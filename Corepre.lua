_G.deathvox = deathvox or {}
--deathvox.ModPath = ModPath
deathvox.update_url = "https://raw.githubusercontent.com/Crackdown-PD2/deathvox/autoupdate/meta.json"
deathvox.ModPath = deathvox.ModPath or deathvoxcore:GetPath()

deathvox.SavePath = SavePath
deathvox.SaveName = "crackdown.txt"
deathvox.SavePathFull = deathvox.SavePath .. deathvox.SaveName
deathvox.Settings = { --options as saved to your BLT save file 
--	useHoppipOverhaul = true, --deprecated; left as an example to others
	useTotalCDOverhaul = true
}
deathvox.syncable_options = { --whitelist: options on this list will be accepted by other clients; if options are not on this list, clients will ignore them and not apply these synced options (from host) on the client's end
--	useHoppipOverhaul = true --deprecated; left as an example to others
}
deathvox.Session_Settings = {} --populated only on load, not on changed menu. keep this empty
deathvox.NetworkIDs = { --string ids for network syncing stuff
	Overhauls = "overhauls"
}

--matchmaking keys to lock lobbies to others using crackdown or crackdown overhaul
deathvox.mm_key_default = "crackdown-release-1-92222"
deathvox.mm_key_overhaul = "crackdown-total-experimental-1-02032023"

deathvox.blt_menu_id = "deathvox_menu_main" --main menu id; all other menu ids should be in their menu's .txt files

deathvox.tcd_gui_data = { --for reference in projectilestweakdata and playerinventorygui, for item class preview icons
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

--If you are creating a menu option that should apply instantly, use Settings; 
--Else, if you want a menu option that should only apply on restart/reload, use Session_Settings.

function deathvox:set_update_data(json_data)
	if json_data:is_nil_or_empty() then
		log("deathvox: received nil update data")
		return
	end
	
	local received_data = json.decode(json_data)
	
	for _, data in pairs(received_data) do
		if data.version then
			deathvox.received_version = data.version
			log("deathvox update data received")
			break
		end
	end
end

function deathvox:check_for_updates()
	dohttpreq(self.update_url, function(json_data, http_id)
		self:set_update_data(json_data)
	end)
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
	
	--if overhaul content is not installed,
	--then force disable overhaul setting to avoid crashes
	if not _G.deathvox_overhaul then
		self:ChangeSetting("useTotalCDOverhaul",false)
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
			local fuck = deathvox._voiceline_framework.BufferedSounds[unit_name]
			fuck[line_type] = {}
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
