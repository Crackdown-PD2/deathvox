local world_g = World

function HuskTeamAIInventory:add_unit_by_name(new_unit_name, equip)
	local new_unit = world_g:spawn_unit(new_unit_name, Vector3(), Rotation())

	managers.mutators:modify_value("CopInventory:add_unit_by_name", self)
	CopInventory._chk_spawn_shield(self, new_unit)

	local setup_data = {
		user_unit = self._unit,
		ignore_units = {
			self._unit,
			new_unit,
			self._shield_unit
		},
		expend_ammo = false,
		hit_slotmask = managers.slot:get_mask("bullet_impact_targets_no_AI"),
		user_sound_variant = tweak_data.character[self._unit:base()._tweak_table].weapon_voice
	}

	new_unit:base():setup(setup_data)

	if new_unit:base().AKIMBO then
		new_unit:base():create_second_gun(new_unit_name)
	end

	self:add_unit(new_unit, equip)
end

function HuskTeamAIInventory:add_unit(new_unit, equip)
	HuskTeamAIInventory.super.add_unit(self, new_unit, equip)

	if managers.groupai:state():is_unit_team_AI(self._unit) then
		if new_unit:base().set_user_is_team_ai then
			new_unit:base():set_user_is_team_ai(true)
		end

		self:_ensure_weapon_visibility(new_unit)

		return
	end
end
