function PlayerMovement:clbk_attention_notice_sneak(observer_unit, status, local_client_detection)
	if alive(observer_unit) then
		self:on_suspicion(observer_unit, status, local_client_detection)
	end
end

function PlayerMovement:on_suspicion(observer_unit, status, local_client_detection)
	if Network:is_server() or local_client_detection then
		self._suspicion_debug = self._suspicion_debug or {}
		self._suspicion_debug[observer_unit:key()] = {
			unit = observer_unit,
			name = observer_unit:name(),
			status = status
		}
		local visible_status = nil

		if managers.groupai:state():whisper_mode() and not managers.groupai:state():stealth_hud_disabled() then
			visible_status = status
		else
			visible_status = false
		end

		self._suspicion = self._suspicion or {}

		if visible_status == false or visible_status == true then
			self._suspicion[observer_unit:key()] = nil

			if not next(self._suspicion) then
				self._suspicion = nil
			end

			if visible_status and observer_unit:movement() and not observer_unit:movement():cool() and TimerManager:game():time() - observer_unit:movement():not_cool_t() > 1 then
				self._suspicion_ratio = false

				self:_feed_suspicion_to_hud()

				return
			end
		elseif type(visible_status) == "number" and (not observer_unit:movement() or observer_unit:movement():cool()) then
			self._suspicion[observer_unit:key()] = visible_status
		else
			return
		end

		self:_calc_suspicion_ratio_and_sync(observer_unit, visible_status, local_client_detection)
	else
		self._suspicion_ratio = status
	end

	self:_feed_suspicion_to_hud()
end

function PlayerMovement:_calc_suspicion_ratio_and_sync(observer_unit, status, local_client_detection)
	local suspicion_sync = nil

	if self._suspicion and status ~= true then
		local max_suspicion = nil

		for u_key, val in pairs(self._suspicion) do
			if not max_suspicion or max_suspicion < val then
				max_suspicion = val
			end
		end

		if max_suspicion then
			self._suspicion_ratio = max_suspicion
			suspicion_sync = math.ceil(self._suspicion_ratio * 254)
		else
			self._suspicion_ratio = false
			suspicion_sync = false
		end
	elseif type(status) == "boolean" then
		self._suspicion_ratio = status
		suspicion_sync = status and 255 or 0
	else
		self._suspicion_ratio = false
		suspicion_sync = 0
	end

	if not local_client_detection and suspicion_sync ~= self._synced_suspicion then
		self._synced_suspicion = suspicion_sync
		local peer = managers.network:session():peer_by_unit(self._unit)

		if peer then
			managers.network:session():send_to_peers_synched("suspicion", peer:id(), suspicion_sync)
		end
	end
end

function PlayerMovement:on_non_lethal_electrocution()
	self._state_data.non_lethal_electrocution = true

	if alive(self._unit) then
		self._unit:character_damage():on_tased(true)
		self._unit:sound():say("s07x_sin", true)
	end
end

if deathvox:IsTotalCrackdownEnabled() then
		
	function PlayerMovement:update_stamina(t, dt, ignore_running)
		local dt = self._last_stamina_regen_t and t - self._last_stamina_regen_t or dt
		self._last_stamina_regen_t = t

		if not ignore_running and self._is_running then
			self:subtract_stamina(dt * tweak_data.player.movement_state.stamina.STAMINA_DRAIN_RATE)
		elseif self._regenerate_timer then
			self._regenerate_timer = self._regenerate_timer - dt

			local regen_rate = dt * tweak_data.player.movement_state.stamina.STAMINA_REGEN_RATE
			regen_rate = regen_rate * (1 + (managers.player:team_upgrade_value("crewchief","passive_stamina_regen_mul",0)))
			
			if self._regenerate_timer < 0 then
				self:add_stamina(regen_rate)

				if self:_max_stamina() <= self._stamina then
					self._regenerate_timer = nil
				end
			end
		elseif self._stamina < self:_max_stamina() then
			self:_restart_stamina_regen_timer()
		end

		if _G.IS_VR then
			managers.hud:set_stamina({
				current = self._stamina,
				total = self:_max_stamina()
			})
		end
	end

	function PlayerMovement:subtract_stamina(value, ratio)
		if ratio then
			value = self:_max_stamina() * value
		end
	
		if managers.player:has_category_upgrade("player", "stamina_ammo_refill_single") then
			self._subtracted_stamina_single = (self._subtracted_stamina_single or 0) + math.abs(value)
			local stamina_needed, ammo_refill = unpack(managers.player:upgrade_value("player", "stamina_ammo_refill_single"))

			if stamina_needed < self._subtracted_stamina_single then
				for i = 1, 2 do
					local weapon = self._unit:inventory():unit_by_selection(i):base()

					if weapon:fire_mode() == "single" then
						local ammo = math.ceil(weapon:get_ammo_max() * ammo_refill)

						weapon:add_ammo_to_pool(ammo, i)
					end
				end

				self._subtracted_stamina_single = self._subtracted_stamina_single - stamina_needed
			end
		end

		if managers.player:has_category_upgrade("player", "stamina_ammo_refill_auto") then
			self._subtracted_stamina_auto = (self._subtracted_stamina_auto or 0) + math.abs(value)
			local stamina_needed, ammo_refill = unpack(managers.player:upgrade_value("player", "stamina_ammo_refill_auto"))

			if stamina_needed < self._subtracted_stamina_auto then
				for i = 1, 2 do
					local weapon = self._unit:inventory():unit_by_selection(i):base()

					if weapon:fire_mode() == "auto" then
						local ammo = math.ceil(weapon:get_ammo_max() * ammo_refill)

						weapon:add_ammo_to_pool(ammo, i)
					end
				end

				self._subtracted_stamina_auto = self._subtracted_stamina_auto - stamina_needed
			end
		end

		self:_change_stamina(-math.abs(value))
	end

end

function PlayerMovement:on_SPOOCed(enemy_unit)

	if managers.player:has_category_upgrade("player", "counter_strike_spooc") and self._current_state.in_melee and self._current_state:in_melee() then
		self._current_state:discharge_melee()
		local comeback_strike = managers.player:has_category_upgrade("player", "infiltrator_comeback_strike")
		
		if comeback_strike then
			local ray = self._unit:raycast("ray", self._unit:movement():m_head_pos(), enemy_unit:movement():m_head_pos(), "slot_mask", managers.slot:get_mask("bullet_impact_targets"), "sphere_cast_radius", 20, "ray_type", "body melee")
			
			self._unit:movement():current_state():_do_melee_damage(managers.player:player_timer():time(), nil, ray, nil, nil, true)
		end

		return "countered"
	end

	if self._unit:character_damage()._god_mode or self._unit:character_damage():get_mission_blocker("invulnerable") then
		return
	end
	
	if self._unit:character_damage()._next_cloaker_dodge_t then
		local pm_timer = managers.player:player_timer():time()
		if self._unit:character_damage()._next_cloaker_dodge_t <= pm_timer then
			self._unit:character_damage()._next_cloaker_dodge_t = pm_timer + 10
		
			self._unit:sound():play("clk_baton_swing", nil, false)
			self._unit:sound():play("clk_baton_swing", nil, false)

			self._unit:camera():play_shaker("melee_hit", 0.3)
		
			local push_vec = Vector3()
			local distance = mvector3.direction(push_vec, enemy_unit:movement():m_head_pos(), self._unit:movement():m_pos())
			mvector3.normalize(push_vec)
			mvector3.set_z(push_vec, 0)
			
			self._unit:movement():push(push_vec * 2000)
			local params = {text = "NARROWLY AVOIDED A CLOAKER'S KICK!", time = 1}
			managers.hud._hud_hint:show(params)
			
			return
		end
	end

	if self._current_state_name == "standard" or self._current_state_name == "carry" or self._current_state_name == "bleed_out" or self._current_state_name == "tased" or self._current_state_name == "bipod" then
		local state = "incapacitated"
		state = managers.modifiers:modify_value("PlayerMovement:OnSpooked", state)

		managers.player:set_player_state(state)
		managers.achievment:award(tweak_data.achievement.finally.award)

		return true
	end
end