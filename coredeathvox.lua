
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
deathvox.mm_key_default = "crackdown-release-1-290623"
deathvox.mm_key_overhaul = "crackdown-total-experimental-1-290623"

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
	
	--[[
	if self:IsTotalCrackdownEnabled() then 
		NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY = deathvox.mm_key_overhaul
	else
		NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY = deathvox.mm_key_default
	end
	--]]
	
--	self:check_for_updates()

--	log("Loaded menu settings")
	return self.Settings
end

function deathvox:GetSetting(key)
	return self.Settings[key]
end

function deathvox:GetSessionSetting(key)
	return self.Session_Settings[key]
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
	
	LuaNetworking:SendToPeers(self.NetworkIDs.Overhauls,network_string)
end

function deathvox:SyncOptionsToClient(peer_id) --single target client; for late joins
	local network_string = LuaNetworking:TableToString(self.Session_Settings)
	
	LuaNetworking:SendToPeer(peer_id,self.NetworkIDs.Overhauls,network_string)
end

-- menu util
function deathvox.GetMenuItem(menu_id,item_id)
	local menu = MenuHelper:GetMenu(menu_id)
	if menu then
		-- necessary to get the index, 
		-- as item() does not return the index.
		-- technically could do (#items - (priority+1)) but the last item in the list also has nil priority so.
		-- better to just use the less efficient, more effective way.
		
		local items = menu._items
		if items then 
			for i,item in ipairs(items) do 
				if item:parameter("name") == item_id then
					return item,i
				end
			end
		end
		
		--return menu:item(item_id)
	end
end

--load contents now, as well as on menu load
deathvox:Load()

-- Voice Framework Setup

Hooks:Register("crackdown_on_setup_voiceline_framework")

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

if not deathvox._voiceline_framework then
	blt.xaudio.setup()
	local voiceline_framework = VoicelineFramework:new()
	deathvox._voiceline_framework = voiceline_framework
	Hooks:Call("crackdown_on_setup_voiceline_framework",voiceline_framework)
end  
