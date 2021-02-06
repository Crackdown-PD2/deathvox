

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
		self.values.class_rapidfire = self.values.class_rapidfire or {}
		self.values.class_shotgun = self.values.class_shotgun or {}
		self.values.class_precision = self.values.class_precision or {}
		self.values.class_heavy = self.values.class_heavy or {}
		self.values.class_specialist = self.values.class_specialist or {}
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
				category = "class_precision"
			}
		}
		self.values.class_precision.enter_steelsight_speed_multiplier = { 
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
		self.values.player.revive_interaction_speed_multiplier = { --vanilla upgrade, but tweaked values
			0.7
		}
	
		self.values.temporary.revive_damage_reduction = { --vanilla upgrade, but tweaked values
			{
				0.5, --1 - 0.5 = 0.5 -> 50% damage reduction
				4	--for 4 seconds
			}
		}
	
		self.values.first_aid_kit.quantity = {
			8, -- + 4 = 12 total
			14 -- + 4 = 18 total
		}
	
			--i didn't want to change the data type from a number to a table to hold the cooldown
			--for many reasons, including stability and mod compatibility
			--and the upgrade level index is used instead of the direct value for networking anyway,
			--so we'll just get the cooldown time that way
		self.values.first_aid_kit.first_aid_kit_auto_recovery = {
			500,
			500
		}
		self.values.first_aid_kit.auto_recovery_cooldown = {--this is referenced by the index of the above upgrade instead of having its own cooldown upgrade
			20, --20 seconds cooldown
			10 --10 seconds cooldown
		}
		self.definitions.first_aid_kit_auto_recovery_2 = {
			name_id = "menu_life_insurance",
			category = "equipment_upgrade",
			upgrade = {
				value = 2,
				upgrade = "first_aid_kit_auto_recovery",
				category = "first_aid_kit"
			}
		}
		
		self.values.doctor_bag.quantity = { --this is for the number of deployable docbags you have
			1, --2 total
			2 --3 total
		}
		self.definitions.doctor_bag_quantity_2 = {
			name_id = "menu_doctor_bag_quantity",
			category = "equipment_upgrade",
			upgrade = {
				value = 2,
				upgrade = "quantity",
				category = "doctor_bag"
			}
		}
		
		self.values.doctor_bag.aoe_health_regen = {
			{
				0.01, --regenerate 1% of max health
				2, --every 2 seconds
				150 --when within a 1.5 meter radius (3 meter diameter) of the docbag
			},
			{
				0.01,
				2,
				300 --range increase to 3 meter radius (6 meter diameter)
			}
		}
		self.definitions.doctor_bag_aoe_health_regen_1 = {
			name_id = "menu_checkup",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "aoe_health_regen",
				category = "doctor_bag"
			}
		}
		self.definitions.doctor_bag_aoe_health_regen_2 = {
			name_id = "menu_checkup",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "aoe_health_regen",
				category = "doctor_bag"
			}
		}
		
		self.values.first_aid_kit.damage_overshield = {
			{
				1, --100% of the sum of health and armor is added as an absorption overshield
				0
			},
			{
				1,
				2 --2 seconds of invuln applied when this overshield is broken
			}
		}
		self.definitions.medic_damage_overshield = {
			name_id = "menu_preventative_care",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "damage_overshield",
				category = "first_aid_kit"
			}
		}
		self.definitions.medic_overshield_break_invuln = {
			name_id = "menu_preventative_care",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "damage_overshield",
				category = "first_aid_kit"
			}
		}
		
		--Chief
		
		--Enforcer
		
		self.values.class_shotgun.tender_meat_bodyshots = {
			0.5
		}
		self.definitions.class_shotgun_tender_meat_bodyshots = {
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
		
		self.values.class_heavy.collateral_damage = { --it's graze, but again
			{ 0.5,25 } --50% damage in 0.25m radius
		}
		self.values.class_heavy.enter_steelsight_speed_multiplier = {
			0.1
		}
		self.definitions.class_heavy_collateral_damage = {
			name_id = "menu_collateral_damage_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "collateral_damage",
				category = "class_heavy"
			}
		}
		self.definitions.class_heavy_steelsight_speed_multiplier = {
			name_id = "menu_collateral_damage_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "enter_steelsight_speed_multiplier",
				category = "class_heavy"
			}
		}
		
		self.values.class_heavy.death_grips_stacks = {
			{8,10} --8s duration, 10 max stacks
		}
		self.values.class_heavy.death_grips_recoil_bonus = {
			1 -- +4 stability (per stack)
		}
		self.values.class_heavy.death_grips_spread_bonus = {
			1, -- +4 accuracy (per stack)
			2 -- +8
		}
		
		self.definitions.class_heavy_death_grips_stacks = {
			name_id = "menu_death_grips_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "death_grips_stacks",
				category = "class_heavy"
			}
		}
		self.definitions.class_heavy_death_grips_recoil_bonus = {
			name_id = "menu_death_grips_recoil_bonus",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "death_grips_recoil_bonus",
				category = "class_heavy"
			}
		}
		self.definitions.class_heavy_death_grips_spread_bonus_1 = {
			name_id = "menu_death_grips_spread_bonus_1",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "death_grips_spread_bonus",
				category = "class_heavy"
			}
		}
		self.definitions.class_heavy_death_grips_spread_bonus_2 = {
			name_id = "menu_death_grips_spread_bonus_2",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "death_grips_spread_bonus",
				category = "class_heavy"
			}
		}
		
		self.values.ammo_bag.quantity = {
			1, --originally only 1
			2
		}
		self.definitions.ammo_bag_quantity = { --this should already be the same as vanilla anyway, aside from the name_id
			name_id = "menu_armory_regular_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "quantity",
				category = "ammo_bag"
			}
		}
		self.definitions.ammo_bag_quantity_2 = { --this is not a vanilla upgrade
			name_id = "menu_armory_regular_aced",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "quantity",
				category = "ammo_bag"
			}
		}
		
		self.values.class_heavy.lead_farmer = {
			{0.01,0.5}, --1% per kill, 50% max
			{0.02,1} --2% per kill, 100% max
		}
		self.definitions.class_heavy_lead_farmer_basic = {
			name_id = "menu_lead_farmer_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "lead_farmer",
				category = "class_heavy"
			}
		}
		self.definitions.class_heavy_lead_farmer_aced = {
			name_id = "menu_lead_farmer_aced",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "lead_farmer",
				category = "class_heavy"
			}
		}
		
		self.values.class_heavy.weapon_class_ammo_stock_bonus = {
			1,
			2
		}
		self.definitions.ammo_bag_war_machine_basic = {
			name_id = "menu_war_machine_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "weapon_class_ammo_stock_bonus",
				category = "class_heavy"
			}
		}
		self.definitions.ammo_bag_war_machine_aced = {
			name_id = "menu_war_machine_aced",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "weapon_class_ammo_stock_bonus",
				category = "class_heavy"
			}
		}
		
		
		--Runner
		self.values.player.can_melee_and_sprint = {
			true
		}
		self.definitions.player_can_melee_and_sprint = {
			name_id = "menu_butterfly_bee_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "can_melee_and_sprint",
				category = "player"
			}
		}
		
		self.values.player.melee_hit_speed_boost = {
			{4,0.1} -- +10% speed boost, 4s
		}
		self.definitions.player_melee_hit_speed_boost = {
			name_id = "menu_butterfly_bee_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "melee_hit_speed_boost",
				category = "player"
			}
		}
		
		self.values.player.heave_ho = {
			0.2
		}
		self.definitions.player_carry_movement_penalty_reduction = {
			name_id = "menu_heave_ho_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "heave_ho",
				category = "player"
			}
		}
		
		self.values.player.escape_plan = {
			{1,0.25,4,0},
			{1,0.25,4,0.2}
		}
		self.definitions.player_escape_plan_basic = {
			name_id = "menu_escape_plan_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "escape_plan",
				category = "player"
			}
		}
		self.definitions.player_escape_plan_aced = {
			name_id = "menu_escape_plan_aced",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "escape_plan",
				category = "player"
			}
		}
		
		self.values.player.leg_day_aced = {
			true
		}
		self.definitions.player_crouch_speed_penalty_removal = {
			name_id = "menu_leg_day_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "leg_day_aced",
				category = "player"
			}
		}
		
		--Gunner
		
		self.values.class_rapidfire.enter_steelsight_speed_multiplier = {
			0.1
		}
		
		self.definitions.weapon_spray_and_pray_basic = {
			name_id = "menu_spray_and_pray_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "enter_steelsight_speed_multiplier",
				category = "class_rapidfire"
			}
		}
		
		self.values.weapon.money_shot = {
			{
				1, --100% damage
				250 --over 2.5 meters
			}
		}
		
		self.values.weapon.money_shot_aced = {
			0.5
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
		
		self.values.class_rapidfire.shotgrouping_aced = { 
			14 --accuracy/stability index addend
		}
		
		self.values.class_rapidfire.enter_steelsight_speed_multiplier = { 
			0.1
		}
		
		self.definitions.class_rapidfire_shotgrouping_basic = {
			name_id = "menu_shotgrouping_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "enter_steelsight_speed_multiplier",
				category = "class_rapidfire"
			}
		}
					
		self.definitions.class_rapidfire_shotgrouping_aced = {
			name_id = "menu_shotgrouping_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "shotgrouping_aced",
				category = "class_rapidfire"
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
		self.values.player.pick_lock_easy_speed_multiplier = {
			0.5,
			0.25 --vanilla tweaked
		}
		self.definitions.player_pick_lock_easy_speed_multiplier_2 = {
			name_id = "menu_player_pick_lock_easy_speed_multiplier",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "pick_lock_easy_speed_multiplier",
				category = "player"
			}
		}
		
		self.values.player.pick_lock_hard_speed_multiplier = {
			0.5
		}
		self.definitions.player_pick_lock_hard_speed_multiplier = {
			name_id = "menu_player_pick_lock_hard_speed_multiplier",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "pick_lock_hard_speed_multiplier",
				category = "player"
			}
		}
		
		self.values.player.can_hack_electronic_locks = {
			true
		}
		self.definitions.player_can_hack_electronic_locks = {
			name_id = "menu_player_can_hack_electronic_locks",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "can_hack_electronic_locks",
				category = "player"
			}
		}
		
		self.values.player.omniscience_range = {
			500,
			1500
		}
		self.values.player.omniscience_timer = {
			3
		}
		
		self.values.player.tape_loop_duration = {
			15,
			25
		}
		self.values.player.tape_loop_amount_unlimited = {
			true
		}
		self.definitions.player_tape_loop_amount_unlimited = {
			name_id = "menu_player_tape_loop_amount_unlimited",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "tape_loop_amount_unlimited",
				category = "player"
			}
		}
		
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
		
			--no ammo consumed on enemy hit
		self.values.saw.enemy_cutter = { true }
		self.definitions.saw_enemy_cutter = {
			name_id = "menu_saw_rolling_cutter_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "enemy_cutter",
				category = "saw"
			}
		}
			--+10% damage per hit for 2 seconds, up to +500%
		self.values.saw.consecutive_damage_bonus = {
			{0.1,5,2}
		}
		self.definitions.saw_consecutive_damage_bonus = {
			name_id = "menu_saw_rolling_cutter_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "consecutive_damage_bonus",
				category = "saw"
			}
		}
		
			--+50% durability
		self.values.saw.durability_increase = {
			0.5
		}
		self.definitions.saw_durability_increase = {
			name_id = "menu_saw_rolling_cutter_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "durability_increase",
				category = "saw"
			}
		}
		
			--ammo increase
		self.values.class_saw.clip_amount_increase = {
			2,
			3
		}
		self.definitions.saw_extra_ammo_addend = {
			name_id = "menu_saw_walking_toolshed_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "clip_amount_increase",
				category = "class_saw" --by class since we don't want it to apply twice to the primary saw
			}
		}
		self.definitions.saw_extra_ammo_addend_2 = {
			name_id = "menu_saw_walking_toolshed_aced",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "clip_amount_increase",
				category = "class_saw"
			}
		}
		
			--+25% range
		self.values.saw.range_mul = {
			1.25
		}
		self.definitions.saw_range_increase = {
			name_id = "menu_saw_handyman_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "range_mul",
				category = "saw"
			}
		}
		
		self.values.saw.killing_blow_radius = {
			250
		}
		self.definitions.saw_killing_blow_radius = {
			name_id = "menu_saw_bloody_mess_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "killing_blow_radius",
				category = "saw"
			}
		}
		
		self.values.saw.killing_blow_chain = {
			true
		}
		self.definitions.saw_killing_blow_chain = {
			name_id = "menu_saw_bloody_mess_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "killing_blow_chain",
				category = "saw"
			}
		}
		
		self.values.saw.dozer_bonus_damage_mul = {
			2
		}
		self.definitions.saw_bonus_dozer_damage_mul = {
			name_id = "menu_saw_not_safe_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "dozer_bonus_damage_mul",
				category = "saw"
			}
		}
		
			--panic on saw kill (tweaked vanilla)
		self.values.saw.panic_when_kill = {
			{
				chance = 1,
				area = 600,
				amount = 200
			}
		}
			--guaranteed crit on the first hit
		self.values.saw.crit_first_strike = {
			true
		}
		self.definitions.saw_crit_first_strike = {
			name_id = "menu_saw_into_pit_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "crit_first_strike",
				category = "saw"
			}
		}
		
		
		--Demolitions
		
		
		
		--FAK auto revive radius on deploying
			--(default upgrade)
		self.values.first_aid_kit.auto_revive = {
			150 --1.5 meters
		}
		self.definitions.first_aid_kit_auto_revive = {
			name_id = "menu_first_aid_kit_auto_revive",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "auto_revive",
				category = "first_aid_kit"
			}
		}
		
		--FAK Interaction Speed increased by 80% 
			--(default upgrade)
		self.values.first_aid_kit.interaction_speed_multiplier = {
			0.8
		}
		self.definitions.first_aid_kit_interaction_speed_multiplier = {
			name_id = "menu_first_aid_kit_interaction_speed_multiplier",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "interaction_speed_multiplier",
				category = "first_aid_kit"
			}
		}
		
		--FAK Deploy Speed increased by 80% 
			--(default upgrade, tweaked vanilla; "first_aid_kit_deploy_time_multiplier") 
		self.values.first_aid_kit.deploy_time_multiplier = {
			0.2
		}
		
		--Health regained upon being revived by deploying FAK
		self.revive_health_multiplier = {
			1 --100% of max health
		--see also: player.revived_health_regain		
		}
		
		--Passively increases Ammo Stock for equipped weapons by 50% 
			--(default upgrade)
		self.definitions.ammo_bag_passive_ammo_stock_bonus = {
			name_id = "menu_ammo_bag_passive_ammo_stock_bonus",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "passive_ammo_stock_bonus",
				category = "ammo_bag"
			}
		}
		self.values.ammo_bag.passive_ammo_stock_bonus = {
			0.5
		}
	end	
end)