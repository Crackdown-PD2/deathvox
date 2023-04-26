function TeamAILogicTravel.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.unit:brain():cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit,
		detection = data.char_tweak.detection.recon
	}

	if old_internal_data then
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
	local key_str = tostring(data.key)

	if not data.unit:movement():cool() then
		my_data.detection_task_key = "TeamAILogicTravel._upd_enemy_detection" .. key_str

		CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicTravel._upd_enemy_detection, data, data.t)
	end

	my_data.advance_path_search_id = "TeamAILogicTravel_detailed" .. tostring(data.key)
	my_data.coarse_path_search_id = "TeamAILogicTravel_coarse" .. tostring(data.key)
	my_data.path_ahead = data.team.id == tweak_data.levels:get_default_team_ID("player")

	if data.objective then
		my_data.called = data.objective.called and true
		data.objective.called = false

		if data.objective.follow_unit then
			my_data.cover_wait_t = {
				0,
				0
			}
		end

		if data.objective.path_style == "warp" then
			my_data.warp_pos = data.objective.pos
		end
	end

	data.unit:movement():set_allow_fire(false)

	local w_td = alive(data.unit) and data.unit:inventory():equipped_unit() and data.unit:inventory():equipped_unit():base():weapon_tweak_data()

	if w_td then
		local cw_td = data.char_tweak.weapon[w_td.usage]
		my_data.weapon_range = cw_td and cw_td.range or {
			optimal = 2000,
			far = 5000,
			close = 1000
		}
	end

	if not data.unit:movement():chk_action_forbidden("walk") or data.unit:anim_data().act_idle then
		local new_action = {
			body_part = 2,
			type = "idle"
		}

		data.unit:brain():action_request(new_action)
	end
	
	my_data.criminal = true
end

function TeamAILogicTravel._upd_enemy_detection(data)
	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local max_reaction = nil

	if data.cool then
		max_reaction = AIAttentionObject.REACT_SURPRISED
	end

	local delay = CopLogicBase._upd_attention_obj_detection(data, AIAttentionObject.REACT_CURIOUS, max_reaction)
	local new_attention, new_prio_slot, new_reaction = TeamAILogicIdle._get_priority_attention(data, data.detected_attention_objects, nil)

	TeamAILogicBase._set_attention_obj(data, new_attention, new_reaction)
	
	if new_attention and (new_attention.nearly_visible or new_attention.verified) and new_reaction and AIAttentionObject.REACT_COMBAT <= new_reaction and new_attention.dis < 2000 then
		data.last_engage_t = data.t
	end

	if new_attention then
		local objective = data.objective
		local allow_trans, obj_failed = nil
		local dont_exit = false

		if data.unit:movement():chk_action_forbidden("walk") and not data.unit:anim_data().act_idle then
			dont_exit = true
		else
			allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, new_attention)
		end

		if obj_failed and not dont_exit then
			if objective.type == "follow" then
				debug_pause_unit(data.unit, "failing follow", allow_trans, obj_failed, inspect(objective))
			end

			data.objective_failed_clbk(data.unit, data.objective)

			return
		end
	end
	
	if data.objective then
		local objective = data.objective
		local objective_is_revive = objective.type == "revive"
	
		if objective_is_revive or my_data.called or objective.type == "follow" and mvector3.distance_sq(objective.follow_unit:movement():m_pos(), data.m_pos) > 490000 then
			if objective_is_revive or not new_prio_slot or new_prio_slot > 1 then
				my_data.low_value_att = true
			end
		else
			my_data.low_value_att = nil
		end
	else
		my_data.low_value_att = nil
	end

	CopLogicAttack._upd_aim(data, my_data)

	if not my_data._intimidate_t or my_data._intimidate_t + 2 < data.t then
		local civ = TeamAILogicIdle.intimidate_civilians(data, data.unit, true, false)

		if civ then
			my_data._intimidate_t = data.t

			if not data.attention_obj then
				CopLogicBase._set_attention_on_unit(data, civ)

				local key = "RemoveAttentionOnUnit" .. tostring(data.key)

				CopLogicBase.queue_task(my_data, key, TeamAILogicTravel._remove_enemy_attention, {
					data = data,
					target_key = civ:key()
				}, data.t + 1.5)
			end
		else
			TeamAILogicIdle.intimidate_others(data, my_data, can_turn)
		end
	end

	TeamAILogicAssault._chk_request_combat_chatter(data, my_data)

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicTravel._upd_enemy_detection, data, data.t + delay)
end

TeamAILogicTravel._pathing_complete_clbk = CopLogicTravel._pathing_complete_clbk