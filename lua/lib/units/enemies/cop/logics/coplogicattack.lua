--local mvec3_x = mvector3.x
--local mvec3_y = mvector3.y
--local mvec3_z = mvector3.z
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_dir = mvector3.direction
local mvec3_dot = mvector3.dot
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
--local mvec3_lerp = mvector3.lerp
local mvec3_norm = mvector3.normalize
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
--local mvec3_cross = mvector3.cross
--local mvec3_rand_ortho = mvector3.random_orthogonal
--local mvec3_negate = mvector3.negate
--local mvec3_len = mvector3.length
local mvec3_len_sq = mvector3.length_sq
local mvec3_cpy = mvector3.copy
--local mvec3_set_stat = mvector3.set_static
local mvec3_set_length = mvector3.set_length
--local mvec3_angle = mvector3.angle
local mvec3_step = mvector3.step
local mvec3_rotate_with = mvector3.rotate_with

local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
local temp_vec3 = Vector3()

local math_lerp = math.lerp
local math_random = math.random
local math_up = math.UP
local math_abs = math.abs
local math_clamp = math.clamp
local math_min = math.min
local math_max = math.max
local math_sign = math.sign

local table_insert = table.insert

local clone_g = clone

local REACT_AIM = AIAttentionObject.REACT_AIM
local REACT_COMBAT = AIAttentionObject.REACT_COMBAT
local REACT_SHOOT = AIAttentionObject.REACT_SHOOT

function CopLogicAttack.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.brain:cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit
	}
	my_data.detection = data.char_tweak.detection.combat

	if old_internal_data then
		my_data.turning = old_internal_data.turning
		my_data.firing = old_internal_data.firing
		my_data.shooting = old_internal_data.shooting
		my_data.attention_unit = old_internal_data.attention_unit

		CopLogicAttack._set_best_cover(data, my_data, old_internal_data.best_cover)
	end

	data.internal_data = my_data

	if data.cool then
		data.unit:movement():set_cool(false)

		if my_data ~= data.internal_data then
			return
		end
	end

	local objective = data.objective

	if not my_data.shooting then
		local new_stance = objective and objective.stance ~= "ntl" and objective.stance or "hos"

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

	my_data.cover_test_step = 1

	CopLogicIdle._chk_has_old_action(data, my_data)

	local key_str = tostring(data.key)
	my_data.detection_task_key = "CopLogicAttack._upd_enemy_detection" .. key_str

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicAttack._upd_enemy_detection, data, data.t, data.important and true)

	if objective then
		if objective.action_duration or objective.action_timeout_t and data.t < objective.action_timeout_t then
			my_data.action_timeout_clbk_id = "CopLogicIdle_action_timeout" .. key_str
			local action_timeout_t = objective.action_timeout_t or data.t + objective.action_duration
			objective.action_timeout_t = action_timeout_t

			CopLogicBase.add_delayed_clbk(my_data, my_data.action_timeout_clbk_id, callback(CopLogicIdle, CopLogicIdle, "clbk_action_timeout", data), action_timeout_t)
		end
	end

	my_data.attitude = objective and objective.attitude or "avoid"
	my_data.weapon_range = clone_g(data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range)
	
	if data.tactics then
		if data.tactics.ranged_fire or data.tactics.elite_ranged_fire then
			my_data.weapon_range.close = my_data.weapon_range.close * 2
			my_data.weapon_range.optimal = my_data.weapon_range.optimal * 1.5
		end
	end

	data.brain:set_attention_settings({
		cbt = true
	})
	data.brain:set_update_enabled_state(true)
end

function CopLogicAttack.exit(data, new_logic_name, enter_params)
	CopLogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	data.brain:cancel_all_pathing_searches()
	CopLogicBase.cancel_queued_tasks(my_data)
	CopLogicBase.cancel_delayed_clbks(my_data)

	if my_data.best_cover then
		managers.navigation:release_cover(my_data.best_cover[1])
	end

	data.brain:rem_pos_rsrv("path")
	data.brain:set_update_enabled_state(true)
end

function CopLogicAttack.update(data)
	local my_data = data.internal_data

	if not my_data.update_queue_id then
		data.t = TimerManager:game():time()
	end

	if my_data.has_old_action then
		CopLogicAttack._upd_stop_old_action(data, my_data)

		if not my_data.update_queue_id then
			data.brain:set_update_enabled_state(false)

			my_data.update_queue_id = "CopLogicAttack.queued_update" .. tostring(data.key)

			CopLogicAttack.queue_update(data, my_data)
		end

		return
	end

	local groupai = managers.groupai:state()
	
	if data.is_converted then
		if not data.objective or data.objective.type == "free" then
			if not data.path_fail_t or data.t - data.path_fail_t > 6 then
				groupai:on_criminal_jobless(data.unit)

				if my_data ~= data.internal_data then
					return
				end
			end
		end
	end

	if CopLogicIdle._chk_relocate(data) or CopLogicAttack._chk_exit_non_walkable_area(data) then
		return
	end

	if not data.attention_obj or data.attention_obj.reaction < REACT_AIM then
		CopLogicAttack._upd_enemy_detection(data, true)

		if my_data ~= data.internal_data then
			return
		end
	end

	CopLogicAttack._process_pathing_results(data, my_data)

	if data.attention_obj and REACT_COMBAT <= data.attention_obj.reaction then
		my_data.want_to_take_cover = CopLogicAttack._chk_wants_to_take_cover(data, my_data)

		CopLogicAttack._update_cover(data)
		
		
		--uncomment to draw cover stuff or whatever
		
		--[[if my_data.want_to_take_cover then
			if my_data.best_cover then
				local line = Draw:brush(Color.blue:with_alpha(0.5), 0.2)
				line:cylinder(data.m_pos, my_data.best_cover[1][1], 5)
			end
			
			if my_data.in_cover then
				local line = Draw:brush(Color.blue:with_alpha(0.5), 0.2)
				line:cylinder(my_data.in_cover[1][1], my_data.in_cover[1][1] + math_up * 185, 100)
			end
		end]]
		
		CopLogicAttack._upd_combat_movement(data)
		
		if not data.char_tweak.cannot_throw_grenades and not data.is_converted and data.unit:base().has_tag and data.unit:base():has_tag("law") and groupai:is_smoke_grenade_active() then 
			CopLogicBase.do_smart_grenade(data, my_data, data.attention_obj)
		end
	end

	if not data.logic.action_taken then
		CopLogicAttack._chk_start_action_move_out_of_the_way(data, my_data)
	end

	if not my_data.update_queue_id then
		data.brain:set_update_enabled_state(false)

		my_data.update_queue_id = "CopLogicAttack.queued_update" .. tostring(data.key)

		CopLogicAttack.queue_update(data, my_data)
	end
end

function CopLogicAttack._upd_combat_movement(data)
	local my_data = data.internal_data
	local t = data.t
	local unit = data.unit
	local focus_enemy = data.attention_obj
	local action_taken = nil

	if not my_data.surprised and data.important and focus_enemy.verified and not my_data.turning and CopLogicAttack._can_move(data) and not unit:movement():chk_action_forbidden("walk") then
		if not my_data.in_cover or not my_data.in_cover[4] then
			if data.is_suppressed and t - unit:character_damage():last_suppression_t() < 0.7 then
				action_taken = CopLogicBase.chk_start_action_dodge(data, "scared")
			end

			if not action_taken and focus_enemy.is_person and focus_enemy.aimed_at and focus_enemy.dis < 2000 then
				--if data.group and data.group.size > 1 or math_random() < 0.5 then --unnecessary extra RNG
					local dodge = nil

					if focus_enemy.is_local_player then
						local e_movement_state = focus_enemy.unit:movement():current_state()

						if not e_movement_state:_is_reloading() and not e_movement_state:_interacting() and not e_movement_state:is_equipping() then
							dodge = true
						end
					else
						local e_anim_data = focus_enemy.unit:anim_data()

						if not e_anim_data.reload then
							if e_anim_data.move or e_anim_data.idle then
								dodge = true
							end
						end
					end

					if dodge then
						action_taken = CopLogicBase.chk_start_action_dodge(data, "preemptive")
					end
				--end
			end
		end
	end

	action_taken = action_taken or data.logic.action_taken(data, my_data) or CopLogicAttack._upd_pose(data, my_data)
	
	local tactics = data.tactics
	local soft_t = 2
	local softer_t = 15
	
	if tactics and tactics.charge then
		soft_t = 0.5
		softer_t = 7
	end
	
	local enemy_visible_soft = focus_enemy.verified_t and t - focus_enemy.verified_t < soft_t
	local enemy_visible_softer = focus_enemy.verified_t and t - focus_enemy.verified_t < softer_t
	local want_to_take_cover = my_data.want_to_take_cover

	if my_data.cover_test_step ~= 1 and not enemy_visible_softer then
		if action_taken or want_to_take_cover or not my_data.in_cover then
			my_data.cover_test_step = 1
		end
	end

	local remove_stay_out_time = nil

	if my_data.stay_out_time then
		if enemy_visible_soft or not my_data.at_cover_shoot_pos or action_taken or want_to_take_cover then
			remove_stay_out_time = true
		end
	end

	if remove_stay_out_time then
		my_data.stay_out_time = nil
	elseif not my_data.stay_out_time and not enemy_visible_soft and my_data.at_cover_shoot_pos and not action_taken then
		my_data.stay_out_time = t + 7
	end

	local move_to_cover, want_flank_cover = nil
	local valid_harass = nil
	
	if tactics and tactics.harass then		
		if not data.unit:in_slot(16) and not data.is_converted and focus_enemy.is_person then
			if focus_enemy.is_local_player then
				local e_movement_state = focus_enemy.unit:movement():current_state()
							
				if e_movement_state:_is_reloading() then
					valid_harass = true
				end
			else
				local e_anim_data = focus_enemy.unit:anim_data()

				if e_anim_data.reload then
					valid_harass = true
				end
			end
		end
					
		if valid_harass then
			managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "reload")
		end
	end

	if not action_taken then
		if want_to_take_cover then
			move_to_cover = true
		elseif not enemy_visible_soft then
			if tactics then			
				if data.objective and data.objective.grp_objective and data.objective.grp_objective.charge or valid_harass then
					if not my_data.charge_path_failed_t or t - my_data.charge_path_failed_t > 3 then
						if my_data.charge_path then
							local path = my_data.charge_path
							my_data.charge_path = nil
							
							--if valid_harass then
							--	log("cum")
							--end
							
							action_taken = CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, "run")
						elseif not my_data.charge_path_search_id and focus_enemy.nav_tracker then
							if tactics.flank then
								my_data.charge_pos = CopLogicAttack._find_flank_pos(data, my_data, focus_enemy.nav_tracker, my_data.weapon_range.optimal) --charge to a position that would put the unit in a flanking position, not a flanking path
							else
								my_data.charge_pos = CopLogicTravel._get_pos_on_wall(focus_enemy.nav_tracker:field_position(), my_data.weapon_range.optimal, 45, nil, data.pos_rsrv_id)
							end

							--my_data.charge_pos = CopLogicTravel._get_pos_on_wall(focus_enemy.nav_tracker:field_position(), my_data.weapon_range.optimal, 45, nil, data.pos_rsrv_id)

							if my_data.charge_pos then
								local my_pos = data.unit:movement():nav_tracker():field_position()
								local unobstructed_line = nil

								if math_abs(my_pos.z - my_data.charge_pos.z) < 40 then
									local ray_params = {
										allow_entry = false,
										pos_from = my_pos,
										pos_to = my_data.charge_pos
									}

									if not managers.navigation:raycast(ray_params) then
										unobstructed_line = true
									end
								end

								if unobstructed_line then
									local path = {
										mvec3_cpy(my_pos),
										my_data.charge_pos
									}

									--[[local line = Draw:brush(Color.blue:with_alpha(0.5), 5)
									line:cylinder(my_pos, my_data.charge_pos, 25)]]

									action_taken = CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, "run")
								else
									data.brain:add_pos_rsrv("path", {
										radius = 60,
										position = mvec3_cpy(my_data.charge_pos)
									})

									my_data.charge_path_search_id = "charge" .. tostring(data.key)

									data.brain:search_for_path(my_data.charge_path_search_id, my_data.charge_pos, nil, nil, nil)
								end
							else
								--debug_pause_unit(unit, "failed to find charge_pos", unit)

								my_data.charge_path_failed_t = t
							end
						end
					end
				elseif my_data.flank_cover and my_data.flank_cover.failed then
					want_flank_cover = true

					if not my_data.charge_path_failed_t or t - my_data.charge_path_failed_t > 3 then --not gonna bother renaming and adding stuff to be used as flank_path as well, so I'm sharing the name even though they're kinda different
						my_data.flank_cover = nil

						if my_data.charge_path then
							local path = my_data.charge_path
							my_data.charge_path = nil

							action_taken = CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, "run")
						elseif not my_data.charge_path_search_id and focus_enemy.nav_tracker then
							my_data.charge_pos = CopLogicAttack._find_flank_pos(data, my_data, focus_enemy.nav_tracker, my_data.weapon_range.optimal) --charge to a position that would put the unit in a flanking position, not really a flanking path

							if my_data.charge_pos then
								local my_pos = data.unit:movement():nav_tracker():field_position()
								local unobstructed_line = nil

								if math_abs(my_pos.z - my_data.charge_pos.z) < 40 then
									local ray_params = {
										allow_entry = false,
										pos_from = my_pos,
										pos_to = my_data.charge_pos
									}

									if not managers.navigation:raycast(ray_params) then
										unobstructed_line = true
									end
								end

								if unobstructed_line then
									local path = {
										mvec3_cpy(my_pos),
										my_data.charge_pos
									}

									--[[local line = Draw:brush(Color.blue:with_alpha(0.5), 5)
									line:cylinder(my_pos, my_data.charge_pos, 25)]]

									action_taken = CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, "run")
								else
									data.brain:add_pos_rsrv("path", {
										radius = 60,
										position = mvec3_cpy(my_data.charge_pos)
									})

									my_data.charge_path_search_id = "charge" .. tostring(data.key)

									data.brain:search_for_path(my_data.charge_path_search_id, my_data.charge_pos, nil, nil, nil)
								end
							else
								--debug_pause_unit(unit, "failed to find charge_pos", unit)

								want_flank_cover = nil
								my_data.charge_path_failed_t = t
							end
						end
					end
				end			
			end
			
			if not action_taken then
				local in_cover = my_data.in_cover
				
				if my_data.attitude == "engage" then
					if in_cover then
						if my_data.cover_test_step <= 2 then
							local height = nil

							if in_cover[4] then --has obstructed high_ray
								height = 150
							else
								height = 80
							end

							local my_tracker = unit:movement():nav_tracker()
							local shoot_from_pos = CopLogicAttack._peek_for_pos_sideways(data, my_data, my_tracker, focus_enemy.m_head_pos, height)

							if shoot_from_pos then
								local path = {
									mvec3_cpy(data.m_pos),
									shoot_from_pos
								}
								action_taken = CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, "walk")
							else
								my_data.cover_test_step = my_data.cover_test_step + 1
							end
						else
							want_flank_cover = true
						end
					elseif not my_data.walking_to_cover_shoot_pos then
						if my_data.at_cover_shoot_pos then
							if my_data.stay_out_time < t then
								move_to_cover = true
							end
						else
							move_to_cover = true
							want_flank_cover = true
						end
					end
				end
			end
		end
	end

	if want_flank_cover then
		if not my_data.flank_cover then
			local sign = math_random() < 0.5 and -1 or 1
			local step = 30
			my_data.flank_cover = {
				step = step,
				angle = step * sign,
				sign = sign
			}
		end
	else
		my_data.flank_cover = nil
	end

	if not action_taken then
		if not my_data.cover_path_failed_t or t - my_data.cover_path_failed_t > 2 then
			local best_cover = my_data.best_cover

			if best_cover and not my_data.processing_cover_path and not my_data.cover_path and not my_data.charge_path_search_id then
				local in_cover = my_data.in_cover

				if not in_cover or best_cover[1] ~= in_cover[1] then
					CopLogicAttack._cancel_cover_pathing(data, my_data)

					local my_pos = data.unit:movement():nav_tracker():field_position()
					local to_cover_pos = my_data.best_cover[1][1]
					local unobstructed_line = nil

					if math_abs(my_pos.z - to_cover_pos.z) < 40 then
						local ray_params = {
							allow_entry = false,
							pos_from = my_pos,
							pos_to = to_cover_pos
						}

						if not managers.navigation:raycast(ray_params) then
							unobstructed_line = true
						end
					end

					if unobstructed_line then
						local path = {
							mvec3_cpy(my_pos),
							mvec3_cpy(to_cover_pos)
						}
						
						my_data.cover_path = path
						
						if move_to_cover then
							action_taken = CopLogicAttack._chk_request_action_walk_to_cover(data, my_data)
						end
					else
						data.brain:add_pos_rsrv("path", {
							radius = 60,
							position = mvec3_cpy(my_data.best_cover[1][1])
						})

						my_data.cover_path_search_id = tostring(data.key) .. "cover"
						my_data.processing_cover_path = best_cover

						data.brain:search_for_path_to_cover(my_data.cover_path_search_id, best_cover[1])
					end
				end
			end
		end
	end

	if not action_taken and move_to_cover and my_data.cover_path then
		action_taken = CopLogicAttack._chk_request_action_walk_to_cover(data, my_data)
	end
	
	if not action_taken then
		if want_to_take_cover and want_to_take_cover ~= true then
			action_taken = CopLogicAttack._chk_start_action_move_back(data, my_data, focus_enemy, my_data.attitude == "engage" and not data.is_suppressed)
		end
	end
end

function CopLogicAttack._chk_start_action_move_back(data, my_data, focus_enemy, vis_required) --keep testing, modify, might want to revert back to vanilla
	if not focus_enemy or not focus_enemy.verified or not CopLogicAttack._can_move(data) then
		return
	end

	local attempt_retreat = nil
	local pose = nil
	local want_to_take_cover = my_data.want_to_take_cover
	local max_walk_dis = 400
	
	if want_to_take_cover then
		attempt_retreat = true
		
		if want_to_take_cover == "spoocavoidance" then
			haste = "run"
			vis_required = nil
			max_walk_dis = 2000
			pose = "crouch"
		elseif want_to_take_cover == "low_ammo" or want_to_take_cover == "hitnrun" then
			vis_required = nil
			haste = "run"
			
			if focus_enemy.dis < 800 then
				max_walk_dis = 800
				pose = "crouch"
			else
				pose = "stand"
			end
		elseif want_to_take_cover == "eliterangedfire" or want_to_take_cover == "reload" then
			if want_to_take_cover == "reload" then
				haste = "run"
				pose = "stand"
				vis_required = nil
			else
				haste = "run"
				pose = "crouch"
			end
			
			max_walk_dis = my_data.weapon_range.optimal * 0.5
		end
	elseif focus_enemy.dis < 250 then
		attempt_retreat = true
	end

	if not attempt_retreat then
		return
	end

	local threat_tracker = focus_enemy.nav_tracker
	local temp_tracker = nil

	if vis_required and not threat_tracker then --this shouldn't even happen, but just in case, we want the unit to still be able to retreat
		local tracker_pos = mvec3_cpy(focus_enemy.m_pos)
		threat_tracker = managers.navigation:create_nav_tracker(tracker_pos)
		temp_tracker = true
	end

	local from_pos = mvec3_cpy(data.m_pos)
	local threat_head_pos = focus_enemy.m_head_pos
	
	pose = pose or data.is_suppressed and "crouch" or "stand"
	local end_pose = pose

	if pose == "crouch" and not data.char_tweak.crouch_move then
		pose = "stand"
	end

	if data.char_tweak.allowed_poses then
		if not data.char_tweak.allowed_poses.crouch then
			pose = "stand"
			end_pose = "stand"
		elseif not data.char_tweak.allowed_poses.stand then
			pose = "crouch"
			end_pose = "crouch"
		end
	end

	local retreat_to = CopLogicAttack._find_retreat_position(data, from_pos, focus_enemy.m_pos, threat_head_pos, threat_tracker, max_walk_dis, vis_required, end_pose)

	if retreat_to then
		CopLogicAttack._cancel_cover_pathing(data, my_data)

		local new_action_data = {
			variant = haste or "walk",
			body_part = 2,
			type = "walk",
			nav_path = {
				from_pos,
				retreat_to
			},
			pose = pose,
			end_pose = end_pose
		}
		my_data.advancing = data.brain:action_request(new_action_data)

		if my_data.advancing then
			if want_to_take_cover and want_to_take_cover ~= true then
				if data.tactics then
					if data.tactics.smoke_grenade or data.tactics.flash_grenade then
						local flash = not data.tactics.smoke_grenade or data.tactics.flash_grenade and math.random() < 0.5
						local pos = not flash and data.m_pos or focus_enemy.m_pos
						
						CopLogicBase.do_grenade(data, pos + math.UP * 5, flash, not flash)
					end
				end
			end
			
			my_data.at_cover_shoot_pos = nil
			my_data.in_cover = nil
		
			my_data.surprised = true

			data.brain:rem_pos_rsrv("path")

			if temp_tracker then
				managers.navigation:destroy_nav_tracker(threat_tracker)
			end

			return true
		end
	end

	if temp_tracker then
		managers.navigation:destroy_nav_tracker(threat_tracker)
	end
end

function CopLogicAttack._chk_start_action_move_out_of_the_way(data, my_data)
	local reservation = {
		radius = 30,
		position = data.m_pos,
		filter = data.pos_rsrv_id
	}

	if not managers.navigation:is_pos_free(reservation) then
		local to_pos = CopLogicTravel._get_pos_on_wall(data.m_pos, 500, nil, nil, data.pos_rsrv_id)

		if to_pos then
			local path = {
				mvec3_cpy(data.m_pos),
				to_pos
			}

			return CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, "run")
		end
	end
end

function CopLogicAttack.queued_update(data)
	local my_data = data.internal_data
	data.t = TimerManager:game():time()

	CopLogicAttack.update(data)

	if data.internal_data == my_data then
		CopLogicAttack.queue_update(data, data.internal_data)
	end
end

function CopLogicAttack._peek_for_pos_sideways(data, my_data, my_tracker, peek_to_pos, height)
	local unit = data.unit
	local enemy_pos = peek_to_pos
	local my_pos = unit:movement():m_pos()
	local back_vec = my_pos - enemy_pos

	mvec3_set_z(back_vec, 0)
	mvec3_set_length(back_vec, 75)

	local back_pos = my_pos + back_vec
	local ray_params = {
		allow_entry = true,
		trace = true,
		tracker_from = my_tracker,
		pos_to = back_pos
	}
	local ray_res = managers.navigation:raycast(ray_params)
	back_pos = ray_params.trace[1]
	local back_polar = (back_pos - my_pos):to_polar()
	local right_polar = back_polar:with_spin(back_polar.spin + 90):with_r(100 + 80 * my_data.cover_test_step)
	local right_vec = right_polar:to_vector()
	local right_pos = back_pos + right_vec
	ray_params.pos_to = right_pos
	local ray_res = managers.navigation:raycast(ray_params)
	local shoot_from_pos = nil
	local ray_softness = 150
	local stand_ray = unit:raycast("ray", ray_params.trace[1] + math_up * height, enemy_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision")

	if not stand_ray or mvec3_dis(stand_ray.position, enemy_pos) < ray_softness then
		local test_pos = ray_params.trace[1]
		local reservation = {
			radius = 30,
			position = test_pos,
			filter = data.pos_rsrv_id
		}

		if managers.navigation:is_pos_free(reservation) then
			shoot_from_pos = test_pos
		end
	end

	if not shoot_from_pos then
		local left_pos = back_pos - right_vec
		ray_params.pos_to = left_pos
		local ray_res = managers.navigation:raycast(ray_params)
		local stand_ray = unit:raycast("ray", ray_params.trace[1] + math_up * height, enemy_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision")

		if not stand_ray or mvec3_dis(stand_ray.position, enemy_pos) < ray_softness then
			local test_pos = ray_params.trace[1]
			local reservation = {
				radius = 30,
				position = test_pos,
				filter = data.pos_rsrv_id
			}

			if managers.navigation:is_pos_free(reservation) then
				shoot_from_pos = test_pos
			end
		end
	end

	return shoot_from_pos
end

function CopLogicAttack._cancel_cover_pathing(data, my_data)
	if my_data.processing_cover_path then
		if data.active_searches[my_data.cover_path_search_id] then
			managers.navigation:cancel_pathing_search(my_data.cover_path_search_id)

			data.active_searches[my_data.cover_path_search_id] = nil
		elseif data.pathing_results then
			data.pathing_results[my_data.cover_path_search_id] = nil
		end

		my_data.processing_cover_path = nil
		my_data.cover_path_search_id = nil
	end

	my_data.cover_path = nil
end

function CopLogicAttack._cancel_charge(data, my_data)
	my_data.charge_pos = nil
	my_data.charge_path = nil

	if my_data.charge_path_search_id then
		if data.active_searches[my_data.charge_path_search_id] then
			managers.navigation:cancel_pathing_search(my_data.charge_path_search_id)

			data.active_searches[my_data.charge_path_search_id] = nil
		elseif data.pathing_results then
			data.pathing_results[my_data.charge_path_search_id] = nil
		end

		my_data.charge_path_search_id = nil
	end
end

function CopLogicAttack._cancel_expected_pos_path(data, my_data)
	my_data.expected_pos_path = nil

	if my_data.expected_pos_path_search_id then
		if data.active_searches[my_data.expected_pos_path_search_id] then
			managers.navigation:cancel_pathing_search(my_data.expected_pos_path_search_id)

			data.active_searches[my_data.expected_pos_path_search_id] = nil
		elseif data.pathing_results then
			data.pathing_results[my_data.expected_pos_path_search_id] = nil
		end

		my_data.expected_pos_path_search_id = nil
	end
end

function CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, my_pos, enemy_pos)
	local fwd = data.unit:movement():m_rot():y()
	local target_vec = enemy_pos - my_pos
	local error_spin = target_vec:to_polar_with_reference(fwd, math_up).spin

	if math_abs(error_spin) > 27 then
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

function CopLogicAttack._cancel_walking_to_cover(data, my_data, skip_action)
	my_data.cover_path = nil

	if my_data.moving_to_cover then
		if not skip_action then
			local new_action = {
				body_part = 2,
				type = "idle"
			}

			data.brain:action_request(new_action)
		end
	elseif my_data.processing_cover_path then
		data.brain:cancel_all_pathing_searches()

		my_data.cover_path_search_id = nil
		my_data.processing_cover_path = nil
	end
end

function CopLogicAttack._chk_request_action_walk_to_cover(data, my_data)
	CopLogicAttack._correct_path_start_pos(data, my_data.cover_path)
	
	local haste = nil
	local pose = nil
	local i = 1
	local travel_dis = 0
	
	repeat
		if my_data.cover_path[i + 1] then
			travel_dis = travel_dis + mvec3_dis(my_data.cover_path[i], my_data.cover_path[i + 1])
			i = i + 1
		else
			break
		end
	until travel_dis > 800 or i >= #my_data.cover_path
	
	if travel_dis > 400 then
		haste = "run"
	end
	
	if travel_dis > 800 then
		pose = "stand"
	else
		pose = data.unit:anim_data().crouch and "crouch"
	end

	haste = haste or "walk"
	pose = pose or data.is_suppressed and "crouch" or "stand"

	local end_pose = my_data.moving_to_cover and "crouch" or "stand"

	if pose == "crouch" and not data.char_tweak.crouch_move then
		pose = "stand"
	end

	if data.char_tweak.allowed_poses then
		if not data.char_tweak.allowed_poses.crouch then
			pose = "stand"
			end_pose = "stand"
		elseif not data.char_tweak.allowed_poses.stand then
			pose = "crouch"
			end_pose = "crouch"
		end
	end

	local new_action_data = {
		type = "walk",
		body_part = 2,
		nav_path = my_data.cover_path,
		variant = haste,
		pose = pose,
		end_pose = end_pose
	}
	my_data.cover_path = nil
	my_data.advancing = data.brain:action_request(new_action_data)

	if my_data.advancing then
		my_data.moving_to_cover = my_data.best_cover
		my_data.at_cover_shoot_pos = nil
		my_data.in_cover = nil

		data.brain:rem_pos_rsrv("path")

		return true
	end
end

function CopLogicAttack._correct_path_start_pos(data, path)
	local first_nav_point = path[1]
	local my_pos = data.m_pos

	if first_nav_point.x ~= my_pos.x or first_nav_point.y ~= my_pos.y then
		table_insert(path, 1, mvec3_cpy(my_pos))
	end
end

function CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, speed)
	CopLogicAttack._cancel_cover_pathing(data, my_data)
	CopLogicAttack._cancel_charge(data, my_data)
	CopLogicAttack._correct_path_start_pos(data, path)

	local pose = data.is_suppressed and "crouch" or "stand"
	local end_pose = pose

	if pose == "crouch" and not data.char_tweak.crouch_move then
		pose = "stand"
	end

	if data.char_tweak.allowed_poses then
		if not data.char_tweak.allowed_poses.crouch then
			pose = "stand"
			end_pose = "stand"
		elseif not data.char_tweak.allowed_poses.stand then
			pose = "crouch"
			end_pose = "crouch"
		end
	end

	local new_action_data = {
		body_part = 2,
		type = "walk",
		nav_path = path,
		variant = speed or "walk",
		pose = pose,
		end_pose = end_pose
	}
	my_data.cover_path = nil
	my_data.advancing = data.brain:action_request(new_action_data)

	if my_data.advancing then
		my_data.walking_to_cover_shoot_pos = my_data.advancing
		my_data.at_cover_shoot_pos = nil
		my_data.in_cover = nil

		data.brain:rem_pos_rsrv("path")

		return true
	end
end

function CopLogicAttack._chk_request_action_crouch(data)
	if data.unit:anim_data().crouch or data.unit:movement():chk_action_forbidden("crouch") then
		return
	end

	local new_action_data = {
		body_part = 4,
		type = "crouch"
	}
	local res = data.brain:action_request(new_action_data)

	return res
end

function CopLogicAttack._chk_request_action_stand(data)
	if data.unit:anim_data().stand or data.unit:movement():chk_action_forbidden("stand") then
		return
	end

	local new_action_data = {
		body_part = 4,
		type = "stand"
	}
	local res = data.brain:action_request(new_action_data)

	return res
end

function CopLogicAttack._update_cover(data)
	local my_data = data.internal_data
	local best_cover = my_data.best_cover
	local satisfied = true --defined properly through the function, but currently unused
	local my_pos = data.m_pos
	local focus_enemy = data.attention_obj

	if focus_enemy and focus_enemy.nav_tracker and REACT_COMBAT <= focus_enemy.reaction then
		local find_new_cover = not my_data.cover_path_failed_t or data.t - my_data.cover_path_failed_t > 1

		if find_new_cover then
			if my_data.processing_cover_path or my_data.charge_path_search_id or my_data.moving_to_cover or my_data.walking_to_cover_shoot_pos or my_data.surprised then
				find_new_cover = nil
			end
		end

		if find_new_cover then
			local threat_pos = focus_enemy.nav_tracker:field_position()

			if data.objective and data.objective.type == "follow" then
				local near_pos = data.objective.follow_unit:movement():nav_tracker():field_position() --small clarification, follow_unit and focus_enemy can easily not be the same thing -- also using field_position if possible for valid navigation purposes

				if not best_cover or not CopLogicAttack._verify_follow_cover(best_cover[1], near_pos, threat_pos, 200, my_data.weapon_range.far) then
					local follow_unit_area = managers.groupai:state():get_area_from_nav_seg_id(data.objective.follow_unit:movement():nav_tracker():nav_segment())
					local max_near_dis = data.objective.distance and data.objective.distance * 0.9 or nil
					local found_cover = managers.navigation:find_cover_in_nav_seg_3(follow_unit_area.nav_segs, max_near_dis, near_pos, threat_pos)

					if found_cover then
						if not best_cover or CopLogicAttack._verify_follow_cover(found_cover, near_pos, threat_pos, 200, my_data.weapon_range.far) then
							local better_cover = {
								found_cover
							}

							--[[local offset_pos, yaw = CopLogicAttack._get_cover_offset_pos(data, better_cover, threat_pos)

							if offset_pos then
								better_cover[5] = offset_pos
								better_cover[6] = yaw
							end]]

							if data.char_tweak.wall_fwd_offset then
								better_cover[1][1] = CopLogicTravel.apply_wall_offset_to_cover(data, my_data, better_cover[1], data.char_tweak.wall_fwd_offset)
							end

							CopLogicAttack._set_best_cover(data, my_data, better_cover)
						else
							satisfied = false
						end
					else
						satisfied = false
					end
				end
			else
				local want_to_take_cover = my_data.want_to_take_cover
				local flank_cover = my_data.flank_cover --unit wants a flanking cover position
				local min_dis, max_dis = nil
				local dis_mul = 0.2
				
				if data.objective and data.objective.attitude ~= "engage" then
					dis_mul = dis_mul + 0.2
				end
				
				if want_to_take_cover then
					dis_mul = dis_mul + 0.4
					
					if want_to_take_cover == "hitnrun" then
						dis_mul = dis_mul + 0.2
					elseif want_to_take_cover == "reload" then
						dis_mul = dis_mul + 0.4
					elseif want_to_take_cover == "spoocavoidance" or want_to_take_cover == "coward" then
						dis_mul = dis_mul + 1
					end
				end
				
				if data.tactics then
					if data.tactics.ranged_fire or data.tactics.elite_ranged_fire then
						dis_mul = dis_mul + 0.6
					end	
					
					if data.tactics.charge then
						dis_mul = dis_mul - 0.35
					end
					
					if data.tactics.aggressor then
						dis_mul = dis_mul * 0.2
					end
				end
				
				local min_dis = my_data.weapon_range.close * dis_mul

				min_dis = math_min(min_dis - 200, my_data.weapon_range.optimal)
				
				local best_cover_bad_dis = nil
				
				if best_cover then
					best_cover_bad_dis = not CopLogicAttack._verify_cover(best_cover[1], threat_pos, min_dis, max_dis) and mvec3_dis(best_cover[1][1], threat_pos)
				end
				
				local look_for_cover = not best_cover or best_cover_bad_dis

				if look_for_cover or flank_cover then
					local my_vec = my_pos - threat_pos

					if flank_cover then
						mvec3_rotate_with(my_vec, Rotation(flank_cover.angle))
					end

					local optimal_dis = my_vec:length()

					if want_to_take_cover then
						max_dis = my_data.weapon_range.far
					else
						max_dis = my_data.weapon_range.optimal
					end

					local my_side_pos = threat_pos + my_vec

					mvec3_set_length(my_vec, max_dis)

					local furthest_side_pos = threat_pos + my_vec

					if flank_cover then
						local angle = flank_cover.angle
						local sign = flank_cover.sign

						if math_sign(angle) ~= sign then
							angle = -angle + flank_cover.step * sign

							if math_abs(angle) > 90 then
								flank_cover.failed = true
							else
								flank_cover.angle = angle
							end
						else
							flank_cover.angle = -angle
						end
					end

					local min_threat_dis, cone_angle = nil

					if flank_cover then
						cone_angle = flank_cover.step
					else
						cone_angle = math_lerp(90, 60, math_min(1, optimal_dis / 3000))
					end

					local search_nav_seg = nil

					if data.objective and data.objective.type == "defend_area" then
						search_nav_seg = data.objective.area and data.objective.area.nav_segs or data.objective.nav_seg
					end
					
					local found_cover = managers.navigation:find_cover_in_cone_from_threat_pos_1(threat_pos, furthest_side_pos, my_side_pos, nil, cone_angle, nil, search_nav_seg, nil, data.pos_rsrv_id)
					
					--log(tostring(i))
					
					if found_cover then	
						local found_cover_threat_dis = mvec3_dis(found_cover[1], threat_pos)
					
						if not best_cover or best_cover_bad_dis and best_cover_bad_dis < found_cover_threat_dis or CopLogicAttack._verify_cover(found_cover, threat_pos, min_dis, max_dis) then
							local better_cover = {
								found_cover
							}

							--[[local offset_pos, yaw = CopLogicAttack._get_cover_offset_pos(data, better_cover, threat_pos)

							if offset_pos then
								better_cover[5] = offset_pos
								better_cover[6] = yaw
							end]]

							if data.char_tweak.wall_fwd_offset then
								better_cover[1][1] = CopLogicTravel.apply_wall_offset_to_cover(data, my_data, better_cover[1], data.char_tweak.wall_fwd_offset)
							end

							CopLogicAttack._set_best_cover(data, my_data, better_cover)
						else
							satisfied = false
							--log("cock")
						end
					end
				else
					satisfied = false
				end
			end
		end
	elseif best_cover then
		local cover_release_dis = 100
		local check_pos = nil

		if my_data.advancing then
			if data.pos_rsrv.move_dest then
				check_pos = data.pos_rsrv.move_dest.position
			else
				check_pos = my_data.advancing:get_walk_to_pos()
			end
		else
			check_pos = my_pos
		end

		if cover_release_dis < mvec3_dis(best_cover[1][1], check_pos) then
			CopLogicAttack._set_best_cover(data, my_data, nil)
		end
	end
end

function CopLogicAttack._verify_cover(cover, threat_pos, min_dis, max_dis)
	local threat_dis = mvec3_dir(temp_vec1, cover[1], threat_pos)

	if min_dis and threat_dis < min_dis or max_dis and max_dis < threat_dis then
		return
	end
	
	--better off commenting this out bc nobody actually makes cover use unique directional placement anymore, this is more likely to get in the way
	--local cover_dot = mvec3_dot(temp_vec1, cover[2]) 

    --if cover_dot < 0.67 then
    --    return
    --end

	return true
end

function CopLogicAttack._verify_follow_cover(cover, near_pos, threat_pos, min_dis, max_dis)
	if mvec3_dis(near_pos, cover[1]) < 600 and CopLogicAttack._verify_cover(cover, threat_pos, min_dis, max_dis) then
		return true
	end
end

function CopLogicAttack._chk_covered(data, cover_pos, threat_pos, slotmask)
	local ray_from = temp_vec1

	mvec3_set(ray_from, math_up)
	mvec3_mul(ray_from, 80)
	mvec3_add(ray_from, cover_pos)

	local ray_to_pos = temp_vec2

	mvec3_step(ray_to_pos, ray_from, threat_pos, 300)

	local low_ray = data.unit:raycast("ray", ray_from, ray_to_pos, "slot_mask", slotmask, "ray_type", "ai_vision", "report")
	local high_ray = nil

	if low_ray then
		mvec3_set_z(ray_from, ray_from.z + 70)
		mvec3_step(ray_to_pos, ray_from, threat_pos, 300)

		high_ray = data.unit:raycast("ray", ray_from, ray_to_pos, "slot_mask", slotmask, "ray_type", "ai_vision", "report")
	end

	return low_ray, high_ray
end

function CopLogicAttack._process_pathing_results(data, my_data)
	if not data.pathing_results then
		return
	end

	local pathing_results = data.pathing_results
	data.pathing_results = nil
	local path = pathing_results[my_data.cover_path_search_id]

	if path then
		if path ~= "failed" then
			my_data.cover_path = path
			my_data.cover_path_failed_t = nil
		else
			--print(data.unit, "[CopLogicAttack._process_pathing_results] cover path failed", data.unit)
			CopLogicAttack._set_best_cover(data, my_data, nil)

			my_data.cover_path_failed_t = data.t
		end

		my_data.processing_cover_path = nil
		my_data.cover_path_search_id = nil
	end

	path = pathing_results[my_data.charge_path_search_id]

	if path then
		if path ~= "failed" then
			my_data.charge_path = path
			my_data.charge_path_failed_t = nil
		--else
			--print("[CopLogicAttack._process_pathing_results] charge path failed", data.unit)
		end

		my_data.charge_path_search_id = nil
		my_data.charge_path_failed_t = data.t
	end

	path = pathing_results[my_data.expected_pos_path_search_id]

	if path then
		if path ~= "failed" then
			my_data.expected_pos_path = path
		end

		my_data.expected_pos_path_search_id = nil
	end
end

function CopLogicAttack._upd_enemy_detection(data, is_synchronous)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local min_reaction = REACT_AIM
	local delay = CopLogicBase._upd_attention_obj_detection(data, min_reaction, nil)
	local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, data.detected_attention_objects, nil)
	local old_att_obj = data.attention_obj

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)
	data.logic._chk_exit_attack_logic(data, new_reaction)

	if my_data ~= data.internal_data then
		return
	end

	if new_attention then
		if old_att_obj and old_att_obj.u_key ~= new_attention.u_key then
			CopLogicAttack._cancel_charge(data, my_data)

			my_data.flank_cover = nil

			if not data.unit:movement():chk_action_forbidden("walk") then
				CopLogicAttack._cancel_walking_to_cover(data, my_data)
			end

			CopLogicAttack._set_best_cover(data, my_data, nil)
		end
	elseif old_att_obj then
		CopLogicAttack._cancel_charge(data, my_data)

		my_data.flank_cover = nil
	end

	CopLogicBase._chk_call_the_police(data)

	if my_data ~= data.internal_data then
		return
	end

	data.logic._upd_aim(data, my_data)

	if not is_synchronous then
		CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicAttack._upd_enemy_detection, data, data.t + delay, data.important and true)
	end

	CopLogicBase._report_detections(data.detected_attention_objects)
end

function CopLogicAttack._confirm_retreat_position(data, retreat_pos, threat_head_pos, threat_tracker, end_pose)
	local ray_params = {
		trace = true,
		pos_from = retreat_pos,
		tracker_to = threat_tracker
	}
	local walk_ray_res = managers.navigation:raycast(ray_params)

	if not walk_ray_res then
		return true
	end

	local retreat_head_pos = mvec3_cpy(retreat_pos)

	if end_pose == "stand" then
		mvec3_set_z(retreat_head_pos, retreat_head_pos.z + 150)
	else
		mvec3_set_z(retreat_head_pos, retreat_head_pos.z + 80)
	end

	local ray_res = data.unit:raycast("ray", retreat_head_pos, threat_head_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision", "report")

	if not ray_res then
		return true
	end

	return false
end

function CopLogicAttack._find_retreat_position(data, from_pos, threat_pos, threat_head_pos, threat_tracker, max_dist, vis_required, end_pose)
	local nav_manager = managers.navigation
	local nr_rays = 5
	local ray_dis = max_dist or 1000
	local step = 180 / nr_rays
	local offset = math_random(step)
	local dir = math_random() < 0.5 and -1 or 1
	step = step * dir
	local step_rot = Rotation(step)
	local offset_rot = Rotation(offset)
	local offset_vec = mvec3_cpy(threat_pos)

	mvec3_sub(offset_vec, from_pos)
	mvec3_norm(offset_vec)
	mvec3_mul(offset_vec, ray_dis)
	mvec3_rotate_with(offset_vec, Rotation((90 + offset) * dir))

	local to_pos = nil
	local from_tracker = nav_manager:create_nav_tracker(from_pos)
	local ray_params = {
		trace = true,
		tracker_from = from_tracker
	}
	local rsrv_desc = {
		radius = 30,
		filter = data.pos_rsrv_id
	}
	local fail_position = nil

	repeat
		to_pos = mvec3_cpy(from_pos)

		mvec3_add(to_pos, offset_vec)

		ray_params.pos_to = to_pos
		local ray_res = nav_manager:raycast(ray_params)

		if ray_res then
			rsrv_desc.position = ray_params.trace[1]
			local is_free = nav_manager:is_pos_free(rsrv_desc)

			if is_free then
				if not vis_required or CopLogicAttack._confirm_retreat_position(data, ray_params.trace[1], threat_head_pos, threat_tracker, end_pose) then
					nav_manager:destroy_nav_tracker(from_tracker)

					return ray_params.trace[1]
				end
			end
		elseif not fail_position then
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

	return nil
end

function CopLogicAttack.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action:type()

	if action_type == "walk" then
		my_data.advancing = nil

		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)

		if my_data.surprised then
			my_data.surprised = false
		elseif my_data.moving_to_cover then
			if action:expired() then
				my_data.in_cover = my_data.moving_to_cover
				my_data.cover_enter_t = TimerManager:game():time()
			end

			my_data.moving_to_cover = nil
		elseif my_data.walking_to_cover_shoot_pos then
			my_data.walking_to_cover_shoot_pos = nil
			my_data.at_cover_shoot_pos = true
		end

		if action:expired() and data.important then
			CopLogicAttack._upd_pose(data, my_data)
		end
	elseif action_type == "shoot" then
		my_data.shooting = nil
	elseif action_type == "reload" or action_type == "heal" then
		if action:expired() then
			data.logic._upd_aim(data, my_data)
		end
	elseif action_type == "act" then
		if my_data.gesture_arrest then
			my_data.gesture_arrest = nil
		elseif action:expired() then
			data.logic._upd_aim(data, my_data)
		end
	elseif action_type == "turn" then
		my_data.turning = nil
	elseif action_type == "hurt" or action_type == "healed" then
		CopLogicAttack._cancel_cover_pathing(data, my_data)

		if action:expired() and not CopLogicBase.chk_start_action_dodge(data, "hit") then
			data.logic._upd_aim(data, my_data)
		end
	elseif action_type == "dodge" then
		local timeout = action:timeout()

		if timeout then
			data.dodge_timeout_t = TimerManager:game():time() + math_lerp(timeout[1], timeout[2], math_random())
		end

		CopLogicAttack._cancel_cover_pathing(data, my_data)

		if action:expired() then
			data.logic._upd_aim(data, my_data)
		end
	end
end

function CopLogicAttack._upd_aim(data, my_data)
	data.t = TimerManager:game():time()

	local aim, shoot, expected_pos = nil
	local focus_enemy = data.attention_obj

	if focus_enemy then
		if REACT_AIM <= focus_enemy.reaction then
			local running = my_data.advancing and not my_data.advancing:stopping() and my_data.advancing:haste() == "run"

			if focus_enemy.verified or focus_enemy.nearly_visible then
				local firing_range = 500

				if my_data.weapon_range then
					firing_range = running and my_data.weapon_range.close or my_data.weapon_range.far
				elseif not running then
					firing_range = 1000
				end

				if running and not data.char_tweak.always_face_enemy and firing_range < focus_enemy.dis then ----check always_face_enemy
					local walk_to_pos = data.unit:movement():get_walk_to_pos()

					if walk_to_pos then
						mvec3_dir(temp_vec1, data.m_pos, walk_to_pos)
						mvec3_dir(temp_vec2, data.m_pos, focus_enemy.m_pos)

						local dot = mvec3_dot(temp_vec1, temp_vec2)

						if dot < 0.6 then
							shoot = false
							aim = false
						end
					end
				end

				if aim == nil then
					if REACT_SHOOT <= focus_enemy.reaction then
						local last_sup_t = data.unit:character_damage():last_suppression_t()

						if last_sup_t then
							local sup_t_ver = 7 

							if running then
								sup_t_ver = sup_t_ver * 0.3
							end

							if not focus_enemy.verified then
								if focus_enemy.vis_ray and firing_range < focus_enemy.vis_ray.distance then
									sup_t_ver = sup_t_ver * 0.5
								else
									sup_t_ver = sup_t_ver * 0.2
								end
							end

							if data.t - last_sup_t < sup_t_ver then
								shoot = true
							end
						end

						if not shoot and focus_enemy.verified then
							if focus_enemy.verified_dis < firing_range then
								shoot = true
							elseif focus_enemy.criminal_record and focus_enemy.criminal_record.assault_t and data.t - focus_enemy.criminal_record.assault_t < 2 then
								shoot = true
							end
						end

						if not shoot and my_data.attitude == "engage" then
							if focus_enemy.verified then
								if focus_enemy.verified_dis < firing_range or focus_enemy.reaction == REACT_SHOOT then
									shoot = true
								end
							else
								local time_since_verification = focus_enemy.verified_t and data.t - focus_enemy.verified_t

								if my_data.firing and time_since_verification and time_since_verification < 3.5 then
									shoot = true
								end
							end
						end

						aim = aim or shoot

						if not aim and focus_enemy.verified_dis < firing_range then
							aim = true
						end
					else
						aim = true
					end
				end
			else
				local time_since_verification = focus_enemy.verified_t and data.t - focus_enemy.verified_t

				if time_since_verification then
					if running then
						local dis_lerp = math_clamp((focus_enemy.verified_dis - 500) / 600, 0, 1)

						if time_since_verification < math_lerp(5, 1, dis_lerp) then
							aim = true
						end
					elseif time_since_verification < 5 then
						aim = true
					end

					if aim and my_data.shooting and REACT_SHOOT <= focus_enemy.reaction then
						if running then
							local look_pos = focus_enemy.last_verified_pos or focus_enemy.verified_pos
							local same_height = math_abs(look_pos.z - data.m_pos.z) < 250

							if same_height and time_since_verification < 2 then
								shoot = true
							end
						elseif time_since_verification < 3 then
							shoot = true
						end
					end
				end

				if not shoot then
					if not focus_enemy.last_verified_pos or time_since_verification and time_since_verification > 5 then
						expected_pos = CopLogicAttack._get_expected_attention_position(data, my_data)

						if expected_pos then
							if running then
								expected_pos = mvec3_cpy(expected_pos)
								local watch_dir = temp_vec1

								mvec3_set(watch_dir, expected_pos)
								mvec3_sub(watch_dir, data.m_pos)
								mvec3_set_z(watch_dir, 0)

								local watch_pos_dis = mvec3_norm(watch_dir)
								local walk_to_pos = data.unit:movement():get_walk_to_pos()
								local walk_vec = temp_vec2

								mvec3_set(walk_vec, walk_to_pos)
								mvec3_sub(walk_vec, data.m_pos)
								mvec3_set_z(walk_vec, 0)
								mvec3_norm(walk_vec)

								local watch_walk_dot = mvec3_dot(watch_dir, walk_vec)

								if watch_pos_dis < 500 or watch_pos_dis < 1000 and watch_walk_dot > 0.85 then
									aim = true
								end
							else
								aim = true
							end
						end
					end
				end
			end
		end

		if not aim and data.char_tweak.always_face_enemy and REACT_COMBAT <= focus_enemy.reaction then
			aim = true
		end

		if data.logic.chk_should_turn(data, my_data) then
			local enemy_pos = nil

			if focus_enemy.verified or focus_enemy.nearly_visible then
				enemy_pos = focus_enemy.m_pos
			else
				enemy_pos = expected_pos or focus_enemy.last_verified_pos or focus_enemy.verified_pos
			end

			CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, enemy_pos)
		end
	end

	if aim or shoot then
		local time_since_verification = focus_enemy.verified_t and data.t - focus_enemy.verified_t
		
		if focus_enemy.verified or focus_enemy.nearly_visible or time_since_verification and time_since_verification < 2 then
			if my_data.attention_unit ~= focus_enemy.u_key then
				CopLogicBase._set_attention(data, focus_enemy)

				my_data.attention_unit = focus_enemy.u_key
			end
			
			if data.logic.chk_should_turn(data, my_data) then
				local enemy_pos = focus_enemy.m_pos
				CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, enemy_pos)
			end
		else
			local look_pos = nil
			local coarse_path = my_data.coarse_path
			local nav_index = my_data.coarse_path_index
			
			if coarse_path and nav_index and #coarse_path >= nav_index + 1 then
				local total_nav_points = #coarse_path
				local index = nav_index + 1
				local seg = coarse_path[index][1]
				look_pos = managers.navigation:find_random_position_in_segment(seg)
			end

			if not look_pos then
				look_pos = my_data.expected_pos or focus_enemy.last_verified_pos or focus_enemy.verified_pos
			end

			if my_data.attention_unit ~= look_pos then
				CopLogicBase._set_attention_on_pos(data, mvec3_cpy(look_pos))

				my_data.attention_unit = mvec3_cpy(look_pos)
			end
			
			if data.logic.chk_should_turn(data, my_data) then
				CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, look_pos)
			end
		end

		if not my_data.shooting and not my_data.spooc_attack and not data.unit:anim_data().reload and not data.unit:movement():chk_action_forbidden("action") then
			local shoot_action = {
				body_part = 3,
				type = "shoot"
			}

			if data.brain:action_request(shoot_action) then
				my_data.shooting = true
			end
		end
	else
		if my_data.shooting and not data.unit:anim_data().reload then
			local new_action = {
				body_part = 3,
				type = "idle"
			}

			data.brain:action_request(new_action)
		end

		if my_data.attention_unit then
			CopLogicBase._reset_attention(data)

			my_data.attention_unit = nil
		end
	end

	CopLogicAttack.aim_allow_fire(shoot, aim, data, my_data)
end

function CopLogicAttack.aim_allow_fire(shoot, aim, data, my_data)
	if shoot then
		if not my_data.firing then
			data.unit:movement():set_allow_fire(true)

			my_data.firing = true

			if not data.unit:in_slot(16) and not data.is_converted and data.char_tweak and data.char_tweak.chatter and data.char_tweak.chatter.aggressive then
				if not data.unit:base():has_tag("special") and data.unit:base():has_tag("law") and not data.unit:base()._tweak_table == "gensec" and not data.unit:base()._tweak_table == "security" then
					if focus_enemy.verified and focus_enemy.verified_dis <= 500 then
						if managers.groupai:state():chk_assault_active_atm() then
							local roll = math.random(1, 100)
						
							if roll < 33 then
								managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "aggressivecontrolsurprised1")
							elseif roll < 66 and roll > 33 then
								managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "aggressivecontrolsurprised2")
							else
								managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "open_fire")
							end
						else
							local roll = math.random(1, 100)
						
							if roll <= chance_heeeeelpp then
								managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "aggressivecontrolsurprised1")
							else --hopefully some variety here now
								managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "aggressivecontrolsurprised2")
							end	
						end
					else
						if managers.groupai:state():chk_assault_active_atm() then
							managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "open_fire")
						else
							managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "aggressivecontrol")
						end
					end
				elseif data.unit:base():has_tag("special") then
					if not data.unit:base():has_tag("tank") and data.unit:base():has_tag("medic") then
						managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "aggressive")
					elseif data.unit:base():has_tag("shield") then
						local shield_knock_cooldown = math.random(3, 6)
						if not my_data.shield_knock_cooldown or my_data.shield_knock_cooldown < data.t then
							local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)	
							my_data.shield_knock_cooldown = data.t + shield_knock_cooldown
									
							if data.unit:base()._tweak_table == "phalanx_minion" or data.unit:base()._tweak_table == "phalanx_minion_assault" then
								data.unit:sound():say("use_gas", true, nil, true)
							else
								data.unit:sound():play("shield_identification", nil, true)
							end
						end
					else
						managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "contact")
					end
				elseif data.unit:base()._tweak_table == "security" or data.unit:base()._tweak_table == "gensec" or data.unit:base()._tweak_table == "city_swat_guard" or data.unit:base()._tweak_table == "spring" or data.unit:base()._tweak_table == "phalanx_vip" then
				    data.unit:sound():say("a01", true)
				else
					managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "contact")
				end
			end
		end
	elseif my_data.firing then
		data.unit:movement():set_allow_fire(false)

		my_data.firing = nil
	end
end

function CopLogicAttack.chk_should_turn(data, my_data)
	return not my_data.turning and not my_data.has_old_action and not my_data.advancing and not my_data.moving_to_cover and not my_data.walking_to_cover_shoot_pos and not my_data.surprised and not my_data.menacing and not data.unit:movement():chk_action_forbidden("walk")
end

function CopLogicAttack._get_cover_offset_pos(data, cover_data, threat_pos)
	local threat_vec = threat_pos - cover_data[1][1]

	mvec3_set_z(threat_vec, 0)

	local threat_polar = threat_vec:to_polar_with_reference(cover_data[1][2], math_up)
	local threat_spin = threat_polar.spin
	local rot = nil

	if threat_spin < -20 then
		rot = Rotation(90)
	elseif threat_spin > 20 then
		rot = Rotation(-90)
	else
		rot = Rotation(180)
	end

	local offset_pos = mvec3_cpy(cover_data[1][2])

	mvec3_rotate_with(offset_pos, rot)
	mvec3_set_length(offset_pos, 25)
	mvec3_add(offset_pos, cover_data[1][1])

	local ray_params = {
		trace = true,
		tracker_from = cover_data[1][3],
		pos_to = offset_pos
	}

	managers.navigation:raycast(ray_params)

	return ray_params.trace[1], rot:yaw()
end

function CopLogicAttack._find_flank_pos(data, my_data, flank_tracker, max_dist)
	local pos = flank_tracker:position()
	local vec_to_pos = pos - data.m_pos

	mvec3_set_z(vec_to_pos, 0)

	local max_dis = max_dist or 1500

	mvec3_set_length(vec_to_pos, max_dis)

	local nav_manager = managers.navigation
	local accross_positions = nav_manager:find_walls_accross_tracker(flank_tracker, vec_to_pos, 160, 5)

	if accross_positions then
		local optimal_dis = max_dis
		local best_error_dis, best_pos, best_is_hit, best_is_miss, best_has_too_much_error = nil
		local reservation = {
			radius = 30,
			filter = data.pos_rsrv_id
		}

		for _, accross_pos in ipairs(accross_positions) do
			local error_dis = math_abs(mvec3_dis(accross_pos[1], pos) - optimal_dis)
			local too_much_error = error_dis / optimal_dis > 0.2
			local is_hit = accross_pos[2]

			if best_is_hit then
				if is_hit then
					if error_dis < best_error_dis then
						reservation.position = accross_pos[1]

						if nav_manager:is_pos_free(reservation) then
							best_pos = accross_pos[1]
							best_error_dis = error_dis
							best_has_too_much_error = too_much_error
						end
					end
				elseif best_has_too_much_error then
					reservation.position = accross_pos[1]

					if nav_manager:is_pos_free(reservation) then
						best_pos = accross_pos[1]
						best_error_dis = error_dis
						best_is_miss = true
						best_is_hit = nil
					end
				end
			elseif best_is_miss then
				if not too_much_error then
					reservation.position = accross_pos[1]

					if nav_manager:is_pos_free(reservation) then
						best_pos = accross_pos[1]
						best_error_dis = error_dis
						best_has_too_much_error = nil
						best_is_miss = nil
						best_is_hit = true
					end
				end
			else
				reservation.position = accross_pos[1]

				if nav_manager:is_pos_free(reservation) then
					best_pos = accross_pos[1]
					best_is_hit = is_hit
					best_is_miss = not is_hit
					best_has_too_much_error = too_much_error
					best_error_dis = error_dis
				end
			end
		end

		return best_pos
	end
end

function CopLogicAttack.damage_clbk(data, damage_info)
	CopLogicIdle.damage_clbk(data, damage_info)
end

function CopLogicAttack.is_available_for_assignment(data, new_objective)
	local my_data = data.internal_data

	if my_data.exiting then
		return
	end

	if new_objective and new_objective.forced then
		return true
	end

	if data.unit:movement():chk_action_forbidden("walk") then
		return
	end

	data.t = TimerManager:game():time()

	if data.path_fail_t and data.t < data.path_fail_t + 6 then
		return
	end

	local att_obj = data.attention_obj

	if not att_obj or att_obj.reaction < REACT_AIM then
		return true
	end

	if not new_objective or new_objective.type == "free" then
		return true
	end

	if new_objective then
		local allow_trans, obj_fail = CopLogicBase.is_obstructed(data, new_objective, 0.2, att_obj)

		if obj_fail then
			return
		end
	end

	return true
end

function CopLogicAttack._chk_wants_to_take_cover(data, my_data)
	if not data.attention_obj or data.attention_obj.reaction < REACT_COMBAT then
		return
	end
	
	if data.tactics then
		if data.tactics.sneaky and data.coward_t and data.t - data.coward_t < 5 then
			return "coward"
		elseif data.tactics.spoocavoidance and data.attention_obj.dis < 2000 and data.attention_obj.aimed_at then
			return "spoocavoidance"
		elseif data.tactics.reloadingretreat and data.unit:anim_data().reload then
			return "reload"
		elseif data.tactics.elite_ranged_fire and data.attention_obj.verified_dis < my_data.weapon_range.optimal * 0.5 then
			return "eliterangedfire"
		elseif data.tactics.hitnrun and data.attention_obj.verified_dis < 1000 then
			return "hitnrun"
		end
	end
	
	local ammo_max, ammo = data.unit:inventory():equipped_unit():base():ammo_info()

	if ammo / ammo_max < 0.2 then
		return true
	end
	
	if my_data.moving_to_cover or data.attention_obj.dmg_t and data.t - data.attention_obj.dmg_t < 2 then
		return true
	end
	
	if data.is_suppressed then
		return true
	end
end

function CopLogicAttack._set_best_cover(data, my_data, cover_data)
	local current_best_cover = my_data.best_cover

	if current_best_cover then
		managers.navigation:release_cover(current_best_cover[1])
		CopLogicAttack._cancel_cover_pathing(data, my_data)
	end

	if cover_data then
		managers.navigation:reserve_cover(cover_data[1], data.pos_rsrv_id)

		my_data.best_cover = cover_data

		if not my_data.in_cover and not my_data.walking_to_cover_shoot_pos and not my_data.moving_to_cover and mvec3_dis_sq(cover_data[1][1], data.m_pos) < 100 then
			my_data.in_cover = my_data.best_cover
			my_data.cover_enter_t = data.t
		end
	else
		my_data.best_cover = nil
		my_data.flank_cover = nil
	end
end

function CopLogicAttack._set_nearest_cover(my_data, cover_data)
	local nearest_cover = my_data.nearest_cover

	if nearest_cover then
		managers.navigation:release_cover(nearest_cover[1])
	end

	if cover_data then
		local pos_rsrv_id = my_data.unit:movement():pos_rsrv_id()

		managers.navigation:reserve_cover(cover_data[1], pos_rsrv_id)

		my_data.nearest_cover = cover_data
	else
		my_data.nearest_cover = nil
	end
end

function CopLogicAttack._can_move(data)
	return not data.objective or not data.objective.pos or not data.objective.in_place
end

function CopLogicAttack.on_new_objective(data, old_objective)
	CopLogicIdle.on_new_objective(data, old_objective)
end

function CopLogicAttack.queue_update(data, my_data)
	local delay = data.important and 0 or 0.7
	
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
			managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "clear_whisper" )
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
	
	CopLogicBase.queue_task(my_data, my_data.update_queue_id, data.logic.queued_update, data, data.t + delay, data.important and true)
end

function CopLogicAttack._get_expected_attention_position(data, my_data)
	local main_enemy = data.attention_obj
	local e_nav_tracker = main_enemy.nav_tracker

	if not e_nav_tracker then
		return
	end

	local my_nav_seg = data.unit:movement():nav_tracker():nav_segment()
	local e_pos = main_enemy.m_pos
	local e_nav_seg = e_nav_tracker:nav_segment()

	if e_nav_seg == my_nav_seg then
		mvec3_set(temp_vec1, main_enemy.m_head_pos)

		return temp_vec1
	end

	local expected_path = my_data.expected_pos_path
	local from_nav_seg, to_nav_seg = nil

	if expected_path then
		local i_from_seg = nil

		for i, k in ipairs(expected_path) do
			if k[1] == my_nav_seg then
				i_from_seg = i

				break
			end
		end

		if i_from_seg then
			local groupai_manager = managers.groupai:state()
			local nav_manager = managers.navigation

			local function _find_aim_pos(from_nav_seg, to_nav_seg)
				local is_criminal = main_enemy.criminal_record and true

				if groupai_manager:chk_area_leads_to_enemy(from_nav_seg, to_nav_seg, is_criminal) then ----check if this changes anything, draw expected_pos to check
					local closest_dis = 1000000000
					local closest_door = nil
					local min_point_dis_sq = 10000
					local found_doors = nav_manager:find_segment_doors(from_nav_seg, callback(CopLogicAttack, CopLogicAttack, "_chk_is_right_segment", to_nav_seg))

					for _, door in pairs(found_doors) do
						mvec3_set(temp_vec1, door.center)

						local same_height = math_abs(temp_vec1.z - data.m_pos.z) < 250

						if same_height then
							local dis = mvec3_dis_sq(e_pos, temp_vec1)

							if dis < closest_dis then
								closest_dis = dis
								closest_door = door
							end
						end
					end

					if closest_door then
						mvec3_set(temp_vec1, closest_door.center)
						mvec3_sub(temp_vec1, data.m_pos)
						mvec3_set_z(temp_vec1, 0)

						if min_point_dis_sq < mvec3_len_sq(temp_vec1) then
							mvec3_set(temp_vec1, closest_door.center)
							mvec3_set_z(temp_vec1, data.unit:movement():m_head_pos().z)

							return temp_vec1
						else
							return false, true
						end
					end
				end
			end

			local i = #expected_path

			while i > 0 do
				if expected_path[i][1] == e_nav_seg then
					to_nav_seg = expected_path[math_clamp(i, i_from_seg - 1, i_from_seg + 1)][1]
					local aim_pos, too_close = _find_aim_pos(my_nav_seg, to_nav_seg)

					if aim_pos then
						do return aim_pos end
						break
					end

					if too_close then
						local next_nav_seg = expected_path[math_clamp(i, i_from_seg - 2, i_from_seg + 2)][1]

						if next_nav_seg ~= to_nav_seg then
							local from_nav_seg = to_nav_seg
							to_nav_seg = next_nav_seg
							aim_pos = _find_aim_pos(from_nav_seg, to_nav_seg)
						end

						return aim_pos
					end

					break
				end

				i = i - 1
			end
		end

		if not i_from_seg or not to_nav_seg then
			expected_path = nil
			my_data.expected_pos_path = nil
		end
	end

	if not expected_path and not my_data.expected_pos_path_search_id then
		my_data.expected_pos_path_search_id = "ExpectedPos" .. tostring(data.key)

		data.brain:search_for_coarse_path(my_data.expected_pos_path_search_id, e_nav_seg)
	end
end

function CopLogicAttack._chk_is_right_segment(ignore_this, enemy_nav_seg, test_nav_seg)
	return enemy_nav_seg == test_nav_seg
end

function CopLogicAttack.is_advancing(data)
	local my_data = data.internal_data

	if my_data.advancing then
		return data.pos_rsrv.move_dest and data.pos_rsrv.move_dest.position or my_data.advancing:get_walk_to_pos()
	end

	if my_data.moving_to_cover then
		return my_data.moving_to_cover[1][1]
	end

	if my_data.walking_to_cover_shoot_pos then
		return my_data.walking_to_cover_shoot_pos:get_walk_to_pos()
	end
end

function CopLogicAttack._get_all_paths(data)
	return {
		cover_path = data.internal_data.cover_path,
		charge_path = data.internal_data.charge_path
	}
end

function CopLogicAttack._set_verified_paths(data, verified_paths)
	data.internal_data.cover_path = verified_paths.cover_path
	data.internal_data.charge_path = verified_paths.charge_path
end

function CopLogicAttack._chk_exit_attack_logic(data, new_reaction)
	if not data.unit:movement():chk_action_forbidden("walk") then
		local wanted_state = CopLogicBase._get_logic_state_from_reaction(data, new_reaction)

		if wanted_state ~= data.name then
			local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, data.objective, nil, nil)

			if allow_trans then
				if obj_failed then
					data.objective_failed_clbk(data.unit, data.objective)
				elseif wanted_state ~= "idle" or not managers.groupai:state():on_cop_jobless(data.unit) then
					CopLogicBase._exit(data.unit, wanted_state)
				end

				CopLogicBase._report_detections(data.detected_attention_objects)
			end
		end
	end
end

function CopLogicAttack.action_taken(data, my_data)
	return my_data.turning or my_data.has_old_action or my_data.advancing or my_data.moving_to_cover or my_data.walking_to_cover_shoot_pos or my_data.surprised or my_data.menacing or data.unit:movement():chk_action_forbidden("walk")
end

function CopLogicAttack._upd_stop_old_action(data, my_data)
	if data.unit:anim_data().to_idle then
		return
	end

	if data.unit:movement():chk_action_forbidden("walk") then
		if not data.unit:movement():chk_action_forbidden("idle") then
			CopLogicIdle._start_idle_action_from_act(data)
		end
	elseif data.unit:anim_data().act and data.unit:anim_data().needs_idle then
		CopLogicIdle._start_idle_action_from_act(data)
	end

	CopLogicIdle._chk_has_old_action(data, my_data)
end

function CopLogicAttack._upd_pose(data, my_data)
	local allowed_poses = data.char_tweak.allowed_poses

	if allowed_poses then
		local unit_can_stand = allowed_poses.stand
		local unit_can_crouch = allowed_poses.crouch

		if not unit_can_stand and unit_can_crouch then
			if not data.unit:anim_data().crouch then
				return CopLogicAttack._chk_request_action_crouch(data)
			end
		elseif not unit_can_crouch and unit_can_stand then
			if data.unit:anim_data().crouch then
				return CopLogicAttack._chk_request_action_stand(data)
			end
		end

		return
	end

	local objective_pose = data.objective and data.objective.pose
	local need_cover = nil

	if my_data.want_to_take_cover then
		if not my_data.in_cover or not my_data.in_cover[4] then
			need_cover = true
		end
	end

	if data.is_suppressed or need_cover and objective_pose ~= "stand" or objective_pose == "crouch" then
		if not data.unit:anim_data().crouch then
			return CopLogicAttack._chk_request_action_crouch(data)
		end
	elseif my_data.cover_test_step > 2 and objective_pose ~= "crouch" or objective_pose == "stand" then
		if data.unit:anim_data().crouch then
			return CopLogicAttack._chk_request_action_stand(data)
		end
	end
end

function CopLogicAttack._chk_exit_non_walkable_area(data)
	local my_data = data.internal_data

	if my_data.advancing or not data.objective or not data.objective.nav_seg or data.unit:movement():chk_action_forbidden("walk") then
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
