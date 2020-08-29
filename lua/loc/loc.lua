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
				["menu_steady_grip_beta"] = "Spray & Pray",
				["menu_steady_grip_beta_desc"] = "BASIC: ##$basic##\nYour SMGs, and Assault Rifles gain ##+10%## Critical Hit chance.\n\nACE: ##$pro##\nYour ranged weapons can now ##pierce Body Armor.##",
				["menu_fast_fire_beta"] = "Close Enough",
				["menu_fast_fire_beta_desc"] = "BASIC: ##$basic##\nYour SMGs, and Assault Rifles' bullets that strike hard surfaces ##ricochet once.##\n\nACE: ##$pro##\nCritical Hits cause ricochets to ##angle towards the closest enemy.##",
				["menu_heavy_impact_beta"] = "Money Shot",
				["menu_heavy_impact_beta_desc"] = "BASIC: ##$basic##\nYour SMGs, and Assault Rifles gain ##+100%## Damage on the last bullet fired from a fully loaded magazine.\n\nACE: ##$pro##\nYour SMGs and Assault Rifles' gain ##+50%## faster Reload Speed when their Magazine is empty.",
				["menu_far_away_beta"] = "Point Blank",
				["menu_far_away_beta_desc"] = "BASIC: ##$basic##\nFor the first 100cm, your Shotguns will now gain ##Armor Piercing, Shield Piercing, and Body Piercing.##\n\nACE: ##$pro##\nPoint Blank also grants ##+100%## Damage for the first meter.",
				-- Crew Chief
				["crew_chief_deck"] = "Crew Chief: CRACKDOWN",
				["crew_chief_deck_desc"] = "A Jack of all trades Team Deck that gives a variety of moderate defensive bonuses. Very referential.",
				["crew_chief_t1_name"] = "The Usual Suspects",
				["crew_chief_t1_desc"] = "Your team gains ##+10%## Damage Resistance.",

				["crew_chief_t2_name"] = "Reservoir Dogs",
				["crew_chief_t2_desc"] = "Your team gains ##+15%## Maximum Health.",

				["crew_chief_t3_name"] = "One Hundred Steps",
				["crew_chief_t3_desc"] = "Your team gains ##+100%## Maximum Stamina.",

				["crew_chief_t4_name"] = "State of Grace",
				["crew_chief_t4_desc"] = "Your team gains ##+10%## Maximum Armor.",

				["crew_chief_t5_name"] = "Mean Streets",
				["crew_chief_t5_desc"] = "Each member of your team regenerates ##1%## of their Missing Health per second.",

				["crew_chief_t6_name"] = "Goodfellas",
				["crew_chief_t6_desc"] = "Increases your team’s Maximum Health bonus to ##+30%##.",

				["crew_chief_t7_name"] = "Heat",
				["crew_chief_t7_desc"] = "Your team gains ##+10%## Armor Recovery Rate.",

				["crew_chief_t8_name"] = "Layer Cake",
				["crew_chief_t8_desc"] = "Increases your team’s Maximum Armor bonus to ##+20%##.",

				["crew_chief_t9_name"] = "Angels with Dirty Faces",
				["crew_chief_t9_desc"] = "Your team gains an additional ##10%## Damage Resistance, for a maximum of ##+20%##.",
				-- Muscle
				["muscle_deck"] = "Muscle: CRACKDOWN",
				["muscle_deck_desc"] = "Massive Health and Health Regeneration. Flex eternal!",
				["muscle_t1_name"] = "Dynamic Tension",
				["muscle_t1_desc"] = "You gain ##+25%## Maximum Health and you become ##25%## more likely to be targeted over your teammates.",

				["muscle_t2_name"] = "Endurance Training",
				["muscle_t2_desc"] = "You regenerate ##0.5%## of your Maximum Health per second.",

				["muscle_t3_name"] = "Chump into Champ",
				["muscle_t3_desc"] = "Increases your Maximum Health bonus to ##+50%##.",

				["muscle_t4_name"] = "Dauntless Improvement",
				["muscle_t4_desc"] = "Your Health Regeneration increases to ##1%## of your Maximum Health per second.",

				["muscle_t5_name"] = "15 Minutes A Day",
				["muscle_t5_desc"] = "Increases your Maximum Health bonus to ##+75%##.",

				["muscle_t6_name"] = "Tireless Physique",
				["muscle_t6_desc"] = "Your Health Regeneration increases to ##1.5%## of your Maximum Health per second.",

				["muscle_t7_name"] = "Muscle Mystery",
				["muscle_t7_desc"] = "Increases your Maximum Health bonus to ##+100%##.",

				["muscle_t8_name"] = "Flex Eternal",
				["muscle_t8_desc"] = "Your Health Regeneration increases to ##2%## of your Maximum Health per second.",

				["muscle_t9_name"] = "Hero Of The Beach",
				["muscle_t9_desc"] = "Increases your Maximum Health bonus to ##+125%##.",
				-- Armorer
				["armorer_deck"] = "Armorer: CRACKDOWN",
				["armorer_deck_desc"] = "Heavy Armor all day, every day.",
				["armorer_t1_name"] = "MK1 Plating",
				["armorer_t1_desc"] = "You gain ##+20%## Maximum Armor and ##+5%## Armor Recovery Rate.",

				["armorer_t2_name"] = "Steadfast",
				["armorer_t2_desc"] = "##Doubles## the Steadiness of your equipped Armor, reducing how much you Flinch from taking Damage.",

				["armorer_t3_name"] = "MK2 Plating",
				["armorer_t3_desc"] = "Increases your Maximum Armor bonus to ##+40%## and Armor Recovery Rate bonus to ##+10%##.",

				["armorer_t4_name"] = "Armored Grace",
				["armorer_t4_desc"] = "Your Speed penalty for wearing Armor is reduced by ##50%##.",

				["armorer_t5_name"] = "MK3 Plating",
				["armorer_t5_desc"] = "Increases your Maximum Armor bonus to ##+60%## and Armor Recovery Rate bonus to ##+15%##.",

				["armorer_t6_name"] = "Reactive Armor",
				["armorer_t6_desc"] = "You are rendered ##Invulnerable## to damage for ##2 seconds## after your Armor breaks. This effect has a ##10 second cooldown##.",

				["armorer_t7_name"] = "MK4 Plating",
				["armorer_t7_desc"] = "Increases your Maximum Armor bonus to ##+80%## and Armor Recovery Rate bonus to ##+20%##.",

				["armorer_t8_name"] = "Ironclad",
				["armorer_t8_desc"] = "You gain ##+10%## Damage Resistance when you ##have any amount of Armor##.",

				["armorer_t9_name"] = "MK5 Plating",
				["armorer_t9_desc"] = "Increases your Maximum Armor bonus to ##+100%## and Armor Recovery Rate bonus to ##+25%##.",
				-- Rogue
				["rogue_deck"] = "Rogue: CRACKDOWN",
				["rogue_deck_desc"] = "Provides Dodge Chance and comes with Special Dodges that are guaranteed to avoid certain attacks. Features a rebranded Sneaky Bastard.",
				["rogue_t1_name"] = "Fat Chance",
				["rogue_t1_desc"] = "You gain ##+10%## Dodge Chance.",

				["rogue_t2_name"] = "Hands Off",
				["rogue_t2_desc"] = "You are ##guaranteed## to Dodge an enemy Melee attack. This effect has a ##10 second cooldown##.",

				["rogue_t3_name"] = "Playing the Odds",
				["rogue_t3_desc"] = "Increases your Dodge Chance bonus to ##+20%##.",

				["rogue_t4_name"] = "Elusive Target",
				["rogue_t4_desc"] = "You are ##guaranteed## to Dodge a Sniper’s shot. This effect has a ##10 second cooldown##.",

				["rogue_t5_name"] = "Tricky Business",
				["rogue_t5_desc"] = "Increases your Dodge Chance bonus to ##+30%##.",

				["rogue_t6_name"] = "Kansas City Shuffle",
				["rogue_t6_desc"] = "You are ##guaranteed## to Dodge a Cloaker’s kick. This effect has a ##10 second cooldown##.",

				["rogue_t7_name"] = "Isai’s Wisdom",
				["rogue_t7_desc"] = "Increases your Dodge Chance bonus to ##+40%##.",

				["rogue_t8_name"] = "The Electric Slide",
				["rogue_t8_desc"] = "You are ##guaranteed## to Dodge a Taser’s shock attack. This effect has a ##10 second cooldown##.",

				["rogue_t9_name"] = "Smooth Criminal",
				["rogue_t9_desc"] = "You gain a bonus ##+2%## Dodge Chance for every ##2 points of Detection Risk## under ##35##, up to ##+20%##."

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