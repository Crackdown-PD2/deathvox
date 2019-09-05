local tmp_rot1 = Rotation()

function SentryGunWeapon:init(unit)
	self._unit = unit
	self._current_damage_mul = 1
	self._timer = TimerManager:game()
	self._character_slotmask = managers.slot:get_mask("raycastable_characters")
	self._next_fire_allowed = -1000
	self._obj_fire = self._unit:get_object(Idstring("a_detect"))
	self._shoot_through_data = {from = Vector3()}
	self._effect_align = {
		self._unit:get_object(Idstring(self._muzzle_flash_parent or "fire")),
		self._unit:get_object(Idstring(self._muzzle_flash_parent or "fire"))
	}
	self._muzzle_flash_parent = nil

	if self._laser_align_name then
		self._laser_align = self._unit:get_object(Idstring(self._laser_align_name))
	end

	self._interleaving_fire = 1
	self._trail_effect_table = {
		effect = RaycastWeaponBase.TRAIL_EFFECT,
		position = Vector3(),
		normal = Vector3()
	}
	self._ammo_sync_resolution = 0.0625

	if Network:is_server() then
		self._ammo_total = 1
		self._ammo_max = self._ammo_total
		self._ammo_sync = 16
	else
		self._ammo_ratio = 1
	end

	self._spread_mul = 1
	self._use_armor_piercing = false
	self._slow_fire_rate = false
	self._fire_rate_reduction = 1
	self._name_id = self._unit:base():get_name_id()
	local my_tweak_data = tweak_data.weapon[self._name_id]
	self._default_alert_size = my_tweak_data.alert_size
	self._from = Vector3()
	self._to = Vector3()
end

function SentryGunWeapon:switch_fire_mode()
	self:_set_fire_mode(not self._use_armor_piercing)

	if self._use_armor_piercing then
		managers.hint:show_hint("sentry_set_ap_rounds")
		self._unit:base()._use_armor_piercing = true
	else
		managers.hint:show_hint("sentry_normal_ammo")
		self._unit:base()._use_armor_piercing = nil
	end

	self._unit:network():send("sentrygun_sync_armor_piercing", self._use_armor_piercing)
	self._unit:sound_source():post_event("wp_sentrygun_swap_ammo")
	self._unit:event_listener():call("on_switch_fire_mode", self._use_armor_piercing)
end

local mvec_to = Vector3()

function SentryGunWeapon:_fire_raycast(from_pos, direction, shoot_player, target_unit)
	if not self._setup.ignore_units then
		return
	end

	local hit_unit = nil
	local result = {}
	local ray_distance = tweak_data.weapon[self._name_id].FIRE_RANGE or 20000

	mvector3.set(mvec_to, direction)
	mvector3.multiply(mvec_to, ray_distance)
	mvector3.add(mvec_to, from_pos)

	self._from = from_pos
	self._to = mvec_to

	local ray_hits = nil
	local hit_enemy = false
	local went_through_wall = false
	local enemy_mask = self._unit:in_slot(25) and managers.slot:get_mask("enemies") or managers.slot:get_mask("criminals")
	local wall_mask = managers.slot:get_mask("world_geometry", "vehicles")
	local shield_mask = managers.slot:get_mask("enemy_shield_check")
	local ai_vision_ids = Idstring("ai_vision")
	local bulletproof_ids = Idstring("bulletproof")

	if self._use_armor_piercing then
		ray_hits = World:raycast_wall("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "thickness", 40, "thickness_mask", wall_mask) --try to change so that no infinite penetration happens
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
		local player_hit, player_ray_data = nil

		if shoot_player then
			player_hit, player_ray_data = RaycastWeaponBase.damage_player(self, col_ray, from_pos, direction)

			if player_hit then
				local damage = self:_apply_dmg_mul(self._damage, col_ray or player_ray_data, from_pos)

				InstantBulletBase:on_hit_player(col_ray or player_ray_data, self._unit, self._unit, damage)
			end
		end

		if not player_hit and col_ray then
			local damage = self:_apply_dmg_mul(self._damage, col_ray, from_pos)
			hit_unit = InstantBulletBase:on_collision(col_ray, self._unit, self._unit, damage)
		end
	end

	if (not col_ray or col_ray.unit ~= target_unit) and target_unit and target_unit:character_damage() and target_unit:character_damage().build_suppression then
		target_unit:character_damage():build_suppression(self._suppression) --check
	end

	result.hit_enemy = hit_unit

	local furthest_hit = unique_hits[#unique_hits]

	if (furthest_hit and furthest_hit.distance > 600 or not furthest_hit) and alive(self._obj_fire) then
		self:_spawn_trail_effect(direction, furthest_hit)
	end

	if self._alert_events then
		result.rays = unique_hits
	end

	return result
end
