function SentryGunWeapon:init(unit)
	self._unit = unit
	self._current_damage_mul = 1
	self._timer = TimerManager:game()
	self._character_slotmask = managers.slot:get_mask("raycastable_characters")
	self._next_fire_allowed = -1000
	self._obj_fire = self._unit:get_object(Idstring("a_detect"))
	self._shoot_through_data = {from = Vector3()}
	self._effect_align = {
		self._unit:get_object(Idstring(self._muzzle_flash_parent or "fire")),
		self._unit:get_object(Idstring(self._muzzle_flash_parent or "fire"))
	}
	self._muzzle_flash_parent = nil

	if self._laser_align_name then
		self._laser_align = self._unit:get_object(Idstring(self._laser_align_name))
	end

	self._interleaving_fire = 1
	self._trail_effect_table = {
		effect = RaycastWeaponBase.TRAIL_EFFECT,
		position = Vector3(),
		normal = Vector3()
	}
	self._ammo_sync_resolution = 0.0625

	if Network:is_server() then
		self._ammo_total = 1
		self._ammo_max = self._ammo_total
		self._ammo_sync = 16
	else
		self._ammo_ratio = 1
	end

	self._spread_mul = 1
	self._use_armor_piercing = false
	self._slow_fire_rate = false
	self._fire_rate_reduction = 1
	self._name_id = self._unit:base():get_name_id()
	local my_tweak_data = tweak_data.weapon[self._name_id]
	self._default_alert_size = my_tweak_data.alert_size
	self._from = Vector3()
	self._to = Vector3()
end

function SentryGunWeapon:switch_fire_mode()
	self:_set_fire_mode(not self._use_armor_piercing)

	if self._use_armor_piercing then
		managers.hint:show_hint("sentry_set_ap_rounds")
		self._unit:base()._use_armor_piercing = true
	else
		managers.hint:show_hint("sentry_normal_ammo")
		self._unit:base()._use_armor_piercing = nil
	end

	self._unit:network():send("sentrygun_sync_armor_piercing", self._use_armor_piercing)
	self._unit:sound_source():post_event("wp_sentrygun_swap_ammo")
	self._unit:event_listener():call("on_switch_fire_mode", self._use_armor_piercing)
end

local mvec_to = Vector3()

function SentryGunWeapon:_fire_raycast(from_pos, direction, shoot_player, target_unit)
	if not self._setup.ignore_units then
		return
	end

	local hit_unit = nil
	local result = {}
	local ray_distance = tweak_data.weapon[self._name_id].FIRE_RANGE or 20000

	mvector3.set(mvec_to, direction)
	mvector3.multiply(mvec_to, ray_distance)
	mvector3.add(mvec_to, from_pos)

	self._from = from_pos
	self._to = mvec_to

	local ray_hits = nil
	local hit_enemy = false
	local went_through_wall = false
	local enemy_mask = self._unit:in_slot(25) and managers.slot:get_mask("enemies") or managers.slot:get_mask("criminals")
	local wall_mask = managers.slot:get_mask("world_geometry", "vehicles")
	local shield_mask = managers.slot:get_mask("enemy_shield_check")
	local ai_vision_ids = Idstring("ai_vision")
	local bulletproof_ids = Idstring("bulletproof")

	if self._use_armor_piercing then
		ray_hits = World:raycast_wall("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "thickness", 40, "thickness_mask", wall_mask) --try to change so that no infinite penetration happens
	else
		ray_hits = World:raycast_all("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
	end

	local units_hit = {}
	local unique_hits = {}

	for i, hit in ipairs(ray_hits) do
		if not units_hit[hit.unit:key()] then
			units_hit[hit.unit:key()] = true
			unique_hits[#unique_hits + 1] = hit
			hit.hit_position = hit.position
			hit_enemy = hit_enemy or hit.unit:in_slot(enemy_mask)
			local weak_body = hit.body:has_ray_type(ai_vision_ids)
			weak_body = weak_body or hit.body:has_ray_type(bulletproof_ids)

			if not self._use_armor_piercing then
				if hit_enemy or hit.unit:in_slot(wall_mask) and weak_body or hit.unit:in_slot(shield_mask) then
					break
				end
			else
				if hit.unit:in_slot(wall_mask) and weak_body then
					if went_through_wall then
						break
					else
						went_through_wall = true
					end
				end
			end
		end
	end

	local furthest_hit = unique_hits[#unique_hits]

	if #unique_hits > 0 then
		local hit_player = false

		for _, hit in ipairs(unique_hits) do
			if not hit_player and shoot_player then
				local player_hit_ray = deep_clone(hit)
				local player_hit, player_ray_data  = RaycastWeaponBase.damage_player(self, player_hit_ray, from_pos, direction, result)

				if player_hit then
					hit_player = true
					char_hit = true

					local damage = self:_apply_dmg_mul(self._damage, player_ray_data, from_pos)
					local damaged_player = InstantBulletBase:on_hit_player(player_hit_ray, self._unit, self._unit, damage)

					if damaged_player then
						if not self._use_armor_piercing then
							hit.unit = managers.player:player_unit()
							hit.body = hit.unit:body("inflict_reciever")
							hit.position = mvector3.copy(hit.body:position())
							hit.hit_position = hit.position
							hit.distance = mvector3.direction(hit.ray, mvector3.copy(from_pos), mvector3.copy(hit.position))
							hit.normal = -hit.ray
							furthest_hit = hit

							break
						end
					end	
				end
			end

			local damage = self:_apply_dmg_mul(self._damage, hit, from_pos)

			if InstantBulletBase:on_collision(hit, self._unit, self._unit, damage) then
				char_hit = true
			end
		end
	else
		if shoot_player then
			local player_hit, player_ray_data = RaycastWeaponBase.damage_player(self, nil, from_pos, direction, result)

			if player_hit then
				local damage = self:_apply_dmg_mul(self._damage, player_ray_data, from_pos)
				local damaged_player = InstantBulletBase:on_hit_player(player_ray_data, self._unit, self._unit, damage)

				if damaged_player then
					char_hit = true

					if not self._use_armor_piercing then
						player_ray_data.unit = managers.player:player_unit()
						player_ray_data.body = player_ray_data.unit:body("inflict_reciever")
						player_ray_data.position = mvector3.copy(player_ray_data.body:position())
						player_ray_data.hit_position = player_ray_data.position
						player_ray_data.distance = mvector3.direction(player_ray_data.ray, mvector3.copy(from_pos), mvector3.copy(player_ray_data.position))
						player_ray_data.normal = -player_ray_data.ray
						furthest_hit = player_ray_data
					end
				end	
			end
		end
	end

	result.hit_enemy = char_hit

	if alive(self._obj_fire) then
		if furthest_hit and furthest_hit.distance > 600 or not furthest_hit then
			local trail_direction = furthest_hit and furthest_hit.ray or direction

			self:_spawn_trail_effect(trail_direction, furthest_hit)
		end
	end

	if self._suppression then
		local suppression_slot_mask = self._unit:in_slot(25) and managers.slot:get_mask("enemies") or managers.slot:get_mask("players", "criminals")

		RaycastWeaponBase._suppress_units(self, mvector3.copy(from_pos), mvector3.copy(direction), ray_distance, suppression_slot_mask, self._unit, nil)
	end

	if self._alert_events then
		result.rays = unique_hits
	end

	return result
end
