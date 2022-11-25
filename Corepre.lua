DeathvoxMapFramework = DeathvoxMapFramework or class(MapFramework)
DeathvoxMapFramework._directory = ModPath .. "map_replacements"
DeathvoxMapFramework.type_name = "deathvox"

DeathvoxMapFramework:init()
DeathvoxMapFramework:InitMods()

_G.deathvox = deathvox or {}
--deathvox.ModPath = ModPath
deathvox.update_url = "https://raw.githubusercontent.com/Crackdown-PD2/deathvox/autoupdate/meta.json"
deathvox.ModPath = deathvoxcore and deathvoxcore:GetPath() or deathvox.ModPath

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

dofile(deathvox.ModPath .. "classes/csvstats.lua") --since this is used to replace/edit tweakdata, it must be loaded even earlier (Core.lua is not early enough)

--checks whether or not hoppip's overhaul is enabled;
--If you are creating a menu option that should apply instantly, use Settings; 
--Else, if you want a menu option that should only apply on restart/reload, use Session_Settings.
function deathvox:IsHoppipOverhaulEnabled()
	return self.Session_Settings.useHoppipOverhaul 
end

function deathvox:set_update_data(json_data)
	if json_data:is_nil_or_empty() then
		log("im mad")
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
	
	self:check_for_updates()

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
if deathvox:IsTotalCrackdownEnabled() then 
	local texture_ids = Idstring("texture")
	local deathvox_modpath = deathvoxcore:GetPath()
	
	--load tcd skill icons
	BLT.AssetManager:CreateEntry(Idstring("guis/textures/pd2/skilltree/drillgui_icon_shocktrap"),texture_ids,deathvox_modpath .. "assets/guis/textures/pd2/skilltree/drillgui_icon_shocktrap.texture")
	BLT.AssetManager:CreateEntry(Idstring("guis/textures/pd2/skilltree_2/icons_atlas_2"),texture_ids,deathvox_modpath .. "assets/guis/textures/pd2/skilltree_2/icons_atlas_2.texture")
	BLT.AssetManager:CreateEntry(Idstring("guis/textures/pd2/specialization/icons_atlas"),texture_ids,deathvox_modpath .. "assets/guis/textures/pd2/specialization/icons_atlas.texture")
	BLT.AssetManager:CreateEntry(Idstring("guis/textures/pd2/hud_sentry_radial_icons_atlas"),texture_ids,deathvox_modpath .. "assets/guis/textures/pd2/hud_sentry_radial_icons_atlas.texture")
	
	BLT.AssetManager:CreateEntry(Idstring("guis/textures/pd2/damage_overlay_sociopath/static1"),texture_ids,deathvox_modpath .. "assets/guis/textures/pd2/damage_overlay_sociopath/static1.texture")
	BLT.AssetManager:CreateEntry(Idstring("guis/textures/pd2/damage_overlay_sociopath/static2"),texture_ids,deathvox_modpath .. "assets/guis/textures/pd2/damage_overlay_sociopath/static2.texture")
	BLT.AssetManager:CreateEntry(Idstring("guis/textures/pd2/damage_overlay_sociopath/static3"),texture_ids,deathvox_modpath .. "assets/guis/textures/pd2/damage_overlay_sociopath/static3.texture")
	BLT.AssetManager:CreateEntry(Idstring("guis/textures/pd2/damage_overlay_sociopath/static4"),texture_ids,deathvox_modpath .. "assets/guis/textures/pd2/damage_overlay_sociopath/static4.texture")
	BLT.AssetManager:CreateEntry(Idstring("guis/textures/pd2/damage_overlay_sociopath/vignette_overlay"),texture_ids,deathvox_modpath .. "assets/guis/textures/pd2/damage_overlay_sociopath/vignette_overlay.png")
	BLT.AssetManager:CreateEntry(Idstring("guis/textures/pd2/damage_overlay_sociopath/vignette_inverted_overlay"),texture_ids,deathvox_modpath .. "assets/guis/textures/pd2/damage_overlay_sociopath/vignette_inverted_overlay.png")
	BLT.AssetManager:CreateEntry(Idstring("guis/textures/pd2/damage_overlay_sociopath/scanlines_overlay"),texture_ids,deathvox_modpath .. "assets/guis/textures/pd2/damage_overlay_sociopath/scanlines_overlay.texture")
	BLT.AssetManager:CreateEntry(Idstring("guis/textures/pd2/blackmarket/icons/deployables/sentry_gun_silent"),texture_ids,deathvox_modpath .. "assets/guis/textures/pd2/blackmarket/icons/tcd/sentry_gun_silent.texture")
	
	BLT.AssetManager:CreateEntry(Idstring("guis/textures/pd2/radial_menu_assets/rmm_bg"),texture_ids,deathvox_modpath .. "assets/guis/textures/pd2/radial_menu_assets/rmm_bg.texture")
	BLT.AssetManager:CreateEntry(Idstring("guis/textures/pd2/radial_menu_assets/rmm_selector"),texture_ids,deathvox_modpath .. "assets/guis/textures/pd2/radial_menu_assets/rmm_selector.texture")
	
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
	
else
	--load vanilla skill icons (in case user launched with tcd but toggled off tcd and reloaded game state)
	BLT.AssetManager:CreateEntry(Idstring("guis/textures/pd2/skilltree_2/icons_atlas_2"),Idstring("texture"),"guis/textures/pd2/skilltree_2/icons_atlas_2.texture")
end

-- Voice Framework Setup
local C = blt_class()
VoicelineFramework = C
VoicelineFramework.BufferedSounds = {}

function C:register_unit(unit_name)
	--log("VF: Registering Unit, " .. unit_name)
	if _G.voiceline_framework then
		_G.voiceline_framework.BufferedSounds[unit_name] = {}
	end
end

function C:register_line_type(unit_name, line_type)
	if _G.voiceline_framework then
		if _G.voiceline_framework.BufferedSounds[unit_name] then
			--log("VF: Registering Type, " .. line_type .. " for Unit " .. unit_name)
			local fuck = _G.voiceline_framework.BufferedSounds[unit_name]
			fuck[line_type] = {}
		end
	end
end

function C:register_voiceline(unit_name, line_type, path)
	if _G.voiceline_framework then
		if _G.voiceline_framework.BufferedSounds[unit_name] then
			local fuck = _G.voiceline_framework.BufferedSounds[unit_name]
			if fuck[line_type] then
				--log("VF: Registering Path, " .. path .. " for Unit " .. unit_name)
				table.insert(fuck[line_type], XAudio.Buffer:new(path))
			end
		end
	end
end

if not _G.voiceline_framework then
	blt.xaudio.setup()
	_G.voiceline_framework = VoicelineFramework:new()
end  
