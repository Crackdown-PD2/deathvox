--[[
local ids_material = Idstring("material")

local is_PS3 = SystemInfo:platform() == Idstring("PS3")
local is_win32 = SystemInfo:platform() == Idstring("WIN32")

local ids_contour_color = Idstring("contour_color")
local ids_contour_opacity = Idstring("contour_opacity")
--]]

if deathvox:IsTotalCrackdownEnabled() then 

	function SentryGunFireModeInteractionExt:interact(player)
		if not self:can_interact(player) then
			return false
		end

		SentryGunFireModeInteractionExt.super.super.interact(self, player)
		
		SentryControlMenu:SelectSentryByUnit(self._sentry_gun_weapon._unit)
		if SentryControlMenu.action_radial then 
			SentryControlMenu.action_radial:Show()
			self:unselect() --remove the prompt upon opening the menu
			
			SentryControlMenu.interacted_radial_start_t = Application:time()
			SentryControlMenu.button_held_state = nil
		end
	end
	
	ArmorPlatesBaseInteractionExt = ArmorPlatesBaseInteractionExt or class(UseInteractionExt)
	function ArmorPlatesBaseInteractionExt:_interact_blocked(player)
		return managers.player:get_property("armor_plates_active")--,false,"already_has_armor_plates"
	end
	
	function ArmorPlatesBaseInteractionExt:interact(player)
		ArmorPlatesBaseInteractionExt.super.super.interact(self,player)
		local interacted = self._unit:base():take(player)
		if interacted then 
			--managers.player:send_message(Message.OnArmorPlateUsed,nil,player)
			--no current plans to that would require setting up a listener
		end
		return interacted
	end
	
end