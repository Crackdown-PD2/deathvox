function SpecializationTierItem:update_size(dt, tree_selected)
	local size = {
		self._tier_panel:size()
	}
	local end_size = tree_selected and self._selected_size or self._basic_size
	local is_done = true
	local lerp_size, step_size = nil

	for i = 1, #size do
		lerp_size = math.lerp(size[i], end_size[i], dt * 10)
		step_size = math.step(size[i], end_size[i], dt * 20)
		size[i] = math.abs(size[i] - lerp_size) < math.abs(size[i] - step_size) and step_size or lerp_size

		if is_done and size[i] ~= end_size[i] then
			is_done = false
		end
	end

	local cx, cy = self._tier_panel:center()

	self._tier_panel:set_size(unpack(size))
	self._tier_panel:set_center(cx, cy)
	self._select_box_panel:set_center(self._tier_panel:w() / 2, self._tier_panel:h() / 2)

	if not self._rotation_start_t then
		self._rotation_start_t = Application:time()
	end

	local tweak_data = tweak_data.skilltree.specializations[self._tree]
	if tweak_data.shake then
		if tree_selected then
			local time_since_start = Application:time() - self._rotation_start_t
			local rotation = math.sin(time_since_start * 100) * 10

			for _, child in pairs(self._tier_panel:children()) do
				if child.set_rotation then
					child:set_rotation(rotation)
				end
			end

			return false
		else
			for _, child in pairs(self._tier_panel:children()) do
				if child.set_rotation then
					local rotation = child:rotation()
					local lerp_rotation = math.lerp(rotation, 0, dt * 10)
					local step_rotation = math.step(rotation, 0, dt * 20)
					rotation = math.abs(rotation - lerp_rotation) < math.abs(rotation - step_rotation) and step_rotation or lerp_rotation

					child:set_rotation(rotation)
				end
			end

			self._rotation_start_t = nil
		end
	end

	return is_done
end