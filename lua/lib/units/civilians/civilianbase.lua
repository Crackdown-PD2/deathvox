local post_init_original = CivilianBase.post_init
function CivilianBase:post_init()
	self._allow_invisible = true

	post_init_original(self)
end

--todo use register/unregister style list instead of checking World for units
--currently only used in tcd but it can be used anywhere -offy
function CivilianBase.get_nearby_civ(pos,radius,require_tied)
	for _,unit in pairs(World:find_units_quick("sphere",pos,radius,21,22)) do --managers.slot:get_mask("civilians")
		if not require_tied or unit:brain() and unit:brain().is_tied and unit:brain():is_tied() then 
			return unit
		end
	end
	return nil
end
