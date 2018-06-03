local old_init_projectiles = BlackMarketTweakData._init_projectiles
function BlackMarketTweakData:_init_projectiles(tweak_data)
	old_init_projectiles(self, tweak_data)
	self.projectiles.dv_grenadier_grenade = deep_clone(self.projectiles.launcher_frag)
	self.projectiles.dv_grenadier_grenade.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_grenadier_grenade"
	table.insert(self._projectiles_index, "dv_grenadier_grenade")
end