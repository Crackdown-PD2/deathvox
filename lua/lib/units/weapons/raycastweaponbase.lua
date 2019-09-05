local mvec3_set = mvector3.set
local mvec3_add = mvector3.add
local mvec3_dot = mvector3.dot
local mvec3_sub = mvector3.subtract
local mvec3_mul = mvector3.multiply
local mvec3_norm = mvector3.normalize
local mvec3_dir = mvector3.direction
local mvec3_set_l = mvector3.set_length
local mvec3_len = mvector3.length
local mvec3_dis = mvector3.distance_sq
local math_clamp = math.clamp
local math_lerp = math.lerp
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_rot1 = Rotation()

function RaycastWeaponBase:_weapon_tweak_data_id()
	local override_gadget = self:gadget_overrides_weapon_functions()
	if override_gadget then
		return override_gadget.name_id
	end
	return self._name_id
end

function RaycastWeaponBase:set_laser_enabled(state)
	if not tweak_data.weapon[self._name_id].disable_sniper_laser then
		if state then
			if alive(self._laser_unit) then
				return
			end
			local spawn_rot = self._obj_fire:rotation()
			local spawn_pos = self._obj_fire:position()
			spawn_pos = spawn_pos - spawn_rot:y() * 8 + spawn_rot:z() * 2 - spawn_rot:x() * 1.5
			self._laser_unit = World:spawn_unit(Idstring("units/payday2/weapons/wpn_npc_upg_fl_ass_smg_sho_peqbox/wpn_npc_upg_fl_ass_smg_sho_peqbox"), spawn_pos, spawn_rot)
			self._unit:link(self._obj_fire:name(), self._laser_unit)
			self._laser_unit:base():set_npc()
			self._laser_unit:base():set_on()
			self._laser_unit:base():set_color_by_theme("cop_sniper")
			self._laser_unit:base():set_max_distace(10000)
		elseif alive(self._laser_unit) then
			self._laser_unit:set_slot(0)
			self._laser_unit = nil
		end
	end
end

local mvec1 = Vector3()
local mvec2 = Vector3()

function RaycastWeaponBase:_collect_hits(from, to)
	local ray_hits = nil
	local hit_enemy = false
	local went_through_wall = false
	local enemy_mask = managers.slot:get_mask("enemies")
	local wall_mask = managers.slot:get_mask("world_geometry", "vehicles")
	local shield_mask = managers.slot:get_mask("enemy_shield_check")
	local ai_vision_ids = Idstring("ai_vision")
	local bulletproof_ids = Idstring("bulletproof")

	if self._can_shoot_through_wall then
		ray_hits = World:raycast_wall("ray", from, to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "thickness", 40, "thickness_mask", wall_mask)
	else
		ray_hits = World:raycast_all("ray", from, to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
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

			if not self._can_shoot_through_enemy and hit_enemy then
				break
			elseif hit.unit:in_slot(wall_mask) then
				if weak_body then --actually this means it's not glass/similar, why they choose to call it this way I don' know. These surfaces (glass/similar) get penetrated with no restriction or requirement
					if self._can_shoot_through_wall then
						if went_through_wall then
							break
						else
							went_through_wall = true --can also be changed to count the number of wall penetrations and limit them like that (using went_through_wall = (went_through_wall or 0) + 1
						end
					else
						break
					end
				end
			elseif not self._can_shoot_through_shield and hit.unit:in_slot(shield_mask) then
				break
			end
		end
	end

	return unique_hits, hit_enemy
end

local reflect_result = Vector3()
local ricochet_angles = {0, 175}
local ricochet_spread_angle = {10, 30}
local singlefire_autohit_stats = {MIN_RATIO = 0.6, MAX_RATIO = 1, INIT_RATIO = 0.6, far_dis = 1000, far_angle = 60, near_angle = 60}
local autofire_autohit_stats = {MIN_RATIO = 0.6, MAX_RATIO = 1, INIT_RATIO = 0.6, far_dis = 2000, far_angle = 60, near_angle = 60}
local peacemaker_autohit_stats = {MIN_RATIO = 0.6, MAX_RATIO = 1, INIT_RATIO = 0.6, far_dis = 4000, far_angle = 60, near_angle = 60} --but that was some fancy shooting

function InstantBulletBase:on_ricochet(col_ray, weapon_unit, user_unit, damage, blank, no_sound, autohit_stats)
	local from_pos, to_pos, ignore_unit, latest_data

	from_pos = user_unit:position() + Vector3(0, 0, 150)
	to_pos = col_ray.hit_position
	ignore_unit = user_unit

	local weapon_base = alive(weapon_unit) and weapon_unit:base()

	if weapon_base and weapon_base.check_autoaim then
		local autoaim = weapon_base:check_autoaim(from_pos, reflect_result, nil, nil, autohit_stats)

		if autoaim then
			mvector3.set(reflect_result, autoaim.ray)
			col_ray = autoaim
		end
	end

	mvector3.set_zero(reflect_result)
	mvector3.set(reflect_result, col_ray.ray)
	mvector3.add(reflect_result, -2 * col_ray.ray:dot(col_ray.normal) * col_ray.normal)

	local ang = math.abs(mvector3.angle(col_ray.ray, reflect_result))
	local can_ricochet = not (ang < ricochet_angles[1]) and not (ang > ricochet_angles[2])

	mvector3.spread(reflect_result, math.random(ricochet_spread_angle[1], ricochet_spread_angle[2]))
	from_pos = col_ray.hit_position + col_ray.normal
	ignore_unit = col_ray.unit

	if not can_ricochet then
		return
	end

	if alive(col_ray.unit) and col_ray.unit:character_damage() then
		return
	else
		local ray_data = World:raycast("ray", from_pos, from_pos + reflect_result * autohit_stats.far_dis, "slot_mask", self:bullet_slotmask())

		if ray_data then
			local trail_effect_table = {
				effect = Idstring("effects/particles/weapons/weapon_trail"),
				position = Vector3(),
				normal = Vector3()
			}
			mvector3.set(trail_effect_table.position, from_pos)
			mvector3.set(trail_effect_table.normal, from_pos + reflect_result * autohit_stats.far_dis)

			local trail = World:effect_manager():spawn(trail_effect_table)

			World:effect_manager():set_remaining_lifetime(trail, math.clamp(ray_data.distance / 10000, 0, ray_data.distance))

			InstantBulletBase:on_collision(ray_data, weapon_unit, user_unit, damage, blank, no_sound, true)
		end
	end

	return
end

local MIN_KNOCK_BACK = 200
local KNOCK_BACK_CHANCE = 0.8

function InstantBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank, no_sound, already_ricocheted)
	local can_ricochet = weapon_unit:base():weapon_tweak_data().can_ricochet

	if can_ricochet and not already_ricocheted then
		InstantBulletBase:on_ricochet(col_ray, weapon_unit, user_unit, damage, blank, no_sound, peacemaker_autohit_stats)
	end

	local hit_unit = col_ray.unit
	local shield_knock = false
	local is_shield = hit_unit:in_slot(8) and alive(hit_unit:parent())

	if is_shield and not hit_unit:parent():base().is_phalanx and not hit_unit:parent():character_damage():is_immune_to_shield_knockback() and weapon_unit then
		shield_knock = weapon_unit:base()._shield_knock
		local dmg_ratio = math.min(damage, MIN_KNOCK_BACK)
		dmg_ratio = dmg_ratio / MIN_KNOCK_BACK + 1
		local rand = math.random() * dmg_ratio

		if KNOCK_BACK_CHANCE < rand then
			local enemy_unit = hit_unit:parent()

			if shield_knock and enemy_unit:character_damage() then
				local damage_info = {
					damage = 0,
					type = "shield_knock",
					variant = "melee",
					col_ray = col_ray,
					result = {
						variant = "melee",
						type = "shield_knock"
					}
				}

				enemy_unit:character_damage():_call_listeners(damage_info)
			end
		end
	end

	local play_impact_flesh = not hit_unit:character_damage() or not hit_unit:character_damage()._no_blood

	if hit_unit:damage() and managers.network:session() and col_ray.body:extension() and col_ray.body:extension().damage then
		local sync_damage = not blank and hit_unit:id() ~= -1
		local network_damage = math.ceil(damage * 163.84)
		damage = network_damage / 163.84

		if sync_damage then
			local normal_vec_yaw, normal_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.normal, 128, 64)
			local dir_vec_yaw, dir_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.ray, 128, 64)

			managers.network:session():send_to_peers_synched("sync_body_damage_bullet", col_ray.unit:id() ~= -1 and col_ray.body or nil, user_unit:id() ~= -1 and user_unit or nil, normal_vec_yaw, normal_vec_pitch, col_ray.position, dir_vec_yaw, dir_vec_pitch, math.min(16384, network_damage))
		end

		local local_damage = not blank or hit_unit:id() == -1

		if local_damage then
			col_ray.body:extension().damage:damage_bullet(user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
			col_ray.body:extension().damage:damage_damage(user_unit, col_ray.normal, col_ray.position, col_ray.ray, damage)

			if alive(weapon_unit) and weapon_unit:base().categories and weapon_unit:base():categories() then
				for _, category in ipairs(weapon_unit:base():categories()) do
					col_ray.body:extension().damage:damage_bullet_type(category, user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
				end
			end
		end
	end

	local result = nil

	if alive(weapon_unit) and hit_unit:character_damage() and hit_unit:character_damage().damage_bullet then
		local is_alive = not hit_unit:character_damage():dead()
		local knock_down = weapon_unit:base()._knock_down and weapon_unit:base()._knock_down > 0 and math.random() < weapon_unit:base()._knock_down
		result = self:give_impact_damage(col_ray, weapon_unit, user_unit, damage, weapon_unit:base()._use_armor_piercing, false, knock_down, weapon_unit:base()._stagger, weapon_unit:base()._variant)

		if result ~= "friendly_fire" then
			local is_dead = hit_unit:character_damage():dead()
			local push_multiplier = self:_get_character_push_multiplier(weapon_unit, is_alive and is_dead)

			managers.game_play_central:physics_push(col_ray, push_multiplier)
		else
			play_impact_flesh = false
		end
	else
		managers.game_play_central:physics_push(col_ray)
	end

	if play_impact_flesh then
		managers.game_play_central:play_impact_flesh({
			col_ray = col_ray,
			no_sound = no_sound
		})
		self:play_impact_sound_and_effects(weapon_unit, col_ray, no_sound)
	end

	return result
end
