if deathvox and deathvox:IsTotalCrackdownEnabled() then

	Hooks:PostHook(EquipmentsTweakData,"init","tcd_equipmentstweakdata_init",function(self, tweak_data)
		self.armor_kit = {
			deploy_time = 2,
			use_function_name = "use_armor_plates",
			dummy_unit = "units/pd2_mod_armorbag/equipment/gen_equipment_armorpak_bag/gen_equipment_armorpak_bag_dummy",
			sound_done = "bar_armor_finished",
			dropin_penalty_function_name = nil,
			icon = "equipment_armor_kit",
			description_id = "des_armor_kit",
			limit_movement = false,
			sound_start = "bar_armor",
			sound_interupt = "bar_armor_cancel",
			text_id = "debug_equipment_armor_kit",
			on_use_callback = "on_use_armor_bag",
			deploying_text_id = "hud_equipment_equipping_armor_kit",
			action_timer = 2,
			visual_object = "g_armorbag",
			quantity = {
				1
			}
		}
		
		self.specials.cable_tie.quantity = 10
		self.specials.cable_tie.max_quantity = 10
		
		self.first_aid_kit.target_deploy_text = "hud_deploying_revive_fak"
		self.first_aid_kit.target_type = "teammates"
		
		self.sentry_gun_silent = {
			deploy_time = 1,
			deploy_distance = 150,
			deploying_text_id = "hud_deploying_friendship_collar",
			target_deploy_text = "hud_deploying_friendship_collar",
			target_type = "enemies",
			dummy_unit = nil, --"units/payday2/equipment/gen_equipment_sentry/gen_equipment_sentry_dummy",
			text_id = "debug_silent_sentry_gun",
			use_function_name = "use_friendship_collar",
--			unit = 2,
--			min_ammo_cost = 2,
--			ammo_cost = math.huge,
			visual_object = "g_toolbag",
			icon = "mugshot_cuffed",
			description_id = "des_sentry_gun",
			quantity = {
				6
			},
--			upgrade_deploy_time_multiplier = {
--				upgrade = "sentry_gun_deploy_time_multiplier",
--				category = "player"
--			}
			upgrade_name = {
				"friendship_collar"
			}
		}
		
		
		self.max_amount.doctor_bag = 3
		self.max_amount.first_aid_kit = 18
		self.max_amount.trip_mine = math.huge
		self.max_amount.ammo_bag = 3
		
		self.trip_mine.quantity = {
			0,
			4
		}
		
		self.tripmine_throwable = {
			deploy_time = 2,
			dummy_unit = "units/payday2/equipment/gen_equipment_tripmine/gen_equipment_tripmine_dummy",
			use_function_name = "use_trip_mine",
			text_id = "debug_trip_mine_throwable",
			visual_object = "g_toolbag",
			icon = "equipment_trip_mine",
			description_id = "des_trip_mine",
			quantity = 4,
			upgrade_deploy_time_multiplier = {
				upgrade = "trip_mine_deploy_time_multiplier",
				category = "player"
			}
		}
	end)
end