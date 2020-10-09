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
				
				--skilltree sub-tree names
				st_menu_dallas_boss = "Boss",
				st_menu_dallas_marksman = "Marksman",
				st_menu_dallas_medic = "Medic",
				st_menu_chains_chief = "Chief",
				st_menu_chains_enforcer = "Enforcer",
				st_menu_chains_heavy = "Heavy",
				st_menu_wolf_runner = "Runner",
				st_menu_wolf_gunner = "Gunner",
				st_menu_wolf_engineer = "Engineer",
				st_menu_houston_thief = "Thief",
				st_menu_houston_assassin = "Assassin",
				st_menu_houston_sapper = "Sapper",
				st_menu_hoxton_dealer = "Dealer",
				st_menu_hoxton_fixer = "Fixer",
				st_menu_hoxton_demolitionist = "Demolitionist",
				
				--marksman
				menu_point_and_click = "Point and Click",
				menu_point_and_click_desc = "BASIC: ##$basic##\nPrecision Weapons gain ##+1%## Damage per hit, up to ##500%##. All stacks are lost upon missing.\n\nACE: ##$pro##\nPrecision Weapons ADS ##90%## faster.",
				menu_tap_the_trigger = "Tap the Trigger",
				menu_tap_the_trigger_desc = "BASIC: ##$basic##\nPrecision Weapons also gain ##+1%## Rate of Fire per stack of Point and Click, up to ##+50%##.\n\nACE: ##$pro##\nMaximum Rate of Fire Bonus increased to ##+100%##.",
				menu_investment_returns = "Investment Returns",
				menu_investment_returns_desc = "BASIC: ##$basic##\nYou gain ##an extra stack## of Point and Click when you kill an enemy.\n\nACE: ##$pro##\nYou gain ##another extra stack## of Point and Click when you kill an enemy with a Headshot.",
				menu_this_machine = "This Machine",
				menu_this_machine_desc = "BASIC: ##$basic##\nPrecision Weapons also gain ##+0.5%## Reload Speed per stack of Point and Click, up to ##+25%##.\n\nACE: ##$pro##\nMaximum Reload Speed Bonus increased to ##+50%##.",
				menu_mulligan = "Mulligan",
				menu_mulligan_desc = "BASIC: ##$basic##\nAfter missing, you gain a ##1-second## grace period where you still benefit from your Point and Click stacks. Killing an enemy during the grace period will prevent your stacks from being lost.\n\nACE: ##$pro##\nThe grace period is extended to ##1.5 seconds##.",
				menu_magic_bullet = "Magic Bullet",
				menu_magic_bullet_desc = "BASIC: ##$basic##\nKilling an enemy with a Headshot from a Precision Weapon adds ##1## bullet to your reserve ammunition.\n\nACE: ##$pro##\nThe bullet is added to your current Magazine instead of your reserves.",
			

				
				--gunner
				menu_spray_and_pray = "Spray & Pray",
				menu_spray_and_pray_desc = "BASIC: ##$basic##\nYour SMGs, and Assault Rifles gain ##+10%## Critical Hit chance.\n\nACE: ##$pro##\nYour ranged weapons can now ##pierce Body Armor.##",
				menu_money_shot = "Money Shot",
				menu_money_shot_desc = "BASIC: ##$basic##\nYour SMGs, and Assault Rifles gain ##+100%## Damage on the last bullet fired from a fully loaded magazine.\n\nACE: ##$pro##\nYour SMGs and Assault Rifles' gain ##+50%## faster Reload Speed when their Magazine is empty.",
				menu_shot_grouping = "Shot Grouping",
				menu_shot_grouping_desc = "BASIC: ##$basic##\nYour SMGs, and Assault Rifles ADS ##+90%## faster.\n\nACE: ##$pro##\nYour SMGs, and Assault Rifles gain ##+40 Accuracy and Stability while ADSing.##",
				menu_making_miracles = "Making Miracles",
				menu_making_miracles_desc = "BASIC: ##$basic##\nYour SMGs, and Assault Rifles gain ##+1%## Critical Hit chance for ##4## seconds when hitting an enemy with a Headshot, stacking up to ##+10%##.\n\nACE: ##$pro##\nKilling an enemy with a Headshot ##generates an additional stack##. Maximum bonus increased to ##+20%##.",
				menu_close_enough = "Close Enough",
				menu_close_enough_desc = "BASIC: ##$basic##\nYour SMGs, and Assault Rifles' bullets that strike hard surfaces ##ricochet once.##\n\nACE: ##$pro##\nCritical Hits cause ricochets to ##angle towards the closest enemy.##",
				menu_prayers_answered = "Prayers Answered",
				menu_prayers_answered_desc = "BASIC: ##$basic##\nYour SMGs, and Assault Rifles have their Critical Hit chance increased by ##+10%##, for a total of ##+20%##.\n\nACE: ##$pro##\nYour SMGs, and Assault Rifles have their Critical Hit chance ##further## increased by ##+10%##, for a total of ##+30%##.",
				
				--ghost
				["menu_backstab_beta"] = "Professional's Choice",
				["menu_backstab_beta_desc"] = "BASIC: ##$basic##\nSilenced Weapons gain a ##+2% Fire Rate bonus## for every ##3## points of Detection Risk under ##35##, up to ##+10%##.\n\nACE: ##$pro##\nThe Fire Rate bonus is increased to ##+4%## and the maximum bonus is increased to ##+20%##.",
				
				--enforcer
				["menu_far_away_beta"] = "Point Blank",
				["menu_far_away_beta_desc"] = "BASIC: ##$basic##\nFor the first 100cm, your Shotguns will now gain ##Armor Piercing, Shield Piercing, and Body Piercing.##\n\nACE: ##$pro##\nPoint Blank also grants ##+100%## Damage for the first meter.",
				
				--engineer
				menu_digging_in = "Digging In",
				menu_digging_in_desc = "BASIC: ##$basic##\nYou deploy and retrieve Sentry Guns ##90%## faster.\n\nACE: ##$pro##\nYour Sentry Guns become armored, rendering them almost completely invulnerable.",
				menu_advanced_rangefinder = "Advanced Rangefinder",
				menu_advanced_rangefinder_desc = "BASIC: ##$basic##\nSentry Guns gain ##+50%## Range and Accuracy.\n\nACE: ##$pro##\nRange and Accuracy bonus increased to ##+100%##.",
				menu_targeting_matrix = "Targeting Matrix",
				menu_targeting_matrix_desc = "BASIC: ##$basic##\nSentry Guns that aim at Special Enemies instantly Mark them for 5 seconds.\n\nACE: ##$pro##\nSentry Guns deal ##+25%## Damage to Marked enemies.",
				menu_wrangler = "Wrangler",
				menu_wrangler_desc = "BASIC: ##$basic##\nWhile in Manual Control of a Sentry Gun, it gains perfect Accuracy.\n\nACE: ##$pro##\nSentries deal ##+100%## Damage on Headshots.",
				menu_hobarts_funnies = "Hobart's Funnies",
				menu_hobarts_funnies_desc = "BASIC: ##$basic##\nNon-Basic Sentry Gun modes gain ##+25%## Fire Rate.\n\nACE: ##$pro##\nFire Rate bonus increased to ##+50%##.",
				menu_killer_machines = "Killer Machines",
				menu_killer_machines_desc = "BASIC: ##$basic##\nAll Sentry Gun modes deal ##+50## damage.\n\nACE: ##$pro##\nIncreases your Sentry Gun supply to ##2##."
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