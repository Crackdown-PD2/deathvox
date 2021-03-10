if deathvox and deathvox:IsTotalCrackdownEnabled() then

	Hooks:PostHook(EquipmentsTweakData,"init","tcd_equipmentstweakdata_init",function(self, tweak_data)
		self.armor_kit.dummy_unit = "units/pd2_mod_armorbag/equipment/gen_equipment_armorpak_bag/gen_equipment_armorpak_bag_dummy"
		self.armor_kit.use_function_name = "use_armor_plates"

		self.specials.cable_tie.quantity = 10
		self.specials.cable_tie.max_quantity = 10
		
		self.armor_kit.limit_movement = false
		
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