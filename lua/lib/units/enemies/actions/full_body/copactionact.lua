local mvec3_z = mvector3.z
local mvec3_set = mvector3.set
local mvec3_sub = mvector3.subtract
local mvec3_lerp = mvector3.lerp
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_cpy = mvector3.copy
local tmp_vec1 = Vector3()

local mrot_yaw = mrotation.yaw
local mrot_set_yaw = mrotation.set_yaw_pitch_roll

local math_ceil = math.ceil
local math_lerp = math.lerp
local math_abs = math.abs
local math_up = math.UP
local math_bezier = math.bezier
local bezier_curve = {
	0,
	0,
	1,
	1
}

local pairs_g = pairs
local type_g = type

local idstr_base = Idstring("base")
local idstr_upper_body = Idstring("upper_body")
local idstr_look_upper_body = Idstring("look_upper_body")
local idstr_look_head = Idstring("look_head")
local idstr_head = Idstring("Head")
local idstr_aim = Idstring("aim")

local alive_g = alive

local script_redirects = CopActionAct._act_redirects.script
script_redirects[#script_redirects + 1] = "cmd_get_up"
script_redirects[#script_redirects + 1] = "cmd_stop"
script_redirects[#script_redirects + 1] = "cmd_down"
script_redirects[#script_redirects + 1] = "cmd_gogo"
script_redirects[#script_redirects + 1] = "cmd_point"
--need to change at least one of these to pissing later

CopActionAct._act_redirects.script = script_redirects

function CopActionAct:init(action_desc, common_data)
	self._common_data = common_data
	self._action_desc = action_desc
	self._ext_base = common_data.ext_base
	self._ext_movement = common_data.ext_movement
	self._ext_anim = common_data.ext_anim
	self._unit = common_data.unit
	self._machine = common_data.machine
	self._host_expired = action_desc.host_expired
	self._skipped_frames = 0
	self._last_vel_z = 0

	self:_init_ik()
	self:_create_blocks_table(action_desc.blocks)

	if self._ext_anim.act_idle then
		self._blocks.walk = nil
	end

	if action_desc.needs_full_blend and self._ext_anim.idle and (not self._ext_anim.idle_full_blend or self._ext_anim.to_idle) then
		self._waiting_full_blend = true

		self:_set_updator("_upd_wait_for_full_blend")
	elseif not self:_play_anim() then
		return
	end

	self:_sync_anim_play()
	self._ext_movement:enable_update()

	if self._host_expired and not self._waiting_full_blend then
		self._expired = true
	end

	if not self._expired and Network:is_server() then
		local stand_rsrv = self._unit:brain():get_pos_rsrv("stand")

		if not stand_rsrv or mvector3.distance_sq(stand_rsrv.position, common_data.pos) > 400 then
			self._unit:brain():add_pos_rsrv("stand", {
				radius = 30,
				position = mvector3.copy(common_data.pos)
			})
		end
	end

	if self._unit:character_damage().set_mover_collision_state then
		self._unit:character_damage():set_mover_collision_state(false)
	end

	return true
end

function CopActionAct:_play_anim()
	if self._ext_anim.upper_body_active and not self._ext_anim.upper_body_empty then
		self._ext_movement:play_redirect("up_idle")
	end

	local redir_name, redir_res = nil

	if type(self._action_desc.variant) == "number" then
		redir_name = self._machine:index_to_state_name(self._action_desc.variant)
		redir_res = self._ext_movement:play_state_idstr(redir_name, self._action_desc.start_anim_time)

		self._unit:movement():set_position(self._unit:movement():m_pos():with_z(self._action_desc.pos_z))
	else
		redir_name = self._action_desc.variant

		if redir_name == "idle" and self._common_data.stance.code == 1 then
			redir_name = "exit"
		end

		redir_res = self._ext_movement:play_redirect(redir_name, self._action_desc.start_anim_time)
	end

	if not redir_res then
		self._expired = true

		return
	end

	if self._action_desc.start_rot and not self._unit:parent() then
		self._ext_movement:set_rotation(self._action_desc.start_rot)
		self._ext_movement:set_position(self._action_desc.start_pos)
	end

	if self._action_desc.clamp_to_graph then
		self:_set_updator("_clamping_update")
	else
		if not self._ext_anim.freefall and not self._unit:parent() then
			self._unit:set_driving("animation")

			self._changed_driving = true
		end

		self:_set_updator()
	end

	if self._ext_anim.freefall and not self._unit:parent() then
		self._freefall = true
		self._last_vel_z = 0
	end
	
	if not self._changed_root_blend then
		self._ext_movement:set_root_blend(false)
	end
	
	self._ext_movement:spawn_wanted_items()

	if self._ext_anim.ik_type then
		self:_update_ik_type()
	end

	return true
end

function CopActionAct:on_exit()
	if self._unit:character_damage().set_mover_collision_state then
		self._unit:character_damage():set_mover_collision_state(true)
	end
	
	if self._changed_root_blend then
		self._ext_movement:set_root_blend(true)
	end

	if self._changed_driving then
		self._unit:set_driving("script")

		self._changed_driving = nil

		self._ext_movement:set_m_rot(self._unit:rotation())
		self._ext_movement:set_m_pos(self._unit:position())
	end

	self._ext_movement:drop_held_items()

	if self._ext_anim.stop_talk_on_action_exit then
		self._unit:sound():stop()
	end

	if self._modifier_on then
		self._modifier_on = nil

		self._machine:forbid_modifier(self._modifier_name)
	end

	if self._expired then
		CopActionWalk._chk_correct_pose(self)
	end

	if Network:is_client() then
		self._ext_movement:set_m_host_stop_pos(self._ext_movement:m_pos())
	elseif not self._expired then
		self._common_data.ext_network:send("action_act_end")
	end
end