--if true then return end

local old_init = WeaponTweakData.init
function WeaponTweakData:init(tweak_data)
	--[[here's a list of what weapons enemies use --NOTE revalidate.
	heavy ar wpn_npc_s553
        light ar wpn_npc_m4
        heavy shot wpn_npc_benelli
        light shot wpn_npc_r870
        gman wpn_npc_r870 ---NOTE this must be revised.
        other pistol enemies wpn_npc_c45
        revolver enemies wpn_npc_raging_bull
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
-- NOTE light and heavy baselines are not used for beat cop type enemies. These are implemented separately. 
-- They correspond to swat unit types (blue, yellow, armored or no) instead.
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
        deathvox_medic_pistol = { -- NOTE uses light ar on difficulties below CD.
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
			hard = {damage = 6}, -- start spawning with asault waves. Matches to higher layer light AR to preserve unit coherence.
			very_hard = {damage = 6},
			overkill = {damage = 6},
			mayhem = {damage = 6}, 
			death_wish = {damage = 6},
			crackdown = {damage = 7.5} -- ZEAL. Increase from prior values, matched to light AR.
		},
	deathvox_sniper = { -- NOTE focuses much more on aim/focus delay than damage shift.
			-- no need for full tier coherence on this unit only, as at a distance. 
			not_a_real_difficulty = {damage = 10},
			normal = {damage = 16}, -- blue.
			hard = {damage = 16},
			very_hard = {damage = 18},
			overkill = {damage = 20}, -- green.
			mayhem = {damage = 20},
			death_wish = {damage = 20},
			crackdown = {damage = 24} -- new black unit.
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
	deathvox_cop_pistol = {  -- mk 3 values. Previously 40 lock, now mapped to guard pistol.
			not_a_real_difficulty = {damage = 10},
			normal = {damage = 2},
			hard = {damage = 2},
			very_hard = {damage = 2},
			overkill = {damage = 2},
			mayhem = {damage = 2},
			death_wish = {damage = 2},
			crackdown = {damage = 6}
		},
	deathvox_cop_revolver = { -- mk 3 values. Previously 40 lock, now start at forty and follow medic pistol.
			not_a_real_difficulty = {damage = 10},
			normal = {damage = 4},
			hard = {damage = 4},
			very_hard = {damage = 4},
			overkill = {damage = 4},
			mayhem = {damage = 6},
			death_wish = {damage = 6},
			crackdown = {damage = 8}
		},
	deathvox_cop_shotgun = {  -- mk 3 values. Previously 60 lock, now mapped to light shot.
			not_a_real_difficulty = {damage = 10},
			normal = {damage = 6},
			hard = {damage = 6},
			very_hard = {damage = 7},
			overkill = {damage = 7},
			mayhem = {damage = 7.5},
			death_wish = {damage = 7.5},
			crackdown = {damage = 9}
		},
	deathvox_cop_smg = {  -- mk 3 values. previously 25 lock, now begin at 25 then mapped to light AR.
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
	self.deathvox_light_ar.hold = "rifle"
	self.deathvox_light_ar.auto.fire_rate = 0.08 -- Firing delay in seconds
	--[[self.deathvox_light_ar.hold = { -- NOTE discuss removal
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
	--self.deathvox_guard_pistol.pull_magazine_during_reload = "pistol" -- NOTE discuss removal
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
	--self.deathvox_sniper.pull_magazine_during_reload = "rifle" -- NOTE discuss removal
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
	self.deathvox_grenadier.shell_ejection = "effects/payday2/particles/weapons/shells/shell_empty" -- appears to produce no effect. No need to adjust.
	self.deathvox_grenadier.CLIP_AMMO_MAX = 9999999
	self.deathvox_grenadier.NR_CLIPS_MAX = 9999999
	self.deathvox_grenadier.looped_reload_speed = 10
	self.deathvox_grenadier.timers = {reload_not_empty = 10}
	self.deathvox_grenadier.timers.reload_empty = self.deathvox_grenadier.timers.reload_not_empty
	self.deathvox_grenadier.fire_rate = 10.8 --ignore this
	self.deathvox_grenadier.auto = nil --ignore this
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
	self.deathvox_lmgdozer.anim_usage = "is_rifle"
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
--		log(diff_name .. " DIFFICULTY NAME")
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
			
			self.sentry_gun.WEAPON_HEAT_INIT = 0
			self.sentry_gun.WEAPON_HEAT_GAIN_RATE = 1 --heat per second gained while firing
			self.sentry_gun.WEAPON_HEAT_OVERHEAT_THRESHOLD = 50 --threshold at which the heat value causes the sentry gun to overheat and shut down
			self.sentry_gun.WEAPON_HEAT_DECAY_TIMER = 3 --number of seconds required to be inactive (not firing) before cooling down can begin
			self.sentry_gun.WEAPON_HEAT_DECAY_RATE = -1 --heat removed per second while cooling down 
			
			
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
		--	self.sentry_gun.SPREAD = 5 -- NOTE discuss removal
		--	self.sentry_gun.FIRE_RANGE = 5000
	end
	
	
end

-- Begin difficulty scripted weapon damage value population. 
-- NOTE comments not fully universalized due to upkeep difficulty. Check with developers if editing.

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
	
	self.mossberg_npc.DAMAGE = 24 -- temporary Greendozer Shotgun, not enough shotguns to map to all units, consider Bulldozer-specific weapon presets?
	self.saiga_npc.DAMAGE = 18 --Blackdozer Saiga, mapped to Deathvox Blackdozer.
	self.m249_npc.DAMAGE = 10 -- LMGDozer M249, has is_rifle behavior, needs to have it's usage changed. consider Bulldozer-specific weapon presets?
	self.rpk_lmg_npc.DAMAGE = 10 -- LMGDozer M249, AKAN faction, has is_rifle behavior, normal M249.
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

Hooks:PostHook(WeaponTweakData, "_init_stats", "vox_stat_mods", function(self) --total crackdown overhaul stat modifications
	if deathvox:IsTotalCrackdownEnabled() then	
		self.stats.extra_ammo = {}

		for i = -100, 100, 1 do --overwrite extra_ammo so that it accepts odds
			table.insert(self.stats.extra_ammo, i)
		end
	end
end)

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
		
--Category: Not shown in-game, category is more of a "tag" kind of thing, this is important for allowing weapon skills to work appropriately, refer to the Total Crackdown weapon rebalance document for easy data-entry: https://docs.google.com/document/d/1UvE_RL1hncNjAvg6pZsvIfT__appMF8N58eOoAEtYFg/edit
		
--I have provided an example with the new_m4/CAR-4, asval/Valkyria Rifle, and the contraband/Little Friend, refer to the original game's weapontweakdata, and do as I did, preserve the original tags just in case.
		
--rapidfire
--quiet
--precision
--shotgun (already set on most shotguns, keep that in mind.)
--heavy
--specialist
--saw		
--tagging grenades and throwing weapons isnt done here, but in blackmarkettweakdata instead

--Ammo Pickup: Acquire two values, the first value is the ammo pickup minimum, the second value is the pickup max, don't forget to calculate for walk-in closet if that's going to be in the overhaul.
		
--Piercing: All kinds can be defined with armor_piercing_chance being set to 1, can_shoot_through_enemy being set to true, can_shoot_through_shield being set to true and can_shoot_through_wall being set to true, I'm not sure what the effects of having some of the more extreme ones being set to true, while smaller ones being set to nil would be, be careful.
		
--Stability/Recoil: 1 point = 3, to get a weapon with 44 stability, the number you'd enter would end up being 12, the decimal is rounded down to 3, which results in the weapon having "44" stability in the weapon stat screen.

--Accuracy/Spread, Spread_Moving: Same as above, 1 = 3.

--Threat/Suppression: Instead of counting upwards, this one counts downwards, 1 = -3 from max Threat that can be achieved in-game (I assume), so for a weapon to have 28 threat, it's suppression would be "5", for a weapon to have 37 threat, it's suppression would be "2". Also, Suppression appears to be used as an index (probably in a lookup table), so it must be an integer.

--Damage/Damage: Consistent, 1 = 1, don't forget to calculate for Fast and Furious, if that's going to be in the overhaul, due to limitations, in order to achieve 200+ numbers, it needs to use a multiplier in a separate table, which will be included for every weapon, for consistency reasons, for example, in order to achieve 480 damage in a weapon, you cannot simply set it to deal 480 damage, you need to set damage to 48, and then multiply it by 10 on the multiplier table.

--Concealment/Concealment: Consistent, 1 = 1.

--Value: a lookup table. Just copy the stat from the comment.
		
--First gun of every category will have notes on the stats some of the unexplained stats if they weren't explained already by a previous category or this sheet, after that, it's all listening to music, drinking coffee at 2 in the morning while typing all the stuff out.

--Comment info template:			
--Weapon
	--ID: self.NAME
	--Class:
	--Value: 
	--Magazine: 
	--Ammo: 
	--Fire Rate: 
	--Damage:
	--Acc: 
	--Stab: 
	--Conc: 
	--Threat: 
	--Pickup: X, Y
	--Notes:
	--Active Mods: Reflects mods affecting the gun. 
	--Other mods related to the gun (that are not shared/common mods, eg suppressors) should be cosmetic only, retaining only their value.)

--BE AWARE all info in template above, other than value, reflects OUTPUT ingame, not code stats. See guidance above for conversion, entry.
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

		self.amcar.primary_class = "class_rapidfire"
		self.amcar.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 14,
			concealment = 30
		}
		self.amcar.stats_modifiers = {
			damage = 1
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
	
		self.tecci.primary_class = "class_rapidfire"
		self.tecci.subclasses = {}
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
			recoil = 24,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 8,
			concealment = 10
		}
		self.tecci.stats_modifiers = {
			damage = 1
		}
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
	
		self.g36.primary_class = "class_rapidfire"
		self.g36.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 14,
			concealment = 25
		}
		self.g36.stats_modifiers = {
			damage = 1
		}
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


		self.s552.primary_class = "class_rapidfire"
		self.s552.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 14,
			concealment = 30
		}
		self.s552.stats_modifiers = {
			damage = 1
		}
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

		self.famas.primary_class = "class_rapidfire"
		self.famas.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 14,
			concealment = 25
		}
		self.famas.stats_modifiers = {
			damage = 1
		}
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
	
-- todo mod
-- Prototype Barrel
-- +10 Concealment
-- -12 Accuracy
-- -20 Stability

		self.asval.primary_class = "class_rapidfire"
		self.asval.subclasses = {"subclass_quiet"}
		self.asval.FIRE_MODE = "auto"
		self.asval.categories = {
			"assault_rifle"
		}
		self.asval.fire_mode_data = {
			fire_rate = 0.11009174311927
		}
		self.asval.CAN_TOGGLE_FIREMODE = true
		self.asval.auto = {
			fire_rate = 0.11009174311927
		}
		self.asval.timers = {
			reload_not_empty = 2.6,
			reload_empty = 3.7,
			unequip = 0.5,
			equip = 0.5
		}
		self.asval.CLIP_AMMO_MAX = 20
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
			concealment = 20,
			suppression = 0,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 15,
			spread = 24,
			recoil = 26,
			value = 9,
			alert_size = 7,
			damage = 80,
			total_ammo_mod = 21,
			zoom = 1
		}
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

		self.new_m4.primary_class = "class_rapidfire"
		self.new_m4.subclasses = {}
		self.new_m4.FIRE_MODE = "auto"
		self.new_m4.fire_mode_data = {
			fire_rate = 0.1
		}
		self.new_m4.CAN_TOGGLE_FIREMODE = true
		self.new_m4.auto = {
			fire_rate = 0.1
		}
		self.new_m4.categories = {
			"assault_rifle"
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
			extra_ammo = 101,
			reload = 11,
			suppression = 10,
			concealment = 15
		}
		self.new_m4.stats_modifiers = {
			damage = 1
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

		self.ak74.primary_class = "class_rapidfire"
		self.ak74.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 10,
			concealment = 15
		}
		self.ak74.stats_modifiers = {
			damage = 1
		}
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

		self.flint.primary_class = "class_rapidfire"
		self.flint.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 10,
			concealment = 10
		}
		self.flint.stats_modifiers = {
			damage = 1
		}
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
			
		self.ak5.primary_class = "class_rapidfire"
		self.ak5.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 10,
			concealment = 15
		}
		self.ak5.stats_modifiers = {
			damage = 1
		}
		
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
			
		self.l85a2.primary_class = "class_rapidfire"
		self.l85a2.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 10,
			concealment = 15
		}
		self.l85a2.stats_modifiers = {
			damage = 1
		}
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

		self.aug.primary_class = "class_rapidfire"
		self.aug.subclasses = {}
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
		self.aug.AMMO_MAX = 210
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
			extra_ammo = 101,
			reload = 11,
			suppression = 10,
			concealment = 15
		}
		self.aug.stats_modifiers = {
			damage = 1
		}
		
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
			
		self.komodo.primary_class = "class_rapidfire"
		self.komodo.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 10,
			concealment = 20
		}
		self.komodo.stats_modifiers = {
			damage = 1
		}
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
			
		self.galil.primary_class = "class_rapidfire"
		self.galil.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 10,
			concealment = 15
		}
		self.galil.stats_modifiers = {
			damage = 1
		}
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

		self.vhs.primary_class = "class_rapidfire"
		self.vhs.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 10,
			concealment = 15
		}
		self.vhs.stats_modifiers = {
			damage = 1
		}
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

		self.corgi.primary_class = "class_rapidfire"
		self.corgi.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 10,
			concealment = 15
		}
		self.corgi.stats_modifiers = {
			damage = 1
		}
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

		self.akm.primary_class = "class_rapidfire"
		self.akm.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 9,
			concealment = 10
		}
		self.akm.stats_modifiers = {
			damage = 1
		}

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

		self.akm_gold.primary_class = "class_rapidfire"
		self.akm_gold.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 9,
			concealment = 10
		}
		self.akm_gold.stats_modifiers = {
			damage = 1
		}
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

		self.scar.primary_class = "class_rapidfire"
		self.scar.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 9,
			concealment = 10
		}
		self.scar.stats_modifiers = {
			damage = 1
		}
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

		self.g3.primary_class = "class_rapidfire"
		self.g3.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 9,
			concealment = 10
		}
		self.g3.stats_modifiers = {
			damage = 1
		}

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

		self.fal.primary_class = "class_rapidfire"
		self.fal.subclasses = {}
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
			spread = 26,
			spread_moving = 16,
			recoil = 22,
			value = 4,
			extra_ammo = 101,
			reload = 11,
			suppression = 9,
			concealment = 10
		}
		self.fal.stats_modifiers = {
			damage = 1
		}
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

		self.m16.primary_class = "class_rapidfire"
		self.m16.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 9,
			concealment = 10
		}
		self.m16.stats_modifiers = {
			damage = 1
		}

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
		self.x_stech.CLIP_AMMO_MAX = 40
		self.x_stech.fire_mode_data = {
			fire_rate = 0.08
		}
		self.x_stech.stats = {
			concealment = 32,
			suppression = 4,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 21,
			recoil = 12,
			value = 1,
			alert_size = 7,
			damage = 60,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_stech.AMMO_MAX = 400
		self.x_stech.primary_class = "class_rapidfire"
		self.x_stech.AMMO_PICKUP = {
			7,
			11
		}
		self.x_stech.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_stech.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
-- todo mod
-- Extended Mag.
-- +28 Magazine
-- -4 Concealment



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
	
		self.x_g18c.CLIP_AMMO_MAX = 40
		self.x_g18c.fire_mode_data = {
			fire_rate = 0.066006600660066
		}
		self.x_g18c.stats = {
			concealment = 32,
			suppression = 4,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 18,
			recoil = 23,
			value = 1,
			alert_size = 7,
			damage = 40,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_g18c.AMMO_MAX = 560
		self.x_g18c.primary_class = "class_rapidfire"
		self.x_g18c.AMMO_PICKUP = {
			9,
			18
		}
		self.x_g18c.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_g18c.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		
-- todo mod:
-- Extended Mag.
-- +24 Magazine
-- -4 Concealment



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
				self.x_czech.CLIP_AMMO_MAX = 30
		self.x_czech.fire_mode_data = {
			fire_rate = 0.06
		}
		self.x_czech.stats = {
			concealment = 32,
			suppression = 4,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 21,
			recoil = 21,
			value = 1,
			alert_size = 7,
			damage = 40,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_czech.AMMO_MAX = 600
		self.x_czech.primary_class = "class_rapidfire"
		self.x_czech.AMMO_PICKUP = {
			9,
			18
		}
		self.x_czech.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_czech.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
-- todo mod
-- Extended Magazine
-- +20 Magazine
-- -4 Concealment


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
		self.x_beer.CLIP_AMMO_MAX = 30
		self.x_beer.fire_mode_data = {
			fire_rate = 0.05449591280654
		}
		self.x_beer.stats = {
			concealment = 32,
			suppression = 4,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 22,
			recoil = 21,
			value = 1,
			alert_size = 7,
			damage = 40,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_beer.AMMO_MAX = 600
		self.x_beer.primary_class = "class_rapidfire"
		self.x_beer.AMMO_PICKUP = {
			9,
			18
		}
		self.x_beer.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_beer.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
-- todo mod
-- Extended Magazine
-- +12 Magazine
-- -2 Concealment



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
	
		self.x_coal.CLIP_AMMO_MAX = 128
		self.x_coal.fire_mode_data = {
			fire_rate = 0.092024539877301
		}
		self.x_coal.stats = {
			concealment = 25,
			suppression = 5,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 21,
			recoil = 22,
			value = 1,
			alert_size = 7,
			damage = 50,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_coal.AMMO_MAX = 320
		self.x_coal.primary_class = "class_rapidfire"
		self.x_coal.AMMO_PICKUP = {
			8,
			16
		}
		self.x_coal.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_coal.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		
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
	
		self.x_uzi.CLIP_AMMO_MAX = 64
		self.x_uzi.fire_mode_data = {
			fire_rate = 0.085959885386819
		}
		self.x_uzi.stats = {
			concealment = 25,
			suppression = 5,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 21,
			recoil = 22,
			value = 1,
			alert_size = 7,
			damage = 50,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_uzi.AMMO_MAX = 320
		self.x_uzi.primary_class = "class_rapidfire"
		self.x_uzi.AMMO_PICKUP = {
			8,
			16
		}
		self.x_uzi.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_uzi.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		
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
	
		self.x_shepheard.CLIP_AMMO_MAX = 40
		self.x_shepheard.fire_mode_data = {
			fire_rate = 0.08
		}
		self.x_shepheard.stats = {
			concealment = 25,
			suppression = 5,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 16,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 50,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_shepheard.AMMO_MAX = 320
		self.x_shepheard.primary_class = "class_rapidfire"
		self.x_shepheard.AMMO_PICKUP = {
			8,
			16
		}
		self.x_shepheard.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_shepheard.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		
-- todo mod:
-- Extended Magazine
-- +20 Magazine
-- -5 Concealment



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
	
		self.x_mp5.CLIP_AMMO_MAX = 60
		self.x_mp5.fire_mode_data = {
			fire_rate = 0.08
		}
		self.x_mp5.stats = {
			concealment = 25,
			suppression = 5,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 19,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 50,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_mp5.AMMO_MAX = 320
		self.x_mp5.primary_class = "class_rapidfire"
		self.x_mp5.AMMO_PICKUP = {
			8,
			16
		}
		self.x_mp5.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_mp5.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		
--todo mod
-- Extended Mag
-- +24 Magazine
-- -10 Concealment


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

		self.x_tec9.CLIP_AMMO_MAX = 40
		self.x_tec9.fire_mode_data = {
			fire_rate = 0.066964285714286
		}
		self.x_tec9.stats = {
			concealment = 30,
			suppression = 5,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 14,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 50,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_tec9.AMMO_MAX = 320
		self.x_tec9.primary_class = "class_rapidfire"
		self.x_tec9.AMMO_PICKUP = {
			8,
			16
		}
		self.x_tec9.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_tec9.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		
-- todo mod
-- Extended Mag
-- +24 Magazine
-- -10 Concealment


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
	
		self.x_mp9.CLIP_AMMO_MAX = 30
		self.x_mp9.fire_mode_data = {
			fire_rate = 0.063025210084034
		}
		self.x_mp9.stats = {
			concealment = 30,
			suppression = 5,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 14,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 50,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_mp9.AMMO_MAX = 320
		self.x_mp9.primary_class = "class_rapidfire"
		self.x_mp9.AMMO_PICKUP = {
			8,
			16
		}
		self.x_mp9.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_mp9.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		
-- todo mod
-- Extended Mag.
-- +30 Magazine
-- -5 Concealment
-- 
-- Tactical Suppressor
-- Suppresses Weapon
-- +Quiet
-- -100 Threat


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
	
		self.x_scorpion.CLIP_AMMO_MAX = 40
		self.x_scorpion.fire_mode_data = {
			fire_rate = 0.06
		}
		self.x_scorpion.stats = {
			concealment = 30,
			suppression = 5,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 14,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 50,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_scorpion.AMMO_MAX = 320
		self.x_scorpion.primary_class = "class_rapidfire"
		self.x_scorpion.AMMO_PICKUP = {
			8,
			16
		}
		self.x_scorpion.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_scorpion.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		
-- todo mod
-- Extended Mag
-- +40 Magazine
-- -10 Concealment


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
	
		self.x_baka.CLIP_AMMO_MAX = 64
		self.x_baka.fire_mode_data = {
			fire_rate = 0.05
		}
		self.x_baka.stats = {
			concealment = 25,
			suppression = 5,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 12,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 50,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_baka.AMMO_MAX = 320
		self.x_baka.primary_class = "class_rapidfire"
		self.x_baka.AMMO_PICKUP = {
			8,
			16
		}
		self.x_baka.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_baka.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		
-- todo mod
-- Futomaki Suppressor, Maki Suppressor, Spring Suppressor
-- Suppresses Weapon
-- +Quiet
-- -100 Threat


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
	
		self.x_olympic.CLIP_AMMO_MAX = 40
		self.x_olympic.fire_mode_data = {
			fire_rate = 0.087976539589443
		}
		self.x_olympic.stats = {
			concealment = 25,
			suppression = 7,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 24,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 70,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_olympic.AMMO_MAX = 240
		self.x_olympic.primary_class = "class_rapidfire"
		self.x_olympic.AMMO_PICKUP = {
			6,
			10
		}
		self.x_olympic.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_olympic.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		
-- todo mod
-- Milspec Mag, Tactical Mag, Expert Mag, L5 Magazine
-- +20 Magazine
-- -10 Concealment
-- 
-- CAR Quadstacked Mag
-- +80 Magazine
-- -20 Concealment
-- 
-- Drop Mag Tab
-- +100% Reload Speed
-- +20 Magazine
-- -8 Concealment



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
	
		self.x_m1928.CLIP_AMMO_MAX = 100
		self.x_m1928.fire_mode_data = {
			fire_rate = 0.08298755186722
		}
		self.x_m1928.stats = {
			concealment = 15,
			suppression = 10,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 22,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 70,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_m1928.AMMO_MAX = 240
		self.x_m1928.primary_class = "class_rapidfire"
		self.x_m1928.AMMO_PICKUP = {
			6,
			10
		}
		self.x_m1928.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_m1928.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		
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
	
		self.x_sr2.CLIP_AMMO_MAX = 60
		self.x_sr2.fire_mode_data = {
			fire_rate = 0.08
		}
		self.x_sr2.stats = {
			concealment = 25,
			suppression = 7,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 22,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 70,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_sr2.AMMO_MAX = 240
		self.x_sr2.primary_class = "class_rapidfire"
		self.x_sr2.AMMO_PICKUP = {
			6,
			10
		}
		self.x_sr2.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_sr2.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		
-- todo mod
-- Drop Mag Tab
-- +100% Reload Speed
-- -8 Concealment


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
		self.x_p90.CLIP_AMMO_MAX = 100
		self.x_p90.fire_mode_data = {
			fire_rate = 0.066006600660066
		}
		self.x_p90.stats = {
			concealment = 20,
			suppression = 7,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 21,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 70,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_p90.AMMO_MAX = 240
		self.x_p90.primary_class = "class_rapidfire"
		self.x_p90.AMMO_PICKUP = {
			6,
			10
		}
		self.x_p90.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_p90.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
-- todo mod
-- Drop Mag Tab
-- +100% Reload Speed
-- -8 Concealment


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
	
		self.x_mp7.CLIP_AMMO_MAX = 40
		self.x_mp7.fire_mode_data = {
			fire_rate = 0.063025210084034
		}
		self.x_mp7.stats = {
			concealment = 25,
			suppression = 7,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 22,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 70,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_mp7.AMMO_MAX = 240
		self.x_mp7.primary_class = "class_rapidfire"
		self.x_mp7.AMMO_PICKUP = {
			6,
			10
		}
		self.x_mp7.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_mp7.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		
-- todo mod
-- Extended Mag.
-- +20 Magazine
-- -5 Concealment


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
		self.x_mac10.CLIP_AMMO_MAX = 40
		self.x_mac10.fire_mode_data = {
			fire_rate = 0.06
		}
		self.x_mac10.stats = {
			concealment = 30,
			suppression = 6,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 22,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 70,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_mac10.AMMO_MAX = 240
		self.x_mac10.primary_class = "class_rapidfire"
		self.x_mac10.AMMO_PICKUP = {
			6,
			10
		}
		self.x_mac10.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_mac10.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
-- todo mod
-- Extended Mag.
-- +40 Magazine
-- -10 Concealment
-- 
-- Drop Mag Tab
-- +100% Reload Speed
-- +40 Magazine
-- -8 Concealment


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
	
		self.x_polymer.CLIP_AMMO_MAX = 60
		self.x_polymer.fire_mode_data = {
			fire_rate = 0.05
		}
		self.x_polymer.stats = {
			concealment = 15,
			suppression = 7,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 22,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 70,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_polymer.AMMO_MAX = 240
		self.x_polymer.primary_class = "class_rapidfire"
		self.x_polymer.AMMO_PICKUP = {
			6,
			10
		}
		self.x_polymer.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_polymer.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
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
		self.x_sterling.CLIP_AMMO_MAX = 40
		self.x_sterling.fire_mode_data = {
			fire_rate = 0.11009174311927
		}
		self.x_sterling.stats = {
			concealment = 20,
			suppression = 10,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 16,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 100,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_sterling.AMMO_MAX = 160
		self.x_sterling.primary_class = "class_rapidfire"
		self.x_sterling.AMMO_PICKUP = {
			4,
			6
		}
		self.x_sterling.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_sterling.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
-- todo mod
-- Extended Mag
-- +20 Magazine
-- -10 Concealment
 
-- Short Mag
-- -20 Magazine
-- +10 Concealment
 
-- Heatsinked Suppressed Barrel, Suppressed Barrel
-- Suppresses Weapon
-- +Quiet
-- -100 Threat

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

		self.x_cobray.CLIP_AMMO_MAX = 64
		self.x_cobray.fire_mode_data = {
			fire_rate = 0.05
		}
		self.x_cobray.stats = {
			concealment = 20,
			suppression = 7,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 19,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 70,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_cobray.AMMO_MAX = 240
		self.x_cobray.primary_class = "class_rapidfire"
		self.x_cobray.AMMO_PICKUP = {
			6,
			10
		}
		self.x_cobray.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_cobray.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}



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

		self.x_erma.CLIP_AMMO_MAX = 64
		self.x_erma.fire_mode_data = {
			fire_rate = 0.1
		}
		self.x_erma.stats = {
			concealment = 20,
			suppression = 10,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 18,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 100,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_erma.AMMO_MAX = 160
		self.x_erma.primary_class = "class_rapidfire"
		self.x_erma.AMMO_PICKUP = {
			4,
			6
		}
		self.x_erma.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_erma.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		
		
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

		self.x_m45.CLIP_AMMO_MAX = 72
		self.x_m45.fire_mode_data = {
			fire_rate = 0.1
		}
		self.x_m45.stats = {
			concealment = 20,
			suppression = 10,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 16,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 100,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_m45.AMMO_MAX = 160
		self.x_m45.primary_class = "class_rapidfire"
		self.x_m45.AMMO_PICKUP = {
			4,
			6
		}
		self.x_m45.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_m45.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		
-- todo mod
-- Extended Mag.
-- +28 Magazine
-- -15 Concealment



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

		self.x_schakal.CLIP_AMMO_MAX = 60
		self.x_schakal.fire_mode_data = {
			fire_rate = 0.092024539877301
		}
		self.x_schakal.stats = {
			concealment = 20,
			suppression = 10,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 17,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 100,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_schakal.AMMO_MAX = 160
		self.x_schakal.primary_class = "class_rapidfire"
		self.x_schakal.AMMO_PICKUP = {
			4,
			6
		}
		self.x_schakal.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_schakal.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}

-- todo mod
-- Extended Magazine
-- +20 Magazine
-- -15 Concealment

-- Short Magazine
-- -20 Magazine
-- +5 Concealment



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
	
		self.x_hajk.CLIP_AMMO_MAX = 60
		self.x_hajk.fire_mode_data = {
			fire_rate = 0.08
		}
		self.x_hajk.stats = {
			concealment = 20,
			suppression = 10,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 17,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 100,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_hajk.AMMO_MAX = 160
		self.x_hajk.primary_class = "class_rapidfire"
		self.x_hajk.AMMO_PICKUP = {
			4,
			6
		}
		self.x_hajk.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_hajk.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}


-- todo mod
-- Vintage Mag
-- -20 Magazine
-- +5 Concealment
-- 
-- CAR Quadstacked Mag
-- +60 Magazine
-- -20 Concealment
-- 
-- Drop Mag Tab
-- +100% Reload Speed
-- -4 Concealment

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

		self.x_akmsu.CLIP_AMMO_MAX = 60
		self.x_akmsu.fire_mode_data = {
			fire_rate = 0.072992700729927
		}
		self.x_akmsu.stats = {
			concealment = 20,
			suppression = 10,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 17,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 100,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_akmsu.AMMO_MAX = 160
		self.x_akmsu.primary_class = "class_rapidfire"
		self.x_akmsu.AMMO_PICKUP = {
			4,
			6
		}
		self.x_akmsu.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_akmsu.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}

-- todo mod
-- AK Quadstacked Mag
-- +60 Magazine
-- -15 Concealment
-- 
-- Drop Mag Tab
-- +100% Reload Speed
-- -4 Concealment


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

		self.b682.primary_class = "class_shotgun"
		self.b682.subclasses = {}
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
			extra_ammo = 101,
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

		self.huntsman.primary_class = "class_shotgun"
		self.huntsman.subclasses = {}
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
			extra_ammo = 101,
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

		self.boot.primary_class = "class_shotgun"
		self.boot.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 3,
			concealment = 20
		}
		self.boot.stats_modifiers = {
			damage = 1
		}
		self.boot.damage_near = 2000
		self.boot.damage_far = 3000
		self.boot.rays = 12
			
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
	
		self.x_judge.CLIP_AMMO_MAX = 10
		self.x_judge.fire_mode_data = {
			fire_rate = 0.12
		}
		self.x_judge.stats = {
			concealment = 30,
			suppression = 5,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 11,
			recoil = 1,
			value = 1,
			alert_size = 7,
			damage = 180,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_judge.AMMO_MAX = 60
		self.x_judge.primary_class = "class_shotgun"
		self.x_judge.AMMO_PICKUP = {
			0.5,
			1
		}
		self.x_judge.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_judge.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}


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

		self.r870.primary_class = "class_shotgun"
		self.r870.subclasses = {}
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
			extra_ammo = 101,
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

		self.ksg.primary_class = "class_shotgun"
		self.ksg.subclasses = {}
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
			extra_ammo = 101,
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

		self.spas12.primary_class = "class_shotgun"
		self.spas12.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 3,
			concealment = 25
		}
		self.spas12.stats_modifiers = {
			damage = 1
		}
		self.spas12.damage_near = 2000
		self.spas12.damage_far = 3000
		self.spas12.rays = 12
			
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

		self.benelli.primary_class = "class_shotgun"
		self.benelli.subclasses = {}
		self.benelli.FIRE_MODE = "single"
		self.benelli.fire_mode_data = {
			fire_rate = 0.13986013986
		}
		self.benelli.CAN_TOGGLE_FIREMODE = false
		self.benelli.single = {
			fire_rate = 0.13986013986
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
			spread = 11,
			spread_moving = 11,
			recoil = 26,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 3,
			concealment = 25
		}
		self.benelli.stats_modifiers = {
			damage = 1
		}
		self.benelli.damage_near = 2000
		self.benelli.damage_far = 3000
		self.benelli.rays = 12
			
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

		self.x_rota.CLIP_AMMO_MAX = 12
		self.x_rota.fire_mode_data = {
			fire_rate = 0.18018018018018
		}
		self.x_rota.stats = {
			concealment = 25,
			suppression = 7,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 11,
			recoil = 11,
			value = 1,
			alert_size = 7,
			damage = 80,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_rota.AMMO_MAX = 72
		self.x_rota.primary_class = "class_shotgun"
		self.x_rota.AMMO_PICKUP = {
			4,
			5
		}
		self.x_rota.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_rota.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}



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

		self.aa12.primary_class = "class_shotgun"
		self.aa12.subclasses = {}
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
			extra_ammo = 101,
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
			
		self.saiga.primary_class = "class_shotgun"
		self.saiga.subclasses = {}
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
		
		self.saiga.CLIP_AMMO_MAX = 7
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
			extra_ammo = 101,
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
	
		self.x_basset.CLIP_AMMO_MAX = 14
		self.x_basset.fire_mode_data = {
			fire_rate = 0.18018018018018
		}
		self.x_basset.stats = {
			concealment = 25,
			suppression = 11,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 11,
			recoil = 6,
			value = 1,
			alert_size = 7,
			damage = 40,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_basset.AMMO_MAX = 96
		self.x_basset.primary_class = "class_shotgun"
		self.x_basset.AMMO_PICKUP = {
			6,
			7
		}
		self.x_basset.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_basset.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}

		
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


		self.contraband.primary_class = "class_precision"
		self.contraband.subclasses = {}
		self.contraband.FIRE_MODE = "single"
		self.contraband.categories = {
			"assault_rifle"
		}
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
			2,
			3
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
			spread = 26,
			spread_moving = 26,
			recoil = 11,
			value = 9,
			extra_ammo = 101,
			reload = 11,
			suppression = 4,
			concealment = 5
		}
		self.contraband.stats_modifiers = {
			damage = 1
		}
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

		self.contraband_m203.primary_class = "class_specialist"
		self.contraband_m203.subclasses = {}
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
			0.1
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
			extra_ammo = 101,
			reload = 11,
			suppression = 2,
			concealment = 18 --doesn't matter, not used
		}
		self.contraband_m203.stats_modifiers = {
			damage = 10 --does not actually matter, projectile damage is defined elsewhere
		}

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

		self.sub2000.primary_class = "class_precision"
		self.sub2000.subclasses = {}
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
			3,
			4
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
		self.sub2000.can_shoot_through_enemy = true
		
		self.sub2000.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 160,
			alert_size = 7,
			spread = 26,
			spread_moving = 16,
			recoil = 4,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 14,
			concealment = 30
		}
		self.sub2000.stats_modifiers = {
			damage = 1
		}
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

		self.new_m14.primary_class = "class_precision"
		self.new_m14.subclasses = {}
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
		self.new_m14.AMMO_MAX = 80
		self.new_m14.AMMO_PICKUP = {
			3,
			4
		}
		
		self.new_m14.can_shoot_through_enemy = true
		
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
			spread = 26,
			spread_moving = 26,
			recoil = 22,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 8,
			concealment = 10
		}
		self.new_m14.stats_modifiers = {
			damage = 1
		}
		
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
	
		self.ching.primary_class = "class_precision"
		self.ching.subclasses = {}
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
			3,
			4
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
		
		self.ching.can_shoot_through_enemy = true
		
		self.ching.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 160,
			alert_size = 7,
			spread = 26,
			spread_moving = 26,
			recoil = 14,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 8,
			concealment = 20
		}
		self.ching.stats_modifiers = {
			damage = 1
		}
		
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

		self.tti.primary_class = "class_precision"
		self.tti.subclasses = {}
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
		self.tti.AMMO_MAX = 60
		self.tti.AMMO_PICKUP = {
			2.5,
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
			damage = 190,
			alert_size = 8,
			spread = 26,
			spread_moving = 26,
			recoil = 8,
			value = 9,
			extra_ammo = 101,
			reload = 11,
			suppression = 0,
			concealment = 20
		}
		self.tti.armor_piercing_chance = 1
		self.tti.stats_modifiers = {
			damage = 1
		}
			
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

		self.wa2000.primary_class = "class_precision"
		self.wa2000.subclasses = {}
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
		self.wa2000.AMMO_MAX = 60
		self.wa2000.AMMO_PICKUP = {
			2.5,
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
			damage = 190,
			alert_size = 8,
			spread = 26,
			spread_moving = 26,
			recoil = 8,
			value = 9,
			extra_ammo = 101,
			reload = 11,
			suppression = 0,
			concealment = 15
		}
		self.wa2000.armor_piercing_chance = 1
		self.wa2000.stats_modifiers = {
			damage = 1
		}
			
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

		self.siltstone.primary_class = "class_precision"
		self.siltstone.subclasses = {}
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
		self.siltstone.AMMO_MAX = 60
		self.siltstone.AMMO_PICKUP = {
			2.5,
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
			damage = 190,
			alert_size = 8,
			spread = 26,
			spread_moving = 26,
			recoil = 6,
			value = 9,
			extra_ammo = 101,
			reload = 11,
			suppression = 0,
			concealment = 15
		}
		self.siltstone.armor_piercing_chance = 1
		self.siltstone.stats_modifiers = {
			damage = 1
		}
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

		self.msr.primary_class = "class_precision"
		self.msr.subclasses = {}
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
		self.msr.AMMO_MAX = 60
		self.msr.AMMO_PICKUP = {
			2,
			2.5
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
			spread = 26,
			spread_moving = 26,
			recoil = 6,
			value = 9,
			extra_ammo = 101,
			reload = 11,
			suppression = 0,
			concealment = 10
		}
		self.msr.armor_piercing_chance = 1
		self.msr.stats_modifiers = {
			damage = 2
		}
		
		
	--------------------------------------
				--R700--
	--------------------------------------
		
		self.r700.CLIP_AMMO_MAX = 5
		self.r700.fire_mode_data = {
			fire_rate = 0.8
		}
		self.r700.stats_modifiers = {
			damage = 1.25
		}
		self.r700.can_shoot_through_shield = true
		self.r700.stats = {
			concealment = 20,
			suppression = 22,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 26,
			recoil = 6,
			value = 1,
			alert_size = 7,
			damage = 200,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.r700.armor_piercing_chance = 1
		self.r700.can_shoot_through_enemy = true
		self.r700.can_shoot_through_wall = true
		self.r700.AMMO_PICKUP = {
			2,
			2.5
		}
		self.r700.primary_class = "class_precision"
		self.r700.AMMO_MAX = 60
		self.r700.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.r700.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		
-- todo mod
-- Medium Barrel
-- Suppresses Weapon
-- +Quiet
-- -100 Threat




		
	--------------------------------------
				--Repeater 1874--
	--------------------------------------
	--ID: self.winchester1874
	--Class: Precision
	--Value: 9
	--Magazine: --INCOMPLETE field in document is blank, wiki sez 15
	--Ammo: 75
	--Fire Rate: 86
	--Damage: 250
	--Acc: 100
	--Stab: 60
	--Conc: 20
	--Threat: 14
	--Pickup: 3, 4
	--Notes: Armor Piercing, Body Piercing, Shield Piercing

		self.winchester1874.primary_class = "class_precision"
		self.winchester1874.subclasses = {}
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
		self.winchester1874.AMMO_MAX = 75
		self.winchester1874.AMMO_PICKUP = {
			3,
			4
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
			spread = 26,
			spread_moving = 26,
			recoil = 16,
			value = 9,
			extra_ammo = 101,
			reload = 11,
			suppression = 11,
			concealment = 20
		}
		self.winchester1874.armor_piercing_chance = 1
		self.winchester1874.stats_modifiers = {
			damage = 2
		}
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

		self.model70.primary_class = "class_precision"
		self.model70.subclasses = {}
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
			1.5,
			2.5
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
			spread = 26,
			spread_moving = 26,
			recoil = 13,
			value = 9,
			extra_ammo = 101,
			reload = 11,
			suppression = 0,
			concealment = 10
		}
		self.model70.armor_piercing_chance = 1
		self.model70.stats_modifiers = {
			damage = 4
		}
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

		self.r93.primary_class = "class_precision"
		self.r93.subclasses = {}
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
			1.5,
			2.5
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
			spread = 26,
			spread_moving = 26,
			recoil = 13,
			value = 9,
			extra_ammo = 101,
			reload = 11,
			suppression = 0,
			concealment = 10
		}
		self.r93.armor_piercing_chance = 1
		self.r93.stats_modifiers = {
			damage = 4
		}
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

		self.mosin.primary_class = "class_precision"
		self.mosin.subclasses = {}
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
		self.mosin.AMMO_MAX = 30
		self.mosin.AMMO_PICKUP = {
			1.5,
			2.5
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
			spread = 26,
			spread_moving = 26,
			recoil = 6,
			value = 9,
			extra_ammo = 101,
			reload = 11,
			suppression = 0,
			concealment = 15
		}
		self.mosin.armor_piercing_chance = 1
		self.mosin.stats_modifiers = {
			damage = 4
		}
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

		self.desertfox.primary_class = "class_precision"
		self.desertfox.subclasses = {}
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
		self.desertfox.AMMO_MAX = 30
		self.desertfox.AMMO_PICKUP = {
			1.5,
			2.5
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
			spread = 26,
			spread_moving = 26,
			recoil = 4,
			value = 10,
			extra_ammo = 101,
			reload = 11,
			suppression = 0,
			concealment = 25
		}
		self.desertfox.armor_piercing_chance = 1
		self.desertfox.stats_modifiers = {
			damage = 4
		}
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

	self.m95.primary_class = "class_heavy"
	self.m95.subclasses = {}
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
		self.m95.AMMO_MAX = 20
		self.m95.AMMO_PICKUP = {
			0.25,
			0.5
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
			spread = 26,
			spread_moving = 26,
			recoil = 0,
			value = 9,
			extra_ammo = 101,
			reload = 11,
			suppression = 0,
			concealment = 0
		}
		self.m95.armor_piercing_chance = 1
		self.m95.stats_modifiers = {
			damage = 35
		}
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
	
		self.x_ppk.CLIP_AMMO_MAX = 28
		self.x_ppk.fire_mode_data = {
			fire_rate = 0.125
		}
		self.x_ppk.stats = {
			concealment = 35,
			suppression = 0,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 26,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 20,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_ppk.AMMO_MAX = 168
		self.x_ppk.primary_class = "class_precision"
		self.x_ppk.AMMO_PICKUP = {
			4,
			8
		}
		self.x_ppk.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_ppk.kick = {
			standing = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			crouching = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			steelsight = {
				1.6,
				1.3,
				-0.3,
				0.3
			}
		}
		
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

		self.x_g17.CLIP_AMMO_MAX = 34
		self.x_g17.fire_mode_data = {
			fire_rate = 0.125
		}
		self.x_g17.stats = {
			concealment = 30,
			suppression = 4,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 22,
			recoil = 13,
			value = 1,
			alert_size = 7,
			damage = 50,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_g17.AMMO_MAX = 300
		self.x_g17.primary_class = "class_precision"
		self.x_g17.AMMO_PICKUP = {
			3,
			6
		}
		self.x_g17.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_g17.kick = {
			standing = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			crouching = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			steelsight = {
				1.6,
				1.3,
				-0.3,
				0.3
			}
		}
-- todo mod
-- Extended Magazine
-- +24 Magazine
-- -5 Concealment





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
	
		self.x_legacy.CLIP_AMMO_MAX = 26
		self.x_legacy.fire_mode_data = {
			fire_rate = 0.11009174311927
		}
		self.x_legacy.stats = {
			concealment = 30,
			suppression = 4,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 22,
			recoil = 13,
			value = 1,
			alert_size = 7,
			damage = 50,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_legacy.AMMO_MAX = 300
		self.x_legacy.primary_class = "class_precision"
		self.x_legacy.AMMO_PICKUP = {
			3,
			6
		}
		self.x_legacy.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_legacy.kick = {
			standing = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			crouching = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			steelsight = {
				1.6,
				1.3,
				-0.3,
				0.3
			}
		}
		
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
		self.jowi.CLIP_AMMO_MAX = 20
		self.jowi.fire_mode_data = {
			fire_rate = 0.089955022488756
		}
		self.jowi.stats = {
			concealment = 30,
			suppression = 4,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 22,
			recoil = 13,
			value = 1,
			alert_size = 7,
			damage = 50,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.jowi.AMMO_MAX = 300
		self.jowi.primary_class = "class_precision"
		self.jowi.AMMO_PICKUP = {
			3,
			6
		}
		self.jowi.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.jowi.kick = {
			standing = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			crouching = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			steelsight = {
				1.6,
				1.3,
				-0.3,
				0.3
			}
		}

-- todo mod
-- Extended Mag.
-- +24 Magazine
-- -5 Concealment


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
	
		self.x_shrew.CLIP_AMMO_MAX = 34
		self.x_shrew.fire_mode_data = {
			fire_rate = 0.089955022488756
		}
		self.x_shrew.stats = {
			concealment = 30,
			suppression = 4,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 22,
			recoil = 13,
			value = 1,
			alert_size = 7,
			damage = 50,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_shrew.AMMO_MAX = 300
		self.x_shrew.primary_class = "class_precision"
		self.x_shrew.AMMO_PICKUP = {
			3,
			6
		}
		self.x_shrew.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_shrew.kick = {
			standing = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			crouching = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			steelsight = {
				1.6,
				1.3,
				-0.3,
				0.3
			}
		}
-- todo mod
-- Extended Mag
-- +8 Magazine
-- -2 Concealment



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
		self.x_b92fs.CLIP_AMMO_MAX = 28
		self.x_b92fs.fire_mode_data = {
			fire_rate = 0.089955022488756
		}
		self.x_b92fs.stats = {
			concealment = 30,
			suppression = 4,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 22,
			recoil = 13,
			value = 1,
			alert_size = 7,
			damage = 50,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_b92fs.AMMO_MAX = 300
		self.x_b92fs.primary_class = "class_precision"
		self.x_b92fs.AMMO_PICKUP = {
			3,
			6
		}
		self.x_b92fs.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_b92fs.kick = {
			standing = {
				1.5,
				1.2,
				-0.3,
				0.3,
			},
			crouching = {
				1.5,
				1.2,
				-0.3,
				0.3,
			},
			steelsight = {
				1.5,
				1.2,
				-0.3,
				0.3,
			}
		}
-- todo mod 
-- Extended Mag.
-- +24 Magazine
-- -5 Concealment



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
		self.x_1911.CLIP_AMMO_MAX = 20
		self.x_1911.fire_mode_data = {
			fire_rate = 0.16620498614958
		}
		self.x_1911.stats = {
			concealment = 30,
			suppression = 6,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 24,
			recoil = 13,
			value = 1,
			alert_size = 7,
			damage = 80,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_1911.AMMO_MAX = 180
		self.x_1911.primary_class = "class_precision"
		self.x_1911.AMMO_PICKUP = {
			2,
			5
		}
		self.x_1911.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_1911.kick = {
			standing = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			crouching = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			steelsight = {
				1.6,
				1.3,
				-0.3,
				0.3
			}
		}
--todo mod
-- 12rnd Mag.
-- +4 Magazine
-- -2 Concealment

-- Magazine with Ameritude!
-- +24 Magazine
-- -5 Concealment



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
		self.x_packrat.CLIP_AMMO_MAX = 30
		self.x_packrat.fire_mode_data = {
			fire_rate = 0.16620498614958
		}
		self.x_packrat.stats = {
			concealment = 30,
			suppression = 6,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 24,
			recoil = 13,
			value = 1,
			alert_size = 7,
			damage = 80,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_packrat.AMMO_MAX = 180
		self.x_packrat.primary_class = "class_precision"
		self.x_packrat.AMMO_PICKUP = {
			2,
			5
		}
		self.x_packrat.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_packrat.kick = {
			standing = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			crouching = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			steelsight = {
				1.6,
				1.3,
				-0.3,
				0.3
			}
		}
-- todo mod
-- Extended Magazine
-- +20 Magazine
-- -5 Concealment


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
		self.x_p226.CLIP_AMMO_MAX = 24
		self.x_p226.fire_mode_data = {
			fire_rate = 0.16620498614958
		}
		self.x_p226.stats = {
			concealment = 30,
			suppression = 6,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 24,
			recoil = 13,
			value = 1,
			alert_size = 7,
			damage = 80,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_p226.AMMO_MAX = 180
		self.x_p226.primary_class = "class_precision"
		self.x_p226.AMMO_PICKUP = {
			2,
			5
		}
		self.x_p226.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_p226.kick = {
			standing = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			crouching = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			steelsight = {
				1.6,
				1.3,
				-0.3,
				0.3
			}
		}
-- todo mod
-- Extended Mag.
-- +16 Magazine
-- -5 Concealment


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
	
		self.x_c96.CLIP_AMMO_MAX = 20
		self.x_c96.fire_mode_data = {
			fire_rate = 0.16620498614958
		}
		self.x_c96.stats = {
			concealment = 30,
			suppression = 6,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 24,
			recoil = 13,
			value = 1,
			alert_size = 7,
			damage = 80,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_c96.AMMO_MAX = 180
		self.x_c96.primary_class = "class_precision"
		self.x_c96.AMMO_PICKUP = {
			2,
			5
		}
		self.x_c96.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_c96.kick = {
			standing = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			crouching = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			steelsight = {
				1.6,
				1.3,
				-0.3,
				0.3
			}
		}
		
-- todo mod
-- High Capacity Mag
-- +20 Magazine
-- -5 Concealment

-- Precision Barrel
-- +Armor Piercing
-- -45 Ammo Stock
-- +30 Damage
-- -12 Stability
-- -5 Concealment
-- -0.5 Pickup Low
-- -2 Pickup High

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
		self.x_usp.CLIP_AMMO_MAX = 26
		self.x_usp.fire_mode_data = {
			fire_rate = 0.16620498614958
		}
		self.x_usp.stats = {
			concealment = 30,
			suppression = 6,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 24,
			recoil = 13,
			value = 1,
			alert_size = 7,
			damage = 80,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_usp.AMMO_MAX = 180
		self.x_usp.primary_class = "class_precision"
		self.x_usp.AMMO_PICKUP = {
			2,
			5
		}
		self.x_usp.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_usp.kick = {
			standing = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			crouching = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			steelsight = {
				1.6,
				1.3,
				-0.3,
				0.3
			}
		}
		
-- todo mod
-- Extended Mag.
-- +16 Magazine
-- -4 Concealment

-- I want more Magazine!
-- +24 Magazine
-- -8 Concealment



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
		self.x_hs2000.CLIP_AMMO_MAX = 38
		self.x_hs2000.fire_mode_data = {
			fire_rate = 0.16620498614958
		}
		self.x_hs2000.stats = {
			concealment = 30,
			suppression = 6,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 24,
			recoil = 13,
			value = 1,
			alert_size = 7,
			damage = 80,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_hs2000.AMMO_MAX = 180
		self.x_hs2000.primary_class = "class_precision"
		self.x_hs2000.AMMO_PICKUP = {
			2,
			5
		}
		self.x_hs2000.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_hs2000.kick = {
			standing = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			crouching = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			steelsight = {
				1.6,
				1.3,
				-0.3,
				0.3
			}
		}
-- todo mod
-- Extended Mag
-- +16 Magazine
-- -5 Concealment



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
		self.x_g22c.CLIP_AMMO_MAX = 32
		self.x_g22c.fire_mode_data = {
			fire_rate = 0.16620498614958
		}
		self.x_g22c.stats = {
			concealment = 30,
			suppression = 6,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 24,
			recoil = 13,
			value = 1,
			alert_size = 7,
			damage = 80,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_g22c.AMMO_MAX = 180
		self.x_g22c.primary_class = "class_precision"
		self.x_g22c.AMMO_PICKUP = {
			2,
			5
		}
		self.x_g22c.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_g22c.kick = {
			standing = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			crouching = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			steelsight = {
				1.6,
				1.3,
				-0.3,
				0.3
			} 
		}

-- todo mod
-- Extended Mag.
-- +24 Magazine
-- -5 Concealment




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
		self.x_deagle.armor_piercing_chance = 1
		self.x_deagle.CLIP_AMMO_MAX = 20
		self.x_deagle.fire_mode_data = {
			fire_rate = 0.25
		}
		self.x_deagle.stats = {
			concealment = 30,
			suppression = 5,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 25,
			recoil = 6,
			value = 1,
			alert_size = 7,
			damage = 110,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_deagle.AMMO_MAX = 90
		self.x_deagle.primary_class = "class_precision"
		self.x_deagle.AMMO_PICKUP = {
			1.5,
			3
		}
		self.x_deagle.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_deagle.kick = {
			standing = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			crouching = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			steelsight = {
				1.6,
				1.3,
				-0.3,
				0.3
			}
		}
-- todo mod
-- Extended Magazine
-- +12 Magazine
-- -5 Concealment



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
		self.x_breech.armor_piercing_chance = 1
		self.x_breech.CLIP_AMMO_MAX = 16
		self.x_breech.fire_mode_data = {
			fire_rate = 0.16620498614958
		}
		self.x_breech.stats = {
			concealment = 30,
			suppression = 5,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 25,
			recoil = 6,
			value = 1,
			alert_size = 7,
			damage = 110,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_breech.AMMO_MAX = 90
		self.x_breech.primary_class = "class_precision"
		self.x_breech.AMMO_PICKUP = {
			1.5,
			3
		}
		self.x_breech.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_breech.kick = {
			standing = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			crouching = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			steelsight = {
				1.6,
				1.3,
				-0.3,
				0.3
			}
		}



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
		self.x_sparrow.armor_piercing_chance = 1
		self.x_sparrow.CLIP_AMMO_MAX = 24
		self.x_sparrow.fire_mode_data = {
			fire_rate = 0.16620498614958
		}
		self.x_sparrow.stats = {
			concealment = 30,
			suppression = 5,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 25,
			recoil = 6,
			value = 1,
			alert_size = 7,
			damage = 110,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_sparrow.AMMO_MAX = 90
		self.x_sparrow.primary_class = "class_precision"
		self.x_sparrow.AMMO_PICKUP = {
			1.5,
			3
		}
		self.x_sparrow.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_sparrow.kick = {
			standing = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			crouching = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			steelsight = {
				1.6,
				1.3,
				-0.3,
				0.3
			}
		}



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
		self.x_pl14.armor_piercing_chance = 1
		self.x_pl14.CLIP_AMMO_MAX = 24
		self.x_pl14.fire_mode_data = {
			fire_rate = 0.16620498614958
		}
		self.x_pl14.stats = {
			concealment = 30,
			suppression = 5,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 25,
			recoil = 6,
			value = 1,
			alert_size = 7,
			damage = 110,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_pl14.AMMO_MAX = 90
		self.x_pl14.primary_class = "class_precision"
		self.x_pl14.AMMO_PICKUP = {
			1.5,
			3
		}
		self.x_pl14.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_pl14.kick = {
			standing = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			crouching = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			steelsight = {
				1.6,
				1.3,
				-0.3,
				0.3
			}
		}
-- todo mod
-- Extended Magazine
-- +4 Magazine
-- -1 Concealment



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
		self.x_2006m.CLIP_AMMO_MAX = 12
		self.x_2006m.fire_mode_data = {
			fire_rate = 0.16620498614958
		}
		self.x_2006m.armor_piercing_chance = 1
		self.x_2006m.can_shoot_through_shield = true
		self.x_2006m.stats = {
			concealment = 30,
			suppression = 5,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 26,
			recoil = 1,
			value = 1,
			alert_size = 7,
			damage = 160,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_2006m.can_shoot_through_enemy = true
		self.x_2006m.can_shoot_through_wall = true
		self.x_2006m.AMMO_PICKUP = {
			1,
			2
		}
		self.x_2006m.primary_class = "class_precision"
		self.x_2006m.AMMO_MAX = 90
		self.x_2006m.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_2006m.kick = {
			standing = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			crouching = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			steelsight = {
				1.6,
				1.3,
				-0.3,
				0.3
			}
		}



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
		self.x_rage.CLIP_AMMO_MAX = 12
		self.x_rage.fire_mode_data = {
			fire_rate = 0.16620498614958
		}
		self.x_rage.armor_piercing_chance = 1
		self.x_rage.can_shoot_through_shield = true
		self.x_rage.stats = {
			concealment = 30,
			suppression = 5,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 26,
			recoil = 1,
			value = 1,
			alert_size = 7,
			damage = 160,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_rage.can_shoot_through_enemy = true
		self.x_rage.can_shoot_through_wall = true
		self.x_rage.AMMO_PICKUP = {
			1,
			2
		}
		self.x_rage.primary_class = "class_precision"
		self.x_rage.AMMO_MAX = 90
		self.x_rage.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_rage.kick = {
			standing = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			crouching = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			steelsight = {
				1.6,
				1.3,
				-0.3,
				0.3
			}
		}



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
	
		self.x_chinchilla.CLIP_AMMO_MAX = 12
		self.x_chinchilla.fire_mode_data = {
			fire_rate = 0.16620498614958
		}
		self.x_chinchilla.armor_piercing_chance = 1
		self.x_chinchilla.can_shoot_through_shield = true
		self.x_chinchilla.stats = {
			concealment = 30,
			suppression = 5,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 26,
			recoil = 1,
			value = 1,
			alert_size = 7,
			damage = 160,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.x_chinchilla.can_shoot_through_enemy = true
		self.x_chinchilla.can_shoot_through_wall = true
		self.x_chinchilla.AMMO_PICKUP = {
			1,
			2
		}
		self.x_chinchilla.primary_class = "class_precision"
		self.x_chinchilla.AMMO_MAX = 90
		self.x_chinchilla.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.x_chinchilla.kick = {
			standing = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			crouching = {
				1.6,
				1.3,
				-0.3,
				0.3
			},
			steelsight = {
				1.6,
				1.3,
				-0.3,
				0.3
			}
		}



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

		self.rpk.primary_class = "class_heavy"
		self.rpk.subclasses = {}
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
		
		self.rpk.CLIP_AMMO_MAX = 75
		self.rpk.AMMO_MAX = 160
		self.rpk.AMMO_PICKUP = {
			0.5,
			0.6
		}
		
		self.rpk.can_shoot_through_enemy = true
		self.rpk.can_shoot_through_shield = true
		self.rpk.can_shoot_through_wall = true
		self.rpk.armor_piercing_chance = 1
		
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
			spread = 20,
			spread_moving = 20,
			recoil = 23,
			value = 9,
			extra_ammo = 101,
			reload = 11,
			suppression = 0,
			concealment = 1
		}
		self.rpk.stats_modifiers = {
			damage = 1
		}

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

		self.hk21.primary_class = "class_heavy"
		self.hk21.subclasses = {}
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
		
		self.hk21.can_shoot_through_enemy = true
		self.hk21.can_shoot_through_shield = true
		self.hk21.can_shoot_through_wall = true
		self.hk21.armor_piercing_chance = 1
		
		self.hk21.CLIP_AMMO_MAX = 80
		self.hk21.AMMO_MAX = 120
		self.hk21.AMMO_PICKUP = {
			0.4,
			0.5
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
			damage = 150,
			alert_size = 8,
			spread = 16,
			spread_moving = 16,
			recoil = 18,
			value = 9,
			extra_ammo = 101,
			reload = 11,
			suppression = 0,
			concealment = 1
		}
		self.hk21.stats_modifiers = {
			damage = 1
		}

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

		self.par.primary_class = "class_heavy"
		self.par.subclasses = {}
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
		
		self.par.CLIP_AMMO_MAX = 50
		self.par.AMMO_MAX = 120
		self.par.AMMO_PICKUP = {
			0.4,
			0.5
		}
		
		self.par.can_shoot_through_enemy = true
		self.par.can_shoot_through_shield = true
		self.par.can_shoot_through_wall = true
		self.par.armor_piercing_chance = 1
		
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
			damage = 150,
			alert_size = 8,
			spread = 18,
			spread_moving = 18,
			recoil = 20,
			value = 9,
			extra_ammo = 101,
			reload = 11,
			suppression = 0,
			concealment = 1
		}
		self.par.stats_modifiers = {
			damage = 1
		}
		
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

		self.m249.primary_class = "class_heavy"
		self.m249.subclasses = {}
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
		
		self.m249.CLIP_AMMO_MAX = 100
		self.m249.AMMO_MAX = 160
		self.m249.AMMO_PICKUP = {
			0.5,
			0.6
		}
		
		self.m249.can_shoot_through_enemy = true
		self.m249.can_shoot_through_shield = true
		self.m249.can_shoot_through_wall = true
		self.m249.armor_piercing_chance = 1
		
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
			damage = 120,
			alert_size = 8,
			spread = 23,
			spread_moving = 23,
			recoil = 24,
			value = 9,
			extra_ammo = 101,
			reload = 11,
			suppression = 0,
			concealment = 1
		}
		self.m249.stats_modifiers = {
			damage = 1
		}

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

		self.mg42.primary_class = "class_heavy"
		self.mg42.subclasses = {}
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
		
		self.mg42.CLIP_AMMO_MAX = 50
		self.mg42.AMMO_MAX = 120
		self.mg42.AMMO_PICKUP = {
			0.4,
			0.5
		}
		
		self.mg42.can_shoot_through_enemy = true
		self.mg42.can_shoot_through_shield = true
		self.mg42.can_shoot_through_wall = true
		self.mg42.armor_piercing_chance = 1
		
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
			damage = 150,
			alert_size = 8,
			spread = 19,
			spread_moving = 19,
			recoil = 23,
			value = 9,
			extra_ammo = 101,
			reload = 11,
			suppression = 0,
			concealment = 0
		}
		self.mg42.stats_modifiers = {
			damage = 1
		}

	--------------------------------------
		--M60--
	--------------------------------------
		self.m60.CLIP_AMMO_MAX = 100
		self.m60.fire_mode_data = {
			fire_rate = 0.10909090909091
		}
		self.m60.armor_piercing_chance = 1
		self.m60.can_shoot_through_shield = true
		self.m60.stats = {
			concealment = 0,
			suppression = 22,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 23,
			recoil = 24,
			value = 1,
			alert_size = 7,
			damage = 120,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.m60.can_shoot_through_enemy = true
		self.m60.can_shoot_through_wall = true
		self.m60.AMMO_PICKUP = {
			0.5,
			0.6
		}
		self.m60.primary_class = "class_heavy"
		self.m60.AMMO_MAX = 160
		self.m60.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.m60.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}



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
		
		self.shuno.primary_class = "class_heavy"
		self.shuno.subclasses = {}
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
		
		self.shuno.can_shoot_through_enemy = true
		self.shuno.can_shoot_through_shield = true
		self.shuno.can_shoot_through_wall = true
		self.shuno.armor_piercing_chance = 1
		
		self.shuno.CLIP_AMMO_MAX = 600
		self.shuno.AMMO_MAX = 200
		--self.shuno.starting_ammo = 200
		--self.shuno.starts_empty = true
		self.shuno.AMMO_PICKUP = {
			0,
			0
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
			damage = 100,
			alert_size = 8,
			spread = 10,
			spread_moving = 5,
			recoil = 23,
			value = 9,
			extra_ammo = 101,
			reload = 11,
			suppression = 0,
			concealment = 0
		}
		self.shuno.stats_modifiers = {
			damage = 1
		}

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

		self.m134.primary_class = "class_heavy"
		self.m134.subclasses = {}
		self.m134.FIRE_MODE = "auto"
		self.m134.fire_mode_data = {
			fire_rate = 0.03
		}
		self.m134.CAN_TOGGLE_FIREMODE = false
		self.m134.auto = {
			fire_rate = 0.03
		}
		self.m134.timers = {
			reload_not_empty = 7.8,
			reload_empty = 7.8,
			unequip = 0.9,
			equip = 0.9
		}
		
		self.m134.can_shoot_through_enemy = true
		self.m134.can_shoot_through_shield = true
		self.m134.can_shoot_through_wall = true
		self.m134.armor_piercing_chance = 1
		
		self.m134.CLIP_AMMO_MAX = 600
		self.m134.NR_CLIPS_MAX = 1
		--self.m134.starting_ammo = 200
		--self.m134.starts_empty = true
		self.m134.AMMO_MAX = 200
		self.m134.AMMO_PICKUP = {
			0,
			0
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
			damage = 100,
			alert_size = 7,
			spread = 10,
			spread_moving = 13,
			recoil = 23,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 22,
			concealment = 0
		}
		self.m134.stats_modifiers = {
			damage = 1
		}
-- todo mod
-- I’ll Take Half That Kit
-- -1500 Fire Rate
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
		self.ecp.CLIP_AMMO_MAX = 6
		self.ecp.fire_mode_data = {
			fire_rate = 0.5
		}
		self.ecp.stats_modifiers = {
			damage = 3.5
		}
		self.ecp.stats = {
			concealment = 20,
			suppression = 0,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 26,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 200,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.ecp.armor_piercing_chance = 1
		self.ecp.AMMO_PICKUP = {
			0,
			0
		}
		self.ecp.primary_class = "class_precision"
		self.ecp.subclasses = {"subclass_quiet"}
		self.ecp.AMMO_MAX = 30
		self.ecp.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.ecp.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
-- todo mod
-- Explosive Arrow
-- - Armor Piercing
-- 2x Headshot Damage
-- 
-- Poison Arrow
-- -560 Damage
-- +Poison




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
		self.frankish.CLIP_AMMO_MAX = 1
		self.frankish.fire_mode_data = {
			fire_rate = 1.5
		}
		self.frankish.stats_modifiers = {
			damage = 3.75
		}
		self.frankish.stats = {
			concealment = 30,
			suppression = 0,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 26,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 200,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.frankish.armor_piercing_chance = 1
		self.frankish.AMMO_PICKUP = {
			0,
			0
		}
		self.frankish.primary_class = "class_precision"
		self.frankish.subclasses = {"subclass_quiet"}
		self.frankish.AMMO_MAX = 50
		self.frankish.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.frankish.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
-- todo mod
-- Explosive Bolt
-- - Armor Piercing
-- 2x Headshot Damage
-- 
-- Poison Bolt
-- -600 Damage
-- +Poison


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
		self.plainsrider.CLIP_AMMO_MAX = 1
		self.plainsrider.fire_mode_data = {
			fire_rate = 0.2
		}
		self.plainsrider.stats_modifiers = {
			damage = 5
		}
		self.plainsrider.stats = {
			concealment = 30,
			suppression = 0,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 26,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 200,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.plainsrider.armor_piercing_chance = 1
		self.plainsrider.AMMO_PICKUP = {
			0,
			0
		}
		self.plainsrider.primary_class = "class_precision"
		self.plainsrider.subclasses = { "subclass_quiet" }
		self.plainsrider.AMMO_MAX = 60
		self.plainsrider.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.plainsrider.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
-- todo mod
-- Explosive Arrows
-- - Armor Piercing
-- 2x Headshot Damage
-- 
-- Poisoned Arrows
-- -200 Damage
-- +Poison

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
		self.elastic.CLIP_AMMO_MAX = 1
		self.elastic.fire_mode_data = {
			fire_rate = 0.2
		}
		self.elastic.stats = {
			concealment = 30,
			suppression = 0,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 26,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 200,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.elastic.subclasses = { "subclass_quiet" }
		self.elastic.stats_modifiers = {
			damage = 10
		}
		self.elastic.primary_class = "class_precision"
		self.elastic.armor_piercing_chance = 1
		self.plainsrider.AMMO_MAX = 40
		self.elastic.AMMO_PICKUP = {
			0,
			0
		}
		self.elastic.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.elastic.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}

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
		self.long.CLIP_AMMO_MAX = 1
		self.long.fire_mode_data = {
			fire_rate = 0.2
		}
		self.long.stats_modifiers = {
			damage = 10
		}
		self.long.stats = {
			concealment = 30,
			suppression = 0,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 26,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 200,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.long.armor_piercing_chance = 1
		self.long.AMMO_PICKUP = {
			0,
			0
		}
		self.long.primary_class = "class_precision"
		self.long.subclasses = { "subclass_quiet" }
		self.long.AMMO_MAX = 40
		self.long.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.long.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}




-- Explosive Arrows
-- - Armor Piercing
-- 2x Headshot Damage
-- 
-- Poisoned Arrows
-- -1600 Damage
-- +Poison

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
		self.arblast.CLIP_AMMO_MAX = 1
		self.arblast.fire_mode_data = {
			fire_rate = 2.8571428571429
		}
		self.arblast.stats_modifiers = {
			damage = 10
		}
		self.arblast.stats = {
			concealment = 30,
			suppression = 0,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 26,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 200,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.arblast.armor_piercing_chance = 1
		self.arblast.AMMO_PICKUP = {
			0,
			0
		}
		self.arblast.primary_class = "class_precision"
		self.arblast.subclasses = { "subclass_quiet" }
		self.arblast.AMMO_MAX = 40
		self.arblast.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.arblast.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}

-- todo mod
-- Explosive Bolt
-- - Armor Piercing
-- 2x Headshot Damage
-- 
-- Poisoned Bolt
-- -1600 Damage
-- +Poison

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
		self.gre_m79.stats_modifiers = {
			damage = 5.5
		}
		self.gre_m79.CLIP_AMMO_MAX = 1
		self.gre_m79.fire_mode_data = {
			fire_rate = 2
		}
		self.gre_m79.stats = {
			concealment = 25,
			suppression = 22,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 26,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 200,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.gre_m79.AMMO_MAX = 6
		self.gre_m79.primary_class = "class_specialist"
		self.gre_m79.subclasses = {}
		self.gre_m79.AMMO_PICKUP = {
			0.1,
			0.2
		}
		self.gre_m79.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.gre_m79.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}

-- todo mod
-- Incendiary Round
-- -1000 Damage
-- +Area Denial in a large area for 15 seconds.

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
	
		self.m32.stats_modifiers = {
			damage = 5.5
		}
		self.m32.CLIP_AMMO_MAX = 6
		self.m32.fire_mode_data = {
			fire_rate = 1
		}
		self.m32.stats = {
			concealment = 0,
			suppression = 22,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 26,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 200,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.m32.AMMO_MAX = 12
		self.m32.primary_class = "class_specialist"
		self.m32.subclasses = {}
		self.m32.AMMO_PICKUP = {
			0.15,
			0.25
		}
		self.m32.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.m32.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		
-- todo mod
-- Incendiary Round
-- -1000 Damage
-- + Area Denial in a large area for 15 seconds.

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
		self.flamethrower_mk2.CLIP_AMMO_MAX = 900
		self.flamethrower_mk2.fire_mode_data = {
			fire_rate = 0.03
		}
		self.flamethrower_mk2.armor_piercing_chance = 1
		self.flamethrower_mk2.can_shoot_through_shield = true
		self.flamethrower_mk2.stats = {
			concealment = 10,
			suppression = 22,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 1,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 100,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.flamethrower_mk2.can_shoot_through_enemy = true
		self.flamethrower_mk2.can_shoot_through_wall = true
		self.flamethrower_mk2.AMMO_PICKUP = {
			0,
			0
		}
		self.flamethrower_mk2.primary_class = "class_specialist"
		self.flamethrower_mk2.subclasses = {"subclass_areadenial"}
		self.flamethrower_mk2.AMMO_MAX = 900
		self.flamethrower_mk2.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.flamethrower_mk2.kick = {
			standing = {
				0,
				0,
				0,
				0
			},
			crouching = {
				0,
				0,
				0,
				0
			},
			steelsight = {
				0,
				0,
				0,
				0
			}
		}



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

		self.ppk.primary_class = "class_precision"
		self.ppk.subclasses = {}
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
		self.ppk.AMMO_MAX = 168
		self.ppk.AMMO_PICKUP = {
			4,
			5
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
			damage = 20,
			alert_size = 7,
			spread = 26,
			spread_moving = 26,
			recoil = 26,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 26,
			concealment = 35
		}
		self.ppk.stats_modifiers = {
			damage = 1
		}
	--------------------------------------
				--Chimano 88--
	--------------------------------------
	--ID: self.glock_17 NOTE different in weaponfactory
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
		
		
		self.glock_17.primary_class = "class_precision"
		self.glock_17.subclasses = {}
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
		
		self.glock_17.CLIP_AMMO_MAX = 17
		self.glock_17.AMMO_MAX = 180
		self.glock_17.AMMO_PICKUP = {
			3,  
			6
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
			damage = 50,
			alert_size = 7,
			spread = 26,
			spread_moving = 26,
			recoil = 15,
			value = 1,
			extra_ammo = 101, --Don't worry about this.
			reload = 11, --AFAIK not actually tied to reload in anyway whatsoever???
			suppression = 18,
			concealment = 30
		}
		self.glock_17.stats_modifiers = {
			damage = 1 --Damage multiplier, for consistency's sake, don't change this from 1 unless you need to achieve damage numbers higher than 200.
		}
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

		self.legacy.primary_class = "class_precision"
		self.legacy.subclasses = {}
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
		self.legacy.AMMO_MAX = 180
		self.legacy.AMMO_PICKUP = {
			3,
			6
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
			damage = 50,
			alert_size = 7,
			spread = 26,
			spread_moving = 26,
			recoil = 13,
			value = 4,
			extra_ammo = 101,
			reload = 11,
			suppression = 16,
			concealment = 30
		}
		self.legacy.stats_modifiers = {
			damage = 1
		}
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

		self.g26.primary_class = "class_precision"
		self.g26.subclasses = {}
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
		self.g26.AMMO_MAX = 180
		self.g26.AMMO_PICKUP = {
			3,
			6
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
			damage = 50,
			alert_size = 7,
			spread = 26,
			spread_moving = 26,
			recoil = 13,
			value = 4,
			extra_ammo = 101,
			reload = 11,
			suppression = 16,
			concealment = 30
		}
		self.g26.stats_modifiers = {
			damage = 1
		}
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

			self.shrew.primary_class = "class_precision"
		self.shrew.subclasses = {}
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
		self.shrew.AMMO_MAX = 180
		self.shrew.AMMO_PICKUP = {
			3,
			6
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
			zoom = 3,
			total_ammo_mod = 21,
			damage = 50,
			alert_size = 7,
			spread = 26,
			spread_moving = 26,
			recoil = 13,
			value = 4,
			extra_ammo = 101,
			reload = 11,
			suppression = 16,
			concealment = 30
		}
		self.shrew.stats_modifiers = {
			damage = 1
		}
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

		self.b92fs.primary_class = "class_precision"
		self.b92fs.subclasses = {}
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
		
		self.b92fs.CLIP_AMMO_MAX = 28
		self.b92fs.AMMO_MAX = 180
		self.b92fs.AMMO_PICKUP = {
			3,  
			6
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
			damage = 50,
			alert_size = 7,
			spread = 26,
			spread_moving = 26,
			recoil = 13,
			value = 4,
			extra_ammo = 101,
			reload = 11,
			suppression = 16,
			concealment = 30
		}
		self.b92fs.stats_modifiers = {
			damage = 1
		}
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

		self.colt_1911.primary_class = "class_precision"
		self.colt_1911.subclasses = {}
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
		self.colt_1911.AMMO_MAX = 90
		self.colt_1911.AMMO_PICKUP = {
			2,  
			5
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
			damage = 80,
			alert_size = 7,
			spread = 26,
			spread_moving = 26,
			recoil = 15,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 13,
			concealment = 30
		}
		self.colt_1911.stats_modifiers = {
			damage = 1
		}
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

		self.packrat.primary_class = "class_precision"
		self.packrat.subclasses = {}
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
		self.packrat.AMMO_MAX = 90
		self.packrat.AMMO_PICKUP = {
			2,
			5
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
			damage = 80,
			alert_size = 7,
			spread = 26,
			spread_moving = 26,
			recoil = 13,
			value = 4,
			extra_ammo = 101,
			reload = 11,
			suppression = 13,
			concealment = 30
		}
		self.packrat.stats_modifiers = {
			damage = 1
		}
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

		self.p226.primary_class = "class_precision"
		self.p226.subclasses = {}
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
		self.p226.AMMO_MAX = 90
		self.p226.AMMO_PICKUP = {
			2,
			5
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
			damage = 80,
			alert_size = 7,
			spread = 26,
			spread_moving = 26,
			recoil = 13,
			value = 4,
			extra_ammo = 101,
			reload = 11,
			suppression = 13,
			concealment = 30
		}
		self.p226.stats_modifiers = {
			damage = 1
		}
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
	
		self.c96.primary_class = "class_precision"
		self.c96.subclasses = {}
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
		
		self.c96.CLIP_AMMO_MAX = 20
		self.c96.AMMO_MAX = 90
		self.c96.AMMO_PICKUP = {
			2,
			5
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
			damage = 80,
			alert_size = 7,
			spread = 26,
			spread_moving = 26,
			recoil = 16,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 13,
			concealment = 30
		}
		self.c96.stats_modifiers = {
			damage = 1
		}
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

		self.usp.primary_class = "class_precision"
		self.usp.subclasses = {}
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
		self.usp.AMMO_MAX = 90
		self.usp.AMMO_PICKUP = {
			2,
			5
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
			zoom = 3,
			total_ammo_mod = 21,
			damage = 80,
			alert_size = 7,
			spread = 26,
			spread_moving = 26,
			recoil = 13,
			value = 4,
			extra_ammo = 101,
			reload = 11,
			suppression = 13,
			concealment = 30
		}
		self.usp.stats_modifiers = {
			damage = 1
		}
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
			
		self.hs2000.primary_class = "class_precision"
		self.hs2000.subclasses = {}
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
		
		self.hs2000.CLIP_AMMO_MAX = 38
		self.hs2000.AMMO_MAX = 90
		self.hs2000.AMMO_PICKUP = {
			2,
			5
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
			damage = 80,
			alert_size = 7,
			spread = 26,
			spread_moving = 26,
			recoil = 13,
			value = 4,
			extra_ammo = 101,
			reload = 11,
			suppression = 13,
			concealment = 30
		}
		self.hs2000.stats_modifiers = {
			damage = 1
		}
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

		self.g22c.primary_class = "class_precision"
		self.g22c.subclasses = {}
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
		self.g22c.AMMO_MAX = 90
		self.g22c.AMMO_PICKUP = {
			2,
			5
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
			zoom = 3,
			total_ammo_mod = 21,
			damage = 80,
			alert_size = 7,
			spread = 26,
			spread_moving = 26,
			recoil = 13,
			value = 4,
			extra_ammo = 101,
			reload = 11,
			suppression = 13,
			concealment = 30
		}
		self.g22c.stats_modifiers = {
			damage = 1
		}
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

		self.lemming.primary_class = "class_precision"
		self.lemming.subclasses = {}
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
		
		self.lemming.CLIP_AMMO_MAX = 20
		self.lemming.AMMO_MAX = 45
		self.lemming.AMMO_PICKUP = {
			0.5,
			0.75
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
			damage = 110,
			alert_size = 7,
			spread = 26,
			spread_moving = 26,
			recoil = 10,
			value = 4,
			extra_ammo = 101,
			reload = 11,
			suppression = 15,
			concealment = 25
		}
		self.lemming.stats_modifiers = {
			damage = 1
		}
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

		self.deagle.primary_class = "class_precision"
		self.deagle.subclasses = {}
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
		self.deagle.AMMO_MAX = 60
		self.deagle.AMMO_PICKUP = {
			1.5,
			3
		}
		self.deagle.can_shoot_through_enemy = true
		self.deagle.armor_piercing_chance = 1
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
			damage = 110,
			alert_size = 7,
			spread = 26,
			spread_moving = 26,
			recoil = 6,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 15,
			concealment = 25
		}
		self.deagle.stats_modifiers = {
			damage = 1
		}
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

		self.breech.primary_class = "class_precision"
		self.breech.subclasses = {}
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
		self.breech.AMMO_MAX = 60
		self.breech.AMMO_PICKUP = {
			1.5,  
			3
		}
		
		self.breech.can_shoot_through_enemy = true
		self.breech.armor_piercing_chance = 1
		
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
			damage = 110,
			alert_size = 7,
			spread = 26,
			spread_moving = 26,
			recoil = 7,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 15,
			concealment = 25
		}
		self.breech.stats_modifiers = {
			damage = 1
		}
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

		self.sparrow.primary_class = "class_precision"
		self.sparrow.subclasses = {}
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
		self.sparrow.AMMO_MAX = 60
		self.sparrow.AMMO_PICKUP = {
			1.5,
			3
		}
		
		self.sparrow.can_shoot_through_enemy = true
		self.sparrow.armor_piercing_chance = 1
		
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
			damage = 110,
			alert_size = 7,
			spread = 26,
			spread_moving = 26,
			recoil = 7,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 15,
			concealment = 25
		}
		self.sparrow.stats_modifiers = {
			damage = 1
		}
	
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

		self.pl14.primary_class = "class_precision"
		self.pl14.subclasses = {}
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
		self.pl14.AMMO_MAX = 60
		self.pl14.AMMO_PICKUP = {
			1.5,  
			3
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
		
		self.pl14.can_shoot_through_enemy = true
		self.pl14.armor_piercing_chance = 1
		
		self.pl14.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 110,
			alert_size = 7,
			spread = 26,
			spread_moving = 26,
			recoil = 8,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 15,
			concealment = 25
		}
		self.pl14.stats_modifiers = {
			damage = 1
		}
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
			
		self.mateba.primary_class = "class_precision"
		self.mateba.subclasses = {}
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
		self.mateba.AMMO_MAX = 60
		self.mateba.AMMO_PICKUP = {
			1,
			2
		}
		
		self.mateba.can_shoot_through_enemy = true
		self.mateba.can_shoot_through_shield = true
		self.mateba.can_shoot_through_wall = true
		self.mateba.armor_piercing_chance = 1
		
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
			damage = 160,
			alert_size = 7,
			spread = 26,
			spread_moving = 26,
			recoil = 4,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 7,
			concealment = 25
		}
		self.mateba.stats_modifiers = {
			damage = 1
		}

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

		self.new_raging_bull.primary_class = "class_precision"
		self.new_raging_bull.subclasses = {}
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
		
		self.new_raging_bull.can_shoot_through_enemy = true
		self.new_raging_bull.can_shoot_through_shield = true
		self.new_raging_bull.can_shoot_through_wall = true
		self.new_raging_bull.armor_piercing_chance = 1
		
		self.new_raging_bull.CLIP_AMMO_MAX = 6
		self.new_raging_bull.AMMO_MAX = 60
		self.new_raging_bull.AMMO_PICKUP = {
			1,  
			2
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
			damage = 160,
			alert_size = 7,
			spread = 26,
			spread_moving = 26,
			recoil = 7,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 7,
			concealment = 25
		}	
		self.new_raging_bull.stats_modifiers = {
			damage = 1
		}

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

		self.chinchilla.primary_class = "class_precision"
		self.chinchilla.subclasses = {}
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
		self.chinchilla.AMMO_MAX = 60
		self.chinchilla.AMMO_PICKUP = {
			1,  
			2
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
		
		self.chinchilla.can_shoot_through_enemy = true
		self.chinchilla.can_shoot_through_shield = true
		self.chinchilla.can_shoot_through_wall = true
		self.chinchilla.armor_piercing_chance = 1
		
		self.chinchilla.stats = {
			zoom = 3,
			total_ammo_mod = 21,
			damage = 160,
			alert_size = 7,
			spread = 26,
			spread_moving = 26,
			recoil = 4,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 7,
			concealment = 25
		}
		self.chinchilla.stats_modifiers = {
			damage = 1
		}

	--------------------------------------
				--Peacemaker .45--
	--------------------------------------
	--ID: self.peacemaker
	--Class: Heavy --NOTE not error, no akimbo peacemaker
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

		self.peacemaker.primary_class = "class_heavy"
		self.peacemaker.subclasses = {}
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
		self.peacemaker.AMMO_MAX = 30
		self.peacemaker.AMMO_PICKUP = {
			1,
			2
		}
		
		self.peacemaker.can_shoot_through_enemy = true
		self.peacemaker.can_shoot_through_shield = true
		self.peacemaker.can_shoot_through_wall = true
		self.peacemaker.armor_piercing_chance = 1
		
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
			spread = 26,
			spread_moving = 26,
			recoil = 0,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 0,
			concealment = 15
		}
		self.peacemaker.stats_modifiers = {
			damage = 2
		}
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
		self.stech.CLIP_AMMO_MAX = 20
		self.stech.fire_mode_data = {
			fire_rate = 0.08
		}
		self.stech.stats = {
			concealment = 32,
			suppression = 4,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 21,
			recoil = 12,
			value = 1,
			alert_size = 7,
			damage = 60,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.stech.AMMO_MAX = 160
		self.stech.primary_class = "class_rapidfire"
		self.stech.AMMO_PICKUP = {
			7,
			11
		}
		self.stech.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.stech.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
-- todo mod
-- Extended Mag.
-- +14 Magazine
-- -2 Concealment



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

		self.glock_18c.primary_class = "class_rapidfire"
		self.glock_18c.subclasses = {}
		self.glock_18c.FIRE_MODE = "auto"
		self.glock_18c.fire_mode_data = {
			fire_rate = 0.066006600660066
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
			9,
			18
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
			concealment = 32,
			suppression = 4,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 18,
			recoil = 23,
			value = 1,
			alert_size = 7,
			damage = 40,
			total_ammo_mod = 21,
			zoom = 1
		}


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
		self.czech.CLIP_AMMO_MAX = 15
		self.czech.fire_mode_data = {
			fire_rate = 0.06
		}
		self.czech.stats = {
			concealment = 32,
			suppression = 4,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 21,
			recoil = 21,
			value = 1,
			alert_size = 7,
			damage = 40,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.czech.AMMO_MAX = 300
		self.czech.primary_class = "class_rapidfire"
		self.czech.AMMO_PICKUP = {
			9,
			18
		}
		self.czech.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.czech.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
-- todo mod
-- Extended Magazine
-- +10 Magazine
-- -2 Concealment



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
		self.beer.CLIP_AMMO_MAX = 15
		self.beer.fire_mode_data = {
			fire_rate = 0.05449591280654
		}
		self.beer.stats = {
			concealment = 32,
			suppression = 4,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 22,
			recoil = 21,
			value = 1,
			alert_size = 7,
			damage = 40,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.beer.AMMO_MAX = 300
		self.beer.primary_class = "class_rapidfire"
		self.beer.AMMO_PICKUP = {
			9,
			18
		}
		self.beer.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.beer.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}

-- todo mod
-- Extended Magazine
-- +6 Magazine
-- -2 Concealment



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

		self.coal.primary_class = "class_rapidfire"
		self.coal.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 14,
			concealment = 24
		}
		self.coal.stats_modifiers = {
			damage = 1
		}
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

		self.uzi.primary_class = "class_rapidfire"
		self.uzi.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 12,
			concealment = 24
		}
		self.uzi.stats_modifiers = {
			damage = 1
		}
		
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

		self.shepheard.primary_class = "class_rapidfire"
		self.shepheard.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 14,
			concealment = 24
		}
		self.shepheard.stats_modifiers = {
			damage = 1
		}
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

		self.new_mp5.primary_class = "class_rapidfire"
		self.new_mp5.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 17,
			concealment = 24
		}
		self.new_mp5.stats_modifiers = {
			damage = 1
		}

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

		self.tec9.primary_class = "class_rapidfire"
		self.tec9.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 12,
			concealment = 27
		}
		self.tec9.stats_modifiers = {
			damage = 1
		}

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

		self.mp9.primary_class = "class_rapidfire"
		self.mp9.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 16,
			concealment = 26
		}
		self.mp9.stats_modifiers = {
			damage = 1
		}

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

		self.scorpion.primary_class = "class_rapidfire"
		self.scorpion.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 17,
			concealment = 28
		}
		self.scorpion.stats_modifiers = {
			damage = 1
		}
			
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

		self.baka.primary_class = "class_rapidfire"
		self.baka.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 14,
			concealment = 29
		}
		self.baka.stats_modifiers = {
			damage = 1
		}

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

		self.olympic.primary_class = "class_rapidfire"
		self.olympic.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 10,
			concealment = 24
		}
		self.olympic.stats_modifiers = {
			damage = 1
		}
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

		self.m1928.primary_class = "class_rapidfire"
		self.m1928.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 12,
			concealment = 18
		}
		self.m1928.stats_modifiers = {
			damage = 1
		}
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

		self.sr2.primary_class = "class_rapidfire"
		self.sr2.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 14,
			concealment = 28
		}
		self.sr2.stats_modifiers = {
			damage = 1
		}
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

		self.p90.primary_class = "class_rapidfire"
		self.p90.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 12,
			concealment = 25
		}
		self.p90.stats_modifiers = {
			damage = 1
		}
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

		self.mp7.primary_class = "class_rapidfire"
		self.mp7.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 16,
			concealment = 23
		}
		self.mp7.stats_modifiers = {
			damage = 1
		}
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

		self.mac10.primary_class = "class_rapidfire"
		self.mac10.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 14,
			concealment = 27
		}
		self.mac10.stats_modifiers = {
			damage = 1
		}
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

		self.polymer.primary_class = "class_rapidfire"
		self.polymer.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 14,
			concealment = 20
		}
		self.polymer.stats_modifiers = {
			damage = 1
		}
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

		self.cobray.primary_class = "class_rapidfire"
		self.cobray.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 14,
			concealment = 25
		}
		self.cobray.stats_modifiers = {
			damage = 1
		}
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

		self.sterling.primary_class = "class_rapidfire"
		self.sterling.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 12,
			concealment = 20
		}
		self.sterling.stats_modifiers = {
			damage = 1
		}
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

		self.erma.primary_class = "class_rapidfire"
		self.erma.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 14,
			concealment = 24
		}
		self.erma.stats_modifiers = {
			damage = 1
		}
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
	
		self.m45.primary_class = "class_rapidfire"
		self.m45.subclasses = {}
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
		
		self.m45.CLIP_AMMO_MAX = 36
		self.m45.NR_CLIPS_MAX = 2
		self.m45.AMMO_MAX = self.m45.CLIP_AMMO_MAX * self.m45.NR_CLIPS_MAX
		self.m45.AMMO_PICKUP = {
			4,
			6
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
			concealment = 20,
			suppression = 0,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 26,
			recoil = 21,
			value = 1,
			alert_size = 7,
			damage = 100,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.m45.stats_modifiers = {
			damage = 1
		}
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

		self.schakal.primary_class = "class_rapidfire"
		self.schakal.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 14,
			concealment = 24
		}
		self.schakal.stats_modifiers = {
			damage = 1
		}
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

		self.hajk.primary_class = "class_rapidfire"
		self.hajk.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 14,
			concealment = 18
		}
		self.hajk.stats_modifiers = {
			damage = 1
		}
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

		self.akmsu.primary_class = "class_rapidfire"
		self.akmsu.subclasses = {}
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
			extra_ammo = 101,
			reload = 11,
			suppression = 8,
			concealment = 21
		}
		self.akmsu.stats_modifiers = {
			damage = 1
		}
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

		self.coach.primary_class = "class_shotgun"
		self.coach.subclasses = {}
		self.coach.FIRE_MODE = "single"
		self.coach.fire_mode_data = {
			fire_rate = 0.35294117647 
		}
		self.coach.single = {
			fire_rate = 0.35294117647 
		}
		self.coach.timers = {
			reload_not_empty = 2.2
		}
		self.coach.timers.reload_empty = self.coach.timers.reload_not_empty
		self.coach.timers.unequip = 0.6
		self.coach.timers.equip = 0.4
		
		self.coach.CLIP_AMMO_MAX = 2
		self.coach.AMMO_MAX = 22
		self.coach.AMMO_PICKUP = {
			1,
			2
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
			damage = 170,
			alert_size = 7,
			spread = 11,
			spread_moving = 11,
			recoil = 4,
			value = 4,
			extra_ammo = 101,
			reload = 11,
			suppression = 3,
			concealment = 30
		}
		self.coach.stats_modifiers = {
			damage = 1
		}
		self.coach.damage_near = 2000
		self.coach.damage_far = 3000
		self.coach.rays = 12
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

		self.m37.primary_class = "class_shotgun"
		self.m37.subclasses = {}
		self.m37.FIRE_MODE = "single"
		self.m37.fire_mode_data = {
			fire_rate = 0.57692307692 
		}
		self.m37.single = {
			fire_rate = 0.57692307692 
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
		self.m37.AMMO_MAX = 46
		self.m37.AMMO_PICKUP = {
			2,
			3
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
			damage = 130,
			alert_size = 7,
			spread = 11,
			spread_moving = 11,
			recoil = 14,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 3,
			concealment = 25
		}
		self.m37.stats_modifiers = {
			damage = 1
		}
		self.m37.damage_near = 2000
		self.m37.damage_far = 3000
		self.m37.rays = 12
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

		self.serbu.primary_class = "class_shotgun"
		self.serbu.subclasses = {}
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
		
		self.serbu.CLIP_AMMO_MAX = 8
		self.serbu.AMMO_MAX = 42
		self.serbu.AMMO_PICKUP = {
			2,
			3
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
			damage = 130,
			alert_size = 7,
			spread = 11,
			spread_moving = 11,
			recoil = 10,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 3,
			concealment = 30
		}
		self.serbu.stats_modifiers = {
			damage = 1
		}
		self.serbu.damage_near = 2000
		self.serbu.damage_far = 3000
		self.serbu.rays = 12

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

		self.rota.primary_class = "class_shotgun"
		self.rota.subclasses = {}
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
			4,
			5
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
			damage = 80,
			alert_size = 7,
			spread = 11,
			spread_moving = 11,
			recoil = 14,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 3,
			concealment = 20
		}
		self.rota.stats_modifiers = {
			damage = 1
		}
		self.rota.damage_near = 2000
		self.rota.damage_far = 3000
		self.rota.rays = 12
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

		self.judge.primary_class = "class_shotgun"
		self.judge.subclasses = {}
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
			0.5,
			1
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
			damage = 180,
			alert_size = 7,
			spread = 12,
			spread_moving = 12,
			recoil = 5,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 12,
			concealment = 30
		}
		self.judge.stats_modifiers = {
			damage = 1
		}
		self.judge.damage_near = 2000
		self.judge.damage_far = 3000
		self.judge.rays = 12
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

		self.basset.primary_class = "class_shotgun"
		self.basset.subclasses = {}
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
		
		self.basset.CLIP_AMMO_MAX = 7
		self.basset.AMMO_MAX = 96
		self.basset.AMMO_PICKUP = {
			5,
			6
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
			damage = 30,
			alert_size = 7,
			spread = 11,
			spread_moving = 11,
			recoil = 16,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 12,
			concealment = 30
		}
		self.basset.stats_modifiers = {
			damage = 1
		}
		self.basset.damage_near = 2000
		self.basset.damage_far = 3000
		self.basset.rays = 12
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

		self.striker.primary_class = "class_shotgun"
		self.striker.subclasses = {}
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
			4,
			5
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
			damage = 60,
			alert_size = 7,
			spread = 11,
			spread_moving = 11,
			recoil = 16,
			value = 1,
			extra_ammo = 101,
			reload = 11,
			suppression = 0,
			concealment = 20
		}
		self.striker.stats_modifiers = {
			damage = 1
		}
		self.striker.damage_near = 2000
		self.striker.damage_far = 3000
		self.striker.rays = 12
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
		self.hunter.CLIP_AMMO_MAX = 1
		self.hunter.fire_mode_data = {
			fire_rate = 1.2
		}
		self.hunter.stats_modifiers = {
			damage = 1.75
		}
		self.hunter.stats = {
			concealment = 30,
			suppression = 0,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 26,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 200,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.hunter.armor_piercing_chance = 1
		self.hunter.AMMO_PICKUP = {
			0,
			0
		}
		self.hunter.primary_class = "class_precision"
		self.hunter.AMMO_MAX = 30
		self.hunter.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.hunter.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
-- todo mod
-- Explosive Bolt
-- - Armor Piercing
-- 2x Headshot Damage
-- 
-- Poison Bolt
-- -250 Damage
-- +Poison


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
		self.system.CLIP_AMMO_MAX = 600
		self.system.fire_mode_data = {
			fire_rate = 0.03
		}
		self.system.armor_piercing_chance = 1
		self.system.can_shoot_through_shield = true
		self.system.stats = {
			concealment = 20,
			suppression = 22,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 1,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 100,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.system.can_shoot_through_enemy = true
		self.system.can_shoot_through_wall = true
		self.system.AMMO_PICKUP = {
			0,
			0
		}
		self.system.primary_class = "class_specialist"
		self.system.subclasses = {"subclass_areadenial"}
		self.system.AMMO_MAX = 600
		self.system.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.system.kick = {
			standing = {
				0,
				0,
				0,
				0
			},
			crouching = {
				0,
				0,
				0,
				0
			},
			steelsight = {
				0,
				0,
				0,
				0
			}
		}


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
		self.slap.stats_modifiers = {
			damage = 5.5
		}
		self.slap.CLIP_AMMO_MAX = 1
		self.slap.fire_mode_data = {
			fire_rate = 2
		}
		self.slap.stats = {
			concealment = 30,
			suppression = 22,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 22,
			recoil = 22,
			value = 1,
			alert_size = 7,
			damage = 200,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.slap.AMMO_MAX = 6
		self.slap.primary_class = "class_specialist"
		self.slap.subclasses = {}
		self.slap.AMMO_PICKUP = {
			0.05,
			0.1
		}
		self.slap.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.slap.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
-- todo mod
-- Incendiary Round
-- -1000 Damage
-- +Area Denial in a large area for 15 seconds.


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
		self.china.stats_modifiers = {
			damage = 5.5
		}
		self.china.CLIP_AMMO_MAX = 3
		self.china.fire_mode_data = {
			fire_rate = 1.2
		}
		self.china.stats = {
			concealment = 20,
			suppression = 22,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 26,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 200,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.china.AMMO_MAX = 6
		self.china.primary_class = "class_specialist"
		self.china.AMMO_PICKUP = {
			0.05,
			0.1
		}
		self.china.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.china.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
-- todo mod
-- Incendiary Round
-- -1000 Damage
-- +Area Denial in a large area for 15 seconds.


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

		self.arbiter.CLIP_AMMO_MAX = 5
		self.arbiter.NR_CLIPS_MAX = 3
		self.arbiter.AMMO_MAX = self.arbiter.CLIP_AMMO_MAX * self.arbiter.NR_CLIPS_MAX
		self.arbiter.fire_mode_data = {
			fire_rate = 0.75
		}
		self.arbiter.stats = {
			concealment = 20,
			suppression = 22,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 26,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 200,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.arbiter.stats_modifiers = {
			damage = 2.6
		}
		self.arbiter.primary_class = "class_specialist"
		self.arbiter.subclasses = {}
		self.arbiter.AMMO_PICKUP = {
			0.05,
			0.1
		}
		self.arbiter.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.arbiter.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}


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
		self.rpg7.stats_modifiers = {
			damage = 62.5
		}
		self.rpg7.CLIP_AMMO_MAX = 1
		self.rpg7.fire_mode_data = {
			fire_rate = 2
		}
		self.rpg7.stats = {
			concealment = 15,
			suppression = 22,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 26,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 200,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.rpg7.AMMO_MAX = 4
		self.rpg7.primary_class = "class_specialist"
		self.rpg7.subclasses = {}
		self.rpg7.AMMO_PICKUP = {
			0,
			0
		}
		self.rpg7.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.rpg7.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}



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
		self.ray.stats_modifiers = {
			damage = 62.5
		}
		self.ray.CLIP_AMMO_MAX = 4
		self.ray.fire_mode_data = {
			fire_rate = 1
		}
		self.ray.stats = {
			concealment = 0,
			suppression = 22,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 26,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 200,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.ray.AMMO_MAX = 4
		self.ray.primary_class = "class_specialist"
		self.ray.subclasses = {}
		self.ray.AMMO_PICKUP = {
			0,
			0
		}
		self.ray.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.ray.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}




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
		self.saw.armor_piercing_chance = 1
		self.saw.fire_mode_data = {
			fire_rate = 0.15
		}
		self.saw.stats = {
			concealment = 20,
			suppression = 22,
			reload = 11,
			extra_ammo = 101,
			spread_moving = 1,
			spread = 26,
			recoil = 26,
			value = 1,
			alert_size = 7,
			damage = 80,
			total_ammo_mod = 21,
			zoom = 1
		}
		self.saw.CLIP_AMMO_MAX = 150
		self.saw.NR_CLIPS_MAX = 2
		self.saw.AMMO_MAX = self.saw.CLIP_AMMO_MAX * self.saw.NR_CLIPS_MAX
		self.saw.primary_class = "class_saw"
		self.saw.AMMO_PICKUP = {
			0,
			0
		}
		self.saw.spread = {
			standing = self.new_m4.spread.standing,
			crouching = self.new_m4.spread.crouching,
			steelsight = self.new_m4.spread.steelsight,
			moving_standing = self.new_m4.spread.moving_standing,
			moving_crouching = self.new_m4.spread.moving_crouching,
			moving_steelsight = self.new_m4.spread.moving_steelsight
		}
		self.saw.kick = {
			standing = {
				3,
				4.8,
				-0.3,
				0.3
			},
			crouching = {
				3,
				4.8,
				-0.3,
				0.3
			},
			steelsight = {
				3,
				4.8,
				-0.3,
				0.3
			}
		}
		
	--saw but again
		self.saw_secondary = deep_clone(self.saw)
		self.saw_secondary.parent_weapon_id = "saw"
		self.saw_secondary.use_data.selection_index = 1
		self.saw_secondary.animations.reload_name_id = "saw"
		self.saw_secondary.use_stance = "saw"
		self.saw_secondary.texture_name = "saw"
		self.saw_secondary.weapon_hold = "saw"
-- todo mod
-- Silent Motor
-- -200 Fire Rate
-- +10 Concealment
-- Reduced noise radius (but not Silenced, aka base game mechanics)

--  Fast Motor
-- -20 Concealment
-- +400 Fire Rate

-- Durable Blade
-- -40 Damage
-- +50 Magazine Size
-- +100 Ammo Stock

-- Sharp Blade
-- +20 Damage
-- -100 Magazine Size
-- -200 Ammo Stock



-- END weapon data.


	--trip mine deployable 
		self.trip_mines.damage = 150
--		self.trip_mines.damage_size = 300 --3m, default
	end
end)
