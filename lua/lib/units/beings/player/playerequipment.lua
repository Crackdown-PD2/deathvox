local mvec3_dis = mvector3.distance
local mvec3_set = mvector3.set
local mvec3_set_stat = mvector3.set_static
local mvec3_add = mvector3.add
local mvec3_dot = mvector3.dot
local mvec3_sub = mvector3.subtract
local mvec3_mul = mvector3.multiply
local mvec3_dir = mvector3.direction
local mvec3_rot = mvector3.rotate_with
local mvec3_cpy = mvector3.copy
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_vec3 = Vector3()
local tmp_vec4 = Vector3()
local tmp_seg_vec1 = Vector3()
local tmp_seg_vec2 = Vector3()
local tmp_seg_vec3 = Vector3()
local tmp_seg_vec4 = Vector3()
local tmp_seg_vec5 = Vector3()
local tmp_seg_vec6 = Vector3()

local mrot_y = mrotation.y
local mrot_yaw = mrotation.yaw
local mrot_pitch = mrotation.pitch
local mrot_roll = mrotation.roll
local mrot_mul = mrotation.multiply
local mrot_inv = mrotation.invert
local mrot_set = mrotation.set_yaw_pitch_roll
local mrot_set_look_at = mrotation.set_look_at
local tmp_rot1 = Rotation()
local tmp_rot2 = Rotation()

local math_up = math.UP
local math_dot = math.dot
local math_clamp = math.clamp

local alive_g = alive
local world_g = World

local idstr_func = Idstring
local body_idstr = idstr_func("body")

local rot_yaw_mods = {
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
	function PlayerEquipment:valid_target_enemy_placement(equipment_id,equipment_data,skip_preview)
		local unit = self._unit
		local mov_ext = unit:movement()
		local rot = self:_m_deploy_rot()
		local from = mov_ext:m_head_pos()
		local to = tmp_vec1
		
		mrot_y(rot,to)
		mvec3_mul(to,equipment_data.deploy_distance or 220)
		mvec3_add(to, from)
		
		local slotmask = 22
		
		local ray = unit:raycast("ray",from,to,"slot_mask",slotmask)
		
		if ray and ray.unit then 
			local target_unit = ray.unit
			local is_enemy = managers.enemy:is_enemy(target_unit)
			if is_enemy then
				if not managers.groupai:state():is_enemy_converted_to_criminal(target_unit) then 
					if not skip_preview then 
						local head_pos = target_unit:movement():m_head_pos()
						local radius = 10
						Draw:brush(Color(0,1,1):with_alpha(0.66)):sphere(head_pos,radius)
					end
					return true,target_unit
				end
			end
		end
		
	end
	
	function PlayerEquipment:use_friendship_collar()
		local valid,target_unit = self:valid_target_enemy_placement("sentry_gun_silent",tweak_data.equipments.sentry_gun_silent,true)
		if valid and alive(target_unit) then 
			if Network:is_server() then
				local success = managers.groupai:state():convert_hostage_to_criminal(target_unit)
				--if host/offline, return bool success to deduct the required equipment amount
				return success
			else
				--in all other cases, we must wait for the server's response before assuming consuming the equipment
				
				managers.network:session():send_to_host("sync_interacted", target_unit, target_unit:id(), "hostage_convert", 1)
				
				--mark the unit as pending conversion with a local listener;
				--if the unit is converted within n seconds of the request, the callback is run locally and the equipment is consumed
				--Note: the instigating player is not verified by clients, so in cases of extreme latency, this may result in anti-duping deployable equipment
				--(ie. if two players attempt to convert the same enemy: if the conversion is successful, both players' friendship collars are consumed)
				--the underlying netcode should be changed to something more like the sentrygun system in the future, to avoid this issue
				local ext_huskbrain = target_unit:brain()
				if ext_huskbrain and ext_huskbrain.set_on_converted_callback then 
					local pm = managers.player
					local equipment = pm._equipment.selections[pm._equipment.selected_index]
					local cb = function(_ext_huskbrain)
						managers.player:remove_equipment(equipment.equipment,nil)
					end
					ext_huskbrain:set_on_converted_callback(cb,2)
				end
				return false
			end
		end
		return false
	end

	function PlayerEquipment:_check_unit_attach_segment(hit_unit, m_global_pos)
		local damage_ext = hit_unit:character_damage()

		if not damage_ext or not damage_ext.get_impact_segment then
			return
		end

		local parent_obj, child_obj = damage_ext:get_impact_segment(m_global_pos)

		if not parent_obj or not child_obj then
			return
		end

		local parent_pos, child_pos, parent_col_vec, seg_dir, proj_pos, dir_from_seg = tmp_seg_vec1, tmp_seg_vec2, tmp_seg_vec3, tmp_seg_vec4, tmp_seg_vec5, tmp_seg_vec6

		parent_obj:m_position(parent_pos)
		child_obj:m_position(child_pos)

		mvec3_set(parent_col_vec, m_global_pos)
		mvec3_sub(parent_col_vec, parent_pos)

		local segment_len = mvec3_dir(seg_dir, parent_pos, child_pos)
		local proj_len = mvec3_dot(parent_col_vec, seg_dir)
		proj_len = math_clamp(proj_len, 0, segment_len)

		mvec3_set(proj_pos, seg_dir)
		mvec3_mul(proj_pos, proj_len)
		mvec3_add(proj_pos, parent_pos)

		local max_dis_from_seg = 10
		local dis_from_seg = mvec3_dir(dir_from_seg, proj_pos, m_global_pos)

		if max_dis_from_seg < dis_from_seg then
			mvec3_set(m_global_pos, dir_from_seg)
			mvec3_mul(m_global_pos, max_dis_from_seg)
			mvec3_add(m_global_pos, proj_pos)
		end

		return true
	end

	function PlayerEquipment:valid_look_at_placement(equipment_data, can_place_on_enemies)
		local unit = self._unit
		local mov_ext = unit:movement()
		local from = mov_ext:m_head_pos()
		local to, ray, stuck_enemy = tmp_vec1

		mrot_y(self:_m_deploy_rot(), to)
		mvec3_mul(to, 220)
		mvec3_add(to, from)

		if can_place_on_enemies then
			local raycast_f = unit.raycast
			local slot_manager = managers.slot

			ray = raycast_f(unit, "ray", from, to, "slot_mask", slot_manager:get_mask("enemies"))

			local ray_pos = ray and ray.position

			if ray_pos and not raycast_f(unit, "ray", from, ray_pos, "slot_mask", slot_manager:get_mask("enemy_shield_check"), "report") then
				local obstructed_ray = raycast_f(unit, "ray", from, ray_pos, "slot_mask", slot_manager:get_mask("trip_mine_placeables"), "ray_type", "equipment_placement")

				if obstructed_ray then
					ray = obstructed_ray
				else
					stuck_enemy = ray.unit
				end
			else
				ray = raycast_f(unit, "ray", from, to, "slot_mask", slot_manager:get_mask("trip_mine_placeables"), "ray_type", "equipment_placement")
			end
		else
			ray = unit:raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ray_type", "equipment_placement")
		end

		local dummy_unit = self._dummy_unit

		if ray then
			local equipment_dummy = equipment_data and equipment_data.dummy_unit

			if equipment_dummy then
				local dummy_pos = tmp_vec2
				mvec3_set(dummy_pos, ray.position)

				if stuck_enemy then
					self:_check_unit_attach_segment(stuck_enemy, dummy_pos)
				end

				local dummy_rot = tmp_rot1
				mrot_set_look_at(dummy_rot, ray.normal, math_up)

				if alive_g(dummy_unit) then
					dummy_unit:set_position(dummy_pos)
					dummy_unit:set_rotation(dummy_rot)
				else
					dummy_unit = world_g:spawn_unit(idstr_func(equipment_dummy), dummy_pos, dummy_rot)
					self._dummy_unit = dummy_unit

					self:_disable_contour(dummy_unit)
				end
			end
		end

		if alive_g(dummy_unit) then
			local state = ray and true or false

			dummy_unit:set_enabled(state)
		end

		return ray, stuck_enemy
	end

	--also changed signature: allow passing the arguments from the raycast check 
	function PlayerEquipment:use_trip_mine(ray,stuck_enemy)
		if ray == nil and stuck_enemy == nil then
			ray, stuck_enemy = self:valid_look_at_placement(nil, managers.player:has_category_upgrade("trip_mine", "can_place_on_enemies"))
		end

		if ray then
			managers.statistics:use_trip_mine()

			local session = managers.network:session()

			if Network:is_client() then
				if stuck_enemy then
					local body = ray.body
					local normal = ray.normal
					local parent_obj = body:root_object()
					local global_pos, local_pos, local_rot_vec = tmp_vec1
					mvec3_set(global_pos, ray.position)

					self:_check_unit_attach_segment(stuck_enemy, global_pos)

					if parent_obj then
						local_pos, local_rot_vec = tmp_vec2, tmp_vec3
						local parent_pos, inv_parent_rot = tmp_vec4, tmp_rot1

						parent_obj:m_position(parent_pos)
						parent_obj:m_rotation(inv_parent_rot)
						mrot_inv(inv_parent_rot)

						mvec3_set(local_pos, global_pos)
						mvec3_sub(local_pos, parent_pos)
						mvec3_rot(local_pos, inv_parent_rot)

						local normal_rot = tmp_rot2
						mrot_set_look_at(normal_rot, normal, math_up)
						mrot_mul(inv_parent_rot, normal_rot)
						mvec3_set_stat(local_rot_vec, mrot_yaw(inv_parent_rot), mrot_pitch(inv_parent_rot), mrot_roll(inv_parent_rot))

						local_pos = mvec3_cpy(local_pos)
						local_rot_vec = mvec3_cpy(local_rot_vec)
					end

					local radius_upgrade_level = managers.player:upgrade_level("trip_mine", "stuck_enemy_panic_radius", 0)
					local vulnerability_upgrade_level = managers.player:upgrade_level("trip_mine", "stuck_dozer_damage_vulnerability", 0)
					local bits = Bitwise:lshift(radius_upgrade_level, TripMineBase.radius_upgrade_shift) + Bitwise:lshift(vulnerability_upgrade_level, TripMineBase.vulnerability_upgrade_shift) + 1

					session:send_to_host("sync_attach_projectile", stuck_enemy, false, stuck_enemy, body or nil, parent_obj or nil, local_pos or global_pos, local_rot_vec or normal, bits, session:local_peer():id())
				else
					local mark_duration_upgrade = managers.player:has_category_upgrade("trip_mine", "trip_mine_extended_mark_duration")

					session:send_to_host("place_trip_mine", ray.position, ray.normal, mark_duration_upgrade)
				end
			elseif stuck_enemy then
				local body = ray.body
				local normal = ray.normal
				local parent_obj = body:root_object()
				local global_pos, local_pos, local_rot_vec = tmp_vec1
				mvec3_set(global_pos, ray.position)

				self:_check_unit_attach_segment(stuck_enemy, global_pos)

				local global_rot = tmp_rot1
				mrot_set_look_at(global_rot, normal, math_up)

				if parent_obj then
					local_pos, local_rot_vec = tmp_vec2, tmp_vec3
					local parent_pos, inv_parent_rot = tmp_vec4, tmp_rot2

					parent_obj:m_position(parent_pos)
					parent_obj:m_rotation(inv_parent_rot)
					mrot_inv(inv_parent_rot)

					mvec3_set(local_pos, global_pos)
					mvec3_sub(local_pos, parent_pos)
					mvec3_rot(local_pos, inv_parent_rot)

					mrot_mul(inv_parent_rot, global_rot)
					mvec3_set_stat(local_rot_vec, mrot_yaw(inv_parent_rot), mrot_pitch(inv_parent_rot), mrot_roll(inv_parent_rot))

					local_pos = mvec3_cpy(local_pos)
					local_rot_vec = mvec3_cpy(local_rot_vec)
				end

				local peer_id = session:local_peer():id()
				local unit = TripMineBase.spawn(global_pos, global_rot, false, peer_id)
				unit:base():set_active(true, self._unit, true)

				local radius_upgrade_level = managers.player:upgrade_level("trip_mine", "stuck_enemy_panic_radius", 0)
				local vulnerability_upgrade_level = managers.player:upgrade_level("trip_mine", "stuck_dozer_damage_vulnerability", 0)
				local bits = Bitwise:lshift(radius_upgrade_level, TripMineBase.radius_upgrade_shift) + Bitwise:lshift(vulnerability_upgrade_level, TripMineBase.vulnerability_upgrade_shift) + 1

				unit:base():attach_to_enemy(stuck_enemy, local_pos, local_rot_vec, parent_obj, radius_upgrade_level, vulnerability_upgrade_level)

				session:send_to_peers_synched("sync_attach_projectile", unit, false, stuck_enemy, body or nil, parent_obj or nil, local_pos or global_pos, local_rot_vec or normal, bits, peer_id)
			else
				local mark_duration_upgrade = managers.player:has_category_upgrade("trip_mine", "trip_mine_extended_mark_duration")
				local rot = tmp_rot1
				mrot_set_look_at(rot, ray.normal, math_up)

				local unit = TripMineBase.spawn(ray.position, rot, mark_duration_upgrade, session:local_peer():id())
				unit:base():set_active(true, self._unit)
			end

			return true
		end

		return false
	end

	function PlayerEquipment:use_armor_plates()
		local ray = self:valid_shape_placement("armor_kit")--, {dummy_unit = tweak_data.equipments.armor_kit.dummy_unit})
		local pos = ray.position
		local rot = tmp_rot1
		mrot_set(rot, mrot_yaw(self:_m_deploy_rot()), 0, 0)

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
				local rot = tmp_rot1
				mrot_set(rot, mrot_yaw(self:_m_deploy_rot()), 0, 0)

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
		local rot = self:_m_deploy_rot()
		local from = mov_ext:m_head_pos()
		local to, ray, stuck_enemy = tmp_vec1

		mrot_y(rot, to)
		mvec3_mul(to, 220)
		mvec3_add(to, from)

		local slot_manager = managers.slot
		local slotmask = slot_manager:get_mask("trip_mine_placeables")
		local ray = unit:raycast("ray", from, to, "slot_mask", slotmask, "ray_type", "equipment_placement")
		local valid = ray and true or false
		local dummy_unit = self._dummy_unit
		local revivable_unit = nil

		if ray then
			valid = math_dot(ray.normal, math_up) > 0.25

			if valid then
				local dummy_pos = ray.position
				local dummy_rot = tmp_rot1
				local yaw_mod = rot_yaw_mods[equipment_id]
				local yaw = yaw_mod and mrot_yaw(rot) + yaw_mod or mrot_yaw(rot)
				mrot_set(dummy_rot, yaw, 0, 0)

				if alive_g(dummy_unit) then
					dummy_unit:set_position(dummy_pos)
					dummy_unit:set_rotation(dummy_rot)
				else
					dummy_unit = world_g:spawn_unit(idstr_func(equipment_data.dummy_unit), dummy_pos, dummy_rot)
					self._dummy_unit = dummy_unit

					self:_disable_contour(dummy_unit)
				end

				local find_params = custom_find_params[equipment_id] or {30, 40, 17}
				local find_start_pos, find_end_pos = tmp_vec2, tmp_vec3
				local find_radius = find_params[3]

				mvec3_set(find_start_pos, math_up)
				mvec3_mul(find_start_pos, find_params[1])
				mvec3_add(find_start_pos, dummy_pos)
				mvec3_set(find_end_pos, math_up)
				mvec3_mul(find_end_pos, find_params[2])
				mvec3_add(find_end_pos, dummy_pos)

				local bodies = dummy_unit:find_bodies("intersect", "capsule", find_start_pos, find_end_pos, find_radius, slotmask + 14 + 25)

				for i = 1, #bodies do
					local body = bodies[i]

					if body:has_ray_type(body_idstr) then
						valid = false

						break
					end
				end

				if valid then
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
										revivable_unit = criminal
									end
								end
							end
						end
					end
				end
			end
		end

		if alive_g(dummy_unit) then
			dummy_unit:set_enabled(valid)
		end

		return valid and ray, revivable_unit
	end

	function PlayerEquipment:use_doctor_bag()
		local ray = self:valid_shape_placement("doctor_bag")

		if ray then
			local pos = ray.position
			local rot = tmp_rot1
			mrot_set(rot, mrot_yaw(self:_m_deploy_rot()), 0, 0)

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

	function PlayerEquipment:throw_projectile()
--		Log("Threw projectile")
		do return end
		
		
		local projectile_entry = managers.blackmarket:equipped_projectile()
		local projectile_data = tweak_data.blackmarket.projectiles[projectile_entry]
		local from = self._unit:movement():m_head_pos()
		local pos = from + self._unit:movement():m_head_rot():y() * 30 + Vector3(0, 0, 0)
		local dir = self._unit:movement():m_head_rot():y()
		local say_line = projectile_data.throw_shout or "g43"

		if say_line and say_line ~= true then
			self._unit:sound():play(say_line, nil, true)
		end

		local projectile_index = tweak_data.blackmarket:get_index_from_projectile_id(projectile_entry)

		if not projectile_data.client_authoritative then
			if Network:is_client() then
				managers.network:session():send_to_host("request_throw_projectile", projectile_index, pos, dir)
			else
				ProjectileBase.throw_projectile(projectile_entry, pos, dir, managers.network:session():local_peer():id())
				managers.player:verify_grenade(managers.network:session():local_peer():id())
			end
		else
			ProjectileBase.throw_projectile(projectile_entry, pos, dir, managers.network:session():local_peer():id())
			managers.player:verify_grenade(managers.network:session():local_peer():id())
		end

		managers.player:on_throw_grenade()
	end
else
	function PlayerEquipment:valid_shape_placement(equipment_id, equipment_data)
		local unit = self._unit
		local mov_ext = unit:movement()
		local rot = self:_m_deploy_rot()
		local from = mov_ext:m_head_pos()
		local to, ray, stuck_enemy = tmp_vec1

		mrot_y(rot, to)
		mvec3_mul(to, 220)
		mvec3_add(to, from)

		local slotmask = managers.slot:get_mask("trip_mine_placeables")
		local ray = unit:raycast("ray", from, to, "slot_mask", slotmask, "ray_type", "equipment_placement")
		local valid = ray and true or false
		local dummy_unit = self._dummy_unit

		if ray then
			valid = math_dot(ray.normal, math_up) > 0.25

			if valid then
				local dummy_pos = ray.position
				local dummy_rot = tmp_rot1
				local yaw_mod = rot_yaw_mods[equipment_id]
				local yaw = yaw_mod and mrot_yaw(rot) + yaw_mod or mrot_yaw(rot)
				mrot_set(dummy_rot, yaw, 0, 0)

				if alive_g(dummy_unit) then
					dummy_unit:set_position(dummy_pos)
					dummy_unit:set_rotation(dummy_rot)
				else
					dummy_unit = world_g:spawn_unit(idstr_func(equipment_data.dummy_unit), dummy_pos, dummy_rot)
					self._dummy_unit = dummy_unit

					self:_disable_contour(dummy_unit)
				end

				local find_params = custom_find_params[equipment_id] or {30, 40, 17}
				local find_start_pos, find_end_pos = tmp_vec2, tmp_vec3
				local find_radius = find_params[3]

				mvec3_set(find_start_pos, math_up)
				mvec3_mul(find_start_pos, find_params[1])
				mvec3_add(find_start_pos, dummy_pos)
				mvec3_set(find_end_pos, math_up)
				mvec3_mul(find_end_pos, find_params[2])
				mvec3_add(find_end_pos, dummy_pos)

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
			dummy_unit:set_enabled(valid)
		end

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
			local dummy_rot = tmp_rot1
			mrot_set(dummy_rot, mrot_yaw(self:_m_deploy_rot()), 0, 0)

			if alive_g(dummy_unit) then
				dummy_unit:set_position(dummy_pos)
				dummy_unit:set_rotation(dummy_rot)
			else
				dummy_unit = world_g:spawn_unit(idstr_func(equipment_dummy), dummy_pos, dummy_rot)
				self._dummy_unit = dummy_unit

				self:_disable_contour(dummy_unit)
			end
		end
	end

	if alive_g(dummy_unit) then
		dummy_unit:set_enabled(valid)
	end

	return valid
end

function PlayerEquipment:use_bodybags_bag()
	local ray = self:valid_shape_placement("bodybags_bag")

	if ray then
		local pos = ray.position
		local rot = tmp_rot1
		mrot_set(rot, mrot_yaw(self:_m_deploy_rot()) + rot_yaw_mods.bodybags_bag, 0, 0)

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
