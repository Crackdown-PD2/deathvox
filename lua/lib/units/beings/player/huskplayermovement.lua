local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_z = mvector3.z
local mvec3_cpy = mvector3.copy
local mvec3_dist_sq = mvector3.distance_sq
local mvec3_lerp = mvector3.lerp
local mvec3_add = mvector3.add
local mvec3_sub = mvector3.subtract
local mvec3_mul = mvector3.multiply

local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()

local mrot_look = mrotation.set_look_at

local math_up = math.UP
local math_clamp = math.clamp
local math_point_on_line = math.point_on_line
local math_lerp = math.lerp
local math_random = math.random

local table_insert = table.insert
local table_remove = table.remove

local left_hand_str = Idstring("LeftHandMiddle2")
local right_hand_str = Idstring("RightHandMiddle2")

local post_init_original = HuskPlayerMovement.post_init
function HuskPlayerMovement:post_init()
	post_init_original(self)
	self._attention_handler:setup_attention_positions(self._m_detect_pos, self._m_newest_pos)
end

function HuskPlayerMovement:m_pos()
	return self._m_newest_pos
end

function HuskPlayerMovement:m_head_pos()
	return self._m_detect_pos
end

local init_original = HuskPlayerMovement.init
function HuskPlayerMovement:init(unit)

	self._stand_detection_offset_z = mvec3_z(tweak_data.player.stances.default.standard.head.translation)

	init_original(self, unit)
end

function HuskPlayerMovement:_calculate_m_pose()
	mrot_look(self._m_head_rot, self._look_dir, math_up)
	self._obj_head:m_position(self._m_head_pos)
end

function HuskPlayerMovement:sync_action_walk_nav_point(pos, speed, action, params)
	if pos then
		self:_update_real_pos(pos)
	end

	speed = speed or 1
	params = params or {}
	self._movement_path = self._movement_path or {}
	self._movement_history = self._movement_history or {}
	local path_len = #self._movement_path

	if not pos then
		if path_len <= 0 or self._movement_path[path_len].pos then
			pos = mvec3_cpy(self._m_pos)
		end
	end

	if Network:is_server() then
		if not self._pos_reservation then
			self._pos_reservation = {
				radius = 100,
				position = mvec3_cpy(pos),
				filter = self._pos_rsrv_id
			}
			self._pos_reservation_slow = {
				radius = 100,
				position = mvec3_cpy(pos),
				filter = self._pos_rsrv_id
			}

			managers.navigation:add_pos_reservation(self._pos_reservation)
			managers.navigation:add_pos_reservation(self._pos_reservation_slow)
		else
			self._pos_reservation.position = mvec3_cpy(pos)

			managers.navigation:move_pos_rsrv(self._pos_reservation)
			self:_upd_slow_pos_reservation()
		end
	end

	local can_add = true

	if not params.force and path_len > 0 then
		local last_node = self._movement_path[path_len]

		if last_node then
			local dist_sq = mvec3_dist_sq(pos, last_node.pos)
			can_add = dist_sq > 4
		end
	end

	if can_add then
		local on_ground = self:_chk_ground_ray(pos)
		local type = "ground"

		if self._zipline and self._zipline.enabled then
			type = "zipline"
		elseif not on_ground then
			type = "air"
		end

		local prev_node = self._movement_history[#self._movement_history]

		if type == "ground" and prev_node and self:action_is(prev_node.action, "jump") then
			type = "air"
		end

		if type == "ground" then
			local ground_z = self:_chk_floor_moving_pos()

			if ground_z then
				mvec3_set_z(pos, ground_z)
			end
		end

		local node = {
			pos = pos,
			speed = speed,
			type = type,
			action = {
				action
			}
		}

		table_insert(self._movement_path, node)
		table_insert(self._movement_history, node)

		if not params.force then
			local len = #self._movement_history

			if len > 1 then
				self:_determine_node_action(#self._movement_history, node)
			end
		end

		for i = 1, #self._movement_history - tweak_data.network.player_path_history do
			table_remove(self._movement_history, 1)
		end

		if params.execute and #self._movement_path <= tweak_data.network.player_path_interpolation then
			self:force_start_moving()
		end
	end
end

--local draw_sync_player_newest_pos = nil
--local draw_sync_player_detect_pos = nil

function HuskPlayerMovement:_update_real_pos(new_pos, new_pose_code)
	local newest_pos = self._m_newest_pos
	local detect_pos = self._m_detect_pos
	local stand_pos = self._m_stand_pos

	mvec3_set(newest_pos, new_pos)
	mvec3_set(detect_pos, new_pos)
	mvec3_set(stand_pos, new_pos)
	mvec3_set_z(stand_pos, new_pos.z + 140)

	local offset_z = nil

	if new_pose_code and new_pose_code == 2 or self._pose_code == 2 then
		offset_z = self._crouch_detection_offset_z
	else
		offset_z = self._stand_detection_offset_z
	end

	mvec3_set_z(detect_pos, detect_pos.z + offset_z)

	local m_com = self._m_com
	mvec3_lerp(m_com, newest_pos, detect_pos, 0.5)

	if self._nav_tracker then
		self._nav_tracker:move(new_pos)

		local nav_seg_id = self._nav_tracker:nav_segment()

		if self._standing_nav_seg_id ~= nav_seg_id then
			self._standing_nav_seg_id = nav_seg_id
			local metadata = managers.navigation:get_nav_seg_metadata(nav_seg_id)

			self._unit:base():set_suspicion_multiplier("area", metadata.suspicion_mul)
			self._unit:base():set_detection_multiplier("area", metadata.detection_mul and 1 / metadata.detection_mul or nil)
			managers.groupai:state():on_criminal_nav_seg_change(self._unit, nav_seg_id)
		end
	end

	--[[if draw_sync_player_newest_pos then
		local m_brush = Draw:brush(Color.blue:with_alpha(0.5), 0.1)
		m_brush:sphere(newest_pos, 15)
	end

	if draw_sync_player_detect_pos then
		local head_brush = Draw:brush(Color.yellow:with_alpha(0.5), 0.1)
		head_brush:sphere(detect_pos, 15)
	end]]
end

local _sync_movement_state_driving_original = HuskPlayerMovement._sync_movement_state_driving
function HuskPlayerMovement:_sync_movement_state_driving(...)
	_sync_movement_state_driving_original(self, ...)

	local seat = self.seat_third

	if not seat then
		return
	end

	self:_update_real_pos(seat:position())
end

function HuskPlayerMovement:_upd_move_driving(t, dt)
	local seat = self.seat_third
	local seat_pos = seat:position()

	self:set_position(seat_pos)
	self:set_rotation(seat:rotation())

	self:_update_real_pos(seat_pos)
end

local _upd_move_zipline_original = HuskPlayerMovement._upd_move_zipline
function HuskPlayerMovement:_upd_move_zipline(t, dt)
	_upd_move_zipline_original(self, t, dt)

	if self._load_data then
		return
	end

	self:_update_real_pos(self._unit:position())
end

function HuskPlayerMovement:set_position(pos)
	mvec3_set(self._m_pos, pos)
	self._unit:set_position(pos)
end

function HuskPlayerMovement:sync_action_change_pose(pose_code, pos)
	self._desired_pose_code = pose_code
	self:_update_real_pos(pos, pose_code)
end

function HuskPlayerMovement:_update_air_time(t, dt)
	if self._in_air then
		self._air_time = self._air_time or 0
		self._air_time = self._air_time + dt

		if self._air_time > 1 then
			local on_ground = self:_chk_ground_ray(self._m_pos)

			if on_ground then
				self._in_air = false
				self._air_time = 0
			end
		end
	else
		self._air_time = 0
	end
end

function HuskPlayerMovement:_update_zipline_sled(t, dt)
	if self._zipline and self._zipline.attached then
		local zipline = self._zipline and self._zipline.zipline_unit and self._zipline.zipline_unit:zipline()

		if zipline then
			local closest_pos = math_point_on_line(zipline:start_pos(), zipline:end_pos(), self._m_pos)
			local distance = (zipline:start_pos() - closest_pos):length()
			local length = (zipline:start_pos() - zipline:end_pos()):length()
			local t = distance / length

			zipline:update_and_get_pos_at_time_linear(math_clamp(t, 0, 1))
		end
	end
end

function HuskPlayerMovement:anim_clbk_spawn_dropped_magazine()
	if not self:allow_dropped_magazines() then
		return
	end

	local equipped_weapon = self._unit:inventory():equipped_unit()

	if alive(equipped_weapon) and not equipped_weapon:base()._assembly_complete then
		return
	end

	local ref_unit = nil
	local allow_throw = true

	if not self._magazine_data then
		local w_td_crew = self:_equipped_weapon_crew_tweak_data()

		if not w_td_crew or not w_td_crew.pull_magazine_during_reload then
			return
		end

		self:anim_clbk_show_magazine_in_hand()

		if not self._magazine_data then
			return
		elseif not alive(self._magazine_data.unit) then
			self._magazine_data = nil

			return
		end

		local attach_bone = nil

		if not self._primary_hand or self._primary_hand == 0 then
			attach_bone = left_hand_str
		else
			attach_bone = right_hand_str
		end

		local bone_hand = self._unit:get_object(attach_bone)

		if bone_hand then
			mvec3_set(tmp_vec1, self._magazine_data.unit:position())
			mvec3_sub(tmp_vec1, self._magazine_data.unit:oobb():center())
			mvec3_add(tmp_vec1, bone_hand:position())
			self._magazine_data.unit:set_position(tmp_vec1)
		end

		ref_unit = self._magazine_data.part_unit
		allow_throw = false
	end

	if self._magazine_data and alive(self._magazine_data.unit) then
		ref_unit = ref_unit or self._magazine_data.unit

		self._magazine_data.unit:set_visible(false)

		local pos = ref_unit:position()
		local rot = ref_unit:rotation()
		local dropped_mag = self:_spawn_magazine_unit(self._magazine_data.id, self._magazine_data.name, pos, rot)

		self:_set_unit_bullet_objects_visible(dropped_mag, self._magazine_data.bullets, false)

		local mag_size = self._magazine_data.weapon_data.pull_magazine_during_reload

		if type(mag_size) ~= "string" then
			mag_size = "medium"
		end

		mvec3_set(tmp_vec1, ref_unit:oobb():center())
		mvec3_sub(tmp_vec1, pos)
		mvec3_set(tmp_vec2, pos)
		mvec3_add(tmp_vec2, tmp_vec1)

		local dropped_col = World:spawn_unit(HuskPlayerMovement.magazine_collisions[mag_size][1], tmp_vec2, rot)

		dropped_col:link(HuskPlayerMovement.magazine_collisions[mag_size][2], dropped_mag)

		if allow_throw then
			if self._left_hand_direction then
				local throw_force = 10

				mvec3_set(tmp_vec1, self._left_hand_direction)
				mvec3_mul(tmp_vec1, self._left_hand_velocity or 3)
				mvec3_mul(tmp_vec1, math_random(25, 45))
				mvec3_mul(tmp_vec1, -1)
				dropped_col:push(throw_force, tmp_vec1)
			end
		else
			local throw_force = 10
			local _t = (self._reload_speed_multiplier or 1) - 1

			mvec3_set(tmp_vec1, equipped_weapon:rotation():z())
			mvec3_mul(tmp_vec1, math_lerp(math_random(65, 80), math_random(140, 160), _t))
			mvec3_mul(tmp_vec1, math_random() < 0.0005 and 10 or -1)
			dropped_col:push(throw_force, tmp_vec1)
		end

		managers.enemy:add_magazine(dropped_mag, dropped_col)
	end
end

--[[local draw_player_newest_pos = nil
local draw_player_detect_pos = nil

local update_original = HuskPlayerMovement.update
function HuskPlayerMovement:update(unit, t, dt)
	update_original(self, unit, t, dt)

	if not self:_has_finished_loading() then
		return
	end

	if draw_player_newest_pos then
		local m_brush = Draw:brush(Color.blue:with_alpha(0.5), 0.1)
		m_brush:sphere(self._m_newest_pos, 15)
	end

	if draw_player_detect_pos then
		local head_brush = Draw:brush(Color.yellow:with_alpha(0.5), 0.1)
		head_brush:sphere(self._m_detect_pos, 15)
	end
end]]
