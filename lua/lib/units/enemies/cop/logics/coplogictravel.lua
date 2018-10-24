function CopLogicTravel._get_exact_move_pos(data, nav_index) --This just gets a exact movement position for the enemies to use.
	local my_data = data.internal_data
	local objective = data.objective
	local to_pos = nil
	local coarse_path = my_data.coarse_path
	local total_nav_points = #coarse_path
	local reservation, wants_reservation = nil

	if total_nav_points <= nav_index then
		local new_occupation = data.logic._determine_destination_occupation(data, objective)

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

					if data.char_tweak.wall_fwd_offset then
						to_pos = CopLogicTravel.apply_wall_offset_to_cover(data, my_data, new_occupation.cover[1], data.char_tweak.wall_fwd_offset)
					end

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
			to_pos = managers.navigation:find_random_position_in_segment(objective.nav_seg)
			to_pos = CopLogicTravel._get_pos_on_wall(to_pos)
			wants_reservation = true
		end
	else
		local nav_seg = coarse_path[nav_index][1]
		local area = managers.groupai:state():get_area_from_nav_seg_id(nav_seg)
		local cover = managers.navigation:find_cover_in_nav_seg_1(area.nav_segs)

		if my_data.moving_to_cover then
			managers.navigation:release_cover(my_data.moving_to_cover[1])

			my_data.moving_to_cover = nil
		end

		if cover then
			managers.navigation:reserve_cover(cover, data.pos_rsrv_id)

			my_data.moving_to_cover = {cover}
			to_pos = cover[1]
		else
			to_pos = coarse_path[nav_index][2]
		end
	end

	if not reservation and wants_reservation then
		data.brain:add_pos_rsrv("path", {
			radius = 100, --Increased from 60 to 100, possibly reduces cases of enemies piling up together?
			position = mvector3.copy(to_pos)
		})
	end

	return to_pos
end

function CopLogicTravel.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.unit:brain():cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {unit = data.unit}
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

	local objective = data.objective
	local path_data = objective.path_data

	if objective.path_style == "warp" then
		my_data.warp_pos = objective.pos
	elseif path_data then
		local path_style = objective.path_style

		if path_style == "precise" then
			local path = {mvector3.copy(data.m_pos)}

			for _, point in ipairs(path_data.points) do
				table.insert(path, mvector3.copy(point.position))
			end

			my_data.advance_path = path
			my_data.coarse_path_index = 1
			local start_seg = data.unit:movement():nav_tracker():nav_segment()
			local end_pos = mvector3.copy(path[#path])
			local end_seg = managers.navigation:get_nav_seg_from_pos(end_pos)
			my_data.coarse_path = {
				{start_seg},
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
			local path = {{start_seg}}

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
		data.unit:brain():set_attention_settings({peaceful = true})
	else
		data.unit:brain():set_attention_settings({cbt = true})
	end

	my_data.attitude = data.objective.attitude or "avoid"
	my_data.weapon_range = data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range
	if not data.team then
		data.unit:movement():set_team(managers.groupai:state()._teams["law1"])
		if data.team then
			
		end
	end
	my_data.path_safely = data.team.foes[tweak_data.levels:get_default_team_ID("player")]
	my_data.path_ahead = data.objective.path_ahead or data.team.id == tweak_data.levels:get_default_team_ID("player")

	data.unit:brain():set_update_enabled_state(false)
end