local origin_init = CharacterTweakData.init
local origin_presets = CharacterTweakData._presets

function CharacterTweakData:init(tweak_data)
	local presets = self:_presets(tweak_data)
	origin_init(self, tweak_data)
	self:_init_deathvox(presets)
end

function CharacterTweakData:_presets(tweak_data)
	local presets = origin_presets(self, tweak_data)
	presets.base.use_pdth_shit = false
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
	presets.dodge.deathvoxninja = {
		speed = 1.7,
		occasions = {
			hit = {
				chance = 0.9,
				check_timeout = {0, 1},
				variations = {
					side_step = {
						chance = 3,
						shoot_chance = 1,
						shoot_accuracy = 0.7,
						timeout = {1, 2}
					},
					roll = {
						chance = 1,
						timeout = {1.2, 2}
					},
					wheel = {
						chance = 2,
						shoot_chance = 1, -- test value. May or may not operate action, crash.
						shoot_accuracy = 0.8,
						timeout = {1.2, 2}
					}
				}
			},
			preemptive = {
				chance = 0.9,
				check_timeout = {0, 1},
				variations = {
					side_step = {
						chance = 1,
						shoot_chance = 1,
						shoot_accuracy = 0.8,
						timeout = {1, 2}
					},
					roll = {
						chance = 2,
						timeout = {1.2, 2}
					},
					wheel = {
						chance = 2,
						shoot_chance = 1, -- test value. May or may not operate action, crash.
						shoot_accuracy = 0.8,
						timeout = {1.2, 2}
					}
				}
			},
			scared = {
				chance = 0.9,
				check_timeout = {0, 1},
				variations = {
					side_step = {
						chance = 1,
						shoot_chance = 0.8,
						shoot_accuracy = 0.6,
						timeout = {1, 2}
					},
					roll = {
						chance = 3,
						timeout = {1.2, 2}
					},
					wheel = {
						chance = 3,
						shoot_chance = 1, -- test value. May or may not operate action, crash.
						shoot_accuracy = 0.8,
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
	--[[presets.weapon.deathvox = {
		is_pistol = {},-- used for guards and numerous scripted enemies, as well as beat police. Assumes base damage 40.
		is_revolver = {},-- used for medics and numerous scripted enemies, as well as beat police. Assumes base damage 60.
		is_rifle = {}, -- clones heavy ar. Used enemy types unknown. assumes base damage 75.
		is_lmg = {},-- used for scripted boss enemies, lmg dozers. Assumes base damage 100.
		is_shotgun_pump = {}, -- used for green dozers. Assumes base damage 400.
		is_shotgun_mag = {}, -- used for saiga dozers. Assumes base damage 225.
		mossberg = {}, -- scripted enemy (e.g. beat cop) shotgun. clones light shotgun. Assumes base damage 75.
		is_smg = {}, -- Ased for shield, variety of enemies. Assumes base damage 45.
		mp9 = {}, -- Clones smg. Used primarily by security, FBI HRT.
		rifle = {}, -- clones light ar. Used enemy types unknown. Assumes base damage 60.
		mac11 = {}, -- Clones smg. Used primarily by criminal enemies. Assumes base damage 45.
		akimbo_pistol = {}, -- used by boss enemy on Panic Room. Clones pistol.
		mini = {}, -- unused aside from Spring, crime spree enemy. Will revise in future build for possible scripted use.
		flamethrower = {}, -- Used for Summers.
		is_light_rifle = {}, -- Used for light AR SWAT, Tasers, Grenadiers. Assumes base damage 60.
		is_heavy_rifle = {}, -- Used for heavy AR. Assumes base damage 75.
		is_light_shotgun = {}, -- Used for light shotgun SWAT. Assumes base damage 75.
		is_heavy_shotgun = {}, -- Used for heavy shotgun SWAT. Assumes base damage 100.
		is_tank_smg = {}, -- used for medic dozer. Clones smg. Assumes base damage 45.
		is_bullpup = {}, -- clones light rifle. Assumes base damage 60.
		is_sniper = {}, -- initializing sniper. Assumes base damage 240.
		is_assault_sniper = {} -- initializing assault sniper preset. Assumes base damage 240.
	}]]--
	presets.weapon.deathvox = deep_clone(presets.weapon.deathwish)
	--note to self- clean up is_revolver and make consistent.
	presets.weapon.deathvox.is_revolver = { -- used by medics.
		aim_delay = { -- mark 3 values complete.
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
	presets.weapon.deathvox.is_pistol = { -- mark 3 values complete. Currently valid for guards, beat police, low level enemies. basis: presets.weapon.deathwish.is_pistol.
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
	presets.weapon.deathvox.is_shotgun_pump = { -- mark 4 values complete. Assumes base damage 400. basis is presets.weapon.deathwish.is_shotgun_pump. Extremely dangerous close range, much less so further out.
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
				dmg_mul = .350,
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
	presets.weapon.deathvox.is_shotgun_mag = { -- mark 3 values complete. assumes base damage 225. Basis is presets.weapon.deathwish.is_shotgun_pump. Much more even arc distribution-focus/shotcount becomes crucial.
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
					1,
					1.1
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
				acc = { -- reduced lower end, vanilla .7.
					0.5,
					0.95
				},
				recoil = {
					1,
					1.25
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
				acc = { -- reduced lower end, vanilla .5.
					0.4,
					0.85
				},
				recoil = {
					1,
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
				dmg_mul = .7,
				r = 2000,
				acc = { -- reduced lower end, vanilla .35.
					0.35,
					0.65
				},
				recoil = {
					1.25,
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

	presets.weapon.deathvox.is_light_rifle = { -- mark 3 values complete. basis is presets.weapon.deathwish.is_rifle. General goal- more shots, less damage, reduced range.
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
				dmg_mul = 0.8, --falloff after 5 meters, no flat damage.
				r = 1000,
				acc = {
					0.7,
					0.9
				},
				recoil = { --reduced to increase attack rate at lower range. Vanilla values .35-.55. No changes to later ranges.
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
				dmg_mul = 0.85,
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
				dmg_mul = 0.7,
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
				dmg_mul = 0.6,
				r = 6000, -- uses longer range, per vanilla, to maintain long falloff tail.
				acc = {
					0.45, -- increased tail accuracy. Vanilla values .25-.7.
					0.7
				},
				recoil = {
					1.5, -- increased tail recoil to reduce attack rate. Vanilla values 1-2.
					2
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
		range = { -- validated, unchanged. I believe same for all shotgun enemy types in vanilla.
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
				dmg_mul = 1,
				r = 500,
				acc = {
					0.7,
					0.95
				},
				recoil = { -- slight recoil reduction. Vanilla stats 1-1.25.
					1,
					1.2
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
				dmg_mul = 1, -- less falloff at close range versus vanilla.
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
				acc = { -- slight max accuracy increase, vanilla stats .45-.7.
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
	presets.weapon.deathvox.mini = { -- unused and unchanged as of mark 3 revisions.
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
	presets.weapon.deathvox.is_lmg = { --mark 3 values complete. Basis is presets.weapon.deathwish.is_lmg. Assumes 100 base damage. Used for LMG Dozers, certain scripted enemies. using a balance between expert and DW values here.
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
		autofire_rounds = {
			25,
			50
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
		range = { --validated, unchanged. Will need to see values used by crimespree zeal heavy snipers for assault snipers.
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
	presets.weapon.deathvox.is_tank_smg = deep_clone(presets.weapon.deathvox.is_smg) --Used for medidozer. May separate.
	presets.weapon.deathvox.is_cloaker_smg = deep_clone(presets.weapon.deathvox.is_smg) -- clone similar to other vars.
	presets.weapon.deathvox.is_dozer_saiga = deep_clone(presets.weapon.deathvox.is_shotgun_mag)
	presets.weapon.deathvox.is_dozer_pump = deep_clone(presets.weapon.deathvox.is_shotgun_pump)
	presets.weapon.deathvox.is_dozer_lmg = deep_clone(presets.weapon.deathvox.is_lmg)
	presets.weapon.deathvox.is_bullpup = deep_clone(presets.weapon.deathvox.is_light_rifle) -- moving this clone down from inappropriate position above.
	presets.weapon.deathvox.mac11 = deep_clone(presets.weapon.deathvox.is_smg) -- revises erroneous clone of pistol from previous setup.
	presets.weapon.deathvox.mp9 = deep_clone(presets.weapon.deathvox.is_smg) -- revises erroneous clone of pistol from previous setup.
	presets.weapon.deathvox.rifle = deep_clone(presets.weapon.deathvox.is_light_rifle)
	presets.weapon.deathvox.is_sniper = deep_clone(presets.weapon.deathvox.is_light_rifle)
	presets.weapon.deathvox.is_rifle = deep_clone(presets.weapon.deathvox.is_light_rifle)
	presets.weapon.deathvox.akimbo_pistol = deep_clone(presets.weapon.deathvox.is_pistol) -- Will revise for test version of Chavez boss at future date.
	presets.weapon.deathvox.mossberg = deep_clone(presets.weapon.deathvox.is_light_shotgun)
	return presets
end
	
function CharacterTweakData:_init_deathvox(presets)
	self.deathvox_guard = deep_clone(self.security)
	self.deathvox_guard.detection = presets.detection.guard -- normal, guard, sniper, gang_member, civilian, blind
	self.deathvox_guard.suppression = nil -- presets.suppression.no_supress
	self.deathvox_guard.surrender = presets.surrender.easy
	self.deathvox_guard.move_speed = presets.move_speed.very_fast -- tentative.
	self.deathvox_guard.ecm_vulnerability = 0 -- DV guards ignore feedback. Removing safety net in stealth.
	
	self.deathvox_guard.dodge = presets.dodge.deathvox_guard
	self.deathvox_guard.deathguard = true -- unlikely to be relevant usually, but adds slight safety window during pathing step.
	self.deathvox_guard.no_arrest = true -- removing the arrest loophole.
	self.deathvox_guard.factory_weapon_id = {"wpn_deathvox_guard_pistol"}
	self.deathvox_guard.use_factory = true
	self.deathvox_guard.HEALTH_INIT = 15
	self.deathvox_guard.headshot_dmg_mul = 3
	self.deathvox_guard.weapon = deep_clone(presets.weapon.deathvox)
	self.deathvox_guard.access = "any"
	table.insert(self._enemy_list, "deathvox_guard")
	
	self.deathvox_lightar = deep_clone(self.city_swat)
	self.deathvox_lightar.detection = presets.detection.normal
	self.deathvox_lightar.suppression = presets.suppression.hard_agg -- tentative. Need to consider effect, may be too much.
	self.deathvox_lightar.surrender = presets.surrender.normal --tentative. hard for heavy, normal for light.
	self.deathvox_lightar.move_speed = presets.move_speed.very_fast
	self.deathvox_lightar.surrender_break_time = {6, 8} --should be fairly fast, used in base for fbi heavy swat.
	self.deathvox_lightar.ecm_vulnerability = 1
	self.deathvox_lightar.ecm_hurts = {
		ears = {min_duration = 6, max_duration = 8} -- base game taser value. Gen base is 8-10.
	}
	self.deathvox_lightar.dodge = presets.dodge.deathvox
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
	table.insert(self._enemy_list, "deathvox_lightar")
	
	self.deathvox_heavyar = deep_clone(self.city_swat)
	self.deathvox_heavyar.detection = presets.detection.normal
	self.deathvox_heavyar.damage.hurt_severity = presets.hurt_severities.only_fire_and_poison_hurts -- new with final 2017 pass.
	self.deathvox_heavyar.suppression = presets.suppression.hard_agg -- tentative.
	self.deathvox_heavyar.surrender = presets.surrender.hard --tentative.
	self.deathvox_heavyar.move_speed = presets.move_speed.very_fast
	self.deathvox_heavyar.surrender_break_time = {6, 8}
	self.deathvox_heavyar.ecm_vulnerability = 1
	self.deathvox_heavyar.ecm_hurts = {
		ears = {min_duration = 6, max_duration = 8}
	}
	self.deathvox_heavyar.dodge = presets.dodge.deathvox
	self.deathvox_heavyar.deathguard = true
	self.deathvox_heavyar.no_arrest = true
	self.deathvox_heavyar.steal_loot = true
	self.deathvox_heavyar.rescue_hostages = true
	self.deathvox_heavyar.weapon = deep_clone(presets.weapon.deathvox)
	self.deathvox_heavyar.factory_weapon_id = {"wpn_deathvox_heavy_ar"}
	self.deathvox_heavyar.use_factory = true
	self.deathvox_heavyar.HEALTH_INIT = 101 -- new with final 2017 pass.
	self.deathvox_heavyar.headshot_dmg_mul = 3
	self.deathvox_heavyar.damage.explosion_damage_mul = 0.9
	self.deathvox_heavyar.access = "any"
	table.insert(self._enemy_list, "deathvox_heavyar")
	
	self.deathvox_lightshot = deep_clone(self.city_swat)
	self.deathvox_lightshot.detection = presets.detection.normal
	self.deathvox_lightshot.suppression = presets.suppression.hard_agg -- tentative.
	self.deathvox_lightshot.surrender = presets.surrender.normal -- tentative.
	self.deathvox_lightshot.move_speed = presets.move_speed.very_fast
	self.deathvox_lightshot.surrender_break_time = {6, 8} 
	self.deathvox_lightshot.ecm_vulnerability = 1
	self.deathvox_lightshot.ecm_hurts = {
		ears = {min_duration = 6, max_duration = 8}
	}
	self.deathvox_lightshot.dodge = presets.dodge.deathvox
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
	table.insert(self._enemy_list, "deathvox_lightshot")
	
	self.deathvox_heavyshot = deep_clone(self.city_swat)
	self.deathvox_heavyshot.detection = presets.detection.normal
	self.deathvox_heavyshot.damage.hurt_severity = presets.hurt_severities.only_fire_and_poison_hurts -- new with final 2017 pass.
	self.deathvox_heavyshot.suppression = presets.suppression.hard_agg -- tentative.
	self.deathvox_heavyshot.surrender = presets.surrender.hard -- tentative.
	self.deathvox_heavyshot.move_speed = presets.move_speed.very_fast
	self.deathvox_heavyshot.surrender_break_time = {6, 8} 
	self.deathvox_heavyshot.ecm_vulnerability = 1
	self.deathvox_heavyshot.ecm_hurts = {
		ears = {min_duration = 6, max_duration = 8}
	}
	self.deathvox_heavyshot.dodge = presets.dodge.deathvox
	self.deathvox_heavyshot.deathguard = true
	self.deathvox_heavyshot.no_arrest = true
	self.deathvox_heavyshot.steal_loot = true
	self.deathvox_heavyshot.rescue_hostages = true
	self.deathvox_heavyshot.weapon = deep_clone(presets.weapon.deathvox)
	self.deathvox_heavyshot.factory_weapon_id = {"wpn_deathvox_shotgun_heavy"}
	self.deathvox_heavyshot.use_factory = true
	self.deathvox_heavyshot.HEALTH_INIT = 101 -- new with final 2017 pass.
	self.deathvox_heavyshot.headshot_dmg_mul = 3
	self.deathvox_heavyshot.damage.explosion_damage_mul = 0.9
	self.deathvox_heavyshot.access = "any"
	table.insert(self._enemy_list, "deathvox_heavyshot")
	
	self.deathvox_shield = deep_clone(self.shield)
	self.deathvox_shield.tags = {"shield"} -- just to be sure it's being applied.
	self.deathvox_shield.detection = presets.detection.normal
	self.deathvox_shield.damage.hurt_severity = presets.hurt_severities.only_explosion_hurts
	self.deathvox_shield.suppression = presets.suppression.no_supress -- I think this is in resto, if not it now is.
	self.deathvox_shield.surrender = nil
	self.deathvox_shield.move_speed = presets.move_speed.very_fast -- same as base.
	self.deathvox_shield.ecm_vulnerability = .9 -- same as base.
	self.deathvox_shield.ecm_hurts = {
		ears = {min_duration = 6, max_duration = 8} -- same as general enemies, less than vanilla.
	}
	self.deathvox_shield.deathguard = false
	self.deathvox_shield.no_arrest = true
	self.deathvox_shield.steal_loot = true -- this is new.
	self.deathvox_shield.rescue_hostages = false
	self.deathvox_shield.weapon = deep_clone(presets.weapon.deathvox)
	self.deathvox_shield.HEALTH_INIT = 72
	self.deathvox_shield.headshot_dmg_mul = 3
	self.deathvox_shield.is_special_unit = "shield"	
	self.deathvox_shield.access = "any"
	table.insert(self._enemy_list, "deathvox_shield")
	
	self.deathvox_medic = deep_clone(self.medic)
	self.deathvox_medic.tags = {"medic"} --just making sure tag applies.
	self.deathvox_medic.detection = presets.detection.normal
	self.deathvox_medic.damage.hurt_severity = presets.hurt_severities.only_fire_and_poison_hurts -- added to make code consistent.
	self.deathvox_medic.suppression = presets.suppression.no_supress -- in base.
	self.deathvox_medic.surrender = presets.surrender.special 
	self.deathvox_medic.move_speed = presets.move_speed.very_fast
	self.deathvox_medic.surrender_break_time = {7, 12} 
	self.deathvox_medic.ecm_vulnerability = 1
	self.deathvox_medic.ecm_hurts = {
		ears = {min_duration = 8, max_duration = 10}
	}
	self.deathvox_medic.dodge = presets.dodge.deathvox
	self.deathvox_medic.deathguard = false
	self.deathvox_medic.no_arrest = true 
	self.deathvox_medic.steal_loot = nil
	self.deathvox_medic.rescue_hostages = false
	self.deathvox_medic.weapon = deep_clone(presets.weapon.deathvox)
	self.deathvox_medic.use_factory = true
	self.deathvox_medic.dv_medic_heal = true -- dont touch, makes him use the death vox healing
	self.deathvox_medic.factory_weapon_id = {"wpn_deathvox_medic_pistol"}
	self.deathvox_medic.HEALTH_INIT = 48
	self.deathvox_medic.headshot_dmg_mul = 3
	self.deathvox_medic.is_special_unit = "medic"
	self.deathvox_medic.access = "any"
	table.insert(self._enemy_list, "deathvox_medic") 

	self.deathvox_taser = deep_clone(self.taser)
	self.deathvox_taser.tags = {"taser"} -- just making sure tag applies.
	self.deathvox_taser.detection = presets.detection.normal
	self.deathvox_taser.damage.hurt_severity = presets.hurt_severities.only_light_hurt_and_fire
	self.deathvox_taser.damage.hurt_severity.tase = false -- if this works, great, horrible things will arise.
	self.deathvox_taser.suppression = presets.suppression.no_supress -- consistent form added.
	self.deathvox_taser.surrender = presets.surrender.special 
	self.deathvox_taser.move_speed = presets.move_speed.fast
	self.deathvox_taser.surrender_break_time = {7, 12} 
	self.deathvox_taser.ecm_vulnerability = 0.9 -- in base
	self.deathvox_taser.ecm_hurts = {
		ears = {min_duration = 6, max_duration = 8} -- in base
	}
	self.deathvox_taser.dodge = presets.dodge.deathvox
	self.deathvox_taser.deathguard = true 
	self.deathvox_taser.no_arrest = true
	self.deathvox_taser.steal_loot = nil
	self.deathvox_taser.rescue_hostages = false
	self.deathvox_taser.HEALTH_INIT = 101 -- new with final 2017 pass.
	self.deathvox_taser.headshot_dmg_mul = 3
	self.deathvox_taser.is_special_unit = "taser"
	self.deathvox_taser.access = "any"
	table.insert(self._enemy_list, "deathvox_taser") 

	self.deathvox_cloaker = deep_clone(self.spooc)
	self.deathvox_cloaker.tags = {"spooc"} -- just making sure tag applies.
	self.deathvox_cloaker.detection = presets.detection.normal
	self.deathvox_cloaker.suppression = nil
	self.deathvox_cloaker.surrender = presets.surrender.special 
	self.deathvox_cloaker.move_speed = presets.move_speed.lightning
	self.deathvox_cloaker.HEALTH_INIT = 96
	self.deathvox_cloaker.headshot_dmg_mul = 3
	self.deathvox_cloaker.surrender_break_time = {4, 6} 
	self.deathvox_cloaker.ecm_vulnerability = 0
	self.deathvox_cloaker.dodge = presets.dodge.deathvoxninja
	self.deathvox_cloaker.deathguard = true 
	self.deathvox_cloaker.no_arrest = true
	self.deathvox_cloaker.steal_loot = nil
	self.deathvox_cloaker.rescue_hostages = false
	self.deathvox_cloaker.factory_weapon_id = {"wpn_deathvox_cloaker"}
	self.deathvox_cloaker.use_factory = true
	self.deathvox_cloaker.is_special_unit = "spooc"
	self.deathvox_cloaker.access = "any"
	self.deathvox_cloaker.use_pdth_shit = true

	table.insert(self._enemy_list, "deathvox_cloaker") 

	self.deathvox_sniper = deep_clone(self.sniper)
	self.deathvox_sniper.tags = {"sniper"} -- just making sure tag applies.
	self.deathvox_sniper.detection = presets.detection.normal
	self.deathvox_sniper.suppression = presets.suppression.no_supress -- this actually makes snipers way less annoying!
	self.deathvox_sniper.surrender = presets.surrender.special 
	self.deathvox_sniper.move_speed = presets.move_speed.normal -- same as base.
	self.deathvox_sniper.surrender_break_time = {4, 6} 
	self.deathvox_sniper.ecm_vulnerability = 0
	self.deathvox_sniper.no_arrest = true
	self.deathvox_sniper.steal_loot = nil
	self.deathvox_sniper.rescue_hostages = false

	self.deathvox_sniper.use_factory = true -- Use a factory weapon
	self.deathvox_sniper.factory_weapon_id = {"wpn_deathvox_sniper"}
	self.deathvox_sniper.HEALTH_INIT = 15 -- note does not match assault, consider revise.
	self.deathvox_sniper.headshot_dmg_mul = 3
	self.deathvox_sniper.is_special_unit = "sniper"
	self.deathvox_sniper.access = "any"

	self.deathvox_sniper_assault = deep_clone(self.deathvox_sniper)
	self.deathvox_sniper_assault.move_speed = presets.move_speed.very_fast
	self.deathvox_sniper_assault.deathguard = true
	self.deathvox_sniper_assault.HEALTH_INIT = 34
	self.deathvox_sniper_assault.headshot_dmg_mul = 3
	self.deathvox_sniper_assault.is_special_unit = "ass_sniper"
	self.deathvox_sniper_assault.access = "any"
	table.insert(self._enemy_list, "deathvox_sniper_assault")

	self.deathvox_tank = deep_clone(self.tank)
	self.deathvox_tank.tags = {"tank"} -- just making sure tag applies.
	self.deathvox_tank.detection = presets.detection.normal
	self.deathvox_tank.damage.hurt_severity = presets.hurt_severities.no_hurts_no_tase -- new with final 2017 pass. Probably not a change, needs to stay.
	self.deathvox_tank.suppression = presets.suppression.no_supress
	self.deathvox_tank.surrender = nil
	self.deathvox_tank.surrender_break_time = {4, 6}
	self.deathvox_tank.ecm_vulnerability = 0.85
	self.deathvox_tank.ecm_hurts = {
        ears = {min_duration = 1, max_duration = 3} -- tentative, in base
    }
	self.deathvox_tank.deathguard = true
	self.deathvox_tank.no_arrest = true
	self.deathvox_tank.steal_loot = nil
	self.deathvox_tank.rescue_hostages = false
	self.deathvox_tank.HEALTH_INIT = 875
	self.deathvox_tank.damage.explosion_damage_mul = 0.7  -- new with final 2017 pass. Highly tentative. I do not believe this will effect armor. Requires scrutiny.
	self.deathvox_tank.is_special_unit = "tank"
	self.deathvox_tank.access = "walk"

    self.deathvox_greendozer = deep_clone(self.deathvox_tank)
	self.deathvox_greendozer.use_factory = true -- Use a factory weapon
	self.deathvox_greendozer.factory_weapon_id = {"wpn_deathvox_greendozer"} 
	self.deathvox_greendozer.access = "tank"
	table.insert(self._enemy_list, "deathvox_greendozer")

    self.deathvox_blackdozer = deep_clone(self.deathvox_tank)
	self.deathvox_blackdozer.use_factory = true -- Use a factory weapon
	self.deathvox_blackdozer.factory_weapon_id = {"wpn_deathvox_blackdozer"} 
	self.deathvox_blackdozer.access = "walk"
	table.insert(self._enemy_list, "deathvox_blackdozer")

    self.deathvox_lmgdozer = deep_clone(self.deathvox_tank)
	self.deathvox_lmgdozer.use_factory = true -- Use a factory weapon
	self.deathvox_lmgdozer.factory_weapon_id = {"wpn_deathvox_lmgdozer"} 
	self.deathvox_lmgdozer.access = "walk"
	table.insert(self._enemy_list, "deathvox_lmgdozer")
	
    self.deathvox_medicdozer = deep_clone(self.deathvox_tank)
	self.deathvox_medicdozer.tags = {"tank", "medic"}
	self.deathvox_medicdozer.use_factory = true -- Use a factory weapon
	self.deathvox_medicdozer.factory_weapon_id = {"wpn_deathvox_medicdozer_smg"} 
	self.deathvox_medicdozer.dv_medic_heal = true -- dont touch, makes him use the death vox healing
	self.deathvox_medicdozer.custom_voicework = "medicdozer"
	self.deathvox_medicdozer.access = "walk"
	self.deathvox_medicdozer.disable_medic_heal_voice = true
	table.insert(self._enemy_list, "deathvox_medicdozer")

	self.deathvox_grenadier = deep_clone(presets.base)
	self.deathvox_grenadier.tags = {"custom"}
	self.deathvox_grenadier.experience = {}
	self.deathvox_grenadier.weapon = deep_clone(presets.weapon.normal)
	self.deathvox_grenadier.melee_weapon = "knife_1"
	self.deathvox_grenadier.melee_weapon_dmg_multiplier = 1
	self.deathvox_grenadier.weapon_safety_range = 1000
	self.deathvox_grenadier.detection = presets.detection.normal
	self.deathvox_grenadier.damage.hurt_severity = presets.hurt_severities.only_light_hurt_and_fire -- immune to poison. new with final 2017 pass.
	self.deathvox_grenadier.HEALTH_INIT = 101
	self.deathvox_grenadier.HEALTH_SUICIDE_LIMIT = 0.25
	self.deathvox_grenadier.flammable = true
	self.deathvox_grenadier.use_animation_on_fire_damage = true
	self.deathvox_grenadier.damage.fire_damage_mul = 1
	self.deathvox_grenadier.headshot_dmg_mul = 3
	self.deathvox_grenadier.bag_dmg_mul = 6
	self.deathvox_grenadier.move_speed = presets.move_speed.fast
	self.deathvox_grenadier.no_retreat = true
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
	
end

function CharacterTweakData:_set_sm_wish()
	if SystemInfo:platform() == Idstring("PS3") then
		self:_multiply_all_hp(1, 1)
	else
		self:_multiply_all_hp(1, 1)
	end
	self:_multiply_weapon_delay(self.presets.weapon.normal, 0)
	self:_multiply_weapon_delay(self.presets.weapon.good, 0)
	self:_multiply_weapon_delay(self.presets.weapon.expert, 0)
	self:_multiply_weapon_delay(self.presets.weapon.sniper, 0)
	self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0)
	self.security = deep_clone(self.deathvox_guard) -- fucking broke piece of shit movement stuff
	self.gensec = deep_clone(self.deathvox_guard)
	self.bolivian_indoors.HEALTH_INIT = 36
	self.gangster.HEALTH_INIT = 36
	self.biker.HEALTH_INIT = 36
	self.biker_escape.HEALTH_INIT = 36
	self.cop.HEALTH_INIT = 15
	self:_set_characters_weapon_preset("deathvox")
	self.deathvox_sniper_assault.weapon = deep_clone(self.presets.weapon.deathvox_sniper)
	self:_set_characters_melee_preset("3")
	self:_set_specials_weapon_preset("deathvox")
	self.shield.weapon.is_pistol.melee_speed = nil
	self.shield.weapon.is_pistol.melee_dmg = nil
	self.shield.weapon.is_pistol.melee_retry_delay = nil
	self:_set_specials_melee_preset("2.5")
	self.sniper = deep_clone(self.deathvox_sniper)
	self.sniper.weapon = deep_clone(self.presets.weapon.deathvox_sniper)
	self.security.no_arrest = true
	self.gensec.no_arrest = true
	self.bolivian_indoors.no_arrest = true
	if job == "kosugi" or job == "dark" then
		self.city_swat.no_arrest = true
	else
		self.city_swat.no_arrest = false
	end
	self:_multiply_all_speeds(1, 1)
	self.presets.gang_member_damage.HEALTH_INIT = 525
	self.presets.gang_member_damage.MIN_DAMAGE_INTERVAL = 0.75
	self.old_hoxton_mission.HEALTH_INIT = 525
	self.spa_vip.HEALTH_INIT = 525
	self.presets.gang_member_damage.BLEED_OUT_HEALTH_INIT = 525
	self.flashbang_multiplier = 2
	self.concussion_multiplier = 2
end
function CharacterTweakData:_multiply_all_hp(hp_mul, hs_mul)
	self.security.HEALTH_INIT = self.security.HEALTH_INIT * hp_mul
	self.gensec.HEALTH_INIT = self.gensec.HEALTH_INIT * hp_mul
	self.cop.HEALTH_INIT = self.cop.HEALTH_INIT * hp_mul
	self.cop_scared.HEALTH_INIT = self.cop_scared.HEALTH_INIT * hp_mul
	self.cop_female.HEALTH_INIT = self.cop_female.HEALTH_INIT * hp_mul
	self.fbi.HEALTH_INIT = self.fbi.HEALTH_INIT * hp_mul
	self.medic.HEALTH_INIT = self.medic.HEALTH_INIT * hp_mul
	self.bolivian.HEALTH_INIT = self.bolivian.HEALTH_INIT * hp_mul
	self.bolivian_indoors.HEALTH_INIT = self.bolivian_indoors.HEALTH_INIT * hp_mul
	self.drug_lord_boss.HEALTH_INIT = self.drug_lord_boss.HEALTH_INIT * hp_mul
	self.drug_lord_boss_stealth.HEALTH_INIT = self.drug_lord_boss_stealth.HEALTH_INIT * hp_mul
	self.fbi_swat.HEALTH_INIT = self.fbi_swat.HEALTH_INIT * hp_mul
	self.city_swat.HEALTH_INIT = self.city_swat.HEALTH_INIT * hp_mul
	self.swat.HEALTH_INIT = self.swat.HEALTH_INIT * hp_mul
	self.heavy_swat.HEALTH_INIT = self.heavy_swat.HEALTH_INIT * hp_mul
	self.heavy_swat_sniper.HEALTH_INIT = self.heavy_swat_sniper.HEALTH_INIT * hp_mul
	self.fbi_heavy_swat.HEALTH_INIT = self.fbi_heavy_swat.HEALTH_INIT * hp_mul
	self.sniper.HEALTH_INIT = self.sniper.HEALTH_INIT * hp_mul
	self.gangster.HEALTH_INIT = self.gangster.HEALTH_INIT * hp_mul
	self.mobster.HEALTH_INIT = self.mobster.HEALTH_INIT * hp_mul
	self.mobster_boss.HEALTH_INIT = self.mobster_boss.HEALTH_INIT * hp_mul
	self.chavez_boss.HEALTH_INIT = self.chavez_boss.HEALTH_INIT * hp_mul
	self.hector_boss.HEALTH_INIT = self.hector_boss.HEALTH_INIT * hp_mul
	self.hector_boss_no_armor.HEALTH_INIT = self.hector_boss_no_armor.HEALTH_INIT * hp_mul
	self.biker_boss.HEALTH_INIT = self.biker_boss.HEALTH_INIT * hp_mul
	self.biker.HEALTH_INIT = self.biker.HEALTH_INIT * hp_mul
	self.tank.HEALTH_INIT = self.tank.HEALTH_INIT * hp_mul
	self.tank_mini.HEALTH_INIT = self.tank_mini.HEALTH_INIT * hp_mul
	self.tank_medic.HEALTH_INIT = self.tank_medic.HEALTH_INIT * hp_mul
	self.tank_hw.HEALTH_INIT = self.tank_hw.HEALTH_INIT * hp_mul
	self.spooc.HEALTH_INIT = self.spooc.HEALTH_INIT * hp_mul
	self.shield.HEALTH_INIT = self.shield.HEALTH_INIT * hp_mul
	self.phalanx_minion.HEALTH_INIT = self.phalanx_minion.HEALTH_INIT * hp_mul
	self.phalanx_vip.HEALTH_INIT = self.phalanx_vip.HEALTH_INIT * hp_mul
	self.taser.HEALTH_INIT = self.taser.HEALTH_INIT * hp_mul
	self.biker_escape.HEALTH_INIT = self.biker_escape.HEALTH_INIT * hp_mul
	self.deathvox_guard.HEALTH_INIT = self.deathvox_guard.HEALTH_INIT * hp_mul
	self.deathvox_heavyar.HEALTH_INIT = self.deathvox_heavyar.HEALTH_INIT * hp_mul
	self.deathvox_heavyshot.HEALTH_INIT = self.deathvox_heavyshot.HEALTH_INIT * hp_mul
	self.deathvox_lightar.HEALTH_INIT = self.deathvox_lightar.HEALTH_INIT * hp_mul
	self.deathvox_lightshot.HEALTH_INIT = self.deathvox_lightshot.HEALTH_INIT * hp_mul
	self.deathvox_shield.HEALTH_INIT = self.deathvox_shield.HEALTH_INIT * hp_mul
	self.deathvox_medic.HEALTH_INIT = self.deathvox_medic.HEALTH_INIT * hp_mul

	self.deathvox_taser.HEALTH_INIT = self.deathvox_taser.HEALTH_INIT * hp_mul
	self.deathvox_cloaker.HEALTH_INIT = self.deathvox_cloaker.HEALTH_INIT * hp_mul
	self.deathvox_sniper_assault.HEALTH_INIT = self.deathvox_sniper_assault.HEALTH_INIT * hp_mul
	self.deathvox_greendozer.HEALTH_INIT = self.deathvox_greendozer.HEALTH_INIT * hp_mul
	self.deathvox_blackdozer.HEALTH_INIT = self.deathvox_blackdozer.HEALTH_INIT * hp_mul
	self.deathvox_lmgdozer.HEALTH_INIT = self.deathvox_lmgdozer.HEALTH_INIT * hp_mul
	self.deathvox_medicdozer.HEALTH_INIT = self.deathvox_medicdozer.HEALTH_INIT * hp_mul
	self.deathvox_grenadier.HEALTH_INIT = self.deathvox_grenadier.HEALTH_INIT * hp_mul
	
	if self.security.headshot_dmg_mul then
		self.security.headshot_dmg_mul = self.security.headshot_dmg_mul * hs_mul
	end
	if self.gensec.headshot_dmg_mul then
		self.gensec.headshot_dmg_mul = self.gensec.headshot_dmg_mul * hs_mul
	end
	if self.cop.headshot_dmg_mul then
		self.cop.headshot_dmg_mul = self.cop.headshot_dmg_mul * hs_mul
	end
	if self.cop_scared.headshot_dmg_mul then
		self.cop_scared.headshot_dmg_mul = self.cop_scared.headshot_dmg_mul * hs_mul
	end
	if self.cop_female.headshot_dmg_mul then
		self.cop_female.headshot_dmg_mul = self.cop_female.headshot_dmg_mul * hs_mul
	end
	if self.fbi.headshot_dmg_mul then
		self.fbi.headshot_dmg_mul = self.fbi.headshot_dmg_mul * hs_mul
	end
	if self.medic.headshot_dmg_mul then
		self.medic.headshot_dmg_mul = self.medic.headshot_dmg_mul * hs_mul
	end
	if self.fbi_swat.headshot_dmg_mul then
		self.fbi_swat.headshot_dmg_mul = self.fbi_swat.headshot_dmg_mul * hs_mul
	end
	if self.city_swat.headshot_dmg_mul then
		self.city_swat.headshot_dmg_mul = self.city_swat.headshot_dmg_mul * hs_mul
	end
	if self.swat.headshot_dmg_mul then
		self.swat.headshot_dmg_mul = self.swat.headshot_dmg_mul * hs_mul
	end
	if self.heavy_swat.headshot_dmg_mul then
		self.heavy_swat.headshot_dmg_mul = self.heavy_swat.headshot_dmg_mul * hs_mul
	end
	if self.heavy_swat_sniper.headshot_dmg_mul then
		self.heavy_swat_sniper.headshot_dmg_mul = self.heavy_swat_sniper.headshot_dmg_mul * hs_mul
	end
	if self.fbi_heavy_swat.headshot_dmg_mul then
		self.fbi_heavy_swat.headshot_dmg_mul = self.fbi_heavy_swat.headshot_dmg_mul * hs_mul
	end
	if self.sniper.headshot_dmg_mul then
		self.sniper.headshot_dmg_mul = self.sniper.headshot_dmg_mul * hs_mul
	end
	if self.gangster.headshot_dmg_mul then
		self.gangster.headshot_dmg_mul = self.gangster.headshot_dmg_mul * hs_mul
	end
	if self.hector_boss.headshot_dmg_mul then
		self.hector_boss.headshot_dmg_mul = self.hector_boss.headshot_dmg_mul * hs_mul
	end
	if self.hector_boss_no_armor.headshot_dmg_mul then
		self.hector_boss_no_armor.headshot_dmg_mul = self.hector_boss_no_armor.headshot_dmg_mul * hs_mul
	end
	if self.mobster.headshot_dmg_mul then
		self.mobster.headshot_dmg_mul = self.mobster.headshot_dmg_mul * hs_mul
	end
	if self.mobster_boss.headshot_dmg_mul then
		self.mobster_boss.headshot_dmg_mul = self.mobster_boss.headshot_dmg_mul * hs_mul
	end
	if self.biker.headshot_dmg_mul then
		self.biker.headshot_dmg_mul = self.biker.headshot_dmg_mul * hs_mul
	end
	if self.biker_boss.headshot_dmg_mul then
		self.biker_boss.headshot_dmg_mul = self.biker_boss.headshot_dmg_mul * hs_mul
	end
	if self.tank.headshot_dmg_mul then
		self.tank.headshot_dmg_mul = self.tank.headshot_dmg_mul * hs_mul
	end
	if self.tank_mini.headshot_dmg_mul then
		self.tank_mini.headshot_dmg_mul = self.tank_mini.headshot_dmg_mul * hs_mul
	end
	if self.tank_medic.headshot_dmg_mul then
		self.tank_medic.headshot_dmg_mul = self.tank_medic.headshot_dmg_mul * hs_mul
	end
	if self.chavez_boss.headshot_dmg_mul then
		self.chavez_boss.headshot_dmg_mul = self.chavez_boss.headshot_dmg_mul * hs_mul
	end
	if self.tank_hw.headshot_dmg_mul then
		self.tank_hw.headshot_dmg_mul = self.tank_hw.headshot_dmg_mul * hs_mul
	end
	if self.spooc.headshot_dmg_mul then
		self.spooc.headshot_dmg_mul = self.spooc.headshot_dmg_mul * hs_mul
	end
	if self.shield.headshot_dmg_mul then
		self.shield.headshot_dmg_mul = self.shield.headshot_dmg_mul * hs_mul
	end
	if self.phalanx_minion.headshot_dmg_mul then
		self.phalanx_minion.headshot_dmg_mul = self.phalanx_minion.headshot_dmg_mul * hs_mul
	end
	if self.phalanx_vip.headshot_dmg_mul then
		self.phalanx_vip.headshot_dmg_mul = self.phalanx_vip.headshot_dmg_mul * hs_mul
	end
	if self.taser.headshot_dmg_mul then
		self.taser.headshot_dmg_mul = self.taser.headshot_dmg_mul * hs_mul
	end
	if self.biker_escape.headshot_dmg_mul then
		self.biker_escape.headshot_dmg_mul = self.biker_escape.headshot_dmg_mul * hs_mul
	end
	if self.drug_lord_boss.headshot_dmg_mul then
		self.drug_lord_boss.headshot_dmg_mul = self.drug_lord_boss.headshot_dmg_mul * hs_mul
	end
	if self.drug_lord_boss_stealth.headshot_dmg_mul then
		self.drug_lord_boss_stealth.headshot_dmg_mul = self.drug_lord_boss_stealth.headshot_dmg_mul * hs_mul
	end
	if self.bolivian.headshot_dmg_mul then
		self.bolivian.headshot_dmg_mul = self.bolivian.headshot_dmg_mul * hs_mul
	end
	if self.bolivian_indoors.headshot_dmg_mul then
		self.bolivian_indoors.headshot_dmg_mul = self.bolivian_indoors.headshot_dmg_mul * hs_mul
	end
	if self.deathvox_guard.headshot_dmg_mul then
		self.deathvox_guard.headshot_dmg_mul = self.deathvox_guard.headshot_dmg_mul * hs_mul
	end
	if self.deathvox_heavyar.headshot_dmg_mul then
		self.deathvox_heavyar.headshot_dmg_mul = self.deathvox_heavyar.headshot_dmg_mul * hs_mul
	end
	if self.deathvox_heavyshot.headshot_dmg_mul then
		self.deathvox_heavyshot.headshot_dmg_mul = self.deathvox_heavyshot.headshot_dmg_mul * hs_mul
	end
	if self.deathvox_lightar.headshot_dmg_mul then
		self.deathvox_lightar.headshot_dmg_mul = self.deathvox_lightar.headshot_dmg_mul * hs_mul
	end
	if self.deathvox_medic.headshot_dmg_mul then
		self.deathvox_medic.headshot_dmg_mul = self.deathvox_medic.headshot_dmg_mul * hs_mul
	end
	if self.deathvox_shield.headshot_dmg_mul then
		self.deathvox_shield.headshot_dmg_mul = self.deathvox_shield.headshot_dmg_mul * hs_mul
	end
	if self.deathvox_lightshot.headshot_dmg_mul then
		self.deathvox_lightshot.headshot_dmg_mul = self.deathvox_lightshot.headshot_dmg_mul * hs_mul
	end
	if self.deathvox_taser.headshot_dmg_mul then
		self.deathvox_taser.headshot_dmg_mul = self.deathvox_taser.headshot_dmg_mul * hs_mul
	end
	if self.deathvox_cloaker.headshot_dmg_mul then
		self.deathvox_cloaker.headshot_dmg_mul = self.deathvox_cloaker.headshot_dmg_mul * hs_mul
	end
	if self.deathvox_sniper_assault.headshot_dmg_mul then
		self.deathvox_sniper_assault.headshot_dmg_mul = self.deathvox_sniper_assault.headshot_dmg_mul * hs_mul
	end
	if self.deathvox_greendozer.headshot_dmg_mul then
		self.deathvox_greendozer.headshot_dmg_mul = self.deathvox_greendozer.headshot_dmg_mul * hs_mul
	end
	if self.deathvox_blackdozer.headshot_dmg_mul then
		self.deathvox_blackdozer.headshot_dmg_mul = self.deathvox_blackdozer.headshot_dmg_mul * hs_mul
	end
	if self.deathvox_lmgdozer.headshot_dmg_mul then
		self.deathvox_lmgdozer.headshot_dmg_mul = self.deathvox_lmgdozer.headshot_dmg_mul * hs_mul
	end
	if self.deathvox_medicdozer.headshot_dmg_mul then
		self.deathvox_medicdozer.headshot_dmg_mul = self.deathvox_medicdozer.headshot_dmg_mul * hs_mul
	end
	if self.deathvox_grenadier.headshot_dmg_mul then
		self.deathvox_grenadier.headshot_dmg_mul = self.deathvox_grenadier.headshot_dmg_mul * hs_mul
	end
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
		log(name)
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

function CharacterTweakData:character_map()
	local char_map = {
		basic = {
			path = "units/payday2/characters/",
			list = {
				"civ_female_bank_1",
				"civ_female_bank_manager_1",
				"civ_female_bikini_1",
				"civ_female_bikini_2",
				"civ_female_casual_1",
				"civ_female_casual_2",
				"civ_female_casual_3",
				"civ_female_casual_4",
				"civ_female_casual_5",
				"civ_female_casual_6",
				"civ_female_casual_7",
				"civ_female_casual_8",
				"civ_female_casual_9",
				"civ_female_casual_10",
				"civ_female_crackwhore_1",
				"civ_female_curator_1",
				"civ_female_curator_2",
				"civ_female_hostess_apron_1",
				"civ_female_hostess_jacket_1",
				"civ_female_hostess_shirt_1",
				"civ_female_party_1",
				"civ_female_party_2",
				"civ_female_party_3",
				"civ_female_party_4",
				"civ_female_waitress_1",
				"civ_female_waitress_2",
				"civ_female_waitress_3",
				"civ_female_waitress_4",
				"civ_female_wife_trophy_1",
				"civ_female_wife_trophy_2",
				"civ_male_bank_1",
				"civ_male_bank_2",
				"civ_male_bank_manager_1",
				"civ_male_bank_manager_3",
				"civ_male_bank_manager_4",
				"civ_male_bank_manager_5",
				"civ_male_bartender_1",
				"civ_male_bartender_2",
				"civ_male_business_1",
				"civ_male_business_2",
				"civ_male_casual_1",
				"civ_male_casual_2",
				"civ_male_casual_3",
				"civ_male_casual_4",
				"civ_male_casual_5",
				"civ_male_casual_6",
				"civ_male_casual_7",
				"civ_male_casual_8",
				"civ_male_casual_9",
				"civ_male_casual_12",
				"civ_male_casual_13",
				"civ_male_casual_14",
				"civ_male_curator_1",
				"civ_male_curator_2",
				"civ_male_curator_3",
				"civ_male_dj_1",
				"civ_male_italian_robe_1",
				"civ_male_janitor_1",
				"civ_male_janitor_2",
				"civ_male_janitor_3",
				"civ_male_meth_cook_1",
				"civ_male_party_1",
				"civ_male_party_2",
				"civ_male_party_3",
				"civ_male_pilot_1",
				"civ_male_scientist_1",
				"civ_male_miami_store_clerk_1",
				"civ_male_taxman",
				"civ_male_trucker_1",
				"civ_male_worker_1",
				"civ_male_worker_2",
				"civ_male_worker_3",
				"civ_male_worker_docks_1",
				"civ_male_worker_docks_2",
				"civ_male_worker_docks_3",
				"civ_male_dog_abuser_1",
				"civ_male_dog_abuser_2",
				"ene_biker_1",
				"ene_biker_2",
				"ene_biker_3",
				"ene_biker_4",
				"ene_bulldozer_1",
				"ene_bulldozer_2",
				"ene_bulldozer_2_hw",
				"ene_bulldozer_3",
				"ene_bulldozer_4",
				"ene_city_swat_1",
				"ene_city_swat_2",
				"ene_city_swat_3",
				"ene_city_swat_heavy_1",
				"ene_city_swat_heavy_2",
				"ene_murkywater_1",
				"ene_murkywater_2",
				"ene_cop_1",
				"ene_cop_2",
				"ene_cop_3",
				"ene_cop_4",
				"ene_fbi_1",
				"ene_fbi_2",
				"ene_fbi_3",
				"ene_fbi_boss_1",
				"ene_fbi_female_1",
				"ene_fbi_female_2",
				"ene_fbi_female_3",
				"ene_fbi_female_4",
				"ene_fbi_heavy_1",
				"ene_fbi_heavy_r870",
				"ene_fbi_office_1",
				"ene_fbi_office_2",
				"ene_fbi_office_3",
				"ene_fbi_office_4",
				"ene_fbi_swat_1",
				"ene_fbi_swat_2",
				"ene_fbi_swat_3",
				"ene_gang_black_1",
				"ene_gang_black_2",
				"ene_gang_black_3",
				"ene_gang_black_4",
				"ene_gang_mexican_1",
				"ene_gang_mexican_2",
				"ene_gang_mexican_3",
				"ene_gang_mexican_4",
				"ene_gang_russian_1",
				"ene_gang_russian_2",
				"ene_gang_russian_3",
				"ene_gang_russian_4",
				"ene_gang_russian_5",
				"ene_gang_mobster_1",
				"ene_gang_mobster_2",
				"ene_gang_mobster_3",
				"ene_gang_mobster_4",
				"ene_gang_mobster_boss",
				"ene_guard_national_1",
				"ene_hoxton_breakout_guard_1",
				"ene_hoxton_breakout_guard_2",
				"ene_male_tgt_1",
				"ene_murkywater_1",
				"ene_murkywater_2",
				"ene_prisonguard_female_1",
				"ene_prisonguard_male_1",
				"ene_secret_service_1",
				"ene_secret_service_2",
				"ene_security_1",
				"ene_security_2",
				"ene_security_3",
				"ene_security_4",
				"ene_security_5",
				"ene_security_6",
				"ene_security_7",
				"ene_security_8",
				"ene_shield_1",
				"ene_shield_2",
				"ene_city_shield",
				"ene_shield_gensec",
				"ene_phalanx_1",
				"ene_vip_1",
				"ene_vip_2",
				"ene_sniper_1",
				"ene_sniper_2",
				"ene_spook_1",
				"ene_swat_1",
				"ene_swat_2",
				"ene_swat_heavy_1",
				"ene_swat_heavy_r870",
				"ene_tazer_1",
				"npc_old_hoxton_prisonsuit_1",
				"npc_old_hoxton_prisonsuit_2",
				"ene_medic_r870",
				"ene_medic_m4",
				"ene_city_heavy_r870",
				"ene_city_heavy_g36",
				"ene_guard_biker_1",
				"ene_murky_heavy_m4",
				"ene_murky_heavy_r870"
			}
		},
		dlc1 = {
			path = "units/pd2_dlc1/characters/",
			list = {
				"civ_male_bank_manager_2",
				"civ_male_casual_10",
				"civ_male_casual_11",
				"civ_male_firefighter_1",
				"civ_male_paramedic_1",
				"civ_male_paramedic_2",
				"ene_security_gensec_1",
				"ene_security_gensec_2"
			}
		},
		dlc2 = {
			path = "units/pd2_dlc2/characters/",
			list = {
				"civ_female_bank_assistant_1",
				"civ_female_bank_assistant_2"
			}
		},
		mansion = {
			path = "units/pd2_mcmansion/characters/",
			list = {
				"ene_male_hector_1",
				"ene_male_hector_2",
				"ene_hoxton_breakout_guard_1",
				"ene_hoxton_breakout_guard_2"
			}
		},
		cage = {
			path = "units/pd2_dlc_cage/characters/",
			list = {
				"civ_female_bank_2"
			}
		},
		arena = {
			path = "units/pd2_dlc_arena/characters/",
			list = {
				"civ_female_fastfood_1",
				"civ_female_party_alesso_1",
				"civ_female_party_alesso_2",
				"civ_female_party_alesso_3",
				"civ_female_party_alesso_4",
				"civ_female_party_alesso_5",
				"civ_female_party_alesso_6",
				"civ_male_party_alesso_1",
				"civ_male_party_alesso_2",
				"civ_male_alesso_booth",
				"civ_male_fastfood_1",
				"ene_guard_security_heavy_2",
				"ene_guard_security_heavy_1"
			}
		},
		kenaz = {
			path = "units/pd2_dlc_casino/characters/",
			list = {
				"civ_male_casino_1",
				"civ_male_casino_2",
				"civ_male_casino_3",
				"civ_male_casino_4",
				"ene_secret_service_1_casino",
				"civ_male_business_casino_1",
				"civ_male_business_casino_2",
				"civ_male_impersonator",
				"civ_female_casino_1",
				"civ_female_casino_2",
				"civ_female_casino_3",
				"civ_male_casino_pitboss"
			}
		},
		vip = {
			path = "units/pd2_dlc_vip/characters/",
			list = {
				"ene_vip_1",
				"ene_vip_2",
				"ene_phalanx_1"
			}
		},
		holly = {
			path = "units/pd2_dlc_holly/characters/",
			list = {
				"civ_male_hobo_1",
				"civ_male_hobo_2",
				"civ_male_hobo_3",
				"civ_male_hobo_4",
				"ene_gang_hispanic_1",
				"ene_gang_hispanic_3",
				"ene_gang_hispanic_2"
			}
		},
		red = {
			path = "units/pd2_dlc_red/characters/",
			list = {
				"civ_female_inside_man_1"
			}
		},
		dinner = {
			path = "units/pd2_dlc_dinner/characters/",
			list = {
				"civ_male_butcher_2",
				"civ_male_butcher_1"
			}
		},
		pal = {
			path = "units/pd2_dlc_pal/characters/",
			list = {
				"civ_male_mitch"
			}
		},
		cane = {
			path = "units/pd2_dlc_cane/characters/",
			list = {
				"civ_male_helper_1",
				"civ_male_helper_2",
				"civ_male_helper_3",
				"civ_male_helper_4"
			}
		},
		berry = {
			path = "units/pd2_dlc_berry/characters/",
			list = {
				"ene_murkywater_no_light",
				"npc_locke"
			}
		},
		peta = {
			path = "units/pd2_dlc_peta/characters/",
			list = {
				"civ_male_boris"
			}
		},
		mad = {
			path = "units/pd2_dlc_mad/characters/",
			list = {
				"civ_male_scientist_01",
				"civ_male_scientist_02",
				"ene_akan_fbi_heavy_g36",
				"ene_akan_fbi_heavy_r870",
				"ene_akan_fbi_shield_sr2_smg",
				"ene_akan_fbi_spooc_asval_smg",
				"ene_akan_fbi_swat_ak47_ass",
				"ene_akan_fbi_swat_dw_ak47_ass",
				"ene_akan_fbi_swat_dw_r870",
				"ene_akan_fbi_swat_dw_ump",
				"ene_akan_fbi_swat_r870",
				"ene_akan_fbi_swat_ump",
				"ene_akan_fbi_tank_r870",
				"ene_akan_fbi_tank_rpk_lmg",
				"ene_akan_fbi_tank_saiga",
				"ene_akan_cs_cop_ak47_ass",
				"ene_akan_cs_cop_akmsu_smg",
				"ene_akan_cs_cop_asval_smg",
				"ene_akan_cs_cop_r870",
				"ene_akan_cs_heavy_ak47_ass",
				"ene_akan_cs_heavy_r870",
				"ene_akan_cs_shield_c45",
				"ene_akan_cs_swat_ak47_ass",
				"ene_akan_cs_swat_r870",
				"ene_akan_cs_swat_sniper_svd_snp",
				"ene_akan_cs_tazer_ak47_ass",
				"ene_akan_fbi_heavy_dw",
				"ene_akan_fbi_heavy_dw_r870",
				"ene_akan_fbi_1",
				"ene_akan_fbi_2",
				"ene_akan_veteran_1",
				"ene_akan_veteran_2",
				"ene_akan_grenadier_1",
				"ene_akan_medic_m4"
			}
		},
		born = {
			path = "units/pd2_dlc_born/characters/",
			list = {
				"ene_gang_biker_boss",
				"ene_biker_female_1",
				"ene_biker_female_2",
				"ene_biker_female_3",
				"npc_male_mechanic"
			}
		},
		flat = {
			path = "units/pd2_dlc_flat/characters/",
			list = {
				"npc_chavez",
				"npc_jamaican"
			}
		},
		help = {
			path = "units/pd2_dlc_help/characters/",
			list = {
				"ene_zeal_bulldozer_halloween"
			}
		},
		glace = {
			path = "units/pd2_dlc_glace/characters/",
			list = {
				"npc_chinese_prisoner",
				"npc_prisoner_1",
				"npc_prisoner_2",
				"npc_prisoner_3",
				"npc_prisoner_4",
				"npc_prisoner_5",
				"npc_prisoner_6",
				"npc_yakuza_prisoner"
			}
		},
		moon = {
			path = "units/pd2_dlc_moon/characters/",
			list = {
				"civ_male_pilot_2"
			}
		},
		friend = {
			path = "units/pd2_dlc_friend/characters/",
			list = {
				"ene_bolivian_thug_outdoor_01",
				"ene_bolivian_thug_outdoor_02",
				"ene_drug_lord_boss",
				"ene_security_manager",
				"ene_thug_indoor_01",
				"ene_thug_indoor_02"
			}
		},
		gitgud = {
			path = "units/pd2_dlc_gitgud/characters/",
			list = {
				"ene_zeal_bulldozer",
				"ene_zeal_bulldozer_2",
				"ene_zeal_bulldozer_3",
				"ene_zeal_cloaker",
				"ene_zeal_swat",
				"ene_zeal_city_1",
				"ene_zeal_city_2",
				"ene_zeal_swat_heavy",
				"ene_zeal_heavy_shield",
				"ene_zeal_swat_shield"
			}
		},
		spa = {
			path = "units/pd2_dlc_spa/characters/",
			list = {
				"ene_sniper_3",
				"npc_spa",
				"npc_spa_2",
				"npc_spa_3",
				"npc_gage"
			}
		},
		fish = {
			path = "units/pd2_dlc_lxy/characters/",
			list = {
				"civ_female_guest_gala_1",
				"civ_female_guest_gala_2",
				"civ_male_guest_gala_1",
				"civ_male_guest_gala_2",
				"civ_male_camera_crew_1"
			}
		},
		slu = {
			path = "units/pd2_dlc_slu/characters/",
			list = {"npc_vlad", "npc_sophia"}
		},
		run = {
			path = "units/pd2_dlc_run/characters/",
			list = {"npc_matt"}
		},
		drm = {
			path = "units/pd2_dlc_drm/characters/",
			list = {
				"ene_bulldozer_medic",
				"ene_bulldozer_minigun",
				"ene_zeal_swat_heavy_sniper"
			}
		},
		wwh = {
			path = "units/pd2_dlc_wwh/characters/",
			list = {
				"ene_female_crew",
				"ene_male_crew_01",
				"ene_male_crew_02",
				"ene_captain",
				"ene_locke"
			}			
		},		
		dah = {
			path = "units/pd2_dlc_dah/characters/",
			list = {
				"npc_male_cfo",
				"npc_male_ralph"
			}
		},		
		hvh = {
			path = "units/pd2_dlc_hvh/characters/",
			list = {
				"ene_cop_hvh_1",
				"ene_cop_hvh_2",
				"ene_cop_hvh_3",
				"ene_cop_hvh_4",
				"ene_swat_hvh_1",
				"ene_swat_hvh_2",
				"ene_fbi_hvh_1",
				"ene_fbi_hvh_2",
				"ene_fbi_hvh_3",
				"ene_spook_hvh_1",
				"ene_swat_heavy_hvh_1",
				"ene_swat_heavy_hvh_r870",
				"ene_tazer_hvh_1",
				"ene_shield_hvh_1",
				"ene_shield_hvh_2",
				"ene_medic_hvh_r870",
				"ene_medic_hvh_m4",
				"ene_bulldozer_hvh_1",
				"ene_bulldozer_hvh_2",
				"ene_bulldozer_hvh_3",
				"ene_fbi_swat_hvh_1",
				"ene_fbi_swat_hvh_2",
				"ene_fbi_heavy_hvh_1",
				"ene_fbi_heavy_hvh_r870",
				"ene_sniper_hvh_2"
			}
		},
		gageammo = {
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
				"ene_deathvox_grenadier"
			}
		}				
	}
	return char_map
end
