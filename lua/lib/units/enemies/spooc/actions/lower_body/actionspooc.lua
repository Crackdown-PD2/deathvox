local mvec3_z = mvector3.z
local mvec3_set = mvector3.set
local mvec3_norm = mvector3.normalize
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_len_sq = mvector3.length_sq
local mvec3_set_l = mvector3.set_length
local mvec3_lerp = mvector3.lerp
local mvec3_cpy = mvector3.copy
local mvec3_set_stat = mvector3.set_static
local mvec3_negate = mvector3.negate

local mrot_lookat = mrotation.set_look_at
local mrot_set = mrotation.set_yaw_pitch_roll
local temp_rot1 = Rotation()

local math_abs = math.abs
local math_lerp = math.lerp
local math_random = math.random
local math_clamp = math.clamp
local math_up = math.UP
local math_down = math.DOWN
local math_step = math.step
local math_bezier = math.bezier
local bezier_curve = {
	0,
	0,
	1,
	1
}

local type_g = type
local tonumber_g = tonumber
local next_g = next
local pairs_g = pairs
local alive_g = alive

local ids_base = Idstring("base")

function ActionSpooc:init(action_desc, common_data)
	self._common_data = common_data
	self._action_desc = action_desc
	self._ext_base = common_data.ext_base
	self._ext_brain = common_data.ext_brain
	self._ext_network = common_data.ext_network
	self._stance = common_data.stance
	self._machine = common_data.machine

	local ext_mov = common_data.ext_movement
	self._ext_movement = ext_mov

	local ext_anim = common_data.ext_anim
	self._ext_anim = ext_anim

	local my_unit = common_data.unit
	self._unit = my_unit

	local is_server = Network:is_server()
	self._is_server = is_server

	local is_local, target_unit = nil
	local was_interrupted = action_desc.interrupted
	self._was_interrupted = was_interrupted
	self._host_expired = action_desc.host_expired

	--interrupted spooc actions only exist to make the husk of the unit move to its server position when they got interrupted there
	if was_interrupted then
		is_local = action_desc.is_local
	elseif not action_desc.is_drop_in then --host syncs attentions to drop-ins 0.1s after finishing connecting
		self:on_attention(common_data.attention)

		if not self._attention then
			return
		end

		target_unit = self._target_unit
		local target_base_ext = target_unit:base()

		if target_base_ext.is_local_player then
			if is_server and managers.player:has_category_upgrade("player", "convert_enemies_tackle_counter") then
				self._joker_vis_mask = managers.slot:get_mask("AI_visibility")
			end

			is_local = true

			target_unit:movement():on_targetted_for_attack(true, my_unit)
		elseif is_server then
			if target_base_ext.is_husk_player then
				if target_base_ext:upgrade_value("player", "convert_enemies_tackle_counter") then
					self._joker_vis_mask = managers.slot:get_mask("AI_visibility")
				end
			else
				is_local = true
			end
		end
	end

	if was_interrupted or not is_local then
		self._occlusion_manager = managers.occlusion
	end

	self._is_local = is_local

	local char_tweak = common_data.char_tweak
	local start_anim_idx = action_desc.start_anim_idx

	if not start_anim_idx then
		if not ext_anim.pose then
			ext_mov:play_redirect("idle")

			if not ext_anim.pose and not ext_mov:play_state("std/stand/still/idle/look") then
				return
			end
		end

		local allowed_poses = char_tweak.allowed_poses

		if not allowed_poses or allowed_poses.stand then
			ext_mov:play_redirect("stand")
		end
	end

	ext_mov:enable_update()

	local cur_pos = common_data.pos
	local nav_path = action_desc.nav_path

	if is_server or not nav_path then
		nav_path = {
			mvec3_cpy(cur_pos)
		}
	else
		nav_path[1] = mvec3_cpy(cur_pos)
	end

	self._nav_path = nav_path

	--used in copactionwalk functions
	if was_interrupted then
		self._no_run_start = true
		self._no_run_stop = true
	else
		if char_tweak.no_run_start then
			self._no_run_start = true
		--elseif not my_unit:in_slot(16) then
			--self._no_run_start_turn = true
		end

		self._no_run_start_turn = true
		self._no_run_stop = true --char_tweak.no_run_stop
	end

	self._using_christmas_sounds = self:_use_christmas_sounds()

	local timer = TimerManager:game()
	self._timer = timer
	self._is_flying_strike = action_desc.flying_strike
	self._host_stop_pos_inserted = action_desc.host_stop_pos_inserted
	self._stop_pos = action_desc.stop_pos

	local nav_index = action_desc.path_index or 1
	self._nav_index = nav_index

	local beating_time = 0
	local tweak_beat = char_tweak.spooc_attack_beating_time

	if tweak_beat then
		if tweak_beat[1] == tweak_beat[2] then
			beating_time = tweak_beat[1]
		else
			beating_time = math_lerp(tweak_beat[1], tweak_beat[2], math_random())
		end
	end

	self._beating_time = beating_time

	local stroke_t = action_desc.stroke_t and tonumber_g(action_desc.stroke_t)
	self._stroke_t = stroke_t
	self._beating_end_t = stroke_t and stroke_t + beating_time

	self._strike_nav_index = action_desc.strike_nav_index
	self._haste = "run"
	self._nr_expected_nav_points = action_desc.nr_expected_nav_points

	if is_server then
		local action_id = ActionSpooc._global_incremental_action_ID

		if action_id == 256 then
			ActionSpooc._global_incremental_action_ID = 1
		else
			ActionSpooc._global_incremental_action_ID = action_id + 1
		end

		self._action_id = action_id

		--[[local target_tracker = target_unit:movement():nav_tracker()
		self._chase_tracker = target_tracker

		local sync_target_pos = target_tracker:lost() and target_tracker:field_position() or target_tracker:position()

		common_data.ext_network:send("action_spooc_start", mvec3_cpy(sync_target_pos), action_desc.flying_strike, action_id)]]

		--syncing an actual vector here is useless with how this was reworked (so just send an empty vector and don't use it)
		--the authoritative peer dictates where the unit will begin moving to
		--instead of forcing them to move to the initial chase position on the server, when the unit started the action
		--all it does is making it confusing for clients as the unit will often not run directly towards them as expected
		--this is also because the unit will not start a sprint spooc action against clients if they're locally obstructed
		--this means no Cloakers won't chase clients through geometry unless the client makes that happen after a valid chase started (aka same as being the host)
		common_data.ext_network:send("action_spooc_start", Vector3(), action_desc.flying_strike, action_id)
	else
		self._action_id = action_desc.action_id

		--[[local host_stop_pos = ext_mov:m_host_stop_pos()

		if host_stop_pos ~= cur_pos then
			local host_stop_pos_i = self._host_stop_pos_inserted

			if host_stop_pos_i then
				self._host_stop_pos_inserted = host_stop_pos_i + 1
			else
				self._host_stop_pos_inserted = 1
			end

			if not nav_path[2] then
				self._nav_path[2] = mvec3_cpy(host_stop_pos)
			else
				local new_path_table = {
					nav_path[1],
					mvec3_cpy(host_stop_pos)
				}

				for idx = 2, #nav_path do
					new_path_table[#new_path_table + 1] = nav_path[idx]
				end

				nav_path = new_path_table
				self._nav_path = nav_path
			end
		end]]
	end

	self._last_vel_z = 0
	self._cur_vel = 0
	self._last_pos = mvec3_cpy(cur_pos)

	CopActionAct._create_blocks_table(self, action_desc.blocks)

	local my_tracker = common_data.nav_tracker
	self._my_tracker = my_tracker

	if start_anim_idx then
		if action_desc.flying_strike then
			self:_set_updator("_upd_flying_strike_first_frame")
		else
			self:_set_updator("_upd_strike_first_frame")
		end
	elseif was_interrupted then
		if nav_path[nav_index + 1] then
			self:_start_sprint()
		else
			self:_wait()
		end

		return true
	elseif is_local then
		if not is_server and self:_chk_target_invalid() then
			self:_send_stop()
			self:_wait()
		elseif action_desc.flying_strike then
			if is_server or ActionSpooc.chk_can_start_flying_strike(my_unit, target_unit) then
				self:_set_updator("_upd_flying_strike_first_frame")
			else
				self:_send_stop()
				self:_wait()
			end
		elseif is_server or ActionSpooc.chk_can_start_spooc_sprint(my_unit, target_unit) then
			if my_tracker:lost() then
				--nav_path[#nav_path + 1] = mvec3_cpy(my_tracker:field_position())
				nav_path[1] = mvec3_cpy(my_tracker:field_position())
			end

			local target_tracker = self._chase_tracker or target_unit:movement():nav_tracker()
			self._chase_tracker = target_tracker

			local chase_pos = target_tracker:lost() and target_tracker:field_position() or target_tracker:position()

			nav_path[#nav_path + 1] = mvec3_cpy(chase_pos)
			self._nav_path = nav_path

			--using an empty vector to define self._last_sent_pos as the _send_nav_point function will modify it
			self._last_sent_pos = Vector3()

			--send the starting position if the action successfully started on the authoritative peer
			--this is to ensure that the unit moves to this position for other peers before actually starting the chase
			self:_send_nav_point(mvec3_cpy(cur_pos))

			self:_start_sprint()
		else
			self:_send_stop()
			self:_wait()
		end
	elseif is_server then
		self:_wait()
	elseif action_desc.flying_strike then
		if action_desc.strike then
			self._queued_kick_after_landing = true
		end

		if nav_path[nav_index + 1] then
			self:_set_updator("_upd_flying_strike_first_frame")
		else
			self:_wait()
		end
	elseif action_desc.strike then
		self:_start_sprint()
	elseif nav_path[nav_index + 1] then
		self:_start_sprint()
	else
		self:_wait()
	end

	if is_local then
		local taunt_during_assault, taunt_after_assault = nil
		local spooc_sound_events = char_tweak.spooc_sound_events

		if spooc_sound_events then
			if spooc_sound_events.taunt_during_assault then
				taunt_during_assault = spooc_sound_events.taunt_during_assault
				self._taunt_during_assault = taunt_during_assault
			end

			if spooc_sound_events.taunt_after_assault then
				taunt_after_assault = spooc_sound_events.taunt_after_assault
				self._taunt_after_assault = taunt_after_assault
			end
		end

		if not taunt_during_assault or not taunt_after_assault then
			local ext_base = common_data.ext_base

			if ext_base.has_tag and ext_base:has_tag("spooc") then
				local ai_type = tweak_data.levels:get_ai_group_type()
				local level_types = LevelsTweakData.LevelType
				local r = level_types.Russia
				local f = level_types.Federales

				if not taunt_during_assault then
					if ai_type == r then
						self._taunt_during_assault = "rcloaker_taunt_during_assault"
					elseif ai_type == f then
						self._taunt_during_assault = "mcloaker_taunt_during_assault"
					else
						self._taunt_during_assault = "cloaker_taunt_during_assault"
					end
				end

				if not taunt_after_assault then
					if ai_type == r then
						self._taunt_after_assault = "rcloaker_taunt_after_assault"
					elseif ai_type == f then
						self._taunt_after_assault = "mcloaker_taunt_after_assault"
					else
						self._taunt_after_assault = "cloaker_taunt_after_assault"
					end
				end
			end
		end
	end

	if start_anim_idx then
		self:update(timer:time())
	end

	return true
end

function ActionSpooc:_send_stop()
	if self._already_sent_stop then
		return
	end

	self._already_sent_stop = true

	local host_stop_pos_i, stop_nav_index = self._host_stop_pos_inserted

	if host_stop_pos_i then
		stop_nav_index = math_clamp(self._nav_index - host_stop_pos_i, 1, 255)
	else
		stop_nav_index = math_clamp(self._nav_index, 1, 255)
	end

	if self._is_server then
		local sync_pos = nil

		----test online, watch someone counter a Cloaker
		if not self._expired then
			local field_pos = self._my_tracker:field_position()
			local below_pos = field_pos + math_down * 500
			local nav_clamp_ray = self._unit:raycast("ray", field_pos, below_pos, "slot_mask", managers.slot:get_mask("AI_graph_obstacle_check"), "ray_type", "walk")

			sync_pos = nav_clamp_ray and nav_clamp_ray.position or field_pos
		else
			sync_pos = self._common_data.pos
		end

		self._ext_network:send("action_spooc_stop", mvec3_cpy(sync_pos), stop_nav_index, self._action_id)
	else
		local session = managers.network:session()
		local server_peer = session:server_peer()

		if server_peer then
			session:send_to_peer_synched(server_peer:id(), "action_spooc_stop", self._unit, mvec3_cpy(self._common_data.pos), stop_nav_index, self._action_id)
		end
	end
end

function ActionSpooc:on_exit()
	local is_server = self._is_server
	local expired = self._expired
	local common_data = self._common_data
	local ext_mov = self._ext_movement
	local my_unit = self._unit

	if common_data.ext_damage:dead() then
		self:_check_sounds_and_lights_state(false, true)
	elseif not self._was_interrupted then
		self:_check_sounds_and_lights_state(false)

		if expired and self._taunt_at_beating_played then
			local taa_sound = self._taunt_after_assault

			if taa_sound and not my_unit:sound():speaking(self._timer:time()) then
				local strike_unit = self._strike_unit

				if alive_g(strike_unit) and not self:_chk_invalid_beating_unit_status(strike_unit) then
					my_unit:sound():say(taa_sound, true, true)
				end
			end
		end

		if is_server then
			local my_tracker = self._my_tracker

			if my_tracker:lost() then
				local safe_pos = mvec3_cpy(my_tracker:field_position())

				ext_mov:set_position(safe_pos)
			end
		elseif self._is_flying_strike then
			local stop_pos = self._stop_pos

			if stop_pos then
				ext_mov:set_position(stop_pos)
			end
		end
	end

	if self._root_blend_disabled then
		ext_mov:set_root_blend(true)

		self._root_blend_disabled = nil
	end

	if self._changed_driving then
		my_unit:set_driving("script")

		self._changed_driving = nil
	end

	if expired and self._ext_anim.move then
		self:_stop_walk()
	end

	ext_mov:drop_held_items()

	if is_server then
		self:_send_stop()
	else
		ext_mov:set_m_host_stop_pos(common_data.pos)
	end

	local target_unit = self._target_unit

	if alive_g(target_unit) and target_unit:base().is_local_player then
		target_unit:movement():on_targetted_for_attack(false, my_unit)
	end
end

function ActionSpooc:_chk_can_strike()
	if self._was_interrupted then
		return
	end

	local target_tracker = self._chase_tracker
	local is_flying_strike = self._is_flying_strike

	if is_flying_strike then
		target_tracker = self._target_unit:movement():nav_tracker()
		self._chase_tracker = target_tracker
	elseif self._stroke_t then
		return
	end

	local my_pos = self._common_data.pos
	local target_pos = self._tmp_vec1

	if target_tracker:lost() then
		mvec3_set(target_pos, target_tracker:field_position())
	else
		target_tracker:m_position(target_pos)
	end

	local function _dis_chk(pos)
		pos = pos - my_pos

		local dif_z = math_abs(mvec3_z(pos))

		if dif_z < 75 then
			pos = pos:with_z(0)

			return mvec3_len_sq(pos) < 52900
		end
	end

	if not _dis_chk(target_pos) then
		return
	elseif is_flying_strike then
		return true
	end

	local path = self._nav_path
	mvec3_set(target_pos, path[#path])

	if _dis_chk(target_pos) then
		return true
	end
end

function ActionSpooc:_chk_target_invalid()
	local target_unit = self._target_unit

	if not target_unit or not alive_g(target_unit) then
		return true
	end

	local record = managers.groupai:state():criminal_record(target_unit:key())

	if record then
		if record.status then
			return true
		--[[else
			local is_last_standing = true

			for u_key, u_data in pairs(managers.groupai:state():all_char_criminals()) do
				if not u_data.status and target_unit:key() ~= u_key then
					is_last_standing = false

					break
				end
			end

			if is_last_standing then
				return true
			end]]
		end
	end

	local target_mov_ext = target_unit:movement()

	if target_mov_ext.zipline_unit and target_mov_ext:zipline_unit() then
		return true
	end

	if target_mov_ext.is_SPOOC_attack_allowed and not target_mov_ext:is_SPOOC_attack_allowed() then
		return true
	end

	if self._is_server then
		if managers.groupai:state():is_unit_team_AI(target_unit) and target_mov_ext:chk_action_forbidden("hurt") then
			return true
		end

		local target_dmg_ext = target_unit:character_damage()

		if target_dmg_ext.dead and target_dmg_ext:dead() then
			return true
		end
	end
end

function ActionSpooc:_start_sprint()
	self:_check_sounds_and_lights_state(true)

	CopActionWalk._chk_start_anim(self, self._nav_path[self._nav_index + 1])

	if self._start_run then
		self:_set_updator("_upd_start_anim_first_frame")
	else
		self:_set_updator("_upd_sprint")
		self._ext_base:chk_freeze_anims()
	end
end

function ActionSpooc:_upd_strike_first_frame(t)
	if self._kick_after_landing then
		self._already_kicked_after_landing = true
	end

	local is_local = self._is_local

	if is_local and self:_chk_target_invalid() then
		if self._is_server then
			self:_expire()
		else
			self:_send_stop()
			self:_wait()
		end

		return
	end

	if self._joker_vis_mask and self:check_joker_counter(t) then
		return
	end

	local my_unit = self._unit
	local ext_mov = self._ext_movement
	local common_data = self._common_data
	local action_desc = self._action_desc
	local drop_in_t = action_desc.start_anim_time
	local redir_result, skipped_item_spawning = nil

	if drop_in_t then
		action_desc.start_anim_time = nil

		local start_anim_idx = self._action_desc.start_anim_idx
		action_desc.start_anim_idx = nil

		local state_name = self._machine:index_to_state_name(start_anim_idx)

		redir_result = ext_mov:play_state_idstr(state_name, drop_in_t)

		if redir_result then
			self:_check_sounds_and_lights_state(true)

			if self._stroke_t then
				local detect_stop_sound = self:get_sound_event("detect_stop")

				if detect_stop_sound then
					my_unit:sound():play(detect_stop_sound)
				end
			end

			if not self._ext_anim.spooc_enter then
				skipped_item_spawning = true
			end
		end
	else
		redir_result = ext_mov:play_redirect("spooc_strike")
	end

	if redir_result then
		if skipped_item_spawning then
			ext_mov:anim_clbk_wanted_item(my_unit, "baton", "hand_l", true)
			ext_mov:spawn_wanted_items()
			ext_mov:anim_clbk_flush_wanted_items()
		else
			ext_mov:spawn_wanted_items()
		end
	elseif is_local then
		if self._is_server then
			self:_expire()
		else
			self:_send_stop()
			self:_wait()
		end

		return
	else
		self:_wait()

		return
	end

	if is_local then
		local last_synced_pos = self._last_sent_pos

		if last_synced_pos then
			mvec3_set(last_synced_pos, common_data.pos)
		end

		self._ext_network:send("action_spooc_strike", mvec3_cpy(common_data.pos), self._action_id)

		self._nav_path[self._nav_index + 1] = mvec3_cpy(common_data.pos)
	end

	self._last_vel_z = 0

	self:_set_updator("_upd_striking")
	self._ext_base:chk_freeze_anims()
end

function ActionSpooc:_upd_chase_path()
	local my_tracker, target_tracker = self._my_tracker, self._chase_tracker
	local ray_params = {
		allow_entry = true,
		trace = true
	}

	if my_tracker:lost() then
		ray_params.pos_from = my_tracker:field_position()
	else
		ray_params.tracker_from = my_tracker
	end

	local chase_pos, simplified = nil

	if target_tracker:lost() then
		chase_pos = target_tracker:field_position()

		ray_params.pos_to = chase_pos
	else
		chase_pos = target_tracker:position()

		ray_params.tracker_to = target_tracker
	end

	local nav_manager = managers.navigation
	local nav_ray_f = nav_manager.raycast
	local path, path_index = self._nav_path, self._nav_index

	if path_index < #path - 1 then
		local walk_ray = nav_ray_f(nav_manager, ray_params)

		if not walk_ray then
			simplified = true

			local i_check = path_index + 2

			if #path >= i_check then
				local new_path_table = {}

				for idx = 1, i_check - 1 do
					new_path_table[#new_path_table + 1] = path[idx]
				end

				path = new_path_table
			end
		end
	end

	local walk_ray = nil

	if not simplified then
		ray_params.tracker_from = nil

		local index_from = #path - 1
		index_from = index_from < 1 and 1 or index_from

		ray_params.pos_from = path[index_from]

		walk_ray = nav_ray_f(nav_manager, ray_params)
	end

	if walk_ray then
		path[#path + 1] = mvec3_cpy(chase_pos)
	else
		mvec3_set(path[#path], ray_params.trace[1])
	end

	self._nav_path = path
end

function ActionSpooc:_upd_sprint(t)
	if self._is_local and not self._was_interrupted then
		if self:_chk_target_invalid() then
			if self._is_server then
				self:_expire()
			else
				self:_send_stop()
				self:_wait()
			end

			return
		end

		self:_upd_chase_path()

		if self:_chk_can_strike() then
			self:_strike()

			return
		end
	end

	if self._joker_vis_mask and self:check_joker_counter(t) then
		return
	end

	local dt = self._timer:delta_time()

	if self._end_of_path then
		if self._stop_pos and not self._nr_expected_nav_points then--or self._is_server and self._stroke_t then
			self:_expire()
		else
			self:_wait()
		end

		return
	else
		self:_nav_chk(t, dt)
	end

	local move_dir = nil
	local expired = self._expired
	local real_velocity = self._cur_vel
	local not_moving = expired or real_velocity < 0.1

	local ext_anim = self._ext_anim
	local common_data = self._common_data
	local cur_pos = common_data.pos
	local last_pos = self._last_pos

	if not not_moving then
		move_dir = last_pos - cur_pos
		move_dir = move_dir:with_z(0)
	end

	--if not moving, stop the moving animation if possible and just apply gravity
	if not move_dir then
		self:_set_new_pos(dt)

		if not expired then
			if ext_anim.move then
				self:_stop_walk()
			end

			if self._strike_now then
				self:_strike()
			end
		end

		return
	end

	local move_dir_norm = move_dir:normalized()
	local next_pos = self._nav_path[self._nav_index + 1]
	local face_fwd = nil

	if next_pos then
		face_fwd = next_pos - cur_pos
		face_fwd = face_fwd:with_z(0):normalized()
	else
		face_fwd = move_dir:with_z(0):normalized()
	end

	local face_right = face_fwd:cross(math_up):normalized()
	local right_dot = move_dir_norm:dot(face_right)
	local fwd_dot = move_dir_norm:dot(face_fwd)
	local abs_right_dot = math_abs(right_dot)
	local abs_fwd_dot = math_abs(fwd_dot)
	local wanted_walk_dir = nil

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

	local wanted_u_fwd = move_dir_norm:rotate_with(self._walk_side_rot[wanted_walk_dir])
	local delta_lerp = dt * 5
	delta_lerp = delta_lerp > 1 and 1 or delta_lerp

	local new_rot = temp_rot1
	mrot_lookat(new_rot, wanted_u_fwd, math_up)

	new_rot = common_data.rot:slerp(new_rot, delta_lerp)

	self._ext_movement:set_rotation(new_rot)

	local variant = self._haste
	local stance = self._stance
	local stance_name = stance.name
	local pose = stance.values[4] > 0 and "wounded" or ext_anim.pose or "stand"
	local anim_velocities = self._walk_anim_velocities
	local wanted_walk = anim_velocities[pose]
	wanted_walk = wanted_walk and wanted_walk[stance_name]

	if ext_anim.sprint then
		if ext_anim.pose == "stand" and real_velocity > 480 then
			variant = "sprint"
		elseif real_velocity > 250 then
			variant = "run"
		else
			variant = "walk"
		end
	elseif ext_anim.run then
		if real_velocity > 530 and ext_anim.pose == "stand" and wanted_walk.sprint then
			variant = "sprint"
		elseif real_velocity > 250 then
			variant = "run"
		else
			variant = "walk"
		end
	elseif real_velocity > 530 and ext_anim.pose == "stand" and wanted_walk.sprint then
		variant = "sprint"
	elseif real_velocity > 300 then
		variant = "run"
	else
		variant = "walk"
	end

	self:_adjust_move_anim(wanted_walk_dir, variant)

	--adjust movement anim speed based on the variant that might've changed above + direction
	local anim_walk_speed = wanted_walk[variant][wanted_walk_dir]
	local wanted_walk_anim_speed = real_velocity / anim_walk_speed

	self:_adjust_walk_anim_speed(dt, wanted_walk_anim_speed)
	self:_set_new_pos(dt)

	if self._strike_now then
		self:_strike()
	end
end

function ActionSpooc:_upd_start_anim_first_frame(t)
	if self._joker_vis_mask and self:check_joker_counter(t) then
		return
	end

	local pose = self._ext_anim.pose or "stand"
	local speed = self:_get_current_max_walk_speed("fwd")
	local speed_mul = speed / self._walk_anim_velocities[pose][self._stance.name].run.fwd
	local start_run_turn = self._start_run_turn
	local start_run_dir = start_run_turn and start_run_turn[3] or self._start_run_straight

	self:_start_move_anim(start_run_dir, "run", speed_mul, start_run_turn)

	self:_set_updator("_upd_start_anim")
	self._ext_base:chk_freeze_anims()
end

function ActionSpooc:_upd_start_anim(t)
	local ext_mov = self._ext_movement

	if self._is_local and not self._was_interrupted then
		if self:_chk_target_invalid() then
			if self._is_server then
				self:_expire()
			else
				self:_send_stop()
				self:_wait()
			end

			if self._root_blend_disabled then
				ext_mov:set_root_blend(true)

				self._root_blend_disabled = nil
			end

			return
		end

		if self._joker_vis_mask and self:check_joker_counter(t) then
			return
		end

		self:_upd_chase_path()

		if self:_chk_can_strike() then
			if self._root_blend_disabled then
				ext_mov:set_root_blend(true)

				self._root_blend_disabled = nil
			end

			self:_strike()

			return
		end
	elseif self._joker_vis_mask and self:check_joker_counter(t) then
		return
	end

	local ext_anim = self._ext_anim
	local common_data = self._common_data

	if not ext_anim.run_start then
		if self._root_blend_disabled then
			ext_mov:set_root_blend(true)

			self._root_blend_disabled = nil
		end

		self._start_run = nil
		self._start_run_straight = nil
		self._start_run_turn = nil
		self._correct_vel_with = nil
		self._correct_vel_from = nil

		local current_pos = common_data.pos

		----not a priority now, but try using this (to avoid run_turn clipping issues) without causing syncing issues
		--if not self._start_run_turn then
			mvec3_set(self._nav_path[self._nav_index], current_pos)
		--[[else
			self._start_run_turn = nil

			local chk_shortcut_func = CopActionWalk._chk_shortcut_pos_to_pos
			local path = self._nav_path
			local path_index = self._nav_index
			local shortcut_chk_index = path_index + 2

			if not path[shortcut_chk_index] then
				local old_pos = path[path_index]
				local next_pos = path[path_index + 1]

				local vec_from_cur = next_pos - current_pos
				local length_from_cur = vec_from_cur:with_z(0):length() * 0.5
				local vec_from_old = next_pos - old_pos
				local length_from_old = vec_from_old:with_z(0):length()

				mvec3_lerp(vec_from_old, old_pos, next_pos, length_from_cur / length_from_old)

				if chk_shortcut_func(current_pos, vec_from_old) then
					length_from_cur = vec_from_cur:with_z(0):length() * 0.75

					mvec3_lerp(vec_from_old, old_pos, next_pos, length_from_cur / length_from_old)

					if chk_shortcut_func(current_pos, vec_from_old) then
						vec_from_cur = current_pos - old_pos
						length_from_cur = vec_from_cur:with_z(0):length()

						mvec3_lerp(vec_from_old, old_pos, next_pos, length_from_cur / length_from_old)
					end
				end

				path[path_index] = mvec3_cpy(current_pos)
				path[path_index + 1] = vec_from_old
				path[shortcut_chk_index] = next_pos
			else
				local old_pos = path[path_index]
				local next_index = path_index + 1
				path[path_index] = mvec3_cpy(current_pos)

				local copied_cur_pos = mvec3_cpy(current_pos)
				local vec_from_old = current_pos - old_pos
				vec_from_old = vec_from_old:with_z(0):normalized()

				while true do
					local vec_to_next = path[next_index] - current_pos
					vec_to_next = vec_to_next:with_z(0):normalized()

					if vec_to_next:dot(vec_from_old) < 0 and not chk_shortcut_func(current_pos, path[shortcut_chk_index]) then
						local new_path = {
							copied_cur_pos
						}

						for idx = shortcut_chk_index, #path do
							new_path[#new_path + 1] = path[idx]
						end

						path = new_path

						if not path[shortcut_chk_index] then
							break
						end
					else
						break
					end
				end
			end

			self._nav_path = path
		end]]

		self._last_pos = mvec3_cpy(current_pos)

		self:_set_updator("_upd_sprint")
		self:update(t)

		return
	end

	local dt = self._timer:delta_time()
	local start_run_turn = self._start_run_turn

	if start_run_turn then
		if ext_anim.run_start_full_blend then
			local seg_rel_t = self._machine:segment_relative_time(ids_base)
			local start_rel_t = start_run_turn.start_seg_rel_t

			if not start_rel_t then
				start_rel_t = seg_rel_t
				start_run_turn.start_seg_rel_t = seg_rel_t
			end

			local new_pos = nil

			if seg_rel_t > 0.6 then
				local delta_pos = common_data.unit:get_animation_delta_position() * 2
				local correct_vel_from = self._correct_vel_from
				local cur_vel = self._cur_vel

				if correct_vel_from then
					local lerp = (math_clamp(seg_rel_t, 0, 0.9) - 0.6) / 0.3
					cur_vel = math_lerp(correct_vel_from, self._correct_vel_with, lerp)
				else
					self._correct_vel_with = self:_get_current_max_walk_speed("fwd")
					self._correct_vel_from = cur_vel
				end

				self._cur_vel = cur_vel

				mvec3_set_l(delta_pos, cur_vel * dt)

				new_pos = common_data.pos + delta_pos

				local ray_params = {
					allow_entry = true,
					trace = true,
					tracker_from = common_data.nav_tracker,
					pos_to = new_pos
				}
				local collision = managers.navigation:raycast(ray_params)

				if collision then
					new_pos = ray_params.trace[1]

					local travel_vec = new_pos - self._last_pos
					local new_vel = travel_vec:with_z(0):length() / dt

					self._cur_vel = new_vel
				end
			else
				local delta_pos = common_data.unit:get_animation_delta_position() * 2
				new_pos = common_data.pos + delta_pos

				local ray_params = {
					allow_entry = true,
					trace = true,
					tracker_from = common_data.nav_tracker,
					pos_to = new_pos
				}
				local collision = managers.navigation:raycast(ray_params)

				if collision then
					new_pos = ray_params.trace[1]
				end

				local travel_vec = new_pos - self._last_pos
				local new_vel = travel_vec:with_z(0):length() / dt

				self._cur_vel = new_vel
			end

			self._last_pos = new_pos

			local seg_rel_t_clamp = math_clamp((seg_rel_t - start_run_turn.start_seg_rel_t) / 0.77, 0, 1)
			local prog_angle = start_run_turn[2] * seg_rel_t_clamp
			local new_yaw = start_run_turn[1] + prog_angle
			local new_rot = temp_rot1

			mrot_set(new_rot, new_yaw, 0, 0)
			ext_mov:set_rotation(new_rot)
		else
			start_run_turn.start_seg_rel_t = self._machine:segment_relative_time(ids_base)
		end
	else
		local end_of_path = self._end_of_path

		if end_of_path then
			self._start_run = nil

			if self._stop_pos and not self._nr_expected_nav_points then-- or self._is_server and self._stroke_t then
				self:_expire()
			else
				self:_wait()
			end

			return
		else
			self:_nav_chk(t, dt)
		end

		if not end_of_path then
			local wanted_u_fwd = self._nav_path[self._nav_index + 1] - common_data.pos
			wanted_u_fwd = wanted_u_fwd:with_z(0):normalized():rotate_with(self._walk_side_rot[self._start_run_straight])

			local new_rot = temp_rot1
			mrot_lookat(new_rot, wanted_u_fwd, math_up)

			local delta_lerp = dt * 5
			delta_lerp = delta_lerp > 1 and 1 or delta_lerp

			new_rot = common_data.rot:slerp(new_rot, delta_lerp)

			ext_mov:set_rotation(new_rot)
		end
	end

	self:_set_new_pos(dt)

	if self._strike_now then
		self:_strike()

		if self._root_blend_disabled then
			ext_mov:set_root_blend(true)

			self._root_blend_disabled = nil
		end

		self._start_run = nil
		self._start_run_turn = nil
		self._start_run_straight = nil

		return
	end
end

function ActionSpooc:get_husk_interrupt_desc()
	local old_action_desc = {
		block_type = "walk",
		interrupted = true,
		type = "spooc",
		body_part = 1,
		stop_pos = self._stop_pos,
		path_index = self._nav_index,
		nav_path = self._nav_path,
		--strike_nav_index = self._strike_nav_index,
		stroke_t = true,
		host_stop_pos_inserted = self._host_stop_pos_inserted,
		nr_expected_nav_points = self._nr_expected_nav_points,
		is_local = self._is_local,
		action_id = self._action_id,
		host_expired = self._host_expired
	}

	return old_action_desc
end

function ActionSpooc:_expire()
	if self._is_flying_strike and not self._kick_after_landing then
		self._expired = true

		self:_set_updator("_upd_exit_empty")
	else
		local ext_anim = self._ext_anim

		if ext_anim.act or ext_anim.spooc_enter or ext_anim.spooc_exit then
			if self._is_server then
				self:_send_stop()
			end

			if not ext_anim.spooc_exit then
				self._ext_movement:play_redirect("idle")
			end

			self:_set_updator("_upd_exiting")
		else
			self._expired = true

			self:_set_updator("_upd_exit_empty")
		end
	end
end

function ActionSpooc:_upd_exiting(t)
	if self._ext_anim.idle then
		self._expired = true

		self:_set_updator("_upd_exit_empty")
	end
end

function ActionSpooc:_upd_exit_empty(t)
end

function ActionSpooc:save(save_data)
	local is_flying_strike = self._is_flying_strike

	save_data.type = "spooc"
	save_data.body_part = 1
	save_data.block_type = "walk"
	save_data.is_drop_in = true
	save_data.stop_pos = self._stop_pos
	save_data.path_index = self._nav_index
	save_data.strike_nav_index = self._strike_nav_index
	save_data.flying_strike = is_flying_strike
	save_data.stroke_t = self._stroke_t
	save_data.action_id = self._action_id
	save_data.blocks = {
		idle = -1,
		act = -1,
		turn = -1,
		walk = -1
	}

	if is_flying_strike then
		save_data.blocks.light_hurt = -1
		save_data.blocks.heavy_hurt = -1
		save_data.blocks.fire_hurt = -1
		save_data.blocks.hurt = -1
		save_data.blocks.expl_hurt = -1
		save_data.blocks.taser_tased = -1
	end

	local sync_path = {}
	local nav_path = self._nav_path

	if is_flying_strike then
		for i = 1, #nav_path do
			sync_path[#sync_path + 1] = mvec3_cpy(nav_path[i])
		end
	else
		for i = 1, self._nav_index + 1 do
			sync_path[#sync_path + 1] = mvec3_cpy(nav_path[i])
		end
	end

	save_data.nav_path = sync_path

	local ext_anim = self._ext_anim

	if ext_anim.act or ext_anim.spooc_enter or ext_anim.spooc_exit then
		local machine = self._machine
		local state_name = machine:segment_state(ids_base)
		save_data.start_anim_idx = machine:state_name_to_index(state_name)
		save_data.start_anim_time = machine:segment_real_time(ids_base)

		if is_flying_strike then
			save_data.pos_z = mvec3_z(self._common_data.pos)
			save_data.travel_scaling = self._flying_strike_data.travel_dis_scaling_xy
		end
	end
end

function ActionSpooc:_nav_chk(t, dt)
	local common_data = self._common_data
	local path = self._nav_path
	local old_nav_index = self._nav_index
	local move_side = self._ext_anim.move_side or "fwd"
	local vel = self:_get_current_max_walk_speed(move_side)
	local walk_dis = vel * dt
	local last_pos = self._last_pos
	local cur_pos = common_data.pos
	local was_interrupted = self._was_interrupted

	mvec3_set(path[old_nav_index], cur_pos)

	local new_pos, new_nav_index, complete = CopActionWalk._walk_spline(path, self._last_pos, old_nav_index, walk_dis)

	if not self._stroke_t and not was_interrupted then
		local strike_index = self._strike_nav_index

		if strike_index then
			if complete or strike_index <= new_nav_index and strike_index == new_nav_index + 1 then
				new_nav_index = strike_index - 1
				new_pos = mvec3_cpy(path[strike_index])

				self._strike_now = true
			end
		end
	end

	if complete then
		self._end_of_path = true
	end

	if self._start_run then
		local delta_pos = common_data.unit:get_animation_delta_position() * 2
		local travel_vec = cur_pos + delta_pos - last_pos
		walk_dis = travel_vec:with_z(0):length()

		self._cur_vel = walk_dis / dt
	else
		local turn_vel, wanted_vel = self._turn_vel, vel

		if turn_vel then
			local next_pos = path[old_nav_index + 1]:with_z(cur_pos.z)
			local dis = mvec3_dis_sq(cur_pos, next_pos)

			wanted_vel = dis < 4900 and math_lerp(turn_vel, vel, dis / 4900) or wanted_vel
		end

		local cur_vel = self._cur_vel

		if cur_vel ~= wanted_vel then
			local adj_mul = cur_vel < wanted_vel and 1.5 or 4
			--local adj = vel * 2 * dt
			local adj = vel * adj_mul * dt
			cur_vel = math_step(cur_vel, wanted_vel, adj)

			walk_dis = cur_vel * dt
			self._cur_vel = cur_vel
		end
	end

	if old_nav_index ~= new_nav_index then
		if self._is_local and not was_interrupted then
			self:_send_nav_point(mvec3_cpy(path[old_nav_index]))
		end

		local future_pos = path[new_nav_index + 2]

		if future_pos then
			local next_pos = path[new_nav_index + 1]
			local back_pos = path[new_nav_index]
			local cur_vec = next_pos - back_pos
			cur_vec = cur_vec:with_z(0):normalized()

			local next_vec = future_pos - next_pos
			next_vec = next_vec:with_z(0):normalized()

			local turn_dot = cur_vec:dot(next_vec)
			local dot_lerp = turn_dot * turn_dot

			local clamped_vel = vel * 0.3
			clamped_vel = clamped_vel < 100 and 100 or clamped_vel
			clamped_vel = clamped_vel > vel and vel or clamped_vel

			local turn_vel = math_lerp(clamped_vel, vel, dot_lerp)
			self._turn_vel = turn_vel
		else
			self._turn_vel = nil
		end
	elseif self._is_local and not was_interrupted and mvec3_dis(self._last_sent_pos:with_z(cur_pos.z), cur_pos) > 200 then
		local new_i = new_nav_index + 1
		new_nav_index = new_i

		if not path[new_i] then
			path[#path + 1] = mvec3_cpy(cur_pos)
		else
			local new_path_table = {}

			for idx = 1, new_i - 1 do
				new_path_table[#new_path_table + 1] = path[idx]
			end

			new_path_table[#new_path_table + 1] = mvec3_cpy(cur_pos)

			for idx = new_i, #path do
				new_path_table[#new_path_table + 1] = path[idx]
			end

			path = new_path_table
		end

		self:_send_nav_point(mvec3_cpy(cur_pos))
	end

	self._nav_path = path
	self._nav_index = new_nav_index
	self._last_pos = mvec3_cpy(new_pos)
end

function ActionSpooc:_upd_wait(t)
	if self._ext_anim.move then
		self:_stop_walk()
	end

	if self._root_blend_disabled then
		self._ext_movement:set_root_blend(true)

		self._root_blend_disabled = nil
	end

	if self._was_interrupted then
		return
	end

	if self._joker_vis_mask and self:check_joker_counter(t) then
		return
	end

	local is_local = self._is_local

	if not is_local or self._already_sent_stop then
		if self._kick_after_landing and not self._already_kicked_after_landing then
			self._ext_movement:play_redirect("stand")

			self:_strike()
		elseif self._host_expired or self._client_expired then
			if not is_local and self._is_flying_strike then
				self._action_completed = true
			end

			self:_expire()
		end

		return
	end

	if not self._is_flying_strike and not self._stroke_t and not self:_chk_target_invalid() then
		self:_upd_chase_path()

		if self._end_of_path and self._nav_index < #self._nav_path then
			self._end_of_path = nil

			self:_start_sprint()
		end
	end
end

function ActionSpooc:_upd_striking(t)
	local stroke_t = self._stroke_t

	if not stroke_t or self._kick_after_landing then
		if self._joker_vis_mask and self:check_joker_counter(t) then
			return
		end
	end

	--local line2 = Draw:brush(Color.blue:with_alpha(0.5), 0.1)
	--line2:sphere(self._ext_movement:m_pos(), 25)

	local target_unit = nil
	local is_local = self._is_local
	local ext_anim = self._ext_anim
	local is_enter = ext_anim.spooc_enter

	----kicks after landing will finish the beatdown immediately once spooc_enter is no longer true, need to fix, but not a priority since it works fine otherwise
	if is_local and not is_enter and self._stroke_t then
		local target = self._strike_unit

		target_unit = alive_g(target) and target
	else
		local target = self._target_unit

		target_unit = alive_g(target) and target
	end

	--[[if not target_unit then
		local line2 = Draw:brush(Color.blue:with_alpha(0.5), 0.1)
		line2:sphere(self._ext_movement:m_head_pos(), 25)
	end]]

	local common_data = self._common_data
	local ext_mov = self._ext_movement
	local dt = self._timer:delta_time()
	local my_pos = CopActionHurt._get_pos_clamped_to_graph(self, false)

	if target_unit then
		local my_fwd = common_data.fwd
		local target_pos = target_unit:movement():m_pos()
		local target_vec = target_pos - my_pos
		target_vec = target_vec:with_z(0):normalized()

		if my_fwd:dot(target_vec) < 0.98 then
			local my_fwd_polar_spin = my_fwd:to_polar_with_reference(target_vec, math_up).spin
			local angle = is_enter and 180 or 110
			local spin_adj = math_step(0, -my_fwd_polar_spin, angle * dt)

			local new_rot = temp_rot1
			mrot_set(new_rot, spin_adj, 0, 0)

			local wanted_u_fwd = my_fwd:rotate_with(new_rot)
			mrot_lookat(new_rot, wanted_u_fwd, math_up)

			ext_mov:set_rotation(new_rot)
		end
	end

	ext_mov:upd_ground_ray(my_pos, true)

	local gnd_z = common_data.gnd_ray.position.z

	if gnd_z < my_pos.z then
		self._last_vel_z = self._apply_freefall(my_pos, self._last_vel_z, gnd_z, dt)
	else
		if my_pos.z < gnd_z then
			my_pos = my_pos:with_z(gnd_z)
		end

		self._last_vel_z = 0
	end

	ext_mov:set_position(my_pos)

	if is_enter then
		return
	end

	if not is_local or self._already_sent_stop then
		if self._host_expired or self._client_expired then
			if not is_local then
				self._action_completed = true
			end

			self:_expire()
		end

		return
	end

	local beating_end_t = self._beating_end_t

	if not beating_end_t then
		beating_end_t = t + self._beating_time
		self._beating_end_t = beating_end_t
	--[[elseif beating_end_t == 0 then
		local line2 = Draw:brush(Color.yellow:with_alpha(0.5), 1)
		line2:sphere(self._ext_movement:m_head_pos(), 30)
	else
		local line2 = Draw:brush(Color.yellow:with_alpha(1), 1)
		line2:sphere(self._ext_movement:m_head_pos(), 30)]]
	end

	local needs_to_expire = not target_unit or self:_chk_invalid_beating_unit_status(target_unit)

	--[[if needs_to_expire then
		local line2 = Draw:brush(Color.white:with_alpha(0.5), 1)
		line2:sphere(self._ext_movement:m_head_pos(), 30)
	end]]

	if not needs_to_expire and beating_end_t < t then
		--local line2 = Draw:brush(Color.green:with_alpha(0.5), 1)
		--line2:sphere(self._ext_movement:m_head_pos(), 30)

		self._action_completed = true
		needs_to_expire = true
	end

	if needs_to_expire then
		if self._is_server then
			self:_expire()
		else
			self:_send_stop()
		end
	elseif not self._taunt_at_beating_played then
		self._taunt_at_beating_played = true

		local tda_sound = self._taunt_during_assault

		if tda_sound then
			self._unit:sound():say(tda_sound, true, true)
		end
	end
end

function ActionSpooc:_chk_invalid_beating_unit_status(target_unit)
	local dmg_ext = target_unit:character_damage()

	if dmg_ext.is_downed and dmg_ext:is_downed() or dmg_ext.arrested and dmg_ext:arrested() then
		return
	end

	return true
end

function ActionSpooc:sync_stop(pos, stop_nav_index)
	self._stop_pos = mvec3_cpy(pos)

	if not self._was_interrupted then
		local flying_strike = self._is_flying_strike

		if self._is_server then
			--[[if flying_strike then
				self._blocks = {}
			end]]

			self._client_expired = true
		else
			self._host_expired = true
		end

		if flying_strike and not self._kick_after_landing then
			self._blocks = {}

			return
		else
			local is_local = self._is_local
			local ext_anim = self._ext_anim

			if is_local or ext_anim.act or ext_anim.spooc_enter or ext_anim.spooc_exit then
				if not is_local then
					self._action_completed = true
				end

				self:_expire()

				return
			end
		end
	end

	local host_stop_pos_i = self._host_stop_pos_inserted

	if host_stop_pos_i then
		stop_nav_index = stop_nav_index + host_stop_pos_i
	end

	local path = self._nav_path

	if #path > stop_nav_index then
		local new_path_table = {}

		for i = 1, stop_nav_index do
			new_path_table[#new_path_table + 1] = path[i]
		end

		path = new_path_table
	end

	local nr_exp_points = nil

	if #path < stop_nav_index - 1 then
		nr_exp_points = stop_nav_index - #path + 1
		self._nr_expected_nav_points = nr_exp_points
	else
		path[#path + 1] = pos

		local new_index = #path - 1
		new_index = new_index < 1 and 1 or new_index

		if new_index < self._nav_index then
			self._nav_index = new_index
		end
	end

	self._nav_path = path

	if self._end_of_path and not nr_exp_points then
		self._end_of_path = nil
		self._cur_vel = 0

		self:_start_sprint()
	end
end

function ActionSpooc:sync_append_nav_point(nav_point)
	local stop_pos = self._stop_pos
	local nr_exp_points = self._nr_expected_nav_points

	if stop_pos and not nr_exp_points then
		return
	end

	local path, start_sprint = self._nav_path

	path[#path + 1] = nav_point

	if self._is_flying_strike then
		self:_set_updator("_upd_flying_strike_first_frame")
	elseif self._end_of_path then
		self._end_of_path = nil

		local new_index = #path - 1
		local new_index_2 = self._nav_index + 1
		local nav_index = new_index > new_index_2 and new_index_2 or new_index
		self._nav_index = nav_index
		self._cur_vel = 0

		if nr_exp_points then
			if nr_exp_points == 1 then
				self._nr_expected_nav_points = nil

				path[#path + 1] = stop_pos
			else
				self._nr_expected_nav_points = nr_exp_points - 1
			end
		end

		start_sprint = true
	end

	self._nav_path = path

	if start_sprint then
		self:_start_sprint()
	end
end

function ActionSpooc:sync_strike(pos)
	if self._is_flying_strike then
		self._kick_after_landing = true

		return
	end

	local stop_pos = self._stop_pos
	local nr_exp_points = self._nr_expected_nav_points

	if stop_pos and not nr_exp_points then
		return
	end

	local path = self._nav_path

	path[#path + 1] = pos

	self._strike_nav_index = #path

	if nr_exp_points then
		if nr_exp_points == 1 then
			self._nr_expected_nav_points = nil

			path[#path + 1] = stop_pos
		else
			self._nr_expected_nav_points = nr_exp_points - 1
		end
	end

	self._nav_path = path

	if self._end_of_path then
		self._end_of_path = nil
		self._cur_vel = 0

		self:_start_sprint()
	end
end

function ActionSpooc:_send_nav_point(nav_point)
	self._ext_network:send("action_spooc_nav_point", nav_point, self._action_id)

	local last_synced_pos = self._last_sent_pos

	if last_synced_pos then
		mvec3_set(last_synced_pos, nav_point)
	end
end

function ActionSpooc:on_attention(attention)
	if self._was_interrupted then
		return
	end

	if attention then
		local cur_target = self._target_unit

		if cur_target and alive_g(cur_target) then
			local cur_attention = attention.unit

			if cur_attention and alive_g(cur_attention) and cur_target:key() == cur_attention:key() then
				return
			end
		end
	end

	local is_server, invalid_attention = self._server

	if is_server then
		if self._attention then
			--already had an attention set, the action needs to expire (handled by whoever is handling the action locally)
			invalid_attention = true
		end
	elseif self._client_attention_set or not attention then
		--same as the above, but if that doesn't apply, check if the unit even has an attention right now if we haven't set the attention here yet
		invalid_attention = true
	else
		local att_unit = attention.unit

		--ensure that the unit is a valid one, in case the action was queued for a client that wasn't authoritative on it and it expired midway through
		if not alive_g(att_unit) or not att_unit:base() or not att_unit:in_slot(managers.slot:get_mask("persons")) then
			invalid_attention = true
		end
	end

	if invalid_attention then
		if self._is_local then
			local target_unit = self._target_unit

			if alive_g(target_unit) and target_unit:base().is_local_player then
				target_unit:movement():on_targetted_for_attack(false, self._unit)
			end
		end

		self._attention = nil
		self._target_unit = nil
		self._attention_pos = nil
	else
		if not is_server then
			self._client_attention_set = true
		end

		self._attention = attention
		self._target_unit = attention.unit

		--[[local att_unit = attention.unit
		self._target_unit = att_unit

		local att_handler = attention.handler

		if att_handler then
			self._attention_pos = att_handler:get_ground_m_pos()
		elseif att_unit then
			local att_mov_ext = att_unit:movement()

			self._attention_pos = att_mov_ext and att_mov_ext:m_pos() or att_unit:position()
		else
			self._attention_pos = attention.pos or nil
		end]]
	end
end

function ActionSpooc:complete()
	return self._action_completed and self._expired
end

function ActionSpooc:anim_act_clbk(anim_act)
	if anim_act ~= "strike" then
		return
	end

	local my_unit = self._unit
	local kick_after_landing = self._kick_after_landing

	if self._stroke_t and not kick_after_landing then
		--[[if self._strike_unit then
			my_unit:sound():play("clk_punch_3rd_person_3p")
		end]]

		return
	end

	self._stroke_t = self._timer:time()
	my_unit:sound():play("clk_punch_3rd_person_3p")

	local detect_stop_sound = self:get_sound_event("detect_stop")

	if detect_stop_sound then
		my_unit:sound():play(detect_stop_sound)
	end

	if Global.game_settings.difficulty == "sm_wish" then
		MutatorCloakerEffect.effect_smoke(nil, my_unit)
	end

	managers.mutators:_run_func("OnPlayerCloakerKicked", my_unit)
	managers.modifiers:run_func("OnPlayerCloakerKicked", my_unit)

	if not self._is_local then
		return
	end

	local flying_strike = self._is_flying_strike

	if self:_chk_target_invalid() then
		if not flying_strike or kick_after_landing then
			if self._is_server then
				self:_expire()
			else
				self:_send_stop()
				self:_wait()
			end
		end

		return
	end

	local common_data = self._common_data
	local ext_mov = self._ext_movement
	local my_fwd = common_data.fwd
	local target_unit = self._target_unit
	local target_mov_ext = target_unit:movement()
	local target_com = target_mov_ext:m_com()
	local target_vec = target_com - common_data.pos
	local target_z_dis = math_abs(target_vec.z)

	if target_z_dis > 200 then
		if flying_strike and not kick_after_landing then
			return
		elseif not self._chase_tracker:lost() then
			if self._is_server then
				self:_expire()
			else
				self:_send_stop()
				self:_wait()
			end

			return
		end
	end

	target_vec = target_vec:with_z(0)

	local target_dis_xy = flying_strike and not kick_after_landing and target_vec:length()
	target_vec = target_vec:normalized()

	if target_dis_xy then
		local angle = target_vec:angle(my_fwd)
		local max_dis = math_lerp(170, 70, math_clamp(angle, 0, 90) / 90)

		if max_dis < target_dis_xy then
			return
		end
	end

	local spooc_res = nil
	local target_base_ext = target_unit:base()
	local target_dmg_ext = target_unit:character_damage()
	local non_lethal_kick_damage = common_data.char_tweak.non_lethal_kick_damage

	if non_lethal_kick_damage and target_dmg_ext.damage_melee then
		if target_base_ext.is_local_player then
			local player_head_pos = target_mov_ext:m_head_pos()
			local attack_dir = player_head_pos - ext_mov:m_com()
			attack_dir = attack_dir:normalized()

			local push_vec = attack_dir:with_z(0.1) * 600
			local attack_data = {
				variant = "melee",
				damage = non_lethal_kick_damage,
				attacker_unit = my_unit,
				push_vel = push_vec,
				col_ray = {
					position = mvec_copy(player_head_pos),
					unit = target_unit,
					ray = attack_dir
				}
			}

			local defense_data = target_dmg_ext:damage_melee(attack_data)

			if defense_data and defense_data ~= "friendly_fire" then
				if defense_data == "countered" then
					spooc_res = "countered"
				else
					self._beating_end_t = 0
				end
			end
		else
			local from_pos = flying_strike and not kick_after_landing and ext_mov:m_head_pos() or ext_mov:m_com()
			local attack_dir = target_com - from_pos
			local distance = mvec3_norm(attack_dir)

			local attack_data = {
				damage = non_lethal_kick_damage,
				damage_effect = target_dmg_ext._HEALTH_INIT,
				variant = "melee",
				attacker_unit = my_unit,
				attack_dir = attack_dir,
				col_ray = {
					position = mvec3_cpy(target_com),
					body = target_unit:body("body"),
					ray = attack_dir
				}
			}

			local defense_data = target_dmg_ext:damage_melee(attack_data)

			if defense_data and defense_data ~= "friendly_fire" then
				if defense_data == "countered" then
					spooc_res = "countered"
				else
					self._beating_end_t = 0

					if type_g(defense_data) == "table" and defense_data.type == "death" then
						local hit_pos = attack_data.col_ray.position

						managers.game_play_central:do_shotgun_push(target_unit, hit_pos, attack_dir, distance, my_unit)
						managers.game_play_central:do_shotgun_push(target_unit, hit_pos, attack_dir, distance, my_unit)
					end
				end
			end
		end
	elseif target_mov_ext.on_SPOOCed then
		spooc_res = target_mov_ext:on_SPOOCed(my_unit, flying_strike and not kick_after_landing and "flying_strike" or "sprint_attack")
	elseif target_dmg_ext.damage_melee then
		local from_pos = flying_strike and not kick_after_landing and ext_mov:m_head_pos() or ext_mov:m_com()
		local attack_dir = target_com - from_pos
		local distance = mvec3_norm(attack_dir)

		local attack_data = {
			damage = target_dmg_ext._HEALTH_INIT,
			damage_effect = target_dmg_ext._HEALTH_INIT,
			variant = "melee",
			attacker_unit = my_unit,
			attack_dir = attack_dir,
			col_ray = {
				position = mvec3_cpy(target_com),
				body = target_unit:body("body"),
				ray = attack_dir
			}
		}

		local defense_data = target_dmg_ext:damage_melee(attack_data)

		if defense_data and defense_data ~= "friendly_fire" then
			if defense_data == "countered" then
				spooc_res = "countered"
			else
				self._beating_end_t = 0

				if type_g(defense_data) == "table" and defense_data.type == "death" then
					local hit_pos = attack_data.col_ray.position

					managers.game_play_central:do_shotgun_push(target_unit, hit_pos, attack_dir, distance, my_unit)
					managers.game_play_central:do_shotgun_push(target_unit, hit_pos, attack_dir, distance, my_unit)
				end
			end
		end
	end

	if not spooc_res then
		--local line2 = Draw:brush(Color.red:with_alpha(0.5), 1)
		--line2:sphere(ext_mov:m_head_pos(), 30)

		return
	end

	if spooc_res == "countered" then
		if not self._is_server then
			self:_send_stop()
		end

		self._blocks = {}

		local my_com = ext_mov:m_com()
		local from_pos = target_mov_ext:m_head_pos()
		local attack_dir = ext_mov:m_com() - from_pos
		mvec3_norm(attack_dir)

		local melee_weapon_id = target_base_ext.is_local_player and managers.blackmarket:equipped_melee_weapon() or target_base_ext.melee_weapon and target_base_ext:melee_weapon() or nil
		local counter_data = {
			damage_effect = 1,
			damage = 0,
			variant = "counter_spooc",
			attacker_unit = target_unit,
			attack_dir = attack_dir,
			col_ray = {
				position = mvec3_cpy(my_com),
				body = my_unit:body("body"),
				ray = attack_dir
			},
			name_id = melee_weapon_id
		}

		my_unit:character_damage():damage_melee(counter_data)

		return
	elseif target_dmg_ext:is_downed() or target_dmg_ext:arrested() then
		self._strike_unit = target_unit

		if target_base_ext.is_local_player then
			self:_play_strike_camera_shake()
			mvec3_negate(target_vec)

			local dot_fwd = target_vec:dot(my_fwd)
			local dot_r = target_vec:dot(common_data.right)

			if math_abs(dot_r) < math_abs(dot_fwd) then
				if dot_fwd > 0 then
					managers.environment_controller:hit_feedback_front()
				else
					managers.environment_controller:hit_feedback_back()
				end
			elseif dot_r > 0 then
				managers.environment_controller:hit_feedback_right()
			else
				managers.environment_controller:hit_feedback_left()
			end
		end

		if flying_strike and not kick_after_landing then
			local taa_sound = self._taunt_after_assault

			if taa_sound then
				my_unit:sound():say(taa_sound, true, true)
			end
		end
	end
end

function ActionSpooc.chk_can_start_spooc_sprint(unit, target_unit)
	local is_client = Network:is_client()
	local ext_mov = unit:movement()
	local target_mov_ext = target_unit:movement()
	local client_my_head_pos, client_target_head_pos = nil

	if is_client then
		client_my_head_pos = ext_mov:m_head_pos()
		client_target_head_pos = target_mov_ext:m_head_pos()

		local target_dis = mvec3_dis(client_my_head_pos:with_z(client_target_head_pos.z), client_target_head_pos)

		if target_dis > 2500 then
			return
		end
	end

	local my_pos = ext_mov:m_pos()
	local my_fwd = ext_mov:m_fwd()
	local target_pos = target_mov_ext:m_pos()
	local target_vec = target_pos - my_pos
	local dot = target_vec:with_z(0):normalized():dot(my_fwd)

	if dot < 0.6 then
		return
	end

	local my_tracker = ext_mov:nav_tracker()
	local enemy_tracker = target_mov_ext:nav_tracker()
	local ray_params = {
		allow_entry = true,
		trace = true
	}

	if my_tracker:lost() then
		ray_params.pos_from = my_tracker:field_position()
	else
		ray_params.tracker_from = my_tracker
	end

	if enemy_tracker:lost() then
		ray_params.pos_to = enemy_tracker:field_position()
	else
		ray_params.tracker_to = enemy_tracker
	end

	local nav_collision = managers.navigation:raycast(ray_params)

	if nav_collision then
		return
	end

	local z_diff_abs = math_abs(ray_params.trace[1].z - target_pos.z)

	if z_diff_abs > 200 then
		return
	end

	local ray_from = math_up:with_z(120)
	local ray_to = ray_from + target_pos
	ray_from = ray_from + my_pos

	local slot_mask = managers.slot:get_mask("AI_graph_obstacle_check")
	local ray = unit:raycast("ray", ray_from, ray_to, "slot_mask", slot_mask, "ray_type", "walk", "report")

	if ray then
		return
	end

	if is_client then
		slot_mask = managers.slot:get_mask("bullet_impact_targets_no_criminals")
		ray = unit:raycast("ray", client_my_head_pos, client_target_head_pos, "slot_mask", slot_mask, "ignore_unit", target_unit, "report")

		if ray then
			return
		end
	end

	return true
end

function ActionSpooc.chk_can_start_flying_strike(unit, target_unit)
	local ext_mov = unit:movement()
	local my_pos = ext_mov:m_pos()
	local target_pos = target_unit:movement():m_pos()
	local target_vec = target_pos - my_pos
	target_vec = target_vec:with_z(0)

	local target_dis = target_vec:length()

	if target_dis > 600 then
		return
	end

	local my_fwd = ext_mov:m_fwd()
	local dot = target_vec:normalized():dot(my_fwd)

	if dot < 0.6 then
		return
	end

	local ray_from = my_pos:with_z(my_pos.z + 160)
	local ray_to = target_pos:with_z(target_pos.z + 160)
	mvec3_lerp(ray_to, ray_from, ray_to, 0.5)
	ray_to = ray_to:with_z(ray_to.z + 50)

	local sphere_radius, slot_mask = 25, managers.slot:get_mask("AI_graph_obstacle_check")
	local ray = unit:raycast("ray", ray_from, ray_to, "sphere_cast_radius", sphere_radius, "bundle", 5, "slot_mask", slot_mask, "ray_type", "walk", "report")

	if ray then
		return
	end

	ray_from = target_pos:with_z(target_pos.z + 160)
	ray = unit:raycast("ray", ray_from, ray_to, "sphere_cast_radius", sphere_radius, "bundle", 5, "slot_mask", slot_mask, "ray_type", "walk", "report")

	if ray then
		return
	end

	return true
end

function ActionSpooc:_upd_flying_strike_first_frame(t)
	if self._queued_kick_after_landing then
		self._kick_after_landing = true
	end

	local is_local = self._is_local

	if is_local and self:_chk_target_invalid() then
		if self._is_server then
			self:_expire()
		else
			self:_send_stop()
			self:_wait()
		end

		return
	end

	if self._joker_vis_mask and self:check_joker_counter(t) then
		return
	end

	local path, target_pos = self._nav_path

	if is_local then
		target_pos = self._target_unit:movement():m_pos()
		path[#path + 1] = mvec3_cpy(target_pos)

		self:_send_nav_point(mvec3_cpy(target_pos))
	else
		target_pos = path[#path]
	end

	self._nav_path = path

	local ext_mov = self._ext_movement
	local my_pos = self._common_data.pos
	local target_vec = target_pos - my_pos
	--local target_dis = target_vec:length()
	target_vec = target_vec:with_z(0)

	local action_desc = self._action_desc
	local drop_in_t = action_desc.start_anim_time
	local redir_result, travel_scaling = nil

	if drop_in_t then
		travel_scaling = action_desc.travel_scaling

		local start_anim_idx = action_desc.start_anim_idx
		local state_name = self._machine:index_to_state_name(start_anim_idx)

		redir_result = ext_mov:play_state_idstr(state_name, drop_in_t)

		if redir_result then
			ext_mov:set_position(my_pos:with_z(action_desc.pos_z))

			action_desc.start_anim_time = nil
			action_desc.start_anim_idx = nil
			action_desc.travel_scaling = nil
			action_desc.pos_z = nil
		end
	else
		redir_result = ext_mov:play_redirect("spooc_flying_strike")

		if redir_result then
			local anim_travel_dis_xy = 470

			travel_scaling = target_vec:length() / anim_travel_dis_xy
			--travel_scaling = target_dis / anim_travel_dis_xy
		end
	end

	if not redir_result then
		return
	end

	if not self._stroke_t then
		self:_check_sounds_and_lights_state(true)
	end

	self._flying_geometry_mask = managers.slot:get_mask("world_geometry")
	self._flying_strike_data = {
		start_rot = self._unit:rotation(),
		--target_rot = Rotation(target_vec:with_z(0):normalized(), math_up),
		target_rot = Rotation(target_vec:normalized(), math_up),
		travel_dis_scaling_xy = travel_scaling,
		target_pos_z = mvec3_z(target_pos)
	}

	local dis_lerp = travel_scaling > 1 and 1 or travel_scaling
	local speed_mul = math_lerp(3, 1, dis_lerp)

	self._machine:set_speed(redir_result, speed_mul)

	self:_set_updator("_upd_flying_strike")
end

function ActionSpooc:_upd_flying_strike(t)
	if self._joker_vis_mask and self:check_joker_counter(t) then
		return
	end

	local common_data = self._common_data
	local cur_pos = common_data.pos
	local ext_mov = self._ext_movement

	if self._ext_anim.act then
		local seg_rel_t = self._machine:segment_relative_time(ids_base)
		local strike_data = self._flying_strike_data

		if not strike_data.is_rot_aligned then
			local rot_correction_period = 0.07

			if seg_rel_t < rot_correction_period then
				local prog = seg_rel_t / rot_correction_period
				local prog_smooth = math_bezier(bezier_curve, prog)

				ext_mov:set_rotation(strike_data.start_rot:slerp(strike_data.target_rot, prog_smooth))
			else
				ext_mov:set_rotation(strike_data.target_rot)

				strike_data.is_rot_aligned = true
			end
		end

		local my_unit = self._unit
		local delta_pos = my_unit:get_animation_delta_position()
		local xy_scaling = strike_data.travel_dis_scaling_xy

		local delta_z = delta_pos.z
		local z_adjust = delta_z + cur_pos.z
		z_adjust = z_adjust - strike_data.target_pos_z

		if z_adjust ~= 0 then
			if z_adjust > 0 then --target pos is below
				if seg_rel_t > 0.5 then
					z_adjust = z_adjust > 10 and 10 or z_adjust
					delta_z = delta_z - z_adjust
				end
			elseif seg_rel_t > 0.1 then
				z_adjust = -z_adjust
				z_adjust = z_adjust > 15 and 15 or z_adjust
				delta_z = delta_z + z_adjust
			end
		end

		mvec3_set_stat(delta_pos, delta_pos.x * xy_scaling, delta_pos.y * xy_scaling, delta_z)
		--mvec3_set_stat(delta_pos, delta_pos.x * xy_scaling, delta_pos.y * xy_scaling, delta_pos.z)

		local new_pos = cur_pos + delta_pos
		local stroke = self._stroke_t

		if not stroke then
			local geometry_collision = my_unit:raycast("ray", cur_pos, new_pos, "sphere_cast_radius", 25, "slot_mask", self._flying_geometry_mask, "report")

			if geometry_collision then
				mvec3_set_stat(new_pos, cur_pos.x, cur_pos.y, new_pos.z)
			end
		else
			local my_tracker = self._my_tracker

			if not my_tracker:lost() then
				local ray_params = {
					tracker_from = my_tracker,
					pos_to = new_pos
				}

				if managers.navigation:raycast(ray_params) then
					mvec3_set_stat(new_pos, cur_pos.x, cur_pos.y, new_pos.z)
				end
			end
		end

		ext_mov:upd_ground_ray(new_pos, true)

		local gnd_z = common_data.gnd_ray.position.z

		if gnd_z < new_pos.z then
			if stroke then
				self._last_vel_z = self._apply_freefall(new_pos, self._last_vel_z, gnd_z, self._timer:delta_time())
			end
		elseif gnd_z > new_pos.z then
			new_pos = new_pos:with_z(gnd_z)
		end

		mvec3_set(self._last_pos, new_pos)

		ext_mov:set_position(new_pos)
	else
		local my_tracker = self._my_tracker
		local new_pos = self._tmp_vec1
		mvec3_set(new_pos, cur_pos)

		if not my_tracker:lost() then
			--[[if cur_pos.z < self._flying_strike_data.target_pos_z then
				local field_pos = my_tracker:field_position()

				mvec3_set_stat(new_pos, field_pos.x, field_pos.y, new_pos.z)
			end
		else]]
			local ray_params = {
				tracker_from = my_tracker,
				pos_to = new_pos
			}

			if managers.navigation:raycast(ray_params) then
				mvec3_set_stat(new_pos, cur_pos.x, cur_pos.y, new_pos.z)
			end
		end

		ext_mov:upd_ground_ray(new_pos, true)

		local gnd_z = common_data.gnd_ray.position.z

		if gnd_z < new_pos.z then
			self._last_vel_z = self._apply_freefall(new_pos, self._last_vel_z, gnd_z, self._timer:delta_time())
		else
			if gnd_z > new_pos.z then
				new_pos = new_pos:with_z(gnd_z)
			end

			self._last_vel_z = 0
			self._beating_end_t = 0

			if self._is_local then
				local target_unit = nil

				if not self._strike_unit then
					local cur_target = self._target_unit

					if cur_target and alive_g(cur_target) then
						target_unit = cur_target
					end
				end

				if target_unit and self:_chk_invalid_beating_unit_status(target_unit) then
					mvec3_set(self._last_pos, new_pos)

					ext_mov:set_position(new_pos)

					if self:_chk_can_strike() then
						ext_mov:play_redirect("stand")

						self._kick_after_landing = true
						self._beating_end_t = nil

						self:_strike()
					elseif self._is_server then
						self:_expire()
					else
						self:_send_stop()
						self:_wait()
					end

					return
				elseif self._is_server then
					self:_expire()
				else
					self:_send_stop()
					self:_wait()
				end

				self._action_completed = true
			else
				self:_wait()
			end
		end

		mvec3_set(self._last_pos, new_pos)

		ext_mov:set_position(new_pos)
	end
end

function ActionSpooc:get_sound_event(sound)
	local sound_events = self._common_data.char_tweak.spooc_sound_events

	if not sound_events then
		return
	end

	local event = nil

	if self._using_christmas_sounds then
		local christmas_events = {
			detect_stop = "cloaker_detect_christmas_stop",
			detect = "cloaker_detect_christmas_mono"
		}
		event = christmas_events[sound]
	end

	event = event or sound_events[sound]

	return event
end

function ActionSpooc:_check_sounds_and_lights_state(state, is_dead)
	local my_unit = self._unit

	if self._was_interrupted then
		if is_dead then
			local detect_stop_sound = self:get_sound_event("detect_stop")

			if detect_stop_sound then
				my_unit:sound():play(detect_stop_sound)
			end
		end

		return
	end

	if state then
		if not self._chk_detect_sound_and_lights then
			local detect_sound = self:get_sound_event("detect")

			if detect_sound then
				my_unit:sound():play(detect_sound)
			end

			--lights are permanent here, leaving this in case that gets changed later
			--[[local u_dmg = my_unit:damage()

			if u_dmg and u_dmg:has_sequence("turn_on_spook_lights") then
				u_dmg:run_sequence_simple("turn_on_spook_lights")
			end]]

			self._chk_detect_sound_and_lights = true
		end
	elseif self._chk_detect_sound_and_lights then
		if is_dead then
			local detect_stop_sound = self:get_sound_event("detect_stop")

			if detect_stop_sound then
				my_unit:sound():play(detect_stop_sound)
			end
		else
			local spawn_sound_event = self._common_data.char_tweak.spawn_sound_event

			if spawn_sound_event then
				my_unit:sound():play(spawn_sound_event)
			end
		end

		--lights are permanent here, leaving this in case that gets changed later
		--[[local u_dmg = my_unit:damage()

		if u_dmg and u_dmg:has_sequence("kill_spook_lights") then
			u_dmg:run_sequence_simple("kill_spook_lights")
		end]]
	end
end

function ActionSpooc:_get_current_max_walk_speed(move_dir)
	if move_dir == "l" or move_dir == "r" then
		move_dir = "strafe"
	end

	local speed = self._common_data.char_tweak.move_speed[self._ext_anim.pose][self._haste][self._stance.name][move_dir]
	local speed_modifier = self._ext_movement:speed_modifier()

	if speed_modifier ~= 1 then
		speed = speed * speed_modifier
	end

	if self._was_interrupted or not self._is_local and self:_needs_speedup() then
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

		speed = speed * vis_mul
	end

	return speed
end

function ActionSpooc:_needs_speedup()
	local queued_actions = self._ext_movement._queued_actions

	--unit has already started another action on the server side
	--but is temporarily blocked here, need to catch up immediately
	if queued_actions and next_g(queued_actions) then
		return true
	end

	local chase_path = self._nav_path

	--unit still has to go through 3 or more nav_points that were synced
	if chase_path[3] then
		local dis_error_total = 0
		local prev_pos = self._common_data.pos

		--get the sum of the distance between the one the unit is moving to + the rest of them
		for i = 2, #chase_path do
			local next_pos = chase_path[i]
			dis_error_total = dis_error_total + mvec3_dis_sq(prev_pos, next_pos)
			prev_pos = next_pos
		end

		--total distance exceeds 9 square meters, speed up until this is no longer true
		if dis_error_total > 90000 then
			return true
		end
	end
end

function ActionSpooc:check_joker_counter(t)
	local last_t_check = self._last_joker_counter_chk_t

	if last_t_check and t < last_t_check then
		return
	end

	self._last_joker_counter_chk_t = t + 0.2

	local target_unit = self._target_unit

	if not alive_g(target_unit) then
		return
	end

	local my_unit = self._unit
	local closest_dis, closest_minion_data = 500, {}
	local record = managers.groupai:state():criminal_record(target_unit:key())
	local minions = record and record.minions

	if minions then
		local ext_mov = self._ext_movement
		local my_pos = ext_mov:m_pos()
		local my_head_pos = ext_mov:m_head_pos()
		local vis_mask = self._joker_vis_mask

		--[[local nav_manager = managers.navigation
		local nav_ray_f = nav_manager.raycast

		local my_tracker = self._common_data.nav_tracker
		local ray_params = {
			allow_entry = false
		}

		if my_tracker:lost() then
			ray_params.pos_to = my_tracker:field_position()
		else
			ray_params.tracker_to = my_tracker
		end]]

		for key, u_data in pairs_g(minions) do
			local minion_unit = u_data.unit
			local minion_mov_ext = minion_unit:movement()

			if not minion_mov_ext:joker_counter_on_cooldown() and not minion_mov_ext:chk_action_forbidden("walk") then
				local vec = my_pos - u_data.m_pos
				local dis = vec:length()

				if dis < closest_dis then
					local obstructed = minion_unit:raycast("ray", minion_mov_ext:m_head_pos(), my_head_pos, "slot_mask", vis_mask, "ray_type", "ai_vision")

					if not obstructed then
						--[[local minion_tracker = minion_mov_ext:nav_tracker()

						if minion_tracker:lost() then
							ray_params.pos_from = minion_tracker:field_position()
							ray_params.tracker_from = nil
						else
							ray_params.tracker_from = minion_tracker
							ray_params.pos_from = nil
						end

						if not nav_ray_f(nav_manager, ray_params) then]]
							closest_dis = dis
							closest_minion_data.unit = minion_unit
							closest_minion_data.vec = vec
						--end
					end
				end
			end
		end
	end

	local found_minion = closest_minion_data.unit

	if not found_minion then
		return
	end

	self._blocks = {}

	local tackle_dir = closest_minion_data.vec:with_z(0):normalized()

	return CopActionTase.execute_tackle_counter(self, found_minion, tackle_dir)
end
