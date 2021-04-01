local add_unit_by_name_original = HuskCopInventory.add_unit_by_name
function HuskCopInventory:add_unit_by_name(...)
	if self._unit:in_slot(16) then
		HuskTeamAIInventory.add_unit_by_name(self, ...)

		return
	else
		add_unit_by_name_original(self, ...)
	end
end
