local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_dir = mvector3.direction
local mvec3_dot = mvector3.dot
local mvec3_cpy = mvector3.copy
local mvec3_norm = mvector3.normalize

local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()

local m_rot_y = mrotation.y
local m_rot_z = mrotation.z

local math_random = math.random

local tostring_g = tostring
local pairs_g = pairs
local next_g = next

function CopLogicIntimidated.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.brain:cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit,
		detection = data.char_tweak.detection.idle,
		aggressor_unit = enter_params and enter_params.aggressor_unit
	}

	if old_internal_data then
		my_data.firing = old_internal_data.firing
		my_data.turning = old_internal_data.turning
		my_data.shooting = old_internal_data.shooting
		my_data.attention_unit = old_internal_data.attention_unit

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

	if data.objective then
		data.objective_failed_clbk(data.unit, data.objective)

		if my_data ~= data.internal_data then
			return
		end
	end

	if data.cool then
		data.unit:movement():set_cool(false)

		if my_data ~= data.internal_data then
			return
		end
	end

	if my_data.firing then
		my_data.firing = nil

		data.unit:movement():set_allow_fire(false)
	end

	CopLogicIdle._chk_has_old_action(data, my_data)

	local body_part = nil

	if my_data.shooting or data.unit:anim_data().reload then
		if my_data.turning then
			body_part = 1
		else
			body_part = 3
		end
	elseif my_data.turning then
		body_part = 2
	end

	if body_part then
		data.brain:action_request({
			body_part = body_part,
			type = "idle"
		})
	end

	my_data.shooting = nil
	my_data.turning = nil
	my_data.advancing = nil

	data.unit:base():set_slot(data.unit, 22)

	if data.attention_obj then
		CopLogicBase._set_attention_obj(data, nil, nil)
	end

	local current_attention = data.unit:movement():attention()

	if current_attention then
		CopLogicBase._reset_attention(data)
	end

	data.unit:sound():say("s01x", true)

	if data.unit:anim_data().hands_tied then
		CopLogicIntimidated._do_tied(data, my_data.aggressor_unit)
	else
		local sur_break_time = data.char_tweak.surrender_break_time

		if sur_break_time then
			if sur_break_time[1] == sur_break_time[2] then
				my_data.surrender_break_t = data.t + sur_break_time[1]
			else
				my_data.surrender_break_t = data.t + math_random(sur_break_time[1], sur_break_time[2])
			end
		end

		my_data.surrender_clbk_registered = true
		managers.groupai:state():add_to_surrendered(data.unit, callback(CopLogicIntimidated, CopLogicIntimidated, "queued_update", data))

		data.brain:set_update_enabled_state(true)
	end

	my_data.is_hostage = true
	managers.groupai:state():on_hostage_state(true, data.key, true)

	data.brain:set_attention_settings({
		corpse_sneak = true
	})

	managers.network:session():send_to_peers_synched("sync_unit_surrendered", data.unit, true)
end

function CopLogicIntimidated.exit(data, new_logic_name, enter_params)
	CopLogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	CopLogicIntimidated._unregister_rescue_SO(data, my_data)
	CopLogicIntimidated._unregister_harassment_SO(data, my_data)
	CopLogicBase.cancel_delayed_clbks(my_data)

	if my_data.best_cover then
		managers.navigation:release_cover(my_data.best_cover[1])
	end

	if my_data.nearest_cover then
		managers.navigation:release_cover(my_data.nearest_cover[1])
	end

	if new_logic_name ~= "inactive" then
		data.unit:base():set_slot(data.unit, 12)
		data.brain:set_update_enabled_state(true)

		if my_data.set_convert_interact then ----check this
			data.unit:interaction():set_active(false, true, false)
		end
	end

	if my_data.tied then
		managers.groupai:state():on_enemy_untied(data.unit:key())
		managers.groupai:state():unregister_rescueable_hostage(data.key)
	elseif my_data.surrender_clbk_registered then
		managers.groupai:state():remove_from_surrendered(data.unit)
	end

	if my_data.is_hostage then
		managers.groupai:state():on_hostage_state(false, data.key, true)
	end

	managers.network:session():send_to_peers_synched("sync_unit_surrendered", data.unit, false)
end

function CopLogicIntimidated._update_enemy_detection(data, my_data)
	data.t = TimerManager:game():time()

	local exit_intimidated = true

	if not my_data.surrender_break_t or data.t < my_data.surrender_break_t then
		local all_criminals = managers.groupai:state():all_criminals()

		if next_g(all_criminals) then
			local mov_ext = data.unit:movement()
			local my_tracker = mov_ext:nav_tracker()
			local my_head_pos = mov_ext:m_head_pos()
			local chk_vis_func = my_tracker.check_visibility
			local vis_slot_mask = data.visibility_slotmask
			local shout_chk_range = tweak_data.player.long_dis_interaction.intimidate_range_enemies * tweak_data.upgrades.values.player.intimidate_range_mul[1] * 1.05

			for u_key, u_data in pairs_g(all_criminals) do
				if not u_data.is_deployable and chk_vis_func(my_tracker, u_data.tracker) then
					local crim_unit = u_data.unit
					local crim_head_pos = u_data.m_det_pos
					local crim_to_unit_vec = tmp_vec1
					local distance = mvec3_dir(crim_to_unit_vec, crim_head_pos, my_head_pos)

					if distance < shout_chk_range then
						mvec3_norm(crim_to_unit_vec)
						local crim_fwd = tmp_vec2

						if crim_unit:base().is_husk_player then
							mvec3_set(crim_fwd, crim_unit:movement():detect_look_dir())
						else
							if crim_unit:base().is_local_player then
								m_rot_y(crim_unit:movement():m_head_rot(), crim_fwd)
							else
								m_rot_z(crim_unit:movement():m_head_rot(), crim_fwd)
							end

							mvec3_norm(crim_fwd)
						end

						if mvec3_dot(crim_fwd, crim_to_unit_vec) > 0.65 then
							local obstructed = data.unit:raycast("ray", my_head_pos, crim_head_pos, "slot_mask", vis_slot_mask, "ray_type", "ai_vision", "report")

							if not obstructed then
								exit_intimidated = nil

								break
							end
						end
					end
				end
			end
		end
	end

	if exit_intimidated then
		my_data.surrender_clbk_registered = nil

		data.brain:set_objective(nil)

		if my_data ~= data.internal_data then
			return
		end

		local wanted_state = data.logic._get_logic_state_from_reaction(data) or "idle"

		CopLogicBase._exit(data.unit, wanted_state)
	end
end

function CopLogicIntimidated.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action:type()

	if action_type == "act" and my_data.act_action then
		my_data.act_action = nil
	elseif action_type == "hurt" and my_data.being_harassed then
		my_data.being_harassed = nil

		CopLogicIntimidated._add_delayed_rescue_SO(data, my_data)
	end

	data.unit:brain():set_update_enabled_state(true)
end

function CopLogicIntimidated.update(data)
	--data.t = TimerManager:game():time()
	local anim_data = data.unit:anim_data()

	if anim_data.hands_tied then
		data.brain:set_update_enabled_state(false)

		local my_data = data.internal_data

		if not my_data.tied then
			CopLogicIntimidated._do_tied(data, my_data.aggressor_unit)
		end

		return
	elseif anim_data.surrender then--or anim_data.hands_up or anim_data.hands_back then
		return
	end

	if anim_data.idle or not data.unit:movement():chk_action_forbidden("walk") then
		CopLogicIntimidated._start_action_hands_up(data)
	end
end

function CopLogicIntimidated.on_intimidated(data, amount, aggressor_unit)
	local my_data = data.internal_data

	if my_data.tied then
		return
	end

	local sur_break_time = data.char_tweak.surrender_break_time

	if sur_break_time then
		local sur_time = nil

		if sur_break_time[1] == sur_break_time[2] then
			sur_time = TimerManager:game():time() + sur_break_time[1]
		else
			sur_time = TimerManager:game():time() + math_random(sur_break_time[1], sur_break_time[2])
		end

		if not my_data.surrender_break_t or my_data.surrender_break_t < sur_time then
			my_data.surrender_break_t = sur_time
		end
	end

	local anim_data = data.unit:anim_data()

	--if not anim_data.idle then ----nav_links get interrupted mid-animation still, fix
		if not anim_data.surrender and --[[not anim_data.hands_up and not anim_data.hands_back and]] data.unit:movement():chk_action_forbidden("walk") then
			return
		end
	--end

	local anim, blocks, align_sync, clamp_to_graph = nil

	if anim_data.hands_up then
		anim = "hands_back"
		blocks = {
			heavy_hurt = -1,
			hurt_sick = -1,
			hurt = -1,
			action = -1,
			light_hurt = -1,
			walk = -1
		}
	elseif anim_data.hands_back then
		anim = "tied"
		blocks = {
			heavy_hurt = -1,
			hurt_sick = -1,
			action = -1,
			light_hurt = -1,
			hurt = -1,
			walk = -1
		}
	else
		if managers.groupai:state():whisper_mode() then
			anim = "tied_all_in_one"
		else
			anim = "hands_up"
			clamp_to_graph = true
		end

		blocks = {
			heavy_hurt = -1,
			hurt_sick = -1,
			hurt = -1,
			action = -1,
			light_hurt = -1,
			walk = -1
		}

		align_sync = true
	end

	local action_data = {
		clamp_to_graph = clamp_to_graph,
		align_sync = align_sync,
		type = "act",
		body_part = 1,
		variant = anim,
		blocks = blocks
	}
	my_data.act_action = data.brain:action_request(action_data)

	if my_data.act_action and data.unit:anim_data().hands_tied then
		CopLogicIntimidated._do_tied(data, aggressor_unit)
	end
end

function CopLogicIntimidated._register_harassment_SO(data, my_data)
	local objective_rot = data.unit:rotation()
	local objective_pos = data.unit:position() - objective_rot:y() * 100
	local my_tracker = data.unit:movement():nav_tracker()
	local ray_params = {
		allow_entry = false,
		tracker_from = my_tracker,
		pos_to = objective_pos
	}

	if managers.navigation:raycast(ray_params) then
		return
	end

	local objective = {
		stance = "hos",
		interrupt_health = 0.85,
		type = "act",
		scan = true,
		interrupt_dis = 700,
		pos = objective_pos,
		rot = objective_rot,
		nav_seg = data.unit:movement():nav_tracker():nav_segment(),
		action_start_clbk = callback(CopLogicIntimidated, CopLogicIntimidated, "on_harassment_SO_action_start", data),
		fail_clbk = callback(CopLogicIntimidated, CopLogicIntimidated, "on_harassment_SO_failed", data),
		action = {
			variant = "e_so_try_kick_door",
			body_part = 1,
			type = "act",
			blocks = {
				action = -1,
				walk = -1
			}
		}
	}
	--"e_nl_kick_enter",
	--"e_nl_kick_enter_special",
	--"e_nl_up_4m_wall_kick",
	--"e_so_try_kick_door",
	--"e_so_low_kicks",
	--"e_so_container_kick",
	local so_descriptor = {
		interval = 5,
		search_dis_sq = 2250000,
		AI_group = "friendlies",
		base_chance = 1,
		chance_inc = 0,
		usage_amount = 1,
		objective = objective,
		search_pos = mvec3_cpy(data.m_pos),
		admin_clbk = callback(CopLogicIntimidated, CopLogicIntimidated, "on_harassment_SO_administered", data),
		verification_clbk = callback(CopLogicIntimidated, CopLogicIntimidated, "harassment_SO_verification", data)
	}
	local so_id = "harass" .. tostring_g(data.unit:key())
	my_data.harassment_SO_id = so_id

	managers.groupai:state():add_special_objective(so_id, so_descriptor)
end

function CopLogicIntimidated.on_harassment_SO_administered(ignore_this, data, receiver_unit)
	local my_data = data.internal_data
	my_data.harassment_SO_id = nil
	my_data.harraser = receiver_unit
end

function CopLogicIntimidated.harassment_SO_verification(ignore_this, data, unit)
	if unit:movement():cool() then
		return false
	end

	return true
end

function CopLogicIntimidated.on_harassment_SO_action_start(ignore_this, data, receiver_unit)
	local my_data = data.internal_data
	my_data.being_harassed = data.unit:movement():play_state("std/surrender/hands_tied/harassed/kicked_from_behind")

	if my_data.being_harassed then
		managers.groupai:state():on_occasional_event("cop_harassment")
		CopLogicIntimidated._unregister_rescue_SO(data, my_data)
	end
end

function CopLogicIntimidated.on_harassment_SO_failed(ignore_this, data, receiver_unit)
	local my_data = data.internal_data

	my_data.harraser = nil

	if my_data.being_harassed then
		local action_data = {
			variant = "tied",
			body_part = 1,
			type = "act",
			blocks = {
				heavy_hurt = -1,
				hurt_sick = -1,
				hurt = -1,
				action = -1,
				light_hurt = -1,
				walk = -1
			}
		}

		my_data.act_action = data.brain:action_request(action_data)

		my_data.being_harassed = nil
	end
end

function CopLogicIntimidated._unregister_harassment_SO(data, my_data)
	local my_data = data.internal_data

	if my_data.harraser then
		local harraser = my_data.harraser
		my_data.harraser = nil

		managers.groupai:state():on_objective_failed(harraser, harraser:brain():objective())
	elseif my_data.harassment_SO_id then
		managers.groupai:state():remove_special_objective(my_data.harassment_SO_id)

		my_data.harassment_SO_id = nil
	end
end

function CopLogicIntimidated._do_tied(data, aggressor_unit)
	local my_data = data.internal_data

	if my_data.tied then
		return
	end

	my_data.tied = true

	aggressor_unit = alive(aggressor_unit) and aggressor_unit

	managers.groupai:state():on_enemy_tied(data.unit:key())
	managers.groupai:state():register_rescueable_hostage(data.unit, nil)

	if managers.groupai:state():rescue_state() then
		CopLogicIntimidated._add_delayed_rescue_SO(data, my_data)
		--CopLogicIntimidated._register_harassment_SO(data, my_data)
	end

	if my_data.surrender_clbk_registered then
		managers.groupai:state():remove_from_surrendered(data.unit)

		my_data.surrender_clbk_registered = nil
	end

	if my_data.update_task_key then
		managers.enemy:unqueue_task(my_data.update_task_key)

		my_data.update_task_key = nil
	end

	data.brain:set_update_enabled_state(false)
	data.unit:inventory():destroy_all_items()
	managers.network:session():send_to_peers_synched("sync_unit_event_id_16", data.unit, "brain", HuskCopBrain._NET_EVENTS.surrender_destroy_all_items) ----

	data.brain:rem_pos_rsrv("stand")

	if my_data.best_cover then
		managers.navigation:release_cover(my_data.best_cover[1])

		my_data.best_cover = nil
	end

	if my_data.nearest_cover then
		managers.navigation:release_cover(my_data.nearest_cover[1])

		my_data.nearest_cover = nil
	end

	--CopLogicIntimidated._chk_begin_alarm_pager(data)

	if not data.brain:is_pager_started() and not managers.groupai:state():whisper_mode() then
		my_data.set_convert_interact = true

		data.unit:interaction():set_tweak_data("hostage_convert")
		data.unit:interaction():set_active(true, true, false)
	end

	if data.unit:unit_data().mission_element then
		data.unit:unit_data().mission_element:event("tied", data.unit)
	end

	data.unit:character_damage():drop_pickup()
	data.unit:character_damage():set_pickup(nil)

	if aggressor_unit then
		if aggressor_unit == managers.player:player_unit() then
			managers.statistics:tied({
				name = data.unit:base()._tweak_table
			})
		elseif aggressor_unit:base() and aggressor_unit:base().is_husk_player then
			aggressor_unit:network():send_to_unit({
				"statistics_tied",
				data.unit:base()._tweak_table
			})
		end
	end

	managers.groupai:state():on_criminal_suspicion_progress(nil, data.unit, nil)
end

function CopLogicIntimidated.on_enemy_weapons_hot(data)
	local my_data = data.internal_data

	if not my_data.tied or my_data.set_convert_interact then
		return
	end

	my_data.set_convert_interact = true

	data.unit:interaction():set_tweak_data("hostage_convert")
	data.unit:interaction():set_active(true, true, false)
end

function CopLogicIntimidated.on_alert(data, alert_data)
	local alert_unit = alert_data[5]

	if not alive(alert_unit) or not alert_unit:in_slot(data.enemy_slotmask) or CopLogicBase._chk_alert_obstructed(data.unit:movement():m_head_pos(), alert_data) then
		return
	end

	local att_obj_data, is_new = CopLogicBase.identify_attention_obj_instant(data, alert_unit:key())

	if not att_obj_data then
		return
	end

	local alert_type = alert_data[1]
	local alert_is_dangerous = CopLogicBase.is_alert_dangerous(alert_type)

	if alert_is_dangerous then
		att_obj_data.alert_t = TimerManager:game():time()
	end

	if att_obj_data.criminal_record then
		managers.groupai:state():criminal_spotted(alert_unit)

		if alert_is_dangerous then
			managers.groupai:state():report_aggression(alert_unit)
		end
	end
end

function CopLogicIntimidated._add_delayed_rescue_SO(data, my_data)
	if data.char_tweak.flee_type == "hide" or data.unit:unit_data() and data.unit:unit_data().not_rescued then
		return
	end

	if my_data.delayed_clbks and my_data.delayed_clbks[my_data.delayed_rescue_SO_id] then
		managers.enemy:reschedule_delayed_clbk(my_data.delayed_rescue_SO_id, TimerManager:game():time() + 10)
	else
		if my_data.rescuer then
			local objective = my_data.rescuer:brain():objective()
			local rescuer = my_data.rescuer
			my_data.rescuer = nil

			managers.groupai:state():on_objective_failed(rescuer, objective)
		elseif my_data.rescue_SO_id then
			managers.groupai:state():remove_special_objective(my_data.rescue_SO_id)

			my_data.rescue_SO_id = nil
		end

		my_data.delayed_rescue_SO_id = "rescue" .. tostring_g(data.unit:key())

		CopLogicBase.add_delayed_clbk(my_data, my_data.delayed_rescue_SO_id, callback(CopLogicIntimidated, CopLogicIntimidated, "register_rescue_SO", data), TimerManager:game():time() + 10)
	end
end

function CopLogicIntimidated.register_rescue_SO(ignore_this, data)
	local my_data = data.internal_data

	CopLogicBase.on_delayed_clbk(my_data, my_data.delayed_rescue_SO_id)

	my_data.delayed_rescue_SO_id = nil
	local my_tracker = data.unit:movement():nav_tracker()
	local objective_pos = my_tracker:field_position()
	local followup_objective = {
		scan = true,
		type = "act",
		stance = "hos",
		action = {
			variant = "idle",
			body_part = 1,
			type = "act",
			blocks = {
				action = -1,
				walk = -1
			}
		},
		action_duration = tweak_data.interaction.free.timer
	}
	local objective = {
		interrupt_health = 0.85,
		stance = "hos",
		type = "act",
		scan = true,
		destroy_clbk_key = false,
		interrupt_dis = 700,
		follow_unit = data.unit,
		pos = mvec3_cpy(objective_pos),
		nav_seg = data.unit:movement():nav_tracker():nav_segment(),
		fail_clbk = callback(CopLogicIntimidated, CopLogicIntimidated, "on_rescue_SO_failed", data),
		complete_clbk = callback(CopLogicIntimidated, CopLogicIntimidated, "on_rescue_SO_completed", data),
		action = {
			variant = "untie",
			body_part = 1,
			type = "act",
			blocks = {
				action = -1,
				walk = -1
			}
		},
		action_duration = tweak_data.interaction.free.timer,
		followup_objective = followup_objective
	}
	local so_descriptor = {
		interval = 10,
		search_dis_sq = 1000000,
		AI_group = "enemies",
		base_chance = 1,
		chance_inc = 0,
		usage_amount = 1,
		objective = objective,
		search_pos = mvec3_cpy(data.m_pos),
		admin_clbk = callback(CopLogicIntimidated, CopLogicIntimidated, "on_rescue_SO_administered", data),
		verification_clbk = callback(CopLogicIntimidated, CopLogicIntimidated, "rescue_SO_verification", data)
	}
	local so_id = "rescue" .. tostring_g(data.unit:key())
	my_data.rescue_SO_id = so_id

	managers.groupai:state():add_special_objective(so_id, so_descriptor)
end

function CopLogicIntimidated.rescue_SO_verification(ignore_this, data, unit)
	return unit:base():char_tweak().rescue_hostages and not unit:movement():cool() and not data.team.foes[unit:movement():team().id] ----add act action check
end

function CopLogicIntimidated._unregister_rescue_SO(data, my_data)
	if my_data.rescuer then
		local objective = my_data.rescuer:brain():objective()
		local rescuer = my_data.rescuer
		my_data.rescuer = nil

		managers.groupai:state():on_objective_failed(rescuer, objective)
	elseif my_data.rescue_SO_id then
		managers.groupai:state():remove_special_objective(my_data.rescue_SO_id)

		my_data.rescue_SO_id = nil
	elseif my_data.delayed_rescue_SO_id then
		CopLogicBase.chk_cancel_delayed_clbk(my_data, my_data.delayed_rescue_SO_id)

		my_data.delayed_rescue_SO_id = nil
	end
end

function CopLogicIntimidated.on_rescue_SO_failed(ignore_this, data)
	local my_data = data.internal_data

	if my_data.rescuer then
		my_data.rescuer = nil

		CopLogicIntimidated._add_delayed_rescue_SO(data, my_data)
	end
end

function CopLogicIntimidated.on_rescue_SO_completed(ignore_this, data, good_pig)
	local inventory_ext = data.unit:inventory()

	if not inventory_ext:equipped_unit() then
		if inventory_ext:num_selections() <= 0 then
			local weap_name = data.unit:base():default_weapon_name()

			if weap_name then
				inventory_ext:add_unit_by_name(weap_name, true, true)
			end
		else
			inventory_ext:equip_selection(1, true)
		end
	end

	if data.unit:anim_data().hands_tied then
		local new_action = {
			variant = "stand",
			body_part = 1,
			type = "act"
		}

		data.unit:brain():action_request(new_action)
	else
		local new_action = {
			body_part = 1,
			type = "idle"
		}

		data.unit:brain():action_request(new_action)
	end

	--[[local objective = data.objective

	if objective then
		if objective.nav_seg or objective.type == "follow" then
			objective.in_place = true
		end
	end]]

	local my_data = data.internal_data

	data.brain:set_objective(nil)

	if my_data ~= data.internal_data then
		return
	end

	local wanted_state = data.logic._get_logic_state_from_reaction(data) or "idle"

	CopLogicBase._exit(data.unit, wanted_state)
end

function CopLogicIntimidated.anim_clbk(data, event_type)
	local my_data = data.internal_data

	if event_type == "harass_end" and my_data.being_harassed then
		my_data.being_harassed = nil

		if managers.groupai:state():rescue_state() then
			CopLogicIntimidated._add_delayed_rescue_SO(data, data.internal_data)
		end
	end
end

function CopLogicIntimidated._start_action_hands_up(data)
	local my_data = data.internal_data
	local anim_name = managers.groupai:state():whisper_mode() and "tied_all_in_one" or "hands_up"
	local action_data = {
		clamp_to_graph = true,
		align_sync = true,
		type = "act",
		body_part = 1,
		variant = anim_name,
		blocks = {
			heavy_hurt = -1,
			hurt_sick = -1,
			hurt = -1,
			action = -1,
			light_hurt = -1,
			walk = -1
		}
	}
	my_data.act_action = data.brain:action_request(action_data)

	if my_data.act_action and data.unit:anim_data().hands_tied then
		CopLogicIntimidated._do_tied(data, my_data.aggressor_unit)
	end
end

function CopLogicIntimidated._chk_begin_alarm_pager(data)
	if not managers.groupai:state():whisper_mode() then
		return
	end

	local u_data = data.unit:unit_data()

	if not u_data or not u_data.has_alarm_pager then
		return
	end

	data.brain:begin_alarm_pager()
end
