local fs_original_playerstandard_update = PlayerStandard.update
function PlayerStandard:update(t, dt)
	fs_original_playerstandard_update(self, t, dt)

	if self._equipped_visibility_timer and t > self._equipped_visibility_timer and alive(self._equipped_unit) then
		self._equipped_visibility_timer = nil
	end
end

local fs_original_playerstandard_exit = PlayerStandard.exit
function PlayerStandard:exit(...)
	if self._shooting then
		local weap_base = self._equipped_unit:base()
		if not weap_base.akimbo or weap_base:weapon_tweak_data().allow_akimbo_autofire then
			self._ext_network:send('sync_stop_auto_fire_sound')
		end
	end

	return fs_original_playerstandard_exit(self, ...)
end