function QuickFlashGrenade:make_flash(detonate_pos, range, ignore_units)
	local range = 2500
	local effect_params = {
		sound_event = "flashbang_explosion",
		effect = "effects/particles/explosions/explosion_flash_grenade",
		camera_shake_max_mul = 4,
		feedback_range = range * 2
	}

	managers.explosion:play_sound_and_effects(detonate_pos, math.UP, range, effect_params)

	ignore_units = ignore_units or {}

	table.insert(ignore_units, self._unit)

	local affected, line_of_sight, travel_dis, linear_dis = self:_chk_dazzle_local_player(detonate_pos, range, ignore_units)

	if affected then
		managers.environment_controller:set_concussion_grenade(detonate_pos, line_of_sight, travel_dis, linear_dis, tweak_data.character.flashbang_multiplier)

		local sound_eff_mul = math.clamp(1 - (travel_dis or linear_dis) / range, 0.3, 1)

		managers.player:player_unit():character_damage():on_concussion(sound_eff_mul)
	end
end

function QuickFlashGrenade:_state_bounced()
	self._unit:damage():run_sequence_simple("activate")

	local bounce_point = Vector3()

	mvector3.lerp(bounce_point, self._shoot_position, self._unit:position(), 0.65)

	local sound_source = SoundDevice:create_source("grenade_bounce_source")

	sound_source:set_position(bounce_point)
	sound_source:post_event("flashbang_bounce", callback(self, self, "sound_playback_complete_clbk"), sound_source, "end_of_event")

	local light = World:create_light("omni|specular")

	light:set_far_range(tweak_data.group_ai.flash_grenade.light_range)
	light:set_color(Vector3(0, 255, 0))
	light:set_position(self._unit:position())
	light:set_specular_multiplier(tweak_data.group_ai.flash_grenade.light_specular)
	light:set_enable(true)
	light:set_multiplier(0)
	light:set_falloff_exponent(0.5)

	self._light = light
	self._light_multiplier = 0
end