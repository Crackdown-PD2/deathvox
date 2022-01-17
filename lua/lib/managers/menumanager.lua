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