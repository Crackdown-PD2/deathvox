local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_vec3 = Vector3()

function TeamAILogicIdle.enter(data, new_logic_name, enter_params)
	TeamAILogicBase.enter(data, new_logic_name, enter_params)

	local my_data = {
		unit = data.unit,
		detection = data.char_tweak.detection.idle,
		enemy_detect_slotmask = managers.slot:get_mask("enemies")
	}
	local old_internal_data = data.internal_data

	if old_internal_data then
		if old_internal_data.best_cover then
			my_data.best_cover = old_internal_data.best_cover

			managers.navigation:reserve_cover(my_data.best_cover[1], data.pos_rsrv_id)
		end

		if old_internal_data.nearest_cover then
			my_data.nearest_cover = old_internal_data.nearest_cover

			managers.navigation:reserve_cover(my_data.nearest_cover[1], data.pos_rsrv_id)
		end

		my_data.attention_unit = old_internal_data.attention_unit
	end

	data.internal_data = my_data
	local key_str = tostring(data.key)
	my_data.detection_task_key = "TeamAILogicIdle._upd_enemy_detection" .. key_str

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, TeamAILogicIdle._upd_enemy_detection, data, data.t)

	if my_data.nearest_cover or my_data.best_cover then
		my_data.cover_update_task_key = "CopLogicIdle._update_cover" .. key_str

		CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t + 1)
	end

	my_data.stare_path_search_id = "stare" .. key_str
	my_data.relocate_chk_t = 0

	CopLogicBase._reset_attention(data)

	if data.unit:movement():stance_name() == "cbt" then
		data.unit:movement():set_stance("hos")
	end

	data.unit:movement():set_allow_fire(false)

	local objective = data.objective
	local entry_action = enter_params and enter_params.action

	if objective then
		if objective.type == "revive" then
			if objective.action_start_clbk then
				objective.action_start_clbk(data.unit)
			end

			local success = nil
			local revive_unit = objective.follow_unit

			if revive_unit:interaction() then
				if revive_unit:interaction():active() and data.unit:brain():action_request(objective.action) then
					revive_unit:interaction():interact_start(data.unit)

					success = true
				end
			elseif revive_unit:character_damage():arrested() then
				if data.unit:brain():action_request(objective.action) then
					revive_unit:character_damage():pause_arrested_timer()

					success = true
				end
			elseif revive_unit:character_damage():need_revive() and data.unit:brain():action_request(objective.action) then
				revive_unit:character_damage():pause_downed_timer()

				success = true
			end

			if success then
				my_data.performing_act_objective = objective
				my_data.reviving = revive_unit
				my_data.acting = true
				my_data.revive_complete_clbk_id = "TeamAILogicIdle_revive" .. tostring(data.key)
				local revive_t = TimerManager:game():time() + (objective.action_duration or 0)

				CopLogicBase.add_delayed_clbk(my_data, my_data.revive_complete_clbk_id, callback(TeamAILogicIdle, TeamAILogicIdle, "clbk_revive_complete", data), revive_t)

				local voiceline = "s09b" --usual bot revive line (should be used for players when they have 3/4 downs left)

				if revive_unit:base().is_local_player then
					if not revive_unit:character_damage():arrested() then
						if revive_unit:movement():current_state_name() == "incapacitated" then --tased/cloaked
							voiceline = "s08x_sin" --"let me help you up"
						else
							if revive_unit:character_damage():get_revives() == 2 then --2 downs left
								voiceline = "s09a" --"you're really fucked up"
							elseif revive_unit:character_damage():get_revives() == 1 then --1 down left
								voiceline = "s09c" --usual bot revive line + last down warning
							end
						end

						data.unit:sound():say(voiceline, true)
					end
				elseif revive_unit:base().is_husk_player then
					if not revive_unit:character_damage():arrested() then --can't check for lives in vanilla, add code for this if you want to
						if revive_unit:movement():current_state_name() == "incapacitated" then
							voiceline = "s08x_sin"
						end

						data.unit:sound():say(voiceline, true)
					end
				else
					if not revive_unit:character_damage():arrested() then
						data.unit:sound():say(voiceline, true) --doesn't really matter for bots, but some variation could be added if desired
					end
				end
			else
				data.unit:brain():set_objective()

				return
			end
		elseif objective.type == "throw_bag" then
			data.unit:movement():throw_bag(objective.unit)

			data._ignore_first_travel_order = true

			data.unit:brain():set_objective()
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
				my_data.wall_stare_task_key = "CopLogicIdle._chk_stare_into_wall" .. tostring(data.key)

				CopLogicBase.queue_task(my_data, my_data.wall_stare_task_key, CopLogicIdle._chk_stare_into_wall_1, data, data.t)
			end
		end
	end
end

function TeamAILogicIdle.on_long_dis_interacted(data, other_unit, secondary)
	if data.objective and data.objective.type == "revive" then
		return
	end

	local objective_type, objective_action, interrupt = nil

	if other_unit:base().is_local_player then
		if not secondary then
			if other_unit:character_damage():need_revive() then
				objective_type = "revive"
				objective_action = "revive"
			elseif other_unit:character_damage():arrested() then
				objective_type = "revive"
				objective_action = "untie"
			else
				objective_type = "follow"
			end
		else
			objective_type = "stop"
		end
	elseif not secondary then
		if other_unit:movement():need_revive() then
			objective_type = "revive"

			if other_unit:movement():current_state_name() == "arrested" then
				objective_action = "untie"
			else
				objective_action = "revive"
			end
		else
			objective_type = "follow"
		end
	else
		objective_type = "stop"
	end

	local objective = nil
	local should_stay = false

	if objective_type == "follow" then
		if data.unit:movement():carrying_bag() and not data.unit:movement()._should_stay then
			local throw_distance = tweak_data.ai_carry.throw_distance * data.unit:movement():carry_tweak().throw_distance_multiplier
			local dist = data.unit:position() - other_unit:position()
			local throw_bag = mvector3.dot(dist, dist) < throw_distance * throw_distance

			if throw_bag then
				if other_unit == managers.player:player_unit() then
					if other_unit:movement():current_state_name() == "carry" then
						throw_bag = false
					end
				elseif other_unit:movement():carry_id() ~= nil then
					throw_bag = false
				end
			end

			if throw_bag then
				objective = {
					type = "throw_bag",
					unit = other_unit
				}
			end
		end

		if not objective then
			objective = {
				scan = true,
				destroy_clbk_key = false,
				called = true,
				type = objective_type,
				follow_unit = other_unit
			}

			data.unit:sound():say("r01x_sin", true)
		end
	elseif objective_type == "stop" then
		objective = {
			scan = true,
			destroy_clbk_key = false,
			type = "follow",
			called = true,
			follow_unit = other_unit
		}
		should_stay = true
	else
		local followup_objective = {
			scan = true,
			type = "act",
			action = {
				variant = "crouch",
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
		objective = {
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
					walk = -1
				}
			},
			action_duration = tweak_data.interaction[objective_action == "untie" and "free" or objective_action].timer,
			followup_objective = followup_objective
		}

		if objective_type == "revive" and not objective_action == "untie" then --not cuffed
			data.unit:sound():say("r02a_sin", true) --"I'M COMING FOR YOU, STAY AWAY FROM THE LIGHT"
		end
	end

	if data.unit:movement():carrying_bag() and objective.type == "revive" then --carrying a bag and called to revive a player
		if not data.unit:movement():carry_tweak().can_run then --slowed down by the bag
			local range_sq = 810000
			local my_pos = data.unit:position()
			local revive_unit_pos = other_unit:position()
			local dist = mvector3.distance_sq(my_pos, revive_unit_pos)
			local inspire_available = managers.player:is_custom_cooldown_not_active("team", "crew_inspire")

			if dist < range_sq then --within inspire range, taken from teamailogictravel as it's calculated with square distance
				if not inspire_available then --if inspire is on cooldown, throw the bag, otherwise, don't
					data.unit:movement():throw_bag()
				end
			else --not within inspire range, so throw the bag
				data.unit:movement():throw_bag()
			end
		end
	end

	data.unit:movement():set_should_stay(should_stay)

	if objective then
		data.unit:brain():set_objective(objective)
	end
end

function TeamAILogicIdle._ignore_shield(unit, attention)
	local weapon_base = unit:inventory():equipped_unit() and unit:inventory():equipped_unit().base and unit:inventory():equipped_unit():base()
	local has_ap_ammo = weapon_base and weapon_base._use_armor_piercing

	if has_ap_ammo then --this way Jokers can also easily check if they have AP ammo
		return false
	end

	if not TeamAILogicIdle._shield_check then
		TeamAILogicIdle._shield_check = managers.slot:get_mask("enemy_shield_check")
	end

	local head_pos = unit:movement():m_head_pos()
	local u_char_dmg = attention and attention.unit and attention.unit:character_damage()
	local u_shoot_pos = Vector3()

	if u_char_dmg and u_char_dmg.shoot_pos_mid then 
		u_char_dmg:shoot_pos_mid(u_shoot_pos)
	else
		return false
	end

	local hit_shield = World:raycast("ray", head_pos, u_shoot_pos, "slot_mask", TeamAILogicIdle._shield_check, "report")

	return not not hit_shield
end

function TeamAILogicIdle._find_intimidateable_civilians(criminal, use_default_shout_shape, max_angle, max_dis) --useless, so
	local intimidateable_civilians = {}
	local best_civ = nil
	local highest_wgt = nil

	return best_civ, highest_wgt, intimidateable_civilians
end

function TeamAILogicIdle.intimidate_civilians(data, criminal, play_sound, play_action, primary_target) --also useless
	return false
end

function TeamAILogicIdle._get_priority_attention(data, attention_objects, reaction_func)
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
					attention_data.pause_expire_t = data.t + math.lerp(attention_data.settings.pause[1], attention_data.settings.pause[2], math.random())
				end
			else
				local distance = mvector3.distance(data.m_pos, attention_data.m_pos)
				local reaction = reaction_func(data, attention_data, not CopLogicAttack._can_move(data))
				local reaction_too_mild = nil

				if not reaction or best_target_reaction and reaction < best_target_reaction then
					reaction_too_mild = true
				elseif distance < 150 and reaction <= AIAttentionObject.REACT_SURPRISED then
					reaction_too_mild = true
				end

				if not reaction_too_mild then
					local aimed_at = TeamAILogicIdle.chk_am_i_aimed_at(data, attention_data, attention_data.aimed_at and 0.95 or 0.985)
					attention_data.aimed_at = aimed_at

					local alert_dt = attention_data.alert_t and data.t - attention_data.alert_t or 10000
					local dmg_dt = attention_data.dmg_t and data.t - attention_data.dmg_t or 10000
					local too_close_threshold = 300
					local near_threshold = 800

					if data.attention_obj and data.attention_obj.u_key == u_key then
						alert_dt = alert_dt * 0.8
						dmg_dt = dmg_dt * 0.8
						distance = distance * 0.8
					end

					local is_visible = attention_data.verified
					local target_priority = distance
					local target_priority_slot = 0

					if is_visible then
						local is_shielded = TeamAILogicIdle._ignore_shield and TeamAILogicIdle._ignore_shield(data.unit, attention_data) or nil

						if is_shielded then
							if distance <= 180 and att_unit:base().has_tag and att_unit:base():has_tag("shield") then
								local can_be_knocked = att_unit:base():char_tweak().damage.shield_knocked and not att_unit:base().is_phalanx and not att_unit:character_damage():is_immune_to_shield_knockback()

								if can_be_knocked then
									target_priority_slot = 4
								else
									reaction = AIAttentionObject.REACT_AIM
								end
							else
								reaction = AIAttentionObject.REACT_AIM
							end
						else
							local too_close = distance <= too_close_threshold
							local near = distance < near_threshold and distance > too_close_threshold
							local has_alerted = alert_dt < 5
							local has_damaged = dmg_dt < 2
							local is_spooc = att_unit:base().has_tag and att_unit:base():has_tag("spooc")
							local is_taser = att_unit:base().has_tag and att_unit:base():has_tag("taser")
							local is_medic = att_unit:base().has_tag and att_unit:base():has_tag("medic")
							local is_tank = att_unit:base().has_tag and att_unit:base():has_tag("tank") and not att_unit:base():has_tag("medic")
							local is_sniper = att_unit:base().has_tag and att_unit:base():has_tag("sniper")
							local is_shield = att_unit:base().has_tag and att_unit:base():has_tag("shield") and att_unit:base()._tweak_table ~= "phalanx_vip"
							local is_phalanx_captain = att_unit:base()._tweak_table == "phalanx_vip"
							local is_turret = att_unit:base().sentry_gun
							local is_marked = att_unit.contour and att_unit:contour() and att_unit:contour()._contour_list

							if is_spooc then
								target_priority_slot = too_close and 1 or near and 3 or is_marked and 6 or has_damaged and has_alerted and 9 or has_alerted and 10 or 11

								local e_internal_data = att_unit:brain()._logic_data and att_unit:brain()._logic_data.internal_data

								if e_internal_data then
									local trying_to_kick_criminal = e_internal_data.spooc_attack

									if trying_to_kick_criminal then
										target_priority_slot = 1
									end
								end
							elseif is_medic then
								target_priority_slot = too_close and 2 or near and 4 or is_marked and 6 or has_damaged and has_alerted and 9 or has_alerted and 10 or 11
							elseif is_taser then
								target_priority_slot = too_close and 3 or near and 5 or is_marked and 7 or has_damaged and has_alerted and 9 or has_alerted and 10 or 11

								local e_internal_data = att_unit:brain()._logic_data and att_unit:brain()._logic_data.internal_data

								if e_internal_data then
									local trying_to_tase_criminal = e_internal_data.tasing

									if trying_to_tase_criminal then
										target_priority_slot = 1
									end
								end
							elseif is_sniper then
								target_priority_slot = too_close and 4 or near and 6 or is_marked and 7 or has_damaged and has_alerted and 9 or has_alerted and 10 or 11
							elseif is_tank then
								target_priority_slot = too_close and 4 or near and 6 or is_marked and 8 or has_damaged and has_alerted and 9 or has_alerted and 10 or 11
							elseif is_shield then
								target_priority_slot = too_close and 4 or near and 6 or is_marked and 8 or has_damaged and has_alerted and 9 or has_alerted and 10 or 11
							elseif is_turret then
								target_priority_slot = too_close and 4 or near and 6 or is_marked and 8 or has_damaged and has_alerted and 9 or has_alerted and 10 or 11
							elseif has_damaged and has_alerted then
								target_priority_slot = too_close and 5 or near and 7 or 9
							elseif has_alerted then
								target_priority_slot = too_close and 6 or near and 8 or 10
							else
								target_priority_slot = too_close and 7 or near and 9 or 11
							end

							if is_phalanx_captain then
								local active_phalanx = alive(managers.groupai:state():phalanx_vip())

								if active_phalanx then
									target_priority_slot = 4
								else
									target_priority_slot = 0
									reaction = AIAttentionObject.REACT_AIM
								end
							else
								if not is_medic and att_unit:character_damage().check_medic_heal and not table.contains(tweak_data.medic.disabled_units, att_unit:base()._tweak_table) then
									if not att_unit:anim_data() or not att_unit:anim_data().act then
										local team = att_unit:brain() and att_unit:brain()._logic_data and att_unit:brain()._logic_data.team

										if team and team.id ~= "law1" and (not team.friends or not team.friends.law1) then
											--nothing
										else
											local medic = managers.enemy:get_nearby_medic(att_unit)

											if medic then
												if medic:character_damage().shoot_pos_mid then
													local medic_shoot_pos = Vector3()
													medic:character_damage():shoot_pos_mid(medic_shoot_pos)

													if not World:raycast("ray", data.unit:movement():m_head_pos(), medic_shoot_pos, "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", "ai_vision", "report") then
														target_priority_slot = 0
													end
												end
											end
										end
									end
								end
							end

							if target_priority_slot ~= 0 then
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
						reaction = AIAttentionObject.REACT_AIM
					end

					if reaction < AIAttentionObject.REACT_COMBAT then
						target_priority_slot = 14 + math.max(0, AIAttentionObject.REACT_COMBAT - reaction)
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
