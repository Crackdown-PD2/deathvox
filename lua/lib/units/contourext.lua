local idstr_contour = Idstring("contour")
local idstr_material = Idstring("material")
local idstr_contour_color = Idstring("contour_color")
local idstr_contour_opacity = Idstring("contour_opacity")

ContourExt._types.mark_enemy.fadeout = 60
ContourExt._types.mark_enemy.fadeout_silent = 60
ContourExt._types.mark_unit_dangerous.fadeout = 60
ContourExt._types.mark_unit_dangerous_damage_bonus.fadeout = 60
ContourExt._types.mark_unit_dangerous_damage_bonus_distance.fadeout = 60
ContourExt._types.mark_enemy_damage_bonus.fadeout = 60
ContourExt._types.mark_enemy_damage_bonus.fadeout_silent = 60
ContourExt._types.mark_enemy_damage_bonus_distance.fadeout = 60
ContourExt._types.mark_enemy_damage_bonus_distance.fadeout_silent = 60

function ContourExt:add(type, sync, multiplier, override_color, add_as_child)
	if Global.debug_contour_enabled then
		return
	end

	local data = self._types[type]
	local fadeout = data.fadeout
	
	local unit = self._unit
	if data.fadeout_silent then 
		local char_tweak = unit:base().char_tweak and unit:base():char_tweak()
		--this sanity check was the only real change to this file
		--tbh i don't know why there isn't already a sanity check here in vanilla
		--since evidently not all units with contour extensions will have the char_tweak() method
		if char_tweak and char_tweak.silent_priority_shout then
			fadeout = data.fadeout_silent
		end
	end

	if multiplier and multiplier > 1 then
		fadeout = fadeout * multiplier
	end

	self._contour_list = self._contour_list or {}
	self._is_child_contour = add_as_child and true or false

	if sync then
		local u_id = unit:id()

		if u_id == -1 then
			u_id = managers.enemy:get_corpse_unit_data_from_key(unit:key()).u_id
		end

		managers.network:session():send_to_peers_synched("sync_contour_state", unit, u_id, table.index_of(ContourExt.indexed_types, type), true, multiplier or 1)
	end

	local should_trigger_marked_event = data.trigger_marked_event

	for _, setup in ipairs(self._contour_list) do
		if setup.type == type then
			if fadeout then
				setup.fadeout_t = TimerManager:game():time() + fadeout
			elseif not self._types[setup.type].unique then
				setup.ref_c = (setup.ref_c or 0) + 1
			end

			setup.color = override_color or setup.color

			return setup
		end

		if self._types[setup.type].trigger_marked_event then
			should_trigger_marked_event = false
		end
	end

	local setup = {
		ref_c = 1,
		type = type,
		fadeout_t = fadeout and TimerManager:game():time() + fadeout or nil,
		sync = sync,
		color = override_color
	}
	local old_preset_type = self._contour_list[1] and self._contour_list[1].type
	local i = 1

	while self._contour_list[i] and self._types[self._contour_list[i].type].priority <= data.priority do
		i = i + 1
	end

	table.insert(self._contour_list, i, setup)

	if old_preset_type ~= setup.type then
		self:_apply_top_preset()
	end

	if not self._update_enabled then
		self:_chk_update_state()
	end

	self:apply_to_linked("add", type, sync, multiplier)

	if should_trigger_marked_event and unit:unit_data().mission_element then
		unit:unit_data().mission_element:event("marked", unit)
	end

	return setup
end
