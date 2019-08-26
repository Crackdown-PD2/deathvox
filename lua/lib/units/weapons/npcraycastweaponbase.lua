	local mvec_to = Vector3()
	local mvec_spread = Vector3()

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
		local user_unit = setup_data.user_unit
		if user_unit then
			if user_unit:in_slot(16) then
				self._bullet_slotmask = self._bullet_slotmask - World:make_slot_mask(16, 22)
			end
		end		
	end
	
	function NPCRaycastWeaponBase:_spawn_trail_effect(direction, col_ray)
		self._obj_fire:m_position(self._trail_effect_table.position)
		mvector3.set(self._trail_effect_table.normal, direction)

		local trail = World:effect_manager():spawn(self._trail_effect_table)

		if col_ray then
			World:effect_manager():set_remaining_lifetime(trail, math.clamp((col_ray.distance - 600) / 10000, 0, col_ray.distance))
		end
	end

	function NPCRaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit, shoot_through_data)
		local result = {}
		local hit_unit = nil
		local miss, extra_spread = self:_check_smoke_shot(user_unit, target_unit)
		local ray_distance = shoot_through_data and shoot_through_data.ray_distance or 20000

		if miss then
			result.guaranteed_miss = miss

			mvector3.spread(direction, math.rand(unpack(extra_spread)))
		end

		mvector3.set(mvec_to, direction)
		mvector3.multiply(mvec_to, ray_distance)
		mvector3.add(mvec_to, from_pos)

		local damage = self._damage * (dmg_mul or 1)
		local ray_from_unit = shoot_through_data and alive(shoot_through_data.ray_from_unit) and shoot_through_data.ray_from_unit or nil
		local col_ray = (ray_from_unit or World):raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)

		local player_hit, player_ray_data = nil

		if shoot_player and self._hit_player then
			player_hit, player_ray_data = self:damage_player(col_ray, from_pos, direction, result)

			if player_hit then
				InstantBulletBase:on_hit_player(col_ray or player_ray_data, self._unit, user_unit, damage)
			end
		end

		local char_hit = nil

		if not player_hit and col_ray then
			char_hit = InstantBulletBase:on_collision(col_ray, self._unit, user_unit, damage)
		end

		if (not col_ray or col_ray.unit ~= target_unit) and target_unit and target_unit:character_damage() and target_unit:character_damage().build_suppression then
			target_unit:character_damage():build_suppression(tweak_data.weapon[self._name_id].suppression)
		end

		if not col_ray or col_ray.distance > 600 or result.guaranteed_miss then
			local num_rays = (tweak_data.weapon[self._name_id] or {}).rays or 1

			for i = 1, num_rays, 1 do
				mvector3.set(mvec_spread, direction)

				if i > 1 then
					mvector3.spread(mvec_spread, self:_get_spread(user_unit))
				end

				self:_spawn_trail_effect(mvec_spread, col_ray)
			end
		end

		if col_ray and col_ray.unit then
			repeat
				if char_hit and not self._use_armor_piercing then
					break
				end

				if col_ray.distance < 0.1 or ray_distance - col_ray.distance < 50 then
					break
				end

				local has_hit_wall = shoot_through_data and shoot_through_data.has_hit_wall
				local has_passed_shield = shoot_through_data and shoot_through_data.has_passed_shield
				local is_shoot_through, is_shield, is_wall = nil

				if not char_hit then
					local is_world_geometry = col_ray.unit:in_slot(managers.slot:get_mask("world_geometry", "vehicles"))

					if is_world_geometry then
						is_shoot_through = not col_ray.body:has_ray_type(Idstring("ai_vision"))

						if not is_shoot_through then
							if has_hit_wall or not self._use_armor_piercing then
								break
							end

							is_wall = true
						end
					else
						if not self._use_armor_piercing then
							break
						end

						is_shield = col_ray.unit:in_slot(8) and alive(col_ray.unit:parent())
					end
				end

				if not char_hit and not is_shoot_through and not is_shield and not is_wall then
					break
				end

				local ray_from_unit = (char_hit or is_shield) and col_ray.unit
				self._shoot_through_data.has_hit_wall = has_hit_wall or is_wall
				self._shoot_through_data.has_passed_shield = has_passed_shield or is_shield
				self._shoot_through_data.ray_from_unit = ray_from_unit
				self._shoot_through_data.ray_distance = ray_distance - col_ray.distance

				mvector3.set(self._shoot_through_data.from, direction)
				mvector3.multiply(self._shoot_through_data.from, is_shield and 5 or 40)
				mvector3.add(self._shoot_through_data.from, col_ray.position)
				managers.game_play_central:queue_fire_raycast(Application:time() + 0.0125, self._unit, user_unit, self._shoot_through_data.from, mvector3.copy(direction), dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit, self._shoot_through_data)
			until true
		end

		result.hit_enemy = char_hit

		if self._alert_events then
			result.rays = {col_ray}
		end

		self:_cleanup_smoke_shot()

		return result
	end
