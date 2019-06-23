function SkirmishTweakData:_init_special_unit_spawn_limits()
	self.spawn_limit_to_use = {
		tank = 2,
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
	skirmish_data.assault.sustain_duration_min = {
		120,
		120,
		120
	}
	skirmish_data.assault.sustain_duration_max = {
		120,
		120,
		120
	}
	skirmish_data.assault.sustain_duration_balance_mul = {
		1,
		1,
		1,
		1
	}
	skirmish_data.assault.fade_duration = 5
	skirmish_data.assault.delay = {
		60,
		60,
		60
	}
end

function SkirmishTweakData:_init_wave_modifiers()
	self.wave_modifiers = {}
	self.wave_modifiers[1] = {{class = "ModifierCloakerArrest"}}
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
		0, -- #3B two HAR/1 Medic/1 LAR
		0, -- #3C two Hshot/2 Lshot
		0, -- #3D two Shield/1 Medic/ 1 Lshot
		0, -- #3E two Shield/2 Lshot
		0, -- #3F two Taser/2 LAR
		0, -- #3G one Shield/1 Gdozer
		0, -- #3H one Shield/1 Bdozer
		0, -- #3I two cloaker
		0, -- #3J one taser/two HRT
		0, -- #4A one Hshot/2 Lshot/1 LAR
		0, -- #4B one Hshot/2 Lshot/1 Medic
		0, -- #4C two HAR/2 LAR
		0, -- #4D two HAR/1 LAR/1 Medic
		0, -- #4E one Wdozer
		0, -- #4F one shield/1 Bdozer/1 Medic
		0, -- #4G  one shield/1 Gdozer/1 Medic
		0, -- #4H one Gdozer/1 Bdozer
		0, -- #4I  two tasers
		0, -- #4J  two cloakers
		0, -- #4K  two veterans/2 Medics
		0, -- #5A smg/two pistol
		0, -- #5B shot/two smg
		0, -- #5C one revolver/two pistol
		0, -- #5D two HAR/2 LAR
		0, -- #5E two HAR/1 Medic/1 LAR
		0, -- #5F two Hshot/2 Lshot
		0, -- #5G two Shield/2 Lshot		
		0, -- #5H two Shield/1 taser/1 Medic
		0, -- #5I  two tasers/1 cloaker
		0, -- #5J two cloakers
		0, -- #5K Gdozer
		0, -- #5L Bdozer/1 Taser
		0, -- #5M one Shield/Wdozer/1 Medic
		0, -- #5N two rookie
		0, -- #5O one Taser/two HRT
		0, -- #5P two HRT/one veteran
		0, -- #6A two Hshot/2 LAR
		0, -- #6B one Hshot/2 Lshot/1 LAR
		0, -- #6C two HAR/2 LAR
		0, -- #6D two HAR/1 LAR/1 Medic
		0, -- #6E two taser/1 Medic
		0, -- #6F one tazer/1 Bdozer/1 Medic/1 cloaker
		0, -- #6G one Bdozer/1 Medicdozer
		0, -- #6H one Shield/1 Gdozer/1 Medic
		0, -- #6I three shield/1 Wdozer
		0, -- #6J three cloakers
		0 -- #6K two veterans/2 Medic
		},
		
		{ -- wave 2 swat
		  -- swat, shield, medic, taser. Add HRT.
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
		0, -- #3B two HAR/1 Medic/1 LAR
		0, -- #3C two Hshot/2 Lshot
		0, -- #3D two Shield/1 Medic/ 1 Lshot
		0, -- #3E two Shield/2 Lshot
		0, -- #3F two Taser/2 LAR
		0, -- #3G one Shield/1 Gdozer
		0, -- #3H one Shield/1 Bdozer
		0, -- #3I two cloaker
		0, -- #3J one taser/two HRT
		0, -- #4A one Hshot/2 Lshot/1 LAR
		0, -- #4B one Hshot/2 Lshot/1 Medic
		0, -- #4C two HAR/2 LAR
		0, -- #4D two HAR/1 LAR/1 Medic
		0, -- #4E one Wdozer
		0, -- #4F one shield/1 Bdozer/1 Medic
		0, -- #4G  one shield/1 Gdozer/1 Medic
		0, -- #4H one Gdozer/1 Bdozer
		0, -- #4I  two tasers
		0, -- #4J  two cloakers
		0, -- #4K  two veterans/2 Medics
		0, -- #5A smg/two pistol
		0, -- #5B shot/two smg
		0, -- #5C one revolver/two pistol
		0, -- #5D two HAR/2 LAR
		0, -- #5E two HAR/1 Medic/1 LAR
		0, -- #5F two Hshot/2 Lshot
		0, -- #5G two Shield/2 Lshot		
		0, -- #5H two Shield/1 taser/1 Medic
		0, -- #5I  two tasers/1 cloaker
		0, -- #5J two cloakers
		0, -- #5K Gdozer
		0, -- #5L Bdozer/1 Taser
		0, -- #5M one Shield/Wdozer/1 Medic
		0, -- #5N two rookie
		0, -- #5O one Taser/two HRT
		0, -- #5P two HRT/one veteran
		0, -- #6A two Hshot/2 LAR
		0, -- #6B one Hshot/2 Lshot/1 LAR
		0, -- #6C two HAR/2 LAR
		0, -- #6D two HAR/1 LAR/1 Medic
		0, -- #6E two taser/1 Medic
		0, -- #6F one tazer/1 Bdozer/1 Medic/1 cloaker
		0, -- #6G one Bdozer/1 Medicdozer
		0, -- #6H one Shield/1 Gdozer/1 Medic
		0, -- #6I three shield/1 Wdozer
		0, -- #6J three cloakers
		0 -- #6K two veterans/2 Medic
		},
		
		{ -- wave 3 FBI
		  -- warmup over. FBI, medics, shields, dozers, cloakers, HRT.
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
		1, -- #3B two HAR/1 Medic/1 LAR
		1, -- #3C two Hshot/2 Lshot
		1, -- #3D two Shield/1 Medic/ 1 Lshot
		1, -- #3E two Shield/2 Lshot
		1, -- #3F two Taser/2 LAR
		1, -- #3G one Shield/1 Gdozer
		1, -- #3H one Shield/1 Bdozer
		1, -- #3I two cloaker
		1, -- #3J one taser/two HRT
		0, -- #4A one Hshot/2 Lshot/1 LAR
		0, -- #4B one Hshot/2 Lshot/1 Medic
		0, -- #4C two HAR/2 LAR
		0, -- #4D two HAR/1 LAR/1 Medic
		0, -- #4E one Wdozer
		0, -- #4F one shield/1 Bdozer/1 Medic
		0, -- #4G  one shield/1 Gdozer/1 Medic
		0, -- #4H one Gdozer/1 Bdozer
		0, -- #4I  two tasers
		0, -- #4J  two cloakers
		0, -- #4K  two veterans/2 Medics
		0, -- #5A smg/two pistol
		0, -- #5B shot/two smg
		0, -- #5C one revolver/two pistol
		0, -- #5D two HAR/2 LAR
		0, -- #5E two HAR/1 Medic/1 LAR
		0, -- #5F two Hshot/2 Lshot
		0, -- #5G two Shield/2 Lshot		
		0, -- #5H two Shield/1 taser/1 Medic
		0, -- #5I  two tasers/1 cloaker
		0, -- #5J two cloakers
		0, -- #5K Gdozer
		0, -- #5L Bdozer/1 Taser
		0, -- #5M one Shield/Wdozer/1 Medic
		0, -- #5N two rookie
		0, -- #5O one Taser/two HRT
		0, -- #5P two HRT/one veteran
		0, -- #6A two Hshot/2 LAR
		0, -- #6B one Hshot/2 Lshot/1 LAR
		0, -- #6C two HAR/2 LAR
		0, -- #6D two HAR/1 LAR/1 Medic
		0, -- #6E two taser/1 Medic
		0, -- #6F one tazer/1 Bdozer/1 Medic/1 cloaker
		0, -- #6G one Bdozer/1 Medicdozer
		0, -- #6H one Shield/1 Gdozer/1 Medic
		0, -- #6I three shield/1 Wdozer
		0, -- #6J three cloakers
		0 -- #6K two veterans/2 Medic
		},
		
		{ -- wave 4 Gensec. Mayhem values.
		  -- Gensecs, dozers (w/LMG), cloakers, medics, shields. Add Veterans.
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
		0, -- #3B two HAR/1 Medic/1 LAR
		0, -- #3C two Hshot/2 Lshot
		0, -- #3D two Shield/1 Medic/ 1 Lshot
		0, -- #3E two Shield/2 Lshot
		0, -- #3F two Taser/2 LAR
		0, -- #3G one Shield/1 Gdozer
		0, -- #3H one Shield/1 Bdozer
		0, -- #3I two cloaker
		0, -- #3J one taser/two HRT
		1, -- #4A one Hshot/2 Lshot/1 LAR
		1, -- #4B one Hshot/2 Lshot/1 Medic
		1, -- #4C two HAR/2 LAR
		1, -- #4D two HAR/1 LAR/1 Medic
		1, -- #4E one Wdozer
		1, -- #4F one shield/1 Bdozer/1 Medic
		1, -- #4G  one shield/1 Gdozer/1 Medic
		1, -- #4H one Gdozer/1 Bdozer
		1, -- #4I  two tasers
		1, -- #4J  two cloakers
		1, -- #4K  two veterans/2 Medics
		0, -- #5A smg/two pistol
		0, -- #5B shot/two smg
		0, -- #5C one revolver/two pistol
		0, -- #5D two HAR/2 LAR
		0, -- #5E two HAR/1 Medic/1 LAR
		0, -- #5F two Hshot/2 Lshot
		0, -- #5G two Shield/2 Lshot		
		0, -- #5H two Shield/1 taser/1 Medic
		0, -- #5I  two tasers/1 cloaker
		0, -- #5J two cloakers
		0, -- #5K Gdozer
		0, -- #5L Bdozer/1 Taser
		0, -- #5M one Shield/Wdozer/1 Medic
		0, -- #5N two rookie
		0, -- #5O one Taser/two HRT
		0, -- #5P two HRT/one veteran
		0, -- #6A two Hshot/2 LAR
		0, -- #6B one Hshot/2 Lshot/1 LAR
		0, -- #6C two HAR/2 LAR
		0, -- #6D two HAR/1 LAR/1 Medic
		0, -- #6E two taser/1 Medic
		0, -- #6F one tazer/1 Bdozer/1 Medic/1 cloaker
		0, -- #6G one Bdozer/1 Medicdozer
		0, -- #6H one Shield/1 Gdozer/1 Medic
		0, -- #6I three shield/1 Wdozer
		0, -- #6J three cloakers
		0 -- #6K two veterans/2 Medic
		},
		
		{ -- wave 5 Classic. Death Wish values.
		  -- extensive semi-endurance. Full range of units including earlier, e.g. beat police, HRT.
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
		0, -- #3B two HAR/1 Medic/1 LAR
		0, -- #3C two Hshot/2 Lshot
		0, -- #3D two Shield/1 Medic/ 1 Lshot
		0, -- #3E two Shield/2 Lshot
		0, -- #3F two Taser/2 LAR
		0, -- #3G one Shield/1 Gdozer
		0, -- #3H one Shield/1 Bdozer
		0, -- #3I two cloaker
		0, -- #3J one taser/two HRT
		0, -- #4A one Hshot/2 Lshot/1 LAR
		0, -- #4B one Hshot/2 Lshot/1 Medic
		0, -- #4C two HAR/2 LAR
		0, -- #4D two HAR/1 LAR/1 Medic
		0, -- #4E one Wdozer
		0, -- #4F one shield/1 Bdozer/1 Medic
		0, -- #4G  one shield/1 Gdozer/1 Medic
		0, -- #4H one Gdozer/1 Bdozer
		0, -- #4I  two tasers
		0, -- #4J  two cloakers
		0, -- #4K  two veterans/2 Medics
		1, -- #5A smg/two pistol
		1, -- #5B shot/two smg
		1, -- #5C one revolver/two pistol
		1, -- #5D two HAR/2 LAR
		1, -- #5E two HAR/1 Medic/1 LAR
		1, -- #5F two Hshot/2 Lshot
		1, -- #5G two Shield/2 Lshot		
		1, -- #5H two Shield/1 taser/1 Medic
		1, -- #5I  two tasers/1 cloaker
		1, -- #5J two cloakers
		1, -- #5K Gdozer
		1, -- #5L Bdozer/1 Taser
		1, -- #5M one Shield/Wdozer/1 Medic
		1, -- #5N two rookie
		1, -- #5O one Taser/two HRT
		1, -- #5P two HRT/one veteran
		0, -- #6A two Hshot/2 LAR
		0, -- #6B one Hshot/2 Lshot/1 LAR
		0, -- #6C two HAR/2 LAR
		0, -- #6D two HAR/1 LAR/1 Medic
		0, -- #6E two taser/1 Medic
		0, -- #6F one tazer/1 Bdozer/1 Medic/1 cloaker
		0, -- #6G one Bdozer/1 Medicdozer
		0, -- #6H one Shield/1 Gdozer/1 Medic
		0, -- #6I three shield/1 Wdozer
		0, -- #6J three cloakers
		0 -- #6K two veterans/2 Medic
		},
		
		{ -- wave 6 Zeal.
		  -- shorter than wave 5. Full assault range except grenadiers. Add medicdozers.
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
		0, -- #3B two HAR/1 Medic/1 LAR
		0, -- #3C two Hshot/2 Lshot
		0, -- #3D two Shield/1 Medic/ 1 Lshot
		0, -- #3E two Shield/2 Lshot
		0, -- #3F two Taser/2 LAR
		0, -- #3G one Shield/1 Gdozer
		0, -- #3H one Shield/1 Bdozer
		0, -- #3I two cloaker
		0, -- #3J one taser/two HRT
		0, -- #4A one Hshot/2 Lshot/1 LAR
		0, -- #4B one Hshot/2 Lshot/1 Medic
		0, -- #4C two HAR/2 LAR
		0, -- #4D two HAR/1 LAR/1 Medic
		0, -- #4E one Wdozer
		0, -- #4F one shield/1 Bdozer/1 Medic
		0, -- #4G  one shield/1 Gdozer/1 Medic
		0, -- #4H one Gdozer/1 Bdozer
		0, -- #4I  two tasers
		0, -- #4J  two cloakers
		0, -- #4K  two veterans/2 Medics
		0, -- #5A smg/two pistol
		0, -- #5B shot/two smg
		0, -- #5C one revolver/two pistol
		0, -- #5D two HAR/2 LAR
		0, -- #5E two HAR/1 Medic/1 LAR
		0, -- #5F two Hshot/2 Lshot
		0, -- #5G two Shield/2 Lshot		
		0, -- #5H two Shield/1 taser/1 Medic
		0, -- #5I  two tasers/1 cloaker
		0, -- #5J two cloakers
		0, -- #5K Gdozer
		0, -- #5L Bdozer/1 Taser
		0, -- #5M one Shield/Wdozer/1 Medic
		0, -- #5N two rookie
		0, -- #5O one Taser/two HRT
		0, -- #5P two HRT/one veteran
		1, -- #6A two Hshot/2 LAR
		1, -- #6B one Hshot/2 Lshot/1 LAR
		1, -- #6C two HAR/2 LAR
		1, -- #6D two HAR/1 LAR/1 Medic
		1, -- #6E two taser/1 Medic
		1, -- #6F one tazer/1 Bdozer/1 Medic/1 cloaker
		1, -- #6G one Bdozer/1 Medicdozer
		1, -- #6H one Shield/1 Gdozer/1 Medic
		1, -- #6I three shield/1 Wdozer
		1, -- #6J three cloakers
		1 -- #6K two veterans/2 Medic
		},
		
		{ -- wave 7 UNUSED
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
		0, -- #3B two HAR/1 Medic/1 LAR
		0, -- #3C two Hshot/2 Lshot
		0, -- #3D two Shield/1 Medic/ 1 Lshot
		0, -- #3E two Shield/2 Lshot
		0, -- #3F two Taser/2 LAR
		0, -- #3G one Shield/1 Gdozer
		0, -- #3H one Shield/1 Bdozer
		0, -- #3I two cloaker
		0, -- #3J one taser/two HRT
		0, -- #4A one Hshot/2 Lshot/1 LAR
		0, -- #4B one Hshot/2 Lshot/1 Medic
		0, -- #4C two HAR/2 LAR
		0, -- #4D two HAR/1 LAR/1 Medic
		0, -- #4E one Wdozer
		0, -- #4F one shield/1 Bdozer/1 Medic
		0, -- #4G  one shield/1 Gdozer/1 Medic
		0, -- #4H one Gdozer/1 Bdozer
		0, -- #4I  two tasers
		0, -- #4J  two cloakers
		0, -- #4K  two veterans/2 Medics
		0, -- #5A smg/two pistol
		0, -- #5B shot/two smg
		0, -- #5C one revolver/two pistol
		0, -- #5D two HAR/2 LAR
		0, -- #5E two HAR/1 Medic/1 LAR
		0, -- #5F two Hshot/2 Lshot
		0, -- #5G two Shield/2 Lshot		
		0, -- #5H two Shield/1 taser/1 Medic
		0, -- #5I  two tasers/1 cloaker
		0, -- #5J two cloakers
		0, -- #5K Gdozer
		0, -- #5L Bdozer/1 Taser
		0, -- #5M one Shield/Wdozer/1 Medic
		0, -- #5N two rookie
		0, -- #5O one Taser/two HRT
		0, -- #5P two HRT/one veteran
		0, -- #6A two Hshot/2 LAR
		0, -- #6B one Hshot/2 Lshot/1 LAR
		0, -- #6C two HAR/2 LAR
		0, -- #6D two HAR/1 LAR/1 Medic
		0, -- #6E two taser/1 Medic
		0, -- #6F one tazer/1 Bdozer/1 Medic/1 cloaker
		0, -- #6G one Bdozer/1 Medicdozer
		0, -- #6H one Shield/1 Gdozer/1 Medic
		0, -- #6I three shield/1 Wdozer
		0, -- #6J three cloakers
		0 -- #6K two veterans/2 Medic
		},
		
		{ -- wave 8 UNUSED
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
		0, -- #3B two HAR/1 Medic/1 LAR
		0, -- #3C two Hshot/2 Lshot
		0, -- #3D two Shield/1 Medic/ 1 Lshot
		0, -- #3E two Shield/2 Lshot
		0, -- #3F two Taser/2 LAR
		0, -- #3G one Shield/1 Gdozer
		0, -- #3H one Shield/1 Bdozer
		0, -- #3I two cloaker
		0, -- #3J one taser/two HRT
		0, -- #4A one Hshot/2 Lshot/1 LAR
		0, -- #4B one Hshot/2 Lshot/1 Medic
		0, -- #4C two HAR/2 LAR
		0, -- #4D two HAR/1 LAR/1 Medic
		0, -- #4E one Wdozer
		0, -- #4F one shield/1 Bdozer/1 Medic
		0, -- #4G  one shield/1 Gdozer/1 Medic
		0, -- #4H one Gdozer/1 Bdozer
		0, -- #4I  two tasers
		0, -- #4J  two cloakers
		0, -- #4K  two veterans/2 Medics
		0, -- #5A smg/two pistol
		0, -- #5B shot/two smg
		0, -- #5C one revolver/two pistol
		0, -- #5D two HAR/2 LAR
		0, -- #5E two HAR/1 Medic/1 LAR
		0, -- #5F two Hshot/2 Lshot
		0, -- #5G two Shield/2 Lshot		
		0, -- #5H two Shield/1 taser/1 Medic
		0, -- #5I  two tasers/1 cloaker
		0, -- #5J two cloakers
		0, -- #5K Gdozer
		0, -- #5L Bdozer/1 Taser
		0, -- #5M one Shield/Wdozer/1 Medic
		0, -- #5N two rookie
		0, -- #5O one Taser/two HRT
		0, -- #5P two HRT/one veteran
		0, -- #6A two Hshot/2 LAR
		0, -- #6B one Hshot/2 Lshot/1 LAR
		0, -- #6C two HAR/2 LAR
		0, -- #6D two HAR/1 LAR/1 Medic
		0, -- #6E two taser/1 Medic
		0, -- #6F one tazer/1 Bdozer/1 Medic/1 cloaker
		0, -- #6G one Bdozer/1 Medicdozer
		0, -- #6H one Shield/1 Gdozer/1 Medic
		0, -- #6I three shield/1 Wdozer
		0, -- #6J three cloakers
		0 -- #6K two veterans/2 Medic
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
		0, -- #3B two HAR/1 Medic/1 LAR
		0, -- #3C two Hshot/2 Lshot
		0, -- #3D two Shield/1 Medic/ 1 Lshot
		0, -- #3E two Shield/2 Lshot
		0, -- #3F two Taser/2 LAR
		0, -- #3G one Shield/1 Gdozer
		0, -- #3H one Shield/1 Bdozer
		0, -- #3I two cloaker
		0, -- #3J one taser/two HRT
		0, -- #4A one Hshot/2 Lshot/1 LAR
		0, -- #4B one Hshot/2 Lshot/1 Medic
		0, -- #4C two HAR/2 LAR
		0, -- #4D two HAR/1 LAR/1 Medic
		0, -- #4E one Wdozer
		0, -- #4F one shield/1 Bdozer/1 Medic
		0, -- #4G  one shield/1 Gdozer/1 Medic
		0, -- #4H one Gdozer/1 Bdozer
		0, -- #4I  two tasers
		0, -- #4J  two cloakers
		0, -- #4K  two veterans/2 Medics
		0, -- #5A smg/two pistol
		0, -- #5B shot/two smg
		0, -- #5C one revolver/two pistol
		0, -- #5D two HAR/2 LAR
		0, -- #5E two HAR/1 Medic/1 LAR
		0, -- #5F two Hshot/2 Lshot
		0, -- #5G two Shield/2 Lshot		
		0, -- #5H two Shield/1 taser/1 Medic
		0, -- #5I  two tasers/1 cloaker
		0, -- #5J two cloakers
		0, -- #5K Gdozer
		0, -- #5L Bdozer/1 Taser
		0, -- #5M one Shield/Wdozer/1 Medic
		0, -- #5N two rookie
		0, -- #5O one Taser/two HRT
		0, -- #5P two HRT/one veteran
		0, -- #6A two Hshot/2 LAR
		0, -- #6B one Hshot/2 Lshot/1 LAR
		0, -- #6C two HAR/2 LAR
		0, -- #6D two HAR/1 LAR/1 Medic
		0, -- #6E two taser/1 Medic
		0, -- #6F one tazer/1 Bdozer/1 Medic/1 cloaker
		0, -- #6G one Bdozer/1 Medicdozer
		0, -- #6H one Shield/1 Gdozer/1 Medic
		0, -- #6I three shield/1 Wdozer
		0, -- #6J three cloakers
		0 -- #6K two veterans/2 Medic
		}
	}
	local ordered_spawn_group_names = { 
	-- aim for 10 or fewer groups per aside from wave 5 classics.
	-- Beat beat, shield, medic, rookies.
		"normal_rookiepair", -- #1A two rookie
		"normal_revolvergroup", -- #1B revolver/two pistol
		"hard_smggroup", -- #1C smg/two pistol
		"hard_copcombo", -- #1D shot/two smg
		"hard_revolvermedic", -- #1E revolver/medic
		"hard_rookiemedic", -- #1F rookie/medic
		"normal_shieldbasic", -- #1G shield/shot
		
	-- SWAT swat, shield, medic, taser. Add HRT.
		"hard_lightgroup", -- #2A one Lshot/3 LAR
		"hard_shieldheavy", -- #2B one Shield/2 HAR
		"vhard_taserARgroup", -- #2C one Taser/2 HAR
		"vhard_tasershotgroup", -- #2D one Taser/2 Hshot
		"vhard_shieldlightgroup", -- #2E one Shield/2 LAR
		"vhard_lightARchargeMed", -- #2F three LAR/1 Medic
		"vhard_hrtmedic", -- #2G 2 HRT/1 Medic
		"vhard_hrttaser", -- #2H one Taser/2 HRT

	-- FBI warmup over. FBI, medics, shields, dozers, cloakers, HRT.
		"ovk_mixheavyARcharge", -- #3A two HAR/2 LAR
		"ovk_comboARcharge", -- #3B two HAR/1 Medic/1 LAR
		"ovk_mixshotcharge", -- #3C two Hshot/2 Lshot
		"ovk_shieldcombo", -- #3D two Shield/1 Medic/ 1 Lshot
		"ovk_shieldshot", -- #3E two Shield/2 Lshot
		"ovk_tazerAR", -- #3F two Taser/2 LAR
		"ovk_greenknight", -- #3G one Shield/1 Gdozer
		"ovk_blackknight", -- #3H one Shield/1 Bdozer
		"ovk_spoocpair", -- #3I	two cloaker
		"ovk_hrttaser", -- #3J one taer/two HRT

	-- Gensec Gensecs, dozers (w/LMG), cloakers, medics, shields. Add Veterans.
		"mh_group_4_std", -- #4A one Hshot/2 Lshot/1 LAR
		"mh_group_4_med", -- #4B one Hshot/2 Lshot/1 Medic
		"mh_group_5_std", -- #4C two HAR/2 LAR
		"mh_group_5_med", -- #4D two HAR/1 LAR/1 Medic
		"mh_whitedozer", -- #4E one Wdozer
		"mh_blackpaladin", -- #4F one shield/1 Bdozer/1 Medic
		"mh_greenpaladin", -- #4G  one shield/1 Gdozer/1 Medic
		"mh_partners", -- #4H one Gdozer/1 Bdozer
		"mh_taserpair", -- #4I  two tasers
		"mh_spoocpair", -- #4J  two cloakers
		"mh_vetmed", -- #4K  two veterans/2 Medics
		
	-- Classic extensive semi-endurance. Full range of units including earlier, e.g. beat police, HRT.
		"hard_smggroup", -- #5A smg/two pistol
		"hard_copcombo", -- #5B shot/two smg
		"normal_revolvergroup", -- #5C one revolver/two pistol
		"ovk_mixheavyARcharge", -- #5D two HAR/2 LAR
		"ovk_comboARcharge", -- #5E two HAR/1 Medic/1 LAR
		"ovk_mixshotcharge", -- #5F two Hshot/2 Lshot
		"ovk_shieldshot", -- #5G two Shield/2 Lshot		
		"dw_citadel", -- #5H two Shield/1 taser/1 Medic
		"dw_takedowner", -- #5I  two tasers/1 cloaker
		"dw_spoocpair", -- #5J two cloakers
		"ovk_greendozer", -- #5K Gdozer
		"dw_blackball", -- #5L Bdozer/1 Taser
		"dw_skullpaladin", -- #5M one Shield/Wdozer/1 Medic
		"normal_rookiepair", -- #5N two rookie
		"ovk_hrttaser", -- #5O one Taser/two HRT
		"ovk_hrtvetmix", -- #5P two HRT/one veteran
		
	-- Zeal shorter than wave 5. Full assault range except grenadiers. Add medicdozers.
		"cd_group_2_std", -- #6A two Hshot/2 LAR
		"cd_group_4_std", -- #6B one Hshot/2 Lshot/1 LAR
		"cd_group_5_std", -- #6C two HAR/2 LAR
		"cd_group_5_med", -- #6D two HAR/1 LAR/1 Medic
		"gorgon", -- #6E two taser/1 Medic
		"chimera", -- #6F one tazer/1 Bdozer/1 Medic/1 cloaker
		"janus", -- #6G one Bdozer/1 Medicdozer
		"mh_greenpaladin", -- #6H one Shield/1 Gdozer/1 Medic
		"epeius", -- #6I three shield/1 Wdozer
		"damocles", -- #6J three cloakers
		"dw_vetmed" -- #6K two veterans/2 Medic
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
			log("Current wave index is " .. current_wave_index)
			return self.assault.groups[current_wave_index]
		else
			return rawget(t, key)
		end
	end}

	setmetatable(tweak_data.group_ai.skirmish.assault, skirmish_assault_meta)
end
