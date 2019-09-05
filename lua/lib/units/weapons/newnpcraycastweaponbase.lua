local mvec_to = Vector3()
local mvec_direction = Vector3()
local mvec_spread = Vector3()
local mvec1 = Vector3()
local mvec_spread_direction = Vector3()

function NewNPCRaycastWeaponBase:init(unit)
	NewRaycastWeaponBase.super.super.init(self, unit, false)

	self._player_manager = managers.player
	self._unit = unit
	self._name_id = self.name_id or "m4_crew"
	self.name_id = nil
	self._bullet_slotmask = managers.slot:get_mask("bullet_impact_targets")
	self._blank_slotmask = managers.slot:get_mask("bullet_blank_impact_targets")

	self:_create_use_setups()

	self._setup = {}
	self._digest_values = false

	self:set_ammo_max(tweak_data.weapon[self._name_id].AMMO_MAX)
	self:set_ammo_total(self:get_ammo_max())
	self:set_ammo_max_per_clip(tweak_data.weapon[self._name_id].CLIP_AMMO_MAX)
	self:set_ammo_remaining_in_clip(self:get_ammo_max_per_clip())

	self._damage = tweak_data.weapon[self._name_id].DAMAGE
	self._shoot_through_data = {
		from = Vector3()
	}
	self._next_fire_allowed = -1000
	self._obj_fire = self._unit:get_object(Idstring("fire"))
	self._sound_fire = SoundDevice:create_source("fire")

	self._sound_fire:link(self._unit:orientation_object())

	self._muzzle_effect = Idstring(self:weapon_tweak_data().muzzleflash or "effects/particles/test/muzzleflash_maingun")
	self._muzzle_effect_table = {
		force_synch = false,
		effect = self._muzzle_effect,
		parent = self._obj_fire
	}
	self._use_shell_ejection_effect = SystemInfo:platform() == Idstring("WIN32")

	if self:weapon_tweak_data().armor_piercing then
		self._use_armor_piercing = true
	end

	if self._use_shell_ejection_effect then
		self._obj_shell_ejection = self._unit:get_object(Idstring("a_shell"))
		self._shell_ejection_effect = Idstring(self:weapon_tweak_data().shell_ejection or "effects/payday2/particles/weapons/shells/shell_556")
		self._shell_ejection_effect_table = {
			effect = self._shell_ejection_effect,
			parent = self._obj_shell_ejection
		}
	end

	self._trail_effect_table = {
		effect = self.TRAIL_EFFECT,
		position = Vector3(),
		normal = Vector3()
	}
	self._flashlight_light_lod_enabled = true

	if self._multivoice then
		if not NewNPCRaycastWeaponBase._next_i_voice[self._name_id] then
			NewNPCRaycastWeaponBase._next_i_voice[self._name_id] = 1
		end

		self._voice = NewNPCRaycastWeaponBase._VOICES[NewNPCRaycastWeaponBase._next_i_voice[self._name_id]]

		if NewNPCRaycastWeaponBase._next_i_voice[self._name_id] == #NewNPCRaycastWeaponBase._VOICES then
			NewNPCRaycastWeaponBase._next_i_voice[self._name_id] = 1
		else
			NewNPCRaycastWeaponBase._next_i_voice[self._name_id] = NewNPCRaycastWeaponBase._next_i_voice[self._name_id] + 1
		end
	else
		self._voice = "a"
	end

	if self._unit:get_object(Idstring("ls_flashlight")) then
		self._flashlight_data = {
			light = self._unit:get_object(Idstring("ls_flashlight")),
			effect = self._unit:effect_spawner(Idstring("flashlight"))
		}

		self._flashlight_data.light:set_far_range(400)
		self._flashlight_data.light:set_spot_angle_end(25)
		self._flashlight_data.light:set_multiplier(2)
	end

	self._textures = {}
	self._cosmetics_data = nil
	self._materials = nil

	managers.mission:add_global_event_listener(tostring(self._unit:key()), {
		"on_peer_removed"
	}, callback(self, self, "_on_peer_removed"))
end

function NewNPCRaycastWeaponBase:setup(setup_data)
	self._autoaim = setup_data.autoaim
	self._alert_events = setup_data.alert_AI and {} or nil
	self._alert_size = tweak_data.weapon[self._name_id].alert_size
	self._alert_fires = {}
	self._suppression = tweak_data.weapon[self._name_id].suppression
	self._bullet_slotmask = setup_data.hit_slotmask or self._bullet_slotmask
	self._character_slotmask = managers.slot:get_mask("raycastable_characters")
	self._hit_player = setup_data.hit_player and true or false
	self._setup = setup_data
	self._part_stats = managers.weapon_factory:get_stats(self._factory_id, self._blueprint)

	if setup_data.user_unit:in_slot(16) then --allow bots to shoot through each other
		self._bullet_slotmask = self._bullet_slotmask - World:make_slot_mask(16, 22)
	end
end

--goof wrote this, originally. it appears to be intended to prevent piercing bullet raycasts from piercing infinitely. 
--however, this breaks team ai's AP ammo crew boost, and goof's changes don't appear to do anything else, so i'm gonna disable it for the time being

function NewNPCRaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, shoot_through_data)
	--check for the armor piercing skills (can't be done through init), this also allows body armor piercing without having to add a specicic check when hitting body_plate
	if not self._checked_for_ap and not self._use_armor_piercing then
		if self._is_team_ai and managers.player:has_category_upgrade("team", "crew_ai_ap_ammo") then
			self._checked_for_ap = true
			self._use_armor_piercing = true
		end
	end

	local hit_unit = nil
	local result = {}
	local ray_distance = self._weapon_range or 20000

	mvector3.set(mvec_to, direction)
	mvector3.multiply(mvec_to, ray_distance)
	mvector3.add(mvec_to, from_pos)

	local damage = self._damage * (dmg_mul or 1)

	local ray_hits = nil
	local hit_enemy = false
	local went_through_wall = false
	local enemy_mask = managers.slot:get_mask("enemies")
	local wall_mask = managers.slot:get_mask("world_geometry", "vehicles")
	local shield_mask = managers.slot:get_mask("enemy_shield_check")
	local ai_vision_ids = Idstring("ai_vision")
	local bulletproof_ids = Idstring("bulletproof")

	if self._use_armor_piercing then
		ray_hits = World:raycast_wall("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "thickness", 40, "thickness_mask", wall_mask)
	else
		ray_hits = World:raycast_all("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
	end

	local units_hit = {}
	local unique_hits = {}

	for i, hit in ipairs(ray_hits) do
		if not units_hit[hit.unit:key()] then
			units_hit[hit.unit:key()] = true
			unique_hits[#unique_hits + 1] = hit
			hit.hit_position = hit.position
			hit_enemy = hit_enemy or hit.unit:in_slot(enemy_mask)
			local weak_body = hit.body:has_ray_type(ai_vision_ids)
			weak_body = weak_body or hit.body:has_ray_type(bulletproof_ids)

			if not self._use_armor_piercing and hit_enemy then
				break
			elseif hit.unit:in_slot(wall_mask) then
				if weak_body then
					if self._use_armor_piercing then
						if went_through_wall then
							break
						else
							went_through_wall = true
						end
					else
						break
					end
				end
			elseif not self._use_armor_piercing and hit.unit:in_slot(shield_mask) then
				break
			end
		end
	end

	for k, col_ray in ipairs(unique_hits) do
		if col_ray then
			if col_ray.unit:in_slot(self._character_slotmask) then
				hit_unit = InstantBulletBase:on_collision(col_ray, self._unit, user_unit, damage)
			elseif shoot_player and self._hit_player and self:damage_player(col_ray, from_pos, direction) then
				InstantBulletBase:on_hit_player(col_ray, self._unit, user_unit, self._damage * (dmg_mul or 1))
			else
				hit_unit = InstantBulletBase:on_collision(col_ray, self._unit, user_unit, damage)
			end
		elseif shoot_player and self._hit_player then
			local hit, ray_data = self:damage_player(col_ray, from_pos, direction)

			if hit then
				InstantBulletBase:on_hit_player(ray_data, self._unit, user_unit, damage)
			end
		end
	end

	result.hit_enemy = hit_unit

	local furthest_hit = unique_hits[#unique_hits]

	if (furthest_hit and furthest_hit.distance > 600 or not furthest_hit) and alive(self._obj_fire) then
		local right = direction:cross(math.UP):normalized()
		local up = direction:cross(right):normalized()
		local name_id = self.non_npc_name_id and self:non_npc_name_id() or self._name_id
		local num_rays = (tweak_data.weapon[name_id] or {}).rays or 1

		for v = 1, num_rays, 1 do
			mvector3.set(mvec_spread, direction)

			if v > 1 then
				local spread_x, spread_y = self:_get_spread(user_unit)
				local theta = math.random() * 360
				local ax = math.sin(theta) * math.random() * spread_x
				local ay = math.cos(theta) * math.random() * (spread_y or spread_x)

				mvector3.add(mvec_spread, right * math.rad(ax))
				mvector3.add(mvec_spread, up * math.rad(ay))
			end

			self:_spawn_trail_effect(mvec_spread, furthest_hit)
		end
	end

	if self._alert_events then
		result.rays = unique_hits
	end

	return result
end

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

--DeathVoxSniperWeaponBase = DeathVoxSniperWeaponBase or blt_class(NewNPCRaycastWeaponBase)
--DeathVoxSniperWeaponBase.TRAIL_EFFECT = Idstring("effects/particles/weapons/trail_dv_sniper")

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



