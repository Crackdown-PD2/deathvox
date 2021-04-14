local mvec3_z = mvector3.z
local mvec3_sub = mvector3.subtract
local mvec3_set = mvector3.set
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

	local host_expired = action_desc.host_expired
	self._host_expired = host_expired

	self._ext_base = common_data.ext_base
	self._ext_damage = common_data.ext_damage

	self._last_vel_z = 0

	local timer = TimerManager:game()
	self._timer = timer

	self:_create_blocks_table(action_desc.blocks)

	local is_server = Network:is_server()
	self._is_server = is_server

	if is_server then
		if action_desc.align_sync and body_part == 3 then
			action_desc.align_sync = nil
		end
	else
		local start_rot = action_desc.start_rot

		if start_rot then
			ext_mov:set_rotation(start_rot)
			ext_mov:set_position(action_desc.start_pos)
		end
	end

	--if action_desc.needs_full_blend and not ext_anim.idle_full_blend then
	if action_desc.needs_full_blend and ext_anim.idle and (not ext_anim.idle_full_blend or ext_anim.to_idle) then
		self._waiting_full_blend = true

		self:_set_updator("_upd_wait_for_full_blend")

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
	elseif host_expired or not self:_play_anim() then
		return
	else
		self:_init_ik()
	end

	self._last_upd_t = timer:time() - 0.001
	self._skipped_frames = 1

	if is_server then
		self:_sync_anim_play()
	end

	ext_mov:enable_update()

	return true
end

function CopActionAct:on_exit()
	if self._disabled_mover_collisions then
		self._disabled_mover_collisions = nil

		self._ext_damage:set_mover_collision_state(true)
	end

	local ext_mov = self._ext_movement

	if self._changed_driving then
		self._changed_driving = nil

		local unit = self._unit

		unit:set_driving("script")

		ext_mov:set_m_rot(unit:rotation())
		ext_mov:set_m_pos(unit:position())
	end

	if self._root_blend_disabled then
		ext_mov:set_root_blend(true)

		self._root_blend_disabled = nil
	end

	ext_mov:drop_held_items()

	if self._ext_anim.stop_talk_on_action_exit then
		self._unit:sound():stop()
	end

	if self._modifier_on then
		self._modifier_on = nil

		self._machine:forbid_modifier(self._modifier_name)
	end

	local expired = self._expired

	if expired then
		CopActionWalk._chk_correct_pose(self)
	end

	if not self._is_server then
		ext_mov:set_m_host_stop_pos(self._common_data.pos)
	elseif not expired then
		self._common_data.ext_network:send("action_act_end")
	end
end

function CopActionAct:_init_ik()
	if self._body_part ~= 1 or managers.job:current_level_id() ~= "chill" or not self._common_data.char_tweak.use_ik then
		return
	end

	self._look_vec = mvec3_cpy(self._common_data.fwd)
	self._ik_update = callback(self, self, "_ik_update_func")
	self._m_head_pos = self._ext_movement:m_head_pos()

	local player_unit = managers.player:player_unit()
	self._ik_data = player_unit
end

function CopActionAct:_ik_update_func(t)
	self:_update_ik_type()

	if not self._ik_type then
		if self._modifier_on then
			self._modifier_on = nil

			self._machine:forbid_modifier(self._modifier_name)
		end

		return
	end

	local local_player = self._ik_data

	if not alive_g(local_player) then
		if self._modifier_on then
			self._modifier_on = nil

			self._machine:forbid_modifier(self._modifier_name)
		end

		return
	end

	local common_data = self._common_data
	local look_from_pos = self._m_head_pos
	local target_vec = self._look_vec

	mvec3_set(target_vec, local_player:movement():m_head_pos())
	mvec3_sub(target_vec, look_from_pos)

	local disable_ik = nil

	mvec3_set(tmp_vec1, target_vec)
	tmp_vec1 = tmp_vec1:normalized()

	local up_dot = tmp_vec1:dot(math_up)

	if math_abs(up_dot) > 0.6 then
		disable_ik = true
	end

	mvec3_set(tmp_vec1, target_vec)
	tmp_vec1 = tmp_vec1:with_z(0):normalized()

	local fwd_dot = common_data.fwd:dot(tmp_vec1)

	if fwd_dot < 0.25 or disable_ik then
		if self._modifier_on then
			self._modifier_on = nil

			self._machine:forbid_modifier(self._modifier_name)
		end
	elseif not self._modifier_on then
		self._modifier_on = true

		self._machine:force_modifier(self._modifier_name)

		local vis_state = self._ext_base:lod_stage() or 4

		if vis_state < 3 then
			local old_look_vec = self._modifier_name == idstr_look_head and self._unit:get_object(idstr_head):rotation():z() or self._unit:get_object(idstr_aim):rotation():y()
			local duration = math_lerp(0.1, 1, target_vec:angle(old_look_vec) / 90)
			self._look_trans = {
				start_t = t,
				duration = duration,
				start_vec = old_look_vec
			}
		end
	end

	local look_trans = self._look_trans

	if look_trans then
		local prog = (t - look_trans.start_t) / look_trans.duration

		if prog > 1 then
			self._look_trans = nil
		else
			local end_vec = tmp_vec1

			mvec3_set(end_vec, target_vec)
			end_vec = end_vec:normalized()

			local prog_smooth = math_bezier(bezier_curve, prog)

			mvec3_lerp(target_vec, look_trans.start_vec, end_vec, prog_smooth)
		end
	end

	if self._modifier_on then
		self._modifier:set_target_z(target_vec)
	end
end

function CopActionAct:on_attention(attention)
	self._attention = attention
end

function CopActionAct:_update_ik_type()
	if not self._ik_update then
		return
	end

	local new_ik_type = self._ext_anim.ik_type

	if self._ik_type ~= new_ik_type then
		if self._modifier_on then
			self._machine:forbid_modifier(self._modifier_name)

			self._modifier_on = nil
		end

		if new_ik_type == "head" then
			self._ik_type = new_ik_type
			self._modifier_name = idstr_look_head
			self._modifier = self._machine:get_modifier(self._modifier_name)
		elseif new_ik_type == "upper_body" then
			self._ik_type = new_ik_type
			self._modifier_name = idstr_look_upper_body
			self._modifier = self._machine:get_modifier(self._modifier_name)
		else
			self._ik_type = nil
		end
	end
end

function CopActionAct:_upd_empty()
end

function CopActionAct:_upd_wait_for_full_blend()
	local ext_anim = self._ext_anim

	if not ext_anim.idle or ext_anim.idle_full_blend and not ext_anim.to_idle then
		self._waiting_full_blend = nil

		if self._host_expired then
			self._expired = true
			self:_set_updator("_upd_empty")

			return
		end

		if self._is_server then
			self._common_data.ext_brain:rem_pos_rsrv("stand")
		end

		if not self:_play_anim() then
			return
		end

		self:_init_ik()
	end
end

function CopActionAct:_clamping_update(t)
	if self._ext_anim.act then
		local unit = self._unit

		if not unit:parent() then
			local dt = t - self._last_upd_t
			self._last_pos = self:_get_pos_clamped_to_graph()

			self:_set_new_pos(dt)

			local new_rot = unit:get_animation_delta_rotation()
			new_rot = self._common_data.rot * new_rot

			mrot_set_yaw(new_rot, new_rot:yaw(), 0, 0)
			self._ext_movement:set_rotation(new_rot)
		end
	else
		self._expired = true
	end

	self._last_upd_t = t

	if self._ik_update then
		self._ik_update(t)
	end
end

function CopActionAct:update(t)
	local freefall = self._freefall
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

	local unit = self._unit
	local ext_anim = self._ext_anim
	local ext_mov = self._ext_movement

	if freefall then
		if ext_anim.freefall then
			local common_data = self._common_data
			local dt = t - self._last_upd_t
			local pos_new = tmp_vec1
			local delta_pos = unit:get_animation_delta_position()

			unit:m_position(pos_new)
			mvec3_add(pos_new, delta_pos)
			ext_mov:upd_ground_ray(pos_new, true)

			local gnd_z = common_data.gnd_ray.position.z

			if gnd_z < pos_new.z then
				self._last_vel_z = self._apply_freefall(pos_new, self._last_vel_z, gnd_z, dt)
			else
				if pos_new.z < gnd_z then
					pos_new = pos_new:with_z(gnd_z)
				end

				self._last_vel_z = 0
			end

			local new_rot = unit:get_animation_delta_rotation()
			new_rot = common_data.rot * new_rot

			mrot_set_yaw(new_rot, new_rot:yaw(), 0, 0)
			ext_mov:set_rotation(new_rot)
			ext_mov:set_position(pos_new)
		else
			self._freefall = nil
			self._last_vel_z = nil

			unit:set_driving("animation")

			self._changed_driving = true
		end
	elseif not unit:parent() then
		if ext_anim.freefall then
			self._freefall = true
			self._last_vel_z = 0

			self._apply_freefall = CopActionWalk._apply_freefall
		else
			ext_mov:set_m_rot(unit:rotation())
			ext_mov:set_m_pos(unit:position())
		end
	end

	self._last_upd_t = t

	if not ext_anim.act then
		self._expired = true
	end

	self._ext_movement:spawn_wanted_items()
end

function CopActionAct:save(save_data)
	for k, v in pairs_g(self._action_desc) do
		save_data[k] = v
	end

	save_data.blocks = save_data.blocks or {
		act = -1,
		action = -1,
		walk = -1
	}

	local machine = self._machine
	save_data.start_anim_time = machine:segment_real_time(idstr_base)

	if save_data.variant then
		local state_name = machine:segment_state(idstr_base)
		local state_index = machine:state_name_to_index(state_name)
		save_data.variant = state_index
	end

	save_data.pos_z = mvec3_z(self._common_data.pos)
end

----improve conditions, maybe make a boolean lookup list to filter which ones need updating (determine in init)
function CopActionAct:need_upd()
	if self._ik_data or self._look_trans or self._waiting_full_blend or self._freefall then
		return true
	end

	return false
end

function CopActionAct:chk_block(action_type, t)
	local unblock_t = self._blocks[action_type]

	if not unblock_t then
		return false
	end

	return unblock_t == -1 or t < unblock_t
end

function CopActionAct:_create_blocks_table(block_desc)
	local blocks = self._blocks or {}

	if block_desc then
		local timer = self._timer or TimerManager:game()
		local t = timer:time()

		for action_type, block_duration in pairs_g(block_desc) do
			blocks[action_type] = block_duration == -1 and -1 or t + block_duration
		end
	end

	self._blocks = blocks
end

function CopActionAct:_get_act_index(anim_name)
	local cat_offset = 0
	local category_index = self._ACT_CATEGORY_INDEX

	for i = 1, #category_index do
		local category_name = category_index[i]
		local category = self._act_redirects[category_name]

		for i_anim = 1, #category do
			local test_anim_name = category[i_anim]

			if test_anim_name == anim_name then
				return i_anim + cat_offset
			end
		end

		cat_offset = cat_offset + #category
	end

	--log("copactionact: couldn't find sync index for" .. tostring(anim_name) .. "")
end

function CopActionAct:_get_act_name_from_index(index)
	local category_index = self._ACT_CATEGORY_INDEX

	for i = 1, #category_index do
		local category_name = category_index[i]
		local category = self._act_redirects[category_name]

		if index <= #category then
			return category[index]
		end

		index = index - #category
	end

	--log("copactionact: synced index " .. tostring(index) .. "is out of limits.")
end

function CopActionAct:_play_anim()
	local action_desc = self._action_desc
	local ext_anim = self._ext_anim
	local ext_mov = self._ext_movement

	if ext_anim.upper_body_active and not ext_anim.upper_body_empty then
		ext_mov:play_redirect("up_idle")
	end

	local variant = action_desc.variant
	local redir_name, redir_res = nil

	if type_g(variant) == "number" then
		redir_name = self._machine:index_to_state_name(variant)
		redir_res = ext_mov:play_state_idstr(redir_name, action_desc.start_anim_time)

		ext_mov:set_position(self._common_data.pos:with_z(action_desc.pos_z))
	else
		redir_name = variant

		if redir_name == "idle" and self._common_data.stance.name == "ntl" then
			redir_name = "exit"
		end

		redir_res = ext_mov:play_redirect(redir_name, action_desc.start_anim_time)
	end

	if not redir_res then
		if self._is_server then
			ext_mov:action_request({
				body_part = self._body_part,
				type = "idle"
			})
		end

		return
	end

	local dmg_ext = self._ext_damage

	if dmg_ext.set_mover_collision_state then
		self._disabled_mover_collisions = true

		dmg_ext:set_mover_collision_state(false)
	end

	local unit = self._unit

	if action_desc.clamp_to_graph then
		self:_set_updator("_clamping_update")

		self._get_pos_clamped_to_graph = CopActionHurt._get_pos_clamped_to_graph
		self._set_new_pos = CopActionWalk._set_new_pos
	else
		if not ext_anim.freefall and not unit:parent() then
			unit:set_driving("animation")

			self._changed_driving = true
		end

		self:_set_updator()
	end

	if ext_anim.freefall and not unit:parent() then
		self._freefall = true
		self._last_vel_z = 0

		self._apply_freefall = CopActionWalk._apply_freefall
	end

	self._root_blend_disabled = true

	ext_mov:set_root_blend(false)
	ext_mov:spawn_wanted_items()

	if ext_anim.ik_type then
		self:_update_ik_type()
	end

	return true
end

function CopActionAct:_sync_anim_play()
	local action_desc = self._action_desc
	local action_index = self:_get_act_index(action_desc.variant)

	if not action_index then
		return
	end

	local common_data = self._common_data
	local blocks_hurts = self._blocks.heavy_hurt and true or false
	local clamp_to_graph = action_desc.clamp_to_graph and true or false
	local needs_full_blend = action_desc.needs_full_blend and true or false

	if action_desc.align_sync and not self._unit:parent() then
		local yaw = mrot_yaw(common_data.rot)

		if yaw < 0 then
			yaw = 360 + yaw
		end

		local sync_yaw = 1 + math_ceil(yaw * 254 / 360)
		local sync_pos = mvec3_cpy(common_data.pos)

		common_data.ext_network:send("action_act_start_align", action_index, blocks_hurts, clamp_to_graph, needs_full_blend, sync_yaw, sync_pos)
	else
		common_data.ext_network:send("action_act_start", action_index, blocks_hurts, clamp_to_graph, needs_full_blend)
	end
end

function CopActionAct:_set_updator(func_name)
	self.update = self[func_name]

	if not func_name then
		self._last_upd_t = self._timer:time() - 0.001
	end
end
