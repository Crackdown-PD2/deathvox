if deathvox and deathvox:IsTotalCrackdownEnabled() then

	Hooks:PostHook(EquipmentsTweakData,"init","tcd_equipmentstweakdata_init",function(self, tweak_data)
		self.armor_kit.dummy_unit = "units/pd2_mod_armorbag/equipment/gen_equipment_armorpak_bag/gen_equipment_armorpak_bag_dummy"
		self.armor_kit.use_function_name = "use_armor_plates"
		self.armor_kit.limit_movement = false
		self.specials.cable_tie.quantity = 10
		self.specials.cable_tie.max_quantity = 10
		
		self.first_aid_kit.target_deploy_text = "hud_deploying_revive_fak"
		self.first_aid_kit.target_type = "teammates"
		
		self.sentry_gun_silent = {
			deploy_time = 3,
			deploy_distance = 150,
			deploying_text_id = "hud_deploying_friendship_collar",
			target_deploy_text = "hud_deploying_friendship_collar",
			target_type = "enemies",
--			dummy_unit = "units/payday2/equipment/gen_equipment_sentry/gen_equipment_sentry_dummy",
			text_id = "debug_silent_sentry_gun",
			use_function_name = "use_friendship_collar",
--			unit = 2,
--			min_ammo_cost = 2,
--			ammo_cost = math.huge,
			visual_object = "g_toolbag",
			icon = "mugshot_cuffed",
			description_id = "des_sentry_gun",
			quantity = {
				3
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