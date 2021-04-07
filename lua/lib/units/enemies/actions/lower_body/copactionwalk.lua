local mvec3_z = mvector3.z
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_negate = mvector3.negate
local mvec3_lerp = mvector3.lerp
local mvec3_cpy = mvector3.copy
local mvec3_set_l = mvector3.set_length
local mvec3_cross = mvector3.cross
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_len = mvector3.length
local mvec3_set_stat = mvector3.set_static
local mvec3_bezier = mvector3.bezier

local REACT_SCARED = AIAttentionObject.REACT_SCARED
local REACT_SHOOT = AIAttentionObject.REACT_SHOOT

local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_vec3 = Vector3()

local mrot_lookat = mrotation.set_look_at
local mrot_set = mrotation.set_yaw_pitch_roll
local mrot_yaw = mrotation.yaw

local temp_rot1 = Rotation()

local math_abs = math.abs
local math_lerp = math.lerp
local math_step = math.step
local math_clamp = math.clamp
local math_ceil = math.ceil
local math_sign = math.sign
local math_up = math.UP
local math_down = math.DOWN

local next_g = next
local pairs_g = pairs

local deep_clone_g = deep_clone
local safe_get_value_g = safe_get_value
local alive_g = alive
local world_g = World

local idstr_base = Idstring("base")

function CopActionWalk:init(action_desc, common_data)
	self._common_data = common_data
	self._action_desc = action_desc
	self._unit = common_data.unit

	local ext_brain = common_data.ext_brain
	self._ext_brain = ext_brain

	self._ext_movement = common_data.ext_movement
	self._ext_anim = common_data.ext_anim
	self._ext_base = common_data.ext_base
	self._ext_network = common_data.ext_network
	self._body_part = action_desc.body_part

	self._machine = common_data.machine
	self._stance = common_data.stance

	self:on_attention(common_data.attention)

	self._last_vel_z = 0
	self._cur_vel = 0
	self._end_rot = action_desc.end_rot

	CopActionAct._create_blocks_table(self, action_desc.blocks)

	self._persistent = action_desc.persistent
	self._haste = action_desc.variant
	self._no_walk = action_desc.no_walk
	self._no_strafe = action_desc.no_strafe
	self._last_pos = mvec3_cpy(common_data.pos)
	self._nav_path = action_desc.nav_path

	local is_server = Network:is_server()
	self._sync = is_server

	local timer = TimerManager:game()
	local t = timer:time()

	self._timer = timer
	self._last_upd_t = t - 0.001
	self._skipped_frames = 1

	if not is_server then
		self._occlusion_manager = managers.occlusion
		self._stealth_boost = tweak_data.network.stealth_speed_boost
	end

	--wip
	--[[if not is_server then
		local sync_t = action_desc.sync_t

		if sync_t then
			local start_t = t - Application:time() - action_desc.sync_t

			self._t_mul = t / start_t
		else
			local old_start_t = action_desc.old_start_t

			if old_start_t then
				local start_t = t - old_start_t + action_desc.interrupt_t
			end
		end
	end]]

	--wait for the unit to fully blend into their idle state before fully starting the action
	--usually done if the unit wants to walk while still not fully exiting from another animation
	if common_data.ext_anim.needs_idle then
		self._waiting_full_blend = true

		self:_set_updator("_upd_wait_for_full_blend")

		if self._sync then
			--reserve the destination position now since that'd normally only happen in the _init function
			self._reserved_destination = true

			ext_brain:add_pos_rsrv("move_dest", {
				radius = 30,
				position = mvec3_cpy(self._nav_point_pos(self._nav_path[#self._nav_path]))
			})

			--since the unit will very likely be standing still, ensure that their current position is properly reserved
			local stand_rsrv = ext_brain:get_pos_rsrv("stand")

			if not stand_rsrv or mvec3_dis_sq(stand_rsrv.position, common_data.pos) > 400 then
				ext_brain:add_pos_rsrv("stand", {
					radius = 30,
					position = mvec3_cpy(common_data.pos)
				})
			end
		end
	elseif not self:_init() then
		return
	end

	--self:_init_ik()

	--shields will turn slower while moving
	--other units will also turn slowly compared to vanilla, just not as slow as shields
	if common_data.machine:get_global("shield") == 1 then
		self._shield_turning = true
	end

	common_data.ext_movement:enable_update()

	--normally just used to print a debug text
	self._is_civilian = CopDamage.is_civilian(common_data.ext_base._tweak_table)

	return true
end

function CopActionWalk:_init_ik()
	if managers.job:current_level_id() ~= "chill" or not self._common_data.char_tweak.use_ik then
		return
	end

	self._look_vec = mvec3_cpy(self._common_data.fwd)
	self._ik_update = callback(self, self, "_ik_update_func")

	self._m_head_pos = self._ext_movement:m_head_pos()
	local player_unit = managers.player:player_unit()
	self._ik_data = player_unit
end

function CopActionWalk:_init()
	if not self:_sanitize() then
		return
	end

	self._init_called = true
	local action_desc = self._action_desc
	local common_data = self._common_data

	--the intention behind interrupted walk actions is to catch up to the unit's real position
	--run start and stop animations slow the unit down a bit
	--these need to be defined in actionspooc as well (normally not the case in vanilla)
	if action_desc.interrupted then
		self._no_run_start = true
		self._no_run_stop = true
	else
		if common_data.char_tweak.no_run_start then
			self._no_run_start = true
		--elseif not self._unit:in_slot(16) then
			--self._no_run_start_turn = true
		end

		--until I find a proper method to consistently not slow down units, just disable it
		self._no_run_stop = true --common_data.char_tweak.no_run_stop
	end

	--either do this or change haste to run
	if self._no_walk and self._haste == "walk" then
		self._no_walk = nil
	end

	if self._sync then
		--team AI is supposed to be invulnerable while playing nav_link animations
		if managers.groupai:state():all_AI_criminals()[common_data.unit:key()] then
			self._nav_link_invul = true
		end

		local unprocessed_path = self._nav_path
		local processed_path = {}
		local precise_path = action_desc.path_simplified

		--nav_links are rearranged in here so that they're more accesible
		--it also allows host and clients to use the same lines
		for i = 1, #unprocessed_path do
			local nav_point = unprocessed_path[i]

			if nav_point.x then --normal nav_point
				processed_path[#processed_path + 1] = nav_point
			else --if not precise_path or alive_g(nav_point) then --nav_link
				processed_path[#processed_path + 1] = {
					element = nav_point:script_data().element,
					c_class = nav_point
				}
			--commenting this out because this should be completely irrelevant
			--precise paths don't use nav_links, and I account for dead nav_links before even starting a walk action
			--[[else
				--dead/destroyed/unregistered nav_link, prevent the action from starting
				self._init_called = false

				return false]]
			end
		end

		self._nav_path = processed_path

		--precise paths don't need shortcuts, shortening or padding
		if precise_path then
			local s_path = {}

			for i = 1, #processed_path do
				local nav_point = processed_path[i]

				if nav_point.x then
					s_path[#s_path + 1] = mvec3_cpy(nav_point)
				else
					s_path[#s_path + 1] = nav_point
				end
			end

			self._simplified_path = s_path
		else
			local nav_tracker = common_data.nav_tracker
			local good_pos = nav_tracker:lost() and mvec3_cpy(common_data.nav_tracker:field_position()) or mvec3_cpy(common_data.pos)
			local nr_iterations = self._stance.name == "ntl" and 2 or 1 --non-alerted units simplify paths twice

			--[[local line1 = Draw:brush(Color.red:with_alpha(0.5), 3)

			for i = 1, #self._nav_path - 1 do
				local cur_pos = self._nav_point_pos(self._nav_path[i])
				local next_pos = self._nav_point_pos(self._nav_path[i + 1])

				line1:cylinder(cur_pos, next_pos, 15)
			end]]

			self._simplified_path = self._calculate_simplified_path(good_pos, processed_path, nr_iterations, true, true)

			--[[local line2 = Draw:brush(Color.blue:with_alpha(0.5), 3)

			for i = 1, #self._simplified_path - 1 do
				local cur_pos = self._nav_point_pos(self._simplified_path[i])
				local next_pos = self._nav_point_pos(self._simplified_path[i + 1])

				line2:cylinder(cur_pos, next_pos, 15)
			end]]
		end
	else
		local nav_path = self._nav_path

		if action_desc.is_drop_in then
			--process nav_links to be usable
			for i = 1, #nav_path do
				local nav_point = nav_path[i]

				if not nav_point.x then
					function nav_point.element.value(element, name)
						return element[name]
					end

					function nav_point.element.nav_link_wants_align_pos(element)
						return element.from_idle
					end
				end
			end

			--received nav_points while the action was started but didn't fully initialize yet
			--only happens when waiting for idle_full_blend, which is short, but it CAN happen
			--shouldn't be needed for drop-ins, but just in case
			local new_nav_points = self._simplified_path

			if new_nav_points then
				for i = 1, #new_nav_points do
					local nav_point = new_nav_points[i]

					nav_path[#nav_path + 1] = nav_point
				end
			end

			--unit was playing a nav_link animation on the server
			if action_desc.start_anim_time then
				self._nav_path = nav_path
				self._simplified_path = nav_path

				self._next_is_nav_link = self._simplified_path[1]

				self:_play_nav_link_anim(self._timer:time())

				action_desc.start_anim_time = nil
				action_desc.start_anim_idx = nil
				action_desc.pos_z = nil

				return true
			else
				--unit was about to reach the end of their path on the server, thus no second nav_point was synced
				--or the initial position doesn't match the unit's position somehow
				if not nav_path[2] or nav_path[1] ~= common_data.pos then
					local new_path_table = {
						mvec3_cpy(common_data.pos)
					}

					for idx = 1, #nav_path do
						new_path_table[#new_path_table + 1] = nav_path[idx]
					end

					nav_path = new_path_table
				end

				self._nav_path = nav_path
				self._simplified_path = nav_path
			end
		else
			--received nav_points while the action was started but didn't fully initialize yet
			--only happens when waiting for idle_full_blend, which is short, but it CAN happen
			local new_nav_points = self._simplified_path

			if new_nav_points then
				for i = 1, #new_nav_points do
					local nav_point = new_nav_points[i]

					nav_path[#nav_path + 1] = nav_point
				end
			end

			--ensure the first nav_point in the table is the position of the unit when starting the action
			if action_desc.interrupted then
				--replace the first nav_point with the current position of the unit

				--first ensure that there is a second nav_point
				if not nav_path[2] then
					--since the action was interrupted, the first one should be used in its place
					nav_path[2] = nav_path[1]
				end

				--the host_stop_pos check after this block will make sure that if this new position will cause the unit to go through obstacles
				--they will return to their original position before being interrupted
				nav_path[1] = mvec3_cpy(common_data.pos)
			elseif not nav_path[2] or not nav_path[1].x or nav_path[1] ~= common_data.pos then
				--normally started the action
				--or it was interrupted but the first nav_point is actually a nav_link
				--either way, inserting current position in index 1
				local new_path_table = {
					mvec3_cpy(common_data.pos)
				}

				for idx = 1, #nav_path do
					new_path_table[#new_path_table + 1] = nav_path[idx]
				end

				nav_path = new_path_table
			end

			--if the unit will collide with a nav obstacle when moving to the first destination due to a previous interruption
			--insert host_stop_pos before the destination to alleviate it (doesn't necessarily mean that this is an interrupted action)
			--host_stop_pos is set for clients when the unit exits some actions prematurely (by interruption) or if the positioning of the unit was local
			--picture a unit running to a destination, then getting shot and staggered to the side. The instant this happens is when
			--this position gets updated, so the unit will go back to where they got staggered, and then resume the path to their real position
			if not action_desc.host_stop_pos_ahead and nav_path[1] ~= nav_path[2] then
				local insert_host_stop_pos = nil
				local next_pos = self._nav_point_pos(nav_path[2])

				if math_abs(common_data.pos.z - next_pos.z) < 100 then
					local ray_params = {
						tracker_from = common_data.nav_tracker,
						pos_to = next_pos
					}

					insert_host_stop_pos = managers.navigation:raycast(ray_params) and true
				else--too much height difference, the nav ray might produce inaccurate results
					insert_host_stop_pos = true
				end

				if insert_host_stop_pos then
					self._host_stop_pos_ahead = true

					local new_path_table = {
						nav_path[1],
						mvec3_cpy(common_data.ext_movement:m_host_stop_pos())
					}

					for idx = 2, #nav_path do
						new_path_table[#new_path_table + 1] = nav_path[idx]
					end

					nav_path = new_path_table
				end
			end

			self._nav_path = nav_path

			--non-persistent means the host has sent the order to expire this action once the final nav_point is reached
			--no new nav_points will be sent, so we want the unit to attempt to use (valid) shortcuts and catch up faster
			--currently not used since if the server didn't get a shortcut, there's no point in clients testing for them
			--[[if not self._persistent then
				local good_pos = mvec3_cpy(common_data.pos)

				self._simplified_path = self._calculate_simplified_path(good_pos, nav_path, 2, false, false)
			else]]
				self._simplified_path = nav_path
			--end
		end
	end

	local init_pos = self._simplified_path[1]
	local next_nav_point = self._simplified_path[2]

	--prepare nav_link for arrival to the next nav_point
	if not next_nav_point.x then
		self._next_is_nav_link = next_nav_point
	end

	local next_point_pos = self._nav_point_pos(next_nav_point)

	--check if the unit should play a run_start animation
	self:_chk_start_anim(next_point_pos)

	local curve_path = nil

	--check if the function above was successfull
	if self._start_run then
		self:_set_updator("_upd_start_anim_first_frame")

		--not actually a curve path, but actual walking is handled through curve path tables
		curve_path = {
			init_pos,
			mvec3_cpy(next_point_pos)
		}
	elseif self._ext_base:lod_stage() == 1 and math_abs(init_pos.z - next_point_pos.z) < 100 and mvec3_dis_sq(init_pos, next_point_pos:with_z(init_pos.z)) > 490000 then
		--calculate a smooth curved path if not doing a run_start turn animation
		-- + unit is in the highest anim lod stage + height difference doesn't exceed 1 meter + distance exceeds 7 meters
		curve_path = self:_calculate_curved_path(self._simplified_path, 1, 1)
	else
		curve_path = {
			init_pos,
			mvec3_cpy(next_point_pos)
		}
	end

	--if the path is a straight line, the unit is running, uses no run stop animations and the distance between the points is higher or equal than 1.2 meters
	--check before starting a stop animation later on when distance to destination becomes lower than 2.1m
	if #self._simplified_path == 2 and not self._no_run_stop and self._haste == "run" and mvec3_dis(init_pos, next_point_pos:with_z(init_pos.z)) >= 210 then
		self._chk_stop_dis = 210
	end

	self._curve_path = curve_path
	self._curve_path_index = 1

	if not self._sync then
		return true
	end

	--not syncing nav_links at start because this can easily just cause issues
	--the unit on a client's end may use the nav_link while it never did on the host's end because they got interrupted
	--this causes them to go back into the initial position of the nav_link, which in a lot of cases means walking through geometry

	local sync_nav_point_pos = mvec3_cpy(next_point_pos)
	local sync_haste = self._haste == "walk" and 1 or 2
	local sync_yaw = 0
	local end_rot = self._end_rot

	if end_rot then
		local yaw = end_rot:yaw()

		if yaw < 0 then
			yaw = 360 + yaw
		end

		sync_yaw = 1 + math_ceil(yaw * 254 / 360)
	end

	local sync_no_walk = self._no_walk and true or false
	local sync_no_strafe = self._no_strafe and true or false
	local pose_code, end_pose_code = nil

	if not action_desc.pose then
		pose_code = 0
	elseif action_desc.pose == "stand" then
		pose_code = 1
	else
		pose_code = 2
	end

	if not action_desc.end_pose then
		end_pose_code = 0
	elseif action_desc.end_pose == "stand" then
		end_pose_code = 1
	else
		end_pose_code = 2
	end

	self._ext_network:send("action_walk_start", sync_nav_point_pos, 1, 0, false, sync_haste, sync_yaw, sync_no_walk, sync_no_strafe, pose_code, end_pose_code)

	local brain_ext = self._ext_brain

	--remove stand position reservation
	brain_ext:rem_pos_rsrv("stand")

	if not self._reserved_destination then
		brain_ext:add_pos_rsrv("move_dest", {
			radius = 30,
			position = mvec3_cpy(self._simplified_path[#self._simplified_path])
		})
	end

	return true
end

function CopActionWalk:_sanitize()
	local ext_anim = self._ext_anim
	local ext_mov = self._ext_movement

	if not ext_anim.pose then
		--if this somehow goes through, make the unit redirect to its idle animation to define this properly
		if not ext_mov:play_redirect("idle") or not ext_anim.pose then
			--if the redirect failed or pose wasn't defined somehow, then play animation state instead of redirecting
			if not ext_mov:play_state("std/stand/still/idle/look") then
				--if this also failed, the action cannot start as it will cause severe issues
				--this should never happen in the game's current state
				return
			end
		end
	end

	local walk_anim_lenghts = self._walk_anim_lengths
	local start_pose = self._action_desc.pose

	--if the unit has a start pose with supported walking animations, play it if needed
	--else, ensure the unit isn't in a pose with unsupported animations
	if start_pose and not ext_anim[start_pose] and walk_anim_lenghts[start_pose] then
		ext_mov:play_redirect(start_pose)
	elseif not walk_anim_lenghts[ext_anim.pose] then
		if ext_anim.pose == "stand" then
			ext_mov:play_redirect("crouch")
		else
			ext_mov:play_redirect("stand")
		end
	end

	return true
end

function CopActionWalk:_chk_start_anim(next_pos)
	if self._no_run_start or self._haste ~= "run" then
		return
	end

	local lod_stage = self._ext_base:lod_stage() or 4

	--no point in doing all this for an enemy that's not in sight or is in a low anim lod stage
	if lod_stage > 2 then
		return
	end

	local common_data = self._common_data
	local path_dir = next_pos - common_data.pos
	path_dir = path_dir:with_z(0) --set height to 0

	local path_len = path_dir:length()

	--just like how run_stop animations require the path to be longer than 1.2m, we're checking for that in here as well
	if path_len < 120 then
		return
	end

	path_dir = path_dir:normalized()

	local can_turn_and_aim = not self._no_run_start_turn
	local att_pos = self._attention_pos

	if can_turn_and_aim and att_pos then
		local target_vec = att_pos - common_data.pos
		target_vec = target_vec:with_z(0):normalized()

		local fwd_dot = path_dir:dot(target_vec)

		if fwd_dot < 0.7 then
			--angle between attention and the direction the unit has to move is too big
			--prevent the unit from doing a run start turn animation so that it can keep aiming
			can_turn_and_aim = nil
		end
	end

	if can_turn_and_aim then
		local path_angle = path_dir:to_polar_with_reference(common_data.fwd, math_up).spin

		if math_abs(path_angle) > 135 then
			local pose = self._ext_anim.pose
			local spline_data = self._anim_movement[pose].run_start_turn_bwd
			local ds = spline_data.ds

			--path has to be longer than the distance needed for the animation + 1m
			if ds:length() < path_len - 100 then
				if path_angle > 0 then
					path_angle = path_angle - 360
				end

				self._start_run_turn = {
					common_data.rot:yaw(),
					path_angle,
					"bwd"
				}
			end
		elseif path_angle < -65 then
			local pose = self._ext_anim.pose
			local spline_data = self._anim_movement[pose].run_start_turn_r
			local ds = spline_data.ds

			if ds:length() < path_len - 100 then
				self._start_run_turn = {
					common_data.rot:yaw(),
					path_angle,
					"r"
				}
			end
		elseif path_angle > 65 then
			local pose = self._ext_anim.pose
			local spline_data = self._anim_movement[pose].run_start_turn_l
			local ds = spline_data.ds

			if ds:length() < path_len - 100 then
				self._start_run_turn = {
					common_data.rot:yaw(),
					path_angle,
					"l"
				}
			end
		end
	end

	self._start_run = true

	if not self._root_blend_disabled then
		self._ext_movement:set_root_blend(false)

		self._root_blend_disabled = true
	end

	if not self._start_run_turn then
		local right_dot = path_dir:dot(common_data.right)
		local fwd_dot = path_dir:dot(common_data.fwd)

		--this won't affect the direction the unit will face
		--there are different movement animations based on the rotation of the unit + direction of movement
		if math_abs(right_dot) < math_abs(fwd_dot) then
			self._start_run_straight = fwd_dot > 0 and "fwd" or "bwd"
		else
			self._start_run_straight = right_dot > 0 and "r" or "l"
		end
	end
end

function CopActionWalk._calculate_shortened_path(path)
	local nav_point_pos_func = CopActionWalk._nav_point_pos
	local chk_shortcut_func = CopActionWalk._chk_shortcut_pos_to_pos

	local nav_manager = managers.navigation
	local create_tracker_f = nav_manager.create_nav_tracker
	local destroy_tracker_f = nav_manager.destroy_nav_tracker
	local temp_tracker = nil

	local index = 2
	local test_pos = tmp_vec1

	while index < #path do
		local prev_point = path[index - 1]
		local cur_point = path[index]

		if not cur_point.x then
			--current point is a nav_link, cannot shorten this section of the path, skip two points ahead
			index = index + 2
		elseif not prev_point.x then
			--previous point is a nav_link, cannot shorten this section of the path, skip one point ahead
			index = index + 1
		else
			--if the next nav point is a nav_link, that's fine, its initial pos is valid for these purposes
			--in this case, clamping isn't needed as it was already done when applying padding

			local pos = cur_point
			local bwd_pos = prev_point
			local fwd_pos = nav_point_pos_func(path[index + 1])
			local vec1 = fwd_pos - pos
			local vec2 = bwd_pos - pos
			vec1 = vec1:with_z(0):normalized()
			vec2 = vec2:with_z(0):normalized()

			--if both previous and current positions almost make a straight line to the next nav_point
			--there's no need to shorten it or even use nav rays to check for obstructions
			if vec1:dot(vec2) < 0.9 then
				--local line1 = Draw:brush(Color.blue:with_alpha(0.5), 3)
				--line1:cylinder(bwd_pos, pos, 15)

				--find the 6/10 point between the current and previous position
				mvec3_lerp(test_pos, bwd_pos, pos, 0.6)

				local too_much_height = math_abs(test_pos.z - fwd_pos.z - (test_pos.z - bwd_pos.z)) > 60

				--if the test_pos results in too much height (like due to a slope)
				--it could be outside of the nav field or just too high up, clamp it
				if too_much_height then
					if temp_tracker then
						temp_tracker:move(test_pos)
						mvec3_set(test_pos, temp_tracker:field_position())
					else
						temp_tracker = create_tracker_f(nav_manager, test_pos)
						mvec3_set(test_pos, temp_tracker:field_position())
					end
				end

				--check if the test position has a clear path to the next nav_point
				local obstructed_ahead = chk_shortcut_func(test_pos, fwd_pos)

				if obstructed_ahead then
					--try again, but using the 8/10 point between the current and previous position
					mvec3_lerp(test_pos, bwd_pos, pos, 0.8)

					--clamp the new test_pos if it had to be done for the other one
					if too_much_height then
						if temp_tracker then
							temp_tracker:move(test_pos)
							mvec3_set(test_pos, temp_tracker:field_position())
						else
							temp_tracker = create_tracker_f(nav_manager, test_pos)
							mvec3_set(test_pos, temp_tracker:field_position())
						end
					end

					obstructed_ahead = chk_shortcut_func(test_pos, fwd_pos)
				end

				if not obstructed_ahead then
					--replace the current position with the test position
					mvec3_set(pos, test_pos)

					--local line1 = Draw:brush(Color.green:with_alpha(0.5), 3)
					--line1:cylinder(bwd_pos, pos, 15)
				end
			--[[else
				local line1 = Draw:brush(Color.red:with_alpha(0.5), 3)
				line1:cylinder(bwd_pos, pos, 15)
				line1:cylinder(pos, fwd_pos, 15)]]
			end

			index = index + 1
		end
	end

	if temp_tracker then
		destroy_tracker_f(nav_manager, temp_tracker)
	end
end

local diagonals = {
	tmp_vec1,
	tmp_vec2
}

function CopActionWalk._apply_padding_to_simplified_path(path)
	local nav_point_pos_func = CopActionWalk._nav_point_pos
	local chk_shortcut_func = CopActionWalk._chk_shortcut_pos_to_pos
	local nav_manager = managers.navigation
	local create_tracker_f = nav_manager.create_nav_tracker
	local destroy_tracker_f = nav_manager.destroy_nav_tracker

	local dim_mag = 212.132

	mvec3_set_stat(tmp_vec1, dim_mag, dim_mag, 0)
	mvec3_set_stat(tmp_vec2, dim_mag, -dim_mag, 0)

	local index = 2
	local offset = tmp_vec3
	local ground_ray_slotmask = managers.slot:get_mask("AI_graph_obstacle_check")
	local temp_tracker, chk_clamp_prev, chk_clamp_next = nil

	while index < #path do
		local prev_point = path[index - 1]
		local cur_point = path[index]

		if not cur_point.x then
			--current point is a nav_link, cannot apply padding to this section, skip two points ahead
			index = index + 2

			chk_clamp_prev, chk_clamp_next = nil
		elseif not prev_point.x then
			--previous point is a nav_link, cannot apply padding to this section, skip one point ahead
			index = index + 1

			chk_clamp_prev, chk_clamp_next = nil
		else
			--if the next nav point is a nav_link, that's fine, its initial pos is valid for these purposes

			local pos = cur_point
			local bwd_pos = prev_point
			local fwd_point = path[index + 1]
			local fwd_pos = nav_point_pos_func(fwd_point)
			local too_much_height = math_abs(pos.z - fwd_pos.z - (pos.z - bwd_pos.z)) > 60

			if too_much_height then
				--some nav_points can end up in the air due to how path searching works, we want to ensure this is not the case
				--if these nav points were not clamped in a previous loop, attempt to do so now

				if not chk_clamp_prev then
					--[[local below_pos = bwd_pos + math_down * 200
					local nav_ray_clamp_check = world_g:raycast("ray", bwd_pos, below_pos, "slot_mask", ground_ray_slotmask, "ray_type", "walk")

					if nav_ray_clamp_check then
						mvec3_set(bwd_pos, nav_ray_clamp_check.position)
					end]]

					if temp_tracker then
						temp_tracker:move(bwd_pos)
						mvec3_set(bwd_pos, temp_tracker:field_position())
					else
						temp_tracker = create_tracker_f(nav_manager, bwd_pos)
						mvec3_set(bwd_pos, temp_tracker:field_position())
					end
				end

				chk_clamp_prev = nil

				if not chk_clamp_next then
					--[[local below_pos = pos + math_down * 200
					local nav_ray_clamp_check = world_g:raycast("ray", pos, below_pos, "slot_mask", ground_ray_slotmask, "ray_type", "walk")

					if nav_ray_clamp_check then
						mvec3_set(pos, nav_ray_clamp_check.position)
					end]]

					if temp_tracker then
						temp_tracker:move(pos)
						mvec3_set(pos, temp_tracker:field_position())
					else
						temp_tracker = create_tracker_f(nav_manager, pos)
						mvec3_set(pos, temp_tracker:field_position())
					end

					chk_clamp_prev = true
				end

				chk_clamp_next = nil

				--skip nav_links here, we don't want (or need) to modify their initial position
				if fwd_point.x then
					--[[local below_pos = fwd_pos + math_down * 200
					local nav_ray_clamp_check = world_g:raycast("ray", fwd_pos, below_pos, "slot_mask", ground_ray_slotmask, "ray_type", "walk")

					if nav_ray_clamp_check then
						mvec3_set(fwd_pos, nav_ray_clamp_check.position)
					end]]

					if temp_tracker then
						temp_tracker:move(fwd_pos)
						mvec3_set(fwd_pos, temp_tracker:field_position())
					else
						temp_tracker = create_tracker_f(nav_manager, fwd_pos)
						mvec3_set(fwd_pos, temp_tracker:field_position())
					end

					chk_clamp_next = true
				end
			elseif chk_clamp_next then
				chk_clamp_prev = true
				chk_clamp_next = nil
			else
				chk_clamp_prev = nil
			end

			for i = 1, #diagonals do
				local diagonal = diagonals[i]
				local to_pos = pos + diagonal

				--clamp the vector made from the position and the diagonal based on the nav mesh
				local collision, trace = chk_shortcut_func(pos, to_pos, true)

				mvec3_set(offset, trace[1])
				mvec3_mul(diagonal, -1)

				to_pos = pos + diagonal

				--clamp the oppposite one as well
				local collision_2, trace_2 = chk_shortcut_func(pos, to_pos, true)

				--move the clamped position to the middle point between the clamped vectors
				mvec3_lerp(offset, offset, trace_2[1], 0.5)

				local too_much_height = math_abs(offset.z - fwd_pos.z - (offset.z - bwd_pos.z)) > 60

				--if the offset pos results in too much height (like due to a slope)
				--it could be outside of the nav field or just too high up, clamp it
				if too_much_height then
					if temp_tracker then
						temp_tracker:move(offset)
						mvec3_set(offset, temp_tracker:field_position())
					else
						temp_tracker = create_tracker_f(nav_manager, offset)
						mvec3_set(offset, temp_tracker:field_position())
					end
				end

				local obstructed = chk_shortcut_func(offset, fwd_pos) or chk_shortcut_func(offset, bwd_pos)

				--if the test position has a clear path to the previous and next nav_point, replace the original one with it
				if not obstructed then
					mvec3_set(pos, offset)
				end
			end

			index = index + 1
		end
	end

	if temp_tracker then
		destroy_tracker_f(nav_manager, temp_tracker)
	end
end

function CopActionWalk:_calculate_curved_path(path, index, curvature_factor, enter_dir)
	local nav_point_pos_func = self._nav_point_pos
	local p1 = nav_point_pos_func(path[index])
	local p4 = nav_point_pos_func(path[index + 1])
	local p2, p3 = nil
	local curved_path = {
		mvec3_cpy(p1)
	}
	local segment_dis = mvec3_dis(p1, p4:with_z(p1.z))
	local nr_control_pts = 2

	--entering from a previous path (potentially a curved one)
	if enter_dir then
		nr_control_pts = nr_control_pts + 1

		local vec_out = tmp_vec1
		mvec3_set(vec_out, enter_dir)
		mvec3_set_l(vec_out, segment_dis)
		--copy of the enter dir vector with the length of the segment

		local vec_in = p4 - p1
		mvec3_set_l(vec_in, segment_dis * curvature_factor)
		--vector based on the segment and its direction, but with the length multiplied by curvature_factor

		vec_out = vec_out + vec_in
		vec_out = vec_out:with_z(0)

		mvec3_set_l(vec_out, segment_dis * 0.3)
		--2D result of the sum of the vectors, with 30% of the length of the segment

		p2 = p1 + vec_out
		--curve vector that goes from the start of the segment
		--to the direction the unit was entering + 30% of the length of the segment
	end

	--has another position to move to after the current destination
	--the unit may be able to do another curve path when reaching the end of this segment
	local future_point = p2 and path[index + 2]

	if future_point then
		nr_control_pts = nr_control_pts + 1

		local future_pos = nav_point_pos_func(future_point)
		local vec_out = p4 - future_pos
		mvec3_set_l(vec_out, segment_dis)

		local vec_in = p1 - p2
		mvec3_set_l(vec_in, segment_dis * curvature_factor)

		vec_out = vec_out + vec_in
		vec_out = vec_out:with_z(0)

		mvec3_set_l(vec_out, segment_dis * 0.3)

		p3 = p4 + vec_out
	end

	if nr_control_pts < 3 then
		--cannot create a curve, just use a straight line
		curved_path[#curved_path + 1] = mvec3_cpy(p4)
	else
		--make a smooth bezier curve, but verify that it's not obstructed
		--if it is, retry again if the curvature_factor isn't lower than 1, else use a straight line
		local chk_shortcut_func = self._chk_shortcut_pos_to_pos
		local nr_samples = 7
		local prev_pos = curved_path[1]

		for i = 1, nr_samples - 1 do
			local pos = tmp_vec1

			if nr_control_pts == 3 then
				mvec3_bezier(pos, p1, p2 or p3, p4, i / nr_samples)
			else
				mvec3_bezier(pos, p1, p2, p3, p4, i / nr_samples)
			end

			local obstructed_point = chk_shortcut_func(prev_pos, pos)

			if obstructed_point then
				--local line1 = Draw:brush(Color.red:with_alpha(0.5), 5)
				--line1:cylinder(prev_pos, pos, 15)

				if curvature_factor < 1 then
					local simple_curved_path = {
						curved_path[1],
						mvec3_cpy(p4)
					}

					--local line1 = Draw:brush(Color.blue:with_alpha(0.5), 5)
					--line1:cylinder(simple_curved_path[1], simple_curved_path[2], 15)

					return simple_curved_path
				else
					return self:_calculate_curved_path(path, index, 0.5, enter_dir)
				end
			--else
				--local line1 = Draw:brush(Color.yellow:with_alpha(0.5), 5)
				--line1:cylinder(prev_pos, pos, 15)
			end

			curved_path[#curved_path + 1] = mvec3_cpy(pos)

			prev_pos = curved_path[#curved_path]
		end

		local obstructed_point = chk_shortcut_func(prev_pos, p4)

		if obstructed_point then
			--local line1 = Draw:brush(Color.red:with_alpha(0.5), 5)
			--line1:cylinder(prev_pos, p4, 15)

			if curvature_factor < 1 then
				local simple_curved_path = {
					curved_path[1],
					mvec3_cpy(p4)
				}

				--local line1 = Draw:brush(Color.blue:with_alpha(0.5), 5)
				--line1:cylinder(simple_curved_path[1], simple_curved_path[2], 15)

				return simple_curved_path
			else
				return self:_calculate_curved_path(path, index, 0.5, enter_dir)
			end
		--else
			--local line1 = Draw:brush(Color.yellow:with_alpha(0.5), 5)
			--line1:cylinder(prev_pos, p4, 15)
		end

		curved_path[#curved_path + 1] = mvec3_cpy(p4)
	end

	--[[local line1 = Draw:brush(Color.green:with_alpha(0.5), 5)

	for i = 1, #curved_path -1 do
		local pos = curved_path[i]
		local next_pos = curved_path[i + 1]

		line1:cylinder(pos, next_pos, 10)
	end]]

	return curved_path
end

function CopActionWalk:on_exit()
	local expired = self._expired
	local ext_mov = self._ext_movement
	local ext_dmg = self._common_data.ext_damage
	--[[local end_rot = self._end_rot

	if expired and end_rot then
		ext_mov:set_rotation(end_rot)
	end]]

	if self._root_blend_disabled then
		ext_mov:set_root_blend(true)

		self._root_blend_disabled = nil
	end

	if self._changed_driving then
		self._common_data.unit:set_driving("script")

		self._changed_driving = nil
	end

	if expired and self._ext_anim.move then
		self:_stop_walk()
	end

	ext_mov:drop_held_items()

	local is_server = self._sync

	if is_server then
		--action was actually started properly (and thus was also synced to begin with)
		if self._init_called then
			local is_dead = ext_dmg:dead()
			--action was interrupted
			if not expired then
				--sync the current position of the unit as a nav_point so that the unit will go there
				--for clients before expiring the action, to make them match their current real position
				if not is_dead then
					self._ext_network:send("action_walk_nav_point", mvec3_cpy(ext_mov:m_pos()))
				end

				if not self._has_dead_nav_link then
					local s_path = self._simplified_path

					--remove the delay on any nav_links that the unit was planning to use before being interrupted
					for i = 1, #s_path do
						local nav_point = s_path[i]

						if not nav_point.x and nav_point.element:nav_link_delay() then
							nav_point.c_class:set_delay_time(0)
						end
					end
				end
			end

			if not is_dead then
				self._ext_network:send("action_walk_stop")
			end
		end
	else
		--update host_stop_pos
		ext_mov:set_m_host_stop_pos(ext_mov:m_pos())
	end

	--remove nav_link invulnerability
	if self._nav_link_invul_on then
		self._nav_link_invul_on = nil

		ext_dmg:set_invulnerable(false)
	end

	--remove destination position reservation
	if is_server then
		self._ext_brain:rem_pos_rsrv("move_dest")
	end
end

function CopActionWalk:_upd_wait_for_full_blend(t)
	local ext_anim = self._ext_anim

	if ext_anim.needs_idle and not ext_anim.to_idle then
		local res = self._ext_movement:play_redirect("idle")

		if not res then
			return
		end

		self._ext_movement:spawn_wanted_items()
	end

	if not ext_anim.to_idle and ext_anim.idle_full_blend then
		self._waiting_full_blend = nil

		if self:_init() then
			self._ext_movement:drop_held_items()

			if self.update == self._upd_wait_for_full_blend then
				self:_set_updator(nil)
			end
		elseif self._sync then
			--instead of expiring the action, interrupt it to avoid (mostly) logic-related issues
			self._ext_movement:action_request({
				body_part = 2,
				type = "idle"
			})
		end
	else
		local ext_mov = self._ext_movement

		ext_mov:set_m_rot(self._unit:rotation())
		ext_mov:set_m_pos(self._unit:position())
	end
end

function CopActionWalk:update(t)
	local dt = nil
	local vis_state = self._ext_base:lod_stage() or 4

	--skip updating for a few frames depending on the animation lod stage set on the unit
	--this will save some performance without any noticeable effects
	if vis_state == 1 then
		dt = t - self._last_upd_t
		self._last_upd_t = self._timer:time()
	elseif self._skipped_frames < vis_state then
		self._skipped_frames = self._skipped_frames + 1

		return
	else
		self._skipped_frames = 1
		dt = t - self._last_upd_t
		self._last_upd_t = self._timer:time()
	end

	--won't be used here due to other changes in other action files making it unnecessary
	--[[local ik_update = self._ik_update

	if ik_update then
		ik_update(t)
	end]]

	local common_data = self._common_data
	local ext_anim = self._ext_anim
	local reached_end_of_path = nil

	--when the end of a path is reached, first ensure the unit stops completely
	if self._end_of_path and not ext_anim.act then
		if ext_anim.move then
			self:_stop_walk()
		end

		if not ext_anim.walk then
			reached_end_of_path = true
		end
	end

	if reached_end_of_path then
		if self._next_is_nav_link then
			--nav_links get to immediately start updating on the same frame
			self:_set_updator("_upd_nav_link_first_frame")
			self:update(t)
		elseif self._persistent then
			--wait for more nav points to be received
			self:_set_updator("_upd_wait")
		else
			self._expired = true

			local end_rot = self._end_rot

			if end_rot then
				self._ext_movement:set_rotation(end_rot)
			end
		end

		return
	else
		self:_nav_chk_walk(t, dt, vis_state)
	end

	local move_dir = nil
	local expired = self._expired
	local not_walking = expired or self._cur_vel < 0.1 or ext_anim.act and ext_anim.walk
	local cur_pos = common_data.pos
	local last_pos = self._last_pos

	if not not_walking then
		move_dir = last_pos - cur_pos
		move_dir = move_dir:with_z(0)
	end

	--if not moving, stop the moving animation if possible and just apply gravity
	if not move_dir then
		if not ext_anim.act and ext_anim.move and not expired then
			self:_stop_walk()
		end

		self:_set_new_pos(dt)

		return
	end

	local wanted_walk_dir, turning_to_face_attention = nil
	local move_dir_norm = move_dir:normalized()
	local walk_turn = self._walk_turn
	local footstep_pos = self._footstep_pos
	local c_path_end_rot = self._curve_path_end_rot

	if walk_turn or self._no_strafe then
		--force forward facing
		wanted_walk_dir = "fwd"
	else
		local face_fwd = nil

		--near end of a curved path
		--and the distance to the last footstep is less than 1.4m
		if c_path_end_rot and mvec3_dis_sq(last_pos, footstep_pos:with_z(last_pos.z)) < 19600 then
			--keep facing the same way the unit is currently facing
			face_fwd = common_data.fwd
		else
			local att_pos = self._attention_pos

			if att_pos then --prioritize facing the current attention
				face_fwd = att_pos - cur_pos

				turning_to_face_attention = true
			elseif footstep_pos then --else the last footstep pos
				face_fwd = footstep_pos - cur_pos
			else --else just face the direction the unit is moving to
				face_fwd = move_dir
			end
		end

		face_fwd = face_fwd:with_z(0):normalized()

		local face_right = face_fwd:cross(math_up):normalized()
		local right_dot = move_dir_norm:dot(face_right)
		local fwd_dot = move_dir_norm:dot(face_fwd)
		local abs_right_dot = math_abs(right_dot)
		local abs_fwd_dot = math_abs(fwd_dot)

		if abs_right_dot < abs_fwd_dot then
			local strafe = nil

			if abs_fwd_dot < 0.73 then
				strafe = ext_anim.move_l and right_dot < 0 or ext_anim.move_r and right_dot > 0
			end

			if strafe then
				wanted_walk_dir = ext_anim.move_side
			elseif fwd_dot > 0 then
				wanted_walk_dir = "fwd"
			else
				wanted_walk_dir = "bwd"
			end
		else
			local fwd_or_bwd = nil

			if abs_right_dot < 0.73 then
				fwd_or_bwd = ext_anim.move_fwd and fwd_dot > 0 or ext_anim.move_bwd and fwd_dot < 0
			end

			if fwd_or_bwd then
				wanted_walk_dir = ext_anim.move_side
			elseif right_dot > 0 then
				wanted_walk_dir = "r"
			else
				wanted_walk_dir = "l"
			end
		end
	end

	local new_rot = nil

	if c_path_end_rot then --reaching end of path, turn towards the end position based on distance
		local dis_lerp = mvec3_dis(last_pos, footstep_pos:with_z(last_pos.z)) / 140
		dis_lerp = dis_lerp < 1 and 1 - dis_lerp or 0

		new_rot = c_path_end_rot:slerp(self._nav_link_rot or self._end_rot, dis_lerp)
	else
		new_rot = temp_rot1

		local wanted_u_fwd = move_dir_norm:rotate_with(self._walk_side_rot[wanted_walk_dir])
		mrot_lookat(new_rot, wanted_u_fwd, math_up)

		--if turning towards an attention, prevent insta-turning, else do the usual vanilla insta-turn (interpolated by delta time)
		local lerp_modifier = not turning_to_face_attention and 1 or self._shield_turning and 0.15 or 0.3
		local delta_lerp = dt * 5 * lerp_modifier
		delta_lerp = delta_lerp > 1 and 1 or delta_lerp
		new_rot = common_data.rot:slerp(new_rot, delta_lerp)
	end

	local ext_mov = self._ext_movement

	ext_mov:set_rotation(new_rot)

	if walk_turn then
		local curve_dis = mvec3_dis(self._curve_path[self._curve_path_index + 1]:with_z(last_pos.z), last_pos)

		--start an animation-driven walk turn once close enough to the start of the curve
		if curve_dis < 45 then
			--but only if the unit is in a high animation lod stage
			if vis_state > 2 then
				walk_turn = nil
				self._walk_turn = nil
			else
				self:_set_updator("_upd_walk_turn_first_frame")
			end
		end
	end

	if not walk_turn then
		local chk_stop_dis = self._chk_stop_dis

		--needs to check for stopping due to run_stop animations
		if chk_stop_dis then
			local s_path = self._simplified_path
			local end_dis = mvec3_dis(self._nav_point_pos(s_path[#s_path]):with_z(last_pos.z), last_pos)

			if end_dis < chk_stop_dis then
				local stop_pose = self._action_desc.end_pose

				--use end_pose only if not persistent
				--this doesn't affect the host, but it will prevent units on clients that might arrive to a nav_point earlier
				--from changing their pose locally, and potentially more than once
				if stop_pose and not self._persistent then
					if stop_pose ~= ext_anim.pose then
						self._ext_movement:action_request({
							body_part = 4,
							type = stop_pose,
							no_sync = true
						})
					end

					self._action_desc.end_pose = nil
				else
					stop_pose = ext_anim.pose
				end

				--if in a high animation lod stage
				--do the more accurate (and heavier) checks regarding when to start the animation and which one to use
				if vis_state < 3 then
					local end_rot = not self._nav_link_rot and self._end_rot
					local stop_anim_fwd = end_rot and end_rot:y() or move_dir_norm:rotate_with(self._walk_side_rot[wanted_walk_dir])
					local fwd_dot = stop_anim_fwd:dot(move_dir_norm)
					local move_dir_r_norm = move_dir_norm:cross(math_up):normalized()
					local r_dot = stop_anim_fwd:dot(move_dir_r_norm)
					local stop_anim_side = nil

					if math_abs(r_dot) < math_abs(fwd_dot) then
						if fwd_dot > 0 then
							stop_anim_side = "fwd"
						else
							stop_anim_side = "bwd"
						end
					elseif r_dot > 0 then
						stop_anim_side = "l"
					else
						stop_anim_side = "r"
					end

					local stop_dis = self._anim_movement[stop_pose]["run_stop_" .. stop_anim_side]

					--no stop_dis means the unit doesn't have the needed run_stop animation (based on pose and direction)
					if stop_dis then
						if end_dis < stop_dis then
							self._stop_anim_side = stop_anim_side
							self._stop_anim_fwd = stop_anim_fwd
							self._stop_dis = stop_dis

							if not self._root_blend_disabled then
								self._ext_movement:set_root_blend(false)

								self._root_blend_disabled = true
							end

							self:_set_updator("_upd_stop_anim_first_frame")
						end
					else
						self._chk_stop_dis = nil
					end
				end
			end
		elseif not self._persistent then --make use of end_pose even when not having chk_stop_dis, but only if not persistent
			local end_pose = self._action_desc.end_pose

			if end_pose then
				local s_path = self._simplified_path

				if #s_path == 2 then
					local end_dis = mvec3_dis(self._nav_point_pos(s_path[2]):with_z(last_pos.z), last_pos)

					if end_dis < 210 then
						if end_pose ~= ext_anim.pose then
							--self._ext_movement:play_redirect(end_pose)

							self._ext_movement:action_request({
								body_part = 4,
								type = end_pose,
								no_sync = true
							})
						end

						self._action_desc.end_pose = nil
					end
				end
			end
		end
	end

	--determine if the current movement animation needs to be changed between walk, run and sprint
	--but only if the unit is supposed to be running (based on the current animation, pose, stance and velocity)
	local stance = self._stance
	local stance_name = stance.name
	local pose = stance.values[4] > 0 and "wounded" or ext_anim.pose or "stand"
	local anim_velocities = self._walk_anim_velocities
	local wanted_walk = anim_velocities[pose] or anim_velocities["stand"] or anim_velocities["crouch"]
	wanted_walk = wanted_walk[stance_name] or wanted_walk["cbt"] or wanted_walk["hos"] or wanted_walk["ntl"]

	local real_velocity = self._cur_vel
	local variant = self._haste

	if variant == "run" then
		if ext_anim.sprint then
			if ext_anim.pose == "stand" and real_velocity > 480 then
				variant = "sprint"
			elseif real_velocity > 250 then
				variant = "run"
			elseif not self._no_walk then
				variant = "walk"
			end
		elseif ext_anim.run then
			--if wanted_walk then
				if wanted_walk and wanted_walk.sprint and real_velocity > 530 and ext_anim.pose == "stand" then
					variant = "sprint"
				elseif real_velocity > 250 then
					variant = "run"
				elseif not self._no_walk then
					variant = "walk"
				end
			--end
		elseif wanted_walk and wanted_walk.sprint and real_velocity > 530 and ext_anim.pose == "stand" then
			variant = "sprint"
		elseif real_velocity > 300 then
			variant = "run"
		elseif not self._no_walk then
			variant = "walk"
		end
	end

	--sanity checking that can potentially waste a lot of performance when it's not needed if things are done properly
	--[[if not safe_get_value_g(anim_velocities, pose, stance_name, variant, wanted_walk_dir) then
		if stance_name == "ntl" and not safe_get_value_g(anim_velocities, pose, stance_name) then
			stance_name = "cbt"
		end

		while not safe_get_value_g(anim_velocities, pose, stance_name, variant) do
			if variant == "sprint" then
				variant = "run"
			end

			if variant == "run" then
				variant = "walk"
			end
		end

		if not safe_get_value_g(anim_velocities, pose, stance_name, variant, wanted_walk_dir) then
			return
		end
	end]]

	self:_adjust_move_anim(wanted_walk_dir, variant)

	--adjust movement anim speed based on the variant that might've changed above + direction
	wanted_walk = wanted_walk[variant] or wanted_walk["run"] or wanted_walk["walk"]
	local anim_walk_speed = wanted_walk and wanted_walk[wanted_walk_dir]

	if not anim_walk_speed then
		self:_set_new_pos(dt)

		return
	end

	local wanted_walk_anim_speed = real_velocity / anim_walk_speed

	self:_adjust_walk_anim_speed(dt, wanted_walk_anim_speed)
	self:_set_new_pos(dt)
end

function CopActionWalk:_upd_start_anim_first_frame(t)
	local pose = self._ext_anim.pose or "stand"
	local speed = self:_get_current_max_walk_speed("fwd")
	local speed_mul = speed / self._walk_anim_velocities[pose][self._stance.name].run.fwd
	local start_run_turn = self._start_run_turn
	local start_run_dir = start_run_turn and start_run_turn[3] or self._start_run_straight

	self:_start_move_anim(start_run_dir, "run", speed_mul, start_run_turn)

	--self._cur_vel = speed
	self._start_max_vel = 0

	self:_set_updator("_upd_start_anim")

	local ext_base = self._ext_base

	ext_base:chk_freeze_anims()

	if ext_base:lod_stage() ~= 1 then
		return
	end

	--update immediately if in the highest lod stage
	self:update(t)
end

function CopActionWalk:_upd_start_anim(t)
	local ext_anim = self._ext_anim
	local common_data = self._common_data

	--if the animation is done
	if not ext_anim.run_start then
		if self._root_blend_disabled then
			self._ext_movement:set_root_blend(true)

			self._root_blend_disabled = nil
		end

		self._start_run = nil

		local current_pos = common_data.pos

		--if not doing a run_turn animation, just set the beginning of the curve path as the current position
		if not self._start_run_turn then
			mvec3_set(self._curve_path[1], current_pos)
		else
			self._start_run_turn = nil

			local curve_path = self._curve_path
			local chk_shortcut_func = self._chk_shortcut_pos_to_pos

			--if the path is a straight line, get back into said line to avoid potential clipping issues
			if not curve_path[3] then
				local old_pos = curve_path[1]
				local next_pos = curve_path[2]

				local vec_from_cur = next_pos - current_pos
				local length_from_cur = vec_from_cur:with_z(0):length() * 0.5
				local vec_from_old = next_pos - old_pos
				local length_from_old = vec_from_old:with_z(0):length()

				--get an interpolated test position based on half of the distance between the current pos and the next pos
				mvec3_lerp(vec_from_old, old_pos, next_pos, length_from_cur / length_from_old)

				--if the path to this test position is obstructed, try again with less distance
				if chk_shortcut_func(current_pos, vec_from_old) then
					--local line1 = Draw:brush(Color.red:with_alpha(0.5), 3)
					--line1:cylinder(current_pos, vec_from_old, 15)

					length_from_cur = vec_from_cur:with_z(0):length() * 0.75

					mvec3_lerp(vec_from_old, old_pos, next_pos, length_from_cur / length_from_old)

					--if the path is obstructed again, just use the distance between current pos and old pos
					--this might make the unit do a sudden movement to get back into the path, but will almost ensure no clippling issues occur due to the animation
					if chk_shortcut_func(current_pos, vec_from_old) then
						--line1:cylinder(current_pos, vec_from_old, 15)

						vec_from_cur = current_pos - old_pos
						length_from_cur = vec_from_cur:with_z(0):length()

						mvec3_lerp(vec_from_old, old_pos, next_pos, length_from_cur / length_from_old)
					end
				end

				curve_path = {
					mvec3_cpy(current_pos),
					vec_from_old,
					next_pos
				}

				--[[local line1 = Draw:brush(Color.green:with_alpha(0.5), 3)
				line1:cylinder(current_pos, vec_from_old, 15)

				local line2 = Draw:brush(Color.blue:with_alpha(0.5), 3)
				line2:cylinder(old_pos, next_pos, 15)

				local line3 = Draw:brush(Color.yellow:with_alpha(0.5), 3)
				line3:cylinder(vec_from_old, next_pos, 15)]]
			else
				--if the animation caused the unit to skip some points of the curved path, attempt to short-cut to the next non-skipped one
				--this is done by checking if two vectors, one made from the current pos and the other from the starting pos, both pointed towards the next nav_point
				--give a negative dot product when compared to each other, which means the nav point was left behind. If that or the shortcut check fails, the loop stops there

				local old_pos = curve_path[1]
				curve_path[1] = mvec3_cpy(current_pos)

				local copied_cur_pos = mvec3_cpy(current_pos)
				local vec_from_old = current_pos - old_pos
				vec_from_old = vec_from_old:with_z(0):normalized()

				while true do
					local vec_to_next = curve_path[2] - current_pos
					vec_to_next = vec_to_next:with_z(0):normalized()

					if vec_to_next:dot(vec_from_old) < 0 and not chk_shortcut_func(current_pos, curve_path[3]) then
						local new_curved_path = {
							copied_cur_pos
						}

						for idx = 3, #curve_path do
							new_curved_path[#new_curved_path + 1] = curve_path[idx]
						end

						curve_path = new_curved_path

						if not curve_path[3] then
							break
						end
					else
						break
					end
				end
			end

			self._curve_path = curve_path
		end

		self._last_pos = mvec3_cpy(current_pos)
		self._curve_path_index = 1
		self._start_max_vel = nil

		self:_set_updator(nil)
		self:update(t)

		return
	end

	local dt = self._timer:delta_time()
	local start_run_turn = self._start_run_turn

	if start_run_turn then
		if ext_anim.run_start_full_blend then
			--move the unit based on the animation, but while still clamping it to the nav field
			local seg_rel_t = self._machine:segment_relative_time(idstr_base)
			local start_rel_t = start_run_turn.start_seg_rel_t

			if not start_rel_t then
				start_rel_t = seg_rel_t
				start_run_turn.start_seg_rel_t = seg_rel_t
			end

			local delta_pos = common_data.unit:get_animation_delta_position()
			local new_pos = common_data.pos + delta_pos
			local ray_params = {
				allow_entry = true,
				trace = true,
				tracker_from = common_data.nav_tracker,
				pos_to = new_pos
			}
			local collision = managers.navigation:raycast(ray_params)

			--clamp velocity (and maximum starting velocity) if needed
			if collision then
				new_pos = ray_params.trace[1] --clamped pos
				local travel_vec = new_pos - self._last_pos
				local clamped_vel = travel_vec:with_z(0):length() / dt

				self._cur_vel = clamped_vel
				self._start_max_vel = clamped_vel
			else
				local travel_vec = new_pos - self._last_pos
				local new_vel = travel_vec:with_z(0):length() / dt
				local start_max_vel = self._start_max_vel

				self._cur_vel = new_vel < start_max_vel and start_max_vel or new_vel
			end

			self._last_pos = new_pos

			--rotate unit towards the wanted turn direction based on animation progress and start time
			local seg_rel_t_clamp = math_clamp((seg_rel_t - start_rel_t) / 0.77, 0, 1)
			local prog_angle = start_run_turn[2] * seg_rel_t_clamp
			local new_yaw = start_run_turn[1] + prog_angle
			local new_rot = temp_rot1

			mrot_set(new_rot, new_yaw, 0, 0)
			self._ext_movement:set_rotation(new_rot)
		else
			start_run_turn.start_seg_rel_t = self._machine:segment_relative_time(idstr_base)
		end
	else
		local reached_end_of_path = nil

		--when the end of a path is reached, first ensure the unit stops completely
		if self._end_of_path and not ext_anim.act then
			if ext_anim.move then
				self:_stop_walk()
			end

			if not ext_anim.walk then
				reached_end_of_path = true
			end
		end

		if reached_end_of_path then
		--if self._end_of_path then
			if self._next_is_nav_link then
				self._start_run = nil

				--nav_links get to immediately start updating on the same frame
				self:_set_updator("_upd_nav_link_first_frame")
				self:update(t)
			elseif self._persistent then
				self._start_run = nil

				--wait for more nav points to be received
				self:_set_updator("_upd_wait")
			else
				self._expired = true

				local end_rot = self._end_rot

				if end_rot then
					self._ext_movement:set_rotation(end_rot)
				end
			end

			return
		else
			local vis_state = self._ext_base:lod_stage() or 4

			self:_nav_chk_walk(t, dt, vis_state)
		end

		--if not reaching end of path, rotate the unit towards the wanted run_start direction (interpolated by delta time)
		if not self._end_of_curved_path then
			local wanted_u_fwd = self._curve_path[self._curve_path_index + 1] - common_data.pos
			wanted_u_fwd = wanted_u_fwd:with_z(0):normalized():rotate_with(self._walk_side_rot[self._start_run_straight])

			local new_rot = temp_rot1
			mrot_lookat(new_rot, wanted_u_fwd, math_up)

			local delta_lerp = dt * 5
			delta_lerp = delta_lerp > 1 and 1 or delta_lerp

			new_rot = common_data.rot:slerp(new_rot, delta_lerp)

			self._ext_movement:set_rotation(new_rot)
		end
	end

	self:_set_new_pos(dt)
end

function CopActionWalk:_set_new_pos(dt)
	local mov_ext = self._ext_movement
	local common_data = self._common_data
	local path_pos = self._last_pos
	local path_z = path_pos.z

	mov_ext:upd_ground_ray(path_pos, true)

	--ground ray height, clamped by 80 cm above and below the height of the new position
	local gnd_z = common_data.gnd_ray.position.z
	gnd_z = math_clamp(gnd_z, path_z - 80, path_z + 80)

	local cur_z = common_data.pos.z
	local new_pos = nil

	--apply gravity if above the ground ray position
	if gnd_z < cur_z then
		new_pos = path_pos:with_z(cur_z)

		self._last_vel_z = self._apply_freefall(new_pos, self._last_vel_z, gnd_z, dt)
	else
		--else, since height is either below or equal to the ground ray height, just set it to that value
		new_pos = path_pos:with_z(gnd_z)

		--set falling velocity to 0 since the unit is now on the ground
		self._last_vel_z = 0
	end

	mov_ext:set_position(new_pos)
end

function CopActionWalk:get_husk_interrupt_desc()
	local old_action_desc = {
		path_simplified = true,
		type = "walk",
		interrupted = true,
		body_part = self._body_part,
		end_rot = self._end_rot,
		variant = self._haste,
		nav_path = self._simplified_path,
		persistent = self._persistent,
		no_walk = self._no_walk,
		no_strafe = self._no_strafe,
		host_stop_pos_ahead = self._host_stop_pos_ahead--[[,
		old_start_t = self._start_t, --wip
		interrupt_t = self._timer:time(), --wip
		pose = self._action_desc.pose,
		end_pose = self._action_desc.end_pose]] --these are just going to cause issues if the action was already interrupted
	}

	local sync_blocks = self._blocks or self._old_blocks

	if sync_blocks then
		local blocks = {}

		for i, k in pairs_g(sync_blocks) do
			blocks[i] = -1
		end

		old_action_desc.blocks = blocks
	end

	return old_action_desc
end

function CopActionWalk:on_attention(attention)
	--units in neutral stances (cool/not alerted) are not supposed to turn (while moving) towards any kind of attention
	if attention and self._stance.name ~= "ntl" then
		local att_handler = attention.handler

		if att_handler then
			--outside of stealth, don't turn towards attentions unless the reaction is to shoot or higher
			local reaction_to_check = managers.groupai:state():enemy_weapons_hot() and REACT_SHOOT or REACT_SCARED

			if reaction_to_check <= attention.reaction then
				self._attention_pos = att_handler:get_ground_m_pos()
			else
				self._attention_pos = nil
			end
		else
			local att_unit = attention.unit

			if att_unit then
				local att_mov_ext = att_unit:movement()

				self._attention_pos = att_mov_ext and att_mov_ext:m_pos() or att_unit:position()
			else
				self._attention_pos = attention.pos or nil
			end
		end
	else
		self._attention_pos = nil
	end

	self._attention = attention
end

function CopActionWalk:_get_max_walk_speed()
	local speeds_table = self._common_data.char_tweak.move_speed[self._ext_anim.pose][self._haste][self._stance.name]
	local speed_modifier = self._ext_movement:speed_modifier()

	--clone and modify the table if the unit has a speed modifier
	if speed_modifier ~= 1 then
		speeds_table = deep_clone_g(speeds_table)

		for k, v in pairs_g(speeds_table) do
			speeds_table[k] = v * speed_modifier
		end
	end

	return speeds_table
end

function CopActionWalk:_get_current_max_walk_speed(move_dir)
	if move_dir == "l" or move_dir == "r" then
		move_dir = "strafe"
	end

	local speed = self._common_data.char_tweak.move_speed[self._ext_anim.pose][self._haste][self._stance.name][move_dir]
	local speed_modifier = self._ext_movement:speed_modifier()

	if speed_modifier ~= 1 then
		speed = speed * speed_modifier
	end

	--client-only
	if not self._sync then
		--action was interrupted before finishing properly, has pending actions, or is too far away from it's server position
		--need to catch up to what the host has synced as final position asap
		if self._action_desc.interrupted or self:_husk_needs_speedup() then
			--[[local host_peer = managers.network:session():server_peer()
			local ping_mul, vis_mul = 1

			if host_peer then
				ping_mul = ping_mul + Network:qos(host_peer:rpc()).ping / 10000
			end]]

			local vis_mul = nil

			--occluded units get a huge speed boost
			if self._occlusion_manager:is_occluded(self._unit) then
				vis_mul = 1.5
			else
				--else, it depends on their animation lod stage
				local lod = self._ext_base:lod_stage()
				local lod_multiplier_add = CopActionWalk.lod_multipliers[lod] or 0.65

				vis_mul = 0.85 + lod_multiplier_add
			end

			--[[local final_multiplier = ping_mul * vis_mul
			final_multiplier = final_multiplier > 2 and 2 or final_multiplier
			speed = speed * final_multiplier]]
			speed = speed * vis_mul
		elseif not managers.groupai:state():enemy_weapons_hot() then --else, apply a very small stealth boost
			speed = speed * self._stealth_boost
		end
	end

	return speed
end

function CopActionWalk:save(save_data)
	if not self._init_called then
		return --action is waiting for idle_full_blend, which means it wasn't even sent to clients yet
	end

	save_data.type = "walk"
	save_data.body_part = self._body_part
	save_data.variant = self._haste
	save_data.end_rot = self._end_rot
	save_data.no_walk = self._no_walk
	save_data.no_strafe = self._no_strafe
	save_data.persistent = true
	save_data.path_simplified = true
	save_data.is_drop_in = true
	save_data.pose = self._action_desc.pose
	save_data.end_pose = self._action_desc.end_pose
	save_data.blocks = {
		act = -1,
		idle = -1,
		turn = -1,
		walk = -1
	}
	local s_path = self._simplified_path
	local sync_path = {}

	--if currently playing a nav_link animation, we need to sync the nav_link info, the unit's height, and the animation index and start time
	if self._updator_name == "_upd_nav_link" then
		local element = s_path[1].element

		sync_path[1] = self.synthesize_nav_link(mvec3_cpy(element:value("position")), element:value("rotation"), element:value("so_action"))--, element:nav_link_wants_align_pos())

		save_data.pos_z = mvec3_z(self._common_data.pos)

		local machine = self._machine
		local state_name = machine:segment_state(idstr_base)
		save_data.start_anim_idx = machine:state_name_to_index(state_name)
		save_data.start_anim_time = machine:segment_real_time(idstr_base)
	else --sync a position for the unit to walk to
		local second_nav_point = s_path[2]

		--which is the next destination
		if second_nav_point then
			if second_nav_point.x then --walking to a normal nav_point
				sync_path[1] = mvec3_cpy(second_nav_point)
			else --walking to a nav_link's starting position
				sync_path[1] = mvec3_cpy(self._nav_point_pos(second_nav_point))
			end
		else --or, as a safety net, the current position of the unit
			sync_path[1] = mvec3_cpy(self._common_data.pos)
		end
	end

	save_data.nav_path = sync_path
end

local shortcut_pos_to_pos_params = {
	allow_entry = false
}

--navigation ray obstruction check, use trace to store and return all the data from the trace process
--this includes a nav-clamped position from a collision or at the end of the ray (look it up as trace[1])
function CopActionWalk._chk_shortcut_pos_to_pos(from, to, trace)
	local params = shortcut_pos_to_pos_params
	params.pos_from = from
	params.pos_to = to
	params.trace = trace
	local res = managers.navigation:raycast(params)

	return res, params.trace
end

function CopActionWalk._calculate_simplified_path(good_pos, original_path, nr_iterations, is_server, apply_padding)
	local s_path = {good_pos}
	local path_size = #original_path
	local nav_point_pos_func = CopActionWalk._nav_point_pos
	local chk_shortcut_func = CopActionWalk._chk_shortcut_pos_to_pos

	if path_size > 2 then
		local index_from = 1

		while index_from < path_size do
			local index_to = index_from + 2

			if index_to > path_size then
				break
			end

			while index_to <= path_size do
				local middle_point = original_path[index_to - 1]

				if not middle_point.x then --nav_link
					s_path[#s_path + 1] = middle_point

					local next_point = original_path[index_to]

					if not next_point.x then
						index_from = index_to - 1
					else
						index_from = index_to

						s_path[#s_path + 1] = is_server and mvec3_cpy(next_point) or next_point
					end

					break
				else
					local pos_from = original_path[index_from]
					local pos_to = nav_point_pos_func(original_path[index_to])
					local blocked = math_abs(pos_from.z - middle_point.z - (middle_point.z - pos_to.z)) > 60 or chk_shortcut_func(pos_from, pos_to)

					if blocked then
						index_from = index_to - 1

						s_path[#s_path + 1] = is_server and mvec3_cpy(middle_point) or middle_point

						break
					end
				end

				index_to = index_to + 1
			end

			if index_to > path_size then
				break
			end
		end
	end

	local first_nav_point = original_path[1]
	local last_nav_point = original_path[path_size]

	if first_nav_point.x and good_pos ~= first_nav_point then
		s_path[1] = is_server and mvec3_cpy(first_nav_point) or first_nav_point
	end

	if not last_nav_point.x then
		s_path[#s_path + 1] = last_nav_point
	else
		s_path[#s_path + 1] = is_server and mvec3_cpy(last_nav_point) or last_nav_point
	end

	if apply_padding and #s_path > 2 then
		CopActionWalk._apply_padding_to_simplified_path(s_path)
		CopActionWalk._calculate_shortened_path(s_path)
	end

	if nr_iterations > 1 and #s_path > 2 then
		s_path = CopActionWalk._calculate_simplified_path(good_pos, s_path, nr_iterations - 1, is_server, apply_padding)
	end

	return s_path
end

function CopActionWalk:_nav_chk_walk(t, dt, vis_state)
	local ext_anim = self._ext_anim
	local move_side = ext_anim.move_side or "fwd"
	local common_data = self._common_data
	local s_path = self._simplified_path
	local c_path = self._curve_path
	local c_index = self._curve_path_index
	local last_pos = self._last_pos
	local cur_pos = common_data.pos
	local cur_max_walk_speed, vel, delta_pos = nil

	if ext_anim.act and ext_anim.walk then
		--animation-driven walk, determine velocity based on the animation (almost sure this is unused, but I'm improving it anyway)
		delta_pos = common_data.unit:get_animation_delta_position()

		--like it's done in another function and in most cases below, it's important to determine distance and/or velocity without the influence of height
		--the reason for this is that walking is handled in a 2D environment where height/gravity doesn't affect the movement of the unit, and is sorted separately
		local travel_vec = cur_pos + delta_pos - last_pos
		vel = travel_vec:with_z(0):length() / dt

		if vel == 0 then
			return
		end
	else
		--store current maximum walk speed to avoid having to call the function up to *3* more times
		cur_max_walk_speed = self:_get_current_max_walk_speed(move_side)
		vel = cur_max_walk_speed
	end

	local walk_dis = vel * dt
	local footstep_length = 200
	local nav_advanced, new_pos, new_c_index, complete, upd_footstep = nil

	while not self._end_of_curved_path do
		new_pos, new_c_index, complete = self._walk_spline(c_path, last_pos, c_index, walk_dis + footstep_length)
		upd_footstep = true

		if not complete then
			break
		elseif #s_path == 2 then --reached end of the curved and the "normal" path
			self._end_of_curved_path = true

			--use current rotation for the curved path if there's an end rotation defined + this is either the server or the action expired there
			if self._end_rot and not self._persistent then
				self._curve_path_end_rot = Rotation(mrot_yaw(common_data.rot), 0, 0)
			end

			nav_advanced = true

			break
		elseif self._next_is_nav_link then --end of curved path, but not the standard path since a nav_link is next
			self._end_of_curved_path = true
			self._nav_link_rot = Rotation(self._next_is_nav_link.element:value("rotation"), 0, 0)
			self._curve_path_end_rot = Rotation(mrot_yaw(common_data.rot), 0, 0) --similar to above, but always used

			break
		else
			self:_advance_simplified_path()

			s_path = self._simplified_path

			local is_server = self._sync
			local next_pos = self._nav_point_pos(s_path[2])

			--temporarily reserve (and move if needed) the next pos if another future pos is also available
			--this doesn't apply to precise paths or if the next nav_point is a nav_link. Velocity will affect how long the reservation lasts
			if is_server and not self._action_desc.path_simplified and not self._next_is_nav_link and s_path[3] then
				self:_reserve_nav_pos(next_pos, self._nav_point_pos(s_path[3]), self._nav_point_pos(c_path[#c_path]), vel)
			end

			--a nav_link was somehow skipped, this normally never happens so I'm commenting it out
			--if you crash or have other issues because of this being missing, then you have bigger worries
			--[[if not s_path[1].x then
				s_path[1] = self._nav_point_pos(s_path[1])
			end]]

			local new_c_path = nil
			local init_pos = s_path[1]

			--same precise curved_path check as in the init function
			if vis_state == 1 and math_abs(init_pos.z - next_pos.z) < 100 and mvec3_dis_sq(init_pos, next_pos:with_z(init_pos.z)) > 490000 then
				--define enter direction based on the previous curved path pos to make it 100% accurate
				local enter_dir = init_pos - c_path[#c_path - 1]
				enter_dir = enter_dir:with_z(0):normalized()

				new_c_path = self:_calculate_curved_path(s_path, 1, 1, enter_dir)
			else
				new_c_path = {
					init_pos,
					mvec3_cpy(next_pos)
				}
			end

			local idx_chk = #c_path - 1

			--if the previous curved path had points left in it when the walk was completed, add them to the beginning of the new curved path
			if c_index <= idx_chk then
				local new_curved_path = {}
				local new_idx = idx_chk - c_index + 1

				for i = idx_chk, c_index, -1 do
					new_curved_path[new_idx] = c_path[i]
					new_idx = new_idx - 1
				end

				for i = 1, #new_c_path do
					new_curved_path[#new_curved_path + 1] = new_c_path[i]
				end

				new_c_path = new_curved_path
			end

			self._curve_path = new_c_path
			self._curve_path_index = 1
			c_path = self._curve_path
			c_index = 1

			if is_server then
				self:_send_nav_point(next_pos)
			end

			nav_advanced = true
		end
	end

	if upd_footstep then
		self._footstep_pos = new_pos:with_z(cur_pos.z)
	end

	if self._start_run then
		--currently doing a run_start animation (due to how upd_start_anim works, this means without run turning)

		local cur_vel = self._cur_vel
		local start_max_vel = self._start_max_vel

		if delta_pos then --if already defined at the start of the function
			--anim velocity and walking distance were already calculated based on the animation, so we just need to adjust current velocity
			cur_max_walk_speed = self:_get_current_max_walk_speed(move_side)

			--use maximum start velocity if its higher than the anim velocity
			local cur_anim_vel = vel < start_max_vel and start_max_vel or vel

			--use current maximum walk velocity instead if the result above is higher
			cur_vel = cur_max_walk_speed < cur_anim_vel and cur_max_walk_speed or cur_anim_vel
		else
			--calculate walk distance and velocity again, based on the animation
			delta_pos = common_data.unit:get_animation_delta_position()

			local travel_vec = cur_pos + delta_pos - last_pos
			walk_dis = travel_vec:with_z(0):length()

			local cur_max_vel = vel
			local cur_anim_vel = walk_dis / dt
			--use maximum start velocity if its higher than the anim velocity
			cur_anim_vel = cur_anim_vel < start_max_vel and start_max_vel or cur_anim_vel

			--use current maximum walk velocity instead if the result above is higher
			cur_vel = cur_max_vel < cur_anim_vel and cur_max_vel or cur_anim_vel
		end

		if cur_vel < start_max_vel then
			--current velocity is lower than maximum start velocity
			--adjust to maximum start velocity and adjust walking distance accordingly

			cur_vel = start_max_vel
			walk_dis = cur_vel * dt
		else
			--increase maximum start velocity using currenty velocity
			self._start_max_vel = cur_vel
		end

		self._cur_vel = cur_vel
	else
		local turn_vel, wanted_vel = self._turn_vel, vel

		if turn_vel then --removed the anim lod stage 1 check since all it does is cause inconsistencies between peers
			local next_pos = c_path[c_index + 1]:with_z(cur_pos.z)
			local dis = mvec3_dis_sq(cur_pos, next_pos)

			--when getting really close to the current curve path destination, interpolate velocity depending on the distance and actual curvature
			wanted_vel = dis < 4900 and math_lerp(turn_vel, vel, dis / 4900) or wanted_vel
		end

		local cur_vel = self._cur_vel

		if cur_vel ~= wanted_vel then
			--adjust current velocity and walk distance if needed
			--if current velocity is higher than wanted velocity, adjust it much faster
			local adj_mul = cur_vel < wanted_vel and 1.5 or 4
			local adj = vel * adj_mul * dt
			cur_vel = math_step(cur_vel, wanted_vel, adj)

			walk_dis = cur_vel * dt
			self._cur_vel = cur_vel
		end
	end

	new_pos, new_c_index, complete = self._walk_spline(c_path, last_pos, c_index, walk_dis)

	if complete then
		local nav_link = self._next_is_nav_link

		if nav_link then
			self._end_of_path = true

			if self._sync and alive_g(nav_link.c_class) then
				local delay = nav_link.element:nav_link_delay()

				if delay then
					nav_link.c_class:set_delay_time(t + delay)
				end
			end
		elseif #s_path == 2 then --reached final destination
			self._end_of_path = true
		end
	elseif nav_advanced or new_c_index ~= self._curve_path_index then
		local future_pos = c_path[new_c_index + 2]

		if future_pos then
			local next_pos = c_path[new_c_index + 1]
			local back_pos = c_path[new_c_index]
			local cur_vec = next_pos - back_pos
			cur_vec = cur_vec:with_z(0):normalized()

			local next_vec = future_pos - next_pos
			next_vec = next_vec:with_z(0)

			local future_dis_flat = next_vec:length()
			next_vec = next_vec:normalized()
			local turn_dot = cur_vec:dot(next_vec)

			if not self._attention_pos and self._haste == "walk" and self._stance.name == "ntl" and s_path[3] and turn_dot > -0.7 and turn_dot < 0.7 and future_dis_flat > 80 and common_data.fwd:dot(cur_vec) > 0.97 then
				--do an animation-driven walk turn once close enough to the nav_point if walking in a neutral stance and if the angles allow it
				self._turn_vel = nil
				self._walk_turn = true
			else
				--the more steep the curve is, the lower the turn speed will be
				cur_max_walk_speed = cur_max_walk_speed or self:_get_current_max_walk_speed(move_side)

				local dot_lerp = turn_dot * turn_dot
				local clamped_vel = vel > 100 and 100 or vel
				local turn_vel = math_lerp(clamped_vel, cur_max_walk_speed, dot_lerp)
				self._turn_vel = turn_vel
				self._walk_turn = nil
			end
		else
			--wipe both of these as they could still be used, and that's problematic
			self._turn_vel = nil
			self._walk_turn = nil

			--if the next nav_point is the final destination + the unit can do a run_stop + there's at least 2.1m of distance, start checking once within said distance
			if not self._chk_stop_dis and not self._no_run_stop then
				if self._haste == "run" and #s_path == 2 and mvec3_dis(self._nav_point_pos(s_path[2]):with_z(new_pos.z), new_pos) >= 210 then
					self._chk_stop_dis = 210
				end
			end
		end
	end

	self._curve_path_index = new_c_index
	self._last_pos = mvec3_cpy(new_pos)
end

function CopActionWalk._walk_spline(path, pos, index, walk_dis)
	if walk_dis >= 0 then
		--walking towards the end of the path or not moving (yet)
		while true do
			local cur_path_pos = path[index]
			local next_path_pos = path[index + 1]
			local dir_vec = next_path_pos - cur_path_pos
			dir_vec = dir_vec:with_z(0)

			local dis = dir_vec:length()

			if dis == 0 then --no distance between the two positions, which means next_path_pos is instantly reached
				if index == #path - 1 then
					--end of the path, stop here
					return next_path_pos, index, true
				else
					--loop again and check the future next_path_pos to determine how much distance is advanced towards it
					index = index + 1
				end
			else
				local my_dir_vec = pos - cur_path_pos
				my_dir_vec = my_dir_vec:with_z(0)

				local my_dis = dir_vec:normalized():dot(my_dir_vec) + walk_dis

				if dis <= my_dis then --reached or passed next_path_pos
					if index == #path - 1 then
						--end of the path
						return next_path_pos, index, true
					else
						--loop again
						index = index + 1
					end
				else
					--get a new position by interpolating between the current position and the next, based on walking distance

					local new_pos = my_dir_vec --save performance by using a vector that was already created (if only because it's not gonna be used anywhere else)
					mvec3_lerp(new_pos, cur_path_pos, next_path_pos, my_dis / dis)

					return new_pos, index
				end
			end
		end
	else
		--walking backwards towards the start of the path
		while true do
			local cur_path_pos = path[index + 1]
			local prev_path_pos = path[index]
			local dir_vec = prev_path_pos - cur_path_pos
			dir_vec = dir_vec:with_z(0)

			local dis = dir_vec:length()

			if dis == 0 then --no distance between the two positions, which means prev_path_pos is instantly reached
				if index == 1 then
					--start of the path, stop here (do NOT complete, the unit is going backwards)
					return prev_path_pos, index--, true
				else
					--loop again and check the past prev_path_pos to determine how much distance is backpedaled towards it
					index = index - 1
				end
			else
				local my_dir_vec = pos - cur_path_pos
				my_dir_vec = my_dir_vec:with_z(0)

				local my_dis = dir_vec:normalized():dot(my_dir_vec) - walk_dis

				if dis <= my_dis then --reached or passed prev_path_pos
					if index == 1 then
						--start of the path
						return prev_path_pos, index--, true
					else
						--loop again
						index = index - 1
					end
				else
					--get a new position by interpolating between the current position and the previous, based on walking distance

					local new_pos = my_dir_vec --save performance by using a vector that was already created (if only because it's not gonna be used anywhere else)
					mvec3_lerp(new_pos, cur_path_pos, prev_path_pos, my_dis / dis)

					return new_pos, index
				end
			end
		end
	end
end

function CopActionWalk:_reserve_nav_pos(nav_pos, next_pos, from_pos, vel)
	local step_vec = nav_pos - self._common_data.pos
	step_vec = step_vec:with_z(0) --set the height to 0 to get the proper 2D length towards the position

	local dis = step_vec:length()

	--make it perpendicular to what it was and set its length to 65cm
	--this will be used when attempting to reserve the position in the case it was already reserved, to try to find a nearby valid spot
	mvec3_cross(step_vec, step_vec, math_up)
	mvec3_set_l(step_vec, 65)

	local data = {
		step_mul = 1,
		nr_attempts = 0,
		start_pos = nav_pos,
		fwd_pos = next_pos,
		bwd_pos = from_pos,
		step_vec = step_vec
	}
	local step_clbk = callback(self, CopActionWalk, "_reserve_pos_step_clbk", data)
	local eta = dis / vel --should be more accurate thanks to using 0 height to get the length of the vector, since velocity is determined like that as well
	local res_pos = managers.navigation:reserve_pos(self._timer:time() + eta, 1, nav_pos, step_clbk, 40, self._ext_movement:pos_rsrv_id())

	if res_pos then
		--move the nav_point pos to the reserved pos, in case it had to be moved
		mvec3_set(nav_pos, res_pos.position)

		return true
	end
end

function CopActionWalk:_reserve_pos_step_clbk(data, test_pos)
	data.nr_attempts = data.nr_attempts + 1

	--too many failed attemps, fail reservation
	if data.nr_attempts > 8 then
		return false
	end

	local step_vec = data.step_vec
	local step_mul = data.step_mul
	local start_pos = data.start_pos

	--have to use these to actually modify test_pos for its use in navigationmanager
	mvec3_set(test_pos, step_vec)
	mvec3_mul(test_pos, step_mul)
	mvec3_add(test_pos, start_pos)

	--verify that there are no nav collisions with the starting pos, the previous nav_point and the next nav_point
	local chk_shortcut_func = self._chk_shortcut_pos_to_pos
	local blocked = chk_shortcut_func(start_pos, test_pos)

	if not blocked then
		local fwd_pos = data.fwd_pos
		blocked = chk_shortcut_func(test_pos, fwd_pos)

		if not blocked then
			local bwd_pos = data.bwd_pos
			blocked = chk_shortcut_func(test_pos, bwd_pos)
		end
	end

	--if two collisions happened, stop the process and fail reservation
	--else modify the step multiplier in case this attempt also fails reservation
	if blocked and data.blocked then
		return false
	elseif data.blocked then
		data.step_mul = data.step_mul + math_sign(data.step_mul)
	else
		if blocked then
			data.blocked = true
		end

		if step_mul > 0 then
			data.step_mul = -step_mul
		else
			data.step_mul = -step_mul + 1
		end
	end

	return true
end

function CopActionWalk:_adjust_move_anim(side, speed)
	local ext_anim = self._ext_anim

	--check if the unit is already playing the needed animation
	if ext_anim[speed] and ext_anim["move_" .. side] then
		return
	end

	local enter_t = nil
	local redirect_name = speed .. "_" .. side
	local move_side = ext_anim.move_side or side

	--redirect the animation at a given time if needed and is possible to make a smooth transition
	if move_side then
		if side == move_side or self._matching_walk_anims[side][move_side] then
			local anim_length = self._walk_anim_lengths[ext_anim.pose]
			anim_length = anim_length and anim_length[self._stance.name]
			anim_length = anim_length and anim_length[speed]
			anim_length = anim_length and anim_length[side]

			if anim_length then
				local seg_rel_t = self._machine:segment_relative_time(idstr_base)
				enter_t = seg_rel_t * anim_length
			end
		end
	end

	local could_freeze = ext_anim.can_freeze and ext_anim.upper_body_empty
	local redir_res = self._ext_movement:play_redirect(redirect_name, enter_t)

	--if the unit was freezable before, check again if it's possible as long as the anim lod system allows it
	if could_freeze then
		self._ext_base:chk_freeze_anims()
	end

	return redir_res
end

function CopActionWalk._apply_freefall(pos, vel, gnd_z, dt)
	local vel_z = vel - dt * 981
	local new_z = pos.z + vel_z * dt

	--if ground ray height is sent here, ensure gravity won't send the unit below ground by clamping the new height with it
	new_z = gnd_z and new_z < gnd_z and gnd_z or new_z

	--can't use with_z method, else the height of the vector sent here won't be modified
	mvec3_set_z(pos, new_z)

	return vel_z
end

function CopActionWalk:get_walk_to_pos()
	local nav_point = self._simplified_path and self._simplified_path[2] or self._nav_path and self._nav_path[2]

	--in case this function gets used on clients, as the unit might not have a destination position and is waiting for the host
	if not nav_point then
		return
	end

	return self._nav_point_pos(nav_point)
end

function CopActionWalk:_upd_wait(t)
	local dt = nil
	local vis_state = self._ext_base:lod_stage() or 4

	--skip updating for a few frames depending on the animation lod stage set on the unit
	--this will save some performance without any noticeable effects
	if vis_state == 1 then
		dt = t - self._last_upd_t
		self._last_upd_t = self._timer:time()
	elseif self._skipped_frames < vis_state then
		self._skipped_frames = self._skipped_frames + 1

		return
	else
		self._skipped_frames = 1
		dt = t - self._last_upd_t
		self._last_upd_t = self._timer:time()
	end

	if self._ext_anim.move then
		self:_stop_walk()
	end

	--unit is waiting for the host to send the next nav_point
	if self._end_of_curved_path and self._persistent then
		local common_data = self._common_data
		local att_pos = self._attention_pos
		local face_fwd = nil

		if att_pos then
			face_fwd = att_pos - common_data.pos
			face_fwd = face_fwd:with_z(0):normalized()
		else
			local c_path_end_rot = self._curve_path_end_rot

			face_fwd = c_path_end_rot and c_path_end_rot:y()
		end

		--rotate the unit towards attentions so that they can still shoot them, or towards the curve path end rotation
		--the unit would otherwise stay locked facing the one way and be unable to turn or spin, even if it might be able for the host or other clients
		if face_fwd then
			local move_dir_norm = tmp_vec3
			mvec3_set(move_dir_norm, common_data.fwd)

			local face_right = face_fwd:cross(math_up):normalized()
			local right_dot = move_dir_norm:dot(face_right)
			local abs_right_dot = math_abs(right_dot)
			local fwd_dot = move_dir_norm:dot(face_fwd)
			local abs_fwd_dot = math_abs(fwd_dot)
			local wanted_walk_dir = nil

			if abs_right_dot < abs_fwd_dot then
				if fwd_dot > 0 then
					wanted_walk_dir = "fwd"
				else
					wanted_walk_dir = "bwd"
				end
			elseif right_dot > 0 then
				wanted_walk_dir = "r"
			else
				wanted_walk_dir = "l"
			end

			local new_rot = temp_rot1
			local wanted_u_fwd = move_dir_norm:rotate_with(self._walk_side_rot[wanted_walk_dir])
			mrot_lookat(new_rot, wanted_u_fwd, math_up)

			local lerp_modifier = self._shield_turning and 0.15 or 0.3
			local delta_lerp = dt * 5 * lerp_modifier
			delta_lerp = delta_lerp > 1 and 1 or delta_lerp
			new_rot = common_data.rot:slerp(new_rot, delta_lerp)

			self._ext_movement:set_rotation(new_rot)
		end

		return
	end

	--a nav_point was synced (check above didn't stop the function) or the action expired on the host's end

	local s_path = self._simplified_path
	local nav_point_pos_func = self._nav_point_pos
	local next_nav_point = s_path[2]

	if not next_nav_point.x then
		self._next_is_nav_link = next_nav_point
	end

	s_path[2] = next_nav_point

	local next_pos = nav_point_pos_func(next_nav_point)
	self:_chk_start_anim(next_pos)

	if self._start_run then
		self:_set_updator("_upd_start_anim_first_frame")
	else
		self:_set_updator(nil)
	end

	self._curve_path_index = 1
	self._cur_vel = 0
	self._curve_path = {
		mvec3_cpy(nav_point_pos_func(s_path[1])),
		mvec3_cpy(next_pos)
	}
	self._simplified_path = s_path
end

function CopActionWalk:_upd_stop_anim_first_frame(t)
	local stop_side = self._stop_anim_side
	local redir_name = "run_stop_" .. stop_side
	local redir_res = self._ext_movement:play_redirect(redir_name)

	if not redir_res then
		return
	end

	self._chk_stop_dis = nil

	local ext_anim = self._ext_anim
	local pose = ext_anim.pose

	--get a speed multiplier based on the stop direction and maximum allowed velocity
	local speed_mul = self:_get_current_max_walk_speed(stop_side) / self._walk_anim_velocities[pose][self._stance.name][self._haste][stop_side]
	self._machine:set_speed(redir_res, speed_mul)

	self._stop_anim_init_pos = mvec3_cpy(self._last_pos)

	local s_path = self._simplified_path
	self._stop_anim_end_pos = mvec3_cpy(self._nav_point_pos(s_path[#s_path]))

	self:_set_updator("_upd_stop_anim")

	--define the displacement function to move the unit from the init pos to the end pos based on the progress of the animation
	if pose ~= "crouch" then
		if stop_side == "fwd" then
			function self._stop_anim_displacement_f(p1, p2, t)
				local t_clamp = (math_clamp(t, 0, 0.6) / 0.6)^0.8

				return math_lerp(p1, p2, t_clamp)
			end
		elseif stop_side == "bwd" then
			function self._stop_anim_displacement_f(p1, p2, t)
				local low = 0.97
				local p_1_5 = 0.9
				local t_clamp = math_clamp(t, 0, 0.8) / 0.8

				if p_1_5 > t_clamp then
					t_clamp = low * (1 - (p_1_5 - t_clamp) / p_1_5)
				else
					t_clamp = low + (1 - low) * (t_clamp - p_1_5) / (1 - p_1_5)
				end

				return math_lerp(p1, p2, t_clamp)
			end
		elseif stop_side == "l" then
			function self._stop_anim_displacement_f(p1, p2, t)
				local p_1_5 = 0.6
				local low = 0.8
				local t_clamp = math_clamp(t, 0, 0.75) / 0.75

				if p_1_5 > t_clamp then
					t_clamp = low * t_clamp / p_1_5
				else
					t_clamp = low + (1 - low) * (t_clamp - p_1_5) / (1 - p_1_5)
				end

				return math_lerp(p1, p2, t_clamp)
			end
		else
			function self._stop_anim_displacement_f(p1, p2, t)
				local low = 0.9
				local p_1_5 = 0.85
				local t_clamp = math_clamp(t, 0, 0.8) / 0.8

				if p_1_5 > t_clamp then
					t_clamp = low * (1 - (p_1_5 - t_clamp) / p_1_5)
				else
					t_clamp = low + (1 - low) * (t_clamp - p_1_5) / (1 - p_1_5)
				end

				return math_lerp(p1, p2, t_clamp)
			end
		end
	elseif stop_side == "fwd" or stop_side == "bwd" then
		function self._stop_anim_displacement_f(p1, p2, t)
			local t_clamp = math_clamp(t, 0, 0.4) / 0.4
			t_clamp = t_clamp^0.85

			return math_lerp(p1, p2, t_clamp)
		end
	elseif stop_side == "l" then
		function self._stop_anim_displacement_f(p1, p2, t)
			local t_clamp = math_clamp(t, 0, 0.3) / 0.3
			t_clamp = t_clamp^0.85

			return math_lerp(p1, p2, t_clamp)
		end
	else
		function self._stop_anim_displacement_f(p1, p2, t)
			local t_clamp = math_clamp(t, 0, 0.6) / 0.6
			t_clamp = t_clamp^0.85

			return math_lerp(p1, p2, t_clamp)
		end
	end

	self._ext_base:chk_freeze_anims()
	self:update(t)
end

function CopActionWalk:_upd_stop_anim(t)
	local ext_mov = self._ext_movement
	local dt = self._timer:delta_time()
	local delta_lerp = dt * 5

	local common_data = self._common_data
	local att_pos = not self._nav_link_rot and not self._end_rot and self._attention_pos
	local face_fwd = nil

	--keep rotating towards attentions as usual, else rotate towards stop_anim_fwd
	if att_pos then
		face_fwd = att_pos - common_data.pos
		face_fwd = face_fwd:with_z(0):normalized()

		local att_lerp_modifier = self._shield_turning and 0.15 or 0.3
		delta_lerp = delta_lerp * att_lerp_modifier
	else
		face_fwd = self._stop_anim_fwd
	end

	delta_lerp = delta_lerp > 1 and 1 or delta_lerp

	local new_rot = temp_rot1
	mrot_lookat(new_rot, face_fwd, math_up)

	new_rot = common_data.rot:slerp(new_rot, delta_lerp)

	ext_mov:set_rotation(new_rot)

	if not self._ext_anim.run_stop then
		if self._root_blend_disabled then
			ext_mov:set_root_blend(true)

			self._root_blend_disabled = nil
		end

		local update_immediately = nil

		if self._next_is_nav_link then
			update_immediately = true

			--nav_links always get to immediately start updating on the same frame
			self:_set_updator("_upd_nav_link_first_frame")
		elseif #self._simplified_path > 2 then
			update_immediately = self._ext_base:lod_stage() == 1

			self:_set_updator(nil)
		elseif self._persistent then
			self:_set_updator("_upd_wait")
		else
			self._expired = true

			local end_rot = self._end_rot

			if end_rot then
				ext_mov:set_rotation(end_rot)
			end
		end

		self._last_pos = mvec3_cpy(self._stop_anim_end_pos)
		self._stop_anim_displacement_f = nil
		self._stop_anim_end_pos = nil
		self._stop_anim_fwd = nil
		self._stop_anim_init_pos = nil
		self._stop_anim_side = nil
		self._stop_dis = nil

		self:_set_new_pos(dt)

		if update_immediately then
			self:update(t)
		end

		return
	end

	--move the unit towards the stop position using the displacement function and animation progress
	local seg_rel_t = self._machine:segment_relative_time(idstr_base)
	self._last_pos = self._stop_anim_displacement_f(self._stop_anim_init_pos, self._stop_anim_end_pos, seg_rel_t)

	self:_set_new_pos(dt)
end

--infinitely faster to use these 2 boolean lookup tables rather than 10 separate compare statements
local soft_anim_updators = {
	_upd_wait = true,
	_upd_start_anim_first_frame = true,
	_upd_start_anim = true
}

local hard_anim_updators = {
	_upd_stop_anim_first_frame = true,
	_upd_stop_anim = true,
	_upd_nav_link_first_frame = true,
	_upd_nav_link_blend_to_idle = true,
	_upd_nav_link = true,
	_upd_walk_turn_first_frame = true,
	_upd_walk_turn = true
}

function CopActionWalk:stop()
	local nav_point_pos_func = nil
	local s_path = self._simplified_path

	--if self._simplified_path doesn't exist, it means the action started successfully
	--but the unit is waiting for idle_full_blend so it didn't fully start it yet
	s_path = s_path or {}

	local s_path = self._simplified_path
	local last_nav_point = s_path[#s_path]

	--the last nav_point is a nav_link. Normally this shouldn't be the case
	--as the host will sync a position before the stop if the action didn't expire properly
	--or will also sync the next nav_point after the nav_link as soon as the unit finishes using it
	--if this ends up being the case anyway, use the initial position of the nav_link as the final position
	--[[if last_nav_point and not last_nav_point.x then
		nav_point_pos_func = self._nav_point_pos

		s_path[#s_path] = mvec3_cpy(nav_point_pos_func(last_nav_point))
	end]]

	local end_pos = s_path[#s_path]
	self._persistent = false

	local is_initialized = self._init_called --the action has fully started

	if is_initialized then
		if soft_anim_updators[self._updator_name] then
			self._end_of_curved_path = nil
			self._end_of_path = nil
		elseif not self._next_is_nav_link then
			self._end_of_curved_path = nil
		end

		--attempt to shortcut to the end position if the path has more than two nav_points + unit isn't playing an animation that dictates movement
		if s_path[3] and not hard_anim_updators[self._updator_name] and math_abs(self._common_data.pos.z - end_pos.z) < 100 then
			local ray_params = {
				tracker_from = self._common_data.nav_tracker,
				pos_to = end_pos
			}

			if not managers.navigation:raycast(ray_params) then
				self._next_is_nav_link = nil
				self._end_of_curved_path = nil
				self._end_of_path = nil
				self._walk_turn = nil
				self._curve_path_index = 1
				self._curve_path = {
					mvec3_cpy(self._common_data.pos),
					mvec3_cpy(end_pos)
				}
				s_path = {
					mvec3_cpy(self._common_data.pos),
					mvec3_cpy(end_pos)
				}
			end
		end
	end

	--attempt to shortcut to the end pos from subsequent nav_points if the path has more than two
	if s_path[3] then
		local chk_shortcut_func = self._chk_shortcut_pos_to_pos
		nav_point_pos_func = nav_point_pos_func or self._nav_point_pos

		for i_nav_point = 2, #s_path - 1 do
			local point_from = s_path[i_nav_point]
			local blocked = not point_from.x or math_abs(point_from.z - end_pos.z) >= 100 or chk_shortcut_func(point_from, end_pos)

			if not blocked then
				local new_s_path = {}

				for i = 1, i_nav_point do
					new_s_path[#new_s_path + 1] = s_path[i]
				end

				new_s_path[#new_s_path + 1] = end_pos

				s_path = new_s_path

				break
			end
		end
	end

	if is_initialized and not self._chk_stop_dis and not self._no_run_stop and self._haste == "run" and #s_path == 2 then
		local first_nav_point = s_path[1]

		if first_nav_point.x then
			nav_point_pos_func = nav_point_pos_func or self._nav_point_pos

			if mvec3_dis(first_nav_point, nav_point_pos_func(s_path[2]):with_z(first_nav_point.z)) >= 210 then
				self._chk_stop_dis = 210
			end
		end
	end

	self._simplified_path = s_path
end

function CopActionWalk:append_nav_point(nav_point)
	self._chk_stop_dis = nil

	if not nav_point.x then
		function nav_point.element.value(element, name)
			return element[name]
		end

		function nav_point.element.nav_link_wants_align_pos(element)
			return element.from_idle
		end
	end

	--local line2 = Draw:brush(Color.red:with_alpha(0.5), 5)
	--line2:sphere(self._nav_point_pos(nav_point), 30)

	local s_path = self._simplified_path

	s_path = s_path or {}
	s_path[#s_path + 1] = nav_point

	local is_initialized = self._init_called

	if is_initialized and #s_path == 2 then
		if not nav_point.x then
			self._next_is_nav_link = nav_point
		end

		if not self._no_run_stop and self._haste == "run" then
			local first_nav_point = s_path[1]

			if first_nav_point.x and mvec3_dis(first_nav_point, self._nav_point_pos(nav_point):with_z(first_nav_point.z)) >= 210 then
				self._chk_stop_dis = 210
			end
		end
	end

	self._simplified_path = s_path

	if is_initialized then
		if soft_anim_updators[self._updator_name] then
			self._end_of_curved_path = nil
			self._end_of_path = nil
		elseif not self._next_is_nav_link then
			self._end_of_curved_path = nil
		end
	end
end

function CopActionWalk:_play_nav_link_anim(t)
	local action_desc = self._action_desc
	local common_data = self._common_data
	local ext_mov = self._ext_movement
	local drop_in_t = action_desc.start_anim_time
	local nav_link = self._next_is_nav_link
	local anim = drop_in_t and self._machine:index_to_state_name(action_desc.start_anim_idx) or nav_link.element:value("so_action")

	local new_rot = temp_rot1
	mrot_set(new_rot, nav_link.element:value("rotation"), 0, 0)
	ext_mov:set_rotation(new_rot)

	--drop-ins set _last_pos to the current position of the unit, without moving it
	--otherwise, the start position of the nav_link is used and the unit is moved there
	if drop_in_t then
		self._last_pos = mvec3_cpy(common_data.pos)
	else
		self._last_pos = mvec3_cpy(nav_link.element:value("position"))
		self:_set_new_pos(self._timer:delta_time())
	end

	self._nav_link = nav_link
	self._next_is_nav_link = nil
	self._end_of_curved_path = nil
	self._end_of_path = nil
	self._curve_path_end_rot = nil
	self._nav_link_rot = nil

	--the path is preemptively advanced for drop-ins
	if not drop_in_t then
		self:_advance_simplified_path()
	end

	local redir_res = nil

	--drop ins play a state directly rather than a redirect, using the synced index
	if drop_in_t then
		redir_res = ext_mov:play_state_idstr(anim, drop_in_t)
	else
		redir_res = ext_mov:play_redirect(anim)
	end

	if redir_res then
		self._old_blocks = self._blocks

		self:_set_blocks(self._anim_block_presets.block_all)

		--normally team-ai only (and also server-only)
		if self._nav_link_invul and not self._nav_link_invul_on then
			common_data.ext_damage:set_invulnerable(true)

			self._nav_link_invul_on = true
		end

		--the nav_link is only synced if it went through sucessfully
		--I also removed any code related to syncing a nav_link when the action is started
		--the reason for this is that it defeats the purpose of how nav_points are synced in the first place
		--the unit might go through the nav_link for some clients, but not for the host (which will force the unit to walk back, including through geometry)
		if self._sync then
			self:_send_nav_point(nav_link)
		end

		--set the height of the unit for drop-ins with the synced value, since the spawning system might move them up or down
		if drop_in_t then
			ext_mov:set_position(common_data.pos:with_z(action_desc.pos_z))

			self._last_pos = mvec3_cpy(common_data.pos)
		end

		--let the nav_link animation fully dictate the new position and rotation of the unit
		common_data.unit:set_driving("animation")

		self._changed_driving = true

		self:_set_updator("_upd_nav_link")

		--interrupt upper_body actions
		--if self._blocks.action then
			ext_mov:action_request({
				non_persistent = true,
				client_interrupt = true,
				body_part = 3,
				type = "idle"
			})
		--end
	else
		--nav_link redirect somehow failed, make the unit path towards its end position (or skip ahead if this is a client) and proceed with the rest of the path

		local s_path = self._simplified_path
		s_path[1] = mvec3_cpy(common_data.pos)

		if self._sync then
			local nav_link = self._nav_link

			if alive_g(nav_link.c_class) then
				if nav_link.element:nav_link_delay() then
					nav_link.c_class:set_delay_time(0)
				end

				local end_pos = nav_link.c_class:end_position()

				if not s_path[2] then
					s_path[2] = mvec3_cpy(end_pos)
				else
					local new_path_table = {
						s_path[1],
						mvec3_cpy(end_pos)
					}

					for idx = 2, #s_path do
						new_path_table[#new_path_table + 1] = s_path[idx]
					end

					s_path = new_path_table
					self._simplified_path = s_path
				end
			end

			if s_path[2] then
				self:_send_nav_point(s_path[2])
			end
		end

		self._cur_vel = 0
		self._nav_link = nil

		local next_point = s_path[2]

		if next_point then
			local init_pos = s_path[1]
			local next_point_pos = self._nav_point_pos(next_point)

			--just do a straight line, no need to bother with a smooth curved path since it will 100% fail due to height difference or nav collisions
			self._curve_path = {
				init_pos,
				mvec3_cpy(next_point_pos)
			}

			self._chk_stop_dis = nil

			if not self._no_run_stop and self._haste == "run" and #s_path == 2 and mvec3_dis(init_pos, next_point_pos:with_z(init_pos.z)) >= 210 then
				self._chk_stop_dis = 210
			end

			self._curve_path_index = 1

			self:_set_updator(nil)
			self:update(t)
		elseif self._persistent then
			self:_set_updator("_upd_wait")
		else
			self:_set_updator(nil)

			self._expired = true

			local end_rot = self._end_rot

			if end_rot then
				ext_mov:set_rotation(end_rot)
			end
		end
	end
end

function CopActionWalk:_upd_nav_link(t)
	local ext_anim = self._ext_anim

	--animation isn't done yet, set position and rotation mutables to match how the animation has moved and rotated the unit
	if ext_anim.act and not ext_anim.walk then
		local unit = self._unit
		local new_pos = unit:position()
		self._last_pos = new_pos

		local ext_mov = self._ext_movement

		ext_mov:set_m_pos(new_pos)
		ext_mov:set_m_rot(unit:rotation())

		return
	end

	local is_server = self._sync
	local common_data = self._common_data
	local ext_mov = self._ext_movement
	local nav_point_pos_func = self._nav_point_pos

	if self._nav_link_invul_on then
		self._nav_link_invul_on = nil

		common_data.ext_damage:set_invulnerable(false)
	end

	common_data.unit:set_driving("script")
	self._changed_driving = nil

	self:_set_blocks(self._old_blocks)

	self._old_blocks = nil

	self._cur_vel = 0
	self._last_vel_z = 0

	local s_path = self._simplified_path
	local next_nav_point = s_path[2]
	local skip_advanced_calculations = nil

	if is_server then
		local nav_link = self._nav_link

		if alive_g(nav_link.c_class) then
			if nav_link.element:nav_link_delay() then
				nav_link.c_class:set_delay_time(0)
			end

			next_nav_point = s_path[2]

			local end_pos = nav_link.c_class:end_position()
			local after_nav_link_pos = next_nav_point and nav_point_pos_func(next_nav_point) or end_pos

			local ray_params = {
				tracker_from = common_data.nav_tracker,
				pos_to = after_nav_link_pos
			}
			local res = managers.navigation:raycast(ray_params)

			--there's a nav collision between the current pos of the unit and the next destination (or the end position of the nav_link if there isn't one)
			--add the end position of the nav_link to the path as the next destination before continuining with the path, this will ensure it remains inside the nav mesh
			if res then
				if not next_nav_point then
					s_path[2] = mvec3_cpy(end_pos)
				else
					local new_s_path = {
						s_path[1],
						mvec3_cpy(end_pos)
					}

					for idx = 2, #s_path do
						new_s_path[#new_s_path + 1] = s_path[idx]
					end

					s_path = new_s_path
				end

				skip_advanced_calculations = true
				self._next_is_nav_link = nil

				next_nav_point = s_path[2]
			end
		end
	end

	self._nav_link = nil

	--this always needs to be called after setting self._nav_link to nil, else stand/crouch actions won't go through at all
	self:_chk_correct_pose()

	if next_nav_point then --still has another nav_point to go to
		s_path[1] = mvec3_cpy(common_data.pos)

		if is_server then
			self:_send_nav_point(next_nav_point)
		elseif not self._persistent then --action expired for the host while the nav_link was still going here
			if s_path[3] then --attempt to shortcut to the end pos if the path still has more than two nav_points
				local chk_shortcut_func = self._chk_shortcut_pos_to_pos
				local last_nav_point_pos = nav_point_pos_func(s_path[#s_path])
				local i_start = common_data.nav_tracker:lost() and 2 or 1 --start with the current position if the unit didn't end up outside the nav_field

				for i_nav_point = i_start, #s_path - 1 do
					local point_from = s_path[i_nav_point]
					local blocked = not point_from.x or math_abs(point_from.z - last_nav_point_pos.z) >= 100 or chk_shortcut_func(point_from, last_nav_point_pos)

					if not blocked then
						local new_s_path = {}

						for i = 1, i_nav_point do
							new_s_path[#new_s_path + 1] = s_path[i]
						end

						new_s_path[#new_s_path + 1] = last_nav_point_pos

						s_path = new_s_path

						break
					end
				end
			end
		end

		local init_pos = s_path[1]
		local next_point_pos = nav_point_pos_func(next_nav_point)

		if skip_advanced_calculations then
			self._curve_path = {
				init_pos,
				mvec3_cpy(next_point_pos)
			}
		elseif self._ext_base:lod_stage() == 1 and math_abs(init_pos.z - next_point_pos.z) < 100 and mvec3_dis_sq(init_pos, next_point_pos:with_z(init_pos.z)) > 490000 then
			self._curve_path = self:_calculate_curved_path(s_path, 1, 1, common_data.fwd)
		else
			self._curve_path = {
				init_pos,
				mvec3_cpy(next_point_pos)
			}
		end

		self._chk_stop_dis = nil

		if not skip_advanced_calculations and not self._no_run_stop and self._haste == "run" and #s_path == 2 and mvec3_dis(init_pos, next_point_pos:with_z(init_pos.z)) >= 210 then
			self._chk_stop_dis = 210
		end

		self._simplified_path = s_path
		self._curve_path_index = 1

		if skip_advanced_calculations then
			self:_set_updator(nil)
		else
			self:_chk_start_anim(next_point_pos)

			if self._start_run then
				self:_set_updator("_upd_start_anim_first_frame")
			else
				self:_set_updator(nil)
			end
		end

		self:update(t)
	elseif self._persistent then
		self._end_of_curved_path = true

		self._simplified_path[1] = mvec3_cpy(common_data.pos)

		self:_set_updator("_upd_wait")
	else
		self._end_of_curved_path = true

		self._simplified_path[1] = mvec3_cpy(common_data.pos)

		self:_set_updator(nil)

		self._expired = true

		local end_rot = self._end_rot

		if end_rot then
			ext_mov:set_rotation(end_rot)
		end
	end
end

function CopActionWalk:_upd_walk_turn_first_frame(t)
	local c_path = self._curve_path
	local c_index = self._curve_path_index
	local pos1 = c_path[c_index + 1]
	local pos2 = c_path[c_index + 2]

	if not pos1 or not pos2 then
		self._walk_turn = nil

		self:_set_updator(nil)
		self:update(t)

		return
	end

	local common_data = self._common_data
	local machine = self._machine

	local curve_vec = pos2 - pos1
	curve_vec = curve_vec:with_z(0):normalized()

	--store the initial and wanted angle
	local walk_turn_start_yaw = common_data.rot:yaw()
	local walk_turn_angle = curve_vec:to_polar_with_reference(common_data.fwd, math_up).spin

	--get the turning side and foot to determine the animation
	local right_dot = common_data.right:dot(curve_vec)
	local side = right_dot > 0 and "r" or "l"
	local seg_rel_t = machine:segment_relative_time(idstr_base)
	local left_foot = seg_rel_t < 0.25 or seg_rel_t > 0.75
	local foot = left_foot and "l" or "r"
	local anim = "walk_turn_" .. side .. "_" .. foot .. "f"
	local redir_res = self._ext_movement:play_redirect(anim)

	if redir_res then
		local cur_vel = self:_get_current_max_walk_speed("fwd")
		self._cur_vel = cur_vel

		local speed_mul = cur_vel / self._walk_anim_velocities.stand.ntl.walk.fwd
		machine:set_speed(redir_res, speed_mul)

		self._walk_turn_start_t = machine:segment_relative_time(idstr_base)
		self._walk_turn_start_yaw = walk_turn_start_yaw
		self._walk_turn_angle = walk_turn_angle

		self._curve_path_index = c_index + 1

		if not left_foot then
			self._walk_turn_blend_to_middle = true
		end

		self:_set_updator("_upd_walk_turn")
		self:update(t)
	else
		self._walk_turn = nil

		self:_set_updator(nil)
		self:update(t)
	end
end

function CopActionWalk:_upd_walk_turn(t)
	local common_data = self._common_data

	--the animation is still going
	if self._ext_anim.walk_turn then
		local seg_rel_t = self._machine:segment_relative_time(idstr_base)
		local delta_pos = common_data.unit:get_animation_delta_position()
		local new_pos = common_data.pos + delta_pos
		local ray_params = {
			allow_entry = true,
			trace = true,
			tracker_from = common_data.nav_tracker,
			pos_to = new_pos
		}
		local collision = managers.navigation:raycast(ray_params)

		--clamp position of the unit if it collides with a nav obstruction
		if collision then
			new_pos = ray_params.trace[1]
		end

		self._last_pos = new_pos

		self:_set_new_pos(self._timer:delta_time())

		--rotate unit towards the wanted turn direction based on animation progress and start time
		local seg_rel_t_clamp = math_clamp((seg_rel_t - self._walk_turn_start_t) / 0.77, 0, 1)
		local prog_angle = self._walk_turn_angle * seg_rel_t_clamp
		local new_yaw = self._walk_turn_start_yaw + prog_angle
		local new_rot = temp_rot1
		mrot_set(new_rot, new_yaw, 0, 0)

		self._ext_movement:set_rotation(new_rot)

		return
	end

	if self._walk_turn_blend_to_middle then
		self._machine:set_animation_time_all_segments(0.5)
	end

	local chk_shortcut_func = self._chk_shortcut_pos_to_pos
	local current_pos = common_data.pos
	local c_path = self._curve_path
	local c_index = self._curve_path_index
	local c_shortcut_chk_index = c_index + 2

	--if there's only one nav_point left in the curve path table, get back into the line of the path to avoid potential clipping issues
	if not c_path[c_shortcut_chk_index] then
		local old_pos = c_path[c_index]
		local next_pos = c_path[c_index + 1]

		local vec_from_cur = next_pos - current_pos
		local length_from_cur = vec_from_cur:with_z(0):length() * 0.5
		local vec_from_old = next_pos - old_pos
		local length_from_old = vec_from_old:with_z(0):length()

		--get an interpolated test position based on half of the distance between the current pos and the next pos
		mvec3_lerp(vec_from_old, old_pos, next_pos, length_from_cur / length_from_old)

		--if the path to this test position is obstructed, try again with less distance
		if chk_shortcut_func(current_pos, vec_from_old) then
			--local line1 = Draw:brush(Color.red:with_alpha(0.5), 3)
			--line1:cylinder(current_pos, vec_from_old, 15)

			length_from_cur = vec_from_cur:with_z(0):length() * 0.75

			mvec3_lerp(vec_from_old, old_pos, next_pos, length_from_cur / length_from_old)

			--if the path is obstructed again, just use the distance between current pos and old pos
			--this might make the unit do a sudden movement to get back into the path, but will almost ensure no clippling issues occur due to the animation
			if chk_shortcut_func(current_pos, vec_from_old) then
				--line1:cylinder(current_pos, vec_from_old, 15)

				vec_from_cur = current_pos - old_pos
				length_from_cur = vec_from_cur:with_z(0):length()

				mvec3_lerp(vec_from_old, old_pos, next_pos, length_from_cur / length_from_old)
			end
		end

		c_path[c_index] = mvec3_cpy(current_pos)
		c_path[c_index + 1] = vec_from_old
		c_path[c_shortcut_chk_index] = next_pos

		--[[local line1 = Draw:brush(Color.green:with_alpha(0.5), 3)
		line1:cylinder(current_pos, vec_from_old, 15)

		local line2 = Draw:brush(Color.blue:with_alpha(0.5), 3)
		line2:cylinder(old_pos, next_pos, 15)

		local line3 = Draw:brush(Color.yellow:with_alpha(0.5), 3)
		line3:cylinder(vec_from_old, next_pos, 15)]]
	else
		local old_pos = c_path[c_index]
		c_path[c_index] = mvec3_cpy(current_pos)

		local copied_cur_pos = mvec3_cpy(current_pos)
		local vec_from_old = current_pos - old_pos
		vec_from_old = vec_from_old:with_z(0):normalized()

		while true do
			local vec_to_next = c_path[2] - current_pos
			vec_to_next = vec_to_next:with_z(0):normalized()

			if vec_to_next:dot(vec_from_old) < 0 and not chk_shortcut_func(current_pos, c_path[c_shortcut_chk_index]) then
				local new_curved_path = {}

				for idx = 1, c_index - 1 do
					new_curved_path[#new_curved_path + 1] = c_path[idx]
				end

				new_curved_path[#new_curved_path + 1] = copied_cur_pos

				for idx = c_shortcut_chk_index, #c_path do
					new_curved_path[#new_curved_path + 1] = c_path[idx]
				end

				c_path = new_curved_path

				if not c_path[c_shortcut_chk_index] then
					break
				end
			else
				break
			end
		end
	end

	self._last_pos = mvec3_cpy(current_pos)
	self._curve_path = c_path
	self._walk_turn = nil
	self._walk_turn_blend_to_middle = nil
	self._walk_turn_angle = nil
	self._walk_turn_start_t = nil
	self._walk_turn_start_yaw = nil

	self:_set_updator(nil)
	self:update(t)
end

function CopActionWalk:_send_nav_point(nav_point)
	if nav_point.x then
		self._ext_network:send("action_walk_nav_point", mvec3_cpy(nav_point))

		return
	end

	local element = nav_point.element
	local anim_index = CopActionAct._get_act_index(CopActionAct, element:value("so_action"))
	local sync_yaw = element:value("rotation")

	if sync_yaw < 0 then
		sync_yaw = 360 + sync_yaw
	end

	sync_yaw = math_ceil(255 * sync_yaw / 360)

	if sync_yaw == 0 then
		sync_yaw = 255
	end

	self._ext_network:send("action_walk_nav_link", mvec3_cpy(element:value("position")), sync_yaw, anim_index, element:nav_link_wants_align_pos() and true or false)
end

function CopActionWalk:_set_updator(name)
	local prev_updator_name = self._updator_name
	self.update = self[name]
	self._updator_name = name

	--reset update timer if using the default or waiting update functions
	if not name then
		if prev_updator_name ~= "_upd_wait" then
			self._last_upd_t = self._timer:time() - 0.001
			self._skipped_frames = 1
		end
	elseif name == "_upd_wait" then
		if prev_updator_name then
			self._last_upd_t = self._timer:time() - 0.001
			self._skipped_frames = 1
		end
	end
end

function CopActionWalk:on_nav_link_unregistered(element_id)
	local next_is_nav_link = self._next_is_nav_link

	--check if the next nav_point of the unit is a nav_link
	if next_is_nav_link and next_is_nav_link.element._id == element_id then
		self._has_dead_nav_link = true

		self._ext_movement:action_request({
			body_part = 2,
			type = "idle"
		})

		return
	end

	local path = self._simplified_path or self._nav_path

	--check the entire path
	for i = 1, #path do
		local nav_point = path[i]

		if not nav_point.x then
			local nav_point_id = nav_point.element and nav_point.element:id() or nav_point:script_data().element:id()

			if nav_point_id == element_id then
				self._has_dead_nav_link = true

				self._ext_movement:action_request({
					body_part = 2,
					type = "idle"
				})

				break
			end
		end
	end
end

function CopActionWalk:_advance_simplified_path()
	local s_path = self._simplified_path
	local new_path_table = {}

	for idx = 2, #s_path do
		new_path_table[#new_path_table + 1] = s_path[idx]
	end

	s_path = new_path_table

	if s_path[2] and not s_path[2].x then
		self._next_is_nav_link = s_path[2]
	end

	self._simplified_path = s_path
	self._host_stop_pos_ahead = false
end

function CopActionWalk:_husk_needs_speedup()
	local queued_actions = self._ext_movement._queued_actions

	--unit has already started another action on the server side
	--but is temporarily blocked here, need to catch up immediately
	if queued_actions and next_g(queued_actions) then
		return true
	end

	local s_path = self._simplified_path

	--unit still has to go through 3 or more nav_points that were synced
	if s_path[3] then
		local dis_error_total = 0
		local nav_point_pos_func = self._nav_point_pos
		local prev_pos = self._common_data.pos

		--get the sum of the distance between the one the unit is moving to + the rest of them
		for i = 2, #s_path do
			local next_pos = nav_point_pos_func(s_path[i]):with_z(prev_pos.z)
			dis_error_total = dis_error_total + mvec3_dis_sq(prev_pos, next_pos)
			prev_pos = next_pos
		end

		--total distance exceeds 9 square meters, speed up until this is no longer true
		if dis_error_total > 90000 then
			return true
		end
	end
end

function CopActionWalk:_chk_correct_pose()
	local common_data = self._common_data
	local pose = self._ext_anim.pose

	if pose == "crouch" and common_data.is_cool then
		self._ext_movement:action_request({
			body_part = 4,
			type = "stand",
			no_sync = true
		})

		return
	end

	local allowed_poses = common_data.char_tweak.allowed_poses

	if not allowed_poses then
		return
	end

	if pose == "crouch" and not allowed_poses.crouch then
		self._ext_movement:action_request({
			body_part = 4,
			type = "stand",
			no_sync = true
		})
	elseif pose == "stand" and not allowed_poses.stand then
		self._ext_movement:action_request({
			body_part = 4,
			type = "crouch",
			no_sync = true
		})
	end
end
