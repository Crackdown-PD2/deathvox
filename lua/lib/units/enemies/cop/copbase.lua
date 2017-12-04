function CopBase:init(unit)
	UnitBase.init(self, unit, false)

	self._char_tweak = tweak_data.character[self._tweak_table]
	self._unit = unit
	self._visibility_state = true
	self._foot_obj_map = {
		right = self._unit:get_object(Idstring("RightToeBase")),
		left = self._unit:get_object(Idstring("LeftToeBase"))
	}
	self._is_in_original_material = true
	self._buffs = {}
	self.my_voice = XAudio.Source:new()
	self.voice_length = 0
	self.voice_start_time = 0
	self:play_voiceline(nil, nil)
end

function CopBase:play_voiceline(buffer, length, force)
	if buffer and length then
		local my_pos = self._unit:position()
		self.my_voice:set_position(my_pos)
		if force then
			self.my_voice:stop()
			self.voice_length = 0
		end
		local _time = math.floor(TimerManager:game():time())
		if self.voice_length == 0 or self.voice_start_time < _time then
			self.my_voice:stop()
			self.my_voice:set_buffer(buffer)
			self.my_voice:play()
			self.voice_length = length
			self.voice_start_time = _time + length
		end
	end
end