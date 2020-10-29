function SecurityCamera:_request_start_tape_loop_by_upgrade_level(time_upgrade_level)
	if not Network:is_server() then
		return
	end

	if alive(SecurityCamera.active_tape_loop_unit) then
		return
	end

	self:_start_tape_loop_by_upgrade_level(time_upgrade_level)

	if time_upgrade_level == 1 then
		self:_send_net_event(self._NET_EVENTS.start_tape_loop_1)
	elseif time_upgrade_level == 2 then
		self:_send_net_event(self._NET_EVENTS.start_tape_loop_2)
	end
end

function SecurityCamera:_deactivate_tape_loop()
	if Network:is_server() then
		self:_send_net_event(self._NET_EVENTS.deactivate_tape_loop)
	end

	if SecurityCamera.active_tape_loop_unit and SecurityCamera.active_tape_loop_unit == self._unit then
		SecurityCamera.active_tape_loop_unit = nil

		self._unit:contour():remove("mark_unit_friendly")
	end

	if self._tape_loop_expired_clbk_id then
		managers.enemy:remove_delayed_clbk(self._tape_loop_expired_clbk_id)

		self._tape_loop_end_t = nil
		self._tape_loop_expired_clbk_id = nil
	end

	if self._camera_wrong_image_sound then
		self._camera_wrong_image_sound:stop()

		self._camera_wrong_image_sound = nil
	end

	if self._tape_loop_restarting_t then
		self:_deactivate_tape_loop_restart()
	end

	if self._unit:interaction() then
		self._unit:interaction():set_active(false)
	end
end

function SecurityCamera:destroy(unit)
	table.delete(SecurityCamera.cameras, self._unit)

	self._destroying = true

	self:set_detection_enabled(false)

	if self._call_police_clbk_id then
		managers.enemy:remove_delayed_clbk(self._call_police_clbk_id)

		self._call_police_clbk_id = nil
	end

	if self._tape_loop_expired_clbk_id then
		managers.enemy:remove_delayed_clbk(self._tape_loop_expired_clbk_id)

		self._tape_loop_expired_clbk_id = nil
	end

	if SecurityCamera.active_tape_loop_unit and SecurityCamera.active_tape_loop_unit == self._unit then
		SecurityCamera.active_tape_loop_unit = nil
	end
end