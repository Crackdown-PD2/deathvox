local old_init = WeaponFactoryTweakData.init
function WeaponFactoryTweakData:init(...)
	old_init(self, ...)
	--[[self.wpn_deathvox_medicdozer_smg = deep_clone(self.wpn_fps_smg_polymer_npc)
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
	}]]--
    
	self.wpn_deathvox_grenadier = deep_clone(self.wpn_fps_gre_m32_npc)
	self.wpn_deathvox_grenadier.default_blueprint = {
		"wpn_fps_gre_m32_barrel",
		"wpn_fps_gre_m32_bolt",
		"wpn_fps_gre_m32_lower_reciever",
		"wpn_fps_gre_m32_mag",
		"wpn_fps_gre_m32_upper_reciever",
		"wpn_fps_upg_m4_s_standard_vanilla"
	}
	
	--[[self.wpn_deathvox_cloaker = deep_clone(self.wpn_fps_smg_schakal_npc)
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

	self.wpn_deathvox_cop_pistol = deep_clone(self.wpn_fps_pis_1911_npc)
	self.wpn_deathvox_cop_pistol.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_cop_pistol"
	
	self.wpn_deathvox_cop_revolver = deep_clone(self.wpn_fps_pis_rage_npc)
	self.wpn_deathvox_cop_revolver.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_cop_revolver"
	
	self.wpn_deathvox_cop_shotgun = deep_clone(self.wpn_fps_sho_spas12_npc)
	self.wpn_deathvox_cop_shotgun.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_cop_shotgun"
	
	self.wpn_deathvox_cop_smg = deep_clone(self.wpn_fps_smg_mp5_npc)
	self.wpn_deathvox_cop_smg.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_cop_smg"
	
	self.wpn_deathvox_guard_pistol.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_guard_pistol"
	self.wpn_deathvox_medic_pistol.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_medic_pistol"
	self.wpn_deathvox_light_ar.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_light_ar"
	self.wpn_deathvox_heavy_ar.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_heavy_ar"
	self.wpn_deathvox_shotgun_light.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_shotgun_light"
	self.wpn_deathvox_shotgun_heavy.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_shotgun_heavy"
    	self.wpn_deathvox_medicdozer_smg.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_medicdozer_smg"]]--
	
	--self.wpn_deathvox_sniper.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_sniper"

	self.wpn_deathvox_grenadier.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_grenadier"
	
	--[[self.wpn_deathvox_cloaker.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_cloaker"
	self.wpn_deathvox_greendozer.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_greendozer"
	self.wpn_deathvox_blackdozer.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_blackdozer"
	self.wpn_deathvox_lmgdozer.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_lmgdozer"]]--
end




-- Total Crackdown Weapon Attachment Stuff
Hooks:PostHook( WeaponFactoryTweakData, "init", "totalcd_weaps", function(self)
	--BEGIN THE NEW INSANITY! (OR SOMETHING LIKE THAT!)
	if deathvox:IsTotalCrackdownEnabled() then
	--------------------------------------
				--AMR16--
	--------------------------------------
		-- Long Ergo Foregrip
		self.parts.wpn_fps_upg_ass_m16_fg_stag.stats = {value = 1}
		-- Blast From the Past Handguard
		self.parts.wpn_fps_m16_fg_vietnam.stats = {value = 10}
		-- Tactical Handguard
		self.parts.wpn_fps_m16_fg_railed.stats = {value = 7}
		self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_l5 = {	
			 stats = {
				value = 1,			 			 
				extra_ammo = 5, 
				concealment = -2
			}	
		}			
		self.wpn_fps_ass_m16.override.wpn_fps_m4_uupg_m_std = {	
			 stats = {
				value = 3,			 
				extra_ammo = 5, 
				concealment = -2
			}	
		}			
		self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_pmag = {	
			 stats = {
				extra_ammo = 5, 
				concealment = -2
			}	
		}			
		self.wpn_fps_ass_m16.override.wpn_fps_ass_l85a2_m_emag = {	
			 stats = {
				value = 1,			 
				extra_ammo = 5, 
				concealment = -2
			}	
		}			
		self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_quad = {	
			 stats = {
				value = 3,
				extra_ammo = 20, 
				concealment = -10
			}	
		}			
	
	--------------------------------------
				--AMCAR--
	--------------------------------------
		self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_l5 = {	
			 stats = {
				value = 1,			 			 
				extra_ammo = 5, 
				concealment = -2
			}	
		}			
		self.wpn_fps_ass_amcar.override.wpn_fps_m4_uupg_m_std = {	
			 stats = {
				value = 3,			 
				extra_ammo = 5, 
				concealment = -2
			}	
		}			
		self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_pmag = {	
			 stats = {
				extra_ammo = 5, 
				concealment = -2
			}	
		}			
		self.wpn_fps_ass_amcar.override.wpn_fps_ass_l85a2_m_emag = {	
			 stats = {
				value = 1,			 
				extra_ammo = 5, 
				concealment = -2
			}	
		}			
		self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_quad = {	
			 stats = {
				value = 3,
				extra_ammo = 20, 
				concealment = -10
			}	
		}			

	--------------------------------------
				--CAR 4--
	--------------------------------------
		-- Aftermarket Special Handguard	
		self.parts.wpn_fps_m4_uupg_fg_lr300.stats = {value = 5}
		-- Competition Foregrip		
		self.parts.wpn_fps_upg_fg_jp.stats = {value = 5}
		-- Gazelle Rail
		self.parts.wpn_fps_upg_fg_smr.stats = {value = 5}
		-- OVAL Foregrip		
		self.parts.wpn_fps_upg_ass_m4_fg_lvoa.stats = {value = 1}
		-- E.M.O. Foregrip		
		self.parts.wpn_fps_upg_ass_m4_fg_moe.stats = {value = 5}
		-- Long Barrel
		self.parts.wpn_fps_m4_uupg_b_long.stats = {value = 5}
		-- Short Barrel		
		self.parts.wpn_fps_m4_uupg_b_short.stats = {value = 4}
		-- Stelth? Barrel		
		self.parts.wpn_fps_m4_uupg_b_sd.stats = {
			value = 6,		
			spread = -3,
			concealment = 3,
			suppression = -72,
			alert_size = 12
		}
		-- DMR Kit				
		self.parts.wpn_fps_upg_ass_m4_b_beowulf.stats = {
			value = 1,
			total_ammo_mod = -13, --christ i hate the way this stat works. curse overkill and this weird ass stat
			damage = 80,
			recoil = -10,
			concealment = -5
		}
		self.parts.wpn_fps_upg_ass_m4_b_beowulf.adds = {"car_dmr_kit_ammo_type"}
		self.parts.car_dmr_kit_ammo_type = { --Dummy ammo type for DMR kit, needed for armor piercing and pickup multipliers to work properly.
			a_obj = "a_m",
			type = "ammo",
			unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
			stats = {
				value = 1
			},
			custom_stats = {
				armor_piercing_add = 1,			
				ammo_pickup_max_mul = 4,
				ammo_pickup_min_mul = 2.5
			}
		}		
	--------------------------------------
				--Valkyria--
	--------------------------------------
	self.parts.wpn_fps_ass_asval_b_standard.stats = nil --why overkill
	-- Prototype Barrel
	self.parts.wpn_fps_ass_asval_b_proto.stats = {
		value = 1,
		spread = -3, 
		recoil = -5, 
		suppression = -72,
		alert_size = 12,
		concealment = 10
	}
	-- Solid Stock
	self.parts.wpn_fps_ass_asval_s_solid.stats = {value = 1}

	--------------------------------------
			--Shared Attachments--
	--------------------------------------
	--auto and singlefire mods
	self.parts.wpn_fps_upg_i_singlefire.stats = {value = 5}
	self.parts.wpn_fps_upg_i_autofire.stats = {value = 8}

	--Barrel extension stat changes begin here. (don't feel like commenting these either noobs)
		self.parts.wpn_fps_upg_ass_ns_battle.stats = {value = 1}
		self.parts.wpn_fps_upg_ns_ass_smg_stubby.stats = {value = 3}
		self.parts.wpn_fps_upg_ns_ass_smg_tank.stats = {value = 4}
		self.parts.wpn_fps_upg_ns_ass_smg_firepig.stats = {value = 5}
		self.parts.wpn_fps_upg_ass_ns_surefire.stats = {value = 5}
		self.parts.wpn_fps_upg_ass_ns_linear.stats = {value = 5}
		self.parts.wpn_fps_upg_ass_ns_jprifles.stats = {value = 5}
		self.parts.wpn_fps_upg_ns_ass_smg_medium.stats = {suppression = 72,	alert_size = 12, value = 2}
		self.parts.wpn_fps_upg_ns_ass_smg_large.stats = {suppression = 72, alert_size = 12, value = 5}
		self.parts.wpn_fps_upg_ns_pis_typhoon.stats = {value = 4}
		self.parts.wpn_fps_upg_ns_ass_smg_v6.stats = {value = 3}
		self.parts.wpn_fps_upg_ns_pis_jungle.stats = {suppression = 72,	value = 5}
		self.parts.wpn_fps_upg_ns_ass_filter.stats = {suppression = 72,	value = 0}
		self.parts.wpn_fps_upg_ns_pis_medium_slim.stats = {suppression = 72, alert_size = 12, value = 1}
		self.parts.wpn_fps_upg_ns_pis_large.stats = {suppression = 72, alert_size = 12, value = 5}
		self.parts.wpn_fps_upg_ns_pis_large_kac.stats = {suppression = 72, alert_size = 12, value = 6}
		self.parts.wpn_fps_upg_ns_pis_small.stats = {suppression = 72, alert_size = 12, value = 3}
		self.parts.wpn_fps_upg_pis_ns_flash.stats = {suppression = 72, alert_size = 12, value = 4}
		self.parts.wpn_fps_upg_ns_pis_meatgrinder.stats = {suppression = 72, alert_size = 12, value = 7}
		self.parts.wpn_fps_upg_ns_pis_ipsccomp.stats = {suppression = 72, alert_size = 12, value = 4}
		self.parts.wpn_fps_upg_ns_pis_medium.stats = {suppression = 72, alert_size = 12, value = 1}
		self.parts.wpn_fps_upg_ns_pis_medium_gem.stats = {suppression = 72, alert_size = 12, value = 4}
		self.parts.wpn_fps_upg_ns_pis_medium_slim.stats = {suppression = 72, alert_size = 12, value = 1}
	
	--Sight stat changes begin here. (don't feel like commenting these! nerds!)
		self.parts.wpn_fps_upg_o_specter.stats = {zoom = 4, value = 8} -- i should probably write it like this for the rest of the attachments but NO, DIE
		self.parts.wpn_fps_upg_o_aimpoint.stats = {zoom = 4, value = 8}
		self.parts.wpn_fps_upg_o_aimpoint_2.stats = {zoom = 4, value = 1}
		self.parts.wpn_fps_upg_o_docter.stats = {zoom = 2, value = 5}
		self.parts.wpn_fps_upg_o_eotech.stats = {zoom = 3, value = 3}
		self.parts.wpn_fps_upg_o_t1micro.stats = {zoom = 3, value = 3}
		self.parts.wpn_upg_o_marksmansight_rear.stats = {zoom = 2, value = 5}
		self.parts.wpn_fps_upg_o_leupold.stats = {zoom = 10, value = 8}
		self.parts.wpn_fps_upg_o_cmore.stats = {zoom = 3, value = 5}
		self.parts.wpn_fps_upg_o_acog.stats = {zoom = 6, value = 6}
		self.parts.wpn_fps_upg_o_cs.stats = {zoom = 4, value = 3}
		self.parts.wpn_fps_upg_o_reflex.stats = {zoom = 3, value = 5}
		self.parts.wpn_fps_upg_o_rx01.stats = {zoom = 3, value = 5}
		self.parts.wpn_fps_upg_o_eotech_xps.stats = {zoom = 3, value = 5}
		self.parts.wpn_fps_upg_o_bmg.stats = {zoom = 6, value = 8}
		self.parts.wpn_fps_upg_o_rms.stats = {zoom = 3, value = 6}
		self.parts.wpn_fps_upg_o_rikt.stats = {zoom = 3, value = 6}
		self.parts.wpn_fps_upg_o_uh.stats = {zoom = 3, value = 5}
		self.parts.wpn_fps_upg_o_fc1.stats = {zoom = 3, value = 5}
	--Magazine stat changes begin here.
		--Milspec Magazine
		self.parts.wpn_fps_m4_uupg_m_std.stats = {value = 1}
		--L5 Magazine
		self.parts.wpn_fps_upg_m4_m_l5.stats = {value = 1}
		--Tactical Magazine
		self.parts.wpn_fps_upg_m4_m_pmag.stats = {value = 3}
		--Expert Magazine
		self.parts.wpn_fps_ass_l85a2_m_emag.stats = {value = 1}
		--Quadstack Magazine
		self.parts.wpn_fps_upg_m4_m_quad.stats = {
			value = 3,		
			extra_ammo = 15, 
			concealment = -10
		}
		self.parts.wpn_fps_upg_m4_m_straight.stats = {	
			value = 2,		
			extra_ammo = -5, 
			concealment = 5
		}		
		--Speedpull Magazine
		self.parts.wpn_fps_m4_upg_m_quick.stats = {	
			value = 2,		
			reload = 10,
			concealment = -4
		}
	--Gadget stat changes begin here.
		-- Flashlight
		self.parts.wpn_fps_upg_fl_ass_smg_sho_surefire.stats = {value = 3}
		-- Tactical Laser										
		self.parts.wpn_fps_upg_fl_ass_smg_sho_peqbox.stats = {value = 5}
		-- Compact Laser								
		self.parts.wpn_fps_upg_fl_ass_laser.stats = {value = 2}	
		-- Military Laser						
		self.parts.wpn_fps_upg_fl_ass_peq15.stats = {value = 5}	
		-- LED Combo						
		self.parts.wpn_fps_upg_fl_ass_utg.stats = {value = 5}	
		-- Tactical Pistol Light						
		self.parts.wpn_fps_upg_fl_pis_tlr1.stats = {value = 2}	
		-- Pocket Laser						
		self.parts.wpn_fps_upg_fl_pis_laser.stats = {value = 5}	
		-- Combined Module
		self.parts.wpn_fps_upg_fl_pis_x400v.stats = {value = 5}	
		-- Polymer Flashlight
		self.parts.wpn_fps_upg_fl_pis_m3x.stats = {value = 1}	
		-- Micro Laser						
		self.parts.wpn_fps_upg_fl_pis_crimson.stats = {value = 5}	
		-- 45 Degree Sight				
		self.parts.wpn_fps_upg_o_45rds.stats = {value = 1, gadget_zoom = 1}	
		-- Riktpunkt 45 Degree Sight		
		self.parts.wpn_fps_upg_o_45rds_v2.stats = {value = 1, gadget_zoom = 1}	
		-- Riktpunkt Magnifier
		self.parts.wpn_fps_upg_o_xpsg33_magnifier.stats = {value = 1, gadget_zoom = 9}
		--border crossing 45 degree sights i forgot the names of
		self.parts.wpn_fps_upg_o_sig.stats = {zoom = 9, value = 2}		
		self.parts.wpn_fps_upg_o_45steel.stats = {value = 1, gadget_zoom = 1}		
	--Grip stat changes begin here.
		-- Pro Grip
		self.parts.wpn_fps_upg_m4_g_sniper.stats = {value = 2}	
		-- Ergo Grip
		self.parts.wpn_fps_upg_m4_g_ergo.stats = {value = 2}	
		-- Rubber Grip (the only good looking grip attachment)
		self.parts.wpn_fps_upg_m4_g_hgrip.stats = {value = 1}	
		-- Contractor Grip
		self.parts.wpn_fps_snp_tti_g_grippy.stats = {value = 1}
		-- Short Grip (ugly as sin)
		self.parts.wpn_fps_upg_m4_g_mgrip.stats = {value = 1}	
		-- Titanium Skeleton Grip (the ugliest)
		self.parts.wpn_fps_upg_g_m4_surgeon.stats = {value = 1}		
	--Stock stat changes begin here.
		--Tactical Stock
		self.parts.wpn_fps_upg_m4_s_pts.stats = {value = 3}
		--Folding stock
		self.parts.wpn_fps_m4_uupg_s_fold.stats = {value = 5}
		-- Crane Stock
		self.parts.wpn_fps_upg_m4_s_crane.stats = {value = 2}
		-- 2 Piece Stock
		self.parts.wpn_fps_upg_m4_s_ubr.stats = {value = 1}		
		-- Contractor stock
		self.parts.wpn_fps_snp_tti_s_vltor.stats = {value = 1}		
		-- War Torn stock
		self.parts.wpn_fps_upg_m4_s_mk46.stats = {value = 6}		
	--Upper/Lower Receiver stat changes begin here.
		-- exotique receiver
		self.parts.wpn_fps_m4_upper_reciever_edge.stats = {value = 3}	
		-- lw upper receiver
		self.parts.wpn_fps_upg_ass_m4_upper_reciever_ballos.stats = {value = 1}		
		-- thrust upper receiver
		self.parts.wpn_fps_upg_ass_m4_upper_reciever_core.stats = {value = 1}
		-- thrust lower receiver
		self.parts.wpn_fps_upg_ass_m4_lower_reciever_core.stats = {value = 1}	
	end
end)