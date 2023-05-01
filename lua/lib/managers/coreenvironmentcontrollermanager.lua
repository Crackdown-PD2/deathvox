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
