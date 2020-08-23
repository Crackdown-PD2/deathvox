DeathvoxMapFramework = DeathvoxMapFramework or class(MapFramework)
DeathvoxMapFramework._directory = ModPath .. "map_replacements"
DeathvoxMapFramework.type_name = "deathvox"

DeathvoxMapFramework:new()

_G.deathvox = deathvox or {}
--deathvox.ModPath = ModPath
deathvox.SavePath = SavePath
deathvox.SaveName = "crackdown.txt"
deathvox.SavePathFull = deathvox.SavePath .. deathvox.SaveName
deathvox.Settings = { --options as saved to your BLT save file 
	useHoppipOverhaul = true,
	useTotalCDOverhaul = true
}
deathvox.syncable_options = { --whitelist: options on this list will be accepted by other clients; if options are not on this list, clients will ignore them and not apply these synced options (from host) on the client's end
	useHoppipOverhaul = true
}
deathvox.Session_Settings = {} --populated only on load, not on changed menu. keep this empty
deathvox.NetworkIDs = { --string ids for network syncing stuff
	Overhauls = "overhauls"
}
deathvox.blt_menu_id = "deathvox_menu_main" --main menu id; all other menu ids should be in their menu's .txt files

--checks whether or not hoppip's overhaul is enabled;
--If you are creating a menu option that should apply instantly, use Settings; 
--Else, if you want a menu option that should only apply on restart/reload, use Session_Settings.
function deathvox:IsHoppipOverhaulEnabled()
	return self.Session_Settings.useHoppipOverhaul 
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
	log("Loaded menu settings")
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
