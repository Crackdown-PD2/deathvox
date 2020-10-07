

Hooks:PostHook(UpgradesTweakData, "init", "vox_overhaul1", function(self, tweak_data)
	if deathvox and deathvox:IsTotalCrackdownEnabled() then
	--weapon archetype categories
		self.values.precision = self.values.precision or {}
		self.values.heavy = self.values.heavy or {}
	
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
			0.9 --was 2 for vanilla upgrade
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
			1,2 --these don't actually mean anything; i plan to use upgrade_level() instead or whatever
		}
		
	
		
		
		--Medic
		
		--Chief
		
		--Enforcer
		
		self.values.player.point_blank = {
			true
		}
		
		self.values.player.point_blank_aced = {
			true
		}
		
		self.definitions.player_point_blank_shotgun_basic = {
			name_id = "menu_point_blank_shotgun_basic",
			category = "feature",
			upgrade = {
			value = 1,
			upgrade = "point_blank",
				category = "player"
			}
		}
					
		self.definitions.player_point_blank_shotgun_aced = {
			name_id = "menu_point_blank_shotgun_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "point_blank_aced",
				category = "player"
			}
		}
		
		--Heavy
		
		--Runner
		
		--Gunner
		
		self.values.player.spray_and_pray_basic = {
			0.1
		}
		
		self.definitions.player_spray_and_pray_basic = {
			name_id = "menu_spray_and_pray_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "spray_and_pray_basic",
				category = "player"
			}
		}
		
		self.values.player.money_shot = {
			true
		}
		
		self.values.player.money_shot_aced = {
			1.5
		}
			
		self.definitions.player_moneyshot_rapid_fire_basic = {
			name_id = "menu_moneyshot_rapid_fire_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "money_shot",
				category = "player"
			}
		}
					
		self.definitions.player_moneyshot_rapid_fire_aced = {
			name_id = "menu_moneyshot_rapid_fire_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "money_shot_aced",
				category = "player"
			}
		}
		
		self.values.player.shotgrouping_aced = { 
			true
		}
		
		self.values.player.shotgrouping_basic = { 
			1.9
		}
		
		self.definitions.player_shotgrouping_basic = {
			name_id = "menu_shotgrouping_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "shotgrouping_basic",
				category = "player"
			}
		}
					
		self.definitions.player_shotgrouping_aced = {
			name_id = "menu_shotgrouping_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "shotgrouping_aced",
				category = "player"
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
		
		self.values.player.making_miracles_basic = {
			true
		}
		
		self.values.player.making_miracles_aced = {
			true
		}
		
		self.definitions.player_making_miracles_basic = {
			name_id = "menu_making_miracles_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "making_miracles_basic",
				category = "player"
			}
		}
		
		self.definitions.player_making_miracles_aced = {
			name_id = "menu_making_miracles_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "making_miracles_aced",
				category = "player"
			}
		}
		
		self.values.player.prayers_answered_basic = {
			0.1
		}
		
		self.definitions.player_prayers_answered_basic = {
			name_id = "menu_prayers_answered_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "prayers_answered_basic",
				category = "player"
			}
		}
		
		self.values.player.prayers_answered_aced = {
			0.1
		}
		
		self.definitions.player_prayers_answered_aced = {
			name_id = "menu_prayers_answered_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "prayers_answered_aced",
				category = "player"
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