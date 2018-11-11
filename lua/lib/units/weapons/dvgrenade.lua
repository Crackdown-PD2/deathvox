DVGrenade = DVGrenade or blt_class(FragGrenade)


function DVGrenade:create_sweep_data()
	self._sweep_data = {slot_mask = self._slot_mask}
	self._sweep_data.slot_mask = managers.mutators:modify_value("ProjectileBase:create_sweep_data:slot_mask", managers.slot:get_mask("players"))
	self._sweep_data.current_pos = self._unit:position()
	self._sweep_data.last_pos = mvector3.copy(self._sweep_data.current_pos)
end

function DVGrenade:add_damage_result(unit, is_dead, damage_percent)
	return
end

function DVGrenade:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	local pos = self._unit:position()
	local normal = math.UP
	local range = self._range

	managers.explosion:play_sound_and_effects(pos, normal, range, self._custom_params)
	managers.groupai:state():detonate_cs_grenade(pos, nil, _G.deathvox.grenadier_gas_duration)
	managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", GrenadeBase.EVENT_IDS.detonate)
	self._unit:set_slot(0)
end

function FragGrenade:_detonate_on_client()
	local pos = self._unit:position()
	local range = self._range
	
	managers.explosion:explode_on_client(pos, math.UP, nil, self._damage, range, self._curve_pow, self._custom_params)
end
