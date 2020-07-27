local mvec3_cpy = mvector3.copy

local mrot_set_ypr = mrotation.set_yaw_pitch_roll
local mrot_yaw = mrotation.yaw

local math_abs = math.abs

local tmp_rot = Rotation()

function CopActionTurn:init(action_desc, common_data)
	self._common_data = common_data
	self._ext_movement = common_data.ext_movement
	self._ext_anim = common_data.ext_anim
	self._ext_base = common_data.ext_base
	self._machine = common_data.machine
	self._action_desc = action_desc

	if not common_data.ext_movement.idle and not common_data.ext_movement:play_redirect("idle") then
		return false
	end

	self._angle = action_desc.angle
	self._start_pos = mvec3_cpy(common_data.pos)

	if common_data.machine:get_global("shield") == 1 then
		self._shield_turning = true
	end

	self.update = self._upd_wait_full_blend

	common_data.ext_movement:enable_update()
	CopActionAct._create_blocks_table(self, action_desc.blocks)

	return true
end

function CopActionTurn:on_exit()
	self._common_data.unit:set_driving("script")
	self._ext_movement:set_root_blend(true)
	self._ext_movement:set_position(self._start_pos)

	local end_rot = self._common_data.rot

	mrot_set_ypr(tmp_rot, mrot_yaw(end_rot), 0, 0)
	self._ext_movement:set_rotation(tmp_rot)
end

function CopActionTurn:update(t)
	if not self._ext_anim.turn and self._ext_anim.idle_full_blend then
		self._expired = true
	end

	if self._ext_anim.base_need_upd then
		self._ext_movement:upd_m_head_pos()
	end

	self._ext_movement:set_m_rot(self._common_data.unit:rotation())
end

function CopActionTurn:_upd_wait_full_blend(t)
	if not self._ext_anim.idle_full_blend or self._expired then
		return
	end

	local angle = self._angle
	local dir_str = angle > 0 and "l" or "r"
	local redir_name = "turn_" .. dir_str
	local redir_res = self._ext_movement:play_redirect(redir_name)

	if not redir_res then
		self._expired = true

		return
	end

	local abs_angle = math_abs(angle)

	if abs_angle > 135 then
		self._machine:set_parameter(redir_res, "angle135", 1)
	elseif abs_angle > 90 then
		local lerp = (abs_angle - 90) / 45

		self._machine:set_parameter(redir_res, "angle135", lerp)
		self._machine:set_parameter(redir_res, "angle90", 1 - lerp)
	elseif abs_angle > 45 then
		local lerp = (abs_angle - 45) / 45

		self._machine:set_parameter(redir_res, "angle90", lerp)
		self._machine:set_parameter(redir_res, "angle45", 1 - lerp)
	else
		self._machine:set_parameter(redir_res, "angle45", 1)
	end

	if self._shield_turning then
		self._machine:set_speed(redir_res, 0.5)
	else
		self._machine:set_speed(redir_res, 1.5)
	end

	self._common_data.unit:set_driving("animation")
	self._ext_movement:set_root_blend(false)
	self._ext_base:chk_freeze_anims()

	self.update = nil

	self:update(t)
end
