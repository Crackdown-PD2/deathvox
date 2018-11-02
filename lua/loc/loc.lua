Hooks:Add("LocalizationManagerPostInit", "DeathVox_Localization", function(loc)
	LocalizationManager:add_localized_strings({
		["menu_risk_sm_wish"] = "Crackdown. A beary hard difficulty.",
		["menu_difficulty_sm_wish"] = "Crackdown",
		["hud_assault_cop_assault"] = "POLICE ASSAULT IN PROGRESS",
		["hud_assault_cop_cover"] = "STAY IN COVER",
		["hud_assault_fbi_assault"] = "FBI ASSAULT IN PROGRESS",
		["hud_assault_fbi_cover"] = "STAY IN COVER",
		["hud_assault_gensec_assault"] = "GenSec Presents: The Assault!",
		["hud_assault_gensec_cover"] = "Twenty-Four Seven Brand Cover!",
		["hud_assault_zeal_assault"] = "ZEAL EXTERMINATION UNDERWAY",
		["hud_assault_zeal_cover"] = "SURRENDER NOW OR FACE THE CONSEQUENCES",
		["hud_assault_murky_assault"] = "MURKYWATER OPERATION UNDERWAY",
		["hud_assault_murky_cover"] = "STAY IN COVER",
		["hud_assault_akan_assault"] = "АКАН НАПАДЕНИЕ В ПРОГРЕСС",
		["hud_assault_akan_cover"] = "ОСТОРОЖНО",
		["hud_assault_classic_assault"] = "POLICE ASSAULT IN PROGRESS",
		["hud_assault_classic_cover"] = "STAY IN COVER",
		["hud_assault_zombie_assault"] = "ALL HEIST AND NO DRILL",
		["hud_assault_zombie_cover"] = "MAKES BAIN A DULL SAFE"
	})
end)
