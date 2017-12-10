Hooks:Add("LocalizationManagerPostInit", "DeathVox_Localization", function(loc)
	LocalizationManager:add_localized_strings({
		["menu_risk_sm_wish"] = "It's true.",
		["menu_difficulty_sm_wish"] = "ANIME IS TRASH"
	})
end)