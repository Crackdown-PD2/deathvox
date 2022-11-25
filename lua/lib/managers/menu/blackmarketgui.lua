if deathvox:IsTotalCrackdownEnabled() then 

	local is_win32 = SystemInfo:platform() == Idstring("WIN32")
	local NOT_WIN_32 = not is_win32
	local WIDTH_MULTIPLIER = NOT_WIN_32 and 0.68 or 0.71
	local BOX_GAP = 13.5
	local GRID_H_MUL = (NOT_WIN_32 and 6.9 or 6.95) / 8
	local ITEMS_PER_ROW = 3
	local ITEMS_PER_COLUMN = 3
	local BUY_MASK_SLOTS = {
		6,
		3
	}
	local WEAPON_MODS_SLOTS = {
		6,
		1
	}
	local WEAPON_MODS_GRID_H_MUL = 0.126
	local massive_font = tweak_data.menu.pd2_massive_font
	local large_font = tweak_data.menu.pd2_large_font
	local medium_font = tweak_data.menu.pd2_medium_font
	local small_font = tweak_data.menu.pd2_small_font
	local tiny_font = tweak_data.menu.tiny_font
	local massive_font_size = tweak_data.menu.pd2_massive_font_size
	local large_font_size = tweak_data.menu.pd2_large_font_size
	local medium_font_size = tweak_data.menu.pd2_medium_font_size
	local small_font_size = tweak_data.menu.pd2_small_font_size
	local tiny_font_size = tweak_data.menu.pd2_tiny_font_size

	Hooks:PostHook(BlackMarketGuiSlotItem,"init","tcd_bmgui_slotitem_init",function(self, main_panel, data, x, y, w, h)
		local tcd_gui_data = deathvox.tcd_gui_data
		local wftd = tweak_data.weapon.factory

		local item_class
		local item_name = data.name
		local item_slot = data.slot
		local item_subclasses = {}
		local item_category = data.category or "none"

		if not item_name then
			return
		end
		

		local function insert_subclasses(new_subclasses)
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
			if partdata then
				if partdata.subclass_modifiers then
					insert_subclasses(partdata.subclass_modifiers)
				end
				if partdata.class_modifier then 
					item_class = partdata.class_modifier
				end
			end
		end
		
		
		if item_category == "characters" then 
			--nothing!
			if item_name == "jowi" then 
				item_class = "class_precision"
				insert_subclasses("subclass_quiet")
			end
		elseif item_category == "grenades" then 
			local proj_td = tweak_data.blackmarket.projectiles[item_name]
			if proj_td then 
				item_class = proj_td.primary_class
				insert_subclasses(proj_td.subclasses)
			end
		elseif item_category == "primaries" or item_category == "secondaries" then
		
			local wtd = tweak_data.weapon[item_name]
			
			if wtd then 
				item_class = wtd.primary_class
				insert_subclasses(wtd.subclasses)
			end
			
			if wftd.parts[item_name] then --is weapon attachment
				find_archetypes_from_part(item_name)
			end
			
			--currently, only weapons (primary/secondary) can have attachments, but if this changes, this should be copied and applied to other item categories accordingly
			if wtd then 
				if managers.blackmarket._global.crafted_items[item_category] then 
					local owned_item_data = item_slot and managers.blackmarket._global.crafted_items[item_category][item_slot]
					if owned_item_data then 
	--					item_name = owned_item_data.weapon_id --redundant
						local blueprint = owned_item_data.blueprint 
						if blueprint then 
							for _,partname in pairs(blueprint) do 
								find_archetypes_from_part(partname)
							end
						end
					end
				end
			end
		elseif item_category == "melee_weapons" then
			local melee_td = item_name and tweak_data.blackmarket.melee_weapons[item_name]
			if melee_td then 
--				item_class = melee_td.primary_class --unless we ever have a melee weapon that isn't of the Melee weapon class, this icon is just visual clutter
				insert_subclasses(melee_td.subclasses)
			end
		end
		
		local icon_size = 24
		local icon_margin = 4
		local start_x = icon_margin
		local start_y = icon_margin
		if data.equipped then 
			start_y = start_y + small_font_size
		end
		
		if item_class then 

			local texture_name = tcd_gui_data.weapons.class[item_class]
			if texture_name then 
				local weapon_class_icon = self._panel:bitmap({
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
				log("TOTAL CRACKDOWN: ERROR! No icon data found for class " .. tostring(item_class))
			end
		end
		
		table.sort(item_subclasses)
		for i,subclass_name in ipairs(item_subclasses) do 
			local texture_name = tcd_gui_data.weapons.subclass[subclass_name]
			if texture_name then 
				local subclass_icon = self._panel:bitmap({
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
				log("TOTAL CRACKDOWN: ERROR! No icon data found for subclass " .. tostring(subclass_name))
			end
		end
	end)

end




