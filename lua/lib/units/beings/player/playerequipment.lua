local mvec3_dis = mvector3.distance
local mvec3_cpy = mvector3.copy

local math_up = math.UP
local math_dot = math.dot
local math_clamp = math.clamp
local math_huge = math.huge

local alive_g = alive
local world_g = World

local idstr_func = Idstring
local body_idstr = idstr_func("body")

local rot_mods = {
	bodybags_bag = -90
}

local custom_find_params = {
	ammo_bag = {
		20,
		21,
		12
	},
	doctor_bag = {
		22,
		28,
		15
	}
}

if deathvox:IsTotalCrackdownEnabled() then

	function PlayerEquipment:valid_look_at_placement(equipment_data, can_place_on_enemies)
		local unit = self._unit
		local mov_ext = unit:movement()

		local from = mov_ext:m_head_pos()
		local head_rot = self:_m_deploy_rot()
		local to = from + head_rot:y() * 220
		local ray, stuck_enemy = nil

		if can_place_on_enemies then
			local slot_manager = managers.slot

			ray = unit:raycast("ray", from, to, "slot_mask", slot_manager:get_mask("enemies"))

			if ray then
				stuck_enemy = ray.unit
			else
				ray = unit:raycast("ray", from, to, "slot_mask", slot_manager:get_mask("trip_mine_placeables"), "ray_type", "equipment_placement")
			end
		else
			ray = unit:raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ray_type", "equipment_placement")
		end

		local dummy_unit = self._dummy_unit

		if ray then
			local equipment_dummy = equipment_data and equipment_data.dummy_unit

			if equipment_dummy then
				local dummy_pos = ray.position
				local dummy_rot = Rotation(ray.normal, math_up)

				if alive_g(dummy_unit) then
					dummy_unit:set_position(dummy_pos)
					dummy_unit:set_rotation(dummy_rot)
				else
					dummy_unit = world_g:spawn_unit(idstr_func(equipment_dummy), dummy_pos, dummy_rot)

					self:_disable_contour(dummy_unit)
				end
			end
		end

		if alive_g(dummy_unit) then
			local vis_state = ray and true or false

			dummy_unit:set_visible(vis_state)
		end

		self._dummy_unit = dummy_unit

		return ray, stuck_enemy
	end

	function PlayerEquipment:use_trip_mine()
		local ray, stuck_enemy = self:valid_look_at_placement(nil, managers.player:has_category_upgrade("trip_mine", "can_place_on_enemies"))

		if ray then
			managers.statistics:use_trip_mine()

			local mark_duration_upgrade = managers.player:has_category_upgrade("trip_mine", "trip_mine_extended_mark_duration")
			
			local hit_position = ray.hit_position
			local rot = Rotation(ray.normal, math_up)
			local radius_upgrade_level = managers.player:upgrade_level("trip_mine","stuck_enemy_panic_radius",0)
			local vulnerability_upgrade_level = managers.player:upgrade_level("trip_mine","stuck_dozer_damage_vulnerability",0)
			local bits = Bitwise:lshift(radius_upgrade_level, TripMineBase.radius_upgrade_shift) + Bitwise:lshift(vulnerability_upgrade_level, TripMineBase.vulnerability_upgrade_shift) + 1
			local session = managers.network:session()
			
			if Network:is_client() then
				--todo send unit to attach to
				if stuck_enemy then 
					session:send_to_host("sync_attach_projectile",stuck_enemy,false,stuck_enemy,ray.body,ray.body:root_object(),hit_position,ray.normal,bits,session:local_peer():id())
				else
					managers.network:session():send_to_host("place_trip_mine", ray.position, ray.normal, mark_duration_upgrade)
				end
--				session:send_to_host("sync_deployable_attachment",stuck_enemy,ray.body,hit_position,rot)
			else
				local unit = TripMineBase.spawn(ray.position, rot, trip_mine_extended_mark_duration, managers.network:session():local_peer():id())
				local player_unit = self._unit
				unit:base():set_active(true, player_unit)
				
				if stuck_enemy then
					unit:base():attach_to_enemy(stuck_enemy,ray.position,rot,ray.body:root_object(),radius_upgrade_level,vulnerability_upgrade_level)
					session:send_to_peers("sync_attach_projectile",unit,false,stuck_enemy,ray.body,ray.body:root_object(),hit_position,ray.normal,bits,session:local_peer():id())
				end
			end

			return true
		end

		return false
	end

	function PlayerEquipment:use_armor_plates()
		local ray = self:valid_shape_placement("armor_kit")--, {dummy_unit = tweak_data.equipments.armor_kit.dummy_unit})
		local pos = ray.position
		local rot = Rotation(self:_m_deploy_rot():yaw(), 0, 0)
		local bits = 4 --not actually used

		if Network:is_client() then
			managers.network:session():send_to_host("place_deployable_bag", "ArmorPlatesBase", pos, rot, bits)
		else
			ArmorPlatesBase.spawn(pos, rot, bits, managers.network:session():local_peer():id())
		end

		return true
	end

	function PlayerEquipment:use_first_aid_kit()
		local ray, criminal_to_revive = self:valid_shape_placement("first_aid_kit")

		if ray then
			managers.statistics:use_first_aid()

			if criminal_to_revive and alive_g(criminal_to_revive) then
				PlayerStandard.say_line(self, "f36x_any")

				criminal_to_revive:interaction():interact(self._unit, true)
			else
				local pos = ray.position
				local rot = Rotation(self:_m_deploy_rot():yaw(), 0, 0)

				PlayerStandard.say_line(self, "s12")

				local upgrade_lvl = managers.player:upgrade_level("first_aid_kit", "damage_overshield", 0)
				local auto_recovery = managers.player:upgrade_level("first_aid_kit", "first_aid_kit_auto_recovery", 0)
				local bits = Bitwise:lshift(auto_recovery, FirstAidKitBase.auto_recovery_shift) + Bitwise:lshift(upgrade_lvl, FirstAidKitBase.upgrade_lvl_shift)

				if Network:is_client() then
					managers.network:session():send_to_host("place_deployable_bag", "FirstAidKitBase", pos, rot, bits)
				else
					FirstAidKitBase.spawn(pos, rot, bits, managers.network:session():local_peer():id())
				end
			end

			return true
		end

		return false
	end

	function PlayerEquipment:valid_shape_placement(equipment_id, equipment_data)
		local unit = self._unit
		local mov_ext = unit:movement()

		local from = mov_ext:m_head_pos()
		local head_rot = self:_m_deploy_rot()
		local to = from + head_rot:y() * 220

		local slot_manager = managers.slot
		local slotmask = slot_manager:get_mask("trip_mine_placeables")
		local ray = unit:raycast("ray", from, to, "slot_mask", slotmask, "ray_type", "equipment_placement")
		local valid = ray and true or false
		local revivable_unit = nil
		local dummy_unit = self._dummy_unit

		if ray then
			local dummy_pos = ray.position

			--no equipment_data means this function is being called to actually place the equipment
			if not equipment_data and equipment_id == "first_aid_kit" then
				local closest_rev_dis = managers.player:upgrade_value("first_aid_kit", "auto_revive", 0) --init as max distance

				if closest_rev_dis > 0 then
					local nearby_criminals = world_g:find_units_quick(unit, "sphere" , dummy_pos, closest_rev_dis, slot_manager:get_mask("criminals_no_deployables"))

					for i = 1, #nearby_criminals do
						local criminal = nearby_criminals[i]
						local ext_mov = criminal:movement()

						if ext_mov and ext_mov.downed and ext_mov:downed() then
							local dis = mvec3_dis(dummy_pos, ext_mov:m_pos())

							if dis < closest_rev_dis then
								closest_rev_dis = dis
								revivable_unit = peer_unit
							end
						end
					end
				end
			end

			local rot_mod = rot_mods[equipment_id]
			local dummy_rot = rot_mod and Rotation(head_rot:yaw() + rot_mod, 0, 0) or Rotation(head_rot:yaw(), 0, 0)

			valid = math_dot(ray.normal, math_up) > 0.25

			if valid then
				if alive_g(dummy_unit) then
					dummy_unit:set_position(dummy_pos)
					dummy_unit:set_rotation(dummy_rot)
				else
					dummy_unit = world_g:spawn_unit(idstr_func(equipment_data.dummy_unit), dummy_pos, dummy_rot)

					self:_disable_contour(dummy_unit)
				end

				local find_params = custom_find_params[equipment_id] or {30, 40, 17}
				local find_start_pos = dummy_pos + math_up * find_params[1]
				local find_end_pos = dummy_pos + math_up * find_params[2]
				local find_radius = find_params[3]

				local bodies = dummy_unit:find_bodies("intersect", "capsule", find_start_pos, find_end_pos, find_radius, slotmask + 14 + 25)

				for i = 1, #bodies do
					local body = bodies[i]

					if body:has_ray_type(body_idstr) then
						valid = false

						break
					end
				end
			end
		end

		if alive_g(dummy_unit) then
			dummy_unit:set_visible(valid)
		end

		self._dummy_unit = dummy_unit

		return valid and ray, revivable_unit
	end

	function PlayerEquipment:use_doctor_bag()
		local ray = self:valid_shape_placement("doctor_bag")

		if ray then
			local pos = ray.position
			local rot = self:_m_deploy_rot()
			rot = Rotation(rot:yaw(), 0, 0)

			PlayerStandard.say_line(self, "s02x_plu")

			if managers.blackmarket:equipped_mask().mask_id == tweak_data.achievement.no_we_cant.mask then
				managers.achievment:award_progress(tweak_data.achievement.no_we_cant.stat)
			end

			managers.mission:call_global_event("player_deploy_doctorbag")
			managers.statistics:use_doctor_bag()

			local upgrade_lvl = managers.player:upgrade_level("first_aid_kit", "damage_overshield", 0)
			--local upgrade_lvl = managers.player:upgrade_level("first_aid_kit", "damage_reduction_upgrade")

			local amount_upgrade_lvl = managers.player:upgrade_level("doctor_bag", "aoe_health_regen",0)
			--local amount_upgrade_lvl = managers.player:upgrade_level("doctor_bag", "amount_increase")

			upgrade_lvl = math_clamp(upgrade_lvl, 0, 2)
			amount_upgrade_lvl = math_clamp(amount_upgrade_lvl, 0, 2)
			local bits = Bitwise:lshift(upgrade_lvl, DoctorBagBase.damage_reduce_lvl_shift) + Bitwise:lshift(amount_upgrade_lvl, DoctorBagBase.amount_upgrade_lvl_shift)

			if Network:is_client() then
				managers.network:session():send_to_host("place_deployable_bag", "DoctorBagBase", pos, rot, bits)
			else
				DoctorBagBase.spawn(pos, rot, bits, managers.network:session():local_peer():id())
			end

			return true
		end

		return false
	end
else
	function PlayerEquipment:valid_shape_placement(equipment_id, equipment_data)
		local unit = self._unit
		local mov_ext = unit:movement()

		local from = mov_ext:m_head_pos()
		local head_rot = self:_m_deploy_rot()
		local to = from + head_rot:y() * 220

		local slotmask = managers.slot:get_mask("trip_mine_placeables")
		local ray = unit:raycast("ray", from, to, "slot_mask", slotmask, "ray_type", "equipment_placement")
		local valid = ray and true or false
		local dummy_unit = self._dummy_unit

		if ray then
			local dummy_pos = ray.position
			local rot_mod = rot_mods[equipment_id]
			local dummy_rot = rot_mod and Rotation(head_rot:yaw() + rot_mod, 0, 0) or Rotation(head_rot:yaw(), 0, 0)

			valid = math_dot(ray.normal, math_up) > 0.25

			if valid then
				if alive_g(dummy_unit) then
					dummy_unit:set_position(dummy_pos)
					dummy_unit:set_rotation(dummy_rot)
				else
					dummy_unit = world_g:spawn_unit(idstr_func(equipment_data.dummy_unit), dummy_pos, dummy_rot)

					self:_disable_contour(dummy_unit)
				end

				local find_params = custom_find_params[equipment_id] or {30, 40, 17}
				local find_start_pos = dummy_pos + math_up * find_params[1]
				local find_end_pos = dummy_pos + math_up * find_params[2]
				local find_radius = find_params[3]

				local bodies = dummy_unit:find_bodies("intersect", "capsule", find_start_pos, find_end_pos, find_radius, slotmask + 14 + 25)

				for i = 1, #bodies do
					local body = bodies[i]

					if body:has_ray_type(body_idstr) then
						valid = false

						break
					end
				end
			end
		end

		if alive_g(dummy_unit) then
			dummy_unit:set_visible(valid)
		end

		self._dummy_unit = dummy_unit

		return valid and ray
	end
end

function PlayerEquipment:valid_placement(equipment_data)
	local unit = self._unit
	local mov_ext = unit:movement()

	local valid = not mov_ext:current_state():in_air()
	local dummy_unit = self._dummy_unit

	if valid then
		local equipment_dummy = equipment_data and equipment_data.dummy_unit

		if equipment_dummy then
			local dummy_pos = mov_ext:m_pos()
			local dummy_rot = Rotation(self:_m_deploy_rot():yaw(), 0, 0)

			if alive_g(dummy_unit) then
				dummy_unit:set_position(dummy_pos)
				dummy_unit:set_rotation(dummy_rot)
			else
				dummy_unit = world_g:spawn_unit(idstr_func(equipment_dummy), dummy_pos, dummy_rot)

				self:_disable_contour(dummy_unit)
			end
		end
	end

	if alive_g(dummy_unit) then
		dummy_unit:set_visible(valid)
	end

	self._dummy_unit = dummy_unit

	return valid
end

function PlayerEquipment:use_bodybags_bag()
	local ray = self:valid_shape_placement("bodybags_bag")

	if ray then
		local pos = ray.position
		local rot = Rotation(self:_m_deploy_rot():yaw() + rot_mods.bodybags_bag, 0, 0)

		PlayerStandard.say_line(self, "s13")
		managers.mission:call_global_event("player_deploy_bodybagsbag")
		managers.statistics:use_body_bag()

		local amount_upgrade_lvl = 0

		if Network:is_client() then
			managers.network:session():send_to_host("place_deployable_bag", "BodyBagsBagBase", pos, rot, amount_upgrade_lvl)
		else
			BodyBagsBagBase.spawn(pos, rot, amount_upgrade_lvl, managers.network:session():local_peer():id())
		end

		return true
	end

	return false
end
