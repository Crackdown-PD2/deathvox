local mvec_to = Vector3()
local mvec_spread = Vector3()
local mvec1 = Vector3()
function NewNPCRaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, shoot_through_data)
	local result = {}
	local hit_unit
	local ray_distance = shoot_through_data and shoot_through_data.ray_distance or self._weapon_range or 20000
	mvector3.set(mvec_to, direction)
	mvector3.multiply(mvec_to, ray_distance)
	mvector3.add(mvec_to, from_pos)
	local damage = self._damage * (dmg_mul or 1)
	local new_damage = damage * 0.74
	damage = new_damage
	local ray_from_unit = shoot_through_data and alive(shoot_through_data.ray_from_unit) and shoot_through_data.ray_from_unit or nil
	local col_ray = ray_from_unit or World:raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
	if shoot_through_data and shoot_through_data.has_hit_wall then
		if not col_ray then
			return result
		end
		mvector3.set(mvec1, col_ray.ray)
		mvector3.multiply(mvec1, -5)
		mvector3.add(mvec1, col_ray.position)
		local ray_blocked = World:raycast("ray", mvec1, shoot_through_data.from, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "report")
		if ray_blocked then
			return result
		end
	end
	if col_ray then
		if col_ray.unit:in_slot(self._character_slotmask) then
			hit_unit = InstantBulletBase:on_collision(col_ray, self._unit, user_unit, damage)
		elseif shoot_player and self:damage_player(col_ray, from_pos, direction) then
			InstantBulletBase:on_hit_player(col_ray, self._unit, user_unit, self._damage * (dmg_mul or 1))
		else
			hit_unit = InstantBulletBase:on_collision(col_ray, self._unit, user_unit, damage)
		end
	elseif shoot_player then
		local hit, ray_data = self:damage_player(col_ray, from_pos, direction)
		if hit then
			InstantBulletBase:on_hit_player(ray_data, self._unit, user_unit, damage)
		end
	end
	if not col_ray or col_ray.distance > 600 then
		local jfc = tweak_data.weapon[self._name_id]
		local num_rays = jfc.rays or 1
		for i = 1, num_rays do
			mvector3.set(mvec_spread, direction)
			if i > 1 then
				mvector3.spread(mvec_spread, self:_get_spread())
			end
			self:_spawn_trail_effect(mvec_spread, col_ray)
		end
	end
	result.hit_enemy = hit_unit
	if self._alert_events then
		result.rays = {col_ray}
	end

-- attempt to replicate base game code for crew boost piercing function.
	
	if col_ray and col_ray.unit then
		local ap_skill = self._is_team_ai and managers.player:has_category_upgrade("team", "crew_ai_ap_ammo")

		repeat
			if hit_unit and not ap_skill then
				break
			end

			if col_ray.distance < 0.1 or ray_distance - col_ray.distance < 50 then
				break
			end

			local has_hit_wall = shoot_through_data and shoot_through_data.has_hit_wall
			local has_passed_shield = shoot_through_data and shoot_through_data.has_passed_shield
			local is_shoot_through, is_shield, is_wall = nil

			if not hit_unit then
				local is_world_geometry = col_ray.unit:in_slot(managers.slot:get_mask("world_geometry"))

				if is_world_geometry then
					is_shoot_through = not col_ray.body:has_ray_type(Idstring("ai_vision"))

					if not is_shoot_through then
						if has_hit_wall or not ap_skill then
							break
						end

						is_wall = true
					end
				else
					if not ap_skill then
						break
					end

					is_shield = col_ray.unit:in_slot(8) and alive(col_ray.unit:parent())
				end
			end

			if not hit_unit and not is_shoot_through and not is_shield and not is_wall then
				break
			end

			local ray_from_unit = (hit_unit or is_shield) and col_ray.unit
			self._shoot_through_data.has_hit_wall = has_hit_wall or is_wall
			self._shoot_through_data.has_passed_shield = has_passed_shield or is_shield
			self._shoot_through_data.ray_from_unit = ray_from_unit
			self._shoot_through_data.ray_distance = ray_distance - col_ray.distance

			mvector3.set(self._shoot_through_data.from, direction)
			mvector3.multiply(self._shoot_through_data.from, is_shield and 5 or 40)
			mvector3.add(self._shoot_through_data.from, col_ray.position)
			managers.game_play_central:queue_fire_raycast(Application:time() + 0.0125, self._unit, user_unit, self._shoot_through_data.from, mvector3.copy(direction), dmg_mul, shoot_player, self._shoot_through_data)
		until true
	end

	return result
end

-- end of attempt to replicate base game crew boost piercing function.

-- add weapon firing animation
-- Lifted directly from HD weapon customization by Shiny Hoppip
local fire_original = NewNPCRaycastWeaponBase.fire
function NewNPCRaycastWeaponBase:fire(...)
  local result = fire_original(self, ...)
   self:tweak_data_anim_play("fire")
  return result
end

local fire_blank_original = NewNPCRaycastWeaponBase.fire_blank
function NewNPCRaycastWeaponBase:fire_blank(...)
  local result = fire_blank_original(self, ...)
   self:tweak_data_anim_play("fire")
  return result
end

local auto_fire_blank_original = NewNPCRaycastWeaponBase.auto_fire_blank
function NewNPCRaycastWeaponBase:auto_fire_blank(...)
  local result = auto_fire_blank_original(self, ...)
   self:tweak_data_anim_play("fire")
  return result
end

local tweak_data_anim_play_original = NewNPCRaycastWeaponBase.tweak_data_anim_play
function NewNPCRaycastWeaponBase:tweak_data_anim_play(anim, ...)
  local unit_anim = self:_get_tweak_data_weapon_animation(anim)
  -- disable animations that don't have a unit to prevent crashing
  if not self._checked_anims[unit_anim] then
	for part_id, data in pairs(self._parts) do
	  if data.animations and data.animations[unit_anim] and not data.unit then
		data.animations[unit_anim] = nil
	  end
	end
	self._checked_anims[unit_anim] = true
  end
  return tweak_data_anim_play_original(self, anim, ...)
end

local setup_original = NewNPCRaycastWeaponBase.setup
function NewNPCRaycastWeaponBase:setup(...)
  setup_original(self, ...)

  self._checked_anims = {}
end


function NewNPCRaycastWeaponBase:add_damage_multiplier(damage_multiplier)
	self._damage = self._damage * damage_multiplier
end

local destroy_original = NewNPCRaycastWeaponBase.destroy
function NewNPCRaycastWeaponBase:destroy(...)
  if alive(self._collider_unit) then
    World:delete_unit(self._collider_unit)
  end
  return destroy_original(self, ...)
end

DeathVoxSniperWeaponBase = DeathVoxSniperWeaponBase or blt_class(NewNPCRaycastWeaponBase)
DeathVoxSniperWeaponBase.TRAIL_EFFECT = Idstring("effects/particles/weapons/trail_dv_sniper")

DeathVoxGrenadierWeaponBase = DeathVoxGrenadierWeaponBase or blt_class(NewNPCRaycastWeaponBase)
function DeathVoxGrenadierWeaponBase:init(unit)
	DeathVoxGrenadierWeaponBase.super.init(self, unit)
	self._grenade_cooldown = 0
	self._grenade_cooldown_max = 10
	self._firing_status = 0 -- 0 for can fire, 1 for speaking
	self._speaking_cooldown = 1
	self._speak_cool = 0
end

function DeathVoxGrenadierWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, shoot_through_data)
	local t = TimerManager:main():time()
	if self._grenade_cooldown > t or self._speak_cool > t then
		return {}
	end
	if self._firing_status == 0 then
		self._firing_status = 1
		user_unit:sound():say("use_gas", true, nil, true)
		self._speak_cool = t + self._speaking_cooldown
		return {}
	else
		if not Network:is_client() then
			local unit = nil
			local mvec_from_pos = Vector3()
			local mvec_direction = Vector3()
			mvector3.set(mvec_from_pos, from_pos)
			mvector3.set(mvec_direction, direction)
			mvector3.multiply(mvec_direction, 100)
			
			mvector3.add(mvec_from_pos, mvec_direction)
			if not self._client_authoritative then
				unit = ProjectileBase.throw_projectile("dv_grenadier_grenade", mvec_from_pos, direction)
			end
			self._firing_status = 0
			self._grenade_cooldown = t + self._grenade_cooldown_max
			return {}
		end
	end
	return {}
end



