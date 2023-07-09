local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3_distance_sq
local mvec3_copy = mvector3.copy
local pairs_g = pairs
local alive_g = alive
local world_g = World

local TCD_ENABLED = deathvox:IsTotalCrackdownEnabled()

Hooks:PostHook(PlayerManager,"_internal_load","deathvox_on_internal_load",function(self)
--this will send whenever the player respawns, so... hm. 
	if Network:is_server() then 
		deathvox:SyncOptionsToClients()
	else
		deathvox:ResetSessionSettings()
	end
--	Hooks:Call("TCD_OnGameStarted")

	if TCD_ENABLED then 
		local grenade = managers.blackmarket:equipped_grenade()
		self:_set_grenade({
			grenade = grenade,
			amount = self:get_max_grenades() --for some reason, in vanilla, spawn amount is math.min()'d with the DEFAULT amount 
		})
		
		local ability_id,max_amount = managers.blackmarket:equipped_ability()
		if ability_id then
			
			if self:has_category_upgrade(ability_id,"amount_increase") then
				max_amount = max_amount * self:upgrade_value(ability_id,"amount_increase")
			end
			
			self:_set_ability({
				ability = ability_id,
				amount = max_amount,
				max_amount = max_amount
			})
		end
		if self:has_category_upgrade("player","cocaine_stacking") then
			local max_stacks = self:upgrade_value("player","mania_max_stacks",0)
			managers.hud:set_info_meter(nil, {
				icon = "guis/dlcs/coco/textures/pd2/hud_absorb_stack_icon_01",
				max = 1,
				current = 0,
				total = max_stacks / tweak_data.upgrades.values.player.mania_max_stacks[#tweak_data.upgrades.values.player.mania_max_stacks]
			})
		end
	end
end)

function PlayerManager:_chk_fellow_crimin_proximity(unit)
	local players_nearby = 0
		
	local criminals = world_g:find_units_quick(unit, "sphere", unit:position(), 1500, managers.slot:get_mask("criminals_no_deployables"))

	for i = 1, #criminals do
		players_nearby = players_nearby + 1
	end
		
	if players_nearby <= 0 then
		--log("uhohstinky")
	end
		
	return players_nearby
end

--function written for cd, not vanilla
function PlayerManager:team_upgrade_value_by_level(category, upgrade, level, default)
	local cat = tweak_data.upgrades.values.team[category]
	local upg = cat and cat[upgrade]
	return upg and upg[level] or default
end

--function written for cd, not vanilla
function PlayerManager:team_upgrade_level(category, upgrade, default)
	for peer_id, categories in pairs(self._global.synced_team_upgrades) do
		if categories[category] and categories[category][upgrade] then
			return categories[category][upgrade]
		end
	end

	if not self._global.team_upgrades[category] then
		return default or 0
	end

	if not self._global.team_upgrades[category][upgrade] then
		return default or 0
	end

	return self._global.team_upgrades[category][upgrade]
end


Hooks:PostHook(PlayerManager,"init","tcd_playermanager_init",function(self)
	self._damage_overshield = {}
	self._can_lunge = true
	Global.player_manager.synced_abilities = {} --not actually synced atm
end)

if TCD_ENABLED then
	Hooks:Register("TCD_OnCriminalDowned")
	
	function PlayerManager:use_messiah_charge()
		--nothing
	end
	
	--replenish ability instead of grenades
	function PlayerManager:_on_grenade_cooldown_end()
		local ability,_ = managers.blackmarket:equipped_ability()
		local tweak = tweak_data.blackmarket.projectiles[ability]

		if tweak and tweak.sounds and tweak.sounds.cooldown then
			self:player_unit():sound():play(tweak.sounds.cooldown)
		end

		self:add_ability_amount(1)
	end
	
	function PlayerManager:speed_up_grenade_cooldown(time)
		local timer = self._timers.replenish_grenades

		if not timer then
			return
		end

		timer.t = timer.t - time
		local peer_id = managers.network:session():local_peer():id()
		local ability = self._global.synced_abilities[peer_id].ability
		local tweak = ability and tweak_data.blackmarket.projectiles[ability]
		if tweak then
			local time_left = self:get_timer_remaining("replenish_grenades") or 0

			managers.hud:set_player_grenade_cooldown({
				end_time = managers.game_play_central:get_heist_timer() + time_left,
				duration = tweak.base_cooldown
			})
		end
	end
	
	function PlayerManager:_set_ability(params)
		self._global.synced_abilities[managers.network:session():local_peer():id()] = {
			ability = params.ability,
			amount = params.amount,
			max_amount = params.max_amount
		}
		
		local tweak = params.ability and tweak_data.blackmarket.projectiles[params.ability]
		local icon = tweak and tweak.icon
		if icon then
			managers.hud:set_ability_icon(HUDManager.PLAYER_PANEL,icon)
		end
		--self:update_ability_amount_to_peers(grenade, amount)
	end
	
	--added in tcd;
	--returns the number of charges for the current perkdeck ability
	function PlayerManager:get_ability_amount(peer_id)
		local data = self._global.synced_abilities[peer_id or managers.network:session():local_peer():id()]
		if data then
			return data.amount
		end
		return nil
	end
	
	function PlayerManager:add_ability_amount(num)
		local peer_id = managers.network:session():local_peer():id()
		local data = self._global.synced_abilities[peer_id]
		if data then
			data.amount = data.amount + num
			local ability = data.ability
			local tweak = ability and tweak_data.blackmarket.projectiles[ability]
			local max_amount = data.max_amount or tweak and tweak.max_amount
			if max_amount and tweak.base_cooldown and data.amount < max_amount then
				self:replenish_grenades(tweak.base_cooldown)
			end
		end
	end
	
	function PlayerManager:attempt_ability(ability)
		if not self:player_unit() then
			return false
		end
		
		local local_peer_id = managers.network:session():local_peer():id()
		local has_no_charges = self:get_ability_amount(local_peer_id) == 0
		local blocked_by_downed = game_state_machine:verify_game_state(GameStateFilters.downed)
		blocked_by_downed = blocked_by_downed and not self:has_category_upgrade("player", "activate_ability_downed")

		if has_no_charges or blocked_by_downed then
			return false
		end

		local attempt_func = self["_attempt_" .. ability]

		if attempt_func and not attempt_func(self) then
			return false
		end

		local tweak = tweak_data.blackmarket.projectiles[ability]

		if tweak and tweak.sounds and tweak.sounds.activate then
			self:player_unit():sound():play(tweak.sounds.activate)
		end

		self:add_ability_amount(-1)
		self._message_system:notify("ability_activated", nil, ability)

		return true
	end
	
	function PlayerManager:_attempt_chico_injector()
		if self:has_activate_temporary_upgrade("temporary", "chico_injector") then
			return false
		end

		local duration = self:upgrade_value("temporary", "chico_injector")[2] + self:upgrade_value("player","kingpin_injector_duration_increase",0)
		local now = managers.game_play_central:get_heist_timer()

		managers.network:session():send_to_peers("sync_ability_hud", now + duration, duration)
		self:activate_temporary_upgrade("temporary", "chico_injector")
		
		if self:has_category_upgrade("player","kingpin_cooldown_drain_on_kill") then
			local cooldown_amount = self:upgrade_value("player","kingpin_cooldown_drain_on_kill",1)
			
			local function speed_up_on_kill()
				managers.player:speed_up_grenade_cooldown(cooldown_amount)
			end
			self:register_message(Message.OnEnemyKilled, "speed_up_chico_injector", speed_up_on_kill)
		end


		return true
	end
	
	function PlayerManager:stamina_multiplier()
		local multiplier = 1
		multiplier = multiplier + self:upgrade_value("player", "sociopath_stamina_mul", 1) - 1
		multiplier = multiplier + self:upgrade_value("player", "stamina_multiplier", 1) - 1
		multiplier = multiplier + self:team_upgrade_value("stamina", "multiplier", 1) - 1
		multiplier = multiplier + self:team_upgrade_value("stamina", "passive_multiplier", 1) - 1
		multiplier = multiplier + self:get_hostage_bonus_multiplier("stamina") - 1
		if self:has_category_upgrade("player", "armorer_stamina_penalty_reduction") then
			--local armor_data = tweak_data.blackmarket.armors
			--local equipped_armor = armor_data[managers.blackmarket:equipped_armor(true, true)]
			local current_armor_stamina_mul = self:body_armor_value("stamina")
			local suit_stamina_mul = self:body_armor_value("stamina",1)
			if suit_stamina_mul > current_armor_stamina_mul then
				local d_stamina_mul = suit_stamina_mul - current_armor_stamina_mul
				multiplier = multiplier + d_stamina_mul * self:upgrade_value("player", "armorer_stamina_penalty_reduction",0)
			end
		end
		multiplier = managers.modifiers:modify_value("PlayerManager:GetStaminaMultiplier", multiplier)

		return multiplier
	end

	function PlayerManager:check_equipment_placement_valid(player, equipment)
		local equipment_data = managers.player:equipment_data_by_name(equipment)

		if not equipment_data then
			return false
		end

		if equipment_data.equipment == "trip_mine" or equipment_data.equipment == "ecm_jammer" then
			return player:equipment():valid_look_at_placement(tweak_data.equipments[equipment_data.equipment]) and true or false
		elseif equipment_data.equipment == "sentry_gun_silent" then
			return player:equipment():valid_target_enemy_placement(equipment_data.equipment,tweak_data.equipments[equipment_data.equipment])
		elseif equipment_data.equipment == "sentry_gun" or equipment_data.equipment == "ammo_bag" or equipment_data.equipment == "doctor_bag" or equipment_data.equipment == "first_aid_kit" or equipment_data.equipment == "bodybags_bag" then
			local result,revivable_unit = player:equipment():valid_shape_placement(equipment_data.equipment, tweak_data.equipments[equipment_data.equipment])
			return result and true or false,revivable_unit
		elseif equipment_data.equipment == "armor_kit" then
			return player:equipment():valid_shape_placement(equipment_data.equipment,tweak_data.equipments[equipment_data.equipment]) and true or false
		end

		return player:equipment():valid_placement(tweak_data.equipments[equipment_data.equipment]) and true or false
	end
	
	function PlayerManager:damage_reduction_skill_multiplier(damage_type)
		local is_melee = damage_type == "melee"
		local player_unit = self:local_player()
		local multiplier = 1
		
		local num_maniac_stacks = self:_get_cocaine_stacks_flat()
		local maniac_stacks_rate = tweak_data.upgrades.maniac_stacks_rate
		if num_maniac_stacks > maniac_stacks_rate then
			local num_maniac_dr_stacks = math.floor(num_maniac_stacks / maniac_stacks_rate)
			multiplier = math.max(0,multiplier * (1 - (num_maniac_dr_stacks * tweak_data.upgrades.maniac_damage_resistance_rate)))
		end
		
		if self._melee_stance_dr_t then
			multiplier = multiplier * 0.8
		end
		
		multiplier = multiplier * self:upgrade_value("player", "infiltrator_passive_DR", 1)
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
		multiplier = multiplier - self:team_upgrade_value("crewchief","passive_damage_resistance",0)
		
		if self:get_property("armor_plates_active") then 
			multiplier = multiplier * tweak_data.upgrades.armor_plates_dmg_reduction
		end
		
		local dmg_red_mul = self:team_upgrade_value("damage_dampener", "team_damage_reduction", 1)

		local player = self:local_player()
		local damage_ext = player:character_damage()
		
		if damage_ext:get_real_armor() > 0 then
			multiplier = multiplier * self:upgrade_value("player", "armorer_ironclad", 1)
		end
		
		if self:has_category_upgrade("player", "yakuza_frenzy_dr") then
			local inv_health_ratio = 1 - damage_ext:health_ratio()
			local yakuza_data = self:upgrade_value("player", "yakuza_frenzy_dr", {0, 0, 1})
			local percent_gain = yakuza_data[1] --0.02 (2% damage resistance)
			local percent_max = yakuza_data[2] --0.9 (10% damage resistance limit)
			local health_step = yakuza_data[3] --0.1 (10% missing health step)
			local yakuza_mul = 1

			while inv_health_ratio >= health_step do
				yakuza_mul = yakuza_mul - percent_gain

				if yakuza_mul < percent_max then
					inv_health_ratio = inv_health_ratio - health_step
				else
					yakuza_mul = percent_max

					break
				end
			end

			multiplier = multiplier * yakuza_mul
		end
		
		if damage_ext._yakuza_dmg_event_dr then
			multiplier = multiplier - self:upgrade_value("player", "yakuza_on_damage_dr", 0)
		end
		
		local team_upgrade_level = self:team_upgrade_level("player","civilian_hostage_aoe_damage_resistance")
		if team_upgrade_level > 0 then 
			--damage resist for being near a civilian with the Stay Down basic skill
			local player_pos = player:movement():m_pos()
			local upgrade_data = self:team_upgrade_value("player","civilian_hostage_aoe_damage_resistance")
			
			local range = upgrade_data[1]
			local civ_near_dmg_resist_bonus = upgrade_data[2]
			
			if CivilianBase.get_nearby_civ(player_pos,range,true) then
				multiplier = multiplier * civ_near_dmg_resist_bonus
			end
		end
		
		if self:has_category_upgrade("player", "passive_damage_reduction") then
			local health_ratio = player_unit:character_damage():health_ratio()
			local min_ratio = self:upgrade_value("player", "passive_damage_reduction")

			if health_ratio < min_ratio then
				dmg_red_mul = dmg_red_mul - (1 - dmg_red_mul)
			end
		end

		multiplier = multiplier * dmg_red_mul

		if is_melee then
			multiplier = multiplier * self:upgrade_value("player", "melee_damage_dampener", 1)
		end

		local current_state = self:get_current_state()

		if current_state and current_state:_interacting() then
			multiplier = multiplier * self:upgrade_value("player", "interacting_damage_multiplier", 1)
		end

		multiplier = multiplier - self:get_temporary_property("deathvox_tag_team_bonus_damage_resistance",0)
		
		local state = player_unit:movement():current_state()
		if state._state_data.meleeing then
			local melee_entry = managers.blackmarket:equipped_melee_weapon()
			local mtd = tweak_data.blackmarket.melee_weapons[melee_entry]
			if is_melee and mtd.melee_damage_resistance then 
				multiplier = multiplier - mtd.melee_damage_resistance
			end
			if mtd.all_damage_resistance then
				multiplier = multiplier - mtd.all_damage_resistance
			end
		end
		
		return multiplier
	end
	
	function PlayerManager:_get_cocaine_stacks_flat(peer_id)
		peer_id = peer_id or (managers.network:session() and managers.network:session():local_peer():id()) or 1
		local data = self:get_synced_cocaine_stacks(peer_id)
		return data and data.amount or 0
	end
	
	function PlayerManager:_add_cocaine_stacks(peer_id,n)
		peer_id = peer_id or (managers.network:session() and managers.network:session():local_peer():id()) or 1
		local data = self:get_synced_cocaine_stacks(peer_id)
		if data then
			local amount = data and data.amount or 0
			amount = math.clamp(amount + n,0,self:upgrade_value("player","mania_max_stacks",100))
			data.amount = amount
			return amount
		end
		return 0
	end
	
	function PlayerManager:_deduct_local_cocaine_stacks()
		local stacks_consumed = self:upgrade_value("player","mania_consumed_on_hit",100)
		local new_amount = self:_add_cocaine_stacks(nil,-stacks_consumed)
		local local_peer_id = managers.network:session() and managers.network:session():local_peer():id()
		local character_data = managers.criminals:character_data_by_peer_id(local_peer_id)
		if character_data then
			local max_stacks = self:upgrade_value("player","mania_max_stacks",100)
			local absolute_max_stacks = tweak_data.upgrades.values.player.mania_max_stacks[#tweak_data.upgrades.values.player.mania_max_stacks]
			managers.hud:set_info_meter(character_data.panel_id, {
				icon = "guis/dlcs/coco/textures/pd2/hud_absorb_stack_icon_01",
				max = 1,
				current = new_amount / absolute_max_stacks,
				total = max_stacks / absolute_max_stacks
			})
		end
	end
	
	function PlayerManager:_update_damage_dealt(t, dt)
		local local_peer_id = managers.network:session() and managers.network:session():local_peer():id()

		if not local_peer_id or not self:has_category_upgrade("player", "cocaine_stacking") then
			return
		end
		local max_stacks = self:upgrade_value("player","mania_max_stacks",100)
		--change max stacks to the upgrade value
		
		self._damage_dealt_to_cops_t = self._damage_dealt_to_cops_t or t + (tweak_data.upgrades.cocaine_stacks_tick_t or 1)
		self._damage_dealt_to_cops_decay_t = self._damage_dealt_to_cops_decay_t or t + (tweak_data.upgrades.cocaine_stacks_decay_t or 5)
		local cocaine_stack = self:get_synced_cocaine_stacks(local_peer_id)
		local amount = cocaine_stack and cocaine_stack.amount or 0
		local new_amount = amount
		
		--convert damage dealt to stacks
		if self._damage_dealt_to_cops_t <= t then
			self._damage_dealt_to_cops_t = t + (tweak_data.upgrades.cocaine_stacks_tick_t or 1)
			local damage_dealt = self._damage_dealt_to_cops or 0
			local new_stacks = damage_dealt * (tweak_data.gui.stats_present_multiplier or 10) * self:upgrade_value("player", "cocaine_stacking", 0)
			new_amount = new_amount + damage_dealt
			self._damage_dealt_to_cops = 0
--			new_amount = new_amount + math.min(new_stacks, tweak_data.upgrades.max_cocaine_stacks_per_tick or 20)
		end
		
		--decay is based on previous stack amount, not new total stack amount (unchanged)
		if self._damage_dealt_to_cops_decay_t <= t then
			self._damage_dealt_to_cops_decay_t = t + (tweak_data.upgrades.cocaine_stacks_decay_t or 5)
			local decay = amount * (tweak_data.upgrades.cocaine_stacks_decay_percentage_per_tick or 0)
			decay = decay + (tweak_data.upgrades.cocaine_stacks_decay_amount_per_tick or 20) * self:upgrade_value("player", "cocaine_stacks_decay_multiplier", 1)
			new_amount = new_amount - decay
		end
		
		
		new_amount = math.clamp(math.floor(new_amount), 0, max_stacks)

		if new_amount ~= amount then
			--don't bother syncing cocaine stacks
			--instead, visually update hud right here
			local character_data = managers.criminals:character_data_by_peer_id(local_peer_id)
			if character_data then
				local absolute_max_stacks = tweak_data.upgrades.values.player.mania_max_stacks[#tweak_data.upgrades.values.player.mania_max_stacks]
				managers.hud:set_info_meter(character_data.panel_id, {
					icon = "guis/dlcs/coco/textures/pd2/hud_absorb_stack_icon_01",
					max = 1,
					current = new_amount / absolute_max_stacks,
					total = max_stacks / absolute_max_stacks
				})
			end
			self._global.synced_cocaine_stacks[local_peer_id] = {
				amount = new_amount,
				in_use = true,
				upgrade_level = 1,
				power_level = 0
			}
--			self:update_synced_cocaine_stacks_to_peers(new_amount, self:upgrade_value("player", "sync_cocaine_upgrade_level", 1), self:upgrade_level("player", "cocaine_stack_absorption_multiplier", 0))
		end
	end
	--note: the following functions still reflect the old max stacks var, but are no longer relevant:
	--get_local_cocaine_damage_absorption_max(), _get_best_max_cocaine_damage_absorption_ratio(), get_peer_cocaine_damage_absorption_max_ratio()
	
	--same as vanilla but disabled HUD element in order to prevent conflicting with damage overshield mechanic
	--if/when the actual absorption mechanic is overhauled, this function (and its accompanying HUD element) may also need to be revisited
	function PlayerManager:set_damage_absorption(key, value)
		self._damage_absorption[key] = value and Application:digest_value(value, true) or nil

--		managers.hud:set_absorb_active(HUDManager.PLAYER_PANEL, self:damage_absorption())
	end
	
	function PlayerManager:verify_grenade(peer_id)
		--gutted anticheat detection function
		return true
	end
	
	function PlayerManager:verify_equipment(peer_id,equipment_id)
		--gutted anticheat detection function
		return true
	end
	
	Hooks:PostHook(PlayerManager,"check_skills","deathvox_check_cd_skills",function(self)
		--[[
		if self:has_category_upgrade("subclass_poison","weapon_subclass_damage_mul") then
			self._message_system:register(Message.OnEnemyKilled, "subclass_poison_aoe_on_kill", function(weapon_unit, variant, killed_unit)
				local player = self:local_player()
				local session = managers.network:session()
				
				if not alive(player) then 
					return
				end
				
				local weapon_base = weapon_unit and weapon_unit:base()
				
				if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_weapon_subclass("subclass_poison") then 
					if weapon_base._setup.user_unit ~= player then 
						return
					end
				else
					return
				end
				
				local weapon_id = weapon_base:get_name_id()
				
				local dot_range = managers.player:upgrade_value("subclass_poison", "poison_dot_aoe", 0)
				
				local dot_damage_received_time
				local dot_length
				local dot_damage
				local sync_variant = variant == "poison" and 1 or variant == "dot" and 2 or nil
				local weapon = weapon_id ~= nil and player or nil
				
				if dot_range > 0 then
					local nearby_enemies = killed_unit:find_units_quick("sphere", killed_unit:position(), dot_range, managers.slot:get_mask("enemies"))
					for i = 1, #nearby_enemies do
						local enemy = nearby_enemies[i]

						managers.dot:_add_doted_enemy(enemy, dot_damage_received_time, weapon_unit, dot_length, dot_damage, false, variant, weapon_id, player)
						session:send_to_peers_synched("sync_add_doted_enemy", enemy, sync_variant, weapon, dot_length, dot_damage, player, false)
					end
				end
			end)
		else
			self._message_system:unregister(Message.OnEnemyKilled,"subclass_poison_aoe_on_kill")
		end
		--]]
		
		
		if self:has_category_upgrade("class_throwing","projectile_charged_damage_mul") then
			self:set_property("charged_throwable_damage_bonus",0)
		end
		
		--[[ redundant; now handled in raycastweaponbase
		if self:has_category_upgrade("class_throwing","throwing_boosts_melee_loop") then
			local max_stacks = self:upgrade_value("class_throwing","throwing_boosts_melee_loop",{0,0})[1]
			self._message_system:register(Message.OnEnemyShot,"proc_shuffle_cut_basic",function(unit,attack_data)
				local player = self:local_player()
				if not alive(player) then 
					return
				end
				local weapon_base = attack_data and attack_data.weapon_unit and attack_data.weapon_unit:base()
				if not (weapon_base and weapon_base.is_weapon_class and weapon_base:is_weapon_class("class_throwing") and weapon_base._thrower_unit and weapon_base._thrower_unit == player) then 
					return
				end
				local stacks = self:get_property("shuffle_cut_melee_bonus_damage",0)
				self:set_property("shuffle_cut_melee_bonus_damage",math.min(stacks+1,max_stacks))
			end)
		end
		--]]
		
		if self:has_category_upgrade("weapon","xbow_headshot_instant_reload") then 
		
			self._message_system:register(Message.OnLethalHeadShot,"proc_good_hunting_aced",
				function(attack_data)
					local player = self:local_player()
					if not alive(player) then 
						return
					end
					local weapon_base = attack_data and attack_data.weapon_unit and attack_data.weapon_unit:base()
					if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_category("crossbow") then 
						if weapon_base._setup.user_unit ~= player then 
							return
						end
					else
						return
					end
					
					weapon_base:set_ammo_remaining_in_clip(weapon_base:calculate_ammo_max_per_clip())
					for i,selection in pairs(player:inventory():available_selections()) do 
						managers.hud:set_ammo_amount(i, selection.unit:base():ammo_info())
					end
				end
			)
		end
		
		if self:has_category_upgrade("class_rapidfire","critical_hit_chance_on_headshot") then 
			local skill_data = self:upgrade_value("class_rapidfire","critical_hit_chance_on_headshot")
		
			local duration = skill_data[2]
			local max_stacks = skill_data[3]
			
			self._message_system:register(Message.OnHeadShot,"proc_shotgrouping_aced",
				function()
					local player = self:local_player()
					if not alive(player) then 
						return
					end
					local weapon = player:inventory():equipped_unit():base()
					if not weapon:is_weapon_class("class_rapidfire") then 
						return
					end
					
					local stacks = math.min(self:get_temporary_property("shotgrouping_aced_stacks",0) + 1,max_stacks)
					self:activate_temporary_property("shotgrouping_aced_stacks",duration,stacks)
				end
			)
		else
			self._message_system:unregister(Message.OnHeadShot,"proc_shotgrouping_aced")
		end
		
--			"OnPlayerMeleeHit" hook is no longer active; to re-implement this, the hook must be re-enabled in PlayerStandard:_do_melee_damage()
--[[
		if self:has_category_upgrade("player","melee_hit_speed_boost") then
			--float like a butterfly aced (unused, pre-rework)
			Hooks:Add("OnPlayerMeleeHit","cd_proc_butterfly_bee",
				function(hit_unit,col_ray,action_data,defense_data,t)
					if hit_unit and not managers.enemy:is_civilian(hit_unit) then 
						managers.player:activate_temporary_property("float_butterfly_movement_speed_multiplier",unpack(managers.player:upgrade_value("player","melee_hit_speed_boost",{0,0})))
					end
				end
			)
		end
--]]
		
		if self:has_category_upgrade("player","escape_plan") then 
			Hooks:Add("OnPlayerShieldBroken","cd_proc_escape_plan",
				function(player_unit)
					if alive(player_unit) then 
						local movement = player_unit:movement()
						
						local escape_plan_data = managers.player:upgrade_value("player","escape_plan",{0,0,0,0})
						local stamina_restored_percent = escape_plan_data[1]
						local sprint_speed_bonus = escape_plan_data[2]
						local escape_plan_duration = escape_plan_data[3]
						local move_speed_bonus = escape_plan_data[4]
						movement:_change_stamina(movement:_max_stamina() * stamina_restored_percent)
						self:activate_temporary_property("escape_plan_speed_bonus",escape_plan_duration,{sprint_speed_bonus,move_speed_bonus})
					end
				end
			)
		end
		
		if self:has_category_upgrade("class_heavy","collateral_damage") then 
			local slot_mask = managers.slot:get_mask("enemies")
			
			local collateral_damage_data = self:upgrade_value("class_heavy","collateral_damage",{0,0})
			local damage_mul = collateral_damage_data[1]
			local radius = collateral_damage_data[2]
			
			self._message_system:register(Message.OnWeaponFired,"proc_collateral_damage",
				function(weapon_unit,result)
				
					--this is called on any weapon firing,
					--so this needs checks to make sure that the weapon class is heavy
					--and that the user_unit is the player
					local player = self:local_player()
					if not alive(player) then 
						return
					end
					local weapon_base = weapon_unit and weapon_unit:base()
					if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_weapon_class("class_heavy") then 
						if weapon_base._setup.user_unit ~= player then 
							return
						end
					else
						return
					end
					if #result.rays == 0 then 
						return
					end
					
					local first_ray = result.rays[1] 
					local from = player:movement():current_state():get_fire_weapon_position()
					--sort of cheating here by assuming the origin of the ray is the current fire position
					local dir = mvec3_copy(first_ray.ray)
					local to
					local hits = {}
					for n,ray in ipairs(result.rays) do 
						local damage = weapon_base:_get_current_damage()
						local dir = ray.ray or Vector3()
						if ray.damage_result then 
							local attack_data = ray.damage_result.attack_data or {}
							damage = attack_data and attack_data.damage_raw or damage
						end
						damage = damage * damage_mul
						if ray.unit then
							hits[ray.unit:key()] = {
								disabled = true
							}
						end
						to = mvec3_copy(ray.hit_position or ray.position or Vector3())
--						Draw:brush(Color.red:with_alpha(0.1),5):sphere(from,50)
--						Draw:brush(Color.blue:with_alpha(0.1),5):sphere(to,50)
--						Draw:brush(Color(1,n / #result.rays,1):with_alpha(0.1),5):cylinder(from,to,radius)
						local grazed_enemies = world_g:raycast_all("ray", from, to, "sphere_cast_radius", radius, "disable_inner_ray", "slot_mask", slot_mask)
						for _,hit in pairs(grazed_enemies) do 
							local hit_data = hits[hit.unit:key()]
							local add_hit = not (hit_data and hit_data.disabled)
							if add_hit and hit_data and hit_data.damage < damage then 
								add_hit = false
							end
							if add_hit and hit.unit then 
								hits[hit.unit:key()] = {
									unit = hit.unit,
									damage = damage,
									attacker_unit = player,
									pos = mvec3_copy(to),
									attack_dir = mvec3_copy(dir)
								}
							end
							--collect hits here to prevent the same enemy from being hit by multiple rays, in the case of penetrating or ricochet shots
						end
						
						from = mvec3_copy(to)
					end

					
					for _,hit_data in pairs(hits) do 
						if not hit_data.disabled then 
							local enemy = hit_data.unit
							if enemy and enemy.character_damage and enemy:character_damage() then 
								enemy:character_damage():damage_simple({
									variant = "graze",
									damage = hit_data.damage,
									attacker_unit = hit_data.attacker_unit,
									pos = hit_data.pos,
									attack_dir = hit_data.attack_dir
								})
							end
						end
					end
					
				end
			)
		end
		
		if self:has_category_upgrade("class_heavy","death_grips_stacks") then
			self._message_system:register(Message.OnEnemyKilled,"proc_death_grips",
				function(weapon_unit,variant,killed_unit)
					local player = self:local_player()
					if not alive(player) then 
						return
					end
					local weapon_base = alive(weapon_unit) and weapon_unit:base()
					if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_weapon_class("class_heavy") then 
						if weapon_base._setup.user_unit ~= player then 
							return
						end
					else
						return
					end
					local death_grips_data = self:upgrade_value("class_heavy","death_grips_stacks",{0,0})
					local death_grips_stack_reset_timer = death_grips_data[1]
					local death_grips_max_stacks = death_grips_data[2]
					
					local death_grips_stacks = math.min(self:get_temporary_property("current_death_grips_stacks",0) + 1,death_grips_max_stacks)
					self:activate_temporary_property("current_death_grips_stacks",death_grips_stack_reset_timer,death_grips_stacks)
				end
			)
		end
		
		if self:has_category_upgrade("class_heavy","lead_farmer") then 
			self:set_property("current_lead_farmer_stacks",0)
			self._message_system:register(Message.OnEnemyKilled,"proc_lead_farmer",
				function(weapon_unit,variant,killed_unit)
					local player = self:local_player()
					if not alive(player) then 
						return
					end
					local weapon_base = weapon_unit and weapon_unit:base()
					if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_weapon_class("class_heavy") then 
						if weapon_base._setup.user_unit ~= player then 
							return
						end
					else
						return
					end
					self:add_to_property("current_lead_farmer_stacks",1)
				end
			)
			
			Hooks:Add("OnPlayerReloadComplete","on_player_reloaded_consume_lead_farmer",
				--Message.OnPlayerReload is called when reload STARTS, which is before the reload mul is calculated.
				--so it's pretty useless to reset stacks from that message event.
				function(weapon_unit)
					local weapon_base = alive(weapon_unit) and weapon_unit:base()
					if weapon_base and weapon_base:is_weapon_class("class_heavy") then 
						self:set_property("current_lead_farmer_stacks",0)
					end
				end
			)
		end
		
		if self:has_category_upgrade("class_shotgun","shell_games_reload_bonus") then
			self:set_property("shell_games_rounds_loaded",0)
		end
		
		--shotgrouping aced, previously known as making miracles basic
		if self:has_category_upgrade("class_rapidfire", "making_miracles_basic") then
			local skill_data = self:upgrade_value("class_rapidfire","making_miracles_basic")
			local duration = skill_data[2]
			local max_stacks = skill_data[3]
			
			
			self._message_system:register(Message.OnHeadShot,"proc_making_miracles_basic",
				function()
					local player = self:local_player()
					if not alive(player) then 
						return
					end
					local weapon = player:inventory():equipped_unit():base()
					if not weapon:is_weapon_class("class_rapidfire") then 
						return
					end
					
					local stacks = math.min(self:get_temporary_property("making_miracles_stacks",0) + 1,max_stacks)
					self:activate_temporary_property("making_miracles_stacks",duration,stacks)
				end
			)
		else
			self._message_system:unregister(Message.OnHeadShot,"proc_making_miracles_basic")
		end
		
		if self:has_category_upgrade("weapon","making_miracles_aced") then 
			self._message_system:register(Message.OnLethalHeadShot,"proc_making_miracles_aced",
				function(attack_data)
					local player = self:local_player()
					if not alive(player) then 
						return
					end
					local weapon_base = attack_data and attack_data.weapon_unit and attack_data.weapon_unit:base()
					if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_weapon_class("class_rapidfire") then 
						if weapon_base._setup.user_unit ~= player then 
							return
						end
					else
						return
					end
					
					self:add_to_property("making_miracles_stacks",1)
				end
			)
		else
			self._message_system:unregister(Message.OnLethalHeadShot,"proc_making_miracles_aced")
		end
		
		self:set_property("current_point_and_click_stacks",0)
		self:set_property("point_and_click_stacks_add", 0)
		
		if self:has_category_upgrade("player","point_and_click_stacks") then 
			Hooks:Add("TCD_Create_Stack_Tracker_HUD","TCD_CreatePACElement",function(hudtemp)
			 --check_skills() is called before the hud is created so it must instead call on an event
			
				--create buff-specific hud element; todo create a hudbuff class to handle this
				--this is temporary until more of the core systems are done, and then i can dedicate more time 
				--to creating a buff tracker system + hud elements 
				--		-offy\
				
--				local hudtemp = managers.hud and managers.hud._hud_temp and managers.hud._hud_temp._hud_panel
				if hudtemp and alive(hudtemp) then
					if alive(hudtemp:child("point_and_click_tracker")) then 
						BeardLib:RemoveUpdater("update_tcd_buffs_hud")
						hudtemp:remove(hudtemp:child("point_and_click_tracker"))
					end
					local trackerhud = hudtemp:panel({
						name = "point_and_click_tracker",
						w = 100,
						h = 100
					})
					trackerhud:set_position((hudtemp:w() - trackerhud:w()) / 2,450)
					local debug_trackerhud = trackerhud:rect({
						name = "debug",
						color = Color.red,
						visible = false,
						alpha = 0.1
					})
					local icon_size = 64
					local icon_x,icon_y = unpack(tweak_data.skilltree.skills.triathlete.icon_xy) --triathlete is the skill that point and click replaced
--					local skill_atlas = "guis/textures/pd2/skilltree/icons_atlas"
					local skill_atlas_2 = "guis/textures/pd2/skilltree_2/icons_atlas_2"
--					local perkdeck_atlas = "guis/textures/pd2/specialization/icons_atlas"	

					local icon = trackerhud:bitmap({
						name = "icon",
						texture = skill_atlas_2,
						texture_rect = {icon_x * 80,icon_y * 80,80,80},
						alpha = 0.9,
--						x = (trackerhud:w() - icon_size) / 2,
--						y = 0,
						w = icon_size,
						h = icon_size
					})
					icon:set_center(trackerhud:w()/2,trackerhud:h()/2)
					local stack_count = trackerhud:text({
						name = "text",
						text = "0",
						font = tweak_data.hud.medium_font,
						font_size = 16,
						align = "center",
						color = Color.white,
						vertical = "bottom"
					})
					
					BeardLib:AddUpdater("update_tcd_buffs_hud",function(t,dt)
						if alive(stack_count) then 
							stack_count:set_text(self:get_property("current_point_and_click_stacks",0))
							if managers.enemy:is_clbk_registered("point_and_click_on_shot_missed") and alive(icon) then 
								icon:set_color(Color(math.sin(t * 300 * math.pi),0,0))
							else
								icon:set_color(Color.white)
							end
						end
					end,false)
				end
			end)
			
			
			self._p_and_c_potential = self:has_category_upgrade("player", "point_and_click_never_miss")
			self._p_and_c_exponential = self:has_category_upgrade("player", "point_and_click_deadshot_mul")
			
			--this adds a stack on kill
			self._message_system:register(Message.OnEnemyKilled, "point_and_click_stack_on_kill", function(weapon_unit, variant, killed_unit)
				local player = self:local_player()
				
				if not alive(player) then 
					return
				end
				
				local weapon_base = weapon_unit and weapon_unit:base()
				
				if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_weapon_class("class_precision") then 
					if weapon_base._setup.user_unit ~= player then 
						return
					end
				else
					return
				end
				
				
				if self:get_property("point_and_click_stacks_add", 0) > 0 then					
					self:add_to_property("current_point_and_click_stacks", 1)
					self:add_to_property("current_point_and_click_stacks", self:get_property("point_and_click_stacks_add", 0))
					
					if self._p_and_c_exponential then
						local to_add = 1
						self:add_to_property("point_and_click_stacks_add", to_add)
					end
				else	
					self:add_to_property("current_point_and_click_stacks", 1)
					
					if self._p_and_c_potential then
						self:set_property("point_and_click_stacks_add", 1)
					end
				end	
			end)
			
			if self._p_and_c_potential then
				self._message_system:register(Message.OnWeaponFired, "point_and_click_on_miss", function(weapon_unit, result)
					if result and result.hit_enemy then
						return
					end
					
					local player = self:local_player()
					
					if not alive(player) then 
						return
					end
					
					local weapon_base = weapon_unit and weapon_unit:base()
					
					if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_weapon_class("class_precision") then 
						if weapon_base._setup.user_unit ~= player then 
							return
						end
					else
						return
					end
					
					self:set_property("point_and_click_stacks_add", 0)
				end)
			else
				self._message_system:unregister(Message.OnWeaponFired, "point_and_click_on_miss")
			end
			
			if self:has_category_upgrade("player", "point_and_click_stack_from_headshot_kill") then
				self._message_system:register(Message.OnLethalHeadShot, "point_and_click_stack_from_headshot_kill", function(attack_data)
					local player = self:local_player()
					
					if not alive(player) then 
						return
					end
					
					local weapon_base = attack_data and attack_data.weapon_unit and attack_data.weapon_unit:base()
					
					if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_weapon_class("class_precision") then 
						if weapon_base._setup.user_unit ~= player then 
							return
						end
					else
						return
					end
					
					self:add_to_property("current_point_and_click_stacks",self:upgrade_value("player","point_and_click_stack_from_headshot_kill",0))
				end)
			else
				self._message_system:unregister(Message.OnLethalHeadShot, "point_and_click_stack_from_headshot_kill")
			end
		else
			self._message_system:unregister(Message.OnEnemyShot,"point_and_click_stack_on_kill")
		end
		
		if self:has_category_upgrade("weapon","magic_bullet") then 
			self._message_system:register(Message.OnLethalHeadShot, "proc_magic_bullet", function(attack_data)
				local player = self:local_player()
				
				if not alive(player) then 
					return
				end
				
				local weapon_base = attack_data.weapon_unit and attack_data.weapon_unit:base()
				
				if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_weapon_class("class_precision") then 
					if weapon_base._setup.user_unit ~= player then 
						return
					end
				else
					return
				end
				
				if not weapon_base:ammo_full() then 
					local magic_bullet_level = self:upgrade_level("weapon","magic_bullet",0)
					local clip_current = weapon_base:get_ammo_remaining_in_clip()
					local clip_max = weapon_base:get_ammo_max_per_clip()
					local weapon_index = self:equipped_weapon_index()
					
					if (magic_bullet_level == 2) and (clip_current < clip_max) then
						weapon_base:set_ammo_remaining_in_clip(math.min(clip_max,clip_current + self:upgrade_value("weapon","magic_bullet",0)))
					end
					
					weapon_base:add_ammo_to_pool(self:upgrade_value("weapon","magic_bullet",0),self:equipped_weapon_index())
					managers.hud:set_ammo_amount(weapon_index, weapon_base:ammo_info())
					player:sound():play("pickup_ammo")
				end
			end)
		else
			self._message_system:unregister(Message.OnLethalHeadShot,"proc_magic_bullet")
		end
		
		if self:has_category_upgrade("player","throwable_regen") then 
			self._improv_expert_basic_throwable_regen_kills = 0
			local kills_to_regen_grenade,grenades_replenished = unpack(self:upgrade_value("player","throwable_regen",{0,0}))
			if kills_to_regen_grenade > 0 then 
				self._message_system:register(Message.OnEnemyKilled,"proc_improv_expert_basic",function(weapon_unit,variant,killed_unit)

					local player = self:local_player()
					if not alive(player) then 
						return
					end
					local weapon_base = weapon_unit and weapon_unit:base()
					if weapon_base and weapon_base._setup and weapon_base._setup.user_unit then 
						if weapon_base._setup.user_unit ~= player then 
							return
						end
					else
						return
					end
					
					
					local grenade_id = managers.blackmarket:equipped_grenade()
					local ptd = tweak_data.blackmarket.projectiles
					local gtd = ptd and grenade_id and ptd[grenade_id]
					local is_a_grenade = gtd.is_a_grenade
					
					self._improv_expert_basic_throwable_regen_kills = self._improv_expert_basic_throwable_regen_kills + 1
					if self._improv_expert_basic_throwable_regen_kills >= kills_to_regen_grenade then 
						if is_a_grenade then 
							self:add_grenade_amount(grenades_replenished,true)
						end
						self._improv_expert_basic_throwable_regen_kills = 0
					end
					
				end)
			end
		end
		
		if self:has_category_upgrade("player","sociopath_mode") then 
			--downed effect
			self._sociopath_downed_overlay = TCDSociopathDownedOverlay:new()
			Hooks:Add("TCD_Create_Stack_Tracker_HUD","TCD_CreateSociopathDownedOverlay",function(hudtemp)
				self._sociopath_downed_overlay:Create(managers.hud._fullscreen_workspace:panel())
			end)
			
			Hooks:Add("deathvox_OnPlayerEnteredBleedout","TCD_Animate_Sociopath_Bleedout",function()
				self._sociopath_downed_overlay:StartDownedAnimation()
			end)
			
			Hooks:Add("deathvox_OnPlayerEnteredCustody","TCD_Animate_Sociopath_Death",function()
				self._sociopath_downed_overlay:StartDeathAnimation()
			end)
			
			Hooks:Add("TCD_OnPlayerRevived","TCD_Animate_Sociopath_End",function()
				self._sociopath_downed_overlay:StopDownedAnimation()
				self._sociopath_downed_overlay:StopDeathAnimation()
			end)
			
			--[ [
			--combo counter
			self._sociopath_combo_overlay = TCDSociopathComboOverlay:new()
			Hooks:Add("TCD_Create_Stack_Tracker_HUD","TCD_CreateSociopathComboOverlay",function(hudtemp)
				self._sociopath_combo_overlay:Create(hudtemp)
			end)
			
			
			Hooks:Add("TCD_OnSociopathComboStacksChanged","TCD_SetSociopathComboStacksHUD",function(previous,current)
				self._sociopath_combo_overlay:OnComboChanged(previous,current)
			end)
			
			--]]
			
			
		end
		
		Hooks:Add("TCD_OnCriminalDowned","TCD_Biker_OnTeammateDowned",function(teammate_type,teammate_ext,state_name,down_time)
			local player = self:local_player()
			if alive(player) then
				if self:has_team_category_upgrade("player","biker_restore_armor_on_teammate_downed") then
					local dmg_ext = player:character_damage()
					dmg_ext:restore_armor(dmg_ext:_max_armor())
				end
			end
		end)
		
		if Network:is_server() then 
			self:set_property("gambler_team_ammo_pickups_grabbed",0)
		end
	end)

	function PlayerManager:movement_speed_multiplier(speed_state, bonus_multiplier, upgrade_level, health_ratio)
		local multiplier = 1
		local armor_penalty = self:mod_movement_penalty(self:body_armor_value("movement", upgrade_level, 1))
		
		multiplier = multiplier + armor_penalty - 1
		
		if multiplier < 1.05 then
			local diff = 1.05 - multiplier
			
			diff = diff * self:upgrade_value("player", "armorer_armor_pen_mul", 1) --no longer used
			
			multiplier = 1.05 - diff
			
			--log("speed_mul: " .. tostring(multiplier))
		end
		
		if bonus_multiplier then
			multiplier = multiplier + bonus_multiplier - 1
		end
		
		multiplier = multiplier + self:upgrade_value("player", "sociopath_speed_mul", 1) - 1
		
		multiplier = multiplier + self:get_temporary_property("float_butterfly_movement_speed_multiplier",0)
		
		local escape_plan_status = self:get_temporary_property("escape_plan_speed_bonus",false)
		local escape_plan_sprint_bonus = 0
		local escape_plan_movement_bonus = 0

		if escape_plan_status and type(escape_plan_status) == "table" then 
			escape_plan_sprint_bonus = escape_plan_status[1] or escape_plan_sprint_bonus
			escape_plan_movement_bonus = escape_plan_status[2] or escape_plan_movement_bonus
		end
		
		if speed_state then
			multiplier = multiplier + self:upgrade_value("player", speed_state .. "_speed_multiplier", 1) - 1
			
			if speed_state == "run" then 
				multiplier = multiplier + escape_plan_sprint_bonus
			end
		end
		multiplier = multiplier + escape_plan_movement_bonus

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

		if self:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier") then
			multiplier = multiplier * (tweak_data.upgrades.berserker_movement_speed_multiplier or 1)
		end
		
		multiplier = multiplier * self:get_temporary_property("deathvox_tag_team_bonus_movement_speed",1)
		
		if health_ratio then
			local damage_health_ratio = self:get_damage_health_ratio(health_ratio, "movement_speed")
			multiplier = multiplier * (1 + self:upgrade_value("player", "movement_speed_damage_health_ratio_multiplier", 0) * damage_health_ratio)
		end

		local damage_speed_multiplier = self:temporary_upgrade_value("temporary", "damage_speed_multiplier", self:temporary_upgrade_value("temporary", "team_damage_speed_multiplier_received", 1))
		multiplier = multiplier * damage_speed_multiplier
		return multiplier
	end

	function PlayerManager:get_max_grenades(grenade_id)
		local eq_gr,eq_max = managers.blackmarket:equipped_grenade()
		local max_amount = 0
		if not grenade_id then 
			grenade_id = eq_gr
			max_amount = eq_max
		end
		local ptd = tweak_data.blackmarket.projectiles
		local gtd = ptd and grenade_id and ptd[grenade_id]
--		local max_amount = tweak_data:get_raw_value("blackmarket", "projectiles", grenade_id, "max_amount") or 0
		if gtd then 
			max_amount = gtd.max_amount or max_amount
			if gtd.throwable then
				if gtd.is_a_grenade then 
					max_amount = math.round(max_amount * self:upgrade_value("player","grenades_amount_increase_mul",1))
				else
					max_amount = math.round(max_amount * self:upgrade_value("class_throwing","throwing_amount_increase_mul",1))
				end
			end
			max_amount = managers.modifiers:modify_value("PlayerManager:GetThrowablesMaxAmount", max_amount)
		end
		return max_amount
	end

	function PlayerManager:_attempt_tag_team()
--		log("Attempted tag team")
		if not self:has_category_upgrade("player","tag_team_base_deathvox") then 
			return
		end
		
		local base_data = self:upgrade_value("player", "tag_team_base_deathvox")
		
		local player = self:local_player()
		local player_eye = player:camera():position()
		local player_fwd = player:camera():rotation():y()
		local tagged = nil
		local heisters_slot_mask = World:make_slot_mask(2, 3, 4, 5, 16, 24)
		local tag_distance = base_data.distance
		local long_distance_revive_health = self:upgrade_value("player","tag_team_long_distance_revive",0)
		local long_distance_revive_level = self:upgrade_level("player","tag_team_long_distance_revive",0)
		local max_angle = base_data.max_angle

		local head_pos = player:movement():m_head_pos()
		local head_rot = player:movement():m_head_rot()
		local aim_direction = head_rot:yaw()
		local best_pick = {
			unit = nil,
			distance = nil,
			angle = 360
		}
		
		local nearby_heisters = World:find_units_quick("sphere",head_pos,tag_distance,heisters_slot_mask)
		for _,unit in pairs(nearby_heisters) do 
			local unit_pos = unit:oobb() and unit:oobb():center() or unit:position()
			local angle = math.abs(mvector3.angle(unit_pos - head_pos,head_rot:y()))
			if angle < max_angle then 
				if angle < best_pick.angle then 
					best_pick = {
						unit = unit,
						distance = distance,
						angle = angle
					}
				end					
			end
		end
		tagged = best_pick.unit
--[[

--		local cone_radius = base_data.radius
		
		local cone_camera = player:camera():camera_object()
		local cone_center = Vector3(0, 0)
		
		local heisters = World:find_units("camera_cone", cone_camera, cone_center, cone_radius, tag_distance, heisters_slot_mask)
		local best_dot = -1

		for _, heister in ipairs(heisters) do
			local heister_center = heister:oobb():center()
			local heister_dir = heister_center - player_eye
			local distance_pass = mvector3.length_sq(heister_dir) <= tag_distance * tag_distance
			local raycast = nil

			if distance_pass then
				mvector3.normalize(heister_dir)

				local heister_dot = Vector3.dot(player_fwd, heister_dir)

				if best_dot < heister_dot then
					best_dot = heister_dot
					raycast = World:raycast(player_eye, heister_center)
					tagged = raycast and raycast.unit:in_slot(heisters_slot_mask) and heister
				end
			end
		end
--]]

		if not tagged then 
--			log("No tagged unit")
			return false
		elseif self._coroutine_mgr:is_running("tag_team") then
--			log("tagteam already running")
			return false
		end
		
		if long_distance_revive_level > 0 then 
			if tagged:movement() and tagged:movement().downed then 
				if tagged:movement():downed() then 
					
					local is_ai = not managers.criminals:character_peer_id_by_unit(tagged)

					managers.statistics:revived({
						npc = is_ai,
						reviving_unit = tagged
					})
					
					if not is_ai then 
						player:network():send_to_unit({
							"revive_player",
							long_distance_revive_health,
							self:upgrade_value("player","revive_damage_reduction_level",0)
						})
					else
						tagged:interaction():interact(player,true)
					end
					
					local event_listener = tagged:event_listener()

					if event_listener then
						event_listener:call("on_revive_interaction_success")
					end
					
					player:sound():say("f36x_any")
					
--					log("revived " .. tostring(is_ai or "bot") .. " via tagteam")
					if long_distance_revive_level < 2 then
--						log("No extra revive upgrade, returning")
						return true
					end
					
				end
			end
		end
		
		self:add_coroutine("tag_team", PlayerAction.TagTeam, tagged, player)
		return true
	end
	
	function PlayerManager:chk_wild_kill_counter(killed_unit, variant)
		local player = self:local_player()
		if alive(player) then
			local dmg_ext = player:character_damage()
			if alive(killed_unit) then
				local killed_base = killed_unit:base()
				if killed_base and killed_base:has_tag("special") then
					local armor_restored_total = 0
					
					if self:has_team_category_upgrade("player","biker_restore_armor_on_special_kill") then
						local armor_restored = self:team_upgrade_value("player","biker_restore_armor_on_special_kill")
						
						armor_restored_total = armor_restored_total + armor_restored
					end
					
					if self:has_team_category_upgrade("player","biker_temp_stagger_on_special_kill") then
						-- stagger event id
						-- an enemy cannot be staggered twice in one buff proc
						local stagger_id = self._num_biker_staggers or 0
						stagger_id = stagger_id + 1
						self._num_biker_staggers = stagger_id
						
						--activate guaranteed stagger temp buff
						local stagger_duration = self:team_upgrade_value("player","biker_temp_stagger_on_special_kill")
						self:activate_temporary_property("biker_guaranteed_stagger",stagger_duration,stagger_id)
					end
					
					if self:has_team_category_upgrade("player","biker_restore_armor_on_special_multikills") then
						local upgrade_data = self:team_upgrade_value("player","biker_restore_armor_on_special_multikills")
						local multikill_timer = upgrade_data.multikill_timer
						local max_stacks = upgrade_data.max_stacks
						local armor_restored = upgrade_data.armor_restored
						
						-- increment stacks
						local stacks = self:get_temporary_property("biker_special_multikill_counter",0)
						stacks = math.min(max_stacks,stacks + 1)
						self:activate_temporary_property("biker_special_multikill_counter",multikill_timer,stacks)
						
						armor_restored_total = armor_restored_total + (armor_restored * stacks)
					end
					
					if armor_restored_total > 0 then
						dmg_ext:restore_armor(armor_restored_total * dmg_ext:_max_armor())
					end
				end
			end
		end
	end
	
end


Hooks:PostHook(PlayerManager,"on_enter_custody","tcd_on_player_enter_custody",function(self,player)
	Hooks:Call("deathvox_OnPlayerEnteredCustody",player)
end)

		--The overshield mechanic is only used in Total Crackdown ((TCD), but its methods are present outside of TCD so that two versions of player damage for any given damage type (damage_bullet, damage_explosion, damage_melee, etc) aren't necessary for TCD and normal Crackdown

--new overshield mechanic whose sources are separate like damage absorption, and provides flat damage reduction like absorption, except the amount of damage you take is subtracted from your overshield amount.
--....so, like overshield in basically any other video game.
function PlayerManager:set_damage_overshield(id,amount,params,skip_update)
	local overshield_data
	
	for i,_overshield_data in pairs(self._damage_overshield) do 
		if _overshield_data.id == id then 
			overshield_data = _overshield_data
			break
		end
	end
	if not overshield_data then 
		local i = #self._damage_overshield + 1
		self._damage_overshield[i] = {}
		overshield_data = self._damage_overshield[i]
	end
	
	overshield_data.amount = amount
	if params then 
		if params.depleted_callback then 
			overshield_data.depleted_callback = params.depleted_callback
		end
	end
	
	--none of that Application:digest_value() nonsense here
	if not skip_update then 
		--skip_update should ideally be used when setting multiple damage overshields at once,
		--since the get_damage_overshield_total() func involves iterating over a table,
		--so it is somewhat inefficient
		self:sort_damage_overshield()
	end
end

--completely unregister a damage overshield
function PlayerManager:remove_damage_overshield(key,skip_update)
	self._damage_overshield[key] = nil
	if not skip_update then 
		self:sort_damage_overshield()
	end
end

--subtracts incoming damage from overshields, and returns remaining damage
--smaller overshield amounts are consumed first
function PlayerManager:consume_damage_overshield(damage)
	--overshield 
	if damage <= 0 then 
		return damage
	end
	local queued_remove = {}
	for i,overshield_data in ipairs(self._damage_overshield) do 
		if damage <= 0 then 
			break
		end
		local prev_overshield_amount = overshield_data.amount
		local new_overshield_amount = math.max(overshield_data.amount - damage,0)
		overshield_data.amount = new_overshield_amount
		local blocked_damage = prev_overshield_amount - new_overshield_amount
		if new_overshield_amount <= 0 then 
			if type(overshield_data.depleted_callback) == "function" then 
				overshield_data.depleted_callback(damage,blocked_damage)
				--note that this callback is performed before the player damage calculation is complete!
			end
			table.insert(queued_remove,i)
		end
		damage = damage - blocked_damage
	end
	
	if #queued_remove > 0 then 
		for i=#queued_remove,1,-1 do 
			table.remove(self._damage_overshield,queued_remove[i])
		end
	end
	self:sort_damage_overshield()
	
	return damage
end

function PlayerManager:sort_damage_overshield()
	table.sort(self._damage_overshield,function(a,b)
		return a.amount > b.amount
	end)
	
	managers.hud:set_absorb_active(HUDManager.PLAYER_PANEL, self:get_damage_overshield_total())
end

function PlayerManager:get_damage_overshield_total()
	local sum = 0
	for k,v in pairs(self._damage_overshield) do 
		sum = sum + v.amount
	end
	return sum
end

function PlayerManager:health_skill_addend()
	local addend = 0
	
	if self:has_category_upgrade("player", "sociopath_mode") then
		addend = -22.6
		
		addend = addend + managers.player:upgrade_value("player", "sociopath_health_addend", 0) * 0.1
		
		return addend
	end
	
	addend = addend + self:upgrade_value("team", "crew_add_health", 0)
	
	addend = addend + self:get_property("muscle_beachyboys_bonus",0)
	
	if table.contains(self._global.kit.equipment_slots, "thick_skin") then
		addend = addend + self:upgrade_value("player", "thick_skin", 0)
	end

	return addend
end

function PlayerManager:health_skill_multiplier()
	local multiplier = 1
	
	if self:has_category_upgrade("player", "sociopath_mode") then
		return multiplier
	end
	
	multiplier = multiplier + self:upgrade_value("player", "health_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "grinder_health_mul", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "muscle_health_mul", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "expres_health_mul", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "passive_health_multiplier", 1) - 1
	multiplier = multiplier + self:team_upgrade_value("health", "passive_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "kingpin_max_health_mul", 1) - 1
	multiplier = multiplier + self:get_hostage_bonus_multiplier("health") - 1
	multiplier = multiplier - self:upgrade_value("player", "health_decrease", 0)
	multiplier = multiplier + self:upgrade_value("player", "infiltrator_max_health_mul",0)

	if self:num_local_minions() > 0 then
		multiplier = multiplier + self:upgrade_value("player", "minion_master_health_multiplier", 1) - 1
	end
	
	if self:has_category_upgrade("player", "anarch_conversion") then
		local anarch_mul = 1 - self:upgrade_value("player", "anarch_conversion", 0)
		multiplier = multiplier * anarch_mul
	end

	return multiplier
end

function PlayerManager:body_armor_value(category, override_value, default)
	local armor_data = tweak_data.blackmarket.armors[managers.blackmarket:equipped_armor(true, true)]
	
	if category == "damage_shake" then
		local shake = self:upgrade_value_by_level("player", "body_armor", category, {})[override_value or armor_data.upgrade_level] or default or 0
		
		shake = shake * self:upgrade_value("player", "armorer_shake_mul", 1)
		
		return shake
	end
	
	return self:upgrade_value_by_level("player", "body_armor", category, {})[override_value or armor_data.upgrade_level] or default or 0
end

local crook_armor_types = {
	level_2 = true,
	level_3 = true,
	level_4 = true
}

function PlayerManager:body_armor_skill_multiplier(override_armor)
	if self:has_category_upgrade("player", "sociopath_mode") then
		return 0
	end

	local multiplier = 1
	multiplier = multiplier + self:upgrade_value("player", "armorer_armor_mul", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "tier_armor_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "passive_armor_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "armor_multiplier", 1) - 1
	multiplier = multiplier + self:team_upgrade_value("armor", "multiplier", 1) - 1
	multiplier = multiplier + self:team_upgrade_value("player", "biker_max_armor_increase", 1) - 1
	multiplier = multiplier + self:get_hostage_bonus_multiplier("armor") - 1
	multiplier = multiplier + self:upgrade_value("player", "perk_armor_loss_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_armor_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "chico_armor_multiplier", 1) - 1
	multiplier = multiplier + self:upgrade_value("player", "infiltrator_max_armor_mul",0)

	return multiplier
end

function PlayerManager:body_armor_skill_addend(override_armor)
	if self:has_category_upgrade("player", "sociopath_mode") then
		return 0
	end

	local addend = 0
	addend = addend + self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_armor_addend", 0)

	if self:has_category_upgrade("player", "armor_increase") then
		local health_multiplier = self:health_skill_multiplier()
		local max_health = (PlayerDamage._HEALTH_INIT + self:health_skill_addend()) * health_multiplier
		addend = addend + max_health * self:upgrade_value("player", "armor_increase", 1)
	end
	
	if self:has_category_upgrade("player", "anarch_conversion") then
		local max_health = (PlayerDamage._HEALTH_INIT + self:health_skill_addend())
		addend = addend + max_health * self:upgrade_value("player", "anarch_conversion", 0)
	end
	
	if self:has_category_upgrade("player", "crook_vest_armor_addend") then
		local armor = tostring(override_armor or managers.blackmarket:equipped_armor(true, true))

		if crook_armor_types[armor] then
			addend = addend + self:upgrade_value("player", "crook_vest_armor_addend", 0)
		end
	end

	addend = addend + self:upgrade_value("team", "crew_add_armor", 0)

	return addend
end

function PlayerManager:body_armor_regen_multiplier(moving, health_ratio)
	local multiplier = 1
	multiplier = multiplier * self:upgrade_value("player", "armorer_armor_regen_mul", 1)
	multiplier = multiplier * self:upgrade_value("player", "hitman_armor_regen", 1)
	
	
	if self:has_category_upgrade("player", "crook_vest_armor_regen") then
		local armor = tostring(override_armor or managers.blackmarket:equipped_armor(true, true))
		
		if crook_armor_types[armor] then
			multiplier = multiplier * self:upgrade_value("player", "crook_vest_armor_regen", 0)
		end
	end
	
	--log("regen_mul: " .. tostring(multiplier) .. "")
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

	return multiplier
end

function PlayerManager:skill_dodge_chance(running, crouching, on_zipline, override_armor, detection_risk)
	local chance = self:upgrade_value("player", "passive_dodge_chance", 0)
	local dodge_shot_gain = self:_dodge_shot_gain()
	
	local player_unit = self:local_player()

	for _, smoke_screen in ipairs(self._smoke_screen_effects or {}) do
		if smoke_screen:is_in_smoke(player_unit) then
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
	chance = chance + self:upgrade_value("player", "rogue_dodge_add", 0)
	chance = chance + self:upgrade_value("player", "expres_dodge_add", 0)
	if not self:has_activate_temporary_upgrade("temporary", "chico_injector") then
		if self:has_category_upgrade("player","kingpin_inactive_dodge_chance") then
			chance = chance + self:upgrade_value("player","kingpin_inactive_dodge_chance")
		end
	end
	
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
	
	if self:has_category_upgrade("player", "crook_vest_dodge_addend") then
		local armor = tostring(override_armor or managers.blackmarket:equipped_armor(true, true))
		
		if crook_armor_types[armor] then
			chance = chance + self:upgrade_value("player", "crook_vest_dodge_addend", 0)
		end
	end
	
	chance = chance + self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_dodge_addend", 0)
	chance = chance + self:upgrade_value("team", "crew_add_dodge", 0)
	chance = chance + self:temporary_upgrade_value("temporary", "pocket_ecm_kill_dodge", 0)

	if TCD_ENABLED then 
		if alive(player_unit) then
			local state = player_unit:movement():current_state()
			if state._state_data.meleeing then
				local melee_entry = managers.blackmarket:equipped_melee_weapon()
				local mtd = tweak_data.blackmarket.melee_weapons[melee_entry]
				if mtd.dodge_chance_bonus_while_charging then 
					chance = chance + mtd.dodge_chance_bonus_while_charging
				end
			end
		end
	end

	return chance
end

function PlayerManager:on_killshot(killed_unit, variant, headshot, weapon_id, weapon_unit)
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
	
	--vanilla copycat stuff
	local selection_index = equipped_unit and equipped_unit:base() and equipped_unit:base():selection_index() or 0
	local update_secondary_reload_primary = selection_index == 1 and self._has_secondary_reload_primary
	local update_primary_reload_secondary = selection_index == 2 and self._has_primary_reload_secondary
	
	if update_secondary_reload_primary then
		local kills_to_reload = self:upgrade_value("player", "secondary_reload_primary", 10)
		local secondary_kills = self:get_property("secondary_reload_primary_kills", 0) + 1

		if kills_to_reload <= secondary_kills then
			local primary_unit = player_unit:inventory():unit_by_selection(2)
			local primary_base = alive(primary_unit) and primary_unit:base()
			local can_reload = primary_base and primary_base.can_reload and primary_base:can_reload()

			if can_reload then
				primary_base:on_reload()
				managers.statistics:reloaded()
				managers.hud:set_ammo_amount(primary_base:selection_index(), primary_base:ammo_info())
			end

			secondary_kills = 0
		end

		self:set_property("secondary_reload_primary_kills", secondary_kills)
	elseif update_primary_reload_secondary then
		local kills_to_reload = self:upgrade_value("player", "primary_reload_secondary", 10)
		local primary_kills = self:get_property("primary_reload_secondary_kills", 0) + 1

		if kills_to_reload <= primary_kills then
			local secondary_unit = player_unit:inventory():unit_by_selection(1)
			local secondary_base = alive(secondary_unit) and secondary_unit:base()
			local can_reload = secondary_base and secondary_base.can_reload and secondary_base:can_reload()

			if can_reload then
				secondary_base:on_reload()
				managers.statistics:reloaded()
				managers.hud:set_ammo_amount(secondary_base:selection_index(), secondary_base:ammo_info())
			end

			primary_kills = 0
		end

		self:set_property("primary_reload_secondary_kills", primary_kills)
	end
	--^ copycat stuff
	
	if self:has_category_upgrade("player", "muscle_beachyboys") then
		local upgrade_data = self:upgrade_value("player","muscle_beachyboys")
		local stacks = self:get_property("muscle_beachyboys_bonus",0)
		local max_stacks = upgrade_data[2]
		if stacks < max_stacks then
			stacks = math.min(stacks + upgrade_data[1],max_stacks)
			self:set_property("muscle_beachyboys_bonus",stacks)
		end
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
				local enemies = world_g:find_units_quick("sphere", pos, area, 12, 21)

				for i = 1, #enemies do
					local unit = enemies[i]
					
					if unit:character_damage() then
						unit:character_damage():build_suppression(amount, chance)
					end
				end
			end
		end
	end
	
	if weapon_unit and weapon_unit:base()._HS_panic then
		local pos = killed_unit:position()
		local area = 600
		local amount = "panic"
		local enemies = world_g:find_units_quick("sphere", pos, area, 12, 21)

		for i = 1, #enemies do
			local unit = enemies[i]
			
			if unit:character_damage() then
				unit:character_damage():build_suppression(amount)
			end
		end
	end

	local t = Application:time()
	local damage_ext = player_unit:character_damage()

	if self:has_category_upgrade("player", "kill_change_regenerate_speed") then
		local amount = self:body_armor_value("skill_kill_change_regenerate_speed", nil, 1)
		local multiplier = self:upgrade_value("player", "kill_change_regenerate_speed", 0)

		damage_ext:change_regenerate_speed(amount * multiplier, tweak_data.upgrades.kill_change_regenerate_speed_percentage)
	end
	
	if self:has_category_upgrade("player", "expres_hot_election") then
		if damage_ext:armor_ratio() >= 1 then
			local expres_data = self:upgrade_value("player", "expres_hot_election", {0, 0})
			local stacks_to_generate = expres_data[1]
			local max_stacks = expres_data[2]
			
			if damage_ext._expres_election_stacks < max_stacks then
				damage_ext._expres_election_stacks = damage_ext._expres_election_stacks + stacks_to_generate

				local shown_stacks = damage_ext._expres_election_stacks * stacks_to_generate
				
				shown_stacks = math.min(shown_stacks, max_stacks)
				local stored_health_ratio = shown_stacks / max_stacks

				managers.hud:set_stored_health(stored_health_ratio)
			end
		end
	end
	
	if damage_ext then
		if self:has_category_upgrade("player", "grinder_killtohp") then
			damage_ext:restore_health(self:upgrade_value("player", "grinder_killtohp", 0))
		end
		
		if self:has_category_upgrade("player", "anarch_conversion") then
			if variant ~= "dot" and variant ~= "poison" then
				local regenerate = 0
				
				regenerate = self:upgrade_value("player", "anarch_onkill_armor_regen", 0)
				
				if headshot then
					regenerate = regenerate + self:upgrade_value("player", "anarch_onheadshotkill_armor_regen", 0)
				end
				
				if regenerate > 0 then
					damage_ext:restore_armor(regenerate)
				end
			end
		end
	
		if variant == "melee" then
			damage_ext:restore_health(self:upgrade_value("player", "infiltrator_melee_heal", 0))
			damage_ext:restore_armor_percent(self:upgrade_value("player", "infiltrator_armor_restore", 0))
		else
			local equipped_unit = alive(weapon_unit) and weapon_unit or self:get_current_state()._equipped_unit:base()
				
			if equipped_unit:is_category("saw") and variant == "bullet" then
				damage_ext:restore_health(self:upgrade_value("player", "infiltrator_melee_heal", 0))
				damage_ext:restore_armor_percent(self:upgrade_value("player", "infiltrator_armor_restore", 0))
			end
		end
	end
	
	local gain_throwable_per_kill = managers.player:upgrade_value("team", "crew_throwable_regen", 0)

	if gain_throwable_per_kill ~= 0 then
		self._throw_regen_kills = (self._throw_regen_kills or 0) + 1

		if gain_throwable_per_kill < self._throw_regen_kills then
			managers.player:add_grenade_amount(1, true)

			self._throw_regen_kills = 0
		end
	end
	
	if variant == "melee" then
		 self._next_lunge_t = nil
		 self._can_lunge = true
	end
	
	local dist_sq = mvector3.distance_sq(player_unit:movement():m_pos(), killed_unit:movement():m_pos())
	
	if self:has_category_upgrade("player", "sociopath_mode") then
		local range = self:has_category_upgrade("player", "sociopath_combo_master") and 2250000 or 1000000
		local throwing_add = self:has_category_upgrade("player", "sociopath_throwing_combo")
		
		local combo_stacks_threshold = tweak_data.upgrades.values.player.sociopath_combo_stack_restore_hp_threshold
		
		local combo_stacks = self._combo_stacks or 0
		local combo_stacks_start = combo_stacks
		local next_combo_diff = combo_stacks_threshold - (combo_stacks % combo_stacks_threshold)
		local next_combo_reward = combo_stacks + next_combo_diff 
		
		if weapon_unit then
			if throwing_add then
				if weapon_unit:base()._primary_class == "class_throwing" then
					combo_stacks = combo_stacks + 2
				end
			end
		end
			
		if dist_sq <= range then
			self._combo_timer = t + tweak_data.upgrades.values.player.sociopath_combo_duration
			
			local melee_add = self:has_category_upgrade("player", "sociopath_melee_combo")
			local saw_add = self:has_category_upgrade("player", "sociopath_saw_combo")
			
			combo_stacks = combo_stacks + 1
			
			if self:has_category_upgrade("player", "sociopath_melee_combo") then
				if variant == "melee" then
					combo_stacks = combo_stacks + 1
				end
			end		
			
			if self:has_category_upgrade("player", "sociopath_saw_combo") then
				local equipped_unit = alive(weapon_unit) and weapon_unit:base() or self:get_current_state()._equipped_unit:base()
				
				if equipped_unit:is_category("saw") and variant == "bullet" then
					combo_stacks = combo_stacks + 1
				end
			end
		end
		
		if self._combo_stacks ~= combo_stacks then
			if combo_stacks >= next_combo_reward then
				local diff = combo_stacks - next_combo_reward
				local num_rewards = 1 + math.floor(diff / combo_stacks_threshold)
				damage_ext:restore_health(num_rewards, true)
			end
			self._combo_stacks = combo_stacks
			Hooks:Call("TCD_OnSociopathComboStacksChanged",combo_stacks_start,combo_stacks)
		end
	end
	
	if self._on_killshot_t and t < self._on_killshot_t then
		return
	end

	local regen_armor_bonus = self:upgrade_value("player", "killshot_regen_armor_bonus", 0)
	local close_combat_sq = tweak_data.upgrades.close_combat_distance * tweak_data.upgrades.close_combat_distance

	if dist_sq <= close_combat_sq then
		regen_armor_bonus = regen_armor_bonus + self:upgrade_value("player", "killshot_close_regen_armor_bonus", 0)
		local panic_chance = self:upgrade_value("player", "killshot_close_panic_chance", 0)
		panic_chance = managers.modifiers:modify_value("PlayerManager:GetKillshotPanicChance", panic_chance)

		if panic_chance > 0 or panic_chance == -1 then
			local slotmask = managers.slot:get_mask("enemies")
			local units = world_g:find_units_quick("sphere", player_unit:movement():m_pos(), tweak_data.upgrades.killshot_close_panic_range, slotmask)

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

function PlayerManager:on_damage_dealt(unit, damage_info)
	local player_unit = self:player_unit()

	if not player_unit then
		return
	end

	local t = Application:time()

	if self:has_category_upgrade("player", "damage_to_hot") then
		self:_check_damage_to_hot(t, unit, damage_info)
	end
	
	self:_check_damage_to_cops(t, unit, damage_info)
	
	local damage_ext = player_unit:character_damage()
	
	if self:has_category_upgrade("player", "anarch_conversion") then
		if damage_info.variant ~= "dot" and damage_info.variant ~= "poison" and type(damage_info.damage) == "number" then
			local regenerate = 0
			
			regenerate = self:upgrade_value("player", "anarch_ondmg_armor_regen", 0)
			
			if damage_info.headshot then
				regenerate = regenerate + self:upgrade_value("player", "anarch_onheadshotdmg_armor_regen", 0)
			end
			
			if regenerate > 0 then
				damage_ext:restore_armor(regenerate)
			end
		end
	end

	if self:has_category_upgrade("player", "grinder_dmgtohp") then
		if damage_info.variant ~= "dot" and damage_info.variant ~= "poison" and type(damage_info.damage) == "number" then
			local mul = self:upgrade_value("player", "grinder_dmgtohp", 0)
			local damage = damage_info.damage
			local hp_to_restore = damage * mul
			damage_ext:restore_health(hp_to_restore, true)
		end
	end
	
	if self:has_category_upgrade("player", "infiltrator_melee_stance_DR") then
		local current_state = self:get_current_state()
		
		if damage_info.variant == "melee" then
			self._melee_stance_dr_t = t + 5
		else
			local equipped_unit = current_state._equipped_unit:base()
			
			if equipped_unit:is_category("saw") and damage_info.variant == "bullet" then
				self._melee_stance_dr_t = t + 5
			end
		end
	end

	if self._on_damage_dealt_t and t < self._on_damage_dealt_t then
		return
	end

	self._on_damage_dealt_t = t + (tweak_data.upgrades.on_damage_dealt_cooldown or 0)
end

function PlayerManager:player_destroyed(id)
	self._players[id] = nil
	self._respawn = true

	if id == 1 then
		if self._marked_enemies then
			for u_key, unit in pairs_g(self._marked_enemies) do
				if alive(unit) then
					unit:contour():remove("hostage_trade")
				end
			end
		end
		
		self._marked_enemies = nil
		self._next_drain_damage_t = nil
		self._yakuza_charging_t = nil
	
		self:clear_timers()
	end
end

function PlayerManager:_upd_sociopath_combo_master(player_unit, t)
	if not player_unit or not alive(player_unit) then
		return
	end

	local last_check_t = self._rasmus_check_t

	if last_check_t and t < last_check_t then
		return
	end

	self._rasmus_check_t = t + 0.2

	local prev_enemies = self._marked_enemies
	local enemies = world_g:find_units_quick("sphere", player_unit:movement():m_pos(), 1500, managers.slot:get_mask("enemies"))
	local cur_enemies = {}

	--local line1 = Draw:brush(Color.blue:with_alpha(0.5), 0.1)
	--line1:sphere(self:m_pos(), 1000)

	for i = 1, #enemies do
		local enemy = enemies[i]
		local u_key = enemy:key()

		if not prev_enemies or not prev_enemies[u_key] then
			if enemy:contour() then
				enemy:contour():add("hostage_trade")
			end
		end

		cur_enemies[u_key] = enemy
	end

	if prev_enemies then
		for u_key, unit in pairs_g(prev_enemies) do
			if not cur_enemies[u_key] and alive_g(unit) then
				unit:contour():remove("hostage_trade")
			end
		end
	end

	self._marked_enemies = cur_enemies
end

local right_hand_ids = Idstring("a_weapon_right")
local left_hand_ids = Idstring("a_weapon_left")
local yakuza_bleed_ids = Idstring("effects/pd2_mod_gageammo/particles/character/yakuza_selfdamage")

function PlayerManager:update(t, dt)
	self._message_system:update()
	self:_update_timers(t)

	if self._need_to_send_player_status then
		self._need_to_send_player_status = nil

		self:need_send_player_status()
	end
	
	self._sent_player_status_this_frame = nil
	
	local player_unit = self:player_unit()
	
	if not self._can_lunge then
		if not self._next_lunge_t then
			self._next_lunge_t = 5
		else
			self._next_lunge_t = self._next_lunge_t - dt
			
			if self._next_lunge_t <= 0 then
				self._can_lunge = true
			end
		end
	end
		
	
	
	if player_unit then
		if self:has_category_upgrade("player", "close_to_hostage_boost") and (not self._hostage_close_to_local_t or self._hostage_close_to_local_t <= t) then
			self._is_local_close_to_hostage = alive(player_unit) and managers.groupai and managers.groupai:state():is_a_hostage_within(player_unit:movement():m_pos(), tweak_data.upgrades.hostage_near_player_radius)
			self._hostage_close_to_local_t = t + tweak_data.upgrades.hostage_near_player_check_t
		end
		
		local current_state = self:get_current_state()
		
		if current_state then
			if self:has_category_upgrade("class_heavy", "lead_farmer_neo") then		
				local lead_farmer_data = self:upgrade_value("class_heavy", "lead_farmer_neo", {0.2, 2})
				self._next_lead_farmer_t = not self._next_lead_farmer_t and lead_farmer_data[2] or self._next_lead_farmer_t - dt
				
				if self._next_lead_farmer_t <= 0 then
					self._next_lead_farmer_t = lead_farmer_data[2]
					
					if player_unit:inventory() then
						local was_ammo_updated = nil
						local can_reload_from_bipod = self:current_state() == "bipod" and self:has_category_upgrade("class_heavy", "lead_farmer_bipod_reload")
						
						local inventory_available_selections = player_unit:inventory():available_selections()
						local number_of_available_selections = table.size(inventory_available_selections)
						local current_equipped_selection = player_unit:inventory()._equipped_selection
						
						for i = 1, number_of_available_selections do
							if i ~= current_equipped_selection or can_reload_from_bipod then
								local weapon_unit = inventory_available_selections[i].unit
								
								if alive(weapon_unit) then
									local weapon_unit_base = weapon_unit:base()
									local weapon_tweak_data = weapon_unit_base:weapon_tweak_data()
									local primary_category = weapon_tweak_data.primary_class
									
									if primary_category and primary_category == "class_heavy" then
										local ammo_total = weapon_unit_base:get_ammo_total()
										local ammo_in_clip = weapon_unit_base:get_ammo_remaining_in_clip()
										
										if ammo_total > ammo_in_clip then
											local ammo_max_per_clip = weapon_unit_base:get_ammo_max_per_clip()

											if ammo_in_clip < ammo_max_per_clip then
												local to_add = math.floor(ammo_max_per_clip * lead_farmer_data[1])
												local new_amount = math.min(math.min(ammo_max_per_clip, ammo_in_clip + to_add), ammo_total)
												
												weapon_unit_base:set_ammo_remaining_in_clip(new_amount)
												
												was_ammo_updated = true
											end
										end
									end
								end
							end
						end

						if was_ammo_updated then
							for id, weapon in pairs(inventory_available_selections) do
								local weapon_unit_base = weapon.unit:base()
								managers.hud:set_ammo_amount(id, weapon_unit_base:ammo_info())
							end
						end
					end
				end
			end

			if current_state.in_melee and current_state:in_melee() then
				if self:has_category_upgrade("player", "yakuza_frenzy_dr") then
					local damage_ext = player_unit:character_damage()
					
					if damage_ext:health_ratio() > 0.5 then
						if self._next_drain_damage_t then
							if self._next_drain_damage_t <= 0 then
								self._next_drain_damage_t = 1
								local damage_to_take = damage_ext:_max_health() * 0.05
								
								if self:has_category_upgrade("player", "wcard_thorns") then
									damage_ext:do_thorns(damage_to_take)
								end
								
								local new_health = damage_ext:get_real_health() - damage_to_take
								
								damage_ext:set_health(new_health)
								
								player_unit:sound():play("knife_hit_body")
								player_unit:sound():play("knuckles_hit_body")

								local camera = player_unit and player_unit:camera()
								local camera_unit = camera and camera._camera_unit
								
								if camera_unit then
									local righthand = camera_unit:get_object(right_hand_ids)
									local lefthand = camera_unit:get_object(left_hand_ids)
									
									camera:play_shaker("player_bullet_damage", 0.1)
									world_g:effect_manager():spawn({effect = yakuza_bleed_ids, parent = righthand})
									world_g:effect_manager():spawn({effect = yakuza_bleed_ids, parent = lefthand})
								end
							else
								self._next_drain_damage_t = self._next_drain_damage_t - dt
							end
						elseif not self._yakuza_charging_t  then
							self._yakuza_charging_t = 5
						elseif self._yakuza_charging_t > 0 then
							self._yakuza_charging_t = self._yakuza_charging_t - dt
						else
							self._next_drain_damage_t = 0
						end
					end
				elseif self:has_category_upgrade("player", "infiltrator_melee_stance_DR") then
					self._melee_stance_dr_t = t + 5
				end
			else
				if self:has_category_upgrade("player", "yakuza_frenzy_dr") then 
					self._yakuza_charging_t = nil
					self._next_drain_damage_t = nil
				elseif self:has_category_upgrade("player", "infiltrator_melee_stance_DR") then
					local equipped_unit = current_state._equipped_unit:base()
					
					if equipped_unit:is_category("saw") then
						self._melee_stance_dr_t = t + 5
					end
				end
			end
		end
		
		if not managers.groupai:state()._whisper_mode then
			if self._rasmus_check_t or self:has_category_upgrade("player", "sociopath_combo_master") then
				self:_upd_sociopath_combo_master(player_unit, t)
			end
		end
		
		if self._combo_timer and self._combo_timer < t then
			Hooks:Call("TCD_OnSociopathComboStacksChanged",self._combo_stacks,0)
			self._combo_stacks = 0
		end
		
		if self._melee_stance_dr_t and self._melee_stance_dr_t < t then
			self._melee_stance_dr_t = nil
		end
	end

	self:_update_damage_dealt(t, dt)

	if #self._global.synced_cocaine_stacks >= 4 then
		local amount = 0

		for i, stack in pairs(self._global.synced_cocaine_stacks) do
			if stack.in_use then
				amount = amount + stack.amount
			end

			if PlayerManager.TARGET_COCAINE_AMOUNT <= amount then
				managers.achievment:award("mad_5")
			end
		end
	end

	self._coroutine_mgr:update(t, dt)
	self._action_mgr:update(t, dt)

	if self._unseen_strike and not self._coroutine_mgr:is_running(PlayerAction.UnseenStrike) then
		local data = self:upgrade_value("player", "unseen_increased_crit_chance", 0)

		if data ~= 0 then
			self._coroutine_mgr:add_coroutine(PlayerAction.UnseenStrike, PlayerAction.UnseenStrike, self, data.min_time, data.max_duration, data.crit_chance)
		end
	end

	self:update_smoke_screens(t, dt)
end
