-- offy's note: this function may now be redundant?
function CivilianLogicFlee.on_rescue_SO_completed(ignore_this, data, good_pig)
	if data.internal_data.rescuer and good_pig:key() == data.internal_data.rescuer:key() then
		data.internal_data.rescue_active = nil
		data.internal_data.rescuer = nil

		if data.name == "surrender" then
			local new_action = nil

			if data.unit:anim_data().stand and data.is_tied then
				data.brain:on_hostage_move_interaction(nil, "release")
			elseif data.unit:anim_data().drop or data.unit:anim_data().tied then
				new_action = {
					variant = "stand",
					body_part = 1,
					type = "act"
				}
			end

			if data.is_tied then
				managers.network:session():send_to_peers_synched("sync_unit_surrendered", data.unit, false)
				
				data.is_tied = nil
			end

			if new_action then
				data.unit:interaction():set_active(false, true)
				data.unit:brain():action_request(new_action)
			end

			data.unit:brain():set_objective({
				is_default = true,
				was_rescued = true,
				type = "free"
			})
		else
			data.unit:base():set_slot(data.unit, 21)
			managers.network:session():send_to_peers_synched("sync_unit_event_id_16", data.unit, "brain", HuskCopBrain._NET_EVENTS.surrender_civilian_untied)

			if not CivilianLogicFlee._get_coarse_flee_path(data) then
				return
			end
		end
	end

	data.unit:brain():set_update_enabled_state(true)
	managers.groupai:state():on_civilian_freed()
	good_pig:sound():say("h01", true)
end

function CivilianLogicFlee.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.unit:brain():cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit
	}
	data.internal_data = my_data
	my_data.detection = data.char_tweak.detection.cbt

	data.unit:brain():set_update_enabled_state(false)

	local key_str = tostring(data.key)

	managers.groupai:state():register_fleeing_civilian(data.key, data.unit)

	my_data.panic_area = managers.groupai:state():get_area_from_nav_seg_id(data.unit:movement():nav_tracker():nav_segment())

	CivilianLogicFlee.reset_actions(data)

	if data.objective then
		if data.objective.alert_data then
			CivilianLogicFlee.on_alert(data, data.objective.alert_data)

			if my_data ~= data.internal_data then
				return
			end

			if data.unit:anim_data().react_enter and not data.unit:anim_data().idle then
				my_data.delayed_post_react_alert_id = "postreact_alert" .. key_str

				if data.char_tweak.faster_reactions then
					CopLogicBase.add_delayed_clbk(my_data, my_data.delayed_post_react_alert_id, callback(CivilianLogicFlee, CivilianLogicFlee, "post_react_alert_clbk", {
						data = data
					}), TimerManager:game():time() + math.lerp(2, 4, math.random()))
				else
					CopLogicBase.add_delayed_clbk(my_data, my_data.delayed_post_react_alert_id, callback(CivilianLogicFlee, CivilianLogicFlee, "post_react_alert_clbk", {
						data = data
					}), TimerManager:game():time() + math.lerp(4, 8, math.random()))
				end
			end
		elseif data.objective.dmg_info then
			CivilianLogicFlee.damage_clbk(data, data.objective.dmg_info)
		end
	end

	data.unit:movement():set_stance(data.is_tied and "cbt" or "hos")
	data.unit:movement():set_cool(false)

	if my_data ~= data.internal_data then
		return
	end

	CivilianLogicFlee._chk_add_delayed_rescue_SO(data, my_data)

	if data.objective and data.objective.was_rescued then
		data.objective.was_rescued = nil

		if CivilianLogicFlee._get_coarse_flee_path(data) then
			managers.groupai:state():on_civilian_freed()
		end
	end

	if not data.been_outlined and data.char_tweak.outline_on_discover then
		my_data.outline_detection_task_key = "CivilianLogicFlee_upd_outline_detection" .. key_str

		CopLogicBase.queue_task(my_data, my_data.outline_detection_task_key, CivilianLogicIdle._upd_outline_detection, data, data.t + 2)
	end

	if not my_data.detection_task_key and data.unit:anim_data().react_enter then
		my_data.detection_task_key = "CivilianLogicFlee._upd_detection" .. key_str

		CivilianLogicFlee._upd_detection(data)
	end

	local attention_settings = nil
	attention_settings = {
		"civ_enemy_cbt",
		"civ_civ_cbt",
		"civ_murderer_cbt"
	}

	CivilianLogicFlee.schedule_run_away_clbk(data)

	if not my_data.delayed_post_react_alert_id and data.unit:movement():stance_name() == "ntl" then
		my_data.delayed_post_react_alert_id = "postreact_alert" .. key_str
		
		if data.char_tweak.faster_reactions then
			CopLogicBase.add_delayed_clbk(my_data, my_data.delayed_post_react_alert_id, callback(CivilianLogicFlee, CivilianLogicFlee, "post_react_alert_clbk", {
				data = data
			}), TimerManager:game():time() + math.lerp(2, 4, math.random()))
		else
			CopLogicBase.add_delayed_clbk(my_data, my_data.delayed_post_react_alert_id, callback(CivilianLogicFlee, CivilianLogicFlee, "post_react_alert_clbk", {
				data = data
			}), TimerManager:game():time() + math.lerp(4, 8, math.random()))
		end
	end

	data.unit:brain():set_attention_settings(attention_settings)

	if data.char_tweak.calls_in and not managers.groupai:state():is_police_called() and managers.groupai:state():can_police_be_called() then
		my_data.call_police_clbk_id = "civ_call_police" .. key_str
		local call_t = math.max(data.call_police_delay_t or 0, TimerManager:game():time() + math.lerp(1, 10, math.random()))

		CopLogicBase.add_delayed_clbk(my_data, my_data.call_police_clbk_id, callback(CivilianLogicFlee, CivilianLogicFlee, "clbk_chk_call_the_police", data), call_t)
	end

	my_data.next_action_t = 0
end

function CivilianLogicFlee.reset_actions(data)
	local walk_action = data.unit:movement()._active_actions[2]

	if walk_action and walk_action:type() == "walk" then
		data.internal_data.old_action_advancing = true
		local action = {
			body_part = 2,
			type = "idle"
		}

		data.unit:movement():action_request(action)
	end
end

function CivilianLogicFlee.action_complete_clbk(data, action)
	local my_data = data.internal_data

	if action:type() == "walk" then
		if not my_data.old_action_advancing then
			if not data.char_tweak.faster_reactions then
				my_data.next_action_t = TimerManager:game():time() + math.lerp(2, 8, math.random())
			end

			if action:expired() then
				if my_data.moving_to_cover then
					data.unit:sound():say("a03x_any", true)

					my_data.in_cover = my_data.moving_to_cover

					CopLogicAttack._set_nearest_cover(my_data, my_data.in_cover)
					CivilianLogicFlee._chk_add_delayed_rescue_SO(data, my_data)
				end

				if my_data.coarse_path_index then
					
					my_data.coarse_path_index = my_data.coarse_path_index + 1
				end
			end
		end

		my_data.moving_to_cover = nil
		my_data.advancing = nil
		my_data.old_action_advancing = nil

		if not my_data.coarse_path_index then
			data.unit:brain():set_update_enabled_state(false)
		end
	elseif action:type() == "act" and my_data.calling_the_police then
		my_data.calling_the_police = nil

		if not my_data.called_the_police then
			managers.groupai:state():on_criminal_suspicion_progress(nil, data.unit, "call_interrupted")
		end
	end
end

function CivilianLogicFlee._run_away_from_alert(data, alert_data)
	local my_data = data.internal_data
	local avoid_pos = nil

	if alert_data[1] == "bullet" then
		local tail = alert_data[2]
		local head = alert_data[6]
		local alert_dir = head - tail
		local alert_len = mvector3.normalize(alert_dir)
		avoid_pos = data.m_pos - tail
		local my_dot = mvector3.dot(alert_dir, avoid_pos)

		mvector3.set(avoid_pos, alert_dir)
		mvector3.multiply(avoid_pos, my_dot)
		mvector3.add(avoid_pos, tail)
	else
		avoid_pos = alert_data[2] or alert_data[5] and alert_data[5]:position() or math.UP:random_orthogonal() * 100 + data.m_pos
	end

	my_data.avoid_pos = avoid_pos

	CivilianLogicFlee._find_hide_cover(data)
end

function CivilianLogicFlee.update(data)
	local exit_state = nil
	local unit = data.unit
	local my_data = data.internal_data
	local objective = data.objective
	local t = data.t

	if my_data.calling_the_police then
		-- Nothing
	elseif my_data.flee_path_search_id or my_data.coarse_path_search_id then
		CivilianLogicFlee._update_pathing(data, my_data)
	elseif my_data.flee_path then
		if not unit:movement():chk_action_forbidden("walk") then
			CivilianLogicFlee._start_moving_to_cover(data, my_data)
		end
	elseif my_data.coarse_path then
		if not my_data.advancing and my_data.next_action_t < data.t then
			local coarse_path = my_data.coarse_path
			local cur_index = my_data.coarse_path_index
			local total_nav_points = #coarse_path

			if cur_index >= total_nav_points then
				if data.unit:unit_data().mission_element then
					data.unit:unit_data().mission_element:event("fled", data.unit)
				end

				data.unit:base():set_slot(unit, 0)
			else
				local to_pos, to_cover = nil

				if cur_index == total_nav_points - 1 then
					to_pos = my_data.flee_target.pos
				else
					local next_area = managers.groupai:state():get_area_from_nav_seg_id(coarse_path[cur_index + 1][1])
					local cover = managers.navigation:find_cover_in_nav_seg_1(next_area.nav_segs)

					if cover then
						CopLogicAttack._set_best_cover(data, my_data, {
							cover
						})

						to_cover = my_data.best_cover
					else
						to_pos = CopLogicTravel._get_pos_on_wall(coarse_path[cur_index + 1][2], 700)
					end
				end

				my_data.flee_path_search_id = "civ_flee" .. tostring(data.key)

				if to_cover then
					my_data.pathing_to_cover = to_cover

					unit:brain():search_for_path_to_cover(my_data.flee_path_search_id, to_cover[1], nil, nil)
				else
					data.brain:add_pos_rsrv("path", {
						radius = 30,
						position = to_pos
					})
					unit:brain():search_for_path(my_data.flee_path_search_id, to_pos)
				end
			end
		end
	elseif my_data.best_cover then
		local best_cover = my_data.best_cover

		if not my_data.moving_to_cover or my_data.moving_to_cover ~= best_cover then
			if not my_data.in_cover or my_data.in_cover ~= best_cover then
				if not unit:anim_data().panic then
					local action_data = {
						clamp_to_graph = true,
						variant = "panic",
						body_part = 1,
						type = "act"
					}

					data.unit:brain():action_request(action_data)
					data.unit:brain():set_update_enabled_state(true)
					CopLogicBase._reset_attention(data)
				end

				my_data.pathing_to_cover = my_data.best_cover
				local search_id = "civ_cover" .. tostring(data.key)
				my_data.flee_path_search_id = search_id

				data.unit:brain():search_for_path_to_cover(search_id, my_data.best_cover[1])
			end
		end
	end
end
