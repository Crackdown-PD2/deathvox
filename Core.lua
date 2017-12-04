if not ModCore then
	log("[ERROR] Unable to find ModCore from BeardLib! Is BeardLib installed correctly?")
	return
end
DeathVox = DeathVox or class(ModCore)

function DeathVox:init()
	self.super.init(self, ModPath .. "config.xml", true, true)
end


if not _G.deathvox then
	local success, err = pcall(function() _G.deathvox = DeathVox:new() end)
	_G.deathvox.ModPath = ModPath
	blt.xaudio.setup()
	_G.deathvox.BufferedSounds = {
		grenadier = {
			death = {XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/death.ogg"), 2},
			spot_heister = {
				{XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/spotted1.ogg"), 2},
				{XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/spotted2.ogg"), 2},
				{XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/spotted3.ogg"), 2},
				{XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/spotted4.ogg"), 2}
			},
			use_gas = {XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/grenadier/use_gas.ogg"), 2}
		},
		medicdozer = {
			heal = {}
		}
	}
	for i = 1, 31 do
		table.insert(_G.deathvox.BufferedSounds.medicdozer.heal, {XAudio.Buffer:new(ModPath .. "assets/oggs/voiceover/medicdozer/heal" .. i .. ".ogg"), 5})
	end
end