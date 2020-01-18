

Hooks:PostHook(SkillTreeTweakData, "init", "vox_overhaul_init", function(self)
	if deathvox and deathvox:IsTotalCrackdownEnabled() then
		self.skills.fast_fire = {
			{
				upgrades = {
					"player_automatic_mag_increase_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_ricochet_rapid_fire_basic"
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
		
		self.skills.heavy_impact = {
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
		
	end
end)

