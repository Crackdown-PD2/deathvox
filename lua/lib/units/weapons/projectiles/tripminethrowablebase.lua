TripmineThrowableBase = class(ProjectileBase)

local mvec1 = Vector3()
local mvec2 = Vector3()
local mvec3 = Vector3()
local mrot1 = Rotation()

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

function TripmineThrowableBase:init(unit,...)
	
	TripmineThrowableBase.super.init(self,unit,...)
	--self._draw_debug_trail = true
	self._orient_to_vel = false
	
	--asdf = self
end

function TripmineThrowableBase:_setup_server_data()
	self._slot_mask = managers.slot:get_mask("trip_mine_targets") + managers.slot:get_mask("enemies")
end

function TripmineThrowableBase:throw(params,...)
	TripmineThrowableBase.super.throw(self,params,...)
	--Print(params.projectile_entry)

	if params.projectile_entry and tweak_data.projectiles[params.projectile_entry] then
		local push_at_body_index = tweak_data.projectiles[params.projectile_entry].push_at_body_index
		local body = self._unit:body(push_at_body_index)
		if body then
			self._rotatey_body = body
		end
	end
end

function TripmineThrowableBase:_on_collision(col_ray)
	-- hit enemy
	
	local body = col_ray.body
	local position = col_ray.position
	local stuck_enemy = col_ray.unit
	local normal = col_ray.normal
	
	-- spawn tripmine at this normal 
	
	local radius_upgrade_level = managers.player:upgrade_level("trip_mine", "stuck_enemy_panic_radius", 0)
	local vulnerability_upgrade_level = managers.player:upgrade_level("trip_mine", "stuck_dozer_damage_vulnerability", 0)
	local bits = Bitwise:lshift(radius_upgrade_level, TripMineBase.radius_upgrade_shift) + Bitwise:lshift(vulnerability_upgrade_level, TripMineBase.vulnerability_upgrade_shift) + 1
	
	local parent_obj = body:root_object()
	
	local global_pos, local_pos, local_rot_vec = tmp_vec1
	mvec3_set(global_pos, position)
	
	PlayerEquipment._check_unit_attach_segment(stuck_enemy, global_pos)
	
	local session = managers.network:session()

	local player_unit = managers.player:local_player()
		
	if Network:is_client() then
		-- stuck as client
		

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

		session:send_to_host("sync_attach_projectile", stuck_enemy, false, stuck_enemy, body or nil, parent_obj or nil, local_pos or global_pos, local_rot_vec or normal, bits, session:local_peer():id())
	else
		-- stuck as host
		
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
		local tripmine_unit = TripMineBase.spawn(global_pos, global_rot, false, peer_id)
		tripmine_unit:base():set_active(true, player_unit, true)

		tripmine_unit:base():attach_to_enemy(stuck_enemy, local_pos, local_rot_vec, parent_obj, radius_upgrade_level, vulnerability_upgrade_level)

		session:send_to_peers_synched("sync_attach_projectile", tripmine_unit, false, stuck_enemy, body or nil, parent_obj or nil, local_pos or global_pos, local_rot_vec or normal, bits, peer_id)
	end
	
	self._unit:set_slot(0)
	self._is_detonated = true
end

function TripmineThrowableBase:clbk_impact(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	--TripmineThrowableBase.super.clbk_impact(self, tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)

	if tag == Idstring("impact2") and not self._is_detonated then
		-- stuck to world
		
		self._unit:set_slot(0)
		self._is_detonated = true
		

		local session = managers.network:session()

		local player_unit = managers.player:local_player()
		
		
		local mark_duration_upgrade = managers.player:has_category_upgrade("trip_mine", "trip_mine_extended_mark_duration")
		if Network:is_client() then
			session:send_to_host("place_trip_mine", position, normal, mark_duration_upgrade)
		else	
			local rot = tmp_rot1
			mrot_set_look_at(rot, normal, math_up)

			local tripmine_unit = TripMineBase.spawn(position, rot, mark_duration_upgrade, session:local_peer():id())
			tripmine_unit:base():set_active(true, player_unit)
			
		end
		
		return
	end
	
	if self._sweep_data and not self._collided then
		mvector3.set(mvec2, position)
		mvector3.subtract(mvec2, self._sweep_data.last_pos)
		mvector3.multiply(mvec2, 2)
		mvector3.add(mvec2, self._sweep_data.last_pos)

		local ig_units = self._ignore_units
		local col_ray = World:raycast("ray", self._sweep_data.last_pos, mvec2, "slot_mask", self._sweep_data.slot_mask, ig_units and "ignore_unit" or nil, ig_units or nil)

		if col_ray and col_ray.unit then
			if self._draw_debug_impact then
				Draw:brush(Color(0.5, 0, 0, 1), nil, 10):sphere(col_ray.position, 4)
				Draw:brush(Color(0.5, 1, 0, 0), nil, 10):sphere(self._unit:position(), 3)
			end

			mvector3.direction(mvec1, self._sweep_data.last_pos, col_ray.position)
			mvector3.add(mvec1, col_ray.position)
			self._unit:set_position(mvec1)
			self._unit:set_position(mvec1)

			col_ray.velocity = velocity
			self._collided = true

			self:_on_collision(col_ray)
		end
	end
end

function TripmineThrowableBase:update(unit, t, dt)
	if not self._simulated and not self._collided then
		self._unit:m_position(mvec1)
		mvector3.set(mvec2, self._velocity * dt)
		mvector3.add(mvec1, mvec2)
		self._unit:set_position(mvec1)

		if self._orient_to_vel then
			mrotation.set_look_at(mrot1, mvec2, math.UP)
			self._unit:set_rotation(mrot1)
		end

		self._velocity = Vector3(self._velocity.x, self._velocity.y, self._velocity.z - 980 * dt)
	end
	
	if self._rotatey_body then
		local _body = self._rotatey_body
		local rotation = _body:rotation()
		local yaw = rotation:yaw()
		local pitch = rotation:pitch() - (dt * 360)
		local roll = rotation:roll()
		_body:set_rotation(Rotation(yaw,pitch,roll + (dt * 30)))
	end

	if self._sweep_data and not self._collided then
		self._unit:m_position(self._sweep_data.current_pos)

		local raycast_params = {
			"ray",
			self._sweep_data.last_pos,
			self._sweep_data.current_pos,
			"slot_mask",
			self._sweep_data.slot_mask
		}

		if self._ignore_units then
			table.list_append(raycast_params, {
				"ignore_unit",
				self._ignore_units
			})
		end

		if self._sphere_cast_radius then
			table.list_append(raycast_params, {
				"sphere_cast_radius",
				self._sphere_cast_radius,
				"bundle",
				4
			})
		end

		local col_ray = World:raycast(unpack(raycast_params))

		if self._draw_debug_trail then
			if self._sphere_cast_radius then
				Draw:brush(Color(0.25, 0, 0, 1), nil, 3):cylinder(self._sweep_data.last_pos, self._sweep_data.current_pos, self._sphere_cast_radius, 4)
			else
				Draw:brush(Color(0.25, 0, 0, 1), nil, 3):line(self._sweep_data.last_pos, self._sweep_data.current_pos)
			end
		end

		if col_ray and col_ray.unit then
			mvector3.direction(mvec1, self._sweep_data.last_pos, self._sweep_data.current_pos)
			mvector3.add(mvec1, col_ray.position)
			self._unit:set_position(mvec1)
			self._unit:set_position(mvec1)

			if self._draw_debug_impact then
				Draw:brush(Color(0.5, 0, 0, 1), nil, 10):sphere(col_ray.position, 4)
				Draw:brush(Color(0.5, 1, 0, 0), nil, 10):sphere(self._unit:position(), 3)
			end

			col_ray.velocity = self._unit:velocity()
			self._collided = true

			self:_on_collision(col_ray)
		end

		self._unit:m_position(self._sweep_data.last_pos)
	end

	if self._warning_fx_vfx_data then
		self:_warning_fx_vfx_upd(unit, t, dt, self._warning_fx_vfx_data)
	end
end
