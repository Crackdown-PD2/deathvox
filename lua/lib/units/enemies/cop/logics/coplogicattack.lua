--Most values except the radiuses here aren't changed, however I felt the need to include comments on what they do because you guys may want to change them.
--I know I certainly fucking did for when I'm playing this game alone.


function CopLogicAttack._chk_start_action_move_out_of_the_way(data, my_data) --As far as I can tell, this makes them give space to other units if a path isn't clear so they clip into eachother less, which, it isn't doing it's job right, is it?
	local my_tracker = data.unit:movement():nav_tracker()
	local reservation = {
		radius = 100, --This MAYBE makes cops clip into eachother less when doing this specific thing, default 60.
		position = data.m_pos,
		filter = data.pos_rsrv_id
	}

	if not managers.navigation:is_pos_free(reservation) then
		local to_pos = CopLogicTravel._get_pos_on_wall(data.m_pos, 500) --This essentially acquires the nearest wall or area close to it so they can stand there.

		if to_pos then
			local path = {
				my_tracker:position(),
				to_pos
			}

			CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, "run")
		end
	end
end

function CopLogicAttack._find_retreat_position(from_pos, threat_pos, threat_head_pos, threat_tracker, max_dist, vis_required)
	local nav_manager = managers.navigation
	local nr_rays = 5
	local ray_dis = max_dist or 1000 --It asks for a max_dist from...maybe CopLogicTravel, or 10m.
	local step = 180 / nr_rays
	local offset = math.random(step)
	local dir = math.random() < 0.5 and -1 or 1
	step = step * dir
	local step_rot = Rotation(step)
	local offset_rot = Rotation(offset)
	local offset_vec = mvector3.copy(threat_pos)

	mvector3.subtract(offset_vec, from_pos)
	mvector3.normalize(offset_vec)
	mvector3.multiply(offset_vec, ray_dis)
	mvector3.rotate_with(offset_vec, Rotation((90 + offset) * dir))

	local to_pos = nil
	local from_tracker = nav_manager:create_nav_tracker(from_pos)
	local ray_params = {
		trace = true,
		tracker_from = from_tracker
	}
	local rsrv_desc = {radius = 100} --This MAYBE makes cops clip into eachother less when doing this specific thing, default 60.
	local fail_position = nil

	repeat
		to_pos = mvector3.copy(from_pos)

		mvector3.add(to_pos, offset_vec)

		ray_params.pos_to = to_pos
		local ray_res = nav_manager:raycast(ray_params)

		if ray_res then
			rsrv_desc.position = ray_params.trace[1]
			local is_free = nav_manager:is_pos_free(rsrv_desc)

			if is_free and (not vis_required or CopLogicAttack._confirm_retreat_position(ray_params.trace[1], threat_pos, threat_head_pos, threat_tracker)) then
				managers.navigation:destroy_nav_tracker(from_tracker)

				return ray_params.trace[1]
			end
		elseif not fail_position then
			rsrv_desc.position = ray_params.trace[1]
			local is_free = nav_manager:is_pos_free(rsrv_desc)

			if is_free then
				fail_position = ray_params.trace[1]
			end
		end

		mvector3.rotate_with(offset_vec, step_rot)

		nr_rays = nr_rays - 1
	until nr_rays == 0

	managers.navigation:destroy_nav_tracker(from_tracker)

	if fail_position then
		return fail_position
	end

	return nil
end


function CopLogicAttack._find_flank_pos(data, my_data, flank_tracker, max_dist)
	local pos = flank_tracker:position()
	local vec_to_pos = pos - data.m_pos

	mvector3.set_z(vec_to_pos, 0)

	local max_dis = max_dist or 1500 --This makes cops look for flanks around 15m, not nearly enough IMO for these changes, maybe consider 24m?

	mvector3.set_length(vec_to_pos, max_dis)

	local accross_positions = managers.navigation:find_walls_accross_tracker(flank_tracker, vec_to_pos, 160, 5)

	if accross_positions then
		local optimal_dis = max_dis
		local best_error_dis, best_pos, best_is_hit, best_is_miss, best_has_too_much_error = nil

		for _, accross_pos in ipairs(accross_positions) do
			local error_dis = math.abs(mvector3.distance(accross_pos[1], pos) - optimal_dis)
			local too_much_error = error_dis / optimal_dis > 0.2
			local is_hit = accross_pos[2]

			if best_is_hit then
				if is_hit then
					if error_dis < best_error_dis then
						local reservation = {
							radius = 50, --If it's not the best flank position it wants and it has errors but less than the best one, set it to 50cm, I may have this one mixed up with another one, I'm not sure, this code is confusing as fuck.
							position = accross_pos[1],
							filter = data.pos_rsrv_id
						}

						if managers.navigation:is_pos_free(reservation) then
							best_pos = accross_pos[1]
							best_error_dis = error_dis
							best_has_too_much_error = too_much_error
						end
					end
				elseif best_has_too_much_error then
					local reservation = {
						radius = 50, --If it has too many errors when they tried to find stuff, just make it 50cm wide.
						position = accross_pos[1],
						filter = data.pos_rsrv_id
					}

					if managers.navigation:is_pos_free(reservation) then
						best_pos = accross_pos[1]
						best_error_dis = error_dis
						best_is_miss = true
						best_is_hit = nil
					end
				end
			elseif best_is_miss then
				if not too_much_error then
					local reservation = {
						radius = 100, --If the best isn't perfect but doesn't have too many errors, go with 100 anyways.
						position = accross_pos[1],
						filter = data.pos_rsrv_id
					}

					if managers.navigation:is_pos_free(reservation) then
						best_pos = accross_pos[1]
						best_error_dis = error_dis
						best_has_too_much_error = nil
						best_is_miss = nil
						best_is_hit = true
					end
				end
			else
				local reservation = {
					radius = 100, --If the seek worked with no problems, GREAT! Make the position 1m wide.
					position = accross_pos[1],
					filter = data.pos_rsrv_id
				}

				if managers.navigation:is_pos_free(reservation) then
					best_pos = accross_pos[1]
					best_is_hit = is_hit
					best_is_miss = not is_hit
					best_has_too_much_error = too_much_error
					best_error_dis = error_dis
				end
			end
		end

		return best_pos
	end
end
