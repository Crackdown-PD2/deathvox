Hooks:PostHook(AttentionTweakData, "init", "cd_att", function(self, tweakdata)
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
		reaction = "REACT_COMBAT",
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
	self.settings.prop_civ_ene_ntl = {
		uncover_range = 500,
		reaction = "REACT_SCARED",
		notice_requires_FOV = true,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "civilians_enemies"
	}
	self.settings.prop_ene_ntl_edaycrate = {
		uncover_range = 300,
		reaction = "REACT_SCARED",
		notice_requires_FOV = true,
		max_range = 700,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "all_enemy"
	}
	self.settings.prop_ene_ntl = {
		uncover_range = 500,
		reaction = "REACT_SCARED",
		notice_requires_FOV = true,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "all_enemy"
	}
	self.settings.broken_cam_ene_ntl = {
		uncover_range = 100,
		reaction = "REACT_SCARED",
		notice_requires_FOV = true,
		max_range = 1200,
		suspicion_range = 1000,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "law_enforcer"
	}
	self.settings.no_staff_ene_ntl = {
		uncover_range = 100,
		reaction = "REACT_SCARED",
		notice_requires_FOV = true,
		max_range = 1200,
		suspicion_range = 1000,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "law_enforcer"
	}
	self.settings.timelock_ene_ntl = {
		uncover_range = 100,
		reaction = "REACT_SCARED",
		notice_requires_FOV = true,
		max_range = 1200,
		suspicion_range = 1000,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "law_enforcer"
	}
	self.settings.open_security_gate_ene_ntl = {
		uncover_range = 100,
		reaction = "REACT_SCARED",
		notice_requires_FOV = true,
		max_range = 1200,
		suspicion_range = 1000,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "law_enforcer"
	}
	self.settings.open_vault_ene_ntl = {
		uncover_range = 100,
		reaction = "REACT_SCARED",
		notice_requires_FOV = true,
		max_range = 600,
		suspicion_range = 500,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "law_enforcer"
	}
	self.settings.open_elevator_ene_ntl = {
		uncover_range = 800,
		reaction = "REACT_SCARED",
		notice_requires_FOV = true,
		max_range = 1500,
		suspicion_range = 1200,
		verification_interval = 0.4,
		release_delay = 1,
		filter = "civilians_enemies"
	}
	self.settings.pl_foe_non_combatant_cbt_stand.relation = nil
end)
