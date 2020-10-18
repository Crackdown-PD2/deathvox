

Hooks:PostHook(UpgradesTweakData, "init", "vox_overhaul1", function(self, tweak_data)
	if deathvox and deathvox:IsTotalCrackdownEnabled() then
		self.armor_plates_base = 4 --armor plates deployable
		self.armor_plates_dmg_reduction = 0.85 -- damage_applied = kevlar_plates_dmg_reduction * incoming_damage, so eg. 0.9 = 10% damage reduction
	
		
		self.values.player.revive_damage_reduction = {
			0.5 --up from vanilla 30% reduction
		}
		
		self.values.player.body_armor.armor = {
			0,
			3,
			4,
			6,
			8,
			12,
			18
		}
		
		--speed = value / 35
		self.values.player.body_armor.movement = {
			1.05, --36.8
			1.025, --35.9
			1, --35
			0.95, --33.3
			30 / 35, --30
			25 / 35, --25
			20 / 35
		}
		self.values.player.body_armor.concealment = {
			30,
			28,
			26,
			24,
			22,
			10,
			1
		}
		self.values.player.body_armor.dodge = {
			0.15,
			0.05,
			0,
			-0.05,
			-0.3,
			-0.5,
			-1
		}
		self.values.player.body_armor.damage_shake = {
			1,
			0.96,
			0.92,
			0.85,
			0.6125,
			0.525,
			0.44
		}
		--stamina is unchanged
	
	--weapon classification categories
		self.values.NO_WEAPON_CLASS = {} --addresses weapons whose weapon class has not been implemented
		self.values.rapidfire = self.values.rapidfire or {}
		self.values.class_shotgun = self.values.class_shotgun or {}
		self.values.precision = self.values.precision or {}
		self.values.heavy = self.values.heavy or {}
		self.values.specialist = self.values.specialist or {}
		self.values.class_saw = self.values.class_saw or {}
		self.values.class_grenade = self.values.class_grenade or {}
		self.values.class_throwing = self.values.class_throwing or {}
		self.values.class_melee = self.values.class_melee or {} 
	--weapon subclass categories
		self.values.subclass_poison = self.values.subclass_poison or {}
		self.values.subclass_quiet = self.values.subclass_quiet or {}
		self.values.subclass_areadenial = self.values.subclass_areadenial or {}
		--todo make these consistent with the names in the converter script
		
		
		--Boss
		
		--Marksman
		
		self.definitions.player_point_and_click_basic = {
			name_id = "menu_point_and_click_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "point_and_click_stacks",
				category = "player"
			}
		}
		self.values.player.point_and_click_stacks = { 
			1		--stacks per hit
		}

		self.definitions.weapon_point_and_click_damage_bonus = {
			name_id = "menu_weapon_point_and_click_damage_bonus",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "point_and_click_damage_bonus",
				category = "weapon"
			}
		}
		self.values.weapon.point_and_click_damage_bonus = {
			{0.01,5} --% bonus damage per stack, max bonus damage
		}
		
		self.definitions.weapon_marksman_steelsight_speed_multiplier = {
			name_id = "menu_marksman_steelsight_speed_multiplier",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "enter_steelsight_speed_multiplier",
				category = "precision"
			}
		}
		self.values.precision.enter_steelsight_speed_multiplier = { 
			0.1 --was 2 for vanilla upgrade
		}
		
		self.definitions.weapon_tap_the_trigger_basic = {
			name_id = "menu_tap_the_trigger_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "point_and_click_rof_bonus",
				category = "weapon"
			}
		}
		
		self.definitions.weapon_tap_the_trigger_aced = {
			name_id = "menu_tap_the_trigger_aced",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "point_and_click_rof_bonus",
				category = "weapon"
			}
		}
		self.values.weapon.point_and_click_rof_bonus = {
			{0.01,0.5}, --% bonus rof per stack
			{0.01,1}
		}
		
		self.definitions.player_investment_returns_basic = {
			name_id = "menu_investment_returns_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "point_and_click_stack_from_kill",
				category = "player"
			}
		}
		self.values.player.point_and_click_stack_from_kill = {
			1 --on kill
		}
		
		self.definitions.player_investment_returns_aced = {
			name_id = "menu_investment_returns_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "point_and_click_stack_from_headshot_kill",
				category = "player"
			}
		}
		self.values.player.point_and_click_stack_from_headshot_kill = {
			1 --on headshot kill
		}
		
		self.definitions.weapon_this_machine_basic = {
			name_id = "menu_this_machine_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "point_and_click_bonus_reload_speed",
				category = "weapon"
			}
		}
		self.definitions.weapon_this_machine_aced = {
			name_id = "menu_this_machine_aced",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "point_and_click_bonus_reload_speed",
				category = "weapon"
			}
		}
		self.values.weapon.point_and_click_bonus_reload_speed = {
			{0.005,0.25},
			{0.005,0.5}
		}
		
		self.definitions.player_mulligan_basic = {
			name_id = "menu_mulligan_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "point_and_click_stack_mulligan",
				category = "player"
			}
		}
		self.definitions.player_mulligan_aced = {
			name_id = "menu_mulligan_aced",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "point_and_click_stack_mulligan",
				category = "player"
			}
		}
		self.values.player.point_and_click_stack_mulligan = {
			1,
			1.5
		}
		
		self.definitions.weapon_magic_bullet_basic = {
			name_id = "menu_magic_bullet_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "magic_bullet",
				category = "weapon"
			}
		}
		self.definitions.weapon_magic_bullet_aced = {
			name_id = "menu_magic_bullet_aced",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "magic_bullet",
				category = "weapon"
			}
		}
		self.values.weapon.magic_bullet = {
			1,1 --these don't actually mean anything; i plan to use upgrade_level() instead or whatever
		}
		
	
		
		
		--Medic
		
		--Chief
		
		--Enforcer
		
		self.values.class_shotgun.tender_meat_bodyshots = {
			0.5
		}
		self.definitions.class_weapon_tender_meat_bodyshots = {
			name_id = "menu_tender_meat_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "tender_meat_bodyshots",
				category = "class_shotgun"
			}
		}
		
		self.values.class_shotgun.recoil_index_addend = {
			10
		}
		self.definitions.class_shotgun_tender_meat_stability = {
			name_id = "menu_tender_meat_aced",
			category = "feature",
			upgrade = {
			value = 1,
			upgrade = "recoil_index_addend",
				category = "class_shotgun"
			}
		}
		
		self.values.class_shotgun.heartbreaker_doublebarrel = {
			true
		}
		self.definitions.class_shotgun_doublebarrel_firemode = {
			name_id = "menu_heartbreaker_basic",
			category = "feature",
			upgrade = {
			value = 1,
			upgrade = "heartbreaker_doublebarrel",
				category = "class_shotgun"
			}
		}
		
		self.values.class_shotgun.heartbreaker_damage = {
			1
		}
		self.definitions.class_shotgun_doublebarrel_damage = {
			name_id = "menu_heartbreaker_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "heartbreaker_damage",
				category = "class_shotgun"
			}
		}
		
		self.values.class_shotgun.shell_games_reload_bonus = {
			0.2 --% stack per shell reloaded
		}
		self.definitions.class_shotgun_shell_games_reload_bonus = {
			name_id = "menu_shell_games_basic",
			category = "feature",
			upgrade = {
			value = 1,
			upgrade = "shell_games_reload_bonus",
				category = "class_shotgun"
			}
		}
		
		self.values.class_shotgun.shell_games_rof_bonus = {
			0.5
		}
		self.definitions.class_shotgun_shell_games_rof_bonus = {
			name_id = "menu_shell_games_aced",
			category = "feature",
			upgrade = {
			value = 1,
			upgrade = "shell_games_rof_bonus",
				category = "class_shotgun"
			}
		}
		
		self.values.class_shotgun.rolling_thunder_magazine_capacity_bonus = {
			0.5,
			1
		}
		self.definitions.class_shotgun_rolling_thunder_magazine_size_1 = {
			name_id = "menu_rolling_thunder_basic",
			category = "feature",
			upgrade = {
			value = 1,
			upgrade = "rolling_thunder_magazine_capacity_bonus",
				category = "class_shotgun"
			}
		}
		self.definitions.class_shotgun_rolling_thunder_magazine_size_2 = {
			name_id = "menu_rolling_thunder_aced",
			category = "feature",
			upgrade = {
			value = 2,
			upgrade = "rolling_thunder_magazine_capacity_bonus",
				category = "class_shotgun"
			}
		}
		
		self.values.class_shotgun.point_blank_basic = {
			250 --2.5m
		}
		self.values.class_shotgun.point_blank_aced = {
			1
		}
		self.definitions.class_shotgun_point_blank_shotgun_basic = {
			name_id = "menu_point_blank_shotgun_basic",
			category = "feature",
			upgrade = {
			value = 1,
			upgrade = "point_blank_basic",
				category = "class_shotgun"
			}
		}
					
		self.definitions.class_shotgun_point_blank_shotgun_aced = {
			name_id = "menu_point_blank_shotgun_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "point_blank_aced",
				category = "class_shotgun"
			}
		}
		
		self.values.class_shotgun.headshot_mul_addend = {
			0.5,
			1
		}
		self.definitions.class_shotgun_shotmaker_headshot_damage_bonus_1 = {
			name_id = "menu_shotmaker_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "headshot_mul_addend",
				category = "class_shotgun"
			}
		}
		self.definitions.class_shotgun_shotmaker_headshot_damage_bonus_2 = {
			name_id = "menu_shotmaker_aced",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "headshot_mul_addend",
				category = "class_shotgun"
			}
		}
		
		
		--Heavy
		
		--Runner
		
		--Gunner
		
		self.values.rapidfire.enter_steelsight_speed_multiplier = {
			0.1
		}
		
		self.definitions.weapon_spray_and_pray_basic = {
			name_id = "menu_spray_and_pray_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "enter_steelsight_speed_multiplier",
				category = "rapidfire"
			}
		}
		
		self.values.weapon.money_shot = {
			{
				1, --100% damage
				250 --over 2.5 meters
			}
		}
		
		self.values.weapon.money_shot_aced = {
			1.5
		}
			
		self.definitions.weapon_moneyshot_rapid_fire_basic = {
			name_id = "menu_moneyshot_rapid_fire_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "money_shot",
				category = "weapon"
			}
		}
					
		self.definitions.weapon_moneyshot_rapid_fire_aced = {
			name_id = "menu_moneyshot_rapid_fire_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "money_shot_aced",
				category = "weapon"
			}
		}
		
		self.values.rapidfire.shotgrouping_aced = { 
			14 --accuracy/stability index addend
		}
		
		self.values.rapidfire.enter_steelsight_speed_multiplier = { 
			0.1
		}
		
		self.definitions.rapidfire_shotgrouping_basic = {
			name_id = "menu_shotgrouping_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "enter_steelsight_speed_multiplier",
				category = "rapidfire"
			}
		}
					
		self.definitions.rapidfire_shotgrouping_aced = {
			name_id = "menu_shotgrouping_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "shotgrouping_aced",
				category = "rapidfire"
			}
		}
	
		self.values.player.ricochet_bullets = {
			true
		}
			
		self.values.player.ricochet_bullets_aced = {
			true
		}
		
		self.definitions.player_ricochet_rapid_fire_basic = {
			name_id = "menu_ricochet_rapid_fire_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "ricochet_bullets",
				category = "player"
			}
		}
					
		self.definitions.player_ricochet_rapid_fire_aced = {
			name_id = "menu_ricochet_rapid_fire_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "ricochet_bullets_aced",
				category = "player"
			}
		}
		
		
		
		
		self.values.weapon.making_miracles_basic = {
			{
				0.01, --crit chance per stack
				4 --duration
			}
		}
		
		self.values.weapon.making_miracles_crit_cap = {
			0.1,
			0.2
		}
		
		self.values.weapon.making_miracles_aced = {
			true
		}
		
		self.definitions.weapon_making_miracles_basic = {
			name_id = "menu_making_miracles_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "making_miracles_basic",
				category = "weapon"
			}
		}
		
		self.definitions.weapon_making_miracles_aced = {
			name_id = "menu_making_miracles_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "making_miracles_aced",
				category = "weapon"
			}
		}
		
		self.definitions.weapon_making_miracles_crit_cap_1 = {
			name_id = "menu_making_miracles_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "making_miracles_crit_cap",
				category = "weapon"
			}
		}
		
		self.definitions.weapon_making_miracles_crit_cap_2 = {
			name_id = "menu_making_miracles_aced",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "making_miracles_crit_cap",
				category = "weapon"
			}
		}
		
		
		
		
		self.values.weapon.prayers_answered = {
			0.1,
			0.2
		}
		
		self.definitions.weapon_prayers_answered_basic = {
			name_id = "menu_prayers_answered_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "prayers_answered",
				category = "weapon"
			}
		}
		
		self.definitions.weapon_prayers_answered_aced = {
			name_id = "menu_prayers_answered_aced",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "prayers_answered",
				category = "weapon"
			}
		}
		
		--Engineer
		self.definitions.player_digging_in_deploy_time = {
			name_id = "menu_digging_in_deploy",
			category = "feature",
			upgrade = {
				value = 2, --skip over base-game value... oh boy i sure hope pd2's upgrade system is well-written and doesn't bug out and give the value for index 1!!!!
				upgrade = "sentry_gun_deploy_time_multiplier",
				category = "player"
			}
		}
		self.values.player.sentry_gun_deploy_time_multiplier = {
			0.5, --base-game
			0.1  --total cd
		}
		self.definitions.sentry_gun_digging_in_retrieve_time = {
			name_id = "menu_digging_in_retrieve",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "interaction_speed_multiplier",
				category = "sentry_gun"
			}
		}
		self.values.sentry_gun.interaction_speed_multiplier = {
			0.1
		}
		
		self.definitions.sentry_gun_advanced_rangefinder_basic = {
			name_id = "menu_advanced_rangefinder_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "advanced_rangefinder",
				category = "sentry_gun"
			}
		}
		self.definitions.sentry_gun_advanced_rangefinder_aced = {
			name_id = "menu_advanced_rangefinder_aced",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "advanced_rangefinder",
				category = "sentry_gun"
			}
		}
		self.values.sentry_gun.advanced_rangefinder = {
			{0.5,0.5}, -- range mul, accuracy mul (1 + n)
			{1,1}
		}
		
		self.definitions.sentry_gun_targeting_matrix_basic = {
			name_id = "menu_targeting_matrix_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "targeting_matrix",
				category = "sentry_gun"
			}
		}
		self.definitions.sentry_gun_targeting_matrix_aced = {
			name_id = "menu_targeting_matrix_aced",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "targeting_matrix",
				category = "sentry_gun"
			}
		}
		self.values.sentry_gun.targeting_matrix = {
			{"mark_enemy_damage_bonus",0},
			{"mark_enemy_damage_bonus",0.25},
		}
		
		self.definitions.sentry_gun_wrangler_basic = {
			name_id = "menu_wrangler_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "wrangler_accuracy",
				category = "sentry_gun"
			}
		}
		self.values.sentry_gun.wrangler_accuracy = {
			true
		}
		
		self.definitions.sentry_gun_wrangler_aced = {
			name_id = "menu_wrangler_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "wrangler_headshot_damage_bonus",
				category = "sentry_gun"
			}
		}
		self.values.sentry_gun.wrangler_headshot_damage_bonus = {
			1
		}
		
		self.definitions.sentry_gun_hobarts_funnies_basic = {
			name_id = "menu_hobarts_funnies_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "hobarts_funnies",
				category = "sentry_gun"
			}
		}
		self.definitions.sentry_gun_hobarts_funnies_aced = {
			name_id = "menu_hobarts_funnies_aced",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "hobarts_funnies",
				category = "sentry_gun"
			}
		}
		self.values.sentry_gun.hobarts_funnies = {
			0.25,
			0.5
		}

		self.definitions.sentry_gun_killer_machines = {
			name_id = "menu_player_killer_machines",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "killer_machines_bonus_damage",
				category = "sentry_gun"
			}
		}
		self.values.sentry_gun.killer_machines_bonus_damage = {
			5
		}
				
		
		--Thief
		
		--Assassin
		
		self.values.player.professionalschoice = {
			{
				0.02,
				3,
				"below",
				35,
				0.1
			},
			{
				0.04,
				3,
				"below",
				35,
				0.2
			}
		}
		
		self.definitions.player_professionalschoice_basic = {
			name_id = "menu_player_professionalschoice_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "professionalschoice",
				category = "player"
			}
		}
		self.definitions.player_professionalschoice_aced = {
			name_id = "menu_player_professionalschoice_aced",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "professionalschoice",
				category = "player"
			}
		}
		
		--Sapper
		
		--Dealer
		
		--Fixer
		
		--Demolitions
		
	end	
end)