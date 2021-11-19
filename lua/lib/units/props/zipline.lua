local math_up = math.UP

function ZipLine:attach_bag(bag)
	self._booked_bag_peer_id = nil
	self._attached_bag = bag

	local carry_id = bag:carry_data():carry_id()
	self._attached_bag_offset = tweak_data.carry:get_zipline_offset(carry_id)

	local link_body = bag:body("hinge_body_1") or bag:body(0)
	link_body:set_keyframed()

	local nr_bodies = bag:num_bodies()
	local disabled_collisions = {} --, dynamic_bodies = {}, {}

	for i_body = 0, nr_bodies - 1 do
		local body = bag:body(i_body)

		if body:collisions_enabled() then
			body:set_collisions_enabled(false)

			disabled_collisions[#disabled_collisions + 1] = body
		end

		--[[if body:dynamic() then
			body:set_keyframed()

			dynamic_bodies[#dynamic_bodies + 1] = body
		end]]
	end

	self._bag_disabled_collisions = disabled_collisions
	--self._bag_dynamic_bodies = dynamic_bodies

	bag:set_rotation(Rotation(self._line_data.dir_s, math_up))
	bag:carry_data():set_zipline_unit(self._unit)
	self:_check_interaction_active_state()
	self:run_sequence("on_attached_bag", bag)
end

function ZipLine:release_bag()
	local bag = self._attached_bag
	local link_body = bag:body("hinge_body_1") or bag:body(0)

	link_body:set_dynamic()

	local disabled_collisions = self._bag_disabled_collisions

	if disabled_collisions then
		for i = 1, #disabled_collisions do
			local body = disabled_collisions[i]

			body:set_collisions_enabled(true)
		end

		self._bag_disabled_collisions = nil
	end

	--[[local dynamic_bodies = self._bag_dynamic_bodies

	if dynamic_bodies then
		for i = 1, #dynamic_bodies do
			local body = dynamic_bodies[i]

			body:set_dynamic()
		end

		self._bag_dynamic_bodies = nil
	end]]

	bag:carry_data():set_zipline_unit(nil)
	self:run_sequence("on_detached_bag", bag)

	self._attached_bag = nil
end