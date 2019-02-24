function LevelsTweakData:get_ai_group_type() -- We can use this to easily swap visuals for "factions" based on difficulty.
	local group_to_use = "zeal" 			 
	-- Instead of if statements, we can just instead change what faction it's looking for.
	-- This makes swapping difficulties on the fly much, much easier, along with maintaining a clean codebase.
	local level_id
	if Global.level_data and Global.level_data.level_id then
		level_id = Global.level_data.level_id
	end
	
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
	local map_faction_override = {}
	--map_faction_override["Enemy_Spawner"] = "classic"
	map_faction_override["pal"] = "classic"
	map_faction_override["dah"] = "classic"
	map_faction_override["red2"] = "classic"
	map_faction_override["glace"] = "classic"
	map_faction_override["run"] = "classic"
	map_faction_override["flat"] = "classic"
	map_faction_override["dinner"] = "classic"
	map_faction_override["man"] = "classic"
	map_faction_override["nmh"] = "classic"
	-- whurr's map edits
	map_faction_override["bridge"] = "classic"
	map_faction_override["apartment"] = "classic"
	map_faction_override["street"] = "classic"
	map_faction_override["bank"] = "classic"
	-- todo: setup akan on BP, murky on all murky heists, and classics on classic heists
	local diff_index = table.index_of(difficulties, Global.game_settings.difficulty)
	if diff_index <= 3 then
		group_to_use = "cop"
	elseif diff_index <= 5 then
		group_to_use = "fbi"
	elseif diff_index <= 7 then
		group_to_use = "gensec"
	end
	if level_id then
		if map_faction_override[level_id] then
			group_to_use = map_faction_override[level_id]
		end
	end
	if diff_index == 8 then -- zeal units on CD for all maps.
		group_to_use = "zeal"
	end
	return group_to_use
end

-- fix for safehouse raid failing to spawn assault group enemies. Base heist uses "safehouse" data that clones beseige.
local old_level_init = LevelsTweakData.init
function LevelsTweakData:init()
    old_level_init(self)
    self.chill_combat.group_ai_state = "besiege"
end
