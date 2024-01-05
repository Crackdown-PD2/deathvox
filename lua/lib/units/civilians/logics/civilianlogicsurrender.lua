if deathvox:IsTotalCrackdownEnabled() then 


	local tmp_vec1 = Vector3()

	function CivilianLogicSurrender.enter(data, new_logic_name, enter_params)
		CopLogicBase.enter(data, new_logic_name, enter_params)
		data.unit:brain():cancel_all_pathing_searches()

		local force_lie_down = enter_params and enter_params.force_lie_down or false
		local old_internal_data = data.internal_data
		local my_data = {
			unit = data.unit
		}
		data.internal_data = my_data

		if data.is_tied then
			managers.groupai:state():on_hostage_state(true, data.key, nil, true)

			my_data.is_hostage = true

			if data.unit:anim_data().drop then
				data.unit:interaction():set_tweak_data("hostage_move", true)
				data.unit:interaction():set_active(true, true)
			end
		end

		if data.unit:anim_data().drop and not data.unit:anim_data().tied then
			data.unit:interaction():set_active(true, true)

			my_data.interaction_active = true
		end

		my_data.state_enter_t = TimerManager:game():time()

		if not data.unit:anim_data().move and managers.groupai:state():rescue_state() and managers.groupai:state():is_nav_seg_safe(data.unit:movement():nav_tracker():nav_segment()) then
			CivilianLogicFlee._add_delayed_rescue_SO(data, my_data)
		end

		local scare_max = data.char_tweak.scare_max
		my_data.scare_max = math.lerp(scare_max[1], scare_max[2], math.random())
		local submission_max = data.char_tweak.submission_max
		my_data.submission_max = math.lerp(submission_max[1], submission_max[2], math.random())
		my_data.scare_meter = 0
		my_data.submission_meter = 0
		my_data.last_upd_t = data.t
		my_data.nr_random_screams = 0
		data.run_away_next_chk_t = nil

		data.unit:brain():set_update_enabled_state(true) --only change was this
		data.unit:movement():set_allow_fire(false)
		if not data.is_tied then
			managers.groupai:state():add_to_surrendered(data.unit, callback(CivilianLogicSurrender, CivilianLogicSurrender, "queued_update", data))

			my_data.surrender_clbk_registered = true
		end


		data.unit:movement():set_stance(data.is_tied and "cbt" or "hos")
		data.unit:movement():set_cool(false)

		if my_data ~= data.internal_data then
			return
		end

		local attention_settings = nil
		attention_settings = {
			"civ_enemy_cbt",
			"civ_civ_cbt",
			"civ_murderer_cbt"
		}

		data.unit:brain():set_attention_settings(attention_settings)

		if not data.been_outlined and data.char_tweak.outline_on_discover then
			my_data.outline_detection_task_key = "CivilianLogicIdle._upd_outline_detection" .. tostring(data.key)

			CopLogicBase.queue_task(my_data, my_data.outline_detection_task_key, CivilianLogicIdle._upd_outline_detection, data, data.t + 2)
		end

		if data.objective and not force_lie_down then
			if data.objective.aggressor_unit then
				if not data.objective.initial_act then
					CivilianLogicSurrender.on_intimidated(data, data.objective.amount, data.objective.aggressor_unit, true)
				else
					if data.objective.initial_act == "halt" then
						managers.groupai:state():register_fleeing_civilian(data.key, data.unit)
					end

					CivilianLogicSurrender._do_initial_act(data, data.objective.amount, data.objective.aggressor_unit, data.objective.initial_act)
				end
			end
		elseif force_lie_down then
			local anim_data = data.unit:anim_data()

			if not anim_data.drop then
				local action_data = nil

				if not anim_data.panic then
					action_data = {
						clamp_to_graph = true,
						variant = "panic",
						body_part = 1,
						type = "act"
					}

					data.unit:brain():action_request(action_data)
				end

				action_data = {
					clamp_to_graph = true,
					variant = "drop",
					body_part = 1,
					type = "act"
				}
				local action_res = data.unit:brain():action_request(action_data)
			end
		end
	end

	function CivilianLogicSurrender.on_tied(data, aggressor_unit, not_tied, can_flee)
		local my_data = data.internal_data

		if data.is_tied then
			return
		end

		data.cannot_flee = not can_flee

		if not_tied then
			if data.has_outline then
				data.unit:contour():remove("highlight")

				data.has_outline = nil
			end

			data.unit:inventory():destroy_all_items()

			if my_data.interaction_active then
				data.unit:interaction():set_active(false, true)

				my_data.interaction_active = nil
			end

			data.unit:character_damage():drop_pickup()
			data.unit:character_damage():set_pickup(nil)
		else
			local action_data = {
				variant = "tied",
				body_part = 1,
				type = "act",
				blocks = {
					heavy_hurt = -1,
					hurt_sick = -1,
					hurt = -1,
					light_hurt = -1,
					walk = -1
				}
			}
			local action_res = data.unit:brain():action_request(action_data)

			if action_res then
				managers.groupai:state():on_hostage_state(true, data.key, nil, nil)

				my_data.is_hostage = true
				data.is_tied = true
				my_data.aggressor_id = aggressor_unit:base():id()

				data.unit:interaction():set_tweak_data("hostage_move")
				data.unit:interaction():set_active(true, true)

				if data.has_outline then
					data.unit:contour():remove("highlight")

					data.has_outline = nil
				end

				data.unit:inventory():destroy_all_items()
				managers.groupai:state():on_civilian_tied(data.unit:key())
				data.unit:base():set_slot(data.unit, 22)

				managers.network:session():send_to_peers_synched("sync_unit_surrendered", data.unit, true)
				managers.network:session():send_to_peers_synched("sync_unit_event_id_16", data.unit, "brain", HuskCopBrain._NET_EVENTS.surrender_tied)

				if data.unit:movement() then
					data.unit:movement():remove_giveaway()
				end

				if my_data.interaction_active then
					data.unit:interaction():set_active(false, true)

					my_data.interaction_active = nil
				end

				data.unit:character_damage():drop_pickup()
				data.unit:character_damage():set_pickup(nil)

				if data.unit:unit_data().mission_element then
					data.unit:unit_data().mission_element:event("tied", data.unit)
				end

				CivilianLogicFlee._chk_add_delayed_rescue_SO(data, my_data)

				if aggressor_unit == managers.player:player_unit() then
					managers.statistics:tied({
						name = data.unit:base()._tweak_table
					})
				elseif aggressor_unit:base() and aggressor_unit:base().is_husk_player then
					aggressor_unit:network():send_to_unit({
						"statistics_tied",
						data.unit:base()._tweak_table
					})
				end

				managers.groupai:state():on_criminal_suspicion_progress(nil, data.unit, nil)
			end
		end
	end
end

function CivilianLogicSurrender.on_alert(data, alert_data)
	local alert_type = alert_data[1]

	if alert_type ~= "aggression" and alert_type ~= "bullet" and alert_type ~= "explosion" then
		return
	end

	local anim_data = data.unit:anim_data()

	if CopLogicBase.is_alert_aggressive(alert_data[1]) then
		local aggressor = alert_data[5]

		if aggressor and aggressor:base() then
			local is_intimidation = nil

			if aggressor:base().is_local_player then
				if managers.player:has_category_upgrade("player", "civ_calming_alerts") then
					is_intimidation = true
				end
			elseif aggressor:base().is_husk_player and aggressor:base():upgrade_value("player", "civ_calming_alerts") then
				is_intimidation = true
			end

			if is_intimidation and not data.is_tied then
				data.unit:brain():on_intimidated(1, aggressor)

				return
			end
		end
	end

	data.t = TimerManager:game():time()

	if not CopLogicBase.is_alert_dangerous(alert_data[1]) then
		return
	end

	local my_data = data.internal_data
	local scare_modifier = data.char_tweak.scare_shot

	if anim_data.halt or anim_data.react or anim_data.stand then
		scare_modifier = scare_modifier * 4
	end

	my_data.scare_meter = math.min(my_data.scare_max, my_data.scare_meter + scare_modifier)

	if my_data.scare_meter == my_data.scare_max and data.t - my_data.state_enter_t > 5 then
		data.unit:sound():say("a01x_any", true)

		if not my_data.inside_intimidate_aura and not data.is_tied then
			data.unit:brain():set_objective({
				is_default = true,
				type = "free",
				alert_data = clone(alert_data)
			})
		end
	elseif not data.unit:sound():speaking(TimerManager:game():time()) then
		local rand = math.random()
		local alert_dis_sq = mvector3.distance_sq(data.m_pos, alert_data[2])
		local max_scare_dis_sq = 4000000

		if alert_dis_sq < max_scare_dis_sq then
			rand = math.lerp(rand, rand * 2, math.min(alert_dis_sq) / 4000000)
			local scare_mul = (max_scare_dis_sq - alert_dis_sq) / max_scare_dis_sq
			local max_nr_random_screams = 8
			scare_mul = scare_mul * math.lerp(1, 0.3, my_data.nr_random_screams / max_nr_random_screams)
			local chance_voice_1 = 0.3 * scare_mul
			local chance_voice_2 = 0.3 * scare_mul

			if data.char_tweak.female then
				chance_voice_1 = chance_voice_1 * 1.2
				chance_voice_2 = chance_voice_2 * 1.2
			end

			if rand < chance_voice_1 then
				data.unit:sound():say("a01x_any", true)

				my_data.nr_random_screams = math.min(my_data.nr_random_screams + 1, max_nr_random_screams)
			elseif rand < chance_voice_1 + chance_voice_2 then
				data.unit:sound():say("a02x_any", true)

				my_data.nr_random_screams = math.min(my_data.nr_random_screams + 1, max_nr_random_screams)
			end
		end
	end
end

local tmp_vec1 = Vector3()

function CivilianLogicSurrender.queued_update(rubbish, data)
	local my_data = data.internal_data

	CivilianLogicSurrender._update_enemy_detection(data, my_data)

	if my_data.submission_meter <= 0 and not data.is_tied and (not data.unit:anim_data().react_enter or not not data.unit:anim_data().idle) then
		if data.unit:anim_data().drop then
			local new_action = {
				variant = "stand",
				body_part = 1,
				type = "act"
			}

			data.unit:brain():action_request(new_action)
		end

		my_data.surrender_clbk_registered = false

		data.unit:brain():set_objective({
			is_default = true,
			type = "free"
		})

		return
	else --pretty sure this function can cause a crash in vanilla due to a civ getting registered into the _upd_hostage_task even though they've left the logic for travel
		if CopLogicIdle._chk_relocate(data) then
			return
		end
	
		CivilianLogicFlee._chk_add_delayed_rescue_SO(data, my_data)
		managers.groupai:state():add_to_surrendered(data.unit, callback(CivilianLogicSurrender, CivilianLogicSurrender, "queued_update", data))
	end	
end

function CivilianLogicSurrender._update_enemy_detection(data, my_data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	local t = TimerManager:game():time()
	local delta_t = t - my_data.last_upd_t
	local my_pos = data.unit:movement():m_head_pos()
	local enemies = managers.groupai:state():all_criminals()
	local visible, closest_dis, closest_enemy = nil
	my_data.inside_intimidate_aura = nil
	local my_tracker = data.unit:movement():nav_tracker()
	local chk_vis_func = my_tracker.check_visibility
	local mvec3_dir = mvector3.direction
	local mvec3_dis_sq = mvector3.distance_sq
	local mvec3_cpy = mvector3.copy
	
	if not my_data.criminal_pos_list then
		my_data.criminal_pos_list = {}
	end
	
	for e_key, u_data in pairs(enemies) do
		if u_data.is_deployable then
			local dis = mvector3.distance(my_pos, u_data.m_det_pos)

			if dis < 1000 then
				my_data.inside_intimidate_aura = true
			end
		elseif chk_vis_func(my_tracker, u_data.tracker) then
			local enemy_unit = u_data.unit
			local enemy_pos = u_data.m_det_pos
			
			if not my_data.criminal_pos_list[e_key] then
				my_data.criminal_pos_list[e_key] = {
					seen = false,
					verified_pos = nil
				}
			end
			
			local crim_pos_entry = my_data.criminal_pos_list[e_key]
			
			if not crim_pos_entry.seen or crim_pos_entry.verified_pos and mvec3_dis_sq(crim_pos_entry.verified_pos, enemy_pos) > 10000 then
				local vis_ray = World:raycast("ray", my_pos, enemy_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision", "report")
				
				crim_pos_entry.seen = not vis_ray
				crim_pos_entry.verified_pos = mvec3_cpy(enemy_pos)
			end
			
			if crim_pos_entry.seen then
				local my_vec = tmp_vec1
				local dis = mvector3.direction(my_vec, enemy_pos, my_pos)
				local inside_aura = nil

				if u_data.unit:base().is_local_player then
					if managers.player:has_category_upgrade("player", "intimidate_aura") and dis < managers.player:upgrade_value("player", "intimidate_aura", 0) then
						inside_aura = true
					end
				elseif u_data.unit:base().is_husk_player and u_data.unit:base():upgrade_value("player", "intimidate_aura") and dis < u_data.unit:base():upgrade_value("player", "intimidate_aura") then
					inside_aura = true
				end

				if (inside_aura or dis < 700) and (not closest_dis or dis < closest_dis) then
					closest_dis = dis
					closest_enemy = enemy_unit
				end

				if inside_aura then
					my_data.inside_intimidate_aura = true
				elseif dis < 700 then
					local look_vec
				
					if enemy_unit:base().is_local_player then
						look_vec = enemy_unit:movement():detect_look_dir()
					else
						if enemy_unit:inventory() and enemy_unit:inventory():equipped_unit() then
							if enemy_unit:movement()._stance.values[3] >= 0.6 then
								local weapon_fire_obj = enemy_unit:inventory():equipped_unit():get_object(Idstring("fire"))

								if alive(weapon_fire_obj) then
									look_vec = weapon_fire_obj:rotation():y()
								end
							end
						end

						if not look_vec then
							look_vec = enemy_unit:movement():detect_look_dir()
						end
					end
					
					if look_vec then
						mvector3.normalize(look_vec)
					end

					local focus = my_vec:dot(look_vec)
					
					if focus > 0.65 then
						visible = true
					end
				end
			end
		end
	end

	local attention = data.unit:movement():attention()
	local attention_unit = attention and attention.unit or nil

	if not attention_unit then
		if closest_enemy and closest_dis < 700 and data.unit:anim_data().ik_type then
			CopLogicBase._set_attention_on_unit(data, closest_enemy)
		end
	elseif mvector3.distance(my_pos, attention_unit:movement():m_head_pos()) > 900 or not data.unit:anim_data().ik_type then
		CopLogicBase._reset_attention(data)
	end

	if managers.navigation:get_nav_seg_metadata(my_tracker:nav_segment()).force_civ_submission then
		my_data.submission_meter = my_data.submission_max
	elseif my_data.inside_intimidate_aura then
		my_data.submission_meter = my_data.submission_max
	elseif visible then
		my_data.submission_meter = math.min(my_data.submission_max, my_data.submission_meter + delta_t)
	elseif not data.unit:anim_data().drop and data.char_tweak.faster_reactions then
		my_data.submission_meter = 0
	else
		my_data.submission_meter = math.max(0, my_data.submission_meter - delta_t)
	end

	if managers.groupai:state():rescue_state() and not visible then
		if not my_data.rescue_active then
			CivilianLogicFlee._add_delayed_rescue_SO(data, my_data)
		end
	elseif my_data.rescue_active then
		CivilianLogicFlee._unregister_rescue_SO(data, my_data)
	end

	my_data.scare_meter = math.max(0, my_data.scare_meter - delta_t)
	my_data.last_upd_t = t
end