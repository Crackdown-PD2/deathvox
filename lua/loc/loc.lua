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
				tripmine_payload_explosive = "Explosive",
				tripmine_payload_incendiary = "Incendiary",
				tripmine_payload_concussive = "Concussive",
				tripmine_payload_sensor = "Sensor Mode",
				tripmine_trigger_detonate = "Detonate Now",
				tripmine_trigger_special = "Special Enemies Only",
				tripmine_trigger_default = "Detect All",
				tripmine_payload_recover = "Recover Tripmine",
				sentry_mode_standard = "Standard Mode",
				sentry_mode_overwatch = "Overwatch Mode",
				sentry_mode_manual = "Manual Mode",
				sentry_ammo_ap = "AP Ammo",
				sentry_ammo_he = "HE Ammo",
				sentry_ammo_taser = "Taser Ammo",
				sentry_ammo_standard = "Standard Ammo",
			
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
				bm_equipment_trip_mine = "Shaped Charges",
				bm_equipment_trip_mine_desc = "Shaped Charges are explosive tools that can destroy specific obstacles or open containers. Hold $BTN_INTERACT on an object's displayed weak point to prime it with a Shaped Charge.\n\nWarning: Shaped Charges will only activate when all of an object's weak points are primed.",
				hud_deploying_revive_fak = "Reviving $TEAMMATE_NAME...",
				
				bm_wpn_prj_four_desc = "$ICN_THR Throwing weapons coated in $ICN_POI Poison that deals 150 damage per 0.5 seconds for 3 seconds. $ICN_POI Poison damage can stack and can incapacitate targets.",
				bm_wpn_prj_ace_desc = "$ICN_THR Throwing weapons disguised as playing cards that deal 200 damage. They can't penetrate body armor, but they come in large amounts.",
				bm_wpn_prj_target_desc = "$ICN_THR Throwing weapons that deal 800 damage.",
				bm_wpn_prj_hur_desc = "$ICN_THR Throwing weapons that deal 4000 damage and can punch through Body Armor.",
				bm_wpn_prj_jav_desc = "$ICN_THR Throwing weapons that deal 1400 damage and can slice through Body Armor.",
				
				bm_grenade_frag_desc = "$ICN_GRN Grenade that deals 300 damage in a 10m radius.\nEach enemy hit has a 40% chance to take Critical damage from the explosion.",
				bm_grenade_frag_com_desc = "$ICN_GRN Grenade that deals 1000 damage in a 5m radius.",
				bm_dynamite_desc = "$ICN_GRN Grenade that deals 5000 damage in a 10m radius. Reduced stock.",
				bm_grenade_dada_com_desc = "$ICN_GRN Grenade that deals 400 damage in a 2m radius and then splits into 7 miniature grenades that also deal 400 damage in a 2m radius.",
				bm_concussion_desc = "$ICN_GRN Grenade that deals no damage, but Stuns enemies in an 8m radius for 4 seconds.\nStunned enemies suffer a -50% Accuracy penalty for 5 seconds after being Stunned.",
				bm_grenade_molotov_desc = "$ICN_GRN Grenade that creates a 2.5m radius pool of flame for 15 seconds that deals 250 damage (50 vs allies) every 0.5 seconds.",
				bm_grenade_fir_com_desc = "$ICN_GRN Grenade that creates a 1m radius pool of flame for 30 seconds that deals 250 damage (50 vs allies) every 0.5 seconds.",
				
				bm_equipment_sentry_gun_desc = "Deployable weapon with multiple firing modes that will automatically attack enemies within range. Enemies will ignore Sentry Guns, making them excellent for fire support.\n\nTo deploy, hold $BTN_USE_ITEM on a suitable surface.",
				bm_equipment_sentry_gun_silent_desc = "Deployable weapon with multiple firing modes that will automatically attack enemies within range. Enemies will ignore Sentry Guns, making them excellent for fire support.\n\nTo deploy, hold $BTN_USE_ITEM on a suitable surface.",
				bm_equipment_sentry_gun_silent_desc_UNUSED = cursed_error,
				debug_trip_mine_throwable = "Trip Mine",
				bm_grenade_tripmine = "Trip Mine Throwable",
				bm_grenade_tripmine_desc = "Trip Mines are explosive booby traps with multiple functions and trigger types. To deploy, hold your Use Throwable button on a suitable surface. To modify a placed Trip Mine, press $BTN_INTERACT while looking at them to open the radial menu.", --needs macros
				hud_deploying_tripmine_preview = "Ready to deploy $EQUIPMENT",
				debug_trip_mine = "Shaped Charges",
			--misc
				hud_int_pick_electronic_lock = "Hold $BTN_INTERACT to hack the lock",
				hud_action_picking_electronic_lock = "Hacking the lock...",
			
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
				menu_point_and_click_desc = "BASIC: ##$basic##\n$ICN_PRE Precision Weapons gain ##+1%## Damage per hit, up to ##500%##. All stacks are lost upon missing.\n\nACE: ##$pro##\n$ICN_PRE Precision Weapons ADS ##90%## faster.",
				menu_tap_the_trigger = "Tap the Trigger",
				menu_tap_the_trigger_desc = "BASIC: ##$basic##\n$ICN_PRE Precision Weapons also gain ##+1%## Rate of Fire per stack of Point and Click, up to ##+50%##.\n\nACE: ##$pro##\nMaximum Rate of Fire Bonus increased to ##+100%##.",
				menu_investment_returns = "Investment Returns",
				menu_investment_returns_desc = "BASIC: ##$basic##\nYou gain ##an extra stack## of Point and Click when you kill an enemy.\n\nACE: ##$pro##\nYou gain ##another extra stack## of Point and Click when you kill an enemy with a Headshot.",
				menu_this_machine = "This Machine",
				menu_this_machine_desc = "BASIC: ##$basic##\n$ICN_PRE Precision Weapons also gain ##+0.5%## Reload Speed per stack of Point and Click, up to ##+25%##.\n\nACE: ##$pro##\nMaximum Reload Speed Bonus increased to ##+50%##.",
				menu_mulligan = "Mulligan",
				menu_mulligan_desc = "BASIC: ##$basic##\nAfter missing, you gain a ##1-second## grace period where you still benefit from your Point and Click stacks. Killing an enemy during the grace period will prevent your stacks from being lost.\n\nACE: ##$pro##\nThe grace period is extended to ##1.5 seconds##.",
				menu_magic_bullet = "Magic Bullet",
				menu_magic_bullet_desc = "BASIC: ##$basic##\nKilling an enemy with a Headshot from a $ICN_PRE Precision Weapon adds ##1## bullet to your reserve ammunition.\n\nACE: ##$pro##\nThe bullet is added to your current Magazine instead of your reserves.",
			
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
				menu_protect_and_serve = "To Protect and to Serve",
				menu_protect_and_serve_desc = "BASIC: ##$basic##\nYou convert enemies into Jokers ##90%## faster.\n\nACE: ##$pro##\nIncreases your Friendship Collar supply to ##6##.",
				menu_order_through_law = "Order through Law",
				menu_order_through_law_desc = "BASIC: ##$basic##\nJokers no longer flinch from taking damage and cannot be knocked down.\n\nACE: ##$pro##\nJokers will melee enemies within range, dealing damage and causing them to stagger.",
				menu_justice_with_mercy = "Justice with Mercy",
				menu_justice_with_mercy_desc = "BASIC: ##$basic##\nJokers gain ##Armor Piercing##.\n\nACE: ##$pro##\nJokers gain ##+90%## Accuracy.",
				menu_standard_of_excellence = "Standard of Excellence",
				menu_standard_of_excellence_desc = "BASIC: ##$basic##\nIncreases Jokers' Damage Resistance from 50% to ##75%##.\n\nACE: ##$pro##\nJokers regenerate ##2.5%## of their Maximum Health per second.",
				menu_maintaining_the_peace = "Maintaining the Peace",
				menu_maintaining_the_peace_desc = "BASIC: ##$basic##\nYou automatically mark Special Enemies by ADSing at them.\nYour Jokers will focus attacks at Marked enemies that you ADS at.\n\nACE: ##$pro##\nYour Jokers deal ##+25%## Damage to Marked enemies.",
				menu_service_above_self = "Service above Self",
				menu_service_above_self_desc = "BASIC: ##$basic##\nIncreases the maximum number of Jokers you can have active at one time to ##2##.\n\nACE: ##$pro##\nIf one of your Jokers is nearby and you are targeted by a Cloaker or shocked by a Taser, your Joker will tackle the Special Enemy and knock them down. This can only occur once every ##30## seconds.",
			
			--enforcer
				menu_tender_meat = "Tender Meat",
				menu_tender_meat_desc = "BASIC: ##$basic##\n$ICN_SHO Shotguns deal ##50%## of their Headshot damage on Body Shots against Non-Dozer enemies.\n\nACE: ##$pro##\n$ICN_SHO Shotguns gain ##+40## Stability.",
				menu_heartbreaker = "Heartbreaker",
				menu_heartbreaker_desc = "BASIC: ##$basic##\nDouble Barreled $ICN_SHO Shotguns can use the Fire Selector to switch to ##Double Barrel Mode##, causing them to fire twice per shot.\n\nACE: ##$pro##\nEach shot in ##Double Barrel Mode## deals ##+100%## Damage when firing both barrels.",
				menu_shell_games = "Shell Games",
				menu_shell_games_desc = "BASIC: ##$basic##\n$ICN_SHO Shotguns gain ##+20%## Reload Speed every time a shell is loaded.\nBonuses are lost upon finishing or cancelling the Reload.\n\nACE: ##$pro##\nSingle-Fire $ICN_SHO Shotguns have their Fire Rate increased by ##50%##.",
				menu_rolling_thunder = "Rolling Thunder",
				menu_rolling_thunder_desc = "BASIC: ##$basic##\nIncreases the Magazine Size of Automatic $ICN_SHO Shotguns by ##50%##.\n\nACE: ##$pro##\nMagazine Size bonus increased to ##100%##.",
				menu_point_blank = "Point Blank",
				menu_point_blank_desc = "BASIC: ##$basic##\n$ICN_SHO Shotguns gain ##Armor Piercing##, ##Shield Piercing##, and ##Body Piercing## against enemies within ##2.5## meters.\n\nACE: ##$pro##\n$ICN_SHO Shotguns deal ##+100%## Damage against enemies within ##2.5## meters.",
				menu_shotmaker = "Shotmaker",
				menu_shotmaker_desc = "BASIC: ##$basic##\nIncreases $ICN_SHO Shotgun Headshot Damage by ##+50%##.\n\nACE: ##$pro##\n$ICN_SHO Shotgun Headshot Damage is increased by an additional ##+50%##, for a total of ##+100%##.",
				
			--heavy
				menu_collateral_damage = "Collateral Damage",
				menu_collateral_damage_desc = "BASIC: ##$basic##\n$ICN_HVY Heavy Weapons deal ##50%## of their damage in a ##0.25## meter radius around the bullet trajectory.\n\nACE: ##$pro##\n$ICN_HVY Heavy Weapons ADS ##50%## faster.",
				menu_death_grips = "Death Grips",
				menu_death_grips_desc = "BASIC: ##$basic##\n$ICN_HVY Heavy Weapons gain ##+4## Accuracy and ##+4## Stability for 8 seconds per kill, stacking up to ##10## times.\n\nACE: ##$pro##\nAccuracy bonus increased to ##+8##.",
				menu_bulletstorm = "Bulletstorm",
				menu_bulletstorm_desc = "BASIC: ##$basic##\nAmmo Bags placed by you grant players the ability to shoot without depleting their ammunition for up to ##5## seconds after interacting with it.\nThe more ammo players replenish, the longer the duration of the effect.\n\nACE: ##$pro##\nIncreases the base duration of the effect by up to ##15## seconds.",
				menu_lead_farmer = "Lead Farmer",
				menu_lead_farmer_desc = "BASIC: ##$basic##\n$ICN_HVY Heavy Weapons gain ##+1%## Reload Speed per kill on their next Reload, up to ##50%##.\n\nACE: ##$pro##\nIncreases the amount of Reload Speed per kill to ##2%## and the maximum amount of Reload Speed to ##100%##.",
				menu_armory_regular = "Armory Regular",
				menu_armory_regular_desc = "BASIC: ##$basic##\nIncreases your Ammo Bag supply to ##2##.\n\nACE: ##$pro##\nIncreases your Ammo Bag supply to ##3##.",
				menu_war_machine = "War Machine",
				menu_war_machine_desc = "BASIC: ##$basic##\nIncreases the Ammo Bag's Ammunition Stock bonus for $ICN_HVY Heavy Weapons to ##+100%##.\n\nACE: ##$pro##\nIncreases the Ammo Bag's Ammunition Stock bonus to ##+100%## for non-Heavy weapons and ##+200%## for $ICN_HVY Heavy Weapons.",
				
			--runner
				menu_hustle = "Hustle",
				menu_hustle_desc = "BASIC: ##$basic##\nYou can Sprint in any direction.\n\nACE: ##$pro##\nYour Stamina starts regenerating ##25%## earlier and ##+25%## faster.",
				menu_butterfly_bee = "Float Like A Butterfly",
				menu_butterfly_bee_desc = "BASIC: ##$basic##\n$ICN_MEL Melee Weapons can be swung and charged while Sprinting.\n\nACE: ##$pro##\n$ICN_MEL Melee Weapon damage increases your Movement Speed by ##+10%## for ##4## seconds.",
				menu_heave_ho = "Heave-Ho",
				menu_heave_ho_desc = "BASIC: ##$basic##\nYou throw Bags ##50%## farther.\n\nACE: ##$pro##\nYour Movement Speed Penalty for carrying a Bag is reduced by ##20%##, and you can ##Sprint while carrying a Bag##.",
				menu_mobile_offense = "Mobile Offense",
				menu_mobile_offense_desc = "BASIC: ##$basic##\nYou can now Reload while Sprinting.\n\nACE: ##$pro##\nYou can now hip-fire weapons while Sprinting.",
				menu_escape_plan = "Escape Plan",
				menu_escape_plan_desc = "BASIC: ##$basic##\nWhen your Armor breaks, you gain ##100%## of your Stamina and gain ##+25%## Sprint Speed for ##4## seconds.\n\nACE: ##$pro##\nYou also gain ##+20%## Movement Speed for ##4## seconds.",
				menu_leg_day = "Leg Day Enthusiast",
				menu_leg_day_desc = "BASIC: ##$basic##\nYou gain ##+10%## Movement Speed and ##+25%## Sprint Speed.\n\nACE: ##$pro##\nCrouching no longer reduces your Movement Speed.",
				
			--gunner
				menu_spray_and_pray = "Spray & Pray",
				menu_spray_and_pray_desc = "BASIC: ##$basic##\n$ICN_RPF Rapid Fire weapons gain ##+10%## Critical Hit chance.\n\nACE: ##$pro##\n$ICN_RPF Rapid Fire weapons can now pierce Body Armor.",
				menu_money_shot = "Money Shot",
				menu_money_shot_desc = "BASIC: ##$basic##\n$ICN_RPF Rapid Fire weapons deal ##+100%## Damage in a ##2.5## meter radius on impact when firing the last bullet from a fully loaded magazine.\n\nACE: ##$pro##\n$ICN_RPF Rapid Fire weapons gain ##+50%## faster Reload Speed when their Magazine is empty.",
				menu_shot_grouping = "Shot Grouping",
				menu_shot_grouping_desc = "BASIC: ##$basic##\n$ICN_RPF Rapid Fire weapons ADS ##+90%## faster.\n\nACE: ##$pro##\n$ICN_RPF Rapid Fire weapons gain ##+40 Accuracy and Stability while ADSing.##",
				menu_making_miracles = "Making Miracles",
				menu_making_miracles_desc = "BASIC: ##$basic##\n$ICN_RPF Rapid Fire weapons gain ##+1%## Critical Hit chance for ##4## seconds when hitting an enemy with a Headshot, stacking up to ##+10%##.\n\nACE: ##$pro##\nKilling an enemy with a Headshot generates an additional stack. Maximum bonus increased to ##+20%##.",
				menu_close_enough = "Close Enough",
				menu_close_enough_desc = "BASIC: ##$basic##\n$ICN_RPF Rapid Fire bullets that strike hard surfaces ##ricochet once##.\n\nACE: ##$pro##\nCritical Hits cause ricochets to ##angle towards the closest enemy##.",
				menu_prayers_answered = "Prayers Answered",
				menu_prayers_answered_desc = "BASIC: ##$basic##\n$ICN_RPF Rapid Fire weapons have their Critical Hit chance increased by ##+10%##, for a total of ##+20%##.\n\nACE: ##$pro##\n$ICN_RPF Rapid Fire weapons have their Critical Hit chance further increased by ##+10%##, for a total of ##+30%##.",
				
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
				menu_good_hunting_desc = "BASIC: ##$basic##\nBows have all of their Arrows readied instead of in reserve.\n\nACE: ##$pro##\nCrossbows instantly Reload themselves after a Headshot.",
				menu_comfortable_silence = "Comfortable Silence",
				menu_comfortable_silence_desc = "BASIC: ##$basic##\n$ICN_QUT Quiet Weapons gain ##+2## Concealment.\n\nACE: ##$pro##\n$ICN_QUT Quiet Weapons gain ##+4## Concealment.",
				menu_toxic_shock = "Toxic Shock",
				menu_toxic_shock_desc = "BASIC: ##$basic##\nSuccessfully $ICN_POI Poisoning an enemy will also $ICN_POI Poison enemies within a ##3##-meter radius.\n\nACE: ##$pro##\n$ICN_POI Poison deals ##+100%## damage.",
				menu_professionals_choice = "Professional's Choice",
				menu_professionals_choice_desc = "BASIC: ##$basic##\n$ICN_QUT Quiet Weapons gain a ##+2% Fire Rate bonus## for every ##3## points of Detection Risk under ##35##, up to ##+10%##.\n\nACE: ##$pro##\nThe Fire Rate bonus is increased to ##+4%## and the maximum bonus is increased to ##+20%##.",
				menu_quiet_grave = "Quiet as the Grave",
				menu_quiet_grave_desc = "BASIC: ##$basic##\n$ICN_QUT Quiet Weapons deal ##+10%## Damage when attacking an enemy from behind.\n\nACE: ##$pro##\n$ICN_QUT Quiet Weapons also deal ##+10%## Damage when attacking an enemy that is not currently targeting you.",
			
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
				menu_high_low_desc = "BASIC: ##$basic##\nYou gain ##+80%## Swap Speed and Stow Speed with all weapon types.\n\nACE: ##$pro##\nYou deal ##+10%## with $ICN_MEL Melee Weapons and $ICN_THR Throwing Weapons.",
			
				menu_wild_card = "Wild Card",
				menu_wild_card_desc = "BASIC: ##$basic##\n$ICN_MEL Melee Weapons can score Headshots.\n\nACE: ##$pro##\n$ICN_THR Throwing Weapons gain ##+100%## Headshot Damage.",
			
				menu_value_bet = "Value Bet",
				menu_value_bet_desc = "BASIC: ##$basic##\n$ICN_THR Throwing Weapons can be charged, dealing ##+100%## Damage after being held for ##1## second.\n\nACE: ##$pro##\n$ICN_MEL Melee Weapons gain ##+100%## Charge Speed.",
			
				menu_face_value = "Face Value",
				menu_face_value_desc = "BASIC: ##$basic##\nIncreases the Knockdown strength of your $ICN_MEL Melee Weapons by ##one stage##.\n\nACE: ##$pro##\nAttacking a Shield with any $ICN_MEL Melee Weapon will stagger them.",
			
				menu_stacking_deck = "Stacking the Deck",
				menu_stacking_deck_desc = "BASIC: ##$basic##\n$ICN_THR Throwing Weapons gain ##+50%## Ammunition.\n\nACE: ##$pro##\n$ICN_THR Throwing Weapons gain ##+100%## increased Velocity, increasing their speed and range.",
			
				menu_shuffle_and_cut = "Shuffle and Cut",
				menu_shuffle_and_cut_desc = "BASIC: ##$basic##\nHitting an enemy with a $ICN_THR Throwing Weapon grants ##+500%## Damage to your $ICN_MEL Melee Weapons for ##5## seconds.\n\nACE: ##$pro##\nHitting an enemy with a $ICN_MEL Melee Weapon grants ##+500%## Damage to $ICN_THR Throwing Weapons for ##5## seconds.",
			
			
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
				
				--[[
				,
				
				--Rogue
				menu_deck4_1 = "PLACEHOLDER",
				menu_deck4_1_desc = "PLACEHOLDER",
				menu_deck4_2 = "PLACEHOLDER",
				menu_deck4_2_desc = "PLACEHOLDER",
				menu_deck4_3 = "PLACEHOLDER",
				menu_deck4_3_desc = "PLACEHOLDER",
				menu_deck4_4 = "PLACEHOLDER",
				menu_deck4_4_desc = "PLACEHOLDER",
				menu_deck4_5 = "PLACEHOLDER",
				menu_deck4_5_desc = "PLACEHOLDER",
				menu_deck4_6 = "PLACEHOLDER",
				menu_deck4_6_desc = "PLACEHOLDER",
				menu_deck4_7 = "PLACEHOLDER",
				menu_deck4_7_desc = "PLACEHOLDER",
				menu_deck4_8 = "PLACEHOLDER",
				menu_deck4_8_desc = "PLACEHOLDER",
				menu_deck4_9 = "PLACEHOLDER",
				menu_deck4_9_desc = "PLACEHOLDER",
				
				--Crook
				menu_deck5_1 = "PLACEHOLDER",
				menu_deck5_1_desc = "PLACEHOLDER",
				menu_deck5_2 = "PLACEHOLDER",
				menu_deck5_2_desc = "PLACEHOLDER",
				menu_deck5_3 = "PLACEHOLDER",
				menu_deck5_3_desc = "PLACEHOLDER",
				menu_deck5_4 = "PLACEHOLDER",
				menu_deck5_4_desc = "PLACEHOLDER",
				menu_deck5_5 = "PLACEHOLDER",
				menu_deck5_5_desc = "PLACEHOLDER",
				menu_deck5_6 = "PLACEHOLDER",
				menu_deck5_6_desc = "PLACEHOLDER",
				menu_deck5_7 = "PLACEHOLDER",
				menu_deck5_7_desc = "PLACEHOLDER",
				menu_deck5_8 = "PLACEHOLDER",
				menu_deck5_8_desc = "PLACEHOLDER",
				menu_deck5_9 = "PLACEHOLDER",
				menu_deck5_9_desc = "PLACEHOLDER",
				
				--Hitman
				menu_deck6_1 = "PLACEHOLDER",
				menu_deck6_1_desc = "PLACEHOLDER",
				menu_deck6_2 = "PLACEHOLDER",
				menu_deck6_2_desc = "PLACEHOLDER",
				menu_deck6_3 = "PLACEHOLDER",
				menu_deck6_3_desc = "PLACEHOLDER",
				menu_deck6_4 = "PLACEHOLDER",
				menu_deck6_4_desc = "PLACEHOLDER",
				menu_deck6_5 = "PLACEHOLDER",
				menu_deck6_5_desc = "PLACEHOLDER",
				menu_deck6_6 = "PLACEHOLDER",
				menu_deck6_6_desc = "PLACEHOLDER",
				menu_deck6_7 = "PLACEHOLDER",
				menu_deck6_7_desc = "PLACEHOLDER",
				menu_deck6_8 = "PLACEHOLDER",
				menu_deck6_8_desc = "PLACEHOLDER",
				menu_deck6_9 = "PLACEHOLDER",
				menu_deck6_9_desc = "PLACEHOLDER",
				
				--Burglar
				menu_deck7_1 = "PLACEHOLDER",
				menu_deck7_1_desc = "PLACEHOLDER",
				menu_deck7_2 = "PLACEHOLDER",
				menu_deck7_2_desc = "PLACEHOLDER",
				menu_deck7_3 = "PLACEHOLDER",
				menu_deck7_3_desc = "PLACEHOLDER",
				menu_deck7_4 = "PLACEHOLDER",
				menu_deck7_4_desc = "PLACEHOLDER",
				menu_deck7_5 = "PLACEHOLDER",
				menu_deck7_5_desc = "PLACEHOLDER",
				menu_deck7_6 = "PLACEHOLDER",
				menu_deck7_6_desc = "PLACEHOLDER",
				menu_deck7_7 = "PLACEHOLDER",
				menu_deck7_7_desc = "PLACEHOLDER",
				menu_deck7_8 = "PLACEHOLDER",
				menu_deck7_8_desc = "PLACEHOLDER",
				menu_deck7_9 = "PLACEHOLDER",
				menu_deck7_9_desc = "PLACEHOLDER",
				
				--Infiltrator
				menu_deck8_1 = "PLACEHOLDER",
				menu_deck8_1_desc = "PLACEHOLDER",
				menu_deck8_2 = "PLACEHOLDER",
				menu_deck8_2_desc = "PLACEHOLDER",
				menu_deck8_3 = "PLACEHOLDER",
				menu_deck8_3_desc = "PLACEHOLDER",
				menu_deck8_4 = "PLACEHOLDER",
				menu_deck8_4_desc = "PLACEHOLDER",
				menu_deck8_5 = "PLACEHOLDER",
				menu_deck8_5_desc = "PLACEHOLDER",
				menu_deck8_6 = "PLACEHOLDER",
				menu_deck8_6_desc = "PLACEHOLDER",
				menu_deck8_7 = "PLACEHOLDER",
				menu_deck8_7_desc = "PLACEHOLDER",
				menu_deck8_8 = "PLACEHOLDER",
				menu_deck8_8_desc = "PLACEHOLDER",
				menu_deck8_9 = "PLACEHOLDER",
				menu_deck8_9_desc = "PLACEHOLDER",
				
				--Sociopath
				menu_deck9_1 = "PLACEHOLDER",
				menu_deck9_1_desc = "PLACEHOLDER",
				menu_deck9_2 = "PLACEHOLDER",
				menu_deck9_2_desc = "PLACEHOLDER",
				menu_deck9_3 = "PLACEHOLDER",
				menu_deck9_3_desc = "PLACEHOLDER",
				menu_deck9_4 = "PLACEHOLDER",
				menu_deck9_4_desc = "PLACEHOLDER",
				menu_deck9_5 = "PLACEHOLDER",
				menu_deck9_5_desc = "PLACEHOLDER",
				menu_deck9_6 = "PLACEHOLDER",
				menu_deck9_6_desc = "PLACEHOLDER",
				menu_deck9_7 = "PLACEHOLDER",
				menu_deck9_7_desc = "PLACEHOLDER",
				menu_deck9_8 = "PLACEHOLDER",
				menu_deck9_8_desc = "PLACEHOLDER",
				menu_deck9_9 = "PLACEHOLDER",
				menu_deck9_9_desc = "PLACEHOLDER",
				
				--Gambler
				menu_deck10_1 = "PLACEHOLDER",
				menu_deck10_1_desc = "PLACEHOLDER",
				menu_deck10_2 = "PLACEHOLDER",
				menu_deck10_2_desc = "PLACEHOLDER",
				menu_deck10_3 = "PLACEHOLDER",
				menu_deck10_3_desc = "PLACEHOLDER",
				menu_deck10_4 = "PLACEHOLDER",
				menu_deck10_4_desc = "PLACEHOLDER",
				menu_deck10_5 = "PLACEHOLDER",
				menu_deck10_5_desc = "PLACEHOLDER",
				menu_deck10_6 = "PLACEHOLDER",
				menu_deck10_6_desc = "PLACEHOLDER",
				menu_deck10_7 = "PLACEHOLDER",
				menu_deck10_7_desc = "PLACEHOLDER",
				menu_deck10_8 = "PLACEHOLDER",
				menu_deck10_8_desc = "PLACEHOLDER",
				menu_deck10_9 = "PLACEHOLDER",
				menu_deck10_9_desc = "PLACEHOLDER",
				
				--Grinder
				menu_deck11_1 = "PLACEHOLDER",
				menu_deck11_1_desc = "PLACEHOLDER",
				menu_deck11_2 = "PLACEHOLDER",
				menu_deck11_2_desc = "PLACEHOLDER",
				menu_deck11_3 = "PLACEHOLDER",
				menu_deck11_3_desc = "PLACEHOLDER",
				menu_deck11_4 = "PLACEHOLDER",
				menu_deck11_4_desc = "PLACEHOLDER",
				menu_deck11_5 = "PLACEHOLDER",
				menu_deck11_5_desc = "PLACEHOLDER",
				menu_deck11_6 = "PLACEHOLDER",
				menu_deck11_6_desc = "PLACEHOLDER",
				menu_deck11_7 = "PLACEHOLDER",
				menu_deck11_7_desc = "PLACEHOLDER",
				menu_deck11_8 = "PLACEHOLDER",
				menu_deck11_8_desc = "PLACEHOLDER",
				menu_deck11_9 = "PLACEHOLDER",
				menu_deck11_9_desc = "PLACEHOLDER",
				
				--Yakuza
				menu_deck12_1 = "PLACEHOLDER",
				menu_deck12_1_desc = "PLACEHOLDER",
				menu_deck12_2 = "PLACEHOLDER",
				menu_deck12_2_desc = "PLACEHOLDER",
				menu_deck12_3 = "PLACEHOLDER",
				menu_deck12_3_desc = "PLACEHOLDER",
				menu_deck12_4 = "PLACEHOLDER",
				menu_deck12_4_desc = "PLACEHOLDER",
				menu_deck12_5 = "PLACEHOLDER",
				menu_deck12_5_desc = "PLACEHOLDER",
				menu_deck12_6 = "PLACEHOLDER",
				menu_deck12_6_desc = "PLACEHOLDER",
				menu_deck12_7 = "PLACEHOLDER",
				menu_deck12_7_desc = "PLACEHOLDER",
				menu_deck12_8 = "PLACEHOLDER",
				menu_deck12_8_desc = "PLACEHOLDER",
				menu_deck12_9 = "PLACEHOLDER",
				menu_deck12_9_desc = "PLACEHOLDER",
				
				--Ex-President
				menu_deck13_1 = "PLACEHOLDER",
				menu_deck13_1_desc = "PLACEHOLDER",
				menu_deck13_2 = "PLACEHOLDER",
				menu_deck13_2_desc = "PLACEHOLDER",
				menu_deck13_3 = "PLACEHOLDER",
				menu_deck13_3_desc = "PLACEHOLDER",
				menu_deck13_4 = "PLACEHOLDER",
				menu_deck13_4_desc = "PLACEHOLDER",
				menu_deck13_5 = "PLACEHOLDER",
				menu_deck13_5_desc = "PLACEHOLDER",
				menu_deck13_6 = "PLACEHOLDER",
				menu_deck13_6_desc = "PLACEHOLDER",
				menu_deck13_7 = "PLACEHOLDER",
				menu_deck13_7_desc = "PLACEHOLDER",
				menu_deck13_8 = "PLACEHOLDER",
				menu_deck13_8_desc = "PLACEHOLDER",
				menu_deck13_9 = "PLACEHOLDER",
				menu_deck13_9_desc = "PLACEHOLDER",
				
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
				
				--Anarchist
				menu_deck15_1 = "PLACEHOLDER",
				menu_deck15_1_desc = "PLACEHOLDER",
				menu_deck15_2 = "PLACEHOLDER",
				menu_deck15_2_desc = "PLACEHOLDER",
				menu_deck15_3 = "PLACEHOLDER",
				menu_deck15_3_desc = "PLACEHOLDER",
				menu_deck15_4 = "PLACEHOLDER",
				menu_deck15_4_desc = "PLACEHOLDER",
				menu_deck15_5 = "PLACEHOLDER",
				menu_deck15_5_desc = "PLACEHOLDER",
				menu_deck15_6 = "PLACEHOLDER",
				menu_deck15_6_desc = "PLACEHOLDER",
				menu_deck15_7 = "PLACEHOLDER",
				menu_deck15_7_desc = "PLACEHOLDER",
				menu_deck15_8 = "PLACEHOLDER",
				menu_deck15_8_desc = "PLACEHOLDER",
				menu_deck15_9 = "PLACEHOLDER",
				menu_deck15_9_desc = "PLACEHOLDER",
				
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
				menu_deck18_1 = "PLACEHOLDER",
				menu_deck18_1_desc = "PLACEHOLDER",
				menu_deck18_2 = "PLACEHOLDER",
				menu_deck18_2_desc = "PLACEHOLDER",
				menu_deck18_3 = "PLACEHOLDER",
				menu_deck18_3_desc = "PLACEHOLDER",
				menu_deck18_4 = "PLACEHOLDER",
				menu_deck18_4_desc = "PLACEHOLDER",
				menu_deck18_5 = "PLACEHOLDER",
				menu_deck18_5_desc = "PLACEHOLDER",
				menu_deck18_6 = "PLACEHOLDER",
				menu_deck18_6_desc = "PLACEHOLDER",
				menu_deck18_7 = "PLACEHOLDER",
				menu_deck18_7_desc = "PLACEHOLDER",
				menu_deck18_8 = "PLACEHOLDER",
				menu_deck18_8_desc = "PLACEHOLDER",
				menu_deck18_9 = "PLACEHOLDER",
				menu_deck18_9_desc = "PLACEHOLDER",
				
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
				
				--Tag Team
				menu_deck20_1 = "PLACEHOLDER",
				menu_deck20_1_desc = "PLACEHOLDER",
				menu_deck20_2 = "PLACEHOLDER",
				menu_deck20_2_desc = "PLACEHOLDER",
				menu_deck20_3 = "PLACEHOLDER",
				menu_deck20_3_desc = "PLACEHOLDER",
				menu_deck20_4 = "PLACEHOLDER",
				menu_deck20_4_desc = "PLACEHOLDER",
				menu_deck20_5 = "PLACEHOLDER",
				menu_deck20_5_desc = "PLACEHOLDER",
				menu_deck20_6 = "PLACEHOLDER",
				menu_deck20_6_desc = "PLACEHOLDER",
				menu_deck20_7 = "PLACEHOLDER",
				menu_deck20_7_desc = "PLACEHOLDER",
				menu_deck20_8 = "PLACEHOLDER",
				menu_deck20_8_desc = "PLACEHOLDER",
				menu_deck20_9 = "PLACEHOLDER",
				menu_deck20_9_desc = "PLACEHOLDER",
				
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