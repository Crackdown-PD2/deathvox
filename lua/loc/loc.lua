Hooks:Add("LocalizationManagerPostInit", "DeathVox_Localization", function(loc)
	LocalizationManager:add_localized_strings({
		["menu_risk_sm_wish"] = "Garrett got the DHS out, and he's taking control.",
		["menu_difficulty_sm_wish"] = "Crackdown"
	})
end)