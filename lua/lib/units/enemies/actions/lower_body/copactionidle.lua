local mvec3_set = mvector3.set
local mvec3_dir = mvector3.direction
local mvec3_rot = mvector3.rotate_with
local mvec3_dot = mvector3.dot
local mvec3_cpy = mvector3.copy
local mvec3_dis_sq = mvector3.distance_sq
local tmp_vec1 = Vector3()

local mrot_set_lookat = mrotation.set_look_at
local mrot_slerp = mrotation.slerp
local mrot_y = mrotation.y
local tmp_rot = Rotation()

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

local idstr_base = Idstring("base")
local idstr_upper_body = Idstring("upper_body")
local idstr_look_upper_body = Idstring("look_upper_body")
local idstr_look_head = Idstring("look_head")
local idstr_head = Idstring("Head")

function CopActionIdle:init(action_desc, common_data)
	if action_desc.non_persistent then
		return
	end

	self._common_data = common_data
	self._ext_base = common_data.ext_base

	local unit = common_data.unit
	self._unit = unit

	local ext_mov = common_data.ext_movement
	self._ext_movement = ext_mov

	local ext_anim = common_data.ext_anim
	self._ext_anim = ext_anim

	local body_part = action_desc.body_part
	self._body_part = body_part

	local machine = common_data.machine
	self._machine = machine

	local stance = common_data.stance
	self._stance = stance

	local is_server = Network:is_server()

	if not is_server and body_part == 3 then
		self._turn_allowed = true
		self._allow_freefall = true
		self._last_vel_z = 0
		self._apply_freefall = CopActionWalk._apply_freefall

		if stance.name == "ntl" then
			self._start_fwd = common_data.rot:y()
		end
	end

	local res = nil

	if body_part == 3 then
		if ext_anim.upper_body_active and not ext_anim.upper_body_empty then
			res = ext_mov:play_redirect("up_idle")
		end
	elseif action_desc.anim then
		local state_name = machine:index_to_state_name(action_desc.anim, action_desc.start_anim_time)

		res = ext_mov:play_state_idstr(state_name)
	elseif not ext_anim.idle then
		if stance.name == "ntl" then
			res = ext_mov:play_redirect("exit")
		else
			res = ext_mov:play_redirect("idle")
		end

		ext_mov:enable_update()
	end

	if res == false then
		return
	end

	local timer = TimerManager:game()
	self._timer = timer
	self._last_upd_t = timer:time() - 0.001
	self._skipped_frames = 1

	local mod_name = ext_anim.ik_type == "head" and idstr_look_head or idstr_look_upper_body

	self._modifier_name = mod_name
	self._modifier = machine:get_modifier(mod_name)

	self:on_attention(common_data.attention)

	if body_part == 1 or body_part == 2 then
		self._allow_freefall = true
		self._last_vel_z = 0
		self._apply_freefall = CopActionWalk._apply_freefall

		if is_server then
			local brain_ext = common_data.ext_brain
			local stand_rsrv = brain_ext:get_pos_rsrv("stand")
			local cur_pos = common_data.pos

			if not stand_rsrv or mvec3_dis_sq(stand_rsrv.position, cur_pos) > 400 then
				brain_ext:add_pos_rsrv("stand", {
					radius = 30,
					position = mvec3_cpy(cur_pos)
				})
			end
		end
	end

	if is_server and action_desc.sync then
		common_data.ext_network:send("action_idle_start", body_part)
	end

	CopActionAct._create_blocks_table(self, action_desc.blocks)
	--self:_init_ik()

	return true
end

function CopActionIdle:_init_ik()
	local body_part = self._body_part

	if body_part ~= 1 and body_part ~= 3 or managers.job:current_level_id() ~= "chill" or not self._common_data.char_tweak.use_ik then
		return
	end

	self._look_vec = mvec3_cpy(self._common_data.fwd)
	self._ik_update = callback(self, self, "_ik_update_func")
	self._m_head_pos = self._ext_movement:m_head_pos()

	local player_unit = managers.player:player_unit()
	self._ik_data = player_unit
end

function CopActionIdle:_update_ik_type()
	if not self._ik_update then
		return
	end

	local new_ik_type = self._ext_anim.ik_type

	if self._ik_type ~= new_ik_type then
		if self._modifier_on then
			----test using allow instead of forbid
			----also try to make head tracking work similarly to what copactionact does in the safehouse (slower head movement)
			self._machine:forbid_modifier(self._modifier_name)

			self._modifier_on = nil
		end

		if new_ik_type == "head" then
			self._ik_type = new_ik_type
			self._modifier_name = idstr_look_head
			self._modifier = self._machine:get_modifier(idstr_look_head)
		elseif new_ik_type == "upper_body" then
			self._ik_type = new_ik_type
			self._modifier_name = idstr_look_upper_body
			self._modifier = self._machine:get_modifier(idstr_look_upper_body)
		else
			self._ik_type = nil
		end
	end
end

function CopActionIdle:on_exit()
	if self._modifier_on then
		self._modifier_on = nil

		self._machine:forbid_modifier(self._modifier_name)
		--self._machine:forbid_modifier(self._modifier_name)
	end

	local look_vec = self._look_vec

	if look_vec and self._modifier:blend() > 0 then
		mvec3_set(self._common_data.look_vec, look_vec)
	end
end

function CopActionIdle:update(t)
	local allow_freefall = self._allow_freefall
	local vis_state = self._ext_base:lod_stage() or 4

	if not freefall and vis_state ~= 1 then
		if self._skipped_frames < vis_state then
			self._skipped_frames = self._skipped_frames + 1

			return
		else
			self._skipped_frames = 1
		end
	end

	local ik_update = self._ik_update

	if ik_update then
		ik_update(t)
	end

	local common_data = self._common_data
	local ext_mov = self._ext_movement
	local attention = self._attention
	local turn_allowed = self._turn_allowed

	if turn_allowed and allow_freefall then
		local active_actions = common_data.active_actions

		if not active_actions[1] and not active_actions[2] then
			allow_freefall = true
			self._last_vel_z = self._last_vel_z or 0
		else
			turn_allowed = false
			allow_freefall = false

			self._last_vel_z = nil
		end
	end

	if attention then
		local ik_enable = true
		local look_from_pos = ext_mov:m_head_pos()
		local target_vec = self._look_vec
		mvec3_dir(target_vec, look_from_pos, self._attention_pos)

		local look_trans = self._look_trans

		if look_trans then
			local prog = (t - look_trans.start_t) / look_trans.duration

			if prog > 1 then
				self._look_trans = nil
			else
				local prog_smooth = math_bezier(bezier_curve, prog)

				mrot_set_lookat(tmp_rot, target_vec, math_up)
				mrot_slerp(tmp_rot, look_trans.start_rot, tmp_rot, prog_smooth)
				mrot_y(tmp_rot, target_vec)

				if target_vec:dot(common_data.fwd) < 0.2 then
					ik_enable = false
				end
			end
		elseif target_vec:dot(common_data.fwd) < 0.2 then
			ik_enable = false
		end

		if ik_enable then
			if not self._modifier_on then
				self._modifier_on = true

				self._machine:force_modifier(self._modifier_name)
			end

			if turn_allowed then
				local queued_actions = common_data.queued_actions

				if not queued_actions or not queued_actions[1] and not queued_actions[2] then
					if not ext_mov:chk_action_forbidden("walk") then
						local spin = target_vec:to_polar_with_reference(common_data.fwd, math_up).spin

						if math_abs(spin) > 70 then
							if self._start_fwd then
								self._rot_offset = true
							end

							local new_action_data = {
								body_part = 2,
								type = "turn",
								angle = spin
							}

							ext_mov:action_request(new_action_data)
						end
					end
				end
			end
		elseif self._modifier_on then
			self._modifier_on = false

			self._machine:forbid_modifier(self._modifier_name)
		end

		if self._modifier_on then
			self._modifier:set_target_z(target_vec)
		end
	elseif self._rot_offset then
		local new_action_data = {
			body_part = 2,
			type = "turn",
			angle = self._start_fwd:to_polar_with_reference(common_data.fwd, math_up).spin
		}

		ext_mov:action_request(new_action_data)

		self._rot_offset = nil
	end

	if allow_freefall then
		local pos_new = tmp_vec1
		self._unit:m_position(pos_new)

		ext_mov:upd_ground_ray(pos_new, true)

		local gnd_z = common_data.gnd_ray.position.z

		if gnd_z < pos_new.z then
			local dt = t - self._last_upd_t

			self._last_vel_z = self._apply_freefall(pos_new, self._last_vel_z, gnd_z, dt)
		else
			if pos_new.z < gnd_z then
				pos_new = pos_new:with_z(gnd_z)
			end

			self._last_vel_z = nil
			self._allow_freefall = nil
		end

		ext_mov:set_position(pos_new)
	end

	self._last_upd_t = t

	if self._ext_anim.base_need_upd then
		ext_mov:upd_m_head_pos()
	end
end

function CopActionIdle:on_attention(attention)
	local body_part = self._body_part

	if body_part ~= 1 and body_part ~= 3 then
		return
	end

	self:_update_ik_type()

	if attention then
		local attention_pos = attention.handler and attention.handler:get_attention_m_pos() or attention.unit and attention.unit:movement():m_head_pos() or attention.pos
		self._attention_pos = attention_pos

		local vis_state = self._ext_base:lod_stage() or 4

		if vis_state < 3 then
			local look_from_pos = self._ext_movement:m_head_pos()
			local target_vec = Vector3()
			mvec3_dir(target_vec, look_from_pos, attention_pos)

			local start_vec = nil

			if self._modifier:blend() > 0 then
				start_vec = self._look_vec or self._common_data.look_vec
			else
				start_vec = self._unit:get_object(idstr_head):rotation():z()
			end

			local duration = math_lerp(0.35, 1, target_vec:angle(start_vec) / 180)
			local start_rot = Rotation()

			mrot_set_lookat(start_rot, start_vec, math_up)

			self._look_trans = {
				start_t = self._timer:time(),
				duration = duration,
				start_rot = start_rot
			}

			self._look_vec = mvec3_cpy(start_vec)
		else
			self._look_vec = mvec3_cpy(self._common_data.fwd)
		end

		self._ext_movement:enable_update()
	else
		if self._modifier_on then
			self._modifier_on = nil

			self._machine:forbid_modifier(self._modifier_name)
		end

		local look_vec = self._look_vec

		if look_vec and self._modifier:blend() > 0 then
			mvec3_set(self._common_data.look_vec, look_vec)
		end
	end

	self._attention = attention
end

function CopActionIdle:need_upd()
	if self._attention or self._look_trans or self._allow_freefall then
		return true
	end

	return false
end

function CopActionIdle:save(save_data)
	if self._body_part ~= 1 then
		return
	end

	save_data.type = "idle"
	save_data.body_part = 1

	local machine = self._machine
	local state_name = machine:segment_state(idstr_base)
	local state_index = machine:state_name_to_index(state_name)
	save_data.anim = state_index
	save_data.start_anim_time = machine:segment_real_time(idstr_base)
end
