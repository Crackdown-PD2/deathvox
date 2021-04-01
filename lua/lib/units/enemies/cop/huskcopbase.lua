local post_init_original = HuskCopBase.post_init
function HuskCopBase:post_init()
	self._allow_invisible = true

	post_init_original(self)

	--[[local spawn_state = nil

	if self._spawn_state then
		if self._spawn_state ~= "" then
			spawn_state = self._spawn_state
		end
	else
		spawn_state = "std/stand/still/idle/look"
	end

	if spawn_state then
		self._ext_movement:play_state(spawn_state)
	end]]
end

function HuskCopBase:pre_destroy(unit)
	UnitBase.pre_destroy(self, unit)

	local headwear = self._headwear_unit

	if alive(headwear) then
		headwear:set_slot(0)
	end

	self._unit:brain():pre_destroy()
	self._ext_movement:pre_destroy()

	local ext_inv = unit:inventory()

	if ext_inv then
		ext_inv:pre_destroy(unit)
	end
end
