

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
		
		--Engineer
		
		--add sentry targeting basic/aced to default upgrades
		table.insert(self.default_upgrades,"sentry_gun_spread_multiplier")
		table.insert(self.default_upgrades,"sentry_gun_extra_ammo_multiplier_1")
		table.insert(self.default_upgrades,"sentry_gun_rot_speed_multiplier")
		
		--Thief
		
		--Assassin
		
		--Sapper
		
		--Dealer
		
		--Fixer
		
		--Demolitions
		
		-- Perk Decks
		-- DON'T TAMPER WITH THE COSTS! This can cause save file problems.
		self.specializations[1] = {
			{
				cost = 200,
				desc_id = "crew_chief_t1_desc",
				name_id = "crew_chief_t1_name",
				upgrades = {
					"crew_chief_t1",
				},
				icon_xy = {
					0,
					0
				}
			},
			{
				cost = 300,
				desc_id = "crew_chief_t2_desc",
				name_id = "crew_chief_t2_name",
				upgrades = {
					"crew_chief_t2",
				},
				icon_xy = {
					0,
					0
				}
			},
			{
				cost = 400,
				desc_id = "crew_chief_t3_desc",
				name_id = "crew_chief_t3_name",
				upgrades = {
					"crew_chief_t3"
				},
				icon_xy = {
					2,
					0
				}
			},
			{
				cost = 600,
				desc_id = "crew_chief_t4_desc",
				name_id = "crew_chief_t4_name",
				upgrades = {
					"crew_chief_t4"
				},
				icon_xy = {
					2,
					0
				}
			},
			{
				cost = 1000,
				desc_id = "crew_chief_t5_desc",
				name_id = "crew_chief_t5_name",
				upgrades = {
					"crew_chief_t5"
				},
				icon_xy = {
					4,
					0
				}
			},
			{
				cost = 1600,
				desc_id = "crew_chief_t6_desc",
				name_id = "crew_chief_t6_name",
				upgrades = {
					"crew_chief_t6"
				},
				icon_xy = {
					2,
					0
				}
			},
			{
				cost = 2400,
				desc_id = "crew_chief_t7_desc",
				name_id = "crew_chief_t7_name",
				upgrades = {
					"crew_chief_t7"
				},
				icon_xy = {
					6,
					0
				}
			},
			{
				cost = 3200,
				desc_id = "crew_chief_t8_desc",
				name_id = "crew_chief_t8_name",
				upgrades = {
					"crew_chief_t8"
				},
				icon_xy = {
					4,
					0
				}
			},
			{
				cost = 4000,
				desc_id = "crew_chief_t9_desc",
				name_id = "crew_chief_t9_name",
				upgrades = {
					"crew_chief_t9"
				},
				icon_xy = {
					0,
					1
				}
			},
			desc_id = "crew_chief_deck_desc",
			name_id = "crew_chief_deck"
		}
		-- Muscle
		self.specializations[2] = {
			{
				cost = 200,
				desc_id = "muscle_t1_desc",
				name_id = "muscle_t1_name",
				upgrades = {
					"muscle_t1",
				},
				icon_xy = {
					0,
					0
				}
			},
			{
				cost = 300,
				desc_id = "muscle_t2_desc",
				name_id = "muscle_t2_name",
				upgrades = {
					"muscle_t2",
				},
				icon_xy = {
					0,
					0
				}
			},
			{
				cost = 400,
				desc_id = "muscle_t3_desc",
				name_id = "muscle_t3_name",
				upgrades = {
					"muscle_t3"
				},
				icon_xy = {
					2,
					0
				}
			},
			{
				cost = 600,
				desc_id = "muscle_t4_desc",
				name_id = "muscle_t4_name",
				upgrades = {
					"muscle_t4"
				},
				icon_xy = {
					2,
					0
				}
			},
			{
				cost = 1000,
				desc_id = "muscle_t5_desc",
				name_id = "muscle_t5_name",
				upgrades = {
					"muscle_t5"
				},
				icon_xy = {
					4,
					0
				}
			},
			{
				cost = 1600,
				desc_id = "muscle_t6_desc",
				name_id = "muscle_t6_name",
				upgrades = {
					"muscle_t6"
				},
				icon_xy = {
					2,
					0
				}
			},
			{
				cost = 2400,
				desc_id = "muscle_t7_desc",
				name_id = "muscle_t7_name",
				upgrades = {
					"muscle_t7"
				},
				icon_xy = {
					6,
					0
				}
			},
			{
				cost = 3200,
				desc_id = "muscle_t8_desc",
				name_id = "muscle_t8_name",
				upgrades = {
					"muscle_t8"
				},
				icon_xy = {
					4,
					0
				}
			},
			{
				cost = 4000,
				desc_id = "muscle_t9_desc",
				name_id = "muscle_t9_name",
				upgrades = {
					"muscle_t9"
				},
				icon_xy = {
					0,
					1
				}
			},
			desc_id = "muscle_deck_desc",
			name_id = "muscle_deck"
		}
		-- Muscle
		self.specializations[3] = {
			{
				cost = 200,
				desc_id = "armorer_t1_desc",
				name_id = "armorer_t1_name",
				upgrades = {
					"armorer_t1",
				},
				icon_xy = {
					0,
					0
				}
			},
			{
				cost = 300,
				desc_id = "armorer_t2_desc",
				name_id = "armorer_t2_name",
				upgrades = {
					"armorer_t2",
				},
				icon_xy = {
					0,
					0
				}
			},
			{
				cost = 400,
				desc_id = "armorer_t3_desc",
				name_id = "armorer_t3_name",
				upgrades = {
					"armorer_t3"
				},
				icon_xy = {
					2,
					0
				}
			},
			{
				cost = 600,
				desc_id = "armorer_t4_desc",
				name_id = "armorer_t4_name",
				upgrades = {
					"armorer_t4"
				},
				icon_xy = {
					2,
					0
				}
			},
			{
				cost = 1000,
				desc_id = "armorer_t5_desc",
				name_id = "armorer_t5_name",
				upgrades = {
					"armorer_t5"
				},
				icon_xy = {
					4,
					0
				}
			},
			{
				cost = 1600,
				desc_id = "armorer_t6_desc",
				name_id = "armorer_t6_name",
				upgrades = {
					"armorer_t6"
				},
				icon_xy = {
					2,
					0
				}
			},
			{
				cost = 2400,
				desc_id = "armorer_t7_desc",
				name_id = "armorer_t7_name",
				upgrades = {
					"armorer_t7"
				},
				icon_xy = {
					6,
					0
				}
			},
			{
				cost = 3200,
				desc_id = "armorer_t8_desc",
				name_id = "armorer_t8_name",
				upgrades = {
					"armorer_t8"
				},
				icon_xy = {
					4,
					0
				}
			},
			{
				cost = 4000,
				desc_id = "armorer_t9_desc",
				name_id = "armorer_t9_name",
				upgrades = {
					"armorer_t9"
				},
				icon_xy = {
					0,
					1
				}
			},
			desc_id = "armorer_deck_desc",
			name_id = "armorer_deck"
		}
		
		
	end
end)

