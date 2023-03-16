_G.TripmineControlMenu = {}
TripmineControlMenu.action_radial = TripmineControlMenu.action_radial or nil
TripmineControlMenu.button_held_state = nil
TripmineControlMenu.interacted_radial_start_t = nil
TripmineControlMenu.ALPHA_HIGHLIGHT_ON = 1
TripmineControlMenu.ALPHA_HIGHLIGHT_OFF = 1/3
TripmineControlMenu.DEFAULT_TRIGGER_MODE = "trigger_default"
TripmineControlMenu.DEFAULT_PAYLOAD_MODE = "payload_explosive"
TripmineControlMenu.NETWORK_SPOOF_ID = "sync_trip_mine_explode_spawn_fire" --todo use "sync_trip_mine_setup" instead? would have to see if the sensor_upgrade value can be something other than a bool
TripmineControlMenu.NetworkSyncIDs = { --ordered table for network ids- DO NOT CHANGE THIS
	"payload_explosive",
	"payload_incendiary",
	"trigger_special",
	"payload_sensor",
	"trigger_detonate",
	"payload_concussive",
	"payload_recover"
}
TripmineControlMenu.NetworkSyncIDsReverseLookup = {} --ordered table for network ids- DO NOT CHANGE THIS
for k,v in ipairs(TripmineControlMenu.NetworkSyncIDs) do 
	TripmineControlMenu.NetworkSyncIDsReverseLookup[v] = k
end

TripmineControlMenu.MenuOrder = { --this can be edited to change the cosmetic order in the radial menu without risking sync issues
	"payload_incendiary", --top
	"trigger_special",--bottom
	"payload_sensor", 
--	"trigger_detonate", --disabled
	"payload_concussive",
	"payload_recover",
	"payload_explosive" --top
}
TripmineControlMenu.MenuOrderReverseLookup = {}

TripmineControlMenu.VALID_TRIPMINE_TRIGGER_MODES = {
	trigger_default = true, --normal mode
	trigger_special = true, --only trigger on specials
	trigger_detonate = true --detonate now
}

TripmineControlMenu.VALID_TRIPMINE_PAYLOAD_MODES = {
	payload_sensor = true,
	payload_explosive = true,
	payload_incendiary = true,
	payload_concussive = true,
	payload_recover = true
}

function TripmineControlMenu:SelectTripmineByUnit(unit)
	self._selected_unit = unit
	self:RefreshRadialHighlights()
end

function TripmineControlMenu:SetTripmineTrigger(unit,trigger)
	unit:base():set_trigger_mode(trigger)
end

function TripmineControlMenu:SetTripminePayload(unit,payload)
	unit:base():set_payload_mode(payload)
end

function TripmineControlMenu:SelectPayload(payload,unit)
	--callback from radial menu; application to multiple selections should be done here
	unit = unit or self._selected_unit
	if alive(unit) then
		self:SetTripminePayload(unit,payload)
	end
end

function TripmineControlMenu:SelectTrigger(trigger,unit)
	--callback from radial menu; application to multiple selections should be done here
	unit = unit or self._selected_unit
	if alive(unit) then 
		self:SetTripmineTrigger(unit,trigger)
	end
end

function TripmineControlMenu:RefreshRadialHighlights()
	if not self.action_radial then
		return
	end
	
	local trigger_mode = self.DEFAULT_TRIGGER_MODE
	local payload_mode = self.DEFAULT_PAYLOAD_MODE
	if alive(self._selected_unit) then 
		trigger_mode = self._selected_unit:base():_get_trigger_mode()
		payload_mode = self._selected_unit:base():_get_payload_mode()
	end
	
	for i,mode in ipairs(self.MenuOrder) do
		local item = self.action_radial._items[i]
		if item then
			local highlight_arc = item._body
			if alive(highlight_arc) then 
				if self.VALID_TRIPMINE_TRIGGER_MODES[mode] then 
					if trigger_mode == mode then 
						highlight_arc:set_alpha(self.ALPHA_HIGHLIGHT_ON)
					else
						highlight_arc:set_alpha(self.ALPHA_HIGHLIGHT_OFF)
					end
				elseif self.VALID_TRIPMINE_PAYLOAD_MODES[mode] then
					if payload_mode == mode then
						highlight_arc:set_alpha(self.ALPHA_HIGHLIGHT_ON)
					else
						highlight_arc:set_alpha(self.ALPHA_HIGHLIGHT_OFF)
					end
				end
			end
		end
	end
end

function TripmineControlMenu:SetActionMenu(menu)
	self.action_radial = menu or self.action_radial
	
	Hooks:Add("radialmenu_released_" .. self.action_radial:get_name(),"tripmine_control_menu_closed",function(num)
		self:RefreshRadialHighlights()
	--[[
		if true then 
			return 
		end
		local mode = self.MenuOrder[num]
		if mode then 
			if self.VALID_TRIPMINE_TRIGGER_MODES[mode] then 
				for other_mode,enabled in pairs(self.VALID_TRIPMINE_TRIGGER_MODES) do 
					if enabled then 
						local other_num = self.MenuOrderReverseLookup[other_mode]
						local item = self.action_radial._items[other_num]
						local highlight_arc = item and item._body
						if alive(highlight_arc) then 
							if (other_mode == mode) or (other_num == num) then 
								if mode == "trigger_special" then 
									if alive(self._selected_unit) then 
										if self._selected_unit:base():_get_trigger_mode() == "trigger_special" then 
											highlight_arc:set_alpha(1)
										else
											highlight_arc:set_alpha(0.5)
										end
									end
								else
									highlight_arc:set_alpha(1)
								end
							else
								highlight_arc:set_alpha(0.5)
							end
						end
					end
				end
			elseif self.VALID_TRIPMINE_PAYLOAD_MODES[mode] then
				for other_mode,enabled in pairs(self.VALID_TRIPMINE_PAYLOAD_MODES) do  
					if enabled then 
						local other_num = self.MenuOrderReverseLookup[other_mode]
						local item = self.action_radial._items[other_num]
						local highlight_arc = item and item._body
						if alive(highlight_arc) then 
							if (other_mode == mode) or (other_num == num) then 
								highlight_arc:set_alpha(1)
							else
								highlight_arc:set_alpha(0.5)
							end
						end
					end
				end
			end
		end
		--]]
	end)
	
	self:RefreshRadialHighlights()
end

function TripmineControlMenu:BuildMenuItems()
	if self.MenuData then 
		self.MenuOrderReverseLookup = {}
		local tbl = {}
		for i,name in ipairs(self.MenuOrder) do 
			table.insert(tbl,#tbl+1,self.MenuData[name])
			self.MenuOrderReverseLookup[name] = i
		end
		self.MenuItems = tbl
	end
end

function TripmineControlMenu:GetMenuItems()
	if self.MenuItems then 
		return self.MenuItems
	elseif self.MenuData then 
		self:BuildMenuItems()
		return self.MenuItems
	end
	return {}
end

function TripmineControlMenu:LoadMenuData()
	--execution must be delayed to allow localizationmanager to load
	self.MenuData = {
		payload_explosive = {
			text = managers.localization:text("tripmine_payload_explosive"),
			icon = {
				texture = tweak_data.hud_icons.pd2_c4.texture,
				texture_rect = tweak_data.hud_icons.pd2_c4.texture_rect,
				layer = 3,
				w = 16,
				h = 16,
				alpha = 0.7,
				color = Color(1,1,0)
			},
			show_text = true,
			stay_open = false,
			callback =  callback(self,self,"SelectPayload","payload_explosive")
		},
		payload_incendiary = {
			text = managers.localization:text("tripmine_payload_incendiary"),
			icon = {
				texture = tweak_data.hud_icons.pd2_fire.texture,
				texture_rect = tweak_data.hud_icons.pd2_fire.texture_rect,
				layer = 3,
				w = 16,
				h = 16,
				alpha = 0.7,
				color = Color(1,0.5,0)
			},
			show_text = true,
			stay_open = false,
			callback =  callback(self,self,"SelectPayload","payload_incendiary")
		},
		payload_concussive = {
			text = managers.localization:text("tripmine_payload_concussive"),
			icon = {
				texture = tweak_data.hud_icons.concussion_grenade.texture,
				texture_rect = tweak_data.hud_icons.concussion_grenade.texture_rect,
				layer = 3,
				w = 16,
				h = 16,
				alpha = 0.7,
				color = Color(1,1,1)
			},
			show_text = true,
			stay_open = false,
			callback =  callback(self,self,"SelectPayload","payload_concussive")
		},
		payload_sensor = {
			text = managers.localization:text("tripmine_payload_sensor"),
			icon = {
				texture = tweak_data.hud_icons.pd2_generic_look.texture,
				texture_rect = tweak_data.hud_icons.pd2_generic_look.texture_rect,
				layer = 3,
				w = 16,
				h = 16,
				alpha = 0.7,
				color = Color(0,0.2,1)
			},
			show_text = true,
			stay_open = false,
			callback =  callback(self,self,"SelectPayload","payload_sensor")
		},
		trigger_detonate = {
			text = managers.localization:text("tripmine_trigger_detonate"),
			icon = {
				texture = tweak_data.hud_icons.wp_calling_in.texture,
				texture_rect = tweak_data.hud_icons.wp_calling_in.texture_rect,
				layer = 3,
				w = 32,
				h = 16,
				alpha = 0.7,
				color = Color(1,0,0)
			},
			show_text = true,
			stay_open = false,
			callback = callback(self,self,"SelectTrigger","trigger_detonate")
		},
		trigger_special = {
			text = managers.localization:text("tripmine_trigger_special"),
			icon = {
				texture = tweak_data.hud_icons.equipment_scythe.texture,
				texture_rect = tweak_data.hud_icons.equipment_scythe.texture_rect,
				layer = 3,
				w = 24,
				h = 24,
				alpha = 0.7,
				color = Color(1,0,0.2)
			},
			show_text = true,
			stay_open = false,
			callback = callback(self,self,"SelectTrigger","trigger_special")
		},
		trigger_default = {--not used
			text = managers.localization:text("tripmine_trigger_default"),
			icon = {
				texture = tweak_data.hud_icons.wp_detected.texture,
				texture_rect = tweak_data.hud_icons.wp_detected.texture_rect,
				layer = 3,
				w = 16,
				h = 16,
				alpha = 0.7,
				color = Color(1,0,0)
			},
			show_text = true,
			stay_open = false,
			callback = callback(self,self,"SelectTrigger","trigger_default")
		},
		payload_recover = {
			text = managers.localization:text("tripmine_payload_recover"),
			icon = {
				texture = tweak_data.hud_icons.develop.texture,
				texture_rect = tweak_data.hud_icons.develop.texture_rect,
				layer = 3,
				w = 24,
				h = 24,
				alpha = 0.7,
				color = Color(1,1,1)
			},
			show_text = true,
			stay_open = false,
			callback = callback(self,self,"SelectPayload","payload_recover")
		}
	}
	self:BuildMenuItems()
end

Hooks:Add("BaseNetworkSessionOnLoadComplete","tcd_create_tripmine_control_menu",function()
	if not deathvox:IsTotalCrackdownEnabled() then return end
	
	TripmineControlMenu:LoadMenuData()
	
	RadialMouseMenu:new({
		name = managers.localization:text("tripmine_control_menu_title"),
		radius = 350,
		deadzone = 50,
		items = TripmineControlMenu:GetMenuItems()
	},callback(TripmineControlMenu,TripmineControlMenu,"SetActionMenu"))
end)
