local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_dir = mvector3.direction
local mvec3_dot = mvector3.dot
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()

function CopLogicBase.chk_am_i_aimed_at(data, attention_obj, max_dot)
	if not attention_obj.is_person then
		return
	end

	if attention_obj.dis < 700 and max_dot > 0.3 then
		max_dot = math.lerp(0.3, max_dot, (attention_obj.dis - 50) / 650)
	end

	local enemy_look_dir = nil

	if attention_obj.is_husk_player then
		enemy_look_dir = attention_obj.unit:movement():detect_look_dir()
	else
		enemy_look_dir = tmp_vec1

		mrotation.y(attention_obj.unit:movement():m_head_rot(), enemy_look_dir)
	end

	local enemy_vec = tmp_vec2

	mvec3_dir(enemy_vec, attention_obj.m_head_pos, data.unit:movement():m_com())

	return max_dot < mvec3_dot(enemy_vec, enemy_look_dir)
end

function CopLogicBase._evaluate_reason_to_surrender(data, my_data, aggressor_unit)
	local surrender_tweak = data.char_tweak.surrender

	if not surrender_tweak then
		return
	end

	if alive(managers.groupai:state():phalanx_vip()) then
		return
	end
	
	if surrender_tweak.base_chance >= 1 then
		return 0
	end

	local t = data.t

	if data.surrender_window and data.surrender_window.window_expire_t < t then
		data.unit:brain():on_surrender_chance()

		return
	end

	local hold_chance = 1
	local surrender_chk = {
		health = function (health_surrender)
			local health_ratio = data.unit:character_damage():health_ratio()

			if health_ratio < 1 then
				local min_setting, max_setting = nil

				for k, v in pairs(health_surrender) do
					if not min_setting or k < min_setting.k then
						min_setting = {
							k = k,
							v = v
						}
					end

					if not max_setting or max_setting.k < k then
						max_setting = {
							k = k,
							v = v
						}
					end
				end

				if health_ratio < max_setting.k then
					hold_chance = hold_chance * (1 - math.lerp(min_setting.v, max_setting.v, math.max(0, health_ratio - min_setting.k) / (max_setting.k - min_setting.k)))
				end
			end
		end,
		aggressor_dis = function (agg_dis_surrender)
			local agg_dis = mvec3_dis(data.m_pos, aggressor_unit:movement():m_pos())
			local min_setting, max_setting = nil

			for k, v in pairs(agg_dis_surrender) do
				if not min_setting or k < min_setting.k then
					min_setting = {
						k = k,
						v = v
					}
				end

				if not max_setting or max_setting.k < k then
					max_setting = {
						k = k,
						v = v
					}
				end
			end

			if agg_dis < max_setting.k then
				hold_chance = hold_chance * (1 - math.lerp(min_setting.v, max_setting.v, math.max(0, agg_dis - min_setting.k) / (max_setting.k - min_setting.k)))
			end
		end,
		weapon_down = function (weap_down_surrender)
			local anim_data = data.unit:anim_data()

			if anim_data.reload then
				hold_chance = hold_chance * (1 - weap_down_surrender)
			elseif anim_data.hurt then
				hold_chance = hold_chance * (1 - weap_down_surrender)
			elseif data.unit:movement():stance_name() == "ntl" then
				hold_chance = hold_chance * (1 - weap_down_surrender)
			end

			local ammo_max, ammo = data.unit:inventory():equipped_unit():base():ammo_info()

			if ammo == 0 then
				hold_chance = hold_chance * (1 - weap_down_surrender)
			end
		end,
		flanked = function (flanked_surrender)
			local dis = mvec3_dir(tmp_vec1, data.m_pos, aggressor_unit:movement():m_pos())

			if dis > 250 then
				local fwd = data.unit:movement():m_rot():y()
				local fwd_dot = mvec3_dot(fwd, tmp_vec1)

				if fwd_dot < -0.5 then
					hold_chance = hold_chance * (1 - flanked_surrender)
				end
			end
		end,
		unaware_of_aggressor = function (unaware_of_aggressor_surrender)
			local att_info = data.detected_attention_objects[aggressor_unit:key()]

			if not att_info or not att_info.identified or t - att_info.identified_t < 1 then
				hold_chance = hold_chance * (1 - unaware_of_aggressor_surrender)
			end
		end,
		enemy_weap_cold = function (enemy_weap_cold_surrender)
			if not managers.groupai:state():enemy_weapons_hot() then
				hold_chance = hold_chance * (1 - enemy_weap_cold_surrender)
			end
		end,
		isolated = function (isolated_surrender)
			if data.group and data.group.has_spawned and data.group.initial_size > 1 then
				local has_support = nil
				local max_dis_sq = 722500

				for u_key, u_data in pairs(data.group.units) do
					if u_key ~= data.key and mvec3_dis_sq(data.m_pos, u_data.m_pos) < max_dis_sq then
						has_support = true

						break
					end

					if not has_support then
						hold_chance = hold_chance * (1 - isolated_surrender)
					end
				end
			end
		end,
		pants_down = function (pants_down_surrender)
			local not_cool_t = data.unit:movement():not_cool_t()

			if (not not_cool_t or t - not_cool_t < 1.5) and not managers.groupai:state():enemy_weapons_hot() then
				hold_chance = hold_chance * (1 - pants_down_surrender)
			end
		end
	}

	for reason, reason_data in pairs(surrender_tweak.reasons) do
		surrender_chk[reason](reason_data)
	end

	if 1 - (surrender_tweak.significant_chance or 0) <= hold_chance then
		return 1
	end

	for factor, factor_data in pairs(surrender_tweak.factors) do
		surrender_chk[factor](factor_data)
	end

	if data.surrender_window then
		hold_chance = hold_chance * (1 - data.surrender_window.chance_mul)
	end

	if surrender_tweak.violence_timeout then
		local violence_t = data.unit:character_damage():last_suppression_t()

		if violence_t then
			local violence_dt = t - violence_t

			if violence_dt < surrender_tweak.violence_timeout then
				hold_chance = hold_chance + (1 - hold_chance) * (1 - violence_dt / surrender_tweak.violence_timeout)
			end
		end
	end

	return hold_chance < 1 and hold_chance
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
				contact_chatter_time_ok = new_crim_rec and data.t - new_crim_rec.det_t > 8

				new_att_obj.stare_expire_t = nil
				new_att_obj.pause_expire_t = nil
				new_att_obj.settings.pause = nil
			else
				if old_att_obj.criminal_record then
					managers.groupai:state():on_enemy_disengaging(data.unit, old_att_obj.u_key)
				end

				if new_crim_rec then
					managers.groupai:state():on_enemy_engaging(data.unit, new_att_obj.u_key)
				end

				contact_chatter_time_ok = new_crim_rec and data.t - new_crim_rec.det_t > 15
			end
		else
			if new_crim_rec then
				managers.groupai:state():on_enemy_engaging(data.unit, new_att_obj.u_key)
			end

			contact_chatter_time_ok = new_crim_rec and data.t - new_crim_rec.det_t > 15
		end

		if not is_same_obj then
			if new_att_obj.settings.duration then
				new_att_obj.stare_expire_t = data.t + math.lerp(new_att_obj.settings.duration[1], new_att_obj.settings.duration[2], math.random())
				new_att_obj.pause_expire_t = nil
			end

			new_att_obj.acquire_t = data.t
		end

		if AIAttentionObject.REACT_SHOOT <= new_reaction and new_att_obj.verified and contact_chatter_time_ok and (data.unit:anim_data().idle or data.unit:anim_data().move) and new_att_obj.is_person and data.char_tweak.chatter.contact then
			if data.unit:base()._tweak_table == "phalanx_vip" then
				data.unit:sound():say("a01", true)				
			elseif data.char_tweak.speech_prefix_p1 == "l5d" then
				data.unit:sound():say("i01", true)						
			elseif data.unit:base()._tweak_table == "gensec" then
				data.unit:sound():say("a01", true)			
			elseif data.unit:base()._tweak_table == "security" then
				data.unit:sound():say("a01", true)			
			else
				data.unit:sound():say("c01", true)
			end
		end
	elseif old_att_obj and old_att_obj.criminal_record then
		managers.groupai:state():on_enemy_disengaging(data.unit, old_att_obj.u_key)
	end
end

function CopLogicBase.should_duck_on_alert(data, alert_data)
	--this sucks.
	
	--if data.char_tweak.allowed_poses and not data.char_tweak.allowed_poses.crouch or alert_data[1] == "voice" or data.unit:anim_data().crouch or data.unit:movement():chk_action_forbidden("walk") then
		--return
	--end

	--local lower_body_action = data.unit:movement()._active_actions[2]

	--if lower_body_action and lower_body_action:type() == "walk" and not data.char_tweak.crouch_move then
		--return
	--end
	
	return
end

function CopLogicBase._chk_nearly_visible_chk_needed(data, attention_info, u_key)
	return not attention_info.criminal_record or attention_info.is_human_player
end

function CopLogicBase._update_haste(data, my_data)
	if my_data ~= data.internal_data then
		log("how is this man")
		return
	end
	
	if data.unit:movement():chk_action_forbidden("walk") or my_data.tasing or my_data.spooc_attack then
		return
	end
	
	local path = my_data.chase_path or my_data.charge_path or my_data.advance_path or my_data.cover_path or my_data.expected_pos_path or my_data.hunt_path or my_data.flank_path
	
	if not path then
		return
	end
	
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	local can_perform_walking_action = not my_data.turning and not data.unit:movement():chk_action_forbidden("walk") and not my_data.has_old_action
	local pose = nil
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
	
	-- I'm gonna leave a note to myself here so that I never commit the same mistake ever again.
	-- AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction
	-- THIS IS HOW YOU CHECK FOR COMBAT REACTIONS, YOU DEHYDRATED RAISIN OF A PERSON, FUGLORE
	-- I SWEAR TO FUCKING GOD I WILL SLAUGHTER YOU IF YOU MAKE THE SAME MISTAKE AGAIN
	-- - Past Fuglore, thembo extraordinaire and apparently, no longer an idiot.
	
	if path and can_perform_walking_action and data.attention_obj then
		local haste = nil
		
		if is_mook and not data.is_converted and not data.unit:in_slot(16) then
			local enemyseeninlast4secs = data.attention_obj and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4
			local enemy_seen_range_bonus = enemyseeninlast4secs and 500 or 0
			local enemy_has_height_difference = data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis >= 1200 and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4 and math.abs(data.m_pos.z - data.attention_obj.m_pos.z) > 250
			local height_difference_penalty = enemy_has_height_difference and 400 or 0
			local can_crouch = not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch
			local can_stand = not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.stand
			
			
			local should_crouch = nil
			local pose = nil
			local end_pose = nil
			if data.unit:movement():cool() and data.unit:movement()._active_actions[2] and data.unit:movement()._active_actions[2]:type() == "walk" and data.unit:movement()._active_actions[2]:haste() == "run" then
				haste = "walk"
			elseif data.attention_obj and data.attention_obj.dis > 10000 and data.unit:movement()._active_actions[2] and data.unit:movement()._active_actions[2]:type() == "walk" and data.unit:movement()._active_actions[2]:haste() ~= "run" then
				haste = "run"
			elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis > 1200 + enemy_seen_range_bonus and not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() and data.unit:movement()._active_actions[2] and data.unit:movement()._active_actions[2]:type() == "walk" and data.unit:movement()._active_actions[2]:haste() ~= "run" and is_mook then
				haste = "run"
				my_data.has_reset_walk_cycle = nil
			elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis <= 1200 + enemy_seen_range_bonus - height_difference_penalty and is_mook and data.tactics and not data.tactics.hitnrun and data.unit:movement()._active_actions[2] and data.unit:movement()._active_actions[2]:type() == "walk" and data.unit:movement()._active_actions[2]:haste() == "run" then
				haste = "walk"
				my_data.has_reset_walk_cycle = nil
			 else
				if data.unit:movement()._active_actions[2] and data.unit:movement()._active_actions[2]:type() == "walk" and data.unit:movement()._active_actions[2]:haste() ~= "run" then
					my_data.has_reset_walk_cycle = nil
					haste = "run"
				else
					--log("current haste is fine!")
					return
				end
			 end
				 
			local crouch_roll = math.random(0.01, 1)
			local stand_chance = nil
			
			local verified_chk = data.attention_obj.verified and data.attention_obj.dis <= 1500 or data.attention_obj.dis <= 1000
			
			if data.attention_obj and data.attention_obj.dis > 10000 then
				stand_chance = 1
				pose = "stand"
				end_pose = "stand"
			elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis > 2000 then
				stand_chance = 0.75
			elseif enemy_has_height_difference and can_crouch then
				stand_chance = 0.25
			elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and verified_chk and CopLogicTravel._chk_close_to_criminal(data, my_data) and data.tactics and data.tactics.flank and haste == "walk" then
				stand_chance = 0.25
			elseif my_data.moving_to_cover and can_crouch then
				stand_chance = 0.5
			else
				stand_chance = 1
				pose = "stand"
				end_pose = "stand"
			end
			
			--randomize enemy crouching to make enemies feel less easy to aim at, the fact they're always crouching all over the place always bugged me, plus, they shouldn't need to crouch so often when you're at long distances from them
			
			if not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() then
				if stand_chance ~= 1 and crouch_roll > stand_chance and can_crouch then
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
		end
	end	
	 
	if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and haste and can_perform_walking_action then
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
			
			if my_data.advancing then
				my_data.advancing = data.unit:brain():action_request(new_action_data)
				my_data.moving_to_cover = my_data.best_cover
				my_data.at_cover_shoot_pos = nil
				my_data.in_cover = nil

				data.brain:rem_pos_rsrv("path")
			end
		end
	end
end 

function CopLogicBase._upd_stance_and_pose(data, my_data, objective)
	if my_data ~= data.internal_data then
		log("how is this man")
		return
	end
	
	if data.unit:movement():chk_action_forbidden("walk") or my_data.tasing or my_data.spooc_attack then
		return
	end
	
	
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)

	local obj_has_stance, obj_has_pose, agg_pose = nil
	local should_crouch = not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch
	local should_stand = not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.stand
	
	if not data.is_converted then
		if data.is_suppressed then
			if diff_index <= 5 and not Global.game_settings.use_intense_AI then
				if not data.unit:anim_data().crouch and should_crouch then
					if not my_data.next_allowed_crouch_t or my_data.next_allowed_crouch_t < data.t then
						CopLogicAttack._chk_request_action_crouch(data)
						my_data.next_allowed_crouch_t = data.t + math.random(2, 6)
					end
				end
			else
				if not data.unit:anim_data().crouch and should_crouch then
					if not my_data.next_allowed_crouch_t or my_data.next_allowed_crouch_t < data.t then
						CopLogicAttack._chk_request_action_crouch(data)
						my_data.next_allowed_crouch_t = data.t + math.random(2, 6)
					end
				elseif data.unit:anim_data().crouch and should_stand then
					if not my_data.next_allowed_stand_t or my_data.next_allowed_stand_t < data.t then
						CopLogicAttack._chk_request_action_stand(data)
						my_data.next_allowed_stand_t = data.t + math.random(2, 6)
					end
				end
			end
		elseif data.attention_obj and data.attention_obj.is_person and data.attention_obj.verified and data.attention_obj.aimed_at and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction then
			if diff_index <= 5 and not Global.game_settings.use_intense_AI then
				--nothing
			else
				if not data.unit:anim_data().crouch and should_crouch then
					if not my_data.next_allowed_crouch_t or my_data.next_allowed_crouch_t < data.t then
						CopLogicAttack._chk_request_action_crouch(data)
						my_data.next_allowed_crouch_t = data.t + math.random(2, 6)
					end
				elseif data.unit:anim_data().crouch and should_stand then
					if not my_data.next_allowed_stand_t or my_data.next_allowed_stand_t < data.t then
						CopLogicAttack._chk_request_action_stand(data)
						my_data.next_allowed_stand_t = data.t + math.random(2, 6)
					end
				end
			end
		end
	end
	
	if objective and not agg_pose then
		local objective_pose_shit = not data.char_tweak.allowed_stances or objective and objective.stance and data.char_tweak.allowed_stances[objective.stance]
		
		if objective.stance and objective_pose_shit then
			obj_has_stance = true
			local upper_body_action = data.unit:movement()._active_actions[3]

			if not upper_body_action or upper_body_action:type() ~= "shoot" then
				data.unit:movement():set_stance(objective.stance)
			end
		end

		if objective.pose and not agg_pose and objective_pose_shit then
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

function CopLogicBase.chk_start_action_dodge(data, reason)

	if not data.char_tweak.dodge or not data.char_tweak.dodge.occasions[reason] then
		return
	end

	if data.dodge_timeout_t and data.t < data.dodge_timeout_t or data.dodge_chk_timeout_t and data.t < data.dodge_chk_timeout_t or data.unit:movement():chk_action_forbidden("walk") then
		return
	end
	local dodge_tweak = data.char_tweak.dodge.occasions[reason]
	
	data.dodge_chk_timeout_t = TimerManager:game():time() + math.lerp(dodge_tweak.check_timeout[1], dodge_tweak.check_timeout[2], math.random())
	if dodge_tweak.chance == 0 or dodge_tweak.chance < math.random() then
		return
	end
	
	local rand_nr = math.random()
	local total_chance = 0
	local variation, variation_data = nil
	for test_variation, test_variation_data in pairs(dodge_tweak.variations) do
		total_chance = total_chance + test_variation_data.chance
		if test_variation_data.chance > 0 and rand_nr <= total_chance then
			variation = test_variation
			variation_data = test_variation_data
			break
		end
	end

	local dodge_dir = Vector3()
	local face_attention = nil
	
	if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction then
		mvec3_set(dodge_dir, data.attention_obj.m_pos)
		mvec3_sub(dodge_dir, data.m_pos)
		mvector3.set_z(dodge_dir, 0)
		mvector3.normalize(dodge_dir)
		if mvector3.dot(data.unit:movement():m_fwd(), dodge_dir) < 0 then
			return
		end
		mvector3.cross(dodge_dir, dodge_dir, math.UP)
		face_attention = true
	else
		mvector3.random_orthogonal(dodge_dir, math.UP)
	end
	
	local dodge_dir_reversed = false
	
	if math.random() < 0.5 then
		mvector3.negate(dodge_dir)
		dodge_dir_reversed = not dodge_dir_reversed
	end
	
	local prefered_space = 200
	local min_space = 130
	local ray_to_pos = tmp_vec1
	mvec3_set(ray_to_pos, dodge_dir)
	mvector3.multiply(ray_to_pos, 200)
	mvector3.add(ray_to_pos, data.m_pos)
	
	local ray_params = {
		trace = true,
		tracker_from = data.unit:movement():nav_tracker(),
		pos_to = ray_to_pos
	}
	
	local ray_hit1 = managers.navigation:raycast(ray_params)
	local dis = nil
	
	if ray_hit1 then
		local hit_vec = tmp_vec2
		mvec3_set(hit_vec, ray_params.trace[1])
		mvec3_sub(hit_vec, data.m_pos)
		mvec3_set_z(hit_vec, 0)
		dis = mvector3.length(hit_vec)
		mvec3_set(ray_to_pos, dodge_dir)
		mvector3.multiply(ray_to_pos, -200)
		mvector3.add(ray_to_pos, data.m_pos)
		ray_params.pos_to = ray_to_pos
		local ray_hit2 = managers.navigation:raycast(ray_params)
		if ray_hit2 then
			mvec3_set(hit_vec, ray_params.trace[1])
			mvec3_sub(hit_vec, data.m_pos)
			mvec3_set_z(hit_vec, 0)
			local prev_dis = dis
			dis = mvector3.length(hit_vec)
			if prev_dis < dis and min_space < dis then
				mvector3.negate(dodge_dir)
				dodge_dir_reversed = not dodge_dir_reversed
			end
		else
			mvector3.negate(dodge_dir)
			dis = nil
			dodge_dir_reversed = not dodge_dir_reversed
		end
	end
	
	if ray_hit1 and dis and dis < min_space then
		return
	end
	
	local dodge_side
	local fwd_dot = mvec3_dot(dodge_dir, data.unit:movement():m_fwd())
	local my_right = tmp_vec1
	mrotation.x(data.unit:movement():m_rot(), my_right)
	local right_dot = mvec3_dot(dodge_dir, my_right)
	dodge_side = math.abs(fwd_dot) > 0.7071067690849 and (fwd_dot > 0 and "fwd" or "bwd") or right_dot > 0 and "r" or "l"
	local body_part = 1
	local shoot_chance = variation_data.shoot_chance
	if shoot_chance and shoot_chance > 0 and math.random() < shoot_chance then
		body_part = 2
	end

	local action_data = {
		type = "dodge",
		body_part = body_part,
		variation = variation,
		side = dodge_side,
		direction = dodge_dir,
		timeout = variation_data.timeout,
		speed = data.char_tweak.dodge.speed,
		shoot_accuracy = variation_data.shoot_accuracy,
		blocks = {
			act = -1,
			tase = -1,
			bleedout = -1,
			dodge = -1,
			walk = -1,
			action = body_part == 1 and -1 or nil,
			aim = body_part == 1 and -1 or nil
		}
	}
	if variation ~= "side_step" then -- they can play hurts while side-stepping
		action_data.blocks.hurt = -1
		action_data.blocks.heavy_hurt = -1
	end
	local action = data.unit:movement():action_request(action_data)
	if action then
		local my_data = data.internal_data
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
		CopLogicAttack._cancel_expected_pos_path(data, my_data)
		CopLogicAttack._cancel_walking_to_cover(data, my_data, true)
	end
	return action
end

function CopLogicBase.chk_am_i_aimed_at(data, attention_obj, max_dot)
	if not attention_obj.is_person then
		return
	end

	if attention_obj.dis < 700 and max_dot > 0.3 then
		max_dot = math.lerp(0.3, max_dot, (attention_obj.dis - 50) / 650)
	end

	local enemy_look_dir = nil

	if attention_obj.is_husk_player then
		enemy_look_dir = attention_obj.unit:movement():detect_look_dir()
	else
		enemy_look_dir = tmp_vec1

		mrotation.y(attention_obj.unit:movement():m_head_rot(), enemy_look_dir)
	end

	local enemy_vec = tmp_vec2

	mvec3_dir(enemy_vec, attention_obj.m_head_pos, data.unit:movement():m_com())

	return max_dot < mvec3_dot(enemy_vec, enemy_look_dir)
end

function CopLogicBase.action_taken(data, my_data)
	return my_data.turning or my_data.moving_to_cover or my_data.walking_to_cover_shoot_pos or my_data.surprised or my_data.has_old_action or data.unit:movement():chk_action_forbidden("walk") or my_data.charge_path or my_data.cover_path or my_data.firing
end
	
function CopLogicBase.chk_should_turn(data, my_data)
	return not my_data.turning and not my_data.has_old_action and not data.unit:movement():chk_action_forbidden("walk") and not my_data.moving_to_cover and not my_data.walking_to_cover_shoot_pos and not my_data.surprised
end

function CopLogicBase.on_new_logic_needed(data, objective)
	
	local my_data = data.internal_data
	local focus_enemy = data.attention_obj
	local t = data.t
	
	if not my_data.next_unstuck_try_t or my_data.next_unstuck_try_t < t then
		if objective then
			local objective_type = objective.type
			local should_enter_travel = objective.nav_seg or objective.type == "follow"
			
			if objective_type == "free" and my_data.exiting then
				--nothing
			elseif should_enter_travel and CopLogicBase.should_enter_travel(data, objective) then
				CopLogicBase._exit(data.unit, "travel")
				my_data.next_allowed_attack_logic_t = t + 0.16666
				--log("looping unit hopefully fixed!")
			elseif objective_type == "guard" then
				CopLogicBase._exit(data.unit, "guard")
				my_data.next_allowed_attack_logic_t = t + 0.16666
			elseif objective_type == "security" then
				CopLogicBase._exit(data.unit, "idle")
				my_data.next_allowed_attack_logic_t = t + 0.16666
			elseif objective_type == "sniper" then
				CopLogicBase._exit(data.unit, "sniper")
				my_data.next_allowed_attack_logic_t = t + 0.16666
			elseif objective_type == "phalanx" then
				CopLogicBase._exit(data.unit, "phalanx")
				my_data.next_allowed_attack_logic_t = t + 0.16666
			elseif objective_type == "surrender" then
				CopLogicBase._exit(data.unit, "intimidated", objective.params)
			elseif objective.action or not data.attention_obj then
				CopLogicBase._exit(data.unit, "idle")
				my_data.next_allowed_attack_logic_t = t + 0.16666
				--log("looping unit hopefully fixed!")
			else
				--log("attack is still fine!")
				my_data.anti_stuck_t = nil
				my_data.next_unstuck_try_t = data.t + 10
				CopLogicBase._exit(data.unit, "attack")
			end
		end
	end
end

function CopLogicBase.should_enter_travel(data, objective)
	
	if not objective.nav_seg and objective.type ~= "follow" then
		return
	end

	if objective.in_place then
		return
	end

	if objective.pos then
		return true
	end

	if objective.area and objective.area.nav_segs[data.unit:movement():nav_tracker():nav_segment()] then
		objective.in_place = true

		return
	end

	return true
end	

function CopLogicBase.should_enter_attack(data)
	local reactions_chk = data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction or data.attention_obj and AIAttentionObject.REACT_SPECIAL_ATTACK <= data.attention_obj.reaction
	local my_data = data.internal_data
	local t = data.t
	
	if data.unit:base()._tweak_table == "sniper" then
		return
	end
	
	if data.name ~= "attack" and my_data.next_allowed_attack_logic_t and my_data.next_allowed_attack_logic_t > t then
		--log("cannot enter attack logic yet!")
		return
	else
		my_data.next_allowed_attack_logic_t = nil
	end
	
	if not my_data.next_unstuck_try_t or my_data.next_unstuck_try_t < t then
		if data.name == "attack" and data.objective and not CopLogicBase.action_taken(data, my_data) then
			if not my_data.anti_stuck_t then
				my_data.anti_stuck_t = t + 5
			elseif my_data.anti_stuck_t < t then
				--log("attempting to fix looping unit")
				local objective = data.objective
				
				if objective then
					CopLogicBase.on_new_logic_needed(data, objective)
				end
				
				my_data.anti_stuck_t = nil
				return
			end
		else
			my_data.anti_stuck_t = nil
		end
	end
	
	if not data.is_converted and not data.unit:in_slot(16) and not data.unit:in_slot(managers.slot:get_mask("criminals")) and data.unit:base():has_tag("law") and reactions_chk and data.internal_data.attitude and data.internal_data.attitude == "engage" or not data.is_converted and not data.unit:in_slot(16) and not data.unit:in_slot(managers.slot:get_mask("criminals")) and data.unit:base():has_tag("law") and reactions_chk and my_data.firing then
		local att_obj = data.attention_obj
		local criminal_in_my_area = nil
		local criminal_in_neighbour = nil
		local ranged_fire_group = nil
		local my_area = managers.groupai:state():get_area_from_nav_seg_id(data.unit:movement():nav_tracker():nav_segment())

		if next(my_area.criminal.units) then
			criminal_in_my_area = true
		else
			for _, nbr in pairs(my_area.neighbours) do
				if next(nbr.criminal.units) then
					criminal_in_neighbour = true

					break
				end
			end
		end
		
		local attack_distance = 1000
		
		if data.tactics and data.tactics.ranged_fire or data.tactics and data.tactics.elite_ranged_fire then
			attack_distance = 1500
			ranged_fire_group = true
		end
		
		local criminal_near = criminal_in_my_area or criminal_in_neighbour
		
		local travel_data_chk = my_data.processing_advance_path or my_data.processing_coarse_path or my_data.advance_path or my_data.coarse_path
		
		if travel_data_chk and not criminal_near then
			return
		end
		
		local visibility_chk = att_obj.verified
		
		if my_data.processing_cover_path and my_data.want_to_take_cover and att_obj.dis <= 2000 or my_data.cover_path and my_data.want_to_take_cover and att_obj.dis <= 2000 or my_data.cover_test_step and my_data.cover_test_step <= 2 and visibility_chk and att_obj.dis <= 2000 then
			return true
		end
		
		
		
		if my_data.charge_path or data.internal_data and data.internal_data.tasing or data.internal_data and data.internal_data.spooc_attack or AIAttentionObject.REACT_SPECIAL_ATTACK <= data.attention_obj.reaction or visibility_chk and att_obj.dis <= attack_distance and math.abs(data.m_pos.z - att_obj.m_pos.z) < 100 or visibility_chk and criminal_near and math.abs(data.m_pos.z - att_obj.m_pos.z) < 400 then
			return true
		end
		
		return
	end
	
	return
end

function CopLogicBase.queue_task(internal_data, id, func, data, exec_t, asap)
	if internal_data.unit and internal_data ~= internal_data.unit:brain()._logic_data.internal_data then
		log("how is this man")
		--debug_pause("[CopLogicBase.queue_task] Task queued from the wrong logic", internal_data.unit, id, func, data, exec_t, asap)
	end
	
	if asap then
		asap = nil
	end

	local qd_tasks = internal_data.queued_tasks

	if qd_tasks then
		if qd_tasks[id] then
			log("queued something twice!!!")
			--debug_pause("[CopLogicBase.queue_task] Task queued twice", internal_data.unit, id, func, data, exec_t, asap)
		end

		qd_tasks[id] = true
	else
		internal_data.queued_tasks = {
			[id] = true
		}
	end
	
	if data.unit:base():has_tag("special") or data.unit:base():has_tag("takedown") or data.internal_data.shooting or data.attention_obj and data.t and data.attention_obj.is_human_player and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis <= 3000 and data.attention_obj.verified_t and data.attention_obj.verified_t - data.t <= 2 or data.attention_obj and data.attention_obj.is_human_player and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis <= 1500 or data.is_converted or data.unit:in_slot(16) or data.internal_data and data.internal_data.next_allowed_attack_logic_t then
		asap = true
		if data.is_converted or data.unit:in_slot(16) or data.internal_data.next_allowed_attack_logic_t then
			exec_t = data.t
		elseif data.attention_obj and data.attention_obj.dis <= 1500 and data.t and data.attention_obj.verified_t and data.attention_obj.verified_t - data.t <= 2 then
			exec_t = data.t + 0.06444
		else
			exec_t = data.t + 0.16666
		end
	elseif data.t and data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction then
		asap = nil
		if data.attention_obj.dis <= 4000 then
			exec_t = data.t + 0.5
		else
			exec_t = data.t + 1
		end
	end
	
	
	managers.enemy:queue_task(id, func, data, exec_t, callback(CopLogicBase, CopLogicBase, "on_queued_task", internal_data), asap)
end
