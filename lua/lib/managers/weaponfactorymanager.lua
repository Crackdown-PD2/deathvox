
--[[ this file wasn't hooked when i got here and the file only contained this function, so i'm gonna comment it for now -offy
function WeaponFactoryManager:_spawn_and_link_unit(u_name, a_obj, third_person, link_to_unit)
	local unit = World:spawn_unit(u_name, Vector3(), Rotation())
	local res = link_to_unit:link(a_obj, unit, unit:orientation_object():name())

	--if managers.occlusion and not third_person then
	--	managers.occlusion:remove_occlusion(unit)
	--end

	return unit
end

--]]

--used in total cd only
function WeaponFactoryManager:get_primary_weapon_class_from_blueprint(weapon_id,blueprint,fallback)
	if fallback == nil then 
		fallback = "NO_WEAPON_CLASS"
	end
	local wpntd = tweak_data.weapon
	local primary_class
	local weapondata = weapon_id and wpntd[weapon_id]
	if weapondata and weapondata.primary_class then
		primary_class = weapondata.primary_class
	end
	if type(blueprint) == "table" then 
		for _,part_id in pairs(blueprint) do 
			local part_data = wpntd.factory.parts[part_id]
			if part_data then 
				if part_data.class_modifier then 
					primary_class = part_data.class_modifier
				end
			end
		end
	end
	return primary_class or fallback
end

function WeaponFactoryManager:get_weapon_subclasses_from_blueprint(weapon_id,blueprint)
	local wpntd = tweak_data.weapon
	local subclasses = {}
	local weapondata = weapon_id and wpntd[weapon_id]
	if weapondata and weapondata.subclasses then
		subclasses = table.deep_map_copy(weapondata.subclasses)
	end
	if type(blueprint) == "table" then 
		for _,part_id in pairs(blueprint) do 
			local part_data = wpntd.factory.parts[part_id]
			if part_data then 
				if part_data.subclass_modifiers then 
					for _,subclass in pairs(part_data.subclass_modifiers) do 
						table.insert(subclasses,subclass)
					end
				end
			end
		end
	end
	return subclasses
end