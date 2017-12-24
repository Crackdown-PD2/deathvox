function TearGasGrenade:detonate()
	local now = TimerManager:game():time()
	self._remove_t = now + self.duration
	self._damage_t = now + 1
	local position = self._unit:position()
	local sound_source = SoundDevice:create_source("tear_gas_source")

	sound_source:set_position(position)
	sound_source:post_event("grenade_gas_explode")
	World:effect_manager():spawn({
		effect = Idstring("effects/particles/explosions/explosion_smoke_grenade"),
		position = position,
		normal = self._unit:rotation():y()
	})

	local parent = self._unit:orientation_object()
	self._smoke_effect = World:effect_manager():spawn({
		effect = Idstring("effects/particles/explosions/cs_grenade_smoke"),
		parent = parent
	})
	local blurzone_radius = self.radius * 1.5

	managers.environment_controller:set_blurzone(self._unit:key(), 1, self._unit:position(), blurzone_radius, 0, true)
	managers.network:session():send_to_peers_synched("sync_tear_gas_grenade_detonate", self._unit)

end

function TearGasGrenade:destroy()
	if self._smoke_effect then
		World:effect_manager():fade_kill(self._smoke_effect)
	end
	managers.environment_controller:set_blurzone(self._unit:key(), 0)
end