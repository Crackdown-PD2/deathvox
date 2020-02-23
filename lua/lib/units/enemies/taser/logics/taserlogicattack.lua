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
		CopLogicAttack._upd_stop_old_action(data, my_data)
		CopLogicBase.queue_task(my_data, my_data.update_task_key, TaserLogicAttack.queued_update, data, data.t + 0)

		return
	end

	if CopLogicIdle._chk_relocate(data) then
		return
	end

	CopLogicAttack._update_cover(data)

	local t = TimerManager:game():time()
	data.t = t
	local unit = data.unit
	local objective = data.objective
	local focus_enemy = data.attention_obj
	local action_taken = my_data.turning or data.unit:movement():chk_action_forbidden("walk") or my_data.moving_to_cover or my_data.walking_to_cover_shoot_pos or my_data.acting

	if my_data.tasing then
		action_taken = action_taken or CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, focus_enemy.m_pos)

		CopLogicBase.queue_task(my_data, my_data.update_task_key, TaserLogicAttack.queued_update, data, data.t + 0)
		CopLogicBase._report_detections(data.detected_attention_objects)

		return
	end

	CopLogicAttack._process_pathing_results(data, my_data)

	if AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction then
		CopLogicAttack._update_cover(data)
		CopLogicAttack._upd_combat_movement(data)
	end
	
	CopLogicBase.queue_task(my_data, my_data.update_task_key, TaserLogicAttack.queued_update, data, data.t + 0) --update asap
	CopLogicBase._report_detections(data.detected_attention_objects)
end

function TaserLogicAttack._upd_aim(data, my_data, reaction)
	local shoot, aim = nil
	local focus_enemy = data.attention_obj
	local tase = reaction == AIAttentionObject.REACT_SPECIAL_ATTACK

	if focus_enemy then
		if tase then
			shoot = true
		elseif focus_enemy.verified then
			if focus_enemy.verified_dis > 1500 then
				shoot = true
				if focus_enemy.verified_dis > 1500 and data.unit:anim_data().run then
					local walk_to_pos = data.unit:movement():get_walk_to_pos()

					if walk_to_pos then
						local move_vec = walk_to_pos - data.m_pos
						local enemy_vec = focus_enemy.m_pos - data.m_pos

						mvector3.normalize(enemy_vec)

						if mvector3.dot(enemy_vec, move_vec) < 0.6 then
							shoot = nil
						end
					end
				end
			end
		elseif focus_enemy.verified_t and data.t - focus_enemy.verified_t < 10 then
			aim = true

			if my_data.shooting and data.t - focus_enemy.verified_t < 3 then
				shoot = true
			end
		elseif focus_enemy.verified_dis <= 1500 and my_data.walking_to_cover_shoot_pos then
			aim = true
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

	if focus_enemy and data.logic.chk_should_turn(data, my_data) then
		local enemy_pos = (focus_enemy.verified or focus_enemy.nearly_visible) and focus_enemy.m_pos or focus_enemy.verified_pos

		CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, enemy_pos)
	end

	if aim or shoot then
		if focus_enemy.verified then
			if my_data.attention_unit ~= focus_enemy.u_key then
				CopLogicBase._set_attention(data, focus_enemy)

				my_data.attention_unit = focus_enemy.u_key
			end
		elseif my_data.attention_unit ~= focus_enemy.verified_pos then
			CopLogicBase._set_attention_on_pos(data, mvector3.copy(focus_enemy.verified_pos))

			my_data.attention_unit = mvector3.copy(focus_enemy.verified_pos)
		end
		
		local nottasingortargetwrong = not my_data.tasing or my_data.tasing.target_u_data ~= focus_enemy
		
		if not data.unit:anim_data().reload and not data.unit:movement():chk_action_forbidden("action") then
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

						CopLogicAttack._cancel_charge(data, my_data)
						managers.groupai:state():on_tase_start(data.key, focus_enemy.u_key)
					end
				end
			elseif shoot and not my_data.shooting then
				local shoot_action = {
					type = "shoot",
					body_part = 3
				}

				if data.unit:brain():action_request(shoot_action) then
					my_data.shooting = true
				end
			end
		end
	else
		if my_data.shooting or my_data.tasing then
			local new_action = {
				body_part = 3,
				type = "idle"
			}
			
			if not data.unit:anim_data().reload and not data.unit:movement():chk_action_forbidden("action") then
				data.unit:brain():action_request(new_action)
			end
		elseif not data.unit:anim_data().run then
			local ammo_max, ammo = data.unit:inventory():equipped_unit():base():ammo_info()

			if ammo / ammo_max < 0.05 then
				local new_action = {
					body_part = 3,
					type = "reload"
				}

				data.unit:brain():action_request(new_action)
			end
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
	CopLogicAttack._chk_exit_attack_logic(data, new_reaction)

	if my_data ~= data.internal_data then
		return
	end

	if new_attention then
		if old_att_obj then
			if old_att_obj.u_key ~= new_attention.u_key then
				CopLogicAttack._cancel_charge(data, my_data)

				if not data.unit:movement():chk_action_forbidden("walk") then
					CopLogicAttack._cancel_walking_to_cover(data, my_data)
				end

				CopLogicAttack._set_best_cover(data, my_data, nil)
				--TaserLogicAttack._chk_play_charge_weapon_sound(data, my_data, new_attention)
			end
		else
			--TaserLogicAttack._chk_play_charge_weapon_sound(data, my_data, new_attention)
		end
	elseif old_att_obj then
		CopLogicAttack._cancel_charge(data, my_data)
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

		local obstructed = data.unit:raycast("ray", data.unit:movement():m_head_pos(), attention_data.m_head_pos, "slot_mask", managers.slot:get_mask("world_geometry", "vehicles", "enemy_shield_check"), "sphere_cast_radius", 30, "report")

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

	if action_type == "walk" then
		my_data.advancing = nil
		my_data.flank_cover = nil
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
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

		managers.groupai:state():on_tase_end(my_data.tasing.target_u_key)

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
			TaserLogicAttack._upd_combat_movement(data)
		end
	elseif action_type == "turn" then
		my_data.turning = nil
	elseif action_type == "act" then
		--CopLogicAttack._cancel_cover_pathing(data, my_data)
		--CopLogicAttack._cancel_charge(data, my_data)
		
		--Fixed panic never waking up cops.
		if action:expired() then
			TaserLogicAttack._cancel_tase_attempt(data, my_data)
			TaserLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			CopLogicAttack._upd_combat_movement(data)
		end
	elseif action_type == "hurt" then
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
		
		--Removed the requirement for being important here.
		if action:expired() and not CopLogicBase.chk_start_action_dodge(data, "hit") then
			TaserLogicAttack._cancel_tase_attempt(data, my_data)
			TaserLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			TaserLogicAttack._upd_combat_movement(data)
		end
	elseif action_type == "dodge" then
		local timeout = action:timeout()

		if timeout then
			data.dodge_timeout_t = TimerManager:game():time() + math.lerp(timeout[1], timeout[2], math.random())
		end

		CopLogicAttack._cancel_cover_pathing(data, my_data)

		if action:expired() then
			TaserLogicAttack._cancel_tase_attempt(data, my_data)
			TaserLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			TaserLogicAttack._upd_combat_movement(data)
		end
	end
end

function TaserLogicAttack._chk_play_charge_weapon_sound(data, my_data, focus_enemy)
	--[[if not my_data.tasing and (not my_data.last_charge_snd_play_t or data.t - my_data.last_charge_snd_play_t > 30) and focus_enemy.verified_dis <= 1500 and math.abs(data.m_pos.z - focus_enemy.m_pos.z) < 300 then
		my_data.last_charge_snd_play_t = data.t

		data.unit:sound():play("taser_charge", nil, true)
	end]]
end

TaserLogicTravel = class(CopLogicTravel)

function TaserLogicTravel.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action:type()
	
	local mook_units = {
		"security",
		"security_undominatable",
		"cop",
		"cop_scared",
		"cop_female",
		"gensec",
		"fbi",
		"swat",
		"heavy_swat",
		"fbi_swat",
		"fbi_heavy_swat",
		"city_swat",
		"gangster",
		"biker",
		"mobster",
		"bolivian",
		"bolivian_indoors",
		"medic",
		"taser",
		"deathvox_guard",
		"deathvox_heavyar",
		"deathvox_heavyshot",
		"deathvox_lightar",
		"deathvox_lightshot",
		"deathvox_medic",
		"deathvox_shield",
		"deathvox_taser",
		"deathvox_cloaker",
		"deathvox_sniper_assault",
		"deathvox_grenadier"
	}
	local is_mook = nil
	for _, name in ipairs(mook_units) do
		if data.unit:base()._tweak_table == name then
			is_mook = true
		end
	end
	
	
	--if is_mook then
		--log("AHAHAHAHAH FUCK YEAH IS_MOOK")
	--end

	if action_type == "walk" then
		--if CopLogicTravel.chk_slide_conditions(data) then 
			--data.unit:movement():play_redirect("e_nl_slide_fwd_4m")
		--end
		
		TaserLogicAttack._cancel_tase_attempt(data, my_data)
		
		if action:expired() and not my_data.starting_advance_action and my_data.coarse_path_index and not my_data.has_old_action and my_data.advancing then
			my_data.coarse_path_index = my_data.coarse_path_index + 1

			if my_data.coarse_path_index > #my_data.coarse_path then
				debug_pause_unit(data.unit, "[CopLogicTravel.action_complete_clbk] invalid coarse path index increment", data.unit, inspect(my_data.coarse_path), my_data.coarse_path_index)

				my_data.coarse_path_index = my_data.coarse_path_index - 1
			end
			TaserLogicTravel.upd_advance(data)
		end

		my_data.advancing = nil

		if my_data.moving_to_cover then
			if action:expired() then
				if my_data.best_cover then
					managers.navigation:release_cover(my_data.best_cover[1])
				end

				my_data.best_cover = my_data.moving_to_cover

				CopLogicBase.chk_cancel_delayed_clbk(my_data, my_data.cover_update_task_key)

				local high_ray = CopLogicTravel._chk_cover_height(data, my_data.best_cover[1], data.visibility_slotmask)
				my_data.best_cover[4] = high_ray
				my_data.in_cover = true
				
				local cover_wait_time = nil
				
				local should_tacticool_wait = data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis >= 1200 and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < math.random(2, 4) and math.abs(data.m_pos.z - data.attention_obj.m_pos.z) > 250 or managers.groupai:state():chk_high_fed_density() --if an enemy is not at semi equal height, and further than 12 meters, and we've seen him at least two to four seconds ago, do a slower, more tacticool approach
				
				if should_tacticool_wait then
					cover_wait_time = math.random(0.4, 0.64) --If there is a height advantage/disadvantage, act tacticool and approach slower.
					--log("HH: cop waiting due to height difference")
				else
					cover_wait_time = math.random(0.35, 0.5) --Keep enemies aggressive and active while still preserving some semblance of what used to be the original pacing while not in Shin Shootout mode
				end
				
				if not is_mook or Global.game_settings.one_down and not managers.groupai:state():chk_high_fed_density() or data.unit:base():has_tag("takedown") or data.is_converted or data.unit:in_slot(16) or data.unit:in_slot(managers.slot:get_mask("criminals")) then
					my_data.cover_leave_t = data.t + 0
				else
					my_data.cover_leave_t = data.t + cover_wait_time
				end
				
			else
				managers.navigation:release_cover(my_data.moving_to_cover[1])

				if my_data.best_cover then
					local facing_cover = nil
					local dis = mvector3.distance(my_data.best_cover[1][1], data.unit:movement():m_pos())
					local cover_search_dis = nil
					
					if no_cover_search_dis_change or not is_mook then
						cover_search_dis = 100
					else
						cover_search_dis = 250
					end
					
					--if cover_search_dis == 200 then
						--log("thats hot")
					--end

					if dis > cover_search_dis then
						managers.navigation:release_cover(my_data.best_cover[1])

						my_data.best_cover = nil
					end
				end
			end

			my_data.moving_to_cover = nil
		elseif my_data.best_cover then
			local dis = mvector3.distance(my_data.best_cover[1][1], data.unit:movement():m_pos())
			local cover_search_dis = nil
					
			if not is_mook then
				cover_search_dis = 100
			else
				cover_search_dis = 250
			end
			
			if dis > cover_search_dis then
				managers.navigation:release_cover(my_data.best_cover[1])

				my_data.best_cover = nil
			end
		end

		if not action:expired() then
			if my_data.processing_advance_path then
				local pathing_results = data.pathing_results

				if pathing_results and pathing_results[my_data.advance_path_search_id] then
					data.pathing_results[my_data.advance_path_search_id] = nil
					my_data.processing_advance_path = nil
				end
			elseif my_data.advance_path then
				my_data.advance_path = nil
			end

			data.unit:brain():abort_detailed_pathing(my_data.advance_path_search_id)
		end
	elseif action_type == "shoot" then
		my_data.shooting = nil
	elseif action_type == "tase" then
		if action:expired() and my_data.tasing then
			local record = managers.groupai:state():criminal_record(my_data.tasing.target_u_key)

			if record and record.status then
				data.tase_delay_t = TimerManager:game():time() + 45
			end
			TaserLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			TaserLogicTravel.upd_advance(data)
		end

		managers.groupai:state():on_tase_end(my_data.tasing.target_u_key)

		my_data.tasing = nil
	elseif action_type == "spooc" then
		data.spooc_attack_timeout_t = TimerManager:game():time() + math.lerp(data.char_tweak.spooc_attack_timeout[1], data.char_tweak.spooc_attack_timeout[2], math.random())

		if action:complete() and data.char_tweak.spooc_attack_use_smoke_chance > 0 and math.random() <= data.char_tweak.spooc_attack_use_smoke_chance and not managers.groupai:state():is_smoke_grenade_active() then
			managers.groupai:state():detonate_smoke_grenade(data.m_pos + math.UP * 10, data.unit:movement():m_head_pos(), math.lerp(15, 30, math.random()), false)
		end
		
		if action:expired() then
			TaserLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			TaserLogicTravel.upd_advance(data)
		end

		my_data.spooc_attack = nil
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
		--CopLogicAttack._cancel_cover_pathing(data, my_data)
		--CopLogicAttack._cancel_charge(data, my_data)
		
		--Fixed panic never waking up cops.
		if action:expired() then
			TaserLogicAttack._cancel_tase_attempt(data, my_data)
			TaserLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			TaserLogicTravel.upd_advance(data)
		end
	elseif action_type == "hurt" then
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
		
		--Removed the requirement for being important here.
		if action:expired() and not CopLogicBase.chk_start_action_dodge(data, "hit") then
			TaserLogicAttack._cancel_tase_attempt(data, my_data)
			TaserLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			TaserLogicTravel.upd_advance(data)
		end
		
	elseif action_type == "dodge" then
		local timeout = action:timeout()

		if timeout then
			data.dodge_timeout_t = TimerManager:game():time() + math.lerp(timeout[1], timeout[2], math.random())
		end

		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
		
		if action:expired() then
			TaserLogicAttack._cancel_tase_attempt(data, my_data)
			TaserLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			TaserLogicTravel.upd_advance(data)
		end
	end
end

function TaserLogicTravel._chk_reaction_to_attention_object(data, attention_data, stationary)
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

		local obstructed = data.unit:raycast("ray", data.unit:movement():m_head_pos(), attention_data.m_head_pos, "slot_mask", managers.slot:get_mask("world_geometry", "vehicles", "enemy_shield_check"), "sphere_cast_radius", 5, "report")

		if obstructed then
			return AIAttentionObject.REACT_COMBAT
		else
			return AIAttentionObject.REACT_SPECIAL_ATTACK
		end
	end

	return reaction
end

function TaserLogicTravel._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	local my_data = data.internal_data
	local min_reaction = AIAttentionObject.REACT_AIM
	local delay = CopLogicBase._upd_attention_obj_detection(data, min_reaction, nil)
	
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
	
	local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, data.detected_attention_objects, TaserLogicTravel._chk_reaction_to_attention_object)
	local old_att_obj = data.attention_obj

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)

	local objective = data.objective
	local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, new_attention)

	if allow_trans and (obj_failed or not objective or objective.type ~= "follow") then
		local wanted_state = CopLogicBase._get_logic_state_from_reaction(data)

		if wanted_state and wanted_state ~= data.name then
			if obj_failed then
				data.objective_failed_clbk(data.unit, data.objective)
			end

			if my_data == data.internal_data and not objective.is_default then
				debug_pause_unit(data.unit, "[TaserLogicTravel._upd_enemy_detection] exiting without discarding objective", data.unit, inspect(objective))
				CopLogicBase._exit(data.unit, wanted_state)
			end

			CopLogicBase._report_detections(data.detected_attention_objects)

			return delay
		end
	end

	if my_data == data.internal_data then
		if data.cool and new_reaction == AIAttentionObject.REACT_SUSPICIOUS and CopLogicBase._upd_suspicion(data, my_data, new_attention) then
			CopLogicBase._report_detections(data.detected_attention_objects)

			return delay
		elseif new_reaction and new_reaction <= AIAttentionObject.REACT_SCARED then
			local set_attention = data.unit:movement():attention()

			if not set_attention or set_attention.u_key ~= new_attention.u_key then
				CopLogicBase._set_attention(data, new_attention, nil)
			end
		end

		TaserLogicAttack._upd_aim(data, my_data)
	end

	CopLogicBase._report_detections(data.detected_attention_objects)

	if new_attention and data.char_tweak.chatter.entrance and not data.entrance and new_attention.criminal_record and new_attention.verified and AIAttentionObject.REACT_SCARED <= new_reaction and math.abs(data.m_pos.z - new_attention.m_pos.z) < 4000 then
		data.unit:sound():say(data.brain.entrance_chatter_cue or "entrance", true, nil)

		data.entrance = true
	end

	if data.cool then
		TaserLogicTravel.upd_suspicion_decay(data)
	end

	return delay
end