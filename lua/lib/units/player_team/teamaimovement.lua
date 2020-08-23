--used by clients
function TeamAIMovement:sync_reload_weapon(empty_reload, reload_speed_multiplier)
	local reload_action = {
		body_part = 3,
		type = "reload",
		idle_reload = empty_reload ~= 0 and empty_reload or nil
	}

	self:action_request(reload_action)
end

function TeamAIMovement:is_taser_attack_allowed()
	if not self._unit:character_damage():is_downed() and not self._unit:character_damage():_cannot_take_damage() and not self:cool() and not self:chk_action_forbidden("hurt") then
		return true
	end
	
	return
end
