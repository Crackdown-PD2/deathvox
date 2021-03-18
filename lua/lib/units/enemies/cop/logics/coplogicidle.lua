--local mvec3_x = mvector3.x
--local mvec3_y = mvector3.y
--local mvec3_z = mvector3.z
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
--local mvec3_sub = mvector3.subtract
--local mvec3_dir = mvector3.direction
--local mvec3_dot = mvector3.dot
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_lerp = mvector3.lerp
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
local mvec3_equal = mvector3.equal

local tmp_vec1 = Vector3()

local math_lerp = math.lerp
local math_random = math.random
local math_up = math.UP
local math_abs = math.abs
local math_clamp = math.clamp
local math_min = math.min
local math_max = math.max
local math_sign = math.sign
--local math_floor = math.floor

--local m_rot_x = mrotation.x
local m_rot_y = mrotation.y
--local m_rot_z = mrotation.z

local table_insert = table.insert
local table_remove = table.remove
--local table_contains = table.contains

local clone_g = clone

local REACT_IDLE = AIAttentionObject.REACT_IDLE
local REACT_CURIOUS = AIAttentionObject.REACT_CURIOUS
local REACT_AIM = AIAttentionObject.REACT_AIM
local REACT_COMBAT = AIAttentionObject.REACT_COMBAT
local REACT_SHOOT = AIAttentionObject.REACT_SHOOT
local REACT_SUSPICIOUS = AIAttentionObject.REACT_SUSPICIOUS
local REACT_SCARED = AIAttentionObject.REACT_SCARED
local REACT_SURPRISED = AIAttentionObject.REACT_SURPRISED
local REACT_ARREST = AIAttentionObject.REACT_ARREST
local REACT_SPECIAL_ATTACK = AIAttentionObject.REACT_SPECIAL_ATTACK

local is_local_vr = _G.IS_VR

--[[CopLogicIdle = class(CopLogicBase)
CopLogicIdle.allowed_transitional_actions = {
	{
		"idle",
		"hurt",
		"dodge"
	},
	{
		"idle",
		"turn"
	},
	{
		"idle",
		"reload"
	},
	{
		"hurt",
		"stand",
		"crouch"
	}
}]]

function CopLogicIdle.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.brain:cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit
	}
	local is_cool = data.cool

	if is_cool then
		my_data.detection = data.char_tweak.detection.ntl
	else
		my_data.detection = data.char_tweak.detection.idle
	end

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

	local objective = data.objective

	if objective then
		--[[if CopLogicIdle._chk_objective_needs_travel(data, objective) then
			CopLogicBase._exit(data.unit, "travel")

			return
		end]]

		my_data.scan = objective.scan

		----almost got this working properly
		--if objective.rubberband_rotation or is_cool then
		if is_cool then
			--local original_fwd = Vector3()

			--if objective.rot then
				--m_rot_y(objective.rot, original_fwd)
			--else
				--m_rot_y(data.unit:movement():m_rot(), original_fwd)
			--end

			my_data.rubberband_rotation = data.unit:movement():m_rot():y()
		end
	else
		my_data.scan = true
	end

	my_data.weapon_range = clone_g(data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range)
	
	if data.tactics then
		if data.tactics.ranged_fire or data.tactics.elite_ranged_fire then
			my_data.weapon_range.close = my_data.weapon_range.close * 2
			my_data.weapon_range.optimal = my_data.weapon_range.optimal * 1.5
		end
	end

	local key_str = tostring(data.key)

	if my_data.scan then
		my_data.stare_path_search_id = "stare" .. key_str
		my_data.wall_stare_task_key = "CopLogicIdle._chk_stare_into_wall" .. key_str

		if not objective or not objective.action then
			CopLogicBase.queue_task(my_data, my_data.wall_stare_task_key, CopLogicIdle._chk_stare_into_wall_1, data, data.t)
		end
	end

	my_data.upd_task_key = "CopLogicIdle.update" .. key_str

	CopLogicBase.queue_task(my_data, my_data.upd_task_key, CopLogicIdle.queued_update, data, data.t, is_cool and true or data.important and true)

	if my_data.nearest_cover or my_data.best_cover then
		my_data.cover_update_task_key = "CopLogicIdle._update_cover" .. key_str

		CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t + 1)
	end

	CopLogicIdle._chk_has_old_action(data, my_data)

	if is_cool then
		data.brain:set_attention_settings({
			peaceful = true
		})
	else
		data.brain:set_attention_settings({
			cbt = true
		})
	end

	data.brain:set_update_enabled_state(false)
	CopLogicIdle._perform_objective_action(data, my_data, objective)
end

function CopLogicIdle.exit(data, new_logic_name, enter_params)
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

function CopLogicIdle.queued_update(data)
	data.t = TimerManager:game():time()
	local my_data = data.internal_data

	local delay = data.logic._upd_enemy_detection(data)

	if data.internal_data ~= my_data then
		return
	end

	local objective = data.objective

	if my_data.has_old_action then
		CopLogicIdle._upd_stop_old_action(data, my_data, objective)
		CopLogicBase.queue_task(my_data, my_data.upd_task_key, CopLogicIdle.queued_update, data, data.t + delay, data.cool and true or data.important and true)

		return
	end

	if data.is_converted then
		if not data.objective or data.objective.type == "free" then
			if not data.path_fail_t or data.t - data.path_fail_t > 6 then
				managers.groupai:state():on_criminal_jobless(data.unit)

				if my_data ~= data.internal_data then
					return
				end
			end
		end
	end

	if data.cool then
		if CopLogicIdle._chk_exit_non_walkable_area(data) then
			return
		end
	elseif CopLogicIdle._chk_relocate(data) or CopLogicIdle._chk_exit_non_walkable_area(data) then
		return
	end

	CopLogicIdle._perform_objective_action(data, my_data, objective)
	CopLogicIdle._upd_stance_and_pose(data, my_data, objective)
	CopLogicIdle._upd_pathing(data, my_data)
	CopLogicIdle._upd_scan(data, my_data)

	if data.cool then
		CopLogicIdle.upd_suspicion_decay(data)
	end

	if data.internal_data ~= my_data then
		return
	end

	CopLogicBase.queue_task(my_data, my_data.upd_task_key, CopLogicIdle.queued_update, data, data.t + delay, data.cool and true or data.important and true)
end

function CopLogicIdle._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	local my_data = data.internal_data
	local delay = CopLogicBase._upd_attention_obj_detection(data, nil, nil)
	local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, data.detected_attention_objects)

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)

	if new_reaction and REACT_SURPRISED <= new_reaction then
		local objective = data.objective
		local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, new_attention)

		if allow_trans then
			local wanted_state = CopLogicBase._get_logic_state_from_reaction(data)

			if wanted_state and wanted_state ~= data.name then
				if obj_failed then
					data.objective_failed_clbk(data.unit, data.objective)
				end

				if my_data == data.internal_data then
					CopLogicBase._exit(data.unit, wanted_state)
				end

				CopLogicBase._report_detections(data.detected_attention_objects)

				return
			end
		end
	end

	CopLogicBase._chk_call_the_police(data)
	CopLogicBase._report_detections(data.detected_attention_objects)

	return delay
end

function CopLogicIdle._upd_pathing(data, my_data)
	if not data.pathing_results then
		return
	end

	local path = my_data.stare_path_search_id and data.pathing_results[my_data.stare_path_search_id]

	if path then
		data.pathing_results[my_data.stare_path_search_id] = nil

		if not next(data.pathing_results) then
			data.pathing_results = nil
		end

		if path ~= "failed" then
			my_data.stare_path = path

			CopLogicBase.queue_task(my_data, my_data.wall_stare_task_key, CopLogicIdle._chk_stare_into_wall_2, data, data.t)
		else
			--print("[CopLogicIdle:_upd_pathing] stare path failed!", data.unit:key())

			local path_jobs = my_data.stare_path_pos

			table_remove(path_jobs)

			if #path_jobs > 0 then
				data.brain:search_for_path(my_data.stare_path_search_id, path_jobs[#path_jobs])
			else
				my_data.stare_path_pos = nil
			end
		end
	end
end

function CopLogicIdle._upd_scan(data, my_data)
	local focusing_attention, not_available = CopLogicIdle._chk_focus_on_attention_object(data, my_data)
	not_available = not_available or not_available == nil and not data.logic.is_available_for_assignment(data)

	if focusing_attention then
		local current_attention = data.attention_obj

		if current_attention and current_attention.reaction > REACT_IDLE then
			return
		end
	end

	if not_available then
		if my_data.fwd_offset and CopLogicIdle._can_turn(data, my_data) then
			local return_spin = my_data.rubberband_rotation:to_polar_with_reference(data.unit:movement():m_rot():y(), math_up).spin

			if CopLogicIdle._turn_by_spin(data, my_data, return_spin) and math_abs(return_spin) < 15 then
				my_data.fwd_offset = nil
			end
		end

		local set_attention = data.unit:movement():attention()

		if set_attention then
			CopLogicBase._reset_attention(data)
		end

		--local line2 = Draw:brush(Color.red:with_alpha(0.5), 0.1)
		--line2:sphere(data.unit:movement():m_head_pos(), 25)

		return
	end

	local stare_positions = my_data.stare_pos

	if not stare_positions or not my_data.next_scan_t or data.t < my_data.next_scan_t then
		local should_stare_at_beanbag_pos = nil
		local set_attention = data.unit:movement():attention()

		if my_data.next_scan_t and data.t < my_data.next_scan_t then
			if set_attention and set_attention.pos then
				should_stare_at_beanbag_pos = true
			elseif my_data.last_beanbag_pos then
				should_stare_at_beanbag_pos = true

				CopLogicBase._set_attention_on_pos(data, my_data.last_beanbag_pos)

				set_attention = data.unit:movement():attention()
			end
		else
			my_data.last_beanbag_pos = nil
			CopLogicBase._reset_attention(data)
		end

		if should_stare_at_beanbag_pos then
			local turned_around = nil
			local turn_angle = CopLogicIdle._chk_turn_needed(data, my_data, data.m_pos, set_attention.pos)

			if not turn_angle or math_abs(turn_angle) < 5 then
				turned_around = true
			elseif CopLogicIdle._can_turn(data, my_data) and CopLogicIdle._turn_by_spin(data, my_data, turn_angle) then
				if my_data.rubberband_rotation then
					my_data.fwd_offset = true
				end

				turned_around = true
			end

			----check
			if not turned_around then
				should_stare_at_beanbag_pos = nil

				CopLogicBase._reset_attention(data)
			end
		end

		if not should_stare_at_beanbag_pos and my_data.fwd_offset and CopLogicIdle._can_turn(data, my_data) then
			local return_spin = my_data.rubberband_rotation:to_polar_with_reference(data.unit:movement():m_rot():y(), math_up).spin

			if CopLogicIdle._turn_by_spin(data, my_data, return_spin) and math_abs(return_spin) < 15 then
				my_data.fwd_offset = nil
			end
		end

		return
	end

	local beanbag = my_data.scan_beanbag

	if not beanbag then
		beanbag = {}

		for i = 1, #stare_positions do
			beanbag[#beanbag + 1] = stare_positions[i]
		end

		my_data.scan_beanbag = beanbag
	end

	local nr_pos = #beanbag
	local scan_pos = nil
	local lucky_i_pos = math_random(nr_pos)
	scan_pos = beanbag[lucky_i_pos]

	local turned_around = nil
	local turn_angle = CopLogicIdle._chk_turn_needed(data, my_data, data.m_pos, scan_pos)

	if not turn_angle or math_abs(turn_angle) < 5 then
		turned_around = true
	elseif CopLogicIdle._can_turn(data, my_data) and CopLogicIdle._turn_by_spin(data, my_data, turn_angle) then
		if my_data.rubberband_rotation then
			my_data.fwd_offset = true
		end

		turned_around = true
	end

	if not turned_around then
		local set_attention = data.unit:movement():attention()

		if set_attention then
			CopLogicBase._reset_attention(data)
		end

		return
	end

	my_data.last_beanbag_pos = scan_pos

	CopLogicBase._set_attention_on_pos(data, scan_pos)

	if #beanbag == 1 then
		my_data.scan_beanbag = nil
	else
		beanbag[lucky_i_pos] = beanbag[#beanbag]

		table_remove(beanbag)
	end

	my_data.next_scan_t = data.t + math_random(3, 10)
end

function CopLogicIdle.damage_clbk(data, damage_info)
	local t = TimerManager:game():time()
	data.t = t

	local enemy = damage_info.attacker_unit

	if alive(enemy) and enemy:in_slot(data.enemy_slotmask) then
		local enemy_data, is_new = CopLogicBase.identify_attention_obj_instant(data, enemy:key())

		if enemy_data then
			enemy_data.dmg_t = t
			enemy_data.alert_t = t

			if enemy_data.criminal_record then
				managers.groupai:state():criminal_spotted(enemy)
				managers.groupai:state():report_aggression(enemy)
			end
		end
	end
	
	if data.tactics and data.tactics.sneaky then
		data.coward_t = t
	end
end

function CopLogicIdle.on_alert(data, alert_data)
	if CopLogicBase._chk_alert_obstructed(data.unit:movement():m_head_pos(), alert_data) then
		return
	end

	data.t = TimerManager:game():time()
	local alert_type = alert_data[1]
	local alert_unit = alert_data[5]
	local groupai_state_manager = managers.groupai:state()
	local was_cool = data.cool
	local alert_is_aggressive = CopLogicBase.is_alert_aggressive(alert_type)

	if was_cool and alert_is_aggressive then
		local giveaway = groupai_state_manager.analyse_giveaway(data.unit:base()._tweak_table, alert_data[5], alert_data)

		data.unit:movement():set_cool(false, giveaway)
	end

	if not alive(alert_unit) then
		return
	end

	if alert_unit:in_slot(data.enemy_slotmask) then
		local att_obj_data, is_new = nil

		if not was_cool or alert_type ~= "explosion" or alert_type ~= "fire" then
			att_obj_data, is_new = CopLogicBase.identify_attention_obj_instant(data, alert_unit:key())
		end

		if not att_obj_data then
			return
		end

		local alert_is_dangerous = CopLogicBase.is_alert_dangerous(alert_type)

		if alert_is_dangerous then
			att_obj_data.alert_t = data.t
		end

		local action_data = nil
		
		if was_cool and not data.is_converted then
			if not data.attention_obj or data.attention_obj.reaction < REACT_AIM then
				if REACT_SURPRISED <= att_obj_data.reaction then
					if not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.stand then
						if data.unit:anim_data().idle and not data.unit:movement():chk_action_forbidden("walk") then
							action_data = {
								variant = "surprised",
								body_part = 1,
								type = "act"
							}
							
							if not data.unit:brain():action_request(action_data) then
								action_data = nil
							end
						end
					end
				end
			end
		end

		if att_obj_data.criminal_record then
			groupai_state_manager:criminal_spotted(alert_unit)

			if alert_is_dangerous then
				groupai_state_manager:report_aggression(alert_unit)
			end
		end
	elseif was_cool and alert_is_aggressive then
		local attention_obj = alert_unit:brain() and alert_unit:brain()._logic_data and alert_unit:brain()._logic_data.attention_obj

		if attention_obj then
			CopLogicBase.identify_attention_obj_instant(data, attention_obj.u_key)
		end
	end
end

function CopLogicIdle.on_new_objective(data, old_objective)
	local new_objective = data.objective

	CopLogicBase.on_new_objective(data, old_objective)

	local my_data = data.internal_data

	if new_objective then
		local objective_type = new_objective.type

		if CopLogicIdle._chk_objective_needs_travel(data, new_objective) then
			--if not new_objective.in_place then
				CopLogicBase._exit(data.unit, "travel")
			--end
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
		elseif objective_type ~= "free" or not my_data.exiting then
			if new_objective.action then
				CopLogicBase._exit(data.unit, "idle")
			--[[else
				local wanted_state = data.logic._get_logic_state_from_reaction(data) or "idle" ----check

				CopLogicBase._exit(data.unit, wanted_state)
			end]]
			elseif not data.attention_obj or REACT_AIM > data.attention_obj.reaction or data.attention_obj.criminal_record and data.attention_obj.criminal_record.being_arrested then
				local can_call_the_police = not data.cool and not data.is_converted and data.char_tweak.calls_in and not new_objective.no_arrest and not managers.groupai:state():is_police_called() and not CopLogicArrest._chk_already_calling_in_area(data) and true

				--[[if can_call_the_police then
					local my_cur_nav_seg = data.unit:movement():nav_tracker():nav_segment()
					local my_cur_area = managers.groupai:state():get_area_from_nav_seg_id(my_cur_nav_seg)
					local already_calling_in_area = managers.groupai:state():chk_enemy_calling_in_area(my_cur_area, data.key)

					if not CopLogicArrest._chk_already_calling_in_area(data) then
						can_call_the_police = false
					end
				end]]

				if can_call_the_police then
					CopLogicBase._exit(data.unit, "arrest")
				else
					CopLogicBase._exit(data.unit, "idle")
				end
			elseif REACT_ARREST == data.attention_obj.reaction and CopLogicBase._can_arrest(data) then
				CopLogicBase._exit(data.unit, "arrest")
			else
				CopLogicBase._exit(data.unit, "attack")
			end
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

function CopLogicIdle._chk_reaction_to_attention_object(data, attention_data, stationary)
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
	--[[elseif record.status == "electrified" and attention_data.verified and attention_data.dis < 1500 and not data.unit:base():has_tag("special") then
		if record.being_arrested and #record.being_arrested > 1 then
			if not record.assault_t or data.t > record.assault_t + 2 then
				return math_min(att_reaction, REACT_AIM)
			end

			return math_min(att_reaction, REACT_COMBAT)
		end

		if not data.objective or not data.objective.no_arrest then
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

function CopLogicIdle.on_criminal_neutralized(data, criminal_key)
end

function CopLogicIdle.on_intimidated(data, amount, aggressor_unit)
	local surrender = false
	local my_data = data.internal_data
	data.t = TimerManager:game():time()

	if not aggressor_unit:movement():team().foes[data.team.id] then
		return
	end

	if managers.groupai:state():has_room_for_police_hostage() and not managers.groupai:state():is_enemy_special(data.unit) then
		--local i_am_special = managers.groupai:state():is_enemy_special(data.unit)
		--local required_skill = i_am_special and "intimidate_specials" or "intimidate_enemies"
		local aggressor_can_intimidate = true
		local aggressor_intimidation_mul = 1

		if aggressor_unit:base().is_local_player then
			--aggressor_can_intimidate = managers.player:has_category_upgrade("player", required_skill)
			aggressor_intimidation_mul = aggressor_intimidation_mul * managers.player:upgrade_value("player", "empowered_intimidation_mul", 1) * managers.player:upgrade_value("player", "intimidation_multiplier", 1)
		elseif aggressor_unit:base().is_husk_player then
			--aggressor_can_intimidate = aggressor_unit:base():upgrade_value("player", required_skill)
			aggressor_intimidation_mul = aggressor_intimidation_mul * (aggressor_unit:base():upgrade_value("player", "empowered_intimidation_mul") or 1) * (aggressor_unit:base():upgrade_value("player", "intimidation_multiplier") or 1)
		end

		if aggressor_can_intimidate then
			local hold_chance = CopLogicBase._evaluate_reason_to_surrender(data, my_data, aggressor_unit)

			if hold_chance then
				hold_chance = hold_chance^aggressor_intimidation_mul

				if hold_chance < 1 then
					local rand_nr = math_random()

					--print("and the winner is: hold_chance", hold_chance, "rand_nr", rand_nr, "rand_nr > hold_chance", hold_chance < rand_nr)

					if hold_chance < rand_nr then
						surrender = true
					end
				end
			end
		end

		if surrender then
			CopLogicIdle._surrender(data, amount, aggressor_unit)
		else
			data.brain:on_surrender_chance()
		end
	end

	CopLogicBase.identify_attention_obj_instant(data, aggressor_unit:key())
	managers.groupai:state():criminal_spotted(aggressor_unit)

	return surrender
end

function CopLogicIdle._surrender(data, amount, aggressor_unit)
	local params = {
		effect = amount,
		aggressor_unit = aggressor_unit
	}

	data.brain:set_objective({
		type = "surrender",
		params = params
	})
end

function CopLogicIdle._chk_stare_into_wall_1(data)
	local my_tracker = data.unit:movement():nav_tracker()
	local my_nav_seg = my_tracker:nav_segment()
	local my_area = managers.groupai:state():get_area_from_nav_seg_id(my_nav_seg)
	local allied_with_criminals = data.is_converted or data.unit:in_slot(16) or data.team.id == tweak_data.levels:get_default_team_ID("player") or data.team.friends[tweak_data.levels:get_default_team_ID("player")]
	local found_areas = {
		[my_area] = true
	}
	local areas_to_search = {
		my_area
	}
	local dangerous_far_areas = {}

	while next(areas_to_search) do
		local test_area = table_remove(areas_to_search, 1)
		local expand = nil

		if allied_with_criminals then
			if next(test_area.police.units) then
				if test_area == my_area then
					break
				end

				dangerous_far_areas[test_area] = true
			else
				expand = true
			end
		elseif next(test_area.criminal.units) then
			if test_area == my_area then
				break
			end

			dangerous_far_areas[test_area] = true
		else
			expand = true
		end

		if expand then
			for n_area_id, n_area in pairs(test_area.neighbours) do
				if not found_areas[n_area] then
					found_areas[n_area] = test_area

					table_insert(areas_to_search, n_area)
				end
			end
		end
	end

	local dangerous_near_areas = {}

	for area, _ in pairs(dangerous_far_areas) do
		local backwards_area = area

		while true do
			if found_areas[backwards_area] == my_area then
				dangerous_near_areas[backwards_area] = true

				break
			else
				backwards_area = found_areas[backwards_area]
			end
		end
	end

	local ray_from_pos = data.unit:movement():m_stand_pos()
	local ray_to_pos = tmp_vec1
	local nav_manager = managers.navigation
	local all_nav_segs = nav_manager._nav_segments
	local my_pos = my_tracker:field_position()
	local walk_params = {
		pos_from = my_pos
	}
	local slotmask = data.visibility_slotmask
	local stare_pos = {}
	local path_tasks = {}

	for area, _ in pairs(dangerous_near_areas) do
		if not all_nav_segs[area.pos_nav_seg].disabled then
			local seg_pos = nav_manager:find_random_position_in_segment(area.pos_nav_seg)
			local unobstructed_line = nil

			if math_abs(my_pos.z - seg_pos.z) < 40 then
				walk_params.pos_to = seg_pos

				if not nav_manager:raycast(walk_params) then
					unobstructed_line = true
				end
			end

			if not unobstructed_line then
				mvec3_set(ray_to_pos, seg_pos)
				mvec3_set_z(ray_to_pos, ray_to_pos.z + 160)

				local vis_ray_hit = data.unit:raycast("ray", ray_from_pos, ray_to_pos, "slot_mask", slotmask, "ray_type", "ai_vision", "report")

				if vis_ray_hit then
					table_insert(path_tasks, seg_pos)
				else
					table_insert(stare_pos, mvec3_cpy(ray_to_pos))
				end
			else
				mvec3_set_z(seg_pos, seg_pos.z + 160)

				table_insert(stare_pos, seg_pos)
			end
		end
	end

	local my_data = data.internal_data

	if #stare_pos > 0 then
		my_data.stare_pos = stare_pos
		my_data.next_scan_t = 0
	end

	if #path_tasks > 0 then
		my_data.stare_path_pos = path_tasks

		data.brain:search_for_path(my_data.stare_path_search_id, path_tasks[#path_tasks])
	end
end

function CopLogicIdle._chk_stare_into_wall_2(data)
	local my_data = data.internal_data
	local stare_path = my_data.stare_path

	if not stare_path then
		return
	end

	local f_nav_point_pos = CopLogicIdle._nav_point_pos

	for i, nav_point in ipairs(stare_path) do
		stare_path[i] = f_nav_point_pos(nav_point)
	end

	local dis_table = {}
	local total_dis = 0
	local nr_nodes = #stare_path
	local i_node = 1
	local this_pos = stare_path[1]

	repeat
		local next_pos = stare_path[i_node + 1]
		local dis = mvec3_dis(this_pos, next_pos)
		total_dis = total_dis + dis

		table_insert(dis_table, dis)

		this_pos = next_pos
		i_node = i_node + 1
	until i_node == nr_nodes

	local nr_loops = 5
	local dis_step = total_dis / (nr_loops + 1)
	local ray_from_pos = data.unit:movement():m_stand_pos()
	local ray_to_pos = tmp_vec1
	local slotmask = data.visibility_slotmask
	local furthest_good_pos = nil
	local dis_in_seg = 0
	local index = nr_nodes
	local i_loop = 0

	repeat
		dis_in_seg = dis_in_seg + dis_step
		local seg_dis = dis_table[index - 1]

		while seg_dis < dis_in_seg do
			index = index - 1
			dis_in_seg = dis_in_seg - seg_dis
			seg_dis = dis_table[index - 1]
		end

		mvec3_lerp(ray_to_pos, stare_path[index], stare_path[index - 1], dis_in_seg / seg_dis)
		mvec3_set_z(ray_to_pos, ray_to_pos.z + 160)

		local vis_ray_hit = data.unit:raycast("ray", ray_from_pos, ray_to_pos, "slot_mask", slotmask, "ray_type", "ai_vision", "report")

		if not vis_ray_hit then
			if not my_data.stare_pos then
				my_data.next_scan_t = 0
				my_data.stare_pos = {}
			end

			table_insert(my_data.stare_pos, mvec3_cpy(ray_to_pos))

			break
		end

		i_loop = i_loop + 1
	until i_loop == nr_loops

	my_data.stare_path = nil

	local path_jobs = my_data.stare_path_pos
	table_remove(path_jobs)

	if #path_jobs > 0 then
		data.brain:search_for_path(my_data.stare_path_search_id, path_jobs[#path_jobs])
	else
		my_data.stare_path_pos = nil

		CopLogicBase.queue_task(my_data, my_data.wall_stare_task_key, CopLogicIdle._chk_stare_into_wall_1, data, TimerManager:game():time() + 2)
	end
end

function CopLogicIdle._chk_request_action_turn_to_look_pos(data, my_data, my_pos, look_pos)
	local turn_angle = CopLogicIdle._chk_turn_needed(data, my_data, my_pos, look_pos)

	if not turn_angle then
		return
	end

	local err_to_correct_abs = math_abs(turn_angle)

	if err_to_correct_abs < 5 then
		return
	end

	return CopLogicIdle._turn_by_spin(data, my_data, turn_angle)
end

function CopLogicIdle.on_area_safety(data, nav_seg, safe, event)
	if not safe and event.reason == "criminal" then
		local my_data = data.internal_data
		local u_criminal = event.record.unit
		local key_criminal = u_criminal:key()

		if not data.detected_attention_objects[key_criminal] then
			local attention_info = managers.groupai:state():get_AI_attention_objects_by_filter(data.SO_access_str)[key_criminal]

			if attention_info then
				local settings = attention_info.handler:get_attention(data.SO_access, nil, nil, data.team)

				if settings then
					data.detected_attention_objects[key_criminal] = CopLogicBase._create_detected_attention_object_data(TimerManager:game():time(), data.unit, key_criminal, attention_info, settings)
				end
			end
		end
	end
end

function CopLogicIdle.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action:type()

	if action_type == "turn" then
		my_data.turning = nil

		if my_data.fwd_offset and action:expired() then
			local return_spin = my_data.rubberband_rotation:to_polar_with_reference(data.unit:movement():m_rot():y(), math_up).spin

			if math_abs(return_spin) < 15 then
				my_data.fwd_offset = nil
			end
		end
	elseif action_type == "act" then
		if my_data.action_started == action then
			local expired = action:expired()

			if expired then
				if not my_data.action_timeout_clbk_id then
					data.objective_complete_clbk(data.unit, data.objective)
				end
			elseif not my_data.action_expired then
				data.objective_failed_clbk(data.unit, data.objective)
			end

			if expired and my_data == data.internal_data and my_data.wall_stare_task_key and my_data.scan and not my_data.exiting and not my_data.stare_path_pos then
				if not my_data.queued_tasks or not my_data.queued_tasks[my_data.wall_stare_task_key] then
					CopLogicBase.queue_task(my_data, my_data.wall_stare_task_key, CopLogicIdle._chk_stare_into_wall_1, data, TimerManager:game():time())
				end
			end
		end
	elseif action_type == "hurt" or action_type == "healed" then
		if action:expired() then
			if data.important or data.is_converted or data.unit:in_slot(16) then
				CopLogicBase.chk_start_action_dodge(data, "hit")
			end

			--[[if not my_data.exiting then
				local wanted_state = data.logic._get_logic_state_from_reaction(data)

				if wanted_state and wanted_state ~= data.name then
					local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, data.objective, nil, nil)

					if allow_trans and obj_failed then
						data.objective_failed_clbk(data.unit, data.objective)

						if my_data == data.internal_data then
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

		--[[if action:expired() and not my_data.exiting then
			local wanted_state = data.logic._get_logic_state_from_reaction(data)

			if wanted_state and wanted_state ~= data.name then
				local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, data.objective, nil, nil)

				if allow_trans and obj_failed then
					data.objective_failed_clbk(data.unit, data.objective)

					if my_data == data.internal_data then
						CopLogicBase._exit(data.unit, wanted_state)
					end
				end
			end
		end]]
	end
end

function CopLogicIdle.is_available_for_assignment(data, objective)
	if objective and objective.forced then
		return true
	end

	local my_data = data.internal_data

	if data.objective and data.objective.action then
		if my_data.action_started then
			if data.unit:anim_data().act and not data.unit:anim_data().act_idle then
				return
			end
		else
			return
		end
	end

	data.t = TimerManager:game():time()

	if my_data.exiting or data.path_fail_t and data.t < data.path_fail_t + 6 then
		return
	end

	return true
end

function CopLogicIdle.clbk_action_timeout(ignore_this, data)
	local my_data = data.internal_data

	CopLogicBase.on_delayed_clbk(my_data, my_data.action_timeout_clbk_id)

	my_data.action_timeout_clbk_id = nil

	if not data.objective then
		--debug_pause_unit(data.unit, "[CopLogicIdle.clbk_action_timeout] missing objective")

		return
	end

	my_data.action_expired = true

	local anim_data = data.unit:anim_data()

	if anim_data.act and anim_data.needs_idle then
		CopLogicIdle._start_idle_action_from_act(data)
	end

	data.objective_complete_clbk(data.unit, data.objective)
end

function CopLogicIdle._nav_point_pos(nav_point)
	return nav_point.x and nav_point or nav_point:script_data().element:value("position")
end

function CopLogicIdle._chk_relocate(data) ----keep fiddling with this, maybe it'll eventually work properly
	if not data.objective then
		return
	end

	if data.objective.type == "follow" then
		if data.is_converted then
			if TeamAILogicIdle._check_should_relocate(data, data.internal_data, data.objective) then
				data.objective.in_place = nil

				data.logic._exit(data.unit, "travel")

				return true
			end

			return
		end

		local follow_unit = data.objective.follow_unit
		local follow_tracker = follow_unit:movement():nav_tracker()
		local advance_pos = follow_unit:brain() and follow_unit:brain():is_advancing()
		local follow_unit_pos = advance_pos or follow_tracker:field_position()

		if data.is_tied and data.objective.lose_track_dis and data.objective.lose_track_dis * data.objective.lose_track_dis < mvec3_dis_sq(data.m_pos, follow_unit_pos) then
			data.brain:set_objective(nil)

			return true
		end

		--[[local current_focus = data.attention_obj

		if current_focus and current_focus.u_key == follow_unit:key() and current_focus.verified then
			local needed_dis = 500

			if data.attention_obj.reaction >= REACT_COMBAT and data.unit:base().has_tag and data.unit:base():has_tag("special") then
				needed_dis = 1500
			end

			if current_focus.dis < needed_dis then
				return
			end
		end]]

		local relocate = nil

		if data.objective.relocated_to and mvec3_equal(data.objective.relocated_to, follow_unit_pos) then
			return
		end

		if data.objective.distance and data.objective.distance < mvec3_dis(data.m_pos, follow_unit_pos) then
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
			if advance_pos or follow_tracker:lost() then
				data.objective.nav_seg = managers.navigation:get_nav_seg_from_pos(follow_unit_pos)
			else
				data.objective.nav_seg = follow_tracker:nav_segment()
			end

			data.objective.in_place = nil
			data.objective.relocated_to = mvec3_cpy(follow_unit_pos)

			data.logic._exit(data.unit, "travel")

			return true
		end
	--[[elseif data.objective.type == "defend_area" then
		if data.objective.grp_objective and data.objective.grp_objective.type == "retire" then
			if not data.attention_obj or data.attention_obj.reaction < REACT_AIM then
				data.logic._exit(data.unit, "travel")

				return true
			else
				local my_area = managers.groupai:state():get_area_from_nav_seg_id(my_nav_seg)

				if my_area and not next(my_area.criminal.units) then
					data.logic._exit(data.unit, "travel")

					return true
				end
			end
		else
			local current_focus = data.attention_obj

			if current_focus and current_focus.criminal_record and current_focus.dis < 1500 then
				if current_focus.verified or current_focus.verified_t and data.t < current_focus.verified_t + 6 then
					return
				end
			end

			local area = data.objective.relocated_area or data.objective.area

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
					data.objective.relocated_area = target_area
					data.objective.in_place = nil
					data.objective.nav_seg = next(target_area.nav_segs)
					data.objective.path_data = {
						{
							data.objective.nav_seg
						}
					}

					data.logic._exit(data.unit, "travel")

					return true
				elseif data.objective.relocated_area then
					data.objective.relocated_area = nil
				end
			end
		end]]
	end
end

function CopLogicIdle._chk_exit_non_walkable_area(data)
	local my_data = data.internal_data

	if my_data.advancing or my_data.old_action_advancing or not data.objective or not data.objective.nav_seg or data.unit:movement():chk_action_forbidden("walk") then
		return
	end

	local my_tracker = data.unit:movement():nav_tracker()

	if my_tracker:obstructed() then
		local nav_seg_id = my_tracker:nav_segment()

		if not managers.navigation._nav_segments[nav_seg_id].disabled then
			data.objective.in_place = nil

			data.logic.on_new_objective(data, data.objective)

			return true
		end
	end
end

function CopLogicIdle._get_all_paths(data)
	return {
		stare_path = data.internal_data.stare_path
	}
end

function CopLogicIdle._set_verified_paths(data, verified_paths)
	data.internal_data.stare_path = verified_paths.stare_path
end

function CopLogicIdle._can_turn(data, my_data)
	if my_data.turning then
		return
	end

	if my_data.fwd_offset or not data.objective or not data.objective.rot then
		if data.unit:movement()._should_stay then
			return not data.unit:movement():chk_action_forbidden("turn")
		else
			return not data.unit:movement():chk_action_forbidden("walk")
		end
	end
end

function CopLogicIdle._chk_focus_on_attention_object(data, my_data)
	local current_attention = data.attention_obj

	if not current_attention then
		local set_attention = data.unit:movement():attention()

		if set_attention and set_attention.handler then
			CopLogicBase._reset_attention(data)
		end

		--local line2 = Draw:brush(Color.red:with_alpha(0.5), 0.1)
		--line2:sphere(data.unit:movement():m_head_pos(), 25)

		return
	end

	local reaction = current_attention.reaction

	if my_data.turning then
		if reaction == REACT_SUSPICIOUS then
			CopLogicBase._upd_suspicion(data, my_data, current_attention)

			--local line2 = Draw:brush(Color.green:with_alpha(0.5), 0.1)
			--line2:sphere(data.unit:movement():m_head_pos(), 25)
		end

		return true, true
	end

	if reaction == REACT_CURIOUS or reaction == REACT_SUSPICIOUS then
		CopLogicIdle._upd_curious_reaction(data)

		--local line2 = Draw:brush(Color.green:with_alpha(0.5), 0.1)
		--line2:sphere(data.unit:movement():m_head_pos(), 25)

		return true, true
	end

	if not data.logic.is_available_for_assignment(data) then
		return false, true
	end

	local turned_around = nil
	local turn_angle = CopLogicIdle._chk_turn_needed(data, my_data, data.m_pos, current_attention.m_pos)

	if not turn_angle then
		turned_around = true
	elseif reaction == REACT_IDLE then
		if math_abs(turn_angle) > 70 then
			local set_attention = data.unit:movement():attention()

			if set_attention and set_attention.handler then
				CopLogicBase._reset_attention(data)
			end

			return nil, false
		else
			turned_around = true
		end
	elseif math_abs(turn_angle) > 40 then
		if CopLogicIdle._can_turn(data, my_data) and CopLogicIdle._turn_by_spin(data, my_data, turn_angle) then
			if my_data.rubberband_rotation then
				my_data.fwd_offset = true
			end

			turned_around = true
		end
	else
		turned_around = true
	end

	if not turned_around then
		local set_attention = data.unit:movement():attention()

		if set_attention and set_attention.handler then
			CopLogicBase._reset_attention(data)
		end

		return nil, false
	end

	local set_attention = data.unit:movement():attention()

	if not set_attention or set_attention.u_key ~= current_attention.u_key then
		CopLogicBase._set_attention(data, current_attention, nil)
	end

	--local line2 = Draw:brush(Color.green:with_alpha(0.5), 0.1)
	--line2:sphere(data.unit:movement():m_head_pos(), 25)

	return true, false
end

function CopLogicIdle._chk_turn_needed(data, my_data, my_pos, look_pos)
	local fwd = data.unit:movement():m_rot():y()
	local target_vec = look_pos - my_pos
	local error_polar = target_vec:to_polar_with_reference(fwd, math_up)
	local error_spin = error_polar.spin
	local tolerance = error_spin < 0 and 50 or 30
	local err_to_correct = error_spin - tolerance * math_sign(error_spin)

	if math_sign(err_to_correct) ~= math_sign(error_spin) then
		return
	end

	return err_to_correct
end

function CopLogicIdle._get_priority_attention(data, attention_objects, reaction_func)
	reaction_func = reaction_func or CopLogicIdle._chk_reaction_to_attention_object
	local best_target, best_target_priority_slot, best_target_priority, best_target_reaction = nil
	local forced_attention_data = managers.groupai:state():force_attention_data(data.unit)

	if forced_attention_data then
		local forced_unit = forced_attention_data.unit
		local requires_visibility = not forced_attention_data.ignore_vis_blockers
		local skip_force_process = nil

		if data.attention_obj and data.attention_obj.unit == forced_unit then
			if not requires_visibility or data.attention_obj.verified then
				return data.attention_obj, 1, REACT_SHOOT
			end

			skip_force_process = true
		end

		if not skip_force_process then
			local att_info = data.detected_attention_objects[forced_unit:key()]

			if att_info then
				local my_pos = data.unit:movement():m_head_pos()
				local attention_pos = att_info.m_head_pos
				local can_force, upd_verified = nil

				if requires_visibility then
					if att_info.identified and att_info.verified then
						can_force = true
						upd_verified = true
					else
						local vis_ray = data.unit:raycast("ray", my_pos, attention_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision")

						if not vis_ray or vis_ray.unit:key() == att_info.u_key then
							can_force = true
							upd_verified = true
						end

						att_info.vis_ray = vis_ray
					end
				else
					can_force = true
				end

				if can_force then
					if not att_info.forced then
						att_info.forced = true
					end

					if not att_info.identified then
						att_info.identified = true
						att_info.identified_t = data.t
						att_info.notice_progress = nil
						att_info.prev_notice_chk_t = nil
						att_info.dis = mvec3_dis(my_pos, attention_pos)

						if not upd_verified then
							att_info.release_t = data.t + att_info.settings.release_delay

							if att_info.settings.notice_interval then
								att_info.next_verify_t = data.t + att_info.settings.notice_interval
							else
								att_info.next_verify_t = data.t + att_info.settings.verification_interval
							end
						end

						if att_info.settings.notice_clbk then
							att_info.settings.notice_clbk(data.unit, true)
						end

						data.logic.on_attention_obj_identified(data, att_info.u_key, att_info)
					end

					if upd_verified then
						att_info.verified = true
						att_info.nearly_visible = nil
						att_info.nearly_visible_t = nil
						att_info.release_t = nil
						att_info.verified_t = data.t
						att_info.verified_dis = mvec3_dis(my_pos, attention_pos)
						att_info.next_verify_t = data.t + att_info.settings.verification_interval

						mvec3_set(att_info.verified_pos, attention_pos)

						if att_info.last_verified_pos then
							mvec3_set(att_info.last_verified_pos, attention_pos)
						else
							att_info.last_verified_pos = mvec3_cpy(attention_pos)
						end
					end

					return att_info, 1, REACT_SHOOT
				end
			else
				local forced_attention_object = managers.groupai:state():get_AI_attention_object_by_unit(forced_unit)

				if forced_attention_object then
					for u_key, attention_info in pairs(forced_attention_object) do
						local my_pos = data.unit:movement():m_head_pos()
						local attention_pos = attention_info.handler:get_detection_m_pos()

						if not requires_visibility then
							best_target = CopLogicBase._create_detected_attention_object_data(data.t, data.unit, u_key, attention_info, attention_info.handler:get_attention(data.SO_access), true)
						else
							local vis_ray = data.unit:raycast("ray", my_pos, attention_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision")

							if not vis_ray or vis_ray.unit:key() == u_key then
								best_target = CopLogicBase._create_detected_attention_object_data(data.t, data.unit, u_key, attention_info, attention_info.handler:get_attention(data.SO_access), true)

								if best_target then
									best_target.vis_ray = vis_ray
								end
							end
						end

						if best_target then
							best_target.identified = true
							best_target.identified_t = data.t
							best_target.notice_progress = nil
							best_target.prev_notice_chk_t = nil
							best_target.dis = mvec3_dis(my_pos, attention_pos)
							best_target.next_verify_t = data.t + best_target.settings.verification_interval

							if best_target.settings.notice_clbk then
								best_target.settings.notice_clbk(data.unit, true)
							end

							data.logic.on_attention_obj_identified(data, best_target.u_key, best_target)

							best_target.verified = true
							best_target.verified_t = data.t
							best_target.verified_dis = mvec3_dis(my_pos, attention_pos)

							mvec3_set(best_target.verified_pos, attention_pos)

							if best_target.last_verified_pos then
								mvec3_set(best_target.last_verified_pos, attention_pos)
							else
								best_target.last_verified_pos = mvec3_cpy(attention_pos)
							end

							data.detected_attention_objects[u_key] = best_target

							return best_target, 1, REACT_SHOOT
						end
					end
				--else
					--Application:error("[CopLogicIdle._get_priority_attention] No attention object available for unit", inspect(forced_attention_data))
				end
			end
		end
	end

	if not data.cool then ----if there's a way to check if players have this equipped, that would make this even better
		local closest_chico_target, closest_chico_dis, reac = nil

		for record_key, record_data in pairs(managers.groupai:state():all_player_criminals()) do
			local att_data = data.detected_attention_objects[record_key]
			local valid_chico_target = nil

			if att_data and att_data.verified then
				local reaction = reaction_func(data, att_data, not CopLogicAttack._can_move(data))

				if reaction and reaction >= REACT_COMBAT then
					if att_data.is_local_player then
						if managers.player:upgrade_value("player", "chico_preferred_target", false) and managers.player:has_activate_temporary_upgrade("temporary", "chico_injector") then
							reac = reaction
							valid_chico_target = true
						end
					elseif att_data.is_husk_player then
						local u_base = att_data.unit:base()

						if u_base.upgrade_value and u_base.has_activate_temporary_upgrade and u_base:upgrade_value("player", "chico_preferred_target") and u_base:has_activate_temporary_upgrade("temporary", "chico_injector") then
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
	end

	local near_threshold = data.internal_data.weapon_range.optimal
	local too_close_threshold = data.internal_data.weapon_range.close
	local tactics = data.tactics
	local harasser = tactics and tactics.harass
	local spoocavoider = tactics and tactics.spoocavoidance
	local tunnel_enemy = data.tunnel_focus

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
				local distance = attention_data.dis
				local reaction = reaction_func(data, attention_data, not CopLogicAttack._can_move(data))

				if data.cool and REACT_SCARED <= reaction then
					local giveaway = managers.groupai:state().analyse_giveaway(data.unit:base()._tweak_table, att_unit)

					data.unit:movement():set_cool(false, giveaway)
				end

				local reaction_too_mild = nil

				if not reaction or best_target_reaction and reaction < best_target_reaction then
					reaction_too_mild = true
				elseif distance < 150 and reaction == REACT_IDLE then
					reaction_too_mild = true
				end

				if not reaction_too_mild then
					local weight_mul = attention_data.settings.weight_mul or 1
					local visible = attention_data.verified
					local alert_dt = attention_data.alert_t and data.t - attention_data.alert_t or 10000
					local dmg_dt = attention_data.dmg_t and data.t - attention_data.dmg_t or 10000
					local target_priority = nil
					local target_priority_slot = 0
					local valid_harass = nil

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
							
							if harasser and cur_state:_is_reloading() then
								valid_harass = true
							end

							--[[if managers.player:has_activate_temporary_upgrade("temporary", "chico_injector") and managers.player:upgrade_value("player", "chico_preferred_target", false) then
								weight_mul = weight_mul * 1000
							end]]

							if is_local_vr and tweak_data.vr.long_range_damage_reduction_distance[1] < distance then
								local mul = math_clamp(distance / tweak_data.vr.long_range_damage_reduction_distance[2] / 2, 0, 1) + 1
								weight_mul = weight_mul * mul
							end
						elseif attention_data.is_husk_player then
							local att_base_ext = att_unit:base()

							if harasser then
								local anim_data = att_unit:anim_data()

								if anim_data and anim_data.reload then
									valid_harass = true
								end
							end

							if att_base_ext and att_base_ext.upgrade_value then
								local att_move_ext = att_unit:movement()

								if att_move_ext and not att_move_ext._move_data and att_move_ext._pose_code and att_move_ext._pose_code == 2 then
									local mul = att_base_ext:upgrade_value("player", "stand_still_crouch_camouflage_bonus")

									if mul then
										weight_mul = weight_mul * mul
									end
								end

								--[[if att_base_ext.has_activate_temporary_upgrade and att_base_ext:has_activate_temporary_upgrade("temporary", "chico_injector") and att_base_ext:upgrade_value("player", "chico_preferred_target") then
									weight_mul = weight_mul * 1000
								end]]

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

						if spoocavoider then
							if aimed_at and distance < 2000 then
								target_priority_slot = target_priority_slot - 2
							end
						end

						if data.attention_obj and data.attention_obj.u_key == u_key then
							if not attention_data.acquire_t then
								log("coplogicidle: no acquire_t defined somehow")

								local my_unit = data.unit

								if not alive(my_unit) then
									log("coplogicidle: unit was destroyed!")
								elseif my_unit:in_slot(0) then
									log("coplogicidle: unit is being destroyed!")
								else
									log("coplogicidle: unit is still intact on the C side")

									local my_base_ext = my_unit:base()

									if not my_base_ext then
										log("coplogicidle: unit has no base() extension")
									elseif my_base_ext._tweak_table then
										log("coplogicidle: unit has tweak table: " .. tostring(my_base_ext._tweak_table) .. "")
									else
										log("coplogicidle: unit has no tweak table")
									end

									local my_dmg_ext = my_unit:character_damage()

									if not my_dmg_ext then
										log("coplogicidle: unit has no character_damage() extension")
									elseif my_dmg_ext.dead and my_dmg_ext:dead() then
										log("coplogicidle: unit is dead")
									end
								end

								local cur_logic_name = data.name

								if cur_logic_name then
									log("coplogicidle: logic name: " .. tostring(cur_logic_name) .. "")
								end

								local att_unit = data.attention_obj.unit

								if not alive(att_unit) then
									log("coplogicidle: attention unit was destroyed!")
								elseif att_unit:in_slot(0) then
									log("coplogicidle: attention unit is being destroyed!")
								else
									log("coplogicidle: attention unit is still intact on the C side")

									local unit_name = att_unit.name and att_unit:name()

									if unit_name then
										--might be pure gibberish
										log("coplogicidle: attention unit name: " .. tostring(unit_name) .. "")
									end

									if att_unit:id() == -1 then
										log("coplogicidle: attention unit was detached from the network")
									end

									local att_base_ext = att_unit:base()

									if not att_base_ext then
										log("coplogicidle: attention unit has no base() extension")
									elseif att_base_ext._tweak_table then
										log("coplogicidle: attention unit has tweak table: " .. tostring(att_base_ext._tweak_table) .. "")
									elseif att_base_ext.is_husk_player then
										log("coplogicidle: attention unit was a player husk")
									elseif att_base_ext.is_local_player then
										log("coplogicidle: attention unit was the local player")
									end

									local att_dmg_ext = att_unit:character_damage()

									if not att_dmg_ext then
										log("coplogicidle: attention unit has no character_damage() extension")
									elseif att_dmg_ext.dead and att_dmg_ext:dead() then
										log("coplogicidle: attention unit is dead")
									end
								end

								local cam_pos = managers.viewport:get_current_camera_position()

								if cam_pos then
									local from_pos = cam_pos + math.DOWN * 50

									local brush = Draw:brush(Color.red:with_alpha(0.5), 10)
									brush:cylinder(from_pos, my_unit:movement():m_com(), 10)
								end
							elseif data.t - attention_data.acquire_t < 4 then --old enemy
								target_priority_slot = target_priority_slot - 3
							end
						end

						if tunnel_enemy and u_key ~= tunnel_enemy then
							target_priority_slot = target_priority_slot + 10
						end

						if harasser then
							if valid_harass then
								target_priority_slot = target_priority_slot - 3
							end
						else
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

						if harasser then
							if attention_data.is_local_player then
								local cur_state = att_unit:movement():current_state()

								if cur_state:_is_reloading() then
									target_priority_slot = target_priority_slot - 3
								end
							elseif attention_data.is_husk_player then							
								local anim_data = att_unit:anim_data()

								if anim_data.reload then
									target_priority_slot = target_priority_slot - 3
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

						local has_damaged = dmg_dt < 5

						if has_damaged then
							target_priority_slot = target_priority_slot - 2
						else
							local has_alerted = alert_dt < 3.5

							if has_alerted then
								target_priority_slot = target_priority_slot - 1
							end
						end

						target_priority_slot = math_clamp(target_priority_slot, 1, 10)
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

	return best_target, best_target_priority_slot, best_target_reaction
end

function CopLogicIdle._upd_curious_reaction(data)
	local my_data = data.internal_data
	local attention_obj = data.attention_obj
	local is_suspicious = data.cool and attention_obj.reaction == REACT_SUSPICIOUS
	local my_fwd = data.unit:movement():m_rot():y()
	local target_vec = attention_obj.m_pos - data.m_pos
	local att_spin = target_vec:to_polar_with_reference(my_fwd, math_up).spin
	local turn_spin = 70
	local turned_around = nil

	if turn_spin < math_abs(att_spin) then
		if CopLogicIdle._can_turn(data, my_data) then
			if not attention_obj.settings.turn_around_range or attention_obj.dis < attention_obj.settings.turn_around_range then
				if CopLogicIdle._turn_by_spin(data, my_data, att_spin) then
					if my_data.rubberband_rotation then
						my_data.fwd_offset = true
					end

					turned_around = true
				end
			end
		end
	else
		turned_around = true
	end

	if not turned_around then
		--[[local my_head_fwd = data.unit:movement():m_head_rot():z()
		local target_head_vec = attention_obj.m_head_pos - data.unit:movement():m_head_pos()
		local att_head_spin = target_head_vec:to_polar_with_reference(my_head_fwd, math_up).spin

		if turn_spin < math_abs(att_head_spin) then]]
			local set_attention = data.unit:movement():attention()

			if set_attention and set_attention.handler then
				CopLogicBase._reset_attention(data)
			end

			if is_suspicious then
				CopLogicBase._upd_suspicion(data, my_data, attention_obj)
			end

			return
		--end
	end

	local set_attention = data.unit:movement():attention()

	if not set_attention or set_attention.u_key ~= attention_obj.u_key then
		CopLogicBase._set_attention(data, attention_obj)
	end

	if is_suspicious and not CopLogicBase._upd_suspicion(data, my_data, attention_obj) then
		CopLogicBase._chk_say_criminal_too_close(data, attention_obj)
	end
end

--[[function CopLogicIdle._upd_curious_reaction(data)
	local my_data = data.internal_data
	local attention_obj = data.attention_obj
	local is_suspicious = data.cool and attention_obj.reaction == REACT_SUSPICIOUS
	local my_fwd = data.unit:movement():m_rot():y()
	local target_vec = attention_obj.m_pos - data.m_pos
	local att_spin = target_vec:to_polar_with_reference(my_fwd, math_up).spin
	local turn_spin = 70
	local turned_around = nil

	if turn_spin < math_abs(att_spin) then
		if CopLogicIdle._can_turn(data, my_data) then
			if not attention_obj.settings.turn_around_range or attention_obj.dis < attention_obj.settings.turn_around_range then
				if CopLogicIdle._turn_by_spin(data, my_data, att_spin) then
					if my_data.rubberband_rotation then
						my_data.fwd_offset = true
					end

					turned_around = true
				end
			end
		end
	else
		turned_around = true
	end

	if not turned_around then
		local my_head_fwd = data.unit:movement():m_head_rot():z()
		local target_head_vec = attention_obj.m_head_pos - data.unit:movement():m_head_pos()
		local att_head_spin = target_head_vec:to_polar_with_reference(my_head_fwd, math_up).spin

		if turn_spin < math_abs(att_head_spin) then
			local set_attention = data.unit:movement():attention()

			if set_attention and set_attention.handler then
				CopLogicBase._reset_attention(data)
			end

			return
		end
	end

	local set_attention = data.unit:movement():attention()

	if not set_attention or set_attention.u_key ~= attention_obj.u_key then
		CopLogicBase._set_attention(data, attention_obj)
	end

	return is_suspicious and CopLogicBase._upd_suspicion(data, my_data, attention_obj) or true
end]]

function CopLogicIdle._turn_by_spin(data, my_data, spin)
	local new_action_data = {
		body_part = 2,
		type = "turn",
		angle = spin
	}
	my_data.turning = data.brain:action_request(new_action_data)

	if my_data.turning then
		return true
	end
end

function CopLogicIdle._chk_objective_needs_travel(data, new_objective)
	if not new_objective.nav_seg and new_objective.type ~= "follow" then
		return
	end

	if new_objective.in_place then
		return
	end

	local objective_pos = new_objective.pos

	if objective_pos then
		--[[if mvec3_equal(data.m_pos, objective_pos) or mvec3_dis(data.m_pos, objective_pos) < 10 then ----
			data.unit:movement():set_position(objective_pos)

			if new_objective.rot then
				data.unit:movement():set_rotation(new_objective.rot)
			end

			CopLogicTravel._on_destination_reached(data)
		end]]

		return true
	end

	if new_objective.area and new_objective.area.nav_segs[data.unit:movement():nav_tracker():nav_segment()] then
		new_objective.in_place = true

		return
	end

	return true
end

function CopLogicIdle._upd_stance_and_pose(data, my_data, objective)
	if data.unit:movement():chk_action_forbidden("walk") then
		return
	end

	local obj_has_stance, obj_has_pose = nil

	if objective then
		if objective.stance then
			if not data.char_tweak.allowed_stances or data.char_tweak.allowed_stances[objective.stance] then
				obj_has_stance = true
				local upper_body_action = data.unit:movement()._active_actions[3]

				if not upper_body_action or upper_body_action:type() ~= "shoot" then
					data.unit:movement():set_stance(objective.stance)
				end
			end
		end

		if objective.pose and not data.is_suppressed then
			if not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses[objective.pose] then
				obj_has_pose = true

				if objective.pose == "crouch" then
					CopLogicAttack._chk_request_action_crouch(data)
				elseif objective.pose == "stand" then
					CopLogicAttack._chk_request_action_stand(data)
				end
			end
		end
	end

	if not obj_has_stance and data.char_tweak.allowed_stances and not data.char_tweak.allowed_stances[data.unit:anim_data().stance] then
		for stance_name, state in pairs(data.char_tweak.allowed_stances) do
			if state then
				data.unit:movement():set_stance(stance_name)

				break
			end
		end
	end

	if not obj_has_pose then
		local suppression_crouch = nil

		if data.is_suppressed and not data.unit:anim_data().crouch then
			if not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch then
				suppression_crouch = true

				CopLogicAttack._chk_request_action_crouch(data)
			end
		end

		if not suppression_crouch and data.char_tweak.allowed_poses and not data.char_tweak.allowed_poses[data.unit:anim_data().pose] then
			for pose_name, state in pairs(data.char_tweak.allowed_poses) do
				if state then
					if pose_name == "crouch" then
						CopLogicAttack._chk_request_action_crouch(data)

						break
					elseif pose_name == "stand" then
						CopLogicAttack._chk_request_action_stand(data)

						break
					end
				end
			end
		end
	end
end

function CopLogicIdle._perform_objective_action(data, my_data, objective)
	if objective and not my_data.action_started then
		if data.unit:anim_data().act_idle or not data.unit:movement():chk_action_forbidden("action") then
			if objective.action then
				my_data.action_started = data.brain:action_request(objective.action)
			else
				my_data.action_started = true
			end

			if my_data.action_started then
				if objective.action_duration or objective.action_timeout_t then
					my_data.action_timeout_clbk_id = "CopLogicIdle_action_timeout" .. tostring(data.key)
					local action_timeout_t = objective.action_timeout_t or data.t + objective.action_duration
					objective.action_timeout_t = action_timeout_t

					CopLogicBase.add_delayed_clbk(my_data, my_data.action_timeout_clbk_id, callback(CopLogicIdle, CopLogicIdle, "clbk_action_timeout", data), action_timeout_t)
				end

				if objective.action_start_clbk then
					objective.action_start_clbk(data.unit)
				end
			end
		end
	end
end

function CopLogicIdle._upd_stop_old_action(data, my_data, objective)
	local can_stop_action = nil

	if objective then
		if objective.type == "free" then
			can_stop_action = true
		elseif objective.action and not my_data.action_started and not data.unit:anim_data().to_idle then
			can_stop_action = true
		end
	end

	if not can_stop_action then
		return
	end

	if my_data.advancing then
		if not data.unit:movement():chk_action_forbidden("idle") then
			data.brain:action_request({
				sync = true,
				body_part = 2,
				type = "idle"
			})
		end
	elseif not data.unit:movement():chk_action_forbidden("idle") and data.unit:anim_data().needs_idle then
		CopLogicIdle._start_idle_action_from_act(data)
	elseif data.unit:anim_data().act_idle then
		data.brain:action_request({
			sync = true,
			body_part = 2,
			type = "idle"
		})
	end

	CopLogicIdle._chk_has_old_action(data, my_data)
end

function CopLogicIdle._chk_has_old_action(data, my_data)
	local anim_data = data.unit:anim_data()
	my_data.has_old_action = anim_data.to_idle or anim_data.act
	local lower_body_action = data.unit:movement()._active_actions[2]
	my_data.advancing = lower_body_action and lower_body_action:type() == "walk" and lower_body_action
end

function CopLogicIdle._start_idle_action_from_act(data)
	data.brain:action_request({
		variant = "idle",
		body_part = 1,
		type = "act",
		blocks = {
			light_hurt = -1,
			hurt = -1,
			action = -1,
			expl_hurt = -1,
			heavy_hurt = -1,
			idle = -1,
			fire_hurt = -1,
			walk = -1
		}
	})
end
