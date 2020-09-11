Hooks:Add("LocalizationManagerPostInit", "DeathVox_Localization", function(loc)
	LocalizationManager:add_localized_strings({
		["menu_risk_sm_wish"] = "CRACKDOWN. New enemies, ultimate challenge.",
		["menu_difficulty_sm_wish"] = "Crackdown",
		["hud_assault_generic_assault"] = "ASSAULT IN PROGRESS",
		["hud_assault_generic_cover"] = "STAY IN COVER",
		["hud_assault_cop_assault"] = "POLICE ASSAULT IN PROGRESS",
		["hud_assault_cop_cover"] = "STAY IN COVER",
		["hud_assault_fbi_assault"] = "FBI OFFENSIVE IS GO",
		["hud_assault_fbi_cover"] = "SEEK VIABLE SHELTER",
		["hud_assault_gensec_assault"] = "GENSEC CHARGE INITIATED",
		["hud_assault_gensec_cover"] = "REMAIN ALERT",
		["hud_assault_zeal_assault"] = "ZULU FORCE INBOUND",
		["hud_assault_zeal_cover"] = "TRY TO SURVIVE",
		["hud_assault_federales_assault"] = "FEDERAL POLICE ADVANCING",
		["hud_assault_federales_cover"] = "BRACE FOR IMPACT",
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

Hooks:Add("LocalizationManagerPostInit", "DeathVox_Overhaul", function(loc)
	if deathvox then
		if deathvox:IsTotalCrackdownEnabled() then
			loc:add_localized_strings({
				["debug_interact_gage_assignment_take"] = "PRESS $BTN_INTERACT TO PICK UP THE PACKAGE",
				
				--gunner
				["menu_steady_grip_beta"] = "Spray & Pray",
				["menu_steady_grip_beta_desc"] = "BASIC: ##$basic##\nYour SMGs, and Assault Rifles gain ##+10%## Critical Hit chance.\n\nACE: ##$pro##\nYour ranged weapons can now ##pierce Body Armor.##",
				["menu_heavy_impact_beta"] = "Money Shot",
				["menu_heavy_impact_beta_desc"] = "BASIC: ##$basic##\nYour SMGs, and Assault Rifles gain ##+100%## Damage on the last bullet fired from a fully loaded magazine.\n\nACE: ##$pro##\nYour SMGs and Assault Rifles' gain ##+50%## faster Reload Speed when their Magazine is empty.",
				["menu_fire_control_beta"] = "Shot Grouping",
				["menu_fire_control_beta_desc"] = "BASIC: ##$basic##\nYour SMGs, and Assault Rifles ADS ##+90%## faster.\n\nACE: ##$pro##\nYour SMGs, and Assault Rifles gain ##+40 Accuracy and Stability while ADSing.##",
				["menu_fast_fire_beta"] = "Close Enough",
				["menu_fast_fire_beta_desc"] = "BASIC: ##$basic##\nYour SMGs, and Assault Rifles' bullets that strike hard surfaces ##ricochet once.##\n\nACE: ##$pro##\nCritical Hits cause ricochets to ##angle towards the closest enemy.##",
				["menu_shock_and_awe_beta"] = "Making Miracles",
				["menu_shock_and_awe_beta_desc"] = "BASIC: ##$basic##\nYour SMGs, and Assault Rifles gain ##+1%## Critical Hit chance for ##4## seconds when hitting an enemy with a Headshot, stacking up to ##+10%##.\n\nACE: ##$pro##\nKilling an enemy with a Headshot ##generates an additional stack##. Maximum bonus increased to ##+20%##.",
				["menu_body_expertise_beta"] = "Prayers Answered",
				["menu_body_expertise_beta_desc"] = "BASIC: ##$basic##\nYour SMGs, and Assault Rifles have their Critical Hit chance increased by ##+10%##, for a total of ##+20%##.\n\nACE: ##$pro##\nYour SMGs, and Assault Rifles have their Critical Hit chance ##further## increased by ##+10%##, for a total of ##+30%##.",
				
				--dsfdsfdsfsd
				["menu_far_away_beta"] = "Point Blank",
				["menu_far_away_beta_desc"] = "BASIC: ##$basic##\nFor the first 100cm, your Shotguns will now gain ##Armor Piercing, Shield Piercing, and Body Piercing.##\n\nACE: ##$pro##\nPoint Blank also grants ##+100%## Damage for the first meter."
			})
		end
		loc:add_localized_strings({
			["bm_equipment_sentry_gun_desc"] = "Deployable weapon with multiple firing modes that will automatically attack enemies within range. Enemies will ignore Sentry Guns, making them excellent for fire support.\n\nTo deploy, hold $BTN_USE_ITEM on a suitable surface.",
			["bm_equipment_sentry_gun_silent_desc"] = "Deployable weapon with multiple firing modes that will automatically attack enemies within range. Enemies will ignore Sentry Guns, making them excellent for fire support.\n\nTo deploy, hold $BTN_USE_ITEM on a suitable surface.",
			["bm_equipment_sentry_gun_silent_desc_UNUSED"] = "oopsie whoopsie!\nuwu\nwe made a fucky wucky!!1 a wittle fucko boingo! the code monkies at our headquarters are working VEWY HAWD to fix this!",
			["sentry_mode_standard"] = "Standard Mode",
			["sentry_mode_overwatch"] = "Overwatch Mode",
			["sentry_mode_manual"] = "Manual Mode",
			["sentry_ammo_ap"] = "AP Ammo",
			["sentry_ammo_he"] = "HE Ammo",
			["sentry_ammo_taser"] = "Taser Ammo",
			["sentry_ammo_standard"] = "Standard Ammo",
			["hud_interact_pickup_sentry_gun"] = "Hold $BTN_INTERACT to pick up sentry gun",
			["tcdso_menu_title"] = "Sentry Overhaul Menu",
			["tcdso_menu_desc"] = "TOTAL CRACKDOWN Sentry Overhaul Menu (Standalone)",
			["tcdso_option_keybind_select_sentry_title"] = "Keybind: Select Sentry",
			["tcdso_option_keybind_select_sentry_desc"] = "When held, this selects any sentry or sentries you aim at.",
			["tcdso_option_keybind_deselect_sentry_title"] = "Keybind: Deselect Sentry",
			["tcdso_option_keybind_deselect_sentry_desc"] = "When held, this deselects any sentry or sentries you aim at.",
			["tcdso_option_keybind_open_menu_title"] = "Keybind: Sentry Control Menu",
			["tcdso_option_keybind_open_menu_desc"] = "Opens the Sentry Control Menu.",
			["tcdso_option_open_menu_behavior_title"] = "Hold/Toggle Menu Behavior",
			["tcdso_option_open_menu_behavior_desc"] = "Choose whether hold/release will select Sentry Modes with the Radial Menu",
			["tdso_option_refresh_keybinds_title"] = "Apply Keybind Changes",
			["tdso_option_refresh_keybinds_desc"] = "Click to refresh your keybinds if you have rebound them after the heist starts.",
			["tcdso_option_hold_behavior"] = "On Button Hold+Release",
			["tcdso_option_toggle_behavior"] = "On Second Button Press",
			["tcdso_option_any_behavior"] = "On Hold+Release, Press, or Click",
			["tcdso_option_click_behavior"] = "On Mouse-Click Only",
			
			["tcdso_mouseclick_on_menu_close_title"] = "Select Current Option on Menu Close",
			["tcdso_mouseclick_on_menu_close_desc"] = "(Hold Behavior only)",
			["tcdso_option_teammate_alpha_title"] = "Teammate Laser Alpha",
			["tcdso_option_teammate_alpha_desc"] = "Set the opacity of teammate sentries' lasers",
			["tcdso_option_hold_threshold_title"] = "Set button hold threshold",
			["tcdso_option_hold_threshold_desc"] = "Holding 'Interact' for longer than this many seconds will hide the menu upon button release."

		})
	end
end)