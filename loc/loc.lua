Hooks:Add("LocalizationManagerPostInit", "DeathVox_Localization", function(loc)
	local group_type = tweak_data.levels:get_ai_group_type()
	local federales = tweak_data.levels.ai_groups.federales
	local level = Global.level_data and Global.level_data.level_id
	
	local loc_path = deathvox.ModPath .. "loc/"
	
	if group_type == federales then
		loc:load_localization_file(loc_path .. "federalesnames.txt")
	elseif level == "pex" or level == "skm_bex" or level == "bex" then --forcefully load beat cop and hrt names on these levels so that they dont get overridden by cd diff killfeed/hoplib/whatever
		loc:load_localization_file(loc_path .. "federalespersistentnames.txt")
	end
	
	if group_type == murkywater then
		loc:load_localization_file(loc_path .. "murkynames.txt")
	elseif level == "bph" or level == "vit" or level == "des" or level == "pbr" then 
		loc:load_localization_file(loc_path .. "murkypersistentnames.txt")
	end	
end)