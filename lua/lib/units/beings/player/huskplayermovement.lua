-- remove when http://steamcommunity.com/app/218620/discussions/14/144513248272843703/ gets integrated into base game -- it never will
local fs_original_huskplayermovement_syncmovementstate = HuskPlayerMovement.sync_movement_state
function HuskPlayerMovement:sync_movement_state(state, down_time)
	if state == 'fatal' or state == 'incapacitated' then
		self:sync_stop_auto_fire_sound()
	end
	fs_original_huskplayermovement_syncmovementstate(self, state, down_time)
end

local fs_original_huskplayermovement_syncstartautofiresound = HuskPlayerMovement.sync_start_auto_fire_sound
function HuskPlayerMovement:sync_start_auto_fire_sound()
	if alive(self._unit:inventory():equipped_unit()) then
		fs_original_huskplayermovement_syncstartautofiresound(self)
	end
end

-- the dumb mag ban was removed