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
		{ -- wave 1 some tasers, mostly greens/tans + medics
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
		{ -- wave 2 more tasers, less medics
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
		{ -- wave 3 introduce LMG dozer groups
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
		{ -- wave 4 no change
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
		{ -- wave 5 introduce more shotgunners, less rifles
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
		{ -- wave 6 no change
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
		{ -- wave 7 introduce medicdozers
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
		"dv_group_1",
		"dv_group_2_std",
		"dv_group_2_med",
		"dv_group_3_std",
		"dv_group_3_med",
		"dv_group_4_std",
		"dv_group_4_med",
		"dv_group_5_std",
		"dv_group_5_med",
		"gorgon",
		"atlas",
		"chimera",
		"zeus",
		"janus",
		"epeius",
		"damocles",
		"caduceus",
		"atropos",
		"aegeas"
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

function SkirmishTweakData:_init_ransom_amounts()
	self.ransom_amounts = { -- cash values scale up a lot every 3 waves, since every 3 waves new shit unlocks usually
		1600000,
		1840000,
		2120000,
		24400000,
		28100000,
		32400000,
		373000000,
		429000000,
		494000000
	}

	for i, ransom in ipairs(self.ransom_amounts) do
		self.ransom_amounts[i] = ransom + (self.ransom_amounts[i - 1] or 0)
	end
end