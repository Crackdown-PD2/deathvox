function SentryGunDamage:init(unit)
	self._unit = unit
	self._parent_unit = nil
	self._ext_movement = unit:movement()

	unit:base():post_init()
	unit:brain():post_init()
	unit:movement():post_init()

	self._HEALTH_INIT = 10000
	self._SHIELD_HEALTH_INIT = 10000

	if self._shield_body_name then
		self._shield_body_name_ids = Idstring(self._shield_body_name)
	end

	if self._bag_body_name then
		self._bag_body_name_ids = Idstring(self._bag_body_name)
	end

	if self._invulnerable_body_names then
		self._invulnerable_bodies = {}
		local names_split = string.split(self._invulnerable_body_names, " ")

		for _, name_ids in ipairs(names_split) do
			self._invulnerable_bodies[name_ids:key()] = true
		end
	end

	self._health = self._HEALTH_INIT
	self._shield_health = self._SHIELD_HEALTH_INIT
	self._shield_smoke_level = 0
	self._shield_smoke_levels = {}

	table.insert(self._shield_smoke_levels, self._shield_smoke_level_1)
	table.insert(self._shield_smoke_levels, self._shield_smoke_level_2)
	table.insert(self._shield_smoke_levels, self._shield_smoke_level_3)

	self._num_shield_smoke_levels = table.getn(self._shield_smoke_levels)

	self._HEALTH_INIT_PERCENT = self._HEALTH_INIT / self._HEALTH_GRANULARITY
	self._SHIELD_HEALTH_INIT_PERCENT = self._SHIELD_HEALTH_INIT / self._HEALTH_GRANULARITY
	self._char_tweak = tweak_data.weapon[self._unit:base():get_name_id()]
	
	self._local_car_damage = 0
	self._repair_counter = 0
end

function SentryGunDamage:set_health(amount, shield_health_amount)
	self._health = amount
	self._HEALTH_INIT = amount
	self._HEALTH_INIT_PERCENT = self._HEALTH_INIT / self._HEALTH_GRANULARITY
	self._shield_health = shield_health_amount
	self._SHIELD_HEALTH_INIT = shield_health_amount
	self._SHIELD_HEALTH_INIT_PERCENT = self._SHIELD_HEALTH_INIT / self._HEALTH_GRANULARITY

	self._char_tweak = tweak_data.weapon[self._unit:base():get_name_id()]
end

function SentryGunDamage:sync_health(health_percent)
	local new_health = health_percent * self._HEALTH_INIT_PERCENT

	if new_health == 0 then
		self:die()
	else
		self._health = new_health
	end

	self._unit:event_listener():call("on_damage_received", self:health_ratio())
end

function SentryGunDamage:damage_bullet(attack_data)
	if self._dead or self._invulnerable or PlayerDamage.is_friendly_fire(self, attack_data.attacker_unit) then
		return "friendly_fire"
	end

	local hit_body = attack_data.col_ray.body
	local hit_body_name = hit_body:name()

	if self._invulnerable_bodies and hit_body and self._invulnerable_bodies[hit_body_name:key()] then
		return
	end

	local hit_shield, hit_bag = nil

	if hit_body then
		if hit_body_name == self._shield_body_name_ids then
			hit_shield = true
		elseif hit_body_name == self._bag_body_name_ids then
			hit_bag = true
		end
	end

	local damage = attack_data.damage

	if self._marked_dmg_dist_mul then
		local spott_dst = tweak_data.upgrades.values.player.marked_inc_dmg_distance[self._marked_dmg_dist_mul]

		if spott_dst then
			local dst = mvector3.distance(attack_data.origin, self._unit:position())

			if spott_dst[1] < dst then
				damage = damage * spott_dst[2]
			end
		end
	end

	local dmg_shield, damage_percent = nil

	if hit_shield and self._char_tweak.SHIELD_DMG_MUL then
		damage = damage * self._char_tweak.SHIELD_DMG_MUL
	end

	if hit_shield and self._shield_health > 0 then
		dmg_shield = true

		if self._char_tweak.SHIELD_DAMAGE_CLAMP then
			damage = math.min(damage, self._char_tweak.SHIELD_DAMAGE_CLAMP)
		end

		attack_data.raw_damage = damage

		damage = math.clamp(damage, 0, self._SHIELD_HEALTH_INIT)
		damage_percent = math.ceil(damage / self._SHIELD_HEALTH_INIT_PERCENT)
		damage = damage_percent * self._SHIELD_HEALTH_INIT_PERCENT
	else
		if hit_bag then
			if self._char_tweak.BAG_DMG_MUL then
				damage = damage * self._char_tweak.BAG_DMG_MUL
			end

			if self._bag_hit_snd_event then
				self._unit:sound_source():post_event(self._bag_hit_snd_event)
			end
		end

		if self._char_tweak.BODY_DAMAGE_CLAMP then
			damage = math.min(damage, self._char_tweak.BODY_DAMAGE_CLAMP)
		end

		attack_data.raw_damage = damage

		damage = math.clamp(damage, 0, self._HEALTH_INIT)
		damage_percent = math.ceil(damage / self._HEALTH_INIT_PERCENT)
		damage = damage_percent * self._HEALTH_INIT_PERCENT
	end

	local damage_post_apply = damage == 0 and 0 or self:_apply_damage(damage, dmg_shield, not dmg_shield, true, attack_data.attacker_unit, "bullet")
	attack_data.damage = damage_post_apply

	local result = {
		variant = "bullet",
		type = "dmg_rcv"
	}
	attack_data.result = result
	result.attack_data = attack_data

	if damage_post_apply == 0 then
		return result
	end

	if not self._ignore_client_damage and attack_data.attacker_unit == managers.player:player_unit() then
		managers.hud:on_hit_confirmed()
	end

	local attacker = attack_data.attacker_unit

	if not attacker or not alive(attacker) or attacker:id() == -1 then
		attacker = self._unit
	end

	local body_index = self._unit:get_body_index(hit_body_name)
	local i_result = 0

	if dmg_shield then
		if self._shield_health > 0 then
			i_result = 1
		else
			i_result = 2
		end
	elseif hit_bag then
		i_result = 3
	end

	self._unit:network():send("damage_bullet", attacker, damage_percent, body_index, 0, i_result, self._dead and true or false)

	if not self._dead then
		self._unit:brain():on_damage_received(attack_data.attacker_unit)
	end

	if not self._ignore_client_damage then
		local attacker_unit = attack_data and attack_data.attacker_unit

		if alive(attacker_unit) and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
		end

		if attacker_unit == managers.player:player_unit() and attack_data then
			managers.player:on_damage_dealt(self._unit, attack_data)
		end

		managers.player:send_message(Message.OnEnemyShot, nil, self._unit, attack_data)
	end

	return result
end

function SentryGunDamage:stun_hit(attack_data)
	return nil
end

function SentryGunDamage:damage_fire(attack_data)
	if self._dead or self._invulnerable or attack_data.variant == "stun" then
		return
	end

	local attacker_unit = attack_data.attacker_unit
	local weapon_unit = attack_data.weapon_unit

	if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
		weapon_unit = attack_data.attacker_unit
	end

	if attacker_unit and PlayerDamage.is_friendly_fire(self, attacker_unit) then
		return "friendly_fire"
	end

	local damage = attack_data.damage

	if self._marked_dmg_mul then
		damage = damage * self._marked_dmg_mul

		if self._marked_dmg_dist_mul and alive(attacker_unit) then
			local dst = mvector3.distance(attacker_unit:position(), self._unit:movement():m_head_pos())
			local spott_dst = tweak_data.upgrades.values.player.marked_inc_dmg_distance[self._marked_dmg_dist_mul]

			if spott_dst[1] < dst then
				damage = damage * spott_dst[2]
			end
		end
	end

	if self._char_tweak.FIRE_DMG_MUL then
		damage = damage * self._char_tweak.FIRE_DMG_MUL
	end

	local dmg_shield, damage_percent = nil

	if self._shield_health > 0 then
		dmg_shield = true

		if self._char_tweak.SHIELD_DMG_MUL then
			damage = damage * self._char_tweak.SHIELD_DMG_MUL
		end

		if self._char_tweak.SHIELD_DAMAGE_CLAMP then
			damage = math.min(damage, self._char_tweak.SHIELD_DAMAGE_CLAMP)
		end

		attack_data.raw_damage = damage

		damage = math.clamp(damage, 0, self._SHIELD_HEALTH_INIT)
		damage_percent = math.ceil(damage / self._SHIELD_HEALTH_INIT_PERCENT)
		damage = damage_percent * self._SHIELD_HEALTH_INIT_PERCENT
	else
		if self._char_tweak.BODY_DAMAGE_CLAMP then
			damage = math.min(damage, self._char_tweak.BODY_DAMAGE_CLAMP)
		end

		attack_data.raw_damage = damage

		damage = math.clamp(damage, 0, self._HEALTH_INIT)
		damage_percent = math.ceil(damage / self._HEALTH_INIT_PERCENT)
		damage = damage_percent * self._HEALTH_INIT_PERCENT
	end

	local damage_post_apply = damage == 0 and 0 or self:_apply_damage(damage, dmg_shield, not dmg_shield, true, attacker_unit, "fire")
	attack_data.damage = damage_post_apply

	local result = {
		variant = "fire",
		type = "dmg_rcv"
	}
	attack_data.result = result
	result.attack_data = attack_data

	if damage_post_apply == 0 then
		return result
	end

	if not self._ignore_client_damage and attacker_unit == managers.player:player_unit() then
		if weapon_unit then
			local is_ground_fire = weapon_unit:base() and weapon_unit:base().get_name_id and weapon_unit:base():get_name_id() == "environment_fire"

			if not is_ground_fire then
				managers.hud:on_hit_confirmed()
			end
		end
	end

	local attacker = attack_data.attacker_unit

	if not attacker or not alive(attacker) or attacker:id() == -1 then
		attacker = self._unit
	end
	
	local send_destroy_shield = false

	if dmg_shield then
	
		if self._shield_health > 0 then
			send_destroy_shield = true
		end
	end
	
	self._unit:network():send("damage_fire", attacker, damage_percent, self._dead and true or false, attack_data.col_ray.ray, 0, send_destroy_shield)

	if not self._dead then
		self._unit:brain():on_damage_received(attack_data.attacker_unit)
	end

	if not self._ignore_client_damage then
		local attacker_unit = attack_data and attack_data.attacker_unit

		if alive(attacker_unit) and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
		end

		if attacker_unit == managers.player:player_unit() and attack_data then
			managers.player:on_damage_dealt(self._unit, attack_data)
		end
	end

	return result
end

function SentryGunDamage:damage_explosion(attack_data)
	if self._dead or self._invulnerable or attack_data.variant == "stun" then
		return
	end

	local attacker_unit = attack_data.attacker_unit

	if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
	end

	if attacker_unit and PlayerDamage.is_friendly_fire(self, attacker_unit) then
		return "friendly_fire"
	end

	local damage = attack_data.damage

	if self._marked_dmg_mul then
		damage = damage * self._marked_dmg_mul

		if self._marked_dmg_dist_mul and alive(attacker_unit) then
			local dst = mvector3.distance(attacker_unit:position(), self._unit:movement():m_head_pos())
			local spott_dst = tweak_data.upgrades.values.player.marked_inc_dmg_distance[self._marked_dmg_dist_mul]

			if spott_dst[1] < dst then
				damage = damage * spott_dst[2]
			end
		end
	end

	if self._char_tweak.EXPLOSION_DMG_MUL then
		damage = damage * self._char_tweak.EXPLOSION_DMG_MUL
	end

	local dmg_shield, damage_percent = nil

	if self._shield_health > 0 then
		dmg_shield = true

		if self._char_tweak.SHIELD_DMG_MUL then
			damage = damage * self._char_tweak.SHIELD_DMG_MUL
		end

		if self._char_tweak.SHIELD_DAMAGE_CLAMP then
			damage = math.min(damage, self._char_tweak.SHIELD_DAMAGE_CLAMP)
		end

		attack_data.raw_damage = damage

		damage = math.clamp(damage, 0, self._SHIELD_HEALTH_INIT)
		damage_percent = math.ceil(damage / self._SHIELD_HEALTH_INIT_PERCENT)
		damage = damage_percent * self._SHIELD_HEALTH_INIT_PERCENT
	else
		if self._char_tweak.BODY_DAMAGE_CLAMP then
			damage = math.min(damage, self._char_tweak.BODY_DAMAGE_CLAMP)
		end

		attack_data.raw_damage = damage

		damage = math.clamp(damage, 0, self._HEALTH_INIT)
		damage_percent = math.ceil(damage / self._HEALTH_INIT_PERCENT)
		damage = damage_percent * self._HEALTH_INIT_PERCENT
	end

	local damage_post_apply = damage == 0 and 0 or self:_apply_damage(damage, dmg_shield, not dmg_shield, true, attacker_unit, "explosion")
	attack_data.damage = damage_post_apply

	local result = {
		variant = "explosion",
		type = "dmg_rcv"
	}
	attack_data.result = result
	result.attack_data = attack_data

	if damage_post_apply == 0 then
		return result
	end

	if not self._ignore_client_damage and attacker_unit == managers.player:player_unit() then
		managers.hud:on_hit_confirmed()
	end

	local attacker = attack_data.attacker_unit

	if not attacker or not alive(attacker) or attacker:id() == -1 then
		attacker = self._unit
	end

	local i_result = 1

	if dmg_shield then
		if self._shield_health > 0 then
			i_result = 2
		else
			i_result = 4 --using 3 will cause the function in unitnetworkhandler to use sync_damage_fire instead of sync_damage_explosion
		end
	end

	self._unit:network():send("damage_explosion_fire", attacker, damage_percent, i_result, self._dead and true or false, Vector3(), self._unit)

	if not self._dead then
		self._unit:brain():on_damage_received(attacker_unit)
	end

	if not self._ignore_client_damage then
		local attacker_unit = attack_data and attack_data.attacker_unit

		if alive(attacker_unit) and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
		end

		if attacker_unit == managers.player:player_unit() and attack_data then
			managers.player:on_damage_dealt(self._unit, attack_data)
		end
	end

	return result
end

function SentryGunDamage:die(attacker_unit, variant, options)
	options = options or {}
	local sequence_death = options.sequence_death or self._death_sequence_name
	local sequence_shield_death = options.sequence_shield_death or self._death_with_shield_sequence_name
	local sequence_done = options.sequence_done or "done_turret_destroyed"
	local global_event = options.global_event or "turret_destroyed"

	if self._stats_name and attacker_unit == managers.player:player_unit() then
		local data = {
			name = self._stats_name,
			stats_name = self._stats_name,
			variant = variant
		}

		managers.statistics:killed(data)
	end

	if self._is_car then
		local ja22_01_data = tweak_data.achievement.ja22_01
		local total_health = self._HEALTH_INIT + self._SHIELD_HEALTH_INIT * (1 + self._repair_counter)

		if ja22_01_data.percentage_dmg < self._local_car_damage / total_health then
--			print("JA22_01: Sentrygun Achievement Awarded!", "Damage: " .. math.truncate(self._local_car_damage, 1), "Percentage: " .. math.truncate(self._local_car_damage / total_health * 100, 1) .. "%")
			managers.achievment:award(ja22_01_data.award)
		else
--			print("JA22_01: Not enough damage", "Damage: " .. math.truncate(self._local_car_damage, 1), "Percentage: " .. math.truncate(self._local_car_damage / total_health * 100, 1) .. "%")
		end
	else
--		print("JA22_01: Sentrygun not a car")
	end

	self._health = 0
	self._dead = true

	self._unit:weapon():remove_fire_mode_interaction()
	self._unit:set_slot(26)
	self._unit:brain():set_active(false)
	self._unit:movement():set_active(false)
	self._unit:movement():on_death()
	
	if managers.groupai:state():criminal_record(self._unit:key()) then
		managers.groupai:state():on_criminal_neutralized(self._unit)
	end
	
	self._unit:base():on_death()

	if self._breakdown_snd_event then
		self._unit:sound_source():post_event(self._breakdown_snd_event)
	end

	self._shield_smoke_level = 0

	if self._enabled_sparks_on_shield and self._shield_sparks_disable and self._unit:damage():has_sequence(self._shield_sparks_disable) then
		self._unit:damage():run_sequence_simple(self._shield_sparks_disable)
		self._enabled_sparks_on_shield = nil
	end

	if sequence_shield_death and self._unit:base():has_shield() and self._unit:damage():has_sequence(sequence_shield_death) then
		self._unit:damage():run_sequence_simple(sequence_shield_death)
	elseif sequence_death and self._unit:damage():has_sequence(sequence_death) then
		self._unit:damage():run_sequence_simple(sequence_death)
	end

	if self._parent_unit ~= nil and self._parent_unit:damage():has_sequence(sequence_done) then
		self._parent_unit:damage():run_sequence_simple(sequence_done)
	end

	local turret_units = managers.groupai:state():turrets()

	if turret_units and table.contains(turret_units, self._unit) then
		if global_event then
			managers.mission:call_global_event("turret_destroyed")
		end

		self._unit:contour():remove("mark_unit_friendly", true)
		self._unit:contour():remove("mark_unit_dangerous", true)
		managers.groupai:state():unregister_turret(self._unit)
	end

	self._unit:event_listener():call("on_death")
end

function SentryGunDamage:sync_damage_bullet(attacker_unit, damage_percent, i_body, hit_offset_height, i_result, death)
	if self._dead then
		return
	end

	local dmg_shield, dmg_body, damage = nil

	if death then
		if i_result == 3 and self._bag_hit_snd_event then
			self._unit:sound_source():post_event(self._bag_hit_snd_event)
		end

		damage = "death"
		dmg_shield = true
		dmg_body = true
	else
		if i_result == 1 then
			damage = damage_percent * self._SHIELD_HEALTH_INIT_PERCENT
			dmg_shield = true
		elseif i_result == 2 then
			damage = "death"
			dmg_shield = true
		else
			if i_result == 3 and self._bag_hit_snd_event then
				self._unit:sound_source():post_event(self._bag_hit_snd_event)
			end

			damage = damage_percent * self._HEALTH_INIT_PERCENT
			dmg_body = true
		end
	end

	self:_apply_damage(damage, dmg_shield, dmg_body, false, attacker_unit, "bullet")

	if not self._dead then
		self._unit:brain():on_damage_received(attacker_unit)
	end
end

function SentryGunDamage:sync_damage_fire(attacker_unit, damage_percent, hit_shield, death, ignore, ignore_2, ignore_3, destroy_shield)
	if self._dead then
		return
	end

	local attacker = attacker_unit

	if attacker and attacker:base() and attacker:base().thrower_unit then
		attacker = attacker:base():thrower_unit()
	end

	local dmg_shield, dmg_body, damage = nil

	if death then
		damage = "death"
		dmg_shield = true
		dmg_body = true
	else
		if hit_shield then
			if destroy_shield then
				damage = "death"
			else
				damage = damage_percent * self._SHIELD_HEALTH_INIT_PERCENT
			end

			dmg_shield = true
		else
			damage = damage_percent * self._HEALTH_INIT_PERCENT
			dmg_body = true
		end
	end

	self:_apply_damage(damage, dmg_shield, dmg_body, false, attacker, "fire")

	if not self._dead then
		self._unit:brain():on_damage_received(attacker)
	end
end

function SentryGunDamage:sync_damage_explosion(attacker_unit, damage_percent, i_result, death)
	if self._dead then
		return
	end

	local attacker = attacker_unit

	if attacker and attacker:base() and attacker:base().thrower_unit then
		attacker = attacker:base():thrower_unit()
	end

	if not self._ignore_client_damage and attacker == managers.player:player_unit() and alive(attacker) then
		managers.hud:on_hit_confirmed()
	end

	local dmg_shield, dmg_body, damage = nil

	if death then
		damage = "death"
		dmg_shield = true
		dmg_body = true
	else
		if i_result == 4 then
			damage = "death"
			dmg_shield = true
		elseif i_result == 2 then
			damage = damage_percent * self._SHIELD_HEALTH_INIT_PERCENT
			dmg_shield = true
		else
			damage = damage_percent * self._HEALTH_INIT_PERCENT
			dmg_body = true
		end
	end

	self:_apply_damage(damage, dmg_shield, dmg_body, false, attacker, "explosion")

	if not self._dead then
		self._unit:brain():on_damage_received(attacker)
	end
end

function SentryGunDamage:_apply_damage(damage, dmg_shield, dmg_body, is_local, attacker_unit, variant)
	if dmg_shield and self._shield_health > 0 then
		local shield_dmg = damage == "death" and self._shield_health or damage

		if shield_dmg > 0 then
			if self._shield_health <= shield_dmg then
				if not dmg_body then
					damage = self._shield_health
				end

				self._shield_health = 0

				if self._shield_sparks_disable and self._enabled_sparks_on_shield and self._unit:damage():has_sequence(self._shield_sparks_disable) then
					self._unit:damage():run_sequence_simple(self._shield_sparks_disable)
					self._enabled_sparks_on_shield = nil
				end

				if self._shield_destroyed_sequence_name and self._unit:damage():has_sequence(self._shield_destroyed_sequence_name) then
					self._unit:damage():run_sequence_simple(self._shield_destroyed_sequence_name)
				end

				if self._shield_destroyed_snd_event then
					self._unit:sound_source():post_event(self._shield_destroyed_snd_event)
				end

				self:update_shield_smoke_level(self:shield_health_ratio())
			else
				self._shield_health = self._shield_health - shield_dmg

				if self._shield_sparks_enable and not self._enabled_sparks_on_shield and self:shield_health_ratio() < 0.25 and self._unit:damage():has_sequence(self._shield_sparks_enable) then
					self._unit:damage():run_sequence_simple(self._shield_sparks_enable)
					self._enabled_sparks_on_shield = true
				end

				self:update_shield_smoke_level(self:shield_health_ratio())
			end

			if not dmg_body then
				return damage
			end
		end
	end

	if dmg_body then
		local body_damage = damage == "death" and self._health or damage

		if body_damage == 0 then
			return 0
		end

		local previous_health_ratio = self:health_ratio()

		if self._health <= body_damage then
			damage = self._health

			self:die(attacker_unit, variant)
		else
			self._health = self._health - body_damage
		end

		self._unit:event_listener():call("on_damage_received", self:health_ratio())

		if not self._char_tweak.AUTO_REPAIR and not self._dead and self._damaged_sequence_name then
			if previous_health_ratio >= 0.75 and self:health_ratio() < 0.75 and self._unit:damage():has_sequence(self._damaged_sequence_name) then
				self._unit:damage():run_sequence_simple(self._damaged_sequence_name)
			end
		end

		return damage
	end

	return 0
end

function SentryGunDamage:save(save_data)
	local my_save_data = {}
	save_data.char_damage = my_save_data
	my_save_data.ignore_client_damage = self._ignore_client_damage
	my_save_data.health = self._health
	my_save_data.shield_health = self._shield_health
	my_save_data.HEALTH_INIT = self._HEALTH_INIT
	my_save_data.SHIELD_HEALTH_INIT = self._SHIELD_HEALTH_INIT
	my_save_data.shield_smoke_level = self._shield_smoke_level
	my_save_data.char_tweak = tweak_data.weapon[self._unit:base():get_name_id()]
end

function SentryGunDamage:load(save_data)
	if not save_data or not save_data.char_damage then
		return
	end

	local my_save_data = save_data.char_damage
	self._ignore_client_damage = my_save_data.ignore_client_damage
	self._health = my_save_data.health
	self._shield_health = my_save_data.shield_health
	self._shield_smoke_level = my_save_data.shield_smoke_level
	self._HEALTH_INIT = my_save_data.HEALTH_INIT
	self._SHIELD_HEALTH_INIT = my_save_data.SHIELD_HEALTH_INIT
	self._HEALTH_INIT_PERCENT = self._HEALTH_INIT / self._HEALTH_GRANULARITY
	self._SHIELD_HEALTH_INIT_PERCENT = self._SHIELD_HEALTH_INIT / self._HEALTH_GRANULARITY
	self._char_tweak = my_save_data.char_tweak

	if self._health == 0 then
		self:die()
	end

	if self._shield_smoke_level > 0 then
		self:_make_shield_smoke()
	end
end

function SentryGunDamage:melee_hit_sfx()
	return "hit_gen"
end
