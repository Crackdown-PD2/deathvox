function SentryGunMovement:_update_rearming(t, dt)
	self:_upd_hacking(t, dt)

	if self._rearm_complete_t and self._rearm_complete_t < t then
		self:complete_rearming()
	end
end

function SentryGunMovement:_update_repairing(t, dt)
	self:_upd_hacking(t, dt)

	if self._repair_complete_t then
		local repair_complete_ratio = 1 - (self._repair_complete_t - t) / self._tweak.AUTO_REPAIR_DURATION

		self._unit:character_damage():update_shield_smoke_level(repair_complete_ratio, true)

		if self._repair_complete_t < t then
			self:complete_repairing()
		end
	end
end
