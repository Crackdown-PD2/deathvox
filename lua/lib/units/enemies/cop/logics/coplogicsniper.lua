local mvec3_cpy = mvector3.copy

function CopLogicSniper.action_complete_clbk(data, action)
	local action_type = action:type()
	local my_data = data.internal_data

	if action_type == "turn" then
		my_data.turning = nil
	elseif action_type == "shoot" then
		my_data.shooting = nil
	elseif action_type == "walk" then
		my_data.advacing = nil

		if action:expired() then
			my_data.reposition = nil
			CopLogicSniper._upd_aim(data, my_data)
		end
	elseif action_type == "dodge" and data.objective and data.objective.pos then
		
		if action:expired() then
			my_data.reposition = true
			CopLogicSniper._upd_aim(data, my_data)
		end
	elseif action_type == "hurt" and (action:body_part() == 1 or action:body_part() == 2) and data.objective and data.objective.pos then
		my_data.reposition = true
		
		if action:expired() and not CopLogicBase.chk_start_action_dodge(data, "hit") then
			CopLogicSniper._upd_aim(data, my_data)
		end
	end
end

function CopLogicSniper.should_duck_on_alert(data, alert_data)
end

function CopLogicSniper._upd_aim(data, my_data)
	local shoot, aim = nil
	local focus_enemy = data.attention_obj

	if focus_enemy then
		if focus_enemy.verified then
			shoot = true
			my_data.last_criminal_nav_seen = focus_enemy.unit:movement():nav_tracker():nav_segment()
		elseif my_data.wanted_stance == "cbt" then
			aim = true
		elseif focus_enemy.verified_t and data.t - focus_enemy.verified_t < 20 then
			aim = true
		end

		if aim and not shoot and my_data.firing and focus_enemy.verified_t and data.t - focus_enemy.verified_t < 2 then
			shoot = true
		end
	end

	if shoot and focus_enemy.reaction < AIAttentionObject.REACT_SHOOT then
		shoot = nil
		aim = true
	end

	local action_taken = my_data.turning or data.unit:movement():chk_action_forbidden("walk")

	if not action_taken then
		local anim_data = data.unit:anim_data()

		if focus_enemy then
			if not focus_enemy.verified and not anim_data.reload then
				if anim_data.crouch then
					if (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.stand) and not CopLogicSniper._chk_stand_visibility(data.m_pos, focus_enemy.m_head_pos, data.visibility_slotmask) then
						CopLogicAttack._chk_request_action_stand(data)
					end
				elseif (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) and not CopLogicSniper._chk_crouch_visibility(data.m_pos, focus_enemy.m_head_pos, data.visibility_slotmask) then
					CopLogicAttack._chk_request_action_crouch(data)
				end
			end
		elseif my_data.wanted_pose and not anim_data.reload then
			if my_data.wanted_pose == "crouch" then
				if not anim_data.crouch and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
					action_taken = CopLogicAttack._chk_request_action_crouch(data)
				end
			elseif not anim_data.stand and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.stand) then
				action_taken = CopLogicAttack._chk_request_action_stand(data)
			end
		end
	end

	if my_data.reposition and not action_taken and not my_data.advancing then
		local objective = data.objective
		my_data.advance_path = {
			mvector3.copy(data.m_pos),
			mvector3.copy(objective.pos)
		}

		if CopLogicTravel._chk_request_action_walk_to_advance_pos(data, my_data, objective.haste or "walk", objective.rot) then
			action_taken = true
		end
	end

	if aim or shoot then
		local time_since_verification = focus_enemy.verified_t and data.t - focus_enemy.verified_t
		
		if focus_enemy.verified or focus_enemy.nearly_visible or time_since_verification and time_since_verification <= 0.3 then
			if my_data.attention_unit ~= focus_enemy.u_key then
				CopLogicBase._set_attention(data, focus_enemy)

				my_data.attention_unit = focus_enemy.u_key
			end
			
			if CopLogicAttack.chk_should_turn(data, my_data) then
				CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, focus_enemy.m_pos)
			end
		elseif my_data.last_criminal_nav_seen then
			local look_pos = managers.navigation:find_random_position_in_segment(my_data.last_criminal_nav_seen)
		
			
			if not look_pos and focus_enemy and time_since_verification and time_since_verification <= 2 or focus_enemy.dis < 400 then
				look_pos =  focus_enemy.last_verified_pos or focus_enemy.verified_pos
			end
			
			if look_pos then
				if my_data.attention_unit ~= look_pos then
					CopLogicBase._set_attention_on_pos(data, mvec3_cpy(look_pos))

					my_data.attention_unit = mvec3_cpy(look_pos)
				end
				
				if CopLogicAttack.chk_should_turn(data, my_data) then
					CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, look_pos)
				end
			end
		end

		if not my_data.shooting and not data.unit:anim_data().reload and not data.unit:movement():chk_action_forbidden("action") then
			local shoot_action = {
				body_part = 3,
				type = "shoot"
			}

			if data.unit:brain():action_request(shoot_action) then
				my_data.shooting = true
			end
		end
	else
		if my_data.shooting then
			local new_action = {
				body_part = 3,
				type = "idle"
			}

			data.brain:action_request(new_action)
		elseif not data.unit:movement():chk_action_forbidden("action") then
			local ammo_max, ammo = data.unit:inventory():equipped_unit():base():ammo_info()

			if ammo / ammo_max < 0.75 then
				local new_action = {
					body_part = 3,
					type = "reload",
					idle_reload = true
				}

				data.brain:action_request(new_action)
			end
		end
		
		if my_data.attention_unit then
			CopLogicBase._reset_attention(data)

			my_data.attention_unit = nil
		end
	end

	CopLogicAttack.aim_allow_fire(shoot, aim, data, my_data)
end

function CopLogicSniper._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local min_reaction = AIAttentionObject.REACT_AIM
	local delay = CopLogicBase._upd_attention_obj_detection(data, min_reaction, nil)
	local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, data.detected_attention_objects, CopLogicSniper._chk_reaction_to_attention_object)
	local old_att_obj = data.attention_obj

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)

	if new_reaction and AIAttentionObject.REACT_SCARED <= new_reaction then
		local objective = data.objective
		local wanted_state = nil
		local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, new_attention)

		if allow_trans then
			wanted_state = CopLogicBase._get_logic_state_from_reaction(data)
		end
		
		if wanted_state == "attack" then
			wanted_state = "sniper"
		end
		
		if obj_failed then
			data.objective_failed_clbk(data.unit, data.objective)
		end

		if wanted_state and wanted_state ~= data.name then
			if my_data == data.internal_data then
				CopLogicBase._exit(data.unit, wanted_state)
			end

			CopLogicBase._report_detections(data.detected_attention_objects)

			return
		end
	end

	CopLogicSniper._upd_aim(data, my_data)

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicSniper._upd_enemy_detection, data, data.t + delay)
	CopLogicBase._report_detections(data.detected_attention_objects)
end
