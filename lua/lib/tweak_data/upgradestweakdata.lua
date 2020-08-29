

Hooks:PostHook(UpgradesTweakData, "init", "vox_overhaul1", function(self, tweak_data)
	if deathvox and deathvox:IsTotalCrackdownEnabled() then
	
		--Boss
		
		--Marksman
		
		--Medic
		
		--Chief
		
		--Enforcer
		
		self.values.player.point_blank = {
			true
		}
		
		self.values.player.point_blank_aced = {
			true
		}
		
		self.definitions.player_point_blank_shotgun_basic = {
			name_id = "menu_point_blank_shotgun_basic",
			category = "feature",
			upgrade = {
			value = 1,
			upgrade = "point_blank",
				category = "player"
			}
		}
					
		self.definitions.player_point_blank_shotgun_aced = {
			name_id = "menu_point_blank_shotgun_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "point_blank_aced",
				category = "player"
			}
		}
		
		--Heavy
		
		--Runner
		
		--Gunner
		
		self.values.player.spray_and_pray_basic = {
			0.1
		}
		
		self.definitions.player_spray_and_pray_basic = {
			name_id = "menu_spray_and_pray_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "spray_and_pray_basic",
				category = "player"
			}
		}
		
		self.values.player.money_shot = {
			true
		}
		
		self.values.player.money_shot_aced = {
			1.5
		}
			
		self.definitions.player_moneyshot_rapid_fire_basic = {
			name_id = "menu_moneyshot_rapid_fire_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "money_shot",
				category = "player"
			}
		}
					
		self.definitions.player_moneyshot_rapid_fire_aced = {
			name_id = "menu_moneyshot_rapid_fire_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "money_shot_aced",
				category = "player"
			}
		}
	
		self.values.player.ricochet_bullets = {
			true
		}
			
		self.values.player.ricochet_bullets_aced = {
			true
		}
		
		self.definitions.player_ricochet_rapid_fire_basic = {
			name_id = "menu_ricochet_rapid_fire_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "ricochet_bullets",
				category = "player"
			}
		}
					
		self.definitions.player_ricochet_rapid_fire_aced = {
			name_id = "menu_ricochet_rapid_fire_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "ricochet_bullets_aced",
				category = "player"
			}
		}
		
		--Engineer
		
		--Thief
		
		--Assassin
		
		--Sapper
		
		--Dealer
		
		--Fixer
		
		--Demolitions
		
		-- Perk Decks
		
		-- Crew Chief
		self.values.player.crew_chief_t1 = {
			true
		}
		
		self.definitions.crew_chief_t1 = {
			name_id = "unused",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "crew_chief_t1",
				category = "player"
			}
		}
		
		self.values.player.crew_chief_t2 = {
			true
		}
		
		self.definitions.crew_chief_t2 = {
			name_id = "unused",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "crew_chief_t2",
				category = "player"
			}
		}

		self.values.player.crew_chief_t3 = {
			true
		}
		
		self.definitions.crew_chief_t3 = {
			name_id = "unused",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "crew_chief_t3",
				category = "player"
			}
		}
		
		self.values.player.crew_chief_t4 = {
			true
		}
		
		self.definitions.crew_chief_t4 = {
			name_id = "unused",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "crew_chief_t4",
				category = "player"
			}
		}
		
		self.values.player.crew_chief_t5 = {
			true
		}
		
		self.definitions.crew_chief_t5 = {
			name_id = "unused",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "crew_chief_t5",
				category = "player"
			}
		}

		self.values.player.crew_chief_t6 = {
			true
		}
		
		self.definitions.crew_chief_t6 = {
			name_id = "unused",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "crew_chief_t6",
				category = "player"
			}
		}

		self.values.player.crew_chief_t7 = {
			true
		}
		
		self.definitions.crew_chief_t7 = {
			name_id = "unused",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "crew_chief_t7",
				category = "player"
			}
		}

		self.values.player.crew_chief_t8 = {
			true
		}
		
		self.definitions.crew_chief_t8 = {
			name_id = "unused",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "crew_chief_t8",
				category = "player"
			}
		}


		self.values.player.crew_chief_t9 = {
			true
		}
		
		self.definitions.crew_chief_t9 = {
			name_id = "unused",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "crew_chief_t9",
				category = "player"
			}
		}
		-- Muscle
		self.values.player.muscle_t1 = {
			true
		}
		
		self.definitions.muscle_t1 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "muscle_t1",
				category = "player"
			}
		}
		
		self.values.player.muscle_t2 = {
			true
		}
		
		self.definitions.muscle_t2 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "muscle_t2",
				category = "player"
			}
		}

		self.values.player.muscle_t3 = {
			true
		}
		
		self.definitions.muscle_t3 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "muscle_t3",
				category = "player"
			}
		}
		
		self.values.player.muscle_t4 = {
			true
		}
		
		self.definitions.muscle_t4 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "muscle_t4",
				category = "player"
			}
		}
		
		self.values.player.muscle_t5 = {
			true
		}
		
		self.definitions.muscle_t5 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "muscle_t5",
				category = "player"
			}
		}

		self.values.player.muscle_t6 = {
			true
		}
		
		self.definitions.muscle_t6 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "muscle_t6",
				category = "player"
			}
		}

		self.values.player.muscle_t7 = {
			true
		}
		
		self.definitions.muscle_t7 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "muscle_t7",
				category = "player"
			}
		}

		self.values.player.muscle_t8 = {
			true
		}
		
		self.definitions.muscle_t8 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "muscle_t8",
				category = "player"
			}
		}


		self.values.player.muscle_t9 = {
			true
		}
		
		self.definitions.muscle_t9 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "muscle_t9",
				category = "player"
			}
		}
		-- Armorer
		self.values.player.armorer_t1 = {
			true
		}
		
		self.definitions.armorer_t1 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "armorer_t1",
				category = "player"
			}
		}
		
		self.values.player.armorer_t2 = {
			true
		}
		
		self.definitions.armorer_t2 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "armorer_t2",
				category = "player"
			}
		}

		self.values.player.armorer_t3 = {
			true
		}
		
		self.definitions.armorer_t3 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "armorer_t3",
				category = "player"
			}
		}
		
		self.values.player.armorer_t4 = {
			true
		}
		
		self.definitions.armorer_t4 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "armorer_t4",
				category = "player"
			}
		}
		
		self.values.player.armorer_t5 = {
			true
		}
		
		self.definitions.armorer_t5 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "armorer_t5",
				category = "player"
			}
		}

		self.values.player.armorer_t6 = {
			true
		}
		
		self.definitions.armorer_t6 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "armorer_t6",
				category = "player"
			}
		}


		self.values.player.armorer_t7 = {
			true
		}
		
		self.definitions.armorer_t7 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "armorer_t7",
				category = "player"
			}
		}

		self.values.player.armorer_t8 = {
			true
		}
		
		self.definitions.armorer_t8 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "armorer_t8",
				category = "player"
			}
		}


		self.values.player.armorer_t9 = {
			true
		}
		
		self.definitions.armorer_t9 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "armorer_t9",
				category = "player"
			}
		}
		-- rogue
		self.values.player.rogue_t1 = {
			true
		}
		
		self.definitions.rogue_t1 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "rogue_t1",
				category = "player"
			}
		}
		
		self.values.player.rogue_t2 = {
			true
		}
		
		self.definitions.rogue_t2 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "rogue_t2",
				category = "player"
			}
		}

		self.values.player.rogue_t3 = {
			true
		}
		
		self.definitions.rogue_t3 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "rogue_t3",
				category = "player"
			}
		}
		
		self.values.player.rogue_t4 = {
			true
		}
		
		self.definitions.rogue_t4 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "rogue_t4",
				category = "player"
			}
		}
		
		self.values.player.rogue_t5 = {
			true
		}
		
		self.definitions.rogue_t5 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "rogue_t5",
				category = "player"
			}
		}

		self.values.player.rogue_t6 = {
			true
		}
		
		self.definitions.rogue_t6 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "rogue_t6",
				category = "player"
			}
		}


		self.values.player.rogue_t7 = {
			true
		}
		
		self.definitions.rogue_t7 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "rogue_t7",
				category = "player"
			}
		}

		self.values.player.rogue_t8 = {
			true
		}
		
		self.definitions.rogue_t8 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "rogue_t8",
				category = "player"
			}
		}


		self.values.player.rogue_t9 = {
			true
		}	
		
		self.definitions.rogue_t9 = {
			name_id = "unused",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "rogue_t9",
				category = "player"
			}
		}
	end	
end)