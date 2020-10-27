function WeaponDescription.get_weapon_ammo_info(weapon_id, extra_ammo, total_ammo_mod)
	local weapon_tweak_data = tweak_data.weapon[weapon_id]
	local ammo_max_multiplier = managers.player:upgrade_value("player", "extra_ammo_multiplier", 1)
	local primary_category = weapon_tweak_data.categories[1]
	local category_skill_in_effect = false
	local category_multiplier = 1

	for _, category in ipairs(weapon_tweak_data.categories) do
		if managers.player:has_category_upgrade(category, "extra_ammo_multiplier") then
			category_multiplier = category_multiplier + managers.player:upgrade_value(category, "extra_ammo_multiplier", 1) - 1
			category_skill_in_effect = true
		end
	end
	local weapon_class = weapon_tweak_data.primary_class or ""
	local ammo_stock_bonus = 0
	if managers.blackmarket:equipped_deployable_slot("ammo_bag") then 
		ammo_stock_bonus = ammo_stock_bonus + managers.player:upgrade_value("ammo_bag","passive_ammo_stock_bonus",0)
	end
	
	ammo_stock_bonus = math.max(ammo_stock_bonus,managers.player:upgrade_value(weapon_class,"weapon_class_ammo_stock_bonus",0))
	category_skill_in_effect = category_skill_in_effect or (ammo_stock_bonus > 0)
	ammo_max_multiplier = ammo_max_multiplier + ammo_stock_bonus
	
	ammo_max_multiplier = ammo_max_multiplier * category_multiplier

	if managers.player:has_category_upgrade("player", "add_armor_stat_skill_ammo_mul") then
		ammo_max_multiplier = ammo_max_multiplier * managers.player:body_armor_value("skill_ammo_mul", nil, 1)
	end

	local function get_ammo_max_per_clip(weapon_id)
		local function upgrade_blocked(category, upgrade)
			if not weapon_tweak_data.upgrade_blocks then
				return false
			end

			if not weapon_tweak_data.upgrade_blocks[category] then
				return false
			end

			return table.contains(weapon_tweak_data.upgrade_blocks[category], upgrade)
		end

		local clip_base = weapon_tweak_data.CLIP_AMMO_MAX
		local clip_mod = extra_ammo and tweak_data.weapon.stats.extra_ammo[extra_ammo] or 0
		local clip_skill = managers.player:upgrade_value(weapon_id, "clip_ammo_increase")

		if not upgrade_blocked("weapon", "clip_ammo_increase") then
			clip_skill = clip_skill + managers.player:upgrade_value("weapon", "clip_ammo_increase", 0)
		end

		for _, category in ipairs(weapon_tweak_data.categories) do
			if not upgrade_blocked(category, "clip_ammo_increase") then
				clip_skill = clip_skill + managers.player:upgrade_value(category, "clip_ammo_increase", 0)
			end
		end

		return clip_base + clip_mod + clip_skill
	end

	local bonus_from_weapon_class = managers.player:upgrade_value(weapon_class,"clip_amount_increase",0)
	
	category_skill_in_effect = category_skill_in_effect or (bonus_from_weapon_class > 0)
	local ammo_max_per_clip = get_ammo_max_per_clip(weapon_id)
	local ammo_max = tweak_data.weapon[weapon_id].AMMO_MAX
	local ammo_from_mods = ammo_max * (total_ammo_mod and tweak_data.weapon.stats.total_ammo_mod[total_ammo_mod] or 0)
	ammo_max = ammo_max + ammo_from_mods + managers.player:upgrade_value(weapon_id, "clip_amount_increase") * ammo_max_per_clip * ammo_max_multiplier
	ammo_max_per_clip = math.min(ammo_max_per_clip, ammo_max)
	local ammo_data = {
		base = tweak_data.weapon[weapon_id].AMMO_MAX,
		mod = ammo_from_mods + managers.player:upgrade_value(weapon_id, "clip_amount_increase") * ammo_max_per_clip
	}
	ammo_data.skill = (ammo_max_per_clip * bonus_from_weapon_class) + (ammo_data.base + ammo_data.mod) * ammo_max_multiplier - ammo_data.base - ammo_data.mod
	ammo_data.skill_in_effect = managers.player:has_category_upgrade("player", "extra_ammo_multiplier") or category_skill_in_effect or managers.player:has_category_upgrade("player", "add_armor_stat_skill_ammo_mul")
	return ammo_max_per_clip, ammo_max, ammo_data
end