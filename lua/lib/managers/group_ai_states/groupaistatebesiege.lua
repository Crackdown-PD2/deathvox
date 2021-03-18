local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_set_zero = mvector3.set_zero
local mvec3_step = mvector3.step
local mvec3_lerp = mvector3.lerp
local mvec3_add = mvector3.add
local mvec3_divide = mvector3.divide
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_cpy = mvector3.copy
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_vec3 = Vector3()

local math_up = math.UP
local math_lerp = math.lerp
local math_random = math.random
local math_clamp = math.clamp
local math_max = math.max

local pairs_g = pairs
local next_g = next

local table_insert = table.insert
local table_remove = table.remove

function GroupAIStateBesiege:init(group_ai_state)
	GroupAIStateBesiege.super.init(self)

	if Network:is_server() and managers.navigation:is_data_ready() then
		self:_queue_police_upd_task()
	end

	self._tweak_data = tweak_data.group_ai[group_ai_state]
	self._spawn_group_timers = {}
	self._graph_distance_cache = {}
	--self:set_debug_draw_state(true) --Uncomment to debug AI stuff.
end

function GroupAIStateBesiege:_draw_enemy_activity(t)
	local camera = managers.viewport:get_current_camera()

	if not camera then
		return
	end

	local draw_data = self._AI_draw_data
	local brush_area = draw_data.brush_area
	local area_normal = -math_up
	local logic_name_texts = draw_data.logic_name_texts
	local group_id_texts = draw_data.group_id_texts
	local panel = draw_data.panel
	local ws = draw_data.workspace
	local mid_pos1 = tmp_vec1
	local mid_pos2 = tmp_vec2
	local focus_enemy_pen = draw_data.pen_focus_enemy
	local focus_player_brush = draw_data.brush_focus_player
	local suppr_period = 0.4
	local suppr_t = t % suppr_period

	if suppr_t > suppr_period * 0.5 then
		suppr_t = suppr_period - suppr_t
	end

	draw_data.brush_suppressed:set_color(Color(math_lerp(0.2, 0.5, suppr_t), 0.85, 0.9, 0.2))

	for area_id, area in pairs_g(self._area_data) do
		if next_g(area.police.units) then
			brush_area:half_sphere(area.pos, 22, area_normal)
		end
	end

	local res_x = RenderSettings.resolution.x
	local res_y = RenderSettings.resolution.y

	local function _f_draw_logic_name(u_key, l_data, draw_color)
		local logic_name_text = logic_name_texts[u_key]
		local text_str = l_data.name

		if l_data.objective then
			text_str = text_str .. ":" .. l_data.objective.type
		end

		if not l_data.group and l_data.team then
			text_str = l_data.team.id .. ":" .. text_str
		end

		if l_data.spawned_in_phase then
			text_str = text_str .. ":" .. l_data.spawned_in_phase
		end

		local unit = l_data.unit
		--[[local anim_machine = unit:anim_state_machine()

		if anim_machine then
			local base_seg_state = anim_machine:segment_state(Idstring("base"))

			if base_seg_state then
				local idx = anim_machine:state_name_to_index(base_seg_state)
				text_str = text_str .. ":base_anim_idx( " .. tostring(idx) .. " )"
			end

			local upper_body_seg_state = anim_machine:segment_state(Idstring("upper_body"))

			if upper_body_seg_state then
				local idx = anim_machine:state_name_to_index(upper_body_seg_state)
				text_str = text_str .. ":upp_bdy_anim_idx( " .. tostring(idx) .. " )"
			end
		end]]

		local ext_mov = unit:movement()
		local active_actions = ext_mov._active_actions

		if active_actions then
			local full_body = active_actions[1]

			if full_body then
				text_str = text_str .. ":action[1]( " .. full_body:type() .. " )"
			end

			local lower_body = active_actions[2]

			if lower_body then
				text_str = text_str .. ":action[2]( " .. lower_body:type() .. " )"
			end

			local upper_body = active_actions[3]

			if upper_body then
				text_str = text_str .. ":action[3]( " .. upper_body:type() .. " )"
			end

			local superficial = active_actions[4]

			if superficial then
				text_str = text_str .. ":action[4]( " .. superficial:type() .. " )"
			end
		end

		if logic_name_text then
			logic_name_text:set_text(text_str)
		else
			logic_name_text = panel:text({
				name = "text",
				font_size = 12,
				layer = 1,
				text = text_str,
				font = tweak_data.hud.medium_font,
				color = draw_color
			})
			logic_name_texts[u_key] = logic_name_text
		end

		local my_head_pos = mid_pos1

		mvec3_set(my_head_pos, ext_mov:m_head_pos())
		mvec3_set_z(my_head_pos, my_head_pos.z + 30)

		local my_head_pos_screen = camera:world_to_screen(my_head_pos)

		if my_head_pos_screen.z > 0 then
			local screen_x = (my_head_pos_screen.x + 1) * 0.5 * res_x
			local screen_y = (my_head_pos_screen.y + 1) * 0.5 * res_y

			logic_name_text:set_x(screen_x)
			logic_name_text:set_y(screen_y)

			if not logic_name_text:visible() then
				logic_name_text:show()
			end
		elseif logic_name_text:visible() then
			logic_name_text:hide()
		end
	end

	local brush_to_use = {
		guard = "brush_guard",
		defend_area = "brush_defend",
		free = "brush_free",
		follow = "brush_free",
		surrender = "brush_free",
		act = "brush_act",
		revive = "brush_act"
	}

	local function _f_draw_obj_pos(unit)
		local ext_brain = unit:brain()
		local objective = ext_brain:objective()
		local objective_type = objective and objective.type
		local brush = brush_to_use[objective_type]
		brush = brush and draw_data[brush] or draw_data.brush_misc

		local obj_pos = nil

		if objective then
			if objective.pos then
				obj_pos = objective.pos
			else
				local follow_unit = objective.follow_unit

				if follow_unit then
					obj_pos = follow_unit:movement():m_head_pos()

					if follow_unit:base().is_local_player then
						obj_pos = obj_pos + math_up * -30
					end
				elseif objective.nav_seg then
					obj_pos = managers.navigation._nav_segments[objective.nav_seg].pos
				elseif objective.area then
					obj_pos = objective.area.pos
				end
			end
		end

		local ext_mov = nil

		if obj_pos then
			ext_mov = unit:movement()

			local u_pos = ext_mov:m_com()

			brush:cylinder(u_pos, obj_pos, 4, 3)
			brush:sphere(u_pos, 24)
		end

		if ext_brain._logic_data.is_suppressed then
			ext_mov = ext_mov or unit:movement()

			mvec3_set(mid_pos1, ext_mov:m_pos())
			mvec3_set_z(mid_pos1, mid_pos1.z + 220)
			draw_data.brush_suppressed:cylinder(ext_mov:m_pos(), mid_pos1, 35)
		end
	end

	local my_groups = self._groups
	local group_center = tmp_vec3

	for group_id, group in pairs_g(my_groups) do
		local units_com = {}

		for u_key, u_data in pairs_g(group.units) do
			local m_com = u_data.unit:movement():m_com()

			units_com[#units_com + 1] = m_com

			mvec3_add(group_center, m_com)
		end

		local nr_units = #units_com

		if nr_units > 0 then
			mvec3_divide(group_center, nr_units)

			local gui_text = group_id_texts[group_id]
			local group_pos_screen = camera:world_to_screen(group_center)

			if group_pos_screen.z > 0 then
				local move_type = ":" .. "none"
				local group_objective = group.objective

				if group_objective then
					if group.is_chasing then
						move_type = ":" .. "chasing"
					elseif group_objective.moving_in then
						move_type = ":" .. "moving_in"
					elseif group_objective.moving_out then
						move_type = ":" .. "moving_out"
					elseif group_objective.open_fire then
						move_type = ":" .. "open_fire"
					end
				end
				
				local phase = ""
				
				local task_data = self._task_data.assault
				
				if task_data and task_data.active then
					phase = ":" .. task_data.phase
				end

				if not gui_text then
					gui_text = panel:text({
						name = "text",
						font_size = 12,
						layer = 2,
						text = group.team.id .. ":" .. group_id .. ":" .. group.objective.type .. move_type .. phase,
						font = tweak_data.hud.medium_font,
						color = draw_data.group_id_color
					})
					group_id_texts[group_id] = gui_text
				else
					gui_text:set_text(group.team.id .. ":" .. group_id .. ":" .. group.objective.type .. move_type .. phase)
				end

				local screen_x = (group_pos_screen.x + 1) * 0.5 * res_x
				local screen_y = (group_pos_screen.y + 1) * 0.5 * res_y

				gui_text:set_x(screen_x)
				gui_text:set_y(screen_y)

				if not gui_text:visible() then
					gui_text:show()
				end
			elseif gui_text and gui_text:visible() then
				gui_text:hide()
			end

			for i = 1, #units_com do
				local m_com = units_com[i]

				draw_data.pen_group:line(group_center, m_com)
			end
		end

		mvec3_set_zero(group_center)
	end

	local function _f_draw_attention(l_data)
		local current_focus = l_data.attention_obj

		if not current_focus then
			return
		end

		local my_head_pos = l_data.unit:movement():m_head_pos()
		local e_pos = l_data.attention_obj.m_head_pos

		mvec3_step(mid_pos2, my_head_pos, e_pos, 300)
		mvec3_lerp(mid_pos1, my_head_pos, mid_pos2, t % 0.5)
		mvec3_step(mid_pos2, mid_pos1, e_pos, 50)
		focus_enemy_pen:line(mid_pos1, mid_pos2)

		local focus_base_ext = current_focus.unit:base()

		if focus_base_ext and focus_base_ext.is_local_player then
			focus_player_brush:sphere(my_head_pos, 20)
		end
	end

	local groups = {
		{
			group = self._police,
			color = Color(1, 1, 0, 0)
		},
		{
			group = managers.enemy:all_civilians(),
			color = Color(1, 0.75, 0.75, 0.75)
		},
		{
			group = self._ai_criminals,
			color = Color(1, 0, 1, 0)
		}
	}

	for i = 1, #groups do
		local group_data = groups[i]

		for u_key, u_data in pairs_g(group_data.group) do
			_f_draw_obj_pos(u_data.unit)

			--[[if camera then
				local l_data = u_data.unit:brain()._logic_data

				_f_draw_logic_name(u_key, l_data, group_data.color)
				_f_draw_attention(l_data)
			end]]
		end
	end

	for u_key, gui_text in pairs_g(logic_name_texts) do
		local keep = nil

		for i = 1, #groups do
			local group_data = groups[i]

			if group_data.group[u_key] then
				keep = true

				break
			end
		end

		if not keep then
			panel:remove(gui_text)

			logic_name_texts[u_key] = nil
		end
	end

	for group_id, gui_text in pairs_g(group_id_texts) do
		if not my_groups[group_id] then
			panel:remove(gui_text)

			group_id_texts[group_id] = nil
		end
	end
end

function GroupAIStateBesiege:_check_spawn_phalanx()
end

function GroupAIStateBesiege:_queue_police_upd_task()
	if not self._police_upd_task_queued then
		self._police_upd_task_queued = true
		
		managers.enemy:queue_task("GroupAIStateBesiege._upd_police_activity", self._upd_police_activity, self, self._t + 0.2, nil, true)
	end
end


function GroupAIStateBesiege:update(t, dt)
	GroupAIStateBesiege.super.update(self, t, dt)
	
	if Network:is_server() then
		self:_queue_police_upd_task()
		self:_claculate_drama_value()

		if managers.navigation:is_data_ready() and self._draw_enabled then
			self:_draw_enemy_activity(t)
			self:_draw_spawn_points()
		end
	end
end

function GroupAIStateBesiege:chk_assault_number()
	if not self._assault_number then
		return 1
	end
	
	return self._assault_number
end

function GroupAIStateBesiege:chk_has_civilian_hostages()
	if self._police_hostage_headcount and self._hostage_headcount > 0 then
		if self._hostage_headcount - self._police_hostage_headcount > 0 then
			return true
		end
	end
end

function GroupAIStateBesiege:chk_no_fighting_atm()

	if self._drama_data.amount > tweak_data.drama.consistentcombat then
		return
	end
	
	return true
end

function GroupAIStateBesiege:chk_had_hostages()
	return self._had_hostages
end

function GroupAIStateBesiege:chk_anticipation()
	local assault_task = self._task_data.assault
	
	if not assault_task.active or assault_task and assault_task.phase == "anticipation" and assault_task.phase_end_t and assault_task.phase_end_t > self._t then
		return true
	end
	
	return
end

function GroupAIStateBesiege:chk_assault_active_atm()
	local assault_task = self._task_data.assault
	
	if assault_task and assault_task.phase == "build" or assault_task and assault_task.phase == "sustain" then
		return true
	end
	
	return
end

function GroupAIStateBesiege:is_detection_persistent()
	local assault_task = self._task_data.assault
	
	if assault_task and assault_task.phase == "build" or assault_task and assault_task.phase == "sustain" then
		return true
	end
	
	return
end

function GroupAIStateBesiege:get_hostage_count_for_chatter()
	
	if self._hostage_headcount > 0 then
		return self._hostage_headcount
	end
	
	return 0
end

function GroupAIStateBesiege:_voice_looking_for_angle(group)
	for u_key, unit_data in pairs_g(group.units) do
		if unit_data.char_tweak.chatter.ready and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "look_for_angle") then
			else
		end
	end
end

function GroupAIStateBesiege:_voice_friend_dead(group)
	for u_key, unit_data in pairs_g(group.units) do
		if unit_data.char_tweak.chatter.enemyidlepanic and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "assaultpanic") then
			else
		end
	end
end

function GroupAIStateBesiege:_voice_saw()
	for group_id, group in pairs_g(self._groups) do
		for u_key, u_data in pairs_g(group.units) do
			if u_data.char_tweak.chatter.saw then
				self:chk_say_enemy_chatter(u_data.unit, u_data.m_pos, "saw")
			else
				
			end
		end
	end
end

function GroupAIStateBesiege:_voice_sentry()
	for group_id, group in pairs_g(self._groups) do
		for u_key, u_data in pairs_g(group.units) do
			if u_data.char_tweak.chatter.sentry then
				self:chk_say_enemy_chatter(u_data.unit, u_data.m_pos, "sentry")
			else
				
			end
		end
	end
end	

function GroupAIStateBesiege:_voice_affirmative(group)
	for u_key, unit_data in pairs_g(group.units) do
		if unit_data.char_tweak.chatter.affirmative and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "affirmative") then
			else
		end
	end
end	
	
function GroupAIStateBesiege:_voice_open_fire_start(group)
	for u_key, unit_data in pairs_g(group.units) do
		if unit_data.char_tweak.chatter.ready and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "open_fire") then
			else
		end
	end
end

function GroupAIStateBesiege:_voice_push_in(group)
	for u_key, unit_data in pairs_g(group.units) do
		if unit_data.char_tweak.chatter.ready and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "push") then
			else
		end
	end
end

function GroupAIStateBesiege:_voice_gtfo(group)
	for u_key, unit_data in pairs_g(group.units) do
		if unit_data.char_tweak.chatter.ready and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "retreat") then
			else
		end
	end
end
	
function GroupAIStateBesiege:_voice_deathguard_start(group)
	for u_key, unit_data in pairs_g(group.units) do
		if unit_data.char_tweak.chatter.ready and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "deathguard") then
			else
		end
	end
end	
	
function GroupAIStateBesiege:_voice_smoke(group)
	for u_key, unit_data in pairs_g(group.units) do
		if unit_data.char_tweak.chatter.ready and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "smoke") then
			else
		end
	end
end	
	
function GroupAIStateBesiege:_voice_flash(group)
	for u_key, unit_data in pairs_g(group.units) do
		if unit_data.char_tweak.chatter.ready and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "flash_grenade") then
		else
		end
	end
end

function GroupAIStateBesiege:_voice_dont_delay_assault(group)
	local time = self._t
	for u_key, unit_data in pairs_g(group.units) do
		if not unit_data.unit:sound():speaking(time) then
			unit_data.unit:sound():say("p01", true, nil)
			return true
		end
	end
	return false
end

function GroupAIStateBesiege:_voice_groupentry(group)
	local group_leader_u_key, group_leader_u_data = self._determine_group_leader(group.units)
	if group_leader_u_data and group_leader_u_data.tactics and group_leader_u_data.char_tweak.chatter.entry then
		for i_tactic, tactic_name in ipairs(group_leader_u_data.tactics) do
			local randomgroupcallout = math.random(1, 100) 
			if tactic_name == "groupcs1" then
				self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "csalpha")
			elseif tactic_name == "groupcs2" then
				self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "csbravo")
			elseif tactic_name == "groupcs3" then
				self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "cscharlie")
			elseif tactic_name == "groupcs4" then
				self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "csdelta")
			elseif tactic_name == "grouphrt1" then
				self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtalpha")
			elseif tactic_name == "grouphrt2" then
				self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtbravo")
			elseif tactic_name == "grouphrt3" then
				self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtcharlie")
			elseif tactic_name == "grouphrt4" then
				self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtdelta")
			elseif tactic_name == "groupcsr" then
				if randomgroupcallout < 25 then
					self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "csalpha")
				elseif randomgroupcallout > 25 and randomgroupcallout < 50 then
					self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "csbravo")
				elseif randomgroupcallout < 74 and randomgroupcallout > 50 then
					self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "cscharlie")
				else
					self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "csdelta")
				end
			elseif tactic_name == "grouphrtr" then
				if randomgroupcallout < 25 then
					self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtalpha")
				elseif randomgroupcallout > 25 and randomgroupcallout < 50 then
					self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtbravo")
				elseif randomgroupcallout < 74 and randomgroupcallout > 50 then
					self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtcharlie")
				else
					self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtdelta")
				end
			elseif tactic_name == "groupany" then
				if self._task_data.assault.active then
					if randomgroupcallout < 25 then
						self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "csalpha")
					elseif randomgroupcallout > 25 and randomgroupcallout < 50 then
						self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "csbravo")
					elseif randomgroupcallout < 74 and randomgroupcallout > 50 then
						self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "cscharlie")
					else
						self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "csdelta")
					end
				else
					if randomgroupcallout < 25 then
						self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtalpha")
					elseif randomgroupcallout > 25 and randomgroupcallout < 50 then
						self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtbravo")
					elseif randomgroupcallout < 74 and randomgroupcallout > 50 then
						self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtcharlie")
					else
						self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtdelta")
					end
				end
			end
		end
	end
end

function GroupAIStateBesiege:provide_covering_fire(group_to_cover)
	
end

function GroupAIStateBesiege:_upd_assault_areas(current_area)
	local all_areas = self._area_data
	local nav_manager = managers.navigation
	local all_nav_segs = nav_manager._nav_segments
	local task_data = self._task_data
	local t = self._t
	
	local assault_candidates = {}
	local assault_data = task_data.assault

	local found_areas = {}
	local to_search_areas = {}

	for area_id, area in pairs_g(all_areas) do
		if area.spawn_points then
			for _, sp_data in pairs_g(area.spawn_points) do
				if sp_data.delay_t <= t and not all_nav_segs[sp_data.nav_seg].disabled then
					table_insert(to_search_areas, area)

					found_areas[area_id] = true

					break
				end
			end
		end

		if not found_areas[area_id] and area.spawn_groups then
			for _, sp_data in pairs_g(area.spawn_groups) do
				if sp_data.delay_t <= t and not all_nav_segs[sp_data.nav_seg].disabled then
					table_insert(to_search_areas, area)

					found_areas[area_id] = true

					break
				end
			end
		end
	end

	if #to_search_areas == 0 then
		return current_area
	end

	if assault_candidates and self._char_criminals then
		for criminal_key, criminal_data in pairs_g(self._char_criminals) do
			if criminal_key and not criminal_data.status then
				local nav_seg = criminal_data.tracker:nav_segment()
				local area = self:get_area_from_nav_seg_id(nav_seg)
				found_areas[area] = true
				
				for _, nbr in pairs_g(area.neighbours) do
					found_areas[nbr] = true
				end

				table_insert(assault_candidates, area)
			end
		end
	end

	local i = 1

	repeat
		local area = to_search_areas[i]
		local force_factor = area.factors.force
		local demand = force_factor and force_factor.force
		local nr_police = table.size(area.police.units)
		local nr_criminals = nil
		
		if area and area.criminal and area.criminal.units then
			nr_criminals = table.size(area.criminal.units)
		end
		
		if assault_candidates and self._player_criminals then
			for criminal_key, _ in pairs_g(area.criminal.units) do
				if criminal_key and self._player_criminals[criminal_key] then
					if not self._player_criminals[criminal_key].is_deployable then
						table_insert(assault_candidates, area)

						break
					end
				end
			end
		end

		if nr_criminals and nr_criminals == 0 then
			for neighbour_area_id, neighbour_area in pairs_g(area.neighbours) do
				if not found_areas[neighbour_area_id] then
					table_insert(to_search_areas, neighbour_area)

					found_areas[neighbour_area_id] = true
				end
			end
		end

		i = i + 1
	until i > #to_search_areas

	if assault_candidates and #assault_candidates > 0 then
		return assault_candidates
	end
	
end

function GroupAIStateBesiege:_set_assault_objective_to_group(group, phase)
	if not group.has_spawned then
		return
	end

	local phase_is_anticipation = phase == "anticipation"
	local current_objective = group.objective
	local approach, open_fire, push, pull_back, charge = nil
	local obstructed_area = self:_chk_group_areas_tresspassed(group)
	local group_leader_u_key, group_leader_u_data = self._determine_group_leader(group.units)
	local tactics_map = nil

	if group_leader_u_data and group_leader_u_data.tactics then
		tactics_map = {}

		for i = 1, #group_leader_u_data.tactics do
			tactic_name = group_leader_u_data.tactics[i]
			tactics_map[tactic_name] = true
		end

		if current_objective.tactic and not tactics_map[current_objective.tactic] then
			current_objective.tactic = nil
		end
		
		if not phase_is_anticipation and not current_objective.moving_in then
			for i = 1, #group_leader_u_data.tactics do
				tactic_name = group_leader_u_data.tactics[i]
				if tactic_name == "hunter" then
					local closest_crim_u_data, closest_crim_dis_sq = nil
					local crim_dis_sq_chk = not closest_crim_dis_sq or closest_crim_dis_sq > closest_u_dis_sq
					
					for u_key, u_data in pairs_g(self._char_criminals) do
						if u_data.unit then
							if not u_data.status or u_data.status == "electrified" then
								local players_nearby = managers.player:_chk_fellow_crimin_proximity(u_data.unit)
								local closest_u_id, closest_u_data, closest_u_dis_sq = self._get_closest_group_unit_to_pos(u_data.m_pos, group.units)
								if players_nearby and players_nearby <= 0 then
									if closest_u_dis_sq and crim_dis_sq_chk then
										closest_crim_u_data = u_data
										closest_crim_dis_sq = closest_u_dis_sq
									end
								end
							end
						end
					end
					
					if closest_crim_u_data then
						local search_params = {
							id = "GroupAI_hunter",
							from_tracker = group_leader_u_data.unit:movement():nav_tracker(),
							to_tracker = closest_crim_u_data.tracker,
							access_pos = self._get_group_acces_mask(group)
						}
						local coarse_path = managers.navigation:search_coarse(search_params)

						if coarse_path then
							local grp_objective = {
								distance = 400,
								type = "assault_area",
								attitude = "engage",
								tactic = "hunter",
								moving_in = true,
								open_fire = true,
								follow_unit = closest_crim_u_data.unit,
								area = self:get_area_from_nav_seg_id(coarse_path[#coarse_path][1]),
								coarse_path = coarse_path
							}
							group.is_chasing = true

							self:_set_objective_to_enemy_group(group, grp_objective)

							return
						end
					end
				elseif tactic_name == "deathguard" then
					if current_objective.tactic == tactic_name then
						for u_key, u_data in pairs_g(self._char_criminals) do
							if u_data.status and current_objective.follow_unit == u_data.unit then
								local crim_nav_seg = u_data.tracker:nav_segment()

								if current_objective.area.nav_segs[crim_nav_seg] then
									return
								end
							end
						end
					end

					local closest_crim_u_data, closest_crim_dis_sq = nil

					for u_key, u_data in pairs_g(self._char_criminals) do
						if u_data.status and u_data.status ~= "electrified" then
							local closest_u_id, closest_u_data, closest_u_dis_sq = self._get_closest_group_unit_to_pos(u_data.m_pos, group.units)

							if closest_u_dis_sq and closest_u_dis_sq < 1440000 and (not closest_crim_dis_sq or closest_u_dis_sq < closest_crim_dis_sq) then
								closest_crim_u_data = u_data
								closest_crim_dis_sq = closest_u_dis_sq
							end
						end
					end

					if closest_crim_u_data then
						local search_params = {
							id = "GroupAI_deathguard",
							from_tracker = group_leader_u_data.unit:movement():nav_tracker(),
							to_tracker = closest_crim_u_data.tracker,
							access_pos = self._get_group_acces_mask(group)
						}
						local coarse_path = managers.navigation:search_coarse(search_params)

						if coarse_path then
							local grp_objective = {
								distance = 800,
								type = "assault_area",
								attitude = "engage",
								tactic = "deathguard",
								open_fire = true,
								moving_in = true,
								follow_unit = closest_crim_u_data.unit,
								area = self:get_area_from_nav_seg_id(coarse_path[#coarse_path][1]),
								coarse_path = coarse_path
							}
							group.is_chasing = true

							self:_set_objective_to_enemy_group(group, grp_objective)
							self:_voice_deathguard_start(group)

							return
						end
					end
				end
			end
		end
	end

	local objective_area = nil
	
	if obstructed_area then
		
		--if one of the group members walk into a criminal then, if the phase is anticipation, they'll retreat backwards, otherwise, stand their ground and start shooting.
		--this will most likely always instantly kick in if the group has finished charging into an area.
	
		if phase_is_anticipation then 
			pull_back = true
		else
			objective_area = obstructed_area
			
			if group.in_place_t and self._t - group.in_place_t > 4 then --if we're in the destination and we have stayed still for longe than 4 seconds, if anyone is camping in a specific spot, try to path to them
				push = true
				charge = true
			elseif not current_objective.open_fire or current_objective.area.id ~= obstructed_area.id then --have to check for this here or open_fire might not get set
				open_fire = true
			end
		end
	elseif group.objective.moving_in and not current_objective.tactic then
		if not next(current_objective.area.criminal.units) then --if theres suddenly no criminals in the area, start approaching instead
			approach = true
		end
	elseif not current_objective.moving_in then
		local obstructed_path_index = nil
		local forwardmost_i_nav_point = nil
		
		if not group.is_chasing and group.objective.coarse_path then
			obstructed_path_index = self:_chk_coarse_path_obstructed(group)
		end
				
		if current_objective.moving_out then
			if obstructed_path_index then --if theres criminals obstructing the group's coarse_path, then this will get the area in which that's happening.
				objective_area = self:get_area_from_nav_seg_id(current_objective.coarse_path[math.max(obstructed_path_index - 1, 1)][1])
				pull_back = true
			end
		else
			local has_criminals_closer = nil
			local has_criminals_close = nil
			
			if next(current_objective.area.criminal.units) then
				has_criminals_close = true
				has_criminals_closer = true
			else
				for area_id, neighbour_area in pairs_g(current_objective.area.neighbours) do
					if next(neighbour_area.criminal.units) then					
						has_criminals_close = neighbour_area
						break
					end
				end
			end
			
			if phase_is_anticipation and current_objective.open_fire then
				pull_back = true
			elseif not has_criminals_close then
				approach = true
			elseif not phase_is_anticipation then
				if not has_criminals_closer then
					objective_area = has_criminals_close
					
					--the general idea here is that groups will generally try to wait until other groups have headed into the area
					--by pushing in one big pile, you make sure to punish players camping and not trying to keep the cops away, without making them too rushy.
					if not group.in_place_t then
						pull_back = true
					else
						local move_t = 4
						--local deduction = not self._last_killed_cop_t and 4 or self._t - self._last_killed_cop_t
						
						if tactics_map then
							if tactics_map.charge then
								move_t = move_t - 2
							elseif tactics_map.ranged_fire or tactics_map.elite_ranged_fire then
								move_t = move_t + 2
							end
							
							if tactics_map.flank then
								move_t = move_t + 1
							end
						end
					
						if move_t <= 0 or self._t - group.in_place_t > move_t then
							push = true
						end
					end
				elseif current_objective.coarse_path then
					--this shouldnt happen under most circumstances, but might be an edge case, so im making sure.
					--in case the group was moving_out/moving_in and doesn't get obstructed_area, but theres criminals in the area they're in, use open_fire
					--to wipe the coarse path.
					open_fire = true
				end
			end
		end
	end
	
	objective_area = objective_area or current_objective.area

	if open_fire then
		local grp_objective = {
			attitude = "engage",
			pose = "stand",
			type = "assault_area",
			stance = "hos",
			open_fire = true,
			no_move_out = true,
			tactic = current_objective.tactic,
			area = obstructed_area or current_objective.area
		}
		
		group.in_place_t = self._t
		group.is_chasing = nil
		self:_set_objective_to_enemy_group(group, grp_objective)
		self:_voice_open_fire_start(group)
	elseif approach or push then
		local assault_area, alternate_assault_area, alternate_assault_area_from, assault_path, alternate_assault_path = nil
		local to_search_areas = {
			objective_area
		}
		local found_areas = {
			[objective_area] = "init"
		}
		
		local needs_coarse_path = nil --i set this up in case we want groups in coplogicattack who are opening fire to be able to charge, without wasting performance on a coarse_path
		
		repeat
			local search_area = table_remove(to_search_areas, 1)
			local needs_coarse_path = nil
			
			if next(search_area.criminal.units) then
				local assault_from_here = true
				
				if search_area.id ~= current_objective.area.id then
					needs_coarse_path = true
				end

				if not push then
					if tactics_map and tactics_map.flank then
						local assault_from_area = found_areas[search_area]

						if assault_from_area ~= "init" then
							local cop_units = assault_from_area.police.units

							for u_key, u_data in pairs_g(cop_units) do
								if u_data.group and u_data.group ~= group and u_data.group.objective.type == "assault_area" then
									assault_from_here = false
									
									if not alternate_assault_area or math_random() < 0.5 then
										if needs_coarse_path then
											local search_params = {
												id = "GroupAI_assault",
												from_seg = current_objective.area.pos_nav_seg,
												to_seg = search_area.pos_nav_seg,
												access_pos = self._get_group_acces_mask(group),
												long_path = true
											}
											alternate_assault_path = managers.navigation:search_coarse(search_params)
											
											if alternate_assault_path then
												--log("pog")
												self:_merge_coarse_path_by_area(alternate_assault_path)

												alternate_assault_area = search_area
												alternate_assault_area_from = assault_from_area
											end
										else
											alternate_assault_area = search_area
											alternate_assault_area_from = assault_from_area
										end

									end

									found_areas[search_area] = nil

									break
								end
							end
						end
					end
				end

				if assault_from_here then
					
					if not needs_coarse_path then
						assault_area = search_area
					else
						local search_params = {
							id = "GroupAI_assault",
							from_seg = current_objective.area.pos_nav_seg,
							to_seg = search_area.pos_nav_seg,
							access_pos = self._get_group_acces_mask(group),
							long_path = tactics_map and tactics_map.flank and true or nil
						}
						assault_path = managers.navigation:search_coarse(search_params)

						if assault_path then
							--log("YOOOOOOOOOOOOOOOOOOOOOOOOO")
							self:_merge_coarse_path_by_area(assault_path)

							assault_area = search_area

							break
						end
					end
				end
			else
				for other_area_id, other_area in pairs_g(search_area.neighbours) do
					if not found_areas[other_area] then
						table_insert(to_search_areas, other_area)

						found_areas[other_area] = search_area
					end
				end
			end
		until #to_search_areas == 0

		if not assault_area and alternate_assault_area then
			assault_area = alternate_assault_area
			found_areas[assault_area] = alternate_assault_area_from
			if needs_coarse_path then
				assault_path = alternate_assault_path
			end
		end

		if not needs_coarse_path and assault_area or assault_area and assault_path then
			local assault_area = push and assault_area or found_areas[assault_area] == "init" and objective_area or found_areas[assault_area]

			local used_grenade = nil
			
			if approach and assault_path and next(assault_area.criminal.units) then
				local safe_area = self:get_area_from_nav_seg_id(assault_path[math_max(#assault_path - 1, 1)][1])
				
				if safe_area then
					local new_path = {}
					for i = 1, #assault_path - 1 do
						new_path[i] = assault_path[i]
					end
					
					assault_path = new_path
					assault_area = safe_area
				end
			end
				
			
			if push then
				if current_objective.area.id == assault_area.id or current_objective.area.neighbours[assault_area] then
					local detonate_pos = nil

					if charge then
						for c_key, c_data in pairs_g(assault_area.criminal.units) do
							detonate_pos = assault_area.pos

							break
						end
					end

					local first_chk = math_random() < 0.5 and self._chk_group_use_flash_grenade or self._chk_group_use_smoke_grenade
					local second_chk = first_chk == self._chk_group_use_flash_grenade and self._chk_group_use_smoke_grenade or self._chk_group_use_flash_grenade
					used_grenade = first_chk(self, group, self._task_data.assault, detonate_pos, assault_area)
					used_grenade = used_grenade or second_chk(self, group, self._task_data.assault, detonate_pos, assault_area)

					self:_voice_move_in_start(group)
				end
			end
			
			if assault_path and #assault_path > 2 and assault_area.nav_segs[assault_path[#assault_path - 1][1]] then
				table_remove(assault_path)
			end

			local grp_objective = {
				type = "assault_area",
				stance = "hos",
				area = assault_area,
				coarse_path = needs_coarse_path and assault_path or nil,
				pose = "stand",
				attitude = push and "engage" or "avoid",
				moving_in = push and true or nil,
				open_fire = push or nil,
				pushed = push or nil,
				charge = charge,
				interrupt_dis = nil
			}
			--group.is_chasing = group.is_chasing or push

			self:_set_objective_to_enemy_group(group, grp_objective)
		end
	elseif pull_back then
		local retreat_area, do_not_retreat = nil

		if not next(objective_area.criminal.units) then
			retreat_area = objective_area
		else
			for u_key, u_data in pairs_g(group.units) do
				local nav_seg_id = u_data.tracker:nav_segment()

				if current_objective.area.nav_segs[nav_seg_id] then
					retreat_area = current_objective.area

					break
				end

				if self:is_nav_seg_safe(nav_seg_id) then
					retreat_area = self:get_area_from_nav_seg_id(nav_seg_id)

					break
				end
			end
		end

		if not retreat_area and not do_not_retreat and current_objective.coarse_path then
			local forwardmost_i_nav_point = self:_get_group_forwardmost_coarse_path_index(group)

			if forwardmost_i_nav_point then
				local nearest_safe_area = self:get_area_from_nav_seg_id(current_objective.coarse_path[math.max(forwardmost_i_nav_point - 1, 1)][1])
				retreat_area = nearest_safe_area
			end
		end

		if retreat_area then
			local search_params = nil
			local retreat_path = nil
			
			if group_leader_u_data then
				search_params = {
					id = "GroupAI_pullback",
					from_tracker = group_leader_u_data.unit:movement():nav_tracker(),
					to_seg = retreat_area.pos_nav_seg,
					access_pos = self._get_group_acces_mask(group)
				}
				
				retreat_path = managers.navigation:search_coarse(search_params)
			end

			local new_grp_objective = {
				attitude = "avoid",
				stance = "hos",
				pose = "crouch",
				type = "assault_area",
				area = retreat_area,
				running = true,
				coarse_path = retreat_path or {{retreat_area.pos_nav_seg, mvec3_cpy(retreat_area.pos)}}
			}
			group.is_chasing = nil

			self:_set_objective_to_enemy_group(group, new_grp_objective)

			return
		end
	end
end

function GroupAIStateBesiege:_chk_group_use_smoke_grenade(group, task_data, detonate_pos, target_area)
	if task_data.use_smoke then
		local shooter_pos, shooter_u_data = nil
		local duration = tweak_data.group_ai.smoke_grenade_lifetime

		for u_key, u_data in pairs_g(group.units) do
			if u_data.tactics_map and u_data.tactics_map.smoke_grenade then
				if not detonate_pos then
					local nav_seg_id = u_data.tracker:nav_segment()
					local nav_seg = managers.navigation._nav_segments[nav_seg_id]
					
					if not target_area then
						target_area = task_data.target_areas[1]
					end
					
					for neighbour_nav_seg_id, door_list in pairs_g(nav_seg.neighbours) do
						local area = self:get_area_from_nav_seg_id(neighbour_nav_seg_id)

						if target_area.nav_segs[neighbour_nav_seg_id] or next(area.criminal.units) then
							local random_door_id = door_list[math_random(#door_list)]

							if type(random_door_id) == "number" then
								detonate_pos = managers.navigation._room_doors[random_door_id].center
							else
								detonate_pos = random_door_id:script_data().element:nav_link_end_pos()
							end

							shooter_pos = mvector3.copy(u_data.m_pos)
							shooter_u_data = u_data

							break
						end
					end
				end

				if detonate_pos and shooter_u_data then
					self:detonate_smoke_grenade(detonate_pos, shooter_pos, duration, false)
					self:apply_grenade_cooldown(nil)

					if shooter_u_data.char_tweak.chatter.smoke and not shooter_u_data.unit:sound():speaking(self._t) then
						self:chk_say_enemy_chatter(shooter_u_data.unit, shooter_u_data.m_pos, "smoke")
					end

					return true
				end
			end
		end
	end
end

function GroupAIStateBesiege:_chk_group_use_flash_grenade(group, task_data, detonate_pos, target_area)
	if task_data.use_smoke then
		local shooter_pos, shooter_u_data = nil
		local duration = tweak_data.group_ai.flash_grenade_lifetime

		for u_key, u_data in pairs_g(group.units) do
			if u_data.tactics_map and u_data.tactics_map.flash_grenade then
				if not detonate_pos then
					local nav_seg_id = u_data.tracker:nav_segment()
					local nav_seg = managers.navigation._nav_segments[nav_seg_id]
					
					if not target_area then
						target_area = task_data.target_areas[1]
					end
					
					for neighbour_nav_seg_id, door_list in pairs_g(nav_seg.neighbours) do
						if target_area.nav_segs[neighbour_nav_seg_id] then
							local random_door_id = door_list[math_random(#door_list)]

							if type(random_door_id) == "number" then
								detonate_pos = managers.navigation._room_doors[random_door_id].center
							else
								detonate_pos = random_door_id:script_data().element:nav_link_end_pos()
							end

							shooter_pos = mvector3.copy(u_data.m_pos)
							shooter_u_data = u_data

							break
						end
					end
				end

				if detonate_pos and shooter_u_data then
					self:detonate_smoke_grenade(detonate_pos, shooter_pos, duration, true)
					self:apply_grenade_cooldown(true)

					if shooter_u_data.char_tweak.chatter.flash_grenade and not shooter_u_data.unit:sound():speaking(self._t) then
						self:chk_say_enemy_chatter(shooter_u_data.unit, shooter_u_data.m_pos, "flash_grenade")
					end

					return true
				end
			end
		end
	end
end

function GroupAIStateBesiege:_upd_group_spawning()
	local spawn_task = self._spawning_groups[1]

	if not spawn_task then
		return
	end

	local nr_units_spawned = 0
	local produce_data = {
		name = true,
		spawn_ai = {}
	}
	local group_ai_tweak = tweak_data.group_ai
	local spawn_points = spawn_task.spawn_group.spawn_pts


	local function _try_spawn_unit(u_type_name, spawn_entry)
		if GroupAIStateBesiege._MAX_SIMULTANEOUS_SPAWNS <= nr_units_spawned then
			return
		end

		local hopeless = true
		local current_unit_type = tweak_data.levels:get_ai_group_type()

		for _, sp_data in ipairs(spawn_points) do
			local category = group_ai_tweak.unit_categories[u_type_name]

			if (sp_data.accessibility == "any" or category.access[sp_data.accessibility]) and (not sp_data.amount or sp_data.amount > 0) and sp_data.mission_element:enabled() and category.unit_types[current_unit_type] then
				hopeless = false

				if sp_data.delay_t < self._t then
					local units = category.unit_types[current_unit_type]
					produce_data.name = units[math.random(#units)]
					produce_data.name = managers.modifiers:modify_value("GroupAIStateBesiege:SpawningUnit", produce_data.name)
					local spawned_unit = sp_data.mission_element:produce(produce_data)
					local u_key = spawned_unit:key()
					local objective = nil

					if spawn_task.objective then
						objective = self.clone_objective(spawn_task.objective)
					else
						if spawn_task.group.objective.element then
							objective = spawn_task.group.objective.element:get_random_SO(spawned_unit)

							if not objective then
								spawned_unit:set_slot(0)

								return true
							end

							objective.grp_objective = spawn_task.group.objective
						else
							spawned_unit:set_slot(0)

							return true
						end
					end

					local u_data = self._police[u_key]

					self:set_enemy_assigned(objective.area, u_key)

					if spawn_entry.tactics then
						u_data.tactics = spawn_entry.tactics
						u_data.tactics_map = {}

						for _, tactic_name in ipairs(u_data.tactics) do
							u_data.tactics_map[tactic_name] = true
						end
					end

					spawned_unit:brain():set_spawn_entry(spawn_entry, u_data.tactics_map)

					u_data.rank = spawn_entry.rank

					self:_add_group_member(spawn_task.group, u_key)

					if spawned_unit:brain():is_available_for_assignment(objective) then
						if objective.element then
							objective.element:clbk_objective_administered(spawned_unit)
						end

						spawned_unit:brain():set_objective(objective)
					else
						spawned_unit:brain():set_followup_objective(objective)
					end

					nr_units_spawned = nr_units_spawned + 1

					if spawn_task.ai_task then
						spawn_task.ai_task.force_spawned = spawn_task.ai_task.force_spawned + 1
					end

					sp_data.delay_t = self._t + sp_data.interval

					if sp_data.amount then
						sp_data.amount = sp_data.amount - 1
					end

					return true
				end
			end
		end

		if hopeless then
			debug_pause("[GroupAIStateBesiege:_upd_group_spawning] spawn group", spawn_task.spawn_group.id, "failed to spawn unit", u_type_name)

			return true
		end
	end

	for u_type_name, spawn_info in pairs_g(spawn_task.units_remaining) do
		if not group_ai_tweak.unit_categories[u_type_name].access.acrobatic then
			for i = spawn_info.amount, 1, -1 do
				local success = _try_spawn_unit(u_type_name, spawn_info.spawn_entry)

				if success then
					spawn_info.amount = spawn_info.amount - 1
				end

				break
			end
		end
	end

	for u_type_name, spawn_info in pairs_g(spawn_task.units_remaining) do
		for i = spawn_info.amount, 1, -1 do
			local success = _try_spawn_unit(u_type_name, spawn_info.spawn_entry)

			if success then
				spawn_info.amount = spawn_info.amount - 1
			end

			break
		end
	end

	local complete = true

	for u_type_name, spawn_info in pairs_g(spawn_task.units_remaining) do
		if spawn_info.amount > 0 then
			complete = false

			break
		end
	end

	if complete then
		spawn_task.group.has_spawned = true
		self:_voice_groupentry(spawn_task.group)
		
		table_remove(self._spawning_groups, use_last and #self._spawning_groups or 1)

		if spawn_task.group.size <= 0 then
			self._groups[spawn_task.group.id] = nil
		end
	end
end

function GroupAIStateBesiege:_upd_groups()
	for group_id, group in pairs_g(self._groups) do
		self:_verify_group_objective(group)

		for u_key, u_data in pairs_g(group.units) do
			local brain = u_data.unit:brain()
			local current_objective = brain:objective()
			local noobjordefaultorgrpobjchkandnoretry = not current_objective or current_objective.is_default or current_objective.grp_objective and current_objective.grp_objective ~= group.objective and not current_objective.grp_objective.no_retry
			local notfollowingorfollowingaliveunit = not group.objective.follow_unit or alive(group.objective.follow_unit)

			if noobjordefaultorgrpobjchkandnoretry and notfollowingorfollowingaliveunit then
				local objective = self._create_objective_from_group_objective(group.objective, u_data.unit)

				if objective and brain:is_available_for_assignment(objective) then
					self:set_enemy_assigned(objective.area or group.objective.area, u_key)

					if objective.element then
						objective.element:clbk_objective_administered(u_data.unit)
					end

					u_data.unit:brain():set_objective(objective)
				end
			end
		end
	end
end

function GroupAIStateBesiege:_upd_assault_task()
	local task_data = self._task_data.assault

	if not task_data.active then
		return
	end

	local t = self._t

	self:_assign_recon_groups_to_retire()

	local force_pool = nil
	--skirmish killcount per-wave stuff
	if managers.skirmish:is_skirmish() then
		if task_data.is_first or self._assault_number and self._assault_number == 1 or not self._assault_number then
			force_pool = self:_get_difficulty_dependent_value(self._tweak_data.assault.force_pool_skm1)
		elseif self._assault_number == 2 then
			force_pool = self:_get_difficulty_dependent_value(self._tweak_data.assault.force_pool_skm2)
			--log("is it working?")
		elseif self._assault_number == 3 then
			force_pool = self:_get_difficulty_dependent_value(self._tweak_data.assault.force_pool_skm3)
		elseif self._assault_number == 4 then
			force_pool = self:_get_difficulty_dependent_value(self._tweak_data.assault.force_pool_skm4)
		elseif self._assault_number == 5 then
			force_pool = self:_get_difficulty_dependent_value(self._tweak_data.assault.force_pool_skm5)
		elseif self._assault_number == 6 then
			force_pool = self:_get_difficulty_dependent_value(self._tweak_data.assault.force_pool_skm6)
		elseif self._assault_number >= 7 then
			force_pool = self:_get_difficulty_dependent_value(self._tweak_data.assault.force_pool_skm7)
		else
			force_pool = self:_get_difficulty_dependent_value(self._tweak_data.assault.force_pool_skm1)
			--log("bruh moment")
		end
	else
		force_pool = self:_get_difficulty_dependent_value(self._tweak_data.assault.force_pool) * self:_get_balancing_multiplier(self._tweak_data.assault.force_pool_balance_mul)
	end
	
	local task_spawn_allowance = force_pool - (self._hunt_mode and 0 or task_data.force_spawned)

	if task_data.phase == "anticipation" then
		if task_spawn_allowance <= 0 then
			

			task_data.phase = "fade"
		
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		elseif task_data.phase_end_t < t then
			self._assault_number = self._assault_number + 1

			managers.mission:call_global_event("start_assault")
			managers.hud:start_assault(self._assault_number)
			self:_set_rescue_state(false)
			
			task_data.phase = "build"
			task_data.phase_end_t = self._t + self._tweak_data.assault.build_duration
			task_data.is_hesitating = nil

			self:set_assault_mode(true)
			managers.trade:set_trade_countdown(false)
		else
			managers.hud:check_anticipation_voice(task_data.phase_end_t - t)
			managers.hud:check_start_anticipation_music(task_data.phase_end_t - t)

			if task_data.is_hesitating and task_data.voice_delay < self._t then
				if self._hostage_headcount > 0 then
					local best_group = nil

					for _, group in pairs_g(self._groups) do
						if not best_group or group.objective.type == "reenforce_area" then
							best_group = group
						elseif best_group.objective.type ~= "reenforce_area" and group.objective.type ~= "retire" then
							best_group = group
						end
					end

					if best_group and self:_voice_delay_assault(best_group) then
						task_data.is_hesitating = nil
					end
				else
					task_data.is_hesitating = nil
				end
			end
		end
	elseif task_data.phase == "build" then
		if task_spawn_allowance <= 0 then
			
			task_data.phase = "fade"
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		elseif task_data.phase_end_t < t then
			local sustain_duration = math.lerp(self:_get_difficulty_dependent_value(self._tweak_data.assault.sustain_duration_min), self:_get_difficulty_dependent_value(self._tweak_data.assault.sustain_duration_max), math.random()) * self:_get_balancing_multiplier(self._tweak_data.assault.sustain_duration_balance_mul)

			managers.modifiers:run_func("OnEnterSustainPhase", sustain_duration)
			
			task_data.phase = "sustain"
			task_data.phase_end_t = t + sustain_duration
		end
	elseif task_data.phase == "sustain" then
		local end_t = self:assault_phase_end_time()
		task_spawn_allowance = managers.modifiers:modify_value("GroupAIStateBesiege:SustainSpawnAllowance", task_spawn_allowance, force_pool)

		if task_spawn_allowance <= 0 then
			
			task_data.phase = "fade"
			local time = self._t
		    for group_id, group in pairs_g(self._groups) do
	            for u_key, u_data in pairs_g(group.units) do
		        local nav_seg_id = u_data.tracker:nav_segment()
		        local current_objective = group.objective
		            if current_objective.coarse_path then
		                if not u_data.unit:sound():speaking(time) then
	                        u_data.unit:sound():say("r01", true)
		                end	
	                end					   
		        end	
		    end
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		elseif end_t < t and not self._hunt_mode then
			
			task_data.phase = "fade"
			local time = self._t
		    for group_id, group in pairs_g(self._groups) do
	            for u_key, u_data in pairs_g(group.units) do
		        local nav_seg_id = u_data.tracker:nav_segment()
		        local current_objective = group.objective
		            if current_objective.coarse_path then
		                if not u_data.unit:sound():speaking(time) then
	                        u_data.unit:sound():say("m01", true)
		                end	
	                end					   
		        end	
		    end
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		end
	else
		local end_assault = false
		local enemies_left = self:_count_police_force("assault")

		if not self._hunt_mode then
		
			local min_enemies_left = nil

			if managers.skirmish:is_skirmish() then
				min_enemies_left = 10
			else
				min_enemies_left = 50
			end
			
			if enemies_left <= min_enemies_left or task_data.phase_end_t + 350 < t then
				if task_data.phase_end_t - 8 < t and not task_data.said_retreat then
					
					task_data.said_retreat = true

					self:_police_announce_retreat()
					local time = self._t
		            for group_id, group in pairs_g(self._groups) do
	                    for u_key, u_data in pairs_g(group.units) do
		                local nav_seg_id = u_data.tracker:nav_segment()
		                local current_objective = group.objective
		                    if current_objective.coarse_path then
		                        if not u_data.unit:sound():speaking(time) then
	                                u_data.unit:sound():say("m01", true)
		                        end	
	                        end					   
		                end	
		            end
				end
			end
			if task_data.phase_end_t < t and self:_count_criminals_engaged_force(4) <= 3 then
				end_assault = true
			end

			if task_data.force_end or end_assault then
				

				task_data.active = nil
				task_data.phase = nil
				task_data.said_retreat = nil
				task_data.force_end = nil
				local time = self._t
		        for group_id, group in pairs_g(self._groups) do
	                for u_key, u_data in pairs_g(group.units) do
		            local nav_seg_id = u_data.tracker:nav_segment()
		            local current_objective = group.objective
		                if current_objective.coarse_path then
		                    if not u_data.unit:sound():speaking(time) then
	                            u_data.unit:sound():say("m01", true)
		                    end	
	                    end					   
		            end	
		        end

				managers.mission:call_global_event("end_assault")
				self:_begin_regroup_task()

				return
			end
		end
	end

	local primary_target_area = nil
	
	if self._task_data.assault.target_areas then
		self._current_target_area = self._task_data.assault.target_areas[math.random(#self._task_data.assault.target_areas)]
		primary_target_area = self._current_target_area
	end

	if not primary_target_area or not self._current_target_area or self:is_area_safe_assault(primary_target_area) then
		self._task_data.assault.target_areas = self:_upd_assault_areas()
		
		if self._task_data.assault.target_areas then
			self._current_target_area = self._task_data.assault.target_areas[math.random(#self._task_data.assault.target_areas)]
			primary_target_area = self._current_target_area
		end
	end
	
	if task_data.phase ~= "fade" and task_data.phase ~= "anticipation"  then
		if task_data.use_smoke_timer < t then
			task_data.use_smoke = true
		end
	end

	self:detonate_queued_smoke_grenades()
	
	local enemy_count = self:_count_police_force("assault")
	local nr_wanted = task_data.force - self:_count_police_force("assault")

	if self._task_data.assault.target_areas and primary_target_area and nr_wanted > 0 and task_data.phase ~= "fade" and not self._activeassaultbreak and not self._feddensityhigh or self._task_data.assault.target_areas and primary_target_area and self._hunt_mode and nr_wanted > 0 and not self._activeassaultbreak and not self._feddensityhigh then
		local used_event = nil

		if task_data.use_spawn_event and task_data.phase ~= "anticipation" or task_data.use_spawn_event and self._hunt_mode then
			task_data.use_spawn_event = false

			if self:_try_use_task_spawn_event(t, primary_target_area, "assault") then
				used_event = true
			end
		end

		if not used_event then
			if next(self._spawning_groups) then
				-- Nothing
			else
				local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(primary_target_area, self._tweak_data.assault.groups, primary_target_area.pos, nil, nil)

				local area_to_approach = nil
			
				if primary_target_area.neighbours then
					local areas = {}
					local i = 1
					--sorround and lockdown the current target area with the power of RNG!
					for area_id, neighbour_area in pairs_g(primary_target_area.neighbours) do
						areas[i] = neighbour_area
						i = i + 1
					end
					
					area_to_approach = areas[math_random(#areas)]
				end
				
				if spawn_group then
					local grp_objective = {
						type = "assault_area",
						area = area_to_approach or primary_target_area,
						attitude = "avoid",
						pose = task_data.phase == "anticipation" and "crouch" or "stand",
						stance = "hos"
					}
					self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective, task_data)
				end
			end
		end
	end
	
	if self._task_data.assault.target_areas then
		self:_assign_enemy_groups_to_assault(task_data.phase)
	end
end

function GroupAIStateBesiege:_spawn_in_group(spawn_group, spawn_group_type, grp_objective, ai_task)
	local spawn_group_desc = tweak_data.group_ai.enemy_spawn_groups[spawn_group_type]
	local wanted_nr_units = nil

	if type(spawn_group_desc.amount) == "number" then
		wanted_nr_units = spawn_group_desc.amount
	else
		wanted_nr_units = math_random(spawn_group_desc.amount[1], spawn_group_desc.amount[2])
	end

	local valid_unit_types = {}

	self._extract_group_desc_structure(spawn_group_desc.spawn, valid_unit_types)

	local unit_categories = tweak_data.group_ai.unit_categories
	local total_wgt = 0
	local i = 1

	while i <= #valid_unit_types do
		local spawn_entry = valid_unit_types[i]
		local cat_data = unit_categories[spawn_entry.unit]

		if not cat_data then
			debug_pause("[GroupAIStateBesiege:_spawn_in_group] unit category doesn't exist:", spawn_entry.unit)

			return
		end

		local spawn_limit = managers.job:current_spawn_limit(cat_data.special_type)

		if cat_data.special_type and not cat_data.is_captain and spawn_limit < self:_get_special_unit_type_count(cat_data.special_type) + (spawn_entry.amount_min or 0) then
			spawn_group.delay_t = self._t + 10

			return
		else
			total_wgt = total_wgt + spawn_entry.freq
			i = i + 1
		end
	end

	for i = 1, #spawn_group.spawn_pts do
		local sp_data = spawn_group.spawn_pts[i]
		sp_data.delay_t = self._t + math.rand(0.5)
	end
	
	if grp_objective.area and not grp_objective.coarse_path then --allows groups to preemptively generate coarse_paths as they spawn to their intended destinations, need to set this up for recon and reenforce groups still, but this is a start
		local end_nav_seg = managers.navigation:get_nav_seg_from_pos(grp_objective.area.pos, true)
		local search_params = {
			id = "GroupAI_spawn",
			from_seg = spawn_group.nav_seg,
			to_seg = end_nav_seg,
			access_pos = "swat",
			verify_clbk = callback(self, self, "is_nav_seg_safe") --spawned in groups will try to path safely (avoiding direct contact) to sorround it if at all possible, in order to execute viable flanks as much as possible
		}
		local coarse_path = managers.navigation:search_coarse(search_params)
		
		if coarse_path then
			grp_objective.coarse_path = coarse_path
		else
			--if it fails, try without the verify_clbk and go head-first anyway, with a chance to take a much longer and wider path instead.
			local search_params = {
				id = "GroupAI_spawn",
				from_seg = spawn_group.nav_seg,
				to_seg = end_nav_seg,
				access_pos = "swat",
				long_path = math_random() < 0.5 and true
				--no verify_clbk
			}
			local coarse_path = managers.navigation:search_coarse(search_params)
			
			if coarse_path then
				grp_objective.coarse_path = coarse_path
			else
				grp_objective.coarse_path = {{spawn_group.nav_seg, spawn_group.area.pos}}
			end
		end
	end
	
	local spawn_task = {
		objective = not grp_objective.element and self._create_objective_from_group_objective(grp_objective),
		units_remaining = {},
		spawn_group = spawn_group,
		spawn_group_type = spawn_group_type,
		ai_task = ai_task
	}

	table.insert(self._spawning_groups, spawn_task)

	local function _add_unit_type_to_spawn_task(i, spawn_entry)
		local spawn_amount_mine = 1 + (spawn_task.units_remaining[spawn_entry.unit] and spawn_task.units_remaining[spawn_entry.unit].amount or 0)
		spawn_task.units_remaining[spawn_entry.unit] = {
			amount = spawn_amount_mine,
			spawn_entry = spawn_entry
		}
		wanted_nr_units = wanted_nr_units - 1

		if spawn_entry.amount_min then
			spawn_entry.amount_min = spawn_entry.amount_min - 1
		end

		if spawn_entry.amount_max then
			spawn_entry.amount_max = spawn_entry.amount_max - 1

			if spawn_entry.amount_max == 0 then
				table.remove(valid_unit_types, i)

				total_wgt = total_wgt - spawn_entry.freq

				return true
			end
		end
	end

	local i = 1

	while i <= #valid_unit_types do
		local spawn_entry = valid_unit_types[i]

		if i <= #valid_unit_types and wanted_nr_units > 0 and spawn_entry.amount_min and spawn_entry.amount_min > 0 and (not spawn_entry.amount_max or spawn_entry.amount_max > 0) then
			if not _add_unit_type_to_spawn_task(i, spawn_entry) then
				i = i + 1
			end
		else
			i = i + 1
		end
	end

	while wanted_nr_units > 0 and #valid_unit_types ~= 0 do
		local rand_wght = math_random() * total_wgt
		local rand_i = 1
		local rand_entry = nil

		repeat
			rand_entry = valid_unit_types[rand_i]
			rand_wght = rand_wght - rand_entry.freq

			if rand_wght <= 0 then
				break
			else
				rand_i = rand_i + 1
			end
		until false

		local cat_data = unit_categories[rand_entry.unit]
		local spawn_limit = managers.job:current_spawn_limit(cat_data.special_type)

		if cat_data.special_type and not cat_data.is_captain and spawn_limit <= self:_get_special_unit_type_count(cat_data.special_type) then
			table.remove(valid_unit_types, rand_i)

			total_wgt = total_wgt - rand_entry.freq
		else
			_add_unit_type_to_spawn_task(rand_i, rand_entry)
		end
	end

	local group_desc = {
		size = 0,
		type = spawn_group_type
	}

	for u_name, spawn_info in pairs(spawn_task.units_remaining) do
		group_desc.size = group_desc.size + spawn_info.amount
	end

	local group = self:_create_group(group_desc)
	
	self:_set_objective_to_enemy_group(group, grp_objective)
	group.team = self._teams[spawn_group.team_id or tweak_data.levels:get_default_team_ID("combatant")]
	spawn_task.group = group

	return group
end

function GroupAIStateBesiege:_assign_enemy_groups_to_assault(phase)
	for group_id, group in pairs_g(self._groups) do
		local grp_objective = group.objective
		if group.has_spawned and grp_objective.type == "assault_area" then
			if grp_objective.moving_out then
				local done_moving = nil

				for u_key, u_data in pairs_g(group.units) do
					local objective = u_data.unit:brain():objective()
					local move

					if objective then
						if objective.grp_objective ~= grp_objective then
							-- Nothing
						elseif not objective.in_place then
							if objective.area.nav_segs[u_data.unit:movement():nav_tracker():nav_segment()] then
								done_moving = true --due to how enemy pathing works, it'd be unescessary to check for all units in the group here.
							else
								done_moving = false
							end
						elseif done_moving == nil then
							done_moving = true
						end
					end
				end

				if done_moving == true then
					grp_objective.moving_out = nil
					group.in_place_t = self._t
					grp_objective.moving_in = nil

					self:_voice_move_complete(group)
				end
			end
			
			self:_set_assault_objective_to_group(group, phase)
		end
	end
end

function GroupAIStateBesiege:_check_phalanx_damage_reduction_increase()
end

function GroupAIStateBesiege:set_phalanx_damage_reduction_buff(damage_reduction)
	local law1team = self:_get_law1_team()
	damage_reduction = damage_reduction or -1
	law1team.damage_reduction = nil
	self:set_damage_reduction_buff_hud()

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_damage_reduction_buff", damage_reduction)
	end
end

function GroupAIStateBesiege:set_damage_reduction_buff_hud()
end

function GroupAIStateBesiege:assign_enemy_to_group_ai(unit, team_id)
	local u_tracker = unit:movement():nav_tracker()
	local seg = u_tracker:nav_segment()
	local area = self:get_area_from_nav_seg_id(seg)
	local current_unit_type = tweak_data.levels:get_ai_group_type()
	local u_name = unit:name()
	local u_category = nil

	for cat_name, category in pairs_g(tweak_data.group_ai.unit_categories) do
		local units = category.unit_types[current_unit_type]
		if units then
			for _, test_u_name in ipairs(units) do
				if u_name == test_u_name then
					u_category = cat_name

					break
				end
			end
		end
	end

	local group_desc = {
		size = 1,
		type = u_category or "custom"
	}
	local group = self:_create_group(group_desc)
	group.team = self._teams[team_id]
	local grp_objective = nil
	local objective = unit:brain():objective()
	local grp_obj_type = self._task_data.assault.active and "assault_area" or "recon_area"

	if objective then
		grp_objective = {
			type = grp_obj_type,
			area = objective.area or objective.nav_seg and self:get_area_from_nav_seg_id(objective.nav_seg) or area
		}
		objective.grp_objective = grp_objective
	else
		grp_objective = {
			type = grp_obj_type,
			area = area
		}
	end

	grp_objective.moving_out = false
	group.objective = grp_objective
	group.has_spawned = true

	self:_add_group_member(group, unit:key())
	self:set_enemy_assigned(area, unit:key())
end

function GroupAIStateBesiege:_assign_skirmish_groups_to_retire(group)
	--this is horrible, but it works.
	for group_id, group in pairs_g(self._groups) do --this acquires the groups currently existing in the level.
		local group_leader_u_key, group_leader_u_data = self._determine_group_leader(group.units)
		local tactics_map = nil

		if group_leader_u_data and group_leader_u_data.tactics then
			tactics_map = {}

			for _, tactic_name in ipairs(group_leader_u_data.tactics) do
				tactics_map[tactic_name] = true
			end
		end
		
		if managers.skirmish:is_skirmish() and tactics_map then
			if tactics_map.skirmish and group.objective.type ~= "retire" and not  self._task_data.assault.active then
				local function suitable_grp_func(group)
					if tactics_map.skirmish and group.objective.type ~= "retire" and not  self._task_data.assault.active then
						local grp_objective = {
							stance = "hos",
							attitude = "avoid",
							pose = "stand",
							type = "assault_area",
							area = group.objective.area
						}

						self:_set_objective_to_enemy_group(group, grp_objective)
					end
				end
				--log("retiring all enemies")
				self:_assign_groups_to_retire(self._tweak_data.assault.groups, suitable_grp_func)
			end			
		end
	end
end

function GroupAIStateBesiege:_upd_recon_tasks()
	local task_data = self._task_data.recon.tasks[1]
	
	--if managers.skirmish:is_skirmish() then --makes unfit units retire during control/recon, mostly used as a safety measure to prevent leftovers
	--	self:_assign_skirmish_groups_to_retire(allowed_groups, suitable_grp_func, group)
	--end
	
	self:_assign_enemy_groups_to_recon()

	if not task_data then
		return
	end

	local t = self._t

	self:_assign_assault_groups_to_retire()

	local target_pos = task_data.target_area.pos
	local nr_wanted = self:_get_difficulty_dependent_value(self._tweak_data.recon.force) - self:_count_police_force("recon")

	if nr_wanted <= 0 then
		return
	end

	local used_event, used_spawn_points, reassigned = nil

	if task_data.use_spawn_event then
		task_data.use_spawn_event = false

		if self:_try_use_task_spawn_event(t, task_data.target_area, "recon") then
			used_event = true
		end
	end

	if not used_event then
		local used_group = nil

		if next(self._spawning_groups) then
			used_group = true
		else
			local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(task_data.target_area, self._tweak_data.recon.groups, nil, nil, callback(self, self, "_verify_anticipation_spawn_point"))

			if spawn_group then
				local grp_objective = {
					attitude = "avoid",
					scan = true,
					stance = "hos",
					type = "recon_area",
					area = task_data.target_area,
					target_area = task_data.target_area
				}

				self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective)

				used_group = true
			end
		end
	end

	if used_event or used_spawn_points or reassigned then
		table_remove(self._task_data.recon.tasks, 1)

		self._task_data.recon.next_dispatch_t = t + math.ceil(self:_get_difficulty_dependent_value(self._tweak_data.recon.interval)) + math.random() * self._tweak_data.recon.interval_variation
	end
end

function GroupAIStateBesiege._create_objective_from_group_objective(grp_objective, receiving_unit)
	local objective = {
		grp_objective = grp_objective
	}

	if grp_objective.element then
		objective = grp_objective.element:get_random_SO(receiving_unit)

		if not objective then
			return
		end

		objective.grp_objective = grp_objective

		return
	elseif grp_objective.type == "defend_area" or grp_objective.type == "recon_area" or grp_objective.type == "reenforce_area" then
		objective.type = "defend_area"
		objective.stance = "hos"
		objective.pose = "stand"
		objective.scan = true
		objective.interrupt_dis = 200
		objective.interrupt_suppression = nil
	elseif grp_objective.type == "retire" then
		objective.type = "defend_area"
		objective.running = true
		objective.stance = "hos"
		objective.pose = "stand"
		objective.scan = true
		objective.no_arrest = true
	elseif grp_objective.type == "assault_area" then
		objective.type = "defend_area"

		if grp_objective.follow_unit then
			objective.follow_unit = grp_objective.follow_unit
			objective.distance = grp_objective.distance
		end
		
		objective.no_arrest = true
		objective.stance = "hos"
		objective.pose = "stand"
		objective.scan = true
		objective.interrupt_dis = nil
		objective.interrupt_suppression = nil
	elseif grp_objective.type == "create_phalanx" then
		objective.type = "phalanx"
		objective.stance = "hos"
		objective.interrupt_dis = nil
		objective.interrupt_health = nil
		objective.interrupt_suppression = nil
		objective.attitude = "avoid"
		objective.path_ahead = true
	elseif grp_objective.type == "hunt" then
		objective.type = "hunt"
		objective.stance = "hos"
		objective.scan = true
		objective.interrupt_dis = 200
	end

	objective.stance = grp_objective.stance or objective.stance
	objective.pose = grp_objective.pose or objective.pose
	objective.area = grp_objective.area
	objective.nav_seg = grp_objective.nav_seg or objective.area.pos_nav_seg
	objective.attitude = grp_objective.attitude or objective.attitude
	
	if not objective.no_arrest then
		objective.no_arrest = not objective.attitude or objective.attitude == "avoid"
	end
	
	objective.interrupt_dis = grp_objective.interrupt_dis or objective.interrupt_dis
	objective.interrupt_health = grp_objective.interrupt_health or objective.interrupt_health
	objective.interrupt_suppression = nil
	objective.pos = grp_objective.pos
	objective.bagjob = grp_objective.bagjob or nil
	objective.hostagejob = grp_objective.hostagejob or nil
	
	if not objective.running then
		objective.interrupt_dis = nil
		objective.running = grp_objective.running or nil
	end

	if grp_objective.scan ~= nil then
		objective.scan = grp_objective.scan
	end

	if grp_objective.coarse_path then
		objective.path_style = "coarse_complete"
		objective.path_data = grp_objective.coarse_path
	end

	return objective
end


function GroupAIStateBesiege:is_smoke_grenade_active() --this functions differently, check for if use_smoke IS a thing instead
	if not self._task_data.assault.use_smoke then
		return
	end
	
	return self._task_data.assault.use_smoke
end

function GroupAIStateBesiege:_begin_assault_task(assault_areas)
	local assault_task = self._task_data.assault
	assault_task.active = true
	assault_task.next_dispatch_t = nil
	assault_task.target_areas = assault_areas or self:_upd_assault_areas(nil)
	self._current_target_area = self._task_data.assault.target_areas[1]	
	assault_task.phase = "anticipation"
	assault_task.start_t = self._t
	local anticipation_duration = self:_get_anticipation_duration(self._tweak_data.assault.anticipation_duration, assault_task.is_first)
	assault_task.is_first = nil
	assault_task.phase_end_t = self._t + anticipation_duration
	if managers.skirmish:is_skirmish() then
		if assault_task.is_first or self._assault_number and self._assault_number == 1 or not self._assault_number then
			assault_task.force = math.ceil(self:_get_difficulty_dependent_value(self._tweak_data.assault.force) * self:_get_balancing_multiplier(self._tweak_data.assault.force_balance_1st))
		elseif self._assault_number == 2 then
			assault_task.force = math.ceil(self:_get_difficulty_dependent_value(self._tweak_data.assault.force) * self:_get_balancing_multiplier(self._tweak_data.assault.force_balance_2nd))
			--log("is it working?")
		elseif self._assault_number == 3 then
			assault_task.force = math.ceil(self:_get_difficulty_dependent_value(self._tweak_data.assault.force) * self:_get_balancing_multiplier(self._tweak_data.assault.force_balance_3rd))
		elseif self._assault_number == 4 then
			assault_task.force = math.ceil(self:_get_difficulty_dependent_value(self._tweak_data.assault.force) * self:_get_balancing_multiplier(self._tweak_data.assault.force_balance_4th))
		elseif self._assault_number == 5 then
			assault_task.force = math.ceil(self:_get_difficulty_dependent_value(self._tweak_data.assault.force) * self:_get_balancing_multiplier(self._tweak_data.assault.force_balance_5th))
		elseif self._assault_number == 6 then
			assault_task.force = math.ceil(self:_get_difficulty_dependent_value(self._tweak_data.assault.force) * self:_get_balancing_multiplier(self._tweak_data.assault.force_balance_6th))
		elseif self._assault_number >= 7 then
			assault_task.force = math.ceil(self:_get_difficulty_dependent_value(self._tweak_data.assault.force) * self:_get_balancing_multiplier(self._tweak_data.assault.force_balance_7up))
		else
			assault_task.force = math.ceil(self:_get_difficulty_dependent_value(self._tweak_data.assault.force) * self:_get_balancing_multiplier(self._tweak_data.assault.force_balance_1st))
			--log("bruh moment")
		end
	else
		assault_task.force = math.ceil(self:_get_difficulty_dependent_value(self._tweak_data.assault.force) * self:_get_balancing_multiplier(self._tweak_data.assault.force_balance_mul))
	end
	assault_task.use_smoke = true
	assault_task.use_smoke_timer = 0
	assault_task.use_spawn_event = true
	assault_task.force_spawned = 0

	if self._hostage_headcount > 0 then
		assault_task.phase_end_t = assault_task.phase_end_t + self:_get_difficulty_dependent_value(self._tweak_data.assault.hostage_hesitation_delay)
		assault_task.is_hesitating = true
		assault_task.voice_delay = self._t + (assault_task.phase_end_t - self._t) / 2
	end

	self._downs_during_assault = 0

	if self._hunt_mode then
		assault_task.phase_end_t = 0
	else
		managers.hud:setup_anticipation(anticipation_duration)
		managers.hud:start_anticipation()
	end

	if self._draw_drama then
		table_insert(self._draw_drama.assault_hist, {
			self._t
		})
	end

	self._task_data.recon.tasks = {}
end

local function make_dis_id(from, to)
	local f = from < to and from or to
	local t = to < from and from or to

	return tostring(f) .. "-" .. tostring(t)
end

local function spawn_group_id(spawn_group)
	return spawn_group.mission_element:id()
end

function GroupAIStateBesiege:_find_spawn_group_near_area(target_area, allowed_groups, target_pos, max_dis, verify_clbk)
	local all_areas = self._area_data
	
	max_dis = max_dis and max_dis * max_dis
	local min_dis = 2250000
		
	local t = self._t
	local valid_spawn_groups = {}
	local valid_spawn_group_distances = {}
	local total_dis = 0
	target_pos = target_pos or target_area.pos
	local to_search_areas = {
		target_area
	}
	local found_areas = {
		[target_area.id] = true
	}

	repeat
		local search_area = table_remove(to_search_areas, 1)
		local spawn_groups = search_area.spawn_groups

		if spawn_groups then
			for i = 1, #spawn_groups do
				local spawn_group = spawn_groups[i]
				if spawn_group.delay_t <= t and (not verify_clbk or verify_clbk(spawn_group)) then
					local dis_id = make_dis_id(spawn_group.nav_seg, target_area.pos_nav_seg)

					if not self._graph_distance_cache[dis_id] then
						local coarse_params = {
							access_pos = "swat",
							from_seg = spawn_group.nav_seg,
							to_seg = target_area.pos_nav_seg,
							id = dis_id
						}
						local path = managers.navigation:search_coarse(coarse_params)

						if path and #path >= 2 then
							local dis = 0
							local current = spawn_group.pos

							for i = 2, #path do
								local nxt = path[i][2]

								if current and nxt then
									dis = dis + mvec3_dis_sq(current, nxt)
								end

								current = nxt
							end

							self._graph_distance_cache[dis_id] = dis
						end
					end

					if self._graph_distance_cache[dis_id] then
						local my_dis = self._graph_distance_cache[dis_id]
						
						local should_add_spawngroup = true
						--log(tostring(my_dis))
						--log(tostring(min_dis))
						if min_dis and min_dis > my_dis then
							should_add_spawngroup = nil
							--log("piss")
						end
						
						if max_dis and my_dis > max_dis then
							should_add_spawngroup = nil
							--log("piss2")
						end
						
						if should_add_spawngroup then
							--log("confusion")
							total_dis = total_dis + my_dis
							valid_spawn_groups[spawn_group_id(spawn_group)] = spawn_group
							valid_spawn_group_distances[spawn_group_id(spawn_group)] = my_dis
						end	
					end
				end
			end
		end

		for other_area_id, other_area in pairs_g(all_areas) do
			if not found_areas[other_area_id] and other_area.neighbours[search_area.id] then
				table_insert(to_search_areas, other_area)

				found_areas[other_area_id] = true
			end
		end
	until #to_search_areas == 0

	local time = TimerManager:game():time()
	local spawn_group_number = #valid_spawn_groups
	
	if spawn_group_number and spawn_group_number > 1 then
		for id in pairs_g(valid_spawn_groups) do
			if self._spawn_group_timers[id] and time < self._spawn_group_timers[id] then
				valid_spawn_groups[id] = nil
				valid_spawn_group_distances[id] = nil
			end
		end
	end
	
	local delays = {10, 15}

	if total_dis == 0 then
		total_dis = 1
	end

	local total_weight = 0
	local candidate_groups = {}
	self._debug_weights = {}
	local dis_limit = max_dis or 64000000 --80 meters
	
	for i, dis in pairs_g(valid_spawn_group_distances) do
		local my_wgt = math_lerp(1, 0.2, math.min(1, dis / dis_limit)) * 5
		local my_spawn_group = valid_spawn_groups[i]
		local my_group_types = my_spawn_group.mission_element:spawn_groups()
		my_spawn_group.distance = dis
		total_weight = total_weight + self:_choose_best_groups(candidate_groups, my_spawn_group, my_group_types, allowed_groups, my_wgt)
	end

	if total_weight == 0 then
		return
	end

	--[[for _, group in ipairs(candidate_groups) do
		table_insert(self._debug_weights, clone(group))
	end]]

	return self:_choose_best_group(candidate_groups, total_weight, delays)
end

function GroupAIStateBesiege:_choose_best_group(best_groups, total_weight, delays)
	local rand_wgt = total_weight * math_random()
	local best_grp, best_grp_type = nil

	for i = 1, #best_groups do
		local candidate = best_groups[i]
		rand_wgt = rand_wgt - candidate.wght
		
		if rand_wgt <= 0 then
			if delays then
				self._spawn_group_timers[spawn_group_id(candidate.group)] = TimerManager:game():time() + math_lerp(delays[1], delays[2], math_random())
			end
			best_grp = candidate.group
			best_grp_type = candidate.group_type
			best_grp.delay_t = self._t + best_grp.interval

			break
		end
	end

	return best_grp, best_grp_type
end

function GroupAIStateBesiege:apply_grenade_cooldown(flash)

	if not self._task_data.assault then
		return
	end
	
	local task_data = self._task_data.assault
	local duration = tweak_data.group_ai.smoke_grenade_lifetime
	local cooldown = math.lerp(tweak_data.group_ai.smoke_and_flash_grenade_timeout[1], tweak_data.group_ai.smoke_and_flash_grenade_timeout[2], math.random())
	
	if flash then
		duration = 4
		cooldown = cooldown * 0.5
	end

	cooldown = cooldown + duration
	
	task_data.use_smoke_timer = self._t + cooldown
	task_data.use_smoke = nil
	
end
