function MedicDamage:heal_unit(unit, override_cooldown)
	if self._unit:anim_data() and self._unit:anim_data().act then
		return false
	end

	local t = Application:time()

	if not override_cooldown then
		local cooldown = tweak_data.medic.cooldown
		cooldown = managers.modifiers:modify_value("MedicDamage:CooldownTime", cooldown)

		if t < self._heal_cooldown_t + cooldown then
			return false
		end
	end

	local tweak_table = unit:base()._tweak_table

	if table.contains(tweak_data.medic.disabled_units, tweak_table) then
		return false
	end

	local team = unit:movement().team and unit:movement():team()

	if team and team.id ~= "law1" then
		if not team.friends or not team.friends.law1 then
			return false
		end
	end

	if unit:brain() then
		if unit:brain().converted then
			if unit:brain():converted() then
				return false
			end
		elseif unit:brain()._logic_data and unit:brain()._logic_data.is_converted then
			return false
		end
	end

	self._heal_cooldown_t = t

	if not self._unit:character_damage():dead() then
		local action_data = {
			body_part = 1,
			type = "heal",
			client_interrupt = Network:is_client()
		}

		self._unit:movement():action_request(action_data)

		if self._unit:base():char_tweak().custom_voicework then
			local voicelines = _G.voiceline_framework.BufferedSounds[self._unit:base():char_tweak().custom_voicework]

			if voicelines and voicelines["heal"] then
				local line_to_use = voicelines.heal[math.random(#voicelines.heal)]

				self._unit:base():play_voiceline(line_to_use)
			end
		end
	end

	managers.network:session():send_to_peers_synched("sync_medic_heal", self._unit)
	MedicActionHeal:check_achievements()

	return true
end
