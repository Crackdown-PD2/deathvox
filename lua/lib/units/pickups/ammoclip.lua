if deathvox:IsTotalCrackdownEnabled() then 
	AmmoClip.EVENT_IDS.cd_share_ammo = 15

	local CABLE_TIE_GET_CHANCE = 0.2
	local CABLE_TIE_GET_AMOUNT = 1

--give portions of ammo pickups to other players
	local orig_pickup = AmmoClip._pickup
	function AmmoClip:_pickup(unit,...)
		if self._picked_up or (unit ~= managers.player:local_player()) or self._projectile_id then 
			return orig_pickup(self,unit,...)
		end
		local player_manager = managers.player
		local inventory = unit:inventory()
		
		if not unit:character_damage():dead() and inventory then 
			local picked_up = false
			
			local available_selections = {}
			
			for i, weapon in pairs(inventory:available_selections()) do
				if inventory:is_equipped(i) then
					table.insert(available_selections, 1, weapon)
				else
					table.insert(available_selections, weapon)
				end
			end

			local success, add_amount = nil

			for _, weapon in ipairs(available_selections) do
				if not self._weapon_category or self._weapon_category == weapon.unit:base():weapon_tweak_data().categories[1] then
					success, add_amount = weapon.unit:base():add_ammo(1, self._ammo_count)
					
					picked_up = success or picked_up

					if self._ammo_count then
						self._ammo_count = math.max(math.floor(self._ammo_count - add_amount), 0)
					end
				end
			end
			
			if picked_up then 
				self._picked_up = true
				if math.random() <= CABLE_TIE_GET_CHANCE then 
					managers.player:add_cable_ties(CABLE_TIE_GET_AMOUNT)
				end
			
				if not self._weapon_category then 
					local restored_health
					
					if not unit:character_damage():is_downed() and player_manager:has_category_upgrade("temporary", "loose_ammo_restore_health") and not player_manager:has_activate_temporary_upgrade("temporary", "loose_ammo_restore_health") then
						player_manager:activate_temporary_upgrade("temporary", "loose_ammo_restore_health")
						
						local values = player_manager:temporary_upgrade_value("temporary", "loose_ammo_restore_health", 0)

						if values ~= 0 then
							local restore_value = math.random(values[1], values[2])
							local num_more_hp = 1

							if player_manager:num_connected_players() > 0 then
								num_more_hp = player_manager:num_players_with_more_health()
							end

							local base = tweak_data.upgrades.loose_ammo_restore_health_values.base
							local sync_value = math.round(math.clamp(restore_value - base, 0, 13))
							restore_value = restore_value * (tweak_data.upgrades.loose_ammo_restore_health_values.multiplier or 0.1)
							local percent_inc = player_manager:upgrade_value("player", "gain_life_per_players", 0) * num_more_hp + 1

							restore_value = restore_value * percent_inc
							local damage_ext = unit:character_damage()

							if not damage_ext:need_revive() and not damage_ext:dead() and not damage_ext:is_berserker() then
								damage_ext:restore_health(restore_value, true)
								unit:sound():play("pickup_ammo_health_boost", nil, true)
							end

							if player_manager:has_category_upgrade("player", "loose_ammo_restore_health_give_team") then
								managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "pickup", 2 + sync_value)
							end
						end
					end	
					
					-- ammo sharing no longer requires an ability
					managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "pickup", AmmoClip.EVENT_IDS.cd_share_ammo)
				end
				
				if Network:is_client() then 
					managers.network:session():send_to_host("sync_pickup",self._unit)
				end
				
				unit:sound():play(self._pickup_event or "pickup_ammo",nil,true)
				self:consume()
				
				if self._ammo_box then 
					player_manager:send_message(Message.OnAmmoPickup,nil,unit)
				end
				

				return true
			end
		end
		
		return false
	end

--receive ammo picked up message from other players,
--add shared ammo amount
	function AmmoClip:sync_net_event(event, peer)
		if event == AmmoClip.EVENT_IDS.register_grenade then --allow throwable registering even when the local player is downed/spectating/in custody
			if peer and not self._grenade_registered then
				managers.player:register_grenade(peer:id())

				self._grenade_registered = true
			end
		else
			local player = managers.player:local_player()

			if not alive(player) then
				return
			end

			local damage_ext = player:character_damage()

			if not damage_ext or damage_ext:dead() then
				return
			end

			if event == AmmoClip.EVENT_IDS.cd_share_ammo or event == AmmoClip.EVENT_IDS.bonnie_share_ammo then --allow ammo share receiving even when the local player is downed
				local inventory = player:inventory()

				if inventory then
					local add_ratio, picked_up = nil

					if event == AmmoClip.EVENT_IDS.cd_share_ammo then
						local nr_alive_players = managers.groupai:state():num_alive_players()

						add_ratio = 1 / nr_alive_players
					else
						add_ratio = tweak_data.upgrades.loose_ammo_give_team_ratio or 0.25
					end

					for id, weapon in pairs(inventory:available_selections()) do
						if weapon.unit:base():add_ammo(add_ratio) then
							picked_up = true

							managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
						end
					end

					if picked_up then
						player:sound():play(self._pickup_event or "pickup_ammo", nil, true)
					end
				end
			elseif AmmoClip.EVENT_IDS.bonnie_share_ammo < event and not damage_ext:need_revive() and not damage_ext:is_berserker() then --works as usual
				local base_value = tweak_data.upgrades.loose_ammo_restore_health_values.base or 3
				local restore_multiplier = tweak_data.upgrades.loose_ammo_restore_health_values.multiplier or 0.1
				local share_restore_ratio = tweak_data.upgrades.loose_ammo_give_team_health_ratio or 0.35

				local restore_value = base_value + event - 2
				restore_value = restore_value * restore_multiplier * share_restore_ratio

				if damage_ext:restore_health(restore_value, true, true) then
					player:sound():play("pickup_ammo_health_boost", nil, true)
				end
			end
		end
	end
end
