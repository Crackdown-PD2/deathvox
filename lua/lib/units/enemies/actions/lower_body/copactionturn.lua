local mrot_set = mrotation.set_yaw_pitch_roll
local mrot_lookat = mrotation.set_look_at
local tmp_rot = Rotation()

local math_abs = math.abs
local math_up = math.UP
local math_step = math.step

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

	self._dt_turn_adj = 180

	local end_angle = action_desc.angle
	self._end_angle = end_angle

	local turn_left = end_angle > 0
	self._turn_left = turn_left

	local fwd_polar = common_data.fwd:to_polar()
	self._end_dir = fwd_polar:with_spin(fwd_polar.spin + end_angle):to_vector()

	self.update = self["_upd_wait_full_blend"]
	ext_mov:enable_update()

	CopActionAct._create_blocks_table(self, action_desc.blocks)

	return true
end

function CopActionTurn:on_exit()
	if self._expired and self._ext_anim.turn then
		self._ext_movement:play_redirect("idle")
	end
end

function CopActionTurn:update(t)
	local ext_anim = self._ext_anim
	local ext_mov = self._ext_movement
	local my_fwd = self._common_data.fwd
	local end_dir = self._end_dir

	local dt = self._timer:delta_time()
	local end_angle = self._end_angle
	local spin_adj = math_step(0, end_angle, self._dt_turn_adj * dt)

	mrot_set(tmp_rot, spin_adj, 0, 0)

	local wanted_u_fwd = my_fwd:rotate_with(tmp_rot)
	mrot_lookat(tmp_rot, wanted_u_fwd, math_up)

	local angle_diff = math_abs(wanted_u_fwd:angle(end_dir))

	if angle_diff < 5 then
		mrot_lookat(tmp_rot, end_dir, math_up)
		ext_mov:set_rotation(tmp_rot)

		self.update = self["_upd_empty"]
		self._expired = true
	else
		ext_mov:set_rotation(tmp_rot)
	end

	if ext_anim.base_need_upd then
		ext_mov:upd_m_head_pos()
	end
end

function CopActionTurn:_upd_wait_full_blend(t)
	if not self._ext_anim.idle_full_blend then
		return
	end

	local ext_mov = self._ext_movement
	local dir_str = self._turn_left and "l" or "r"
	local redir_name = "turn_" .. dir_str
	local redir_res = ext_mov:play_redirect(redir_name)

	if not redir_res then
		--interrupt without expiring
		ext_mov:action_request({
			body_part = 2,
			type = "idle"
		})

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

	self._ext_base:chk_freeze_anims()

	self._timer = TimerManager:game()

	self.update = self[nil]
	self:update(t)
end

function CopActionTurn:_upd_empty(t)
end
