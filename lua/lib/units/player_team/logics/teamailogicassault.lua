local mvec3_dis_sq = mvector3.distance_sq
local mvec3_cpy = mvector3.copy

local math_up = math.UP
local math_lerp = math.lerp
local math_random = math.random
local math_min = math.min
local math_abs = math.abs

local REACT_AIM = AIAttentionObject.REACT_AIM
local REACT_COMBAT = AIAttentionObject.REACT_COMBAT
TeamAILogicAssault._COVER_CHK_INTERVAL = 0.2

function TeamAILogicAssault.enter(data, new_logic_name, enter_params)
	TeamAILogicBase.enter(data, new_logic_name, enter_params)
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

		CopLogicAttack._set_best_cover(data, my_data, old_internal_data.best_cover)
		CopLogicAttack._set_nearest_cover(my_data, old_internal_data.nearest_cover)
	end

	data.internal_data = my_data

	if data.cool then
		data.unit:movement():set_cool(false)

		if my_data ~= data.internal_data then
			return
		end
	end

	local objective = data.objective

	if not my_data.shooting then
		local new_stance = objective and objective.stance ~= "ntl" and objective.stance or "hos"

		if data.char_tweak.allowed_stances then
			if data.char_tweak.allowed_stances.hos then
				new_stance = "hos"
			elseif data.char_tweak.allowed_stances.cbt then
				new_stance = "cbt"
			end
		end

		if new_stance then
			data.unit:movement():set_stance(new_stance)

			if my_data ~= data.internal_data then
				return
			end
		end
	end

	my_data.cover_test_step = 1
	my_data.cover_chk_t = data.t

	CopLogicIdle._chk_has_old_action(data, my_data)

	local key_str = tostring(data.key)
	my_data.detection_task_key = "TeamAILogicAssault._upd_enemy_detection" .. key_str

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicAssault._upd_enemy_detection, data, data.t, true)

	if objective then
		if objective.action_duration or objective.action_timeout_t and data.t < objective.action_timeout_t then
			my_data.action_timeout_clbk_id = "TeamAILogicIdle_action_timeout" .. key_str
			local action_timeout_t = objective.action_timeout_t or data.t + objective.action_duration
			objective.action_timeout_t = action_timeout_t

			CopLogicBase.add_delayed_clbk(my_data, my_data.action_timeout_clbk_id, callback(CopLogicIdle, CopLogicIdle, "clbk_action_timeout", data), action_timeout_t)
		end
	end

	my_data.attitude = objective and objective.attitude or "avoid"
	my_data.weapon_range = data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range
end

function TeamAILogicAssault.exit(data, new_logic_name, enter_params)
	TeamAILogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	data.brain:cancel_all_pathing_searches()
	CopLogicBase.cancel_queued_tasks(my_data)
	CopLogicBase.cancel_delayed_clbks(my_data)

	if my_data.best_cover then
		managers.navigation:release_cover(my_data.best_cover[1])
	end

	if my_data.nearest_cover then
		managers.navigation:release_cover(my_data.nearest_cover[1])
	end

	data.brain:rem_pos_rsrv("path")
end

function TeamAILogicAssault.update(data)
	local my_data = data.internal_data

	if my_data.has_old_action then
		CopLogicAttack._upd_stop_old_action(data, my_data)

		return
	end
	
	if CopLogicAttack._chk_exit_non_walkable_area(data) then
		return
	end

	if not data.attention_obj or data.attention_obj.reaction < REACT_AIM then
		TeamAILogicAssault._upd_enemy_detection(data, true)

		if my_data ~= data.internal_data then
			return
		end
	end

	if not data.objective or data.objective.type == "free" then
		if not data.path_fail_t or data.t - data.path_fail_t > 1 then
			managers.groupai:state():on_criminal_jobless(data.unit)

			if my_data ~= data.internal_data then
				return
			end
		end
	end

	local should_stay = data.unit:movement()._should_stay

	if should_stay then
		if not my_data.chk_after_staying then
			local best_cover = my_data.best_cover

			if best_cover then
				local cover_release_dis_sq = 10000
				local check_pos = nil

				if my_data.advancing then
					if data.pos_rsrv.move_dest then
						check_pos = data.pos_rsrv.move_dest.position
					else
						check_pos = my_data.advancing:get_walk_to_pos()
					end
				else
					check_pos = data.m_pos
				end

				if cover_release_dis_sq < mvec3_dis_sq(best_cover[1][1], check_pos) then
					CopLogicAttack._set_best_cover(data, my_data, nil)
				end
			end

			CopLogicAttack._cancel_cover_pathing(data, my_data)
			data.brain:rem_pos_rsrv("path")

			my_data.chk_after_staying = true
		end

		return
	elseif my_data.chk_after_staying then
		my_data.chk_after_staying = nil
	end

	CopLogicAttack._process_pathing_results(data, my_data)

	if data.attention_obj and REACT_COMBAT <= data.attention_obj.reaction then
		
		if not should_stay then
			my_data.want_to_take_cover = TeamAILogicAssault._chk_wants_to_take_cover(data, my_data)
		end

		CopLogicAttack._update_cover(data)
		
		
		--[[uncomment for debug drawings
		if my_data.moving_to_cover then
			local line = Draw:brush(Color.blue:with_alpha(0.5), 0.01)
			line:cylinder(data.m_pos, my_data.moving_to_cover[1][1], 5)
			line:cylinder(my_data.moving_to_cover[1][1], my_data.moving_to_cover[1][1] + math_up * 185, 5)
		elseif my_data.best_cover then
			local line = Draw:brush(Color.green:with_alpha(0.5), 0.01)
			line:cylinder(data.m_pos, my_data.best_cover[1][1], 5)
			line:cylinder(my_data.best_cover[1][1], my_data.best_cover[1][1] + math_up * 185, 5)
		end
			
		if my_data.in_cover then
			local line = Draw:brush(Color.red:with_alpha(0.5), 0.01)
			line:cylinder(my_data.best_cover[1][1], my_data.best_cover[1][1] + math_up * 185, 100)
		end]]
		
		if not should_stay then
			TeamAILogicAssault._upd_combat_movement(data)
		end
	end

	if not data.logic.action_taken and not should_stay then
		CopLogicAttack._chk_start_action_move_out_of_the_way(data, my_data)
	end
end

function TeamAILogicAssault._chk_wants_to_take_cover(data, my_data)
	if not data.attention_obj or data.attention_obj.reaction < REACT_COMBAT then
		return
	end
	
	if data.unit:movement()._should_stay then
		return
	end
	
	if my_data.moving_to_cover then 
		return true
	end
	
	if data.unit:character_damage()._health_ratio < 0.75 then
		return true
	end
end

function TeamAILogicAssault._upd_combat_movement(data)
	local my_data = data.internal_data
	local t = data.t
	local unit = data.unit
	local focus_enemy = data.attention_obj
	local action_taken = nil
	local want_to_take_cover = my_data.want_to_take_cover	
	
	action_taken = action_taken or data.logic.action_taken(data, my_data)
	
	if action_taken then
		return
	end

	local soft_t = 2
	local softer_t = 7

	local enemy_visible_soft = focus_enemy.verified_t and t - focus_enemy.verified_t < soft_t
	local enemy_visible_softer = focus_enemy.verified_t and t - focus_enemy.verified_t < softer_t

	if my_data.cover_test_step ~= 1 and not enemy_visible_softer then
		if action_taken or want_to_take_cover or not my_data.in_cover then
			my_data.cover_test_step = 1
		end
	end

	local remove_stay_out_time = nil

	if my_data.stay_out_time then
		if enemy_visible_soft or not my_data.at_cover_shoot_pos or action_taken or want_to_take_cover then
			remove_stay_out_time = true
		end
	end

	if remove_stay_out_time then
		my_data.stay_out_time = nil
	elseif not my_data.stay_out_time and not enemy_visible_soft and my_data.at_cover_shoot_pos and not action_taken and not want_to_take_cover then
		my_data.stay_out_time = t + softer_t
	end
	
	local in_cover = my_data.in_cover
	local best_cover = my_data.best_cover
	
	local move_to_cover, want_flank_cover = nil
	
	if not action_taken then
		if my_data.at_cover_shoot_pos then
			if not my_data.stay_out_time or my_data.stay_out_time < t then
				move_to_cover = true
				
				if my_data.cover_test_step > 2 then
					want_flank_cover = true
				end
			end
		elseif in_cover and not want_to_take_cover and not enemy_visible_soft then
			if my_data.cover_test_step <= 2 then
				local height = nil

				if best_cover[4] then --has obstructed high_ray
					height = 180
				else
					height = 90
				end

				local my_tracker = unit:movement():nav_tracker()
				local shoot_from_pos = CopLogicAttack._peek_for_pos_sideways(data, my_data, my_tracker, focus_enemy.m_head_pos, height)

				if shoot_from_pos then
					local path = {
						mvec3_cpy(data.m_pos),
						shoot_from_pos
					}
					action_taken = CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, "walk")
				else
					my_data.cover_test_step = my_data.cover_test_step + 1
					
					if my_data.cover_test_step > 2 then
						move_to_cover = true
						want_flank_cover = true
					end
				end
			end
		elseif not in_cover then
			if not my_data.cover_enter_t or data.t - my_data.cover_enter_t > math_lerp(2, 8, math_random()) then
				move_to_cover = true
			end
		end
	end
	
	if want_flank_cover then
		if not my_data.flank_cover then
			local sign = math_random() < 0.5 and -1 or 1
			local step = 30
			my_data.flank_cover = {
				step = step,
				angle = step * sign,
				sign = sign
			}
		end
	else
		my_data.flank_cover = nil
	end
	
	if not action_taken and not in_cover and move_to_cover and my_data.cover_path then
		action_taken = CopLogicAttack._chk_request_action_walk_to_cover(data, my_data)
	end

	if not action_taken then
		if not my_data.cover_path_failed_t or t - my_data.cover_path_failed_t > 0.5 then
			local best_cover = my_data.best_cover

			if best_cover and not my_data.processing_cover_path and not my_data.cover_path then
				if not in_cover then
					CopLogicAttack._cancel_cover_pathing(data, my_data)

					local my_pos = data.unit:movement():nav_tracker():field_position()
					local to_cover_pos = my_data.best_cover[1][1]
					local unobstructed_line = CopLogicTravel._check_path_is_straight_line(my_pos, to_cover_pos, data)

					if unobstructed_line then
						local path = {
							mvec3_cpy(my_pos),
							mvec3_cpy(to_cover_pos)
						}
						
						my_data.cover_path = path
						
						if move_to_cover then
							action_taken = CopLogicAttack._chk_request_action_walk_to_cover(data, my_data)
						end
					else
						data.brain:add_pos_rsrv("path", {
							radius = 60,
							position = mvec3_cpy(my_data.best_cover[1][1])
						})

						my_data.cover_path_search_id = tostring(data.key) .. "cover"
						my_data.processing_cover_path = best_cover

						data.brain:search_for_path_to_cover(my_data.cover_path_search_id, best_cover[1])
					end
				end
			end
		end
	end
	
	if not action_taken and want_to_take_cover and not my_data.best_cover then
		action_taken = CopLogicAttack._chk_start_action_move_back(data, my_data, focus_enemy, my_data.attitude == "engage" and not data.is_suppressed)
	end
end

function TeamAILogicAssault._upd_enemy_detection(data, is_synchronous)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local delay = CopLogicBase._upd_attention_obj_detection(data, nil, nil)
	local new_attention, new_prio_slot, new_reaction = TeamAILogicIdle._get_priority_attention(data, data.detected_attention_objects, nil)
	local old_att_obj = data.attention_obj
	
	if new_attention then
		if old_att_obj and old_att_obj.u_key ~= new_attention.u_key then
			if not data.unit:movement():chk_action_forbidden("walk") then
				CopLogicAttack._cancel_walking_to_cover(data, my_data)
			end

			CopLogicAttack._set_best_cover(data, my_data, nil)
		end
	end
	
	TeamAILogicBase._set_attention_obj(data, new_attention, new_reaction)
	TeamAILogicAssault._chk_exit_assault_logic(data, new_reaction)

	if my_data ~= data.internal_data then
		return
	end

	if data.objective and data.objective.type == "follow" and not data.unit:movement():chk_action_forbidden("walk") and TeamAILogicIdle._check_should_relocate(data, my_data, data.objective) then
		data.objective.in_place = nil

		if new_prio_slot and new_prio_slot > 3 then
			data.objective.called = true
		end

		TeamAILogicBase._exit(data.unit, "travel")

		return
	end

	CopLogicAttack._upd_aim(data, my_data)

	if not my_data._turning_to_intimidate and data.unit:character_damage():health_ratio() > 0.5 then
		if not my_data._intimidate_chk_t or data.t > my_data._intimidate_chk_t then
			my_data._intimidate_chk_t = data.t + 0.5

			if not data.intimidate_t or data.t > data.intimidate_t then
				local can_turn = nil

				if not new_prio_slot or new_prio_slot > 5 then
					if data.logic.chk_should_turn(data, my_data) then
						can_turn = true
					end
				end

				local is_assault = managers.groupai:state():get_assault_mode()
				local shout_angle = can_turn and 180 or 60
				local shout_distance = is_assault and 800 or 1200
				local civ = TeamAILogicIdle.find_civilian_to_intimidate(data.unit, shout_angle, shout_distance)

				if civ then
					data.intimidate_t = data.t + 2
					my_data._intimidate_chk_t = data.intimidate_t

					if can_turn and CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, civ:movement():m_pos()) then
						my_data._turning_to_intimidate = true
						my_data._primary_intimidation_target = civ
					else
						TeamAILogicIdle.intimidate_civilians(data, data.unit, true, can_turn and true)
					end
				end
			end
		end
	end

	if not TeamAILogicAssault._upd_spotting(data, my_data) then
		TeamAILogicAssault._chk_request_combat_chatter(data, my_data)
	end

	if not is_synchronous then
		CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicAssault._upd_enemy_detection, data, data.t + delay)
	end
end

function TeamAILogicAssault._upd_spotting(data, my_data)
	if my_data.acting then
		return
	end

	if not my_data.mark_special_chk_t or data.t > my_data.mark_special_chk_t then
		my_data.mark_special_chk_t = data.t + 0.75

		if not data.mark_special_t or data.t > data.mark_special_t then
			local nmy = TeamAILogicAssault.find_enemy_to_mark(data)

			if nmy then
				data.mark_special_t = data.t + 6
				my_data.mark_special_chk_t = data.mark_special_t

				local play_sound = not data.unit:sound():speaking()

				TeamAILogicAssault.mark_enemy(data, data.unit, nmy, play_sound, true)

				return true
			end
		end
	end
end

function TeamAILogicAssault.find_enemy_to_mark(data)
	local my_head_pos = data.unit:movement():m_head_pos()
	local my_look_vec = data.unit:movement():m_rot():y()
	local max_marking_angle = 90
	local best_nmy, best_nmy_wgt = nil
	local use_non_att_obj_mark = nil
	
	if data.attention_obj and data.attention_obj.unit and alive(data.attention_obj.unit) then
		local attention_info = data.attention_obj
		local key = attention_info.unit:key()
	
		local att_contour_ext = attention_info.unit:contour()

		if att_contour_ext and attention_info.identified and attention_info.is_alive then
			if attention_info.verified or attention_info.nearly_visible then
				if attention_info.reaction and REACT_COMBAT <= attention_info.reaction then
					if attention_info.is_deployable or attention_info.is_person and attention_info.char_tweak and attention_info.char_tweak.priority_shout then
						local in_range = nil

						if attention_info.is_deployable then
							local turret_tweak = attention_info.unit:brain() and attention_info.unit:brain()._tweak_data

							if turret_tweak then
								local actual_range = math_min(turret_tweak.FIRE_RANGE, turret_tweak.DETECTION_RANGE)

								if attention_info.dis < actual_range then
									in_range = true
								end
							end
						elseif attention_info.char_tweak.priority_shout_max_dis then
							if attention_info.dis < attention_info.char_tweak.priority_shout_max_dis then
								in_range = true
							end
						elseif attention_info.dis < 3000 then
							in_range = true
						end

						if in_range then
							local vec = attention_info.m_head_pos - my_head_pos
							local angle = vec:normalized():angle(my_look_vec)

							if angle < max_marking_angle then
								local mark = nil

								if not att_contour_ext._contour_list then
									mark = true
								else
									local has_id_func = att_contour_ext.has_id

									if attention_info.is_deployable then
										if not has_id_func(att_contour_ext, "mark_unit_dangerous") and not has_id_func(att_contour_ext, "mark_unit_dangerous_damage_bonus") and not has_id_func(att_contour_ext, "mark_unit_dangerous_damage_bonus_distance") then
											mark = true
										end
									elseif not has_id_func(att_contour_ext, "mark_enemy") and not has_id_func(att_contour_ext, "mark_enemy_damage_bonus") and not has_id_func(att_contour_ext, "mark_enemy_damage_bonus_distance") then
										mark = true
									end
								end

								if mark then
									best_nmy = attention_info.unit
								end
							end
						end
					end
				end
			end
		end
	elseif use_non_att_obj_mark then
	
		local attention_objects = data.detected_attention_objects

		for key, attention_info in pairs(attention_objects) do
			local att_contour_ext = attention_info.unit:contour()

			if att_contour_ext and attention_info.identified and attention_info.is_alive then
				if attention_info.verified or attention_info.nearly_visible then
					if attention_info.reaction and REACT_COMBAT <= attention_info.reaction then
						if attention_info.is_deployable or attention_info.is_person and attention_info.char_tweak and attention_info.char_tweak.priority_shout then
							local in_range = nil

							if attention_info.is_deployable then
								local turret_tweak = attention_info.unit:brain() and attention_info.unit:brain()._tweak_data

								if turret_tweak then
									local actual_range = math_min(turret_tweak.FIRE_RANGE, turret_tweak.DETECTION_RANGE)

									if attention_info.dis < actual_range then
										in_range = true
									end
								end
							elseif attention_info.char_tweak.priority_shout_max_dis then
								if attention_info.dis < attention_info.char_tweak.priority_shout_max_dis then
									in_range = true
								end
							elseif attention_info.dis < 3000 then
								in_range = true
							end

							if in_range then
								local vec = attention_info.m_head_pos - my_head_pos
								local angle = vec:normalized():angle(my_look_vec)

								if angle < max_marking_angle then
									local mark = nil

									if not att_contour_ext._contour_list then
										mark = true
									else
										local has_id_func = att_contour_ext.has_id

										if attention_info.is_deployable then
											if not has_id_func(att_contour_ext, "mark_unit_dangerous") and not has_id_func(att_contour_ext, "mark_unit_dangerous_damage_bonus") and not has_id_func(att_contour_ext, "mark_unit_dangerous_damage_bonus_distance") then
												mark = true
											end
										elseif not has_id_func(att_contour_ext, "mark_enemy") and not has_id_func(att_contour_ext, "mark_enemy_damage_bonus") and not has_id_func(att_contour_ext, "mark_enemy_damage_bonus_distance") then
											mark = true
										end
									end

									if mark then
										if not best_nmy_wgt or attention_info.dis < best_nmy_wgt then
											best_nmy_wgt = attention_info.dis
											best_nmy = attention_info.unit
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	return best_nmy
end

function TeamAILogicAssault.mark_enemy(data, criminal, to_mark, play_sound, play_action)
	if play_sound then
		local callout = not data.last_mark_shout_t or tweak_data.sound.criminal_sound.ai_callout_cooldown < data.t - data.last_mark_shout_t

		if callout then
			if to_mark:base().sentry_gun then
				criminal:sound():say("f44x_any", true)
			else
				criminal:sound():say(to_mark:base():char_tweak().priority_shout .. "x_any", true)
			end

			data.last_mark_shout_t = data.t
		end
	end

	if play_action then
		local can_play_action = not data.internal_data.shooting and not criminal:anim_data().reload and not criminal:movement():chk_action_forbidden("action")

		if can_play_action then
			local new_action = {
				type = "act",
				variant = "cmd_point",
				body_part = 3,
				align_sync = true
			}

			if criminal:brain():action_request(new_action) then
				data.internal_data.gesture_arrest = true
			end

			--[[if criminal:movement():play_redirect("arrest") then
				managers.network:session():send_to_peers_synched("play_distance_interact_redirect", criminal, "arrest")
			end]]
		end
	end

	if to_mark:base().sentry_gun then
		to_mark:contour():add("mark_unit_dangerous", true)
	else
		to_mark:contour():add("mark_enemy", true)
	end

	local skip_alert = managers.groupai:state():whisper_mode()

	if not skip_alert then
		local alert_rad = 500
		local alert = {
			"vo_cbt",
			criminal:movement():m_head_pos(),
			alert_rad,
			data.SO_access,
			criminal
		}

		managers.groupai:state():propagate_alert(alert)
	end
end

function TeamAILogicAssault.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action:type()

	if action_type == "walk" then
		my_data.advancing = nil

		CopLogicAttack._cancel_cover_pathing(data, my_data)

		if my_data.surprised then
			my_data.surprised = false
		elseif my_data.moving_to_cover then
			my_data.moving_to_cover = nil
		elseif my_data.walking_to_cover_shoot_pos then
			my_data.walking_to_cover_shoot_pos = nil
			my_data.at_cover_shoot_pos = true
		end
	elseif action_type == "shoot" then
		my_data.shooting = nil
	elseif action_type == "reload" or action_type == "heal" then
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

		if my_data._turning_to_intimidate then
			my_data._turning_to_intimidate = nil

			if action:expired() then
				TeamAILogicIdle.intimidate_civilians(data, data.unit, true, true, my_data._primary_intimidation_target)
			end

			my_data._primary_intimidation_target = nil
		end
	elseif action_type == "hurt" or action_type == "healed" then
		--CopLogicAttack._cancel_cover_pathing(data, my_data)

		if action:expired() and not CopLogicBase.chk_start_action_dodge(data, "hit") then
			CopLogicAttack._upd_aim(data, my_data)
		end
	elseif action_type == "dodge" then
		local timeout = action:timeout()

		if timeout then
			data.dodge_timeout_t = TimerManager:game():time() + math_lerp(timeout[1], timeout[2], math_random())
		end

		--CopLogicAttack._cancel_cover_pathing(data, my_data)

		if action:expired() then
			CopLogicAttack._upd_aim(data, my_data)
		end
	end
end

function TeamAILogicAssault.damage_clbk(data, damage_info)
	TeamAILogicIdle.damage_clbk(data, damage_info)
end

function TeamAILogicAssault.death_clbk(data, damage_info)
end

function TeamAILogicAssault.on_detected_enemy_destroyed(data, enemy_unit)
	TeamAILogicIdle.on_cop_neutralized(data, enemy_unit:key())
end

function TeamAILogicAssault.chk_should_turn(data, my_data)
	if not my_data.turning and not my_data.has_old_action and not my_data.advancing and not my_data.moving_to_cover and not my_data.walking_to_cover_shoot_pos and not my_data.surprised then
		if data.unit:movement()._should_stay then
			if not data.unit:movement():chk_action_forbidden("turn") then
				return true
			end
		elseif not data.unit:movement():chk_action_forbidden("walk") then
			return true
		end
	end
end

function TeamAILogicAssault._chk_request_combat_chatter(data, my_data)
	if data.unit:sound():speaking() then
		return
	end

	local focus_enemy = data.attention_obj

	if focus_enemy and focus_enemy.verified and focus_enemy.is_person and REACT_COMBAT <= focus_enemy.reaction then
		if my_data.firing or data.unit:character_damage():health_ratio() < 1 then
			if data.unit:movement()._should_stay or not data.unit:movement():chk_action_forbidden("walk") then
				managers.groupai:state():chk_say_teamAI_combat_chatter(data.unit)
			end
		end
	end
end

function TeamAILogicAssault._chk_exit_assault_logic(data, new_reaction)
	if data.unit:movement()._should_stay or not data.unit:movement():chk_action_forbidden("walk") then
		local wanted_state = TeamAILogicBase._get_logic_state_from_reaction(data, new_reaction)

		if wanted_state ~= data.name then
			local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, data.objective, nil, nil)

			if allow_trans or wanted_state == "idle" then
				if obj_failed then
					data.objective_failed_clbk(data.unit, data.objective)
				else
					TeamAILogicBase._exit(data.unit, wanted_state)
				end
			end
		end
	end
end