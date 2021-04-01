function Pickup:delete_unit()
	local unit = self._unit

	if Network:is_server() then
		World:delete_unit(unit)
	else
		self:set_active(false)
		unit:set_visible(false)

		local int_ext = unit:interaction()

		if int_ext then
			int_ext:set_active(false)
		end
	end
end
