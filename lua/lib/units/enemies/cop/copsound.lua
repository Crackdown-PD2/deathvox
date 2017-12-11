function CopSound:xaudio_say(sound_name, sync, index_to_use, force)
	if self._unit:base():char_tweak().custom_voicework then
		local voicelines = _G.deathvox.BufferedSounds[self._unit:base():char_tweak().custom_voicework]
		if voicelines and voicelines[sound_name] then
			local fuckshit = voicelines[sound_name]
			local stored_index = math.random(#fuckshit)
			if index_to_use then
				stored_index = index_to_use
			end
			local line_to_use = fuckshit[stored_index]
			self._unit:base():play_voiceline(line_to_use, force)
			if sync then
				self._unit:network():send("xaudio_say", sound_name, stored_index, force)
			end
		end
	end
end