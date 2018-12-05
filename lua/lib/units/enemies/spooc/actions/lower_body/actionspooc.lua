function ActionSpooc:complete()
	return (self._beating_end_t and self._beating_end_t < TimerManager:game():time()) or (self._beating_end_t and self._last_vel_z >= 0)
end

ActionSpooc._get_current_max_walk_speed = CopActionWalk._get_current_max_walk_speed
