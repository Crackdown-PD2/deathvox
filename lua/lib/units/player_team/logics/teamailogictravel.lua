function TeamAILogicTravel.check_inspire(data, attention)
	if not attention then
		return
	end

	local range_sq = 810000
	local pos = data.unit:position()
	local target = attention.unit:position()
	local dist = mvector3.distance_sq(pos, target)

	if dist < range_sq and not attention.unit:character_damage():arrested() then
		data.unit:brain():set_objective()
		data.unit:sound():say("f36x_any", true, false)

		if not data.internal_data.firing and not data.internal_data.shooting and not data.unit:anim_data().reload then
			local new_action = {
				variant = "cmd_get_up",
				align_sync = true,
				body_part = 3,
				type = "act"
			}

			if data.unit:brain():action_request(new_action) then
				data.internal_data.gesture_arrest = true
			end
		end

		local cooldown = managers.player:crew_ability_upgrade_value("crew_inspire", 360)

		managers.player:start_custom_cooldown("team", "crew_inspire", cooldown)
		TeamAILogicTravel.actually_revive(data, attention.unit, true)
	end
end
