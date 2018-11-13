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
		ass_sniper = true
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
		ass_sniper = true
	}
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

-- Lines: 1450 to 1465
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
			self:register_special_unit(unit:key(), unit_type)
		end
	end

	if Network:is_client() then
		unit:movement():set_team(self._teams[tweak_data.levels:get_default_team_ID(unit:base():char_tweak().access == "gangster" and "gangster" or "combatant")])
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

local _is_loud

local fs_groupaistatebase_converthostagetocriminal = GroupAIStateBase.convert_hostage_to_criminal
function GroupAIStateBase:convert_hostage_to_criminal(unit, ...)
	local ret = fs_groupaistatebase_converthostagetocriminal(self, unit, ...)
	self:on_AI_attention_changed(unit:key())
	return ret
end

local fs_original_groupaistatebase_onenemyweaponshot = GroupAIStateBase.on_enemy_weapons_hot
function GroupAIStateBase:on_enemy_weapons_hot(...)
	local enemy_weapons_hot = self._enemy_weapons_hot

	fs_original_groupaistatebase_onenemyweaponshot(self, ...)

	_is_loud = true
	if not enemy_weapons_hot then
		for k, v in pairs(self._attention_objects) do
			if k ~= 'all' then
				self._attention_objects[k] = nil
			end
		end

		for _, fct in pairs(FullSpeedSwarm.call_on_loud) do
			fct()
		end
	end
end

local _cop_ctgs = {}
local function _build_cop_ctgs()
	for name, data in pairs(tweak_data.character) do
		if type(data) == 'table' and data.tags then
			if type(data.tags) == 'table' and table.contains(data.tags, 'law') then
				_cop_ctgs[name] = true
			end
		end
	end
end
_build_cop_ctgs()
DelayedCalls:Add('DelayedModFSS_buildcopctgs', 0, function()
	-- Do it again in case another mod added new cop types
	_build_cop_ctgs()
end)

local function _requires_attention(cat_filter, att_info)
	if not att_info then
		return false
	end

	local unit = att_info.unit
	local aiub = unit and unit:base()
	if not aiub then
		if _is_loud then
			return false
		else
			return not not unit:carry_data()
		end
	end

	if _is_loud then
		if not att_info.nav_tracker then
			return false

		else
			local slot = unit:slot()
			if cat_filter == 'teamAI1' then
				if slot == 21 or slot == 22 then
					return false
				elseif aiub.is_local_player then
					return unit:character_damage():need_revive()
				elseif aiub.is_husk_player then
					return unit:movement():need_revive()
				elseif aiub._type == 'swat_turret' then
					return true
				end
				return slot == 12 or slot == 33 -- enemies

			elseif _cop_ctgs[cat_filter] then
				if slot ~= 16 and _cop_ctgs[aiub._tweak_table] then -- not jokers
					return false
				elseif slot == 21 or slot == 22 then -- civilians 21, hostages 22
					return false
				end
			end
		end

	elseif cat_filter == 'teamAI1' then
		return false
	elseif aiub.is_local_player or aiub.is_husk_player then
		return true
	elseif aiub.security_camera then
		return aiub._destroyed
	elseif unit:character_damage() and unit:character_damage():dead() then
		return true
	elseif unit:movement() then
		return not unit:movement()._cool
	end

	return true
end

local _cf = {}
function GroupAIStateBase:on_AI_attention_changed(unit_key)
	local attention_objects = self._attention_objects
	local att_info = attention_objects.all[unit_key]
	local attention_handler
	if att_info then
		attention_handler = att_info.handler
		attention_handler.rel_cache = {}
	end

	local navigation = managers.navigation
	for cat_filter, list in pairs(attention_objects) do
		if cat_filter ~= 'all' then
			_cf[1] = cat_filter
			if attention_handler and attention_handler:get_attention(navigation:convert_access_filter_to_number(_cf)) then
				list[unit_key] = _requires_attention(cat_filter, att_info) and att_info or nil
			else
				list[unit_key] = nil
			end
		end
	end
end

function GroupAIStateBase:get_AI_attention_objects_by_filter(filter, team)
	local real_filter = team and team.id == 'converted_enemy' and 'teamAI1' or filter

	local result = self._attention_objects[real_filter]
	if not result then
		_cf[1] = real_filter
		local filter_num = managers.navigation:convert_access_filter_to_number(_cf)
		result = {}
		for u_key, attention_info in pairs(self._attention_objects.all) do
			if attention_info.handler:get_attention(filter_num) then
				if _requires_attention(real_filter, attention_info) then
					result[u_key] = attention_info
				end
			end
		end
		self._attention_objects[real_filter] = result
	end

	return result
end

function GroupAIStateBase.on_unit_detection_updated()
end

function GroupAIStateBase:chk_enemy_calling_in_area(area, except_key)
	local area_nav_segs = area.nav_segs
	for unit_key, v in pairs(FullSpeedSwarm.in_arrest_logic) do
		if v and unit_key ~= except_key then
			local u_data = self._police[unit_key]
			if u_data and area_nav_segs[u_data.tracker:nav_segment()] then
				return true
			end
		end
	end
end

function GroupAIStateBase:criminal_spotted(unit)
	local u_key = unit:key()
	local u_sighting = self._criminals[u_key]
	if u_sighting.det_t == self._t then
		return
	end
	local prev_seg = u_sighting.seg
	local prev_area = u_sighting.area
	local seg = u_sighting.tracker:nav_segment()
	u_sighting.undetected = nil
	u_sighting.seg = seg
	u_sighting.tracker:m_position(u_sighting.pos)
	u_sighting.det_t = self._t
	local area = prev_area and prev_area.nav_segs[seg] and prev_area or self:get_area_from_nav_seg_id(seg)
	if prev_area ~= area then
		u_sighting.area = area
		if prev_area then
			prev_area.criminal.units[u_key] = nil
		end
		area.criminal.units[u_key] = u_sighting
	end
	if area.is_safe then
		area.is_safe = nil
		self:_on_area_safety_status(area, {reason = 'criminal', record = u_sighting})
	end
end

local fs_original_groupaistatebase_creategroup = GroupAIStateBase._create_group
function GroupAIStateBase:_create_group(...)
	local result = fs_original_groupaistatebase_creategroup(self, ...)
	result.attention_obj_identified_t = {}
	return result
end

local table_insert = table.insert
function GroupAIStateBase:set_importance_weight(u_key, wgt_report)
	local max_nr_imp = self._nr_important_cops
	local imp_adj = 0
	local criminals = self._player_criminals

	for i_dis_rep = #wgt_report - 1, 1, -2 do
		local c_record = criminals[wgt_report[i_dis_rep]]
		local c_dis = wgt_report[i_dis_rep + 1]
		local imp_enemies = c_record.important_enemies
		local imp_dis = c_record.important_dis
		-- original function sorts the tables by distance but it does not seem to be useful anywhere
		local max_dis = -1
		local max_i = 1

		local imp_enemies_nr = #imp_enemies
		for i = 1, imp_enemies_nr do
			if imp_enemies[i] == u_key then
				imp_dis[i] = c_dis
				max_i = nil
				break
			else
				local imp_dis_i = imp_dis[i]
				if imp_dis_i > max_dis then
					max_dis = imp_dis_i
					max_i = i
				end
			end
		end

		if max_i then
			if imp_enemies_nr < max_nr_imp then
				table_insert(imp_enemies, u_key)
				table_insert(imp_dis, c_dis)
				imp_adj = imp_adj + 1
			elseif max_dis > c_dis then
				self:_adjust_cop_importance(imp_enemies[max_i], -1)
				imp_enemies[max_i] = u_key
				imp_dis[max_i] = c_dis
				imp_adj = imp_adj + 1
			end
		end
	end

	if imp_adj ~= 0 then
		self:_adjust_cop_importance(u_key, imp_adj)
	end
end

local _fs_cache_areas_from_nav_seg_id = {}

local fs_original_groupaistatebase_addarea = GroupAIStateBase.add_area
function GroupAIStateBase:add_area(...)
	_fs_cache_areas_from_nav_seg_id = {}
	return fs_original_groupaistatebase_addarea(self, ...)
end

local fs_original_groupaistatebase_getareasfromnavsegid = GroupAIStateBase.get_areas_from_nav_seg_id
function GroupAIStateBase:get_areas_from_nav_seg_id(nav_seg_id)
	local areas = _fs_cache_areas_from_nav_seg_id[nav_seg_id]

	if not areas then
		areas = fs_original_groupaistatebase_getareasfromnavsegid(self, nav_seg_id)
		_fs_cache_areas_from_nav_seg_id[nav_seg_id] = areas
	end

	return areas
end

local fs_original_groupaistatebase_onhostagestate = GroupAIStateBase.on_hostage_state
function GroupAIStateBase:on_hostage_state(state, key, ...)
	fs_original_groupaistatebase_onhostagestate(self, state, key, ...)

	local attention_data = self._attention_objects.all[key]
	local unit = attention_data and attention_data.unit
	if alive(unit) then
		unit:movement().move_speed_multiplier = state and tweak_data.character[unit:base()._tweak_table].hostage_move_speed or 1
		managers.network:session():send_to_peers_synched('sync_unit_event_id_16', unit, 'brain', state and 3 or 4)
	end
end

local fs_original_groupaistatebase_synchostageheadcount = GroupAIStateBase.sync_hostage_headcount
function GroupAIStateBase:sync_hostage_headcount(...)
	managers.player:reset_cached_hostage_bonus_multiplier()
	fs_original_groupaistatebase_synchostageheadcount(self, ...)
end

local fs_original_groupaistatebase_addarea = GroupAIStateBase.add_area
function GroupAIStateBase:add_area(area_id, nav_segs, area_pos)
	fs_original_groupaistatebase_addarea(self, area_id, nav_segs, area_pos)
	self:fs_create_neighbours_rev()
end

local fs_original_groupaistatebase_createareadata = GroupAIStateBase._create_area_data
function GroupAIStateBase:_create_area_data()
	fs_original_groupaistatebase_createareadata(self)
	self:fs_create_neighbours_rev()
end

local fs_original_groupaistatebase_onnavsegmentstatechange = GroupAIStateBase.on_nav_segment_state_change
function GroupAIStateBase:on_nav_segment_state_change(changed_seg_id, state)
	fs_original_groupaistatebase_onnavsegmentstatechange(self, changed_seg_id, state)
	self:fs_create_neighbours_rev()
end

local fs_original_groupaistatebase_onnavsegneighbourstate = GroupAIStateBase.on_nav_seg_neighbour_state
function GroupAIStateBase:on_nav_seg_neighbour_state(start_seg_id, end_seg_id, state)
	fs_original_groupaistatebase_onnavsegneighbourstate(self, start_seg_id, end_seg_id, state)
	self:fs_create_neighbours_rev()
end

local fs_original_groupaistatebase_onnavsegneighboursstate = GroupAIStateBase.on_nav_seg_neighbours_state
function GroupAIStateBase:on_nav_seg_neighbours_state(changed_seg_id, neighbours, state)
	fs_original_groupaistatebase_onnavsegneighboursstate(self, changed_seg_id, neighbours, state)
	self:fs_create_neighbours_rev()
end

function GroupAIStateBase:fs_create_neighbours_rev()
	local all_areas = self._area_data
	for area_id, area in pairs(all_areas) do
		area.neighbours_rev = {}
	end

	for area_id, area in pairs(all_areas) do
		for other_id, other_area in pairs(area.neighbours) do
			other_area.neighbours_rev[area_id] = area
		end
	end
end
