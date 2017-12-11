function UnitNetworkHandler:xaudio_say(unit, sound_name, stored_index, force, sender)
	if not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end
	log("XAudio: " .. sound_name)
	log("XAudio: " .. stored_index)
	log("XAudio: " .. force)

	unit:sound():xaudio_say(sound_name, false, stored_index, force)
end