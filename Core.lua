local _G = _G
local io = io
local file = file

if not _G.deathvox then
	_G.deathvox = {}
	_G.deathvox.ModPath = ModPath
	blt.xaudio.setup()
	local deathvox_mod_instance = ModInstance
	log("==============Loading Crackdown Assets==============")
	log("Loading Crackdown Cops")
	deathvox_mod_instance:GetSuperMod():GetAssetLoader():LoadAssetGroup("cops")
	log("Loading SWAT Cops")
	deathvox_mod_instance:GetSuperMod():GetAssetLoader():LoadAssetGroup("copcops")
	log("Loading FBI Cops")
	deathvox_mod_instance:GetSuperMod():GetAssetLoader():LoadAssetGroup("fbicops")
	log("Loading Gensec Cops")
	deathvox_mod_instance:GetSuperMod():GetAssetLoader():LoadAssetGroup("genseccops")
	log("Loading Classic Cops")
	deathvox_mod_instance:GetSuperMod():GetAssetLoader():LoadAssetGroup("classiccops")
    log("Loading Skirmish edit instance")
    deathvox_mod_instance:GetSuperMod():GetAssetLoader():LoadAssetGroup("skirmishedit")
	--log("Loading Murkywater Units") uncomment to load murkywater assets. does nothing currently, as there's no assets yet.
	--deathvox_mod_instance:GetSuperMod():GetAssetLoader():LoadAssetGroup("murkywater")	
	log("Finished loading!")
	if _G.voiceline_framework then
		_G.voiceline_framework:register_unit("grenadier")
		local fuck =  Application:nice_path( "./" .. ModPath .. "assets/oggs/voiceover/grenadier", true )
		for index, directory in pairs(file.GetDirectories(fuck)) do
			local ass = Application:nice_path( "./" .. ModPath .. "assets/oggs/voiceover/grenadier/" .. directory, true )
			_G.voiceline_framework.register_line_type("go fuck yourself lua", "grenadier", tostring(directory))
			for index2, filez in pairs(file.GetFiles(ass)) do
				_G.voiceline_framework:register_voiceline("grenadier", tostring(directory), ModPath .. "assets/oggs/voiceover/grenadier/" .. tostring(directory) .. "/" .. tostring(filez))
			end
		end
		
		--[[_G.voiceline_framework:register_unit("pdth")
		local fuck =  Application:nice_path( "./" .. ModPath .. "assets/oggs/voiceover/pdth", true )
		for index, directory in pairs(file.GetDirectories(fuck)) do
			local ass = Application:nice_path( "./" .. ModPath .. "assets/oggs/voiceover/pdth/" .. directory, true )
			_G.voiceline_framework.register_line_type("go fuck yourself lua", "pdth", tostring(directory))
			for index2, filez in pairs(file.GetFiles(ass)) do
				_G.voiceline_framework:register_voiceline("pdth", tostring(directory), ModPath .. "assets/oggs/voiceover/pdth/" .. tostring(directory) .. "/" .. tostring(filez))
			end
		end
		
		_G.voiceline_framework:register_unit("pdthdozer")
		local fuck =  Application:nice_path( "./" .. ModPath .. "assets/oggs/voiceover/pdthdozer", true )
		for index, directory in pairs(file.GetDirectories(fuck)) do
			local ass = Application:nice_path( "./" .. ModPath .. "assets/oggs/voiceover/pdthdozer/" .. directory, true )
			_G.voiceline_framework.register_line_type("go fuck yourself lua", "pdthdozer", tostring(directory))
			for index2, filez in pairs(file.GetFiles(ass)) do
				_G.voiceline_framework:register_voiceline("pdthdozer", tostring(directory), ModPath .. "assets/oggs/voiceover/pdthdozer/" .. tostring(directory) .. "/" .. tostring(filez))
			end
		end
		
		_G.voiceline_framework:register_unit("medicdozer")
		_G.voiceline_framework:register_line_type("medicdozer", "heal")
		for i = 1, 31 do
			_G.voiceline_framework:register_voiceline("medicdozer", "heal", ModPath .. "assets/oggs/voiceover/medicdozer/heal" .. i .. ".ogg")
		end]]--
		_G.deathvox.grenadier_gas_duration = 15
	else
		
	end
end