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

--Template entry material:
--Weapon
	--ID: [whatever]
	--Value: 
	--Magazine: 20
	--Ammo: 300
	--Fire Rate: 545
	--Damage:50
	--Acc: 100
	--Stab: 100
	--Conc: 30
	--Threat: 10
	--Pickup: 9, 18
	--Notes: many shared mods
--Mod
	--Mod name
	--WeaponFactory ID: [whatever]
	--Value: 
	--Magazine: 
	--Conc: 
	--+100% Reload speed
	--Notes: 
			
			
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
	--ID: self.amcar
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 20
	--Ammo: 300
	--Fire Rate: 545
	--Damage: 50
	--Acc: 100
	--Stab: 100
	--Conc: 30
	--Threat: 10
	--Pickup: 9, 18
	--Notes: Being the "training wheels" gun and having notably lower DPS than every other AR, 
	--it received additional buffs in multiple areas to make it a viable comfort pick. 
	--Active Mods:
			
	--Speed pull Mag [wpn_fps_m4_upg_m_quick] [+100% Reload Speed, +10 Magazine -4 Concealment] Value: 2

		-- L5 Magazine [+10 Magazine, -2 Concealment] [wpn_fps_upg_m4_m_l5] Value: 1
		self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_l5 = { -- gotta be like this or else the game shits the bed
			stats = {	
				value = 1,			 			 
				extra_ammo = 5, 
				concealment = -2
			}
		}			
		-- Milspec Mag [+10 Magazine, -2 Concealment] [wpn_fps_m4_uupg_m_std] Value: 1
		self.wpn_fps_ass_amcar.override.wpn_fps_m4_uupg_m_std = {	
			stats = {			
				value = 1,			 
				extra_ammo = 5, 
				concealment = -2
			}
		}
		-- Tactical Mag	[+10 Magazine, -2 Concealment] [wpn_fps_upg_m4_m_pmag] Value: 3
		self.wpn_fps_ass_amcar.override.wpn_fps_upg_m4_m_pmag = {	
			stats = {			
				value = 3,
				extra_ammo = 5, 
				concealment = -2
			}
		}
		-- Expert Mag [+10 Magazine, -2 Concealment] [wpn_fps_ass_l85a2_m_emag] [Value: 1]	
		self.wpn_fps_ass_amcar.override.wpn_fps_ass_l85a2_m_emag = {	
			stats = {
				value = 1,			 
				extra_ammo = 5, 
				concealment = -2
			}
		}
		--CAR Quadstacked Mag [wpn_fps_upg_m4_m_quad] [+40 Magazine, -10 Concealment] [Value: 3]
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
	--ID: self.tecci
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 100
	--Ammo: 400
	--Fire Rate: 667
	--Damage: 50
	--Acc: 52
	--Stab: 92
	--Conc: 10
	--Threat: 22
	--Pickup: 8, 16
	--Notes:
	--Active Mods:

	--------------------------------------
				--JP36--
	--------------------------------------
	--ID: self.g36
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 30
	--Ammo: 300
	--Fire Rate: 706
	--Damage: 50
	--Acc: 84
	--Stab: 100
	--Conc: 25
	--Threat: 10
	--Pickup: 9, 18
	--Notes:
	--Active Mods: Speedpull Mag [wpn_fps_ass_g36_m_quick] [+100% Reload Speed, -5 Concealment] Value: 2

	--------------------------------------
				--Commando 553--
	--------------------------------------
	--ID: self.s552
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 30
	--Ammo: 300
	--Fire Rate: 714
	--Damage: 50
	--Acc: 60
	--Stab: 100
	--Conc: 30
	--Threat: 10
	--Pickup: 8, 16
	--Notes:
	--Active Mods:

	--------------------------------------
				--Clarion--
	--------------------------------------
	--ID: self.famas
	--Class: Rapid Fire
	--Value: 4
	--Magazine: 30
	--Ammo: 300
	--Fire Rate: 1000
	--Damage: 50
	--Acc: 72
	--Stab: 80
	--Conc: 25
	--Threat: 10
	--Pickup: 8, 16
	--Notes:
	--Active Mods: Suppressed Barrel [wpn_fps_ass_famas_b_suppressed] [Suppresses Weapon, + Quiet, -100 Threat] Value: 4

	--------------------------------------
			--Medium ARs--
	--------------------------------------
	--------------------------------------
				--Valkyria--
	--------------------------------------
	--ID: self.asval
	--Class: Rapid Fire, Quiet
	--Value: 1
	--Magazine: 20
	--Ammo: 180
	--Fire Rate: 545 (Old: 896)
	--Damage: 80
	--Acc: 92
	--Stab: 100
	--Conc: 20
	--Threat: 0
	--Pickup: 7, 12
	--Notes: Moved to a slower-firing, harder-hitting category upon community request.
	--NOTE: Suppressed.
	--Active Mods: Prototype Barrel [+10 Concealment, -12 Accuracy, -20 Concealment]

	self.parts.wpn_fps_ass_asval_b_standard.stats = nil --why overkill -- probably to avoid a suppression overwrite? -Finale
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
	--ID: self.new_m4
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 30
	--Ammo: 210
	--Fire Rate: 600
	--Damage: 80
	--Acc: 100
	--Stab: 100
	--Conc: 15
	--Threat: 14
	--Pickup: 6, 10
	--Notes: 
	--Active Mods: 
	--DMR Kit [wpn_fps_upg_ass_m4_b_beowulf] [- Rapid Fire, + Precision, +Armor Piercing, -135 Ammo Stock,
		--+80 Damage, -40 Stability, -5 Concealment, -3, 6 Pickup] Value: 1

	--Vintage Mag [wpn_fps_upg_m4_m_straight] [-10 Magazine, +5 Concealment] Value: 2
			
	--CAR Quadstacked Mag [wpn_fps_upg_m4_m_quad] [+30 Magazine, -10 Concealment] Value: 3

	--Speedpull Mag [wpn_fps_m4_upg_m_quick] [+100% Reload Speed, -4 Concealment] Value: 2

		-- Aftermarket Special Handguard	
		self.parts.wpn_fps_m4_uupg_fg_lr300.stats = {value = 5}
		-- Competition Foregrip		
		self.parts.wpn_fps_upg_fg_jp.stats = {value = 5}
		-- Gazelle Rail
		self.parts.wpn_fps_upg_fg_smr.stats = {value = 5}
		-- OVAL Foregrip		
		self.parts.wpn_fps_upg_ass_m4_fg_lvoa.stats = {value = 1}
		-- E.M.O. Foregrip		
		self.parts.wpn_fps_upg_ass_m4_fg_moe.stats = {value = 1}
		-- Long Barrel
		self.parts.wpn_fps_m4_uupg_b_long.stats = {value = 4}
		-- Short Barrel		
		self.parts.wpn_fps_m4_uupg_b_short.stats = {value = 5}

	--Stealth Barrel [wpn_fps_m4_uupg_b_sd] [Suppresses Weapon, + Quiet, -12 Accuracy, +3 Concealment, -100 Threat] Value: 6		
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
	--INCOMPLETE - see active mod description under CAR-4 instead.

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
	--ID: self.ak74
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 30
	--Ammo: 210
	--Fire Rate: 652
	--Damage: 80
	--Acc: 92
	--Stab: 100
	--Conc: 15
	--Threat: 14
	--Pickup: 6, 10
	--Notes: 
	--Active Mods: DMR Kit, AK Quadstacked Mag, Speedpull Mag
	--DMR Kit [wpn_fps_upg_ass_ak_b_zastava] [- Rapid Fire, + Precision, +Armor Piercing, -135 Ammo Stock,
		--+80 Damage, +8 Accuracy, -44 Stability, -5 Concealment, -3, 6 Pickup] Value: 1
			
	--AK Quadstacked Mag [wpn_fps_upg_ak_m_quad] [+30 Magazine, -10 Concealment] Value: 3
			
	--Speedpull Mag [wpn_fps_upg_ak_m_quick] [+100% Reload Speed, -4 Concealment] Value: 2

	--------------------------------------
				--AK (DMR Kit)--
	--------------------------------------
	--Note: Conversion kit entries are not actual weapons and are only listed for referential purposes.
	--INCOMPLETE - consult mod information for AK instead.

	--------------------------------------
				--AK17--
	--------------------------------------
	--ID: self.flint
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 30
	--Ammo: 210
	--Fire Rate: 652
	--Damage: 80
	--Acc: 92
	--Stab: 100
	--Conc: 10
	--Threat: 14
	--Pickup: 6, 10
	--Notes: Was previously a Heavy AR.
	--Active Mods:
	--AK Quadstacked Mag [wpn_fps_upg_ak_m_quad] [+30 Magazine, -10 Concealment] Value: 3
			
	--Speedpull Mag [wpn_fps_upg_ak_m_quick] [+100% Reload Speed, -4 Concealment] Value: 2

	--------------------------------------
				--AK5--
	--------------------------------------
	--ID: self.ak5
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 30
	--Ammo: 210
	--Fire Rate: 706
	--Damage: 80
	--Acc: 92
	--Stab: 100
	--Conc: 15
	--Threat: 14
	--Pickup: 6, 10
	--Notes:
	--Active Mods: 
	--Vintage Mag [wpn_fps_upg_m4_m_straight] [-10 Magazine, +5 Concealment] Value: 2	

	--CAR Quadstacked Mag [wpn_fps_upg_m4_m_quad][+30 Magazine, -10 Concealment] Value: 3

	--Speedpull Mag [wpn_fps_m4_upg_m_quick] [+100% Reload Speed, -4 Concealment] Value: 2 
	--note doublecheck using car4 speedpull id here.

	--------------------------------------
				--Queen's Wrath--
	--------------------------------------
	--ID: self.l85a2
	--Class: Rapid Fire
	--Value: 9
	--Magazine: 30
	--Ammo: 210
	--Fire Rate: 723
	--Damage: 80
	--Acc: 84
	--Stab: 100
	--Conc: 15
	--Threat: 14
	--Pickup: 6, 10
	--Notes:
	--Active Mods: Vintage Mag [wpn_fps_upg_m4_m_straight] [-10 Magazine, +5 Concealment] Value: 2
			
	--CAR Quadstacked Mag [wpn_fps_upg_m4_m_quad] [+30 Magazine, -10 Concealment] Value: 3
			
	--Speedpull Mag [wpn_fps_m4_upg_m_quick] [+100% Reload Speed, -4 Concealment] Value: 2

	--------------------------------------
				--UAR--
	--------------------------------------
	--ID: self.aug
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 30
	--Ammo: 210
	--Fire Rate: 750
	--Damage: 80
	--Acc: 80
	--Stab: 100
	--Conc: 15
	--Threat: 14
	--Pickup: 6, 10
	--Notes:
	--Active Mods: 	
	--Speedpull Mag [wpn_fps_ass_aug_m_quick] [+100% Reload Speed, -4 Concealment] Value: 2

	--------------------------------------
				--Tempest-21--
	--------------------------------------
	--ID: self.komodo
	--Class: Rapid Fire
	--Value: 9
	--Magazine: 30
	--Ammo: 210
	--Fire Rate: 800
	--Damage: 80
	--Acc: 84
	--Stab: 100
	--Conc: 20
	--Threat: 14
	--Pickup: 6, 10
	--Notes:
	--Active Mods: Vintage Mag [wpn_fps_upg_m4_m_straight] [-10 Magazine, +5 Concealment] Value: 2
			
	--CAR Quadstacked Mag [wpn_fps_upg_m4_m_quad] [+30 Magazine, -10 Concealment] Value: 3
			
	--Speedpull Mag [wpn_fps_m4_upg_m_quick] [+100% Reload Speed, -4 Concealment] Value: 2

	--------------------------------------
				--Gecko 7.62--
	--------------------------------------
	--ID: self.galil
	--Class: Rapid Fire
	--Value: 4
	--Magazine: 30
	--Ammo: 210
	--Fire Rate: 845
	--Damage: 80
	--Acc: 100
	--Stab: 76
	--Conc: 15
	--Threat: 14
	--Pickup: 6, 10
	--Notes:
	--Active Mods:

	--------------------------------------
				--Lion's Roar--
	--------------------------------------
	--BEST GUN
	--That's debatable - Finale
	--ID: self.vhs
	--Class: Rapid Fire
	--Value: 9
	--Magazine: 30
	--Ammo: 210
	--Fire Rate: 857
	--Damage: 80
	--Acc: 72
	--Stab: 100
	--Conc: 15
	--Threat: 14
	--Pickup: 6, 10
	--Notes:
	--Active Mods: Silenced Barrel [wpn_fps_ass_vhs_b_silenced] [Suppresses Weapon, + Quiet, -100 Threat] Value: 2

	--------------------------------------
				--Union 5.56--
	--------------------------------------
	--ID: self.corgi
	--Class: Rapid Fire
	--Value: 9
	--Magazine: 30
	--Ammo: 210
	--Fire Rate: 857
	--Damage: 80
	--Acc: 72
	--Stab: 100
	--Conc: 15
	--Threat: 14
	--Pickup: 6, 10
	--Notes:
	--Active Mods: Vintage Mag [wpn_fps_upg_m4_m_straight] [-10 Magazine, +5 Concealment] Value: 2
			
	--CAR Quadstacked Mag [wpn_fps_upg_m4_m_quad] [+30 Magazine, -10 Concealment] Value: 3
			
	--Speedpull Mag [wpn_fps_m4_upg_m_quick] [+100% Reload Speed, -4 Concealment] Value: 2

	--------------------------------------
			--Heavy ARs--
	--------------------------------------
	--------------------------------------
				--AK.762--
	--------------------------------------
	--ID: self.akm
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 30
	--Ammo: 150
	--Fire Rate: 561
	--Damage: 110
	--Acc: 92
	--Stab: 100
	--Conc: 10
	--Threat: 20
	--Pickup: 4, 6
	--Notes:
	--Active Mods: AK Quadstacked Mag [wpn_fps_upg_ak_m_quad] [+30 Magazine, -10 Concealment] Value: 3
			
	--Speed Pull Mag [wpn_fps_upg_ak_m_quick] [+100% Reload Speed, -4 Concealment] Value: 2
			
	--DMR Kit [wpn_fps_upg_ass_ak_b_zastava] [-Rapid Fire, -Precision, +Armor Piercing, -75 Ammo Stock, -50 Damage, +8 Accuracy,
	-- -20 Stability, +2 Threat, -1, -2 Pickup] Value: 1
	-- NOTE This DMR Kit manually calculated from diff values. may require further scrutiny.

	--------------------------------------
				--AK.762 (DMR Kit)--
	--------------------------------------
	--Note: Conversion kit entries are not actual weapons and are only listed for referential purposes.
	--INCOMPLETE -consult AK.762 mods
	--------------------------------------
				--AK.762 Golden--
	--------------------------------------
	--ID: self.akm_gold
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 30
	--Ammo: 150
	--Fire Rate: 561
	--Damage: 110
	--Acc: 92
	--Stab: 100
	--Conc: 10
	--Threat: 20
	--Pickup: 4, 6
	--Notes:
	--Active Mods: 
	--Active Mods: AK Quadstacked Mag  [wpn_fps_upg_ak_m_quad] [+30 Magazine, -10 Concealment] Value: 3
			
	--Speed Pull Mag [wpn_fps_upg_ak_m_quick] [+100% Reload Speed, -4 Concealment] Value: 2
			
	--DMR Kit [wpn_fps_upg_ass_ak_b_zastava] [-Rapid Fire, -Precision, +Armor Piercing, -75 Ammo Stock, -50 Damage, +8 Accuracy,
	-- -20 Stability, +2 Threat, -1, -2 Pickup] Value: 1
	-- NOTE This DMR Kit manually calculated from diff values. may require further scrutiny.
	
	--------------------------------------
				--Eagle Heavy--
	--------------------------------------
	--ID: self.scar
	--Class: Rapid Fire
	--Value: 9
	--Magazine: 20
	--Ammo: 140
	--Fire Rate: 612
	--Damage: 110
	--Acc: 100
	--Stab: 84
	--Conc: 10
	--Threat: 20
	--Pickup: 4, 6
	--Notes:
	--Active Mods: 

	--------------------------------------
				--Gewehr 3--
	--------------------------------------
	--ID: self.g3
	--Class: Rapid Fire
	--Value: 4
	--Magazine: 20
	--Ammo: 140
	--Fire Rate: 652
	--Damage: 110
	--Acc: 100
	--Stab: 84
	--Conc: 10
	--Threat: 20
	--Pickup: 4, 6
	--Notes:
	--Active Mods: 
	--Assault Kit [wpn_fps_ass_g3_b_short] [+85 Ammo Stock, -30 Damage, -16 Accuracy, +16 Stability, +5 Concealment, +2, +4 Pickup] Value: 2
	--DMR Kit [wpn_fps_ass_g3_b_sniper] [- Rapid Fire, + Precision, + Armor Piercing, -10 Magazine, -65 Ammo Stock, +50 Damage, -1, -2 Pickup] Value: 2

	--------------------------------------
				--Gewehr 3 (DMR Kit)--
	--------------------------------------
	--Note: Conversion kit entries are not actual weapons and are only listed for referential purposes.
	--INCOMPLETE --See main Gewehr mod entries for information.
	--------------------------------------
				--Gewehr 3 (assault kit)--
	--------------------------------------
	--Note: Conversion kit entries are not actual weapons and are only listed for referential purposes.
	--INCOMPLETE --See main Gewehr mod entries for information.
	--------------------------------------
				--Falcon--
	--------------------------------------	
	--ID: self.fal
	--Class: Rapid Fire
	--Value: 4
	--Magazine: 20
	--Ammo: 140
	--Fire Rate: 698
	--Damage: 110
	--Acc: 100
	--Stab: 86
	--Conc: 10
	--Threat: 20
	--Pickup: 4, 6
	--Notes:
	--Active Mods: Extended Magazine [wpn_fps_ass_fal_m_01] [+20 Magazine, -10 Concealment] Value: 2

	--------------------------------------
				--AMR-16--
	--------------------------------------
	--ID: self.m16
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 20
	--Ammo: 140
	--Fire Rate: 857
	--Damage: 110
	--Acc: 96
	--Stab: 100
	--Conc: 10
	--Threat: 20
	--Pickup: 4, 6
	--Notes:
	--Active Mods: 
	--DMR Kit [wpn_fps_upg_ass_m4_b_beowulf] [- Rapid Fire, + Precision, + Armor Piercing, -65 Ammo Stock,
	-- +50 Damage, +4 Accuracy, -40 Stability, -1, -2 Pickup] Value: 1

	--Speedpull Mag [wpn_fps_m4_upg_m_quick] [+100% Reload Speed, +10 Magazine, -4 Concealment] Value: 2

		-- Long Ergo Foregrip
		self.parts.wpn_fps_upg_ass_m16_fg_stag.stats = {value = 1}
		-- Blast From the Past Handguard
		self.parts.wpn_fps_m16_fg_vietnam.stats = {value = 10}
		-- Tactical Handguard
		self.parts.wpn_fps_m16_fg_railed.stats = {value = 7}
			
		-- L5 Magazine [wpn_fps_upg_m4_m_l5] [+10 Magazine, -2 Concealment] Value: 1
		self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_l5 = {
			stats = {
				value = 1,			 			 
				extra_ammo = 5, 
				concealment = -2	
			}
		}
		--Milspec Mag [wpn_fps_m4_uupg_m_std] [+10 Magazine, -2 Concealment] Value: 1
		self.wpn_fps_ass_m16.override.wpn_fps_m4_uupg_m_std = {	
			stats = {
				value = 1,			 
				extra_ammo = 5, 
				concealment = -2	
			}
		}
		--Tactical Mag [wpn_fps_upg_m4_m_pmag] [+10 Magazine, -2 Concealment] Value: 3
		self.wpn_fps_ass_m16.override.wpn_fps_upg_m4_m_pmag = {	
		stats = {
				value = 3,
				extra_ammo = 5, 
				concealment = -2
			}
		}
		--Expert Mag [wpn_fps_ass_l85a2_m_emag] [+10 Magazine, -2 Concealment] Value: 1
		self.wpn_fps_ass_m16.override.wpn_fps_ass_l85a2_m_emag = {	
			stats = {
				value = 1,			 
				extra_ammo = 5, 
				concealment = -2
			}
		}
		-- CAR Quadstacked Mag [wpn_fps_upg_m4_m_quad] [+40 Magazine, -10 Concealment] Value: 3
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
	--INCOMPLETE see AMR-16 entry mod information for details.
	--------------------------------------
		--Akimbo Machine Pistols--
	--------------------------------------
	--------------------------------------
				--Akimbo Igor Automatik Pistols--
	--------------------------------------
	--ID: self.x_stech
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 40
	--Ammo: 400
	--Fire Rate: 750
	--Damage: 60
	--Acc: 80
	--Stab: 44
	--Conc: 32
	--Threat: 8
	--Pickup: 7, 11
	--Notes:
	--Active Mods: Extended Mag. [wpn_fps_pis_stech_m_extended] [+28 Magazine, -4 Concealment] Value: 5
	--NOTE not in mws wiki. Leave this note.
			
	--------------------------------------
				--Akimbo STRYK 18c--
	--------------------------------------
	--ID: self.x_g18c
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 40
	--Ammo: 560
	--Fire Rate: 909
	--Damage: 40
	--Acc: 68
	--Stab: 88
	--Conc: 32
	--Threat: 8
	--Pickup: 9, 18
	--Notes:
	--Active Mods: Extended Mag. [wpn_fps_pis_g18c_m_mag_33rnd] [+24 Magazine, -4 Concealment] Value: 6

	--------------------------------------
				--Akimbo Czech 92 Pistols--
	--------------------------------------
	--ID: self.x_czech
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 30
	--Ammo: 600
	--Fire Rate: 1000
	--Damage: 40
	--Acc: 80
	--Stab: 80
	--Conc: 32
	--Threat: 8
	--Pickup: 9, 18
	--Notes:
	--Active Mods: Extended Magazine [wpn_fps_pis_czech_m_extended] [+20 Magazine, -4 Concealment] Value: 1
	--NOTE not in mws wiki. Leave this note.

	--------------------------------------
				--Akimbo Bernetti Auto Pistols--
	--------------------------------------
	--ID: self.x_beer
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 30
	--Ammo: 600
	--Fire Rate: 1101
	--Damage: 40
	--Acc: 84
	--Stab: 80
	--Conc: 32
	--Threat: 8
	--Pickup: 9, 18
	--Notes:
	--Active Mods: Extended Magazine [wpn_fps_pis_beer_m_extended] [+12 Magazine, -2 Concealment] Value: 3
	--NOTE not in mws wiki. Leave this note.

	--------------------------------------
		--Akimbo SMGs--
	--------------------------------------
	--------------------------------------
			--Akimbo Light SMGs--
	--------------------------------------
	--------------------------------------
				--Akimbo Tatonka--
	--------------------------------------
	--ID: self.x_coal
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 128
	--Ammo: 320
	--Fire Rate: 652
	--Damage: 50
	--Acc: 80
	--Stab: 84
	--Conc: 25
	--Threat: 10
	--Pickup: 8, 16
	--Notes: Formerly a Heavy SMG.
	--Active Mods: 

	--------------------------------------
				--Akimbo Uzi--
	--------------------------------------
	--ID: self.x_uzi
	--Class: Rapid Fire
	--Value: 7
	--Magazine: 64
	--Ammo: 320
	--Fire Rate: 698
	--Damage: 50
	--Acc: 80
	--Stab: 84
	--Conc: 25
	--Threat: 10
	--Pickup: 8, 16
	--Notes: 
	--Active Mods: 

	--------------------------------------
				--Akimbo Signature SMG--
	--------------------------------------
	--ID: self.x_shepheard
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 40
	--Ammo: 320
	--Fire Rate: 750
	--Damage: 50
	--Acc: 60
	--Stab: 100
	--Conc: 25
	--Threat: 10
	--Pickup: 8, 16
	--Notes: 
	--Active Mods: Extended Magazine [wpn_fps_smg_shepheard_mag_extended] [+20 Magazine, -5 Concealment] Value: 1

	--------------------------------------
				--Akimbo Compact-5--
	--------------------------------------
	--ID: self.x_mp5
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 60
	--Ammo: 320
	--Fire Rate: 750
	--Damage: 50
	--Acc: 72
	--Stab: 100
	--Conc: 25
	--Threat: 10
	--Pickup: 8, 16
	--Notes: 
	--Active Mods: 

	--------------------------------------
				--Akimbo Blaster 9mm--
	--------------------------------------
	--ID: self.x_tec9
	--Class: Rapid Fire
	--Value: 7
	--Magazine: 40
	--Ammo: 320
	--Fire Rate: 896
	--Damage: 50
	--Acc: 52
	--Stab: 100
	--Conc: 30
	--Threat: 10
	--Pickup: 8, 16
	--Notes: 
	--Active Mods: Extended Mag [wpn_fps_smg_tec9_m_extended] [+24 Magazine, -10 Concealment] Value: 4

	--------------------------------------
				--Akimbo CMP--
	--------------------------------------
	--ID: self.x_mp9
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 30
	--Ammo: 320
	--Fire Rate: 952
	--Damage: 50
	--Acc: 52
	--Stab: 100
	--Conc: 30
	--Threat: 10
	--Pickup: 8, 16
	--Notes: 
	--Active Mods: Extended Mag. [wpn_fps_smg_mp9_m_extended] [+30 Magazine, -5 Concealment] Value: 4
	--Tactical Suppressor [wpn_fps_smg_mp9_b_suppressed] [Suppresses Weapon, +Quiet, -100 Threat] Value: 4

	--------------------------------------
				--Akimbo Cobra--
	--------------------------------------
	--ID: self.x_scorpion
	--Class: Rapid Fire
	--Value: 7
	--Magazine: 40
	--Ammo: 320
	--Fire Rate: 1000
	--Damage: 50
	--Acc: 52
	--Stab: 100
	--Conc: 30
	--Threat: 10
	--Pickup: 8, 16
	--Notes: 
	--Active Mods: Extended Mag [wpn_fps_smg_scorpion_m_extended] [+40 Magazine, -10 Concealment] Value: 1

	--------------------------------------
				--Akimbo Micro Uzi--
	--------------------------------------
	--ID: self.x_baka
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 64
	--Ammo: 320
	--Fire Rate: 1200
	--Damage: 50
	--Acc: 44
	--Stab: 100
	--Conc: 25
	--Threat: 10
	--Pickup: 8, 16
	--Notes: 
	--Active Mods: 
	--Futomaki Suppressor [wpn_fps_smg_baka_b_longsupp] [Suppresses Weapon, +Quiet, -100 Threat] Value: 1
	--Maki Suppressor [wpn_fps_smg_baka_b_midsupp] [Suppresses Weapon, +Quiet, -100 Threat] Value: 1
	--Spring Suppressor [wpn_fps_smg_baka_b_smallsupp] [Suppresses Weapon, +Quiet, -100 Threat] Value: 1

	--------------------------------------
			--Akimbo Medium SMGs--
	--------------------------------------
	--------------------------------------
				--Akimbo Para--
	--------------------------------------
	--ID: self.x_olympic
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 40
	--Ammo: 240
	--Fire Rate: 682
	--Damage: 70
	--Acc: 92
	--Stab: 100
	--Conc: 25
	--Threat: 13
	--Pickup: 6, 10
	--Notes: 
	--Active Mods: Milspec Mag [wpn_fps_m4_uupg_m_std] [+20 Magazine, -10 Concealment] Value: 1

	--Tactical Mag [wpn_fps_upg_m4_m_pmag] [+20 Magazine, -10 Concealment] Value: 3

	--Expert Mag [wpn_fps_ass_l85a2_m_emag] [+20 Magazine, -10 Concealment] Value: 1

	--L5 Magazine [wpn_fps_upg_m4_m_l5] [+20 Magazine, -10 Concealment] Value: 1

	--CAR Quadstacked Mag [wpn_fps_upg_m4_m_quad] [+80 Magazine, -20 Concealment] Value: 3

	--Speedpull Mag [wpn_fps_m4_upg_m_quick] [+100% Reload Speed, +20 Magazine, -8 Concealment] Value: 2

	--------------------------------------
				--Akimbo Chicago Typewriter--
	--------------------------------------
	--ID: self.x_m1928
	--Class: Rapid Fire
	--Value: 9
	--Magazine: 100
	--Ammo: 240
	--Fire Rate: 723
	--Damage: 70
	--Acc: 84
	--Stab: 100
	--Conc: 15
	--Threat: 20
	--Pickup: 6, 10
	--Notes: 
	--Active Mods: 

	--------------------------------------
				--Akimbo Heather--
	--------------------------------------
	--ID: self.x_sr2
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 60
	--Ammo: 240
	--Fire Rate: 750
	--Damage: 70
	--Acc: 84
	--Stab: 100
	--Conc: 25
	--Threat: 13
	--Pickup: 6, 10
	--Notes: 
	--Active Mods: Speed Pull Mag [wpn_fps_smg_sr2_m_quick] [+100% Reload Speed, -8 Concealment] Value: 2

	--------------------------------------
				--Akimbo Kobus 90--
	--------------------------------------
	--ID: self.x_p90
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 100
	--Ammo: 240
	--Fire Rate: 909
	--Damage: 70
	--Acc: 80
	--Stab: 100
	--Conc: 20
	--Threat: 13
	--Pickup: 6, 10
	--Notes: 
	--Active Mods: Speed Pull Mag [wpn_fps_smg_p90_m_strap] [+100% Reload Speed, -8 Concealment] Value: 2

	--------------------------------------
				--Akimbo SpecOps--
	--------------------------------------
	--ID: self.x_mp7
	--Class: Rapid Fire
	--Value: 7
	--Magazine: 40
	--Ammo: 240
	--Fire Rate: 952
	--Damage: 70
	--Acc: 84
	--Stab: 100
	--Conc: 25
	--Threat: 13
	--Pickup: 6, 10
	--Notes: 
	--Active Mods: Extended Mag. [wpn_fps_smg_mp7_m_extended] [+20 Magazine, -5 Concealment] Value: 1

	--------------------------------------
				--Akimbo Mark 10--
	--------------------------------------
	--ID: self.x_mac10
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 40
	--Ammo: 240
	--Fire Rate: 1000
	--Damage: 70
	--Acc: 84
	--Stab: 100
	--Conc: 30
	--Threat: 13
	--Pickup: 6, 10
	--Notes: 
	--Active Mods: Extended Mag. [wpn_fps_smg_mac10_m_extended] [+40 Magazine, -10 Concealment] Value: 2
	--Speedpull Mag [wpn_fps_smg_mac10_m_quick] [+100% Reload Speed, +40 Magazine, -8 Concealment] Value: 2

	--------------------------------------
				--Akimbo Kross Vertex--
	--------------------------------------
	--ID: self.x_polymer
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 60
	--Ammo: 240
	--Fire Rate: 1200
	--Damage: 70
	--Acc: 84
	--Stab: 100
	--Conc: 15
	--Threat: 13
	--Pickup: 6, 10
	--Notes: 
	--Active Mods:

	--------------------------------------
				--Akimbo Jacket's Piece--
	--------------------------------------
	--ID: self.x_cobray
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 64
	--Ammo: 240
	--Fire Rate: 1200
	--Damage: 70
	--Acc: 72
	--Stab: 100
	--Conc: 20
	--Threat: 13
	--Pickup: 6, 10
	--Notes: 
	--Active Mods:

	--------------------------------------
			--Akimbo Heavy SMGs--
	--------------------------------------
	--------------------------------------
				--Akimbo Patchett L2A1--
	--------------------------------------
	--ID: self.x_sterling
	--Class: Rapid Fire
	--Value: 7
	--Magazine: 40
	--Ammo: 160
	--Fire Rate: 545
	--Damage: 100
	--Acc: 60
	--Stab: 100
	--Conc: 20
	--Threat: 20
	--Pickup: 4, 6
	--Notes: Formerly a Light SMG.
	--Active Mods: 
	--Extended Mag [wpn_fps_smg_sterling_m_long] [+20 Magazine, -10 Concealment] Value: 1

	--Short Mag [wpn_fps_smg_sterling_m_short] [-20 Magazine, +10 Concealment] Value: 1

	--Heatsinked Suppressed Barrel [wpn_fps_smg_sterling_b_e11] [Suppresses Weapon, + Quiet, -100 Threat] Value: 4

	--Suppressed Barrel [wpn_fps_smg_sterling_b_suppressed] [Suppresses Weapon, + Quiet, -100 Threat] Value: 4

	--------------------------------------
				--Akimbo MP40--
	--------------------------------------
	--ID: self.x_erma
	--Class: Rapid Fire
	--Value: 5
	--Magazine: 64
	--Ammo: 160
	--Fire Rate: 600
	--Damage: 100
	--Acc: 68
	--Stab: 100
	--Conc: 20
	--Threat: 20
	--Pickup: 4, 6
	--Notes:
	--Active Mods: 

	--------------------------------------
				--Akimbo Swedish K--
	--------------------------------------
	--ID: self.x_m45
	--Class: Rapid Fire
	--Value: 5
	--Magazine: 72
	--Ammo: 160
	--Fire Rate: 600
	--Damage: 100
	--Acc: 60
	--Stab: 100
	--Conc: 20
	--Threat: 20
	--Pickup: 4, 6
	--Notes:
	--Active Mods: Extended Mag. [wpn_fps_smg_m45_m_extended] [+28 Magazine, -15 Concealment] Value: 4

	--------------------------------------
				--Akimbo Jackal--
	--------------------------------------
	--ID: self.x_schakal
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 60
	--Ammo: 160
	--Fire Rate: 652
	--Damage: 100
	--Acc: 64
	--Stab: 100
	--Conc: 20
	--Threat: 20
	--Pickup: 4, 6
	--Notes:
	--Active Mods: Extended Magazine [wpn_fps_smg_schakal_m_long] [+20 Magazine, -15 Concealment] Value: 1
	--Short Magazine [wpn_fps_smg_schakal_m_short] [+20 Magazine, +5 Concealment] Value: 1

	--------------------------------------
				--Akimbo CR 805B--
	--------------------------------------
	--ID: self.x_hajk
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 60
	--Ammo: 160
	--Fire Rate: 750
	--Damage: 100
	--Acc: 64
	--Stab: 100
	--Conc: 20
	--Threat: 20
	--Pickup: 4, 6
	--Notes:
	--Active Mods: Vintage Mag [wpn_fps_upg_m4_m_straight] [-20 Magazine, +5 Concealment] Value: 2
	--CAR Quadstacked Mag [wpn_fps_upg_m4_m_quad] [+60 Magazine, -20 Concealment] Value: 3
	--Vintage Mag [wpn_fps_upg_m4_m_straight] [-20 Magazine, +5 Concealment] Value: 2
	--Speedpull Mag [wpn_fps_m4_upg_m_quick] [+100% Reload Speed, -4 Concealment] Value: 2

	--------------------------------------
				--Akimbo Krinkov--
	--------------------------------------
	--ID: self.x_akmsu
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 60
	--Ammo: 160
	--Fire Rate: 822
	--Damage: 100
	--Acc: 64
	--Stab: 100
	--Conc: 20
	--Threat: 20
	--Pickup: 4, 6
	--Notes:
	--Active Mods: AK Quadstacked Mag [wpn_fps_upg_ak_m_quad] [+60 Magazine, -15 Concealment] Value: 3
	--Speedpull Mag [+100% Reload Speed, -4 Concealment]

	--------------------------------------
		--Primary/Akimbo Shotguns--
	--------------------------------------
	--------------------------------------
				--Joceline O/U--
	--------------------------------------
	--ID: self.b682
	--Class: Shotgun
	--Value: 1
	--Magazine: 2
	--Ammo: 34
	--Fire Rate: 500
	--Damage: 200
	--Acc: 40
	--Stab: 4
	--Conc: 25
	--Threat: 34
	--Pickup: 1, 2
	--Notes:
	--Active Mods: [wpn_fps_shot_b682_b_short] Sawed-Off Barrel [-20 Accuracy] Value: 1

	--------------------------------------
				--Mosconi 12G--
	--------------------------------------
	--ID: self.huntsman
	--Class: Shotgun
	--Value: 1
	--Magazine: 2
	--Ammo: 34
	--Fire Rate: 500
	--Damage: 200
	--Acc: 40
	--Stab: 4
	--Conc: 25
	--Threat: 34
	--Pickup: 1, 2
	--Notes:
	--Active Mods: Road Warrior Barrel [wpn_fps_shot_huntsman_b_short] [-20 Accuracy] Value: 10

	--------------------------------------
				--Breaker 12G--
	--------------------------------------
	--ID: self.boot
	--Class: Shotgun
	--Value: 1
	--Magazine: 7
	--Ammo: 28
	--Fire Rate: 80
	--Damage: 200
	--Acc: 40
	--Stab: 4
	--Conc: 20
	--Threat: 34
	--Pickup: 1, 2
	--Notes:
	--Active Mods:

	--------------------------------------
				--Akimbo Judge--
	--------------------------------------
	--ID: self.x_judge
	--Class: Shotgun
	--Value: 1
	--Magazine: 10
	--Ammo: 60
	--Fire Rate: 500
	--Damage: 180
	--Acc: 40
	--Stab: 0
	--Conc: 30
	--Threat: 10
	--Pickup: 0.5, 1
	--Notes:
	--Active Mods:

	--------------------------------------
				--Reinfeld 880--
	--------------------------------------
	--ID: self.r870
	--Class: Shotgun
	--Value: 1
	--Magazine: 8
	--Ammo: 50
	--Fire Rate: 104
	--Damage: 160
	--Acc: 40
	--Stab: 100
	--Conc: 20
	--Threat: 34
	--Pickup: 2, 3
	--Notes:
	--Active Mods:

	--------------------------------------
				--Raven--
	--------------------------------------
	--ID: self.ksg
	--Class: Shotgun
	--Value: 1
	--Magazine: 10
	--Ammo: 50
	--Fire Rate: 104
	--Damage: 160
	--Acc: 40
	--Stab: 100
	--Conc: 20
	--Threat: 34
	--Pickup: 2, 3
	--Notes:
	--Active Mods: Short Barrel [wpn_fps_sho_ksg_b_short] [-4 Magazine, +5 Concealment] Value: 5
	--Long Barrel [wpn_fps_sho_ksg_b_long] [+4 Magazine, -5 Concealment] Value: 7

	--------------------------------------
				--Predator 12G--
	--------------------------------------
	--ID: self.spas12
	--Class: Shotgun
	--Value: 1
	--Magazine: 8
	--Ammo: 70
	--Fire Rate: 300
	--Damage: 110
	--Acc: 40
	--Stab: 100
	--Conc: 25
	--Threat: 34
	--Pickup: 4, 5
	--Notes:
	--Active Mods: Extended Mag [wpn_fps_sho_b_spas12_long] [+4 Magazine, -5 Concealment] Value: 1

	--------------------------------------
				--M1014--
	--------------------------------------
	--ID: self.benelli
	--Class: Shotgun
	--Value: 1
	--Magazine: 8
	--Ammo: 70
	--Fire Rate: 429
	--Damage: 110
	--Acc: 40
	--Stab: 100
	--Conc: 25
	--Threat: 34
	--Pickup: 4, 5
	--Notes:
	--Active Mods: 

	--------------------------------------
				--Akimbo Goliath 12G--
	--------------------------------------
	--ID: self.x_rota
	--Class: Shotgun
	--Value: 1
	--Magazine: 12
	--Ammo: 72
	--Fire Rate: 333
	--Damage: 80
	--Acc: 40
	--Stab: 40
	--Conc: 25
	--Threat: 14
	--Pickup: 4, 5
	--Notes:
	--Active Mods: Silenced Barrel [wpn_fps_sho_rota_b_silencer] [Suppresses Weapon, +Quiet, -100 Threat] Value: 6
--IND
	--------------------------------------
				--Steakout 12G--
	--------------------------------------
	--ID: self.aa12
	--Class: Shotgun
	--Value: 1
	--Magazine: 8
	--Ammo: 80
	--Fire Rate: 300
	--Damage: 60
	--Acc: 40
	--Stab: 60
	--Conc: 20
	--Threat: 34
	--Pickup: 5, 6
	--Notes:
	--Active Mods: Suppressed Barrel [Suppresses Weapon, +Quiet, -100 Threat]
	--Drum Magazine [+12 Magazine, -20 Concealment]

	--------------------------------------
				--IZHMA 12G--
	--------------------------------------
	--ID: self.saiga
	--Class: Shotgun
	--Value: 1
	--Magazine: 7
	--Ammo: 60
	--Fire Rate: 333
	--Damage: 60
	--Acc: 40
	--Stab: 60
	--Conc: 25
	--Threat: 34
	--Pickup: 5, 6
	--Notes:
	--Active Mods: Big Brother Magazine [+3 Magazine, -5 Concealment]

	--------------------------------------
				--Brothers Grimm 12G--
	--------------------------------------
	--ID: self.x_basset
	--Class: Shotgun
	--Value: 1
	--Magazine: 14
	--Ammo: 96
	--Fire Rate: 333
	--Damage: 40
	--Acc: 40
	--Stab: 20
	--Conc: 25
	--Threat: 22
	--Pickup: 6, 7
	--Notes:
	--Active Mods: Big Brother Magazine [+6 Magazine, -10 Concealment]

	--------------------------------------
		--Marksman Rifles--
	--------------------------------------
	--------------------------------------
				--Little Friend 7.62--
	--------------------------------------
	--ID: self.contraband
	--Class: Precision
	--Value: 1
	--Magazine: 20
	--Ammo: 40
	--Fire Rate: 612
	--Damage: 160
	--Acc: 100
	--Stab: 40
	--Conc: 5
	--Threat: 31
	--Pickup: 2, 3
	--Notes: Armor Piercing
	--Active Mods: 

	--------------------------------------
				--Little Friend 7.62 (Grenade Launcher)--
	--------------------------------------
	--ID: self.contraband_m203
	--Class: Specialist
	--Value: 1
	--Magazine: 1
	--Ammo: 3
	--Fire Rate: 30
	--Damage: 1100
	--Acc: 100
	--Stab: 100
	--Conc: n/1
	--Threat: 43
	--Pickup: 0.1, 0.1
	--Notes: Area Damage
	--Active Mods:

	--------------------------------------
				--Cavity 9mm--
	--------------------------------------
	--ID: self.sub2000
	--Class: Precision
	--Value: 1
	--Magazine: 33
	--Ammo: 66
	--Fire Rate: 706
	--Damage: 160
	--Acc: 100
	--Stab: 12
	--Conc: 30
	--Threat: 10
	--Pickup: 3, 4
	--Notes: Armor Piercing
	--Active Mods: Tooth Fairy Suppressor [Suppresses Weapon, +Quiet, -100 Threat]

	--------------------------------------
				--M308--
	--------------------------------------
	--ID: self.new_m14
	--Class: Precision
	--Value: 1
	--Magazine: 10
	--Ammo: 80
	--Fire Rate: 706
	--Damage: 160
	--Acc: 100
	--Stab: 84
	--Conc: 10
	--Threat: 14
	--Pickup: 3, 4
	--Notes: Armor Piercing
	--Active Mods:

	--------------------------------------
				--Galant--
	--------------------------------------
	--ID: self.ching
	--Class: Precision
	--Value: 1
	--Magazine: 8
	--Ammo: 72
	--Fire Rate: 600
	--Damage: 160
	--Acc: 100
	--Stab: 52
	--Conc: 20
	--Threat: 22
	--Pickup: 3, 4
	--Notes: Armor Piercing
	--Active Mods: Magpouch Stock [+16 Ammo Stock, -5 Concealment]

	--------------------------------------
		--Primary Sniper Rifles--
	--------------------------------------
	--------------------------------------
			--Sniper Rifles--
	--------------------------------------
	--------------------------------------
				--Contractor .308--
	--------------------------------------
	--ID: self.tti
	--Class: Precision
	--Value: 9
	--Magazine: 20
	--Ammo: 60
	--Fire Rate: 150
	--Damage: 190
	--Acc: 100
	--Stab: 28
	--Conc: 20
	--Threat: 43
	--Pickup: 2.5, 3
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: Contractor Silencer [Suppresses Weapon, +Quiet, -100 Threat]

	--------------------------------------
				--Lebensauger .308--
	--------------------------------------
	--ID: self.wa2000
	--Class: Precision
	--Value: 9
	--Magazine: 10
	--Ammo: 60
	--Fire Rate: 150
	--Damage: 190
	--Acc: 100
	--Stab: 28
	--Conc: 15
	--Threat: 43
	--Pickup: 2.5, 3
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: Gedampfter Barrel [Suppresses Weapon, +Quiet, -100 Threat]

	--------------------------------------
				--Grom--
	--------------------------------------
	--ID: self.siltstone
	--Class: Precision
	--Value: 9
	--Magazine: 10
	--Ammo: 60
	--Fire Rate: 150
	--Damage: 190
	--Acc: 100
	--Stab: 20
	--Conc: 15
	--Threat: 43
	--Pickup: 2.5, 3
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: Tikho Barrel [Suppresses Weapon, +Quiet, -100 Threat]
	--Iron Sights [+15 Concealment, -20 Stability]

	--------------------------------------
			--Medium Sniper Rifles--
	--------------------------------------
	--------------------------------------
				--Rattlesnake--
	--------------------------------------
	--ID: self.msr
	--Class: Precision
	--Value: 9
	--Magazine: 10
	--Ammo: 60
	--Fire Rate: 60
	--Damage: 250
	--Acc: 100
	--Stab: 20
	--Conc: 10
	--Threat: 43
	--Pickup: 2, 2.5
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: Sniper Suppressor [Suppresses Weapon, +Quiet, -100 Threat]

	--------------------------------------
				--Repeater 1874--
	--------------------------------------
	--ID: self.winchester1874
	--Class: Precision
	--Value: 9
	--Magazine: 15
	--Ammo: 75
	--Fire Rate: 86
	--Damage: 250
	--Acc: 100
	--Stab: 60
	--Conc: 20
	--Threat: 14
	--Pickup: 3, 4
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: Outlaw’s Silenced Barrel [Suppresses Weapon, +Quiet, -100 Threat]

	--------------------------------------
			--Heavy Sniper Rifles--
	--------------------------------------
	--------------------------------------
				--Platypus 70--
	--------------------------------------
	--ID: self.model70
	--Class: Precision
	--Value: 9
	--Magazine: 5
	--Ammo: 30
	--Fire Rate: 60
	--Damage: 480
	--Acc: 100
	--Stab: 48
	--Conc: 10
	--Threat: 43
	--Pickup: 1.5, 2.5
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: Beak Suppressor [Suppresses Weapon, +Quiet, -100 Threat]

	--------------------------------------
				--R93--
	--------------------------------------
	--ID: self.r93
	--Class: Precision
	--Value: 9
	--Magazine: 6
	--Ammo: 30
	--Fire Rate: 50
	--Damage: 480
	--Acc: 100
	--Stab: 48
	--Conc: 10
	--Threat: 43
	--Pickup: 1.5, 2.5
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: Compensated Suppressor [Suppresses Weapon, +Quiet, -100 Threat]

	--------------------------------------
				--Nagant--
	--------------------------------------
	--ID: self.mosin
	--Class: Precision
	--Value: 9
	--Magazine: 5
	--Ammo: 30
	--Fire Rate: 60
	--Damage: 480
	--Acc: 100
	--Stab: 20
	--Conc: 15
	--Threat: 43
	--Pickup: 1.5, 2.5
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: Silenced Barrel [Suppresses Weapon, +Quiet, -100 Threat]
	--Nagant Bayonet [Replaces Weapon Butt melee weapon with Nagant Bayonet melee weapon]

	--------------------------------------
				--Desertfox--
	--------------------------------------
	--ID: self.desertfox
	--Class: Precision
	--Value: 10
	--Magazine: 5
	--Ammo: 30
	--Fire Rate: 60
	--Damage: 480
	--Acc: 100
	--Stab: 12
	--Conc: 25
	--Threat: 43
	--Pickup: 1.5, 2.5
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: Silenced Barrel [Suppresses Weapon, +Quiet, -100 Threat]

	--------------------------------------
				--Thanatos .50 cal--
	--------------------------------------
	--ID: self.m95
	--Class: Heavy
	--Value: 9
	--Magazine: 5
	--Ammo: 20
	--Fire Rate: 40
	--Damage: 3500
	--Acc: 100
	--Stab: 0
	--Conc: 0
	--Threat: 43
	--Pickup: 0.25, 0.5
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: Suppressed Barrel [Suppresses Weapon, +Quiet, -100 Threat]

	--------------------------------------
		--Akimbo Pistols--
	--------------------------------------
	--------------------------------------
			--Akimbo Light Pistols--
	--------------------------------------
	--------------------------------------
				--Akimbo Gruber Kurz--
	--------------------------------------
	--ID: self.x_ppk
	--Class: Precision
	--Value: 1
	--Magazine: 28
	--Ammo: 168
	--Fire Rate: 480
	--Damage: 20
	--Acc: 100
	--Stab: 100
	--Conc: 35
	--Threat: 0
	--Pickup: 4, 8
	--Notes: 
	--Active Mods: 

	--------------------------------------
				--Akimbo Chimano 88--
	--------------------------------------
	--ID: self.x_g17
	--Class: Precision
	--Value: 1
	--Magazine: 34
	--Ammo: 300
	--Fire Rate: 480
	--Damage: 50
	--Acc: 84
	--Stab: 48
	--Conc: 30
	--Threat: 8
	--Pickup: 3, 6
	--Notes: 
	--Active Mods: Extended Magazine [+24 Magazine, -5 Concealment]

	--------------------------------------
				--Akimbo M13 9mm--
	--------------------------------------
	--ID: self.x_legacy
	--Class: Precision
	--Value: 4
	--Magazine: 26
	--Ammo: 300
	--Fire Rate: 545
	--Damage: 50
	--Acc: 84
	--Stab: 48
	--Conc: 30
	--Threat: 8
	--Pickup: 3, 6
	--Notes: 
	--Active Mods: 

	--------------------------------------
				--Akimbo Chimano Compact--
	--------------------------------------
	--ID: self.jowi
	--Class: Precision
	--Value: 1
	--Magazine: 20
	--Ammo: 300
	--Fire Rate: 667
	--Damage: 50
	--Acc: 84
	--Stab: 48
	--Conc: 30
	--Threat: 8
	--Pickup: 3, 6
	--Notes: 
	--Active Mods: Extended Mag.[+24 Magazine, -5 Concealment]
	--------------------------------------
				--Akimbo Crosskill Guard--
	--------------------------------------
	--ID: self.x_shrew
	--Class: Precision
	--Value: 1
	--Magazine: 34
	--Ammo: 300
	--Fire Rate: 667
	--Damage: 50
	--Acc: 84
	--Stab: 48
	--Conc: 30
	--Threat: 8
	--Pickup: 3, 6
	--Notes: 
	--Active Mods: Extended Mag [+8 Magazine, -2 Concealment]

	--------------------------------------
				--Akimbo Bernetti 9--
	--------------------------------------
	--ID: self.x_b92fs
	--Class: Precision
	--Value: 1
	--Magazine: 28
	--Ammo: 300
	--Fire Rate: 667
	--Damage: 50
	--Acc: 84
	--Stab: 48
	--Conc: 30
	--Threat: 8
	--Pickup: 3, 6
	--Notes: 
	--Active Mods: Extended Mag. [+24 Magazine, -5 Concealment]

	--------------------------------------
			--Akimbo Medium Pistols--
	--------------------------------------
	--------------------------------------
				--Akimbo Crosskill--
	--------------------------------------
	--ID: self.x_1911
	--Class: Precision
	--Value: 1
	--Magazine: 20
	--Ammo: 180
	--Fire Rate: 361
	--Damage: 80
	--Acc: 92
	--Stab: 48
	--Conc: 30
	--Threat: 11
	--Pickup: 2, 5
	--Notes: 
	--Active Mods: 12rnd Mag. [+4 Magazine, -2 Concealment]
	--Magazine with Ameritude! [+24 Magazine, -5 Concealment]

	--------------------------------------
				--Akimbo Contractor--
	--------------------------------------
	--ID: self.x_packrat
	--Class: Precision
	--Value: 4
	--Magazine: 30
	--Ammo: 180
	--Fire Rate: 361
	--Damage: 80
	--Acc: 92
	--Stab: 48
	--Conc: 30
	--Threat: 11
	--Pickup: 2, 5
	--Notes: 
	--Active Mods: Extended Magazine[+20 Magazine, -5 Concealment]
	--------------------------------------
				--Akimbo Signature .40--
	--------------------------------------
	--ID: self.x_p226
	--Class: Precision
	--Value: 4
	--Magazine: 24
	--Ammo: 180
	--Fire Rate: 361
	--Damage: 80
	--Acc: 92
	--Stab: 48
	--Conc: 30
	--Threat: 11
	--Pickup: 2, 5
	--Notes: 
	--Active Mods: Extended Mag. [+16 Magazine, -5 Concealment]

	--------------------------------------
				--Akimbo Broomstick--
	--------------------------------------
	--ID: self.x_c96
	--Class: Precision
	--Value: 1
	--Magazine: 20
	--Ammo: 180
	--Fire Rate: 361
	--Damage: 80
	--Acc: 92
	--Stab: 48
	--Conc: 30
	--Threat: 11
	--Pickup: 2, 5
	--Notes: 
	--Active Mods: High Capacity Mag [+20 Magazine, -5 Concealment]
	--Precision Barrel [+Armor Piercing, -45 Ammo Stock, +30 Damage, -12 Stability,
	---5 Concealment, -0.5, -2 Pickup]

	--------------------------------------
				--Akimbo Interceptor 45--
	--------------------------------------
	--ID: self.x_usp
	--Class: Precision
	--Value: 1
	--Magazine: 26
	--Ammo: 180
	--Fire Rate: 361
	--Damage: 80
	--Acc: 92
	--Stab: 48
	--Conc: 30
	--Threat: 11
	--Pickup: 2, 5
	--Notes: 
	--Active Mods: Extended Mag.[+16 Magazine, -4 Concealment]
	--I want more Magazine! [+24 Magazine, -8 Concealment]

	--------------------------------------
				--Akimbo LEO--
	--------------------------------------
	--ID: self.x_hs2000
	--Class: Precision
	--Value: 4
	--Magazine: 38
	--Ammo: 180
	--Fire Rate: 361
	--Damage: 80
	--Acc: 92
	--Stab: 48
	--Conc: 30
	--Threat: 11
	--Pickup: 2, 5
	--Notes: 
	--Active Mods: Extended Mag [+16 Magazine, -5 Concealment]

	--------------------------------------
				--Akimbo Chimano Custom--
	--------------------------------------
	--ID: self.x_g22c
	--Class: Precision
	--Value: 1
	--Magazine: 32
	--Ammo: 180
	--Fire Rate: 361
	--Damage: 80
	--Acc: 92
	--Stab: 48
	--Conc: 30
	--Threat: 11
	--Pickup: 2, 5
	--Notes: 
	--Active Mods: Extended Mag. [+24 Magazine, -5 Concealment]

	--------------------------------------
			--Akimbo Heavy Pistols--
	--------------------------------------
	--------------------------------------
				--Akimbo Deagle--
	--------------------------------------
	--ID: self.x_deagle
	--Class: Precision
	--Value: 1
	--Magazine: 20
	--Ammo: 90
	--Fire Rate: 240
	--Damage: 110
	--Acc: 96
	--Stab: 20
	--Conc: 30
	--Threat: 9
	--Pickup: 1.5, 3
	--Notes: Armor Piercing
	--Active Mods: Extended Magazine [+12 Magazine, -5 Concealment]

	--------------------------------------
				--Akimbo Parabellum--
	--------------------------------------
	--ID: self.x_breech
	--Class: Precision
	--Value: 4
	--Magazine: 16
	--Ammo: 90
	--Fire Rate: 361
	--Damage: 110
	--Acc: 96
	--Stab: 20
	--Conc: 30
	--Threat: 9
	--Pickup: 1.5, 3
	--Notes: Armor Piercing
	--Active Mods: 

	--------------------------------------
				--Akimbo Baby Deagle--
	--------------------------------------
	--ID: self.x_sparrow
	--Class: Precision
	--Value: 4
	--Magazine: 24
	--Ammo: 90
	--Fire Rate: 361
	--Damage: 110
	--Acc: 96
	--Stab: 20
	--Conc: 30
	--Threat: 9
	--Pickup: 1.5, 3
	--Notes: Armor Piercing
	--Active Mods: 

	--------------------------------------
				--Akimbo White Streak--
	--------------------------------------
	--ID: self.x_pl14
	--Class: Precision
	--Value: 4
	--Magazine: 24
	--Ammo: 90
	--Fire Rate: 361
	--Damage: 110
	--Acc: 96
	--Stab: 20
	--Conc: 30
	--Threat: 9
	--Pickup: 1.5, 3
	--Notes: Armor Piercing
	--Active Mods: Extended Magazine [+4 Magazine, -1 Concealment]

	--------------------------------------
			--Akimbo Revolvers--
	--------------------------------------
	--------------------------------------
				--Akimbo Matever .357--
	--------------------------------------
	--ID: self.x_2006m
	--Class: Precision
	--Value: 1
	--Magazine: 12
	--Ammo: 90
	--Fire Rate: 361
	--Damage: 160
	--Acc: 100
	--Stab: 0
	--Conc: 30
	--Threat: 9
	--Pickup: 1, 2
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: 

	--------------------------------------
				--Akimbo Bronco .44--
	--------------------------------------
	--ID: self.x_rage
	--Class: Precision
	--Value: 1
	--Magazine: 12
	--Ammo: 90
	--Fire Rate: 361
	--Damage: 160
	--Acc: 100
	--Stab: 0
	--Conc: 30
	--Threat: 9
	--Pickup: 1, 2
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: 

	--------------------------------------
				--Akimbo Castigo .44--
	--------------------------------------
	--ID: self.x_chinchilla
	--Class: Precision
	--Value: 1
	--Magazine: 12
	--Ammo: 90
	--Fire Rate: 361
	--Damage: 160
	--Acc: 100
	--Stab: 0
	--Conc: 30
	--Threat: 9
	--Pickup: 1, 2
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: 

	--------------------------------------
		--Machine Guns--
	--------------------------------------
	--------------------------------------
				--RPK--
	--------------------------------------
	--ID: self.rpk
	--Class: Heavy
	--Value: 9
	--Magazine: 75
	--Ammo: 160
	--Fire Rate: 750
	--Damage: 120
	--Acc: 76
	--Stab: 88
	--Conc: 0
	--Threat: 43
	--Pickup: 0.5, 0.6
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: 

	--------------------------------------
				--Brenner-21--
	--------------------------------------
	--ID: self.hk21
	--Class: Heavy
	--Value: 9
	--Magazine: 80
	--Ammo: 120
	--Fire Rate: 732
	--Damage: 150
	--Acc: 60
	--Stab: 68
	--Conc: 0
	--Threat: 43
	--Pickup: 0.4, 0.5
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: 

	--------------------------------------
				--KSP 58--
	--------------------------------------
	--ID: self.par
	--Class: Heavy
	--Value: 9
	--Magazine: 50
	--Ammo: 120
	--Fire Rate: 909
	--Damage: 150
	--Acc: 68
	--Stab: 76
	--Conc: 0
	--Threat: 43
	--Pickup: 0.4, 0.5
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: 

	--------------------------------------
				--KSP unnumbered--
	--------------------------------------
	--ID: self.m249
	--Class: Heavy
	--Value: 9
	--Magazine: 100
	--Ammo: 160
	--Fire Rate: 909
	--Damage: 120
	--Acc: 88
	--Stab: 92
	--Conc: 0
	--Threat: 43
	--Pickup: 0.5, 0.6
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: 

	--------------------------------------
				--Buzzsaw 42--
	--------------------------------------
	--ID: self.mg42
	--Class: Heavy
	--Value: 9
	--Magazine: 50
	--Ammo: 120
	--Fire Rate: 1200
	--Damage: 150
	--Acc: 72
	--Stab: 88
	--Conc: 0
	--Threat: 43
	--Pickup: 0.4, 0.5
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: 

	--------------------------------------
		--Primary Special Weapons--
	--------------------------------------
	--------------------------------------
				--XL 5.56 Microgun--
	--------------------------------------
	--ID: self.shuno
	--Class: Heavy
	--Value: 9
	--Magazine: 600
	--Ammo: 200
	--Fire Rate: 2000
	--Damage: 100
	--Acc: 36
	--Stab: 88
	--Conc: 0
	--Threat: 43
	--Pickup: 0, 0
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: 

	--------------------------------------
				--Vulcan Minigun--
	--------------------------------------
	--ID: self.m134
	--Class: Heavy
	--Value: 9
	--Magazine: 600
	--Ammo: 200
	--Fire Rate: 3000
	--Damage: 100
	--Acc: 48
	--Stab: 68
	--Conc: 0
	--Threat: 43
	--Pickup: 0, 0
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: I’ll Take Half That Kit [-1500 Fire Rate] --NOTE may be pure benefit? ask

	--------------------------------------
				--Airbow--
	--------------------------------------
	--ID: self.ecp
	--Class: Precision, Quiet
	--Value: 1
	--Magazine: 6
	--Ammo: 30
	--Fire Rate: 120
	--Damage: 700
	--Acc: 100
	--Stab: 100
	--Conc: 20
	--Threat: 0
	--Pickup: 0, 0
	--Notes: Armor Piercing
	--Active Mods: Explosive Arrow [-Armor Piercing, 2x Headshot Damage]
	--Poison Arrow [-560 Damage, + Poison]

	--------------------------------------
				--Light Crossbow--
	--------------------------------------
	--ID: self.frankish
	--Class: Precision, Quiet
	--Value: 1
	--Magazine: 1
	--Ammo: 50
	--Fire Rate: 40
	--Damage: 750
	--Acc: 100
	--Stab: 100
	--Conc: 30
	--Threat: 0
	--Pickup: 0, 0
	--Notes: Armor Piercing
	--Active Mods: Explosive Bolt [-Armor Piercing, 2x Headshot Damage]
	--Poison Bolt [-600 Damage, + Poison]

	--------------------------------------
				--Plainsrider Bow--
	--------------------------------------
	--ID: self.plainsrider
	--Class: Precision, Quiet
	--Value: 1
	--Magazine: 1
	--Ammo: 60
	--Fire Rate: 300
	--Damage: 1000
	--Acc: 100
	--Stab: 100
	--Conc: 30
	--Threat: 0
	--Pickup: 0, 0
	--Notes: Armor Piercing
	--Active Mods: Explosive Arrows [-Armor Piercing, 2x Headshot Damage]
	--Poison Arrows [-200 Damage, + Poison]

	--------------------------------------
				--DECA Technologies Compound Bow--
	--------------------------------------
	--ID: self.elastic
	--Class: Precision, Quiet
	--Value: 1
	--Magazine: 1
	--Ammo: 40
	--Fire Rate: 300
	--Damage: 2000
	--Acc: 100
	--Stab: 100
	--Conc: 30
	--Threat: 0
	--Pickup: 0, 0
	--Notes: Armor Piercing
	--Active Mods: Explosive Arrow [-Armor Piercing, 2x Headshot Damage]
	--Poison Arrow [-1600 Damage, + Poison]

	--------------------------------------
				--English Longbow--
	--------------------------------------
	--ID: self.long
	--Class: Precision, Quiet
	--Value: 1
	--Magazine: 1
	--Ammo: 40
	--Fire Rate: 300
	--Damage: 2000
	--Acc: 100
	--Stab: 100
	--Conc: 30
	--Threat: 0
	--Pickup: 0, 0
	--Notes: Armor Piercing
	--Active Mods: Explosive Arrows [-Armor Piercing, 2x Headshot Damage]
	--Poison Arrows [-1600 Damage, + Poison]

	--------------------------------------
				--Heavy Crossbow--
	--------------------------------------
	--ID: self.arblast
	--Class: Precision, Quiet
	--Value: 1
	--Magazine: 1
	--Ammo: 40
	--Fire Rate: 21
	--Damage: 2000
	--Acc: 100
	--Stab: 100
	--Conc: 30
	--Threat: 0
	--Pickup: 0, 0
	--Notes: Armor Piercing
	--Active Mods: Explosive Bolt [-Armor Piercing, 2x Headshot Damage]
	--Poisoned Bolt [-1600 Damage, + Poison]

	--------------------------------------
				--GL 40 Grenade Launcher--
	--------------------------------------
	--ID: self.gre_m79
	--Class: Specialist
	--Value: 1
	--Magazine: 1
	--Ammo: 6
	--Fire Rate: 30
	--Damage: 1100
	--Acc: 100
	--Stab: 100
	--Conc: 25
	--Threat: 43
	--Pickup: 0.1, 0.2
	--Notes: Area Damage
	--Active Mods: Incendiary Round [-1000 Damage, + Area Denial in a large area for 15 seconds.]

	--------------------------------------
				--Piglet Grenade Launcher--
	--------------------------------------
	--ID: self.m32
	--Class: Specialist
	--Value: 1
	--Magazine: 6
	--Ammo: 12
	--Fire Rate: 60
	--Damage: 1100
	--Acc: 100
	--Stab: 100
	--Conc: 0
	--Threat: 43
	--Pickup: 0.1, 0.2
	--Notes: Area Damage
	--Active Mods: Incendiary Round [-1000 Damage, + Area Denial in a large area for 15 seconds.]

	--------------------------------------
				--Flamethrower Mk.1--
	--------------------------------------
	--ID: self.flamethrower_mk2
	--Class: Specialist
	--Value: 1
	--Magazine: 900
	--Ammo: 900
	--Fire Rate: 2000
	--Damage: 100
	--Acc: 0
	--Stab: 100
	--Conc: 10
	--Threat: 43
	--Pickup: 1, 1
	--Notes:  Igniting, Armor Piercing, Body Piercing, Shield Piercing, Improv Expert Aced
	--NOTE: The Flamethrower Mk.1 does not have an active Ammo Pickup without Improv Expert Aced.
	--Active Mods: 

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
	--ID: self.ppk
	--Class: Precision
	--Value: 1
	--Magazine: 14
	--Ammo: 168
	--Fire Rate: 480
	--Damage: 20
	--Acc: 100
	--Stab: 100
	--Conc: 35
	--Threat: 0
	--Pickup: 4, 5
	--Notes: 
	--Active Mods:

	--------------------------------------
				--Chimano 88--
	--------------------------------------
	--ID: self.glock_17
	--Class: Precision
	--Value: 1
	--Magazine: 17
	--Ammo: 180
	--Fire Rate: 480
	--Damage: 50
	--Acc: 100
	--Stab: 56
	--Conc: 30
	--Threat: 4
	--Pickup: 3, 6
	--Notes: 
	--Active Mods: Extended Magazine [+12 Magazine, -3 Concealment]

	--------------------------------------
				--M13 9mm--
	--------------------------------------
	--ID: self.legacy
	--Class: Precision
	--Value: 4
	--Magazine: 13
	--Ammo: 180
	--Fire Rate: 545
	--Damage: 50
	--Acc: 100
	--Stab: 48
	--Conc: 30
	--Threat: 8
	--Pickup: 3, 6
	--Notes: 
	--Active Mods: 

	--------------------------------------
				--Chimano Compact--
	--------------------------------------
	--ID: self.g26
	--Class: Precision
	--Value: 1
	--Magazine: 10
	--Ammo: 180
	--Fire Rate: 480
	--Damage: 50
	--Acc: 100
	--Stab: 48
	--Conc: 30
	--Threat: 8
	--Pickup: 3, 6
	--Notes: 
	--Active Mods: Extended Mag. [+12 Magazine, -3 Concealment]

	--------------------------------------
				--Crosskill Guard--
	--------------------------------------
	--ID: self.shrew
	--Class: Precision
	--Value: 1
	--Magazine: 17
	--Ammo: 180
	--Fire Rate: 480
	--Damage: 50
	--Acc: 100
	--Stab: 48
	--Conc: 30
	--Threat: 8
	--Pickup: 3, 6
	--Notes: 
	--Active Mods: Extended Mag [+4 Magazine, -1 Concealment]

	--------------------------------------
				--Bernetti 9--
	--------------------------------------
	--ID: self.b92fs
	--Class: Precision
	--Value: 1
	--Magazine: 28
	--Ammo: 180
	--Fire Rate: 480
	--Damage: 50
	--Acc: 100
	--Stab: 48
	--Conc: 30
	--Threat: 8
	--Pickup: 3, 6
	--Notes: 
	--Active Mods: Extended Mag. [+12 Magazine, -3 Concealment]

	--------------------------------------
			--Medium Pistols--
	--------------------------------------
	--------------------------------------
				--Crosskill--
	--------------------------------------
	--ID: self.colt_1911
	--Class: Precision
	--Value: 1
	--Magazine: 10
	--Ammo: 90
	--Fire Rate: 361
	--Damage: 80
	--Acc: 100
	--Stab: 56
	--Conc: 30
	--Threat: 11
	--Pickup: 2, 5
	--Notes: 
	--Active Mods: 12rnd Mag. [+2 Magazine, -1 Concealment]
	--Magazine with Ameritude! [+12 Magazine, -3 Concealment]

	--------------------------------------
				--Contractor--
	--------------------------------------
	--ID: self.packrat
	--Class: Precision
	--Value: 4
	--Magazine: 15
	--Ammo: 90
	--Fire Rate: 361
	--Damage: 80
	--Acc: 100
	--Stab: 48
	--Conc: 30
	--Threat: 11
	--Pickup: 2, 5
	--Notes: 
	--Active Mods: Extended Magazine [+10 Magazine, -1 Concealment]

	--------------------------------------
				--Signature .40--
	--------------------------------------
	--ID: self.p226
	--Class: Precision
	--Value: 4
	--Magazine: 12
	--Ammo: 90
	--Fire Rate: 361
	--Damage: 80
	--Acc: 100
	--Stab: 48
	--Conc: 30
	--Threat: 11
	--Pickup: 2, 5
	--Notes: 
	--Active Mods: Extended Mag. [+8 Magazine, -2 Concealment]

	--------------------------------------
				--Broomstick--
	--------------------------------------
	--ID: self.c96
	--Class: Precision
	--Value: 1
	--Magazine: 20
	--Ammo: 90
	--Fire Rate: 361
	--Damage: 80
	--Acc: 100
	--Stab: 60
	--Conc: 30
	--Threat: 11
	--Pickup: 2, 5
	--Notes: 
	--Active Mods: High Capacity Mag [+10 Magazine, -2 Concealment]
	--Precision Barrel [+Armor Piercing, -30 Ammo Stock. +30 Damage,
	--+32 Stability, 5 Concealment, -0.5, -2 Pickup]

	--------------------------------------
				--Interceptor 45--
	--------------------------------------
	--ID: self.usp
	--Class: Precision
	--Value: 1
	--Magazine: 13
	--Ammo: 90
	--Fire Rate: 361
	--Damage: 80
	--Acc: 100
	--Stab: 48
	--Conc: 30
	--Threat: 11
	--Pickup: 2, 5
	--Notes: 
	--Active Mods: Extended Mag. [+18 Magazine, -2 Concealment]
	--I want more Magazine! [+12 Magazine, -4 Concealment]

	--------------------------------------
				--LEO--
	--------------------------------------
	--ID: self.hs2000
	--Class: Precision
	--Value: 4
	--Magazine: 38
	--Ammo: 90
	--Fire Rate: 361
	--Damage: 80
	--Acc: 100
	--Stab: 48
	--Conc: 30
	--Threat: 11
	--Pickup: 2, 5
	--Notes: 
	--Active Mods: Extended Mag [+16 Magazine, -5 Concealment]

	--------------------------------------
				--Chimano Custom--
	--------------------------------------
	--ID: self.g22c
	--Class: Precision
	--Value: 1
	--Magazine: 16
	--Ammo: 90
	--Fire Rate: 361
	--Damage: 80
	--Acc: 100
	--Stab: 48
	--Conc: 30
	--Threat: 11
	--Pickup: 2, 5
	--Notes: 
	--Active Mods: Extended Mag. [+12 Magazine, -2 Concealment]

	--------------------------------------
			--Heavy Pistols--
	--------------------------------------
	--------------------------------------
				--5/7 AP--
	--------------------------------------
	--ID: self.lemming
	--Class: Precision
	--Value: 4
	--Magazine: 20
	--Ammo: 45
	--Fire Rate: 600
	--Damage: 110
	--Acc: 100
	--Stab: 36
	--Conc: 25
	--Threat: 9
	--Pickup: 0.5, 0.75
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: Extended Magazine [+10 Magazine, -5 Concealment]

	--------------------------------------
				--Deagle--
	--------------------------------------
	--ID: self.deagle
	--Class: Precision
	--Value: 1
	--Magazine: 10
	--Ammo: 60
	--Fire Rate: 240
	--Damage: 110
	--Acc: 100
	--Stab: 20
	--Conc: 25
	--Threat: 9
	--Pickup: 1.5, 3
	--Notes: Armor Piercing
	--Active Mods: Extended Magazine [+6 Magazine, -2 Concealment]

	--------------------------------------
				--Parabellum--
	--------------------------------------
	--ID: self.breech
	--Class: Precision
	--Value: 4
	--Magazine: 8
	--Ammo: 60
	--Fire Rate: 361
	--Damage: 110
	--Acc: 100
	--Stab: 24
	--Conc: 25
	--Threat: 9
	--Pickup: 1.5, 3
	--Notes: Armor Piercing
	--Active Mods:

	--------------------------------------
				--Baby Deagle--
	--------------------------------------
	--ID: self.sparrow
	--Class: Precision
	--Value: 4
	--Magazine: 12
	--Ammo: 60
	--Fire Rate: 240
	--Damage: 110
	--Acc: 100
	--Stab: 24
	--Conc: 25
	--Threat: 9
	--Pickup: 1.5, 3
	--Notes: Armor Piercing
	--Active Mods:

	--------------------------------------
				--White Streak--
	--------------------------------------
	--ID: self.pl14
	--Class: Precision
	--Value: 4
	--Magazine: 12
	--Ammo: 60
	--Fire Rate: 240
	--Damage: 110
	--Acc: 100
	--Stab: 28
	--Conc: 25
	--Threat: 9
	--Pickup: 1.5, 3
	--Notes: Armor Piercing
	--Active Mods: Extended Magazine [+2 Magazine, -1 Concealment]

	--------------------------------------
			--Revolvers--
	--------------------------------------
	--------------------------------------
				--Matever .357--
	--------------------------------------
	--ID: self.mateba
	--Class: Precision
	--Value: 1
	--Magazine: 6
	--Ammo: 60
	--Fire Rate: 361
	--Damage: 160
	--Acc: 100
	--Stab: 12
	--Conc: 25
	--Threat: 24
	--Pickup: 1, 2
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: 

	--------------------------------------
				--Bronco .44--
	--------------------------------------
	--ID: self.new_raging_bull
	--Class: Precision
	--Value: 1
	--Magazine: 6
	--Ammo: 60
	--Fire Rate: 361
	--Damage: 160
	--Acc: 100
	--Stab: 24
	--Conc: 25
	--Threat: 24
	--Pickup: 1, 2
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: 

	--------------------------------------
				--Castigo .44--
	--------------------------------------
	--ID: self.chinchilla
	--Class: Precision
	--Value: 1
	--Magazine: 6
	--Ammo: 60
	--Fire Rate: 361
	--Damage: 160
	--Acc: 100
	--Stab: 12
	--Conc: 25
	--Threat: 24
	--Pickup: 1, 2
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: 

	--------------------------------------
				--Peacemaker .45--
	--------------------------------------
	--ID: self.peacemaker
	-- https://www.youtube.com/watch?v=ufH4eZ7sF_I
	--Class: Heavy --NOTE not error, no akimbo peacemaker.
	--Value: 1
	--Magazine: 6
	--Ammo: 30
	--Fire Rate: 240
	--Damage: 360
	--Acc: 100
	--Stab: 0
	--Conc: 15
	--Threat: 43
	--Pickup: 1, 2
	--Notes: Armor Piercing, Body Piercing, Shield Piercing
	--Active Mods: 

	--------------------------------------
		--Machine Pistols--
	--------------------------------------
	--------------------------------------
				--Igor Automatik--
	--------------------------------------
	--ID: self.stech
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 20
	--Ammo: 160
	--Fire Rate: 750
	--Damage: 60
	--Acc: 80
	--Stab: 44
	--Conc: 32
	--Threat: 8
	--Pickup: 7, 11
	--Notes: 
	--Active Mods: Extended Mag. [+14 Magazine, -2 Concealment]

	--------------------------------------
				--STRYK 18c--
	--------------------------------------
	--ID: self.glock_18c
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 20
	--Ammo: 240
	--Fire Rate: 909
	--Damage: 40
	--Acc: 68
	--Stab: 88
	--Conc: 32
	--Threat: 8
	--Pickup: 9, 18
	--Notes: 
	--Active Mods: Extended Mag. [+12 Magazine, -2 Concealment]

	--------------------------------------
				--Czech 92--
	--------------------------------------
	--ID: self.czech
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 15
	--Ammo: 300
	--Fire Rate: 1000
	--Damage: 40
	--Acc: 80
	--Stab: 40
	--Conc: 32
	--Threat: 8
	--Pickup: 9, 18
	--Notes: 
	--Active Mods: Extended Magazine [+10 Magazine, -2 Concealment]

	--------------------------------------
				--Bernetti Auto--
	--------------------------------------
	--ID: self.beer
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 15
	--Ammo: 300
	--Fire Rate: 1101
	--Damage: 40
	--Acc: 84
	--Stab: 80
	--Conc: 32
	--Threat: 8
	--Pickup: 9, 18
	--Notes: 
	--Active Mods: Extended Magazine [+6 Magazine, -2 Concealment]

	--------------------------------------
		--SMGs--
	--------------------------------------
	--------------------------------------
			--Light SMGs--
	--------------------------------------
	--------------------------------------
				--Tatonka--
	--------------------------------------
	--ID: self.coal
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 64
	--Ammo: 200
	--Fire Rate: 652
	--Damage: 50
	--Acc: 80
	--Stab: 100
	--Conc: 28
	--Threat: 10
	--Pickup: 8, 16
	--Notes: Formerly a Heavy SMG
	--Active Mods: 

	--------------------------------------
				--Uzi SMG--
	--------------------------------------
	--ID: self.uzi
	--Class: Rapid Fire
	--Value: 7
	--Magazine: 32
	--Ammo: 200
	--Fire Rate: 698
	--Damage: 50
	--Acc: 68
	--Stab: 100
	--Conc: 20
	--Threat: 13
	--Pickup: 8, 16
	--Notes: 
	--Active Mods: 

	--------------------------------------
				--Signature SMG--
	--------------------------------------
	--ID: self.shepheard
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 20
	--Ammo: 200
	--Fire Rate: 750
	--Damage: 50
	--Acc: 64
	--Stab: 100
	--Conc: 25
	--Threat: 13
	--Pickup: 8, 16
	--Notes: 
	--Active Mods: Extended Magazine [wpn_fps_smg_shepheard_mag_extended]  [+10 Magazine, -2 Concealment] Value: 1

	--------------------------------------
				--Compact-5--
	--------------------------------------
	--ID: self.new_mp5
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 30
	--Ammo: 210
	--Fire Rate: 750
	--Damage: 50
	--Acc: 64
	--Stab: 100
	--Conc: 25
	--Threat: 10
	--Pickup: 8, 16
	--Notes: 
	--Active Mods:

	--------------------------------------
				--Blaster 9mm--
	--------------------------------------
	--ID: self.tec9
	--Class: Rapid Fire
	--Value: 7
	--Magazine: 20
	--Ammo: 220
	--Fire Rate: 896
	--Damage: 50
	--Acc: 52
	--Stab: 100
	--Conc: 30
	--Threat: 10
	--Pickup: 8, 16
	--Notes: 
	--Active Mods: Extended Mag [wpn_fps_smg_tec9_m_extended] [+12 Magazine, -2 Concealment] Value: 4

	--------------------------------------
				--CMP--
	--------------------------------------
	--ID: self.mp9
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 15
	--Ammo: 240
	--Fire Rate: 952
	--Damage: 50
	--Acc: 68
	--Stab: 100
	--Conc: 30
	--Threat: 10
	--Pickup: 8, 16
	--Notes: 
	--Active Mods: Extended Mag. [wpn_fps_smg_mp9_m_extended] [+15 Magazine, -2 Concealment] Value: 4
	--Tactical Suppressor [wpn_fps_smg_mp9_b_suppressed] [Suppresses Weapon, +Quiet, -100 Threat] Value: 4

	--------------------------------------
				--Cobra--
	--------------------------------------
	--ID: self.scorpion
	--Class: Rapid Fire
	--Value: 7
	--Magazine: 20
	--Ammo: 220
	--Fire Rate: 1000
	--Damage: 50
	--Acc: 52
	--Stab: 100
	--Conc: 30
	--Threat: 10
	--Pickup: 8, 16
	--Notes: 
	--Active Mods: Extended Mag [+20 Magazine, -10 Concealment]

	--------------------------------------
				--Micro Uzi--
	--------------------------------------
	--ID: self.baka
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 32
	--Ammo: 240
	--Fire Rate: 1200
	--Damage: 50
	--Acc: 44
	--Stab: 100
	--Conc: 25
	--Threat: 10
	--Pickup: 8, 16
	--Notes: 
	--Active Mods:
	--Futomaki Suppressor [wpn_fps_smg_baka_b_longsupp] [Suppresses Weapon, +Quiet, -100 Threat] Value: 1
	--Maki Suppressor [wpn_fps_smg_baka_b_midsupp] [Suppresses Weapon, +Quiet, -100 Threat] Value: 1
	--Spring Suppressor [wpn_fps_smg_baka_b_smallsupp] [Suppresses Weapon, +Quiet, -100 Threat] Value: 1

	--------------------------------------
			--Medium SMGs--
	--------------------------------------
	--------------------------------------
				--Para--
	--------------------------------------
	--ID: self.olympic
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 20
	--Ammo: 160
	--Fire Rate: 682
	--Damage: 70
	--Acc: 72
	--Stab: 100
	--Conc: 25
	--Threat: 13
	--Pickup: 6, 10
	--Notes: 
	--Active Mods: Milspec Mag [wpn_fps_m4_uupg_m_std] [+10 Magazine, -2 Concealment] Value: 1
	--Tactical Mag [wpn_fps_upg_m4_m_pmag] [+10 Magazine, -2 Concealment] Value: 3
	--Expert Mag [wpn_fps_ass_l85a2_m_emag] [+10 Magazine, -2 Concealment] Value: 1
	--L5 Magazine [wpn_fps_upg_m4_m_l5] [+10 Magazine, -2 Concealment] Value: 1
	--CAR Quadstacked Mag [wpn_fps_upg_m4_m_quad] [+40 Magazine, -10 Concealment] Value: 3
	--Speedpull Mag [wpn_fps_m4_upg_m_quick] [+100% Reload Speed, +10 Magazine, -4 Concealment] Value: 2

	--------------------------------------
				--Chicago Typewriter--
	--------------------------------------
	--ID: self.m1928
	--Class: Rapid Fire
	--Value: 9
	--Magazine: 50
	--Ammo: 160
	--Fire Rate: 723
	--Damage: 70
	--Acc: 88
	--Stab: 100
	--Conc: 15
	--Threat: 20
	--Pickup: 6, 10
	--Notes: 
	--Active Mods: 

	--------------------------------------
				--Heather--
	--------------------------------------
	--ID: self.sr2
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 30
	--Ammo: 160
	--Fire Rate: 750
	--Damage: 70
	--Acc: 84
	--Stab: 100
	--Conc: 25
	--Threat: 13
	--Pickup: 6, 10
	--Notes: 
	--Active Mods: 
	--Speed Pull Mag [wpn_fps_smg_sr2_m_quick] [+100% Reload Speed, -8 Concealment] Value: 2 

	--------------------------------------
				--Kobus 90--
	--------------------------------------
	--ID: self.p90
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 50
	--Ammo: 160
	--Fire Rate: 909
	--Damage: 70
	--Acc: 76
	--Stab: 100
	--Conc: 20
	--Threat: 13
	--Pickup: 6, 10
	--Notes: 
	--Active Mods: 
	--Speed Pull Mag [wpn_fps_smg_p90_m_strap] [+100% Reload Speed, -3 Concealment] Value: 2

	--------------------------------------
				--SpecOps--
	--------------------------------------
	--ID: self.mp7
	--Class: Rapid Fire
	--Value: 7
	--Magazine: 20
	--Ammo: 160
	--Fire Rate: 952
	--Damage: 70
	--Acc: 84
	--Stab: 100
	--Conc: 25
	--Threat: 13
	--Pickup: 6, 10
	--Notes: 
	--Active Mods: 
	--Extended Mag. [wpn_fps_smg_mp7_m_extended] [+10 Magazine, -2 Concealment] Value: 1

	--------------------------------------
				--Mark 10--
	--------------------------------------
	--ID: self.mac10
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 20
	--Ammo: 160
	--Fire Rate: 1000
	--Damage: 70
	--Acc: 84
	--Stab: 100
	--Conc: 30
	--Threat: 13
	--Pickup: 6, 10
	--Notes: 
	--Active Mods: 
	--Extended Mag. [wpn_fps_smg_mac10_m_extended] [+20 Magazine, -5 Concealment] Value: 2
	--Speed Pull Mag [wpn_fps_smg_mac10_m_quick] [+100% Reload Speed, +20 Magazine, -10 Concealment] Value: 2

	--------------------------------------
				--Kross Vertex--
	--------------------------------------
	--ID: self.polymer
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 30
	--Ammo: 160
	--Fire Rate: 1200
	--Damage: 70
	--Acc: 84
	--Stab: 100
	--Conc: 15
	--Threat: 13
	--Pickup: 6, 10
	--Notes: 
	--Active Mods: 

	--------------------------------------
				--Jacket's Piece--
	--------------------------------------
	--ID: self.cobray
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 32
	--Ammo: 160
	--Fire Rate: 1200
	--Damage: 70
	--Acc: 72
	--Stab: 100
	--Conc: 20
	--Threat: 13
	--Pickup: 6, 10
	--Notes: 
	--Active Mods: 

	--------------------------------------
			--Heavy SMGs--
	--------------------------------------
	--------------------------------------
				--Patchett L2A1--
	--------------------------------------
	--ID: self.sterling
	--Class: Rapid Fire
	--Value: 7
	--Magazine: 20
	--Ammo: 80
	--Fire Rate: 545
	--Damage: 100
	--Acc: 56
	--Stab: 100
	--Conc: 20
	--Threat: 12
	--Pickup: 4, 6
	--Notes: Formerly a Light SMG.
	--Active Mods: 
	--Extended Mag [wpn_fps_smg_sterling_m_long] [+10 Magazine, -5 Concealment] Value: 1
		
	--Short Mag [wpn_fps_smg_sterling_m_short] [-10 Magazine, +5 Concealment] Value: 1
	
	--Heatsinked Suppressed Barrel [wpn_fps_smg_sterling_b_e11] [Suppresses Weapon, + Quiet, -100 Threat] Value: 4
		
	--Suppressed Barrel [wpn_fps_smg_sterling_b_suppressed] [Suppresses Weapon, + Quiet, -100 Threat] Value: 4
		
	--------------------------------------
				--MP40--
	--------------------------------------
	--ID: self.erma
	--Class: Rapid Fire
	--Value: 5
	--Magazine: 32
	--Ammo: 80
	--Fire Rate: 600
	--Damage: 100
	--Acc: 100
	--Stab: 80
	--Conc: 25
	--Threat: 20
	--Pickup: 4, 6
	--Notes: 
	--Active Mods:

	--------------------------------------
				--Swedish K--
	--------------------------------------
	--ID: self.m45
	--Class: Rapid Fire
	--Value: 5
	--Magazine: 36
	--Ammo: 80
	--Fire Rate: 600
	--Damage: 100
	--Acc: 100
	--Stab: 80
	--Conc: 20
	--Threat: 20
	--Pickup: 4, 6
	--Notes: 
	--Active Mods: Extended Mag. [wpn_fps_smg_m45_m_extended] [+14 Magazine, -5 Concealment] Value: 4

	--------------------------------------
				--Jackal--
	--------------------------------------
	--ID: self.schakal
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 30
	--Ammo: 80
	--Fire Rate: 652
	--Damage: 100
	--Acc: 100
	--Stab: 76
	--Conc: 20
	--Threat: 20
	--Pickup: 4, 6
	--Notes: 
	--Active Mods: Extended Magazine [wpn_fps_smg_schakal_m_long] [+10 Magazine, -10 Concealment] Value: 1
	--Extended Magazine [wpn_fps_smg_schakal_m_short] [-10 Magazine, +5 Concealment] Value: 1

	--------------------------------------
				--CR 805B--
	--------------------------------------
	--ID: self.hajk
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 30
	--Ammo: 80
	--Fire Rate: 750
	--Damage: 100
	--Acc: 100
	--Stab: 100
	--Conc: 10
	--Threat: 20
	--Pickup: 4, 6
	--Notes: 
	--Active Mods: CAR Quadstacked Mag [wpn_fps_upg_m4_m_quad] [+30 Magazine, -10 Concealment] Value: 3
	--Vintage Mag [wpn_fps_upg_m4_m_straight] [-10 Magazine, +5 Concealment] Value: 2
	--Speed Pull Mag [wpn_fps_m4_upg_m_quick] [+100% Reload Speed, -4 Concealment] Value: 2

	--------------------------------------
				--Krinkov--
	--------------------------------------
	--ID: self.akmsu
	--Class: Rapid Fire
	--Value: 1
	--Magazine: 30
	--Ammo: 80
	--Fire Rate: 822
	--Damage: 100
	--Acc: 92
	--Stab: 100
	--Conc: 20
	--Threat: 20
	--Pickup: 4, 6
	--Notes: 
	--Active Mods: AK Quadstacked Mag [wpn_fps_upg_ak_m_quad] [+30 Magazine, -15 Concealment] Value: 3
	--Speed Pull Mag [wpn_fps_upg_ak_m_quick] [+100% Reload Speed, -4 Concealment] Value: 2

	--------------------------------------
		--Secondary Shotguns--
	--------------------------------------
	--------------------------------------
				--Claire 12G--
	--------------------------------------
	--ID: self.coach
	--Class: Shotgun
	--Value: 3
	--Magazine: 2
	--Ammo: 22
	--Fire Rate: 170
	--Damage: 170
	--Acc: 40
	--Stab: 12
	--Conc: 30
	--Threat: 34
	--Pickup: 1, 2
	--Notes: 
	--Active Mods: Sawed-Off Barrel [-20 Accuracy]

	--------------------------------------
				--GSPS 12G--
	--------------------------------------
	--ID: self.m37
	--Class: Shotgun
	--Value: 1
	--Magazine: 7
	--Ammo: 46
	--Fire Rate: 104
	--Damage: 130
	--Acc: 40
	--Stab: 52
	--Conc: 25
	--Threat: 34
	--Pickup: 2, 3
	--Notes: 
	--Active Mods: 

	--------------------------------------
				--Locomotive 12G--
	--------------------------------------
	--ID: self.serbu
	--Class: Shotgun
	--Value: 1
	--Magazine: 8
	--Ammo: 42
	--Fire Rate: 160
	--Damage: 130
	--Acc: 40
	--Stab: 36
	--Conc: 30
	--Threat: 34
	--Pickup: 2, 3
	--Notes: 
	--Active Mods: Extended Magazine [+2 Magazine, -3 Concealment]
	--Shell Rack: [+5 Ammo Stock, -3 Concealment]

	--------------------------------------
				--Goliath 12G--
	--------------------------------------
	--ID: self.rota
	--Class: Shotgun
	--Value: 1
	--Magazine: 6
	--Ammo: 54
	--Fire Rate: 333
	--Damage: 80
	--Acc: 40
	--Stab: 52
	--Conc: 20
	--Threat: 34
	--Pickup: 4, 5
	--Notes: 
	--Active Mods: Silenced Barrel [wpn_fps_sho_rota_b_silencer] [Suppresses Weapon, +Quiet, -100 Threat] Value: 6

	--------------------------------------
				--Judge--
	--------------------------------------
	--ID: self.judge
	--Class: Shotgun
	--Value: 1
	--Magazine: 5
	--Ammo: 35
	--Fire Rate: 500
	--Damage: 180
	--Acc: 40
	--Stab: 20
	--Conc: 30
	--Threat: 11
	--Pickup: 0.5, 1
	--Notes: 
	--Active Mods:

	--------------------------------------
				--Grimm 12G--
	--------------------------------------
	--ID: self.basset
	--Class: Shotgun
	--Value: 1
	--Magazine: 7
	--Ammo: 96
	--Fire Rate: 300
	--Damage: 30
	--Acc: 40
	--Stab: 60
	--Conc: 30
	--Threat: 11
	--Pickup: 5, 6
	--Notes: 
	--Active Mods: Big Brother Magazine [+3 Magazine, -5 Concealment]

	--------------------------------------
				--Street Sweeper--
	--------------------------------------
	--ID: self.striker
	--Class: Shotgun
	--Value: 1
	--Magazine: 12
	--Ammo: 72
	--Fire Rate: 429
	--Damage: 60
	--Acc: 40
	--Stab: 60
	--Conc: 20
	--Threat: 43
	--Pickup: 4, 5
	--Notes: 
	--Active Mods: Suppressed Barrel [Suppresses Weapon, + “Quiet” Class, -100 Threat]

	--------------------------------------
		--Secondary Special Weapons--
	--------------------------------------
	--------------------------------------
				--Pistol Crossbow--
	--------------------------------------
	--ID: self.hunter
	--Class: Precision, Quiet
	--Value: 1
	--Magazine: 1
	--Ammo: 30
	--Fire Rate: 50
	--Damage: 350
	--Acc: 100
	--Stab: 100
	--Conc: 30
	--Threat: 0
	--Pickup: 0, 0
	--Notes: Armor Piercing
	--Active Mods: Explosive Bolt [- Armor Piercing, 2x Headshot Damage]
	--Poison Bolt [-250 Damage, +Poison]

	--------------------------------------
				--MA-17 Flamethrower--
	--------------------------------------
	--ID: self.system
	--Class: Specialist
	--Value: 1
	--Magazine: 600
	--Ammo: 600
	--Fire Rate: 2000
	--Damage: 100
	--Acc: 0
	--Stab: 100
	--Conc: 20
	--Threat: 43
	--Pickup: 1, 1
	--Notes: Igniting, Armor Piercing, Body Piercing, Shield Piercing, Improv Expert Aced
	--NOTE: Note: The MA-17 Flamethrower does not have an active Ammo Pickup without Improv Expert Aced.
	--Active Mods:

	--------------------------------------
				--Compact 40mm--
	--------------------------------------
	--ID: self.slap
	--Class: Specialist
	--Value: 1
	--Magazine: 1
	--Ammo: 6
	--Fire Rate: 30
	--Damage: 1100
	--Acc: 84
	--Stab: 84
	--Conc: 30
	--Threat: 43
	--Pickup: 0.05, 0.1
	--Notes: Area Damage
	--Active Mods: Incendiary Round [-1000 Damage, +Area Denial in a large area for 15 seconds.]

	--------------------------------------
				--China Puff 40mm--
	--------------------------------------
	--ID: self.china
	--Class: Specialist
	--Value: 1
	--Magazine: 3
	--Ammo: 6
	--Fire Rate: 50
	--Damage: 1100
	--Acc: 100
	--Stab: 100
	--Conc: 20
	--Threat: 43
	--Pickup: 0.05, 0.1
	--Notes: Area Damage
	--Active Mods: Incendiary Round [-1000 Damage, +Area Denial in a large area for 15 seconds.]

	--------------------------------------
				--Arbiter--
	--------------------------------------
	--ID: self.arbiter
	--Class: Specialist
	--Value: 1
	--Magazine: 5
	--Ammo: 15
	--Fire Rate: 80
	--Damage: 520
	--Acc: 100
	--Stab: 100
	--Conc: 20
	--Threat: 43
	--Pickup: 0.05, 0.1
	--Notes: Area Damage
	--NOTE: Unlike other Area Denial effects that mimic the Molotov Cocktail’s full-sized pool of flame, 
	-- the Arbiter’s Area Denial is based on the Incendiary Grenade’s reduced radius that only uses
	-- the central flame of the Molotov Cocktail effect.
	--Active Mods: Incendiary Round [-470 Damage, +Area Denial in a small area for 10 seconds.]
	--------------------------------------
				--HRL-7--
	--------------------------------------
	--ID: self.rpg7
	--Class: Specialist
	--Value: 1
	--Magazine: 1
	--Ammo: 4
	--Fire Rate: 30
	--Damage: 12500
	--Acc: 100
	--Stab: 100
	--Conc: 15
	--Threat: 43
	--Pickup: 0.001, 0.001
	--Notes: Area Damage, Improv Expert Aced
	--NOTE: The HRL-7 does not have an active Ammo Pickup without Improv Expert Aced.
	--Active Mods:
	--------------------------------------
				--Commando 101--
	--------------------------------------
	--ID: self.ray
	--Class: Specialist
	--Value: 1
	--Magazine: 4
	--Ammo: 4
	--Fire Rate: 60
	--Damage: 12500
	--Acc: 100
	--Stab: 100
	--Conc: 0
	--Threat: 43
	--Pickup: 0.001, 0.001
	--Notes: Area Damage, Improv Expert Aced
	--NOTE: The Commando 101 does not have an active Ammo Pickup without Improv Expert Aced.
	--Active Mods:

	--------------------------------------
	--OVE9000 Saw--
	--------------------------------------			
	--ID: self.saw
	--Class: Saw
	--Value: 1
	--Magazine: 150
	--Ammo: 300
	--Fire Rate: 400
	--Damage: 80
	--Acc: 100
	--Stab: 100
	--Conc: 20
	--Threat: 43
	--Pickup: 0, 0
	--Notes: Armor Piercing, Handyman Aced
	--NOTE: The hitbox is being moved to the middle of the screen. Rejoice!
	-- No longer has a hidden damage bonus to Dozers.
	-- The OVE9000 Saw is not available as a Secondary weapon without Handyman Aced.
	--Active Mods: Silent Motor [-200 Fire Rate, +10 Concealment, Reduced noise radius (base game mechanic)]
	--Fast Motor [-20 Concealment, +400 Fire Rate]
	--Durable Blade [-40 Damage, +50 Magazine Size, +100 Ammo Stock]
	--Sharp Blade [+20 Damage, +100 Magazine Size, -200 Ammo Stock]

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
		self.parts.wpn_fps_upg_ns_ass_smg_medium.stats = {suppression = 72, alert_size = 12, value = 2}
	-- The Bigger the Better Suppressor
		self.parts.wpn_fps_upg_ns_ass_smg_large.stats = {suppression = 72, alert_size = 12, value = 5}
	-- Hurricane Compensator -- name is tentative due to limited documentation of cartel optics pack files
		self.parts.wpn_fps_upg_ns_pis_typhoon.stats = {value = 4}
	-- Marmon Compensator -- name is tentative due to limited documentation of cartel optics pack files
		self.parts.wpn_fps_upg_ns_ass_smg_v6.stats = {value = 3}
	-- Jungle Ninja Suppressor
		self.parts.wpn_fps_upg_ns_pis_jungle.stats = {suppression = 72,	value = 5}
	-- Budget Suppressor
		self.parts.wpn_fps_upg_ns_ass_filter.stats = {suppression = 72,	value = 0} -- yes, value correct
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
		-- CAR Quadstacked Magazine [wpn_fps_upg_m4_m_quad] Value: 3
		self.parts.wpn_fps_upg_m4_m_quad.stats = {
			value = 3,		-- note wiki value incorrect
			extra_ammo = 15, 
			concealment = -10
		}
		--  [wpn_fps_upg_m4_m_straight] Value: 2
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
		self.parts.wpn_fps_upg_fl_ass_peq15.stats = {value = 5}	-- check vs wpn_fps_upg_fl_ass_peq15_flashlight
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
		self.parts.wpn_fps_upg_o_sig.stats = {value = 2, gadget_zoom = 9}
		-- 45 Degree Ironsights
		self.parts.wpn_fps_upg_o_45steel.stats = {value = 1, gadget_zoom = 1}	
	
	--Grip stat changes begin here.
		-- Pro Grip
		self.parts.wpn_fps_upg_m4_g_sniper.stats = {value = 6}	
		-- Ergo Grip
		self.parts.wpn_fps_upg_m4_g_ergo.stats = {value = 2}	
		-- Rubber Grip
		self.parts.wpn_fps_upg_m4_g_hgrip.stats = {value = 2}	
		-- Contractor Grip
		self.parts.wpn_fps_snp_tti_g_grippy.stats = {value = 1}
		-- Short Grip
		self.parts.wpn_fps_upg_m4_g_mgrip.stats = {value = 2}	
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
