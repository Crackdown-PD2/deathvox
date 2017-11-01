function QuickCsGrenade:_setup_from_tweak_data()
	local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
	local difficulty_index = tweak_data:difficulty_to_index(difficulty)
	local grenade_entry = self._tweak_projectile_entry or "cs_grenade_quick"
	self._tweak_data = tweak_data.projectiles[grenade_entry]
	self._radius = self._tweak_data.radius or 300
	self._radius_blurzone_multiplier = self._tweak_data.radius_blurzone_multiplier or 1.3
	self._damage_per_tick = 0
end