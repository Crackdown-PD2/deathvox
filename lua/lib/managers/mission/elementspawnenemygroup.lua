function i_hate_lua(list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

function ElementSpawnEnemyGroup:spawn_groups()
	local dv_spawngroups = {
		"dv_group_1",
		"dv_group_2_std",
		"dv_group_2_med",
		"dv_group_3_std",
		"dv_group_3_med",
		"dv_group_4_std",
		"dv_group_4_med",
		"dv_group_5_std",
		"dv_group_5_med",
		"gorgon",
		"atlas",
		"chimera",
		"zeus",
		"janus",
		"epeius",
		"damocles",
		"caduceus",
		"atropos",
		"aegeas"
	}
	dv_spawngroups = i_hate_lua(dv_spawngroups)
	local opt = self._values.preferred_spawn_groups
	if not opt then
		opt = {}
	end
	for cat_name, team in pairs(tweak_data.group_ai.enemy_spawn_groups) do
		if dv_spawngroups[cat_name] then
			table.insert(opt, cat_name)
		end
	end
	return opt
end
