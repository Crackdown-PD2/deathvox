local mvec3_dot = mvector3.dot
local mvec3_set = mvector3.set
local mvec3_sub = mvector3.subtract
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_dir = mvector3.direction
local mvec3_l_sq = mvector3.length_sq
local mvec3_set_l = mvector3.set_length
local mvec3_add = mvector3.add
local mvec3_rand_orth = mvector3.random_orthogonal
local mvec3_cpy = mvector3.copy

local math_up = math.UP
local math_ceil = math.ceil
local math_floor = math.floor
local math_random = math.random
local math_pow = math.pow
local math_clamp = math.clamp
local math_lerp = math.lerp
local math_DOWN = math.DOWN

local table_insert = table.insert
local table_remove = table.remove
local table_size = table.size

local pairs_g = pairs
local next_g = next
local tostring_g = tostring
local alive_g = alive

local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local old_group_misc_data = GroupAIStateBase._init_misc_data
function GroupAIStateBase:_init_misc_data()
	old_group_misc_data(self)
	self._nr_important_cops = 8
	self._special_unit_types = {
		tank = true,
		spooc = true,
		shield = true,
		taser = true,
		boom = true,
		medic = true,
		ass_sniper = true,
		phalanx_minion = true
	}
end

local old_group_base = GroupAIStateBase.on_simulation_started
function GroupAIStateBase:on_simulation_started()
	old_group_base(self)
	self._nr_important_cops = 8
	self._special_unit_types = {
		tank = true,
		spooc = true,
		shield = true,
		taser = true,
		boom = true,
		medic = true,
		ass_sniper = true,
		phalanx_minion = true
	}	
end

function GroupAIStateBase:_check_assault_panic_chatter()
	if self._t and self._last_killed_cop_t and self._t - self._last_killed_cop_t < math.random(1, 3.5) then
		return true
	end
	
	return
end

function GroupAIStateBase:_determine_objective_for_criminal_AI(unit)
	local objective, closest_dis, closest_player = nil
	local ai_pos = unit:movement():m_pos()

	for pl_key, player in pairs_g(self:all_player_criminals()) do
		if player.status ~= "dead" then
			local my_dis = mvec3_dis_sq(ai_pos, player.m_pos)

			if not closest_dis or my_dis < closest_dis then
				closest_dis = my_dis
				closest_player = player
			end
		end
	end

	if closest_player then
		objective = {
			scan = true,
			is_default = true,
			type = "follow",
			follow_unit = closest_player.unit
		}
	end

	if not objective then
		local mov_ext = unit:movement()

		if mov_ext._should_stay then
			mov_ext:set_should_stay(false)
		end

		if self:is_ai_trade_possible() then
			local hostage = managers.trade:get_best_hostage(ai_pos)

			if hostage and mvec3_dis_sq(ai_pos, hostage.m_pos) > 250000 then
				objective = {
					scan = true,
					type = "free",
					haste = "run",
					nav_seg = hostage.tracker:nav_segment()
				}
			end
		end
	end

	return objective
end

function GroupAIStateBase:chk_say_teamAI_combat_chatter(unit)
	if not self._assault_mode or not self:is_detection_persistent() then
		return
	end

	local t = self._t

	local frequency_lerp = self._drama_data.amount
	local delay_tweak = tweak_data.sound.criminal_sound.combat_callout_delay
	local delay = math_lerp(delay_tweak[1], delay_tweak[2], frequency_lerp)
	local delay_t = self._teamAI_last_combat_chatter_t + delay

	if t < delay_t then
		return
	end

	self._teamAI_last_combat_chatter_t = t

	local frequency_lerp_clamp = math_clamp(frequency_lerp^2, 0, 1)
	local chance_tweak = tweak_data.sound.criminal_sound.combat_callout_chance
	local chance = math_lerp(chance_tweak[1], chance_tweak[2], frequency_lerp_clamp)

	if chance < math_random() then
		return
	end

	unit:sound():say("g90", true, true)
end

function GroupAIStateBase:update(t, dt)
	self._t = t

	self:_upd_criminal_suspicion_progress()
	self:_claculate_drama_value()
	--self:_draw_current_logics()
	--self:_draw_enemy_importancies()

	if self._draw_drama then
		self:_debug_draw_drama(t)
	end
	
	if not Global.game_settings.single_player then
		if Network:is_server() then
			local new_value = 8 / table.size(self:all_player_criminals()) 

			self._nr_important_cops = new_value
		end
	end

	self:_upd_debug_draw_attentions()
	self:upd_team_AI_distance()
end

function GroupAIStateBase:_draw_current_logics()
	for key, data in pairs(self._police) do
		if data.unit:brain() and data.unit:brain().is_current_logic then
			local brain = data.unit:brain()
			
			if brain:is_current_logic("attack") then
				local draw_duration = 0.1
				local new_brush = Draw:brush(Color.red:with_alpha(1), draw_duration)
				new_brush:sphere(data.unit:movement():m_head_pos(), 20)
			elseif brain:is_current_logic("base") then
				local draw_duration = 0.1
				local new_brush = Draw:brush(Color.white:with_alpha(0.5), draw_duration)
				new_brush:sphere(data.unit:movement():m_head_pos(), 20)
			elseif brain:is_current_logic("idle") then
				local draw_duration = 0.1
				local new_brush = Draw:brush(Color.green:with_alpha(0.5), draw_duration)
				new_brush:sphere(data.unit:movement():m_head_pos(), 20)
			elseif brain:is_current_logic("sniper") then
				local draw_duration = 0.1
				local new_brush = Draw:brush(Color.red:with_alpha(0.1), draw_duration)
				new_brush:sphere(data.unit:movement():m_head_pos(), 20)
			elseif brain:is_current_logic("travel") then
				local draw_duration = 0.1
				local new_brush = Draw:brush(Color.yellow:with_alpha(0.5), draw_duration)
				new_brush:sphere(data.unit:movement():m_head_pos(), 20)
			end
		end
	end
end

function GroupAIStateBase:on_wgt_report_empty(u_key)
	if u_key then
		local e_data = self._police[u_key]

		if e_data and e_data.importance > 0 then
			--log("you're a cock")
			
			e_data.importance = 0
			
			for c_key, c_data in pairs_g(self._player_criminals) do
				local imp_keys = c_data.important_enemies
				
				for i = 1, #imp_keys do
					local test_e_key = imp_keys[i]

					if test_e_key == u_key then
						table_remove(imp_keys, i)
						table_remove(c_data.important_dis, i)

						break
					end
				end
			end
			
			e_data.unit:brain():set_important(nil)
		end
	end
end 

function GroupAIStateBase:on_enemy_logic_intimidated(u_key)
	if u_key then
		local e_data = self._police[u_key]

		if e_data and e_data.importance > 0 then
			--log("you're a cock")
			
			e_data.importance = 0
			
			for c_key, c_data in pairs_g(self._player_criminals) do
				local imp_keys = c_data.important_enemies
				
				for i = 1, #imp_keys do
					local test_e_key = imp_keys[i]

					if test_e_key == u_key then
						table_remove(imp_keys, i)
						table_remove(c_data.important_dis, i)

						break
					end
				end
			end
			
			e_data.unit:brain():set_important(nil)
		end
	end
end

function GroupAIStateBase:set_importance_weight(u_key, wgt_report)
	if not wgt_report or #wgt_report == 0 then
		self:on_wgt_report_empty(u_key)
		
		return
	end

	local t_rem = table_remove
	local t_ins = table_insert
	local max_nr_imp = self._nr_important_cops
	local imp_adj = 0
	local criminals = self._player_criminals
	

	for i_dis_rep = #wgt_report - 1, 1, -2 do
		local c_key = wgt_report[i_dis_rep]
		local c_dis = wgt_report[i_dis_rep + 1]
		local c_record = criminals[c_key]
		local imp_enemies = c_record.important_enemies
		local imp_dis = c_record.important_dis
		local was_imp = nil

		for i_imp = #imp_enemies, 1, -1 do
			if imp_enemies[i_imp] == u_key then
				t_rem(imp_enemies, i_imp)
				t_rem(imp_dis, i_imp)

				was_imp = true

				break
			end
		end

		local i_imp = #imp_dis

		while i_imp > 0 do
			if imp_dis[i_imp] < c_dis then
				break
			end

			i_imp = i_imp - 1
		end

		if i_imp < max_nr_imp then
			i_imp = i_imp + 1

			while max_nr_imp <= #imp_enemies do
				local dump_e_key = imp_enemies[#imp_enemies]

				self:_adjust_cop_importance(dump_e_key, -1)
				t_rem(imp_enemies)
				t_rem(imp_dis)
			end

			t_ins(imp_enemies, i_imp, u_key)
			t_ins(imp_dis, i_imp, c_dis)

			if not was_imp then
				imp_adj = imp_adj + 1
			end
		elseif was_imp then
			imp_adj = imp_adj - 1
		end
	end

	if imp_adj ~= 0 then
		self:_adjust_cop_importance(u_key, imp_adj)
	end
end

function GroupAIStateBase:_draw_enemy_importancies()
	for e_key, e_data in pairs_g(self._police) do
		local imp = e_data.importance

		while imp > 0 do
			local tint_r = 1
			local tint_g = 1
			local tint_b = 1
			
			if e_data.unit:brain().active_searches and next(e_data.unit:brain().active_searches) then
				tint_g = tint_g - 0.5
			end
			
			if e_data.unit:brain()._logic_data and e_data.unit:brain()._logic_data.internal_data then
				if e_data.unit:brain()._logic_data.internal_data.processing_cover_path then
					tint_g = tint_g - 0.5
				end
				
				if e_data.unit:brain()._logic_data.internal_data.want_to_take_cover and e_data.unit:brain()._logic_data.internal_data.in_cover then
					tint_r = 0
				end
			end
			
			Application:draw_sphere(e_data.m_pos, 50 * imp, tint_r, tint_g, tint_b)

			imp = imp - 1
		end

		if e_data.unit:brain()._important then
			local tint_r = 0
			local tint_g = 1
			local tint_b = 0
			
			if e_data.unit:brain().active_searches and next(e_data.unit:brain().active_searches) then
				tint_b = tint_b + 0.5
			end
			
			if e_data.unit:brain()._logic_data and e_data.unit:brain()._logic_data.internal_data then
				if e_data.unit:brain()._logic_data.internal_data.processing_cover_path then
					tint_b = tint_b + 0.5
				end
				
				if e_data.unit:brain()._logic_data.internal_data.want_to_take_cover and e_data.unit:brain()._logic_data.internal_data.in_cover then
					tint_g = 0
					tint_r = 1
				end
			end
			
			
			Application:draw_cylinder(e_data.m_pos, e_data.m_pos + math_up * 300, 35, tint_r, tint_g, tint_b)
		end
	end

	for c_key, c_data in pairs_g(self._player_criminals) do
		local imp_enemies = c_data.important_enemies

		for imp, e_key in ipairs(imp_enemies) do
			local tint = math_clamp(1 - imp / self._nr_important_cops, 0, 1)

			Application:draw_cylinder(self._police[e_key].m_pos, c_data.m_pos, 10, tint, 0, 0, 1 - tint)
		end
	end
end

function GroupAIStateBase:chk_area_leads_to_enemy(start_nav_seg_id, test_nav_seg_id, enemy_is_criminal)
	local enemy_areas = {}

	for c_key, c_data in pairs(enemy_is_criminal and self._criminals or self._police) do
		enemy_areas[c_data.tracker:nav_segment()] = true
	end

	local all_nav_segs = managers.navigation._nav_segments
	local found_nav_segs = {
		[start_nav_seg_id] = true,
		[test_nav_seg_id] = true
	}
	local to_search_nav_segs = {
		test_nav_seg_id
	}

	repeat
		local chk_nav_seg_id = table.remove(to_search_nav_segs)
		local chk_nav_seg = all_nav_segs[chk_nav_seg_id]

		if enemy_areas[chk_nav_seg_id] then
			--log("executing")
			return true
		end

		local neighbours = chk_nav_seg.neighbours

		for neighbour_seg_id, door_list in pairs(neighbours) do
			if not all_nav_segs[neighbour_seg_id].disabled and not found_nav_segs[neighbour_seg_id] then
				found_nav_segs[neighbour_seg_id] = true

				table.insert(to_search_nav_segs, neighbour_seg_id)
			end
		end
	until #to_search_nav_segs == 0
end

function GroupAIStateBase:on_enemy_unregistered(unit)
	if self:is_unit_in_phalanx_minion_data(unit:key()) then
		self:unregister_phalanx_minion(unit:key())
		CopLogicPhalanxMinion:chk_should_breakup()
		CopLogicPhalanxMinion:chk_should_reposition()
	end

	self._police_force = self._police_force - 1
	local u_key = unit:key()

	self:_clear_character_criminal_suspicion_data(u_key)

	if not Network:is_server() then
		return
	end

	local e_data = self._police[u_key]

	if e_data.importance > 0 then
		for c_key, c_data in pairs(self._player_criminals) do
			local imp_keys = c_data.important_enemies

			for i, test_e_key in ipairs(imp_keys) do
				if test_e_key == u_key then
					table.remove(imp_keys, i)
					table.remove(c_data.important_dis, i)

					break
				end
			end
		end
	end

	for crim_key, record in pairs(self._ai_criminals) do
		record.unit:brain():on_cop_neutralized(u_key)
	end

	local unit_type = unit:base()._tweak_table
	local is_special = unit:movement()._tweak_data.is_special_unit

	if self._special_unit_types[unit_type] or is_special then
		if is_special then
			self:unregister_special_unit(u_key, is_special)
		else
			self:unregister_special_unit(u_key, unit_type)
		end
	end

	local dead = unit:character_damage():dead()

	if e_data.group then
		self:_remove_group_member(e_data.group, u_key, dead)
		self._last_killed_cop_t = self._t
		if dead and self._task_data and self._task_data.assault and self._task_data.assault.active then
			self:_voice_friend_dead(e_data.group)	
		end
	end

	if e_data.assigned_area and dead then
		local spawn_point = unit:unit_data().mission_element

		if spawn_point then
			local spawn_pos = spawn_point:value("position")
			local u_pos = e_data.m_pos

			if mvector3.distance(spawn_pos, u_pos) < 700 and math.abs(spawn_pos.z - u_pos.z) < 300 then
				local found = nil

				for area_id, area_data in pairs(self._area_data) do
					local area_spawn_points = area_data.spawn_points

					if area_spawn_points then
						for _, sp_data in ipairs(area_spawn_points) do
							if sp_data.spawn_point == spawn_point then
								found = true
								sp_data.delay_t = math.max(sp_data.delay_t, self._t + math.random(30, 60))

								break
							end
						end

						if found then
							break
						end
					end

					local area_spawn_points = area_data.spawn_groups

					if area_spawn_points then
						for _, sp_data in ipairs(area_spawn_points) do
							if sp_data.spawn_point == spawn_point then
								found = true
								sp_data.delay_t = math.max(sp_data.delay_t, self._t + math.random(30, 60))

								break
							end
						end

						if found then
							break
						end
					end
				end
			end
		end
	end
end

function GroupAIStateBase:on_enemy_registered(unit)
	if self._anticipated_police_force > 0 then
		self._anticipated_police_force = self._anticipated_police_force - 1
	else
		self._police_force = self._police_force + 1
	end

	local unit_type = unit:base()._tweak_table
	local is_special = unit:movement()._tweak_data.is_special_unit
	
	if is_special then
		
	end
	if self._special_unit_types[unit_type] or is_special then
		if is_special then
			self:register_special_unit(unit:key(), is_special)
		else
			if unit_type == "phalanx_minion" and not unit:base().is_phalanx then
				self:register_special_unit(unit:key(), "shield")
			else
				self:register_special_unit(unit:key(), unit_type)
			end
		end
	end

	if Network:is_client() then
		unit:movement():set_team(self._teams[tweak_data.levels:get_default_team_ID(unit:base():char_tweak().access == "gangster" and "gangster" or "combatant")])
	end
end

function GroupAIStateBase:unregister_special_unit(u_key, category_name)
	local category = self._special_units[category_name]

	if category_name == "phalanx_minion" and self._special_units["shield"] and self._special_units["shield"][u_key] then
		self._special_units["shield"][u_key] = nil

		if not next(self._special_units["shield"]) then
			self._special_units["shield"] = nil
		end
	else
		if category then
			category[u_key] = nil

			if not next(category) then
				self._special_units[category_name] = nil
			end
		end
	end
end

function GroupAIStateBase:propagate_alert(alert_data)
	if managers.network:session() and Network and not Network:is_server() then
		managers.network:session():send_to_host("propagate_alert", alert_data[1], alert_data[2], alert_data[3], alert_data[4], alert_data[5], alert_data[6])

		return
	end

	local nav_manager = managers.navigation
	local access_func = nav_manager.check_access
	local alert_type = alert_data[1]
	local all_listeners = self._alert_listeners
	local listeners_by_type = all_listeners[alert_type]

	if listeners_by_type then
		local proximity_chk_func = nil
		local alert_epicenter = alert_data[2]

		if alert_epicenter then
			local alert_rad_sq = alert_data[3] * alert_data[3]
			if self._enemy_weapons_hot then
				alert_rad_sq = 4500 * 4500
			end


			function proximity_chk_func(listener_pos)
				return mvec3_dis_sq(alert_epicenter, listener_pos) < alert_rad_sq
			end
		else

			function proximity_chk_func()
				return true
			end
		end

		local alert_filter = alert_data[4]
		local clbks = nil

		for filter_str, listeners_by_type_and_filter in pairs(listeners_by_type) do
			local key, listener = next(listeners_by_type_and_filter, nil)
			local filter_num = listener.filter

			if access_func(nav_manager, filter_num, alert_filter, nil) then
				for id, listener in pairs(listeners_by_type_and_filter) do
					if proximity_chk_func(listener.m_pos) then
						clbks = clbks or {}

						table.insert(clbks, listener.clbk)
					end
				end
			end
		end

		if clbks then
			for _, clbk in ipairs(clbks) do
				clbk(alert_data)
			end
		end
	end
end

local invalid_player_bot_warp_states = {
	jerry1 = true,
	jerry2 = true,
	driving = true
}

local teleport_SO_anims = {
	e_so_teleport_var1 = true,
	e_so_teleport_var2 = true,
	e_so_teleport_var3 = true
}

function GroupAIStateBase:upd_team_AI_distance()
	if not Network:is_server() then
		return
	end

	local t = self._t
	local check_t = self._team_ai_dist_t

	if check_t and t < check_t then
		return
	end

	self._team_ai_dist_t = t + 1

	if not self:team_ai_enabled() then
		return
	end

	local ai_criminals = self:all_AI_criminals()

	if not next_g(ai_criminals) then
		return
	end

	local player_criminals = self:all_player_criminals()

	if not next_g(player_criminals) then
		return
	end

	local teleport_distance = tweak_data.team_ai.stop_action.teleport_distance * tweak_data.team_ai.stop_action.teleport_distance
	local nav_manager = managers.navigation
	local find_cover_f = nav_manager.find_cover_in_nav_seg_3
	local search_coarse_f = nav_manager.search_coarse

	for ai_key, ai in pairs_g(ai_criminals) do
		local unit = ai.unit
		local ai_mov_ext = unit:movement()

		if not ai_mov_ext:cool() then
			local objective = unit:brain():objective()
			local has_warp_objective = nil

			if objective then
				if objective.path_style == "warp" or teleport_SO_anims[objective.action]then
					has_warp_objective = true
				else
					local followup = objective.followup_objective

					if followup then
						if followup.path_style == "warp" or teleport_SO_anims[followup.action] then
							has_warp_objective = true
						end
					end
				end
			end

			if not has_warp_objective then
				if not ai_mov_ext:chk_action_forbidden("walk") then
					local bot_pos = ai.m_pos
					local valid_players = {}

					for _, player in pairs_g(self:all_player_criminals()) do
						if player.status ~= "dead" then
							local distance = mvec3_dis_sq(bot_pos, player.m_pos)

							if distance > teleport_distance then
								valid_players[#valid_players + 1] = {player, distance}
							else
								valid_players = {}

								break
							end
						end
					end

					local closest_distance, closest_player, closest_tracker = nil
					local ai_tracker, ai_access = ai.tracker, ai.so_access

					for i = 1, #valid_players do
						local player = valid_players[i][1]
						local tracker = player.tracker

						if not tracker:obstructed() and not tracker:lost() then
							local player_unit = player.unit
							local player_mov_ext = player_unit:movement()

							if not player_mov_ext:zipline_unit() then
								local player_state = player_mov_ext:current_state_name()

								if not invalid_player_bot_warp_states[player_state] then
									local in_air = nil

									if player_unit:base().is_local_player then
										in_air = player_mov_ext:in_air() and true
									else
										in_air = player_mov_ext._in_air and true
									end

									if not in_air then
										local distance = valid_players[i][2]

										if not closest_distance or distance < closest_distance then
											local params = {
												from_tracker = ai_tracker,
												to_seg = tracker:nav_segment(),
												access = {
													"walk"
												},
												id = "warp_coarse_check" .. tostring_g(ai_key),
												access_pos = ai_access
											}

											local can_path = search_coarse_f(nav_manager, params) and true

											if can_path then
												closest_distance = distance
												closest_player = player
												closest_tracker = tracker
											end
										end
									end
								end
							end
						end
					end

					if closest_player then
						local near_cover_point = find_cover_f(nav_manager, closest_tracker:nav_segment(), 500, closest_tracker:field_position())
						local position = near_cover_point and near_cover_point[1] or closest_player.m_pos
						local action_desc = {
							body_part = 1,
							type = "warp",
							position = mvec3_cpy(position)
						}

						ai_mov_ext:action_request(action_desc)
					end
				end
			end
		end
	end
end

function GroupAIStateBase:_merge_coarse_path_by_area(coarse_path)
	local i_nav_seg = #coarse_path
	local last_area = nil

	while i_nav_seg > 0 do
		if #coarse_path > 2 then
			local nav_seg = coarse_path[i_nav_seg][1]
			local area = self:get_area_from_nav_seg_id(nav_seg)

			if last_area and last_area == area then
				table.remove(coarse_path, i_nav_seg)
			else
				last_area = area
			end
		end

		i_nav_seg = i_nav_seg - 1
	end

	--fug pls (i did it hoxi) 
end

function GroupAIStateBase:queue_smoke_grenade(id, detonate_pos, shooter_pos, duration, ignore_control, flashbang)
	self._smoke_grenades = self._smoke_grenades or {}
	local data = {
		id = id,
		detonate_pos = detonate_pos,
		shooter_pos = shooter_pos,
		duration = duration,
		ignore_control = ignore_control,
		flashbang = flashbang
	}
	self._smoke_grenades[id] = data
end

function GroupAIStateBase:detonate_world_smoke_grenade(id)
	self._smoke_grenades = self._smoke_grenades or {}

	if not self._smoke_grenades[id] then
		--Application:error("Could not detonate smoke grenade as it was not queued!", id)

		return
	end

	local data = self._smoke_grenades[id]

	if data.flashbang then
		if Network:is_client() then
			return
		end

		local det_pos = data.detonate_pos
		local ray_to = mvector3.copy(det_pos) + math.UP * 5

		mvector3.set_z(ray_to, ray_to.z - 50)

		local ground_ray = World:raycast("ray", det_pos, ray_to, "slot_mask", managers.slot:get_mask("world_geometry"))

		if ground_ray then
			det_pos = ground_ray.hit_position
			mvector3.set_z(det_pos, det_pos.z + 3)
			data.detonate_pos = det_pos
		end

		local rotation = Rotation(math.random() * 360, 0, 0)
		local flash_grenade = World:spawn_unit(Idstring("units/payday2/weapons/wpn_frag_flashbang/wpn_frag_flashbang"), det_pos, rotation)
		local shoot_from_pos = data.shooter_pos or det_pos
		flash_grenade:base():activate(shoot_from_pos, data.duration)

		self._smoke_grenades[id] = nil
	else
		data.duration = data.duration == 0 and 15 or data.duration
		local det_pos = data.detonate_pos
		local ray_to = mvector3.copy(det_pos) + math.UP * 5

		mvector3.set_z(ray_to, ray_to.z - 50)

		local ground_ray = World:raycast("ray", det_pos, ray_to, "slot_mask", managers.slot:get_mask("world_geometry"))

		if ground_ray then
			det_pos = ground_ray.hit_position
			mvector3.set_z(det_pos, det_pos.z + 3)
			data.detonate_pos = det_pos
		end

		local rotation = Rotation(math.random() * 360, 0, 0)
		local smoke_grenade = World:spawn_unit(Idstring("units/weapons/smoke_grenade_quick/smoke_grenade_quick"), det_pos, rotation)
		local shoot_from_pos = data.shooter_pos or det_pos
		smoke_grenade:base():activate(shoot_from_pos, data.duration)

		managers.groupai:state():teammate_comment(nil, "g40x_any", det_pos, true, 2000, false)

		data.grenade = smoke_grenade
		self._smoke_end_t = Application:time() + data.duration
	end
end

function GroupAIStateBase:sync_smoke_grenade(detonate_pos, shooter_pos, duration, flashbang)
	self._smoke_grenades = self._smoke_grenades or {}
	local id = #self._smoke_grenades

	self:queue_smoke_grenade(id, detonate_pos, shooter_pos, duration, true, flashbang)
	self:detonate_world_smoke_grenade(id)
end

function GroupAIStateBase:sync_smoke_grenade_kill()
	if self._smoke_grenades then
		for id, data in pairs(self._smoke_grenades) do
			if alive(data.grenade) and data.grenade:base() and data.grenade:base().preemptive_kill then
				data.grenade:base():preemptive_kill()
			end
		end

		self._smoke_grenades = {}
		self._smoke_end_t = nil
	end
end

function GroupAIStateBase:smoke_and_flash_grenades()
	return self._smoke_grenades
end

function GroupAIStateBase:criminal_spotted(unit)
	local u_key = unit:key()
	local u_sighting = self._criminals[u_key]

	u_sighting.undetected = nil
	u_sighting.det_t = self._t

	u_sighting.tracker:m_position(u_sighting.pos)

	local seg = u_sighting.tracker:nav_segment()
	u_sighting.seg = seg

	local prev_area = u_sighting.area
	local area = nil

	if prev_area and prev_area.nav_segs[seg] then
		area = prev_area
	else
		area = self:get_area_from_nav_seg_id(seg)
	end

	if prev_area ~= area then
		u_sighting.area = area

		if prev_area then
			prev_area.criminal.units[u_key] = nil
		end

		area.criminal.units[u_key] = u_sighting
	end

	if area.is_safe then
		area.is_safe = nil

		self:_on_area_safety_status(area, {
			reason = "criminal",
			record = u_sighting
		})
	end
end

function GroupAIStateBase:on_criminal_nav_seg_change(unit, nav_seg_id)
	local u_key = unit:key()
	local u_sighting = self._criminals[u_key]

	if not u_sighting then
		return
	end

	local seg = nav_seg_id

	u_sighting.seg = seg

	local prev_area = u_sighting.area
	local area = nil

	if prev_area and prev_area.nav_segs[seg] then
		area = prev_area
	else
		area = self:get_area_from_nav_seg_id(seg)
	end

	if prev_area ~= area then
		u_sighting.area = area

		if prev_area then
			prev_area.criminal.units[u_key] = nil
		end

		area.criminal.units[u_key] = u_sighting
	end
end

function GroupAIStateBase:on_criminal_suspicion_progress(u_suspect, u_observer, status, client_id)
	if not self._ai_enabled or not self._whisper_mode or self._stealth_hud_disabled then
		return
	end

	local ignore_suspicion = u_observer:brain() and u_observer:brain()._ignore_suspicion
	local observer_is_dead = u_observer:character_damage() and u_observer:character_damage():dead()

	if ignore_suspicion or observer_is_dead then
		return
	end

	local obs_key = u_observer:key()

	if managers.groupai:state():all_AI_criminals()[obs_key] then
		return
	end

	local susp_data = self._suspicion_hud_data
	local susp_key = u_suspect and u_suspect:key()

	local function _sync_status(sync_status_code)
		if Network:is_server() and managers.network:session() then
			if client_id then
				managers.network:session():send_to_peers_synched_except(client_id, "suspicion_hud", u_observer, sync_status_code)
			else
				managers.network:session():send_to_peers_synched("suspicion_hud", u_observer, sync_status_code)
			end
		end
	end

	local obs_susp_data = susp_data[obs_key]

	if status == "called" then
		if obs_susp_data then
			if status == obs_susp_data.status then
				return
			else
				obs_susp_data.suspects = nil
			end
		else
			local icon_id = "susp1" .. tostring(obs_key)
			local icon_pos = self._create_hud_suspicion_icon(obs_key, u_observer, "wp_calling_in", tweak_data.hud.suspicion_color, icon_id)
			obs_susp_data = {
				u_observer = u_observer,
				icon_id = icon_id,
				icon_pos = icon_pos
			}
			susp_data[obs_key] = obs_susp_data
		end

		managers.hud:change_waypoint_icon(obs_susp_data.icon_id, "wp_calling_in")
		managers.hud:change_waypoint_arrow_color(obs_susp_data.icon_id, tweak_data.hud.detected_color)

		if obs_susp_data.icon_id2 then
			managers.hud:remove_waypoint(obs_susp_data.icon_id2)

			obs_susp_data.icon_id2 = nil
			obs_susp_data.icon_pos2 = nil
		end

		obs_susp_data.status = "called"
		obs_susp_data.alerted = true
		obs_susp_data.expire_t = self._t + 8
		obs_susp_data.persistent = true

		_sync_status(4)
	elseif status == "calling" then
		if obs_susp_data then
			if status == obs_susp_data.status then
				return
			else
				obs_susp_data.suspects = nil
			end
		else
			local icon_id = "susp1" .. tostring(obs_key)
			local icon_pos = self._create_hud_suspicion_icon(obs_key, u_observer, "wp_calling_in", tweak_data.hud.detected_color, icon_id)
			obs_susp_data = {
				u_observer = u_observer,
				icon_id = icon_id,
				icon_pos = icon_pos
			}
			susp_data[obs_key] = obs_susp_data
		end

		if not obs_susp_data.icon_id2 then
			local hazard_icon_id = "susp2" .. tostring(obs_key)
			local hazard_icon_pos = self._create_hud_suspicion_icon(obs_key, u_observer, "wp_calling_in_hazard", tweak_data.hud.detected_color, hazard_icon_id)
			obs_susp_data.icon_id2 = hazard_icon_id
			obs_susp_data.icon_pos2 = hazard_icon_pos
		end

		managers.hud:change_waypoint_icon(obs_susp_data.icon_id, "wp_calling_in")
		managers.hud:change_waypoint_arrow_color(obs_susp_data.icon_id, tweak_data.hud.detected_color)
		managers.hud:change_waypoint_icon(obs_susp_data.icon_id2, "wp_calling_in_hazard")
		managers.hud:change_waypoint_arrow_color(obs_susp_data.icon_id2, tweak_data.hud.detected_color)

		obs_susp_data.status = "calling"
		obs_susp_data.alerted = true

		_sync_status(3)
	elseif status == true or status == "call_interrupted" then
		if obs_susp_data then
			if obs_susp_data.status == status then
				return
			else
				obs_susp_data.suspects = nil
			end
		else
			local icon_id = "susp1" .. tostring(obs_key)
			local icon_pos = self._create_hud_suspicion_icon(obs_key, u_observer, "wp_detected", tweak_data.hud.detected_color, icon_id)
			obs_susp_data = {
				u_observer = u_observer,
				icon_id = icon_id,
				icon_pos = icon_pos
			}
			susp_data[obs_key] = obs_susp_data
		end

		managers.hud:change_waypoint_icon(obs_susp_data.icon_id, "wp_detected")
		managers.hud:change_waypoint_arrow_color(obs_susp_data.icon_id, tweak_data.hud.detected_color)

		if obs_susp_data.icon_id2 then
			managers.hud:remove_waypoint(obs_susp_data.icon_id2)

			obs_susp_data.icon_id2 = nil
			obs_susp_data.icon_pos2 = nil
		end

		obs_susp_data.status = status
		obs_susp_data.alerted = true

		_sync_status(2)
	elseif not status then
		if obs_susp_data then
			if obs_susp_data.suspects and susp_key then
				obs_susp_data.suspects[susp_key] = nil

				if not next(obs_susp_data.suspects) then
					obs_susp_data.suspects = nil
				end
			end

			if not susp_key or not obs_susp_data.alerted and (not obs_susp_data.suspects or not next(obs_susp_data.suspects)) then
				managers.hud:remove_waypoint(obs_susp_data.icon_id)

				if obs_susp_data.icon_id2 then
					managers.hud:remove_waypoint(obs_susp_data.icon_id2)
				end

				susp_data[obs_key] = nil

				_sync_status(0)
			end
		end
	else
		if obs_susp_data then
			if obs_susp_data.alerted then
				return
			end

			_sync_status(1)
		elseif not obs_susp_data then
			local icon_id = "susp1" .. tostring(obs_key)
			local icon_pos = self._create_hud_suspicion_icon(obs_key, u_observer, "wp_suspicious", tweak_data.hud.suspicion_color, icon_id)
			obs_susp_data = {
				u_observer = u_observer,
				icon_id = icon_id,
				icon_pos = icon_pos
			}
			susp_data[obs_key] = obs_susp_data

			managers.hud:change_waypoint_icon(obs_susp_data.icon_id, "wp_suspicious")
			managers.hud:change_waypoint_arrow_color(obs_susp_data.icon_id, tweak_data.hud.suspicion_color)

			if obs_susp_data.icon_id2 then
				managers.hud:remove_waypoint(obs_susp_data.icon_id2)

				obs_susp_data.icon_id2 = nil
				obs_susp_data.icon_pos2 = nil
			end

			_sync_status(1)
		end

		if susp_key then
			obs_susp_data.suspects = obs_susp_data.suspects or {}

			if obs_susp_data.suspects[susp_key] then
				obs_susp_data.suspects[susp_key].status = status
			else
				obs_susp_data.suspects[susp_key] = {
					status = status,
					u_suspect = u_suspect
				}
			end
		end
	end
end

function GroupAIStateBase:register_AI_attention_object(unit, handler, nav_tracker, team, SO_access)
	local actually_remove_instead = nil

	if not self:whisper_mode() then
		if not nav_tracker and not unit:vehicle_driving() or unit:in_slot(1) --[[or unit:in_slot(17) and unit:character_damage()]] then
			actually_remove_instead = true
		end
	end

	local u_key = unit:key()

	if actually_remove_instead then
		self._attention_objects.all[u_key] = {
			handler = handler
		}

		local handler_data = deep_clone(handler:attention_data())

		self:store_removed_attention_object(u_key, unit, handler, handler_data)

		for attention_id, _ in pairs_g(handler_data) do
			handler:remove_attention(attention_id)
		end
	else
		self._attention_objects.all[u_key] = {
			unit = unit,
			handler = handler,
			nav_tracker = nav_tracker,
			team = team,
			SO_access = SO_access
		}

		self:on_AI_attention_changed(u_key)

		if handler._is_extension then
			local att_obj_upd_state = true

			if not nav_tracker and not unit:vehicle_driving() and not unit:carry_data() then
				local base_ext = unit:base()

				if not base_ext then
					if unit:in_slot(1) then
						att_obj_upd_state = false
					end
				elseif base_ext.is_security_camera then
					if base_ext.is_friendly or base_ext:destroyed() then
						att_obj_upd_state = false
					end
				elseif unit:in_slot(1) then
					att_obj_upd_state = false
				end
			elseif unit:in_slot(1) then
				att_obj_upd_state = false
			end

			handler:set_update_enabled(att_obj_upd_state)

			if not att_obj_upd_state then
				handler:update()

				managers.enemy:add_delayed_clbk("_att_object_pos_upd" .. tostring(u_key), callback(handler, handler, "_do_late_update"), self._t + 0.5)
			end
		end
	end
end

function GroupAIStateBase:unregister_AI_attention_object(unit_key)
	local general_entry = self._attention_objects.all[unit_key]
	local handler = general_entry and general_entry.handler

	if handler and handler._is_extension then
		handler:set_update_enabled(false)
	end

	--[[if not handler then
		local cam_pos = managers.viewport:get_current_camera_position()

		if cam_pos then
			if general_entry and general_entry.unit then
				local from_pos = cam_pos + math.DOWN * 50
				local brush = Draw:brush(Color.red:with_alpha(0.5), 5)
				brush:cylinder(from_pos, unit:position(), 25)
			else
				local from_pos = cam_pos + math.DOWN * 50
				local brush = Draw:brush(Color.red:with_alpha(0.5), 5)
				brush:sphere(from_pos, 25)
			end
		end
	end]]

	for cat_filter, list in pairs_g(self._attention_objects) do
		list[unit_key] = nil
	end
end

function GroupAIStateBase:chk_register_removed_attention_objects()
	if not self._removed_attention_objects then
		return
	end

	local all_attention_objects = self:get_all_AI_attention_objects()

	for u_key, removed_data in pairs_g(self._removed_attention_objects) do
		if all_attention_objects[u_key] then
			self._removed_attention_objects[u_key] = nil
		else
			local unit = removed_data[1]

			if alive_g(unit) then
				local handler = removed_data[2]
				local saved_attention_data = removed_data[3]

				for attention_id, attention_data in pairs_g(saved_attention_data) do
					handler:add_attention(attention_data)
				end
			end

			self._removed_attention_objects[u_key] = nil
		end
	end

	self._removed_attention_objects = {}
end

function GroupAIStateBase:store_removed_attention_object(u_key, unit, handler, attention_data)
	local stored_data = self._removed_attention_objects or {}

	if stored_data[u_key] then
		stored_data[u_key][1] = unit
		stored_data[u_key][2] = handler
		local stored_att_data = stored_data[u_key][3]

		for id, data in pairs_g(attention_data) do
			stored_att_data[id] = data
		end
	else
		stored_data[u_key] = {unit, handler, attention_data}
	end

	self._removed_attention_objects = stored_data
end

function GroupAIStateBase:chk_unregister_irrelevant_attention_objects()
	local all_attention_objects = self:get_all_AI_attention_objects()

	for u_key, att_info in pairs_g(all_attention_objects) do
		if not att_info.nav_tracker and not att_info.unit:vehicle_driving() or att_info.unit:in_slot(1) --[[or att_info.unit:in_slot(17) and att_info.unit:character_damage()]] then
			local handler = att_info.handler
			local handler_data = deep_clone(handler:attention_data())

			self:store_removed_attention_object(u_key, att_info.unit, handler, handler_data)

			for attention_id, _ in pairs_g(handler_data) do
				handler:remove_attention(attention_id)
			end
		end
	end
end

function GroupAIStateBase:_set_rescue_state(state)
end

local get_sync_event_id_original = GroupAIStateBase.get_sync_event_id
function GroupAIStateBase:get_sync_event_id(event_name)
	if event_name == "cloaker_spawned" then
		managers.hud:post_event("cloaker_spawn")
	end

	return get_sync_event_id_original(self, event_name)
end

function GroupAIStateBase:on_hostage_follow(owner, follower, state)
	local mov_ext = follower:movement()
	mov_ext:set_hostage_speed_modifier(state)

	local follower_key = follower:key()

	if state then
		owner = alive_g(owner) and owner or nil

		if owner then
			local owner_data = self:criminal_record(owner:key())

			if owner_data then
				owner_data.following_hostages = owner_data.following_hostages or {}
				owner_data.following_hostages[follower_key] = follower
			end

			local follower_data = managers.enemy:all_civilians()[follower_key]

			if follower_data then
				follower_data.hostage_following = owner
			end
		end

		if Network:is_server() then
			local peer = owner and managers.network:session():peer_by_unit(owner)

			if peer then
				local peer_id = peer:id()

				if peer_id ~= managers.network:session():local_peer():id() then
					peer:send_queued_sync("sync_unit_event_id_16", follower, "base", 1)

					managers.network:session():send_to_peers_synched_except(peer_id, "sync_unit_event_id_16", follower, "base", 3)
				else
					managers.network:session():send_to_peers_synched("sync_unit_event_id_16", follower, "base", 3)
				end
			else
				managers.network:session():send_to_peers_synched("sync_unit_event_id_16", follower, "base", 3)
			end

			if managers.player:has_team_category_upgrade("player", "civilian_hostage_carry_bags") then
				CarryData._valid_civs[follower_key] = follower

				local was_carrying_data = mov_ext:was_carrying_bag()
				local bag_unit = was_carrying_data and was_carrying_data.unit

				if alive_g(bag_unit) then
					local distance = mvec3_dis_sq(mov_ext:m_pos(), bag_unit:position())
					local max_distance = math_pow(tweak_data.ai_carry.revive_distance_autopickup, 2)

					if distance <= max_distance then
						bag_unit:carry_data():link_to(follower, false)

						if mov_ext.set_carrying_bag then
							mov_ext:set_carrying_bag(bag_unit)
						end
					end
				end
			end
		end
	else
		local follower_data = managers.enemy:all_civilians()[follower_key]

		owner = owner or follower_data and follower_data.hostage_following
		owner = alive_g(owner) and owner or nil

		local owner_data = owner and self:criminal_record(owner:key())

		if owner_data and owner_data.following_hostages then
			owner_data.following_hostages[follower_key] = nil

			if not next_g(owner_data.following_hostages) then
				owner_data.following_hostages = nil
			end
		end

		if follower_data then
			follower_data.hostage_following = nil
		end

		if Network:is_server() then
			mov_ext:throw_bag()

			if CarryData._valid_civs[follower_key] then
				CarryData._valid_civs[follower_key] = nil

				--reset the table to remove nil entries that still increase its size
				if not next_g(CarryData._valid_civs) then
					CarryData._valid_civs = {}
				end
			end

			if follower:id() ~= 1 then
				managers.network:session():send_to_peers_synched("sync_unit_event_id_16", follower, "base", 2)
			end
		end
	end
end
