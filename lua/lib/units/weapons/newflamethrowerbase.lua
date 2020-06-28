local draw_debug_spheres = false
local mvec3_set = mvector3.set
local mvec3_mul = mvector3.multiply
local mvec3_add = mvector3.add
local mvec3_cpy = mvector3.copy
local mvec_to = Vector3()
local mvec_to2 = Vector3()
local math_min = math.min
local dozer_faceplate = Idstring("body_helmet_plate")
local dozer_visor = Idstring("body_helmet_glass")
local world_g = World

function NewFlamethrowerBase:setup_default()
	self._rays = tweak_data.weapon[self._name_id].rays or 6
	self._range = tweak_data.weapon[self._name_id].flame_max_range or 1000
	self._flame_max_range = tweak_data.weapon[self._name_id].flame_max_range
	self._single_flame_effect_duration = tweak_data.weapon[self._name_id].single_flame_effect_duration
	self._bullet_class = FlameBulletBase
	self._bullet_slotmask = self._bullet_class:bullet_slotmask()

	if managers.mutators:is_mutator_active(MutatorFriendlyFire) then --add friendly fire against player husks only for players (prevents NPCs from hitting player husks and dealing unintended non-local damage)
		self._bullet_slotmask = self._bullet_slotmask + world_g:make_slot_mask(3)
	end

	self._blank_slotmask = self._bullet_class:blank_slotmask()
	self._col_slotmask = managers.slot:get_mask("bullet_impact_targets_no_criminals")
	self._col_slotmask = self._col_slotmask - 8
end

function NewFlamethrowerBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
	local damage_range = self._flame_max_range

	mvec3_set(mvec_to, direction)
	mvec3_mul(mvec_to, damage_range)
	mvec3_add(mvec_to, from_pos)

	--use a smaller sphere ray to limit the range of the actual damaging sphere ray
	local col_sphere_ray = world_g:raycast("ray", from_pos, mvec_to, "sphere_cast_radius", 20, "disable_inner_ray", "slot_mask", self._col_slotmask, "ignore_unit", self._setup.ignore_units)

	if col_sphere_ray then --limit the range of the damage sphere if something was hit by the initial sphere ray
		damage_range = math_min(damage_range, col_sphere_ray.distance)
	end

	mvec3_set(mvec_to2, direction)
	mvec3_mul(mvec_to2, damage_range)
	mvec3_add(mvec_to2, from_pos)

	local sphere_hits = world_g:raycast_all("ray", from_pos, mvec_to2, "sphere_cast_radius", 35, "disable_inner_ray", "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
	local units_hit, unique_hits = {}, {}

	for _, hit in ipairs(sphere_hits) do
		hit.hit_position = hit.position

		if not units_hit[hit.unit:key()] then --not already hit
			units_hit[hit.unit:key()] = true

			if not hit.unit:character_damage() then
				hit.is_object = true
			end

			unique_hits[#unique_hits + 1] = hit
		elseif not hit.unit:character_damage() then
			local previous_hit = unique_hits[#unique_hits]

			if not previous_hit.body:extension() or not previous_hit.body:extension().damage then
				if hit.body:extension() and hit.body:extension().damage then
					hit.is_object = true
					unique_hits[#unique_hits] = hit
				end
			end
		else
			local previous_hit = unique_hits[#unique_hits]

			if hit.unit:character_damage().is_head then --has is_head function
				local prioritize_body_with_damage_extension = nil

				if previous_hit.body:name() == dozer_faceplate or previous_hit.body:name() == dozer_visor or previous_hit.body:extension() and previous_hit.body:extension().damage then --prioritize bodies with damage extensions over others
					prioritize_body_with_damage_extension = true
				elseif hit.body:extension() and hit.body:extension().damage then
					unique_hits[#unique_hits] = hit

					prioritize_body_with_damage_extension = true
				end

				if not prioritize_body_with_damage_extension and hit.unit:character_damage():is_head(hit.body) then --prioritize the head (you never know, it changes nothing since flamethrowers aren't supposed to no headshot damage)
					unique_hits[#unique_hits] = hit
				end
			else
				--[[local turret_shield = hit.unit:character_damage()._shield_body_name_ids
				local turret_weak_spot = hit.unit:character_damage()._bag_body_name_ids

				if turret_shield and hit.body:name() == turret_shield or turret_weak_spot and hit.body:name() == turret_weak_spot then --prioritize the shield or weak spot of a turret over other parts of its body
					unique_hits[#unique_hits] = hit
				end]]

				local invulnerable_bodies = hit.unit:character_damage()._invulnerable_bodies

				if invulnerable_bodies and invulnerable_bodies[previous_hit.body:key()] and not invulnerable_bodies[hit.body:key()] then --replace hits that deal no damage with ones that do (with my other changes, Turrets take shield damage and 
					unique_hits[#unique_hits] = hit
				end
			end
		end
	end

	local damage = self:_get_current_damage(dmg_mul)
	local hit_enemies = 0

	for _, col_ray in ipairs(unique_hits) do
		self._bullet_class:on_collision(col_ray, self._unit, user_unit, damage)

		if col_ray.is_object then
			col_ray.is_object = nil

			if draw_debug_spheres then
				local draw_duration = 1
				local new_brush = Draw:brush(Color.white:with_alpha(0.5), draw_duration)
				new_brush:sphere(col_ray.position, 5)
			end
		else
			hit_enemies = hit_enemies + 1

			if draw_debug_spheres then
				local draw_duration = 1
				local new_brush = Draw:brush(Color.red:with_alpha(0.5), draw_duration)
				new_brush:sphere(col_ray.position, 5)
			end
		end
	end

	--rework suppression in general, once again
	if self._suppression then --using a bigger cone here due to the flamethrower's short range and wider area of effect
		local max_suppression_range = self._flame_max_range * 1.5

		self:_suppress_units(mvec3_cpy(from_pos), mvec3_cpy(direction), max_suppression_range, managers.slot:get_mask("enemies"), user_unit, suppr_mul)
	end

	if alive(self._obj_fire) then
		self._unit:flamethrower_effect_extension():_spawn_muzzle_effect(from_pos, direction, true, col_sphere_ray)
	end

	local result = {}
	result.hit_enemy = hit_enemies > 0 and true or false

	if self._alert_events then
		result.rays = {{position = from_pos}} --flamethrowers normally cause alerts only from where they're fired, keeping it that way since it makes sense
	end

	managers.statistics:shot_fired({
		hit = false,
		weapon_unit = self._unit
	})

	for i = 1, hit_enemies do
		managers.statistics:shot_fired({
			skip_bullet_count = true,
			hit = true,
			weapon_unit = self._unit
		})
	end

	return result
end
