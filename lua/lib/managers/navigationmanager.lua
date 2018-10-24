function NavigationManager:reserve_cover(cover, filter)
	local reserved = cover[self.COVER_RESERVED]

	if reserved then
		cover[self.COVER_RESERVED] = reserved + 1
	else
		cover[self.COVER_RESERVED] = 1
		local reservation = {
			radius = 100, --The holy grail of all weirdness, maybe?
			position = cover[1],
			filter = filter
		}
		cover[self.COVER_RESERVATION] = reservation

		self:add_pos_reservation(reservation)
	end
end