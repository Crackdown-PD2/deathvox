function CivilianLogicTravel.update(data)
	local my_data = data.internal_data
	local unit = data.unit
	local objective = data.objective
	local t = data.t

	if my_data.has_old_action then
		CivilianLogicTravel._upd_stop_old_action(data, my_data)
		
		if my_data.has_old_action then
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
			CivilianLogicTravel._on_destination_reached(data)
		end
	elseif my_data.processing_advance_path or my_data.processing_coarse_path then
		local was_processing_advance = my_data.processing_advance_path and true
		CivilianLogicEscort._upd_pathing(data, my_data)
		
		if was_processing_advance and my_data.advance_path then
			CopLogicAttack._correct_path_start_pos(data, my_data.advance_path)

			local end_rot = nil

			if my_data.coarse_path_index == #my_data.coarse_path - 1 then
				end_rot = objective and objective.rot
			end

			local haste = objective and objective.haste or "walk"
			local new_action_data = {
				type = "walk",
				body_part = 2,
				nav_path = my_data.advance_path,
				variant = haste,
				end_rot = end_rot
			}
			my_data.starting_advance_action = true
			my_data.advancing = data.unit:brain():action_request(new_action_data)
			my_data.starting_advance_action = false

			if my_data.advancing then
				my_data.advance_path = nil

				data.brain:rem_pos_rsrv("path")
			end
		elseif my_data.coarse_path then
			local coarse_path = my_data.coarse_path
			local cur_index = my_data.coarse_path_index
			local total_nav_points = #coarse_path

			if cur_index >= total_nav_points then
				objective.in_place = true

				if objective.type ~= "escort" and objective.type ~= "act" and objective.type ~= "follow" and not objective.action_duration then
					data.objective_complete_clbk(unit, objective)
				else
					CivilianLogicTravel.on_new_objective(data)
				end

				return
			else
				data.brain:rem_pos_rsrv("path")

				local to_pos = nil

				if cur_index == total_nav_points - 1 then
					to_pos = CivilianLogicTravel._determine_exact_destination(data, objective)
				else
					to_pos = coarse_path[cur_index + 1][2]
				end

				my_data.processing_advance_path = true

				unit:brain():search_for_path(my_data.advance_path_search_id, to_pos)
			end
		end
	elseif my_data.advancing then
		-- Nothing
	elseif my_data.advance_path then
		CopLogicAttack._correct_path_start_pos(data, my_data.advance_path)

		local end_rot = nil

		if my_data.coarse_path_index == #my_data.coarse_path - 1 then
			end_rot = objective and objective.rot
		end

		local haste = objective and objective.haste or "walk"
		local new_action_data = {
			type = "walk",
			body_part = 2,
			nav_path = my_data.advance_path,
			variant = haste,
			end_rot = end_rot
		}
		my_data.starting_advance_action = true
		my_data.advancing = data.unit:brain():action_request(new_action_data)
		my_data.starting_advance_action = false

		if my_data.advancing then
			my_data.advance_path = nil

			data.brain:rem_pos_rsrv("path")
		end
	elseif objective then
		if not my_data.coarse_path and my_data.is_hostage then
			local nav_seg = nil

			if objective.follow_unit then
				nav_seg = objective.follow_unit:movement():nav_tracker():nav_segment()
			else
				nav_seg = objective.nav_seg
			end
		
			my_data.coarse_path = unit:brain():search_for_coarse_immediate(my_data.coarse_path_search_id, nav_seg)
			
			if my_data.coarse_path then
				my_data.coarse_path_index = 1
			end
		end
	
		if my_data.coarse_path then
			local coarse_path = my_data.coarse_path
			local cur_index = my_data.coarse_path_index
			local total_nav_points = #coarse_path

			if cur_index >= total_nav_points then
				objective.in_place = true

				if objective.type ~= "escort" and objective.type ~= "act" and objective.type ~= "follow" and not objective.action_duration then
					data.objective_complete_clbk(unit, objective)
				else
					CivilianLogicTravel.on_new_objective(data)
				end

				return
			else
				if coarse_path[cur_index + 1][3] and alive(coarse_path[cur_index + 1][3]) and coarse_path[cur_index + 1][3]:delay_time() > data.t then
					return
				elseif coarse_path[cur_index + 1][4] then
					local entry_found
					local all_nav_segments = managers.navigation._nav_segments
					local target_seg_id = coarse_path[cur_index + 1][1]
					local my_seg = all_nav_segments[coarse_path[cur_index][1]]
					local neighbours = my_seg.neighbours

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
			
				data.brain:rem_pos_rsrv("path")

				local to_pos = nil

				if cur_index == total_nav_points - 1 then
					to_pos = CivilianLogicTravel._determine_exact_destination(data, objective)
				else
					to_pos = coarse_path[cur_index + 1][2]
				end

				my_data.processing_advance_path = true

				unit:brain():search_for_path(my_data.advance_path_search_id, to_pos)
			end
		else
			local nav_seg = nil

			if objective.follow_unit then
				nav_seg = objective.follow_unit:movement():nav_tracker():nav_segment()
			else
				nav_seg = objective.nav_seg
			end

			if unit:brain():search_for_coarse_path(my_data.coarse_path_search_id, nav_seg) then
				my_data.processing_coarse_path = true
			end
		end
	else
		CopLogicBase._exit(data.unit, "idle")
	end
end