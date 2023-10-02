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
		
		local function find_archetypes_from_part(part_data)
			if part_data then
				if part_data.subclass_modifiers then
					insert_subclasses(part_data.subclass_modifiers)
				end
				if part_data.class_modifier then 
					item_class = part_data.class_modifier
				end
			end
		end
		
		
		if item_category == "characters" then 
			--nothing!
			--[[
			--sorry wick you've been demoted
			if item_name == "jowi" then 
				item_class = "class_precision"
				insert_subclasses("subclass_quiet")
			end
			--]]
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
			
			--currently, only weapons (primary/secondary) can have attachments, but if this changes, this should be copied and applied to other item categories accordingly
			if managers.blackmarket._global.crafted_items[item_category] then
				local owned_item_data = item_slot and managers.blackmarket._global.crafted_items[item_category][item_slot]
				if owned_item_data then 
					local factory_id = owned_item_data.factory_id
					if wtd then --is weapon
	--					item_name = owned_item_data.weapon_id --redundant
						local blueprint = owned_item_data.blueprint 
						if blueprint then 
							for _,part_id in pairs(blueprint) do 
								local part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(part_id,factory_id,blueprint)
								find_archetypes_from_part(part_data)
							end
						end
						
					elseif wftd.parts[item_name] then --is weapon attachment
						local part_id = item_name
						local part_data = managers.weapon_factory:_part_data(part_id,factory_id,nil)
						
						find_archetypes_from_part(part_data)
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
	

	--only change is to add icon macros for item descriptions, at: line 1301
	function BlackMarketGui:update_info_text()
		local slot_data = self._slot_data
		local tab_data = self._tabs[self._selected]._data
		local prev_data = tab_data.prev_node_data
		local ids_category = Idstring(slot_data.category)
		local identifier = tab_data.identifier
		local updated_texts = {
			{
				text = ""
			},
			{
				text = ""
			},
			{
				text = ""
			},
			{
				text = ""
			},
			{
				text = ""
			}
		}
		local ignore_lock = false

		self._stats_text_modslist:set_text("")

		local suspicion, max_reached, min_reached = managers.blackmarket:get_suspicion_offset_of_local(tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)

		self:_set_detection(suspicion, max_reached, min_reached)
		self:_set_rename_info_text(nil)

		local is_renaming_this = self._renaming_item and not self._data.is_loadout and self._renaming_item.category == slot_data.category and self._renaming_item.slot == slot_data.slot

		self._armor_info_panel:set_visible(identifier == self.identifiers.armor)

		if identifier == self.identifiers.weapon then
			local price = slot_data.price or 0

			if slot_data.ignore_slot then
				-- Nothing
			elseif not slot_data.empty_slot then
				updated_texts[1].text = slot_data.name_localized

				if slot_data.name_color then
					updated_texts[1].text = "##" .. updated_texts[1].text .. "##"
					updated_texts[1].resource_color = {
						slot_data.name_color
					}
				end

				local resource_color = {}
				updated_texts[2].resource_color = resource_color

				if price > 0 then
					updated_texts[2].text = "##" .. managers.localization:to_upper_text(slot_data.not_moddable and "st_menu_cost" or "st_menu_value") .. " " .. managers.experience:cash_string(price) .. "##"

					table.insert(resource_color, slot_data.can_afford and tweak_data.screen_colors.text or tweak_data.screen_colors.important_1)
				end

				if not slot_data.not_moddable and not self._data.is_loadout then
					self:_set_rename_info_text(1)
				end

				if not slot_data.unlocked then
					if slot_data.lock_text then
						updated_texts[3].text = slot_data.lock_text
						updated_texts[3].below_stats = true
					else
						local skill_based = slot_data.skill_based
						local func_based = slot_data.func_based
						local level_based = slot_data.level and slot_data.level > 0
						local dlc_based = tweak_data.lootdrop.global_values[slot_data.global_value] and tweak_data.lootdrop.global_values[slot_data.global_value].dlc and not managers.dlc:is_dlc_unlocked(slot_data.global_value)
						local part_dlc_locked = slot_data.part_dlc_lock
						local skill_text_id = skill_based and (slot_data.skill_name or "bm_menu_skilltree_locked") or false
						local level_text_id = level_based and "bm_menu_level_req" or false
						local dlc_text_id = dlc_based and slot_data.dlc_locked or false
						local part_dlc_text_id = part_dlc_locked and "bm_menu_part_dlc_locked"
						local funclock_text_id = false

						if func_based then
							local unlocked, text_id = BlackMarketGui.get_func_based(func_based)

							if not unlocked then
								funclock_text_id = text_id
							end
						end

						local vr_lock_text = slot_data.vr_locked and "bm_menu_vr_locked"
						local text = ""

						if slot_data.install_lock then
							text = text .. managers.localization:to_upper_text(slot_data.install_lock, {}) .. "\n"
						elseif vr_lock_text then
							text = text .. managers.localization:to_upper_text(vr_lock_text) .. "\n"
						elseif dlc_text_id then
							text = text .. managers.localization:to_upper_text(dlc_text_id, {}) .. "\n"
						elseif part_dlc_text_id then
							text = text .. managers.localization:to_upper_text(part_dlc_text_id, {}) .. "\n"
						elseif funclock_text_id then
							text = text .. managers.localization:to_upper_text(funclock_text_id, {
								slot_data.name_localized
							}) .. "\n"
						elseif skill_text_id then
							text = text .. managers.localization:to_upper_text(skill_text_id, {
								slot_data.name_localized
							}) .. "\n"
						elseif level_text_id then
							text = text .. managers.localization:to_upper_text(level_text_id, {
								level = slot_data.level
							}) .. "\n"
						end

						updated_texts[3].text = text
						updated_texts[3].below_stats = true
					end
				elseif self._slot_data.can_afford == false then
					-- Nothing
				end

				if slot_data.last_weapon then
					updated_texts[5].text = updated_texts[5].text .. managers.localization:to_upper_text("bm_menu_last_weapon_warning") .. "\n"
				end

				if slot_data.global_value and slot_data.global_value ~= "normal" then
					updated_texts[4].text = updated_texts[4].text .. "##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"
					updated_texts[4].resource_color = tweak_data.lootdrop.global_values[slot_data.global_value].color
					updated_texts[4].below_stats = true
				end

				local weapon_id = slot_data.name
				local weapon_tweak = weapon_id and tweak_data.weapon[weapon_id]
				if weapon_tweak then
					if weapon_tweak.has_description then
						updated_texts[4].text = updated_texts[4].text .. "\n" .. managers.localization:to_upper_text(tweak_data.weapon[slot_data.name].desc_id)
						updated_texts[4].below_stats = true
					end
						
					if slot_data.not_moddable then
						local movement_penalty = weapon_tweak and tweak_data.upgrades.weapon_movement_penalty[weapon_tweak.categories[1]] or 1

						if movement_penalty < 1 then
							local penalty_as_string = string.format("%d%%", math.round((1 - movement_penalty) * 100))
							updated_texts[5].text = updated_texts[5].text .. managers.localization:to_upper_text("bm_menu_weapon_movement_penalty_info", {
								penalty = penalty_as_string
							})
						end
					end
					
					updated_texts[5].below_stats = true
				end
			elseif slot_data.locked_slot then
				ignore_lock = true
				updated_texts[1].text = managers.localization:to_upper_text("bm_menu_locked_weapon_slot")

				if slot_data.cannot_buy then
					updated_texts[3].text = slot_data.dlc_locked
				else
					updated_texts[2].text = slot_data.dlc_locked
				end

				updated_texts[4].text = managers.localization:text("bm_menu_locked_weapon_slot_desc")
			elseif not slot_data.is_loadout then
				local prefix = ""

				if not managers.menu:is_pc_controller() then
					prefix = managers.localization:get_default_macro("BTN_A")
				end

				updated_texts[1].text = prefix .. managers.localization:to_upper_text("bm_menu_btn_buy_new_weapon")
				updated_texts[4].text = managers.localization:text("bm_menu_empty_weapon_slot_buy_info")
			end
		elseif identifier == self.identifiers.melee_weapon then
			updated_texts[1].text = self._slot_data.name_localized

			if tweak_data.blackmarket.melee_weapons[slot_data.name].info_id then
				updated_texts[2].text = managers.localization:text(tweak_data.blackmarket.melee_weapons[slot_data.name].info_id)
				updated_texts[2].below_stats = true
			end

			if not slot_data.unlocked then
				local skill_based = slot_data.skill_based
				local level_based = slot_data.level and slot_data.level > 0
				local dlc_based = slot_data.dlc_based or tweak_data.lootdrop.global_values[slot_data.global_value] and tweak_data.lootdrop.global_values[slot_data.global_value].dlc and not managers.dlc:is_dlc_unlocked(slot_data.global_value)
				local skill_text_id = skill_based and (slot_data.skill_name or "bm_menu_skilltree_locked") or false
				local level_text_id = level_based and "bm_menu_level_req" or false
				local dlc_text_id = dlc_based and slot_data.dlc_locked or false
				local text = ""
				local vr_lock_text = slot_data.vr_locked and "bm_menu_vr_locked"

				if slot_data.install_lock then
					text = text .. managers.localization:to_upper_text(slot_data.install_lock, {}) .. "\n"
				elseif vr_lock_text then
					text = text .. managers.localization:to_upper_text(vr_lock_text) .. "\n"
				elseif skill_text_id then
					text = text .. managers.localization:to_upper_text(skill_text_id, {
						slot_data.name_localized
					}) .. "\n"
				elseif dlc_text_id then
					text = text .. managers.localization:to_upper_text(dlc_text_id, {}) .. "\n"
				elseif level_text_id then
					text = text .. managers.localization:to_upper_text(level_text_id, {
						level = slot_data.level
					}) .. "\n"
				end

				updated_texts[3].text = text
				updated_texts[3].below_stats = true
			end

			updated_texts[4].resource_color = {}
			local desc_text = managers.localization:text(tweak_data.blackmarket.melee_weapons[slot_data.name].desc_id)

			if slot_data.global_value and slot_data.global_value ~= "normal" then
				updated_texts[4].text = updated_texts[4].text .. "##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"

				table.insert(updated_texts[4].resource_color, tweak_data.lootdrop.global_values[slot_data.global_value].color)
			end

			updated_texts[4].below_stats = true
		elseif identifier == self.identifiers.grenade then
			updated_texts[1].text = self._slot_data.name_localized

			if not slot_data.unlocked then
				local grenade_tweak = tweak_data.blackmarket.projectiles[slot_data.name]

				if grenade_tweak and grenade_tweak.unlock_id then
					updated_texts[3].text = managers.localization:to_upper_text(grenade_tweak.unlock_id)
				else
					local skill_based = slot_data.skill_based
					local level_based = slot_data.level and slot_data.level > 0
					local dlc_based = false

					if slot_data.dlc_based then
						local dlc = tweak_data.lootdrop.global_values[slot_data.global_value] and tweak_data.lootdrop.global_values[slot_data.global_value].dlc or grenade_tweak.dlc
						dlc_based = dlc and not managers.dlc:is_dlc_unlocked(slot_data.global_value)
					end

					local skill_text_id = skill_based and (slot_data.skill_name or "bm_menu_skilltree_locked") or false
					local level_text_id = level_based and "bm_menu_level_req" or false
					local dlc_text_id = slot_data.dlc_locked or false
					local text = ""

					if slot_data.install_lock then
						text = text .. managers.localization:to_upper_text(slot_data.install_lock, {}) .. "\n"
					elseif skill_text_id then
						text = text .. managers.localization:to_upper_text(skill_text_id, {
							slot_data.name_localized
						}) .. "\n"
					elseif level_text_id then
						text = text .. managers.localization:to_upper_text(level_text_id, {
							level = slot_data.level
						}) .. "\n"
					elseif dlc_text_id then
						text = text .. managers.localization:to_upper_text(dlc_text_id, {}) .. "\n"
					end

					updated_texts[3].text = text
				end
			end
			
			updated_texts[4].resource_color = {}
			local grenade_macros = {
				BTN_INTERACT = managers.localization:btn_macro("interact", true),
				BTN_USE_ITEM = managers.localization:btn_macro("use_item", true),
				BTN_THROW_GRENADE = managers.localization:btn_macro("throw_grenade", true)
			}
			deathvox:insert_tcd_macros(grenade_macros)
			local desc_text = managers.localization:text(tweak_data.blackmarket.projectiles[slot_data.name].desc_id,grenade_macros)
			updated_texts[4].text = desc_text .. "\n"

			if slot_data.global_value and slot_data.global_value ~= "normal" then
				updated_texts[4].text = updated_texts[4].text .. "##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"

				table.insert(updated_texts[4].resource_color, tweak_data.lootdrop.global_values[slot_data.global_value].color)
			end

			updated_texts[4].below_stats = true
		elseif identifier == self.identifiers.armor then
			local armor_name_text = self._armor_info_panel:child("armor_name_text")
			local armor_image = self._armor_info_panel:child("armor_image")
			local armor_equipped = self._armor_info_panel:child("armor_equipped")

			armor_name_text:set_text(self._slot_data.name_localized)
			armor_name_text:set_w(self._armor_info_panel:w() - armor_image:right() - 20)
			self:make_fine_text(armor_name_text)
			armor_name_text:grow(2, 0)
			armor_equipped:set_visible(self._slot_data.equipped)
			armor_equipped:set_top(armor_name_text:bottom())
			armor_image:set_image(self._slot_data.bitmap_texture)
			self._armor_info_panel:set_h(armor_image:bottom())

			if not self._slot_data.unlocked then
				updated_texts[3].text = utf8.to_upper(managers.localization:text(slot_data.level == 0 and (slot_data.skill_name or "bm_menu_skilltree_locked") or "bm_menu_level_req", {
					level = slot_data.level,
					SKILL = slot_data.name
				}))
				updated_texts[3].below_stats = true
			elseif managers.player:has_category_upgrade("player", "damage_to_hot") and not table.contains(tweak_data:get_raw_value("upgrades", "damage_to_hot_data", "armors_allowed") or {}, self._slot_data.name) then
				updated_texts[3].text = managers.localization:to_upper_text("bm_menu_disables_damage_to_hot")
				updated_texts[3].below_stats = true
			elseif managers.player:has_category_upgrade("player", "armor_health_store_amount") then
				local bm_armor_tweak = tweak_data.blackmarket.armors[slot_data.name]
				local upgrade_level = bm_armor_tweak.upgrade_level
				local amount = managers.player:body_armor_value("skill_max_health_store", upgrade_level, 1)
				local multiplier = managers.player:upgrade_value("player", "armor_max_health_store_multiplier", 1)
				updated_texts[2].text = managers.localization:to_upper_text("bm_menu_armor_max_health_store", {
					amount = format_round(amount * multiplier * tweak_data.gui.stats_present_multiplier)
				})
				updated_texts[2].below_stats = true
			end
		elseif identifier == self.identifiers.armor_skins then
			local skin_tweak = tweak_data.economy.armor_skins[self._slot_data.name]
			updated_texts[1].text = self._slot_data.name_localized
			local desc = ""
			local desc_colors = {}

			if self._slot_data.equipped then
				updated_texts[2].text = "##" .. managers.localization:to_upper_text("bm_menu_equipped") .. "##"
				updated_texts[2].resource_color = tweak_data.screen_colors.text
			elseif not self._slot_data.cosmetic_unlocked then
				if slot_data.dlc_locked then
					updated_texts[3].text = managers.localization:to_upper_text(slot_data.dlc_locked)
				else
					updated_texts[2].text = "##" .. managers.localization:to_upper_text("bm_menu_item_locked") .. "##"
					updated_texts[2].resource_color = tweak_data.screen_colors.important_1
				end
			end

			if self._slot_data.cosmetic_rarity then
				local rarity_color = tweak_data.economy.rarities[self._slot_data.cosmetic_rarity].color or tweak_data.screen_colors.text
				updated_texts[1].text = "##" .. self._slot_data.name_localized .. "##"
				updated_texts[1].resource_color = rarity_color
				local rarity = managers.localization:to_upper_text("bm_menu_steam_item_rarity", {
					rarity = managers.localization:text(tweak_data.economy.rarities[self._slot_data.cosmetic_rarity].name_id)
				})
				desc = desc .. rarity .. "\n\n"

				table.insert(desc_colors, rarity_color)
			end

			if skin_tweak.desc_id then
				local desc_text = managers.localization:text(skin_tweak.desc_id)

				if desc_text ~= " " then
					desc = desc .. desc_text
					desc = desc .. "\n\n"
				end
			end

			if skin_tweak.challenge_id then
				desc = desc .. "##" .. managers.localization:to_upper_text("menu_unlock_condition") .. "##\n"

				table.insert(desc_colors, tweak_data.screen_colors.challenge_title)

				desc = desc .. managers.localization:text(skin_tweak.challenge_id)
			elseif not skin_tweak.free then
				if skin_tweak.unlock_id then
					desc = desc .. managers.localization:text(skin_tweak.unlock_id) .. "\n"

					table.insert(desc_colors, tweak_data.screen_colors.challenge_title)
				else
					local safe = self:get_safe_for_economy_item(slot_data.name)
					safe = safe and safe.name_id and managers.localization:text(safe.name_id) or "invalid skin"
					desc = desc .. managers.localization:text("bm_menu_purchase_steam", {
						safe = safe
					}) .. "\n"

					table.insert(desc_colors, tweak_data.screen_colors.challenge_title)
				end
			end

			updated_texts[4].text = desc
			updated_texts[4].resource_color = desc_colors
			updated_texts[4].below_stats = true

			if slot_data.global_value and slot_data.global_value ~= "normal" then
				updated_texts[4].text = updated_texts[4].text .. "##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"

				table.insert(updated_texts[4].resource_color, tweak_data.lootdrop.global_values[slot_data.global_value].color)
			end
		elseif identifier == self.identifiers.player_style then
			local player_style = slot_data.name
			local player_style_tweak = tweak_data.blackmarket.player_styles[player_style]
			if player_style_tweak then
				updated_texts[1].text = slot_data.name_localized

				if not slot_data.unlocked then
					updated_texts[2].text = "##" .. managers.localization:to_upper_text("bm_menu_item_locked") .. "##"
					updated_texts[2].resource_color = tweak_data.screen_colors.important_1
					updated_texts[3].text = slot_data.dlc_locked and managers.localization:to_upper_text(slot_data.dlc_locked) or managers.localization:to_upper_text("bm_menu_dlc_locked")
				end

				local desc_id = player_style_tweak.desc_id
				local desc_colors = {}
				updated_texts[4].text = desc_id and managers.localization:text(desc_id) or ""

				if slot_data.global_value and slot_data.global_value ~= "normal" then
					local gvalue_tweak = tweak_data.lootdrop.global_values[slot_data.global_value]

					if gvalue_tweak.desc_id then
						updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text(gvalue_tweak.desc_id) .. "##"

						table.insert(desc_colors, gvalue_tweak.color)
					end
				end

				if #desc_colors == 1 then
					updated_texts[4].resource_color = desc_colors[1]
				else
					updated_texts[4].resource_color = desc_colors
				end
			end
		elseif identifier == self.identifiers.suit_variation then
			local player_style = self._data.prev_node_data.name
			local player_style_tweak = tweak_data.blackmarket.player_styles[player_style]
			local suit_variation = slot_data.name
			local suit_variation_tweak = player_style_tweak.material_variations[suit_variation]
			updated_texts[1].text = slot_data.name_localized

			if not slot_data.unlocked then
				updated_texts[2].text = "##" .. managers.localization:to_upper_text("bm_menu_item_locked") .. "##"
				updated_texts[2].resource_color = tweak_data.screen_colors.important_1
				updated_texts[3].text = slot_data.dlc_locked and managers.localization:to_upper_text(slot_data.dlc_locked) or managers.localization:to_upper_text("bm_menu_dlc_locked")
			end

			local desc_id = suit_variation_tweak and suit_variation_tweak.desc_id or "menu_default"
			local desc_colors = {}
			updated_texts[4].text = desc_id and managers.localization:text(desc_id) or ""

			if slot_data.global_value and slot_data.global_value ~= "normal" then
				local gvalue_tweak = tweak_data.lootdrop.global_values[slot_data.global_value]

				if gvalue_tweak.desc_id then
					updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text(gvalue_tweak.desc_id) .. "##"

					table.insert(desc_colors, gvalue_tweak.color)
				end
			end

			if #desc_colors == 1 then
				updated_texts[4].resource_color = desc_colors[1]
			else
				updated_texts[4].resource_color = desc_colors
			end
		elseif identifier == self.identifiers.glove then
			local glove_id = slot_data.name
			local glove_tweak = tweak_data.blackmarket.gloves[glove_id]
			if glove_tweak then
				updated_texts[1].text = slot_data.name_localized

				if not slot_data.unlocked then
					updated_texts[2].text = "##" .. managers.localization:to_upper_text("bm_menu_item_locked") .. "##"
					updated_texts[2].resource_color = tweak_data.screen_colors.important_1
					updated_texts[3].text = slot_data.dlc_locked and managers.localization:to_upper_text(slot_data.dlc_locked) or managers.localization:to_upper_text("bm_menu_dlc_locked")
				end

				local desc_id = glove_tweak.desc_id
				local desc_colors = {}
				updated_texts[4].text = desc_id and managers.localization:text(desc_id) or ""

				if slot_data.global_value and slot_data.global_value ~= "normal" then
					local gvalue_tweak = tweak_data.lootdrop.global_values[slot_data.global_value]

					if gvalue_tweak.desc_id then
						updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text(gvalue_tweak.desc_id) .. "##"

						table.insert(desc_colors, gvalue_tweak.color)
					end
				end

				if #desc_colors == 1 then
					updated_texts[4].resource_color = desc_colors[1]
				else
					updated_texts[4].resource_color = desc_colors
				end
			end
		elseif identifier == self.identifiers.mask then
			local price = slot_data.price
			price = price or (type(slot_data.unlocked) == "number" or managers.money:get_mask_slot_sell_value(slot_data.slot)) and managers.money:get_mask_sell_value(slot_data.name, slot_data.global_value)

			if not slot_data.empty_slot then
				updated_texts[1].text = slot_data.name_localized

				if not self._data.is_loadout and slot_data.slot ~= 1 and slot_data.unlocked == true then
					self:_set_rename_info_text(1)
				end

				local resource_colors = {}

				if price > 0 and slot_data.slot ~= 1 then
					updated_texts[2].text = "##" .. managers.localization:to_upper_text("st_menu_value") .. " " .. managers.experience:cash_string(price) .. "##" .. "   "

					table.insert(resource_colors, slot_data.can_afford ~= false and tweak_data.screen_colors.text or tweak_data.screen_colors.important_1)
				end

				if slot_data.num_backs then
					updated_texts[2].text = updated_texts[2].text .. "##" .. managers.localization:to_upper_text("bm_menu_item_amount", {
						amount = math.abs(slot_data.unlocked)
					}) .. "##"

					table.insert(resource_colors, tweak_data.screen_colors.text)
				end

				if #resource_colors == 1 then
					updated_texts[2].resource_color = resource_colors[1]
				else
					updated_texts[2].resource_color = resource_colors
				end

				local achievement_tracker = tweak_data.achievement.mask_tracker
				local mask_id = slot_data.name
				local achievement_lock_id = managers.dlc:is_mask_achievement_locked(mask_id)
				local achievement_milestone_lock_id = managers.dlc:is_mask_achievement_milestone_locked(mask_id)

				if slot_data.dlc_locked then
					updated_texts[3].text = managers.localization:to_upper_text(slot_data.dlc_locked)
				elseif slot_data.infamy_lock then
					updated_texts[3].text = managers.localization:to_upper_text("menu_infamy_lock_info")
				elseif mask_id and achievement_tracker[mask_id] and (not slot_data.unlocked or type(slot_data.unlocked) == "number" and slot_data.unlocked <= 0) then
					local achievement_data = achievement_tracker[mask_id]
					local max_progress = achievement_data.max_progress
					local text_id = achievement_data.text_id
					local award = achievement_data.award
					local stat = achievement_data.stat

					if stat and max_progress > 0 then
						local progress_left = max_progress - (managers.achievment:get_stat(stat) or 0)

						if progress_left > 0 then
							local progress = tostring(progress_left)
							updated_texts[3].text = "##" .. managers.localization:text(achievement_data.text_id, {
								progress = progress
							}) .. "##"
							updated_texts[3].resource_color = tweak_data.screen_colors.button_stage_2
						end
					elseif award and not managers.achievment:get_info(award).awarded then
						updated_texts[3].text = "##" .. managers.localization:text(achievement_data.text_id) .. "##"
						updated_texts[3].resource_color = tweak_data.screen_colors.button_stage_2
					end
				elseif achievement_lock_id and (not slot_data.unlocked or type(slot_data.unlocked) == "number" and slot_data.unlocked <= 0) then
					local dlc_tweak = tweak_data.dlc[achievement_lock_id]
					local achievement = dlc_tweak and dlc_tweak.achievement_id
					local achievement_visual = tweak_data.achievement.visual[achievement]

					if achievement_visual then
						updated_texts[3].text = managers.localization:to_upper_text(achievement_visual.desc_id)

						if achievement_visual.progress then
							updated_texts[3].text = updated_texts[3].text .. " (" .. tostring(achievement_visual.progress.get()) .. "/" .. tostring(achievement_visual.progress.max) .. ")"
						end
					end
				elseif achievement_milestone_lock_id and (not slot_data.unlocked or type(slot_data.unlocked) == "number" and slot_data.unlocked <= 0) then
					for _, data in ipairs(tweak_data.achievement.milestones) do
						if data.id == achievement_milestone_lock_id then
							updated_texts[3].text = managers.localization:to_upper_text("bm_menu_milestone_reward_unlock", {
								NUM = tostring(data.at)
							})

							break
						end
					end
				elseif managers.dlc:is_content_skirmish_locked("masks", mask_id) and (not slot_data.unlocked or type(slot_data.unlocked) == "number" and slot_data.unlocked <= 0) then
					updated_texts[3].text = managers.localization:to_upper_text("bm_menu_skirmish_content_reward")
				elseif managers.dlc:is_content_crimespree_locked("masks", mask_id) and (not slot_data.unlocked or type(slot_data.unlocked) == "number" and slot_data.unlocked <= 0) then
					updated_texts[3].text = managers.localization:to_upper_text("bm_menu_crimespree_content_reward")
				end

				if mask_id and mask_id ~= "empty" then
					local desc_id = tweak_data.blackmarket.masks[mask_id].desc_id
					updated_texts[4].text = desc_id and managers.localization:text(desc_id) or Application:production_build() and "Add ##desc_id## to ##" .. mask_id .. "## in tweak_data.blackmarket.masks" or ""

					if slot_data.global_value and slot_data.global_value ~= "normal" then
						local gvalue_tweak = tweak_data.lootdrop.global_values[slot_data.global_value]

						if gvalue_tweak.desc_id then
							updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text(gvalue_tweak.desc_id) .. "##"
							updated_texts[4].resource_color = gvalue_tweak.color
						end
					end
				end
			elseif slot_data.locked_slot then
				ignore_lock = true
				updated_texts[1].text = managers.localization:to_upper_text("bm_menu_locked_mask_slot")

				if slot_data.cannot_buy then
					updated_texts[3].text = slot_data.dlc_locked
				else
					updated_texts[2].text = slot_data.dlc_locked
				end

				updated_texts[4].text = managers.localization:text("bm_menu_locked_mask_slot_desc")
			else
				if slot_data.cannot_buy then
					updated_texts[2].text = managers.localization:to_upper_text("bm_menu_empty_mask_slot")
					updated_texts[3].text = managers.localization:to_upper_text("bm_menu_no_masks_in_stash_varning")
				else
					local prefix = ""

					if not managers.menu:is_pc_controller() then
						prefix = managers.localization:get_default_macro("BTN_A")
					end

					updated_texts[1].text = prefix .. managers.localization:to_upper_text("bm_menu_btn_buy_new_mask")
				end

				updated_texts[4].text = managers.localization:text("bm_menu_empty_mask_slot_buy_info")
			end
		elseif identifier == self.identifiers.weapon_mod then
			local price = slot_data.price or managers.money:get_weapon_modify_price(prev_data.name, slot_data.name, slot_data.global_value)
			updated_texts[1].text = slot_data.name_localized
			local resource_colors = {}

			if price > 0 then
				updated_texts[2].text = "##" .. managers.localization:to_upper_text("st_menu_cost") .. " " .. managers.experience:cash_string(price) .. "##"

				table.insert(resource_colors, slot_data.can_afford and tweak_data.screen_colors.text or tweak_data.screen_colors.important_1)
			end

			local unlocked = slot_data.unlocked and slot_data.unlocked ~= true and slot_data.unlocked or 0
			updated_texts[2].text = updated_texts[2].text .. (price > 0 and "   " or "")

			if slot_data.previewing then
				updated_texts[2].text = updated_texts[2].text .. managers.localization:to_upper_text("bm_menu_mod_preview")
			elseif slot_data.free_of_charge then
				updated_texts[2].text = updated_texts[2].text .. (unlocked > 0 and managers.localization:to_upper_text("bm_menu_item_unlocked") or managers.localization:to_upper_text("bm_menu_item_locked"))
			else
				updated_texts[2].text = updated_texts[2].text .. "##" .. managers.localization:to_upper_text("bm_menu_item_amount", {
					amount = tostring(math.abs(unlocked))
				}) .. "##"

				table.insert(resource_colors, math.abs(unlocked) > 0 and tweak_data.screen_colors.text or tweak_data.screen_colors.important_1)
			end

			if #resource_colors == 1 then
				updated_texts[2].resource_color = resource_colors[1]
			else
				updated_texts[2].resource_color = resource_colors
			end

			local can_not_afford = slot_data.can_afford == false
			local conflicted = slot_data.conflict
			local out_of_item = slot_data.unlocked and slot_data.unlocked ~= true and slot_data.unlocked == 0

			if slot_data.install_lock then
				updated_texts[3].text = managers.localization:to_upper_text(slot_data.install_lock)
				updated_texts[3].below_stats = true
			elseif slot_data.dlc_locked then
				updated_texts[3].text = managers.localization:to_upper_text(slot_data.dlc_locked)
			elseif conflicted then
				updated_texts[3].text = managers.localization:to_upper_text("bm_menu_conflict", {
					conflict = slot_data.conflict
				})
			elseif slot_data.lock_texture then
				local achievement_lock_id = managers.dlc:is_weapon_mod_achievement_locked(slot_data.name)
				local achievement_milestone_lock_id = managers.dlc:is_weapon_mod_achievement_milestone_locked(slot_data.name)

				if achievement_lock_id then
					local dlc_tweak = tweak_data.dlc[achievement_lock_id]
					local achievement = dlc_tweak and dlc_tweak.achievement_id
					local achievement_visual = tweak_data.achievement.visual[achievement]

					if achievement_visual then
						updated_texts[3].text = managers.localization:to_upper_text(achievement_visual.desc_id)

						if achievement_visual.progress then
							updated_texts[3].text = updated_texts[3].text .. " (" .. tostring(achievement_visual.progress.get()) .. "/" .. tostring(achievement_visual.progress.max) .. ")"
						end

						updated_texts[3].below_stats = true
					end
				elseif achievement_milestone_lock_id then
					for _, data in ipairs(tweak_data.achievement.milestones) do
						if data.id == achievement_milestone_lock_id then
							updated_texts[3].text = managers.localization:to_upper_text("bm_menu_milestone_reward_unlock", {
								NUM = tostring(data.at)
							})
							updated_texts[3].below_stats = true

							break
						end
					end
				elseif managers.dlc:is_content_skirmish_locked("weapon_mods", slot_data.name) then
					updated_texts[3].text = managers.localization:to_upper_text("bm_menu_skirmish_content_reward")
					updated_texts[3].below_stats = true
				elseif managers.dlc:is_content_crimespree_locked("weapon_mods", slot_data.name) then
					updated_texts[3].text = managers.localization:to_upper_text("bm_menu_crimespree_content_reward")
					updated_texts[3].below_stats = true
				end
			end

			local part_id = slot_data.name
			local part_data = part_id and tweak_data.weapon.factory.parts[part_id]
			local perks = part_data and part_data.perks
			local is_gadget = part_data and part_data.type == "gadget" or perks and table.contains(perks, "gadget")
			local is_ammo = part_data and part_data.type == "ammo" or perks and table.contains(perks, "ammo")
			local is_bayonet = part_data and part_data.type == "bayonet" or perks and table.contains(perks, "bayonet")
			local is_bipod = part_data and part_data.type == "bipod" or perks and table.contains(perks, "bipod")
			local is_underbarrel_ammo = part_data and part_data.type == "underbarrel_ammo" or perks and table.contains(perks, "underbarrel_ammo")
			local has_desc = part_data and part_data.has_description == true
			updated_texts[4].resource_color = {}

			if is_gadget or is_ammo or is_bayonet or is_bipod or is_underbarrel_ammo or has_desc then
				local crafted = managers.blackmarket:get_crafted_category_slot(prev_data.category, prev_data.slot)
				updated_texts[4].text = managers.weapon_factory:get_part_desc_by_part_id_from_weapon(part_id, crafted.factory_id, crafted.blueprint)
			end

			if slot_data.global_value and slot_data.global_value ~= "normal" then
				if is_gadget or is_ammo or is_bayonet or is_underbarrel_ammo or has_desc then
					updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"
				else
					updated_texts[4].text = "##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"
				end

				table.insert(updated_texts[4].resource_color, tweak_data.lootdrop.global_values[slot_data.global_value].color)
			end

			local current_zoom = slot_data.comparision_data and slot_data.comparision_data.zoom or 1
			local zoom_stat = part_data and part_data.stats and part_data.stats.zoom
			local gadget_zoom_stat = part_data and part_data.stats and part_data.stats.gadget_zoom
			local gadget_zoom_add_stat = part_data and part_data.stats and part_data.stats.gadget_zoom_add
			local zoom_magnification = nil

			if zoom_stat then
				zoom_magnification = 1 + zoom_stat
			elseif gadget_zoom_stat then
				zoom_magnification = gadget_zoom_stat
			elseif gadget_zoom_add_stat then
				zoom_magnification = current_zoom + gadget_zoom_add_stat
			end

			if zoom_magnification then
				zoom_magnification = math.clamp(zoom_magnification, 1, #tweak_data.weapon.stats.zoom)
				zoom_magnification = tweak_data.weapon.stats.zoom[1] / tweak_data.weapon.stats.zoom[zoom_magnification]
				zoom_magnification = math.round(zoom_magnification * zoom_magnification, 0.25)

				if zoom_magnification > 1 then
					local zoom_level_string = managers.localization:text("bm_menu_sight_zoom_level", {
						zoom = zoom_magnification
					})
					updated_texts[1].text = updated_texts[1].text .. "  " .. zoom_level_string
				end
			end

			if perks and table.contains(perks, "bonus") then
				updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text("bm_menu_disables_cosmetic_bonus") .. "##"

				table.insert(updated_texts[4].resource_color, tweak_data.screen_colors.text)
			end

			updated_texts[4].below_stats = true
			local weapon_id = managers.weapon_factory:get_factory_id_by_weapon_id(prev_data.name)

			local function get_forbids(weapon_id, part_id)
				local weapon_data = tweak_data.weapon.factory[weapon_id]

				if not weapon_data then
					return {}
				end

				local default_parts = {}

				for _, part in ipairs(weapon_data.default_blueprint) do
					table.insert(default_parts, part)

					local part_data = tweak_data.weapon.factory.parts[part]

					if part_data and part_data.adds then
						for _, part in ipairs(part_data.adds) do
							table.insert(default_parts, part)
						end
					end
				end

				local weapon_mods = {}

				for _, part in ipairs(weapon_data.uses_parts) do
					if not table.contains(default_parts, part) then
						local part_data = tweak_data.weapon.factory.parts[part]

						if part_data and not part_data.unatainable then
							weapon_mods[part] = {}
						end
					end
				end

				for part, _ in pairs(weapon_mods) do
					local part_data = tweak_data.weapon.factory.parts[part]

					if part_data.forbids then
						for other_part, _ in pairs(weapon_mods) do
							local other_part_data = tweak_data.weapon.factory.parts[part]

							if table.contains(part_data.forbids, other_part) then
								table.insert(weapon_mods[part], other_part)
								table.insert(weapon_mods[other_part], part)
							end
						end
					end
				end

				return weapon_mods[part_id]
			end

			local forbidden_parts = get_forbids(weapon_id, part_id)
			local droppable_mods = managers.blackmarket:get_dropable_mods_by_weapon_id(prev_data.name)

			if slot_data.removes and #slot_data.removes > 0 then
				local removed_mods = ""

				for i, name in ipairs(slot_data.removes) do
					local mod_data = tweak_data.weapon.factory.parts[name]

					if droppable_mods[mod_data.type] then
						local mod_name = mod_data and mod_data.name_id or name
						mod_name = managers.localization:text(mod_name)
						removed_mods = string.format("%s%s%s", removed_mods, i > 1 and ", " or "", mod_name)
					end
				end

				if #removed_mods > 0 then
					updated_texts[5].text = managers.localization:to_upper_text("bm_mod_equip_remove", {
						mod = removed_mods
					})
				end
			elseif forbidden_parts and #forbidden_parts > 0 then
				local forbids = {}

				for i, forbidden_part in ipairs(forbidden_parts) do
					local data = tweak_data.weapon.factory.parts[forbidden_part]

					if data then
						forbids[data.type] = (forbids[data.type] or 0) + 1
					end
				end

				local text = ""

				for category, amount in pairs(forbids) do
					if droppable_mods[category] then
						if text ~= "" then
							text = text .. "\n"
						end

						local category_count = 0
						local weapon_data = tweak_data.weapon.factory[weapon_id]

						for _, part_name in ipairs(weapon_data.uses_parts) do
							local part_data = tweak_data.weapon.factory.parts[part_name]

							if part_data and not part_data.unatainable and part_data.type == category and not table.contains(weapon_data.default_blueprint, part_name) then
								category_count = category_count + 1
							end
						end

						local percent_forbidden = amount / category_count
						local category = managers.localization:text("bm_menu_" .. tostring(category) .. "_plural")
						local quantifier = percent_forbidden == 1 and "all" or percent_forbidden > 0.66 and "most" or "some"
						quantifier = managers.localization:text("bm_mod_incompatibility_" .. tostring(quantifier))
						text = managers.localization:to_upper_text("bm_mod_incompatibilities", {
							quantifier = quantifier,
							category = category
						})
					end
				end

				updated_texts[5].text = text
			end
		elseif identifier == self.identifiers.mask_mod then
			if not managers.blackmarket:currently_customizing_mask() then
				return
			end

			local mask_mod_info = managers.blackmarket:info_customize_mask()
			local mask_base_price = managers.blackmarket:get_customize_mask_base_value()
			updated_texts[2].text = updated_texts[2].text .. managers.localization:to_upper_text("bm_menu_masks") .. ": " .. self._data.topic_params.mask_name

			if mask_base_price and mask_base_price > 0 then
				updated_texts[2].text = updated_texts[2].text .. " " .. managers.experience:cash_string(mask_base_price)
			end

			updated_texts[2].text = updated_texts[2].text .. "\n"
			local resource_color = {}
			local material_text = managers.localization:to_upper_text("bm_menu_materials")
			local pattern_text = managers.localization:to_upper_text("bm_menu_textures")
			local colors_text = managers.localization:to_upper_text("bm_menu_colors")
			local color_a_text = managers.localization:to_upper_text("bm_menu_color_a")
			local color_b_text = managers.localization:to_upper_text("bm_menu_color_b")

			if mask_mod_info[1].overwritten then
				updated_texts[2].text = updated_texts[2].text .. material_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_overwritten") .. "##" .. "\n"

				table.insert(resource_color, tweak_data.screen_colors.risk)
			elseif mask_mod_info[1].is_good then
				updated_texts[2].text = updated_texts[2].text .. material_text .. ": " .. managers.localization:text(mask_mod_info[1].text)

				if mask_mod_info[1].price and mask_mod_info[1].price > 0 then
					updated_texts[2].text = updated_texts[2].text .. " " .. managers.experience:cash_string(mask_mod_info[1].price)
				end

				updated_texts[2].text = updated_texts[2].text .. "\n"
			else
				updated_texts[2].text = updated_texts[2].text .. material_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_not_selected") .. "##" .. "\n"

				table.insert(resource_color, tweak_data.screen_colors.important_1)
			end

			if mask_mod_info[2].overwritten then
				updated_texts[2].text = updated_texts[2].text .. pattern_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_overwritten") .. "##" .. "\n"

				table.insert(resource_color, tweak_data.screen_colors.risk)
			elseif mask_mod_info[2].is_good then
				updated_texts[2].text = updated_texts[2].text .. pattern_text .. ": " .. managers.localization:text(mask_mod_info[2].text)

				if mask_mod_info[2].price and mask_mod_info[2].price > 0 then
					updated_texts[2].text = updated_texts[2].text .. " " .. managers.experience:cash_string(mask_mod_info[2].price)
				end

				updated_texts[2].text = updated_texts[2].text .. "\n"
			else
				updated_texts[2].text = updated_texts[2].text .. pattern_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_not_selected") .. "##" .. "\n"

				table.insert(resource_color, tweak_data.screen_colors.important_1)
			end

			local should_show_one_color = mask_mod_info[4].is_same or mask_mod_info[3].overwritten and mask_mod_info[4].overwritten

			if should_show_one_color then
				if mask_mod_info[3].overwritten then
					updated_texts[2].text = updated_texts[2].text .. colors_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_overwritten") .. "##" .. "\n"

					table.insert(resource_color, tweak_data.screen_colors.risk)
				elseif mask_mod_info[3].is_good then
					updated_texts[2].text = updated_texts[2].text .. colors_text .. ": " .. managers.localization:text(mask_mod_info[3].text)

					if mask_mod_info[3].price and mask_mod_info[3].price > 0 then
						updated_texts[2].text = updated_texts[2].text .. " " .. managers.experience:cash_string(mask_mod_info[3].price)
					end

					updated_texts[2].text = updated_texts[2].text .. "\n"
				else
					updated_texts[2].text = updated_texts[2].text .. colors_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_not_selected") .. "##" .. "\n"

					table.insert(resource_color, tweak_data.screen_colors.important_1)
				end
			else
				if mask_mod_info[3].overwritten then
					updated_texts[2].text = updated_texts[2].text .. color_a_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_overwritten") .. "##" .. "\n"

					table.insert(resource_color, tweak_data.screen_colors.risk)
				elseif mask_mod_info[3].is_good then
					updated_texts[2].text = updated_texts[2].text .. color_a_text .. ": " .. managers.localization:text(mask_mod_info[3].text)

					if mask_mod_info[3].price and mask_mod_info[3].price > 0 then
						updated_texts[2].text = updated_texts[2].text .. " " .. managers.experience:cash_string(mask_mod_info[3].price)
					end

					updated_texts[2].text = updated_texts[2].text .. "\n"
				else
					updated_texts[2].text = updated_texts[2].text .. color_a_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_not_selected") .. "##" .. "\n"

					table.insert(resource_color, tweak_data.screen_colors.important_1)
				end

				if mask_mod_info[4].overwritten then
					updated_texts[2].text = updated_texts[2].text .. color_b_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_overwritten") .. "##" .. "\n"

					table.insert(resource_color, tweak_data.screen_colors.risk)
				elseif mask_mod_info[4].is_good then
					updated_texts[2].text = updated_texts[2].text .. color_b_text .. ": " .. managers.localization:text(mask_mod_info[4].text)

					if mask_mod_info[4].price and mask_mod_info[4].price > 0 then
						updated_texts[2].text = updated_texts[2].text .. " " .. managers.experience:cash_string(mask_mod_info[4].price)
					end

					updated_texts[2].text = updated_texts[2].text .. "\n"
				else
					updated_texts[2].text = updated_texts[2].text .. color_b_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_not_selected") .. "##" .. "\n"

					table.insert(resource_color, tweak_data.screen_colors.important_1)
				end
			end

			updated_texts[2].text = updated_texts[2].text .. "\n"
			local price, can_afford = managers.blackmarket:get_customize_mask_value()

			if slot_data.global_value then
				local mask = managers.blackmarket:get_crafted_category("masks")[slot_data.prev_slot] or {}
				updated_texts[4].text = "\n\n" .. managers.localization:to_upper_text("menu_bm_highlighted") .. "\n" .. slot_data.name_localized
				local mod_price = managers.money:get_mask_part_price_modified(slot_data.category, slot_data.name, slot_data.global_value, mask.mask_id) or 0

				if mod_price > 0 then
					updated_texts[4].text = updated_texts[4].text .. " " .. managers.experience:cash_string(mod_price)
				else
					updated_texts[4].text = updated_texts[4].text
				end

				if slot_data.unlocked and slot_data.unlocked ~= true and slot_data.unlocked ~= 0 then
					updated_texts[4].text = updated_texts[4].text .. "\n" .. managers.localization:to_upper_text("bm_menu_item_amount", {
						amount = math.abs(slot_data.unlocked)
					})
				end

				updated_texts[4].resource_color = {}

				if slot_data.global_value and slot_data.global_value ~= "normal" then
					updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"

					table.insert(updated_texts[4].resource_color, tweak_data.lootdrop.global_values[slot_data.global_value].color)
				end

				if slot_data.dlc_locked then
					updated_texts[3].text = managers.localization:to_upper_text(slot_data.dlc_locked)
				end

				local customize_mask_blueprint = managers.blackmarket:get_customize_mask_blueprint()
				local index = {
					colors = 3,
					materials = 1,
					textures = 2
				}
				index.mask_colors = index.colors
				index.colors = nil
				index = index[slot_data.category]

				if index == 1 then
					customize_mask_blueprint.material = {
						global_value = slot_data.global_value,
						id = slot_data.name
					}
				elseif index == 2 then
					customize_mask_blueprint.pattern = {
						global_value = slot_data.global_value,
						id = slot_data.name
					}
				elseif index == 3 then
					customize_mask_blueprint.color = {
						global_value = slot_data.global_value,
						id = slot_data.name
					}
				end

				local part_info = managers.blackmarket:get_info_from_mask_blueprint(customize_mask_blueprint, mask.mask_id)
				part_info = part_info[index]

				if part_info.override then
					updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text("menu_bm_overwrite", {
						category = managers.localization:text("bm_menu_" .. part_info.override)
					}) .. "##"

					table.insert(updated_texts[4].resource_color, tweak_data.screen_colors.risk)
				end
			end

			if price and price > 0 then
				updated_texts[2].text = updated_texts[2].text .. managers.localization:to_upper_text("menu_bm_total_cost", {
					cost = (not can_afford and "##" or "") .. managers.experience:cash_string(price) .. (not can_afford and "##" or "")
				})

				if not can_afford then
					table.insert(resource_color, tweak_data.screen_colors.important_1)
				end
			end

			if #resource_color == 1 then
				updated_texts[2].resource_color = resource_color[1]
			else
				updated_texts[2].resource_color = resource_color
			end

			if not managers.blackmarket:can_finish_customize_mask() then
				local list_of_mods = ""
				local missed_mods = {}

				for _, data in ipairs(mask_mod_info) do
					if not data.is_good and not data.overwritten then
						table.insert(missed_mods, managers.localization:text(data.text))
					end
				end

				if #missed_mods > 1 then
					for i = 1, #missed_mods do
						list_of_mods = list_of_mods .. missed_mods[i]

						if i < #missed_mods - 1 then
							list_of_mods = list_of_mods .. ", "
						elseif i == #missed_mods - 1 then
							list_of_mods = list_of_mods .. ", "
						end
					end
				elseif #missed_mods == 1 then
					list_of_mods = missed_mods[1]
				end

				if slot_data.dlc_locked then
					updated_texts[3].text = updated_texts[3].text .. "\n" .. managers.localization:to_upper_text("bm_menu_missing_to_finalize_mask", {
						missed_mods = list_of_mods
					}) .. "\n"
				else
					updated_texts[3].text = managers.localization:to_upper_text("bm_menu_missing_to_finalize_mask", {
						missed_mods = list_of_mods
					}) .. "\n"
				end
			elseif price and managers.money:total() < price then
				if slot_data.dlc_locked then
					updated_texts[3].text = updated_texts[3].text .. "\n" .. managers.localization:to_upper_text("bm_menu_not_enough_cash") .. "\n"
				else
					updated_texts[3].text = managers.localization:to_upper_text("bm_menu_not_enough_cash") .. "\n"
				end
			end
		elseif identifier == self.identifiers.deployable then
			updated_texts[1].text = slot_data.name_localized

			if not self._slot_data.unlocked then
				local text_id = nil

				if slot_data.dlc_locked then
					text_id = slot_data.dlc_locked
				elseif slot_data.level == 0 then
					text_id = slot_data.skill_name or "bm_menu_skilltree_locked"
				else
					text_id = "bm_menu_level_req"
				end

				updated_texts[3].text = managers.localization:to_upper_text(text_id, {
					level = slot_data.level,
					SKILL = slot_data.name
				})
				updated_texts[3].text = updated_texts[3].text .. "\n"
			end

			updated_texts[4].resource_color = {}
			local deployable_macros = {
				BTN_INTERACT = managers.localization:btn_macro("interact", true),
				BTN_USE_ITEM = managers.localization:btn_macro("use_item", true),
				BTN_THROW_GRENADE = managers.localization:btn_macro("throw_grenade", true)
			}
			deathvox:insert_tcd_macros(deployable_macros)
			
			local desc_text = managers.localization:text(tweak_data.blackmarket.deployables[slot_data.name].desc_id, deployable_macros)
			
			updated_texts[4].text = desc_text .. "\n"

			if slot_data.global_value and slot_data.global_value ~= "normal" then
				updated_texts[4].text = updated_texts[4].text .. "##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"

				table.insert(updated_texts[4].resource_color, tweak_data.lootdrop.global_values[slot_data.global_value].color)
			end

			updated_texts[4].below_stats = true
		elseif identifier == self.identifiers.character then
			updated_texts[1].text = slot_data.name_localized

			if not slot_data.unlocked then
				local dlc_text_id = slot_data.dlc_locked or "ERR"
				local text = managers.localization:to_upper_text(dlc_text_id, {}) .. "\n"
				updated_texts[3].text = text
			end

			updated_texts[4].text = managers.localization:text(slot_data.name .. "_desc")
		elseif identifier == self.identifiers.weapon_cosmetic then
			updated_texts[1].text = managers.localization:to_upper_text("bm_menu_steam_item_name", {
				type = managers.localization:text("bm_menu_" .. slot_data.category),
				name = slot_data.name_localized
			})
			updated_texts[1].resource_color = tweak_data.screen_colors.text

			if slot_data.weapon_id then
				updated_texts[2].text = managers.weapon_factory:get_weapon_name_by_weapon_id(slot_data.weapon_id)
			end

			updated_texts[4].resource_color = {}
			local cosmetic_rarity = slot_data.cosmetic_rarity
			local cosmetic_quality = slot_data.cosmetic_quality
			local cosmetic_bonus = slot_data.cosmetic_bonus

			if slot_data.is_a_color_skin then
				if slot_data.equipped then
					local color_id = slot_data.name
					local color_tweak = tweak_data.blackmarket.weapon_skins[color_id]

					if not slot_data.unlocked then
						local global_value = slot_data.global_value
						local gvalue_tweak = tweak_data.lootdrop.global_values[global_value]
						local dlc = color_tweak.dlc or managers.dlc:global_value_to_dlc(global_value)
						local unlocked = not dlc or managers.dlc:is_dlc_unlocked(dlc)
						local have_color = managers.blackmarket:has_item(global_value, "weapon_skins", color_id)

						if not unlocked then
							updated_texts[5].text = managers.localization:text(gvalue_tweak and gvalue_tweak.unlock_id or "bm_menu_dlc_locked")
						elseif not have_color then
							local achievement_locked_content = managers.dlc:weapon_color_achievement_locked_content(color_id)
							local dlc_tweak = tweak_data.dlc[achievement_locked_content]
							local achievement = dlc_tweak and dlc_tweak.achievement_id

							if achievement and managers.achievment:get_info(achievement) then
								local achievement_visual = tweak_data.achievement.visual[achievement]
								updated_texts[5].text = managers.localization:text(achievement_visual and achievement_visual.desc_id or "achievement_" .. tostring(achievement) .. "_desc" or "bm_menu_dlc_locked")
							else
								updated_texts[5].text = managers.localization:text("bm_menu_dlc_locked")
							end
						end
					end

					local name_string = managers.localization:to_upper_text(color_tweak.name_id)
					local color_index_string = managers.localization:to_upper_text("bm_menu_weapon_color_index", {
						variation = managers.localization:text(tweak_data.blackmarket:get_weapon_color_index_string(slot_data.cosmetic_color_index))
					})
					local quality_string = managers.localization:to_upper_text("bm_menu_weapon_color_quality", {
						quality = managers.localization:text(tweak_data.economy.qualities[cosmetic_quality].name_id)
					})
					updated_texts[4].text = updated_texts[4].text .. name_string .. "\n" .. color_index_string .. "\n" .. quality_string

					table.insert(updated_texts[4].resource_color, tweak_data.screen_colors.text)
					table.insert(updated_texts[4].resource_color, tweak_data.economy.qualities[cosmetic_quality].color or tweak_data.screen_colors.text)
				else
					updated_texts[4].text = updated_texts[4].text .. managers.localization:text("bm_menu_customizable_weapon_color_desc")
				end
			else
				if not slot_data.unlocked then
					local safe = self:get_safe_for_economy_item(slot_data.name)
					safe = safe and safe.name_id or "invalid skin"
					local macros = {
						safe = managers.localization:text(safe)
					}
					local lock_text_id = slot_data.lock_text_id or "bm_menu_wcc_not_owned"
					updated_texts[5].text = (slot_data.default_blueprint and "" or "\n") .. managers.localization:text(lock_text_id, macros)
				elseif type(slot_data.unlocked) == "number" then
					updated_texts[2].text = updated_texts[2].text .. managers.localization:to_upper_text("bm_menu_item_amount", {
						amount = tostring(math.abs(slot_data.unlocked))
					})
				end

				if cosmetic_rarity then
					updated_texts[4].text = updated_texts[4].text .. managers.localization:to_upper_text("bm_menu_steam_item_rarity", {
						rarity = managers.localization:text(tweak_data.economy.rarities[cosmetic_rarity].name_id)
					})

					table.insert(updated_texts[4].resource_color, tweak_data.economy.rarities[cosmetic_rarity].color or tweak_data.screen_colors.text)
				end

				if cosmetic_quality then
					updated_texts[4].text = updated_texts[4].text .. (cosmetic_rarity and "\n" or "") .. managers.localization:to_upper_text("bm_menu_steam_item_quality", {
						quality = managers.localization:text(tweak_data.economy.qualities[cosmetic_quality].name_id)
					})

					table.insert(updated_texts[4].resource_color, tweak_data.economy.qualities[cosmetic_quality].color or tweak_data.screen_colors.text)
				end

				if cosmetic_bonus then
					local bonus = tweak_data.blackmarket.weapon_skins[slot_data.cosmetic_id] and tweak_data.blackmarket.weapon_skins[slot_data.cosmetic_id].bonus

					if bonus then
						local bonus_tweak = tweak_data.economy.bonuses[bonus]
						local bonus_value = bonus_tweak.exp_multiplier and bonus_tweak.exp_multiplier * 100 - 100 .. "%" or bonus_tweak.money_multiplier and bonus_tweak.money_multiplier * 100 - 100 .. "%"
						updated_texts[4].text = updated_texts[4].text .. ((cosmetic_quality or cosmetic_rarity) and "\n" or "") .. managers.localization:text("dialog_new_tradable_item_bonus", {
							bonus = managers.localization:text(bonus_tweak.name_id, {
								team_bonus = bonus_value
							})
						})
					end
				end
			end

			if slot_data.desc_id and slot_data.unlocked then
				updated_texts[4].text = updated_texts[4].text .. "\n" .. managers.localization:text(slot_data.desc_id)
			end

			if slot_data.global_value and slot_data.global_value ~= "normal" then
				updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"

				table.insert(updated_texts[4].resource_color, tweak_data.lootdrop.global_values[slot_data.global_value].color)
			end

			updated_texts[4].below_stats = true
		elseif identifier == self.identifiers.inventory_tradable then
			if slot_data.name ~= "empty" then
				updated_texts[1].text = managers.localization:to_upper_text("bm_menu_steam_item_name", {
					type = managers.localization:text("bm_menu_" .. slot_data.category),
					name = slot_data.name_localized
				})
				updated_texts[1].resource_color = tweak_data.screen_colors.text

				if slot_data.category == "weapon_skins" then
					updated_texts[1].text = ""
					local name_string = ""

					if slot_data.weapon_id then
						name_string = utf8.to_upper(managers.weapon_factory:get_weapon_name_by_weapon_id(slot_data.weapon_id)) .. " | "
					end

					name_string = name_string .. slot_data.name_localized
					local stat_bonus, team_bonus = nil

					if slot_data.cosmetic_quality then
						name_string = name_string .. ", " .. managers.localization:text(tweak_data.economy.qualities[slot_data.cosmetic_quality].name_id)
					end

					if slot_data.cosmetic_bonus then
						local bonus = tweak_data.blackmarket.weapon_skins[slot_data.cosmetic_id] and tweak_data.blackmarket.weapon_skins[slot_data.cosmetic_id].bonus

						if bonus then
							name_string = name_string .. ", " .. managers.localization:text("menu_bm_inventory_bonus")
						end
					end

					updated_texts[2].text = "##" .. name_string .. "##"

					if slot_data.cosmetic_rarity then
						updated_texts[2].resource_color = tweak_data.economy.rarities[slot_data.cosmetic_rarity].color or tweak_data.screen_colors.text
					end

					updated_texts[4].text, updated_texts[4].resource_color = InventoryDescription.create_description_item({
						category = "weapon_skins",
						instance_id = 0,
						entry = slot_data.name,
						quality = slot_data.cosmetic_quality,
						bonus = slot_data.cosmetic_bonus
					}, tweak_data.blackmarket.weapon_skins[slot_data.name], {
						default = tweak_data.screen_colors.text,
						mods = tweak_data.screen_colors.text
					}, true)
					updated_texts[4].below_stats = true
				elseif slot_data.category == "armor_skins" then
					updated_texts[1].text = "##" .. updated_texts[1].text .. "##"

					if slot_data.cosmetic_rarity then
						updated_texts[1].resource_color = tweak_data.economy.rarities[slot_data.cosmetic_rarity].color or tweak_data.screen_colors.text
					end

					updated_texts[2].text = managers.localization:text(slot_data.desc_id)
				elseif slot_data.safe_entry then
					local content_text, color_ranges = InventoryDescription.create_description_safe(slot_data.safe_entry, {}, true)
					updated_texts[2].text = content_text
					updated_texts[2].resource_color = color_ranges
				elseif slot_data.desc_id then
					updated_texts[2].text = managers.localization:text(slot_data.desc_id)
				end
			end
		elseif identifier == self.identifiers.custom then
			if self._data.custom_update_text_info then
				self._data.custom_update_text_info(slot_data, updated_texts, self)
			end
		elseif Application:production_build() then
			updated_texts[1].text = identifier:s()
		end

		if identifier == self.identifiers.armor then
			self._stats_panel:set_top(self._armor_info_panel:bottom() + 10)
		end

		if self._desc_mini_icons then
			for _, gui_object in pairs(self._desc_mini_icons) do
				self._panel:remove(gui_object[1])
			end
		end

		self._desc_mini_icons = {}
		local desc_mini_icons = self._slot_data.desc_mini_icons
		local info_box_panel = self._panel:child("info_box_panel")

		if desc_mini_icons and table.size(desc_mini_icons) > 0 then
			for _, mini_icon in pairs(desc_mini_icons) do
				local new_icon = self._panel:bitmap({
					layer = 1,
					texture = mini_icon.texture,
					x = info_box_panel:left() + 10 + mini_icon.right,
					w = mini_icon.w or 32,
					h = mini_icon.h or 32
				})

				table.insert(self._desc_mini_icons, {
					new_icon,
					2
				})
			end

			updated_texts[2].text = string.rep("     ", table.size(desc_mini_icons)) .. updated_texts[2].text
		end

		if not ignore_lock and slot_data.lock_texture and slot_data.lock_texture ~= true then
			local new_icon = self._panel:bitmap({
				h = 20,
				blend_mode = "add",
				w = 20,
				layer = 1,
				texture = slot_data.lock_texture,
				texture_rect = slot_data.lock_rect or nil,
				x = info_box_panel:left() + 10,
				color = self._info_texts[3]:color()
			})
			updated_texts[3].text = "     " .. updated_texts[3].text

			table.insert(self._desc_mini_icons, {
				new_icon,
				3
			})
		end

		if is_renaming_this and self._rename_info_text then
			local text = self._renaming_item.custom_name ~= "" and self._renaming_item.custom_name or "##" .. tostring(slot_data.raw_name_localized) .. "##"
			updated_texts[self._rename_info_text].text = text
			updated_texts[self._rename_info_text].resource_color = tweak_data.screen_colors.text:with_alpha(0.35)
		end

		for id, _ in ipairs(self._info_texts) do
			self:set_info_text(id, updated_texts[id].text, updated_texts[id].resource_color)
		end

		local _, _, _, th = self._info_texts[1]:text_rect()

		self._info_texts[1]:set_h(th)

		local y = self._info_texts[1]:bottom()
		local title_offset = y
		local bg = self._info_texts_bg[1]

		if alive(bg) then
			bg:set_shape(self._info_texts[1]:shape())
		end

		local below_y = nil

		for i = 2, #self._info_texts do
			local info_text = self._info_texts[i]

			info_text:set_font_size(small_font_size)
			info_text:set_w(self._info_texts_panel:w())

			_, _, _, th = info_text:text_rect()

			info_text:set_y(y)
			info_text:set_h(th)

			if updated_texts[i].below_stats then
				if slot_data.comparision_data and alive(self._stats_text_modslist) then
					info_text:set_world_y(below_y or self._stats_text_modslist:world_top())

					below_y = (below_y or info_text:world_y()) + th
				else
					info_text:set_top((below_y or info_text:top()) + 20)

					below_y = (below_y or info_text:top()) + th
				end
			end

			local scale = 1
			local attempts = 5
			local max_h = self._info_texts_panel:h() - info_text:top()

			if not updated_texts[i].below_stats and slot_data.comparision_data and alive(self._stats_panel) then
				max_h = self._stats_panel:world_top() - info_text:world_top()
			end

			if info_text:h() ~= 0 and max_h > 0 and max_h < info_text:h() then
				local font_size = info_text:font_size()
				local wanted_h = max_h

				while info_text:h() ~= 0 and not math.within(math.ceil(info_text:h()), wanted_h - 10, wanted_h) and attempts > 0 do
					scale = wanted_h / info_text:h()
					font_size = math.clamp(font_size * scale, 0, small_font_size)

					info_text:set_font_size(font_size)

					_, _, _, th = info_text:text_rect()

					info_text:set_h(th)

					attempts = attempts - 1
				end

				if info_text:h() ~= 0 and info_text:h() > self._info_texts_panel:h() - info_text:top() then
					print("[BlackMarketGui] Info text dynamic font sizer failed")

					scale = (self._info_texts_panel:h() - info_text:top()) / info_text:h()

					info_text:set_font_size(font_size * scale)

					_, _, _, th = info_text:text_rect()

					info_text:set_h(th)
				end
			end

			local bg = self._info_texts_bg[i]

			if alive(bg) then
				bg:set_shape(info_text:shape())
			end

			y = info_text:bottom()
		end

		for _, desc_mini_icon in ipairs(self._desc_mini_icons) do
			desc_mini_icon[1]:set_y(title_offset)
			desc_mini_icon[1]:set_world_top(self._info_texts[desc_mini_icon[2]]:world_top() + 1)
		end

		if is_renaming_this and self._rename_info_text and self._rename_caret then
			local info_text = self._info_texts[self._rename_info_text]
			local x, y, w, h = info_text:text_rect()

			if self._renaming_item.custom_name == "" then
				w = 0
			end

			self._rename_caret:set_w(2)
			self._rename_caret:set_h(h)
			self._rename_caret:set_world_position(x + w, y)
		end
	end


end
