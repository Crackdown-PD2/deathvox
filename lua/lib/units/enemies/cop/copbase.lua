function CopBase:_chk_spawn_gear()
	--[[if self._unit:base():char_tweak().ends_assault_on_death then
		managers.groupai:state():register_phalanx_vip(self._unit)
		GroupAIStateBesiege:set_assault_endless(true)
		managers.hud:set_buff_enabled("vip", true)

		for u_key, u_data in pairs(managers.enemy:all_enemies()) do
			if alive(u_data.unit) then
				managers.fire:_add_hellfire_enemy(u_data.unit)
			end
		end

		for _, converted_enemy_unit in pairs(managers.groupai:state():all_converted_enemies()) do
			if alive(converted_enemy_unit) then
				local action_data = {
					variant = "fire",
					damage = 99999999999,
					weapon_unit = nil,
					attacker_unit = nil,
					col_ray = {unit = converted_enemy_unit},
					is_fire_dot_damage = true,
					is_molotov = false
				}
				converted_enemy_unit:character_damage():damage_fire(action_data)
			end
		end
	end

	if alive(managers.groupai:state():phalanx_vip()) then
		managers.fire:_add_hellfire_enemy(self._unit)
	end]]

	if self:has_tag("spooc") then
		if self._unit:damage() and self._unit:damage():has_sequence("turn_on_spook_lights") then
			self._unit:damage():run_sequence_simple("turn_on_spook_lights")
		end

		local job_tweak_data = tweak_data.narrative.jobs[managers.job:current_real_job_id()]

		if job_tweak_data and job_tweak_data.is_christmas_heist then
			local align_obj_name = Idstring("Head")
			local align_obj = self._unit:get_object(align_obj_name)
			self._headwear_unit = World:spawn_unit(Idstring("units/payday2/characters/ene_acc_spook_santa_hat/ene_acc_spook_santa_hat"), Vector3(), Rotation())

			self._unit:link(align_obj_name, self._headwear_unit, self._headwear_unit:orientation_object():name())
		end
	end
end

function CopBase:default_weapon_name()
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)

	if diff_index < 4 then
		local unit_name = self._unit:name()
		local classic_shield = unit_name == Idstring("units/pd2_mod_classic/characters/ene_deathvox_classic_shield/ene_deathvox_classic_shield") or unit_name == Idstring("units/pd2_mod_classic/characters/ene_deathvox_classic_shield/ene_deathvox_classic_shield_husk")

		if classic_shield then
			local deathvox_pistol = Idstring("units/pd2_mod_gageammo/pew_pew_lasers/wpn_npc_c45/wpn_npc_c45")

			return deathvox_pistol
		end
	end

	local default_weapon_id = self._default_weapon_id
	local weap_ids = tweak_data.character.weap_ids

	for i_weap_id, weap_id in ipairs(weap_ids) do
		if default_weapon_id == weap_id then
			return tweak_data.character.weap_unit_names[i_weap_id]
		end
	end
end
