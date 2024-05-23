Hooks:PostHook(FireTweakData,"_init_tweak_data","cd_firetweakdata_init",function(self)
	self.hellfire_bones = {
		"Head"
	}
end)

if deathvox:IsTotalCrackdownEnabled() then
	Hooks:OverrideFunction(FireTweakData,"_init_dot_entries_fire",function(self,entries)
		local fire_entries = {}
		entries.fire = fire_entries
		fire_entries.default_fire = {
			PROCESSED = true,
			name = "default",
			dot_length = 6,
			dot_trigger_chance = 1,
			dot_trigger_max_distance = 3000,
			dot_grace_period = 1,
			variant = "fire",
			dot_damage = 0,
			damage_class = "FlameBulletBase",
			dot_tick_period = 0.5
		}
		fire_entries.weapon_kacchainsaw_flamethrower = {
			dot_trigger_chance = 1,
			dot_damage = 0,
			dot_length = 6,
			dot_trigger_max_distance = false
		}
		fire_entries.weapon_flamethrower_mk2 = {
			dot_trigger_chance = 1,
			dot_damage = 0,
			dot_length = 6,
			dot_trigger_max_distance = false
		}
		fire_entries.weapon_money = {
			dot_trigger_max_distance = false,
			dot_damage = 0,
			dot_length = 6,
			burn_sound_name = "no_sound",
			dot_trigger_chance = 1,
			fire_effect_variant = "endless_money"
		}
		fire_entries.weapon_system = {
			dot_trigger_chance = 1,
			dot_damage = 0,
			dot_length = 6,
			dot_trigger_max_distance = false
		}
		fire_entries.ammo_dragons_breath = {
			dot_trigger_chance = 1,
			dot_damage = 0,
			dot_length = 6,
			dot_trigger_max_distance = 1400
		}
		fire_entries.ammo_flamethrower_mk2_rare = {
			dot_trigger_chance = 1,
			dot_damage = 0,
			dot_length = 6,
			dot_trigger_max_distance = false
		}
		fire_entries.ammo_flamethrower_mk2_welldone = {
			dot_trigger_chance = 1,
			dot_damage = 0,
			dot_length = 6,
			dot_trigger_max_distance = false
		}
		fire_entries.ammo_system_low = {
			dot_trigger_chance = 1,
			dot_damage = 0,
			dot_length = 6,
			dot_trigger_max_distance = false
		}
		fire_entries.ammo_system_high = {
			dot_trigger_chance = 1,
			dot_damage = 0,
			dot_length = 6,
			dot_trigger_max_distance = false
		}
		fire_entries.melee_spoon_gold = {
			dot_trigger_chance = 1,
			dot_damage = 0,
			dot_length = 6,
			dot_trigger_max_distance = false
		}
		fire_entries.proj_molotov = {
			dot_trigger_chance = 1,
			dot_damage = 0,
			dot_length = 6,
			dot_trigger_max_distance = false,
			is_molotov = true
		}
		fire_entries.proj_launcher_incendiary = {
			dot_trigger_max_distance = false,
			dot_damage = 0,
			dot_trigger_chance = 1
		}
		fire_entries.proj_launcher_incendiary_arbiter = {
			dot_trigger_max_distance = false,
			dot_damage = 0,
			dot_length = 6,
			dot_trigger_chance = 1
		}
		fire_entries.proj_fire_com = {
			dot_trigger_chance = 1,
			dot_damage = 0,
			dot_length = 6,
			dot_trigger_max_distance = false
		}
		fire_entries.proj_molotov_groundfire = {
			is_molotov = true,
			dot_trigger_max_distance = false
		}
		fire_entries.proj_launcher_incendiary_groundfire = {
			dot_trigger_max_distance = false
		}
		fire_entries.proj_launcher_incendiary_arbiter_groundfire = clone(fire_entries.proj_launcher_incendiary_groundfire)
		fire_entries.equipment_tripmine_groundfire = clone(fire_entries.proj_launcher_incendiary_groundfire)
		fire_entries.enemy_triad_boss_groundfire = clone(fire_entries.proj_launcher_incendiary_groundfire)
		fire_entries.enemy_mutator_cloaker_groundfire = {
			dot_trigger_max_distance = false
		}
	end)
end