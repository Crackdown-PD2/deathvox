Hooks:Add("LocalizationManagerPostInit", "DeathVox_Localization", function(loc)
	LocalizationManager:add_localized_strings({
		["menu_risk_sm_wish"] = "Fo Sho.",
		["menu_difficulty_sm_wish"] = "Crackdown"
	})
end)
