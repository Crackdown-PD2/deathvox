Hooks:PostHook(DOTTweakData,"_init_dot_entries_fire","cd_dottweakdata_initfire",function(self,entries,tweak_data)
--[[
	tweak_data.fire.dot_entries.proj_fire_com = {
		dot_trigger_chance = 35,
		dot_damage = 25,
		dot_length = 30,
		dot_trigger_max_distance = 3000,
		dot_tick_period = 0.5
	}
	
	
	tweak_data.dot_types.poison = {
		damage_class = "PoisonBulletBase",
		dot_damage = 15, --150 damage
		dot_length = 3,
		hurt_animation_chance = 0
	}
	
--]]

end)