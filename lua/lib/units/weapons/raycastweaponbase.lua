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
RaycastWeaponBase.TRAIL_EFFECT = Idstring("effects/particles/weapons/weapon_trail")



Hooks:PostHook(RaycastWeaponBase,"init","deathvox_init_weapon_classes",function(self,unit)
	self:set_weapon_class(tweak_data.weapon[self._name_id].primary_class)
	--todo check blueprint for class-/subclass-modifying attachments
	self._subclasses = tweak_data.weapon[self._name_id].subclasses and table.deep_map_copy(tweak_data.weapon[self._name_id].subclasses) or {}
end)

function RaycastWeaponBase:get_weapon_class()
	return self._primary_class
end

function RaycastWeaponBase:set_weapon_class(class)
	self._primary_class = class
end

function RaycastWeaponBase:set_weapon_subclass(subclass)
	if not table.contains(self._subclasses,subclass) then 
		table.insert(self._subclasses,subclass)
	end
end

function RaycastWeaponBase:remove_weapon_subclass(...) --can remove multiple simultaneously
	local num_subclasses = #self._subclasses
	if num_subclasses <= 0 then 
		return
	end
	for _,subclass in pairs({...}) do 
		for i = num_subclasses,1,-1 do 
			if self._subclasses[i] == subclass then 
				table.remove(self._subclasses,i)
				break
			end
		end
	end
end

function RaycastWeaponBase:get_weapon_subclasses()
	return self._subclasses
end

function RaycastWeaponBase:is_weapon_class(class)
	if not class then 
		return false
	end
	local gadget_override = self:gadget_overrides_weapon_functions()
	if gadget_override then 
		local td = gadget_override.name_id and tweak_data.weapon[gadget_override.name_id]
		return td and td.primary_class == class
	end
	return self._primary_class == class
end

function RaycastWeaponBase:is_weapon_subclass(...)
	local subclasses = self._weapon_subclasses
	
	local gadget_override = self:gadget_overrides_weapon_functions()
	if gadget_override then 
		local td = gadget_override.name_id and tweak_data.weapon[gadget_override.name_id]
		subclasses = td and td.subclasses or {}
	end
	
	local matched
	for _,category in pairs({...}) do 
		if table.contains(subclasses or {},category) then 
			--must not be missing match to any given parameters, and must positively match at least one parameter
			--(therefore if own subclasses table is empty, this will return false)
			matched = true
		else
			return false
		end
	end
	return matched
end



function RaycastWeaponBase:check_autoaim(from_pos, direction, max_dist, use_aim_assist, autohit_override_data)
	local autohit = use_aim_assist and self._aim_assist_data or self._autohit_data
	autohit = autohit_override_data or autohit
	local autohit_near_angle = autohit.near_angle
	local autohit_far_angle = autohit.far_angle
	local far_dis = autohit.far_dis
	local closest_error, closest_ray = nil
	local tar_vec = tmp_vec1
	local ignore_units = self._setup.ignore_units
	local obstruction_slotmask = self._bullet_slotmask

	if self._can_shoot_through_shield then
		obstruction_slotmask = obstruction_slotmask - 8
	end

	local cone_distance = max_dist or self:weapon_range() or 20000
	local tmp_vec_to = Vector3()
	mvector3.set(tmp_vec_to, mvector3.copy(direction))
	mvector3.multiply(tmp_vec_to, cone_distance)
	mvector3.add(tmp_vec_to, mvector3.copy(from_pos))

	local cone_radius = mvector3.length(tmp_vec_to) / 4
	local enemies_in_cone = World:find_units("cone", from_pos, tmp_vec_to, cone_radius, managers.slot:get_mask("player_autoaim"))

	for _, enemy in pairs(enemies_in_cone) do
		local com = enemy:movement():m_com()

		mvector3.set(tar_vec, com)
		mvector3.subtract(tar_vec, from_pos)

		local tar_aim_dot = mvec3_dot(direction, tar_vec)

		if tar_aim_dot > 0 and (not max_dist or tar_aim_dot < max_dist) then
			local tar_vec_len = math_clamp(mvec3_norm(tar_vec), 1, far_dis)
			local error_dot = mvec3_dot(direction, tar_vec)
			local error_angle = math.acos(error_dot)
			local dis_lerp = math.pow(tar_aim_dot / far_dis, 0.25)
			local autohit_min_angle = math_lerp(autohit_near_angle, autohit_far_angle, dis_lerp)

			if error_angle < autohit_min_angle then
				local percent_error = error_angle / autohit_min_angle

				if not closest_error or percent_error < closest_error then
					tar_vec_len = tar_vec_len + 100

					mvector3.multiply(tar_vec, tar_vec_len)
					mvector3.add(tar_vec, from_pos)

					local vis_ray = World:raycast("ray", from_pos, tar_vec, "slot_mask", obstruction_slotmask, "ignore_unit", ignore_units)

					if vis_ray and vis_ray.unit:key() == enemy:key() and (not closest_error or error_angle < closest_error) then
						closest_error = error_angle
						closest_ray = vis_ray

						mvector3.set(tmp_vec1, com)
						mvector3.subtract(tmp_vec1, from_pos)

						local d = mvec3_dot(direction, tmp_vec1)

						mvector3.set(tmp_vec1, direction)
						mvector3.multiply(tmp_vec1, d)
						mvector3.add(tmp_vec1, from_pos)
						mvector3.subtract(tmp_vec1, com)

						closest_ray.distance_to_aim_line = mvec3_len(tmp_vec1)
					end
				end
			end
		end
	end

	return closest_ray
end

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
	self._bullet_slotmask = managers.mutators:modify_value("RaycastWeaponBase:setup:weapon_slot_mask", self._bullet_slotmask)
	self._panic_suppression_chance = setup_data.panic_suppression_skill and self:weapon_tweak_data().panic_suppression_chance

	if self._panic_suppression_chance == 0 then
		self._panic_suppression_chance = false
	end

	self._setup = setup_data
	self._fire_mode = self._fire_mode or tweak_data.weapon[self._name_id].FIRE_MODE or "single"

	if self._setup.timer then
		self:set_timer(self._setup.timer)
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

function RaycastWeaponBase:fire(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	if managers.player:has_activate_temporary_upgrade("temporary", "no_ammo_cost_buff") then
		managers.player:deactivate_temporary_upgrade("temporary", "no_ammo_cost_buff")

		if managers.player:has_category_upgrade("temporary", "no_ammo_cost") then
			managers.player:activate_temporary_upgrade("temporary", "no_ammo_cost")
		end
	end
	
	local is_player = self._setup.user_unit == managers.player:player_unit()
	local consume_ammo = not managers.player:has_active_temporary_property("bullet_storm") and (not managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier") or not managers.player:has_category_upgrade("player", "berserker_no_ammo_cost")) or not is_player
	local base = self:ammo_base()
	local mag = base:get_ammo_remaining_in_clip()
	

	if consume_ammo and (is_player or Network:is_server()) then

		if base:get_ammo_remaining_in_clip() == 0 then
			return
		end

		local ammo_usage = 1
		local remaining_ammo = mag - ammo_usage

		if is_player then
			for _, category in ipairs(self:weapon_tweak_data().categories) do
				if managers.player:has_category_upgrade(category, "consume_no_ammo_chance") then
					local roll = math.rand(1)
					local chance = managers.player:upgrade_value(category, "consume_no_ammo_chance", 0)

					if roll < chance then
						ammo_usage = 0

						print("NO AMMO COST")
					end
				end
			end
		end

		if mag > 0 and remaining_ammo <= (self.AKIMBO and 1 or 0) then
			local w_td = self:weapon_tweak_data()

			if w_td.animations and w_td.animations.magazine_empty then
				self:tweak_data_anim_play("magazine_empty")
			end

			if w_td.sounds and w_td.sounds.magazine_empty then
				self:play_tweak_data_sound("magazine_empty")
			end

			if w_td.effects and w_td.effects.magazine_empty then
				self:_spawn_tweak_data_effect("magazine_empty")
			end

			self:set_magazine_empty(true)
		end

		base:set_ammo_remaining_in_clip(base:get_ammo_remaining_in_clip() - ammo_usage)
		self:use_ammo(base, ammo_usage)
	end
	local do_money_shot
	if is_player then
		if mag <= 1 and managers.player:has_category_upgrade("weapon", "money_shot") and self:is_weapon_class("rapidfire") then
			do_money_shot = true
			local money_trail = Idstring("effects/particles/weapons/trail_dv_sniper")
			local money_muzzle = Idstring("effects/particles/weapons/money_muzzle_fps")
			
			self._trail_effect_table = {
				effect = money_trail,
				position = Vector3(),
				normal = Vector3()
			}
			
			self._muzzle_effect_table = {
				force_synch = true,
				effect = money_muzzle,
				parent = self._obj_fire
			}
			
			dmg_mul = dmg_mul + 1
			self:play_sound("c4_explode_metal")
		else
			self._trail_effect_table = {
				effect = self.TRAIL_EFFECT,
				position = Vector3(),
				normal = Vector3()
			}
			
			self._muzzle_effect_table = {
				force_synch = true,
				effect = self._muzzle_effect,
				parent = self._obj_fire
			}
			
		end
	end

	local user_unit = self._setup.user_unit

	self:_check_ammo_total(user_unit)

	if alive(self._obj_fire) then
		self:_spawn_muzzle_effect(from_pos, direction)
	end

	self:_spawn_shell_eject_effect()

	local ray_res = self:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)

	if self._alert_events and ray_res.rays then
		self:_check_alert(ray_res.rays, from_pos, direction, user_unit)
	end

	if ray_res.enemies_in_cone then
		for enemy_data, dis_error in pairs(ray_res.enemies_in_cone) do
			if not enemy_data.unit:movement():cool() then
				enemy_data.unit:character_damage():build_suppression(suppr_mul * dis_error * self._suppression, self._panic_suppression_chance)
			end
		end
	end

	managers.player:send_message(Message.OnWeaponFired, nil, self._unit, ray_res)
	if do_money_shot and ray_res.rays and ray_res.rays[1] and ray_res.rays[1].position then 
		local position = ray_res.rays[1].position 
		local money_shot_data = managers.player:upgrade_value("weapon","money_shot",{0,0})
		for _,unit in pairs(World:find_units_quick("sphere",position,money_shot_data[2],managers.slot:get_mask("enemies"))) do 
			if unit:character_damage() then 
				unit:character_damage():damage_simple({
					variant = "bullet",
					damage = money_shot_data[1] * self:_get_current_damage(dmg_mul),
					attacker_unit = managers.player:local_player(),
--					owner = managers.player:local_player(),
					weapon_unit = self._unit,
					pos = unit:position(),
					attack_dir = direction
				})
			end
		end
	end
	return ray_res
end

function RaycastWeaponBase:fire_rate_multiplier(rof_mul)
--the addition of the optional rof_mul argument is from cd
	rof_mul = rof_mul or 1
	if self:is_weapon_class("precision") then
		local tap_the_trigger_data = managers.player:upgrade_value("point_and_click_rof_bonus",{0,0})
		rof_mul = rof_mul * (1 + math.min(tap_the_trigger_data[1] * managers.player:get_property("current_point_and_click_stacks",0),tap_the_trigger_data[2]))
	elseif self:is_weapon_class("class_shotgun") and self:fire_mode() == "single" then 
		rof_mul = rof_mul + managers.player:upgrade_value("class_shotgun","shell_games_rof_bonus",0)
	end
	return rof_mul
end

function RaycastWeaponBase:reload_speed_multiplier(multiplier)
	multiplier = multiplier or 1
--optional multiplier argument is added from cd here as well

	if self:is_weapon_class("precision") then
		local this_machine_data = managers.player:upgrade_value("weapon","point_and_click_bonus_reload_speed",{0,0})
		multiplier = multiplier * (1 + math.min(this_machine_data[1] * managers.player:get_property("current_point_and_click_stacks",0),this_machine_data[2]))
	end
	
	for _, category in ipairs(self:weapon_tweak_data().categories) do
		multiplier = multiplier * managers.player:upgrade_value(category, "reload_speed_multiplier", 1)
	end

	multiplier = multiplier * managers.player:upgrade_value("weapon", "passive_reload_speed_multiplier", 1)
	multiplier = multiplier * managers.player:upgrade_value(self._name_id, "reload_speed_multiplier", 1)
	
	--clean this up once all weapons are tagged appropriately
	if self:is_weapon_class("rapidfire") and self:ammo_base():clip_empty() then
		multiplier = multiplier * managers.player:upgrade_value("weapon", "money_shot_aced", 1)
	end
	
	multiplier = managers.modifiers:modify_value("WeaponBase:GetReloadSpeedMultiplier", multiplier)

	return multiplier
end

function RaycastWeaponBase:_get_current_damage(dmg_mul)
	local point_and_click_data = managers.player:upgrade_value("weapon","point_and_click_damage_bonus",{0,0})
	local damage = self._damage
	if self:is_weapon_class("precision") then 
		damage = damage + math.min(point_and_click_data[1] * managers.player:get_property("current_point_and_click_stacks",0),point_and_click_data[2])
	end
	damage = damage * (dmg_mul or 1)
	damage = damage * managers.player:temporary_upgrade_value("temporary", "combat_medic_damage_multiplier", 1)
	if self:is_weapon_class("class_shotgun") and self:fire_mode() == "auto" then 
		damage = damage * (1 + managers.player:upgrade_value("class_shotgun","heartbreaker_damage",0))
	end
	return damage
end

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
		local auto_hit_candidate = not hit_enemy and self:check_autoaim(from_pos, direction)

		if auto_hit_candidate then
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

	if alive(self._obj_fire) then
		if furthest_hit and furthest_hit.distance > 600 or not furthest_hit then
			local trail_direction = furthest_hit and furthest_hit.ray or mvec_spread_direction

			self._obj_fire:m_position(self._trail_effect_table.position)
			mvector3.set(self._trail_effect_table.normal, trail_direction)

			local trail = World:effect_manager():spawn(self._trail_effect_table)

			if furthest_hit then
				World:effect_manager():set_remaining_lifetime(trail, math.clamp((furthest_hit.distance - 600) / 10000, 0, furthest_hit.distance))
			else
				World:effect_manager():set_remaining_lifetime(trail, math.clamp((ray_distance - 600) / 10000, 0, ray_distance))
			end
		end
	end

	if self._alert_events then
		result.rays = ray_hits
	end

	if self._suppression then
		self:_suppress_units(mvector3.copy(from_pos), mvector3.copy(direction), ray_distance, managers.slot:get_mask("enemies"), user_unit, suppr_mul)
	end

	return result
end

function RaycastWeaponBase:update_next_shooting_time()
	if self:is_weapon_class("class_shotgun") and self:fire_mode() == "auto" then 
		if tweak_data.weapon[self._name_id].CLIP_AMMO_MAX == 2 then 
			if managers.player:has_category_upgrade("class_shotgun","heartbreaker_doublebarrel") then 
--				self._next_fire_allowed = 0
				return
			end
		end
	end

	local next_fire = (tweak_data.weapon[self._name_id].fire_mode_data and tweak_data.weapon[self._name_id].fire_mode_data.fire_rate or 0) / self:fire_rate_multiplier()
	self._next_fire_allowed = self._next_fire_allowed + next_fire
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

	if guaranteed_hit and managers.player:has_category_upgrade("player", "ricochet_bullets_aced") then
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

function InstantBulletBase:calculate_crit(weapon_unit, user_unit)
	if not user_unit or user_unit ~= managers.player:player_unit() then
		return nil
	end

	local crit_value = managers.player:critical_hit_chance()
	
	local has_category = weapon_unit and alive(weapon_unit) and not weapon_unit:base().thrower_unit and weapon_unit:base().is_category
	
	if has_category and weapon_unit:base():is_weapon_class("rapidfire") then
	
		crit_value = crit_value + managers.player:upgrade_value("weapon", "spray_and_pray_basic", 0)
		
		crit_value = crit_value + managers.player:upgrade_value("weapon", "prayers_answered", 0)
		
		local making_miracles_stacks = managers.player:get_property("making_miracles_stacks",0) --num stacks
		local making_miracles_crit_max = managers.player:upgrade_value("weapon","making_miracles_crit_cap",0) --max crit chance
		local making_miracles_crit_chance = managers.player:upgrade_value("weapon","making_miracles_basic",{0,0})[1] --chance per stack
		local making_miracles_crit_bonus = math.min(making_miracles_stacks * making_miracles_crit_chance,making_miracles_crit_max) --total applied bonus
		crit_value = crit_value + making_miracles_crit_bonus
		--log("new do? dead you.")
	end
	
	--log("crit value is " .. crit_value .. "!")
	
	--if critical_hit then
	--	log("BOOM")
	--end
	
	return crit_value > math.random()
end

function InstantBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank, no_sound, already_ricocheted, critical_hit)
	if Network:is_client() and not blank and user_unit ~= managers.player:player_unit() then
		blank = true
	end

	local enable_ricochets = managers.player:has_category_upgrade("player", "ricochet_bullets")
	critical_hit = critical_hit or self:calculate_crit(weapon_unit, user_unit)
	
	local has_category = weapon_unit and alive(weapon_unit) and not weapon_unit:base().thrower_unit and weapon_unit:base().is_category
	if enable_ricochets and not already_ricocheted and user_unit and user_unit == managers.player:player_unit() and col_ray.unit then

		if has_category and weapon_unit:base():is_weapon_class("rapidfire") then
			local can_bounce_off = false

			--easier to understand and to add more conditions if desired
			if not weapon_unit:base()._can_shoot_through_shield and col_ray.unit:in_slot(managers.slot:get_mask("enemy_shield_check")) then
				can_bounce_off = true
			elseif not weapon_unit:base()._can_shoot_through_wall and col_ray.unit:in_slot(managers.slot:get_mask("world_geometry", "vehicles")) and (col_ray.body:has_ray_type(Idstring("ai_vision")) or col_ray.body:has_ray_type(Idstring("bulletproof"))) then
				can_bounce_off = true
			end

			if can_bounce_off then
				InstantBulletBase:on_ricochet(col_ray, weapon_unit, user_unit, damage, blank, no_sound, critical_hit)
			end
		end
	end

	local hit_unit = col_ray.unit
	local is_shield = hit_unit:in_slot(managers.slot:get_mask("enemy_shield_check")) and alive(hit_unit:parent())

	--more proper checks for knocking back a shield
	if alive(weapon_unit) and is_shield and weapon_unit:base()._shield_knock then
		local enemy_unit = hit_unit:parent()

		if enemy_unit:character_damage() and enemy_unit:character_damage().dead and not enemy_unit:character_damage():dead() then
			if enemy_unit:base():char_tweak() and not enemy_unit:base().is_phalanx and enemy_unit:base():char_tweak().damage.shield_knocked and not enemy_unit:character_damage():is_immune_to_shield_knockback() then
				local MIN_KNOCK_BACK = 200
				local KNOCK_BACK_CHANCE = 0.8
				local dmg_ratio = math.min(damage, MIN_KNOCK_BACK)
				dmg_ratio = dmg_ratio / MIN_KNOCK_BACK + 1

				local rand = math.random() * dmg_ratio

				if KNOCK_BACK_CHANCE < rand then
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
	end

	local play_impact_flesh = not hit_unit:character_damage() or not hit_unit:character_damage()._no_blood

	if hit_unit:damage() and managers.network:session() and col_ray.body:extension() and col_ray.body:extension().damage then
		local damage_body_extension = true
		local character_unit = nil

		if hit_unit:character_damage() then
			character_unit = hit_unit
		elseif is_shield and hit_unit:parent():character_damage() then
			character_unit = hit_unit:parent()
		end
		
		--if the unit hit is a character or a character's shield, do a friendly fire check before damaging the body extension that was hit
		if character_unit and character_unit:character_damage().is_friendly_fire and character_unit:character_damage():is_friendly_fire(user_unit) then
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

	if alive(weapon_unit) and hit_unit:character_damage() and hit_unit:character_damage().damage_bullet then
		local is_alive = not hit_unit:character_damage():dead()
		
		local pierce_armor = false
		if user_unit == managers.player:player_unit() then
			if has_category and weapon_unit:base():is_weapon_class("class_shotgun") then 
				local point_blank_range = managers.player:upgrade_value("class_shotgun","point_blank_basic",0)
				if point_blank_range > 0 then  --right now, basic and aced have the same proc range, but if you want to change that, this is where you'd do it
					if col_ray and col_ray.distance and (col_ray.distance <= point_blank_range) then 
						pierce_armor = true
						damage = damage * (1 + managers.player:upgrade_value("class_shotgun","point_blank_aced",0)) 
					end
				end
			end
		end
		
		
		pierce_armor = pierce_armor or weapon_unit:base()._use_armor_piercing
		
		if not blank then
			local knock_down = weapon_unit:base()._knock_down and weapon_unit:base()._knock_down > 0 and math.random() < weapon_unit:base()._knock_down
			result = self:give_impact_damage(col_ray, weapon_unit, user_unit, damage, pierce_armor, false, knock_down, weapon_unit:base()._stagger, weapon_unit:base()._variant, critical_hit)
		end

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

	return result
end

function InstantBulletBase:give_impact_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing, shield_knock, knock_down, stagger, variant, critical_hit)
	local action_data = {
		variant = variant or "bullet",
		damage = damage,
		weapon_unit = weapon_unit,
		attacker_unit = user_unit,
		col_ray = col_ray,
		armor_piercing = armor_piercing,
		shield_knock = shield_knock,
		origin = user_unit:position(),
		knock_down = knock_down,
		stagger = stagger,
		critical_hit = critical_hit
	}
	local defense_data = col_ray.unit:character_damage():damage_bullet(action_data)

	return defense_data
end

function FlameBulletBase:calculate_crit(weapon_unit, user_unit)
	if not user_unit or user_unit ~= managers.player:player_unit() then
		return nil
	end

	local crit_value = managers.player:critical_hit_chance()
	local has_category = weapon_unit and alive(weapon_unit) and not weapon_unit:base().thrower_unit and weapon_unit:base().is_category
	
	if has_category and weapon_unit:base():is_weapon_class("rapidfire") then
		crit_value = crit_value + managers.player:upgrade_value("weapon", "spray_and_pray_basic", 0)
		crit_value = crit_value + managers.player:upgrade_value("weapon", "prayers_answered", 0)
		
		local making_miracles_stacks = managers.player:get_property("making_miracles_stacks",0) --num stacks
		local making_miracles_crit_max = managers.player:upgrade_value("weapon","making_miracles_crit_cap",0) --max crit chance
		local making_miracles_crit_chance = managers.player:upgrade_value("weapon","making_miracles_basic",{0,0})[1] --chance per stack
		local making_miracles_crit_bonus = math.min(making_miracles_stacks * making_miracles_crit_chance,making_miracles_crit_max) --total applied bonus
		crit_value = crit_value + making_miracles_crit_bonus
	end
	
	
	--if critical_hit then
		--log("BOOM")
	--end
	
	return math.random() < crit_value
end

function FlameBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank)
	local hit_unit = col_ray.unit
	local play_impact_flesh = false
	local critical_hit = self:calculate_crit(weapon_unit, user_unit)

	if hit_unit:damage() and col_ray.body:extension() and col_ray.body:extension().damage then
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

	if hit_unit:character_damage() and hit_unit:character_damage().damage_fire then
		local is_alive = not hit_unit:character_damage():dead()
		result = self:give_fire_damage(col_ray, weapon_unit, user_unit, damage, nil, critical_hit)

		if result ~= "friendly_fire" then
			local is_dead = hit_unit:character_damage():dead()

			if weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.push_units then
				local push_multiplier = self:_get_character_push_multiplier(weapon_unit, is_alive and is_dead)

				managers.game_play_central:physics_push(col_ray, push_multiplier)
			end
		else
			play_impact_flesh = false
		end
	elseif weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.push_units then
		managers.game_play_central:physics_push(col_ray)
	end

	if play_impact_flesh then
		managers.game_play_central:play_impact_flesh({
			no_sound = true,
			col_ray = col_ray
		})
	end

	self:play_impact_sound_and_effects(weapon_unit, col_ray)

	return result
end

function FlameBulletBase:give_fire_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing, critical_hit)
	local fire_dot_data = nil

	if weapon_unit.base and weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.bullet_class == "FlameBulletBase" then
		fire_dot_data = weapon_unit:base()._ammo_data.fire_dot_data
	elseif weapon_unit.base and weapon_unit:base()._name_id then
		local weapon_name_id = weapon_unit:base()._name_id

		if tweak_data.weapon[weapon_name_id] and tweak_data.weapon[weapon_name_id].fire_dot_data then
			fire_dot_data = tweak_data.weapon[weapon_name_id].fire_dot_data
		end
	end

	local action_data = {
		variant = "fire",
		damage = damage,
		weapon_unit = weapon_unit,
		attacker_unit = user_unit,
		col_ray = col_ray,
		critical_hit = critical_hit,
		armor_piercing = armor_piercing,
		fire_dot_data = fire_dot_data
	}
	local defense_data = col_ray.unit:character_damage():damage_fire(action_data)

	return defense_data
end

function InstantExplosiveBulletBase:on_collision_server(position, normal, damage, user_unit, weapon_unit, owner_peer_id, owner_selection_index)
	local slot_mask = managers.slot:get_mask("explosion_targets")
	--local critical_hit = self:calculate_crit(weapon_unit, user_unit) i have this fully implemented, but commented out, if we ever want explosive bullet crits.
	managers.explosion:play_sound_and_effects(position, normal, self.RANGE, self.EFFECT_PARAMS)
	local params = {
		hit_pos = position,
		range = self.RANGE,
		collision_slotmask = slot_mask,
		curve_pow = self.CURVE_POW,
		damage = damage,
		player_damage = damage * self.PLAYER_DMG_MUL,
		ignore_unit = weapon_unit,
		user = user_unit,
		--critical_hit = critical_hit,
		owner = weapon_unit
	}

	local hit_units, splinters, results = managers.explosion:detect_and_give_dmg(params)
	local network_damage = math.ceil(damage * 163.84)

	managers.network:session():send_to_peers_synched("sync_explode_bullet", position, normal, math.min(16384, network_damage), owner_peer_id)

	if managers.network:session():local_peer():id() == owner_peer_id then
		local enemies_hit = (results.count_gangsters or 0) + (results.count_cops or 0)
		local enemies_killed = (results.count_gangster_kills or 0) + (results.count_cop_kills or 0)

		managers.statistics:shot_fired({
			hit = false,
			weapon_unit = weapon_unit
		})

		for i = 1, enemies_hit do
			managers.statistics:shot_fired({
				skip_bullet_count = true,
				hit = true,
				weapon_unit = weapon_unit
			})
		end

		local weapon_pass, weapon_type_pass, count_pass, all_pass = nil

		for achievement, achievement_data in pairs(tweak_data.achievement.explosion_achievements) do
			weapon_pass = not achievement_data.weapon or true
			weapon_type_pass = not achievement_data.weapon_type or weapon_unit:base() and weapon_unit:base().weapon_tweak_data and weapon_unit:base():is_category(achievement_data.weapon_type)
			count_pass = not achievement_data.count or achievement_data.count <= (achievement_data.kill and enemies_killed or enemies_hit)
			all_pass = weapon_pass and weapon_type_pass and count_pass

			if all_pass and achievement_data.award then
				managers.achievment:award(achievement_data.award)
			end
		end
	else
		local peer = managers.network:session():peer(owner_peer_id)
		local SYNCH_MIN = 0
		local SYNCH_MAX = 31
		local count_cops = math.clamp(results.count_cops, SYNCH_MIN, SYNCH_MAX)
		local count_gangsters = math.clamp(results.count_gangsters, SYNCH_MIN, SYNCH_MAX)
		local count_civilians = math.clamp(results.count_civilians, SYNCH_MIN, SYNCH_MAX)
		local count_cop_kills = math.clamp(results.count_cop_kills, SYNCH_MIN, SYNCH_MAX)
		local count_gangster_kills = math.clamp(results.count_gangster_kills, SYNCH_MIN, SYNCH_MAX)
		local count_civilian_kills = math.clamp(results.count_civilian_kills, SYNCH_MIN, SYNCH_MAX)

		managers.network:session():send_to_peer_synched(peer, "sync_explosion_results", count_cops, count_gangsters, count_civilians, count_cop_kills, count_gangster_kills, count_civilian_kills, owner_selection_index)
	end
end
function RaycastWeaponBase:_suppress_units(from_pos, direction, distance, slotmask, user_unit, suppr_mul)
	local tmp_to = Vector3()

	mvector3.set(tmp_to, mvector3.copy(direction))
	mvector3.multiply(tmp_to, distance)
	mvector3.add(tmp_to, mvector3.copy(from_pos))

	local cone_radius = distance / 4
	local enemies_in_cone = World:find_units(user_unit, "cone", from_pos, tmp_to, cone_radius, slotmask)
	local enemies_to_suppress = {}

	--draw the cone to see where it goes
	local draw_suppression_cone = false

	if draw_suppression_cone and user_unit == managers.player:player_unit() then
		local draw_duration = 0.1
		local new_brush = Draw:brush(Color.white:with_alpha(0.5), draw_duration)
		new_brush:cone(from_pos, tmp_to, cone_radius)
	end

	if #enemies_in_cone > 0 then
		for _, enemy in ipairs(enemies_in_cone) do
			if Network:is_server() or user_unit == managers.player:player_unit() or enemy == managers.player:player_unit() then --clients only allow the local player to suppress or be suppressed (so that NPC husks don't suppress each other)
				if not table.contains(enemies_to_suppress, enemy) and enemy.character_damage and enemy:character_damage() and enemy:character_damage().build_suppression then --valid enemy + has suppression function
					if not enemy:movement().cool or enemy:movement().cool and not enemy:movement():cool() then --is alerted or can't be alerted at all (player)
						if enemy:character_damage().is_friendly_fire and not enemy:character_damage():is_friendly_fire(user_unit) then --not in the same team as the shooter
							local obstructed = World:raycast("ray", from_pos, enemy:movement():m_head_pos(), "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", "ai_vision", "report") --imitating AI checking for visibility for things like shouting

							if not obstructed then
								table.insert(enemies_to_suppress, enemy)
							end
						end
					end
				end
			end
		end

		if #enemies_to_suppress > 0 then
			for _, enemy in ipairs(enemies_to_suppress) do
				local enemy_distance = mvector3.distance(from_pos, enemy:movement():m_head_pos())
				local dis_lerp_value = math.clamp(enemy_distance, 0, distance) / distance
				local total_suppression = self._suppression

				if suppr_mul then
					total_suppression = total_suppression * suppr_mul
				end

				total_suppression = math.lerp(total_suppression, 0, dis_lerp_value) --scale suppression downwards and linearly, becoming 0 at maximum allowed distance or past that

				local total_panic_chance = false

				if self._panic_suppression_chance then
					total_panic_chance = self._panic_suppression_chance

					local suppr_lerp_value = math.clamp(total_suppression, 0, 4.5) / 4.5 --4.5 is the highest suppression value allowed for players, that point means maximum panic base chance

					total_panic_chance = math.lerp(0, total_panic_chance, suppr_lerp_value)
				end

				if total_suppression > 0 then
					if draw_suppression_cone and enemy:contour() then
						enemy:contour():add("medic_heal")
					end

					enemy:character_damage():build_suppression(total_suppression, total_panic_chance)
				end
			end
		end
	end
end

--taser bullets for taser sentries (currently used in total cd only) 
local MIN_KNOCK_BACK = 200 --WHY ARE THESE LOCAL VARIABLES
local KNOCK_BACK_CHANCE = 0.8

ElectricBulletBase = ElectricBulletBase or clone(InstantBulletBase)
ElectricBulletBase.id = "electric"

function ElectricBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank, no_sound)
	local hit_unit = col_ray.unit
	local shield_knock = false
	local is_shield = hit_unit:in_slot(8) and alive(hit_unit:parent())
	

	if is_shield and not hit_unit:parent():character_damage():is_immune_to_shield_knockback() and weapon_unit then
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

function ElectricBulletBase:give_impact_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing, shield_knock, knock_down, stagger, variant)
	local action_data = {
		variant = variant or "light",
		damage = damage,
		weapon_unit = weapon_unit,
		attacker_unit = user_unit,
		col_ray = col_ray,
		armor_piercing = armor_piercing,
		shield_knock = shield_knock,
		origin = user_unit:position(),
		knock_down = knock_down,
		stagger = stagger
	}
	local defense_data
	if col_ray.unit.character_damage then
		if col_ray.unit:character_damage().damage_tase then 
			defense_data = col_ray.unit:character_damage():damage_tase(action_data)
		elseif col_ray.unit:character_damage().damage_bullet then 
			defense_data = col_ray.unit:character_damage():damage_bullet(action_data)
		end
	end

	return defense_data
end

function RaycastWeaponBase:is_heavy_weapon() --new function
	return self:weapon_tweak_data().IS_HEAVY_WEAPON
end

if deathvox:IsTotalCrackdownEnabled() then 

	function RaycastWeaponBase:add_ammo(ratio, add_amount_override)
		local function _add_ammo(ammo_base, ratio, add_amount_override)
			if ammo_base:get_ammo_max() == ammo_base:get_ammo_total() then
				return false, 0
			end

			local multiplier_min = 1
			local multiplier_max = 1

			if ammo_base._ammo_data and ammo_base._ammo_data.ammo_pickup_min_mul then
				multiplier_min = ammo_base._ammo_data.ammo_pickup_min_mul
			else
				multiplier_min = managers.player:upgrade_value("player", "pick_up_ammo_multiplier", 1)
				multiplier_min = multiplier_min + managers.player:upgrade_value("player", "pick_up_ammo_multiplier_2", 1) - 1
				multiplier_min = multiplier_min + managers.player:crew_ability_upgrade_value("crew_scavenge", 0)
				if self:is_heavy_weapon() then 
					multiplier_min = multiplier_min + managers.player:upgrade_value("weapon", "heavy_weapons_ammo_pickup_bonus",1) - 1 --this is the cd thingy, replace the name here. also this is the only change to this function
				end
			end

			if ammo_base._ammo_data and ammo_base._ammo_data.ammo_pickup_max_mul then
				multiplier_max = ammo_base._ammo_data.ammo_pickup_max_mul
			else
				multiplier_max = managers.player:upgrade_value("player", "pick_up_ammo_multiplier", 1)
				multiplier_max = multiplier_max + managers.player:upgrade_value("player", "pick_up_ammo_multiplier_2", 1) - 1
				multiplier_max = multiplier_max + managers.player:crew_ability_upgrade_value("crew_scavenge", 0)
				if self:is_heavy_weapon() then 
					multiplier_max = multiplier_max + managers.player:upgrade_value("weapon", "heavy_weapons_ammo_pickup_bonus",1) - 1
				end
			end

			local add_amount = add_amount_override
			local picked_up = true

			if not add_amount then
				local rng_ammo = math.lerp(ammo_base._ammo_pickup[1] * multiplier_min, ammo_base._ammo_pickup[2] * multiplier_max, math.random())
				picked_up = rng_ammo > 0
				add_amount = math.max(0, math.round(rng_ammo))
			end

			add_amount = math.floor(add_amount * (ratio or 1))

			ammo_base:set_ammo_total(math.clamp(ammo_base:get_ammo_total() + add_amount, 0, ammo_base:get_ammo_max()))

			return picked_up, add_amount
		end

		local picked_up, add_amount = nil
		picked_up, add_amount = _add_ammo(self, ratio, add_amount_override)

		if self.AKIMBO then
			local akimbo_rounding = self:get_ammo_total() % 2 + #self._fire_callbacks

			if akimbo_rounding > 0 then
				_add_ammo(self, nil, akimbo_rounding)
			end
		end

		for _, gadget in ipairs(self:get_all_override_weapon_gadgets()) do
			if gadget and gadget.ammo_base then
				local p, a = _add_ammo(gadget:ammo_base(), ratio, add_amount_override)
				picked_up = p or picked_up
				add_amount = add_amount + a
			end
		end

		return picked_up, add_amount
	end
end

