local math_random = math.random

function MedicDamage:heal_unit(unit_to_heal, no_cooldown)
	if not no_cooldown then
		local t = Application:time()

		self._heal_cooldown_t = t
	end

	if not self._unit:character_damage():dead() then
		local action_data = {
			body_part = 1,
			type = "heal",
			client_interrupt = Network:is_client()
		}

		self._unit:movement():action_request(action_data)

		local base_ext = self._unit:base()
		local custom_vo = base_ext:char_tweak().custom_voicework

		if custom_vo then
			local voicelines = _G.voiceline_framework.BufferedSounds[custom_vo]

			if voicelines and voicelines["heal"] then
				local line_to_use = voicelines.heal[math_random(#voicelines.heal)]

				base_ext:play_voiceline(line_to_use)
			end
		end
	end

	managers.network:session():send_to_peers_synched("sync_medic_heal", self._unit)
	MedicActionHeal:check_achievements()

	return true
end
