local idstr_base = Idstring("base")

function CopActionCrouch:init(action_desc, common_data)
	local mov_ext = common_data.ext_movement
	local crouch_anim_lengths = mov_ext._actions.walk._walk_anim_lengths.crouch

	if not crouch_anim_lengths then
		--debug_pause_unit(common_data.unit, "unit cannot crouch!", common_data.unit, inspect(action_desc), common_data.machine:segment_state(idstr_base))

		return
	end

	local active_actions = common_data.active_actions

	if active_actions[2] and active_actions[2]._nav_link then
		--debug_pause_unit(common_data.unit, "interrupted nav_link!", common_data.unit, inspect(action_desc), common_data.machine:segment_state(idstr_base), inspect(active_actions[2]))

		return
	end

	self._ext_movement = mov_ext

	local enter_t = nil
	local ext_anim = common_data.ext_anim
	self._ext_anim = ext_anim

	if ext_anim.move then
		local my_stance = common_data.stance.name
		local seg_rel_t = common_data.machine:segment_relative_time(idstr_base)
		local move_side = ext_anim.move_side
		local walk_anim_length = nil

		if ext_anim.run_start_turn then
			walk_anim_length = crouch_anim_lengths[my_stance].run_start_turn[move_side]
		elseif ext_anim.run_start then
			walk_anim_length = crouch_anim_lengths[my_stance].run_start[move_side]
		elseif ext_anim.run_stop then
			walk_anim_length = crouch_anim_lengths[my_stance].run_stop[move_side]
		else
			local walk_pose_tbl = crouch_anim_lengths and crouch_anim_lengths[my_stance]
			local walk_speed_tbl = walk_pose_tbl and walk_pose_tbl[ext_anim.run and "run" or "walk"]
			walk_anim_length = walk_speed_tbl and walk_speed_tbl[move_side] or 29
		end

		enter_t = seg_rel_t * walk_anim_length
	end

	local redir_result = mov_ext:play_redirect("crouch", enter_t)

	if redir_result then
		if not action_desc.no_sync and Network:is_server() then
			common_data.ext_network:send("set_pose", 2)
		end

		mov_ext:enable_update()

		return true
	--else
		--cat_print("george", "[CopActionCrouch:init] failed in", common_data.machine:segment_state(idstr_base), common_data.unit)
	end
end

function CopActionCrouch:on_exit()
	if self._expired then
		self._ext_movement:upd_m_head_pos()
	end
end
