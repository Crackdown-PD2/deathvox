Hooks:PostHook(AttentionTweakData, "init", "bot_att", function(self, tweakdata)
	self.settings.team_enemy_cbt = {
		max_range = 20000,
		reaction = "REACT_COMBAT",
		notice_interval = 1,
		relation = "foe",
		filter = "all",
		uncover_range = 400,
		notice_requires_FOV = true,
		verification_interval = 0.5,
		release_delay = 1,
		weight_mul = 1
	}
	self.settings.custom_enemy_suburbia_shootout = {
		max_range = 12000,
		reaction = "REACT_SHOOT",
		notice_requires_FOV = true,
		turn_around_range = 15000,
		weight_mul = 1.25,
		verification_interval = 0.5,
		release_delay = 5,
		filter = "all_enemy"
	}
	self.settings.sentry_gun_enemy_cbt_hacked = {
		uncover_range = 300,
		reaction = "REACT_COMBAT",
		release_delay = 1,
		weight_mul = 1.25,
		verification_interval = 1,
		relation = "foe",
		filter = "combatant"
	}
	
end)