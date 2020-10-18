

Hooks:PostHook(SkillTreeTweakData, "init", "vox_overhaul_init", function(self)
	if deathvox and deathvox:IsTotalCrackdownEnabled() then
	
	--replaces skills by position in the skilltree
	--without having to look up the name (even you could just do it by list of names)
	--usage:
		--tree_index: the index of the tree [num 1-15]
			--with 1-3 being the mastermind subtrees in vanilla,
			--4-6 being enforcer,
			--7-9 technician,
			--10-12 ghost,
			--13-15 fugitive
		--skill_position: the position of the skill in the tree. [num 1-6]
			--visually, position numbers are situated as follows:
			--    6
			--  4   5
			--  2   3
			--    1
		--data: the skill data with upgrades etc that you're replacing existing values with [table]
		
		local function replace_skill(tree_index,position_index,data)
			data = data or {}
			local position_data = {
				{1,1},
				{2,1},
				{2,2},
				{3,1},
				{3,2},
				{4,1}
			}
			local tier,slot = unpack(position_data[position_index]) 
			
			local tree_data = self.trees[tree_index]
			if not tree_data then 
				log("deathvox: ERROR! Invalid replaced tree index " .. tostring(tree_index) .. " in skilltreetweakdata:local function replace_skill(tree_index " .. tostring(tree_index) .. ", position_index " .. tostring(position_index) .. ", data " .. table.concat(data,"=") .. ")")
				return
			end
			local tier_data = tree_data.tiers[tier]
			if not tier_data then 
				log("deathvox: ERROR! Invalid replaced skill tier " .. tostring(tier) .. " in skilltreetweakdata:local function replace_skill(tree_index " .. tostring(tree_index) .. ", position_index " .. tostring(position_index) .. ", data " .. table.concat(data,"=") .. ")")
				return
			end
			local skill_name = tier_data[slot]
			if not skill_name then 
				log("deathvox: ERROR! Invalid replaced skill slot " .. tostring(slot) .. " in skilltreetweakdata:local function replace_skill(tree_index " .. tostring(tree_index) .. ", position_index " .. tostring(position_index) .. ", data " .. table.concat(data,"=") .. ")")
				return
			end
			self.skills[skill_name] = data
		end
	
		local tree_indices = {
			boss = 1,
			marksman = 2,
			medic = 3,
			chief = 4,
			enforcer = 5,
			heavy = 6,
			runner = 7,
			gunner = 8,
			engineer = 9,
			thief = 10,
			assassin = 11,
			sapper = 12,
			dealer = 13, 
			fixer = 14,
			demolitions = 15
		}
		
		self.trees[1].name_id = "st_menu_dallas_boss"
		self.trees[2].name_id = "st_menu_dallas_marksman"
		self.trees[3].name_id = "st_menu_dallas_medic"
		self.trees[4].name_id = "st_menu_chains_chief"
		self.trees[5].name_id = "st_menu_chains_enforcer"
		self.trees[6].name_id = "st_menu_chains_heavy"
		self.trees[7].name_id = "st_menu_wolf_runner"
		self.trees[8].name_id = "st_menu_wolf_gunner"
		self.trees[9].name_id = "st_menu_wolf_engineer"
		self.trees[10].name_id = "st_menu_houston_thief"
		self.trees[11].name_id = "st_menu_houston_assassin"
		self.trees[12].name_id = "st_menu_houston_sapper"
		self.trees[13].name_id = "st_menu_hoxton_dealer"
		self.trees[14].name_id = "st_menu_hoxton_fixer"
		self.trees[15].name_id = "st_menu_hoxton_demolitionist"
		
		
		--Boss
		
		--Marksman
		replace_skill(tree_indices.marksman,1,{ --Point and Click
			{
				upgrades = {
					"player_point_and_click_basic",
					"weapon_point_and_click_damage_bonus"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"weapon_marksman_steelsight_speed_multiplier"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_point_and_click",
			desc_id = "menu_point_and_click_desc",
			icon_xy = {
				8,
				1
			}
		})
		replace_skill(tree_indices.marksman,2,{ --Tap the Trigger
			{
				upgrades = {
					"weapon_tap_the_trigger_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"weapon_tap_the_trigger_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_tap_the_trigger",
			desc_id = "menu_tap_the_trigger_desc",
			icon_xy = {
				8,
				5
			}
		})
		replace_skill(tree_indices.marksman,3,{ --Investment Returns
			{
				upgrades = {
					"player_investment_returns_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_investment_returns_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_investment_returns",
			desc_id = "menu_investment_returns_desc",
			icon_xy = {
				7,
				11
			}
		})
		replace_skill(tree_indices.marksman,4,{ --This Machine
			{
				upgrades = {
					"weapon_this_machine_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"weapon_this_machine_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_this_machine",
			desc_id = "menu_this_machine_desc",
			icon_xy = {
				1,
				9
			}
		})
		replace_skill(tree_indices.marksman,5,{ --Mulligan
			{
				upgrades = {
					"player_mulligan_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_mulligan_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_mulligan",
			desc_id = "menu_mulligan_desc",
			icon_xy = {
				0,
				11
			}
		})
		replace_skill(tree_indices.marksman,6,{ --Magic Bullet
			{
				upgrades = {
					"weapon_magic_bullet_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"weapon_magic_bullet_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_magic_bullet",
			desc_id = "menu_magic_bullet_desc",
			icon_xy = {
				8,
				4
			}
		})
		
		--Medic
		
		--Chief
		
		--Enforcer
		
		replace_skill(tree_indices.enforcer,1,{ --Tender Meat
			{
				upgrades = {
					"class_weapon_tender_meat_bodyshots"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"class_shotgun_tender_meat_stability"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_tender_meat",
			desc_id = "menu_tender_meat_desc",
			icon_xy = {
				10,
				3
			}
		})
		replace_skill(tree_indices.enforcer,2,{ --Heartbreaker
			{
				upgrades = {
					"class_shotgun_doublebarrel_firemode"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"class_shotgun_doublebarrel_damage"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_heartbreaker",
			desc_id = "menu_heartbreaker_desc",
			icon_xy = {
				4,
				1
			}
		})
		replace_skill(tree_indices.enforcer,3,{ --Shell Games
			{
				upgrades = {
					"class_shotgun_shell_games_reload_bonus"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"class_shotgun_shell_games_rof_bonus"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_shell_games",
			desc_id = "menu_shell_games_desc",
			icon_xy = {
				4,
				1
			}
		})
		replace_skill(tree_indices.enforcer,4,{ --Rolling Thunder
			{
				upgrades = {
					"class_shotgun_rolling_thunder_magazine_size_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"class_shotgun_rolling_thunder_magazine_size_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_rolling_thunder",
			desc_id = "menu_rolling_thunder_desc",
			icon_xy = {
				8,
				7
			}
		})
		replace_skill(tree_indices.enforcer,5,{ --Point Blank
			{
				upgrades = {
					"class_shotgun_point_blank_shotgun_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"class_shotgun_point_blank_shotgun_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_point_blank",
			desc_id = "menu_point_blank_desc",
			icon_xy = {
				4,
				1
			}
		})
		replace_skill(tree_indices.enforcer,6,{ --Shotmaker
			{
				upgrades = {
					"class_shotgun_shotmaker_headshot_damage_bonus_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"class_shotgun_shotmaker_headshot_damage_bonus_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_shotmaker",
			desc_id = "menu_shotmaker_desc",
			icon_xy = {
				6,
				11
			}
		})
		
		--Heavy
		
		--Runner
		
		replace_skill(tree_indices.runner,1,{ --Hustle
			{
				upgrades = {
					
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_hustle",
			desc_id = "menu_hustle_desc",
			icon_xy = {
				0,
				0
			}
		})
		replace_skill(tree_indices.runner,2,{ --Float Like A Butterfly
			{
				upgrades = {
					
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_butterfly_bee",
			desc_id = "menu_butterfly_bee_desc",
			icon_xy = {
				0,
				0
			}
		})
		replace_skill(tree_indices.runner,3,{ --Heave-Ho
			{
				upgrades = {
					
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_heave_ho",
			desc_id = "menu_heave_ho_desc",
			icon_xy = {
				0,
				0
			}
		})
		replace_skill(tree_indices.runner,4,{ --Mobile Offense
			{
				upgrades = {
					
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_mobile_offense",
			desc_id = "menu_mobile_offense_desc",
			icon_xy = {
				0,
				0
			}
		})
		replace_skill(tree_indices.runner,5,{ --Escape Plan
			{
				upgrades = {
					--rip old tf2 escape plan. you were too good for this world
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_escape_plan",
			desc_id = "menu_escape_plan_desc",
			icon_xy = {
				0,
				0
			}
		})
		replace_skill(tree_indices.runner,6,{ --Leg Day Enthusiast
			{
				upgrades = {
					
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_leg_day",
			desc_id = "menu_leg_day_desc",
			icon_xy = {
				0,
				0
			}
		})
		
		--Gunner
		
		replace_skill(tree_indices.gunner,1,{ --Spray and Pray
			{
				upgrades = {
					"weapon_spray_and_pray_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_ap_bullets_1"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_spray_and_pray",
			desc_id = "menu_spray_and_pray_desc",
			icon_xy = {
				7,
				0
			}
		})
		replace_skill(tree_indices.gunner,2,{ --Money Shot
			{
				upgrades = {
					"weapon_moneyshot_rapid_fire_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"weapon_moneyshot_rapid_fire_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_money_shot",
			desc_id = "menu_money_shot_desc",
			icon_xy = {
				0,
				6
			}
		})
		replace_skill(tree_indices.gunner,3,{ --Shot Grouping
			{
				upgrades = {
					"rapidfire_shotgrouping_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"rapidfire_shotgrouping_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_shot_grouping",
			desc_id = "menu_shot_grouping_desc",
			icon_xy = {
				9,
				11
			}
		})
		replace_skill(tree_indices.gunner,4,{ --Close Enough
			{
				upgrades = {
					"player_ricochet_rapid_fire_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_ricochet_rapid_fire_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_close_enough",
			desc_id = "menu_close_enough_desc",
			icon_xy = {
				10,
				2
			}
		})
		replace_skill(tree_indices.gunner,5,{ --Making Miracles
			{
				upgrades = {
					"weapon_making_miracles_basic",
					"weapon_making_miracles_crit_cap_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"weapon_making_miracles_aced",
					"weapon_making_miracles_crit_cap_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_making_miracles",
			desc_id = "menu_making_miracles_desc",
			icon_xy = {
				0,
				12
			}
		})
		replace_skill(tree_indices.gunner,6,{ --Prayers Answered
			{
				upgrades = {
					"weapon_prayers_answered_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"weapon_prayers_answered_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_prayers_answered",
			desc_id = "menu_prayers_answered_desc",
			icon_xy = {
				2,
				9
			}
		})
		
		--Engineer
		
		replace_skill(tree_indices.engineer,1,{ --Digging In
			{
				upgrades = {
					"player_digging_in_deploy_time",
					"sentry_gun_digging_in_retrieve_time"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"sentry_gun_shield"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_digging_in",
			desc_id = "menu_digging_in_desc",
			icon_xy = {
				9,
				0
			}
		})
		replace_skill(tree_indices.engineer,2,{ --Advanced Rangefinder
			{
				upgrades = {
					"sentry_gun_advanced_rangefinder_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"sentry_gun_advanced_rangefinder_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_advanced_rangefinder",
			desc_id = "menu_advanced_rangefinder_desc",
			icon_xy = {
				1,
				6
			}
		})
		replace_skill(tree_indices.engineer,3,{ --Targeting Matrix
			{
				upgrades = {
					"sentry_gun_targeting_matrix_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"sentry_gun_targeting_matrix_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_targeting_matrix",
			desc_id = "menu_targeting_matrix_desc",
			icon_xy = {
				1,
				6
			}
		})
		replace_skill(tree_indices.engineer,4,{ --Wrangler
			{
				upgrades = {
					"sentry_gun_wrangler_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"sentry_gun_wrangler_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_wrangler",
			desc_id = "menu_wrangler_desc",
			icon_xy = {
				1,
				6
			}
		})
		replace_skill(tree_indices.engineer,5,{ --Hobart's Funnies
			{
				upgrades = {
					"sentry_gun_hobarts_funnies_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"sentry_gun_hobarts_funnies_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_hobarts_funnies",
			desc_id = "menu_hobarts_funnies_desc",
			icon_xy = {
				1,
				6
			}
		})
		replace_skill(tree_indices.engineer,6,{ --Killer Machines
			{
				upgrades = {
					"sentry_gun_killer_machines"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"sentry_gun_quantity_1"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_killer_machines",
			desc_id = "menu_killer_machines_desc",
			icon_xy = {
				9,
				5
			}
		})
		
		--Thief
		
		--Assassin
		
		replace_skill(tree_indices.assassin,1,{ --professional's choice
			{
				upgrades = {
					"player_professionalschoice_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_professionalschoice_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_backstab_beta",
			desc_id = "menu_backstab_beta_desc",
			icon_xy = {
				0,
				12
			}
		})

		--Sapper
		
		--Dealer
		
		--Fixer
		
		--Demolitions

		
		local more_default_upgrades = {
			--flashbang resistance
			"player_flashbang_multiplier_1",
			"player_flashbang_multiplier_2",
			
			--ICTV access
			"body_armor6",
			
			--die hard basic (damage resist when interacting)
			"player_interacting_damage_multiplier",
			
			--cable tie speed
			"cable_tie_interact_speed_multiplier",
			--(cable tie amount is in equipmentstweakdata)
			
			--can purchase preplanning assets (sixth sense aced)
			"player_buy_bodybags_asset",
			"player_additional_assets",
			"player_buy_spotter_asset",
			
			--damage reduction when reviving teammate
			"player_revive_damage_reduction_1",
			
			--sentry targeting basic/aced 
			"sentry_gun_spread_multiplier",
			"sentry_gun_extra_ammo_multiplier_1",
			"sentry_gun_rot_speed_multiplier"
		}
		
		for _,upgrade_name in pairs(more_default_upgrades) do 
			table.insert(self.default_upgrades,upgrade_name)
		end
	end
end)

