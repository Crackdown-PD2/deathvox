

Hooks:PostHook(UpgradesTweakData, "init", "vox_overhaul1", function(self, tweak_data)
	--create the tcd upgrade tables in all cases so that upgrade checks won't crash when the overhaul is not enabled
	
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
	self.values.friendship_collar = self.values.friendship_collar or {}
	
	if deathvox:IsTotalCrackdownEnabled() then
	
		self.definitions.tripmine_throwable = {
			category = "grenade"
		}
		table.insert(self.level_tree[0].upgrades,"tripmine_throwable")
		
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
		
		--Taskmaster
		
		self.values.cable_tie.quantity_1 = {
			10 --10 default, 10 from skill, 20 total
		}

--				"player_intimidate_range_mul",
--				"player_intimidate_aura",
--				"player_civ_intimidation_mul"		
		self.definitions.player_shout_intimidation_aoe = {
			name_id = "menu_zip_it",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "shout_intimidation_aoe",
				category = "player"
			}
		}
		self.values.player.shout_intimidation_aoe = {1000}
		
		self.definitions.team_civilian_hostage_carry_bags = {
			name_id = "menu_BLANK",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "civilian_hostage_carry_bags",
				category = "player"
			}
		}
		self.values.team.player.civilian_hostage_carry_bags  = {true}
		
		self.definitions.team_civilian_hostage_speed_bonus = {
			name_id = "menu_BLANK",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "civilian_hostage_speed_bonus",
				category = "player"
			}
		}
		self.values.team.player.civilian_hostage_speed_bonus = {1.5} --50% speed bonus
		
		
		self.definitions.team_civilian_hostage_stationary_invuln = {
			name_id = "menu_pack_mules",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "civilian_hostage_stationary_invuln",
				category = "player"
			}
		}
		self.values.team.player.civilian_hostage_stationary_invuln = {true}
		
		--this has to be written as a separate upgrade because apparently ovk checked for the same "super_syndrome" upgrade for both the no-fleeing mechanic, and the self-trading mechanic
		self.definitions.team_civilian_hostage_no_fleeing = {
			name_id = "menu_pack_mules",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "civilian_hostage_no_fleeing",
				category = "player"
			}
		}
		self.values.team.player.civilian_hostage_no_fleeing = {true}
		
		self.definitions.team_civilian_hostage_area_marking_1 = {
			name_id = "menu_BLANK",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "civilian_hostage_area_marking",
				category = "player"
			}
		}
		self.definitions.team_civilian_hostage_area_marking_2 = {
			name_id = "menu_BLANK",
			category = "team",
			upgrade = {
				value = 2,
				upgrade = "civilian_hostage_area_marking",
				category = "player"
			}
		}
		self.values.team.player.civilian_hostage_area_marking_distance = 1000 --10m
		self.values.team.player.civilian_hostage_area_marking_damage_mul = 1.1 --10% extra damage
		self.values.team.player.civilian_hostage_area_marking_interval = 0.1 --check every 0.1 seconds
		
		self.values.team.player.civilian_hostage_area_marking = {1,2} --values only used as a "tier" shortcut
		
		--use this
		self.definitions.team_civilian_hostage_aoe_damage_resistance_1 = {
			name_id = "menu_BLANK",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "civilian_hostage_aoe_damage_resistance",
				category = "player"
			}
		}

		self.values.team.player.civilian_hostage_aoe_damage_resistance = {{500,0.75}} --5m range, 25% damage resistance
		
		self.definitions.team_civilian_hostage_vip_trade = {
			name_id = "menu_false_idol",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "civilian_hostage_vip_trade",
				category = "player"
			}
		}
		self.values.team.player.civilian_hostage_vip_trade = {true}
		
		self.definitions.team_civilian_hostage_fakeout_trade = {
			name_id = "menu_BLANK",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "civilian_hostage_fakeout_trade",
				category = "player"
			}
		}
		self.values.team.player.civilian_hostage_fakeout_trade = {true}
		
		self.values.player.max_civ_hostage_followers = {
			2,
			3
		}
		self.definitions.player_max_civ_hostage_followers_1 = {
			name_id = "menu_falseidol_aced_followers",
			category = "player",
			upgrade = {
				value = 1,
				synced = true,
				upgrade = "max_civ_hostage_followers",
				category = "player"
			}
		}
		self.definitions.player_max_civ_hostage_followers_2 = {
			name_id = "menu_falseidol_aced_followers",
			category = "player",
			upgrade = {
				value = 2,
				synced = true,
				upgrade = "max_civ_hostage_followers",
				category = "player"
			}
		}
		
		self.definitions.player_civilian_early_trade_restores_down = {
			name_id = "menu_civilian_early_trade_restores_down",
			category = "player",
			upgrade = {
				value = 1,
				synced = true,
				upgrade = "civilian_early_trade_restores_down",
				category = "player"
			}
		}
		
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
		self.definitions.weapon_point_and_click_damage_bonus_2 = {
			name_id = "menu_weapon_point_and_click_damage_bonus",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "point_and_click_damage_bonus",
				category = "weapon"
			}
		}
		
		--% bonus damage per stack, max bonus damage
		self.values.weapon.point_and_click_damage_bonus = {
			{0.005, 2.5},
			{0.005, 5},
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
		
		self.definitions.player_point_and_click_never_miss = {
			name_id = "menu_point_and_click_never_miss",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "point_and_click_never_miss",
				category = "player"
			}
		}
		self.values.player.point_and_click_never_miss = {true}
		
		self.definitions.player_point_and_click_deadshot_mul = {
			name_id = "menu_point_and_click_deadshot_mul",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "point_and_click_deadshot_mul",
				category = "player"
			}
		}
		self.values.player.point_and_click_deadshot_mul = {true}
		
		self.definitions.player_point_and_click_stack_from_kill = {
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
		
		self.definitions.player_point_and_click_stack_from_headshot_kill = {
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
		
		self.values.player.passive_convert_enemies_health_multiplier = {
			0.2,
			0.1
		}
		self.values.player.convert_enemies_interaction_speed_multiplier = {
			0.1 --90% faster; modified vanilla upgrade
		}
		self.values.friendship_collar.quantity = {
			6
		}
		self.definitions.friendship_collar_quantity = {
			name = "menu_protect_and_serve",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "quantity",
				category = "friendship_collar"
			}
		}
		
		self.values.player.convert_enemies_knockback_proof = {
			true
		}
		self.definitions.player_convert_enemies_knockback_proof = {
			name = "menu_order_through_law",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "convert_enemies_knockback_proof",
				synced = true,
				category = "player"
			}
		}
		self.values.player.convert_enemies_melee = {
			true
		}
		self.definitions.player_convert_enemies_melee = {
			name = "menu_order_through_law",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "convert_enemies_melee",
				synced = true,
				category = "player"
			}
		}
		
		self.values.player.convert_enemies_piercing_bullets = {
			true
		}
		self.definitions.player_convert_enemies_piercing_bullets = {
			name = "menu_justice_with_mercy",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "convert_enemies_piercing_bullets",
				synced = true,
				category = "player"
			}
		}
		self.values.player.convert_enemies_accuracy_bonus = {
			1.9
		}
		self.definitions.player_convert_enemies_accuracy_bonus = {
			name = "menu_justice_with_mercy",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "convert_enemies_accuracy_bonus",
				synced = true,
				category = "player"
			}
		}
		
		self.values.player.convert_enemies_health_regen = {
			0.025
		}
		self.definitions.player_convert_enemies_health_regen = {
			name = "menu_standard_of_excellence",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "convert_enemies_health_regen",
				synced = true,
				category = "player"
			}
		}
		
		self.values.player.convert_enemies_target_marked = {
			true
		}
		self.definitions.player_convert_enemies_target_marked = {
			name = "menu_maintaining_the_peace",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "convert_enemies_target_marked",
				synced = true,
				category = "player"
			}
		}
		self.values.player.convert_enemies_marked_damage_bonus = {
			1.25
		}
		self.definitions.player_convert_enemies_marked_damage_bonus = {
			name = "menu_maintaining_the_peace",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "convert_enemies_marked_damage_bonus",
				synced = true,
				category = "player"
			}
		}
		
		self.values.player.convert_enemies_tackle_specials = {
			30
		}
		self.definitions.player_convert_enemies_tackle_specials = {
			name_id = "menu_service_above_self",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "convert_enemies_tackle_specials",
				synced = true,
				category = "player"
			}
		}
		
		self.values.player.convert_enemies_range_bonus = {
			2
		}
		self.definitions.player_convert_enemies_range_bonus = {
			name = "menu_order_through_law",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "convert_enemies_range_bonus",
				synced = true,
				category = "player"
			}
		}
		
		self.values.player.convert_enemies_always_stagger = {
			true
		}
		self.definitions.player_convert_enemies_always_stagger = {
			name = "menu_bleh",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "convert_enemies_always_stagger",
				synced = true,
				category = "player"
			}
		}
		
		self.values.player.convert_enemy_instant = {
			true
		}
		self.definitions.player_convert_enemy_instant = {
			name = "menu_maintaining_the_peace",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "convert_enemy_instant",
				synced = true,
				category = "player"
			}
		}
		
		self._joker_dmg_increase_data = {
			increase_max = 0.25,
			increase_t = 30,
			increase_per_t = 0.01
		}
		
		self.values.player.convert_enemy_gains_dmg_over_t = {
			true
		}
		self.definitions.player_convert_convert_enemy_gains_dmg_over_t = {
			name = "menu_maintaining_the_peace",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "convert_enemy_gains_dmg_over_t",
				synced = true,
				category = "player"
			}
		}
		
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
			2
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
			300 --2.5m
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
		
		self.values.class_shotgun.grand_brachial_bodyshots = {
			true
		}
		self.definitions.class_shotgun_grand_brachial_bodyshots = {
			name_id = "menu_grand_brachial_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "grand_brachial_bodyshots",
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
		
		self.values.class_heavy.lead_farmer_neo = {{0.2, 2}} --Percentage of ammo reloaded, time between ticks
		self.values.class_heavy.lead_farmer_bipod_reload = {true}
		
		self.definitions.class_heavy_lead_farmer_neo_basic = {
			name_id = "menu_lead_farmer_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "lead_farmer_neo",
				category = "class_heavy"
			}
		}
		self.definitions.class_heavy_lead_farmer_neo_aced = {
			name_id = "menu_lead_farmer_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "lead_farmer_bipod_reload",
				category = "class_heavy"
			}
		}
		
		--OLD REMOVE LATER
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
		self.definitions.ammo_bag_passive_ammo_stock_bonus_2 = {
			name_id = "menu_ammo_bag_passive_ammo_stock_bonus",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "passive_ammo_stock_bonus",
				category = "ammo_bag"
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
		
		self.values.player.bungielungie = {
			true
		}
		self.definitions.player_bungielungie = {
			name_id = "menu_butterfly_bee_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "bungielungie",
				category = "player"
			}
		}
		
		self.values.player.melee_hit_speed_boost = { --unused/old pre-rework runner skill
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
			name_id = "menu_heave_ho",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "heave_ho",
				category = "player"
			}
		}
		self.values.carry.can_sprint_with_bag = {true}
		self.definitions.carry_can_sprint_with_bag = {
			name_id = "menu_heave_ho",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "can_sprint_with_bag",
				category = "carry"
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
		
		self.values.player.wave_dash_basic = {true}
		self.values.player.wave_dash_aced = {true}
		
		self.definitions.player_wave_dash_basic = {
			name_id = "menu_air_dash_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "wave_dash_basic",
				category = "player"
			}
		}
		self.definitions.player_wave_dash_aced = {
			name_id = "menu_air_dash_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "wave_dash_aced",
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
		
		self.values.class_rapidfire.money_shot = {
			true
		}
		
		self.values.class_rapidfire.empty_magazine_reload_speed_bonus = {
			0.5
		}
		
		self.values.class_rapidfire.money_shot_pierce = {
			true
		}
		
		self.definitions.class_rapidfire_moneyshot_pierce = {
			name_id = "menu_moneyshot_rapid_fire_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "money_shot_pierce",
				category = "class_rapidfire"
			}
		}
		
		self.definitions.class_rapidfire_moneyshot = {
			name_id = "menu_moneyshot_rapid_fire_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "money_shot",
				category = "class_rapidfire"
			}
		}
		
		self.definitions.class_rapidfire_empty_magazine_reload_speed_bonus = {
			name_id = "menu_moneyshot_rapid_fire_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "empty_magazine_reload_speed_bonus",
				category = "class_rapidfire"
			}
		}
		
		self.values.class_rapidfire.steelsight_accstab_bonus = { 
			14 --accuracy/stability index addend (used for both)
		}
		self.values.class_rapidfire.enter_steelsight_speed_multiplier = { 
			0.1
		}
		
		self.definitions.class_rapidfire_steelsight_speed_multiplier = {
			name_id = "menu_shotgrouping_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "enter_steelsight_speed_multiplier",
				category = "class_rapidfire"
			}
		}
		self.definitions.class_rapidfire_steelsight_accstab_bonus = {
			name_id = "menu_shotgrouping_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "steelsight_accstab_bonus",
				category = "class_rapidfire"
			}
		}
	
		self.values.class_rapidfire.critical_hit_chance_on_headshot = {
			{
				0.01, --crit chance per stack
				4, --duration
				10 --max stacks
			}
		}
		self.definitions.class_rapidfire_critical_hit_chance_on_headshot = {
			name_id = "menu_shotgrouping_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "critical_hit_chance_on_headshot",
				category = "class_rapidfire"
			}
		}
		
		self.values.player.critical_hit_multiplier = {
			2,
			2.5,
			3
		}
		self.definitions.player_critical_hit_multiplier_1 = { --default upgrade
			name_id = "",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "critical_hit_multiplier",
				category = "player"
			}
		}
		self.definitions.player_critical_hit_multiplier_2 = {
			name_id = "menu_making_miracles_basic",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "critical_hit_multiplier",
				category = "player"
			}
		}
		self.definitions.player_critical_hit_multiplier_3 = {
			name_id = "menu_making_miracles_aced",
			category = "feature",
			upgrade = {
				value = 3,
				upgrade = "critical_hit_multiplier",
				category = "player"
			}
		}
		
		self.values.class_rapidfire.ricochet_bullets = {
			true --can ricochet
		}

		self.values.class_rapidfire.guaranteed_hit_ricochet_bullets = {
			true --guaranteed ricochet
		}

		self.values.player.crit_ricochet_no_damage_penalty = {
			true
		}
		
		self.values.class_rapidfire.ricochet_damage_penalty = { 0.5 } --deal only 0.5x of normal damage on ricochet
	
		self.definitions.class_rapidfire_ricochet_bullets = {
			name_id = "menu_ricochet_rapid_fire_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "ricochet_bullets",
				category = "class_rapidfire"
			}
		}
		
		self.definitions.class_rapidfire_ricochet_damage_penalty_1 = {
			name_id = "menu_ricochet_rapid_fire_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "ricochet_damage_penalty",
				category = "class_rapidfire"
			}
		}
		self.definitions.class_rapidfire_guaranteed_hit_ricochet_bullets = {
			name_id = "menu_ricochet_rapid_fire_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "guaranteed_hit_ricochet_bullets",
				category = "class_rapidfire"
			}
		}
		self.definitions.player_crit_ricochet_no_damage_penalty = {
			name_id = "menu_ricochet_rapid_fire_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "crit_ricochet_no_damage_penalty",
				category = "player"
			}
		}
		
		self.values.class_rapidfire.primary_class_critical_hit_chance_increase = {
			0.1,
			0.15,
			0.25
		}
		self.definitions.class_rapidfire_critical_hit_chance_increase_1 = {
			name_id = "menu_prayers_answered_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "primary_class_critical_hit_chance_increase",
				category = "class_rapidfire"
			}
		}
		self.definitions.class_rapidfire_critical_hit_chance_increase_2 = {
			name_id = "menu_prayers_answered_basic",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "primary_class_critical_hit_chance_increase",
				category = "class_rapidfire"
			}
		}
		self.definitions.class_rapidfire_critical_hit_chance_increase_3 = {
			name_id = "menu_prayers_answered_basic",
			category = "feature",
			upgrade = {
				value = 3,
				upgrade = "primary_class_critical_hit_chance_increase",
				category = "class_rapidfire"
			}
		}
		
		--Engineer
		self.definitions.player_digging_in_deploy_time = { -- not used
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
		self.definitions.sentry_gun_digging_in_retrieve_time = { --not used
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
		
		self.definitions.sentry_gun_auto_heat_decay_1 = {
			name_id = "menu_digging_in_decay_heat",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "auto_heat_decay",
				category = "sentry_gun"
			}
		}
		self.values.sentry_gun.auto_heat_decay = {
			{
				interval = 6, --every n seconds, perform heat decay
				amount = -1 --amount of heat removed per interval
			}
		}
		
		--wrangler_damage_bonus
		self.definitions.sentry_gun_targeting_range_increase = {
			name_id = "menu_advanced_rangefinder_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "targeting_range_increase",
				category = "sentry_gun"
			}
		}
		self.definitions.sentry_gun_targeting_accuracy_increase = {
			name_id = "menu_advanced_rangefinder_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "targeting_accuracy_increase",
				category = "sentry_gun"
			}
		}
		
		self.definitions.sentry_gun_advanced_rangefinder_aced = {
			name_id = "menu_advanced_rangefinder_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "overwatch_targets_all_specials",
				category = "sentry_gun"
			}
		}
		self.values.sentry_gun.targeting_range_increase = {
			1 -- +100% range (1 + n)
		}
		self.values.sentry_gun.targeting_accuracy_increase = {
			1 -- +100% accuracy (1 + n)
		}
		self.values.sentry_gun.overwatch_targets_all_specials = {
			true
		}
		
		self.values.sentry_gun.wrangler_damage_bonus = {
			1.25
		}
		self.definitions.sentry_gun_manual_damage_bonus = {
			name_id = "menu_targeting_matrix_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "wrangler_damage_bonus",
				category = "sentry_gun"
			}
		}
		
		
		self.definitions.sentry_gun_highlight_enemies_1 = {
			name_id = "menu_targeting_matrix_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "automatic_highlight_enemies",
				category = "sentry_gun"
			}
		}
		self.definitions.sentry_gun_highlight_enemies_2 = {
			name_id = "menu_targeting_matrix_aced",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "automatic_highlight_enemies",
				category = "sentry_gun"
			}
		}
		self.values.sentry_gun.automatic_highlight_enemies = {
			{"mark_enemy_damage_bonus",0},
			{"mark_enemy_damage_bonus",0.25}
		}
		
		self.definitions.sentry_gun_wrangler_heatsink = {
			name_id = "menu_wrangler_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "wrangler_heatsink",
				category = "sentry_gun"
			}
		}
		self.values.sentry_gun.wrangler_heatsink = {
			true
		}
		
		self.definitions.sentry_gun_wrangler_headshot_damage_bonus = {
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
		self.values.team.player.tape_loop_amount_unlimited = {
			true
		}
		self.definitions.team_player_tape_loop_amount_unlimited = {
			name_id = "menu_player_tape_loop_amount_unlimited",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "tape_loop_amount_unlimited",
				category = "player"
			}
		}
		
		--Assassin
		
		self.values.subclass_quiet.subclass_detection_risk_rof_bonus = {
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
		
		self.definitions.subclass_quiet_detection_risk_rof_bonus_1 = {
			name_id = "menu_professionals_choice",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "subclass_detection_risk_rof_bonus",
				category = "subclass_quiet"
			}
		}
		self.definitions.subclass_quiet_detection_risk_rof_bonus_2 = {
			name_id = "menu_professionals_choice",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "subclass_detection_risk_rof_bonus",
				category = "subclass_quiet"
			}
		}
		
		self.definitions.subclass_poison_damage_mul = { --not implemented
			name_id = "menu_toxic_shock",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "weapon_subclass_damage_mul",
				category = "subclass_poison"
			}
		}
		self.values.subclass_poison.weapon_subclass_damage_mul = {2} --this should actually be a dot-specific damage bonus
		
		self.definitions.subclass_poison_dot_aoe = { --not implemented
			name_id = "menu_toxic_shock",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "poison_dot_aoe",
				category = "subclass_poison"
			}
		}
		self.values.subclass_poison.poison_dot_aoe = { 300 }
		
		self.values.subclass_quiet.enter_steelsight_speed_multiplier = { 0.1 }
		self.definitions.subclass_quiet_steelsight_speed_multiplier = {
			name_id = "menu_killers_notebook",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "enter_steelsight_speed_multiplier",
				category = "subclass_quiet"
			}
		}
		
		self.definitions.subclass_quiet_stability_addend = {
			name_id = "menu_killers_notebook",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "subclass_stability_addend",
				category = "subclass_quiet"
			}
		}
		self.values.subclass_quiet.subclass_stability_addend = { 5 }
		
		self.values.weapon.homing_bolts = {true}
		self.definitions.weapon_homing_bolts = {
			name_id = "menu_good_hunting",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "homing_bolts",
				category = "weapon"
			}
		}
		
		self.values.weapon.crossbow_piercer = {true}
		self.definitions.weapon_crossbow_piercer = {
			name_id = "menu_good_hunting",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "crossbow_piercer",
				category = "weapon"
			}
		}
		
		self.values.weapon.xbow_headshot_instant_reload = {true}
		self.definitions.weapon_crossbow_headshot_instant_reload = {
			name_id = "menu_good_hunting",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "xbow_headshot_instant_reload",
				category = "weapon"
			}
		}
		
		self.values.weapon.bow_instant_ready = {true}
		self.definitions.weapon_bow_instant_ready = {
			name_id = "menu_good_hunting",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "bow_instant_ready",
				category = "weapon"
			}
		}
		
		self.definitions.subclass_quiet_concealment_addend_1 = {
			name_id = "menu_comfortable_silence",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "subclass_concealment_addend",
				category = "subclass_quiet"
			}
		}
		self.definitions.subclass_quiet_concealment_addend_2 = {
			name_id = "menu_comfortable_silence",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "subclass_concealment_addend",
				category = "subclass_quiet"
			}
		}
		self.values.subclass_quiet.subclass_concealment_addend = { 2,4 }
		
		self.values.subclass_quiet.backstab_bullets = { 1.25 }
		self.definitions.subclass_quiet_backstab_bullets = {
			name_id = "menu_quiet_grave",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "backstab_bullets",
				category = "subclass_quiet"
			}
		}
		
		self.values.subclass_quiet.unnoticed_damage_bonus = { 1.25 }
		self.definitions.subclass_quiet_unnoticed_damage_bonus = {
			name_id = "menu_quiet_grave",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "unnoticed_damage_bonus",
				category = "subclass_quiet"
			}
		}
		
		--Sapper
		self.values.player.drill_place_interaction_speed_multiplier = { 0.25 } --75% faster 
		self.definitions.player_drill_place_interaction_speed_multiplier = {
			name_id = "menu_perfect_alignment",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "drill_place_interaction_speed_multiplier",
				category = "player"
			}
		}
		
		self.values.player.drill_fix_interaction_speed_multiplier = { 0.5 } --vanilla value tweaked
		
		self.values.player.drill_upgrade_interaction_speed_multiplier = { 0.25 } --75% faster
		self.definitions.player_drill_upgrade_interaction_speed_multiplier = {
			name_id = "menu_perfect_alignment",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "drill_upgrade_interaction_speed_multiplier",
				category = "player"
			}
		}
		
		self.values.player.drill_auto_repair_guaranteed = { 30,5 } --referenced directly by drill instead of changing autorepair chance values
		
		self.values.shape_charge.quantity = { 2, 4 } --vanilla value tweaked
		
		self.values.player.drill_shock_trap = {60,30} --cooldown
		self.definitions.player_drill_shock_trap_1 = {
			name_id = "menu_static_defense",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "drill_shock_trap",
				category = "player"
			}
		}
		self.definitions.player_drill_shock_trap_2 = {
			name_id = "menu_static_defense",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "drill_shock_trap",
				category = "player"
			}
		}
		
		self.values.player.drill_shock_tase_time = 5 --by direct reference only
		
		--Dealer
		self.values.class_melee.weapon_class_damage_mul = {1.1}
		self.definitions.class_melee_weapon_class_damage_mul = {
			name_id = "menu_high_low",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "weapon_class_damage_mul",
				category = "class_melee"
			}
		}
		
		self.values.class_throwing.weapon_class_damage_mul = {1.1}
		self.definitions.class_throwing_weapon_class_damage_mul = {
			name_id = "menu_high_low",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "weapon_class_damage_mul",
				category = "class_throwing"
			}
		}
		
		self.values.class_melee.can_headshot = {true}
		self.definitions.melee_can_headshot = {
			name_id = "menu_wild_card",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "can_headshot",
				category = "class_melee"
			}
		}
		
		self.values.class_throwing.headshot_mul_addend = { 1 }
		self.definitions.class_throwing_headshot_mul_addend = {
			name_id = "menu_wild_card",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "headshot_mul_addend",
				category = "class_throwing"
			}
		}
		
		self.values.player.wcard_thorns = {true}
		self.definitions.player_wcard_thorns = {
			name_id = "menu_wild_card",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "wcard_thorns",
				category = "player"
			}
		}
		
		self.values.player.wcard_thorns_stagger = {true}
		self.definitions.player_wcard_thorns_stagger = {
			name_id = "menu_wild_card",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "wcard_thorns_stagger",
				category = "player"
			}
		}
		
		self.values.class_throwing.deckstacker_homing = {true}
		self.definitions.class_throwing_deckstacker_homing = {
			name_id = "menu_stacking_deck",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "deckstacker_homing",
				category = "class_throwing"
			}
		}
		
		self.values.class_throwing.deckstacker_HS_panic = {true}
		self.definitions.class_throwing_deckstacker_HS_panic = {
			name_id = "menu_stacking_deck",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "deckstacker_HS_panic",
				category = "class_throwing"
			}
		}
		
		self.values.class_throwing.projectile_charged_damage_mul = { {1,1} } -- after 1s charge, +100% damage
		self.definitions.class_throwing_charged_damage = {
			name_id = "menu_value_bet",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "projectile_charged_damage_mul",
				category = "class_throwing"
			}
		}
		self.values.class_melee.melee_charge_speed_mul = { 1 } --1 + 1 => double charge speed increase
		self.definitions.class_melee_charge_speed_mul = {
			name_id = "menu_value_bet",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "melee_charge_speed_mul",
				category = "class_melee"
			}
		}
		
		self.values.class_melee.knockdown_tier_increase = { 1 }
		self.definitions.class_melee_knockdown_tier_increase = {
			name_id = "menu_face_value",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "knockdown_tier_increase",
				category = "class_melee"
			}
		}
		
		self.values.class_throwing.throwing_amount_increase_mul = {1.5}
		self.definitions.class_throwing_amount_increase_mul = {
			name_id = "menu_stacking_deck",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "throwing_amount_increase_mul",
				category = "class_throwing"
			}
		}
		
		self.values.class_throwing.projectile_velocity_mul = { 2 }
		self.definitions.class_throwing_projectile_velocity_mul = {
			name_id = "menu_stacking_deck",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "projectile_velocity_mul",
				category = "class_throwing"
			}
		}
		
		--award this on throwing weapon hit
		self.values.class_throwing.throwing_boosts_melee_loop = { {5,5} } --5 stack max, +500% damage per stack
		self.definitions.class_throwing_melee_loop = {
			name_id = "menu_shuffle_cut",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "throwing_boosts_melee_loop",
				category = "class_throwing"
			}
		}
		
		--award this on melee hit
		self.values.class_melee.melee_boosts_throwing_loop = { {5,5} } --5 stack max, +500% damage per stack
		self.definitions.class_melee_throwing_loop = {
			name_id = "menu_shuffle_cut",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "melee_boosts_throwing_loop",
				category = "class_melee"
			}
		}
		
		self.values.class_throwing.melee_loop_refund = { true }
		self.definitions.class_throwing_loop_refund = {
			name_id = "menu_shuffle_cut",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "melee_loop_refund",
				category = "class_throwing"
			}
		}
		
		self.values.class_melee.throwing_loop_refund = { true }
		self.definitions.class_melee_loop_refund = {
			name_id = "menu_shuffle_cut",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "throwing_loop_refund",
				category = "class_melee"
			}
		}
		
		
		
		
		
		--Fixer
		
		self.values.saw.enemy_damage_multiplier = {
			10 --10x
		}
		self.definitions.saw_enemy_damage_multiplier_1 = {
			name_id = "menu_saw_into_the_pit_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "enemy_damage_multiplier",
				category = "saw"
			}
		}
		self.values.saw.damage_multiplier_to_specials = {
			2
		}
		self.definitions.saw_damage_multiplier_to_specials = {
			name_id = "menu_saw_not_safe_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "damage_multiplier_to_specials",
				category = "saw"
			}
		}
		
		self.values.saw.panic_on_hit = {
			true
		}
		self.definitions.saw_panic_on_hit = {
			name_id = "menu_saw_rolling_cutter_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "panic_on_hit",
				category = "saw"
			}
		}
		
		
		self.values.saw.stagger_on_kill = {
			{
				severity = "heavy_hurt",
				range = 600
			}
		}
		self.definitions.saw_stagger_on_kill = {
			name_id = "menu_saw_bloody_mess_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "stagger_on_kill",
				category = "saw"
			}
		}
		
		
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
		
			--permanent +1% damage per kill, up to +500%
		self.values.saw.consecutive_damage_bonus = {
			{0.01,500}
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
			300
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
		
		self.values.saw.killing_blow_chain = { --not used
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
		
		
		self.values.saw.destroys_dozer_armor = {
			true
		}
		self.values.saw.dozer_instant_armor_peel_bodies = { --manually referenced in SawWeaponBase bc weapon base code is a heck
			"body_helmet_plate"
		}
		self.definitions.saw_destroys_dozer_armor = {
			name_id = "menu_saw_not_safe_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "destroys_dozer_armor",
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
		
			 --Have a Blast basic
		self.values.trip_mine.can_place_on_enemies = {true}
		self.definitions.trip_mine_can_place_on_enemies = {
			name_id = "menu_have_blast_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "can_place_on_enemies",
				category = "trip_mine"
			}
		}
		self.definitions.trip_mine_stuck_damage_mul = {
			name_id = "menu_have_blast_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "stuck_enemy_damage_mul",
				category = "trip_mine"
			}
		}
		self.values.trip_mine.stuck_enemy_damage_mul = {3}

			--Have a Blast Aced
		self.values.player.grenades_amount_increase_mul = {1.33}
		self.definitions.player_grenades_amount_increase_mul = {
			name_id = "menu_have_blast_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "grenades_amount_increase_mul",
				category = "player"
			}
		}
		
			--not used
		self.values.trip_mine.stuck_enemy_panic_radius = {1000}
		self.definitions.trip_mine_stuck_enemy_panic = {
			name_id = "menu_have_blast_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "stuck_enemy_panic_radius",
				category = "trip_mine"
			}
		}
		self.values.trip_mine.stuck_dozer_damage_vulnerability = { {1,10} } --100% damage vuln increase for 10s (relies on stuck_enemy_panic_radius for area)
		self.definitions.trip_mine_stuck_dozer_damage_vulnerability = {
			name_id = "menu_have_blast_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "stuck_dozer_damage_vulnerability",
				category = "trip_mine"
			}
		}
		
		
			--Third Degree Basic
		self.values.subclass_areadenial.effect_duration_increase_mul = {1.5}
		self.definitions.subclass_areadenial_effect_duration_increase_1 = {
			name_id = "menu_third_degree",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "effect_duration_increase_mul",
				category = "subclass_areadenial",
				synced = true
			}
		}
			
			--Third Degree Aced
		self.values.subclass_areadenial.effect_doubleroasting_damage_increase_mul = {1.25}
		self.definitions.subclass_areadenial_effect_doubleroasting_damage_increase_mul = {
			name_id = "menu_third_degree",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "effect_doubleroasting_damage_increase_mul",
				category = "subclass_areadenial",
				synced = true
			}
		}
		
		
			--Cheap Trick Basic
		self.values.trip_mine.can_throw = {true}
		self.definitions.trip_mine_can_throw = {
			name_id = "menu_cheap_trick_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "can_throw",
				category = "trip_mine"
			}
		}
			--Cheap Trick Aced
		self.values.player.throwable_regen = {{50,1}} --50 kills grants 1 grenade
		self.definitions.player_throwable_regen = {
			name_id = "menu_cheap_trick_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "throwable_regen",
				category = "player"
			}
		}
		
		
			--Special Toys Basic
		self.values.class_specialist.weapon_class_ammo_stock_bonus = { 0.25 } --25% more ammo for specialist class weapons
		self.definitions.class_specialist_ammo_stock_increase = {
			name_id = "menu_special_toys_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "weapon_class_ammo_stock_bonus",
				category = "class_specialist"
			}
		}
		
		self.values.class_specialist.reload_speed_multiplier = {0.7} --30% faster reload speed
		self.definitions.class_specialist_reload_speed_multiplier = {
			name_id = "menu_special_toys_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "reload_speed_multiplier",
				category = "class_specialist"
			}
		}
		
			--Special Toys Aced
		self.values.weapon.rpg7_ammo_pickup_modifier = { {0.001,0.001} }
		self.definitions.weapon_rpg7_ammo_pickup_modifier = {
			name_id = "menu_improv_expert_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "rpg7_ammo_pickup_modifier",
				category = "weapon"
			}
		}
		self.values.weapon.ray_ammo_pickup_modifier = { {0.001,0.001} }
		self.definitions.weapon_ray_ammo_pickup_modifier = {
			name_id = "menu_improv_expert_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "ray_ammo_pickup_modifier",
				category = "weapon"
			}
		}
		self.values.weapon.grenade_launcher_ammo_pickup_increase = { 0.5 } --50% increase (additive)
		self.definitions.weapon_grenade_launcher_ammo_pickup_increase = {
			name_id = "menu_improv_expert_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "grenade_launcher_ammo_pickup_increase",
				category = "weapon"
			}
		}
		self.values.weapon.flamethrower_ammo_pickup_modifier = { {1,1} }
		self.definitions.weapon_flamethrower_ammo_pickup_modifier = {
			name_id = "menu_improv_expert_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "flamethrower_ammo_pickup_modifier",
				category = "weapon"
			}
		}
		
		
			--not used
		self.values.trip_mine.extended_mark_duration = {1.5}
		self.definitions.trip_mine_extended_mark_duration = {
			name_id = "menu_party_favors",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "extended_mark_duration",
				category = "trip_mine"
			}
		}
		
		
			--Smart Bombs Aced
		self.values.class_specialist.blast_radius_mul_increase = {1.3}
		self.definitions.class_specialist_blast_radius_mul_increase_1 = {
			name_id = "menu_smart_bombs_aced",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "blast_radius_mul_increase",
				category = "class_specialist",
				synced = true
			}
		}
		self.values.class_specialist.no_friendly_fire = {true}
		self.definitions.class_specialist_no_friendly_fire = {
			name_id = "menu_smart_bombs",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "no_friendly_fire",
				category = "class_specialist",
				synced = true
			}
		}
		
		
			--Tankbuster 
		self.values.class_specialist.negate_enemy_explosive_resistance = {1,2} --overrides character's explosive damage resistance
		self.definitions.class_specialist_negate_enemy_explosive_resistance_1 = {
			name_id = "menu_tankbuster_basic",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "negate_enemy_explosive_resistance",
				category = "class_specialist"
			}
		}
		self.definitions.class_specialist_negate_enemy_explosive_resistance_2 = {
			name_id = "menu_tankbuster_aced",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "negate_enemy_explosive_resistance",
				category = "class_specialist"
			}
		}
		
		
		
		
	--perk decks
		self.values.team.crewchief = {}
		
		
			--Crew Chief 1: +10% damage resistance
		self.values.team.crewchief.passive_damage_resistance = {
			0.1
		}
		self.definitions.team_passive_damage_resistance = {
			name_id = "menu_deck1_1",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "passive_damage_resistance",
				category = "crewchief"
			}
		}
		
			--Crew Chief 2: +10% stamina recovery rate
		self.values.team.crewchief.passive_stamina_regen_mul = {
			0.1
		}
		self.definitions.team_passive_stamina_regen_mul = {
			name_id = "menu_deck1_2",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "passive_stamina_regen_mul",
				category = "crewchief"
			}
		}

			--Crew Chief 4: +10% maximum stamina
		self.values.team.stamina.passive_multiplier = {
			1.1,
			1.3 --seems to be unused
		}
		
			--Crew Chief 5: 1% health regen
		self.values.team.crewchief.passive_health_regen = {
			0.01
		}
		self.definitions.team_passive_health_regen = {
			name_id = "menu_deck1_5",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "passive_health_regen",
				category = "crewchief"
			}
		}

		
		
			--Crew Chief 6: +10% interaction speed (does not apply to pagers)
		self.values.team.crewchief.passive_interaction_speed_multiplier = {
			0.9
		}
		self.definitions.team_passive_interaction_speed_multiplier = {
			name_id = "menu_deck1_6",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "passive_interaction_speed_multiplier",
				category = "crewchief"
			}
		}

			--Crew Chief 7: +10% armor
		self.values.team.armor.multiplier = {
			1.1
		}
		

		--General free skills (default upgrades)
			--FAK auto revive radius on deploying
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
				--second tier is available through the War Machine Aced skill in the Heavy subtree
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
			0.5,
			1
		}
		
		
		--Muscle Perkdeck
		self.values.player.muscle_aggro_weight_add = {true}
		self.values.player.muscle_health_mul = {
			1.25,
			1.5,
			1.75,
			2
		}
		self.values.player.muscle_health_regen = {
			0.005,
			0.01,
			0.015,
			0.02
		}
		self.values.player.muscle_beachyboys = {
			true
		}
		
		self.definitions.muscle_1_health = {
			name_id = "menu_deck2_1",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "muscle_health_mul",
				category = "player"
			}
		}
		self.definitions.muscle_1_aggro = {
			name_id = "menu_deck2_1",
			category = "feature",
			upgrade = {
				value = 1,
				synced = true,
				upgrade = "muscle_aggro_weight_add",
				category = "player"
			}
		}
		self.definitions.muscle_2 = {
			name_id = "menu_deck2_2",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "muscle_health_regen",
				category = "player"
			}
		}
		self.definitions.muscle_3 = {
			name_id = "menu_deck2_3",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "muscle_health_mul",
				category = "player"
			}
		}
		self.definitions.muscle_4 = {
			name_id = "menu_deck2_4",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "muscle_health_regen",
				category = "player"
			}
		}
		self.definitions.muscle_5 = {
			name_id = "menu_deck2_5",
			category = "feature",
			upgrade = {
				value = 3,
				upgrade = "muscle_health_mul",
				category = "player"
			}
		}
		self.definitions.muscle_6 = {
			name_id = "menu_deck2_6",
			category = "feature",
			upgrade = {
				value = 3,
				upgrade = "muscle_health_regen",
				category = "player"
			}
		}
		self.definitions.muscle_7 = {
			name_id = "menu_deck2_7",
			category = "feature",
			upgrade = {
				value = 4,
				upgrade = "muscle_health_mul",
				category = "player"
			}
		}
		self.definitions.muscle_8 = {
			name_id = "menu_deck2_8",
			category = "feature",
			upgrade = {
				value = 4,
				upgrade = "muscle_health_regen",
				category = "player"
			}
		}
		self.definitions.muscle_9 = {
			name_id = "menu_deck2_9",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "muscle_beachyboys",
				category = "player"
			}
		}
		
		--Armorer Perkdeck
		self.values.temporary.armor_break_invulnerable = { --Armorer 1
			{
				2,
				10
			}
		}
		self.values.player.armorer_armor_mul = {
			1.25,
			1.5,
			1.75,
			2
		}
		self.values.player.armorer_shake_mul = {0.5}
		self.values.player.armorer_armor_pen_mul = {0.5} --Armor Speed Penalty reducer
		self.values.player.armorer_armor_regen_mul = {0.75}
		self.values.player.armorer_ironclad = {0.9}
		
		--Armorer 1 is not defined here
		self.definitions.armorer_2 = {
			name_id = "menu_deck3_2",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "armorer_armor_mul",
				category = "player"
			}
		}
		self.definitions.armorer_3 = {
			name_id = "menu_deck3_3",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "armorer_shake_mul",
				category = "player"
			}
		}
		self.definitions.armorer_4 = {
			name_id = "menu_deck3_4",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "armorer_armor_mul",
				category = "player"
			}
		}
		self.definitions.armorer_5 = {
			name_id = "menu_deck3_5",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "armorer_armor_pen_mul",
				category = "player"
			}
		}
		self.definitions.armorer_6 = {
			name_id = "menu_deck3_6",
			category = "feature",
			upgrade = {
				value = 3,
				upgrade = "armorer_armor_mul",
				category = "player"
			}
		}
		self.definitions.armorer_7 = {
			name_id = "menu_deck3_7",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "armorer_armor_regen_mul",
				category = "player"
			}
		}
		self.definitions.armorer_8 = {
			name_id = "menu_deck3_8",
			category = "feature",
			upgrade = {
				value = 4,
				upgrade = "armorer_armor_mul",
				category = "player"
			}
		}
		self.definitions.armorer_9 = {
			name_id = "menu_deck3_9",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "armorer_ironclad",
				category = "player"
			}
		}
		
		--Rogue
		self.values.player.rogue_dodge_add = {
			0.1,
			0.2,
			0.3,
			0.4
		}
		self.values.player.rogue_melee_dodge = {true}
		self.values.player.rogue_sniper_dodge = {true}
		self.values.player.rogue_cloaker_dodge = {true}
		self.values.player.rogue_taser_dodge = {true}
		self.values.player.detection_risk_add_dodge_chance = {
			{
				0.02,
				2,
				"below",
				35,
				0.2
			},
			{
				0.01,
				1,
				"below",
				35,
				0.1
			}
		}
		
		self.definitions.rogue_1 = {
			name_id = "menu_deck4_1",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "rogue_dodge_add",
				category = "player"
			}
		}
		self.definitions.rogue_2 = {
			name_id = "menu_deck4_2",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "rogue_melee_dodge",
				category = "player"
			}
		}
		self.definitions.rogue_3 = {
			name_id = "menu_deck4_3",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "rogue_dodge_add",
				category = "player"
			}
		}
		self.definitions.rogue_4 = {
			name_id = "menu_deck4_4",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "rogue_sniper_dodge",
				category = "player"
			}
		}
		self.definitions.rogue_5 = {
			name_id = "menu_deck4_5",
			category = "feature",
			upgrade = {
				value = 3,
				upgrade = "rogue_dodge_add",
				category = "player"
			}
		}
		self.definitions.rogue_6 = {
			name_id = "menu_deck4_6",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "rogue_cloaker_dodge",
				category = "player"
			}
		}
		self.definitions.rogue_7 = {
			name_id = "menu_deck4_7",
			category = "feature",
			upgrade = {
				value = 4,
				upgrade = "rogue_dodge_add",
				category = "player"
			}
		}
		self.definitions.rogue_8 = {
			name_id = "menu_deck4_8",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "rogue_taser_dodge",
				category = "player"
			}
		}
		self.definitions.rogue_9 = {
			name_id = "menu_deck4_9",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "detection_risk_add_dodge_chance",
				category = "player"
			}
		}
		
		--Crook
		self.values.player.crook_vest_dodge_addend = {
			0.15,
			0.3
		}
		self.values.player.crook_vest_armor_addend = {
			1.5,
			3,
			4.5,
			6
		}
		self.values.player.crook_vest_armor_regen = {
			0.8,
			0.6,
			0.4
		}
		self.berserker_movement_speed_multiplier = 1
		self.values.temporary.berserker_damage_multiplier = {
			{
				1,
				4
			},
			{
				1,
				6
			}
		}
		
		self.definitions.crook_1 = {
			name_id = "menu_deck5_1",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "crook_vest_armor_addend",
				category = "player"
			}
		}
		self.definitions.crook_2 = {
			name_id = "menu_deck5_2",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "crook_vest_armor_regen",
				category = "player"
			}
		}
		self.definitions.crook_3 = {
			name_id = "menu_deck5_3",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "crook_vest_armor_addend",
				category = "player"
			}
		}
		self.definitions.crook_4 = {
			name_id = "menu_deck5_4",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "crook_vest_dodge_addend",
				category = "player"
			}
		}
		self.definitions.crook_5 = {
			name_id = "menu_deck5_5",
			category = "feature",
			upgrade = {
				value = 3,
				upgrade = "crook_vest_armor_addend",
				category = "player"
			}
		}
		self.definitions.crook_6 = {
			name_id = "menu_deck5_6",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "crook_vest_armor_regen",
				category = "player"
			}
		}
		self.definitions.crook_7 = {
			name_id = "menu_deck5_7",
			category = "feature",
			upgrade = {
				value = 4,
				upgrade = "crook_vest_armor_addend",
				category = "player"
			}
		}
		self.definitions.crook_8 = {
			name_id = "menu_deck5_8",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "crook_vest_dodge_addend",
				category = "player"
			}
		}
		self.definitions.crook_9 = {
			name_id = "menu_deck5_9",
			category = "temporary",
			upgrade = {
				value = 1,
				upgrade = "berserker_damage_multiplier",
				category = "temporary"
			}
		}
		
		--Hitman After All
		self.values.player.hitman_armor_regen = {
			0.9,
			0.8,
			0.7,
			0.6
		}
		self.values.player.passive_always_regen_armor = {
			2,
			1.75,
			1.5,
			1.25
		}
		self.values.player.hitman_bleedout_invuln = {true}
		
		self.definitions.hitman_1 = {
			name_id = "menu_deck6_1",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "hitman_armor_regen",
				category = "player"
			}
		}
		self.definitions.hitman_2 = {
			name_id = "menu_deck6_2",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "passive_always_regen_armor",
				category = "player"
			}
		}
		self.definitions.hitman_3 = {
			name_id = "menu_deck6_3",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "hitman_armor_regen",
				category = "player"
			}
		}
		self.definitions.hitman_4 = {
			name_id = "menu_deck6_4",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "passive_always_regen_armor",
				category = "player"
			}
		}
		self.definitions.hitman_5 = {
			name_id = "menu_deck6_5",
			category = "feature",
			upgrade = {
				value = 3,
				upgrade = "hitman_armor_regen",
				category = "player"
			}
		}
		self.definitions.hitman_6 = {
			name_id = "menu_deck6_6",
			category = "feature",
			upgrade = {
				value = 3,
				upgrade = "passive_always_regen_armor",
				category = "player"
			}
		}
		self.definitions.hitman_7 = {
			name_id = "menu_deck6_7",
			category = "feature",
			upgrade = {
				value = 4,
				upgrade = "hitman_armor_regen",
				category = "player"
			}
		}
		self.definitions.hitman_8 = {
			name_id = "menu_deck6_8",
			category = "feature",
			upgrade = {
				value = 4,
				upgrade = "passive_always_regen_armor",
				category = "player"
			}
		}
		self.definitions.hitman_9_messiah = {
			name_id = "menu_deck6_9",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "messiah_revive_from_bleed_out",
				category = "player"
			}
		}
		self.definitions.hitman_9_bleedout_invuln = {
			name_id = "menu_deck6_9",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "hitman_bleedout_invuln",
				category = "player"
			}
		}
		
		--Burglar
		self.values.player.burglar_stealth_interaction_speed_mul = {
			0.9,
			0.8,
			0.7,
			0.6
		}
		self.values.player.burglar_max_concealment = {true}
		self.values.player.burglar_fall_damage_resist = {true}
		self.values.player.burglar_body_interaction_speed_mul = {0.8}
		self.values.player.burglar_pager_interaction_speed_mul = {0.9}
		self.values.player.burglar_camera_freeturn = {true}
		
		self.definitions.burglar_1 = {
			name_id = "menu_deck7_1",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "burglar_stealth_interaction_speed_mul",
				category = "player"
			}
		}
		self.definitions.burglar_2 = {
			name_id = "menu_deck7_2",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "burglar_max_concealment",
				category = "player"
			}
		}
		self.definitions.burglar_3 = {
			name_id = "menu_deck7_3",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "burglar_stealth_interaction_speed_mul",
				category = "player"
			}
		}
		self.definitions.burglar_4 = {
			name_id = "menu_deck7_4",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "burglar_fall_damage_resist",
				category = "player"
			}
		}
		self.definitions.burglar_5 = {
			name_id = "menu_deck7_5",
			category = "feature",
			upgrade = {
				value = 3,
				upgrade = "burglar_stealth_interaction_speed_mul",
				category = "player"
			}
		}
		self.definitions.burglar_6 = {
			name_id = "menu_deck7_6",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "burglar_body_interaction_speed_mul",
				category = "player"
			}
		}
		self.definitions.burglar_7 = {
			name_id = "menu_deck7_7",
			category = "feature",
			upgrade = {
				value = 4,
				upgrade = "burglar_stealth_interaction_speed_mul",
				category = "player"
			}
		}
		self.definitions.burglar_8 = {
			name_id = "menu_deck7_8",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "burglar_pager_interaction_speed_mul",
				category = "player"
			}
		}
		self.definitions.burglar_9 = {
			name_id = "menu_deck7_9",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "burglar_camera_freeturn",
				category = "player"
			}
		}
		
		
		--Infiltrator aka the deck fug's gonna be using until the end of time
		self.values.player.infiltrator_melee_stance_DR = {true}
		self.values.player.infiltrator_melee_heal = {0.02}
		self.values.player.infiltrator_flash_immunity = {true}
		self.values.player.infiltrator_max_health_mul = {0.4}
		self.values.player.infiltrator_passive_DR = {0.9}
		self.values.player.infiltrator_armor_restore = {0.02}
		self.values.player.infiltrator_comeback_strike = {true} --this is used to make sure counters actually deal damage
		self.values.player.infiltrator_max_armor_mul = {0.4}
		self.values.player.infiltrator_taser_breakout = {true}
		
		self.definitions.infiltrator_1 = {
			name_id = "menu_deck8_1",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "infiltrator_melee_stance_DR",
				category = "player"
			}
		}
		self.definitions.infiltrator_2 = {
			name_id = "menu_deck8_2",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "infiltrator_melee_heal",
				category = "player"
			}
		}
		self.definitions.infiltrator_3 = {
			name_id = "menu_deck8_3",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "infiltrator_flash_immunity",
				category = "player"
			}
		}
		self.definitions.infiltrator_4 = {
			name_id = "menu_deck8_4",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "infiltrator_max_health_mul",
				category = "player"
			}
		}
		self.definitions.infiltrator_5 = {
			name_id = "menu_deck8_5",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "infiltrator_passive_DR",
				category = "player"
			}
		}
		self.definitions.infiltrator_6 = {
			name_id = "menu_deck8_6",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "infiltrator_armor_restore",
				category = "player"
			}
		}
		self.definitions.infiltrator_7 = {
			name_id = "menu_deck8_7",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "infiltrator_comeback_strike",
				category = "player"
			}
		}
		self.definitions.infiltrator_8 = {
			name_id = "menu_deck8_8",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "infiltrator_max_armor_mul",
				category = "player"
			}
		}
		self.definitions.infiltrator_9 = {
			name_id = "menu_deck8_9",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "infiltrator_taser_breakout",
				category = "player"
			}
		}
		
		--Sociopath
		self.values.player.sociopath_mode = {true}
		self.values.player.sociopath_stamina_mul = {2}
		self.values.player.sociopath_melee_combo = {true}
		self.values.player.sociopath_health_addend = {1}
		self.values.player.sociopath_throwing_combo = {true}
		self.values.player.sociopath_speed_mul = {1.1}
		self.values.player.sociopath_saw_combo = {true}
		self.values.player.sociopath_i_frames_add = {0.5}
		self.values.player.sociopath_combo_master = {true}
		
		self.values.player.sociopath_combo_duration = 10
		
		self.definitions.sociopath_1 = {
			name_id = "menu_deck8_1",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "sociopath_mode",
				category = "player"
			}
		}
		self.definitions.sociopath_2 = {
			name_id = "menu_deck8_2",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "sociopath_stamina_mul",
				category = "player"
			}
		}
		self.definitions.sociopath_3 = {
			name_id = "menu_deck8_3",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "sociopath_melee_combo",
				category = "player"
			}
		}
		self.definitions.sociopath_4 = {
			name_id = "menu_deck8_4",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "sociopath_health_addend",
				category = "player"
			}
		}
		self.definitions.sociopath_5 = {
			name_id = "menu_deck8_5",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "sociopath_throwing_combo",
				category = "player"
			}
		}
		self.definitions.sociopath_6 = {
			name_id = "menu_deck8_6",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "sociopath_speed_mul",
				category = "player"
			}
		}
		self.definitions.sociopath_7 = {
			name_id = "menu_deck8_7",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "sociopath_saw_combo",
				category = "player"
			}
		}
		self.definitions.sociopath_8 = {
			name_id = "menu_deck8_8",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "sociopath_i_frames_add",
				category = "player"
			}
		}
		self.definitions.sociopath_9 = {
			name_id = "menu_deck8_9",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "sociopath_combo_master",
				category = "player"
			}
		}
		
		--Grinder
		self.values.player.grinder_dmgtohp = {
			0.005,
			0.01,
			0.015,
			0.02,
			0.025
		}
		self.values.player.grinder_killtohp = {
			0.005,
			0.01
		}
		self.values.player.grinder_health_mul = {
			1.2,
			1.4
		}
		
		self.definitions.grinder_1 = {
			name_id = "menu_deck11_1",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "grinder_dmgtohp",
				category = "player"
			}
		}
		self.definitions.grinder_2 = {
			name_id = "menu_deck11_2",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "grinder_killtohp",
				category = "player"
			}
		}
		self.definitions.grinder_3 = {
			name_id = "menu_deck11_3",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "grinder_dmgtohp",
				category = "player"
			}
		}
		self.definitions.grinder_4 = {
			name_id = "menu_deck11_4",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "grinder_health_mul",
				category = "player"
			}
		}
		self.definitions.grinder_5 = {
			name_id = "menu_deck11_5",
			category = "feature",
			upgrade = {
				value = 3,
				upgrade = "grinder_dmgtohp",
				category = "player"
			}
		}
		self.definitions.grinder_6 = {
			name_id = "menu_deck11_6",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "grinder_killtohp",
				category = "player"
			}
		}
		self.definitions.grinder_7 = {
			name_id = "menu_deck11_7",
			category = "feature",
			upgrade = {
				value = 4,
				upgrade = "grinder_dmgtohp",
				category = "player"
			}
		}
		self.definitions.grinder_8 = {
			name_id = "menu_deck11_8",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "grinder_health_mul",
				category = "player"
			}
		}
		self.definitions.grinder_9 = {
			name_id = "menu_deck11_9",
			category = "feature",
			upgrade = {
				value = 5,
				upgrade = "grinder_dmgtohp",
				category = "player"
			}
		}
		
		--Yakuza
		
		self.values.player.yakuza_frenzy_dr = {
			--Damage Resistance gained, max DR, percentage steps, in that specific order
			--Added the percentage steps as possible future-proofing
			{0.02, 0.9, 0.1}, 
			{0.04, 0.8, 0.1}, 
			{0.06, 0.7, 0.1}, 
			{0.08, 0.6, 0.1}
		}
		self.values.player.yakuza_on_damage_dr = {
			0.1,
			0.2,
			0.3,
			0.4
		}
		self.values.player.yakuza_on_damage_iframes = {true}
		
		self.definitions.yakuza_1 = {
			name_id = "menu_deck12_1",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "yakuza_frenzy_dr",
				category = "player"
			}
		}
		self.definitions.yakuza_2 = {
			name_id = "menu_deck12_2",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "yakuza_on_damage_dr",
				category = "player"
			}
		}
		self.definitions.yakuza_3 = {
			name_id = "menu_deck12_3",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "yakuza_frenzy_dr",
				category = "player"
			}
		}
		self.definitions.yakuza_4 = {
			name_id = "menu_deck12_4",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "yakuza_on_damage_dr",
				category = "player"
			}
		}
		self.definitions.yakuza_5 = {
			name_id = "menu_deck12_5",
			category = "feature",
			upgrade = {
				value = 3,
				upgrade = "yakuza_frenzy_dr",
				category = "player"
			}
		}
		self.definitions.yakuza_6 = {
			name_id = "menu_deck12_6",
			category = "feature",
			upgrade = {
				value = 3,
				upgrade = "yakuza_on_damage_dr",
				category = "player"
			}
		}
		self.definitions.yakuza_7 = {
			name_id = "menu_deck12_7",
			category = "feature",
			upgrade = {
				value = 4,
				upgrade = "yakuza_frenzy_dr",
				category = "player"
			}
		}
		self.definitions.yakuza_8 = {
			name_id = "menu_deck12_8",
			category = "feature",
			upgrade = {
				value = 4,
				upgrade = "yakuza_on_damage_dr",
				category = "player"
			}
		}
		self.definitions.yakuza_9 = {
			name_id = "menu_deck12_9",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "yakuza_on_damage_iframes",
				category = "player"
			}
		}
		
		--Ex-President
		--this perkdeck was kind of a nightmare but i managed to pull it together 
		--im really sorry for offy, who will probably look at this code later and feel nothing but disgust
		
		self.values.player.expres_hot_election = {
			{0.5, 20}, --stacks generated per kill, max stacks
			{1, 30}
		}
		self.values.player.expres_hot_armorup = { --cooldown timers for armor up regen
			5,
			4,
			3,
			2
		}
		self.values.player.expres_health_mul = {
			1.3
		}
		self.values.player.expres_dodge_add = {
			0.2
		}
		self.values.player.expres_approval_regenerate_time = {
			1.6
		}
		
		self.definitions.expres_1 = {
			name_id = "menu_deck13_1",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "expres_hot_election",
				category = "player"
			}
		}
		self.definitions.expres_2 = {
			name_id = "menu_deck13_2",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "expres_hot_armorup",
				category = "player"
			}
		}
		self.definitions.expres_3 = {
			name_id = "menu_deck13_3",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "expres_health_mul",
				category = "player"
			}
		}
		self.definitions.expres_4 = {
			name_id = "menu_deck13_4",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "expres_hot_armorup",
				category = "player"
			}
		}
		self.definitions.expres_5 = {
			name_id = "menu_deck13_5",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "expres_dodge_add",
				category = "player"
			}
		}
		self.definitions.expres_6 = {
			name_id = "menu_deck13_6",
			category = "feature",
			upgrade = {
				value = 3,
				upgrade = "expres_hot_armorup",
				category = "player"
			}
		}
		self.definitions.expres_7 = {
			name_id = "menu_deck13_7",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "expres_hot_election",
				category = "player"
			}
		}
		self.definitions.expres_8 = {
			name_id = "menu_deck13_8",
			category = "feature",
			upgrade = {
				value = 4,
				upgrade = "expres_hot_armorup",
				category = "player"
			}
		}
		self.definitions.expres_9 = {
			name_id = "menu_deck13_9",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "expres_approval_regenerate_time",
				category = "player"
			}
		}
		
		--Gambler
		self.values.team.player.ammo_pickup_counter_thresholds = {
			20,
			15,
			10,
			5
		}
		self.values.team.player.ammo_pickup_range_mul = {
			1,
			1.25, --25%
			1.50, --+50%
			1.75, --+75%
			2 --+100%
		}
		self.values.team.player.ammo_pickup_health_restore = {
			0.01,
			0.015
		}
		
		self.definitions.gambler_range_1 = {
			name_id = "menu_deck10_2",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "ammo_pickup_range_mul",
				category = "player"
			}
		}
		self.definitions.gambler_range_2 = {
			name_id = "menu_deck10_4",
			category = "team",
			upgrade = {
				value = 2,
				upgrade = "ammo_pickup_range_mul",
				category = "player"
			}
		}
		self.definitions.gambler_range_3 = {
			name_id = "menu_deck10_6",
			category = "team",
			upgrade = {
				value = 3,
				upgrade = "ammo_pickup_range_mul",
				category = "player"
			}
		}
		self.definitions.gambler_range_4 = {
			name_id = "menu_deck10_8",
			category = "team",
			upgrade = {
				value = 4,
				upgrade = "ammo_pickup_range_mul",
				category = "player"
			}
		}
		self.definitions.gambler_threshold_1 = {
			name_id = "menu_deck10_1_threshold",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "ammo_pickup_counter_thresholds",
				category = "player"
			}
		}
		self.definitions.gambler_threshold_2 = {
			name_id = "menu_deck10_3",
			category = "team",
			upgrade = {
				value = 2,
				upgrade = "ammo_pickup_counter_thresholds",
				category = "player"
			}
		}
		self.definitions.gambler_threshold_3 = {
			name_id = "menu_deck10_5",
			category = "team",
			upgrade = {
				value = 3,
				upgrade = "ammo_pickup_counter_thresholds",
				category = "player"
			}
		}
		self.definitions.gambler_threshold_4 = {
			name_id = "menu_deck10_7",
			category = "team",
			upgrade = {
				value = 4,
				upgrade = "ammo_pickup_counter_thresholds",
				category = "player"
			}
		}
		self.definitions.gambler_healing_1 = {
			name_id = "menu_deck10_1",
			category = "team",
			upgrade = {
				value = 1,
				upgrade = "ammo_pickup_health_restore",
				category = "player"
			}
		}
		self.definitions.gambler_healing_2 = {
			name_id = "menu_deck10_9",
			category = "team",
			upgrade = {
				value = 2,
				upgrade = "ammo_pickup_health_restore",
				category = "player"
			}
		}
		
		
		
		--Anarchist
		self.values.player.anarch_conversion = { --i...don't understand why the math turns out this way but you need to do it like this or the health doesnt apply properly
			0.5,
			0.6,
			0.7,
			0.8,
			0.9
		}
		self.values.player.anarch_ondmg_armor_regen = {0.5}
		self.values.player.anarch_onkill_armor_regen = {1}
		self.values.player.anarch_onheadshotdmg_armor_regen = {1.5}
		self.values.player.anarch_onheadshotkill_armor_regen = {2}
		
		self.definitions.anarch_1 = {
			name_id = "menu_deck13_1",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "anarch_conversion",
				category = "player"
			}
		}
		self.definitions.anarch_2 = {
			name_id = "menu_deck13_2",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "anarch_ondmg_armor_regen",
				category = "player"
			}
		}
		self.definitions.anarch_3 = {
			name_id = "menu_deck13_3",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "anarch_conversion",
				category = "player"
			}
		}
		self.definitions.anarch_4 = {
			name_id = "menu_deck13_4",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "anarch_onkill_armor_regen",
				category = "player"
			}
		}
		self.definitions.anarch_5 = {
			name_id = "menu_deck13_5",
			category = "feature",
			upgrade = {
				value = 3,
				upgrade = "anarch_conversion",
				category = "player"
			}
		}
		self.definitions.anarch_6 = {
			name_id = "menu_deck13_6",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "anarch_onheadshotdmg_armor_regen",
				category = "player"
			}
		}
		self.definitions.anarch_7 = {
			name_id = "menu_deck13_7",
			category = "feature",
			upgrade = {
				value = 4,
				upgrade = "anarch_conversion",
				category = "player"
			}
		}
		self.definitions.anarch_8 = {
			name_id = "menu_deck13_8",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "anarch_onheadshotkill_armor_regen",
				category = "player"
			}
		}
		self.definitions.anarch_9 = {
			name_id = "menu_deck13_9",
			category = "feature",
			upgrade = {
				value = 5,
				upgrade = "anarch_conversion",
				category = "player"
			}
		}
		
		--Tag Team
		self.values.player.tag_team_base_deathvox = {
			{
				distance = 1800,
				duration = 5,
				cooldown = 60,
				max_angle = 30,
--				radius = 0.6
			}
		}
		self.definitions.player_tag_team_base_deathvox = {
			name_id = "menu_deck20_0",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "tag_team_base_deathvox",
				synced = true,
				category = "player"
			}
		}
		
		self.values.player.tag_team_health_regen = {
			0.05,
			0.10
		}
		self.definitions.player_tag_team_health_regen_1 = {
			name_id = "menu_deck20_1",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "tag_team_health_regen",
				synced = true,
				category = "player"
			}
		}
		self.definitions.player_tag_team_health_regen_2 = {
			name_id = "menu_deck20_6",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "tag_team_health_regen",
				synced = true,
				category = "player"
			}
		}
		
		self.values.player.tag_team_long_distance_revive = {	
			0.1,
			0.1
		}
		self.definitions.player_tag_team_long_distance_revive = { 
			name_id = "menu_deck20_2",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "tag_team_long_distance_revive",
				synced = true,
				category = "player"
			}
		}
		self.definitions.player_tag_team_long_distance_revive_full_effects = {
			name_id = "menu_deck20_9",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "tag_team_long_distance_revive",
				synced = true,
				category = "player"
			}
		}
		
		self.values.player.tag_team_movement_speed_bonus = {
			1.2
		}
		self.definitions.player_tag_team_movement_speed_bonus = {
			name_id = "menu_deck20_3",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "tag_team_movement_speed_bonus",
				synced = true,
				category = "player"
			}
		}
		
		self.values.player.tag_team_effect_empathy = {true}
		self.definitions.player_tag_team_effect_empathy = {
			name_id = "menu_deck20_4",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "tag_team_effect_empathy",
				category = "player"
			}
		}
		
		self.values.player.tag_team_damage_resistance = {
			0.1
		}
		self.definitions.player_tag_team_damage_resistance = {
			name_id = "menu_deck20_5",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "tag_team_damage_resistance",
				synced = true,
				category = "player"
			}
		}

		--tweaked vanilla values
		self.values.player.tag_team_cooldown_drain = {
			{ --only this first table is used now
				tagged = 1,
				owner = 1
			},
			{
				tagged = 2,
				owner = 2
			}
		}
		
		self.values.player.tag_team_duration_increase = {
			5
		}
		self.definitions.player_tag_team_duration_increase_1 = {
			name_id = "menu_deck20_8",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "tag_team_duration_increase",
				synced = true,
				category = "player"
			}
		}
	end
end)	

Hooks:PostHook(UpgradesTweakData,"_init_pd2_values","tcd_upgradestweakdata_btnmacros",function(self)
	if self.skill_btns then 
		self.skill_btns.steroids = self.skill_btns.steroids or {}
		self.skill_btns.steroids.BTN_THROW_GRENADE = self.skill_btns.steroids.BTN_ABILITY or function() return utf8.to_upper(managers.localization:btn_macro("throw_grenade")) end
		--BTN_ABILITY should be separate
	end
end)