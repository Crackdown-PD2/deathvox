--broadly identical to vanilla but has a bool return value to indicate success
function GroupAIStateBase:convert_hostage_to_criminal(unit, peer_unit)
	local player_unit = peer_unit or managers.player:player_unit()

	if not alive(player_unit) or not self._criminals[player_unit:key()] then
		return
	end

	if not alive(unit) then
		return
	end

	local u_key = unit:key()
	local u_data = self._police[u_key]

	if not u_data then
		return
	end

	local minions = self._criminals[player_unit:key()].minions or {}
	self._criminals[player_unit:key()].minions = minions
	local max_minions = 0

	if peer_unit then
		max_minions = peer_unit:base():upgrade_value("player", "convert_enemies_max_minions") or 0
	else
		max_minions = managers.player:upgrade_value("player", "convert_enemies_max_minions", 0)
	end

	Application:debug("GroupAIStateBase:convert_hostage_to_criminal", "Player", player_unit, "Minions: ", table.size(minions) .. "/" .. max_minions)

	if alive(self._converted_police[u_key]) or max_minions <= table.size(minions) then
		local peer = managers.network:session():peer_by_unit(player_unit)

		if peer then
			if peer:id() == managers.network:session():local_peer():id() then
				managers.hint:show_hint("convert_enemy_failed")
			else
				managers.network:session():send_to_peer(peer, "sync_show_hint", "convert_enemy_failed")
			end
		end

		return
	end

	local group = u_data.group
	u_data.group = nil

	if group then
		self:_remove_group_member(group, u_key, nil)
	end

	self:set_enemy_assigned(nil, u_key)

	u_data.is_converted = true

	unit:brain():convert_to_criminal(peer_unit)

	local clbk_key = "Converted" .. tostring(player_unit:key())
	u_data.minion_death_clbk_key = clbk_key
	u_data.minion_destroyed_clbk_key = clbk_key

	unit:character_damage():add_listener(clbk_key, {
		"death"
	}, callback(self, self, "clbk_minion_dies", player_unit:key()))
	unit:base():add_destroy_listener(clbk_key, callback(self, self, "clbk_minion_destroyed", player_unit:key()))

	if not unit:contour() then
		debug_pause_unit(unit, "[GroupAIStateBase:convert_hostage_to_criminal]: Unit doesn't have Contour Extension")
	end

	unit:contour():add("friendly", nil, nil, not peer_unit and tweak_data.contour.character.friendly_minion_color)

	u_data.so_access = unit:brain():SO_access()

	self:_set_converted_police(u_key, unit, player_unit)

	minions[u_key] = u_data

	unit:movement():set_team(self._teams.converted_enemy)

	local convert_enemies_health_multiplier_level = 0
	local passive_convert_enemies_health_multiplier_level = 0

	if alive(peer_unit) then
		convert_enemies_health_multiplier_level = peer_unit:base():upgrade_level("player", "convert_enemies_health_multiplier") or 0
		passive_convert_enemies_health_multiplier_level = peer_unit:base():upgrade_level("player", "passive_convert_enemies_health_multiplier") or 0
	else
		convert_enemies_health_multiplier_level = managers.player:upgrade_level("player", "convert_enemies_health_multiplier")
		passive_convert_enemies_health_multiplier_level = managers.player:upgrade_level("player", "passive_convert_enemies_health_multiplier")
	end

	local owner_peer_id = managers.network:session():peer_by_unit(player_unit):id()

	managers.network:session():send_to_peers_synched("mark_minion", unit, owner_peer_id, convert_enemies_health_multiplier_level, passive_convert_enemies_health_multiplier_level)

	if not peer_unit then
		managers.player:count_up_player_minions()
	end

	managers.modifiers:run_func("OnMinionAdded")
	
	return true
end
