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
			no_cheat_count = true,
			texture_bundle_folder = nil,
			ability = false,
			dlc = false,
			throwable = true,
			max_amount = 6,
			is_a_grenade = true,
			instant_use = true,
			override_equipment_id = "tripmine_throwable", --reference key for corresponding data in equipmentstweakdata
			primary_class = "class_grenade",
			subclasses = {}
		}

		self.projectiles.wpn_prj_four.max_amount = 10
		self.projectiles.wpn_prj_four.can_pierce_armor = false
		self.projectiles.wpn_prj_four.no_cheat_count = true
		self.projectiles.wpn_prj_four.primary_class = "class_throwing"
		self.projectiles.wpn_prj_four.subclasses = {
			"subclass_poison"
		}
		
		self.projectiles.wpn_prj_ace.primary_class = "class_throwing"
		self.projectiles.wpn_prj_ace.subclasses = {}
		self.projectiles.wpn_prj_ace.max_amount = 20
		self.projectiles.wpn_prj_ace.can_pierce_armor = false
		self.projectiles.wpn_prj_ace.no_cheat_count = true
		
		self.projectiles.wpn_prj_target.max_amount = 8
		self.projectiles.wpn_prj_target.repeat_expire_t = 0.5
		self.projectiles.wpn_prj_target.throw_allowed_expire_t = 0.15
		self.projectiles.wpn_prj_target.expire_t = 1.1
		self.projectiles.wpn_prj_target.primary_class = "class_throwing"
		self.projectiles.wpn_prj_target.can_pierce_armor = false
		self.projectiles.wpn_prj_target.subclasses = {}
		self.projectiles.wpn_prj_target.no_cheat_count = true
		
		self.projectiles.wpn_prj_hur.max_amount = 4
		self.projectiles.wpn_prj_hur.repeat_expire_t = 0.5
		self.projectiles.wpn_prj_hur.throw_allowed_expire_t = 0.15
		self.projectiles.wpn_prj_hur.expire_t = 1.1
		self.projectiles.wpn_prj_hur.primary_class = "class_throwing"
		self.projectiles.wpn_prj_hur.can_pierce_armor = true
		self.projectiles.wpn_prj_hur.subclasses = {}
		self.projectiles.wpn_prj_hur.no_cheat_count = true
		
		self.projectiles.wpn_prj_jav.max_amount = 2
		self.projectiles.wpn_prj_jav.repeat_expire_t = 1
		self.projectiles.wpn_prj_jav.throw_allowed_expire_t = 0.4
		self.projectiles.wpn_prj_jav.expire_t = 1.1
		self.projectiles.wpn_prj_jav.primary_class = "class_throwing"
		self.projectiles.wpn_prj_jav.can_pierce_armor = true
		self.projectiles.wpn_prj_jav.subclasses = {}
		self.projectiles.wpn_prj_jav.no_cheat_count = true
		
		self.projectiles.frag.impact_detonation = true
		self.projectiles.frag.max_amount = 3
		self.projectiles.frag.repeat_expire_t = 1.5
		self.projectiles.frag.throw_allowed_expire_t = 0.1
		self.projectiles.frag.expire_t = 1.1
		self.projectiles.frag.primary_class = "class_grenade"
		self.projectiles.frag.subclasses = {}
		self.projectiles.frag.no_cheat_count = true
		
		self.projectiles.frag_com.impact_detonation = true
		self.projectiles.frag_com.max_amount = 3
		self.projectiles.frag_com.repeat_expire_t = 1.5
		self.projectiles.frag_com.throw_allowed_expire_t = 0.1
		self.projectiles.frag_com.expire_t = 1.1
		self.projectiles.frag_com.primary_class = "class_grenade"
		self.projectiles.frag_com.subclasses = {}
		self.projectiles.frag_com.no_cheat_count = true
		
		self.projectiles.dynamite.impact_detonation = true
		self.projectiles.dynamite.max_amount = 1
		self.projectiles.dynamite.repeat_expire_t = 1.5
		self.projectiles.dynamite.throw_allowed_expire_t = 0.1
		self.projectiles.dynamite.expire_t = 1.1
		self.projectiles.dynamite.primary_class = "class_grenade"
		self.projectiles.dynamite.subclasses = {}
		self.projectiles.dynamite.no_cheat_count = true
		
		self.projectiles.dada_com.impact_detonation = true
		self.projectiles.dada_com.max_amount = 3
		self.projectiles.dada_com.repeat_expire_t = 1.5
		self.projectiles.dada_com.throw_allowed_expire_t = 0.1
		self.projectiles.dada_com.expire_t = 1.1
		self.projectiles.dada_com.primary_class = "class_grenade"
		self.projectiles.dada_com.subclasses = {}
		self.projectiles.dada_com.no_cheat_count = true
		
		self.projectiles.concussion.impact_detonation = true
		self.projectiles.concussion.max_amount = 6
		self.projectiles.concussion.repeat_expire_t = 1.5
		self.projectiles.concussion.throw_allowed_expire_t = 0.1
		self.projectiles.concussion.expire_t = 1.1
		self.projectiles.concussion.primary_class = "class_grenade"
		self.projectiles.concussion.subclasses = {}
		self.projectiles.concussion.no_cheat_count = true
		
		self.projectiles.molotov.max_amount = 3
		self.projectiles.molotov.repeat_expire_t = 1.5
		self.projectiles.molotov.throw_allowed_expire_t = 0.1
		self.projectiles.molotov.expire_t = 1.1
		self.projectiles.molotov.primary_class = "class_grenade"
		self.projectiles.molotov.subclasses = {"subclass_areadenial"}
		self.projectiles.molotov.no_cheat_count = true
		
		self.projectiles.fir_com.impact_detonation = true
		self.projectiles.fir_com.max_amount = 6
		self.projectiles.fir_com.repeat_expire_t = 1.5
		self.projectiles.fir_com.throw_allowed_expire_t = 0.1
		self.projectiles.fir_com.expire_t = 1.1
		self.projectiles.fir_com.primary_class = "class_grenade"
		self.projectiles.fir_com.subclasses = {"subclass_areadenial"}
		self.projectiles.fir_com.no_cheat_count = true
		
		self.projectiles.wpn_gre_electric.primary_class = "class_grenade"
		self.projectiles.poison_gas_grenade.primary_class = "class_grenade"
		self.projectiles.sticky_grenade.primary_class = "class_grenade"
		
		
		self.projectiles.bow_poison_arrow.is_poison = true
		self.projectiles.crossbow_poison_arrow.is_poison = true
		self.projectiles.arblast_poison_arrow.is_poison = true
		self.projectiles.frankish_poison_arrow.is_poison = true
		self.projectiles.long_poison_arrow.is_poison = true
		self.projectiles.wpn_prj_four.is_poison = true
		self.projectiles.ecp_arrow_poison.is_poison = true
		self.projectiles.elastic_arrow_poison.is_poison = true
		
		self.projectiles.tag_team.base_cooldown = 60 --same as vanilla anyway
		self.projectiles.tag_team.hold_function_name = "_update_tagteam_hud_targets"
	end
end)
