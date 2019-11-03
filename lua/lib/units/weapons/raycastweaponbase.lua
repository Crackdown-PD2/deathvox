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

function RaycastWeaponBase:setup(setup_data, damage_multiplier)
	self._autoaim = setup_data.autoaim
	local stats = tweak_data.weapon[self._name_id].stats
	self._alert_events = setup_data.alert_AI and {} or nil
	self._alert_fires = {}
	local weapon_stats = tweak_data.weapon.stats

	if stats then
		self._zoom = self._zoom or weapon_stats.zoom[stats.zoom]
		self._alert_size = self._alert_size or weapon_stats.alert_size[stats.alert_size]
		self._suppression = self._suppression or weapon_stats.suppression[stats.suppression]
		self._spread = self._spread or weapon_stats.spread[stats.spread]
		self._recoil = self._recoil or weapon_stats.recoil[stats.recoil]
		self._spread_moving = self._spread_moving or weapon_stats.spread_moving[stats.spread_moving]
		self._concealment = self._concealment or weapon_stats.concealment[stats.concealment]
		self._value = self._value or weapon_stats.value[stats.value]
		self._reload = self._reload or weapon_stats.reload[stats.reload]

		for i, _ in pairs(weapon_stats) do
			local stat = self["_" .. tostring(i)]

			if not stat then
				self["_" .. tostring(i)] = weapon_stats[i][5]

				debug_pause("[RaycastWeaponBase] Weapon \"" .. tostring(self._name_id) .. "\" is missing stat \"" .. tostring(i) .. "\"!")
			end
		end
	else
		debug_pause("[RaycastWeaponBase] Weapon \"" .. tostring(self._name_id) .. "\" is missing stats block!")

		self._zoom = 60
		self._alert_size = 5000
		self._suppression = 1
		self._spread = 1
		self._recoil = 1
		self._spread_moving = 1
		self._reload = 1
	end

	self._bullet_slotmask = setup_data.hit_slotmask or self._bullet_slotmask
	self._panic_suppression_chance = setup_data.panic_suppression_skill and self:weapon_tweak_data().panic_suppression_chance

	if self._panic_suppression_chance == 0 then
		self._panic_suppression_chance = false
	end

	self._setup = setup_data
	self._fire_mode = self._fire_mode or tweak_data.weapon[self._name_id].FIRE_MODE or "single"

	if self._setup.timer then
		self:set_timer(self._setup.timer)
	end

	if managers.mutators:is_mutator_active(MutatorFriendlyFire) then --add friendly fire against player husks only for players
		self._bullet_slotmask = self._bullet_slotmask + World:make_slot_mask(3)
	end
end

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

local mvec_to = Vector3()
local mvec_spread_direction = Vector3()
local mvec1 = Vector3()

function RaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
	if self:gadget_overrides_weapon_functions() then
		return self:gadget_function_override("_fire_raycast", self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
	end

	local result = {}
	local spread_x, spread_y = self:_get_spread(user_unit)
	local ray_distance = self:weapon_range()
	local right = direction:cross(Vector3(0, 0, 1)):normalized()
	local up = direction:cross(right):normalized()
	local theta = math.random() * 360
	local ax = math.sin(theta) * math.random() * spread_x * (spread_mul or 1)
	local ay = math.cos(theta) * math.random() * spread_y * (spread_mul or 1)

	mvector3.set(mvec_spread_direction, direction)
	mvector3.add(mvec_spread_direction, right * math.rad(ax))
	mvector3.add(mvec_spread_direction, up * math.rad(ay))
	mvector3.set(mvec_to, mvec_spread_direction)
	mvector3.multiply(mvec_to, ray_distance)
	mvector3.add(mvec_to, from_pos)

	local damage = self:_get_current_damage(dmg_mul)
	local ray_hits, hit_enemy = self:_collect_hits(from_pos, mvec_to)
	local hit_anyone = false

	if self._autoaim then
		local weight = 0.1
		local auto_hit_candidate = self:check_autoaim(from_pos, direction)

		if auto_hit_candidate and not hit_enemy then
			local autohit_chance = 1 - math.clamp((self._autohit_current - self._autohit_data.MIN_RATIO) / (self._autohit_data.MAX_RATIO - self._autohit_data.MIN_RATIO), 0, 1)

			if autohit_mul then
				autohit_chance = autohit_chance * autohit_mul
			end

			if math.random() < autohit_chance then
				self._autohit_current = (self._autohit_current + weight) / (1 + weight)

				mvector3.set(mvec_to, from_pos)
				mvector3.add_scaled(mvec_to, auto_hit_candidate.ray, ray_distance)

				ray_hits, hit_enemy = self:_collect_hits(from_pos, mvec_to)
			end
		end

		if hit_enemy then
			self._autohit_current = (self._autohit_current + weight) / (1 + weight)
		elseif auto_hit_candidate then
			self._autohit_current = self._autohit_current / (1 + weight)
		end
	end

	local hit_count = 0
	local cop_kill_count = 0
	local hit_through_wall = false
	local hit_through_shield = false
	local hit_result = nil

	for _, hit in ipairs(ray_hits) do
		damage = self:get_damage_falloff(damage, hit, user_unit)
		hit_result = self._bullet_class:on_collision(hit, self._unit, user_unit, damage)

		if hit_result and hit_result.type == "death" then
			local unit_type = hit.unit:base() and hit.unit:base()._tweak_table
			local is_civilian = unit_type and CopDamage.is_civilian(unit_type)

			if not is_civilian then
				cop_kill_count = cop_kill_count + 1
			end

			if self:is_category(tweak_data.achievement.easy_as_breathing.weapon_type) and not is_civilian then
				self._kills_without_releasing_trigger = (self._kills_without_releasing_trigger or 0) + 1

				if tweak_data.achievement.easy_as_breathing.count <= self._kills_without_releasing_trigger then
					managers.achievment:award(tweak_data.achievement.easy_as_breathing.award)
				end
			end
		end

		if hit_result then
			hit.damage_result = hit_result
			hit_anyone = true
			hit_count = hit_count + 1
		end

		if hit.unit:in_slot(managers.slot:get_mask("world_geometry")) then
			hit_through_wall = true
		elseif hit.unit:in_slot(managers.slot:get_mask("enemy_shield_check")) then
			hit_through_shield = hit_through_shield or alive(hit.unit:parent())
		end

		if hit_result and hit_result.type == "death" and cop_kill_count > 0 then
			local unit_type = hit.unit:base() and hit.unit:base()._tweak_table
			local multi_kill, enemy_pass, obstacle_pass, weapon_pass, weapons_pass, weapon_type_pass = nil

			for achievement, achievement_data in pairs(tweak_data.achievement.sniper_kill_achievements) do
				multi_kill = not achievement_data.multi_kill or cop_kill_count == achievement_data.multi_kill
				enemy_pass = not achievement_data.enemy or unit_type == achievement_data.enemy
				obstacle_pass = not achievement_data.obstacle or achievement_data.obstacle == "wall" and hit_through_wall or achievement_data.obstacle == "shield" and hit_through_shield
				weapon_pass = not achievement_data.weapon or self._name_id == achievement_data.weapon
				weapons_pass = not achievement_data.weapons or table.contains(achievement_data.weapons, self._name_id)
				weapon_type_pass = not achievement_data.weapon_type or self:is_category(achievement_data.weapon_type)

				if multi_kill and enemy_pass and obstacle_pass and weapon_pass and weapons_pass and weapon_type_pass then
					if achievement_data.stat then
						managers.achievment:award_progress(achievement_data.stat)
					elseif achievement_data.award then
						managers.achievment:award(achievement_data.award)
					elseif achievement_data.challenge_stat then
						managers.challenge:award_progress(achievement_data.challenge_stat)
					elseif achievement_data.trophy_stat then
						managers.custom_safehouse:award(achievement_data.trophy_stat)
					elseif achievement_data.challenge_award then
						managers.challenge:award(achievement_data.challenge_award)
					end
				end
			end
		end
	end

	if not tweak_data.achievement.tango_4.difficulty or table.contains(tweak_data.achievement.tango_4.difficulty, Global.game_settings.difficulty) then
		if self._gadgets and table.contains(self._gadgets, "wpn_fps_upg_o_45rds") and cop_kill_count > 0 and managers.player:player_unit():movement():current_state():in_steelsight() then
			if self._tango_4_data then
				if self._gadget_on == self._tango_4_data.last_gadget_state then
					self._tango_4_data = nil
				else
					self._tango_4_data.last_gadget_state = self._gadget_on
					self._tango_4_data.count = self._tango_4_data.count + 1
				end

				if self._tango_4_data and tweak_data.achievement.tango_4.count <= self._tango_4_data.count then
					managers.achievment:_award_achievement(tweak_data.achievement.tango_4, "tango_4")
				end
			else
				self._tango_4_data = {
					count = 1,
					last_gadget_state = self._gadget_on
				}
			end
		elseif self._tango_4_data then
			self._tango_4_data = nil
		end
	end

	result.hit_enemy = hit_anyone

	if self._autoaim then
		self._shot_fired_stats_table.hit = hit_anyone
		self._shot_fired_stats_table.hit_count = hit_count

		if (not self._ammo_data or not self._ammo_data.ignore_statistic) and not self._rays then
			managers.statistics:shot_fired(self._shot_fired_stats_table)
		end
	end

	local furthest_hit = ray_hits[#ray_hits]

	if (furthest_hit and furthest_hit.distance > 600 or not furthest_hit) and alive(self._obj_fire) then
		self._obj_fire:m_position(self._trail_effect_table.position)
		mvector3.set(self._trail_effect_table.normal, mvec_spread_direction)

		local trail = World:effect_manager():spawn(self._trail_effect_table)

		if furthest_hit then
			World:effect_manager():set_remaining_lifetime(trail, math.clamp((furthest_hit.distance - 600) / 10000, 0, furthest_hit.distance))
		else
			World:effect_manager():set_remaining_lifetime(trail, math.clamp((ray_distance - 600) / 10000, 0, ray_distance)) --first small change
		end
	end

	if self._suppression then --second change done here, for the suppression rework
		local max_distance = ray_distance --ray_distance is 200m, modify accordingly
		local tmp_vec_to = Vector3()

		mvector3.set(tmp_vec_to, mvector3.copy(direction))
		mvector3.multiply(tmp_vec_to, max_distance)
		mvector3.add(tmp_vec_to, mvector3.copy(from_pos))

		self:_suppress_units(mvector3.copy(from_pos), tmp_vec_to, 100, managers.slot:get_mask("enemies"), user_unit, suppr_mul, max_distance)
	end

	if self._alert_events then
		result.rays = ray_hits
	end

	return result
end

local reflect_result = Vector3()

function InstantBulletBase:on_ricochet(col_ray, weapon_unit, user_unit, damage, blank, no_sound, guaranteed_hit, restrictive_angles)
	local ignore_units = {}
	local can_shoot_through_enemy = nil
	local can_shoot_through_shield = nil

	if weapon_unit and alive(weapon_unit) then
		--shoot-through checks that will avoid crashing if the weapon somehow ceases to exist
		can_shoot_through_enemy = weapon_unit:base()._can_shoot_through_enemy
		can_shoot_through_shield = weapon_unit:base()._can_shoot_through_shield

		--usually a weapon has itself and its user ignored to avoid unnecessary collisions. These checks are here in case we want player husks to shoot visible ricochets (pretty sure other players can't see the ricochet if only local players can trigger them)
		if weapon_unit:base()._setup and weapon_unit:base()._setup.ignore_units then
			ignore_units = weapon_unit:base()._setup.ignore_units
		else
			table.insert(ignore_units, weapon_unit)

			if user_unit then
				table.insert(ignore_units, user_unit)
			end
		end
	end

	local ricochet_range = guaranteed_hit and 1000 or 2000 --modify as you wish
	local impact_pos = col_ray.hit_position or col_ray.position

	if guaranteed_hit then
		local bodies = World:find_bodies("intersect", "sphere", impact_pos, ricochet_range, managers.slot:get_mask("enemies")) --use a sphere to find nearby enemies
		local can_hit_enemy = false

		if #bodies > 0 then
			for _, hit_body in ipairs(bodies) do
				local hit_unit = hit_body:unit()

				if hit_unit.character_damage and hit_unit:character_damage() and hit_unit:character_damage().damage_bullet and not hit_unit:character_damage():dead() then --check if the enemy can take bullet damage and they're not dead
					local hit_ray = World:raycast("ray", impact_pos, hit_body:center_of_mass(), "slot_mask", self:bullet_slotmask(), "ignore_unit", ignore_units) --check if the enemy can actually be hit (isn't obstructed)

					if hit_ray and hit_ray.unit and hit_ray.unit:key() == hit_unit:key() then --make sure the one that's hit is the same as that was found in this loop
						mvector3.set(reflect_result, hit_ray.ray)
						col_ray.ray = hit_ray.ray
						can_hit_enemy = true

						break --to select and only hit that specific enemy
					end
				end
			end

			if not can_hit_enemy then
				return
			end
		else
			return
		end
	else
		mvector3.set_zero(reflect_result)
		mvector3.set(reflect_result, col_ray.ray) --get the direction of the bullet
		mvector3.add(reflect_result, -2 * col_ray.ray:dot(col_ray.normal) * col_ray.normal) --use the direction of the bullet to calculate where it should bounce off to

		local angle = math.abs(mvector3.angle(col_ray.ray, reflect_result))
		local allowed_angles = {0, 175}

		if restrictive_angles then
			allowed_angles = {0, 90}
		end

		local can_ricochet = not (angle < allowed_angles[1]) and not (angle > allowed_angles[2])

		if not can_ricochet then
			return
		end

		if not restrictive_angles then --if there's no restriction, apply some spread to avoid perfect 175° bounces
			local ricochet_spread_angle = {10, 30}

			mvector3.spread(reflect_result, math.random(ricochet_spread_angle[1], ricochet_spread_angle[2]))
		end
	end

	local from_pos = col_ray.hit_position + col_ray.normal

	--usual collect_hits stuff to use proper penetration
	local ray_hits = nil
	local hit_enemy = false
	local enemy_mask = managers.slot:get_mask("enemies")
	local wall_mask = managers.slot:get_mask("world_geometry", "vehicles")
	local shield_mask = managers.slot:get_mask("enemy_shield_check")
	local ai_vision_ids = Idstring("ai_vision")
	local bulletproof_ids = Idstring("bulletproof")

	ray_hits = World:raycast_all("ray", from_pos, from_pos + reflect_result * ricochet_range, "slot_mask", self:bullet_slotmask(), "ignore_unit", ignore_units)

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

			if not can_shoot_through_enemy and hit_enemy then
				break
			elseif hit.unit:in_slot(wall_mask) then
				if weak_body then
					break
				end
			elseif not can_shoot_through_shield and hit.unit:in_slot(shield_mask) then
				break
			end
		end
	end

	local hit_enemies = {}

	for _, hit in ipairs(unique_hits) do
		if hit.unit and hit.unit:character_damage() then
			table.insert(hit_enemies, hit.unit)
		end

		if guaranteed_hit then
			if not hit.unit:in_slot(managers.slot:get_mask("civilians")) then --ignore civs with guaranteed hits since you are not able to control where they go to (remove this check if you still want to make them to kill civs that happen to be in the way)
				InstantBulletBase:on_collision(hit, weapon_unit, user_unit, damage, blank, no_sound, true)
			end
		else
			InstantBulletBase:on_collision(hit, weapon_unit, user_unit, damage, blank, no_sound, true)
		end
	end

	for _, d in pairs(hit_enemies) do --if the ricochet hit a character, count it as an actual hit instead of a missed shot
		managers.statistics:shot_fired({
			skip_bullet_count = true,
			hit = true,
			weapon_unit = weapon_unit
		})
	end

	local furthest_hit = unique_hits[#unique_hits]

	--guaranteed hits use sniper trails to show them, while simulated hits simply use a bullet trail
	if guaranteed_hit then
		if not self._trail_length then
			self._trail_length = World:effect_manager():get_initial_simulator_var_vector2(Idstring("effects/particles/weapons/sniper_trail"), Idstring("trail"), Idstring("simulator_length"), Idstring("size"))
		end

		local trail = World:effect_manager():spawn({
			effect = Idstring("effects/particles/weapons/sniper_trail"),
			position = from_pos,
			normal = reflect_result
		})

		mvector3.set_y(self._trail_length, furthest_hit and furthest_hit.distance or ricochet_range)
		World:effect_manager():set_simulator_var_vector2(trail, Idstring("trail"), Idstring("simulator_length"), Idstring("size"), self._trail_length)
	else
		local trail = World:effect_manager():spawn({
			effect = Idstring("effects/particles/weapons/weapon_trail"),
			position = from_pos,
			normal = reflect_result
		})

		if furthest_hit then
			World:effect_manager():set_remaining_lifetime(trail, math.clamp((furthest_hit.distance - 600) / 10000, 0, furthest_hit.distance))
		else
			World:effect_manager():set_remaining_lifetime(trail, math.clamp((ricochet_range - 600) / 10000, 0, ricochet_range))
		end
	end
end

local MIN_KNOCK_BACK = 200
local KNOCK_BACK_CHANCE = 0.8

function InstantBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank, no_sound, already_ricocheted)
	if not blank and Network:is_client() and user_unit ~= managers.player:player_unit() then
		blank = true
	end

	local enable_ricochets = false

	if enable_ricochets and not already_ricocheted and user_unit and user_unit == managers.player:player_unit() and col_ray.unit then
		local has_category = weapon_unit and alive(weapon_unit) and not weapon_unit:base().thrower_unit and weapon_unit:base().is_category

		if has_category and weapon_unit:base():is_category("assault_rifle", "smg") then --to replace later with the proper skill and procing check (random chance/last bullet/etc)
			local can_bounce_off = false

			--easier to understand and to add more conditions if desired
			if not weapon_unit:base()._can_shoot_through_shield and col_ray.unit:in_slot(managers.slot:get_mask("enemy_shield_check")) then
				can_bounce_off = true
			elseif not weapon_unit:base()._can_shoot_through_wall and col_ray.unit:in_slot(managers.slot:get_mask("world_geometry", "vehicles")) and (col_ray.body:has_ray_type(Idstring("ai_vision")) or col_ray.body:has_ray_type(Idstring("bulletproof"))) then
				can_bounce_off = true
			end

			if can_bounce_off then
				InstantBulletBase:on_ricochet(col_ray, weapon_unit, user_unit, damage, blank, no_sound, true)
			end
		end
	end

	local hit_unit = col_ray.unit
	local shield_knock = false
	local is_shield = hit_unit:in_slot(managers.slot:get_mask("enemy_shield_check")) and alive(hit_unit:parent())

	--more proper checks if the shield can actually be knocked back
	if weapon_unit and is_shield and not hit_unit:parent():base().is_phalanx and tweak_data.character[hit_unit:parent():base()._tweak_table].damage.shield_knocked and not hit_unit:parent():character_damage():is_immune_to_shield_knockback() then
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
		local damage_body_extension = true

		--prevents teammates of the hit_unit from damaging its body extensions, if it has any (e.g. Bulldozer armor parts/faceplate/visor)
		if user_unit and hit_unit:character_damage() and hit_unit:character_damage().is_friendly_fire and hit_unit:character_damage():is_friendly_fire(user_unit) then
			damage_body_extension = false
		end

		if damage_body_extension then
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
	end

	local result = nil

	if not blank then
		if alive(weapon_unit) and hit_unit:character_damage() and hit_unit:character_damage().damage_bullet then
			local is_alive = not hit_unit:character_damage():dead()
			local knock_down = weapon_unit:base()._knock_down and weapon_unit:base()._knock_down > 0 and math.random() < weapon_unit:base()._knock_down
			result = self:give_impact_damage(col_ray, weapon_unit, user_unit, damage, weapon_unit:base()._use_armor_piercing, false, knock_down, weapon_unit:base()._stagger, weapon_unit:base()._variant)
			local is_dead = hit_unit:character_damage():dead()

			if not is_dead then
				--if no damage is taken (blocked by grace period, script, mission stuff, etc). The less impact effects, the better
				if not result or result == "friendly_fire" then
					play_impact_flesh = false
				end
			end

			local push_multiplier = self:_get_character_push_multiplier(weapon_unit, is_alive and is_dead)

			managers.game_play_central:physics_push(col_ray, push_multiplier)
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
	end

	return result
end

function RaycastWeaponBase:_suppress_units(from, to, cylinder_radius, slotmask, user_unit, suppr_mul, max_distance)
	local find_enemies = World:find_units("intersect", "cylinder", from, to, cylinder_radius, slotmask)

	--draw the cylinder to see where it goes
	--[[local draw_duration = 0.1 --SEIZURE WARNING, INCREASE IF NEEDED
	local new_brush = Draw:brush(Color.white:with_alpha(0.5), draw_duration)
	new_brush:cylinder(from, to, cylinder_radius)]]

	local enemies_to_suppress = {}

	if #find_enemies > 0 then
		for _, ene_unit in ipairs(find_enemies) do
			if not table.contains(enemies_to_suppress, ene_unit) and ene_unit.character_damage and ene_unit:character_damage() and ene_unit:character_damage().build_suppression then --valid enemy + has suppression function
				if not ene_unit:movement().cool or ene_unit:movement().cool and not ene_unit:movement():cool() then --is alerted or can't be alerted at all (player)
					if user_unit:movement():team() ~= ene_unit:movement():team() and user_unit:movement():team().foes[ene_unit:movement():team().id] then --not in the same team as the shooter
						if Network:is_server() or ene_unit == managers.player:player_unit() then --only suppress the local player for client sessions
							local obstructed = World:raycast("ray", from, ene_unit:movement():m_head_pos(), "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", "ai_vision") --imitating AI checking for visibility for things like shouting

							if not obstructed then
								table.insert(enemies_to_suppress, ene_unit)
							end
						end
					end
				end
			end
		end

		for _, ene_unit in ipairs(enemies_to_suppress) do
			local total_suppression = (suppr_mul or 1) * self._suppression
			local enemy_distance = mvector3.normalize(from, ene_unit:movement():m_head_pos())
			local dis_lerp_value = math.clamp(enemy_distance, 0, max_distance) / max_distance

			total_suppression = math.lerp(total_suppression, 0, dis_lerp_value) --scale suppression downwards and linearly, becoming 0 at maximum allowed distance or past that

			local total_panic_chance = false

			if self._panic_suppression_chance then
				total_panic_chance = self._panic_suppression_chance

				--4.5 is the highest suppression value allowed for players, that point means maximum panic base chance, but it will still get decreased with distance
				local suppr_lerp_value = math.clamp(total_suppression, 0, 4.5) / 4.5

				total_panic_chance = math.lerp(0, total_panic_chance, suppr_lerp_value)
			end

			if total_suppression > 0 then
				ene_unit:character_damage():build_suppression(total_suppression, total_panic_chance)
			end
		end
	end
end
