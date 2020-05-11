--key is the global (_G) table value associated with the mod in question
--value is the localized name of that mod to display to the user; as is evident, it does not strictly have to be only the name of the mod.
local warned_mods = {
    ["BB"] = "Better Bots",
    ["FullSpeedSwarm"] = "Full Speed Swarm",
    ["Iter"] = "Iter",
    ["HoxHUD"] = "HoxH- wait, HoxHUD? Seriously? Why, and also how, and then looping back around again to the \"why?\"",
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
       desc = desc .. "\n" .. "KITH SAYS YOU'RE A HUGE FUCKING IDIOT FOR TRYING TO USE AN AI MOD WITH ANOTHER AI MOD, HOPE THAT HELPS"
       QuickMenu:new(
           title,
           desc,
           {
                {
                    title = "ok FINE MOM GOD",
                    is_cancel_button = true
                }
            }
       ,true)
    end
end)
