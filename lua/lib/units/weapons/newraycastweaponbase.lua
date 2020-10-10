function NewRaycastWeaponBase:conditional_accuracy_addend(current_state)
	local index = 0

	if not current_state then
		return index
	end

	local pm = managers.player
	
	local has_category = self._unit and alive(self._unit) and not self._unit:base().thrower_unit and self._unit:base().is_category
	
	if not current_state:in_steelsight() then
		index = index + pm:upgrade_value("player", "hip_fire_accuracy_inc", 0)
	elseif has_category and self:is_weapon_class("rapidfire") and pm:player_unit() then 
		index = index + pm:upgrade_value("rapidfire","shotgrouping_aced",0)
	end

	if self:is_single_shot() and self:is_category("assault_rifle", "smg", "snp") then
		index = index + pm:upgrade_value("weapon", "single_spread_index_addend", 0)
	elseif not self:is_single_shot() then
		index = index + pm:upgrade_value("weapon", "auto_spread_index_addend", 0)
	end

	if not current_state._moving then
		index = index + pm:upgrade_value("player", "not_moving_accuracy_increase", 0)
	end

	if current_state._moving then
		for _, category in ipairs(self:categories()) do
			index = index + pm:upgrade_value(category, "move_spread_index_addend", 0)
		end
	end
	
	--log("we gunnin':" .. index .. "")

	return index
end

function NewRaycastWeaponBase:enter_steelsight_speed_multiplier()
	local multiplier = 1
	local categories = self:weapon_tweak_data().categories

	for _, category in ipairs(categories) do
		multiplier = multiplier + 1 - managers.player:upgrade_value(category, "enter_steelsight_speed_multiplier", 1)
	end

	multiplier = multiplier + 1 - managers.player:temporary_upgrade_value("temporary", "combat_medic_enter_steelsight_speed_multiplier", 1)
	multiplier = multiplier + 1 - managers.player:upgrade_value(self._name_id, "enter_steelsight_speed_multiplier", 1)
	multiplier = multiplier + 1 - managers.player:upgrade_value("weapon", "enter_steelsight_speed_multiplier", 1)

	if self._silencer then
		multiplier = multiplier + 1 - managers.player:upgrade_value("weapon", "silencer_enter_steelsight_speed_multiplier", 1)

		for _, category in ipairs(categories) do
			multiplier = multiplier + 1 - managers.player:upgrade_value(category, "silencer_enter_steelsight_speed_multiplier", 1)
		end
	end
	
		
	local has_category = self._unit and alive(self._unit) and not self._unit:base().thrower_unit and self._unit:base().is_category
	
	multiplier = multiplier * managers.player:upgrade_value(self:get_weapon_class() or "","enter_steelsight_speed_multiplier",1)
	
	return self:_convert_add_to_mul(multiplier)
end

function NewRaycastWeaponBase:reload_speed_multiplier(multiplier)
	multiplier = multiplier or 1
	if self._current_reload_speed_multiplier then
		return self._current_reload_speed_multiplier
	end
	
	if self:is_weapon_class("precision") then
		local this_machine_data = managers.player:upgrade_value("weapon","point_and_click_bonus_reload_speed",{0,0})
		multiplier = multiplier * (1 - math.min(this_machine_data[1] * managers.player:get_property("current_point_and_click_stacks",0),this_machine_data[2]))
	end
	
	if self:is_weapon_class("rapidfire") and self:ammo_base():clip_empty() then
		multiplier = multiplier * managers.player:upgrade_value("weapon", "money_shot_aced", 1)
	end
	
	for _, category in ipairs(self:weapon_tweak_data().categories) do
		multiplier = multiplier + 1 - managers.player:upgrade_value(category, "reload_speed_multiplier", 1)
	end

	multiplier = multiplier + 1 - managers.player:upgrade_value("weapon", "passive_reload_speed_multiplier", 1)
	multiplier = multiplier + 1 - managers.player:upgrade_value(self._name_id, "reload_speed_multiplier", 1)

	if self._setup and alive(self._setup.user_unit) and self._setup.user_unit:movement() then
		local morale_boost_bonus = self._setup.user_unit:movement():morale_boost()

		if morale_boost_bonus then
			multiplier = multiplier + 1 - morale_boost_bonus.reload_speed_bonus
		end

		if self._setup.user_unit:movement():next_reload_speed_multiplier() then
			multiplier = multiplier + 1 - self._setup.user_unit:movement():next_reload_speed_multiplier()
		end
	end

	if managers.player:has_activate_temporary_upgrade("temporary", "reload_weapon_faster") then
		multiplier = multiplier + 1 - managers.player:temporary_upgrade_value("temporary", "reload_weapon_faster", 1)
	end

	if managers.player:has_activate_temporary_upgrade("temporary", "single_shot_fast_reload") then
		multiplier = multiplier + 1 - managers.player:temporary_upgrade_value("temporary", "single_shot_fast_reload", 1)
	end

	multiplier = multiplier + 1 - managers.player:get_property("shock_and_awe_reload_multiplier", 1)
	multiplier = multiplier + 1 - managers.player:get_temporary_property("bloodthirst_reload_speed", 1)
	multiplier = multiplier + 1 - managers.player:upgrade_value("team", "crew_faster_reload", 1)
	multiplier = self:_convert_add_to_mul(multiplier)
	multiplier = multiplier * self:reload_speed_stat()
	multiplier = managers.modifiers:modify_value("WeaponBase:GetReloadSpeedMultiplier", multiplier)

	return multiplier
end