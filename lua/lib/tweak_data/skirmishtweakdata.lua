function SkirmishTweakData:_init_special_unit_spawn_limits()
	self.spawn_limit_to_use = {
		tank = 1,
		taser = 3,
		boom = 0,
		spooc = 3,
		shield = 4,
		medic = 4,
	}
	self.special_unit_spawn_limits = {
		deep_clone(self.spawn_limit_to_use),
		deep_clone(self.spawn_limit_to_use),
		deep_clone(self.spawn_limit_to_use),
		deep_clone(self.spawn_limit_to_use),
		deep_clone(self.spawn_limit_to_use),
		deep_clone(self.spawn_limit_to_use),
		deep_clone(self.spawn_limit_to_use),
		deep_clone(self.spawn_limit_to_use),
		deep_clone(self.spawn_limit_to_use)
	}
end

function SkirmishTweakData:_init_wave_phase_durations(tweak_data)
	local skirmish_data = tweak_data.group_ai.skirmish
	skirmish_data.assault.anticipation_duration = {{
		15,
		1
	}}
	skirmish_data.assault.build_duration = 30
	-- functionally, designed to be infinite and make players deplete assault pool
	skirmish_data.assault.sustain_duration_min = {
		1500,
		1500,
		1500
	}
	skirmish_data.assault.sustain_duration_max = {
		1500,
		1500,
		1500
	}
	skirmish_data.assault.sustain_duration_balance_mul = {
		1,
		1,
		1,
		1
	}
	skirmish_data.assault.fade_duration = 10
	skirmish_data.assault.delay = {
		20,
		20,
		20
	}
end

function SkirmishTweakData:_init_wave_modifiers()
	self.wave_modifiers = {}
	--self.wave_modifiers[1] = {{class = "ModifierCloakerArrest"}}
	--self.wave_modifiers[3] = {{class = "ModifierSkulldozers"}} TODO: Introduce skulldozers
	--[[
	self.wave_modifiers[5] = {{
		class = "ModifierHeavySniper",
		data = {spawn_chance = 5}
	}}
	]]--

	--self.wave_modifiers[7] = {{class = "ModifierDozerMedic"}}  TODO: Introduce medicdozer units 
	--self.wave_modifiers[9] = {{class = "ModifierDozerMinigun"}} TODO: Introduce grenadiers
end

function SkirmishTweakData:_init_spawn_group_weights(tweak_data)  -- Everything about this setup is really nice and I like it a lot. I need to integrate some of this into the core CD groupAI stuff.
	local nice_human_readable_table = {
		{ -- wave 1 beat police
		-- Effectively brief warm-up. beat, shield, medic, rookies.
		-- Beat intro. beat, shield, medic, rookies. NORMAL.
		1, -- #1A two rookie
		1, -- #1B revolver/two pistol
		1, -- #1C smg/two pistol
		1, -- #1D shot/two smg
		1, -- #1E revolver/medic
		1, -- #1F rookie/medic
		1, -- #1G shield/shot
		0, -- #2A one Lshot/3 LAR
		0, -- #2B one Shield/2 HAR
		0, -- #2C one Taser/2 HAR
		0, -- #2D one Taser/2 Hshot
		0, -- #2E one Shield/2 LAR
		0, -- #2F three LAR/1 Medic
		0, -- #2G 2 HRT/1 Medic
		0, -- #2H one Taser/2 HRT
		0, -- #3A two HAR/2 LAR
		0, -- #3B two Lshot/1 Medic/1 LAR
		0, -- #3C two Hshot/2 LAR
		0, -- #3D one Shield/3 LAR
		0, -- #3E two Shield/2 HAR
		0, -- #3F two Taser/2 LAR
		0, -- #3G one Gdozer
		0, -- #3H two cloaker
		0, -- #3I one taser/two HRT
		0, -- #4A two HAR/2 LAR
		0, -- #4B two HAR/1 Medic/1 LAR
		0, -- #4C two Hshot/2 Lshot
		0, -- #4D two Shield/1 Medic/ 1 Lshot
		0, -- #4E two Shield/2 Lshot
		0, -- #4F two Taser/2 LAR
		0, -- #4G one Shield/1 Gdozer
		0, -- #4H one Shield/1 Bdozer
		0, -- #4I two cloaker
		0, -- #4J one taser/two HRT
		0, -- #5A one Hshot/2 Lshot/1 LAR
		0, -- #5B one Hshot/2 Lshot/1 Medic
		0, -- #5C two HAR/2 LAR
		0, -- #5D two HAR/1 LAR/1 Medic
		0, -- #5E one Wdozer
		0, -- #5F one shield/1 Bdozer/1 Medic
		0, -- #5G one shield/1 Gdozer/1 Medic
		0, -- #5H one Gdozer/1 Bdozer
		0, -- #5I two tasers
		0, -- #5J two cloakers
		0, -- #5K two veterans/2 Medics
		0, -- #6A two Hshot/2 LAR
		0, -- #6B two HAR/1 LAR/1 Medic
		0, -- #6C one Hshot/1 Lshot/1 LAR
		0, -- #6D one Hshot/1 Lshot/1 Medic
		0, -- #6E two Shield/1 taser/1 Medic
		0, -- #6F two tasers/1 cloaker
		0, -- #6G three cloakers
		0, -- #6H one Bdozer/1 Taser
		0, -- #6I one Shield/1 Wdozer/1 Medic
		0, -- #6J one Gdozer/1 Medic/1 Cloaker
		0, -- #6K two HRT/one veteran
		0, -- #7A two Hshot/2 LAR
		0, -- #7B one Hshot/2 Lshot/1 LAR
		0, -- #7C two HAR/2 LAR
		0, -- #7D two HAR/1 LAR/1 Medic
		0, -- #7E two taser/1 Medic
		0, -- #7F one tazer/1 Bdozer/1 Medic/1 cloaker
		0, -- #7G one Bdozer/1 Medicdozer
		0, -- #7H one Shield/1 Gdozer/1 Medic
		0, -- #7I three shield/1 Wdozer
		0, -- #7J four cloakers
		0, -- #7K two veterans/2 Taser
		},
		
		{ -- wave 2 swat
		-- SWAT sig raise term. Swat, shield, medic, taser. Add HRT. HARD.
		0, -- #1A two rookie
		0, -- #1B revolver/two pistol
		0, -- #1C smg/two pistol
		0, -- #1D shot/two smg
		0, -- #1E revolver/medic
		0, -- #1F rookie/medic
		0, -- #1G shield/shot
		1, -- #2A one Lshot/3 LAR
		1, -- #2B one Shield/2 HAR
		1, -- #2C one Taser/2 HAR
		1, -- #2D one Taser/2 Hshot
		1, -- #2E one Shield/2 LAR
		1, -- #2F three LAR/1 Medic
		1, -- #2G 2 HRT/1 Medic
		1, -- #2H one Taser/2 HRT
		0, -- #3A two HAR/2 LAR
		0, -- #3B two Lshot/1 Medic/1 LAR
		0, -- #3C two Hshot/2 LAR
		0, -- #3D one Shield/3 LAR
		0, -- #3E two Shield/2 HAR
		0, -- #3F two Taser/2 LAR
		0, -- #3G one Gdozer
		0, -- #3H two cloaker
		0, -- #3I one taser/two HRT
		0, -- #4A two HAR/2 LAR
		0, -- #4B two HAR/1 Medic/1 LAR
		0, -- #4C two Hshot/2 Lshot
		0, -- #4D two Shield/1 Medic/ 1 Lshot
		0, -- #4E two Shield/2 Lshot
		0, -- #4F two Taser/2 LAR
		0, -- #4G one Shield/1 Gdozer
		0, -- #4H one Shield/1 Bdozer
		0, -- #4I two cloaker
		0, -- #4J one taser/two HRT
		0, -- #5A one Hshot/2 Lshot/1 LAR
		0, -- #5B one Hshot/2 Lshot/1 Medic
		0, -- #5C two HAR/2 LAR
		0, -- #5D two HAR/1 LAR/1 Medic
		0, -- #5E one Wdozer
		0, -- #5F one shield/1 Bdozer/1 Medic
		0, -- #5G one shield/1 Gdozer/1 Medic
		0, -- #5H one Gdozer/1 Bdozer
		0, -- #5I two tasers
		0, -- #5J two cloakers
		0, -- #5K two veterans/2 Medics
		0, -- #6A two Hshot/2 LAR
		0, -- #6B two HAR/1 LAR/1 Medic
		0, -- #6C one Hshot/1 Lshot/1 LAR
		0, -- #6D one Hshot/1 Lshot/1 Medic
		0, -- #6E two Shield/1 taser/1 Medic
		0, -- #6F two tasers/1 cloaker
		0, -- #6G three cloakers
		0, -- #6H one Bdozer/1 Taser
		0, -- #6I one Shield/1 Wdozer/1 Medic
		0, -- #6J one Gdozer/1 Medic/1 Cloaker
		0, -- #6K two HRT/one veteran
		0, -- #7A two Hshot/2 LAR
		0, -- #7B one Hshot/2 Lshot/1 LAR
		0, -- #7C two HAR/2 LAR
		0, -- #7D two HAR/1 LAR/1 Medic
		0, -- #7E two taser/1 Medic
		0, -- #7F one tazer/1 Bdozer/1 Medic/1 cloaker
		0, -- #7G one Bdozer/1 Medicdozer
		0, -- #7H one Shield/1 Gdozer/1 Medic
		0, -- #7I three shield/1 Wdozer
		0, -- #7J four cloakers
		0, -- #7K two veterans/2 Taser
		},
		
		{ -- wave 3 FBI
		-- FBI warmup. FBI, medics, shields, dozer, HRT. VERY HARD.
		0, -- #1A two rookie
		0, -- #1B revolver/two pistol
		0, -- #1C smg/two pistol
		0, -- #1D shot/two smg
		0, -- #1E revolver/medic
		0, -- #1F rookie/medic
		0, -- #1G shield/shot
		0, -- #2A one Lshot/3 LAR
		0, -- #2B one Shield/2 HAR
		0, -- #2C one Taser/2 HAR
		0, -- #2D one Taser/2 Hshot
		0, -- #2E one Shield/2 LAR
		0, -- #2F three LAR/1 Medic
		0, -- #2G 2 HRT/1 Medic
		0, -- #2H one Taser/2 HRT
		1, -- #3A two HAR/2 LAR
		1, -- #3B two Lshot/1 Medic/1 LAR
		1, -- #3C two Hshot/2 LAR
		1, -- #3D one Shield/3 LAR
		1, -- #3E two Shield/2 HAR
		1, -- #3F two Taser/2 LAR
		1, -- #3G one Gdozer
		1, -- #3H two cloaker
		1, -- #3I one taser/two HRT
		0, -- #4A two HAR/2 LAR
		0, -- #4B two HAR/1 Medic/1 LAR
		0, -- #4C two Hshot/2 Lshot
		0, -- #4D two Shield/1 Medic/ 1 Lshot
		0, -- #4E two Shield/2 Lshot
		0, -- #4F two Taser/2 LAR
		0, -- #4G one Shield/1 Gdozer
		0, -- #4H one Shield/1 Bdozer
		0, -- #4I two cloaker
		0, -- #4J one taser/two HRT
		0, -- #5A one Hshot/2 Lshot/1 LAR
		0, -- #5B one Hshot/2 Lshot/1 Medic
		0, -- #5C two HAR/2 LAR
		0, -- #5D two HAR/1 LAR/1 Medic
		0, -- #5E one Wdozer
		0, -- #5F one shield/1 Bdozer/1 Medic
		0, -- #5G one shield/1 Gdozer/1 Medic
		0, -- #5H one Gdozer/1 Bdozer
		0, -- #5I two tasers
		0, -- #5J two cloakers
		0, -- #5K two veterans/2 Medics
		0, -- #6A two Hshot/2 LAR
		0, -- #6B two HAR/1 LAR/1 Medic
		0, -- #6C one Hshot/1 Lshot/1 LAR
		0, -- #6D one Hshot/1 Lshot/1 Medic
		0, -- #6E two Shield/1 taser/1 Medic
		0, -- #6F two tasers/1 cloaker
		0, -- #6G three cloakers
		0, -- #6H one Bdozer/1 Taser
		0, -- #6I one Shield/1 Wdozer/1 Medic
		0, -- #6J one Gdozer/1 Medic/1 Cloaker
		0, -- #6K two HRT/one veteran
		0, -- #7A two Hshot/2 LAR
		0, -- #7B one Hshot/2 Lshot/1 LAR
		0, -- #7C two HAR/2 LAR
		0, -- #7D two HAR/1 LAR/1 Medic
		0, -- #7E two taser/1 Medic
		0, -- #7F one tazer/1 Bdozer/1 Medic/1 cloaker
		0, -- #7G one Bdozer/1 Medicdozer
		0, -- #7H one Shield/1 Gdozer/1 Medic
		0, -- #7I three shield/1 Wdozer
		0, -- #7J four cloakers
		0, -- #7K two veterans/2 Taser
		},
		
		{ -- wave 4 FBI.
		 -- FBI warmup over. FBI, medics, shields, dozers, HRT. Add cloaker. OVERKILL.
		0, -- #1A two rookie
		0, -- #1B revolver/two pistol
		0, -- #1C smg/two pistol
		0, -- #1D shot/two smg
		0, -- #1E revolver/medic
		0, -- #1F rookie/medic
		0, -- #1G shield/shot
		0, -- #2A one Lshot/3 LAR
		0, -- #2B one Shield/2 HAR
		0, -- #2C one Taser/2 HAR
		0, -- #2D one Taser/2 Hshot
		0, -- #2E one Shield/2 LAR
		0, -- #2F three LAR/1 Medic
		0, -- #2G 2 HRT/1 Medic
		0, -- #2H one Taser/2 HRT
		0, -- #3A two HAR/2 LAR
		0, -- #3B two Lshot/1 Medic/1 LAR
		0, -- #3C two Hshot/2 LAR
		0, -- #3D one Shield/3 LAR
		0, -- #3E two Shield/2 HAR
		0, -- #3F two Taser/2 LAR
		0, -- #3G one Gdozer
		0, -- #3H two cloaker
		0, -- #3I one taser/two HRT
		1, -- #4A two HAR/2 LAR
		1, -- #4B two HAR/1 Medic/1 LAR
		1, -- #4C two Hshot/2 Lshot
		1, -- #4D two Shield/1 Medic/ 1 Lshot
		1, -- #4E two Shield/2 Lshot
		1, -- #4F two Taser/2 LAR
		1, -- #4G one Shield/1 Gdozer
		1, -- #4H one Shield/1 Bdozer
		1, -- #4I two cloaker
		1, -- #4J one taser/two HRT
		0, -- #5A one Hshot/2 Lshot/1 LAR
		0, -- #5B one Hshot/2 Lshot/1 Medic
		0, -- #5C two HAR/2 LAR
		0, -- #5D two HAR/1 LAR/1 Medic
		0, -- #5E one Wdozer
		0, -- #5F one shield/1 Bdozer/1 Medic
		0, -- #5G one shield/1 Gdozer/1 Medic
		0, -- #5H one Gdozer/1 Bdozer
		0, -- #5I two tasers
		0, -- #5J two cloakers
		0, -- #5K two veterans/2 Medics
		0, -- #6A two Hshot/2 LAR
		0, -- #6B two HAR/1 LAR/1 Medic
		0, -- #6C one Hshot/1 Lshot/1 LAR
		0, -- #6D one Hshot/1 Lshot/1 Medic
		0, -- #6E two Shield/1 taser/1 Medic
		0, -- #6F two tasers/1 cloaker
		0, -- #6G three cloakers
		0, -- #6H one Bdozer/1 Taser
		0, -- #6I one Shield/1 Wdozer/1 Medic
		0, -- #6J one Gdozer/1 Medic/1 Cloaker
		0, -- #6K two HRT/one veteran
		0, -- #7A two Hshot/2 LAR
		0, -- #7B one Hshot/2 Lshot/1 LAR
		0, -- #7C two HAR/2 LAR
		0, -- #7D two HAR/1 LAR/1 Medic
		0, -- #7E two taser/1 Medic
		0, -- #7F one tazer/1 Bdozer/1 Medic/1 cloaker
		0, -- #7G one Bdozer/1 Medicdozer
		0, -- #7H one Shield/1 Gdozer/1 Medic
		0, -- #7I three shield/1 Wdozer
		0, -- #7J four cloakers
		0, -- #7K two veterans/2 Taser
		},
		
		{ -- wave 5 FBI.
		0, -- #1A two rookie
		0, -- #1B revolver/two pistol
		0, -- #1C smg/two pistol
		0, -- #1D shot/two smg
		0, -- #1E revolver/medic
		0, -- #1F rookie/medic
		0, -- #1G shield/shot
		0, -- #2A one Lshot/3 LAR
		0, -- #2B one Shield/2 HAR
		0, -- #2C one Taser/2 HAR
		0, -- #2D one Taser/2 Hshot
		0, -- #2E one Shield/2 LAR
		0, -- #2F three LAR/1 Medic
		0, -- #2G 2 HRT/1 Medic
		0, -- #2H one Taser/2 HRT
		0, -- #3A two HAR/2 LAR
		0, -- #3B two Lshot/1 Medic/1 LAR
		0, -- #3C two Hshot/2 LAR
		0, -- #3D one Shield/3 LAR
		0, -- #3E two Shield/2 HAR
		0, -- #3F two Taser/2 LAR
		0, -- #3G one Gdozer
		0, -- #3H two cloaker
		0, -- #3I one taser/two HRT
		0, -- #4A two HAR/2 LAR
		1, -- #4B two HAR/1 Medic/1 LAR
		1, -- #4C two Hshot/2 Lshot
		1, -- #4D two Shield/1 Medic/ 1 Lshot
		1, -- #4E two Shield/2 Lshot
		1, -- #4F two Taser/2 LAR
		1, -- #4G one Shield/1 Gdozer
		1, -- #4H one Shield/1 Bdozer
		1, -- #4I two cloaker
		0, -- #4J one taser/two HRT
		1, -- #5A one Hshot/2 Lshot/1 LAR
		0, -- #5B one Hshot/2 Lshot/1 Medic
		0, -- #5C two HAR/2 LAR
		0, -- #5D two HAR/1 LAR/1 Medic
		0, -- #5E one Wdozer
		1, -- #5F one shield/1 Bdozer/1 Medic
		0, -- #5G one shield/1 Gdozer/1 Medic
		0, -- #5H one Gdozer/1 Bdozer
		0, -- #5I two tasers
		0, -- #5J two cloakers
		0, -- #5K two veterans/2 Medics
		0, -- #6A two Hshot/2 LAR
		0, -- #6B two HAR/1 LAR/1 Medic
		0, -- #6C one Hshot/1 Lshot/1 LAR
		0, -- #6D one Hshot/1 Lshot/1 Medic
		0, -- #6E two Shield/1 taser/1 Medic
		0, -- #6F two tasers/1 cloaker
		0, -- #6G three cloakers
		0, -- #6H one Bdozer/1 Taser
		0, -- #6I one Shield/1 Wdozer/1 Medic
		0, -- #6J one Gdozer/1 Medic/1 Cloaker
		0, -- #6K two HRT/one veteran
		0, -- #7A two Hshot/2 LAR
		0, -- #7B one Hshot/2 Lshot/1 LAR
		0, -- #7C two HAR/2 LAR
		0, -- #7D two HAR/1 LAR/1 Medic
		0, -- #7E two taser/1 Medic
		0, -- #7F one tazer/1 Bdozer/1 Medic/1 cloaker
		0, -- #7G one Bdozer/1 Medicdozer
		0, -- #7H one Shield/1 Gdozer/1 Medic
		0, -- #7I three shield/1 Wdozer
		0, -- #7J four cloakers
		0, -- #7K two veterans/2 Taser
		},
		
		{ -- wave 6 Gensec.
		  -- Gensec. Gensecs, dozers, cloakers, medics, shields. Add Veterans. MAYHEM.
		0, -- #1A two rookie
		0, -- #1B revolver/two pistol
		0, -- #1C smg/two pistol
		0, -- #1D shot/two smg
		0, -- #1E revolver/medic
		0, -- #1F rookie/medic
		0, -- #1G shield/shot
		0, -- #2A one Lshot/3 LAR
		0, -- #2B one Shield/2 HAR
		0, -- #2C one Taser/2 HAR
		0, -- #2D one Taser/2 Hshot
		0, -- #2E one Shield/2 LAR
		0, -- #2F three LAR/1 Medic
		0, -- #2G 2 HRT/1 Medic
		0, -- #2H one Taser/2 HRT
		0, -- #3A two HAR/2 LAR
		0, -- #3B two Lshot/1 Medic/1 LAR
		0, -- #3C two Hshot/2 LAR
		0, -- #3D one Shield/3 LAR
		0, -- #3E two Shield/2 HAR
		0, -- #3F two Taser/2 LAR
		0, -- #3G one Gdozer
		0, -- #3H two cloaker
		0, -- #3I one taser/two HRT
		0, -- #4A two HAR/2 LAR
		0, -- #4B two HAR/1 Medic/1 LAR
		0, -- #4C two Hshot/2 Lshot
		0, -- #4D two Shield/1 Medic/ 1 Lshot
		0, -- #4E two Shield/2 Lshot
		0, -- #4F two Taser/2 LAR
		0, -- #4G one Shield/1 Gdozer
		0, -- #4H one Shield/1 Bdozer
		0, -- #4I two cloaker
		0, -- #4J one taser/two HRT
		1, -- #5A one Hshot/2 Lshot/1 LAR
		1, -- #5B one Hshot/2 Lshot/1 Medic
		1, -- #5C two HAR/2 LAR
		1, -- #5D two HAR/1 LAR/1 Medic
		1, -- #5E one Wdozer
		1, -- #5F one shield/1 Bdozer/1 Medic
		1, -- #5G one shield/1 Gdozer/1 Medic
		1, -- #5H one Gdozer/1 Bdozer
		1, -- #5I two tasers
		1, -- #5J two cloakers
		1, -- #5K two veterans/2 Medics
		0, -- #6A two Hshot/2 LAR
		0, -- #6B two HAR/1 LAR/1 Medic
		0, -- #6C one Hshot/1 Lshot/1 LAR
		0, -- #6D one Hshot/1 Lshot/1 Medic
		0, -- #6E two Shield/1 taser/1 Medic
		0, -- #6F two tasers/1 cloaker
		0, -- #6G three cloakers
		0, -- #6H one Bdozer/1 Taser
		0, -- #6I one Shield/1 Wdozer/1 Medic
		0, -- #6J one Gdozer/1 Medic/1 Cloaker
		0, -- #6K two HRT/one veteran
		0, -- #7A two Hshot/2 LAR
		0, -- #7B one Hshot/2 Lshot/1 LAR
		0, -- #7C two HAR/2 LAR
		0, -- #7D two HAR/1 LAR/1 Medic
		0, -- #7E two taser/1 Medic
		0, -- #7F one tazer/1 Bdozer/1 Medic/1 cloaker
		0, -- #7G one Bdozer/1 Medicdozer
		0, -- #7H one Shield/1 Gdozer/1 Medic
		0, -- #7I three shield/1 Wdozer
		0, -- #7J four cloakers
		0, -- #7K two veterans/2 Taser
		},
		
		{ -- wave 7 Gensec.
		  -- Gensec. Full range of units, intensified distro of normals. DEATH WISH.
		0, -- #1A two rookie
		0, -- #1B revolver/two pistol
		0, -- #1C smg/two pistol
		0, -- #1D shot/two smg
		0, -- #1E revolver/medic
		0, -- #1F rookie/medic
		0, -- #1G shield/shot
		0, -- #2A one Lshot/3 LAR
		0, -- #2B one Shield/2 HAR
		0, -- #2C one Taser/2 HAR
		0, -- #2D one Taser/2 Hshot
		0, -- #2E one Shield/2 LAR
		0, -- #2F three LAR/1 Medic
		0, -- #2G 2 HRT/1 Medic
		0, -- #2H one Taser/2 HRT
		0, -- #3A two HAR/2 LAR
		0, -- #3B two Lshot/1 Medic/1 LAR
		0, -- #3C two Hshot/2 LAR
		0, -- #3D one Shield/3 LAR
		0, -- #3E two Shield/2 HAR
		0, -- #3F two Taser/2 LAR
		0, -- #3G one Gdozer
		0, -- #3H two cloaker
		0, -- #3I one taser/two HRT
		0, -- #4A two HAR/2 LAR
		0, -- #4B two HAR/1 Medic/1 LAR
		0, -- #4C two Hshot/2 Lshot
		0, -- #4D two Shield/1 Medic/ 1 Lshot
		0, -- #4E two Shield/2 Lshot
		0, -- #4F two Taser/2 LAR
		0, -- #4G one Shield/1 Gdozer
		0, -- #4H one Shield/1 Bdozer
		0, -- #4I two cloaker
		0, -- #4J one taser/two HRT
		0, -- #5A one Hshot/2 Lshot/1 LAR
		0, -- #5B one Hshot/2 Lshot/1 Medic
		0, -- #5C two HAR/2 LAR
		0, -- #5D two HAR/1 LAR/1 Medic
		0, -- #5E one Wdozer
		0, -- #5F one shield/1 Bdozer/1 Medic
		0, -- #5G one shield/1 Gdozer/1 Medic
		0, -- #5H one Gdozer/1 Bdozer
		0, -- #5I two tasers
		0, -- #5J two cloakers
		0, -- #5K two veterans/2 Medics
		1, -- #6A two Hshot/2 LAR
		1, -- #6B two HAR/1 LAR/1 Medic
		1, -- #6C one Hshot/1 Lshot/1 LAR
		1, -- #6D one Hshot/1 Lshot/1 Medic
		1, -- #6E two Shield/1 taser/1 Medic
		1, -- #6F two tasers/1 cloaker
		1, -- #6G three cloakers
		1, -- #6H one Bdozer/1 Taser
		1, -- #6I one Shield/1 Wdozer/1 Medic
		1, -- #6J one Gdozer/1 Medic/1 Cloaker
		1, -- #6K two HRT/one veteran
		0, -- #7A two Hshot/2 LAR
		0, -- #7B one Hshot/2 Lshot/1 LAR
		0, -- #7C two HAR/2 LAR
		0, -- #7D two HAR/1 LAR/1 Medic
		0, -- #7E two taser/1 Medic
		0, -- #7F one tazer/1 Bdozer/1 Medic/1 cloaker
		0, -- #7G one Bdozer/1 Medicdozer
		0, -- #7H one Shield/1 Gdozer/1 Medic
		0, -- #7I three shield/1 Wdozer
		0, -- #7J four cloakers
		0, -- #7K two veterans/2 Taser
		},
		
		{ -- wave 8 Classics
		-- Classics. Zeal tactics and takedown groups with no medicdozer, but Gensec stats. Deathwish.
		0, -- #1A two rookie
		0, -- #1B revolver/two pistol
		0, -- #1C smg/two pistol
		0, -- #1D shot/two smg
		0, -- #1E revolver/medic
		0, -- #1F rookie/medic
		0, -- #1G shield/shot
		0, -- #2A one Lshot/3 LAR
		0, -- #2B one Shield/2 HAR
		0, -- #2C one Taser/2 HAR
		0, -- #2D one Taser/2 Hshot
		0, -- #2E one Shield/2 LAR
		0, -- #2F three LAR/1 Medic
		0, -- #2G 2 HRT/1 Medic
		0, -- #2H one Taser/2 HRT
		0, -- #3A two HAR/2 LAR
		0, -- #3B two Lshot/1 Medic/1 LAR
		0, -- #3C two Hshot/2 LAR
		0, -- #3D one Shield/3 LAR
		0, -- #3E two Shield/2 HAR
		0, -- #3F two Taser/2 LAR
		0, -- #3G one Gdozer
		0, -- #3H two cloaker
		0, -- #3I one taser/two HRT
		0, -- #4A two HAR/2 LAR
		0, -- #4B two HAR/1 Medic/1 LAR
		0, -- #4C two Hshot/2 Lshot
		0, -- #4D two Shield/1 Medic/ 1 Lshot
		0, -- #4E two Shield/2 Lshot
		0, -- #4F two Taser/2 LAR
		0, -- #4G one Shield/1 Gdozer
		0, -- #4H one Shield/1 Bdozer
		0, -- #4I two cloaker
		0, -- #4J one taser/two HRT
		0, -- #5A one Hshot/2 Lshot/1 LAR
		0, -- #5B one Hshot/2 Lshot/1 Medic
		0, -- #5C two HAR/2 LAR
		0, -- #5D two HAR/1 LAR/1 Medic
		0, -- #5E one Wdozer
		0, -- #5F one shield/1 Bdozer/1 Medic
		0, -- #5G one shield/1 Gdozer/1 Medic
		0, -- #5H one Gdozer/1 Bdozer
		0, -- #5I two tasers
		0, -- #5J two cloakers
		0, -- #5K two veterans/2 Medics
		0, -- #6A two Hshot/2 LAR
		0, -- #6B two HAR/1 LAR/1 Medic
		0, -- #6C one Hshot/1 Lshot/1 LAR
		0, -- #6D one Hshot/1 Lshot/1 Medic
		0, -- #6E two Shield/1 taser/1 Medic
		1, -- #6F two tasers/1 cloaker
		0, -- #6G three cloakers
		0, -- #6H one Bdozer/1 Taser
		0, -- #6I one Shield/1 Wdozer/1 Medic
		0, -- #6J one Gdozer/1 Medic/1 Cloaker
		0, -- #6K two HRT/one veteran
		1, -- #7A two Hshot/2 LAR
		1, -- #7B one Hshot/2 Lshot/1 LAR
		1, -- #7C two HAR/2 LAR
		1, -- #7D two HAR/1 LAR/1 Medic
		1, -- #7E two taser/1 Medic
		1, -- #7F one tazer/1 Bdozer/1 Medic/1 cloaker
		0, -- #7G one Bdozer/1 Medicdozer
		1, -- #7H one Shield/1 Gdozer/1 Medic
		1, -- #7I three shield/1 Wdozer
		1, -- #7J four cloakers
		0, -- #7K two veterans/2 Taser
		},
		
		{ -- wave 9 ZEAL
		-- Zeal. Full assault range except grenadiers. Add medicdozers. CRACKDOWN.
		0, -- #1A two rookie
		0, -- #1B revolver/two pistol
		0, -- #1C smg/two pistol
		0, -- #1D shot/two smg
		0, -- #1E revolver/medic
		0, -- #1F rookie/medic
		0, -- #1G shield/shot
		0, -- #2A one Lshot/3 LAR
		0, -- #2B one Shield/2 HAR
		0, -- #2C one Taser/2 HAR
		0, -- #2D one Taser/2 Hshot
		0, -- #2E one Shield/2 LAR
		0, -- #2F three LAR/1 Medic
		0, -- #2G 2 HRT/1 Medic
		0, -- #2H one Taser/2 HRT
		0, -- #3A two HAR/2 LAR
		0, -- #3B two Lshot/1 Medic/1 LAR
		0, -- #3C two Hshot/2 LAR
		0, -- #3D one Shield/3 LAR
		0, -- #3E two Shield/2 HAR
		0, -- #3F two Taser/2 LAR
		0, -- #3G one Gdozer
		0, -- #3H two cloaker
		0, -- #3I one taser/two HRT
		0, -- #4A two HAR/2 LAR
		0, -- #4B two HAR/1 Medic/1 LAR
		0, -- #4C two Hshot/2 Lshot
		0, -- #4D two Shield/1 Medic/ 1 Lshot
		0, -- #4E two Shield/2 Lshot
		0, -- #4F two Taser/2 LAR
		0, -- #4G one Shield/1 Gdozer
		0, -- #4H one Shield/1 Bdozer
		0, -- #4I two cloaker
		0, -- #4J one taser/two HRT
		0, -- #5A one Hshot/2 Lshot/1 LAR
		0, -- #5B one Hshot/2 Lshot/1 Medic
		0, -- #5C two HAR/2 LAR
		0, -- #5D two HAR/1 LAR/1 Medic
		0, -- #5E one Wdozer
		0, -- #5F one shield/1 Bdozer/1 Medic
		0, -- #5G one shield/1 Gdozer/1 Medic
		0, -- #5H one Gdozer/1 Bdozer
		0, -- #5I two tasers
		0, -- #5J two cloakers
		0, -- #5K two veterans/2 Medics
		0, -- #6A two Hshot/2 LAR
		0, -- #6B two HAR/1 LAR/1 Medic
		0, -- #6C one Hshot/1 Lshot/1 LAR
		0, -- #6D one Hshot/1 Lshot/1 Medic
		0, -- #6E two Shield/1 taser/1 Medic
		0, -- #6F two tasers/1 cloaker
		0, -- #6G three cloakers
		0, -- #6H one Bdozer/1 Taser
		0, -- #6I one Shield/1 Wdozer/1 Medic
		0, -- #6J one Gdozer/1 Medic/1 Cloaker
		0, -- #6K two HRT/one veteran
		1, -- #7A two Hshot/2 LAR
		1, -- #7B one Hshot/2 Lshot/1 LAR
		1, -- #7C two HAR/2 LAR
		1, -- #7D two HAR/1 LAR/1 Medic
		1, -- #7E two taser/1 Medic
		1, -- #7F one tazer/1 Bdozer/1 Medic/1 cloaker
		1, -- #7G one Bdozer/1 Medicdozer
		1, -- #7H one Shield/1 Gdozer/1 Medic
		1, -- #7I three shield/1 Wdozer
		1, -- #7J four cloakers
		1, -- #7K two veterans/2 Taser
		},
		
		{ -- wave 9 UNUSED
		0, -- #1A two rookie
		0, -- #1B revolver/two pistol
		0, -- #1C smg/two pistol
		0, -- #1D shot/two smg
		0, -- #1E revolver/medic
		0, -- #1F rookie/medic
		0, -- #1G shield/shot
		0, -- #2A one Lshot/3 LAR
		0, -- #2B one Shield/2 HAR
		0, -- #2C one Taser/2 HAR
		0, -- #2D one Taser/2 Hshot
		0, -- #2E one Shield/2 LAR
		0, -- #2F three LAR/1 Medic
		0, -- #2G 2 HRT/1 Medic
		0, -- #2H one Taser/2 HRT
		0, -- #3A two HAR/2 LAR
		0, -- #3B two Lshot/1 Medic/1 LAR
		0, -- #3C two Hshot/2 LAR
		0, -- #3D one Shield/3 LAR
		0, -- #3E two Shield/2 HAR
		0, -- #3F two Taser/2 LAR
		1, -- #3G one Gdozer -- TEST VALUE FOR OVERFLOW REPORTING
		0, -- #3H two cloaker
		0, -- #3I one taser/two HRT
		0, -- #4A two HAR/2 LAR
		0, -- #4B two HAR/1 Medic/1 LAR
		0, -- #4C two Hshot/2 Lshot
		0, -- #4D two Shield/1 Medic/ 1 Lshot
		0, -- #4E two Shield/2 Lshot
		0, -- #4F two Taser/2 LAR
		0, -- #4G one Shield/1 Gdozer
		0, -- #4H one Shield/1 Bdozer
		0, -- #4I two cloaker
		0, -- #4J one taser/two HRT
		0, -- #5A one Hshot/2 Lshot/1 LAR
		0, -- #5B one Hshot/2 Lshot/1 Medic
		0, -- #5C two HAR/2 LAR
		0, -- #5D two HAR/1 LAR/1 Medic
		0, -- #5E one Wdozer
		0, -- #5F one shield/1 Bdozer/1 Medic
		0, -- #5G one shield/1 Gdozer/1 Medic
		0, -- #5H one Gdozer/1 Bdozer
		0, -- #5I two tasers
		0, -- #5J two cloakers
		0, -- #5K two veterans/2 Medics
		0, -- #6A two Hshot/2 LAR
		0, -- #6B two HAR/1 LAR/1 Medic
		0, -- #6C one Hshot/1 Lshot/1 LAR
		0, -- #6D one Hshot/1 Lshot/1 Medic
		0, -- #6E two Shield/1 taser/1 Medic
		0, -- #6F two tasers/1 cloaker
		0, -- #6G three cloakers
		0, -- #6H one Bdozer/1 Taser
		0, -- #6I one Shield/1 Wdozer/1 Medic
		0, -- #6J one Gdozer/1 Medic/1 Cloaker
		0, -- #6K two HRT/one veteran
		0, -- #7A two Hshot/2 LAR
		0, -- #7B one Hshot/2 Lshot/1 LAR
		0, -- #7C two HAR/2 LAR
		0, -- #7D two HAR/1 LAR/1 Medic
		0, -- #7E two taser/1 Medic
		0, -- #7F one tazer/1 Bdozer/1 Medic/1 cloaker
		0, -- #7G one Bdozer/1 Medicdozer
		0, -- #7H one Shield/1 Gdozer/1 Medic
		0, -- #7I three shield/1 Wdozer
		0, -- #7J four cloakers
		0, -- #7K two veterans/2 Taser
		}
	}
	local ordered_spawn_group_names = { 
	-- aim for 10 or fewer groups per wave.
	-- Beat intro. beat, shield, medic, rookies. NORMAL.
		"normal_rookiepair", -- #1A two rookie
		"normal_revolvergroup", -- #1B revolver/two pistol
		"hard_smggroup", -- #1C smg/two pistol
		"hard_copcombo", -- #1D shot/two smg
		"hard_revolvermedic", -- #1E revolver/medic
		"hard_rookiemedic", -- #1F rookie/medic
		"normal_shieldbasic", -- #1G shield/shot
		
	-- SWAT sig raise term. Swat, shield, medic, taser. Add HRT. HARD.
		"hard_lightgroup", -- #2A one Lshot/3 LAR
		"hard_shieldheavy", -- #2B one Shield/2 HAR
		"vhard_taserARgroup", -- #2C one Taser/2 HAR
		"vhard_tasershotgroup", -- #2D one Taser/2 Hshot
		"vhard_shieldlightgroup", -- #2E one Shield/2 LAR
		"vhard_lightARchargeMed", -- #2F three LAR/1 Medic
		"vhard_hrtmedic", -- #2G 2 HRT/1 Medic
		"vhard_hrttaser", -- #2H one Taser/2 HRT

	-- FBI warmup. FBI, medics, shields, dozer, HRT. VERY HARD.
		"vhard_mixARcharge", -- #3A two HAR/2 LAR
		"vhard_lightmixchargeMed", -- #3B two Lshot/1 Medic/1 LAR
		"vhard_mixbothcharge", -- #3C two Hshot/2 LAR
		"vhard_shieldlightgroup", -- #3D one Shield/3 LAR
		"vhard_shieldheavyARgroup", -- #3E two Shield/2 HAR
		"vhard_taserARgroup", -- #3F two Taser/2 LAR
		"vhard_bullsolo", -- #3G one Gdozer
		"vhard_hrtmedic", -- #3H two cloaker
		"vhard_hrttaser", -- #3I one taser/two HRT
		
	-- FBI warmup over. FBI, medics, shields, dozers, HRT. Add cloaker. OVERKILL.
		"ovk_mixheavyARcharge", -- #4A two HAR/2 LAR
		"ovk_comboARcharge", -- #4B two HAR/1 Medic/1 LAR
		"ovk_mixshotcharge", -- #4C two Hshot/2 Lshot
		"ovk_shieldcombo", -- #4D two Shield/1 Medic/ 1 Lshot
		"ovk_shieldshot", -- #4E two Shield/2 Lshot
		"ovk_tazerAR", -- #4F two Taser/2 LAR
		"ovk_greenknight", -- #4G one Shield/1 Gdozer
		"ovk_blackknight", -- #4H one Shield/1 Bdozer
		"ovk_spoocpair", -- #4I	two cloaker
		"ovk_hrttaser", -- #4J one taser/two HRT

	-- Gensec. Gensecs, dozers, cloakers, medics, shields. Add Veterans. MAYHEM.
		"mh_group_4_std", -- #5A one Hshot/2 Lshot/1 LAR
		"mh_group_4_med", -- #5B one Hshot/2 Lshot/1 Medic
		"mh_group_5_std", -- #5C two HAR/2 LAR
		"mh_group_5_med", -- #5D two HAR/1 LAR/1 Medic
		"mh_whitedozer", -- #5E one Wdozer
		"mh_blackpaladin", -- #5F one shield/1 Bdozer/1 Medic
		"mh_greenpaladin", -- #5G one shield/1 Gdozer/1 Medic
		"mh_partners", -- #5H one Gdozer/1 Bdozer
		"mh_taserpair", -- #5I two tasers
		"mh_spoocpair", -- #5J two cloakers
		"mh_vetmed", -- #5K two veterans/2 Medics
		
	-- Gensec. Full range of units, intensified distro of normals. DEATH WISH.
		"dw_group_2_std", -- #6A two Hshot/2 LAR
		"dw_group_5_med", -- #6B two HAR/1 LAR/1 Medic
		"dw_group_4_std", -- #6C one Hshot/1 Lshot/1 LAR
		"dw_group_4_med", -- #6D one Hshot/1 Lshot/1 Medic
		"dw_citadel", -- #6E two Shield/1 taser/1 Medic
		"dw_takedowner", -- #6F two tasers/1 cloaker
		"dw_spooctrio", -- #6G three cloakers
		"dw_blackball", -- #6H one Bdozer/1 Taser
		"dw_skullpaladin", -- #6I one Shield/1 Wdozer/1 Medic
		"dw_greeneye", -- #6J one Gdozer/1 Medic/1 Cloaker
		"dw_hrtvetmix", -- #6K two HRT/one veteran
		
	-- Zeal. Full assault range except grenadiers. Add medicdozers. CRACKDOWN.
		"cd_group_2_std", -- #7A two Hshot/2 LAR
		"cd_group_4_std", -- #7B one Hshot/2 Lshot/1 LAR
		"cd_group_5_std", -- #7C two HAR/2 LAR
		"cd_group_5_med", -- #7D two HAR/1 LAR/1 Medic
		"gorgon", -- #7E two taser/1 Medic
		"chimera", -- #7F one tazer/1 Bdozer/1 Medic/1 cloaker
		"janus", -- #7G one Bdozer/1 Medicdozer
		"mh_greenpaladin", -- #7H one Shield/1 Gdozer/1 Medic
		"epeius", -- #7I three shield/1 Wdozer
		"styx", -- #7J four cloakers
		"too_group" -- #7K two veterans/2 Taser
	}

	for _, wave in ipairs(nice_human_readable_table) do
		local total_weight = 0

		for _, weight in ipairs(wave) do
			total_weight = total_weight + weight
		end

		for i, weight in ipairs(wave) do
			wave[i] = weight / total_weight
		end
	end

	self.assault = {groups = {}}

	for i, src_weights in ipairs(nice_human_readable_table) do
		local dst_weights = {}

		for j, weight in ipairs(src_weights) do
			local group_name = ordered_spawn_group_names[j]
			dst_weights[group_name] = {
				weight,
				weight,
				weight
			}
		end

		self.assault.groups[i] = dst_weights
	end

	local skirmish_assault_meta = {__index = function (t, key)
		if key == "groups" then
			local current_wave = managers.skirmish:current_wave_number()
			local current_wave_index = math.clamp(current_wave, 1, #self.assault.groups)
			--log("Current wave index is " .. current_wave_index)
			return self.assault.groups[current_wave_index]
		else
			return rawget(t, key)
		end
	end}

	setmetatable(tweak_data.group_ai.skirmish.assault, skirmish_assault_meta)
end
