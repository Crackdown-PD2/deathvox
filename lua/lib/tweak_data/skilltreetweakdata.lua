

Hooks:PostHook(SkillTreeTweakData, "init", "vox_overhaul_init", function(self)
	if deathvox:IsTotalCrackdownEnabled() then
	
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
			taskmaster = 1,
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
		
		self.trees[1].name_id = "st_menu_dallas_taskmaster"
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
		
		
		--Taskmaster (not fully implemented)
		replace_skill(tree_indices.taskmaster,1,{ --Zip It
			{
				upgrades = {
					"player_civ_calming_alerts",
					"player_shout_intimidation_aoe"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"cable_tie_quantity"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_zip_it",
			desc_id = "menu_zip_it_desc",
			icon_xy = {
				1,
				0
			}
		})
		replace_skill(tree_indices.taskmaster,2,{ --Pack Mules (basic not yet implemented)
			{
				upgrades = {
					"team_civilian_hostage_carry_bags"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"team_civilian_hostage_speed_bonus"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_pack_mules",
			desc_id = "menu_pack_mules_desc",
			icon_xy = {
				0 or 1,
				1 or 1
			}
		})
		replace_skill(tree_indices.taskmaster,3,{ --Stay Down
			{
				upgrades = {
					"team_civilian_hostage_stationary_invuln"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"team_civilian_hostage_no_fleeing"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_stay_down",
			desc_id = "menu_stay_down_desc",
			icon_xy = {
				1,
				2
			}
		})
		replace_skill(tree_indices.taskmaster,4,{ --Lookout Duty
			{
				upgrades = {
					"team_civilian_hostage_area_marking"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"team_civilian_hostage_aoe_damage_multiplier"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_lookout_duty",
			desc_id = "menu_lookout_duty_desc",
			icon_xy = {
				1,
				3
			}
		})
		replace_skill(tree_indices.taskmaster,5,{ --Leverage
			{
				upgrades = {
					"team_civilian_hostage_aoe_damage_resistance_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"team_civilian_hostage_aoe_damage_resistance_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_leverage",
			desc_id = "menu_leverage_desc",
			icon_xy = {
				1,
				4
			}
		})
		replace_skill(tree_indices.taskmaster,6,{ --False Idol (aced not yet implemented)
			{
				upgrades = {
					"team_civilian_hostage_vip_trade"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"team_civilian_hostage_fakeout_trade"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_false_idol",
			desc_id = "menu_false_idol_desc",
			icon_xy = {
				0 or 1,
				1 or 5
			}
		})
		
		
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
				2,
				0
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
				2,
				1
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
				2,
				2
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
				2,
				3
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
				2,
				4
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
				2,
				5
			}
		})
		
		--Medic
		replace_skill(tree_indices.medic,1,{ --Doctor's Orders
			{
				upgrades = {
					"revive_interaction_speed_multiplier"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"temporary_revive_damage_reduction_1"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_doctors_orders",
			desc_id = "menu_doctors_orders_desc",
			icon_xy = {
				3,
				0
			}
		})
		replace_skill(tree_indices.medic,2,{ --In Case Of Trouble
			{
				upgrades = {
					"first_aid_kit_quantity_increase_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"first_aid_kit_quantity_increase_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_in_case_of_trouble",
			desc_id = "menu_in_case_of_trouble_desc",
			icon_xy = {
				3,
				1
			}
		})
		replace_skill(tree_indices.medic,3,{ --Checkup
			{
				upgrades = {
					"doctor_bag_aoe_health_regen_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"doctor_bag_aoe_health_regen_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_checkup",
			desc_id = "menu_checkup_desc",
			icon_xy = {
				3,
				2
			}
		})
		replace_skill(tree_indices.medic,4,{ --Life Insurance
			{
				upgrades = {
					"first_aid_kit_auto_recovery_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"first_aid_kit_auto_recovery_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_life_insurance",
			desc_id = "menu_life_insurance_desc",
			icon_xy = {
				3,
				3
			}
		})
		replace_skill(tree_indices.medic,5,{ --Outpatient
			{
				upgrades = {
					"doctor_bag_quantity"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"doctor_bag_quantity_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_outpatient",
			desc_id = "menu_outpatient_desc",
			icon_xy = {
				3,
				4
			}
		})
		replace_skill(tree_indices.medic,6,{ --Preventative Care
			{
				upgrades = {
					"medic_damage_overshield"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"medic_overshield_break_invuln"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_preventative_care",
			desc_id = "menu_preventative_care_desc",
			icon_xy = {
				3,
				5
			}
		})

		--Chief (not yet implemented)
		replace_skill(tree_indices.chief,1,{ --Protect and Serve
			{
				upgrades = {
					"player_convert_enemies_interaction_speed_multiplier"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					 "friendship_collar_quantity" --not yet connected
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_protect_and_serve",
			desc_id = "menu_protect_and_serve_desc",
			icon_xy = {
				4,
				0
			}
		})
		replace_skill(tree_indices.chief,2,{ --Order through Law
			{
				upgrades = {
					"player_convert_enemies_knockback_proof" --not yet connected
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_convert_enemies_melee" --not yet connected
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_order_through_law",
			desc_id = "menu_order_through_law_desc",
			icon_xy = {
				4,
				1
			}
		})
		replace_skill(tree_indices.chief,3,{ --Justice with Mercy
			{
				upgrades = {
					"player_convert_enemies_piercing_bullets" --not yet connected
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_convert_enemies_accuracy_bonus" --not yet connected
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_justice_with_mercy",
			desc_id = "menu_justice_with_mercy_desc",
			icon_xy = {
				4,
				2
			}
		})
		replace_skill(tree_indices.chief,4,{ --Standard of Excellence
			{
				upgrades = {
					"player_passive_convert_enemies_health_multiplier_2"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_convert_enemies_health_regen" --not yet connected
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_standard_of_excellence",
			desc_id = "menu_standard_of_excellence_desc",
			icon_xy = {
				4,
				3
			}
		})
		replace_skill(tree_indices.chief,5,{ --Maintaining the Peace
			{
				upgrades = {
					"player_convert_enemies_target_marked", --not yet connected
					"weapon_steelsight_highlight_specials"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_convert_enemies_marked_damage_bonus" --not yet connected
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_maintaining_the_peace",
			desc_id = "menu_maintaining_the_peace_desc",
			icon_xy = {
				4,
				4
			}
		})
		replace_skill(tree_indices.chief,6,{ --Service above Self
			{
				upgrades = {
					"player_convert_enemies_max_minions_1",
					"player_convert_enemies_max_minions_2"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_convert_enemies_tackle_specials" --not yet connected
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_service_above_self",
			desc_id = "menu_service_above_self_desc",
			icon_xy = {
				4,
				5
			}
		})
		
		--Enforcer
		replace_skill(tree_indices.enforcer,1,{ --Tender Meat
			{
				upgrades = {
					"class_shotgun_tender_meat_bodyshots"
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
				5,
				0
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
				5,
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
				5,
				2
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
				5,
				3
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
				5,
				4
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
				5,
				5
			}
		})
		
		--Heavy (not fully implemented)
		replace_skill(tree_indices.heavy,1,{ --Collateral Damage
			{
				upgrades = {
					"class_heavy_collateral_damage"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"class_heavy_steelsight_speed_multiplier"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_collateral_damage",
			desc_id = "menu_collateral_damage_desc",
			icon_xy = {
				6,
				0
			}
		})
		replace_skill(tree_indices.heavy,2,{ --Death Grips
			{
				upgrades = {
					"class_heavy_death_grips_stacks",
					"class_heavy_death_grips_recoil_bonus",
					"class_heavy_death_grips_spread_bonus_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"class_heavy_death_grips_spread_bonus_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_death_grips",
			desc_id = "menu_death_grips_desc",
			icon_xy = {
				6,
				1
			}
		})
		replace_skill(tree_indices.heavy,3,{ --Bulletstorm
			{
				upgrades = {
					"temporary_no_ammo_cost_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"temporary_no_ammo_cost_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_bulletstorm",
			desc_id = "menu_bulletstorm_desc",
			icon_xy = {
				6,
				2
			}
		})		
		replace_skill(tree_indices.heavy,4,{ --Lead Farmer
			{
				upgrades = {
					"class_heavy_lead_farmer_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"class_heavy_lead_farmer_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_lead_farmer",
			desc_id = "menu_lead_farmer_desc",
			icon_xy = {
				6,
				3
			}
		})
		replace_skill(tree_indices.heavy,5,{ --Armory Regular
			{
				upgrades = {
					"ammo_bag_quantity"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"ammo_bag_quantity_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_armory_regular",
			desc_id = "menu_armory_regular_desc",
			icon_xy = {
				6,
				4
			}
		})
		replace_skill(tree_indices.heavy,6,{ --War Machine
			{
				upgrades = {
					"ammo_bag_war_machine_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"ammo_bag_war_machine_aced",
					"ammo_bag_passive_ammo_stock_bonus_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_war_machine",
			desc_id = "menu_war_machine_desc",
			icon_xy = {
				6,
				5
			}
		})
		
		
		--Runner
		replace_skill(tree_indices.runner,1,{ --Hustle
			{
				upgrades = {
					"player_can_free_run"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_stamina_regen_timer_multiplier",
					"player_stamina_regen_multiplier"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_hustle",
			desc_id = "menu_hustle_desc",
			icon_xy = {
				7,
				0
			}
		})
		replace_skill(tree_indices.runner,2,{ --Float Like A Butterfly
			{
				upgrades = {
					"player_can_melee_and_sprint"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_melee_hit_speed_boost"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_butterfly_bee",
			desc_id = "menu_butterfly_bee_desc",
			icon_xy = {
				7,
				1
			}
		})
		replace_skill(tree_indices.runner,3,{ --Heave-Ho
			{
				upgrades = {
					"carry_throw_distance_multiplier"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_carry_movement_penalty_reduction",
					"carry_sprint_with_bag"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_heave_ho",
			desc_id = "menu_heave_ho_desc",
			icon_xy = {
				7,
				2
			}
		})
		replace_skill(tree_indices.runner,4,{ --Mobile Offense
			{
				upgrades = {
					"player_run_and_reload"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_run_and_shoot_1"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_mobile_offense",
			desc_id = "menu_mobile_offense_desc",
			icon_xy = {
				7,
				3
			}
		})
		replace_skill(tree_indices.runner,5,{ --Escape Plan
			{
				upgrades = {
					"player_escape_plan_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_escape_plan_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_escape_plan",
			desc_id = "menu_escape_plan_desc",
			icon_xy = {
				7,
				4
			}
		})
		replace_skill(tree_indices.runner,6,{ --Leg Day Enthusiast
			{
				upgrades = {
					"player_run_speed_multiplier",
					"player_movement_speed_multiplier"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_crouch_speed_penalty_removal"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_leg_day",
			desc_id = "menu_leg_day_desc",
			icon_xy = {
				7,
				5
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
				8,
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
				8,
				1
			}
		})
		replace_skill(tree_indices.gunner,3,{ --Shot Grouping
			{
				upgrades = {
					"class_rapidfire_shotgrouping_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"class_rapidfire_shotgrouping_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_shot_grouping",
			desc_id = "menu_shot_grouping_desc",
			icon_xy = {
				8,
				2
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
				8,
				3
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
				8,
				4
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
				8,
				5
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
				9,
				1
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
				9,
				2
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
				9,
				3
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
				9,
				4
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
		
		--Thief (not fully implemented)
		replace_skill(tree_indices.thief,1,{ --Classic Thievery
			{
				upgrades = {
					"player_pick_lock_easy_speed_multiplier"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_suspicion_bonus"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_classic_thievery",
			desc_id = "menu_classic_thievery_desc",
			icon_xy = {
				10,
				0
			}
		})
		replace_skill(tree_indices.thief,2,{ --People Watching
			{
				upgrades = {
					"player_special_enemy_highlight_mask_off",
					"player_sec_camera_highlight_mask_off",
					"player_mask_off_pickup"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_standstill_omniscience"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_people_watching",
			desc_id = "menu_people_watching_desc",
			icon_xy = {
				10,
				1
			}
		})
		replace_skill(tree_indices.thief,3,{ --Blackout
			{
				upgrades = {
					"ecm_jammer_duration_multiplier"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"ecm_jammer_duration_multiplier_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_blackout",
			desc_id = "menu_blackout_desc",
			icon_xy = {
				10,
				2
			}
		})
		replace_skill(tree_indices.thief,4,{ --Tuned Out (aced not fully implemented)
			{
				upgrades = {
					"player_tape_loop_duration_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"team_player_tape_loop_amount_unlimited", --unlimited not yet functional
					"player_tape_loop_duration_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_tuned_out",
			desc_id = "menu_tuned_out_desc",
			icon_xy = {
				10,
				3
			}
		})
		replace_skill(tree_indices.thief,5,{ --Electronic Warfare
			{
				upgrades = {
					"ecm_jammer_quantity_increase_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"ecm_jammer_affects_pagers"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_electronic_warfare",
			desc_id = "menu_electronic_warfare_desc",
			icon_xy = {
				10,
				4
			}
		})
		replace_skill(tree_indices.thief,6,{ --Skeleton Key
			{
				upgrades = {
					"player_pick_lock_easy_speed_multiplier_2",
					"player_pick_lock_hard"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_pick_lock_hard_speed_multiplier",
					"player_can_hack_electronic_locks"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_skeleton_key",
			desc_id = "menu_skeleton_key_desc",
			icon_xy = {
				10,
				5
			}
		})
		

		--Assassin (not fully implemented)
		replace_skill(tree_indices.assassin,1,{ --Killer's Notebook
			{
				upgrades = {
					"subclass_quiet_steelsight_speed_multiplier"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"subclass_quiet_stability_addend"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_killers_notebook",
			desc_id = "menu_killers_notebook_desc",
			icon_xy = {
				11,
				0
			}
		})
		replace_skill(tree_indices.assassin,2,{ --Good Hunting
			{
				upgrades = {
					"weapon_bow_instant_ready"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"weapon_crossbow_headshot_instant_reload"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_good_hunting",
			desc_id = "menu_good_hunting_desc",
			icon_xy = {
				11,
				1
			}
		})
		replace_skill(tree_indices.assassin,3,{ --Comfortable Silence
			{
				upgrades = {
					"subclass_quiet_concealment_addend_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"subclass_quiet_concealment_addend_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_comfortable_silence",
			desc_id = "menu_comfortable_silence_desc",
			icon_xy = {
				11,
				2
			}
		})
		replace_skill(tree_indices.assassin,4,{ --Toxic Shock (not implemented)
			{
				upgrades = {
					"subclass_poison_dot_aoe" --not yet implemented
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"subclass_poison_damage_mul" --not yet implemented
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_toxic_shock",
			desc_id = "menu_toxic_shock_desc",
			icon_xy = {
				0 or 11,
				0 or 3
			}
		})	
		replace_skill(tree_indices.assassin,5,{ --Professional's Choice
			{
				upgrades = {
					"subclass_quiet_detection_risk_rof_bonus_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"subclass_quiet_detection_risk_rof_bonus_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_professionals_choice",
			desc_id = "menu_professionals_choice_desc",
			icon_xy = {
				11,
				4
			}
		})
		replace_skill(tree_indices.assassin,6,{ --Quiet as the Grave
			{
				upgrades = {
					"subclass_quiet_backstab_bullets"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"subclass_quiet_unnoticed_damage_bonus"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_quiet_grave",
			desc_id = "menu_quiet_grave_desc",
			icon_xy = {
				11,
				5
			}
		})
		

		--Sapper
		replace_skill(tree_indices.sapper,1,{ --Home Improvements
			{
				upgrades = {
					"player_drill_upgrade_interaction_speed_multiplier",
					"player_drill_alert",
					"player_silent_drill"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_home_improvements",
			desc_id = "menu_home_improvements_desc",
			icon_xy = {
				0,
				6
			}
		})
		replace_skill(tree_indices.sapper,2,{ --Perfect Alignment
			{
				upgrades = {
					"player_drill_place_interaction_speed_multiplier"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_drill_speed_multiplier1",
					"player_drill_speed_multiplier2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_perfect_alignment",
			desc_id = "menu_perfect_alignment_desc",
			icon_xy = {
				0,
				7
			}
		})
		replace_skill(tree_indices.sapper,3,{ --Static Defense
			{
				upgrades = {
					"player_drill_shock_trap_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_drill_shock_trap_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_static_defense",
			desc_id = "menu_static_defense_desc",
			icon_xy = {
				0,
				8
			}
		})
		replace_skill(tree_indices.sapper,4,{ --Routine Maintenance
			{
				upgrades = {
					"player_drill_fix_interaction_speed_multiplier"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_drill_melee_hit_restart_chance_1"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_routine_maintenance",
			desc_id = "menu_routine_maintenance_desc",
			icon_xy = {
				0,
				9
			}
		})
		replace_skill(tree_indices.sapper,5,{ --Automatic Reboot
			{
				upgrades = {
					"player_drill_autorepair_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_drill_autorepair_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_automatic_reboot",
			desc_id = "menu_automatic_reboot_desc",
			icon_xy = {
				0,
				10
			}
		})
		replace_skill(tree_indices.sapper,6,{ --Explosive Impatience
			{
				upgrades = {
					"shape_charge_quantity_increase_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"shape_charge_quantity_increase_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_explosive_impatience",
			desc_id = "menu_explosive_impatience_desc",
			icon_xy = {
				0,
				11
			}
		})
		
		
		
		--Dealer
		replace_skill(tree_indices.dealer,1,{ --High-Low Split
			{
				upgrades = {
					"weapon_swap_speed_multiplier"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"class_throwing_weapon_class_damage_mul",
					"class_melee_weapon_class_damage_mul"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_high_low",
			desc_id = "menu_high_low_desc",
			icon_xy = {
				2,
				6
			}
		})
		replace_skill(tree_indices.dealer,2,{ --Wild Card
			{
				upgrades = {
					"melee_can_headshot"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"class_throwing_headshot_mul_addend"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_wild_card",
			desc_id = "menu_wild_card_desc",
			icon_xy = {
				2,
				7
			}
		})
		replace_skill(tree_indices.dealer,3,{ --Value Bet
			{
				upgrades = {
					"class_throwing_charged_damage"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"class_melee_charge_speed_mul"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_value_bet",
			desc_id = "menu_value_bet_desc",
			icon_xy = {
				2,
				8
			}
		})
		replace_skill(tree_indices.dealer,4,{ --Face Value
			{
				upgrades = {
					"class_melee_knockdown_tier_increase"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_shield_knock"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_face_value",
			desc_id = "menu_face_value_desc",
			icon_xy = {
				2,
				9
			}
		})
		replace_skill(tree_indices.dealer,5,{ --Stacking the Deck
			{
				upgrades = {
					"class_throwing_amount_increase_mul"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"class_throwing_projectile_velocity_mul"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_stacking_deck",
			desc_id = "menu_stacking_deck_desc",
			icon_xy = {
				2,
				10
			}
		})
		replace_skill(tree_indices.dealer,6,{ --Shuffle and Cut
			{
				upgrades = {
					"class_throwing_melee_loop"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"class_melee_throwing_loop"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_shuffle_and_cut",
			desc_id = "menu_shuffle_and_cut_desc",
			icon_xy = {
				2,
				11
			}
		})
		
		--Fixer
		replace_skill(tree_indices.fixer,1,{ --Rolling Cutter
			{
				upgrades = {
					"saw_enemy_cutter",
					"saw_consecutive_damage_bonus"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"saw_durability_increase"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_rolling_cutter",
			desc_id = "menu_rolling_cutter_desc",
			icon_xy = {
				3,
				6
			}
		})
		replace_skill(tree_indices.fixer,2,{ --Walking Toolshed
			{
				upgrades = {
					"saw_extra_ammo_addend"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"saw_extra_ammo_addend_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_walking_toolshed",
			desc_id = "menu_walking_toolshed_desc",
			icon_xy = {
				3,
				7
			}
		})
		replace_skill(tree_indices.fixer,3,{ --Handyman
			{
				upgrades = {
					"saw_secondary"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"saw_range_increase"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_handyman",
			desc_id = "menu_handyman_desc",
			icon_xy = {
				3,
				8
			}
		})
		replace_skill(tree_indices.fixer,4,{ --Bloody Mess
			{
				upgrades = {
					"saw_killing_blow_radius"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"saw_killing_blow_chain"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_bloody_mess",
			desc_id = "menu_bloody_mess_desc",
			icon_xy = {
				3,
				9
			}
		})
		replace_skill(tree_indices.fixer,5,{ --Not Safe
			{
				upgrades = {
					"saw_ignore_shields_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"saw_bonus_dozer_damage_mul"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_not_safe",
			desc_id = "menu_not_safe_desc",
			icon_xy = {
				3,
				10
			}
		})
		replace_skill(tree_indices.fixer,6,{ --Into The Pit
			{
				upgrades = {
					"saw_crit_first_strike"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"saw_panic_when_kill_1"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_into_the_pit",
			desc_id = "menu_into_the_pit_desc",
			icon_xy = {
				3,
				11
			}
		})
		
		
		--Demolitions (not fully implemented)
		
		replace_skill(tree_indices.demolitions,1,{ --Party Favors
			{
				upgrades = {
					"player_grenades_amount_increase_mul"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"trip_mine_extended_mark_duration"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_party_favors",
			desc_id = "menu_party_favors_desc",
			icon_xy = {
				4,
				6
			}
		})
		replace_skill(tree_indices.demolitions,2,{ --Special Toys
			{
				upgrades = {
					"class_specialist_ammo_stock_increase"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"class_specialist_reload_speed_multiplier"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_special_toys",
			desc_id = "menu_special_toys_desc",
			icon_xy = {
				4,
				7
			}
		})
		replace_skill(tree_indices.demolitions,3,{ --Smart Bombs
			{
				upgrades = {
					"trip_mine_explosion_size_multiplier_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"trip_mine_dont_damage_hostages",
					"trip_mine_dont_damage_civilians"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_smart_bombs",
			desc_id = "menu_smart_bombs_desc",
			icon_xy = {
				4,
				8
			}
		})
		replace_skill(tree_indices.demolitions,4,{ --Third Degree
			{
				upgrades = {
					"subclass_areadenial_effect_duration_increase_1" --not implemented
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"subclass_areadenial_effect_doubleroasting_damage_increase_mul" --not implemented
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_third_degree",
			desc_id = "menu_third_degree_desc",
			icon_xy = {
				0 or 4,
				0 or 9
			}
		})
		replace_skill(tree_indices.demolitions,5,{ --Have a Blast
			{
				upgrades = {
					"trip_mine_can_place_on_enemies",
					"trip_mine_stuck_enemy_panic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"trip_mine_stuck_dozer_stun",
					"trip_mine_stuck_dozer_damage_vulnerability"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_have_blast",
			desc_id = "menu_have_blast_desc",
			icon_xy = {
				4,
				10
			}
		})
		replace_skill(tree_indices.demolitions,6,{ --Improv Expert
			{
				upgrades = {
					"player_throwable_regen"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"weapon_rpg7_ammo_pickup_modifier",
					"weapon_ray_ammo_pickup_modifier",
					"weapon_flamethrower_ammo_pickup_modifier",
					"weapon_grenade_launcher_ammo_pickup_increase"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_improv_expert",
			desc_id = "menu_improv_expert_desc",
			icon_xy = {
				4,
				11
			}
		})
	

		
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
			"sentry_gun_rot_speed_multiplier",
			
			--passive +50% max ammo reserves if ammo bag equipped (from cd)
			"ammo_bag_passive_ammo_stock_bonus",
			
			--fak auto revive radius on deploying
			"first_aid_kit_auto_revive",
			--fak 80% faster interaction
			"first_aid_kit_interaction_speed_multiplier",
			--fak 80% faster deploy (tweaked vanilla)
			"first_aid_kit_deploy_time_multiplier",
			
			"player_convert_enemies",
			"sentry_gun_silent",
			"player_passive_convert_enemies_health_multiplier_1" --50% damage resistance
		}
		
		for _,upgrade_name in pairs(more_default_upgrades) do 
			table.insert(self.default_upgrades,upgrade_name)
		end
	end
end)

