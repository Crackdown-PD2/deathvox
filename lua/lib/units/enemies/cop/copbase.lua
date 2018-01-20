
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
	self.my_voice = nil
	self.voice_length = 0
	self.voice_start_time = 0
	self:play_voiceline(nil, nil)
end

function CopBase:play_voiceline(buffer, force)
	if buffer then
		if force and self.my_voice and not self.my_voice:is_closed() then
			self.my_voice:stop()
			self.my_voice:close()
			self.my_voice = nil
			self.voice_length = 0
		end
		local _time = math.floor(TimerManager:game():time())
		if self.voice_length == 0 or self.voice_start_time < _time then
			if self.my_voice and not self.my_voice:is_closed() then
				self.my_voice:stop()
				self.my_voice:close()
				self.my_voice = nil
			end
			self.my_voice = XAudio.UnitSource:new(self._unit, buffer)
			self.voice_length = buffer:get_length()
			self.voice_start_time = _time + buffer:get_length()
		end
	end
end