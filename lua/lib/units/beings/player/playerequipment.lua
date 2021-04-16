local mvec3_dis = mvector3.distance
local mvec3_cpy = mvector3.copy
local mvec3_rotate = mvector3.rotate_with
local mvec3_dir = mvector3.direction
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()

local mrot_lookat = mrotation.set_look_at

local math_up = math.UP
local math_dot = math.dot
local math_clamp = math.clamp

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
		local ray, stuck_enemy = self:valid_look_at_placement(nil, true)

		if ray then
			managers.statistics:use_trip_mine()

			local session = managers.network:session()

			if Network:is_client() then
				if stuck_enemy then
					local parent_obj, child_obj, local_pos = nil
					local global_pos = ray.position
					local damage_ext = stuck_enemy:character_damage()

					if damage_ext and damage_ext.get_impact_segment then
						parent_obj, child_obj = damage_ext:get_impact_segment(global_pos)

						if parent_obj and child_obj then
							local parent_pos = parent_obj:position()
							local child_pos = child_obj:position()
							local segment_dir = tmp_vec1
							local segment_dist = mvec3_dir(segment_dir, parent_pos, child_pos)
							local collision_to_parent = global_pos - parent_pos

							local projected_dist = collision_to_parent:dot(segment_dir)
							projected_dist = math_clamp(projected_dist, 0, segment_dist)
							local projected_pos = parent_pos + projected_dist * segment_dir
							local max_dist_from_segment = 10
							local dir_from_segment = tmp_vec2
							local dist_from_segment = mvec3_dir(dir_from_segment, projected_pos, global_pos)

							if max_dist_from_segment < dist_from_segment then
								global_pos = projected_pos + max_dist_from_segment * dir_from_segment
							end

							local_pos = global_pos - parent_pos
							local_pos = local_pos:rotate_with(parent_obj:rotation():inverse())
						end
					end

					parent_obj = parent_obj or ray.body:root_object()

					local radius_upgrade_level = managers.player:upgrade_level("trip_mine", "stuck_enemy_panic_radius", 0)
					local vulnerability_upgrade_level = managers.player:upgrade_level("trip_mine", "stuck_dozer_damage_vulnerability", 0)
					local bits = Bitwise:lshift(radius_upgrade_level, TripMineBase.radius_upgrade_shift) + Bitwise:lshift(vulnerability_upgrade_level, TripMineBase.vulnerability_upgrade_shift) + 1

					session:send_to_host("sync_attach_projectile", stuck_enemy, false, stuck_enemy, nil, parent_obj, local_pos or global_pos, ray.normal, bits, session:local_peer():id())
				else
					local mark_duration_upgrade = managers.player:has_category_upgrade("trip_mine", "trip_mine_extended_mark_duration")

					session:send_to_host("place_trip_mine", ray.position, ray.normal, mark_duration_upgrade)
				end
			elseif stuck_enemy then
				local parent_obj, child_obj, local_pos = nil
				local global_pos = ray.position
				local damage_ext = stuck_enemy:character_damage()

				if damage_ext and damage_ext.get_impact_segment then
					parent_obj, child_obj = damage_ext:get_impact_segment(global_pos)

					if parent_obj and child_obj then
						local parent_pos = parent_obj:position()
						local child_pos = child_obj:position()
						local segment_dir = tmp_vec1
						local segment_dist = mvec3_dir(segment_dir, parent_pos, child_pos)
						local collision_to_parent = global_pos - parent_pos

						local projected_dist = collision_to_parent:dot(segment_dir)
						projected_dist = math_clamp(projected_dist, 0, segment_dist)
						local projected_pos = parent_pos + projected_dist * segment_dir
						local max_dist_from_segment = 10
						local dir_from_segment = tmp_vec2
						local dist_from_segment = mvec3_dir(dir_from_segment, projected_pos, global_pos)

						if max_dist_from_segment < dist_from_segment then
							global_pos = projected_pos + max_dist_from_segment * dir_from_segment
						end

						local_pos = global_pos - parent_pos
						local_pos = local_pos:rotate_with(parent_obj:rotation():inverse())
					end
				end

				parent_obj = parent_obj or ray.body:root_object()

				local rot = Rotation()
				mrot_lookat(rot, ray.normal, math_up)

				local unit = TripMineBase.spawn(global_pos, rot, false, session:local_peer():id())
				local player_unit = self._unit
				unit:base():set_active(true, player_unit, true)

				local radius_upgrade_level = managers.player:upgrade_level("trip_mine", "stuck_enemy_panic_radius", 0)
				local vulnerability_upgrade_level = managers.player:upgrade_level("trip_mine", "stuck_dozer_damage_vulnerability", 0)
				local bits = Bitwise:lshift(radius_upgrade_level, TripMineBase.radius_upgrade_shift) + Bitwise:lshift(vulnerability_upgrade_level, TripMineBase.vulnerability_upgrade_shift) + 1

				unit:base():attach_to_enemy(stuck_enemy, unit:position(), unit:rotation(), parent_obj, radius_upgrade_level, vulnerability_upgrade_level)

				session:send_to_peers_synched("sync_attach_projectile", unit, false, stuck_enemy, nil, parent_obj, local_pos or global_pos, ray.normal, bits, session:local_peer():id())
			else
				local mark_duration_upgrade = managers.player:has_category_upgrade("trip_mine", "trip_mine_extended_mark_duration")
				local rot = Rotation()
				mrot_lookat(rot, ray.normal, math_up)

				local unit = TripMineBase.spawn(ray.position, rot, mark_duration_upgrade, session:local_peer():id())
				local player_unit = self._unit
				unit:base():set_active(true, player_unit)
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
