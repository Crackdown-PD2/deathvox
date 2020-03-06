function CopLogicIdle._get_priority_attention(data, attention_objects, reaction_func)
	local best_target, best_target_priority_slot, best_target_reaction = nil
	reaction_func = reaction_func or CopLogicIdle._chk_reaction_to_attention_object
	if data.is_converted then
		best_target, best_target_priority_slot, best_target_reaction = TeamAILogicIdle._get_priority_attention(data, attention_objects, reaction_func)
		return best_target, best_target_priority_slot, best_target_reaction
	end
	
	local forced_attention_data = managers.groupai:state():force_attention_data(data.unit)

	if forced_attention_data then
		if data.attention_obj and data.attention_obj.unit == forced_attention_data.unit then
			return data.attention_obj, 1, AIAttentionObject.REACT_SHOOT
		end

		local forced_attention_object = managers.groupai:state():get_AI_attention_object_by_unit(forced_attention_data.unit)

		if forced_attention_object then
			for u_key, attention_info in pairs(forced_attention_object) do
				if forced_attention_data.ignore_vis_blockers then
					local vis_ray = World:raycast("ray", data.unit:movement():m_head_pos(), attention_info.handler:get_detection_m_pos(), "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision")

					if not vis_ray or vis_ray.unit:key() == u_key or not vis_ray.unit:visible() then
						best_target = CopLogicBase._create_detected_attention_object_data(data.t, data.unit, u_key, attention_info, attention_info.handler:get_attention(data.SO_access), true)
						best_target.verified = true
					end
				else
					best_target = CopLogicBase._create_detected_attention_object_data(data.t, data.unit, u_key, attention_info, attention_info.handler:get_attention(data.SO_access), true)
				end
			end
		else
			Application:error("[CopLogicIdle._get_priority_attention] No attention object available for unit", inspect(forced_attention_data))
		end

		if best_target then
			return best_target, 1, AIAttentionObject.REACT_SHOOT
		end
	end

	for u_key, attention_data in pairs(attention_objects) do
		local att_unit = attention_data.unit
		local crim_record = attention_data.criminal_record

		if not attention_data.identified then
			-- Nothing
		elseif attention_data.pause_expire_t then
			if attention_data.pause_expire_t < data.t then
				if not attention_data.settings.attract_chance or math.random() < attention_data.settings.attract_chance then
					attention_data.pause_expire_t = nil
				else
					debug_pause_unit(data.unit, "[ CopLogicIdle._get_priority_attention] skipping attraction")

					attention_data.pause_expire_t = data.t + math.lerp(attention_data.settings.pause[1], attention_data.settings.pause[2], math.random())
				end
			end
		elseif attention_data.stare_expire_t and attention_data.stare_expire_t < data.t then
			if attention_data.settings.pause then
				attention_data.stare_expire_t = nil
				attention_data.pause_expire_t = data.t + math.lerp(attention_data.settings.pause[1], attention_data.settings.pause[2], math.random())
			end
		else
			local distance = attention_data.dis
			local reaction = reaction_func(data, attention_data, not CopLogicAttack._can_move(data))

			if data.cool and AIAttentionObject.REACT_SCARED <= reaction then
				data.unit:movement():set_cool(false, managers.groupai:state().analyse_giveaway(data.unit:base()._tweak_table, att_unit))
			end

			local reaction_too_mild = nil

			if not reaction or best_target_reaction and reaction < best_target_reaction then
				reaction_too_mild = true
			elseif distance < 150 and reaction == AIAttentionObject.REACT_IDLE then
				reaction_too_mild = true
			end

			if not reaction_too_mild then
				local aimed_at = CopLogicIdle.chk_am_i_aimed_at(data, attention_data, attention_data.aimed_at and 0.95 or 0.985)
				attention_data.aimed_at = aimed_at
				local alert_dt = attention_data.alert_t and data.t - attention_data.alert_t or 10000
				local dmg_dt = attention_data.dmg_t and data.t - attention_data.dmg_t or 10000
				local status = crim_record and crim_record.status
				local nr_enemies = crim_record and crim_record.engaged_force

				local weight_mul = attention_data.settings.weight_mul

				if attention_data.is_local_player then
					if not att_unit:movement():current_state()._moving and att_unit:movement():current_state():ducking() then
						weight_mul = (weight_mul or 1) * managers.player:upgrade_value("player", "stand_still_crouch_camouflage_bonus", 1)
					end

					if managers.player:has_activate_temporary_upgrade("temporary", "chico_injector") and managers.player:upgrade_value("player", "chico_preferred_target", false) then
						weight_mul = (weight_mul or 1) * 1000
					end

					if _G.IS_VR and tweak_data.vr.long_range_damage_reduction_distance[1] < distance then
						local mul = math.clamp(distance / tweak_data.vr.long_range_damage_reduction_distance[2] / 2, 0, 1) + 1
						weight_mul = (weight_mul or 1) * mul
					end
				elseif att_unit:base() and att_unit:base().upgrade_value then
					if att_unit:movement() and not att_unit:movement()._move_data and att_unit:movement()._pose_code and att_unit:movement()._pose_code == 2 then
						weight_mul = (weight_mul or 1) * (att_unit:base():upgrade_value("player", "stand_still_crouch_camouflage_bonus") or 1)
					end

					if att_unit:base().has_activate_temporary_upgrade and att_unit:base():has_activate_temporary_upgrade("temporary", "chico_injector") and att_unit:base():upgrade_value("player", "chico_preferred_target") then
						weight_mul = (weight_mul or 1) * 1000
					end

					if att_unit:movement().is_vr and att_unit:movement():is_vr() and tweak_data.vr.long_range_damage_reduction_distance[1] < distance then
						local mul = math.clamp(distance / tweak_data.vr.long_range_damage_reduction_distance[2] / 2, 0, 1) + 1
						weight_mul = (weight_mul or 1) * mul
					end
				end

				if weight_mul and weight_mul ~= 1 then
					weight_mul = 1 / weight_mul
					alert_dt = alert_dt and alert_dt * weight_mul
					dmg_dt = dmg_dt and dmg_dt * weight_mul
					distance = distance * weight_mul
				end
				
				local optimal_threshold = data.internal_data.weapon_range.optimal
				local near_threshold = data.internal_data.weapon_range.close
				local too_close_threshold = 1000
				
				if data.tactics and data.tactics.ranged_fire or data.tactics and data.tactics.elite_ranged_fire then
					optimal_threshold = data.internal_data.weapon_range.optimal * 1.5
					near_threshold = data.internal_data.weapon_range.optimal
					too_close_threshold = data.internal_data.weapon_range.close
				end
				
				local assault_reaction = reaction == AIAttentionObject.REACT_SPECIAL_ATTACK
				local visible = attention_data.verified
				local near = distance < near_threshold
				local too_near = distance < too_close_threshold and math.abs(attention_data.m_pos.z - data.m_pos.z) < 250
				local free_status = status == nil
				local has_alerted = alert_dt < 3.5
				local has_damaged = dmg_dt < 5
				local reviving = nil
				local focus_enemy = attention_data
				local human_chk = attention_data.is_husk_player or attention_data.is_local_player
				local human_current_target_chk = data.attention_obj and data.attention_obj.is_husk_player or data.attention_obj and data.attention_obj.is_local_player
				local old_enemy = nil
				local old_enemy_murder = nil
				
				if not data.unit:in_slot(16) and focus_enemy and focus_enemy.is_local_player or not data.unit:in_slot(16) and focus_enemy and focus_enemy.is_husk_player then
					local anim_data = att_unit:anim_data()
					if focus_enemy.is_local_player then
						local e_movement_state = att_unit:movement():current_state()

						if e_movement_state:_is_reloading() or e_movement_state:_interacting() or e_movement_state:is_equipping() then
							pantsdownchk = true
							--log("MURDER TIME, WOO")
						end
					else
						local e_anim_data = att_unit:anim_data()

						if not (e_anim_data.move or e_anim_data.idle) or e_anim_data.reload then
							pantsdownchk = true
							--log("MURDER TIME, WOO")
						end
					end
				end
				
				if data.tactics and data.tactics.murder then
					if attention_data.acquire_t and human_chk and attention_data.verified and data.attention_obj and data.attention_obj.verified and AIAttentionObject.REACT_AIM <= data.attention_obj.reaction and AIAttentionObject.REACT_AIM <= reaction and data.attention_obj.u_key == u_key and human_att_obj_chk then
						old_enemy_murder = true
					end
				end
				
				if attention_data.acquire_t and attention_data.verified and data.attention_obj and data.attention_obj.verified and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and AIAttentionObject.REACT_COMBAT <= reaction and data.attention_obj.u_key == u_key then
					old_enemy = true
				end

				local target_priority = distance
				local target_priority_slot = 0
				
				if visible then
					local justmurder = data.tactics and data.tactics.murder
					local justharass = data.tactics and data.tactics.harass
					
					if distance < 250 then
						target_priority_slot = 1
					elseif too_near then
						target_priority_slot = 2
					elseif near then
						target_priority_slot = 4
					elseif optimal_threshold then
						target_priority_slot = 5
					else
						target_priority_slot = 6
					end
					
					if justmurder and human_chk and not human_current_target_chk then
						target_priority_slot = 1
					end

					if has_damaged then
						target_priority_slot = target_priority_slot - 2
					end
					
					if old_enemy and not justmurder then
						target_priority_slot = target_priority_slot - 1
					end
					
					if not free_status and not justmurder or pantsdownchk and not justharass then
						target_priority_slot = target_priority_slot + 4
					end
					
					target_priority_slot = math.clamp(target_priority_slot, 1, 10)
				else
					target_priority_slot = 10
					if not free_status and not justmurder or pantsdownchk and not justharass then
						target_priority_slot = target_priority_slot + 10
					end
				end
				
				if old_enemy_murder and data.tactics and data.tactics.murder then
					target_priority_slot = 1
				end
				
				if data.tactics and data.tactics.harass and pantsdownchk then
					target_priority_slot = 1
				end
					
				if assault_reaction and distance < 1500 then
					target_priority_slot = 1
				end

				if AIAttentionObject.REACT_COMBAT > reaction or data.tactics and data.tactics.murder and not old_enemy_murder and not human_chk then
					target_priority_slot = 20 + target_priority_slot + math.max(0, AIAttentionObject.REACT_COMBAT - reaction)
				end

				if target_priority_slot ~= 0 then
					local best = false

					if not best_target then
						best = true
					elseif target_priority_slot < best_target_priority_slot then
						best = true
					elseif target_priority_slot == best_target_priority_slot and target_priority < best_target_priority then
						best = true
					end

					if best then
						best_target = attention_data
						best_target_reaction = reaction
						best_target_priority_slot = target_priority_slot
						best_target_priority = target_priority
					end
				end
			end
		end
	end

	return best_target, best_target_priority_slot, best_target_reaction
end

function CopLogicIdle.on_intimidated(data, amount, aggressor_unit)
	local surrender = false
	local my_data = data.internal_data
	data.t = TimerManager:game():time()

	if not aggressor_unit:movement():team().foes[data.unit:movement():team().id] then
		return
	end

	if managers.groupai:state():has_room_for_police_hostage() then
		local i_am_special = managers.groupai:state():is_enemy_special(data.unit)
		local required_skill = i_am_special and "intimidate_specials" or "intimidate_enemies"
		local aggressor_can_intimidate = nil
		local aggressor_intimidation_mul = 1

		if aggressor_unit:base().is_local_player then
			aggressor_can_intimidate = managers.player:has_category_upgrade("player", required_skill)
			aggressor_intimidation_mul = aggressor_intimidation_mul * managers.player:upgrade_value("player", "empowered_intimidation_mul", 1) * managers.player:upgrade_value("player", "intimidation_multiplier", 1)
		elseif aggressor_unit:base().is_husk_player then
			aggressor_can_intimidate = aggressor_unit:base():upgrade_value("player", required_skill)
			aggressor_intimidation_mul = aggressor_intimidation_mul * (aggressor_unit:base():upgrade_value("player", "empowered_intimidation_mul") or 1) * (aggressor_unit:base():upgrade_value("player", "intimidation_multiplier") or 1)
		else
			aggressor_can_intimidate = true
			aggressor_intimidation_mul = aggressor_intimidation_mul
		end

		if aggressor_can_intimidate then
			local hold_chance = CopLogicBase._evaluate_reason_to_surrender(data, my_data, aggressor_unit)

			if hold_chance then
				hold_chance = hold_chance ^ aggressor_intimidation_mul

				if hold_chance >= 1 then
					-- Nothing
				else
					local rand_nr = math.random()

					print("and the winner is: hold_chance", hold_chance, "rand_nr", rand_nr, "rand_nr > hold_chance", hold_chance < rand_nr)

					if hold_chance < rand_nr then
						surrender = true
					end
				end
			end
		end

		if surrender then
			CopLogicIdle._surrender(data, amount, aggressor_unit)
		else
			data.unit:brain():on_surrender_chance()
		end
	end

	CopLogicBase.identify_attention_obj_instant(data, aggressor_unit:key())
	managers.groupai:state():criminal_spotted(aggressor_unit)

	return surrender
end

function CopLogicIdle._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local delay = CopLogicBase._upd_attention_obj_detection(data, nil, nil)
	local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, data.detected_attention_objects)

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)

	if new_reaction and AIAttentionObject.REACT_SUSPICIOUS < new_reaction then
		local objective = data.objective
		local wanted_state = nil
		local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, new_attention)

		if allow_trans then
			wanted_state = CopLogicBase._get_logic_state_from_reaction(data)
		end

		if wanted_state and wanted_state ~= data.name then
			if obj_failed then
				data.objective_failed_clbk(data.unit, data.objective)
			end

			if my_data == data.internal_data then
				CopLogicBase._exit(data.unit, wanted_state)
			end
		end
	end

	if my_data == data.internal_data then
		CopLogicBase._chk_call_the_police(data)

		if my_data ~= data.internal_data then
			return delay
		end
	end

	return delay
end

function CopLogicIdle.queued_update(data)
	local my_data = data.internal_data
	local delay = CopLogicIdle._upd_enemy_detection(data)

	if data.internal_data ~= my_data then
		CopLogicBase._report_detections(data.detected_attention_objects)

		return
	end

	local objective = data.objective

	if my_data.has_old_action then
		CopLogicIdle._upd_stop_old_action(data, my_data, objective)
		CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicIdle.queued_update, data, data.t + delay)

		return
	end

	if data.is_converted and (not data.objective or data.objective.type == "free") and (not data.path_fail_t or data.t - data.path_fail_t > 3) then
		managers.groupai:state():on_criminal_jobless(data.unit)

		if my_data ~= data.internal_data then
			return
		end
	end

	if CopLogicIdle._chk_exit_non_walkable_area(data) then
		return
	end

	if CopLogicIdle._chk_relocate(data) then
		return
	end

	CopLogicIdle._perform_objective_action(data, my_data, objective)
	data.logic._upd_stance_and_pose(data, my_data, objective)
	CopLogicIdle._upd_pathing(data, my_data)
	CopLogicIdle._upd_scan(data, my_data)
	CopLogicIdle._update_haste(data, my_data)
	
	if data.cool then
		CopLogicIdle.upd_suspicion_decay(data)
	end

	if data.internal_data ~= my_data then
		CopLogicBase._report_detections(data.detected_attention_objects)

		return
	end
	
	delay = data.logic._upd_enemy_detection(data)
	
	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicIdle.queued_update, data, data.t + delay)
end

function CopLogicIdle.on_new_objective(data, old_objective)
	local new_objective = data.objective

	CopLogicBase.on_new_objective(data, old_objective)

	local my_data = data.internal_data
	local focus_enemy = data.attention_obj

	if new_objective then
		local objective_type = new_objective.type
		
		if objective_type == "free" and my_data.exiting then
			--nothing
		elseif objective_type == "surrender" then
			CopLogicBase._exit(data.unit, "intimidated", new_objective.params)
		elseif CopLogicIdle._chk_objective_needs_travel(data, new_objective) then
			if CopLogicBase.should_enter_attack(data) then
				--log("entered attack")
				CopLogicBase._exit(data.unit, "attack")
			else
				CopLogicBase._exit(data.unit, "travel")
			end
		elseif objective_type == "guard" then
			CopLogicBase._exit(data.unit, "guard")
		elseif objective_type == "security" then
			CopLogicBase._exit(data.unit, "idle")
		elseif objective_type == "sniper" then
			CopLogicBase._exit(data.unit, "sniper")
		elseif objective_type == "phalanx" then
			CopLogicBase._exit(data.unit, "phalanx")
		elseif new_objective.action or not data.attention_obj or not CopLogicBase.should_enter_attack(data) then
			CopLogicBase._exit(data.unit, "idle")
		else
			CopLogicBase._exit(data.unit, "attack")
		end
	elseif not my_data.exiting then
		CopLogicBase._exit(data.unit, "idle")
	end

	if new_objective and new_objective.stance then
		if new_objective.stance == "ntl" then
			data.unit:movement():set_cool(true)
		else
			data.unit:movement():set_cool(false)
		end
	end

	if old_objective and old_objective.fail_clbk then
		old_objective.fail_clbk(data.unit)
	end
end

function CopLogicIdle._chk_relocate(data)
	
	if not data.team.id == tweak_data.levels:get_default_team_ID("player") and not data.is_converted and not data.unit:in_slot(16) and not data.unit:in_slot(managers.slot:get_mask("criminals")) then
		if CopLogicBase.should_enter_attack(data) then
			data.logic._exit(data.unit, "attack")
			
			return true
		end
	end
	
	if data.objective and data.objective.type == "follow" then
		if data.is_converted then
			if TeamAILogicIdle._check_should_relocate(data, data.internal_data, data.objective) then
				data.objective.in_place = nil

				data.logic._exit(data.unit, "travel")

				return true
			end

			return
		end

		if data.is_tied and data.objective.lose_track_dis and data.objective.lose_track_dis * data.objective.lose_track_dis < mvector3.distance_sq(data.m_pos, data.objective.follow_unit:movement():m_pos()) then
			data.brain:set_objective(nil)

			return true
		end

		local relocate = nil
		local follow_unit = data.objective.follow_unit
		local advance_pos = follow_unit:brain() and follow_unit:brain():is_advancing()
		local follow_unit_pos = advance_pos or follow_unit:movement():m_pos()

		if data.objective.relocated_to and mvector3.equal(data.objective.relocated_to, follow_unit_pos) then
			return
		end

		if data.objective.distance and data.objective.distance < mvector3.distance(data.m_pos, follow_unit_pos) then
			relocate = true
		end

		if not relocate then
			local ray_params = {
				tracker_from = data.unit:movement():nav_tracker(),
				pos_to = follow_unit_pos
			}
			local ray_res = managers.navigation:raycast(ray_params)

			if ray_res then
				relocate = true
			end
		end

		if relocate then
			data.objective.in_place = nil
			data.objective.nav_seg = follow_unit:movement():nav_tracker():nav_segment()
			data.objective.relocated_to = mvector3.copy(follow_unit_pos)

			data.logic._exit(data.unit, "travel")

			return true
		end
	elseif data.objective and data.objective.type == "defend_area" then
		local area = data.objective.area

		if area and not next(area.criminal.units) then
			local found_areas = {
				[area] = true
			}
			local areas_to_search = {
				area
			}
			local target_area = nil

			while next(areas_to_search) do
				local current_area = table.remove(areas_to_search)

				if next(current_area.criminal.units) then
					target_area = current_area

					break
				end

				for _, n_area in pairs(current_area.neighbours) do
					if not found_areas[n_area] then
						found_areas[n_area] = true

						table.insert(areas_to_search, n_area)
					end
				end
			end

			if target_area then
				data.objective.in_place = nil
				data.objective.nav_seg = next(target_area.nav_segs)
				data.objective.path_data = {
					{
						data.objective.nav_seg
					}
				}

				data.logic._exit(data.unit, "travel")

				return true
			end
		end
	end
end

function CopLogicIdle.on_alert(data, alert_data)
	local alert_type = alert_data[1]
	local alert_unit = alert_data[5]

	if CopLogicBase._chk_alert_obstructed(data.unit:movement():m_head_pos(), alert_data) then
		return
	end

	local was_cool = data.cool

	if CopLogicBase.is_alert_aggressive(alert_type) then
		data.unit:movement():set_cool(false, managers.groupai:state().analyse_giveaway(data.unit:base()._tweak_table, alert_data[5], alert_data))
	end

	if alert_unit and alive(alert_unit) and alert_unit:in_slot(data.enemy_slotmask) then
		local att_obj_data, is_new = CopLogicBase.identify_attention_obj_instant(data, alert_unit:key())

		if not att_obj_data then
			return
		end

		if alert_type == "bullet" or alert_type == "aggression" or alert_type == "explosion" then
			att_obj_data.alert_t = TimerManager:game():time()
		end

		local action_data = nil

		--if is_new and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.stand) and AIAttentionObject.REACT_SURPRISED <= att_obj_data.reaction and data.unit:anim_data().idle and not data.unit:movement():chk_action_forbidden("walk") then
		--	action_data = {
		--		variant = "surprised",
		--		body_part = 1,
		--		type = "act"
		--	}

		--	data.unit:brain():action_request(action_data)
		--end

		if not action_data and alert_type == "bullet" and data.logic.should_duck_on_alert(data, alert_data) then
			action_data = CopLogicAttack._chk_request_action_crouch(data)
		end

		if att_obj_data.criminal_record then
			managers.groupai:state():criminal_spotted(alert_unit)

			if alert_type == "bullet" or alert_type == "aggression" or alert_type == "explosion" then
				managers.groupai:state():report_aggression(alert_unit)
			end
		end
	elseif was_cool and (alert_type == "footstep" or alert_type == "bullet" or alert_type == "aggression" or alert_type == "explosion" or alert_type == "vo_cbt" or alert_type == "vo_intimidate" or alert_type == "vo_distress") then
		local attention_obj = alert_unit and alert_unit:brain() and alert_unit:brain()._logic_data.attention_obj

		if attention_obj then
			slot6, slot7 = CopLogicBase.identify_attention_obj_instant(data, attention_obj.u_key)
		end
	end
end

function CopLogicIdle.action_complete_clbk(data, action)
	local action_type = action:type()
	local my_data = data.internal_data
	
	if action_type == "walk" then
		my_data.advancing = nil
		my_data.flank_cover = nil
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
		if my_data.surprised then
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
	elseif action_type == "reload" then
		--Removed the requirement for being important here.
		if action:expired() then
			CopLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
		end
	elseif action_type == "turn" then
		data.internal_data.turning = nil

		if data.internal_data.fwd_offset then
			local return_spin = data.internal_data.rubberband_rotation:to_polar_with_reference(data.unit:movement():m_rot():y(), math.UP).spin

			if math.abs(return_spin) < 15 then
				data.internal_data.fwd_offset = nil
			end
		end
	elseif action_type == "act" then

		if my_data.action_started == action then
			if my_data.scan and not my_data.exiting and (not my_data.queued_tasks or not my_data.queued_tasks[my_data.wall_stare_task_key]) and not my_data.stare_path_pos then
				CopLogicBase.queue_task(my_data, my_data.wall_stare_task_key, CopLogicIdle._chk_stare_into_wall_1, data, data.t)
			end

			if action:expired() then
				if not my_data.action_timeout_clbk_id then
					data.objective_complete_clbk(data.unit, data.objective)
				end
			elseif not my_data.action_expired then
				data.objective_failed_clbk(data.unit, data.objective)
			end
		end
		
		--CopLogicAttack._cancel_cover_pathing(data, my_data)
		--CopLogicAttack._cancel_charge(data, my_data)
		
		--Fixed panic never waking up cops.
		if action:expired() then
			CopLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			CopLogicAttack._upd_combat_movement(data)
		end
		
	elseif action_type == "hurt" then
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
		
		--Removed the requirement for being important here.
		if action:expired() and not CopLogicBase.chk_start_action_dodge(data, "hit") then
			CopLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
		end
	elseif action_type == "dodge" then
		local timeout = action:timeout()

		if timeout then
			data.dodge_timeout_t = TimerManager:game():time() + math.lerp(timeout[1], timeout[2], math.random())
		end

		CopLogicAttack._cancel_cover_pathing(data, my_data)

		if action:expired() then
			CopLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			--CopLogicAttack._upd_combat_movement(data)
		end
	end
end