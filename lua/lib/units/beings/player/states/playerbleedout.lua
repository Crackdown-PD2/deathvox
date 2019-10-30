function PlayerBleedOut:on_rescue_SO_administered(revive_SO_data, receiver_unit)
	if revive_SO_data.rescuer then
		debug_pause("[PlayerBleedOut:on_rescue_SO_administered] Already had a rescuer!!!!", receiver_unit, revive_SO_data.rescuer)
	end

	revive_SO_data.rescuer = receiver_unit
	revive_SO_data.SO_id = nil

	if receiver_unit:movement():carrying_bag() then
		if not receiver_unit:movement():carry_tweak().can_run then
			local range_sq = 810000
			local pos = receiver_unit:position()
			local target = revive_SO_data.unit:position()
			local dist = mvector3.distance_sq(pos, target)

			local speed_modifier = receiver_unit:movement():carry_tweak().move_speed_modifier
			local heavy_carry = speed_modifier == 0.6 or speed_modifier == 0.5
			local very_heavy_carry = speed_modifier < 0.5
			local no_inspire_cooldown = managers.player:is_custom_cooldown_not_active("team", "crew_inspire")

			if dist < range_sq then
				if not no_inspire_cooldown and very_heavy_carry then
					receiver_unit:movement():throw_bag()
				end
			else
				if (not no_inspire_cooldown and heavy_carry) or very_heavy_carry then
					receiver_unit:movement():throw_bag()
				end
			end
		end
	end
end
