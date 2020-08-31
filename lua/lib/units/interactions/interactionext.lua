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

function BaseInteractionExt:_get_timer()
	local modified_timer = self:_get_modified_timer()

	if modified_timer then
		return modified_timer
	end

	local multiplier = 1

	if self.tweak_data ~= "corpse_alarm_pager" then
		multiplier = multiplier * managers.player:crew_ability_upgrade_value("crew_interact", 1)
		if managers.groupai:state():whisper_mode() then
			if managers.player:upgrade_value("player", "burglar_t9") == true then
				multiplier = multiplier - 0.25
			elseif managers.player:upgrade_value("player", "burglar_t7") == true then
				multiplier = multiplier - 0.2
			elseif managers.player:upgrade_value("player", "burglar_t5") == true then
				multiplier = multiplier - 0.15
			elseif managers.player:upgrade_value("player", "burglar_t3") == true then
				multiplier = multiplier - 0.1
			elseif managers.player:upgrade_value("player", "burglar_t1") == true then
				multiplier = multiplier - 0.05
			end
		end
	else
		if managers.player:upgrade_value("player", "burglar_t8") == true then
			multiplier = multiplier - 0.1
		end
	end

	if self._tweak_data.upgrade_timer_multiplier then
		multiplier = multiplier * managers.player:upgrade_value(self._tweak_data.upgrade_timer_multiplier.category, self._tweak_data.upgrade_timer_multiplier.upgrade, 1)
	end

	if self._tweak_data.upgrade_timer_multipliers then
		for _, upgrade_timer_multiplier in pairs(self._tweak_data.upgrade_timer_multipliers) do
			multiplier = multiplier * managers.player:upgrade_value(upgrade_timer_multiplier.category, upgrade_timer_multiplier.upgrade, 1)
		end
	end

	if managers.player:has_category_upgrade("player", "level_interaction_timer_multiplier") then
		local data = managers.player:upgrade_value("player", "level_interaction_timer_multiplier") or {}
		local player_level = managers.experience:current_level() or 0
		multiplier = multiplier * (1 - (data[1] or 0) * math.ceil(player_level / (data[2] or 1)))
	end

	return self:_timer_value() * multiplier * managers.player:toolset_value()
end