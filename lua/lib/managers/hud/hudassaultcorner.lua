function HUDAssaultCorner:_get_assault_strings()
	if self._assault_mode == "normal" then
		local ids_risk
		local faction = tweak_data.levels:get_ai_group_type()
		if managers.job:current_difficulty_stars() > 0 then
			ids_risk = Idstring("risk")
		end
		if ids_risk then
			return {
				"hud_assault_" .. faction .. "_assault",
				"hud_assault_end_line",
				ids_risk,
				"hud_assault_end_line",
				"hud_assault_" .. faction .. "_cover",
				"hud_assault_end_line",
				ids_risk,
				"hud_assault_end_line",
				"hud_assault_" .. faction .. "_assault",
				"hud_assault_end_line",
				ids_risk,
				"hud_assault_end_line",
				"hud_assault_" .. faction .. "_cover",
				"hud_assault_end_line"
			}
		else
			return {
				"hud_assault_" .. faction .. "_assault",
				"hud_assault_end_line",
				"hud_assault_" .. faction .. "_cover",
				"hud_assault_end_line",
				"hud_assault_" .. faction .. "_assault",
				"hud_assault_end_line",
				"hud_assault_" .. faction .. "_cover",
				"hud_assault_end_line"
			}
		end
	end

	if self._assault_mode == "phalanx" then
		if managers.job:current_difficulty_stars() > 0 then
			local ids_risk = Idstring("risk")

			return {
				"hud_assault_vip",
				"hud_assault_padlock",
				ids_risk,
				"hud_assault_padlock",
				"hud_assault_vip",
				"hud_assault_padlock",
				ids_risk,
				"hud_assault_padlock"
			}
		else
			return {
				"hud_assault_vip",
				"hud_assault_padlock",
				"hud_assault_vip",
				"hud_assault_padlock",
				"hud_assault_vip",
				"hud_assault_padlock"
			}
		end
	end
end