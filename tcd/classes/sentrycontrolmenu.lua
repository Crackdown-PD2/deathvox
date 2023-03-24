_G.SentryControlMenu = {}

--SentryControlMenu._path = deathvox.ModPath or deathvox:GetPath()
SentryControlMenu._save_path = SavePath .. "SentryControlMenuSettings.txt"

SentryControlMenu.ICONS_ATLAS_NAME = "guis/textures/pd2/hud_sentry_radial_icons_atlas"
SentryControlMenu.ICONS_ATLAS_LOOKUP = {
	mode_manual_on = {
		0 * 64,
		0 * 64,
		64,
		64
	},
	ammo_standard = {
		1 * 64,
		0 * 64,
		64,
		64
	},
	mode_manual_off = {
		2 * 64,
		0 * 64,
		64,
		64
	},
	mode_overwatch = {
		0 * 64,
		1 * 64,
		64,
		64
	},
	retrieve = {
		1 * 64,
		1 * 64,
		64,
		64
	},
	mode_standard = {
		2 * 64,
		1 * 64,
		64,
		64
	},
	ammo_taser = {
		0 * 64,
		2 * 64,
		64,
		64
	},
	ammo_ap = {
		1 * 64,
		2 * 64,
		64,
		64
	}
}

SentryControlMenu.settings = {
	menu_behavior = 1,
	teammate_laser_alpha = 0.05,
	button_hold_threshold = 0.25,
	keybind_select = "j", --deprecated
	keybind_deselect = "k", --deprecated
	keybind_menu = "l", --deprecated
	menu_click_on_release = true --deprecated
}

SentryControlMenu.tweakdata = {
	MAX_PICK_SENTRY_ANGLE = 30,
	MAX_PICK_SENTRY_DISTANCE = 100000,
	OVERWATCH_DETECTION_RANGE = 100000,
	ws_h = 1000,
	ws_w = 1000,
	unselected_alpha = 0.25,
	selected_alpha = 1,
	bitmap_rotation_speed = 45, --degrees/sec
	_SYNC_AIM_INTERVAL = 0.1, --amount of seconds between each sync message to other clients, for sentry aim direction. small numbers look better and perform worse
	color_aimed_at = Color("FFD700"),
	color_unselected = Color(1,1,1),
	color_mode_manual = Color(1,0,0),
	color_mode_overwatch = Color(1,1,0)
}

SentryControlMenu._selections = {} --deprecated

SentryControlMenu.button_held_state = nil
SentryControlMenu._targeted_sentry = nil

function SentryControlMenu.angle_from(a,b,c,d) -- converts to angle with ranges (-180 , 180); for result range 0-360, do +180 to result
--mvector3.angle() is a big fat meanie zucchini;
	a = a or "nil"
	b = b or "nil"
	c = c or "nil"
	d = d or "nil"
	local function do_angle(x1,y1,x2,y2)
		local angle = 0
		local x = x2 - x1 --x diff
		local y = y2 - y1 --y diff
		if x ~= 0 then 
			angle = math.atan(y / x) % 180
			if y == 0 then 
				if x > 0 then 
					angle = 180 --right
				else
					angle = 0 --left 
				end
			elseif y > 0 then 
				angle = angle - 180
			end
		else
			if y > 0 then
				angle = 270 --up
			else
				angle = 90 --down
			end
		end
		
		return angle
	end
	local vectype = type(Vector3())
	if (type(a) == vectype) and (type(b) == vectype) then  --vector pos diff
		return do_angle(a.x,a.y,b.x,b.y)
	elseif (type(a) == "number") and (type(b) == "number") and (type(c) == "number") and (type(d) == "number") then --manual x/y pos diff
		return do_angle(a,b,c,d)
	else
		log("ERROR: angle_from(" .. table.concat({tostring(a),tostring(b),tostring(c),tostring(d)},",") .. ") failed - bad/mismatched arg types")
		return
	end
end

function SentryControlMenu._button_held(key)
	if HoldTheKey then
		return HoldTheKey:Key_Held(key)
	end

	if not (managers and managers.hud) or managers.hud._chat_focus then
		return false
	end
	
	key = tostring(key)
	if key:find("mouse ") then 
		if not key:find("wheel") then 
			key = key:sub(7)
		end
		return Input:mouse():down(Idstring(key))
	else
		return Input:keyboard():down(Idstring(key))
	end
end

function SentryControlMenu:SetTeammateSentryLaserAlpha(value)
	self.settings.teammate_laser_alpha = tonumber(value)
end

function SentryControlMenu:GetTeammateSentryLaserAlpha()
	return self.settings.teammate_laser_alpha
end

function SentryControlMenu:GetMenuButtonHoldThreshold()
 --if the button is held for longer than this amount of seconds, next button release will hide the menu 
	return self.settings.button_hold_threshold
end

function SentryControlMenu:SetMenuButtonHoldThreshold(value)
	self.settings.button_hold_threshold = tonumber(value)
end

function SentryControlMenu:_create_panel(unit) --deprecated
end

function SentryControlMenu:_remove_ws(ws) --deprecated
end
 
function SentryControlMenu:SetSentryMode(unit,mode)
	if unit and alive(unit) then 
	
		if unit:weapon():_get_sentry_firemode() == mode then 
			mode = "normal"
		end
		
		unit:weapon():_set_sentry_firemode(mode,true)
		if unit:network() then 
			unit:network():send("sync_player_movement_state",mode,1,"")
		end
		self:RefreshMenu(unit)
	end
end

function SentryControlMenu:SetSentryAmmo(unit,ammo_type)
	
	if unit and alive(unit) then 
		
		unit:weapon():_set_ammo_type(ammo_type,true)
		if unit:network() then 
			unit:network():send("sync_player_movement_state",ammo_type,2,"")
		end
		self:RefreshMenu(unit)
	end
end

function SentryControlMenu:SelectSentryByUnit(unit)
	if unit and alive(unit) then 
		self.selected_sentry = unit
	end
end

function SentryControlMenu:DeselectSentryByUnit()
	if self.selected_sentry == unit then 
		self.selected_sentry = nil
	end
end

function SentryControlMenu:ShowMenu(unit)
	if self.action_radial then 
		self:RefreshMenu(unit)
		self.action_radial:Show(
--			self:GetRadialOptions(unit) --it doesn't currently work like this but it should
		)
	end
end

function SentryControlMenu:HideMenu()
	if self.action_radial then 
		self.action_radial:Hide()
	end
end

function SentryControlMenu:RefreshMenu(unit) --sets the visual toggle state of various ammo types based on the selected sentry's options
	if alive(unit) then 
		local sentryweapon = unit:weapon()
		local mode = sentryweapon:_get_sentry_firemode()
		local ammo_type = sentryweapon:_get_ammo_type()
		
		local items = self.action_radial._items
		local color_on = Color.white
		local color_off = Color(0.3,0.3,0.3)
		items[1]._icon:set_color(ammo_type == "ap" and color_on or color_off)
		items[2]._icon:set_color(ammo_type == "taser" and color_on or color_off)
		items[3]._icon:set_color(mode == "overwatch" and color_on or color_off)
		items[4]._icon:set_color(mode == "manual" and color_on or color_off)
--		items[5]._body:set_visible(false)
		items[6]._icon:set_color(ammo_type == "basic" and color_on or color_off)
	end
end

function SentryControlMenu:IsMenuActive()
	return self.action_radial and self.action_radial:active()
end

function SentryControlMenu:SelectAmmo(ammo,selected_unit)
	if ammo then 
		if selected_unit then 
			self:SetSentryAmmo(selected_unit,ammo)
		else
			self:SetSentryAmmo(self.selected_sentry,ammo)
		end
	end
end

function SentryControlMenu:SelectMode(mode,selected_unit)
	if mode then 
		if selected_unit then 
			self:SetSentryMode(selected_unit,mode)
		else
			self:SetSentryMode(self.selected_sentry,mode)
		end
	end
end

function SentryControlMenu:SetActionMenu(menu)
	self.action_radial = menu or self.action_radial

	for k,v in pairs(self.action_radial._items) do 
--		v._body:set_image("guis/textures/pd2/radial_menu_assets/rmm_selector")
		v._body:hide()
	end
	menu._selector:set_image("guis/textures/pd2/radial_menu_assets/rmm_selector")
--	menu._selector:set_color(Color.black)
	menu._selector:set_alpha(0.9)
	menu._bg:set_image("guis/textures/pd2/radial_menu_assets/rmm_bg")
	menu._bg:set_color(Color.black)
	menu._bg:set_alpha(0.66)
	Hooks:Add("radialmenu_released_" .. self.action_radial:get_name(),"tcdso_menu_closed",function(num)
		--not required
	end)
	
	
	
	
	menu.on_mouseover_item = function(self,index,...)
		local item = self:get_item(index)
		if not item then 
			self._selected = false
			return 
		end
		
		if index ~= self._selected then 
			local old_item = self:get_item(self._selected)
			
			local function animate_flare(o,w1,h1,w2,h2,x,y,duration)
				over(duration,function(progress)
					local progsq = progress * progress
					local dw = w2 - w1
					local dh = h2 - h1
					o:set_size(w1 + (dw * progsq),h1 + (dh * progsq))
					o:set_center(x,y)
				end)
			end
			
			item._icon:stop()
			item._icon:animate(animate_flare,item._icon:w(),item._icon:h(),item.icon.w * 1.25,item.icon.h * 1.25,item.icon.x,item.icon.y,0.25)
			
			if old_item then
				local icon_data = old_item.icon
				old_item._icon:animate(animate_flare,old_item._icon:w(),old_item._icon:h(),icon_data.w,icon_data.h,old_item.icon.x,old_item.icon.y,0.33)
			end
			
--			self._animate_in = item._panel:animate(animate_flare,false) --must be called from a hud panel
			if old_item then 
--				self._animate_out = old_item._panel:animate(animate_flare,true)
			end
		end
		
			--[[
			local function animate_flare(o,down)
				local text_panel = o._text_panel
				local font_size = o.text_panel.font_size --this is not a typo, this is the default font size
				local final_size = font_size * (down and 1 or 1.25)

				local rate = down and 0.95 or 1.05
				
				repeat
					local s = math[down and "max" or "min"](text_panel:font_size() * rate,final_size)
					
					text_panel:set_font_size(s)
					
					coroutine.yield()
				until math.abs(text_panel:font_size() - final_size) <= 0.01
			end--]]
		
		return RadialMouseMenu.on_mouseover_item(self,index,...)
	end

end
	
function SentryControlMenu:PickupSentry(unit)
	unit = unit or self.selected_sentry
	if alive(unit) then 
		local sentrybase = unit:base()
		if Network:is_server() then
			SentryGunBase.on_picked_up(sentrybase:get_type(), unit:weapon():ammo_ratio(), unit:id())
			sentrybase:remove()
		else
			managers.network:session():send_to_host("picked_up_sentry_gun", unit)
		end
	end
end

function SentryControlMenu:GetIconRect(name)
	return self.ICONS_ATLAS_LOOKUP[name]
end

Hooks:Add("BaseNetworkSessionOnLoadComplete","tcdso_sentry_onbaseloadcomplete",function()
	if not deathvox:IsTotalCrackdownEnabled() then return end
	
	RadialMouseMenu:new({
		name = managers.localization:text("tcdso_menu_title"),
		radius = 200,
		deadzone = 40,
		items = {
			{
				text = managers.localization:text("sentry_ammo_ap"),
				icon = {
					texture = SentryControlMenu.ICONS_ATLAS_NAME,
					texture_rect = SentryControlMenu:GetIconRect("ammo_ap"),
					layer = 3,
					w = 16,
					h = 16,
					alpha = 0.7,
					color = Color.white
				},
				show_text = true,
				stay_open = false,
				callback =  callback(SentryControlMenu,SentryControlMenu,"SelectAmmo","ap")
			},
			{
				text = managers.localization:text("sentry_ammo_taser"),
				icon = {
					texture = SentryControlMenu.ICONS_ATLAS_NAME,
					texture_rect = SentryControlMenu:GetIconRect("ammo_taser"),
					layer = 3,
					w = 16,
					h = 16,
					alpha = 0.7,
					color = Color.white
				},
				show_text = true,
				stay_open = false,
				callback = callback(SentryControlMenu,SentryControlMenu,"SelectAmmo","taser")
			},
			{
				text = managers.localization:text("sentry_mode_overwatch"),
				icon = {
					texture = SentryControlMenu.ICONS_ATLAS_NAME,
					texture_rect = SentryControlMenu:GetIconRect("mode_overwatch"),
					layer = 3,
					w = 16,
					h = 16,
					alpha = 0.7,
					color = Color.white
				},
				show_text = true,
				stay_open = false,
				callback =  callback(SentryControlMenu,SentryControlMenu,"SelectMode","overwatch")
			},
			{
				text = managers.localization:text("sentry_mode_manual"),
				icon = {
					texture = SentryControlMenu.ICONS_ATLAS_NAME,
					texture_rect = SentryControlMenu:GetIconRect("mode_manual_on"),
					layer = 3,
					w = 16,
					h = 16,
					alpha = 0.7,
					color = Color.white
				},
				show_text = true,
				stay_open = false,
				callback =  callback(SentryControlMenu,SentryControlMenu,"SelectMode","manual")
			},
			{
				text = managers.localization:text("sentry_retrieve"),
				icon = {
					texture = SentryControlMenu.ICONS_ATLAS_NAME,
					texture_rect = SentryControlMenu:GetIconRect("retrieve"),
					layer = 3,
					w = 16,
					h = 16,
					alpha = 0.7,
					color = Color.red
				},
				show_text = true,
				stay_open = false,
				callback =  callback(SentryControlMenu,SentryControlMenu,"PickupSentry")
			},
			{
				text = managers.localization:text("sentry_ammo_standard"),
				icon = {
					texture = SentryControlMenu.ICONS_ATLAS_NAME,
					texture_rect = SentryControlMenu:GetIconRect("ammo_standard"),
					layer = 3,
					w = 16,
					h = 16,
					alpha = 0.7,
					color = Color.white
				},
				show_text = true,
				stay_open = false,
				callback =  callback(SentryControlMenu,SentryControlMenu,"SelectAmmo","basic")
			}
		}
	},callback(SentryControlMenu,SentryControlMenu,"SetActionMenu"))
end)

function SentryControlMenu:Load()
	local file = io.open(self._save_path, "r")
	if (file) then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
		end
	else
		self:Save()
	end
end

function SentryControlMenu:Save()
	local file = io.open(self._save_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_tcdso", function(menu_manager)

	MenuCallbackHandler.callback_tcdso_set_open_menu_behavior = function(self,item)
		SentryControlMenu:SetMenuBehavior(item:value())
		SentryControlMenu:Save()
	end
	MenuCallbackHandler.callback_tcdso_select_sentry = function(self)
		--done by held key detection in Update()
	end
	MenuCallbackHandler.callback_tcdso_deselect_sentry = function(self)
		--done by held key detection in Update()
	end
	MenuCallbackHandler.callback_tcdso_open_menu = function(self)
		if SentryControlMenu:GetMenuBehavior() == 2 then 
			if SentryControlMenu.action_radial then
				SentryControlMenu.action_radial:Toggle()
			end
		end
		--alternatively, can be done by held key detection in Update()
	end
	MenuCallbackHandler.callback_tdso_option_refresh_keybinds = function(self)
		SentryControlMenu:RefreshKeybinds()
		SentryControlMenu:Save()
	end
	MenuCallbackHandler.callback_tcdso_mouseclick_on_menu_close = function(self,item)
		SentryControlMenu:SetMouseClickOnMenuClose(item:value() == "on")
		SentryControlMenu:Save()
	end
	MenuCallbackHandler.callback_tcdso_set_teammate_alpha = function(self,item)
		SentryControlMenu:SetTeammateSentryLaserAlpha(item:value())
		SentryControlMenu:Save()
	end
	MenuCallbackHandler.callback_tcdso_set_hold_threshold = function(self,item)
		SentryControlMenu:SetMenuButtonHoldThreshold(item:value())
		SentryControlMenu:Save()
	end
	MenuCallbackHandler.callback_tcdso_close = function(this)
--		SentryControlMenu:Save()
	end
	SentryControlMenu:Load()
--	MenuHelper:LoadFromJsonFile(SentryControlMenu._path .. "menu/menu_sentry_control.txt", SentryControlMenu, SentryControlMenu.settings)
	
end)
