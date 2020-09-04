local old_init = WeaponFactoryTweakData.init
function WeaponFactoryTweakData:init(...)
	old_init(self, ...)
    
	self.wpn_deathvox_grenadier = deep_clone(self.wpn_fps_gre_m32_npc)
	self.wpn_deathvox_grenadier.default_blueprint = {
		"wpn_fps_gre_m32_barrel",
		"wpn_fps_gre_m32_bolt",
		"wpn_fps_gre_m32_lower_reciever",
		"wpn_fps_gre_m32_mag",
		"wpn_fps_gre_m32_upper_reciever",
		"wpn_fps_upg_m4_s_standard_vanilla"
	}
	self.wpn_deathvox_grenadier.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_grenadier"

end




-- Begin Total Crackdown Weapon Attachment materials
Hooks:PostHook( WeaponFactoryTweakData, "init", "totalcd_weaps", function(self)
	--BEGIN THE NEW INSANITY! (OR SOMETHING LIKE THAT!)
	if deathvox:IsTotalCrackdownEnabled() then

--Mod stats info:
--      damage - Damage increased/decreased by attachment. (Note. If weapon use stats_modifiers for damage this value will be multiplied by it)
--      spread - Accuracy increased/decreased by attachment. 1/ -1 value = 4 / -4 accuracy in-game.
--      recoil - Stability increased/decreased by attachment. 1/ -1 value = 4 / -4 accuracy in-game.
--      concealment - Concealment increased/decreased by attachment.
--      extra_ammo - Adds additional rounds added to weapon magazine. 1 value = 2 rounds in-game.
--      total_ammo_mod - Increased/decreased weapon ammo pool. Values varies depending on total ammo pool.
--      reload - Increased/decreased weapon reload timers. 1 / -1 value = 10% / -10% reload time.
--      value - from table. Inconsistently reported/documented. Copy from decompile.

--Weapon stats:
--      damage - Base damage of weapon. Max value should be no more than 180 (Damage can be increased further by using "stats_modifiers")
--      spread - Base accuracy of weapon. 1 value = 4 accuracy - Game calculate it using: Value*4-4 = accuracy in-game. Example - 17 value = 17*4-4=64 accuracy.
--      spread_moving - NOT USED BY GAME (But just in case use same value as for "spread")
--      recoil - Base stability of weapon 1 value = 4 stability - Game calculate it using: Value*4-4 = stability in-game. Example - 16 value = 16*4-4=60 stability.
--      zoom - Base zoom value used when aiming down sights.
--      concealment - Base concealment of weapon.
--      suppression - Base suppression value.
--      value - from table. Inconsistently reported/documented. Copy from decompile.
			
	--------------------------------------
	--Primary Weapons--
	--------------------------------------	
	--------------------------------------
		--Assault Rifles--
	--------------------------------------	
	--------------------------------------
			--Light ARs--
	--------------------------------------		
			
	--------------------------------------
				--AMCAR--
	--------------------------------------
		-- L5 Magazine
		self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_l5 = { -- gotta be like this or else the game shits the bed
			stats = {	
				value = 1,			 			 
				extra_ammo = 5, 
				concealment = -2
			}
		}			
		-- Milspec Mag
		self.wpn_fps_ass_amcar.override.wpn_fps_m4_uupg_m_std = {	
			stats = {			
				value = 1,			 
				extra_ammo = 5, 
				concealment = -2
			}
		}
		-- Tactical Mag		
		self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_pmag = {	
			stats = {			
				value = 1,
				extra_ammo = 5, 
				concealment = -2
			}
		}
		-- Expert Mag			
		self.wpn_fps_ass_amcar.override.wpn_fps_ass_l85a2_m_emag = {	
			stats = {
				value = 1,			 
				extra_ammo = 5, 
				concealment = -2
			}
		}
		-- Quadstacked mag
		self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_quad = {
			stats = {
				value = 3,
				extra_ammo = 20, 
				concealment = -10	
			}	
		}
	--------------------------------------
				--Bootleg--
	--------------------------------------
	--------------------------------------
				--JP36--
	--------------------------------------
	--------------------------------------
				--Commando 553--
	--------------------------------------
	--------------------------------------
				--Clarion--
	--------------------------------------	
	--------------------------------------
			--Medium ARs--
	--------------------------------------
	--------------------------------------
				--Valkyria--
	--------------------------------------
	self.parts.wpn_fps_ass_asval_b_standard.stats = nil --why overkill
	-- Prototype Barrel
	self.parts.wpn_fps_ass_asval_b_proto.stats = {
		value = 1,
		spread = -3, 
		recoil = -5, 
		concealment = 10
	}
	-- Solid Stock
	self.parts.wpn_fps_ass_asval_s_solid.stats = {value = 1}

	--------------------------------------
				--CAR-4--
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
		-- Stealth Barrel		
		self.parts.wpn_fps_m4_uupg_b_sd.stats = {
			value = 6,		
			spread = -3,
			concealment = 3,
			suppression = -72,
			alert_size = 12
		}
	--------------------------------------
				--CAR-4 (DMR Kit)--
	--------------------------------------
	--Note: Conversion kit entries are not actual weapons and are only listed for referential purposes.
		self.parts.wpn_fps_upg_ass_m4_b_beowulf.stats = {
			value = 1,
			total_ammo_mod = -13, -- the way this stat works...curse overkill and this weird stat
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
				--AK--
	--------------------------------------
	--------------------------------------
				--AK (DMR Kit)--
	--------------------------------------
	--Note: Conversion kit entries are not actual weapons and are only listed for referential purposes.
	--------------------------------------
				--AK17--
	--------------------------------------
	--------------------------------------
				--AK5--
	--------------------------------------
	--------------------------------------
				--Queen's Wrath--
	--------------------------------------
	--------------------------------------
				--UAR--
	--------------------------------------
	--------------------------------------
				--Tempest-21--
	--------------------------------------
	--------------------------------------
				--Gecko 7.62--
	--------------------------------------
	--------------------------------------
				--Lion's Roar--
	--------------------------------------
	--------------------------------------
				--Union 5.56--
	--------------------------------------
	--------------------------------------
			--Heavy ARs--
	--------------------------------------
	--------------------------------------
				--AK.762--
	--------------------------------------
	--------------------------------------
				--AK.762 (DMR Kit)--
	--------------------------------------
	--Note: Conversion kit entries are not actual weapons and are only listed for referential purposes.
	--------------------------------------
				--AK.762 Golden--
	--------------------------------------			
	--------------------------------------
				--Eagle Heavy--
	--------------------------------------
	--------------------------------------
				--Gewehr 3--
	--------------------------------------
	--------------------------------------
				--Gewehr 3 (assault kit)--
	--------------------------------------
	--Note: Conversion kit entries are not actual weapons and are only listed for referential purposes.
	--------------------------------------
				--Falcon--
	--------------------------------------
	--------------------------------------
				--AMR-16--
	--------------------------------------
		-- Long Ergo Foregrip
		self.parts.wpn_fps_upg_ass_m16_fg_stag.stats = {value = 1}
		-- Blast From the Past Handguard
		self.parts.wpn_fps_m16_fg_vietnam.stats = {value = 10}
		-- Tactical Handguard
		self.parts.wpn_fps_m16_fg_railed.stats = {value = 7}
		-- L5 Magazine
		self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_l5 = {
			stats = {
				value = 1,			 			 
				extra_ammo = 5, 
				concealment = -2	
			}
		}
		-- Milspec Mag
		self.wpn_fps_ass_m16.override.wpn_fps_m4_uupg_m_std = {	
			stats = {
				value = 1,			 
				extra_ammo = 5, 
				concealment = -2	
			}
		}
		-- Tactical Mag
		self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_pmag = {	
		stats = {
				value = 3,
				extra_ammo = 5, 
				concealment = -2
			}
		}
		-- Expert Mag
		self.wpn_fps_ass_m16.override.wpn_fps_ass_l85a2_m_emag = {	
			stats = {
				value = 1,			 
				extra_ammo = 5, 
				concealment = -2
			}
		}
		-- CAR Quadstacked Mag
		self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_quad = {	
			stats = {
				value = 3,
				extra_ammo = 20, 
				concealment = -10
			}		
		}
	--------------------------------------
				--AMR-16 (DMR Kit)--
	--------------------------------------
	--Note: Conversion kit entries are not actual weapons and are only listed for referential purposes.
	--------------------------------------
		--Akimbo Machine Pistols--
	--------------------------------------
	--------------------------------------
				--Akimbo Igor Automatik Pistols--
	--------------------------------------
	--------------------------------------
				--Akimbo STRYK 18c--
	--------------------------------------
	--------------------------------------
				--Akimbo Czech 92 Pistols--
	--------------------------------------
	--------------------------------------
				--Akimbo Bernetti Auto Pistols--
	--------------------------------------
	--------------------------------------
		--Akimbo SMGs--
	--------------------------------------
	--------------------------------------
			--Akimbo Light SMGs--
	--------------------------------------
	--------------------------------------
				--Akimbo Tatonka--
	--------------------------------------
	--------------------------------------
				--Akimbo Uzi--
	--------------------------------------
	--------------------------------------
				--Akimbo Signature--
	--------------------------------------
	--------------------------------------
				--Akimbo Compact-5--
	--------------------------------------
	--------------------------------------
				--Akimbo Blaster 9mm--
	--------------------------------------
	--------------------------------------
				--Akimbo CMP--
	--------------------------------------
	--------------------------------------
				--Akimbo Cobra--
	--------------------------------------
	--------------------------------------
				--Akimbo Micro Uzi--
	--------------------------------------
	--------------------------------------
			--Akimbo Medium SMGs--
	--------------------------------------
	--------------------------------------
				--Akimbo Para--
	--------------------------------------
	--------------------------------------
				--Akimbo Chicago Typewriter--
	--------------------------------------
	--------------------------------------
				--Akimbo Heather--
	--------------------------------------
	--------------------------------------
				--Akimbo Kobus 90--
	--------------------------------------
	--------------------------------------
				--Akimbo SpecOps--
	--------------------------------------
	--------------------------------------
				--Akimbo Mark 10--
	--------------------------------------
	--------------------------------------
				--Akimbo Kross Vertex--
	--------------------------------------
	--------------------------------------
				--Akimbo Jacket's Piece--
	--------------------------------------
	--------------------------------------
			--Akimbo Heavy SMGs--
	--------------------------------------
	--------------------------------------
				--Akimbo Patchett L2A1--
	--------------------------------------
	--------------------------------------
				--Akimbo MP40--
	--------------------------------------
	--------------------------------------
				--Akimbo Swedish K--
	--------------------------------------
	--------------------------------------
				--Akimbo Jackal--
	--------------------------------------
	--------------------------------------
				--Akimbo CR 805B--
	--------------------------------------
	--------------------------------------
				--Akimbo Krinkov--
	--------------------------------------
	--------------------------------------
		--Primary/Akimbo Shotguns--
	--------------------------------------
	--------------------------------------
				--Joceline O/U--
	--------------------------------------
	--------------------------------------
				--Mosconi 12G--
	--------------------------------------
	--------------------------------------
				--Breaker 12G--
	--------------------------------------
	--------------------------------------
				--Akimbo Judge--
	--------------------------------------
	--------------------------------------
				--Reinfeld 880--
	--------------------------------------
	--------------------------------------
				--Raven--
	--------------------------------------
	--------------------------------------
				--Predator 12G--
	--------------------------------------
	--------------------------------------
				--M1014--
	--------------------------------------
	--------------------------------------
				--Akimbo Goliath 12G--
	--------------------------------------
	--------------------------------------
				--Steakout 12G--
	--------------------------------------
	--------------------------------------
				--IZHMA 12G--
	--------------------------------------
	--------------------------------------
				--Brothers Grimm 12G--
	--------------------------------------
	--------------------------------------
		--Marksman Rifles--
	--------------------------------------
	--------------------------------------
				--Little Friend 7.62--
	--------------------------------------
	--------------------------------------
				--Little Friend 7.62 (Grenade Launcher)--
	--------------------------------------
	--------------------------------------
				--Cavity 9mm--
	--------------------------------------
	--------------------------------------
				--M308--
	--------------------------------------
	--------------------------------------
				--Galant--
	--------------------------------------
	--------------------------------------
				--Gewehr 3 (DMR Kit)--
	--------------------------------------
	--Note: Conversion kit entries are not actual weapons and are only listed for referential purposes.
	--------------------------------------
		--Primary Sniper Rifles--
	--------------------------------------
	--------------------------------------
			--Sniper Rifles--
	--------------------------------------
	--------------------------------------
				--Contractor .308--
	--------------------------------------
	--------------------------------------
				--Lebensauger .308--
	--------------------------------------
	--------------------------------------
				--Grom--
	--------------------------------------
	--------------------------------------
			--Medium Sniper Rifles--
	--------------------------------------
	--------------------------------------
				--Rattlesnake--
	--------------------------------------
	--------------------------------------
				--Repeater 1874--
	--------------------------------------
	--------------------------------------
			--Heavy Sniper Rifles--
	--------------------------------------
	--------------------------------------
				--Platypus 70--
	--------------------------------------
	--------------------------------------
				--R93--
	--------------------------------------
	--------------------------------------
				--Nagant--
	--------------------------------------
	--------------------------------------
				--Desertfox--
	--------------------------------------
	--------------------------------------
				--Thanatos .50 cal--
	--------------------------------------
	--------------------------------------
		--Akimbo Pistols--
	--------------------------------------
	--------------------------------------
			--Akimbo Light Pistols--
	--------------------------------------
	--------------------------------------
				--Akimbo Gruber Kurz--
	--------------------------------------
	--------------------------------------
				--Akimbo Chimano 88--
	--------------------------------------
	--------------------------------------
				--Akimbo M13 9mm--
	--------------------------------------
	--------------------------------------
				--Akimbo Chimano Compact--
	--------------------------------------
	--------------------------------------
				--Akimbo Crosskill Guard--
	--------------------------------------
	--------------------------------------
				--Akimbo Bernetti 9--
	--------------------------------------
	--------------------------------------
			--Akimbo Medium Pistols--
	--------------------------------------
	--------------------------------------
				--Akimbo Crosskill--
	--------------------------------------
	--------------------------------------
				--Akimbo Contractor--
	--------------------------------------
	--------------------------------------
				--Akimbo Signature .40--
	--------------------------------------
	--------------------------------------
				--Akimbo Broomstick--
	--------------------------------------
	--------------------------------------
				--Akimbo Interceptor 45--
	--------------------------------------
	--------------------------------------
				--Akimbo LEO--
	--------------------------------------
	--------------------------------------
				--Akimbo Chimano Custom--
	--------------------------------------
	--------------------------------------
			--Akimbo Heavy Pistols--
	--------------------------------------
	--------------------------------------
				--Akimbo Deagle--
	--------------------------------------
	--------------------------------------
				--Akimbo Parabellum--
	--------------------------------------
	--------------------------------------
				--Akimbo Baby Deagle--
	--------------------------------------
	--------------------------------------
				--Akimbo White Streak--
	--------------------------------------
	--------------------------------------
			--Akimbo Revolvers--
	--------------------------------------
	--------------------------------------
				--Akimbo Matever .357--
	--------------------------------------
	--------------------------------------
				--Akimbo Bronco .44--
	--------------------------------------
	--------------------------------------
				--Akimbo Castigo .44--
	--------------------------------------
	--------------------------------------
		--Machine Guns--
	--------------------------------------
	--------------------------------------
				--RPK--
	--------------------------------------
	--------------------------------------
				--Brenner-21--
	--------------------------------------
	--------------------------------------
				--KSP 58--
	--------------------------------------
	--------------------------------------
				--KSP--
	--------------------------------------
	--------------------------------------
				--Buzzsaw 42--
	--------------------------------------
	--------------------------------------
		--Primary Special Weapons--
	--------------------------------------
	--------------------------------------
				--XL 5.56 Microgun--
	--------------------------------------
	--------------------------------------
				--Vulcan Minigun--
	--------------------------------------
	--------------------------------------
				--Airbow--
	--------------------------------------
	--------------------------------------
				--Light Crossbow--
	--------------------------------------
	--------------------------------------
				--Plainsrider Bow--
	--------------------------------------
	--------------------------------------
				--DECA Technologies Compound Bow--
	--------------------------------------
	--------------------------------------
				--English Longbow--
	--------------------------------------
	--------------------------------------
				--Heavy Crossbow--
	--------------------------------------
	--------------------------------------
				--GL 40 Grenade Launcher--
	--------------------------------------
	--------------------------------------
				--Piglet Grenade Launcher--
	--------------------------------------
	--------------------------------------
				--Flamethrower Mk.1--
	--------------------------------------
	--------------------------------------
	--Secondary Weapons--
	--------------------------------------
	--------------------------------------
		--Pistols--
	--------------------------------------
	--------------------------------------
			--Light Pistols--
	--------------------------------------
	--------------------------------------
				--Gruber Kurz--
	--------------------------------------
	--------------------------------------
				--Chimano 88--
	--------------------------------------
	--------------------------------------
				--M13 9mm--
	--------------------------------------
	--------------------------------------
				--Chimano Compact--
	--------------------------------------
	--------------------------------------
				--Crosskill Guard--
	--------------------------------------
	--------------------------------------
				--Bernetti 9--
	--------------------------------------
	--------------------------------------
			--Medium Pistols--
	--------------------------------------
	--------------------------------------
				--Crosskill--
	--------------------------------------
	--------------------------------------
				--Contractor--
	--------------------------------------
	--------------------------------------
				--Signature .40--
	--------------------------------------
	--------------------------------------
				--Broomstick--
	--------------------------------------
	--------------------------------------
				--Interceptor 45--
	--------------------------------------
	--------------------------------------
				--LEO--
	--------------------------------------
	--------------------------------------
				--Chimano Custom--
	--------------------------------------
	--------------------------------------
			--Heavy Pistols--
	--------------------------------------
	--------------------------------------
				--5/7 AP--
	--------------------------------------
	--------------------------------------
				--Deagle--
	--------------------------------------
	--------------------------------------
				--Parabellum--
	--------------------------------------
	--------------------------------------
				--Baby Deagle--
	--------------------------------------
	--------------------------------------
				--White Streak--
	--------------------------------------
	--------------------------------------
			--Revolvers--
	--------------------------------------
	--------------------------------------
				--Matever .357--
	--------------------------------------
	--------------------------------------
				--Bronco .44--
	--------------------------------------
	--------------------------------------
				--Castigo .44--
	--------------------------------------
	--------------------------------------
				--Peacemaker .45--
	--------------------------------------
	--------------------------------------
		--SMGs--
	--------------------------------------
	--------------------------------------
			--Light SMGs--
	--------------------------------------
	--------------------------------------
				--Tatonka--
	--------------------------------------
	--------------------------------------
				--Signature--
	--------------------------------------
	--------------------------------------
				--Compact-5--
	--------------------------------------
	--------------------------------------
				--Blaster 9mm--
	--------------------------------------
	--------------------------------------
				--CMP--
	--------------------------------------
	--------------------------------------
				--Cobra--
	--------------------------------------
	--------------------------------------
				--Micro Uzi--
	--------------------------------------
	--------------------------------------
			--Medium SMGs--
	--------------------------------------
	--------------------------------------
				--Para--
	--------------------------------------
	--------------------------------------
				--Chicago Typewriter--
	--------------------------------------
	--------------------------------------
				--Heather--
	--------------------------------------
	--------------------------------------
				--Kobus 90--
	--------------------------------------
	--------------------------------------
				--SpecOps--
	--------------------------------------
	--------------------------------------
				--Mark 10--
	--------------------------------------
	--------------------------------------
				--Kross Vertex--
	--------------------------------------
	--------------------------------------
				--Jacket's Piece--
	--------------------------------------
	--------------------------------------
			--Heavy SMGs--
	--------------------------------------
	--------------------------------------
				--Patchett L2A1--
	--------------------------------------
	--------------------------------------
				--MP40--
	--------------------------------------
	--------------------------------------
				--Swedish K--
	--------------------------------------
	--------------------------------------
				--Jackal--
	--------------------------------------
	--------------------------------------
				--CR 805B--
	--------------------------------------
	--------------------------------------
				--Krinkov--
	--------------------------------------
	--------------------------------------
		--Secondary Shotguns--
	--------------------------------------
	--------------------------------------
				--Claire 12G--
	--------------------------------------
	--------------------------------------
				--GSPS 12G--
	--------------------------------------
	--------------------------------------
				--Locomotive 12G--
	--------------------------------------
	--------------------------------------
				--Goliath 12G--
	--------------------------------------
	--------------------------------------
				--Judge--
	--------------------------------------
	--------------------------------------
				--Grimm 12G--
	--------------------------------------
	--------------------------------------
				--Street Sweeper--
	--------------------------------------
	--------------------------------------
		--Secondary Special Weapons--
	--------------------------------------
	--------------------------------------
				--Pistol Crossbow--
	--------------------------------------
	--------------------------------------
				--MA-17 Flamethrower--
	--------------------------------------
	--------------------------------------
				--Compact 40mm--
	--------------------------------------
	--------------------------------------
				--China Puff 40mm--
	--------------------------------------
	--------------------------------------
				--Arbiter--
	--------------------------------------
	--------------------------------------
				--HRL-7--
	--------------------------------------
	--------------------------------------
				--Commando 101--
	--------------------------------------
	--------------------------------------
	--OVE9000 Saw--
	--------------------------------------
	--------------------------------------
	--Shared Attachments--
	--------------------------------------
	--auto and singlefire mods
	self.parts.wpn_fps_upg_i_singlefire.stats = {value = 5}
	self.parts.wpn_fps_upg_i_autofire.stats = {value = 8}

	--Barrel extension stat changes begin here.
	-- Ported Compensator
		self.parts.wpn_fps_upg_ass_ns_battle.stats = {value = 1}
	-- Stubby Compensator
		self.parts.wpn_fps_upg_ns_ass_smg_stubby.stats = {value = 3}
	-- The Tank Compensator
		self.parts.wpn_fps_upg_ns_ass_smg_tank.stats = {value = 4}
	-- Fire Breather Nozzle
		self.parts.wpn_fps_upg_ns_ass_smg_firepig.stats = {value = 5}
	-- Tactical Compensator
		self.parts.wpn_fps_upg_ass_ns_surefire.stats = {value = 5}
	-- Funnel of Fun Nozzle
		self.parts.wpn_fps_upg_ass_ns_linear.stats = {value = 5}
	-- Competitor's Compensator
		self.parts.wpn_fps_upg_ass_ns_jprifles.stats = {value = 5}
	-- Medium Suppressor
		self.parts.wpn_fps_upg_ns_ass_smg_medium.stats = {suppression = 72,	alert_size = 12, value = 2}
	-- The Bigger the Better Suppressor
		self.parts.wpn_fps_upg_ns_ass_smg_large.stats = {suppression = 72, alert_size = 12, value = 5}
	-- Hurricane Compensator -- name is tentative due to limited documentation of cartel optics pack files
		self.parts.wpn_fps_upg_ns_pis_typhoon.stats = {value = 4}
	-- Marmon Compensator -- name is tentative due to limited documentation of cartel optics pack files
		self.parts.wpn_fps_upg_ns_ass_smg_v6.stats = {value = 3}
	-- Jungle Ninja Suppressor
		self.parts.wpn_fps_upg_ns_pis_jungle.stats = {suppression = 72,	value = 5}
	-- Budget Suppressor
		self.parts.wpn_fps_upg_ns_ass_filter.stats = {suppression = 72,	value = 0}
	-- Asepsis Suppressor
		self.parts.wpn_fps_upg_ns_pis_medium_slim.stats = {suppression = 72, alert_size = 12, value = 1}
	-- Monolith Suppressor
		self.parts.wpn_fps_upg_ns_pis_large.stats = {suppression = 72, alert_size = 12, value = 5}
	-- Champion's Suppressor
		self.parts.wpn_fps_upg_ns_pis_large_kac.stats = {suppression = 72, alert_size = 12, value = 6}
	-- Size Doesn't Matter Suppressor
		self.parts.wpn_fps_upg_ns_pis_small.stats = {suppression = 72, alert_size = 12, value = 3}
	-- Flash Hider
		self.parts.wpn_fps_upg_pis_ns_flash.stats = {suppression = 72, alert_size = 12, value = 4}
	-- Facepunch Compensator -- NOTE consider name change for Knockout
		self.parts.wpn_fps_upg_ns_pis_meatgrinder.stats = {suppression = 72, alert_size = 12, value = 7}
	-- IPSC Compensator
		self.parts.wpn_fps_upg_ns_pis_ipsccomp.stats = {suppression = 72, alert_size = 12, value = 4}
	-- Standard Issue Suppressor
		self.parts.wpn_fps_upg_ns_pis_medium.stats = {suppression = 72, alert_size = 12, value = 1}
	-- Roctec Suppressor
		self.parts.wpn_fps_upg_ns_pis_medium_gem.stats = {suppression = 72, alert_size = 12, value = 4}
	
	
	--Sight stat changes begin here.
	-- Milspec Scope
		self.parts.wpn_fps_upg_o_specter.stats = {zoom = 4, value = 8} -- i should probably write it like this for the rest of the attachments
	-- Military Red Dot Sight 
		self.parts.wpn_fps_upg_o_aimpoint.stats = {zoom = 4, value = 8}
	-- Military Red Dot Sight -- NOTE this is the preorder edition.
		self.parts.wpn_fps_upg_o_aimpoint_2.stats = {zoom = 4, value = 1}
	-- Surgeon Sight
		self.parts.wpn_fps_upg_o_docter.stats = {zoom = 2, value = 5}
	-- Holographic Sight
		self.parts.wpn_fps_upg_o_eotech.stats = {zoom = 3, value = 3}
	-- The Professional's Choice Sight
		self.parts.wpn_fps_upg_o_t1micro.stats = {zoom = 3, value = 3}
	-- Marksman Sight
		self.parts.wpn_upg_o_marksmansight_rear.stats = {zoom = 2, value = 5}
	-- Theia Magnified Scope
		self.parts.wpn_fps_upg_o_leupold.stats = {zoom = 10, value = 8}
	-- See More Sight
		self.parts.wpn_fps_upg_o_cmore.stats = {zoom = 3, value = 5}
	-- Acough Optic Scope
		self.parts.wpn_fps_upg_o_acog.stats = {zoom = 6, value = 6}
	-- Combat Sight
		self.parts.wpn_fps_upg_o_cs.stats = {zoom = 4, value = 3}
	-- Speculator Sight
		self.parts.wpn_fps_upg_o_reflex.stats = {zoom = 3, value = 5}
	-- Trigonom Sight
		self.parts.wpn_fps_upg_o_rx01.stats = {zoom = 3, value = 5}
	-- Compact Holosight
		self.parts.wpn_fps_upg_o_eotech_xps.stats = {zoom = 3, value = 5}
	-- [NOTE unable to find name in documentation]
		self.parts.wpn_fps_upg_o_bmg.stats = {zoom = 6, value = 8}
	-- [NOTE unable to find name in documentation]
		self.parts.wpn_fps_upg_o_uh.stats = {zoom = 3, value = 5}
	-- [NOTE unable to find name in documentation]
		self.parts.wpn_fps_upg_o_fc1.stats = {zoom = 3, value = 5}
	-- SKOLD Reflex Micro Sight -- name is tentative due to limited documentation of cartel optics pack files (what of rmr?)
		self.parts.wpn_fps_upg_o_rms.stats = {zoom = 3, value = 6}
	-- Riktpunkt Holosight -- name is tentative due to limited documentation of cartel optics pack files
		self.parts.wpn_fps_upg_o_rikt.stats = {zoom = 3, value = 6}
	-- Magazine stat changes begin here.
		-- Milspec Magazine
		self.parts.wpn_fps_m4_uupg_m_std.stats = {value = 1}
		-- L5 Magazine
		self.parts.wpn_fps_upg_m4_m_l5.stats = {value = 1}
		-- Tactical Magazine
		self.parts.wpn_fps_upg_m4_m_pmag.stats = {value = 3}
		-- Expert Magazine
		self.parts.wpn_fps_ass_l85a2_m_emag.stats = {value = 1}
		-- Quadstack Magazine
		self.parts.wpn_fps_upg_m4_m_quad.stats = {
			value = 3,		
			extra_ammo = 15, 
			concealment = -10
		}
		-- Vintage Mag
		self.parts.wpn_fps_upg_m4_m_straight.stats = {	
			value = 2,		
			extra_ammo = -5, 
			concealment = 5
		}		
		-- Speedpull Magazine
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
		-- 45 Degree Red Dot Sight				
		self.parts.wpn_fps_upg_o_45rds.stats = {value = 1, gadget_zoom = 1}	
		-- Riktpunkt 45 Degree Sight
		self.parts.wpn_fps_upg_o_45rds_v2.stats = {value = 1, gadget_zoom = 1}	
		-- Riktpunkt Magnifier
		self.parts.wpn_fps_upg_o_xpsg33_magnifier.stats = {value = 1, gadget_zoom = 9}
		-- Signature Magnifier
		self.parts.wpn_fps_upg_o_sig.stats = {zoom = 9, value = 2}
		-- 45 Degree Ironsights
		self.parts.wpn_fps_upg_o_45steel.stats = {value = 1, gadget_zoom = 1}		
	--Grip stat changes begin here.
		-- Pro Grip
		self.parts.wpn_fps_upg_m4_g_sniper.stats = {value = 2}	
		-- Ergo Grip
		self.parts.wpn_fps_upg_m4_g_ergo.stats = {value = 2}	
		-- Rubber Grip
		self.parts.wpn_fps_upg_m4_g_hgrip.stats = {value = 1}	
		-- Contractor Grip
		self.parts.wpn_fps_snp_tti_g_grippy.stats = {value = 1}
		-- Short Grip
		self.parts.wpn_fps_upg_m4_g_mgrip.stats = {value = 1}	
		-- Titanium Skeleton Grip
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
