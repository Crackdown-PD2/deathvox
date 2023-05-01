function CopLogicTravel.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.unit:brain():cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit
	}
	local is_cool = data.unit:movement():cool()

	if is_cool then
		my_data.detection = data.char_tweak.detection.ntl
	else
		my_data.detection = data.char_tweak.detection.recon
	end

	if old_internal_data then
		my_data.turning = old_internal_data.turning
		my_data.firing = old_internal_data.firing
		my_data.shooting = old_internal_data.shooting
		my_data.attention_unit = old_internal_data.attention_unit

		if old_internal_data.nearest_cover then
			my_data.nearest_cover = old_internal_data.nearest_cover

			managers.navigation:reserve_cover(my_data.nearest_cover[1], data.pos_rsrv_id)
		end

		if old_internal_data.best_cover then
			my_data.best_cover = old_internal_data.best_cover

			managers.navigation:reserve_cover(my_data.best_cover[1], data.pos_rsrv_id)
		end
	end

	if data.char_tweak.announce_incomming then
		my_data.announce_t = data.t + 2
	end

	data.internal_data = my_data
	local key_str = tostring(data.key)
	my_data.upd_task_key = "CopLogicTravel.queued_update" .. key_str

	CopLogicTravel.queue_update(data, my_data)

	my_data.cover_update_task_key = "CopLogicTravel._update_cover" .. key_str

	if my_data.nearest_cover or my_data.best_cover then
		CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t + 1)
	end

	my_data.advance_path_search_id = "CopLogicTravel_detailed" .. tostring(data.key)
	my_data.coarse_path_search_id = "CopLogicTravel_coarse" .. tostring(data.key)

	CopLogicIdle._chk_has_old_action(data, my_data)
	
	if my_data.advancing then
		my_data.old_action_advancing = true
	end

	local objective = data.objective
	local path_data = objective.path_data

	if objective.path_style == "warp" then
		my_data.warp_pos = objective.pos
	elseif path_data then
		local path_style = objective.path_style

		if path_style == "precise" then
			local path = {
				mvector3.copy(data.m_pos)
			}

			for _, point in ipairs(path_data.points) do
				table.insert(path, mvector3.copy(point.position))
			end

			my_data.advance_path = path
			my_data.coarse_path_index = 1
			local start_seg = data.unit:movement():nav_tracker():nav_segment()
			local end_pos = mvector3.copy(path[#path])
			local end_seg = managers.navigation:get_nav_seg_from_pos(end_pos)
			my_data.coarse_path = {
				{
					start_seg
				},
				{
					end_seg,
					end_pos
				}
			}
			my_data.path_is_precise = true
		elseif path_style == "coarse" then
			local nav_manager = managers.navigation
			local f_get_nav_seg = nav_manager.get_nav_seg_from_pos
			local start_seg = data.unit:movement():nav_tracker():nav_segment()
			local path = {
				{
					start_seg
				}
			}

			for _, point in ipairs(path_data.points) do
				local pos = mvector3.copy(point.position)
				local nav_seg = f_get_nav_seg(nav_manager, pos)

				table.insert(path, {
					nav_seg,
					pos
				})
			end

			my_data.coarse_path = path
			my_data.coarse_path_index = CopLogicTravel.complete_coarse_path(data, my_data, path)
		elseif path_style == "coarse_complete" then
			my_data.coarse_path_index = 1
			my_data.coarse_path = deep_clone(objective.path_data)
			my_data.coarse_path_index = CopLogicTravel.complete_coarse_path(data, my_data, my_data.coarse_path)
		end
	end

	if objective.stance then
		local upper_body_action = data.unit:movement()._active_actions[3]

		if not upper_body_action or upper_body_action:type() ~= "shoot" then
			data.unit:movement():set_stance(objective.stance)
		end
	end

	if data.attention_obj and AIAttentionObject.REACT_AIM < data.attention_obj.reaction then
		data.unit:movement():set_cool(false, managers.groupai:state().analyse_giveaway(data.unit:base()._tweak_table, data.attention_obj.unit))
	end

	if is_cool then
		data.unit:brain():set_attention_settings({
			peaceful = true
		})
	else
		data.unit:brain():set_attention_settings({
			cbt = true
		})
	end

	my_data.attitude = data.objective.attitude or "avoid"
	local usage = data.unit:inventory():equipped_unit() and alive(data.unit:inventory():equipped_unit()) and data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage
	my_data.weapon_range = usage and (data.char_tweak.weapon[usage] or {}).range
	
	if not my_data.weapon_range then
		my_data.weapon_range = {
			optimal = 2000,
			far = 5000,
			close = 1000
		}
	end
	
	my_data.path_safely = my_data.attitude == "avoid" and data.team.foes[tweak_data.levels:get_default_team_ID("player")]
	my_data.path_ahead = data.objective.path_ahead or data.team.id == tweak_data.levels:get_default_team_ID("player")

	data.unit:brain():set_update_enabled_state(false)
end

function CopLogicTravel.update(data)
	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	my_data.close_to_criminal = nil

	CopLogicTravel.upd_advance(data)
end

function CopLogicTravel.queue_detection_update(data, my_data, delay)
	if not delay then
		delay = 0
	end
	
	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicTravel.queued_detection_update, data, data.t + delay, data.important and true)
end

function CopLogicTravel.queued_detection_update(data)
	local my_data = data.internal_data
	local delay = CopLogicTravel._upd_enemy_detection(data)
	
	if my_data ~= data.internal_data then
		return
	end
	
	CopLogicTravel.queue_detection_update(data, my_data, delay)
end

function CopLogicTravel._update_cover(ignore_this, data)
	local my_data = data.internal_data
	local cover_release_dis = 100
	local nearest_cover = my_data.nearest_cover
	local best_cover = my_data.best_cover
	local m_pos = data.m_pos

	if not my_data.in_cover and nearest_cover and cover_release_dis < mvector3.distance(nearest_cover[1][1], m_pos) then
		managers.navigation:release_cover(nearest_cover[1])

		my_data.nearest_cover = nil
		nearest_cover = nil
	end

	if best_cover and cover_release_dis < mvector3.distance(best_cover[1][1], m_pos) then
		managers.navigation:release_cover(best_cover[1])

		my_data.best_cover = nil
		best_cover = nil
	end
end

function CopLogicTravel._chk_close_to_criminal(data, my_data)
	if data.unit:in_slot(16) or my_data.criminal or data.cool then
		return
	end

	if my_data.close_to_criminal == nil then
		my_data.close_to_criminal = false
		local my_area = managers.groupai:state():get_area_from_nav_seg_id(data.unit:movement():nav_tracker():nav_segment())
		local all_criminals = managers.groupai:state():all_char_criminals()
		local next_seg = my_data.coarse_path_index and my_data.coarse_path[my_data.coarse_path_index + 1] and my_data.coarse_path[my_data.coarse_path_index + 1][1]
		local next_area = next_seg and managers.groupai:state():get_area_from_nav_seg_id(next_seg)
		local closest_crim_u_data, closest_crim_dis = nil

		for u_key, u_data in pairs(all_criminals) do
			if not u_data.status or u_data.status == "electrified" then
				local u_data_seg = u_data.tracker:nav_segment()
				
				if my_area.nav_segs[u_data_seg] then
					my_data.close_to_criminal = true
					
					break
				elseif next_area and next_area.nav_segs[u_data_seg] then
					my_data.close_to_criminal = true
					
					break
				end
			end
		end
	end

	return my_data.close_to_criminal
end

function CopLogicTravel._pathing_complete_clbk(data)
	local my_data = data.internal_data

	if not my_data.exiting then
		if my_data.processing_advance_path or my_data.processing_coarse_path then
			CopLogicTravel.upd_advance(data)
		end
	end
end

function CopLogicTravel._get_pos_on_wall(from_pos, max_dist, step_offset, is_recurse)
	local nav_manager = managers.navigation
	local nr_rays = 9
	local ray_dis = max_dist or 700
	local step = 360 / nr_rays
	local offset = step_offset or math.random(360)
	local step_rot = Rotation(step)
	local offset_rot = Rotation(offset)
	local offset_vec = Vector3(ray_dis, 0, 0)

	mvector3.rotate_with(offset_vec, offset_rot)

	local to_pos = mvector3.copy(from_pos)

	mvector3.add(to_pos, offset_vec)

	local from_tracker = nav_manager:create_nav_tracker(from_pos)
	local ray_params = {
		allow_entry = false,
		trace = true,
		tracker_from = from_tracker,
		pos_to = to_pos
	}
	local rsrv_desc = {
		false,
		60
	}
	local fail_position = nil

	repeat
		to_pos = mvector3.copy(from_pos)

		mvector3.add(to_pos, offset_vec)

		ray_params.pos_to = to_pos
		local ray_res = nav_manager:raycast(ray_params)

		if ray_res then
			rsrv_desc.position = ray_params.trace[1]
			local is_free = nav_manager:is_pos_free(rsrv_desc)

			if is_free then
				managers.navigation:destroy_nav_tracker(from_tracker)

				return ray_params.trace[1]
			end
		elseif not fail_position then
			rsrv_desc.position = ray_params.trace[1]
			local is_free = nav_manager:is_pos_free(rsrv_desc)

			if is_free then
				fail_position = to_pos
			end
		end

		mvector3.rotate_with(offset_vec, step_rot)

		nr_rays = nr_rays - 1
	until nr_rays == 0

	managers.navigation:destroy_nav_tracker(from_tracker)

	if fail_position then
		return fail_position
	end

	if not is_recurse then
		return CopLogicTravel._get_pos_on_wall(from_pos, ray_dis * 0.5, offset + step * 0.5, true)
	end

	return from_pos
end

function CopLogicTravel._chk_start_pathing_to_next_nav_point(data, my_data)
	if not data.cool and not CopLogicTravel.chk_group_ready_to_move(data, my_data) then
		return
	end
	
	local nav_link = my_data.coarse_path[my_data.coarse_path_index + 1][3]
	
	if nav_link and alive(my_data.coarse_path[my_data.coarse_path_index + 1][3]) then
		if nav_link:delay_time() > data.t then
			my_data.waiting_for_navlink = nav_link:delay_time()
			
			return
		end
	elseif my_data.coarse_path[my_data.coarse_path_index + 1][4] then
		local entry_found
		local all_nav_segments = managers.navigation._nav_segments
		local target_seg_id = my_data.coarse_path[my_data.coarse_path_index + 1][1]
		local my_seg = all_nav_segments[my_data.coarse_path[my_data.coarse_path_index][1]]
		local neighbours = my_seg.neighbours
		local best_delay_t
		
		for neighbour_nav_seg_id, door_list in pairs(neighbours) do
			for _, i_door in ipairs(door_list) do
				if neighbour_nav_seg_id == target_seg_id then					
					if type(i_door) == "number" then
						entry_found = true
					elseif alive(i_door) and i_door:delay_time() <= TimerManager:game():time() and i_door:check_access(data.char_tweak.access) then
						entry_found = true
						
						break
					elseif alive(i_door) then
						if not best_delay_t or i_door:delay_time() < best_delay_t then
							best_delay_t = i_door:delay_time()
						end
					end
				end
			end
		end
			
		if not entry_found then
			my_data.waiting_for_navlink = best_delay_t
			
			return
		end
	end
	
	my_data.waiting_for_navlink = nil

	local to_pos = CopLogicTravel._get_exact_move_pos(data, my_data.coarse_path_index + 1)	
	my_data.processing_advance_path = true
	local prio = CopLogicTravel.get_pathing_prio(data)
	
	local nav_segs = CopLogicTravel._get_allowed_travel_nav_segs(data, my_data, to_pos)

	data.unit:brain():search_for_path(my_data.advance_path_search_id, to_pos, prio, nil, nav_segs)
end

function CopLogicTravel._check_start_path_ahead(data)
	local my_data = data.internal_data

	if my_data.processing_advance_path then
		return
	end

	local objective = data.objective
	local coarse_path = my_data.coarse_path
	local next_index = my_data.coarse_path_index + 2
	local total_nav_points = #coarse_path

	if next_index > total_nav_points then
		return
	end
	
	local nav_link = my_data.coarse_path[next_index][3]
	
	if nav_link and alive(my_data.coarse_path[next_index][3]) then
		if nav_link:delay_time() > data.t then
			return
		end
	elseif my_data.coarse_path[next_index][4] then
		local entry_found
		local all_nav_segments = managers.navigation._nav_segments
		local target_seg_id = my_data.coarse_path[next_index][1]
		local my_seg = all_nav_segments[my_data.coarse_path[my_data.coarse_path_index + 1][1]]
		local neighbours = my_seg.neighbours
		local best_delay_t
		
		for neighbour_nav_seg_id, door_list in pairs(neighbours) do
			for _, i_door in ipairs(door_list) do
				if neighbour_nav_seg_id == target_seg_id then					
					if type(i_door) == "number" then
						entry_found = true
					elseif alive(i_door) and i_door:delay_time() <= TimerManager:game():time() and i_door:check_access(data.char_tweak.access) then
						entry_found = true
						
						break
					end
				end
			end
		end
			
		if not entry_found then
			return
		end
	end
	

	local to_pos = data.logic._get_exact_move_pos(data, next_index)
	my_data.processing_advance_path = true
	local prio = data.logic.get_pathing_prio(data)
	local from_pos = data.pos_rsrv.move_dest.position
	local nav_segs = CopLogicTravel._get_allowed_travel_nav_segs(data, my_data, to_pos)

	data.unit:brain():search_for_path_from_pos(my_data.advance_path_search_id, from_pos, to_pos, prio, nil, nav_segs)
end

function CopLogicTravel.chk_group_ready_to_move(data, my_data)
	if not data.group then
		return true
	end

	local my_objective = data.objective

	if not my_objective.grp_objective or my_objective.grp_objective.type == "retire" then
		return true
	end
	
	local mvec3_dis = mvector3.distance_sq

	local my_dis = mvec3_dis(my_objective.area.pos, data.m_pos)
	
	if my_dis > 16000000 then
		return true
	end
	
	my_dis = my_dis * 1.1 * 1.1
	
	local can_continue = true	
	local my_tracker = data.unit:movement():nav_tracker()
	local m_tracker_pos = my_tracker:field_position()

	for u_key, u_data in pairs(data.group.units) do
		if u_key ~= data.key then
			local his_objective = u_data.unit:brain():objective()

			if his_objective and his_objective.grp_objective == my_objective.grp_objective and his_objective.area and not his_objective.in_place then
				local his_pos = u_data.unit:movement():nav_tracker():field_position()
				local dis_to_me = mvec3_dis(his_pos, m_tracker_pos) 
				local z_dis = math.abs(his_pos.z - m_tracker_pos.z)
				
				if dis_to_me > 640000 or z_dis >= 250 then
					local advance_pos = u_data.unit:brain() and u_data.unit:brain():is_advancing()
					his_pos = advance_pos or his_pos
					local his_dis = mvec3_dis(his_objective.area.pos, his_pos)
					
					if my_dis < his_dis then
						can_continue = nil
						
						break
					end
				end
			end
		end
	end
	
	if not can_continue then
		if data.char_tweak.chatter and data.char_tweak.chatter.ready then
			managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "follow_me")
		end
	end

	return can_continue
end

function CopLogicTravel._chk_begin_advance(data, my_data)
	if data.unit:movement():chk_action_forbidden("walk") then
		return
	end

	local objective = data.objective
	local haste = nil

	if objective and objective.haste then
		haste = objective.haste
	elseif data.unit:movement():cool() then
		haste = "walk"
	else
		haste = "run"
	end

	local pose = nil
	pose = not data.char_tweak.crouch_move and "stand" or data.char_tweak.allowed_poses and not data.char_tweak.allowed_poses.stand and "crouch" or "stand"

	if not data.unit:anim_data()[pose] then
		CopLogicAttack["_chk_request_action_" .. pose](data)
	end

	local end_rot = nil

	if my_data.coarse_path_index >= #my_data.coarse_path - 1 then
		end_rot = objective and objective.rot
	end

	local no_strafe, end_pose = nil

	if (my_data.moving_to_cover or data.is_suppressed) and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
		end_pose = "crouch"
	end

	CopLogicTravel._chk_request_action_walk_to_advance_pos(data, my_data, haste, end_rot, no_strafe, pose, end_pose)
end

function CopLogicTravel._chk_request_action_walk_to_advance_pos(data, my_data, speed, end_rot, no_strafe, pose, end_pose)
	if not data.unit:movement():chk_action_forbidden("walk") or data.unit:anim_data().act_idle then
		CopLogicAttack._correct_path_start_pos(data, my_data.advance_path)

		local path = my_data.advance_path
		local new_action_data = {
			type = "walk",
			body_part = 2,
			nav_path = path,
			variant = speed or "run",
			end_rot = end_rot,
			path_simplified = my_data.path_is_precise,
			no_strafe = no_strafe,
			pose = pose,
			end_pose = end_pose
		}
		my_data.advance_path = nil
		my_data.starting_advance_action = true
		my_data.advancing = data.unit:brain():action_request(new_action_data)
		my_data.starting_advance_action = false

		if my_data.advancing then
			data.brain:rem_pos_rsrv("path")
		end
	end
end

function CopLogicTravel.upd_advance(data)
	local unit = data.unit
	local my_data = data.internal_data
	local objective = data.objective
	local t = TimerManager:game():time()
	data.t = t
	
	--adding this here prevents a wasted update if the old action was stopped successfully and if the cover_leave_t is gone
	if my_data.has_old_action then
		CopLogicAttack._upd_stop_old_action(data, my_data)

		if my_data.has_old_action then
			return
		end
	end
	
	CopLogicTravel._chk_stop_for_follow_unit(data, my_data)
	
	if not data.cool then
		if my_data.cover_leave_t then
			if my_data.cover_leave_t > t then
				if data.attention_obj and AIAttentionObject.REACT_SCARED <= data.attention_obj.reaction and (not my_data.best_cover or not my_data.best_cover[4]) and not unit:anim_data().crouch and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
					CopLogicAttack._chk_request_action_crouch(data)
				end	
			else
				my_data.cover_leave_t = nil
			end
		end
		
		if not my_data.coarse_path or my_data.coarse_path_index and my_data.coarse_path_index < #my_data.coarse_path then
			if not CopLogicAttack._check_needs_reload(data, my_data) then
				return
			end
		end
		
		if my_data.cover_leave_t then
			return
		elseif data.next_mov_time and data.next_mov_time > t then
			return
		end
	end
	
	if my_data ~= data.internal_data then
		return
	end
	
	if CopLogicTravel._chk_coarse_objective_reached(data) then
		CopLogicTravel._on_destination_reached(data)
		
		if my_data ~= data.internal_data then
			return
		end
	end

	if my_data.warp_pos then
		local action_desc = {
			body_part = 1,
			type = "warp",
			position = mvector3.copy(objective.pos),
			rotation = objective.rot
		}

		if unit:movement():action_request(action_desc) then
			CopLogicTravel._on_destination_reached(data)
		end
	elseif my_data.advancing then
		if not my_data.old_action_advancing and my_data.coarse_path then
			if my_data.processing_advance_path or my_data.processing_coarse_path then
				CopLogicTravel._upd_pathing(data, my_data)
			end
			
			if my_data ~= data.internal_data then
				return
			end
		
			if not data.cool and not data.unit:in_slot(16) then
				CopLogicTravel._chk_say_clear(data)
			end
	
			--[[if my_data.advance_path and my_data.advancing and CopLogicTravel.chk_group_ready_to_move(data, my_data) then
				if not my_data.advancing:stopping() and not my_data.advancing._end_of_path and my_data.advancing:append_path_mid_logic(my_data.advance_path) then
					my_data.advance_path = nil
					my_data.path_elongated = true
				end
			end]]
		end
	elseif my_data.advance_path then
		if data.cool or CopLogicTravel.chk_group_ready_to_move(data, my_data) then --to-do, make chk_close_to_criminal make more sense...
			CopLogicTravel._chk_begin_advance(data, my_data)

			if my_data.advancing and my_data.path_ahead then
				CopLogicTravel._check_start_path_ahead(data)
			end
		end
	elseif my_data.processing_advance_path or my_data.processing_coarse_path then
		local was_processing_advance_path = my_data.processing_advance_path
	
		CopLogicTravel._upd_pathing(data, my_data)

		if my_data ~= data.internal_data then
			return
		end
		
		if not my_data.processing_advance_path and not my_data.processing_coarse_path then
			if was_processing_advance_path then
				if my_data.advance_path and not my_data.advancing then
					if data.cool or CopLogicTravel.chk_group_ready_to_move(data, my_data) then
						CopLogicTravel._chk_begin_advance(data, my_data)

						if my_data.advancing and my_data.path_ahead then
							CopLogicTravel._check_start_path_ahead(data)
						end
					end
				end
			elseif my_data.coarse_path and not my_data.advancing then
				CopLogicTravel._chk_start_pathing_to_next_nav_point(data, my_data)
				
				if my_data.waiting_for_navlink then
					if data.attention_obj and AIAttentionObject.REACT_SCARED <= data.attention_obj.reaction and (not my_data.best_cover or not my_data.best_cover[4]) and not unit:anim_data().crouch and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
						CopLogicAttack._chk_request_action_crouch(data)
					end
				end
			end
		end
	elseif not data.unit:movement():chk_action_forbidden("walk") then
		if objective then
			if objective.nav_seg or objective.type == "follow" then
				if my_data.coarse_path then
					if my_data.coarse_path_index == #my_data.coarse_path or CopLogicTravel._chk_coarse_objective_reached(data) then
						CopLogicTravel._on_destination_reached(data)
					else
						CopLogicTravel._chk_start_pathing_to_next_nav_point(data, my_data)
						
						if my_data.waiting_for_navlink then
							if data.attention_obj and AIAttentionObject.REACT_SCARED <= data.attention_obj.reaction and (not my_data.best_cover or not my_data.best_cover[4]) and not unit:anim_data().crouch and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
								CopLogicAttack._chk_request_action_crouch(data)
							end
						end
					end
				else
					CopLogicTravel._begin_coarse_pathing(data, my_data)
				end
			else
				local wanted_state = data.logic._get_logic_state_from_reaction(data) or "idle"

				CopLogicBase._exit(data.unit, wanted_state)
			end
		else
			local wanted_state = data.logic._get_logic_state_from_reaction(data) or "idle"

			CopLogicBase._exit(data.unit, wanted_state)
		end
	end
	
	if data.internal_data == my_data then
		CopLogicTravel._update_cover(nil, data)
	end
end

local precise_objective_types = {
	act = true,
	sniper = true,
	follow = true
}

function CopLogicTravel._chk_coarse_objective_reached(data)
	local objective = data.objective
	
	if not objective then
		return
	end

	if objective.followup_SO or objective.followup_objective and objective.followup_objective.action or objective.action or precise_objective_types[objective.type] or objective.grp_objective and objective.grp_objective.type == "retire" then
		return
	end
	
	if not objective.nav_seg then
		return
	end
	
	local my_seg = data.unit:movement():nav_tracker():nav_segment()
	
	if objective.nav_seg == my_seg then
		return true
	end
end

function CopLogicTravel._chk_say_clear(data)
	if data.last_calm_chatter_t and data.t - data.last_calm_chatter_t < 30 then
		return
	end

	if data.char_tweak.chatter and data.char_tweak.chatter.clear then
		if not data.attention_obj or data.attention_obj.reaction <= AIAttentionObject.REACT_AIM or not data.attention_obj.verified_t or data.t - data.attention_obj.verified_t > 15 then
			if not managers.groupai:state():is_detection_persistent() then
				local rng = math.random()
				
				if rng > 0.4 then
					managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "clear")
				else
					managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "controlidle")
				end
			else
				managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "clear")
			end
			
			data.last_calm_chatter_t = data.t
		end
	end
	
	if not data.entrance and data.char_tweak.chatter and data.char_tweak.chatter.entrance then
		if not data.attention_obj or data.attention_obj.reaction <= AIAttentionObject.REACT_AIM or not data.attention_obj.verified_t or data.t - data.attention_obj.verified_t > 15 then
		--[[
			if data.unit:sound():say(data.char_tweak.chatter.entrance, true) then
				data.entrance = true
				
				data.last_calm_chatter_t = data.t
			end
		--]]
			data.last_calm_chatter_t = data.t --temp; remove this when this voiceline proc is reenabled
		end
	end
end

function CopLogicTravel._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	local my_data = data.internal_data
	--this prevents units from looking at broken glass or other dumb things while in loud, and saves performance a decent bit
	local min_reaction = not data.cool and AIAttentionObject.REACT_AIM
	CopLogicBase._upd_attention_obj_detection(data, min_reaction, nil)
	local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, data.detected_attention_objects, nil)
	local old_att_obj = data.attention_obj
	
	local delay = 0 --whisper mode updates need to be as CONSTANT as possible to keep units moving smoothly and predictably
	
	if not managers.groupai:state():whisper_mode() then
		delay = data.important and 0.5 or 1 --units in travel update less often than units in attack, i can run a lot of stuff through action_complete_clbk and single-update states
	end

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)

	local objective = data.objective
	local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, new_attention)

	if allow_trans and (obj_failed or not objective or objective.type ~= "follow") then
		local wanted_state = CopLogicBase._get_logic_state_from_reaction(data)

		if wanted_state and wanted_state ~= data.name then
			if obj_failed then
				data.objective_failed_clbk(data.unit, data.objective)
			end

			if my_data == data.internal_data and not objective.is_default then
				debug_pause_unit(data.unit, "[CopLogicTravel._upd_enemy_detection] exiting without discarding objective", data.unit, inspect(objective))
				CopLogicBase._exit(data.unit, wanted_state)
			end

			CopLogicBase._report_detections(data.detected_attention_objects)

			return delay
		end
	end

	if my_data == data.internal_data then
		if data.cool and new_reaction == AIAttentionObject.REACT_SUSPICIOUS and CopLogicBase._upd_suspicion(data, my_data, new_attention) then
			CopLogicBase._report_detections(data.detected_attention_objects)

			return delay
		elseif new_reaction and new_reaction <= AIAttentionObject.REACT_SCARED then
			local set_attention = data.unit:movement():attention()

			if not set_attention or set_attention.u_key ~= new_attention.u_key then
				CopLogicBase._set_attention(data, new_attention, nil)
			end
		end

		CopLogicAttack._upd_aim(data, my_data)
	end

	CopLogicBase._report_detections(data.detected_attention_objects)

	if data.cool then
		CopLogicTravel.upd_suspicion_decay(data)
	end

	return delay
end

function CopLogicTravel._determine_destination_occupation(data, objective)
	local occupation = nil

	if objective.type == "defend_area" then
		if objective.cover then
			occupation = {
				type = "defend",
				seg = objective.nav_seg,
				cover = objective.cover,
				radius = objective.radius
			}
		elseif objective.pos then
			occupation = {
				type = "defend",
				seg = objective.nav_seg,
				pos = objective.pos,
				radius = objective.radius
			}
		else
			local near_pos = objective.follow_unit and alive(objective.follow_unit) and objective.follow_unit:movement():nav_tracker():field_position() or data.internal_data.coarse_path[#data.internal_data.coarse_path][2] or managers.navigation._nav_segments[objective.nav_seg].pos
			local cover = CopLogicTravel._find_cover(data, objective.nav_seg, near_pos)

			if cover then
				local cover_entry = {
					cover
				}
				occupation = {
					type = "defend",
					seg = objective.nav_seg,
					cover = cover_entry,
					radius = objective.radius
				}
			else
				near_pos = CopLogicTravel._get_pos_on_wall(near_pos, 700)
				near_pos = managers.navigation:pad_out_position(near_pos, 4, data.char_tweak.wall_fwd_offset)
				occupation = {
					type = "defend",
					seg = objective.nav_seg,
					pos = near_pos,
					radius = objective.radius
				}
			end
		end
	elseif objective.type == "phalanx" then
		local logic = data.unit:brain():get_logic_by_name(objective.type)

		logic.register_in_group_ai(data.unit)

		local phalanx_circle_pos = logic.calc_initial_phalanx_pos(data.m_pos, objective)
		occupation = {
			type = "defend",
			seg = objective.nav_seg,
			pos = phalanx_circle_pos,
			radius = objective.radius
		}
	elseif objective.type == "act" then
		occupation = {
			type = "act",
			seg = objective.nav_seg,
			pos = objective.pos
		}
	elseif objective.type == "follow" then
		local my_data = data.internal_data
		local follow_tracker = objective.follow_unit and alive(objective.follow_unit) and objective.follow_unit:movement():nav_tracker()
		local dest_nav_seg_id = my_data.coarse_path[#my_data.coarse_path][1]
		local dest_area = managers.groupai:state():get_area_from_nav_seg_id(dest_nav_seg_id)
		local follow_pos = follow_tracker and follow_tracker:field_position()
		local threat_pos = nil
		local follow_dis = data.internal_data.called and 450 or 700

		if data.attention_obj and data.attention_obj.nav_tracker and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction then
			threat_pos = data.attention_obj.nav_tracker:field_position()
		end

		local cover = managers.navigation:find_cover_in_nav_seg_3(dest_area.nav_segs, follow_dis, follow_pos, threat_pos)
		
		if cover and (not follow_pos or mvector3.distance_sq(cover[1], follow_pos) <= (data.internal_data.called and 202500 or 490000)) then
			local cover_entry = {
				cover
			}
			occupation = {
				type = "defend",
				cover = cover_entry
			}
		else
			local max_dist = nil

			if data.internal_data.called then
				max_dist = 450
			end

			local to_pos = CopLogicTravel._get_pos_on_wall(follow_pos, max_dist)
			to_pos = managers.navigation:pad_out_position(to_pos, 4, data.char_tweak.wall_fwd_offset)
			occupation = {
				type = "defend",
				pos = to_pos
			}
		end
	elseif objective.type == "revive" then
		local is_local_player = objective.follow_unit:base().is_local_player
		local revive_u_mv = objective.follow_unit:movement()
		local revive_u_tracker = revive_u_mv:nav_tracker()
		local revive_u_rot = is_local_player and Rotation(0, 0, 0) or revive_u_mv:m_rot()
		local revive_u_fwd = revive_u_rot:y()
		local revive_u_right = revive_u_rot:x()
		local revive_u_pos = revive_u_tracker:lost() and revive_u_tracker:field_position() or revive_u_mv:m_pos()
		local ray_params = {
			trace = true,
			tracker_from = revive_u_tracker
		}

		if revive_u_tracker:lost() then
			ray_params.pos_from = revive_u_pos
		end

		local stand_dis = nil

		if is_local_player or objective.follow_unit:base().is_husk_player then
			stand_dis = 120
		else
			stand_dis = 90
			local mid_pos = mvector3.copy(revive_u_fwd)

			mvector3.multiply(mid_pos, -20)
			mvector3.add(mid_pos, revive_u_pos)

			ray_params.pos_to = mid_pos
			local ray_res = managers.navigation:raycast(ray_params)
			revive_u_pos = ray_params.trace[1]
		end

		local rand_side_mul = math.random() > 0.5 and 1 or -1
		local revive_pos = mvector3.copy(revive_u_right)

		mvector3.multiply(revive_pos, rand_side_mul * stand_dis)
		mvector3.add(revive_pos, revive_u_pos)

		ray_params.pos_to = revive_pos
		local ray_res = managers.navigation:raycast(ray_params)

		if ray_res then
			local opposite_pos = mvector3.copy(revive_u_right)

			mvector3.multiply(opposite_pos, -rand_side_mul * stand_dis)
			mvector3.add(opposite_pos, revive_u_pos)

			ray_params.pos_to = opposite_pos
			local old_trace = ray_params.trace[1]
			local opposite_ray_res = managers.navigation:raycast(ray_params)

			if opposite_ray_res then
				if mvector3.distance(revive_pos, revive_u_pos) < mvector3.distance(ray_params.trace[1], revive_u_pos) then
					revive_pos = ray_params.trace[1]
				else
					revive_pos = old_trace
				end
			else
				revive_pos = ray_params.trace[1]
			end
		else
			revive_pos = ray_params.trace[1]
		end

		local revive_rot = revive_u_pos - revive_pos
		local revive_rot = Rotation(revive_rot, math.UP)
		occupation = {
			type = "revive",
			pos = revive_pos,
			rot = revive_rot
		}
	else
		occupation = {
			seg = objective.nav_seg,
			pos = objective.pos
		}
	end

	return occupation
end

function CopLogicTravel.get_pathing_prio(data)
	local prio = 0
	local objective = data.objective
	
	if data.is_converted or data.unit:in_slot(16) then
		if objective and objective.type == "follow" then
			prio = 11
		else
			prio = 10
		end
	elseif data.team.id == tweak_data.levels:get_default_team_ID("player") then
		prio = 9
	else
		local is_civilian = CopDamage.is_civilian(data.unit:base()._tweak_table)
		
		if is_civilian then
			if objective then
				prio = 1
				
				
				if objective.type == "escort" then
					prio = 10
				elseif objective.follow_unit then
					if objective.follow_unit:base().is_local_player or objective.follow_unit:base().is_husk_player or managers.groupai:state():is_unit_team_AI(objective.follow_unit) then	
						prio = 2
					end
				end
			end
		elseif objective then
			prio = 4
			
			if objective.type == "phalanx" then
				prio = 8
			elseif objective.follow_unit then
				if objective.follow_unit:base().is_local_player or objective.follow_unit:base().is_husk_player or managers.groupai:state():is_unit_team_AI(objective.follow_unit) then	
					if data.important then
						prio = 7
					else
						prio = 6
					end
				end
			elseif data.important then
				prio = 5
			end
		elseif data.important then
			prio = 3
		end
	end

	return prio
end

function CopLogicTravel.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action:type()

	if action_type == "walk" then
		if action:expired() and not my_data.starting_advance_action and my_data.coarse_path_index and not my_data.has_old_action and not my_data.old_action_advancing and my_data.advancing then
			local coarse_index_increment = my_data.path_elongated and 2 or 1
			my_data.coarse_path_index = my_data.coarse_path_index + coarse_index_increment

			if my_data.coarse_path_index > #my_data.coarse_path then
				my_data.coarse_path_index = my_data.coarse_path_index - 1
			end
		end

		my_data.advancing = nil
		my_data.old_action_advancing = nil

		if my_data.moving_to_cover then
			if action:expired() then
				if my_data.best_cover then
					managers.navigation:release_cover(my_data.best_cover[1])
				end

				my_data.best_cover = my_data.moving_to_cover

				CopLogicBase.chk_cancel_delayed_clbk(my_data, my_data.cover_update_task_key)

				local high_ray = CopLogicTravel._chk_cover_height(data, my_data.best_cover[1], data.visibility_slotmask)
				my_data.best_cover[4] = high_ray
				my_data.in_cover = true

				if CopLogicTravel._chk_close_to_criminal(data, my_data) or data.is_suppressed then
					local cover_wait_time = my_data.coarse_path_index == #my_data.coarse_path - 1 and 0.3 or 0.6 + 0.4 * math.random()
					
					my_data.cover_leave_t = data.t + cover_wait_time
				end
			else
				managers.navigation:release_cover(my_data.moving_to_cover[1])

				if my_data.best_cover then
					local dis = mvector3.distance(my_data.best_cover[1][1], data.unit:movement():m_pos())

					if dis > 100 then
						managers.navigation:release_cover(my_data.best_cover[1])

						my_data.best_cover = nil
					end
				end
			end

			my_data.moving_to_cover = nil
		elseif my_data.best_cover then
			local dis = mvector3.distance(my_data.best_cover[1][1], data.unit:movement():m_pos())

			if dis > 100 then
				managers.navigation:release_cover(my_data.best_cover[1])

				my_data.best_cover = nil
			end
		end

		if action:expired() and not my_data.starting_advance_action then
			--log("wee")
			if my_data == data.internal_data then 
				CopLogicTravel.upd_advance(data)
				my_data.waiting_for_navlink = nil
			end
		end
		
		if my_data == data.internal_data then
			CopLogicTravel._update_cover(nil, data)
		end
	elseif action_type == "turn" then
		data.internal_data.turning = nil

		if action:expired() then
			CopLogicTravel.upd_advance(data)
			my_data.waiting_for_navlink = nil
		end
	elseif action_type == "shoot" then
		data.internal_data.shooting = nil
	elseif action_type == "heal" then
		if action:expired() then
			CopLogicTravel.upd_advance(data)
			my_data.waiting_for_navlink = nil
		end
	elseif action_type == "hurt" or action_type == "healed" or action_type == "act" and not my_data.advancing then
		if action:expired() then	
			if my_data == data.internal_data then
				CopLogicTravel.upd_advance(data)
				my_data.waiting_for_navlink = nil
			end
		end
	elseif action_type == "dodge" then
		local objective = data.objective
		local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, nil)

		if allow_trans then
			local wanted_state = data.logic._get_logic_state_from_reaction(data)

			if wanted_state and wanted_state ~= data.name and obj_failed then
				if data.unit:in_slot(managers.slot:get_mask("enemies")) or data.unit:in_slot(17) then
					data.objective_failed_clbk(data.unit, data.objective)
				elseif data.unit:in_slot(managers.slot:get_mask("criminals")) then
					managers.groupai:state():on_criminal_objective_failed(data.unit, data.objective, false)
				end

				if my_data == data.internal_data then
					debug_pause_unit(data.unit, "[CopLogicTravel.action_complete_clbk] exiting without discarding objective", data.unit, inspect(data.objective))
					CopLogicBase._exit(data.unit, wanted_state)
				end
			end
		end
		
		if my_data == data.internal_data then
			if action:expired() then
				CopLogicTravel.upd_advance(data)
				my_data.waiting_for_navlink = nil
			end
		end
	end
end

function CopLogicTravel._chk_stop_for_follow_unit(data, my_data)
	local objective = data.objective

	if not objective or objective.type ~= "follow" or data.unit:movement():chk_action_forbidden("walk") or data.unit:anim_data().act_idle then
		return
	end

	if not my_data.coarse_path_index or my_data.coarse_path and #my_data.coarse_path - 1 == 1 then
		return
	end
	
	if not objective.follow_unit or not alive(objective.follow_unit) then
		return
	end
	
	if my_data.criminal or data.unit:in_slot(16) or data.team.id == tweak_data.levels:get_default_team_ID("player") or data.team.friends[tweak_data.levels:get_default_team_ID("player")] then
		local follow_unit = objective.follow_unit
		local my_nav_seg_id = data.unit:movement():nav_tracker():nav_segment()
		local my_areas = managers.groupai:state():get_areas_from_nav_seg_id(my_nav_seg_id)
		local follow_unit_nav_seg_id = follow_unit:movement():nav_tracker():nav_segment()
		local should_try_stop = nil
		
		if my_nav_seg_id == follow_unit_nav_seg_id then
			if mvector3.distance_sq(data.m_pos, follow_unit:movement():nav_tracker():field_position()) < 40000 then
				objective.in_place = true

				data.logic.on_new_objective(data)
				
				return
			end
		
			should_try_stop = true
		else
			for _, area in ipairs(my_areas) do
				if area.nav_segs[follow_unit_nav_seg_id] then
					should_try_stop = true
					
					break
				end
			end
		end
		
		if should_try_stop and not TeamAILogicIdle._check_should_relocate(data, my_data, data.objective) then
			objective.in_place = true

			data.logic.on_new_objective(data)
			
			return
		else
			local obj_nav_seg = my_data.coarse_path[#my_data.coarse_path][1]
			local obj_areas = managers.groupai:state():get_areas_from_nav_seg_id(obj_nav_seg)
			local dontcheckdis, dis
			
			for _, area in ipairs(obj_areas) do
				if area.nav_segs[follow_unit_nav_seg_id] then
					dontcheckdis = true
					
					break
				end
			end
			
			if not dontcheckdis and #obj_areas > 0 then
				if mvector3.distance_sq(obj_areas[1].pos, follow_unit:movement():nav_tracker():field_position()) > 1000000 or math.abs(obj_areas[1].pos.z - follow_unit:movement():nav_tracker():field_position().z) > 250 then
					objective.in_place = nil
					
					data.logic.on_new_objective(data)
			
					return
				end
			end
		end
	else
		local follow_unit = data.objective.follow_unit
		local advance_pos = follow_unit:brain() and follow_unit:brain():is_advancing()
		local follow_unit_pos = advance_pos or follow_unit:movement():m_pos()
		local relocate = nil
		
		if data.objective.distance and data.objective.distance < mvector3.distance(data.m_pos, follow_unit_pos) then
			relocate = true
		end

		if not relocate then
			local ray_params = {
				tracker_from = data.unit:movement():nav_tracker(),
				pos_to = follow_unit_pos
			}
			local ray_res = managers.navigation:raycast(ray_params)

			if ray_res then
				relocate = true
			end
		end
		
		if not relocate then
			objective.in_place = true

			data.logic.on_new_objective(data)
			
			return
		end
	end
end

function CopLogicTravel._find_cover(data, search_nav_seg, near_pos)
	if data.unit:movement():cool() then
		return
	end
	
	local cover = nil
	local search_area = managers.groupai:state():get_area_from_nav_seg_id(search_nav_seg)

	local optimal_threat_dis, threat_pos = nil
	
	if not data.internal_data.weapon_range and data.char_tweak.weapon then
		data.internal_data.weapon_range = data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range
		
		if not data.internal_data.range then
			data.internal_data.weapon_range = {
				optimal = 2000,
				far = 5000,
				close = 1000
			}
		end
	else
		data.internal_data.weapon_range = {
			optimal = 2000,
			far = 5000,
			close = 1000
		}
	end
	
	if data.internal_data.weapon_range then
		if data.objective.attitude == "engage" then
			optimal_threat_dis = data.internal_data.weapon_range.optimal
		else
			optimal_threat_dis = data.internal_data.weapon_range.far
		end
	else
		optimal_threat_dis = 1000
	end
	
	near_pos = near_pos or search_area.pos
	
	if data.internal_data.criminal or data.unit:in_slot(16) then
		threat_pos = data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.m_head_pos
	else
		local all_criminals = managers.groupai:state():all_char_criminals()
		local closest_crim_u_data, closest_crim_dis = nil

		for u_key, u_data in pairs(all_criminals) do
			if not u_data.status or u_data.status == "electrified" then
				local crim_area = managers.groupai:state():get_area_from_nav_seg_id(u_data.tracker:nav_segment())

				if crim_area == search_area then
					threat_pos = u_data.m_pos

					break
				else
					local crim_dis = mvector3.distance_sq(near_pos, u_data.m_pos)

					if not closest_crim_dis or crim_dis < closest_crim_dis then
						threat_pos = u_data.m_pos
						closest_crim_dis = crim_dis
					end
				end
			end
		end
	end
	
	if threat_pos then
		cover = managers.navigation:find_cover_from_threat(search_area.nav_segs, optimal_threat_dis, near_pos, threat_pos)
	end

	return cover
end

function CopLogicTravel._get_exact_move_pos(data, nav_index)
	local my_data = data.internal_data
	local objective = data.objective
	local to_pos = nil
	local coarse_path = my_data.coarse_path
	local total_nav_points = #coarse_path
	local reservation, wants_reservation = nil

	if total_nav_points <= nav_index then
		local new_occupation = CopLogicTravel._determine_destination_occupation(data, objective)

		if new_occupation then
			if new_occupation.type == "guard" then
				local guard_door = new_occupation.door
				local guard_pos = CopLogicTravel._get_pos_accross_door(guard_door, objective.nav_seg)

				if guard_pos then
					reservation = CopLogicTravel._reserve_pos_along_vec(guard_door.center, guard_pos)

					if reservation then
						local guard_object = {
							type = "door",
							door = guard_door,
							from_seg = new_occupation.from_seg
						}
						objective.guard_obj = guard_object
						to_pos = reservation.pos
					end
				end
			elseif new_occupation.type == "defend" then
				if new_occupation.cover then
					to_pos = new_occupation.cover[1][1]

					to_pos = managers.navigation:pad_out_position(to_pos, 4, data.char_tweak.wall_fwd_offset)

					local new_cover = new_occupation.cover

					managers.navigation:reserve_cover(new_cover[1], data.pos_rsrv_id)

					my_data.moving_to_cover = new_cover
				elseif new_occupation.pos then
					to_pos = new_occupation.pos
				end

				wants_reservation = true
			elseif new_occupation.type == "act" then
				to_pos = new_occupation.pos
				wants_reservation = true
			elseif new_occupation.type == "revive" then
				to_pos = new_occupation.pos
				objective.rot = new_occupation.rot
				wants_reservation = true
			else
				to_pos = new_occupation.pos
				wants_reservation = true
			end
		end

		if not to_pos then
			to_pos = coarse_path[nav_index][2] or managers.navigation:find_random_position_in_segment(objective.nav_seg)
			to_pos = CopLogicTravel._get_pos_on_wall(to_pos)
			to_pos = managers.navigation:pad_out_position(to_pos, 4, data.char_tweak.wall_fwd_offset)
			wants_reservation = true
		end
	else
		local nav_seg = coarse_path[nav_index][1]
		local area = managers.groupai:state():get_area_from_nav_seg_id(nav_seg)
		local door_pos = not data.cool and CopLogicTravel.find_door_pos_nearest_to_next_nav_seg(data, coarse_path, nav_index, nav_seg)	
		
		local cover = CopLogicTravel._find_cover(data, nav_seg, door_pos)

		if my_data.moving_to_cover then
			managers.navigation:release_cover(my_data.moving_to_cover[1])

			my_data.moving_to_cover = nil
		end

		if cover then
			managers.navigation:reserve_cover(cover, data.pos_rsrv_id)

			my_data.moving_to_cover = {
				cover
			}
			to_pos = cover[1]
			wants_reservation = true
		else
			if door_pos then
				to_pos = door_pos
			else
				to_pos = coarse_path[nav_index][2] or area.pos
				
				if not data.cool then
					to_pos = CopLogicTravel._get_pos_on_wall(to_pos)
				end
			end
			
			local rsrv_desc = {
				filter = data.pos_rsrv_id,
				radius = 60,
				position = to_pos
			}
			
			if not managers.navigation:is_pos_free(rsrv_desc) then
				to_pos = CopLogicTravel._get_pos_on_wall(to_pos, nil, nil, nil, nil, data.pos_rsrv_id)
			end
			
			
			wants_reservation = true
		end
		
		to_pos = managers.navigation:pad_out_position(to_pos, 4, data.char_tweak.wall_fwd_offset)
	end

	if not reservation and wants_reservation then
		data.brain:add_pos_rsrv("path", {
			radius = 60,
			position = mvector3.copy(to_pos)
		})
	end

	return to_pos
end

function CopLogicTravel.find_door_pos_nearest_to_next_nav_seg(data, coarse_path, nav_index, nav_seg)
	local next_pos = coarse_path[nav_index + 1][2]
	local nav_seg_data = managers.navigation._nav_segments[coarse_path[nav_index + 1][1]]
	local best_dis, best_door
	local all_doors = managers.navigation._room_doors
	local mvec3_dis = mvector3.distance
	
	for neighbour_nav_seg_id, door_list in pairs(nav_seg_data.neighbours) do
		if neighbour_nav_seg_id == nav_seg then
			for _, i_door in ipairs(door_list) do
				local door_pos
				
				if type(i_door) == "number" then
					door_pos = all_doors[i_door].center
				elseif alive(i_door) then
					door_pos = i_door:start_position()
				end
				
				if door_pos then
					local dis = mvec3_dis(door_pos, next_pos)
							
					if not best_dis or dis < best_dis then
						best_door = door
						best_dis = dis
					end
				end
			end
		end
	end
	
	if best_door then
		local door_pos = best_door.center
		local accross_vec = door_pos - next_pos
		local rot_angle = 90
		mvector3.rotate_with(accross_vec, Rotation(rot_angle))
		
		local max_dis = 500

		mvector3.set_length(accross_vec, max_dis)

		local door_tracker = managers.navigation:create_nav_tracker(mvector3.copy(door_pos))
		local accross_positions = managers.navigation:find_walls_accross_tracker(door_tracker, accross_vec)
		
		if accross_positions then
			local optimal_dis = math.lerp(max_dis * 0.6, max_dis, math.random())
			local best_error_dis, best_pos, best_is_hit, best_is_miss, best_has_too_much_error = nil

			for _, accross_pos in ipairs(accross_positions) do
				local error_dis = math.abs(mvector3.distance(accross_pos[1], door_pos) - optimal_dis)
				local too_much_error = error_dis / optimal_dis > 0.3
				local is_hit = accross_pos[2]

				if best_is_hit then
					if is_hit then
						if error_dis < best_error_dis then
							best_pos = accross_pos[1]
							best_error_dis = error_dis
							best_has_too_much_error = too_much_error
						end
					elseif best_has_too_much_error then
						best_pos = accross_pos[1]
						best_error_dis = error_dis
						best_is_miss = true
						best_is_hit = nil
					end
				elseif best_is_miss then
					if not too_much_error then
						best_pos = accross_pos[1]
						best_error_dis = error_dis
						best_has_too_much_error = nil
						best_is_miss = nil
						best_is_hit = true
					end
				else
					best_pos = accross_pos[1]
					best_is_hit = is_hit
					best_is_miss = not is_hit
					best_has_too_much_error = too_much_error
					best_error_dis = error_dis
				end
			end

			managers.navigation:destroy_nav_tracker(door_tracker)
			
			return best_pos
		end

		managers.navigation:destroy_nav_tracker(door_tracker)
		
	end
end

function CopLogicTravel._chk_cover_height(data, cover, slotmask)
	local low_ray, high_ray
	
	if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction then
		local threat_pos = data.attention_obj.m_head_pos
		low_ray, high_ray = CopLogicAttack._chk_covered(data, cover[1], threat_pos, slotmask)
	end

	return high_ray
end

function CopLogicTravel.queue_update(data, my_data, delay)
	delay = delay or 0.3
	
	if my_data.waiting_for_navlink then
		delay = math.min(my_data.waiting_for_navlink - data.t, delay)
	end
	
	CopLogicBase.queue_task(my_data, my_data.upd_task_key, CopLogicTravel.queued_update, data, data.t + delay, data.important and true)
	
	my_data.waiting_for_navlink = nil
end

function CopLogicTravel._get_pos_on_wall(from_pos, max_dist, step_offset, is_recurse)
	local nav_manager = managers.navigation
	local nr_rays = 9
	local ray_dis = max_dist or 1000
	local step = 360 / nr_rays
	local offset = step_offset or math.random(360)
	local step_rot = Rotation(step)
	local offset_rot = Rotation(offset)
	local offset_vec = Vector3(ray_dis, 0, 0)

	mvector3.rotate_with(offset_vec, offset_rot)

	local to_pos = mvector3.copy(from_pos)

	mvector3.add(to_pos, offset_vec)

	local from_tracker = nav_manager:create_nav_tracker(from_pos)
	local ray_params = {
		allow_entry = false,
		trace = true,
		tracker_from = from_tracker,
		pos_to = to_pos
	}
	local rsrv_desc = {
		false,
		60
	}
	local fail_position = nil

	repeat
		to_pos = mvector3.copy(from_pos)

		mvector3.add(to_pos, offset_vec)

		ray_params.pos_to = to_pos
		local ray_res = nav_manager:raycast(ray_params)

		if ray_res then
			rsrv_desc.position = ray_params.trace[1]
			local is_free = nav_manager:is_pos_free(rsrv_desc)

			if is_free then
				managers.navigation:destroy_nav_tracker(from_tracker)

				return ray_params.trace[1]
			end
		elseif not fail_position then
			rsrv_desc.position = ray_params.trace[1]
			local is_free = nav_manager:is_pos_free(rsrv_desc)

			if is_free then
				fail_position = to_pos
			end
		end

		mvector3.rotate_with(offset_vec, step_rot)

		nr_rays = nr_rays - 1
	until nr_rays == 0

	managers.navigation:destroy_nav_tracker(from_tracker)

	if fail_position then
		return fail_position
	end

	if not is_recurse then
		return CopLogicTravel._get_pos_on_wall(from_pos, ray_dis * 0.5, offset + step * 0.5, true)
	end

	return from_pos
end