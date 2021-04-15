if deathvox:IsTotalCrackdownEnabled() then 
	Hooks:PostHook(DoctorBagBase,"init","tcd_docbag_init",function(self,unit)
		self.last_aoe_heal_t = 0
	end)


	function DoctorBagBase:setup(bits)
		local amount_upgrade_lvl, dmg_reduction_lvl = self:_get_upgrade_levels(bits)
		self._damage_reduction_upgrade = false
		self._damage_overshield_upgrade = dmg_reduction_lvl
		self._amount = tweak_data.upgrades.doctor_bag_base

		if amount_upgrade_lvl == 0 then 
			self._aoe_health_regen = false
		else
			self._aoe_health_regen = managers.player:upgrade_value_by_level("doctor_bag","aoe_health_regen",amount_upgrade_lvl,{0,0,math.huge})
		end

		self:_set_visual_stage()
		local should_update = self._aoe_health_regen and true or false

		if Network:is_server() and self._is_attachable then
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
			end
			
			should_update = true
		end
		self._unit:set_extension_update_enabled(Idstring("base"), should_update)
	end

	local mvec3_dis = mvector3.distance
	
	function DoctorBagBase:update(unit, t, dt)
		if self._aoe_health_regen then 
			local rate,interval,range = unpack(self._aoe_health_regen)
			if (t - self.last_aoe_heal_t) >= interval then 
				self.last_aoe_heal_t = t
				local player = managers.player:local_player()
				if alive(player) then 
					local docbag_pos = unit:position() + unit:rotation():z() * 10
					local player_pos = player:movement():m_head_pos()
					if mvec3_dis(docbag_pos,player_pos) <= range then 
						local raycast = World:raycast("ray",docbag_pos,player_pos,"slot_mask",managers.slot:get_mask("world_geometry"),"ignore_unit",unit)
						if not raycast then 
							local dmg_ext = player:character_damage()
							local max_health = dmg_ext:_max_health()
							dmg_ext:change_health(rate * max_health)
						end
					end
				end
			end
		end
		if Network:is_server() and self._attached_data then 
			self:_check_body()
		end
	end

	function DoctorBagBase:take(unit)
		if self._empty then
			return
		end
		
		local pm = managers.player

		if self._damage_reduction_upgrade then
			pm:activate_temporary_upgrade("temporary", "first_aid_damage_reduction")
		end

		if self._damage_overshield_upgrade and self._damage_overshield_upgrade > 1 then 
			unit:character_damage():_activate_preventative_care(self._damage_overshield_upgrade)
		end

		local taken = self:_take(unit)

		if taken > 0 then
			unit:sound():play("pickup_ammo")
			managers.network:session():send_to_peers_synched("sync_doctor_bag_taken", self._unit, taken)
			managers.mission:call_global_event("player_refill_doctorbag")
		end

		if self._amount <= 0 then
			self:_set_empty()
		else
			self:_set_visual_stage()
		end

		return taken > 0
	end
end