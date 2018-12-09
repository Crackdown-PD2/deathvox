function GamePlayCentralManager:set_flashlights_on(flashlights_on)
	if self._flashlights_on == flashlights_on then
		return
	end

	self._flashlights_on = flashlights_on
	local weapons = World:find_units('all', 13)
	for _, weapon in ipairs(weapons) do
		weapon:base():flashlight_state_changed()
	end
end
