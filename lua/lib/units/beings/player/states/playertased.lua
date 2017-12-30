function PlayerTased:_update_check_actions(t, dt)
	local input = self:_get_input(t, dt)
	local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	if self._next_shock < t then
		self._num_shocks = self._num_shocks + 1
		if difficulty_index == 8 then
			self._next_shock = t + 0.1 + math.rand(0.5)
			self._unit:camera():play_shaker("player_taser_shock", 1, 10)
			self._unit:camera():camera_unit():base():set_target_tilt((math.random(2) == 1 and -1 or 1) * math.random(40))
		else
			self._next_shock = t + 0.25 + math.rand(1)
			self._unit:camera():play_shaker("player_taser_shock", 1, 10)
			self._unit:camera():camera_unit():base():set_target_tilt((math.random(2) == 1 and -1 or 1) * math.random(10))
		end

		self._taser_value = math.max(self._taser_value - 0.25, 0)

		self._unit:sound():play("tasered_shock")
		managers.rumble:play("electric_shock")

		if not alive(self._counter_taser_unit) then
			self._camera_unit:base():start_shooting()
			if difficulty_index == 8 then
				self._recoil_t = t + 0.25
			else
				self._recoil_t = t + 0.5
			end
			if not managers.player:has_category_upgrade("player", "resist_firing_tased") then
				input.btn_primary_attack_state = true
				input.btn_primary_attack_press = true
			end
			if difficulty_index == 8 then
				self._camera_unit:base():recoil_kick(-15, 15, -15, 15)
			else
				self._camera_unit:base():recoil_kick(-5, 5, -5, 5)
			end
			self._unit:camera():play_redirect(self:get_animation("tased_boost"))
		end
	elseif self._recoil_t then
		if not managers.player:has_category_upgrade("player", "resist_firing_tased") then
			input.btn_primary_attack_state = true
		end

		if self._recoil_t < t then
			self._recoil_t = nil

			self._camera_unit:base():stop_shooting()
		end
	end

	self._taser_value = math.step(self._taser_value, 0.8, dt / 4)

	managers.environment_controller:set_taser_value(self._taser_value)

	self._shooting = self:_check_action_primary_attack(t, input)

	if self._shooting then
		if difficulty_index == 8 then
			self._camera_unit:base():recoil_kick(-15, 15, -15, 15)
		else
			self._camera_unit:base():recoil_kick(-5, 5, -5, 5)
		end
	end

	if self._unequip_weapon_expire_t and self._unequip_weapon_expire_t <= t then
		self._unequip_weapon_expire_t = nil

		self:_start_action_equip_weapon(t)
	end

	if self._equip_weapon_expire_t and self._equip_weapon_expire_t <= t then
		self._equip_weapon_expire_t = nil
	end

	if input.btn_stats_screen_press then
		self._unit:base():set_stats_screen_visible(true)
	elseif input.btn_stats_screen_release then
		self._unit:base():set_stats_screen_visible(false)
	end

	self:_update_foley(t, input)

	local new_action = nil

	self:_check_action_interact(t, input)

	local new_action = nil
end
