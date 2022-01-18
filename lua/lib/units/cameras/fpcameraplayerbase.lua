function FPCameraPlayerBase:recoil_kick(up, down, left, right)
	local v = math.lerp(up, down, math.random())
	self._recoil_kick.accumulated = ((self._recoil_kick.accumulated or 0) + v)
	local h = math.lerp(left, right, math.random())
	self._recoil_kick.h.accumulated = ((self._recoil_kick.h.accumulated or 0) + h)
end
		
function FPCameraPlayerBase:stop_shooting(wait)
	if managers.user:get_setting("staticrecoil") then
		
		self._recoil_kick.to_reduce = 0
		self._recoil_kick.h.to_reduce = 0
		self._recoil_wait = nil
		self._recoil_kick.current = 0
		self._recoil_kick.h.current = 0
		self._recoil_kick.accumulated = 0
		self._recoil_kick.h.accumulated = 0
		
		return
	end

	self._recoil_kick.to_reduce = self._recoil_kick.accumulated
	self._recoil_kick.h.to_reduce = self._recoil_kick.h.accumulated
	self._recoil_wait = nil
end

function FPCameraPlayerBase:_vertical_recoil_kick(t, dt)
	local player_state = managers.player:current_state()

	if player_state == "bipod" then
		self:break_recoil()

		return 0
	end

	local r_value = 0
	local equipped_weapon = self._parent_unit:inventory():equipped_unit()
	local dt_mul = 1
	local dt_with_mul = dt

	if alive(equipped_weapon) and equipped_weapon:base() then
		dt_mul = dt_mul / (equipped_weapon:base():recoil() + equipped_weapon:base():recoil_addend()) * equipped_weapon:base():recoil_multiplier()
		dt_with_mul = dt_with_mul * dt_mul
	end

	if self._recoil_kick.current and self._episilon < self._recoil_kick.accumulated - self._recoil_kick.current then
		local n = math.step(self._recoil_kick.current, self._recoil_kick.accumulated, 40 * dt_with_mul)
		r_value = n - self._recoil_kick.current
		self._recoil_kick.current = n
	elseif self._recoil_wait then
		self._recoil_wait = self._recoil_wait - dt

		if self._recoil_wait <= 0 then
			self._recoil_wait = nil
		end
	elseif self._recoil_kick.to_reduce then
		self._recoil_kick.current = nil
		local n = math.lerp(self._recoil_kick.to_reduce, 0, 9 * dt_with_mul)
		r_value = -(self._recoil_kick.to_reduce - n)
		self._recoil_kick.to_reduce = n

		if self._recoil_kick.to_reduce <= 0 then
			self._recoil_kick.to_reduce = nil
		end
	end

	return r_value
end

function FPCameraPlayerBase:_horizonatal_recoil_kick(t, dt)
	local player_state = managers.player:current_state()

	if player_state == "bipod" then
		return 0
	end

	local r_value = 0
	local equipped_weapon = self._parent_unit:inventory():equipped_unit()
	local dt_mul = 1
	local dt_with_mul = dt

	if alive(equipped_weapon) and equipped_weapon:base() then
		dt_mul = dt_mul / (equipped_weapon:base():recoil() + equipped_weapon:base():recoil_addend()) * equipped_weapon:base():recoil_multiplier()
		dt_with_mul = dt_with_mul * dt_mul
	end

	if self._recoil_kick.h.current and self._episilon < math.abs(self._recoil_kick.h.accumulated - self._recoil_kick.h.current) then
		local n = math.step(self._recoil_kick.h.current, self._recoil_kick.h.accumulated, 40 * dt_with_mul)
		r_value = n - self._recoil_kick.h.current
		self._recoil_kick.h.current = n
	elseif self._recoil_wait then
		self._recoil_wait = self._recoil_wait - dt

		if self._recoil_wait <= 0 then
			self._recoil_wait = nil
		end
	elseif self._recoil_kick.h.to_reduce then
		self._recoil_kick.h.current = nil
		local n = math.lerp(self._recoil_kick.h.to_reduce, 0, 9 * dt_with_mul)
		r_value = -(self._recoil_kick.h.to_reduce - n)
		self._recoil_kick.h.to_reduce = n

		if self._recoil_kick.h.to_reduce <= 0 then
			self._recoil_kick.h.to_reduce = nil
		end
	end

	return r_value
end