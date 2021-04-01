local mvec3_set = mvector3.set
local mvec3_mul = mvector3.multiply

local tmp_vec1 = Vector3()

local math_random = math.random

local idstr_func = Idstring
local unit_idstr = idstr_func("unit")
local medium_col_unit_idstr = idstr_func("units/payday2/weapons/box_collision/box_collision_medium_ar")
local medium_col_idstr = idstr_func("rp_box_collision_medium")

local alive_g = alive
local world_g = World
local tonumber_g = tonumber
local tostring_g = tonumber

function CopInventory:drop_weapon()
	local selection = self._available_selections[self._equipped_selection]
	local unit = selection and selection.unit

	if not alive_g(unit) then
		self._equipped_selection = nil

		return
	end

	local base_ext = unit:base()
	local second_gun = base_ext and base_ext._second_gun

	unit:unlink()

	local u_dmg = unit:damage()

	if u_dmg and u_dmg:has_sequence("enable_body") then
		u_dmg:run_sequence_simple("enable_body")
	else
		local u_pos = unit:position()
		local u_rot = unit:rotation()
		local dropped_col = world_g:spawn_unit(medium_col_unit_idstr, u_pos, u_rot)

		if dropped_col then
			dropped_col:link(medium_col_idstr, unit)
			unit:base()._collider_unit = dropped_col

			mvec3_set(tmp_vec1, u_rot:y())
			mvec3_mul(tmp_vec1, math_random(75, 200))

			dropped_col:push(10, tmp_vec1)

			--[[local listener_key = "added_collision" .. tostring_g(dropped_col:key())

			unit:base():add_destroy_listener(listener_key, function()
				if alive_g(dropped_col) then
					dropped_col:set_slot(0)
				end

				if not alive_g(unit) then
					return
				end

				unit:base():remove_destroy_listener(listener_key)
			end)]]
		end
	end

	managers.game_play_central:weapon_dropped(unit)

	if alive_g(second_gun) then
		second_gun:unlink()

		local s_gun_u_dmg = second_gun:damage()

		if s_gun_u_dmg and s_gun_u_dmg:has_sequence("enable_body") then
			s_gun_u_dmg:run_sequence_simple("enable_body")
		else
			local u_pos = second_gun:position()
			local u_rot = second_gun:rotation()
			local dropped_col = world_g:spawn_unit(medium_col_unit_idstr, u_pos, u_rot)

			if dropped_col then
				dropped_col:link(medium_col_idstr, second_gun)
				second_gun:base()._collider_unit = dropped_col

				mvec3_set(tmp_vec1, u_rot:y())
				mvec3_mul(tmp_vec1, math_random(75, 200))

				dropped_col:push(10, tmp_vec1)

				--[[local listener_key = "added_collision" .. tostring_g(dropped_col:key())

				second_gun:base():add_destroy_listener(listener_key, function()
					if alive_g(dropped_col) then
						dropped_col:set_slot(0)
					end

					if not alive_g(second_gun) then
						return
					end

					second_gun:base():remove_destroy_listener(listener_key)
				end)]]
			end
		end

		managers.game_play_central:weapon_dropped(second_gun)
	end

	self._equipped_selection = nil

	self:_call_listeners("unequip")
end

function CopInventory:add_unit_by_factory_name(factory_name, equip, instant, blueprint_string, cosmetics_string)
	local factory_weapon = tweak_data.weapon.factory[factory_name]
	local ids_unit_name = idstr_func(factory_weapon.unit)
	local dyn_rsr_manager = managers.dyn_resource

	if not dyn_rsr_manager:is_resource_ready(unit_idstr, ids_unit_name, dyn_rsr_manager.DYN_RESOURCES_PACKAGE) then
		dyn_rsr_manager:load(unit_idstr, ids_unit_name, dyn_rsr_manager.DYN_RESOURCES_PACKAGE, nil)
	end

	local blueprint = blueprint_string and blueprint_string ~= "" and managers.weapon_factory:unpack_blueprint_from_string(factory_name, blueprint_string) or managers.weapon_factory:get_default_blueprint_by_factory_id(factory_name)
	local cosmetics_data = string.split(cosmetics_string, "-")
	local weapon_skin_id = cosmetics_data[1] or "nil"
	local cosmetics = nil

	if weapon_skin_id ~= "nil" then
		local quality_index_s = cosmetics_data[2] or "1"
		local bonus_id_s = cosmetics_data[3] or "0"
		local bonus = bonus_id_s == "1" and true or false
		local quality = tweak_data.economy:get_entry_from_index("qualities", tonumber_g(quality_index_s))

		cosmetics = {
			id = weapon_skin_id,
			quality = quality,
			bonus = bonus
		}
	end

	local new_unit = world_g:spawn_unit(ids_unit_name, Vector3(), Rotation())

	if not new_unit then
		return --oh no
	end

	new_unit:base():set_factory_data(factory_name)
	new_unit:base():set_cosmetics_data(cosmetics)
	new_unit:base():assemble_from_blueprint(factory_name, blueprint)
	new_unit:base():check_npc()

	managers.mutators:modify_value("CopInventory:add_unit_by_name", self)
	self:_chk_spawn_shield(new_unit)

	local setup_data = nil

	if Network:is_server() then
		setup_data = {
			user_unit = self._unit,
			ignore_units = {
				self._unit,
				new_unit,
				self._shield_unit
			},
			expend_ammo = false,
			hit_slotmask = managers.slot:get_mask("bullet_impact_targets"),
			hit_player = true,
			user_sound_variant = "1",
			alert_AI = true,
			alert_filter = self._unit:brain():SO_access()
		}
	else
		setup_data = {
			user_unit = self._unit,
			ignore_units = {
				self._unit,
				new_unit,
				self._shield_unit
			},
			expend_ammo = false,
			hit_slotmask = managers.slot:get_mask("bullet_impact_targets_no_AI"),
			hit_player = true,
			user_sound_variant = "1"
		}
	end

	new_unit:base():setup(setup_data)

	if new_unit:base().AKIMBO then
		new_unit:base():create_second_gun()
	end

	self:add_unit(new_unit, equip, instant)
end
