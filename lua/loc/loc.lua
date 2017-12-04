Hooks:Add("LocalizationManagerPostInit", "DeathVox_Localization", function(loc)
	LocalizationManager:add_localized_strings({
		["menu_risk_sm_wish"] = "Bad news, I'm your doctor.",
		["menu_difficulty_sm_wish"] = "GOOD NEWS, FREE HEALTHCARE"
	})
end)