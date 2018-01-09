if not _G.deathvox then
	_G.deathvox = {}
	_G.deathvox.ModPath = ModPath
	blt.xaudio.setup()
	_G.deathvox.BufferedSounds = {
		grenadier = {
			death = {
				XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/grenadier_death1.ogg"),
				XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/grenadier_death2.ogg"),
				XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/grenadier_death3.ogg"),
				XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/grenadier_death4.ogg")
			},
			spawn = {
				XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/grenadier_spawn1.ogg"),
				XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/grenadier_spawn2.ogg"),
				XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/grenadier_spawn3.ogg")
			},
			spot_heister = {
				XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/grenadier_contact3.ogg"),
				XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/grenadier_contact2.ogg"),
				XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/grenadier_contact1.ogg")
			},
			use_gas = {
				XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/grenadier_gas_1.ogg"),
				XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/grenadier_gas_2.ogg"),
				XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/grenadier_gas_3.ogg"),
				XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/grenadier_gas_4.ogg")
			}
		},
		medicdozer = {
			heal = {}
		}
	}
	_G.deathvox.grenadier_gas_duration = 15
	for i = 1, 31 do
		table.insert(_G.deathvox.BufferedSounds.medicdozer.heal, XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/medicdozer/heal" .. i .. ".ogg"))
	end
end