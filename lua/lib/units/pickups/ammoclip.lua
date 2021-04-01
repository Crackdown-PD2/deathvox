AmmoClip.EVENT_IDS = {
	bonnie_share_ammo = 1
}

local math_random = math.random
local math_floor = math.floor
local math_round = math.round
local math_clamp = math.clamp

local pairs_g = pairs

local alive_g = alive

local ammo_pickup_ids = Idstring("units/pickups/ammo/ammo_pickup")

local CABLE_TIE_GET_CHANCE = 0.2
local CABLE_TIE_GET_AMOUNT = 1

function AmmoClip:init(unit)
	AmmoClip.super.init(self, unit)

	self._ammo_type = ""

	if self._unit:name() ~= ammo_pickup_ids then
		return
	end

	self._ammo_box = true

	self:reload_contour()
end

function AmmoClip:reload_contour()
	if not self._ammo_box then
		return
	end

	local contour_ext = self._unit:contour()

	if not contour_ext then
		return
	end

	if managers.user:get_setting("ammo_contour") then
		contour_ext:add("deployable_selected")
	else
		contour_ext:remove("deployable_selected")
	end
end

if deathvox:IsTotalCrackdownEnabled() then 
	function AmmoClip:_pickup(unit)
		if self._picked_up then
			return
		end

		local damage_ext = unit:character_damage()

		if not damage_ext or damage_ext:dead() then
			return
		end

		local inventory = unit:inventory()

		if not inventory then
			return
		end

		local player_manager = managers.player
		local throwable_id = self._projectile_id
		local picked_up, is_projectile_or_throwable = false

		if throwable_id then
			is_projectile_or_throwable = true

			if not player_manager:got_max_grenades() and managers.blackmarket:equipped_projectile() == throwable_id then
				player_manager:add_grenade_amount(self._ammo_count or 1, true)

				picked_up = true
			end
		else
			local projectile_category = self._weapon_category
			local ammo_count = self._ammo_count
			is_projectile_or_throwable = projectile_category and true

			if ammo_count then
				local valid_weapons = {}

				for id, weapon in pairs_g(inventory:available_selections()) do
					if inventory:is_equipped(id) then
						if not projectile_category or projectile_category == weapon.unit:base():weapon_tweak_data().categories[1] then
							if #valid_weapons > 0 then
								local new_table = {
									weapon
								}

								for idx = 1, #valid_weapons do
									new_table[#new_table + 1] = valid_weapons[idx]
								end

								valid_weapons = new_table
							else
								valid_weapons[#valid_weapons + 1] = weapon
							end
						end
					elseif not projectile_category or projectile_category == weapon.unit:base():weapon_tweak_data().categories[1] then
						valid_weapons[#valid_weapons + 1] = weapon
					end
				end

				for i = 1, #valid_weapons do
					local weapon = valid_weapons[i]
					local success, add_amount = weapon.unit:base():add_ammo(1, ammo_count)

					if success then
						picked_up = true

						ammo_count = math_floor(ammo_count - add_amount)
						ammo_count = ammo_count < 0 and 0 or ammo_count

						if ammo_count <= 0 then
							break
						end
					end
				end

				self._ammo_count = ammo_count
			else
				for id, weapon in pairs_g(inventory:available_selections()) do
					if weapon.unit:base():add_ammo(1) then
						picked_up = true
					end
				end
			end

			if picked_up and projectile_category then
				local achiev_data = tweak_data.achievement.pickup_sticks

				if achiev_data and projectile_category == achiev_data.weapon_category then
					managers.achievment:award_progress(achiev_data.stat)
				end
			end
		end

		if picked_up then
			self._picked_up = true

			local session = managers.network:session()
			local my_unit = self._unit
			local is_ammo_box = nil

			if not is_projectile_or_throwable then
				is_ammo_box = self._ammo_box

				if is_ammo_box and math_random() <= CABLE_TIE_GET_CHANCE then
					player_manager:add_cable_ties(CABLE_TIE_GET_AMOUNT)
				end

				if player_manager:has_category_upgrade("temporary", "loose_ammo_restore_health") and not player_manager:has_activate_temporary_upgrade("temporary", "loose_ammo_restore_health") then
					player_manager:activate_temporary_upgrade("temporary", "loose_ammo_restore_health")

					local values = player_manager:temporary_upgrade_value("temporary", "loose_ammo_restore_health", 0)

					if values ~= 0 then
						local restore_tweak_data = tweak_data.upgrades.loose_ammo_restore_health_values
						local restore_value = math_random(values[1], values[2])

						if player_manager:has_category_upgrade("player", "loose_ammo_restore_health_give_team") then
							local sync_value = math_round(math_clamp(restore_value - restore_tweak_data.base, 0, 14))

							session:send_to_peers_synched("sync_unit_event_id_16", my_unit, "pickup", 2 + sync_value)
						end

						local restore_multiplier = restore_tweak_data.multiplier or 0.1
						restore_value = restore_value * restore_multiplier

						local percent_inc = player_manager:upgrade_value("player", "gain_life_per_players", 0)

						if percent_inc ~= 0 then
							if player_manager:num_connected_players() > 0 then
								percent_inc = percent_inc * player_manager:num_players_with_more_health()
							end

							percent_inc = percent_inc + 1

							restore_value = restore_value * percent_inc
						end

						if not damage_ext:need_revive() and not damage_ext:dead() and not damage_ext:is_berserker() then
							damage_ext:restore_health(restore_value, true)
							unit:sound():play("pickup_ammo_health_boost")
						end
					end
				end

				--ammo sharing no longer requires an ability
				session:send_to_peers_synched("sync_unit_event_id_16", my_unit, "pickup", AmmoClip.EVENT_IDS.bonnie_share_ammo)
			end

			if Network:is_client() then
				local server_peer = session:server_peer()

				if server_peer then
					--queuing this message along with the (potential) ones above
					--will ensure it arrives in the correct order, as the send_to_host function doesn't do this normally
					session:send_to_peer_synched(server_peer, "sync_pickup", my_unit)
				end
			end

			unit:sound():play(self._pickup_event or "pickup_ammo")
			self:consume()

			if is_ammo_box then
				player_manager:send_message(Message.OnAmmoPickup, nil, unit)
			end

			return true
		end

		return false
	end

	function AmmoClip:sync_net_event(event, peer)
		local player = managers.player:local_player()

		if not alive_g(player) then
			return
		end

		local damage_ext = player:character_damage()

		if not damage_ext or damage_ext:dead() then
			return
		end

		if event == AmmoClip.EVENT_IDS.bonnie_share_ammo then
			local inventory = player:inventory()

			if not inventory then
				return
			end

			local nr_alive_players = managers.groupai:state():num_alive_players()
			local add_ratio = 1 / nr_alive_players

			local hud_manager = managers.hud
			local hud_set_ammo_f = hud_manager.set_ammo_amount
			local picked_up = false

			for id, weapon in pairs_g(inventory:available_selections()) do
				local weap_base = weapon.unit:base()

				if weap_base:add_ammo(add_ratio) then
					picked_up = true

					hud_set_ammo_f(hud_manager, id, weap_base:ammo_info())
				end
			end

			if picked_up then
				player:sound():play(self._pickup_event or "pickup_ammo")
			end
		elseif AmmoClip.EVENT_IDS.bonnie_share_ammo < event and not damage_ext:need_revive() and not damage_ext:is_berserker() then
			local upgrades_data = tweak_data.upgrades
			local restore_health_values = upgrades_data.loose_ammo_restore_health_values
			local base_value = restore_health_values.base or 3
			local restore_multiplier = restore_health_values.multiplier or 0.1
			local share_restore_ratio = upgrades_data.loose_ammo_give_team_health_ratio or 0.35

			local restore_value = base_value + event - 2
			restore_value = restore_value * restore_multiplier * share_restore_ratio

			if damage_ext:restore_health(restore_value, true, true) then
				player:sound():play("pickup_ammo_health_boost")
			end
		end
	end
else
	function AmmoClip:_pickup(unit)
		if self._picked_up then
			return
		end

		local damage_ext = unit:character_damage()

		if not damage_ext or damage_ext:dead() then
			return
		end

		local inventory = unit:inventory()

		if not inventory then
			return
		end

		local player_manager = managers.player
		local throwable_id = self._projectile_id
		local picked_up, is_projectile_or_throwable = false

		if throwable_id then
			is_projectile_or_throwable = true

			if not player_manager:got_max_grenades() and managers.blackmarket:equipped_projectile() == throwable_id then
				player_manager:add_grenade_amount(self._ammo_count or 1, true)

				picked_up = true
			end
		else
			local projectile_category = self._weapon_category
			local ammo_count = self._ammo_count
			is_projectile_or_throwable = projectile_category and true

			if ammo_count then
				local valid_weapons = {}

				for id, weapon in pairs_g(inventory:available_selections()) do
					if inventory:is_equipped(id) then
						if not projectile_category or projectile_category == weapon.unit:base():weapon_tweak_data().categories[1] then
							if #valid_weapons > 0 then
								local new_table = {
									weapon
								}

								for idx = 1, #valid_weapons do
									new_table[#new_table + 1] = valid_weapons[idx]
								end

								valid_weapons = new_table
							else
								valid_weapons[#valid_weapons + 1] = weapon
							end
						end
					elseif not projectile_category or projectile_category == weapon.unit:base():weapon_tweak_data().categories[1] then
						valid_weapons[#valid_weapons + 1] = weapon
					end
				end

				for i = 1, #valid_weapons do
					local weapon = valid_weapons[i]
					local success, add_amount = weapon.unit:base():add_ammo(1, ammo_count)

					if success then
						picked_up = true

						ammo_count = math_floor(ammo_count - add_amount)
						ammo_count = ammo_count < 0 and 0 or ammo_count

						if ammo_count <= 0 then
							break
						end
					end
				end

				self._ammo_count = ammo_count
			else
				for id, weapon in pairs_g(inventory:available_selections()) do
					if weapon.unit:base():add_ammo(1) then
						picked_up = true
					end
				end
			end

			if picked_up and projectile_category then
				local achiev_data = tweak_data.achievement.pickup_sticks

				if achiev_data and projectile_category == achiev_data.weapon_category then
					managers.achievment:award_progress(achiev_data.stat)
				end
			end
		end

		if picked_up then
			self._picked_up = true

			local session = managers.network:session()
			local my_unit = self._unit
			local is_ammo_box = nil

			if not is_projectile_or_throwable then
				is_ammo_box = self._ammo_box

				if is_ammo_box and math_random() <= CABLE_TIE_GET_CHANCE then
					player_manager:add_cable_ties(CABLE_TIE_GET_AMOUNT)
				end

				if player_manager:has_category_upgrade("temporary", "loose_ammo_restore_health") and not player_manager:has_activate_temporary_upgrade("temporary", "loose_ammo_restore_health") then
					player_manager:activate_temporary_upgrade("temporary", "loose_ammo_restore_health")

					local values = player_manager:temporary_upgrade_value("temporary", "loose_ammo_restore_health", 0)

					if values ~= 0 then
						local restore_tweak_data = tweak_data.upgrades.loose_ammo_restore_health_values
						local restore_value = math_random(values[1], values[2])

						if player_manager:has_category_upgrade("player", "loose_ammo_restore_health_give_team") then
							local sync_value = math_round(math_clamp(restore_value - restore_tweak_data.base, 0, 14))

							session:send_to_peers_synched("sync_unit_event_id_16", my_unit, "pickup", 2 + sync_value)
						end

						local restore_multiplier = restore_tweak_data.multiplier or 0.1
						restore_value = restore_value * restore_multiplier

						local percent_inc = player_manager:upgrade_value("player", "gain_life_per_players", 0)

						if percent_inc ~= 0 then
							if player_manager:num_connected_players() > 0 then
								percent_inc = percent_inc * player_manager:num_players_with_more_health()
							end

							percent_inc = percent_inc + 1

							restore_value = restore_value * percent_inc
						end

						if not damage_ext:need_revive() and not damage_ext:dead() and not damage_ext:is_berserker() then
							damage_ext:restore_health(restore_value, true)
							unit:sound():play("pickup_ammo_health_boost")
						end
					end
				end

				if player_manager:has_category_upgrade("temporary", "loose_ammo_give_team") and not player_manager:has_activate_temporary_upgrade("temporary", "loose_ammo_give_team") then
					player_manager:activate_temporary_upgrade("temporary", "loose_ammo_give_team")

					session:send_to_peers_synched("sync_unit_event_id_16", my_unit, "pickup", AmmoClip.EVENT_IDS.bonnie_share_ammo)
				end
			end

			if Network:is_client() then
				local server_peer = session:server_peer()

				if server_peer then
					--queuing this message along with the (potential) ones above
					--will ensure it arrives in the correct order, as the send_to_host function doesn't do this normally
					session:send_to_peer_synched(server_peer, "sync_pickup", my_unit)
				end
			end

			unit:sound():play(self._pickup_event or "pickup_ammo")
			self:consume()

			if is_ammo_box then
				player_manager:send_message(Message.OnAmmoPickup, nil, unit)
			end

			return true
		end

		return false
	end

	function AmmoClip:sync_net_event(event, peer)
		local player = managers.player:local_player()

		if not alive_g(player) then
			return
		end

		local damage_ext = player:character_damage()

		if not damage_ext or damage_ext:dead() then
			return
		end

		if event == AmmoClip.EVENT_IDS.bonnie_share_ammo then
			local inventory = player:inventory()

			if not inventory then
				return
			end

			local add_ratio = tweak_data.upgrades.loose_ammo_give_team_ratio or 0.25
			local hud_manager = managers.hud
			local hud_set_ammo_f = hud_manager.set_ammo_amount
			local picked_up = false

			for id, weapon in pairs_g(inventory:available_selections()) do
				local weap_base = weapon.unit:base()

				if weap_base:add_ammo(add_ratio) then
					picked_up = true

					hud_set_ammo_f(hud_manager, id, weap_base:ammo_info())
				end
			end

			if picked_up then
				player:sound():play(self._pickup_event or "pickup_ammo")
			end
		elseif AmmoClip.EVENT_IDS.bonnie_share_ammo < event and not damage_ext:need_revive() and not damage_ext:is_berserker() then
			local upgrades_data = tweak_data.upgrades
			local restore_health_values = upgrades_data.loose_ammo_restore_health_values
			local base_value = restore_health_values.base or 3
			local restore_multiplier = restore_health_values.multiplier or 0.1
			local share_restore_ratio = upgrades_data.loose_ammo_give_team_health_ratio or 0.35

			local restore_value = base_value + event - 2
			restore_value = restore_value * restore_multiplier * share_restore_ratio

			if damage_ext:restore_health(restore_value, true, true) then
				player:sound():play("pickup_ammo_health_boost")
			end
		end
	end
end
