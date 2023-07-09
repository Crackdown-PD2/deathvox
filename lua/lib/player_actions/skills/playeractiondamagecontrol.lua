PlayerAction.DamageControl = {
	Priority = 1,
	Function = function ()
		local timer = TimerManager:game()
		local auto_shrug_time = nil
		local cooldown_drain = managers.player:upgrade_value("player", "damage_control_cooldown_drain")
		local damage_delay_values = managers.player:has_category_upgrade("player", "damage_control_passive") and managers.player:upgrade_value("player", "damage_control_passive")
		local auto_shrug_delay = managers.player:has_category_upgrade("player", "damage_control_auto_shrug") and managers.player:upgrade_value("player", "damage_control_auto_shrug")
		local shrug_healing = managers.player:has_category_upgrade("player", "damage_control_healing") and managers.player:upgrade_value("player", "damage_control_healing") * 0.01
		
		local has_damage_resist_on_shrug = managers.player:has_category_upgrade("player","stoic_damage_resist_on_stagger")
		local damage_resist_on_shrug_amount,damage_resist_on_shrug_duration 
		if has_damage_resist_on_shrug then
			local upgrade_data = managers.player:upgrade_value("player","stoic_damage_resist_on_stagger")
			damage_resist_on_shrug_amount = upgrade_data[1]
			damage_resist_on_shrug_duration = upgrade_data[2]
		end
		
		local has_cooldown_on_receive_damage = managers.player:has_category_upgrade("player","stoic_cooldown_drain_on_damaged")
		local cooldown_on_receive_damage_amount,on_damage_cooldown_duration
		if has_cooldown_on_receive_damage then
			local upgrade_data = managers.player:upgrade_value("player","stoic_cooldown_drain_on_damaged")
			cooldown_on_receive_damage_amount = upgrade_data[1]
			on_damage_cooldown_duration = upgrade_data[2]
		end
		
		
		if not damage_delay_values then
			return
		end
		local stagger_timer_increase = managers.player:upgrade_value("player","stoic_stagger_time_increase",0)
		
		damage_delay_values = {
			delay_ratio = damage_delay_values[1] * 0.01,
			tick_ratio = (stagger_timer_increase + damage_delay_values[2]) * 0.01
		}
		cooldown_drain = {
			health_ratio = cooldown_drain[1] * 0.01,
			seconds_below = cooldown_drain[2],
			seconds_above = managers.player:upgrade_value_by_level("player", "damage_control_cooldown_drain", 1)[2]
		}

		local function shrug_off_damage()
			local player_unit = managers.player:player_unit()
			if player_unit then
				local player_damage = player_unit:character_damage()
				local remaining_damage = player_damage:clear_delayed_damage()
				local is_downed = game_state_machine:verify_game_state(GameStateFilters.downed)
				local swan_song_active = managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier")

				if is_downed or swan_song_active then
					return
				end

				if shrug_healing then
					player_damage:restore_health(remaining_damage * shrug_healing, true)
				end
				
				if has_damage_resist_on_shrug then
					managers.player:activate_temporary_property("stoic_damage_resist_bonus",damage_resist_on_shrug_amount,damage_resist_on_shrug_duration)
				end
				
			end

			auto_shrug_time = nil
		end

		local function modify_damage_taken(amount, attack_data)
			local is_downed = game_state_machine:verify_game_state(GameStateFilters.downed)

			if attack_data.variant == "delayed_tick" or is_downed then
				return
			end

			local player_damage = managers.player:player_unit():character_damage()
			local removed = amount * damage_delay_values.delay_ratio
			local duration = 1 / damage_delay_values.tick_ratio

			player_damage:delay_damage(removed, duration)

			if auto_shrug_delay then
				auto_shrug_time = timer:time() + auto_shrug_delay
			end

			return -removed
		end

		local function on_ability_activated(ability_name)
			if ability_name == "damage_control" then
				shrug_off_damage()
			end
		end

		local function on_enemy_killed(weapon_unit, variant, enemy_unit)
			local player = managers.player:player_unit()
			local low_health = player:character_damage():health_ratio() <= cooldown_drain.health_ratio
			local seconds = low_health and cooldown_drain.seconds_below or cooldown_drain.seconds_above

			if player then
				managers.player:speed_up_grenade_cooldown(seconds)
			end
		end

		local on_check_skills_key = {}
		local on_enemy_killed_key = {}
		local on_ability_activated_key = {}

		managers.player:register_message(Message.OnEnemyKilled, on_enemy_killed_key, on_enemy_killed)
		managers.player:register_message("ability_activated", on_ability_activated_key, on_ability_activated)
		
		if has_cooldown_on_receive_damage then
			local player = managers.player:local_player()
			if alive(player) then
				local dmg_ext = player:character_damage()
				dmg_ext:add_listener("stoic_on_damaged",{"on_damage"},function()
					if not managers.player:has_active_temporary_property("stoic_on_damage_cooldown") then
						managers.player:activate_temporary_property("stoic_on_damage_cooldown",true,on_damage_cooldown_duration)
						managers.player:speed_up_grenade_cooldown(cooldown_on_receive_damage_amount)
					end
				end)
			end
		end
		
		Hooks:Add("TCD_Stoic_OnDoctorBagBaseInteraction","tcd_stoic_docbag_clear_staggered_damage",function()
			if managers.player:has_category_upgrade("player","stoic_meds_clears_staggered_damage") then
				shrug_off_damage()
			end
		end)
		
		local damage_taken_key = managers.player:add_modifier("damage_taken", modify_damage_taken)

		local function remove_listeners()
			managers.player:unregister_message("check_skills", on_check_skills_key)
			managers.player:unregister_message(Message.OnEnemyKilled, on_enemy_killed_key)
			managers.player:unregister_message("ability_activated", on_ability_activated_key)
			managers.player:remove_modifier("damage_taken", damage_taken_key)
			local player = managers.player:local_player()
			if alive(player) then
				local dmg_ext = player:character_damage()
				if dmg_ext then
					dmg_ext:remove_listener("stoic_on_damaged")
				end
			end
			Hooks:Remove("tcd_stoic_docbag_clear_staggered_damage")
		end

		managers.player:register_message("check_skills", on_check_skills_key, remove_listeners)
		
		while true do
			coroutine.yield()
			local now = timer:time()

			if auto_shrug_time and auto_shrug_time <= now then
				shrug_off_damage()
			end
		end
	end
}
