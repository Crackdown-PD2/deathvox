function NewFlamethrowerBase:setup_default()
	self._rays = tweak_data.weapon[self._name_id].rays or 6
	self._range = tweak_data.weapon[self._name_id].flame_max_range or 1000
	self._flame_max_range = tweak_data.weapon[self._name_id].flame_max_range
	self._single_flame_effect_duration = tweak_data.weapon[self._name_id].single_flame_effect_duration
	self._bullet_class = FlameBulletBase
	self._bullet_slotmask = self._bullet_class:bullet_slotmask()
	self._blank_slotmask = self._bullet_class:blank_slotmask()

	if managers.mutators:is_mutator_active(MutatorFriendlyFire) then --add friendly fire against player husks only for players (prevents NPCs from hitting player husks and dealing unintended non-local damage)
		self._bullet_slotmask = self._bullet_slotmask + World:make_slot_mask(3)
	end
end

function NewFlamethrowerBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
	local result = {}
	local hit_enemies = {}
	local hit_objects = {}

	local draw_debug_spheres = false
	local damage = self:_get_current_damage(dmg_mul)
	local damage_range = self._flame_max_range

	local mvec_to = Vector3()
	mvector3.set(mvec_to, mvector3.copy(direction))
	mvector3.multiply(mvec_to, damage_range)
	mvector3.add(mvec_to, mvector3.copy(from_pos))

	--change self._bullet_slotmask to managers.slot:get_mask("world_geometry", "vehicles") if you'd prefer the flamethrower to go through anything that isn't map geometry/vehicles
	local col_sphere_ray = World:raycast("ray", mvector3.copy(from_pos), mvec_to, "sphere_cast_radius", 20, "disable_inner_ray", "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)

	if col_sphere_ray then --limit the range of the damage sphere if something was hit by the initial sphere ray
		damage_range = math.min(damage_range, col_sphere_ray.distance)
	end

	local mvec_to2 = Vector3()
	mvector3.set(mvec_to2, mvector3.copy(direction))
	mvector3.multiply(mvec_to2, damage_range)
	mvector3.add(mvec_to2, mvector3.copy(from_pos))

	local sphere_hits = World:raycast_all("ray", mvector3.copy(from_pos), mvec_to2, "sphere_cast_radius", 35, "disable_inner_ray", "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
	local units_hit = {}
	local unique_hits = {}

	for i, hit in ipairs(sphere_hits) do
		if not units_hit[hit.unit:key()] then
			units_hit[hit.unit:key()] = true
			unique_hits[#unique_hits + 1] = hit
			hit.hit_position = hit.position
		end
	end

	for _, hit in ipairs(unique_hits) do
		if hit and hit.unit then
			if hit.unit:character_damage() then
				if not hit_enemies[hit.unit:key()] then --not already hit
					hit_enemies[hit.unit:key()] = hit
				else
					if hit.unit:character_damage().is_head then --has is_head function
						if hit.unit:character_damage():is_head(hit.body) then --prioritize the head (you never know if it's going to be useful, it changes nothing for now so it does no harm)
							hit_enemies[hit.unit:key()] = hit
						elseif hit.body:name() == Idstring("body_helmet_plate") or hit.body:name() == Idstring("body_helmet_glass") then --prioritize dozer faceplates and visors over other body parts
							hit_enemies[hit.unit:key()] = hit
						end
					else
						local turret_shield = hit.unit:character_damage()._shield_body_name_ids
						local turret_weak_spot = hit.unit:character_damage()._bag_body_name_ids

						if turret_shield and (hit.body:name() == turret_shield) or turret_weak_spot and (hit.body:name() == turret_weak_spot) then --prioritize the shield or weak spot of a turret over other parts of its body
							hit_enemies[hit.unit:key()] = hit
						end
					end
				end
			else
				if not hit_objects[hit.unit:key()] then --not already hit
					hit_objects[hit.unit:key()] = hit
					self._bullet_class:on_collision(hit, self._unit, user_unit, damage)

					if draw_debug_spheres then
						local draw_duration = 1
						local new_brush = Draw:brush(Color.white:with_alpha(0.5), draw_duration) --create a new brush with the color of the shape; alpha affects its opacity as usual
						new_brush:sphere(hit.position, 5)
					end
				end
			end
		end
	end

	for _, col_ray in pairs(hit_enemies) do --clean way to deal damage to each enemy hit per fired shot
		self._bullet_class:on_collision(col_ray, self._unit, user_unit, damage)

		if draw_debug_spheres then
			local draw_duration = 1
			local new_brush = Draw:brush(Color.red:with_alpha(0.5), draw_duration) --create a new brush with the color of the shape; alpha affects its opacity as usual
			new_brush:sphere(col_ray.position, 5)
		end
	end

	if self._suppression then --using a bigger cone here due to the flamethrower's short range and wider area of effect
		local max_suppression_range = self._flame_max_range * 1.5

		self:_suppress_units(mvector3.copy(from_pos), mvector3.copy(direction), max_suppression_range, managers.slot:get_mask("enemies"), user_unit, suppr_mul)
	end

	result.hit_enemy = #hit_enemies > 0 and true or false

	if self._alert_events then
		result.rays = {
			{
				position = mvector3.copy(from_pos) --flamethrowers normally cause alerts only from where they're fired, keeping it that way since it makes sense
			}
		}
	end

	managers.statistics:shot_fired({
		hit = false,
		weapon_unit = self._unit
	})

	for i = 1, #hit_enemies, 1 do --enemies hit per fired shot pull increase accuracy accordingly (negating the one above)
		managers.statistics:shot_fired({
			skip_bullet_count = true,
			hit = true,
			weapon_unit = self._unit
		})
	end

	return result
end
