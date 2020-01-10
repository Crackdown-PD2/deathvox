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
	
	local optimal_threshold = data.internal_data.weapon_range.optimal
	local near_threshold = data.internal_data.weapon_range.close
	local too_close_threshold = 1000
	
	if data.tactics and data.tactics.ranged_fire or data.tactics and data.tactics.elite_ranged_fire then
		optimal_threshold = data.internal_data.weapon_range.optimal * 1.5
		near_threshold = data.internal_data.weapon_range.optimal
		too_close_threshold = data.internal_data.weapon_range.close
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
				local old_enemy = false

				if data.attention_obj and data.attention_obj.u_key == u_key and data.t - attention_data.acquire_t < 4 then
					old_enemy = true
				end

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

				local assault_reaction = reaction == AIAttentionObject.REACT_SPECIAL_ATTACK
				local visible = attention_data.verified
				local optimal = distance < optimal_threshold
				local near = distance < near_threshold
				local too_near = distance < too_close_threshold and math.abs(attention_data.m_pos.z - data.m_pos.z) < 250
				local free_status = status == nil
				local has_alerted = alert_dt < 3.5
				local has_damaged = dmg_dt < 5
				local reviving = nil
				local focus_enemy = attention_data
				
				if not data.unit:in_slot(16) and focus_enemy and (focus_enemy.is_local_player or focus_enemy.is_husk_player) then
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

				if attention_data.is_local_player then
					local iparams = att_unit:movement():current_state()._interact_params

					if iparams and managers.criminals:character_name_by_unit(iparams.object) ~= nil then
						reviving = true
					end
				else
					reviving = att_unit:anim_data() and att_unit:anim_data().revive
				end

				local target_priority = distance
				local target_priority_slot = 0
				
				if visible then
					local murderorspooctargeting = data.tactics and data.tactics.murder or data.tactics and data.tactics.spooctargeting
					local justmurder = data.tactics and data.tactics.murder
					local justharass = data.tactics and data.tactics.harass
					
					if data.tactics and data.tactics.spooctargeting and distance < 1500 or too_near then
						target_priority_slot = 1
					elseif near and not murderorspooctargeting then
						target_priority_slot = 2
					elseif optimal and not murderorspooctargeting then
						target_priority_slot = 4
					elseif not justmurder then
						target_priority_slot = 6
					end

					if has_damaged and not murderorspooctargeting then
						target_priority_slot = target_priority_slot - 2
					elseif has_alerted and not murderorspooctargeting then
						target_priority_slot = target_priority_slot - 1
					elseif data.tactics and data.tactics.harass and pantsdownchk then
						target_priority_slot = 1
						--log("oh god oh fuck here comes the locusts")
					elseif assault_reaction then
						target_priority_slot = 1
					end
					
					if old_enemy then
						target_priority_slot = target_priority_slot - 3
					end
					
					target_priority_slot = math.clamp(target_priority_slot, 1, 10)
				elseif free_status and not justmurder or pantsdownchk and not justharass then
					target_priority_slot = 7
				end
				
				if old_enemy and data.tactics and data.tactics.murder and reaction >= AIAttentionObject.REACT_COMBAT then
					target_priority_slot = 1
					--log("*heavy breathing*")
				end

				if reaction < AIAttentionObject.REACT_COMBAT then
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

function CopLogicIdle._update_haste(data, my_data)
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)

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
	
	local haste = nil
	local enemyseeninlast4secs = data.attention_obj and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4
	local enemy_seen_range_bonus = enemyseeninlast4secs and 500 or 0
	local enemy_has_height_difference = data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis >= 1200 and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4 and math.abs(data.m_pos.z - data.attention_obj.m_pos.z) > 250
	local should_crouch = nil
	local pose = nil
	local end_pose = nil
	
	if my_data.cover_path or my_data.charge_path or my_data.chase_path then	
		if is_mook and not data.is_converted and not data.unit:in_slot(16) then
			if data.unit:movement():cool() then
				haste = "walk"
			elseif data.attention_obj and data.attention_obj.dis > 10000 then
				haste = "run"
			elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis > 1200 + enemy_seen_range_bonus and not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() and data.unit:anim_data().move and is_mook then
				haste = "run"
				my_data.has_reset_walk_cycle = nil
			elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis <= 1200 + enemy_seen_range_bonus - (math.abs(data.m_pos.z - data.attention_obj.m_pos.z) < 250 and 400 or 0) and is_mook and data.tactics and not data.tactics.hitnrun and data.unit:anim_data().run then
				haste = "walk"
				my_data.has_reset_walk_cycle = nil
			 else
				if data.unit:anim_data().move then
					my_data.has_reset_walk_cycle = nil
				end
				haste = "run"
			 end
				 
			local crouch_roll = math.random(0.01, 1)
			local stand_chance = nil
			
			if data.attention_obj and data.attention_obj.dis > 10000 then
				stand_chance = 1
				pose = "stand"
				end_pose = "stand"
			elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis > 2000 then
				stand_chance = 0.75
			elseif enemy_has_height_difference and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
				stand_chance = 0.25
			elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and (data.attention_obj.verified and data.attention_obj.dis <= 1500 or data.attention_obj.dis <= 1000) and CopLogicTravel._chk_close_to_criminal(data, my_data) and data.tactics and data.tactics.flank and haste == "walk" then
				stand_chance = 0.25
			elseif my_data.moving_to_cover and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
				stand_chance = 0.5
			else
				stand_chance = 1
				pose = "stand"
				end_pose = "stand"
			end
			
			--randomize enemy crouching to make enemies feel less easy to aim at, the fact they're always crouching all over the place always bugged me, plus, they shouldn't need to crouch so often when you're at long distances from them
			
			if not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() then
				if stand_chance ~= 1 and crouch_roll > stand_chance and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
					end_pose = "crouch"
					pose = "crouch"
					should_crouch = true
				end
			end
			
			if not pose then
				pose = not data.char_tweak.crouch_move and "stand" or data.char_tweak.allowed_poses and not data.char_tweak.allowed_poses.stand and "crouch" or should_crouch and "crouch" or "stand"
				end_pose = pose
			end

			if not data.unit:anim_data()[pose] then
				CopLogicAttack["_chk_request_action_" .. pose](data)
			end	
		elseif data.unit:base():has_tag("tank") then
			local run_dist = 900
			
			if data.attention_obj and math.abs(data.m_pos.z - data.attention_obj.m_pos.z) < 250 and data.attention_obj.verified then
				run_dist = 1200
			end
			
			if data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.verified_dis <= run_dist and data.unit:anim_data().run and math.abs(data.m_pos.z - data.attention_obj.m_pos.z) < 250 then
				haste = "walk"
				my_data.has_reset_walk_cycle = nil
			elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis > run_dist and data.unit:anim_data().move then
				haste = "run"
				my_data.has_reset_walk_cycle = nil
			end
		end
	end	
	 
	if data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and haste then
		local path = my_data.chase_path or my_data.charge_path or my_data.cover_path
		if not my_data.has_reset_walk_cycle then
			local new_action = {
				body_part = 2,
				type = "idle"
			}

			data.unit:brain():action_request(new_action)
			my_data.has_reset_walk_cycle = true
		else
			local new_action_data = {
				type = "walk",
				body_part = 2,
				nav_path = path,
				variant = haste,
				pose = pose,
				end_pose = end_pose
			}
			my_data.cover_path = nil
			my_data.advancing = data.unit:brain():action_request(new_action_data)

			if my_data.advancing then
				my_data.moving_to_cover = my_data.best_cover
				my_data.at_cover_shoot_pos = nil
				my_data.in_cover = nil

				data.brain:rem_pos_rsrv("path")
			end
		end
	end
end 

function CopLogicIdle._upd_stance_and_pose(data, my_data, objective)
	if data.unit:movement():chk_action_forbidden("walk") then
		return
	end
	
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)

	local obj_has_stance, obj_has_pose, agg_pose = nil
	
	if not data.is_converted and not data.unit:in_slot(16) then
		if data.is_suppressed then
			if not data.unit:anim_data().crouch and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
				CopLogicAttack._chk_request_action_crouch(data)
				agg_pose = true
			end
		elseif data.attention_obj and data.attention_obj.verified and data.attention_obj.aimed_at and data.attention_obj.reaction >= AIAttentionObject.REACT_COMBAT and data.attention_obj.is_person then
			if not data.unit:anim_data().crouch and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
				CopLogicAttack._chk_request_action_crouch(data)
				agg_pose = true
			elseif data.unit:anim_data().crouch and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.stand) then
				CopLogicAttack._chk_request_action_stand(data)
				agg_pose = true
			end
		end
	end

	if objective and not agg_pose then
		if objective.stance and (not data.char_tweak.allowed_stances or data.char_tweak.allowed_stances[objective.stance]) then
			obj_has_stance = true
			local upper_body_action = data.unit:movement()._active_actions[3]

			if not upper_body_action or upper_body_action:type() ~= "shoot" then
				data.unit:movement():set_stance(objective.stance)
			end
		end

		if objective.pose and not agg_pose and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses[objective.pose]) then
			obj_has_pose = true

			if objective.pose == "crouch" then
				CopLogicAttack._chk_request_action_crouch(data)
			elseif objective.pose == "stand" then
				CopLogicAttack._chk_request_action_stand(data)
			end
		end
	end

	if not obj_has_stance and data.char_tweak.allowed_stances and not data.char_tweak.allowed_stances[data.unit:anim_data().stance] and not agg_pose then
		for stance_name, state in pairs(data.char_tweak.allowed_stances) do
			if state then
				data.unit:movement():set_stance(stance_name)

				break
			end
		end
	end
	
	if not obj_has_pose and not agg_pose then
		if data.char_tweak.allowed_poses and not data.char_tweak.allowed_poses[data.unit:anim_data().pose] then
			for pose_name, state in pairs(data.char_tweak.allowed_poses) do
				if state then
					if pose_name == "crouch" then
						CopLogicAttack._chk_request_action_crouch(data)

						break
					end

					if pose_name == "stand" then
						CopLogicAttack._chk_request_action_stand(data)
					end

					break
				end
			end
		end
	end
end

function CopLogicIdle.queued_update(data)
	local my_data = data.internal_data
	local delay = data.logic._upd_enemy_detection(data)

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
	CopLogicIdle._upd_stance_and_pose(data, my_data, objective)
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
	
	if data.is_converted then
		delay = 0
	else
		delay = data.logic._upd_enemy_detection(data)
	end
	
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
		elseif data.unit:base():has_tag("taser") and data.attention_obj and data.attention_obj.verified and data.attention_obj.dis and data.attention_obj.dis <= 1500 then
			CopLogicBase._exit(data.unit, "attack")
		elseif data.unit:base():has_tag("spooc") and focus_enemy and focus_enemy.dis and focus_enemy.is_person and focus_enemy.criminal_record and not focus_enemy.criminal_record.status and not my_data.spooc_attack and AIAttentionObject.REACT_SHOOT <= focus_enemy.reaction and not data.unit:movement():chk_action_forbidden("walk") and not SpoocLogicAttack._is_last_standing_criminal(focus_enemy) and not focus_enemy.unit:movement():zipline_unit() and focus_enemy.unit:movement():is_SPOOC_attack_allowed() and focus_enemy.dis <= 1500 and focus_enemy.verified then
			CopLogicBase._exit(data.unit, "attack")
		elseif CopLogicIdle._chk_objective_needs_travel(data, new_objective) then
			CopLogicBase._exit(data.unit, "travel")
		elseif objective_type == "guard" then
			CopLogicBase._exit(data.unit, "guard")
		elseif objective_type == "security" then
			CopLogicBase._exit(data.unit, "idle")
		elseif objective_type == "sniper" then
			CopLogicBase._exit(data.unit, "sniper")
		elseif objective_type == "phalanx" then
			CopLogicBase._exit(data.unit, "phalanx")
		elseif objective_type == "surrender" then
			CopLogicBase._exit(data.unit, "intimidated", new_objective.params)
		elseif new_objective.action or not data.attention_obj or AIAttentionObject.REACT_AIM > data.attention_obj.reaction then
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