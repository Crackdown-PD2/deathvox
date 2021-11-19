local mvec3_dis_sq = mvector3.distance_sq
local mvec3_cpy = mvector3.copy

local math_abs = math.abs

local pairs_g = pairs

local REACT_SURPRISED = AIAttentionObject.REACT_SURPRISED
local REACT_CURIOUS = AIAttentionObject.REACT_CURIOUS
local REACT_AIM = AIAttentionObject.REACT_AIM

function TeamAILogicTravel.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.brain:cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit
	}
	local was_cool = data.cool

	if was_cool then
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

	data.internal_data = my_data

	local new_stance = nil
	local objective = data.objective

	if objective and objective.stance then
		new_stance = objective.stance

		if new_stance == "ntl" and data.char_tweak.allowed_stances and not data.char_tweak.allowed_stances.ntl then
			new_stance = nil
		end
	end

	if was_cool and new_stance and new_stance ~= "ntl" then
		data.unit:movement():set_cool(false)

		if my_data ~= data.internal_data then
			return
		end
	end

	if not new_stance and not data.cool then --checking for data.cool instead of was_cool is intended here
		new_stance = "hos"
	end

	if new_stance then
		if new_stance == "ntl" then
			data.unit:movement():set_stance(new_stance)
		elseif not my_data.shooting then
			if not data.char_tweak.allowed_stances or data.char_tweak.allowed_stances.hos then
				new_stance = "hos"
			elseif data.char_tweak.allowed_stances.cbt then
				new_stance = "cbt"
			end

			if new_stance then
				data.unit:movement():set_stance(new_stance)
			end
		end

		if my_data ~= data.internal_data then
			return
		end
	end

	my_data.weapon_range = data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range
	my_data.path_ahead = true

	local key_str = tostring(data.key)
	my_data.detection_task_key = "TeamAILogicTravel._upd_enemy_detection" .. key_str

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicTravel._upd_enemy_detection, data, data.t, true)

	my_data.cover_update_task_key = "CopLogicTravel._update_cover" .. key_str

	if my_data.nearest_cover or my_data.best_cover then
		CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t + 1)
	end

	my_data.advance_path_search_id = "CopLogicTravel_detailed" .. key_str
	my_data.coarse_path_search_id = "CopLogicTravel_coarse" .. key_str

	CopLogicIdle._chk_has_old_action(data, my_data)

	if data.unit:anim_data().act_idle or data.unit:movement()._should_stay and not my_data.has_old_action or not data.unit:movement():chk_action_forbidden("walk") then
		local new_action = {
			body_part = 2,
			type = "idle"
		}

		data.unit:brain():action_request(new_action)
	end

	if my_data.advancing then
		my_data.old_action_advancing = true
	end

	if was_cool then
		if not data.cool then
			my_data.detection = data.char_tweak.detection.recon
		end
	elseif data.cool then
		my_data.detection = data.char_tweak.detection.ntl
	end

	if objective then
		if objective.called then
			my_data.called = true
			objective.called = false
		end

		if objective.type == "revive" and objective.action == "revive" and managers.player:has_category_upgrade("team", "crew_inspire") then
			my_data.can_inspire = true
		end

		local path_style = objective.path_style

		if objective.path_style == "warp" then
			my_data.warp_pos = objective.pos
		else
			local path_data = objective.path_data

			if path_data then
				if path_style == "precise" then
					local path = {
						mvec3_cpy(data.m_pos)
					}
					local nav_points = path_data.points

					for i = 1, #nav_points do
						path[#path + 1] = mvec3_cpy(nav_points[i].position)
					end

					my_data.advance_path = path
					my_data.coarse_path_index = 1
					local start_seg = data.unit:movement():nav_tracker():nav_segment()
					local end_pos = mvec3_cpy(path[#path])
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
					local nav_points = path_data.points

					for i = 1, #nav_points do
						local pos = mvec3_cpy(nav_points[i].position)
						local nav_seg = f_get_nav_seg(nav_manager, pos)

						path[#path + 1] = {
							nav_seg,
							pos
						}
					end

					my_data.coarse_path = path
					my_data.coarse_path_index = CopLogicTravel.complete_coarse_path(data, my_data, path)
				elseif path_style == "coarse_complete" then
					my_data.coarse_path_index = 1
					my_data.coarse_path = deep_clone(objective.path_data)
					my_data.coarse_path_index = CopLogicTravel.complete_coarse_path(data, my_data, my_data.coarse_path)
				end
			end
		end
	end
end

function TeamAILogicTravel.exit(data, new_logic_name, enter_params)
	TeamAILogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	data.brain:cancel_all_pathing_searches()
	CopLogicBase.cancel_queued_tasks(my_data)
	CopLogicBase.cancel_delayed_clbks(my_data)

	if my_data.moving_to_cover then
		managers.navigation:release_cover(my_data.moving_to_cover[1])
	end

	if my_data.nearest_cover then
		managers.navigation:release_cover(my_data.nearest_cover[1])
	end

	if my_data.best_cover then
		managers.navigation:release_cover(my_data.best_cover[1])
	end

	data.brain:rem_pos_rsrv("path")
end

function TeamAILogicTravel.check_inspire(data, my_data, revive_unit)
	local range_sq = 810000
	local dist_sq = mvec3_dis_sq(data.m_pos, revive_unit:movement():m_pos())

	if dist_sq > range_sq then
		my_data.inspire_chk_t = data.t + 0.5

		return
	end

	local allow_inspire = nil
	local no_players_standing = true

	for u_key, u_data in pairs_g(managers.groupai:state():all_player_criminals()) do
		if not u_data.status and data.key ~= u_key then
			no_players_standing = false

			break
		end
	end

	if no_players_standing then
		allow_inspire = true
	else
		local rev_base_ext = revive_unit:base()

		--if not going to revive a player and there's still a player standing, just don't use inspire
		if not rev_base_ext.is_local_player and not rev_base_ext.is_husk_player then
			my_data.inspire_chk_t = data.t + 0.5

			return
		end
	end

	if not allow_inspire then
		local revive_timer = nil

		if revive_unit:base().is_local_player then
			revive_timer = revive_unit:character_damage()._downed_timer
		else
			local interact_ext = revive_unit:interaction()
			revive_timer = interact_ext.get_waypoint_time and interact_ext:get_waypoint_time()
		end

		--unit to revive will go into custody in 10 or less seconds
		if revive_timer and revive_timer <= 10 then
			allow_inspire = true
		end
	end

	if not allow_inspire and data.unit:character_damage():health_ratio() < 0.3 then --bot has less than 30% health
		allow_inspire = true
	end

	if not allow_inspire then
		local under_multiple_fire = nil
		local und_mul_fire_amount = 0
		local dmg_chk_t = data.t - 1.2

		for key, att_data in pairs_g(data.detected_attention_objects) do
			if att_data.dmg_t and dmg_chk_t < att_data.dmg_t then
				und_mul_fire_amount = und_mul_fire_amount + 1

				if und_mul_fire_amount > 3 then
					under_multiple_fire = true

					break
				end
			end
		end

		--more than 3 enemies damaged the bot in the last 1.2 seconds
		if under_multiple_fire then
			allow_inspire = true
		end
	end

	if not allow_inspire then
		my_data.inspire_chk_t = data.t + 0.5

		return
	end

	data.unit:brain():set_objective()
	data.unit:sound():say("f36x_any", true, false)

	local can_play_action = not my_data.shooting and not data.unit:anim_data().reload and not data.unit:movement():chk_action_forbidden("action")

	if can_play_action then
		local new_action = {
			variant = "cmd_get_up",
			align_sync = true,
			body_part = 3,
			type = "act"
		}

		if data.unit:brain():action_request(new_action) then
			data.internal_data.gesture_arrest = true
		end
	end

	local cooldown = managers.player:crew_ability_upgrade_value("crew_inspire", 360)

	managers.player:start_custom_cooldown("team", "crew_inspire", cooldown)
	TeamAILogicTravel.actually_revive(data, revive_unit, true)

	local skip_alert = managers.groupai:state():whisper_mode()

	if not skip_alert then
		local alert_rad = 500
		local new_alert = {
			"vo_cbt",
			data.unit:movement():m_head_pos(),
			alert_rad,
			data.SO_access,
			data.unit
		}

		managers.groupai:state():propagate_alert(new_alert)
	end
end

function TeamAILogicTravel.update(data)
	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	my_data.close_to_criminal = false

	local objective = data.objective

	if objective.type == "revive" and my_data.can_inspire then
		if not my_data.inspire_chk_t or data.t > my_data.inspire_chk_t then
			if managers.player:is_custom_cooldown_not_active("team", "crew_inspire") then
				TeamAILogicTravel.check_inspire(data, my_data, objective.follow_unit)

				if my_data ~= data.internal_data then
					return
				end
			else
				my_data.inspire_chk_t = data.t + 0.5
			end
		end
	end

	CopLogicTravel.upd_advance(data)
end

function TeamAILogicTravel._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local is_cool = data.cool
	local min_reaction, max_reaction = nil

	if is_cool then
		max_reaction = REACT_SURPRISED
	else
		min_reaction = REACT_CURIOUS
	end

	local delay = CopLogicBase._upd_attention_obj_detection(data, min_reaction, max_reaction)
	local new_attention, new_prio_slot, new_reaction = TeamAILogicIdle._get_priority_attention(data, data.detected_attention_objects, nil)

	TeamAILogicBase._set_attention_obj(data, new_attention, new_reaction)

	if is_cool then
		if new_attention then
			local turn_angle = CopLogicIdle._chk_turn_needed(data, my_data, data.m_pos, new_attention.m_pos)

			if turn_angle and math_abs(turn_angle) > 70 then
				local set_attention = data.unit:movement():attention()

				if set_attention then
					CopLogicBase._reset_attention(data)
				end
			elseif new_reaction < REACT_SURPRISED then
				local set_attention = data.unit:movement():attention()

				if not set_attention or set_attention.u_key ~= new_attention.u_key then
					CopLogicBase._set_attention(data, new_attention, nil)
				end
			end
		else
			local set_attention = data.unit:movement():attention()

			if set_attention then
				CopLogicBase._reset_attention(data)
			end
		end

		TeamAILogicIdle._upd_sneak_spotting(data, my_data)
	else
		if new_attention then
			if data.unit:anim_data().act_idle or data.unit:movement()._should_stay or not data.unit:movement():chk_action_forbidden("walk") then
				local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, data.objective, nil, new_attention)

				if allow_trans and obj_failed then
					data.objective_failed_clbk(data.unit, data.objective)

					return
				end
			end
		end

		CopLogicAttack._upd_aim(data, my_data)

		if not my_data._intimidate_chk_t or data.t > my_data._intimidate_chk_t then
			my_data._intimidate_chk_t = data.t + 0.5

			if not data.intimidate_t or data.t > data.intimidate_t then
				local civ = TeamAILogicIdle.intimidate_civilians(data, data.unit, true, true)

				if civ then
					data.intimidate_t = data.t + 2
					my_data._intimidate_chk_t = data.intimidate_t
				end
			end
		end

		if not TeamAILogicIdle._upd_sneak_spotting(data, my_data) and not TeamAILogicAssault._upd_spotting(data, my_data) then
			TeamAILogicAssault._chk_request_combat_chatter(data, my_data)
		end

		TeamAILogicIdle.check_idle_reload(data, new_reaction)
	end

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicTravel._upd_enemy_detection, data, data.t + delay, true)
end

function TeamAILogicTravel._remove_enemy_attention(param)
	local data = param.data

	if not data.attention_obj or data.attention_obj.u_key ~= param.target_key then
		return
	end

	CopLogicBase._reset_attention(data)
end

function TeamAILogicTravel.is_available_for_assignment(data, new_objective)
	if new_objective and new_objective.forced then
		return true
	elseif data.objective and data.objective.type == "act" then
		if not new_objective or new_objective.type == "free" then
			if data.objective.interrupt_dis == -1 then
				return true
			end
		end

		return
	else
		return TeamAILogicAssault.is_available_for_assignment(data, new_objective)
	end
end
