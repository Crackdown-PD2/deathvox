local old_init = WeaponFactoryTweakData.init
function WeaponFactoryTweakData:init(...)
	old_init(self, ...)
	self.wpn_deathvox_medicdozer_smg = deep_clone(self.wpn_fps_smg_polymer_npc)
	self.wpn_deathvox_medicdozer_smg.default_blueprint = {
		"wpn_fps_smg_polymer_body_standard",
		"wpn_fps_smg_polymer_bolt_standard",
		"wpn_fps_smg_polymer_dh_standard",
		"wpn_fps_smg_polymer_extra_sling",
		"wpn_fps_smg_polymer_o_iron",
		"wpn_fps_smg_polymer_fg_standard",
		"wpn_fps_smg_polymer_barrel_standard",
		"wpn_fps_smg_polymer_m_standard",
		"wpn_fps_smg_polymer_s_standard"
	}
	
	self.wpn_deathvox_shield_pistol = deep_clone(self.wpn_fps_pis_g18c_npc)
	self.wpn_deathvox_shield_pistol.default_blueprint = {
		"wpn_fps_pis_g18c_body_frame",
		"wpn_fps_pis_g18c_b_standard",
		"wpn_fps_pis_g18c_g_ergo",
		"wpn_fps_pis_g18c_m_mag_33rnd",
		"wpn_fps_pis_g18c_s_stock"
	}
	
	self.wpn_deathvox_guard_pistol = deep_clone(self.wpn_fps_pis_packrat_npc)
	self.wpn_deathvox_guard_pistol.default_blueprint = {
		"wpn_fps_pis_packrat_b_standard",
		"wpn_fps_pis_packrat_body_standard",
		"wpn_fps_pis_packrat_bolt_standard",
		"wpn_fps_pis_packrat_m_standard",
		"wpn_fps_pis_packrat_sl_standard",
		"wpn_fps_pis_packrat_o_expert"
	}

	self.wpn_deathvox_medic_pistol = deep_clone(self.wpn_fps_pis_2006m_npc)
	self.wpn_deathvox_medic_pistol.default_blueprint = {
		"wpn_fps_pis_2006m_body_standard",
		"wpn_fps_pis_2006m_m_standard",
		"wpn_fps_pis_2006m_b_long",
		"wpn_fps_pis_2006m_g_bling"
	}
	
	self.wpn_deathvox_light_ar = deep_clone(self.wpn_fps_ass_aug_npc)
	self.wpn_deathvox_light_ar.default_blueprint = {
		"wpn_fps_aug_m_pmag",
		"wpn_fps_aug_b_long",
		"wpn_fps_upg_ass_ns_surefire",
		"wpn_fps_aug_fg_a3",
		"wpn_fps_upg_fl_ass_peq15",
		"wpn_fps_aug_body_f90",
		"wpn_fps_upg_o_cs"
	}

	self.wpn_deathvox_heavy_ar = deep_clone(self.wpn_fps_ass_fal_npc)
	self.wpn_deathvox_heavy_ar.default_blueprint = {
		"wpn_fps_ass_fal_body_standard",
		"wpn_fps_ass_fal_fg_standard",
		"wpn_fps_ass_fal_s_standard",
		"wpn_fps_upg_ass_ns_battle",
		"wpn_fps_ass_fal_g_01",
		"wpn_fps_upg_fl_ass_peq15",
		"wpn_fps_ass_fal_m_01",
		"wpn_fps_upg_o_reflex"
	}
	
	self.wpn_deathvox_shotgun_light = deep_clone(self.wpn_fps_shot_r870_npc)
	self.wpn_deathvox_shotgun_light.default_blueprint = {
		"wpn_fps_shot_r870_body_standard",
		"wpn_fps_shot_r870_b_long",
		"wpn_fps_shot_r870_fg_wood",
		"wpn_fps_upg_m4_g_sniper",
		"wpn_fps_shot_r870_s_nostock",
		"wpn_fps_shot_r870_body_rack"
	}

	self.wpn_deathvox_shotgun_heavy = deep_clone(self.wpn_fps_sho_ben_npc)
	self.wpn_deathvox_shotgun_heavy.default_blueprint = {
		"wpn_fps_sho_ben_b_short",
		"wpn_fps_sho_ben_body_standard",
		"wpn_fps_sho_ben_fg_standard",
		"wpn_fps_sho_ben_s_collapsable"
	}

	self.wpn_deathvox_sniper = deep_clone(self.wpn_fps_snp_wa2000_npc)
	self.wpn_deathvox_sniper.default_blueprint = {
		"wpn_fps_snp_wa2000_body_standard",
		"wpn_fps_snp_wa2000_m_standard",
		"wpn_fps_snp_wa2000_s_standard",
		"wpn_fps_snp_wa2000_b_long",
		"wpn_fps_upg_fl_ass_peq15",
		"wpn_fps_snp_wa2000_g_stealth",
		"wpn_fps_upg_o_spot"
	}

	self.wpn_deathvox_grenadier = deep_clone(self.wpn_fps_ass_contraband_npc)
	self.wpn_deathvox_grenadier.default_blueprint = {
		"wpn_fps_ass_contraband_b_standard",
		"wpn_fps_ass_contraband_body_standard",
		"wpn_fps_ass_contraband_dh_standard",
		"wpn_fps_ass_contraband_fg_standard",
		"wpn_fps_ass_contraband_g_standard",
		"wpn_fps_ass_contraband_gl_m203",
		"wpn_fps_ass_contraband_m_standard",
		"wpn_fps_ass_contraband_ns_standard",
		"wpn_fps_ass_contraband_o_standard",
		"wpn_fps_ass_contraband_s_standard",
		"wpn_fps_ass_contraband_bolt_standard"
	}
	
	self.wpn_deathvox_cloaker = deep_clone(self.wpn_fps_smg_schakal_npc)
	self.wpn_deathvox_cloaker.default_blueprint = {
		"wpn_fps_smg_schakal_b_standard",
		"wpn_fps_smg_schakal_body_lower",
		"wpn_fps_smg_schakal_body_upper",
		"wpn_fps_smg_schakal_m_standard",
		"wpn_fps_smg_schakal_s_standard",
		"wpn_fps_smg_schakal_dh_standard",
		"wpn_fps_smg_schakal_bolt_standard",
		"wpn_fps_upg_vg_ass_smg_verticalgrip",
		"wpn_fps_smg_schakal_extra_magrelease"
	}
	self.wpn_deathvox_greendozer = deep_clone(self.wpn_fps_shot_r870_npc)
	self.wpn_deathvox_greendozer.default_blueprint = {
		"wpn_fps_shot_r870_body_standard",
		"wpn_fps_shot_r870_b_long",
		"wpn_fps_shot_r870_fg_big",
		"wpn_fps_shot_r870_s_solid_vanilla",
		"wpn_fps_upg_m4_g_standard"
	}
	self.wpn_deathvox_blackdozer = deep_clone(self.wpn_fps_shot_saiga_npc)
	self.wpn_deathvox_blackdozer.default_blueprint = {
		"wpn_fps_smg_akmsu_body_lowerreceiver",
		"wpn_fps_ass_akm_body_upperreceiver_vanilla",
		"wpn_fps_shot_saiga_b_standard",
		"wpn_fps_shot_saiga_m_5rnd",
		"wpn_upg_ak_s_folding_vanilla",
		"wpn_upg_saiga_fg_standard",
		"wpn_upg_ak_g_standard",
		"wpn_upg_o_marksmansight_rear_vanilla"
	}
	self.wpn_deathvox_lmgdozer = deep_clone(self.wpn_fps_lmg_m249_npc)
	self.wpn_deathvox_lmgdozer.default_blueprint = {
		"wpn_fps_lmg_m249_b_short",
		"wpn_fps_lmg_m249_body_standard",
		"wpn_fps_lmg_m249_fg_standard",
		"wpn_fps_lmg_m249_m_standard",
		"wpn_fps_lmg_m249_s_para",
		"wpn_fps_lmg_m249_upper_reciever"
	}
	
	
	self.wpn_deathvox_guard_pistol.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_guard_pistol"
	self.wpn_deathvox_medic_pistol.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_medic_pistol"
	self.wpn_deathvox_light_ar.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_light_ar"
	self.wpn_deathvox_heavy_ar.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_heavy_ar"
	self.wpn_deathvox_shotgun_light.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_shotgun_light"
	self.wpn_deathvox_shotgun_heavy.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_shotgun_heavy"
	self.wpn_deathvox_sniper.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_sniper"
	self.wpn_deathvox_medicdozer_smg.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_medicdozer_smg"
	self.wpn_deathvox_grenadier.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_grenadier"
	
	self.wpn_deathvox_cloaker.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_cloaker"
	self.wpn_deathvox_greendozer.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_greendozer"
	self.wpn_deathvox_blackdozer.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_blackdozer"
	self.wpn_deathvox_lmgdozer.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_lmgdozer"
end