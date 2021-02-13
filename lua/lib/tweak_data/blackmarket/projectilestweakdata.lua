Hooks:PostHook(BlackMarketTweakData, "_init_projectiles", "cdgren", function(self, tweak_data)
	self.projectiles.dv_grenadier_grenade = deep_clone(self.projectiles.launcher_frag)
	self.projectiles.dv_grenadier_grenade.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_grenadier_grenade"

	table.insert(self._projectiles_index, "dv_grenadier_grenade")
	
	--this mainly exists as the entry for the throwable slot; actual data (besides the maximum equipment count) are handled in equipmentstweakdata
	if deathvox:IsTotalCrackdownEnabled() then 
		self.projectiles.tripmine_throwable = {
			name_id = "bm_grenade_tripmine",
			desc_id = "bm_grenade_tripmine_desc",
			ignore_statistics = false,
			icon = "equipment_trip_mine", 
			texture_bundle_folder = nil,
			ability = false,
			dlc = false,
			throwable = true,
			max_amount = 6,
			is_a_grenade = true,
			instant_use = true,
			override_equipment_id = "tripmine_throwable" --reference key for corresponding data in equipmentstweakdata
		}
	
	end
end)
