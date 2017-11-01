local origin_init = CharacterTweakData.init
local origin_presets = CharacterTweakData._presets

function CharacterTweakData:init(tweak_data)
	origin_init(self, tweak_data)
	local presets = self:_presets(tweak_data)
	self:_init_deathvox(presets)
end

function CharacterTweakData:_presets(tweak_data)
	local presets = origin_presets(self, tweak_data)
	--[[presets.weapon.deathvox = {
		is_pistol = {},--
		is_revolver = {},--
		is_rifle = {},
		is_lmg = {},--
		is_shotgun_pump = {},--
		is_shotgun_mag = {},--
		mossberg = {},
		is_smg = {},--
		mp9 = {},
		rifle = {},
		mac11 = {},
		akimbo_pistol = {},
		mini = {},--
		flamethrower = {},
		is_light_rifle = {},--
		is_heavy_rifle = {},--
		is_light_shotgun = {},--
		is_heavy_shotgun = {},--
		is_tank_smg = {},--
		is_bullpup = {}
	}]]--
	presets.weapon.deathvox = deep_clone(presets.weapon.deathwish)
	presets.weapon.deathvox.is_revolver.aim_delay = {
		0,
		0
	}
	presets.weapon.deathvox.is_revolver.focus_delay = 10 -- validated, unchanged.
	presets.weapon.deathvox.is_revolver.focus_dis = 200
	presets.weapon.deathvox.is_revolver.spread = 20
	presets.weapon.deathvox.is_revolver.miss_dis = 50
	presets.weapon.deathvox.is_revolver.RELOAD_SPEED = 0.9 --validated, unchanged.
	presets.weapon.deathvox.is_revolver.melee_speed = 1
	presets.weapon.deathvox.is_revolver.melee_dmg = 8
	presets.weapon.deathvox.is_revolver.melee_retry_delay = {
		1,
		2
	}
	presets.weapon.deathvox.is_revolver.range = { --validated, unchanged, consider adjustment to increase engage range.
		optimal = 2000,
		far = 5000,
		close = 1000
	}
	presets.weapon.deathvox.is_revolver.FALLOFF = { 
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
	presets.weapon.deathvox.is_pistol = { -- mark 2 values complete. Currently valid for guards, beat police, low level enemies. basis: presets.weapon.deathwish.is_pistol.
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
	presets.weapon.deathvox.is_shotgun_pump = { -- mark 2 values complete. Assumes base damage 400. basis is presets.weapon.deathwish.is_shotgun_pump. Extremely dangerous close range, much less so further out.
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
				dmg_mul = .325,
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
				dmg_mul = .125,
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
	presets.weapon.deathvox.is_shotgun_mag = { -- mark 2 values complete. assumes base damage 225. basis is presets.weapon.deathwish.is_shotgun_pump. Much more even arc distribution-focus/shotcount becomes crucial.
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
				dmg_mul = .6,
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
	presets.weapon.deathvox.is_tank_smg = { -- mark 2 values complete. Assumes base 36. basis is presets.weapon.deathwish.is_smg. Used for medidozer.
		aim_delay = {
			0,
			0
		},
		focus_delay = 0,
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
					0.95,
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
					0.75,
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
					0.65,
					0.65
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
					0.6,
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
	presets.weapon.deathvox.is_light_rifle = { -- mark 2 values complete. basis is presets.weapon.deathwish.is_rifle. General goal- more shots, less damage, reduced range.
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
	presets.weapon.deathvox.is_heavy_rifle = { -- mark 2 values complete. basis is presets.weapon.deathwish.is_rifle. General goal- fewer shots, more damage, greater range.
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
	presets.weapon.deathvox.is_bullpup = presets.weapon.deathvox.is_light_rifle
	presets.weapon.deathvox.is_light_shotgun = { -- mark 2 values complete. basis is presets.weapon.deathwish.is_shotgun_pump. Light shotgunner fires and gains focus faster than Heavy.
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
	presets.weapon.deathvox.is_heavy_shotgun = { -- mark 2 values complete. basis is presets.weapon.deathwish.is_shotgun_pump. Heavy Shotgunner has conventional focal stats.
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
	presets.weapon.deathvox.is_smg = {
		aim_delay = {
			0,
			0.1
		},
		focus_delay = 1,
		focus_dis = 200,
		spread = 15,
		miss_dis = 10,
		RELOAD_SPEED = 1.2,
		melee_speed = presets.weapon.normal.is_smg.melee_speed,
		melee_dmg = presets.weapon.normal.is_smg.melee_dmg,
		melee_retry_delay = presets.weapon.normal.is_smg.melee_retry_delay,
		range = presets.weapon.normal.is_smg.range,
		autofire_rounds = presets.weapon.normal.is_smg.autofire_rounds,
		FALLOFF = {
			{
				dmg_mul = 5,
				r = 100,
				acc = {
					0.6,
					0.95
				},
				recoil = {
					0.1,
					0.25
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 4.5,
				r = 500,
				acc = {
					0.6,
					0.9
				},
				recoil = {
					0.1,
					0.3
				},
				mode = {
					0,
					3,
					3,
					1
				}
			},
			{
				dmg_mul = 4,
				r = 1000,
				acc = {
					0.4,
					0.65
				},
				recoil = {
					0.35,
					0.5
				},
				mode = {
					0,
					3,
					3,
					0
				}
			},
			{
				dmg_mul = 3,
				r = 2000,
				acc = {
					0.4,
					0.6
				},
				recoil = {
					0.35,
					0.7
				},
				mode = {
					0,
					3,
					3,
					0
				}
			},
			{
				dmg_mul = 2,
				r = 3000,
				acc = {
					0.2,
					0.35
				},
				recoil = {
					0.5,
					1.5
				},
				mode = {
					1,
					3,
					2,
					0
				}
			}
		}
	}
	presets.weapon.deathvox.is_revolver.aim_delay = {
		0,
		0
	}
	presets.weapon.deathvox.is_revolver.focus_delay = 10 -- leaving intact
	presets.weapon.deathvox.is_revolver.focus_dis = 200
	presets.weapon.deathvox.is_revolver.spread = 20
	presets.weapon.deathvox.is_revolver.miss_dis = 50
	presets.weapon.deathvox.is_revolver.RELOAD_SPEED = 0.9
	presets.weapon.deathvox.is_revolver.melee_speed = 1
	presets.weapon.deathvox.is_revolver.melee_dmg = 8
	presets.weapon.deathvox.is_revolver.melee_retry_delay = {
		1,
		2
	}
	presets.weapon.deathvox.is_revolver.range = {
		optimal = 2000,
		far = 5000,
		close = 1000
	}
	presets.weapon.deathvox.is_revolver.FALLOFF = { 
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
			dmg_mul = 1,
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
	presets.weapon.deathvox.mini = {
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
	presets.weapon.deathvox.is_lmg = {
		aim_delay = {
			0.1,
			0.1
		},
		focus_delay = 3,
		focus_dis = 200,
		spread = 24,
		miss_dis = 40,
		RELOAD_SPEED = 1,
		melee_speed = 1,
		melee_dmg = 15,
		melee_retry_delay = presets.weapon.normal.is_lmg.melee_retry_delay,
		range = {
			optimal = 2000,
			far = 5000,
			close = 1000
		},
		autofire_rounds = presets.weapon.normal.is_lmg.autofire_rounds,
		FALLOFF = {
			{
				dmg_mul = 3,
				r = 100,
				acc = {
					0.65,
					0.85
				},
				recoil = {
					0.4,
					0.8
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 2,
				r = 500,
				acc = {
					0.4,
					0.8
				},
				recoil = {
					0.45,
					0.8
				},
				mode = {
					0,
					0,
					0,
					1
				}
			},
			{
				dmg_mul = 1.5,
				r = 1000,
				acc = {
					0.2,
					0.7
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
				dmg_mul = 1.25,
				r = 2000,
				acc = {
					0.2,
					0.5
				},
				recoil = {
					0.4,
					1.2
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
				r = 3000,
				acc = {
					0.01,
					0.35
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

	presets.weapon.deathvox_sniper = {is_rifle = {}} -- mark 2 values complete. basis is presets.weapon.sniper. For non-assault wave snipers. Please check I've not botched headings.
	presets.weapon.deathvox_sniper.is_rifle.aim_delay = {
		0,
		0.1
	}
	presets.weapon.deathvox_sniper.is_rifle.focus_delay = 7
	presets.weapon.deathvox_sniper.is_rifle.focus_dis = 200
	presets.weapon.deathvox_sniper.is_rifle.spread = 30
	presets.weapon.deathvox_sniper.is_rifle.miss_dis = 250
	presets.weapon.deathvox_sniper.is_rifle.RELOAD_SPEED = 1.25  -- validated, unchanged.
	presets.weapon.deathvox_sniper.is_rifle.melee_speed = presets.weapon.normal.is_rifle.melee_speed
	presets.weapon.deathvox_sniper.is_rifle.melee_dmg = presets.weapon.normal.is_rifle.melee_dmg
	presets.weapon.deathvox_sniper.is_rifle.melee_retry_delay = presets.weapon.normal.is_rifle.melee_retry_delay
	presets.weapon.deathvox_sniper.is_rifle.range = { --validated, unchanged. Will need to see values used by crimespree zeal heavy snipers for assault snipers.
		optimal = 15000,
		far = 15000,
		close = 15000
	}
	presets.weapon.deathvox_sniper.is_rifle.autofire_rounds = presets.weapon.normal.is_rifle.autofire_rounds
	presets.weapon.deathvox_sniper.is_rifle.use_laser = true -- where the laser change goes.
	presets.weapon.deathvox_sniper.is_rifle.FALLOFF = { -- note values do not match frank's table. Largely eyeballed, may need revision.
		{
			dmg_mul = 1,
			r = 700,
			acc = {
				0.4,
				0.95
			},
			recoil = { --
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
	
	presets.weapon.deathvox.mac11 = deep_clone(presets.weapon.deathvox.is_pistol)
	presets.weapon.deathvox.mp9 = deep_clone(presets.weapon.deathvox.is_pistol)
	presets.weapon.deathvox.rifle = deep_clone(presets.weapon.deathvox.is_light_rifle)
	presets.weapon.deathvox.is_rifle = deep_clone(presets.weapon.deathvox.is_heavy_rifle)
	presets.weapon.deathvox.is_sniper = deep_clone(presets.weapon.deathvox.is_light_rifle)
	presets.weapon.deathvox.akimbo_pistol = deep_clone(presets.weapon.deathvox.is_pistol)
	presets.weapon.deathvox.mossberg = deep_clone(presets.weapon.deathvox.is_light_shotgun)
end
	
function CharacterTweakData:_init_deathvox(presets)
	self.deathvox_guard = deep_clone(self.security)
	self.deathvox_guard.detection = presets.detection.guard -- normal, guard, sniper, gang_member, civilian, blind
	self.deathvox_guard.suppression = nil -- presets.suppression.no_supress
	self.deathvox_guard.surrender = nil
	self.deathvox_guard.move_speed = presets.move_speed.very_fast -- tentative.
	self.deathvox_guard.ecm_vulnerability = 0 -- DV guards ignore feedback. Removing safety net in stealth.
	
	self.deathvox_guard.dodge = presets.dodge.deathvox_guard
	self.deathvox_guard.deathguard = true -- unlikely to be relevant usually, but adds slight safety window during pathing step.
	self.deathvox_guard.no_arrest = true -- removing the arrest loophole.
	self.deathvox_guard.factory_weapon_id = {"wpn_deathvox_guard_pistol"}
	self.deathvox_guard.use_factory = true
	self.deathvox_guard.weapon = deep_clone(presets.weapon.deathvox)
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
	table.insert(self._enemy_list, "deathvox_lightar")
	
	self.deathvox_heavyar = deep_clone(self.city_swat)
	self.deathvox_heavyar.detection = presets.detection.normal
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
	table.insert(self._enemy_list, "deathvox_lightshot")
	
	self.deathvox_heavyshot = deep_clone(self.city_swat)
	self.deathvox_heavyshot.detection = presets.detection.normal
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
	table.insert(self._enemy_list, "deathvox_heavyshot")
	
	self.deathvox_shield = deep_clone(self.shield)
	self.deathvox_shield.tags = {"shield"} -- just to be sure it's being applied.
	self.deathvox_shield.detection = presets.detection.normal
	self.deathvox_shield.suppression = presets.suppression.no_supress --I think this is in resto, if not it now is.
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
	
	table.insert(self._enemy_list, "deathvox_shield")
	
	self.deathvox_medic = deep_clone(self.medic)
	self.deathvox_medic.tags = {"medic"} --just making sure tag applies.
	self.deathvox_medic.detection = presets.detection.normal
	self.deathvox_medic.suppression = presets.suppression.no_supress -- tentative, in base.
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
	self.deathvox_medic.weapon = deep_clone(presets.weapon.deathvox) -- normal, good, expert, deathwish, gang_member, sniper, sniper_good/expert/deathwish
	self.deathvox_medic.use_factory = true -- Use a factory weapon
	self.deathvox_medic.dv_medic_heal = true -- dont touch, makes him use the death vox healing
	self.deathvox_medic.factory_weapon_id = {"wpn_deathvox_medic_pistol"}
	table.insert(self._enemy_list, "deathvox_medic") 

	self.deathvox_taser = deep_clone(self.taser)
	self.deathvox_taser.tags = {"taser"} -- just making sure tag applies.
	self.deathvox_taser.detection = presets.detection.normal
	self.deathvox_taser.suppression = nil
	self.deathvox_taser.surrender = presets.surrender.special 
	self.deathvox_taser.move_speed = presets.move_speed.fast --tentative, in base.
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

	table.insert(self._enemy_list, "deathvox_taser") 

	self.deathvox_cloaker = deep_clone(self.spooc)
	self.deathvox_cloaker.tags = {"spooc"} -- just making sure tag applies.
	self.deathvox_cloaker.detection = presets.detection.normal
	self.deathvox_cloaker.suppression = nil
	self.deathvox_cloaker.surrender = presets.surrender.special 
	self.deathvox_cloaker.move_speed = presets.move_speed.lightning
	self.deathvox_cloaker.surrender_break_time = {4, 6} 
	self.deathvox_cloaker.ecm_vulnerability = 0
	self.deathvox_cloaker.dodge = presets.dodge.ninja
	self.deathvox_cloaker.deathguard = true 
	self.deathvox_cloaker.no_arrest = true
	self.deathvox_cloaker.steal_loot = nil
	self.deathvox_cloaker.rescue_hostages = false

	table.insert(self._enemy_list, "deathvox_spooc") 

	self.deathvox_sniper = deep_clone(self.sniper)
	self.deathvox_sniper.tags = {"sniper"} -- just making sure tag applies.
	self.deathvox_sniper.detection = presets.detection.normal
	self.deathvox_sniper.suppression = presets.suppression.no_supress -- this actually makes snipers way less annoying!
	self.deathvox_sniper.surrender = presets.surrender.special 
	self.deathvox_sniper.move_speed = presets.move_speed.normal
	self.deathvox_sniper.surrender_break_time = {4, 6} 
	self.deathvox_sniper.ecm_vulnerability = 0
	self.deathvox_sniper.no_arrest = true
	self.deathvox_sniper.steal_loot = nil
	self.deathvox_sniper.rescue_hostages = false

	self.deathvox_sniper.use_factory = true -- Use a factory weapon
	self.deathvox_sniper.factory_weapon_id = {"wpn_deathvox_sniper"}

	self.deathvox_sniper_assault = deep_clone(self.deathvox_sniper)
	self.deathvox_sniper_assault.move_speed = presets.move_speed.very_fast
	self.deathvox_sniper_assault.deathguard = true --tentative. This was apparently a big problem in RAID, but that unit may be implemented differently.

	table.insert(self._enemy_list, "deathvox_sniperassault")

    self.deathvox_tank = deep_clone(self.tank)
    self.deathvox_tank.tags = {"tank"} -- just making sure tag applies.
    self.deathvox_tank.detection = presets.detection.normal
    self.deathvox_tank.suppression = presets.suppression.no_supress
    self.deathvox_tank.surrender = nil
    self.deathvox_tank.surrender_break_time = {4, 6}
    self.deathvox_tank.ecm_vulnerability = 0.85
    self.deathvox_taser.ecm_hurts = {
        ears = {min_duration = 1, max_duration = 3} -- tentative, in base
    }
    self.deathvox_tank.deathguard = true
    self.deathvox_tank.no_arrest = true
    self.deathvox_tank.steal_loot = nil
    self.deathvox_tank.rescue_hostages = false

    self.deathvox_greendozer = deep_clone(self.deathvox_tank) -- pro OOP strats
	table.insert(self._enemy_list, "deathvox_greendozer")

    self.deathvox_blackdozer = deep_clone(self.deathvox_tank)
	table.insert(self._enemy_list, "deathvox_blackdozer")

    self.deathvox_lmgdozer = deep_clone(self.deathvox_tank)
	table.insert(self._enemy_list, "deathvox_lmgdozer")
	
    self.deathvox_medicdozer = deep_clone(self.deathvox_tank)
	self.deathvox_medicdozer.use_factory = true -- Use a factory weapon
	self.deathvox_medicdozer.factory_weapon_id = {"wpn_deathvox_medicdozer_smg"} 
	self.deathvox_medicdozer.dv_medic_heal = true -- dont touch, makes him use the death vox healing
	table.insert(self._enemy_list, "deathvox_medicdozer")

	self.deathvox_grenadier = deep_clone(presets.base)
	self.deathvox_grenadier.tags = {"custom"}
	self.deathvox_grenadier.experience = {}
	self.deathvox_grenadier.weapon = deep_clone(presets.weapon.normal)
	self.deathvox_grenadier.melee_weapon = "knife_1"
	self.deathvox_grenadier.melee_weapon_dmg_multiplier = 1
	self.deathvox_grenadier.weapon_safety_range = 1000
	self.deathvox_grenadier.detection = presets.detection.normal
	self.deathvox_grenadier.HEALTH_INIT = 36
	self.deathvox_grenadier.HEALTH_SUICIDE_LIMIT = 0.25
	self.deathvox_grenadier.flammable = true
	self.deathvox_grenadier.use_animation_on_fire_damage = true
	self.deathvox_grenadier.damage.explosion_damage_mul = 0.5
	self.deathvox_grenadier.damage.fire_damage_mul = 1
	self.deathvox_grenadier.damage.hurt_severity = presets.hurt_severities.base
	self.deathvox_grenadier.headshot_dmg_mul = 1.8
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
	self.deathvox_grenadier.speech_prefix_p1 = self._prefix_data_p1.swat()
	self.deathvox_grenadier.speech_prefix_p2 = self._prefix_data_p2.swat()
	self.deathvox_grenadier.speech_prefix_count = 1
	self.deathvox_grenadier.access = "taser"
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
 	table.insert(self._enemy_list, "deathvox_grenadier")
	
end
