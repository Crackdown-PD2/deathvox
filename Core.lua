local _G = _G
local io = io
local file = file


if not (_G.deathvox and deathvox.HAS_LOADED_ASSETS) then
	_G.deathvox = deathvox or {}
	deathvox.ModPath = deathvox.ModPath or ModPath
	deathvox.SavePath = deathvox.SavePath or SavePath
	deathvox.HAS_LOADED_ASSETS = true

--loads radialmousemenu and sentrycontrolmenu (they don't do anything unless total cd is enabled)
	dofile(deathvox.ModPath .. "classes/radialmousemenu.lua")
	dofile(deathvox.ModPath .. "classes/sentrycontrolmenu.lua")
	dofile(deathvox.ModPath .. "classes/tripminecontrolmenu.lua")

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

	blt.xaudio.setup()
	
	--local deathvox_mod_instance = ModInstance
	--log("==============Loading Crackdown Assets==============")
	--log("Loading Crackdown Cops")
	--deathvox_mod_instance:GetSuperMod():GetAssetLoader():LoadAssetGroup("cops")
	--log("Loading SWAT Cops")
	--deathvox_mod_instance:GetSuperMod():GetAssetLoader():LoadAssetGroup("copcops")
	--log("Loading FBI Cops")
	--deathvox_mod_instance:GetSuperMod():GetAssetLoader():LoadAssetGroup("fbicops")
	--log("Loading Gensec Cops")
	--deathvox_mod_instance:GetSuperMod():GetAssetLoader():LoadAssetGroup("genseccops")
	--log("Loading Classic Cops")
	--deathvox_mod_instance:GetSuperMod():GetAssetLoader():LoadAssetGroup("classiccops")
	--log("Loading Murkywater Units") uncomment to load murkywater assets. does nothing currently, as there's no assets yet.
	--deathvox_mod_instance:GetSuperMod():GetAssetLoader():LoadAssetGroup("murkywater")	
	
	--log("Finished loading!")
	
	if _G.voiceline_framework then
		_G.voiceline_framework:register_unit("grenadier")
		local fuck =  Application:nice_path( "./" .. ModPath .. "assets/oggs/voiceover/grenadier", true )
		for index, directory in pairs(file.GetDirectories(fuck)) do
			local ass = Application:nice_path( "./" .. ModPath .. "assets/oggs/voiceover/grenadier/" .. directory, true )
			_G.voiceline_framework.register_line_type("go fuck yourself lua", "grenadier", tostring(directory))
			for index2, filez in pairs(file.GetFiles(ass)) do
				_G.voiceline_framework:register_voiceline("grenadier", tostring(directory), ModPath .. "assets/oggs/voiceover/grenadier/" .. tostring(directory) .. "/" .. tostring(filez))
			end
		end
		
		--[[_G.voiceline_framework:register_unit("pdth")
		local fuck =  Application:nice_path( "./" .. ModPath .. "assets/oggs/voiceover/pdth", true )
		for index, directory in pairs(file.GetDirectories(fuck)) do
			local ass = Application:nice_path( "./" .. ModPath .. "assets/oggs/voiceover/pdth/" .. directory, true )
			_G.voiceline_framework.register_line_type("go fuck yourself lua", "pdth", tostring(directory))
			for index2, filez in pairs(file.GetFiles(ass)) do
				_G.voiceline_framework:register_voiceline("pdth", tostring(directory), ModPath .. "assets/oggs/voiceover/pdth/" .. tostring(directory) .. "/" .. tostring(filez))
			end
		end
		
		_G.voiceline_framework:register_unit("pdthdozer")
		local fuck =  Application:nice_path( "./" .. ModPath .. "assets/oggs/voiceover/pdthdozer", true )
		for index, directory in pairs(file.GetDirectories(fuck)) do
			local ass = Application:nice_path( "./" .. ModPath .. "assets/oggs/voiceover/pdthdozer/" .. directory, true )
			_G.voiceline_framework.register_line_type("go fuck yourself lua", "pdthdozer", tostring(directory))
			for index2, filez in pairs(file.GetFiles(ass)) do
				_G.voiceline_framework:register_voiceline("pdthdozer", tostring(directory), ModPath .. "assets/oggs/voiceover/pdthdozer/" .. tostring(directory) .. "/" .. tostring(filez))
			end
		end
		
		_G.voiceline_framework:register_unit("medicdozer")
		_G.voiceline_framework:register_line_type("medicdozer", "heal")
		for i = 1, 31 do
			_G.voiceline_framework:register_voiceline("medicdozer", "heal", ModPath .. "assets/oggs/voiceover/medicdozer/heal" .. i .. ".ogg")
		end]]--
		_G.deathvox.grenadier_gas_duration = 15
	else
		
	end
end
