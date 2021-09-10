PlayerAction.TagTeam = {
	Priority = 1,
	Function = function (tagged, owner)
		local pm = managers.player
		local owner_damage_ext = owner:character_damage()
		local base_values = pm:upgrade_value("player","tag_team_base_deathvox")
		local health_regen_rate = pm:upgrade_value("player","tag_team_health_regen",0)
		
		local duration = base_values.duration + pm:upgrade_value("player","tag_team_duration_increase",0)
		local cooldown_drain = pm:upgrade_value("player", "tag_team_cooldown_drain",false)
		local move_speed_bonus = pm:upgrade_value("player","tag_team_movement_speed_bonus",0)
		local damage_resistance_bonus = pm:upgrade_value("player","tag_team_damage_resistance",0)
		local timer = TimerManager:game()
		local end_time = timer:time() + duration
		local on_damage_key = string.format("tagteam_activation_%i",timer:time())
		
		
		local function on_hit_cb(damage_info)
			if cooldown_drain then 
				local was_killed = damage_info.result.type == "death"
				local valid_player = damage_info.attacker_unit == owner or damage_info.attacker_unit == tagged

				if was_killed and valid_player then
					pm:speed_up_grenade_cooldown(damage_info.attacker_unit == owner and cooldown_drain.owner or cooldown_drain.tagged)
				end
			end
		end

		--set tagteam flags active for damage resist/movement speed bonus calculation
		--timers are technically dissociated from the function duration of the actual tagteam coroutine
		if pm:has_category_upgrade("player","tag_team_effect_empathy") then 
			pm:activate_temporary_property("deathvox_tag_team_bonus_movement_speed",duration,move_speed_bonus)
			pm:activate_temporary_property("deathvox_tag_team_bonus_damage_resistance",duration,damage_resistance_bonus)
		end
		
		--sync tag team begin to peers (no dynamic duration extending effects anyway so this will always be either 5 or 10 sec)
		managers.network:session():send_to_peers("sync_tag_team", tagged, owner)
		managers.hud:activate_teammate_ability_radial(HUDManager.PLAYER_PANEL, end_time - timer:time(), duration)
		
		local dt = 0
		local t = timer:time()
		while alive(owner) and timer:time() < end_time do 
			--coroutine.yield() in this context, inside of a playeraction coroutine, seems to return the tagged unit and the owner unit instead of dt
			--(probably because player actions are a coroutine to begin with, and this defined function takes the tagged/owner from said coroutine)
			--so, fine! we'll make our own dt! with blackjack! and hookers!
			dt = timer:time() - t

			if health_regen_rate ~= 0 then 
				owner_damage_ext:restore_health(health_regen_rate * dt,false,true)
			end
			t = timer:time()
			coroutine.yield()
		end
		
		--removal of tagteam active flags is automatic
--		pm:remove_property("deathvox_tag_team_bonus_movement_speed")
--		pm:remove_property("deathvox_tag_team_bonus_damage_resistance")

		--unregister listeners for on-kill effects
		CopDamage.register_listener(on_damage_key,
			{
				"on_damage"
			},
			on_hit_cb
		)
		
		
		--sync tag team ended to peers
		managers.network:session():send_to_peers("end_tag_team", tagged, owner)
	end
}
PlayerAction.TagTeamTagged = {
	Priority = 1,
	Function = function (tagged, owner)
		if tagged ~= managers.player:local_player() then
			return
		end
		
		local huskbase = owner:base()
		if not huskbase then 
			log("ERROR: PlayerAction.TagTeamTagged: No player base for tagging owner " .. tostring(owner) .. ". Incoming Tag Team action cancelled.")
			return
		end
		
		local timer = TimerManager:game()
		local pm = managers.player
		local tagged_damage_ext = tagged:character_damage()
		
		local base_values = huskbase:upgrade_value("player","tag_team_base_deathvox") or {duration = tweak_data.blackmarket.projectiles.tag_team.duration}
		
		local health_regen_rate = huskbase:upgrade_value("player","tag_team_health_regen") or 0
		
		local duration = base_values.duration + huskbase:upgrade_value("player","tag_team_duration_increase") or 0
		local move_speed_bonus = huskbase:upgrade_value("player","tag_team_movement_speed_bonus") or 0
		local damage_resistance_bonus = huskbase:upgrade_value("player","tag_team_damage_resistance") or 0
		local end_time = timer:time() + duration

		local ended_by_owner = false
		local on_end_key = string.format("tagteam_end_%i",timer:time())

		local function on_action_end(end_tagged, end_owner)
			local tagged_match = tagged == end_tagged
			local owner_match = owner == end_owner
			ended_by_owner = tagged_match and owner_match
		end

		managers.player:add_listener(on_end_key, {
			"tag_team_end"
		}, on_action_end)
		
		
		--set tagteam flags active for damage resist/movement speed bonus calculation
		--since a player can be tagged by multiple sources at once, this refreshes the timer
		pm:activate_temporary_property("deathvox_tag_team_bonus_movement_speed",duration,move_speed_bonus)
		pm:activate_temporary_property("deathvox_tag_team_bonus_damage_resistance",duration,damage_resistance_bonus)
		
		local dt = 0
		local t = timer:time()
		while not ended_by_owner and alive(tagged) and (alive(owner) or timer:time() < end_time) do
			dt = timer:time() - t
			
			if health_regen_rate ~= 0 then 
				owner_damage_ext:restore_health(health_regen_rate * dt,false,true)
			end
			t = timer:time()
			
			coroutine.yield()
		end
		

		managers.player:remove_listener(on_end_key)
	end
}
