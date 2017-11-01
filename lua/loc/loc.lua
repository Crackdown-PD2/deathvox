Hooks:Add("LocalizationManagerPostInit", "DeathVox_Localization", function(loc)
	LocalizationManager:add_localized_strings({
		["menu_risk_sm_wish"] = "When all of Vox's wishes are granted, many of his dreams will be destroyed.",
		["menu_difficulty_sm_wish"] = "Death Vox"
	})
end)