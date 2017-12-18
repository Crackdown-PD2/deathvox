function UnitNetworkHandler:sync_cs_grenade(detonate_pos, shooter_pos, duration, damage, d_rad)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.groupai:state():sync_cs_grenade(detonate_pos, shooter_pos, duration, damage, d_rad)
end