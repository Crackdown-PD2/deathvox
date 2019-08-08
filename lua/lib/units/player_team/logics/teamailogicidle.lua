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

		data.unit:sound():say("r02a_sin", true)
	end

	--calling a bot to revive you in case they're not trying to do so will make them drop what they're carring (if it slows them down) if they're not in range of Inspire and it's not on cooldown
	if data.unit:movement():carrying_bag() and objective.type == "revive" then
		if not data.unit:movement():carry_tweak().can_run then
			local range_sq = 810000
			local pos = data.unit:position()
			local target = revive_unit:position()
			local dist = mvector3.distance_sq(pos, target)

			local speed_modifier = data.unit:movement():carry_tweak().move_speed_modifier
			local no_inspire_cooldown = managers.player:is_custom_cooldown_not_active("team", "crew_inspire")

			if dist < range_sq and not no_inspire_cooldown then
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
	if managers.groupai:state():is_unit_team_AI(unit) and managers.player:has_category_upgrade("team", "crew_ai_ap_ammo") then --prevent Jokers from thinking they have AP rounds, modify later to use with Kith's Mercenary skill
		return false
	end

	if not TeamAILogicIdle._shield_check then
		TeamAILogicIdle._shield_check = managers.slot:get_mask("enemy_shield_check")
	end

	local head_pos = unit:movement():m_head_pos()
	local att_movement = attention and attention.unit and attention.unit.movement and attention.unit:movement() or nil
	local u_head_pos = att_movement and att_movement.m_head_pos and att_movement:m_head_pos() or nil

	if not u_head_pos then
		return false
	end

	local hit_shield = World:raycast("ray", head_pos, u_head_pos, "ignore_unit", {unit}, "slot_mask", TeamAILogicIdle._shield_check)

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

		if not attention_data.identified then --thanks, I hate it
			-- Nothing
		elseif attention_data.pause_expire_t then
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
			local aimed_at = TeamAILogicIdle.chk_am_i_aimed_at(data, attention_data, attention_data.aimed_at and 0.95 or 0.985)
			attention_data.aimed_at = aimed_at
			local reaction_too_mild = nil

			if not reaction or best_target_reaction and reaction < best_target_reaction then
				reaction_too_mild = true
			elseif distance < 150 and reaction <= AIAttentionObject.REACT_SURPRISED then
				reaction_too_mild = true
			end

			if not reaction_too_mild then --at least until down here (I personally didn't use reaction_too_mild and simply set the stare and pause stuff to nil because fuck that)
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
				local too_close = distance <= too_close_threshold
				local near = distance < near_threshold and distance > too_close_threshold
				local has_alerted = alert_dt < 5
				local has_damaged = dmg_dt < 2
				local is_spooc = att_unit:base()._tweak_table == "spooc" --replace all these with has_tag, using _tweak_table for exceptions), I didn't have the time (and I made this script ages ago)
				local is_taser = att_unit:base()._tweak_table == "taser"
				local is_medic = att_unit:base()._tweak_table == "medic" or att_unit:base()._tweak_table == "tank_medic"
				local is_tank = att_unit:base()._tweak_table == "tank" or att_unit:base()._tweak_table == "tank_mini" or att_unit:base()._tweak_table == "tank_hw"
				local is_sniper = att_unit:base()._tweak_table == "sniper"
				local is_shield = att_unit:base()._tweak_table == "shield" or att_unit:base()._tweak_table == "phalanx_minion"
				local is_captain = att_unit:base()._tweak_table == "phalanx_vip"
				local is_turret = att_unit:base().sentry_gun
				local target_priority = distance
				local target_priority_slot = 0
				local is_shielded = TeamAILogicIdle._ignore_shield and TeamAILogicIdle._ignore_shield(data.unit, attention_data) or nil

				local is_marked = false --arrange as you see fit, and use this placeholder for specials that require being marked, I'll make it work later since it's really simple

				if visible then
					if too_close then
						if not is_shielded then
							if is_spooc then
								target_priority_slot = 1
							elseif is_medic then
								target_priority_slot = 2
							elseif is_taser then
								target_priority_slot = 3
							elseif is_tank or is_shield or is_sniper or is_turret then
								target_priority_slot = 4
							elseif has_damaged and has_alerted then
								target_priority_slot = 5
							elseif has_alerted then
								target_priority_slot = 6
							else
								target_priority_slot = 7
							end
						else
							target_priority_slot = 11
						end
					elseif near then
						if not is_shielded then
							if is_spooc then
								target_priority_slot = 3
							elseif is_medic then
								target_priority_slot = 4
							elseif is_taser then
								target_priority_slot = 5
							elseif is_tank or is_shield or is_sniper or is_turret then
								target_priority_slot = 6
							elseif has_damaged and has_alerted then
								target_priority_slot = 7
							elseif has_alerted then
								target_priority_slot = 8
							else
								target_priority_slot = 9
							end
						else
							target_priority_slot = 11
						end
					else
						if not is_shielded then
							if is_spooc or is_medic then
								target_priority_slot = 6
							elseif is_taser or is_sniper then
								target_priority_slot = 7
							elseif is_tank or is_shield or is_turret then
								target_priority_slot = 8
							elseif has_damaged and has_alerted then
								target_priority_slot = 9
							elseif has_alerted then
								target_priority_slot = 10
							else
								target_priority_slot = 11
							end
						else
							target_priority_slot = 11
						end
					end

					if is_spooc and not is_shielded then
						if att_unit:brain()._logic_data then
							if att_unit:brain()._logic_data.internal_data and att_unit:brain()._logic_data.internal_data.spooc_attack then --cloaker is trying to kick someone
								target_priority_slot = 1
							end
						end
					end

					if is_taser and not is_shielded then
						if att_unit:brain()._logic_data then
							if att_unit:brain()._logic_data.internal_data and att_unit:brain()._logic_data.internal_data.tasing then --taser is trying to tase someone
								target_priority_slot = 1
							end
						end
					end

					if is_captain and not is_shielded then
						if alive(managers.groupai:state():phalanx_vip()) then --Winters is in position and buffing enemies
							target_priority_slot = 4
						else
							target_priority_slot = 11
						end
					end
				else
					if has_alerted then
						target_priority_slot = 12
					else
						target_priority_slot = 13
					end
				end

				if is_shielded then
					target_priority = target_priority * 5
				end

				if reaction < AIAttentionObject.REACT_COMBAT then
					target_priority_slot = 14 + target_priority_slot + math.max(0, AIAttentionObject.REACT_COMBAT - reaction)
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

	return best_target, best_target_priority_slot, best_target_reaction
end
