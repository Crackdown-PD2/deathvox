Hooks:PostHook(BlackMarketTweakData, "_init_projectiles", "cdgren", function(self, tweak_data)
	self.projectiles.dv_grenadier_grenade = deep_clone(self.projectiles.launcher_frag)
	self.projectiles.dv_grenadier_grenade.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_grenadier_grenade"

	table.insert(self._projectiles_index, "dv_grenadier_grenade")
end)
