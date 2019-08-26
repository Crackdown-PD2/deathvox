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

function SentryGunWeapon:fire(blanks, expend_ammo, shoot_player, target_unit)
	if expend_ammo then
		if self._ammo_total <= 0 then
			return
		end

		self:change_ammo(-1)
	end

	local fire_obj = self._effect_align[self._interleaving_fire]
	local from_pos = fire_obj:position()
	local direction = fire_obj:rotation():y()

	mvector3.spread(direction, tweak_data.weapon[self._name_id].SPREAD * self._spread_mul)
	World:effect_manager():spawn(self._muzzle_effect_table[self._interleaving_fire])

	if self._use_shell_ejection_effect then
		World:effect_manager():spawn(self._shell_ejection_effect_table)
	end

	if self._unit:damage() and self._unit:damage():has_sequence("anim_fire_seq") then
		self._unit:damage():run_sequence_simple("anim_fire_seq")
	end

	local ray_res = self:_fire_raycast(self._unit, from_pos, direction, shoot_player, target_unit)

	if self._alert_events and ray_res.rays then
		RaycastWeaponBase._check_alert(self, ray_res.rays, from_pos, direction, self._unit)
	end

	self._unit:movement():give_recoil()
	self._unit:event_listener():call("on_fire")

	return ray_res
end

local mvec_to = Vector3()

function SentryGunWeapon:_fire_raycast(user_unit, from_pos, direction, shoot_player, target_unit, shoot_through_data)
	local result = {}
	local hit_unit, col_ray = nil
	local ray_distance = shoot_through_data and shoot_through_data.ray_distance or tweak_data.weapon[self._name_id].FIRE_RANGE or 20000

	mvector3.set(mvec_to, direction)
	mvector3.multiply(mvec_to, ray_distance)
	mvector3.add(mvec_to, from_pos)

	self._from = from_pos
	self._to = mvec_to

	if not self._setup.ignore_units then
		return
	end

	local ray_from_unit = shoot_through_data and alive(shoot_through_data.ray_from_unit) and shoot_through_data.ray_from_unit or nil
	local col_ray = (ray_from_unit or World):raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
	local player_hit, player_ray_data = nil

	if shoot_player then
		player_hit, player_ray_data = RaycastWeaponBase.damage_player(self, col_ray, from_pos, direction)

		if player_hit then
			local damage = self:_apply_dmg_mul(self._damage, col_ray or player_ray_data, from_pos)

			InstantBulletBase:on_hit_player(col_ray or player_ray_data, self._unit, user_unit, damage)
		end
	end

	if not player_hit and col_ray then
		local damage = self:_apply_dmg_mul(self._damage, col_ray, from_pos)

		hit_unit = InstantBulletBase:on_collision(col_ray, self._unit, user_unit, damage)
	end

	if (not col_ray or col_ray.unit ~= target_unit) and target_unit and target_unit:character_damage() and target_unit:character_damage().build_suppression then
		target_unit:character_damage():build_suppression(self._suppression)
	end

	if not col_ray or col_ray.distance > 600 then
		self:_spawn_trail_effect(direction, col_ray)
	end

	if col_ray and col_ray.unit then
		repeat
			if hit_unit and not self._use_armor_piercing then
				break
			end

			if col_ray.distance < 0.1 or ray_distance - col_ray.distance < 50 then
				break
			end

			local has_hit_wall = shoot_through_data and shoot_through_data.has_hit_wall
			local has_passed_shield = shoot_through_data and shoot_through_data.has_passed_shield
			local is_shoot_through, is_shield, is_wall = nil

			if not hit_unit then
				local is_world_geometry = col_ray.unit:in_slot(managers.slot:get_mask("world_geometry", "vehicles"))

				if is_world_geometry then
					is_shoot_through = not col_ray.body:has_ray_type(Idstring("ai_vision"))

					if not is_shoot_through then
						if has_hit_wall or not self._use_armor_piercing then
							break
						end

						is_wall = true
					end
				else
					if not self._use_armor_piercing then
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
			managers.game_play_central:queue_fire_raycast(Application:time() + 0.0125, self._unit, user_unit, self._shoot_through_data.from, mvector3.copy(direction), shoot_player, target_unit, self._shoot_through_data)
		until true
	end

	result.hit_enemy = hit_unit

	if self._alert_events then
		result.rays = {col_ray}
	end

	return result
end
