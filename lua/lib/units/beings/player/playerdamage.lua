function PlayerDamage:damage_bullet(attack_data)
	if not self:_chk_can_take_dmg() then
		self:play_whizby(attack_data.col_ray.position)
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
	elseif not attack_data.ignore_suppression and not self:is_suppressed() then
		self:play_whizby(attack_data.col_ray.position)

		return
	elseif self:_chk_dmg_too_soon(attack_data.damage) then
		return
	end

	if deathvox and deathvox:IsTotalCrackdownEnabled() then
		local pm = managers.player
		if not self._rogue_dodge_sniper_bullet_cooldown then
			self._rogue_dodge_sniper_bullet_cooldown = managers.player:player_timer():time()
		end
		local attacker = attack_data.attacker_unit
		if attacker:base().has_tag then
			local is_sniper = attacker:base():has_tag("sniper")
			if is_sniper and self._rogue_dodge_sniper_bullet_cooldown <= managers.player:player_timer():time() then
				if managers.player:upgrade_value("player", "rogue_t4") == true then
					self:play_whizby(attack_data.col_ray.position)
					self._rogue_dodge_sniper_bullet_cooldown = managers.player:player_timer():time() + 10
					return
				end
			end
		end
	end
				

	self:_hit_direction(attack_data.attacker_unit:position())

	local pm = managers.player
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

	return true
end

function PlayerDamage:clbk_kill_taunt(attack_data)
	local attacker = attack_data.attacker_unit

	if attacker and alive(attacker) and attacker:character_damage() and attacker:character_damage().dead and not attacker:character_damage():dead() then
		attacker:sound():say("post_kill_taunt")
	end

	self._kill_taunt_clbk_id = nil
end

function PlayerDamage:clbk_kill_taunt_tase(attack_data)
	local attacker = attack_data.attacker_unit

	if attacker and alive(attacker) and attacker:character_damage() and attacker:character_damage().dead and not attacker:character_damage():dead() then
		attacker:sound():say("post_tasing_taunt")
	end

	self._kill_taunt_clbk_id = nil
end	

function PlayerDamage:clbk_kill_taunt_common(attack_data)
	local attacker = attack_data.attacker_unit

	if attacker and alive(attacker) and attacker:character_damage() and attacker:character_damage().dead and not attacker:character_damage():dead() then
		attacker:sound():say("i03")
	end

	self._kill_taunt_clbk_id = nil
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
	local armor_at_start = self:get_real_armor()
	if not deathvox:IsHoppipOverhaulEnabled() then
		return _calc_armor_damage_original(self, attack_data, ...)
   	end
	
	attack_data.damage = attack_data.damage - (self._old_last_received_dmg or 0)
	self._next_allowed_dmg_t = self._old_next_allowed_dmg_t and Application:digest_value(self._old_next_allowed_dmg_t, true) or self._next_allowed_dmg_t
	self._old_last_received_dmg = nil
	self._old_next_allowed_dmg_t = nil
	local damage_calc_shit = _calc_armor_damage_original(self, attack_data, ...)
	if deathvox and deathvox:IsTotalCrackdownEnabled() then
		if self._armor_damage_null_cooldown == nil then
			self._armor_damage_null_cooldown = TimerManager:game():time()
		end
		if self:get_real_armor() <= 0 and armor_at_start > 0 then
			log("Invincibility triggered!")
			if self._armor_damage_null_cooldown > TimerManager:game():time() then
				log("Still on cooldown.")
			else
				if managers.player:upgrade_value("player", "armorer_t6") == true then
					self._can_take_dmg_timer = 2
					self._armor_damage_null_cooldown = TimerManager:game():time() + 10
				end
			end
		end
	end
	return damage_calc_shit
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

function PlayerDamage:damage_melee(attack_data)
	if not self:_chk_can_take_dmg() then
		return
	end

	local pm = managers.player
	local can_counter_strike = pm:has_category_upgrade("player", "counter_strike_melee")

	if can_counter_strike and self._unit:movement():current_state().in_melee and self._unit:movement():current_state():in_melee() then
		if attack_data.attacker_unit and alive(attack_data.attacker_unit) and attack_data.attacker_unit:base() then
			local is_dozer = attack_data.attacker_unit:base().has_tag and attack_data.attacker_unit:base():has_tag("tank")

			--prevent the player from countering Dozers or other players through FF, for obvious reasons
			if not attack_data.attacker_unit:base().is_husk_player and not is_dozer then
				self._unit:movement():current_state():discharge_melee()

				return "countered"
			end
		end
	end
	
	if deathvox and deathvox:IsTotalCrackdownEnabled() then
		local pm = managers.player
		if not self._rogue_dodge_melee_cooldown then
			self._rogue_dodge_melee_cooldown = managers.player:player_timer():time()
		end
		local attacker = attack_data.attacker_unit
		if self._rogue_dodge_melee_cooldown <= managers.player:player_timer():time() then
			if managers.player:upgrade_value("player", "rogue_t2") == true then
				self:play_whizby(attack_data.col_ray.position)
				self._rogue_dodge_melee_cooldown = managers.player:player_timer():time() + 10
				return
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

	local allow_melee_dodge = false --manual toggle, to be later replaced with a Rogue melee dodge perk check

	if allow_melee_dodge and pm:current_state() ~= "bleed_out" and pm:current_state() ~= "bipod" and pm:current_state() ~= "tased" then --self._bleed_out and current_state() ~= "bleed_out" aren't the same thing
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
			--do a push to simulate the dodge + small camera shake + show an indicator (no hit sounds or a blood effect)
			self._unit:movement():push(attack_data.push_vel)
			self._unit:camera():play_shaker("melee_hit", 0.2)
			pm:send_message(Message.OnPlayerDodge)

			return
		end
	end

	local dmg_mul = pm:damage_reduction_skill_multiplier("melee") --the vanilla function has this line, but it also uses bullet damage reduction skills due to it redirecting to damage_bullet to get results
	attack_data.damage = attack_data.damage * dmg_mul
	attack_data.damage = pm:modify_value("damage_taken", attack_data.damage, attack_data) --apply damage resistances before checking for bleedout and other things

	local damage_absorption = pm:damage_absorption()

	if damage_absorption > 0 then
		attack_data.damage = math.max(0, attack_data.damage - damage_absorption)
	end

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

				--some sounds are too low to hear, playing them twice helps and or accentuates a hit even more)
				self._unit:sound():play(post_event, nil, false)
				self._unit:sound():play(post_event, nil, false)
			end
		end
	end
end

function PlayerDamage:damage_fire(attack_data)
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

	local dmg_mul = pm:damage_reduction_skill_multiplier("fire")
	attack_data.damage = attack_data.damage * dmg_mul
	attack_data.damage = pm:modify_value("damage_taken", attack_data.damage, attack_data)

	local damage_absorption = pm:damage_absorption()

	if damage_absorption > 0 then
		attack_data.damage = math.max(0, attack_data.damage - damage_absorption)
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

function PlayerDamage:_upd_health_regen(t, dt)
	if self._health_regen_update_timer then
		self._health_regen_update_timer = self._health_regen_update_timer - dt

		if self._health_regen_update_timer <= 0 then
			self._health_regen_update_timer = nil
		end
	end

	if not self._health_regen_update_timer then
		local max_health = self:_max_health()

		if self:get_real_health() < max_health then
			self:restore_health(managers.player:health_regen(), false)
			self:restore_health(managers.player:fixed_health_regen(self:health_ratio()), true)

			self._health_regen_update_timer = 5
		end
	end
	if deathvox and deathvox:IsTotalCrackdownEnabled() then
		local pm = managers.player
		if self._crew_chief_regen_timer then
			self._crew_chief_regen_timer = self._crew_chief_regen_timer - dt

			if self._crew_chief_regen_timer <= 0 then
				self._crew_chief_regen_timer = nil
			end
		end

		if not self._crew_chief_regen_timer then
			local max_health = self:_max_health()
			local missing_health = max_health - self:get_real_health()
			if self:get_real_health() < max_health then
				if pm:has_team_category_upgrade("player", "crew_chief_t5") == true then
					self:restore_health(missing_health * 0.01, true)
				end
				if pm:upgrade_value("player", "muscle_t8") == true then
					self:restore_health(max_health * 0.02, true)
				elseif pm:upgrade_value("player", "muscle_t6") == true then
					self:restore_health(max_health * 0.015, true)
				elseif pm:upgrade_value("player", "muscle_t4") == true then
					self:restore_health(max_health * 0.01, true)
				elseif pm:upgrade_value("player", "muscle_t2") == true then
					self:restore_health(max_health * 0.005, true)
				end
				self._crew_chief_regen_timer = 1
			end
		end
	end

	if #self._damage_to_hot_stack > 0 then
		repeat
			local next_doh = self._damage_to_hot_stack[1]
			local done = not next_doh or TimerManager:game():time() < next_doh.next_tick

			if not done then
				local regen_rate = managers.player:upgrade_value("player", "damage_to_hot", 0)

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

function PlayerDamage:damage_tase(attack_data)
	if self._god_mode then
		return
	end

	if deathvox and deathvox:IsTotalCrackdownEnabled() then
		local pm = managers.player
		if not self._rogue_dodge_tase_cooldown then
			self._rogue_dodge_tase_cooldown = managers.player:player_timer():time()
		end
		local attacker = attack_data.attacker_unit
		if self._rogue_dodge_tase_cooldown <= managers.player:player_timer():time() then
			if managers.player:upgrade_value("player", "rogue_t6") == true then
				self._rogue_dodge_tase_cooldown = managers.player:player_timer():time() + 10
				return
			end
		end
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
	
	if managers.player:upgrade_value("player", "burglar_t4") == true then
		death_limit = death_limit * 2
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
	else

		health_damage_multiplier = managers.player:upgrade_value("player", "fall_damage_multiplier", 1) * managers.player:upgrade_value("player", "fall_health_damage_multiplier", 1)
		if managers.player:upgrade_value("player", "burglar_t4") == true then
			health_damage_multiplier = 0 -- no fall damage unless it would kill you
		end
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
		self:change_armor(-max_armor * managers.player:upgrade_value("player", "fall_damage_multiplier", 1))
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