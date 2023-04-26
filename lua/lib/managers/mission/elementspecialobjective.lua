local adjust_ids = {
	wwh = { --use comments to keep track of what im modifying here so i dont forget what i did or why
		[100796] = { --superduper broken anim for climbing up near the alaskan deal sheds
			new_pos = Vector3(5552.89, 2805.31, 1153),
			new_search_pos = Vector3(5992, 2749, 1568),
			new_rotation = Rotation(-137, 0, -0),
			new_action = "e_nl_up_4m"
		}
	}
}

Hooks:PostHook(ElementSpecialObjective, "_finalize_values", "CD_modify_navlinks", function(self)
	if adjust_ids[Global.level_data.level_id] then
		local to_adjust = adjust_ids[Global.level_data.level_id]
		
		if to_adjust[self._id] then
			local params = to_adjust[self._id]
			
			if params.new_pos then
				self._values.position = params.new_pos
			end
			
			if params.new_rotation then
				self._values.rotation = mrotation.yaw(params.new_rotation)
			end
			
			if params.new_search_pos then
				self._values.search_position = params.new_search_pos
			end
			
			if params.new_action then
				self._values.so_action = params.new_action
			end
			
			--log("SCRONGBONGLED")
		end
	end

	if self:_is_nav_link() then
		managers.navigation._LIES_navlink_elements[self._id] = self
	end
	
	local is_AI_SO = self._is_AI_SO or string.begins(self._values.so_action, "AI")
	
	if not is_AI_SO and self._values.path_stance ~= "hos" and self._values.path_stance ~= "cbt" and (self._values.patrol_path or self._values.position) and self._values.path_style ~= "precise" then
		self._stealth_patrol = true
	end
end)

function ElementSpecialObjective:nav_link_delay()
	local original_value = self:_get_default_value_if_nil("interval")
	
	if original_value > 3 then
		original_value = 3
	end
	
	return original_value
end

function ElementSpecialObjective:clbk_verify_administration(unit)
	if self._values.needs_pos_rsrv then
		self._tmp_pos_rsrv = self._tmp_pos_rsrv or {
			radius = 30,
			position = self._values.position
		}
		local pos_rsrv = self._tmp_pos_rsrv
		pos_rsrv.filter = unit:movement():pos_rsrv_id()

		if not managers.navigation:is_pos_free(pos_rsrv) then
			return false
		end
	end
	
	if self._stealth_patrol then
		if unit:movement()._nav_tracker and unit:brain():SO_access() then
			local to_pos = self._values.position
			
			if not to_pos then
				local path_data = managers.ai_data:patrol_path(self._values.patrol_path)
				
				local points = path_data.points
				to_pos = points[#points].position
			end
			
			if to_pos then
				local to_seg = managers.navigation:get_nav_seg_from_pos(to_pos, true)
				local search_params = {
					id = "ESO_coarse_" ..  self._id .. tostring(unit:key()),
					from_tracker = unit:movement():nav_tracker(),
					to_seg = to_seg,
					to_pos = to_pos,
					access_pos = self._values.SO_access
				}
				local coarse_path = managers.navigation:search_coarse(search_params)
				
				if not coarse_path then
					return false
				end
			end
		end
	end

	return true
end

function ElementSpecialObjective:choose_followup_SO(unit, skip_element_ids)
	if not self._values.followup_elements then
		return
	end

	if skip_element_ids == nil then
		if self._values.allow_followup_self and self:enabled() then
			skip_element_ids = {}
		else
			skip_element_ids = {
				[self._id] = true
			}
		end
	end

	if self._values.SO_access and unit and not managers.navigation:check_access(self._values.SO_access, unit:brain():SO_access(), 0) then
		return
	end
	
	local found_element = true
	local total_weight = 0
	local pool = {}

	for _, followup_element_id in ipairs(self._values.followup_elements) do
		local weight = nil
		local followup_element = managers.mission:get_element_by_id(followup_element_id)

		if followup_element:enabled() then
			followup_element, weight = followup_element:get_as_followup(unit, skip_element_ids)

			if followup_element and followup_element:enabled() and weight > 0 then
				table.insert(pool, {
					element = followup_element,
					weight = weight
				})

				total_weight = total_weight + weight
			end
		end
	end

	if not next(pool) or total_weight <= 0 then
		found_element = nil
	end
	
	if found_element then
		local lucky_w = math.random() * total_weight
		local accumulated_w = 0

		for i, followup_data in ipairs(pool) do
			accumulated_w = accumulated_w + followup_data.weight

			if lucky_w <= accumulated_w then
				return pool[i].element
			end
		end
	elseif self._stealth_patrol then --we have followup elements...but none of them are accessible...aaaaa repeat!!!
		local weight
		local followup_element = managers.mission:get_element_by_id(self._id)
		followup_element, weight = followup_element:get_as_followup(unit, {})
		
		return followup_element
	end
end