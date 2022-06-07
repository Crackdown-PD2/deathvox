local mvec1 = Vector3()
local mvec2 = Vector3()
local ids_pickup = Idstring("pickup")

local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()

local tmp_vel = Vector3()

local world_g = World

local mvec3_dir = mvector3.direction
local mvec3_dot = mvector3.dot
local mvec3_dis = mvector3.distance
local mvec3_angle = mvector3.angle
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_step = mvector3.step
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_norm = mvector3.normalize

local math_lerp = math.lerp

local anti_gravitate_idstr = Idstring("physic_effects/anti_gravitate")

function ArrowBase:set_weapon_unit(weapon_unit)
	ArrowBase.super.set_weapon_unit(self, weapon_unit)

	self._weapon_damage_mult = weapon_unit and weapon_unit:base().projectile_damage_multiplier and weapon_unit:base():projectile_damage_multiplier() or 1
	self._weapon_charge_value = weapon_unit and weapon_unit:base().projectile_charge_value and weapon_unit:base():projectile_charge_value() or 1
	self._weapon_speed_mult = weapon_unit and weapon_unit:base().projectile_speed_multiplier and weapon_unit:base():projectile_speed_multiplier() or 1
	
	local homing_skill = weapon_unit and weapon_unit:base()._homing_arrows
	
	if homing_skill then
		if self._weapon_speed_mult > 0.6 then
			self._homing = world_g:play_physic_effect(anti_gravitate_idstr, self._unit)
		end
	end
	
	self._weapon_charge_fail = weapon_unit and weapon_unit:base():charge_fail() or false

	if not self._weapon_charge_fail then
		self:add_trail_effect()
	end
end

function ArrowBase:_calculate_autohit_direction()
	local enemies = managers.enemy:all_enemies()
	local m_unit = self._unit
	local pos = m_unit:position()
	local dir = m_unit:rotation():y()
	local closest_ang, closest_pos = nil
	local max_angle = self._homing and 60 or 30
	
	local obstruction_mask = managers.slot:get_mask("world_geometry", "vehicles", "enemy_shield_check")

	for u_key, enemy_data in pairs(enemies) do
		local enemy = enemy_data.unit
		
		if not enemy:in_slot(16) then
			local com = enemy:movement():m_head_pos()
			mvec3_dir(tmp_vec1, pos, com)
			mvec3_set_z(tmp_vec1, 0)

			local angle = mvec3_angle(dir, tmp_vec1)
			
			if angle < max_angle then
				local obstructed = m_unit:raycast("ray", pos, com, "slot_mask", obstruction_mask, "report")
				
				if not obstructed then
					if not closest_ang or angle < closest_ang then
						closest_ang = angle
						closest_pos = com
					end
				end
			end
		end
	end

	if closest_pos then
		mvector3.direction(tmp_vec1, pos, closest_pos)

		return tmp_vec1
	end
end

function ArrowBase:update(unit, t, dt)
	if self._drop_in_sync_data then
		self._drop_in_sync_data.f = self._drop_in_sync_data.f - 1

		if self._drop_in_sync_data.f < 0 then
			local parent_unit = self._drop_in_sync_data.parent_unit

			if alive(parent_unit) then
				local state = self._drop_in_sync_data.state
				local parent_body = parent_unit:body(state.sync_attach_data.parent_body_index)
				local parent_obj = parent_body:root_object()

				self:sync_attach_to_unit(false, parent_unit, parent_body, parent_obj, state.sync_attach_data.local_pos, state.sync_attach_data.dir, true)
			end

			self._drop_in_sync_data = nil
		end
	end

	if not self._is_pickup then
		if self._homing then
			if not self._homing_physics_t then
				self._homing_physics_t = t + 1
			end
		
			local autohit_dir = self:_calculate_autohit_direction()

			if autohit_dir then
				local body = self._unit:body(0)

				mvec3_set(tmp_vel, body:velocity())

				local speed = mvector3.normalize(tmp_vel)

				mvec3_step(tmp_vel, tmp_vel, autohit_dir, dt * 2)
				
				local rot = Rotation(tmp_vel, math.UP)
				
				body:set_rotation(rot)
				
				body:set_velocity(tmp_vel * speed)
			elseif self._homing_physics_t < t then
				world_g:stop_physic_effect(self._homing)
				self._homing = nil
			end
		else
			local autohit_dir = self:_calculate_autohit_direction()

			if autohit_dir then
				local body = self._unit:body(0)

				mvec3_set(tmp_vel, body:velocity())

				local speed = mvector3.normalize(tmp_vel)

				mvec3_step(tmp_vel, tmp_vel, autohit_dir, dt * 0.3)
				
				local rot = Rotation(tmp_vel, math.UP)
				
				body:set_rotation(rot)
				
				body:set_velocity(tmp_vel * speed)
			end
		end
	end

	ArrowBase.super.update(self, unit, t, dt)

	if self._draw_debug_cone then
		local tip = unit:position()
		local base = tip + unit:rotation():y() * -35

		Application:draw_cone(tip, base, 3, 0, 0, 1)
	end
end

function ArrowBase:_on_collision(col_ray)
	local damage_mult = self._weapon_damage_mult or 1
	local loose_shoot = self._weapon_charge_fail
	local result = nil
	
	if not loose_shoot and alive(col_ray.unit) then
		local client_damage = self._damage_class.is_explosive_bullet or alive(col_ray.unit) and col_ray.unit:id() ~= -1

		if Network:is_server() or client_damage then
			result = self._damage_class:on_collision(col_ray, self._weapon_unit or self._unit, self._thrower_unit, self._damage * damage_mult, false, false)
		end
	end

	if not loose_shoot and tweak_data.projectiles[self._tweak_projectile_entry].remove_on_impact then
		self._unit:set_slot(0)

		return
	end
	
	self._unit:body("dynamic_body"):set_deactivate_tag(Idstring())

	self._col_ray = col_ray
		
	if self._homing then
		world_g:stop_physic_effect(self._homing)
		self._homing = nil
	end

	self:_attach_to_hit_unit(nil, loose_shoot)
end