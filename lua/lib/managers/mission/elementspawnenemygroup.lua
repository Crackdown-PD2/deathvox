function ElementSpawnEnemyGroup:spawn_groups()
	local opt = {}
	for cat_name, team in pairs(tweak_data.group_ai.enemy_spawn_groups) do
		table.insert(opt, cat_name)
	end
	return opt
end