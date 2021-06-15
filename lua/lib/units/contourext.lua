local mvec3_dis_sq = mvector3.distance_sq
local tmp_vec = Vector3()

local math_lerp = math.lerp

local pairs_g = pairs

local table_index_of = table.index_of
local alive_g = alive

local idstr_contour = Idstring("contour")
local idstr_material = Idstring("material")
local idstr_contour_color = Idstring("contour_color")
local idstr_contour_opacity = Idstring("contour_opacity")

ContourExt._types.mark_unit_dangerous.priority = 5
ContourExt._types.mark_unit_dangerous_damage_bonus.color = tweak_data.contour.character.more_dangerous_color
ContourExt._types.mark_unit_dangerous_damage_bonus_distance.color = tweak_data.contour.character.more_dangerous_color

if deathvox:IsTotalCrackdownEnabled() then
	ContourExt._types.mark_enemy.fadeout = 60
	ContourExt._types.mark_enemy.fadeout_silent = 60
	ContourExt._types.mark_unit_dangerous.fadeout = 60
	ContourExt._types.mark_unit_dangerous_damage_bonus.fadeout = 60
	ContourExt._types.mark_unit_dangerous_damage_bonus_distance.fadeout = 60
	ContourExt._types.mark_enemy_damage_bonus.fadeout = 60
	ContourExt._types.mark_enemy_damage_bonus.fadeout_silent = 60
	ContourExt._types.mark_enemy_damage_bonus_distance.fadeout = 60
	ContourExt._types.mark_enemy_damage_bonus_distance.fadeout_silent = 60
end

local init_original = ContourExt.init
function ContourExt:init(...)
	self._timer = TimerManager:game()

	init_original(self, ...)
end

function ContourExt:apply_to_linked(func_name, ...)
	local spawn_manager = self._unit:spawn_manager()

	if not spawn_manager then
		return
	end

	local linked_units = spawn_manager:linked_units()

	if not linked_units then
		return
	end

	local spawned_units = spawn_manager:spawned_units()

	for unit_id, _ in pairs_g(linked_units) do
		local unit_entry = spawned_units[unit_id]

		if unit_entry then
			local child_unit = unit_entry.unit

			if alive_g(child_unit) then
				local contour_ext = child_unit:contour()

				if contour_ext then
					contour_ext[func_name](contour_ext, ...)
				end
			end
		end
	end
end

function ContourExt:add(type, sync, multiplier, override_color, add_as_child, mark_peer_id)
	--[[if Global.debug_contour_enabled then
		return
	end]]

	local unit = self._unit
	local data = self._types[type]
	local fadeout = data.fadeout
	local stealth_fadeout = data.fadeout_silent

	if stealth_fadeout and managers.groupai:state():whisper_mode() then
		local char_tweak = unit:base():char_tweak()

		if char_tweak and char_tweak.silent_priority_shout then
			fadeout = stealth_fadeout
		end
	end

	if fadeout and multiplier then
		fadeout = fadeout * multiplier
	end

	self._is_child_contour = add_as_child and true or false

	if sync then
		if add_as_child then
			sync = nil
		else
			local sync_unit = unit
			local u_id = sync_unit:id()

			if u_id == -1 then
				local corpse_data = managers.enemy:get_corpse_unit_data_from_key(sync_unit:key())
				u_id = corpse_data and corpse_data.u_id or nil

				sync_unit = nil
			end

			if u_id then
				managers.network:session():send_to_peers_synched("sync_contour_state", sync_unit, u_id, table_index_of(ContourExt.indexed_types, type), true, multiplier or 1)
			end
		end
	end

	local should_trigger_marked_event = data.trigger_marked_event
	local damage_bonus = data.damage_bonus
	local damage_bonus_dis = data.damage_bonus_distance
	local prio = data.priority
	local contour_list = self._contour_list
	local type_was_in_list = false
	local index = 1

	for i = 1, #contour_list do
		local setup = contour_list[i]

		if not add_as_child and not damage_bonus then
			damage_bonus = setup.damage_bonus
		end

		if not add_as_child and not damage_bonus_dis then
			damage_bonus_dis = setup.damage_bonus_distance
		end

		if setup.type == type then
			if fadeout then
				setup.fadeout_t = self._timer:time() + fadeout
			elseif not setup.unique then
				setup.ref_c = setup.ref_c + 1
			end

			setup.color = override_color or setup.color

			if mark_peer_id then
				setup.peer_ids = setup.peer_ids or {}
				setup.peer_ids[mark_peer_id] = true
			end

			type_was_in_list = setup
		else
			if setup.priority <= prio then
				index = index + 1
			end

			if should_trigger_marked_event and setup.trigger_marked_event then
				should_trigger_marked_event = false
			end
		end
	end

	if not add_as_child and damage_bonus then
		local dmg_ext = unit:character_damage()

		if dmg_ext and dmg_ext.on_marked_state then
			dmg_ext:on_marked_state(damage_bonus, damage_bonus_dis)
		end
	end

	if type_was_in_list then
		return type_was_in_list
	end

	local has_ray_check = data.ray_check
	local setup = {
		ref_c = 1,
		type = type,
		fadeout_t = fadeout and self._timer:time() + fadeout or nil,
		sync = sync,
		ray_check = has_ray_check,
		persistence = data.persistence,
		material_swap_required = data.material_swap_required,
		trigger_marked_event = data.trigger_marked_event,
		damage_bonus = not add_as_child and data.damage_bonus,
		damage_bonus_distance = not add_as_child and data.damage_bonus_distance,
		priority = prio,
		unique = data.unique,
		color = override_color or data.color
	}

	if mark_peer_id then
		setup.peer_ids = {
			mark_peer_id = true
		}
	end
	
	if has_ray_check then
		local mov_ext = unit:movement()

		if mov_ext and mov_ext.m_com then
			setup.ray_pos = mov_ext:m_com()
		end
	end

	local old_preset = contour_list[1]
	local old_preset_type = old_preset and old_preset.type
	local new_contour_list = {}

	for idx = 1, index - 1 do
		new_contour_list[#new_contour_list + 1] = contour_list[idx]
	end

	new_contour_list[#new_contour_list + 1] = setup

	for idx = index, #contour_list do
		new_contour_list[#new_contour_list + 1] = contour_list[idx]
	end

	self._contour_list = new_contour_list

	if old_preset_type ~= setup.type then
		self:_apply_top_preset()
	end

	if not self._update_enabled then
		self:_chk_update_state()
	end

	self:apply_to_linked("add", type, nil, multiplier, override_color, true)

	if should_trigger_marked_event then
		local element = unit:unit_data().mission_element

		if element then
			element:event("marked", unit)
		end
	end

	return setup
end

function ContourExt:chk_joker_should_prioritize(owner_id)
	local list = self._contour_list

	for i = 1, #list do
		local setup = list[i]
		local peer_ids = setup.peer_ids

		if peer_ids and peer_ids[owner_id] then
			return true
		end
	end

	return false
end

function ContourExt:change_color(type, color)
	local list = self._contour_list

	for i = 1, #list do
		local setup = list[i]

		if setup.type == type then
			setup.color = color

			self:_upd_color()

			break
		end
	end

	self:apply_to_linked("change_color", type, color)
end

function ContourExt:flash(type_or_id, frequency)
	local list = self._contour_list

	for i = 1, #list do
		local setup = list[i]

		if setup.type == type_or_id or setup == type_or_id then
			frequency = frequency and frequency > 0 and frequency or nil
			setup.flash_frequency = frequency
			setup.flash_t = frequency and self._timer:time() + frequency or nil
			setup.flash_on = nil

			list[i] = setup

			self:_chk_update_state()

			break
		end
	end

	self:apply_to_linked("flash", type_or_id, frequency)
end

function ContourExt:is_flashing()
	local list = self._contour_list

	for i = 1, #list do
		local setup = list[i]

		if setup.flash_frequency then
			return true
		end
	end
end

function ContourExt:remove(type, sync)
	local list = clone(self._contour_list)

	for i = 1, #list do
		local setup = list[i]

		if setup.type == type then
			self:_remove(i, sync)

			if self._update_enabled then
				self:_chk_update_state()
			end

			break
		end
	end

	self:apply_to_linked("remove", type)
end

function ContourExt:remove_by_id(id, sync)
	local remove_type = id.type
	local list = self._contour_list

	for i = 1, #list do
		local setup = list[i]

		if setup == id then
			self:_remove(i, sync)

			if self._update_enabled then
				self:_chk_update_state()
			end

			break
		end
	end

	self:apply_to_linked("remove", remove_type)
end

function ContourExt:has_id(id)
	local list = self._contour_list

	for i = 1, #list do
		local setup = list[i]

		if setup.type == id then
			return true
		end
	end

	return false
end

function ContourExt:_clear()
	self._contour_list = {}
	self._materials = nil
end

function ContourExt:_remove(index, sync)
	local contour_list = self._contour_list
	local setup = contour_list[index]

	if not setup then
		return
	end

	local unit = self._unit
	local contour_type = setup.type
	local should_disable_damage_bonus = setup.damage_bonus
	local keep_damage_bonus_dis = nil

	if should_disable_damage_bonus then
		for i = 1, index - 1 do
			local other_setup = contour_list[i]

			if should_disable_damage_bonus and other_setup.damage_bonus then
				should_disable_damage_bonus = nil
			end

			keep_damage_bonus_dis = keep_damage_bonus_dis or other_setup.damage_bonus_distance
		end

		for i = index + 1, #contour_list do
			local other_setup = contour_list[i]

			if should_disable_damage_bonus and other_setup.damage_bonus then
				should_disable_damage_bonus = nil
			end

			keep_damage_bonus_dis = keep_damage_bonus_dis or other_setup.damage_bonus_distance
		end

		local dmg_bonus_state = keep_damage_bonus_dis and true or should_disable_damage_bonus and false or true

		unit:character_damage():on_marked_state(dmg_bonus_state, keep_damage_bonus_dis)
	end

	if setup.ref_c > 1 then
		setup.ref_c = setup.ref_c - 1

		return
	end

	if #contour_list == 1 then
		managers.occlusion:add_occlusion(unit)

		if setup.material_swap_required then
			local base_ext = unit:base()

			if base_ext and base_ext.set_material_state then
				base_ext:set_material_state(true)
				--base_ext:set_allow_invisible(true)
			else
				local materials = self._materials

				if materials then
					for i = 1, #materials do
						local material = materials[i]

						material:set_variable(idstr_contour_opacity, 0)
					end
				end
			end
		else
			local materials = self._materials

			for i = 1, #materials do
				local material = materials[i]

				material:set_variable(idstr_contour_opacity, 0)
			end
		end
	end

	self._last_opacity = nil

	local new_contour_list = {}

	for idx = 1, index - 1 do
		new_contour_list[#new_contour_list + 1] = contour_list[idx]
	end

	for idx = index + 1, #contour_list do
		new_contour_list[#new_contour_list + 1] = contour_list[idx]
	end

	contour_list = new_contour_list
	self._contour_list = contour_list

	if not contour_list[1] then
		self:_clear()
	elseif index == 1 then
		self:_apply_top_preset()
	end

	if sync then
		local sync_unit = unit
		local u_id = sync_unit:id()

		if u_id == -1 then
			local corpse_data = managers.enemy:get_corpse_unit_data_from_key(sync_unit:key())
			u_id = corpse_data and corpse_data.u_id or nil

			sync_unit = nil
		end

		if u_id then
			managers.network:session():send_to_peers_synched("sync_contour_state", sync_unit, u_id, table_index_of(ContourExt.indexed_types, contour_type), false, 1)
		end
	end

	if setup.trigger_marked_event then
		local should_trigger_unmarked_event = true

		for i = 1, #contour_list do
			local setup = contour_list[i]

			if setup.trigger_marked_event then
				should_trigger_unmarked_event = false

				break
			end
		end

		if should_trigger_unmarked_event then	
			local element = unit:unit_data().mission_element

			if element then
				element:event("unmarked", unit)
			end
		end
	end
end

local lerp_opacity = false --current contours don't support this

function ContourExt:update(u_unit, t, dt)
	local cam_pos = nil
	local index = 1
	local unit = self._unit
	local contour_list = self._contour_list
	local ray_check_slotmask = self._slotmask_world_geometry

	while index <= #contour_list do
		local setup = contour_list[index]
		local is_current = index == 1
		local fadeout_t = setup.fadeout_t

		if fadeout_t and fadeout_t < t then
			self:_remove(index)
			self:_chk_update_state()

			contour_list = self._contour_list
		else
			index = index + 1

			local turn_off = nil

			if is_current and setup.ray_check then
				local turn_on = false
				cam_pos = cam_pos or managers.viewport:get_current_camera_position()

				if cam_pos then
					local u_pos = setup.ray_pos

					if not u_pos then
						u_pos = tmp_vec
						unit:m_position(u_pos)
					end

					turn_on = mvec3_dis_sq(cam_pos, u_pos) > 16000000
					turn_on = turn_on or unit:raycast("ray", u_pos, cam_pos, "slot_mask", ray_check_slotmask, "report")
				end

				local persistence = setup.persistence

				if persistence then
					if turn_on then
						setup.last_turned_on_t = t
					else
						local last_t = setup.last_turned_on_t

						if not last_t or persistence < t - last_t then
							turn_off = true

							setup.last_turned_on_t = nil
						end
					end
				elseif not turn_on then
					turn_off = not turn_on
				end
			end

			local flash_t = setup.flash_t

			if flash_t then
				local flash = setup.flash_on

				if flash_t < t then
					setup.flash_t = setup.flash_t + setup.flash_frequency
					flash = not flash
					setup.flash_on = flash
				end

				if is_current then
					if turn_off or not flash then
						----add support in general to change and display the color of other contours when one is flashing or gets turned off
						--make use of a separate table of "active" contours
						--[[for i = index, #contour_list do
							local other_setup = contour_list[i]

							if other_setup then
								
							else]]
								self:_upd_opacity(0)
							--end
						--end
					elseif fadeout_t and lerp_opacity then
						local opacity_lerp = math_lerp(1, 0, t / fadeout_t)

						self:_upd_opacity(opacity_lerp)
					else
						self:_upd_opacity(1)
					end
				end
			elseif is_current then
				if turn_off then
					self:_upd_opacity(0)
				elseif fadeout_t and lerp_opacity then
					local opacity_lerp = math_lerp(1, 0, t / fadeout_t)

					self:_upd_opacity(opacity_lerp)
				else
					self:_upd_opacity(1)
				end
			end
		end
	end
end

function ContourExt:_upd_opacity(opacity, is_retry)
	if opacity == self._last_opacity then
		return
	end

	--[[if Global.debug_contour_enabled and opacity == 1 then
		self._last_opacity = 1

		return
	end]]

	local materials = self._materials or self._unit:get_objects_by_type(idstr_material)
	self._materials = materials

	for i = 1, #materials do
		local material = materials[i]

		if not alive_g(material) then
			self:update_materials()

			if not is_retry then
				self:_upd_opacity(opacity, true)
			end

			return
		end

		material:set_variable(idstr_contour_opacity, opacity)
	end

	self._last_opacity = opacity

	self:apply_to_linked("_upd_opacity", opacity, is_retry)
end

function ContourExt:_upd_color(is_retry)
	local setup = self._contour_list[1]

	if not setup then
		return
	end

	local color = setup.color

	if not color then
		return
	end

	local materials = self._materials or self._unit:get_objects_by_type(idstr_material)
	self._materials = materials

	for i = 1, #materials do
		local material = materials[i]

		if not alive_g(material) then
			self:update_materials()

			if not is_retry then
				self:_upd_color(true)
			end

			break
		end

		material:set_variable(idstr_contour_color, color)
	end

	self:apply_to_linked("_upd_color", is_retry)
end

function ContourExt:_apply_top_preset()
	local setup = self._contour_list[1]
	self._last_opacity = nil

	if setup.material_swap_required then
		self._materials = nil

		local base_ext = self._unit:base()

		if base_ext and base_ext.is_in_original_material and base_ext:is_in_original_material() then
			base_ext:swap_material_config(callback(self, ContourExt, "material_applied", true))
		else
			self:material_applied()
		end
	else
		managers.occlusion:remove_occlusion(self._unit)
		self:material_applied()
	end
end

function ContourExt:material_applied(material_was_swapped)
	local setup = self._contour_list[1]

	if material_was_swapped then
		local unit = self._unit

		managers.occlusion:remove_occlusion(unit)
		--unit:base():set_allow_invisible(false)
		self:update_materials()
	else
		self._materials = nil

		self:_upd_color()

		if not setup.ray_check then
			self:_upd_opacity(1)
		end
	end
end

function ContourExt:_chk_update_state()
	local needs_update = nil

	if self._is_child_contour then
		if self._update_enabled ~= needs_update then
			self._update_enabled = needs_update

			self._unit:set_extension_update_enabled(idstr_contour, needs_update and true or false)
		end

		return
	end

	local list = self._contour_list

	for i = 1, #list do
		local setup = list[i]

		if setup.fadeout_t or setup.flash_t or setup.ray_check then
			needs_update = true

			break
		end
	end

	if self._update_enabled ~= needs_update then
		self._update_enabled = needs_update

		self._unit:set_extension_update_enabled(idstr_contour, needs_update and true or false)
	end
end

function ContourExt:update_materials()
	if not self._contour_list[1] then
		return
	end

	self._materials = nil

	self:_upd_color()

	local opacity = self._last_opacity or 1
	self._last_opacity = nil

	self:_upd_opacity(opacity)
end

function ContourExt:save(data)
	if self._is_child_contour then
		return
	end

	local list = self._contour_list

	for i = 1, #list do
		local setup = list[i]

		if setup.type == "highlight_character" and setup.sync then
			data.highlight_character = true

			return
		end
	end
end

function ContourExt:load(data)
	if not data or not data.highlight_character then
		return
	end

	self:add("highlight_character")
end