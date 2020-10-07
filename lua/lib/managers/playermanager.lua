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

if deathvox:IsTotalCrackdownEnabled() then
	Hooks:PostHook(PlayerManager,"check_skills","deathvox_check_cd_skills",function(self)

		self:set_property("current_point_and_click_stacks",0)
		if self:has_category_upgrade("player","point_and_click_stacks") then 
			self._message_system:register(Message.OnEnemyShot,"proc_point_and_click",function(unit,attack_data)
				local player = self:local_player()
				if not alive(player) then 
					return
				end
				local weapon_base = attack_data and attack_data.weapon_unit and attack_data.weapon_unit:base()
				if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_category("precision") then 
					if weapon_base._setup.user_unit ~= player then 
						return
					end
				else
					return
				end
				self:add_to_property("current_point_and_click_stacks",self:upgrade_value("player","point_and_click_stacks",0))
			end)
			if self:has_category_upgrade("player","point_and_click_stack_from_kill") then 
				self._message_system:register(Message.OnEnemyKilled,"proc_investment_returns_basic",function(weapon_unit,variant,killed_unit)
					local player = self:local_player()
					if not alive(player) then 
						return
					end
					local weapon_base = weapon_unit and weapon_unit:base()
					if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_category("precision") then 
						if weapon_base._setup.user_unit ~= player then 
							return
						end
					else
						return
					end
					self:add_to_property("current_point_and_click_stacks",self:upgrade_value("player","point_and_click_stack_from_kill",0))
				end)
			else
				self._message_system:unregister(Message.OnEnemyKilled,"proc_investment_returns_basic")
			end
			
			if self:has_category_upgrade("player","point_and_click_stack_from_headshot_kill") then 
				self._message_system:register(Message.OnLethalHeadShot,"proc_investment_returns_aced",function(attack_data)
					local player = self:local_player()
					if not alive(player) then 
						return
					end
					local weapon_base = attack_data and attack_data.weapon_unit and attack_data.weapon_unit:base()
					if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_category("precision") then 
						if weapon_base._setup.user_unit ~= player then 
							return
						end
					else
						return
					end
					self:add_to_property("current_point_and_click_stacks",self:upgrade_value("player","point_and_click_stack_from_headshot_kill",0))
				end)
			else
				self._message_system:unregister(Message.OnLethalHeadShot,"proc_investment_returns_aced")
			end
			
			if self:has_category_upgrade("player","point_and_click_stack_mulligan") then 
				self._message_system:register(Message.OnEnemyKilled,"proc_mulligan_reprieve",function(weapon_unit,variant,killed_unit)
					local player = self:local_player()
					if not alive(player) then 
						return
					end
					local weapon_base = weapon_unit and weapon_unit:base()
					if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_category("precision") then 
						if weapon_base._setup.user_unit ~= player then 
							return
						end
					else
						return
					end
					
					managers.enemy:remove_delayed_clbk("point_and_click_on_shot_missed",true)
				end)
			else
				self._message_system:unregister(Message.OnEnemyKilled,"proc_mulligan_reprieve")
			end
			
			self._message_system:register(Message.OnWeaponFired,"clear_point_and_click_stacks",function(weapon_unit,result)
				if result and result.hit_enemy then
					return
				end
				
				local player = self:local_player()
				if not alive(player) then 
					return
				end
				
				local weapon_base = weapon_unit and weapon_unit:base()
				if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_category("precision") then 
					if weapon_base._setup.user_unit ~= player then 
						return
					end
				else
					return
				end
				
				if not managers.enemy:is_clbk_registered("point_and_click_on_shot_missed") then 
					managers.enemy:add_delayed_clbk("point_and_click_on_shot_missed",callback(self,self,"set_property","current_point_and_click_stacks",0),
						Application:time() + self:upgrade_value("player","point_and_click_stack_mulligan",0)
					)
				end
			end)
		else
			self._message_system:unregister(Message.OnEnemyShot,"proc_point_and_click")
			self._message_system:unregister(Message.OnWeaponFired,"clear_point_and_click_stacks")
		end
		
		if self:has_category_upgrade("weapon","magic_bullet") then 
			self._message_system:register(Message.OnLethalHeadShot,"proc_magic_bullet",function(attack_data)
				local player = self:local_player()
				if not alive(player) then 
					return
				end
				local weapon_base = attack_data.weapon_unit and attack_data.weapon_unit:base()
				if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_category("precision") then 
					if weapon_base._setup.user_unit ~= player then 
						return
					end
				else
					return
				end
				
				if not weapon_base:ammo_full() then 
					local magic_bullet_level = self:upgrade_level("weapon","magic_bullet",0) 
					local weapon_ammo = weapon_base:ammo_base()
					local clip_current = weapon_ammo:get_ammo_remaining_in_clip()
					local clip_max = weapon_ammo:get_ammo_max_per_clip()
					local weapon_index = self:equipped_weapon_index()
					if (magic_bullet_level == 2) and (clip_current < clip_max) then
						weapon_ammo:set_ammo_remaining_in_clip(math.min(clip_max,clip_current + self:upgrade_value("weapon","magic_bullet",0)))
					else
						weapon_ammo:add_ammo_to_pool(self:upgrade_value("weapon","magic_bullet",0),self:equipped_weapon_index())
					end
					managers.hud:set_ammo_amount(weapon_index, weapon_base:ammo_info())
					player:sound():play("pickup_ammo")
				end
			end)
		else
			self._message_system:unregister(Message.OnLethalHeadShot,"proc_magic_bullet")
		end
		
	end)

	function PlayerManager:on_headshot_dealt()
		local player_unit = self:player_unit()

		if not player_unit then
			return
		end

		self._message_system:notify(Message.OnHeadShot, nil, nil)
		
		local t = Application:time()
		
		if self._miracle_crit_chance_boost_t then
			if self._miracle_crit_chance_boost_t < t then
				--log("the witch hunts are over")
				self._miracle_crit_chance_boost = nil
				self._miracle_crit_chance_boost_t = nil
			end
		end
		
		if self:has_category_upgrade("player", "making_miracles_basic") then
			local miracle_crit_boost_max = 0.1
			local chance_to_add = 0.01
				
			if self:has_category_upgrade("player", "making_miracles_aced") then
				miracle_crit_boost_max = 0.2
			end
			
			if not self._miracle_crit_chance_boost then
				self._miracle_crit_chance_boost = chance_to_add
			else
				self._miracle_crit_chance_boost = math.min(self._miracle_crit_chance_boost + chance_to_add, miracle_crit_boost_max)
			end
			
			self._miracle_crit_chance_boost_t = t + 4
		end

		if self._on_headshot_dealt_t and t < self._on_headshot_dealt_t then
			return
		end

		self._on_headshot_dealt_t = t + (tweak_data.upgrades.on_headshot_dealt_cooldown or 0)
		local damage_ext = player_unit:character_damage()
		local regen_armor_bonus = managers.player:upgrade_value("player", "headshot_regen_armor_bonus", 0)

		if damage_ext and regen_armor_bonus > 0 then
			damage_ext:restore_armor(regen_armor_bonus)
		end
	end

	function PlayerManager:on_killshot(killed_unit, variant, headshot, weapon_id)
		local player_unit = self:player_unit()

		if not player_unit then
			return
		end

		if CopDamage.is_civilian(killed_unit:base()._tweak_table) then
			return
		end

		local weapon_melee = weapon_id and tweak_data.blackmarket and tweak_data.blackmarket.melee_weapons and tweak_data.blackmarket.melee_weapons[weapon_id] and true

		if killed_unit:brain().surrendered and killed_unit:brain():surrendered() and (variant == "melee" or weapon_melee) then
			managers.custom_safehouse:award("daily_honorable")
		end

		managers.modifiers:run_func("OnPlayerManagerKillshot", player_unit, killed_unit:base()._tweak_table, variant)

		local equipped_unit = self:get_current_state()._equipped_unit
		self._num_kills = self._num_kills + 1

		if self._num_kills % self._SHOCK_AND_AWE_TARGET_KILLS == 0 and self:has_category_upgrade("player", "automatic_faster_reload") then
			self:_on_enter_shock_and_awe_event()
		end

		self._message_system:notify(Message.OnEnemyKilled, nil, equipped_unit, variant, killed_unit)

		if self._saw_panic_when_kill and variant ~= "melee" then
			local equipped_unit = self:get_current_state()._equipped_unit:base()

			if equipped_unit:is_category("saw") then
				local pos = player_unit:position()
				local skill = self:upgrade_value("saw", "panic_when_kill")

				if skill and type(skill) ~= "number" then
					local area = skill.area
					local chance = skill.chance
					local amount = skill.amount
					local enemies = World:find_units_quick("sphere", pos, area, 12, 21)

					for i, unit in ipairs(enemies) do
						if unit:character_damage() then
							unit:character_damage():build_suppression(amount, chance)
						end
					end
				end
			end
		end

		local t = Application:time()
		
		if self._miracle_crit_chance_boost_t then
			if self._miracle_crit_chance_boost_t < t then
				--log("the witch hunts are over")
				self._miracle_crit_chance_boost = nil
				self._miracle_crit_chance_boost_t = nil
			end
		end
		
		if self:has_category_upgrade("player", "making_miracles_basic") then
			local miracle_crit_boost_max = 0.1
			local chance_to_add = 0.01
				
			if self:has_category_upgrade("player", "making_miracles_aced") then
				chance_to_add = 0.02
				miracle_crit_boost_max = 0.2
			end
			
			if not self._miracle_crit_chance_boost then
				self._miracle_crit_chance_boost = chance_to_add
			else
				self._miracle_crit_chance_boost = math.min(self._miracle_crit_chance_boost + chance_to_add, miracle_crit_boost_max)
			end
			
			self._miracle_crit_chance_boost_t = t + 4
		end
		
		local damage_ext = player_unit:character_damage()

		if self:has_category_upgrade("player", "kill_change_regenerate_speed") then
			local amount = self:body_armor_value("skill_kill_change_regenerate_speed", nil, 1)
			local multiplier = self:upgrade_value("player", "kill_change_regenerate_speed", 0)

			damage_ext:change_regenerate_speed(amount * multiplier, tweak_data.upgrades.kill_change_regenerate_speed_percentage)
		end

		local gain_throwable_per_kill = managers.player:upgrade_value("team", "crew_throwable_regen", 0)

		if gain_throwable_per_kill ~= 0 then
			self._throw_regen_kills = (self._throw_regen_kills or 0) + 1

			if gain_throwable_per_kill < self._throw_regen_kills then
				managers.player:add_grenade_amount(1, true)

				self._throw_regen_kills = 0
			end
		end

		if self._on_killshot_t and t < self._on_killshot_t then
			return
		end

		local regen_armor_bonus = self:upgrade_value("player", "killshot_regen_armor_bonus", 0)
		local dist_sq = mvector3.distance_sq(player_unit:movement():m_pos(), killed_unit:movement():m_pos())
		local close_combat_sq = tweak_data.upgrades.close_combat_distance * tweak_data.upgrades.close_combat_distance

		if dist_sq <= close_combat_sq then
			regen_armor_bonus = regen_armor_bonus + self:upgrade_value("player", "killshot_close_regen_armor_bonus", 0)
			local panic_chance = self:upgrade_value("player", "killshot_close_panic_chance", 0)
			panic_chance = managers.modifiers:modify_value("PlayerManager:GetKillshotPanicChance", panic_chance)

			if panic_chance > 0 or panic_chance == -1 then
				local slotmask = managers.slot:get_mask("enemies")
				local units = World:find_units_quick("sphere", player_unit:movement():m_pos(), tweak_data.upgrades.killshot_close_panic_range, slotmask)

				for e_key, unit in pairs(units) do
					if alive(unit) and unit:character_damage() and not unit:character_damage():dead() then
						unit:character_damage():build_suppression(0, panic_chance)
					end
				end
			end
		end

		if damage_ext and regen_armor_bonus > 0 then
			damage_ext:restore_armor(regen_armor_bonus)
		end

		local regen_health_bonus = 0

		if variant == "melee" then
			regen_health_bonus = regen_health_bonus + self:upgrade_value("player", "melee_kill_life_leech", 0)
		end

		if damage_ext and regen_health_bonus > 0 then
			damage_ext:restore_health(regen_health_bonus)
		end

		self._on_killshot_t = t + (tweak_data.upgrades.on_killshot_cooldown or 0)

		if _G.IS_VR then
			local steelsight_multiplier = equipped_unit:base():enter_steelsight_speed_multiplier()
			local stamina_percentage = (steelsight_multiplier - 1) * tweak_data.vr.steelsight_stamina_regen
			local stamina_regen = player_unit:movement():_max_stamina() * stamina_percentage

			player_unit:movement():add_stamina(stamina_regen)
		end
	end
	
end