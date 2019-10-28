local orig_dmg_bullet = PlayerDamage.damage_bullet
function PlayerDamage:damage_bullet(attack_data,...)
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
	local pm = managers.player
	local dmg_mul = pm:damage_reduction_skill_multiplier("bullet")
	attack_data.damage = attack_data.damage * dmg_mul
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

	if self._god_mode then
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
	elseif self:is_friendly_fire(attack_data.attacker_unit) then
		return
	elseif self:_chk_dmg_too_soon(attack_data.damage) then
		return
	elseif self._unit:movement():current_state().immortal then
		return
	elseif self._revive_miss and math.random() < self._revive_miss then
		self:play_whizby(attack_data.col_ray.position)

		return
	end

	self._last_received_dmg = attack_data.damage
	self._next_allowed_dmg_t = Application:digest_value(pm:player_timer():time() + self._dmg_interval, true)
	local dodge_roll = math.random()
	local dodge_value = tweak_data.player.damage.DODGE_INIT or 0
	local armor_dodge_chance = pm:body_armor_value("dodge")
	local skill_dodge_chance = pm:skill_dodge_chance(self._unit:movement():running(), self._unit:movement():crouching(), self._unit:movement():zipline_unit())
	dodge_value = dodge_value + armor_dodge_chance + skill_dodge_chance

	if self._temporary_dodge_t and TimerManager:game():time() < self._temporary_dodge_t then
		dodge_value = dodge_value + self._temporary_dodge
	end

	local smoke_dodge = 0

	for _, smoke_screen in ipairs(managers.player._smoke_screen_effects or {}) do
		if smoke_screen:is_in_smoke(self._unit) then
			smoke_dodge = tweak_data.projectiles.smoke_screen_grenade.dodge_chance

			break
		end
	end

	dodge_value = 1 - (1 - dodge_value) * (1 - smoke_dodge)

	if dodge_roll < dodge_value then
		if attack_data.damage > 0 then
			self:_send_damage_drama(attack_data, 0)
		end

		self:_call_listeners(damage_info)
		self:play_whizby(attack_data.col_ray.position)
		self:_hit_direction(attack_data.attacker_unit:position())

		self._next_allowed_dmg_t = Application:digest_value(pm:player_timer():time() + self._dmg_interval, true)
		self._last_received_dmg = attack_data.damage

		managers.player:send_message(Message.OnPlayerDodge)

		return
	end

	if attack_data.attacker_unit:base()._tweak_table == "tank" then
		managers.achievment:set_script_data("dodge_this_fail", true)
	end

	if self:get_real_armor() > 0 then
		self._unit:sound():play("player_hit")
	else
		self._unit:sound():play("player_hit_permadamage")
	end

	local shake_armor_multiplier = pm:body_armor_value("damage_shake") * pm:upgrade_value("player", "damage_shake_multiplier", 1)
	local gui_shake_number = tweak_data.gui.armor_damage_shake_base / shake_armor_multiplier
	gui_shake_number = gui_shake_number + pm:upgrade_value("player", "damage_shake_addend", 0)
	shake_armor_multiplier = tweak_data.gui.armor_damage_shake_base / gui_shake_number
	local shake_multiplier = math.clamp(attack_data.damage, 0.2, 2) * shake_armor_multiplier

	self._unit:camera():play_shaker("player_bullet_damage", 1 * shake_multiplier)

	if not _G.IS_VR then
		managers.rumble:play("damage_bullet")
	end

	self:_hit_direction(attack_data.attacker_unit:position())
	pm:check_damage_carry(attack_data)

	attack_data.damage = managers.player:modify_value("damage_taken", attack_data.damage, attack_data)

	if self._bleed_out then
		self:_bleed_out_damage(attack_data)

		return
	end

	if not attack_data.ignore_suppression and not self:is_suppressed() then
		return
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

	if not self._bleed_out and health_subtracted > 0 then
		self:_send_damage_drama(attack_data, health_subtracted)
	elseif self._bleed_out and attack_data.attacker_unit and attack_data.attacker_unit:alive() and attack_data.attacker_unit:base()._tweak_table == "tank" then
		self._kill_taunt_clbk_id = "kill_taunt" .. tostring(self._unit:key())
		managers.enemy:add_delayed_clbk(self._kill_taunt_clbk_id, callback(self, self, "clbk_kill_taunt", attack_data), TimerManager:game():time() + tweak_data.timespeed.downed.fade_in + tweak_data.timespeed.downed.sustain + tweak_data.timespeed.downed.fade_out)
	elseif self._bleed_out and attack_data.attacker_unit and attack_data.attacker_unit:alive() and attack_data.attacker_unit:base()._tweak_table == "taser" then
		self._kill_taunt_clbk_id = "kill_taunt" .. tostring(self._unit:key())
		managers.enemy:add_delayed_clbk(self._kill_taunt_clbk_id, callback(self, self, "clbk_kill_taunt_tase", attack_data), TimerManager:game():time() + 0.1 + 0.1 + 0.1)	
	elseif self._bleed_out and attack_data.attacker_unit and attack_data.attacker_unit:alive() then
		self._kill_taunt_clbk_id = "kill_taunt" .. tostring(self._unit:key())
		managers.enemy:add_delayed_clbk(self._kill_taunt_clbk_id, callback(self, self, "clbk_kill_taunt_common", attack_data), TimerManager:game():time() + 0.1 + 0.1 + 0.1)
	end

	pm:send_message(Message.OnPlayerDamage, nil, attack_data)
	self:_call_listeners(damage_info)
end
	
function PlayerDamage:clbk_kill_taunt_tase(attack_data)
	if attack_data.attacker_unit and attack_data.attacker_unit:alive() then
		self._kill_taunt_clbk_id = nil

		attack_data.attacker_unit:sound():say("post_tasing_taunt")
	end
end		

function PlayerDamage:clbk_kill_taunt_common(attack_data)
	if attack_data.attacker_unit and attack_data.attacker_unit:alive() then
		if not attack_data.attacker_unit:base()._tweak_table then
			return
		end	
			self._kill_taunt_clbk_id = nil

		attack_data.attacker_unit:sound():say("i03")
	end
end	

local _chk_dmg_too_soon_orig = PlayerDamage._chk_dmg_too_soon
function PlayerDamage:_chk_dmg_too_soon(damage, ...)
	if not deathvox:IsHoppipOverhaulEnabled() then
		return _chk_dmg_too_soon_orig(self, damage, ...)
   	end
	
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

local _calc_armor_damage_original = PlayerDamage._calc_armor_damage
function PlayerDamage:_calc_armor_damage(attack_data, ...)

	if not deathvox:IsHoppipOverhaulEnabled() then
		return _calc_armor_damage_original(self, attack_data, ...)
    end
	
	attack_data.damage = attack_data.damage - (self._old_last_received_dmg or 0)
	self._next_allowed_dmg_t = self._old_next_allowed_dmg_t and Application:digest_value(self._old_next_allowed_dmg_t, true) or self._next_allowed_dmg_t
	self._old_last_received_dmg = nil
	self._old_next_allowed_dmg_t = nil
	return _calc_armor_damage_original(self, attack_data, ...)
end

local _calc_health_damage_original = PlayerDamage._calc_health_damage
function PlayerDamage:_calc_health_damage(attack_data, ...)

	if not deathvox:IsHoppipOverhaulEnabled() then
		return _calc_health_damage_original(self, attack_data, ...)
    end
	
	attack_data.damage = attack_data.damage - (self._old_last_received_dmg or 0)
	self._next_allowed_dmg_t = self._old_next_allowed_dmg_t and Application:digest_value(self._old_next_allowed_dmg_t, true) or self._next_allowed_dmg_t
	self._old_last_received_dmg = nil
	self._old_next_allowed_dmg_t = nil
	return _calc_health_damage_original(self, attack_data, ...)
end

--would edit the whole function and do it properly + fix it while at it, but it hates me and I can't avoid 0 damage results or game crashes if I don't do it this way
local damage_melee_original = PlayerDamage.damage_melee
function PlayerDamage:damage_melee(attack_data)
	local player_unit = managers.player:player_unit()

	if alive(player_unit) and attack_data and attack_data.tase_player then
		if player_unit:movement():current_state_name() == "standard" or player_unit:movement():current_state_name() == "carry" or player_unit:movement():current_state_name() == "bipod" then
			if player_unit:movement():current_state_name() == "bipod" then
				player_unit:movement()._current_state:exit(nil, "tased")
			end

			player_unit:movement():on_non_lethal_electrocution()
			managers.player:set_player_state("tased")
		end
	end

	damage_melee_original(self, attack_data)
end

function PlayerDamage:damage_fire(attack_data)
	if not self:_chk_can_take_dmg() then
		return
	end

	local damage_info = {result = {
		variant = "fire",
		type = "hurt"
	}}
	
	local pm = managers.player
	local damage = attack_data.damage or 1
	local dmg_mul = pm:damage_reduction_skill_multiplier("fire")
	attack_data.damage = damage * dmg_mul

	local damage_absorption = pm:damage_absorption()

	if damage_absorption > 0 then
		attack_data.damage = math.max(0, attack_data.damage - damage_absorption)
	end

	if self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self._unit:movement():current_state().immortal then
		return
	elseif self:incapacitated() then
		return
	elseif self:is_friendly_fire(attack_data.attacker_unit) then
		return
	elseif self:_chk_dmg_too_soon(attack_data.damage) then
		return
	end

	self._last_received_dmg = attack_data.damage + attack_data.damage
	self._next_allowed_dmg_t = Application:digest_value(pm:player_timer():time() + self._dmg_interval, true)

	if self:get_real_armor() > 0 then
		self._unit:sound():play("player_hit")
	else
		self._unit:sound():play("player_hit_permadamage")
	end

	if attack_data.attacker_unit then
		self:_hit_direction(attack_data.attacker_unit:position())
	end

	attack_data.damage = managers.player:modify_value("damage_taken", attack_data.damage, attack_data)

	if self._bleed_out then
		self:_bleed_out_damage(attack_data)

		return
	end

	self:_check_chico_heal(attack_data)

	local armor_subtracted = self:_calc_armor_damage(attack_data)
	attack_data.damage = attack_data.damage - (armor_subtracted or 0)
	local health_subtracted = self:_calc_health_damage(attack_data)

	self:_call_listeners(damage_info)
end
