function ActionSpooc:complete()
	return (self._beating_end_t and self._beating_end_t < TimerManager:game():time()) or (self._beating_end_t and self._last_vel_z >= 0)
end

local fs_original_actionspooc_init = ActionSpooc.init
function ActionSpooc:init(action_desc, common_data)
	local result = fs_original_actionspooc_init(self, action_desc, common_data)
	self.fs_move_speed = CopActionWalk.fs_move_speeds[common_data.ext_base._tweak_table][self._stance.name][self._haste]
	return result
end

ActionSpooc._get_current_max_walk_speed = CopActionWalk._get_current_max_walk_speed