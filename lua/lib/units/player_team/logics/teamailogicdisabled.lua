function TeamAILogicDisabled._upd_enemy_detection(data)
	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local delay = CopLogicBase._upd_attention_obj_detection(data, AIAttentionObject.REACT_SURPRISED, nil)
	local new_attention, new_prio_slot, new_reaction = TeamAILogicIdle._get_priority_attention(data, data.detected_attention_objects, nil, data.cool)

	TeamAILogicBase._set_attention_obj(data, new_attention, new_reaction)
	TeamAILogicDisabled._upd_aim(data, my_data)

	if data.unit:character_damage():bleed_out() and not data.unit:character_damage():fatal() or data.unit:character_damage():arrested() then
		TeamAILogicIdle._upd_sneak_spotting(data, my_data)
	elseif data.unit:movement():tased() then
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
