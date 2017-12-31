
if not _G.deathvox then
	_G.deathvox = {}
	_G.deathvox.ModPath = ModPath
	blt.xaudio.setup()
	_G.deathvox.BufferedSounds = {
		grenadier = {
			death = XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/death.ogg"),
			spot_heister = {
				XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/spotted1.ogg"),
				XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/spotted2.ogg"),
				XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/spotted3.ogg"),
				XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/spotted4.ogg")
			},
			use_gas = XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/use_gas.ogg")
		},
		medicdozer = {
			heal = {}
		}
	}
	for i = 1, 31 do
		table.insert(_G.deathvox.BufferedSounds.medicdozer.heal, XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/medicdozer/heal" .. i .. ".ogg"))
	end
end