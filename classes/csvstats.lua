--requires string.split() from PAYDAY 2's string util library
--requires table.deep_map_copy() from PAYDAY 2's table util library
--requires tweak_data.weapon table (WeaponTweakData) from PAYDAY 2 ( lib/tweak_data/weapontweakdata )
--requres utf8.to_lower() from PAYDAY 2's utf8 util library

_G.CSVStatReader = {
	DAMAGE_CAP = 210, --damage is technically on a lookup table from 0 to 210
	IGNORED_HEADERS = 2,
	INPUT_DIRECTORY = deathvox.ModPath .. "csv/",
	WEAPONS_SUBDIR = "weapons/",
	ATTACHMENTS_SUBDIR = "attachments/",
	MELEES_SUBDIR = "melees/",
	
	WIPE_PREVIOUS_STATS = true,
	PRIMARY_CLASS_NAME_LOOKUP = {
	--yes i wrote it this way on purpose
		[utf8.to_lower("Rapid Fire")] = "class_rapidfire",
		[utf8.to_lower("Shotgun")] = "class_shotgun",
		[utf8.to_lower("Precision")] = "class_precision",
		[utf8.to_lower("Heavy")] = "class_heavy",
		[utf8.to_lower("Specialist")] = "class_specialist",
		[utf8.to_lower("Saw")] = "class_saw",
		[utf8.to_lower("Grenade")] = "class_grenade",
		[utf8.to_lower("Throwing")] = "class_throwing",
		[utf8.to_lower("Melee")] = "class_melee"
	},
	VALID_PRIMARY_CLASSES = {
		["class_rapidfire"] = true,
		["class_shotgun"] = true,
		["class_precision"] = true,
		["class_heavy"] = true,
		["class_specialist"] = true,
		["class_saw"] = true,
		["class_grenade"] = true,
		["class_throwing"] = true,
		["class_melee"] = true
	},
	SUBCLASS_NAME_LOOKUP = {
		["Quiet"] = "subclass_quiet",
		["Poison"] = "subclass_poison",
		["Area Denial"] = "subclass_areadenial"
	},
	VALID_SUBCLASSES = {
		["subclass_quiet"] = true,
		["subclass_poison"] = true,
		["subclass_areadenial"] = true
	},
	VALID_FIREMODES = { --not used
		["auto"] = true,
		["single"] = true
	},
	FIREMODE_NAME_LOOKUP = { --not used
		["autofire"] = "auto",
		["singlefire"] = "single",
		["auto fire"] = "auto",
		["single fire"] = "single",
		["auto-fire" ] = "auto",
		["single-fire"] = "single"
	},
	WEAPON_CSV_ORDER = {
		"id", --"Weapon ID"
		"name", --"Weapon Name"
		"primary_class", --"Weapon Class"
		"subclasses", --"Subclasses"
		"magazine", --"Mag" (magazine size)
		"total_ammo", --"Total Ammo"
	--	"total_ammo_mod",
	--	"extra_ammo",
		"fire_rate", --ROF"
		"fire_rate_internal", --"s/R"
	--	"firemode",
	--	"is_firemode_toggleable",
		"damage", --"DMG"
		"accuracy", --"ACC"
		"spread_internal", --"Spread"
	--	"spread_moving",
		"stability", --"STB"
		"recoil_internal", --"Recoil"
		"concealment", --"Conceal"
		"threat", --"Threat"
		"suppression_internal", --"Supp. Index"
		"reload_partial", --"Partial Reload"
		"reload_full", --"Full Reload"
		"equip", --"Equip"
	--	"unequip", 
	--	"reload",
		"zoom", --"Zoom" (inherited)
		"value", --"Value" (inherited)
		"price_internal", --"Price"
		"pickup_low", --"Pick. Low"
		"pickup_high", --"Pick. High"
	--	"alert_size",
		"can_pierce_wall", --"Wall Piercing"
		"can_pierce_enemy", --"Overpenetration"
		"can_pierce_shield", --"Shield Piercing"
		"armor_piercing_chance", --"Armor Piercing"
		"kick_y_min", --"Kick Min-Y"
		"kick_y_max", --"Kick Max-Y"
		"kick_x_min", --"Kick Min-X"
		"kick_x_max" --"Kick Max-X"
	},
	ATTACHMENT_CSV_ORDER = {
		"id", --"Attachment ID"
		"name", --"Attachment/Weapon Name" (ignored)
		"bm_weapon_id", --"Weapon Override"
		"primary_class", --"Weapon Class"
		"subclasses", --"Subclasses"
		"extra_ammo", --"Magazine Size"
		"total_ammo_add", --"Total Ammo Add Bonus" (TCD stat only)
		"total_ammo", --"Total Ammo Mul Bonus"
		"total_ammo_internal", --"Total Ammo Mul Index" (pre-calculated)
		"fire_rate", --"Fire Rate"
		"fire_rate_internal", --"SpR" (pre-calulated)
		"damage", --"Damage"
		"accuracy", --"Accuracy"
		"spread_internal", --"Spread" (pre-calculated)
		"stability", --"Stability",
		"recoil", --"Recoil" (pre-calculated"
		"concealment", --"Conceal. Mod"
		"threat", --"Threat Mod"
		"suppression_internal", --"Supp. Index" (pre-calculated)
		"reload", --"Reload Multiplier"
		"reload_internal", --"Reload Index" (pre-calculated)
		"zoom", --"Zoom"
		"alert_size", --"Alert Size"
		"value", --"Value"
		"value_external", --"Price" (pre-calculated)
		"pickup_low", --"Pick. Low"
		"pickup_high", --"Pick. High"
		"can_pierce_wall", --"Wall Piercing"
		"can_pierce_enemy", --"Overpenetration"
		"can_pierce_shield", --"Shield Piercing"
		"armor_piercing_chance", --"Armor Piercing"
		"perks", --"Perks"
		"sub_type" --"Sub Type"
	},
	EXTRA_AMMO_LOOKUP = {}, --generated post load
	TOTAL_AMMO_LOOKUP = {}, --generated post load
	SUPPRESSION_THREAT_LOOKUP = {
		--suppression : threat
		43, -- 1 (cap)
		37, -- 2
		34, -- 3
		31, -- 4
		28, -- 5
		26, -- 6
		24, -- 7
		22, -- 8
		20, -- 9
		14, -- 10
		13, -- 11
		12, -- 12
		11, -- 13
		10, -- 14
		9,  -- 15
		8,  -- 16
		6,  -- 17
		4,  -- 18
		2,  -- 19
		0   -- 20 (floor)
	},
	WEAPON_STAT_INDICES = {}, --generated post load
	ATTACHMENT_STAT_INDICES = {} --generated post load
}

--[[
local attachment_stat_indices = {
	override_primary_class, --overrides weapon's primary class
	adds_subclasses, --semicolon separated list
	
	sub_type,
	
	perks, --semicolon separated list, can contain any of the following:
--	scope,
--	highlight,
--	silencer,
--	fire_mode_auto,
--	fire_mode_single,
--	gadget,
--	bonus,
--	bipod,
	
	--stats (same stat types as weapon stats)
	concealment,
	spread_moving,
	value,
	recoil,
	damage,
	extra_ammo,
	zoom
}
--]]

--generate reverse lookup table from this order
for i,key in ipairs(CSVStatReader.WEAPON_CSV_ORDER) do 
	CSVStatReader.WEAPON_STAT_INDICES[key] = i
end

for i,key in ipairs(CSVStatReader.ATTACHMENT_CSV_ORDER) do 
	CSVStatReader.ATTACHMENT_STAT_INDICES[key] = i
end

--generate extra_ammo lookup table
for i = -100,100,1 do 
	CSVStatReader.EXTRA_AMMO_LOOKUP[i] = i + 101
end

--generate total_ammo lookup table
for i = 1,41 do 
	CSVStatReader.TOTAL_AMMO_LOOKUP[i] = (i-21) * 0.05
end

function CSVStatReader.log(s)
	log("\tTCD csv Parser: " .. s)
end

function CSVStatReader.table_concat(tbl,div)
	div = tostring(div or ",")
	if type(tbl) ~= "table" then 
		return "(concat error: non-table value)"
	end
	local str
	for k,v in pairs(tbl) do
		str = str and (str .. div .. tostring(v)) or tostring(v)
	end
	return str or ""
end

function CSVStatReader.print_weapon_stats(weapon_id)
	local table_concat = CSVStatReader.table_concat
	local s = {}
	local function ins(...)
		local tbl = {...}
		if #tbl > 0 then
			local a = table.remove(tbl,1)
			table.insert(s,#s+1,tostring(a) .. "\t" .. table_concat(tbl," "))
		else
			table.insert(s,#s+1,"")
		end
	end
	
	local wtd = tweak_data.weapon[weapon_id]
	ins("weapon_id",weapon_id)
	ins("name_id",wtd.name_id,managers.localization:text(wtd.name_id))
	ins("subclasses",table_concat(wtd.subclasses or {},"; "))
	ins("magazine",wtd.CLIP_AMMO_MAX)
	ins("total_ammo_mod",wtd.stats.total_ammo_mod)
	ins("extra_ammo",wtd.stats.extra_ammo)
	ins("AMMO_MAX ",wtd.AMMO_MAX)
	ins("fire_rate",wtd.fire_mode_data.fire_rate)
	ins("damage",wtd.stats.damage)
	ins("accuracy",wtd.stats.spread)
	ins("stability",wtd.stats.recoil)
	ins("concealment",wtd.stats.concealment)
	ins("suppression",wtd.stats.suppression)
	ins("reload_partial",wtd.timers.reload_not_empty)
	ins("reload_full",wtd.timers.reload_empty)
	ins("equip",wtd.timers.equip)
	ins("unequip",wtd.timers.unequip)
	ins("zoom",wtd.stats.zoom)
	ins("value",wtd.stats.value)
	ins("pickup_low",wtd.AMMO_PICKUP[1])
	ins("pickup_high",wtd.AMMO_PICKUP[2])
	ins("can_pierce_wall",wtd.can_shoot_through_wall)
	ins("can_pierce_enemy",wtd.can_shoot_through_enemy)
	ins("can_pierce_shield",wtd.can_shoot_through_shield)
	ins("armor_piercing_chance",wtd.armor_piercing_chance)
	ins("kick matrix: [ " .. table_concat({wtd.kick.standing[1],wtd.kick.standing[2],wtd.kick.standing[3],wtd.kick.standing[4]}," / ") .. " ]")
	
	
	self.log("Printing weapon stats for " .. tostring(weapon_id))
	for _,v in ipairs(s) do 
		self.log(v)
	end
	self.log("Done printing weapon stats")
end

function CSVStatReader.convert_rof(rpm) --converts rounds per minute to seconds per round
	local rounds_per_second = rpm / 60
	return 1 / rounds_per_second --could just do 60/n to save time and space but i'd rather waste even more time and space by leaving this comment saying that i'm not going to do that
end

function CSVStatReader.convert_accstab(stat) --converts acc/stab from a [0-100] value to the weird internal multiple of 4 stat thing pd2 has going on
	return math.round((stat + 4) / 4)
end

function CSVStatReader.convert_threat(target_threat)
	local threat_suppression_reverse_lookup = CSVStatReader.SUPPRESSION_THREAT_LOOKUP 
	
	for threat_index,suppression in ipairs(threat_suppression_reverse_lookup) do 
		if suppression == target_threat then 
			return threat_index
		elseif suppression < target_threat then
			if THREAT_ROUND_UP then 
				return math.max(1,threat_index - 1)
			else --round down
				return threat_index
			end
		end
	end
	
	return 0
end

function CSVStatReader.convert_extra_ammo(target_mag_bonus)
	local extra_ammo = 101
	if CSVStatReader.EXTRA_AMMO_LOOKUP[target_mag_bonus] then 
		extra_ammo = CSVStatReader.EXTRA_AMMO_LOOKUP[target_mag_bonus]
	else
		CSVStatReader.log("ERROR: convert_extra_ammo failed! target: " .. tostring(target_mag_bonus))
	end
	return extra_ammo
end

function CSVStatReader.convert_total_ammo_mul(target_ammo_mul)
	local total_ammo = 21
	if CSVStatReader.TOTAL_AMMO_LOOKUP[target_ammo_mul] then 
		total_ammo = CSVStatReader.TOTAL_AMMO_LOOKUP[target_ammo_mul]
	else
		CSVStatReader.log("ERROR: convert_total_ammo_mul failed! target: " .. tostring(target_ammo_mul))
	end
	return total_ammo
end

function CSVStatReader.convert_boolean(input)
	if type(input) == "string" then 
		local s = utf8.to_lower(input)
		if string.find(s,"yes") or string.find(s,"true") then 
			return true
		elseif string.find(s,"no") or string.find(s,"false") then 
			return false
		end
	end
	return input and true or false
end

function CSVStatReader.not_null_or_na(s)
	s = utf8.to_lower(s)
	return s and (s ~= "n/a") and (s ~= "null")
end

function CSVStatReader.not_empty(s)
	return s and s ~= ""
end

function CSVStatReader.remove_extra_spaces(s)
	--check for extraneous space characters here
	-- instead of *assuming* each field is delimited by " : " in string.split, in case of rare typos where the space is not present
	while (string.match(string.sub(s,1,1),"%s")) and (string.len(s) > 0) do
		s = string.sub(s,2)
	end
	while (string.match(string.sub(s,-1,-1),"%s")) and (string.len(s) > 0) do 
		s = string.sub(s,1,-2)
	end
	
	return s
end

function CSVStatReader:read_files(mode)
	if mode == "weapon" then 
		return self:read_firearms()
	elseif mode == "attachment" then 
		return self:read_attachments()
	elseif mode == "melee" then
		return self:read_melees()
	end
end

function CSVStatReader:read_firearms()
	local file_util = _G.FileIO
	local path_util = BeardLib.Utils.Path
	
	local convert_threat = self.convert_threat
	local convert_boolean = self.convert_boolean
	local convert_accstab = self.convert_accstab
	local convert_rof = self.convert_rof
	local remove_extra_spaces = self.remove_extra_spaces
	local not_empty = self.not_empty
	local not_null = self.not_null_or_na
	local table_concat = self.table_concat
	
	local olog = self.log
	local DAMAGE_CAP = self.DAMAGE_CAP
	local IGNORED_HEADERS = self.IGNORED_HEADERS
	local input_directory = self.INPUT_DIRECTORY
	
	local target_subdir = input_directory .. self.WEAPONS_SUBDIR
	
	local STAT_INDICES = self.WEAPON_STAT_INDICES
	
	for _,filename in pairs(file_util:GetFiles(target_subdir)) do
		
		local extension = utf8.to_lower(path_util:GetFileExtension(filename))
		if extension == "csv" then 
			local input_file = io.open(target_subdir .. filename)
			self.log("Doing weapon stats file: [" .. tostring(filename) .. "]")
			
			local line_num = 0
			for raw_line in input_file:lines() do 
			
				line_num = line_num + 1
				local raw_csv_values = string.split(raw_line,",",true) --csv values? nice. my favorite type of tea is chai tea
				if line_num > IGNORED_HEADERS then 
				
					--weapon_id
					local weapon_id = raw_csv_values[STAT_INDICES.id]
					if not_empty(weapon_id) and not_null(weapon_id) then 
						local wtd = tweak_data.weapon[weapon_id]
						if wtd then --found valid weapon data to edit
							olog("Processing weapon id " .. tostring(weapon_id) .. " (line " .. tostring(line_num) .. ")")
							
							--Primary class
							local primary_class
							
							local _primary_class = utf8.to_lower(raw_csv_values[STAT_INDICES.primary_class])
							if _primary_class then
								if self.VALID_PRIMARY_CLASSES[_primary_class] then
									primary_class = _primary_class
								elseif self.PRIMARY_CLASS_NAME_LOOKUP[_primary_class] then 
									primary_class = self.PRIMARY_CLASS_NAME_LOOKUP[_primary_class]
								else
									olog("Error: bad primary_class: " .. tostring(raw_csv_values[STAT_INDICES.primary_class]))
									return
								end
							end
							
							
							--Secondary classes
							local secondary_classes = {}
							
							local _secondary_classes = remove_extra_spaces(utf8.to_lower(raw_csv_values[STAT_INDICES.subclasses]))
							if _secondary_classes and _secondary_classes ~= "" then 
								for _,_secondary_class in pairs(string.split(_secondary_classes,";") or {}) do 
									_secondary_class = remove_extra_spaces(_secondary_class)
									local secondary_class
									if self.VALID_SUBCLASSES[_secondary_class] then 
										secondary_class = _secondary_class
									elseif self.SUBCLASS_NAME_LOOKUP[_secondary_class] then
										secondary_class = self.SUBCLASS_NAME_LOOKUP[_secondary_class]
									end
									
									if secondary_class then 
										if secondary_class ~= "" and not table.contains(secondary_classes,secondary_class) then 
											table.insert(secondary_classes,secondary_class)
										else
											olog("Error: bad subclass: " .. tostring(_secondary_class))
											--subclass is not required so don't break here
										end
									end
								end
							end
							
							
							--Magazine size (aka CLIP_AMMO_MAX)
							local magazine
							
							local _magazine = raw_csv_values[STAT_INDICES.magazine]
							magazine = not_empty(_magazine) and math.floor(tonumber(_magazine))
							if not magazine then 
								olog("Error: bad magazine size: " .. tostring(magazine))
								return
							end
							
							
							--Total Ammo (aka Reserve Ammo) (not to be confused with total_ammo_mod)
							local total_ammo
							
							local _total_ammo = raw_csv_values[STAT_INDICES.total_ammo]
							total_ammo = not_empty(_total_ammo) and tonumber(_total_ammo)
							if not total_ammo then 
								olog("Error: bad total_ammo size: " .. tostring(_total_ammo))
								return
							end
							
							
							--Fire Rate
							local fire_rate
							
--								fire_rate = tonumber(raw_csv_values[STAT_INDICES.fire_rate_internal])
							local _fire_rate = raw_csv_values[STAT_INDICES.fire_rate]
							fire_rate = not_empty(_fire_rate) and convert_rof(tonumber(_fire_rate))
							if not fire_rate then 
								olog("Error: bad fire_rate: " .. tostring(_fire_rate))
								return
							end
							
							
							--Damage
							local damage,damage_mul
							
							local _damage = raw_csv_values[STAT_INDICES.damage]
							damage = not_empty(_damage) and tonumber(_damage)
							if damage then 
								if damage > DAMAGE_CAP then 
									damage_mul = damage / DAMAGE_CAP
									damage = DAMAGE_CAP
								end
							else
								olog("Error: bad damage: " .. tostring(_damage))
								return
							end
							
							
							--Accuracy/Spread
							local spread
							
--								spread = tonumber(raw_csv_values[STAT_INDICES.spread_internal])
							local _accuracy = raw_csv_values[STAT_INDICES.accuracy]
							local accuracy = not_empty(_accuracy) and tonumber(_accuracy)
							if accuracy then 
								spread = convert_accstab(accuracy)
							end
							if not spread then 
								olog("Error: bad accuracy: " .. tostring(_accuracy))
								return
							end
							
							--Stability/Recoil
							local recoil 
							
--								recoil = tonumber(raw_csv_values[STAT_INDICES.recoil_internal])
							local _stability = raw_csv_values[STAT_INDICES.stability]
							local stability = not_empty(_stability) and tonumber(_stability)
							if stability then
								recoil = convert_accstab(stability)
							end
							if not recoil then 
								olog("Error: bad stability: " .. tostring(_stability))
								return
							end
							
							--Concealment
							local concealment
							
							local _concealment = raw_csv_values[STAT_INDICES.concealment]
							concealment = not_empty(_concealment) and tonumber(_concealment)
							if not concealment then
								olog("Error: bad concealment: " .. tostring(_concealment))
								return
							end
							
							
							--Threat/Suppression
							local suppression
							
--								suppression = tonumber(raw_csv_values[STAT_INDICES.suppression_internal])
							local _threat = raw_csv_values[STAT_INDICES.threat]
							local threat = not_empty(_threat) and tonumber(_threat)
							if threat then 
								suppression = convert_threat(threat)
							end
							if not suppression then
								olog("Error: bad suppression: " .. tostring(_concealment))
								return
							end
							
							
							--[[
							--Firemode Toggle
							local is_firemode_toggleable
							local _is_firemode_toggleable = raw_csv_values[STAT_INDICES.is_firemode_toggleable]
							if (_is_firemode_toggleable ~= nil) and (_is_firemode_toggleable ~= "") then 
								is_firemode_toggleable = convert_boolean(_is_firemode_toggleable)
							end
							--]]
							
							--[[
							--Firemode
							local fire_mode
							local _fire_mode = utf8.to_lower(raw_csv_values[STAT_INDICES.firemode])
							if _fire_mode then 
								if VALID_FIREMODES[_fire_mode] then 
									fire_mode = _fire_mode
								elseif FIREMODE_NAME_LOOKUP[_fire_mode] then
									fire_mode = FIREMODE_NAME_LOOKUP[_fire_mode]
								end
							end
							if not fire_mode then 
								olog("Error: Bad firemode: " .. tostring(_firemode))
							end
							--]]
							
							
							--timers subsection
							local timers = {}
							
							--Partial Reload timer
							local reload_partial 
							
							local _reload_partial = raw_csv_values[STAT_INDICES.reload_partial]
							reload_partial = not_empty(_reload_partial) and tonumber(_reload_partial)
							if not reload_partial then
								olog("Error: bad reload_partial: " .. tostring(_reload_partial))
								return
							end
							
							
							--Full Reload timer
							local reload_full
							
							local _reload_full = raw_csv_values[STAT_INDICES.reload_full]
							reload_full = not_empty(_reload_full) and tonumber(_reload_full)
							if not reload_full then
								olog("Error: bad reload_full: " .. tostring(_reload_full))
								return
							end
							
							--Equip/Unequip timer
							local equip,unequip
							
							local _equip = raw_csv_values[STAT_INDICES.equip]
							equip = not_empty(_equip) and tonumber(_equip)
							if not equip then 
								olog("Error: bad equip timer: " .. tostring(_equip))
								return
							end
							unequip = equip
							--[[
							local _unequip = raw_csv_values[STAT_INDICES.unequip]
							local unequip = not_empty(_unequip) and tonumber(_unequip)
							if not unequip then 
								olog("Error: bad unequip timer: " .. tostring(_unequip))
								return
							end
							--]]
							
							
							timers.reload_not_empty = reload_partial
							timers.reload_empty = reload_full
							timers.equip = equip
							timers.unequip = unequip
							--timers subsection end
							
							
							--[[
							--Reload speed multiplier (inherited)
							local reload
							local _reload = raw_csv_values[STAT_INDICES.reload]
							reload = not_empty(_reload) and tonumber(_reload)
							--]]
							
							--zoom (optional/inherited)
							local _zoom = raw_csv_values[STAT_INDICES.zoom]
							local zoom = not_empty(_zoom) and tonumber(_zoom)
							
							
							--value aka Price (optional/inherited)
							local _price = raw_csv_values[STAT_INDICES.value]
							local price = not_empty(_price) and tonumber(_price)
							
							
							--Ammo Pickup High/Ammo Pickup Low
							local pickup_low,pickup_high
							
							local _pickup_low = raw_csv_values[STAT_INDICES.pickup_low]
							pickup_low = not_empty(_pickup_low) and tonumber(_pickup_low)
							local _pickup_high = raw_csv_values[STAT_INDICES.pickup_high]
							pickup_high = not_empty(_pickup_high) and tonumber(_pickup_high)
							if not (pickup_low and pickup_high) then 
								olog("Error: bad pickup stat(s): " .. tostring(_pickup_low) .. ", " .. tostring(_pickup_high))
								return
							end
							
							--[[
							--Alert Size (inherited)
							local alert_size
							local _alert_size = raw_csv_values[STAT_INDICES.alert_size]
							alert_size = not_empty(_alert_size) and tonumber(_alert_size)
							--]]
							
							--[[
							--spread_moving (inherited
							local spread_moving
							local _spread_moving = raw_csv_values[STAT_INDICES.spread_moving]
							spread_moving = not_empty(_spread_moving) and convert_accstab(tonumber(_spread_moving))
							--]]
							
							--assorted piercing stats
							local _can_shoot_through_enemy = raw_csv_values[STAT_INDICES.can_pierce_enemy]
							local can_shoot_through_enemy = not_empty(_can_shoot_through_enemy) and convert_boolean(_can_shoot_through_enemy)
							local _can_shoot_through_shield = raw_csv_values[STAT_INDICES.can_pierce_shield]
							local can_shoot_through_shield = not_empty(_can_shoot_through_shield) and convert_boolean(_can_shoot_through_shield)
							local _can_shoot_through_wall = raw_csv_values[STAT_INDICES.can_pierce_wall]
							local can_shoot_through_wall = not_empty(_can_shoot_through_wall) and convert_boolean(_can_shoot_through_wall)
							local _armor_piercing_chance = raw_csv_values[STAT_INDICES.armor_piercing_chance]
							local armor_piercing_chance = not_empty(_armor_piercing_chance) and tonumber(_armor_piercing_chance)
							
							--[[
							--extra magazine size bonus (inherited)
							local _extra_ammo = raw_csv_values[STAT_INDICES.extra_ammo]
							local extra_ammo = not_empty(_extra_ammo) and tonumber(_extra_ammo)
							--]]
							
							--[[
							--total_ammo_mod reserve ammo multiplier (inherited)
							local _total_ammo_mod = raw_csv_values[STAT_INDICES.total_ammo_mod]
							local total_ammo_mod = not_empty(_total_ammo_mod) and tonumber(_total_ammo_mod)
							--]]
							
							--Kick matrix (kick/stability system overhaul not yet implemented)
							--[[
							local _kick_y_min = raw_csv_values[STAT_INDICES.kick_y_min]
							local kick_y_min = not_empty(_kick_y_min) and tonumber(_kick_y_min)
							local _kick_y_max = raw_csv_values[STAT_INDICES.kick_y_max]
							local kick_y_max = not_empty(_kick_y_max) and tonumber(_kick_y_max)
							local _kick_x_min = raw_csv_values[STAT_INDICES.kick_x_min]
							local kick_x_min = not_empty(_kick_x_min) and tonumber(_kick_x_min)
							local _kick_x_max = raw_csv_values[STAT_INDICES.kick_x_max]
							local kick_x_max = not_empty(_kick_x_max) and tonumber(_kick_x_max)
							if not (kick_y_min and kick_y_max and kick_x_min and kick_x_max) then 
								olog("Error: Bad kick value(s): [ " .. table_concat({_kick_y_min,_kick_y_max,_kick_x_min,_kick_x_max}," / ") .. " ]")
								return
							end
							--]]
							
							local spread_moving
							local _spread_moving = raw_csv_values[STAT_INDICES.spread_moving]
							spread_moving = not_empty(_spread_moving) and convert_accstab(tonumber(_spread_moving))
							
							
							wtd.primary_class = primary_class
							wtd.subclasses = secondary_classes
							
							for timer_stat_name,timer_stat_value in pairs(timers) do 
								if timer_stat_value then 
									wtd.timers[timer_stat_name] = timer_stat_value
								end
							end
							
							wtd.CLIP_AMMO_MAX = magazine
							wtd.AMMO_MAX = total_ammo
							if pickup_low and pickup_high then 
								wtd.AMMO_PICKUP[1] = pickup_low
								wtd.AMMO_PICKUP[2] = pickup_high
							end
							
							wtd.fire_mode_data = {
								fire_rate = fire_rate
							}
							wtd.FIRE_MODE = fire_mode or wtd.FIRE_MODE
							if is_firemode_toggleable ~= nil then 
								wtd.CAN_TOGGLE_FIREMODE = is_firemode_toggleable
							end
							
							local new_stats = {}
							new_stats.damage = damage --damage is an index from 1-210, generally linear. larger numbers than 210 can be used, as the parser will automatically convert them using the game's damage multiplier in stats_modifiers. however, this must still be an integer! bigger number more owie.
							new_stats.spread = spread --default accuracy deviation; index from 1-20
							new_stats.spread_moving = spread_moving or wtd.stats.spread_moving --dummy stat
							new_stats.recoil = recoil --change in accuracy deviation over time; index from 1-20
							new_stats.concealment = concealment
							new_stats.suppression = suppression --calculates the displayed Threat stat using a lookup table, from 1-20. larger numbers have a lower threat value.
							new_stats.zoom = zoom or wtd.stats.zoom --zoom is an index from 1-10. larger numbers have greater magnification
							new_stats.value = price or wtd.stats.value --value is an index from 1-10, for a lookup table that determines buy/sell value. larger numbers indicate a more expensive weapon
							new_stats.alert_size = alert_size or wtd.stats.alert_size --alert size is an index from 1-20 for a lookup table, ranging from 300m to 0m. larger numbers have a smaller effective radius
							new_stats.total_ammo_mod = total_ammo_mod or 21 --total_ammo is an index for a lookup table, which is used as a multiplier for the weapon's reserve ammo amount. leave at 21 = 1x 
							new_stats.extra_ammo = extra_ammo or 101 --index from 1-201 in TCD (1-101 in the base game); should only be used for weapon attachments that modify magazine ammo count. leave at 101 = +0 bonus magazine size
							new_stats.reload = reload or 11 --index from 1 to 20, used as a reload speed multiplier. leave at 11 = 1x
							
							if can_shoot_through_enemy ~= nil then 
								wtd.can_shoot_through_enemy = can_shoot_through_enemy
							end
							if can_shoot_through_shield ~= nil then 
								wtd.can_shoot_through_shield = can_shoot_through_shield
							end
							if can_shoot_through_wall ~= nil then 
								wtd.can_shoot_through_wall = can_shoot_through_wall
							end
							if armor_piercing_chance ~= nil then 
								wtd.armor_piercing_chance = armor_piercing_chance
							end
			--				wtd.panic_suppression_chance --???
							
							--[[
							wtd.kick = {
								standing = kick,
								crouching = kick,
								steelsight = kick
							}
							--]]
							
							
							if self.WIPE_PREVIOUS_STATS then --does not affect inherited stats
								wtd.stats = new_stats
							else
								for k,v in pairs(new_stats) do 
									wtd.stats[k] = new_stats[k] or v
								end
							end
							
							--damage_mul for damage values above DAMAGE_CAP (210)
							wtd.stats_modifiers = wtd.stats_modifiers or {}
							wtd.stats_modifiers.damage = damage_mul
							
						else
							olog("Error! No weapon stats exist for weapon with id: [" .. tostring(weapon_id) .. "]") 
						end
					end
				end
			end
			
			input_file:close()
		else
			olog("Error! Bad file type: " .. tostring(extension))
		end
	end

end

function CSVStatReader:read_melees()
	local file_util = _G.FileIO
	local path_util = BeardLib.Utils.Path
	
	local convert_threat = self.convert_threat
	local convert_boolean = self.convert_boolean
	local convert_accstab = self.convert_accstab
	local convert_rof = self.convert_rof
	local remove_extra_spaces = self.remove_extra_spaces
	local not_empty = self.not_empty
	local table_concat = self.table_concat
	
	local olog = self.log
	local DAMAGE_CAP = self.DAMAGE_CAP
	local IGNORED_HEADERS = self.IGNORED_HEADERS
	local input_directory = self.INPUT_DIRECTORY
end

function CSVStatReader:read_attachments()
	local file_util = _G.FileIO
	local path_util = BeardLib.Utils.Path
	
	local convert_threat = self.convert_threat
	local convert_boolean = self.convert_boolean
	local convert_accstab = self.convert_accstab
	local convert_rof = self.convert_rof
	local convert_extra_ammo = self.convert_extra_ammo
	local convert_total_ammo_mul = self.convert_total_ammo_mul
	local remove_extra_spaces = self.remove_extra_spaces
	local not_empty = self.not_empty
	local table_concat = self.table_concat
	
	local olog = self.log
--	local DAMAGE_CAP = self.DAMAGE_CAP
	local IGNORED_HEADERS = self.IGNORED_HEADERS
	local input_directory = self.INPUT_DIRECTORY
	
	
	
	local target_subdir = input_directory .. self.ATTACHMENTS_SUBDIR
	
	local STAT_INDICES = self.ATTACHMENT_STAT_INDICES
	
	for _,filename in pairs(file_util:GetFiles(target_subdir)) do
		local extension = utf8.to_lower(path_util:GetFileExtension(filename))
		if extension == "csv" then 
			local input_file = io.open(target_subdir .. filename)
			self.log("Doing weapon stats file: [" .. tostring(filename) .. "]")
			local line_num = 0
			for raw_line in input_file:lines() do 
				line_num = line_num + 1
				local raw_csv_values = string.split(raw_line,",",true) --csv values? nice. my favorite type of tea is chai tea
				if line_num > IGNORED_HEADERS then 
					local attachment_id = raw_csv_values[STAT_INDICES.id]
					
					if not_empty(attachment_id) and not_null(attachment_id) then 
						local ptd = tweak_data.weapon.factory.parts[attachment_id]
						if ptd then 
							olog("Processing attachment id " .. tostring(attachment_id) .. " (line " .. tostring(line_num) .. ")")
							
							
							--Weapon (for weapon-specific attachment stat balancing)
							local bm_weapon_id
							local _bm_weapon_id = utf8.to_lower(raw_csv_values[STAT_INDICES.bm_weapon_id])
							if not_null(_bm_weapon_id) and not_empty(_bm_weapon_id) then 
								if tweak_data.weapon.factory[_bm_weapon_id] then 
									--is valid weapon
									bm_weapon_id = _bm_weapon_id
								else
									olog("Error: bad bm_weapon_id: " .. tostring(raw_csv_values[STAT_INDICES.bm_weapon_id]))
								end
							end
							
							--Primary Class
							local primary_class
							local _primary_class = utf8.to_lower(raw_csv_values[STAT_INDICES.primary_class])
							if not_null(_primary_class) and not_empty(_primary_class) then 
								if self.VALID_PRIMARY_CLASSES[_primary_class] then 
									primary_class = _primary_class
								elseif self.PRIMARY_CLASS_NAME_LOOKUP[_primary_class] then 
									primary_class = self.PRIMARY_CLASS_NAME_LOOKUP[_primary_class]
								else
									olog("Error: bad primary_class: " .. tostring(raw_csv_values[STAT_INDICES.primary_class]))
									return
								end
							end
							
							--Secondary classes
							local secondary_classes = {}
							local _secondary_classes = remove_extra_spaces(utf8.to_lower(raw_csv_values[STAT_INDICES.subclasses]))
							if _secondary_classes and _secondary_classes ~= "" then 
								for _,_secondary_class in pairs(string.split(_secondary_classes,";") or {}) do 
									_secondary_class = remove_extra_spaces(_secondary_class)
									local secondary_class
									if self.VALID_SUBCLASSES[_secondary_class] then 
										secondary_class = _secondary_class
									elseif self.SUBCLASS_NAME_LOOKUP[_secondary_class] then
										secondary_class = self.SUBCLASS_NAME_LOOKUP[_secondary_class]
									end
									
									if secondary_class then 
										if secondary_class ~= "" and not table.contains(secondary_classes,secondary_class) then 
											table.insert(secondary_classes,secondary_class)
										else
											olog("Error: bad subclass: " .. tostring(_secondary_class))
											--subclass is not required so don't break here
										end
									end
								end
							end
							
							
							--Magazine size bonus (aka extra_ammo)
							local extra_ammo
							local _extra_ammo = raw_csv_values[STAT_INDICES.extra_ammo]
							if not_empty(_extra_ammo) then
								extra_ammo = convert_extra_ammo(tonumber(_extra_ammo))
							end
							
							
							--Total Ammo Add Bonus (additive bonus to Reserve Ammo)
							local total_ammo_add
							local _total_ammo_add = raw_csv_values[STAT_INDICES.total_ammo_add]
							if not_empty(_total_ammo_add) then 
								total_ammo_add = tonumber(_total_ammo_add)
							end
							
							--Total Ammo Mul Bonus (multiplicative bonus to Reserve Ammo)
							local total_ammo_mul
							local _total_ammo_mul = raw_csv_values[STAT_INDICES.total_ammo_internal]
							if not_empty(_total_ammo_mul) then 
								--pre-converted
								total_ammo_mul = tonumber(_total_ammo_mul)
							end
							
							--Fire Rate bonus
							local fire_rate
							local _fire_rate = raw_csv_values[STAT_INDICES.fire_rate_internal]
							if not_empty(_fire_rate) then
								--pre-converted
								fire_rate = tonumber(_fire_rate)
							end
							
							
							--Damage
							local damage
							local _damage = raw_csv_values[STAT_INDICES.damage]
							if not_empty(_damage) then
								--pre-converted
								damage = tonumber(_damage)
							end
							
							
							--Accuracy/Spread bonus
							local spread
							local _spread = raw_csv_values[STAT_INDICES.spread_internal]
							if not_empty(_spread) then 
								--pre-converted
								spread = tonumber(_spread)
							end
							
							
							--Stability/Recoil bonus
							local recoil 
							local _recoil = raw_csv_values[STAT_INDICES.recoil_internal]
							if not_empty(_recoil) then
								--pre-converted
								recoil = tonumber(_recoil)
							end
							
							
							--Concealment
							local concealment
							local _concealment = raw_csv_values[STAT_INDICES.concealment]
							if not_empty(_concealment) then
								concealment = tonumber(_concealment)
							end
							
							
							--Threat/Suppression bonus
							local suppression
							local _suppression = raw_csv_values[STAT_INDICES.suppression_internal]
							if not_empty(_suppression) then 
								--pre-converted
								suppression = tonumber(_suppression)
							end
							
							--Reload Multiplier
							local reload_mul
							local _reload_mul = raw_csv_values[STAT_INDICES.reload_internal]
							if not_empty(_reload_mul) then 
								--pre-converted
								reload_mul = tonumber(_reload_mul)
							end
							
							--Zoom (inherited)
							local zoom
							local _zoom = raw_csv_values[STAT_INDICES.zoom]
							if not_empty(_zoom) then 
								zoom = tonumber(_zoom)
							end
							
							--Alert Size (inherited)
							local alert_size
							local _alert_size = raw_csv_values[STAT_INDICES.alert_size]
							if not_empty(_alert_size) then 
								alert_size = tonumber(_alert_size)
							end
							
							--Value (inherited)
							local value
							local _value = raw_csv_values[STAT_INDICES.value]
							if not_empty(_value) then 
								value = tonumber(_value)
							end
							
							--Ammo Pickup High/Ammo Pickup Low
							local pickup_low,pickup_high
							
							local _pickup_low = raw_csv_values[STAT_INDICES.pickup_low]
							pickup_low = not_empty(_pickup_low) and tonumber(_pickup_low)
							local _pickup_high = raw_csv_values[STAT_INDICES.pickup_high]
							pickup_high = not_empty(_pickup_high) and tonumber(_pickup_high)
							
							--assorted piercing stats
							local _can_shoot_through_enemy = raw_csv_values[STAT_INDICES.can_pierce_enemy]
							local can_shoot_through_enemy = not_empty(_can_shoot_through_enemy) and convert_boolean(_can_shoot_through_enemy)
							local _can_shoot_through_shield = raw_csv_values[STAT_INDICES.can_pierce_shield]
							local can_shoot_through_shield = not_empty(_can_shoot_through_shield) and convert_boolean(_can_shoot_through_shield)
							local _can_shoot_through_wall = raw_csv_values[STAT_INDICES.can_pierce_wall]
							local can_shoot_through_wall = not_empty(_can_shoot_through_wall) and convert_boolean(_can_shoot_through_wall)
							local _armor_piercing_chance = raw_csv_values[STAT_INDICES.armor_piercing_chance]
							local armor_piercing_chance = not_empty(_armor_piercing_chance) and tonumber(_armor_piercing_chance)
							
							
							--TODO
							
						
							--inherited values:
							--value (unchanged from vanilla)
							--zoom (unchanged from vanilla)
							--perks (unchanged from vanilla)
							
--								local new_data = table.deep_map_copy(ptd.parts[id])
							local new_data = {
								supported = true
							}
							
							new_data.primary_class = primary_class
							new_data.subclasses = secondary_classes
							new_data.parts[id] = new_data
							
							if bm_weapon_id then 
								ptd.override[bm_weapon_id] = new_data
							else
								ptd.parts[id] = new_data
							end
							
						
							
						end
					end
					
					
				end
			end
		end
	end	
		
	
	
	
end