local mvec3_norm = mvector3.normalize

--i hate my life
PlayerDamage._expres_election_stacks = 0
PlayerDamage._expres_regenerate_speed = 1

Hooks:PostHook(PlayerDamage, "init", "dv_post_init", function(self, unit)
	local player_manager = managers.player
	
	if player_manager:has_category_upgrade("player", "rogue_melee_dodge") then
		self._next_melee_dodge_t = 0
	end
	
	if player_manager:has_category_upgrade("player", "wcard_thorns") then
		self._thorns = true
	end
	
	if player_manager:has_category_upgrade("player", "rogue_sniper_dodge") then
		self._next_sniper_dodge_t = 0
	end
	
	if player_manager:has_category_upgrade("player", "rogue_cloaker_dodge") then
		self._next_cloaker_dodge_t = 0
	end
	
	if player_manager:has_category_upgrade("player", "rogue_taser_dodge") then
		self._next_taser_dodge_t = 0
	end
	
	if player_manager:has_category_upgrade("player", "expres_hot_armorup") then
		self._expres_drain_t = player_manager:upgrade_value("player", "expres_hot_armorup", 5)
	end
end)

function PlayerDamage:clbk_kill_taunt(taunt_data)
	local attacker = taunt_data.attacker_unit

	if not alive(attacker) or attacker:character_damage():dead() then
		return
	end
	
	if taunt_data.taunt_line then
		attacker:sound():say(taunt_data.taunt_line, true)
	end
end

function PlayerDamage:_raw_max_health()
	if managers.player:has_category_upgrade("player", "sociopath_mode") then
		local hp = 4
		
		hp = hp + managers.player:upgrade_value("player", "sociopath_health_addend", 0)
		
		return hp
	end

	local base_max_health = self._HEALTH_INIT + managers.player:health_skill_addend()
	local mul = managers.player:health_skill_multiplier()
	mul = managers.modifiers:modify_value("PlayerDamage:GetMaxHealth", mul)

	return base_max_health * mul
end

function PlayerDamage:_max_health()
	if managers.player:has_category_upgrade("player", "sociopath_mode") then
		return self:_raw_max_health()
	end

	local max_health = self:_raw_max_health()

	if managers.player:has_category_upgrade("player", "armor_to_health_conversion") then
		local max_armor = self:_raw_max_armor()
		local conversion_factor = managers.player:upgrade_value("player", "armor_to_health_conversion") * 0.01
		max_health = max_health + max_armor * conversion_factor
	end

	return max_health
end

function PlayerDamage:_raw_max_armor()
	if managers.player:has_category_upgrade("player", "sociopath_mode") then
		return 0
	end

	local base_max_armor = self._ARMOR_INIT + managers.player:body_armor_value("armor") + managers.player:body_armor_skill_addend()
	local mul = managers.player:body_armor_skill_multiplier()
	mul = managers.modifiers:modify_value("PlayerDamage:GetMaxArmor", mul)

	return base_max_armor * mul
end

function PlayerDamage:_max_armor()
	if managers.player:has_category_upgrade("player", "sociopath_mode") then
		return 0
	end

	local max_armor = self:_raw_max_armor()

	if managers.player:has_category_upgrade("player", "armor_to_health_conversion") then
		local conversion_factor = managers.player:upgrade_value("player", "armor_to_health_conversion") * 0.01
		max_armor = max_armor * (1 - conversion_factor)
	end

	return max_armor
end

function PlayerDamage:update(unit, t, dt)
	if _G.IS_VR and self._heartbeat_t and t < self._heartbeat_t then
		local intensity_mul = 1 - (t - self._heartbeat_start_t) / (self._heartbeat_t - self._heartbeat_start_t)
		local controller = self._unit:base():controller():get_controller("vr")

		for i = 0, 1 do
			local intensity = get_heartbeat_value(t)
			intensity = intensity * (1 - math.clamp(self:health_ratio() / 0.3, 0, 1))
			intensity = intensity * intensity_mul

			controller:trigger_haptic_pulse(i, 0, intensity * 900)
		end
	end

	self:_check_update_max_health()
	self:_check_update_max_armor()
	self:_update_can_take_dmg_timer(dt)
	self:_update_regen_on_the_side(dt)
	
	if self._yakuza_dmg_event_dr then
		if self._yakuza_dmg_event_dr <= 0 then
			self._yakuza_dmg_event_dr = nil
		else
			self._yakuza_dmg_event_dr = self._yakuza_dmg_event_dr - dt
		end
	end

	if not self._armor_stored_health_max_set then
		self._armor_stored_health_max_set = true

		self:update_armor_stored_health()
	end

	if managers.player:has_activate_temporary_upgrade("temporary", "chico_injector") then
		self._chico_injector_active = true
		local total_time = managers.player:upgrade_value("temporary", "chico_injector")[2]
		local current_time = managers.player:get_activate_temporary_expire_time("temporary", "chico_injector") - t

		managers.hud:set_player_ability_radial({
			current = current_time,
			total = total_time
		})
	elseif self._chico_injector_active then
		managers.hud:set_player_ability_radial({
			current = 0,
			total = 1
		})

		self._chico_injector_active = nil
	end

	local is_berserker_active = managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier")

	if self._check_berserker_done then
		if is_berserker_active then
			if self._unit:movement():tased() then
				self._tased_during_berserker = true
			else
				self._tased_during_berserker = false
			end
		end

		if not is_berserker_active then
			if self._unit:movement():tased() then
				self._bleed_out_blocked_by_tased = true
			else
				self._bleed_out_blocked_by_tased = false
				self._check_berserker_done = nil

				managers.hud:set_teammate_condition(HUDManager.PLAYER_PANEL, "mugshot_normal", "")
				managers.hud:set_player_custom_radial({
					current = 0,
					total = self:_max_health(),
					revives = Application:digest_value(self._revives, false)
				})
				self:force_into_bleedout()

				if not self._bleed_out then
					self._disable_next_swansong = true
				end
			end
		else
			local expire_time = managers.player:get_activate_temporary_expire_time("temporary", "berserker_damage_multiplier")
			local total_time = managers.player:upgrade_value("temporary", "berserker_damage_multiplier")
			total_time = total_time and total_time[2] or 0
			local delta = 0
			local max_health = self:_max_health()

			if total_time ~= 0 then
				delta = math.clamp((expire_time - Application:time()) / total_time, 0, 1)
			end

			managers.hud:set_player_custom_radial({
				current = delta * max_health,
				total = max_health,
				revives = Application:digest_value(self._revives, false)
			})
			managers.network:session():send_to_peers("sync_swansong_timer", self._unit, delta * max_health, max_health, Application:digest_value(self._revives, false), managers.network:session():local_peer():id())
		end
	end

	if self._bleed_out_blocked_by_zipline and not self._unit:movement():zipline_unit() then
		self:force_into_bleedout(true)

		self._bleed_out_blocked_by_zipline = nil
	end

	if self._bleed_out_blocked_by_movement_state and not self._unit:movement():current_state():bleed_out_blocked() then
		self:force_into_bleedout()

		self._bleed_out_blocked_by_movement_state = nil
	end

	if self._bleed_out_blocked_by_tased and not self._tased_during_berserker and not self._unit:movement():tased() then
		self:force_into_bleedout()

		self._bleed_out_blocked_by_tased = nil
	end

	if self._current_state then
		self:_current_state(t, dt)
	end

	self:_update_armor_hud(t, dt)

	if self._tinnitus_data then
		self._tinnitus_data.intensity = (self._tinnitus_data.end_t - t) / self._tinnitus_data.duration

		if self._tinnitus_data.intensity <= 0 then
			SoundDevice:set_rtpc("downed_state_progression", math.max(self._downed_progression or 0, 0))
			self:_stop_tinnitus(true)
		else
			SoundDevice:set_rtpc("downed_state_progression", math.max(self._downed_progression or 0, self._tinnitus_data.intensity * 100))
		end
	end

	if self._concussion_data then
		self._concussion_data.intensity = (self._concussion_data.end_t - t) / self._concussion_data.duration

		if self._concussion_data.intensity <= 0 then
			SoundDevice:set_rtpc("concussion_effect", 0)
			self:_stop_concussion(true)
		else
			SoundDevice:set_rtpc("concussion_effect", self._concussion_data.intensity * 100)
		end
	end

	if not self._downed_timer and self._downed_progression then
		self._downed_progression = math.max(0, self._downed_progression - dt * 50)

		if not _G.IS_VR then
			managers.environment_controller:set_downed_value(self._downed_progression)
		end

		SoundDevice:set_rtpc("downed_state_progression", self._downed_progression)

		if self._downed_progression == 0 then
			self._unit:sound():play("critical_state_heart_stop")

			self._downed_progression = nil
		end
	end

	if self._auto_revive_timer then
		if not managers.platform:presence() == "Playing" or not self._bleed_out or self._dead or self:incapacitated() or self:arrested() or self._check_berserker_done then
			self._auto_revive_timer = nil
		else
			self._auto_revive_timer = self._auto_revive_timer - dt

			if self._auto_revive_timer <= 0 then
				self:revive(true)
				self._unit:sound_source():post_event("nine_lives_skill")

				self._auto_revive_timer = nil
			end
		end
	end

	if self._revive_miss then
		self._revive_miss = self._revive_miss - dt

		if self._revive_miss <= 0 then
			self._revive_miss = nil
		end
	end

	self:_upd_suppression(t, dt)
	
	if not managers.player:has_category_upgrade("player", "sociopath_mode") and not managers.player:has_category_upgrade("player", "yakuza_frenzy_dr") then
		if not self._dead and not self._bleed_out and not self._check_berserker_done then
			self:_upd_health_regen(t, dt)
		end

		if not self:is_downed() then
			self:_update_delayed_damage(t, dt)
		end
	end
end

function PlayerDamage:restore_armor_percent(armor_restored)
	if self._dead or self._bleed_out or self._check_berserker_done then
		return
	end

	local max_armor = self:_max_armor()
	local armor = self:get_real_armor()
	local new_armor = max_armor * armor_restored
	
	new_armor = armor + new_armor
	
	new_armor = math.min(new_armor, max_armor)
	
	self:set_armor(new_armor)
	self:_send_set_armor()

	if self._unit:sound() and new_armor ~= armor and new_armor == max_armor then
		self._unit:sound():play("shield_full_indicator")
	end
end

function PlayerDamage:damage_bullet(attack_data)
	if not self:_chk_can_take_dmg() then
		return
	end

	local damage_info = {
		result = {
			variant = "bullet",
			type = "hurt"
		},
		attacker_unit = attack_data.attacker_unit
	}

	if self:is_friendly_fire(attack_data.attacker_unit) then
		return
	elseif self._bleed_out and managers.player:has_category_upgrade("player", "hitman_bleedout_invuln") then
		return
	elseif self._god_mode then
		if attack_data.damage > 0 then
			self:_send_damage_drama(attack_data, attack_data.damage)
		end

		self:_call_listeners(damage_info)

		return
	elseif self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self:incapacitated() then
		return
	elseif self._unit:movement():current_state().immortal then
		return
	elseif self._revive_miss and math.random() < self._revive_miss then
		self:play_whizby(attack_data.col_ray.position)

		return
	elseif self:_chk_dmg_too_soon(attack_data.damage) then
		return
	end

	self:_hit_direction(attack_data.attacker_unit:position())

	local pm = managers.player
	self._last_received_dmg = attack_data.damage
	
	self._next_allowed_dmg_t = Application:digest_value(pm:player_timer():time() + self._dmg_interval, true)
	
	if self._thorns then
		self:do_thorns(attack_data.damage)
	end
	
	if not managers.player:has_category_upgrade("player", "sociopath_mode") then
		local dodge_roll = math.random()
		local dodge_value = tweak_data.player.damage.DODGE_INIT or 0
		local armor_dodge_chance = pm:body_armor_value("dodge")
		local skill_dodge_chance = pm:skill_dodge_chance(self._unit:movement():running(), self._unit:movement():crouching(), self._unit:movement():zipline_unit())
		dodge_value = dodge_value + armor_dodge_chance + skill_dodge_chance

		if self._temporary_dodge_t and TimerManager:game():time() < self._temporary_dodge_t then
			dodge_value = dodge_value + self._temporary_dodge
		end

		local smoke_dodge = 0

		for _, smoke_screen in ipairs(pm._smoke_screen_effects or {}) do
			if smoke_screen:is_in_smoke(self._unit) then
				smoke_dodge = tweak_data.projectiles.smoke_screen_grenade.dodge_chance

				break
			end
		end

		dodge_value = 1 - (1 - dodge_value) * (1 - smoke_dodge)

		if dodge_roll < dodge_value then
			self:play_whizby(attack_data.col_ray.position)
			pm:send_message(Message.OnPlayerDodge)

			return
		end
	
		local dmg_mul = pm:damage_reduction_skill_multiplier("bullet")
		attack_data.damage = attack_data.damage * dmg_mul
		attack_data.damage = pm:modify_value("damage_taken", attack_data.damage, attack_data)
		attack_data.damage = managers.mutators:modify_value("PlayerDamage:TakeDamageBullet", attack_data.damage)
		attack_data.damage = managers.modifiers:modify_value("PlayerDamage:TakeDamageBullet", attack_data.damage)
		
		if _G.IS_VR then
			local distance = mvector3.distance(self._unit:position(), attack_data.attacker_unit:position())

			if tweak_data.vr.long_range_damage_reduction_distance[1] < distance then
				local step = math.clamp(distance / tweak_data.vr.long_range_damage_reduction_distance[2], 0, 1)
				local mul = 1 - math.step(tweak_data.vr.long_range_damage_reduction[1], tweak_data.vr.long_range_damage_reduction[2], step)
				attack_data.damage = attack_data.damage * mul
			end
		end
		
		local damage_absorption = pm:damage_absorption()

		if damage_absorption > 0 then
			attack_data.damage = math.max(0, attack_data.damage - damage_absorption)
		end
	else
		attack_data.damage = 1
	end
	
	attack_data.damage = pm:consume_damage_overshield(attack_data.damage)

	local shake_armor_multiplier = pm:body_armor_value("damage_shake") * pm:upgrade_value("player", "damage_shake_multiplier", 1)
	local gui_shake_number = tweak_data.gui.armor_damage_shake_base / shake_armor_multiplier
	gui_shake_number = gui_shake_number + pm:upgrade_value("player", "damage_shake_addend", 0)
	shake_armor_multiplier = tweak_data.gui.armor_damage_shake_base / gui_shake_number
	local shake_multiplier = math.clamp(attack_data.damage, 0.2, 2) * shake_armor_multiplier

	self._unit:camera():play_shaker("player_bullet_damage", 1 * shake_multiplier)

	if not _G.IS_VR then
		managers.rumble:play("damage_bullet")
	end

	pm:check_damage_carry(attack_data)

	if self._bleed_out then
		if attack_data.damage == 0 then
			self._unit:sound():play("player_hit")
		else
			self._unit:sound():play("player_hit_permadamage")
		end

		self:_bleed_out_damage(attack_data)

		return
	else
		if self:get_real_armor() > 0 or attack_data.damage == 0 then
			self._unit:sound():play("player_hit")
		else
			self._unit:sound():play("player_hit_permadamage")
		end
	end

	self:_check_chico_heal(attack_data)

	local armor_reduction_multiplier = 0

	if self:get_real_armor() <= 0 then
		armor_reduction_multiplier = 1
	end

	local health_subtracted = self:_calc_armor_damage(attack_data)

	if attack_data.armor_piercing then
		attack_data.damage = attack_data.damage - health_subtracted
	else
		attack_data.damage = attack_data.damage * armor_reduction_multiplier
	end

	health_subtracted = health_subtracted + self:_calc_health_damage(attack_data)

	if not self._bleed_out then
		if health_subtracted > 0 then
			self:_send_damage_drama(attack_data, health_subtracted)
		end
	else
		self:chk_queue_taunt_line(attack_data)
	end

	pm:send_message(Message.OnPlayerDamage, nil, attack_data)
	self:_call_listeners(damage_info)

	return true
end

function PlayerDamage:clbk_kill_taunt_common(attack_data)
	local attacker = attack_data.attacker_unit

	if attacker and alive(attacker) and attacker:character_damage() and attacker:character_damage().dead and not attacker:character_damage():dead() then
		attacker:sound():say("i03")
	end

	self._kill_taunt_clbk_id = nil
end

function PlayerDamage:clbk_kill_taunt_tase(attack_data)
--[[
	local attacker = attack_data.attacker_unit

	if attacker and alive(attacker) and attacker:character_damage() and attacker:character_damage().dead and not attacker:character_damage():dead() then
		attacker:sound():say("tsr_post_tasing_taunt")
	end
--]]
	self._kill_taunt_clbk_id = nil
end

--local _chk_dmg_too_soon_orig = PlayerDamage._chk_dmg_too_soon
function PlayerDamage:_chk_dmg_too_soon(damage, ...)
	local next_allowed_dmg_t = type(self._next_allowed_dmg_t) == "number" and self._next_allowed_dmg_t or Application:digest_value(self._next_allowed_dmg_t, false)
	local t = managers.player:player_timer():time()

	if damage <= self._last_received_dmg + 0.01 and next_allowed_dmg_t > t then
		self._old_last_received_dmg = nil
		self._old_next_allowed_dmg_t = nil

		return true
	end

	if next_allowed_dmg_t > t then
		self._old_last_received_dmg = self._last_received_dmg
		self._old_next_allowed_dmg_t = next_allowed_dmg_t
	end
end

function PlayerDamage:damage_killzone(attack_data)
	local damage_info = {
		result = {
			variant = "killzone",
			type = "hurt"
		}
	}

	if self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self:incapacitated() then
		return
	elseif self._unit:movement():current_state().immortal then
		return
	end

	if attack_data.instant_death then
		self._unit:sound():play("player_hit_permadamage")
		self:set_armor(0)
		self:set_health(0)
		self:_send_set_armor()
		self:_send_set_health()
		managers.hud:set_player_health({
			current = self:get_real_health(),
			total = self:_max_health(),
			revives = Application:digest_value(self._revives, false)
		})
		self:_set_health_effect()
		self:_damage_screen()
		self:_check_bleed_out(nil)	
	else
		if not self:_chk_can_take_dmg() then
			return
		end
		
		if self:get_real_armor() > 0 then
			self._unit:sound():play("player_hit")
		else
			self._unit:sound():play("player_hit_permadamage")
		end
		
		self:_hit_direction(attack_data.col_ray.origin)

		if self._bleed_out then
			return
		end
		
		local pm = managers.player
		
		if pm:has_category_upgrade("player", "sociopath_mode") then
			attack_data.damage = 1
		else
			attack_data.damage = pm:modify_value("damage_taken", attack_data.damage, attack_data)
		end
		
		attack_data.damage = pm:consume_damage_overshield(attack_data.damage) 

		self:_check_chico_heal(attack_data)

		local armor_reduction_multiplier = 0

		if self:get_real_armor() <= 0 then
			armor_reduction_multiplier = 1
		end

		local health_subtracted = self:_calc_armor_damage(attack_data)
		attack_data.damage = attack_data.damage * armor_reduction_multiplier
		health_subtracted = health_subtracted + self:_calc_health_damage(attack_data)
	end

	self:_call_listeners(damage_info)
end

local _calc_armor_damage_original = PlayerDamage._calc_armor_damage
function PlayerDamage:_calc_armor_damage(attack_data, ...)
	if self:get_real_armor() > 0 then
		if self._old_last_received_dmg then
			attack_data.damage = attack_data.damage - self._old_last_received_dmg
		end
		
		self._next_allowed_dmg_t = self._old_next_allowed_dmg_t and Application:digest_value(self._old_next_allowed_dmg_t, true) or self._next_allowed_dmg_t
		self._old_last_received_dmg = nil
		self._old_next_allowed_dmg_t = nil
	end

	return _calc_armor_damage_original(self, attack_data, ...)
end

local _calc_health_damage_original = PlayerDamage._calc_health_damage
function PlayerDamage:_calc_health_damage(attack_data, ...)
	if self._old_last_received_dmg then
		attack_data.damage = attack_data.damage - self._old_last_received_dmg
	end

	self._next_allowed_dmg_t = self._old_next_allowed_dmg_t and Application:digest_value(self._old_next_allowed_dmg_t, true) or self._next_allowed_dmg_t
	self._old_last_received_dmg = nil
	self._old_next_allowed_dmg_t = nil

	return _calc_health_damage_original(self, attack_data, ...)
end

function PlayerDamage:damage_melee(attack_data)
	if not self:_chk_can_take_dmg() then
		return
	end

	local pm = managers.player
	local can_counter_strike = pm:has_category_upgrade("player", "counter_strike_melee")

	if can_counter_strike and self._unit:movement():current_state().in_melee and self._unit:movement():current_state():in_melee() then
		if attack_data.attacker_unit and alive(attack_data.attacker_unit) and attack_data.attacker_unit:base() then
			local comeback_strike = pm:has_category_upgrade("player", "infiltrator_comeback_strike")
			local is_dozer = not comeback_strike and attack_data.attacker_unit:base().has_tag and attack_data.attacker_unit:base():has_tag("tank")

			--prevent the player from countering Dozers or other players through FF, for obvious reasons
			if not attack_data.attacker_unit:base().is_husk_player and not is_dozer then
			
				if comeback_strike then
					local ray = self._unit:raycast("ray", self._unit:movement():m_head_pos(), attack_data.attacker_unit:movement():m_head_pos(), "slot_mask", managers.slot:get_mask("bullet_impact_targets"), "sphere_cast_radius", 20, "ray_type", "body melee")
					
					self._unit:movement():current_state():_do_melee_damage(pm:player_timer():time(), nil, ray, nil, nil, true)
				end	
				
				self._unit:movement():current_state():discharge_melee()

				return "countered"
			end
		end
	end

	local damage_info = {
		result = {
			variant = "melee",
			type = "hurt"
		},
		attacker_unit = attack_data.attacker_unit
	}

	if self:is_friendly_fire(attack_data.attacker_unit) then
		return
	elseif self._bleed_out and managers.player:has_category_upgrade("player", "hitman_bleedout_invuln") then
		return
	elseif self._god_mode then
		if attack_data.damage > 0 then
			self:_send_damage_drama(attack_data, attack_data.damage)
		end

		self:_call_listeners(damage_info)

		return
	elseif self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self:incapacitated() then
		return
	elseif self._unit:movement():current_state().immortal then
		return
	elseif self:_chk_dmg_too_soon(attack_data.damage) then
		return
	end

	self:_hit_direction(attack_data.attacker_unit:position())

	self._last_received_dmg = attack_data.damage
	self._next_allowed_dmg_t = Application:digest_value(pm:player_timer():time() + self._dmg_interval, true)
	
	if self._thorns then
		self:do_thorns(attack_data.damage)
	end
	
	local allow_melee_dodge = self._next_melee_dodge_t and self._next_melee_dodge_t < pm:player_timer():time() --manual toggle, to be later replaced with a Rogue melee dodge perk check

	if allow_melee_dodge and pm:current_state() ~= "bleed_out" and pm:current_state() ~= "bipod" and pm:current_state() ~= "tased" then --self._bleed_out and current_state() ~= "bleed_out" aren't the same thing
		self._unit:movement():push(attack_data.push_vel * 0.25)
		self._unit:camera():play_shaker("melee_hit", 0.1)
			
		self._unit:sound():play("clk_baton_swing", nil, false)
		self._unit:sound():play("clk_baton_swing", nil, false)
		
		self._next_melee_dodge_t = pm:player_timer():time() + 10
		pm:send_message(Message.OnPlayerDodge)

		return
	end
	
	if not pm:has_category_upgrade("player", "sociopath_mode") then
		local dmg_mul = pm:damage_reduction_skill_multiplier("melee") --the vanilla function has this line, but it also uses bullet damage reduction skills due to it redirecting to damage_bullet to get results
		attack_data.damage = attack_data.damage * dmg_mul
		attack_data.damage = pm:modify_value("damage_taken", attack_data.damage, attack_data) --apply damage resistances before checking for bleedout and other things

		local damage_absorption = pm:damage_absorption()

		if damage_absorption > 0 then
			attack_data.damage = math.max(0, attack_data.damage - damage_absorption)
		end
	else
		attack_data.damage = 1
	end
	
	attack_data.damage = pm:consume_damage_overshield(attack_data.damage)

	if attack_data.tase_player then
		if pm:current_state() == "standard" or pm:current_state() == "carry" or pm:current_state() == "bipod" then
			if pm:current_state() == "bipod" then
				self._unit:movement()._current_state:exit(nil, "tased")
			end

			self._unit:movement():on_non_lethal_electrocution()
			pm:set_player_state("tased")

			--no pushing and camera shaking for melee tase attacks
		end
	else
		if pm:current_state() == "bipod" then
			self._unit:movement()._current_state:exit(nil, "standard")
			pm:set_player_state("standard")
		end

		local vars = {
			"melee_hit",
			"melee_hit_var2"
		}

		self._unit:camera():play_shaker(vars[math.random(#vars)], 0.5)

		--no pushing when in bleedout, looks silly in third-person
		if pm:current_state() ~= "bleed_out" then
			self._unit:movement():push(attack_data.push_vel)
		end
	end

	if self._bleed_out then
		self:_bleed_out_damage(attack_data)

		--bleed_out = always taking health damage, so use the appropiate sound and cause a blood effect if the weapon isn't tase capable
		local hit_sound = "hit_body"

		--unless damage is completely negated
		if attack_data.damage == 0 then
			hit_sound = "hit_gen"
		end

		self:play_melee_hit_sound_and_effects(attack_data, hit_sound, not attack_data.tase_player)

		return
	end

	self:_check_chico_heal(attack_data)

	local go_through_armor = false --manual toggle
	local health_subtracted = nil
	local armor_broken = false

	if go_through_armor then
		health_subtracted = self:_calc_armor_damage(attack_data)

		attack_data.damage = attack_data.damage - health_subtracted

		health_subtracted = health_subtracted + self:_calc_health_damage(attack_data)

		armor_broken = self:_max_armor() == 0 or self:_max_armor() > 0 and self:get_real_armor() <= 0 --works when armor is broken and health damage is taken by the same hit
	else
		local armor_reduction_multiplier = 0

		if self:get_real_armor() <= 0 then --if armor is already broken, don't negate health damage
			armor_reduction_multiplier = 1
			armor_broken = true --checked before actually taking damage
		end

		health_subtracted = self:_calc_armor_damage(attack_data)

		if attack_data.melee_armor_piercing then --for specific cases, like say, making headless Dozers able to go through armor with melee when other enemies can't
			attack_data.damage = attack_data.damage - health_subtracted
		else
			attack_data.damage = attack_data.damage * armor_reduction_multiplier
		end

		health_subtracted = health_subtracted + self:_calc_health_damage(attack_data)
	end

	local hit_sound_type = "hit_gen"
	local blood_effect = false

	if armor_broken then
		hit_sound_type = "hit_body"
		blood_effect = not attack_data.tase_player
	end

	self:play_melee_hit_sound_and_effects(attack_data, hit_sound_type, blood_effect)

	if not self._bleed_out then
		if health_subtracted > 0 then
			self:_send_damage_drama(attack_data, health_subtracted)
		end
	else
		local attacker = attack_data.attacker_unit

		if attacker:character_damage() and attacker:character_damage().dead and not attacker:character_damage():dead() then
			if attacker:base().has_tag then
				if attacker:base():has_tag("tank") then
					self._kill_taunt_clbk_id = "kill_taunt" .. tostring(self._unit:key())
					managers.enemy:add_delayed_clbk(self._kill_taunt_clbk_id, callback(self, self, "clbk_kill_taunt", attack_data), TimerManager:game():time() + 0.5)
				elseif attacker:base():has_tag("taser") then
					self._kill_taunt_clbk_id = "kill_taunt" .. tostring(self._unit:key())
					managers.enemy:add_delayed_clbk(self._kill_taunt_clbk_id, callback(self, self, "clbk_kill_taunt_tase", attack_data), TimerManager:game():time() + 0.5)
				elseif attacker:base():has_tag("law") and not attacker:base():has_tag("special") then
					self._kill_taunt_clbk_id = "kill_taunt" .. tostring(self._unit:key())
					managers.enemy:add_delayed_clbk(self._kill_taunt_clbk_id, callback(self, self, "clbk_kill_taunt_common", attack_data), TimerManager:game():time() + 0.5)
				end
			end
		end
	end

	pm:send_message(Message.OnPlayerDamage, nil, attack_data)
	self:_call_listeners(damage_info)

	return
end

local mvec1 = Vector3()

function PlayerDamage:play_melee_hit_sound_and_effects(attack_data, sound_type, play_blood_effect)
	if play_blood_effect then
		--make sure the weapon is supposed to cause a blood splatter
		local blood_effect = attack_data.melee_weapon and attack_data.melee_weapon == "weapon"
		blood_effect = blood_effect or attack_data.melee_weapon and tweak_data.weapon.npc_melee[attack_data.melee_weapon] and tweak_data.weapon.npc_melee[attack_data.melee_weapon].player_blood_effect or false

		if blood_effect then --spawn a blood splatter in front of the player
			local pos = mvec1

			mvector3.set(pos, self._unit:camera():forward())
			mvector3.multiply(pos, 20)
			mvector3.add(pos, self._unit:camera():position())

			local rot = self._unit:camera():rotation():z()

			World:effect_manager():spawn({
				effect = Idstring("effects/payday2/particles/impacts/blood/blood_impact_a"),
				position = pos,
				normal = rot
			})
		end
	end

	local melee_name_id = nil
	local attacker_unit = attack_data.attacker_unit
	local valid_attacker = attacker_unit and alive(attacker_unit) and attacker_unit:base()

	if valid_attacker then
		--get melee weapon id
		if attacker_unit:base().is_husk_player then
			local peer_id = managers.network:session():peer_by_unit(attacker_unit):id()
			local peer = managers.network:session():peer(peer_id)

			melee_name_id = peer:melee_id()
		else
			melee_name_id = attacker_unit:base().melee_weapon and attacker_unit:base():melee_weapon()
		end

		if melee_name_id then
			if melee_name_id == "knife_1" then --knife used by NPCs
				melee_name_id = "kabar"
			elseif melee_name_id == "helloween" then --titan staff used by headless Dozers
				melee_name_id = "brass_knuckles"
			elseif not attacker_unit:base().is_husk_player and melee_name_id == "baton" then --cop baton (otherwise the ballistic baton's sounds are used)
				melee_name_id = "weapon"
			end

			local tweak_data = tweak_data.blackmarket.melee_weapons[melee_name_id]

			if tweak_data and tweak_data.sounds and tweak_data.sounds[sound_type] then
				local post_event = tweak_data.sounds[sound_type]
				local anim_attack_vars = tweak_data.anim_attack_vars
				local variation = anim_attack_vars and math.random(#anim_attack_vars)

				if type(post_event) == "table" then
					if variation then
						post_event = post_event[variation]
					else
						post_event = post_event[1]
					end
				end
				
				--log(tostring(post_event))
				
				--some sounds are too low to hear, playing them twice helps and or accentuates a hit even more)
				self._unit:sound():play(post_event, nil, false)
				self._unit:sound():play(post_event, nil, false)
			end
		end
	end
end

function PlayerDamage:damage_tase(attack_data)
	if self._god_mode then
		return
	end
	
	local pm = managers.player
	
	if self._next_taser_dodge_t and self._next_taser_dodge_t < pm:player_timer():time() then 
		self._next_taser_dodge_t = pm:player_timer():time() + 10
		
		self._unit:sound():play("clk_baton_swing", nil, false)
		self._unit:sound():play("clk_baton_swing", nil, false)

		self._unit:camera():play_shaker("melee_hit", 0.3)
		
		local params = {text = "NARROWLY AVOIDED A TASER'S HOOKS!", time = 1}
		managers.hud._hud_hint:show(params)
		
		return
	end
	
	local cur_state = self._unit:movement():current_state_name()

	if cur_state ~= "tased" and cur_state ~= "fatal" then
		self:on_tased(false)

		self._tase_data = attack_data

		managers.player:set_player_state("tased")

		local damage_info = {
			result = {
				variant = "tase",
				type = "hurt"
			}
		}

		self:_call_listeners(damage_info)

		if attack_data.attacker_unit and attack_data.attacker_unit:alive() and attack_data.attacker_unit:base()._tweak_table == "taser" then
			attack_data.attacker_unit:sound():say("post_tasing_taunt")

			if managers.blackmarket:equipped_mask().mask_id == tweak_data.achievement.its_alive_its_alive.mask then
				managers.achievment:award_progress(tweak_data.achievement.its_alive_its_alive.stat)
			end
		end
	end
end

function PlayerDamage:damage_fire(attack_data)
	if attack_data.is_hit then
		return self:damage_fire_hit(attack_data)
	end

	if not self:_chk_can_take_dmg() or self:incapacitated() then
		return
	end

	local attack_pos = attack_data.position or attack_data.col_ray.position or attack_data.attacker_unit and alive(attack_data.attacker_unit) and attack_data.attacker_unit:position()
	local distance = mvector3.distance(attack_pos, self._unit:position())

	if not attack_data.range then
		attack_data.range = distance
	end

	if attack_data.range < distance then
		return
	elseif self:is_friendly_fire(attack_data.attacker_unit) then
		return
	elseif self._bleed_out and managers.player:has_category_upgrade("player", "hitman_bleedout_invuln") then
		return
	end

	local damage_info = {
		result = {
			variant = "fire",
			type = "hurt"
		}
	}

	local damage = attack_data.damage or 1
	attack_data.damage = damage

	if self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self._unit:movement():current_state().immortal then
		return
	elseif self:_chk_dmg_too_soon(attack_data.damage) then
		return
	end

	if attack_data.attacker_unit and alive(attack_data.attacker_unit) then
		self:_hit_direction(attack_data.attacker_unit:position())
	end

	local pm = managers.player

	self._last_received_dmg = attack_data.damage
	self._next_allowed_dmg_t = Application:digest_value(pm:player_timer():time() + self._dmg_interval, true)
	
	if not pm:has_category_upgrade("player", "sociopath_mode") then
		local dmg_mul = pm:damage_reduction_skill_multiplier("fire")
		attack_data.damage = attack_data.damage * dmg_mul
		attack_data.damage = pm:modify_value("damage_taken", attack_data.damage, attack_data)
	

		local damage_absorption = pm:damage_absorption()

		if damage_absorption > 0 then
			attack_data.damage = math.max(0, attack_data.damage - damage_absorption)
		end
	else
		attack_data.damage = 1
	end
	
	attack_data.damage = pm:consume_damage_overshield(attack_data.damage)

	if self._bleed_out then
		if attack_data.damage == 0 then
			self._unit:sound():play("player_hit")
		else
			self._unit:sound():play("player_hit_permadamage")
		end

		self:_bleed_out_damage(attack_data)

		return
	else
		if self:get_real_armor() > 0 or attack_data.damage == 0 then
			self._unit:sound():play("player_hit")
		else
			self._unit:sound():play("player_hit_permadamage")
		end
	end

	self:_check_chico_heal(attack_data)

	local armor_reduction_multiplier = 0

	if self:get_real_armor() <= 0 then
		armor_reduction_multiplier = 1
	end

	local health_subtracted = self:_calc_armor_damage(attack_data)

	attack_data.damage = attack_data.damage * armor_reduction_multiplier
	health_subtracted = health_subtracted + self:_calc_health_damage(attack_data)

	pm:send_message(Message.OnPlayerDamage, nil, attack_data)
	self:_call_listeners(damage_info)
end

function PlayerDamage:damage_explosion(attack_data)
	if not self:_chk_can_take_dmg() or self:incapacitated() then
		return
	end

	local attack_pos = attack_data.position or attack_data.col_ray.position or attack_data.attacker_unit and alive(attack_data.attacker_unit) and attack_data.attacker_unit:position()
	local distance = mvector3.distance(attack_pos, self._unit:position())

	if not attack_data.range then
		attack_data.range = distance
	end

	if attack_data.range < distance then
		return
	elseif self:is_friendly_fire(attack_data.attacker_unit) then
		return
	elseif self._bleed_out and managers.player:has_category_upgrade("player", "hitman_bleedout_invuln") then
		return
	end

	local damage_info = {
		result = {
			variant = "explosion",
			type = "hurt"
		}
	}

	if self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self._unit:movement():current_state().immortal then
		return
	end

	local pm = managers.player
	
	if not pm:has_category_upgrade("player", "sociopath_mode") then
		local damage = attack_data.damage or 1
		attack_data.damage = damage
		attack_data.damage = attack_data.damage * (1 - distance / attack_data.range)

		local dmg_mul = pm:damage_reduction_skill_multiplier("explosion")
		attack_data.damage = attack_data.damage * dmg_mul
		attack_data.damage = pm:modify_value("damage_taken", attack_data.damage, attack_data)
		attack_data.damage = managers.modifiers:modify_value("PlayerDamage:OnTakeExplosionDamage", attack_data.damage)

		local damage_absorption = pm:damage_absorption()

		if damage_absorption > 0 then
			attack_data.damage = math.max(0, attack_data.damage - damage_absorption)
		end
	else
		attack_data.damage = 1
	end
	
	attack_data.damage = pm:consume_damage_overshield(attack_data.damage)

	if attack_data.attacker_unit and alive(attack_data.attacker_unit) then
		self:_hit_direction(attack_data.attacker_unit:position())
	end

	if self._bleed_out then
		if attack_data.damage == 0 then
			self._unit:sound():play("player_hit")
		else
			self._unit:sound():play("player_hit_permadamage")
		end

		self:_bleed_out_damage(attack_data)

		return
	else
		if self:get_real_armor() > 0 or attack_data.damage == 0 then
			self._unit:sound():play("player_hit")
		else
			self._unit:sound():play("player_hit_permadamage")
		end

		local allow_explosive_pushes = false

		--enjoy your rocket/grenade/trip mine jumps
		if allow_explosive_pushes and attack_data.damage ~= 0 then
			local push_vec = Vector3()
			mvector3.direction(push_vec, attack_pos, self._unit:movement():m_head_pos())

			local final_damage = attack_data.damage
			local max_damage = 40 --RPG player damage, aka maximum explosive damage that the player can normally take
			local dmg_lerp_value = math.clamp(final_damage, 1, max_damage) / max_damage
			local push_force = math.lerp(600, 2000, dmg_lerp_value)

			self._unit:movement():push(push_vec * push_force)
		end
	end

	self:_check_chico_heal(attack_data)

	local health_subtracted = self:_calc_armor_damage(attack_data)

	attack_data.damage = attack_data.damage - health_subtracted
	health_subtracted = health_subtracted + self:_calc_health_damage(attack_data)

	pm:send_message(Message.OnPlayerDamage, nil, attack_data)
	self:_call_listeners(damage_info)
end

function PlayerDamage:do_thorns(damage)
	local player_manager = managers.player
	
	local aced = player_manager:has_category_upgrade("player", "wcard_thorns_stagger")
	
	local m_head_pos = player_manager:local_player():movement():m_head_pos()
	local weap_unit = player_manager:get_current_state()._equipped_unit
	local enemies = World:find_units_quick(self._unit, "sphere", self._unit:position(), 200, managers.slot:get_mask("enemies"))
	
	for i = 1, #enemies do
		local enemy = enemies[i]
		local dmg_ext = enemy:character_damage()

		if dmg_ext and dmg_ext.damage_simple then
			local center_of_mass = enemy:movement():m_com()
			local attack_dir = center_of_mass - m_head_pos
			mvec3_norm(attack_dir)

			local attack_data = {
				damage = damage,
				attacker_unit = self._unit,
				no_weapon_stats = true,
				stagger = aced,
				pos = center_of_mass,
				attack_dir = attack_dir,
				weapon_unit = weap_unit
			}

			dmg_ext:damage_simple(attack_data)
		end
	end
end

Hooks:Register("OnPlayerShieldBroken")

function PlayerDamage:_damage_screen()
	if not managers.player:has_category_upgrade("player", "sociopath_mode") then
		local armor_ratio = self:armor_ratio()
		self._hurt_value = 1 - math.clamp(0.8 - math.pow(armor_ratio, 2), 0, 1)
		self._armor_value = math.clamp(armor_ratio, 0, 1)

		managers.environment_controller:set_hurt_value(self._hurt_value)
	end
	
	self._listener_holder:call("on_damage")
end

function PlayerDamage:_set_health_effect()
	if not managers.player:has_category_upgrade("player", "sociopath_mode") then
		local hp = self:get_real_health() / self:_max_health()

		math.clamp(hp, 0, 1)
		managers.environment_controller:set_health_effect_value(hp)
	end
end

function PlayerDamage:build_suppression(amount)
	if not managers.player:has_category_upgrade("player", "sociopath_mode") then
		if self:_chk_suppression_too_soon(amount) then
			return
		end

		local data = self._supperssion_data
		amount = amount * managers.player:upgrade_value("player", "suppressed_multiplier", 1)
		local morale_boost_bonus = self._unit:movement():morale_boost()

		if morale_boost_bonus then
			amount = amount * morale_boost_bonus.suppression_resistance
		end

		amount = amount * tweak_data.player.suppression.receive_mul
		data.value = math.min(tweak_data.player.suppression.max_value, (data.value or 0) + amount * tweak_data.player.suppression.receive_mul)
		self._last_received_sup = amount
		self._next_allowed_sup_t = managers.player:player_timer():time() + self._dmg_interval
		data.decay_start_t = managers.player:player_timer():time()
	end
end

function PlayerDamage:_on_damage_event()
	self:set_regenerate_timer_to_max()
	
	local player_manager = managers.player
	
	if player_manager:has_category_upgrade("player", "sociopath_mode") then
		World:effect_manager():spawn({
			effect = Idstring("effects/pd2_mod_gageammo/particles/character/sociopath_damage"),
			position = Vector3(),
			rotation = Rotation()
		})
		self._unit:sound():play("knife_hit_body", nil, nil)
		self._hurt_value = 0
		self._can_take_dmg_timer = 2 + player_manager:upgrade_value("player", "sociopath_i_frames_add", 0)
		
		local env_value = self._can_take_dmg_timer - 0.35
		
		managers.environment_controller:set_sociopath_inv_value(env_value)
	end
	
	if player_manager:has_category_upgrade("player", "yakuza_on_damage_iframes") then
		self._can_take_dmg_timer = 1
	end
	
	if player_manager:has_category_upgrade("player", "yakuza_on_damage_dr") then
		self._yakuza_dmg_event_dr = 5
	end

	local armor_broken = self:_max_armor() > 0 and self:get_real_armor() <= 0

	if armor_broken then 
		self._expres_can_insta_regen = true
		
		if player_manager:has_category_upgrade("player", "expres_approval_regenerate_time") then
			local max_regen_speed = player_manager:upgrade_value("player", "expres_approval_regenerate_time", 0)
			local expres_stacks = self._expres_election_stacks
			local step = 8
			
			while expres_stacks >= step do
				self._expres_regenerate_speed = self._expres_regenerate_speed + 0.2

				if self._expres_regenerate_speed < 1.6 then
					step = step + 8
				else
					break
				end
			end
		end
		
		
		Hooks:Call("OnPlayerShieldBroken",self._unit)
		if self._has_damage_speed then
			player_manager:activate_temporary_upgrade("temporary", "damage_speed_multiplier")
		end
		if self._has_damage_speed_team then
			player_manager:send_activate_temporary_team_upgrade_to_peers("temporary", "team_damage_speed_multiplier_received")
		end
	end
end

Hooks:Register("deathvox_OnPlayerEnteredBleedout")
Hooks:PostHook(PlayerDamage,"init","tcd_post_playerdamage_init",function(self,unit)
	self._listener_holder:add("on_bleedout_remove_armor_plates_bonus",{"on_enter_bleedout"},callback(self,self,"remove_armor_plates_bonus"))
	self._listener_holder:add("on_bleedout_call_deathvox_listeners",{"on_enter_bleedout"},function()
		Hooks:Call("deathvox_OnPlayerEnteredBleedout")
	end)

	if managers.player:has_category_upgrade("player", "muscle_beachyboys") then
		self._listener_holder:add("on_bleedout_beach_health_point_removal",{"on_enter_bleedout"},callback(self,self,"blush_beach_hp"))
	end
end)

function PlayerDamage:blush_beach_hp()
	--log(tostring(self:_max_health()))
	managers.player._beach_health_points = 0
end

--tcd only
function PlayerDamage:has_armor_plates_bonus()
	return managers.player:get_property("armor_plates_active")
end

function PlayerDamage:acquire_armor_plates_bonus()
	managers.player:set_property("armor_plates_active",true)
	managers.player:set_property("armor_plates_free_revive",true)
	self:restore_armor(self:_max_armor())
end

function PlayerDamage:remove_armor_plates_bonus()
	managers.player:set_property("armor_plates_active",false)
end

function PlayerDamage:remove_armor_plates_bonus()
	managers.player:set_property("armor_plates_active",false)
end

if deathvox:IsTotalCrackdownEnabled() then 

	function PlayerDamage:_upd_health_regen(t, dt)
		local player_manager = managers.player
		local current_health_f = self.get_real_health
		local max_health = self:_max_health()
		local armor = self:get_real_armor()
		
		if self._health_regen_update_timer then
			self._health_regen_update_timer = self._health_regen_update_timer - dt

			if self._health_regen_update_timer <= 0 then
				self._health_regen_update_timer = nil
			end
		end
		
			
		--vanilla 5s interval passive hp regen over time
		if not self._health_regen_update_timer then
			--hp regen check is only performed on this interval
			--timer continues to progress even when hp is full and regen check fails,
			--unlike tcd's muscle/crewchief passive health regen over time
			if current_health_f(self) < max_health then
				local health_regen = player_manager:health_regen()
				local fixed_health_regen = player_manager:fixed_health_regen(self:health_ratio())
				
				if health_regen > 0 then
					self:restore_health(health_regen, false)
				end
				
				if fixed_health_regen > 0 then
					self:restore_health(fixed_health_regen, true)
				end

			end
			self._health_regen_update_timer = 5
		end
		
		--tcd 1s interval passive hp regen over time
		if current_health_f(self) < max_health then
			if not player_manager:has_active_temporary_property("generic_hot_cooldown") then 
				local health_regen = 0
				health_regen = health_regen + player_manager:team_upgrade_value("crewchief","passive_health_regen",0)
				health_regen = health_regen + player_manager:upgrade_value("player", "muscle_health_regen", 0)
				if health_regen > 0 then
					self:restore_health(health_regen, false)
					player_manager:activate_temporary_property("generic_hot_cooldown",1,1)
				end
			end
			
		--continuous hp over time (requires some backend networking tweaks in order to not clog the traffic; otherwise functional)
--			local continuous_health_regen = 0
--			continuous_health_regen = continuous_health_regen + player_manager:team_upgrade_value("crewchief","passive_health_regen",0)
--			continuous_health_regen = continuous_health_regen + player_manager:upgrade_value("player", "muscle_health_regen", 0)
--			if continuous_health_regen > 0 then 
--				self:restore_health(continuous_health_regen * dt,false)
--			end
		end
		
		--Medic tree Checkup skill, docbag AoE hp regen over time (3s Basic/6s Aced interval)
		if current_health_f(self) < max_health then
			if not player_manager:has_active_temporary_property("docbag_hot_aoe_cooldown") then 
				local found_docbag = DoctorBagBase.GetDoctorBag(player_manager:local_player():movement():m_head_pos())
				if found_docbag then 
					local rate,interval,range = unpack(managers.player:upgrade_value_by_level("doctor_bag","aoe_health_regen",found_docbag._aoe_health_regen_level,{0,0,math.huge}))
					self:restore_health(rate,false)
					player_manager:activate_temporary_property("docbag_hot_aoe_cooldown",interval,interval)
				end
			end
		end
		
		if self._expres_election_stacks > 0 then
			if current_health_f(self) < max_health and not self._expres_can_insta_regen then
				if player_manager:has_category_upgrade("player", "expres_hot_armorup") then
					if self._expres_drain_t > 0 then
						self._expres_drain_t = self._expres_drain_t - dt
					else
						self._expres_drain_t = player_manager:upgrade_value("player", "expres_hot_armorup", 5)
						
						local regen_data = managers.player:upgrade_value("player", "expres_hot_election", {0, 0})
						local stacks_to_consume = 0.5
						
						self._expres_election_stacks = self._expres_election_stacks - stacks_to_consume
						self:restore_health(stacks_to_consume, true)
						
						if managers.hud then
							local shown_stacks = self._expres_election_stacks
							local max_stacks = regen_data[2]
							
							local stored_health_ratio = shown_stacks / max_stacks

							managers.hud:set_stored_health(stored_health_ratio)
						end
						
					end
				end
			end
		end

		if #self._damage_to_hot_stack > 0 then
			repeat
				local next_doh = self._damage_to_hot_stack[1]
				local done = not next_doh or TimerManager:game():time() < next_doh.next_tick

				if not done then
					local regen_rate = player_manager:upgrade_value("player", "damage_to_hot", 0)

					self:restore_health(regen_rate, true)

					next_doh.ticks_left = next_doh.ticks_left - 1

					if next_doh.ticks_left == 0 then
						table.remove(self._damage_to_hot_stack, 1)
					else
						next_doh.next_tick = next_doh.next_tick + (self._doh_data.tick_time or 1)
					end

					table.sort(self._damage_to_hot_stack, function (x, y)
						return x.next_tick < y.next_tick
					end)
				end
			until done
		end
	end

	function PlayerDamage:max_armor_stored_health()
		local player_manager = managers.player
		
		if not player_manager:has_category_upgrade("player", "expres_hot_election") then
			return 0
		end

		local regen_data = player_manager:upgrade_value("player", "expres_hot_election", {0, 0})
		local max_stacks = regen_data[2]

		return max_stacks
	end

	function PlayerDamage:update_armor_stored_health()
		if managers.hud then
			local player_manager = managers.player
			
			if not player_manager:has_category_upgrade("player", "expres_hot_election") then
				return
			end
			
			local max_health = self:_max_health()
			local regen_data = player_manager:upgrade_value("player", "expres_hot_election", {0, 0})
			local max_stacks = regen_data[2]
			
			managers.hud:set_stored_health_max(math.min(max_stacks / max_health, 1))

			if self._expres_election_stacks then
				local shown_stacks = self._expres_election_stacks
				
				shown_stacks = math.min(shown_stacks, max_stacks)
				local stored_health_ratio = shown_stacks / max_stacks

				managers.hud:set_stored_health(stored_health_ratio)
			end
		end
	end
	
	function PlayerDamage:consume_armor_stored_health()
		if self._expres_election_stacks > 0 then
			if not self._dead and not self._bleed_out and not self._check_berserker_done then
				local current_health_f = self.get_real_health
				local max_health = self._current_max_health
				local regen_data = managers.player:upgrade_value("player", "expres_hot_election", {0, 0})
				local stacks_to_consume = regen_data[1]
				local restore_health_f = self.restore_health
				
				repeat
					self._expres_election_stacks = self._expres_election_stacks - stacks_to_consume
					restore_health_f(self, stacks_to_consume, true)
				until current_health_f(self) >= max_health or self._expres_election_stacks <= 0
				
				self:update_armor_stored_health()
			end
		end
	end
	
	function PlayerDamage:_regenerate_armor(no_sound)
		if self._unit:sound() and not no_sound then
			self._unit:sound():play("shield_full_indicator")
		end

		self._regenerate_speed = nil
		
		if self._expres_can_insta_regen then
			self:consume_armor_stored_health()
			self._expres_can_insta_regen = nil
		end
		
		self:set_armor(self:_max_armor())
		self:_send_set_armor()
		
		self._expres_regenerate_speed = 1
		self._current_state = nil
	end
	
	function PlayerDamage:_update_regenerate_timer(t, dt)
		local regen_speed = self._regenerate_speed or 1
		regen_speed = regen_speed + self._expres_regenerate_speed - 1
		local dt_mul = regen_speed * math.lerp(1, 0.25, self:effective_suppression_ratio())
		self._regenerate_timer = math.max(self._regenerate_timer - dt * dt_mul, 0)

		if self._regenerate_timer <= 0 then
			self:_regenerate_armor()
		end
	end
	
	function PlayerDamage:band_aid_health()
		if managers.platform:presence() == "Playing" and (self:arrested() or self:need_revive()) then
			return
		end
		
		local to_restore = nil
		
		if managers.player:has_category_upgrade("player", "sociopath_mode") then
			to_restore = 2
		else
			to_restore = self:_max_health() * self._healing_reduction
		end
		
		self:change_health(to_restore)

		self._said_hurt = false

		if math.rand(1) < managers.player:upgrade_value("first_aid_kit", "downs_restore_chance", 0) then
			self._revives = Application:digest_value(math.min(self._lives_init + managers.player:upgrade_value("player", "additional_lives", 0), Application:digest_value(self._revives, false) + 1), true)
			self._revive_health_i = math.max(self._revive_health_i - 1, 1)

			managers.environment_controller:set_last_life(Application:digest_value(self._revives, false) <= 1)
		end
	end
	
	function PlayerDamage:_activate_preventative_care(upgrade_level)
		if upgrade_level < 1 then
			return
		end

		local pm = managers.player
		local ehp = nil
		local mul = nil
		local upgrade_data = pm:upgrade_value_by_level("first_aid_kit","damage_overshield",upgrade_level,{0,0})
		
		if managers.player:has_category_upgrade("player", "sociopath_mode") then
			ehp = 1
			mul = 1
		else
			ehp = self:_max_health() + self:_max_armor()
			mul = upgrade_data[1]
		end
		
		local amount = ehp * mul
		
		pm:set_damage_overshield("preventative_care_absorption",amount,
			{
				depleted_callback = function(damage_before_overshield,damage_blocked_by_overshield)
					local duration = upgrade_data[2]
					if duration > 0 then 
						pm:activate_temporary_property("preventative_care_invuln_active",duration,true)
					end
				end
			}
		)
	end

	function PlayerDamage:_check_bleed_out(can_activate_berserker, ignore_movement_state)
		if self:get_real_health() == 0 and not self._check_berserker_done then
			if self._unit:movement():zipline_unit() then
				self._bleed_out_blocked_by_zipline = true

				return
			end

			if not ignore_movement_state and self._unit:movement():current_state():bleed_out_blocked() then
				self._bleed_out_blocked_by_movement_state = true

				return
			end

			local time = Application:time()

	--note to self: _block_medkit_auto_revive is from swansong. check this when implementing crook's Borrowed Time, which itself is just swan song with a different hat on
	
	--NOTE: _uppers_elapsed now represents the time at which the cooldown will end, rather than the time at which the cooldown began
			if not self._block_medkit_auto_revive and time > self._uppers_elapsed then
				local auto_recovery_kit = FirstAidKitBase.GetFirstAidKit(self._unit:position())

				if auto_recovery_kit then
					local cooldown = auto_recovery_kit:get_auto_recovery_cooldown()
					if cooldown then 
						self._uppers_elapsed = time + cooldown
						
						auto_recovery_kit:take(self._unit)
						self._unit:sound():play("pickup_fak_skill")
						
						return
					end
				end
			end

			if can_activate_berserker and not self._check_berserker_done then
				local has_berserker_skill = managers.player:has_category_upgrade("temporary", "berserker_damage_multiplier")

				if has_berserker_skill and not self._disable_next_swansong then
					managers.hud:set_teammate_condition(HUDManager.PLAYER_PANEL, "mugshot_swansong", managers.localization:text("debug_mugshot_downed"))
					managers.player:activate_temporary_upgrade("temporary", "berserker_damage_multiplier")

					self._current_state = nil
					self._check_berserker_done = true

					if alive(self._interaction:active_unit()) and not self._interaction:active_unit():interaction():can_interact(self._unit) then
						self._unit:movement():interupt_interact()
					end

					self._listener_holder:call("on_enter_swansong")
				end

				self._disable_next_swansong = nil
			end

			self._hurt_value = 0.2
			self._damage_to_hot_stack = {}

			managers.environment_controller:set_downed_value(0)
			SoundDevice:set_rtpc("downed_state_progression", 0)

			if not self._check_berserker_done or not can_activate_berserker then
				if managers.player:get_property("armor_plates_free_revive",false) then 
					managers.player:remove_property("armor_plates_free_revive")
				else
					self._revives = Application:digest_value(Application:digest_value(self._revives, false) - 1, true)
					
					self:_send_set_revives()
				end
				
				self._check_berserker_done = nil

				managers.environment_controller:set_last_life(Application:digest_value(self._revives, false) <= 1)

				if Application:digest_value(self._revives, false) == 0 then
					self._down_time = 0
				end

				self._bleed_out = true
				self._current_state = nil

				managers.player:set_player_state("bleed_out")

				self._critical_state_heart_loop_instance = self._unit:sound():play("critical_state_heart_loop")
				self._slomo_sound_instance = self._unit:sound():play("downed_slomo_fx")
				self._bleed_out_health = Application:digest_value(tweak_data.player.damage.BLEED_OUT_HEALTH_INIT * managers.player:upgrade_value("player", "bleed_out_health_multiplier", 1), true)

				self:_drop_blood_sample()
				self:on_downed()
			end
		elseif not self._said_hurt and self:get_real_health() / self:_max_health() < 0.2 then
			self._said_hurt = true

			PlayerStandard.say_line(self, "g80x_plu")
		end
	end

	function PlayerDamage:set_revive_boost(revive_health_level)
		self._revive_health_multiplier = tweak_data.upgrades.revive_health_multiplier[revive_health_level]
		--actually the only change here is removing the debug print() 
		--but since i'm changing how the multiplier is applied i may as well override this too
		--even if this function specifically is not functionally different
				--offy
	end	
	
	function PlayerDamage:revive(silent)
		if Application:digest_value(self._revives, false) == 0 then
			self._revive_health_multiplier = nil

			return
		end

		local arrested = self:arrested()

		managers.player:set_player_state("standard")

		if not silent then
			PlayerStandard.say_line(self, "s05x_sin")
		end

		self._bleed_out = false
		self._incapacitated = nil
		self._downed_timer = nil
		self._downed_start_time = nil

		if not arrested then
			if not managers.player:has_category_upgrade("player", "sociopath_mode") then
				if self._revive_health_multiplier then 
					self:set_health(self:_max_health() * self._revive_health_multiplier)
					--if it is set, self._revive_health_multiplier now overrides other on-revive-health-regained bonuses and difficulty multipliers
					--and is a direct multiplier to max health
				else
					self:set_health(self:_max_health() * tweak_data.player.damage.REVIVE_HEALTH_STEPS[self._revive_health_i] * managers.player:upgrade_value("player", "revived_health_regain", 1))
				end
				
				self:set_armor(self:_max_armor())

				self._revive_health_i = math.min(#tweak_data.player.damage.REVIVE_HEALTH_STEPS, self._revive_health_i + 1)
				self._revive_miss = 2
			else
				self:set_armor(self:_max_armor())
				self:set_health(self:_max_health())
				self._can_take_dmg_timer = 2 + managers.player:upgrade_value("player", "sociopath_i_frames_add", 0)
			end
		end

		self:_regenerate_armor()
		managers.hud:set_player_health({
			current = self:get_real_health(),
			total = self:_max_health(),
			revives = Application:digest_value(self._revives, false)
		})
		self:_send_set_health()
		self:_set_health_effect()
		managers.hud:pd_stop_progress()

		self._revive_health_multiplier = nil

		self._listener_holder:call("on_revive")

		if managers.player:has_inactivate_temporary_upgrade("temporary", "revived_damage_resist") then
			managers.player:activate_temporary_upgrade("temporary", "revived_damage_resist")
		end

		if managers.player:has_inactivate_temporary_upgrade("temporary", "increased_movement_speed") then
			managers.player:activate_temporary_upgrade("temporary", "increased_movement_speed")
		end

		if managers.player:has_inactivate_temporary_upgrade("temporary", "swap_weapon_faster") then
			managers.player:activate_temporary_upgrade("temporary", "swap_weapon_faster")
		end

		if managers.player:has_inactivate_temporary_upgrade("temporary", "reload_weapon_faster") then
			managers.player:activate_temporary_upgrade("temporary", "reload_weapon_faster")
		end
		
		Hooks:Call("TCD_OnPlayerRevived")
	end

	local orig_chk_invuln = PlayerDamage._chk_can_take_dmg
	function PlayerDamage:_chk_can_take_dmg(...)
		return orig_chk_invuln(self,...) and not managers.player:has_active_temporary_property("preventative_care_invuln_active")
	end

	function PlayerDamage:damage_fall(data)
		local damage_info = {
			result = {
				variant = "fall",
				type = "hurt"
			}
		}

		if self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable then
			self:_call_listeners(damage_info)

			return
		elseif self:incapacitated() then
			return
		elseif self._unit:movement():current_state().immortal then
			return
		elseif self._mission_damage_blockers.damage_fall_disabled then
			return
		end

		local height_limit = 300
		local death_limit = 631
		
		local pm = managers.player
		
		if pm:has_category_upgrade("player", "burglar_fall_damage_resist") or pm:has_category_upgrade("player", "sociopath_mode") then
			if pm:has_category_upgrade("player", "burglar_fall_damage_resist") then
				death_limit = death_limit * 2
			end
			
			if data.height < death_limit then
				return
			end
		end

		if data.height < height_limit then
			return
		end

		local die = death_limit < data.height

		self._unit:sound():play("player_hit")
		managers.environment_controller:hit_feedback_down()
		managers.hud:on_hit_direction(Vector3(0, 0, 0), die and HUDHitDirection.DAMAGE_TYPES.HEALTH or HUDHitDirection.DAMAGE_TYPES.ARMOUR, 0)

		if self._bleed_out and self._unit:movement():current_state_name() ~= "jerry1" then
			return
		end

		local health_damage_multiplier = 0

		if die then
			self._check_berserker_done = false

			self:set_health(0)

			if self._unit:movement():current_state_name() == "jerry1" then
				self._revives = Application:digest_value(1, true)
			end
		elseif not pm:has_category_upgrade("player", "burglar_fall_damage_resist") then
			health_damage_multiplier = pm:upgrade_value("player", "fall_damage_multiplier", 1) * pm:upgrade_value("player", "fall_health_damage_multiplier", 1)

			self:change_health(-(tweak_data.player.fall_health_damage * health_damage_multiplier))
		end

		if die or health_damage_multiplier > 0 then
			local alert_rad = tweak_data.player.fall_damage_alert_size or 500
			local new_alert = {
				"vo_cbt",
				self._unit:movement():m_head_pos(),
				alert_rad,
				self._unit:movement():SO_access(),
				self._unit
			}

			managers.groupai:state():propagate_alert(new_alert)
		end

		local max_armor = self:_max_armor()

		if die then
			self:set_armor(0)
		else
			self:change_armor(-max_armor * pm:upgrade_value("player", "fall_damage_multiplier", 1))
		end

		SoundDevice:set_rtpc("shield_status", 0)
		self:_send_set_armor()

		self._bleed_out_blocked_by_movement_state = nil

		managers.hud:set_player_health({
			current = self:get_real_health(),
			total = self:_max_health(),
			revives = Application:digest_value(self._revives, false)
		})
		self:_send_set_health()
		self:_set_health_effect()
		self:_damage_screen()
		self:_check_bleed_out(nil, true)
		self:_call_listeners(damage_info)

		return true
	end

end
