--[[CopLogicArrest = class(CopLogicBase)
CopLogicArrest.on_alert = CopLogicIdle.on_alert
CopLogicArrest.on_intimidated = CopLogicIdle.on_intimidated
CopLogicArrest.on_new_objective = CopLogicIdle.on_new_objective]]

local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_cpy = mvector3.copy

local math_lerp = math.lerp
local math_random = math.random
local math_abs = math.abs
local math_clamp = math.clamp
local math_min = math.min
local math_max = math.max

local REACT_IDLE = AIAttentionObject.REACT_IDLE
local REACT_AIM = AIAttentionObject.REACT_AIM
local REACT_ARREST = AIAttentionObject.REACT_ARREST
local REACT_COMBAT = AIAttentionObject.REACT_COMBAT
local REACT_SCARED = AIAttentionObject.REACT_SCARED
local REACT_SHOOT = AIAttentionObject.REACT_SHOOT
local REACT_SUSPICIOUS = AIAttentionObject.REACT_SUSPICIOUS
local REACT_SPECIAL_ATTACK = AIAttentionObject.REACT_SPECIAL_ATTACK

local world = World

local is_local_vr = _G.IS_VR

function CopLogicArrest.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.brain:cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit,
		detection = data.char_tweak.detection.guard
	}

	if old_internal_data then
		my_data.turning = old_internal_data.turning
		my_data.shooting = old_internal_data.shooting
		my_data.attention_unit = old_internal_data.attention_unit

		if old_internal_data.firing then
			data.unit:movement():set_allow_fire(false)
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

	local objective = data.objective

	--[[if objective and CopLogicIdle._chk_objective_needs_travel(data, objective) then
		CopLogicBase._exit(data.unit, "travel")

		return
	end]]

	if data.cool then
		data.unit:movement():set_cool(false)

		if my_data ~= data.internal_data then
			return
		end
	end

	if not my_data.shooting then
		local new_stance = "hos"

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

	CopLogicIdle._chk_has_old_action(data, my_data)

	my_data.arrest_targets = {}
	my_data.next_action_delay_t = data.t + math_lerp(2, 2.5, math_random())

	local key_str = tostring(data.key)
	my_data.update_task_key = "CopLogicArrest.queued_update" .. key_str

	CopLogicBase.queue_task(my_data, my_data.update_task_key, CopLogicArrest.queued_update, data, data.t, data.important and true)

	if my_data.nearest_cover or my_data.best_cover then
		my_data.cover_update_task_key = "CopLogicArrest._update_cover" .. key_str

		CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t + 1)
	end

	if objective then
		if objective.action_duration or objective.action_timeout_t and data.t < objective.action_timeout_t then
			my_data.action_timeout_clbk_id = "CopLogicIdle_action_timeout" .. key_str
			local action_timeout_t = objective.action_timeout_t or data.t + objective.action_duration
			objective.action_timeout_t = action_timeout_t

			CopLogicBase.add_delayed_clbk(my_data, my_data.action_timeout_clbk_id, callback(CopLogicIdle, CopLogicIdle, "clbk_action_timeout", data), action_timeout_t)
		end
	end

	if not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.stand then
		if not data.unit:anim_data().stand then
			CopLogicAttack._chk_request_action_stand(data)
		end
	end

	my_data.weapon_range = data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range

	data.brain:set_attention_settings({
		cbt = true
	})
	data.brain:set_update_enabled_state(false)
end

function CopLogicArrest.exit(data, new_logic_name, enter_params)
	CopLogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	data.brain:cancel_all_pathing_searches()
	CopLogicBase.cancel_queued_tasks(my_data)
	CopLogicBase.cancel_delayed_clbks(my_data)

	if my_data.best_cover then
		managers.navigation:release_cover(my_data.best_cover[1])
	end

	if my_data.nearest_cover then
		managers.navigation:release_cover(my_data.nearest_cover[1])
	end

	if my_data.arrest_targets then
		for u_key, enemy_arrest_data in pairs(my_data.arrest_targets) do
			managers.groupai:state():on_arrest_end(data.key, u_key)
		end
	end

	CopLogicArrest._chk_stop_ongoing_call(data, my_data)

	--[[if my_data.calling_the_police then
		managers.groupai:state():on_criminal_suspicion_progress(nil, data.unit, "call_interrupted")
	end]]

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

	data.brain:rem_pos_rsrv("path")
	data.brain:set_update_enabled_state(true)
end

function CopLogicArrest.queued_update(data)
	data.t = TimerManager:game():time()
	local my_data = data.internal_data

	local delay = CopLogicArrest._upd_enemy_detection(data)

	if my_data ~= data.internal_data then
		return
	end

	if my_data.has_old_action then
		--CopLogicIdle._upd_stop_old_action(data, my_data, data.objective
		CopLogicAttack._upd_stop_old_action(data, my_data)
		
		if my_data.has_old_action then
			CopLogicBase.queue_task(my_data, my_data.update_task_key, CopLogicArrest.queued_update, data, data.t + delay, data.important and true)

			return
		end
	end

	local attention_obj = data.attention_obj
	local arrest_data = attention_obj and my_data.arrest_targets[attention_obj.u_key]

	if not arrest_data or arrest_data.intro_t then
		if attention_obj and REACT_ARREST <= attention_obj.reaction then
			if not my_data.shooting and not data.unit:anim_data().reload and not data.unit:movement():chk_action_forbidden("action") then
				local shoot_action = {
					body_part = 3,
					type = "shoot"
				}

				if data.brain:action_request(shoot_action) then
					my_data.shooting = true
				end
			end
		elseif my_data.shooting then
			local idle_action = {
				body_part = 3,
				type = "idle"
			}

			data.brain:action_request(idle_action)
		end
	end

	if arrest_data then
		if not arrest_data.intro_t then
			if arrest_data.tase_arrest then
				arrest_data.intro_t = data.t
				arrest_data.intro_pos = mvec3_cpy(attention_obj.m_pos)
			else
				local facing_arrest_target = nil
				local turn_angle = CopLogicIdle._chk_turn_needed(data, my_data, data.m_pos, attention_obj.m_pos)

				if not turn_angle or math_abs(turn_angle) < 5 then
					facing_arrest_target = true
				elseif not my_data.turning and not my_data.advancing and not data.unit:movement():chk_action_forbidden("walk") then
					CopLogicIdle._turn_by_spin(data, my_data, turn_angle)
				end

				if facing_arrest_target and not data.unit:sound():speaking(data.t) then
					arrest_data.intro_t = data.t

					data.unit:sound():say("i01", true)

					if not attention_obj.is_human_player then
						attention_obj.unit:brain():on_intimidated(1, data.unit)
					end

					if not data.unit:movement():chk_action_forbidden("action") then
						local new_action = {
							variant = "cmd_stop",
							align_sync = true,
							body_part = 1,
							type = "act"
						}

						if data.brain:action_request(new_action) then
							my_data.gesture_arrest = true
						end
					end
				end
			end
		elseif not arrest_data.intro_pos and data.t - arrest_data.intro_t > 1 then
			arrest_data.intro_pos = mvec3_cpy(attention_obj.m_pos)
		end
	end

	if arrest_data and arrest_data.intro_pos or my_data.should_stand_close then
		CopLogicArrest._upd_advance(data, my_data, attention_obj, arrest_data)
	end

	if attention_obj and not my_data.turning and not my_data.advancing and not data.unit:movement():chk_action_forbidden("walk") then
		CopLogicIdle._chk_request_action_turn_to_look_pos(data, my_data, data.m_pos, attention_obj.m_pos)
	end

	CopLogicBase.queue_task(my_data, my_data.update_task_key, CopLogicArrest.queued_update, data, data.t + delay, data.important and true)
end

function CopLogicArrest._upd_advance(data, my_data, attention_obj, arrest_data)
	local action_taken = my_data.turning or data.unit:movement():chk_action_forbidden("walk")

	if arrest_data and my_data.should_arrest then
		if attention_obj.dis < 180 then
			if not action_taken then
				if arrest_data.tase_arrest then
					if not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch then
						if not data.unit:anim_data().crouch then
							CopLogicAttack._chk_request_action_crouch(data)
						end
					end

					if attention_obj.dis < 150 then
						if my_data.advancing then
							local action_data = {
								body_part = 1,
								type = "idle"
							}

							data.brain:action_request(action_data)
						end

						attention_obj.unit:movement():on_cuffed()
						data.unit:sound():say("i03", true, false)

						return
					end
				else
					if not data.unit:anim_data().idle_full_blend then
						if attention_obj.dis < 150 and not data.unit:anim_data().idle then
							local action_data = {
								body_part = 1,
								type = "idle"
							}

							data.brain:action_request(action_data)
						end
					elseif not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch then
						if not data.unit:anim_data().crouch then
							CopLogicAttack._chk_request_action_crouch(data)
						end
					end

					if data.unit:anim_data().idle_full_blend then
						attention_obj.unit:movement():on_cuffed()
						data.unit:sound():say("i03", true, false)

						return
					end
				end
			end
		elseif not arrest_data.tase_arrest and not arrest_data.said_approach and attention_obj.dis < 600 and attention_obj.dis > 500 and not data.unit:sound():speaking(data.t) then
			arrest_data.said_approach = true

			data.unit:sound():say("i02", true)
		end
	--elseif my_data.should_stand_close and attention_obj.dis < 300 and not data.unit:sound():speaking(data.t) then
		--CopLogicArrest._chk_say_approach(data, my_data, attention_obj)
	end

	if action_taken or my_data.advancing then
		return
	end

	local tase_arrest = arrest_data and arrest_data.tase_arrest

	if my_data.advance_path then
		if tase_arrest or my_data.next_action_delay_t < data.t then
			CopLogicArrest._start_advancing(data, my_data, tase_arrest)
		end
	elseif my_data.processing_path then
		CopLogicArrest._process_pathing_results(data, my_data)
	elseif not my_data.in_position then
		if tase_arrest or my_data.next_action_delay_t < data.t then
			if my_data.should_arrest then
				local my_pos = data.unit:movement():nav_tracker():field_position()
				local att_field_pos = attention_obj.nav_tracker:field_position()
				local near_pos = CopLogicTravel._get_pos_on_wall(att_field_pos, 150, nil, nil, data.pos_rsrv_id)
				local unobstructed_line = nil

				if math_abs(my_pos.z - near_pos.z) < 40 then
					local ray_params = {
						allow_entry = false,
						pos_from = my_pos,
						pos_to = near_pos
					}
					if not managers.navigation:raycast(ray_params) then
						unobstructed_line = true
					end
				end

				if unobstructed_line then
					my_data.advance_path = {
						mvec3_cpy(my_pos),
						near_pos
					}
					CopLogicArrest._start_advancing(data, my_data, tase_arrest)
				else
					data.brain:add_pos_rsrv("path", {
						radius = 60,
						position = mvec3_cpy(near_pos)
					})

					my_data.path_search_id = "cuff" .. tostring(data.key)
					my_data.processing_path = true

					data.brain:search_for_path(my_data.path_search_id, near_pos, 1)
				end
			elseif my_data.should_stand_close and attention_obj then
				CopLogicArrest._say_scary_stuff_discovered(data)

				local close_pos = CopLogicArrest._get_att_obj_close_pos(data, my_data)

				if close_pos then
					local my_pos = data.unit:movement():nav_tracker():field_position()
					local unobstructed_line = nil

					if math_abs(my_pos.z - close_pos.z) < 40 then
						local ray_params = {
							allow_entry = false,
							pos_from = my_pos,
							pos_to = close_pos
						}
						if not managers.navigation:raycast(ray_params) then
							unobstructed_line = true
						end
					end

					if unobstructed_line then
						my_data.advance_path = {
							mvec3_cpy(my_pos),
							close_pos
						}
						CopLogicArrest._start_advancing(data, my_data, tase_arrest)
					else
						data.brain:add_pos_rsrv("path", {
							radius = 60,
							position = mvec3_cpy(close_pos)
						})

						my_data.path_search_id = "stand_close" .. tostring(data.key)
						my_data.processing_path = true

						data.brain:search_for_path(my_data.path_search_id, close_pos, 1, nil)
					end
				else
					my_data.in_position = true
				end
			--else
				--debug_pause_unit(data.unit, "not sure what I am supposed to do", data.unit, inspect(data.attention_obj), inspect(my_data))
			end
		end
	end
end

function CopLogicArrest._start_advancing(data, my_data, is_tase_arrest)
	if not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.stand then
		if not data.unit:anim_data().stand then
			CopLogicAttack._chk_request_action_stand(data)
		end
	end

	CopLogicAttack._correct_path_start_pos(data, my_data.advance_path)

	local new_action_data = {
		variant = is_tase_arrest and "run" or "walk",
		body_part = 2,
		type = "walk",
		pose = "stand",
		nav_path = my_data.advance_path
	}
	my_data.advance_path = nil
	my_data.advancing = data.brain:action_request(new_action_data)

	if my_data.advancing then
		data.brain:rem_pos_rsrv("path")
	end
end

function CopLogicArrest._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	local my_data = data.internal_data
	local delay = CopLogicBase._upd_attention_obj_detection(data, REACT_SUSPICIOUS, nil)

	CopLogicArrest._verify_arrest_targets(data, my_data)

	local new_attention, new_prio_slot, new_reaction = CopLogicArrest._get_priority_attention(data, data.detected_attention_objects)

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)

	local arrest_targets = my_data.arrest_targets
	local should_arrest = new_reaction == REACT_ARREST
	local should_stand_close = new_reaction == REACT_SCARED or new_attention and new_attention.criminal_record and new_attention.criminal_record.status --and new_attention.criminal_record.status ~= "electrified"

	if should_arrest ~= my_data.should_arrest or should_stand_close ~= my_data.should_stand_close then
		my_data.should_arrest = should_arrest
		my_data.should_stand_close = should_stand_close

		CopLogicArrest._cancel_advance(data, my_data)
	end

	if should_arrest and not my_data.arrest_targets[new_attention.u_key] then
		my_data.arrest_targets[new_attention.u_key] = {
			attention_obj = new_attention
			--tase_arrest = new_attention.criminal_record and new_attention.criminal_record.status == "electrified" and true
		}

		managers.groupai:state():on_arrest_start(data.key, new_attention.u_key)
	end

	CopLogicArrest._mark_call_in_event(data, my_data, new_attention)

	if not should_arrest then
		CopLogicArrest._chk_say_discovery(data, my_data, new_attention)

		if not my_data.should_stand_close then
			my_data.in_position = true
		end
	end

	local current_attention = data.unit:movement():attention()

	if new_attention and not current_attention or current_attention and not new_attention or new_attention and current_attention.u_key ~= new_attention.u_key then
		if new_attention then
			CopLogicBase._set_attention(data, new_attention)
		else
			CopLogicBase._reset_attention(data)
		end
	end

	if new_reaction == AIAttentionObject.REACT_ARREST then ----replace these with the local reacts
		if not managers.groupai:state():is_police_called() and CopLogicArrest._chk_already_calling_in_area(data) then
			CopLogicArrest._ask_call_the_police(data) ----fix
		end
	elseif data.char_tweak.calls_in then
		if not new_reaction or new_reaction < AIAttentionObject.REACT_SHOOT or not new_attention.verified or new_attention.dis >= 1500 then
			if my_data.in_position or not my_data.should_arrest and not my_data.should_stand_close then
				if my_data.calling_the_police then
					if CopLogicArrest._chk_already_calling_in_area(data) then
						CopLogicArrest._chk_stop_ongoing_call(data, my_data)
					end
				elseif not my_data.turning and not managers.groupai:state():is_police_called() and not data.unit:sound():speaking(data.t) then
					if CopLogicArrest._chk_already_calling_in_area(data) then
						CopLogicArrest._ask_call_the_police(data)
					elseif my_data.next_action_delay_t < data.t and not data.unit:movement():chk_action_forbidden("action") then
						CopLogicArrest._call_the_police(data, my_data)
					end
				end
			end
		end
	end

	if not my_data.called_the_police then ----fix
		local wanted_state = CopLogicBase._get_logic_state_from_reaction(data)

		if wanted_state and wanted_state ~= data.name then
			if not my_data.calling_the_police or wanted_state == "attack" then
				CopLogicArrest._chk_stop_ongoing_call(data, my_data)
				CopLogicBase._exit(data.unit, wanted_state)
			end
		end
	end

	CopLogicBase._report_detections(data.detected_attention_objects)

	return delay
end

function CopLogicArrest._chk_already_calling_in_area(data, custom_area)
	--[[local area_to_check = custom_area

	if not area_to_check then
		local my_cur_nav_seg = data.unit:movement():nav_tracker():nav_segment()
		area_to_check = managers.groupai:state():get_area_from_nav_seg_id(my_cur_nav_seg)
	end

	if not area_to_check or not managers.groupai:state():chk_enemy_calling_in_area(area_to_check, data.key) then
		return false
	end

	return true

	local already_calling_in_area = false
	local my_head_pos = data.unit:movement():m_head_pos()
	local nearby_units = world:find_units_quick(data.unit, "sphere", my_head_pos, 1000, managers.slot:get_mask("enemies"))

	if #nearby_units > 0 then
		for _, unit in pairs(nearby_units) do
			if unit:base() and unit:base():char_tweak() and unit:base():char_tweak().calls_in then
				local vis_ray = data.unit:raycast("ray", my_head_pos, unit:, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision", "report")

				if vis_ray then
					already_calling_in_area = true

					break
				end
			end
		end
	end]]

	local already_calling_in_area = false

	for u_key, attention_info in pairs(data.detected_attention_objects) do
		if attention_info.identified and attention_info.verified and attention_info.is_person and attention_info.is_alive and attention_info.char_tweak and attention_info.char_tweak.calls_in and attention_info.dis < 1000 then
			local att_brain_ext = attention_info.unit:brain()

			if att_brain_ext and att_brain_ext._current_logic_name == "arrest" then
				if not att_brain_ext._logic_data.attention_obj or att_brain_ext._logic_data.attention_obj.reaction ~= REACT_ARREST then
					already_calling_in_area = true

					break
				end
			end
		end
	end

	return already_calling_in_area
end

function CopLogicArrest._chk_stop_ongoing_call(data, my_data)
	if my_data.calling_the_police then
		local action_data = {
			body_part = 3,
			type = "idle"
		}

		data.brain:action_request(action_data)
	end
end

function CopLogicArrest._chk_reaction_to_attention_object(data, attention_data, stationary)
	local att_reaction = attention_data.settings.reaction

	if attention_data.is_deployable then
		return math_min(att_reaction, REACT_COMBAT)
	end

	local record = attention_data.criminal_record

	if not record or not attention_data.is_person then
		if att_reaction == REACT_ARREST then
			return REACT_AIM
		end

		return att_reaction
	end

	if record.status == "dead" then
		return math_min(att_reaction, REACT_AIM)
	--[[elseif record.status == "electrified" then
		local chk_tase_arrest = nil

		if record.being_arrested then
			if record.being_arrested[data.key] then
				chk_tase_arrest = true
			else
				return math_min(att_reaction, REACT_AIM)
			end
		else
			chk_tase_arrest = true
		end

		if chk_tase_arrest then
			if not attention_data.aimed_at or not attention_data.dmg_t or data.t > attention_data.dmg_t + 1 then
				return math_min(att_reaction, REACT_ARREST)
			end
		end]]
	elseif record.status == "disabled" then
		if data.tactics and data.tactics.murder then
			return math_min(att_reaction, REACT_COMBAT)
		end

		if not record.assault_t then
			return math_min(att_reaction, REACT_AIM)
		end

		local disable_t_chk = 0.6

		if attention_data.is_husk_player then
			disable_t_chk = disable_t_chk / tweak_data.timespeed.downed.speed
		end

		if record.assault_t - record.disabled_t > disable_t_chk then
			return math_min(att_reaction, REACT_COMBAT)
		end

		return math_min(att_reaction, REACT_AIM)
	elseif record.being_arrested then
		if record.being_arrested[data.key] then
			return math_min(att_reaction, REACT_ARREST)
		end

		return math_min(att_reaction, REACT_AIM)
	elseif not record.status and CopLogicBase._can_arrest(data) and data.t > record.arrest_timeout then
		if not record.assault_t or attention_data.unit:base():arrest_settings().aggression_timeout < data.t - record.assault_t then
			local under_threat = nil

			if attention_data.dis < 2000 then
				for u_key, other_crim_rec in pairs(managers.groupai:state():all_criminals()) do
					local other_crim_attention_info = data.detected_attention_objects[u_key]

					if other_crim_attention_info and other_crim_attention_info.verified then
						if other_crim_attention_info.is_deployable then
							under_threat = true

							break
						else
							local other_crim_was_not_aggressive = not other_crim_rec.assault_t or other_crim_rec.unit:base():arrest_settings().aggression_timeout < data.t - other_crim_rec.assault_t

							if not other_crim_was_not_aggressive then
								under_threat = true

								break
							end
						end
					end
				end
			end

			if not under_threat then
				if attention_data.verified and attention_data.dis < 2000 then
					return math_min(att_reaction, REACT_ARREST)
				end

				return math_min(att_reaction, REACT_AIM)
			end
		end
	end

	return math_min(att_reaction, REACT_COMBAT)
end

function CopLogicArrest._verify_arrest_targets(data, my_data)
	local all_attention_objects = data.detected_attention_objects
	local arrest_targets = my_data.arrest_targets
	local group_ai = managers.groupai:state()

	for u_key, arrest_data in pairs(arrest_targets) do
		local drop, penalty = nil
		local record = group_ai:criminal_record(u_key)

		if record then
			if arrest_data.intro_pos and mvec3_dis_sq(arrest_data.attention_obj.m_pos, arrest_data.intro_pos) > 28900 then
				drop = true
				penalty = true
			elseif arrest_data.intro_t and record.assault_t and record.assault_t > arrest_data.intro_t + 0.6 then
				drop = true
				penalty = true
			elseif record.status or data.t < record.arrest_timeout then
				--if record.status ~= "electrified" then
					drop = true
				--end
			elseif all_attention_objects[u_key] ~= arrest_data.attention_obj then
				drop = true
			elseif not arrest_data.attention_obj.identified then
				drop = true

				if arrest_data.intro_pos then
					penalty = true
				end
			end
		end

		if drop then
			if penalty then
				record.arrest_timeout = data.t + arrest_data.attention_obj.unit:base():arrest_settings().arrest_timeout
			end

			group_ai:on_arrest_end(data.key, u_key)

			arrest_targets[u_key] = nil
		end
	end
end

function CopLogicArrest.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action:type()

	if action_type == "walk" then
		my_data.advancing = nil

		if action:expired() then
			my_data.next_action_delay_t = TimerManager:game():time() + math_lerp(2, 2.5, math_random())

			if my_data.should_stand_close then
				my_data.in_position = true
			end
		end
	elseif action_type == "shoot" then
		my_data.shooting = nil
	elseif action_type == "turn" then
		my_data.turning = nil ----make arrest gesture turning work like how bots do it for intimidation
	elseif action_type == "act" then
		if my_data.gesture_arrest then
			my_data.gesture_arrest = nil
		elseif my_data.calling_the_police then
			my_data.calling_the_police = nil

			if not my_data.called_the_police then
				managers.groupai:state():on_criminal_suspicion_progress(nil, data.unit, "call_interrupted")
				data.unit:sound():stop()
			end
		end

		my_data.next_action_delay_t = TimerManager:game():time() + math_lerp(2, 2.5, math_random())
	elseif action_type == "hurt" or action_type == "healed" then
		if action:expired() then
			CopLogicBase.chk_start_action_dodge(data, "hit")
		end

		if not my_data.exiting then
			local wanted_state = CopLogicBase._get_logic_state_from_reaction(data)

			if wanted_state and wanted_state ~= data.name then
				CopLogicBase._exit(data.unit, wanted_state)
			end
		end
	elseif action_type == "dodge" then
		local timeout = action:timeout()

		if timeout then
			data.dodge_timeout_t = TimerManager:game():time() + math_lerp(timeout[1], timeout[2], math_random())
		end

		if not my_data.exiting then
			local wanted_state = CopLogicBase._get_logic_state_from_reaction(data)

			if wanted_state and wanted_state ~= data.name then
				CopLogicBase._exit(data.unit, wanted_state)
			end
		end
	end
end

function CopLogicArrest.damage_clbk(data, damage_info) ----further tweak
	local my_data = data.internal_data

	CopLogicIdle.damage_clbk(data, damage_info)

	if my_data ~= data.internal_data then
		return
	end

	local attacker = damage_info.attacker_unit

	if alive(attacker) then
		local attacker_u_key = attacker:key()
		local record = managers.groupai:state():criminal_record(attacker_u_key)

		if managers.groupai:state():whisper_mode() then
			local arrest_data = my_data.arrest_targets[attacker_u_key]

			if arrest_data then
				managers.groupai:state():on_arrest_end(data.key, attacker_u_key)

				my_data.arrest_targets[attacker_u_key] = nil

				--[[if record then
					record.arrest_timeout = data.t + attacker:base():arrest_settings().arrest_timeout
				end]]
			end
		elseif record then
			for enemy_key, arrest_data in pairs(my_data.arrest_targets) do
				managers.groupai:state():on_arrest_end(data.key, enemy_key)

				my_data.arrest_targets[enemy_key] = nil

				local e_record = managers.groupai:state():criminal_record(enemy_key)

				if e_record then
					e_record.arrest_timeout = data.t + arrest_data.attention_obj.unit:base():arrest_settings().arrest_timeout
				end
			end
		end
	end

	if my_data.call_in_event == "criminal" then
		if not data.attention_obj or data.attention_obj.reaction < REACT_SCARED then
			local weapon_unit = damage_info.weapon_unit

			if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().battery_life_multiplier then
				my_data.call_in_event = "ecm_feedback"
			end
		end
	end
end

function CopLogicArrest.on_alert(data, alert_data)
	local my_data = data.internal_data

	CopLogicIdle.on_alert(data, alert_data)

	if my_data ~= data.internal_data then
		return
	end

	if my_data.call_in_event == "criminal" then
		if not data.attention_obj or data.attention_obj.reaction < REACT_SCARED then
			if alert_data[1] == "fire" then
				my_data.call_in_event = "fire"
			else
				local alert_unit = alert_data[5]

				if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().battery_life_multiplier then
					my_data.call_in_event = "ecm_feedback"
				end
			end
		end
	end
end

function CopLogicArrest.on_detected_enemy_destroyed(data, enemy_unit)
end

function CopLogicArrest.is_available_for_assignment(data, objective)
	if objective and objective.forced then
		return true
	end

	return false
end

function CopLogicArrest.on_criminal_neutralized(data, criminal_key)
	local record = managers.groupai:state():criminal_record(criminal_key)
	local my_data = data.internal_data

	if record.status == "dead" or record.status == "removed" then
		if my_data.arrest_targets[criminal_key] then
			managers.groupai:state():on_arrest_end(data.key, criminal_key)
		end

		my_data.arrest_targets[criminal_key] = nil
	elseif --[[record.status ~= "electrified" and]] my_data.arrest_targets[criminal_key] and my_data.arrest_targets[criminal_key].intro_pos then
		my_data.arrest_targets[criminal_key].intro_pos = mvec3_cpy(my_data.arrest_targets[criminal_key].attention_obj.m_pos)
		my_data.arrest_targets[criminal_key].intro_t = TimerManager:game():time()
	end
end

function CopLogicArrest._call_the_police(data, my_data, panicked)
	local action = {
		variant = "arrest_call",
		align_sync = true,
		body_part = 1,
		type = "act",
		blocks = {
			aim = -1,
			action = -1,
			walk = -1
		}
	}
	my_data.calling_the_police = data.unit:movement():action_request(action)

	if my_data.calling_the_police then
		managers.groupai:state():on_criminal_suspicion_progress(nil, data.unit, "calling")
		CopLogicArrest._say_call_the_police(data, my_data)
	end
end

function CopLogicArrest._get_priority_attention(data, attention_objects, reaction_func)
	reaction_func = reaction_func or CopLogicArrest._chk_reaction_to_attention_object
	local best_target, best_target_priority_slot, best_target_priority, best_target_reaction = nil
	local near_threshold = data.internal_data.weapon_range.optimal
	local too_close_threshold = data.internal_data.weapon_range.close

	local closest_chico_target, closest_chico_dis, reac = nil

	for record_key, record_data in pairs(managers.groupai:state():all_player_criminals()) do
		local att_data = data.detected_attention_objects[record_key]
		local valid_chico_target = nil

		if att_data and att_data.verified then
			local reaction = reaction_func(data, att_data, not CopLogicAttack._can_move(data))

			if reaction and reaction >= REACT_COMBAT then
				if att_data.is_local_player then
					if managers.player:has_activate_temporary_upgrade("temporary", "chico_injector") and managers.player:upgrade_value("player", "chico_preferred_target", false) then
						reac = reaction
						valid_chico_target = true
					end
				elseif att_data.is_husk_player then
					local u_base = att_data.unit:base()

					if u_base.upgrade_value and u_base.has_activate_temporary_upgrade and u_base:has_activate_temporary_upgrade("temporary", "chico_injector") and u_base:upgrade_value("player", "chico_preferred_target") then
						reac = reaction
						valid_chico_target = true
					end
				end
			end
		end

		if valid_chico_target then
			if not closest_chico_dis or att_data.dis < closest_chico_dis then
				closest_chico_dis = att_data.dis
				closest_chico_target = att_data
			end
		end
	end

	if closest_chico_target then
		local aimed_at = CopLogicIdle.chk_am_i_aimed_at(data, closest_chico_target, closest_chico_target.aimed_at and 0.95 or 0.985)
		closest_chico_target.aimed_at = aimed_at

		return closest_chico_target, 1, reac
	end

	for u_key, attention_data in pairs(attention_objects) do
		local att_unit = attention_data.unit

		if attention_data.identified then
			if attention_data.pause_expire_t then
				if attention_data.pause_expire_t < data.t then
					if not attention_data.settings.attract_chance or math_random() < attention_data.settings.attract_chance then
						attention_data.pause_expire_t = nil
					else
						--debug_pause_unit(data.unit, "[ CopLogicIdle._get_priority_attention] skipping attraction")

						attention_data.pause_expire_t = data.t + math_lerp(attention_data.settings.pause[1], attention_data.settings.pause[2], math_random())
					end
				end
			elseif attention_data.stare_expire_t and attention_data.stare_expire_t < data.t then
				if attention_data.settings.pause then
					attention_data.stare_expire_t = nil
					attention_data.pause_expire_t = data.t + math_lerp(attention_data.settings.pause[1], attention_data.settings.pause[2], math_random())
				end
			else
				local distance = mvec3_dis(data.m_pos, attention_data.m_pos)
				local reaction = reaction_func(data, attention_data, not CopLogicAttack._can_move(data))
				local reaction_too_mild = nil

				if not reaction or best_target_reaction and reaction < best_target_reaction then
					reaction_too_mild = true
				elseif distance < 150 and reaction == REACT_IDLE then
					reaction_too_mild = true
				end

				if not reaction_too_mild then
					local arrest_targets = data.internal_data.arrest_targets
					local is_target_to_arrest = nil

					if reaction == REACT_ARREST and reaction == best_target_reaction and arrest_targets[best_target.u_key] and arrest_targets[best_target.u_key].intro_t then
						if not arrest_targets[u_key] or not arrest_targets[u_key].intro_t then
							is_target_to_arrest = true
						end
					end

					if is_target_to_arrest then
						best_target = attention_data
						best_target_reaction = reaction
						best_target_priority_slot = 7
						best_target_priority = distance
					else
						local weight_mul = attention_data.settings.weight_mul or 1
						local visible = attention_data.verified
						local alert_dt = attention_data.alert_t and data.t - attention_data.alert_t or 10000
						local dmg_dt = attention_data.dmg_t and data.t - attention_data.dmg_t or 10000
						local target_priority = nil
						local target_priority_slot = 0

						if visible then
							local aimed_at = CopLogicIdle.chk_am_i_aimed_at(data, attention_data, attention_data.aimed_at and 0.95 or 0.985)
							attention_data.aimed_at = aimed_at

							local crim_record = attention_data.criminal_record

							--[[if reaction == REACT_ARREST and crim_record and crim_record.status == "electrified" then
								return attention_data, 1, reaction
							end]]

							if attention_data.is_local_player then
								local cur_state = att_unit:movement():current_state()

								if not cur_state._moving and cur_state:ducking() then
									weight_mul = weight_mul * managers.player:upgrade_value("player", "stand_still_crouch_camouflage_bonus", 1)
								end

								if is_local_vr and tweak_data.vr.long_range_damage_reduction_distance[1] < distance then
									local mul = math_clamp(distance / tweak_data.vr.long_range_damage_reduction_distance[2] / 2, 0, 1) + 1
									weight_mul = weight_mul * mul
								end
							elseif attention_data.is_husk_player then
								local att_base_ext = att_unit:base()

								if att_base_ext and att_base_ext.upgrade_value then
									local att_move_ext = att_unit:movement()

									if att_move_ext and not att_move_ext._move_data and att_move_ext._pose_code and att_move_ext._pose_code == 2 then
										local mul = att_base_ext:upgrade_value("player", "stand_still_crouch_camouflage_bonus")

										if mul then
											weight_mul = weight_mul * mul
										end
									end

									if att_move_ext.is_vr and att_move_ext:is_vr() and tweak_data.vr.long_range_damage_reduction_distance[1] < distance then
										local mul = math_clamp(distance / tweak_data.vr.long_range_damage_reduction_distance[2] / 2, 0, 1) + 1
										weight_mul = weight_mul * mul
									end
								end
							end

							if weight_mul and weight_mul ~= 1 then
								weight_mul = 1 / weight_mul
								alert_dt = alert_dt and alert_dt * weight_mul
								dmg_dt = dmg_dt and dmg_dt * weight_mul
								distance = distance * weight_mul
							end

							target_priority = distance

							local status = crim_record and crim_record.status
							local free_status = status == nil

							if free_status then
								if distance < too_close_threshold and math_abs(attention_data.m_pos.z - data.m_pos.z) < 250 then
									if reaction == REACT_SPECIAL_ATTACK then
										target_priority_slot = 1
									else
										target_priority_slot = 2
									end
								elseif reaction == REACT_SPECIAL_ATTACK or distance < near_threshold then
									target_priority_slot = 3
								else
									target_priority_slot = 4
								end
							else
								target_priority_slot = 5
							end

							local has_damaged = dmg_dt < 5

							if has_damaged then
								target_priority_slot = target_priority_slot - 2
							else
								local has_alerted = alert_dt < 3.5

								if has_alerted then
									target_priority_slot = target_priority_slot - 1
								end
							end

							if data.attention_obj and data.attention_obj.u_key == u_key then
								if not attention_data.acquire_t then
									log("arrest: no acquire_t defined somehow")

									local my_unit = data.unit

									if not alive(my_unit) then
										log("arrest: unit was destroyed!")
									elseif my_unit:in_slot(0) then
										log("arrest: unit is being destroyed!")
									else
										log("arrest: unit is still intact on the C side")

										local my_base_ext = my_unit:base()

										if not my_base_ext then
											log("arrest: unit has no base() extension")
										elseif my_base_ext._tweak_table then
											log("arrest: unit has tweak table: " .. tostring(my_base_ext._tweak_table) .. "")
										else
											log("arrest: unit has no tweak table")
										end

										local my_dmg_ext = my_unit:character_damage()

										if not my_dmg_ext then
											log("arrest: unit has no character_damage() extension")
										elseif my_dmg_ext.dead and att_dmg_ext:dead() then
											log("arrest: unit is dead")
										end
									end

									local cur_logic_name = data.name

									if cur_logic_name ~= "arrest" then
										log("arrest: unit was in a different logic! Logic name: " .. tostring(cur_logic_name) .. "")
									end

									local att_unit = data.attention_obj.unit

									if not alive(att_unit) then
										log("arrest: attention unit was destroyed!")
									elseif att_unit:in_slot(0) then
										log("arrest: attention unit is being destroyed!")
									else
										log("arrest: attention unit is still intact on the C side")

										local unit_name = att_unit.name and att_unit:name()

										if unit_name then
											--might be pure gibberish
											log("arrest: attention unit name: " .. tostring(unit_name) .. "")
										end

										if att_unit:id() == -1 then
											log("arrest: attention unit was detached from the network")
										end

										local att_base_ext = att_unit:base()

										if not att_base_ext then
											log("arrest: attention unit has no base() extension")
										elseif att_base_ext._tweak_table then
											log("arrest: attention unit has tweak table: " .. tostring(att_base_ext._tweak_table) .. "")
										elseif att_base_ext.is_husk_player then
											log("arrest: attention unit was a player husk")
										elseif att_base_ext.is_local_player then
											log("arrest: attention unit was the local player")
										end

										local att_dmg_ext = att_unit:character_damage()

										if not att_dmg_ext then
											log("arrest: attention unit has no character_damage() extension")
										elseif att_dmg_ext.dead and att_dmg_ext:dead() then
											log("arrest: attention unit is dead")
										end
									end

									local cam_pos = managers.viewport:get_current_camera_position()

									if cam_pos then
										local from_pos = cam_pos + math.DOWN * 50

										local brush = Draw:brush(Color.red:with_alpha(0.5), 10)
										brush:cylinder(from_pos, data.unit:movement():m_com(), 10)
									end
								elseif data.t - attention_data.acquire_t < 4 then --old enemy
									target_priority_slot = target_priority_slot - 3
								end
							end

							local reviving = nil

							if attention_data.is_local_player then
								local iparams = att_unit:movement():current_state()._interact_params

								if iparams and managers.criminals:character_name_by_unit(iparams.object) ~= nil then
									reviving = true
								end
							else
								reviving = att_unit:anim_data() and att_unit:anim_data().revive
							end

							if reviving then
								target_priority_slot = target_priority_slot + 2
							end

							local nr_enemies = crim_record and crim_record.engaged_force

							if nr_enemies then
								if nr_enemies < 5 then
									target_priority_slot = target_priority_slot - 1
								elseif nr_enemies > 20 then
									target_priority_slot = target_priority_slot + 2
								elseif nr_enemies > 10 then
									target_priority_slot = target_priority_slot + 1
								end
							end

							target_priority_slot = math_clamp(target_priority_slot, 1, 10)
						else
							target_priority_slot = 10

							if weight_mul and weight_mul ~= 1 then
								weight_mul = 1 / weight_mul
								alert_dt = alert_dt and alert_dt * weight_mul
								dmg_dt = dmg_dt and dmg_dt * weight_mul
								distance = distance * weight_mul
							end

							target_priority = distance

							local has_damaged = dmg_dt < 5

							if has_damaged then
								target_priority_slot = target_priority_slot - 2
							else
								local has_alerted = alert_dt < 3.5

								if has_alerted then
									target_priority_slot = target_priority_slot - 1
								end
							end
						end

						if reaction < REACT_COMBAT then
							target_priority_slot = 10 + target_priority_slot + math_max(0, REACT_COMBAT - reaction)
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
		end
	end

	return best_target, best_target_priority_slot, best_target_reaction
end

function CopLogicArrest._process_pathing_results(data, my_data)
	if data.pathing_results then
		for path_id, path in pairs(data.pathing_results) do
			if path_id == my_data.path_search_id then
				if path ~= "failed" then
					my_data.advance_path = path
				--else
					--print("[CopLogicArrest._process_pathing_results] advance path failed")
				end

				my_data.processing_path = nil
				my_data.path_search_id = nil
			end
		end

		data.pathing_results = nil
	end
end

function CopLogicArrest._cancel_advance(data, my_data)
	if my_data.processing_path then
		if data.active_searches[my_data.path_search_id] then
			managers.navigation:cancel_pathing_search(my_data.path_search_id)

			data.active_searches[my_data.path_search_id] = nil
		elseif data.pathing_results then
			data.pathing_results[my_data.path_search_id] = nil
		end

		my_data.processing_path = nil
		my_data.path_search_id = nil
	end

	my_data.advance_path = nil

	if my_data.advancing then
		local action_data = {
			body_part = 2,
			type = "idle"
		}

		data.brain:action_request(action_data)
	end

	my_data.in_position = false
end

function CopLogicArrest._get_att_obj_close_pos(data, my_data)
	local att_obj_pos = nil

	if data.attention_obj.nav_tracker then
		att_obj_pos = data.attention_obj.nav_tracker:field_position()
	else
		local nav_manager = managers.navigation
		local temp_tracker = nav_manager:create_nav_tracker(data.attention_obj.m_pos)

		att_obj_pos = mvec3_cpy(temp_tracker:field_position())

		nav_manager:destroy_nav_tracker(temp_tracker)
	end

	local my_dis = mvec3_dis(data.m_pos, att_obj_pos)
	local optimal_dis = 150 + math_random() * 100

	if my_dis > optimal_dis * 0.8 and my_dis < optimal_dis * 1.2 then
		return false
	end

	local pos_on_wall = CopLogicTravel._get_pos_on_wall(att_obj_pos, optimal_dis, nil, nil, data.pos_rsrv_id)

	return pos_on_wall
end

function CopLogicArrest._say_scary_stuff_discovered(data) ----check
	if not data.attention_obj then
		return
	end

	if not data._scary_discovery_said --[[and data.SO_access_str ~= "taser"]] then
		data._scary_discovery_said = true

		if not data.unit:sound():speaking(data.t) then
			data.unit:sound():say("a07b", true)
		end
	end
end

function CopLogicArrest.death_clbk(data, damage_info) ----further tweak
	if managers.groupai:state():whisper_mode() or not alive(damage_info.attacker_unit) then
		return
	end

	local my_data = data.internal_data
	local attacker_u_key = damage_info.attacker_unit:key()
	local arrest_data = my_data.arrest_targets[attacker_u_key]

	if arrest_data then
		local record = managers.groupai:state():criminal_record(attacker_u_key)

		if record then
			record.arrest_timeout = data.t + damage_info.attacker_unit:base():arrest_settings().arrest_timeout
		end
	end
end

function CopLogicArrest._mark_call_in_event(data, my_data, attention_obj)
	if not attention_obj then
		return
	end

	if attention_obj.reaction == REACT_ARREST then
		my_data.call_in_event = "criminal"
	elseif REACT_SCARED <= attention_obj.reaction then
		local unit_base = attention_obj.unit:base()
		local unit_brain = attention_obj.unit:brain()

		if attention_obj.unit:in_slot(17) then
			my_data.call_in_event = managers.enemy:get_corpse_unit_data_from_key(attention_obj.unit:key()).is_civilian and "dead_civ" or "dead_cop"
		elseif attention_obj.unit:in_slot(managers.slot:get_mask("enemies")) then
			my_data.call_in_event = "w_hot"
		elseif unit_brain and unit_brain.is_hostage and unit_brain:is_hostage() then
			my_data.call_in_event = managers.enemy:is_civilian(attention_obj.unit) and "hostage_civ" or "hostage_cop"
		elseif unit_base and unit_base.is_drill then
			my_data.call_in_event = "drill"
		elseif unit_base and unit_base.sentry_gun then
			my_data.call_in_event = "sentry_gun"
		elseif unit_base and unit_base.is_tripmine then
			my_data.call_in_event = "trip_mine"
		elseif unit_base and unit_base.is_security_camera then
			my_data.call_in_event = "camera"
		elseif unit_base and unit_base.is_hacking_device then
			my_data.call_in_event = "computer"
		elseif unit_base and unit_base._devices then
			local has_type = unit_base._devices["drill"] or unit_base._devices["c4"] or unit_base._devices["key"] or unit_base._devices["ecm"]

			if has_type then
				if has_type.units and next(has_type.units) then
					my_data.call_in_event = "sec_door"
				end
			end
		elseif attention_obj.unit:carry_data() then
			if attention_obj.unit:carry_data():carry_id() == "person" then
				my_data.call_in_event = "body_bag"
			else
				my_data.call_in_event = "bag"
			end
		elseif attention_obj.unit:in_slot(21) then
			my_data.call_in_event = "civilian"
		elseif not attention_obj.nav_tracker and attention_obj.unit:in_slot(1) then
			my_data.call_in_event = "glass"
		end
	end
end

function CopLogicArrest._chk_say_discovery(data, my_data, attention_obj) ----check
	if not attention_obj then
		return
	end

	if not data._discovery_said and attention_obj.reaction == REACT_SCARED --[[and data.SO_access_str ~= "taser"]] then
		data._discovery_said = true

		if not data.unit:sound():speaking(data.t) then
			data.unit:sound():say("a07a", true)
		end
	end
end

function CopLogicArrest._chk_say_approach(data, my_data, attention_obj)
end

function CopLogicArrest.on_police_call_success(data)
	data.internal_data.called_the_police = true
end

function CopLogicArrest._say_call_the_police(data, my_data)
	--[[if data.SO_access_str == "taser" then
		return
	end]]

	local blame_list = {
		ecm_feedback = "b27",
		computer = "a24",
		fire = "a18",
		sec_door = "a17",
		glass = math_random() < 0.5 and "b25" or "a10",
		camera = "b26",
		bag = "a22",
		body_bag = "a19",
		drill = "a25",
		criminal = "a23",
		trip_mine = "a21",
		w_hot = "a16",
		civilian = "a15",
		sentry_gun = "a20",
		dead_cop = "a12",
		hostage_cop = "a14",
		hostage_civ = "a13",
		dead_civ = "a11"
	}
	local voiceline = blame_list[my_data.call_in_event] or "a23"

	data.unit:sound():say(voiceline, true)
end

function CopLogicArrest._ask_call_the_police(data)
	if not data._said_ask_sound_the_alarm then
		data._said_ask_sound_the_alarm = true

		if not data.unit:sound():speaking(data.t) then
			data.unit:sound():say("a09", true)
		end
	end
end
