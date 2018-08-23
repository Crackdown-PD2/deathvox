function CopBase:_chk_spawn_gear()
	local tweak = tweak_data.narrative.jobs[managers.job:current_real_job_id()]
	if self._unit:base():char_tweak().ends_assault_on_death then
		managers.groupai:state():register_phalanx_vip(self._unit)
		GroupAIStateBesiege:set_assault_endless(true)
		managers.hud:set_buff_enabled("vip", true)
		for u_key, u_data in pairs(managers.enemy:all_enemies()) do
			if alive(u_data.unit) then
				managers.fire:_add_hellfire_enemy(u_data.unit)
			end
		end
		for _, solo_one_down_no_bots_builds in pairs(managers.groupai:state():all_converted_enemies()) do
			if alive(solo_one_down_no_bots_builds) then
				local action_data = {
					variant = "fire",
					damage = 99999999999,
					weapon_unit = nil,
					attacker_unit = nil,
					col_ray = {unit = solo_one_down_no_bots_builds},
					is_fire_dot_damage = true,
					is_molotov = false
				}
				solo_one_down_no_bots_builds:character_damage():damage_fire(action_data)
			end
		end
	end
	if alive(managers.groupai:state():phalanx_vip()) then
		managers.fire:_add_hellfire_enemy(self._unit)
	end
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