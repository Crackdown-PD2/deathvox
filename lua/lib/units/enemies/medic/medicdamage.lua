function MedicDamage:heal_unit(unit_to_heal, no_cooldown)
	if not no_cooldown then
		local t = Application:time()

		self._heal_cooldown_t = t
	end

	local my_unit = self._unit

	if not my_unit:character_damage():dead() then
		local action_data = {
			body_part = 1,
			type = "heal",
			client_interrupt = Network:is_client()
		}

		local base_ext = my_unit:base()
		local custom_vo = base_ext and base_ext:char_tweak().custom_voicework

		if custom_vo then
			local voicelines = deathvox._voiceline_framework.BufferedSounds[custom_vo]

			if voicelines and voicelines["heal"] then
				local line_to_use = voicelines.heal[math_random(#voicelines.heal)]

				base_ext:play_voiceline(line_to_use)
			end
		end

		my_unit:movement():action_request(action_data)
	end

	local sync_unit = my_unit:id() ~= 1 and my_unit or nil

	managers.network:session():send_to_peers_synched("sync_medic_heal", sync_unit)
	MedicActionHeal:check_achievements()

	return true
end
