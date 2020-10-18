if deathvox:IsTotalCrackdownEnabled() then

	Hooks:PostHook(EquipmentsTweakData,"init","tcd_equipmentstweakdata_init",function(self)
		self.armor_kit.dummy_unit = "units/pd2_mod_armorbag/equipment/gen_equipment_armorpak_bag/gen_equipment_armorpak_bag_dummy"
		self.armor_kit.use_function_name = "use_armor_plates"

		self.specials.cable_tie.quantity = 10
		self.specials.cable_tie.max_quantity = 10
	end)
end