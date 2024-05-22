function MedicDamage:heal_unit(unit_to_heal, no_cooldown)
	if not no_cooldown then
		local t = Application:time()

		self._heal_cooldown_t = t
	end

	unit_to_heal:character_damage():do_medic_heal()

	local my_unit = self._unit

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

	if my_unit:id() ~= 1 then
		managers.network:session():send_to_peers_synched("sync_medic_heal", my_unit)
	end
	MedicActionHeal:check_achievements()

	return true
end

function MedicDamage:verify_heal_requesting_unit(requesting_unit)

	local base_ext = requesting_unit:base()
	local char_tweak = base_ext and base_ext.char_tweak and base_ext:char_tweak()

	if not char_tweak or char_tweak.can_be_healed == false then
		return false
	end

	local mov_ext = requesting_unit:movement()
	local team = mov_ext and mov_ext.team and mov_ext:team()

	if not team then
		return false
	end

	local my_team = self._unit:movement():team()

	if team ~= my_team and not team.friends[my_team.id] then
		return false
	end


	local anim_data = requesting_unit:anim_data()

	if anim_data and anim_data.act then
		return false
	end

	--further ensure that the unit isn't acting or plans to act
	local act_action, was_queued = requesting_unit:movement():_get_latest_act_action()

	if act_action then
		if not was_queued or not act_action.host_expired then
			return false
		end
	end
	
	-- converts also cannot be healed at all
	local brain_ext = requesting_unit:brain()
	if brain_ext then
		if brain_ext.converted then
			if brain_ext:converted() then
				return false
			end
		elseif brain_ext._logic_data and brain_ext._logic_data.is_converted then
			return false
		end
	end

	return true
end
