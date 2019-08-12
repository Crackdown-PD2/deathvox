ModifierShieldPhalanx = ModifierShieldPhalanx or class(BaseModifier)
ModifierShieldPhalanx._type = "ModifierShieldPhalanx"
ModifierShieldPhalanx.name_id = "none"
ModifierShieldPhalanx.desc_id = "menu_cs_modifier_shield_phalanx"

function ModifierShieldPhalanx:init(data)
	ModifierShieldPhalanx.super.init(data)

	--only replacing the units so that is_captain isn't applied to them (the rest is identical otherwise)
	tweak_data.group_ai.unit_categories.CS_shield.unit_types = tweak_data.group_ai.unit_categories.Phalanx_minion.unit_types
	tweak_data.group_ai.unit_categories.FBI_shield.unit_types = tweak_data.group_ai.unit_categories.Phalanx_minion.unit_types
end

function ModifierShieldPhalanx:modify_value(id, value, unit)
	if id ~= "PlayerStandart:_start_action_intimidate" then
		return value
	end

	local unit_tweak = unit:base()._tweak_table

	if unit_tweak ~= "phalanx_minion" then
		return value
	end

	if unit:base().is_phalanx then
		return --OH SHIT CAPTAIN
	end

	return "f31x_any" --OH SHIT SHIELD
end
