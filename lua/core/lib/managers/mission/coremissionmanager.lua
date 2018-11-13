core:module("CoreMissionManager")

local fs_original_missionmanager_update = MissionManager.update
function MissionManager:update(t, dt)
	self.project_instigators_cache = {}
	fs_original_missionmanager_update(self, t, dt)
end

function MissionScript:is_debug() -- no clue what this does, check w/ rex and the map nerds
	return false
end