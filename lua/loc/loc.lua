Hooks:Add("LocalizationManagerPostInit", "DeathVox_Localization", function(loc)
	LocalizationManager:add_localized_strings({
		["menu_risk_sm_wish"] = "CRACKDOWN. New enemies, ultimate challenge.",
		["menu_difficulty_sm_wish"] = "Crackdown",
		["hud_assault_cop_assault"] = "POLICE ASSAULT IN PROGRESS",
		["hud_assault_cop_cover"] = "STAY IN COVER",
		["hud_assault_fbi_assault"] = "FBI ASSAULT IN PROGRESS",
		["hud_assault_fbi_cover"] = "SHELTER IN PLACE",
		["hud_assault_gensec_assault"] = "GENSEC OFFENSIVE IS GO",
		["hud_assault_gensec_cover"] = "REMAIN ALERT",
		["hud_assault_zeal_assault"] = "ZULU FORCE INBOUND",
		["hud_assault_zeal_cover"] = "TRY TO SURVIVE",
		["hud_assault_murky_assault"] = "MURKYWATER ASSAULT IN PROGRESS",
		["hud_assault_murky_cover"] = "STAND YOUR GROUND",
		["hud_assault_akan_assault"] = "Идёт штурм наёмников",
		["hud_assault_akan_cover"] = "Оставайтесь в укрытии",
		["hud_assault_classic_assault"] = "POLICE ASSAULT IN PROGRESS",
		["hud_assault_classic_cover"] = "STAY IN COVER",
		["hud_assault_zombie_assault"] = "I SEE YOU",
		["hud_assault_zombie_cover"] = "NO ESCAPE NO ESCAPE NO ESCAPE",
		["hud_assault_gsg9_assault"] = "POLIZEIVORSTOẞ IM GANGE",
		["hud_assault_gsg9_cover"]	= "IN DECKUNG BLEIBEN"
	})
end)

Hooks:Add("LocalizationManagerPostInit", "DV_HopLibKillfeedStuff", function(loc)
	loc:load_localization_file(ModPath .. "lua/loc/hoplibenemylist.txt")
end)

Hooks:Add("LocalizationManagerPostInit", "DeathVox_Overhaul", function(loc)
	if deathvox and deathvox:IsTotalCrackdownEnabled() then
		LocalizationManager:add_localized_strings({
			["debug_interact_gage_assignment_take"] = "PRESS $BTN_INTERACT TO PICK UP THE PACKAGE",		
			["menu_fast_fire_beta"] = "Close Enough",
			["menu_fast_fire_beta_desc"] = "BASIC: ##$basic##\nYour SMGs, LMGs and Assault Rifles gain ##15## more bullets in their magazine.\n\nACE: ##$pro##\nYour SMGs and Assault Rifles' bullets that strike hard surfaces ##have a 25% chance to ricochet## towards enemies.",
			["menu_heavy_impact_beta"] = "Money Shot",
			["menu_heavy_impact_beta_desc"] = "BASIC: ##$basic##\nYour SMGs, and Assault Rifles gain ##+100%## Damage on the last bullet fired from a fully loaded magazine.\n\nACE: ##$pro##\nYour SMGs and Assault Rifles' gain ##+50%## faster Reload Speed when their Magazine is empty.",
			["menu_far_away_beta"] = "Point Blank",
			["menu_far_away_beta_desc"] = "BASIC: ##$basic##\nFor the first 100cm, your Shotguns will now gain ##Armor Piercing, Shield Piercing, and Body Piercing.##\n\nACE: ##$pro##\nPoint Blank also grants ##+100%## Damage for the first meter."
		})
	end
end)