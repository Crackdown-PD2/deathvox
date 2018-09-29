function LevelsTweakData:get_ai_group_type() -- We don't have support for or use the russians/zombies, so we can use this to easily swap visuals for "factions" based on difficulty.
	local group_to_use = "zeal" 			 -- Aka, instead of 1500 difficulty if's to change the group based on what difficulty it is, we can just instead change what faction it's looking for.
											 -- This makes swapping difficulties on the fly much, much easier, along with maintaining a clean codebase.
	if not Global.game_settings then
		return group_to_use
	end
	local difficulties = {
		"easy",
		"normal",
		"hard",
		"overkill",
		"overkill_145",
		"easy_wish",
		"overkill_290",
		"sm_wish"
	}
	local diff_index = table.index_of(difficulties, Global.game_settings.difficulty)
	if diff_index <= 3 then
		group_to_use = "cop"
	elseif diff_index <= 5 then
		group_to_use = "fbi"
	elseif diff_index <= 7 then
		group_to_use = "gensec"
	end
	return group_to_use
end
