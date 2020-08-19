local old_init = WeaponTweakData.init
function WeaponTweakData:init(tweak_data)
	--[[i dunno where to put this but heres a list of what weapons enemies use
	      heavy ar wpn_npc_s553
          light ar wpn_npc_m4
          heavy shot wpn_npc_benelli
          light shot wpn_npc_r870
          gman wpn_npc_r870
          other pistol nerds wpn_npc_c45
          revolver bois wpn_npc_raging_bull
          dozer wpn_npc_r870_dozer
          cd med wpn_npc_raging_bull_med
          cop smg wpn_npc_mp5
          meddozer wpn_npc_ump_meddozer
          dozer lmg wpn_npc_lmg_m249
          dozer black wpn_npc_saiga
		  cloaker wpn_npc_mp5_tactical
	]]--	  
	old_init(self, tweak_data)
	self.damage_tables = {
		deathvox_guard_pistol = { 
			not_a_real_difficulty = {damage = 10},
			normal = {damage = 2},
			hard = {damage = 2},
			very_hard = {damage = 2},
			overkill = {damage = 2},
			mayhem = {damage = 2},
			death_wish = {damage = 2},
			crackdown = {damage = 6}
		},
-- note light and heavy baselines are not used for beat cop type enemies. These will be implemented separately. They correspond to swat unit types (blue, yellow) instead.
	deathvox_light_ar = {
			not_a_real_difficulty = {damage = 10},
			normal = {damage = 2}, -- blue swat.
			hard = {damage = 2},
			very_hard = {damage = 4.5}, -- green.
			overkill = {damage = 4.5},
			mayhem = {damage = 6}, -- elite.
			death_wish = {damage = 6},
			crackdown = {damage = 7.5} -- zeal.
		},
	deathvox_heavy_ar = {
			not_a_real_difficulty = {damage = 10},
			normal = {damage = 4}, -- yellow swat.
			hard = {damage = 4},
			very_hard = {damage = 6}, -- tan.
			overkill = {damage = 6},
			mayhem = {damage = 7.5}, -- elite.
			death_wish = {damage = 7.5},
			crackdown = {damage = 9} -- zeal.
		},
        deathvox_shotgun_light = {
			not_a_real_difficulty = {damage = 10},
			normal = {damage = 6}, -- blue swat.
			hard = {damage = 6},
			very_hard = {damage = 7}, -- green.
			overkill = {damage = 7},
			mayhem = {damage = 7.5}, -- elite.
			death_wish = {damage = 7.5},
			crackdown = {damage = 9} -- zeal.
		},
	deathvox_shotgun_heavy = {
			not_a_real_difficulty = {damage = 10},
			normal = {damage = 8}, -- yellow swat.
			hard = {damage = 8},
			very_hard = {damage = 9.5}, -- tan.
			overkill = {damage = 9.5},
			mayhem = {damage = 10}, -- elite.
			death_wish = {damage = 10},
			crackdown = {damage = 11} -- zeal.
		},
        deathvox_medic_pistol = { -- note uses light ar on difficulties below CD.
			not_a_real_difficulty = {damage = 10},
			normal = {damage = 2}, -- blue.
			hard = {damage = 2}, --start.
			very_hard = {damage = 4}, -- green.
			overkill = {damage = 4},
			mayhem = {damage = 6},  -- elite.
			death_wish = {damage = 6},
			crackdown = {damage = 8} -- zeal
		},
	deathvox_cloaker = {
			not_a_real_difficulty = {damage = 10},
			normal = {damage = 4.5},
			hard = {damage = 6}, -- start. Match to higher layer light AR to preserve unit coherence.
			very_hard = {damage = 6},
			overkill = {damage = 6},
			mayhem = {damage = 6}, 
			death_wish = {damage = 6},
			crackdown = {damage = 7.5} -- zeal. Increase from prior values, matched to light AR.
		},
	deathvox_sniper = { -- focus much more on aim/focus delay than damage shift.
-- no need for asset coherence on this unit only, as at a distance. Discuss typing with group.
			not_a_real_difficulty = {damage = 10},
			normal = {damage = 16}, -- blue.
			hard = {damage = 16},
			very_hard = {damage = 18},
			overkill = {damage = 20}, -- green.
			mayhem = {damage = 20},
			death_wish = {damage = 20},
			crackdown = {damage = 24}
		},
	deathvox_greendozer = {
			not_a_real_difficulty = {damage = 10},
			normal = {damage = 24},
			hard = {damage = 24},
			very_hard = {damage = 24}, -- start.
			overkill = {damage = 24},
			mayhem = {damage = 24},
			death_wish = {damage = 24},
			crackdown = {damage = 32} -- zeal.
		},
	deathvox_blackdozer = {
			not_a_real_difficulty = {damage = 10},
			normal = {damage = 18},
			hard = {damage = 18},
			very_hard = {damage = 18},
			overkill = {damage = 18}, -- start.
			mayhem = {damage = 18},
			death_wish = {damage = 18},
			crackdown = {damage = 22.5} -- zeal. matched to DW.
		},
	deathvox_lmgdozer = { 
			not_a_real_difficulty = {damage = 10},
			normal = {damage = 10},
			hard = {damage = 10},
			very_hard = {damage = 10},
			overkill = {damage = 10},
			mayhem = {damage = 8}, -- start. Skull. Matched to DW.
			death_wish = {damage = 8},
			crackdown = {damage = 10} -- zeal. Value increased. Matched to intended minidozer.
		},
        deathvox_medicdozer_smg = {
			not_a_real_difficulty = {damage = 10},
			normal = {damage = 7.5},
			hard = {damage = 7.5},
			very_hard = {damage = 7.5},
			overkill = {damage = 7.5},
			mayhem = {damage = 7.5},
			death_wish = {damage = 7.5},
			crackdown = {damage = 7.5} -- start. zeal. Increase from prior values, matched to light AR.
		},
-- Grenadier damage values are zero as they are actually used to target their grenades.
        deathvox_grenadier = {
			not_a_real_difficulty = {damage = 10},
			normal = {damage = 0},
			hard = {damage = 0},
			very_hard = {damage = 0},
			overkill = {damage = 0},
			mayhem = {damage = 0},
			death_wish = {damage = 0},
			crackdown = {damage = 0} -- start.
		},
	deathvox_cop_pistol = {  -- mk 3 values. Previously 4 lock, now mapped to guard pistol.
			not_a_real_difficulty = {damage = 10},
			normal = {damage = 2},
			hard = {damage = 2},
			very_hard = {damage = 2},
			overkill = {damage = 2},
			mayhem = {damage = 2},
			death_wish = {damage = 2},
			crackdown = {damage = 6}
		},
	deathvox_cop_revolver = { -- mk 3 values. Previously 4 lock, now start at four and follow medic pistol.
			not_a_real_difficulty = {damage = 10},
			normal = {damage = 4},
			hard = {damage = 4},
			very_hard = {damage = 4},
			overkill = {damage = 4},
			mayhem = {damage = 6},
			death_wish = {damage = 6},
			crackdown = {damage = 8}
		},
	deathvox_cop_shotgun = {  -- mk 3 values. Previously 6 lock, now mapped to light shot.
			not_a_real_difficulty = {damage = 10},
			normal = {damage = 6},
			hard = {damage = 6},
			very_hard = {damage = 7},
			overkill = {damage = 7},
			mayhem = {damage = 7.5},
			death_wish = {damage = 7.5},
			crackdown = {damage = 9}
		},
	deathvox_cop_smg = {  -- mk 3 values. previously 2.5 lock, now begin at 2.5 then mapped to light AR.
			not_a_real_difficulty = {damage = 10},
			normal = {damage = 2.5},
			hard = {damage = 2.5},
			very_hard = {damage = 4.5},
			overkill = {damage = 4.5},
			mayhem = {damage = 6},
			death_wish = {damage = 6},
			crackdown = {damage = 7.5}
		}
	}
	self._gun_list_cd = {}
	self.deathvox_guard_pistol = deep_clone(self.c45_npc)
	self.deathvox_medic_pistol = deep_clone(self.raging_bull_npc)
	self.deathvox_light_ar = deep_clone(self.g36_npc)
	self.deathvox_heavy_ar = deep_clone(self.m4_npc)
	self.deathvox_shotgun_light = deep_clone(self.r870_npc)
	self.deathvox_shotgun_heavy = deep_clone(self.benelli_npc)
	self.deathvox_sniper = deep_clone(self.m14_sniper_npc)
	self.deathvox_medicdozer_smg = deep_clone(self.mp5_npc)
	self.deathvox_grenadier = deep_clone(self.m32_crew)
	
	self.deathvox_lmgdozer = deep_clone(self.m249_npc)
	self.deathvox_cloaker = deep_clone(self.mp5_tactical_npc)
	self.deathvox_blackdozer = deep_clone(self.saiga_npc)
	self.deathvox_greendozer = deep_clone(self.r870_npc)

	self.deathvox_cop_pistol = deep_clone(self.c45_npc)
	table.insert(self._gun_list_cd, "deathvox_cop_pistol")

	self.deathvox_cop_revolver = deep_clone(self.raging_bull_npc)
	self.deathvox_cop_revolver.sounds.prefix = "rbull_npc"
	self.deathvox_cop_revolver.DAMAGE = 4 -- DEPRECATED due to use of damage table.
	self.deathvox_cop_revolver.muzzleflash = "effects/payday2/particles/weapons/9mm_auto"
	self.deathvox_cop_revolver.muzzleflash_silenced = "effects/payday2/particles/weapons/9mm_auto_silence"
	self.deathvox_cop_revolver.shell_ejection = "effects/payday2/particles/weapons/shells/shell_empty"
	self.deathvox_cop_revolver.CLIP_AMMO_MAX = 6
	self.deathvox_cop_revolver.NR_CLIPS_MAX = 8
	self.deathvox_cop_revolver.hold = "pistol"
	self.deathvox_cop_revolver.alert_size = 5000
	self.deathvox_cop_revolver.suppression = 1.8
	self.deathvox_cop_revolver.FIRE_MODE = "single"
	table.insert(self._gun_list_cd, "deathvox_cop_revolver")
	
	self.deathvox_cop_shotgun = deep_clone(self.r870_npc)
	self.deathvox_cop_shotgun.rays = nil
	self.deathvox_cop_shotgun.spread = nil
	self.deathvox_cop_shotgun.reload = "looped"
	self.deathvox_cop_shotgun.looped_reload_speed = 0.8 -- time it takes to reload each shell.
	table.insert(self._gun_list_cd, "deathvox_cop_shotgun")
	
	self.deathvox_cop_smg = deep_clone(self.mp5_npc)
	table.insert(self._gun_list_cd, "deathvox_cop_smg")
	
	self.deathvox_light_ar.sounds.prefix = "g36_npc" -- dont worry about this
	self.deathvox_light_ar.use_data.selection_index = 2 -- dont worry about this
	self.deathvox_light_ar.DAMAGE = 7.5 -- DEPRECATED due to use of damage table.
	self.deathvox_light_ar.muzzleflash = "effects/payday2/particles/weapons/556_auto" -- dont worry about this
	self.deathvox_light_ar.shell_ejection = "effects/payday2/particles/weapons/shells/shell_556" -- dont worry about this
	self.deathvox_light_ar.CLIP_AMMO_MAX = 30 -- How many shots before reload
	self.deathvox_light_ar.NR_CLIPS_MAX = 5 -- Unused
	--self.deathvox_light_ar.pull_magazine_during_reload = "rifle" -- magazine used during reload.
	self.deathvox_light_ar.auto.fire_rate = 0.08 -- Firing delay in seconds
	--[[self.deathvox_light_ar.hold = { -- dont worry about this
		"bullpup",
		"rifle"
	}]]--
	self.deathvox_light_ar.alert_size = 5000 -- how far away in AlmirUnits(tm) it alerts people
	self.deathvox_light_ar.suppression = 1 -- dont worry about this
	self.deathvox_light_ar.usage = "is_light_rifle"
	self.deathvox_light_ar.anim_usage = "is_rifle"
	table.insert(self._gun_list_cd, "deathvox_light_ar")

	self.deathvox_heavy_ar.sounds.prefix = "m4_npc"
	self.deathvox_heavy_ar.use_data.selection_index = 2
	self.deathvox_heavy_ar.DAMAGE = 10 -- DEPRECATED due to use of damage table.
	self.deathvox_heavy_ar.muzzleflash = "effects/payday2/particles/weapons/762_auto"
	self.deathvox_heavy_ar.shell_ejection = "effects/payday2/particles/weapons/shells/shell_556"
	self.deathvox_heavy_ar.CLIP_AMMO_MAX = 20
	self.deathvox_heavy_ar.NR_CLIPS_MAX = 5
	--self.deathvox_heavy_ar.pull_magazine_during_reload = "rifle"
	self.deathvox_heavy_ar.auto.fire_rate = 0.08
	self.deathvox_heavy_ar.hold = "rifle"
	self.deathvox_heavy_ar.alert_size = 5000
	self.deathvox_heavy_ar.suppression = 1
	self.deathvox_heavy_ar.usage = "is_heavy_rifle"
	self.deathvox_heavy_ar.anim_usage = "is_rifle"
	table.insert(self._gun_list_cd, "deathvox_heavy_ar")

	self.deathvox_guard_pistol.sounds.prefix = "packrat_npc"
	self.deathvox_guard_pistol.use_data.selection_index = 1
	self.deathvox_guard_pistol.DAMAGE = 6 -- DEPRECATED due to use of damage table.
	self.deathvox_guard_pistol.muzzleflash = "effects/payday2/particles/weapons/9mm_auto"
	self.deathvox_guard_pistol.muzzleflash_silenced = "effects/payday2/particles/weapons/9mm_auto_silence"
	self.deathvox_guard_pistol.shell_ejection = "effects/payday2/particles/weapons/shells/shell_9mm"
	self.deathvox_guard_pistol.CLIP_AMMO_MAX = 15
	self.deathvox_guard_pistol.NR_CLIPS_MAX = 5
	--self.deathvox_guard_pistol.pull_magazine_during_reload = "pistol"
	self.deathvox_guard_pistol.hold = "pistol"
	self.deathvox_guard_pistol.alert_size = 2500
	self.deathvox_guard_pistol.suppression = 1
	self.deathvox_guard_pistol.usage = "is_pistol"
	self.deathvox_guard_pistol.anim_usage = "is_pistol"
	table.insert(self._gun_list_cd, "deathvox_guard_pistol")

	self.deathvox_medic_pistol.sounds.prefix = "mateba_npc"
	self.deathvox_medic_pistol.use_data.selection_index = 1
	self.deathvox_medic_pistol.DAMAGE = 8 -- DEPRECATED due to use of damage table.
	self.deathvox_medic_pistol.muzzleflash = "effects/payday2/particles/weapons/9mm_auto"
	self.deathvox_medic_pistol.muzzleflash_silenced = "effects/payday2/particles/weapons/9mm_auto_silence"
	self.deathvox_medic_pistol.shell_ejection = "effects/payday2/particles/weapons/shells/shell_empty"
	self.deathvox_medic_pistol.CLIP_AMMO_MAX = 6
	self.deathvox_medic_pistol.NR_CLIPS_MAX = 8
	self.deathvox_medic_pistol.hold = "pistol"
	self.deathvox_medic_pistol.reload = "revolver"
	self.deathvox_medic_pistol.alert_size = 5000
	self.deathvox_medic_pistol.suppression = 1.8
	self.deathvox_medic_pistol.usage = "is_revolver"
	self.deathvox_medic_pistol.anim_usage = "is_revolver"
	self.deathvox_medic_pistol.armor_piercing = true -- armor piercing.
	table.insert(self._gun_list_cd, "deathvox_medic_pistol")

	self.deathvox_shotgun_light.sounds.prefix = "remington_npc"
	self.deathvox_shotgun_light.use_data.selection_index = 2
	self.deathvox_shotgun_light.DAMAGE = 12 -- DEPRECATED due to use of damage table.
	self.deathvox_shotgun_light.muzzleflash = "effects/payday2/particles/weapons/762_auto"
	self.deathvox_shotgun_light.shell_ejection = "effects/payday2/particles/weapons/shells/shell_slug_semi"
	self.deathvox_shotgun_light.CLIP_AMMO_MAX = 6
	self.deathvox_shotgun_light.NR_CLIPS_MAX = 4
	self.deathvox_shotgun_light.hold = "rifle"
	self.deathvox_shotgun_light.alert_size = 4500
	self.deathvox_shotgun_light.suppression = 1.8
	self.deathvox_shotgun_light.is_shotgun = true 
	self.deathvox_shotgun_light.usage = "is_light_shotgun"
	self.deathvox_shotgun_light.anim_usage = "is_shotgun_pump"
	self.deathvox_shotgun_light.reload = "looped"
	self.deathvox_shotgun_light.looped_reload_speed = 0.8 -- time it takes to reload each shell
	table.insert(self._gun_list_cd, "deathvox_shotgun_light")

	self.deathvox_shotgun_heavy.sounds.prefix = "benelli_m4_npc"
	self.deathvox_shotgun_heavy.use_data.selection_index = 2
	self.deathvox_shotgun_heavy.DAMAGE = 15 -- DEPRECATED due to use of damage table.
	self.deathvox_shotgun_heavy.muzzleflash = "effects/payday2/particles/weapons/762_auto"
	self.deathvox_shotgun_heavy.shell_ejection = "effects/payday2/particles/weapons/shells/shell_slug"
	self.deathvox_shotgun_heavy.CLIP_AMMO_MAX = 8
	self.deathvox_shotgun_heavy.NR_CLIPS_MAX = 4
	self.deathvox_shotgun_heavy.hold = "rifle"
	self.deathvox_shotgun_heavy.reload = "looped"
	self.deathvox_shotgun_heavy.looped_reload_speed = 0.8 -- time it takes to reload each shell
	self.deathvox_shotgun_heavy.alert_size = 4500
	self.deathvox_shotgun_heavy.suppression = 1.8
	self.deathvox_shotgun_heavy.is_shotgun = true
	self.deathvox_shotgun_heavy.usage = "is_heavy_shotgun"
	self.deathvox_shotgun_heavy.anim_usage = "is_shotgun_pump"
	table.insert(self._gun_list_cd, "deathvox_shotgun_heavy")

	self.deathvox_sniper.categories = {"snp"}
	self.deathvox_sniper.sounds.prefix = "sniper_npc"
	self.deathvox_sniper.use_data.selection_index = 2
	self.deathvox_sniper.DAMAGE = 24 -- DEPRECATED due to use of damage table.
	self.deathvox_sniper.muzzleflash = "effects/payday2/particles/weapons/9mm_auto"
	self.deathvox_sniper.muzzleflash_silenced = "effects/payday2/particles/weapons/9mm_auto_silence"
	self.deathvox_sniper.shell_ejection = "effects/payday2/particles/weapons/shells/shell_9mm"
	self.deathvox_sniper.CLIP_AMMO_MAX = 10
	self.deathvox_sniper.NR_CLIPS_MAX = 5
	--self.deathvox_sniper.pull_magazine_during_reload = "rifle"
	--self.deathvox_sniper.auto.fire_rate = 0.5
	self.deathvox_sniper.alert_size = 5000
	self.deathvox_sniper.suppression = 1	
	self.deathvox_sniper.armor_piercing = true
	self.deathvox_sniper.usage = "is_assault_sniper"
	self.deathvox_sniper.anim_usage = "is_rifle"
    self.deathvox_sniper.use_laser = false
    self.deathvox_sniper.disable_sniper_laser = true	
	table.insert(self._gun_list_cd, "deathvox_sniper")
	
	self.deathvox_medicdozer_smg.sounds.prefix = "polymer_npc"
	self.deathvox_medicdozer_smg.use_data.selection_index = 1
	self.deathvox_medicdozer_smg.DAMAGE = 4.5 -- DEPRECATED due to use of damage table.
	self.deathvox_medicdozer_smg.muzzleflash = "effects/payday2/particles/weapons/9mm_auto"
	self.deathvox_medicdozer_smg.muzzleflash_silenced = "effects/payday2/particles/weapons/9mm_auto_silence"
	self.deathvox_medicdozer_smg.shell_ejection = "effects/payday2/particles/weapons/shells/shell_9mm"
	self.deathvox_medicdozer_smg.CLIP_AMMO_MAX = 30
	self.deathvox_medicdozer_smg.NR_CLIPS_MAX = 5
	self.deathvox_medicdozer_smg.reload = "rifle"
	self.deathvox_medicdozer_smg.pull_magazine_during_reload = "smg"
	self.deathvox_medicdozer_smg.auto.fire_rate = 0.05
	self.deathvox_medicdozer_smg.hold = "rifle"
	self.deathvox_medicdozer_smg.alert_size = 5000
	self.deathvox_medicdozer_smg.suppression = 1	
	self.deathvox_medicdozer_smg.usage = "is_tank_smg"
	table.insert(self._gun_list_cd, "deathvox_medicdozer_smg")

	self.deathvox_grenadier.sounds.prefix = "mgl_npc"
	self.deathvox_grenadier.use_data.selection_index = 2
	self.deathvox_grenadier.DAMAGE = 0 -- irrelevant, as does not fire bullets. DEPRECATED due to use of damage table.
	self.deathvox_grenadier.muzzleflash = "effects/payday2/particles/weapons/big_762_auto" -- increased visibility on fire.
	self.deathvox_grenadier.shell_ejection = "effects/payday2/particles/weapons/shells/shell_empty" -- appears to produce no effect.
	self.deathvox_grenadier.CLIP_AMMO_MAX = 9999999
	self.deathvox_grenadier.NR_CLIPS_MAX = 9999999
	self.deathvox_grenadier.looped_reload_speed = 10
	self.deathvox_grenadier.timers = {reload_not_empty = 10}
	self.deathvox_grenadier.timers.reload_empty = self.deathvox_grenadier.timers.reload_not_empty
	self.deathvox_grenadier.auto.fire_rate = 1
	self.deathvox_grenadier.hold = {
		"bullpup",
		"rifle"
	}
	self.deathvox_grenadier.reload = "rifle"
	self.deathvox_grenadier.alert_size = 5000
	self.deathvox_grenadier.suppression = 1
	self.deathvox_grenadier.usage = "is_heavy_rifle"
	self.deathvox_grenadier.anim_usage = "is_shotgun_pump"
	self.deathvox_grenadier.no_trail = true
	table.insert(self._gun_list_cd, "deathvox_grenadier")

	self.deathvox_lmgdozer.sounds.prefix = "m249_npc"
	self.deathvox_lmgdozer.use_data.selection_index = 2
	self.deathvox_lmgdozer.DAMAGE = 10 -- DEPRECATED due to use of damage table.
	self.deathvox_lmgdozer.muzzleflash = "effects/payday2/particles/weapons/big_762_auto"
	self.deathvox_lmgdozer.shell_ejection = "effects/payday2/particles/weapons/shells/shell_556_lmg"
	self.deathvox_lmgdozer.CLIP_AMMO_MAX = 200
	self.deathvox_lmgdozer.NR_CLIPS_MAX = 2
	self.deathvox_lmgdozer.spread = 8
	self.deathvox_lmgdozer.auto.fire_rate = 0.08
	self.deathvox_lmgdozer.hold = "rifle"
	self.deathvox_lmgdozer.alert_size = 5000
	self.deathvox_lmgdozer.suppression = 1
	self.deathvox_lmgdozer.usage = "is_dozer_lmg"
   	table.insert(self._gun_list_cd, "deathvox_lmgdozer")

	self.deathvox_cloaker.sounds.prefix = "schakal_npc"
	self.deathvox_cloaker.use_data.selection_index = 1
	self.deathvox_cloaker.DAMAGE = 4.5 -- DEPRECATED due to use of damage table.
	self.deathvox_cloaker.muzzleflash = "effects/payday2/particles/weapons/9mm_auto"
	self.deathvox_cloaker.muzzleflash_silenced = "effects/payday2/particles/weapons/9mm_auto_silence"
	self.deathvox_cloaker.shell_ejection = "effects/payday2/particles/weapons/shells/shell_9mm"
	self.deathvox_cloaker.CLIP_AMMO_MAX = 30
	self.deathvox_cloaker.NR_CLIPS_MAX = 5
	self.deathvox_cloaker.auto.fire_rate = 0.092
	self.deathvox_cloaker.hold = {
		"bullpup",
		"rifle"
	}
	self.deathvox_cloaker.alert_size = 5000
	self.deathvox_cloaker.suppression = 1
	self.deathvox_cloaker.usage = "is_cloaker_smg"
	table.insert(self._gun_list_cd, "deathvox_cloaker")
	
	self.deathvox_blackdozer.sounds.prefix = "saiga_npc"
	self.deathvox_blackdozer.use_data.selection_index = 2
	self.deathvox_blackdozer.DAMAGE = 22.5 -- DEPRECATED due to use of damage table.
	self.deathvox_blackdozer.muzzleflash = "effects/payday2/particles/weapons/762_auto"
	self.deathvox_blackdozer.shell_ejection = "effects/payday2/particles/weapons/shells/shell_slug"
	self.deathvox_blackdozer.auto.fire_rate = 0.14
	self.deathvox_blackdozer.CLIP_AMMO_MAX = 11
	self.deathvox_blackdozer.NR_CLIPS_MAX = 10
	self.deathvox_blackdozer.hold = "rifle"
	self.deathvox_blackdozer.spread = 3
	self.deathvox_blackdozer.alert_size = 4500
	self.deathvox_blackdozer.suppression = 1.8
	self.deathvox_blackdozer.is_shotgun = true
	self.deathvox_blackdozer.usage = "is_dozer_saiga"
	table.insert(self._gun_list_cd, "deathvox_blackdozer")
	
	self.deathvox_greendozer.sounds.prefix = "remington_npc"
	self.deathvox_greendozer.use_data.selection_index = 2
	self.deathvox_greendozer.DAMAGE = 50 -- DEPRECATED due to use of damage table.
	self.deathvox_greendozer.muzzleflash = "effects/payday2/particles/weapons/762_auto"
	self.deathvox_greendozer.shell_ejection = "effects/payday2/particles/weapons/shells/shell_slug_semi"
	self.deathvox_greendozer.CLIP_AMMO_MAX = 6
	self.deathvox_greendozer.NR_CLIPS_MAX = 4
	self.deathvox_greendozer.hold = "shot"
	self.deathvox_greendozer.alert_size = 4500
	self.deathvox_greendozer.suppression = 1.8
	self.deathvox_greendozer.is_shotgun = true
	self.deathvox_greendozer.usage = "is_dozer_pump"
	self.deathvox_greendozer.anim_usage = "is_shotgun_pump"
	self.deathvox_greendozer.reload = "looped"
	self.deathvox_greendozer.looped_reload_speed = 0.8 -- time it takes to reload each shell.
	table.insert(self._gun_list_cd, "deathvox_greendozer")
	
	local all_rifles = {
		"m4_npc",
		"m4_yellow_npc",
		"ak47_npc",
		"ak47_ass_npc",		
		"g36_npc",
		"scar_npc",
		"deathvox_light_ar",
		"deathvox_heavy_ar"
	}
	
	local all_smgs = {
		"mp5_npc",
		"mac11_npc",
		"mp9_npc",
		"akmsu_smg_npc",
		"ump_npc",
		"asval_smg_npc",
		"deathvox_cloaker",
		"deathvox_cop_smg",
		"deathvox_medicdozer_smg"
	}

	for _, rname in ipairs(all_rifles) do
		self[rname].spread = 5
	end
	
	for _, sname in ipairs(all_smgs) do
		self[sname].spread = 8
	end

	local difficulties = {
		"easy",
		"normal",
		"hard",
		"overkill",
		"overkill_145",
		"easy_wish",
		"overkill_290",
		"sm_wish"
	}
	local better_names = {
		"not_a_real_difficulty",
		"normal",
		"hard",
		"very_hard",
		"overkill",
		"mayhem",
		"death_wish",
		"crackdown"
	}
	if Global and Global.game_settings and Global.game_settings.difficulty then
		local difficulty_index = table.index_of(difficulties, Global.game_settings.difficulty)
		local diff_name = better_names[difficulty_index]
		log(diff_name .. " DIFFICULTY NAME")
		for _, weapon_type in ipairs(self._gun_list_cd) do
			if self.damage_tables[weapon_type] then
				local damage_table = self.damage_tables[weapon_type]
				if damage_table then
					local chosen_diff = damage_table[diff_name]
					if chosen_diff then
						self[weapon_type].DAMAGE = chosen_diff["damage"]
					end
				end
			end
		end
	end	
	
	if deathvox:IsTotalCrackdownEnabled() then
		--Sentry stats here
			local function rpm(n) --converts rounds per minute to seconds per round
				local rounds_per_second = n / 60
				return 1 / rounds_per_second
			end
			
			--BASIC
		--	self.sentry_gun.KEEP_FIRE_ANGLE = 0.1
			self.sentry_gun.auto.fire_rate = rpm(400)
			self.sentry_gun.DAMAGE = 5
			self.sentry_gun.FIRE_RANGE = 2000
			self.sentry_gun.SPREAD = 10
			self.sentry_gun.DETECTION_RANGE = 2000
			
			
			--AP
			self.sentry_ap = table.deep_map_copy(self.sentry_gun)
			self.sentry_ap.DAMAGE = 10
			self.sentry_ap.auto.fire_rate = rpm(100)
			self.sentry_ap.can_shoot_through_enemy = true
			self.sentry_ap.can_shoot_through_shield = true
			self.sentry_ap.can_shoot_through_wall = false
			self.sentry_ap.muzzleflash = "effects/particles/weapons/mp5/scene_m_muzzle"
			
			--HE
			self.sentry_he = table.deep_map_copy(self.sentry_gun)
			self.sentry_he.DAMAGE = 5
			self.sentry_he.auto.fire_rate = rpm(100)
			self.sentry_he.muzzleflash = "effects/particles/weapons/shotgun/muzzleflash"
			
			--TASER
			self.sentry_taser = table.deep_map_copy(self.sentry_gun)
			self.sentry_taser.DAMAGE = 1.5
			self.sentry_taser.auto.fire_rate = rpm(400)
			self.sentry_taser.SUPPRESSION = 0
			self.sentry_taser.muzzleflash = "effects/particles/weapons/silenced/muzzleflash"
		--	self.sentry_gun.SPREAD = 5
		--	self.sentry_gun.FIRE_RANGE = 5000
	end
	
	
end

-- Begin difficulty scripted weapon damage value population.

-- Begin NORMAL difficulty damage values. 

function WeaponTweakData:_set_normal()

	--Rifles
	self.m4_npc.DAMAGE = 4		-- Heavy SWAT Riflemen. Mapped to heavy AR.
	self.g36_npc.DAMAGE = 2		-- Light SWAT Riflemen, possibly. Mapped to light AR.
	self.ump_npc.DAMAGE = 2		-- Light SWAT Riflemen, possibly. Mapped to light AR.
	self.akmsu_smg_npc.DAMAGE = 2		-- Light SWAT Riflemen, possibly. Mapped to light AR.
	self.ak47_ass_npc.DAMAGE = 2 -- possibly unused aside from akan. Mapped to light AR.
	self.ak47_npc.DAMAGE = 4	-- possibly used by mobster units. Map to heavy AR.
	self.scar_npc.DAMAGE = 2 --Scripted murky units, possibly useful for later custom units? Mapped to light AR.
	
	--Shotguns
	self.r870_npc.DAMAGE = 6	-- Light SWAT Shotgunners. Mapped to Light Shotgun.
	self.benelli_npc.DAMAGE = 8 -- Heavy SWAT Shotgunners. Mapped to Heavy Shotgun.
	
	--Unique/Special Weapons (scripted, special enemies, bosses)
	self.contraband_npc.DAMAGE = 6   -- apparently used exclusively by Sosa. Draft value up one tier from heavy AR.
	self.x_c45_npc.DAMAGE = 4	-- chavez weapon. Check name and syntax. Draft map to medic revolver + 20.
	
	self.m4_yellow_npc.DAMAGE = 2	-- populates taser damage after other fixes applied. Map to light AR.
	
	self.mossberg_npc.DAMAGE = 24 --temporary Greendozer Shotgun, not enough shotguns to map to all units, consider Bulldozer-specific weapon presets?
	self.saiga_npc.DAMAGE = 18 --Blackdozer Saiga, mapped to Deathvox Blackdozer.
	self.m249_npc.DAMAGE = 10 --LMGDozer M249, has is_rifle behavior, needs to have it's usage changed. consider Bulldozer-specific weapon presets?
	self.rpk_lmg_npc.DAMAGE = 10 --LMGDozer M249, AKAN faction, has is_rifle behavior, normal M249.
	self.s552_npc.DAMAGE = 7.5 --No info on what or who uses it, so it might be better used as the MedicDozer weapon, damage mapped as such, unsure whether it actually exists as a weapon in the game's files, however.
	
	self.mp5_tactical_npc.DAMAGE = 4.5 --Used by Cloaker, mapped to Deathvox Cloaker SMG.
	self.asval_smg_npc.DAMAGE = 4.5 --Used by Akan Cloaker, mapped to Deathvox Cloaker SMG.
	
--	self.m14_npc.DAMAGE = 3		-- possibly unused.
	self.m14_sniper_npc.DAMAGE = 16	-- possibly fully overwritten.
	
	self.mp5_npc.DAMAGE = 2.5	-- smg used by number of units. Map to cop smg.
	self.mp9_npc.DAMAGE = 2.5	-- shield only.	Map to cop smg.
	self.c45_npc.DAMAGE = 2		-- pistol used by variety of units. Draft map to cop pistol.
	self.raging_bull_npc.DAMAGE = 4	-- bronco used by variety of units. Draft map to cop revolver. Make sure no armor pierce.
	self.mac11_npc.DAMAGE = 2.5	-- smg used by number of criminal units. Map to cop smg.
	self.smoke_npc.DAMAGE = 4	-- vit secret enemy weapon. Map to Heavy AR.
--	self.mini_npc.DAMAGE = 10	-- minigun damage. Used only for specific scripted enemies. Draft value assumes general lmg usage.
	
-- below code is goofball legacy believed to reinitialize enemy melee values.	
	self.npc_melee.baton.damage = 5
	self.npc_melee.knife_1.damage = 7
	self.npc_melee.fists.damage = 4
-- end goofball legacy code block.

-- Begin NORMAL Turret values.
	if managers.skirmish and managers.skirmish:is_skirmish() then

--turret stats for holdout
	self.swat_van_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 300 -- Same as CD.
	self.swat_van_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.swat_van_turret_module.FIRE_DMG_MUL = 0.1
	self.swat_van_turret_module.BAG_DMG_MUL = 100
	self.swat_van_turret_module.SHIELD_DMG_MUL = 1
	self.swat_van_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.swat_van_turret_module.BODY_DAMAGE_CLAMP = 4200
	self.swat_van_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.swat_van_turret_module.CLIP_SIZE = 300 -- compare base game stat, 400.
	self.swat_van_turret_module.AUTO_REPAIR = true
	self.swat_van_turret_module.AUTO_REPAIR_MAX_COUNT = 1 -- Reduced repair count for FBI.
	self.swat_van_turret_module.AUTO_REPAIR_DURATION = 30
	self.swat_van_turret_module.AUTO_RELOAD_DURATION = 8
	self.swat_van_turret_module.CAN_GO_IDLE = true
	self.swat_van_turret_module.IDLE_WAIT_TIME = 10
	
	--Ceiling turrets.
	self.ceiling_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 500 -- Same as base game overkill.
	self.ceiling_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.ceiling_turret_module.FIRE_DMG_MUL = 0.1
	self.ceiling_turret_module.BAG_DMG_MUL = 100
	self.ceiling_turret_module.SHIELD_DMG_MUL = 1
	self.ceiling_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.ceiling_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.ceiling_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.ceiling_turret_module.CLIP_SIZE = 300 -- compare base game stat, 400.
	self.ceiling_turret_module.AUTO_REPAIR = false
	self.ceiling_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.ceiling_turret_module.AUTO_REPAIR_DURATION = 1
	self.ceiling_turret_module.AUTO_RELOAD_DURATION = 8
	self.ceiling_turret_module.CAN_GO_IDLE = false
	self.ceiling_turret_module.IDLE_WAIT_TIME = 1
	
	--Crate turrets. Clone Ceiling turrets with slight revisions.
	self.crate_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.crate_turret_module.SHIELD_HEALTH_INIT = 500 -- Same as base game overkill.
	self.crate_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.crate_turret_module.FIRE_DMG_MUL = 0.1
	self.crate_turret_module.BAG_DMG_MUL = 100
	self.crate_turret_module.SHIELD_DMG_MUL = 1
	self.crate_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.crate_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.crate_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.crate_turret_module.CLIP_SIZE = 200 -- reduced due to locations used being mostly close range.
	self.crate_turret_module.AUTO_REPAIR = false
	self.crate_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.crate_turret_module.AUTO_REPAIR_DURATION = 1
	self.crate_turret_module.AUTO_RELOAD_DURATION = 8
	self.crate_turret_module.CAN_GO_IDLE = false
	self.crate_turret_module.IDLE_WAIT_TIME = 1
	
	--unusual variants in base game files; may or may not be used.
	self.ceiling_turret_module_no_idle = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range.CAN_GO_IDLE = false
	self.ceiling_turret_module_longer_range.FIRE_RANGE = 30000
	self.ceiling_turret_module_longer_range.DETECTION_RANGE = self.ceiling_turret_module_longer_range.FIRE_RANGE
	
	-- AA turret; used on Henry's Rock.
	self.aa_turret_module.HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.SHIELD_HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.EXPLOSION_DMG_MUL = 0
	self.aa_turret_module.FIRE_DMG_MUL = 0
	self.aa_turret_module.BAG_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DAMAGE_CLAMP = 10
	self.aa_turret_module.BODY_DAMAGE_CLAMP = 10
	self.aa_turret_module.DAMAGE = 2.0
	self.aa_turret_module.CLIP_SIZE = 300
	self.aa_turret_module.AUTO_REPAIR = true 
	self.aa_turret_module.AUTO_REPAIR_MAX_COUNT = 999
	self.aa_turret_module.AUTO_REPAIR_DURATION = 30
	self.aa_turret_module.AUTO_RELOAD_DURATION = 8
	self.aa_turret_module.CAN_GO_IDLE = false
	self.aa_turret_module.IDLE_WAIT_TIME = 10
	
	else

--regular NORMAL turret stats

	self.swat_van_turret_module.HEALTH_INIT = 15000 -- compare 35k base game. Note no repair though.
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 300 -- Same as CD.
	self.swat_van_turret_module.EXPLOSION_DMG_MUL = 7 -- Full explosive mult.
	self.swat_van_turret_module.FIRE_DMG_MUL = 0.1
	self.swat_van_turret_module.BAG_DMG_MUL = 100
	self.swat_van_turret_module.SHIELD_DMG_MUL = 1
	self.swat_van_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.swat_van_turret_module.BODY_DAMAGE_CLAMP = 4200
	self.swat_van_turret_module.DAMAGE = 0.5	-- same as base game hard.
	self.swat_van_turret_module.CLIP_SIZE = 200 -- compare base game stat, 400.
	self.swat_van_turret_module.AUTO_REPAIR = false -- No repair for SWAT tier.
	self.swat_van_turret_module.AUTO_REPAIR_MAX_COUNT = 1 
	self.swat_van_turret_module.AUTO_REPAIR_DURATION = 30
	self.swat_van_turret_module.AUTO_RELOAD_DURATION = 8
	self.swat_van_turret_module.CAN_GO_IDLE = false
	self.swat_van_turret_module.IDLE_WAIT_TIME = 10
	
	--Ceiling turrets.
	self.ceiling_turret_module.HEALTH_INIT = 15000 -- compare 35k base game. Note no repair though.
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 300 -- Same as CD.
	self.ceiling_turret_module.EXPLOSION_DMG_MUL = 7 -- Full explosive mult.
	self.ceiling_turret_module.FIRE_DMG_MUL = 0.1
	self.ceiling_turret_module.BAG_DMG_MUL = 100
	self.ceiling_turret_module.SHIELD_DMG_MUL = 1
	self.ceiling_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.ceiling_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.ceiling_turret_module.DAMAGE = 0.5	-- same as base game hard.
	self.ceiling_turret_module.CLIP_SIZE = 200 -- compare base game stat, 400.
	self.ceiling_turret_module.AUTO_REPAIR = false
	self.ceiling_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.ceiling_turret_module.AUTO_REPAIR_DURATION = 1
	self.ceiling_turret_module.AUTO_RELOAD_DURATION = 8
	self.ceiling_turret_module.CAN_GO_IDLE = false
	self.ceiling_turret_module.IDLE_WAIT_TIME = 1
	
	--Crate turrets. Clone Ceiling turrets with slight revisions.
	self.crate_turret_module.HEALTH_INIT = 15000 -- compare 35k base game. Note low damage.
	self.crate_turret_module.SHIELD_HEALTH_INIT = 300 -- Same as base game overkill.
	self.crate_turret_module.EXPLOSION_DMG_MUL = 7 -- Full explosive mult.
	self.crate_turret_module.FIRE_DMG_MUL = 0.1
	self.crate_turret_module.BAG_DMG_MUL = 100
	self.crate_turret_module.SHIELD_DMG_MUL = 1
	self.crate_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.crate_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.crate_turret_module.DAMAGE = 0.5	-- same as base game hard.
	self.crate_turret_module.CLIP_SIZE = 150 -- reduced due to locations used being mostly close range.
	self.crate_turret_module.AUTO_REPAIR = false
	self.crate_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.crate_turret_module.AUTO_REPAIR_DURATION = 1
	self.crate_turret_module.AUTO_RELOAD_DURATION = 8
	self.crate_turret_module.CAN_GO_IDLE = false
	self.crate_turret_module.IDLE_WAIT_TIME = 1
	
	--unusual variants in base game files; may or may not be used.
	self.ceiling_turret_module_no_idle = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range.CAN_GO_IDLE = false
	self.ceiling_turret_module_longer_range.FIRE_RANGE = 30000
	self.ceiling_turret_module_longer_range.DETECTION_RANGE = self.ceiling_turret_module_longer_range.FIRE_RANGE
	
	-- AA turret; used on Henry's Rock.
	self.aa_turret_module.HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.SHIELD_HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.EXPLOSION_DMG_MUL = 0
	self.aa_turret_module.FIRE_DMG_MUL = 0
	self.aa_turret_module.BAG_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DAMAGE_CLAMP = 10
	self.aa_turret_module.BODY_DAMAGE_CLAMP = 10
	self.aa_turret_module.DAMAGE = 0.5
	self.aa_turret_module.CLIP_SIZE = 200
	self.aa_turret_module.AUTO_REPAIR = true 
	self.aa_turret_module.AUTO_REPAIR_MAX_COUNT = 999
	self.aa_turret_module.AUTO_REPAIR_DURATION = 30
	self.aa_turret_module.AUTO_RELOAD_DURATION = 8
	self.aa_turret_module.CAN_GO_IDLE = false
	self.aa_turret_module.IDLE_WAIT_TIME = 10	
		
	end
end

-- Begin HARD difficulty damage values. 

function WeaponTweakData:_set_hard()
	--Rifles
	self.m4_npc.DAMAGE = 4		-- Heavy SWAT Riflemen. Mapped to heavy AR.
	self.g36_npc.DAMAGE = 2		-- Light SWAT Riflemen, possibly. Mapped to light AR.
	self.ump_npc.DAMAGE = 2		-- Light SWAT Riflemen, possibly. Mapped to light AR.
	self.akmsu_smg_npc.DAMAGE = 2		-- Light SWAT Riflemen, possibly. Mapped to light AR.
	self.ak47_ass_npc.DAMAGE = 2 -- possibly unused aside from akan. Mapped to light AR.
	self.ak47_npc.DAMAGE = 4	-- possibly used by mobster units. Map to heavy AR.
	self.scar_npc.DAMAGE = 2 --Scripted murky units, possibly useful for later custom units? Mapped to light AR.
	
	--Shotguns
	self.r870_npc.DAMAGE = 6	-- Light SWAT Shotgunners. Mapped to Light Shotgun.
	self.benelli_npc.DAMAGE = 8 -- Heavy SWAT Shotgunners. Mapped to Heavy Shotgun.
	
	--Unique/Special Weapons (scripted, special enemies, bosses)
	self.contraband_npc.DAMAGE = 6   -- apparently used exclusively by Sosa. Draft value up one tier from heavy AR.
	self.x_c45_npc.DAMAGE = 4	-- chavez weapon. Check name and syntax. Draft map to medic revolver + 20.
	
	self.m4_yellow_npc.DAMAGE = 2	-- populates taser damage after other fixes applied. Map to light AR.
	
	self.mossberg_npc.DAMAGE = 24 --temporary Greendozer Shotgun, not enough shotguns to map to all units, consider Bulldozer-specific weapon presets?
	self.saiga_npc.DAMAGE = 18 --Blackdozer Saiga, mapped to Deathvox Blackdozer.
	self.m249_npc.DAMAGE = 10 --LMGDozer M249, has is_rifle behavior, needs to have it's usage changed. consider Bulldozer-specific weapon presets?
	self.rpk_lmg_npc.DAMAGE = 10 --LMGDozer M249, AKAN faction, has is_rifle behavior, normal M249.
	self.s552_npc.DAMAGE = 7.5 --No info on what or who uses it, so it might be better used as the MedicDozer weapon, damage mapped as such, unsure whether it actually exists as a weapon in the game's files, however.
	
	self.mp5_tactical_npc.DAMAGE = 6 --Used by Cloaker, mapped to Deathvox Cloaker SMG.
	self.asval_smg_npc.DAMAGE = 6 --Used by Akan Cloaker, mapped to Deathvox Cloaker SMG.
	
--	self.m14_npc.DAMAGE = 3		-- possibly unused.
	self.m14_sniper_npc.DAMAGE = 16	-- possibly fully overwritten.
	
	self.mp5_npc.DAMAGE = 2.5	-- smg used by number of units. Map to cop smg.
	self.mp9_npc.DAMAGE = 2.5	-- shield only.	Map to cop smg.
	self.c45_npc.DAMAGE = 2		-- pistol used by variety of units. Draft map to cop pistol.
	self.raging_bull_npc.DAMAGE = 4	-- bronco used by variety of units. Draft map to cop revolver. Make sure no armor pierce.
	self.mac11_npc.DAMAGE = 2.5	-- smg used by number of criminal units. Map to cop smg.
	self.smoke_npc.DAMAGE = 4	-- vit secret enemy weapon. Map to Heavy AR.
--	self.mini_npc.DAMAGE = 10	-- minigun damage. Used only for specific scripted enemies. Draft value assumes general lmg usage.
	
-- below code is goofball legacy believed to reinitialize enemy melee values.	
	self.npc_melee.baton.damage = 5
	self.npc_melee.knife_1.damage = 7
	self.npc_melee.fists.damage = 4
-- end goofball legacy code block.
	
-- Begin HARD Turret values.
if managers.skirmish and managers.skirmish:is_skirmish() then
		
	self.swat_van_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 300 -- Same as CD.
	self.swat_van_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.swat_van_turret_module.FIRE_DMG_MUL = 0.1
	self.swat_van_turret_module.BAG_DMG_MUL = 100
	self.swat_van_turret_module.SHIELD_DMG_MUL = 1
	self.swat_van_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.swat_van_turret_module.BODY_DAMAGE_CLAMP = 4200
	self.swat_van_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.swat_van_turret_module.CLIP_SIZE = 300 -- compare base game stat, 400.
	self.swat_van_turret_module.AUTO_REPAIR = true
	self.swat_van_turret_module.AUTO_REPAIR_MAX_COUNT = 1 -- Reduced repair count for FBI.
	self.swat_van_turret_module.AUTO_REPAIR_DURATION = 30
	self.swat_van_turret_module.AUTO_RELOAD_DURATION = 8
	self.swat_van_turret_module.CAN_GO_IDLE = true
	self.swat_van_turret_module.IDLE_WAIT_TIME = 10
	
	--Ceiling turrets.
	self.ceiling_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 500 -- Same as base game overkill.
	self.ceiling_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.ceiling_turret_module.FIRE_DMG_MUL = 0.1
	self.ceiling_turret_module.BAG_DMG_MUL = 100
	self.ceiling_turret_module.SHIELD_DMG_MUL = 1
	self.ceiling_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.ceiling_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.ceiling_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.ceiling_turret_module.CLIP_SIZE = 300 -- compare base game stat, 400.
	self.ceiling_turret_module.AUTO_REPAIR = false
	self.ceiling_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.ceiling_turret_module.AUTO_REPAIR_DURATION = 1
	self.ceiling_turret_module.AUTO_RELOAD_DURATION = 8
	self.ceiling_turret_module.CAN_GO_IDLE = false
	self.ceiling_turret_module.IDLE_WAIT_TIME = 1
	
	--Crate turrets. Clone Ceiling turrets with slight revisions.
	self.crate_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.crate_turret_module.SHIELD_HEALTH_INIT = 500 -- Same as base game overkill.
	self.crate_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.crate_turret_module.FIRE_DMG_MUL = 0.1
	self.crate_turret_module.BAG_DMG_MUL = 100
	self.crate_turret_module.SHIELD_DMG_MUL = 1
	self.crate_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.crate_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.crate_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.crate_turret_module.CLIP_SIZE = 200 -- reduced due to locations used being mostly close range.
	self.crate_turret_module.AUTO_REPAIR = false
	self.crate_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.crate_turret_module.AUTO_REPAIR_DURATION = 1
	self.crate_turret_module.AUTO_RELOAD_DURATION = 8
	self.crate_turret_module.CAN_GO_IDLE = false
	self.crate_turret_module.IDLE_WAIT_TIME = 1
	
	--unusual variants in base game files; may or may not be used.
	self.ceiling_turret_module_no_idle = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range.CAN_GO_IDLE = false
	self.ceiling_turret_module_longer_range.FIRE_RANGE = 30000
	self.ceiling_turret_module_longer_range.DETECTION_RANGE = self.ceiling_turret_module_longer_range.FIRE_RANGE
	
	-- AA turret; used on Henry's Rock.
	self.aa_turret_module.HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.SHIELD_HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.EXPLOSION_DMG_MUL = 0
	self.aa_turret_module.FIRE_DMG_MUL = 0
	self.aa_turret_module.BAG_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DAMAGE_CLAMP = 10
	self.aa_turret_module.BODY_DAMAGE_CLAMP = 10
	self.aa_turret_module.DAMAGE = 2.0
	self.aa_turret_module.CLIP_SIZE = 300
	self.aa_turret_module.AUTO_REPAIR = true 
	self.aa_turret_module.AUTO_REPAIR_MAX_COUNT = 999
	self.aa_turret_module.AUTO_REPAIR_DURATION = 30
	self.aa_turret_module.AUTO_RELOAD_DURATION = 8
	self.aa_turret_module.CAN_GO_IDLE = false
	self.aa_turret_module.IDLE_WAIT_TIME = 10
	
else
	
--regular HARD turret stats
	self.swat_van_turret_module.HEALTH_INIT = 15000 -- compare 35k base game. Note no repair though.
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 300 -- Same as CD.
	self.swat_van_turret_module.EXPLOSION_DMG_MUL = 7 -- Full explosive mult.
	self.swat_van_turret_module.FIRE_DMG_MUL = 0.1
	self.swat_van_turret_module.BAG_DMG_MUL = 100
	self.swat_van_turret_module.SHIELD_DMG_MUL = 1
	self.swat_van_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.swat_van_turret_module.BODY_DAMAGE_CLAMP = 4200
	self.swat_van_turret_module.DAMAGE = 0.5	-- same as base game hard.
	self.swat_van_turret_module.CLIP_SIZE = 200 -- compare base game stat, 400.
	self.swat_van_turret_module.AUTO_REPAIR = false -- No repair for SWAT tier.
	self.swat_van_turret_module.AUTO_REPAIR_MAX_COUNT = 1 
	self.swat_van_turret_module.AUTO_REPAIR_DURATION = 30
	self.swat_van_turret_module.AUTO_RELOAD_DURATION = 8
	self.swat_van_turret_module.CAN_GO_IDLE = false
	self.swat_van_turret_module.IDLE_WAIT_TIME = 10
	
	--Ceiling turrets.
	self.ceiling_turret_module.HEALTH_INIT = 15000 -- compare 35k base game. Note no repair though.
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 300 -- Same as CD.
	self.ceiling_turret_module.EXPLOSION_DMG_MUL = 7 -- Full explosive mult.
	self.ceiling_turret_module.FIRE_DMG_MUL = 0.1
	self.ceiling_turret_module.BAG_DMG_MUL = 100
	self.ceiling_turret_module.SHIELD_DMG_MUL = 1
	self.ceiling_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.ceiling_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.ceiling_turret_module.DAMAGE = 0.5	-- same as base game hard.
	self.ceiling_turret_module.CLIP_SIZE = 200 -- compare base game stat, 400.
	self.ceiling_turret_module.AUTO_REPAIR = false
	self.ceiling_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.ceiling_turret_module.AUTO_REPAIR_DURATION = 1
	self.ceiling_turret_module.AUTO_RELOAD_DURATION = 8
	self.ceiling_turret_module.CAN_GO_IDLE = false
	self.ceiling_turret_module.IDLE_WAIT_TIME = 1
	
	--Crate turrets. Clone Ceiling turrets with slight revisions.
	self.crate_turret_module.HEALTH_INIT = 15000 -- compare 35k base game. Note low damage.
	self.crate_turret_module.SHIELD_HEALTH_INIT = 300 -- Same as CD.
	self.crate_turret_module.EXPLOSION_DMG_MUL = 7 -- Full explosive mult.
	self.crate_turret_module.FIRE_DMG_MUL = 0.1
	self.crate_turret_module.BAG_DMG_MUL = 100
	self.crate_turret_module.SHIELD_DMG_MUL = 1
	self.crate_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.crate_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.crate_turret_module.DAMAGE = 0.5	-- same as base game hard.
	self.crate_turret_module.CLIP_SIZE = 150 -- reduced due to locations used being mostly close range.
	self.crate_turret_module.AUTO_REPAIR = false
	self.crate_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.crate_turret_module.AUTO_REPAIR_DURATION = 1
	self.crate_turret_module.AUTO_RELOAD_DURATION = 8
	self.crate_turret_module.CAN_GO_IDLE = false
	self.crate_turret_module.IDLE_WAIT_TIME = 1
	
	--unusual variants in base game files; may or may not be used.
	self.ceiling_turret_module_no_idle = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range.CAN_GO_IDLE = false
	self.ceiling_turret_module_longer_range.FIRE_RANGE = 30000
	self.ceiling_turret_module_longer_range.DETECTION_RANGE = self.ceiling_turret_module_longer_range.FIRE_RANGE
	
	-- AA turret; used on Henry's Rock.
	self.aa_turret_module.HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.SHIELD_HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.EXPLOSION_DMG_MUL = 0
	self.aa_turret_module.FIRE_DMG_MUL = 0
	self.aa_turret_module.BAG_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DAMAGE_CLAMP = 10
	self.aa_turret_module.BODY_DAMAGE_CLAMP = 10
	self.aa_turret_module.DAMAGE = 0.5
	self.aa_turret_module.CLIP_SIZE = 200
	self.aa_turret_module.AUTO_REPAIR = true 
	self.aa_turret_module.AUTO_REPAIR_MAX_COUNT = 999
	self.aa_turret_module.AUTO_REPAIR_DURATION = 30
	self.aa_turret_module.AUTO_RELOAD_DURATION = 8
	self.aa_turret_module.CAN_GO_IDLE = false
	self.aa_turret_module.IDLE_WAIT_TIME = 10
	
	end
	
end

-- Begin VERY HARD difficulty damage values. 

function WeaponTweakData:_set_overkill()
	--Rifles
	self.m4_npc.DAMAGE = 6		-- Heavy SWAT Riflemen. Mapped to heavy AR.
	self.g36_npc.DAMAGE = 4.5		-- Light SWAT Riflemen, possibly. Mapped to light AR.
	self.ump_npc.DAMAGE = 4.5		-- Light SWAT Riflemen, possibly. Mapped to light AR.
	self.akmsu_smg_npc.DAMAGE = 4.5		-- Light SWAT Riflemen, possibly. Mapped to light AR.
	self.ak47_ass_npc.DAMAGE = 4.5 -- possibly unused aside from akan. Mapped to light AR.
	self.ak47_npc.DAMAGE = 6	-- possibly used by mobster units. Map to heavy AR.
	self.scar_npc.DAMAGE = 4.5 --Scripted murky units, possibly useful for later custom units? Mapped to light AR.
	
	--Shotguns
	self.r870_npc.DAMAGE = 7	-- Light SWAT Shotgunners. Mapped to Light Shotgun.
	self.benelli_npc.DAMAGE = 9.5 -- Heavy SWAT Shotgunners. Mapped to Heavy Shotgun.
	
	--Unique/Special Weapons (scripted, special enemies, bosses)
	self.contraband_npc.DAMAGE = 7.5   -- apparently used exclusively by Sosa. Draft value up one tier from heavy AR.
	self.x_c45_npc.DAMAGE = 6	-- chavez weapon. Check name and syntax. Draft map to medic revolver + 20.
	
	self.m4_yellow_npc.DAMAGE = 4.5	-- populates taser damage after other fixes applied. Map to light AR.
	
	self.mossberg_npc.DAMAGE = 24 --temporary Greendozer Shotgun, not enough shotguns to map to all units, consider Bulldozer-specific weapon presets?
	self.saiga_npc.DAMAGE = 18 --Blackdozer Saiga, mapped to Deathvox Blackdozer.
	self.m249_npc.DAMAGE = 10 --LMGDozer M249, has is_rifle behavior, needs to have it's usage changed. consider Bulldozer-specific weapon presets?
	self.rpk_lmg_npc.DAMAGE = 10 --LMGDozer M249, AKAN faction, has is_rifle behavior, normal M249.
	self.s552_npc.DAMAGE = 7.5 --No info on what or who uses it, so it might be better used as the MedicDozer weapon, damage mapped as such, unsure whether it actually exists as a weapon in the game's files, however.
	
	self.mp5_tactical_npc.DAMAGE = 6 --Used by Cloaker, mapped to Deathvox Cloaker SMG.
	self.asval_smg_npc.DAMAGE = 6 --Used by Akan Cloaker, mapped to Deathvox Cloaker SMG.
	
--	self.m14_npc.DAMAGE = 3		-- possibly unused.
	self.m14_sniper_npc.DAMAGE = 18	-- possibly fully overwritten.
	
	self.mp5_npc.DAMAGE = 4.5	-- smg used by number of units. Map to cop smg.
	self.mp9_npc.DAMAGE = 4.5	-- shield only.	Map to cop smg.
	self.c45_npc.DAMAGE = 2		-- pistol used by variety of units. Draft map to cop pistol.
	self.raging_bull_npc.DAMAGE = 4	-- bronco used by variety of units. Draft map to cop revolver. Make sure no armor pierce.
	self.mac11_npc.DAMAGE = 4.5	-- smg used by number of criminal units. Map to cop smg.
	self.smoke_npc.DAMAGE = 6	-- vit secret enemy weapon. Map to Heavy AR.
--	self.mini_npc.DAMAGE = 10	-- minigun damage. Used only for specific scripted enemies. Draft value assumes general lmg usage.
	
-- below code is goofball legacy believed to reinitialize enemy melee values.	
	self.npc_melee.baton.damage = 5
	self.npc_melee.knife_1.damage = 7
	self.npc_melee.fists.damage = 4
-- end goofball legacy code block.

	
-- Begin VERY HARD Turret values.

if managers.skirmish and managers.skirmish:is_skirmish() then
		
	self.swat_van_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 300 -- Same as CD.
	self.swat_van_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.swat_van_turret_module.FIRE_DMG_MUL = 0.1
	self.swat_van_turret_module.BAG_DMG_MUL = 100
	self.swat_van_turret_module.SHIELD_DMG_MUL = 1
	self.swat_van_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.swat_van_turret_module.BODY_DAMAGE_CLAMP = 4200
	self.swat_van_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.swat_van_turret_module.CLIP_SIZE = 300 -- compare base game stat, 400.
	self.swat_van_turret_module.AUTO_REPAIR = true
	self.swat_van_turret_module.AUTO_REPAIR_MAX_COUNT = 1 -- Reduced repair count for FBI.
	self.swat_van_turret_module.AUTO_REPAIR_DURATION = 30
	self.swat_van_turret_module.AUTO_RELOAD_DURATION = 8
	self.swat_van_turret_module.CAN_GO_IDLE = true
	self.swat_van_turret_module.IDLE_WAIT_TIME = 10
	
	--Ceiling turrets.
	self.ceiling_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 500 -- Same as base game overkill.
	self.ceiling_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.ceiling_turret_module.FIRE_DMG_MUL = 0.1
	self.ceiling_turret_module.BAG_DMG_MUL = 100
	self.ceiling_turret_module.SHIELD_DMG_MUL = 1
	self.ceiling_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.ceiling_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.ceiling_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.ceiling_turret_module.CLIP_SIZE = 300 -- compare base game stat, 400.
	self.ceiling_turret_module.AUTO_REPAIR = false
	self.ceiling_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.ceiling_turret_module.AUTO_REPAIR_DURATION = 1
	self.ceiling_turret_module.AUTO_RELOAD_DURATION = 8
	self.ceiling_turret_module.CAN_GO_IDLE = false
	self.ceiling_turret_module.IDLE_WAIT_TIME = 1
	
	--Crate turrets. Clone Ceiling turrets with slight revisions.
	self.crate_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.crate_turret_module.SHIELD_HEALTH_INIT = 500 -- Same as base game overkill.
	self.crate_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.crate_turret_module.FIRE_DMG_MUL = 0.1
	self.crate_turret_module.BAG_DMG_MUL = 100
	self.crate_turret_module.SHIELD_DMG_MUL = 1
	self.crate_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.crate_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.crate_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.crate_turret_module.CLIP_SIZE = 200 -- reduced due to locations used being mostly close range.
	self.crate_turret_module.AUTO_REPAIR = false
	self.crate_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.crate_turret_module.AUTO_REPAIR_DURATION = 1
	self.crate_turret_module.AUTO_RELOAD_DURATION = 8
	self.crate_turret_module.CAN_GO_IDLE = false
	self.crate_turret_module.IDLE_WAIT_TIME = 1
	
	--unusual variants in base game files; may or may not be used.
	self.ceiling_turret_module_no_idle = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range.CAN_GO_IDLE = false
	self.ceiling_turret_module_longer_range.FIRE_RANGE = 30000
	self.ceiling_turret_module_longer_range.DETECTION_RANGE = self.ceiling_turret_module_longer_range.FIRE_RANGE
	
	-- AA turret; used on Henry's Rock.
	self.aa_turret_module.HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.SHIELD_HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.EXPLOSION_DMG_MUL = 0
	self.aa_turret_module.FIRE_DMG_MUL = 0
	self.aa_turret_module.BAG_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DAMAGE_CLAMP = 10
	self.aa_turret_module.BODY_DAMAGE_CLAMP = 10
	self.aa_turret_module.DAMAGE = 2.0
	self.aa_turret_module.CLIP_SIZE = 300
	self.aa_turret_module.AUTO_REPAIR = true 
	self.aa_turret_module.AUTO_REPAIR_MAX_COUNT = 999
	self.aa_turret_module.AUTO_REPAIR_DURATION = 30
	self.aa_turret_module.AUTO_RELOAD_DURATION = 8
	self.aa_turret_module.CAN_GO_IDLE = false
	self.aa_turret_module.IDLE_WAIT_TIME = 10
	
else
	
--regular VERY HARD turret stats
	self.swat_van_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 300 -- Same as CD.
	self.swat_van_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.swat_van_turret_module.FIRE_DMG_MUL = 0.1
	self.swat_van_turret_module.BAG_DMG_MUL = 100
	self.swat_van_turret_module.SHIELD_DMG_MUL = 1
	self.swat_van_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.swat_van_turret_module.BODY_DAMAGE_CLAMP = 4200
	self.swat_van_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.swat_van_turret_module.CLIP_SIZE = 300 -- compare base game stat, 400.
	self.swat_van_turret_module.AUTO_REPAIR = true
	self.swat_van_turret_module.AUTO_REPAIR_MAX_COUNT = 1 -- Reduced repair count for FBI.
	self.swat_van_turret_module.AUTO_REPAIR_DURATION = 30
	self.swat_van_turret_module.AUTO_RELOAD_DURATION = 8
	self.swat_van_turret_module.CAN_GO_IDLE = true
	self.swat_van_turret_module.IDLE_WAIT_TIME = 10
	
	--Ceiling turrets.
	self.ceiling_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 500 -- Same as base game overkill.
	self.ceiling_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.ceiling_turret_module.FIRE_DMG_MUL = 0.1
	self.ceiling_turret_module.BAG_DMG_MUL = 100
	self.ceiling_turret_module.SHIELD_DMG_MUL = 1
	self.ceiling_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.ceiling_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.ceiling_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.ceiling_turret_module.CLIP_SIZE = 300 -- compare base game stat, 400.
	self.ceiling_turret_module.AUTO_REPAIR = false
	self.ceiling_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.ceiling_turret_module.AUTO_REPAIR_DURATION = 1
	self.ceiling_turret_module.AUTO_RELOAD_DURATION = 8
	self.ceiling_turret_module.CAN_GO_IDLE = false
	self.ceiling_turret_module.IDLE_WAIT_TIME = 1
	
	--Crate turrets. Clone Ceiling turrets with slight revisions.
	self.crate_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.crate_turret_module.SHIELD_HEALTH_INIT = 500 -- Same as base game overkill.
	self.crate_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.crate_turret_module.FIRE_DMG_MUL = 0.1
	self.crate_turret_module.BAG_DMG_MUL = 100
	self.crate_turret_module.SHIELD_DMG_MUL = 1
	self.crate_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.crate_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.crate_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.crate_turret_module.CLIP_SIZE = 200 -- reduced due to locations used being mostly close range.
	self.crate_turret_module.AUTO_REPAIR = false
	self.crate_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.crate_turret_module.AUTO_REPAIR_DURATION = 1
	self.crate_turret_module.AUTO_RELOAD_DURATION = 8
	self.crate_turret_module.CAN_GO_IDLE = false
	self.crate_turret_module.IDLE_WAIT_TIME = 1
	
	--unusual variants in base game files; may or may not be used.
	self.ceiling_turret_module_no_idle = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range.CAN_GO_IDLE = false
	self.ceiling_turret_module_longer_range.FIRE_RANGE = 30000
	self.ceiling_turret_module_longer_range.DETECTION_RANGE = self.ceiling_turret_module_longer_range.FIRE_RANGE

	-- AA turret; used on Henry's Rock.
	self.aa_turret_module.HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.SHIELD_HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.EXPLOSION_DMG_MUL = 0
	self.aa_turret_module.FIRE_DMG_MUL = 0
	self.aa_turret_module.BAG_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DAMAGE_CLAMP = 10
	self.aa_turret_module.BODY_DAMAGE_CLAMP = 10
	self.aa_turret_module.DAMAGE = 2.0
	self.aa_turret_module.CLIP_SIZE = 300
	self.aa_turret_module.AUTO_REPAIR = true 
	self.aa_turret_module.AUTO_REPAIR_MAX_COUNT = 999
	self.aa_turret_module.AUTO_REPAIR_DURATION = 30
	self.aa_turret_module.AUTO_RELOAD_DURATION = 8
	self.aa_turret_module.CAN_GO_IDLE = false
	self.aa_turret_module.IDLE_WAIT_TIME = 10
	end
	
end

-- Begin OVERKILL difficulty damage values. 

function WeaponTweakData:_set_overkill_145()
	--Rifles
	self.m4_npc.DAMAGE = 6		-- Heavy SWAT Riflemen. Mapped to heavy AR.
	self.g36_npc.DAMAGE = 4.5		-- Light SWAT Riflemen, possibly. Mapped to light AR.
	self.ump_npc.DAMAGE = 4.5		-- Light SWAT Riflemen, possibly. Mapped to light AR.
	self.akmsu_smg_npc.DAMAGE = 4.5		-- Light SWAT Riflemen, possibly. Mapped to light AR.
	self.ak47_ass_npc.DAMAGE = 4.5 -- possibly unused aside from akan. Mapped to light AR.
	self.ak47_npc.DAMAGE = 6	-- possibly used by mobster units. Map to heavy AR.
	self.scar_npc.DAMAGE = 4.5 --Scripted murky units, possibly useful for later custom units? Mapped to light AR.
	
	--Shotguns
	self.r870_npc.DAMAGE = 7	-- Light SWAT Shotgunners. Mapped to Light Shotgun.
	self.benelli_npc.DAMAGE = 9.5 -- Heavy SWAT Shotgunners. Mapped to Heavy Shotgun.
	
	--Unique/Special Weapons (scripted, special enemies, bosses)
	self.contraband_npc.DAMAGE = 7.5   -- apparently used exclusively by Sosa. Draft value up one tier from heavy AR.
	self.x_c45_npc.DAMAGE = 6	-- chavez weapon. Check name and syntax. Draft map to medic revolver + 20.
	
	self.m4_yellow_npc.DAMAGE = 4.5	-- populates taser damage after other fixes applied. Map to light AR.
	
	self.mossberg_npc.DAMAGE = 24 --temporary Greendozer Shotgun, not enough shotguns to map to all units, consider Bulldozer-specific weapon presets?
	self.saiga_npc.DAMAGE = 18 --Blackdozer Saiga, mapped to Deathvox Blackdozer.
	self.m249_npc.DAMAGE = 10 --LMGDozer M249, has is_rifle behavior, needs to have it's usage changed. consider Bulldozer-specific weapon presets?
	self.rpk_lmg_npc.DAMAGE = 10 --LMGDozer M249, AKAN faction, has is_rifle behavior, normal M249.
	self.s552_npc.DAMAGE = 7.5 --No info on what or who uses it, so it might be better used as the MedicDozer weapon, damage mapped as such, unsure whether it actually exists as a weapon in the game's files, however.
	
	self.mp5_tactical_npc.DAMAGE = 6 --Used by Cloaker, mapped to Deathvox Cloaker SMG.
	self.asval_smg_npc.DAMAGE = 6 --Used by Akan Cloaker, mapped to Deathvox Cloaker SMG.
	
--	self.m14_npc.DAMAGE = 3		-- possibly unused.
	self.m14_sniper_npc.DAMAGE = 20	-- possibly fully overwritten.
	
	self.mp5_npc.DAMAGE = 4.5	-- smg used by number of units. Map to cop smg.
	self.mp9_npc.DAMAGE = 4.5	-- shield only.	Map to cop smg.
	self.c45_npc.DAMAGE = 2		-- pistol used by variety of units. Draft map to cop pistol.
	self.raging_bull_npc.DAMAGE = 4	-- bronco used by variety of units. Draft map to cop revolver. Make sure no armor pierce.
	self.mac11_npc.DAMAGE = 4.5	-- smg used by number of criminal units. Map to cop smg.
	self.smoke_npc.DAMAGE = 6	-- vit secret enemy weapon. Map to Heavy AR.
--	self.mini_npc.DAMAGE = 10	-- minigun damage. Used only for specific scripted enemies. Draft value assumes general lmg usage.
	
-- below code is goofball legacy believed to reinitialize enemy melee values.	
	self.npc_melee.baton.damage = 5
	self.npc_melee.knife_1.damage = 7
	self.npc_melee.fists.damage = 4
-- end goofball legacy code block.
	
-- Begin OVERKILL Turret values.
if managers.skirmish and managers.skirmish:is_skirmish() then
		
	self.swat_van_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 300 -- Same as CD.
	self.swat_van_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.swat_van_turret_module.FIRE_DMG_MUL = 0.1
	self.swat_van_turret_module.BAG_DMG_MUL = 100
	self.swat_van_turret_module.SHIELD_DMG_MUL = 1
	self.swat_van_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.swat_van_turret_module.BODY_DAMAGE_CLAMP = 4200
	self.swat_van_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.swat_van_turret_module.CLIP_SIZE = 300 -- compare base game stat, 400.
	self.swat_van_turret_module.AUTO_REPAIR = true
	self.swat_van_turret_module.AUTO_REPAIR_MAX_COUNT = 1 -- Reduced repair count for FBI.
	self.swat_van_turret_module.AUTO_REPAIR_DURATION = 30
	self.swat_van_turret_module.AUTO_RELOAD_DURATION = 8
	self.swat_van_turret_module.CAN_GO_IDLE = true
	self.swat_van_turret_module.IDLE_WAIT_TIME = 10
	
	--Ceiling turrets.
	self.ceiling_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 500 -- Same as base game overkill.
	self.ceiling_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.ceiling_turret_module.FIRE_DMG_MUL = 0.1
	self.ceiling_turret_module.BAG_DMG_MUL = 100
	self.ceiling_turret_module.SHIELD_DMG_MUL = 1
	self.ceiling_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.ceiling_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.ceiling_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.ceiling_turret_module.CLIP_SIZE = 300 -- compare base game stat, 400.
	self.ceiling_turret_module.AUTO_REPAIR = false
	self.ceiling_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.ceiling_turret_module.AUTO_REPAIR_DURATION = 1
	self.ceiling_turret_module.AUTO_RELOAD_DURATION = 8
	self.ceiling_turret_module.CAN_GO_IDLE = false
	self.ceiling_turret_module.IDLE_WAIT_TIME = 1
	
	--Crate turrets. Clone Ceiling turrets with slight revisions.
	self.crate_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.crate_turret_module.SHIELD_HEALTH_INIT = 500 -- Same as base game overkill.
	self.crate_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.crate_turret_module.FIRE_DMG_MUL = 0.1
	self.crate_turret_module.BAG_DMG_MUL = 100
	self.crate_turret_module.SHIELD_DMG_MUL = 1
	self.crate_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.crate_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.crate_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.crate_turret_module.CLIP_SIZE = 200 -- reduced due to locations used being mostly close range.
	self.crate_turret_module.AUTO_REPAIR = false
	self.crate_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.crate_turret_module.AUTO_REPAIR_DURATION = 1
	self.crate_turret_module.AUTO_RELOAD_DURATION = 8
	self.crate_turret_module.CAN_GO_IDLE = false
	self.crate_turret_module.IDLE_WAIT_TIME = 1
	
	--unusual variants in base game files; may or may not be used.
	self.ceiling_turret_module_no_idle = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range.CAN_GO_IDLE = false
	self.ceiling_turret_module_longer_range.FIRE_RANGE = 30000
	self.ceiling_turret_module_longer_range.DETECTION_RANGE = self.ceiling_turret_module_longer_range.FIRE_RANGE
	
	-- AA turret; used on Henry's Rock.
	self.aa_turret_module.HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.SHIELD_HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.EXPLOSION_DMG_MUL = 0
	self.aa_turret_module.FIRE_DMG_MUL = 0
	self.aa_turret_module.BAG_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DAMAGE_CLAMP = 10
	self.aa_turret_module.BODY_DAMAGE_CLAMP = 10
	self.aa_turret_module.DAMAGE = 2.0
	self.aa_turret_module.CLIP_SIZE = 300
	self.aa_turret_module.AUTO_REPAIR = true 
	self.aa_turret_module.AUTO_REPAIR_MAX_COUNT = 999
	self.aa_turret_module.AUTO_REPAIR_DURATION = 30
	self.aa_turret_module.AUTO_RELOAD_DURATION = 8
	self.aa_turret_module.CAN_GO_IDLE = false
	self.aa_turret_module.IDLE_WAIT_TIME = 10
	
else
	
--regular OVERKILL turret stats
	self.swat_van_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 300 -- Same as CD.
	self.swat_van_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.swat_van_turret_module.FIRE_DMG_MUL = 0.1
	self.swat_van_turret_module.BAG_DMG_MUL = 100
	self.swat_van_turret_module.SHIELD_DMG_MUL = 1
	self.swat_van_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.swat_van_turret_module.BODY_DAMAGE_CLAMP = 4200
	self.swat_van_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.swat_van_turret_module.CLIP_SIZE = 300 -- compare base game stat, 400.
	self.swat_van_turret_module.AUTO_REPAIR = true
	self.swat_van_turret_module.AUTO_REPAIR_MAX_COUNT = 1 -- Reduced repair count for FBI.
	self.swat_van_turret_module.AUTO_REPAIR_DURATION = 30
	self.swat_van_turret_module.AUTO_RELOAD_DURATION = 8
	self.swat_van_turret_module.CAN_GO_IDLE = true
	self.swat_van_turret_module.IDLE_WAIT_TIME = 10
	
	--Ceiling turrets.
	self.ceiling_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 500 -- Same as base game overkill.
	self.ceiling_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.ceiling_turret_module.FIRE_DMG_MUL = 0.1
	self.ceiling_turret_module.BAG_DMG_MUL = 100
	self.ceiling_turret_module.SHIELD_DMG_MUL = 1
	self.ceiling_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.ceiling_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.ceiling_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.ceiling_turret_module.CLIP_SIZE = 300 -- compare base game stat, 400.
	self.ceiling_turret_module.AUTO_REPAIR = false
	self.ceiling_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.ceiling_turret_module.AUTO_REPAIR_DURATION = 1
	self.ceiling_turret_module.AUTO_RELOAD_DURATION = 8
	self.ceiling_turret_module.CAN_GO_IDLE = false
	self.ceiling_turret_module.IDLE_WAIT_TIME = 1
	
	--Crate turrets. Clone Ceiling turrets with slight revisions.
	self.crate_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.crate_turret_module.SHIELD_HEALTH_INIT = 500 -- Same as base game overkill.
	self.crate_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.crate_turret_module.FIRE_DMG_MUL = 0.1
	self.crate_turret_module.BAG_DMG_MUL = 100
	self.crate_turret_module.SHIELD_DMG_MUL = 1
	self.crate_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.crate_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.crate_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.crate_turret_module.CLIP_SIZE = 200 -- reduced due to locations used being mostly close range.
	self.crate_turret_module.AUTO_REPAIR = false
	self.crate_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.crate_turret_module.AUTO_REPAIR_DURATION = 1
	self.crate_turret_module.AUTO_RELOAD_DURATION = 8
	self.crate_turret_module.CAN_GO_IDLE = false
	self.crate_turret_module.IDLE_WAIT_TIME = 1
	
	--unusual variants in base game files; may or may not be used.
	self.ceiling_turret_module_no_idle = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range.CAN_GO_IDLE = false
	self.ceiling_turret_module_longer_range.FIRE_RANGE = 30000
	self.ceiling_turret_module_longer_range.DETECTION_RANGE = self.ceiling_turret_module_longer_range.FIRE_RANGE
	
	-- AA turret; used on Henry's Rock.
	self.aa_turret_module.HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.SHIELD_HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.EXPLOSION_DMG_MUL = 0
	self.aa_turret_module.FIRE_DMG_MUL = 0
	self.aa_turret_module.BAG_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DAMAGE_CLAMP = 10
	self.aa_turret_module.BODY_DAMAGE_CLAMP = 10
	self.aa_turret_module.DAMAGE = 2.0
	self.aa_turret_module.CLIP_SIZE = 300
	self.aa_turret_module.AUTO_REPAIR = true 
	self.aa_turret_module.AUTO_REPAIR_MAX_COUNT = 999
	self.aa_turret_module.AUTO_REPAIR_DURATION = 30
	self.aa_turret_module.AUTO_RELOAD_DURATION = 8
	self.aa_turret_module.CAN_GO_IDLE = false
	self.aa_turret_module.IDLE_WAIT_TIME = 10
	end
end

-- Begin MAYHEM difficulty damage values. 

function WeaponTweakData:_set_easy_wish()
	--Rifles
	self.m4_npc.DAMAGE = 7.5		-- Heavy SWAT Riflemen. Mapped to heavy AR.
	self.g36_npc.DAMAGE = 6		-- Light SWAT Riflemen, possibly. Mapped to light AR.
	self.ump_npc.DAMAGE = 6		-- Light SWAT Riflemen, possibly. Mapped to light AR.
	self.akmsu_smg_npc.DAMAGE = 6		-- Light SWAT Riflemen, possibly. Mapped to light AR, Akan.
	self.ak47_ass_npc.DAMAGE = 6 -- possibly unused aside from akan. Mapped to light AR.
	self.ak47_npc.DAMAGE = 7.5	-- possibly used by mobster units. Map to heavy AR.
	self.scar_npc.DAMAGE = 6 --Scripted murky units, possibly useful for later custom units? Mapped to light AR.
	
	--Shotguns
	self.r870_npc.DAMAGE = 7.5	-- Light SWAT Shotgunners. Mapped to Light Shotgun.
	self.benelli_npc.DAMAGE = 10 -- Heavy SWAT Shotgunners. Mapped to Heavy Shotgun.
	
	--Unique/Special Weapons (scripted, special enemies, bosses)
	self.contraband_npc.DAMAGE = 9   -- apparently used exclusively by Sosa. Draft value up one tier from heavy AR.
	self.x_c45_npc.DAMAGE = 8	-- chavez weapon. Check name and syntax. Draft map to medic revolver + 20.
	
	self.m4_yellow_npc.DAMAGE = 6	-- populates taser damage after other fixes applied. Map to light AR.
	
	self.mossberg_npc.DAMAGE = 24 --temporary Greendozer Shotgun, not enough shotguns to map to all units, consider Bulldozer-specific weapon presets?
	self.saiga_npc.DAMAGE = 18 --Blackdozer Saiga, mapped to Deathvox Blackdozer.
	self.m249_npc.DAMAGE = 10 --LMGDozer M249, has is_rifle behavior, needs to have it's usage changed. consider Bulldozer-specific weapon presets?
	self.rpk_lmg_npc.DAMAGE = 10 --LMGDozer M249, AKAN faction, has is_rifle behavior, normal M249.
	self.s552_npc.DAMAGE = 7.5 --No info on what or who uses it, so it might be better used as the MedicDozer weapon, damage mapped as such, unsure whether it actually exists as a weapon in the game's files, however.
	
	self.mp5_tactical_npc.DAMAGE = 6 --Used by Cloaker, mapped to Deathvox Cloaker SMG.
	self.asval_smg_npc.DAMAGE = 6 --Used by Akan Cloaker, mapped to Deathvox Cloaker SMG.
	
--	self.m14_npc.DAMAGE = 3		-- possibly unused.
	self.m14_sniper_npc.DAMAGE = 20	-- sniper damage, set according to table.
	self.m14_sniper_npc.sniper_trail = true
	self.deathvox_sniper.sniper_trail = true
	self.m14_sniper_npc.use_laser = false
    self.m14_sniper_npc.disable_sniper_laser = true
	
	self.mp5_npc.DAMAGE = 6	-- smg used by number of units. Map to cop smg.
	self.mp9_npc.DAMAGE = 6	-- shield only.	Map to cop smg.
	self.c45_npc.DAMAGE = 2		-- pistol used by variety of units. Draft map to cop pistol.
	self.raging_bull_npc.DAMAGE = 6	-- bronco used by variety of units. Draft map to cop revolver. Make sure no armor pierce.
	self.mac11_npc.DAMAGE = 4.5	-- smg used by number of criminal units. Map to cop smg.
	self.smoke_npc.DAMAGE = 7.5	-- vit secret enemy weapon. Map to Heavy AR.
--	self.mini_npc.DAMAGE = 10	-- minigun damage. Used only for specific scripted enemies. Draft value assumes general lmg usage.
	
-- below code is goofball legacy believed to reinitialize enemy melee values.	
	self.npc_melee.baton.damage = 5
	self.npc_melee.knife_1.damage = 7
	self.npc_melee.fists.damage = 4
-- end goofball legacy code block.
	
-- Begin MAYHEM Turret values.
if managers.skirmish and managers.skirmish:is_skirmish() then
		
	self.swat_van_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 300 -- Same as CD.
	self.swat_van_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.swat_van_turret_module.FIRE_DMG_MUL = 0.1
	self.swat_van_turret_module.BAG_DMG_MUL = 100
	self.swat_van_turret_module.SHIELD_DMG_MUL = 1
	self.swat_van_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.swat_van_turret_module.BODY_DAMAGE_CLAMP = 4200
	self.swat_van_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.swat_van_turret_module.CLIP_SIZE = 300 -- compare base game stat, 400.
	self.swat_van_turret_module.AUTO_REPAIR = true
	self.swat_van_turret_module.AUTO_REPAIR_MAX_COUNT = 1 -- Reduced repair count for FBI.
	self.swat_van_turret_module.AUTO_REPAIR_DURATION = 30
	self.swat_van_turret_module.AUTO_RELOAD_DURATION = 8
	self.swat_van_turret_module.CAN_GO_IDLE = true
	self.swat_van_turret_module.IDLE_WAIT_TIME = 10
	
	--Ceiling turrets.
	self.ceiling_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 500 -- Same as base game overkill.
	self.ceiling_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.ceiling_turret_module.FIRE_DMG_MUL = 0.1
	self.ceiling_turret_module.BAG_DMG_MUL = 100
	self.ceiling_turret_module.SHIELD_DMG_MUL = 1
	self.ceiling_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.ceiling_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.ceiling_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.ceiling_turret_module.CLIP_SIZE = 300 -- compare base game stat, 400.
	self.ceiling_turret_module.AUTO_REPAIR = false
	self.ceiling_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.ceiling_turret_module.AUTO_REPAIR_DURATION = 1
	self.ceiling_turret_module.AUTO_RELOAD_DURATION = 8
	self.ceiling_turret_module.CAN_GO_IDLE = false
	self.ceiling_turret_module.IDLE_WAIT_TIME = 1
	
	--Crate turrets. Clone Ceiling turrets with slight revisions.
	self.crate_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.crate_turret_module.SHIELD_HEALTH_INIT = 500 -- Same as base game overkill.
	self.crate_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.crate_turret_module.FIRE_DMG_MUL = 0.1
	self.crate_turret_module.BAG_DMG_MUL = 100
	self.crate_turret_module.SHIELD_DMG_MUL = 1
	self.crate_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.crate_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.crate_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.crate_turret_module.CLIP_SIZE = 200 -- reduced due to locations used being mostly close range.
	self.crate_turret_module.AUTO_REPAIR = false
	self.crate_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.crate_turret_module.AUTO_REPAIR_DURATION = 1
	self.crate_turret_module.AUTO_RELOAD_DURATION = 8
	self.crate_turret_module.CAN_GO_IDLE = false
	self.crate_turret_module.IDLE_WAIT_TIME = 1
	
	--unusual variants in base game files; may or may not be used.
	self.ceiling_turret_module_no_idle = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range.CAN_GO_IDLE = false
	self.ceiling_turret_module_longer_range.FIRE_RANGE = 30000
	self.ceiling_turret_module_longer_range.DETECTION_RANGE = self.ceiling_turret_module_longer_range.FIRE_RANGE
	
	-- AA turret; used on Henry's Rock.
	self.aa_turret_module.HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.SHIELD_HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.EXPLOSION_DMG_MUL = 0
	self.aa_turret_module.FIRE_DMG_MUL = 0
	self.aa_turret_module.BAG_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DAMAGE_CLAMP = 10
	self.aa_turret_module.BODY_DAMAGE_CLAMP = 10
	self.aa_turret_module.DAMAGE = 2.0
	self.aa_turret_module.CLIP_SIZE = 300
	self.aa_turret_module.AUTO_REPAIR = true 
	self.aa_turret_module.AUTO_REPAIR_MAX_COUNT = 999
	self.aa_turret_module.AUTO_REPAIR_DURATION = 30
	self.aa_turret_module.AUTO_RELOAD_DURATION = 8
	self.aa_turret_module.CAN_GO_IDLE = false
	self.aa_turret_module.IDLE_WAIT_TIME = 10
	
else
	
--regular MAYHEM turret stats
	self.swat_van_turret_module.HEALTH_INIT = 30000 -- compare 400k base game.
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 300 -- Same as CD, "vivinite" shield.
	self.swat_van_turret_module.EXPLOSION_DMG_MUL = 3 -- Same as CD, "vivinite" shield.
	self.swat_van_turret_module.FIRE_DMG_MUL = 0.1
	self.swat_van_turret_module.BAG_DMG_MUL = 100
	self.swat_van_turret_module.SHIELD_DMG_MUL = 1
	self.swat_van_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.swat_van_turret_module.BODY_DAMAGE_CLAMP = 4200
	self.swat_van_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.swat_van_turret_module.CLIP_SIZE = 400 -- compare base game stat, 800.
	self.swat_van_turret_module.AUTO_REPAIR = true
	self.swat_van_turret_module.AUTO_REPAIR_MAX_COUNT = 2 -- same as base game.
	self.swat_van_turret_module.AUTO_REPAIR_DURATION = 30
	self.swat_van_turret_module.AUTO_RELOAD_DURATION = 8
	self.swat_van_turret_module.CAN_GO_IDLE = true
	self.swat_van_turret_module.IDLE_WAIT_TIME = 10
	
	--Ceiling turrets.
	self.ceiling_turret_module.HEALTH_INIT = 30000 -- compare 400k base game.
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 700 -- Same as CD, "vivinite" shield.
	self.ceiling_turret_module.EXPLOSION_DMG_MUL = 3 -- base game value is 7
	self.ceiling_turret_module.FIRE_DMG_MUL = 0.1
	self.ceiling_turret_module.BAG_DMG_MUL = 100
	self.ceiling_turret_module.SHIELD_DMG_MUL = 1
	self.ceiling_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.ceiling_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.ceiling_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.ceiling_turret_module.CLIP_SIZE = 400 -- compare base game stat, 800.
	self.ceiling_turret_module.AUTO_REPAIR = false
	self.ceiling_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.ceiling_turret_module.AUTO_REPAIR_DURATION = 1
	self.ceiling_turret_module.AUTO_RELOAD_DURATION = 8
	self.ceiling_turret_module.CAN_GO_IDLE = false
	self.ceiling_turret_module.IDLE_WAIT_TIME = 1
	
	--Crate turrets. Clone Ceiling turrets with slight revisions.
	self.crate_turret_module.HEALTH_INIT = 30000 -- compare 400k base game.
	self.crate_turret_module.SHIELD_HEALTH_INIT = 700 -- Same as CD, "vivinite" shield.
	self.crate_turret_module.EXPLOSION_DMG_MUL = 3 -- base game value is 7
	self.crate_turret_module.FIRE_DMG_MUL = 0.1
	self.crate_turret_module.BAG_DMG_MUL = 100
	self.crate_turret_module.SHIELD_DMG_MUL = 1
	self.crate_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.crate_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.crate_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.crate_turret_module.CLIP_SIZE = 250 -- reduced due to locations used being mostly close range.
	self.crate_turret_module.AUTO_REPAIR = false
	self.crate_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.crate_turret_module.AUTO_REPAIR_DURATION = 1
	self.crate_turret_module.AUTO_RELOAD_DURATION = 8
	self.crate_turret_module.CAN_GO_IDLE = false
	self.crate_turret_module.IDLE_WAIT_TIME = 1
	
	--unusual variants in base game files; may or may not be used.
	self.ceiling_turret_module_no_idle = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range.CAN_GO_IDLE = false
	self.ceiling_turret_module_longer_range.FIRE_RANGE = 30000
	self.ceiling_turret_module_longer_range.DETECTION_RANGE = self.ceiling_turret_module_longer_range.FIRE_RANGE
	
	-- AA turret; used on Henry's Rock.
	self.aa_turret_module.HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.SHIELD_HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.EXPLOSION_DMG_MUL = 0
	self.aa_turret_module.FIRE_DMG_MUL = 0
	self.aa_turret_module.BAG_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DAMAGE_CLAMP = 10
	self.aa_turret_module.BODY_DAMAGE_CLAMP = 10
	self.aa_turret_module.DAMAGE = 2.0
	self.aa_turret_module.CLIP_SIZE = 400
	self.aa_turret_module.AUTO_REPAIR = true 
	self.aa_turret_module.AUTO_REPAIR_MAX_COUNT = 999
	self.aa_turret_module.AUTO_REPAIR_DURATION = 30
	self.aa_turret_module.AUTO_RELOAD_DURATION = 8
	self.aa_turret_module.CAN_GO_IDLE = false
	self.aa_turret_module.IDLE_WAIT_TIME = 10	
	end
end

-- Begin DEATHWISH difficulty damage values. 

function WeaponTweakData:_set_overkill_290()
	--Rifles
	self.m4_npc.DAMAGE = 7.5		-- Heavy SWAT Riflemen. Mapped to heavy AR.
	self.g36_npc.DAMAGE = 6		-- Light SWAT Riflemen, possibly. Mapped to light AR.
	self.ump_npc.DAMAGE = 6		-- Light SWAT Riflemen, possibly. Mapped to light AR.
	self.akmsu_smg_npc.DAMAGE = 6		-- Light SWAT Riflemen, possibly. Mapped to light AR, Akan.
	self.ak47_ass_npc.DAMAGE = 6 -- possibly unused aside from akan. Mapped to light AR.
	self.ak47_npc.DAMAGE = 7.5	-- possibly used by mobster units. Map to heavy AR.
	self.scar_npc.DAMAGE = 6 --Scripted murky units, possibly useful for later custom units? Mapped to light AR.
	
	--Shotguns
	self.r870_npc.DAMAGE = 7.5	-- Light SWAT Shotgunners. Mapped to Light Shotgun.
	self.benelli_npc.DAMAGE = 10 -- Heavy SWAT Shotgunners. Mapped to Heavy Shotgun.
	
	--Unique/Special Weapons (scripted, special enemies, bosses)
	self.contraband_npc.DAMAGE = 9   -- apparently used exclusively by Sosa. Draft value up one tier from heavy AR.
	self.x_c45_npc.DAMAGE = 8	-- chavez weapon. Check name and syntax. Draft map to medic revolver + 20.
	
	self.m4_yellow_npc.DAMAGE = 6	-- populates taser damage after other fixes applied. Map to light AR.
	
	self.mossberg_npc.DAMAGE = 24 --temporary Greendozer Shotgun, not enough shotguns to map to all units, consider Bulldozer-specific weapon presets?
	self.saiga_npc.DAMAGE = 18 --Blackdozer Saiga, mapped to Deathvox Blackdozer.
	self.m249_npc.DAMAGE = 10 --LMGDozer M249, has is_rifle behavior, needs to have it's usage changed. consider Bulldozer-specific weapon presets?
	self.rpk_lmg_npc.DAMAGE = 10 --LMGDozer M249, AKAN faction, has is_rifle behavior, normal M249.
	self.s552_npc.DAMAGE = 7.5 --No info on what or who uses it, so it might be better used as the MedicDozer weapon, damage mapped as such, unsure whether it actually exists as a weapon in the game's files, however.
	
	self.mp5_tactical_npc.DAMAGE = 6 --Used by Cloaker, mapped to Deathvox Cloaker SMG.
	self.asval_smg_npc.DAMAGE = 6 --Used by Akan Cloaker, mapped to Deathvox Cloaker SMG.
	
--	self.m14_npc.DAMAGE = 3		-- possibly unused.
	self.m14_sniper_npc.DAMAGE = 20	-- sniper damage, set according to table.
	self.m14_sniper_npc.sniper_trail = true
	self.deathvox_sniper.sniper_trail = true
	self.m14_sniper_npc.use_laser = false
    self.m14_sniper_npc.disable_sniper_laser = true
	
	self.mp5_npc.DAMAGE = 6	-- smg used by number of units. Map to cop smg.
	self.mp9_npc.DAMAGE = 6	-- shield only.	Map to cop smg.
	self.c45_npc.DAMAGE = 2		-- pistol used by variety of units. Draft map to cop pistol.
	self.raging_bull_npc.DAMAGE = 6	-- bronco used by variety of units. Draft map to cop revolver. Make sure no armor pierce.
	self.mac11_npc.DAMAGE = 4.5	-- smg used by number of criminal units. Map to cop smg.
	self.smoke_npc.DAMAGE = 7.5	-- vit secret enemy weapon. Map to Heavy AR.
--	self.mini_npc.DAMAGE = 10	-- minigun damage. Used only for specific scripted enemies. Draft value assumes general lmg usage.
	
-- below code is goofball legacy believed to reinitialize enemy melee values.	
	self.npc_melee.baton.damage = 5
	self.npc_melee.knife_1.damage = 7
	self.npc_melee.fists.damage = 4
-- end goofball legacy code block.

-- Begin DEATHWISH Turret values.
if managers.skirmish and managers.skirmish:is_skirmish() then
		
	self.swat_van_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 300 -- Same as CD.
	self.swat_van_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.swat_van_turret_module.FIRE_DMG_MUL = 0.1
	self.swat_van_turret_module.BAG_DMG_MUL = 100
	self.swat_van_turret_module.SHIELD_DMG_MUL = 1
	self.swat_van_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.swat_van_turret_module.BODY_DAMAGE_CLAMP = 4200
	self.swat_van_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.swat_van_turret_module.CLIP_SIZE = 300 -- compare base game stat, 400.
	self.swat_van_turret_module.AUTO_REPAIR = true
	self.swat_van_turret_module.AUTO_REPAIR_MAX_COUNT = 1 -- Reduced repair count for FBI.
	self.swat_van_turret_module.AUTO_REPAIR_DURATION = 30
	self.swat_van_turret_module.AUTO_RELOAD_DURATION = 8
	self.swat_van_turret_module.CAN_GO_IDLE = true
	self.swat_van_turret_module.IDLE_WAIT_TIME = 10
	
	--Ceiling turrets.
	self.ceiling_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 500 -- Same as base game overkill.
	self.ceiling_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.ceiling_turret_module.FIRE_DMG_MUL = 0.1
	self.ceiling_turret_module.BAG_DMG_MUL = 100
	self.ceiling_turret_module.SHIELD_DMG_MUL = 1
	self.ceiling_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.ceiling_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.ceiling_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.ceiling_turret_module.CLIP_SIZE = 300 -- compare base game stat, 400.
	self.ceiling_turret_module.AUTO_REPAIR = false
	self.ceiling_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.ceiling_turret_module.AUTO_REPAIR_DURATION = 1
	self.ceiling_turret_module.AUTO_RELOAD_DURATION = 8
	self.ceiling_turret_module.CAN_GO_IDLE = false
	self.ceiling_turret_module.IDLE_WAIT_TIME = 1
	
	--Crate turrets. Clone Ceiling turrets with slight revisions.
	self.crate_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.crate_turret_module.SHIELD_HEALTH_INIT = 500 -- Same as base game overkill.
	self.crate_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.crate_turret_module.FIRE_DMG_MUL = 0.1
	self.crate_turret_module.BAG_DMG_MUL = 100
	self.crate_turret_module.SHIELD_DMG_MUL = 1
	self.crate_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.crate_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.crate_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.crate_turret_module.CLIP_SIZE = 200 -- reduced due to locations used being mostly close range.
	self.crate_turret_module.AUTO_REPAIR = false
	self.crate_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.crate_turret_module.AUTO_REPAIR_DURATION = 1
	self.crate_turret_module.AUTO_RELOAD_DURATION = 8
	self.crate_turret_module.CAN_GO_IDLE = false
	self.crate_turret_module.IDLE_WAIT_TIME = 1
	
	--unusual variants in base game files; may or may not be used.
	self.ceiling_turret_module_no_idle = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range.CAN_GO_IDLE = false
	self.ceiling_turret_module_longer_range.FIRE_RANGE = 30000
	self.ceiling_turret_module_longer_range.DETECTION_RANGE = self.ceiling_turret_module_longer_range.FIRE_RANGE
	
	-- AA turret; used on Henry's Rock.
	self.aa_turret_module.HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.SHIELD_HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.EXPLOSION_DMG_MUL = 0
	self.aa_turret_module.FIRE_DMG_MUL = 0
	self.aa_turret_module.BAG_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DAMAGE_CLAMP = 10
	self.aa_turret_module.BODY_DAMAGE_CLAMP = 10
	self.aa_turret_module.DAMAGE = 2.0
	self.aa_turret_module.CLIP_SIZE = 300
	self.aa_turret_module.AUTO_REPAIR = true 
	self.aa_turret_module.AUTO_REPAIR_MAX_COUNT = 999
	self.aa_turret_module.AUTO_REPAIR_DURATION = 30
	self.aa_turret_module.AUTO_RELOAD_DURATION = 8
	self.aa_turret_module.CAN_GO_IDLE = false
	self.aa_turret_module.IDLE_WAIT_TIME = 10
	
else
	
--regular DEATHWISH turret stats
	self.swat_van_turret_module.HEALTH_INIT = 30000 -- compare 400k base game.
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 300 -- Same as CD, "vivinite" shield.
	self.swat_van_turret_module.EXPLOSION_DMG_MUL = 3 -- Same as CD, "vivinite" shield.
	self.swat_van_turret_module.FIRE_DMG_MUL = 0.1
	self.swat_van_turret_module.BAG_DMG_MUL = 100
	self.swat_van_turret_module.SHIELD_DMG_MUL = 1
	self.swat_van_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.swat_van_turret_module.BODY_DAMAGE_CLAMP = 4200
	self.swat_van_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.swat_van_turret_module.CLIP_SIZE = 400 -- compare base game stat, 800.
	self.swat_van_turret_module.AUTO_REPAIR = true
	self.swat_van_turret_module.AUTO_REPAIR_MAX_COUNT = 2 -- same as base game.
	self.swat_van_turret_module.AUTO_REPAIR_DURATION = 30
	self.swat_van_turret_module.AUTO_RELOAD_DURATION = 8
	self.swat_van_turret_module.CAN_GO_IDLE = true
	self.swat_van_turret_module.IDLE_WAIT_TIME = 10
	
	--Ceiling turrets.
	self.ceiling_turret_module.HEALTH_INIT = 30000 -- compare 400k base game.
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 700 -- Same as CD, "vivinite" shield.
	self.ceiling_turret_module.EXPLOSION_DMG_MUL = 3 -- base game value is 7
	self.ceiling_turret_module.FIRE_DMG_MUL = 0.1
	self.ceiling_turret_module.BAG_DMG_MUL = 100
	self.ceiling_turret_module.SHIELD_DMG_MUL = 1
	self.ceiling_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.ceiling_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.ceiling_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.ceiling_turret_module.CLIP_SIZE = 400 -- compare base game stat, 800.
	self.ceiling_turret_module.AUTO_REPAIR = false
	self.ceiling_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.ceiling_turret_module.AUTO_REPAIR_DURATION = 1
	self.ceiling_turret_module.AUTO_RELOAD_DURATION = 8
	self.ceiling_turret_module.CAN_GO_IDLE = false
	self.ceiling_turret_module.IDLE_WAIT_TIME = 1
	
	--Crate turrets. Clone Ceiling turrets with slight revisions.
	self.crate_turret_module.HEALTH_INIT = 30000 -- compare 400k base game.
	self.crate_turret_module.SHIELD_HEALTH_INIT = 700 -- Same as CD, "vivinite" shield.
	self.crate_turret_module.EXPLOSION_DMG_MUL = 3 -- base game value is 7
	self.crate_turret_module.FIRE_DMG_MUL = 0.1
	self.crate_turret_module.BAG_DMG_MUL = 100
	self.crate_turret_module.SHIELD_DMG_MUL = 1
	self.crate_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.crate_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.crate_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.crate_turret_module.CLIP_SIZE = 250 -- reduced due to locations used being mostly close range.
	self.crate_turret_module.AUTO_REPAIR = false
	self.crate_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.crate_turret_module.AUTO_REPAIR_DURATION = 1
	self.crate_turret_module.AUTO_RELOAD_DURATION = 8
	self.crate_turret_module.CAN_GO_IDLE = false
	self.crate_turret_module.IDLE_WAIT_TIME = 1
	
	--unusual variants in base game files; may or may not be used.
	self.ceiling_turret_module_no_idle = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range.CAN_GO_IDLE = false
	self.ceiling_turret_module_longer_range.FIRE_RANGE = 30000
	self.ceiling_turret_module_longer_range.DETECTION_RANGE = self.ceiling_turret_module_longer_range.FIRE_RANGE
	
	-- AA turret; used on Henry's Rock.
	self.aa_turret_module.HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.SHIELD_HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.EXPLOSION_DMG_MUL = 0
	self.aa_turret_module.FIRE_DMG_MUL = 0
	self.aa_turret_module.BAG_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DAMAGE_CLAMP = 10
	self.aa_turret_module.BODY_DAMAGE_CLAMP = 10
	self.aa_turret_module.DAMAGE = 2.0
	self.aa_turret_module.CLIP_SIZE = 400
	self.aa_turret_module.AUTO_REPAIR = true 
	self.aa_turret_module.AUTO_REPAIR_MAX_COUNT = 999
	self.aa_turret_module.AUTO_REPAIR_DURATION = 30
	self.aa_turret_module.AUTO_RELOAD_DURATION = 8
	self.aa_turret_module.CAN_GO_IDLE = false
	self.aa_turret_module.IDLE_WAIT_TIME = 10
	end
end

-- Begin CRACKDOWN difficulty damage values. 

function WeaponTweakData:_set_sm_wish() 
	--Rifles
	self.m4_npc.DAMAGE = 9	-- Heavy SWAT Riflemen. Mapped to heavy AR.
	self.g36_npc.DAMAGE = 7.5		-- Light SWAT Riflemen, possibly. Mapped to light AR.
	self.ump_npc.DAMAGE = 7.5		-- Light SWAT Riflemen, possibly. Mapped to light AR.
	self.akmsu_smg_npc.DAMAGE = 7.5		-- Light SWAT Riflemen, possibly. Mapped to light AR, Akan.
	self.ak47_ass_npc.DAMAGE = 7.5 -- possibly unused aside from akan. Mapped to light AR.
	self.ak47_npc.DAMAGE = 9	-- possibly used by mobster units. Map to heavy AR.
	self.scar_npc.DAMAGE = 7.5 --Scripted murky units, possibly useful for later custom units? Mapped to light AR.
	
	--Shotguns
	self.r870_npc.DAMAGE = 9	-- Light SWAT Shotgunners. Mapped to Light Shotgun.
	self.benelli_npc.DAMAGE = 11 -- Heavy SWAT Shotgunners. Mapped to Heavy Shotgun.
	
	--Unique/Special Weapons (scripted, special enemies, bosses)
	self.contraband_npc.DAMAGE = 11  -- apparently used exclusively by Sosa. Heavy AR + 20.
	self.x_c45_npc.DAMAGE = 10	-- chavez weapon. Check name and syntax. Draft map to medic revolver + 20.
	
	self.m4_yellow_npc.DAMAGE = 7.5	-- populates taser damage after other fixes applied. Map to light AR.
	
	self.mossberg_npc.DAMAGE = 50 --temporary Greendozer Shotgun. not enough shotguns to map to all units, consider Bulldozer-specific weapon presets?
	self.saiga_npc.DAMAGE = 22.5 --Blackdozer Saiga, mapped to Deathvox Blackdozer.
	self.m249_npc.DAMAGE = 12 --LMGDozer M249, has is_rifle behavior, needs to have it's usage changed. consider Bulldozer-specific weapon presets?
	self.rpk_lmg_npc.DAMAGE = 10 --LMGDozer M249, AKAN faction, has is_rifle behavior, normal M249.
	self.s552_npc.DAMAGE = 7.5 --No info on what or who uses it, so it might be better used as the MedicDozer weapon, damage mapped as such, unsure whether it actually exists as a weapon in the game's files, however.
	
	self.mp5_tactical_npc.DAMAGE = 7.5 --Used by Cloaker, mapped to Deathvox Cloaker SMG.
	self.asval_smg_npc.DAMAGE = 7.5 --Used by Akan Cloaker, mapped to Deathvox Cloaker SMG.
	
--	self.m14_npc.DAMAGE = 3		-- possibly unused.
	self.m14_sniper_npc.DAMAGE = 24	-- sniper damage, set according to table
	--Sniper Trail for Snipers
	self.m14_sniper_npc.sniper_trail = true
	self.deathvox_sniper.sniper_trail = true
	self.m14_sniper_npc.use_laser = false
    self.m14_sniper_npc.disable_sniper_laser = true
	
	
	self.mp5_npc.DAMAGE = 7.5	-- smg used by number of units. Map to cop smg.
	self.mp9_npc.DAMAGE = 7.5	-- shield only.	Map to cop smg.
	self.c45_npc.DAMAGE = 6		-- pistol used by variety of units. Draft map to cop pistol.
	self.raging_bull_npc.DAMAGE = 8	-- bronco used by variety of units. Draft map to cop revolver. Make sure no armor pierce.
	self.mac11_npc.DAMAGE = 7.5	-- smg used by number of criminal units. Map to cop smg.
	self.smoke_npc.DAMAGE = 9	-- vit secret enemy weapon. Map to Heavy AR.
--	self.mini_npc.DAMAGE = 10	-- minigun damage. Used only for specific scripted enemies. Draft value assumes general lmg usage.
	
-- below code is goofball legacy believed to reinitialize enemy melee values.	
	self.npc_melee.baton.damage = 5
	self.npc_melee.knife_1.damage = 7
	self.npc_melee.fists.damage = 4
-- end goofball legacy code block.
-- Begin CRACKDOWN Turret values.
if managers.skirmish and managers.skirmish:is_skirmish() then
		
	self.swat_van_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 300 -- Same as CD.
	self.swat_van_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.swat_van_turret_module.FIRE_DMG_MUL = 0.1
	self.swat_van_turret_module.BAG_DMG_MUL = 100
	self.swat_van_turret_module.SHIELD_DMG_MUL = 1
	self.swat_van_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.swat_van_turret_module.BODY_DAMAGE_CLAMP = 4200
	self.swat_van_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.swat_van_turret_module.CLIP_SIZE = 300 -- compare base game stat, 400.
	self.swat_van_turret_module.AUTO_REPAIR = true
	self.swat_van_turret_module.AUTO_REPAIR_MAX_COUNT = 1 -- Reduced repair count for FBI.
	self.swat_van_turret_module.AUTO_REPAIR_DURATION = 30
	self.swat_van_turret_module.AUTO_RELOAD_DURATION = 8
	self.swat_van_turret_module.CAN_GO_IDLE = true
	self.swat_van_turret_module.IDLE_WAIT_TIME = 10
	
	--Ceiling turrets.
	self.ceiling_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 500 -- Same as base game overkill.
	self.ceiling_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.ceiling_turret_module.FIRE_DMG_MUL = 0.1
	self.ceiling_turret_module.BAG_DMG_MUL = 100
	self.ceiling_turret_module.SHIELD_DMG_MUL = 1
	self.ceiling_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.ceiling_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.ceiling_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.ceiling_turret_module.CLIP_SIZE = 300 -- compare base game stat, 400.
	self.ceiling_turret_module.AUTO_REPAIR = false
	self.ceiling_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.ceiling_turret_module.AUTO_REPAIR_DURATION = 1
	self.ceiling_turret_module.AUTO_RELOAD_DURATION = 8
	self.ceiling_turret_module.CAN_GO_IDLE = false
	self.ceiling_turret_module.IDLE_WAIT_TIME = 1
	
	--Crate turrets. Clone Ceiling turrets with slight revisions.
	self.crate_turret_module.HEALTH_INIT = 20000 -- compare 250k base game.
	self.crate_turret_module.SHIELD_HEALTH_INIT = 500 -- Same as base game overkill.
	self.crate_turret_module.EXPLOSION_DMG_MUL = 5 -- reduced XP mult versus SWAT tier.
	self.crate_turret_module.FIRE_DMG_MUL = 0.1
	self.crate_turret_module.BAG_DMG_MUL = 100
	self.crate_turret_module.SHIELD_DMG_MUL = 1
	self.crate_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.crate_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.crate_turret_module.DAMAGE = 2.0	-- same as base game overkill.
	self.crate_turret_module.CLIP_SIZE = 200 -- reduced due to locations used being mostly close range.
	self.crate_turret_module.AUTO_REPAIR = false
	self.crate_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.crate_turret_module.AUTO_REPAIR_DURATION = 1
	self.crate_turret_module.AUTO_RELOAD_DURATION = 8
	self.crate_turret_module.CAN_GO_IDLE = false
	self.crate_turret_module.IDLE_WAIT_TIME = 1
	
	--unusual variants in base game files; may or may not be used.
	self.ceiling_turret_module_no_idle = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range.CAN_GO_IDLE = false
	self.ceiling_turret_module_longer_range.FIRE_RANGE = 30000
	self.ceiling_turret_module_longer_range.DETECTION_RANGE = self.ceiling_turret_module_longer_range.FIRE_RANGE
	
	-- AA turret; used on Henry's Rock.
	self.aa_turret_module.HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.SHIELD_HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.EXPLOSION_DMG_MUL = 0
	self.aa_turret_module.FIRE_DMG_MUL = 0
	self.aa_turret_module.BAG_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DAMAGE_CLAMP = 10
	self.aa_turret_module.BODY_DAMAGE_CLAMP = 10
	self.aa_turret_module.DAMAGE = 2.0
	self.aa_turret_module.CLIP_SIZE = 300
	self.aa_turret_module.AUTO_REPAIR = true 
	self.aa_turret_module.AUTO_REPAIR_MAX_COUNT = 999
	self.aa_turret_module.AUTO_REPAIR_DURATION = 30
	self.aa_turret_module.AUTO_RELOAD_DURATION = 8
	self.aa_turret_module.CAN_GO_IDLE = false
	self.aa_turret_module.IDLE_WAIT_TIME = 10
	
else
	
--regular CRACKDOWN turret stats
	self.swat_van_turret_module.HEALTH_INIT = 999999 -- functionally immortal.
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 300
	self.swat_van_turret_module.EXPLOSION_DMG_MUL = 3 -- base game value is 7.
	self.swat_van_turret_module.FIRE_DMG_MUL = 0.1
	self.swat_van_turret_module.BAG_DMG_MUL = 100
	self.swat_van_turret_module.SHIELD_DMG_MUL = 1
	self.swat_van_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.swat_van_turret_module.BODY_DAMAGE_CLAMP = 4200
	self.swat_van_turret_module.DAMAGE = 3.5
	self.swat_van_turret_module.CLIP_SIZE = 500 --reduced from base game stat, 800.
	self.swat_van_turret_module.AUTO_REPAIR = true
	self.swat_van_turret_module.AUTO_REPAIR_MAX_COUNT = 999
	self.swat_van_turret_module.AUTO_REPAIR_DURATION = 30
	self.swat_van_turret_module.AUTO_RELOAD_DURATION = 8
	self.swat_van_turret_module.CAN_GO_IDLE = true
	self.swat_van_turret_module.IDLE_WAIT_TIME = 10
	
	--Ceiling turrets.
	self.ceiling_turret_module.HEALTH_INIT = 40000
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 700
	self.ceiling_turret_module.EXPLOSION_DMG_MUL = 3 -- base game value is 7
	self.ceiling_turret_module.FIRE_DMG_MUL = 0.1
	self.ceiling_turret_module.BAG_DMG_MUL = 100
	self.ceiling_turret_module.SHIELD_DMG_MUL = 1
	self.ceiling_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.ceiling_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.ceiling_turret_module.DAMAGE = 3.5
	self.ceiling_turret_module.CLIP_SIZE = 800
	self.ceiling_turret_module.AUTO_REPAIR = false
	self.ceiling_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.ceiling_turret_module.AUTO_REPAIR_DURATION = 1
	self.ceiling_turret_module.AUTO_RELOAD_DURATION = 8
	self.ceiling_turret_module.CAN_GO_IDLE = false
	self.ceiling_turret_module.IDLE_WAIT_TIME = 1
	
	--Crate turrets. Clone Ceiling turrets with slight revisions.
	self.crate_turret_module.HEALTH_INIT = 40000
	self.crate_turret_module.SHIELD_HEALTH_INIT = 700
	self.crate_turret_module.EXPLOSION_DMG_MUL = 3 -- base game value is 7
	self.crate_turret_module.FIRE_DMG_MUL = 0.1
	self.crate_turret_module.BAG_DMG_MUL = 100
	self.crate_turret_module.SHIELD_DMG_MUL = 1
	self.crate_turret_module.SHIELD_DAMAGE_CLAMP = 350
	self.crate_turret_module.BODY_DAMAGE_CLAMP =  4200
	self.crate_turret_module.DAMAGE = 3.5
	self.crate_turret_module.CLIP_SIZE = 400 -- reduced due to locations used being mostly close range.
	self.crate_turret_module.AUTO_REPAIR = false
	self.crate_turret_module.AUTO_REPAIR_MAX_COUNT = 1
	self.crate_turret_module.AUTO_REPAIR_DURATION = 1
	self.crate_turret_module.AUTO_RELOAD_DURATION = 8
	self.crate_turret_module.CAN_GO_IDLE = false
	self.crate_turret_module.IDLE_WAIT_TIME = 1
	
	--unusual variants in base game files; may or may not be used.
	self.ceiling_turret_module_no_idle = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range.CAN_GO_IDLE = false
	self.ceiling_turret_module_longer_range.FIRE_RANGE = 30000
	self.ceiling_turret_module_longer_range.DETECTION_RANGE = self.ceiling_turret_module_longer_range.FIRE_RANGE
	
	-- AA turret; used on Henry's Rock.
	self.aa_turret_module.HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.SHIELD_HEALTH_INIT = 999999 -- functionally immortal.
	self.aa_turret_module.EXPLOSION_DMG_MUL = 0
	self.aa_turret_module.FIRE_DMG_MUL = 0
	self.aa_turret_module.BAG_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DMG_MUL = 0
	self.aa_turret_module.SHIELD_DAMAGE_CLAMP = 10
	self.aa_turret_module.BODY_DAMAGE_CLAMP = 10
	self.aa_turret_module.DAMAGE = 3.5
	self.aa_turret_module.CLIP_SIZE = 800
	self.aa_turret_module.AUTO_REPAIR = true 
	self.aa_turret_module.AUTO_REPAIR_MAX_COUNT = 999
	self.aa_turret_module.AUTO_REPAIR_DURATION = 30
	self.aa_turret_module.AUTO_RELOAD_DURATION = 8
	self.aa_turret_module.CAN_GO_IDLE = false
	self.aa_turret_module.IDLE_WAIT_TIME = 10
	end
end



Hooks:PostHook(WeaponTweakData, "_init_data_player_weapons", "vox_wep", function(self, tweak_data) --total crackdown overhaul weapons
	
	--local dont = true
	
	if deathvox:IsTotalCrackdownEnabled() then
		--Don't worry about all of this.
		local autohit_rifle_default, autohit_pistol_default, autohit_shotgun_default, autohit_lmg_default, autohit_snp_default, autohit_smg_default, autohit_minigun_default, aim_assist_rifle_default, aim_assist_pistol_default, aim_assist_shotgun_default, aim_assist_lmg_default, aim_assist_snp_default, aim_assist_smg_default, aim_assist_minigun_default = nil
		
		if SystemInfo:platform() == Idstring("WIN32") then
			autohit_rifle_default = {
				INIT_RATIO = 0.15,
				MAX_RATIO = 0.85,
				far_angle = 1,
				far_dis = 4000,
				MIN_RATIO = 0.75,
				near_angle = 3
			}
			autohit_pistol_default = {
				INIT_RATIO = 0.15,
				MAX_RATIO = 0.95,
				far_angle = 0.5,
				far_dis = 4000,
				MIN_RATIO = 0.82,
				near_angle = 3
			}
			autohit_shotgun_default = {
				INIT_RATIO = 0.15,
				MAX_RATIO = 0.7,
				far_angle = 1.5,
				far_dis = 5000,
				MIN_RATIO = 0.6,
				near_angle = 3
			}
			autohit_lmg_default = {
				INIT_RATIO = 0.05,
				MAX_RATIO = 0.4,
				far_angle = 0.2,
				far_dis = 2000,
				MIN_RATIO = 0.2,
				near_angle = 2
			}
			autohit_snp_default = {
				INIT_RATIO = 0.05,
				MAX_RATIO = 0.4,
				far_angle = 0.2,
				far_dis = 5000,
				MIN_RATIO = 0.2,
				near_angle = 2
			}
			autohit_smg_default = {
				INIT_RATIO = 0.05,
				MAX_RATIO = 0.4,
				far_angle = 0.5,
				far_dis = 2500,
				MIN_RATIO = 0.2,
				near_angle = 4
			}
			autohit_minigun_default = {
				INIT_RATIO = 1,
				MAX_RATIO = 1,
				far_angle = 0.0005,
				far_dis = 10000,
				MIN_RATIO = 0,
				near_angle = 0.0005
			}
		else
			autohit_rifle_default = {
				INIT_RATIO = 0.6,
				MAX_RATIO = 0.6,
				far_angle = 3,
				far_dis = 5000,
				MIN_RATIO = 0.25,
				near_angle = 3
			}
			autohit_pistol_default = {
				INIT_RATIO = 0.6,
				MAX_RATIO = 0.6,
				far_angle = 3,
				far_dis = 2500,
				MIN_RATIO = 0.25,
				near_angle = 3
			}
			autohit_shotgun_default = {
				INIT_RATIO = 0.3,
				MAX_RATIO = 0.3,
				far_angle = 5,
				far_dis = 5000,
				MIN_RATIO = 0.15,
				near_angle = 3
			}
			autohit_lmg_default = {
				INIT_RATIO = 0.6,
				MAX_RATIO = 0.6,
				far_angle = 3,
				far_dis = 5000,
				MIN_RATIO = 0.25,
				near_angle = 3
			}
			autohit_snp_default = {
				INIT_RATIO = 0.6,
				MAX_RATIO = 0.6,
				far_angle = 3,
				far_dis = 5000,
				MIN_RATIO = 0.25,
				near_angle = 3
			}
			autohit_smg_default = {
				INIT_RATIO = 0.6,
				MAX_RATIO = 0.6,
				far_angle = 3,
				far_dis = 5000,
				MIN_RATIO = 0.25,
				near_angle = 3
			}
			autohit_minigun_default = {
				INIT_RATIO = 1,
				MAX_RATIO = 1,
				far_angle = 0.0005,
				far_dis = 10000,
				MIN_RATIO = 0,
				near_angle = 0.0005
			}
		end

		aim_assist_rifle_default = deep_clone(autohit_rifle_default)
		aim_assist_pistol_default = deep_clone(autohit_pistol_default)
		aim_assist_shotgun_default = deep_clone(autohit_shotgun_default)
		aim_assist_lmg_default = deep_clone(autohit_lmg_default)
		aim_assist_snp_default = deep_clone(autohit_snp_default)
		aim_assist_smg_default = deep_clone(autohit_smg_default)
		aim_assist_minigun_default = deep_clone(autohit_minigun_default)
		aim_assist_rifle_default.near_angle = 40
		aim_assist_pistol_default.near_angle = 20
		aim_assist_shotgun_default.near_angle = 40
		aim_assist_lmg_default.near_angle = 10
		aim_assist_snp_default.near_angle = 20
		aim_assist_smg_default.near_angle = 30
		
		local weapon_data = {
			autohit_rifle_default = autohit_rifle_default,
			autohit_pistol_default = autohit_pistol_default,
			autohit_shotgun_default = autohit_shotgun_default,
			autohit_lmg_default = autohit_lmg_default,
			autohit_snp_default = autohit_snp_default,
			autohit_smg_default = autohit_smg_default,
			autohit_minigun_default = autohit_minigun_default,
			damage_melee_default = damage_melee_default,
			damage_melee_effect_multiplier_default = damage_melee_effect_multiplier_default,
			aim_assist_rifle_default = aim_assist_rifle_default,
			aim_assist_pistol_default = aim_assist_pistol_default,
			aim_assist_shotgun_default = aim_assist_shotgun_default,
			aim_assist_lmg_default = aim_assist_lmg_default,
			aim_assist_snp_default = aim_assist_snp_default,
			aim_assist_smg_default = aim_assist_smg_default,
			aim_assist_minigun_default = aim_assist_minigun_default
		}
		
		weapon_data.total_damage_primary = 300
		weapon_data.total_damage_secondary = 150
		weapon_data.default_bipod_spread = 1.6
		--Don't worry about all of the above, crash-prevention.
		
		--In-game name/Internal name.
		
		--Fire Rate/Fire Rate: In-game number is rounds per minute, in code, it's a division of that value in order to achieve proper firerates.
		--480 rounds per minute = 8 rounds per second, divide a second by 8 and you get the Chimano 88's firerate, beware of decimal hell.

		--------/Ammo Pickup: Acquire two values, the first value is the ammo pickup minimum, the second value is the pickup max, don't forget to calculate for walk-in closet if that's going to be in the overhaul.
		
		--Piercing of all kinds can be defined with armor_piercing_chance being set to 1, can_shoot_through_enemy being set to true, can_shoot_through_shield being set to true and can_shoot_through_wall being set to true, I'm not sure what the effects of having some of the more extreme ones being set to true, while smaller ones being set to nil would be, be careful.
		
		--Stability/Recoil: 1 point = 3, to get a weapon with 44 stability, the number you'd enter would end up being 12, the decimal is rounded down to 3, which results in the weapon having "44" stability in the weapon stat screen.

		--Accuracy/Spread, Spread_Moving: Same as above, 1 = 3.

		--Threat/Suppression: Instead of counting upwards, this one counts downwards, 1 = -3 from max Threat that can be achieved in-game (I assume), so for a weapon to have 28 threat, it's suppression would be "5", for a weapon to have 37 threat, it's suppression would be "2".

		--Damage/Damage: Consistent, 1 = 1, don't forget to calculate for Fast and Furious, if that's going to be in the overhaul, due to limitations, in order to achieve 200+ numbers, it needs to use a multiplier in a separate table, which will be included for every weapon, for consistency reasons, for example, in order to achieve 480 damage in a weapon, you cannot simply set it to deal 480 damage, you need to set damage to 48, and then multiply it by 10 on the multiplier table.

		--Concealment/Concealment: Consistent, 1 = 1.
		
		--First gun of every category will have notes on the stats some of the unexplained stats if they weren't explained already by a previous category or this sheet, after that, it's all listening to music, drinking coffee at 2 in the morning while typing all the stuff out.
		
		--Rifles begin here.
		
		--CAR-4 Rifle
		self.new_m4.FIRE_MODE = "auto"
		self.new_m4.fire_mode_data = {
			fire_rate = 0.1
		}
		self.new_m4.CAN_TOGGLE_FIREMODE = true
		self.new_m4.auto = {
			fire_rate = 0.1
		}
		self.new_m4.timers = {
			reload_not_empty = 2.665,
			reload_empty = 3.43,
			unequip = 0.6,
			equip = 0.6
		}
		
		self.new_m4.CLIP_AMMO_MAX = 30
		self.new_m4.AMMO_MAX = 210
		self.new_m4.AMMO_PICKUP = {
			6,
			10
		}
		
		self.new_m4.spread = {
			standing = 3
		}
		self.new_m4.spread.crouching = self.new_m4.spread.standing * 0.4
		self.new_m4.spread.steelsight = self.new_m4.spread.standing * 0.4
		self.new_m4.spread.moving_standing = self.new_m4.spread.standing
		self.new_m4.spread.moving_crouching = self.new_m4.spread.standing
		self.new_m4.spread.moving_steelsight = self.new_m4.spread.steelsight
		self.new_m4.kick = {
			standing = {
				0.6,
				0.8,
				-1,
				1
			}
		}
		self.new_m4.kick.crouching = self.new_m4.kick.standing
		self.new_m4.kick.steelsight = self.new_m4.kick.standing
		
		self.new_m4.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 80,
			alert_size = 7,
			spread = 26,
			spread_moving = 10,
			recoil = 26,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 10,
			concealment = 15
		}
		self.new_m4.stats_modifiers = {
			damage = 1
		}
		
		--AMCAR
		self.amcar.FIRE_MODE = "auto"
		self.amcar.fire_mode_data = {
			fire_rate = 0.11
		}
		self.amcar.CAN_TOGGLE_FIREMODE = true
		self.amcar.auto = {
			fire_rate = 0.11
		}
		self.amcar.timers = {
			reload_not_empty = 2.25,
			reload_empty = 3,
			unequip = 0.6,
			equip = 0.55
		}
	
		self.amcar.CLIP_AMMO_MAX = 20
		self.amcar.AMMO_MAX = 300
		self.amcar.AMMO_PICKUP = {
			9,
			18
		}
		self.amcar.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.amcar.kick = {
			standing = self.new_m4.kick.standing
		}
		self.amcar.kick.crouching = self.amcar.kick.standing
		self.amcar.kick.steelsight = self.amcar.kick.standing
		
		self.amcar.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 50,
			alert_size = 7,
			spread = 26,
			spread_moving = 8,
			recoil = 26,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 14,
			concealment = 30
		}
		self.amcar.stats_modifiers = {
			damage = 1
		}
	
		--AK Rifle
		self.ak74.FIRE_MODE = "auto"
		self.ak74.fire_mode_data = {
			fire_rate = 0.092
		}
		self.ak74.CAN_TOGGLE_FIREMODE = true
		self.ak74.auto = {
			fire_rate = 0.092
		}
		self.ak74.timers = {
			reload_not_empty = 2.8,
			reload_empty = 3.87,
			unequip = 0.5,
			equip = 0.5
		}
		
		self.ak74.CLIP_AMMO_MAX = 30
		self.ak74.AMMO_MAX = 210
		self.ak74.AMMO_PICKUP = {
			6,
			10
		}
		
		self.ak74.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.ak74.kick = {
			standing = self.new_m4.kick.standing
		}
		self.ak74.kick.crouching = self.ak74.kick.standing
		self.ak74.kick.steelsight = self.ak74.kick.standing
		
		self.ak74.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 80,
			alert_size = 7,
			spread = 24,
			spread_moving = 11,
			recoil = 26,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 10,
			concealment = 15
		}
		self.ak74.stats_modifiers = {
			damage = 1
		}
		
		--UAR Rifle
		self.aug.FIRE_MODE = "auto"
		self.aug.fire_mode_data = {
			fire_rate = 0.08
		}
		self.aug.CAN_TOGGLE_FIREMODE = true
		self.aug.auto = {
			fire_rate = 0.08
		}
		self.aug.timers = {
			reload_not_empty = 2.5,
			reload_empty = 3.3,
			unequip = 0.5,
			equip = 0.5
		}
		
		self.aug.CLIP_AMMO_MAX = 30
		self.aug.NR_CLIPS_MAX = 5
		self.aug.AMMO_MAX = self.aug.CLIP_AMMO_MAX * self.aug.NR_CLIPS_MAX
		self.aug.AMMO_PICKUP = {
			6,
			10
		}
		
		self.aug.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.aug.kick = {
			standing = self.new_m4.kick.standing
		}
		self.aug.kick.crouching = self.aug.kick.standing
		self.aug.kick.steelsight = self.aug.kick.standing
		
		self.aug.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 80,
			alert_size = 7,
			spread = 21,
			spread_moving = 15,
			recoil = 26,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 10,
			concealment = 15
		}
		self.aug.stats_modifiers = {
			damage = 1
		}
		
		--AK 7.62
		self.akm.FIRE_MODE = "auto"
		self.akm.fire_mode_data = {
			fire_rate = 0.107
		}
		self.akm.CAN_TOGGLE_FIREMODE = true
		self.akm.auto = {
			fire_rate = 0.107
		}
		self.akm.timers = {
			reload_not_empty = 2.8,
			reload_empty = 3.87,
			unequip = 0.5,
			equip = 0.5
		}
		
		self.akm.CLIP_AMMO_MAX = 30
		self.akm.AMMO_MAX = 150
		self.akm.AMMO_PICKUP = {
			4,
			6
		}
		
		self.akm.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.akm.kick = {
			standing = self.new_m4.kick.standing
		}
		self.akm.kick.crouching = self.akm.kick.standing
		self.akm.kick.steelsight = self.akm.kick.standing
		
		self.akm.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 110,
			alert_size = 7,
			spread = 24,
			spread_moving = 14,
			recoil = 26,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 7,
			concealment = 10
		}
		self.akm.stats_modifiers = {
			damage = 1
		}
		
		--JP36
		self.g36.FIRE_MODE = "auto"
		self.g36.fire_mode_data = {
			fire_rate = 0.085
		}
		self.g36.CAN_TOGGLE_FIREMODE = true
		self.g36.auto = {
			fire_rate = 0.085
		}
		self.g36.timers = {
			reload_not_empty = 2.85,
			reload_empty = 3.85,
			unequip = 0.6,
			equip = 0.6
		}
		
		self.g36.CLIP_AMMO_MAX = 30
		self.g36.AMMO_MAX = 300
		self.g36.AMMO_PICKUP = {
			9,
			18
		}
		
		self.g36.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.g36.kick = {
			standing = self.new_m4.kick.standing
		}
		self.g36.kick.crouching = self.g36.kick.standing
		self.g36.kick.steelsight = self.g36.kick.standing
		
		self.g36.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 50,
			alert_size = 7,
			spread = 22,
			spread_moving = 9,
			recoil = 26,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 14,
			concealment = 25
		}
		self.g36.stats_modifiers = {
			damage = 1
		}
		
		--Galant Rifle
		self.ching.FIRE_MODE = "single"
		self.ching.fire_mode_data = {
			fire_rate = 0.1
		}
		self.ching.CAN_TOGGLE_FIREMODE = false
		self.ching.single = {
			fire_rate = 0.1
		}
		self.ching.timers = {
			reload_not_empty = 2.56,
			reload_empty = 1.52,
			unequip = 0.6,
			equip = 0.55
		}
		
		self.ching.CLIP_AMMO_MAX = 8
		self.ching.NR_CLIPS_MAX = 9
		self.ching.AMMO_MAX = self.ching.CLIP_AMMO_MAX * self.ching.NR_CLIPS_MAX
		self.ching.AMMO_PICKUP = {
			0.36,
			1.08
		}
		
		self.ching.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.ching.kick = {
			standing = self.new_m4.kick.standing
		}
		self.ching.kick.crouching = self.ching.kick.standing
		self.ching.kick.steelsight = self.ching.kick.standing
		
		self.ching.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 160,
			alert_size = 7,
			spread = 22,
			spread_moving = 20,
			recoil = 10,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 4,
			concealment = 20
		}
		self.ching.stats_modifiers = {
			damage = 1
		}
		
		--M308 Rifle
		self.new_m14.FIRE_MODE = "single"
		self.new_m14.fire_mode_data = {
			fire_rate = 0.085
		}
		self.new_m14.CAN_TOGGLE_FIREMODE = true
		self.new_m14.single = {
			fire_rate = 0.085
		}
		self.new_m14.timers = {
			reload_not_empty = 2.65,
			reload_empty = 3.15,
			unequip = 0.6,
			equip = 0.55
		}
		
		self.new_m14.CLIP_AMMO_MAX = 10
		self.new_m14.NR_CLIPS_MAX = 7
		self.new_m14.AMMO_MAX = self.new_m14.CLIP_AMMO_MAX * self.new_m14.NR_CLIPS_MAX
		self.new_m14.AMMO_PICKUP = {
			0.35,
			1.05
		}
		
		self.new_m14.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.new_m14.kick = {
			standing = self.new_m4.kick.standing
		}
		self.new_m14.kick.crouching = self.new_m14.kick.standing
		self.new_m14.kick.steelsight = self.new_m14.kick.standing
		
		self.new_m14.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 160,
			alert_size = 7,
			spread = 22,
			spread_moving = 20,
			recoil = 10,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 4,
			concealment = 8
		}
		self.new_m14.stats_modifiers = {
			damage = 1
		}
		
		--AK5 Rifle
		self.ak5.FIRE_MODE = "auto"
		self.ak5.fire_mode_data = {
			fire_rate = 0.085
		}
		self.ak5.CAN_TOGGLE_FIREMODE = true
		self.ak5.auto = {
			fire_rate = 0.085
		}
		self.ak5.timers = {
			reload_not_empty = 2.05,
			reload_empty = 3.08,
			unequip = 0.6,
			equip = 0.45
		}
		
		self.ak5.CLIP_AMMO_MAX = 30
		self.ak5.AMMO_MAX = 210
		self.ak5.AMMO_PICKUP = {
			6,
			10
		}
		
		self.ak5.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.ak5.kick = {
			standing = self.new_m4.kick.standing
		}
		self.ak5.kick.crouching = self.ak5.kick.standing
		self.ak5.kick.steelsight = self.ak5.kick.standing
		
		self.ak5.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 80,
			alert_size = 7,
			spread = 24,
			spread_moving = 14,
			recoil = 26,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 10,
			concealment = 15
		}
		self.ak5.stats_modifiers = {
			damage = 1
		}
		
		--AMR-16
		self.m16.FIRE_MODE = "auto"
		self.m16.fire_mode_data = {
			fire_rate = 0.07
		}
		self.m16.CAN_TOGGLE_FIREMODE = true
		self.m16.auto = {
			fire_rate = 0.07
		}
		self.m16.timers = {
			reload_not_empty = 2.75,
			reload_empty = 3.73,
			unequip = 0.6,
			equip = 0.6
		}
		
		self.m16.CLIP_AMMO_MAX = 20
		self.m16.AMMO_MAX = 140
		self.m16.AMMO_PICKUP = {
			4,
			6
		}
		
		self.m16.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.m16.kick = {
			standing = self.new_m4.kick.standing
		}
		self.m16.kick.crouching = self.m16.kick.standing
		self.m16.kick.steelsight = self.m16.kick.standing
		
		self.m16.stats = {
			zoom = 4,
			total_ammo_mod = 21,
			damage = 110,
			alert_size = 7,
			spread = 25,
			spread_moving = 13,
			recoil = 26,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 10,
			concealment = 10
		}
		self.m16.stats_modifiers = {
			damage = 1
		}
		
		--Tempest-21
		self.komodo.FIRE_MODE = "auto"
		self.komodo.fire_mode_data = {
			fire_rate = 0.075
		}
		self.komodo.CAN_TOGGLE_FIREMODE = true
		self.komodo.auto = {
			fire_rate = 0.075
		}
		self.komodo.timers = {
			reload_not_empty = 2.35,
			reload_empty = 3.35,
			unequip = 0.65,
			equip = 0.6
		}
		
		self.komodo.CLIP_AMMO_MAX = 30
		self.komodo.AMMO_MAX = 210
		self.komodo.AMMO_PICKUP = {
			6,
			10
		}
		
		self.komodo.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.komodo.kick = {
			standing = self.new_m4.kick.standing
		}
		self.komodo.kick.crouching = self.komodo.kick.standing
		self.komodo.kick.steelsight = self.komodo.kick.standing
		
		self.komodo.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 80,
			alert_size = 8,
			spread = 22,
			spread_moving = 15,
			recoil = 26,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 10,
			concealment = 20
		}
		self.komodo.stats_modifiers = {
			damage = 1
		}
		
		--Union 5.56 Rifle
		self.corgi.FIRE_MODE = "auto"
		self.corgi.fire_mode_data = {
			fire_rate = 0.07
		}
		self.corgi.CAN_TOGGLE_FIREMODE = true
		self.corgi.auto = {
			fire_rate = 0.07
		}
		self.corgi.timers = {
			reload_not_empty = 2.1,
			reload_empty = 2.9,
			unequip = 0.6,
			equip = 0.6
		}
		
		self.corgi.CLIP_AMMO_MAX = 30
		self.corgi.AMMO_MAX = 210
		self.corgi.AMMO_PICKUP = {
			6,
			10
		}
		
		self.corgi.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.corgi.kick = {
			standing = self.new_m4.kick.standing
		}
		self.corgi.kick.crouching = self.corgi.kick.standing
		self.corgi.kick.steelsight = self.corgi.kick.standing
		
		self.corgi.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 80,
			alert_size = 8,
			spread = 19,
			spread_moving = 15,
			recoil = 26,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 10,
			concealment = 15
		}
		self.corgi.stats_modifiers = {
			damage = 1
		}
		
		--Commando 553
		self.s552.FIRE_MODE = "auto"
		self.s552.fire_mode_data = {
			fire_rate = 0.084
		}
		self.s552.CAN_TOGGLE_FIREMODE = true
		self.s552.auto = {
			fire_rate = 0.084
		}
		self.s552.timers = {
			reload_not_empty = 1.65,
			reload_empty = 2.4,
			unequip = 0.55,
			equip = 0.7
		}
		
		self.s552.CLIP_AMMO_MAX = 30
		self.s552.AMMO_MAX = 300
		self.s552.AMMO_PICKUP = {
			8,
			16
		}
		
		self.s552.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.s552.kick = {
			standing = self.new_m4.kick.standing
		}
		self.s552.kick.crouching = self.s552.kick.standing
		self.s552.kick.steelsight = self.s552.kick.standing
		
		self.s552.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 50,
			alert_size = 7,
			spread = 16,
			spread_moving = 8,
			recoil = 26,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 14,
			concealment = 30
		}
		self.s552.stats_modifiers = {
			damage = 1
		}
		
		--Eagle Heavy
		self.scar.FIRE_MODE = "auto"
		self.scar.fire_mode_data = {
			fire_rate = 0.098
		}
		self.scar.CAN_TOGGLE_FIREMODE = true
		self.scar.auto = {
			fire_rate = 0.098
		}
		self.scar.timers = {
			reload_not_empty = 2.2,
			reload_empty = 3.15,
			unequip = 0.6,
			equip = 0.5
		}
		
		self.scar.CLIP_AMMO_MAX = 20
		self.scar.AMMO_MAX = 140
		self.scar.AMMO_PICKUP = {
			4,
			6
		}
		
		self.scar.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.scar.kick = {
			standing = self.new_m4.kick.standing
		}
		self.scar.kick.crouching = self.scar.kick.standing
		self.scar.kick.steelsight = self.scar.kick.standing
		
		self.scar.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 110,
			alert_size = 7,
			spread = 26,
			spread_moving = 15,
			recoil = 22,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 9,
			concealment = 10
		}
		self.scar.stats_modifiers = {
			damage = 1
		}
		
		--Cavity 9mm
		self.sub2000.FIRE_MODE = "single"
		self.sub2000.fire_mode_data = {
			fire_rate = 0.085
		}
		self.sub2000.CAN_TOGGLE_FIREMODE = false
		self.sub2000.single = {
			fire_rate = 0.085
		}
		self.sub2000.timers = {
			reload_not_empty = 2.3,
			reload_empty = 3.3,
			unequip = 0.9,
			equip = 0.9
		}
		
		self.sub2000.CLIP_AMMO_MAX = 33
		self.sub2000.NR_CLIPS_MAX = 2
		self.sub2000.AMMO_MAX = self.sub2000.CLIP_AMMO_MAX * self.sub2000.NR_CLIPS_MAX
		self.sub2000.AMMO_PICKUP = {
			0.33,
			0.99
		}
		
		self.sub2000.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.sub2000.kick = {
			standing = self.new_m4.kick.standing
		}
		self.sub2000.kick.crouching = self.sub2000.kick.standing
		self.sub2000.kick.steelsight = self.sub2000.kick.standing
		
		self.sub2000.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 160,
			alert_size = 7,
			spread = 19,
			spread_moving = 16,
			recoil = 9,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 4,
			concealment = 27
		}
		self.sub2000.stats_modifiers = {
			damage = 1
		}
		
		--AK17 Rifle
		self.flint.FIRE_MODE = "auto"
		self.flint.fire_mode_data = {
			fire_rate = 0.092
		}
		self.flint.CAN_TOGGLE_FIREMODE = true
		self.flint.auto = {
			fire_rate = 0.092
		}
		self.flint.timers = {
			reload_not_empty = 2.26,
			reload_empty = 3.37,
			unequip = 0.5,
			equip = 0.5
		}
		
		self.flint.CLIP_AMMO_MAX = 30
		self.flint.AMMO_MAX = 210
		self.flint.AMMO_PICKUP = {
			6,
			10
		}
		
		self.flint.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.flint.kick = {
			standing = self.new_m4.kick.standing,
			crouching = self.ak74.kick.standing,
			steelsight = self.ak74.kick.standing
		}
		
		self.flint.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 80,
			alert_size = 7,
			spread = 24,
			spread_moving = 11,
			recoil = 26,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 10,
			concealment = 10
		}
		self.flint.stats_modifiers = {
			damage = 1
		}
		
		--Bootleg Rifle
		self.tecci.FIRE_MODE = "auto"
		self.tecci.fire_mode_data = {
			fire_rate = 0.09
		}
		self.tecci.CAN_TOGGLE_FIREMODE = true
		self.tecci.auto = {
			fire_rate = 0.09
		}
		self.tecci.timers = {
			reload_not_empty = 3.8,
			reload_empty = 4.7,
			unequip = 0.6,
			equip = 0.6
		}
		
		self.tecci.CLIP_AMMO_MAX = 100
		self.tecci.AMMO_MAX = 400
		self.tecci.AMMO_PICKUP = {
			8,
			16
		}
		
		self.tecci.spread = {
			standing = 3
		}
		self.tecci.spread.crouching = self.tecci.spread.standing * 0.4
		self.tecci.spread.steelsight = self.tecci.spread.standing * 0.4
		self.tecci.spread.moving_standing = self.tecci.spread.standing
		self.tecci.spread.moving_crouching = self.tecci.spread.standing
		self.tecci.spread.moving_steelsight = self.tecci.spread.steelsight
		self.tecci.kick = {
			standing = {
				0.6,
				0.8,
				-1,
				1
			}
		}
		self.tecci.kick.crouching = self.tecci.kick.standing
		self.tecci.kick.steelsight = self.tecci.kick.standing
		
		self.tecci.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 50,
			alert_size = 7,
			spread = 14,
			spread_moving = 10,
			recoil = 25,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 8,
			concealment = 10
		}
		self.tecci.stats_modifiers = {
			damage = 1
		}
		
		--Queen's Wrath
		self.l85a2.FIRE_MODE = "auto"
		self.l85a2.fire_mode_data = {
			fire_rate = 0.083
		}
		self.l85a2.CAN_TOGGLE_FIREMODE = true
		self.l85a2.auto = {
			fire_rate = 0.083
		}
		self.l85a2.timers = {
			reload_not_empty = 3.5,
			reload_empty = 4.5,
			unequip = 0.45,
			equip = 0.75
		}
		
		self.l85a2.CLIP_AMMO_MAX = 30
		self.l85a2.AMMO_MAX = 210
		self.l85a2.AMMO_PICKUP = {
			6,
			10
		}
		
		self.l85a2.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.l85a2.kick = {
			standing = {
				0.8,
				1.1,
				-1.2,
				1.2
			}
		}
		self.l85a2.kick.crouching = self.l85a2.kick.standing
		self.l85a2.kick.steelsight = self.l85a2.kick.standing
		
		self.l85a2.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 80,
			alert_size = 8,
			spread = 22,
			spread_moving = 15,
			recoil = 26,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 10,
			concealment = 15
		}
		self.l85a2.stats_modifiers = {
			damage = 1
		}
		
		--Clarion Rifle
		self.famas.FIRE_MODE = "auto"
		self.famas.fire_mode_data = {
			fire_rate = 0.06
		}
		self.famas.CAN_TOGGLE_FIREMODE = true
		self.famas.auto = {
			fire_rate = 0.06
		}
		self.famas.timers = {
			reload_not_empty = 2.72,
			reload_empty = 3.78,
			unequip = 0.55,
			equip = 0.6
		}
		
		self.famas.CLIP_AMMO_MAX = 30
		self.famas.AMMO_MAX = 300
		self.famas.AMMO_PICKUP = {
			8,
			16
		}
		
		self.famas.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.famas.kick = {
			standing = self.new_m4.kick.standing
		}
		self.famas.kick.crouching = self.famas.kick.standing
		self.famas.kick.steelsight = self.famas.kick.standing
		
		self.famas.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 50,
			alert_size = 7,
			spread = 19,
			spread_moving = 8,
			recoil = 21,
			value = 4,
			extra_ammo = 51,
			reload = 11,
			suppression = 14,
			concealment = 25
		}
		self.famas.stats_modifiers = {
			damage = 1
		}
		
		--Lion's Roar aka BEST GUN
		self.vhs.FIRE_MODE = "auto"
		self.vhs.fire_mode_data = {
			fire_rate = 0.07
		}
		self.vhs.CAN_TOGGLE_FIREMODE = true
		self.vhs.auto = {
			fire_rate = 0.07
		}
		self.vhs.timers = {
			reload_not_empty = 3.2,
			reload_empty = 4.75,
			unequip = 0.6,
			equip = 0.6
		}
		
		self.vhs.CLIP_AMMO_MAX = 30
		self.vhs.AMMO_MAX = 210
		self.vhs.AMMO_PICKUP = {
			6,
			10
		}
		
		self.vhs.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.vhs.kick = {
			standing = {
				0.6,
				0.8,
				-1,
				1
			}
		}
		self.vhs.kick.crouching = self.vhs.kick.standing
		self.vhs.kick.steelsight = self.vhs.kick.standing
		
		self.vhs.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 80,
			alert_size = 8,
			spread = 19,
			spread_moving = 15,
			recoil = 26,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 10,
			concealment = 15
		}
		self.vhs.stats_modifiers = {
			damage = 1
		}
		
		--Valkyria Rifle
		self.asval.FIRE_MODE = "auto"
		self.asval.fire_mode_data = {
			fire_rate = 0.11
		}
		self.asval.CAN_TOGGLE_FIREMODE = true
		self.asval.auto = {
			fire_rate = 0.11
		}
		self.asval.timers = {
			reload_not_empty = 2.6,
			reload_empty = 3.7,
			unequip = 0.5,
			equip = 0.5
		}
		
		self.asval.AMMO_MAX = 180
		self.asval.AMMO_PICKUP = {
			7,
			12
		}
		
		self.asval.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.asval.kick = {
			standing = self.new_m4.kick.standing
		}
		self.asval.kick.crouching = self.asval.kick.standing
		self.asval.kick.steelsight = self.asval.kick.standing
		self.asval.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 80,
			alert_size = 24,
			spread = 24,
			spread_moving = 15,
			recoil = 26,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 24,
			concealment = 17
		}
		
		
		--Gecko 7.62
		self.galil.FIRE_MODE = "auto"
		self.galil.fire_mode_data = {
			fire_rate = 0.071
		}
		self.galil.CAN_TOGGLE_FIREMODE = true
		self.galil.auto = {
			fire_rate = 0.071
		}
		self.galil.timers = {
			reload_not_empty = 3,
			reload_empty = 4.2,
			unequip = 0.6,
			equip = 0.6
		}
		
		self.galil.CLIP_AMMO_MAX = 30
		self.galil.AMMO_MAX = 210
		self.galil.AMMO_PICKUP = {
			6,
			10
		}
		
		self.galil.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.galil.kick = {
			standing = self.new_m4.kick.standing
		}
		self.galil.kick.crouching = self.galil.kick.standing
		self.galil.kick.steelsight = self.galil.kick.standing
		
		self.galil.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 80,
			alert_size = 7,
			spread = 26,
			spread_moving = 10,
			recoil = 20,
			value = 4,
			extra_ammo = 51,
			reload = 11,
			suppression = 10,
			concealment = 15
		}
		self.galil.stats_modifiers = {
			damage = 1
		}
		
		--Little Friend RIFLE
		self.contraband.FIRE_MODE = "single"
		self.contraband.fire_mode_data = {
			fire_rate = 0.098
		}
		self.contraband.CAN_TOGGLE_FIREMODE = true
		self.contraband.auto = {
			fire_rate = 0.098
		}
		self.contraband.timers = {
			reload_not_empty = 2.55,
			reload_empty = 3.2,
			unequip = 0.6,
			equip = 0.5
		}
		
		self.contraband.CLIP_AMMO_MAX = 20
		self.contraband.NR_CLIPS_MAX = 2
		self.contraband.AMMO_MAX = self.contraband.CLIP_AMMO_MAX * self.contraband.NR_CLIPS_MAX
		self.contraband.AMMO_PICKUP = {
			0.20,
			0.60
		}
		
		self.contraband.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.contraband.kick = {
			standing = self.new_m4.kick.standing
		}
		self.contraband.kick.crouching = self.contraband.kick.standing
		self.contraband.kick.steelsight = self.contraband.kick.standing
		
		self.contraband.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 160,
			alert_size = 7,
			spread = 19,
			spread_moving = 15,
			recoil = 12,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 8,
			concealment = 8
		}
		self.contraband.stats_modifiers = {
			damage = 1
		}
		
		--Little Friend GRENADE LAUNCHER
		self.contraband_m203.FIRE_MODE = "single"
		self.contraband_m203.fire_mode_data = {
			fire_rate = 0.75
		}
		self.contraband_m203.single = {
			fire_rate = 0.75
		}
		self.contraband_m203.timers = {
			reload_not_empty = 2.45,
			reload_empty = 2.45,
			unequip = 0.6,
			equip = 0.6,
			equip_underbarrel = 0.4,
			unequip_underbarrel = 0.4
		}
		
		self.contraband_m203.CLIP_AMMO_MAX = 1
		self.contraband_m203.NR_CLIPS_MAX = 3
		self.contraband_m203.AMMO_MAX = self.contraband_m203.CLIP_AMMO_MAX * self.contraband_m203.NR_CLIPS_MAX
		self.contraband_m203.AMMO_PICKUP = {
			0.1,
			0.7
		}
		
		self.contraband_m203.spread = {
			standing = self.r870.spread.standing,
			crouching = self.r870.spread.crouching,
			steelsight = self.r870.spread.steelsight,
			moving_standing = self.r870.spread.moving_standing,
			moving_crouching = self.r870.spread.moving_crouching,
			moving_steelsight = self.r870.spread.moving_steelsight
		}
		self.contraband_m203.kick = {
			standing = {
				2.9,
				3,
				-0.5,
				0.5
			}
		}
		self.contraband_m203.kick.crouching = self.contraband_m203.kick.standing
		self.contraband_m203.kick.steelsight = self.contraband_m203.kick.standing
		
		self.contraband_m203.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 960, --does not actually matter, projectile damage is defined elsewhere
			alert_size = 7,
			spread = 25,
			spread_moving = 6,
			recoil = 25,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 2,
			concealment = 18 --doesn't matter, not used
		}
		self.contraband_m203.stats_modifiers = {
			damage = 10 --does not actually matter, projectile damage is defined elsewhere
		}
		
		--Falcon Rifle
		self.fal.FIRE_MODE = "auto"
		self.fal.fire_mode_data = {
			fire_rate = 0.086
		}
		self.fal.CAN_TOGGLE_FIREMODE = true
		self.fal.auto = {
			fire_rate = 0.086
		}
		self.fal.timers = {
			reload_not_empty = 2.2,
			reload_empty = 3.28,
			unequip = 0.6,
			equip = 0.6
		}
		
		self.fal.CLIP_AMMO_MAX = 20
		self.fal.AMMO_MAX = 140
		self.fal.AMMO_PICKUP = {
			4,
			6
		}
		
		self.fal.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.fal.kick = {
			standing = self.new_m4.kick.standing
		}
		self.fal.kick.crouching = self.fal.kick.standing
		self.fal.kick.steelsight = self.fal.kick.standing
		
		self.fal.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 98,
			alert_size = 7,
			spread = 25,
			spread_moving = 16,
			recoil = 22,
			value = 4,
			extra_ammo = 51,
			reload = 11,
			suppression = 9,
			concealment = 10
		}
		self.fal.stats_modifiers = {
			damage = 1
		}
		
		--Gewehr 3
		self.g3.FIRE_MODE = "auto"
		self.g3.fire_mode_data = {
			fire_rate = 0.092
		}
		self.g3.CAN_TOGGLE_FIREMODE = true
		self.g3.auto = {
			fire_rate = 0.092
		}
		self.g3.timers = {
			reload_not_empty = 1.4,
			reload_empty = 2,
			unequip = 0.6,
			equip = 0.65
		}
		
		self.g3.CLIP_AMMO_MAX = 20
		self.g3.AMMO_MAX = 140
		self.g3.AMMO_PICKUP = {
			4,
			6
		}
		
		self.g3.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.g3.kick = {
			standing = self.new_m4.kick.standing
		}
		self.g3.kick.crouching = self.g3.kick.standing
		self.g3.kick.steelsight = self.g3.kick.standing
		
		self.g3.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 110,
			alert_size = 7,
			spread = 26,
			spread_moving = 16,
			recoil = 22,
			value = 4,
			extra_ammo = 51,
			reload = 11,
			suppression = 9,
			concealment = 10
		}
		self.g3.stats_modifiers = {
			damage = 1
		}
		
		--Golden AK 7.62
		self.akm_gold.FIRE_MODE = "auto"
		self.akm_gold.fire_mode_data = {
			fire_rate = 0.107
		}
		self.akm_gold.CAN_TOGGLE_FIREMODE = true
		self.akm_gold.auto = {
			fire_rate = 0.107
		}
		self.akm_gold.timers = {
			reload_not_empty = 2.8,
			reload_empty = 3.87,
			unequip = 0.5,
			equip = 0.5
		}
		
		self.akm_gold.CLIP_AMMO_MAX = 30
		self.akm_gold.AMMO_MAX = 150
		self.akm_gold.AMMO_PICKUP = {
			4,
			6
		}
		
		self.akm_gold.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.akm_gold.kick = {
			standing = self.new_m4.kick.standing
		}
		self.akm_gold.kick.crouching = self.akm_gold.kick.standing
		self.akm_gold.kick.steelsight = self.akm_gold.kick.standing
		
		self.akm_gold.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 110,
			alert_size = 7,
			spread = 24,
			spread_moving = 14,
			recoil = 26,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 9,
			concealment = 10
		}
		self.akm_gold.stats_modifiers = {
			damage = 1
		}
	
		--Rifles end here.
		
		--Pistols begin here.
		
		--Chimano 88
		self.glock_17.fire_mode_data = {
			fire_rate = 0.125
		}
		self.glock_17.single = {
			fire_rate = 0.125
		}	
		self.glock_17.timers = {
			reload_not_empty = 1.47,
			reload_empty = 2.12,
			unequip = 0.5,
			equip = 0.35
		}
		
		self.glock_17.CLIP_AMMO_MAX = 17 --Self-explanatory, maximum ammo in a clip.
		self.glock_17.NR_CLIPS_MAX = 9 --Maximum number of clips carried by the gun itself, merely used to the AMMO_MAX below as far as I know.
		self.glock_17.AMMO_MAX = self.glock_17.CLIP_AMMO_MAX * self.glock_17.NR_CLIPS_MAX
		self.glock_17.AMMO_PICKUP = {
			1.53,  
			5.36
		}
		
		self.glock_17.spread = { --Don't worry about this.
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.glock_17.kick = { --Used for most other pistols, consider this a "multiplier" I guess, first two values are vertical minimum and maximum kick, negative values will KICK THE WEAPON DOWNWARD, last two values are horizontal minimum and maximum, I believe negative values would kick the weapon to the left, while normal kicks the weapon to the right.
			standing = {
				1.2,
				1.8,
				-0.5,
				0.5
			}
		}
		self.glock_17.kick.crouching = self.glock_17.kick.standing
		self.glock_17.kick.steelsight = self.glock_17.kick.standing
		
		self.glock_17.stats = {
			zoom = 1,
			total_ammo_mod = 21, --Don't worry about this.
			damage = 35,
			alert_size = 7,
			spread = 14,
			spread_moving = 14,
			recoil = 16,
			value = 1,
			extra_ammo = 51, --Don't worry about this.
			reload = 11, --AFAIK not actually tied to reload in anyway whatsoever???
			suppression = 16,
			concealment = 30
		}
		self.glock_17.stats_modifiers = {
			damage = 1 --Damage multiplier, for consistency's sake, don't change this from 1 unless you need to achieve damage numbers higher than 200.
		}
		
		--Crosskill Pistol
		
		self.colt_1911.FIRE_MODE = "single"
		self.colt_1911.fire_mode_data = {
			fire_rate = 0.166
		}
		self.colt_1911.single = {
			fire_rate = 0.166
		}	
		self.colt_1911.timers = {
			reload_not_empty = 1.47,
			reload_empty = 2.12,
			unequip = 0.5,
			equip = 0.35
		}
		
		self.colt_1911.CLIP_AMMO_MAX = 10
		self.colt_1911.NR_CLIPS_MAX = 9
		self.colt_1911.AMMO_MAX = self.colt_1911.CLIP_AMMO_MAX * self.colt_1911.NR_CLIPS_MAX
		self.colt_1911.AMMO_PICKUP = {
			0.90,  
			3.15
		}
		
		self.colt_1911.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.colt_1911.kick = {
			standing = self.glock_17.kick.standing
		}
		self.colt_1911.kick.crouching = self.colt_1911.kick.standing
		self.colt_1911.kick.steelsight = self.colt_1911.kick.standing
		
		self.colt_1911.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 65,
			alert_size = 7,
			spread = 18,
			spread_moving = 18,
			recoil = 14,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 14,
			concealment = 29
		}
		self.colt_1911.stats_modifiers = {
			damage = 1
		}
		
		--Bernetti 9
		self.b92fs.FIRE_MODE = "single"
		self.b92fs.fire_mode_data = {
			fire_rate = 0.125
		}
		self.b92fs.single = {
			fire_rate = 0.125
		}
		self.b92fs.timers = {
			reload_not_empty = 1.47,
			reload_empty = 2.12,
			unequip = 0.5,
			equip = 0.35
		}
		
		self.b92fs.CLIP_AMMO_MAX = 14
		self.b92fs.NR_CLIPS_MAX = 11
		self.b92fs.AMMO_MAX = self.b92fs.CLIP_AMMO_MAX * self.b92fs.NR_CLIPS_MAX
		self.b92fs.AMMO_PICKUP = {
			1.54,  
			5.39
		}
		
		self.b92fs.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.b92fs.kick = {
			standing = self.glock_17.kick.standing
		}
		self.b92fs.kick.crouching = self.b92fs.kick.standing
		self.b92fs.kick.steelsight = self.b92fs.kick.standing
		
		self.b92fs.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 37,
			alert_size = 7,
			spread = 15,
			spread_moving = 15,
			recoil = 16,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 17,
			concealment = 30
		}
		self.b92fs.stats_modifiers = {
			damage = 1
		}
		
		--Bronco
		self.new_raging_bull.FIRE_MODE = "single"
		self.new_raging_bull.fire_mode_data = {
			fire_rate = 0.166
		}
		self.new_raging_bull.single = {
			fire_rate = 0.166
		}
		self.new_raging_bull.timers = {
			reload_not_empty = 2.25,
			reload_empty = 2.25,
			unequip = 0.5,
			equip = 0.45
		}
		
		self.new_raging_bull.CLIP_AMMO_MAX = 6
		self.new_raging_bull.NR_CLIPS_MAX = 9
		self.new_raging_bull.AMMO_MAX = self.new_raging_bull.CLIP_AMMO_MAX * self.new_raging_bull.NR_CLIPS_MAX
		self.new_raging_bull.AMMO_PICKUP = {
			0.54,  
			1.89
		}
		
		self.new_raging_bull.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.new_raging_bull.kick = {
			standing = self.glock_17.kick.standing
		}
		self.new_raging_bull.kick.crouching = self.new_raging_bull.kick.standing
		self.new_raging_bull.kick.steelsight = self.new_raging_bull.kick.standing
		
		self.new_raging_bull.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 175,
			alert_size = 7,
			spread = 20,
			spread_moving = 5,
			recoil = 2,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 7,
			concealment = 26
		}	
		self.new_raging_bull.stats_modifiers = {
			damage = 1
		}
		
		--White Streak Pistol
		self.pl14.FIRE_MODE = "single"
		self.pl14.fire_mode_data = {
			fire_rate = 0.25
		}
		self.pl14.single = {
			fire_rate = 0.25
		}
		self.pl14.timers = {
			reload_not_empty = 1.47,
			reload_empty = 2.12,
			unequip = 0.5,
			equip = 0.35
		}
		
		self.pl14.CLIP_AMMO_MAX = 12
		self.pl14.NR_CLIPS_MAX = 5
		self.pl14.AMMO_MAX = self.pl14.CLIP_AMMO_MAX * self.pl14.NR_CLIPS_MAX
		self.pl14.AMMO_PICKUP = {
			0.60,  
			2.10
		}
		
		self.pl14.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.pl14.kick = {
			standing = self.glock_17.kick.standing
		}
		self.pl14.kick.crouching = self.pl14.kick.standing
		self.pl14.kick.steelsight = self.pl14.kick.standing
		
		self.pl14.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 120,
			alert_size = 7,
			spread = 18,
			spread_moving = 18,
			recoil = 9,
			value = 4,
			extra_ammo = 51,
			reload = 11,
			suppression = 15,
			concealment = 29
		}
		self.pl14.stats_modifiers = {
			damage = 1
		}
		
		--Parabellum
		self.breech.FIRE_MODE = "single"
		self.breech.fire_mode_data = {
			fire_rate = 0.166
		}
		self.breech.single = {
			fire_rate = 0.166
		}
		self.breech.timers = {
			reload_not_empty = 1.33,
			reload_empty = 2.1,
			unequip = 0.5,
			equip = 0.35
		}
		
		self.breech.CLIP_AMMO_MAX = 8
		self.breech.NR_CLIPS_MAX = 7
		self.breech.AMMO_MAX = self.breech.CLIP_AMMO_MAX * self.breech.NR_CLIPS_MAX
		self.breech.AMMO_PICKUP = {
			0.56,  
			1.96
		}
		
		self.breech.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.breech.kick = {
			standing = self.glock_17.kick.standing
		}
		self.breech.kick.crouching = self.breech.kick.standing
		self.breech.kick.steelsight = self.breech.kick.standing
		
		self.breech.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 180,
			alert_size = 7,
			spread = 20,
			spread_moving = 18,
			recoil = 7,
			value = 4,
			extra_ammo = 51,
			reload = 11,
			suppression = 15,
			concealment = 29
		}
		self.breech.stats_modifiers = {
			damage = 1
		}
		
		self.chinchilla.FIRE_MODE = "single"
		self.chinchilla.fire_mode_data = {
			fire_rate = 0.166
		}
		self.chinchilla.single = {
			fire_rate = 0.166
		}
		self.chinchilla.timers = {
			reload_not_empty = 2.97,
			reload_empty = 2.97,
			unequip = 0.5,
			equip = 0.45
		}
		
		self.chinchilla.CLIP_AMMO_MAX = 6
		self.chinchilla.NR_CLIPS_MAX = 9
		self.chinchilla.AMMO_MAX = self.chinchilla.CLIP_AMMO_MAX * self.chinchilla.NR_CLIPS_MAX
		self.chinchilla.AMMO_PICKUP = {
			0.54,  
			1.89
		}
		
		self.chinchilla.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.chinchilla.kick = {
			standing = self.glock_17.kick.standing
		}
		self.chinchilla.kick.crouching = self.chinchilla.kick.standing
		self.chinchilla.kick.steelsight = self.chinchilla.kick.standing
		
		self.chinchilla.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 180,
			alert_size = 7,
			spread = 20,
			spread_moving = 5,
			recoil = 2,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 7,
			concealment = 28
		}
		self.chinchilla.stats_modifiers = {
			damage = 1
		}
		
		--Crosskill Guard
		self.shrew.FIRE_MODE = "single"
		self.shrew.fire_mode_data = {
			fire_rate = 0.125
		}
		self.shrew.single = {
			fire_rate = 0.125
		}
		self.shrew.timers = {
			reload_not_empty = 1.47,
			reload_empty = 2.12,
			unequip = 0.5,
			equip = 0.35
		}
		
		self.shrew.CLIP_AMMO_MAX = 17
		self.shrew.NR_CLIPS_MAX = 9
		self.shrew.AMMO_MAX = self.shrew.CLIP_AMMO_MAX * self.shrew.NR_CLIPS_MAX
		self.shrew.AMMO_PICKUP = {
			1.53,
			5.36
		}
		
		self.shrew.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.shrew.kick = {
			standing = {
				1.2,
				1.8,
				-0.5,
				0.5
			}
		}
		self.shrew.kick.crouching = self.shrew.kick.standing
		self.shrew.kick.steelsight = self.shrew.kick.standing
		
		self.shrew.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 37,
			alert_size = 7,
			spread = 17,
			spread_moving = 14,
			recoil = 16,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 16,
			concealment = 30
		}
		self.shrew.stats_modifiers = {
			damage = 1
		}
		
		--STRYK 18c
		self.glock_18c.FIRE_MODE = "auto"
		self.glock_18c.fire_mode_data = {
			fire_rate = 0.066
		}
		self.glock_18c.CAN_TOGGLE_FIREMODE = true
		self.glock_18c.auto = {
			fire_rate = 0.066
		}
		self.glock_18c.timers = {
			reload_not_empty = 1.47,
			reload_empty = 2.12,
			unequip = 0.5,
			equip = 0.35
		}
		
		self.glock_18c.CLIP_AMMO_MAX = 20
		self.glock_18c.NR_CLIPS_MAX = 8
		self.glock_18c.AMMO_MAX = self.glock_18c.CLIP_AMMO_MAX * self.glock_18c.NR_CLIPS_MAX
		self.glock_18c.AMMO_PICKUP = {
			1.60,
			5.60
		}
		
		self.glock_18c.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.glock_18c.kick = {
			standing = {
				0.3,
				0.4,
				-0.3,
				0.3
			}
		}
		self.glock_18c.kick.crouching = self.glock_18c.kick.standing
		self.glock_18c.kick.steelsight = self.glock_18c.kick.standing
		
		self.glock_18c.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 35,
			alert_size = 7,
			spread = 14,
			spread_moving = 14,
			recoil = 15,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 14,
			concealment = 29
		}
		self.glock_18c.stats_modifiers = {
			damage = 1
		}
		
		--Deagle
		self.deagle.FIRE_MODE = "single"
		self.deagle.fire_mode_data = {
			fire_rate = 0.25
		}
		self.deagle.single = {
			fire_rate = 0.25
		}
		self.deagle.timers = {
			reload_not_empty = 1.85,
			reload_empty = 3.1,
			unequip = 0.5,
			equip = 0.35
		}
		
		self.deagle.CLIP_AMMO_MAX = 10
		self.deagle.NR_CLIPS_MAX = 5
		self.deagle.AMMO_MAX = self.deagle.CLIP_AMMO_MAX * self.deagle.NR_CLIPS_MAX
		self.deagle.AMMO_PICKUP = {
			0.50,
			1.75
		}
		
		self.deagle.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.deagle.kick = {
			standing = self.glock_17.kick.standing
		}
		self.deagle.kick.crouching = self.deagle.kick.standing
		self.deagle.kick.steelsight = self.deagle.kick.standing
		
		self.deagle.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 120,
			alert_size = 7,
			spread = 20,
			spread_moving = 20,
			recoil = 8,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 7,
			concealment = 28
		}
		self.deagle.stats_modifiers = {
			damage = 1
		}
		
		--M13 9mm Pistol
		self.legacy.FIRE_MODE = "single"
		self.legacy.fire_mode_data = {
			fire_rate = 0.11
		}
		self.legacy.single = {
			fire_rate = 0.11
		}
		self.legacy.timers = {
			reload_not_empty = 1.5,
			reload_empty = 2.15,
			unequip = 0.5,
			equip = 0.35
		}
		
		self.legacy.CLIP_AMMO_MAX = 13
		self.legacy.NR_CLIPS_MAX = 12
		self.legacy.AMMO_MAX = self.legacy.CLIP_AMMO_MAX * self.legacy.NR_CLIPS_MAX
		self.legacy.AMMO_PICKUP = {
			1.56,
			5.46
		}
		
		self.legacy.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.legacy.kick = {
			standing = self.glock_17.kick.standing
		}
		self.legacy.kick.crouching = self.legacy.kick.standing
		self.legacy.kick.steelsight = self.legacy.kick.standing
		
		self.legacy.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 37,
			alert_size = 7,
			spread = 12,
			spread_moving = 12,
			recoil = 13,
			value = 4,
			extra_ammo = 51,
			reload = 11,
			suppression = 15,
			concealment = 30
		}
		self.legacy.stats_modifiers = {
			damage = 1
		}
		
		--Gruber Kurz
		self.ppk.FIRE_MODE = "single"
		self.ppk.fire_mode_data = {
			fire_rate = 0.125
		}
		self.ppk.single = {
			fire_rate = 0.125
		}
		self.ppk.timers = {
			reload_not_empty = 1.55,
			reload_empty = 2.12,
			unequip = 0.5,
			equip = 0.35
		}
		
		self.ppk.CLIP_AMMO_MAX = 14
		self.ppk.NR_CLIPS_MAX = 11
		self.ppk.AMMO_MAX = self.ppk.CLIP_AMMO_MAX * self.ppk.NR_CLIPS_MAX
		self.ppk.AMMO_PICKUP = {
			1.54,
			5.39
		}
		
		self.ppk.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.ppk.kick = {
			standing = self.glock_17.kick.standing
		}
		self.ppk.kick.crouching = self.ppk.kick.standing
		self.ppk.kick.steelsight = self.ppk.kick.standing
		
		self.ppk.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 37,
			alert_size = 7,
			spread = 12,
			spread_moving = 12,
			recoil = 16,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 18,
			concealment = 30
		}
		self.ppk.stats_modifiers = {
			damage = 1
		}
		
		--Signature .40
		self.p226.FIRE_MODE = "single"
		self.p226.fire_mode_data = {
			fire_rate = 0.166
		}
		self.p226.single = {
			fire_rate = 0.166
		}
		self.p226.timers = {
			reload_not_empty = 1.47,
			reload_empty = 2.12,
			unequip = 0.5,
			equip = 0.35
		}
		
		self.p226.CLIP_AMMO_MAX = 12
		self.p226.NR_CLIPS_MAX = 7
		self.p226.AMMO_MAX = self.p226.CLIP_AMMO_MAX * self.p226.NR_CLIPS_MAX
		self.p226.AMMO_PICKUP = {
			0.84,
			2.94
		}
		
		self.p226.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.p226.kick = {
			standing = self.glock_17.kick.standing
		}
		self.p226.kick.crouching = self.p226.kick.standing
		self.p226.kick.steelsight = self.p226.kick.standing
		
		self.p226.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 65,
			alert_size = 7,
			spread = 18,
			spread_moving = 18,
			recoil = 14,
			value = 4,
			extra_ammo = 51,
			reload = 11,
			suppression = 15,
			concealment = 29
		}
		self.p226.stats_modifiers = {
			damage = 1
		}
		
		--Baby Deagle
		self.sparrow.FIRE_MODE = "single"
		self.sparrow.fire_mode_data = {
			fire_rate = 0.25
		}
		self.sparrow.single = {
			fire_rate = 0.25
		}
		self.sparrow.timers = {
			reload_not_empty = 1.47,
			reload_empty = 2.12,
			unequip = 0.5,
			equip = 0.35
		}
		
		self.sparrow.CLIP_AMMO_MAX = 12
		self.sparrow.NR_CLIPS_MAX = 5
		self.sparrow.AMMO_MAX = self.sparrow.CLIP_AMMO_MAX * self.sparrow.NR_CLIPS_MAX
		self.sparrow.AMMO_PICKUP = {
			0.60,
			2.10
		}
		
		self.sparrow.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.sparrow.kick = {
			standing = self.glock_17.kick.standing
		}
		self.sparrow.kick.crouching = self.sparrow.kick.standing
		self.sparrow.kick.steelsight = self.sparrow.kick.standing
		
		self.sparrow.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 120,
			alert_size = 7,
			spread = 18,
			spread_moving = 18,
			recoil = 9,
			value = 4,
			extra_ammo = 51,
			reload = 11,
			suppression = 15,
			concealment = 29
		}
		self.sparrow.stats_modifiers = {
			damage = 1
		}
		
		--Contractor
		self.packrat.FIRE_MODE = "single"
		self.packrat.fire_mode_data = {
			fire_rate = 0.166
		}
		self.packrat.single = {
			fire_rate = 0.166
		}
		self.packrat.timers = {
			reload_not_empty = 1.52,
			reload_empty = 2.32,
			unequip = 0.5,
			equip = 0.35
		}
		
		self.packrat.CLIP_AMMO_MAX = 15
		self.packrat.NR_CLIPS_MAX = 6
		self.packrat.AMMO_MAX = self.packrat.CLIP_AMMO_MAX * self.packrat.NR_CLIPS_MAX
		self.packrat.AMMO_PICKUP = {
			0.90,
			3.15
		}
		
		self.packrat.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.packrat.kick = {
			standing = self.glock_17.kick.standing
		}
		self.packrat.kick.crouching = self.packrat.kick.standing
		self.packrat.kick.steelsight = self.packrat.kick.standing
		
		self.packrat.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 66,
			alert_size = 7,
			spread = 18,
			spread_moving = 18,
			recoil = 16,
			value = 4,
			extra_ammo = 51,
			reload = 11,
			suppression = 15,
			concealment = 29
		}
		self.packrat.stats_modifiers = {
			damage = 1
		}
		
		--LEO Pistol
		self.hs2000.FIRE_MODE = "single"
		self.hs2000.fire_mode_data = {
			fire_rate = 0.166
		}
		self.hs2000.single = {
			fire_rate = 0.166
		}
		self.hs2000.timers = {
			reload_not_empty = 1.47,
			reload_empty = 2.12,
			unequip = 0.5,
			equip = 0.5
		}
		
		self.hs2000.CLIP_AMMO_MAX = 19
		self.hs2000.NR_CLIPS_MAX = 5
		self.hs2000.AMMO_MAX = self.hs2000.CLIP_AMMO_MAX * self.hs2000.NR_CLIPS_MAX
		self.hs2000.AMMO_PICKUP = {
			0.95,
			3.33
		}
		
		self.hs2000.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.hs2000.kick = {
			standing = self.glock_17.kick.standing
		}
		self.hs2000.kick.crouching = self.hs2000.kick.standing
		self.hs2000.kick.steelsight = self.hs2000.kick.standing
		
		self.hs2000.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 65,
			alert_size = 7,
			spread = 18,
			spread_moving = 18,
			recoil = 14,
			value = 4,
			extra_ammo = 51,
			reload = 11,
			suppression = 15,
			concealment = 29
		}
		self.hs2000.stats_modifiers = {
			damage = 1
		}
		
		self.c96.FIRE_MODE = "single"
		self.c96.fire_mode_data = {
			fire_rate = 0.166
		}
		self.c96.single = {
			fire_rate = 0.166
		}
		self.c96.timers = {
			reload_not_empty = 4,
			reload_empty = 4.17,
			unequip = 0.5,
			equip = 0.35
		}
		
		self.c96.CLIP_AMMO_MAX = 10
		self.c96.NR_CLIPS_MAX = 9
		self.c96.AMMO_MAX = self.c96.CLIP_AMMO_MAX * self.c96.NR_CLIPS_MAX
		self.c96.AMMO_PICKUP = {
			0.90,
			3.15
		}
		
		self.c96.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.c96.kick = {
			standing = self.glock_17.kick.standing
		}
		self.c96.kick.crouching = self.c96.kick.standing
		self.c96.kick.steelsight = self.c96.kick.standing
		
		self.c96.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 65,
			alert_size = 7,
			spread = 21,
			spread_moving = 12,
			recoil = 16,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 14,
			concealment = 28
		}
		self.c96.stats_modifiers = {
			damage = 1
		}
		
		--Peacemaker
		self.peacemaker.FIRE_MODE = "single"
		self.peacemaker.fire_mode_data = {
			fire_rate = 0.25
		}
		self.peacemaker.CAN_TOGGLE_FIREMODE = false
		self.peacemaker.single = {
			fire_rate = 0.166
		}
		self.peacemaker.auto = {
			fire_rate = 0.166
		}
		self.peacemaker.timers = {
			shotgun_reload_enter = 1.4333333333333333,
			shotgun_reload_exit_empty = 0.3333333333333333,
			shotgun_reload_exit_not_empty = 0.3333333333333333,
			shotgun_reload_shell = 1,
			shotgun_reload_first_shell_offset = 0,
			unequip = 0.65,
			equip = 0.65
		}
		
		self.peacemaker.CLIP_AMMO_MAX = 6
		self.peacemaker.NR_CLIPS_MAX = 9
		self.peacemaker.AMMO_MAX = self.peacemaker.CLIP_AMMO_MAX * self.peacemaker.NR_CLIPS_MAX
		self.peacemaker.AMMO_PICKUP = {
			0.54,
			1.89
		}
		
		self.peacemaker.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.peacemaker.kick = {
			standing = {
				2.9,
				3,
				-0.5,
				0.5
			}
		}
		self.peacemaker.kick.crouching = self.peacemaker.kick.standing
		self.peacemaker.kick.steelsight = self.peacemaker.kick.standing
		
		self.peacemaker.stats = {
			zoom = 5,
			total_ammo_mod = 21,
			damage = 180,
			alert_size = 7,
			spread = 22,
			spread_moving = 22,
			recoil = 4,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 5,
			concealment = 26
		}
		self.peacemaker.stats_modifiers = {
			damage = 1
		}
		
		--Matever .357
		self.mateba.FIRE_MODE = "single"
		self.mateba.fire_mode_data = {
			fire_rate = 0.166
		}
		self.mateba.single = {
			fire_rate = 0.166
		}
		self.mateba.timers = {
			reload_not_empty = 3.6,
			reload_empty = 3.6,
			unequip = 0.5,
			equip = 0.45
		}
		
		self.mateba.CLIP_AMMO_MAX = 6
		self.mateba.NR_CLIPS_MAX = 9
		self.mateba.AMMO_MAX = self.mateba.CLIP_AMMO_MAX * self.mateba.NR_CLIPS_MAX
		self.mateba.AMMO_PICKUP = {
			0.54,
			1.89
		}
		
		self.mateba.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.mateba.kick = {
			standing = self.glock_17.kick.standing
		}
		self.mateba.kick.crouching = self.mateba.kick.standing
		self.mateba.kick.steelsight = self.mateba.kick.standing
		
		self.mateba.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 180,
			alert_size = 7,
			spread = 22,
			spread_moving = 22,
			recoil = 4,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 7,
			concealment = 20
		}
		self.mateba.stats_modifiers = {
			damage = 1
		}
		
		--Interceptor .45
		self.usp.FIRE_MODE = "single"
		self.usp.fire_mode_data = {
			fire_rate = 0.166
		}
		self.usp.single = {
			fire_rate = 0.166
		}
		self.usp.timers = {
			reload_not_empty = 1.47,
			reload_empty = 2.2,
			unequip = 0.5,
			equip = 0.35
		}
		
		self.usp.CLIP_AMMO_MAX = 13
		self.usp.NR_CLIPS_MAX = 7
		self.usp.AMMO_MAX = self.usp.CLIP_AMMO_MAX * self.usp.NR_CLIPS_MAX
		self.usp.AMMO_PICKUP = {
			0.91,
			3.18
		}
		
		self.usp.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.usp.kick = {
			standing = {
				1.2,
				1.8,
				-0.5,
				0.5
			},
			crouching = self.glock_17.kick.standing,
			steelsight = self.glock_17.kick.standing
		}
		
		self.usp.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 65,
			alert_size = 7,
			spread = 18,
			spread_moving = 18,
			recoil = 14,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 16,
			concealment = 29
		}
		self.usp.stats_modifiers = {
			damage = 1
		}
		
		--Chimano Custom
		self.g22c.FIRE_MODE = "single"
		self.g22c.fire_mode_data = {
			fire_rate = 0.166
		}
		self.g22c.single = {
			fire_rate = 0.166
		}
		self.g22c.timers = {
			reload_not_empty = 1.47,
			reload_empty = 2.2,
			unequip = 0.5,
			equip = 0.35
		}
		
		self.g22c.CLIP_AMMO_MAX = 16
		self.g22c.NR_CLIPS_MAX = 6
		self.g22c.AMMO_MAX = self.g22c.CLIP_AMMO_MAX * self.g22c.NR_CLIPS_MAX
		self.g22c.AMMO_PICKUP = {
			0.96,
			3.36
		}
		
		self.g22c.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.g22c.kick = {
			standing = {
				1.2,
				1.8,
				-0.5,
				0.5
			},
			crouching = self.glock_17.kick.standing,
			steelsight = self.glock_17.kick.standing
		}
		
		self.g22c.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 65,
			alert_size = 7,
			spread = 18,
			spread_moving = 18,
			recoil = 14,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 15,
			concealment = 29
		}
		self.g22c.stats_modifiers = {
			damage = 1
		}
		
		--5/7 AP Pistol
		self.lemming.FIRE_MODE = "single"
		self.lemming.fire_mode_data = {
			fire_rate = 0.1
		}
		self.lemming.single = {
			fire_rate = 0.1
		}
		self.lemming.timers = {
			reload_not_empty = 1.5,
			reload_empty = 2.15,
			unequip = 0.5,
			equip = 0.35
		}
		
		self.lemming.CLIP_AMMO_MAX = 15
		self.lemming.NR_CLIPS_MAX = 3
		self.lemming.AMMO_MAX = self.lemming.CLIP_AMMO_MAX * self.lemming.NR_CLIPS_MAX
		self.lemming.AMMO_PICKUP = {
			0.22,
			0.674
		}
		
		self.lemming.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.lemming.kick = {
			standing = self.glock_17.kick.standing
		}
		self.lemming.kick.crouching = self.lemming.kick.standing
		self.lemming.kick.steelsight = self.lemming.kick.standing
		
		self.lemming.can_shoot_through_enemy = true
		self.lemming.can_shoot_through_shield = true
		self.lemming.can_shoot_through_wall = true
		self.lemming.armor_piercing_chance = 1
		self.lemming.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 120,
			alert_size = 7,
			spread = 13,
			spread_moving = 18,
			recoil = 10,
			value = 4,
			extra_ammo = 51,
			reload = 11,
			suppression = 15,
			concealment = 29
		}
		self.lemming.stats_modifiers = {
			damage = 1
		}
		
		--Chimano Compact
		self.g26.FIRE_MODE = "single"
		self.g26.fire_mode_data = {
			fire_rate = 0.125
		}
		self.g26.single = {
			fire_rate = 0.125
		}
		self.g26.timers = {
			reload_not_empty = 1.47,
			reload_empty = 2.12,
			unequip = 0.5,
			equip = 0.35
		}
		
		self.g26.CLIP_AMMO_MAX = 10
		self.g26.NR_CLIPS_MAX = 15
		self.g26.AMMO_MAX = self.g26.CLIP_AMMO_MAX * self.g26.NR_CLIPS_MAX
		self.g26.AMMO_PICKUP = {
			1.50,
			5.25
		}
		
		self.g26.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.g26.kick = {
			standing = self.glock_17.kick.standing
		}
		self.g26.kick.crouching = self.g26.kick.standing
		self.g26.kick.steelsight = self.g26.kick.standing
		
		self.g26.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 37,
			alert_size = 7,
			spread = 14,
			spread_moving = 14,
			recoil = 16,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 18,
			concealment = 30
		}
		self.g26.stats_modifiers = {
			damage = 1
		}
		
		
		--Pistols end here.
		
		--SMGs begin here.
		
		--Mark 10
		self.mac10.FIRE_MODE = "auto"
		self.mac10.fire_mode_data = {
			fire_rate = 0.06
		}
		self.mac10.CAN_TOGGLE_FIREMODE = true
		self.mac10.auto = {
			fire_rate = 0.06
		}
		self.mac10.timers = {
			reload_not_empty = 2,
			reload_empty = 2.7,
			unequip = 0.5,
			equip = 0.5
		}
		
		self.mac10.CLIP_AMMO_MAX = 40
		self.mac10.NR_CLIPS_MAX = 4
		self.mac10.AMMO_MAX = self.mac10.CLIP_AMMO_MAX * self.mac10.NR_CLIPS_MAX
		self.mac10.AMMO_PICKUP = {
			4.80,
			8.80
		}
		
		self.mac10.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.mac10.kick = {
			standing = self.mp9.kick.standing
		}
		self.mac10.kick.crouching = self.mac10.kick.standing
		self.mac10.kick.steelsight = self.mac10.kick.standing
		
		self.mac10.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 58,
			alert_size = 7,
			spread = 13,
			spread_moving = 13,
			recoil = 17,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 14,
			concealment = 27
		}
		self.mac10.stats_modifiers = {
			damage = 1
		}
		
		--Compact 5
		self.new_mp5.FIRE_MODE = "auto"
		self.new_mp5.fire_mode_data = {
			fire_rate = 0.08
		}
		self.new_mp5.CAN_TOGGLE_FIREMODE = true
		self.new_mp5.auto = {
			fire_rate = 0.08
		}
		self.new_mp5.timers = {
			reload_not_empty = 2.4,
			reload_empty = 3.6,
			unequip = 0.6,
			equip = 0.6
		}
		
		self.new_mp5.CLIP_AMMO_MAX = 30
		self.new_mp5.NR_CLIPS_MAX = 7
		self.new_mp5.AMMO_MAX = self.new_mp5.CLIP_AMMO_MAX * self.new_mp5.NR_CLIPS_MAX
		self.new_mp5.AMMO_PICKUP = {
			6.30,
			11.55
		}
		
		self.new_mp5.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.new_mp5.kick = {
			standing = self.new_m4.kick.standing
		}
		self.new_mp5.kick.crouching = self.new_mp5.kick.standing
		self.new_mp5.kick.steelsight = self.new_mp5.kick.standing
		
		self.new_mp5.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 44,
			alert_size = 7,
			spread = 12,
			spread_moving = 8,
			recoil = 21,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 17,
			concealment = 24
		}
		self.new_mp5.stats_modifiers = {
			damage = 1
		}
		
		--CMP
		self.mp9.FIRE_MODE = "auto"
		self.mp9.fire_mode_data = {
			fire_rate = 0.063
		}
		self.mp9.CAN_TOGGLE_FIREMODE = true
		self.mp9.auto = {
			fire_rate = 0.063
		}
		self.mp9.timers = {
			reload_not_empty = 1.51,
			reload_empty = 2.48,
			unequip = 0.5,
			equip = 0.4
		}
		
		self.mp9.CLIP_AMMO_MAX = 30
		self.mp9.NR_CLIPS_MAX = 7
		self.mp9.AMMO_MAX = self.mp9.CLIP_AMMO_MAX * self.mp9.NR_CLIPS_MAX
		self.mp9.AMMO_PICKUP = {
			6.30,
			11.55
		}
		
		self.mp9.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.mp9.kick = {
			standing = {
				-1.2,
				1.2,
				-1,
				1
			}
		}
		self.mp9.kick.crouching = self.mp9.kick.standing
		self.mp9.kick.steelsight = self.mp9.kick.standing
		
		self.mp9.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 44,
			alert_size = 7,
			spread = 8,
			spread_moving = 8,
			recoil = 20,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 16,
			concealment = 26
		}
		self.mp9.stats_modifiers = {
			damage = 1
		}
		
		--PARA
		self.olympic.FIRE_MODE = "auto"
		self.olympic.fire_mode_data = {
			fire_rate = 0.088
		}
		self.olympic.CAN_TOGGLE_FIREMODE = true
		self.olympic.auto = {
			fire_rate = 0.088
		}
		self.olympic.timers = {
			reload_not_empty = 2.16,
			reload_empty = 3.23,
			unequip = 0.6,
			equip = 0.5
		}
		
		self.olympic.CLIP_AMMO_MAX = 25
		self.olympic.NR_CLIPS_MAX = 6
		self.olympic.AMMO_MAX = self.olympic.CLIP_AMMO_MAX * self.olympic.NR_CLIPS_MAX
		self.olympic.AMMO_PICKUP = {
			4.50,
			8.25
		}
		
		self.olympic.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 55,
			alert_size = 7,
			spread = 12,
			spread_moving = 11,
			recoil = 17,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 10,
			concealment = 24
		}
		self.olympic.stats_modifiers = {
			damage = 1
		}
		
		--Heather SMG
		self.sr2.FIRE_MODE = "auto"
		self.sr2.fire_mode_data = {
			fire_rate = 0.08
		}
		self.sr2.CAN_TOGGLE_FIREMODE = true
		self.sr2.auto = {
			fire_rate = 0.08
		}
		self.sr2.timers = {
			reload_not_empty = 2.07,
			reload_empty = 4,
			unequip = 0.55,
			equip = 0.5
		}
		
		self.sr2.CLIP_AMMO_MAX = 32
		self.sr2.NR_CLIPS_MAX = 5
		self.sr2.AMMO_MAX = self.sr2.CLIP_AMMO_MAX * self.sr2.NR_CLIPS_MAX
		self.sr2.AMMO_PICKUP = {
			4.8,
			8.8
		}
		
		self.sr2.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.sr2.kick = {
			standing = {
				-0.3,
				0.6,
				-0.5,
				0.5
			},
			crouching = self.cobray.kick.standing,
			steelsight = self.cobray.kick.standing
		}
		
		self.sr2.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 58,
			alert_size = 7,
			spread = 14,
			spread_moving = 14,
			recoil = 14,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 14,
			concealment = 28
		}
		self.sr2.stats_modifiers = {
			damage = 1
		}
		
		--MP40
		self.erma.FIRE_MODE = "auto"
		self.erma.fire_mode_data = {
			fire_rate = 0.1
		}
		self.erma.auto = {
			fire_rate = 0.1
		}
		self.erma.timers = {
			reload_not_empty = 1.9,
			reload_empty = 3.05,
			unequip = 0.5,
			equip = 0.6
		}
		
		self.erma.CLIP_AMMO_MAX = 40
		self.erma.NR_CLIPS_MAX = 2
		self.erma.AMMO_MAX = self.erma.CLIP_AMMO_MAX * self.erma.NR_CLIPS_MAX
		self.erma.AMMO_PICKUP = {
			0.8,
			2.8
		}
		
		self.erma.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.erma.kick = {
			standing = self.mp9.kick.standing
		}
		self.erma.kick.crouching = self.erma.kick.standing
		self.erma.kick.steelsight = self.erma.kick.standing
		
		self.erma.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 99,
			alert_size = 7,
			spread = 18,
			spread_moving = 18,
			recoil = 12,
			value = 5,
			extra_ammo = 51,
			reload = 11,
			suppression = 14,
			concealment = 24
		}
		self.erma.stats_modifiers = {
			damage = 1
		}
		
		--Krinkov SMG
		self.akmsu.FIRE_MODE = "auto"
		self.akmsu.fire_mode_data = {
			fire_rate = 0.073
		}
		self.akmsu.CAN_TOGGLE_FIREMODE = true
		self.akmsu.auto = {
			fire_rate = 0.073
		}
		self.akmsu.timers = {
			reload_not_empty = 2.15,
			reload_empty = 3.9,
			unequip = 0.55,
			equip = 0.6
		}
		
		self.akmsu.CLIP_AMMO_MAX = 30
		self.akmsu.NR_CLIPS_MAX = 3
		self.akmsu.AMMO_MAX = self.akmsu.CLIP_AMMO_MAX * self.akmsu.NR_CLIPS_MAX
		self.akmsu.AMMO_PICKUP = {
			0.9,
			3.15
		}
		
		self.akmsu.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.akmsu.kick = {
			standing = self.new_m4.kick.standing
		}
		self.akmsu.kick.crouching = self.akmsu.kick.standing
		self.akmsu.kick.steelsight = self.akmsu.kick.standing
		
		self.akmsu.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 99,
			alert_size = 7,
			spread = 16,
			spread_moving = 16,
			recoil = 12,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 8,
			concealment = 21
		}
		self.akmsu.stats_modifiers = {
			damage = 1
		}
		
		--Kobus 90
		self.p90.FIRE_MODE = "auto"
		self.p90.fire_mode_data = {
			fire_rate = 0.066
		}
		self.p90.CAN_TOGGLE_FIREMODE = true
		self.p90.auto = {
			fire_rate = 0.066
		}
		self.p90.timers = {
			reload_not_empty = 2.55,
			reload_empty = 3.4,
			unequip = 0.68,
			equip = 0.65
		}
		
		self.p90.CLIP_AMMO_MAX = 50
		self.p90.NR_CLIPS_MAX = 3
		self.p90.AMMO_MAX = self.p90.CLIP_AMMO_MAX * self.p90.NR_CLIPS_MAX
		self.p90.AMMO_PICKUP = {
			4.5,
			8.25
		}
		
		self.p90.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.p90.kick = {
			standing = self.new_m4.kick.standing
		}
		self.p90.kick.crouching = self.p90.kick.standing
		self.p90.kick.steelsight = self.p90.kick.standing
		
		self.p90.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 56,
			alert_size = 7,
			spread = 14,
			spread_moving = 14,
			recoil = 16,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 12,
			concealment = 25
		}
		self.p90.stats_modifiers = {
			damage = 1
		}
		
		--Signature SMG
		self.shepheard.FIRE_MODE = "auto"
		self.shepheard.fire_mode_data = {
			fire_rate = 0.08
		}
		self.shepheard.CAN_TOGGLE_FIREMODE = true
		self.shepheard.auto = {
			fire_rate = 0.08
		}
		self.shepheard.timers = {
			reload_not_empty = 2.11,
			reload_empty = 2.85,
			unequip = 0.6,
			equip = 0.5
		}
		
		self.shepheard.CLIP_AMMO_MAX = 20
		self.shepheard.NR_CLIPS_MAX = 10
		self.shepheard.AMMO_MAX = self.shepheard.CLIP_AMMO_MAX * self.shepheard.NR_CLIPS_MAX
		self.shepheard.AMMO_PICKUP = {
			2,
			7
		}
		
		self.shepheard.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.shepheard.kick = {
			standing = {
				-0.2,
				0.4,
				-1,
				1
			}
		}
		self.shepheard.kick.crouching = self.shepheard.kick.standing
		self.shepheard.kick.steelsight = self.shepheard.kick.standing
		
		self.shepheard.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 44,
			alert_size = 7,
			spread = 12,
			spread_moving = 14,
			recoil = 12,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 14,
			concealment = 24
		}
		self.shepheard.stats_modifiers = {
			damage = 1
		}
		
		--Swedish K
		self.m45.FIRE_MODE = "auto"
		self.m45.fire_mode_data = {
			fire_rate = 0.1
		}
		self.m45.auto = {
			fire_rate = 0.1
		}
		self.m45.timers = {
			reload_not_empty = 2.85,
			reload_empty = 3.9,
			unequip = 0.5,
			equip = 0.6
		}
		
		self.m45.CLIP_AMMO_MAX = 40
		self.m45.NR_CLIPS_MAX = 2
		self.m45.AMMO_MAX = self.m45.CLIP_AMMO_MAX * self.m45.NR_CLIPS_MAX
		self.m45.AMMO_PICKUP = {
			0.80,
			2.80
		}
		
		self.m45.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.m45.kick = {
			standing = self.mp9.kick.standing
		}
		self.m45.kick.crouching = self.m45.kick.standing
		self.m45.kick.steelsight = self.m45.kick.standing
		
		self.m45.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 99,
			alert_size = 7,
			spread = 18,
			spread_moving = 18,
			recoil = 12,
			value = 5,
			extra_ammo = 51,
			reload = 11,
			suppression = 14,
			concealment = 24
		}
		self.m45.stats_modifiers = {
			damage = 1
		}
		
		--SpecOps
		self.mp7.FIRE_MODE = "auto"
		self.mp7.fire_mode_data = {
			fire_rate = 0.063
		}
		self.mp7.CAN_TOGGLE_FIREMODE = true
		self.mp7.auto = {
			fire_rate = 0.063
		}
		self.mp7.timers = {
			reload_not_empty = 1.96,
			reload_empty = 2.45,
			unequip = 0.6,
			equip = 0.5
		}
		
		self.mp7.CLIP_AMMO_MAX = 20
		self.mp7.NR_CLIPS_MAX = 8
		self.mp7.AMMO_MAX = self.mp7.CLIP_AMMO_MAX * self.mp7.NR_CLIPS_MAX
		self.mp7.AMMO_PICKUP = {
			4.8,
			8.8
		}
		
		self.mp7.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.mp7.kick = {
			standing = self.new_m4.kick.standing
		}
		self.mp7.kick.crouching = self.mp7.kick.standing
		self.mp7.kick.steelsight = self.mp7.kick.standing
		
		self.mp7.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 58,
			alert_size = 7,
			spread = 17,
			spread_moving = 17,
			recoil = 18,
			value = 7,
			extra_ammo = 51,
			reload = 11,
			suppression = 16,
			concealment = 23
		}
		self.mp7.stats_modifiers = {
			damage = 1
		}
		
		--CR 805B
		self.hajk.FIRE_MODE = "auto"
		self.hajk.fire_mode_data = {
			fire_rate = 0.08
		}
		self.hajk.CAN_TOGGLE_FIREMODE = true
		self.hajk.auto = {
			fire_rate = 0.08
		}
		self.hajk.timers = {
			reload_not_empty = 2,
			reload_empty = 3.5,
			unequip = 0.6,
			equip = 0.6
		}
		
		self.hajk.CLIP_AMMO_MAX = 30
		self.hajk.NR_CLIPS_MAX = 3
		self.hajk.AMMO_MAX = self.hajk.CLIP_AMMO_MAX * self.hajk.NR_CLIPS_MAX
		self.hajk.AMMO_PICKUP = {
			0.9,
			3.15
		}
		
		self.hajk.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.hajk.kick = {
			standing = {
				-0.6,
				1.2,
				-1,
				1
			}
		}
		self.hajk.kick.crouching = self.hajk.kick.standing
		self.hajk.kick.steelsight = self.hajk.kick.standing
		
		self.hajk.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 99,
			alert_size = 7,
			spread = 19,
			spread_moving = 15,
			recoil = 18,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 14,
			concealment = 18
		}
		self.hajk.stats_modifiers = {
			damage = 1
		}
		
		--Cobra SMGs
		self.scorpion.FIRE_MODE = "auto"
		self.scorpion.fire_mode_data = {
			fire_rate = 0.06
		}
		self.scorpion.CAN_TOGGLE_FIREMODE = true
		self.scorpion.auto = {
			fire_rate = 0.06
		}
		self.scorpion.timers = {
			reload_not_empty = 2,
			reload_empty = 2.75,
			unequip = 0.7,
			equip = 0.5
		}
		
		self.scorpion.CLIP_AMMO_MAX = 20
		self.scorpion.NR_CLIPS_MAX = 11
		self.scorpion.AMMO_MAX = self.scorpion.CLIP_AMMO_MAX * self.scorpion.NR_CLIPS_MAX
		self.scorpion.AMMO_PICKUP = {
			6.6,
			12.10
		}
		
		self.scorpion.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.scorpion.kick = {
			standing = self.new_m4.kick.standing
		}
		self.scorpion.kick.crouching = self.scorpion.kick.standing
		self.scorpion.kick.steelsight = self.scorpion.kick.standing
		
		self.scorpion.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 44,
			alert_size = 7,
			spread = 8,
			spread_moving = 8,
			recoil = 18,
			value = 7,
			extra_ammo = 51,
			reload = 11,
			suppression = 17,
			concealment = 28
		}
		self.scorpion.stats_modifiers = {
			damage = 1
		}
		
		--Micro Uzi
		self.baka.FIRE_MODE = "auto"
		self.baka.fire_mode_data = {
			fire_rate = 0.05
		}
		self.baka.CAN_TOGGLE_FIREMODE = true
		self.baka.auto = {
			fire_rate = 0.05
		}
		self.baka.timers = {
			reload_not_empty = 1.85,
			reload_empty = 2.6,
			unequip = 0.7,
			equip = 0.5
		}
		
		self.baka.CLIP_AMMO_MAX = 32
		self.baka.NR_CLIPS_MAX = 7
		self.baka.AMMO_MAX = self.baka.CLIP_AMMO_MAX * self.baka.NR_CLIPS_MAX
		self.baka.AMMO_PICKUP = {
			6.72,
			12.32
		}
		
		self.baka.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.baka.kick = {
			standing = {
				-0.1,
				0.6,
				-1.2,
				1.2
			}
		}
		self.baka.kick.crouching = self.baka.kick.standing
		self.baka.kick.steelsight = self.baka.kick.standing
		
		self.baka.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 44,
			alert_size = 7,
			spread = 8,
			spread_moving = 4,
			recoil = 20,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 14,
			concealment = 29
		}
		self.baka.stats_modifiers = {
			damage = 1
		}
		
		--Jackal SMGs
		self.schakal.FIRE_MODE = "auto"
		self.schakal.fire_mode_data = {
			fire_rate = 0.092
		}
		self.schakal.CAN_TOGGLE_FIREMODE = true
		self.schakal.auto = {
			fire_rate = 0.092
		}
		self.schakal.timers = {
			reload_not_empty = 2.36,
			reload_empty = 3.62,
			unequip = 0.6,
			equip = 0.5
		}
		
		self.schakal.CLIP_AMMO_MAX = 30
		self.schakal.NR_CLIPS_MAX = 3
		self.schakal.AMMO_MAX = self.schakal.CLIP_AMMO_MAX * self.schakal.NR_CLIPS_MAX
		self.schakal.AMMO_PICKUP = {
			0.9,
			3.15
		}
		
		self.schakal.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.schakal.kick = {
			standing = {
				-0.2,
				0.4,
				-1,
				1
			}
		}
		self.schakal.kick.crouching = self.schakal.kick.standing
		self.schakal.kick.steelsight = self.schakal.kick.standing
		
		self.schakal.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 99,
			alert_size = 7,
			spread = 16,
			spread_moving = 14,
			recoil = 14,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 14,
			concealment = 24
		}
		self.schakal.stats_modifiers = {
			damage = 1
		}
		
		--Blaster 9mm
		self.tec9.FIRE_MODE = "auto"
		self.tec9.fire_mode_data = {
			fire_rate = 0.067
		}
		self.tec9.CAN_TOGGLE_FIREMODE = true
		self.tec9.auto = {
			fire_rate = 0.067
		}
		self.tec9.timers = {
			reload_not_empty = 2.315,
			reload_empty = 3.28,
			unequip = 0.6,
			equip = 0.5
		}
		
		self.tec9.CLIP_AMMO_MAX = 20
		self.tec9.NR_CLIPS_MAX = 11
		self.tec9.AMMO_MAX = self.tec9.CLIP_AMMO_MAX * self.tec9.NR_CLIPS_MAX
		self.tec9.AMMO_PICKUP = {
			6.6,
			12.10
		}
		
		self.tec9.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.tec9.kick = {
			standing = self.new_m4.kick.standing
		}
		self.tec9.kick.crouching = self.tec9.kick.standing
		self.tec9.kick.steelsight = self.tec9.kick.standing
		
		self.tec9.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 44,
			alert_size = 7,
			spread = 8,
			spread_moving = 8,
			recoil = 20,
			value = 7,
			extra_ammo = 51,
			reload = 11,
			suppression = 12,
			concealment = 27
		}
		self.tec9.stats_modifiers = {
			damage = 1
		}
		
		--Kross Vertex
		self.polymer.FIRE_MODE = "auto"
		self.polymer.fire_mode_data = {
			fire_rate = 0.05
		}
		self.polymer.CAN_TOGGLE_FIREMODE = true
		self.polymer.auto = {
			fire_rate = 0.05
		}
		self.polymer.timers = {
			reload_not_empty = 2,
			reload_empty = 2.5,
			unequip = 0.6,
			equip = 0.5
		}
		
		self.polymer.CLIP_AMMO_MAX = 30
		self.polymer.NR_CLIPS_MAX = 5
		self.polymer.AMMO_MAX = self.polymer.CLIP_AMMO_MAX * self.polymer.NR_CLIPS_MAX
		self.polymer.AMMO_PICKUP = {
			4.5,
			8.25
		}
		
		self.polymer.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.polymer.kick = {
			standing = {
				-0.2,
				0.4,
				-1,
				1
			}
		}
		self.polymer.kick.crouching = self.polymer.kick.standing
		self.polymer.kick.steelsight = self.polymer.kick.standing
		
		self.polymer.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 58,
			alert_size = 7,
			spread = 14,
			spread_moving = 14,
			recoil = 20,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 14,
			concealment = 20
		}
		self.polymer.stats_modifiers = {
			damage = 1
		}
		
		--Tatonka
		self.coal.FIRE_MODE = "auto"
		self.coal.fire_mode_data = {
			fire_rate = 0.092
		}
		self.coal.CAN_TOGGLE_FIREMODE = true
		self.coal.auto = {
			fire_rate = 0.092
		}
		self.coal.timers = {
			reload_not_empty = 3.25,
			reload_empty = 4.25,
			unequip = 0.6,
			equip = 0.5
		}
		
		self.coal.CLIP_AMMO_MAX = 64
		self.coal.NR_CLIPS_MAX = 2
		self.coal.AMMO_MAX = self.coal.CLIP_AMMO_MAX * self.coal.NR_CLIPS_MAX
		self.coal.AMMO_PICKUP = {
			1.28,
			4.48
		}
		
		self.coal.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.coal.kick = {
			standing = {
				-0.2,
				0.4,
				-1,
				1
			}
		}
		self.coal.kick.crouching = self.coal.kick.standing
		self.coal.kick.steelsight = self.coal.kick.standing
		
		self.coal.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 99,
			alert_size = 7,
			spread = 14,
			spread_moving = 14,
			recoil = 14,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 14,
			concealment = 24
		}
		self.coal.stats_modifiers = {
			damage = 1
		}
		
		--Patchett L2A1
		self.sterling.FIRE_MODE = "auto"
		self.sterling.fire_mode_data = {
			fire_rate = 0.11
		}
		self.sterling.CAN_TOGGLE_FIREMODE = true
		self.sterling.auto = {
			fire_rate = 0.11
		}
		self.sterling.timers = {
			reload_not_empty = 2.3,
			reload_empty = 3.3,
			unequip = 0.55,
			equip = 0.65
		}
		
		self.sterling.CLIP_AMMO_MAX = 20
		self.sterling.NR_CLIPS_MAX = 11
		self.sterling.AMMO_MAX = self.sterling.CLIP_AMMO_MAX * self.sterling.NR_CLIPS_MAX
		self.sterling.AMMO_PICKUP = {
			6.6,
			12.10
		}
		
		self.sterling.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.sterling.kick = {
			standing = self.new_m4.kick.standing
		}
		self.sterling.kick.crouching = self.sterling.kick.standing
		self.sterling.kick.steelsight = self.sterling.kick.standing
		
		self.sterling.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 42,
			alert_size = 7,
			spread = 8,
			spread_moving = 8,
			recoil = 20,
			value = 7,
			extra_ammo = 51,
			reload = 11,
			suppression = 12,
			concealment = 20
		}
		self.sterling.stats_modifiers = {
			damage = 1
		}
		
		--Uzi SMG
		self.uzi.FIRE_MODE = "auto"
		self.uzi.fire_mode_data = {
			fire_rate = 0.086
		}
		self.uzi.CAN_TOGGLE_FIREMODE = true
		self.uzi.auto = {
			fire_rate = 0.086
		}
		self.uzi.timers = {
			reload_not_empty = 2.45,
			reload_empty = 3.52,
			unequip = 0.55,
			equip = 0.6
		}
		
		self.uzi.CLIP_AMMO_MAX = 40
		self.uzi.NR_CLIPS_MAX = 5
		self.uzi.AMMO_MAX = self.uzi.CLIP_AMMO_MAX * self.uzi.NR_CLIPS_MAX
		self.uzi.AMMO_PICKUP = {
			6,
			11
		}
		
		self.uzi.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.uzi.kick = {
			standing = self.new_m4.kick.standing
		}
		self.uzi.kick.crouching = self.uzi.kick.standing
		self.uzi.kick.steelsight = self.uzi.kick.standing
		
		self.uzi.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 44,
			alert_size = 7,
			spread = 14,
			spread_moving = 14,
			recoil = 18,
			value = 7,
			extra_ammo = 51,
			reload = 11,
			suppression = 12,
			concealment = 24
		}
		self.uzi.stats_modifiers = {
			damage = 1
		}
		
		--Chicago Typewriter
		self.m1928.FIRE_MODE = "auto"
		self.m1928.fire_mode_data = {
			fire_rate = 0.083
		}
		self.m1928.CAN_TOGGLE_FIREMODE = true
		self.m1928.auto = {
			fire_rate = 0.083
		}
		self.m1928.timers = {
			reload_not_empty = 3.5,
			reload_empty = 4.5,
			unequip = 0.6,
			equip = 0.75
		}
		
		self.m1928.CLIP_AMMO_MAX = 50
		self.m1928.NR_CLIPS_MAX = 3
		self.m1928.AMMO_MAX = self.m1928.CLIP_AMMO_MAX * self.m1928.NR_CLIPS_MAX
		self.m1928.AMMO_PICKUP = {
			4.5,
			8.25
		}
		
		self.m1928.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.m1928.kick = {
			standing = {
				0.3,
				1.5,
				-1.2,
				1.2
			}
		}
		self.m1928.kick.crouching = self.m1928.kick.standing
		self.m1928.kick.steelsight = self.m1928.kick.standing
		
		self.m1928.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 58,
			alert_size = 8,
			spread = 13,
			spread_moving = 13,
			recoil = 18,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 12,
			concealment = 18
		}
		self.m1928.stats_modifiers = {
			damage = 1
		}
		
		--Jacket's Piece
		self.cobray.FIRE_MODE = "auto"
		self.cobray.fire_mode_data = {
			fire_rate = 0.05
		}
		self.cobray.CAN_TOGGLE_FIREMODE = true
		self.cobray.auto = {
			fire_rate = 0.05
		}
		self.cobray.timers = {
			reload_not_empty = 2.05,
			reload_empty = 4.35,
			unequip = 0.55,
			equip = 0.5
		}
		
		self.cobray.CLIP_AMMO_MAX = 32
		self.cobray.NR_CLIPS_MAX = 5
		self.cobray.AMMO_MAX = self.cobray.CLIP_AMMO_MAX * self.cobray.NR_CLIPS_MAX
		self.cobray.AMMO_PICKUP = {
			4.8,
			8.8
		}
		
		self.cobray.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.cobray.kick = {
			standing = {
				-0.6,
				1.2,
				-1,
				1
			}
		}
		self.cobray.kick.crouching = self.cobray.kick.standing
		self.cobray.kick.steelsight = self.cobray.kick.standing
		
		self.cobray.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 57,
			alert_size = 7,
			spread = 14,
			spread_moving = 14,
			recoil = 18,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 14,
			concealment = 25
		}
		self.cobray.stats_modifiers = {
			damage = 1
		}
		
		--SMGs end here.
		
		--Shotguns begin here.
		
		--Reinfeld 880
		self.r870.FIRE_MODE = "single"
		self.r870.fire_mode_data = {
			fire_rate = 0.575
		}
		self.r870.single = {
			fire_rate = 0.575
		}
		self.r870.timers = {
			unequip = 0.85,
			equip = 0.85
		}
		
		self.r870.CLIP_AMMO_MAX = 6
		self.r870.AMMO_MAX = 50
		self.r870.AMMO_PICKUP = {
			0.42,
			1.47
		}
		
		self.r870.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.r870.kick = {
			standing = {
				1.9,
				2,
				-0.2,
				0.2
			}
		}
		self.r870.kick.crouching = self.r870.kick.standing
		self.r870.kick.steelsight = {
			1.5,
			1.7,
			-0.2,
			0.2
		}
		
		self.r870.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 160,
			alert_size = 7,
			spread = 11,
			spread_moving = 12,
			recoil = 26,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 3,
			concealment = 20
		}
		self.r870.stats_modifiers = {
			damage = 1
		}
		self.r870.rays = 12 --Number of pellets/bullets shot out by the gun when firing, self-explanatory.
		self.r870.damage_near = 2000 --Initial range at which damage falloff begins, from regular weapon damage to less than that.
		self.r870.damage_far = 3000 --Range at which the gun's damage reaches the lowest possible point.
		
		--Izhma 12G
		self.saiga.FIRE_MODE = "auto"
		self.saiga.fire_mode_data = {
			fire_rate = 0.18
		}
		self.saiga.CAN_TOGGLE_FIREMODE = true
		self.saiga.auto = {
			fire_rate = 0.18
		}
		self.saiga.timers = {
			reload_not_empty = 2.65,
			reload_empty = 3.95,
			unequip = 0.6,
			equip = 0.6
		}
		
		self.saiga.CLIP_AMMO_MAX = 8
		self.saiga.AMMO_MAX = 60
		self.saiga.AMMO_PICKUP = {
			5,
			6
		}
		
		self.saiga.spread = {
			standing = self.r870.spread.standing,
			crouching = self.r870.spread.crouching,
			steelsight = self.r870.spread.steelsight,
			moving_standing = self.r870.spread.moving_standing,
			moving_crouching = self.r870.spread.moving_crouching,
			moving_steelsight = self.r870.spread.moving_steelsight
		}
		self.saiga.kick = {
			standing = self.r870.kick.standing
		}
		self.saiga.kick.crouching = self.saiga.kick.standing
		self.saiga.kick.steelsight = self.r870.kick.steelsight
		
		self.saiga.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 60,
			alert_size = 7,
			spread = 11,
			spread_moving = 8,
			recoil = 16,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 3,
			concealment = 25
		}
		self.saiga.stats_modifiers = {
			damage = 1
		}
		self.saiga.rays = 12
		self.saiga.damage_near = 2000
		self.saiga.damage_far = 3000
		
		--Mosconi 12G
		self.huntsman.FIRE_MODE = "single"
		self.huntsman.fire_mode_data = {
			fire_rate = 0.12
		}
		self.huntsman.single = {
			fire_rate = 0.12
		}
		self.huntsman.timers = {
			reload_not_empty = 2.5
		}
		self.huntsman.timers.reload_empty = self.huntsman.timers.reload_not_empty
		self.huntsman.timers.unequip = 0.6
		self.huntsman.timers.equip = 0.6
		
		self.huntsman.CLIP_AMMO_MAX = 2
		self.huntsman.NR_CLIPS_MAX = 16
		self.huntsman.AMMO_MAX = self.huntsman.CLIP_AMMO_MAX * self.huntsman.NR_CLIPS_MAX
		self.huntsman.AMMO_PICKUP = {
			1,
			2
		}
		
		self.huntsman.spread = {
			standing = self.r870.spread.standing,
			crouching = self.r870.spread.crouching,
			steelsight = self.r870.spread.steelsight,
			moving_standing = self.r870.spread.moving_standing,
			moving_crouching = self.r870.spread.moving_crouching,
			moving_steelsight = self.r870.spread.moving_steelsight
		}
		self.huntsman.kick = {
			standing = {
				2.9,
				3,
				-0.5,
				0.5
			}
		}
		self.huntsman.kick.crouching = self.huntsman.kick.standing
		self.huntsman.kick.steelsight = self.huntsman.kick.standing		
		self.huntsman.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 200,
			alert_size = 7,
			spread = 11,
			spread_moving = 16,
			recoil = 2,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 3,
			concealment = 25
		}
		self.huntsman.stats_modifiers = {
			damage = 1
		}
		self.huntsman.damage_near = 2000
		self.huntsman.damage_far = 3000
		self.huntsman.rays = 12
		
		--Breaker 12G
		self.boot.FIRE_MODE = "single"
		self.boot.fire_mode_data = {
			fire_rate = 0.75
		}
		self.boot.single = {
			fire_rate = 0.75
		}
		self.boot.timers = {
			shotgun_reload_enter = 0.733,
			shotgun_reload_exit_empty = 1.1,
			shotgun_reload_exit_not_empty = 0.75,
			shotgun_reload_shell = 0.33,
			shotgun_reload_first_shell_offset = 0,
			unequip = 0.55,
			equip = 0.85
		}
		
		self.boot.CLIP_AMMO_MAX = 7
		self.boot.AMMO_MAX = 28
		self.boot.AMMO_PICKUP = {
			0.2,
			0.735
		}
		
		self.boot.spread = {
			standing = self.r870.spread.standing,
			crouching = self.r870.spread.crouching,
			steelsight = self.r870.spread.steelsight,
			moving_standing = self.r870.spread.moving_standing,
			moving_crouching = self.r870.spread.moving_crouching,
			moving_steelsight = self.r870.spread.moving_steelsight
		}
		self.boot.kick = {
			standing = {
				1.9,
				2,
				-0.2,
				0.2
			}
		}
		self.boot.kick.crouching = self.boot.kick.standing
		self.boot.kick.steelsight = {
			1.5,
			1.7,
			-0.2,
			0.2
		}
		
		self.boot.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 200,
			alert_size = 7,
			spread = 11,
			spread_moving = 12,
			recoil = 2,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 5,
			concealment = 20
		}
		self.boot.stats_modifiers = {
			damage = 1
		}
		self.boot.damage_near = 2000
		self.boot.damage_far = 3000
		self.boot.rays = 12
		
		--M1014
		self.benelli.FIRE_MODE = "single"
		self.benelli.fire_mode_data = {
			fire_rate = 0.139
		}
		self.benelli.CAN_TOGGLE_FIREMODE = false
		self.benelli.single = {
			fire_rate = 0.139
		}
		self.benelli.timers = {
			unequip = 0.85,
			equip = 0.85
		}
		
		self.benelli.CLIP_AMMO_MAX = 8
		self.benelli.AMMO_MAX = 70
		self.benelli.AMMO_PICKUP = {
			4,
			5
		}
		
		self.benelli.spread = {
			standing = self.r870.spread.standing,
			crouching = self.r870.spread.crouching,
			steelsight = self.r870.spread.steelsight,
			moving_standing = self.r870.spread.moving_standing,
			moving_crouching = self.r870.spread.moving_crouching,
			moving_steelsight = self.r870.spread.moving_steelsight
		}
		self.benelli.kick = {
			standing = self.r870.kick.standing
		}
		self.benelli.kick.crouching = self.benelli.kick.standing
		self.benelli.kick.steelsight = self.r870.kick.steelsight
		
		self.benelli.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 110,
			alert_size = 7,
			spread = 8,
			spread_moving = 7,
			recoil = 12,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 3,
			concealment = 20
		}
		self.benelli.stats_modifiers = {
			damage = 1
		}
		self.benelli.damage_near = 2000
		self.benelli.damage_far = 3000
		self.benelli.rays = 12
		
		--Raven Shotgun
		self.ksg.FIRE_MODE = "single"
		self.ksg.fire_mode_data = {
			fire_rate = 0.575
		}
		self.ksg.single = {
			fire_rate = 0.575
		}
		self.ksg.timers = {
			unequip = 0.6,
			equip = 0.55
		}
		
		self.ksg.CLIP_AMMO_MAX = 10
		self.ksg.AMMO_MAX = 50
		self.ksg.AMMO_PICKUP = {
			2,
			3
		}
		
		self.ksg.spread = {
			standing = self.r870.spread.standing,
			crouching = self.r870.spread.crouching,
			steelsight = self.r870.spread.steelsight,
			moving_standing = self.r870.spread.moving_standing,
			moving_crouching = self.r870.spread.moving_crouching,
			moving_steelsight = self.r870.spread.moving_steelsight
		}
		self.ksg.kick = {
			standing = {
				1.9,
				2,
				-0.2,
				0.2
			}
		}
		self.ksg.kick.crouching = self.ksg.kick.standing
		self.ksg.kick.steelsight = {
			1.5,
			1.7,
			-0.2,
			0.2
		}
		
		self.ksg.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 160,
			alert_size = 7,
			spread = 11,
			spread_moving = 12,
			recoil = 26,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 3,
			concealment = 20
		}
		self.ksg.stats_modifiers = {
			damage = 1
		}
		self.ksg.damage_near = 2000
		self.ksg.damage_far = 3000
		self.ksg.rays = 12
		
		--Steakout 12G Shotgun
		self.aa12.FIRE_MODE = "auto"
		self.aa12.fire_mode_data = {
			fire_rate = 0.2
		}
		self.aa12.CAN_TOGGLE_FIREMODE = true
		self.aa12.auto = {
			fire_rate = 0.2
		}
		self.aa12.timers = {
			reload_not_empty = 3,
			reload_empty = 4.1,
			unequip = 0.55,
			equip = 0.55
		}
		
		self.aa12.CLIP_AMMO_MAX = 8
		self.aa12.AMMO_MAX = 80
		self.aa12.AMMO_PICKUP = {
			5,
			6
		}
		
		self.aa12.spread = {
			standing = self.r870.spread.standing,
			crouching = self.r870.spread.crouching,
			steelsight = self.r870.spread.steelsight,
			moving_standing = self.r870.spread.moving_standing,
			moving_crouching = self.r870.spread.moving_crouching,
			moving_steelsight = self.r870.spread.moving_steelsight
		}
		self.aa12.kick = {
			standing = self.r870.kick.standing
		}
		self.aa12.kick.crouching = self.aa12.kick.standing
		self.aa12.kick.steelsight = self.r870.kick.steelsight
		
		self.aa12.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 60,
			alert_size = 7,
			spread = 11,
			spread_moving = 8,
			recoil = 16,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 3,
			concealment = 20
		}
		self.aa12.stats_modifiers = {
			damage = 1
		}
		self.aa12.damage_near = 2000
		self.aa12.damage_far = 3000
		self.aa12.rays = 12
		
		--Predator 12G
		self.spas12.FIRE_MODE = "single"
		self.spas12.fire_mode_data = {
			fire_rate = 0.2
		}
		self.spas12.CAN_TOGGLE_FIREMODE = false
		self.spas12.single = {
			fire_rate = 0.2
		}
		self.spas12.timers = {
			unequip = 0.85,
			equip = 0.85
		}
		
		self.spas12.CLIP_AMMO_MAX = 8
		self.spas12.AMMO_MAX = 70
		self.spas12.AMMO_PICKUP = {
			4,
			5
		}
		
		self.spas12.spread = {
			standing = self.r870.spread.standing,
			crouching = self.r870.spread.crouching,
			steelsight = self.r870.spread.steelsight,
			moving_standing = self.r870.spread.moving_standing,
			moving_crouching = self.r870.spread.moving_crouching,
			moving_steelsight = self.r870.spread.moving_steelsight
		}
		self.spas12.kick = {
			standing = {
				1.8,
				1.5,
				-0.5,
				0.8
			}
		}
		self.spas12.kick.crouching = self.spas12.kick.standing
		self.spas12.kick.steelsight = self.spas12.kick.standing
		
		self.spas12.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 110,
			alert_size = 7,
			spread = 11,
			spread_moving = 8,
			recoil = 26,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 3,
			concealment = 20
		}
		self.spas12.stats_modifiers = {
			damage = 1
		}
		self.spas12.damage_near = 2000
		self.spas12.damage_far = 3000
		self.spas12.rays = 12
		
		--Joceline O/U 12G
		self.b682.FIRE_MODE = "single"
		self.b682.fire_mode_data = {
			fire_rate = 0.12
		}
		self.b682.single = {
			fire_rate = 0.12
		}
		self.b682.timers = {
			reload_not_empty = 2.5,
			reload_empty = 2.7,
			unequip = 0.55,
			equip = 0.55
		}
		
		self.b682.CLIP_AMMO_MAX = 2
		self.b682.AMMO_MAX = 34
		self.b682.AMMO_PICKUP = {
			1,
			2
		}
		
		self.b682.spread = {
			standing = self.r870.spread.standing,
			crouching = self.r870.spread.crouching,
			steelsight = self.r870.spread.steelsight,
			moving_standing = self.r870.spread.moving_standing,
			moving_crouching = self.r870.spread.moving_crouching,
			moving_steelsight = self.r870.spread.moving_steelsight
		}
		self.b682.kick = {
			standing = {
				2.9,
				3,
				-0.5,
				0.5
			}
		}
		self.b682.kick.crouching = self.b682.kick.standing
		self.b682.kick.steelsight = self.b682.kick.standing
		
		self.b682.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 200,
			alert_size = 7,
			spread = 11,
			spread_moving = 16,
			recoil = 2,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 3,
			concealment = 25
		}
		self.b682.stats_modifiers = {
			damage = 1
		}
		self.b682.damage_near = 2000
		self.b682.damage_far = 3000
		self.b682.rays = 12
		
		--Locomotive 12G
		self.serbu.FIRE_MODE = "single"
		self.serbu.fire_mode_data = {
			fire_rate = 0.375
		}
		self.serbu.single = {
			fire_rate = 0.375
		}
		self.serbu.timers = {
			unequip = 0.7,
			equip = 0.6
		}
		
		self.serbu.CLIP_AMMO_MAX = 6
		self.serbu.NR_CLIPS_MAX = 7
		self.serbu.AMMO_MAX = self.serbu.CLIP_AMMO_MAX * self.serbu.NR_CLIPS_MAX
		self.serbu.AMMO_PICKUP = {
			0.42,
			1.47
		}
		
		self.serbu.spread = {
			standing = self.r870.spread.standing,
			crouching = self.r870.spread.crouching,
			steelsight = self.r870.spread.steelsight,
			moving_standing = self.r870.spread.moving_standing,
			moving_crouching = self.r870.spread.moving_crouching,
			moving_steelsight = self.r870.spread.moving_steelsight
		}
		self.serbu.kick = {
			standing = self.r870.kick.standing
		}
		self.serbu.kick.crouching = self.serbu.kick.standing
		self.serbu.kick.steelsight = self.serbu.kick.standing
		
		self.serbu.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 90,
			alert_size = 7,
			spread = 13,
			spread_moving = 10,
			recoil = 10,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 5,
			concealment = 23
		}
		self.serbu.stats_modifiers = {
			damage = 1
		}
		self.serbu.damage_near = 2000
		self.serbu.damage_far = 3000
		self.serbu.rays = 12
		
		--Goliath 12G.
		self.rota.FIRE_MODE = "single"
		self.rota.fire_mode_data = {
			fire_rate = 0.18
		}
		self.rota.CAN_TOGGLE_FIREMODE = false
		self.rota.single = {
			fire_rate = 0.18
		}
		self.rota.timers = {
			reload_not_empty = 2.55,
			reload_empty = 2.55,
			unequip = 0.6,
			equip = 0.6
		}
		
		self.rota.CLIP_AMMO_MAX = 6
		self.rota.NR_CLIPS_MAX = 9
		self.rota.AMMO_MAX = self.rota.CLIP_AMMO_MAX * self.rota.NR_CLIPS_MAX
		self.rota.AMMO_PICKUP = {
			2.7,
			4.05
		}
		
		self.rota.spread = {
			standing = self.r870.spread.standing,
			crouching = self.r870.spread.crouching,
			steelsight = self.r870.spread.steelsight,
			moving_standing = self.r870.spread.moving_standing,
			moving_crouching = self.r870.spread.moving_crouching,
			moving_steelsight = self.r870.spread.moving_steelsight
		}
		self.rota.kick = {
			standing = self.r870.kick.standing
		}
		self.rota.kick.crouching = self.rota.kick.standing
		self.rota.kick.steelsight = self.r870.kick.steelsight
		
		self.rota.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 42,
			alert_size = 7,
			spread = 15,
			spread_moving = 8,
			recoil = 12,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 5,
			concealment = 13
		}
		self.rota.stats_modifiers = {
			damage = 1
		}
		self.rota.damage_near = 2000
		self.rota.damage_far = 3000
		self.rota.rays = 12
		
		--Grimm 12G
		self.basset.FIRE_MODE = "auto"
		self.basset.fire_mode_data = {
			fire_rate = 0.2
		}
		self.basset.CAN_TOGGLE_FIREMODE = true
		self.basset.auto = {
			fire_rate = 0.2
		}
		self.basset.timers = {
			reload_not_empty = 2.16,
			reload_empty = 2.9,
			unequip = 0.55,
			equip = 0.55
		}
		
		self.basset.CLIP_AMMO_MAX = 8
		self.basset.NR_CLIPS_MAX = 13
		self.basset.AMMO_MAX = self.basset.CLIP_AMMO_MAX * self.basset.NR_CLIPS_MAX
		self.basset.AMMO_PICKUP = {
			5.2,
			7.8
		}
		
		self.basset.spread = {
			standing = self.r870.spread.standing,
			crouching = self.r870.spread.crouching,
			steelsight = self.r870.spread.steelsight,
			moving_standing = self.r870.spread.moving_standing,
			moving_crouching = self.r870.spread.moving_crouching,
			moving_steelsight = self.r870.spread.moving_steelsight
		}
		self.basset.kick = {
			standing = self.r870.kick.standing
		}
		self.basset.kick.crouching = self.basset.kick.standing
		self.basset.kick.steelsight = self.r870.kick.steelsight
		
		self.basset.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 18,
			alert_size = 7,
			spread = 4,
			spread_moving = 8,
			recoil = 13,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 5,
			concealment = 21
		}
		self.basset.stats_modifiers = {
			damage = 1
		}
		self.basset.damage_near = 2000
		self.basset.damage_far = 3000
		self.basset.rays = 12
		
		--Claire 12G
		
		self.coach.FIRE_MODE = "single"
		self.coach.fire_mode_data = {
			fire_rate = 0.12
		}
		self.coach.single = {
			fire_rate = 0.12
		}
		self.coach.timers = {
			reload_not_empty = 2.2
		}
		self.coach.timers.reload_empty = self.coach.timers.reload_not_empty
		self.coach.timers.unequip = 0.6
		self.coach.timers.equip = 0.4
		
		self.coach.CLIP_AMMO_MAX = 2
		self.coach.NR_CLIPS_MAX = 22
		self.coach.AMMO_MAX = self.coach.CLIP_AMMO_MAX * self.coach.NR_CLIPS_MAX
		self.coach.AMMO_PICKUP = {
			0.22,
			0.66
		}
		
		self.coach.spread = {
			standing = self.r870.spread.standing,
			crouching = self.r870.spread.crouching,
			steelsight = self.r870.spread.steelsight,
			moving_standing = self.r870.spread.moving_standing,
			moving_crouching = self.r870.spread.moving_crouching,
			moving_steelsight = self.r870.spread.moving_steelsight
		}
		self.coach.kick = {
			standing = {
				1.7,
				1.8,
				-0.4,
				0.3
			}
		}
		self.coach.kick.crouching = self.coach.kick.standing
		self.coach.kick.steelsight = {
			1.4,
			1.5,
			-0.2,
			0.2
		}
		
		self.coach.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 155,
			alert_size = 7,
			spread = 15,
			spread_moving = 12,
			recoil = 12,
			value = 3,
			extra_ammo = 51,
			reload = 11,
			suppression = 5,
			concealment = 10
		}
		self.coach.stats_modifiers = {
			damage = 1
		}
		self.coach.damage_near = 2000
		self.coach.damage_far = 3000
		self.coach.rays = 12
		
		--GSPS 12G
		self.m37.FIRE_MODE = "single"
		self.m37.fire_mode_data = {
			fire_rate = 0.575
		}
		self.m37.single = {
			fire_rate = 0.575
		}
		self.m37.timers = {
			shotgun_reload_enter = 0.5,
			shotgun_reload_exit_empty = 0.7,
			shotgun_reload_exit_not_empty = 0.3,
			shotgun_reload_shell = 0.65,
			shotgun_reload_first_shell_offset = 0,
			unequip = 0.85,
			equip = 0.85
		}
		
		self.m37.CLIP_AMMO_MAX = 7
		self.m37.NR_CLIPS_MAX = 4
		self.m37.AMMO_MAX = self.m37.CLIP_AMMO_MAX * self.m37.NR_CLIPS_MAX
		self.m37.AMMO_PICKUP = {
			0.28,
			0.98
		}
		
		self.m37.spread = {
			standing = self.r870.spread.standing,
			crouching = self.r870.spread.crouching,
			steelsight = self.r870.spread.steelsight,
			moving_standing = self.r870.spread.moving_standing,
			moving_crouching = self.r870.spread.moving_crouching,
			moving_steelsight = self.r870.spread.moving_steelsight
		}
		self.m37.kick = {
			standing = {
				1.9,
				2,
				-0.2,
				0.2
			}
		}
		self.m37.kick.crouching = self.m37.kick.standing
		self.m37.kick.steelsight = {
			1.5,
			1.7,
			-0.2,
			0.2
		}
		
		self.m37.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 155,
			alert_size = 7,
			spread = 12,
			spread_moving = 12,
			recoil = 14,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 5,
			concealment = 22
		}
		self.m37.stats_modifiers = {
			damage = 1
		}
		self.m37.damage_near = 2000
		self.m37.damage_far = 3000
		self.m37.rays = 12
		
		--Street Sweeper
		self.striker.FIRE_MODE = "single"
		self.striker.fire_mode_data = {
			fire_rate = 0.14
		}
		self.striker.CAN_TOGGLE_FIREMODE = false
		self.striker.single = {
			fire_rate = 0.14
		}
		self.striker.timers = {
			shotgun_reload_enter = 0.5333333333333333,
			shotgun_reload_exit_empty = 0.4,
			shotgun_reload_exit_not_empty = 0.4,
			shotgun_reload_shell = 0.6,
			shotgun_reload_first_shell_offset = 0.13333333333333333,
			unequip = 0.6,
			equip = 0.85
		}
		
		self.striker.CLIP_AMMO_MAX = 12
		self.striker.NR_CLIPS_MAX = 6
		self.striker.AMMO_MAX = self.striker.CLIP_AMMO_MAX * self.striker.NR_CLIPS_MAX
		self.striker.AMMO_PICKUP = {
			3.6,
			5.4
		}
		
		self.striker.spread = {
			standing = self.r870.spread.standing,
			crouching = self.r870.spread.crouching,
			steelsight = self.r870.spread.steelsight,
			moving_standing = self.r870.spread.moving_standing,
			moving_crouching = self.r870.spread.moving_crouching,
			moving_steelsight = self.r870.spread.moving_steelsight
		}
		self.striker.kick = {
			standing = self.r870.kick.standing
		}
		self.striker.kick.crouching = self.striker.kick.standing
		self.striker.kick.steelsight = self.r870.kick.steelsight
		
		self.striker.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 42,
			alert_size = 7,
			spread = 8,
			spread_moving = 8,
			recoil = 12,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 5,
			concealment = 21
		}
		self.striker.stats_modifiers = {
			damage = 1
		}
		self.striker.damage_near = 2000
		self.striker.damage_far = 3000
		self.striker.rays = 12
		
		--The Judge
		self.judge.FIRE_MODE = "single"
		self.judge.fire_mode_data = {
			fire_rate = 0.12
		}
		self.judge.single = {
			fire_rate = 0.21
		}
		self.judge.timers = {
			reload_not_empty = 2.25,
			reload_empty = 2.25,
			unequip = 0.5,
			equip = 0.45
		}
		
		self.judge.CLIP_AMMO_MAX = 5
		self.judge.NR_CLIPS_MAX = 7
		self.judge.AMMO_MAX = self.judge.CLIP_AMMO_MAX * self.judge.NR_CLIPS_MAX
		self.judge.AMMO_PICKUP = {
			0.18,
			0.53
		}
		
		self.judge.spread = {
			standing = self.r870.spread.standing,
			crouching = self.r870.spread.crouching,
			steelsight = self.r870.spread.steelsight,
			moving_standing = self.r870.spread.moving_standing,
			moving_crouching = self.r870.spread.moving_crouching,
			moving_steelsight = self.r870.spread.moving_steelsight
		}
		self.judge.kick = {
			standing = {
				2.9,
				3,
				-0.5,
				0.5
			}
		}
		self.judge.kick.crouching = self.judge.kick.standing
		self.judge.kick.steelsight = self.judge.kick.standing
		
		self.judge.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 155,
			alert_size = 7,
			spread = 14,
			spread_moving = 14,
			recoil = 8,
			value = 1,
			extra_ammo = 51,
			reload = 11,
			suppression = 5,
			concealment = 29
		}
		self.judge.stats_modifiers = {
			damage = 1
		}
		self.judge.damage_near = 2000
		self.judge.damage_far = 3000
		self.judge.rays = 12
		
		--Shotguns end here
		
		--LMGs start here.
		
		--KSP 58
		self.par.FIRE_MODE = "auto"
		self.par.fire_mode_data = {
			fire_rate = 0.066
		}
		self.par.CAN_TOGGLE_FIREMODE = false
		self.par.auto = {
			fire_rate = 0.076
		}
		self.par.timers = {
			reload_not_empty = 6.5,
			reload_empty = 6.5,
			unequip = 0.9,
			equip = 0.9,
			deploy_bipod = 0.85
		}
		
		self.par.CLIP_AMMO_MAX = 200
		self.par.NR_CLIPS_MAX = 2
		self.par.AMMO_MAX = self.par.CLIP_AMMO_MAX * self.par.NR_CLIPS_MAX
		self.par.AMMO_PICKUP = {
			12,
			22
		}
		
		self.par.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight,
			bipod = weapon_data.default_bipod_spread
		}
		self.par.kick = {
			standing = {
				-0.2,
				0.8,
				-1,
				1.4
			}
		}
		self.par.kick.crouching = self.par.kick.standing
		self.par.kick.steelsight = self.par.kick.standing
		
		self.par.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 80,
			alert_size = 8,
			spread = 14,
			spread_moving = 8,
			recoil = 8,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 4,
			concealment = 1
		}
		self.par.stats_modifiers = {
			damage = 1
		}
		
		--RPK
		self.rpk.FIRE_MODE = "auto"
		self.rpk.fire_mode_data = {
			fire_rate = 0.08
		}
		self.rpk.CAN_TOGGLE_FIREMODE = false
		self.rpk.auto = {
			fire_rate = 0.08
		}
		self.rpk.timers = {
			reload_not_empty = 3.4,
			reload_empty = 4.56,
			unequip = 0.9,
			equip = 0.9,
			deploy_bipod = 1
		}
		
		self.rpk.CLIP_AMMO_MAX = 100
		self.rpk.NR_CLIPS_MAX = 3
		self.rpk.AMMO_MAX = self.rpk.CLIP_AMMO_MAX * self.rpk.NR_CLIPS_MAX
		self.rpk.AMMO_PICKUP = {
			3.00,
			10.50
		}
		
		self.rpk.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight,
			bipod = weapon_data.default_bipod_spread
		}
		self.rpk.kick = {
			standing = {
				-0.2,
				0.8,
				-1,
				1.4
			}
		}
		self.rpk.kick.crouching = self.rpk.kick.standing
		self.rpk.kick.steelsight = self.rpk.kick.standing
		
		self.rpk.stats = {
			zoom = 2,
			total_ammo_mod = 21,
			damage = 120,
			alert_size = 7,
			spread = 8,
			spread_moving = 6,
			recoil = 3,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 8,
			concealment = 1
		}
		self.rpk.stats_modifiers = {
			damage = 1
		}
		
		--KSP (Again!?)
		self.m249.FIRE_MODE = "auto"
		self.m249.fire_mode_data = {
			fire_rate = 0.066
		}
		self.m249.CAN_TOGGLE_FIREMODE = false
		self.m249.auto = {
			fire_rate = 0.076
		}
		self.m249.timers = {
			reload_not_empty = 5.62,
			reload_empty = 5.62,
			unequip = 0.9,
			equip = 0.9,
			deploy_bipod = 1
		}
		
		self.m249.CLIP_AMMO_MAX = 200
		self.m249.NR_CLIPS_MAX = 2
		self.m249.AMMO_MAX = self.m249.CLIP_AMMO_MAX * self.m249.NR_CLIPS_MAX
		self.m249.AMMO_PICKUP = {
			12,
			22
		}
		
		self.m249.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight,
			bipod = weapon_data.default_bipod_spread
		}
		self.m249.kick = {
			standing = {
				-0.2,
				0.8,
				-1,
				1.4
			}
		}
		self.m249.kick.crouching = self.m249.kick.standing
		self.m249.kick.steelsight = self.m249.kick.standing
		
		self.m249.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 80,
			alert_size = 8,
			spread = 13,
			spread_moving = 8,
			recoil = 8,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 4,
			concealment = 1
		}
		self.m249.stats_modifiers = {
			damage = 1
		}
		
		--Buzzsaw 42
		self.mg42.FIRE_MODE = "auto"
		self.mg42.fire_mode_data = {
			fire_rate = 0.05
		}
		self.mg42.CAN_TOGGLE_FIREMODE = false
		self.mg42.auto = {
			fire_rate = 0.05
		}
		self.mg42.timers = {
			reload_not_empty = 6.5,
			reload_empty = 6.5,
			unequip = 0.9,
			equip = 0.9,
			deploy_bipod = 1
		}
		
		self.mg42.CLIP_AMMO_MAX = 150
		self.mg42.NR_CLIPS_MAX = 3
		self.mg42.AMMO_MAX = self.mg42.CLIP_AMMO_MAX * self.mg42.NR_CLIPS_MAX
		self.mg42.AMMO_PICKUP = {
			13.50,
			24.75
		}
		
		self.mg42.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight,
			bipod = weapon_data.default_bipod_spread
		}
		self.mg42.kick = {
			standing = {
				-0.2,
				0.8,
				-1,
				1.4
			}
		}
		self.mg42.kick.crouching = self.mg42.kick.standing
		self.mg42.kick.steelsight = self.mg42.kick.standing
		
		self.mg42.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 80,
			alert_size = 8,
			spread = 13,
			spread_moving = 8,
			recoil = 8,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 4,
			concealment = 1
		}
		self.mg42.stats_modifiers = {
			damage = 1
		}
		
		--Brenner 21
		self.hk21.FIRE_MODE = "auto"
		self.hk21.fire_mode_data = {
			fire_rate = 0.083
		}
		self.hk21.CAN_TOGGLE_FIREMODE = false
		self.hk21.auto = {
			fire_rate = 0.083
		}
		self.hk21.timers = {
			reload_not_empty = 4.65,
			reload_empty = 6.7,
			unequip = 0.9,
			equip = 0.9,
			deploy_bipod = 1
		}
		
		self.hk21.CLIP_AMMO_MAX = 150
		self.hk21.NR_CLIPS_MAX = 2
		self.hk21.AMMO_MAX = self.hk21.CLIP_AMMO_MAX * self.hk21.NR_CLIPS_MAX
		self.hk21.AMMO_PICKUP = {
			3.00,
			10.50
		}
		
		self.hk21.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight,
			bipod = weapon_data.default_bipod_spread
		}
		self.hk21.kick = {
			standing = {
				-0.2,
				0.8,
				-0.8,
				1
			}
		}
		self.hk21.kick.crouching = self.hk21.kick.standing
		self.hk21.kick.steelsight = self.hk21.kick.standing
		
		self.hk21.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 120,
			alert_size = 8,
			spread = 10,
			spread_moving = 10,
			recoil = 3,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 2,
			concealment = 1
		}
		self.hk21.stats_modifiers = {
			damage = 1
		}
		
		--LMGs end here.
		
		--Snipers begin here.
	
		--Platypus 70
		self.model70.FIRE_MODE = "single"
		self.model70.fire_mode_data = {
			fire_rate = 1
		}
		self.model70.CAN_TOGGLE_FIREMODE = false
		self.model70.single = {
			fire_rate = 20
		}
		self.model70.timers = {
			reload_not_empty = 3.35,
			reload_empty = 4.5,
			unequip = 0.45,
			equip = 0.75
		}
		
		self.model70.CLIP_AMMO_MAX = 5
		self.model70.NR_CLIPS_MAX = 6
		self.model70.AMMO_MAX = self.model70.CLIP_AMMO_MAX * self.model70.NR_CLIPS_MAX
		self.model70.AMMO_PICKUP = {
			0.7,
			1
		}
		
		self.model70.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.model70.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		self.model70.kick.crouching = self.model70.kick.standing
		self.model70.kick.steelsight = self.model70.kick.standing
		
		self.model70.can_shoot_through_enemy = true
		self.model70.can_shoot_through_shield = true
		self.model70.can_shoot_through_wall = true
		self.model70.panic_suppression_chance = 0.2
		self.model70.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 120,
			alert_size = 7,
			spread = 24,
			spread_moving = 24,
			recoil = 4,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 5,
			concealment = 6
		}
		self.model70.armor_piercing_chance = 1
		self.model70.stats_modifiers = {
			damage = 4
		}
		
		--Rattlesnake
		self.msr.FIRE_MODE = "single"
		self.msr.fire_mode_data = {
			fire_rate = 1
		}
		self.msr.CAN_TOGGLE_FIREMODE = false
		self.msr.single = {
			fire_rate = 20
		}
		self.msr.timers = {
			reload_not_empty = 2.6,
			reload_empty = 3.7,
			unequip = 0.6,
			equip = 0.7
		}
		
		self.msr.CLIP_AMMO_MAX = 10
		self.msr.NR_CLIPS_MAX = 4
		self.msr.AMMO_MAX = self.msr.CLIP_AMMO_MAX * self.msr.NR_CLIPS_MAX
		self.msr.AMMO_PICKUP = {
			2,
			3
		}
		
		self.msr.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.msr.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		self.msr.kick.crouching = self.msr.kick.standing
		self.msr.kick.steelsight = self.msr.kick.standing
		
		self.msr.can_shoot_through_enemy = true
		self.msr.can_shoot_through_shield = true
		self.msr.can_shoot_through_wall = true
		self.msr.panic_suppression_chance = 0.2
		self.msr.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 123,
			alert_size = 7,
			spread = 23,
			spread_moving = 22,
			recoil = 8,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 6,
			concealment = 5
		}
		self.msr.armor_piercing_chance = 1
		self.msr.stats_modifiers = {
			damage = 2
		}
		
		--Lebensauger .308
		self.wa2000.FIRE_MODE = "single"
		self.wa2000.fire_mode_data = {
			fire_rate = 0.4
		}
		self.wa2000.CAN_TOGGLE_FIREMODE = false
		self.wa2000.single = {
			fire_rate = 0.4
		}
		self.wa2000.timers = {
			reload_not_empty = 4.64,
			reload_empty = 6.2,
			unequip = 0.9,
			equip = 0.9
		}
		
		self.wa2000.CLIP_AMMO_MAX = 10
		self.wa2000.NR_CLIPS_MAX = 4
		self.wa2000.AMMO_MAX = self.wa2000.CLIP_AMMO_MAX * self.wa2000.NR_CLIPS_MAX
		self.wa2000.AMMO_PICKUP = {
			2,
			3
		}
		
		self.wa2000.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.wa2000.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		self.wa2000.kick.crouching = self.wa2000.kick.standing
		self.wa2000.kick.steelsight = self.wa2000.kick.standing
		
		self.wa2000.can_shoot_through_enemy = true
		self.wa2000.can_shoot_through_shield = true
		self.wa2000.can_shoot_through_wall = true
		self.wa2000.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 160,
			alert_size = 8,
			spread = 24,
			spread_moving = 24,
			recoil = 6,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 12,
			concealment = 16
		}
		self.wa2000.armor_piercing_chance = 1
		self.wa2000.stats_modifiers = {
			damage = 1
		}
		
		--Desertfox
		self.desertfox.FIRE_MODE = "single"
		self.desertfox.fire_mode_data = {
			fire_rate = 1
		}
		self.desertfox.CAN_TOGGLE_FIREMODE = false
		self.desertfox.single = {
			fire_rate = 20
		}
		self.desertfox.timers = {
			reload_not_empty = 2.72,
			reload_empty = 3.86,
			unequip = 0.45,
			equip = 0.75
		}
		
		self.desertfox.CLIP_AMMO_MAX = 5
		self.desertfox.NR_CLIPS_MAX = 6
		self.desertfox.AMMO_MAX = self.desertfox.CLIP_AMMO_MAX * self.desertfox.NR_CLIPS_MAX
		self.desertfox.AMMO_PICKUP = {
			0.7,
			1
		}
		
		self.desertfox.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.desertfox.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		self.desertfox.kick.crouching = self.desertfox.kick.standing
		self.desertfox.kick.steelsight = self.desertfox.kick.standing
		
		self.desertfox.can_shoot_through_enemy = true
		self.desertfox.can_shoot_through_shield = true
		self.desertfox.can_shoot_through_wall = true
		self.desertfox.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 120,
			alert_size = 7,
			spread = 20,
			spread_moving = 24,
			recoil = 4,
			value = 10,
			extra_ammo = 51,
			reload = 11,
			suppression = 5,
			concealment = 19
		}
		self.desertfox.armor_piercing_chance = 1
		self.desertfox.stats_modifiers = {
			damage = 4
		}
		
		--Contractor .308
		self.tti.FIRE_MODE = "single"
		self.tti.fire_mode_data = {
			fire_rate = 0.4
		}
		self.tti.CAN_TOGGLE_FIREMODE = false
		self.tti.single = {
			fire_rate = 0.4
		}
		self.tti.timers = {
			reload_not_empty = 2.3,
			reload_empty = 3.3,
			unequip = 0.9,
			equip = 0.9
		}
		
		self.tti.CLIP_AMMO_MAX = 20
		self.tti.NR_CLIPS_MAX = 2
		self.tti.AMMO_MAX = self.tti.CLIP_AMMO_MAX * self.tti.NR_CLIPS_MAX
		self.tti.AMMO_PICKUP = {
			2,
			3
		}
		
		self.tti.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.tti.kick = {
			standing = {
				2,
				3.8,
				-0.3,
				0.3
			}
		}
		self.tti.kick.crouching = self.tti.kick.standing
		self.tti.kick.steelsight = self.tti.kick.standing
		
		self.tti.can_shoot_through_enemy = true
		self.tti.can_shoot_through_shield = true
		self.tti.can_shoot_through_wall = true
		self.tti.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 160,
			alert_size = 8,
			spread = 16,
			spread_moving = 24,
			recoil = 2,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 12,
			concealment = 16
		}
		self.tti.armor_piercing_chance = 1
		self.tti.stats_modifiers = {
			damage = 1
		}
		
		--R93 Sniper Rifle
		self.r93.FIRE_MODE = "single"
		self.r93.fire_mode_data = {
			fire_rate = 1.2
		}
		self.r93.CAN_TOGGLE_FIREMODE = false
		self.r93.single = {
			fire_rate = 20
		}
		self.r93.timers = {
			reload_not_empty = 2.82,
			reload_empty = 3.82,
			unequip = 0.7,
			equip = 0.65
		}
		
		self.r93.CLIP_AMMO_MAX = 6
		self.r93.NR_CLIPS_MAX = 5
		self.r93.AMMO_MAX = self.r93.CLIP_AMMO_MAX * self.r93.NR_CLIPS_MAX
		self.r93.AMMO_PICKUP = {
			0.7,
			1
		}
		
		self.r93.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.r93.kick = {
			standing = {
				3,
				3.8,
				-0.1,
				0.1
			}
		}
		self.r93.kick.crouching = self.r93.kick.standing
		self.r93.kick.steelsight = self.r93.kick.standing
		
		self.r93.can_shoot_through_enemy = true
		self.r93.can_shoot_through_shield = true
		self.r93.can_shoot_through_wall = true
		self.r93.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 120,
			alert_size = 8,
			spread = 24,
			spread_moving = 24,
			recoil = 4,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 4,
			concealment = 5
		}
		self.r93.armor_piercing_chance = 1
		self.r93.stats_modifiers = {
			damage = 4
		}
		
		--Repeater 1874
		self.winchester1874.FIRE_MODE = "single"
		self.winchester1874.fire_mode_data = {
			fire_rate = 0.7
		}
		self.winchester1874.CAN_TOGGLE_FIREMODE = false
		self.winchester1874.single = {
			fire_rate = 0.7
		}
		self.winchester1874.timers = {
			shotgun_reload_enter = 0.43333333333333335,
			shotgun_reload_exit_empty = 0.7666666666666667,
			shotgun_reload_exit_not_empty = 0.4,
			shotgun_reload_shell = 0.5666666666666667,
			shotgun_reload_first_shell_offset = 0.2,
			unequip = 0.9,
			equip = 0.9
		}
		
		self.winchester1874.CLIP_AMMO_MAX = 15
		self.winchester1874.NR_CLIPS_MAX = 3
		self.winchester1874.AMMO_MAX = self.winchester1874.CLIP_AMMO_MAX * self.winchester1874.NR_CLIPS_MAX
		self.winchester1874.AMMO_PICKUP = {
			2.25,
			3.377
		}
		
		self.winchester1874.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.winchester1874.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		self.winchester1874.kick.crouching = self.winchester1874.kick.standing
		self.winchester1874.kick.steelsight = self.winchester1874.kick.standing
		
		self.winchester1874.can_shoot_through_enemy = true
		self.winchester1874.can_shoot_through_shield = true
		self.winchester1874.can_shoot_through_wall = true
		self.winchester1874.panic_suppression_chance = 0.2
		self.winchester1874.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 123,
			alert_size = 7,
			spread = 24,
			spread_moving = 24,
			recoil = 6,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 5,
			concealment = 12
		}
		self.winchester1874.armor_piercing_chance = 1
		self.winchester1874.stats_modifiers = {
			damage = 2
		}
		
		--Grom Sniper Rifle
		self.siltstone.FIRE_MODE = "single"
		self.siltstone.fire_mode_data = {
			fire_rate = 0.4
		}
		self.siltstone.CAN_TOGGLE_FIREMODE = false
		self.siltstone.single = {
			fire_rate = 0.4
		}
		self.siltstone.timers = {
			reload_not_empty = 2.3,
			reload_empty = 3.3,
			unequip = 0.9,
			equip = 0.9
		}
		
		self.siltstone.CLIP_AMMO_MAX = 10
		self.siltstone.NR_CLIPS_MAX = 4
		self.siltstone.AMMO_MAX = self.siltstone.CLIP_AMMO_MAX * self.siltstone.NR_CLIPS_MAX
		self.siltstone.AMMO_PICKUP = {
			2,
			3
		}
		
		self.siltstone.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.siltstone.kick = {
			standing = {
				2,
				3.8,
				-0.3,
				0.3
			}
		}
		self.siltstone.kick.crouching = self.siltstone.kick.standing
		self.siltstone.kick.steelsight = self.siltstone.kick.standing
		
		self.siltstone.can_shoot_through_enemy = true
		self.siltstone.can_shoot_through_shield = true
		self.siltstone.can_shoot_through_wall = true
		self.siltstone.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 160,
			alert_size = 8,
			spread = 19,
			spread_moving = 24,
			recoil = 2,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 12,
			concealment = 16
		}
		self.siltstone.armor_piercing_chance = 1
		self.siltstone.stats_modifiers = {
			damage = 1
		}
		
		--Nagant
		self.mosin.FIRE_MODE = "single"
		self.mosin.fire_mode_data = {
			fire_rate = 1
		}
		self.mosin.CAN_TOGGLE_FIREMODE = false
		self.mosin.single = {
			fire_rate = 20
		}
		self.mosin.timers = {
			reload_not_empty = 3.85,
			reload_empty = 3.85,
			unequip = 0.6,
			equip = 0.5
		}
		
		self.mosin.CLIP_AMMO_MAX = 5
		self.mosin.NR_CLIPS_MAX = 5
		self.mosin.AMMO_MAX = self.mosin.CLIP_AMMO_MAX * self.mosin.NR_CLIPS_MAX
		self.mosin.AMMO_PICKUP = {
			0.7,
			1
		}
		
		self.mosin.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.mosin.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		self.mosin.kick.crouching = self.mosin.kick.standing
		self.mosin.kick.steelsight = self.mosin.kick.standing
		
		self.mosin.can_shoot_through_enemy = true
		self.mosin.can_shoot_through_shield = true
		self.mosin.can_shoot_through_wall = true
		self.mosin.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 120,
			alert_size = 7,
			spread = 24,
			spread_moving = 24,
			recoil = 4,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 5,
			concealment = 6
		}
		self.mosin.armor_piercing_chance = 1
		self.mosin.stats_modifiers = {
			damage = 4
		}
		
		--Thanatos .50 cal
		self.m95.FIRE_MODE = "single"
		self.m95.fire_mode_data = {
			fire_rate = 1.5
		}
		self.m95.CAN_TOGGLE_FIREMODE = false
		self.m95.single = {
			fire_rate = 20
		}
		self.m95.timers = {
			reload_not_empty = 3.96,
			reload_empty = 5.23,
			unequip = 0.9,
			equip = 0.9
		}
		
		self.m95.CLIP_AMMO_MAX = 5
		self.m95.NR_CLIPS_MAX = 3
		self.m95.AMMO_MAX = self.m95.CLIP_AMMO_MAX * self.m95.NR_CLIPS_MAX
		self.m95.AMMO_PICKUP = {
			0.05,
			0.65
		}
		
		self.m95.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.m95.kick = {
			standing = {
				3,
				3.8,
				-0.5,
				0.5
			}
		}
		self.m95.kick.crouching = self.m95.kick.standing
		self.m95.kick.steelsight = self.m95.kick.standing
		
		self.m95.can_shoot_through_enemy = true
		self.m95.can_shoot_through_shield = true
		self.m95.can_shoot_through_wall = true
		self.m95.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 100,
			alert_size = 9,
			spread = 24,
			spread_moving = 24,
			recoil = 2,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 2,
			concealment = 1
		}
		self.m95.armor_piercing_chance = 1
		self.m95.stats_modifiers = {
			damage = 35
		}
		
		--Snipers end here.
		
		--Miniguns begin here.
		
		--Vulcan Minigun
		self.m134.FIRE_MODE = "auto"
		self.m134.fire_mode_data = {
			fire_rate = 0.02
		}
		self.m134.CAN_TOGGLE_FIREMODE = false
		self.m134.auto = {
			fire_rate = 0.05
		}
		self.m134.timers = {
			reload_not_empty = 7.8,
			reload_empty = 7.8,
			unequip = 0.9,
			equip = 0.9
		}
		
		self.m134.CLIP_AMMO_MAX = 750
		self.m134.NR_CLIPS_MAX = 1
		self.m134.AMMO_MAX = self.m134.CLIP_AMMO_MAX * self.m134.NR_CLIPS_MAX
		self.m134.AMMO_PICKUP = {
			7.50,
			26.25
		}
		
		self.m134.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.m134.kick = {
			standing = {
				-0.05,
				0.1,
				-0.15,
				0.2
			}
		}
		self.m134.kick.crouching = self.m134.kick.standing
		self.m134.kick.steelsight = self.m134.kick.standing
		
		self.m134.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 25,
			alert_size = 8,
			spread = 9,
			spread_moving = 9,
			recoil = 7,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 4,
			concealment = 5
		}
		self.m134.stats_modifiers = {
			damage = 1
		}
		
		--Microgun
		
		self.shuno.FIRE_MODE = "auto"
		self.shuno.fire_mode_data = {
			fire_rate = 0.03
		}
		self.shuno.CAN_TOGGLE_FIREMODE = false
		self.shuno.auto = {
			fire_rate = 0.05
		}
		self.shuno.timers = {
			reload_not_empty = 7.8,
			reload_empty = 7.8,
			unequip = 1.5,
			equip = 0.9
		}
		
		self.shuno.CLIP_AMMO_MAX = 750
		self.shuno.NR_CLIPS_MAX = 1
		self.shuno.AMMO_MAX = self.shuno.CLIP_AMMO_MAX * self.shuno.NR_CLIPS_MAX
		self.shuno.AMMO_PICKUP = {
			7.50,
			26.25
		}
		
		self.shuno.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.shuno.kick = {
			standing = {
				-0.05,
				0.1,
				-0.15,
				0.2
			}
		}
		self.shuno.kick.crouching = self.shuno.kick.standing
		self.shuno.kick.steelsight = self.shuno.kick.standing
		
		self.shuno.stats = {
			zoom = 1,
			total_ammo_mod = 21,
			damage = 35,
			alert_size = 8,
			spread = 9,
			spread_moving = 9,
			recoil = 7,
			value = 9,
			extra_ammo = 51,
			reload = 11,
			suppression = 4,
			concealment = 5
		}
		self.shuno.stats_modifiers = {
			damage = 1
		}
		
		--Miniguns end here.

	end
end)
