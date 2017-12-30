function UnitNetworkHandler:sync_vox_grenade(detonate_pos, shooter_pos, duration, damage, d_rad)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	managers.groupai:state():sync_vox_grenade(detonate_pos, shooter_pos, duration, damage, d_rad)
end

function UnitNetworkHandler:sync_vox_grenade_properties(grenade, radius, damage, duration, location)
	if grenade then
		grenade:base():set_properties({
			radius = radius,
			damage = damage,
			duration = duration
		})
	else
		grenade = World:spawn_unit(Idstring("units/weapons/cs_grenade_quick/cs_grenade_quick"), location, Rotation())
		grenade:base():set_properties({
			radius = radius,
			damage = damage,
			duration = duration
		})
	end
end

function UnitNetworkHandler:sync_vox_grenade_detonate(grenade, radius, damage, duration, location)
	if grenade then
		grenade:base():detonate()
	else
		grenade = World:spawn_unit(Idstring("units/weapons/cs_grenade_quick/cs_grenade_quick"), location, Rotation())
		grenade:base():set_properties({
			radius = radius,
			damage = damage,
			duration = duration
		})
		grenade:base():detonate()
	end
end
