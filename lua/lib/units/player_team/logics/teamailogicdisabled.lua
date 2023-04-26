function TeamAILogicDisabled._upd_enemy_detection(data)
	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local delay = CopLogicBase._upd_attention_obj_detection(data, AIAttentionObject.REACT_SURPRISED, nil)
	local new_attention, new_prio_slot, new_reaction = TeamAILogicIdle._get_priority_attention(data, data.detected_attention_objects, nil, data.cool)

	TeamAILogicBase._set_attention_obj(data, new_attention, new_reaction)
	TeamAILogicDisabled._upd_aim(data, my_data)


	if data.unit:movement():tased() then
		if not data.unit:brain()._tase_mark_t or data.unit:brain()._tase_mark_t + 2 < data.t then
			for key, attention_info in pairs(data.detected_attention_objects) do
				if attention_info.identified and attention_info.is_person and attention_info.unit:contour() then
					if attention_info.unit:character_damage().dead and not attention_info.unit:character_damage():dead() then
						if attention_info.unit:brain() and attention_info.unit:brain()._logic_data and attention_info.unit:brain()._logic_data.internal_data then
							local tasing = attention_info.unit:brain()._logic_data.internal_data.tasing

							if tasing and tasing.target_u_key == data.key then
								data.unit:brain()._tase_mark_t = data.t
								data.unit:sound():say("s07x_sin", true)
								attention_info.unit:contour():add("mark_enemy", true)

								local skip_alert = managers.groupai:state():whisper_mode()

								if not skip_alert then
									local alert_rad = 500
									local alert = {
										"vo_cbt",
										data.unit:movement():m_head_pos(),
										alert_rad,
										data.SO_access,
										data.unit
									}

									managers.groupai:state():propagate_alert(alert)
								end

								break
							end
						end
					end
				end
			end
		end
	end

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicDisabled._upd_enemy_detection, data, data.t + delay)
end

function TeamAILogicDisabled.on_recovered(data, reviving_unit)
	local my_data = data.internal_data

	if reviving_unit and my_data.rescuer and my_data.rescuer:key() == reviving_unit:key() then
		my_data.rescuer = nil
	else
		TeamAILogicDisabled._unregister_revive_SO(my_data)
	end

	local objective = data.objective

	if objective and objective.forced and objective.path_style == "warp" then
		CopLogicBase._exit(data.unit, "travel")
	else
		CopLogicBase._exit(data.unit, "idle") ----to further edit along with the rest of this file
	end
end

function TeamAILogicDisabled._register_revive_SO(data, my_data, rescue_type)
	local followup_objective = {
		type = "act",
		action = {
			variant = "idle",
			body_part = 1,
			type = "act",
			blocks = {
				heavy_hurt = -1,
				idle = -1,
				action = -1,
				turn = -1,
				light_hurt = -1,
				walk = -1,
				fire_hurt = -1,
				hurt = -1,
				expl_hurt = -1
			}
		}
	}
	local objective = {
		type = "revive",
		called = true,
		destroy_clbk_key = false,
		follow_unit = data.unit,
		nav_seg = data.unit:movement():nav_tracker():nav_segment(),
		fail_clbk = callback(TeamAILogicDisabled, TeamAILogicDisabled, "on_revive_SO_failed", data),
		action = {
			align_sync = true,
			type = "act",
			body_part = 1,
			variant = rescue_type,
			blocks = {
				light_hurt = -1,
				hurt = -1,
				action = -1,
				heavy_hurt = -1,
				aim = -1,
				walk = -1
			}
		},
		action_duration = tweak_data.interaction[data.name == "surrender" and "free" or "revive"].timer,
		followup_objective = followup_objective
	}
	local so_descriptor = {
		interval = 0,
		search_dis_sq = 2250000,
		AI_group = "friendlies",
		base_chance = 1,
		chance_inc = 0,
		usage_amount = 1,
		objective = objective,
		search_pos = mvector3.copy(data.m_pos),
		admin_clbk = callback(TeamAILogicDisabled, TeamAILogicDisabled, "on_revive_SO_administered", data)
	}
	local so_id = "TeamAIrevive" .. tostring(data.key)
	my_data.SO_id = so_id

	managers.groupai:state():add_special_objective(so_id, so_descriptor)

	my_data.deathguard_SO_id = PlayerBleedOut._register_deathguard_SO(data.unit)
end