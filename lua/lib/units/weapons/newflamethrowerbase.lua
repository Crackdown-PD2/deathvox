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

local mvec_to = Vector3()
local mvec_direction = Vector3()
local mvec_spread_direction = Vector3()

function NewFlamethrowerBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
	local result = {}
	local fake_rays = {}
	local hit_enemies = {}
	local damage = self:_get_current_damage(dmg_mul)
	local damage_range = self._flame_max_range
	local spread_x, spread_y = self:_get_spread(user_unit)

	--proper spread
	local right = direction:cross(Vector3(0, 0, 1)):normalized()
	local up = direction:cross(right):normalized()

	mvector3.set(mvec_direction, direction)

	for i = 1, self._rays, 1 do --repeat according to the amount of rays (usually 12, so 12 cones)
		local theta = math.random() * 360
		local ax = math.sin(theta) * math.random() * spread_x * (spread_mul or 1)
		local ay = math.cos(theta) * math.random() * spread_y * (spread_mul or 1)

		--different spread for each cone
		mvector3.set(mvec_spread_direction, mvec_direction)
		mvector3.add(mvec_spread_direction, right * math.rad(ax))
		mvector3.add(mvec_spread_direction, up * math.rad(ay))
		mvector3.set(mvec_to, mvec_spread_direction)
		mvector3.multiply(mvec_to, damage_range)
		mvector3.add(mvec_to, from_pos)

		--change self._bullet_slotmask to managers.slot:get_mask("world_geometry", "vehicles") if you'd prefer the flamethrower to go through anything that isn't map geometry/vehicles
		local col_ray = World:raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)

		if col_ray then --limit cone range if something was hit at the center of the cone
			damage_range = math.min(damage_range, col_ray.distance)
		end

		local cone_spread = math.rad(spread_x) * damage_range

		mvector3.set(mvec_to, mvec_spread_direction)
		mvector3.multiply(mvec_to, damage_range)
		mvector3.add(mvec_to, from_pos)

		local hit_bodies = World:find_bodies(user_unit, "intersect", "cone", from_pos, mvec_to, cone_spread, self._bullet_slotmask)
		local bodies_hit = {}

		for idx, body in ipairs(hit_bodies) do --assign fake col_rays to anything that gets hit by the cones
			local fake_ray = {
				body = body,
				unit = body:unit(),
				ray = mvector3.copy(mvec_to),
				normal = mvector3.copy(mvec_to),
				position = mvector3.copy(from_pos)
			}

			table.insert(bodies_hit, fake_ray)
		end

		for _, fake_ray in ipairs(bodies_hit) do
			if fake_ray then
				table.insert(fake_rays, fake_ray) --if something was hit
			else
				local ray_to = mvector3.copy(mvec_to)
				local spread_direction = mvector3.copy(mvec_spread_direction)

				table.insert(fake_rays, {
					position = ray_to,
					ray = spread_direction
				}) --go to where the fake ray would've hit anyway
			end
		end
	end

	for _, fake_ray in pairs(fake_rays) do
		if fake_ray and fake_ray.unit then
			if fake_ray.unit:character_damage() then
				if not hit_enemies[fake_ray.unit:key()] then --not already hit
					hit_enemies[fake_ray.unit:key()] = fake_ray
				else
					if fake_ray.unit:character_damage().is_head then --has is_head function
						if fake_ray.unit:character_damage():is_head(fake_ray.body) then --prioritize the head (you never know if it's going to be useful, it changes nothing for now so it does no harm)
							hit_enemies[fake_ray.unit:key()] = fake_ray
						elseif fake_ray.body:name() == Idstring("body_helmet_plate") or fake_ray.body:name() == Idstring("body_helmet_glass") then --prioritize dozer faceplates and visors over other body parts
							hit_enemies[fake_ray.unit:key()] = fake_ray
						end
					else
						local turret_shield = fake_ray.unit:character_damage()._shield_body_name_ids
						local turret_weak_spot = fake_ray.unit:character_damage()._bag_body_name_ids

						if turret_shield and (fake_ray.body:name() == turret_shield) or turret_weak_spot and (fake_ray.body:name() == turret_weak_spot) then --prioritize the shield or weak spot of a turret over other parts of its body
							hit_enemies[fake_ray.unit:key()] = fake_ray
						end
					end
				end
			else
				local final_damage = damage / self._rays

				--split damage among the fake rays to avoid having multiple max damage hits per fired shot (this is for non-characters)
				self._bullet_class:on_collision(fake_ray, self._unit, user_unit, final_damage)
			end
		end
	end

	for _, fake_ray in pairs(hit_enemies) do --clean way to deal damage to each enemy hit per fired shot
		self._bullet_class:on_collision(fake_ray, self._unit, user_unit, damage)
	end

	if self._suppression then --proper suppression, using a wider cylinder here due to the flamethrower's short range and wider area of effect
		local tmp_vec_to = Vector3()

		mvector3.set(tmp_vec_to, mvector3.copy(direction))
		mvector3.multiply(tmp_vec_to, self._flame_max_range)
		mvector3.add(tmp_vec_to, mvector3.copy(from_pos))

		self:_suppress_units(mvector3.copy(from_pos), tmp_vec_to, 200, managers.slot:get_mask("enemies"), user_unit, suppr_mul, self._flame_max_range)
	end

	result.hit_enemy = next(hit_enemies) and true or false

	if self._alert_events and #fake_rays > 0 then
		result.rays = {
			{
				position = from_pos --flamethrowers normally cause alerts only from where they're fired, keeping it that way since it makes sense
			}
		}
	end

	managers.statistics:shot_fired({
		hit = false,
		weapon_unit = self._unit
	})

	for _, d in pairs(hit_enemies) do --enemies hit per fired shot pull increase accuracy accordingly (negating the one above)
		managers.statistics:shot_fired({
			skip_bullet_count = true,
			hit = true,
			weapon_unit = self._unit
		})
	end

	return result
end
