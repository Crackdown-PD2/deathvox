function GageAssignmentBase:delete_unit()
	local unit = self._unit

	if not alive(unit) then
		return
	end

	if Network:is_server() then
		unit:set_slot(0)
	else
		self:set_active(false)
		unit:set_visible(false)

		local int_ext = unit:interaction()

		if int_ext then
			int_ext:set_active(false)
		end
	end
end
