function SpoocLogicAttack.queued_update(data)
	local t = TimerManager:game():time()
	data.t = t
	local unit = data.unit
	local my_data = data.internal_data

	if my_data.spooc_attack then
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

	SpoocLogicAttack._upd_spooc_attack(data, my_data)

	if my_data.spooc_attack then
		SpoocLogicAttack.queue_update(data, my_data)

		return
	end

	if AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction then
		my_data.want_to_take_cover = CopLogicAttack._chk_wants_to_take_cover(data, my_data)

		CopLogicAttack._update_cover(data)
		CopLogicAttack._upd_combat_movement(data)
		local groupai = managers.groupai:state()
		if not data.char_tweak.cannot_throw_grenades and not data.is_converted and data.unit:base().has_tag and data.unit:base():has_tag("law") and groupai:is_smoke_grenade_active() then 
			CopLogicBase.do_smart_grenade(data, my_data, data.attention_obj)
		end
	end

	SpoocLogicAttack.queue_update(data, my_data)
	CopLogicBase._report_detections(data.detected_attention_objects)
end

function SpoocLogicAttack._upd_spooc_attack(data, my_data)
	if my_data.spooc_attack then
		return
	end

	if not data.is_converted and data.spooc_attack_timeout_t and data.spooc_attack_timeout_t >= data.t then
		return
	end

	local focus_enemy = data.attention_obj

	if focus_enemy and focus_enemy.nav_tracker and focus_enemy.is_person and AIAttentionObject.REACT_SHOOT <= focus_enemy.reaction and not data.unit:movement():chk_action_forbidden("walk") then
		if focus_enemy.criminal_record then
			if focus_enemy.criminal_record.status then
				return
			elseif SpoocLogicAttack._is_last_standing_criminal(focus_enemy) then
				return
			end
		end

		if focus_enemy.unit:movement().zipline_unit and focus_enemy.unit:movement():zipline_unit() then
			return
		end

		if focus_enemy.unit:movement().is_SPOOC_attack_allowed and not focus_enemy.unit:movement():is_SPOOC_attack_allowed() then
			return
		end

		if focus_enemy.unit:movement().chk_action_forbidden and focus_enemy.unit:movement():chk_action_forbidden("hurt") then
			return true
		end
		
		if focus_enemy.verified and focus_enemy.verified_dis <= 2500 then
			managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "cloakercontact" )
		end

		if focus_enemy.verified and focus_enemy.verified_dis <= 2500 and ActionSpooc.chk_can_start_spooc_sprint(data.unit, focus_enemy.unit) and not data.unit:raycast("ray", data.unit:movement():m_head_pos(), focus_enemy.m_head_pos, "slot_mask", managers.slot:get_mask("bullet_impact_targets_no_criminals"), "ignore_unit", focus_enemy.unit, "report") then
			if my_data.attention_unit ~= focus_enemy.u_key then
				CopLogicBase._set_attention(data, focus_enemy)

				my_data.attention_unit = focus_enemy.u_key
			end

			local action = SpoocLogicAttack._chk_request_action_spooc_attack(data, my_data)

			if action then
			
				if data.tactics then
					if data.tactics.smoke_grenade or data.tactics.flash_grenade then
						local flash = not data.tactics.smoke_grenade or data.tactics.flash_grenade and math.random() < 0.5
						
						CopLogicBase.do_grenade(data, focus_enemy.m_pos + math.UP * 5, flash)
					end
				end
			
				my_data.spooc_attack = {
					start_t = data.t,
					target_u_data = focus_enemy,
					action = action
				}

				return true
			end
		end

		if ActionSpooc.chk_can_start_flying_strike(data.unit, focus_enemy.unit) then
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

function SpoocLogicAttack._chk_request_action_spooc_attack(data, my_data, flying_strike)
	data.unit:movement():set_stance_by_code(2)

	local new_action = {
		body_part = 3,
		type = "idle"
	}

	data.brain:action_request(new_action)

	local new_action_data = {
		body_part = 1,
		type = "spooc",
		flying_strike = flying_strike
	}

	if flying_strike then
		new_action_data.blocks = {
			light_hurt = -1,
			heavy_hurt = -1,
			idle = -1,
			turn = -1,
			fire_hurt = -1,
			walk = -1,
			act = -1,
			hurt = -1,
			expl_hurt = -1,
			taser_tased = -1
		}
	end

	local action = data.brain:action_request(new_action_data)

	return action
end

function SpoocLogicAttack.action_complete_clbk(data, action)
	local action_type = action:type()
	local my_data = data.internal_data

	if action_type == "walk" then
		my_data.advancing = nil

		if my_data.surprised then
			my_data.surprised = false
		elseif my_data.moving_to_cover then
			if action:expired() then
				my_data.in_cover = my_data.moving_to_cover

				CopLogicAttack._set_nearest_cover(my_data, my_data.in_cover)

				my_data.cover_enter_t = data.t
				my_data.cover_sideways_chk = nil
			end

			my_data.moving_to_cover = nil
		elseif my_data.walking_to_cover_shoot_pos then
			my_data.walking_to_cover_shoot_pos = nil
		end
	elseif action_type == "shoot" then
		my_data.shooting = nil
	elseif action_type == "turn" then
		my_data.turning = nil
	elseif action_type == "spooc" then
		data.spooc_attack_timeout_t = TimerManager:game():time() + math.lerp(data.char_tweak.spooc_attack_timeout[1], data.char_tweak.spooc_attack_timeout[2], math.random())

		if action:complete() and data.char_tweak.spooc_attack_use_smoke_chance > 0 and math.random() <= data.char_tweak.spooc_attack_use_smoke_chance and managers.groupai:state():is_smoke_grenade_active() then
			managers.groupai:state():detonate_smoke_grenade(data.m_pos + math.UP * 10, data.unit:movement():m_head_pos(), math.lerp(15, 30, math.random()), false)
		end

		my_data.spooc_attack = nil
	elseif action_type == "dodge" then
		local timeout = action:timeout()

		if timeout then
			data.dodge_timeout_t = TimerManager:game():time() + math.lerp(timeout[1], timeout[2], math.random())
		end

		CopLogicAttack._cancel_cover_pathing(data, my_data)

		if action:expired() then
			SpoocLogicAttack._upd_aim(data, my_data)
		end
	end
end

function SpoocLogicAttack.queue_update(data, my_data)
	my_data.update_queued = true

	CopLogicBase.queue_task(my_data, my_data.update_queue_id, SpoocLogicAttack.queued_update, data, data.t, true)
end
