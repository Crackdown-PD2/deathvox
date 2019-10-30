ActionSpooc = ActionSpooc or class()
ActionSpooc._walk_anim_velocities = CopActionWalk._walk_anim_velocities
ActionSpooc._walk_anim_lengths = CopActionWalk._walk_anim_lengths
ActionSpooc._matching_walk_anims = CopActionWalk._matching_walk_anims
ActionSpooc._walk_side_rot = CopActionWalk._walk_side_rot
ActionSpooc._anim_movement = CopActionWalk._anim_movement
ActionSpooc._get_max_walk_speed = CopActionWalk._get_max_walk_speed
ActionSpooc._get_current_max_walk_speed = CopActionWalk._get_current_max_walk_speed
ActionSpooc._global_incremental_action_ID = 1
ActionSpooc._apply_freefall = CopActionWalk._apply_freefall
ActionSpooc._tmp_vec1 = Vector3()
ActionSpooc._tmp_vec2 = Vector3()

function ActionSpooc:complete()
	return (self._beating_end_t and self._beating_end_t < TimerManager:game():time()) or (self._beating_end_t and self._last_vel_z >= 0)
end

function ActionSpooc:_upd_strike_first_frame(t)
	if self._is_local and self:_chk_target_invalid() then
		if Network:is_server() then
			self:_expire()
		else
			self:_wait()
		end

		return
	end

	local redir_result = self._ext_movement:play_redirect("spooc_strike")

	if redir_result then
		self._ext_movement:spawn_wanted_items()
	elseif self._is_local then
		if Network:is_server() then
			self:_expire()
		else
			self._ext_network:send_to_host("action_spooc_stop", self._ext_movement:m_pos(), 1, self._action_id)
			self:_wait()
		end

		return
	end

	if self._is_local then
		mvector3.set(self._last_sent_pos, self._common_data.pos)
		self._ext_network:send("action_spooc_strike", mvector3.copy(self._common_data.pos), self._action_id)

		self._nav_path[self._nav_index + 1] = mvector3.copy(self._common_data.pos)

		if self._target_unit:base().is_local_player then
			local enemy_vec = mvector3.copy(self._common_data.pos)

			mvector3.subtract(enemy_vec, self._target_unit:movement():m_pos())
			mvector3.set_z(enemy_vec, 0)
			mvector3.normalize(enemy_vec)
			--self._target_unit:camera():camera_unit():base():clbk_aim_assist({
			--	ray = enemy_vec
			--})
			--no more aim assist BS
		end
	end

	self._last_vel_z = 0

	self:_set_updator("_upd_striking")
	self._common_data.unit:base():chk_freeze_anims()
end

function ActionSpooc:_upd_flying_strike_first_frame(t)
	local target_pos = nil

	if self._is_local then
		target_pos = self._target_unit:movement():m_pos()

		self:_send_nav_point(target_pos)
	else
		target_pos = self._nav_path[#self._nav_path]
	end

	local my_pos = self._unit:movement():m_pos()
	local target_vec = self._tmp_vec1

	mvector3.set(target_vec, target_pos)
	mvector3.subtract(target_vec, my_pos)

	local target_dis = mvector3.length(target_vec)
	local redir_result = self._ext_movement:play_redirect("spooc_flying_strike")

	if not redir_result then
		debug_pause_unit(self._unit, "[ActionSpooc:_chk_start_flying_strike] failed redirect spooc_flying_strike in ", self._machine:segment_state(Idstring("base")), self._unit)

		return
	end

	self._ext_movement:spawn_wanted_items()

	local anim_travel_dis_xy = 470
	self._flying_strike_data = {
		start_pos = mvector3.copy(my_pos),
		start_rot = self._unit:rotation(),
		target_pos = mvector3.copy(target_pos),
		target_rot = Rotation(target_vec:with_z(0), math.UP),
		start_t = TimerManager:game():time(),
		travel_dis_scaling_xy = target_dis / anim_travel_dis_xy
	}
	local speed_mul = math.lerp(3, 1, math.min(1, self._flying_strike_data.travel_dis_scaling_xy))

	self._machine:set_speed(redir_result, speed_mul)

	if alive(self._target_unit) and self._target_unit:base().is_local_player then
		local enemy_vec = mvector3.copy(self._common_data.pos)

		mvector3.subtract(enemy_vec, self._target_unit:movement():m_pos())
		mvector3.set_z(enemy_vec, 0)
		mvector3.normalize(enemy_vec)
		--self._target_unit:camera():camera_unit():base():clbk_aim_assist({
		--	ray = enemy_vec
		--})
	end

	self:_set_updator("_upd_flying_strike")
end