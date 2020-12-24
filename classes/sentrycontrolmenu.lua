_G.SentryControlMenu = {}

SentryControlMenu._path = deathvox.ModPath or deathvox:GetPath()
SentryControlMenu._save_path = SavePath .. "SentryControlMenuSettings.txt"

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

SentryControlMenu._selections = {}
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

--most of this is deprecated because of the change to interaction behavior precluding the need for the multiselection capability
--but not all of it!

function SentryControlMenu:MenuShouldClickOnRelease() --deprecated
	return self.settings.menu_click_on_release
end

function SentryControlMenu:SetMouseClickOnMenuClose(value) --deprecated
	self.settings.menu_click_on_release = value
end

function SentryControlMenu:SetMenuBehavior(value) --deprecated
	self.settings.menu_behavior = tonumber(value)
end

function SentryControlMenu:GetMenuBehavior() --deprecated
	return self.settings.menu_behavior
end

function SentryControlMenu:SetTeammateSentryLaserAlpha(value)
	self.settings.teammate_laser_alpha = tonumber(value)
end


function SentryControlMenu:GetTeammateSentryLaserAlpha()
	return self.settings.teammate_laser_alpha
end

function SentryControlMenu:GetSelectSentryKeybind() --deprecated
	return self.settings.keybind_select
end

function SentryControlMenu:GetDeselectSentryKeybind() --deprecated
	return self.settings.keybind_deselect
end

function SentryControlMenu:GetOpenMenuKeybind() --deprecated
	return self.settings.keybind_menu
end

function SentryControlMenu:GetMenuButtonHoldThreshold()
 --if the button is held for longer than this amount of seconds, next button release will hide the menu 
	return self.settings.button_hold_threshold
end

function SentryControlMenu:SetMenuButtonHoldThreshold(value)
	self.settings.button_hold_threshold = tonumber(value)
end

function SentryControlMenu:SetSelectSentryKeybind(key) --deprecated
	self.settings.keybind_select = key
end

function SentryControlMenu:SetDeselectSentryKeybind(key) --deprecated
	self.settings.keybind_deselect = key
end

function SentryControlMenu:SetOpenMenuKeybind(key) --deprecated
	self.settings.keybind_menu = key
end

function SentryControlMenu:RefreshKeybinds() --deprecated
	self:SetSelectSentryKeybind(self:GetBLTKeybind("tcdso_select_sentry") or "")
	self:SetDeselectSentryKeybind(self:GetBLTKeybind("tcdso_deselect_sentry") or "")
	self:SetOpenMenuKeybind(self:GetBLTKeybind("tcdso_open_menu") or "")
end

function SentryControlMenu:GetBLTKeybind(id,...) --deprecated
	--method copied from holdthekey v1.35; if htk is present, use this newer-or-same version's method. else, use the version i copied
	if HoldTheKey and HoldTheKey.Get_BLT_Keybind then 
		return HoldTheKey:Get_BLT_Keybind(id,...)
	else
		for k,v in pairs(BLT.Keybinds._keybinds) do
			if type(v) == "table" then
				if v["_id"] == id then
					if v["_key"] and v["_key"]["pc"] then
						return tostring(v["_key"]["pc"])
					else
						return
					end
				end
			end
		end
		
		if BLT.Keybinds._potential_keybinds then
			for k,v in pairs(BLT.Keybinds._potential_keybinds) do
				if type(v) == "table" then
					if v["id"] == id then
						if v["pc"] then 
							return tostring(v["pc"])
						else
							return
						end
					end
				end
			end
		end
	end
end

function SentryControlMenu:GetMaxPickDistance() --deprecated
	return self.tweakdata.MAX_PICK_SENTRY_DISTANCE
end

function SentryControlMenu:GetMaxPickAngle() --deprecated
	return self.tweakdata.MAX_PICK_SENTRY_ANGLE
end

function SentryControlMenu:_create_panel(unit)
	local width = self.tweakdata.ws_w
	local height = self.tweakdata.ws_h
	local pos = unit:position()
	local offset_vector = Vector3(0,0,0) + pos
	local right_vector = Vector3(0, -width, 0)
	local bottom_vector = Vector3(0, 0, -height)
	
	if self._gui then 
		local new_ws = self._gui:create_world_workspace(width,height,offset_vector,right_vector,bottom_vector)
		return new_ws
	end
end

function SentryControlMenu:_remove_ws(ws)
	if ws then 
		self._gui:destroy_workspace(ws)
	end
end

function SentryControlMenu:Update(t,dt) --deprecated
	if managers.player then
		local player = managers.player:local_player()
		if player then 
		
		
		
			local action_radial = self.action_radial
			if action_radial then 
				if self._button_held(self:GetOpenMenuKeybind()) then 
					if not action_radial:active() then 
						action_radial:Show()
					end
				elseif action_radial:active() then --on released
					if self:MenuShouldClickOnRelease() then
						action_radial:mouse_clicked(action_radial._base,Idstring("0"),0,0)
					end
					action_radial:Hide()
				end
			end
			
			
			
		
			local head_pos = player:movement():m_head_pos()
			local head_rot = player:movement():m_head_rot()
			local aim_direction = head_rot:yaw()
			local best_pick = {
				unit = nil,
				distance = nil,
				angle = 360
			}
			local deselect_held = self._button_held(self:GetDeselectSentryKeybind())
			local select_held = self._button_held(self:GetSelectSentryKeybind())
			local MAX_PICK_ANGLE = self:GetMaxPickAngle()

			local all_sentries = World:find_units_quick("sphere",head_pos,self:GetMaxPickDistance(),managers.slot:get_mask("sentry_gun"))
			for _,unit in pairs(all_sentries) do 
				if unit and alive(unit) and unit:character_damage() and not (unit:character_damage():dead() or unit:movement()._switched_off) then 
					if unit:base():is_owner() then 
						if unit:base()._bitmap then 
							unit:base()._bitmap:set_color(self.tweakdata.color_unselected)
							if unit == self._targeted_sentry or self._selections[tostring(unit:key())] then 
								unit:base()._bitmap:show()
							else
								unit:base()._bitmap:set_alpha(self.tweakdata.unselected_alpha)
								unit:base()._bitmap:hide()
							end
						end
						local angle = math.abs(mvector3.angle(unit:position() - head_pos,head_rot:y()))
						if angle < MAX_PICK_ANGLE then 
							if angle < best_pick.angle then 
								best_pick = {
									unit = unit,
									distance = distance,
									angle = angle
								}
							end					
						end
					end
				end
			end
			
			if best_pick.unit and alive(best_pick.unit) then 
				local base = best_pick.unit:base()
				if base then 
					self._targeted_sentry = best_pick.unit
					
					if deselect_held then 
						self:DeselectSentryByUnit(best_pick.unit)
					elseif select_held then 
						self:SelectSentryByUnit(best_pick.unit)
					end
					
					if base._bitmap then 
						base._bitmap:show()
						base._bitmap:set_color(self.tweakdata.color_aimed_at)
						
						if self._selections[tostring(best_pick.unit:key())] then
							base._bitmap:set_alpha(self.tweakdata.selected_alpha)
						else
							base._bitmap:set_alpha(self.tweakdata.unselected_alpha)
						end
					end
				end
			end
		end
--[[		
if selection and alive(selection) and (selection ~= self.SelectedSentry) then 
	selection:base()._bitmap:set_color(Color.red)
	if alive(self.SelectedSentry) then 
		self.SelectedSentry:base()._bitmap:set_color(Color.white)
		self.SelectedSentry = selection
	end
end
--]]
	end
end

function SentryControlMenu:GetCastSelection() --deprecated
	local player = managers.player:local_player()
	if player then 
		local head_pos = player:movement():m_head_pos()
		local head_rot = player:movement():m_head_rot()
		local aim_direction = head_rot:yaw()

		local best_pick = {
			unit = nil,
			distance = nil,
			angle = 360
		}

		local all_sentries = World:find_units_quick("sphere",head_pos,self:GetMaxPickDistance(),managers.slot:get_mask("sentry_gun"))
		for _,unit in pairs(all_sentries) do 
			if unit and alive(unit) and unit:character_damage() and not (unit:character_damage():dead() or unit:movement()._switched_off) then 
				if unit:base()._owner then 
					local angle = math.abs(mvector3.angle(unit:position() - head_pos,head_rot:y()))
--					if unit:base()._text then 
--						unit:base()._text:set_text(string.format("%.02f",angle))
--					end
					if angle < self:GetMaxPickAngle() then 
						if angle < best_pick.angle then 
							best_pick = {
								unit = unit,
								distance = distance,
								angle = angle
							}
						end					
					end
				end
			end
		end
		
		if best_pick.unit and alive(best_pick.unit) then 
			return best_pick.unit
		end
	end
end

function SentryControlMenu:SetSentryMode(unit,mode)
	if unit and alive(unit) then 
		unit:weapon():_set_sentry_firemode(mode,true)
		if unit:network() then 
			unit:network():send("sync_player_movement_state",mode,1,"")
		end
	end
--	unit:weapon()._firemode = mode
end

function SentryControlMenu:SetSentryAmmo(unit,ammo_type)
	if unit and alive(unit) then 
	
		if unit:weapon()._ammo_type == ammo_type then 
			--when selecting the same ammo type as current, selects "basic" ammo
			ammo_type = "basic"
		end
		
		unit:weapon():_set_ammo_type(ammo_type,true)
		if unit:network() then 
			unit:network():send("sync_player_movement_state",ammo_type,2,"")
		end
	end
--	unit:weapon()._ammo_type = ammo_type
end

function SentryControlMenu:SelectSentryByUnit(unit)
	if unit and alive(unit) then 
		self._selections = {
			[tostring(unit:key())] = {unit = unit}
		}
	--[[ --multiselect
		if not self._selections[tostring(unit:key())] then 
			self._selections[tostring(unit:key())] = {
				unit = unit
			}
		end
	--]]
	end
end

function SentryControlMenu:DeselectSentryByUnit(unit,key)
--todo peform remove_cb if extant?
	if key and self._selections[tostring(key)] then 
		self._selections[tostring(key)] = nil
	elseif unit and alive(unit) then 
		self._selections[tostring(unit:key())] = nil
	end
end

function SentryControlMenu:SelectAmmo(ammo,selected_unit)
	if ammo then 
		if selected_unit then 
			self:SetSentryAmmo(selected_unit,ammo)
		else
			for _,data in pairs(self._selections) do 
				self:SetSentryAmmo(data.unit,ammo)
			end
		end
	end
end

function SentryControlMenu:SelectMode(mode,selected_unit)
	if mode then 
		if selected_unit then 
			self:SetSentryMode(selected_unit,mode)
		else
			for _,data in pairs(self._selections) do 
				self:SetSentryMode(data.unit,mode)
			end
		end
	end
end

function SentryControlMenu:SetActionMenu(menu)
--	if not managers.hud then 
--		return
--	end
	self.action_radial = menu or self.action_radial

	Hooks:Add("radialmenu_released_" .. self.action_radial:get_name(),"tcdso_menu_closed",function(num)
		
	end)
	
	
--	managers.hud:add_updator("SentryControlMenu_Update",callback(self,self,"Update")) --no longer needed
--	self._gui = World:newgui()
end
	

Hooks:Add("BaseNetworkSessionOnLoadComplete","tcdso_sentry_onbaseloadcomplete",function()
	if not deathvox:IsTotalCrackdownEnabled() then return end
	
--	managers.localization:add_localized_strings({hud_interact_sentry_gun_switch_fire_mode = string.gsub(managers.localization:text("deathvox_total_hud_interact_sentry_gun_switch_fire_mode"),"BTN_INTERACT","$BTN_INTERACT")})
--	"deathvox_total_hud_interact_sentry_gun_switch_fire_mode" : "Press BTN_INTERACT to change Sentry Mode.",	
	RadialMouseMenu:new({
		name = managers.localization:text("tcdso_menu_title"),
		radius = 200,
		deadzone = 50,
		items = {
			{
				text = managers.localization:text("sentry_ammo_he"),
				icon = {
					texture = tweak_data.hud_icons.pd2_fire.texture,
					texture_rect = tweak_data.hud_icons.pd2_fire.texture_rect,
					layer = 3,
					w = 16,
					h = 16,
					alpha = 0.7,
					color = Color(1,0.5,0) --orange
				},
				show_text = true,
				stay_open = false,
				callback =  callback(SentryControlMenu,SentryControlMenu,"SelectAmmo","he")
			},
			{
				text = managers.localization:text("sentry_ammo_ap"),
				icon = {
					texture = tweak_data.hud_icons.r870_shotgun.texture,
					texture_rect = tweak_data.hud_icons.r870_shotgun.texture_rect,
					layer = 3,
					w = 16,
					h = 16,
					alpha = 0.7,
					color = Color(0.5,1,0) --green
				},
				show_text = true,
				stay_open = false,
				callback =  callback(SentryControlMenu,SentryControlMenu,"SelectAmmo","ap")
			},
			{
				text = managers.localization:text("sentry_mode_standard"),
				icon = {
					texture = tweak_data.hud_icons.wp_sentry.texture,
					texture_rect = tweak_data.hud_icons.wp_sentry.texture_rect,
					layer = 3,
					w = 16,
					h = 16,
					alpha = 0.7,
					color = Color(0,0.5,1) --blue
				},
				show_text = true,
				stay_open = false,
				callback =  callback(SentryControlMenu,SentryControlMenu,"SelectMode","normal")
			},
			{
				text = managers.localization:text("sentry_mode_overwatch"),
				icon = {
					texture = tweak_data.hud_icons.wp_sentry.texture,
					texture_rect = tweak_data.hud_icons.wp_sentry.texture_rect,
					layer = 3,
					w = 16,
					h = 16,
					alpha = 0.7,
					color = Color(0.5,1,0) --green
				},
				show_text = true,
				stay_open = false,
				callback =  callback(SentryControlMenu,SentryControlMenu,"SelectMode","overwatch")
			},
			{
				text = managers.localization:text("sentry_mode_manual"),
				icon = {
					texture = tweak_data.hud_icons.wp_sentry.texture,
					texture_rect = tweak_data.hud_icons.wp_sentry.texture_rect,
					layer = 3,
					w = 16,
					h = 16,
					alpha = 0.7,
					color = Color(1,0.7,0) --orange-yellow
				},
				show_text = true,
				stay_open = false,
				callback =  callback(SentryControlMenu,SentryControlMenu,"SelectMode","manual")
			},
			{
				text = managers.localization:text("sentry_ammo_taser"),
				icon = {
					texture = tweak_data.hud_icons.mugshot_electrified.texture,
					texture_rect = tweak_data.hud_icons.mugshot_electrified.texture_rect,
					layer = 3,
					w = 16,
					h = 16,
					alpha = 0.7,
					color = Color(1,1,0) --yellow
				},
				show_text = true,
				stay_open = false,
				callback = callback(SentryControlMenu,SentryControlMenu,"SelectAmmo","taser")
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
	MenuHelper:LoadFromJsonFile(SentryControlMenu._path .. "menu/menu_sentry_control.txt", SentryControlMenu, SentryControlMenu.settings)
	
end)
