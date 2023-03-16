if deathvox:IsTotalCrackdownEnabled() then 
	
	local mvec3_distance = mvector3.distance
	local math_map_range_clamped = math.map_range_clamped
	
	function NewRaycastWeaponBase:conditional_accuracy_addend(current_state)
		local index = 0
		local primary_class = self:get_weapon_class()
		
		if not current_state then
			return index
		end

		local pm = managers.player
		
		local has_category = self._unit and alive(self._unit) and not self._unit:base().thrower_unit and self._unit:base().is_category
		
		if not current_state:in_steelsight() then
			index = index + pm:upgrade_value("player", "hip_fire_accuracy_inc", 0)
		elseif has_category and pm:player_unit() then 
			index = index + pm:upgrade_value(primary_class,"steelsight_accstab_bonus",0)
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
		
		if self:is_weapon_class("class_heavy") then 
			local bonus = pm:get_temporary_property("current_death_grips_stacks",0) * pm:upgrade_value("class_heavy","death_grips_spread_bonus",0)
			index = index + bonus
		end
		
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
		
		for _,subclass in pairs(self:get_weapon_subclasses()) do
			multiplier = multiplier + managers.player:upgrade_value(subclass,"enter_steelsight_speed_multiplier",1)
		end
		multiplier = multiplier * managers.player:upgrade_value(self:get_weapon_class() or "","enter_steelsight_speed_multiplier",1)
		
		
		return self:_convert_add_to_mul(multiplier)
	end
	
	function NewRaycastWeaponBase:reload_speed_multiplier(multiplier)
		multiplier = multiplier or 1
		local shell_games_bonus = 1
		local pm = managers.player
		
		local pm = managers.player
		
		if pm:player_unit():character_damage().swansong then
			return 99
		end
		
		if self._use_shotgun_reload then 
			shell_games_bonus = pm:upgrade_value("class_shotgun","shell_games_reload_bonus",0) * pm:get_property("shell_games_rounds_loaded",0)
		end
		
		if self._current_reload_speed_multiplier then
			return self._current_reload_speed_multiplier + shell_games_bonus
		end
		
		for _, category in ipairs(self:weapon_tweak_data().categories) do
			multiplier = multiplier + 1 - pm:upgrade_value(category, "reload_speed_multiplier", 1)
		end
		
		if self:is_weapon_class("class_precision") then
			local this_machine_data = pm:upgrade_value("weapon","point_and_click_bonus_reload_speed",{0,0})
			multiplier = multiplier * (1 - math.min(this_machine_data[1] * pm:get_property("current_point_and_click_stacks",0),this_machine_data[2]))
		elseif self:is_weapon_class("class_shotgun") then 
			if managers.player:has_category_upgrade("class_shotgun", "shell_games_reload_bonus") then
				multiplier = multiplier + 0.2
			end
		end

		multiplier = multiplier + 1 - pm:upgrade_value("weapon", "passive_reload_speed_multiplier", 1)
		multiplier = multiplier + 1 - pm:upgrade_value(self._name_id, "reload_speed_multiplier", 1)

		if self._setup and alive(self._setup.user_unit) and self._setup.user_unit:movement() then
			local morale_boost_bonus = self._setup.user_unit:movement():morale_boost()

			if morale_boost_bonus then
				multiplier = multiplier + 1 - morale_boost_bonus.reload_speed_bonus
			end

			if self._setup.user_unit:movement():next_reload_speed_multiplier() then
				multiplier = multiplier + 1 - self._setup.user_unit:movement():next_reload_speed_multiplier()
			end
		end

		if pm:has_activate_temporary_upgrade("temporary", "reload_weapon_faster") then
			multiplier = multiplier + 1 - pm:temporary_upgrade_value("temporary", "reload_weapon_faster", 1)
		end

		if pm:has_activate_temporary_upgrade("temporary", "single_shot_fast_reload") then
			multiplier = multiplier + 1 - pm:temporary_upgrade_value("temporary", "single_shot_fast_reload", 1)
		end

		multiplier = multiplier + 1 - pm:get_property("shock_and_awe_reload_multiplier", 1)
		multiplier = multiplier + 1 - pm:get_temporary_property("bloodthirst_reload_speed", 1)
		multiplier = multiplier + 1 - pm:upgrade_value("team", "crew_faster_reload", 1)
		multiplier = self:_convert_add_to_mul(multiplier)
		
		if self:is_weapon_class("class_heavy") then
			local lead_farmer_data = pm:upgrade_value("class_heavy","lead_farmer",{0,0})
			local lead_farmer_bonus = math.min(pm:get_property("current_lead_farmer_stacks",0) * lead_farmer_data[1],lead_farmer_data[2])
			multiplier = multiplier + lead_farmer_bonus
		end
		
		multiplier = multiplier + shell_games_bonus
		if self:clip_empty() then
			--money shot aced reload speed
			multiplier = multiplier + pm:upgrade_value(self:get_weapon_class(), "empty_magazine_reload_speed_bonus", 0)
		end
		
		multiplier = multiplier * self:reload_speed_stat()
		
		multiplier = managers.modifiers:modify_value("WeaponBase:GetReloadSpeedMultiplier", multiplier)
		
		return multiplier
	end

	function NewRaycastWeaponBase:update_reloading(t, dt, time_left)
		if self._use_shotgun_reload and self._next_shell_reloded_t and self._next_shell_reloded_t < t then
			local speed_multiplier = self:reload_speed_multiplier()
			managers.player:add_to_property("shell_games_rounds_loaded",1)
			self._next_shell_reloded_t = self._next_shell_reloded_t + self:reload_shell_expire_t() / speed_multiplier
			self:set_ammo_remaining_in_clip(math.min(self:get_ammo_max_per_clip(), self:get_ammo_remaining_in_clip() + 1))
			managers.job:set_memory("kill_count_no_reload_" .. tostring(self._name_id), nil, true)

			return true,self:clip_full()
		end
	end

	function NewRaycastWeaponBase:calculate_ammo_max_per_clip()
		local added = 0
		local weapon_tweak_data = self:weapon_tweak_data()

		if self:is_category("shotgun") and tweak_data.weapon[self._name_id].has_magazine then
			added = managers.player:upgrade_value("shotgun", "magazine_capacity_inc", 0)

			if self:is_category("akimbo") then
				added = added * 2
			end
		elseif self:is_category("pistol") and not self:is_category("revolver") and managers.player:has_category_upgrade("pistol", "magazine_capacity_inc") then
			added = managers.player:upgrade_value("pistol", "magazine_capacity_inc", 0)

			if self:is_category("akimbo") then
				added = added * 2
			end
		elseif self:is_category("smg", "assault_rifle", "lmg") then
			added = managers.player:upgrade_value("player", "automatic_mag_increase", 0)

			if self:is_category("akimbo") then
				added = added * 2
			end
		end
		
		local ammo = tweak_data.weapon[self._name_id].CLIP_AMMO_MAX + added
		ammo = ammo + managers.player:upgrade_value(self._name_id, "clip_ammo_increase")

		if not self:upgrade_blocked("weapon", "clip_ammo_increase") then
			ammo = ammo + managers.player:upgrade_value("weapon", "clip_ammo_increase", 0)
		end

		for _, category in ipairs(tweak_data.weapon[self._name_id].categories) do
			if not self:upgrade_blocked(category, "clip_ammo_increase") then
				ammo = ammo + managers.player:upgrade_value(category, "clip_ammo_increase", 0)
			end
		end

		ammo = ammo + (self._extra_ammo or 0)
		
		if self:is_weapon_class("class_shotgun") then 
			if tweak_data.weapon[self._name_id].FIRE_MODE == "auto" then
				ammo = math.ceil(ammo * (1 + managers.player:upgrade_value("class_shotgun","rolling_thunder_magazine_capacity_bonus",0)))
			end
		end
		
		return ammo
	end
	
	function NewRaycastWeaponBase:can_toggle_firemode()
		if self:gadget_overrides_weapon_functions() then
			return self:gadget_function_override("can_toggle_firemode")
		end
		
		if tweak_data.weapon[self._name_id].CAN_TOGGLE_FIREMODE then 
			return true
		elseif self:is_weapon_class("class_shotgun") then 
			if tweak_data.weapon[self._name_id].CLIP_AMMO_MAX == 2 then 
				return managers.player:has_category_upgrade("class_shotgun","heartbreaker_doublebarrel")
			end
		end
		return false
	end

	function NewRaycastWeaponBase:on_reload_stop()
		self._bloodthist_value_during_reload = 0
		self._current_reload_speed_multiplier = nil
		local user_unit = managers.player:player_unit()

		if user_unit then
			user_unit:movement():current_state():send_reload_interupt()
		end

		self:set_reload_objects_visible(false)

		self._reload_objects = {}
		managers.player:set_property("shell_games_rounds_loaded",0)
	end

	function NewRaycastWeaponBase:recoil_wait()
		local tweak_is_auto = tweak_data.weapon[self._name_id].FIRE_MODE == "auto"
		local weapon_is_auto = self:fire_mode() == "auto"

		local doubledouble
		if weapon_is_auto then 
			if self:is_weapon_class("class_shotgun") then 
				if tweak_data.weapon[self._name_id].CLIP_AMMO_MAX == 2 then 
					if managers.player:has_category_upgrade("class_shotgun","heartbreaker_doublebarrel") then 
						doubledouble = true
						--double-shots with double-barreled shotguns should not have double recoil
						--in theory it sounds great, but in practice it just looks bad
						--since it drags your camera up for twice as long but not twice as fast
					end
				end
			end
		end
		
		if not (doubledouble or tweak_is_auto) then
			return nil
		end
		
		local multiplier = ((doubledouble or (tweak_is_auto == weapon_is_auto)) and 1 or 2)

		return self:weapon_tweak_data().fire_mode_data.fire_rate * multiplier
	end

	function NewRaycastWeaponBase:get_add_head_shot_mul(special)
		if not special or managers.player:has_category_upgrade("class_shotgun", "grand_brachial_bodyshots") and special ~= "tank" then
			if self:is_weapon_class("class_shotgun") and managers.player:has_category_upgrade("class_shotgun","tender_meat_bodyshots") then 
				return managers.player:upgrade_value("class_shotgun","tender_meat_bodyshots",0)
			end
		end
		
		if self:is_category("smg", "lmg", "assault_rifle", "minigun") and self._fire_mode == ids_auto or self:is_category("bow", "saw") then
			return managers.player:upgrade_value("weapon", "automatic_head_shot_add", nil)
		end
		return nil
	end

	function NewRaycastWeaponBase:replenish()
		local ammo_max_multiplier = managers.player:upgrade_value("player", "extra_ammo_multiplier", 1)

		for _, category in ipairs(self:weapon_tweak_data().categories) do
			ammo_max_multiplier = ammo_max_multiplier * managers.player:upgrade_value(category, "extra_ammo_multiplier", 1)
		end

		ammo_max_multiplier = ammo_max_multiplier + ammo_max_multiplier * (self._total_ammo_mod or 0)

		if managers.player:has_category_upgrade("player", "add_armor_stat_skill_ammo_mul") then
			ammo_max_multiplier = ammo_max_multiplier * managers.player:body_armor_value("skill_ammo_mul", nil, 1)
		end
		
		local ammo_stock_bonus = 0
		if managers.blackmarket:equipped_deployable_slot("ammo_bag") then 
			ammo_stock_bonus = ammo_stock_bonus + managers.player:upgrade_value("ammo_bag","passive_ammo_stock_bonus",0)
		end
		ammo_stock_bonus = math.max(ammo_stock_bonus,managers.player:upgrade_value(self:get_weapon_class() or "","weapon_class_ammo_stock_bonus",0))
		ammo_max_multiplier = ammo_max_multiplier + ammo_stock_bonus

		ammo_max_multiplier = managers.modifiers:modify_value("WeaponBase:GetMaxAmmoMultiplier", ammo_max_multiplier)
		local ammo_max_per_clip = self:calculate_ammo_max_per_clip()
		local ammo_max_base = 
			(self._total_ammo_add or 0)
			+ tweak_data.weapon[self._name_id].AMMO_MAX
			+ (managers.player:upgrade_value(self._name_id, "clip_amount_increase",0)
			+ managers.player:upgrade_value(self:get_weapon_class() or "","clip_amount_increase",0))
			* ammo_max_per_clip
			
			
			
		local ammo_max = math.round(ammo_max_base * ammo_max_multiplier)
		ammo_max_per_clip = math.min(ammo_max_per_clip, ammo_max)

		self:set_ammo_max_per_clip(ammo_max_per_clip)
		self:set_ammo_max(ammo_max)
		self:set_ammo_total(ammo_max)
		self:set_ammo_remaining_in_clip(ammo_max_per_clip)

		self._ammo_pickup = tweak_data.weapon[self._name_id].AMMO_PICKUP
		local weapon_id = self:get_name_id()
		if weapon_id == "ray" then
			self._ammo_pickup = managers.player:upgrade_value("weapon","ray_ammo_pickup_modifier",self._ammo_pickup)
		elseif weapon_id == "rpg7" then 
			self._ammo_pickup = managers.player:upgrade_value("weapon","rpg7_ammo_pickup_modifier",self._ammo_pickup)
		end
		if self:is_category("flamethrower") then 
			self._ammo_pickup = managers.player:upgrade_value("weapon","flamethrower_ammo_pickup_modifier",self._ammo_pickup)
		end

		if self._assembly_complete then
			for _, gadget in ipairs(self:get_all_override_weapon_gadgets()) do
				if gadget and gadget.replenish then
					gadget:replenish()
				end
			end
		end

		self:update_damage()
	end
	
	function NewRaycastWeaponBase:fire_rate_multiplier()
		local rof_mul = self._fire_rate_multiplier or 1
		if self:is_weapon_class("class_precision") then
			local tap_the_trigger_data = managers.player:upgrade_value("weapon","point_and_click_rof_bonus",{0,0})
			rof_mul = rof_mul * (1 + math.min(tap_the_trigger_data[1] * managers.player:get_property("current_point_and_click_stacks",0),tap_the_trigger_data[2]))
		elseif self:is_weapon_class("class_shotgun") and self:fire_mode() == "single" then 
			rof_mul = rof_mul + managers.player:upgrade_value("class_shotgun","shell_games_rof_bonus",0)
		end
		return rof_mul
	end
	
	function NewRaycastWeaponBase:get_damage_falloff(damage, col_ray, user_unit)
		if self._optimal_distance + self._optimal_range == 0 then
			return damage
		end
		
		local ammo_data = self._ammo_data
		if ammo_data and ammo_data.no_falloff then
			return damage
		end
		
		local distance = col_ray.distance or mvec3_distance(col_ray.unit:position(), user_unit:position())
		local near_dist = self._optimal_distance - self._near_falloff
		local optimal_start = self._optimal_distance
		local optimal_end = self._optimal_distance + self._optimal_range
		local far_dist = optimal_end + self._far_falloff
		local near_mul = self._near_mul
		local optimal_mul = 1
		local far_mul = self._far_mul
		local primary_category = self:weapon_tweak_data().categories and self:weapon_tweak_data().categories[1]
		local current_state = user_unit and user_unit:movement() and user_unit:movement()._current_state

		if current_state and current_state:in_steelsight() then
			local mul = managers.player:upgrade_value(primary_category, "steelsight_range_inc", 1)
			optimal_end = optimal_end * mul
			far_dist = far_dist * mul
		end

		local damage_mul = 1

		if distance < self._optimal_distance then
			if self._near_falloff > 0 then
				damage_mul = math_map_range_clamped(distance, near_dist, optimal_start, near_mul, optimal_mul)
			else
				damage_mul = near_mul
			end
		elseif distance < optimal_end then
			damage_mul = optimal_mul
		elseif self._far_falloff > 0 then
			damage_mul = math_map_range_clamped(distance, optimal_end, far_dist, optimal_mul, far_mul)
		else
			damage_mul = far_mul
		end

		return damage * damage_mul
	end

	Hooks:PostHook(NewRaycastWeaponBase,"_update_stats_values","tcd_newraycastweaponbase_update_custom_stats",function(self,disallow_replenish,ammo_data)
		local factory_id = self._factory_id
		local wftd = tweak_data.weapon.factory.parts
		local total_ammo_add = 0
		for _,part_id in pairs(self._blueprint) do 
			local part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(part_id, factory_id, self._blueprint)
			if part_data.custom_stats then 
				if part_data.custom_stats.total_ammo_add then
					total_ammo_add = part_data.custom_stats.total_ammo_add + total_ammo_add
				end
			end
		end
		self._total_ammo_add = total_ammo_add
		
	end)
	
end