local mvec3_x = mvector3.x
local mvec3_y = mvector3.y
local mvec3_z = mvector3.z
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_sub = mvector3.subtract
local mvec3_dot = mvector3.dot
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_dir = mvector3.direction
local mvec3_norm = mvector3.normalize
local mvec3_cross = mvector3.cross
local mvec3_rand_ortho = mvector3.random_orthogonal
local mvec3_negate = mvector3.negate
local mvec3_len = mvector3.length
local mvec3_cpy = mvector3.copy
local mvec3_set_stat = mvector3.set_static
local mvec3_set_length = mvector3.set_length
local mvec3_angle = mvector3.angle
local mvec3_step = mvector3.step

local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()

local m_rot_x = mrotation.x
local m_rot_y = mrotation.y
local m_rot_z = mrotation.z

local math_lerp = math.lerp
local math_random = math.random
local math_up = math.UP
local math_abs = math.abs
local math_clamp = math.clamp
local math_min = math.min

local table_insert = table.insert

local pairs_g = pairs
local tostring_g = tostring

local REACT_AIM = AIAttentionObject.REACT_AIM
local REACT_ARREST = AIAttentionObject.REACT_ARREST
local REACT_COMBAT = AIAttentionObject.REACT_COMBAT
local REACT_SCARED = AIAttentionObject.REACT_SCARED
local REACT_SHOOT = AIAttentionObject.REACT_SHOOT
local REACT_SURPRISED = AIAttentionObject.REACT_SURPRISED
local REACT_SUSPICIOUS = AIAttentionObject.REACT_SUSPICIOUS

CopLogicBase._AGGRESSIVE_ALERT_TYPES = {
	vo_distress = true,
	aggression = true,
	bullet = true,
	vo_intimidate = true,
	explosion = true,
	footstep = true,
	vo_cbt = true,
	fire = true
}
CopLogicBase._DANGEROUS_ALERT_TYPES = {
	explosion = true,
	bullet = true,
	aggression = true,
	fire = true
}

function CopLogicBase.on_importance(data) ----distribute in each logic, do not modify timers, or if it's done, store previous ones in case the unit is no longer important
	if not data.important or not data.internal_data then
		return
	end

	local internal_data = data.internal_data
	local detection_id = internal_data.detection_task_key
	local update_func_id = internal_data.update_queue_id
	local update_func2_id = internal_data.upd_task_key

	local e_manager = managers.enemy
	local update_task = e_manager.update_queue_task

	if detection_id then
		update_task(e_manager, detection_id, nil, nil, data.t, nil, true)
	end

	if update_func_id then
		update_task(e_manager, update_func_id, nil, nil, data.t, nil, true)
	end

	if update_func2_id then
		update_task(e_manager, update_func2_id, nil, nil, data.t, nil, true)
	end
end

function CopLogicBase.queue_task(internal_data, id, func, data, exec_t, asap)
	local qd_tasks = internal_data.queued_tasks

	if qd_tasks then
		qd_tasks[id] = true
	else
		internal_data.queued_tasks = {
			[id] = true
		}
	end

	managers.enemy:queue_task(id, func, data, exec_t, callback(CopLogicBase, CopLogicBase, "on_queued_task", internal_data), asap)
end

function CopLogicBase.on_queued_task(ignore_this, internal_data, id)
	if not internal_data.queued_tasks or not internal_data.queued_tasks[id] then
		return
	end

	internal_data.queued_tasks[id] = nil

	if not next(internal_data.queued_tasks) then
		internal_data.queued_tasks = nil
	end
end

function CopLogicBase.add_delayed_clbk(internal_data, id, clbk, exec_t)
	local clbks = internal_data.delayed_clbks

	if clbks then
		clbks[id] = true
	else
		internal_data.delayed_clbks = {
			[id] = true
		}
	end

	managers.enemy:add_delayed_clbk(id, clbk, exec_t)
end

function CopLogicBase.cancel_delayed_clbk(internal_data, id)
	if not internal_data.delayed_clbks or not internal_data.delayed_clbks[id] then
		return
	end

	managers.enemy:remove_delayed_clbk(id)

	internal_data.delayed_clbks[id] = nil

	if not next(internal_data.delayed_clbks) then
		internal_data.delayed_clbks = nil
	end
end

function CopLogicBase.chk_cancel_delayed_clbk(internal_data, id)
	if internal_data.delayed_clbks and internal_data.delayed_clbks[id] then
		managers.enemy:remove_delayed_clbk(id)

		internal_data.delayed_clbks[id] = nil

		if not next(internal_data.delayed_clbks) then
			internal_data.delayed_clbks = nil
		end
	end
end

function CopLogicBase.on_delayed_clbk(internal_data, id)
	if not internal_data.delayed_clbks or not internal_data.delayed_clbks[id] then
		return
	end

	internal_data.delayed_clbks[id] = nil

	if not next(internal_data.delayed_clbks) then
		internal_data.delayed_clbks = nil
	end
end

--[[function CopLogicBase.on_objective_unit_damaged(data, follow_unit, attacker_unit)
	if not alive(data.unit) or not alive(follow_unit) or data.unit:character_damage():dead() then
		return
	end

	local objective = data.objective

	if follow_unit:character_damage().dead and follow_unit:character_damage():dead() then
		objective.death_clbk_key = nil

		data.objective_failed_clbk(data.unit, objective)
	end

	if attacker_unit ~= nil and alive(attacker_unit) then
		if data.is_converted then
			local alert_data = {
				"aggression",
				attacker_unit:movement():m_pos(),
				[5] = attacker_unit
			}

			TeamAILogicIdle.on_alert(data, alert_data)

			local damage_info = {
				attacker_unit = attacker_unit,
				result = {
					type = "none"
				}
			}

			TeamAILogicIdle.damage_clbk(data, damage_info)
		elseif data.tactics and data.tactics.provide_coverfire then
			local alert_data = {
				"aggression",
				follow_unit:movement():m_pos(),
				1000,
				data.SO_access,
				attacker_unit,
				attacker_unit:movement():m_pos()
			}

			CopLogicIdle.on_alert(data, alert_data)

			local damage_info = {
				attacker_unit = attacker_unit
			}

			CopLogicIdle.damage_clbk(data, damage_info)
		end
	end
end]]

function CopLogicBase.draw_reserved_positions(data)
	local my_pos = data.m_pos
	local my_data = data.internal_data
	local rsrv_pos = data.pos_rsrv
	local flanking_unit = data.tactics and data.tactics.flank

	if rsrv_pos.path then
		local to_pos = rsrv_pos.path.position

		if flanking_unit then
			local line1 = Draw:brush(Color.blue:with_alpha(0.1), 0.1)
			line1:cylinder(my_pos, to_pos, 5)
			line1:sphere(to_pos, 5)
		else
			local line1 = Draw:brush(Color.blue:with_alpha(1), 0.1)
			line1:cylinder(my_pos, to_pos, 5)
			line1:sphere(to_pos, 5)
		end
	end

	if rsrv_pos.move_dest then
		local to_pos = rsrv_pos.move_dest.position

		if flanking_unit then
			local line1 = Draw:brush(Color.red:with_alpha(0.1), 0.1)
			line1:cylinder(my_pos, to_pos, 5)
			line1:sphere(to_pos, 5)
		else
			local line1 = Draw:brush(Color.red:with_alpha(1), 0.1)
			line1:cylinder(my_pos, to_pos, 5)
			line1:sphere(to_pos, 5)
		end
	end

	if rsrv_pos.stand then
		local to_pos = rsrv_pos.stand.position

		local line1 = Draw:brush(Color.white:with_alpha(0.1), 0.1)
		line1:cylinder(my_pos, to_pos, 5)
		line1:sphere(to_pos, 5)
	end

	if my_data.best_cover then
		local from_pos = my_pos + math_up * 140
		local cover_pos = my_data.best_cover[1][1]

		if flanking_unit then
			local line1 = Draw:brush(Color.green:with_alpha(0.1), 0.1)
			line1:cylinder(from_pos, cover_pos, 5)
			line1:sphere(cover_pos, 5)
		else
			local line1 = Draw:brush(Color.green:with_alpha(1), 0.1)
			line1:cylinder(from_pos, cover_pos, 5)
			line1:sphere(cover_pos, 5)
		end
	end

	if my_data.nearest_cover then
		local from_pos = my_pos + math_up * 180
		local cover_pos = my_data.nearest_cover[1][1]

		if flanking_unit then
			local line1 = Draw:brush(Color.green:with_alpha(0.1), 0.1)
			line1:cylinder(from_pos, cover_pos, 5)
			line1:sphere(cover_pos, 5)
		else
			local line1 = Draw:brush(Color.green:with_alpha(1), 0.1)
			line1:cylinder(from_pos, cover_pos, 5)
			line1:sphere(cover_pos, 5)
		end
	end

	if my_data.moving_to_cover then
		local from_pos = my_pos + math_up * 140
		local cover_pos = my_data.moving_to_cover[1][1]

		if flanking_unit then
			local line1 = Draw:brush(Color.yellow:with_alpha(0.1), 0.1)
			line1:cylinder(from_pos, cover_pos, 5)
			line1:sphere(cover_pos, 5)
		else
			local line1 = Draw:brush(Color.yellow:with_alpha(1), 0.1)
			line1:cylinder(from_pos, cover_pos, 5)
			line1:sphere(cover_pos, 5)
		end
	end
end

local use_metal_gear_detection = nil

function CopLogicBase._upd_attention_obj_detection(data, min_reaction, max_reaction)
	local my_data = data.internal_data
	local detected_obj = data.detected_attention_objects

	--[[if my_data.detection == tweak_data.character.presets.detection.blind then
		if next(detected_obj) then
			for u_key, attention_info in pairs_g(detected_obj) do
				CopLogicBase._destroy_detected_attention_object_data(data, attention_info)
			end
		end

		return 2
	end]]

	local t = data.t
	local my_key = data.key
	local my_pos = data.unit:movement():m_head_pos()
	local my_access = data.SO_access
	local my_head_fwd = nil
	local my_tracker = data.unit:movement():nav_tracker()
	--local chk_vis_func = my_tracker.check_visibility
	local vis_mask = data.visibility_slotmask
	local is_cool = data.cool
	local within_any_acquire_range = nil
	local player_importance_wgt = data.unit:in_slot(managers.slot:get_mask("enemies")) and {}

	local groupai_state_manager = managers.groupai:state()
	local is_stealth = use_metal_gear_detection and groupai_state_manager:whisper_mode()
	local all_attention_objects = groupai_state_manager:get_AI_attention_objects_by_filter(data.SO_access_str, data.team)
	local is_detection_persistent = groupai_state_manager:is_detection_persistent()

	for u_key, attention_info in pairs_g(all_attention_objects) do
		if u_key ~= my_key and not detected_obj[u_key] then
			local can_acquire = true

			if attention_info.unit:base() then
				if is_cool and attention_info.unit:base().is_husk_player --[[or attention_info.unit:base().is_local_player]] then
					can_acquire = false
				end
			end

			if can_acquire then
				--if not attention_info.nav_tracker or chk_vis_func(my_tracker, attention_info.nav_tracker) then
					local settings = attention_info.handler:get_attention(my_access, min_reaction, max_reaction, data.team)

					if settings then
						local acquired, angle, dis_multiplier = nil
						local attention_pos = attention_info.handler:get_detection_m_pos()
						local dis = mvec3_dir(tmp_vec1, my_pos, attention_pos)

						if my_data.detection.use_uncover_range and settings.uncover_range and dis < settings.uncover_range then
							within_any_acquire_range = is_cool and true

							angle = -1
							dis_multiplier = 0
						else
							local dis_mul = nil
							local max_dis = my_data.detection.dis_max

							if settings.max_range then
								max_dis = math_min(max_dis, settings.max_range)
							end

							if settings.detection and settings.detection.range_mul then
								max_dis = max_dis * settings.detection.range_mul
							end

							dis_mul = dis / max_dis

							if dis_mul < 1 then
								within_any_acquire_range = is_cool and true

								if settings.notice_requires_FOV then
									my_head_fwd = my_head_fwd or data.unit:movement():m_head_rot():z()
									local vec_angle = mvec3_angle(my_head_fwd, tmp_vec1)

									if use_metal_gear_detection and is_stealth and attention_info.unit:base() and attention_info.unit:base().is_local_player then
										if not my_data.detection.use_uncover_range and vec_angle < my_data.detection.angle_max and settings.uncover_range and dis < settings.uncover_range then
											angle = -1
											dis_multiplier = 0
										elseif vec_angle < my_data.detection.angle_max then
											local angle_max = math_lerp(180, my_data.detection.angle_max, math_clamp((dis - 150) / 700, 0, 1))
											angle_multiplier = vec_angle / angle_max

											if angle_multiplier < 1 then
												angle = vec_angle
												dis_multiplier = dis_mul
											end
										end
									elseif not my_data.detection.use_uncover_range and vec_angle < 55 and settings.uncover_range and dis < settings.uncover_range then
										angle = -1
										dis_multiplier = 0
									else
										local angle_max = math_lerp(180, my_data.detection.angle_max, math_clamp((dis - 150) / 700, 0, 1))
										angle_multiplier = vec_angle / angle_max

										if angle_multiplier < 1 then
											angle = vec_angle
											dis_multiplier = dis_mul
										end
									end
								else
									angle = 0
									dis_multiplier = dis_mul
								end
							end
						end

						if angle then
							local vis_ray = data.unit:raycast("ray", my_pos, attention_pos, "slot_mask", vis_mask, "ray_type", "ai_vision")

							if not vis_ray or vis_ray.unit:key() == u_key then
								acquired = true

								local visible_data = {
									visible_angle = angle,
									visible_dis_multiplier = dis_multiplier,
									visible_ray = vis_ray
								}
								detected_obj[u_key] = CopLogicBase._create_detected_attention_object_data(data.t, data.unit, u_key, attention_info, settings, nil, visible_data)
							end
						end

						if not acquired and player_importance_wgt then
							local is_human_player, is_local_player, is_husk_player = nil

							if attention_info.unit:base() then
								is_local_player = attention_info.unit:base().is_local_player
								is_husk_player = attention_info.unit:base().is_husk_player
								is_human_player = is_local_player or is_husk_player
							end

							if is_human_player then
								local weight = mvec3_dir(tmp_vec1, attention_pos, my_pos)
								local e_fwd = nil

								if is_husk_player then
									e_fwd = attention_info.unit:movement():detect_look_dir()
								else
									e_fwd = attention_info.unit:movement():m_head_rot():y()
								end

								local dot = mvec3_dot(e_fwd, tmp_vec1)
								weight = weight * weight * (1 - dot)

								table_insert(player_importance_wgt, u_key)
								table_insert(player_importance_wgt, weight)
							end
						end
					end
				--end
			end
		end
	end

	local delay = within_any_acquire_range and 0 or 2

	for u_key, attention_info in pairs_g(detected_obj) do
		local can_detect = true

		--[[if attention_info.is_local_player then
			CopLogicBase._destroy_detected_attention_object_data(data, attention_info)

			can_detect = false
		else]]if is_cool and attention_info.is_husk_player then
			can_detect = false

			if attention_info.client_casing_suspicion or attention_info.client_peaceful_detection then
				if t >= attention_info.next_verify_t then
					attention_info.next_verify_t = t

					local attention_pos = attention_info.m_head_pos
					local dis = mvec3_dis(my_pos, attention_pos)
					attention_info.dis = dis

					if attention_info.verified then
						attention_info.verified_t = t
						attention_info.verified_dis = dis

						mvec3_set(attention_info.verified_pos, attention_pos)

						if attention_info.last_verified_pos then
							mvec3_set(attention_info.last_verified_pos, attention_pos)
						else
							attention_info.last_verified_pos = mvec3_cpy(attention_pos)
						end
					end
				end
			end
		end

		if can_detect then
			if not attention_info.visible_in_this_instance and t < attention_info.next_verify_t then
				if REACT_SUSPICIOUS <= attention_info.reaction then
					delay = math_min(attention_info.next_verify_t - t, delay)
				end
			else
				local settings = attention_info.settings
				local verify_interval = nil

				if is_cool then
					verify_interval = 0
				elseif attention_info.identified and attention_info.verified then
					verify_interval = settings.verification_interval
				else
					verify_interval = settings.notice_interval or settings.verification_interval
				end

				attention_info.next_verify_t = t + verify_interval
				delay = math_min(delay, verify_interval)

				if not attention_info.identified then
					local noticable, angle, dis_multiplier = nil

					if attention_info.visible_in_this_instance then
						noticable = true
						angle = attention_info.visible_angle
						dis_multiplier = attention_info.visible_dis_multiplier
					else
						local attention_pos = attention_info.m_head_pos
						local dis = mvec3_dir(tmp_vec1, my_pos, attention_pos)

						if my_data.detection.use_uncover_range and settings.uncover_range and dis < settings.uncover_range then
							angle = -1
							dis_multiplier = 0
						else
							local dis_mul = nil
							local max_dis = my_data.detection.dis_max

							if settings.max_range then
								max_dis = math_min(max_dis, settings.max_range)
							end

							if settings.detection and settings.detection.range_mul then
								max_dis = max_dis * settings.detection.range_mul
							end

							dis_mul = dis / max_dis

							if dis_mul < 1 then
								if settings.notice_requires_FOV then
									my_head_fwd = my_head_fwd or data.unit:movement():m_head_rot():z()
									local vec_angle = mvec3_angle(my_head_fwd, tmp_vec1)

									if use_metal_gear_detection and is_stealth and attention_info.unit:base() and attention_info.unit:base().is_local_player then
										if not my_data.detection.use_uncover_range and vec_angle < my_data.detection.angle_max and settings.uncover_range and dis < settings.uncover_range then
											angle = -1
											dis_multiplier = 0
										elseif vec_angle < my_data.detection.angle_max then
											local angle_max = math_lerp(180, my_data.detection.angle_max, math_clamp((dis - 150) / 700, 0, 1))
											angle_multiplier = vec_angle / angle_max

											if angle_multiplier < 1 then
												angle = vec_angle
												dis_multiplier = dis_mul
											end
										end
									elseif not my_data.detection.use_uncover_range and vec_angle < 55 and settings.uncover_range and dis < settings.uncover_range then
										angle = -1
										dis_multiplier = 0
									else
										local angle_max = math_lerp(180, my_data.detection.angle_max, math_clamp((dis - 150) / 700, 0, 1))
										angle_multiplier = vec_angle / angle_max

										if angle_multiplier < 1 then
											angle = vec_angle
											dis_multiplier = dis_mul
										end
									end
								else
									angle = 0
									dis_multiplier = dis_mul
								end
							end
						end

						if angle then
							local vis_ray = attention_info.visible_ray or data.unit:raycast("ray", my_pos, attention_pos, "slot_mask", vis_mask, "ray_type", "ai_vision")

							if not vis_ray or vis_ray.unit:key() == u_key then
								noticable = true
								attention_info.visible_in_this_instance = true
							end

							if not attention_info.visible_ray then
								attention_info.visible_ray = vis_ray
							end
						end
					end

					local delta_prog = nil
					local dt = t - attention_info.prev_notice_chk_t

					if noticable then
						if angle == -1 then
							delta_prog = 1
						else
							local min_delay = my_data.detection.delay[1]
							local max_delay = my_data.detection.delay[2]
							local angle_mul_mod = 0.25 * math_min(angle / my_data.detection.angle_max, 1)
							local dis_mul_mod = 0.75 * dis_multiplier
							local notice_delay_mul = settings.notice_delay_mul or 1

							if settings.detection and settings.detection.delay_mul then
								notice_delay_mul = notice_delay_mul * settings.detection.delay_mul
							end

							local notice_delay_modified = math_lerp(min_delay * notice_delay_mul, max_delay, dis_mul_mod + angle_mul_mod)
							delta_prog = notice_delay_modified > 0 and dt / notice_delay_modified or 1
						end
					else
						delta_prog = dt * -0.125
					end

					attention_info.notice_progress = attention_info.notice_progress + delta_prog

					if attention_info.notice_progress > 1 then
						attention_info.notice_progress = nil
						attention_info.prev_notice_chk_t = nil
						attention_info.identified = true
						attention_info.release_t = t + settings.release_delay
						attention_info.identified_t = t
						noticable = true

						data.logic.on_attention_obj_identified(data, u_key, attention_info)
					elseif attention_info.notice_progress < 0 then
						CopLogicBase._destroy_detected_attention_object_data(data, attention_info)

						noticable = false
					else
						noticable = attention_info.notice_progress
						attention_info.prev_notice_chk_t = t

						if is_cool and REACT_SCARED <= settings.reaction then
							groupai_state_manager:on_criminal_suspicion_progress(attention_info.unit, data.unit, noticable)
						end
					end

					if noticable ~= false and settings.notice_clbk then
						settings.notice_clbk(data.unit, noticable)
					end
				end

				if attention_info.identified then
					local is_ignored = false

					if attention_info.unit:movement() and attention_info.unit:movement().is_cuffed then
						is_ignored = attention_info.unit:movement():is_cuffed()
					end

					if is_ignored then
						CopLogicBase._destroy_detected_attention_object_data(data, attention_info)
					else
						if not is_cool then
							attention_info.next_verify_t = t + settings.verification_interval
							delay = math_min(delay, settings.verification_interval)
						end

						attention_info.nearly_visible = nil

						local verified, vis_ray = nil
						local attention_pos = attention_info.m_head_pos
						local dis = mvec3_dis(my_pos, attention_pos)
						local max_dis = my_data.detection.dis_max

						if dis < max_dis * 1.2 then
							if settings.max_range then
								max_dis = math_min(max_dis, settings.max_range)
							end

							if settings.detection and settings.detection.range_mul then
								max_dis = max_dis * settings.detection.range_mul
							end

							if dis < max_dis * 1.2 then
								local in_FOV = not settings.notice_requires_FOV or data.enemy_slotmask and attention_info.unit:in_slot(data.enemy_slotmask)

								if not in_FOV then
									mvec3_dir(tmp_vec1, my_pos, attention_pos)

									my_head_fwd = my_head_fwd or data.unit:movement():m_head_rot():z()
									local angle = mvec3_angle(my_head_fwd, tmp_vec1)
									local angle_max = math_lerp(180, my_data.detection.angle_max, math_clamp((dis - 150) / 700, 0, 1))
									local strictness = 0.8

									if angle_max > angle * strictness then
										in_FOV = true
									end
								end

								if in_FOV then
									if attention_info.visible_in_this_instance then
										verified = true
										vis_ray = attention_info.visible_ray
									else
										vis_ray = attention_info.visible_ray or data.unit:raycast("ray", my_pos, attention_pos, "slot_mask", vis_mask, "ray_type", "ai_vision")

										if not vis_ray or vis_ray.unit:key() == u_key then
											verified = true
										end
									end
								end
							end
						end

						attention_info.verified = verified
						attention_info.dis = dis
						attention_info.vis_ray = vis_ray

						if verified then
							attention_info.nearly_visible_t = nil
							attention_info.release_t = nil
							attention_info.verified_t = t
							attention_info.verified_dis = dis

							mvec3_set(attention_info.verified_pos, attention_pos)

							if attention_info.last_verified_pos then
								mvec3_set(attention_info.last_verified_pos, attention_pos)
							else
								attention_info.last_verified_pos = mvec3_cpy(attention_pos)
							end
						elseif not is_cool and REACT_COMBAT <= settings.reaction and data.enemy_slotmask and attention_info.unit:in_slot(data.enemy_slotmask) then
							local destroyed_att_data = nil

							if is_detection_persistent and attention_info.criminal_record then
								attention_info.release_t = nil

								delay = math_min(0.2, delay)
								attention_info.next_verify_t = math_min(0.2, attention_info.next_verify_t)

								mvec3_set(attention_info.verified_pos, attention_pos)

								attention_info.verified_dis = dis
							elseif attention_info.release_t and attention_info.release_t < t then
								CopLogicBase._destroy_detected_attention_object_data(data, attention_info)

								destroyed_att_data = true
							else
								attention_info.release_t = attention_info.release_t or t + settings.release_delay
							end

							if not destroyed_att_data and vis_ray and attention_info.is_person and dis < 2000 and data.logic._chk_nearly_visible_chk_needed(data, attention_info, u_key) then
								local side_offset = 25
								local head_offset = 15
								local hips_offset = 35
								local legs_offset = 70

								if attention_info.is_human_player then
									side_offset = 20
									head_offset = 10
								end

								local near_pos = tmp_vec1
								local side_vec = tmp_vec2

								mvec3_set(side_vec, attention_pos)
								mvec3_sub(side_vec, my_pos)
								mvec3_cross(side_vec, side_vec, math_up)
								mvec3_set_length(side_vec, side_offset)
								mvec3_set(near_pos, attention_pos)
								mvec3_add(near_pos, side_vec)

								local near_vis_ray = data.unit:raycast("ray", my_pos, near_pos, "slot_mask", vis_mask, "ray_type", "ai_vision", "report")

								if near_vis_ray then
									mvec3_mul(side_vec, -2)
									mvec3_add(near_pos, side_vec)

									near_vis_ray = data.unit:raycast("ray", my_pos, near_pos, "slot_mask", vis_mask, "ray_type", "ai_vision", "report")

									if near_vis_ray then
										mvec3_set(near_pos, attention_pos)
										mvec3_set_z(near_pos, near_pos.z + head_offset)

										near_vis_ray = data.unit:raycast("ray", my_pos, near_pos, "slot_mask", vis_mask, "ray_type", "ai_vision", "report")

										if near_vis_ray then
											mvec3_set(near_pos, attention_pos)
											mvec3_set_z(near_pos, near_pos.z - hips_offset)

											near_vis_ray = data.unit:raycast("ray", my_pos, near_pos, "slot_mask", vis_mask, "ray_type", "ai_vision", "report")

											if near_vis_ray then
												mvec3_set(near_pos, attention_pos)
												mvec3_set_z(near_pos, near_pos.z - legs_offset)

												near_vis_ray = data.unit:raycast("ray", my_pos, near_pos, "slot_mask", vis_mask, "ray_type", "ai_vision", "report")
											end
										end
									end
								end

								if not near_vis_ray then
									attention_info.nearly_visible = true
									attention_info.nearly_visible_t = t
									attention_info.release_t = nil

									if attention_info.last_verified_pos then
										mvec3_set(attention_info.last_verified_pos, attention_pos)
									else
										attention_info.last_verified_pos = mvec3_cpy(attention_pos)
									end
								end
							end
						elseif attention_info.release_t and attention_info.release_t < t then
							CopLogicBase._destroy_detected_attention_object_data(data, attention_info)
						else
							attention_info.release_t = attention_info.release_t or t + settings.release_delay
						end
					end
				end
			end
		end

		if player_importance_wgt and attention_info.is_human_player then
			local weight = mvec3_dir(tmp_vec1, attention_info.m_head_pos, my_pos)
			local e_fwd = nil

			if attention_info.is_husk_player then
				e_fwd = attention_info.unit:movement():detect_look_dir()
			else
				e_fwd = attention_info.unit:movement():m_head_rot():y()
			end

			local dot = mvec3_dot(e_fwd, tmp_vec1)
			weight = weight * weight * (1 - dot)

			table_insert(player_importance_wgt, attention_info.u_key)
			table_insert(player_importance_wgt, weight)
		end

		attention_info.visible_in_this_instance = nil
		attention_info.visible_angle = nil
		attention_info.visible_dis_multiplier = nil
		attention_info.visible_ray = nil
	end

	if player_importance_wgt then
		managers.groupai:state():set_importance_weight(data.key, player_importance_wgt)
	end

	return delay
end

function CopLogicBase._create_detected_attention_object_data(t, my_unit, u_key, attention_info, settings, forced, visible_data)
	local ext_brain = my_unit:brain()

	attention_info.handler:add_listener("detect_" .. tostring_g(my_unit:key()), callback(ext_brain, ext_brain, "on_detected_attention_obj_modified"))

	local att_unit = attention_info.unit
	local m_pos = attention_info.handler:get_ground_m_pos()
	local m_head_pos = attention_info.handler:get_detection_m_pos()
	local is_local_player, is_husk_player, is_deployable, is_person, nav_tracker, char_tweak, m_rot = nil
	local is_alive = true

	if att_unit:base() then
		is_local_player = att_unit:base().is_local_player
		is_husk_player = att_unit:base().is_husk_player
		is_deployable = att_unit:base().sentry_gun
		is_person = att_unit:in_slot(managers.slot:get_mask("persons"))

		if att_unit:base().char_tweak then
			char_tweak = att_unit:base():char_tweak()
		end
	end

	if att_unit:movement() and att_unit:movement().m_rot then
		m_rot = att_unit:movement():m_rot()
	end

	if att_unit:character_damage() and att_unit:character_damage().dead then
		is_alive = not att_unit:character_damage():dead()
	end

	local verify_interval = settings.notice_interval or settings.verification_interval
	local dis = mvec3_dis(my_unit:movement():m_head_pos(), m_head_pos)
	local new_entry = {
		verified = false,
		verified_t = false,
		notice_progress = 0,
		settings = settings,
		unit = attention_info.unit,
		u_key = u_key,
		handler = attention_info.handler,
		next_verify_t = t + verify_interval,
		prev_notice_chk_t = t,
		m_rot = m_rot,
		m_pos = m_pos,
		m_head_pos = m_head_pos,
		nav_tracker = attention_info.nav_tracker,
		is_local_player = is_local_player,
		is_husk_player = is_husk_player,
		is_human_player = is_local_player or is_husk_player,
		is_deployable = is_deployable,
		is_person = is_person,
		is_alive = is_alive,
		reaction = settings.reaction,
		criminal_record = managers.groupai:state():criminal_record(u_key),
		char_tweak = char_tweak,
		verified_pos = mvec3_cpy(m_head_pos),
		verified_dis = dis,
		dis = dis,
		has_team = att_unit:movement() and att_unit:movement().team,
		health_ratio = att_unit:character_damage() and att_unit:character_damage().health_ratio,
		objective = att_unit:brain() and att_unit:brain().objective,
		forced = forced
	}

	if visible_data then
		new_entry.visible_in_this_instance = true
		new_entry.visible_angle = visible_data.visible_angle
		new_entry.visible_dis_multiplier = visible_data.visible_dis_multiplier
		new_entry.visible_ray = visible_data.visible_ray
		visible_data = nil
	end

	return new_entry
end

function CopLogicBase._destroy_detected_attention_object_data(data, attention_info)
	attention_info.handler:remove_listener("detect_" .. tostring_g(data.key))

	local my_unit = data.unit
	local settings = attention_info.settings

	if settings.notice_clbk then
		settings.notice_clbk(my_unit, false)
	end

	if REACT_SUSPICIOUS <= settings.reaction then
		managers.groupai:state():on_criminal_suspicion_progress(attention_info.unit, my_unit, nil)
	end

	if attention_info.uncover_progress then
		attention_info.unit:movement():on_suspicion(my_unit, false)
	end

	local removed_key = attention_info.u_key

	data.detected_attention_objects[removed_key] = nil

	local my_data = data.internal_data
	--the fact that I need to ensure the unit exists to prevent a crash means there's a very deep issue somewhere (very likely vanilla)
	--a listener didn't get removed when a unit was destroyed, which is really, really bad
	local my_mov_ext = alive(my_unit) and my_unit.movement and my_unit:movement()
	local current_att_obj = data.attention_obj

	if not my_mov_ext then
		log("coplogicbase: attention destroy listener wasn't removed on a unit that got destroyed!")

		if not alive(my_unit) then
			log("coplogicbase: unit was destroyed!")
		elseif not my_unit.in_slot then
			log("coplogicbase: no in_slot function???")
		elseif my_unit:in_slot(0) then
			log("coplogicbase: unit is being destroyed!")
		else
			log("coplogicbase: unit is still intact on the C side")

			local my_base_ext = my_unit.base and my_unit:base()

			if not my_base_ext then
				log("coplogicbase: unit has no base() extension")
			elseif my_base_ext._tweak_table then
				log("coplogicbase: unit has tweak table: " .. tostring(my_base_ext._tweak_table) .. "")
			else
				log("coplogicbase: unit has no tweak table")
			end

			local my_dmg_ext = my_unit.character_damage and my_unit:character_damage()

			if not my_dmg_ext then
				log("coplogicbase: unit has no character_damage() extension")
			elseif my_dmg_ext.dead and my_dmg_ext:dead() then
				log("coplogicbase: unit is dead")
			end
		end

		local cur_logic_name = data.name

		if cur_logic_name then
			log("coplogicbase: logic name: " .. tostring(cur_logic_name) .. "")
		end

		local att_unit = attention_info and attention_info.unit

		if not alive(att_unit) then
			log("coplogicbase: attention unit was destroyed!")
		elseif att_unit:in_slot(0) then
			log("coplogicbase: attention unit is being destroyed!")
		else
			log("coplogicbase: attention unit is still intact on the C side")

			local unit_name = att_unit.name and att_unit:name()

			if unit_name then
				--might be pure gibberish
				log("coplogicbase: attention unit name: " .. tostring(unit_name) .. "")
			end

			if att_unit:id() == -1 then
				log("coplogicbase: attention unit was detached from the network")
			end

			local att_base_ext = att_unit:base()

			if not att_base_ext then
				log("coplogicbase: attention unit has no base() extension")
			elseif att_base_ext._tweak_table then
				log("coplogicbase: attention unit has tweak table: " .. tostring(att_base_ext._tweak_table) .. "")
			elseif att_base_ext.is_husk_player then
				log("coplogicbase: attention unit was a player husk")
			elseif att_base_ext.is_local_player then
				log("coplogicbase: attention unit was the local player")
			end

			local att_dmg_ext = att_unit:character_damage()

			if not att_dmg_ext then
				log("coplogicbase: attention unit has no character_damage() extension")
			elseif att_dmg_ext.dead and att_dmg_ext:dead() then
				log("coplogicbase: attention unit is dead")
			end
		end
	end

	if current_att_obj and current_att_obj.u_key == removed_key then
		CopLogicBase._set_attention_obj(data, nil, nil)

		if my_data and my_data.firing then
			if my_mov_ext then
				my_mov_ext:set_allow_fire(false)
			end

			my_data.firing = nil
		end
	end

	if my_data and my_data.arrest_targets and my_data.arrest_targets[removed_key] then
		managers.groupai:state():on_arrest_end(data.key, removed_key)

		my_data.arrest_targets[removed_key] = nil
	end
end

function CopLogicBase.on_detected_attention_obj_modified(data, modified_u_key)
	if data.logic.on_detected_attention_obj_modified_internal then
		data.logic.on_detected_attention_obj_modified_internal(data, modified_u_key)
	end

	local attention_info = data.detected_attention_objects[modified_u_key]

	if not attention_info then
		return
	end

	local new_settings = attention_info.handler:get_attention(data.SO_access, nil, nil, data.team)
	local old_settings = attention_info.settings

	if new_settings == old_settings then
		return
	end

	local old_notice_clbk = not attention_info.identified and old_settings.notice_clbk

	if new_settings then
		if data.cool then
			if attention_info.client_casing_suspicion or attention_info.client_peaceful_detection then
				attention_info.reaction = new_settings.reaction

				return
			end
		end

		local switch_from_suspicious = REACT_SCARED <= new_settings.reaction and attention_info.reaction <= REACT_SUSPICIOUS
		attention_info.settings = new_settings
		attention_info.stare_expire_t = nil
		attention_info.pause_expire_t = nil

		if switch_from_suspicious then
			attention_info.next_verify_t = 0
			attention_info.prev_notice_chk_t = TimerManager:game():time()

			if attention_info.identified then
				attention_info.identified = false
				attention_info.notice_progress = attention_info.uncover_progress or 0
				attention_info.verified = nil
			else
				attention_info.notice_progress = 0
			end
		end

		local old_reaction = attention_info.reaction

		attention_info.uncover_progress = nil
		attention_info.reaction = new_settings.reaction

		if attention_info.unit:character_damage() and attention_info.unit:character_damage().dead then
			attention_info.is_alive = not attention_info.unit:character_damage():dead()
		end

		if data.attention_obj and data.attention_obj.u_key == modified_u_key then
			if old_reaction and old_reaction > REACT_AIM then
				if not attention_info.is_alive or attention_info.reaction < old_reaction then
					local my_data = data.internal_data

					if my_data and my_data.firing then
						data.unit:movement():set_allow_fire(false)

						my_data.firing = nil
					end
				end
			end
		end
	else
		CopLogicBase._destroy_detected_attention_object_data(data, attention_info)
	end

	if old_notice_clbk then
		if not new_settings or not new_settings.notice_clbk then
			old_notice_clbk(data.unit, false)
		end
	end

	if REACT_SCARED <= old_settings.reaction then
		if not new_settings or REACT_SCARED > new_settings.reaction then
			managers.groupai:state():on_criminal_suspicion_progress(attention_info.unit, data.unit, nil)
		end
	end
end

function CopLogicBase._set_attention_obj(data, new_att_obj, new_reaction)
	local old_att_obj = data.attention_obj
	data.attention_obj = new_att_obj

	if new_att_obj then
		new_reaction = new_reaction or new_att_obj.settings.reaction
		new_att_obj.reaction = new_reaction
		local new_crim_rec = new_att_obj.criminal_record
		local is_same_obj, contact_chatter_time_ok = nil

		if old_att_obj then
			if old_att_obj.u_key == new_att_obj.u_key then
				is_same_obj = true
				contact_chatter_time_ok = new_crim_rec and data.t - new_crim_rec.det_t > 5

				if new_att_obj.stare_expire_t and new_att_obj.stare_expire_t < data.t then
					if new_att_obj.settings.pause then
						new_att_obj.stare_expire_t = nil
						new_att_obj.pause_expire_t = data.t + math_lerp(new_att_obj.settings.pause[1], new_att_obj.settings.pause[2], math_random())
					end
				elseif new_att_obj.pause_expire_t and new_att_obj.pause_expire_t < data.t then
					if not new_att_obj.settings.attract_chance or math_random() < new_att_obj.settings.attract_chance then
						new_att_obj.pause_expire_t = nil
						new_att_obj.stare_expire_t = data.t + math_lerp(new_att_obj.settings.duration[1], new_att_obj.settings.duration[2], math_random())
					else
						new_att_obj.pause_expire_t = data.t + math_lerp(new_att_obj.settings.pause[1], new_att_obj.settings.pause[2], math_random())
					end
				end
			else
				if old_att_obj.criminal_record then
					managers.groupai:state():on_enemy_disengaging(data.unit, old_att_obj.u_key)
				end

				if new_crim_rec then
					managers.groupai:state():on_enemy_engaging(data.unit, new_att_obj.u_key)

					contact_chatter_time_ok = data.t - new_crim_rec.det_t > 15
				end
			end
		elseif new_crim_rec then
			managers.groupai:state():on_enemy_engaging(data.unit, new_att_obj.u_key)

			contact_chatter_time_ok = data.t - new_crim_rec.det_t > 15
		end

		if not is_same_obj then
			if new_att_obj.settings.duration then
				new_att_obj.stare_expire_t = data.t + math_lerp(new_att_obj.settings.duration[1], new_att_obj.settings.duration[2], math_random())
				new_att_obj.pause_expire_t = nil
			end

			new_att_obj.acquire_t = data.t
		end

		local tactics = data.tactics

		if tactics and tactics.tunnel then
			data.tunnel_focus = new_reaction >= REACT_COMBAT and new_att_obj.u_key or nil
		end

		--[[if contact_chatter_time_ok then
			if data.char_tweak.chatter.contact or data.unit:base().has_tag and data.unit:base():has_tag("spooc") then
				if new_att_obj.is_person and new_att_obj.verified and REACT_SHOOT <= new_reaction then
					if data.unit:anim_data().idle or data.unit:anim_data().move then
						data.unit:sound():say("c01", true)
					end
				end
			end
		end]]

		if contact_chatter_time_ok and data.char_tweak.chatter.contact and new_att_obj.is_person and new_att_obj.verified and REACT_SHOOT <= new_reaction then
			if data.unit:anim_data().idle or data.unit:anim_data().move then
				data.unit:sound():say("c01", true)
			end
		end
	elseif old_att_obj then
		local tactics = data.tactics

		if tactics and tactics.tunnel then
			data.tunnel_focus = nil
		end

		if old_att_obj.criminal_record then
			managers.groupai:state():on_enemy_disengaging(data.unit, old_att_obj.u_key)
		end
	end
end

function CopLogicBase.should_duck_on_alert(data, alert_data)
	--[[if data.char_tweak.allowed_poses and not data.char_tweak.allowed_poses.crouch or data.unit:anim_data().crouch or data.unit:movement():chk_action_forbidden("walk") then
		return
	end

	if not data.char_tweak.crouch_move then
		local lower_body_action = data.unit:movement()._active_actions[2]

		if lower_body_action and lower_body_action:type() == "walk" then
			return
		end
	end

	return true]]
end

--allows nearly_visible checks to work more consistently while still saving perfomance
function CopLogicBase._chk_nearly_visible_chk_needed(data, attention_info, u_key)
	local current_focus = data.attention_obj

	if current_focus then
		if current_focus.u_key == u_key then
			return true
		elseif not current_focus.verified and not current_focus.nearly_visible then
			if attention_info.verified_t and data.t - attention_info.verified_t < 3 or attention_info.nearly_visible_t and data.t - attention_info.nearly_visible_t < 3 then
				return true
			end
		end
	elseif attention_info.verified_t and data.t - attention_info.verified_t < 3 or attention_info.nearly_visible_t and data.t - attention_info.nearly_visible_t < 3 then
		return true
	end
end

function CopLogicBase.is_obstructed(data, objective, strictness, attention)
	if not objective then
		return true, false
	end

	if data.unit:character_damage():dead() then
		return true, true
	end

	local health_ratio = data.unit:character_damage():health_ratio()

	if health_ratio <= 0 then
		return true, true
	end

	if objective.is_default then
		return true, false
	elseif objective.in_place or not objective.nav_seg then
		if not objective.action then
			return true, false
		end
	end

	if objective.interrupt_suppression and data.is_suppressed then
		return true, true
	end

	local strictness_mul = strictness and 1 - strictness

	if objective.interrupt_health then
		if health_ratio < 1 then
			local too_much_damage = nil

			if strictness_mul then
				too_much_damage = health_ratio * strictness_mul < objective.interrupt_health
			else
				too_much_damage = health_ratio < objective.interrupt_health
			end

			if too_much_damage then
				return true, true
			end
		end
	end
	
	if not objective.running then
		if attention and REACT_COMBAT <= attention.reaction then
			local good_types = {
				free = true,
				defend_area = true
			}
				
			if good_types[objective.type] then
				local good_grp_types = {
					recon_area = true,
					assault_area = true,
					reenforce_area = true,
					defend_area = true
				}
				
				if not objective.grp_objective or good_grp_types[objective.grp_objective.type] then 
					local my_nav_seg = data.unit:movement():nav_tracker():nav_segment()
					local my_area = managers.groupai:state():get_area_from_nav_seg_id(data.unit:movement():nav_tracker():nav_segment())
					
					if objective.area and objective.area.nav_segs[my_nav_seg] and next(objective.area.criminal.units) then
						return true, false
					end
					
					if REACT_COMBAT <= attention.reaction then
						if not data.tactics or not data.tactics.charge or objective.area and next(objective.area.police.units) then
							local grp_objective = objective.grp_objective
							local dis = data.unit:base()._engagement_range or data.internal_data.weapon_range and data.internal_data.weapon_range.optimal or 500
							local my_data = data.internal_data
							local soft_t = 3.5
							if grp_objective and not grp_objective.open_fire then
								dis = dis * 0.5
								soft_t = 1 
							end
							
							local visible_softer = attention.verified_t and data.t - attention.verified_t < soft_t
							if visible_softer and attention.dis <= dis then
								return true, false
							end
						end
					end
				end
			end
		end	
	end
	
	if objective.interrupt_dis then
		attention = attention or data.attention_obj

		if attention and attention.reaction then
			local reaction_to_check = nil

			if data.cool then
				reaction_to_check = REACT_SURPRISED
			else
				reaction_to_check = REACT_COMBAT
			end
			
			if reaction_to_check <= attention.reaction then
				if objective.interrupt_dis == -1 then
					return true, true
				elseif math_abs(attention.m_pos.z - data.m_pos.z) < 250 then
					local enemy_dis = attention.dis

					if strictness_mul then
						enemy_dis = enemy_dis * strictness_mul
					end

					if not attention.verified then
						enemy_dis = enemy_dis * 2
					end

					if enemy_dis < objective.interrupt_dis then
						return true, true
					end
				end

				if objective.pos and math_abs(attention.m_pos.z - objective.pos.z) < 250 then
					local enemy_dis = mvec3_dis(objective.pos, attention.m_pos)

					if strictness_mul then
						enemy_dis = enemy_dis * strictness_mul
					end

					if enemy_dis < objective.interrupt_dis then
						return true, true
					end
				end
			elseif objective.interrupt_dis == -1 and not data.cool then
				return true, true
			end
		elseif objective.interrupt_dis == -1 and not data.cool then
			return true, true
		end
	end

	--[[if objective.interrupt_dis and data.name == "travel" and data.attention_obj and data.attention_obj.reaction >= REACT_COMBAT and data.unit:base().has_tag and data.unit:base():has_tag("special") then
		if not data.unit:base():has_tag("sniper") and data.unit:base()._tweak_table ~= "phalanx_minion" and data.unit:base()._tweak_table ~= "phalanx_vip" then
			local enter_attack_range = 1400
			local focus_enemy_dis = data.attention_obj.verified and data.attention_obj.dis or data.attention_obj.verified_dis

			if focus_enemy_dis < enter_attack_range then
				return true, true
			end
		end
	end]]

	return false, false
end

function CopLogicBase._chk_say_criminal_too_close(data, attention_obj)
	if not data.said_too_close_t or data.t > data.said_too_close_t then
		if not data.unit:sound():speaking(data.t) then
			local required_dis = attention_obj.settings.turn_around_range or 250

			if data.attention_obj.dis < required_dis then
				data.unit:sound():say("a02", true)

				data.said_too_close_t = data.t + math_lerp(15, 25, math_random())
			end
		end
	end
end

function CopLogicBase._upd_suspicion(data, my_data, attention_obj)
	if attention_obj.client_casing_suspicion then
		--CopLogicBase._chk_say_criminal_too_close(data, attention_obj)

		return
	end

	local function _exit_func()
		data.unit:sound():say("a01", true)

		if not attention_obj.client_casing_detected then
			attention_obj.unit:movement():on_uncovered(data.unit)
		else
			attention_obj.client_casing_detected = nil
			attention_obj.client_casing_suspicion = true
		end

		local reaction, state_name = nil

		if attention_obj.forced then
			reaction = REACT_SHOOT
			state_name = "attack"
		elseif attention_obj.verified then
			if not data.char_tweak.no_arrest and attention_obj.dis < 2000 then
				reaction = REACT_ARREST
				state_name = "arrest"
			elseif attention_obj.criminal_record and attention_obj.criminal_record.being_arrested then
				reaction = REACT_AIM
				state_name = "attack"
			else
				reaction = REACT_COMBAT
				state_name = "attack"
			end
		elseif data.char_tweak.calls_in then
			reaction = REACT_AIM
			state_name = "arrest"
		else
			reaction = REACT_COMBAT
			state_name = "attack"
		end

		attention_obj.reaction = reaction
		local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, data.objective, nil, attention_obj)

		if allow_trans then
			if obj_failed then
				data.objective_failed_clbk(data.unit, data.objective)
			end

			if my_data == data.internal_data then
				CopLogicBase._exit(data.unit, state_name)
			end

			return true
		end
	end

	if attention_obj.client_casing_detected then
		managers.groupai:state():criminal_spotted(attention_obj.unit)

		return _exit_func()
	end

	local dis = attention_obj.dis
	local susp_settings = attention_obj.unit:base():suspicion_settings()

	if attention_obj.verified and attention_obj.settings.uncover_range and dis < math_min(attention_obj.settings.max_range, attention_obj.settings.uncover_range) * susp_settings.range_mul then
		attention_obj.unit:movement():on_suspicion(data.unit, true)
		managers.groupai:state():criminal_spotted(attention_obj.unit)

		return _exit_func()
	elseif attention_obj.verified and attention_obj.settings.suspicion_range and dis < math_min(attention_obj.settings.max_range, attention_obj.settings.suspicion_range) * susp_settings.range_mul then
		if attention_obj.last_suspicion_t then
			local dt = data.t - attention_obj.last_suspicion_t
			local uncover_range = attention_obj.settings.uncover_range or 0
			local range_max = attention_obj.settings.suspicion_range - uncover_range
			range_max = range_max * susp_settings.range_mul
			local range_min = uncover_range * susp_settings.range_mul
			local mul = 1 - (dis - range_min) / range_max
			local progress = dt * mul * susp_settings.buildup_mul / attention_obj.settings.suspicion_duration

			if attention_obj.uncover_progress then
				attention_obj.uncover_progress = attention_obj.uncover_progress + progress
			else
				attention_obj.uncover_progress = progress
			end

			if attention_obj.uncover_progress < 1 then
				attention_obj.unit:movement():on_suspicion(data.unit, attention_obj.uncover_progress)
				managers.groupai:state():on_criminal_suspicion_progress(attention_obj.unit, data.unit, attention_obj.uncover_progress)

				--CopLogicBase._chk_say_criminal_too_close(data, attention_obj)
			else
				attention_obj.unit:movement():on_suspicion(data.unit, true)
				managers.groupai:state():criminal_spotted(attention_obj.unit)

				return _exit_func()
			end
		else
			attention_obj.uncover_progress = 0
		end

		attention_obj.last_suspicion_t = data.t
	elseif attention_obj.uncover_progress then
		if attention_obj.last_suspicion_t then
			local dt = data.t - attention_obj.last_suspicion_t
			attention_obj.uncover_progress = attention_obj.uncover_progress - dt

			if attention_obj.uncover_progress <= 0 then
				attention_obj.uncover_progress = nil
				attention_obj.last_suspicion_t = nil

				attention_obj.unit:movement():on_suspicion(data.unit, false)
			else
				attention_obj.unit:movement():on_suspicion(data.unit, attention_obj.uncover_progress)
			end
		else
			attention_obj.last_suspicion_t = data.t
		end
	end
end

function CopLogicBase.upd_suspicion_decay(data)
	local my_data = data.internal_data

	for u_key, u_data in pairs_g(data.detected_attention_objects) do
		if not u_data.client_casing_suspicion and u_data.uncover_progress and u_data.last_suspicion_t ~= data.t then
			local dt = data.t - u_data.last_suspicion_t
			u_data.uncover_progress = u_data.uncover_progress - dt

			if u_data.uncover_progress <= 0 then
				u_data.uncover_progress = nil
				u_data.last_suspicion_t = nil

				u_data.unit:movement():on_suspicion(data.unit, false)
			else
				u_data.unit:movement():on_suspicion(data.unit, u_data.uncover_progress)

				u_data.last_suspicion_t = data.t
			end
		end
	end
end

function CopLogicBase._get_logic_state_from_reaction(data, reaction)
	local current_focus = data.attention_obj

	if current_focus and current_focus.forced then
		return "attack"
	end

	if data.cool then
		return
	end

	if reaction == nil and current_focus then
		reaction = current_focus.reaction
	end

	if data.is_converted then
		if not reaction or reaction < REACT_AIM then
			return "idle"
		else
			return "attack"
		end
	end

	if not reaction or reaction < REACT_AIM then
		if data.char_tweak.calls_in and not managers.groupai:state():is_police_called() then
			if not data.objective or not data.objective.no_arrest then
				if not CopLogicArrest._chk_already_calling_in_area(data) then
					return "arrest"
				end
			end
		end

		return "idle"
	elseif reaction == REACT_ARREST and CopLogicBase._can_arrest(data) then
		return "arrest"
	elseif data.char_tweak.calls_in and not managers.groupai:state():is_police_called() then
		if not data.objective or not data.objective.no_arrest then
			if not current_focus or reaction == REACT_AIM and not current_focus.is_person or current_focus.criminal_record and current_focus.criminal_record.being_arrested or current_focus.dis > 1500 or not current_focus.verified_t or data.t - current_focus.verified_t > 6 then
				if not CopLogicArrest._chk_already_calling_in_area(data) then
					return "arrest"
				end
			end
		end
	end

	return "attack"
end

function CopLogicBase._chk_call_the_police(data)
	if data.is_converted or data.cool or not data.char_tweak.calls_in or managers.groupai:state():is_police_called() then
		return
	end

	--doing this instead of calling CopLogicBase._can_arrest(data), which would check for data.char_tweak.no_arrest, and that makes no sense (no_arrest in an objective just means "don't switch to arrest logic")
	if data.objective and data.objective.no_arrest then
		return
	end

	local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, data.objective, nil, nil)

	if allow_trans and data.logic.is_available_for_assignment(data) then
		local current_focus = data.attention_obj

		if not current_focus or current_focus.reaction < REACT_AIM --[[or current_focus.reaction == REACT_ARREST and not data.char_tweak.no_arrest]] or not current_focus.verified_t or data.t - current_focus.verified_t > 6 then
			if obj_failed then
				data.objective_failed_clbk(data.unit, data.objective)
			end

			if not data.objective or data.objective.is_default then
				--[[local my_cur_nav_seg = data.unit:movement():nav_tracker():nav_segment()
				local my_cur_area = managers.groupai:state():get_area_from_nav_seg_id(my_cur_nav_seg)
				local already_calling_in_area = managers.groupai:state():chk_enemy_calling_in_area(my_cur_area, data.key)]]

				if not CopLogicArrest._chk_already_calling_in_area(data) then
					CopLogicBase._exit(data.unit, "arrest")
				end
			end
		end
	end
end

function CopLogicBase.identify_attention_obj_instant(data, att_u_key)
	local att_obj_data = data.detected_attention_objects[att_u_key]
	local is_new = not att_obj_data

	if att_obj_data then
		local detect_pos = att_obj_data.m_head_pos
		mvec3_set(att_obj_data.verified_pos, detect_pos)

		att_obj_data.verified_dis = mvec3_dis(data.unit:movement():m_head_pos(), detect_pos)

		if not att_obj_data.identified then
			att_obj_data.identified = true
			att_obj_data.identified_t = TimerManager:game():time()
			att_obj_data.notice_progress = nil
			att_obj_data.prev_notice_chk_t = nil

			if att_obj_data.settings.notice_clbk then
				att_obj_data.settings.notice_clbk(data.unit, true)
			end

			data.logic.on_attention_obj_identified(data, att_u_key, att_obj_data)
		elseif att_obj_data.uncover_progress then
			att_obj_data.uncover_progress = nil

			att_obj_data.unit:movement():on_suspicion(data.unit, false)
		end
	else
		local attention_info = managers.groupai:state():get_AI_attention_objects_by_filter(data.SO_access_str)[att_u_key]

		if attention_info then
			local settings = attention_info.handler:get_attention(data.SO_access, nil, nil, data.team)

			if settings then
				local t = TimerManager:game():time()

				att_obj_data = CopLogicBase._create_detected_attention_object_data(t, data.unit, att_u_key, attention_info, settings)
				att_obj_data.identified = true
				att_obj_data.identified_t = t
				att_obj_data.notice_progress = nil
				att_obj_data.prev_notice_chk_t = nil

				if att_obj_data.settings.notice_clbk then
					att_obj_data.settings.notice_clbk(data.unit, true)
				end

				data.detected_attention_objects[att_u_key] = att_obj_data

				data.logic.on_attention_obj_identified(data, att_u_key, att_obj_data)
			end
		end
	end

	return att_obj_data, is_new
end

function CopLogicBase._can_arrest(data)
	if not data.is_converted then
		if not data.objective or not data.objective.no_arrest then
			if not data.char_tweak.no_arrest then --or data.attention_obj and data.attention_obj.criminal_record and data.attention_obj.criminal_record.status == "electrified" then
				return true
			end
		end
	end
end

function CopLogicBase.on_attention_obj_identified(data, attention_u_key, attention_info)
	local identifier_key = data.key

	if data.group then
		for u_key, u_data in pairs_g(data.group.units) do
			if u_key ~= identifier_key and alive(u_data.unit) then
				u_data.unit:brain():clbk_group_member_attention_identified(data.unit, attention_u_key)
			end
		end
	elseif data.is_converted or data.unit:in_slot(16) then
		for u_key, record in pairs_g(managers.groupai:state():all_AI_criminals()) do
			if u_key ~= identifier_key then
				record.unit:brain():clbk_group_member_attention_identified(data.unit, attention_u_key)
			end
		end

		local all_converted_enemies = managers.groupai:state():all_converted_enemies()

		if all_converted_enemies then
			for u_key, unit in pairs_g(all_converted_enemies) do
				if u_key ~= identifier_key then
					unit:brain():clbk_group_member_attention_identified(data.unit, attention_u_key)
				end
			end
		end
	end
end

function CopLogicBase.chk_am_i_aimed_at(data, attention_obj, max_dot)
	if not attention_obj.is_person or not attention_obj.is_alive then
		return
	end

	if attention_obj.dis < 700 and max_dot > 0.3 then
		max_dot = math_lerp(0.3, max_dot, (attention_obj.dis - 50) / 650)
	end

	local enemy_look_dir = tmp_vec1
	local weapon_rot = nil

	if attention_obj.is_husk_player then
		mvec3_set(enemy_look_dir, attention_obj.unit:movement():detect_look_dir())
	else
		if attention_obj.is_local_player then
			m_rot_y(attention_obj.unit:movement():m_head_rot(), enemy_look_dir)
		else
			if attention_obj.unit:inventory() and attention_obj.unit:inventory():equipped_unit() then
				if attention_obj.unit:movement()._stance.values[3] >= 0.6 then
					local weapon_fire_obj = attention_obj.unit:inventory():equipped_unit():get_object(Idstring("fire"))

					if alive(weapon_fire_obj) then
						weapon_rot = weapon_fire_obj:rotation()
					end
				end
			end

			if weapon_rot then
				m_rot_y(weapon_rot, enemy_look_dir)
			else
				m_rot_z(attention_obj.unit:movement():m_head_rot(), enemy_look_dir)
			end
		end

		mvec3_norm(enemy_look_dir)
	end

	local enemy_vec = data.unit:movement():m_com() - attention_obj.m_head_pos
	mvec3_norm(enemy_vec)

	--[[local line = Draw:brush(Color.white:with_alpha(0.2), 0.1)
	local init_pos = weapon_rot and attention_obj.unit:inventory():equipped_unit():get_object(Idstring("fire")):position() or attention_obj.m_head_pos
	line:cylinder(init_pos, init_pos + enemy_look_dir * 500, 0.1)]]

	return max_dot < mvec3_dot(enemy_vec, enemy_look_dir)
end

function CopLogicBase._chk_alert_obstructed(my_listen_pos, alert_data)
	if alert_data[3] then
		if not CopLogicBase._alert_obstruction_slotmask then
			CopLogicBase._alert_obstruction_slotmask = managers.slot:get_mask("AI_visibility")
		end

		local alert_epicenter = nil

		if alert_data[1] == "bullet" then
			alert_epicenter = tmp_vec1

			mvec3_step(alert_epicenter, alert_data[2], alert_data[6], 50)
		else
			alert_epicenter = alert_data[2]
		end

		local ray = World:raycast("ray", my_listen_pos, alert_epicenter, "slot_mask", CopLogicBase._alert_obstruction_slotmask, "ray_type", "ai_vision", "report")

		if ray then
			if alert_data[1] == "footstep" then
				return true
			end

			local my_dis_sq = mvec3_dis(my_listen_pos, alert_epicenter)
			local dampening = alert_data[1] == "bullet" and 0.5 or 0.25
			local effective_dis_sq = alert_data[3] * dampening
			effective_dis_sq = effective_dis_sq * effective_dis_sq

			if my_dis_sq > effective_dis_sq then
				return true
			end
		end
	end
end

function CopLogicBase.do_grenade(data, pos, flash, drop)
	if not managers.groupai:state():is_smoke_grenade_active() or data.unit:base().has_tag and not data.unit:base():has_tag("law") or data.char_tweak.cannot_throw_grenades then --if you're not calling this function from somewhere outside do_smart_grenade, remove this entire check
		return
	end

	local duration = tweak_data.group_ai.smoke_grenade_lifetime

	if flash then
		duration = tweak_data.group_ai.flash_grenade_lifetime

		managers.groupai:state():detonate_smoke_grenade(pos, data.unit:movement():m_head_pos(), duration, flash)
		managers.groupai:state():apply_grenade_cooldown(flash)

		if not drop and data.char_tweak.chatter and data.char_tweak.chatter.flash_grenade then
			data.unit:sound():say("d02", true)	
		end
	else
		managers.groupai:state():detonate_smoke_grenade(pos, data.unit:movement():m_head_pos(), duration, flash)
		managers.groupai:state():apply_grenade_cooldown(flash)

		if not drop and data.char_tweak.chatter and data.char_tweak.chatter.smoke then
			data.unit:sound():say("d01", true)	
		end
	end
	
	if not drop and not data.unit:movement():chk_action_forbidden("action") and not data.char_tweak.no_grenade_anim then
		local redir_name = "throw_grenade"

		if data.unit:movement():play_redirect(redir_name) then
			managers.network:session():send_to_peers_synched("play_distance_interact_redirect", data.unit, redir_name)
		end
	end

	return true
end

function CopLogicBase.do_smart_grenade(data, my_data, focus_enemy)
	if not data.tactics then
		return
	end
	
	local flash = nil
	
	if data.tactics.smoke_grenade or data.tactics.flash_grenade then
		flash = not data.tactics.smoke_grenade or data.tactics.flash_grenade and math_random() < 0.5
	else
		return
	end
	
	local t = data.t
	local enemy_visible = focus_enemy.verified
	local enemy_visible_soft = focus_enemy.verified_t and t - focus_enemy.verified_t < 2
	--local enemy_visible_softer = focus_enemy.verified_t and t - focus_enemy.verified_t < 15
	
	local do_something_else = true
	
	if data.objective then
		local attitude = data.objective.attitude or "avoid"
		local pos_to_use = CopLogicAttack.is_advancing(data)
		
		if pos_to_use then
			if attitude == "avoid" and not flash then
				if focus_enemy.verified and focus_enemy.aimed_at and focus_enemy.dis < 2000 then
					if CopLogicBase.do_grenade(data, pos_to_use + math.UP * 5, flash, nil) then
						--log("reason1")
						do_something_else = nil
					end
				end
			else
				if mvec3_dis(pos_to_use, focus_enemy.m_pos) < 600 then
					if flash then
						if CopLogicBase.do_grenade(data, pos_to_use + math.UP * 10, flash, nil) then
							--log("reason3")
							do_something_else = nil
						end
					else
						if CopLogicBase.do_grenade(data, pos_to_use + math.UP * 5, flash, nil) then
							--log("reason4")
							do_something_else = nil
						end
					end
				end
			end
		end
		
		if not do_something_else then
			return true
		end
		
		if not flash then
			if my_data.firing and focus_enemy.verified then
				if data.is_suppressed or focus_enemy.criminal_record and focus_enemy.criminal_record.assault_t and data.t - focus_enemy.criminal_record.assault_t < 2 then
					if CopLogicBase.do_grenade(data, data.m_pos + math.UP * 5, flash, true) then
						--log("reason5")
						do_something_else = nil
					end
				end
			end
		else
			if focus_enemy.verified and focus_enemy.dis < 2000 then
				if focus_enemy.is_person then
					local area = managers.groupai:state():get_area_from_nav_seg_id(focus_enemy.nav_tracker:nav_segment())
					if CopLogicBase.do_grenade(data, area.pos + math.UP * 10, flash, nil) then
						--log("reason6")
						do_something_else = nil
					end
				end
			end
		end
					
		if not do_something_else then
			return true
		end
	end
	
	if not do_something_else then
		--log("found appropriate grenade throwing thingy!")
		return true
	else
		--log("couldnt find suitable reason")
		return
	end
	
end 


function CopLogicBase.on_long_dis_interacted(data, other_unit, secondary)
end
