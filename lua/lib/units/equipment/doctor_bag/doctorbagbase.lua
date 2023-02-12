if deathvox:IsTotalCrackdownEnabled() then 
	
	local mvec3_dis = mvector3.distance
			
	DoctorBagBase.List = {}
	
	function DoctorBagBase.Add(obj, pos, min_distance, upgrade_lvl)
		table.insert(DoctorBagBase.List,{
			obj = obj,
			pos = pos,
			min_distance = min_distance,
			upgrade_lvl = upgrade_lvl
		})
	end

	function DoctorBagBase.Remove(obj)
		for i, o in pairs(DoctorBagBase.List) do
			if obj == o.obj then
				table.remove(DoctorBagBase.List,i)
				return
			end
		end
	end
	
	--since this includes a raycast LoS check, it is not recommended to call this every frame
	function DoctorBagBase.GetDoctorBag(pos)
		local best_bag
		for i=#DoctorBagBase.List,1,-1 do 
			local o = DoctorBagBase.List[i]
			local dst = mvec3_dis(pos, o.pos)
			local max_upgrade_lvl = 0
			local t = managers.player:player_timer():time()
			if alive(o.obj._unit) then 
				if dst <= o.min_distance and o.upgrade_lvl > max_upgrade_lvl then
					local raycast = World:raycast("ray",o.pos,pos,"slot_mask",managers.slot:get_mask("world_geometry"),"ignore_unit",o.obj._unit)
					if not raycast then 
						best_bag = o.obj
						max_upgrade_lvl = o.upgrade_lvl
					end
				end
			else
				DoctorBagBase.Remove(obj)
			end
		end
		return best_bag
	end

	function DoctorBagBase:setup(bits)
		local amount_upgrade_lvl, dmg_reduction_lvl = self:_get_upgrade_levels(bits)
		self._damage_reduction_upgrade = false
		self._damage_overshield_upgrade = dmg_reduction_lvl
		self._amount = tweak_data.upgrades.doctor_bag_base

		self._aoe_health_regen_level = amount_upgrade_lvl
		if amount_upgrade_lvl ~= 0 then 
			local min_distance = managers.player:upgrade_value_by_level("doctor_bag","aoe_health_regen",amount_upgrade_lvl,{0,0,math.huge})[3]
			DoctorBagBase.Add(self,
				self._unit:oobb():center(),
				min_distance,
				amount_upgrade_lvl
			)
		end

		self:_set_visual_stage()
		
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
			
			self._unit:set_extension_update_enabled(Idstring("base"), true)
		end
	end

	function DoctorBagBase:update(unit, t, dt)
		if self._attached_data then 
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

		if self._damage_overshield_upgrade and self._damage_overshield_upgrade > 0 then 
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

	Hooks:PreHook(DoctorBagBase,"destroy","tcd_docgbag_destroy",function(self)
		DoctorBagBase.Remove(self)
	end)
end