function WeaponFactoryManager:_spawn_and_link_unit(u_name, a_obj, third_person, link_to_unit)
	local unit = World:spawn_unit(u_name, Vector3(), Rotation())
	local res = link_to_unit:link(a_obj, unit, unit:orientation_object():name())

	--if managers.occlusion and not third_person then
	--	managers.occlusion:remove_occlusion(unit)
	--end

	return unit
end
