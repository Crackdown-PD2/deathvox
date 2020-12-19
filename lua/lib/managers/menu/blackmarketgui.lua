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

	local tcd_gui_data = {
		allowed_categories = {
			primaries = true,
			secondaries = true,
			masks = false
		},
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
	

	Hooks:PostHook(BlackMarketGuiSlotItem,"init","tcd_bmgui_slotitem_init",function(self, main_panel, data, x, y, w, h)
		
		local item_id
		local item_class
		local item_name = data.name
		local item_slot = data.slot
		local item_subclasses = {}
		local item_category = data.category
		local wtd = tweak_data.weapon
		local wftd = wtd.factory
		
		local function find_archetypes_from_part(partname)
			local partdata = wftd.parts[partname]
			if partdata then
				if partdata.subclass_modifiers then 
					for _,subclass_name in pairs(partdata.subclass_modifiers) do
						if not table.contains(item_subclasses,subclass_name) then 
							table.insert(item_subclasses,subclass_name)
						end
					end
				end
				if partdata.class_modifier then 
					item_class = partdata.class_modifier
				end
			end
		end
		
		if wftd.parts[item_name] then --is weapon attachment
			find_archetypes_from_part(item_name)
		elseif wtd[item_name] then --is weapon
			if item_category and tcd_gui_data.allowed_categories[item_category] then
				if managers.blackmarket._global.crafted_items[item_category] then 
					local blackmarket_item_data = managers.blackmarket._global.crafted_items[item_category][data.slot]
					if data.slot and blackmarket_item_data then 
	--					item_name = blackmarket_item_data.weapon_id --redundant
						item_class = wtd[item_name].primary_class
						if wtd[item_name].subclasses then 
							item_subclasses = table.deep_map_copy(wtd[item_name].subclasses)
						end
						
						local blupr = managers.blackmarket._global.crafted_items[item_category][data.slot].blueprint 
						if blupr then 
							for _,partname in pairs(blupr) do 
								find_archetypes_from_part(partname)
							end
						end
					end
				end
			end
		else
			--todo check skin blueprints
			--todo check subclasses from default blueprints
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