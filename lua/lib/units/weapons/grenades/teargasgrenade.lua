function TearGasGrenade:detonate()
	-- note: removed _detonated check

	local now = TimerManager:game():time()
	self._remove_t = now + self.duration
	self._damage_t = now + 1

	self._unit:sound_source():post_event("grenade_gas_explode")

	local position = self._unit:position()

	World:effect_manager():spawn({
		effect = Idstring("effects/particles/explosions/explosion_smoke_grenade"),
		position = position,
		normal = self._unit:rotation():y()
	})

	local parent = self._unit:orientation_object()
	self._smoke_effect = World:effect_manager():spawn({
		effect = Idstring("effects/payday2/environment/cs_gas_damage_area"),
		parent = parent
	})
	self._set_blurzone = true
	local blurzone_radius = self.radius * 1.3

	managers.environment_controller:set_blurzone(self._unit:key(), 1, position, blurzone_radius, 0, true)

	if self._unit:id() ~= -1 and Network:is_server() then
		managers.network:session():send_to_peers("sync_tear_gas_grenade_detonate", self._unit)
	end

	self._unit:set_extension_update_enabled(Idstring("base"), true)
end
