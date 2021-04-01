local att_str = Idstring("attention")

function AIAttentionObject:set_update_enabled(state)
	if not self._attention_data then
		state = false
	end

	self._unit:set_extension_update_enabled(att_str, state)
end

function AIAttentionObject:_do_late_update()
	if not self._attention_obj or not self._observer_info or not alive(self._unit) then
		return
	end

	self:update()
end

--[[function AIAttentionObject:update()
	self._attention_obj:m_position(self._observer_info.m_pos)

	local cam_pos = managers.viewport:get_current_camera_position()

	if cam_pos then
		local from_pos = cam_pos + math.DOWN * 50
		local color = nil

		if not self._parent_unit then
			if not self._unit then
				color = Color.yellow:with_alpha(0.5)
			elseif not alive(self._unit) then
				color = Color.red:with_alpha(0.5)
			else
				color = Color.white:with_alpha(0.5)
			end
		elseif not alive(self._parent_unit) then
			color = Color.red:with_alpha(0.5)
		else
			color = Color.green:with_alpha(0.5)
		end

		local brush = Draw:brush(color, 0.1)
		brush:cylinder(from_pos, self._observer_info.m_pos, 1)
	end
end]]
