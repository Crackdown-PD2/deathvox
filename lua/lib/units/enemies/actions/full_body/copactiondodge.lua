CopActionDodge._dodge_anim_distances = {
	hos = {
		side_step = {
			fwd = 210,
			bwd = 65,
			l = 180,
			r = 120
		},
		dive = {
			fwd = 275,
			bwd = 280,
			l = 240,
			r = 275
		},
		roll = {
			fwd = 240,
			bwd = 240,
			l = 245,
			r = 250
		},
		wheel = {
			fwd = 300,
			bwd = 240,
			l = 215,
			r = 215
		}
	},
	cbt = {
		side_step = {
			fwd = 130,
			bwd = 35,
			l = 100,
			r = 75
		}
	}
}

CopActionDodge._dodge_anim_distances.cbt.dive = CopActionDodge._dodge_anim_distances.hos.dive
CopActionDodge._dodge_anim_distances.cbt.roll = CopActionDodge._dodge_anim_distances.hos.roll
CopActionDodge._dodge_anim_distances.cbt.wheel = CopActionDodge._dodge_anim_distances.hos.wheel

local mvec3_cpy = mvector3.copy

local mrot_set = mrotation.set_yaw_pitch_roll
local mrot_lookat = mrotation.set_look_at
local tmp_rot = Rotation()

local math_floor = math.floor
local math_clamp = math.clamp
local math_up = math.UP
local math_lerp = math.lerp

local ids_base = Idstring("base")

function CopActionDodge:init(action_desc, common_data)
	local ext_mov = common_data.ext_movement
	local redir_res = ext_mov:play_redirect("dodge")

	if not redir_res then
		return
	end

	self._common_data = common_data
	self._action_desc = action_desc
	self._ext_movement = ext_mov
	self._ext_base = common_data.ext_base
	self._ext_anim = common_data.ext_anim
	self._unit = common_data.unit

	local body_part = action_desc.body_part
	self._body_part = body_part

	local variation = action_desc.variation
	local speed = action_desc.speed
	speed = speed > 1.6 and 1.6 or speed --hard clamp as otherwise the animations just completely break, thanks OVK lmao
	self._speed = speed

	local side = action_desc.side
	local direction = action_desc.direction

	self._timeout = action_desc.timeout

	local machine = common_data.machine
	self._machine = machine

	machine:set_parameter(redir_res, variation, 1)
	machine:set_parameter(redir_res, side, 1)

	if speed ~= 1 then
		machine:set_speed(redir_res, speed)
	end

	CopActionAct._create_blocks_table(self, action_desc.blocks)

	self:_determine_rotation_transition(side, direction, variation)

	self._set_new_pos = CopActionWalk._set_new_pos

	local shoot_accuracy = action_desc.shoot_accuracy

	if Network:is_server() then
		self._is_server = true

		if shoot_accuracy then --clamp accuracy between 0 and 1, and round down to one decimal if needed
			if shoot_accuracy < 0 then
				shoot_accuracy = 0
			elseif shoot_accuracy ~= 1 then
				shoot_accuracy = shoot_accuracy > 1 and 1 or math_floor(shoot_accuracy * 10) / 10
			end
		else
			shoot_accuracy = 1
		end

		local var_index = self._get_variation_index(variation)
		local side_index = self._get_side_index(side)

		mrot_lookat(tmp_rot, direction, math_up)

		local sync_yaw = tmp_rot:yaw()
		local sync_acc = shoot_accuracy * 10 --accuracy multiplier is synced to clients as an integer clamped between 0 and 10

		common_data.ext_network:send("action_dodge_start", body_part, var_index, side_index, sync_yaw, speed, sync_acc)
	end

	self._shoot_accuracy = shoot_accuracy

	self._last_vel_z = 0

	ext_mov:enable_update()

	return true
end

function CopActionDodge:on_exit()
	local ext_mov = self._ext_movement
	local expired = self._expired

	if not self._is_server then
		ext_mov:set_m_host_stop_pos(self._common_data.pos)
	elseif not expired then
		self._common_data.ext_network:send("action_dodge_end")
	end

	if expired then
		CopActionWalk._chk_correct_pose(self)
	end
end

function CopActionDodge:update(t)
	local ext_anim = self._ext_anim
	local dt = TimerManager:game():delta_time()

	if not ext_anim.dodge then
		self._expired = true
		self.update = self["_upd_empty"]

		self._last_pos = self._end_pos

		self._set_new_pos(self, dt)

		if ext_anim.base_need_upd then
			self._ext_movement:upd_m_head_pos()
		end

		return
	end

	local ext_mov = self._ext_movement
	local seg_rel_t = self._machine:segment_relative_time(ids_base)
	local prev_last_pos = self._last_pos or self._start_pos
	local dis_speed = self._speed
	dis_speed = dis_speed < 1 and 1 or dis_speed

	self._last_pos = self._anim_displacement_f(self._start_pos, self._end_pos, seg_rel_t, dis_speed)

	self._set_new_pos(self, dt)

	if ext_anim.base_need_upd then
		ext_mov:upd_m_head_pos()
	end
end

function CopActionDodge:upd_empty(t)
end

local cannot_block_list = {
	death = true,
	bleedout = true,
	fatal = true
}

local default_block_list = {
	turn = true,
	idle = true,
	stand = true,
	crouch = true,
	walk = true
}

function CopActionDodge:chk_block(action_type, t)
	if cannot_block_list[action_type] then
		return false
	elseif default_block_list[action_type] or CopActionAct.chk_block(self, action_type, t) then
		return true
	end
end

function CopActionDodge._get_variation_index(var_name)
	local vars = CopActionDodge._VARIATIONS

	for i = 1, #vars do
		local test_var_name = vars[i]

		if var_name == test_var_name then
			return i
		end
	end
end

function CopActionDodge._get_side_index(side_name)
	local vars = CopActionDodge._SIDES

	for i = 1, #vars do
		local test_side_name = vars[i]

		if side_name == test_side_name then
			return i
		end
	end
end

local displacement_functions = {
	hos = {
		side_step = {
			fwd = function (p1, p2, t, speed)
				local t_min = 0.2 / speed
				local t_max = 0.37 / speed
				local t_clamp = (math_clamp(t - t_min, 0, t_max) / t_max)

				return math_lerp(p1, p2, t_clamp)
			end,
			bwd = function (p1, p2, t, speed)
				local t_min = 0.2 / speed
				local t_max = 0.22 / speed
				local t_clamp = (math_clamp(t - t_min, 0, t_max) / t_max)

				return math_lerp(p1, p2, t_clamp)
			end,
			l = function (p1, p2, t, speed)
				local t_min = 0.2 / speed
				local t_max = 0.43 / speed
				local t_clamp = (math_clamp(t - t_min, 0, t_max) / t_max)

				return math_lerp(p1, p2, t_clamp)
			end,
			r = function (p1, p2, t, speed)
				local t_min = 0.27 / speed
				local t_max = 0.36 / speed
				local t_clamp = (math_clamp(t - t_min, 0, t_max) / t_max)

				return math_lerp(p1, p2, t_clamp)
			end
		},
		dive = {
			fwd = function (p1, p2, t, speed)
				local t_min = 0.11 / speed
				local t_max = 0.23 / speed
				local t_clamp = (math_clamp(t - t_min, 0, t_max) / t_max)

				return math_lerp(p1, p2, t_clamp)
			end,
			bwd = function (p1, p2, t, speed)
				local t_min = 0.15 / speed
				local t_max = 0.23 / speed
				local t_clamp = (math_clamp(t - t_min, 0, t_max) / t_max)

				return math_lerp(p1, p2, t_clamp)
			end,
			l = function (p1, p2, t, speed)
				local t_min = 0.1 / speed
				local t_max = 0.31 / speed
				local t_clamp = (math_clamp(t - t_min, 0, t_max) / t_max)

				return math_lerp(p1, p2, t_clamp)
			end,
			r = function (p1, p2, t, speed)
				local t_min = 0.08 / speed
				local t_max = 0.2 / speed
				local t_clamp = (math_clamp(t - t_min, 0, t_max) / t_max)

				return math_lerp(p1, p2, t_clamp)
			end
		},
		roll = {
			fwd = function (p1, p2, t, speed)
				local t_min = 0.1 / speed
				local t_max = 0.47 / speed
				local t_clamp = (math_clamp(t - t_min, 0, t_max) / t_max)

				return math_lerp(p1, p2, t_clamp)
			end,
			bwd = function (p1, p2, t, speed)
				local t_min = 0.15 / speed
				local t_max = 0.49 / speed
				local t_clamp = (math_clamp(t - t_min, 0, t_max) / t_max)

				return math_lerp(p1, p2, t_clamp)
			end,
			l = function (p1, p2, t, speed)
				local t_min = 0.15 / speed
				local t_max = 0.49 / speed
				local t_clamp = (math_clamp(t - t_min, 0, t_max) / t_max)

				return math_lerp(p1, p2, t_clamp)
			end,
			r = function (p1, p2, t, speed)
				local t_min = 0.15 / speed
				local t_max = 0.49 / speed
				local t_clamp = (math_clamp(t - t_min, 0, t_max) / t_max)

				return math_lerp(p1, p2, t_clamp)
			end
		},
		wheel = {
			fwd = function (p1, p2, t, speed)
				local t_min = 0.08 / speed
				local t_max = 0.5 / speed
				local t_clamp = (math_clamp(t - t_min, 0, t_max) / t_max)

				return math_lerp(p1, p2, t_clamp)
			end,
			bwd = function (p1, p2, t, speed)
				local t_min = 0.15 / speed
				local t_max = 0.52 / speed
				local t_clamp = (math_clamp(t - t_min, 0, t_max) / t_max)

				return math_lerp(p1, p2, t_clamp)
			end,
			l = function (p1, p2, t, speed)
				local t_min = 0.12 / speed
				local t_max = 0.47 / speed
				local t_clamp = (math_clamp(t - t_min, 0, t_max) / t_max)

				return math_lerp(p1, p2, t_clamp)
			end,
			r = function (p1, p2, t, speed)
				local t_min = 0.12 / speed
				local t_max = 0.47 / speed
				local t_clamp = (math_clamp(t - t_min, 0, t_max) / t_max)

				return math_lerp(p1, p2, t_clamp)
			end
		}
	},
	cbt = {
		side_step = {
			fwd = function (p1, p2, t, speed)
				local t_min = 0.2 / speed
				local t_max = 0.27 / speed
				local t_clamp = (math_clamp(t - t_min, 0, t_max) / t_max)

				return math_lerp(p1, p2, t_clamp)
			end,
			bwd = function (p1, p2, t, speed)
				local t_min = 0.16 / speed
				local t_max = 0.12 / speed
				local t_clamp = (math_clamp(t - t_min, 0, t_max) / t_max)

				return math_lerp(p1, p2, t_clamp)
			end,
			l = function (p1, p2, t, speed)
				local t_min = 0.2 / speed
				local t_max = 0.26 / speed
				local t_clamp = (math_clamp(t - t_min, 0, t_max) / t_max)

				return math_lerp(p1, p2, t_clamp)
			end,
			r = function (p1, p2, t, speed)
				local t_min = 0.24 / speed
				local t_max = t_min
				local t_clamp = (math_clamp(t - t_min, 0, t_max) / t_max)

				return math_lerp(p1, p2, t_clamp)
			end
		}
	}
}

displacement_functions.cbt.dive = displacement_functions.hos.dive
displacement_functions.cbt.roll = displacement_functions.hos.roll
displacement_functions.cbt.wheel = displacement_functions.hos.wheel

function CopActionDodge:_determine_rotation_transition(wanted_side, direction, variation)
	local common_data = self._common_data
	local cur_pos = common_data.pos
	local stance = common_data.stance.name
	local needed_dis = CopActionDodge._determine_needed_distance(stance, variation, wanted_side)
	local ray_params = {
		allow_entry = false,
		trace = true,
		pos_to = cur_pos + direction * needed_dis
	}

	local my_tracker = common_data.nav_tracker

	if my_tracker:lost() then
		ray_params.pos_from = my_tracker:field_position()
	else
		ray_params.tracker_from = my_tracker
	end

	managers.navigation:raycast(ray_params)

	self._start_pos = mvec3_cpy(cur_pos)
	self._end_pos = ray_params.trace[1]
	self._anim_displacement_f = displacement_functions[stance][variation][wanted_side]
end

function CopActionDodge:accuracy_multiplier()
	return self._shoot_accuracy
end

function CopActionDodge._determine_needed_distance(stance, var, side)
	stance = stance or "hos"

	return CopActionDodge._dodge_anim_distances[stance][var][side]
end
