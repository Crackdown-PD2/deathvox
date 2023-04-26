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
local math_lerp = math.lerp
local math_abs = math.abs
local math_max = math.max
local math_clamp = math.clamp
local math_ceil = math.ceil
local math_floor = math.floor
local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
local math_up = math.UP
NavigationManager._CD_navlink_elements = {}

function NavigationManager:find_segment_doors_with_nav_links(from_seg_id, approve_clbk)
	local all_doors = self._room_doors
	local all_nav_segs = self._nav_segments
	local from_seg = all_nav_segs[from_seg_id]
	local all_navlink_elements = self._CD_navlink_elements
	local found_doors = {}

	for neighbour_seg_id, _ in pairs(from_seg.neighbours) do
		for neighbours_neighbour_id, door_list in pairs(all_nav_segs[neighbour_seg_id].neighbours) do
			if neighbours_neighbour_id == from_seg_id then
				for _, i_door in ipairs(door_list) do
					if type(i_door) == "number" then
						table.insert(found_doors, all_doors[i_door])
					end
				end
			end
		end
	end
	
	for nl_id, nl_element in pairs(all_navlink_elements) do
		if nl_element then
			local nl_tracker = self._quad_field:create_nav_tracker(nl_element:value("position"), true) 
			
			if nl_tracker:nav_segment() == from_seg_id then
				local fake_door = {
					center = nl_element:value("position"),
					end_pos = nl_element:nav_link_end_pos()
				}
				
				table.insert(found_doors, fake_door)
			end
			
			self:destroy_nav_tracker(nl_tracker)
		else
			self._CD_navlink_elements[nl_id] = nil
		end
	end

	return found_doors
end

function NavigationManager:generate_cover_fwd(tracker)
	local all_nav_segs = self._nav_segments
	local m_seg_id = tracker:nav_segment()
	
	if all_nav_segs[m_seg_id] then
		local new_fwd = temp_vec1
		local v3_dis_sq = mvec3_dis_sq
		local doors = self:find_segment_doors_with_nav_links(m_seg_id)
		local best_door_pos = all_nav_segs[m_seg_id].pos
		local field_pos = tracker:field_position()
		local best_door_dis = nil
		local best_door_has_ray = nil
		local best_door_is_navlink = nil
		local second_best_pos = nil
		
		for i = 1, #doors do
			local door = doors[i]
			local door_on_z = door.center:with_z(field_pos.z)			
			local dis = v3_dis_sq(field_pos, door_on_z)			
			
			local ray = door.end_pos and true or self:raycast({trace = false, pos_from = field_pos, pos_to = door_on_z})
				
			if (not best_door_dis or dis < best_door_dis) and (not best_door_has_ray or ray) then
				second_best_pos = best_door_pos
				
				if door.end_pos then
					best_door_pos = door.end_pos:with_z(field_pos.z)
					best_door_is_navlink = true
				else
					best_door_pos = door_on_z
					best_door_is_navlink = nil
				end
				
				best_door_dis = dis
				best_door_has_ray = ray
			end
		end
		
		mvec3_dir(new_fwd, field_pos, best_door_pos)
		
		local ray_params = {
			trace = true,
			pos_from = field_pos
		}
		local hits = {}
		
		local rot_with = mvector3.rotate_with
		
		local fwd_test = temp_vec2
		
		local nr_rotations = 12
		local angle = 180 / nr_rotations
		rot_with(new_fwd, Rotation(-90))

		for i = 1, nr_rotations do
			mvec3_set(fwd_test, new_fwd)
			mvec3_mul(fwd_test, 100)
			mvec3_add(fwd_test, field_pos)
			ray_params.pos_to = fwd_test
			
			if self:raycast(ray_params) then
				if i == 6 then --perfect match.
					return mvec3_cpy(new_fwd)
				else
					hits[#hits + 1] = {mvec3_cpy(new_fwd), angle * i}
				end
			end
			
			if i < nr_rotations then
				rot_with(new_fwd, Rotation(angle))
			end
		end
		
		local best_angle, best_hit
		
		if #hits > 0 then
			for i = 1, #hits do
				local hit = hits[i]
				local diff = math_abs(hit[2])
				
				if not best_angle or diff < best_angle or diff == best_angle and math.random() <= 0.5 then
					best_hit = hit[1]
					best_angle = diff
				end
			end
			
			return best_hit
		end
		
		if second_best_pos then
			hits = {}
			mvec3_dir(new_fwd, field_pos, second_best_pos)
			rot_with(new_fwd, Rotation(-90))
			
			for i = 1, nr_rotations do
				mvec3_set(fwd_test, new_fwd)
				mvec3_mul(fwd_test, 100)
				mvec3_add(fwd_test, field_pos)
				ray_params.pos_to = fwd_test
				
				if self:raycast(ray_params) then
					if i == 6 then --perfect match.
						return mvec3_cpy(new_fwd)
					else
						hits[#hits + 1] = {mvec3_cpy(new_fwd), angle * i}
					end
				end
				
				if i < nr_rotations then
					rot_with(new_fwd, Rotation(angle))
				end
			end
			
			local best_angle, best_hit
			
			if #hits > 0 then
				for i = 1, #hits do
					local hit = hits[i]
					local diff = math_abs(hit[2])
					
					if not best_angle or diff < best_angle or diff == best_angle and math.random() <= 0.5 then
						best_hit = hit[1]
						best_angle = diff
					end
				end
				
				return best_hit
			end
		end
		
		--literally nothing worked, just in case, return the original direction since it'll probably be the best
		mvec3_dir(new_fwd, field_pos, best_door_pos)
		
		return mvec3_cpy(new_fwd)
	end
end

function NavigationManager:register_cover_units()
	if not self:is_data_ready() then
		return
	end

	local rooms = self._rooms
	local covers = {}
	local cover_data = managers.worlddefinition:get_cover_data()
	local t_ins = table.insert
	local v3_dis_sq = mvec3_dis_sq

	if cover_data then
		local function _register_cover(pos, fwd)
			local nav_tracker = self._quad_field:create_nav_tracker(pos, true)

			if not nav_tracker:lost() then
				local room_nav_seg = self._nav_segments[nav_tracker:nav_segment()]
				local navseg_tracker = self._quad_field:create_nav_tracker(room_nav_seg.pos, true)
				local field_pos = nav_tracker:field_position()
				local cover = {
					nav_tracker:field_position(),
					fwd,
					nav_tracker
				}
				
				cover[2] = self:generate_cover_fwd(nav_tracker)

				local location_script_data = self._quad_field:get_script_data(navseg_tracker, true)

				if not location_script_data.covers then
					location_script_data.covers = {}
				end

				t_ins(location_script_data.covers, cover)
				t_ins(covers, cover)
				
				self:destroy_nav_tracker(navseg_tracker)
			end
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

			if self._debug then
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
	
	if Network:is_server() then
		local max_cover_points = #covers <= 0 and 2500 or math.round(#covers * (math_lerp(4, 1, math_clamp(#covers / 2500, 0, 1))))
	
		max_cover_points = math_clamp(max_cover_points, 1, 2500)
		
		log("Map has " .. tostring(#covers) .. " cover points, setting generation limit to " .. tostring(max_cover_points) .. " cover points.")
		
		if #covers < max_cover_points then
			for key, res in pairs(self._nav_segments) do
				if res.pos and res.neighbours and next(res.neighbours) then	
					local tracker = self._quad_field:create_nav_tracker(res.pos, true)

					local location_script_data = self._quad_field:get_script_data(tracker, true)

					if not location_script_data.covers or #location_script_data.covers < 12 then
						if not location_script_data.covers then
							location_script_data.covers = {}
						end
			
						for _, room in pairs(res.rooms) do
							local c_tracker = nil
							local room_pos = NavFieldBuilder._calculate_room_center(self, room)
							local place_cover = true
							
							for i = 1, #covers do
								local other_cover_pos = covers[i][1]
								
								if v3_dis_sq(room_pos, other_cover_pos) <= 8100 then
									place_cover = nil
								end
							end
							
							if place_cover then
								place_cover = self:check_cover_close_to_wall(room_pos)
								
								if not place_cover then
									local across_vec = temp_vec1
									mvec3_set_st(across_vec, room.borders.x_pos, room.borders.y_pos, 0)
									mvec3_add(across_vec, room_pos)
									c_tracker = self._quad_field:create_nav_tracker(room_pos, true)
									local new_positions = self:find_walls_accross_tracker(c_tracker, across_vec, 360, 8)
									
									if new_positions then
										for i = 1, #new_positions do
											local good_cover = new_positions[i][2]
											
											if good_cover then
												local try_pos = new_positions[i][1]
												
												for i = 1, #covers do
													local other_cover_pos = covers[i][1]
													
													if v3_dis_sq(try_pos, other_cover_pos) <= 8100 then
														good_cover = nil
													end
												end
												
												if good_cover and self:check_cover_close_to_wall(try_pos) then
													if c_tracker:nav_segment() == key then
														place_cover = true
														c_tracker:move(try_pos)

														break
													end
												end
											end
										end
									else
										place_cover = nil
									end
								end
							end
							
							if place_cover then
								if not c_tracker then
									c_tracker = self._quad_field:create_nav_tracker(room_pos, true)
								end
								
								local cover = {
									c_tracker:field_position(),
									nil,
									c_tracker
								}
								
								cover[2] = self:generate_cover_fwd(c_tracker)
								
								t_ins(location_script_data.covers, cover)
								t_ins(covers, cover)
								
								if #location_script_data.covers >= 12 or #covers >= max_cover_points then
									break
								end
							elseif c_tracker then
								self:destroy_nav_tracker(c_tracker)
							end
						end
					end
					
					self:destroy_nav_tracker(tracker)
					
					if #covers >= max_cover_points then
						break
					end
				end
			end
		end
	end
	
	self._covers = covers
	
	if not self.has_registered_cover_units_for_CD then
		if #self._covers > 0 then
			self.has_registered_cover_units_for_CD = true
		else
			self.has_registered_cover_units_for_CD = true
		end
	end
end


function NavigationManager:clamp_position_to_field(position)
	if not position then
		return
	end
	
	local position_tracker = self._quad_field:create_nav_tracker(position)
	
	local new_pos = position_tracker:field_position()
	
	self._quad_field:destroy_nav_tracker(position_tracker)

	return new_pos
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
	local i_ray = 1
	local tmp_vec = temp_vec1
	local altered_pos = mvec3_cpy(position)
	--local line = Draw:brush(Color.red:with_alpha(0.5), 2)
	--local line2 = Draw:brush(Color.green:with_alpha(0.5), 2)
	
	for i = 1, nr_rays do
		mvec3_rot(vec_to, ray_rot)
		mvec3_set(pos_to, vec_to)
		mvec3_add(pos_to, position)
		local hit = self:raycast(ray_params)
		
		if hit then
			if line then
				line:cylinder(position, pos_to, 1)
			end
			
			mvec3_dir(tmp_vec, pos_to, position)
			mvec3_mul(tmp_vec, dis)
			mvec3_add(altered_pos, tmp_vec)
		elseif line2 then
			line2:cylinder(position, ray_params.trace[1]:with_z(position.z), 1)
		end
	end
	
	local altered_pos = altered_pos:with_z(position.z)
	local position_tracker = self._quad_field:create_nav_tracker(altered_pos, true)
	altered_pos = position_tracker:field_position()

	self._quad_field:destroy_nav_tracker(position_tracker)
	
	if line and line2 then
		line2:sphere(position, 10)
		line:sphere(altered_pos, 10)
	end
	
	return altered_pos
end

function NavigationManager:check_cover_close_to_wall(position, nr_rays, dis)
	nr_rays = math.max(2, nr_rays or 8)
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
		pos_from = position,
		pos_to = pos_to
	}
	local i_ray = 1
	local tmp_vec = temp_vec1
	--local line = Draw:brush(Color.red:with_alpha(0.5), 2)
	--local line2 = Draw:brush(Color.green:with_alpha(0.5), 2)
	
	for i = 1, nr_rays do
		mvec3_rot(vec_to, ray_rot)
		mvec3_set(pos_to, vec_to)
		mvec3_add(pos_to, position)
		local hit = self:raycast(ray_params)
		
		if hit then
			return true
		end
	end
end

function NavigationManager:send_nav_field_to_engine()
	local t_ins = table.insert
	local send_data = {
		rooms = self._rooms
	}
	local nr_rooms = #send_data.rooms

	send_data.doors = self._room_doors
	send_data.nav_segments = self._nav_segments
	send_data.quad_grid_size = self._grid_size
	send_data.sector_grid_offset = self._geog_segment_offset or Vector3()
	send_data.sector_grid_size = self._geog_segment_size
	send_data.sector_max_x = self._nr_geog_segments and self._nr_geog_segments.x or 0
	send_data.sector_max_y = self._nr_geog_segments and self._nr_geog_segments.y or 0
	local vis_groups = {}
	send_data.visibility_groups = vis_groups

	for i_vis_group, vis_group in ipairs(self._visibility_groups) do
		local new_vis_group = {
			seg = vis_group.seg
		}
		local rooms = {}

		for i_room, _ in pairs(vis_group.rooms) do
			if self._nav_segments[vis_group.seg] and self._nav_segments[vis_group.seg].pos then
				if not self._nav_segments[vis_group.seg].rooms then 
					self._nav_segments[vis_group.seg].rooms = {}
				end
				
				self._nav_segments[vis_group.seg].rooms[i_room] = self._rooms[i_room]
				--self._nav_segments[vis_group.seg].rooms[i_room].room_pos = NavFieldBuilder._calculate_room_center(self, self._rooms[i_room])
			end
		
			if i_room <= nr_rooms then
				t_ins(rooms, i_room)	
			else
				Application:error("[NavigationManager:send_nav_field_to_engine] Navgraph needs to be rebuilt!")
			end
		end

		new_vis_group.rooms = rooms
		local visible_groups = {}

		for i_visible_group, _ in pairs(vis_group.vis_groups) do
			t_ins(visible_groups, i_visible_group)
		end

		new_vis_group.vis_groups = visible_groups

		t_ins(vis_groups, new_vis_group)
	end

	local nav_sectors = {}
	send_data.nav_sectors = nav_sectors

	for sector_id, sector in pairs(self._geog_segments) do
		local rooms = {}
		local new_sector = {
			rooms = rooms
		}

		for i_room, _ in pairs(sector.rooms) do
			if i_room <= nr_rooms then
				t_ins(rooms, i_room)
			else
				Application:error("[NavigationManager:send_nav_field_to_engine] Navgraph needs to be rebuilt!")
			end
		end

		nav_sectors[sector_id] = new_sector
	end

	local nav_field = World:quad_field()

	nav_field:set_navfield(send_data, callback(self, self, "clbk_navfield"))
	nav_field:set_nav_link_filter(NavigationManager.ACCESS_FLAGS)
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
				center = door.pos,
			}

			mvector3.lerp(stripped_door.center, door.pos, door.pos1, 0.5)

			all_doors[i_door] = stripped_door
		end

		i_door = i_door - 1
	end

	self._rooms = {}
	self._geog_segments = {}
	self._geog_segment_offset = nil
	self._visibility_groups = {}
	self._helper_blockers = nil
	self._builder = nil
	self._covers = {}
end


function NavigationManager:_execute_coarce_search(search_data)
	local search_id = search_data.id
	local i = 0

	while true do
		if i == 500 then
			debug_pause("[NavigationManager:_execute_coarce_search] endless loop", inspect(search_data))

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
			local entry_found, nav_link_element, has_multiple_navlink_elements

			for _, i_door in ipairs(neighbours[search_data.end_i_seg]) do
				if type(i_door) == "number" then
					entry_found = true
					nav_link_element = nil
					has_multiple_navlink_elements = nil

					break
				elseif i_door:check_access(search_data.access_pos, search_data.access_neg) and i_door:delay_time() < TimerManager:game():time() and not i_door:is_obstructed() then
					entry_found = true
					
					if not has_multiple_navlink_elements then
						if nav_link_element then
							has_multiple_navlink_elements = true
							nav_link_element = nil
						else
							nav_link_element = i_door
						end
					end
				end
			end

			if entry_found then
				local i_seg = next_search_i_seg
				local this_seg = next_search_seg
				local prev_seg = search_data.end_i_seg
				local path = {
					{
						search_data.end_i_seg,
						search_data.to_pos,
						nav_link_element,
						has_multiple_navlink_elements
					}
				}

				table.insert(path, 1, {
					next_search_i_seg,
					next_search_seg.pos,
					next_search_seg.nav_link,
					next_search_seg.multiple_nav_links
				})

				local searched = search_data.seg_searched

				while this_seg.from do
					i_seg = this_seg.from
					this_seg = searched[i_seg]

					table.insert(path, 1, {
						i_seg,
						this_seg.pos,
						this_seg.nav_link,
						this_seg.multiple_nav_links
					})
				end

				return path
			end
		end

		local to_pos = all_nav_segments[next_search_i_seg].pos
		local new_segments = self:_sort_nav_segs_after_pos(to_pos, next_search_i_seg, search_data.discovered_seg, search_data.verify_clbk, search_data.access_pos, search_data.access_neg)

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

				while search_index > 0 and to_search[search_index].weight < new_seg_weight do
					search_index = search_index - 1
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

function NavigationManager:_sort_nav_segs_after_pos(to_pos, i_seg, ignore_seg, verify_clbk, access_pos, access_neg)
	local all_segs = self._nav_segments
	local all_doors = self._room_doors
	local all_rooms = self._rooms
	local seg = all_segs[i_seg]
	local neighbours = seg.neighbours
	local found_segs = nil

	for neighbour_seg_id, door_list in pairs(neighbours) do
		if not ignore_seg[neighbour_seg_id] and not all_segs[neighbour_seg_id].disabled and (not verify_clbk or verify_clbk(neighbour_seg_id)) then
			for _, i_door in ipairs(door_list) do
				if type(i_door) == "number" then
					local door = all_doors[i_door]
					local door_pos = all_segs[neighbour_seg_id].pos
					local weight = mvec3_dis(door_pos, to_pos)

					if found_segs then
						if found_segs[neighbour_seg_id] then
							if weight < found_segs[neighbour_seg_id].weight or found_segs[neighbour_seg_id].nav_link or found_segs[neighbour_seg_id].multiple_nav_links then
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
					local end_pos = all_segs[neighbour_seg_id].pos
					local my_weight = mvec3_dis(end_pos, to_pos)

					if found_segs then
						if found_segs[neighbour_seg_id] then
							if found_segs[neighbour_seg_id].nav_link or found_segs[neighbour_seg_id].multiple_nav_links then
								if my_weight < found_segs[neighbour_seg_id].weight then
									found_segs[neighbour_seg_id] = {
										weight = my_weight,
										from = i_seg,
										i_seg = neighbour_seg_id,
										pos = end_pos,
										multiple_nav_links = true
									}
								end
							else
								my_weight = my_weight * 1.25
								
								if my_weight < found_segs[neighbour_seg_id].weight then
									local had_nav_links = found_segs[neighbour_seg_id].multiple_nav_links
								
									found_segs[neighbour_seg_id] = {
										weight = my_weight,
										from = i_seg,
										i_seg = neighbour_seg_id,
										pos = end_pos,
										nav_link = not had_nav_links and i_door or nil,
										multiple_nav_links = had_nav_links
									}
								end
							end
						else
							found_segs[neighbour_seg_id] = {
								weight = my_weight,
								from = i_seg,
								i_seg = neighbour_seg_id,
								pos = end_pos,
								nav_link = i_door
							}
							ignore_seg[neighbour_seg_id] = true
						end
					else
						found_segs = {
							[neighbour_seg_id] = {
								weight = my_weight,
								from = i_seg,
								i_seg = neighbour_seg_id,
								pos = end_pos,
								nav_link = i_door
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

function NavigationManager:_path_is_straight_line(pos_from, pos_to, u_data)
	if not pos_from.z then
		if alive(pos_from) then
			pos_from = CopActionWalk._nav_point_pos(pos_from:script_data())
		else
			return
		end
	end
	
	if not pos_to.z then
		if alive(pos_to) then
			pos_to = CopActionWalk._nav_point_pos(pos_to:script_data())
		else
			return
		end
	end

	if math.abs(pos_from.z - pos_to.z) > 60 then 
		return
	end
	
	local ray = CopActionWalk._chk_shortcut_pos_to_pos(pos_from, pos_to)

	return not ray 
end