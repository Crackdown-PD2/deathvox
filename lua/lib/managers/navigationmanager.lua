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
local mvec3_length = mvector3.length
local math_abs = math.abs
local math_max = math.max
local math_clamp = math.clamp
local math_ceil = math.ceil
local math_floor = math.floor
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
	
	if not self._covers_registered then
		self._covers = {}
		self:register_covers_for_LUA() --run this in order to allow LUA-based cover searches.
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

function NavigationManager:register_covers_for_LUA()
	for key, res in pairs(self._nav_segments) do
		if res.pos then
			local tracker = self._quad_field:create_nav_tracker(res.pos)
			
			local location_script_data = self._quad_field:get_script_data(tracker)
			
			if location_script_data and location_script_data.covers then
				local covers = location_script_data.covers
				
				for i = 1, #covers do
					local cover = covers[i]
					
					self._covers[#self._covers + 1] = cover
				end
			end
			
			self:destroy_nav_tracker(tracker)
		end
	end
	
	self._covers_registered = true
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
--			log("endless")

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

function NavigationManager:find_cover_in_cone_from_threat_pos_1(threat_pos, furthest_pos, near_pos, search_from_pos, angle, min_dis, nav_seg, optimal_threat_dis, rsrv_filter)
	local v3_dis_sq = mvec3_dis_sq
	local world_g = World
	min_dis = min_dis and min_dis * min_dis or 0
	local nav_segs
	
	if type(nav_seg) == "table" then
		nav_segs = nav_seg
	elseif nav_seg then
		nav_segs = {nav_seg}
	end
	
	local best_cover, best_dist, best_l_ray, best_h_ray
	
	local function _f_check_cover_rays(cover, threat_pos) --this is a visibility check. first checking for crouching positions, then standing.
		local cover_pos = cover[1]
		local ray_from = temp_vec1

		mvec3_set(ray_from, math_up)
		mvec3_mul(ray_from, 82.5)
		mvec3_add(ray_from, cover_pos)
		
		local ray_to_pos = temp_vec2
		
		mvec3_set(ray_to_pos, math_up)
		mvec3_mul(ray_to_pos, 82.5)
		mvec3_add(ray_to_pos, threat_pos)

		local low_ray = world_g:raycast("ray", ray_from, ray_to_pos, "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", "ai_vision", "report")
		local high_ray = nil

		if low_ray then
			mvec3_set_z(ray_from, ray_from.z + 82.5)
			mvec3_set_z(ray_to_pos, ray_to_pos.z + 82.5)

			high_ray = world_g:raycast("ray", ray_from, ray_to_pos, "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", "ai_vision", "report")
		end

		return low_ray, high_ray
	end
	
	for i = 1, #self._covers do
		local cover = self._covers[i]
		
		if not cover[self.COVER_RESERVED] and self._quad_field:is_nav_segment_enabled(cover[3]:nav_segment()) then
			if not nav_segs or nav_segs[cover[3]:nav_segment()] then
				local cover_dis = mvec3_dis_sq(near_pos, cover[1])
				local threat_dir = threat_pos - cover[1]
				local threat_dist = mvec3_length(threat_dir)
				threat_dist = threat_dist * threat_dist
				
				local threat_dir_norm = threat_dir:normalized()
				
				if min_dis < threat_dist then
					if optimal_threat_dis then
						cover_dis = cover_dis - optimal_threat_dis
					end
					
					if not best_dist or cover_dis < best_dist then
						if math.cos(cone_angle) > mvec3_dot(threat_dir_norm, furthest_pos) then
							if self._quad_field:is_position_unreserved({radius = 40, position = cover[1], filter = rsrv_filter}) then
								local low_ray, high_ray
								
								low_ray, high_ray = _f_check_cover_rays(cover, threat_pos)
								
								if not best_l_ray or low_ray then
									if not best_h_ray or high_ray then
										best_l_ray = low_ray
										best_h_ray = high_ray
										best_cover = cover
										best_dist = cover_dis
								
										if cover_dis <= 10000 and best_l_ray then
											break
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	if best_cover then
		return best_cover
	end
end

function NavigationManager:find_cover_from_threat(nav_seg_id, optimal_threat_dis, near_pos, threat_pos)
	local v3_dis_sq = mvec3_dis_sq
	local world_g = World
	min_dis = min_dis and min_dis * min_dis or 0
	local nav_segs
	
	if type(nav_seg_id) == "table" then
		nav_segs = nav_seg_id
	elseif nav_seg_id then
		nav_segs = {nav_seg_id}
	end
	
	local best_cover, best_dist, best_l_ray, best_h_ray
	
	local function _f_check_cover_rays(cover, threat_pos) --this is a visibility check. first checking for crouching positions, then standing.
		local cover_pos = cover[1]
		local ray_from = temp_vec1

		mvec3_set(ray_from, math_up)
		mvec3_mul(ray_from, 82.5)
		mvec3_add(ray_from, cover_pos)
		
		local ray_to_pos = temp_vec2
		
		mvec3_set(ray_to_pos, math_up)
		mvec3_mul(ray_to_pos, 82.5)
		mvec3_add(ray_to_pos, threat_pos)

		local low_ray = world_g:raycast("ray", ray_from, ray_to_pos, "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", "ai_vision", "report")
		local high_ray = nil

		if low_ray then
			mvec3_set_z(ray_from, ray_from.z + 82.5)
			mvec3_set_z(ray_to_pos, ray_to_pos.z + 82.5)

			high_ray = world_g:raycast("ray", ray_from, ray_to_pos, "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", "ai_vision", "report")
		end

		return low_ray, high_ray
	end
	
	for i = 1, #self._covers do
		local cover = self._covers[i]
		
		if not cover[self.COVER_RESERVED] and self._quad_field:is_nav_segment_enabled(cover[3]:nav_segment()) then
			if not nav_segs or nav_segs[cover[3]:nav_segment()] then
				local cover_dis = v3_dis_sq(near_pos, cover[1])
				local threat_dist
				
				if threat_pos then
					threat_dist = v3_dis_sq(cover[1], threat_pos)
				end
				
				if not threat_dist or min_dis < threat_dist then
					if threat_dist and optimal_threat_dis then
						cover_dis = cover_dis - optimal_threat_dis
					end
					
					if not best_dist or cover_dis < best_dist then
						if self._quad_field:is_position_unreserved({radius = 40, position = cover[1], filter = rsrv_filter}) then
							local low_ray, high_ray
								
							if threat_pos then
								low_ray, high_ray = _f_check_cover_rays(cover, threat_pos)
							end
							
							if not best_l_ray or low_ray then
								if not best_h_ray or high_ray then
									best_l_ray = low_ray
									best_h_ray = high_ray
									best_cover = cover
									best_dist = cover_dis
							
									if cover_dis <= 10000 and best_l_ray then
										break
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	if best_cover then
		return best_cover
	end
end

function NavigationManager:find_cover_in_nav_seg_3(nav_seg_id, max_near_dis, near_pos, threat_pos)
	local v3_dis_sq = mvec3_dis_sq
	local world_g = World
	min_dis = min_dis and min_dis * min_dis or 0

	max_near_dis = max_near_dis and max_near_dis * max_near_dis
	local nav_segs
	
	if type(nav_seg_id) == "table" then
		nav_segs = nav_seg_id
	elseif nav_seg_id then
		nav_segs = {nav_seg_id}
	end
	
	local best_cover, best_dist, best_l_ray, best_h_ray
	
	local function _f_check_cover_rays(cover, threat_pos) --this is a visibility check. first checking for crouching positions, then standing.
		local cover_pos = cover[1]
		local ray_from = temp_vec1

		mvec3_set(ray_from, math_up)
		mvec3_mul(ray_from, 82.5)
		mvec3_add(ray_from, cover_pos)
		
		local ray_to_pos = temp_vec2
		
		mvec3_set(ray_to_pos, math_up)
		mvec3_mul(ray_to_pos, 82.5)
		mvec3_add(ray_to_pos, threat_pos)

		local low_ray = world_g:raycast("ray", ray_from, ray_to_pos, "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", "ai_vision", "report")
		local high_ray = nil

		if low_ray then
			mvec3_set_z(ray_from, ray_from.z + 82.5)
			mvec3_set_z(ray_to_pos, ray_to_pos.z + 82.5)

			high_ray = world_g:raycast("ray", ray_from, ray_to_pos, "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", "ai_vision", "report")
		end

		return low_ray, high_ray
	end
	
	for i = 1, #self._covers do
		local cover = self._covers[i]
		
		if not cover[self.COVER_RESERVED] and self._quad_field:is_nav_segment_enabled(cover[3]:nav_segment()) then
			if not nav_segs or nav_segs[cover[3]:nav_segment()] then
				local cover_dis = mvec3_dis_sq(near_pos, cover[1])
				local threat_dist
				
				if threat_pos then
					threat_dist = v3_dis_sq(cover[1], threat_pos)
				end
				
				if not threat_dist or min_dis < threat_dist then
					if not max_near_dis or cover_dis < max_near_dis then
						if not best_dist or cover_dis < best_dist then
							if self._quad_field:is_position_unreserved({radius = 40, position = cover[1], filter = rsrv_filter}) then
								local low_ray, high_ray
								
								if threat_pos then
									low_ray, high_ray = _f_check_cover_rays(cover, threat_pos)
								end
								
								if not best_l_ray or low_ray then
									if not best_h_ray or high_ray then
										best_l_ray = low_ray
										best_h_ray = high_ray
										best_cover = cover
										best_dist = cover_dis
								
										if cover_dis <= 10000 and best_l_ray then
											break
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	if best_cover then
		return best_cover
	end
end

function NavigationManager:pad_out_position(position, nr_rays, dis)
	nr_rays = math.max(2, nr_rays or 4)
	dis = dis or 46.5
	local angle = 360
	local rot_step = angle / nr_rays
	local rot_offset = 1 * angle * 0.5
	local ray_rot = Rotation(-angle * 0.5 + rot_offset - rot_step)
	local vec_to = Vector3(dis, 0, 0)

	mvec3_rot(vec_to, ray_rot)

	local pos_to = Vector3()

	mrotation.set_yaw_pitch_roll(ray_rot, rot_step, 0, 0)

	local ray_params = {
		trace = true,
		pos_from = position,
		pos_to = pos_to
	}
	local ray_results = {}
	local i_ray = 1
	local tmp_vec = temp_vec1
	local altered_pos = mvec3_cpy(position)
	
	while nr_rays >= i_ray do
		mvec3_rot(vec_to, ray_rot)
		mvec3_set(pos_to, vec_to)
		mvec3_add(pos_to, altered_pos)
		local hit = self:raycast(ray_params)

		if hit then
			mvec3_dir(tmp_vec, ray_params.trace[1], position)
			mvec3_mul(tmp_vec, dis)
			mvec3_add(altered_pos, tmp_vec)
		end

		i_ray = i_ray + 1
	end
	
	local position_tracker = self._quad_field:create_nav_tracker(altered_pos, true)
	altered_pos = mvec3_cpy(position_tracker:field_position())

	self._quad_field:destroy_nav_tracker(position_tracker)
	
	return altered_pos
end