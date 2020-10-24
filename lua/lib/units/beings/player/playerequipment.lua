if deathvox:IsTotalCrackdownEnabled() then


	function PlayerEquipment:use_armor_plates()
		local ray = self:valid_shape_placement("armor_kit",{dummy_unit = tweak_data.equipments.armor_kit.dummy_unit})
		local pos = ray.position
		local rot = Rotation(self:_m_deploy_rot():yaw(),0,0)
		
		local bits = 4 --not actually used
		
		if Network:is_client() then
			managers.network:session():send_to_host("place_deployable_bag", "ArmorPlatesBase", pos, rot, bits)
			return true
		else
			local unit = ArmorPlatesBase.spawn(pos, rot, bits, managers.network:session():local_peer():id())
			return true
		end
	end
	
	function PlayerEquipment:use_first_aid_kit()
		local ray,nearest_player = self:valid_shape_placement("first_aid_kit")

		if ray then
			local pos = ray.position
			local rot = self:_m_deploy_rot()
			rot = Rotation(rot:yaw(), 0, 0)

			managers.statistics:use_first_aid()
			
			if nearest_player and alive(nearest_player) then 
				PlayerStandard.say_line(self, "f36x_any")
				
				nearest_player:interaction():interact(self._unit,true)
			else
				PlayerStandard.say_line(self, "s12")
			
				local upgrade_lvl = managers.player:has_category_upgrade("first_aid_kit", "damage_reduction_upgrade") and 1 or 0
				local auto_recovery = managers.player:has_category_upgrade("first_aid_kit", "first_aid_kit_auto_recovery") and 1 or 0
				local bits = Bitwise:lshift(auto_recovery, FirstAidKitBase.auto_recovery_shift) + Bitwise:lshift(upgrade_lvl, FirstAidKitBase.upgrade_lvl_shift)
				
				if Network:is_client() then
					managers.network:session():send_to_host("place_deployable_bag", "FirstAidKitBase", pos, rot, bits)
				else
					local unit = FirstAidKitBase.spawn(pos, rot, bits, managers.network:session():local_peer():id())
				end
			end

			return true
		end

		return false
	end
		
	function PlayerEquipment:valid_shape_placement(equipment_id, equipment_data)
		local from = self._unit:movement():m_head_pos()
		local to = from + self._unit:movement():m_head_rot():y() * 220
		local ray = self._unit:raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {}, "ray_type", "equipment_placement")
		local valid = ray and true or false
		local revivable_unit
		if ray then
			local pos = ray.position
			local rot = self._unit:movement():m_head_rot()
			rot = Rotation(rot:yaw(), 0, 0)
			
			local closest_distance = managers.player:upgrade_value("first_aid_kit","auto_revive",0) --init as max distance
			if closest_distance > 0 then
				for i,peer_unit in pairs(World:find_units_quick("sphere",pos,closest_distance,managers.slot:get_mask("criminals_no_deployables"))) do 
					if peer_unit ~= self._unit then 
						if peer_unit:movement() and peer_unit:movement().downed and peer_unit:movement():downed() then 
							local distance_to = mvector3.distance(pos,peer_unit:movement():m_pos())
							if distance_to < closest_distance then 
								closest_distance = distance_to
								revivable_unit = peer_unit
							end
						end
					end
				end
			end
			if not alive(self._dummy_unit) then
				self._dummy_unit = World:spawn_unit(Idstring(equipment_data.dummy_unit), pos, rot)

				self:_disable_contour(self._dummy_unit)
			end

			self._dummy_unit:set_position(pos)
			self._dummy_unit:set_rotation(rot)

			valid = valid and math.dot(ray.normal, math.UP) > 0.25
			local find_start_pos, find_end_pos, find_radius = nil

			if equipment_id == "ammo_bag" then
				find_start_pos = pos + math.UP * 20
				find_end_pos = pos + math.UP * 21
				find_radius = 12
			elseif equipment_id == "doctor_bag" then
				find_start_pos = pos + math.UP * 22
				find_end_pos = pos + math.UP * 28
				find_radius = 15
			else
				find_start_pos = pos + math.UP * 30
				find_end_pos = pos + math.UP * 40
				find_radius = 17
			end

			local bodies = self._dummy_unit:find_bodies("intersect", "capsule", find_start_pos, find_end_pos, find_radius, managers.slot:get_mask("trip_mine_placeables") + 14 + 25)

			for _, body in ipairs(bodies) do
				if body:unit() ~= self._dummy_unit and body:has_ray_type(Idstring("body")) then
					valid = false

					break
				end
			end
		end

		if alive(self._dummy_unit) then
			self._dummy_unit:set_enabled(valid)
		end


		return valid and ray,revivable_unit
	end	
	
	
end