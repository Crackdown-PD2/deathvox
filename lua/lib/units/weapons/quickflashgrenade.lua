QuickFlashGrenade.States = {
	{
		"_state_launched",
		0.5
	},
	{
		"_state_bounced"
	},
	{
		"_state_detonated",
		3
	},
	{
		"_state_destroy",
		0
	}
}

function QuickFlashGrenade:init(unit)
	self._unit = unit
	self._state = 0
	self._armed = false

	for i, state in ipairs(QuickFlashGrenade.States) do
		if state[2] == nil then
			QuickFlashGrenade.States[i][2] = tweak_data.group_ai.flash_grenade.timer
		end
	end

	if Network:is_client() then
		local shooter_pos = nil
		local smoke_and_flash_grenades = managers.groupai:state():smoke_and_flash_grenades()

		if smoke_and_flash_grenades then
			for id, data in ipairs(smoke_and_flash_grenades) do
				if data and data.flashbang and data.shooter_pos and data.detonate_pos == self._unit:position() then
					shooter_pos = data.shooter_pos
					smoke_and_flash_grenades[id] = nil

					break
				end
			end
		end

		if not shooter_pos then
			shooter_pos = self._unit:position()
		end

		self:activate(shooter_pos, tweak_data.group_ai.flash_grenade_lifetime)
	end
end

function QuickFlashGrenade:activate_immediately(position, duration)
	self:_activate(1, 0, position, duration)
end

function QuickFlashGrenade:_activate(state, timer, position, duration)
	self._state = state
	self._armed = true
	self._timer = timer
	self._shoot_position = position
	self._duration = duration
end

function QuickFlashGrenade:_state_bounced()
	self._unit:damage():run_sequence_simple("activate")

	--[[local bounce_point = Vector3()
	mvector3.lerp(bounce_point, self._shoot_position, self._unit:position(), 0.65)]]

	local bounce_point = self._unit:position()
	local sound_source = SoundDevice:create_source("grenade_bounce_source")

	sound_source:set_position(bounce_point)
	sound_source:post_event("flashbang_bounce", callback(self, self, "sound_playback_complete_clbk"), sound_source, "end_of_event")

	local light = World:create_light("omni|specular")

	light:set_far_range(tweak_data.group_ai.flash_grenade.light_range)
	light:set_color(tweak_data.group_ai.flash_grenade.light_color)
	light:set_position(self._unit:position())
	light:set_specular_multiplier(tweak_data.group_ai.flash_grenade.light_specular)
	light:set_enable(true)
	light:set_multiplier(0)
	light:set_falloff_exponent(0.5)

	self._light = light
	self._light_multiplier = 0
end

function QuickFlashGrenade:_state_detonated()
	local detonate_pos = self._unit:position()

	self:make_flash(detonate_pos, tweak_data.group_ai.flash_grenade.range)
	managers.groupai:state():propagate_alert({
		"explosion",
		detonate_pos,
		10000,
		managers.groupai:state():get_unit_type_filter("civilians_enemies")
	})
	self._unit:damage():run_sequence_simple("detonate")
end

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

	local affected, line_of_sight, travel_dis, linear_dis = self:_chk_dazzle_local_player(detonate_pos, range, ignore_units)

	if affected and line_of_sight then
		managers.environment_controller:set_flashbang(detonate_pos, line_of_sight, travel_dis, linear_dis, tweak_data.character.flashbang_multiplier)
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

function QuickFlashGrenade:on_flashbang_destroyed(prevent_network)
	if self._destroyed then
		return
	end

	if not prevent_network then
		managers.network:session():send_to_peers_synched("sync_flashbang_event", self._unit, QuickFlashGrenade.Events.DestroyedByPlayer)
	end

	self._unit:sound_source():post_event("pfn_beep_end")

	self._destroyed = true
	self._destroyed_t = 1

	self:remove_light()
end
