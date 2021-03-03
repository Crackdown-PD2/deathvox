if deathvox:IsTotalCrackdownEnabled() then
	

	function CivilianDamage:damage_bullet(attack_data)
		if self._unit:brain():is_tied() and managers.player:has_team_category_upgrade("player","civilian_hostage_stationary_invuln") then 
			return
		end
		
		if managers.player:has_category_upgrade("player", "civ_harmless_bullets") and self.no_intimidation_by_dmg and not self:no_intimidation_by_dmg() and (not self._survive_shot_t or self._survive_shot_t < TimerManager:game():time()) then
			self._survive_shot_t = TimerManager:game():time() + 2.5

			self._unit:brain():on_intimidated(1, attack_data.attacker_unit)

			return
		end

		attack_data.damage = 10

		return CopDamage.damage_bullet(self, attack_data)
	end

	function CivilianDamage:damage_explosion(attack_data)
		if self._unit:brain():is_tied() and managers.player:has_team_category_upgrade("player","civilian_hostage_stationary_invuln") then 
			return
		end
		if attack_data.variant == "explosion" then
			attack_data.damage = 10
		end

		return CopDamage.damage_explosion(self, attack_data)
	end

	function CivilianDamage:damage_fire(attack_data)
		if self._unit:brain():is_tied() and managers.player:has_team_category_upgrade("player","civilian_hostage_stationary_invuln") then 
			return
		end
		if attack_data.variant == "fire" then
			attack_data.damage = 10
		end

		return CopDamage.damage_fire(self, attack_data)
	end

	function CivilianDamage:damage_melee(attack_data)
		if self._unit:brain():is_tied() and managers.player:has_team_category_upgrade("player","civilian_hostage_stationary_invuln") then 
			return
		end
		if managers.player:has_category_upgrade("player", "civ_harmless_melee") and self.no_intimidation_by_dmg and not self:no_intimidation_by_dmg() and (not self._survive_shot_t or self._survive_shot_t < TimerManager:game():time()) then
			self._survive_shot_t = TimerManager:game():time() + 2.5

			self._unit:brain():on_intimidated(1, attack_data.attacker_unit)

			return
		end

		if _G.IS_VR and attack_data.damage == 0 then
			return
		end

		attack_data.damage = 10

		return CopDamage.damage_melee(self, attack_data)
	end

	function CivilianDamage:damage_tase(attack_data)
		if self._unit:brain():is_tied() and managers.player:has_team_category_upgrade("player","civilian_hostage_stationary_invuln") then 
			return
		end
		if managers.player:has_category_upgrade("player", "civ_harmless_melee") and self.no_intimidation_by_dmg and not self:no_intimidation_by_dmg() and (not self._survive_shot_t or self._survive_shot_t < TimerManager:game():time()) then
			self._survive_shot_t = TimerManager:game():time() + 2.5

			self._unit:brain():on_intimidated(1, attack_data.attacker_unit)

			return
		end

		attack_data.damage = 10

		return CopDamage.damage_tase(self, attack_data)
	end
	
end