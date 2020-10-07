

Hooks:PostHook(SkillTreeTweakData, "init", "vox_overhaul_init", function(self)
	if deathvox and deathvox:IsTotalCrackdownEnabled() then
		--Boss
		
		--Marksman
		self.skills.point_and_click = { --Point and Click
			{
				upgrades = {
					"player_point_and_click_basic",
					"weapon_point_and_click_damage_bonus"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"weapon_marksman_steelsight_speed_multiplier"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_point_and_click",
			desc_id = "menu_point_and_click_desc",
			icon_xy = {
				8,
				5
			}
		}
		
		self.skills.tap_the_trigger = { --Tap the Trigger
			{
				upgrades = {
					"weapon_tap_the_trigger_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"weapon_tap_the_trigger_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_tap_the_trigger",
			desc_id = "menu_tap_the_trigger_desc",
			icon_xy = {
				8,
				5
			}
		}
		
		self.skills.investment_returns = { --Investment Returns
			{
				upgrades = {
					"player_investment_returns_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_investment_returns_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_investment_returns",
			desc_id = "menu_investment_returns_desc",
			icon_xy = {
				8,
				5
			}
		}
		
		self.skills.this_machine = { --This Machine
			{
				upgrades = {
					"weapon_this_machine_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"weapon_this_machine_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_this_machine",
			desc_id = "menu_this_machine_desc",
			icon_xy = {
				8,
				5
			}
		}
		
		self.skills.mulligan = { --Mulligan
			{
				upgrades = {
					"player_mulligan_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_mulligan_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_mulligan",
			desc_id = "menu_mulligan_desc",
			icon_xy = {
				8,
				5
			}
		}
		
		self.skills.magic_bullet = { --Magic Bullet
			{
				upgrades = {
					"weapon_magic_bullet_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"weapon_magic_bullet_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_magic_bullet",
			desc_id = "menu_magic_bullet_desc",
			icon_xy = {
				8,
				5
			}
		}
		
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
		
		self.skills.digging_in = { --Digging In
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

		self.skills.advanced_rangefinder = { --Advanced Rangefinder
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

		self.skills.targeting_matrix = { --Targeting Matrix
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

		self.skills.wrangler = { --Wrangler
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
		
		self.skills.hobarts_funnies = { --Hobart's Funnies
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
		
		self.skills.killer_machines = { --Killer Machines
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



		self.trees[2] = {
			skill = "mastermind",
			name_id = "st_menu_dallas_marksman",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"point_and_click"
				},
				{
					"tap_the_trigger",
					"investment_returns"
				},
				{
					"this_machine",
					"mulligan"
				},
				{
					"magic_bullet"
				}
			}
		}
		
		self.trees[7] = { --should be 9 when the other subtrees are done
			skill = "technician",
			name_id = "st_menu_wolf_engineer",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"digging_in"
				},
				{
					"advanced_rangefinder",
					"targeting_matrix"
				},
				{
					"wrangler",
					"hobarts_funnies"
				},
				{
					"killer_machines"
				}
			}
		}

		
		--add sentry targeting basic/aced to default upgrades
		table.insert(self.default_upgrades,"sentry_gun_spread_multiplier")
		table.insert(self.default_upgrades,"sentry_gun_extra_ammo_multiplier_1")
		table.insert(self.default_upgrades,"sentry_gun_rot_speed_multiplier")
		table.insert(self.default_upgrades,"sentry_gun_ap_bullets") --this is necessary to enable the sentry gun firemode interactions, I GUESS

	end
end)

