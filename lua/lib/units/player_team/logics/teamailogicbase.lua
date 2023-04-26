function TeamAILogicBase._get_logic_state_from_reaction(data, reaction)
	if data.last_engage_t and data.t - data.last_engage_t <= 7 then
		return "assault"
	elseif not reaction or reaction <= AIAttentionObject.REACT_SCARED then
		return "idle"
	else
		return "assault"
	end
end