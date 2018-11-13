local fs_original_ammobagbase_setempty = AmmoBagBase._set_empty
function AmmoBagBase:_set_empty()
	local original_slot = self._unit:slot()
	fs_original_ammobagbase_setempty(self)
	DelayedCalls:Add('DelayedModFSS_ammobagbasesetempty_' .. tostring(self._unit:key()), 5, function()
		if alive(self._unit) then
			self._unit:set_slot(original_slot)
		end
	end)
end
