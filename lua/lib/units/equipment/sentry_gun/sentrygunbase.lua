function SentryGunBase:_fire_raycast(user_unit, from_pos, direction, shoot_player, target_unit, shoot_through_data)
	return self._unit:weapon():_fire_raycast(user_unit, from_pos, direction, shoot_player, target_unit, shoot_through_data)
end
