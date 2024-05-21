function QuickFlashGrenade:make_flash(detonate_pos, range, ignore_units)
	local range = range or 1000
	local effect_params = {
		sound_event = "flashbang_explosion",
		effect = "effects/particles/explosions/explosion_flash_grenade",
		camera_shake_max_mul = 4,
		feedback_range = range * 2
	}

	managers.explosion:play_sound_and_effects(detonate_pos, math.UP, range, effect_params)

	ignore_units = ignore_units or {}

	table.insert(ignore_units, self._unit)
	
	
	if not managers.player:has_category_upgrade("player", "infiltrator_flash_immunity") then
		local affected, line_of_sight, travel_dis, linear_dis = self:_chk_dazzle_local_player(detonate_pos, range, ignore_units)

		if affected and line_of_sight then
			managers.environment_controller:set_flashbang(detonate_pos, line_of_sight, travel_dis, linear_dis, tweak_data.character.flashbang_multiplier, nil, true)
		end

		local player_concussion_range = 500
		affected, line_of_sight, travel_dis, linear_dis = self:_chk_dazzle_local_player(detonate_pos, player_concussion_range, ignore_units)

		if affected then
			if line_of_sight then
				managers.environment_controller:set_concussion_grenade(detonate_pos, line_of_sight, travel_dis, linear_dis, tweak_data.character.flashbang_multiplier)
			end

			local sound_eff_mul = math.clamp(1 - (travel_dis or linear_dis) / player_concussion_range, 0.3, 1)

			managers.player:player_unit():character_damage():on_concussion(sound_eff_mul)
		end
	end
end
