
local _G = _G
local io = io
local file = file

deathvox.ModPath = deathvox:GetPath()

deathvox.SavePath = SavePath
deathvox.SaveName = "crackdown.txt"
deathvox.SavePathFull = deathvox.SavePath .. deathvox.SaveName

--If you are creating a menu option that should apply instantly, use Settings; 
--Else, if you want a menu option that should only apply on restart/reload, use Session_Settings.

--options as saved to your BLT save file 
deathvox.Settings = {
--	useHoppipOverhaul = true, --deprecated; left as an example to others
	useTotalCDOverhaul = true
}

--whitelist: options on this list will be accepted by other clients; if options are not on this list, clients will ignore them and not apply these synced options (from host) on the client's end
deathvox.syncable_options = {
--	useTotalCDOverhaul = true
--	useHoppipOverhaul = true --deprecated; left as an example to others
}

--populated only on load, not on changed menu. keep this empty
deathvox.Session_Settings = {}

--string ids for network syncing stuff
deathvox.NetworkIDs = {
	Overhauls = "overhauls"
}

--matchmaking keys to lock lobbies to others using crackdown or crackdown overhaul
deathvox.mm_key_default = "crackdown-release-1-92222"
deathvox.mm_key_overhaul = "crackdown-total-experimental-1-02032023"

--main menu id; all other menu ids should be in their menu's .txt files
deathvox.blt_menu_id = "deathvox_menu_main"

--for reference in projectilestweakdata and playerinventorygui, for item class preview icons
deathvox.tcd_gui_data = {
	weapons = {
		class = {
			class_grenade = "guis/textures/pd2/blackmarket/icons/tcd/class_grenade",
			class_heavy = "guis/textures/pd2/blackmarket/icons/tcd/class_heavy",
			class_melee = "guis/textures/pd2/blackmarket/icons/tcd/class_melee",
			class_precision = "guis/textures/pd2/blackmarket/icons/tcd/class_precision",
			class_rapidfire = "guis/textures/pd2/blackmarket/icons/tcd/class_rapidfire",
			class_saw = "guis/textures/pd2/blackmarket/icons/tcd/class_saw",
			class_shotgun = "guis/textures/pd2/blackmarket/icons/tcd/class_shotgun",
			class_specialist = "guis/textures/pd2/blackmarket/icons/tcd/class_specialist",
			class_throwing = "guis/textures/pd2/blackmarket/icons/tcd/class_throwing"
		},
		subclass = {
			subclass_areadenial = "guis/textures/pd2/blackmarket/icons/tcd/subclass_areadenial",
			subclass_poison = "guis/textures/pd2/blackmarket/icons/tcd/subclass_poison",
			subclass_quiet = "guis/textures/pd2/blackmarket/icons/tcd/subclass_quiet"
		}
	}
}

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
	
function deathvox:IsTotalCrackdownEnabled()
	return self.Settings.useTotalCDOverhaul
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
	
--	self:check_for_updates()

--	log("Loaded menu settings")
	return self.Settings
end

function deathvox:ChangeSetting(key,value) --called when changing settings
	self.Settings[key] = value
		
	if game_state_machine then 
		if GameStateFilters.player_slot[game_state_machine:current_state_name()] then
--				if not managers.network:session() or table.size(managers.network:session():peers()) <= 0 then 
			deathvox.Session_Settings[key] = value
--				end
		end
	end
end

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

--load contents now, as well as on menu load
deathvox:Load()


-- Voice Framework Setup
local C = blt_class()
VoicelineFramework = C
VoicelineFramework.BufferedSounds = {}

function C:register_unit(unit_name)
	--log("VF: Registering Unit, " .. unit_name)
	if deathvox._voiceline_framework then
		deathvox._voiceline_framework.BufferedSounds[unit_name] = {}
	end
end

function C:register_line_type(unit_name, line_type)
	if deathvox._voiceline_framework then
		if deathvox._voiceline_framework.BufferedSounds[unit_name] then
			--log("VF: Registering Type, " .. line_type .. " for Unit " .. unit_name)
			local buffered_sounds = deathvox._voiceline_framework.BufferedSounds[unit_name]
			buffered_sounds[line_type] = {}
		end
	end
end

function C:register_voiceline(unit_name, line_type, path)
	if deathvox._voiceline_framework then
		if deathvox._voiceline_framework.BufferedSounds[unit_name] then
			local buffered_sounds = deathvox._voiceline_framework.BufferedSounds[unit_name]
			if buffered_sounds[line_type] then
				--log("VF: Registering Path, " .. path .. " for Unit " .. unit_name)
				table.insert(buffered_sounds[line_type], XAudio.Buffer:new(path))
			end
		end
	end
end
--Hooks:Register("crackdown_on_setup_voiceline_framework")

if not deathvox._voiceline_framework then
	blt.xaudio.setup()
	local voiceline_framework = VoicelineFramework:new()
	deathvox._voiceline_framework = voiceline_framework
	Hooks:Call("crackdown_on_setup_voiceline_framework",voiceline_framework)
end  



---------------------------
-- Options Menu Creation --
---------------------------

--creates empty menu entries for the main menu and the overhauls submenu, to be populated with options later
local menu_id = deathvox.blt_menu_id
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_deathvox", function(menu_manager, nodes)
	MenuHelper:NewMenu( menu_id )
	MenuHelper:NewMenu("deathvox_menu_overhauls")
end)

--populates the menu with data from the json file; this data should have a menu id matching one you created in the above MenuManagerSetupCustomMenus hook
Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus_deathvox", function(menu_manager, nodes)
	MenuHelper:LoadFromJsonFile(deathvox.ModPath .. "menu/menu_overhauls.txt", deathvox, deathvox.Settings)

	local overhaul_is_installed = not not _G.deathvox_overhaul
	MenuHelper:AddToggle({
		id = "deathvox_toggle_totalcd",
		title = "deathvox_toggle_totalcd_title",
		desc = "deathvox_toggle_totalcd_desc",
		callback = "callback_deathvox_toggle_totalcd",
		value = deathvox:IsTotalCrackdownEnabled(),
		disabled = not overhaul_is_installed,
		menu_id = "deathvox_menu_overhauls",
		priority = 1
	})	
	
end)

--i just used this to create the main crackdown menu; you probably don't need to change/add to this if you just want more submenus
Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_deathvox", function(menu_manager, nodes)
	nodes[menu_id] = MenuHelper:BuildMenu( menu_id )
	
	--place the crackdown menu in the main menu instead of the mod options menu
	MenuHelper:AddMenuItem( nodes.options, menu_id, "deathvox_menu_main_title", "deathvox_menu_main_desc","blt_options","before")
	
end)

-- Currently, the menu is only set up to save on changing the only option extant so far (ie put Save() in every new menu option entry)
-- Optionally, I can make a manual save button and prompt the user to save when there are unsaved options,
	-- or save automatically only when exiting the menu		
Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_deathvox", function(menu_manager)

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
			NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY = deathvox.mm_key_overhaul
		else
			NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY = deathvox.mm_key_default
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