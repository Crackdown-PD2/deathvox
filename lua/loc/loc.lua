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
		["hud_assault_murkywater_assault"] = "MURKYWATER ASSAULT IN PROGRESS",
		["hud_assault_murkywater_cover"] = "STAND YOUR GROUND",
		["hud_assault_akan_assault"] = "Идёт штурм наёмников",
		["hud_assault_akan_cover"] = "Оставайтесь в укрытии",
		["hud_assault_classic_assault"] = "POLICE ASSAULT IN PROGRESS",
		["hud_assault_classic_cover"] = "STAY IN COVER",
		["hud_assault_zombie_assault"] = "I SEE YOU",
		["hud_assault_zombie_cover"] = "NO ESCAPE NO ESCAPE NO ESCAPE",
		["hud_assault_gsg9_assault"] = "POLIZEIVORSTOẞ IM GANGE",
		["hud_assault_gsg9_cover"]	= "IN DECKUNG BLEIBEN",
		
		["cdmenu_staticrecoil"] = "Static Recoil",
		["cdmenu_staticrecoil_help"] = "Disables the automatic recoil compensation, making you have to manually pull down on the mouse to adjust your aim after you stop firing.",
		["cdmenu_holdtofire"] = "HOLD TO FIRE SINGLE-FIRE WEAPONS",
		["cdmenu_holdtofire_help"] = "Allows players to fire single-fire weapons at their maximum firerate by Fire button.",
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
	
	if group_type == murkywater then
		loc:load_localization_file(ModPath .. "loc/murkynames.txt")
	elseif level == "bph" or level == "vit" or level == "des" or level == "pbr" then 
		loc:load_localization_file(ModPath .. "loc/murkypersistentnames.txt")
	end	
end)

Hooks:Add("LocalizationManagerPostInit", "DeathVox_Overhaul", function(loc)
	if deathvox then
		if deathvox:IsTotalCrackdownEnabled() then
			local weapon_class_icon_data = {
				heavy = {
					character = "─",
					macro = "$ICN_HVY",
				},
				grenade = {
					character = "┼",
					macro = "$ICN_GRN"
				},
				area_denial = {
					character = "═",
					macro = "$ICN_ARD"
				},
				throwing = {
					character = "╤",
					macro = "$ICN_THR"
				},
				specialist = {
					character = "╥",
					macro = "$ICN_SPC"
				},
				shotgun = {
					character = "╦",
					macro = "$ICN_SHO"
				},
				saw = {
					character = "╧",
					macro = "$ICN_SAW"
				},
				rapidfire = {
					character = "╨",
					macro = "$ICN_RPF"
				},
				quiet = {
					character = "╩",
					macro = "$ICN_QUT"
				},
				precision = {
					character = "╪",
					macro = "$ICN_PRE"
				},
				poison = {
					character = "╫",
					macro = "$ICN_POI"
				},
				melee = {
					character = "╬",
					macro = "$ICN_MEL"
				}
			}

			--bit of extra overhead here for tcd icons
			LocalizationManager._orig_text = LocalizationManager.text
			function LocalizationManager:text(...)
				local result = {self:_orig_text(...)}
				for class_id,weapon_icon_data in pairs(weapon_class_icon_data) do 
					if result[1] and weapon_icon_data and weapon_icon_data.macro then 
						result[1] = string.gsub(result[1],weapon_icon_data.macro,weapon_icon_data.character)
					end
				end
				return unpack(result)
			end
			
			
--			local interact_keybind = utf8.to_upper(loc:btn_macro("use_item")) 
--			local grenade_keybind = utf8.to_upper(loc:btn_macro("throw_grenade")) 
--apparently keybind macros aren't active in the throwables descriptions, but also controllermanager isn't initialized in time for this
			
			local cursed_error = "oopsie whoopsie!\nuwu\nwe made a fucky wucky!!1 a wittle fucko boingo! the code monkies at our headquarters are working VEWY HAWD to fix this!" --preliminary research suggests that using this as an localization error string will make users 4206.9% more likely to report normally insignificant minor localization errors. i apologize for nothing. -offy
			--i did not spot this earlier and i can say with 100% certainty that you have nothing to apologize for, offy <3
			
			
			loc:add_localized_strings({
				cursed_error = cursed_error,
				debug_interact_gage_assignment_take = "PRESS $BTN_INTERACT TO PICK UP THE PACKAGE",
				--weapon stuff
				
				--shotgun ammo
				bm_wp_upg_a_custom_free = "Iron Hand Buckshot",
				bm_wp_upg_a_custom_free_desc = "Makes all pellets that hit enemies deal individual damage, allowing for damage to stack. Halves pellet count.",
				
				bm_wp_striker_b_long_achievment = "Kill ##$progress## more Bulldozers with any shotgun using the 000 Buck or Iron Hand Buckshot ammo types.", --not sure if this actually will display progress 
			
				--skilltree sub-tree names
				st_menu_dallas_taskmaster = "Taskmaster",
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
			
			--deployable equipment
				hud_int_equipment_sensor_mode_trip_mine = "Press $BTN_INTERACT to edit Trip Mine",
				hud_int_equipment_normal_mode_trip_mine = "Press $BTN_INTERACT to edit Trip Mine",
				debug_interact_trip_mine = cursed_error,
				tripmine_payload_explosive = "Explosive Mode",
				tripmine_payload_incendiary = "Incendiary Mode",
				tripmine_payload_concussive = "Concussive Mode",
				tripmine_payload_sensor = "Sensor Mode",
				tripmine_trigger_detonate = "Detonate Now",
				tripmine_trigger_special = "Special Targeting",
				tripmine_trigger_default = "Default Targeting",
				tripmine_payload_recover = "Retrieve",
				tripmine_menu_exit = "Exit",
				sentry_mode_standard = "Standard Mode",
				sentry_mode_overwatch = "Overwatch Mode",
				sentry_mode_manual = "Manual Mode",
				sentry_ammo_ap = "AP Ammo",
				sentry_ammo_he = "HE Ammo",
				sentry_ammo_taser = "Taser Ammo",
				sentry_ammo_standard = "Standard Ammo",
				sentry_retrieve = "Retrieve",
				
				hud_deploy_valid_help = "Invalid aim location",
				
				hud_interact_edit_sentry_gun = "Hold $BTN_INTERACT to change Sentry mode",
				hud_action_editing_sentry_gun = "Changing Sentry mode...", --not used
				hud_interact_pickup_sentry_gun = "Hold $BTN_INTERACT to pick up sentry gun",
				debug_interact_armor_plates_take = "Hold $BTN_INTERACT to take Armor Plates",
				hud_equipment_equipping_armor_kit = "Deploying Armor Plates...",
				hint_hud_already_has_armor_plates = "You already have Armor Plates!",
				hud_action_taking_armor_plates = "Taking Armor Plates...",
				menu_equipment_armor_kit = "Armor Plates",
				bm_equipment_armor_kit = "Armor Plates Bag",
				bm_equipment_armor_kit_desc = "Advanced shock-resistant armor inserts that provide +15% Damage Resistance and allow the user to go down one additional time before instantly being taken into custody. To use, hold $BTN_USE_ITEM on a suitable surface and press $BTN_INTERACT to equip.\n\nOnce deployed, the Armor Plates Bag can be used 4 times before disappearing. Remaining uses are visible within the bag.",
				bm_equipment_ammo_bag_desc = "Deployable ammunition container that refills expended ammunition and passively increases the holder's Ammunition Stock by 50%, even after using all charges. To use, hold $BTN_USE_ITEM on a suitable surface and press $BTN_INTERACT to refill ammunition.\n\nOnce deployed, the Ammo Bag can completely refill ammunition stocks 4 times before disappearing. Remaining uses are visible within the bag.",
				bm_equipment_first_aid_kit_desc = "Single-use healing deployable that fully restores the user's health. To use, hold $BTN_USE_ITEM on a suitable surface and press $BTN_INTERACT to heal.\n\nFirst Aid Kits can also be used to instantly revive and fully heal an incapacitated teammate by deploying a First Aid Kit within 1.5 meters of them.",
				
				debug_silent_sentry_gun = "Friendship Collar",
				hud_deploying_friendship_collar = "Converting $TARGET_UNIT...",
				bm_equipment_sentry_gun_silent = "Friendship Collar",
				bm_equipment_sentry_gun_silent_desc = "A \"compliance device\" that can convert a non-special enemy into a Joker to fight for you.\n(It's not actually dangerous, but don't tell the cops that.)\n\nTo convert an enemy, get within melee range and hold $BTN_USE_ITEM while targeting them. Subdued enemies that have cuffed themselves will be converted instantly. Jokers have 50% Damage Resistance and will follow you closely, fighting to protect you.\n\nYou can only have one Joker at a time. Jokers do not count as Hostages.",
				
				debug_trip_mine = "Shaped Charges",
				bm_equipment_trip_mine = "Shaped Charges",
				bm_equipment_trip_mine_desc = "Shaped Charges are explosive tools that can destroy specific obstacles or open containers. Hold $BTN_INTERACT on an object's displayed weak point to prime it with a Shaped Charge.\n\nWarning: Shaped Charges will only activate when all of an object's weak points are primed.",
				hud_deploying_revive_fak = "Reviving $TARGET_UNIT...",
				
				hud_enemy_generic = "Enemy",
				hud_teammate_generic = "Teammate",
				
				bm_wpn_prj_four_desc = "$ICN_THR Throwing weapons coated in $ICN_POI Poison that deals 150 damage per 0.5 seconds for 3 seconds. $ICN_POI Poison damage can stack and can incapacitate targets.",
				bm_wpn_prj_ace_desc = "$ICN_THR Throwing weapons disguised as playing cards that deal 200 damage. They can't penetrate body armor, but they come in large amounts.",
				bm_wpn_prj_target_desc = "$ICN_THR Throwing weapons that deal 800 damage.",
				bm_wpn_prj_hur_desc = "$ICN_THR Throwing weapons that deal 1400 damage and can punch through Body Armor.",
				bm_wpn_prj_jav_desc = "$ICN_THR Throwing weapons that deal 4000 damage and can slice through Body Armor.",
				bm_grenade_frag_desc = "$ICN_GRN Grenade that deals 300 damage in a 10m radius.\nEach enemy hit has a 40% chance to take Critical damage from the explosion.",
				bm_grenade_frag_com_desc = "$ICN_GRN Grenade that deals 1000 damage in a 5m radius.",
				bm_dynamite_desc = "$ICN_GRN Grenade that deals 5000 damage in a 10m radius. Reduced stock.",
				bm_grenade_dada_com_desc = "(CHANGES NOT YET IMPLEMENTED)\n\n$ICN_GRN Grenade that deals 400 damage in a 2m radius and then splits into 7 miniature grenades that also deal 400 damage in a 2m radius.",
				bm_concussion_desc = "(CHANGES NOT YET IMPLEMENTED)\n\n$ICN_GRN Grenade that deals no damage, but Stuns enemies in an 8m radius for 4 seconds.\nStunned enemies suffer a -50% Accuracy penalty for 5 seconds after being Stunned.",
				bm_grenade_molotov_desc = "(CHANGES NOT YET IMPLEMENTED)\n\n$ICN_GRN Grenade that creates a 2.5m radius pool of flame for 15 seconds that deals 250 damage (50 vs allies) every 0.5 seconds.",
				bm_grenade_fir_com_desc = "(CHANGES NOT YET IMPLEMENTED)\n\n$ICN_GRN Grenade that creates a 1m radius pool of flame for 30 seconds that deals 250 damage (50 vs allies) every 0.5 seconds.",
				
				bm_equipment_sentry_gun_desc = "Deployable weapon that will automatically attack nearby targets. Sentry Guns have infinite ammunition, will be ignored by enemies, and have a Radial Menu with the following options:\nBasic Ammo has excellent damage output, but no special properties.\nAP Ammo has good damage output and punches through Body Armor and Shields.\nTaser Ammo deals little damage, but electrocutes enemies.\nManual Mode causes the Sentry Gun to aim where you do.\nOverwatch Mode can only target Snipers, but has infinite Range and perfect Accuracy.\nRetrieve returns the Sentry Gun to your Inventory.\n\nSentry Guns generate Heat during combat, inflicting -1% Damage Reduction per second, up to -75%. Heat can be vented by opening a Sentry Gun's Radial Menu.\n\nTo deploy a Sentry Gun, hold $BTN_USE_ITEM on a suitable surface.\n\nTo configure a deployed Sentry Gun, approach it and hold $BTN_INTERACT to open the Radial Menu. To choose an option in a Radial Menu, highlight an option via aiming and release $BTN_INTERACT.\n\nYou can also open the Radial Menu to configure your Sentry Guns while they're still in your inventory by holding $BTN_USE_ITEM and $BTN_INTERACT at the same time.",
				debug_trip_mine_throwable = "Trip Mine",
				bm_grenade_tripmine = "Trip Mine Throwable",
				bm_grenade_tripmine_desc = "Static trap that can be configured for a variety of purposes and effects. In their default setting, Trip Mines deal 1500 explosive damage in an area when any enemy passes by.\n\nPress [$BTN_GRENADE] to place a Trip Mine on a suitable surface.\n\nTo configure a placed Trip Mine, hold [$BTN_INTERACT] to access a Radial Menu with the following options:\n\nExplosive Mode deals 1500 explosive damage in an area.\n\nIncendiary Mode creates a 2.5m radius pool of flame for 15 seconds that deals 250 damage (50 vs allies) every 0.5 seconds.\nConcussive Mode stuns enemies for 4 seconds. Non-lethal.\nSensor Mode Marks enemies instead of detonating. Marking enemies does not consume the Trip Mine.\nDefault Targeting will trigger the Trip Mine on any enemy.\nSpecial Targeting will only trigger the Trip Mine on Special Enemies.\nRetrieve returns the Trip Mine to your inventory.\n\nYou can also open the Radial Menu to configure your Trip Mines while they're still in your Inventory by holding [BTN_GRENADE] and [$BTN_INTERACT] at the same time.", --needs macros
				
				hud_deploying_tripmine_preview = "Ready to deploy $EQUIPMENT",
				hud_sentry_gun_vent_heat = "Hold $BTN_INTERACT to vent sentrygun heat",
				hud_action_sentry_gun_vent_heat = "Venting sentrygun...",
			--misc
				hud_int_pick_electronic_lock = "Hold $BTN_INTERACT to hack the lock",
				hud_action_picking_electronic_lock = "Hacking the lock...",
				
				hud_sociopath_combo_count = "%ix combo", --sociopath hud combo counter; "%i" represents the number of kills in the combo
				
			--skills:
				
			--taskmaster
				menu_zip_it = "Zip It",
				menu_zip_it_desc = "BASIC: ##$basic##\nCivilians are ##intimidated by the noise you make##. Shouting intimidates all Civilians within ##10## meters of the target.\n\nACE: ##$pro##\nIncreases your supply of Cable Ties to ##20##.",
				menu_pack_mules = "Pack Mules",
				menu_pack_mules_desc = "BASIC: ##$basic##\nYour team's Civilian Hostages ##can carry Bags##.\n\nACE: ##$pro##\nYour team's Civilian Hostages move ##+20% faster##.",
				menu_stay_down = "Stay Down",
				menu_stay_down_desc = "BASIC: ##$basic##\nYour team's Civilians are ##invulnerable while stationary##.\n\nACE: ##$pro##\nYour team's Civilian Hostages ##will not flee## when rescued.",
				menu_lookout_duty = "Lookout Duty",
				menu_lookout_duty_desc = "BASIC: ##$basic##\nEnemies within ##10## Meters of your team's Hostages are automatically Marked.\n\nACE: ##$pro##\nEnemies within ##10## meters of your team's Hostages take ##+10%## damage from all sources.",
				menu_leverage = "Leverage",
				menu_leverage_desc = "BASIC: ##$basic##\nYour team's Hostages grant ##+10%## Damage Resistance to teammates within ##0.25## meters.\n\nACE: ##$pro##\nYour team's Hostages also grant ##+10%## Damage Resistance to teammates within ##5## meters, and can stack up to ##+20%## when a teammate is within ##0.25## meters.",
				menu_false_idol = "False Idol",
				menu_false_idol_desc = "BASIC: ##$basic##\nYour team's Hostages ##release all teammates in custody## when traded.\n\nYou can have up to ##2## Civilian Hostages following you at once.\n\nACE: ##$pro##\nEach of your team's Hostages will ##fake surrendering once## upon being traded, releasing your teammates from custody without turning themselves in.\n\nYou can have up to ##3## Civilian Hostages following you at once.",
				
			--marksman
				menu_point_and_click = "Point and Click",
				menu_point_and_click_desc = "BASIC: ##$basic##\n$ICN_PRE Precision Weapons gain ##+0.5%## Damage per kill, up to ##250%##. All stacks are lost upon missing.\n\nACE: ##$pro##\n$ICN_PRE Precision Weapons ADS ##90%## faster.",
				menu_tap_the_trigger = "Tap the Trigger",
				menu_tap_the_trigger_desc = "BASIC: ##$basic##\n$ICN_PRE Precision Weapons also gain ##+1%## Rate of Fire per stack of Point and Click, up to ##+50%##.\n\nACE: ##$pro##\nMaximum Rate of Fire Bonus increased to ##+100%##.",
				menu_potential_exponential = "Potential Exponential",
				menu_potential_exponential_desc = "BASIC: ##$basic##\nYou generate an additional stack of Point And Click per kill if you haven't missed a shot between kills.\n\nACE: ##$pro##\nThe additional stack of Point And Click is multiplied by how many kills you've made without missing.",
				
				menu_this_machine = "This Machine",
				menu_this_machine_desc = "BASIC: ##$basic##\n$ICN_PRE Precision Weapons also gain ##+0.5%## Reload Speed per stack of Point and Click, up to ##+25%##.\n\nACE: ##$pro##\nMaximum Reload Speed Bonus increased to ##+50%##.",
				
				menu_magic_bullet = "Magic Bullet",
				menu_magic_bullet_desc = "BASIC: ##$basic##\nKilling an enemy with a Headshot from a $ICN_PRE Precision Weapon adds ##1## bullet to your reserve ammunition. This effect does not activate for Bows or Crossbows.\n\nACE: ##$pro##\nThe bullet is added to your current Magazine instead of your reserves.",
				
				menu_investment_returns = "Investment Returns",
				menu_investment_returns_desc = "BASIC: ##$basic##\nHeadshots with $ICN_PRE Precision Weapons generate an additional stack of Point And Click.\n\nACE: ##$pro##\nPoint And Click's maximum bonus increases to ##+500%##.",
			
				--unused--
				menu_mulligan = "Mulligan",
				menu_mulligan_desc = "BASIC: ##$basic##\nAfter missing, you gain a ##1-second## grace period where you still benefit from your Point and Click stacks. Killing an enemy during the grace period will prevent your stacks from being lost.\n\nACE: ##$pro##\nThe grace period is extended to ##1.5 seconds##.",
				--unused--
			
			--medic
				menu_doctors_orders = "Doctor's Orders",
				menu_doctors_orders_desc = "BASIC: ##$basic##\nYou revive downed players ##30%## faster.\n\nACE: ##$pro##\nAfter you revive a player, you and the player you revived gain ##+50%## Damage Resistance for ##4## seconds.",
				menu_in_case_of_trouble = "In Case Of Trouble",
				menu_in_case_of_trouble_desc = "BASIC: ##$basic##\nYour supply of First Aid Kits is increased to ##12##.\n\nACE: ##$pro##\nYour supply of First Aid Kits is increased to ##18##.",
				menu_checkup = "Checkup",
				menu_checkup_desc = "BASIC: ##$basic##\nYour Doctor Bags restore ##1%## of a player's Maximum Health every ##2## seconds in a ##3## meter diameter.\n\nACE: ##$pro##\nRange increased to ##6## meters.\n\nNote: Healing effect cannot stack. Requires line of sight to the Doctor Bag in question.",
				menu_life_insurance = "Life Insurance",
				menu_life_insurance_desc = "BASIC: ##$basic##\nYour deployed First Aid Kits will be automatically used if a player is downed within ##5## meters, healing them and preventing the down.\nThis effect has a ##20## second cooldown per player.\n\nACE: ##$pro##\nCooldown reduced to ##10## seconds.\n\nNote: This effect directly interacts with Crook's Borrowed Time, allowing users to prevent going down at the end of the grace period with Life Insurance's effect.",
				menu_outpatient = "Outpatient",
				menu_outpatient_desc = "BASIC: ##$basic##\nIncreases your Doctor Bag supply to ##2##.\n\nACE: ##$pro##\nIncreases your Doctor Bag supply to ##3##.",
				menu_preventative_care = "Preventative Care",
				menu_preventative_care_desc = "BASIC: ##$basic##\nYour First Aid Kits and Doctor Bags provide the user with a Damage Absorption shield equal to ##100%## of their Health and Armor.\n\nACE: ##$pro##\nPlayers become Invulnerable for ##2## seconds when their Damage Absorption shields are broken.\n\nNote: Shield does not decay over time. Shield absorbs damage on a 1:1 ratio of Shield Amount : Damage Taken.",

			--chief
				menu_protect_and_serve = "Protect and Serve",
				menu_protect_and_serve_desc = "BASIC: ##$basic##\nIf one of your Jokers is nearby and you are targeted by a Cloaker or shocked by a Taser, your Joker will tackle the Special Enemy and knock them down. This can only occur once every ##30## seconds.\n\nACE: ##$pro##\nIncreases your Friendship Collar supply to ##12##.",
				
				menu_standard_of_excellence = "Standard of Excellence",
				menu_standard_of_excellence_desc = "BASIC: ##$basic##\nJokers regenerate ##2.5%## of their Maximum Health per second and their Damage Resistance increases from ##80%## to ##90%##.\n\nACE: ##$pro##\nJokers no longer flinch from taking damage and cannot be knocked down.",
				
				menu_maintaining_the_peace = "Maintaining the Peace",
				menu_maintaining_the_peace_desc = "BASIC: ##$basic##\nShouting at a Special Enemy causes your Jokers to focus them as a priority target.\n\nACE: ##$pro##\nIf you have an open Joker slot, shouting at a Standard Enemy will force them to instantly surrender. You can only have ##one## instantly surrendered enemy at a time.",
				
				menu_order_through_law = "Order through Law",
				menu_order_through_law_desc = "BASIC: ##$basic##\nJokers equipped with Shotguns will use melee attacks on enemies within range, dealing high damage and staggering Shields.\n\nACE: ##$pro##\nJokers equipped with Shotguns will knock down enemies with every shot.",
				
				menu_justice_with_mercy = "Justice with Mercy",
				menu_justice_with_mercy_desc = "BASIC: ##$basic##\nJokers equipped with Assault Rifles gain ##+90%## Accuracy and ##Armor Piercing##.\n\nACE: ##$pro##\nJokers equipped with Assault Rifles gain ##+100%## range.",
				
				menu_service_above_self = "Service above Self",
				menu_service_above_self_desc = "BASIC: ##$basic##\nIncreases the maximum number of Jokers you can have active at one time to ##2##.\n\nACE: ##$pro##\nEach Joker gains ##+1%## damage every 30 seconds they're active, up to ##+25%##.",
			
			--enforcer
				menu_tender_meat = "Tender Meat",
				menu_tender_meat_desc = "BASIC: ##$basic##\n$ICN_SHO Shotguns deal ##50%## of their Headshot damage on Body Shots against against ##Standard Enemies##.\n\nACE: ##$pro##\n$ICN_SHO Shotguns gain ##+40## Stability.\n\nNOTE: ##Standard Enemies## are non-Special enemies, aka Lights and Heavies but not Cloakers or Tasers.",
				menu_heartbreaker = "Heartbreaker",
				menu_heartbreaker_desc = "BASIC: ##$basic##\nDouble Barreled $ICN_SHO Shotguns can use the Fire Selector to switch to ##Double Barrel Mode##, causing them to fire twice per shot.\n\nACE: ##$pro##\nEach shot in ##Double Barrel Mode## deals ##+200%## Damage when firing both barrels.",
				menu_shell_games = "Shell Games",
				menu_shell_games_desc = "BASIC: ##$basic##\n$ICN_SHO Shotguns gain ##+20%## Reload Speed and gain an additional ##+20%## Reload Speed for every shell loaded into the Magazine.\nBonuses are lost upon finishing or cancelling the Reload.\n\nACE: ##$pro##\nSingle-Fire $ICN_SHO Shotguns have their Fire Rate increased by ##50%##.",
				menu_rolling_thunder = "Rolling Thunder",
				menu_rolling_thunder_desc = "BASIC: ##$basic##\nIncreases the Magazine Size of Automatic $ICN_SHO Shotguns by ##50%##.\n\nACE: ##$pro##\nMagazine Size bonus increased to ##100%##.",
				menu_point_blank = "Point Blank",
				menu_point_blank_desc = "BASIC: ##$basic##\n$ICN_SHO Shotguns gain ##Armor Piercing##, ##Shield Piercing##, and ##Body Piercing## against enemies within ##3## meters.\n\nACE: ##$pro##\n$ICN_SHO Shotguns deal ##+100%## Damage against enemies within ##3## meters.",
				menu_shotmaker = "Grand Brachial",
				menu_shotmaker_desc = "BASIC: ##$basic##\n$ICN_SHO Shotguns deal ##+100%## Headshot damage.\n\nACE: ##$pro##\n$ICN_SHO Shotguns deal ##50%## of their Headshot Damage on Body Shots against ##Shields, Medics, Tasers, Grenadiers and Cloakers##.",
				
			--heavy
				menu_collateral_damage = "Collateral Damage",
				menu_collateral_damage_desc = "BASIC: ##$basic##\n$ICN_HVY Heavy Weapons deal ##50%## of their damage in a ##0.25## meter radius around the bullet trajectory.\n\nACE: ##$pro##\n$ICN_HVY Heavy Weapons ADS ##50%## faster.",
				menu_death_grips = "Death Grips",
				menu_death_grips_desc = "BASIC: ##$basic##\n$ICN_HVY Heavy Weapons gain ##+4## Accuracy and ##+4## Stability for 8 seconds per kill, stacking up to ##10## times.\n\nACE: ##$pro##\nAccuracy bonus increased to ##+8##.",
				menu_bulletstorm = "Bulletstorm",
				menu_bulletstorm_desc = "BASIC: ##$basic##\nAmmo Bags placed by you grant players the ability to shoot without depleting their ammunition for up to ##5## seconds after interacting with it.\nThe more ammo players replenish, the longer the duration of the effect.\n\nACE: ##$pro##\nIncreases the base duration of the effect by up to ##15## seconds.",
				menu_lead_farmer = "Lead Farmer",
				menu_lead_farmer_desc = "BASIC: ##$basic##\n$ICN_HVY Heavy Weapons load ##20%## of their Magazine every ##2## seconds while stowed.\n\nACE: ##$pro##\n$ICN_HVY Heavy Weapons with a deployed Bipod load ##20%## of their Magazine every ##2## seconds.",
				menu_armory_regular = "Armory Regular",
				menu_armory_regular_desc = "BASIC: ##$basic##\nIncreases your Ammo Bag supply to ##2##.\n\nACE: ##$pro##\nIncreases your Ammo Bag supply to ##3##.",
				menu_war_machine = "War Machine",
				menu_war_machine_desc = "BASIC: ##$basic##\nIncreases the Ammo Bag's Ammunition Stock bonus for $ICN_HVY Heavy Weapons to ##+100%##.\n\nACE: ##$pro##\nIncreases the Ammo Bag's Ammunition Stock bonus to ##+100%## for non-Heavy weapons and ##+200%## for $ICN_HVY Heavy Weapons.",
				
			--runner
				menu_hustle = "Hustle",
				menu_hustle_desc = "BASIC: ##$basic##\nYou can Sprint in any direction.\n\nACE: ##$pro##\nYour Stamina starts regenerating ##25%## earlier and ##+25%## faster.",
				menu_butterfly_bee = "Float Like A Butterfly",
				menu_butterfly_bee_desc = "BASIC: ##$basic##\n$ICN_MEL Melee Weapons can be swung and charged while Sprinting.\n\nACE: ##$pro##\nSwinging your $ICN_MEL Melee Weapon when aiming at an enemy within ##5## meters causes you to lunge forward into striking range.\n\nThis ability has a ##5## second cooldown, but $ICN_MEL Melee Weapon kills refresh the cooldown instantly.",
				menu_heave_ho = "Heave-Ho",
				menu_heave_ho_desc = "BASIC: ##$basic##\nYou throw Bags ##50%## farther.\n\nACE: ##$pro##\nYour Movement Speed Penalty for carrying a Bag is reduced by ##20%##, and you can ##Sprint while carrying a Bag##.",
				menu_mobile_offense = "Mobile Offense",
				menu_mobile_offense_desc = "BASIC: ##$basic##\nYou can now Reload while Sprinting.\n\nACE: ##$pro##\nYou can now hip-fire weapons while Sprinting.",
				menu_escape_plan = "Escape Plan",
				menu_escape_plan_desc = "BASIC: ##$basic##\nWhen your Armor breaks, you gain ##100%## of your Stamina and gain ##+25%## Sprint Speed for ##4## seconds.\n\nACE: ##$pro##\nYou also gain ##+20%## Movement Speed for ##4## seconds.",
				menu_leg_day = "Leg Day Enthusiast",
				menu_leg_day_desc = "BASIC: ##$basic##\nYou gain ##+10%## Movement Speed and ##+25%## Sprint Speed.\n\nACE: ##$pro##\nCrouching no longer reduces your Movement Speed.",
				menu_wave_dash = "Wave Dash",
				menu_wave_dash_desc = "BASIC: ##$basic##\nWhile in midair, pressing your ##Jump## button will cause you to dash in the direction you are currently moving and holding your ##Crouch## button causes you to dive to the ground and avoid Fall Damage from non-lethal heights. These actions cost ##5%## of your maximum Stamina.\n\nACE: ##$pro##\nYou can now dash in any direction. Diving no longer costs Stamina.\n\n##Mission Complete!##",
				
			--gunner
				menu_spray_and_pray = "Spray & Pray",
				menu_spray_and_pray_desc = "BASIC: ##$basic##\n$ICN_RPF Rapid Fire weapons gain a ##10%## chance to ##Critical Hit and deal 2x damage##.\n\nACE: ##$pro##\n$ICN_RPF Rapid Fire weapons now pierce Body Armor.",
				menu_money_shot = "Money Shot",
				menu_money_shot_desc = "BASIC: ##$basic##\n$ICN_RPF Rapid Fire weapons gain a special overpressure round at the end of every fully loaded Magazine that is guaranteed to be a ##Critical Hit## and increases the Reload Speed of empty Magazines by ##+50%##.\n\nACE: ##$pro##\nThe overpressure round gains ##Armor Piercing, Shield Piercing, and Body Piercing## properties.",
				menu_shot_grouping = "Shot Grouping",
				menu_shot_grouping_desc = "BASIC: ##$basic##\n$ICN_RPF Rapid Fire weapons ADS ##+90%## faster and gain ##+40## Accuracy and Stability while ADSing.\n\nACE: ##$pro##\n$ICN_RPF Rapid Fire weapons gain ##+1%## Critical Hit chance for ##4## seconds when hitting an enemy with a Headshot, stacking up to ##+10%##.",
				menu_prayers_answered = "Prayers Answered",
				menu_prayers_answered_desc = "BASIC: ##$basic##\n$ICN_RPF Rapid Fire weapons have their Critical Hit chance increased by ##+5%##, for a total of ##+15%##.\n\nACE: ##$pro##\n$ICN_RPF Rapid Fire weapons have their Critical Hit chance further increased by ##+10%##, for a total of ##+25%##.",
				menu_making_miracles = "Find the Crit",
				menu_making_miracles_desc = "BASIC: ##$basic##\nIncreases the Critical Hit damage multiplier to ##2.5x##.\n\nACE: ##$pro##\nFurther increases the Critical Hit damage multiplier to ##3x##.",
				menu_close_enough = "Close Enough",
				menu_close_enough_desc = "BASIC: ##$basic##\n$ICN_RPF Rapid Fire bullets that strike hard surfaces ##ricochet## towards the closest enemy, dealing ##50%## damage.\n\nACE: ##$pro##\nCritical Hits that ricochet do not have a damage penalty.",
				
			--engineer
				menu_digging_in = "Digging In",
				menu_digging_in_desc = "BASIC: ##$basic##\nYour Sentry Guns vent ##1## Heat every ##6## seconds.\n\nACE: ##$pro##\nYour Sentry Guns become armored, rendering them almost completely invulnerable and making them good for use as cover.",
				menu_advanced_rangefinder = "Advanced Targeting",
				menu_advanced_rangefinder_desc = "BASIC: ##$basic##\nSentry Guns gain ##+100%## Range and Accuracy.\n\nACE: ##$pro##\nOverwatch Mode will target all Special Enemy types in addition to Snipers.",
				menu_targeting_matrix = "Little Helpers",
				menu_targeting_matrix_desc = "BASIC: ##$basic##\nSentry Guns deal ##+25%## damage while in Manual Mode and instantly Highlight enemies that they aim at.\n\nACE: ##$pro##\nYou deal ##+25%## damage to enemies Highlighted by Sentry Guns in Manual Mode.",
				menu_wrangler = "Wrangler",
				menu_wrangler_desc = "BASIC: ##$basic##\nSentry Guns generate zero Heat while in Manual Mode.\n\nACE: ##$pro##\nSentry Guns in Manual Mode gain ##+100%## Headshot Damage.",
				menu_hobarts_funnies = "Hobart's Funnies",
				menu_hobarts_funnies_desc = "BASIC: ##$basic##\nSentry Guns using AP or Taser gain ##+25%## Fire Rate.\n\nACE: ##$pro##\nFire Rate bonus increased to ##+50%##.",
				menu_killer_machines = "Killer Machines",
				menu_killer_machines_desc = "BASIC: ##$basic##\nAll Sentry Gun modes deal ##+50## damage.\n\nACE: ##$pro##\nIncreases your Sentry Gun supply to ##2##.",
				
			--thief
				menu_classic_thievery = "Classic Thievery",
				menu_classic_thievery_desc = "BASIC: ##$basic##\nIncrease lockpicking speed by ##100%##.\n\nACE: ##$pro##\nYou take ##25%## longer to be detected while in Casing Mode.",
				menu_people_watching = "People Watching",
				menu_people_watching_desc = "BASIC: ##$basic##\nYou gain the ability to Mark enemies and pick up items while in Casing Mode.\n\nACE: ##$pro##\nWhile in Stealth, you automatically Mark enemies and Civilians within ##5## Meters.\nStanding still for ##3## seconds increases the radius to ##15## Meters.",
				menu_blackout = "Blackout",
				menu_blackout_desc = "BASIC: ##$basic##\nIncreases the ECM Jammer's duration by ##25%##.\n\nACE: ##$pro##\nIncreases the ECM Jammer's duration by an additional ##25%##, for a total of ##+50%##.",
				menu_tuned_out = "Tuned Out",
				menu_tuned_out_desc = "BASIC: ##$basic##\nYou gain the ability to disable a camera from detecting your team for ##20## seconds. Only one camera may be disabled at a time.\n\nACE: ##$pro##\nDisable duration increases to ##30## seconds.\n\nAn unlimited number of cameras may be disabled at one time.",
				menu_electronic_warfare = "Electronic Warfare",
				menu_electronic_warfare_desc = "BASIC: ##$basic##\nIncreases your ECM Jammer count to ##2##.\n\nACE: ##$pro##\nECM Jammers delay pagers while active.",
				menu_skeleton_key = "Skeleton Key",
				menu_skeleton_key_desc = "BASIC: ##$basic##\nIncreases Lockpick Speed by ##+100%## and gain the ability to Lockpick Safes.\n\nACE: ##$pro##\nYou now Lockpick Safes ##100%## faster and you gain the ability to open Electronic Locks.",
				
			--assassin
				menu_killers_notebook = "Killer's Notebook",
				menu_killers_notebook_desc = "BASIC: ##$basic##\n$ICN_QUT Quiet Weapons ADS ##90%## faster.\n\nACE: ##$pro##\n$ICN_QUT Quiet Weapons gain ##+20## Stability.",
				menu_good_hunting = "Good Hunting",
				menu_good_hunting_desc = "BASIC: ##$basic##\nBows have all of their Arrows readied instead of in reserve. Arrows will curve towards enemies, angling to strike them in the head.\n\nACE: ##$pro##\nCrossbows instantly Reload themselves after a Headshot. Bolts that kill an enemy gain ##Body Piercing##, punching through the target and through any other enemies in its path.",
				menu_comfortable_silence = "Comfortable Silence",
				menu_comfortable_silence_desc = "BASIC: ##$basic##\n$ICN_QUT Quiet Weapons gain ##+2## Concealment.\n\nACE: ##$pro##\n$ICN_QUT Quiet Weapons gain ##+4## Concealment.",
				menu_toxic_shock = "Toxic Shock",
				menu_toxic_shock_desc = "BASIC: ##$basic##\nSuccessfully $ICN_POI Poisoning an enemy will also $ICN_POI Poison enemies within a ##3##-meter radius.\n\nACE: ##$pro##\n$ICN_POI Poison deals ##+100%## damage.",
				menu_professionals_choice = "Professional's Choice",
				menu_professionals_choice_desc = "BASIC: ##$basic##\n$ICN_QUT Quiet Weapons gain a ##+2% Fire Rate bonus## for every ##3## points of Detection Risk under ##35##, up to ##+10%##.\n\nACE: ##$pro##\nThe Fire Rate bonus is increased to ##+4%## and the maximum bonus is increased to ##+20%##.",
				menu_quiet_grave = "Quiet as the Grave",
				menu_quiet_grave_desc = "BASIC: ##$basic##\n$ICN_QUT Quiet Weapons deal ##+25%## Damage when attacking an enemy from behind.\n\nACE: ##$pro##\n$ICN_QUT Quiet Weapons also deal ##+25%## Damage when attacking an enemy that is not currently targeting you.",
			
			--sapper
				menu_home_improvements = "Home Improvements",
				menu_home_improvements_desc = "BASIC: ##$basic##\nDrills and Saws you place or upgrade become ##silent##. Civilians and Guards must see the Drill or Saw in order to become alerted.\n\nACE: ##$pro##\nYou upgrade Drills and Saws placed by other players ##75%## faster.",
				menu_perfect_alignment = "Perfect Alignment",
				menu_perfect_alignment_desc = "BASIC: ##$basic##\nYou place Drills and Saws ##75%## faster.\n\nACE: ##$pro##\nDrills and Saws placed or upgraded by you work ##30%## faster.",
				menu_static_defense = "Static Defense",
				menu_static_defense_desc = "BASIC: ##$basic##\nIf an enemy tries to disable a Drill or Saw you have placed or upgraded, the attempt will fail and they will be shocked for ##5## seconds.This can only happen once every ##60## seconds.\n\nACE: ##$pro##\nThe cooldown is reduced to ##30## seconds. When Static Defense is activated, it will send out an alert.",
				menu_routine_maintenance = "Routine Maintenance",
				menu_routine_maintenance_desc = "BASIC: ##$basic##\nYou fixed jammed Drills and Saws ##50%## faster.\n\nACE: ##$pro##\nYou can Melee Attack a jammed Drill or Saw to fix it instantly, but only once per Drill or Saw.",
				menu_automatic_reboot = "Automatic Reboot",
				menu_automatic_reboot_desc = "BASIC: ##$basic##\nIf a Drill or Saw you have placed or upgraded jams, it will automatically unjam itself after ##30## seconds. This can only happen once per Drill or Saw.\n\nACE: ##$pro##\nThe delay between the Drill or Saw jamming and unjamming itself is reduced to ##5## seconds.",
				menu_explosive_impatience = "Explosive Impatience",
				menu_explosive_impatience_desc = "BASIC: ##$basic##\nIncreases your Shaped Charges supply to ##6##.\n\nACE: ##$pro##\nIncreases your Shaped Charges supply to ##8##.",
		
			--dealer
				menu_high_low = "High-Low Split",
				menu_high_low_desc = "BASIC: ##$basic##\n$ICN_MEL Melee Weapons gain the ability to score Headshots. $ICN_THR Throwing Weapons gain ##+100%## increased Velocity, increasing their speed and range.\n\nACE: ##$pro##\nYou gain ##+80%## Swap Speed and Stow Speed with all weapon types.",
				
				menu_face_value = "Face Value",
				menu_face_value_desc = "BASIC: ##$basic##\n$ICN_MEL Melee Weapons gain ##+100%## Charge Speed.\n\nACE: ##$pro##\nAttacking a Shield with any $ICN_MEL Melee Weapon will stagger them.",
			
				menu_value_bet = "Value Bet",
				menu_value_bet_desc = "BASIC: ##$basic##\n$ICN_THR Throwing Weapons gain ##+50%## ammunition.\n\nACE: ##$pro##\n$ICN_THR Throwing Weapons can be charged, dealing ##+100%## Damage after being held for ##1## second.",
			
				menu_wild_card = "Wild Card",
				menu_wild_card_desc = "BASIC: ##$basic##\nWhen you take damage, enemies within ##2## meters take ##100%## of that damage.\n\nACE: ##$pro##\nEnemies damaged by Wild Card are now staggered.",
			
				menu_stacking_deck = "Stacking the Deck",
				menu_stacking_deck_desc = "BASIC: ##$basic##\n$ICN_THR Throwing Weapons will curve towards enemies, angling to strike them in the head.\n\nACE: ##$pro##\nHeadshot kills with $ICN_THR Throwing Weapons inflict Panic on most enemies within ##6## meters of the target, causing them to go into short bursts of uncontrollable fear.",
			
				menu_shuffle_and_cut = "Shuffle and Cut",
				menu_shuffle_and_cut_desc = "BASIC: ##$basic##\nHitting an enemy with a $ICN_THR Throwing Weapon empowers your next $ICN_MEL Melee Attack with ##+500%## Damage. Hitting an enemy with a $ICN_MEL Melee Weapon empowers your next $ICN_THR Throwing Weapon attack with ##+500%## Damage.\n\nYou can hold up to ##5## empowered attacks of each type at a time.\n\nACE: ##$pro##\nKilling an enemy with an empowered $ICN_MEL Melee Weapon or $ICN_THR Throwing Weapon refunds the buff.",
			
			
			--fixer
				menu_rolling_cutter = "Rolling Cutter",
				menu_rolling_cutter_desc = "BASIC: ##$basic##\nThe $ICN_SAW OVE9000 Saw no longer consumes Ammunition when damaging enemies and gains ##+10%## Damage for ##2## seconds after every hit, up to a maximum of ##500%##.\n\nACE: ##$pro##\nIncreases the $ICN_SAW OVE9000 Saw blade durability by ##+50##.",
				menu_walking_toolshed = "Walking Toolshed",
				menu_walking_toolshed_desc = "BASIC: ##$basic##\nIncreases your spare $ICN_SAW OVE9000 Saw blades to ##2##.\n\nACE: ##$pro##\nIncreases your spare $ICN_SAW OVE9000 Saw blades to ##3##.",
				menu_handyman = "Handyman",
				menu_handyman_desc = "BASIC: ##$basic##\nThe $ICN_SAW OVE9000 Saw becomes available as a Secondary Weapon.\n\nACE: ##$pro##\nThe $ICN_SAW OVE9000 Saw gains ##+25%## range.",
				menu_bloody_mess = "Bloody Mess",
				menu_bloody_mess_desc = "BASIC: ##$basic##\nKills with the $ICN_SAW OVE9000 Saw deal the killing blow's damage to enemies within ##2.5## meters.\n\nACE: ##$pro##\nEnemies killed by Bloody Mess also deal damage to nearby enemies.",
				menu_not_safe = "Not Safe",
				menu_not_safe_desc = "BASIC: ##$basic##\nThe $ICN_SAW OVE9000 Saw can cut through Shields. Additionally, the OVE9000 Saw no longer consumes ammunition when hitting Shields.\n\nACE: ##$pro##\nThe $ICN_SAW OVE9000 Saw deals ##+100%## Damage to Dozers and their armor plates.",
				menu_into_the_pit = "Into The Pit",
				menu_into_the_pit_desc = "BASIC: ##$basic##\nThe $ICN_SAW OVE9000 Saw is guaranteed to deal a Critical Hit the first time it damages an enemy.\n\nACE: ##$pro##\nKills with the $ICN_SAW OVE9000 Saw inflict Panic on most enemies within ##6## meters, causing them to go into short bursts of uncontrollable fear.",
				
				
			--demolitions
			
				menu_party_favors = "Party Favors",
				menu_party_favors_desc = "BASIC: ##$basic##\n$ICN_GRN Grenades gain ##+33%## Ammunition.\n\nACE: ##$pro##\nTrip Mines in Sensor Mode will Mark targets for ##50%## longer.",
			
				menu_special_toys = "Special Toys",
				menu_special_toys_desc = "BASIC: ##$basic##\n$ICN_SPC Specialist Weapons gain ##+25%## more Ammunition.\n\nACE: ##$pro##\n$ICN_SPC Specialist Weapons gain ##+30%## Reload Speed.",
			
				menu_smart_bombs = "Smart Bombs",
				menu_smart_bombs_desc = "BASIC: ##$basic##\nYour Trip Mines gain ##+30%## explosion radius.\n\nACE: ##$pro##\nYour Trip Mines can no longer damage Civilians or Hostages.",
			
				menu_third_degree = "Third Degree",
				menu_third_degree_desc = "BASIC: ##$basic##\nYour $ICN_ARD Area Denial effects last ##+50%## longer.\n\nACE: ##$pro##\nYou and your $ICN_ARD Area Denial effects deal ##+25%## more damage to enemies that are on fire.",
			
				menu_have_blast = "Have A Blast",
				menu_have_blast_desc = "BASIC: ##$basic##\nYou gain the ability to deploy a Trip Mine directly on an enemy.\nDoing so will cause the target and all enemies within ##10## meters to Panic until it detonates.\n\nACE: ##$pro##\nDeploying a Trip Mine on a Dozer stuns them and inflicts a ##+100%## Damage Vulnerability on all enemies within ##10## meters for ##10## seconds.",
			
				menu_improv_expert = "Improv Expert",
				menu_improv_expert_desc = "BASIC: ##$basic##\nEvery ##50## Ammo Boxes grants ##+1## $ICN_GRN Grenade. \n\nACE: ##$pro##\n Rocket Launchers and Flamethrowers can gain Ammunition from Ammo Boxes. Grenade Launchers gain ##+50%## Ammunition from Ammo Boxes.\n\nNote: This applies to both Ammo Boxes picked up by yourself and by teammates.",
			
		--perk decks
				--crew chief
				menu_deck1_1 = "The Usual Suspects",
				menu_deck1_1_desc = "Your team gains ##+10%## Damage Resistance.\n\nYour team can only benefit from one set of Crew Chief passives at a time. If multiple Crew Chiefs are present, the team will only benefit from the highest leveled Crew Chief deck.",
				menu_deck1_2 = "One Hundred Steps",
				menu_deck1_2_desc = "Your team gains ##+10%## Stamina Recovery Rate.",
				menu_deck1_3 = "Reservoir Dogs",
				menu_deck1_3_desc = "Your team gains ##+10%## Maximum Health.",
				menu_deck1_4 = "Mean Streets",
				menu_deck1_4_desc = "Your team gains ##+10%## Maximum Stamina.",
				menu_deck1_5 = "Goodfellas",
				menu_deck1_5_desc = "Each member of your team regenerates ##1%## of their Missing Health per second.",
				menu_deck1_6 = "Heat",
				menu_deck1_6_desc = "Your team gains ##+10%## Interact Speed.",
				menu_deck1_7 = "Layer Cake",
				menu_deck1_7_desc = "Your team gains ##+10%## Maximum Armor.",
				menu_deck1_8 = "State of Grace",
				menu_deck1_8_desc = "Your team gains ##+10%## Armor Recovery Rate.",
				menu_deck1_9 = "Angels with Dirty Faces",
				menu_deck1_9_desc = "You can revive Downed players within your line of sight by Shouting at them when they are within ##10## meters of you. This effect has a ##20## second cooldown.",
				
				
				--Muscle
				menu_deck2_1 = "Dynamic Tension",
				menu_deck2_1_desc = "You gain ##+25%## Maximum Health and you become ##25%## more likely to be targeted over your teammates.",
				menu_deck2_2 = "Endurance Training",
				menu_deck2_2_desc = "You regenerate ##0.5%## of your Maximum Health per second.",
				menu_deck2_3 = "Chump Into Champ",
				menu_deck2_3_desc = "Increases your Maximum Health bonus to ##+50%##.",
				menu_deck2_4 = "Dauntless Improvement",
				menu_deck2_4_desc = "Your Health Regeneration increases to ##1%## of your Maximum Health per second.",
				menu_deck2_5 = "15 Minutes A Day",
				menu_deck2_5_desc = "Increases your Maximum Health bonus to ##+75%##.",
				menu_deck2_6 = "Tireless Physique",
				menu_deck2_6_desc = "Your Health Regeneration increases to ##1.5%## of your Maximum Health per second.",
				menu_deck2_7 = "Muscle Mystery",
				menu_deck2_7_desc = "Increases your Maximum Health bonus to ##+100%##.",
				menu_deck2_8 = "Flex Eternal",
				menu_deck2_8_desc = "Your Health Regeneration increases to ##2%## of your Maximum Health per second.",
				menu_deck2_9 = "Hero Of The Beach",
				menu_deck2_9_desc = "Each kill you make during a heist increases your Maximum Health by ##+1##, up to ##+200##. All stacks are lost upon being downed.",
				
				--Armorer
				menu_deck3_1 = "Reactive Armor",
				menu_deck3_1_desc = "You are rendered ##Invulnerable## to damage for ##2## seconds after your Armor breaks. This effect has a ##10## second cooldown.",
				menu_deck3_2 = "Mk1 Plating",
				menu_deck3_2_desc = "You gain ##+25%## Maximum Armor.",
				menu_deck3_3 = "Steadfast",
				menu_deck3_3_desc = "##Doubles## the Steadiness of your equipped Armor, ##reducing how much you Flinch## from taking Damage.",
				menu_deck3_4 = "Mk2 Plating",
				menu_deck3_4_desc = "Increases your Maximum Armor bonus to ##+50%##.",
				menu_deck3_5 = "Armored Grace",
				menu_deck3_5_desc = "Your Speed penalty for wearing Armor is reduced by ##50%##.",
				menu_deck3_6 = "Mk3 Plating",
				menu_deck3_6_desc = "Increases your Maximum Armor bonus to ##+75%##.",
				menu_deck3_7 = "Unbreakable Will",
				menu_deck3_7_desc = "You gain ##+25%## Armor Recovery.",
				menu_deck3_8 = "Mk4 Plating",
				menu_deck3_8_desc = "Increases your Maximum Armor bonus to ##+100%##.",
				menu_deck3_9 = "Ironclad",
				menu_deck3_9_desc = "You gain ##+10%## Damage Resistance when you have any amount of Armor.",
				
				--Rogue
				menu_deck4_1 = "Fat Chance",
				menu_deck4_1_desc = "You gain ##+10%## Dodge Chance.",
				menu_deck4_2 = "Hands Off",
				menu_deck4_2_desc = "You are ##guaranteed to Dodge an enemy Melee attack##. This effect has a ##10## second cooldown.",
				menu_deck4_3 = "Playing the Odds",
				menu_deck4_3_desc = "Increases your Dodge Chance bonus to ##+20%##.",
				menu_deck4_4 = "Elusive Target",
				menu_deck4_4_desc = "You are ##guaranteed to Dodge a Sniper shot##. This effect has a ##10## second cooldown.",
				menu_deck4_5 = "Tricky Business",
				menu_deck4_5_desc = "Increases your Dodge Chance bonus to ##+30%##.",
				menu_deck4_6 = "Kansas City Shuffle",
				menu_deck4_6_desc = "You are ##guaranteed to Dodge a Cloaker kick##. This effect has a ##10## second cooldown.",
				menu_deck4_7 = "Isai's Wisdom",
				menu_deck4_7_desc = "Increases your Dodge Chance bonus to ##+40%##.",
				menu_deck4_8 = "The Electric Slide",
				menu_deck4_8_desc = "You are ##guaranteed to Dodge a Taser shock##. This effect has a ##10## second cooldown.",
				menu_deck4_9 = "Smooth Criminal",
				menu_deck4_9_desc = "You gain a bonus ##+2%## Dodge Chance for every ##2## points of Detection Risk under ##35##, up to ##+20%##.",
				
				
				--Hitman
				menu_st_spec_5 = "Hitman",
				menu_deck5_1 = "Aerodynamic",
				menu_deck5_1_desc = "You gain ##+10%## Armor Recovery Rate.",
				menu_deck5_2 = "Revolution 909",
				menu_deck5_2_desc = "Your Armor will Recover ##2## seconds after being broken, no matter the situation. ",
				menu_deck5_3 = "High Fidelity",
				menu_deck5_3_desc = "Your Armor Recovery Rate bonus increases to ##+20%##.",
				menu_deck5_4 = "Rollin & Scratchin",
				menu_deck5_4_desc = "Revolution 909 now activates after ##1.75## seconds.",
				menu_deck5_5 = "Fresh",
				menu_deck5_5_desc = "Your Armor Recovery Rate bonus increases to ##+30%##.",
				menu_deck5_6 = "Steam Machine",
				menu_deck5_6_desc = "Revolution 909 now activates after ##1.5## seconds.",
				menu_deck5_7 = "Face to Face",
				menu_deck5_7_desc = "Your Armor Recovery Rate bonus increases to ##+40%##.",
				menu_deck5_8 = "Hitmen After All",
				menu_deck5_8_desc = "Revolution 909 now activates after ##1.25## seconds.",
				menu_deck5_9 = "One More Time",
				menu_deck5_9_desc = "You become ##Invulnerable while in bleedout##. While in bleedout, you can ##Revive yourself by killing an enemy and then pressing Jump##.",
				
				--Crook
				menu_st_spec_6 = "Crook",
				menu_deck6_1 = "Extra Padding",
				menu_deck6_1_desc = "Ballistic Vests gain ##+15## Maximum Armor.",
				menu_deck6_2 = "Bounce Back",
				menu_deck6_2_desc = "Ballistic Vests gain ##+20%## Armor Recovery Rate.",
				menu_deck6_3 = "Vital Protection",
				menu_deck6_3_desc = "Increases the Maximum Armor bonus for Ballistic Vests to ##+30##.",
				menu_deck6_4 = "Basic Tailoring",
				menu_deck6_4_desc = "When wearing a Ballistic Vest, you gain ##+15%## Dodge Chance.",
				menu_deck6_5 = "Custom Weave",
				menu_deck6_5_desc = "Increases the Maximum Armor bonus for Ballistic Vests to ##+45##.",
				menu_deck6_6 = "Keeping Cool",
				menu_deck6_6_desc = "Increases the Ballistic Vest Armor Recovery Rate bonus to ##+40%##.",
				menu_deck6_7 = "Prototype Material",
				menu_deck6_7_desc = "Increases the Maximum Armor bonus for Ballistic Vests to ##+60##.",
				menu_deck6_8 = "Perfect Fit",
				menu_deck6_8_desc = "Your Dodge Chance bonus for Ballistic Vests increases to ##+30%##.",
				menu_deck6_9 = "Borrowed Time",
				menu_deck6_9_desc = "Instead of being incapacitated when you lose all of your health, you will enter a grace period where you can continue to act for ##4## seconds before falling. During this grace period, you are ##invulnerable## and your weapons ##instantly reload##. Borrowed Time cannot be triggered by fall damage or fire damage.",
				
				--Burglar
				menu_deck7_1 = "Hands in the Dark",
				menu_deck7_1_desc = "You gain ##+10%## Object Interact Speed while in Stealth.",
				menu_deck7_2 = "The Toothpick",
				menu_deck7_2_desc = "You gain ##+232## Concealment.",
				menu_deck7_3 = "Deft Fingers",
				menu_deck7_3_desc = "Your Object Interact Speed bonus increases to ##+20%##.",
				menu_deck7_4 = "Ranzer's Edge",
				menu_deck7_4_desc = "You ##no longer take Fall Damage when falling from Non-Fatal heights##. Additionally, the distance you must fall before a fall is considered Fatal is ##doubled##.",
				menu_deck7_5 = "Silent Work",
				menu_deck7_5_desc = "Your Object Interact Speed bonus increases to ##+30%##.",
				menu_deck7_6 = "Long Haul",
				menu_deck7_6_desc = "You bag corpses ##+20%## faster and can Sprint ##while carrying heavy Bags##.",
				menu_deck7_7 = "Criminal Discretion",
				menu_deck7_7_desc = "Your Object Interact Speed bonus increases to ##+40%##.",
				menu_deck7_8 = "Fast Talker",
				menu_deck7_8_desc = "You answer Pagers ##+10%## faster.",
				menu_deck7_9 = "Blessing of the Strigidae",
				menu_deck7_9_desc = "You can ##freely rotate your camera## while Interacting with something.",
				
				--Infiltrator
				menu_deck8_1 = "Frontliner",
				menu_deck8_1_desc = "Charging your $ICN_MELMelee Weapon, holding the $ICN_SAW##OVE9000 Saw##, or hitting an enemy with a $ICN_MELMelee Weapon grants you ##+20%## Damage Resistance for ##5## seconds.",
				menu_deck8_2 = "Man Opener",
				menu_deck8_2_desc = "Killing an enemy with a $ICN_MELMelee Weapon or the $ICN_SAW##OVE9000 Saw## restores ##2%## of your Maximum Health.",
				menu_deck8_3 = "Eye of The Tiger",
				menu_deck8_3_desc = "You become ##immune to the visual effect of Flashbangs##.",
				menu_deck8_4 = "Bulk Up",
				menu_deck8_4_desc = "You gain ##+40%## Maximum Health.",
				menu_deck8_5 = "Grit",
				menu_deck8_5_desc = "You gain ##+10%## Damage Resistance.",
				menu_deck8_6 = "Playing Rough",
				menu_deck8_6_desc = "Killing an enemy with a $ICN_MELMelee Weapon or the $ICN_SAW##OVE9000 Saw## restores ##2%## of your Maximum Armor.",
				menu_deck8_7 = "Cross-Counter",
				menu_deck8_7_desc = "If you are struck by an enemy melee attack or Cloaker kick while Charging your $ICN_MELMelee Weapon, you will ##automatically counter-attack##, avoiding the attack and performing a fully Charged $ICN_MELMelee Attack in return.",
				menu_deck8_8 = "Scar Tissue",
				menu_deck8_8_desc = "You gain ##+40%## Maximum Armor.",
				menu_deck8_9 = "Insulated",
				menu_deck8_9_desc = "You ##automatically break out of being shocked## by a Taser after ##1.5## seconds.",
				
				--Sociopath
				menu_deck9_1 = "Richard",
				menu_deck9_1_desc = "Limits the amount of damage that you can take from any attack to ##1##, but reduces your Armor and Dodge by ##100%## and reduces your Health to ##4##. Taking damage ##renders you Invulnerable## for ##2## seconds.\n\nKilling an enemy within ##10## meters grants a stack of ##Combo## that lasts for ##10## seconds. Every ##5## stacks of ##Combo## restores ##1## Health. Every ##10## stacks of Combo reduces the amount of stacks required to restore Health by ##1##.\n\nNOTE: Sociopath reduces healing from First Aid Kits, gains fewer Shields from skills, and negates Regeneration effects and Team Health bonuses.",
				menu_deck9_2 = "Graham",
				menu_deck9_2_desc = "You gain ##+100%## Stamina.",
				menu_deck9_3 = "Tony",
				menu_deck9_3_desc = "Killing an enemy with a $ICN_MELMelee Weapon generates an additional ##Combo## stack.",
				menu_deck9_4 = "Rufus",
				menu_deck9_4_desc = "You gain ##+1## Maximum Health.",
				menu_deck9_5 = "Jake",
				menu_deck9_5_desc = "Killing an enemy with a $ICN_THRThrowing Weapon generates ##2## stacks of ##Combo##, regardless of range.",
				menu_deck9_6 = "Brandon",
				menu_deck9_6_desc = "You gain ##+10%## Movement Speed.",
				menu_deck9_7 = "Carl",
				menu_deck9_7_desc = "Killing an enemy with the $ICN_SAWOVE9000 Saw generates an additional ##Combo## stack.",
				menu_deck9_8 = "Earl",
				menu_deck9_8_desc = "Your Invulnerability period lasts ##+0.5## seconds longer.",
				menu_deck9_9 = "Rasmus",
				menu_deck9_9_desc = "Increases ##Combo## radius to ##15## meters. All enemies within ##Combo## range are Highlighted during Loud.",
				
				--Grinder
				menu_deck11_1 = "Break Out",
				menu_deck11_1_desc = "##0.5%## of the damage you deal is returned to you as Health.",
				menu_deck11_2 = "Life Tap",
				menu_deck11_2_desc = "You regain ##+0.5%## of your Maximum Health when you kill an enemy.",
				menu_deck11_3 = "Offensive Pressure",
				menu_deck11_3_desc = "Increases the amount of Health gained from damage dealt to ##1%##.",
				menu_deck11_4 = "Backcheck",
				menu_deck11_4_desc = "You gain ##+20%## Maximum Health.",
				menu_deck11_5 = "Strong Side",
				menu_deck11_5_desc = "Increases the amount of Health gained from damage dealt to ##1.5%##.",
				menu_deck11_6 = "Life Rush",
				menu_deck11_6_desc = "Increases the amount of Maximum Health gained from killing an enemy to ##1%##.",
				menu_deck11_7 = "Scoring Chance",
				menu_deck11_7_desc = "Increases the amount of Health gained from damage dealt to ##2%##.",
				menu_deck11_8 = "Forecheck",
				menu_deck11_8_desc = "Increases your Maximum Health bonus to ##+40%##.",
				menu_deck11_9 = "Bar Down",
				menu_deck11_9_desc = "Increases the amount of Health gained from damage dealt to ##2.5%##.",
				
				--Yakuza
				menu_deck12_1 = "Fujin Irezumi",
				menu_deck12_1_desc = "You gain ##+2%## Damage Resistance per ##10%## of Missing Health, up to ##+10%## Damage Resistance.\n\nCharging your $ICN_MELMelee Weapon for ##5## seconds causes you to ##lose 5%## Maximum Health per second spent Charging afterwards, up to ##50%##.\n\n##Yakuza negates Regeneration effects while equipped.##",
				menu_deck12_2 = "Raijin Irezumi",
				menu_deck12_2_desc = "Taking damage grants ##+10%## Damage Resistance for ##5## seconds.",
				menu_deck12_3 = "Taubushi",
				menu_deck12_3_desc = "Increases the Damage Resistance bonus per Missing Health to ##+4%##, up to ##+20%##.",
				menu_deck12_4 = "Gobu",
				menu_deck12_4_desc = "Increases the Damage Resistance bonus from taking damage to ##+20%##",
				menu_deck12_5 = "Hanzubon",
				menu_deck12_5_desc = "Increases the Damage Resistance bonus per Missing Health to ##+6%##, up to ##+30%##.",
				menu_deck12_6 = "Shichibu",
				menu_deck12_6_desc = "Increases the Damage Resistance bonus from taking damage to ##+30%##",
				menu_deck12_7 = "Munewari",
				menu_deck12_7_desc = "Increases the Damage Resistance bonus per Missing Health to ##+8%##, up to ##+40%##",
				menu_deck12_8 = "Nagasode",
				menu_deck12_8_desc = "Increases the Damage Resistance bonus from taking damage to ##+40%##.",
				menu_deck12_9 = "Donburi Soshinbori",
				menu_deck12_9_desc = "You become Invulnerable for ##1## second after taking damage from any source.",
				
				--Ex-President
				menu_deck13_1 = "Election",
				menu_deck13_1_desc = "When you ##have any amount of Armor##, kills generate ##5 Approval##, up to ##200##.\n\nWhen your Armor has been ##completely depleted and starts to regenerate##, ##Approval## is converted into healing to ##restore missing Health##.",
				menu_deck13_2 = "Inauguration",
				menu_deck13_2_desc = "If you are missing Health when you have any amount of Armor, ##5 Approval## is converted to Health every ##5## seconds.",
				menu_deck13_3 = "Appointment",
				menu_deck13_3_desc = "You gain ##+30%## Maximum Health.",
				menu_deck13_4 = "Delegation",
				menu_deck13_4_desc = "Reduces the amount of time to convert ##Approval## while Armored to ##4## seconds.",
				menu_deck13_5 = "Rough Times",
				menu_deck13_5_desc = "You gain ##+20%## Dodge Chance.",
				menu_deck13_6 = "Bad Decisions",
				menu_deck13_6_desc = "Reduces the amount of time to convert ##Approval## while Armored to ##3## seconds.",
				menu_deck13_7 = "Scandal",
				menu_deck13_7_desc = "You now generate ##10 Approval## per kill and the maximum amount of ##Approval## increases to ##300##.",
				menu_deck13_8 = "Impeachment",
				menu_deck13_8_desc = "Reduces the amount of time to convert ##Approval## while Armored to ##2## seconds.",
				menu_deck13_9 = "Departure",
				menu_deck13_9_desc = "When your Armor ##has been completely depleted##, you gain ##+20%## Armor Recovery Rate for every ##80 Approval## you have stored, up to ##+60%##.",
				
				--Anarchist
				menu_deck15_1 = "Nazi Punks Fuck Off",
				menu_deck15_1_desc = "Instead of ##fully regenerating Armor when out of combat##, you will ##constantly regenerate Armor based on your suit##. Heavier suits regenerates more Armor, but during longer intervals.\n\n##50%## of your Health is converted into Armor.",
				menu_deck15_2 = "Dog Bite",
				menu_deck15_2_desc = "Damaging an enemy generates ##5## Armor.",
				menu_deck15_3 = "Cesspools In Eden",
				menu_deck15_3_desc = "Increases the amount of Health converted into Armor to ##60%##.",
				menu_deck15_4 = "Life Sentence",
				menu_deck15_4_desc = "Killing an enemy generates ##5## Armor.",
				menu_deck15_5 = "Dead End",
				menu_deck15_5_desc = "Increases the amount of Health converted into Armor to ##70%##.",
				menu_deck15_6 = "I Spy",
				menu_deck15_6_desc = "Hitting an enemy with a Headshot generates ##10## Armor.",
				menu_deck15_7 = "The Great Wall",
				menu_deck15_7_desc = "Increases the amount of Health converted into Armor to ##80%##.",
				menu_deck15_8 = "Let's Lynch The Landlord",
				menu_deck15_8_desc = "Killing an enemy with a Headshot generates ##10## Armor.",
				menu_deck15_9 = "This Could Be Anywhere",
				menu_deck15_9_desc = "Increases the amount of Health converted into Armor to ##90%##.",
				
				--Gambler
				menu_deck10_1 = "Financial Wellness",
				menu_deck10_1_desc = "Every ##20## Ammo Pickups that your team gathers heals your team for ##1%## Maximum Health.",
				menu_deck10_2 = "Scavenger",
				menu_deck10_2_desc = "Your team's Ammo Box pickup range is increased by ##+25%##.",
				menu_deck10_3 = "Healthy Investment",
				menu_deck10_3_desc = "Reduces the amount of Ammo Pickups required for healing to ##15##.",
				menu_deck10_4 = "Forager",
				menu_deck10_4_desc = "Your team's Ammo Box pickup range bonus increases to ##+50%##.",
				menu_deck10_5 = "Sure Thing",
				menu_deck10_5_desc = "Reduces the amount of Ammo Pickups required for healing to ##10##.",
				menu_deck10_6 = "Hunter",
				menu_deck10_6_desc = "Your team's Ammo Box pickup range bonus increases to ##+75%##.",
				menu_deck10_7 = "Fun And Profit",
				menu_deck10_7_desc = "Reduces the amount of Ammo Pickups required for healing to ##5##.",
				menu_deck10_8 = "Farmer",
				menu_deck10_8_desc = "Your team's Ammo Box pickup range bonus increases to ##+100%##.",
				menu_deck10_9 = "High Roller",
				menu_deck10_9_desc = "Healing from Ammo Pickups is increased to ##1.5%## of Maximum Health.",
				
				--Tag Team
				menu_deck20_1 = "We Live In A Society",
				menu_deck20_1_desc = "Unlocks the Tag Team Gas Dispenser, which can be equipped in the Throwable slot. The Gas Dispenser can be activated by pressing the Throwable key when looking at an allied unit with a clear line of sight up to ##18## meters away.",
				menu_deck20_2 = "Gamers Rise Up",
				menu_deck20_2_desc = "When used on an incapacitated teammate, the Gas Dispenser will instantly Revive them with ##10%## of their Maximum Health but apply no other effects.",
				menu_deck20_3 = "Chasing Veronica",
				menu_deck20_3_desc = "The Gas Dispenser's healing also grants ##+20%## Movement Speed.",
				menu_deck20_4 = "Gang Weed",
				menu_deck20_4_desc = "When using the Gas Dispenser on an ally, you also gain its effects.",
				menu_deck20_5 = "Fighting Oppression",
				menu_deck20_5_desc = "The Gas Dispenser's healing also grants ##+10%## Damage Resistance.",
				menu_deck20_6 = "Epic Content",
				menu_deck20_6_desc = "The Gas Dispenser's healing is increased to ##+10%## of Maximum Health per second, for a total of ##50%## Maximum Health restored.",
				menu_deck20_7 = "Chad Killer",
				menu_deck20_7_desc = "When you or your tagged ally kills an enemy while the Gas Dispenser's effect is active, its cooldown is reduced by ##1## second.",
				menu_deck20_8 = "Now You See",
				menu_deck20_8_desc = "The Gas Dispenser's healing lasts for ##5## seconds longer, for a total of ##100%## of Maximum Health restored.",
				menu_deck20_9 = "Bottom Text",
				menu_deck20_9_desc = "Reviving a Teammate with the Gas Dispenser no longer excludes the target or the user from the Gas Dispenser's effects.",
				
				
				--[[
				
				--Maniac
				menu_deck14_1 = "PLACEHOLDER",
				menu_deck14_1_desc = "PLACEHOLDER",
				menu_deck14_2 = "PLACEHOLDER",
				menu_deck14_2_desc = "PLACEHOLDER",
				menu_deck14_3 = "PLACEHOLDER",
				menu_deck14_3_desc = "PLACEHOLDER",
				menu_deck14_4 = "PLACEHOLDER",
				menu_deck14_4_desc = "PLACEHOLDER",
				menu_deck14_5 = "PLACEHOLDER",
				menu_deck14_5_desc = "PLACEHOLDER",
				menu_deck14_6 = "PLACEHOLDER",
				menu_deck14_6_desc = "PLACEHOLDER",
				menu_deck14_7 = "PLACEHOLDER",
				menu_deck14_7_desc = "PLACEHOLDER",
				menu_deck14_8 = "PLACEHOLDER",
				menu_deck14_8_desc = "PLACEHOLDER",
				menu_deck14_9 = "PLACEHOLDER",
				menu_deck14_9_desc = "PLACEHOLDER",
				
				--Biker
				menu_deck16_1 = "PLACEHOLDER",
				menu_deck16_1_desc = "PLACEHOLDER",
				menu_deck16_2 = "PLACEHOLDER",
				menu_deck16_2_desc = "PLACEHOLDER",
				menu_deck16_3 = "PLACEHOLDER",
				menu_deck16_3_desc = "PLACEHOLDER",
				menu_deck16_4 = "PLACEHOLDER",
				menu_deck16_4_desc = "PLACEHOLDER",
				menu_deck16_5 = "PLACEHOLDER",
				menu_deck16_5_desc = "PLACEHOLDER",
				menu_deck16_6 = "PLACEHOLDER",
				menu_deck16_6_desc = "PLACEHOLDER",
				menu_deck16_7 = "PLACEHOLDER",
				menu_deck16_7_desc = "PLACEHOLDER",
				menu_deck16_8 = "PLACEHOLDER",
				menu_deck16_8_desc = "PLACEHOLDER",
				menu_deck16_9 = "PLACEHOLDER",
				menu_deck16_9_desc = "PLACEHOLDER",
				
				--Kingpin
				menu_deck17_1 = "PLACEHOLDER",
				menu_deck17_1_desc = "PLACEHOLDER",
				menu_deck17_2 = "PLACEHOLDER",
				menu_deck17_2_desc = "PLACEHOLDER",
				menu_deck17_3 = "PLACEHOLDER",
				menu_deck17_3_desc = "PLACEHOLDER",
				menu_deck17_4 = "PLACEHOLDER",
				menu_deck17_4_desc = "PLACEHOLDER",
				menu_deck17_5 = "PLACEHOLDER",
				menu_deck17_5_desc = "PLACEHOLDER",
				menu_deck17_6 = "PLACEHOLDER",
				menu_deck17_6_desc = "PLACEHOLDER",
				menu_deck17_7 = "PLACEHOLDER",
				menu_deck17_7_desc = "PLACEHOLDER",
				menu_deck17_8 = "PLACEHOLDER",
				menu_deck17_8_desc = "PLACEHOLDER",
				menu_deck17_9 = "PLACEHOLDER",
				menu_deck17_9_desc = "PLACEHOLDER",
				
				--Sicario
				menu_deck18_1 = "Vanishing Act",
				menu_deck18_1_desc = "Unlocks the Sicario Smoke Bomb, which can be equipped in the Throwable slot and thrown by pressing the Throwable key. Deploying the Smoke Bomb creates a smoke screen for ##10## seconds. Allies within the smoke screen Evade ##50## of all incoming attacks, and enemies within the smoke screen suffer from a ##50%## Accuracy penalty.\n\nThe Smoke Bomb has a ##60## second cooldown.\n\nMechanical Note: Evasion is separate from Dodge and rolls its chance to negate damage after Dodge's chance to negate damage is calculated.",
				menu_deck18_2 = "Smoke Signals",
				menu_deck18_2_desc = "Enemies within the smoke screen are Marked.",
				menu_deck18_3 = "Wraith Walk",
				menu_deck18_3_desc = "Allies gain ##20%## increased Movement Speed and Dodge Chance while in the smoke screen and for ##5## seconds after leaving it.",
				menu_deck18_4 = "Second-hand Hazard",
				menu_deck18_4_desc = "Killing an enemy while the smoke screen is active reduces the cooldown of the Smoke Bomb by ##2## seconds.",
				menu_deck18_5 = "Shadow Armor",
				menu_deck18_5_desc = "Allies standing within the smoke screen have ##5%## of their Armor restored per second.",
				menu_deck18_6 = "No Filter",
				menu_deck18_6_desc = "Increases the duration of the smoke screen to ##15## seconds.",
				menu_deck18_7 = "Soothing Mist",
				menu_deck18_7_desc = "Allies are immune to Tear Gas within the smoke screen.",
				menu_deck18_8 = "Clouded Vision",
				menu_deck18_8_desc = "Snipers cannot target allies within a smoke screen.",
				menu_deck18_9 = "Beyond The Veil",
				menu_deck18_9_desc = "Allies within the smoke screen gain ##100%## Damage Resistance when Interacting with an object or Reviving a teammate.",
				
				--Stoic
				menu_deck19_1 = "PLACEHOLDER",
				menu_deck19_1_desc = "PLACEHOLDER",
				menu_deck19_2 = "PLACEHOLDER",
				menu_deck19_2_desc = "PLACEHOLDER",
				menu_deck19_3 = "PLACEHOLDER",
				menu_deck19_3_desc = "PLACEHOLDER",
				menu_deck19_4 = "PLACEHOLDER",
				menu_deck19_4_desc = "PLACEHOLDER",
				menu_deck19_5 = "PLACEHOLDER",
				menu_deck19_5_desc = "PLACEHOLDER",
				menu_deck19_6 = "PLACEHOLDER",
				menu_deck19_6_desc = "PLACEHOLDER",
				menu_deck19_7 = "PLACEHOLDER",
				menu_deck19_7_desc = "PLACEHOLDER",
				menu_deck19_8 = "PLACEHOLDER",
				menu_deck19_8_desc = "PLACEHOLDER",
				menu_deck19_9 = "PLACEHOLDER",
				menu_deck19_9_desc = "PLACEHOLDER",
				
				--Hacker
				menu_deck21_1 = "PLACEHOLDER",
				menu_deck21_1_desc = "PLACEHOLDER",
				menu_deck21_2 = "PLACEHOLDER",
				menu_deck21_2_desc = "PLACEHOLDER",
				menu_deck21_3 = "PLACEHOLDER",
				menu_deck21_3_desc = "PLACEHOLDER",
				menu_deck21_4 = "PLACEHOLDER",
				menu_deck21_4_desc = "PLACEHOLDER",
				menu_deck21_5 = "PLACEHOLDER",
				menu_deck21_5_desc = "PLACEHOLDER",
				menu_deck21_6 = "PLACEHOLDER",
				menu_deck21_6_desc = "PLACEHOLDER",
				menu_deck21_7 = "PLACEHOLDER",
				menu_deck21_7_desc = "PLACEHOLDER",
				menu_deck21_8 = "PLACEHOLDER",
				menu_deck21_8_desc = "PLACEHOLDER",
				menu_deck21_9 = "PLACEHOLDER",
				menu_deck21_9_desc = "PLACEHOLDER"
				
				--]]
				
				
				
			})
		end
		
		--this is separate since some of these options are intended for menus, which are available regardless of whether or not the overhaul itself is enabled
	end
	loc:add_localized_strings({
		tripmine_control_menu_title = "Tripmine Control",
		tcdso_menu_title = "Sentry Overhaul Menu",
		tcdso_menu_desc = "TOTAL CRACKDOWN Sentry Overhaul Menu (Standalone)",
		tcdso_option_keybind_select_sentry_title = "Keybind: Select Sentry",
		tcdso_option_keybind_select_sentry_desc = "When held, this selects any sentry or sentries you aim at.",
		tcdso_option_keybind_deselect_sentry_title = "Keybind: Deselect Sentry",
		tcdso_option_keybind_deselect_sentry_desc = "When held, this deselects any sentry or sentries you aim at.",
		tcdso_option_keybind_open_menu_title = "Keybind: Sentry Control Menu",
		tcdso_option_keybind_open_menu_desc = "Opens the Sentry Control Menu.",
		tcdso_option_open_menu_behavior_title = "Hold/Toggle Menu Behavior",
		tcdso_option_open_menu_behavior_desc = "Choose whether hold/release will select Sentry Modes with the Radial Menu",
		tdso_option_refresh_keybinds_title = "Apply Keybind Changes",
		tdso_option_refresh_keybinds_desc = "Click to refresh your keybinds if you have rebound them after the heist starts.",
		tcdso_option_hold_behavior = "On Button Hold+Release",
		tcdso_option_toggle_behavior = "On Second Button Press",
		tcdso_option_any_behavior = "On Hold+Release, Press, or Click",
		tcdso_option_click_behavior = "On Mouse-Click Only",
		
		tcdso_mouseclick_on_menu_close_title = "Select Current Option on Menu Close",
		tcdso_mouseclick_on_menu_close_desc = "(Hold Behavior only)",
		tcdso_option_teammate_alpha_title = "Teammate Laser Alpha",
		tcdso_option_teammate_alpha_desc = "Set the opacity of teammate sentries' lasers",
		tcdso_option_hold_threshold_title = "Set button hold threshold",
		tcdso_option_hold_threshold_desc = "Holding 'Interact' for longer than this many seconds will hide the menu upon button release."

	})
end)
