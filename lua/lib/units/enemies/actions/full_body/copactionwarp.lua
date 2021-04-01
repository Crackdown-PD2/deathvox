local mvec3_cpy = mvector3.copy

local m_rot_yaw = mrotation.yaw

local math_ceil = math.ceil

function CopActionWarp:init(action_desc, common_data)
	local unit = common_data.unit
	local ext_mov = common_data.ext_movement

	self._unit = unit
	self._ext_movement = ext_mov

	local dynamic_bodies = {}
	local nr_bodies = unit:num_bodies()

	--set dynamic bodies to non-dynamic and store them
	for i = 0, nr_bodies - 1 do
		local body = unit:body(i)

		if body:dynamic() then
			body:set_keyframed()

			dynamic_bodies[#dynamic_bodies + 1] = body
		end
	end

	local warp_pos = action_desc.position
	warp_pos = warp_pos and mvec3_cpy(warp_pos)

	local warp_rot = action_desc.rotation

	--if there's no dynamic bodies, warping can happen instantly
	--else, it needs to happen in the next frame
	if #dynamic_bodies == 0 then
		if warp_pos then
			ext_mov:set_position(warp_pos)
		end

		if warp_rot then
			ext_mov:set_rotation(warp_rot)
		end
	else
		self._dynamic_bodies = dynamic_bodies

		self._warp_pos = warp_pos
		self._warp_rot = warp_rot
	end

	if Network:is_server() then
		--bot with stay put order, remove it
		if ext_mov._should_stay then
			ext_mov:set_should_stay(false)
		end

		local sync_pos, has_sync_pos = nil

		if warp_pos then
			has_sync_pos = true
			sync_pos = warp_pos
		else
			has_sync_pos = false
			sync_pos = Vector3() --empty vector because sending nil will crash
		end

		local sync_yaw, has_rotation = nil

		if warp_rot then
			has_rotation = true

			local yaw = m_rot_yaw(warp_rot)

			if yaw < 0 then
				yaw = 360 + yaw
			end

			sync_yaw = 1 + math_ceil(yaw * 254 / 360)
		else
			sync_yaw = 0 --same as with the vector
			has_rotation = false
		end

		common_data.ext_network:send("action_warp_start", has_sync_pos, sync_pos, has_rotation, sync_yaw)
	end

	ext_mov:enable_update()

	return true
end

function CopActionWarp:update(t)
	local warp_pos, warp_rot = self._warp_pos, self._warp_rot

	if warp_pos or warp_rot then
		--warp the unit if it has dynamic bodies and then wait another frame
		local ext_mov = self._ext_movement

		if warp_pos then
			ext_mov:set_position(warp_pos)

			self._warp_pos = nil
		end

		if warp_rot then
			ext_mov:set_rotation(warp_rot)

			self._warp_rot = nil
		end

		return
	end

	local dynamic_bodies = self._dynamic_bodies

	if dynamic_bodies then
		--restore dynamic bodies again and wait another frame before expiring
		for i = 1, #dynamic_bodies do
			local body = dynamic_bodies[i]

			body:set_dynamic()
		end

		self._dynamic_bodies = nil

		return
	end

	self._expired = true
end
