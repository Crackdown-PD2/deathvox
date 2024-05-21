---------------------------
-- Options Menu Creation --
---------------------------

--creates empty menu entries for the main menu and the overhauls submenu, to be populated with options later
local menu_id = deathvox.blt_menu_id
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_deathvox", function(menu_manager, nodes)
	MenuHelper:NewMenu( menu_id )
	--MenuHelper:NewMenu("deathvox_menu_overhauls")
end)

--populates the menu with data from the json file; this data should have a menu id matching one you created in the above MenuManagerSetupCustomMenus hook
Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus_deathvox", function(menu_manager, nodes)
	--MenuHelper:LoadFromJsonFile(deathvox.ModPath .. "menu/menu_overhauls.json", deathvox, deathvox.Settings)

	local overhaul_is_installed = not not _G.deathvox_overhaul
	MenuHelper:AddToggle({
		id = "deathvox_toggle_totalcd",
		title = "deathvox_toggle_totalcd_title",
		desc = "deathvox_toggle_totalcd_desc",
		callback = "callback_deathvox_toggle_totalcd",
		value = deathvox:IsTotalCrackdownEnabled(),
		disabled = not overhaul_is_installed,
		menu_id = menu_id, -- "deathvox_menu_overhauls",
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
	
	MenuCallbackHandler.callback_deathvox_toggle_totalcd = function(self,item) --on keypress
		local enabled = item:value() == "on"
		local currently_enabled = deathvox:GetSetting("useTotalCDOverhaul")
		if enabled ~= currently_enabled then
			
			local function confirm_changes()
				-- apply settings change,
				-- then force close game
				
				deathvox:ChangeSetting("useTotalCDOverhaul",enabled)
				deathvox:Save()
				
				MenuCallbackHandler:_dialog_quit_yes()
			end
			
			local function cancel_changes()
				-- revert menu checkbox state
				item:set_value(currently_enabled and "on" or "off")
			end
			
			-- show "restart required" dialog
			QuickMenu:new(
				managers.localization:text("deathvox_dialog_tcd_restart_required_title"),
				managers.localization:text("deathvox_dialog_tcd_restart_required_desc"),
				{
					{
						text = managers.localization:text("dialog_yes"),
						callback = confirm_changes
					},
					{
						text = managers.localization:text("dialog_no"),
						is_selected = true,
						is_cancel_button = true,
						callback = cancel_changes
					}
				},
				true
			)
		end
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


-- resume regular changes below


function MenuCallbackHandler:accept_skirmish_contract(item)
	local node = item:parameters().gui_node.node

	managers.menu:active_menu().logic:navigate_back(true)
	managers.menu:active_menu().logic:navigate_back(true)

	local job_id = (node:parameters().menu_component_data or {}).job_id
	local job_data = {
		difficulty = "normal",
		customize_contract = true,
		job_id = job_id or managers.skirmish:random_skirmish_job_id(),
		difficulty_id = tweak_data:difficulty_to_index("normal")
	}

	managers.job:on_buy_job(job_data.job_id, job_data.difficulty_id or 2)

	if Global.game_settings.single_player then
		MenuCallbackHandler:start_single_player_job(job_data)
	else
		MenuCallbackHandler:start_job(job_data)
	end
end

function MenuCallbackHandler:accept_skirmish_weekly_contract(item, node)
	managers.menu:active_menu().logic:navigate_back(true)
	managers.menu:active_menu().logic:navigate_back(true)

	local weekly_skirmish = managers.skirmish:active_weekly()
	local job_data = {
		difficulty = "normal",
		weekly_skirmish = true,
		job_id = weekly_skirmish.id
	}

	if Global.game_settings.single_player then
		MenuCallbackHandler:start_single_player_job(job_data)
	else
		MenuCallbackHandler:start_job(job_data)
	end
end

function MenuCallbackHandler:staticrecoil_clbk(item)
	local on = item:value() == "on" or false

	managers.user:set_setting("staticrecoil", on)
end

function MenuCallbackHandler:holdtofire_clbk(item)
	local on = item:value() == "on" or false

	managers.user:set_setting("holdtofire", on)
end

Hooks:Add("MenuManagerBuildCustomMenus", "HH_CONTROLS", function(menu_manager, nodes)
	local controls_node = nodes.controls
	
	local params = {
		name = "staticrecoil",
		text_id = "cdmenu_staticrecoil",
		help_id = "cdmenu_staticrecoil_help",
		callback = "staticrecoil_clbk",
		filter = true,
		enabled = false,
		localize = true,
		localize_help = true
	}
	local data_node = {
		{
			w = "24",
			y = "0",
			h = "24",
			s_y = "24",
			value = "on",
			s_w = "24",
			s_h = "24",
			s_x = "24",
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			x = "24",
			s_icon = "guis/textures/menu_tickbox"
		},
		{
			w = "24",
			y = "0",
			h = "24",
			s_y = "24",
			value = "off",
			s_w = "24",
			s_h = "24",
			s_x = "0",
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			x = "0",
			s_icon = "guis/textures/menu_tickbox"
		},
		type = "CoreMenuItemToggle.ItemToggle"
	}
	
	local recoil_item = controls_node:create_item(data_node, params)
	
	local position = 0
	
	for index, item in pairs(controls_node._items) do
		if item:name() == "toggle_hold_to_duck" then
			position = index + 1
			break
		end
	end
	
	controls_node:insert_item(recoil_item, position)
	
	local params = {
		name = "holdtofire",
		text_id = "cdmenu_holdtofire",
		help_id = "cdmenu_holdtofire_help",
		callback = "holdtofire_clbk",
		filter = true,
		enabled = false,
		localize = true,
		localize_help = true
	}
	local data_node = {
		{
			w = "24",
			y = "0",
			h = "24",
			s_y = "24",
			value = "on",
			s_w = "24",
			s_h = "24",
			s_x = "24",
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			x = "24",
			s_icon = "guis/textures/menu_tickbox"
		},
		{
			w = "24",
			y = "0",
			h = "24",
			s_y = "24",
			value = "off",
			s_w = "24",
			s_h = "24",
			s_x = "0",
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			x = "0",
			s_icon = "guis/textures/menu_tickbox"
		},
		type = "CoreMenuItemToggle.ItemToggle"
	}
	
	local fire_item = controls_node:create_item(data_node, params)
	
	local position = 0
	
	for index, item in pairs(controls_node._items) do
		if item:name() == "staticrecoil" then
			position = index + 1
			break
		end
	end
	
	controls_node:insert_item(fire_item, position)
end)

Hooks:PostHook(MenuOptionInitiator, "modify_controls", "CD_modify_controls", function(self, node)
	local option_value = "off"
	local recoil_item = node:item("staticrecoil")
	local holdtofire_item = node:item("holdtofire")
	
	if jump_item then
		if managers.user:get_setting("hold_to_jump") then
			option_value = "on"
		end

		jump_item:set_value(option_value)
	end
	
	option_value = "off"
	
	if recoil_item then
		if managers.user:get_setting("staticrecoil") then
			option_value = "on"
		end
		
		recoil_item:set_value(option_value)
	end
	
	option_value = "off"
	
	if holdtofire_item then
		if managers.user:get_setting("holdtofire") then
			option_value = "on"
		end
		
		holdtofire_item:set_value(option_value)
	end
end)