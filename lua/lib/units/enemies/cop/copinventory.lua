function CopInventory:drop_weapon()
	local selection = self._available_selections[self._equipped_selection]
	local unit = selection and selection.unit

	self._equipped_selection = nil

	if alive(unit) then
		unit:unlink()

		if unit:damage() then
			unit:damage():run_sequence_simple("enable_body")
			managers.game_play_central:weapon_dropped(unit)
		end

		local second_gun = unit:base() and alive(unit:base()._second_gun) and unit:base()._second_gun

		if second_gun then
			second_gun:unlink()

			if second_gun:damage() then
				second_gun:damage():run_sequence_simple("enable_body")
				managers.game_play_central:weapon_dropped(second_gun)
			end
		end

		self:_call_listeners("unequip")
	end
end

--[[function CopInventory:add_unit_by_factory_name(factory_name, equip, instant, blueprint_string, cosmetics_string)
	local factory_weapon = tweak_data.weapon.factory[factory_name]
	local ids_unit_name = Idstring(factory_weapon.unit)

	if not managers.dyn_resource:is_resource_ready(Idstring("unit"), ids_unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
		managers.dyn_resource:load(Idstring("unit"), ids_unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE, nil)
	end

	local blueprint = nil
	blueprint = blueprint_string and blueprint_string ~= "" and managers.weapon_factory:unpack_blueprint_from_string(factory_name, blueprint_string) or managers.weapon_factory:get_default_blueprint_by_factory_id(factory_name)
	local cosmetics = nil
	local cosmetics_data = string.split(cosmetics_string, "-")
	local weapon_skin_id = cosmetics_data[1] or "nil"
	local quality_index_s = cosmetics_data[2] or "1"
	local bonus_id_s = cosmetics_data[3] or "0"

	if weapon_skin_id ~= "nil" then
		local quality = tweak_data.economy:get_entry_from_index("qualities", tonumber(quality_index_s))
		local bonus = bonus_id_s == "1" and true or false
		cosmetics = {
			id = weapon_skin_id,
			quality = quality,
			bonus = bonus
		}
	end

	self:add_unit_by_factory_blueprint(factory_name, equip, instant, blueprint, cosmetics)
end

function CopInventory:add_unit_by_factory_blueprint(factory_name, equip, instant, blueprint, cosmetics)
	local factory_weapon = tweak_data.weapon.factory[factory_name]
	local ids_unit_name = Idstring(factory_weapon.unit)

	if not managers.dyn_resource:is_resource_ready(Idstring("unit"), ids_unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
		managers.dyn_resource:load(Idstring("unit"), ids_unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE, nil)
	end

	local new_unit = World:spawn_unit(Idstring(factory_weapon.unit), Vector3(), Rotation())

	new_unit:base():set_factory_data(factory_name)
	new_unit:base():set_cosmetics_data(cosmetics)
	new_unit:base():assemble_from_blueprint(factory_name, blueprint)
	new_unit:base():check_npc()
	
	local setup_data = {
		user_unit = nil,
		ignore_units = {},
		expend_ammo = nil,
		hit_player = nil,
		user_sound_variant = nil,
		alert_AI = nil,
		alert_filter = nil
	}
	if Network:is_server() then
		setup_data = {
			user_unit = self._unit,
			ignore_units = {
				self._unit,
				new_unit
			},
			expend_ammo = false,
			autoaim = false,
			user_sound_variant = "1",
			hit_player = true,
			alert_AI = true,
			alert_filter = self._unit:brain():SO_access()
		}
	else
		setup_data = {
			user_unit = self._unit,
			ignore_units = {
				self._unit,
				new_unit
			},
			expend_ammo = false,
			autoaim = false,
			user_sound_variant = "1",
			hit_player = true,
			alert_AI = false
		}
	end

	new_unit:base():setup(setup_data)
	self:add_unit(new_unit, equip, instant)

	if new_unit:base().AKIMBO then
		new_unit:base():create_second_gun()
	end
end

local temp_vec1 = Vector3()
local drop_weapon_original = CopInventory.drop_weapon
function CopInventory:drop_weapon(...)
  local selection = self._available_selections[self._equipped_selection]
  local unit = selection and selection.unit

  if unit and unit:damage() then
    return drop_weapon_original(self, ...)
  end

  local create_physics_body = function (unit, right)
    local dropped_col = World:spawn_unit(Idstring("units/payday2/weapons/box_collision/box_collision_medium_ar"), unit:position(), unit:rotation())
    dropped_col:link(Idstring("rp_box_collision_medium"), unit)
    mvector3.set(temp_vec1, unit:rotation():y())
    mvector3.multiply(temp_vec1, math.random(75, 200))
    dropped_col:push(10, temp_vec1)
    unit:base()._collider_unit = dropped_col
  end

  if unit then
    unit:unlink()
    create_physics_body(unit)
    self:_call_listeners("unequip")
    managers.game_play_central:weapon_dropped(unit)

    if unit:base() and unit:base()._second_gun then
      local second_gun = unit:base()._second_gun
      second_gun:unlink()
      create_physics_body(unit, true)
      managers.game_play_central:weapon_dropped(second_gun)
    end
  end
end]]
