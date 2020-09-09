

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
		
	end
end)

