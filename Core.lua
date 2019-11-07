local _G = _G
local io = io
local file = file

local function deathvox_init_menus()
--[[
	Startup stuff for menus and such,
	I don't really know where else to put this such that the load order would permit it
	-offy
--]]

	--checks whether or not hoppip's overhaul is enabled;
	--If you are creating a menu option that should apply instantly, use Settings; 
	--Else, if you want a menu option that should only apply on restart/reload, use Session_Settings.
	function deathvox:IsHoppipOverhaulEnabled()
		return self.Session_Settings.useHoppipOverhaul 
	end

	--generic load/save functions; menu option savefiles are currently located at PAYDAY 2/mods/saves/crackdown.txt
	function deathvox:Save(override_tbl)
		local file = io.open(self.SavePathFull,"w+")
		if file then
			file:write(json.encode((type(override_tbl) == "table" and override_tbl) or self.Settings))
			file:close()
		end
	end

	function deathvox:ResetSessionSettings()
		self.Session_Settings = {}
	end

	function deathvox:Load()
		local file = io.open(self.SavePathFull, "r")
		if (file) then
			for k, v in pairs(json.decode(file:read("*all"))) do
				self.Settings[k] = v --these settings are applied instantly
				self.Session_Settings[k] = v --these settings are only written (ie. applied) on restart
			end
		else
			self:Save()
		end
		log("Loaded menu settings")
		return self.Settings
	end
	
	function deathvox:ChangeSetting(key,state) --called when changing settings
		self.Settings[key] = state
		--The below code would allow settings changed mid-game to apply immediately if the game is offline/populated by only host. It's disabled but you can enable it if you want
		--[[ 
		if not managers.network:session() or table.size(managers.network:session():peers()) <= 0 then 
			deathvox.Session_Settings[key] = state
		end
		--]]
	end

	Hooks:Add("NetworkReceivedData", "NetworkReceivedData_deathvox", function(sender, message, data)
		if sender == 1 then --only accept sync data from host
			if message == deathvox.NetworkIDs.Overhauls then
				deathvox:SyncOptionsFromHost(data)
			--other sync data interpretation can go here
			end
		end
	end)
	
	function deathvox:SyncOptionsFromHost(str)
		local synced_options = str and LuaNetworking:StringToTable(str)
		if not synced_options then 
			log("CRACKDOWN: ERROR: Bad sync options")
			self.Session_Settings = self.Session_Settings or {}
		else
			for item,value in pairs(synced_options) do 
				if self.syncable_options[item] then 
					self.Session_Settings[item] = value
				end
			end
		end

	end
	
	function deathvox:SyncOptionsToClients() --all clients
		local network_string = LuaNetworking:TableToString(self.Session_Settings)
		
		LuaNetworking:SendToPeers(deathvox.NetworkIDs.Overhauls,network_string)
	end
	
	function deathvox:SyncOptionsToClient(peer_id) --single target client; for late joins
		local network_string = LuaNetworking:TableToString(self.Session_Settings)
		
		LuaNetworking:SendToPeer(peer_id,deathvox.NetworkIDs.Overhauls,network_string)
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
	
		MenuCallbackHandler.callback_deathvox_close_overhauls = function(self)
--			deathvox:Save()
		end
		deathvox:Load()		
	end)

end
if not _G.deathvox then
	_G.deathvox = {}
	_G.deathvox.ModPath = ModPath
	_G.deathvox.SavePath = SavePath
	_G.deathvox.SaveName = "crackdown.txt"
	_G.deathvox.SavePathFull = deathvox.SavePath .. deathvox.SaveName
	deathvox.Settings = { --options as saved to your BLT save file 
		useHoppipOverhaul = true
	}
	deathvox.syncable_options = { --whitelist: options on this list will be accepted by other clients; if options are not on this list, clients will ignore them and not apply these synced options (from host) on the client's end
		useHoppipOverhaul = true
	}
	deathvox.Session_Settings = {} --populated only on load, not on changed menu. keep this empty
	deathvox.NetworkIDs = { --string ids for network syncing stuff
		Overhauls = "overhauls"
	}
	deathvox.blt_menu_id = "deathvox_menu_main" --main menu id; all other menu ids should be in their menu's .txt files
	
	blt.xaudio.setup()
	local deathvox_mod_instance = ModInstance
	log("==============Loading Crackdown Assets==============")
	log("Loading Crackdown Cops")
	deathvox_mod_instance:GetSuperMod():GetAssetLoader():LoadAssetGroup("cops")
	log("Loading SWAT Cops")
	deathvox_mod_instance:GetSuperMod():GetAssetLoader():LoadAssetGroup("copcops")
	log("Loading FBI Cops")
	deathvox_mod_instance:GetSuperMod():GetAssetLoader():LoadAssetGroup("fbicops")
	log("Loading Gensec Cops")
	deathvox_mod_instance:GetSuperMod():GetAssetLoader():LoadAssetGroup("genseccops")
	log("Loading Classic Cops")
	deathvox_mod_instance:GetSuperMod():GetAssetLoader():LoadAssetGroup("classiccops")
	--log("Loading Murkywater Units") uncomment to load murkywater assets. does nothing currently, as there's no assets yet.
	--deathvox_mod_instance:GetSuperMod():GetAssetLoader():LoadAssetGroup("murkywater")	
	
	deathvox_init_menus() 
	log("Finished loading!")
	
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
