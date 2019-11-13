local mvec3_dot = mvector3.dot
local mvec3_set = mvector3.set
local mvec3_sub = mvector3.subtract
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_dir = mvector3.direction
local mvec3_l_sq = mvector3.length_sq
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

function GroupAIStateBase:set_importance_weight(u_key, wgt_report)
	if #wgt_report == 0 then
		return
	end

	local t_rem = table.remove
	local t_ins = table.insert
	local max_nr_imp = 9000 --no reason to have this
	local imp_adj = 0
	local criminals = self._player_criminals
	local cops = self._police

	for i_dis_rep = #wgt_report - 1, 1, -2 do
		local c_key = wgt_report[i_dis_rep]
		local c_dis = wgt_report[i_dis_rep + 1]
		local c_record = criminals[c_key]
		local imp_enemies = c_record.important_enemies
		local imp_dis = c_record.important_dis
		local was_imp = nil

		for i_imp = #imp_enemies, 1, -1 do
			if imp_enemies[i_imp] == u_key then
				table.remove(imp_enemies, i_imp)
				table.remove(imp_dis, i_imp)

				was_imp = true

				break
			end
		end

		local i_imp = #imp_dis

		while i_imp > 0 do
			if imp_dis[i_imp] <= c_dis then
				break
			end

			i_imp = i_imp - 1
		end

		if i_imp < max_nr_imp then
			i_imp = i_imp + 1

			while max_nr_imp <= #imp_enemies do
				local dump_e_key = imp_enemies[#imp_enemies]

				self:_adjust_cop_importance(dump_e_key, -1)
				t_rem(imp_enemies)
				t_rem(imp_dis)
			end

			t_ins(imp_enemies, i_imp, u_key)
			t_ins(imp_dis, i_imp, c_dis)

			if not was_imp then
				imp_adj = imp_adj + 1
			end
		elseif was_imp then
			imp_adj = imp_adj - 1
		end
	end

	if imp_adj ~= 0 then
		self:_adjust_cop_importance(u_key, imp_adj)
	end
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
	
	if is_special then
		
	end
	
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
	if Network:is_sever() then
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
