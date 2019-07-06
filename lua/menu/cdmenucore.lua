_G.CDmenu = _G.CDmenu or {}
CDmenu._path = ModPath
CDmenu._data_path = SavePath .. 'cdsave.txt'
CDmenu.settings = CDmenu.settings or {
	plrrebal = true
}

function CDmenu:Save()
	local file = io.open(CDmenu._data_path, 'w+')
	if file then
		file:write(json.encode(CDmenu.settings))
		file:close()
	end
end

function CDmenu:Load()
	local file = io.open(CDmenu._data_path, 'r')
	if file then
		for k, v in pairs(json.decode(file:read('*all')) or {}) do
			CDmenu.settings[k] = v
		end
		file:close()
	end
end

CDmenu.Load()
-- generate save data even if nobody ever touches the mod options menu
CDmenu.Save()