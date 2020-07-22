local mvec3_dot = mvector3.dot
local mvec3_set = mvector3.set
local mvec3_sub = mvector3.subtract
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_dir = mvector3.direction
local mvec3_l_sq = mvector3.length_sq
local mvec3_set_l = mvector3.set_length
local mvec3_add = mvector3.add
local mvec3_rand_orth = mvector3.random_orthogonal

local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local old_group_misc_data = GroupAIStateBase._init_misc_data
function GroupAIStateBase:_init_misc_data()
	old_group_misc_data(self)
	self._special_unit_types = {
		tank = true,
		spooc = true,
		shield = true,
		taser = true,
		boom = true,
		medic = true,
		ass_sniper = true,
		phalanx_minion = true
	}
end

local old_group_base = GroupAIStateBase.on_simulation_started
function GroupAIStateBase:on_simulation_started()
	old_group_base(self)
	self._special_unit_types = {
		tank = true,
		spooc = true,
		shield = true,
		taser = true,
		boom = true,
		medic = true,
		ass_sniper = true,
		phalanx_minion = true
	}
end

function GroupAIStateBase:_check_assault_panic_chatter()
	if self._t and self._last_killed_cop_t and self._t - self._last_killed_cop_t < math.random(1, 3.5) then
		return true
	end
	
	return
end

function GroupAIStateBase:update(t, dt)
	self._t = t

	self:_upd_criminal_suspicion_progress()
	self:_claculate_drama_value()
	--self:_draw_current_logics()
	
	if managers.skirmish:is_skirmish() then
		self._nr_important_cops = self:_get_balancing_multiplier(self._tweak_data.assault.force_balance_7up) * 0.25
	else
		self._nr_important_cops = self:_get_balancing_multiplier(self._tweak_data.assault.force_balance_mul) * 0.25
	end
	
	if self._draw_drama then
		self:_debug_draw_drama(t)
	end

	self:_upd_debug_draw_attentions()
	self:upd_team_AI_distance()
end

function GroupAIStateBase:_draw_current_logics()
	for key, data in pairs(self._police) do
		if data.unit:brain() and data.unit:brain().is_current_logic then
			local brain = data.unit:brain()
			
			if brain:is_current_logic("attack") then
				local draw_duration = 0.1
				local new_brush = Draw:brush(Color.red:with_alpha(1), draw_duration)
				new_brush:sphere(data.unit:movement():m_head_pos(), 20)
			elseif brain:is_current_logic("base") then
				local draw_duration = 0.1
				local new_brush = Draw:brush(Color.white:with_alpha(0.5), draw_duration)
				new_brush:sphere(data.unit:movement():m_head_pos(), 20)
			elseif brain:is_current_logic("idle") then
				local draw_duration = 0.1
				local new_brush = Draw:brush(Color.green:with_alpha(0.5), draw_duration)
				new_brush:sphere(data.unit:movement():m_head_pos(), 20)
			elseif brain:is_current_logic("sniper") then
				local draw_duration = 0.1
				local new_brush = Draw:brush(Color.red:with_alpha(0.1), draw_duration)
				new_brush:sphere(data.unit:movement():m_head_pos(), 20)
			elseif brain:is_current_logic("travel") then
				local draw_duration = 0.1
				local new_brush = Draw:brush(Color.yellow:with_alpha(0.5), draw_duration)
				new_brush:sphere(data.unit:movement():m_head_pos(), 20)
			end
		end
	end
end

function GroupAIStateBase:chk_area_leads_to_enemy(start_nav_seg_id, test_nav_seg_id, enemy_is_criminal)
	local enemy_areas = {}

	for c_key, c_data in pairs(enemy_is_criminal and self._criminals or self._police) do
		enemy_areas[c_data.tracker:nav_segment()] = true
	end

	local all_nav_segs = managers.navigation._nav_segments
	local found_nav_segs = {
		[start_nav_seg_id] = true,
		[test_nav_seg_id] = true
	}
	local to_search_nav_segs = {
		test_nav_seg_id
	}

	repeat
		local chk_nav_seg_id = table.remove(to_search_nav_segs)
		local chk_nav_seg = all_nav_segs[chk_nav_seg_id]

		if enemy_areas[chk_nav_seg_id] then
			--log("executing")
			return true
		end

		local neighbours = chk_nav_seg.neighbours

		for neighbour_seg_id, door_list in pairs(neighbours) do
			if not all_nav_segs[neighbour_seg_id].disabled and not found_nav_segs[neighbour_seg_id] then
				found_nav_segs[neighbour_seg_id] = true

				table.insert(to_search_nav_segs, neighbour_seg_id)
			end
		end
	until #to_search_nav_segs == 0
end

function GroupAIStateBase:on_enemy_unregistered(unit)
	if self:is_unit_in_phalanx_minion_data(unit:key()) then
		self:unregister_phalanx_minion(unit:key())
		CopLogicPhalanxMinion:chk_should_breakup()
		CopLogicPhalanxMinion:chk_should_reposition()
	end

	self._police_force = self._police_force - 1
	local u_key = unit:key()

	self:_clear_character_criminal_suspicion_data(u_key)

	if not Network:is_server() then
		return
	end

	local objective = unit:brain() and unit:brain():objective()

	if objective and objective.fail_clbk then
		local fail_clbk = objective.fail_clbk
		objective.fail_clbk = nil

		fail_clbk(unit)
	end

	local e_data = self._police[u_key]

	if e_data.importance > 0 then
		for c_key, c_data in pairs(self._player_criminals) do
			local imp_keys = c_data.important_enemies

			for i, test_e_key in ipairs(imp_keys) do
				if test_e_key == u_key then
					table.remove(imp_keys, i)
					table.remove(c_data.important_dis, i)

					break
				end
			end
		end
	end

	for crim_key, record in pairs(self._ai_criminals) do
		record.unit:brain():on_cop_neutralized(u_key)
	end

	local unit_type = unit:base()._tweak_table
	local is_special = unit:movement()._tweak_data.is_special_unit

	if self._special_unit_types[unit_type] or is_special then
		if is_special then
			self:unregister_special_unit(u_key, is_special)
		else
			self:unregister_special_unit(u_key, unit_type)
		end
	end

	local dead = unit:character_damage():dead()

	if e_data.group then
		self:_remove_group_member(e_data.group, u_key, dead)
		if dead and self._task_data and self._task_data.assault and self._task_data.assault.active then
			self:_voice_friend_dead(e_data.group)
			self._last_killed_cop_t = self._t
		end
	end

	if e_data.assigned_area and dead then
		local spawn_point = unit:unit_data().mission_element

		if spawn_point then
			local spawn_pos = spawn_point:value("position")
			local u_pos = e_data.m_pos

			if mvector3.distance(spawn_pos, u_pos) < 700 and math.abs(spawn_pos.z - u_pos.z) < 300 then
				local found = nil

				for area_id, area_data in pairs(self._area_data) do
					local area_spawn_points = area_data.spawn_points

					if area_spawn_points then
						for _, sp_data in ipairs(area_spawn_points) do
							if sp_data.spawn_point == spawn_point then
								found = true
								sp_data.delay_t = math.max(sp_data.delay_t, self._t + math.random(30, 60))

								break
							end
						end

						if found then
							break
						end
					end

					local area_spawn_points = area_data.spawn_groups

					if area_spawn_points then
						for _, sp_data in ipairs(area_spawn_points) do
							if sp_data.spawn_point == spawn_point then
								found = true
								sp_data.delay_t = math.max(sp_data.delay_t, self._t + math.random(30, 60))

								break
							end
						end

						if found then
							break
						end
					end
				end
			end
		end
	end
end

function GroupAIStateBase:on_enemy_registered(unit)
	if self._anticipated_police_force > 0 then
		self._anticipated_police_force = self._anticipated_police_force - 1
	else
		self._police_force = self._police_force + 1
	end

	local unit_type = unit:base()._tweak_table
	local is_special = unit:movement()._tweak_data.is_special_unit
	
	if is_special then
		
	end
	if self._special_unit_types[unit_type] or is_special then
		if is_special then
			self:register_special_unit(unit:key(), is_special)
		else
			if unit_type == "phalanx_minion" and not unit:base().is_phalanx then
				self:register_special_unit(unit:key(), "shield")
			else
				self:register_special_unit(unit:key(), unit_type)
			end
		end
	end

	if Network:is_client() then
		unit:movement():set_team(self._teams[tweak_data.levels:get_default_team_ID(unit:base():char_tweak().access == "gangster" and "gangster" or "combatant")])
	end
end

function GroupAIStateBase:unregister_special_unit(u_key, category_name)
	local category = self._special_units[category_name]

	if category_name == "phalanx_minion" and self._special_units["shield"] and self._special_units["shield"][u_key] then
		self._special_units["shield"][u_key] = nil

		if not next(self._special_units["shield"]) then
			self._special_units["shield"] = nil
		end
	else
		if category then
			category[u_key] = nil

			if not next(category) then
				self._special_units[category_name] = nil
			end
		end
	end
end

function GroupAIStateBase:propagate_alert(alert_data)
	if managers.network:session() and Network and not Network:is_server() then
		managers.network:session():send_to_host("propagate_alert", alert_data[1], alert_data[2], alert_data[3], alert_data[4], alert_data[5], alert_data[6])

		return
	end

	local nav_manager = managers.navigation
	local access_func = nav_manager.check_access
	local alert_type = alert_data[1]
	local all_listeners = self._alert_listeners
	local listeners_by_type = all_listeners[alert_type]

	if listeners_by_type then
		local proximity_chk_func = nil
		local alert_epicenter = alert_data[2]

		if alert_epicenter then
			local alert_rad_sq = alert_data[3] * alert_data[3]
			if self._enemy_weapons_hot then
				alert_rad_sq = 4500 * 4500
			end


			function proximity_chk_func(listener_pos)
				return mvec3_dis_sq(alert_epicenter, listener_pos) < alert_rad_sq
			end
		else

			function proximity_chk_func()
				return true
			end
		end

		local alert_filter = alert_data[4]
		local clbks = nil

		for filter_str, listeners_by_type_and_filter in pairs(listeners_by_type) do
			local key, listener = next(listeners_by_type_and_filter, nil)
			local filter_num = listener.filter

			if access_func(nav_manager, filter_num, alert_filter, nil) then
				for id, listener in pairs(listeners_by_type_and_filter) do
					if proximity_chk_func(listener.m_pos) then
						clbks = clbks or {}

						table.insert(clbks, listener.clbk)
					end
				end
			end
		end

		if clbks then
			for _, clbk in ipairs(clbks) do
				clbk(alert_data)
			end
		end
	end
end

function GroupAIStateBase:upd_team_AI_distance()
	if Network:is_server() then
		if self:team_ai_enabled() then
			local far_away_distance = tweak_data.team_ai.stop_action.distance * tweak_data.team_ai.stop_action.distance
			local teleport_distance = tweak_data.team_ai.stop_action.teleport_distance * tweak_data.team_ai.stop_action.teleport_distance

			for _, ai in pairs(self:all_AI_criminals()) do
				local unit = ai.unit

				--make sure the bot hasn't despawned first (I don't know if the table is safe against this so I'm just making sure here)
				if alive(unit) and not unit:movement():cool() then
					local unit_pos = unit:movement()._m_pos --position of the bot
					local closest_distance = nil --distance to the closest player, to be used to compare with the distance limits
					local closest_unit = nil

					for _, player in pairs(self:all_player_criminals()) do
						local player_unit = player.unit

						if alive(player_unit) then --make sure the player's unit hasn't despawned (by leaving the game or being in custody)
							local distance = mvector3.distance_sq(unit_pos, player_unit:position()) --using player.pos is bad because it doesn't get updated in certain situations, like when driving a vehicle

							if not closest_distance or distance < closest_distance then
								closest_distance = distance
								closest_unit = player_unit
							end
						end
					end

					if closest_unit then
						if unit:movement() and unit:movement()._should_stay and closest_distance > far_away_distance then
							unit:movement():set_should_stay(false)

							print("[GroupAIStateBase:update] team ai is too far away, started moving again")
						end

						if not unit:movement():chk_action_forbidden("warp") and not unit:movement():downed() and closest_distance > teleport_distance then
							local allow_teleport = true
							local using_zipline = closest_unit:movement():zipline_unit()
							local state = closest_unit:movement():current_state_name()
							local in_air = nil

							if closest_unit == managers.player:player_unit() then
								in_air = closest_unit:movement():in_air()
							else
								in_air = closest_unit:movement()._in_air
							end

							if using_zipline or state == "jerry1" or state == "jerry2" or state == "driving" or in_air then
								allow_teleport = false
							end

							if allow_teleport then
								local player_tracker = closest_unit:movement():nav_tracker()
								local warp_destination = managers.groupai:state():get_area_from_nav_seg_id(player_tracker:nav_segment())
								local near_cover_point = managers.navigation:find_cover_in_nav_seg_3(warp_destination.nav_segs, 400, player_tracker:field_position())
								local position = near_cover_point and near_cover_point[1] or closest_unit:position()

								local action_desc = {
									body_part = 1,
									type = "warp",
									position = position
								}

								if unit:movement():action_request(action_desc) then
									print("[GroupAIStateBase:update] team ai is too far away, teleported to player")
								end
							end
						end
					end
				end
			end
		end
	end
end

function GroupAIStateBase:_merge_coarse_path_by_area(coarse_path)
	local i_nav_seg = #coarse_path
	local last_area = nil

	while i_nav_seg > 0 do
		if #coarse_path > 2 then
			local nav_seg = coarse_path[i_nav_seg][1]
			local area = self:get_area_from_nav_seg_id(nav_seg)

			if last_area and last_area == area then
				table.remove(coarse_path, i_nav_seg)
			else
				last_area = area
			end
		end

		i_nav_seg = i_nav_seg - 1
	end

	--fug pls (i did it hoxi) 
end

function GroupAIStateBase:queue_smoke_grenade(id, detonate_pos, shooter_pos, duration, ignore_control, flashbang)
	self._smoke_grenades = self._smoke_grenades or {}
	local data = {
		id = id,
		detonate_pos = detonate_pos,
		shooter_pos = shooter_pos,
		duration = duration,
		ignore_control = ignore_control,
		flashbang = flashbang
	}
	self._smoke_grenades[id] = data
end

function GroupAIStateBase:detonate_world_smoke_grenade(id)
	self._smoke_grenades = self._smoke_grenades or {}

	if not self._smoke_grenades[id] then
		--Application:error("Could not detonate smoke grenade as it was not queued!", id)

		return
	end

	local data = self._smoke_grenades[id]

	if data.flashbang then
		if Network:is_client() then
			return
		end

		local det_pos = data.detonate_pos
		local ray_to = mvector3.copy(det_pos) + math.UP * 5

		mvector3.set_z(ray_to, ray_to.z - 50)

		local ground_ray = World:raycast("ray", det_pos, ray_to, "slot_mask", managers.slot:get_mask("world_geometry"))

		if ground_ray then
			det_pos = ground_ray.hit_position
			mvector3.set_z(det_pos, det_pos.z + 3)
			data.detonate_pos = det_pos
		end

		local rotation = Rotation(math.random() * 360, 0, 0)
		local flash_grenade = World:spawn_unit(Idstring("units/payday2/weapons/wpn_frag_flashbang/wpn_frag_flashbang"), det_pos, rotation)
		local shoot_from_pos = data.shooter_pos or det_pos
		flash_grenade:base():activate(shoot_from_pos, data.duration)

		self._smoke_grenades[id] = nil
	else
		data.duration = data.duration == 0 and 15 or data.duration
		local det_pos = data.detonate_pos
		local ray_to = mvector3.copy(det_pos) + math.UP * 5

		mvector3.set_z(ray_to, ray_to.z - 50)

		local ground_ray = World:raycast("ray", det_pos, ray_to, "slot_mask", managers.slot:get_mask("world_geometry"))

		if ground_ray then
			det_pos = ground_ray.hit_position
			mvector3.set_z(det_pos, det_pos.z + 3)
			data.detonate_pos = det_pos
		end

		local rotation = Rotation(math.random() * 360, 0, 0)
		local smoke_grenade = World:spawn_unit(Idstring("units/weapons/smoke_grenade_quick/smoke_grenade_quick"), det_pos, rotation)
		local shoot_from_pos = data.shooter_pos or det_pos
		smoke_grenade:base():activate(shoot_from_pos, data.duration)

		managers.groupai:state():teammate_comment(nil, "g40x_any", det_pos, true, 2000, false)

		data.grenade = smoke_grenade
		self._smoke_end_t = Application:time() + data.duration
	end
end

function GroupAIStateBase:sync_smoke_grenade(detonate_pos, shooter_pos, duration, flashbang)
	self._smoke_grenades = self._smoke_grenades or {}
	local id = #self._smoke_grenades

	self:queue_smoke_grenade(id, detonate_pos, shooter_pos, duration, true, flashbang)
	self:detonate_world_smoke_grenade(id)
end

function GroupAIStateBase:sync_smoke_grenade_kill()
	if self._smoke_grenades then
		for id, data in pairs(self._smoke_grenades) do
			if alive(data.grenade) and data.grenade:base() and data.grenade:base().preemptive_kill then
				data.grenade:base():preemptive_kill()
			end
		end

		self._smoke_grenades = {}
		self._smoke_end_t = nil
	end
end

function GroupAIStateBase:smoke_and_flash_grenades()
	return self._smoke_grenades
end

function GroupAIStateBase:criminal_spotted(unit)
	local u_key = unit:key()
	local u_sighting = self._criminals[u_key]

	u_sighting.undetected = nil
	u_sighting.det_t = self._t

	u_sighting.tracker:m_position(u_sighting.pos)

	local seg = u_sighting.tracker:nav_segment()
	u_sighting.seg = seg

	local prev_area = u_sighting.area
	local area = nil

	if prev_area and prev_area.nav_segs[seg] then
		area = prev_area
	else
		area = self:get_area_from_nav_seg_id(seg)
	end

	if prev_area ~= area then
		u_sighting.area = area

		if prev_area then
			prev_area.criminal.units[u_key] = nil
		end

		area.criminal.units[u_key] = u_sighting
	end

	if area.is_safe then
		area.is_safe = nil

		self:_on_area_safety_status(area, {
			reason = "criminal",
			record = u_sighting
		})
	end
end

function GroupAIStateBase:on_criminal_nav_seg_change(unit, nav_seg_id)
	local u_key = unit:key()
	local u_sighting = self._criminals[u_key]

	if not u_sighting then
		return
	end

	local seg = nav_seg_id
	local prev_area = u_sighting.area
	local area = nil

	if prev_area and prev_area.nav_segs[seg] then
		area = prev_area
	else
		area = self:get_area_from_nav_seg_id(seg)
	end

	if prev_area ~= area then
		u_sighting.area = area

		if prev_area then
			prev_area.criminal.units[u_key] = nil
		end

		area.criminal.units[u_key] = u_sighting
	end
end

function GroupAIStateBase:on_criminal_suspicion_progress(u_suspect, u_observer, status, client_id)
	if not self._ai_enabled or not self._whisper_mode or self._stealth_hud_disabled then
		return
	end

	local ignore_suspicion = u_observer:brain() and u_observer:brain()._ignore_suspicion
	local observer_is_dead = u_observer:character_damage() and u_observer:character_damage():dead()

	if ignore_suspicion or observer_is_dead then
		return
	end

	local obs_key = u_observer:key()

	if managers.groupai:state():all_AI_criminals()[obs_key] then
		return
	end

	local susp_data = self._suspicion_hud_data
	local susp_key = u_suspect and u_suspect:key()

	local function _sync_status(sync_status_code)
		if Network:is_server() and managers.network:session() then
			if client_id then
				managers.network:session():send_to_peers_synched_except(client_id, "suspicion_hud", u_observer, sync_status_code)
			else
				managers.network:session():send_to_peers_synched("suspicion_hud", u_observer, sync_status_code)
			end
		end
	end

	local obs_susp_data = susp_data[obs_key]

	if status == "called" then
		if obs_susp_data then
			if status == obs_susp_data.status then
				return
			else
				obs_susp_data.suspects = nil
			end
		else
			local icon_id = "susp1" .. tostring(obs_key)
			local icon_pos = self._create_hud_suspicion_icon(obs_key, u_observer, "wp_calling_in", tweak_data.hud.suspicion_color, icon_id)
			obs_susp_data = {
				u_observer = u_observer,
				icon_id = icon_id,
				icon_pos = icon_pos
			}
			susp_data[obs_key] = obs_susp_data
		end

		managers.hud:change_waypoint_icon(obs_susp_data.icon_id, "wp_calling_in")
		managers.hud:change_waypoint_arrow_color(obs_susp_data.icon_id, tweak_data.hud.detected_color)

		if obs_susp_data.icon_id2 then
			managers.hud:remove_waypoint(obs_susp_data.icon_id2)

			obs_susp_data.icon_id2 = nil
			obs_susp_data.icon_pos2 = nil
		end

		obs_susp_data.status = "called"
		obs_susp_data.alerted = true
		obs_susp_data.expire_t = self._t + 8
		obs_susp_data.persistent = true

		_sync_status(4)
	elseif status == "calling" then
		if obs_susp_data then
			if status == obs_susp_data.status then
				return
			else
				obs_susp_data.suspects = nil
			end
		else
			local icon_id = "susp1" .. tostring(obs_key)
			local icon_pos = self._create_hud_suspicion_icon(obs_key, u_observer, "wp_calling_in", tweak_data.hud.detected_color, icon_id)
			obs_susp_data = {
				u_observer = u_observer,
				icon_id = icon_id,
				icon_pos = icon_pos
			}
			susp_data[obs_key] = obs_susp_data
		end

		if not obs_susp_data.icon_id2 then
			local hazard_icon_id = "susp2" .. tostring(obs_key)
			local hazard_icon_pos = self._create_hud_suspicion_icon(obs_key, u_observer, "wp_calling_in_hazard", tweak_data.hud.detected_color, hazard_icon_id)
			obs_susp_data.icon_id2 = hazard_icon_id
			obs_susp_data.icon_pos2 = hazard_icon_pos
		end

		managers.hud:change_waypoint_icon(obs_susp_data.icon_id, "wp_calling_in")
		managers.hud:change_waypoint_arrow_color(obs_susp_data.icon_id, tweak_data.hud.detected_color)
		managers.hud:change_waypoint_icon(obs_susp_data.icon_id2, "wp_calling_in_hazard")
		managers.hud:change_waypoint_arrow_color(obs_susp_data.icon_id2, tweak_data.hud.detected_color)

		obs_susp_data.status = "calling"
		obs_susp_data.alerted = true

		_sync_status(3)
	elseif status == true or status == "call_interrupted" then
		if obs_susp_data then
			if obs_susp_data.status == status then
				return
			else
				obs_susp_data.suspects = nil
			end
		else
			local icon_id = "susp1" .. tostring(obs_key)
			local icon_pos = self._create_hud_suspicion_icon(obs_key, u_observer, "wp_detected", tweak_data.hud.detected_color, icon_id)
			obs_susp_data = {
				u_observer = u_observer,
				icon_id = icon_id,
				icon_pos = icon_pos
			}
			susp_data[obs_key] = obs_susp_data
		end

		managers.hud:change_waypoint_icon(obs_susp_data.icon_id, "wp_detected")
		managers.hud:change_waypoint_arrow_color(obs_susp_data.icon_id, tweak_data.hud.detected_color)

		if obs_susp_data.icon_id2 then
			managers.hud:remove_waypoint(obs_susp_data.icon_id2)

			obs_susp_data.icon_id2 = nil
			obs_susp_data.icon_pos2 = nil
		end

		obs_susp_data.status = status
		obs_susp_data.alerted = true

		_sync_status(2)
	elseif not status then
		if obs_susp_data then
			if obs_susp_data.suspects and susp_key then
				obs_susp_data.suspects[susp_key] = nil

				if not next(obs_susp_data.suspects) then
					obs_susp_data.suspects = nil
				end
			end

			if not susp_key or not obs_susp_data.alerted and (not obs_susp_data.suspects or not next(obs_susp_data.suspects)) then
				managers.hud:remove_waypoint(obs_susp_data.icon_id)

				if obs_susp_data.icon_id2 then
					managers.hud:remove_waypoint(obs_susp_data.icon_id2)
				end

				susp_data[obs_key] = nil

				_sync_status(0)
			end
		end
	else
		if obs_susp_data then
			if obs_susp_data.alerted then
				return
			end

			_sync_status(1)
		elseif not obs_susp_data then
			local icon_id = "susp1" .. tostring(obs_key)
			local icon_pos = self._create_hud_suspicion_icon(obs_key, u_observer, "wp_suspicious", tweak_data.hud.suspicion_color, icon_id)
			obs_susp_data = {
				u_observer = u_observer,
				icon_id = icon_id,
				icon_pos = icon_pos
			}
			susp_data[obs_key] = obs_susp_data

			managers.hud:change_waypoint_icon(obs_susp_data.icon_id, "wp_suspicious")
			managers.hud:change_waypoint_arrow_color(obs_susp_data.icon_id, tweak_data.hud.suspicion_color)

			if obs_susp_data.icon_id2 then
				managers.hud:remove_waypoint(obs_susp_data.icon_id2)

				obs_susp_data.icon_id2 = nil
				obs_susp_data.icon_pos2 = nil
			end

			_sync_status(1)
		end

		if susp_key then
			obs_susp_data.suspects = obs_susp_data.suspects or {}

			if obs_susp_data.suspects[susp_key] then
				obs_susp_data.suspects[susp_key].status = status
			else
				obs_susp_data.suspects[susp_key] = {
					status = status,
					u_suspect = u_suspect
				}
			end
		end
	end
end

function GroupAIStateBase:set_whisper_mode(state)
	state = state and true or false

	if state == self._whisper_mode then
		return
	end

	self._whisper_mode = state
	self._whisper_mode_change_t = TimerManager:game():time()

	self:set_ambience_flag()

	if Network:is_server() then
		if state then
			self:chk_register_removed_attention_objects()
		else
			self:chk_unregister_irrelevant_attention_objects()

			if not self._switch_to_not_cool_clbk_id then
				self._switch_to_not_cool_clbk_id = "GroupAI_delayed_not_cool"

				managers.enemy:add_delayed_clbk(self._switch_to_not_cool_clbk_id, callback(self, self, "_clbk_switch_enemies_to_not_cool"), self._t + 1)
			end
		end
	end

	self:_call_listeners("whisper_mode", state)

	if not state then
		self:_clear_criminal_suspicion_data()
	end
end

function GroupAIStateBase:register_AI_attention_object(unit, handler, nav_tracker, team, SO_access)
	local store_instead = nil

	if Network:is_server() and not self:whisper_mode() then
		if not nav_tracker and not unit:vehicle_driving() or unit:in_slot(1) --[[or unit:in_slot(17) and unit:character_damage()]] then
			store_instead = true
		end
	end

	if store_instead then
		local attention_info = {
			unit = unit,
			handler = handler,
			nav_tracker = nav_tracker,
			team = team,
			SO_access = SO_access
		}

		self:store_removed_attention_object(unit:key(), attention_info)

		return
	end

	self._attention_objects.all[unit:key()] = {
		unit = unit,
		handler = handler,
		nav_tracker = nav_tracker,
		team = team,
		SO_access = SO_access
	}

	self:on_AI_attention_changed(unit:key())
end

function GroupAIStateBase:chk_register_removed_attention_objects()
	if not self._removed_attention_objects then
		return
	end

	local all_attention_objects = self:get_all_AI_attention_objects()

	for u_key, att_info in pairs (self._removed_attention_objects) do
		if all_attention_objects[u_key] then
			self._removed_attention_objects[u_key] = nil
		elseif alive(att_info.unit) then
			self:register_AI_attention_object(att_info.unit, att_info.handler, att_info.nav_tracker, att_info.team, att_info.SO_access)
			self._removed_attention_objects[u_key] = nil
		end
	end

	self._removed_attention_objects = nil
end

function GroupAIStateBase:store_removed_attention_object(u_key, attention_info)
	self._removed_attention_objects = self._removed_attention_objects or {}

	self._removed_attention_objects[u_key] = attention_info
end

function GroupAIStateBase:chk_unregister_irrelevant_attention_objects()
	local all_attention_objects = self:get_all_AI_attention_objects()

	for u_key, att_info in pairs (all_attention_objects) do
		if not att_info.nav_tracker and not att_info.unit:vehicle_driving() or att_info.unit:in_slot(1) --[[or att_info.unit:in_slot(17) and att_info.unit:character_damage()]] then
			self:store_removed_attention_object(u_key, att_info)
			att_info.handler:set_attention(nil)
		end
	end
end
