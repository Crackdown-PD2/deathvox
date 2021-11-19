local idstr_base = Idstring("base")

function CopActionStand:init(action_desc, common_data)
	local active_actions = common_data.active_actions

	if active_actions[2] and active_actions[2]._nav_link then
		--debug_pause_unit(common_data.unit, "interrupted nav_link!", common_data.unit, inspect(action_desc), common_data.machine:segment_state(idstr_base), inspect(active_actions[2]))

		return
	end

	local mov_ext = common_data.ext_movement
	self._ext_movement = mov_ext

	local enter_t = nil
	local ext_anim = common_data.ext_anim
	self._ext_anim = ext_anim

	if ext_anim.move then
		local stand_anim_lengths = mov_ext._actions.walk._walk_anim_lengths.stand
		local my_stance = common_data.stance.name
		local seg_rel_t = common_data.machine:segment_relative_time(idstr_base)
		local move_side = ext_anim.move_side
		local walk_anim_length = nil

		if ext_anim.run_start_turn then
			walk_anim_length = stand_anim_lengths[my_stance].run_start_turn[move_side]
		elseif ext_anim.run_start then
			walk_anim_length = stand_anim_lengths[my_stance].run_start[move_side]
		elseif ext_anim.run_stop then
			if not stand_anim_lengths[my_stance].run_stop then
				--debug_pause_unit(common_data.unit, "[CopActionStand:init]", common_data.unit, "stance", my_stance, "anim_length", stand_anim_lengths[my_stance])

				return
			end

			walk_anim_length = stand_anim_lengths[my_stance].run_stop[move_side]
		else
			local walk_pose_tbl = stand_anim_lengths[my_stance]
			local walk_speed_tbl = walk_pose_tbl and walk_pose_tbl[ext_anim.run and "run" or "walk"]
			walk_anim_length = walk_speed_tbl and walk_speed_tbl[move_side] or 29
		end

		enter_t = seg_rel_t * walk_anim_length
	end

	local redir_result = mov_ext:play_redirect("stand", enter_t)

	if redir_result then
		if not action_desc.no_sync and Network:is_server() then
			common_data.ext_network:send("set_pose", 1)
		end

		mov_ext:enable_update()

		return true
	--else
		--cat_print("george", "[CopActionStand:init] failed in", common_data.machine:segment_state(idstr_base), common_data.unit)
	end
end

function CopActionStand:on_exit()
	if self._expired then
		self._ext_movement:upd_m_head_pos()
	end
end
