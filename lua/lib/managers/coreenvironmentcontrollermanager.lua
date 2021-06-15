local flashbang_test_offset = Vector3(0, 0, 150)

function CoreEnvironmentControllerManager:set_flashbang(flashbang_pos, line_of_sight, travel_dis, linear_dis, duration)
	local flash = self:test_line_of_sight(flashbang_pos + flashbang_test_offset, 200, 1000, 3000, true)
	self._flashbang_duration = duration

	if flash > 0 then
		self._current_flashbang = math.min(self._current_flashbang + flash, 1.5) * self._flashbang_duration
		self._current_flashbang_flash = math.min(self._current_flashbang_flash + flash, 1.5) * self._flashbang_duration
	end

	World:effect_manager():spawn({
		effect = Idstring("effects/particles/explosions/explosion_grenade"),
		position = flashbang_pos,
		normal = Vector3(0, 0, 1)
	})
end

function CoreEnvironmentControllerManager:test_line_of_sight(test_pos, min_distance, dot_distance, max_distance, is_flashbang)
	local tmp_vec1 = Vector3()
	local tmp_vec2 = Vector3()
	local tmp_vec3 = Vector3()
	local vp = managers.viewport:first_active_viewport()

	if not vp then
		return 0
	end

	local camera = vp:camera()
	local cam_pos = tmp_vec1

	camera:m_position(cam_pos)

	local test_vec = tmp_vec2
	local dis = mvector3.direction(test_vec, cam_pos, test_pos)

	if max_distance < dis then
		return 0
	end

	if dis < min_distance then
		if is_flashbang then
			managers.player:player_unit():sound():say("g41x_any", true)
		end

		return 1
	end

	local dot_mul = 1
	local max_dot = math.cos(75)
	local cam_rot = camera:rotation()
	local cam_fwd = camera:rotation():y()

	if mvector3.dot(cam_fwd, test_vec) < max_dot then
		if dis < dot_distance then
			dot_mul = 0.5
		else
			return 0
		end
	end

	local ray_hit = World:raycast("ray", cam_pos, test_pos, "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", "ai_vision", "report")

	if ray_hit then
		return 0
	end

	local flash = math.max(dis - min_distance, 0) / (max_distance - min_distance)
	flash = (1 - flash) * dot_mul

	if is_flashbang and dot_mul == 1 then
		managers.player:player_unit():sound():say("g41x_any", true)
	end

	return flash
end

function CoreEnvironmentControllerManager:set_chromatic_enabled(enabled)
	self._chromatic_enabled = enabled

	if self._material then
		if self._chromatic_enabled then
			self._material:set_variable(Idstring("chromatic_amount"), self._base_chromatic_amount)
		else
			self._material:set_variable(Idstring("chromatic_amount"), 0)
		end
	end
end

function CoreEnvironmentControllerManager:set_contrast_value_lerp(lerp_value)
	if not lerp_value then
		return
	end

	if self._material then
		local high_contrast = lerp_value >= 0.99 and math.lerp(0.5, 0.6, math.random()) or 0.5
		if self._chromatic_enabled then
			high_contrast = high_contrast * 0.5
		end
		local new_contrast_value = math.lerp(self._base_contrast, high_contrast, lerp_value)
		self._material:set_variable(Idstring("contrast"), new_contrast_value)
	end
end

function CoreEnvironmentControllerManager:set_chromatic_value_lerp(lerp_value)
	if not lerp_value then
		return
	end
	
	if not self._chromatic_enabled then
		return
	end

	if self._material then
		if self._chromatic_enabled then
			--log("nice")
			self._current_chrom = lerp_value >= 0.99 and math.lerp(-1.4, -2.8, math.random()) or self._current_chrom
			local new_chrom_value = math.lerp(self._base_chromatic_amount, self._current_chrom, lerp_value)
			self._material:set_variable(Idstring("chromatic_amount"), new_chrom_value)
		end
	end
end

function CoreEnvironmentControllerManager:set_sociopath_inv_value(value)
	if not value then
		return
	end
	
	self._sociopath_inv_timer = value
	self._health_effect_value = 1
	self._old_health_effect_value = 1
	self._health_effect_value_diff = 0.4
	self._hurt_value = 1
end

function CoreEnvironmentControllerManager:update(t, dt)
	self:_update_values(t, dt)
	self:set_post_composite(t, dt)
	
	if self._sociopath_inv_timer then
		self._sociopath_inv_timer = self._sociopath_inv_timer - dt
		
		if self._sociopath_inv_timer > 0 then
			local lerp = math.min(self._sociopath_inv_timer, 1)
			self:set_chromatic_value_lerp(lerp)
			self:set_contrast_value_lerp(lerp)
		else
			self._sociopath_inv_timer = nil
		end
	end
end
