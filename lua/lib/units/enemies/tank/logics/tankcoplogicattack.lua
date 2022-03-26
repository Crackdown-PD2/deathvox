local mvec3_cpy = mvector3.copy
local mvec3_not_equal = mvector3.not_equal

local math_abs = math.abs

local REACT_AIM = AIAttentionObject.REACT_AIM
local REACT_COMBAT = AIAttentionObject.REACT_COMBAT

--TankCopLogicAttack = class(CopLogicAttack)

function TankCopLogicAttack.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.brain:cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit
	}
	my_data.detection = data.char_tweak.detection.combat

	if old_internal_data then
		my_data.turning = old_internal_data.turning
		my_data.firing = old_internal_data.firing
		my_data.shooting = old_internal_data.shooting
		my_data.attention_unit = old_internal_data.attention_unit
	end

	data.internal_data = my_data

	if data.cool then
		data.unit:movement():set_cool(false)

		if my_data ~= data.internal_data then
			return
		end
	end

	if not my_data.shooting then
		local new_stance = nil

		if not data.char_tweak.allowed_stances or data.char_tweak.allowed_stances.hos then
			new_stance = "hos"
		elseif data.char_tweak.allowed_stances.cbt then
			new_stance = "cbt"
		end

		if new_stance then
			data.unit:movement():set_stance(new_stance)

			if my_data ~= data.internal_data then
				return
			end
		end
	end

	local objective = data.objective

	my_data.attitude = objective and objective.attitude or "avoid"
	
	if not data.unit:base():has_tag("law") then
		my_data.attitude = "engage"
	end
	
	my_data.weapon_range = data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range
	
	if data.tactics and data.tactics.flank then
		my_data.use_flank_pos_when_chasing = true
	end
	
	if data.unit:base():has_tag("backliner") then
		my_data.use_medic_positioning = true
	end
	
	if data.unit:base():has_tag("no_run") then
		my_data.no_running = true
	end
	
	local key_str = tostring(data.key)
	
	if not data.extreme_ai_priority then
		my_data.detection_task_key = "TankLogicAttack._upd_enemy_detection" .. key_str

		CopLogicBase.queue_task(my_data, my_data.detection_task_key, TankCopLogicAttack._upd_enemy_detection, data, data.t, true)
	end

	CopLogicIdle._chk_has_old_action(data, my_data)

	if objective then
		if objective.action_duration or objective.action_timeout_t and data.t < objective.action_timeout_t then
			my_data.action_timeout_clbk_id = "CopLogicIdle_action_timeout" .. key_str
			local action_timeout_t = objective.action_timeout_t or data.t + objective.action_duration
			objective.action_timeout_t = action_timeout_t

			CopLogicBase.add_delayed_clbk(my_data, my_data.action_timeout_clbk_id, callback(CopLogicIdle, CopLogicIdle, "clbk_action_timeout", data), action_timeout_t)
		end
	end

	data.brain:set_attention_settings({
		cbt = true
	})
	data.brain:set_update_enabled_state(true)
end

function TankCopLogicAttack.exit(data, new_logic_name, enter_params)
	CopLogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	TankCopLogicAttack._cancel_chase_attempt(data, my_data)
	data.brain:cancel_all_pathing_searches()
	CopLogicBase.cancel_queued_tasks(my_data)
	CopLogicBase.cancel_delayed_clbks(my_data)
	data.brain:rem_pos_rsrv("path")
	data.brain:set_update_enabled_state(true)
end

function TankCopLogicAttack.update(data)
	local t = data.t
	local unit = data.unit
	local my_data = data.internal_data

	if my_data.has_old_action then
		CopLogicAttack._upd_stop_old_action(data, my_data)

		
		if my_data.has_old_action then
			return
		end
	end

	if CopLogicIdle._chk_relocate(data) or CopLogicAttack._chk_exit_non_walkable_area(data) then
		return
	end

	if not data.attention_obj or data.attention_obj.reaction < REACT_AIM then
		TankCopLogicAttack._upd_enemy_detection(data, true)

		if my_data ~= data.internal_data then
			return
		end
	end

	if data.is_converted then
		if not data.objective or data.objective.type == "free" then
			if not data.path_fail_t or data.t - data.path_fail_t > 6 then
				managers.groupai:state():on_criminal_jobless(data.unit)

				if my_data ~= data.internal_data then
					return
				end
			end
		end
	end

	TankCopLogicAttack._process_pathing_results(data, my_data)

	if data.attention_obj and REACT_COMBAT <= data.attention_obj.reaction then
		if data.unit:base():has_tag("law") then
			my_data.attitude = data.objective and data.objective.attitude or "avoid"
		end
		
		my_data.want_to_take_cover = CopLogicAttack._chk_wants_to_take_cover(data, my_data)
		TankCopLogicAttack._upd_combat_movement(data)
	else
		TankCopLogicAttack._cancel_chase_attempt(data, my_data)
	end
end

function TankCopLogicAttack._upd_enemy_detection_high_def(data, is_synchronous)
	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local min_reaction = REACT_AIM
	local delay = CopLogicBase._upd_attention_obj_detection(data, min_reaction, nil)
	local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, data.detected_attention_objects, nil)
	local old_att_obj = data.attention_obj

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)
	data.logic._chk_exit_attack_logic(data, new_reaction)

	if my_data ~= data.internal_data then
		return
	end

	if not new_attention and old_att_obj then
		TankCopLogicAttack._cancel_chase_attempt(data, my_data)
	end

	CopLogicBase._chk_call_the_police(data)

	if my_data ~= data.internal_data then
		return
	end

	CopLogicAttack._upd_aim(data, my_data)

	CopLogicBase._report_detections(data.detected_attention_objects)
end

function TankCopLogicAttack._upd_enemy_detection(data, is_synchronous)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local min_reaction = REACT_AIM
	local delay = CopLogicBase._upd_attention_obj_detection(data, min_reaction, nil)
	local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, data.detected_attention_objects, nil)
	local old_att_obj = data.attention_obj

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)
	data.logic._chk_exit_attack_logic(data, new_reaction)

	if my_data ~= data.internal_data then
		return
	end

	if not new_attention and old_att_obj then
		TankCopLogicAttack._cancel_chase_attempt(data, my_data)
	end

	CopLogicBase._chk_call_the_police(data)

	if my_data ~= data.internal_data then
		return
	end

	CopLogicAttack._upd_aim(data, my_data)

	if not is_synchronous and my_data.detection_task_key then
		CopLogicBase.queue_task(my_data, my_data.detection_task_key, TankCopLogicAttack._upd_enemy_detection, data, data.t + delay, data.important and true)
	end

	CopLogicBase._report_detections(data.detected_attention_objects)
end

function TankCopLogicAttack._chk_start_action_move_back(data, my_data, focus_enemy)
	if not focus_enemy or not focus_enemy.verified or not CopLogicAttack._can_move(data) then
		return
	end

	local attempt_retreat = nil
	local vis_required = nil
	local want_to_move_back = my_data.want_to_move_back
	local max_walk_dis = 300
	local haste = "walk"
	
	if want_to_move_back then
		attempt_retreat = true
		
		if want_to_move_back == "spoocavoidance" then
			haste = "run"
			max_walk_dis = 2000
		elseif want_to_move_back == "hitnrun" then
			vis_required = nil
			haste = "run"
			max_walk_dis = 800
		elseif want_to_move_back == "eliterangedfire" or want_to_move_back == "reload" then
			if want_to_move_back == "elite_ranged_fire" then
				vis_required = true
			else
				haste = "run"
			end
			
			max_walk_dis = my_data.weapon_range.optimal * 0.5
		elseif want_to_move_back == "heavyfire" then
			max_walk_dis = 1000
		end
	elseif focus_enemy.dis < 300 then
		attempt_retreat = true
	end

	if not attempt_retreat then
		return
	end

	local threat_tracker = focus_enemy.nav_tracker
	local temp_tracker = nil

	if vis_required and not threat_tracker then --this shouldn't even happen, but just in case, we want the unit to still be able to retreat
		local tracker_pos = mvec3_cpy(focus_enemy.m_pos)
		threat_tracker = managers.navigation:create_nav_tracker(tracker_pos)
		temp_tracker = true
	end

	local from_pos = mvec3_cpy(data.m_pos)
	local threat_head_pos = focus_enemy.m_head_pos
	
	local pose = "stand"
	local end_pose = "stand"

	local retreat_to = CopLogicAttack._find_retreat_position(data, from_pos, focus_enemy.m_pos, threat_head_pos, threat_tracker, max_walk_dis, vis_required, end_pose)

	if retreat_to then
		CopLogicAttack._cancel_cover_pathing(data, my_data)

		local new_action_data = {
			variant = haste or "walk",
			body_part = 2,
			type = "walk",
			nav_path = {
				from_pos,
				retreat_to
			},
			pose = pose,
			end_pose = end_pose
		}
		my_data.advancing = data.brain:action_request(new_action_data)

		if my_data.advancing then		
			my_data.surprised = true

			data.brain:rem_pos_rsrv("path")

			if temp_tracker then
				managers.navigation:destroy_nav_tracker(threat_tracker)
			end

			return true
		end
	end

	if temp_tracker then
		managers.navigation:destroy_nav_tracker(threat_tracker)
	end
end

function TankCopLogicAttack._chk_wants_to_take_cover(data, my_data)
	if not data.attention_obj or data.attention_obj.reaction < REACT_COMBAT then
		return
	end
	
	if data.tactics then
		if data.tactics.spoocavoidance and data.attention_obj.dis < 2000 and data.attention_obj.aimed_at then
			return "spoocavoidance"
		elseif data.tactics.reloadingretreat and data.unit:anim_data().reload then
			return "reload"
		elseif data.tactics.elite_ranged_fire and data.attention_obj.verified and data.attention_obj.verified_dis < my_data.weapon_range.optimal * 0.5 then
			return "eliterangedfire"
		elseif data.tactics.hitnrun and data.attention_obj.verified and data.attention_obj.verified_dis < 800 then
			return "hitnrun"
		end
	end
end

local math_lerp = math.lerp
local math_random = math.random

function TankCopLogicAttack._walk_around_menacingly(data, my_data) 
	local my_pos = data.unit:movement():nav_tracker():field_position()
	local dis = math_lerp(200, 600, math_random())
	local menacing_pos = CopLogicTravel._find_near_free_pos(my_pos, dis, nil, data.pos_rsrv_id)

	if menacing_pos then
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		local path = {
			mvec3_cpy(data.m_pos),
			menacing_pos
		}
		CopLogicAttack._correct_path_start_pos(data, path)
		
		
		local new_action_data = {
			variant = "walk",
			body_part = 2,
			type = "walk",
			nav_path = path,
			pose = "stand",
			end_pose = "stand"
		}
		my_data.advancing = data.brain:action_request(new_action_data)

		if my_data.advancing then		
			my_data.menacing = true

			data.brain:rem_pos_rsrv("path")

			return true
		end
	end
end

function TankCopLogicAttack._upd_combat_movement(data)
	local t = data.t
	local my_data = data.internal_data
	local focus_enemy = data.attention_obj
	local enemy_visible = focus_enemy.verified
	local action_taken = data.logic.action_taken(data, my_data)
	local chase = nil
	local engage = not my_data.use_medic_positioning and my_data.attitude == "engage"
	local no_run = my_data.no_running

	if not action_taken then
		local enemy_dis = focus_enemy.dis
		local run_dist = enemy_visible and 800 or 600
		local should_try_chase = nil
		local height_diff = math_abs(data.m_pos.z - focus_enemy.m_pos.z)
		
		if engage then
			should_try_chase = height_diff > 300 or not enemy_visible or enemy_dis > 300
		else
			should_try_chase = enemy_visible or focus_enemy.verified_t and t - focus_enemy.verified_t < 4
			
			if should_try_chase then
				if not no_run then
					if not enemy_visible then
						run_dist = run_dist * 0.5
					end
				end
				
				should_try_chase = height_diff < 300 and enemy_dis < 600
			else
				should_try_chase = nil
			end
		end
		
		if should_try_chase then
			if data.important or not my_data.chase_path_failed_t or t - my_data.chase_path_failed_t > 1 then --helps not nuking performance if there's too many Dozers in attack logic
				local speed = no_run and "walk" or enemy_dis < run_dist and "walk" or "run"
				
				--log(speed)
				
				if my_data.chase_path then
					action_taken = TankCopLogicAttack._chk_request_action_walk_to_chase_pos(data, my_data, speed)
				elseif not my_data.chase_path_search_id and focus_enemy.nav_tracker then
					my_data.chase_pos = nil

					if my_data.use_flank_pos_when_chasing then
						my_data.chase_pos = CopLogicAttack._find_flank_pos(data, my_data, focus_enemy.nav_tracker, 300)
					else
						local chase_pos = focus_enemy.nav_tracker:field_position()
						local pos_on_wall = CopLogicTravel._find_near_free_pos(chase_pos, 300, nil, data.pos_rsrv_id)

						if mvec3_not_equal(chase_pos, pos_on_wall) then
							my_data.chase_pos = pos_on_wall
						end
					end

					if my_data.chase_pos then
						local my_pos = data.unit:movement():nav_tracker():field_position()
						local unobstructed_line = nil

						if math_abs(my_pos.z - my_data.chase_pos.z) < 40 then
							local ray_params = {
								allow_entry = false,
								pos_from = my_pos,
								pos_to = my_data.chase_pos
							}

							if not managers.navigation:raycast(ray_params) then
								unobstructed_line = true
							end
						end

						if unobstructed_line then
							my_data.chase_path = {
								mvec3_cpy(my_pos),
								my_data.chase_pos
							}

							--[[local line = Draw:brush(Color.blue:with_alpha(0.5), 5)
							line:cylinder(my_pos, my_data.chase_pos, 25)]]

							action_taken = TankCopLogicAttack._chk_request_action_walk_to_chase_pos(data, my_data, speed)
						else
							my_data.chase_path_search_id = tostring(data.unit:key()) .. "chase"
							my_data.pathing_to_chase_pos = true

							data.brain:add_pos_rsrv("path", {
								radius = 60,
								position = mvec3_cpy(my_data.chase_pos)
							})
							data.brain:search_for_path(my_data.chase_path_search_id, my_data.chase_pos)
						end
					else
						my_data.chase_path_failed_t = t
					end
				end
			end
		elseif not action_taken then
			if focus_enemy.aimed_at then
				action_taken = TankCopLogicAttack._walk_around_menacingly(data, my_data)
			end
		end
		 		
		action_taken = action_taken or TankCopLogicAttack._chk_start_action_move_out_of_the_way(data, my_data)
	end
end

function TankCopLogicAttack.queued_update(data)
	local my_data = data.internal_data
	data.t = TimerManager:game():time()

	TankCopLogicAttack.update(data)

	if my_data == data.internal_data then
		TankCopLogicAttack.queue_update(data, data.internal_data)
	end
end

function TankCopLogicAttack._process_pathing_results(data, my_data)
	if data.pathing_results then
		local pathing_results = data.pathing_results
		data.pathing_results = nil
		local path = pathing_results[my_data.chase_path_search_id]

		if path then
			if path ~= "failed" then
				my_data.chase_path = path
			else
				--print("[TankCopLogicAttack._process_pathing_results] chase path failed")
				my_data.chase_path_failed_t = data.t
			end

			my_data.pathing_to_chase_pos = nil
			my_data.chase_path_search_id = nil
		end
	end
end

function TankCopLogicAttack._cancel_chase_attempt(data, my_data, only_cancel_pathing)
	my_data.chase_path = nil

	if my_data.walking_to_chase_pos and not my_data.exiting and not data.unit:movement():chk_action_forbidden("walk") then
		local new_action = {
			body_part = 2,
			type = "idle"
		}

		data.brain:action_request(new_action)
	end

	if my_data.pathing_to_chase_pos then
		data.brain:rem_pos_rsrv("path")

		if data.active_searches[my_data.chase_path_search_id] then
			managers.navigation:cancel_pathing_search(my_data.chase_path_search_id)

			data.active_searches[my_data.chase_path_search_id] = nil
		elseif data.pathing_results then
			data.pathing_results[my_data.chase_path_search_id] = nil
		end

		my_data.chase_path_search_id = nil
		my_data.pathing_to_chase_pos = nil

		data.brain:cancel_all_pathing_searches()
	end

	my_data.chase_pos = nil
end

function TankCopLogicAttack.action_complete_clbk(data, action)
	local action_type = action:type()
	local my_data = data.internal_data

	if action_type == "walk" then
		my_data.advancing = nil

		if my_data.walking_to_chase_pos then
			my_data.walking_to_chase_pos = nil
		end

		if my_data.moving_out_of_the_way then
			my_data.moving_out_of_the_way = nil
		end

		if my_data.surprised then
			my_data.surprised = false
		end

		TankCopLogicAttack._cancel_chase_attempt(data, my_data)

		if my_data.menacing then
			my_data.menacing = nil
		end
		
		if action:expired() then
			if data.attention_obj and REACT_COMBAT <= data.attention_obj.reaction then
				TankCopLogicAttack._upd_combat_movement(data)
			end
		end
	elseif action_type == "shoot" then
		my_data.shooting = nil
	elseif action_type == "reload" or action_type == "heal" or action_type == "healed" then
		if action:expired() then
			CopLogicAttack._upd_aim(data, my_data)
		end
	elseif action_type == "act" then
		if my_data.gesture_arrest then
			my_data.gesture_arrest = nil
		elseif action:expired() then
			CopLogicAttack._upd_aim(data, my_data)
		end
	elseif action_type == "turn" then
		my_data.turning = nil
	elseif action_type == "hurt" then
		TankCopLogicAttack._cancel_chase_attempt(data, my_data)

		if action:expired() and action:hurt_type() ~= "death" then
			CopLogicAttack._upd_aim(data, my_data)
		end
	end
end

function TankCopLogicAttack.chk_should_turn(data, my_data)
	return not my_data.turning and not my_data.has_old_action and not my_data.advancing and not my_data.walking_to_chase_pos and not my_data.moving_out_of_the_way and not my_data.menacing and not data.unit:movement():chk_action_forbidden("walk")
end

function TankCopLogicAttack.action_taken(data, my_data)
	return my_data.turning or my_data.has_old_action or my_data.advancing or my_data.walking_to_chase_pos or my_data.moving_out_of_the_way or my_data.menacing or data.unit:movement():chk_action_forbidden("walk")
end

function TankCopLogicAttack.queue_update(data, my_data)
	local delay = data.important and 0 or 0.2

	CopLogicBase.queue_task(my_data, my_data.update_queue_id, TankCopLogicAttack.queued_update, data, data.t + delay, data.important and true)
end

function TankCopLogicAttack._chk_request_action_walk_to_chase_pos(data, my_data, speed)
	if not data.unit:movement():chk_action_forbidden("walk") then
		CopLogicAttack._correct_path_start_pos(data, my_data.chase_path)

		local new_action_data = {
			type = "walk",
			body_part = 2,
			nav_path = my_data.chase_path,
			variant = speed or "walk"
		}
		my_data.chase_path = nil
		my_data.advancing = data.brain:action_request(new_action_data)

		if my_data.advancing then
			my_data.walking_to_chase_pos = my_data.advancing
			data.brain:rem_pos_rsrv("path")

			return true
		end
	end
end

function TankCopLogicAttack._chk_start_action_move_out_of_the_way(data, my_data)
	local reservation = {
		radius = 30,
		position = data.m_pos,
		filter = data.pos_rsrv_id
	}

	if not managers.navigation:is_pos_free(reservation) then
		local to_pos = CopLogicTravel._find_near_free_pos(data.m_pos, 500, nil, data.pos_rsrv_id)

		if to_pos then
			local path = {
				mvec3_cpy(data.m_pos),
				to_pos
			}
			CopLogicAttack._correct_path_start_pos(data, path)
			
			local new_action_data = {
				type = "walk",
				body_part = 2,
				nav_path = path,
				variant = "walk"
			}
			my_data.advancing = data.brain:action_request(new_action_data)

			if my_data.advancing then
				my_data.moving_out_of_the_way = my_data.advancing

				TankCopLogicAttack._cancel_chase_attempt(data, my_data)

				return true
			end
		end
	end
end

function TankCopLogicAttack.is_advancing(data)
	if data.internal_data.advancing then
		return data.internal_data.advancing:get_walk_to_pos()
	end

	if data.internal_data.moving_out_of_the_way then
		return data.internal_data.moving_out_of_the_way:get_walk_to_pos()
	end

	if data.internal_data.walking_to_chase_pos then
		return data.internal_data.walking_to_chase_pos:get_walk_to_pos()
	end
end

function TankCopLogicAttack._get_all_paths(data)
	return {
		chase_path = data.internal_data.chase_path
	}
end

function TankCopLogicAttack._set_verified_paths(data, verified_paths)
	data.internal_data.chase_path = verified_paths.chase_path
end
