TeamAILogicIdle.global_last_cop_int_t = 0
TeamAILogicIdle.global_last_advance_int_t = 0
local tmp_vec1 = Vector3()

function TeamAILogicIdle._on_player_slow_pos_rsrv_upd(data)
	local my_data = data.internal_data

	local objective = data.objective

	if objective then
		if not my_data.acting then
			if objective.type == "follow" then
				if TeamAILogicIdle._check_should_relocate(data, my_data, objective) and not data.unit:movement():chk_action_forbidden("walk") then
					objective.in_place = nil

					TeamAILogicBase._exit(data.unit, "travel")
					
					if my_data ~= data.internal_data then
						CopLogicBase.cancel_queued_tasks(my_data)
					
						return
					end
				end
			elseif objective.type == "revive" and not data.unit:movement()._should_stay then
				objective.in_place = nil

				TeamAILogicBase._exit(data.unit, "travel")
				
				if my_data ~= data.internal_data then
					CopLogicBase.cancel_queued_tasks(my_data)
				
					return
				end
			end
		end
	elseif not data.path_fail_t or data.t - data.path_fail_t > 1 then
		managers.groupai:state():on_criminal_jobless(data.unit)
		
		if my_data ~= data.internal_data then
			CopLogicBase.cancel_queued_tasks(my_data)
		
			return
		end
	end
end

function TeamAILogicIdle._check_should_relocate(data, my_data, objective)
	if data.cool or data.unit:movement()._should_stay or not objective or not objective.follow_unit then
		return
	end

	local follow_unit = objective.follow_unit
	local follow_pos = follow_unit:movement():m_pos()
	local max_allowed_dis = 700
	local z_diff = math.abs(data.m_pos.z - follow_pos.z)
	
	if z_diff > 250 then
		return true
	else
		max_allowed_dis = math.lerp(max_allowed_dis, 0, z_diff / 250)
		
		if mvector3.distance(data.m_pos, follow_pos) > max_allowed_dis then
			return true
		end
	end
end

function TeamAILogicIdle.on_new_objective(data, old_objective)
	local new_objective = data.objective

	TeamAILogicBase.on_new_objective(data, old_objective)

	local my_data = data.internal_data

	if not my_data.exiting then
		if new_objective and not data.unit:movement()._should_stay then
			if (new_objective.nav_seg or new_objective.follow_unit) and not new_objective.in_place then
				if data._ignore_first_travel_order then
					data._ignore_first_travel_order = nil
				else
					CopLogicBase._exit(data.unit, "travel")
				end
			else
				CopLogicBase._exit(data.unit, "idle")
			end
		else
			CopLogicBase._exit(data.unit, "idle")
		end
	else
		debug_pause("[TeamAILogicIdle.on_new_objective] Already exiting", data.name, data.unit, old_objective and inspect(old_objective), new_objective and inspect(new_objective))
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

function TeamAILogicIdle.is_available_for_assignment(data, new_objective)
	if data.internal_data.exiting then
		return
	elseif data.path_fail_t and data.t < data.path_fail_t + 1 then
		return
	elseif data.unit:movement()._should_stay and (not new_objective or not new_objective.type ~= "stop") then
		return
	elseif data.objective then
		if data.internal_data.performing_act_objective and not data.unit:anim_data().act_idle then
			return
		end

		if new_objective and CopLogicBase.is_obstructed(data, new_objective, 0.2) then
			return
		end

		local old_objective_type = data.objective.type

		if not new_objective then
			-- Nothing
		elseif old_objective_type == "revive" then
			return
		elseif old_objective_type == "follow" and data.objective.called then
			return
		end
	end

	return true
end

function TeamAILogicIdle._get_priority_attention(data, attention_objects, reaction_func)
	reaction_func = reaction_func or TeamAILogicBase._chk_reaction_to_attention_object
	local best_target, best_target_priority_slot, best_target_priority, best_target_reaction = nil
	
	local ranges = data.internal_data and data.internal_data.weapon_range
	
	if not ranges then
		ranges = {
			optimal = 2000,
			far = 5000,
			close = 1000
		}
	end

	for u_key, attention_data in pairs(attention_objects) do
		local att_unit = attention_data.unit
		local crim_record = attention_data.criminal_record

		if not attention_data.identified then
			-- Nothing
		elseif attention_data.pause_expire_t then
			if attention_data.pause_expire_t < data.t then
				attention_data.pause_expire_t = nil
			end
		elseif attention_data.stare_expire_t and attention_data.stare_expire_t < data.t then
			if attention_data.settings.pause then
				attention_data.stare_expire_t = nil
				attention_data.pause_expire_t = data.t + math.lerp(attention_data.settings.pause[1], attention_data.settings.pause[2], math.random())
			end
		else
			local distance = mvector3.distance(data.m_pos, attention_data.m_pos)
			local reaction = reaction_func(data, attention_data, not CopLogicAttack._can_move(data))
			local reaction_too_mild = nil

			if not reaction or best_target_reaction and reaction < best_target_reaction then
				reaction_too_mild = true
			elseif distance < 150 and reaction <= AIAttentionObject.REACT_SURPRISED then
				reaction_too_mild = true
			end

			if not reaction_too_mild then
				local aimed_at = TeamAILogicIdle.chk_am_i_aimed_at(data, attention_data, attention_data.aimed_at and 0.95 or 0.985)
				attention_data.aimed_at = aimed_at
				local dangerous_special = nil
			
				local alert_dt = attention_data.alert_t and data.t - attention_data.alert_t or 10000
				local dmg_dt = attention_data.dmg_t and data.t - attention_data.dmg_t or 10000
				local mark_dt = attention_data.mark_t and data.t - attention_data.mark_t or 10000
				local target_priority = distance
				local close_threshold = ranges.optimal

				if data.attention_obj and data.attention_obj.u_key == u_key then
					alert_dt = alert_dt * 0.8
					dmg_dt = dmg_dt * 0.8
					mark_dt = mark_dt * 0.8
					distance = distance * 0.8
					target_priority = target_priority * 0.8
				end

				local visible = attention_data.verified
				
				local target_priority_slot = 0

				if visible then
					local is_shielded = TeamAILogicIdle._ignore_shield and TeamAILogicIdle._ignore_shield(data.unit, attention_data) or nil
					
					if is_shielded then
						target_priority_slot = 10
					else
						local near = distance < close_threshold
						local has_alerted = alert_dt < 5
						local has_damaged = dmg_dt < 2
						local been_marked = mark_dt < 8
						local attention_unit = attention_data.unit
						
						if attention_unit:base().sentry_gun then
							if near and (has_alerted and has_damaged) then
								target_priority_slot = 7
							elseif near then
								target_priority_slot = 8
							else
								target_priority_slot = 9
							end
						elseif attention_unit:base().has_tag and attention_unit:base():has_tag("special") then
							if attention_unit:base():has_tag("sniper") and aimed_at then
								dangerous_special = true
								if has_damaged then
									target_priority_slot = 2
								elseif has_alerted then
									target_priority_slot = 4
								else
									target_priority_slot = 7
								end
							elseif attention_unit:base():has_tag("spooc") then
								if distance < 1500 then
									dangerous_special = true
									local trying_to_kick_criminal = attention_unit:brain()._logic_data and attention_unit:brain()._logic_data.internal_data and attention_unit:brain()._logic_data.internal_data.spooc_attack

									if trying_to_kick_criminal then
										target_priority_slot = 1

										if trying_to_kick_criminal.target_u_key == data.key then
											target_priority = target_priority * 0.1
										end
									else
										target_priority_slot = 2 --medics can't heal cloakers, so if the cloaker would be in range, hold him in high regard anyways
									end
								elseif near then
									target_priority_slot = 3
								else
									target_priority_slot = 6
								end
							elseif attention_unit:base():has_tag("medic") then
								if near and (has_alerted and has_damaged) then
									target_priority_slot = 2
								elseif near then
									target_priority_slot = 3
								else
									target_priority_slot = 6
								end
							elseif attention_unit:base():has_tag("taser") then
								if distance < 1500 then
									dangerous_special = true
									local trying_to_tase_criminal = att_unit:brain()._logic_data and att_unit:brain()._logic_data.internal_data and att_unit:brain()._logic_data.internal_data.tasing

									if trying_to_tase_criminal then
										target_priority_slot = 1 --try to stagger the taser

										if trying_to_tase_criminal.target_u_key == data.key then
											target_priority = target_priority * 0.1
										end
									else
										target_priority_slot = 3
									end
								elseif near then
									target_priority_slot = 4
								else
									target_priority_slot = 6
								end
							elseif attention_unit:base():has_tag("tank") then
								local dozer_type = attention_unit:base()._tweak_table
								
								if near then
									--dangerous_special = true
									
									if dozer_type == "tank_mini" then
										target_priority_slot = 4
									else
										target_priority_slot = 5
									end
								else
									target_priority_slot = 8
								end
							elseif near and (has_alerted and has_damaged) then
								target_priority_slot = 7
							elseif near then
								target_priority_slot = 8
							else
								target_priority_slot = 9
							end
						elseif near and (has_alerted and has_damaged) then
							target_priority_slot = 8
						elseif near then
							target_priority_slot = 9
						else
							target_priority_slot = 10
						end
					end
				else
					target_priority_slot = 11
				end
				
				attention_data.dangerous_special = dangerous_special

				if reaction < AIAttentionObject.REACT_COMBAT then
					target_priority = target_priority * 10
					target_priority_slot = 11 + target_priority_slot + math.max(0, AIAttentionObject.REACT_COMBAT - reaction)
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
						best_target_priority_slot = target_priority_slot
						best_target_priority = target_priority
						best_target_reaction = reaction
					end
				end
			end
		end
	end

	return best_target, best_target_priority_slot, best_target_reaction
end

function TeamAILogicIdle._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local max_reaction = nil

	if data.cool then
		max_reaction = AIAttentionObject.REACT_SURPRISED
	end

	local delay = CopLogicBase._upd_attention_obj_detection(data, nil, max_reaction)
	local new_attention, new_prio_slot, new_reaction = TeamAILogicIdle._get_priority_attention(data, data.detected_attention_objects, nil)

	TeamAILogicBase._set_attention_obj(data, new_attention, new_reaction)
	
	if new_attention and (new_attention.nearly_visible or new_attention.verified) and new_reaction and AIAttentionObject.REACT_COMBAT <= new_reaction and new_attention.dis < 2000 then
		data.last_engage_t = data.t
	end
	
	if my_data ~= data.internal_data then
		return
	end

	if new_reaction and AIAttentionObject.REACT_SCARED <= new_reaction then
		local objective = data.objective
		local wanted_state = nil
		local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, new_attention)

		if allow_trans then
			wanted_state = TeamAILogicBase._get_logic_state_from_reaction(data, new_reaction)
			local objective = data.objective

			if objective and objective.type == "revive" then
				local revive_unit = objective.follow_unit
				local timer = nil

				if revive_unit:base().is_local_player then
					timer = revive_unit:character_damage()._downed_timer
				elseif revive_unit:interaction().get_waypoint_time then
					timer = revive_unit:interaction():get_waypoint_time()
				end

				if timer and timer <= 10 then
					wanted_state = nil
				end
			end
		end

		if wanted_state and wanted_state ~= data.name then
			if obj_failed then
				data.objective_failed_clbk(data.unit, data.objective)
			end

			if my_data == data.internal_data then
				CopLogicBase._exit(data.unit, wanted_state)
			end

			return
		end
	end
	
	if not data.cool and not my_data.performing_act_objective and not my_data.acting then
		if not my_data._intimidate_t or my_data._intimidate_t + 2 < data.t and not my_data._turning_to_intimidate then
			local can_turn = not data.unit:movement():chk_action_forbidden("turn") and (not new_prio_slot or new_prio_slot > 7)
			local is_assault = managers.groupai:state():get_assault_mode()
			local civ = TeamAILogicIdle.find_civilian_to_intimidate(data.unit, can_turn and 180 or 60, is_assault and 800 or 1200)

			if civ then
				my_data._intimidate_t = data.t

				if can_turn and CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.unit:movement():m_pos(), civ:movement():m_pos()) then
					my_data._turning_to_intimidate = true
					my_data._primary_intimidation_target = civ
				else
					TeamAILogicIdle.intimidate_civilians(data, data.unit, true, false)
				end
			else
				TeamAILogicIdle.intimidate_others(data, my_data, can_turn)
			end
		end
	end
	
	if my_data ~= data.internal_data then
		log("YOU FELL FOR IT FOOL, THUNDER CROSS SPLIT ATTACK!!!")
	end
	
	CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicIdle._upd_enemy_detection, data, data.t + delay)
end

function TeamAILogicIdle._find_intimidateable_civilians(criminal, use_default_shout_shape, max_angle, max_dis)
	local head_pos = criminal:movement():m_head_pos()
	local look_vec = criminal:movement():m_rot():y()
	local close_dis = 400
	local intimidateable_civilians = {}
	local best_civ = nil
	local best_civ_wgt = false
	local best_civ_angle = nil
	local highest_wgt = 1

	for key, u_data in pairs(managers.enemy:all_civilians()) do
		if alive(u_data.unit) then
			local unit = u_data.unit
			
			if not tweak_data.character[unit:base()._tweak_table].is_escort and tweak_data.character[unit:base()._tweak_table].intimidateable and not unit:base().unintimidateable and not unit:anim_data().unintimidateable and not unit:brain():is_tied() and not unit:unit_data().disable_shout then
				local unit_is_not_drop = unit:anim_data().run or unit:anim_data().stand or unit:anim_data().halt or unit:anim_data().panic or unit:anim_data().react
				
				local does_not_need_intimidation = not unit_is_not_drop and unit:brain()._logic_data and unit:brain()._logic_data.internal_data and unit:brain()._logic_data.internal_data.submission_meter and unit:brain()._logic_data.internal_data.submission_meter > 20

				if not does_not_need_intimidation then
					local u_head_pos = unit:movement():m_head_pos() + math.UP * 30
					local vec = u_head_pos - head_pos
					local dis = mvector3.normalize(vec)
					local angle = vec:angle(look_vec)

					if use_default_shout_shape then
						max_angle = math.max(8, math.lerp(90, 30, dis / 1200))
						max_dis = 1200
					end

					if dis < close_dis or dis < max_dis and angle < max_angle then
						local slotmask = managers.slot:get_mask("AI_visibility")
						local ray = World:raycast("ray", head_pos, u_head_pos, "slot_mask", slotmask, "ray_type", "ai_vision")

						if not ray then
							local inv_wgt = dis * dis * (1 - vec:dot(look_vec))

							table.insert(intimidateable_civilians, {
								unit = unit,
								key = key,
								inv_wgt = inv_wgt
							})

							if not best_civ_wgt or inv_wgt < best_civ_wgt then
								best_civ_wgt = inv_wgt
								best_civ = unit
								best_civ_angle = angle
							end

							if highest_wgt < inv_wgt then
								highest_wgt = inv_wgt
							end
						end
					end
				end
			end
		end
	end

	return best_civ, highest_wgt, intimidateable_civilians
end

function TeamAILogicIdle.intimidate_civilians(data, criminal, play_sound, play_action, primary_target)
	if alive(primary_target) and primary_target:unit_data().disable_shout then
		return false
	end

	if primary_target and (not alive(primary_target) or not managers.enemy:all_civilians()[primary_target:key()]) then
		primary_target = nil
	end

	local best_civ, highest_wgt, intimidateable_civilians = TeamAILogicIdle._find_intimidateable_civilians(criminal, true)
	local plural = false

	if #intimidateable_civilians > 1 then
		plural = true
	elseif #intimidateable_civilians <= 0 then
		return false
	end

	local act_name, sound_name = nil
	local sound_suffix = plural and "plu" or "sin"

	if best_civ:anim_data().move then
		act_name = "gesture_stop"
		sound_name = "f02x_" .. sound_suffix
	else
		act_name = "arrest"
		
		if best_civ:anim_data().drop then
			if data.last_intimidate_t and data.t - data.last_intimidate_t < 3 then
				sound_name = "f03b_any"
			else
				sound_name = "f03a_" .. sound_suffix
			end
		elseif data.last_intimidate_t and data.t - data.last_intimidate_t < 3 then
			sound_name = "f02b_sin"
		else
			sound_name = "f02x_" .. sound_suffix
		end
	end

	if play_sound then
		criminal:sound():say(sound_name, true)
	end

	if play_action and not criminal:movement():chk_action_forbidden("action") then
		local new_action = {
			align_sync = true,
			body_part = 3,
			type = "act",
			variant = act_name
		}

		if criminal:brain():action_request(new_action) then
			data.internal_data.gesture_arrest = true
		end
	end

	local intimidated_primary_target = false

	for _, civ in ipairs(intimidateable_civilians) do
		local amount = civ.inv_wgt / highest_wgt

		if best_civ == civ.unit then
			amount = 1
		end

		if primary_target == civ.unit then
			intimidated_primary_target = true
			amount = 1
		end

		civ.unit:brain():on_intimidated(amount, criminal)
	end

	if not intimidated_primary_target and primary_target then
		primary_target:brain():on_intimidated(1, criminal)
	end
	
	data.last_intimidate_t = data.t

	if not managers.groupai:state():enemy_weapons_hot() then
		local alert = {
			"vo_intimidate",
			data.m_pos,
			800,
			data.SO_access,
			data.unit
		}

		managers.groupai:state():propagate_alert(alert)
	end

	if not primary_target and best_civ and best_civ:unit_data().disable_shout then
		return false
	end

	return primary_target or best_civ
end

function TeamAILogicIdle.intimidate_others(data, my_data, can_turn)
	local can_intimidate_escort = not my_data._advance_intimidate_t or data.t - my_data._advance_intimidate_t > 4
	
	if can_intimidate_escort then
		if data.t - TeamAILogicIdle.global_last_advance_int_t < 2 then
			can_intimidate_escort = nil
		end
	end
	
	local can_intimidate_cop = data.t - TeamAILogicIdle.global_last_cop_int_t > 1.4
	
	if not can_intimidate_cop and not can_intimidate_escort then
		return
	end

	local best_unit, best_weight

	local groupaistate = managers.groupai:state()
	local enemies = groupaistate._police
	local is_escort, is_intimidated_cop
	local m_pos = data.m_pos
	local my_head_pos = data.unit:movement():m_head_pos()
	local my_look_vec = data.unit:movement():m_rot():y()	
	local mvec3_dis_sq = mvector3.distance_sq

	for u_key, attention_data in pairs(data.detected_attention_objects) do	
		if attention_data.is_person and (attention_data.verified or attention_data.nearly_visible) then
			local unit = attention_data.unit
			
			if unit and unit.brain then
				local brain = unit:brain()
				
				if brain then
					if enemies[u_key] then
						if can_intimidate_cop and brain._logic_data.name == "intimidated" then
							local internal_data = brain._logic_data.internal_data
								
							if not internal_data.tied then
								local dis = mvec3_dis_sq(m_pos, attention_data.m_pos)
								
								if dis < 640000 then
									local vec = attention_data.m_head_pos - my_head_pos
									local weight = dis * (1 - vec:dot(my_look_vec))
									
									if not best_unit or weight < best_weight then
										best_unit = unit
										best_weight = weight
										is_escort = nil
									end
								end
							end
						end
					elseif can_intimidate_escort then
						if brain._logic_data.name == "escort" then
							local internal_data = brain._logic_data.internal_data
							
							if internal_data.advance_path and not internal_data.commanded_to_move then
								local dis = mvec3_dis_sq(m_pos, attention_data.m_pos)
								
								if dis < 640000 then
									local vec = attention_data.m_head_pos - my_head_pos
									local weight = dis * (1 - vec:dot(my_look_vec))
									
									if not best_unit or weight < best_weight then
										best_unit = unit
										best_weight = weight
										is_escort = true
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	if best_unit then
		if can_turn then
			CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.unit:movement():m_pos(), best_unit:movement():m_pos())
		end
	
		if is_escort then			
			data.unit:sound():say("f40_any", true)
			
			if not data.unit:movement():chk_action_forbidden("action") then
				local redir_name = "cmd_gogo"

				if data.unit:movement():play_redirect(redir_name) then
					managers.network:session():send_to_peers_synched("play_distance_interact_redirect", data.unit, redir_name)
				end
			end
			
			my_data._advance_intimidate_t = data.t
			TeamAILogicIdle.global_last_advance_int_t = data.t
		else
			local redir_name, sound
		
			if best_unit:anim_data().hands_back then
				redir_name = "cmd_down"
				sound = "l03x_sin"
			elseif best_unit:anim_data().surrender then
				redir_name = "cmd_down"
				sound = "l02x_sin"
			else
				redir_name = "cmd_stop"
				sound = "l01x_sin"
			end
			
			data.unit:sound():say(sound, true)
			
			if not data.unit:movement():chk_action_forbidden("action") then
				if data.unit:movement():play_redirect(redir_name) then
					managers.network:session():send_to_peers_synched("play_distance_interact_redirect", data.unit, redir_name)
				end
			end
			
			TeamAILogicIdle.global_last_cop_int_t = data.t
		end

		my_data._intimidate_t = data.t
		
		best_unit:brain():on_intimidated(1, data.unit)
	end
end
