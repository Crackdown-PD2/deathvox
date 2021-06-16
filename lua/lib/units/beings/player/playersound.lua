Hooks:PostHook(PlayerSound, "init" , "init_whiz_by_sources" , function(self)
	self:_init_whiz_by_sources()
end)

Hooks:PreHook(PlayerSound, "destroy" , "destroy_whiz_by_sources" , function(self)
	self:_destroy_whiz_by_sources()
end)

local nr_whiz_by_sound_sources = 30

function PlayerSound:_init_whiz_by_sources()
	if not self._unit:base().is_local_player then
		return
	end

	local whiz_by_sounds = {
		index = 1
	}

	local sources = {}
	local source_str = "whizby"
	local sound_device = SoundDevice
	local create_source_f = sound_device.create_source

	for i = 1, nr_whiz_by_sound_sources do
		sources[i] = create_source_f(sound_device, source_str .. i)
	end

	whiz_by_sounds.max_index = #sources
	whiz_by_sounds.sources = sources

	self._whiz_by_sounds = whiz_by_sounds
end

function PlayerSound:_get_whiz_by_source()
	local whiz_by_sounds = self._whiz_by_sounds
	local cur_index = whiz_by_sounds.index
	local source = whiz_by_sounds.sources[cur_index]

	whiz_by_sounds.index = cur_index < whiz_by_sounds.max_index and cur_index + 1 or 1

	return source
end

function PlayerSound:_destroy_whiz_by_sources()
	local whiz_by_sounds = self._whiz_by_sounds

	if not whiz_by_sounds then
		return
	end

	local sources = whiz_by_sounds.sources

	for i = 1, whiz_by_sounds.max_index do
		local source = sources[i]

		source:stop()
		source:delete()
	end

	self._whiz_by_sounds = nil
end

function PlayerSound:play_whizby(params)
	local sound_source = self:_get_whiz_by_source()

	sound_source:stop()
	sound_source:set_position(params.position)
	sound_source:post_event(params.event or "bullet_whizby_medium")
end
