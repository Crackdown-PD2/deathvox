function SkirmishTweakData:_init_special_unit_spawn_limits()
	self.spawn_limit_to_use = {
		tank = 2,
		taser = 4,
		boom = 2,
		spooc = 4,
		shield = 6,
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
			2.56, -- 4 heavyar
			5.55, -- heavyshot/lightar
			5.55, -- heavyshot/lightar/medic
			5.55, -- lightshot/lightar
			5.55, -- lightshot/lightar/medic
			5.55, -- heavyshot/lightshot/lightar
			5.55, -- heavyshot/lightshot/lightar/medic
			5.55, -- heavyar/lightar
			5.55, -- heavyar/lightar/medic
			5.55, -- taser/taser/medic
			0, -- shield/lmgdozer/medic
			0, --taser/saigadozer/medic/cloaker
			0, --greendozer/taser/grenadier
			0, --saigadozer/medicdozer
			0, --shield/lmgdozer
			3, --cloakers
			0, --greendozer/medic/medicdozer
			0, --grenadier/cloaker/taser
			0 --shield/grenadier
		},
		{ -- wave 2 swat
		  -- swat, shield, medic, taser. Add HRT.
			5.56, -- 4 heavyar
			5.55, -- heavyshot/lightar
			3.55, -- heavyshot/lightar/medic
			5.55, -- lightshot/lightar
			3.55, -- lightshot/lightar/medic
			5.55, -- heavyshot/lightshot/lightar
			3.55, -- heavyshot/lightshot/lightar/medic
			5.55, -- heavyar/lightar
			3.55, -- heavyar/lightar/medic
			10.55, -- taser/taser/medic
			0, -- shield/lmgdozer/medic
			0, --taser/saigadozer/medic/cloaker
			0, --greendozer/taser/grenadier
			0, --saigadozer/medicdozer
			0, --shield/lmgdozer
			3, --cloakers
			0, --greendozer/medic/medicdozer
			0, --grenadier/cloaker/taser
			0 --shield/grenadier
		},
		{ -- wave 3 FBI
		  -- warmup over. FBI, medics, shields, dozers, cloakers, HRT.
			5.56, -- 4 heavyar
			3.55, -- heavyshot/lightar
			3.55, -- heavyshot/lightar/medic
			3.55, -- lightshot/lightar
			3.55, -- lightshot/lightar/medic
			3.55, -- heavyshot/lightshot/lightar
			3.55, -- heavyshot/lightshot/lightar/medic
			3.55, -- heavyar/lightar
			3.55, -- heavyar/lightar/medic
			5.55, -- taser/taser/medic
			6, -- shield/lmgdozer/medic
			0, --taser/saigadozer/medic/cloaker
			0, --greendozer/taser/grenadier
			0, --saigadozer/medicdozer
			6, --shield/lmgdozer
			4, --cloakers
			0, --greendozer/medic/medicdozer
			0, --grenadier/cloaker/taser
			0 --shield/grenadier
		},
		{ -- wave 4 Gensec. Mayhem values.
		  -- Gensecs, dozers (w/LMG), cloakers, medics, shields. Add Veterans.
			5.56, -- 4 heavyar
			3.55, -- heavyshot/lightar
			3.55, -- heavyshot/lightar/medic
			3.55, -- lightshot/lightar
			3.55, -- lightshot/lightar/medic
			3.55, -- heavyshot/lightshot/lightar
			3.55, -- heavyshot/lightshot/lightar/medic
			3.55, -- heavyar/lightar
			3.55, -- heavyar/lightar/medic
			5.55, -- taser/taser/medic
			6, -- shield/lmgdozer/medic
			0, --taser/saigadozer/medic/cloaker
			0, --greendozer/taser/grenadier
			0, --saigadozer/medicdozer
			6, --shield/lmgdozer
			4, --cloakers
			0, --greendozer/medic/medicdozer
			0, --grenadier/cloaker/taser
			0 --shield/grenadier
		},
		{ -- wave 5 Classic. Death Wish values.
		  -- extensive semi-endurance. Full range of units including earlier, e.g. beat police, HRT.
			2.56, -- 4 heavyar
			3.55, -- heavyshot/lightar
			3.55, -- heavyshot/lightar/medic
			3.55, -- lightshot/lightar
			3.55, -- lightshot/lightar/medic
			6.55, -- heavyshot/lightshot/lightar
			6.55, -- heavyshot/lightshot/lightar/medic
			0, -- heavyar/lightar
			0, -- heavyar/lightar/medic
			5.55, -- taser/taser/medic
			6, -- shield/lmgdozer/medic
			0, --taser/saigadozer/medic/cloaker
			0, --greendozer/taser/grenadier
			0, --saigadozer/medicdozer
			6, --shield/lmgdozer
			4, --cloakers
			0, --greendozer/medic/medicdozer
			0, --grenadier/cloaker/taser
			0 --shield/grenadier
		},
		{ -- wave 6 Zeal.
		  -- shorter than wave 5. Full assault range except grenadiers. Add medicdozers.
			2.56, -- 4 heavyar
			3.55, -- heavyshot/lightar
			3.55, -- heavyshot/lightar/medic
			3.55, -- lightshot/lightar
			3.55, -- lightshot/lightar/medic
			6.55, -- heavyshot/lightshot/lightar
			6.55, -- heavyshot/lightshot/lightar/medic
			0, -- heavyar/lightar
			0, -- heavyar/lightar/medic
			5.55, -- taser/taser/medic
			6, -- shield/lmgdozer/medic
			0, --taser/saigadozer/medic/cloaker
			0, --greendozer/taser/grenadier
			0, --saigadozer/medicdozer
			6, --shield/lmgdozer
			4, --cloakers
			0, --greendozer/medic/medicdozer
			0, --grenadier/cloaker/taser
			0 --shield/grenadier
		},
		{ -- wave 7 ???
			3.56, -- 4 heavyar
			3.55, -- heavyshot/lightar
			2.55, -- heavyshot/lightar/medic
			3.55, -- lightshot/lightar
			2.55, -- lightshot/lightar/medic
			3.55, -- heavyshot/lightshot/lightar
			2.55, -- heavyshot/lightshot/lightar/medic
			3.55, -- heavyar/lightar
			3.55, -- heavyar/lightar/medic
			3.55, -- taser/taser/medic
			4, -- shield/lmgdozer/medic
			3, --taser/saigadozer/medic/cloaker
			0, --greendozer/taser/grenadier
			3, --saigadozer/medicdozer
			4, --shield/lmgdozer
			4, --cloakers
			3, --greendozer/medic/medicdozer
			0, --grenadier/cloaker/taser
			0 --shield/grenadier
		},
		{ -- wave 8 no change
			3.56, -- 4 heavyar
			3.55, -- heavyshot/lightar
			2.55, -- heavyshot/lightar/medic
			3.55, -- lightshot/lightar
			2.55, -- lightshot/lightar/medic
			3.55, -- heavyshot/lightshot/lightar
			2.55, -- heavyshot/lightshot/lightar/medic
			3.55, -- heavyar/lightar
			3.55, -- heavyar/lightar/medic
			3.55, -- taser/taser/medic
			4, -- shield/lmgdozer/medic
			3, --taser/saigadozer/medic/cloaker
			0, --greendozer/taser/grenadier
			3, --saigadozer/medicdozer
			4, --shield/lmgdozer
			4, --cloakers
			3, --greendozer/medic/medicdozer
			0, --grenadier/cloaker/taser
			0 --shield/grenadier
		},
		{ -- wave 9 introduce grenadiers
			2.56, -- 4 heavyar
			2.55, -- heavyshot/lightar
			2.55, -- heavyshot/lightar/medic
			2.55, -- lightshot/lightar
			2.55, -- lightshot/lightar/medic
			2.55, -- heavyshot/lightshot/lightar
			2.55, -- heavyshot/lightshot/lightar/medic
			2.55, -- heavyar/lightar
			2.55, -- heavyar/lightar/medic
			2.55, -- taser/taser/medic
			3, -- shield/lmgdozer/medic
			3, --taser/saigadozer/medic/cloaker
			3, --greendozer/taser/grenadier
			3, --saigadozer/medicdozer
			3, --shield/lmgdozer
			3, --cloakers
			3, --greendozer/medic/medicdozer
			3, --grenadier/cloaker/taser
			4 --shield/grenadier
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
		"ovk_greenknight" -- #3G one Shield/1 Gdozer
		"ovk_blackknight", -- #3H one Shield/1 Bdozer
		"ovk_spoocpair", -- #3I	two cloaker
		"vhard_hrtmedic", -- #3J two HRT/1 Medic

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
		"mh_taserpair", -- #5I  two tasers
		"damocles", -- #5J three cloakers
		"ovk_greendozer", -- #5K Gdozer
		"ovk_blackdozer", -- #5L Bdozer
		"mh_whitedozer", -- #5M Wdozer
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
