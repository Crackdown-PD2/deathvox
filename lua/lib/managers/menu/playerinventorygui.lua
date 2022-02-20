if deathvox:IsTotalCrackdownEnabled() then 
	Hooks:PostHook(PlayerInventoryGui,"init","tcd_playerinventory_init",function(self,ws,fullscreen_ws,node)
		
		local wftd = tweak_data.weapon.factory
		
		local function insert_subclasses(item_subclasses,new_subclasses)
			if type(new_subclasses) == "table" then 
				for _,subclass_name in pairs(new_subclasses) do 
					if not table.contains(item_subclasses,subclass_name) then 
						table.insert(item_subclasses,subclass_name)
					end
				end
			elseif new_subclasses then
				if not table.contains(item_subclasses,subclass_name) then 
					table.insert(item_subclasses,subclass_name)
				end
			end
		end
		local function find_archetypes_from_part(partname)
			local partdata = wftd.parts[partname]
			local item_class,item_subclasses
			if partdata then
				if partdata.subclass_modifiers then
					item_subclasses = partdata.subclass_modifiers
				end
				if partdata.class_modifier then 
					item_class = partdata.class_modifier
				end
			end
			return item_class,item_subclasses
		end
		
		local function find_weapon_archetypes(data)
			
			local weapon_id = data.weapon_id
			local wtd = tweak_data.weapon[weapon_id]
			
			local item_class = wtd.primary_class
			local item_subclasses = table.deep_map_copy(wtd.subclasses)
			for _,part_id in ipairs(data.blueprint) do
				local new_item_class,new_subclasses = find_archetypes_from_part(part_id)
				item_class = new_item_class or item_class
				insert_subclasses(item_subclasses,new_subclasses)
			end
			return item_class,item_subclasses
		end
		
		local function create_archetype_icons(weapon_slot,primary_class,subclasses)
			local tcd_gui_data = deathvox.tcd_gui_data
			local box = self._boxes_by_name[weapon_slot]
			
			local panel = box and box.panel
			if alive(panel) then 
				
				
				local icon_size = 24
				local icon_margin = 4
				local start_x = icon_margin
				local start_y = icon_margin + icon_size
				
				if primary_class then 
					local texture_name = tcd_gui_data.weapons.class[primary_class]
					if texture_name then 
						local weapon_class_icon = panel:bitmap({
							name = "weapon_class_icon",
							texture = texture_name,
							w = icon_size,
							h = icon_size,
							x = start_x,
							y = start_y,
							layer = 1,
							alpha = 1,
							blend_mode = "normal"
						})
						start_x = weapon_class_icon:right() + icon_margin
					else
	--					log("TOTAL CRACKDOWN: ERROR! No icon data found for class " .. tostring(primary_class))
					end
				end
				
				table.sort(subclasses)
				for i,subclass_name in ipairs(subclasses) do 
					local texture_name = tcd_gui_data.weapons.subclass[subclass_name]
					if texture_name then 
						local subclass_icon = panel:bitmap({
							name = "subclass_" .. i,
							texture = texture_name,
							w = icon_size,
							h = icon_size,
							x = start_x + ((i - 1) * (icon_size + icon_margin)),
							y = start_y,
							layer = 1,
							alpha = 1,
							blend_mode = "normal"
						})
					else
	--					log("TOTAL CRACKDOWN: ERROR! No icon data found for subclass " .. tostring(subclass_name))
					end
				end
				
			else
				log("TOTAL CRACKDOWN: ERROR! No inventory panel found for slot " .. tostring(weapon_slot))
			end
		end
		
		if self._boxes_by_name.primary then 
			local weapon_class,weapon_subclasses = find_weapon_archetypes(managers.blackmarket:equipped_primary())
			create_archetype_icons("primary",weapon_class,weapon_subclasses)
		end
		
		if self._boxes_by_name.secondary then 
			local weapon_class,weapon_subclasses = find_weapon_archetypes(managers.blackmarket:equipped_secondary())
			create_archetype_icons("secondary",weapon_class,weapon_subclasses)
		end
		if self._boxes_by_name.throwable then 
			local throwable_id = managers.blackmarket:equipped_grenade()
			
			local proj_td = throwable_id and tweak_data.blackmarket.projectiles[throwable_id]
			local weapon_class
			local weapon_subclasses = {}
			if proj_td then 
				weapon_class = proj_td.primary_class
				insert_subclasses(weapon_subclasses,proj_td.subclasses)
			end
			
			create_archetype_icons("throwable",weapon_class,weapon_subclasses)
		end
		if self._boxes_by_name.melee then 
	--		local melee_id = managers.blackmarket:equipped_melee_weapon()
			
			--MELEE WEAPONS ARE MELEE WEAPONS
			create_archetype_icons("melee","class_melee",{})
		end
		
		if self._boxes_by_name.character then 
			--john wick is... a precision weapon, i guess
		end
		
	end)
end