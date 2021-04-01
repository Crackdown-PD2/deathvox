local type_g = type

local _post_init_original = HuskTeamAIMovement._post_init
function HuskTeamAIMovement:_post_init(...)
	_post_init_original(self, ...)

	if not managers.groupai:state():whisper_mode() then
		return
	end

	local my_unit = self._unit
	my_unit:base():set_slot(my_unit, 24)
end

function HuskTeamAIMovement:sync_reload_weapon(empty_reload, reload_speed_multiplier)
	local reload_action = {
		body_part = 3,
		type = "reload",
		idle_reload = empty_reload ~= 0 and empty_reload or nil
	}

	self:action_request(reload_action)
end

function HuskTeamAIMovement:_switch_to_not_cool(...)
	HuskTeamAIMovement.super._switch_to_not_cool(self, ...)

	local inv_ext = self._ext_inventory
	local equipped_unit = inv_ext:equipped_unit()

	if equipped_unit then
		inv_ext:_ensure_weapon_visibility()
	end

	local my_unit = self._unit
	my_unit:base():set_slot(my_unit, 16)
end

function HuskTeamAIMovement:add_weapons()
	local base_ext = self._ext_base
	local inv_ext = self._ext_inventory
	local weapon = base_ext:default_weapon_name("primary")

	if type_g(weapon) == "table" then
		weapon = weapon[1][1]
	end

	if weapon then
		inv_ext:add_unit_by_factory_name(weapon, false, false, nil, "")
	end

	local sec_weapon = base_ext:default_weapon_name("secondary")

	if type_g(sec_weapon) == "table" then
		sec_weapon = sec_weapon[1][1]
	end

	if sec_weapon then
		inv_ext:add_unit_by_factory_name(sec_weapon, false, false, nil, "")
	end
end
