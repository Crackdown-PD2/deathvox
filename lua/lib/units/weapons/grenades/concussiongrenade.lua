function ConcussionGrenade:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	local pos = self._unit:position()
	local normal = math.UP
	local range = self._range
	local slot_mask = managers.slot:get_mask("raycastable_characters")
	slot_mask = slot_mask - 3 - 17 + 21

	managers.explosion:play_sound_and_effects(pos, normal, range, self._custom_params)

	local hit_units, splinters = managers.explosion:detect_and_stun({
		player_damage = 0,
		hit_pos = pos,
		range = range,
		collision_slotmask = slot_mask,
		curve_pow = self._curve_pow,
		damage = self._damage,
		ignore_unit = self._unit,
		alert_radius = self._alert_radius,
		user = self:thrower_unit() or self._unit,
		owner = self._unit,
		verify_callback = callback(self, self, "_can_stun_unit")
	})
	if self._unit:id() ~= 1 then
		managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", GrenadeBase.EVENT_IDS.detonate)
	end
	self:_flash_player()
	self:_handle_hiding_and_destroying(true, nil)
end

function ConcussionGrenade:_detonate_on_client()
	local pos = self._unit:position()
	local range = self._range

	managers.explosion:play_sound_and_effects(pos, math.UP, range, self._custom_params)
	self:_flash_player()
	self:_handle_hiding_and_destroying(true, nil)
end
