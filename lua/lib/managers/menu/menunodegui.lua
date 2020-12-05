--key is the global (_G) table value associated with the mod in question
--value is the localized name of that mod to display to the user; as is evident, it does not strictly have to be only the name of the mod.
local warned_mods = {
    ["BB"] = "Better Bots",
    ["FullSpeedSwarm"] = "Full Speed Swarm",
    ["Iter"] = "Iter",
    ["HoxHUD"] = "HoxHUD? At this day and age? Okey-dokey then.",
    ["SC"] = "Restoration Mod"
}

Hooks:PostHook(MenuNodeGui,"_setup_item_rows","crackdown_mod_incompatibility_warning",function(self,node,...)
    local title = "Potential Mod Compatibility Issues"
    local desc = "Caution! You have the following AI-changing mods installed, which may conflict with CRACKDOWN:\n"
    local has_any
    for key,mod_name in pairs(warned_mods) do 
        if rawget(_G,key) then 
            has_any = true
            desc = desc .. "\n" .. mod_name
        end
    end
    
    if has_any then 
       desc = desc .. "\n" .. "Fug says: Using AI mods with Crackdown can, and probably WILL crash your game!"
       QuickMenu:new(
           title,
           desc,
           {
                {
                    title = "What could possibly go wrong?",
                    is_cancel_button = true
                }
            }
       ,true)
    end
	
	local current_ver = 666
	local new_ver_string = deathvox.received_version
	
	if not deathvox.has_shown_update_warning and new_ver_string and current_ver < tonumber(new_ver_string) then
		title = "Crackdown has a new update!"
		desc = "Visit the ModWorkshop page or the Discord server to acquire it!"
		QuickMenu:new(
			title,
			desc,
			{
				{
					title = "OK, got it!",
					is_cancel_button = true
				}
			}
		,true)
		deathvox.has_shown_update_warning = true
	end
	
end)
