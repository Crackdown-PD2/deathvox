

Hooks:PostHook(SkillTreeTweakData, "init", "vox_overhaul_init", function(self)
	if deathvox and deathvox:IsTotalCrackdownEnabled() then
		--Boss
		
		--Marksman
		
		--Medic
		
		--Chief
		
		--Enforcer
		
		self.skills.far_away = { --Point Blank
			{
				upgrades = {
					"player_point_blank_shotgun_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_point_blank_shotgun_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_far_away_beta",
			desc_id = "menu_far_away_beta_desc",
			icon_xy = {
				8,
				5
			}
		}
		
		--Heavy
		
		--Runner
		
		--Gunner
		
		self.skills.steady_grip = { --Spray and Pray
			{
				upgrades = {
					"player_spray_and_pray_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_ap_bullets_1"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_steady_grip_beta",
			desc_id = "menu_steady_grip_beta_desc",
			icon_xy = {
				9,
				11
			}
		}
		
		self.skills.fire_control = { --Shot Grouping
			{
				upgrades = {
					"player_shotgrouping_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_shotgrouping_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_fire_control_beta",
			desc_id = "menu_fire_control_beta_desc",
			icon_xy = {
				9,
				10
			}
		}
		
		self.skills.heavy_impact = { --Money Shot
			{
				upgrades = {
					"player_moneyshot_rapid_fire_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_moneyshot_rapid_fire_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_heavy_impact_beta",
			desc_id = "menu_heavy_impact_beta_desc",
			icon_xy = {
				10,
				1
			}
		}
		
		self.skills.shock_and_awe = { --Making Miracles
			{
				upgrades = {
					"player_making_miracles_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_making_miracles_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_shock_and_awe_beta",
			desc_id = "menu_shock_and_awe_beta_desc",
			icon_xy = {
				10,
				0
			}
		}
			
		self.skills.fast_fire = { --Close Enough
			{
				upgrades = {
					"player_ricochet_rapid_fire_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_ricochet_rapid_fire_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_fast_fire_beta",
			desc_id = "menu_fast_fire_beta_desc",
			icon_xy = {
				10,
				2
			}
		}
		
		self.skills.body_expertise = { --Prayers Answered
			{
				upgrades = {
					"player_prayers_answered_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_prayers_answered_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_body_expertise_beta",
			desc_id = "menu_body_expertise_beta_desc",
			icon_xy = {
				10,
				3
			}
		}
		
		--Engineer
		self.skills.defense_up = { --Digging In
			{
				upgrades = {
					"player_digging_in_deploy_time",
					"sentry_gun_digging_in_retrieve_time"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"sentry_gun_shield"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_digging_in",
			desc_id = "menu_digging_in_desc",
			icon_xy = {
				9,
				0
			}
		}

		self.skills.sentry_targeting_package = { --Advanced Rangefinder
			{
				upgrades = {
					"sentry_gun_advanced_rangefinder_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"sentry_gun_advanced_rangefinder_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_advanced_rangefinder",
			desc_id = "menu_advanced_rangefinder_desc",
			icon_xy = {
				9,
				1
			}
		}

		self.skills.eco_sentry = { --Targeting Matrix
			{
				upgrades = {
					"sentry_gun_targeting_matrix_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"sentry_gun_targeting_matrix_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_targeting_matrix",
			desc_id = "menu_targeting_matrix_desc",
			icon_xy = {
				9,
				2
			}
		}

		self.skills.engineering = { --Wrangler
			{
				upgrades = {
					"sentry_gun_wrangler_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"sentry_gun_wrangler_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_wrangler",
			desc_id = "menu_wrangler_desc",
			icon_xy = {
				9,
				3
			}
		}
		
		self.skills.jack_of_all_trades = { --Hobart's Funnies
			{
				upgrades = {
					"sentry_gun_hobarts_funnies_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"sentry_gun_hobarts_funnies_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_hobarts_funnies",
			desc_id = "menu_hobarts_funnies_desc",
			icon_xy = {
				9,
				4
			}
		}
		
		self.skills.tower_defense = { --Killer Machines
			{
				upgrades = {
					"sentry_gun_killer_machines"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"sentry_gun_quantity_1"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_killer_machines",
			desc_id = "menu_killer_machines_desc",
			icon_xy = {
				9,
				5
			}
		}
		
		
		
		--add sentry targeting basic/aced to default upgrades
		table.insert(self.default_upgrades,"sentry_gun_spread_multiplier")
		table.insert(self.default_upgrades,"sentry_gun_extra_ammo_multiplier_1")
		table.insert(self.default_upgrades,"sentry_gun_rot_speed_multiplier")
		table.insert(self.default_upgrades,"sentry_gun_ap_bullets") --this is necessary to enable the sentry gun firemode interactions, I GUESS
		
		--Thief
		
		--Assassin
		
		self.skills.backstab = { --professional's choice
			{
				upgrades = {
					"player_professionalschoice_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_professionalschoice_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_backstab_beta",
			desc_id = "menu_backstab_beta_desc",
			icon_xy = {
				0,
				12
			}
		}
		
		--Sapper
		
		--Dealer
		
		--Fixer
		
		--Demolitions
		
	end
end)

