local init_original = NPCRaycastWeaponBase.init
local setup_original = NPCRaycastWeaponBase.setup

function NPCRaycastWeaponBase:init(...)
	init_original(self, ...)
	self._bullet_slotmask = self._bullet_slotmask - World:make_slot_mask(22)

	local weapon_tweak = tweak_data.weapon[self._name_id]

	local trail = Idstring("effects/particles/weapons/weapon_trail")

	if weapon_tweak and weapon_tweak.sniper_trail then
		trail = Idstring("effects/particles/weapons/trail_dv_sniper")
	end

	self._trail_effect_table = {
		effect = trail,
		position = Vector3(),
		normal = Vector3()
	}

	--switch sound and muzzle flash for suppressed weapons
	if tweak_data.weapon[self._name_id].has_suppressor then
		self._sound_fire:set_switch("suppressed", tweak_data.weapon[self._name_id].has_suppressor)
		self._muzzle_effect = Idstring(self:weapon_tweak_data().muzzleflash_silenced or "effects/payday2/particles/weapons/9mm_auto_silence")
	else
		self._muzzle_effect = Idstring(self:weapon_tweak_data().muzzleflash or "effects/particles/test/muzzleflash_maingun")
	end

	--enable proper armor piercing (for things other than players getting hit)
	if self:weapon_tweak_data().armor_piercing then
		self._use_armor_piercing = true
	end
end

function NPCRaycastWeaponBase:setup(setup_data, ...)
	setup_original(self, setup_data, ...)
	self._bullet_slotmask = self._bullet_slotmask - World:make_slot_mask(22)
	self._enemy_slotmask = managers.slot:get_mask("criminals")
	local user_unit = setup_data.user_unit
	if user_unit then
		if user_unit:in_slot(16) then
			self._bullet_slotmask = self._bullet_slotmask - World:make_slot_mask(16, 22)
			self._enemy_slotmask = managers.slot:get_mask("enemies")
		end
	end		
end

function NPCRaycastWeaponBase:_get_spread(user_unit)
	local weapon_tweak = tweak_data.weapon[self._name_id]
	
	if not weapon_tweak then
		return 3
	end
	
	if weapon_tweak.spread then
		return weapon_tweak.spread
	else
		return 1
	end
end

local mvec_to = Vector3()
local mvec_spread = Vector3()

function NPCRaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	local char_hit = nil
	local result = {}
	local ray_distance = self._weapon_range or 20000
	local miss, extra_spread = self:_check_smoke_shot(user_unit, target_unit)

	if miss then
		result.guaranteed_miss = miss

		mvector3.spread(direction, math.rand(unpack(extra_spread)))
	else
		local true_spread = self:_get_spread(user_unit)

		if true_spread > 1 then
			mvector3.spread(direction, true_spread)
		end
	end

	mvector3.set(mvec_to, direction)
	mvector3.multiply(mvec_to, ray_distance)
	mvector3.add(mvec_to, from_pos)

	local damage = self._damage * (dmg_mul or 1)

	local ray_hits = nil
	local hit_enemy = false
	local went_through_wall = false
	local enemy_mask = self._enemy_slotmask
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
			if self._hit_player and not hit_player and shoot_player then
				local player_hit_ray = deep_clone(hit)
				local player_hit = self:damage_player(player_hit_ray, from_pos, direction, result)

				if player_hit then
					hit_player = true
					char_hit = true

					local damaged_player = InstantBulletBase:on_hit_player(player_hit_ray, self._unit, user_unit, damage)

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

			local hit_char = InstantBulletBase:on_collision(hit, self._unit, user_unit, damage)

			if hit_char then
				char_hit = true

				if hit_char.type and hit_char.type == "death" then
					if self:is_category("shotgun") then
						managers.game_play_central:do_shotgun_push(hit.unit, hit.position, hit.ray, hit.distance, user_unit)
					end

					if user_unit:unit_data().mission_element then
						user_unit:unit_data().mission_element:event("killshot", user_unit)
					end
				end
			end
		end
	else
		if self._hit_player and shoot_player then
			local player_hit, player_ray_data = self:damage_player(nil, from_pos, direction, result)

			if player_hit then
				local damaged_player = InstantBulletBase:on_hit_player(player_ray_data, self._unit, user_unit, damage)

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
		if furthest_hit and furthest_hit.distance > 600 or not furthest_hit or result.guaranteed_miss then
			local num_rays = (tweak_data.weapon[self._name_id] or {}).rays or 1
			local trail_direction = furthest_hit and furthest_hit.ray or direction

			for i = 1, num_rays, 1 do
				mvector3.set(mvec_spread, trail_direction)

				if i > 1 then
					mvector3.spread(mvec_spread, self:_get_spread(user_unit))
				end

				self:_spawn_trail_effect(mvec_spread, furthest_hit)
			end
		end
	end

	if self._suppression then
		local suppression_slot_mask = user_unit:in_slot(16) and managers.slot:get_mask("enemies") or managers.slot:get_mask("players", "criminals")

		self:_suppress_units(mvector3.copy(from_pos), mvector3.copy(direction), ray_distance, suppression_slot_mask, user_unit, suppr_mul)
	end

	if self._alert_events then
		result.rays = unique_hits
	end

	self:_cleanup_smoke_shot()

	return result
end
