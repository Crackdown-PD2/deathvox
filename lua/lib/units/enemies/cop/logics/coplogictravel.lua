--local mvec3_x = mvector3.x
--local mvec3_y = mvector3.y
--local mvec3_z = mvector3.z
local mvec3_set = mvector3.set
--local mvec3_set_z = mvector3.set_z
--local mvec3_sub = mvector3.subtract
--local mvec3_dir = mvector3.direction
--local mvec3_dot = mvector3.dot
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
--local mvec3_lerp = mvector3.lerp
--local mvec3_norm = mvector3.normalize
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
--local mvec3_cross = mvector3.cross
--local mvec3_rand_ortho = mvector3.random_orthogonal
local mvec3_negate = mvector3.negate
local mvec3_len = mvector3.length
--local mvec3_len_sq = mvector3.length_sq
local mvec3_cpy = mvector3.copy
--local mvec3_set_stat = mvector3.set_static
local mvec3_set_length = mvector3.set_length
--local mvec3_angle = mvector3.angle
--local mvec3_step = mvector3.step
local mvec3_rotate_with = mvector3.rotate_with

local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()

local math_lerp = math.lerp
local math_random = math.random
local math_up = math.UP
local math_abs = math.abs
--local math_clamp = math.clamp
local math_min = math.min
--local math_max = math.max
local math_sign = math.sign
local math_floor = math.floor

--local m_rot_x = mrotation.x
--local m_rot_y = mrotation.y
--local m_rot_z = mrotation.z

local pairs_g = pairs
local next_g = next
local table_insert = table.insert
local table_remove = table.remove
--local table_contains = table.contains

local clone_g = clone

local REACT_CURIOUS = AIAttentionObject.REACT_CURIOUS
local REACT_AIM = AIAttentionObject.REACT_AIM
local REACT_COMBAT = AIAttentionObject.REACT_COMBAT
local REACT_SHOOT = AIAttentionObject.REACT_SHOOT
local REACT_SUSPICIOUS = AIAttentionObject.REACT_SUSPICIOUS
local REACT_SCARED = AIAttentionObject.REACT_SCARED

--[[CopLogicTravel = class(CopLogicBase)
CopLogicTravel.damage_clbk = CopLogicIdle.damage_clbk
CopLogicTravel.death_clbk = CopLogicAttack.death_clbk
CopLogicTravel.on_detected_enemy_destroyed = CopLogicAttack.on_detected_enemy_destroyed
CopLogicTravel.on_criminal_neutralized = CopLogicAttack.on_criminal_neutralized
CopLogicTravel.on_alert = CopLogicIdle.on_alert
CopLogicTravel.on_new_objective = CopLogicIdle.on_new_objective]]

function CopLogicTravel.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.brain:cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit
	}
	local was_cool = data.cool

	if was_cool then
		my_data.detection = data.char_tweak.detection.ntl
	else
		my_data.detection = data.char_tweak.detection.recon
	end

	if old_internal_data then
		my_data.turning = old_internal_data.turning
		my_data.firing = old_internal_data.firing
		my_data.shooting = old_internal_data.shooting
		my_data.attention_unit = old_internal_data.attention_unit

		if old_internal_data.nearest_cover then
			my_data.nearest_cover = old_internal_data.nearest_cover

			managers.navigation:reserve_cover(my_data.nearest_cover[1], data.pos_rsrv_id)
		end

		if old_internal_data.best_cover then
			my_data.best_cover = old_internal_data.best_cover

			managers.navigation:reserve_cover(my_data.best_cover[1], data.pos_rsrv_id)
		end
	end

	--disabling since there's no audio for this in PD2 and this just wastes performance, enable back if actually needed
	--[[if data.announce_t then
		data.announce_t = math_max(data.announce_t, data. + 2)
	elseif data.char_tweak.announce_incomming then
		data.announce_t = data.t + 2
	end]]

	data.internal_data = my_data

	local new_stance = nil
	local objective = data.objective

	if objective.stance then
		new_stance = objective.stance

		if new_stance == "ntl" and data.char_tweak.allowed_stances and not data.char_tweak.allowed_stances.ntl then
			new_stance = nil
		end
	end

	if was_cool then
		local scary_attention_obj = data.attention_obj and data.attention_obj.reaction >= REACT_SCARED and data.attention_obj

		if not new_stance and scary_attention_obj or new_stance and new_stance ~= "ntl" then
			local giveaway = scary_attention_obj and managers.groupai:state().analyse_giveaway(data.unit:base()._tweak_table, scary_attention_obj.unit)

			data.unit:movement():set_cool(false, giveaway)

			if my_data ~= data.internal_data then
				return
			end
		end
	end

	if not new_stance and not data.cool then --checking for data.cool instead of was_cool is intended here (the latter isn't modified if the unit goes uncool, and in this case, didn't switch logics)
		new_stance = "hos"
	end

	if new_stance then
		if new_stance == "ntl" then
			data.unit:movement():set_stance(new_stance)

			if my_data ~= data.internal_data then
				return
			end
		elseif not my_data.shooting then
			if data.char_tweak.allowed_stances and not data.char_tweak.allowed_stances[new_stance] then
				if new_stance ~= "hos" and data.char_tweak.allowed_stances.hos then
					new_stance = "hos"
				elseif new_stance ~= "cbt" and data.char_tweak.allowed_stances.cbt then
					new_stance = "cbt"
				else
					new_stance = nil
				end
			end

			if new_stance then
				data.unit:movement():set_stance(new_stance)

				if my_data ~= data.internal_data then
					return
				end
			end
		end
	end

	my_data.attitude = objective.attitude or "avoid"
	my_data.weapon_range = clone_g(data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range)
	
	if data.tactics then
		if data.tactics.ranged_fire or data.tactics.elite_ranged_fire then
			my_data.weapon_range.close = my_data.weapon_range.close * 2
			my_data.weapon_range.optimal = my_data.weapon_range.optimal * 1.5
		end
	end

	my_data.path_safely = not data.cool and data.objective and data.objective.grp_objective and data.objective.grp_objective.type == "recon_area"
	my_data.path_ahead = data.cool or objective.path_ahead or data.is_converted or data.unit:in_slot(16) or data.team.id == tweak_data.levels:get_default_team_ID("player")

	local key_str = tostring(data.key)
	my_data.upd_task_key = "CopLogicTravel.queued_update" .. key_str

	CopLogicTravel.queue_update(data, my_data)

	my_data.cover_update_task_key = "CopLogicTravel._update_cover" .. key_str

	if my_data.nearest_cover or my_data.best_cover then
		CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t + 1)
	end

	my_data.advance_path_search_id = "CopLogicTravel_detailed" .. key_str
	my_data.coarse_path_search_id = "CopLogicTravel_coarse" .. key_str

	CopLogicIdle._chk_has_old_action(data, my_data)

	if my_data.advancing then
		my_data.old_action_advancing = true
	end

	if data.cool then
		if not was_cool then
			my_data.detection = data.char_tweak.detection.ntl
		end

		if my_data.firing then
			data.unit:movement():set_allow_fire(false)

			my_data.firing = nil
		end

		data.brain:set_attention_settings({
			peaceful = true
		})
	else
		if was_cool then
			my_data.detection = data.char_tweak.detection.recon
		end

		if data.unit:base().has_tag and data.unit:base():has_tag("special") then
			my_data.detection_uses_aim_react_or_higher = true
		end

		data.brain:set_attention_settings({
			cbt = true
		})
	end

	data.brain:set_update_enabled_state(false)

	local path_style = objective.path_style

	if path_style == "warp" then
		my_data.warp_pos = objective.pos
	else
		local path_data = objective.path_data

		if path_data then
			if path_style == "precise" then
				local path = {
					mvec3_cpy(data.m_pos)
				}

				for _, point in ipairs(path_data.points) do
					table_insert(path, mvec3_cpy(point.position))
				end

				my_data.advance_path = path
				my_data.coarse_path_index = 1
				local start_seg = data.unit:movement():nav_tracker():nav_segment()
				local end_pos = mvec3_cpy(path[#path])
				local end_seg = managers.navigation:get_nav_seg_from_pos(end_pos)
				my_data.coarse_path = {
					{
						start_seg
					},
					{
						end_seg,
						end_pos
					}
				}
				my_data.path_is_precise = true
			elseif path_style == "coarse" then
				local nav_manager = managers.navigation
				local f_get_nav_seg = nav_manager.get_nav_seg_from_pos
				local start_seg = data.unit:movement():nav_tracker():nav_segment()
				local path = {
					{
						start_seg
					}
				}

				for _, point in ipairs(path_data.points) do
					local pos = mvec3_cpy(point.position)
					local nav_seg = f_get_nav_seg(nav_manager, pos)

					table_insert(path, {
						nav_seg,
						pos
					})
				end

				my_data.coarse_path = path
				my_data.coarse_path_index = CopLogicTravel.complete_coarse_path(data, my_data, path)
			elseif path_style == "coarse_complete" then
				my_data.coarse_path_index = 1
				my_data.coarse_path = deep_clone(objective.path_data)
				my_data.coarse_path_index = CopLogicTravel.complete_coarse_path(data, my_data, my_data.coarse_path)
			end
		end
	end
end

function CopLogicTravel.exit(data, new_logic_name, enter_params)
	CopLogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	data.brain:cancel_all_pathing_searches()
	CopLogicBase.cancel_queued_tasks(my_data)
	CopLogicBase.cancel_delayed_clbks(my_data)

	if my_data.moving_to_cover then
		managers.navigation:release_cover(my_data.moving_to_cover[1])
	end

	if my_data.nearest_cover then
		managers.navigation:release_cover(my_data.nearest_cover[1])
	end

	if my_data.best_cover then
		managers.navigation:release_cover(my_data.best_cover[1])
	end

	if not my_data.attention_unit then
		local current_attention = data.unit:movement():attention()

		if current_attention then
			if current_attention.pos then
				my_data.attention_unit = mvec3_cpy(current_attention.pos)
			elseif current_attention.u_key then
				my_data.attention_unit = current_attention.u_key
			elseif current_attention.unit then
				my_data.attention_unit = current_attention.unit:key()
			end
		end
	end

	data.brain:rem_pos_rsrv("path")
	data.brain:set_update_enabled_state(true)
end

function CopLogicTravel.queued_update(data)
	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	my_data.close_to_criminal = nil

	local delay = CopLogicTravel._upd_enemy_detection(data)

	if data.internal_data ~= my_data then
		return
	end

	CopLogicTravel.upd_advance(data)

	if data.internal_data ~= my_data then
		return
	end

	if not delay then
		--debug_pause_unit(data.unit, "crap!!!", inspect(data))

		delay = 1
	end

	CopLogicTravel.queue_update(data, data.internal_data, delay)
end

function CopLogicTravel.upd_advance(data)
	local my_data = data.internal_data
	local objective = data.objective

	if my_data.has_old_action then
		CopLogicAttack._upd_stop_old_action(data, my_data)
	elseif my_data.warp_pos then
		local action_desc = {
			body_part = 1,
			type = "warp",
			position = mvec3_cpy(my_data.warp_pos),
			rotation = objective.rot
		}

		if data.unit:movement():action_request(action_desc) then
			CopLogicTravel._on_destination_reached(data)
		end
	--elseif CopLogicTravel._chk_target_area(data, my_data) then
	elseif my_data.advancing then
		if not my_data.old_action_advancing and my_data.coarse_path then
			CopLogicTravel._chk_stop_for_follow_unit(data, my_data)

			if my_data ~= data.internal_data then
				return
			end

			if data.announce_t and data.announce_t < data.t then
				CopLogicTravel._try_anounce(data)
			end
		end
	elseif my_data.advance_path then
		CopLogicTravel._chk_stop_for_follow_unit(data, my_data)

		if my_data ~= data.internal_data then
			return
		end

		if data.cool or CopLogicTravel.chk_group_ready_to_move(data, my_data) then
			CopLogicTravel._chk_begin_advance(data, my_data)
		end

		if my_data.advancing and my_data.path_ahead then
			CopLogicTravel._check_start_path_ahead(data)
		end
	elseif my_data.processing_advance_path or my_data.processing_coarse_path then
		local was_processing_advance = my_data.processing_advance_path

		CopLogicTravel._upd_pathing(data, my_data)

		if data.internal_data == my_data and not my_data.processing_advance_path and not my_data.processing_coarse_path then
			if was_processing_advance then
				if my_data.advance_path and not my_data.advancing then
					CopLogicTravel._chk_stop_for_follow_unit(data, my_data)

					if my_data ~= data.internal_data then
						return
					end

					if data.cool or CopLogicTravel.chk_group_ready_to_move(data, my_data) then
						CopLogicTravel._chk_begin_advance(data, my_data)
					end

					if my_data.advancing and my_data.path_ahead then
						CopLogicTravel._check_start_path_ahead(data)
					end
				end
			elseif my_data.coarse_path and not my_data.advancing then
				CopLogicTravel._chk_start_pathing_to_next_nav_point(data, my_data)
			end
		end
	elseif my_data.cover_leave_t then
		if my_data.cover_leave_t < data.t or CopLogicTravel._chk_close_to_criminal(data, my_data) then
			if not data.unit:anim_data().reload and not data.unit:movement():chk_action_forbidden("walk") then
				my_data.cover_leave_t = nil
			end
		end

		if my_data.cover_leave_t then
			if data.attention_obj and REACT_COMBAT <= data.attention_obj.reaction then
				if not my_data.best_cover or not my_data.best_cover[4] then
					if not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch then
						if not data.unit:anim_data().crouch then
							CopLogicAttack._chk_request_action_crouch(data)
						end
					end
				end
			end
		elseif objective.nav_seg or objective.type == "follow" then
			if my_data.coarse_path then
				if my_data.coarse_path_index == #my_data.coarse_path then
					CopLogicTravel._on_destination_reached(data)
				else
					CopLogicTravel._chk_start_pathing_to_next_nav_point(data, my_data)
				end
			else
				CopLogicTravel._begin_coarse_pathing(data, my_data)
			end
		else
			local wanted_state = data.logic._get_logic_state_from_reaction(data) or "idle"

			CopLogicBase._exit(data.unit, wanted_state)
		end
	elseif not data.unit:movement():chk_action_forbidden("walk") then
		if objective then
			if objective.nav_seg or objective.type == "follow" then
				if my_data.coarse_path then
					if my_data.coarse_path_index == #my_data.coarse_path then
						CopLogicTravel._on_destination_reached(data)
					else
						CopLogicTravel._chk_start_pathing_to_next_nav_point(data, my_data)
					end
				else
					CopLogicTravel._begin_coarse_pathing(data, my_data)
				end
			else
				local wanted_state = data.logic._get_logic_state_from_reaction(data) or "idle"

				CopLogicBase._exit(data.unit, wanted_state)
			end
		else
			local wanted_state = data.logic._get_logic_state_from_reaction(data) or "idle"

			CopLogicBase._exit(data.unit, wanted_state)
		end
	end
end

function CopLogicTravel._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	local my_data = data.internal_data
	local is_cool = data.cool
	local min_reaction = nil

	if not is_cool then
		min_reaction = my_data.aim_react_or_higher and REACT_AIM or REACT_CURIOUS
	end

	local delay = CopLogicBase._upd_attention_obj_detection(data, min_reaction, nil)
	local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, data.detected_attention_objects, nil)

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)

	local objective = data.objective
	local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, new_attention)
	
	if not objective or objective.type ~= "follow" then
		if allow_trans then
			local wanted_state = CopLogicBase._get_logic_state_from_reaction(data, new_reaction)

			if wanted_state and wanted_state ~= data.name then
				if obj_failed then
					data.objective_failed_clbk(data.unit, data.objective)
				end

				if my_data ~= data.internal_data then
					CopLogicBase._report_detections(data.detected_attention_objects)

					return delay
				end

				CopLogicBase._exit(data.unit, wanted_state)
				CopLogicBase._report_detections(data.detected_attention_objects)

				return delay
			end
		end
	end

	if is_cool then
		if new_attention then
			local turn_angle = CopLogicIdle._chk_turn_needed(data, my_data, data.m_pos, new_attention.m_pos)
			local facing_attention = nil

			if turn_angle and math_abs(turn_angle) > 70 then
				local set_attention = data.unit:movement():attention()

				if set_attention then
					CopLogicBase._reset_attention(data)
				end
			else
				facing_attention = true

				if new_reaction < REACT_AIM then
					local set_attention = data.unit:movement():attention()

					if not set_attention or set_attention.u_key ~= new_attention.u_key then
						CopLogicBase._set_attention(data, new_attention, nil)
					end
				end
			end

			if new_reaction == REACT_SUSPICIOUS then
				if CopLogicBase._upd_suspicion(data, my_data, new_attention) then
					CopLogicBase._report_detections(data.detected_attention_objects)

					return delay
				elseif facing_attention then
					CopLogicBase._chk_say_criminal_too_close(data, new_attention)
				end
			end
		else
			local set_attention = data.unit:movement():attention()

			if set_attention then
				CopLogicBase._reset_attention(data)
			end
		end

		CopLogicTravel.upd_suspicion_decay(data)
	else
		CopLogicAttack._upd_aim(data, my_data)

		if not data.entrance and new_attention and data.char_tweak.chatter and data.char_tweak.chatter.entrance then
			if new_attention.criminal_record and new_reaction >= REACT_COMBAT and new_attention.dis < 1000 and math_abs(data.m_pos.z - new_attention.m_pos.z) < 250 then
				local voiceline = data.brain.entrance_chatter_cue or data.char_tweak.elite_entrance or "entrance"

				data.unit:sound():say(voiceline, true, nil)

				data.entrance = true
			end
		end
	end

	CopLogicBase._report_detections(data.detected_attention_objects)

	return delay
end

function CopLogicTravel._upd_pathing(data, my_data)
	if data.pathing_results then
		local pathing_results = data.pathing_results
		data.pathing_results = nil
		local path = pathing_results[my_data.advance_path_search_id]

		if path and my_data.processing_advance_path then
			my_data.processing_advance_path = nil

			if path ~= "failed" then
				my_data.advance_path = path
				data.path_fail_t = nil
				--my_data.pathing_to_pos = nil
			else
				if data.objective and data.objective.type == "revive" then
					my_data.processing_coarse_path = nil

					CopLogicTravel._on_revive_destination_reached_by_warp(data, my_data, true)
				else
					data.path_fail_t = data.t

					data.objective_failed_clbk(data.unit, data.objective)
				end

				return
			end
		end

		local path = pathing_results[my_data.coarse_path_search_id]

		if path and my_data.processing_coarse_path then
			my_data.processing_coarse_path = nil

			if path ~= "failed" then
				my_data.coarse_path = path
				my_data.coarse_path_index = 1
				data.path_fail_t = nil

				if my_data.was_pathing_safely then
					my_data.path_safely = true
					my_data.was_pathing_safely = nil
				end
			elseif my_data.path_safely then
				my_data.path_safely = nil
				my_data.was_pathing_safely = true
			elseif data.objective and data.objective.type == "revive" then
				CopLogicTravel._on_revive_destination_reached_by_warp(data, my_data, true)
			else
				data.path_fail_t = data.t

				data.objective_failed_clbk(data.unit, data.objective)
			end
		end
	end
end

function CopLogicTravel._update_cover(ignore_this, data)
	local my_data = data.internal_data

	CopLogicBase.on_delayed_clbk(my_data, my_data.cover_update_task_key)

	local cover_release_dis = 100
	local nearest_cover = my_data.nearest_cover
	local best_cover = my_data.best_cover
	local check_pos = nil

	if my_data.advancing then
		if data.pos_rsrv.move_dest then
			check_pos = data.pos_rsrv.move_dest.position
		else
			check_pos = my_data.advancing:get_walk_to_pos()
		end
	else
		check_pos = data.m_pos
	end

	if not my_data.in_cover and nearest_cover and cover_release_dis < mvec3_dis(nearest_cover[1][1], check_pos) then
		managers.navigation:release_cover(nearest_cover[1])

		my_data.nearest_cover = nil
		nearest_cover = nil
	end

	if best_cover and cover_release_dis < mvec3_dis(best_cover[1][1], check_pos) then
		managers.navigation:release_cover(best_cover[1])

		my_data.best_cover = nil
		best_cover = nil
	end

	if nearest_cover or best_cover then
		CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), TimerManager:game():time() + 2)
	end
end

function CopLogicTravel._chk_request_action_turn_to_cover(data, my_data)
	local fwd = data.unit:movement():m_rot():y()

	mvec3_set(tmp_vec1, my_data.best_cover[1][2])
	mvec3_negate(tmp_vec1)

	local error_spin = tmp_vec1:to_polar_with_reference(fwd, math_up).spin

	if math_abs(error_spin) > 25 then
		local new_action_data = {
			type = "turn",
			body_part = 2,
			angle = error_spin
		}
		my_data.turning = data.brain:action_request(new_action_data)

		if my_data.turning then
			return true
		end
	end
end

function CopLogicTravel._chk_cover_height(data, cover, slotmask)
	local ray_from = tmp_vec1

	mvec3_set(ray_from, math_up)
	mvec3_mul(ray_from, 110)
	mvec3_add(ray_from, cover[1])

	local ray_to = tmp_vec2

	mvec3_set(ray_to, cover[2])
	mvec3_mul(ray_to, 200)
	mvec3_add(ray_to, ray_from)

	local ray = data.unit:raycast("ray", ray_from, ray_to, "slot_mask", slotmask, "ray_type", "ai_vision", "report")

	return ray
end

function CopLogicTravel.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action:type()

	if action_type == "walk" then
		local action_expired = action:expired()
		local update_immediately = nil

		if action_expired and my_data.advancing and not my_data.old_action_advancing and not my_data.has_old_action and not my_data.starting_advance_action and my_data.coarse_path_index then
			my_data.coarse_path_index = my_data.coarse_path_index + 1

			if my_data.coarse_path_index > #my_data.coarse_path then
				--debug_pause_unit(data.unit, "[CopLogicTravel.action_complete_clbk] invalid coarse path index increment", data.unit, inspect(my_data.coarse_path), my_data.coarse_path_index)

				my_data.coarse_path_index = my_data.coarse_path_index - 1
			end

			update_immediately = true
		end

		my_data.advancing = nil
		my_data.old_action_advancing = nil

		if my_data.moving_to_cover then
			if action_expired and not my_data.starting_advance_action then
				if my_data.best_cover then
					managers.navigation:release_cover(my_data.best_cover[1])
				end

				my_data.best_cover = my_data.moving_to_cover

				CopLogicBase.chk_cancel_delayed_clbk(my_data, my_data.cover_update_task_key)

				local high_ray = CopLogicTravel._chk_cover_height(data, my_data.best_cover[1], data.visibility_slotmask)
				my_data.best_cover[4] = high_ray
				my_data.in_cover = true

				if my_data.coarse_path_index ~= #my_data.coarse_path then
					my_data.close_to_criminal = nil
					
					if not data.tactics or not data.tactics.aggressor and not data.tactics.legday then
						if not CopLogicTravel._chk_close_to_criminal(data, my_data) then
							local cover_wait_time = 0.6 + 0.4 * math_random()
							
							if not data.tactics or not data.tactics.charge then
								cover_wait_time = cover_wait_time + math_random()
							end
							
							my_data.cover_leave_t = TimerManager:game():time() + cover_wait_time

							update_immediately = nil
						end
					end
				end
			else
				managers.navigation:release_cover(my_data.moving_to_cover[1])

				if my_data.best_cover then
					local dis = mvec3_dis(my_data.best_cover[1][1], data.m_pos)

					if dis > 100 then
						managers.navigation:release_cover(my_data.best_cover[1])

						my_data.best_cover = nil
					end
				end
			end

			my_data.moving_to_cover = nil
		elseif my_data.best_cover then
			local dis = mvec3_dis(my_data.best_cover[1][1], data.m_pos)

			if dis > 100 then
				managers.navigation:release_cover(my_data.best_cover[1])

				my_data.best_cover = nil
			end
		end

		if not action_expired then
			if my_data.processing_advance_path then
				local pathing_results = data.pathing_results

				if pathing_results and pathing_results[my_data.advance_path_search_id] then
					data.pathing_results[my_data.advance_path_search_id] = nil
					my_data.processing_advance_path = nil
				end
			elseif my_data.advance_path then
				my_data.advance_path = nil
			end

			data.brain:abort_detailed_pathing(my_data.advance_path_search_id)
		end

		if update_immediately then
			if my_data.advance_path then
				CopLogicTravel._chk_stop_for_follow_unit(data, my_data)

				if my_data ~= data.internal_data then
					return
				end

				data.t = TimerManager:game():time()

				if data.cool or CopLogicTravel.chk_group_ready_to_move(data, my_data) then
					CopLogicTravel._chk_begin_advance(data, my_data)
				end

				if my_data.advancing and my_data.path_ahead then
					CopLogicTravel._check_start_path_ahead(data)
				end
			elseif my_data.coarse_path and not my_data.processing_advance_path and not my_data.processing_coarse_path then
				local objective = data.objective

				if objective then
					if objective.nav_seg or objective.type == "follow" then
						if not data.unit:movement():chk_action_forbidden("walk") then
							if my_data.coarse_path_index == #my_data.coarse_path then
								--CopLogicTravel._on_destination_reached(data) ----test
							elseif data.important or data.is_converted or data.unit:in_slot(16) then
								CopLogicTravel._chk_start_pathing_to_next_nav_point(data, my_data)
							end
						end
					end
				end
			end
		end
	elseif action_type == "turn" then
		data.internal_data.turning = nil
	elseif action_type == "shoot" then
		data.internal_data.shooting = nil
	elseif action_type == "reload" or action_type == "heal" then
		if action:expired() then
			if data.important or data.is_converted or data.unit:in_slot(16) then
				CopLogicAttack._upd_aim(data, my_data)
			end
		end
	elseif action_type == "act" then
		if my_data.gesture_arrest then
			my_data.gesture_arrest = nil
		elseif action:expired() and not data.cool then
			if data.important or data.is_converted or data.unit:in_slot(16) then
				CopLogicAttack._upd_aim(data, my_data)
			end
		end
	elseif action_type == "hurt" or action_type == "healed" then
		if action:expired() then
			if data.important or data.is_converted or data.unit:in_slot(16) then
				if not CopLogicBase.chk_start_action_dodge(data, "hit") then
					CopLogicAttack._upd_aim(data, my_data)
				end
			end

			--[[if not my_data.exiting then
				local wanted_state = data.logic._get_logic_state_from_reaction(data)

				if wanted_state and wanted_state ~= data.name then
					local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, data.objective, nil, nil)

					if allow_trans and obj_failed then
						data.objective_failed_clbk(data.unit, data.objective)

						if my_data == data.internal_data then
							--debug_pause_unit(data.unit, "[CopLogicTravel.action_complete_clbk] exiting without discarding objective", data.unit, inspect(data.objective))
							CopLogicBase._exit(data.unit, wanted_state)
						end
					end
				end
			end]]
		end
	elseif action_type == "dodge" then
		local timeout = action:timeout()

		if timeout then
			data.dodge_timeout_t = TimerManager:game():time() + math_lerp(timeout[1], timeout[2], math_random())
		end

		if action:expired() then
			if data.important or data.is_converted or data.unit:in_slot(16) then
				CopLogicAttack._upd_aim(data, my_data)
			end

			--[[if not my_data.exiting then
				local wanted_state = data.logic._get_logic_state_from_reaction(data)

				if wanted_state and wanted_state ~= data.name then
					local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, data.objective, nil, nil)

					if allow_trans and obj_failed then
						data.objective_failed_clbk(data.unit, data.objective)

						if my_data == data.internal_data then
							--debug_pause_unit(data.unit, "[CopLogicTravel.action_complete_clbk] exiting without discarding objective", data.unit, inspect(data.objective))
							CopLogicBase._exit(data.unit, wanted_state)
						end
					end
				end
			end]]
		end
	end
end

function CopLogicTravel._get_pos_accross_door(guard_door, nav_seg)
	local rooms = guard_door.rooms
	local room_1_seg = guard_door.low_seg
	local accross_vec = guard_door.high_pos - guard_door.low_pos
	local rot_angle = 90

	if room_1_seg == nav_seg then
		if guard_door.low_pos.y == guard_door.high_pos.y then
			rot_angle = rot_angle * -1
		end
	elseif guard_door.low_pos.x == guard_door.high_pos.x then
		rot_angle = rot_angle * -1
	end

	mvec3_rotate_with(accross_vec, Rotation(rot_angle))

	local max_dis = 1500

	mvec3_set_length(accross_vec, 1500)

	local door_pos = guard_door.center
	local door_tracker = managers.navigation:create_nav_tracker(mvec3_cpy(door_pos))
	local accross_positions = managers.navigation:find_walls_accross_tracker(door_tracker, accross_vec)

	if accross_positions then
		local optimal_dis = math_lerp(max_dis * 0.6, max_dis, math_random())
		local best_error_dis, best_pos, best_is_hit, best_is_miss, best_has_too_much_error = nil

		for _, accross_pos in ipairs(accross_positions) do
			local error_dis = math_abs(mvec3_dis(accross_pos[1], door_pos) - optimal_dis)
			local too_much_error = error_dis / optimal_dis > 0.3
			local is_hit = accross_pos[2]

			if best_is_hit then
				if is_hit then
					if error_dis < best_error_dis then
						best_pos = accross_pos[1]
						best_error_dis = error_dis
						best_has_too_much_error = too_much_error
					end
				elseif best_has_too_much_error then
					best_pos = accross_pos[1]
					best_error_dis = error_dis
					best_is_miss = true
					best_is_hit = nil
				end
			elseif best_is_miss then
				if not too_much_error then
					best_pos = accross_pos[1]
					best_error_dis = error_dis
					best_has_too_much_error = nil
					best_is_miss = nil
					best_is_hit = true
				end
			else
				best_pos = accross_pos[1]
				best_is_hit = is_hit
				best_is_miss = not is_hit
				best_has_too_much_error = too_much_error
				best_error_dis = error_dis
			end
		end

		managers.navigation:destroy_nav_tracker(door_tracker)

		return best_pos
	end

	managers.navigation:destroy_nav_tracker(door_tracker)
end

--[[function CopLogicTravel._get_pos_accross_door(guard_door, nav_seg, pos_rsrv_id)
	local rooms = guard_door.rooms
	local room_1_seg = guard_door.low_seg
	local accross_vec = guard_door.high_pos - guard_door.low_pos
	local rot_angle = 90

	if room_1_seg == nav_seg then
		if guard_door.low_pos.y == guard_door.high_pos.y then
			rot_angle = rot_angle * -1
		end
	elseif guard_door.low_pos.x == guard_door.high_pos.x then
		rot_angle = rot_angle * -1
	end

	mvec3_rotate_with(accross_vec, Rotation(rot_angle))

	local max_dis = 1500

	mvec3_set_length(accross_vec, 1500)

	local door_pos = guard_door.center
	local nav_manager = managers.navigation
	local door_tracker = nav_manager:create_nav_tracker(mvec3_cpy(door_pos))
	local accross_positions = nav_manager:find_walls_accross_tracker(door_tracker, accross_vec)

	if accross_positions then
		local optimal_dis = math_lerp(max_dis * 0.6, max_dis, math_random())
		local best_error_dis, best_pos, best_is_hit, best_is_miss, best_has_too_much_error = nil

		for _, accross_pos in ipairs(accross_positions) do
			local error_dis = math_abs(mvec3_dis(accross_pos[1], door_pos) - optimal_dis)
			local too_much_error = error_dis / optimal_dis > 0.3
			local is_hit = accross_pos[2]

			if best_is_hit then
				if is_hit then
					if error_dis < best_error_dis then
						local reservation = {
							radius = 30,
							position = accross_pos[1],
							filter = pos_rsrv_id
						}

						if nav_manager:is_pos_free(reservation) then
							best_pos = accross_pos[1]
							best_error_dis = error_dis
							best_has_too_much_error = too_much_error
						end
					end
				elseif best_has_too_much_error then
					local reservation = {
						radius = 30,
						position = accross_pos[1],
						filter = pos_rsrv_id
					}

					if nav_manager:is_pos_free(reservation) then
						best_pos = accross_pos[1]
						best_error_dis = error_dis
						best_is_miss = true
						best_is_hit = nil
					end
				end
			elseif best_is_miss then
				if not too_much_error then
					local reservation = {
						radius = 30,
						position = accross_pos[1],
						filter = pos_rsrv_id
					}

					if nav_manager:is_pos_free(reservation) then
						best_pos = accross_pos[1]
						best_error_dis = error_dis
						best_has_too_much_error = nil
						best_is_miss = nil
						best_is_hit = true
					end
				end
			else
				local reservation = {
					radius = 30,
					position = accross_pos[1],
					filter = pos_rsrv_id
				}

				if nav_manager:is_pos_free(reservation) then
					best_pos = accross_pos[1]
					best_is_hit = is_hit
					best_is_miss = not is_hit
					best_has_too_much_error = too_much_error
					best_error_dis = error_dis
				end
			end
		end

		managers.navigation:destroy_nav_tracker(door_tracker)

		return best_pos
	end

	managers.navigation:destroy_nav_tracker(door_tracker)
end]]

function CopLogicTravel.is_available_for_assignment(data, new_objective)
	if new_objective and new_objective.forced then
		return true
	elseif data.objective and data.objective.type == "act" then
		if not new_objective or new_objective.type == "free" then
			if data.objective.interrupt_dis == -1 then
				return true
			end
		end

		return
	else
		return CopLogicAttack.is_available_for_assignment(data, new_objective)
	end
end

function CopLogicTravel.is_advancing(data)
	local my_data = data.internal_data

	if my_data.advancing then
		return data.pos_rsrv.move_dest and data.pos_rsrv.move_dest.position or my_data.advancing:get_walk_to_pos()
	end
end

function CopLogicTravel._reserve_pos_along_vec(look_pos, wanted_pos)
	local step_vec = look_pos - wanted_pos
	local max_pos_mul = math_floor(mvec3_len(step_vec) / 65)

	mvec3_set_length(step_vec, 65)

	local data = {
		start_pos = wanted_pos,
		step_vec = step_vec,
		step_mul = max_pos_mul > 0 and 1 or -1,
		block = max_pos_mul == 0,
		max_pos_mul = max_pos_mul
	}
	local step_clbk = callback(CopLogicTravel, CopLogicTravel, "_rsrv_pos_along_vec_step_clbk", data)
	local res_data = managers.navigation:reserve_pos(nil, nil, wanted_pos, step_clbk, 60, data.pos_rsrv_id)

	return res_data
end

function CopLogicTravel._rsrv_pos_along_vec_step_clbk(shait, data, test_pos)
	local step_mul = data.step_mul
	local nav_manager = managers.navigation
	local step_vec = data.step_vec

	mvec3_set(test_pos, step_vec)
	mvec3_mul(test_pos, step_mul)
	mvec3_add(test_pos, data.start_pos)

	local params = {
		allow_entry = false,
		pos_from = data.start_pos,
		pos_to = test_pos
	}
	local blocked = nav_manager:raycast(params)

	if blocked then
		if data.block then
			return false
		end

		data.block = true

		if step_mul > 0 then
			data.step_mul = -step_mul
		else
			data.step_mul = -step_mul + 1

			if data.max_pos_mul < data.step_mul then
				return
			end
		end

		return CopLogicTravel._rsrv_pos_along_vec_step_clbk(shait, data, test_pos)
	elseif data.block then
		data.step_mul = step_mul + math_sign(step_mul)

		if data.max_pos_mul < data.step_mul then
			return
		end
	elseif step_mul > 0 then
		data.step_mul = -step_mul
	else
		data.step_mul = -step_mul + 1

		if data.max_pos_mul < data.step_mul then
			data.block = true
			data.step_mul = -data.step_mul
		end
	end

	return true
end

function CopLogicTravel._investigate_coarse_path_verify_clbk(shait, nav_seg)
	return managers.groupai:state():is_nav_seg_safe(nav_seg)
end

function CopLogicTravel.on_intimidated(data, amount, aggressor_unit)
	local surrender = CopLogicIdle.on_intimidated(data, amount, aggressor_unit)

	if surrender and data.objective then
		data.objective_failed_clbk(data.unit, data.objective)
	end
end

function CopLogicTravel._chk_request_action_walk_to_advance_pos(data, my_data, speed, end_rot, no_strafe, pose, end_pose)
	if not data.unit:movement():chk_action_forbidden("walk") or data.unit:anim_data().act_idle then
		CopLogicAttack._correct_path_start_pos(data, my_data.advance_path)

		local path = my_data.advance_path
		local new_action_data = {
			type = "walk",
			body_part = 2,
			nav_path = path,
			variant = speed or "run",
			end_rot = end_rot,
			path_simplified = my_data.path_is_precise,
			no_strafe = no_strafe,
			pose = pose,
			end_pose = end_pose
		}
		my_data.advance_path = nil
		my_data.starting_advance_action = true
		my_data.advancing = data.brain:action_request(new_action_data)
		my_data.starting_advance_action = false

		if my_data.advancing then
			data.brain:rem_pos_rsrv("path")

			if my_data.nearest_cover or my_data.best_cover then
				if not my_data.delayed_clbks or not my_data.delayed_clbks[my_data.cover_update_task_key] then
					CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t + 1)
				end
			end
		end
	end
end

function CopLogicTravel._determine_destination_occupation(data, objective)
	local occupation = nil

	if objective.type == "guard" then
		occupation = {
			type = "guard",
			from_seg = objective.nav_seg,
			door = objective.door
		}
	elseif objective.type == "defend_area" then
		if objective.cover then
			occupation = {
				type = "defend",
				seg = objective.nav_seg,
				cover = objective.cover,
				radius = objective.radius
			}
		elseif objective.pos then
			occupation = {
				type = "defend",
				seg = objective.nav_seg,
				pos = objective.pos,
				radius = objective.radius
			}
		else
			local near_pos = objective.follow_unit and objective.follow_unit:movement():nav_tracker():field_position()
			local dest_nav_seg = objective.nav_seg
			local cover = CopLogicTravel._find_cover(data, dest_nav_seg, near_pos)

			if cover then
				local cover_entry = {
					cover
				}
				occupation = {
					type = "defend",
					seg = objective.nav_seg,
					cover = cover_entry,
					radius = objective.radius
				}
			else
				near_pos = CopLogicTravel._get_pos_on_wall(managers.navigation._nav_segments[objective.nav_seg].pos, 700, nil, nil, data.pos_rsrv_id) ----
				occupation = {
					type = "defend",
					seg = objective.nav_seg,
					pos = near_pos,
					radius = objective.radius,
					pos_is_precise = true
				}
			end
		end
	elseif objective.type == "phalanx" then
		local logic = data.brain:get_logic_by_name(objective.type)

		logic.register_in_group_ai(data.unit)

		local phalanx_circle_pos = logic.calc_initial_phalanx_pos(data.m_pos, objective)
		occupation = {
			type = "defend",
			seg = objective.nav_seg,
			pos = phalanx_circle_pos,
			radius = objective.radius,
			pos_is_precise = true
		}
	elseif objective.type == "act" then
		occupation = {
			type = "act",
			seg = objective.nav_seg,
			pos = objective.pos
		}
	elseif objective.type == "follow" then
		local my_data = data.internal_data
		local dest_nav_seg_id = my_data.coarse_path[#my_data.coarse_path][1]
		local dest_area = managers.groupai:state():get_area_from_nav_seg_id(dest_nav_seg_id)
		local follow_pos, cover = nil

		if CopLogicTravel._needs_cover_at_destination(data, dest_area) then			
			local threat_pos, max_dist = nil
			follow_pos = objective.follow_unit:movement():nav_tracker():field_position()

			if data.attention_obj and data.attention_obj.nav_tracker and REACT_COMBAT <= data.attention_obj.reaction then
				threat_pos = data.attention_obj.nav_tracker:field_position()
			end

			if my_data.called then
				max_dist = 450
			end

			cover = managers.navigation:find_cover_in_nav_seg_3(dest_area.nav_segs, max_dist, follow_pos, threat_pos)
		end

		if cover then
			local cover_entry = {
				cover
			}
			occupation = {
				type = "defend",
				cover = cover_entry
			}
		else
			local max_dist = nil
			follow_pos = follow_pos or objective.follow_unit:movement():nav_tracker():field_position()

			if my_data.called then
				max_dist = 400
			else
				max_dist = 500
			end

			local to_pos = CopLogicTravel._get_pos_on_wall(follow_pos, max_dist, nil, nil, data.pos_rsrv_id)
			occupation = {
				type = "defend",
				pos = to_pos,
				pos_is_precise = true
			}
		end
	elseif objective.type == "revive" then
		local is_local_player = objective.follow_unit:base().is_local_player
		local revive_u_mv = objective.follow_unit:movement()
		local revive_u_tracker = revive_u_mv:nav_tracker()
		local revive_u_rot = is_local_player and Rotation(0, 0, 0) or revive_u_mv:m_rot()
		local revive_u_fwd = revive_u_rot:y()
		local revive_u_right = revive_u_rot:x()
		local revive_u_pos = revive_u_tracker:lost() and revive_u_tracker:field_position() or revive_u_mv:m_pos()
		local ray_params = {
			trace = true,
			tracker_from = revive_u_tracker
		}

		if revive_u_tracker:lost() then
			ray_params.pos_from = revive_u_pos
		end

		local stand_dis = nil

		if is_local_player or objective.follow_unit:base().is_husk_player then
			stand_dis = 120
		else
			stand_dis = 90
			local mid_pos = mvec3_cpy(revive_u_fwd)

			mvec3_mul(mid_pos, -20)
			mvec3_add(mid_pos, revive_u_pos)

			ray_params.pos_to = mid_pos
			local ray_res = managers.navigation:raycast(ray_params)
			revive_u_pos = ray_params.trace[1]
		end

		local rand_side_mul = math_random() > 0.5 and 1 or -1
		local revive_pos = mvec3_cpy(revive_u_right)

		mvec3_mul(revive_pos, rand_side_mul * stand_dis)
		mvec3_add(revive_pos, revive_u_pos)

		ray_params.pos_to = revive_pos
		local ray_res = managers.navigation:raycast(ray_params)

		if ray_res then
			local opposite_pos = mvec3_cpy(revive_u_right)

			mvec3_mul(opposite_pos, -rand_side_mul * stand_dis)
			mvec3_add(opposite_pos, revive_u_pos)

			ray_params.pos_to = opposite_pos
			local old_trace = ray_params.trace[1]
			local opposite_ray_res = managers.navigation:raycast(ray_params)

			if opposite_ray_res then
				if mvec3_dis(revive_pos, revive_u_pos) < mvec3_dis(ray_params.trace[1], revive_u_pos) then
					revive_pos = ray_params.trace[1]
				else
					revive_pos = old_trace
				end
			else
				revive_pos = ray_params.trace[1]
			end
		else
			revive_pos = ray_params.trace[1]
		end

		local revive_rot = revive_u_pos - revive_pos
		local revive_rot = Rotation(revive_rot, math_up)
		occupation = {
			type = "revive",
			pos = revive_pos,
			rot = revive_rot
		}
	else
		occupation = {
			seg = objective.nav_seg,
			pos = objective.pos
		}
	end

	return occupation
end

function CopLogicTravel._get_pos_on_wall(from_pos, max_dist, step_offset, is_recurse, pos_rsrv_id, too_same_dis)
	local nav_manager = managers.navigation
	local nr_rays = 7
	local ray_dis = max_dist or 1000
	local step = 360 / nr_rays
	local offset = step_offset or math_random(360)
	local step_rot = Rotation(step)
	local offset_rot = Rotation(offset)
	local offset_vec = Vector3(ray_dis, 0, 0)

	mvec3_rotate_with(offset_vec, offset_rot)

	local to_pos = mvec3_cpy(from_pos)

	mvec3_add(to_pos, offset_vec)

	local from_tracker = nav_manager:create_nav_tracker(from_pos)
	local ray_params = {
		allow_entry = false,
		trace = true,
		tracker_from = from_tracker,
		pos_to = to_pos
	}

	local rsrv_desc = nil

	if pos_rsrv_id then
		rsrv_desc = {
			radius = 60,
			filter = pos_rsrv_id
		}
	else
		rsrv_desc = {
			false,
			60
		}
	end

	local fail_position = nil

	repeat
		to_pos = mvec3_cpy(from_pos)

		mvec3_add(to_pos, offset_vec)

		ray_params.pos_to = to_pos
		local ray_res = nav_manager:raycast(ray_params)

		if ray_res then
			rsrv_desc.position = ray_params.trace[1]
			
			if not too_same_dis or too_same_dis < mvec3_dis(rsrv_desc.position, from_pos) then
				local is_free = nav_manager:is_pos_free(rsrv_desc)

				if is_free then
					nav_manager:destroy_nav_tracker(from_tracker)

					return ray_params.trace[1]
				end
			end
		elseif not fail_position then --no need to check for too_same here since that means the ray didnt even hit anything which means it'll almost definitely be a different pos
			rsrv_desc.position = ray_params.trace[1]
			local is_free = nav_manager:is_pos_free(rsrv_desc)

			if is_free then
				fail_position = ray_params.trace[1]
			end
		end

		mvec3_rotate_with(offset_vec, step_rot)

		nr_rays = nr_rays - 1
	until nr_rays == 0

	nav_manager:destroy_nav_tracker(from_tracker)

	if fail_position then
		return fail_position
	end

	if not is_recurse then
		return CopLogicTravel._get_pos_on_wall(from_pos, ray_dis * 0.5, offset + step * 0.5, true, pos_rsrv_id, too_same_dis and too_same_dis * 0.5 or nil)
	end

	return from_pos
end

function CopLogicTravel.queue_update(data, my_data, delay)
	delay = data.important and 0 or delay or 0
	
	local hostage_count = managers.groupai:state():get_hostage_count_for_chatter() --check current hostage count
	local chosen_panic_chatter = "controlpanic" --set default generic assault break chatter
	
	if hostage_count > 0 then --make sure the hostage count is actually above zero before replacing any of the lines
		if hostage_count > 3 then  -- hostage count needs to be above 3
			if math_random() < 0.4 then --40% chance for regular panic if hostages are present
				chosen_panic_chatter = "controlpanic"
			else
				chosen_panic_chatter = "hostagepanic2" --more panicky "GET THOSE HOSTAGES OUT RIGHT NOW!!!" line for when theres too many hostages on the map
			end
		else
			if math_random() < 0.4 then
				chosen_panic_chatter = "controlpanic"
			else
				chosen_panic_chatter = "hostagepanic1" --less panicky "Delay the assault until those hostages are out." line
			end
		end
			
		if managers.groupai:state():chk_has_civilian_hostages() then
			--log("they got sausages!")
			if math_random() < 0.5 then
				chosen_panic_chatter = chosen_panic_chatter
			else
				chosen_panic_chatter = "civilianpanic"
			end
		end
			
	elseif managers.groupai:state():chk_had_hostages() then
		if math_random() < 0.4 then
			chosen_panic_chatter = "controlpanic"
		else
			chosen_panic_chatter = "hostagepanic3" -- no more hostages!!! full force!!!
		end
	end
	
	local chosen_sabotage_chatter = "sabotagegeneric" --set default sabotage chatter for variety's sake
	local skirmish_map = managers.skirmish:is_skirmish()--these shouldnt play on holdout
	local ignore_radio_rules = nil
	
	if objective and objective.bagjob then
		--log("oh, worm")
		chosen_sabotage_chatter = "sabotagebags"
		ignore_radio_rules = true
	elseif objective and objective.hostagejob then
		--log("sausage removal squadron")
		chosen_sabotage_chatter = "sabotagehostages"
		ignore_radio_rules = true 
	else
		chosen_sabotage_chatter = "sabotagegeneric" --if none of these levels are the current one, use a generic "Break their gear!" line
	end
		
	local clear_t_chk = not data.attention_obj or not data.attention_obj.verified_t or data.attention_obj.verified_t - data.t > math_random(2.5, 5)	
		
	local cant_say_clear = not data.attention_obj or AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and clear_t_chk
		
	if not data.unit:base():has_tag("special") and not cant_say_clear and not data.is_converted then
		if data.unit:movement():cool() and data.char_tweak.chatter and data.char_tweak.chatter.clear_whisper then  
			local roll = math.rand(1, 100)
			local whistle_chance = 50
			if roll <= whistle_chance then
				managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "clear_whisper_2" )
				--log("whistle")
			else
				managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "clear_whisper" )
				--log("reporting")
			end
		elseif not data.unit:movement():cool() then
			if not managers.groupai:state():chk_assault_active_atm() then
				if data.char_tweak.chatter and data.char_tweak.chatter.controlpanic then
					local clearchk = math_random(0, 90)
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
				elseif data.char_tweak.chatter and data.char_tweak.chatter.clear then
					managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "clear" )
				end
			end
		end
	end
	
	if data.unit:base():has_tag("special") and not cant_say_clear then
		if data.unit:base():has_tag("tank") or data.unit:base():has_tag("taser") then
			managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "approachingspecial" )
		elseif data.unit:base()._tweak_table == "shield" then
			--fuck off
		elseif data.unit:base()._tweak_table == "akuma" then
			managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "lotusapproach" )
		end
	end
		
	--mid-assault panic for cops based on alerts instead of opening fire, since its supposed to be generic action lines instead of for opening fire and such
	--I'm adding some randomness to these since the delays in groupaitweakdata went a bit overboard but also arent able to really discern things proper
				
	if data.char_tweak and data.char_tweak.chatter and data.char_tweak.chatter.enemyidlepanic and not data.is_converted then
		if not data.unit:base():has_tag("special") and data.unit:base():has_tag("law") then
			if managers.groupai:state():chk_assault_active_atm() then
				if managers.groupai:state():_check_assault_panic_chatter() then
					if data.attention_obj and data.attention_obj.verified and data.attention_obj.dis <= 500 or data.is_suppressed and data.attention_obj and data.attention_obj.verified then
						local roll = math_random(1, 100)
						local chance_suppanic = 50
						
						if roll <= chance_suppanic then
							local nroll = math_random(1, 100)
							local chance_help = 50
							if roll <= chance_suppanic then
								managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanicsuppressed1" )
							else
								managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanicsuppressed2" )
							end
						else
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanic" )
						end
					else
						if math_random() < 0.2 then
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_sabotage_chatter )
						else
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanic" )
						end
					end
				else
					local clearchk = math_random(0, 90)
						
					if clearchk > 60 then
						if not skirmish_map and my_data.radio_voice or not skirmish_map and ignore_radio_rules then
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_sabotage_chatter )
						end
					elseif chosen_panic_chatter == "civilianpanic" then
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_panic_chatter )
					end
				end
			end
		elseif not data.unit:base():has_tag("special") and data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.verified_t or not data.unit:base():has_tag("special") and data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.alert_t then
		
			if data.attention_obj.verified and data.attention_obj.dis <= 500 or data.is_suppressed and data.attention_obj.verified then
				local roll = math_random(1, 100)
				local chance_suppanic = 50
						
				if roll <= chance_suppanic then
					local nroll = math_random(1, 100)
					local chance_help = 50
					if roll <= chance_suppanic then
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanicsuppressed1" )
					else
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanicsuppressed2" )
					end
				else
					managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanic" )
				end
			else
				managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanic" )
			end
			
		end	
	end

	CopLogicBase.queue_task(my_data, my_data.upd_task_key, CopLogicTravel.queued_update, data, data.t + delay, data.important and true)
end

function CopLogicTravel._try_anounce(data)
	local my_pos = data.m_pos
	local max_dis_sq = 250000
	local my_key = data.key
	local announce_type = data.char_tweak.announce_incomming
	local groupai_manager = managers.groupai:state()
	local say_chatter_func = groupai_manager.chk_say_enemy_chatter
	local found_announcer = nil

	for u_key, u_data in pairs_g(managers.enemy:all_enemies()) do
		if u_key ~= my_key and u_data.char_tweak.chatter and u_data.char_tweak.chatter[announce_type] and mvec3_dis_sq(my_pos, u_data.m_pos) < max_dis_sq and not u_data.unit:sound():speaking(data.t) then
			if u_data.unit:anim_data().idle or u_data.unit:anim_data().move then
				if say_chatter_func(groupai_manager, u_data.unit, u_data.m_pos, announce_type) then
					data.announce_t = data.t + 15

					break
				end
			end
		end
	end

	if not found_announcer then
		data.announce_t = data.t + 2
	end
end

function CopLogicTravel._get_all_paths(data)
	return {
		advance_path = data.internal_data.advance_path
	}
end

function CopLogicTravel._set_verified_paths(data, verified_paths)
	data.internal_data.advance_path = verified_paths.advance_path
end

function CopLogicTravel.chk_should_turn(data, my_data)
	if not my_data.advancing and not my_data.turning and not my_data.has_old_action then
		if not my_data.coarse_path or my_data.coarse_path_index < #my_data.coarse_path - 1 or not data.objective.rot then
			if not data.unit:movement():chk_action_forbidden("turn") then
				return true
			end
		end
	end
end

function CopLogicTravel.complete_coarse_path(data, my_data, coarse_path)
	local first_seg_id = coarse_path[1][1]
	local current_seg_id = data.unit:movement():nav_tracker():nav_segment()
	local all_nav_segs = managers.navigation._nav_segments

	if not coarse_path[1][2] then
		coarse_path[1][2] = mvec3_cpy(all_nav_segs[first_seg_id].pos)
	end

	if first_seg_id ~= current_seg_id then
		table_insert(coarse_path, 1, {
			current_seg_id,
			mvec3_cpy(data.m_pos)
		})
	end

	local i_nav_point = 1

	while i_nav_point < #coarse_path do
		local nav_seg_id = coarse_path[i_nav_point][1]
		local next_nav_seg_id = coarse_path[i_nav_point + 1][1]
		local nav_seg = all_nav_segs[nav_seg_id]

		if not nav_seg.neighbours[next_nav_seg_id] then
			local search_params = {
				id = "CopLogicTravel_complete_coarse_path",
				from_seg = nav_seg_id,
				to_seg = next_nav_seg_id,
				access_pos = data.SO_access
			}
			local ins_coarse_path = managers.navigation:search_coarse(search_params)

			if not ins_coarse_path then
				my_data.coarse_path = nil

				return
			end

			local i_insert = #ins_coarse_path - 1

			while i_insert > 1 do
				table_insert(coarse_path, i_nav_point + 1, ins_coarse_path[i_insert])

				i_insert = i_insert - 1
			end
		end

		i_nav_point = i_nav_point + 1
	end

	if #coarse_path == 1 then
		table_insert(coarse_path, 1, {
			current_seg_id,
			mvec3_cpy(data.m_pos)
		})
	end

	local start_index = nil

	for i, nav_point in ipairs(coarse_path) do
		if current_seg_id == nav_point[1] then
			start_index = i
		end
	end

	if start_index then
		start_index = math_min(start_index, #coarse_path - 1)

		return start_index
	end

	local to_search_segs = {
		current_seg_id
	}
	local found_segs = {
		[current_seg_id] = "init"
	}

	repeat
		local search_seg_id = table_remove(to_search_segs, 1)
		local search_seg = all_nav_segs[search_seg_id]

		for other_seg_id, door_list in pairs_g(search_seg.neighbours) do
			local other_seg = all_nav_segs[other_seg_id]

			if not other_seg.disabled and not found_segs[other_seg_id] then
				found_segs[other_seg_id] = search_seg_id

				if other_seg_id == first_seg_id then
					local last_added_seg_id = other_seg_id

					while found_segs[last_added_seg_id] ~= "init" do
						last_added_seg_id = found_segs[last_added_seg_id]

						table_insert(coarse_path, 1, {
							last_added_seg_id,
							all_nav_segs[last_added_seg_id].pos
						})
					end

					return 1
				else
					table_insert(to_search_segs, other_seg_id)
				end
			end
		end
	until #to_search_segs == 0

	return 1
end

function CopLogicTravel._chk_close_to_criminal(data, my_data)
	if my_data.close_to_criminal ~= nil then
		return my_data.close_to_criminal
	end

	if data.cool then
		my_data.close_to_criminal = false
	else
		local verify_u_key = nil
		local allied_with_criminals = data.is_converted or data.unit:in_slot(16)

		if not allied_with_criminals then
			local player_team = tweak_data.levels:get_default_team_ID("player")

			if data.team.id == player_team or data.team.friends[player_team] then
				allied_with_criminals = true
				verify_u_key = data.key
			end
		end

		local my_area = managers.groupai:state():get_area_from_nav_seg_id(data.unit:movement():nav_tracker():nav_segment())

		if allied_with_criminals then
			local police_units = my_area.police.units

			if next_g(police_units) then
				if not verify_u_key then
					my_data.close_to_criminal = true
				else
					for u_key, u_data in pairs_g(police_units) do
						if u_key ~= verify_u_key then
							my_data.close_to_criminal = true

							break
						end
					end
				end
			elseif verify_u_key then
				for _, nbr in pairs_g(my_area.neighbours) do
					local neighbor_police_units = nbr.police.units

					if next_g(neighbor_police_units) then
						for u_key, u_data in pairs_g(neighbor_police_units) do
							if u_key ~= verify_u_key then
								my_data.close_to_criminal = true

								break
							end
						end
					end
				end
			else
				for _, nbr in pairs_g(my_area.neighbours) do
					if next_g(nbr.police.units) then
						my_data.close_to_criminal = true

						break
					end
				end
			end
		elseif next_g(my_area.criminal.units) then
			my_data.close_to_criminal = true
		else
			for _, nbr in pairs_g(my_area.neighbours) do
				if next_g(nbr.criminal.units) then
					my_data.close_to_criminal = true

					break
				end
			end
		end
	end

	return my_data.close_to_criminal
end

function CopLogicTravel.chk_group_ready_to_move(data, my_data)
	local my_objective = data.objective

	if not my_objective.grp_objective then
		return true
	end

	local my_dis = mvec3_dis_sq(my_objective.area.pos, data.m_pos)

	if my_dis > 4000000 then
		return true
	end

	my_dis = my_dis * 1.15 * 1.15

	for u_key, u_data in pairs_g(data.group.units) do
		if u_key ~= data.key then
			local teammate_obj = u_data.unit:brain():objective()

			if teammate_obj and teammate_obj.grp_objective == my_objective.grp_objective and not teammate_obj.in_place then
				local teammate_dis_to_obj = mvec3_dis_sq(teammate_obj.area.pos, u_data.m_pos)

				if my_dis < teammate_dis_to_obj then
					return false
				end
			end
		end
	end

	return true
end

function CopLogicTravel.apply_wall_offset_to_cover(data, my_data, cover, wall_fwd_offset)
	local to_pos_fwd = tmp_vec1

	mvec3_set(to_pos_fwd, cover[2])
	mvec3_mul(to_pos_fwd, wall_fwd_offset)
	mvec3_add(to_pos_fwd, cover[1])

	local ray_params = {
		trace = true,
		tracker_from = cover[3],
		pos_to = to_pos_fwd
	}
	local collision = managers.navigation:raycast(ray_params)

	if not collision then
		return cover[1]
	end

	local col_pos_fwd = ray_params.trace[1]
	local space_needed = mvec3_dis(col_pos_fwd, to_pos_fwd) + wall_fwd_offset * 1.05
	local to_pos_bwd = tmp_vec2

	mvec3_set(to_pos_bwd, cover[2])
	mvec3_mul(to_pos_bwd, -space_needed)
	mvec3_add(to_pos_bwd, cover[1])

	local ray_params = {
		trace = true,
		tracker_from = cover[3],
		pos_to = to_pos_bwd
	}
	local collision = managers.navigation:raycast(ray_params)

	return collision and ray_params.trace[1] or mvec3_cpy(to_pos_bwd)
end

function CopLogicTravel._find_cover(data, search_nav_seg, near_pos)
	if data.cool then
		return
	end

	local allied_with_criminals = data.is_converted or data.unit:in_slot(16)

	if not allied_with_criminals then
		local player_team = tweak_data.levels:get_default_team_ID("player")

		if data.team.id == player_team or data.team.friends[player_team] then
			allied_with_criminals = true
		end
	end

	local search_area = managers.groupai:state():get_area_from_nav_seg_id(search_nav_seg)
	local optimal_threat_dis, threat_pos = nil

	if data.objective and data.objective.attitude == "engage" then
		optimal_threat_dis = data.internal_data.weapon_range.optimal
	else
		optimal_threat_dis = data.internal_data.weapon_range.far
	end

	near_pos = near_pos or search_area.pos

	if not allied_with_criminals then
		local groupai_manager = managers.groupai:state()
		local all_criminals = groupai_manager:all_char_criminals()
		local get_area_func = groupai_manager.get_area_from_nav_seg_id
		local closest_crim_u_data, closest_crim_dis = nil

		for u_key, u_data in pairs_g(all_criminals) do
			local crim_area = get_area_func(groupai_manager, u_data.tracker:nav_segment())

			if crim_area == search_area then
				threat_pos = u_data.m_pos

				break
			else
				local crim_dis = mvec3_dis_sq(near_pos, u_data.m_pos)

				if not closest_crim_dis or crim_dis < closest_crim_dis then
					threat_pos = u_data.m_pos
					closest_crim_dis = crim_dis
				end
			end
		end
	end

	return managers.navigation:find_cover_from_threat(search_area.nav_segs, optimal_threat_dis, near_pos, threat_pos)
end

function CopLogicTravel._get_allowed_travel_nav_segs(data, my_data, to_pos)
	local nav_segs = {}
	local added_segs = {}
	local all_nav_segs = managers.navigation._nav_segments
	local chk_enabled_neighbor_segs_func = CopLogicTravel._chk_enabled_neighbor_segs

	for _, nav_point in ipairs(my_data.coarse_path) do
		local area = managers.groupai:state():get_area_from_nav_seg_id(nav_point[1])

		for nav_seg_id, _ in pairs_g(area.nav_segs) do
			local id_to_add = nav_seg_id

			if all_nav_segs[id_to_add].disabled then
				id_to_add = chk_enabled_neighbor_segs_func(id_to_add)
			end

			if not added_segs[nav_seg_id] then
				added_segs[nav_seg_id] = true

				table_insert(nav_segs, id_to_add)
			end
		end
	end

	local end_nav_seg = managers.navigation:get_nav_seg_from_pos(to_pos, true)

	if all_nav_segs[end_nav_seg].disabled then
		end_nav_seg = chk_enabled_neighbor_segs_func(end_nav_seg)
	end

	local end_area = managers.groupai:state():get_area_from_nav_seg_id(end_nav_seg)

	for nav_seg_id, _ in pairs_g(end_area.nav_segs) do
		local id_to_add = nav_seg_id

		if all_nav_segs[id_to_add].disabled then
			id_to_add = chk_enabled_neighbor_segs_func(id_to_add)
		end

		if not added_segs[nav_seg_id] then
			added_segs[nav_seg_id] = true

			table_insert(nav_segs, id_to_add)
		end
	end

	local standing_nav_seg = data.unit:movement():nav_tracker():nav_segment()

	if all_nav_segs[standing_nav_seg].disabled then
		standing_nav_seg = chk_enabled_neighbor_segs_func(standing_nav_seg)
	end

	if not added_segs[standing_nav_seg] then
		table_insert(nav_segs, standing_nav_seg)

		added_segs[standing_nav_seg] = true
	end

	return nav_segs
end

function CopLogicTravel._chk_enabled_neighbor_segs(disabled_seg)
	local new_neighbor_seg = nil
	local enabled_alt_segs = {}
	local all_nav_segs = managers.navigation._nav_segments
	local disabled_segment = all_nav_segs[disabled_seg]

	for other_seg_id, _ in pairs_g(disabled_segment.neighbours) do
		local other_seg = all_nav_segs[other_seg_id]

		if not other_seg.disabled and not enabled_alt_segs[other_seg_id] then
			table_insert(enabled_alt_segs, other_seg_id)
		end
	end

	if next_g(enabled_alt_segs) then
		if #enabled_alt_segs > 1 then
			new_neighbor_seg = enabled_alt_segs[math_random(#enabled_alt_segs)]
		else
			new_neighbor_seg = enabled_alt_segs[1]
		end
	end

	return new_neighbor_seg or disabled_seg
end

function CopLogicTravel._check_start_path_ahead(data)
	local my_data = data.internal_data

	if my_data.processing_advance_path then
		return
	end

	local objective = data.objective
	local coarse_path = my_data.coarse_path
	local next_index = my_data.coarse_path_index + 2
	local total_nav_points = #coarse_path

	if next_index > total_nav_points then
		return
	end

	local from_pos = data.pos_rsrv.move_dest.position
	local to_pos = data.logic._get_exact_move_pos(data, next_index)
	local unobstructed_line = nil

	if math_abs(from_pos.z - to_pos.z) < 40 then
		local ray_params = {
			allow_entry = false,
			pos_from = from_pos,
			pos_to = to_pos
		}

		if not managers.navigation:raycast(ray_params) then
			unobstructed_line = true
		end
	end

	if unobstructed_line then
		my_data.advance_path = {
			mvec3_cpy(from_pos),
			mvec3_cpy(to_pos)
		}

		return
	end

	--my_data.pathing_to_pos = to_pos
	my_data.processing_advance_path = true
	local prio = data.logic.get_pathing_prio(data)
	local nav_segs = CopLogicTravel._get_allowed_travel_nav_segs(data, my_data, to_pos)

	data.brain:search_for_path_from_pos(my_data.advance_path_search_id, from_pos, to_pos, prio, nil, nav_segs)
end

function CopLogicTravel.get_pathing_prio(data)
	local prio = nil
	local objective = data.objective

	if objective then
		prio = 0 --disable if it ends up hindering performance (since it makes the search faster, but without being prioritized over the other ones below)

		if objective.type == "phalanx" then
			prio = 4
		elseif objective.follow_unit then
			if objective.follow_unit:base().is_local_player or objective.follow_unit:base().is_husk_player or managers.groupai:state():is_unit_team_AI(objective.follow_unit) then
				prio = 4
			end
		end
	end

	if data.is_converted or data.unit:in_slot(16) then
		prio = prio or 0

		prio = prio + 2
	elseif data.team.id == tweak_data.levels:get_default_team_ID("player") then
		prio = prio or 0

		prio = prio + 1
	end

	return prio
end

function CopLogicTravel._get_exact_move_pos(data, nav_index)
	local my_data = data.internal_data
	local objective = data.objective
	local to_pos = nil
	local coarse_path = my_data.coarse_path
	local total_nav_points = #coarse_path
	local reservation, wants_reservation = nil

	if total_nav_points <= nav_index then
		local new_occupation = data.logic._determine_destination_occupation(data, objective)

		if new_occupation then
			if new_occupation.type == "guard" then
				local guard_door = new_occupation.door
				local guard_pos = CopLogicTravel._get_pos_accross_door(guard_door, objective.nav_seg)

				if guard_pos then
					reservation = CopLogicTravel._reserve_pos_along_vec(guard_door.center, guard_pos)

					if reservation then
						local guard_object = {
							type = "door",
							door = guard_door,
							from_seg = new_occupation.from_seg
						}
						objective.guard_obj = guard_object
						to_pos = reservation.pos
					end
				end
			elseif new_occupation.type == "defend" then
				if new_occupation.cover then
					to_pos = new_occupation.cover[1][1]

					if data.char_tweak.wall_fwd_offset then
						to_pos = CopLogicTravel.apply_wall_offset_to_cover(data, my_data, new_occupation.cover[1], data.char_tweak.wall_fwd_offset)
					end

					local new_cover = new_occupation.cover

					managers.navigation:reserve_cover(new_cover[1], data.pos_rsrv_id)

					my_data.moving_to_cover = new_cover
				elseif new_occupation.pos then
					to_pos = new_occupation.pos

					if not new_occupation.pos_is_precise then
						local pos_rsrv_id = data.pos_rsrv_id
						local rsrv_desc = {
							position = to_pos,
							radius = 60,
							filter = pos_rsrv_id
						}

						if not managers.navigation:is_pos_free(rsrv_desc) then
							to_pos = CopLogicTravel._get_pos_on_wall(to_pos, 700, nil, nil, pos_rsrv_id)
						end
					end
				end

				wants_reservation = true
			elseif new_occupation.type == "act" then
				to_pos = new_occupation.pos
				wants_reservation = true
			elseif new_occupation.type == "revive" then
				to_pos = new_occupation.pos
				objective.rot = new_occupation.rot
				wants_reservation = true
			else
				to_pos = new_occupation.pos

				if to_pos then
					local pos_rsrv_id = data.pos_rsrv_id
					local rsrv_desc = {
						position = to_pos,
						radius = 60,
						filter = pos_rsrv_id
					}

					if not managers.navigation:is_pos_free(rsrv_desc) then
						to_pos = CopLogicTravel._get_pos_on_wall(to_pos, 700, nil, nil, pos_rsrv_id)
					end

					wants_reservation = true
				end
			end
		end

		if not to_pos then
			to_pos = managers.navigation:find_random_position_in_segment(objective.nav_seg)
			local pos_rsrv_id = data.pos_rsrv_id
			local rsrv_desc = {
				position = to_pos,
				radius = 60,
				filter = pos_rsrv_id
			}

			if not managers.navigation:is_pos_free(rsrv_desc) then
				to_pos = CopLogicTravel._get_pos_on_wall(to_pos, nil, nil, nil, pos_rsrv_id)
			end

			wants_reservation = true
		end
	else
		local nav_seg = coarse_path[nav_index][1]
		local area = managers.groupai:state():get_area_from_nav_seg_id(nav_seg)
		local cover = CopLogicTravel._needs_cover_at_destination(data, area) and managers.navigation:find_cover_in_nav_seg_1(area.nav_segs)

		if my_data.moving_to_cover then
			managers.navigation:release_cover(my_data.moving_to_cover[1])

			my_data.moving_to_cover = nil
		end

		if cover then
			to_pos = cover[1]

			if data.char_tweak.wall_fwd_offset then
				to_pos = CopLogicTravel.apply_wall_offset_to_cover(data, my_data, cover, data.char_tweak.wall_fwd_offset)
			end

			managers.navigation:reserve_cover(cover, data.pos_rsrv_id)

			my_data.moving_to_cover = {
				cover
			}
		else
			to_pos = coarse_path[nav_index][2]
			local pos_rsrv_id = data.pos_rsrv_id
			local rsrv_desc = {
				position = to_pos,
				radius = 60,
				filter = pos_rsrv_id
			}

			if not managers.navigation:is_pos_free(rsrv_desc) then
				to_pos = CopLogicTravel._get_pos_on_wall(to_pos, 700, nil, nil, pos_rsrv_id)
			end
		end

		wants_reservation = true
	end

	if not reservation and wants_reservation then
		data.brain:add_pos_rsrv("path", {
			radius = 60,
			position = mvec3_cpy(to_pos)
		})
	end

	return to_pos
end

function CopLogicTravel._needs_cover_at_destination(data, dest_area)
	if data.cool then
		return false
	end

	local verify_u_key = nil
	local allied_with_criminals = data.is_converted or data.unit:in_slot(16)

	if not allied_with_criminals then
		local player_team = tweak_data.levels:get_default_team_ID("player")

		if data.team.id == player_team or data.team.friends[player_team] then
			allied_with_criminals = true
			verify_u_key = data.key
		end
	end

	if allied_with_criminals then
		local police_units = dest_area.police.units

		if next_g(police_units) then
			if not verify_u_key then
				return true
			else
				for u_key, u_data in pairs_g(police_units) do
					if u_key ~= verify_u_key then
						return true
					end
				end
			end
		elseif verify_u_key then
			for _, nbr in pairs_g(dest_area.neighbours) do
				local neighbor_police_units = nbr.police.units

				if next_g(neighbor_police_units) then
					for u_key, u_data in pairs_g(neighbor_police_units) do
						if u_key ~= verify_u_key then
							return true
						end
					end
				end
			end
		else
			for _, nbr in pairs_g(dest_area.neighbours) do
				if next_g(nbr.police.units) then
					return true
				end
			end
		end
	elseif next_g(dest_area.criminal.units) then
		return true
	else
		for _, nbr in pairs_g(dest_area.neighbours) do
			if next_g(nbr.criminal.units) then
				return true
			end
		end
	end

	return false
end

function CopLogicTravel._on_destination_reached(data)
	local objective = data.objective
	objective.in_place = true

	if objective.type == "free" then
		if not objective.action_duration then
			data.objective_complete_clbk(data.unit, objective)

			return
		end
	elseif objective.type == "flee" then
		data.brain:set_active(false)
		data.unit:base():set_slot(data.unit, 0)

		return
	elseif objective.type == "defend_area" then
		if objective.grp_objective and objective.grp_objective.type == "retire" then
			data.brain:set_active(false)
			data.unit:base():set_slot(data.unit, 0)

			return
		else
			managers.groupai:state():on_defend_travel_end(data.unit, objective)
		end
	end

	data.logic.on_new_objective(data)
end

function CopLogicTravel._on_revive_destination_reached_by_warp(data, my_data, warp_back)
	CopLogicTravel._on_destination_reached(data)
end

function CopLogicTravel._chk_start_pathing_to_next_nav_point(data, my_data)
	if not CopLogicTravel.chk_group_ready_to_move(data, my_data) then
		return
	end

	local my_pos = data.unit:movement():nav_tracker():field_position()
	local to_pos = CopLogicTravel._get_exact_move_pos(data, my_data.coarse_path_index + 1)
	local unobstructed_line = nil

	if math_abs(my_pos.z - to_pos.z) < 40 then
		local ray_params = {
			allow_entry = false,
			pos_from = my_pos,
			pos_to = to_pos
		}

		if not managers.navigation:raycast(ray_params) then
			unobstructed_line = true
		end
	end

	if unobstructed_line then
		my_data.advance_path = {
			mvec3_cpy(my_pos),
			to_pos
		}

		--[[local line = Draw:brush(Color.blue:with_alpha(0.5), 5)
		line:cylinder(my_pos, to_pos, 25)]]

		if data.cool or CopLogicTravel.chk_group_ready_to_move(data, my_data) then
			CopLogicTravel._chk_begin_advance(data, my_data)
		end

		if my_data.advancing and my_data.path_ahead then
			CopLogicTravel._check_start_path_ahead(data)
		end

		return
	end

	--my_data.pathing_to_pos = to_pos
	my_data.processing_advance_path = true
	local prio = data.logic.get_pathing_prio(data)
	local nav_segs = CopLogicTravel._get_allowed_travel_nav_segs(data, my_data, to_pos)

	data.brain:search_for_path(my_data.advance_path_search_id, to_pos, prio, nil, nav_segs)
end

function CopLogicTravel._begin_coarse_pathing(data, my_data)
	local verify_clbk = nil

	if my_data.path_safely then
		verify_clbk = callback(CopLogicTravel, CopLogicTravel, "_investigate_coarse_path_verify_clbk")
	end

	local nav_seg = nil

	if data.objective.follow_unit then
		nav_seg = data.objective.follow_unit:movement():nav_tracker():nav_segment()
	else
		nav_seg = data.objective.nav_seg
	end

	if data.brain:search_for_coarse_path(my_data.coarse_path_search_id, nav_seg, verify_clbk) then
		my_data.processing_coarse_path = true

		--[[local area = managers.groupai:state():get_area_from_nav_seg_id(nav_seg)

		my_data.pathing_to_pos_coarse = area and area.pos]]
	end
end

function CopLogicTravel._chk_begin_advance(data, my_data)
	if data.unit:movement():chk_action_forbidden("walk") then
		return
	end

	local objective = data.objective
	local haste = nil

	if objective and objective.haste then
		haste = objective.haste
	elseif data.unit:movement():cool() then
		haste = "walk"
	else
		haste = "run"
	end

	local pose = data.is_suppressed and "crouch" or objective and objective.pose or "stand"

	if pose == "crouch" then
		if not data.char_tweak.crouch_move then
			pose = "stand"
		elseif not data.is_suppressed and not CopLogicTravel._chk_close_to_criminal(data, my_data) then
			pose = "stand"
		end
	end

	local end_pose = my_data.moving_to_cover and "crouch"

	if data.char_tweak.allowed_poses then
		if not data.char_tweak.allowed_poses.crouch then
			pose = "stand"

			if end_pose then
				end_pose = "stand"
			end
		elseif not data.char_tweak.allowed_poses.stand then
			pose = "crouch"

			if end_pose then
				end_pose = "crouch"
			end
		end
	end

	if not data.unit:anim_data()[pose] then
		CopLogicAttack["_chk_request_action_" .. pose](data)
	end

	local end_rot = nil

	if my_data.coarse_path_index >= #my_data.coarse_path - 1 then
		end_rot = objective and objective.rot
	end

	local no_strafe = data.char_tweak.no_strafe or objective and objective.no_strafe

	CopLogicTravel._chk_request_action_walk_to_advance_pos(data, my_data, haste, end_rot, no_strafe, pose, end_pose)
end

function CopLogicTravel._chk_stop_for_follow_unit(data, my_data)
	local objective = data.objective

	if objective.type ~= "follow" or data.unit:movement():chk_action_forbidden("walk") or data.unit:anim_data().act_idle then
		return
	end

	if not my_data.coarse_path_index then
		--debug_pause_unit(data.unit, "[CopLogicTravel._chk_stop_for_follow_unit]", data.unit, inspect(data), inspect(my_data))

		return
	end

	local follow_unit_nav_seg = data.objective.follow_unit:movement():nav_tracker():nav_segment()

	if follow_unit_nav_seg ~= my_data.coarse_path[my_data.coarse_path_index + 1][1] or my_data.coarse_path_index ~= #my_data.coarse_path - 1 then
		local my_nav_seg = data.unit:movement():nav_tracker():nav_segment()

		if follow_unit_nav_seg == my_nav_seg then
			objective.in_place = true

			data.logic.on_new_objective(data)
		end
	end
end

function CopLogicTravel._chk_target_area(data, my_data) ----eventually try reenabling
	local objective = data.objective

	if objective and objective.type == "defend_area" and objective.grp_objective then
		if objective.grp_objective.type == "assault_area" or objective.grp_objective.type == "defend_area" then
			if CopLogicTravel._chk_close_to_criminal(data, my_data) then
				--data.objective_failed_clbk(data.unit, data.objective)
				local my_seg = data.unit:movement():nav_tracker():nav_segment()
				local my_area = managers.groupai:state():get_area_from_nav_seg_id(my_seg)
				objective.in_place = true
				objective.nav_seg = my_seg
				objective.area = my_area
				objective.pos = nil

				return true
			end
		end
	end
end
