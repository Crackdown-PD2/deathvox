--Most values except the radiuses here aren't changed, however I felt the need to include comments on what they do because you guys may want to change them.
--I know I certainly fucking did for when I'm playing this game alone.

local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_dir = mvector3.direction
local mvec3_dot = mvector3.dot
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_lerp = mvector3.lerp
local mvec3_norm = mvector3.normalize
local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
local temp_vec3 = Vector3()

function CopLogicAttack._update_cover(data)
	local my_data = data.internal_data
	local cover_release_dis_sq = 10000
	local best_cover = my_data.best_cover
	local satisfied = true
	local my_pos = data.m_pos

	if data.attention_obj and data.attention_obj.nav_tracker and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction then
		local find_new = not my_data.moving_to_cover and not my_data.walking_to_cover_shoot_pos and not my_data.surprised
		local enemyseeninlast5secs = data.attention_obj and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 5	
		
		if find_new then
			local enemy_tracker = data.attention_obj.nav_tracker
			local threat_pos = enemy_tracker:field_position()

			if data.objective and data.objective.type == "follow" then
				local near_pos = data.objective.follow_unit:movement():m_pos()

				if (not best_cover or not CopLogicAttack._verify_follow_cover(best_cover[1], near_pos, threat_pos, 200, 1000)) and not my_data.processing_cover_path and not my_data.charge_path_search_id then
					local follow_unit_area = managers.groupai:state():get_area_from_nav_seg_id(data.objective.follow_unit:movement():nav_tracker():nav_segment())
					local found_cover = managers.navigation:find_cover_in_nav_seg_3(follow_unit_area.nav_segs, data.objective.distance and data.objective.distance * 0.9 or nil, near_pos, threat_pos)

					if found_cover then
						if not follow_unit_area.nav_segs[found_cover[3]:nav_segment()] then
							debug_pause_unit(data.unit, "cover in wrong area")
						end

						satisfied = true
						local better_cover = {
							found_cover
						}

						CopLogicAttack._set_best_cover(data, my_data, better_cover)

						local offset_pos, yaw = CopLogicAttack._get_cover_offset_pos(data, better_cover, threat_pos)

						if offset_pos then
							better_cover[5] = offset_pos
							better_cover[6] = yaw
						end
					end
				end
			else
				local want_to_take_cover = my_data.want_to_take_cover
				local flank_cover = my_data.flank_cover
				local min_dis, max_dis = nil

				if want_to_take_cover or my_data.shooting then
					if data.tactics and not data.tactics.ranged_fire and not data.tactics.elite_ranged_fire or not enemyseeninlast5secs then
						min_dis = 250
					else
						min_dis = math.max(data.attention_obj.dis * 0.9, data.attention_obj.dis - 200)
					end
				end

				if not my_data.processing_cover_path and not my_data.charge_path_search_id and (not best_cover or flank_cover or not CopLogicAttack._verify_cover(best_cover[1], threat_pos, min_dis, max_dis)) then
					satisfied = false
					local my_vec = my_pos - threat_pos

					if flank_cover then
						mvector3.rotate_with(my_vec, Rotation(flank_cover.angle))
					end

					local optimal_dis = my_vec:length()
					local max_dis = nil

					if want_to_take_cover or my_data.shooting then
						if data.tactics and (data.tactics.ranged_fire or data.tactics.elite_ranged_fire) then
							if not enemyseeninlast2secs then
								optimal_dis = min_dis
							elseif optimal_dis < my_data.weapon_range.optimal then
								optimal_dis = optimal_dis

								mvector3.set_length(my_vec, optimal_dis)
							else
								optimal_dis = my_data.weapon_range.optimal

								mvector3.set_length(my_vec, optimal_dis)
							end
						else
							if not enemyseeninlast2secs then
								optimal_dis = min_dis
							elseif optimal_dis < my_data.weapon_range.close then
								optimal_dis = optimal_dis

								mvector3.set_length(my_vec, optimal_dis)
							else
								optimal_dis = my_data.weapon_range.close

								mvector3.set_length(my_vec, optimal_dis)
							end
						end
						
						if data.tactics and not data.tactics.ranged_fire and not data.tactics.elite_ranged_fire then
							max_dis = math.max(optimal_dis + 200, my_data.weapon_range.far * 0.5)
						else							
							max_dis = math.max(optimal_dis + 200, my_data.weapon_range.far)
						end
						
					elseif data.tactics and not data.tactics.ranged_fire and not data.tactics.elite_ranged_fire and optimal_dis > my_data.weapon_range.close then
						optimal_dis = my_data.weapon_range.close

						mvector3.set_length(my_vec, optimal_dis)

						max_dis = my_data.weapon_range.optimal
					elseif optimal_dis > my_data.weapon_range.optimal then
						optimal_dis = my_data.weapon_range.optimal

						mvector3.set_length(my_vec, optimal_dis)

						max_dis = my_data.weapon_range.far
					end

					local my_side_pos = threat_pos + my_vec

					mvector3.set_length(my_vec, max_dis)

					local furthest_side_pos = threat_pos + my_vec

					if flank_cover then
						local angle = flank_cover.angle
						local sign = flank_cover.sign

						if math.sign(angle) ~= sign then
							angle = -angle + flank_cover.step * sign

							if math.abs(angle) > 90 then
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
						cone_angle = math.lerp(90, 60, math.min(1, optimal_dis / 3000))
					end

					local search_nav_seg = nil

					if data.objective and data.objective.type == "defend_area" then
						search_nav_seg = data.objective.area and data.objective.area.nav_segs or data.objective.nav_seg
					end

					local found_cover = managers.navigation:find_cover_in_cone_from_threat_pos_1(threat_pos, furthest_side_pos, my_side_pos, nil, cone_angle, min_threat_dis, search_nav_seg, nil, data.pos_rsrv_id)

					if found_cover and (not best_cover or CopLogicAttack._verify_cover(found_cover, threat_pos, min_dis, max_dis)) then
						satisfied = true
						local better_cover = {
							found_cover
						}

						CopLogicAttack._set_best_cover(data, my_data, better_cover)

						local offset_pos, yaw = CopLogicAttack._get_cover_offset_pos(data, better_cover, threat_pos)

						if offset_pos then
							better_cover[5] = offset_pos
							better_cover[6] = yaw
						end
					end
				end
			end
		end

		local in_cover = my_data.in_cover

		if in_cover then
			local threat_pos = data.attention_obj.verified_pos
			in_cover[3], in_cover[4] = CopLogicAttack._chk_covered(data, my_pos, threat_pos, data.visibility_slotmask)
		end
	elseif best_cover and cover_release_dis_sq < mvector3.distance_sq(best_cover[1][1], my_pos) then
		CopLogicAttack._set_best_cover(data, my_data, nil)
	end
end

function CopLogicAttack._upd_combat_movement(data)
	local my_data = data.internal_data
	local t = data.t
	local unit = data.unit
	local focus_enemy = data.attention_obj
	local in_cover = my_data.in_cover
	local best_cover = my_data.best_cover
	local enemy_visible = focus_enemy.verified
	local enemy_visible_soft = focus_enemy and focus_enemy.verified
	local antipassivecheck = focus_enemy and focus_enemy.verified and focus_enemy.verified_t > math.random(1.05, 1.4)
	
	if data.tactics and data.tactics.ranged_fire or data.tactics and data.tactics.elite_ranged_fire then
		antipassivecheck = focus_enemy and focus_enemy.verified and focus_enemy.verified_t > math.random(2.1, 3.8)
		enemy_visible_soft = focus_enemy and focus_enemy.verified and focus_enemy.verified_t > math.random(2.1, 3.8)
	end
	
	local enemy_visible_softer = focus_enemy and focus_enemy.verified_t and t - focus_enemy.verified_t < 4
	local enemy_visible_mild_soft = focus_enemy and focus_enemy.verified_t and t - focus_enemy.verified_t < 2
	local flank_cover_charge_time = focus_enemy and focus_enemy.verified_t and t - focus_enemy.verified_t < 4 or focus_enemy.verified
	local alert_soft = data.is_suppressed
	local action_taken = data.logic.action_taken(data, my_data)
	local want_to_take_cover = my_data.want_to_take_cover
	action_taken = action_taken or CopLogicAttack._upd_pose(data, my_data)
	local cover_test_step_chk = action_taken or want_to_take_cover or not in_cover --optimizations, yay
	
	if data.tactics and (data.tactics.hitnrun or data.tactics.murder) or data.unit:base():has_tag("takedown") or focus_enemy.dis > 10000 then
		if my_data.cover_test_step ~= 1 and cover_test_step_chk then
			my_data.cover_test_step = 1
			--not many tactics need to be this aggressive, but hitnrun and murder are specifically for units which will want to get up to enemies' faces, and as such, require these, we can also tag specific enemies with "takedown" in charactertweakdata to invoke this without the use of tactics, there is also a specific check here for situations where enemies arent even close enough to the players for their approach to matter
		end
	else
		if my_data.cover_test_step ~= 1 and not enemy_visible_softer and cover_test_step_chk then
			my_data.cover_test_step = 1
		end
	end
	
	local stay_out_time_chk = enemy_visible_soft or antipassivecheck or not my_data.at_cover_shoot_pos or action_taken or want_to_take_cover

	if my_data.stay_out_time and stay_out_time_chk then
		my_data.stay_out_time = nil
	elseif my_data.attitude == "engage" and not my_data.stay_out_time and not antipassivecheck and not enemy_visible_soft and my_data.at_cover_shoot_pos and not action_taken and not want_to_take_cover then
		if data.tactics and data.tactics.ranged_fire or data.tactics and data.tactics.elite_ranged_fire then
			my_data.stay_out_time = t + 5
		else
			my_data.stay_out_time = t + 2
		end
	end
	
	--hitnrun: approach enemies, back away once the enemy is visible, creating a variating degree of aggressiveness
	--eliterangedfire: open fire at enemies from longer distances, back away if the enemy gets too close for comfort
	--spoocavoidance: attempt to approach enemies, if aimed at/seen, retreat away into cover and disengage until ready to try again
	local hitnrunmovementqualify = data.tactics and data.tactics.hitnrun and focus_enemy and focus_enemy.verified and focus_enemy.verified_dis <= 1000 and math.abs(data.m_pos.z - data.attention_obj.m_pos.z) < 200
	local spoocavoidancemovementqualify = data.tactics and data.tactics.spoocavoidance and focus_enemy and focus_enemy.verified and focus_enemy.verified_dis <= 2000 and focus_enemy.aimed_at
	local eliterangedfiremovementqualify = data.tactics and data.tactics.elite_ranged_fire and focus_enemy and focus_enemy.verified and focus_enemy.verified_dis <= 1500
	
	if not action_taken and hitnrunmovementqualify or not action_taken and eliterangedfiremovementqualify or not action_taken and spoocavoidancemovementqualify or not action_taken and reloadingretreatmovementqualify then
		action_taken = CopLogicAttack._chk_start_action_move_back(data, my_data, focus_enemy, false)
	end
	
	if not my_data.turning and not data.unit:movement():chk_action_forbidden("walk") and CopLogicAttack._can_move(data) and data.attention_obj.verified and (not in_cover or not in_cover[4]) then
		if data.is_suppressed and data.t - data.unit:character_damage():last_suppression_t() < 0.7 then
			action_taken = CopLogicBase.chk_start_action_dodge(data, "scared")
		end

		if not action_taken and focus_enemy.is_person and focus_enemy.dis < 3000 then
			local dodge = nil

			if focus_enemy.is_local_player then
				local e_movement_state = focus_enemy.unit:movement():current_state()

				if not e_movement_state:_is_reloading() and not e_movement_state:_interacting() and not e_movement_state:is_equipping() then
					dodge = true
				end
			else
				local e_anim_data = focus_enemy.unit:anim_data()

				if (e_anim_data.move or e_anim_data.idle) and not e_anim_data.reload then
					dodge = true
				end
			end

			if dodge and focus_enemy.aimed_at then
				action_taken = CopLogicBase.chk_start_action_dodge(data, "preemptive")
			end
		end
	end
	
	if action_taken or my_data.stay_out_time and my_data.stay_out_time > t then
		-- Nothing
	elseif want_to_take_cover then
		if data.tactics and data.tactics.flank then
			want_flank_cover = true
		end
		move_to_cover = true
	elseif not enemy_visible_soft or antipassivecheck then
		if data.tactics and data.tactics.charge and data.objective and data.objective.grp_objective and data.objective.grp_objective.charge and (not my_data.charge_path_failed_t or data.t - my_data.charge_path_failed_t > 6) or data.tactics and data.tactics.flank and my_data.flank_cover and in_cover and focus_enemy and focus_enemy.dis <= 2500 and my_data.taken_flank_cover and (not my_data.charge_path_failed_t or data.t - my_data.charge_path_failed_t > 4) then
			if my_data.charge_path then
				local path = my_data.charge_path
				my_data.charge_path = nil
				action_taken = CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path)
			elseif not my_data.charge_path_search_id and data.attention_obj.nav_tracker then
				my_data.charge_pos = CopLogicTravel._get_pos_on_wall(data.attention_obj.nav_tracker:field_position(), my_data.weapon_range.close, 45, nil)

				if my_data.charge_pos then
					my_data.charge_path_search_id = "charge" .. tostring(data.key)

					unit:brain():search_for_path(my_data.charge_path_search_id, my_data.charge_pos, nil, nil, nil)
				else
					debug_pause_unit(data.unit, "failed to find charge_pos", data.unit)

					my_data.charge_path_failed_t = TimerManager:game():time()
				end
			end
		elseif in_cover then
			if my_data.cover_test_step <= 2 then
				local height = nil

				if in_cover[4] then
					height = 150
				else
					height = 80
				end

				local my_tracker = unit:movement():nav_tracker()
				local shoot_from_pos = CopLogicAttack._peek_for_pos_sideways(data, my_data, my_tracker, focus_enemy.m_head_pos, height)

				if shoot_from_pos then
						local path = {
							my_tracker:position(),
							shoot_from_pos
						}
						--ranged fire cops signal the start of their movement and positioning
						if data.tactics and data.tactics.ranged_fire or data.tactics and data.tactics.elite_ranged_fire then
							if not data.unit:in_slot(16) then
								if data.group and data.group.leader_key == data.key and data.char_tweak.chatter.ready then
									managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "ready")
								end
							end
						end
						action_taken = CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, math.random() < 0.5 and "run" or "walk")
					else
						my_data.cover_test_step = my_data.cover_test_step + 1
					end
			elseif not enemy_visible_softer and math.random() < 0.05 then
				move_to_cover = true
				want_flank_cover = true
			end
		elseif my_data.walking_to_cover_shoot_pos then
			-- Nothing
		elseif my_data.at_cover_shoot_pos then
			--ranged fire cops also signal the END of their movement and positioning
			if data.tactics and data.tactics.ranged_fire or data.tactics and data.tactics.elite_ranged_fire then
				if not data.unit:in_slot(16) and data.char_tweak.chatter.ready then
					managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "inpos")
				end
			end
			if my_data.stay_out_time and my_data.stay_out_time < t then
				if data.tactics and data.tactics.flank then
					want_flank_cover = true 
					--i went ahead and included these to make sure flankers are always getting flanking positions instead of regular ones, it helps them stay predictable in regards to their choices of movement, you can tell a flank team by 1. smoke grenades being present 2. their chatter and 3. how they prefer to move around the map.
				end
				move_to_cover = true
			end
		else
			if data.tactics and data.tactics.flank then
				want_flank_cover = true
			end
			move_to_cover = true
		end
	end

	if not my_data.processing_cover_path and not my_data.cover_path and not my_data.charge_path_search_id and not action_taken and best_cover and (not in_cover or best_cover[1] ~= in_cover[1]) and (not my_data.cover_path_failed_t or data.t - my_data.cover_path_failed_t > 5) then
		CopLogicAttack._cancel_cover_pathing(data, my_data)

		local search_id = tostring(unit:key()) .. "cover"

		if data.unit:brain():search_for_path_to_cover(search_id, best_cover[1], best_cover[5]) then
			my_data.cover_path_search_id = search_id
			my_data.processing_cover_path = best_cover
		end
	end

	if not action_taken and move_to_cover and my_data.cover_path then
		action_taken = CopLogicAttack._chk_request_action_walk_to_cover(data, my_data)
	end

	if want_flank_cover then
		if not my_data.flank_cover then
			local sign = math.random() < 0.5 and -1 or 1
			local step = 30
			my_data.flank_cover = {
				step = step,
				angle = step * sign,
				sign = sign
			}
			my_data.taken_flank_cover = true --this helps them qualify for charging behavior after acquiring a flank, which is not vanilla behavior btw
			want_flank_cover = nil
			if not data.unit:in_slot(16) then --flankers signal their presence whenever they move around
				if data.group and data.group.leader_key == data.key and data.char_tweak.chatter.look_for_angle then
					managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "look_for_angle")
				end
			end
		end
	else
		my_data.flank_cover = nil
		my_data.taken_flank_cover = nil
	end

	if not action_taken and want_to_take_cover and not best_cover then
		action_taken = CopLogicAttack._chk_start_action_move_back(data, my_data, focus_enemy, false)
	end

	action_taken = action_taken or CopLogicAttack._chk_start_action_move_out_of_the_way(data, my_data)
end

function CopLogicAttack.aim_allow_fire(shoot, aim, data, my_data)
	local focus_enemy = data.attention_obj

	if shoot then
		if not my_data.firing then
			data.unit:movement():set_allow_fire(true)

			my_data.firing = true

			if not data.unit:in_slot(16) and data.char_tweak.chatter.aggressive then --yo shoutouts to syntax for randomly sending me vermintide 2 dlc while i was doing this lmao
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
							
							if roll <= 50 then
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
				else
					if not data.unit:base()._tweak_table == "gensec" and not data.unit:base()._tweak_table == "security" then
						if data.unit:base():has_tag("medic") and not data.unit:base():has_tag("tank") then
							managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "aggressive")
						elseif data.unit:base():has_tag("shield") then
							local shield_knock_cooldown = math.random(5, 8)
							if not data.attack_sound_t or data.t - data.attack_sound_t > shield_knock_cooldown then
								data.unit:sound():say("shield_identification", true)
							end
						else
							managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "contact")
						end
					end
				end
			end
		end
	elseif my_data.firing then
		data.unit:movement():set_allow_fire(false)

		my_data.firing = nil
	end
end

function CopLogicAttack._upd_aim(data, my_data)
	local shoot, aim, expected_pos, height_difference, outoffov = nil
	local focus_enemy = data.attention_obj
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	
	if focus_enemy and AIAttentionObject.REACT_AIM <= focus_enemy.reaction then
		local last_sup_t = data.unit:character_damage():last_suppression_t()

		if focus_enemy.verified or focus_enemy.nearly_visible then
		
			if focus_enemy.dis > my_data.weapon_range.far then
				shoot = false
			end
			
			if data.unit:anim_data().run and math.lerp(my_data.weapon_range.close, my_data.weapon_range.optimal, 0) < focus_enemy.dis then
				local walk_to_pos = data.unit:movement():get_walk_to_pos()

				if walk_to_pos then
					mvector3.direction(temp_vec1, data.m_pos, walk_to_pos)
					mvector3.direction(temp_vec2, data.m_pos, focus_enemy.m_pos)

					local dot = mvector3.dot(temp_vec1, temp_vec2)

					if dot < 0.6 then
						shoot = false
						aim = false
						outoffov = true
					end
				end
			end
			
			--harass: attempt to engage enemies who are leaving themselves open, with things like interactions, changing weapons or reloading 
	
			--this is important for harass.
			local pantsdownchk = nil
					
			if not data.unit:in_slot(16) and focus_enemy and focus_enemy.is_person and focus_enemy.verified and focus_enemy.dis <= 2000 then
				if focus_enemy.is_local_player then
					local e_movement_state = focus_enemy.unit:movement():current_state()
					if e_movement_state:_is_reloading() or e_movement_state:_interacting() or e_movement_state:is_equipping() then
						pantsdownchk = true
					end
				else
					local e_anim_data = focus_enemy.unit:anim_data()
					if not (e_anim_data.move or e_anim_data.idle) or e_anim_data.reload then
						pantsdownchk = true
					end
				end
			end
			
			local reaction_time = nil
			
			if not shoot and focus_enemy and focus_enemy.verified and data.tactics and data.tactics.harass and pantsdownchk and not outoffov then 
				shoot = true
			end

			if aim == nil and AIAttentionObject.REACT_AIM <= focus_enemy.reaction then
				if AIAttentionObject.REACT_SHOOT <= focus_enemy.reaction then
					local running = my_data.advancing and not my_data.advancing:stopping() and my_data.advancing:haste() == "run"
					local firing_range = 1800

					if data.internal_data.weapon_range then
						firing_range = running and data.internal_data.weapon_range.close or data.internal_data.weapon_range.far
						maxrange = data.internal_data.weapon_range.far
					else
						debug_pause_unit(data.unit, "[CopLogicAttack]: Unit doesn't have data.internal_data.weapon_range")
					end
					
					if not managers.groupai:state():whisper_mode() then
						if focus_enemy.verified and focus_enemy.alert_t and data.t - focus_enemy.alert_t < 7 and managers.groupai:state():chk_assault_active_atm() then
							shoot = true
						elseif focus_enemy.verified and data.internal_data.weapon_range and focus_enemy.verified_dis < firing_range and managers.groupai:state():chk_assault_active_atm() then
							shoot = true
						elseif focus_enemy.verified and focus_enemy.criminal_record and focus_enemy.criminal_record.assault_t and data.t - focus_enemy.criminal_record.assault_t < 2 then
							shoot = true
						end
					end

					if not shoot and my_data.attitude == "engage" or not shoot and focus_enemy.dis <= 800 and not managers.groupai:state():whisper_mode() then
						if focus_enemy.verified_dis < firing_range * (height_difference and 0.75 or 1) or focus_enemy.reaction == AIAttentionObject.REACT_SHOOT then
							shoot = true
						else
							local time_since_verification = focus_enemy.verified_t and data.t - focus_enemy.verified_t

							if my_data.firing and time_since_verification and time_since_verification < 3 then
								shoot = true
								if data.tactics and data.tactics.charge and focus_enemy.is_person then
									data.brain:search_for_path_to_unit("hunt" .. tostring(my_data.key), focus_enemy.unit)
								end
							else
								if not (data.tactics and data.tactics.obstacle) and focus_enemy.is_person then
									data.brain:search_for_path_to_unit("hunt" .. tostring(my_data.key), focus_enemy.unit)
								end
							end
						end
					end

					aim = aim or shoot

					if not aim and focus_enemy.verified_dis < maxrange then
						aim = true
					end
				else
					aim = true
				end
			end
		elseif AIAttentionObject.REACT_AIM <= focus_enemy.reaction then
			local time_since_verification = focus_enemy.verified_t and data.t - focus_enemy.verified_t
			local running = my_data.advancing and not my_data.advancing:stopping() and my_data.advancing:haste() == "run"
			local same_z = math.abs(focus_enemy.verified_pos.z - data.m_pos.z) < 250

			if running then
				if time_since_verification and time_since_verification < 1 and same_z then
					aim = true
				end
			else
				aim = true
			end

			if aim and my_data.shooting and not managers.groupai:state():whisper_mode() and AIAttentionObject.REACT_SHOOT <= focus_enemy.reaction and time_since_verification and time_since_verification < (running and 1 or 2) then
				shoot = true
			end

			if not aim then
				expected_pos = CopLogicAttack._get_expected_attention_position(data, my_data)

				if expected_pos then
					if running then
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
							
							if focus_enemy and aim and focus_enemy.alert_t and data.t - focus_enemy.alert_t < 1 and focus_enemy.verified_t and data.t - focus_enemy.verified_t < 5 and data.tactics and data.tactics.harass then
								shoot = true
							end
						end
					else
						aim = true
						
						if focus_enemy and aim and focus_enemy.alert_t and data.t - focus_enemy.alert_t < 1 and focus_enemy.verified_t and data.t - focus_enemy.verified_t < 5 and data.tactics and data.tactics.harass then
							shoot = true
						end
					end
				end
			end
		else
			expected_pos = CopLogicAttack._get_expected_attention_position(data, my_data)

			if expected_pos then
				aim = true
				
				--cops will open fire on expected player positions if they hear player alerts and the player has been seen in the last 5 seconds, and they're harassers, for large bursts of suppressive fire.
				
				if focus_enemy and aim and focus_enemy.alert_t and data.t - focus_enemy.alert_t < 1 and focus_enemy.verified_t and data.t - focus_enemy.verified_t < 5 and data.tactics and data.tactics.harass then
					shoot = true
				end
			end
		end
	end
		
	--cops call out player reloads if they've seen the player in the last 6 seconds on difficulties above overkill
	if focus_enemy and focus_enemy.is_person and focus_enemy.reaction >= AIAttentionObject.REACT_COMBAT and not data.unit:in_slot(16) then
		if focus_enemy.is_local_player then
			local time_since_verify = data.attention_obj.verified_t and data.t - data.attention_obj.verified_t
			local e_movement_state = focus_enemy.unit:movement():current_state()
			
			if e_movement_state:_is_reloading() and time_since_verify and time_since_verify < 6 then
				if not data.unit:in_slot(16) and data.char_tweak.chatter.reload then
					managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "reload")
				end
			end
		else
			local e_anim_data = focus_enemy.unit:anim_data()
			local time_since_verify = data.attention_obj.verified_t and data.t - data.attention_obj.verified_t

			if e_anim_data.reload and time_since_verify and time_since_verify < 6 then
				if not data.unit:in_slot(16) and data.char_tweak.chatter.reload then
					managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "reload")
				end			
			end
		end
	end
	
	if not aim and data.char_tweak.always_face_enemy and focus_enemy and AIAttentionObject.REACT_COMBAT >= focus_enemy.reaction then
		aim = true
	end

	if data.logic.chk_should_turn(data, my_data) and (focus_enemy or expected_pos) then
		local enemy_pos = expected_pos or (focus_enemy.verified or focus_enemy.nearly_visible) and focus_enemy.m_pos or focus_enemy.verified_pos

		CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, enemy_pos)
	end

	if aim or shoot then
		if expected_pos then
			if my_data.attention_unit ~= expected_pos then
				CopLogicBase._set_attention_on_pos(data, mvector3.copy(expected_pos))

				my_data.attention_unit = mvector3.copy(expected_pos)
			end
		elseif focus_enemy.verified or focus_enemy.nearly_visible then
			if my_data.attention_unit ~= focus_enemy.u_key then
				CopLogicBase._set_attention(data, focus_enemy)

				my_data.attention_unit = focus_enemy.u_key
			end
		else
			local look_pos = focus_enemy.last_verified_pos or focus_enemy.verified_pos

			if my_data.attention_unit ~= look_pos then
				CopLogicBase._set_attention_on_pos(data, mvector3.copy(look_pos))

				my_data.attention_unit = mvector3.copy(look_pos)
			end
		end

		if not my_data.shooting and not my_data.spooc_attack and not data.unit:anim_data().reload and not data.unit:movement():chk_action_forbidden("action") then
			local shoot_action = {
				body_part = 3,
				type = "shoot"
			}

			if data.unit:brain():action_request(shoot_action) then
				my_data.shooting = true
			end
		end
	else
		if my_data.shooting then
			local new_action = {
				body_part = 3,
				type = "idle"
			}
			if not data.unit:anim_data().reload and not data.unit:movement():chk_action_forbidden("action") then
				data.unit:brain():action_request(new_action)
			end
		end

		if my_data.attention_unit then
			CopLogicBase._reset_attention(data)

			my_data.attention_unit = nil
		end
	end

	CopLogicAttack.aim_allow_fire(shoot, aim, data, my_data)
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
				my_data.cover_enter_t = data.t
			end

			my_data.moving_to_cover = nil
		elseif my_data.walking_to_cover_shoot_pos then
			my_data.walking_to_cover_shoot_pos = nil
			my_data.at_cover_shoot_pos = true
		end
	elseif action_type == "shoot" then
		my_data.shooting = nil
	elseif action_type == "turn" then
		my_data.turning = nil
	elseif action_type == "hurt" then
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		
		--Removed the requirement for being important here.
		if action:expired() and not CopLogicBase.chk_start_action_dodge(data, "hit") then
			data.logic._upd_aim(data, my_data)
		end
	elseif action_type == "dodge" then
		local timeout = action:timeout()

		if timeout then
			data.dodge_timeout_t = TimerManager:game():time() + math.lerp(timeout[1], timeout[2], math.random())
		end

		CopLogicAttack._cancel_cover_pathing(data, my_data)

		if action:expired() then
			CopLogicAttack._upd_aim(data, my_data)
		end
	end
end

function CopLogicAttack._chk_start_action_move_back(data, my_data, focus_enemy, engage)

	local pantsdownchk = nil
	
	if not data.unit:in_slot(16) and focus_enemy and focus_enemy.is_person and focus_enemy.dis <= 2000 then
		if focus_enemy.is_local_player then
			local e_movement_state = focus_enemy.unit:movement():current_state()

			if e_movement_state:_is_reloading() or e_movement_state:_interacting() or e_movement_state:is_equipping() then
				pantsdownchk = true
			end
		else
			local e_anim_data = focus_enemy.unit:anim_data()

			if not (e_anim_data.move or e_anim_data.idle) or e_anim_data.reload then
				pantsdownchk = true
			end
		end
	end
	
	local can_perform_walking_action = not my_data.turning and not data.unit:movement():chk_action_forbidden("walk") and not my_data.has_old_action and not my_data.moving_to_cover and not my_data.walking_to_cover_shoot_pos
	
	if can_perform_walking_action then
	--what the fuck is my code rn tbh
		if focus_enemy and focus_enemy.nav_tracker and focus_enemy.verified and focus_enemy.dis < 250 and CopLogicAttack._can_move(data) or focus_enemy and focus_enemy.nav_tracker and focus_enemy.dis < 700 and CopLogicAttack._can_move(data) or data.tactics and data.tactics.elite_ranged_fire and focus_enemy and focus_enemy.nav_tracker and focus_enemy.verified and focus_enemy.verified_dis <= 1500 and CopLogicAttack._can_move(data) or data.tactics and data.tactics.hitnrun and focus_enemy and focus_enemy.verified and focus_enemy.verified_dis <= 1000 and CopLogicAttack._can_move(data) or data.tactics and data.tactics.spoocavoidance and focus_enemy.verified and focus_enemy.aimed_at or data.tactics and data.tactics.reloadingretreat and focus_enemy and focus_enemy.verified then
			
			local from_pos = mvector3.copy(data.m_pos)
			local threat_tracker = focus_enemy.nav_tracker
			local threat_head_pos = focus_enemy.m_head_pos
			local max_walk_dis = nil
			local vis_required = engage
				
			if data.tactics and data.tactics.hitnrun then
				max_walk_dis = 800
			elseif data.tactics and data.tactics.elite_ranged_fire then
				max_walk_dis = 1000
			elseif data.tactics and data.tactics.spoocavoidance then
				max_walk_dis = 1500
			elseif data.tactics and data.tactics.reloadingretreat then
				max_walk_dis = 1500
			else
				max_walk_dis = 400
			end
				
			local retreat_to = CopLogicAttack._find_retreat_position(from_pos, focus_enemy.m_pos, threat_head_pos, threat_tracker, max_walk_dis, vis_required)

			if retreat_to then
				CopLogicAttack._cancel_cover_pathing(data, my_data)
					
				--if data.tactics and data.tactics.hitnrun or data.tactics and data.tactics.elite_ranged_fire then
					--log("hitnrun or eliteranged just backed up properly")
				--end
					
				if data.tactics and data.tactics.elite_ranged_fire then
					if not data.unit:in_slot(16) and data.char_tweak.chatter.dodge then
						managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "dodge")
					end
				end

				local new_action_data = {
					variant = "run",
					body_part = 2,
					type = "walk",
					nav_path = {
						from_pos,
						retreat_to
					}
				}
				my_data.advancing = data.unit:brain():action_request(new_action_data)
					
				if my_data.advancing then
					my_data.surprised = true

					return true
				end
			end
		end
	end
end

function CopLogicAttack._chk_request_action_walk_to_cover(data, my_data)
	CopLogicAttack._correct_path_start_pos(data, my_data.cover_path)
	
	local haste = nil
	
	local can_perform_walking_action = not my_data.turning and not data.unit:movement():chk_action_forbidden("walk") and not my_data.has_old_action and not my_data.moving_to_cover and not my_data.walking_to_cover_shoot_pos
	
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
		"shield",
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
		"deathvox_greendozer",
		"deathvox_blackdozer",
		"deathvox_lmgdozer",
		"deathvox_medicdozer",
		"deathvox_grenadier"
	}
	local is_mook = nil
	for _, name in ipairs(mook_units) do
		if data.unit:base()._tweak_table == name then
			is_mook = true
		end
	end
	
	if can_perform_walking_action then 
		
		--enemies at long distances makes cops run, enemies at shorter distances makes cops walk, keeps pacing in small maps consistent and manageable, while making the cops seem cooler
		local enemyseeninlast4secs = data.attention_obj and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4
		local enemy_seen_range_bonus = enemyseeninlast4secs and 500 or 0
		local enemy_has_height_difference = data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis >= 1200 and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4 and math.abs(data.m_pos.z - data.attention_obj.m_pos.z) > 250
		
		if data.unit:movement():cool() then
			haste = "walk"
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis > 1200 + enemy_seen_range_bonus and not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() then
			haste = "run"
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis <= 1200 + enemy_seen_range_bonus - (math.abs(data.m_pos.z - data.attention_obj.m_pos.z) < 250 and 400 or 0) and is_mook and data.tactics and not data.tactics.hitnrun then
			haste = "walk"
		else
			haste = "run"
		end

		local crouch_roll = math.random(0.01, 1)
		local stand_chance = nil
		local end_pose = nil
	
		if data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis > 2000 then
			stand_chance = 0.75
		elseif enemy_has_height_difference and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
			stand_chance = 0.25
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and (data.attention_obj.verified and data.attention_obj.dis <= 1500 or data.attention_obj.dis <= 1000) and CopLogicTravel._chk_close_to_criminal(data, my_data) and data.tactics and data.tactics.flank and haste == "walk" then
			stand_chance = 0.25
		elseif my_data.moving_to_cover and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
			stand_chance = 0.5
		else
			stand_chance = 1
		end
	
		--randomize enemy crouching to make enemies feel less easy to aim at, the fact they're always crouching all over the place always bugged me, plus, they shouldn't need to crouch so often when you're at long distances from them
		
		if not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() then
			if crouch_roll > stand_chance and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
				end_pose = "crouch"
				pose = "crouch"
				should_crouch = true
			end
		end
	
		local pose = nil
		pose = not data.char_tweak.crouch_move and "stand" or data.char_tweak.allowed_poses and not data.char_tweak.allowed_poses.stand and "crouch" or should_crouch and "crouch" or "stand"

		if not data.unit:anim_data()[pose] then
			CopLogicAttack["_chk_request_action_" .. pose](data)
		end
		
		if not pose then
			pose = not data.char_tweak.crouch_move and "stand" or data.char_tweak.allowed_poses and not data.char_tweak.allowed_poses.stand and "crouch" or "stand"
		end
		
		local new_action_data = {
			type = "walk",
			body_part = 2,
			pose = pose,
			nav_path = my_data.cover_path,
			variant = haste,
			end_pose = end_pose
		}
		my_data.cover_path = nil
		my_data.advancing = data.unit:brain():action_request(new_action_data)

		if my_data.advancing then
			my_data.moving_to_cover = my_data.best_cover
			my_data.at_cover_shoot_pos = nil
			my_data.in_cover = nil

			data.brain:rem_pos_rsrv("path")
		end
	end
end

function CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, speed)
	local can_perform_walking_action = not my_data.turning and not data.unit:movement():chk_action_forbidden("walk") and not my_data.has_old_action and not my_data.moving_to_cover and not my_data.walking_to_cover_shoot_pos
	local pose = not data.char_tweak.crouch_move and "stand" or data.char_tweak.allowed_poses and not data.char_tweak.allowed_poses.stand and "crouch" or should_crouch and "crouch" or "stand"
	
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
		"shield",
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
		"deathvox_greendozer",
		"deathvox_blackdozer",
		"deathvox_lmgdozer",
		"deathvox_medicdozer",
		"deathvox_grenadier"
	}
	local is_mook = nil
	for _, name in ipairs(mook_units) do
		if data.unit:base()._tweak_table == name then
			is_mook = true
		end
	end
	
	if can_perform_walking_action then
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
		CopLogicAttack._correct_path_start_pos(data, path)
		
		--enemies at long distances makes cops run, enemies at shorter distances makes cops walk, keeps pacing in small maps consistent and manageable, while making the cops seem cooler
		local enemyseeninlast4secs = data.attention_obj and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4
		local enemy_seen_range_bonus = enemyseeninlast4secs and 500 or 0
		local enemy_has_height_difference = data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis >= 1200 and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4 and math.abs(data.m_pos.z - data.attention_obj.m_pos.z) > 250
		
		if data.unit:movement():cool() then
			haste = "walk"
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis > 1200 + (enemyseeninlast4secs and 500 or 0) and not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() then
			haste = "run"
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis <= 1200 + enemy_seen_range_bonus - (math.abs(data.m_pos.z - data.attention_obj.m_pos.z) < 250 and 400 or 0) and is_mook and data.tactics and not data.tactics.hitnrun then
			haste = "walk"
		else
			haste = "run"
		end

		local crouch_roll = math.random(0.01, 1)
		local stand_chance = nil
		local end_pose = nil
	
		if data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis > 2000 then
			stand_chance = 0.75
		elseif enemy_has_height_difference and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
			stand_chance = 0.25
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and (data.attention_obj.verified and data.attention_obj.dis <= 1500 or data.attention_obj.dis <= 1000) and CopLogicTravel._chk_close_to_criminal(data, my_data) and data.tactics and data.tactics.flank and haste == "walk" then
			stand_chance = 0.25
		elseif my_data.moving_to_cover and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
			stand_chance = 0.5
		else
			stand_chance = 1
		end
	
		--randomize enemy crouching to make enemies feel less easy to aim at, the fact they're always crouching all over the place always bugged me, plus, they shouldn't need to crouch so often when you're at long distances from them
		
		if not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() then
			if crouch_roll > stand_chance and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
				end_pose = "crouch"
				pose = "crouch"
				should_crouch = true
			end
		end

		if not data.unit:anim_data()[pose] then
			CopLogicAttack["_chk_request_action_" .. pose](data)
		end
		
		if not pose then
			pose = not data.char_tweak.crouch_move and "stand" or data.char_tweak.allowed_poses and not data.char_tweak.allowed_poses.stand and "crouch" or "stand"
		end

		local new_action_data = {
			body_part = 2,
			type = "walk",
			nav_path = path,
			pose = pose,
			end_pose = end_pose,
			variant = haste or "walk"
		}
		my_data.cover_path = nil
		my_data.advancing = data.unit:brain():action_request(new_action_data)

		if my_data.advancing then
			my_data.walking_to_cover_shoot_pos = my_data.advancing
			my_data.at_cover_shoot_pos = nil
			my_data.in_cover = nil

			data.brain:rem_pos_rsrv("path")
		end
	end
end

function CopLogicAttack.queue_update(data, my_data)
	local focus_enemy = data.attention_obj
	local is_close = focus_enemy and focus_enemy.dis <= 3000 and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction
	local too_far = focus_enemy and focus_enemy.dis > 5000 and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction
	local delay = nil
	if in_close then
		delay = 0
	elseif too_far then
		delay = 0.7
	else
		delay = 0.35
	end
	CopLogicBase.queue_task(my_data, my_data.update_queue_id, data.logic.queued_update, data, data.t + delay)
end