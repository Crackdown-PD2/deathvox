local draw_debug_spheres = false
local mvec3_set = mvector3.set
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_lerp = mvector3.lerp
local mvec3_dir = mvector3.direction
local mvec3_cpy = mvector3.copy
local mvec_to = Vector3()
local mvec_to2 = Vector3()
local math_min = math.min
local dozer_faceplate = Idstring("body_helmet_plate")
local dozer_visor = Idstring("body_helmet_glass")
local world_g = World

function NewFlamethrowerBase:setup_default()
	self:kill_effects()

	local unit = self._unit
	local nozzle_obj = unit:get_object(Idstring("fire"))
	self._nozzle_obj = nozzle_obj
	local name_id = self._name_id
	local weap_tweak = tweak_data.weapon[name_id]
	local flame_effect_range = weap_tweak.flame_max_range
	self._range = flame_effect_range
	self._flame_max_range = flame_effect_range
	self._flame_radius = weap_tweak.flame_radius or 40
	local flame_effect = weap_tweak.flame_effect

	if flame_effect then
		self._last_effect_t = -100
		self._flame_effect_collection = {}
		self._flame_effect_ids = Idstring(flame_effect)
		self._flame_max_range_sq = flame_effect_range * flame_effect_range
		local effect_duration = weap_tweak.single_flame_effect_duration
		self._single_flame_effect_duration = effect_duration
		self._single_flame_effect_cooldown = effect_duration * 0.1
	else
		self._last_effect_t = nil
		self._flame_effect_collection = nil
		self._flame_effect_ids = nil
		self._flame_max_range_sq = nil
		self._single_flame_effect_duration = nil
		self._single_flame_effect_cooldown = nil

		print("[NewFlamethrowerBase:setup_default] No flame effect defined for tweak data ID ", name_id)
	end

	local effect_manager = self._effect_manager
	local pilot_effect = weap_tweak.pilot_effect

	if pilot_effect then
		local parent_obj = nil
		local parent_name = weap_tweak.pilot_parent_name

		if parent_name then
			parent_obj = unit:get_object(Idstring(parent_name))

			if not parent_obj then
				print("[NewFlamethrowerBase:setup_default] No pilot parent object found with name ", parent_name, "in unit ", unit)
			end
		end

		parent_obj = parent_obj or nozzle_obj
		local force_synch = self.is_npc and not self:is_npc()
		local pilot_offset = weap_tweak.pilot_offset or nil
		local normal = weap_tweak.pilot_normal or Vector3(0, 0, 1)
		local pilot_effect_id = effect_manager:spawn({
			effect = Idstring(pilot_effect),
			parent = parent_obj,
			force_synch = force_synch,
			position = pilot_offset,
			normal = normal
		})
		self._pilot_effect = pilot_effect_id
		local state = (not self._enabled or not self._visible) and true or false

		effect_manager:set_hidden(pilot_effect_id, state)
		effect_manager:set_frozen(pilot_effect_id, state)
	else
		self._pilot_effect = nil
	end

	local nozzle_effect = weap_tweak.nozzle_effect

	if nozzle_effect then
		self._last_fire_t = -100
		self._nozzle_expire_t = weap_tweak.nozzle_expire_time or 0.2
		local force_synch = self.is_npc and not self:is_npc()
		local normal = weap_tweak.nozzle_normal or Vector3(0, 1, 0)
		local nozzle_effect_id = effect_manager:spawn({
			effect = Idstring(nozzle_effect),
			parent = nozzle_obj,
			force_synch = force_synch,
			normal = normal
		})
		self._nozzle_effect = nozzle_effect_id

		effect_manager:set_hidden(nozzle_effect_id, true)
		effect_manager:set_frozen(nozzle_effect_id, true)

		self._showing_nozzle_effect = false
	else
		self._last_fire_t = nil
		self._nozzle_expire_t = nil
		self._nozzle_effect = nil
		self._showing_nozzle_effect = nil
	end

	local bullet_class = weap_tweak.bullet_class

	if bullet_class ~= nil then
		bullet_class = CoreSerialize.string_to_classtable(bullet_class)

		if not bullet_class then
			print("[NewFlamethrowerBase:setup_default] Unexisting class for bullet_class string ", weap_tweak.bullet_class, "defined for tweak data ID ", name_id)

			bullet_class = FlameBulletBase
		end
	else
		bullet_class = FlameBulletBase
	end

	self._bullet_class = bullet_class
	self._bullet_slotmask = bullet_class:bullet_slotmask()
	self._blank_slotmask = bullet_class:blank_slotmask()
	
	if managers.mutators:is_mutator_active(MutatorFriendlyFire) then --add friendly fire against player husks only for players (prevents NPCs from hitting player husks and dealing unintended non-local damage)
		self._bullet_slotmask = self._bullet_slotmask + world_g:make_slot_mask(3)
	end
end

local mvec_to = Vector3()
local mvec_direction = Vector3()
local mvec_spread_direction = Vector3()

function NewFlamethrowerBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
	local result = {}
	local damage = self:_get_current_damage(dmg_mul)
	local damage_range = self._flame_max_range or self._range

	mvec3_set(mvec_to, direction)
	mvec3_mul(mvec_to, damage_range)
	mvec3_add(mvec_to, from_pos)
	
	--use a smaller sphere ray to limit the range of the actual damaging sphere ray
	local col_ray = World:raycast("ray", mvector3.copy(from_pos), mvec_to, "sphere_cast_radius", 20, "disable_inner_ray", "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
	
	if col_ray then
		local col_dis = col_ray.distance

		if col_dis < damage_range then
			damage_range = col_dis or damage_range
		end

		mvec3_set(mvec_to, direction)
		mvec3_mul(mvec_to, damage_range)
		mvec3_add(mvec_to, from_pos)
	end

	self:_spawn_flame_effect(mvec_to, direction)
	
	
	local hit_bodies = World:find_bodies("intersect", "capsule", from_pos, mvec_to, 35, self._bullet_slotmask)
	local weap_unit = self._unit
	local hit_enemies = 0
	local hit_body, hit_unit, hit_u_key = nil
	local units_hit = {}
	local valid_hit_bodies = {}
	local ignore_units = self._setup.ignore_units
	local t_contains = table.contains

	for i = 1, #hit_bodies do
		hit_body = hit_bodies[i]
		hit_unit = hit_body:unit()

		if not t_contains(ignore_units, hit_unit) then
			hit_u_key = hit_unit:key()

			if not units_hit[hit_u_key] then
				units_hit[hit_u_key] = true
				valid_hit_bodies[#valid_hit_bodies + 1] = hit_body

				if hit_unit:character_damage() then
					hit_enemies = hit_enemies + 1
				end
			end
		end
	end

	local bullet_class = self:bullet_class()
	local fake_ray_dir, fake_ray_dis = nil

	for i = 1, #valid_hit_bodies do
		hit_body = valid_hit_bodies[i]
		fake_ray_dir = hit_body:center_of_mass()
		fake_ray_dis = mvec3_dir(fake_ray_dir, from_pos, fake_ray_dir)
		local hit_pos = hit_body:position()
		local fake_ray = {
			body = hit_body,
			unit = hit_body:unit(),
			ray = fake_ray_dir,
			normal = fake_ray_dir,
			distance = fake_ray_dis,
			position = hit_pos,
			hit_position = hit_pos
		}

		bullet_class:on_collision(fake_ray, weap_unit, user_unit, damage)
	end

	local suppression = self._suppression

	if suppression then
		local max_suppression_range = self._flame_max_range * 1.5
	
		self:_suppress_units(mvector3.copy(from_pos), mvector3.copy(direction), max_suppression_range, managers.slot:get_mask("enemies"), user_unit, suppr_mul)
	end

	if self._alert_events then
		result.rays = {
			{
				position = from_pos
			}
		}
	end

	if hit_enemies > 0 then
		result.hit_enemy = true

		managers.statistics:shot_fired({
			hit = true,
			hit_count = hit_enemies,
			weapon_unit = weap_unit
		})
	else
		result.hit_enemy = false

		managers.statistics:shot_fired({
			hit = false,
			weapon_unit = weap_unit
		})
	end

	return result
end