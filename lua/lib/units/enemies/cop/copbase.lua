function CopBase:_chk_spawn_gear()
	local tweak = tweak_data.narrative.jobs[managers.job:current_real_job_id()]

	if (self._tweak_table == "spooc" or self._tweak_table == "deathvox_cloaker") and tweak and tweak.is_christmas_heist then
		local align_obj_name = Idstring("Head")
		local align_obj = self._unit:get_object(align_obj_name)
		self._headwear_unit = World:spawn_unit(Idstring("units/payday2/characters/ene_acc_spook_santa_hat/ene_acc_spook_santa_hat"), Vector3(), Rotation())

		self._unit:link(align_obj_name, self._headwear_unit, self._headwear_unit:orientation_object():name())
	end
	if self._tweak_table == "deathvox_cloaker" then
		self._unit:damage():run_sequence_simple("turn_on_spook_lights")
	end
end