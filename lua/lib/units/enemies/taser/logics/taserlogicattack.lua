local mvec3_x = mvector3.x
local mvec3_y = mvector3.y
local mvec3_z = mvector3.z
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_dir = mvector3.direction
local mvec3_dot = mvector3.dot
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_lerp = mvector3.lerp
local mvec3_norm = mvector3.normalize
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_cross = mvector3.cross
local mvec3_rand_ortho = mvector3.random_orthogonal
local mvec3_negate = mvector3.negate
local mvec3_len = mvector3.length
local mvec3_len_sq = mvector3.length_sq
local mvec3_cpy = mvector3.copy
local mvec3_set_stat = mvector3.set_static
local mvec3_set_length = mvector3.set_length
local mvec3_angle = mvector3.angle
local mvec3_step = mvector3.step
local math_lerp = math.lerp
local math_random = math.random
local math_up = math.UP
local math_abs = math.abs
local math_clamp = math.clamp
local math_min = math.min
local m_rot_x = mrotation.x
local m_rot_y = mrotation.y
local m_rot_z = mrotation.z
local table_insert = table.insert
local table_contains = table.contains
local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
local temp_vec3 = Vector3()

function TaserLogicAttack.queued_update(data)
	local my_data = data.internal_data

	TaserLogicAttack._upd_enemy_detection(data)
	
	if my_data ~= data.internal_data then
		CopLogicBase._report_detections(data.detected_attention_objects)

		return
	elseif not data.attention_obj then
		CopLogicBase.queue_task(my_data, my_data.update_task_key, TaserLogicAttack.queued_update, data, data.t + 0)
		CopLogicBase._report_detections(data.detected_attention_objects)

		return
	end

	if my_data.has_old_action then
		TaserLogicAttack._upd_stop_old_action(data, my_data)
		CopLogicBase.queue_task(my_data, my_data.update_task_key, TaserLogicAttack.queued_update, data, data.t + 0)

		return
	end

	if CopLogicIdle._chk_relocate(data) then
		return
	end

	TaserLogicAttack._update_cover(data)

	local t = TimerManager:game():time()
	data.t = t
	local unit = data.unit
	local objective = data.objective
	local focus_enemy = data.attention_obj
	local action_taken = my_data.turning or data.unit:movement():chk_action_forbidden("walk") or my_data.moving_to_cover or my_data.walking_to_cover_shoot_pos or my_data.acting

	if my_data.tasing then
		action_taken = action_taken or TaserLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, focus_enemy.m_pos)

		CopLogicBase.queue_task(my_data, my_data.update_task_key, TaserLogicAttack.queued_update, data, data.t + 0)
		CopLogicBase._report_detections(data.detected_attention_objects)

		return
	end

	TaserLogicAttack._process_pathing_results(data, my_data)

	if AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction then
		TaserLogicAttack._update_cover(data)
		TaserLogicAttack._upd_combat_movement(data)
	end

	CopLogicBase.queue_task(my_data, my_data.update_task_key, TaserLogicAttack.queued_update, data, data.t + 0) --update asap
	CopLogicBase._report_detections(data.detected_attention_objects)
end

function TaserLogicAttack._upd_aim(data, my_data)
	
	if my_data.spooc_attack then
		if my_data.attention_unit ~= my_data.spooc_attack.target_u_data.u_key then
			CopLogicBase._set_attention(data, my_data.spooc_attack.target_u_data)

			my_data.attention_unit = my_data.spooc_attack.target_u_data.u_key
		end
		
		return
	end
	
	local shoot, aim, expected_pos = nil
	local focus_enemy = data.attention_obj
	local running = data.unit:movement()._active_actions[2] and data.unit:movement()._active_actions[2]:type() == "walk" and data.unit:movement()._active_actions[2]:haste() == "run"
	local tase = focus_enemy and focus_enemy.reaction >= AIAttentionObject.REACT_SPECIAL_ATTACK

	if focus_enemy then
		if tase and data.unit:base():has_tag("taser") then
			shoot = true
		elseif AIAttentionObject.REACT_AIM <= focus_enemy.reaction then
			if focus_enemy.verified or focus_enemy.nearly_visible then
				local firing_range = 500

				if my_data.weapon_range then
					firing_range = running and my_data.weapon_range.close or my_data.weapon_range.far
				elseif not running then
					firing_range = 1000
				end

				if running and firing_range < focus_enemy.dis then
					local walk_to_pos = data.unit:movement():get_walk_to_pos()

					if walk_to_pos then
						mvec3_dir(temp_vec1, data.m_pos, walk_to_pos)
						mvec3_dir(temp_vec2, data.m_pos, focus_enemy.m_pos)

						local dot = mvec3_dot(temp_vec1, temp_vec2)

						if dot < 0.6 then
							shoot = false
							aim = false
						end
					end
				end

				if aim == nil then
					if AIAttentionObject.REACT_SHOOT <= focus_enemy.reaction then
						local last_sup_t = data.unit:character_damage():last_suppression_t()

						if last_sup_t then
							local sup_t_ver = 7 

							if running then
								sup_t_ver = sup_t_ver * 0.3
							end

							if not focus_enemy.verified then
								if focus_enemy.vis_ray and firing_range < focus_enemy.vis_ray.distance then
									sup_t_ver = sup_t_ver * 0.5
								else
									sup_t_ver = sup_t_ver * 0.2
								end
							end

							if data.t - last_sup_t < sup_t_ver then
								shoot = true
							end
						end

						if not managers.groupai:state():whisper_mode() then
							if data.internal_data.weapon_range and focus_enemy.verified_dis < firing_range and managers.groupai:state():chk_assault_active_atm() then
								shoot = true
							elseif focus_enemy.criminal_record and focus_enemy.criminal_record.assault_t and data.t - focus_enemy.criminal_record.assault_t < 2 then
								shoot = true
							elseif not data.unit:base():has_tag("law") and focus_enemy.verified_dis < firing_range or data.unit:base():has_tag("law") and focus_enemy.aimed_at and focus_enemy.verified_dis <= 1500 then
								shoot = true
							end
						end
						
						if managers.groupai:state():whisper_mode() then
							if not shoot then
								shoot = true
							end
						end
						
						if not shoot and not managers.groupai:state():whisper_mode() and my_data.attitude == "engage" then
							local height_difference = math.abs(data.m_pos.z - data.attention_obj.m_pos.z) > 250
							local z_check = height_difference and 0.75 or 1
							
							if focus_enemy.verified_dis < firing_range * z_check or focus_enemy.reaction == AIAttentionObject.REACT_SHOOT then
								if dense_mook and not my_data.firing then
										--log("not firing due to FEDS")
								else
									shoot = true
								end
							else
								local time_since_verification = focus_enemy.verified_t and data.t - focus_enemy.verified_t
								local suppressingfire_t = 0.75
								
								if data.tactics and data.tactics.harass then
									suppressingfire_t = 2
								end

								if my_data.firing and time_since_verification and time_since_verification < suppressingfire_t then
									shoot = true
								end
							end
						end
						
						if not aim and focus_enemy.verified_dis < firing_range and not running then
							aim = true
						end

						aim = aim or shoot
					else
						aim = true
					end
				end
			else
				local time_since_verification = focus_enemy.verified_t and data.t - focus_enemy.verified_t

				if time_since_verification then
					if running then
						local dis_lerp = math_clamp((focus_enemy.verified_dis - 500) / 600, 0, 1)

						if time_since_verification < math_lerp(5, 1, dis_lerp) then
							aim = true
						end
					elseif time_since_verification < 5 then
						aim = true
					end

					if aim and my_data.shooting and AIAttentionObject.REACT_SHOOT <= focus_enemy.reaction then
						if running then
							local look_pos = focus_enemy.last_verified_pos or focus_enemy.verified_pos
							local same_height = math_abs(look_pos.z - data.m_pos.z) < 250

							if same_height and time_since_verification < 2 then
								shoot = true
							end
						elseif time_since_verification < 3 then
							shoot = true
						end
					end
				end

				if not shoot then
					if not focus_enemy.last_verified_pos or time_since_verification and time_since_verification > 5 then
						my_data.expected_pos = CopLogicAttack._get_expected_attention_position(data, my_data)

						if my_data.expected_pos then
							if running then
								my_data.expected_pos = mvec3_cpy(my_data.expected_pos)
								local watch_dir = temp_vec1

								mvec3_set(watch_dir, my_data.expected_pos)
								mvec3_sub(watch_dir, data.m_pos)
								mvec3_set_z(watch_dir, 0)

								local watch_pos_dis = mvec3_norm(watch_dir)
								local walk_to_pos = data.unit:movement():get_walk_to_pos()
								local walk_vec = temp_vec2

								mvec3_set(walk_vec, walk_to_pos)
								mvec3_sub(walk_vec, data.m_pos)
								mvec3_set_z(walk_vec, 0)
								mvec3_norm(walk_vec)

								local watch_walk_dot = mvec3_dot(watch_dir, walk_vec)

								if watch_pos_dis < 500 or watch_pos_dis < 1000 and watch_walk_dot > 0.85 then
									aim = true
								end
							else
								aim = true
							end
						end
					end
				end
			end
		end
		
		
		if focus_enemy.is_person and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and not data.unit:in_slot(16) and not data.is_converted and data.tactics and data.tactics.harass then
			if focus_enemy.is_local_player then
				local time_since_verify = data.attention_obj.verified_t and data.t - data.attention_obj.verified_t
				local e_movement_state = focus_enemy.unit:movement():current_state()
				
				if e_movement_state:_is_reloading() and time_since_verify and time_since_verify < 2 then
					if not data.unit:in_slot(16) and data.char_tweak.chatter.reload then
						managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "reload")
					end
				end
			else
				local e_anim_data = focus_enemy.unit:anim_data()
				local time_since_verify = data.attention_obj.verified_t and data.t - data.attention_obj.verified_t

				if e_anim_data.reload and time_since_verify and time_since_verify < 2 then
					if not data.unit:in_slot(16) and data.char_tweak.chatter.reload then
						managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "reload")
					end			
				end
			end
		end

		if not aim and data.char_tweak.always_face_enemy and AIAttentionObject.REACT_COMBAT <= focus_enemy.reaction then
			aim = true
		end

		if data.logic.chk_should_turn(data, my_data) then
			local enemy_pos = nil

			if focus_enemy.verified or focus_enemy.nearly_visible then
				enemy_pos = focus_enemy.m_pos
			else
				enemy_pos = my_data.expected_pos or focus_enemy.last_verified_pos or focus_enemy.verified_pos
			end

			CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, enemy_pos)
		end
	end
	
	local is_moving = my_data.walking_to_cover_shoot_pos or my_data.moving_to_cover or data.unit:anim_data().run or data.unit:anim_data().move
	if tase and is_moving and not data.unit:movement():chk_action_forbidden("walk") then
		local new_action = {
			body_part = 2,
			type = "idle"
		}

		data.unit:brain():action_request(new_action)
	end

	if aim or shoot then
		if focus_enemy.verified or focus_enemy.nearly_visible then
			if my_data.attention_unit ~= focus_enemy.u_key then
				CopLogicBase._set_attention(data, focus_enemy)

				my_data.attention_unit = focus_enemy.u_key
			end
		else
			local look_pos = my_data.expected_pos or focus_enemy.last_verified_pos or focus_enemy.verified_pos

			--[[if look_pos then
				local line = Draw:brush(Color.blue:with_alpha(0.5), 0.1)
				line:cylinder(data.unit:movement():m_head_pos(), look_pos, 5)
			end]]

			if my_data.attention_unit ~= look_pos then
				CopLogicBase._set_attention_on_pos(data, mvec3_cpy(look_pos))

				my_data.attention_unit = mvec3_cpy(look_pos)
			end
		end
		
		local nottasingortargetwrong = not my_data.tasing or my_data.tasing.target_u_data ~= focus_enemy
		
		if tase then
			if nottasingortargetwrong and not data.unit:movement():chk_action_forbidden("walk") and not focus_enemy.unit:movement():zipline_unit() then
				if my_data.attention_unit ~= focus_enemy.u_key then
					CopLogicBase._set_attention(data, focus_enemy)

					my_data.attention_unit = focus_enemy.u_key
				end

				local tase_action = {
					body_part = 3,
					type = "tase"
				}

				if data.unit:brain():action_request(tase_action) then
					my_data.tasing = {
						target_u_data = focus_enemy,
						target_u_key = focus_enemy.u_key,
						start_t = data.t
					}

					TaserLogicAttack._cancel_charge(data, my_data)
					managers.groupai:state():on_tase_start(data.key, focus_enemy.u_key)
				end
			end
		elseif not my_data.shooting and not my_data.spooc_attack and not data.unit:anim_data().reload and not data.unit:movement():chk_action_forbidden("action") then
			local shoot_action = {
				body_part = 3,
				type = "shoot"
			}

			if data.brain:action_request(shoot_action) then
				my_data.shooting = true
			end
		end
	else
		if my_data.shooting and not data.unit:anim_data().reload or my_data.tasing then
			local new_action = {
				body_part = 3,
				type = "idle"
			}

			data.brain:action_request(new_action)
		end

		if my_data.attention_unit then
			CopLogicBase._reset_attention(data)

			my_data.attention_unit = nil
		end
	end

	CopLogicAttack.aim_allow_fire(shoot, aim, data, my_data)
end

function TaserLogicAttack._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local min_reaction = AIAttentionObject.REACT_AIM
	
	CopLogicBase._upd_attention_obj_detection(data, min_reaction, nil)

	local tasing = my_data.tasing
	local tased_u_key = tasing and tasing.target_u_key
	local tase_in_effect = nil

	if tasing then
		if data.unit:movement()._active_actions[3] and data.unit:movement()._active_actions[3]:type() == "tase" then
			local tase_action = data.unit:movement()._active_actions[3]

			if tase_action._discharging or tase_action._firing_at_husk or tase_action._discharging_on_husk then
				tase_in_effect = true
			end
		end
	end

	if tase_in_effect then
		return
	end

	local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, data.detected_attention_objects, TaserLogicAttack._chk_reaction_to_attention_object)
	local old_att_obj = data.attention_obj

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)
	TaserLogicAttack._chk_exit_attack_logic(data, new_reaction)

	if my_data ~= data.internal_data then
		return
	end

	if new_attention then
		if old_att_obj then
			if old_att_obj.u_key ~= new_attention.u_key then
				TaserLogicAttack._cancel_charge(data, my_data)

				if not data.unit:movement():chk_action_forbidden("walk") then
					TaserLogicAttack._cancel_walking_to_cover(data, my_data)
				end

				TaserLogicAttack._set_best_cover(data, my_data, nil)
				--TaserLogicAttack._chk_play_charge_weapon_sound(data, my_data, new_attention)
			end
		else
			--TaserLogicAttack._chk_play_charge_weapon_sound(data, my_data, new_attention)
		end
	elseif old_att_obj then
		TaserLogicAttack._cancel_charge(data, my_data)
	end

	TaserLogicAttack._upd_aim(data, my_data, new_reaction)
end

function TaserLogicAttack._chk_reaction_to_attention_object(data, attention_data, stationary)
	local reaction = CopLogicIdle._chk_reaction_to_attention_object(data, attention_data, stationary)
	local tase_length = data.internal_data.tase_distance or 1500

	if reaction < AIAttentionObject.REACT_SHOOT or not attention_data.criminal_record or not attention_data.is_person then
		return reaction
	end

	if attention_data.verified and attention_data.verified_dis <= tase_length then
		if not data.internal_data.tasing or data.internal_data.tasing.target_u_key ~= attention_data.u_key then
			if attention_data.unit:movement() and attention_data.unit:movement().tased and attention_data.unit:movement():tased() then
				return AIAttentionObject.REACT_COMBAT
			end
		end

		if attention_data.is_human_player then
			if not attention_data.unit:movement():is_taser_attack_allowed() then
				return AIAttentionObject.REACT_COMBAT
			end
		elseif attention_data.unit:movement():chk_action_forbidden("hurt") then
			return AIAttentionObject.REACT_COMBAT
		end

		local obstructed = data.unit:raycast("ray", data.unit:movement():m_head_pos(), attention_data.m_head_pos, "slot_mask", managers.slot:get_mask("world_geometry", "vehicles", "enemy_shield_check"), "sphere_cast_radius", 10, "report")

		if obstructed then
			return AIAttentionObject.REACT_COMBAT
		else
			return AIAttentionObject.REACT_SPECIAL_ATTACK
		end
	end

	return reaction
end

function TaserLogicAttack._cancel_tase_attempt(data, my_data)
	if my_data.tasing then
		local new_action = {
			body_part = 3,
			type = "idle"
		}

		local res = data.unit:brain():action_request(new_action)
		if res then
			my_data.tasing = nil
		end
	end
end

function TaserLogicAttack.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action:type()
	
	if action_type == "healed" then
		TaserLogicAttack._cancel_cover_pathing(data, my_data)
		TaserLogicAttack._cancel_charge(data, my_data)
	
		if not data.unit:character_damage():dead() and action:expired() and not CopLogicBase.chk_start_action_dodge(data, "hit") then
			TaserLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			TaserLogicAttack._upd_combat_movement(data)
		end
	elseif action_type == "heal" then
		TaserLogicAttack._cancel_cover_pathing(data, my_data)
		TaserLogicAttack._cancel_charge(data, my_data)
	
		if not data.unit:character_damage():dead() and action:expired() then
			--log("hey this actually works!")
			TaserLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			TaserLogicAttack._upd_combat_movement(data)
		end
	elseif action_type == "walk" then
		my_data.advancing = nil
		my_data.flank_cover = nil
		TaserLogicAttack._cancel_cover_pathing(data, my_data)
		TaserLogicAttack._cancel_charge(data, my_data)
		TaserLogicAttack._cancel_tase_attempt(data, my_data)
		if my_data.has_retreated and managers.groupai:state():chk_active_assault_break() then
			my_data.in_retreat_pos = true
		elseif my_data.surprised then
			my_data.surprised = false
		elseif my_data.moving_to_cover then
			if action:expired() then
				my_data.in_cover = my_data.moving_to_cover
				my_data.cover_enter_t = data.t
			end

			my_data.moving_to_cover = nil
		elseif my_data.walking_to_cover_shoot_pos then
			my_data.walking_to_cover_shoot_pos = nil
			my_data.at_cover_shoot_pos = true
		end
	elseif action_type == "shoot" then
		my_data.shooting = nil
	elseif action_type == "tase" then
		if action:expired() and my_data.tasing then
			local record = managers.groupai:state():criminal_record(my_data.tasing.target_u_key)

			if record and record.status then
				data.tase_delay_t = TimerManager:game():time() + 45
			end
		end
		
		if my_data.tasing then
			managers.groupai:state():on_tase_end(my_data.tasing.target_u_key)
		end

		my_data.tasing = nil
		
		if action:expired() and not my_data.tasing then
			TaserLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			TaserLogicAttack._upd_combat_movement(data)
		end
	elseif action_type == "reload" then
		--Removed the requirement for being important here.
		if action:expired() then
			TaserLogicAttack._cancel_tase_attempt(data, my_data)
			TaserLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
		end
	elseif action_type == "turn" then
		my_data.turning = nil
	elseif action_type == "act" then
		--TaserLogicAttack._cancel_cover_pathing(data, my_data)
		--TaserLogicAttack._cancel_charge(data, my_data)
		
		--Fixed panic never waking up cops.
		if action:expired() then
			TaserLogicAttack._cancel_tase_attempt(data, my_data)
			TaserLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
		end
	elseif action_type == "hurt" then
		TaserLogicAttack._cancel_cover_pathing(data, my_data)
		TaserLogicAttack._cancel_charge(data, my_data)
		
		--Removed the requirement for being important here.
		if action:expired() and not CopLogicBase.chk_start_action_dodge(data, "hit") then
			TaserLogicAttack._cancel_tase_attempt(data, my_data)
			TaserLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
		end
	elseif action_type == "dodge" then
		local timeout = action:timeout()

		if timeout then
			data.dodge_timeout_t = TimerManager:game():time() + math.lerp(timeout[1], timeout[2], math.random())
		end

		TaserLogicAttack._cancel_cover_pathing(data, my_data)

		if action:expired() then
			TaserLogicAttack._cancel_tase_attempt(data, my_data)
			TaserLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
		end
	end
end

function TaserLogicAttack._chk_play_charge_weapon_sound(data, my_data, focus_enemy)
end