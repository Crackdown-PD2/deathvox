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
			self.sentry_gun.WEAPON_HEAT_GAIN_RATE = 1 --heat gained per kill
			self.sentry_gun.WEAPON_HEAT_MAX = 75 
			self.sentry_gun.WEAPON_HEAT_DAMAGE_PENALTY = -0.01 -- -1% damage penalty per heat point
			
			self.sentry_gun.WEAPON_HEAT_OVERHEAT_THRESHOLD = 50 --threshold at which the heat value causes the sentry gun to overheat and shut down (not used) 
			
			
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

		self.tcd_specialist_pickup_amounts = {
			kacchainsaw_flamethrower = {1,1},
			flamethrower_mk2 = {1,1},
			slap = {0.05,0.1},
			china = {0.05,0.1},
			ms3gl = {0.05,0.1},
			arbiter = {0.05,0.1},
			system = {0.05,0.1},
			rpg7 = {0.005,0.005},
			ray = {0.005,0.005}
		}
		
		CSVStatReader:read_files("weapon",self)
		
	--saw but again
		self.saw_secondary = deep_clone(self.saw)
		self.saw_secondary.parent_weapon_id = "saw"
		self.saw_secondary.use_data.selection_index = 1
		self.saw_secondary.animations.reload_name_id = "saw"
		self.saw_secondary.use_stance = "saw"
		self.saw_secondary.texture_name = "saw"
		self.saw_secondary.weapon_hold = "saw"
		
	--trip mine deployable (special special boy)
		self.trip_mines.damage = 150
--		self.trip_mines.damage_size = 300 --3m, default

	end
end)
