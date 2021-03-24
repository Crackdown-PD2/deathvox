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

local mvec_to = Vector3()
local mvec_spread = Vector3()

function NewNPCRaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, shoot_through_data)
	--check for the armor piercing skills (can't be done through init), this also allows body armor piercing without having to add a specicic check when hitting body_plate
	if not self._checked_for_ap then
		self._checked_for_ap = true

		if not self._use_armor_piercing then
			if self._is_team_ai and managers.player:has_category_upgrade("team", "crew_ai_ap_ammo") then
				self._use_armor_piercing = true
			end
		end
	end

	local char_hit = nil
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

			if not self._use_armor_piercing then
				if hit_enemy or hit.unit:in_slot(wall_mask) and weak_body or hit.unit:in_slot(shield_mask) then
					break
				end
			else
				if hit.unit:in_slot(wall_mask) and weak_body then
					if went_through_wall then
						break
					else
						went_through_wall = true
					end
				end
			end
		end
	end

	local furthest_hit = unique_hits[#unique_hits]

	if #unique_hits > 0 then
		local hit_player = false

		for _, hit in ipairs(unique_hits) do
			if self._hit_player and not hit_player and shoot_player then
				local player_hit_ray = deep_clone(hit)
				local player_hit = self:damage_player(player_hit_ray, from_pos, direction, result)

				if player_hit then
					hit_player = true
					char_hit = true

					local damaged_player = InstantBulletBase:on_hit_player(player_hit_ray, self._unit, user_unit, damage)

					if damaged_player then
						if not self._use_armor_piercing then
							hit.unit = managers.player:player_unit()
							hit.body = hit.unit:body("inflict_reciever")
							hit.position = mvector3.copy(hit.body:position())
							hit.hit_position = hit.position
							hit.distance = mvector3.direction(hit.ray, mvector3.copy(from_pos), mvector3.copy(hit.position))
							hit.normal = -hit.ray
							furthest_hit = hit

							break
						end
					end	
				end
			end

			local hit_char = InstantBulletBase:on_collision(hit, self._unit, user_unit, damage)

			if hit_char then
				char_hit = true

				if hit_char.type and hit_char.type == "death" then
					if self:is_category("shotgun") then
						managers.game_play_central:do_shotgun_push(hit.unit, hit.position, hit.ray, hit.distance, user_unit)
					end

					if user_unit:unit_data().mission_element then
						user_unit:unit_data().mission_element:event("killshot", user_unit)
					end
				end
			end
		end
	else
		if self._hit_player and shoot_player then
			local player_hit, player_ray_data = self:damage_player(nil, from_pos, direction, result)

			if player_hit then
				local damaged_player = InstantBulletBase:on_hit_player(player_ray_data, self._unit, user_unit, damage)

				if damaged_player then
					char_hit = true

					if not self._use_armor_piercing then
						player_ray_data.unit = managers.player:player_unit()
						player_ray_data.body = player_ray_data.unit:body("inflict_reciever")
						player_ray_data.position = mvector3.copy(player_ray_data.body:position())
						player_ray_data.hit_position = player_ray_data.position
						player_ray_data.distance = mvector3.direction(player_ray_data.ray, mvector3.copy(from_pos), mvector3.copy(player_ray_data.position))
						player_ray_data.normal = -player_ray_data.ray
						furthest_hit = player_ray_data
					end
				end	
			end
		end
	end

	result.hit_enemy = char_hit

	if alive(self._obj_fire) then
		if furthest_hit and furthest_hit.distance > 600 or not furthest_hit then
			local trail_direction = furthest_hit and furthest_hit.ray or direction
			local right = trail_direction:cross(math.UP):normalized()
			local up = trail_direction:cross(right):normalized()
			local name_id = self.non_npc_name_id and self:non_npc_name_id() or self._name_id
			local num_rays = (tweak_data.weapon[name_id] or {}).rays or 1

			for v = 1, num_rays, 1 do
				mvector3.set(mvec_spread, trail_direction)

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
	end

	if self._suppression then
		local suppression_slot_mask = user_unit:in_slot(16) and managers.slot:get_mask("enemies") or managers.slot:get_mask("players", "criminals")

		self:_suppress_units(mvector3.copy(from_pos), mvector3.copy(direction), ray_distance, suppression_slot_mask, user_unit, nil)
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
	self._speaking_cooldown = 0.9
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
			self._play_fire_sound = true
			return {}
		end
	end
	return {}
end

function DeathVoxGrenadierWeaponBase:singleshot(...)
	local fired = self:fire(...)

	if self._play_fire_sound then
		self._play_fire_sound = nil
		self:_sound_singleshot()
	end

	return fired
end

function DeathVoxGrenadierWeaponBase:trigger_held(...)
	local fired = nil
	
	if self._grenade_cooldown <= Application:time() then
		fired = self:fire(...)
	end

	return fired
end

function DeathVoxGrenadierWeaponBase:auto_trigger_held(...)
	local fired = nil
	
	if self._grenade_cooldown <= Application:time() then
		fired = self:fire(...)
	end

	return fired
end

function DeathVoxGrenadierWeaponBase:fire(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	local user_unit = self._setup.user_unit

	self:_check_ammo_total(user_unit)

	local ray_res = self:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)

	if self._play_fire_sound then --only play the muzzle effects when the grenade is actually getting fired, alongside the actual sound
		if alive(self._obj_fire) then
			self:_spawn_muzzle_effect(from_pos, direction)
		end

		self:_spawn_shell_eject_effect()
	end

	if self._alert_events and ray_res.rays then
		self:_check_alert(ray_res.rays, from_pos, direction, user_unit)
	end

	if ray_res.enemies_in_cone then
		for enemy_data, dis_error in pairs(ray_res.enemies_in_cone) do
			if not enemy_data.unit:movement():cool() then
				enemy_data.unit:character_damage():build_suppression(suppr_mul * dis_error * self._suppression, self._panic_suppression_chance)
			end
		end
	end

	managers.player:send_message(Message.OnWeaponFired, nil, self._unit, ray_res)

	return ray_res
end