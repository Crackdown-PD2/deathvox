local alive_g = alive
local pairs_g = pairs

function VehicleDrivingExt:update(unit, t, dt)
	self:_manage_position_reservation()

	if Network:is_server() then
		if self._vehicle:is_active() then
			self:drop_loot()
		end

		self:_catch_loot()
	end

	for _, seat in pairs_g(self._seats) do
		local is_ai = alive_g(seat.occupant) and seat.occupant:brain() ~= nil

		if is_ai then
			if seat.occupant:character_damage():is_downed() then
				self:_evacuate_seat(seat)
			else
				local pos = seat.third_object:position()
				local rot = seat.third_object:rotation()

				seat.occupant:movement():set_m_pos(pos)
				seat.occupant:movement():set_m_rot(rot)
			end
		end
	end

	self._current_state:update(t, dt)
end

function VehicleDrivingExt:on_drive_SO_failed(seat, unit)
	local so_data = seat.drive_SO_data

	if not so_data then
		return
	end

	if unit ~= so_data.unit then
		return
	end

	if alive_g(unit) then
		local mov_ext = unit:movement()

		mov_ext.vehicle_unit = nil
		mov_ext.vehicle_seat = nil
	end

	seat.drive_SO_data = nil

	self:_create_seat_SO(seat)
end

function VehicleDrivingExt:_unregister_drive_SO(seat)
	local so_data = seat.drive_SO_data

	if not so_data then
		return
	end

	seat.drive_SO_data = nil

	if so_data.SO_registered then
		managers.groupai:state():remove_special_objective(so_data.SO_id)
	end

	local bot_unit = so_data.unit

	if not alive_g(bot_unit) then
		return
	end

	local mov_ext = bot_unit:movement()

	mov_ext.vehicle_unit = nil
	mov_ext.vehicle_seat = nil

	bot_unit:brain():set_objective(nil)
end
