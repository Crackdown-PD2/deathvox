

Hooks:PostHook(UpgradesTweakData, "init", "vox_overhaul1", function(self, tweak_data)
	if deathvox and deathvox:IsTotalCrackdownEnabled() then
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
			
		self.values.player.ricochet_bullets = {
			true
		}
			
		self.values.player.ricochet_bullets_aced = {
			true
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
		
		self.values.player.money_shot = {
			true
		}
		
		self.values.player.money_shot_aced = {
			1.5
		}
		
		self.values.player.ricochet_bullets = {
			true
		}
			
		self.values.player.ricochet_bullets_aced = {
			true
		}
	end	
end)