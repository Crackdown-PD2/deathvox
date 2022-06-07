function ElementSpawnEnemyGroup:_finalize_values()
	local values = self._values

	if values.team == "default" then
		values.team = nil
	end
	
	local has_regular_enemies = nil
	
	local preferreds = {}
	
	if not self._values.preferred_spawn_groups then --prevents a crash.
		self._values.preferred_spawn_groups = {}
		
		for cat_name, team in pairs(tweak_data.group_ai.enemy_spawn_groups) do
			if cat_name ~= "Phalanx" then
				table.insert(self._values.preferred_spawn_groups, cat_name)
			end
		end
		
		return
	end
	
	local has_regular_enemies = true
	
	for name, name2 in pairs(self._values.preferred_spawn_groups) do
		if name2 == "single_spooc" or name2 == "Phalanx" then --single_spooc means that the spawn point is meant for scripted cloakers
			has_regular_enemies = nil

			break
		end
	end
	
	if not has_regular_enemies then
		--nothing, do not change preferred groups
	else
		for cat_name, team in pairs(tweak_data.group_ai.enemy_spawn_groups) do
			if cat_name ~= "Phalanx" and cat_name ~= "Phalanx_minion" and cat_name ~= "single_spooc" then
				table.insert(preferreds, cat_name)
			end
		end
		
		self._values.preferred_spawn_groups = preferreds
	end
end