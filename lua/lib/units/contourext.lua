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
	
	--damage bonuses, and contour/marking itself (for these two) are handled clientside, since there's no easy way to tweak the damage bonus from marking
	local new_types = {
		civilian_mark_standard = {
			fadeout = 2,
			fadeout_silent = 15,
			priority = 2,
			material_swap_required = true,
--			damage_bonus = false,
			trigger_marked_event = true,
			color = tweak_data.contour.character.civilian_mark_standard_color
		},
		civilian_mark_special = {
			fadeout = 2,
			fadeout_silent = 15,
			priority = 2,
			material_swap_required = true,
--			damage_bonus = true,
			trigger_marked_event = true,
			color = tweak_data.contour.character.civilian_mark_special_color
		}
	}
	
	for name, preset in pairs(new_types) do
		ContourExt._types[name] = preset
		table.insert(ContourExt.indexed_types, name)
	end

	table.sort(ContourExt.indexed_types)
	
	
end

--mark_peer_id is from tcd
function ContourExt:add(type, sync, multiplier, override_color, is_element, mark_peer_id)
	self._contour_list = self._contour_list or {}
	local data = self._types[type]
	local fadeout = data.fadeout

	if data.fadeout_silent and managers.groupai:state():whisper_mode() then
		fadeout = data.fadeout_silent
	end

	if fadeout and multiplier then
		fadeout = fadeout * multiplier
	end

	sync = sync and not self._is_child_contour or false

	if sync then
		local sync_unit = self._unit
		local u_id = self._unit:id()

		if u_id == -1 then
			sync_unit, u_id = nil
			local corpse_data = managers.enemy:get_corpse_unit_data_from_key(self._unit:key())

			if corpse_data then
				u_id = corpse_data.u_id
			end
		end

		if u_id then
			managers.network:session():send_to_peers_synched("sync_contour_add", sync_unit, u_id, table.index_of(ContourExt.indexed_types, type), multiplier or 1)
		else
			sync = nil

			Application:error("[ContourExt:add] Unit isn't network-synced and isn't a registered corpse, can't sync. ", self._unit)
		end
	end

	for _, setup in ipairs(self._contour_list) do
		if setup.type == type then
			if fadeout then
				setup.fadeout_t = TimerManager:game():time() + fadeout
			elseif not setup.data.unique then
				setup.ref_c = setup.ref_c + 1
			end

			if is_element then
				setup.ref_c_element = (setup.ref_c_element or 0) + 1
			end

			local old_color = setup.color or data.color
			setup.color = override_color or nil

			if old_color ~= override_color then
				self:_upd_color()
			end
			
			if mark_peer_id then
				setup.peer_ids = setup.peer_ids or {}
				setup.peer_ids[mark_peer_id] = true
			end

			return setup
		end
	end

	local setup = {
		ref_c = 1,
		type = type,
		ref_c_element = is_element and 1 or nil,
		sync = sync,
		fadeout_t = fadeout and TimerManager:game():time() + fadeout or nil,
		color = override_color or nil,
		data = data
	}
	
	if mark_peer_id then
		setup.peer_ids = {
			mark_peer_id = true
		}
	end
	
	if data.ray_check then
		setup.upd_skip_count = ContourExt.raycast_update_skip_count
		local mov_ext = self._unit:movement()

		if mov_ext and mov_ext.m_com then
			setup.ray_pos = mov_ext:m_com()
		end
	end

	local i = 1
	local contour_list = self._contour_list
	local old_preset_type = contour_list[1] and contour_list[1].type

	while contour_list[i] and contour_list[i].data.priority <= data.priority do
		i = i + 1
	end

	table.insert(contour_list, i, setup)

	if not old_preset_type or i == 1 and old_preset_type ~= setup.type then
		self:_apply_top_preset()
	end

	if not self._update_enabled then
		self:_chk_update_state()
	end

	if data.damage_bonus or data.damage_bonus_distance then
		self:_chk_damage_bonuses()
	end

	if data.trigger_marked_event then
		self:_chk_mission_marked_events(setup)
	end

	self:apply_to_linked("add", type, false, multiplier, override_color)

	return setup
end

function ContourExt:chk_joker_should_prioritize(owner_id)
	local list = self._contour_list
	
	if list then
		for i = 1, #list do
			local setup = list[i]
			local peer_ids = setup.peer_ids

			if peer_ids and peer_ids[owner_id] then
				return true
			end
		end
	end

	return false
end

--[[
function ContourExt:save(data)
	local my_save_data = {}
	
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

function ContourExt:load(load_data)
	local my_load_data = load_data.ContourExt

	if not my_load_data or not load_data.highlight_character then
		return
	end
	
	if my_load_data and my_load_data.element_contours then
		for _, setup in ipairs(my_load_data.element_contours) do
			for i = 1, setup.ref_c_element do
				self:add(setup.type)
			end
		end
	end
	
	self:add("highlight_character")
end
--]]