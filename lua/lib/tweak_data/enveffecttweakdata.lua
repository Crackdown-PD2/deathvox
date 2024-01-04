if deathvox:IsTotalCrackdownEnabled() then

	function EnvEffectTweakData:trip_mine_fire()
		local params = {
			sound_event = "molotov_impact",
			range = 75,
			curve_pow = 3,
			damage = 25,
			fire_alert_radius = 15000,
			alert_radius = 15000,
			sound_event_burning = "burn_loop_gen",
			sound_event_burning_stop = "burn_loop_gen_stop_fade",
			player_damage = 5,
			sound_event_impact_duration = 4,
			burn_tick_period = 0.5,
			burn_duration = 15,
			dot_data_name = "equipment_tripmine_groundfire",
			effect_name = "effects/payday2/particles/explosions/molotov_grenade"
		}

		return params
	end

	function EnvEffectTweakData:incendiary_fire()
		local params = {
			sound_event = "gl_explode",
			range = 75,
			curve_pow = 3,
			damage = 1,
			fire_alert_radius = 1500,
			alert_radius = 1500,
			sound_event_burning = "burn_loop_gen",
			sound_event_burning_stop = "burn_loop_gen_stop_fade",
			player_damage = 2,
			sound_event_impact_duration = 6,
			burn_tick_period = 0.5,
			burn_duration = 10,
			dot_data_name = "proj_launcher_incendiary_groundfire",
			effect_name = "effects/payday2/particles/explosions/molotov_grenade"
		}

		return params
	end

	function EnvEffectTweakData:incendiary_fire_arbiter()
		local params = {
			sound_event = "no_sound",
			range = 75,
			curve_pow = 3,
			damage = 1,
			fire_alert_radius = 1500,
			alert_radius = 1500,
			sound_event_burning = "burn_loop_gen",
			sound_event_burning_stop = "burn_loop_gen_stop_fade",
			player_damage = 2,
			sound_event_impact_duration = 6,
			burn_tick_period = 0.5,
			burn_duration = 3,
			dot_data_name = "proj_launcher_incendiary_arbiter_groundfire",
			effect_name = "effects/payday2/particles/explosions/molotov_grenade"
		}

		return params
	end
	
end