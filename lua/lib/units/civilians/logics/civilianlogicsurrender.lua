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
		managers.groupai:state():add_to_surrendered(data.unit, callback(CivilianLogicSurrender, CivilianLogicSurrender, "queued_update", data))

		my_data.surrender_clbk_registered = true

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
				else
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
