
if deathvox:IsTotalCrackdownEnabled() then 
	Hooks:PostHook(FirstAidKitBase,"init","tcd_fak_init",function(self,unit)
		self._auto_recovery_upgrade = 0
		self._damage_overshield_upgrade = 0
	end)
	function FirstAidKitBase:get_auto_recovery_cooldown()
		return self._auto_recovery_upgrade and tweak_data.upgrades.values.first_aid_kit.auto_recovery_cooldown[self._auto_recovery_upgrade]
	end
	
	function FirstAidKitBase:setup(bits)
		local upgrade_lvl, auto_recovery = self:_get_upgrade_levels(bits)
		self._damage_overshield_upgrade = upgrade_lvl
		self._auto_recovery_upgrade = auto_recovery
		
		if Network:is_server() then
			local from_pos = self._unit:position() + self._unit:rotation():z() * 10
			local to_pos = self._unit:position() + self._unit:rotation():z() * -10
			local ray = self._unit:raycast("ray", from_pos, to_pos, "slot_mask", managers.slot:get_mask("world_geometry"))

			if ray then
				self._attached_data = {
					body = ray.body,
					position = ray.body:position(),
					rotation = ray.body:rotation(),
					index = 1,
					max_index = 3
				}

				self._unit:set_extension_update_enabled(Idstring("base"), true)
			end
		end

		if auto_recovery > 0 then
			self._min_distance = tweak_data.upgrades.values.first_aid_kit.first_aid_kit_auto_recovery[1]

			FirstAidKitBase.Add(self, self._unit:position(), self._min_distance)
		end
	end
	
	function FirstAidKitBase:take(unit)
		if self._empty then
			return
		end

		unit:character_damage():band_aid_health()

		if self._damage_overshield_upgrade > 1 then 
			unit:character_damage():_activate_preventative_care(self._damage_overshield_upgrade)
		end

		if managers.network:session() then
			managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", 2)
		end

		self:_set_empty()
	end

	
end