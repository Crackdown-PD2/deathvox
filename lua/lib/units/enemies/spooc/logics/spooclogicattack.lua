function SpoocLogicAttack.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.unit:brain():cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit
	}
	data.internal_data = my_data
	my_data.detection = data.char_tweak.detection.combat

	if old_internal_data then
		my_data.turning = old_internal_data.turning
		my_data.firing = old_internal_data.firing
		my_data.shooting = old_internal_data.shooting
		my_data.attention_unit = old_internal_data.attention_unit

		CopLogicAttack._set_best_cover(data, my_data, old_internal_data.best_cover)
		CopLogicAttack._set_nearest_cover(my_data, old_internal_data.nearest_cover)
	end

	local key_str = tostring(data.key)
	my_data.update_queue_id = "SpoocLogicAttack.queued_update" .. key_str

	CopLogicBase.queue_task(my_data, my_data.update_queue_id, SpoocLogicAttack.queued_update, data, data.t)

	my_data.detection_task_key = "SpoocLogicAttack._upd_enemy_detection" .. key_str

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, SpoocLogicAttack._upd_enemy_detection, data, data.t)
	data.unit:brain():set_update_enabled_state(false)
	CopLogicIdle._chk_has_old_action(data, my_data)

	local objective = data.objective

	if objective then
		my_data.attitude = data.objective.attitude or "avoid"
	end

	my_data.weapon_range = data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range

	data.unit:movement():set_cool(false)

	if my_data ~= data.internal_data then
		return
	end

	my_data.cover_test_step = 1
	data.spooc_attack_timeout_t = data.spooc_attack_timeout_t or 0

	data.unit:brain():set_attention_settings({
		cbt = true
	})
end

function SpoocLogicAttack.queued_update(data)
	local t = TimerManager:game():time()
	data.t = t
	local unit = data.unit
	local my_data = data.internal_data

	if my_data.spooc_attack then
		if my_data.spooc_attack.action:complete() and data.attention_obj and (not data.attention_obj.criminal_record or not data.attention_obj.criminal_record.status) and (data.attention_obj.verified or data.attention_obj.nearly_visible) and data.attention_obj.dis < my_data.weapon_range.close then
			SpoocLogicAttack._cancel_spooc_attempt(data, my_data)
		end

		if data.internal_data == my_data then
			CopLogicBase._report_detections(data.detected_attention_objects)
			SpoocLogicAttack.queue_update(data, my_data)
		end

		return
	end

	if my_data.has_old_action then
		CopLogicAttack._upd_stop_old_action(data, my_data)
		SpoocLogicAttack.queue_update(data, my_data)

		return
	end

	if CopLogicIdle._chk_relocate(data) then
		return
	end

	if my_data.wants_stop_old_walk_action then
		if not data.unit:anim_data().to_idle and not data.unit:movement():chk_action_forbidden("walk") then
			data.unit:movement():action_request({
				body_part = 2,
				type = "idle"
			})

			my_data.wants_stop_old_walk_action = nil
		end

		SpoocLogicAttack.queue_update(data, my_data)

		return
	end

	CopLogicAttack._process_pathing_results(data, my_data)

	if not data.attention_obj or data.attention_obj.reaction < AIAttentionObject.REACT_AIM then
		CopLogicAttack._upd_enemy_detection(data, true)

		if my_data ~= data.internal_data or not data.attention_obj then
			return
		end
	end

	if my_data.spooc_attack then
		SpoocLogicAttack.queue_update(data, my_data)

		return
	end

	if AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction then
		my_data.want_to_take_cover = CopLogicAttack._chk_wants_to_take_cover(data, my_data)

		CopLogicAttack._update_cover(data)
		CopLogicAttack._upd_combat_movement(data)
	end

	SpoocLogicAttack.queue_update(data, my_data)
	CopLogicBase._report_detections(data.detected_attention_objects)
end

function SpoocLogicAttack._upd_spooc_attack(data, my_data)
	if not data then
		--log("how did this happen!?")
		return
	end
	
	local focus_enemy = data.attention_obj
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	local spooc_attack_timeout_chk = not data.spooc_attack_timeout_t or data.spooc_attack_timeout_t < data.t
	if focus_enemy and not my_data.spooc_attack and spooc_attack_timeout_chk and focus_enemy.reaction == AIAttentionObject.REACT_SPECIAL_ATTACK and not data.unit:movement():chk_action_forbidden("walk") then
		if math.abs(data.m_pos.z - focus_enemy.m_pos.z) < 200 then
			
			if focus_enemy.verified and focus_enemy.dis <= 1500 then
				managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "cloakercontact")
			end
			
			if math.abs(data.m_pos.z - focus_enemy.m_pos.z) < 100 and focus_enemy.dis > 600 or math.abs(data.m_pos.z - focus_enemy.m_pos.z) < 100 and math.random() < 0.5 then
				if diff_index >= 6 and focus_enemy.verified_dis <= 250 or Global.game_settings.use_intense_AI and focus_enemy.verified_dis <= 250 then
					if my_data.attention_unit ~= focus_enemy.u_key then
						CopLogicBase._set_attention(data, focus_enemy)
						
						my_data.attention_unit = focus_enemy.u_key
					end

					local action = SpoocLogicAttack._chk_request_action_spooc_attack(data, my_data)

					if action then
						my_data.spooc_attack = {
							start_t = data.t,
							target_u_data = focus_enemy,
							action = action
						}

						return true
					end
				elseif focus_enemy.verified_dis <= 1500 and ActionSpooc.chk_can_start_spooc_sprint(data.unit, focus_enemy.unit) and not data.unit:raycast("ray", data.unit:movement():m_head_pos(), focus_enemy.m_head_pos, "slot_mask", managers.slot:get_mask("world_geometry", "vehicles", "enemy_shield_check"), "report") then
					if my_data.attention_unit ~= focus_enemy.u_key then
						CopLogicBase._set_attention(data, focus_enemy)

						my_data.attention_unit = focus_enemy.u_key
					end

					local action = SpoocLogicAttack._chk_request_action_spooc_attack(data, my_data)

					if action then
						my_data.spooc_attack = {
							start_t = data.t,
							target_u_data = focus_enemy,
							action = action
						}

						return true
					end
				end
			elseif focus_enemy.verified_dis <= 600 and ActionSpooc.chk_can_start_flying_strike(data.unit, focus_enemy.unit) then
				if my_data.attention_unit ~= focus_enemy.u_key then
					CopLogicBase._set_attention(data, focus_enemy)

					my_data.attention_unit = focus_enemy.u_key
				end

				local action = SpoocLogicAttack._chk_request_action_spooc_attack(data, my_data, true)

				if action then
					my_data.spooc_attack = {
						start_t = data.t,
						target_u_data = focus_enemy,
						action = action
					}

					return true
				end
			end
		end
	end
end

function SpoocLogicAttack.queue_update(data, my_data)
	my_data.update_queued = true

	CopLogicBase.queue_task(my_data, my_data.update_queue_id, SpoocLogicAttack.queued_update, data, data.t + 0)
end

function SpoocLogicAttack._upd_enemy_detection(data, is_synchronous)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local delay = CopLogicBase._upd_attention_obj_detection(data, nil, nil)
	local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, data.detected_attention_objects, SpoocLogicAttack._chk_reaction_to_attention_object)
	local old_att_obj = data.attention_obj

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)
	data.logic._chk_exit_attack_logic(data, new_reaction)

	if my_data ~= data.internal_data then
		return
	end

	if new_attention then
		if old_att_obj and old_att_obj.u_key ~= new_attention.u_key then
			CopLogicAttack._cancel_charge(data, my_data)

			my_data.flank_cover = nil

			if not data.unit:movement():chk_action_forbidden("walk") then
				CopLogicAttack._cancel_walking_to_cover(data, my_data)
			end

			CopLogicAttack._set_best_cover(data, my_data, nil)
		end
	elseif old_att_obj then
		CopLogicAttack._cancel_charge(data, my_data)

		my_data.flank_cover = nil
	end

	CopLogicBase._chk_call_the_police(data)

	if my_data ~= data.internal_data then
		return
	end

	SpoocLogicAttack._upd_aim(data, my_data)
	SpoocLogicAttack._upd_spooc_attack(data, my_data)

	if not is_synchronous then
		CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicAttack._upd_enemy_detection, data, delay and data.t + delay, data.important and true)
	end

	CopLogicBase._report_detections(data.detected_attention_objects)
end

function SpoocLogicAttack._chk_reaction_to_attention_object(data, attention_data, stationary)
    local reaction = CopLogicIdle._chk_reaction_to_attention_object(data, attention_data, stationary)

    if reaction < AIAttentionObject.REACT_SHOOT or not attention_data.criminal_record or attention_data.criminal_record.status or not attention_data.is_person then
        return reaction
    end

    if attention_data.verified then
        if attention_data.verified_dis > 1500 then
            return AIAttentionObject.REACT_COMBAT
        end

        if attention_data.is_human_player then
            if attention_data.unit:movement().zipline_unit and attention_data.unit:movement():zipline_unit() then
                return AIAttentionObject.REACT_COMBAT
            end
        elseif attention_data.unit:movement():chk_action_forbidden("hurt") then
            return AIAttentionObject.REACT_COMBAT
        end

        if SpoocLogicAttack._is_last_standing_criminal(attention_data) then
            return AIAttentionObject.REACT_COMBAT
        end

        if not attention_data.unit:movement().is_SPOOC_attack_allowed or not attention_data.unit:movement():is_SPOOC_attack_allowed() then
            return AIAttentionObject.REACT_COMBAT
        end

        return AIAttentionObject.REACT_SPECIAL_ATTACK
    end

    return reaction
end

function SpoocLogicAttack.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action:type()

	if action_type == "walk" then
		my_data.advancing = nil
		my_data.flank_cover = nil
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
		SpoocLogicAttack._cancel_spooc_attempt(data, my_data)
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
	elseif action_type == "spooc" then
		data.spooc_attack_timeout_t = TimerManager:game():time() + math.lerp(data.char_tweak.spooc_attack_timeout[1], data.char_tweak.spooc_attack_timeout[2], math.random())

		if action:complete() and data.char_tweak.spooc_attack_use_smoke_chance > 0 and math.random() <= data.char_tweak.spooc_attack_use_smoke_chance and not managers.groupai:state():is_smoke_grenade_active() then
			managers.groupai:state():detonate_smoke_grenade(data.m_pos + math.UP * 10, data.unit:movement():m_head_pos(), math.lerp(15, 30, math.random()), false)
		end

		my_data.spooc_attack = nil
		
		if action:expired() then
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
			SpoocLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			SpoocLogicAttack._upd_combat_movement(data)
		end
		
	elseif action_type == "reload" then
		--Removed the requirement for being important here.
		if action:expired() then
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
			SpoocLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			SpoocLogicAttack._upd_combat_movement(data)
		end
	elseif action_type == "turn" then
		my_data.turning = nil
	elseif action_type == "act" then
		--CopLogicAttack._cancel_cover_pathing(data, my_data)
		--CopLogicAttack._cancel_charge(data, my_data)
		
		--Fixed panic never waking up cops.
		if action:expired() then
			SpoocLogicAttack._upd_aim(data, my_data)
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			SpoocLogicAttack._upd_combat_movement(data)
		end
	elseif action_type == "hurt" then
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
		SpoocLogicAttack._cancel_spooc_attempt(data, my_data)
		
		--Removed the requirement for being important here.
		if action:expired() and not CopLogicBase.chk_start_action_dodge(data, "hit") then
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
			SpoocLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			SpoocLogicAttack._upd_combat_movement(data)
		end
	elseif action_type == "dodge" then
		local timeout = action:timeout()

		if timeout then
			data.dodge_timeout_t = TimerManager:game():time() + math.lerp(timeout[1], timeout[2], math.random())
		end

		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
		SpoocLogicAttack._cancel_spooc_attempt(data, my_data)

		if action:expired() then
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
			SpoocLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			SpoocLogicAttack._upd_combat_movement(data)
		end
	end
end

SpoocLogicTravel = class(CopLogicTravel)

function SpoocLogicTravel.action_complete_clbk(data, action)
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
		"taser"
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
		SpoocLogicAttack._cancel_spooc_attempt(data, my_data)
		
		if action:expired() and not my_data.starting_advance_action and my_data.coarse_path_index and not my_data.has_old_action and my_data.advancing then
			my_data.coarse_path_index = my_data.coarse_path_index + 1

			if my_data.coarse_path_index > #my_data.coarse_path then
				debug_pause_unit(data.unit, "[CopLogicTravel.action_complete_clbk] invalid coarse path index increment", data.unit, inspect(my_data.coarse_path), my_data.coarse_path_index)

				my_data.coarse_path_index = my_data.coarse_path_index - 1
			end
			SpoocLogicTravel.upd_advance(data)
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
			CopLogicAttack._upd_combat_movement(data)
		end

		managers.groupai:state():on_tase_end(my_data.tasing.target_u_key)

		my_data.tasing = nil
	elseif action_type == "spooc" then
		data.spooc_attack_timeout_t = TimerManager:game():time() + math.lerp(data.char_tweak.spooc_attack_timeout[1], data.char_tweak.spooc_attack_timeout[2], math.random())

		if action:complete() and data.char_tweak.spooc_attack_use_smoke_chance > 0 and math.random() <= data.char_tweak.spooc_attack_use_smoke_chance and not managers.groupai:state():is_smoke_grenade_active() then
			managers.groupai:state():detonate_smoke_grenade(data.m_pos + math.UP * 10, data.unit:movement():m_head_pos(), math.lerp(15, 30, math.random()), false)
		end

		my_data.spooc_attack = nil
		
		if action:expired() then
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
			SpoocLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			SpoocLogicTravel.upd_advance(data)
		end
	elseif action_type == "reload" then
		--Removed the requirement for being important here.
		if action:expired() then
			CopLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
		end
	elseif action_type == "turn" then
		my_data.turning = nil
	elseif action_type == "act" then
		--CopLogicAttack._cancel_cover_pathing(data, my_data)
		--CopLogicAttack._cancel_charge(data, my_data)
		
		--Fixed panic never waking up cops.
		if action:expired() then
			SpoocLogicAttack._upd_aim(data, my_data)
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			SpoocLogicTravel.upd_advance(data)
		end
	elseif action_type == "hurt" then
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
		SpoocLogicAttack._cancel_spooc_attempt(data, my_data)
		
		--Removed the requirement for being important here.
		if action:expired() and not CopLogicBase.chk_start_action_dodge(data, "hit") then
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
			SpoocLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			SpoocLogicTravel.upd_advance(data)
		end
	elseif action_type == "dodge" then
		local timeout = action:timeout()

		if timeout then
			data.dodge_timeout_t = TimerManager:game():time() + math.lerp(timeout[1], timeout[2], math.random())
		end

		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
		SpoocLogicAttack._cancel_spooc_attempt(data, my_data)

		if action:expired() then
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
			SpoocLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			SpoocLogicTravel.upd_advance(data)
		end
	end
end

function SpoocLogicTravel.queued_update(data)
    local my_data = data.internal_data
    data.t = TimerManager:game():time()
    my_data.close_to_criminal = nil
    local delay = SpoocLogicTravel._upd_enemy_detection(data)
    
    if data.internal_data ~= my_data then
    	return
    end
    
    SpoocLogicTravel.upd_advance(data)
    
    if data.internal_data ~= my_data then
    	return
    end
    
    if not delay then
    	debug_pause_unit(data.unit, "crap!!!", inspect(data))	
    
    	delay = 0.35
    end
	
	local level = Global.level_data and Global.level_data.level_id
	local hostage_count = managers.groupai:state():get_hostage_count_for_chatter() --check current hostage count
	local chosen_panic_chatter = "controlpanic" --set default generic assault break chatter
	
	if hostage_count > 0 and not managers.groupai:state():chk_assault_active_atm() then --make sure the hostage count is actually above zero before replacing any of the lines
		if hostage_count > 3 then  -- hostage count needs to be above 3
			if math.random() < 0.4 then --40% chance
				chosen_panic_chatter = "controlpanic"
			else
				chosen_panic_chatter = "hostagepanic2" --more panicky "GET THOSE HOSTAGES OUT RIGHT NOW!!!" line for when theres too many hostages on the map
			end
		else
			if math.random() < 0.4 then
				chosen_panic_chatter = "controlpanic"
			else
				chosen_panic_chatter = "hostagepanic1" --less panicky "Delay the assault until those hostages are out." line
			end
		end
	end
	
	local chosen_sabotage_chatter = "sabotagegeneric" --set default sabotage chatter for variety's sake
	local skirmish_map = level == "skm_mus" or level == "skm_red2" or level == "skm_run" or level == "skm_watchdogs_stage2" --these shouldnt play on holdout
	local ignore_radio_rules = nil
	
	if level == "branchbank" then --bank heist
		chosen_sabotage_chatter = "sabotagedrill"
	elseif level == "nmh" or level == "man" or level == "framing_frame_3" or level == "rat" or level == "election_day_1" then --various heists where turning off the power is a frequent occurence
		chosen_sabotage_chatter = "sabotagepower"
	elseif level == "chill_combat" or level == "watchdogs_1" or level == "watchdogs_1_night" or level == "watchdogs_2" or level == "watchdogs_2_day" or level == "cane" then
		chosen_sabotage_chatter = "sabotagebags"
		ignore_radio_rules = true
	else
		chosen_sabotage_chatter = "sabotagegeneric" --if none of these levels are the current one, use a generic "Break their gear!" line
	end
	
	local cant_say_clear = data.attention_obj and data.attention_obj.reaction <= AIAttentionObject.REACT_COMBAT and data.attention_obj.verified_t and data.attention_obj.verified_t - data.t < 5
	
    if not data.unit:base():has_tag("special") then
    	if data.char_tweak.chatter.clear and not cant_say_clear and not data.is_converted then
			if data.unit:movement():cool() then
				managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "clear_whisper" )
			else
				local clearchk = math.random(0, 90)
				local say_clear = 30
				if clearchk > 60 then
					managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "clear" )
				elseif clearchk > 30 then
					if not skirmish_map and my_data.radio_voice or not skirmish_map and ignore_radio_rules then
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_sabotage_chatter )
					else
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_panic_chatter )
					end
				else
					managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_panic_chatter )
				end
			end
		end
    end
	
	if data.unit:base():has_tag("tank") or data.unit:base():has_tag("taser") then
    	if not cant_say_clear then
			managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "approachingspecial" )
		end
    end
	
	if data.unit:base()._tweak_table == "akuma" then
		managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "lotusapproach" )
	end
	
	--mid-assault panic for cops based on alerts instead of opening fire, since its supposed to be generic action lines instead of for opening fire and such
	--I'm adding some randomness to these since the delays in groupaitweakdata went a bit overboard but also arent able to really discern things proper
	
	if data.char_tweak and data.char_tweak.chatter and data.char_tweak.chatter.enemyidlepanic and not data.is_converted and not data.unit:base():has_tag("special") then
		if managers.groupai:state():chk_assault_active_atm() or not data.unit:base():has_tag("law") then
			if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.alert_t and data.t - data.attention_obj.alert_t < 1 and data.attention_obj.dis <= 3000 then
				if data.attention_obj.verified and data.attention_obj.dis <= 500 or data.is_suppressed and data.attention_obj.verified then
					local roll = math.random(1, 100)
					local chance_suppanic = 30
					
					if roll <= chance_suppanic then
						local nroll = math.random(1, 100)
						local chance_help = 50
						if roll <= chance_suppanic or not data.unit:base():has_tag("law") then
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanicsuppressed1" )
						else
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanicsuppressed2" )
						end
					else
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanic" )
					end
				else
					if math.random() < 0.1 and data.unit:base():has_tag("law") then
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_sabotage_chatter )
					else
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanic" )
					end
				end
			end
		end
	end
	
	local objective = data.objective or nil
	
	data.logic._update_haste(data, data.internal_data)
	data.logic._upd_stance_and_pose(data, data.internal_data, objective)
	SpoocLogicAttack._upd_spooc_attack(data, my_data)
	
	if CopLogicBase.should_enter_attack(data) then
		CopLogicBase._exit(data.unit, "attack")
		return
	end
      
    SpoocLogicTravel.queue_update(data, data.internal_data, delay)
end

function SpoocLogicTravel._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	local my_data = data.internal_data
	local delay = CopLogicBase._upd_attention_obj_detection(data, nil, nil)
	local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, data.detected_attention_objects, SpoocLogicAttack._chk_reaction_to_attention_object)
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
				debug_pause_unit(data.unit, "[SpoocLogicTravel._upd_enemy_detection] exiting without discarding objective", data.unit, inspect(objective))
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

		SpoocLogicAttack._upd_aim(data, my_data)
	end

	CopLogicBase._report_detections(data.detected_attention_objects)

	if new_attention and data.char_tweak.chatter.entrance and not data.entrance and new_attention.criminal_record and new_attention.verified and AIAttentionObject.REACT_SCARED <= new_reaction and math.abs(data.m_pos.z - new_attention.m_pos.z) < 4000 then
		data.unit:sound():say(data.brain.entrance_chatter_cue or "entrance", true, nil)

		data.entrance = true
	end

	if data.cool then
		SpoocLogicTravel.upd_suspicion_decay(data)
	end

	return delay
end