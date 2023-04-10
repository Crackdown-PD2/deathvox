local _G = _G
local io = io
local file = file


if not (_G.deathvox and deathvox.HAS_LOADED_ASSETS) then
	_G.deathvox = deathvox or {}
	deathvox.ModPath = deathvox.ModPath or ModPath
	deathvox.SavePath = deathvox.SavePath or SavePath
	deathvox.HAS_LOADED_ASSETS = true
	
	deathvox.tcd_icon_chars = {
		heavy = {
			character = "─",
			macro = "ICN_HVY",
		},
		grenade = {
			character = "┼",
			macro = "ICN_GRN"
		},
		area_denial = {
			character = "═",
			macro = "ICN_ARD"
		},
		throwing = {
			character = "╤",
			macro = "ICN_THR"
		},
		specialist = {
			character = "╥",
			macro = "ICN_SPC"
		},
		shotgun = {
			character = "╦",
			macro = "ICN_SHO"
		},
		saw = {
			character = "╧",
			macro = "ICN_SAW"
		},
		rapidfire = {
			character = "╨",
			macro = "ICN_RPF"
		},
		quiet = {
			character = "╩",
			macro = "ICN_QUT"
		},
		precision = {
			character = "╪",
			macro = "ICN_PRE"
		},
		poison = {
			character = "╫",
			macro = "ICN_POI"
		},
		melee = {
			character = "╬",
			macro = "ICN_MEL"
		}
	}
	
	function deathvox:insert_tcd_macros(macros)
		for _,v in pairs(deathvox.tcd_icon_chars) do  --just adds wpn class/subclass icon macros
			if v.macro and v.character then
				macros[v.macro] = v.character
			end
		end
	end
	
	--creates empty menu entries for the main menu and the overhauls submenu, to be populated with options later
	local menu_id = deathvox.blt_menu_id
	Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_deathvox", function(menu_manager, nodes)
		MenuHelper:NewMenu( menu_id )
		MenuHelper:NewMenu("deathvox_menu_overhauls")
	end)

	--populates the menu with data from the json file; this data should have a menu id matching one you created in the above MenuManagerSetupCustomMenus hook
	Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus_deathvox", function(menu_manager, nodes)
		MenuHelper:LoadFromJsonFile(deathvox.ModPath .. "menu/menu_overhauls.txt", deathvox, deathvox.Settings)
	end)

	--i just used this to create the main crackdown menu; you probably don't need to change/add to this if you just want more submenus
	Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_deathvox", function(menu_manager, nodes)
		nodes[menu_id] = MenuHelper:BuildMenu( menu_id )
		MenuHelper:AddMenuItem( nodes.options, menu_id, "deathvox_menu_main_title", "deathvox_menu_main_desc","blt_options","before") --creates the 
		
	end)

	-- Currently, the menu is only set up to save on changing the only option extant so far (ie put Save() in every new menu option entry)
	-- Optionally, I can make a manual save button and prompt the user to save when there are unsaved options,
		-- or save automatically only when exiting the menu		
	Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_deathvox", function(menu_manager)

		MenuCallbackHandler.callback_deathvox_toggle_hoppip = function(self,item) --on keypress
			local enabled = item:value() == "on"
			deathvox:ChangeSetting("useHoppipOverhaul",enabled)
			deathvox:Save()
		end
		MenuCallbackHandler.callback_deathvox_toggle_totalcd = function(self,item) --on keypress
			local enabled = item:value() == "on"
			deathvox:ChangeSetting("useTotalCDOverhaul",enabled)
			
			--quick and dirty fix
			--alternatively, close game immediately after to force a restart + apply game settings change?
			if enabled then 
				NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY = "crackdown-total-experimental-1"
			else
				NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY = "crackdown-release-1"
			end
			
			deathvox:Save()
		end

		MenuCallbackHandler.callback_deathvox_close_overhauls = function(self)
	--			deathvox:Save()
		end
		deathvox:Load()		
	end)

	Hooks:Add("NetworkReceivedData", "NetworkReceivedData_deathvox", function(sender, message, data)
		if sender == 1 then --only accept sync data from host
			if message == deathvox.NetworkIDs.Overhauls then
				deathvox:SyncOptionsFromHost(data)
			--other sync data interpretation can go here
			end
		end
	end)

	_G.deathvox.grenadier_gas_duration = 15
	--(9 apr) hey uh. what's this for? like, i can read, but i don't see any references to this... anywhere
	-- -offy
end
