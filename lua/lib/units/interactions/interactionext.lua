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
			
			SentryControlMenu.interacted_radial_start_t = Application:time()
			SentryControlMenu.button_held_state = nil
		end
	end
end