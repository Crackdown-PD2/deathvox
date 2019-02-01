local origin_init = CharacterTweakData.init
local origin_presets = CharacterTweakData._presets
local origin_charmap = CharacterTweakData.character_map

function CharacterTweakData:init(tweak_data)
	local presets = self:_presets(tweak_data)
	origin_init(self, tweak_data)
	self:_init_deathvox(presets)
end

function CharacterTweakData:get_ai_group_type()
	local group_to_use = "zeal" 		
						
	if Global.level_data and Global.level_data.level_id then
		level_id = Global.level_data.level_id
	end
	
	if not Global.game_settings then
		return group_to_use
	end
	local difficulties = {
		"easy",
		"normal",
		"hard",
		"overkill",
		"overkill_145",
		"easy_wish",
		"overkill_290",
		"sm_wish"
	}
	local map_faction_override = {}
	--map_faction_override["Enemy_Spawner"] = "classic"
	map_faction_override["pal"] = "classic"
	map_faction_override["dah"] = "classic"
	map_faction_override["red2"] = "classic"
	map_faction_override["glace"] = "classic"
	map_faction_override["run"] = "classic"
	map_faction_override["flat"] = "classic"
	map_faction_override["dinner"] = "classic"
	map_faction_override["man"] = "classic"
	map_faction_override["nmh"] = "classic"
	-- whurr's map edits
	map_faction_override["bridge"] = "classic"
	map_faction_override["apartment"] = "classic"
	map_faction_override["street"] = "classic"
	map_faction_override["bank"] = "classic"
	-- todo: setup akan on BP, murky on all murky heists, and classics on classic heists
	local diff_index = table.index_of(difficulties, Global.game_settings.difficulty)
	if diff_index <= 3 then
		group_to_use = "cop"
	elseif diff_index <= 5 then
		group_to_use = "fbi"
	elseif diff_index <= 7 then
		group_to_use = "gensec"
	end
	if level_id then
		if map_faction_override[level_id] then
			group_to_use = map_faction_override[level_id]
		end
	end
	if diff_index == 8 then -- kataru's reach is true
		group_to_use = "zeal"
	end
	return group_to_use
end


function CharacterTweakData:_presets(tweak_data)
	local presets = origin_presets(self, tweak_data)
	presets.base.stealth_instant_kill = true
	presets.health_tables = {
		deathvox_guard = {  -- mk 1 values complete. Consistent below CD.
			not_a_real_difficulty = {health = 4, headshot_mult = 3},
			normal = {health = 4, headshot_mult = 3},
			hard = {health = 4, headshot_mult = 3},
			very_hard = {health = 4, headshot_mult = 3},
			overkill = {health = 4, headshot_mult = 3},
			mayhem = {health = 4, headshot_mult = 3},
			death_wish = {health = 4, headshot_mult = 3},
			crackdown = {health = 15, headshot_mult = 3}
		},
		deathvox_gman = { -- mk 1 values complete. Consistent below CD.
			not_a_real_difficulty = {health = 4, headshot_mult = 3}, 
			normal = {health = 4, headshot_mult = 3},
			hard = {health = 4, headshot_mult = 3},
			very_hard = {health = 4, headshot_mult = 3},
			overkill = {health = 4, headshot_mult = 3},
			mayhem = {health = 4, headshot_mult = 3},
			death_wish = {health = 4, headshot_mult = 3},
			crackdown = {health = 15, headshot_mult = 3}
		},
		deathvox_lightar = { -- mk 2 values complete. Shift upward via lower bound, tiering established.
			not_a_real_difficulty = {health = 8, headshot_mult = 2},
			normal = {health = 18, headshot_mult = 3},
			hard = {health = 18, headshot_mult = 3},
			very_hard = {health = 24, headshot_mult = 3},
			overkill = {health = 24, headshot_mult = 3},
			mayhem = {health = 32, headshot_mult = 3},
			death_wish = {health = 32, headshot_mult = 3},
			crackdown = {health = 48, headshot_mult = 3}
		},
		deathvox_lightshot = { -- mk 2 values complete. Shift upward via lower bound, tiering established.
			not_a_real_difficulty = {health = 8, headshot_mult = 2},
			normal = {health = 18, headshot_mult = 3},
			hard = {health = 18, headshot_mult = 3},
			very_hard = {health = 24, headshot_mult = 3},
			overkill = {health = 24, headshot_mult = 3},
			mayhem = {health = 32, headshot_mult = 3},
			death_wish = {health = 32, headshot_mult = 3},
			crackdown = {health = 48, headshot_mult = 3}
		},
        	deathvox_heavyar = { -- mk 2 values complete. Shift upward via lower bound, tiering established.
			not_a_real_difficulty = {health = 16, headshot_mult = 3},
			normal = {health = 25, headshot_mult = 3},
			hard = {health = 25, headshot_mult = 3},
			very_hard = {health = 48, headshot_mult = 3},
			overkill = {health = 48, headshot_mult = 3},
			mayhem = {health = 96, headshot_mult = 3},
			death_wish = {health = 96, headshot_mult = 3},
			crackdown = {health = 101, headshot_mult = 3}
		},
		deathvox_heavyshot = { -- mk 2 values complete. Shift upward via lower bound, tiering established.
			not_a_real_difficulty = {health = 16, headshot_mult = 3},
			normal = {health = 25, headshot_mult = 3},
			hard = {health = 25, headshot_mult = 3},
			very_hard = {health = 48, headshot_mult = 3},
			overkill = {health = 48, headshot_mult = 3},
			mayhem = {health = 96, headshot_mult = 3},
			death_wish = {health = 96, headshot_mult = 3},
			crackdown = {health = 101, headshot_mult = 3}
		},
		deathvox_shield = { -- mk 2 values complete. Shift upward via lower bound, tiering established.
			not_a_real_difficulty = {health = 24, headshot_mult = 3},
			normal = {health = 25, headshot_mult = 3},
			hard = {health = 25, headshot_mult = 3},
			very_hard = {health = 40, headshot_mult = 3},
			overkill = {health = 40, headshot_mult = 3},
			mayhem = {health = 72, headshot_mult = 3},
			death_wish = {health = 72, headshot_mult = 3},
			crackdown = {health = 72, headshot_mult = 3}
		},
		deathvox_medic = { -- mk 2 values complete. Based on light.
			not_a_real_difficulty = {health = 8, headshot_mult = 2},
			normal = {health = 18, headshot_mult = 3},
			hard = {health = 18, headshot_mult = 3},
			very_hard = {health = 24, headshot_mult = 3},
			overkill = {health = 24, headshot_mult = 3},
			mayhem = {health = 32, headshot_mult = 3},
			death_wish = {health = 32, headshot_mult = 3},
			crackdown = {health = 48, headshot_mult = 3}
		},
		deathvox_taser = { -- mk 2 values complete. Based on heavy.
			not_a_real_difficulty = {health = 16, headshot_mult = 3},
			normal = {health = 25, headshot_mult = 3},
			hard = {health = 25, headshot_mult = 3},
			very_hard = {health = 48, headshot_mult = 3},
			overkill = {health = 48, headshot_mult = 3},
			mayhem = {health = 96, headshot_mult = 3},
			death_wish = {health = 96, headshot_mult = 3},
			crackdown = {health = 101, headshot_mult = 3}
		},
		deathvox_cloaker = { -- mk 2 values complete. Now light-based. Will require further scrutiny.
			not_a_real_difficulty = {health = 24, headshot_mult = 3},
			normal = {health = 24, headshot_mult = 3},
			hard = {health = 24, headshot_mult = 3},
			very_hard = {health = 24, headshot_mult = 3},
			overkill = {health = 24, headshot_mult = 3},
			mayhem = {health = 48, headshot_mult = 3},
			death_wish = {health = 48, headshot_mult = 3},
			crackdown = {health = 48, headshot_mult = 3}
		},
		deathvox_sniper = { -- mk 1 values complete. lower difficulty curve structure.
			not_a_real_difficulty = {health = 8, headshot_mult = 3},
			normal = {health = 8, headshot_mult = 3},
			hard = {health = 8, headshot_mult = 3},
			very_hard = {health = 8, headshot_mult = 3},
			overkill = {health = 12, headshot_mult = 3},
			mayhem = {health = 12, headshot_mult = 3},
			death_wish = {health = 12, headshot_mult = 3},
			crackdown = {health = 15, headshot_mult = 3}
		},
		deathvox_greendozer = { -- mk 2 values complete. Tiering implemented.
			not_a_real_difficulty = {health = 500, headshot_mult = 5},
			normal = {health = 500, headshot_mult = 5},
			hard = {health = 500, headshot_mult = 5},
			very_hard = {health = 600, headshot_mult = 5},
			overkill = {health = 600, headshot_mult = 5},
			mayhem = {health = 750, headshot_mult = 5},
			death_wish = {health = 750, headshot_mult = 5},
			crackdown = {health = 875, headshot_mult = 5}
		},
		deathvox_blackdozer = { -- mk 1 values complete. Copies greendozer.
			not_a_real_difficulty = {health = 500, headshot_mult = 5},
			normal = {health = 500, headshot_mult = 5},
			hard = {health = 500, headshot_mult = 5},
			very_hard = {health = 600, headshot_mult = 5},
			overkill = {health = 600, headshot_mult = 5},
			mayhem = {health = 750, headshot_mult = 5},
			death_wish = {health = 750, headshot_mult = 5},
			crackdown = {health = 875, headshot_mult = 5}
		},
		deathvox_lmgdozer = { -- mk 1 values complete. Copies greendozer.
			not_a_real_difficulty = {health = 500, headshot_mult = 5},
			normal = {health = 500, headshot_mult = 5},
			hard = {health = 500, headshot_mult = 5},
			very_hard = {health = 600, headshot_mult = 5},
			overkill = {health = 600, headshot_mult = 5},
			mayhem = {health = 750, headshot_mult = 5},
			death_wish = {health = 750, headshot_mult = 5},
			crackdown = {health = 875, headshot_mult = 5}
		},
		deathvox_medicdozer = { -- mk 2 values complete. Copies greendozer.
			not_a_real_difficulty = {health = 500, headshot_mult = 5},
			normal = {health = 500, headshot_mult = 5},
			hard = {health = 500, headshot_mult = 5},
			very_hard = {health = 600, headshot_mult = 5},
			overkill = {health = 600, headshot_mult = 5},
			mayhem = {health = 750, headshot_mult = 5},
			death_wish = {health = 750, headshot_mult = 5},
			crackdown = {health = 875, headshot_mult = 5}
		},
		deathvox_guarddozer = { -- mk 1 values complete. Copies greendozer.
			not_a_real_difficulty = {health = 500, headshot_mult = 5},
			normal = {health = 500, headshot_mult = 5},
			hard = {health = 500, headshot_mult = 5},
			very_hard = {health = 600, headshot_mult = 5},
			overkill = {health = 600, headshot_mult = 5},
			mayhem = {health = 750, headshot_mult = 5},
			death_wish = {health = 750, headshot_mult = 5},
			crackdown = {health = 875, headshot_mult = 5}
		},
		deathvox_grenadier = { -- mk 2 values complete. Based on heavy.
			not_a_real_difficulty = {health = 16, headshot_mult = 3},
			normal = {health = 24, headshot_mult = 3},
			hard = {health = 24, headshot_mult = 3},
			very_hard = {health = 48, headshot_mult = 3},
			overkill = {health = 48, headshot_mult = 3},
			mayhem = {health = 96, headshot_mult = 3},
			death_wish = {health = 96, headshot_mult = 3},
			crackdown = {health = 101, headshot_mult = 3}
		},
		deathvox_cop_pistol = {  -- mk 2 values complete. Consistent on all diffs.
			not_a_real_difficulty = {health = 10, headshot_mult = 1},
			normal = {health = 15, headshot_mult = 3},
			hard = {health = 15, headshot_mult = 3},
			very_hard = {health = 15, headshot_mult = 3},
			overkill = {health = 15, headshot_mult = 3},
			mayhem = {health = 15, headshot_mult = 3},
			death_wish = {health = 15, headshot_mult = 3},
			crackdown = {health = 15, headshot_mult = 3}
		},
		deathvox_cop_smg = {  -- mk 2 values complete. Consistent on all diffs. Higher health corresponds to armor.
			not_a_real_difficulty = {health = 10, headshot_mult = 1},
			normal = {health = 22, headshot_mult = 3},
			hard = {health = 22, headshot_mult = 3},
			very_hard = {health = 22, headshot_mult = 3},
			overkill = {health = 22, headshot_mult = 3},
			mayhem = {health = 22, headshot_mult = 3},
			death_wish = {health = 22, headshot_mult = 3},
			crackdown = {health = 22, headshot_mult = 3}
		},
		deathvox_cop_revolver = {  -- mk 2 values complete. Consistent on all diffs.
			not_a_real_difficulty = {health = 10, headshot_mult = 1},
			normal = {health = 15, headshot_mult = 3},
			hard = {health = 15, headshot_mult = 3},
			very_hard = {health = 15, headshot_mult = 3},
			overkill = {health = 15, headshot_mult = 3},
			mayhem = {health = 15, headshot_mult = 3},
			death_wish = {health = 15, headshot_mult = 3},
			crackdown = {health = 15, headshot_mult = 3}
		},
		deathvox_cop_shotgun = {  -- mk 2 values complete. Consistent on all diffs.
			not_a_real_difficulty = {health = 10, headshot_mult = 1},
			normal = {health = 15, headshot_mult = 3},
			hard = {health = 15, headshot_mult = 3},
			very_hard = {health = 15, headshot_mult = 3},
			overkill = {health = 15, headshot_mult = 3},
			mayhem = {health = 15, headshot_mult = 3},
			death_wish = {health = 15, headshot_mult = 3},
			crackdown = {health = 15, headshot_mult = 3}
		},
		deathvox_fbi_rookie = {  -- mk 1 values complete. Consistent on all diffs.
			not_a_real_difficulty = {health = 10, headshot_mult = 1},
			normal = {health = 15, headshot_mult = 3},
			hard = {health = 15, headshot_mult = 3},
			very_hard = {health = 15, headshot_mult = 3},
			overkill = {health = 15, headshot_mult = 3},
			mayhem = {health = 15, headshot_mult = 3},
			death_wish = {health = 15, headshot_mult = 3},
			crackdown = {health = 15, headshot_mult = 3}
		},
		deathvox_fbi_hrt = {  -- mk 1 values complete. Consistent on all diffs. Higher health corresponds to armor.
			not_a_real_difficulty = {health = 10, headshot_mult = 1},
			normal = {health = 22, headshot_mult = 3},
			hard = {health = 22, headshot_mult = 3},
			very_hard = {health = 22, headshot_mult = 3},
			overkill = {health = 22, headshot_mult = 3},
			mayhem = {health = 22, headshot_mult = 3},
			death_wish = {health = 22, headshot_mult = 3},
			crackdown = {health = 22, headshot_mult = 3}
		},
		deathvox_fbi_veteran = {  -- mk 1 values complete. Consistent on all diffs.
			not_a_real_difficulty = {health = 10, headshot_mult = 1},
			normal = {health = 22, headshot_mult = 3},
			hard = {health = 22, headshot_mult = 3},
			very_hard = {health = 22, headshot_mult = 3},
			overkill = {health = 22, headshot_mult = 3},
			mayhem = {health = 22, headshot_mult = 3},
			death_wish = {health = 22, headshot_mult = 3},
			crackdown = {health = 22, headshot_mult = 3}
		}
	}
	presets.move_speed.shield_vf = { --custom shield move speed preset, shields never use anything except crouching cbt stances so it shouldn't be a problem
		stand = {
			walk = {
				ntl = {
					strafe = 335,
					fwd = 485,
					bwd = 310
				},
				hos = {
					strafe = 335,
					fwd = 485,
					bwd = 310
				},
				cbt = {
					strafe = 335,
					fwd = 485,
					bwd = 310
				}
			},
			run = {
				hos = {
					strafe = 340,
					fwd = 670,
					bwd = 325
				},
				cbt = {
					strafe = 335,
					fwd = 485,
					bwd = 310
				}
			}
		},
		crouch = {
			walk = {
				hos = {
					strafe = 335,
					fwd = 485,
					bwd = 310
				},
				cbt = {
					strafe = 335,
					fwd = 485,
					bwd = 310
				}
			},
			run = {
				hos = {
					strafe = 335,
					fwd = 485,
					bwd = 310
				},
				cbt = {
					strafe = 335,
					fwd = 485,
					bwd = 310
				}
			}
		}
	}
	presets.dodge.deathvox = {
		speed = 1.7,
		occasions = {
			hit = {
				chance = 1,
				check_timeout = {0, 3},
				variations = {
					side_step = {
						chance = 3,
						timeout = {1, 2},
						shoot_chance = 1,
						shoot_accuracy = 0.8
					},
					roll = {
						chance = 1,
						timeout = {1.2, 2}
					}
				}
			},
			preemptive = {
				chance = 0.9,
				check_timeout = {0, 3},
				variations = {
					side_step = {
						chance = 3,
						timeout = {1, 2},
						shoot_chance = 1,
						shoot_accuracy = 0.8
					},
					roll = {
						chance = 1,
						timeout = {1.2, 2}
					}
				}
			},
			scared = {
				chance = 0.9,
				check_timeout = {0, 3},
				variations = {
					side_step = {
						chance = 5,
						timeout = {1, 2},
						shoot_chance = 1,
						shoot_accuracy = 0.7
					},
					roll = {
						chance = 3,
						timeout = {1.2, 2}
					},
					dive = {
						chance = 1,
						timeout = {1.2, 2}
					}
				}
			}
		}
	}
	presets.dodge.deathvoxchavez = {
		speed = 1.7,
		occasions = {
			hit = {
				chance = 1,
				check_timeout = {0, 3},
				variations = {
					dive = {
						chance = 2,
						timeout = {1, 2},
						shoot_chance = 1,
						shoot_accuracy = 0.9
					},
					roll = {
						chance = 1,
						timeout = {1.2, 2}
					}
				}
			},
			preemptive = {
				chance = 1,
				check_timeout = {0, 3},
				variations = {
					dive = {
						chance = 2,
						timeout = {1, 2},
						shoot_chance = 1,
						shoot_accuracy = 0.9
					},
					roll = {
						chance = 1,
						timeout = {1.2, 2}
					}
				}
			},
			scared = {
				chance = 0.9,
				check_timeout = {0, 2},
				variations = {
					roll = {
						chance = 1,
						timeout = {1.2, 2}
					},
					dive = {
						chance = 2,
						timeout = {1, 2},
						shoot_chance = 1,
						shoot_accuracy = 0.9
					}
				}
			}
		}
	}
	presets.dodge.deathvoxninja = {
		speed = 1.7,
		occasions = {
			hit = {
				chance = 1,
				check_timeout = {0, 1},
				variations = {
					roll = {
						chance = 2,
						timeout = {1, 1.5}
					},
					wheel = {
						chance = 1,
						shoot_chance = 0.9,
						shoot_accuracy = 0.8,
						timeout = {1, 1.5}
					}
				}
			},
			preemptive = {
				chance = 1,
				check_timeout = {0, .6},
				variations = {
					side_step = {
						chance = 1,
						shoot_chance = 0.8,
						shoot_accuracy = 0.6,
						timeout = {1, 1.5}
					},
					roll = {
						chance = 2,
						timeout = {1, 1.5}
					},
					wheel = {
						chance = 2,
						shoot_chance = 0.9,
						shoot_accuracy = 0.8,
						timeout = {1, 1.5}
					}
				}
			},
			scared = {
				chance = 1,
				check_timeout = {0, 0.6},
				variations = {
					side_step = {
						chance = 1,
						shoot_chance = 0.8,
						shoot_accuracy = 0.6,
						timeout = {1, 1.5}
					},
					roll = {
						chance = 3,
						timeout = {1, 1.5}
					},
					wheel = {
						chance = 3,
						shoot_chance = 0.9,
						shoot_accuracy = 0.8,
						timeout = {1, 1.5}
					}
				}
			}
		}
	}
	presets.dodge.deathvox_guard = {
		speed = 1.2,
		occasions = {
			hit = {
				chance = 1,
				check_timeout = {0, 3},
				variations = {
					side_step = {
						chance = 3,
						timeout = {1, 2},
					},
					roll = {
						chance = 1,
						timeout = {1.2, 2}
					}
				}
			},
			scared = {
				chance = 0.9,
				check_timeout = {0, 3},
				variations = {
					side_step = {
						chance = 5,
						timeout = {1, 2},
					},
					roll = {
						chance = 3,
						timeout = {1.2, 2}
					}
				}
			}
		}
	}		
	--[[presets.weapon.deathvox = { -- these notes are mostly out of date. Need further revision to ensure clear usage tracing.
		is_pistol = {},-- used for guards and numerous scripted enemies, as well as beat police.
		is_revolver = {},-- used for medics and numerous scripted enemies, as well as beat police.
		is_rifle = {}, -- clones heavy ar. Used enemy types unknown.
		is_lmg = {},-- used for scripted boss enemies, lmg dozers.
		is_shotgun_pump = {}, -- used for green dozers.
		is_shotgun_mag = {}, -- used for saiga dozers.
		mossberg = {}, -- scripted enemy (e.g. beat cop) shotgun. clones light shotgun.
		is_smg = {}, -- Used for variety of enemies?
		mp9 = {}, -- Clones smg. Used primarily by security, FBI HRT?
		rifle = {}, -- clones light ar. Used enemy types unknown.
		mac11 = {}, -- Clones smg. Used primarily by criminal enemies.
		akimbo_pistol = {}, -- used by boss enemy on Panic Room. Clones pistol.
		mini = {}, -- unused aside from Spring, crime spree enemy. Will revise in future build for possible scripted use.
		flamethrower = {}, -- Currently unused.
		is_light_rifle = {}, -- Used for light AR SWAT. 
		is_heavy_rifle = {}, -- Used for heavy AR.
		is_light_shotgun = {}, -- Used for light shotgun SWAT.
		is_heavy_shotgun = {}, -- Used for heavy shotgun SWAT.
		is_tank_smg = {}, -- used for medic dozer. Clones smg.
		is_bullpup = {}, -- clones light rifle.
		is_sniper = {}, -- initializing sniper.
		is_assault_sniper = {} -- initializing assault sniper preset.
	}]]--
	presets.weapon.deathvox = deep_clone(presets.weapon.deathwish)
	--note to self- clean up is_revolver and make consistent.
	presets.weapon.deathvox.is_revolver = { -- used by medics.
		aim_delay = { -- mark 3 values.
		0,
		0
		},
		focus_delay = 10, -- validated, unchanged.
		focus_dis = 200,
		spread = 20,
		miss_dis = 50,
		RELOAD_SPEED = 0.9, --validated, unchanged.
		melee_speed = 1,
		melee_dmg = 8,
		melee_retry_delay = {
		1,
		2
		},
		range = { --validated, unchanged, consider adjustment to increase engage range.
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		FALLOFF = { 
			{
				dmg_mul = 1,
				r = 100,
				acc = {
					0.7, --note to self 2 values show acc increase with focus delay
					0.9
				},
				recoil = {
					0.8,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = .8, -- new from mark 1.
				r = 500,
				acc = {
					0.6,
					0.85
				},
				recoil = {
					0.8,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0.65,
				r = 1000,
				acc = {
					0.5,
					0.75
				},
				recoil = {
					0.8,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0.5,
				r = 2000,
				acc = {
					0.5,
					0.65
				},
				recoil = {
					1,
					1.3
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 0.37,
				r = 3000,
				acc = {
					0.1,
					0.35
				},
				recoil = {
					1,
					1.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.deathvox.is_pistol = { -- mark 3 values. Currently valid for guards, beat police, low level enemies. basis: presets.weapon.deathwish.is_pistol.
		aim_delay = {
			0,
			0
		},
		focus_delay = 0,
		focus_dis = 200,
		spread = 20,
		miss_dis = 50,
		RELOAD_SPEED = 1.4, -- validated, unchanged.
		melee_speed = presets.weapon.expert.is_pistol.melee_speed,
		melee_dmg = 20,
		melee_retry_delay = presets.weapon.expert.is_pistol.melee_retry_delay,
		range = {
			optimal = 3200, -- validated, unchanged.
			far = 5000,
			close = 2000
		},
		FALLOFF = {
			{
				dmg_mul = 1,
				r = 100,
				acc = {
					0.9,
					0.95
				},
				recoil = {
					0.15,
					0.25
				},
				mode = {
					0,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 500,
				acc = {
					0.9,
					0.95
				},
				recoil = {
					0.15,
					0.3
				},
				mode = {
					0,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = .8,
				r = 1000,
				acc = {
					0.7,
					0.8
				},
				recoil = {
					0.25,
					0.3
				},
				mode = {
					0,
					1,
					0,
					0
				}
			},
			{
				dmg_mul = .65,
				r = 2000,
				acc = {
					0.6,
					0.7
				},
				recoil = {
					0.4,
					0.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = .6,
				r = 3000,
				acc = {
					0.6,
					0.65
				},
				recoil = {
					0.6,
					0.8
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = .5, -- no flat damage.
				r = 4000,
				acc = {
					0.2,
					0.60 -- no infinite range.
				},
				recoil = {
					1,
					1.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.deathvox.is_shotgun_pump = { -- mark 5 values. Assumes CD base damage 500. Extremely dangerous close range, less so further out. Slower to fire.
		aim_delay = {
			0,
			0
		},
		focus_delay = 5, -- re-added from lower difficulties.
		focus_dis = 200,
		spread = 15,
		miss_dis = 20,
		RELOAD_SPEED = 1.4, --unchanged, validated.
		melee_speed = 1,
		melee_dmg = 20,
		melee_retry_delay = presets.weapon.expert.is_shotgun_pump.melee_retry_delay,
		range = { -- using expert ranges. Should have effect of causing enemy to fire when closer.
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		FALLOFF = {
			{
				dmg_mul = 1,
				r = 100,
				acc = { -- Vanilla .95-.95.
					0.95,
					1
				},
				recoil = {
					1,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1, -- no falloff to 5 meters. Falloff arc undergoes bifurcal distortion.
				r = 500,
				acc = {
					0.7,
					0.95
				},
				recoil = {
					1,
					1.25
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = .875,
				r = 1000,
				acc = {
					0.5,
					0.8
				},
				recoil = {
					1,
					1.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = .400,
				r = 2000,
				acc = {
					0.45,
					0.65
				},
				recoil = {
					1.25,
					1.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = .150,
				r = 3000,
				acc = {
					0.3,
					0.5
				},
				recoil = { -- greater max recoil for conveyance purposes.
					1.5,
					2.25
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.deathvox.is_shotgun_mag = { -- mark 4 values. Assumes CD base damage 225. The danger isn't the damage, it's the low recoil! Extremely hazardous at close range.
		aim_delay = {
			0,
			0
		},
		focus_delay = 5, -- re-added from lower difficulties.
		focus_dis = 200,
		spread = 15,
		miss_dis = 20,
		RELOAD_SPEED = 1.4, --unchanged, validated.
		melee_speed = 1,
		melee_dmg = 20,
		melee_retry_delay = presets.weapon.expert.is_shotgun_pump.melee_retry_delay,
		range = {
			optimal = 3000,
			far = 5000,
			close = 2000
		},
		FALLOFF = {
			{
				dmg_mul = 1,
				r = 100,
				acc = {
					0.95,
					0.95
				},
				recoil = {
					0.5,
					1.0
				},
				mode = {
					0,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 500,
				acc = { -- reduced lower end, base game .7.
					0.5,
					0.95
				},
				recoil = {
					0.5,
					1.0
				},
				mode = {
					0,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = .93,
				r = 1000,
				acc = { -- reduced lower end, base game .5.
					0.4,
					0.85
				},
				recoil = {
					0.7,
					1.1
				},
				mode = {
					1,
					1,
					0,
					0
				}
			},
			{
				dmg_mul = .7,
				r = 2000,
				acc = { -- reduced lower end, base game .35.
					0.35,
					0.65
				},
				recoil = {
					1.0,
					1.5
				},
				mode = {
					1,
					1,
					0,
					0
				}
			},
			{
				dmg_mul = .3,
				r = 3000,
				acc = {
					0.3,
					0.5
				},
				recoil = {
					1.5,
					1.75
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}

	presets.weapon.deathvox.is_light_rifle = { -- mark 3 values. basis is presets.weapon.deathwish.is_rifle. General goal- more shots, less damage, reduced range.
		aim_delay = {
			0,
			0
		},
		focus_delay = 3, -- Re-added from lower difficulties.
		focus_dis = 200,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 1.4, -- validated, unchanged.
		melee_speed = 1,
		melee_dmg = 20,
		tase_distance = 1500,
		aim_delay_tase = {
			0,
			0
		},
		tase_sphere_cast_radius = 30,
		melee_retry_delay = presets.weapon.expert.is_rifle.melee_retry_delay,
		range = { 
			optimal = 3500,
			far = 6000,  -- currently unchanged. Consider adjustment if needed to improve differentiation. Light should prefer closer range, if so.
			close = 2000
		},
		autofire_rounds = {
			4,
			9
		},
		FALLOFF = {
			{
				dmg_mul = 1,
				r = 100,
				acc = {
					0.9,
					0.975
				},
				recoil = {
					0.25,
					0.3
				},
				mode = {
					0,
					0,
					1,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 500,
				acc = {
					0.875,
					0.95
				},
				recoil = {
					0.25,
					0.3
				},
				mode = {
					0,
					0,
					1,
					1
				}
			},
			{
				dmg_mul = 0.8, --falloff after 5 meters, no flat damage.
				r = 1000,
				acc = {
					0.7,
					0.9
				},
				recoil = { --reduced to increase attack rate at lower range. Base game values .35-.55. No changes to later ranges.
					0.25,
					0.45
				},
				mode = {
					0,
					1,
					1,
					0
				}
			},
			{
				dmg_mul = 0.7,
				r = 2000,
				acc = {
					0.7,
					0.85
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					1,
					1,
					0
				}
			},
			{
				dmg_mul = 0.6,
				r = 3000,
				acc = { -- reduced accuracy begins here. vanilla values .65-.75.
					0.45,
					0.6
				},
				recoil = {
					0.7,
					1.1
				},
				mode = {
					0,
					1,
					0,
					0
				}
			},
			{
				dmg_mul = 0.5,
				r = 4500, -- uses lower difficulty outer bound to begin falloff.
				acc = { -- vanilla values .25-.7.
					0.25,
					0.6
				},
				recoil = {
					1,
					2
				},
				mode = {
					1,
					1,
					0,
					0
				}
			}
		}
	}
	presets.weapon.deathvox.is_heavy_rifle = { -- mark 3 values complete. basis is presets.weapon.deathwish.is_rifle. General goal- fewer shots, more damage, greater range.
		aim_delay = {
			0,
			0
		},
		focus_delay = 3, -- Re-added from lower difficulties.
		focus_dis = 200,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 1.4, -- validated, unchanged.
		melee_speed = 1,
		melee_dmg = 20,
		melee_retry_delay = presets.weapon.expert.is_rifle.melee_retry_delay,
		range = {
			optimal = 3500, -- currently unchanged. Consider adjustment if needed to improve differentiation. Heavies should prefer more range, if so.
			far = 6000,
			close = 2000
		},
		autofire_rounds = {
			4,
			9
		},
		FALLOFF = {
			{
				dmg_mul = 1,
				r = 100,
				acc = {
					0.9,
					0.975
				},
				recoil = {
					0.25,
					0.3
				},
				mode = {
					0,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 500,
				acc = {
					0.875,
					0.95
				},
				recoil = {
					0.25,
					0.3
				},
				mode = {
					0,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 0.9, -- damage falloff begins.
				r = 1000,
				acc = {
					0.7,
					0.9
				},
				recoil = {
					0.35,
					0.55
				},
				mode = {
					0,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = 0.8,
				r = 2000,
				acc = {
					0.7,
					0.85
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					1,
					0,
					0
				}
			},
			{
				dmg_mul = 0.65,
				r = 3000,
				acc = {
					0.65,
					0.75
				},
				recoil = {
					0.7,
					1.1
				},
				mode = {
					0,
					1,
					0,
					0
				}
			},
			{
				dmg_mul = 0.55,
				r = 6000, -- uses longer range, per base game, to maintain long falloff tail.
				acc = {
					0.35, -- increased tail accuracy. Base game values .25-.7.
					0.7
				},
				recoil = {
					1.5, -- increased tail recoil to reduce attack rate. Base game values 1-2.
					2.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.deathvox.is_light_shotgun = { -- mark 3 values complete. basis is presets.weapon.deathwish.is_shotgun_pump. Light shotgunner fires and gains focus faster than Heavy.
		aim_delay = {
			0,
			0
		},
		focus_delay = 4, -- re-added from lower difficulties, but reduced for light shotgunner.
		focus_dis = 200,
		spread = 15,
		miss_dis = 20,
		RELOAD_SPEED = 1.8, -- faster speed reload, vanilla value 1.4
		melee_speed = 1,
		melee_dmg = 20,
		melee_retry_delay = presets.weapon.expert.is_shotgun_pump.melee_retry_delay,
		range = { -- validated, unchanged. I believe same for all shotgun enemy types in base game.
			optimal = 3000,
			far = 5000,
			close = 2000
		},
		FALLOFF = {
			{
				dmg_mul = 1,
				r = 100,
				acc = {
					0.95,
					0.95
				},
				recoil = {
					0.8,
					1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1,
				r = 500,
				acc = {
					0.7,
					0.95
				},
				recoil = { -- slight recoil reduction. Vanilla stats 1-1.25.
					0.9,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = .8,
				r = 1000,
				acc = {
					0.5,
					0.8
				},
				recoil = { -- slight recoil reduction. Vanilla stats 1-1.5.
					1,
					1.3
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = .6, -- lower falloff arc.
				r = 2000,
				acc = {
					0.15,
					0.45
				},
				recoil = { -- return to vanilla recoil.
					1.25,
					1.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = .2,
				r = 3000,
				acc = {
					0.1,
					0.25
				},
				recoil = {
					1.5,
					1.75
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.deathvox.is_heavy_shotgun = { -- mark 3 values complete. basis is presets.weapon.deathwish.is_shotgun_pump. Heavy Shotgunner has conventional focal stats.
		aim_delay = {
			0,
			0
		},
		focus_delay = 5, -- focus delay returned from lower difficulties.
		focus_dis = 200,
		spread = 15,
		miss_dis = 20,
		RELOAD_SPEED = 1.4, -- validated, unchanged.
		melee_speed = 1,
		melee_dmg = 20,
		melee_retry_delay = presets.weapon.expert.is_shotgun_pump.melee_retry_delay,
		range = { -- using expert ranges. Should have effect of causing enemy to fire when closer.
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		FALLOFF = {
			{
				dmg_mul = 1,
				r = 100,
				acc = {
					0.95,
					0.95
				},
				recoil = {
					1,
					1.1
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = 1, -- less falloff at close range versus base game.
				r = 500,
				acc = {
					0.7,
					0.95
				},
				recoil = {
					1,
					1.25
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = .7, -- falloff rate increase versus vanilla.
				r = 1000,
				acc = {
					0.5,
					0.8
				},
				recoil = {
					1,
					1.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = .4,
				r = 2000,
				acc = { -- slight max accuracy increase, base game stats .45-.7.
					0.45,
					0.75
				},
				recoil = {
					1.25,
					1.5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = .2,
				r = 3000,
				acc = {
					0.3,
					0.5
				},
				recoil = {
					1.5,
					1.75
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.deathvox.is_smg = { -- mark 3 values complete. Assumes base damage of 45. basis is presets.weapon.deathwish.is_smg. Currently copies medidozer values.
		aim_delay = {
			0,
			0.1 --re-adding aim delay from lower difficulties.
		},
		focus_delay = 1, --re-adding slight focus delay from lower difficulties.
		focus_dis = 200,
		spread = 15,
		miss_dis = 10,
		RELOAD_SPEED = 1.4, -- validated, unchanged.
		melee_speed = presets.weapon.expert.is_smg.melee_speed,
		melee_dmg = presets.weapon.expert.is_smg.melee_dmg,
		melee_retry_delay = presets.weapon.expert.is_smg.melee_retry_delay,
		range = {
			optimal = 3200,
			far = 6000,
			close = 2000
		},
		autofire_rounds = {
			8,
			16
		},
		FALLOFF = {
			{
				dmg_mul = 1,
				r = 100,
				acc = {
					0.6, -- applying lower bound on accuracy based on lower difficulties.
					0.95
				},
				recoil = {
					0.1,
					0.25
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 500,
				acc = {
					0.6,
					0.75
				},
				recoil = {
					0.1,
					0.3
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = .9, -- applying falloff, unlike DW.
				r = 1000,
				acc = {
					0.5,
					0.75
				},
				recoil = {
					0.35,
					0.5
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = .7,
				r = 2000,
				acc = {
					0.4,
					0.7
				},
				recoil = {
					0.35,
					0.5
				},
				mode = {
					0,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = .6,
				r = 3000,
				acc = {
					0.55,
					0.6
				},
				recoil = {
					0.5,
					1.5
				},
				mode = {
					0,
					0,
					1,
					0
				}
			},
			{
				dmg_mul = .4,
				r = 4500,
				acc = {
					0.3,
					0.6
				},
				recoil = {
					1,
					1.5
				},
				mode = {
					0,
					1,
					0,
					0
				}
			}
		}
	}
	presets.weapon.deathvox.mini = { -- unused and unchanged.
		aim_delay = {
			0.1,
			0.2
		},
		focus_delay = 4,
		focus_dis = 800,
		spread = 20,
		miss_dis = 40,
		RELOAD_SPEED = 0.5,
		melee_speed = 1,
		melee_dmg = 25,
		melee_retry_delay = {
			1,
			2
		},
		range = {
			optimal = 2500,
			far = 5000,
			close = 1000
		},
		autofire_rounds = {
			20,
			40
		},
		FALLOFF = {
			{
				dmg_mul = 5,
				r = 100,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 4,
				r = 500,
				acc = {
					0.5,
					0.7
				},
				recoil = {
					0.4,
					0.7
				},
				mode = {
					0,
					1,
					2,
					8
				}
			},
			{
				dmg_mul = 3.5,
				r = 1000,
				acc = {
					0.4,
					0.6
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					3,
					6,
					6
				}
			},
			{
				dmg_mul = 3,
				r = 2000,
				acc = {
					0.2,
					0.5
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					1,
					2,
					2,
					1
				}
			},
			{
				dmg_mul = 3,
				r = 3000,
				acc = {
					0.1,
					0.35
				},
				recoil = {
					1,
					1.2
				},
				mode = {
					4,
					2,
					1,
					0
				}
			}
		}
	}
	presets.weapon.deathvox.is_lmg = { --mark 4 values complete. Assumes 100 base damage. Going to treat it as a bullethose, making it much more dangerous to approach directly.
		aim_delay = { 
			0.1,
			0.1
		},
		focus_delay = 3,
		focus_dis = 200,
		spread = 24,
		miss_dis = 40,
		RELOAD_SPEED = 0.75,
		melee_speed = 1,
		melee_dmg = 15,
		melee_retry_delay = presets.weapon.normal.is_lmg.melee_retry_delay,
		range = {
			optimal = 3500,
			far = 6000,
			close = 2000
		},
		autofire_rounds = { -- experimental autofire increase. prev values 25, 50.
			55,
			70
		},
		FALLOFF = { 
			{
				dmg_mul = 1,
				r = 100,
				acc = {
					0.8,
					0.9
				},
				recoil = {
					0.25,
					0.5
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 500,
				acc = {
					0.7,
					0.8
				},
				recoil = {
					0.45,
					0.6
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = .8,
				r = 1000,
				acc = {
					0.5,
					0.8
				},
				recoil = {
					0.35,
					0.75
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = .6,
				r = 2000,
				acc = {
					0.4,
					0.65
				},
				recoil = {
					0.4,
					1
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = .3,
				r = 3000,
				acc = {
					0.2,
					0.35
				},
				recoil = {
					0.8,
					2
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = .16,
				r = 6000,
				acc = {
					0.1, -- generally a warning shot at range.
					0.3
				},
				recoil = {
					1.5,
					3
				},
				mode = {
					0,
					0,
					0,
					1
				}
			}
		}
	}
	presets.weapon.deathvox_sniper = {is_rifle = {}, is_assault_sniper = {}}
	presets.weapon.deathvox_sniper.is_rifle = { -- mark 3 values complete. basis is presets.weapon.sniper. For non-assault wave snipers. Headings revised to fit standard format.
		aim_delay = {
			0,
			0.1
		},
		focus_delay = 7,
		focus_dis = 200,
		spread = 30,
		miss_dis = 250,
		RELOAD_SPEED = 1.25,  -- validated, unchanged.
		melee_speed = presets.weapon.normal.is_rifle.melee_speed,
		melee_dmg = presets.weapon.normal.is_rifle.melee_dmg,
		melee_retry_delay = presets.weapon.normal.is_rifle.melee_retry_delay,
		range = { --validated, unchanged.
			optimal = 15000,
			far = 15000,
			close = 15000
		},
		autofire_rounds = presets.weapon.normal.is_rifle.autofire_rounds,
		use_laser = true, -- where the laser change goes.
		FALLOFF = { -- note values do not match frank's table. Largely eyeballed, may need revision.
			{
				dmg_mul = 1,
				r = 700,
				acc = {
					0.4,
					0.95
				},
				recoil = {
					2,
					4
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = .95, -- slight falloff, frank indicates flat damage on DW.
				r = 4500,
				acc = {
					0.1,
					0.75
				},
				recoil = {
					3,
					4
				},
				mode = {
					1,
					0,
					0,
					0
				}
			},
			{
				dmg_mul = .83,
				r = 12000,
				acc = {
					0,
					0.5
				},
				recoil = {
					3,
					5
				},
				mode = {
					1,
					0,
					0,
					0
				}
			}
		}
	}
	presets.weapon.deathvox_sniper.is_assault_sniper = deep_clone(presets.weapon.deathvox_sniper.is_rifle)
	presets.weapon.deathvox.is_assault_sniper = deep_clone(presets.weapon.deathvox_sniper.is_rifle) --defining the assault sniper preset.
	presets.weapon.deathvox.is_assault_sniper.FALLOFF = { -- revising assault sniper falloff values.
		{
			dmg_mul = 1,
			r = 700,
			acc = {
				0, --zeroing base focus accuracy to ensure warning.
				0.95
			},
			recoil = {
				2,
				4
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = .95, -- slight falloff, frank indicates flat damage on DW.
			r = 4500,
			acc = {
				0, --zeroing base focus accuracy to ensure warning.
				0.75
			},
			recoil = {
				3,
				4
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = .83,
			r = 12000,
			acc = {
				0,
				0.5
			},
			recoil = {
				3,
				5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.deathvox.akimbo_pistol = { --mark 1 adjustment. Needs damage increase.
		aim_delay = {
			0,
			0
		},
		focus_delay = 0,
		focus_dis = 200,
		spread = 20,
		miss_dis = 50,
		RELOAD_SPEED = 1.4, -- validated, unchanged.
		melee_speed = presets.weapon.expert.is_pistol.melee_speed,
		melee_dmg = 20,
		melee_retry_delay = presets.weapon.expert.is_pistol.melee_retry_delay,
		autofire_rounds = { -- experimental autofire increase. prev values 25, 50.
			8,
			10
		},
			range = {
			optimal = 3200, -- validated, unchanged.
			far = 5000,
			close = 2000
		},
		FALLOFF = {
			{
				dmg_mul = 1,
				r = 100,
				acc = {
					0.9,
					0.95
				},
				recoil = {
					0.15,
					0.25
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1,
				r = 500,
				acc = {
					0.9,
					0.95
				},
				recoil = {
					0.15,
					0.3
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = .8,
				r = 1000,
				acc = {
					0.7,
					0.8
				},
				recoil = {
					0.25,
					0.3
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = .65,
				r = 2000,
				acc = {
					0.6,
					0.7
				},
				recoil = {
					0.4,
					0.5
				},
				mode = {
					0,
					1,
					0,
					0
				}
			},
			{
				dmg_mul = .6,
				r = 3000,
				acc = {
					0.6,
					0.65
				},
				recoil = {
					0.6,
					0.8
				},
				mode = {
					0,
					1,
					0,
					0
				}
			},
			{
				dmg_mul = .5, -- no flat damage.
				r = 4000,
				acc = {
					0.2,
					0.60 -- no infinite range.
				},
				recoil = {
					1,
					1.5
				},
				mode = {
					0,
					1,
					0,
					0
				}
			}
		}
	}
	presets.weapon.deathvox.is_tank_smg = deep_clone(presets.weapon.deathvox.is_smg) --Used for medidozer. May separate.
	presets.weapon.deathvox.is_cloaker_smg = deep_clone(presets.weapon.deathvox.is_smg) -- clone similar to other vars.
	presets.weapon.deathvox.is_dozer_saiga = deep_clone(presets.weapon.deathvox.is_shotgun_mag)
	presets.weapon.deathvox.is_dozer_pump = deep_clone(presets.weapon.deathvox.is_shotgun_pump)
	presets.weapon.deathvox.is_dozer_lmg = deep_clone(presets.weapon.deathvox.is_lmg)
	presets.weapon.deathvox.is_bullpup = deep_clone(presets.weapon.deathvox.is_light_rifle) 
	presets.weapon.deathvox.mac11 = deep_clone(presets.weapon.deathvox.is_smg) 
	presets.weapon.deathvox.mp9 = deep_clone(presets.weapon.deathvox.is_smg) 
	presets.weapon.deathvox.rifle = deep_clone(presets.weapon.deathvox.is_light_rifle)
	presets.weapon.deathvox.is_sniper = deep_clone(presets.weapon.deathvox.is_light_rifle)
	presets.weapon.deathvox.is_rifle = deep_clone(presets.weapon.deathvox.is_light_rifle)
	presets.weapon.deathvox.mossberg = deep_clone(presets.weapon.deathvox.is_light_shotgun)
	presets.weapon.normal = deep_clone(presets.weapon.deathvox)
	presets.weapon.good = deep_clone(presets.weapon.deathvox)
	presets.weapon.expert = deep_clone(presets.weapon.deathvox)
	presets.weapon.deathwish = deep_clone(presets.weapon.deathvox)
	presets.detection.deathvox = { -- Correct angles for cops so they can actually see you during loud.
		idle = {},
		combat = {},
		recon = {},
		guard = {},
		ntl = {}
	}
	presets.detection.deathvox.idle.dis_max = 10000
	presets.detection.deathvox.idle.angle_max = 240
	presets.detection.deathvox.idle.delay = {
		0,
		0
	}
	presets.detection.deathvox.idle.use_uncover_range = true
	presets.detection.deathvox.combat.dis_max = 10000
	presets.detection.deathvox.combat.angle_max = 240
	presets.detection.deathvox.combat.delay = {
		0,
		0
	}
	presets.detection.deathvox.combat.use_uncover_range = true
	presets.detection.deathvox.recon.dis_max = 10000
	presets.detection.deathvox.recon.angle_max = 240
	presets.detection.deathvox.recon.delay = {
		0,
		0
	}
	presets.detection.deathvox.recon.use_uncover_range = true
	presets.detection.deathvox.guard.dis_max = 10000
	presets.detection.deathvox.guard.angle_max = 240
	presets.detection.deathvox.guard.delay = {
		0,
		0
	}
	presets.detection.deathvox.ntl.dis_max = 4000
	presets.detection.deathvox.ntl.angle_max = 120
	presets.detection.deathvox.ntl.delay = {
		0.2,
		2
	}
	
	return presets
end
	
function CharacterTweakData:_init_deathvox(presets)
	self.deathvox_guard = deep_clone(self.security)
	self.deathvox_guard.detection = presets.detection.guard
	self.deathvox_guard.ignore_medic_revive_animation = true --no revive animation. may require curving on lower diffs.
	self.deathvox_guard.suppression = nil -- should be easy on diffs below CD.
	self.deathvox_guard.surrender = presets.surrender.easy
	self.deathvox_guard.move_speed = presets.move_speed.very_fast -- should be normal on diffs below CD.
	self.deathvox_guard.ecm_vulnerability = 0 -- should be changed for lower diffs. See commented out code below for values.
--	self.deathvox_guard.ecm_vulnerability = 1
--	self.deathvox_guard.ecm_hurts = {
--		ears = {
--			max_duration = 10,
--			min_duration = 8
--		}
--	}	
	self.deathvox_guard.dodge = presets.dodge.deathvox_guard -- should be poor on diffs below CD.
	self.deathvox_guard.deathguard = true 
	self.deathvox_guard.no_arrest = false 
	self.deathvox_guard.factory_weapon_id = {"wpn_deathvox_guard_pistol"}
	self.deathvox_guard.use_factory = true
	self.deathvox_guard.HEALTH_INIT = 15
	self.deathvox_guard.headshot_dmg_mul = 3
	self.deathvox_guard.weapon = deep_clone(presets.weapon.deathvox)
	self.deathvox_guard.access = "security" --fixes SO problem
	self.deathvox_guard.die_sound_event = "x01a_any_3p" -- pain lines are death lines for these units.
	table.insert(self._enemy_list, "deathvox_guard")

	self.deathvox_gman = deep_clone(self.deathvox_guard)
	self.deathvox_gman.ignore_medic_revive_animation = true --no revive animation.
	self.deathvox_gman.ignore_ecm_for_pager = true
	self.deathvox_gman.suppression = nil
	self.deathvox_gman.surrender = nil -- cannot be intimidated.
	self.deathvox_gman.move_speed = presets.move_speed.very_fast
	self.deathvox_gman.ecm_vulnerability = 0
	self.deathvox_gman.dodge = presets.dodge.deathvox_guard
	self.deathvox_gman.no_arrest = false -- causes too many issues.
	self.deathvox_gman.die_sound_event = "x01a_any_3p" -- pain lines are death lines for these units.
	table.insert(self._enemy_list, "deathvox_gman")
	local is_classic
	if self:get_ai_group_type() == "classic" then
		is_classic = true
	end
	self.deathvox_lightar = deep_clone(self.city_swat)
	self.deathvox_lightar.speech_prefix_p1 = "l1d"
	self.deathvox_lightar.speech_prefix_p2 = nil
	self.deathvox_lightar.speech_prefix_count = nil
	self.deathvox_lightar.detection = presets.detection.deathvox
	self.deathvox_lightar.ignore_medic_revive_animation = true  -- no revive animation. may require curving on lower diffs.
	self.deathvox_lightar.suppression = presets.suppression.hard_agg -- should be hard_def on N through OVK.
	self.deathvox_lightar.surrender = presets.surrender.hard -- should be normal on diffs below CD.
	self.deathvox_lightar.move_speed = presets.move_speed.very_fast -- should be fast on diffs N, H.
	self.deathvox_lightar.surrender_break_time = {6, 8}
	self.deathvox_lightar.ecm_vulnerability = 1
	self.deathvox_lightar.ecm_hurts = {
		ears = {min_duration = 6, max_duration = 8}
	}
	self.deathvox_lightar.dodge = presets.dodge.deathvoxninja -- should be athletic on diffs below CD.
	self.deathvox_lightar.deathguard = true
	self.deathvox_lightar.no_arrest = true
	self.deathvox_lightar.steal_loot = true
	self.deathvox_lightar.rescue_hostages = true
	self.deathvox_lightar.weapon = deep_clone(presets.weapon.deathvox)
	self.deathvox_lightar.factory_weapon_id = {"wpn_deathvox_light_ar"}
	self.deathvox_lightar.use_factory = true
	self.deathvox_lightar.HEALTH_INIT = 48
	self.deathvox_lightar.headshot_dmg_mul = 3
	self.deathvox_lightar.access = "any"
	if is_classic then
		self.deathvox_lightar.custom_voicework = "pdth"
	else
		self.deathvox_lightar.custom_voicework = "light"
	end
	table.insert(self._enemy_list, "deathvox_lightar")
	
	self.deathvox_lightshot = deep_clone(self.city_swat)
	self.deathvox_lightshot.speech_prefix_p1 = "l1d"
	self.deathvox_lightshot.speech_prefix_p2 = nil
	self.deathvox_lightshot.speech_prefix_count = nil
	self.deathvox_lightshot.detection = presets.detection.deathvox
	self.deathvox_lightshot.ignore_medic_revive_animation = true  -- no revive animation. may require curving on lower diffs.
	self.deathvox_lightshot.suppression = presets.suppression.hard_agg -- should be hard_def on N through OVK.
	self.deathvox_lightshot.surrender = presets.surrender.normal -- should be normal on diffs below CD.
	self.deathvox_lightshot.move_speed = presets.move_speed.very_fast -- should be fast on diffs N, H.
	self.deathvox_lightshot.surrender_break_time = {6, 8} 
	self.deathvox_lightshot.ecm_vulnerability = 1
	self.deathvox_lightshot.ecm_hurts = {
		ears = {min_duration = 6, max_duration = 8}
	}
	self.deathvox_lightshot.dodge = presets.dodge.deathvoxninja -- should be athletic on diffs below CD.
	self.deathvox_lightshot.deathguard = true
	self.deathvox_lightshot.no_arrest = true
	self.deathvox_lightshot.steal_loot = true
	self.deathvox_lightshot.rescue_hostages = true
	self.deathvox_lightshot.weapon = deep_clone(presets.weapon.deathvox)
	self.deathvox_lightshot.factory_weapon_id = {"wpn_deathvox_shotgun_light"}
	self.deathvox_lightshot.use_factory = true
	self.deathvox_lightshot.HEALTH_INIT = 48
	self.deathvox_lightshot.headshot_dmg_mul = 3
	self.deathvox_lightshot.access = "any"
	if is_classic then
		self.deathvox_lightshot.custom_voicework = "pdth"
	else
		self.deathvox_lightshot.custom_voicework = "light"
	end
	table.insert(self._enemy_list, "deathvox_lightshot")
	
	self.deathvox_heavyar = deep_clone(self.city_swat)
	self.deathvox_heavyar.speech_prefix_p1 = "l3d"
	self.deathvox_heavyar.speech_prefix_p2 = nil
	self.deathvox_heavyar.speech_prefix_count = nil
	self.deathvox_heavyar.detection = presets.detection.deathvox
	self.deathvox_heavyar.ignore_medic_revive_animation = true  --no revive animation. may require curving on lower diffs.
	self.deathvox_heavyar.damage.hurt_severity = presets.hurt_severities.light_hurt_fire_poison -- may require curving on lower diffs.
	self.deathvox_heavyar.suppression = presets.suppression.hard_agg -- hard_agg on all diffs.
	self.deathvox_heavyar.surrender = presets.surrender.special -- should be normal on N/H, hard on VH-DW.
	self.deathvox_heavyar.move_speed = presets.move_speed.fast -- fast on all diffs.
	self.deathvox_heavyar.surrender_break_time = {6, 8}
	self.deathvox_heavyar.ecm_vulnerability = 1
	self.deathvox_heavyar.ecm_hurts = {
		ears = {min_duration = 6, max_duration = 8}
	}
	self.deathvox_heavyar.dodge = presets.dodge.deathvox -- should be heavy on diffs below CD.
	self.deathvox_heavyar.deathguard = true
	self.deathvox_heavyar.no_arrest = true
	self.deathvox_heavyar.steal_loot = true
	self.deathvox_heavyar.rescue_hostages = true
	self.deathvox_heavyar.weapon = deep_clone(presets.weapon.deathvox)
	self.deathvox_heavyar.factory_weapon_id = {"wpn_deathvox_heavy_ar"}
	self.deathvox_heavyar.use_factory = true
	self.deathvox_heavyar.HEALTH_INIT = 101 -- new with final 2017 pass.
	self.deathvox_heavyar.headshot_dmg_mul = 3
	self.deathvox_heavyar.damage.explosion_damage_mul = 0.7 -- may require curving on lower diffs.
	self.deathvox_heavyar.access = "any"
	if is_classic then
		self.deathvox_heavyar.custom_voicework = "pdth"
	else
		self.deathvox_heavyar.custom_voicework = "heavy"
	end
	table.insert(self._enemy_list, "deathvox_heavyar")
	
	self.deathvox_heavyshot = deep_clone(self.city_swat)
	self.deathvox_heavyshot.speech_prefix_p1 = "l4d"
	self.deathvox_heavyshot.speech_prefix_p2 = nil
	self.deathvox_heavyshot.speech_prefix_count = nil
	self.deathvox_heavyshot.detection = presets.detection.deathvox
	self.deathvox_heavyshot.ignore_medic_revive_animation = true  -- no revive animation. may require curving on lower diffs.
	self.deathvox_heavyshot.damage.hurt_severity = presets.hurt_severities.light_hurt_fire_poison -- may require curving on lower diffs.
	self.deathvox_heavyshot.suppression = presets.suppression.hard_agg -- hard_agg on all diffs.
	self.deathvox_heavyshot.surrender = presets.surrender.special -- should be normal on N/H, hard on VH-DW.
	self.deathvox_heavyshot.move_speed = presets.move_speed.fast -- fast on all diffs.
	self.deathvox_heavyshot.surrender_break_time = {6, 8} 
	self.deathvox_heavyshot.ecm_vulnerability = 1
	self.deathvox_heavyshot.ecm_hurts = {
		ears = {min_duration = 6, max_duration = 8}
	}
	self.deathvox_heavyshot.dodge = presets.dodge.deathvox -- should be heavy on diffs below CD.
	self.deathvox_heavyshot.deathguard = true
	self.deathvox_heavyshot.no_arrest = true
	self.deathvox_heavyshot.steal_loot = true
	self.deathvox_heavyshot.rescue_hostages = true
	self.deathvox_heavyshot.weapon = deep_clone(presets.weapon.deathvox)
	self.deathvox_heavyshot.factory_weapon_id = {"wpn_deathvox_shotgun_heavy"}
	self.deathvox_heavyshot.use_factory = true
	self.deathvox_heavyshot.HEALTH_INIT = 101 -- new with final 2017 pass.
	self.deathvox_heavyshot.headshot_dmg_mul = 3
	self.deathvox_heavyshot.damage.explosion_damage_mul = 0.7 -- may require curving on lower diffs.
	self.deathvox_heavyshot.access = "any"
	if is_classic then
		self.deathvox_heavyshot.custom_voicework = "pdth"
	else
		self.deathvox_heavyshot.custom_voicework = "heavy"
	end
	table.insert(self._enemy_list, "deathvox_heavyshot")
	
	self.deathvox_shield = deep_clone(self.shield)
	self.deathvox_shield.speech_prefix_p1 = "l5d"
	self.deathvox_shield.speech_prefix_p2 = nil
	self.deathvox_shield.speech_prefix_count = nil
	self.deathvox_shield.tags = {"shield"} -- just to be sure it's being applied.
	self.deathvox_shield.detection = presets.detection.deathvox
	self.deathvox_shield.ignore_medic_revive_animation = true  --no revive animation. In base.
	self.deathvox_shield.damage.hurt_severity = presets.hurt_severities.only_explosion_hurts
	self.deathvox_shield.damage.hurt_severity.tase = false
	self.deathvox_shield.suppression = nil
	self.deathvox_shield.surrender = nil
	self.deathvox_shield.move_speed = presets.move_speed.shield_vf -- using a custom shield speed preset. same on all diffs.
	self.deathvox_shield.ecm_vulnerability = .9 -- same as base.
	self.deathvox_shield.ecm_hurts = {
		ears = {min_duration = 6, max_duration = 8} -- same as general enemies, less than vanilla. leave for all diffs.
	}
	self.deathvox_shield.deathguard = true
	self.deathvox_shield.no_arrest = true
	self.deathvox_shield.steal_loot = nil -- setting this true harmed gameplay.
	self.deathvox_shield.rescue_hostages = false
	self.deathvox_shield.weapon = deep_clone(presets.weapon.deathvox) -- should be pistol on N,H.
	self.deathvox_shield.HEALTH_INIT = 72
	self.deathvox_shield.headshot_dmg_mul = 3
	self.deathvox_shield.is_special_unit = "shield"	
	self.deathvox_shield.access = "any"
	self.deathvox_shield.no_retreat = false
	table.insert(self._enemy_list, "deathvox_shield")
	
	self.deathvox_medic = deep_clone(self.medic)
	self.deathvox_medic.tags = {"medic"} --just making sure tag applies.
	self.deathvox_medic.detection = presets.detection.deathvox
	self.deathvox_medic.ignore_medic_revive_animation = true  --no revive animation. may require curving on lower diffs.
	self.deathvox_medic.damage.hurt_severity = presets.hurt_severities.only_fire_and_poison_hurts -- added to make code consistent.
	self.deathvox_medic.suppression = nil
	self.deathvox_medic.surrender = nil
	self.deathvox_medic.move_speed = presets.move_speed.very_fast -- same for all diffs.
	self.deathvox_medic.surrender_break_time = {7, 12} 
	self.deathvox_medic.ecm_vulnerability = 1
	self.deathvox_medic.ecm_hurts = {
		ears = {min_duration = 8, max_duration = 10}
	}
	self.deathvox_medic.dodge = presets.dodge.deathvox -- should be athletic for lower diffs.
	self.deathvox_medic.deathguard = false
	self.deathvox_medic.no_arrest = true 
	self.deathvox_medic.steal_loot = nil
	self.deathvox_medic.rescue_hostages = false
	self.deathvox_medic.weapon = deep_clone(presets.weapon.deathvox)
	self.deathvox_medic.use_factory = true
	self.deathvox_medic.dv_medic_heal = true -- dont touch, makes him use the death vox healing. Note should be disabled for lower diffs.
	self.deathvox_medic.factory_weapon_id = {"wpn_deathvox_medic_pistol"} -- Should be light AR for diffs below CD.
	self.deathvox_medic.HEALTH_INIT = 48
	self.deathvox_medic.headshot_dmg_mul = 3
	self.deathvox_medic.is_special_unit = "medic"
	self.deathvox_medic.access = "any"
	self.deathvox_medic.no_retreat = false
	table.insert(self._enemy_list, "deathvox_medic") 

	self.deathvox_taser = deep_clone(self.taser)
	self.deathvox_taser.tags = {"taser"} -- just making sure tag applies.
	self.deathvox_taser.detection = presets.detection.deathvox
	self.deathvox_taser.ignore_medic_revive_animation = true  --no revive animation. may require curving on lower diffs.
	self.deathvox_taser.damage.hurt_severity = presets.hurt_severities.only_light_hurt_and_fire -- may require curving on lower diffs.
	self.deathvox_taser.damage.hurt_severity.tase = false
	self.deathvox_taser.suppression = nil 
	self.deathvox_taser.surrender = nil 
	self.deathvox_taser.move_speed = presets.move_speed.very_fast -- should be fast on N-OVK.
	self.deathvox_taser.surrender_break_time = {7, 12} 
	self.deathvox_taser.ecm_vulnerability = 0.9 -- in base.
	self.deathvox_taser.ecm_hurts = {
		ears = {min_duration = 6, max_duration = 8} -- in base.
	}
	self.deathvox_taser.dodge = presets.dodge.deathvox -- should be athletic on MH/DW, average on VH/OVK, heavy on N/H. 
	self.deathvox_taser.deathguard = true 
	self.deathvox_taser.no_arrest = true
	self.deathvox_taser.steal_loot = nil
	self.deathvox_taser.rescue_hostages = false
	self.deathvox_taser.HEALTH_INIT = 101 -- new with final 2017 pass.
	self.deathvox_taser.headshot_dmg_mul = 3
	self.deathvox_taser.is_special_unit = "taser"
	self.deathvox_taser.access = "any"
	self.deathvox_taser.custom_voicework = "taser"
	self.deathvox_taser.no_retreat = false
	table.insert(self._enemy_list, "deathvox_taser") 

	self.deathvox_cloaker = deep_clone(self.spooc)
	self.deathvox_cloaker.tags = {"spooc"} -- just making sure tag applies.
	self.deathvox_cloaker.detection = presets.detection.deathvox
	self.deathvox_cloaker.ignore_medic_revive_animation = true  --no revive animation. same on all diffs.
	self.deathvox_cloaker.suppression = nil
	self.deathvox_cloaker.surrender = nil
	self.deathvox_cloaker.move_speed = presets.move_speed.lightning -- same on all diffs.
	self.deathvox_cloaker.HEALTH_INIT = 96
	self.deathvox_cloaker.headshot_dmg_mul = 3
	self.deathvox_cloaker.surrender_break_time = {4, 6} 
	self.deathvox_cloaker.ecm_vulnerability = 0
	self.deathvox_cloaker.dodge = presets.dodge.deathvoxninja -- should be ninja on all diffs below CD.
	self.deathvox_cloaker.deathguard = true 
	self.deathvox_cloaker.no_arrest = true
	self.deathvox_cloaker.steal_loot = nil
	self.deathvox_cloaker.rescue_hostages = false
	self.deathvox_cloaker.factory_weapon_id = {"wpn_deathvox_cloaker"}
	self.deathvox_cloaker.use_factory = true
	self.deathvox_cloaker.is_special_unit = "spooc"
	self.deathvox_cloaker.access = "any"
	self.deathvox_cloaker.no_retreat = false
	self.deathvox_cloaker.spooc_attack_use_smoke_chance = 0

	table.insert(self._enemy_list, "deathvox_cloaker") 

	self.deathvox_sniper = deep_clone(self.sniper)
	self.deathvox_sniper.tags = {"sniper"} -- just making sure tag applies.
	self.deathvox_sniper.detection = presets.detection.deathvox
	self.deathvox_sniper.ignore_medic_revive_animation = false  -- revive animation.
	self.deathvox_sniper.suppression = nil -- same on all diffs.
	self.deathvox_sniper.surrender = nil 
	self.deathvox_sniper.move_speed = presets.move_speed.normal -- same as base. Same on all diffs.
	self.deathvox_sniper.surrender_break_time = {4, 6} 
	self.deathvox_sniper.ecm_vulnerability = 0
	self.deathvox_sniper.no_arrest = true
	self.deathvox_sniper.steal_loot = nil
	self.deathvox_sniper.rescue_hostages = false

	self.deathvox_sniper.use_factory = true -- Use a factory weapon
	self.deathvox_sniper.factory_weapon_id = {"wpn_deathvox_sniper"} -- should be laser and not tracer on diffs below CD.
	self.deathvox_sniper.HEALTH_INIT = 15 
	self.deathvox_sniper.headshot_dmg_mul = 3
	self.deathvox_sniper.is_special_unit = "sniper"
	self.deathvox_sniper.access = "any"
	table.insert(self._enemy_list, "deathvox_sniper")
	
	self.deathvox_sniper_assault = deep_clone(self.deathvox_sniper) -- note unit not in use due to poor feedback.
	self.deathvox_sniper_assault.move_speed = presets.move_speed.very_fast
	self.deathvox_sniper_assault.deathguard = true
	self.deathvox_sniper_assault.HEALTH_INIT = 15
	self.deathvox_sniper_assault.headshot_dmg_mul = 3
	self.deathvox_sniper_assault.is_special_unit = "ass_sniper"
	self.deathvox_sniper_assault.access = "any"
	table.insert(self._enemy_list, "deathvox_sniper_assault")

	self.deathvox_tank = deep_clone(self.tank)
	self.deathvox_tank.tags = {"tank"} -- just making sure tag applies.
	self.deathvox_tank.detection = presets.detection.deathvox
	self.deathvox_tank.ignore_medic_revive_animation = false  -- revive animation.
	self.deathvox_tank.damage.hurt_severity = presets.hurt_severities.no_hurts_no_tase -- same on all diffs.
	self.deathvox_tank.suppression = nil
	self.deathvox_tank.surrender = nil
	self.deathvox_tank.surrender_break_time = {4, 6}
	self.deathvox_tank.move_speed = presets.move_speed.slow -- same on all diffs. Same as base. Note revise for "special" dozers.
	self.deathvox_tank.ecm_vulnerability = 0 -- addressing base game ECM vuln bug.
	self.deathvox_tank.ecm_hurts = {
        ears = {min_duration = 1, max_duration = 3} 
    }
	self.deathvox_tank.deathguard = true
	self.deathvox_tank.no_arrest = true
	self.deathvox_tank.steal_loot = nil
	self.deathvox_tank.rescue_hostages = false
	self.deathvox_tank.HEALTH_INIT = 875
	self.deathvox_tank.damage.explosion_damage_mul = 0.3  -- may require curving on lower diffs.
	self.deathvox_tank.is_special_unit = "tank"
	self.deathvox_tank.access = "walk"
	self.deathvox_tank.no_retreat = false
	if is_classic then
		self.deathvox_tank.custom_voicework = "pdthdozer"
	end

	self.deathvox_guarddozer = deep_clone(self.security)
	self.deathvox_guarddozer.tags = {"tank"} -- just making sure tag applies.
	self.deathvox_guarddozer.ignore_medic_revive_animation = false  -- revive animation.
	self.deathvox_guarddozer.damage.hurt_severity = presets.hurt_severities.no_hurts_no_tase -- same on all diffs.
	self.deathvox_guarddozer.suppression = nil
	self.deathvox_guarddozer.surrender = nil
	self.deathvox_guarddozer.surrender_break_time = {4, 6}
	self.deathvox_guarddozer.ecm_vulnerability = 0 -- addressing base game ECM vuln bug.
	self.deathvox_guarddozer.ecm_hurts = {
        ears = {min_duration = 1, max_duration = 3}
    }
	self.deathvox_guarddozer.deathguard = true
	self.deathvox_guarddozer.steal_loot = nil
	self.deathvox_guarddozer.rescue_hostages = false
	self.deathvox_guarddozer.HEALTH_INIT = 875
	self.deathvox_guarddozer.damage.explosion_damage_mul = 0.7  -- may require curving on lower diffs.
	self.deathvox_guarddozer.is_special_unit = "tank"
	self.deathvox_guarddozer.no_retreat = false
	self.deathvox_guarddozer.access = "tank"
	self.deathvox_guarddozer.no_arrest = false
	self.deathvox_guarddozer.calls_in = true
	self.deathvox_guarddozer.detection = presets.detection.guard
	self.deathvox_guarddozer.stealth_instant_kill = false
	table.insert(self._enemy_list, "deathvox_guarddozer")
	
	self.deathvox_greendozer = deep_clone(self.deathvox_tank)
	self.deathvox_greendozer.use_factory = true -- Use a factory weapon
	self.deathvox_greendozer.factory_weapon_id = {"wpn_deathvox_greendozer"} 
	self.deathvox_greendozer.access = "tank"
	table.insert(self._enemy_list, "deathvox_greendozer")

	self.deathvox_blackdozer = deep_clone(self.deathvox_tank)
	self.deathvox_blackdozer.use_factory = true -- Use a factory weapon
	self.deathvox_blackdozer.factory_weapon_id = {"wpn_deathvox_blackdozer"} 
	self.deathvox_blackdozer.access = "tank"
	table.insert(self._enemy_list, "deathvox_blackdozer")

	self.deathvox_lmgdozer = deep_clone(self.deathvox_tank)
	self.deathvox_lmgdozer.use_factory = true -- Use a factory weapon
	self.deathvox_lmgdozer.factory_weapon_id = {"wpn_deathvox_lmgdozer"} 
	self.deathvox_lmgdozer.access = "tank"
	table.insert(self._enemy_list, "deathvox_lmgdozer")
	
	self.deathvox_medicdozer = deep_clone(self.deathvox_tank)
	self.deathvox_medicdozer.tags = {"tank", "medic"}
	self.deathvox_medicdozer.use_factory = true -- Use a factory weapon
	self.deathvox_medicdozer.factory_weapon_id = {"wpn_deathvox_heavy_ar"} 
	self.deathvox_medicdozer.dv_medic_heal = true -- don't touch, makes him use the death vox healing
	self.deathvox_medicdozer.custom_voicework = "medicdozer"
	self.deathvox_medicdozer.access = "tank"
	self.deathvox_medicdozer.disable_medic_heal_voice = true
	table.insert(self._enemy_list, "deathvox_medicdozer")

	self.deathvox_grenadier = deep_clone(presets.base)
	self.deathvox_grenadier.tags = {"custom"}
	self.deathvox_grenadier.experience = {}
	self.deathvox_grenadier.weapon = deep_clone(presets.weapon.normal)
	self.deathvox_grenadier.melee_weapon = "knife_1"
	self.deathvox_grenadier.melee_weapon_dmg_multiplier = 1
	self.deathvox_grenadier.weapon_safety_range = 1000
	self.deathvox_grenadier.detection = presets.detection.deathvox
	self.deathvox_grenadier.ignore_medic_revive_animation = true  -- no revive animation. do not touch.
	self.deathvox_grenadier.damage.hurt_severity = presets.hurt_severities.only_light_hurt_and_fire -- immune to poison.
	self.deathvox_grenadier.HEALTH_INIT = 101
	self.deathvox_grenadier.HEALTH_SUICIDE_LIMIT = 0.25
	self.deathvox_grenadier.flammable = true
	self.deathvox_grenadier.use_animation_on_fire_damage = true
	self.deathvox_grenadier.damage.fire_damage_mul = 1
	self.deathvox_grenadier.headshot_dmg_mul = 3
	self.deathvox_grenadier.bag_dmg_mul = 6
	self.deathvox_grenadier.move_speed = presets.move_speed.fast
	self.deathvox_grenadier.no_retreat = false
	self.deathvox_grenadier.no_arrest = true
	self.deathvox_grenadier.surrender = nil
	self.deathvox_grenadier.ecm_vulnerability = 0.9
	self.deathvox_grenadier.ecm_hurts = {
		ears = {min_duration = 6, max_duration = 8}
	}
	self.deathvox_grenadier.surrender_break_time = {4, 6}
	self.deathvox_grenadier.suppression = nil
	self.deathvox_grenadier.weapon_voice = "3"
	self.deathvox_grenadier.experience.cable_tie = "tie_swat"
	self.deathvox_grenadier.access = "any"
	self.deathvox_grenadier.dodge = presets.dodge.athletic
	self.deathvox_grenadier.use_gas = true
	self.deathvox_grenadier.priority_shout = "g29"
	self.deathvox_grenadier.bot_priority_shout = "g29"
	self.deathvox_grenadier.priority_shout_max_dis = 3000
	self.deathvox_grenadier.custom_shout = true
	self.deathvox_grenadier.rescue_hostages = false
	self.deathvox_grenadier.deathguard = true
	self.deathvox_grenadier.chatter = {
		aggressive = true,
		retreat = true,
		go_go = true,
		contact = true,
		entrance = true
	}
	self.deathvox_grenadier.announce_incomming = "incomming_gren"
	self.deathvox_grenadier.spawn_sound_event = "clk_c01x_plu"
	self.deathvox_grenadier.die_sound_event = "rmdc_x02a_any_3p"
	self.deathvox_grenadier.steal_loot = nil
	self.deathvox_grenadier.use_factory = true -- Use a factory weapon
	self.deathvox_grenadier.factory_weapon_id = {"wpn_deathvox_grenadier"} 
	self.deathvox_grenadier.is_special_unit = "boom"
	self.deathvox_grenadier.custom_voicework = "grenadier"
 	table.insert(self._enemy_list, "deathvox_grenadier")
	
	self.deathvox_cop = deep_clone(self.cop)
	self.deathvox_cop.weapon = presets.weapon.deathvox
	self.deathvox_cop.HEALTH_INIT = 15 -- adding current design doc stat. same for all but smg.
	self.deathvox_cop.headshot_dmg_mul = 3
	self.deathvox_cop.access = "cop"
	self.deathvox_cop.silent_priority_shout = "f37"
	self.deathvox_cop.dodge = presets.dodge.average -- same on all diffs. cloned to all cop units.
	self.deathvox_cop.suppression = presets.suppression.easy -- same on all diffs. cloned to all cop units.
	self.deathvox_cop.surrender = presets.surrender.easy -- same on all diffs. cloned to all cop units.
	self.deathvox_cop.deathguard = true
	self.deathvox_cop.chatter = presets.enemy_chatter.cop
	self.deathvox_cop.steal_loot = true
	self.deathvox_cop.die_sound_event = "x01a_any_3p" --pain lines are their death lines because overkill are dumb dumbs
	self.deathvox_cop.detection = presets.detection.deathvox

	self.deathvox_cop_pistol = deep_clone(self.deathvox_cop)
	self.deathvox_cop_pistol.use_factory = true
	self.deathvox_cop_pistol.factory_weapon_id = {"wpn_deathvox_cop_pistol"}
	self.deathvox_cop_pistol.die_sound_event = "x01a_any_3p" --pain lines are their death lines because overkill are dumb dumbs
 	table.insert(self._enemy_list, "deathvox_cop_pistol")
	
	self.deathvox_cop_revolver = deep_clone(self.deathvox_cop)
	self.deathvox_cop_revolver.use_factory = true
	self.deathvox_cop_revolver.factory_weapon_id = {"wpn_deathvox_cop_revolver"}
	self.deathvox_cop_revolver.die_sound_event = "x01a_any_3p" --pain lines are their death lines because overkill are dumb dumbs
 	table.insert(self._enemy_list, "deathvox_cop_revolver")
	
	self.deathvox_cop_smg = deep_clone(self.deathvox_cop)
	self.deathvox_cop_smg.HEALTH_INIT = 22 -- based on flak jacket model, revise if incorrect.
	self.deathvox_cop_smg.use_factory = true
	self.deathvox_cop_smg.factory_weapon_id = {"wpn_deathvox_cop_smg"}
	self.deathvox_cop_smg.die_sound_event = "x01a_any_3p" --pain lines are their death lines because overkill are dumb dumbs
 	table.insert(self._enemy_list, "deathvox_cop_smg")
	
	self.deathvox_cop_shotgun = deep_clone(self.deathvox_cop)
	self.deathvox_cop_shotgun.use_factory = true
	self.deathvox_cop_shotgun.factory_weapon_id = {"wpn_deathvox_cop_shotgun"}
	self.deathvox_cop_shotgun.die_sound_event = "x01a_any_3p" --pain lines are their death lines because overkill are dumb dumbs
 	table.insert(self._enemy_list, "deathvox_cop_shotgun")
	
	self.deathvox_fbi_rookie = deep_clone(self.deathvox_cop_pistol) 
	self.deathvox_fbi_rookie.dodge = presets.dodge.poor -- same on all diffs.
	self.deathvox_fbi_rookie.suppression = presets.suppression.easy -- same on all diffs. cloned to all cop units.
	self.deathvox_fbi_rookie.surrender = presets.surrender.easy -- same on all diffs. cloned to all cop units.
	self.deathvox_fbi_rookie.use_factory = true
	self.deathvox_fbi_rookie.factory_weapon_id = {"wpn_deathvox_cop_pistol"}
	self.deathvox_fbi_rookie.die_sound_event = "x01a_any_3p" --pain lines are their death lines because overkill are dumb dumbs
 	table.insert(self._enemy_list, "deathvox_fbi_rookie")

	self.deathvox_fbi_hrt = deep_clone(self.deathvox_cop_smg) -- note retains smg health.
	self.deathvox_fbi_hrt.dodge = presets.dodge.athletic -- same on all diffs.
	self.deathvox_fbi_hrt.suppression = presets.suppression.hard_agg -- same on all diffs.
	self.deathvox_fbi_hrt.surrender = presets.surrender.hard -- same on all diffs.
	self.deathvox_fbi_hrt.use_factory = true
	self.deathvox_fbi_hrt.factory_weapon_id = {"wpn_deathvox_cop_smg"}
	self.deathvox_fbi_hrt.die_sound_event = "x01a_any_3p" --pain lines are their death lines because overkill are dumb dumbs
 	table.insert(self._enemy_list, "deathvox_fbi_hrt")
	
	self.deathvox_fbi_veteran = deep_clone(self.deathvox_cop_smg) -- note retains smg health.
	self.deathvox_fbi_veteran.dodge = presets.dodge.athletic -- same on all diffs.
	self.deathvox_fbi_veteran.suppression = nil -- same on all diffs.
	self.deathvox_fbi_veteran.surrender = nil -- same on all diffs.
	self.deathvox_fbi_veteran.use_factory = true
	self.deathvox_fbi_veteran.factory_weapon_id = {"wpn_deathvox_heavy_ar"}
	self.deathvox_fbi_veteran.die_sound_event = "x01a_any_3p" --pain lines are their death lines because overkill are dumb dumbs
 	table.insert(self._enemy_list, "deathvox_fbi_veteran")
	
end

function CharacterTweakData:crackdown_health_setup()
	local difficulties = {
		"easy",
		"normal",
		"hard",
		"overkill",
		"overkill_145",
		"easy_wish",
		"overkill_290",
		"sm_wish"
	}
	local better_names = {
		"not_a_real_difficulty",
		"normal",
		"hard",
		"very_hard",
		"overkill",
		"mayhem",
		"death_wish",
		"crackdown"
	}
	local difficulty_index = table.index_of(difficulties, Global.game_settings.difficulty)
	local diff_name = better_names[difficulty_index]
	for _, enemy_type in ipairs(self._enemy_list) do
		if self.presets.health_tables[enemy_type] then
			local health_table = self.presets.health_tables[enemy_type]
			if health_table then
				local chosen_diff = health_table[diff_name]
				if chosen_diff then
					self[enemy_type].HEALTH_INIT = chosen_diff["health"]
					self[enemy_type].headshot_dmg_mul = chosen_diff["headshot_mult"]
				end
			end
		end
	end
end

function CharacterTweakData:_set_normal() -- NORMAL specific tweaks begin.

	self:crackdown_health_setup() -- applies health scaling structure.
	self:_set_characters_weapon_preset("deathvox") -- applies weapon scaling structure.
	self:_set_specials_weapon_preset("deathvox") -- applies weapon scaling structure.
	self:_set_characters_melee_preset("2") -- applies enemy melee scaling structure.
	
	if job == "man" then -- fixes base game alert bug on Counterfeit. Must be separately invoked on each diff in current setup.
		self.fbi.calls_in = nil
		self.cop_female.calls_in = nil
		self.cop.calls_in = nil
	end	
	
	self.presets.gang_member_damage.HEALTH_INIT = 250 -- bot health values. Manually set for each diff.
	self.presets.gang_member_damage.MIN_DAMAGE_INTERVAL = 0.35
	self.presets.gang_member_damage.BLEED_OUT_HEALTH_INIT = 250
	
-- guard - NORMAL
	self.deathvox_guard.ignore_medic_revive_animation = false --medic revive anim below CD
	self.deathvox_guard.suppression = deep_clone(self.presets.suppression.easy) -- easy suppression below CD
	self.deathvox_guard.move_speed = deep_clone(self.presets.move_speed.normal) -- normal movespeed below CD
	self.deathvox_guard.ecm_vulnerability = 1 -- ecm vuln below CD
	self.deathvox_guard.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}	
	self.deathvox_guard.dodge = deep_clone(self.presets.dodge.poor) -- poor dodge below CD
--lightar - NORMAL
	self.deathvox_lightar.ignore_medic_revive_animation = false -- medic revive anim (below CD)
	self.deathvox_lightar.suppression = deep_clone(self.presets.suppression.hard_def) -- suppression to hard_def (N thru OVK)
	self.deathvox_lightar.surrender = deep_clone(self.presets.surrender.normal)  --	surrender to normal (all below CD)
	self.deathvox_lightar.move_speed = deep_clone(self.presets.move_speed.fast) -- move_speed to fast (N, H)
	self.deathvox_lightar.dodge = deep_clone(self.presets.dodge.athletic) -- dodge to athletic (all below CD)
	
--lightshot - NORMAL
	self.deathvox_lightshot.ignore_medic_revive_animation = false -- medic revive anim (below CD)
	self.deathvox_lightshot.suppression = deep_clone(self.presets.suppression.hard_def) -- suppression to hard_def (N thru OVK)
	self.deathvox_lightshot.surrender = deep_clone(self.presets.surrender.normal)  -- surrender to normal (all below CD)
	self.deathvox_lightshot.move_speed = deep_clone(self.presets.move_speed.fast) -- move_speed to fast (N, H)
	self.deathvox_lightshot.dodge = deep_clone(self.presets.dodge.athletic) -- dodge to athletic (all below CD)
	
--heavyar - NORMAL
	self.deathvox_heavyar.ignore_medic_revive_animation = false -- medic revive animation false (all below MH)
--	NOTE consider curving hurt severities on lower diffs.
	self.deathvox_heavyar.surrender = deep_clone(self.presets.surrender.normal)  -- surrender to normal (on N/H, hard on VH-DW)
	self.deathvox_heavyar.dodge = deep_clone(self.presets.dodge.heavy) -- dodge to heavy (all below CD)
	self.deathvox_heavyar.damage.explosion_damage_mul = 1 -- damage.explosion_damage_mul to 1 on N, H, (0.8 on VH, OVK)
	
--heavyshot - NORMAL
	self.deathvox_heavyshot.ignore_medic_revive_animation = false -- medic revive animation false (all below MH)
--	NOTE consider curving hurt severities on lower diffs.
	self.deathvox_heavyshot.surrender = deep_clone(self.presets.surrender.normal)  -- surrender to normal (on N/H, hard on VH-DW)
	self.deathvox_heavyshot.dodge = deep_clone(self.presets.dodge.heavy) -- dodge to heavy (all below CD)
	self.deathvox_heavyshot.damage.explosion_damage_mul = 1 -- damage.explosion_damage_mul to 1 on N, H, (0.8 on VH, OVK)
	
--shield - NORMAL
--	NOTE ask others to examine weapon use. Is this even functioning properly? Should be pistol on N/H, seems to work?

--medic - NORMAL
	self.deathvox_medic.ignore_medic_revive_animation = false -- medic revive anim (all below CD)
	self.deathvox_medic.dodge = deep_clone(self.presets.dodge.athletic) -- dodge to athletic (all below CD)
	self.deathvox_medic.dv_medic_heal = false -- dv_medic_heal to false (all below CD)
	self.deathvox_medic.factory_weapon_id = {"wpn_deathvox_light_ar"} -- light AR (all below CD). Note uses weaponfactory.
	
--taser - NORMAL
--	NOTE ask others to examine weapon use. Is this functioning properly? how is it curved?
--	set ignore medic revive animation to false (all below MH)
--	NOTE consider curving hurt severities on lower diffs. note tase severity defined separately.
--	set move_speed to fast (N-OVK)
--	set dodge to heavy (on N/H, average on VH/OVK, athletic on MH/DW)
	
--cloaker - NORMAL
	self.deathvox_cloaker.dodge = deep_clone(self.presets.dodge.ninja) -- dodge to ninja (all below CD)

--sniper - NORMAL
--	NOTE need to use laser, not tracer, on diffs below CD.
--	NOTE discuss implementation and use of jarey's glint effect on lower diffs, curve structure.

--tank
	self.deathvox_tank.damage.explosion_damage_mul = 0.7 -- set 0.7 below CD.
--	No specific unit curving for dozers, which all sync off of tank effects.
	
--guarddozer
--	NOTE not synced to tank, which is appropriate.
--	NOTE explosion resist does not appear to require curving.
		
--turrets
--	NOTE turrets need adjustment on lower difficulties.
	
end -- end NORMAL specific tweaks.

function CharacterTweakData:_set_hard() -- HARD specific tweaks begin.

	self:crackdown_health_setup() -- applies health scaling structure.
	self:_set_characters_weapon_preset("deathvox") -- applies weapon scaling structure.
	self:_set_specials_weapon_preset("deathvox") -- applies weapon scaling structure.
	self:_set_characters_melee_preset("2") -- applies enemy melee scaling structure.
	
	if job == "man" then -- fixes base game alert bug on Counterfeit. Must be separately invoked on each diff in current setup.
		self.fbi.calls_in = nil
		self.cop_female.calls_in = nil
		self.cop.calls_in = nil
	end	
	
	self.presets.gang_member_damage.HEALTH_INIT = 250 -- bot health values. Manually set for each diff.
	self.presets.gang_member_damage.MIN_DAMAGE_INTERVAL = 0.35
	self.presets.gang_member_damage.BLEED_OUT_HEALTH_INIT = 250
-- guard - HARD
	self.deathvox_guard.ignore_medic_revive_animation = false --medic revive anim below CD
	self.deathvox_guard.suppression = deep_clone(self.presets.suppression.easy) -- easy suppression below CD
	self.deathvox_guard.move_speed = deep_clone(self.presets.move_speed.normal) -- normal movespeed below CD
	self.deathvox_guard.ecm_vulnerability = 1 -- ecm vuln below CD
	self.deathvox_guard.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}	
	self.deathvox_guard.dodge = deep_clone(self.presets.dodge.poor) -- poor dodge below CD

--	lightar - HARD
	self.deathvox_lightar.ignore_medic_revive_animation = false -- medic revive anim (below CD)
	self.deathvox_lightar.suppression = deep_clone(self.presets.suppression.hard_def) -- suppression to hard_def (N thru OVK)
	self.deathvox_lightar.surrender = deep_clone(self.presets.surrender.normal)  --	surrender to normal (all below CD)
	self.deathvox_lightar.move_speed = deep_clone(self.presets.move_speed.fast) -- move_speed to fast (N, H)
	self.deathvox_lightar.dodge = deep_clone(self.presets.dodge.athletic) --	dodge to athletic (all below CD)
	
--	lightshot - HARD
	self.deathvox_lightshot.ignore_medic_revive_animation = false -- medic revive anim (below CD)
	self.deathvox_lightshot.suppression = deep_clone(self.presets.suppression.hard_def) -- suppression to hard_def (N thru OVK)
	self.deathvox_lightshot.surrender = deep_clone(self.presets.surrender.normal)  -- surrender to normal (all below CD)
	self.deathvox_lightshot.move_speed = deep_clone(self.presets.move_speed.fast) -- move_speed to fast (N, H)
	self.deathvox_lightshot.dodge = deep_clone(self.presets.dodge.athletic) -- dodge to athletic (all below CD)
	
--	heavyar - HARD
	self.deathvox_heavyar.ignore_medic_revive_animation = false -- medic revive animation false (all below MH)
--	NOTE consider curving hurt severities on lower diffs.
	self.deathvox_heavyar.surrender = deep_clone(self.presets.surrender.normal)  -- surrender to normal (on N/H, hard on VH-DW)
	self.deathvox_heavyar.dodge = deep_clone(self.presets.dodge.heavy) -- dodge to heavy (all below CD)
	self.deathvox_heavyar.damage.explosion_damage_mul = 1 -- damage.explosion_damage_mul to 1 on N, H, (0.8 on VH, OVK)
	
--	heavyshot - HARD
	self.deathvox_heavyshot.ignore_medic_revive_animation = false -- medic revive animation false (all below MH)
--	NOTE consider curving hurt severities on lower diffs.
	self.deathvox_heavyshot.surrender = deep_clone(self.presets.surrender.normal)  -- surrender to normal (on N/H, hard on VH-DW)
	self.deathvox_heavyshot.dodge = deep_clone(self.presets.dodge.heavy) -- dodge to heavy (all below CD)
	self.deathvox_heavyshot.damage.explosion_damage_mul = 1 -- damage.explosion_damage_mul to 1 on N, H, (0.8 on VH, OVK)
		
--	shield - HARD
--	medic - HARD
	self.deathvox_medic.ignore_medic_revive_animation = false -- medic revive anim (all below CD)
	self.deathvox_medic.dodge = deep_clone(self.presets.dodge.athletic) -- dodge to athletic (all below CD)
	self.deathvox_medic.dv_medic_heal = false -- dv_medic_heal to false (all below CD)
	self.deathvox_medic.factory_weapon_id = {"wpn_deathvox_light_ar"} -- light AR (all below CD). Note uses weaponfactory.
	
--	taser - HARD
--	cloaker - HARD
	self.deathvox_cloaker.dodge = deep_clone(self.presets.dodge.ninja) -- dodge to ninja (all below CD)
	
--	sniper - HARD
--	tank - HARD
	self.deathvox_tank.damage.explosion_damage_mul = 0.7 -- set 0.7 below CD.
--	No specific unit curving for dozers, which all sync off of tank effects.
	
end -- end HARD specific tweaks.

function CharacterTweakData:_set_overkill() -- VERY HARD specific tweaks begin.

	self:crackdown_health_setup() -- applies health scaling structure.
	self:_set_characters_weapon_preset("deathvox") -- applies weapon scaling structure.
	self:_set_specials_weapon_preset("deathvox") -- applies weapon scaling structure.
	self:_set_characters_melee_preset("2") -- applies enemy melee scaling structure.
	
	if job == "man" then -- fixes base game alert bug on Counterfeit. Must be separately invoked on each diff in current setup.
		self.fbi.calls_in = nil
		self.cop_female.calls_in = nil
		self.cop.calls_in = nil
	end	
	
	self.presets.gang_member_damage.HEALTH_INIT = 300 -- bot health values. Manually set for each diff.
	self.presets.gang_member_damage.MIN_DAMAGE_INTERVAL = 0.35
	self.presets.gang_member_damage.BLEED_OUT_HEALTH_INIT = 300
-- guard - VERY HARD
	self.deathvox_guard.ignore_medic_revive_animation = false --medic revive anim below CD
	self.deathvox_guard.suppression = deep_clone(self.presets.suppression.easy) -- easy suppression below CD
	self.deathvox_guard.move_speed = deep_clone(self.presets.move_speed.normal) -- normal movespeed below CD
	self.deathvox_guard.ecm_vulnerability = 1 -- ecm vuln below CD
	self.deathvox_guard.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}	
	self.deathvox_guard.dodge = deep_clone(self.presets.dodge.poor) -- poor dodge below CD

--	lightar - VERY HARD
	self.deathvox_lightar.ignore_medic_revive_animation = false -- medic revive anim (below CD)
	self.deathvox_lightar.suppression = deep_clone(self.presets.suppression.hard_def) -- suppression to hard_def (N thru OVK)
	self.deathvox_lightar.surrender = deep_clone(self.presets.surrender.normal)  --	surrender to normal (all below CD)
	self.deathvox_lightar.dodge = deep_clone(self.presets.dodge.athletic) --	dodge to athletic (all below CD)
	
--	lightshot - VERY HARD
	self.deathvox_lightshot.ignore_medic_revive_animation = false -- medic revive anim (below CD)
	self.deathvox_lightshot.suppression = deep_clone(self.presets.suppression.hard_def) -- suppression to hard_def (N thru OVK)
	self.deathvox_lightshot.surrender = deep_clone(self.presets.surrender.normal)  -- surrender to normal (all below CD)
	self.deathvox_lightshot.dodge = deep_clone(self.presets.dodge.athletic) -- dodge to athletic (all below CD)
	
--	heavyar - VERY HARD
	self.deathvox_heavyar.ignore_medic_revive_animation = false -- medic revive animation false (all below MH)
--	NOTE consider curving hurt severities on lower diffs.
	self.deathvox_heavyar.surrender = deep_clone(self.presets.surrender.hard)  -- surrender to normal (on N/H, hard on VH-DW)
	self.deathvox_heavyar.dodge = deep_clone(self.presets.dodge.heavy) -- dodge to heavy (all below CD)
	self.deathvox_heavyar.damage.explosion_damage_mul = 0.8 -- damage.explosion_damage_mul to 1 on N, H, (0.8 on VH, OVK)
	
--	heavyshot - VERY HARD
	self.deathvox_heavyshot.ignore_medic_revive_animation = false -- medic revive animation false (all below MH)
--	NOTE consider curving hurt severities on lower diffs.
	self.deathvox_heavyshot.surrender = deep_clone(self.presets.surrender.hard)  -- surrender to normal (on N/H, hard on VH-DW)
	self.deathvox_heavyshot.dodge = deep_clone(self.presets.dodge.heavy) -- dodge to heavy (all below CD)
	self.deathvox_heavyshot.damage.explosion_damage_mul = 0.8 -- damage.explosion_damage_mul to 1 on N, H, (0.8 on VH, OVK)
	
--	shield - VERY HARD
--	medic - VERY HARD
	self.deathvox_medic.ignore_medic_revive_animation = false -- medic revive anim (all below CD)
	self.deathvox_medic.dodge = deep_clone(self.presets.dodge.athletic) -- dodge to athletic (all below CD)
	self.deathvox_medic.dv_medic_heal = false -- dv_medic_heal to false (all below CD)
	self.deathvox_medic.factory_weapon_id = {"wpn_deathvox_light_ar"} -- light AR (all below CD). Note uses weaponfactory.
	
--	taser - VERY HARD
--	cloaker - VERY HARD
	self.deathvox_cloaker.dodge = deep_clone(self.presets.dodge.ninja) -- dodge to ninja (all below CD)
	
--	sniper - VERY HARD
--	tank - VERY HARD
	self.deathvox_tank.damage.explosion_damage_mul = 0.7 -- set 0.7 below CD.
--	No specific unit curving for dozers, which all sync off of tank effects.
	
end -- end VERY HARD specific tweaks.

function CharacterTweakData:_set_overkill_145() -- OVERKILL specific tweaks begin.

	self:crackdown_health_setup() -- applies health scaling structure.
	self:_set_characters_weapon_preset("deathvox") -- applies weapon scaling structure.
	self:_set_specials_weapon_preset("deathvox") -- applies weapon scaling structure.
	self:_set_characters_melee_preset("2") -- applies enemy melee scaling structure.
	
	if job == "man" then -- fixes base game alert bug on Counterfeit. Must be separately invoked on each diff in current setup.
		self.fbi.calls_in = nil
		self.cop_female.calls_in = nil
		self.cop.calls_in = nil
	end	
	
	self.presets.gang_member_damage.HEALTH_INIT = 300 -- bot health values. Manually set for each diff.
	self.presets.gang_member_damage.MIN_DAMAGE_INTERVAL = 0.35
	self.presets.gang_member_damage.BLEED_OUT_HEALTH_INIT = 300
	
-- guard - OVERKILL
	self.deathvox_guard.ignore_medic_revive_animation = false --medic revive anim below CD
	self.deathvox_guard.suppression = deep_clone(self.presets.suppression.easy) -- easy suppression below CD
	self.deathvox_guard.move_speed = deep_clone(self.presets.move_speed.normal) -- normal movespeed below CD
	self.deathvox_guard.ecm_vulnerability = 1 -- ecm vuln below CD
	self.deathvox_guard.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}	
	self.deathvox_guard.dodge = deep_clone(self.presets.dodge.poor) -- poor dodge below CD

--	lightar - OVERKILL
	self.deathvox_lightar.ignore_medic_revive_animation = false -- medic revive anim (below CD)
	self.deathvox_lightar.suppression = deep_clone(self.presets.suppression.hard_def) -- suppression to hard_def (N thru OVK)
	self.deathvox_lightar.surrender = deep_clone(self.presets.surrender.normal)  --	surrender to normal (all below CD)
	self.deathvox_lightar.dodge = deep_clone(self.presets.dodge.athletic) --	dodge to athletic (all below CD)
	
--	lightshot - OVERKILL
	self.deathvox_lightshot.ignore_medic_revive_animation = false -- medic revive anim (below CD)
	self.deathvox_lightshot.suppression = deep_clone(self.presets.suppression.hard_def) -- suppression to hard_def (N thru OVK)
	self.deathvox_lightshot.surrender = deep_clone(self.presets.surrender.normal)  -- surrender to normal (all below CD)
	self.deathvox_lightshot.dodge = deep_clone(self.presets.dodge.athletic) -- dodge to athletic (all below CD)
	
--	heavyar - OVERKILL
	self.deathvox_heavyar.ignore_medic_revive_animation = false -- medic revive animation false (all below MH)
--	NOTE consider curving hurt severities on lower diffs.
	self.deathvox_heavyar.surrender = deep_clone(self.presets.surrender.hard)  -- surrender to normal (on N/H, hard on VH-DW)
	self.deathvox_heavyar.dodge = deep_clone(self.presets.dodge.heavy) -- dodge to heavy (all below CD)
	self.deathvox_heavyar.damage.explosion_damage_mul = 0.8 -- damage.explosion_damage_mul to 1 on N, H, (0.8 on VH, OVK)
	
--	heavyshot - OVERKILL
	self.deathvox_heavyshot.ignore_medic_revive_animation = false -- medic revive animation false (all below MH)
--	NOTE consider curving hurt severities on lower diffs.
	self.deathvox_heavyshot.surrender = deep_clone(self.presets.surrender.hard)  -- surrender to normal (on N/H, hard on VH-DW)
	self.deathvox_heavyshot.dodge = deep_clone(self.presets.dodge.heavy) -- dodge to heavy (all below CD)
	self.deathvox_heavyshot.damage.explosion_damage_mul = 0.8 -- damage.explosion_damage_mul to 1 on N, H, (0.8 on VH, OVK)
	
--	shield - OVERKILL
--	medic - OVERKILL
	self.deathvox_medic.ignore_medic_revive_animation = false -- medic revive anim (all below CD)
	self.deathvox_medic.dodge = deep_clone(self.presets.dodge.athletic) -- dodge to athletic (all below CD)
	self.deathvox_medic.dv_medic_heal = false -- dv_medic_heal to false (all below CD)
	self.deathvox_medic.factory_weapon_id = {"wpn_deathvox_light_ar"} -- light AR (all below CD). Note uses weaponfactory.
	
--	taser - OVERKILL
--	cloaker - OVERKILL
	self.deathvox_cloaker.dodge = deep_clone(self.presets.dodge.ninja) -- dodge to ninja (all below CD)
	
--	sniper - OVERKILL
--	tank - OVERKILL
	self.deathvox_tank.damage.explosion_damage_mul = 0.7 -- set 0.7 below CD.
--	No specific unit curving for dozers, which all sync off of tank effects.
	
end -- end OVERKILL specific tweaks.

function CharacterTweakData:_set_easy_wish() -- MAYHEM specific tweaks begin.

	self:crackdown_health_setup() -- applies health scaling structure.
	self:_set_characters_weapon_preset("deathvox") -- applies weapon scaling structure.
	self:_set_specials_weapon_preset("deathvox") -- applies weapon scaling structure.
	self:_set_characters_melee_preset("2") -- applies enemy melee scaling structure.
	
	if job == "man" then -- fixes base game alert bug on Counterfeit. Must be separately invoked on each diff in current setup.
		self.fbi.calls_in = nil
		self.cop_female.calls_in = nil
		self.cop.calls_in = nil
	end	
	
	self.presets.gang_member_damage.HEALTH_INIT = 400 -- bot health values. Manually set for each diff.
	self.presets.gang_member_damage.MIN_DAMAGE_INTERVAL = 0.35
	self.presets.gang_member_damage.BLEED_OUT_HEALTH_INIT = 400
--guard - MAYHEM
	self.deathvox_guard.ignore_medic_revive_animation = false --medic revive anim below CD
	self.deathvox_guard.suppression = deep_clone(self.presets.suppression.easy) -- easy suppression below CD
	self.deathvox_guard.move_speed = deep_clone(self.presets.move_speed.normal) -- normal movespeed below CD
	self.deathvox_guard.ecm_vulnerability = 1 -- ecm vuln below CD
	self.deathvox_guard.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}	
	self.deathvox_guard.dodge = deep_clone(self.presets.dodge.poor) -- poor dodge below CD

--	lightar - MAYHEM
	self.deathvox_lightar.ignore_medic_revive_animation = false -- medic revive anim (below CD)
	self.deathvox_lightar.surrender = deep_clone(self.presets.surrender.normal)  --	surrender to normal (all below CD)
	self.deathvox_lightar.dodge = deep_clone(self.presets.dodge.athletic) --	dodge to athletic (all below CD)
	
--	lightshot - MAYHEM
	self.deathvox_lightshot.ignore_medic_revive_animation = false -- medic revive anim (below CD)
	self.deathvox_lightshot.surrender = deep_clone(self.presets.surrender.normal)  -- surrender to normal (all below CD)
	self.deathvox_lightshot.dodge = deep_clone(self.presets.dodge.athletic) -- dodge to athletic (all below CD)
	
--	heavyar - MAYHEM
--	NOTE consider curving hurt severities on lower diffs.
	self.deathvox_heavyar.surrender = deep_clone(self.presets.surrender.hard)  -- surrender to normal (on N/H, hard on VH-DW)
	self.deathvox_heavyar.dodge = deep_clone(self.presets.dodge.heavy) -- dodge to heavy (all below CD)
	
--	heavyshot - MAYHEM
--	NOTE consider curving hurt severities on lower diffs.
	self.deathvox_heavyshot.surrender = deep_clone(self.presets.surrender.hard)  -- surrender to normal (on N/H, hard on VH-DW)
	self.deathvox_heavyshot.dodge = deep_clone(self.presets.dodge.heavy) -- dodge to heavy (all below CD)
	
--	shield - MAYHEM
--	medic - MAYHEM
	self.deathvox_medic.ignore_medic_revive_animation = false -- medic revive anim (all below CD)
	self.deathvox_medic.dodge = deep_clone(self.presets.dodge.athletic) -- dodge to athletic (all below CD)
	self.deathvox_medic.dv_medic_heal = false -- dv_medic_heal to false (all below CD)
	self.deathvox_medic.factory_weapon_id = {"wpn_deathvox_light_ar"} -- light AR (all below CD). Note uses weaponfactory.
	
--	taser - MAYHEM
--	cloaker - MAYHEM
	self.deathvox_cloaker.dodge = deep_clone(self.presets.dodge.ninja) -- dodge to ninja (all below CD)
	
--	sniper - MAYHEM
--	tank - MAYHEM
	self.deathvox_tank.damage.explosion_damage_mul = 0.7 -- set 0.7 below CD.
--	No specific unit curving for dozers, which all sync off of tank effects.	

end -- end MAYHEM specific tweaks.

function CharacterTweakData:_set_overkill_290() -- DEATH WISH specific tweaks begin.

	self:crackdown_health_setup() -- applies health scaling structure.
	self:_set_characters_weapon_preset("deathvox") -- applies weapon scaling structure.
	self:_set_specials_weapon_preset("deathvox") -- applies weapon scaling structure.
	self:_set_characters_melee_preset("2") -- applies enemy melee scaling structure.

	if job == "man" then -- fixes base game alert bug on Counterfeit. Must be separately invoked on each diff in current setup.
		self.fbi.calls_in = nil
		self.cop_female.calls_in = nil
		self.cop.calls_in = nil
	end	
	
	self.presets.gang_member_damage.HEALTH_INIT = 400 -- bot health values. Manually set for each diff.
	self.presets.gang_member_damage.MIN_DAMAGE_INTERVAL = 0.35
	self.presets.gang_member_damage.BLEED_OUT_HEALTH_INIT = 400
	
--guard - DEATH WISH
	self.deathvox_guard.ignore_medic_revive_animation = false --medic revive anim below CD
	self.deathvox_guard.suppression = deep_clone(self.presets.suppression.easy) -- easy suppression below CD
	self.deathvox_guard.move_speed = deep_clone(self.presets.move_speed.normal) -- normal movespeed below CD
	self.deathvox_guard.ecm_vulnerability = 1 -- ecm vuln below CD
	self.deathvox_guard.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}	
	self.deathvox_guard.dodge = deep_clone(self.presets.dodge.poor) -- poor dodge below CD

--	lightar - DEATH WISH
	self.deathvox_lightar.ignore_medic_revive_animation = false -- medic revive anim (below CD)
	self.deathvox_lightar.surrender = deep_clone(self.presets.surrender.normal)  --	surrender to normal (all below CD)
	self.deathvox_lightar.dodge = deep_clone(self.presets.dodge.athletic) --	dodge to athletic (all below CD)
	
--	lightshot - DEATH WISH
	self.deathvox_lightshot.ignore_medic_revive_animation = false -- medic revive anim (below CD)
	self.deathvox_lightshot.surrender = deep_clone(self.presets.surrender.normal)  -- surrender to normal (all below CD)
	self.deathvox_lightshot.dodge = deep_clone(self.presets.dodge.athletic) -- dodge to athletic (all below CD)

--	heavyar - DEATH WISH
--	NOTE consider curving hurt severities on lower diffs.
	self.deathvox_heavyar.surrender = deep_clone(self.presets.surrender.hard)  -- surrender to normal (on N/H, hard on VH-DW)
	self.deathvox_heavyar.dodge = deep_clone(self.presets.dodge.heavy) -- dodge to heavy (all below CD)	

--	heavyshot - DEATH WISH
--	NOTE consider curving hurt severities on lower diffs.
	self.deathvox_heavyshot.surrender = deep_clone(self.presets.surrender.hard)  -- surrender to normal (on N/H, hard on VH-DW)
	self.deathvox_heavyshot.dodge = deep_clone(self.presets.dodge.heavy) -- dodge to heavy (all below CD)
	
--	shield - DEATH WISH
--	medic - DEATH WISH
	self.deathvox_medic.ignore_medic_revive_animation = false -- medic revive anim (all below CD)
	self.deathvox_medic.dodge = deep_clone(self.presets.dodge.athletic) -- dodge to athletic (all below CD)
	self.deathvox_medic.dv_medic_heal = false -- dv_medic_heal to false (all below CD)
	self.deathvox_medic.factory_weapon_id = {"wpn_deathvox_light_ar"} -- light AR (all below CD). Note uses weaponfactory.
	
--	taser - DEATH WISH
--	cloaker - DEATH WISH
	self.deathvox_cloaker.dodge = deep_clone(self.presets.dodge.ninja) -- dodge to ninja (all below CD)
	
--	sniper - DEATH WISH
--	tank - DEATH WISH
	self.deathvox_tank.damage.explosion_damage_mul = 0.7 -- set 0.7 below CD.
--	No specific unit curving for dozers, which all sync off of tank effects.	

end -- end DEATH WISH specific tweaks.

function CharacterTweakData:_set_sm_wish() -- CRACKDOWN specific tweaks begin.

	self:crackdown_health_setup() -- applies health scaling structure.
	self:_set_characters_weapon_preset("deathvox") -- applies weapon scaling structure.
	self:_set_specials_weapon_preset("deathvox") -- applies weapon scaling structure.
	self:_set_characters_melee_preset("2") -- applies enemy melee scaling structure.
	
	if job == "man" then -- fixes base game alert bug on Counterfeit. Must be separately invoked on each diff in current setup.
		self.fbi.calls_in = nil
		self.cop_female.calls_in = nil
		self.cop.calls_in = nil
	end	
	
	self.presets.gang_member_damage.HEALTH_INIT = 500 -- bot health values. Manually set for each diff.
	self.presets.gang_member_damage.MIN_DAMAGE_INTERVAL = 0.35
	self.presets.gang_member_damage.BLEED_OUT_HEALTH_INIT = 500
	
-- NOTE material below this point iamgoofball legacy code. Identify purposes, clean, annotate as able.
	

	self:_multiply_weapon_delay(self.presets.weapon.normal, 0)
	self:_multiply_weapon_delay(self.presets.weapon.good, 0)
	self:_multiply_weapon_delay(self.presets.weapon.expert, 0)
	self:_multiply_weapon_delay(self.presets.weapon.sniper, 0)
	self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0)
	
	self.security = deep_clone(self.deathvox_guard) --  Requires further testing. May be fix for heist-specific crash tied to initial custom unit spawn.
	self.gensec = deep_clone(self.deathvox_guard)
	
	self.deathvox_sniper_assault.weapon = deep_clone(self.presets.weapon.deathvox_sniper)

	self.sniper = deep_clone(self.deathvox_sniper)
	self.sniper.weapon = deep_clone(self.presets.weapon.deathvox_sniper)
	
--	if job == "kosugi" or job == "dark" then -- believed to be outdated unit role change for murky stealth guards. testing removal.
--		self.city_swat.no_arrest = true
--	else
--		self.city_swat.no_arrest = false
--	end
	
	self:_multiply_all_speeds(1, 1)
--	self.old_hoxton_mission.HEALTH_INIT = 525 -- testing removal of oldhox HP set code.
	self.spa_vip.HEALTH_INIT = 525
	self.flashbang_multiplier = 2
	self.concussion_multiplier = 2
	
-- Begin goofball legacy health changes.
	
	self.cop.HEALTH_INIT = 15 -- note need to see if can be removed.

	self.cop_female.HEALTH_INIT = 15 -- note need to see if can be removed.
	self.fbi.HEALTH_INIT = 48 -- note need to see if can be removed.
	
	self.chavez_boss.HEALTH_INIT = 900 -- ask testers if these are in use
	self.bolivian_indoors.HEALTH_INIT = 1000 
	self.bolivian_indoors.no_arrest = true
	self.bolivian.HEALTH_INIT = 1000
	self.gangster.HEALTH_INIT = 1000
	self.biker.HEALTH_INIT = 1000
	self.biker_escape.HEALTH_INIT = 1000
	
	self.phalanx_vip = deep_clone(self.phalanx_minion) -- killable winters to prevent soft-lock
	self.phalanx_vip.HEALTH_INIT = 300 -- currently unused captain code. Not touching until captain implemented.
	self.phalanx_vip.DAMAGE_CLAMP_BULLET = 100
	self.phalanx_vip.DAMAGE_CLAMP_EXPLOSION = self.phalanx_vip.DAMAGE_CLAMP_BULLET
	self.phalanx_vip.can_be_tased = false
	self.phalanx_vip.immune_to_knock_down = true
	self.phalanx_vip.immune_to_concussion = true
	self.phalanx_vip.ends_assault_on_death = true
	
end  -- end CRACKDOWN specific tweaks.

function CharacterTweakData:_multiply_all_hp(hp_mul, hs_mul)
	self:crackdown_health_setup()
	self.sniper = deep_clone(self.deathvox_sniper)
	self.sniper.weapon = deep_clone(self.presets.weapon.deathvox_sniper)
end

function CharacterTweakData:_multiply_all_speeds(walk_mul, run_mul)
	local all_units = {
		"security",
		"gensec",
		"cop",
		"cop_scared",
		"cop_female",
		"fbi",
		"medic",
		"swat",
		"heavy_swat",
		"heavy_swat_sniper",
		"fbi_swat",
		"fbi_heavy_swat",
		"city_swat",
		"sniper",
		"gangster",
		"mobster",
		"mobster_boss",
		"biker_boss",
		"hector_boss",
		"chavez_boss",
		"hector_boss_no_armor",
		"tank",
		"tank_mini",
		"tank_medic",
		"tank_hw",
		"spooc",
		"phalanx_vip",
		"phalanx_minion",
		"shield",
		"biker",
		"taser",
		"deathvox_guard",
		"deathvox_heavyar",
		"deathvox_heavyshot",
		"deathvox_lightar",
		"deathvox_lightshot",
		"deathvox_medic",
		"deathvox_shield",
		"deathvox_taser",
		"deathvox_cloaker",
		"deathvox_sniper_assault",
		"deathvox_greendozer",
		"deathvox_blackdozer",
		"deathvox_lmgdozer",
		"deathvox_medicdozer",
		"deathvox_grenadier"
	}
	table.insert(all_units, "bolivian")
	table.insert(all_units, "bolivian_indoors")
	table.insert(all_units, "drug_lord_boss")
	table.insert(all_units, "drug_lord_boss_stealth")
	for _, name in ipairs(all_units) do
		local speed_table = self[name].SPEED_WALK
		speed_table.hos = speed_table.hos * walk_mul
		speed_table.cbt = speed_table.cbt * walk_mul
	end
	self.security.SPEED_RUN = self.security.SPEED_RUN * run_mul
	self.gensec.SPEED_RUN = self.security.SPEED_RUN * run_mul
	self.cop.SPEED_RUN = self.cop.SPEED_RUN * run_mul
	self.cop_scared.SPEED_RUN = self.cop_scared.SPEED_RUN * run_mul
	self.cop_female.SPEED_RUN = self.cop_female.SPEED_RUN * run_mul
	self.fbi.SPEED_RUN = self.fbi.SPEED_RUN * run_mul
	self.medic.SPEED_RUN = self.medic.SPEED_RUN * run_mul
	self.bolivian.SPEED_RUN = self.bolivian.SPEED_RUN * run_mul
	self.bolivian_indoors.SPEED_RUN = self.bolivian_indoors.SPEED_RUN * run_mul
	self.drug_lord_boss.SPEED_RUN = self.drug_lord_boss.SPEED_RUN * run_mul
	self.drug_lord_boss_stealth.SPEED_RUN = self.drug_lord_boss_stealth.SPEED_RUN * run_mul
	self.swat.SPEED_RUN = self.swat.SPEED_RUN * run_mul
	self.heavy_swat.SPEED_RUN = self.heavy_swat.SPEED_RUN * run_mul
	self.heavy_swat_sniper.SPEED_RUN = self.heavy_swat_sniper.SPEED_RUN * run_mul
	self.fbi_swat.SPEED_RUN = self.fbi_swat.SPEED_RUN * run_mul
	self.fbi_heavy_swat.SPEED_RUN = self.fbi_heavy_swat.SPEED_RUN * run_mul
	self.city_swat.SPEED_RUN = self.city_swat.SPEED_RUN * run_mul
	self.sniper.SPEED_RUN = self.sniper.SPEED_RUN * run_mul
	self.gangster.SPEED_RUN = self.gangster.SPEED_RUN * run_mul
	self.mobster.SPEED_RUN = self.gangster.SPEED_RUN * run_mul
	self.mobster_boss.SPEED_RUN = self.mobster_boss.SPEED_RUN * run_mul
	self.chavez_boss.SPEED_RUN = self.chavez_boss.SPEED_RUN * run_mul
	self.biker_boss.SPEED_RUN = self.biker_boss.SPEED_RUN * run_mul
	self.hector_boss.SPEED_RUN = self.hector_boss.SPEED_RUN * run_mul
	self.hector_boss_no_armor.SPEED_RUN = self.hector_boss_no_armor.SPEED_RUN * run_mul
	self.tank.SPEED_RUN = self.tank.SPEED_RUN * run_mul
	self.tank_mini.SPEED_RUN = self.tank_mini.SPEED_RUN * run_mul
	self.tank_medic.SPEED_RUN = self.tank_medic.SPEED_RUN * run_mul
	self.tank_hw.SPEED_RUN = self.tank_hw.SPEED_RUN * run_mul
	self.spooc.SPEED_RUN = self.spooc.SPEED_RUN * run_mul
	self.phalanx_vip.SPEED_RUN = self.phalanx_vip.SPEED_RUN * run_mul
	self.phalanx_minion.SPEED_RUN = self.phalanx_minion.SPEED_RUN * run_mul
	self.shield.SPEED_RUN = self.shield.SPEED_RUN * run_mul
	self.biker.SPEED_RUN = self.biker.SPEED_RUN * run_mul
	self.taser.SPEED_RUN = self.taser.SPEED_RUN * run_mul
	self.biker_escape.SPEED_RUN = self.biker_escape.SPEED_RUN * run_mul
	self.deathvox_guard.SPEED_RUN = self.deathvox_guard.SPEED_RUN * run_mul
	self.deathvox_grenadier.SPEED_RUN = self.deathvox_grenadier.SPEED_RUN * run_mul
	self.deathvox_heavyar.SPEED_RUN = self.deathvox_heavyar.SPEED_RUN * run_mul
	self.deathvox_heavyshot.SPEED_RUN = self.deathvox_heavyshot.SPEED_RUN * run_mul
	self.deathvox_lightar.SPEED_RUN = self.deathvox_lightar.SPEED_RUN * run_mul
	self.deathvox_lightshot.SPEED_RUN = self.deathvox_lightshot.SPEED_RUN * run_mul
	self.deathvox_shield.SPEED_RUN = self.deathvox_shield.SPEED_RUN * run_mul
	self.deathvox_medic.SPEED_RUN = self.deathvox_medic.SPEED_RUN * run_mul
	
	self.deathvox_taser.SPEED_RUN = self.deathvox_taser.SPEED_RUN * run_mul
	self.deathvox_cloaker.SPEED_RUN = self.deathvox_cloaker.SPEED_RUN * run_mul
	self.deathvox_sniper_assault.SPEED_RUN = self.deathvox_sniper_assault.SPEED_RUN * run_mul
	self.deathvox_greendozer.SPEED_RUN = self.deathvox_greendozer.SPEED_RUN * run_mul
	self.deathvox_blackdozer.SPEED_RUN = self.deathvox_blackdozer.SPEED_RUN * run_mul
	self.deathvox_lmgdozer.SPEED_RUN = self.deathvox_lmgdozer.SPEED_RUN * run_mul
	self.deathvox_medicdozer.SPEED_RUN = self.deathvox_medicdozer.SPEED_RUN * run_mul
end

function CharacterTweakData:_set_characters_weapon_preset(preset)
	local all_units = {
		"security",
		"cop",
		"cop_scared",
		"cop_female",
		"gensec",
		"fbi",
		"swat",
		"gangster",
		"hector_boss_no_armor",
		"bolivian",
		"bolivian_indoors",
		"drug_lord_boss_stealth",
		"biker",
		"mobster",
		"deathvox_guard",
		"deathvox_heavyar",
		"deathvox_heavyshot",
		"deathvox_lightar",
		"deathvox_lightshot",
		"deathvox_medic",
		"deathvox_shield",
		"deathvox_taser",
		"deathvox_cloaker",
		"deathvox_sniper_assault",
		"deathvox_greendozer",
		"deathvox_blackdozer",
		"deathvox_lmgdozer",
		"deathvox_medicdozer",
		"deathvox_grenadier"
	}
	for _, name in ipairs(all_units) do
		
		self[name].weapon = self.presets.weapon[preset]
	end
end

function CharacterTweakData:_set_characters_dodge_preset(preset)
	local all_units = {
		"gensec",
		"fbi",
		"medic",
		"taser",
		"hector_boss_no_armor",
		"bolivian_indoors",
		"drug_lord_boss_stealth",
		"swat",
		"deathvox_heavyar",
		"deathvox_heavyshot",
		"deathvox_lightar",
		"deathvox_lightshot",
		"deathvox_medic",
		"deathvox_taser",
		"deathvox_cloaker",
		"deathvox_sniper_assault",
		"deathvox_guard",
		"deathvox_grenadier"
	}
	for _, name in ipairs(all_units) do
		self[name].dodge = self.presets.dodge[preset]
	end
end

function CharacterTweakData:_set_characters_melee_preset(preset)
	local all_units = {
		"security",
		"cop",
		"cop_scared",
		"cop_female",
		"gensec",
		"fbi",
		"swat",
		"gangster",
		"hector_boss_no_armor",
		"bolivian",
		"bolivian_indoors",
		"drug_lord_boss_stealth",
		"biker",
		"mobster",
		"deathvox_guard",
		"deathvox_heavyar",
		"deathvox_heavyshot",
		"deathvox_lightar",
		"deathvox_lightshot"
	}
	for _, name in ipairs(all_units) do
		self[name].melee_weapon_dmg_multiplier = preset
	end
end

function CharacterTweakData:_set_specials_weapon_preset(preset)
	local all_units = {
		"taser",
		"medic",
		"spooc",
		"shield",
		"tank",
		"tank_mini",
		"tank_medic",
		"tank_hw",
		"mobster_boss",
		"biker_boss",
		"chavez_boss",
		"hector_boss",
		"drug_lord_boss",
		"phalanx_minion",
		"phalanx_vip",
		"deathvox_medic",
		"deathvox_shield",
		"deathvox_taser",
		"deathvox_cloaker",
		"deathvox_sniper_assault",
		"deathvox_greendozer",
		"deathvox_blackdozer",
		"deathvox_lmgdozer",
		"deathvox_medicdozer",
		"deathvox_grenadier"
	}
	for _, name in ipairs(all_units) do
		self[name].weapon = deep_clone(self.presets.weapon[preset])
	end
end

function CharacterTweakData:_set_specials_melee_preset(preset)
	local all_units = {
		"taser",
		"medic",
		"spooc",
		"shield",
		"tank",
		"tank_mini",
		"tank_medic",
		"sniper",
		"tank_hw",
		"mobster_boss",
		"biker_boss",
		"chavez_boss",
		"hector_boss",
		"drug_lord_boss",
		"phalanx_minion",
		"phalanx_vip",
		"deathvox_medic",
		"deathvox_shield",
		"deathvox_taser",
		"deathvox_cloaker",
		"deathvox_sniper_assault",
		"deathvox_greendozer",
		"deathvox_blackdozer",
		"deathvox_lmgdozer",
		"deathvox_medicdozer",
		"deathvox_grenadier"
	}
	for _, name in ipairs(all_units) do
		self[name].melee_weapon_dmg_multiplier = preset
	end
end

function CharacterTweakData:_init_region_cop()
	self._default_chatter = "dispatch_generic_message"
	self._unit_prefixes = {
		cop = "l",
		swat = "l",
		heavy_swat = "l",
		taser = "tsr",
		cloaker = "clk",
		bulldozer = "bdz",
		medic = "mdc"
	}
end

function CharacterTweakData:_init_region_fbi()
	self._default_chatter = "dispatch_generic_message"
	self._unit_prefixes = {
		cop = "l",
		swat = "l",
		heavy_swat = "l",
		taser = "tsr",
		cloaker = "clk",
		bulldozer = "bdz",
		medic = "mdc"
	}
end

function CharacterTweakData:_init_region_gensec()
	self._default_chatter = "dispatch_generic_message"
	self._unit_prefixes = {
		cop = "l",
		swat = "l",
		heavy_swat = "l",
		taser = "tsr",
		cloaker = "clk",
		bulldozer = "bdz",
		medic = "mdc"
	}
end

function CharacterTweakData:_init_region_zeal()
	self._default_chatter = "dispatch_generic_message"
	self._unit_prefixes = {
		cop = "l",
		swat = "l",
		heavy_swat = "l",
		taser = "tsr",
		cloaker = "clk",
		bulldozer = "bdz",
		medic = "mdc"
	}
end

function CharacterTweakData:_init_region_classic()
	self._default_chatter = "dispatch_generic_message"
	self._unit_prefixes = {
		cop = "l",
		swat = "l",
		heavy_swat = "l",
		taser = "tsr",
		cloaker = "clk",
		bulldozer = "bdz",
		medic = "mdc"
	}
end


function CharacterTweakData:character_map()
	local char_map = origin_charmap(self)
	char_map.gageammo = {
		path = "units/pd2_mod_gageammo/characters/",
		list = {
			"ene_deathvox_guard",
			"ene_deathvox_heavyar",
			"ene_deathvox_lightar",
			"ene_deathvox_medic",
			"ene_deathvox_shield",
			"ene_deathvox_lightshot",
			"ene_deathvox_heavyshot",
			"ene_deathvox_taser",
			"ene_deathvox_cloaker",
			"ene_deathvox_sniper_assault",
			"ene_deathvox_greendozer",
			"ene_deathvox_blackdozer",
			"ene_deathvox_lmgdozer",
			"ene_deathvox_medicdozer",
			"ene_deathvox_grenadier",
			"ene_deathvox_gman",
			"ene_deathvox_gman_noflashlight",
			"ene_deathvox_guarddozer",
			"ene_deathvox_gensec_taser",
			"ene_deathvox_gensec_swatshot",
			"ene_deathvox_gensec_swat",
			"ene_deathvox_gensec_shield",
			"ene_deathvox_gensec_medic",
			"ene_deathvox_gensec_lmgdozer",
			"ene_deathvox_gensec_heavyswatshot",
			"ene_deathvox_gensec_heavyswat",
			"ene_deathvox_gensec_cloaker",
			"ene_deathvox_fbi_veteran",
			"ene_deathvox_fbi_taser",
			"ene_deathvox_fbi_swatshot",
			"ene_deathvox_fbi_swat",
			"ene_deathvox_fbi_shield",
			"ene_deathvox_fbi_rookie",
			"ene_deathvox_fbi_medic",
			"ene_deathvox_fbi_hrt",
			"ene_deathvox_fbi_heavyswatshot",
			"ene_deathvox_fbi_heavyswat",
			"ene_deathvox_fbi_greendozer",
			"ene_deathvox_fbi_cloaker",
			"ene_deathvox_fbi_blackdozer",
			"ene_deathvox_cop_taser",
			"ene_deathvox_cop_swatshot",
			"ene_deathvox_cop_swat",
			"ene_deathvox_cop_smg",
			"ene_deathvox_cop_shotgun",
			"ene_deathvox_cop_shield",
			"ene_deathvox_cop_revolver",
			"ene_deathvox_cop_pistol",
			"ene_deathvox_cop_medic",
			"ene_deathvox_cop_heavyswatshot",
			"ene_deathvox_cop_heavyswat",
			"ene_deathvox_classic_blackdozer",
			"ene_deathvox_classic_cloaker",
			"ene_deathvox_classic_cop_pistol",
			"ene_deathvox_classic_cop_revolver",
			"ene_deathvox_classic_cop_shotgun",
			"ene_deathvox_classic_cop_smg",
			"ene_deathvox_classic_greendozer",
			"ene_deathvox_classic_heavyswat",
			"ene_deathvox_classic_heavyswatshot",
			"ene_deathvox_classic_hrt",
			"ene_deathvox_classic_lmgdozer",
			"ene_deathvox_classic_medic",
			"ene_deathvox_classic_shield",
			"ene_deathvox_classic_swat",
			"ene_deathvox_classic_swatshot",
			"ene_deathvox_classic_taser",
			"ene_deathvox_classic_veteran"
		}
	}
	return char_map
end
