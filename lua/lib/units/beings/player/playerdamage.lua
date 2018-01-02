Hooks:PostHook( PlayerDamage, "init", "PlayerDamageLivesFix", function(self, ...)
	local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	if difficulty_index == 8 then
		self._lives_init = 3
		self._lives_init = managers.crime_spree:modify_value("PlayerDamage:GetMaximumLives", self._lives_init)
	end
	self:replenish()
end )