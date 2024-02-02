if deathvox:IsTotalCrackdownEnabled() then

	local unit_id = Idstring("units/payday2/environment/environment_fire_1/environment_fire_1")
	function EnvironmentFire.spawn(position, rotation, data, normal, user_unit, weapon_unit, added_time, range_multiplier)
		local unit = World:spawn_unit(unit_id, position, rotation)
		local time_until_destruction = nil

		if unit then
			local user_base_ext = alive(user_unit) and user_unit:base()

			if user_base_ext then
				if user_base_ext.is_local_player then
					local player_manager = managers.player
					local third_degree_dur_mul = player_manager:upgrade_value("subclass_areadenial", "effect_duration_increase_mul", 1)

					if third_degree_dur_mul > 1 then
						local extra_time = data.burn_duration + added_time
						extra_time = extra_time * third_degree_dur_mul - extra_time
						added_time = added_time + extra_time 
					end

					local third_degree_dmg_mul = player_manager:upgrade_value("subclass_areadenial", "effect_doubleroasting_damage_increase_mul", 1)

					if third_degree_dmg_mul > 1 then
						unit:base()._on_fire_dmg_mul = third_degree_dmg_mul
					end
				elseif user_base_ext.is_husk_player then
					local third_degree_dur_mul = user_base_ext:upgrade_value("subclass_areadenial", "effect_duration_increase_mul",1)

					if third_degree_dur_mul > 1 then
						local extra_time = data.burn_duration + added_time
						extra_time = extra_time * third_degree_dur_mul - extra_time
						added_time = added_time + extra_time 
					end

					local third_degree_dmg_mul = user_base_ext:upgrade_value("subclass_areadenial", "effect_doubleroasting_damage_increase_mul",1)

					if third_degree_dmg_mul > 1 then
						unit:base()._on_fire_dmg_mul = third_degree_dmg_mul
					end
				end
			end
			
			local base_ext = unit:base()
			if base_ext then
				if base_ext.on_spawn then
					base_ext:on_spawn(data, normal, user_unit, weapon_unit, added_time, range_multiplier)
				end
			end
			
			time_until_destruction = base_ext.get_duration_until_destruction and base_ext:get_duration_until_destruction()
			--unit:base():on_spawn(data, normal, user_unit, added_time, range_multiplier)
			if time_until_destruction then
				time_until_destruction = time_until_destruction + added_time
			end
		end

		return unit,time_until_destruction
	end
end

Hooks:PostHook(EnvironmentFire, "init", "deathvox_environmentfire_init", function(self, unit)
	EnvironmentFire.super.init(self, unit, true)
end)

Hooks:PreHook(EnvironmentFire, "destroy", "deathvox_environmentfire_destroy", function(self, unit, ...)
	EnvironmentFire.super.destroy(self, unit, ...)
end)