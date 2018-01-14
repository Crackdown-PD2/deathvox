local old_init = WeaponTweakData.init
function WeaponTweakData:init(tweak_data)
	old_init(self, tweak_data)

	self.deathvox_guard_pistol = deep_clone(self.packrat_crew)
	self.deathvox_medic_pistol = deep_clone(self.mateba_crew)
	self.deathvox_light_ar = deep_clone(self.aug_crew)
	self.deathvox_heavy_ar = deep_clone(self.fal_crew)
	self.deathvox_shotgun_light = deep_clone(self.r870_crew)
	self.deathvox_shotgun_heavy = deep_clone(self.ben_crew)
	self.deathvox_sniper = deep_clone(self.wa2000_crew)
	self.deathvox_medicdozer_smg = deep_clone(self.polymer_crew)
	self.deathvox_grenadier = deep_clone(self.contraband_crew)
	
	self.deathvox_lmgdozer = deep_clone(self.m249_crew)
	self.deathvox_cloaker = deep_clone(self.schakal_crew)
	self.deathvox_blackdozer = deep_clone(self.saiga_crew)
	self.deathvox_greendozer = deep_clone(self.r870_crew)

	self.deathvox_light_ar.sounds.prefix = "aug_npc" -- dont worry about this
	self.deathvox_light_ar.use_data.selection_index = 2 -- dont worry about this
	self.deathvox_light_ar.DAMAGE = 7.5 -- Base damage 75.
	self.deathvox_light_ar.muzzleflash = "effects/payday2/particles/weapons/556_auto" -- dont worry about this
	self.deathvox_light_ar.shell_ejection = "effects/payday2/particles/weapons/shells/shell_556" -- dont worry about this
	self.deathvox_light_ar.CLIP_AMMO_MAX = 30 -- How many shots before they gotta reload
	self.deathvox_light_ar.NR_CLIPS_MAX = 5 -- dont worry about this
	self.deathvox_light_ar.pull_magazine_during_reload = "rifle" -- dont worry about this
	self.deathvox_light_ar.auto.fire_rate = 0.08 -- Firing delay in seconds(?)
	self.deathvox_light_ar.hold = { -- dont worry about this
		"bullpup",
		"rifle"
	}
	self.deathvox_light_ar.alert_size = 5000 -- how far away in AlmirUnits(tm) it alerts people
	self.deathvox_light_ar.suppression = 1 -- dont worry about this
	self.deathvox_light_ar.usage = "is_light_rifle"
	self.deathvox_light_ar.anim_usage = "is_bullpup"

	self.deathvox_heavy_ar.sounds.prefix = "fn_fal_npc"
	self.deathvox_heavy_ar.use_data.selection_index = 2
	self.deathvox_heavy_ar.DAMAGE = 10 -- base damage 100.
	self.deathvox_heavy_ar.muzzleflash = "effects/payday2/particles/weapons/762_auto"
	self.deathvox_heavy_ar.shell_ejection = "effects/payday2/particles/weapons/shells/shell_556"
	self.deathvox_heavy_ar.CLIP_AMMO_MAX = 20
	self.deathvox_heavy_ar.NR_CLIPS_MAX = 5
	self.deathvox_heavy_ar.pull_magazine_during_reload = "rifle"
	self.deathvox_heavy_ar.auto.fire_rate = 0.08
	self.deathvox_heavy_ar.hold = "rifle"
	self.deathvox_heavy_ar.alert_size = 5000
	self.deathvox_heavy_ar.suppression = 1
	self.deathvox_heavy_ar.usage = "is_heavy_rifle"
	self.deathvox_heavy_ar.anim_usage = "is_rifle"

	self.deathvox_guard_pistol.sounds.prefix = "packrat_npc"
	self.deathvox_guard_pistol.use_data.selection_index = 1
	self.deathvox_guard_pistol.DAMAGE = 6 -- base damage 60
	self.deathvox_guard_pistol.muzzleflash = "effects/payday2/particles/weapons/9mm_auto"
	self.deathvox_guard_pistol.muzzleflash_silenced = "effects/payday2/particles/weapons/9mm_auto_silence"
	self.deathvox_guard_pistol.shell_ejection = "effects/payday2/particles/weapons/shells/shell_9mm"
	self.deathvox_guard_pistol.CLIP_AMMO_MAX = 15
	self.deathvox_guard_pistol.NR_CLIPS_MAX = 5
	self.deathvox_guard_pistol.pull_magazine_during_reload = "pistol"
	self.deathvox_guard_pistol.hold = "pistol"
	self.deathvox_guard_pistol.alert_size = 2500
	self.deathvox_guard_pistol.suppression = 1
	self.deathvox_guard_pistol.usage = "is_pistol"
	self.deathvox_guard_pistol.anim_usage = "is_pistol"
	
	self.deathvox_medic_pistol.sounds.prefix = "mateba_npc"
	self.deathvox_medic_pistol.use_data.selection_index = 1
	self.deathvox_medic_pistol.DAMAGE = 8 -- base 80 damage.
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

	self.deathvox_shotgun_light.sounds.prefix = "remington_npc"
	self.deathvox_shotgun_light.use_data.selection_index = 2
	self.deathvox_shotgun_light.DAMAGE = 9 -- Base damage 90.
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

	self.deathvox_shotgun_heavy.sounds.prefix = "benelli_m4_npc"
	self.deathvox_shotgun_heavy.use_data.selection_index = 2
	self.deathvox_shotgun_heavy.DAMAGE = 13 -- Base damage 130.
	self.deathvox_shotgun_heavy.muzzleflash = "effects/payday2/particles/weapons/762_auto"
	self.deathvox_shotgun_heavy.shell_ejection = "effects/payday2/particles/weapons/shells/shell_slug"
	self.deathvox_shotgun_heavy.auto.fire_rate = 0.14
	self.deathvox_shotgun_heavy.CLIP_AMMO_MAX = 8
	self.deathvox_shotgun_heavy.NR_CLIPS_MAX = 4
	self.deathvox_shotgun_heavy.hold = "rifle"
	self.deathvox_shotgun_heavy.reload = "looped"
	self.deathvox_shotgun_heavy.looped_reload_speed = 0.8 -- time it takes to shove each shell in
	self.deathvox_shotgun_heavy.alert_size = 4500
	self.deathvox_shotgun_heavy.suppression = 1.8
	self.deathvox_shotgun_heavy.is_shotgun = true
	self.deathvox_shotgun_heavy.usage = "is_heavy_shotgun"
	self.deathvox_shotgun_heavy.anim_usage = "is_shotgun_mag"

	self.deathvox_sniper.sounds.prefix = "lakner_npc"
	self.deathvox_sniper.use_data.selection_index = 2
	self.deathvox_sniper.DAMAGE = 24 -- base 240, drop with distance. Same as DW and OD.
	self.deathvox_sniper.muzzleflash = "effects/payday2/particles/weapons/9mm_auto"
	self.deathvox_sniper.muzzleflash_silenced = "effects/payday2/particles/weapons/9mm_auto_silence"
	self.deathvox_sniper.shell_ejection = "effects/payday2/particles/weapons/shells/shell_9mm"
	self.deathvox_sniper.CLIP_AMMO_MAX = 10
	self.deathvox_sniper.NR_CLIPS_MAX = 5
	self.deathvox_sniper.pull_magazine_during_reload = "rifle"
	self.deathvox_sniper.auto.fire_rate = 0.5
	self.deathvox_sniper.hold = {
		"bullpup",
		"rifle"
	}
	self.deathvox_sniper.alert_size = 5000
	self.deathvox_sniper.suppression = 1	
	self.deathvox_sniper.armor_piercing = true
	self.deathvox_sniper.usage = "is_assault_sniper"
	self.deathvox_sniper.anim_usage = "is_bullpup"
	self.deathvox_sniper.disable_sniper_laser = true
	
	self.deathvox_medicdozer_smg.sounds.prefix = "polymer_npc"
	self.deathvox_medicdozer_smg.use_data.selection_index = 1
	self.deathvox_medicdozer_smg.DAMAGE = 4.5 -- Vanilla base is 20, adjusting up to 45. Matched to other smgs.
	self.deathvox_medicdozer_smg.muzzleflash = "effects/payday2/particles/weapons/9mm_auto"
	self.deathvox_medicdozer_smg.muzzleflash_silenced = "effects/payday2/particles/weapons/9mm_auto_silence"
	self.deathvox_medicdozer_smg.shell_ejection = "effects/payday2/particles/weapons/shells/shell_9mm"
	self.deathvox_medicdozer_smg.CLIP_AMMO_MAX = 30
	self.deathvox_medicdozer_smg.NR_CLIPS_MAX = 5
	self.deathvox_medicdozer_smg.reload = "rifle"
	self.deathvox_medicdozer_smg.pull_magazine_during_reload = "smg"
	self.deathvox_medicdozer_smg.auto.fire_rate = 0.05
	self.deathvox_medicdozer_smg.hold = {
		"bullpup",
		"rifle"
	}
	self.deathvox_medicdozer_smg.alert_size = 5000
	self.deathvox_medicdozer_smg.suppression = 1	
	self.deathvox_medicdozer_smg.usage = "is_tank_smg"
	
	self.deathvox_grenadier.sounds.prefix = "contraband_npc"
	self.deathvox_grenadier.use_data.selection_index = 2
	self.deathvox_grenadier.DAMAGE = 7.5 -- Base damage 75. Matched to light swat.
	self.deathvox_grenadier.muzzleflash = "effects/payday2/particles/weapons/762_auto"
	self.deathvox_grenadier.shell_ejection = "effects/payday2/particles/weapons/shells/shell_556"
	self.deathvox_grenadier.CLIP_AMMO_MAX = 20
	self.deathvox_grenadier.NR_CLIPS_MAX = 5
	self.deathvox_grenadier.pull_magazine_during_reload = "rifle"
	self.deathvox_grenadier.auto.fire_rate = 0.098
	self.deathvox_grenadier.hold = {
		"bullpup",
		"rifle"
	}
	self.deathvox_grenadier.reload = "rifle"
	self.deathvox_grenadier.alert_size = 5000
	self.deathvox_grenadier.suppression = 1
	
    self.deathvox_lmgdozer.sounds.prefix = "m249_npc"
    self.deathvox_lmgdozer.use_data.selection_index = 2
    self.deathvox_lmgdozer.DAMAGE = 10 -- Base damage 100, matched to DW.
    self.deathvox_lmgdozer.muzzleflash = "effects/payday2/particles/weapons/big_762_auto"
    self.deathvox_lmgdozer.shell_ejection = "effects/payday2/particles/weapons/shells/shell_556_lmg"
    self.deathvox_lmgdozer.CLIP_AMMO_MAX = 200
    self.deathvox_lmgdozer.NR_CLIPS_MAX = 2
    self.deathvox_lmgdozer.auto.fire_rate = 0.08
    self.deathvox_lmgdozer.hold = "rifle"
    self.deathvox_lmgdozer.alert_size = 5000
    self.deathvox_lmgdozer.suppression = 1
    self.deathvox_lmgdozer.usage = "is_dozer_lmg"
   
    self.deathvox_cloaker.sounds.prefix = "schakal_npc"
    self.deathvox_cloaker.use_data.selection_index = 1
    self.deathvox_cloaker.DAMAGE = 4.5 -- Base damage 45, matched to other smgs
    self.deathvox_cloaker.muzzleflash = "effects/payday2/particles/weapons/9mm_auto"
    self.deathvox_cloaker.muzzleflash_silenced = "effects/payday2/particles/weapons/9mm_auto_silence"
    self.deathvox_cloaker.shell_ejection = "effects/payday2/particles/weapons/shells/shell_9mm"
    self.deathvox_cloaker.CLIP_AMMO_MAX = 30
    self.deathvox_cloaker.NR_CLIPS_MAX = 5
    self.deathvox_cloaker.pull_magazine_during_reload = "pistol"
    self.deathvox_cloaker.auto.fire_rate = 0.092
    self.deathvox_cloaker.hold = {
        "bullpup",
        "rifle"
    }
    self.deathvox_cloaker.hold = "rifle"
    self.deathvox_cloaker.alert_size = 5000
    self.deathvox_cloaker.suppression = 1
    self.deathvox_cloaker.usage = "is_cloaker_smg"
   
    self.deathvox_blackdozer.sounds.prefix = "saiga_npc"
    self.deathvox_blackdozer.use_data.selection_index = 2
    self.deathvox_blackdozer.DAMAGE = 22.5 --Base damage 225, matched to DW.
    self.deathvox_blackdozer.muzzleflash = "effects/payday2/particles/weapons/762_auto"
    self.deathvox_blackdozer.shell_ejection = "effects/payday2/particles/weapons/shells/shell_slug"
    self.deathvox_blackdozer.auto.fire_rate = 0.14
    self.deathvox_blackdozer.CLIP_AMMO_MAX = 7
    self.deathvox_blackdozer.NR_CLIPS_MAX = 10
    self.deathvox_blackdozer.hold = "rifle"
    self.deathvox_blackdozer.alert_size = 4500
    self.deathvox_blackdozer.suppression = 1.8
    self.deathvox_blackdozer.is_shotgun = true
    self.deathvox_blackdozer.usage = "is_dozer_saiga"
   
    self.deathvox_greendozer.sounds.prefix = "remington_npc"
    self.deathvox_greendozer.use_data.selection_index = 2
    self.deathvox_greendozer.DAMAGE = 45 --Base damage 450, Compare DW 400, OD 560.
    self.deathvox_greendozer.muzzleflash = "effects/payday2/particles/weapons/762_auto"
    self.deathvox_greendozer.shell_ejection = "effects/payday2/particles/weapons/shells/shell_slug_semi"
    self.deathvox_greendozer.CLIP_AMMO_MAX = 6
    self.deathvox_greendozer.NR_CLIPS_MAX = 4
    self.deathvox_greendozer.hold = "rifle"
    self.deathvox_greendozer.alert_size = 4500
    self.deathvox_greendozer.suppression = 1.8
    self.deathvox_greendozer.is_shotgun = true
    self.deathvox_greendozer.usage = "is_dozer_pump"
end

function WeaponTweakData:_set_sm_wish()
	self.ak47_ass_npc.DAMAGE = 3
	self.m4_npc.DAMAGE = 3
	self.g36_npc.DAMAGE = 5
	self.r870_npc.DAMAGE = 7
	self.swat_van_turret_module.HEALTH_INIT = 40000
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 500
	self.swat_van_turret_module.DAMAGE = 3
	self.swat_van_turret_module.CLIP_SIZE = 600
	self.swat_van_turret_module.AUTO_REPAIR_MAX_COUNT = 696969
	self.swat_van_turret_module.EXPLOSION_DMG_MUL = 3
	self.ceiling_turret_module.HEALTH_INIT = 40000
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 350
	self.ceiling_turret_module.DAMAGE = 3.5
	self.ceiling_turret_module.CLIP_SIZE = 800
	self.ceiling_turret_module.EXPLOSION_DMG_MUL = 3
	self.ceiling_turret_module.BAG_DMG_MUL = 50
end
