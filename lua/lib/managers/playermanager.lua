Hooks:PostHook(PlayerManager,"_internal_load","deathvox_on_internal_load",function(self)
	if Network:is_server() then 
		deathvox:SyncOptionsToClients()
	else
		deathvox:ResetSessionSettings()
	end
end)

function PlayerManager:_chk_fellow_crimin_proximity(unit)
	local players_nearby = 0
		
	local criminals = World:find_units_quick(unit, "sphere", unit:position(), 1500, managers.slot:get_mask("criminals_no_deployables"))

	for _, criminal in ipairs(criminals) do
		players_nearby = players_nearby + 1
	end
		
	if players_nearby <= 0 then
		--log("uhohstinky")
	end
		
	return players_nearby
end

function PlayerManager:damage_reduction_skill_multiplier(damage_type)
	local multiplier = 1
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "dmg_dampener_outnumbered", 1)
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "dmg_dampener_outnumbered_strong", 1)
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "dmg_dampener_close_contact", 1)
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "revived_damage_resist", 1)
	multiplier = multiplier * self:upgrade_value("player", "damage_dampener", 1)
	multiplier = multiplier * self:upgrade_value("player", "health_damage_reduction", 1)
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "first_aid_damage_reduction", 1)
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "revive_damage_reduction", 1)
	multiplier = multiplier * self:get_hostage_bonus_multiplier("damage_dampener")
	multiplier = multiplier * self._properties:get_property("revive_damage_reduction", 1)
	multiplier = multiplier * self._temporary_properties:get_property("revived_damage_reduction", 1)
	local dmg_red_mul = self:team_upgrade_value("damage_dampener", "team_damage_reduction", 1)

	if self:has_category_upgrade("player", "passive_damage_reduction") then
		local health_ratio = self:player_unit():character_damage():health_ratio()
		local min_ratio = self:upgrade_value("player", "passive_damage_reduction")

		if health_ratio < min_ratio then
			dmg_red_mul = dmg_red_mul - (1 - dmg_red_mul)
		end
	end

	multiplier = multiplier * dmg_red_mul

	if damage_type == "melee" then
		multiplier = multiplier * managers.player:upgrade_value("player", "melee_damage_dampener", 1)
	end

	local current_state = self:get_current_state()

	if current_state and current_state:_interacting() then
		multiplier = multiplier * managers.player:upgrade_value("player", "interacting_damage_multiplier", 1)
	end
	if deathvox and deathvox:IsTotalCrackdownEnabled() then
		if self:has_team_category_upgrade("player", "crew_chief_t9") then
			multiplier = multiplier - 0.2 -- 20% damage reduction at t9
		elseif self:has_team_category_upgrade("player", "crew_chief_t1") then
			multiplier = multiplier - 0.1 -- but 10% at t1
		end
	end
	return multiplier
end

function PlayerManager:stamina_multiplier()
	local multiplier = 1
	multiplier = multiplier + self:upgrade_value("player", "stamina_multiplier", 1) - 1
	multiplier = multiplier + self:team_upgrade_value("stamina", "multiplier", 1) - 1
	multiplier = multiplier + self:team_upgrade_value("stamina", "passive_multiplier", 1) - 1
	multiplier = multiplier + self:get_hostage_bonus_multiplier("stamina") - 1
	multiplier = managers.modifiers:modify_value("PlayerManager:GetStaminaMultiplier", multiplier)
	if deathvox and deathvox:IsTotalCrackdownEnabled() then
		if self:has_team_category_upgrade("player", "crew_chief_t3") == true then
			multiplier = multiplier + 1 -- 100% more stamina
		end
	end
	return multiplier
end

function PlayerManager:health_skill_multiplier()
	local multiplier = 1
	multiplier = multiplier + self:upgrade_value("player", "health_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "passive_health_multiplier", 1) - 1
	multiplier = multiplier + self:team_upgrade_value("health", "passive_multiplier", 1) - 1
	multiplier = multiplier + self:get_hostage_bonus_multiplier("health") - 1
	multiplier = multiplier - self:upgrade_value("player", "health_decrease", 0)

	if self:num_local_minions() > 0 then
		multiplier = multiplier + self:upgrade_value("player", "minion_master_health_multiplier", 1) - 1
	end
	
	if deathvox and deathvox:IsTotalCrackdownEnabled() then
		if self:upgrade_value("player", "muscle_t9") == true then
			multiplier = multiplier + 1.25
		elseif self:upgrade_value("player", "muscle_t7") == true then
			multiplier = multiplier + 1
		elseif self:upgrade_value("player", "muscle_t5") == true then
			multiplier = multiplier + 0.75
		elseif self:upgrade_value("player", "muscle_t3") == true then
			multiplier = multiplier + 0.5
		elseif self:upgrade_value("player", "muscle_t1") == true then
			multiplier = multiplier + 0.25
		end
		if self:has_team_category_upgrade("player", "crew_chief_t6") == true then
			multiplier = multiplier + 0.3
		elseif self:has_team_category_upgrade("player", "crew_chief_t2") == true then
			multiplier = multiplier + 0.15
		end
	end
	return multiplier
end

function PlayerManager:body_armor_skill_multiplier(override_armor)
	local multiplier = 1
	multiplier = multiplier + self:upgrade_value("player", "tier_armor_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "passive_armor_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "armor_multiplier", 1) - 1
	multiplier = multiplier + self:team_upgrade_value("armor", "multiplier", 1) - 1
	multiplier = multiplier + self:get_hostage_bonus_multiplier("armor") - 1
	multiplier = multiplier + self:upgrade_value("player", "perk_armor_loss_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_armor_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "chico_armor_multiplier", 1) - 1
	if deathvox and deathvox:IsTotalCrackdownEnabled() then
		if self:upgrade_value("player", "armorer_t9") == true then
			multiplier = multiplier + 1
		elseif self:upgrade_value("player", "armorer_t7") == true then
			multiplier = multiplier + 0.8
		elseif self:upgrade_value("player", "armorer_t5") == true then
			multiplier = multiplier + 0.6
		elseif self:upgrade_value("player", "armorer_t3") == true then
			multiplier = multiplier + 0.4
		elseif self:upgrade_value("player", "armorer_t1") == true then
			multiplier = multiplier + 0.2
		end
		if self:has_team_category_upgrade("player", "crew_chief_t8") == true then
			multiplier = multiplier + 0.2
		elseif self:has_team_category_upgrade("player", "crew_chief_t4") == true then
			multiplier = multiplier + 0.1
		end
	end
	return multiplier
end

function PlayerManager:wearing_crook_armor()
	local equipped_armor = managers.blackmarket:equipped_armor(true, true)
	if equipped_armor == "level_2" then
		return true
	elseif equipped_armor == "level_3" then
		return true
	elseif equipped_armor == "level_4" then
		return true
	end
	return false
end

function PlayerManager:body_armor_skill_addend(override_armor)
	local addend = 0
	addend = addend + self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_armor_addend", 0)

	if self:has_category_upgrade("player", "armor_increase") then
		local health_multiplier = self:health_skill_multiplier()
		local max_health = (PlayerDamage._HEALTH_INIT + self:health_skill_addend()) * health_multiplier
		addend = addend + max_health * self:upgrade_value("player", "armor_increase", 1)
	end

	addend = addend + self:upgrade_value("team", "crew_add_armor", 0)

	if deathvox and deathvox:IsTotalCrackdownEnabled() then
		if self:wearing_crook_armor() then
			if self:upgrade_value("player", "crook_t7") == true then
				addend = addend + 6
			elseif self:upgrade_value("player", "crook_t5") == true then
				addend = addend + 4.5
			elseif self:upgrade_value("player", "crook_t3") == true then
				addend = addend + 3
			elseif self:upgrade_value("player", "crook_t1") == true then
				addend = addend + 1.5
			end
		end
	end

	return addend
end


function PlayerManager:body_armor_regen_multiplier(moving, health_ratio)
	local multiplier = 1
	multiplier = multiplier * self:upgrade_value("player", "armor_regen_timer_multiplier_tier", 1)
	multiplier = multiplier * self:upgrade_value("player", "armor_regen_timer_multiplier", 1)
	multiplier = multiplier * self:upgrade_value("player", "armor_regen_timer_multiplier_passive", 1)
	multiplier = multiplier * self:team_upgrade_value("armor", "regen_time_multiplier", 1)
	multiplier = multiplier * self:team_upgrade_value("armor", "passive_regen_time_multiplier", 1)
	multiplier = multiplier * self:upgrade_value("player", "perk_armor_regen_timer_multiplier", 1)

	if not moving then
		multiplier = multiplier * managers.player:upgrade_value("player", "armor_regen_timer_stand_still_multiplier", 1)
	end

	if health_ratio then
		local damage_health_ratio = self:get_damage_health_ratio(health_ratio, "armor_regen")
		multiplier = multiplier * (1 - managers.player:upgrade_value("player", "armor_regen_damage_health_ratio_multiplier", 0) * damage_health_ratio)
	end
	if deathvox and deathvox:IsTotalCrackdownEnabled() then
		if self:upgrade_value("player", "armorer_t9") == true then
			multiplier = multiplier + 0.25
		elseif self:upgrade_value("player", "armorer_t7") == true then
			multiplier = multiplier + 0.2
		elseif self:upgrade_value("player", "armorer_t5") == true then
			multiplier = multiplier + 0.15
		elseif self:upgrade_value("player", "armorer_t3") == true then
			multiplier = multiplier + 0.1
		elseif self:upgrade_value("player", "armorer_t1") == true then
			multiplier = multiplier + 0.05
		end
		if self:upgrade_value("player", "hitman_t7") == true then
			multiplier = multiplier + 0.7
		elseif self:upgrade_value("player", "hitman_t5") == true then
			multiplier = multiplier + 0.45
		elseif self:upgrade_value("player", "hitman_t3") == true then
			multiplier = multiplier + 0.25
		elseif self:upgrade_value("player", "hitman_t1") == true then
			multiplier = multiplier + 0.1
		end
		if self:wearing_crook_armor() then
			if self:upgrade_value("player", "crook_t6") == true then
				multiplier = multiplier + 0.4
			elseif self:upgrade_value("player", "crook_t2") == true then
				multiplier = multiplier + 0.2
			end
		end
		if self:has_team_category_upgrade("player", "crew_chief_t7") == true then
			multiplier = multiplier + 0.1
		end
	end
	return multiplier
end

function PlayerManager:body_armor_value(category, override_value, default)
	local armor_data = tweak_data.blackmarket.armors[managers.blackmarket:equipped_armor(true, true)]
	if category == "damage_shake" then
		local shake_it = self:upgrade_value_by_level("player", "body_armor", category, {})[override_value or armor_data.upgrade_level] or default or 0
		if deathvox and deathvox:IsTotalCrackdownEnabled() then
			if self:upgrade_value("player", "armorer_t2") == true then 
				return shake_it * 0.5
			else
				return shake_it
			end
		else
			return shake_it
		end
	else
		return self:upgrade_value_by_level("player", "body_armor", category, {})[override_value or armor_data.upgrade_level] or default or 0
	end
end

function PlayerManager:movement_speed_multiplier(speed_state, bonus_multiplier, upgrade_level, health_ratio)
	local multiplier = 1
	local armor_penalty = self:mod_movement_penalty(self:body_armor_value("movement", upgrade_level, 1))
	local fuckshit = (1 - armor_penalty) * 0.5
	if deathvox and deathvox:IsTotalCrackdownEnabled() then
		if self:upgrade_value("player", "armorer_t4") == true then
			armor_penalty = 1 - fuckshit
		end
	end
	multiplier = multiplier + armor_penalty - 1

	if bonus_multiplier then
		multiplier = multiplier + bonus_multiplier - 1
	end

	if speed_state then
		multiplier = multiplier + self:upgrade_value("player", speed_state .. "_speed_multiplier", 1) - 1
	end

	multiplier = multiplier + self:get_hostage_bonus_multiplier("speed") - 1
	multiplier = multiplier + self:upgrade_value("player", "movement_speed_multiplier", 1) - 1

	if self:num_local_minions() > 0 then
		multiplier = multiplier + self:upgrade_value("player", "minion_master_speed_multiplier", 1) - 1
	end

	if self:has_category_upgrade("player", "secured_bags_speed_multiplier") then
		local bags = 0
		bags = bags + (managers.loot:get_secured_mandatory_bags_amount() or 0)
		bags = bags + (managers.loot:get_secured_bonus_bags_amount() or 0)
		multiplier = multiplier + bags * (self:upgrade_value("player", "secured_bags_speed_multiplier", 1) - 1)
	end

	if managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier") then
		multiplier = multiplier * (tweak_data.upgrades.berserker_movement_speed_multiplier or 1)
	end

	if health_ratio then
		local damage_health_ratio = self:get_damage_health_ratio(health_ratio, "movement_speed")
		multiplier = multiplier * (1 + managers.player:upgrade_value("player", "movement_speed_damage_health_ratio_multiplier", 0) * damage_health_ratio)
	end

	local damage_speed_multiplier = managers.player:temporary_upgrade_value("temporary", "damage_speed_multiplier", managers.player:temporary_upgrade_value("temporary", "team_damage_speed_multiplier_received", 1))
	multiplier = multiplier * damage_speed_multiplier

	return multiplier
end

function PlayerManager:skill_dodge_chance(running, crouching, on_zipline, override_armor, detection_risk)
	local chance = self:upgrade_value("player", "passive_dodge_chance", 0)
	local dodge_shot_gain = self:_dodge_shot_gain()

	for _, smoke_screen in ipairs(self._smoke_screen_effects or {}) do
		if smoke_screen:is_in_smoke(self:player_unit()) then
			if smoke_screen:mine() then
				chance = chance * self:upgrade_value("player", "sicario_multiplier", 1)
				dodge_shot_gain = dodge_shot_gain * self:upgrade_value("player", "sicario_multiplier", 1)
			else
				chance = chance + smoke_screen:dodge_bonus()
			end
		end
	end

	chance = chance + dodge_shot_gain
	chance = chance + self:upgrade_value("player", "tier_dodge_chance", 0)

	if running then
		chance = chance + self:upgrade_value("player", "run_dodge_chance", 0)
	end

	if crouching then
		chance = chance + self:upgrade_value("player", "crouch_dodge_chance", 0)
	end

	if on_zipline then
		chance = chance + self:upgrade_value("player", "on_zipline_dodge_chance", 0)
	end

	local detection_risk_add_dodge_chance = managers.player:upgrade_value("player", "detection_risk_add_dodge_chance")
	chance = chance + self:get_value_from_risk_upgrade(detection_risk_add_dodge_chance, detection_risk)
	chance = chance + self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_dodge_addend", 0)
	chance = chance + self:upgrade_value("team", "crew_add_dodge", 0)
	chance = chance + self:temporary_upgrade_value("temporary", "pocket_ecm_kill_dodge", 0)
	if deathvox and deathvox:IsTotalCrackdownEnabled() then
		if self:upgrade_value("player", "rogue_t7") == true then
			chance = chance + 0.4
		elseif self:upgrade_value("player", "rogue_t5") == true then
			chance = chance + 0.3
		elseif self:upgrade_value("player", "rogue_t3") == true then
			chance = chance + 0.2
		elseif self:upgrade_value("player", "rogue_t1") == true then
			chance = chance + 0.1
		end
		if self:wearing_crook_armor() then
			if self:upgrade_value("player", "crook_t8") == true then
				chance = chance + 0.3
			elseif self:upgrade_value("player", "crook_t4") == true then
				chance = chance + 0.15
			end
		end
		local rogue_t9_dodge_boost = managers.player:upgrade_value("player", "rogue_t9")
		chance = chance + self:get_value_from_risk_upgrade(rogue_t9_dodge_boost, detection_risk)
	end
	log("dodge chance " .. chance)
		

	return chance
end
