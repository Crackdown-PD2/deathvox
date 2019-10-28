function HuskPlayerDamage:damage_fire(attack_data)
	if managers.mutators:is_mutator_active(MutatorFriendlyFire) then
		local apply_damage_reduction = true
		local attacker_unit = attack_data.attacker_unit

		if attacker_unit then
			if attacker_unit:base() and attacker_unit:base().thrower_unit then
				attacker_unit = attacker_unit:base():thrower_unit()
			end

			if attacker_unit:base().is_husk_player then
				apply_damage_reduction = false
			end
		end

		if apply_damage_reduction then
			attack_data.damage = attack_data.damage * 0.2
		end

		self:_send_damage_to_owner(attack_data)
	end
end
