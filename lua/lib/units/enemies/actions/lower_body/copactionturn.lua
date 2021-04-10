local mrot_lookat = mrotation.set_look_at
local tmp_rot = Rotation()

local math_abs = math.abs
local math_up = math.UP

function CopActionTurn:init(action_desc, common_data)
	local ext_mov = common_data.ext_movement
	local ext_anim = common_data.ext_anim

	if not ext_anim.idle and not ext_mov:play_redirect("idle") then
		return false --the redirect shouldn't fail unless something related to animations is messed up
	end

	self._common_data = common_data
	self._action_desc = action_desc
	self._ext_anim = ext_anim
	self._ext_movement = ext_mov
	self._ext_base = common_data.ext_base

	local machine = common_data.machine
	self._machine = machine

	local turn_speed_mul = 1
	self._turn_speed_mul = turn_speed_mul --also used on the animation itself

	local turn_step_mul = machine:get_global("shield") == 1 and 1 or 0.75
	self._dt_turn_adj = 5 * turn_step_mul * turn_speed_mul

	local end_angle = action_desc.angle
	self._end_angle = end_angle
	self._turn_left = end_angle > 0

	local fwd_polar = common_data.fwd:to_polar()
	local end_dir = fwd_polar:with_spin(fwd_polar.spin + end_angle):to_vector()
	self._end_dir = end_dir

	local end_rot = Rotation()
	mrot_lookat(end_rot, end_dir, math_up)
	self._end_rot = end_rot

	self.update = self["_upd_wait_full_blend"]
	ext_mov:enable_update()

	CopActionAct._create_blocks_table(self, action_desc.blocks)

	return true
end

function CopActionTurn:on_exit()
	if self._ext_anim.turn then
		self._ext_movement:play_redirect("idle")
	end
end

function CopActionTurn:update(t)
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

	local ext_anim = self._ext_anim
	local ext_mov = self._ext_movement
	local end_dir = self._end_dir
	local delta_lerp = dt * self._dt_turn_adj
	delta_lerp = delta_lerp > 1 and 1 or delta_lerp

	local end_rot = self._end_rot
	local new_rot = self._common_data.rot:slerp(end_rot, delta_lerp)
	local new_fwd = new_rot:y()

	if new_fwd:dot(end_dir) < 0.98 then
		ext_mov:set_rotation(new_rot)

		if not self._no_turn_animation and not ext_anim.turn and ext_anim.idle_full_blend then
			self:play_new_turn_anim(end_dir, new_fwd)
		end
	else
		ext_mov:set_rotation(end_rot)

		if ext_anim.turn then
			ext_mov:play_redirect("idle")
		end

		self.update = self["_upd_empty"]
		self._expired = true
	end

	if ext_anim.base_need_upd then
		ext_mov:upd_m_head_pos()
	end
end

function CopActionTurn:play_new_turn_anim(end_dir, new_fwd)
	local dir_str = self._turn_left and "l" or "r"
	local redir_name = "turn_" .. dir_str
	local redir_res = self._ext_movement:play_redirect(redir_name)

	if not redir_res then --if this happens somehow, stop attempting to play a turn animation
		self._no_turn_animation = true

		self._ext_base:chk_freeze_anims()

		return
	end

	local machine = self._machine
	local abs_angle = math_abs(end_dir:to_polar_with_reference(new_fwd, math_up).spin)

	if abs_angle > 135 then
		machine:set_parameter(redir_res, "angle135", 1)
	elseif abs_angle > 90 then
		local lerp = (abs_angle - 90) / 45

		machine:set_parameter(redir_res, "angle135", lerp)
		machine:set_parameter(redir_res, "angle90", 1 - lerp)
	elseif abs_angle > 45 then
		local lerp = (abs_angle - 45) / 45

		machine:set_parameter(redir_res, "angle90", lerp)
		machine:set_parameter(redir_res, "angle45", 1 - lerp)
	else
		machine:set_parameter(redir_res, "angle45", 1)
	end

	local turn_speed_mul = self._turn_speed_mul

	if turn_speed_mul ~= 1 then
		machine:set_speed(redir_res, turn_speed_mul)
	end

	self._ext_base:chk_freeze_anims()
end

function CopActionTurn:_upd_wait_full_blend(t)
	if not self._ext_anim.idle_full_blend then --start updating immediately, don't bother waiting to be able to play the animation
		self._ext_base:chk_freeze_anims()

		self._timer = TimerManager:game()

		self._last_upd_t = self._timer:time() - 0.001
		self._skipped_frames = 1

		self.update = self[nil]
		self:update(t)

		return
	end

	local dir_str = self._turn_left and "l" or "r"
	local redir_name = "turn_" .. dir_str
	local redir_res = self._ext_movement:play_redirect(redir_name)

	if not redir_res then --if this happens somehow, stop attempting to play a turn animation
		self._no_turn_animation = true

		self._ext_base:chk_freeze_anims()

		self._timer = TimerManager:game()

		self._last_upd_t = self._timer:time() - 0.001
		self._skipped_frames = 1

		self.update = self[nil]
		self:update(t)

		return
	end

	local machine = self._machine
	local abs_angle = math_abs(self._end_angle)

	if abs_angle > 135 then
		machine:set_parameter(redir_res, "angle135", 1)
	elseif abs_angle > 90 then
		local lerp = (abs_angle - 90) / 45

		machine:set_parameter(redir_res, "angle135", lerp)
		machine:set_parameter(redir_res, "angle90", 1 - lerp)
	elseif abs_angle > 45 then
		local lerp = (abs_angle - 45) / 45

		machine:set_parameter(redir_res, "angle90", lerp)
		machine:set_parameter(redir_res, "angle45", 1 - lerp)
	else
		machine:set_parameter(redir_res, "angle45", 1)
	end

	local turn_speed_mul = self._turn_speed_mul

	if turn_speed_mul ~= 1 then
		machine:set_speed(redir_res, turn_speed_mul)
	end

	self._ext_base:chk_freeze_anims()

	self._timer = TimerManager:game()

	self._last_upd_t = self._timer:time() - 0.001
	self._skipped_frames = 1

	self.update = self[nil]
	self:update(t)
end

function CopActionTurn:_upd_empty(t)
end
