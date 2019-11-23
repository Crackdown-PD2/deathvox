function TeamAIMovement:is_taser_attack_allowed() --godfuckoff
	if not self._unit:character_damage():is_downed() and not self._unit:character_damage():_cannot_take_damage() then
		return true
	end
	
	return
end