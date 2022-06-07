local mvec3_n_equal = mvector3.not_equal
local mvec3_set = mvector3.set
local mvec3_set_st = mvector3.set_static
local mvec3_set_z = mvector3.set_z
local mvec3_step = mvector3.step
local mvec3_sub = mvector3.subtract
local mvec3_norm = mvector3.normalize
local mvec3_dir = mvector3.direction
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_div = mvector3.divide
local mvec3_lerp = mvector3.lerp
local mvec3_cpy = mvector3.copy
local mvec3_set_l = mvector3.set_length
local mvec3_dot = mvector3.dot
local mvec3_cross = mvector3.cross
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_rot = mvector3.rotate_with
local math_abs = math.abs
local math_max = math.max
local math_clamp = math.clamp
local math_ceil = math.ceil
local math_floor = math.floor
local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
local math_up = math.UP
local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
NavigationManager = NavigationManager or class()
NavigationManager.nav_states = {
	"allow_access",
	"forbid_access",
	"forbid_custom"
}
NavigationManager.nav_meta_operations = {
	"force_civ_submission",
	"relieve_forced_civ_submission"
}
NavigationManager.COVER_RESERVED = 4
NavigationManager.COVER_RESERVATION = 5
NavigationManager.ACCESS_FLAGS_VERSION = 1
NavigationManager.ACCESS_FLAGS = {
	"civ_male",
	"civ_female",
	"gangster",
	"security",
	"security_patrol",
	"cop",
	"fbi",
	"swat",
	"murky",
	"sniper",
	"spooc",
	"shield",
	"tank",
	"taser",
	"teamAI1",
	"teamAI2",
	"teamAI3",
	"teamAI4",
	"SO_ID1",
	"SO_ID2",
	"SO_ID3",
	"pistol",
	"rifle",
	"ntl",
	"hos",
	"run",
	"fumble",
	"sprint",
	"crawl",
	"climb"
}
NavigationManager.ACCESS_FLAGS_OLD = {}

function NavigationManager:update(t, dt)
	
	if #self._covers == 0 then
		self:register_cover_units(true) --run this in order to allow LUA-based cover searches.
	end
	
	self:_commence_coarce_searches(t)
end

function NavigationManager:_clamp_pos_to_field(pos, allow_disabled)
	if not pos then
		return
	end
	
	local pos_tracker = self:create_nav_tracker(pos, allow_disabled)
	
	local clamped_pos = mvec3_cpy(pos_tracker:field_position())
	
	self:destroy_nav_tracker(pos_tracker)
	
	return clamped_pos
end

function NavigationManager:register_cover_units(please)
	if not please and not self:is_data_ready() then
		return
	end

	local rooms = self._rooms
	local covers = {}
	local cover_data = managers.worlddefinition:get_cover_data()
	local t_ins = table.insert

	if cover_data then
		local function _register_cover(pos, fwd)
			local nav_tracker = self._quad_field:create_nav_tracker(pos, true)
			local cover = {
				nav_tracker:field_position(),
				fwd,
				nav_tracker
			}

			if please or self._debug then
				t_ins(covers, cover)
			end

			local location_script_data = self._quad_field:get_script_data(nav_tracker, true)

			if not location_script_data.covers then
				location_script_data.covers = {}
			end

			t_ins(location_script_data.covers, cover)
		end

		local tmp_rot = Rotation(0, 0, 0)

		if cover_data.rotations then
			local rotations = cover_data.rotations

			for i, yaw in ipairs(cover_data.rotations) do
				mrotation.set_yaw_pitch_roll(tmp_rot, yaw, 0, 0)
				mrotation.y(tmp_rot, temp_vec1)
				_register_cover(cover_data.positions[i], mvector3.copy(temp_vec1))
			end
		else
			for _, cover_desc in ipairs(cover_data) do
				mrotation.set_yaw_pitch_roll(tmp_rot, cover_desc[2], 0, 0)
				mrotation.y(tmp_rot, temp_vec1)
				_register_cover(cover_desc[1], mvector3.copy(temp_vec1))
			end
		end
	else
		local all_cover_units = World:find_units_quick("all", managers.slot:get_mask("cover"))

		for i, unit in ipairs(all_cover_units) do
			local pos = unit:position()
			local fwd = unit:rotation():y()
			local nav_tracker = self._quad_field:create_nav_tracker(pos, true)
			local cover = {
				nav_tracker:field_position(),
				fwd,
				nav_tracker,
				true
			}

			if please or self._debug then
				t_ins(covers, cover)
			end

			local location_script_data = self._quad_field:get_script_data(nav_tracker)

			if not location_script_data.covers then
				location_script_data.covers = {}
			end

			t_ins(location_script_data.covers, cover)
			self:_safe_remove_unit(unit)
		end
	end

	self._covers = covers
end

function NavigationManager:draw_coarse_path(path, alt_color)
	if not path then
		return
	end
	
	local all_nav_segs = self._nav_segments
	
	local line1 = Draw:brush(Color.red:with_alpha(0.5), 5)
	local line2 = Draw:brush(Color.blue:with_alpha(0.5), 5)
	
	if alt_color then
		for path_i = 1, #path do
			local seg_pos = all_nav_segs[path[path_i][1]].pos
			line2:cylinder(seg_pos, seg_pos + math_up * 185, 20)
		end
	else
		for path_i = 1, #path do
			local seg_pos = all_nav_segs[path[path_i][1]].pos
			line1:cylinder(seg_pos, seg_pos + math_up * 185, 20)
		end
	end
end

function NavigationManager:shorten_coarse_through_dis(path)
	do return path end
	
	local i = 1
	local all_nav_segs = self._nav_segments
	local done = nil
	
	--log("indexes before: " .. tostring(#path) .. "")
	--local line1 = Draw:brush(Color.red:with_alpha(0.5), 5)
	
	while not done do 
		if path[i + 1] and i + 1 < #path then
			local i_seg_pos_1 = all_nav_segs[path[i][1]].pos
			local i_seg_pos_2 = all_nav_segs[path[i + 1][1]].pos
			
			if math_abs(i_seg_pos_1.z - i_seg_pos_2.z) < 185 then 
				local travel_dis = mvec3_dis(i_seg_pos_1, i_seg_pos_2)
				
				if travel_dis < 800 then
					local new_path = {}
					
					for path_i = 1, #path do
						if path_i ~= i + 1	then
							new_path[#new_path + 1] = path[path_i]
						end
					end
					path = deep_clone(new_path)			
				elseif math_abs(i_seg_pos_1.z - i_seg_pos_2.z) < 93 then 
					local ray_params = {
						allow_entry = false,
						pos_from = i_seg_pos_1,
						pos_to = i_seg_pos_2
					}

					if not self:raycast(ray_params) then
						local new_path = {}
						--line1:cylinder(i_seg_pos_2, i_seg_pos_2 + math_up * 185, 20)
						for path_i = 1, #path do
							if path_i ~= i + 1	then
								new_path[#new_path + 1] = path[path_i]
							end
						end
						path = deep_clone(new_path)
					end
				end
			end
			
			i = i + 1
		else
			done = true
		end
	end
	
	--log("indexes after: " .. tostring(#path) .. "")
	
	--local line2 = Draw:brush(Color.blue:with_alpha(0.5), 5)
	
	--for path_i = 1, #path do
	--	local seg_pos = all_nav_segs[path[path_i][1]].pos
	--	line2:cylinder(seg_pos, seg_pos + math_up * 185, 20)
	--end
	
	return path
end

function NavigationManager:search_coarse(params)
	local pos_to, start_i_seg, end_i_seg, access_pos, access_neg = nil

	if params.from_seg then
		start_i_seg = params.from_seg
	elseif params.from_tracker then
		start_i_seg = params.from_tracker:nav_segment()
	end

	if params.to_seg then
		end_i_seg = params.to_seg
	elseif params.to_tracker then
		end_i_seg = params.to_tracker:nav_segment()
	end

	pos_to = params.to_pos or self._nav_segments[end_i_seg].pos

	if start_i_seg == end_i_seg then
		if params.results_clbk then
			params.results_clbk({
				{
					start_i_seg
				},
				{
					end_i_seg,
					mvec3_cpy(pos_to)
				}
			})

			return
		else
			return {
				{
					start_i_seg
				},
				{
					end_i_seg,
					mvec3_cpy(pos_to)
				}
			}
		end
	end

	if type_name(params.access_pos) == "table" then
		access_pos = self._quad_field:convert_access_filter_to_number(params.access_pos)
	elseif type_name(params.access_pos) == "string" then
		access_pos = self._quad_field:convert_nav_link_flag_to_bitmask(params.access_pos)
	else
		access_pos = params.access_pos
	end

	if params.access_neg then
		access_neg = self._quad_field:convert_nav_link_flag_to_bitmask(params.access_neg)
	else
		access_neg = 0
	end

	local new_search_data = {
		id = params.id,
		long_path = params.long_path,
		to_pos = mvec3_cpy(pos_to),
		start_i_seg = start_i_seg,
		end_i_seg = end_i_seg,
		seg_searched = {},
		discovered_seg = {
			[start_i_seg] = true
		},
		seg_to_search = {
			{
				i_seg = start_i_seg
			}
		},
		results_callback = params.results_clbk,
		verify_clbk = params.verify_clbk,
		access_pos = access_pos,
		access_neg = access_neg
	}

	if params.results_clbk then
		table.insert(self._coarse_searches, new_search_data)
	else
		local result = self:_execute_coarce_search(new_search_data)

		return result
	end
end

function NavigationManager:_execute_coarce_search(search_data)
	local search_id = search_data.id
	local i = 0

	while true do
		if i == 500 then
			log("endless")

			return false
		else
			i = i + 1
		end

		local next_search_seg = search_data.seg_to_search[#search_data.seg_to_search]
		local next_search_i_seg = next_search_seg.i_seg

		table.remove(search_data.seg_to_search)

		local all_nav_segments = self._nav_segments
		local neighbours = all_nav_segments[next_search_i_seg].neighbours

		if neighbours[search_data.end_i_seg] then
			local entry_found = nil

			for _, i_door in ipairs(neighbours[search_data.end_i_seg]) do
				if type(i_door) == "number" then
					entry_found = true

					break
				elseif i_door:delay_time() < TimerManager:game():time() and i_door:check_access(search_data.access_pos, search_data.access_neg) then
					entry_found = true

					break
				end
			end

			if entry_found then
				local i_seg = next_search_i_seg
				local this_seg = next_search_seg
				local prev_seg = search_data.end_i_seg
				local path = {
					{
						search_data.end_i_seg,
						search_data.to_pos
					}
				}

				table.insert(path, 1, {
					next_search_i_seg,
					next_search_seg.pos
				})

				local searched = search_data.seg_searched

				while this_seg.from do
					i_seg = this_seg.from
					this_seg = searched[i_seg]

					table.insert(path, 1, {
						i_seg,
						this_seg.pos
					})
				end

				return path
			end
		end

		local to_pos = search_data.to_pos
		local new_segments = self:_sort_nav_segs_after_pos(to_pos, next_search_i_seg, search_data.discovered_seg, search_data.verify_clbk, search_data.access_pos, search_data.access_neg, search_data.long_path)

		if new_segments then
			if search_data.access_pos then
				for i_seg, data in pairs(new_segments) do
					if self._quad_field:is_nav_segment_blocked(i_seg, search_data.access_pos) then
						new_segments[i_seg] = nil
					end
				end
			end

			local to_search = search_data.seg_to_search

			for i_seg, seg_data in pairs(new_segments) do
				local new_seg_weight = seg_data.weight
				local search_index = #to_search
				if search_data.long_path then
					local weight_mul = math.lerp(1, 2, math.random())
				
					new_seg_weight = new_seg_weight * weight_mul
					while search_index > 0 and to_search[search_index].weight > new_seg_weight do
						search_index = search_index - 1
					end
				else
					while search_index > 0 and to_search[search_index].weight < new_seg_weight do
						search_index = search_index - 1
					end
				end

				table.insert(to_search, search_index + 1, seg_data)
			end
		end

		local nr_seg_to_search = #search_data.seg_to_search

		if nr_seg_to_search == 0 then
			return false
		else
			search_data.seg_searched[next_search_i_seg] = next_search_seg
		end
	end
end

function NavigationManager:_sort_nav_segs_after_pos(to_pos, i_seg, ignore_seg, verify_clbk, access_pos, access_neg, long_path)
	local all_segs = self._nav_segments
	local all_doors = self._room_doors
	local all_rooms = self._rooms
	local seg = all_segs[i_seg]
	local neighbours = seg.neighbours
	local found_segs = nil

	for neighbour_seg_id, door_list in pairs(neighbours) do
		if not ignore_seg[neighbour_seg_id] and not all_segs[neighbour_seg_id].disabled and (not verify_clbk or verify_clbk(neighbour_seg_id)) then
			for i = 1, #door_list do
				local i_door = door_list[i]
				
				if type(i_door) == "number" then
					local door = all_doors[i_door]
					local door_pos = door.center
					local weight = mvec3_dis_sq(door_pos, to_pos)

					if found_segs then
						if found_segs[neighbour_seg_id] then
							if long_path and weight > found_segs[neighbour_seg_id].weight or weight < found_segs[neighbour_seg_id].weight then
								found_segs[neighbour_seg_id] = {
									weight = weight,
									from = i_seg,
									i_seg = neighbour_seg_id,
									pos = door_pos
								}
							end
						else
							found_segs[neighbour_seg_id] = {
								weight = weight,
								from = i_seg,
								i_seg = neighbour_seg_id,
								pos = door_pos
							}
							ignore_seg[neighbour_seg_id] = true
						end
					else
						found_segs = {
							[neighbour_seg_id] = {
								weight = weight,
								from = i_seg,
								i_seg = neighbour_seg_id,
								pos = door_pos
							}
						}
						ignore_seg[neighbour_seg_id] = true
					end
				elseif not alive(i_door) then
					debug_pause("[NavigationManager:_sort_nav_segs_after_pos] dead nav_link! between NavSegments", i_seg, "-", neighbour_seg_id)
				elseif not i_door:is_obstructed() and i_door:delay_time() < TimerManager:game():time() and i_door:check_access(access_pos, access_neg) then
					local end_pos = i_door:script_data().element:nav_link_end_pos()
					local my_weight = mvec3_dis_sq(end_pos, to_pos)

					if found_segs then
						if found_segs[neighbour_seg_id] then
							if long_path and my_weight > found_segs[neighbour_seg_id].weight or my_weight < found_segs[neighbour_seg_id].weight then
								found_segs[neighbour_seg_id] = {
									weight = my_weight,
									from = i_seg,
									i_seg = neighbour_seg_id,
									pos = end_pos
								}
							end
						else
							found_segs[neighbour_seg_id] = {
								weight = my_weight,
								from = i_seg,
								i_seg = neighbour_seg_id,
								pos = end_pos
							}
							ignore_seg[neighbour_seg_id] = true
						end
					else
						found_segs = {
							[neighbour_seg_id] = {
								weight = my_weight,
								from = i_seg,
								i_seg = neighbour_seg_id,
								pos = end_pos
							}
						}
						ignore_seg[neighbour_seg_id] = true
					end
				end
			end
		end
	end

	return found_segs
end

function NavigationManager:_strip_nav_field_for_gameplay()
	local all_doors = self._room_doors
	local all_rooms = self._rooms
	local i_door = #all_doors

	while i_door ~= 0 do
		local door = all_doors[i_door]
		local seg_1 = self:get_nav_seg_from_i_room(door.rooms[1])
		local seg_2 = self:get_nav_seg_from_i_room(door.rooms[2])

		if seg_1 == seg_2 then
			all_doors[i_door] = nil
		else
			local stripped_door = {
				center = door.pos
			}

			mvector3.lerp(stripped_door.center, door.pos, door.pos1, 0.5)

			all_doors[i_door] = stripped_door
		end

		i_door = i_door - 1
	end

	for nav_seg_id, nav_seg in pairs(self._nav_segments) do
		nav_seg.rooms = nil
		nav_seg.vis_groups = nil
	end

	self._rooms = {}
	self._geog_segments = {}
	self._geog_segment_offset = nil
	self._visibility_groups = {}
	self._helper_blockers = nil
	self._builder = nil
end

function NavigationManager:_find_cover_in_seg_through_lua(threat_vis_pos, near_pos, slotmask, access_pos, desired_segs)
	local v3_dis_sq = mvec3_dis_sq
	local world_g = World
	local nav_segs = desired_segs
	local nav_seg = nil
	
	--log(tostring(max_dis) .. ":" .. tostring(min_dis) .. ":" .. tostring(optimal_dis))
	
	if type(desired_segs) ~= "table" then
		nav_seg = desired_segs
		nav_segs = nil
	end
	
	local function _f_check_cover_dis(cover, near_pos) --checking the distance of the cover to the near_pos
		local dis_sq = v3_dis_sq
		local cover_dis = dis_sq(cover[1], near_pos)
		
		return cover_dis
	end
	
	local function _f_check_cover_rays(cover, threat_vis_pos, slotmask) --this is a visibility check. first checking for crouching positions, then standing.
		local cover_pos = cover[1]
		local ray_from = temp_vec1

		mvec3_set(ray_from, math_up)
		mvec3_mul(ray_from, 82)
		mvec3_add(ray_from, cover_pos)

		local ray_to_pos = threat_vis_pos

		local low_ray = world_g:raycast("ray", ray_from, ray_to_pos, "slot_mask", slotmask, "ray_type", "ai_vision", "report")
		local high_ray = nil

		if low_ray then
			mvec3_set_z(ray_from, ray_from.z + 82)

			high_ray = world_g:raycast("ray", ray_from, ray_to_pos, "slot_mask", slotmask, "ray_type", "ai_vision", "report")
		end

		return low_ray, high_ray
	end
	
	local best_cover, best_cover_dis, best_cover_low_ray, best_cover_high_ray

	for i = 1, #self._covers do
		local cover = self._covers[i]
		
		if not cover[self.COVER_RESERVED] then
			if nav_segs and nav_segs[cover[3]:nav_segment()] or nav_seg == cover[3]:nav_segment() then
				if near_pos then
					cover_dis = _f_check_cover_dis(cover, near_pos)
				end
				
				if not best_cover_dis or cover_dis < best_cover_dis then
					local cover_low_ray, cover_high_ray
					
					if threat_vis_pos then
						cover_low_ray, cover_high_ray = _f_check_cover_rays(cover, threat_vis_pos, slotmask)
					end
							
					if not best_cover_low_ray or cover_low_ray then
						if not best_cover_high_ray or cover_high_ray then
							best_cover = cover
							best_cover_dis = cover_dis
							best_cover_low_ray = cover_low_ray
							best_cover_high_ray = cover_high_ray
						end
					end
				end
			end
		end
	end
	
	return best_cover
end

function NavigationManager:_find_cover_through_lua(threat_pos, threat_vis_pos, near_pos, max_dis, min_dis, slotmask, access_pos, unit_nav_tracker)
	local v3_dis_sq = mvec3_dis_sq
	local world_g = World
	
	--log(tostring(max_dis) .. ":" .. tostring(min_dis) .. ":" .. tostring(optimal_dis))
	max_dis = max_dis and max_dis * max_dis or 490000
	min_dis = min_dis and min_dis * min_dis
	optimal_dis = optimal_dis and optimal_dis * optimal_dis
	
	local function _f_check_optimal_dis(cover, near_pos, optimal_dis) --if the cover is an optimal distance from our near position, the lower, the more optimal the cover.
		local dis_sq = v3_dis_sq
		local cover_dis = dis_sq(cover[1], near_pos)
		
		if cover_dis > optimal_dis then
			return
		else
			return cover_dis
		end
	end
	
	local function _f_check_max_dis(cover, near_pos, max_dis) --checking if the cover is further than our max search distance.
		local dis_sq = v3_dis_sq
		local cover_dis = dis_sq(cover[1], near_pos)
		
		if cover_dis > max_dis then
			return
		else
			return true
		end
	end
	
	local function _f_check_min_dis(cover, threat_pos, min_dis) --minimum distance from threat.
		if not threat_pos then
			return
		end
	
		local dis_sq = v3_dis_sq
		local cover_dis = dis_sq(cover[1], threat_pos)
		
		if cover_dis < min_dis then
			return
		else
			return cover_dis
		end
	end
	
	local function _f_check_cover_rays(cover, threat_vis_pos, slotmask) --this is a visibility check. first checking for crouching positions, then standing.
		local cover_pos = cover[1]
		local ray_from = temp_vec1

		mvec3_set(ray_from, math_up)
		mvec3_mul(ray_from, 82)
		mvec3_add(ray_from, cover_pos)

		local ray_to_pos = threat_vis_pos

		local low_ray = world_g:raycast("ray", ray_from, ray_to_pos, "slot_mask", slotmask, "ray_type", "ai_vision", "report")
		local high_ray = nil

		if low_ray then
			mvec3_set_z(ray_from, ray_from.z + 82)

			high_ray = world_g:raycast("ray", ray_from, ray_to_pos, "slot_mask", slotmask, "ray_type", "ai_vision", "report")
		end

		return low_ray, high_ray
	end
	
	local best_cover, best_cover_optimal_dis, best_cover_min_dis, best_cover_low_ray, best_cover_high_ray
	local debuglineawful, debuglinebad, debuglinemeh, debuglinegood, debuglinegreat
	
	local debugging = nil
	
	if debugging then
		debuglineawful = Draw:brush(Color.red:with_alpha(0.5), 5)
		debuglinebad = Draw:brush(Color.yellow:with_alpha(0.5), 5)
		debuglinemeh = Draw:brush(Color.white:with_alpha(0.5), 5)
		debuglinegood = Draw:brush(Color.blue:with_alpha(0.5), 5)
		debuglinegreat = Draw:brush(Color.green:with_alpha(0.5), 5)
	end
	
	if debugging then
		debuglinegreat:sphere(near_pos, 20)
		
		for i = 1, #self._covers do
			local cover = self._covers[i]
			
			--is this cover already reserved by someone else?
			if not cover[self.COVER_RESERVED] then
				--the priority is as follows:
				--the cover is further than the minimum distance of the threat.
				--the cover is optimally distanced, and close to our optimal position.
				--the cover would cover up our head if we crouched.
				--the cover would cover up our head if we stood up.
				
				--the only actual REQUIREMENTS for the cover is for it to be within the maximum search distance and to be something we can path to, everything else is fluff.
				
				if _f_check_max_dis(cover, near_pos, max_dis) then
					--can we path to this cover?
					local coarse_params = {
						access_pos = access_pos or "swat",
						from_tracker = unit_nav_tracker,
						to_tracker = cover[3],
						id = "cover" .. tostring(i)
					}
					local path = self:search_coarse(coarse_params)
					
					if path then
						local cover_optimal_dis, cover_min_dis, cover_low_ray, cover_high_ray
						
						cover_min_dis = min_dis and _f_check_min_dis(cover, threat_pos, min_dis)
						
						if not best_cover_min_dis or cover_min_dis and cover_min_dis > best_cover_min_dis then
							if threat_vis_pos then
								cover_low_ray, cover_high_ray = _f_check_cover_rays(cover, threat_vis_pos, slotmask)
							end
							
							if not best_cover_low_ray or cover_low_ray then
								if not best_cover_high_ray or cover_high_ray then
									best_cover = cover
									best_cover_optimal_dis = cover_optimal_dis
									best_cover_min_dis = cover_min_dis
									best_cover_low_ray = cover_low_ray
									best_cover_high_ray = cover_high_ray
									
									if (not min_dis or best_cover_min_dis) and best_cover_low_ray and best_cover_high_ray then
										debuglinegreat:cylinder(cover[1], cover[1] + math_up * 65, 5)
										return best_cover
									end
								end									
							end
						else
							debuglinemeh:cylinder(cover[1], cover[1] + math_up * 65, 5)
						end
					else
						debuglinebad:cylinder(cover[1], cover[1] + math_up * 65, 5)
					end
				else
					debuglineawful:cylinder(cover[1], cover[1] + math_up * 65, 5)
				end
			else
				debuglinemeh:cylinder(cover[1], cover[1] + math_up * 65, 5)
			end
		end
	else
		for i = 1, #self._covers do
			local cover = self._covers[i]
			
			--is this cover already reserved by someone else?
			if not cover[self.COVER_RESERVED] then
				--the priority is as follows:
				--the cover is further than the minimum distance of the threat.
				--the cover is optimally distanced, and close to our optimal position.
				--the cover would cover up our head if we crouched.
				--the cover would cover up our head if we stood up.
				
				--the only actual REQUIREMENTS for the cover is for it to be within the maximum search distance and to be something we can path to, everything else is fluff.
				
				if _f_check_max_dis(cover, near_pos, max_dis) then
					--can we path to this cover?
					local coarse_params = {
						access_pos = access_pos or "swat",
						from_tracker = unit_nav_tracker,
						to_tracker = cover[3],
						id = "cover" .. tostring(i)
					}
					local path = self:search_coarse(coarse_params)
					
					if path then
						local cover_optimal_dis, cover_min_dis, cover_low_ray, cover_high_ray
						
						cover_min_dis = min_dis and _f_check_min_dis(cover, threat_pos, min_dis)
						
						if not best_cover_min_dis or cover_min_dis and cover_min_dis > best_cover_min_dis then
							if threat_vis_pos then
								cover_low_ray, cover_high_ray = _f_check_cover_rays(cover, threat_vis_pos, slotmask)
							end
							
							if not best_cover_low_ray or cover_low_ray then
								if not best_cover_high_ray or cover_high_ray then
									best_cover = cover
									best_cover_optimal_dis = cover_optimal_dis
									best_cover_min_dis = cover_min_dis
									best_cover_low_ray = cover_low_ray
									best_cover_high_ray = cover_high_ray
									
									if (not min_dis or best_cover_min_dis) and best_cover_low_ray and best_cover_high_ray then
										return best_cover
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	if debugging and best_cover then
		debuglinegreat:cylinder(best_cover[1], best_cover[1] + math_up * 65, 60)
	end
	
	return best_cover
end

function NavigationManager:_find_cover_through_lua_quick(near_pos, max_dis, access_pos) --meant for quick searches, find cover nearest to a pos
	local v3_dis_sq = mvec3_dis_sq
	local world_g = World

	max_dis = max_dis and max_dis * max_dis or 490000
	
	local function _f_check_dis(cover, near_pos, max_dis) --checking if the cover is further than our max search distance.
		local dis_sq = v3_dis_sq
		local cover_dis = dis_sq(cover[1], near_pos)
		
		if math.abs(cover[1].z - near_pos.z) > 250 then
			return
		end
		
		if cover_dis > max_dis then
			return
		else
			return true
		end
	end

	local best_cover
	local pos_tracker = self:create_nav_tracker(near_pos)

	for i = 1, #self._covers do
		local cover = self._covers[i]

		if not cover[self.COVER_RESERVED] then
			if _f_check_dis(cover, near_pos, max_dis) then
				local coarse_params = {
					access_pos = access_pos or "swat",
					from_tracker = pos_tracker,
					to_tracker = cover[3],
					id = "cover" .. tostring(i)
				}
				local path = self:search_coarse(coarse_params)
				
				if path then
					best_cover = cover
				end
				
				break
			end
		end
	end
	
	self:destroy_nav_tracker(pos_tracker)
	
	return best_cover
end