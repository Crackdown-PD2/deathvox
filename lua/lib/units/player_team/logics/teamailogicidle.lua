local mvec3_dot = mvector3.dot
local mvec3_dist_sq = mvector3.distance_sq
local mvec3_dist = mvector3.distance
local mvec3_norm = mvector3.normalize
local math_abs = math.abs
local math_max = math.max
local math_min = math.min
local math_lerp = math.lerp
local math_random = math.random
local t_cont = table.contains
local t_ins = table.insert
local pairs_g = pairs
local ipairs_g = ipairs
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_vec3 = Vector3()


function TeamAILogicIdle.enter(data, new_logic_name, enter_params)
	TeamAILogicBase.enter(data, new_logic_name, enter_params)
	data.brain:cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit,
		detection = data.char_tweak.detection.idle
	}

	if old_internal_data then
		my_data.turning = old_internal_data.turning

		if old_internal_data.firing then
			data.unit:movement():set_allow_fire(false)
		end

		if old_internal_data.shooting and not data.unit:anim_data().reload then
			data.brain:action_request({
				body_part = 3,
				type = "idle"
			})
		end

		if old_internal_data.best_cover then
			my_data.best_cover = old_internal_data.best_cover

			managers.navigation:reserve_cover(my_data.best_cover[1], data.pos_rsrv_id)
		end

		if old_internal_data.nearest_cover then
			my_data.nearest_cover = old_internal_data.nearest_cover

			managers.navigation:reserve_cover(my_data.nearest_cover[1], data.pos_rsrv_id)
		end
	end

	data.internal_data = my_data
	local key_str = tostring(data.key)
	my_data.detection_task_key = "TeamAILogicIdle._upd_enemy_detection" .. key_str

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicIdle._upd_enemy_detection, data, data.t)

	if my_data.nearest_cover or my_data.best_cover then
		my_data.cover_update_task_key = "TeamAILogicIdle._update_cover" .. key_str

		CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t + 1)
	end

	my_data.stare_path_search_id = "stare" .. key_str
	my_data.relocate_chk_t = 0

	CopLogicBase._reset_attention(data)
	CopLogicIdle._chk_has_old_action(data, my_data)

	local objective = data.objective

	if not objective then
		my_data.scan = true
		my_data.wall_stare_task_key = "TeamAILogicIdle._chk_stare_into_wall" .. tostring(data.key)

		CopLogicBase.queue_task(my_data, my_data.wall_stare_task_key, CopLogicIdle._chk_stare_into_wall_1, data, data.t)
	else
		if data.cool then
			my_data.rubberband_rotation = data.unit:movement():m_rot():y()
		end

		if objective.type == "revive" then
			if objective.action_start_clbk then
				objective.action_start_clbk(data.unit)
			end

			local success = nil
			local revive_unit = objective.follow_unit
			local revive_char_dmg_ext = revive_unit:character_damage()

			if revive_unit:interaction() then
				if revive_unit:interaction():active() and data.unit:brain():action_request(objective.action) then
					revive_unit:interaction():interact_start(data.unit)

					success = true
				end
			elseif revive_char_dmg_ext:arrested() then
				if data.unit:brain():action_request(objective.action) then
					revive_char_dmg_ext:pause_arrested_timer()

					success = true
				end
			elseif revive_char_dmg_ext:need_revive() and data.unit:brain():action_request(objective.action) then
				revive_char_dmg_ext:pause_downed_timer()

				success = true
			end

			if success then
				my_data.performing_act_objective = objective
				my_data.reviving = revive_unit
				my_data.acting = true
				my_data.revive_complete_clbk_id = "TeamAILogicIdle_revive" .. tostring(data.key)
				local revive_t = TimerManager:game():time() + (objective.action_duration or 0)

				CopLogicBase.add_delayed_clbk(my_data, my_data.revive_complete_clbk_id, callback(TeamAILogicIdle, TeamAILogicIdle, "clbk_revive_complete", data), revive_t)

				if not revive_char_dmg_ext:arrested() then
					local suffix = "a"

					if revive_char_dmg_ext.get_revives then
						local amount_revives = revive_char_dmg_ext:get_revives()

						if amount_revives == 1 then
							suffix = "c"
						elseif amount_revives == 2 then
							suffix = "b"
						else
							local first_down_nr_chk = revive_char_dmg_ext:get_revives_max() - 1

							if amount_revives < first_down_nr_chk then
								suffix = "b"
							end
						end
					end

					data.unit:sound():say("s09" .. suffix, true)
				end
			else
				data.unit:brain():set_objective()

				return
			end
		else
			if objective.action_duration then
				my_data.action_timeout_clbk_id = "TeamAILogicIdle_action_timeout" .. key_str
				local action_timeout_t = data.t + objective.action_duration

				CopLogicBase.add_delayed_clbk(my_data, my_data.action_timeout_clbk_id, callback(CopLogicIdle, CopLogicIdle, "clbk_action_timeout", data), action_timeout_t)
			end

			if objective.type == "act" then
				if data.unit:brain():action_request(objective.action) then
					my_data.acting = true
				end

				my_data.performing_act_objective = objective

				if objective.action_start_clbk then
					objective.action_start_clbk(data.unit)
				end
			end
		end

		if objective.scan then
			my_data.scan = true

			if not my_data.acting then
				my_data.wall_stare_task_key = "TeamAILogicIdle._chk_stare_into_wall" .. tostring(data.key)

				CopLogicBase.queue_task(my_data, my_data.wall_stare_task_key, CopLogicIdle._chk_stare_into_wall_1, data, data.t)
			end
		end
	end
end

function TeamAILogicIdle.update(data)
	data.t = TimerManager:game():time()

	local my_data = data.internal_data
	local objective = data.objective

	if my_data.has_old_action then
		CopLogicIdle._upd_stop_old_action(data, my_data, objective)

		return
	end

	if not objective or objective.type == "free" then
		if not data.path_fail_t or data.t - data.path_fail_t > 6 then
			managers.groupai:state():on_criminal_jobless(data.unit)

			if my_data ~= data.internal_data then
				return
			end
		end
	end

	if not my_data.acting then
		if objective and not data.cool then
			if objective.type == "follow" then
				if not data.unit:movement():chk_action_forbidden("walk") and TeamAILogicIdle._check_should_relocate(data, my_data, objective) then
					objective.in_place = nil

					TeamAILogicBase._exit(data.unit, "travel")
				end
			elseif objective.type == "revive" then
				objective.in_place = nil

				TeamAILogicBase._exit(data.unit, "travel")
			end
		end

		if my_data ~= data.internal_data or CopLogicIdle._chk_exit_non_walkable_area(data) then
			return
		end
	end

	--CopLogicIdle._perform_objective_action(data, my_data, objective)
	CopLogicIdle._upd_stance_and_pose(data, my_data, objective)
	CopLogicIdle._upd_pathing(data, my_data)
	CopLogicIdle._upd_scan(data, my_data)
end

function TeamAILogicIdle._check_should_relocate(data, my_data, objective)
	if data.cool and managers.groupai:state():whisper_mode() then
		return
	end

	local follow_unit = objective.follow_unit
	local movement_ext = data.unit:movement()
	local m_field_pos = movement_ext:nav_tracker():field_position()
	local follow_unit_mov_ext = follow_unit:movement()
	local follow_unit_field_pos = follow_unit_mov_ext:nav_tracker():field_position()
	local max_allowed_dis_xy = 700 * 700
	local max_allowed_dis_z = 200

	local too_far = nil

	if math_abs(m_field_pos.z - follow_unit_field_pos.z) > max_allowed_dis_z then --this is more or less going to check for different floors since field pos doesnt have that much height before it gets clamped
		too_far = true
		--log("no")
	else	
		local dis = mvec3_dist_sq(m_field_pos, follow_unit_field_pos)

		if max_allowed_dis_xy < dis then
			--log("yes")
			too_far = true
		end
	end

	if too_far then
		return true
	end
	
	local my_nav_seg_id = movement_ext:nav_tracker():nav_segment()
	local follow_unit_nav_seg_id = follow_unit_mov_ext:nav_tracker():nav_segment()
	
	if my_nav_seg_id == follow_unit_nav_seg_id then
		--log("they're in my area")
		return
	end
	
	if not data.attention_obj or data.attention_obj.reaction >= AIAttentionObject.REACT_COMBAT and not my_data.moving_to_cover and not my_data.in_cover then
		local slot_mask = managers.slot:get_mask("world_geometry", "vehicles", "enemy_shield_check")
		local raycast = data.unit:raycast("ray", movement_ext:m_head_pos(), follow_unit_mov_ext:m_head_pos(), "slot_mask", slot_mask, "ignore_unit", follow_unit, "report")
		
		if raycast then
			--log("no los")
			return true
		end
	end
end

function TeamAILogicIdle.on_long_dis_interacted(data, other_unit, secondary)
	local cur_objective = data.objective
	local mov_ext = data.unit:movement()
	local other_unit_mov_ext = other_unit:movement()
	local was_staying = mov_ext._should_stay and true

	if secondary then
		if was_staying then
			return
		end

		mov_ext:set_should_stay(true)

		if not cur_objective or cur_objective.type ~= "revive" then
			local new_objective = {
				scan = true,
				destroy_clbk_key = false,
				type = "follow",
				follow_unit = other_unit,
				is_stop = true
			}
			data.brain:set_objective(new_objective)
		end

		return
	end

	if cur_objective and cur_objective.type == "revive" then
		if was_staying then
			mov_ext:set_should_stay(false)
		end

		return
	end

	local objective_type, objective_action, interrupt = nil

	if other_unit:base().is_local_player then
		local other_unit_dmg_ext = other_unit:character_damage()

		if other_unit_dmg_ext:need_revive() then
			objective_type = "revive"

			if other_unit_dmg_ext:arrested() then
				objective_action = "untie"
			else
				objective_action = "revive"
			end
		else
			objective_type = "follow"
		end
	elseif other_unit_mov_ext:need_revive() then
		objective_type = "revive"

		if other_unit_mov_ext:current_state_name() == "arrested" then
			objective_action = "untie"
		else
			objective_action = "revive"
		end
	else
		objective_type = "follow"
	end

	local new_objective = nil

	if objective_type == "follow" then
		if mov_ext:carrying_bag() then
			local throw_bag = true

			if other_unit:base().is_local_player then
				if other_unit_mov_ext:current_state_name() == "carry" then
					throw_bag = false
				end
			elseif other_unit_mov_ext:carry_id() ~= nil then
				throw_bag = false
			end

			if throw_bag then
				local spine_pos = tmp_vec1
				mov_ext._obj_spine:m_position(spine_pos)

				local dis = mvec3_dist(spine_pos, other_unit_mov_ext:m_head_pos())

				local throw_distance = tweak_data.ai_carry.throw_distance * mov_ext:carry_tweak().throw_distance_multiplier
				throw_bag = dis <= throw_distance
			end

			if throw_bag then
				mov_ext:throw_bag(other_unit)

				return
			end
		end

		new_objective = {
			scan = true,
			destroy_clbk_key = false,
			called = true,
			type = objective_type,
			follow_unit = other_unit
		}

		data.unit:sound():say("r01x_sin", true)
	else
		local followup_objective = {
			scan = true,
			type = "act",
			action = {
				variant = "idle", ----change this to idle in all the other files (or test overriding them through copactionact)
				body_part = 1,
				type = "act",
				blocks = {
					heavy_hurt = -1,
					hurt = -1,
					action = -1,
					aim = -1,
					walk = -1
				}
			}
		}
		new_objective = {
			type = "revive",
			called = true,
			scan = true,
			destroy_clbk_key = false,
			follow_unit = other_unit,
			nav_seg = other_unit:movement():nav_tracker():nav_segment(),
			action = {
				align_sync = true,
				type = "act",
				body_part = 1,
				variant = objective_action,
				blocks = {
					light_hurt = -1,
					hurt = -1,
					action = -1,
					heavy_hurt = -1,
					aim = -1,
					walk = -1,
					dodge = -1
				}
			},
			action_duration = tweak_data.interaction[objective_action == "untie" and "free" or "revive"].timer,
			followup_objective = followup_objective
		}

		if not objective_action == "untie" then
			data.unit:sound():say("r02a_sin", true)
		end
	end

	if was_staying then
		mov_ext:set_should_stay(false)
	end

	data.brain:set_objective(new_objective)
end

function TeamAILogicIdle._ignore_shield(unit, attention)
	local weapon_base = unit:inventory() and unit:inventory():equipped_unit() and unit:inventory():equipped_unit():base()
	local has_ap_ammo = weapon_base and weapon_base._use_armor_piercing

	if has_ap_ammo then --this way Jokers can also easily check if they have AP ammo
		return false
	end

	local shoot_from_pos = unit:movement():m_head_pos()
	local target_pos = nil

	if attention.handler then
		target_pos = attention.handler:get_attention_m_pos()
	elseif attention.unit then
		if attention.unit:movement() and attention.unit:movement().m_head_pos then
			target_pos = attention.unit:movement():m_head_pos()
		elseif attention.unit:character_damage() and attention.unit:character_damage().shoot_pos_mid then
			target_pos = tmp_vec2

			attention.unit:character_damage():shoot_pos_mid(target_pos)
		end
	end

	if not target_pos then
		return false
	end

	if not TeamAILogicIdle._shield_check then
		TeamAILogicIdle._shield_check = managers.slot:get_mask("enemy_shield_check")
	end

	local hit_shield = nil

	if alive(unit:inventory() and unit:inventory()._shield_unit) then
		hit_shield = World:raycast("ray", shoot_from_pos, target_pos, "slot_mask", TeamAILogicIdle._shield_check, "ignore_unit", unit:inventory()._shield_unit, "report")
	else
		hit_shield = World:raycast("ray", shoot_from_pos, target_pos, "slot_mask", TeamAILogicIdle._shield_check, "report")
	end

	return not not hit_shield
end

function TeamAILogicIdle._get_priority_attention(data, attention_objects, reaction_func)
	if not TeamAILogicIdle._vis_check_slotmask then
		TeamAILogicIdle._vis_check_slotmask = managers.slot:get_mask("AI_visibility")
	end

	reaction_func = reaction_func or TeamAILogicBase._chk_reaction_to_attention_object
	local best_target, best_target_priority_slot, best_target_priority, best_target_reaction = nil

	for u_key, attention_data in pairs(attention_objects) do
		local att_unit = attention_data.unit

		if attention_data.identified then
			if attention_data.pause_expire_t then
				if attention_data.pause_expire_t < data.t then
					attention_data.pause_expire_t = nil
				end
			elseif attention_data.stare_expire_t and attention_data.stare_expire_t < data.t then
				if attention_data.settings.pause then
					attention_data.stare_expire_t = nil
					attention_data.pause_expire_t = data.t + math_lerp(attention_data.settings.pause[1], attention_data.settings.pause[2], math_random())
				end
			else
				local distance = mvec3_dist(data.m_pos, attention_data.m_pos)
				local reaction = reaction_func(data, attention_data, not CopLogicAttack._can_move(data))
				local reaction_too_mild = nil

				if not reaction or best_target_reaction and reaction < best_target_reaction then
					reaction_too_mild = true
				elseif distance < 150 and reaction <= AIAttentionObject.REACT_SURPRISED then
					reaction_too_mild = true
				end

				if not reaction_too_mild then
					local alert_dt = attention_data.alert_t and data.t - attention_data.alert_t or 10000
					local dmg_dt = attention_data.dmg_t and data.t - attention_data.dmg_t or 10000
					local too_close_threshold = 300
					local near_threshold = 800

					if data.attention_obj and data.attention_obj.u_key == u_key then
						alert_dt = alert_dt * 0.8
						dmg_dt = dmg_dt * 0.8
						distance = distance * 0.8
					end

					local visible = attention_data.verified
					local target_priority = distance
					local target_priority_slot = 0

					if visible then
						local att_base = att_unit:base()
						local is_shielded = TeamAILogicIdle._ignore_shield and TeamAILogicIdle._ignore_shield(data.unit, attention_data) or nil

						if is_shielded then
							local not_important = true

							if distance <= 150 and att_base.has_tag and att_base:has_tag("shield") then
								local can_be_knocked = att_base:char_tweak().damage.shield_knocked and not att_unit:character_damage():is_immune_to_shield_knockback()

								if can_be_knocked then
									target_priority_slot = 4
									not_important = nil
								end
							end

							if not_important then
								target_priority_slot = 14
							end
						else
							local aimed_at = TeamAILogicIdle.chk_am_i_aimed_at(data, attention_data, attention_data.aimed_at and 0.95 or 0.985)
							attention_data.aimed_at = aimed_at

							local too_close = distance <= too_close_threshold
							local near = distance < near_threshold and distance > too_close_threshold
							local has_alerted = alert_dt < 5
							local has_damaged = dmg_dt < 2
							local is_marked = att_unit:contour() and att_unit:contour()._contour_list

							if att_base.sentry_gun then
								target_priority_slot = too_close and 4 or near and 6 or is_marked and 8 or has_damaged and has_alerted and 9 or has_alerted and 10 or 11
							else
								local keep_checking = true

								if att_base.has_tag and att_base:has_tag("special") then
									if att_base:has_tag("spooc") then
										local trying_to_kick_criminal = att_unit:brain()._logic_data and att_unit:brain()._logic_data.internal_data and att_unit:brain()._logic_data.internal_data.spooc_attack

										if trying_to_kick_criminal then
											target_priority_slot = 1

											if trying_to_kick_criminal.target_u_key == data.key then
												target_priority = target_priority * 0.1
											end
										else
											target_priority_slot = too_close and 1 or near and 3 or is_marked and 6 or has_damaged and has_alerted and 9 or has_alerted and 10 or 11
										end

										keep_checking = nil
									elseif att_base:has_tag("taser") then
										local trying_to_tase_criminal = att_unit:brain()._logic_data and att_unit:brain()._logic_data.internal_data and att_unit:brain()._logic_data.internal_data.tasing

										if trying_to_tase_criminal then
											target_priority_slot = 1

											if trying_to_tase_criminal.target_u_key == data.key then
												target_priority = target_priority * 0.1
											end
										else
											target_priority_slot = too_close and 3 or near and 5 or is_marked and 7 or has_damaged and has_alerted and 9 or has_alerted and 10 or 11
										end

										keep_checking = nil
									elseif att_base:has_tag("medic") then
										target_priority_slot = too_close and 2 or near and 4 or is_marked and 6 or has_damaged and has_alerted and 9 or has_alerted and 10 or 11
										keep_checking = nil
									elseif att_base:has_tag("tank") then
										target_priority_slot = too_close and 4 or near and 6 or is_marked and 8 or has_damaged and has_alerted and 9 or has_alerted and 10 or 11
										keep_checking = nil
									elseif att_base:has_tag("sniper") then
										target_priority_slot = too_close and 4 or near and 6 or is_marked and 7 or has_damaged and has_alerted and 9 or has_alerted and 10 or 11
										keep_checking = nil
									elseif att_base:has_tag("shield") then
										if att_tweak_table == "phalanx_vip" then
											local active_phalanx = alive(managers.groupai:state():phalanx_vip())

											if active_phalanx then
												target_priority_slot = 4
											else
												target_priority_slot = 14 --to avoid calculating optimal distance with auto/semiauto shotguns and LMGs
												reaction = math_min(AIAttentionObject.REACT_AIM, reaction)
											end
										else
											target_priority_slot = too_close and 4 or near and 6 or is_marked and 8 or has_damaged and has_alerted and 9 or has_alerted and 10 or 11
										end

										keep_checking = nil
									end
								end

								if keep_checking then
									if has_damaged and has_alerted then
										target_priority_slot = too_close and 5 or near and 7 or 9
									elseif has_alerted then
										target_priority_slot = too_close and 6 or near and 8 or 10
									else
										target_priority_slot = too_close and 7 or near and 9 or 11
									end
								end
							end

							if target_priority_slot ~= 0 and reaction >= AIAttentionObject.REACT_COMBAT then
								local my_weapon_usage = data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage

								if my_weapon_usage == "is_shotgun_mag" or my_weapon_usage == "is_lmg" then
									local optimal_range = data.char_tweak.weapon[my_weapon_usage].range.optimal

									if distance >= optimal_range then
										target_priority_slot = target_priority_slot + 3
									end
								end
							end
						end
					else
						target_priority_slot = 15
					end

					if reaction < AIAttentionObject.REACT_COMBAT then
						target_priority_slot = 15 + target_priority_slot + math_max(0, AIAttentionObject.REACT_COMBAT - reaction)
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
	end

	return best_target, best_target_priority_slot, best_target_reaction
end

function TeamAILogicIdle._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local is_cool = data.cool
	local max_reaction = nil

	if is_cool then
		max_reaction = AIAttentionObject.REACT_SURPRISED
	end

	local delay = CopLogicBase._upd_attention_obj_detection(data, nil, max_reaction)
	local new_attention, new_prio_slot, new_reaction = TeamAILogicIdle._get_priority_attention(data, data.detected_attention_objects, nil)

	TeamAILogicBase._set_attention_obj(data, new_attention, new_reaction)

	if not is_cool then
		if new_reaction and AIAttentionObject.REACT_AIM <= new_reaction then
			local wanted_state = nil
			local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, data.objective, nil, new_attention)

			if allow_trans then
				wanted_state = TeamAILogicBase._get_logic_state_from_reaction(data, new_reaction)

				if data.objective and data.objective.type == "revive" then
					local revive_unit = data.objective.follow_unit
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

		if not my_data._turning_to_intimidate and not my_data.acting then
			if not my_data._intimidate_chk_t or data.t > my_data._intimidate_chk_t then
				my_data._intimidate_chk_t = data.t + 0.5

				if not data.intimidate_t or data.t > data.intimidate_t then
					local can_turn = nil

					if not new_reaction or new_reaction < AIAttentionObject.REACT_AIM then
						if not data.unit:movement():chk_action_forbidden("turn") then
							can_turn = true
						end
					end

					local shout_angle = can_turn and 180 or 60
					local civ = TeamAILogicIdle.find_civilian_to_intimidate(data.unit, shout_angle, 1200)

					if civ then
						data.intimidate_t = data.t + 2
						my_data._intimidate_chk_t = data.intimidate_t

						if can_turn and CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, civ:movement():m_pos()) then ----temporarily set attention for stuff like this so the unit turns for clients
							my_data._turning_to_intimidate = true
							my_data._primary_intimidation_target = civ
						else
							TeamAILogicIdle.intimidate_civilians(data, data.unit, true, true)
						end
					end
				end
			end
		end

		TeamAILogicIdle.check_idle_reload(data, new_reaction)
	end

	TeamAILogicIdle._upd_sneak_spotting(data, my_data)
	CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicIdle._upd_enemy_detection, data, data.t + delay)
end

function TeamAILogicIdle.check_idle_reload(data, reaction)
	local criminal_brain = data.unit:brain()

	if not reaction or reaction <= AIAttentionObject.REACT_AIM then
		data.idle_reload_chk_t = data.idle_reload_chk_t or data.t + 2

		if data.idle_reload_chk_t and data.idle_reload_chk_t < data.t then
			local criminal = data.unit
			local weapon_unit = criminal:inventory():equipped_unit()

			if weapon_unit and weapon_unit:base() then
				if not criminal:anim_data().reload and not criminal:movement():chk_action_forbidden("action") then
					local magazine_size, current_ammo_in_mag = weapon_unit:base():ammo_info()

					if current_ammo_in_mag <= magazine_size * 0.5 then
						local new_action = {
							body_part = 3,
							type = "reload",
							idle_reload = true
						}

						if criminal_brain:action_request(new_action) then
							data.idle_reload_chk_t = nil
						end
					end
				end
			end
		end
	else
		data.idle_reload_chk_t = nil
	end
end

function TeamAILogicIdle._find_intimidateable_civilians(criminal, use_default_shout_shape, max_angle, max_dis)
	local enemy_domination = "assist" --add toggle to use -"assist" or true or nil-
	local draw_civ_detection_lines = false
	local head_pos = criminal:movement():m_head_pos()
	local look_vec = criminal:movement():m_rot():y()
	local close_dis = 400
	local intimidateable_civilians = {}
	local best_civ = nil
	local best_civ_wgt = false
	local highest_wgt = 1
	local t = TimerManager:game():time()
	local attention_objects = criminal:brain()._logic_data and criminal:brain()._logic_data.detected_attention_objects or {}

	for key, attention_info in pairs(attention_objects) do
		if attention_info.identified then
			if attention_info.verified or attention_info.nearly_visible then
				if attention_info.is_person and attention_info.char_tweak and not attention_info.unit:character_damage():dead() then
					local att_unit = attention_info.unit
					local att_char_tweak = attention_info.char_tweak
					local anim_data = att_unit:anim_data()
					local is_enemy = nil
					local is_escort = nil
					local is_civilian = nil

					if enemy_domination ~= nil then
						if not TeamAILogicIdle._intimidate_global_t or TeamAILogicIdle._intimidate_global_t + 2 < t then
							if not att_char_tweak.priority_shout and att_char_tweak.surrender and not att_char_tweak.surrender.special and not att_char_tweak.surrender.never and not anim_data.hands_tied then
								is_enemy = true
							end
						end
					end

					if not is_enemy and att_char_tweak.is_escort then
						if not TeamAILogicIdle._intimidate_global_t or TeamAILogicIdle._intimidate_global_t + 2 < t then
							is_escort = true
						end
					end

					if not is_escort and managers.enemy:is_civilian(att_unit) and att_char_tweak.intimidateable and not att_unit:brain():is_tied() then
						is_civilian = true
					end

					if is_enemy or is_escort or is_civilian then
						if not att_unit:movement():cool() and not att_unit:base().unintimidateable and not anim_data.unintimidateable and not anim_data.long_dis_interact_disabled and not att_unit:unit_data().disable_shout then
							local being_moved = is_civilian and att_unit:movement():stance_name() == "cbt" and anim_data.stand

							if not being_moved then
								local att_head_pos = attention_info.m_head_pos
								local vec = att_head_pos - head_pos
								local dis = mvec3_norm(vec)
								local angle = vec:angle(look_vec)

								if use_default_shout_shape then
									max_angle = math_max(8, math_lerp(90, 30, dis / 1200))

									if is_escort then
										max_dis = 600
									else
										max_dis = 1200
									end
								elseif is_escort then
									max_dis = math_min(600, max_dis)
								elseif is_enemy then
									max_angle = 180
								end

								if dis < close_dis or dis < max_dis and angle < max_angle then
									local valid_target = nil
									local inv_wgt = dis

									if is_enemy then
										local already_intimidated = att_unit:brain().surrendered and att_unit:brain():surrendered() or anim_data.surrender or anim_data.hands_back

										if already_intimidated then
											valid_target = true
											inv_wgt = inv_wgt * 0.01
										elseif enemy_domination ~= "assist" then
											if managers.groupai:state():has_room_for_police_hostage() then
												if att_char_tweak.surrender.base_chance >= 1 then
													valid_target = true
												else
													for reason, reason_data in pairs(att_char_tweak.surrender.reasons) do
														if reason == "pants_down" then
															if not managers.groupai:state():enemy_weapons_hot() then
																local not_cool_t = att_unit:movement():not_cool_t()

																if not not_cool_t or t - not_cool_t < 1.5 then
																	valid_target = true

																	break
																end
															end
														elseif reason == "weapon_down" then
															if anim_data.reload or anim_data.hurt or anim_data.tase or att_unit:movement():stance_name() == "ntl" then
																valid_target = true

																break
															else
																local equipped_weapon = att_unit:inventory() and att_unit:inventory():equipped_unit()
																local _, ammo = equipped_weapon and equipped_weapon:base() and equipped_weapon:base().ammo_info and equipped_weapon:base():ammo_info()

																if ammo == 0 then
																	valid_target = true

																	break
																end
															end
														elseif reason == "health" then
															local health_ratio = att_unit:character_damage():health_ratio()

															if health_ratio < 1 then
																local max_setting = nil

																for k, v in pairs(reason_data) do
																	if not max_setting or max_setting.k < k then
																		max_setting = {
																			k = k,
																			v = v
																		}
																	end
																end

																if health_ratio < max_setting.k then
																	valid_target = true

																	break
																end
															end
														end
													end
												end
											end
										end
									elseif is_escort then
										if not anim_data.move then
											valid_target = true
											inv_wgt = -1
										end
									else
										if not anim_data.drop then
											valid_target = true
											inv_wgt = inv_wgt * 0.001
										else
											local civ_internal_data = att_unit:brain()._logic_data and att_unit:brain()._logic_data.internal_data
											local will_get_up_soon = civ_internal_data and civ_internal_data.submission_meter and civ_internal_data.submission_meter < 10

											if will_get_up_soon then
												valid_target = true
												inv_wgt = inv_wgt * 0.01
											else
												local recently_shouted_down = criminal:brain()._shouted_down_civ_t and att_unit:brain()._stopped_civ_t and t < criminal:brain()._shouted_down_civ_t + 3 and t < att_unit:brain()._stopped_civ_t + 3

												if recently_shouted_down then
													valid_target = true
												end
											end
										end
									end

									if valid_target then
										if draw_civ_detection_lines then
											local draw_duration = 0.1
											local new_brush = Draw:brush(Color.blue:with_alpha(0.5), draw_duration)
											new_brush:cylinder(head_pos, att_head_pos, 0.5)
										end

										t_ins(intimidateable_civilians, {
											unit = att_unit,
											key = key,
											inv_wgt = inv_wgt
										})

										if not best_civ_wgt or inv_wgt < best_civ_wgt then
											best_civ_wgt = inv_wgt
											best_civ = att_unit
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
			end
		end
	end

	if draw_civ_detection_lines and best_civ then
		local draw_duration = 0.1
		local new_brush = Draw:brush(Color.yellow:with_alpha(0.5), draw_duration)
		new_brush:cylinder(head_pos, best_civ:movement():m_head_pos(), 0.5)
	end

	return best_civ, highest_wgt, intimidateable_civilians
end

function TeamAILogicIdle.intimidate_civilians(data, criminal, play_sound, play_action, primary_target)
	if alive(primary_target) and primary_target:unit_data().disable_shout then
		return false
	end

	if primary_target and not alive(primary_target) then
		primary_target = nil
	end

	local best_civ, highest_wgt, intimidateable_civilians = TeamAILogicIdle._find_intimidateable_civilians(criminal, true)
	local plural = false

	if #intimidateable_civilians > 1 then
		plural = true
	elseif #intimidateable_civilians <= 0 then
		return false
	end
	
	local criminal_brain = criminal:brain()
	local best_civ_brain = best_civ:brain()
	local best_civ_anim_data = best_civ:anim_data()

	local intimidate_enemy = best_civ:base():char_tweak().surrender
	local intimidate_escort = best_civ:base():char_tweak().is_escort
	local act_name, sound_name = nil
	local sound_suffix = plural and "plu" or "sin"

	if intimidate_enemy then
		if best_civ_anim_data.hands_back then --dropped weapon
			act_name = "cmd_down"
			sound_name = "l03x_sin" --put your cuffs on
		elseif best_civ_anim_data.surrender then --has hands in the air
			act_name = "cmd_down"
			sound_name = "l02x_sin" --on your knees
		else
			act_name = "cmd_stop"
			sound_name = "l01x_sin" --put your hands up/drop your weapon
		end
	elseif intimidate_escort then
		act_name = "cmd_gogo" --same as "cmd_point", but for the heck of consistency
		sound_name = "f40_any" --not using "get up" lines since they're mostly unfitting inspire ones (the "gogo" inspire ones are not so bad in comparison), or they're played at wrong times
	else
		if best_civ_anim_data.move then --civ is moving
			act_name = "cmd_stop"

			if criminal_brain._stopped_civ_t and data.t < criminal_brain._stopped_civ_t + 3 then --bot told someone to get on the ground in the last 3 seconds
				sound_name = "f02b_sin" --I SAID GET DOWN
			else
				sound_name = "f02x_" .. sound_suffix --get down people/on the ground

				best_civ_brain._stopped_civ_t = data.t
				criminal_brain._stopped_civ_t = data.t
			end
		elseif best_civ_anim_data.drop then --civ is on the ground
			act_name = "cmd_down"

			if criminal_brain._shouted_down_civ_t and data.t < criminal_brain._shouted_down_civ_t + 3 then --bot made someone get on the ground in the last 3 seconds
				sound_name = "f03b_any" --and stay put
			else
				sound_name = "f03a_" .. sound_suffix --stay down/nobody moves
			end
		else
			act_name = "cmd_down"

			if criminal_brain._stopped_civ_t and data.t < criminal_brain._stopped_civ_t + 3 then --bot told someone to get on the ground in the last 3 seconds
				sound_name = "f02b_sin" --I SAID GET DOWN
			else
				sound_name = "f02x_" .. sound_suffix --get down people/on the ground
			end

			best_civ_brain._stopped_civ_t = data.t
			criminal_brain._stopped_civ_t = data.t
			criminal_brain._shouted_down_civ_t = data.t
		end
	end

	if play_sound then
		criminal:sound():say(sound_name, true)
	end

	if play_action then
		local can_do_action = nil

		if not criminal:anim_data().reload then
			if intimidate_enemy then
				can_do_action = true
			else
				if not data.internal_data.firing and not data.internal_data.shooting then
					can_do_action = true
				end
			end
		end

		if can_do_action and not criminal:movement():chk_action_forbidden("action") then
			local new_action = {
				align_sync = true,
				body_part = 3,
				type = "act",
				variant = act_name
			}

			if criminal_brain:action_request(new_action) then
				data.internal_data.gesture_arrest = true
			end

			--[[if criminal:movement():play_redirect(act_name) then
				managers.network:session():send_to_peers_synched("play_distance_interact_redirect", criminal, act_name)
			end]]
		end
	end

	local intimidated_primary_target = false

	for _, civ in ipairs(intimidateable_civilians) do
		if primary_target == civ.unit then
			intimidated_primary_target = true
		end

		local dont_intimidate = nil

		if best_civ ~= civ.unit then
			if civ.unit:base():char_tweak().surrender or civ.unit:base():char_tweak().is_escort then
				dont_intimidate = true
			end
		end

		if not dont_intimidate then
			civ.unit:brain():on_intimidated(1, criminal)
		end
	end

	if not intimidated_primary_target and primary_target then
		primary_target:brain():on_intimidated(1, criminal)
	end

	if intimidate_enemy or intimidate_escort then
		TeamAILogicIdle._intimidate_global_t = data.t
	end

	local skip_alert = managers.groupai:state():whisper_mode()

	if not skip_alert then
		local alert_rad = 500
		local alert = {
			"vo_cbt",
			criminal:movement():m_head_pos(),
			alert_rad,
			data.SO_access,
			criminal
		}

		managers.groupai:state():propagate_alert(alert)
	end

	if not primary_target and best_civ and best_civ:unit_data().disable_shout then
		return false
	end

	return primary_target or best_civ
end

function TeamAILogicIdle.on_new_objective(data, old_objective)
	local new_objective = data.objective

	TeamAILogicBase.on_new_objective(data, old_objective)

	local my_data = data.internal_data

	if not my_data.exiting then
		if new_objective then
			if new_objective.is_stop then
				local att_obj = data.attention_obj

				if not att_obj or AIAttentionObject.REACT_AIM > att_obj.reaction then
					CopLogicBase._exit(data.unit, "idle")
				else
					CopLogicBase._exit(data.unit, "assault")
				end
			else
				local objective_needs_travel = nil

				if new_objective.type == "revive" then
					objective_needs_travel = CopLogicIdle._chk_objective_needs_travel(data, new_objective)
				elseif not data.unit:movement()._should_stay then
					if new_objective.type == "follow" and TeamAILogicIdle._check_should_relocate(data, my_data, new_objective) then
						new_objective.in_place = nil

						objective_needs_travel = true
					else
						objective_needs_travel = CopLogicIdle._chk_objective_needs_travel(data, new_objective)
					end
				end

					--[[if new_objective.nav_seg or new_objective.type == "follow" then
						if not new_objective.in_place then
							if new_objective.pos then
								objective_needs_travel = true
							elseif not new_objective.area or not new_objective.area.nav_segs[data.unit:movement():nav_tracker():nav_segment()] then
								objective_needs_travel = true
							end
						end
					end
				elseif new_objective.type == "revive" then
					objective_needs_travel = true
				end]]

				if objective_needs_travel then
					--[[if data._ignore_first_travel_order then
						data._ignore_first_travel_order = nil
					else]]
						CopLogicBase._exit(data.unit, "travel")
					--end
				elseif new_objective.action then
					CopLogicBase._exit(data.unit, "idle")
				else
					local att_obj = data.attention_obj

					if not att_obj or AIAttentionObject.REACT_AIM > att_obj.reaction then
						CopLogicBase._exit(data.unit, "idle")
					else
						CopLogicBase._exit(data.unit, "assault")
					end
				end
			end
		else
			CopLogicBase._exit(data.unit, "idle")
		end
	--else
		--debug_pause("[TeamAILogicIdle.on_new_objective] Already exiting", data.name, data.unit, old_objective and inspect(old_objective), new_objective and inspect(new_objective))
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

function TeamAILogicIdle._upd_sneak_spotting(data, my_data)
	if not managers.groupai:state():whisper_mode() then
		return
	end

	if not my_data.mark_special_chk_t or data.t > my_data.mark_special_chk_t then
		my_data.mark_special_chk_t = data.t + 0.75

		if not data.mark_special_t or data.t > data.mark_special_t then
			local play_action = not data.cool --aka requires fov
			local nmy = TeamAILogicIdle.find_sneak_char_to_mark(data, play_action)

			if nmy then
				data.mark_special_t = data.t + 6
				my_data.mark_special_chk_t = data.mark_special_t

				local play_sound = not data.unit:sound():speaking()

				TeamAILogicIdle.mark_sneak_char(data, data.unit, nmy, play_sound, play_action)

				return true
			end
		end
	end
end

function TeamAILogicIdle.find_sneak_char_to_mark(data, can_play_action)
	local attention_objects = data.detected_attention_objects
	local e_manager = managers.enemy
	local is_civ_func = e_manager.is_civilian
	local best_nmy, best_nmy_wgt, my_head_pos, my_look_vec, max_marking_angle = nil

	if can_play_action then
		my_head_pos = data.unit:movement():m_head_pos()
		my_look_vec = data.unit:movement():m_rot():y()
		max_marking_angle = 90
	end

	for key, attention_info in pairs(attention_objects) do
		local att_contour_ext = attention_info.unit:contour()

		if att_contour_ext and attention_info.identified and attention_info.is_alive then
			if attention_info.verified or attention_info.nearly_visible then
				if attention_info.is_person and attention_info.char_tweak and attention_info.char_tweak.silent_priority_shout then
					if not e_manager.is_civilian(e_manager, attention_info.unit) and attention_info.unit:movement():cool() then
						if not attention_info.char_tweak.priority_shout_max_dis or attention_info.dis < attention_info.char_tweak.priority_shout_max_dis then
							local in_fov = nil

							if can_play_action then
								local vec = attention_info.m_head_pos - my_head_pos
								local angle = vec:normalized():angle(my_look_vec)

								if angle < max_marking_angle then
									in_fov = true
								end
							else
								in_fov = true
							end

							if in_fov then
								local mark = nil

								if not att_contour_ext._contour_list then
									mark = true
								else
									local has_id_func = att_contour_ext.has_id

									if not has_id_func(att_contour_ext, "mark_enemy") and not has_id_func(att_contour_ext, "mark_enemy_damage_bonus") and not has_id_func(att_contour_ext, "mark_enemy_damage_bonus_distance") then
										mark = true
									end
								end

								if mark then
									if not best_nmy_wgt or attention_info.dis < best_nmy_wgt then
										best_nmy_wgt = attention_info.dis
										best_nmy = attention_info.unit
									end
								end
							end
						end
					end
				end
			end
		end
	end

	return best_nmy
end

function TeamAILogicIdle.mark_sneak_char(data, criminal, to_mark, play_sound, play_action)
	if play_sound then
		local callout = not data.last_mark_shout_t or tweak_data.sound.criminal_sound.ai_callout_cooldown < data.t - data.last_mark_shout_t

		if callout then
			criminal:sound():say(to_mark:base():char_tweak().silent_priority_shout .. "_any", true)

			data.last_mark_shout_t = data.t
		end
	end

	if play_action then
		local can_play_action = not data.internal_data.shooting and not criminal:anim_data().reload and not criminal:movement():chk_action_forbidden("action")

		if can_play_action then
			local new_action = {
				type = "act",
				variant = "arrest",
				body_part = 3,
				align_sync = true
			}

			if criminal:brain():action_request(new_action) then
				data.internal_data.gesture_arrest = true
			end
		end
	end

	to_mark:contour():add("mark_enemy", true)
end

function TeamAILogicIdle.damage_clbk(data, damage_info)
	local t = TimerManager:game():time()
	data.t = t

	local enemy = damage_info.attacker_unit

	if alive(enemy) and enemy:in_slot(data.enemy_slotmask) then
		local enemy_data, is_new = CopLogicBase.identify_attention_obj_instant(data, enemy:key())

		if enemy_data then
			enemy_data.dmg_t = t
			enemy_data.alert_t = t
		end
	end

	if data.name == "disabled" then
		return
	end

	if damage_info.result.type == "bleedout" or damage_info.result.type == "fatal" or damage_info.variant == "tase" then
		CopLogicBase._exit(data.unit, "disabled")
	end
end

function TeamAILogicIdle.on_alert(data, alert_data)
	if CopLogicBase._chk_alert_obstructed(data.unit:movement():m_head_pos(), alert_data) then
		return
	end

	data.t = TimerManager:game():time()

	local alert_type = alert_data[1]
	local alert_unit = alert_data[5]

	if not alive(alert_unit) or not alert_unit:in_slot(data.enemy_slotmask) then
		return
	end

	local att_obj_data = CopLogicBase.identify_attention_obj_instant(data, alert_unit:key())

	if not att_obj_data then
		return
	end

	if CopLogicBase.is_alert_dangerous(alert_type) then
		att_obj_data.alert_t = data.t
	end
end