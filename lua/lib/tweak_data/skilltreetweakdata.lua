

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
				1
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
				7,
				11
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
				1,
				9
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
				0,
				11
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
				4
			}
		}
		
		--Medic
		
		--Chief
		
		--Enforcer
		
		self.skills.tender_meat = { --Tender Meat
			{
				upgrades = {
					"class_weapon_tender_meat_bodyshots"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"class_shotgun_tender_meat_stability"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_tender_meat",
			desc_id = "menu_tender_meat_desc",
			icon_xy = {
				10,
				3
			}
		}
		self.skills.heartbreaker = { --Heartbreaker
			{
				upgrades = {
					"class_shotgun_doublebarrel_firemode"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"class_shotgun_doublebarrel_damage"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_heartbreaker",
			desc_id = "menu_heartbreaker_desc",
			icon_xy = {
				4,
				1
			}
		}
		
		self.skills.shell_games = { --Shell Games
			{
				upgrades = {
					"class_shotgun_shell_games_reload_bonus"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"class_shotgun_shell_games_rof_bonus"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_shell_games",
			desc_id = "menu_shell_games_desc",
			icon_xy = {
				4,
				1
			}
		}
		self.skills.rolling_thunder = { --Rolling Thunder
			{
				upgrades = {
					"class_shotgun_rolling_thunder_magazine_size_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"class_shotgun_rolling_thunder_magazine_size_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_rolling_thunder",
			desc_id = "menu_rolling_thunder_desc",
			icon_xy = {
				8,
				7
			}
		}
		self.skills.point_blank = { --Point Blank
			{
				upgrades = {
					"class_shotgun_point_blank_shotgun_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"class_shotgun_point_blank_shotgun_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_point_blank",
			desc_id = "menu_point_blank_desc",
			icon_xy = {
				4,
				1
			}
		}
		
		self.skills.shotmaker = { --Shotmaker
			{
				upgrades = {
					"class_shotgun_shotmaker_headshot_damage_bonus_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"class_shotgun_shotmaker_headshot_damage_bonus_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_shotmaker",
			desc_id = "menu_shotmaker_desc",
			icon_xy = {
				6,
				11
			}
		}
		
		--Heavy
		
		--Runner
		
		--Gunner
		
		self.skills.spray_and_pray = { --Spray and Pray
			{
				upgrades = {
					"weapon_spray_and_pray_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_ap_bullets_1"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_spray_and_pray",
			desc_id = "menu_spray_and_pray_desc",
			icon_xy = {
				7,
				0
			}
		}
		
		self.skills.shot_grouping = { --Shot Grouping
			{
				upgrades = {
					"rapidfire_shotgrouping_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"rapidfire_shotgrouping_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_shot_grouping",
			desc_id = "menu_shot_grouping_desc",
			icon_xy = {
				9,
				11
			}
		}
		
		self.skills.money_shot = { --Money Shot
			{
				upgrades = {
					"weapon_moneyshot_rapid_fire_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"weapon_moneyshot_rapid_fire_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_money_shot",
			desc_id = "menu_money_shot_desc",
			icon_xy = {
				0,
				6
			}
		}
		
		self.skills.making_miracles = { --Making Miracles
			{
				upgrades = {
					"weapon_making_miracles_basic",
					"weapon_making_miracles_crit_cap_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"weapon_making_miracles_aced",
					"weapon_making_miracles_crit_cap_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_making_miracles",
			desc_id = "menu_making_miracles_desc",
			icon_xy = {
				0,
				12
			}
		}
			
		self.skills.close_enough = { --Close Enough
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
			name_id = "menu_close_enough",
			desc_id = "menu_close_enough_desc",
			icon_xy = {
				10,
				2
			}
		}
		
		self.skills.prayers_answered = { --Prayers Answered
			{
				upgrades = {
					"weapon_prayers_answered_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"weapon_prayers_answered_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_prayers_answered",
			desc_id = "menu_prayers_answered_desc",
			icon_xy = {
				2,
				9
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
				1,
				6
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
				1,
				6
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
				1,
				6
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
				1,
				6
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

--skilltrees; eventually this will override the whole trees table instead of selectively replacing by index
--[[
		self.trees[1] = { -- boss
			skill = "mastermind",
			name_id = "st_menu_dallas_boss",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					""
				},
				{
					""
				},
				{
					""
				},
				{
					""
				}
			}
		}
	
		self.trees[3] = { -- medic
			skill = "mastermind",
			name_id = "st_menu_dallas_medic",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					""
				},
				{
					""
				},
				{
					""
				},
				{
					""
				}
			}
		}
		self.trees[4] = { -- chief
			skill = "enforcer",
			name_id = "st_menu_chains_chief",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					""
				},
				{
					""
				},
				{
					""
				},
				{
					""
				}
			}
		}

		self.trees[6] = { -- heavy
			skill = "enforcer",
			name_id = "st_menu_chains_heavy",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					""
				},
				{
					""
				},
				{
					""
				},
				{
					""
				}
			}
		}
		self.trees[7] = { -- runner
			skill = "technician",
			name_id = "st_menu_wolf_runner",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					""
				},
				{
					""
				},
				{
					""
				},
				{
					""
				}
			}
		}

		self.trees[10] = { -- thief
			skill = "ghost",
			name_id = "st_menu_houston_thief",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					""
				},
				{
					""
				},
				{
					""
				},
				{
					""
				}
			}
		}
		self.trees[11] = { -- assassin
			skill = "ghost",
			name_id = "st_menu_houston_assassin",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					""
				},
				{
					""
				},
				{
					""
				},
				{
					""
				}
			}
		}
		self.trees[12] = { -- sapper
			skill = "ghost",
			name_id = "st_menu_houston_sapper",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					""
				},
				{
					""
				},
				{
					""
				},
				{
					""
				}
			}
		}
		self.trees[13] = { -- dealer
			skill = "fugitive",
			name_id = "st_menu_hoxton_dealer",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					""
				},
				{
					""
				},
				{
					""
				},
				{
					""
				}
			}
		}
		self.trees[14] = { -- fixer
			skill = "fugitive",
			name_id = "st_menu_hoxton_fixer",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					""
				},
				{
					""
				},
				{
					""
				},
				{
					""
				}
			}
		}
		self.trees[15] = { -- demolitions
			skill = "fugitive",
			name_id = "st_menu_hoxton_demolitions",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					""
				},
				{
					""
				},
				{
					""
				},
				{
					""
				}
			}
		}
--]]
		self.trees[2] = { ---marksman
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
		self.trees[5] = { --enforcer
			skill = "enforcer",
			name_id = "st_menu_chains_enforcer",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"tender_meat"
				},
				{
					"heartbreaker",
					"shell_games"
				},
				{
					"rolling_thunder",
					"point_blank"
				},
				{
					"shotmaker"
				}
			}
			
		}
		
		self.trees[8] = { --gunner
			skill = "technician",
			name_id = "st_menu_wolf_gunner",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"spray_and_pray"
				},
				{
					"money_shot",
					"shot_grouping"
				},
				{
					"close_enough",
					"making_miracles"
				},
				{
					"prayers_answered"
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
	end
end)

