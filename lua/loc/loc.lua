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
	
	local group_type = tweak_data.levels:get_ai_group_type()
	local federales = tweak_data.levels.ai_groups.federales
	local level = Global.level_data and Global.level_data.level_id

	if group_type == federales then
		loc:load_localization_file(ModPath .. "loc/federalesnames.txt")
	elseif level == "pex" or level == "skm_bex" or level == "bex" then --forcefully load beat cop and hrt names on these levels so that they dont get overridden by cd diff killfeed/hoplib/whatever
		-- log("head keeps spinnin")
		loc:load_localization_file(ModPath .. "loc/federalespersistentnames.txt")	
	end
	
end)

Hooks:Add("LocalizationManagerPostInit", "DeathVox_Overhaul", function(loc)
	if deathvox then
		if deathvox:IsTotalCrackdownEnabled() then
			loc:add_localized_strings({
				debug_interact_gage_assignment_take = "PRESS $BTN_INTERACT TO PICK UP THE PACKAGE",
				
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
			
			--medic
				menu_doctors_orders = "Doctor's Orders",
				menu_doctors_orders_desc = "NOT YET IMPLEMENTED",
				--menu_doctors_orders_desc = "BASIC: ##$basic##\nYou revive downed players ##30%## faster.\n\nACE: ##$pro##\nAfter you revive a player, you and the player you revived gain ##+50%## Damage Resistance for ##4## seconds.",
				menu_in_case_of_trouble = "In Case Of Trouble",
				menu_in_case_of_trouble_desc = "NOT YET IMPLEMENTED",
				--menu_in_case_of_trouble_desc = "BASIC: ##$basic##\nYour supply of First Aid Kits is increased to ##12##.\n\nACE: ##$pro##\nYour supply of First Aid Kits is increased to ##18##.",
				menu_checkup = "Checkup",
				menu_checkup_desc = "NOT YET IMPLEMENTED",
				--menu_checkup_desc = "BASIC: ##$basic##\nYour Doctor Bags restore ##1%## of a player's Maximum Health every ##2## seconds in a ##3## meter diameter.\n\nACE: ##$pro##\nRange increased to ##6## meters.",
				menu_life_insurance = "Life Insurance",
				menu_life_insurance_desc = "NOT YET IMPLEMENTED",
				--menu_life_insurance_desc = "BASIC: ##$basic##\nYour deployed First Aid Kits will be automatically used if a player is downed within ##5## meters, healing them and preventing the down.\nThis effect has a ##20## second cooldown per player.\n\nACE: ##$pro##\nCooldown reduced to ##10## seconds.",
				menu_outpatient = "Outpatient",
				menu_outpatient_desc = "NOT YET IMPLEMENTED",
				--menu_outpatient_desc = "BASIC: ##$basic##\nIncreases your Doctor Bag supply to ##2##.\n\nACE: ##$pro##\nIncreases your Doctor Bag supply to ##3##.",
				menu_preventative_care = "Preventative Care",
				menu_preventative_care_desc = "NOT YET IMPLEMENTED",
				--menu_preventative_care_desc = "BASIC: ##$basic##\nYour First Aid Kits and Doctor Bags provide the user with a Damage Absorption shield equal to ##100%## of their Health and Armor.\n\nACE: ##$pro##\nPlayers become Invulnerable for ##2## seconds when their Damage Absorption shields are broken.",
				
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
				
				--thief
				menu_classic_thievery = "Classic Thievery",
				menu_classic_thievery_desc = "BASIC: ##$basic##\nIncrease lockpicking speed by ##100%##.\n\nACE: ##$pro##\nYou take ##25%## longer to be detected while in Casing Mode.",
				menu_people_watching = "People Watching",
				menu_people_watching_desc = "BASIC: ##$basic##\nYou gain the ability to Mark enemies and pick up items while in Casing Mode.\n\nACE: ##$pro##\nNOT YET IMPLEMENTED",
--				menu_people_watching_desc = "BASIC: ##$basic##\nYou gain the ability to Mark enemies and pick up items while in Casing Mode.\n\nACE: ##$pro##\nWhile in Stealth, you automatically Mark all enemies within ##5## Meters.\nStanding still for ##3## seconds increases the radius to ##15## Meters.",
				menu_blackout = "Blackout",
				menu_blackout_desc = "BASIC: ##$basic##\nIncreases the ECM Jammer's duration by ##25%##.\n\nACE: ##$pro##\nIncreases the ECM Jammer's duration by an additional ##25%##, for a total of ##+50%##.",
				menu_tuned_out = "Tuned Out",
--				menu_tuned_out_desc = "BASIC: ##$basic##\nYou gain the ability to disable a camera from detecting your team for ##20## seconds. Only one camera may be disabled at a time.\n\nACE: ##$pro##\nDisable duration increases to ##30## seconds and an unlimited number of cameras may be disabled at one time.",
				menu_tuned_out_desc = "BASIC: ##$basic##\nYou gain the ability to disable a camera from detecting your team for ##20## seconds. Only one camera may be disabled at a time.\n\nACE: ##$pro##\nDisable duration increases to ##30## seconds.\n\nNOT YET IMPLEMENTED: An unlimited number of cameras may be disabled at one time.",
				menu_electronic_warfare = "Electronic Warfare",
				menu_electronic_warfare_desc = "BASIC: ##$basic##\nIncreases your ECM Jammer count to ##2##.\n\nACE: ##$pro##\nECM Jammers delay pagers while active.",
				menu_skeleton_key = "Skeleton Key",
				menu_skeleton_key_desc = "BASIC: ##$basic##\nIncreases Lockpick Speed by ##+100%## and gain the ability to Lockpick Safes.\n\nACE: ##$pro##\nYou now Lockpick Safes ##100%## faster and you gain the ability to open Electronic Locks.",
				
				
				--assassin
				menu_killers_notebook = "Killer's Notebook",
				menu_killers_notebook_desc = "NOT YET IMPLEMENTED",
--				menu_killers_notebook_desc = "BASIC: ##$basic##\nQuiet Weapons ADS ##90%## faster.\n\nACE: ##$pro##\nQuiet Weapons gain ##+20## Stability.",
				menu_good_hunting = "Good Hunting",
				menu_good_hunting_desc = "NOT YET IMPLEMENTED",
--				menu_good_hunting_desc = "BASIC: ##$basic##\nBows have all of their Arrows readied instead of in reserve.\n\nACE: ##$pro##\nCrossbows instantly Reload themselves after a Headshot.",
				menu_comfortable_silence = "Comfortable Silence",
				menu_comfortable_silence_desc = "NOT YET IMPLEMENTED",
--				menu_comfortable_silence_desc = "BASIC: ##$basic##\nQuiet Weapons gain ##+2## Concealment.\n\nACE: ##$pro##\nQuiet Weapons gain ##+4## Concealment.",
				menu_toxic_shock = "Toxic Shock",
				menu_toxic_shock_desc = "NOT YET IMPLEMENTED",
--				menu_toxic_shock_desc = "BASIC: ##$basic##\nSuccessfully Poisoning an enemy will also Poison enemies within a ##3##-meter radius.\n\nACE: ##$pro##\nPoison deals ##+100%## damage.",
				menu_professionals_choice = "Professional's Choice",
				menu_professionals_choice_desc = "BASIC: ##$basic##\nSilenced Weapons gain a ##+2% Fire Rate bonus## for every ##3## points of Detection Risk under ##35##, up to ##+10%##.\n\nACE: ##$pro##\nThe Fire Rate bonus is increased to ##+4%## and the maximum bonus is increased to ##+20%##.",
				menu_quiet_grave = "Quiet as the Grave",
				menu_quiet_grave_desc = "NOT YET IMPLEMENTED",
--				menu_quiet_grave_desc = "BASIC: ##$basic##\nQuiet Weapons deal ##+10%## Damage when attacking an enemy from behind.\n\nACE: ##$pro##\nQuiet Weapons also deal ##+10%## Damage when attacking an enemy that is not currently targeting you.",
				
			--enforcer
				menu_tender_meat = "Tender Meat",
				menu_tender_meat_desc = "BASIC: ##$basic##\nShotguns deal ##50%## of their Headshot damage on Body Shots against Non-Dozer enemies.\n\nACE: ##$pro##\nShotguns gain ##+40## Stability.",
				menu_heartbreaker = "Heartbreaker",
				menu_heartbreaker_desc = "BASIC: ##$basic##\nDouble Barreled Shotguns can use the Fire Selector to switch to ##Double Barrel Mode##, causing them to fire twice per shot.\n\nACE: ##$pro##\nEach shot in ##Double Barrel Mode## deals ##+100%## Damage when firing both barrels.",
				menu_shell_games = "Shell Games",
				menu_shell_games_desc = "BASIC: ##$basic##\nShotguns gain ##+20%## Reload Speed every time a shell is loaded.\nBonuses are lost upon finishing or cancelling the Reload.\n\nACE: ##$pro##\nSingle-Fire Shotguns have their Fire Rate increased by ##50%##.",
				menu_rolling_thunder = "Rolling Thunder",
				menu_rolling_thunder_desc = "BASIC: ##$basic##\nIncreases the Magazine Size of Automatic Shotguns by ##50%##.\n\nACE: ##$pro##\nMagazine Size bonus increased to ##100%##.",
				menu_point_blank = "Point Blank",
				menu_point_blank_desc = "BASIC: ##$basic##\nShotguns gain ##Armor Piercing##, ##Shield Piercing##, and ##Body Piercing## against enemies within ##2.5## meters.\n\nACE: ##$pro##\nShotguns deal ##+100%## Damage against enemies within ##2.5## meters.",
				menu_shotmaker = "Shotmaker",
				menu_shotmaker_desc = "BASIC: ##$basic##\nIncreases Shotgun Headshot Damage by ##+50%##.\n\nACE: ##$pro##\nShotgun Headshot Damage is increased by an additional ##+50%##, for a total of ##+100%##.",
			
			--heavy
				menu_collateral_damage = "Collateral Damage",
				menu_collateral_damage_desc = "BASIC: ##$basic##\n\n(BASIC NOT YET IMPLEMENTED)\n\nHeavy Weapons deal ##50%## of their damage in a ##0.25## meter radius around the bullet trajectory.\n\nACE: ##$pro##\nHeavy Weapons ADS ##50%## faster.",
				menu_death_grips = "Death Grips",
				menu_death_grips_desc = "BASIC: ##$basic##\nHeavy Weapons gain ##+4## Accuracy and ##+4## Stability for 8 seconds per kill, stacking up to ##10## times.\n\nACE: ##$pro##\nAccuracy bonus increased to ##+8##.",
				menu_bulletstorm = "Bulletstorm",
				menu_bulletstorm_desc = "BASIC: ##$basic##\nAmmo Bags placed by you grant players the ability to shoot without depleting their ammunition for up to ##5## seconds after interacting with it.\nThe more ammo players replenish, the longer the duration of the effect.\n\nACE: ##$pro##\nIncreases the base duration of the effect by up to ##15## seconds.",
				menu_lead_farmer = "Lead Farmer",
				menu_lead_farmer_desc = "BASIC: ##$basic##\nHeavy Weapons gain ##+1%## Reload Speed per kill on their next Reload, up to ##50%##.\n\nACE: ##$pro##\nIncreases the amount of Reload Speed per kill to ##2%## and the maximum amount of Reload Speed to ##100%##.",
				menu_armory_regular = "Armory Regular",
				menu_armory_regular_desc = "BASIC: ##$basic##\nIncreases your Ammo Bag supply to ##2##.\n\nACE: ##$pro##\nIncreases your Ammo Bag supply to ##3##.",
				menu_war_machine = "War Machine",
				menu_war_machine_desc = "BASIC: ##$basic##\nIncreases the Ammo Bag's Ammunition Stock bonus for Heavy Weapons to ##+100%##.\n\nACE: ##$pro##\nIncreases the Ammo Bag's Ammunition Stock bonus to ##+100%## for non-Heavy weapons and ##+200%## for Heavy Weapons.",
				
			
			--runner
				menu_hustle = "Hustle",
				menu_hustle_desc = "BASIC: ##$basic##\nYou can Sprint in any direction.\n\nACE: ##$pro##\nYour Stamina starts regenerating ##25%## earlier and ##+25%## faster.",
				menu_butterfly_bee = "Float Like A Butterfly",
				menu_butterfly_bee_desc = "BASIC: ##$basic##\nMelee Weapons can be swung and charged while Sprinting.\n\nACE: ##$pro##\nMelee Weapon damage increases your Movement Speed by ##+10%## for ##4## seconds.",
				menu_heave_ho = "Heave-Ho",
				menu_heave_ho_desc = "BASIC: ##$basic##\nYou throw Bags ##50%## farther.\n\nACE: ##$pro##\nYour Movement Speed Penalty for carrying a Bag is reduced by ##20%##.",
				menu_mobile_offense = "Mobile Offense",
				menu_mobile_offense_desc = "BASIC: ##$basic##\nYou can now Reload while Sprinting.\n\nACE: ##$pro##\nYou can now hip-fire weapons while Sprinting.",
				menu_escape_plan = "Escape Plan",
				menu_escape_plan_desc = "BASIC: ##$basic##\nWhen your Armor breaks, you gain ##100%## of your Stamina and gain ##+25%## Sprint Speed for ##4## seconds.\n\nACE: ##$pro##\nYou also gain ##+20%## Movement Speed for 4 seconds.",
				menu_leg_day = "Leg Day Enthusiast",
				menu_leg_day_desc = "BASIC: ##$basic##\nYou gain ##+10%## Movement Speed and ##+25%## Sprint Speed.\n\nACE: ##$pro##\nCrouching no longer reduces your Movement Speed.",
				
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
				menu_killer_machines_desc = "BASIC: ##$basic##\nAll Sentry Gun modes deal ##+50## damage.\n\nACE: ##$pro##\nIncreases your Sentry Gun supply to ##2##.",
				
				debug_interact_armor_plates_take = "Hold $BTN_INTERACT to take Armor Plates",
				hint_hud_already_has_armor_plates = "You already have Armor Plates!",
				hud_action_taking_armor_plates = "Taking Armor Plates...",
				menu_equipment_armor_kit = "Armor Plates",
				bm_equipment_armor_kit = "Armor Plates Bag",
				bm_equipment_armor_kit_desc = "Advanced shock-resistant armor inserts that provide +15% Damage Resistance and allow the user to go down one additional time before instantly being taken into custody. To use, hold $BTN_USE_ITEM on a suitable surface and press $BTN_INTERACT to equip.\n\nOnce deployed, the Armor Plates Bag can be used 4 times before disappearing. Remaining uses are visible within the bag.",
				bm_equipment_ammo_bag_desc = "Deployable ammunition container that refills expended ammunition and passively increases the holder's Ammunition Stock by 50%, even after using all charges. To use, hold $BTN_USE_ITEM on a suitable surface and press $BTN_INTERACT to refill ammunition.\n\nOnce deployed, the Ammo Bag can completely refill ammunition stocks 4 times before disappearing. Remaining uses are visible within the bag.",
				bm_equipment_first_aid_kit_desc = "Single-use healing deployable that fully restores the user's health. To use, hold $BTN_USE_ITEM on a suitable surface and press $BTN_INTERACT to heal.\n\nFirst Aid Kits can also be used to instantly revive and fully heal an incapacitated teammate by deploying a First Aid Kit within 1.5 meters of them.",
				hud_deploying_revive_fak = "Reviving $TEAMMATE_NAME...",
				hud_int_pick_electronic_lock = "Hold $BTN_INTERACT to hack the lock",
				hud_action_picking_electronic_lock = "Hacking the lock..."
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