Hooks:Add('LocalizationManagerPostInit', 'cdmenu_wordswordswords', function(loc)
	CDmenu:Load()
	loc:load_localization_file(CDmenu._path .. 'lua/menu/cdmenu_en.txt', false)
end)

Hooks:Add('MenuManagerInitialize', 'cdmenu_init', function(self)

	MenuCallbackHandler.CDsave = function(this, item)
		CDmenu:Save()
	end

	MenuCallbackHandler.CDcb_donothing = function(this, item)
		-- do nothing
	end

	MenuCallbackHandler.CDcb_plrrebal = function(this, item)
		CDmenu.settings[item:name()] = item:value() == 'on'
		CDmenu:Save()
	end

	CDmenu:Load()
	MenuHelper:LoadFromJsonFile(CDmenu._path .. 'lua/menu/cdmenu.txt', CDmenu, CDmenu.settings)
end)