local old_unit_cat = GroupAITweakData._init_unit_categories
local old_spawn_group = GroupAITweakData._init_enemy_spawn_groups
local old_task_data = GroupAITweakData._init_task_data

function GroupAITweakData:_init_unit_categories(difficulty_index)
	old_unit_cat(self, difficulty_index)
	local access_type_walk_only = {walk = true}
	local access_type_all = {
		acrobatic = true,
		walk = true
	}
	if difficulty_index == 1 then -- Easy special unit caps. unused.
		self.special_unit_spawn_limits = {
			shield = 0,
			taser = 0,
			medic = 0,
			tank = 0,
			spooc = 0,
			boom = 0,
			ass_sniper = 0
		}
	end
    if difficulty_index == 2 then -- Normal special unit caps.
		self.special_unit_spawn_limits = {
			shield = 3,
			taser = 0,
			medic = 0,
			tank = 0,
			spooc = 0,
			boom = 0,
			ass_sniper = 0
		}
	end
    if difficulty_index == 3 then -- Hard special unit caps.
		self.special_unit_spawn_limits = {
			shield = 3,
			taser = 2,
			medic = 2,
			tank = 0,
			spooc = 0,
			boom = 0,
			ass_sniper = 0
		}
	end
    if difficulty_index == 4 then -- Very Hard special unit caps.
		self.special_unit_spawn_limits = {
			shield = 4,
			taser = 2,
			medic = 2,
			tank = 1,
			spooc = 0,
			boom = 0,
			ass_sniper = 0
		}
	end
    if difficulty_index == 5 then -- OVK special unit caps.
		self.special_unit_spawn_limits = {
			shield = 4,
			taser = 3,
			medic = 3,
			tank = 2,
			spooc = 2,
			boom = 0,
			ass_sniper = 0
		}
	end
    if difficulty_index == 6 then -- Mayhem special unit caps. 
    -- note, focus of this transition is coordinated unit groups.
		self.special_unit_spawn_limits = {
			shield = 4,
			taser = 3,
			medic = 3,
			tank = 2,
			spooc = 3,
			boom = 0,
			ass_sniper = 0
		}
	end
    if difficulty_index == 7 then -- Death Wish special unit caps.
		self.special_unit_spawn_limits = {
			shield = 4,
			taser = 4,
			medic = 4,
			tank = 2,
			spooc = 3,
			boom = 0,
			ass_sniper = 0
		}
	end
    if difficulty_index == 8 then -- Crackdown special unit caps.
		self.special_unit_spawn_limits = {
			shield = 6,
			taser = 4,
			medic = 4,
			tank = 2,
			spooc = 4,
			boom = 2,
			ass_sniper = 0
		}
	end
	for _, category in ipairs(self.unit_categories) do
		category.unit_types["cop"] = category.unit_types["america"]
		category.unit_types["fbi"] = category.unit_types["america"]
		category.unit_types["gensec"] = category.unit_types["america"]
		category.unit_types["zeal"] = category.unit_types["america"]
	end
	self.unit_categories.deathvox_fbi_veteran = {
		unit_types = {
			cop = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_veteran/ene_deathvox_fbi_veteran")
			},
			fbi = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_veteran/ene_deathvox_fbi_veteran")
			},
			gensec = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_veteran/ene_deathvox_fbi_veteran")
			},
			zeal = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_veteran/ene_deathvox_fbi_veteran")
			}		
		},
		unit_type_spawner = {
			cop = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_veteran/ene_deathvox_fbi_veteran",
			fbi = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_veteran/ene_deathvox_fbi_veteran",
			gensec = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_veteran/ene_deathvox_fbi_veteran",
			zeal = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_veteran/ene_deathvox_fbi_veteran"
		},
		access = access_type_all
	}
	self.unit_categories.deathvox_fbi_rookie = {
		unit_types = {
			cop = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_rookie/ene_deathvox_fbi_rookie")
			},
			fbi = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_rookie/ene_deathvox_fbi_rookie")
			},
			gensec = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_rookie/ene_deathvox_fbi_rookie")
			},
			zeal = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_rookie/ene_deathvox_fbi_rookie")
			}		
		},
		unit_type_spawner = {
			cop = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_rookie/ene_deathvox_fbi_rookie",
			fbi = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_rookie/ene_deathvox_fbi_rookie",
			gensec = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_rookie/ene_deathvox_fbi_rookie",
			zeal = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_rookie/ene_deathvox_fbi_rookie"
		},
		access = access_type_all
	}
	self.unit_categories.deathvox_fbi_hrt = {
		unit_types = {
			cop = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_hrt/ene_deathvox_fbi_hrt")
			},
			fbi = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_hrt/ene_deathvox_fbi_hrt")
			},
			gensec = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_hrt/ene_deathvox_fbi_hrt")
			},
			zeal = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_hrt/ene_deathvox_fbi_hrt")
			}		
		},
		unit_type_spawner = {
			cop = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_hrt/ene_deathvox_fbi_hrt",
			fbi = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_hrt/ene_deathvox_fbi_hrt",
			gensec = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_hrt/ene_deathvox_fbi_hrt",
			zeal = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_hrt/ene_deathvox_fbi_hrt"
		},
		access = access_type_all
	}
	self.unit_categories.deathvox_cop_pistol = {
		unit_types = {
			cop = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_pistol/ene_deathvox_cop_pistol")
			},
			fbi = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_pistol/ene_deathvox_cop_pistol")
			},
			gensec = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_pistol/ene_deathvox_cop_pistol")
			},
			zeal = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_pistol/ene_deathvox_cop_pistol")
			}		
		},
		unit_type_spawner = {
			cop = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_pistol/ene_deathvox_cop_pistol",
			fbi = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_pistol/ene_deathvox_cop_pistol",
			gensec = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_pistol/ene_deathvox_cop_pistol",
			zeal = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_pistol/ene_deathvox_cop_pistol"
		},
		access = access_type_all
	}
	self.unit_categories.deathvox_cop_revolver = {
		unit_types = {
			cop = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_revolver/ene_deathvox_cop_revolver")
			},
			fbi = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_revolver/ene_deathvox_cop_revolver")
			},
			gensec = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_revolver/ene_deathvox_cop_revolver")
			},
			zeal = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_revolver/ene_deathvox_cop_revolver")
			}		
		},
		unit_type_spawner = {
			cop = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_revolver/ene_deathvox_cop_revolver",
			fbi = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_revolver/ene_deathvox_cop_revolver",
			gensec = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_revolver/ene_deathvox_cop_revolver",
			zeal = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_revolver/ene_deathvox_cop_revolver"
		},
		access = access_type_all
	}
	self.unit_categories.deathvox_cop_shotgun = {
		unit_types = {
			cop = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_shotgun/ene_deathvox_cop_shotgun")
			},
			fbi = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_shotgun/ene_deathvox_cop_shotgun")
			},
			gensec = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_shotgun/ene_deathvox_cop_shotgun")
			},
			zeal = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_shotgun/ene_deathvox_cop_shotgun")
			}		
		},
		unit_type_spawner = {
			cop = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_shotgun/ene_deathvox_cop_shotgun",
			fbi = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_shotgun/ene_deathvox_cop_shotgun",
			gensec = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_shotgun/ene_deathvox_cop_shotgun",
			zeal = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_shotgun/ene_deathvox_cop_shotgun"
		},
		access = access_type_all
	}
	self.unit_categories.deathvox_cop_smg = {
		unit_types = {
			cop = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_smg/ene_deathvox_cop_smg")
			},
			fbi = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_smg/ene_deathvox_cop_smg")
			},
			gensec = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_smg/ene_deathvox_cop_smg")
			},
			zeal = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_smg/ene_deathvox_cop_smg")
			}		
		},
		unit_type_spawner = {
			cop = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_smg/ene_deathvox_cop_smg",
			fbi = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_smg/ene_deathvox_cop_smg",
			gensec = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_smg/ene_deathvox_cop_smg",
			zeal = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_smg/ene_deathvox_cop_smg"
		},
		access = access_type_all
	}
	self.unit_categories.deathvox_guard = {
		unit_types = {
			cop = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard")
			},
			fbi = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard")
			},
			gensec = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard")
			},
			zeal = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard")
			}		
		},
		unit_type_spawner = {
			cop = "units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard",
			fbi = "units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard",
			gensec = "units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard",
			zeal = "units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard"
		},
		access = access_type_all
	}
	self.unit_categories.deathvox_grenadier = {
		unit_types = {
			cop = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_grenadier/ene_deathvox_grenadier")
			},
			fbi = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_grenadier/ene_deathvox_grenadier")
			},
			gensec = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_grenadier/ene_deathvox_grenadier")
			},
			zeal = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_grenadier/ene_deathvox_grenadier")
			}		
		},
		unit_type_spawner = {
			cop = "units/pd2_mod_gageammo/characters/ene_deathvox_grenadier/ene_deathvox_grenadier",
			fbi = "units/pd2_mod_gageammo/characters/ene_deathvox_grenadier/ene_deathvox_grenadier",
			gensec = "units/pd2_mod_gageammo/characters/ene_deathvox_grenadier/ene_deathvox_grenadier",
			zeal = "units/pd2_mod_gageammo/characters/ene_deathvox_grenadier/ene_deathvox_grenadier"
		},
		access = access_type_all,
		special_type = "boom"
	}
	self.unit_categories.deathvox_lightar = {
		unit_types = {
			cop = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_swat/ene_deathvox_cop_swat")
			},
			fbi = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_swat/ene_deathvox_fbi_swat")
			},
			gensec = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_gensec_swat/ene_deathvox_gensec_swat")
			},
			zeal = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_lightar/ene_deathvox_lightar")
			}
		},
		unit_type_spawner = {
			cop = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_swat/ene_deathvox_cop_swat",
			fbi = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_swat/ene_deathvox_fbi_swat",
			gensec = "units/pd2_mod_gageammo/characters/ene_deathvox_gensec_swat/ene_deathvox_gensec_swat",
			zeal = "units/pd2_mod_gageammo/characters/ene_deathvox_lightar/ene_deathvox_lightar"
		},
		access = access_type_all
	}
	self.unit_categories.deathvox_heavyar = {
		unit_types = {
			cop = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_heavyswat/ene_deathvox_cop_heavyswat")
			},
			fbi = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_heavyswat/ene_deathvox_fbi_heavyswat")
			},
			gensec = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_gensec_heavyswat/ene_deathvox_gensec_heavyswat")
			},
			zeal = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_heavyar/ene_deathvox_heavyar")
			}			
		},
		unit_type_spawner = {
			cop = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_heavyswat/ene_deathvox_cop_heavyswat",
			fbi = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_heavyswat/ene_deathvox_fbi_heavyswat",
			gensec = "units/pd2_mod_gageammo/characters/ene_deathvox_gensec_heavyswat/ene_deathvox_gensec_heavyswat",
			zeal = "units/pd2_mod_gageammo/characters/ene_deathvox_heavyar/ene_deathvox_heavyar"
		},
		access = access_type_all
	}
	self.unit_categories.deathvox_lightshot = {
		unit_types = {
			cop = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_swatshot/ene_deathvox_cop_swatshot")
			},
			fbi = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_swatshot/ene_deathvox_fbi_swatshot")
			},
			gensec = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_gensec_swatshot/ene_deathvox_gensec_swatshot")
			},
			zeal = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_lightshot/ene_deathvox_lightshot")
			}						
		},
		unit_type_spawner = {
			cop = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_swatshot/ene_deathvox_cop_swatshot",
			fbi = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_swatshot/ene_deathvox_fbi_swatshot",
			gensec = "units/pd2_mod_gageammo/characters/ene_deathvox_gensec_swatshot/ene_deathvox_gensec_swatshot",
			zeal = "units/pd2_mod_gageammo/characters/ene_deathvox_lightshot/ene_deathvox_lightshot"
		},
		access = access_type_all
	}
	self.unit_categories.deathvox_heavyshot = {
		unit_types = {
			cop = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_heavyswatshot/ene_deathvox_cop_heavyswatshot")
			},
			fbi = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_heavyswatshot/ene_deathvox_fbi_heavyswatshot")
			},
			gensec = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_gensec_heavyswatshot/ene_deathvox_gensec_heavyswatshot")
			},
			zeal = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_heavyshot/ene_deathvox_heavyshot")
			}					
		},
		unit_type_spawner = {
			cop = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_heavyswatshot/ene_deathvox_cop_heavyswatshot",
			fbi = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_heavyswatshot/ene_deathvox_fbi_heavyswatshot",
			gensec = "units/pd2_mod_gageammo/characters/ene_deathvox_gensec_heavyswatshot/ene_deathvox_gensec_heavyswatshot",
			zeal = "units/pd2_mod_gageammo/characters/ene_deathvox_heavyshot/ene_deathvox_heavyshot"
		},
		access = access_type_all
	}
	self.unit_categories.deathvox_shield = {
		unit_types = {
			cop = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_shield/ene_deathvox_cop_shield")
			},
			fbi = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_shield/ene_deathvox_fbi_shield")
			},
			gensec = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_gensec_shield/ene_deathvox_gensec_shield")
			},
			zeal = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_shield/ene_deathvox_shield")
			}				
		},
		unit_type_spawner = {
			cop = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_shield/ene_deathvox_cop_shield",
			fbi = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_shield/ene_deathvox_fbi_shield",
			gensec = "units/pd2_mod_gageammo/characters/ene_deathvox_gensec_shield/ene_deathvox_gensec_shield",
			zeal = "units/pd2_mod_gageammo/characters/ene_deathvox_shield/ene_deathvox_shield"
		},
		access = access_type_all,
		special_type = "shield"
	}
	self.unit_categories.deathvox_medic = {
		unit_types = {
			cop = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_medic/ene_deathvox_cop_medic")
			},
			fbi = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_medic/ene_deathvox_fbi_medic")
			},
			gensec = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_gensec_medic/ene_deathvox_gensec_medic")
			},
			zeal = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_medic/ene_deathvox_medic")
			}	
		},
		unit_type_spawner = {
			cop = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_medic/ene_deathvox_cop_medic",
			fbi = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_medic/ene_deathvox_fbi_medic",
			gensec = "units/pd2_mod_gageammo/characters/ene_deathvox_gensec_medic/ene_deathvox_gensec_medic",
			zeal = "units/pd2_mod_gageammo/characters/ene_deathvox_medic/ene_deathvox_medic"
		},
		access = access_type_all,
		special_type = "medic"
	}
	self.unit_categories.deathvox_taser = {
		unit_types = {
			cop = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cop_taser/ene_deathvox_cop_taser")
			},
			fbi = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_taser/ene_deathvox_fbi_taser")
			},
			gensec = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_gensec_taser/ene_deathvox_gensec_taser")
			},
			zeal = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_taser/ene_deathvox_taser")
			}				
		},
		unit_type_spawner = {
			cop = "units/pd2_mod_gageammo/characters/ene_deathvox_cop_taser/ene_deathvox_cop_taser",
			fbi = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_taser/ene_deathvox_fbi_taser",
			gensec = "units/pd2_mod_gageammo/characters/ene_deathvox_gensec_taser/ene_deathvox_gensec_taser",
			zeal = "units/pd2_mod_gageammo/characters/ene_deathvox_taser/ene_deathvox_taser"
		},
		access = access_type_all,
		special_type = "taser"
	}
	self.unit_categories.deathvox_greendozer = {
		unit_types = {
			cop = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_greendozer/ene_deathvox_fbi_greendozer")
			},
			fbi = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_greendozer/ene_deathvox_fbi_greendozer")
			},
			gensec = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_greendozer/ene_deathvox_fbi_greendozer")
			},
			zeal = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_greendozer/ene_deathvox_greendozer")
			}		
		},
		unit_type_spawner = {
			cop = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_greendozer/ene_deathvox_fbi_greendozer",
			fbi = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_greendozer/ene_deathvox_fbi_greendozer",
			gensec = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_greendozer/ene_deathvox_fbi_greendozer",
			zeal = "units/pd2_mod_gageammo/characters/ene_deathvox_greendozer/ene_deathvox_greendozer"
		},
		access = access_type_all,
		special_type = "tank"
	}
	self.unit_categories.deathvox_medicdozer = {
		unit_types = {
			cop = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_medicdozer/ene_deathvox_medicdozer")
			},
			fbi = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_medicdozer/ene_deathvox_medicdozer")
			},
			gensec = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_medicdozer/ene_deathvox_medicdozer")
			},
			zeal = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_medicdozer/ene_deathvox_medicdozer")
			}					
		},
		unit_type_spawner = {
			cop = "units/pd2_mod_gageammo/characters/ene_deathvox_medicdozer/ene_deathvox_medicdozer",
			fbi = "units/pd2_mod_gageammo/characters/ene_deathvox_medicdozer/ene_deathvox_medicdozer",
			gensec = "units/pd2_mod_gageammo/characters/ene_deathvox_medicdozer/ene_deathvox_medicdozer",
			zeal = "units/pd2_mod_gageammo/characters/ene_deathvox_medicdozer/ene_deathvox_medicdozer"
		},
		access = access_type_all,
		special_type = "tank"
	}
	self.unit_categories.deathvox_blackdozer = {
		unit_types = {
			cop = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_blackdozer/ene_deathvox_fbi_blackdozer")
			},
			fbi = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_blackdozer/ene_deathvox_fbi_blackdozer")
			},
			gensec = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_blackdozer/ene_deathvox_fbi_blackdozer")
			},
			zeal = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_blackdozer/ene_deathvox_blackdozer")
			}					
		},
		unit_type_spawner = {
			cop = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_blackdozer/ene_deathvox_fbi_blackdozer",
			fbi = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_blackdozer/ene_deathvox_fbi_blackdozer",
			gensec = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_blackdozer/ene_deathvox_fbi_blackdozer",
			zeal = "units/pd2_mod_gageammo/characters/ene_deathvox_blackdozer/ene_deathvox_blackdozer"
		},
		access = access_type_all,
		special_type = "tank"
	}
	self.unit_categories.deathvox_lmgdozer = {
		unit_types = {
			cop = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_gensec_lmgdozer/ene_deathvox_gensec_lmgdozer")
			},
			fbi = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_gensec_lmgdozer/ene_deathvox_gensec_lmgdozer")
			},
			gensec = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_gensec_lmgdozer/ene_deathvox_gensec_lmgdozer")
			},
			zeal = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_lmgdozer/ene_deathvox_lmgdozer")
			}				
		},
		unit_type_spawner = {
			cop = "units/pd2_mod_gageammo/characters/ene_deathvox_gensec_lmgdozer/ene_deathvox_gensec_lmgdozer",
			fbi = "units/pd2_mod_gageammo/characters/ene_deathvox_gensec_lmgdozer/ene_deathvox_gensec_lmgdozer",
			gensec = "units/pd2_mod_gageammo/characters/ene_deathvox_gensec_lmgdozer/ene_deathvox_gensec_lmgdozer",
			zeal = "units/pd2_mod_gageammo/characters/ene_deathvox_lmgdozer/ene_deathvox_lmgdozer"
		},
		access = access_type_all,
		special_type = "tank"
	}
	self.unit_categories.deathvox_cloaker = {
		unit_types = {
			cop = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_cloaker/ene_deathvox_fbi_cloaker")
			},
			fbi = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_fbi_cloaker/ene_deathvox_fbi_cloaker")
			},
			gensec = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_gensec_cloaker/ene_deathvox_gensec_cloaker")
			},
			zeal = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cloaker/ene_deathvox_cloaker")
			}
		},
		unit_type_spawner = {
			cop = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_cloaker/ene_deathvox_fbi_cloaker",
			fbi = "units/pd2_mod_gageammo/characters/ene_deathvox_fbi_cloaker/ene_deathvox_fbi_cloaker",
			gensec = "units/pd2_mod_gageammo/characters/ene_deathvox_gensec_cloaker/ene_deathvox_gensec_cloaker",
			zeal = "units/pd2_mod_gageammo/characters/ene_deathvox_cloaker/ene_deathvox_cloaker"
		},
		access = access_type_all,
		special_type = "spooc"
	}
end

function GroupAITweakData:_init_enemy_spawn_groups(difficulty_index)
	old_spawn_group(self, difficulty_index)
	self._tactics = {
			deathvox_grenad_follow = {
				"shield_cover",
				"ranged_fire",
				"provide_coverfire",
				"provide_support",
				"deathguard",
				"flash_grenade"
				},
			deathvox_grenad_lead = {
				"ranged_fire",
				"provide_coverfire",
				"deathguard"
				},
			deathvox_grenad_pinch = {
				"ranged_fire",
				"flash_grenade",
				"provide_coverfire",
				"provide_support",
				"deathguard",
				},
			deathvox_medic = {
				"shield_cover",
				"charge",
				"provide_coverfire",
				"provide_support"
				},
			deathvox_shield_lead = {
				"shield",
				"charge",
				"provide_coverfire",
				"provide_support"
				},
			deathvox_shield_support = {
				"shield",
				"provide_coverfire",
				"provide_support",
				"charge",
				"deathguard"
				},
			deathvox_spooc_lead = {
				"charge",
				"flash_grenade",
				"provide_coverfire",
				"smoke_grenade",
				"deathguard"
				},
			deathvox_spooc_pinch = {
				"flank",
				"smoke_grenade",
				"charge",
				"provide_coverfire",
				"provide_support",
				"deathguard",
				"flash_grenade"
				},
			deathvox_spooc_shield = {
				"shield_cover",
				"charge",
				"provide_coverfire",
				"provide_support",
				"smoke_grenade",
				"deathguard",
				"flash_grenade"
				},			
			deathvox_simple_charge = {
				"charge",
				"provide_coverfire",
				"provide_support",
				},
			deathvox_swat_charge = {
				"charge",
				"provide_coverfire",
				"provide_support"
				},
			deathvox_swat_flashcharge = {
				"flash_grenade",
				"charge",
				"provide_coverfire",
				"provide_support"
				},
			deathvox_swat_smokecharge = {
				"smoke_grenade",
				"charge",
				"provide_coverfire",
				"provide_support"
				},
			deathvox_swat_shieldcharge = {
				"shield_cover",
				"charge",
				"provide_coverfire",
				"provide_support"
				},
			deathvox_swat_flank = {
				"flank",
				"provide_coverfire",
				"provide_support"
				},
			deathvox_swat_flashflank = {
				"flash_grenade",
				"flank",
				"provide_coverfire",
				"provide_support"
				},
			deathvox_swat_smokeflank = {
				"smoke_grenade",
				"flank",
				"provide_coverfire",
				"provide_support"
				},
			deathvox_swat_shieldflank = {
				"shield_cover",
				"flank",
				"provide_coverfire",
				"provide_support"
				},
			deathvox_swat_ranged = {
				"ranged_fire",
				"provide_coverfire",
				"provide_support",
				},
			deathvox_tank_cover = {
				"shield_cover",
				"provide_coverfire",
				"provide_support",
				"charge",
				"murder",
				"deathguard"
				},
			deathvox_tank_lead = {
				"charge",
				"provide_coverfire",
				"provide_support",
				"murder",
				"deathguard"
				},
			deathvox_tank_pinch = {
				"flank",
				"charge",
				"provide_coverfire",
				"provide_support",
				"deathguard",
				"murder"
				},
			deathvox_tazer_follow = {
				"shield_cover",
				"charge",
				"provide_coverfire",
				"provide_support",
				"flash_grenade",
				"deathguard"
				},
			deathvox_tazer_lead = {
				"flash_grenade",
				"charge",
				"provide_coverfire",
				"provide_support"
				},
			deathvox_sniper = {
				"shield_cover",
				"ranged_fire",
				"provide_coverfire",
				"provide_support",
				"murder",
				"deathguard"
				},
			deathvox_supportflash = {
				"flash_grenade",
				"charge",				
				"provide_coverfire",
				"provide_support"
				},
			deathvox_supportsmoke = {
				"smoke_grenade",
				"flank",
				"provide_coverfire",
				"provide_support"
				},	
			swat_shotgun_rush = { --vanilla tactics begin here.
				"charge",
				"provide_coverfire",
				"provide_support",
				"deathguard",
				"flash_grenade"
				},
			swat_shotgun_flank = {
				"charge",
				"provide_coverfire",
				"provide_support",
				"flank",
				"deathguard"
				},
			swat_rifle = {
				"ranged_fire",
				"provide_coverfire",
				"provide_support"
				},
			swat_rifle_flank = {
				"ranged_fire",
				"provide_coverfire",
				"provide_support",
				"flank"
				},
			shield_wall_ranged = {
				"shield",
				"ranged_fire",
				"provide_support "
				},
			shield_support_ranged = {
				"shield_cover",
				"ranged_fire",
				"provide_coverfire"
				},
			shield_wall_charge = {
				"shield",
				"charge",
				"provide_support"
				},
			shield_support_charge = {
				"shield_cover",
				"charge",
				"provide_coverfire",
				"flash_grenade"
				},
			shield_wall = {
				"shield",
				"ranged_fire",
				"provide_support",
				"murder",
				"deathguard"
				},
			tazer_flanking = {
				"flank",
				"charge",
				"provide_coverfire",
				"smoke_grenade",
				"murder"
				},
			tazer_charge = {
				"charge",
				"provide_coverfire",
				"murder"
				},
			tank_rush = {
				"charge",
				"provide_coverfire",
				"murder"
				},
			spooc = {
				"charge",
				"shield_cover",
				"smoke_grenade"
				}
	}
-- Normal spawngroups
--Introductory difficulty.
--all tactics placeholders.
-- most spawngroups on the lower third have uniform charge or flank behaviors.
-- Ranged fire is more common on lower difficulties- it's functionally low threat.								
	self.enemy_spawn_groups.normal_solopistol = {
		amount = {1, 1},
		spawn = {
			{
				unit = "deathvox_cop_pistol",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_ranged,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.normal_soloshot = {
		amount = {1, 1},
		spawn = {
			{
				unit = "deathvox_cop_shotgun",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.normal_solorevolver = {
		amount = {1, 1},
		spawn = {
			{
				unit = "deathvox_cop_revolver",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.normal_solosmg = {
		amount = {1, 1},
		spawn = {
			{
				unit = "deathvox_cop_smg",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.normal_revolvergroup = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_cop_revolver",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 2
			},
			{
				unit = "deathvox_cop_pistol",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_ranged,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.normal_shotgroup = {
		amount = {2, 2},
		spawn = {
			{
				unit = "deathvox_cop_shotgun",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 2
			},
			{
				unit = "deathvox_cop_pistol",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.normal_smggroup = {
		amount = {2, 2},
		spawn = {
			{
				unit = "deathvox_cop_smg",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 2
			},
			{
				unit = "deathvox_cop_pistol",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.normal_copcombo = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_cop_smg",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 3
			},
			{
				unit = "deathvox_cop_shotgun",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 2
			},
			{
				unit = "deathvox_cop_revolver",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.normal_ARswat = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 3,
				amount_max = 3,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.normal_swatcombo = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 2
			},		
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.normal_shieldbasicpistol = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_shield_lead,
				rank = 2
			},
			{
				unit = "deathvox_cop_pistol",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.normal_shieldbasic = {
		amount = {2, 2},
		spawn = {
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_shield_lead,
				rank = 2
			},
			{
				unit = "deathvox_cop_shotgun",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}
-- Normal recon groups. also calls single bronco, single smg.
	self.enemy_spawn_groups.normal_rookiepair = {
		amount = {2, 2},
		spawn = {
			{
				unit = "deathvox_fbi_rookie",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.normal_rookie = {
		amount = {1, 1},
		spawn = {
			{
				unit = "deathvox_fbi_rookie",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}
-- Hard spawngroups
-- Beat cops, SWATs, some Heavy Swat.
-- Introduces enemy priority and encourages group play.
-- Shield, Taser, Medic.
-- Very limited tactics. mostly rush, some flank, limited nade use.

--Hard recon groups
	self.enemy_spawn_groups.hard_smggroup = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_cop_smg",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 2
			},
			{
				unit = "deathvox_cop_pistol",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.hard_copcombo = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_cop_shotgun",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 2
			},
			{
				unit = "deathvox_cop_smg",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.hard_medicgroup = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 2
			},
			{
				unit = "deathvox_cop_pistol",
				freq = 1,
				amount_min = 3,
				amount_max = 3,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.hard_revolvermedic = {
		amount = {2, 2},
		spawn = {
			{
				unit = "deathvox_cop_revolver",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 2
			}
		}
	}							
	self.enemy_spawn_groups.hard_argroupranged = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_ranged,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 3,
				amount_max = 3,
				tactics = self._tactics.deathvox_swat_ranged,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.hard_lightgroup = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 3,
				amount_max = 3,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.hard_flankswat = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 2
			},	
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 3,
				amount_max = 3,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.hard_mixgroup = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 3,
				amount_max = 3,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.hard_shieldlight = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_shield_lead,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.hard_shieldsmg = {
		amount = {2, 2},
		spawn = {
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_shield_lead,
				rank = 2
			},
			{
				unit = "deathvox_cop_smg",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.hard_shieldheavy = {
		amount = {2, 2},
		spawn = {
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_shield_lead,
				rank = 2
			},
			{
				unit = "deathvox_heavyar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.hard_taser = {
		amount = {1, 1},
		spawn = {
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_flashcharge,
				rank = 1
			}
		}
	}
--Hard recon groups.
	self.enemy_spawn_groups.hard_rookiemedic = {
		amount = {2, 2},
		spawn = {
			{
				unit = "deathvox_fbi_rookie",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.hard_rookiecombo = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_fbi_rookie",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 3
			},
			{
				unit = "deathvox_cop_shotgun",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},
			{
				unit = "deathvox_cop_smg",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}			
	self.enemy_spawn_groups.hard_rookieshotgun = {
		amount = {2, 2},
		spawn = {
			{
				unit = "deathvox_fbi_rookie",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 2
			},
			{
				unit = "deathvox_cop_shotgun",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			},
		}
	}
-- Very Hard spawngroups
-- Green, Tan, comprehensive.
-- generally complete enemy set introducing types and core play.
-- Shields, Tasers, Bulldozer (Green), Medics.
								
-- 4 light AR. ranged.
	self.enemy_spawn_groups.vhard_lightARranged = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 4,
				amount_max = 4,
				tactics = self._tactics.deathvox_swat_ranged,
				rank = 1
			}
		}
	}
-- 4 light AR. charge.
	self.enemy_spawn_groups.vhard_lightARcharge = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 4,
				amount_max = 4,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}	
-- 3 light AR, medic. charge.
	self.enemy_spawn_groups.vhard_lightARchargeMed = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 3,
				amount_max = 3,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},			
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 3,
				amount_max = 3,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}
-- 3 light AR, medic. flank.
	self.enemy_spawn_groups.vhard_lightARflankMed = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 3,
				amount_max = 3,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 2
			},			
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 3,
				amount_max = 3,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}
-- 2 light shot 2 light AR. charge.
	self.enemy_spawn_groups.vhard_lightmixcharge = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},			
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}	
-- 2 light shot 1 AR light, medic. charge.
	self.enemy_spawn_groups.vhard_lightmixchargeMed = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 3
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			},
		}
	}
-- 2 light shot 1 AR light, medic. flank.
	self.enemy_spawn_groups.vhard_lightmixflankMed = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 3
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 1
			},
		}
	}
-- 2 heavy ar 2 light AR. charge.
	self.enemy_spawn_groups.vhard_mixARcharge = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},			
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}									
-- 2 heavy shot 2 light AR. charge.
	self.enemy_spawn_groups.vhard_mixbothcharge = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},			
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}
-- 2 heavy shot 2 heavy AR. charge.
	self.enemy_spawn_groups.vhard_mixheavybothcharge = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},			
			{
				unit = "deathvox_heavyar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}
-- 1 Taser 2 Heavy AR.
	self.enemy_spawn_groups.vhard_taserARgroup = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tazer_lead,
				rank = 2
			},			
			{
				unit = "deathvox_heavyar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_charge,
				rank = 1
			}
		}
	}
-- 1 Taser 2 Heavy shot.
	self.enemy_spawn_groups.vhard_tasershotgroup = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tazer_lead,
				rank = 2
			},			
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_charge,
				rank = 1
			}
		}
	}
-- 1 Shield, 3 light AR.
	self.enemy_spawn_groups.vhard_shieldlightgroup = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_shield_lead,
				rank = 2
			},			
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 3,
				amount_max = 3,
				tactics = self._tactics.deathvox_charge,
				rank = 1
			}
		}
	}
-- 2 Shield, 2 Heavy AR.
	self.enemy_spawn_groups.vhard_shieldheavyARgroup = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_shield_lead,
				rank = 2
			},			
			{
				unit = "deathvox_heavyar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_charge,
				rank = 1
			}
		}
	}
-- 2 Shield, 2 Heavy shot.
	self.enemy_spawn_groups.vhard_shieldheavyshotgroup = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_shield_lead,
				rank = 2
			},			
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_charge,
				rank = 1
			}
		}
	}
--Bulldozer solo.	
	self.enemy_spawn_groups.vhard_bullsolo = {
		amount = {1, 1},
		spawn = {
			{
				unit = "deathvox_greendozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tank_rush,
				rank = 1
			}
		}
	}							
-- Very Hard recon roups						
-- SWAT, HRT, Medic, Taser
	
-- 2 HRT, Medic
	self.enemy_spawn_groups.vhard_hrtmedic = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_fbi_hrt",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_supportsmoke,
				rank = 2
			},			
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}
-- Taser, 2 HRT
	self.enemy_spawn_groups.vhard_hrttaser = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_supportflash,
				rank = 2
			},			
			{
				unit = "deathvox_fbi_hrt",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}
-- Overkill spawngroups
-- Green, Tan, full conventional groups.
-- Mixed special groups begin on this difficulty, but they are not designed for strong challenge.
-- Limited case dependence, standout behaviors. 
-- Lock to 4 units for all but dozers and cloakers. only one ranged all light, all others mixed light/heavy.
-- Shields, Tasers, Bulldozers (R870, SAIGA), Cloakers, Medics
--4 light ranged AR
	self.enemy_spawn_groups.ovk_mixARcharge = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_ranged,
				rank = 1
			}
		}
	}	
--2 heavy AR 2 light AR charge
	self.enemy_spawn_groups.ovk_mixheavyARcharge = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}								
--2 heavy AR 1 light AR 1 medic charge
	self.enemy_spawn_groups.ovk_comboARcharge = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 3
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_medic,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}	
--2 heavy shot 2 light AR charge
	self.enemy_spawn_groups.ovk_mixcombocharge = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}
--2 heavy shot 1 light AR 1 medic charge
	self.enemy_spawn_groups.ovk_mixcombomediccharge = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 3
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_medic,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}
--2 heavy shot 2 light shot charge
	self.enemy_spawn_groups.ovk_mixshotcharge = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}								
--2 heavy shot 1 light shot 1 medic flank
	self.enemy_spawn_groups.ovk_shotcombomedicflank = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 3
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_medic,
				rank = 2
			},
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 1
			}
		}
	}
--2 heavy ar 1 light ar 1 medic flank
	self.enemy_spawn_groups.ovk_arcombomedicflank = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 3
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_medic,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 1
			}
		}
	}
--2 heavy shot 2 heavy AR charge
	self.enemy_spawn_groups.ovk_heavycombocharge = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},
			{
				unit = "deathvox_heavyar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}
--2 light shot 2 light AR flank
	self.enemy_spawn_groups.ovk_lightcomboflank = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 2
			},
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 1
			}
		}
	}
-- 2 shield, 1 light shot 1 Medic
	self.enemy_spawn_groups.ovk_shieldcombo = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_shield_lead,
				rank = 3
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 2
			},
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_shieldcharge,
				rank = 1
			}
		}
	}
-- 2 shield, 2 light shot
	self.enemy_spawn_groups.ovk_shieldshot = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_shield_lead,
				rank = 2
			},
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}							
-- 2 tasers, 2 light AR
	self.enemy_spawn_groups.ovk_tazerAR = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_tazer_lead,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}
-- 2 tasers, 2 light shot 
	self.enemy_spawn_groups.ovk_tazershot = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_tazer_lead,
				rank = 2
			},
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}
-- 1 taser, 1 Medic
	self.enemy_spawn_groups.ovk_tazermedic = {
		amount = {2, 2},
		spawn = {
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tazer_lead,
				rank = 1
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}								
-- Bulldozer solo (green)
	self.enemy_spawn_groups.ovk_greendozer = {
		amount = {1, 1},
		spawn = {
			{
				unit = "deathvox_greendozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tank_rush,
				rank = 1
			}
		}
	}
-- Bulldozer solo (black)
	self.enemy_spawn_groups.ovk_blackdozer = {
		amount = {1, 1},
		spawn = {
			{
				unit = "deathvox_blackdozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tank_rush,
				rank = 1
			}
		}
	}
-- 1 Shield 1 Bulldozer (green)
	self.enemy_spawn_groups.ovk_greenknight = {
		amount = {2, 2},
		spawn = {
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_shield_lead,
				rank = 2
			},
			{
				unit = "deathvox_greendozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tank_cover,
				rank = 1
			}
		}
	}
-- 1 Shield 1 Bulldozer (black)
	self.enemy_spawn_groups.ovk_blackknight = {
		amount = {2, 2},
		spawn = {
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_shield_lead,
				rank = 2
			},
			{
				unit = "deathvox_blackdozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tank_cover,
				rank = 1
			}
		}
	}
-- 2 cloakers.
	self.enemy_spawn_groups.ovk_spoocpair = {
		amount = {2, 2},
		spawn = {
			{
				unit = "deathvox_cloaker",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_spooc_lead,
				rank = 2
			},
			{
				unit = "deathvox_cloaker",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_spooc_pinch,
				rank = 1
			}
		}
	}			
-- Overkill recon groups
-- HRT, Veteran, Medic, Cloaker, Taser

-- 2 Veteran, 1 medic
	self.enemy_spawn_groups.ovk_vetmed = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_fbi_veteran",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 2
			},			
			{
				unit = "deathvox_fbi_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}
-- 2 HRT, 1 Veteran
	self.enemy_spawn_groups.ovk_hrtvetmix = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_fbi_hrt",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_supportsmoke,
				rank = 2
			},			
			{
				unit = "deathvox_fbi_veteran",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 1
			}
		}
	}
-- repeat cloakerpair
-- Taser, 2 HRT
	self.enemy_spawn_groups.ovk_hrttaser = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_supportflash,
				rank = 2
			},			
			{
				unit = "deathvox_fbi_hrt",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}

-- Mayhem spawngroups
-- Elites.
	self.enemy_spawn_groups.mh_group_1 = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyar",
				freq = 1,
				amount_min = 4,
				amount_max = 4,
				tactics = self._tactics.deathvox_swat_ranged,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.mh_group_2_std = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.mh_group_2_med = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 3
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.mh_group_3_std = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.mh_group_3_med = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 3
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.mh_group_4_std = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 3
			},
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.mh_group_4_med = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 3
			},
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.mh_group_5_std = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.mh_group_5_med = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 3
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}
-- Begin Mayhem coordinated mixed special groups. Introduction of elites does most of work.
-- Shields, Tasers, Bulldozers (R870, SAIGA), Cloakers, Medics
-- LMG Dozer solo
	self.enemy_spawn_groups.mh_whitedozer = {
		amount = {1, 1},
		spawn = {
			{
				unit = "deathvox_lmgdozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tank_lead,
				rank = 1
			}
		}
	}
-- shield, black dozer, medic
	self.enemy_spawn_groups.mh_blackpaladin = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_shield_lead,
				rank = 3
			},
			{
				unit = "deathvox_blackdozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tank_cover,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}
-- shield, green dozer, medic
	self.enemy_spawn_groups.mh_greenpaladin = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_shield_lead,
				rank = 3
			},
			{
				unit = "deathvox_greendozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tank_cover,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}
-- taser, cloaker
	self.enemy_spawn_groups.mh_takedown = {
		amount = {2, 2},
		spawn = {
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tazer_lead,
				rank = 2
			},
			{
				unit = "deathvox_cloaker",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_spooc_pinch,
				rank = 1
			}
		}
	}
-- shield pair, medic
	self.enemy_spawn_groups.mh_castle = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_shield_lead,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}
-- taser duo. note simple tactic.
	self.enemy_spawn_groups.mh_taserpair = {
		amount = {2, 2},
		spawn = {
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_tazer_lead,
				rank = 1
			}
		}
	}
-- 2 cloakers.
	self.enemy_spawn_groups.mh_spoocpair = {
		amount = {2, 2},
		spawn = {
			{
				unit = "deathvox_cloaker",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_spooc_lead,
				rank = 2
			},
			{
				unit = "deathvox_cloaker",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_spooc_pinch,
				rank = 1
			}
		}
	}
--Dozer duo.
	self.enemy_spawn_groups.mh_partners = {
		amount = {2, 2},
		spawn = {
			{
				unit = "deathvox_greendozer",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_tank_lead,
				rank = 3
			},
			{
				unit = "deathvox_blackdozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox__tank_lead,
				rank = 1
			}
		}
	}
-- Mayhem recon groups
-- Veteran, HRT, Medic, Cloaker, Taser
-- 2 Veteran, 2 medic
	self.enemy_spawn_groups.mh_vetmed = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_fbi_veteran",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 2
			},			
			{
				unit = "deathvox_fbi_medic",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}
-- 2 HRT, 1 Veteran
	self.enemy_spawn_groups.mh_hrtvetmix = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_fbi_hrt",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_supportsmoke,
				rank = 2
			},			
			{
				unit = "deathvox_fbi_veteran",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 1
			}
		}
	}
-- repeat mh cloakerpair
-- Taser, 2 HRT
	self.enemy_spawn_groups.mh_hrttaser = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_supportflash,
				rank = 2
			},			
			{
				unit = "deathvox_fbi_hrt",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}
-- Death Wish spawngroups
-- Elites.
-- begin DW Elites.
	self.enemy_spawn_groups.dw_group_1 = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyar",
				freq = 1,
				amount_min = 4,
				amount_max = 4,
				tactics = self._tactics.deathvox_swat_ranged,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.dw_group_2_std = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.dw_group_2_med = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 3
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.dw_group_3_std = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.dw_group_3_med = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 3
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.dw_group_4_std = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 3
			},
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.dw_group_4_med = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 3
			},
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.dw_group_5_std = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.dw_group_5_med = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 3
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}
-- Begin DW coordinated mixed special groups. Note full coordination, no basic swat.
-- Shields, Tasers, Bulldozers (R870, SAIGA, LMG), Cloakers, Medics.
-- Shield, LMG Dozer, medic
	self.enemy_spawn_groups.dw_skullpaladin = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_shield_lead,
				rank = 3
			},
			{
				unit = "deathvox_lmgdozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tank_cover,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}	
	}							
-- Blackdozer, Taser
	self.enemy_spawn_groups.dw_blackball = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_blackdozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tank_lead,
				rank = 2
			},
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_tazer_follow,
				rank = 1
			}
		}
	}
-- Greendozer, medic, cloaker
	self.enemy_spawn_groups.dw_greeneye = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_blackdozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tank_lead,
				rank = 3
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 2
			},
			{
				unit = "deathvox_cloaker",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_spooc_pinch,
				rank = 1
			}
		}
	}																
-- 2 Tasers, cloaker. Note more complex tactic set
	self.enemy_spawn_groups.dw_takedowner = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tazer_lead,
				rank = 3
			},
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tazer_follow,
				rank = 2
			},
			{
				unit = "deathvox_cloaker",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_spooc_pinch,
				rank = 1
			}
		}
	}
-- Cloaker pair. Note NOT used in recon, use trio instead.
	self.enemy_spawn_groups.dw_spoocpair = {
		amount = {2, 2},
		spawn = {
			{
				unit = "deathvox_cloaker",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_spooc_lead,
				rank = 2
			},
			{
				unit = "deathvox_cloaker",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_spooc_pinch,
				rank = 1
			}
		}
	}
-- 2 Shields, taser, medic
	self.enemy_spawn_groups.dw_citadel = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_shield_lead,
				rank = 3
			},
			{
				unit = "deathvox_tazer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tazer_follow,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.dw_vetmed = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_fbi_veteran",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 2
			},			
			{
				unit = "deathvox_fbi_medic",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}
-- 2 HRT, 1 Veteran
	self.enemy_spawn_groups.dw_hrtvetmix = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_fbi_hrt",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_supportsmoke,
				rank = 2
			},			
			{
				unit = "deathvox_fbi_veteran",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 1
			}
		}
	}
-- Triple cloaker, oh my
	self.enemy_spawn_groups.dw_spooctrio = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_cloaker",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_spooc_lead,
				rank = 2
			},			
			{
				unit = "deathvox_cloaker",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_spooc_pinch,
				rank = 1
			}
		}
	}
-- 2 Taser, 2 HRT
	self.enemy_spawn_groups.dw_hrttaser = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_supportflash,
				rank = 2
			},			
			{
				unit = "deathvox_fbi_hrt",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_simple_charge,
				rank = 1
			}
		}
	}
-- Crackdown spawngroups
-- Begin CD Standard Spawngroups.
	self.enemy_spawn_groups.cd_group_1 = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyar",
				freq = 1,
				amount_min = 4,
				amount_max = 4,
				tactics = self._tactics.deathvox_swat_ranged,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.cd_group_2_std = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.cd_group_2_med = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 3
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.cd_group_3_std = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.dv_group_3_med = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 3
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.cd_group_4_std = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 3
			},
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.cd_group_4_med = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 3
			},
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.cd_group_5_std = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.cd_group_5_med = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_heavyar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 3
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}
-- Begin CD special groups. Note full coordination, no basic swat.

	self.enemy_spawn_groups.gorgon = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tazer_lead,
				rank = 3
			},
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tazer_follow,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.atlas = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_shield_lead,
				rank = 3
			},
			{
				unit = "deathvox_lmgdozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tank_cover,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.chimera = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tazer_lead,
				rank = 4
			},
			{
				unit = "deathvox_blackdozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tank_lead,
				rank = 3
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 2
			},
			{
				unit = "deathvox_cloaker",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_spooc_pinch,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.zeus = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_greendozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tank_lead,
				rank = 3
			},
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_tazer_follow,
				rank = 2
			},
			{
				unit = "deathvox_grenadier",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_grenad_follow,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.janus = {
		amount = {2, 2},
		spawn = {
			{
				unit = "deathvox_blackdozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tank_lead,
				rank = 2
			},
			{
				unit = "deathvox_medicdozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.epeius = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 3,
				amount_max = 3,
				tactics = self._tactics.deathvox_shield_lead,
				rank = 2
			},
			{
				unit = "deathvox_lmgdozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tank_cover,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.damocles = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_cloaker",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_spooc_lead,
				rank = 2
			},
			{
				unit = "deathvox_cloaker",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_spooc_pinch,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.caduceus = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_greendozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_tank_lead,
				rank = 3
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_medic,
				rank = 2
			},
			{
				unit = "deathvox_medicdozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.atropos = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_grenadier",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_grenad_lead,
				rank = 3
			},
			{
				unit = "deathvox_cloaker",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_spooc_pinch,
				rank = 2
			},
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_tazer_follow,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.aegeas = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_shield_lead,
				rank = 2
			},				
			{
				unit = "deathvox_grenadier",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_grenad_follow,
				rank = 1
			}
		}
	}

-- Begin Crackdown Recon Groups.

	self.enemy_spawn_groups.recovery_unit = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_fbi_hrt",
				freq = 1,
				amount_min = 3,
				amount_max = 3,
				tactics = self._tactics.deathvox_supportsmoke,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_medic,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.too_group = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_fbi_veteran",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_supportflash,
				rank = 2
			},
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_tazer_follow,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.styx = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_cloaker",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_spooc_lead,
				rank = 1
			},
			{
				unit = "deathvox_cloaker",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_spooc_pinch,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.hoplon = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_shield_lead,
				rank = 2
			},
			{
				unit = "deathvox_grenadier",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_grenad_follow,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.recon = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_fbi_veteran",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_ranged,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 3,
				amount_max = 3,
				tactics = self._tactics.deathvox_swat_ranged,
				rank = 1
			}
		}
	}
end
DIFF_NORMAL = 2
DIFF_HARD = 3
DIFF_VERY_HARD = 4
DIFF_OVERKILL = 5
DIFF_MAYHEM = 6
DIFF_DEATHWISH = 7
DIFF_CRACKDOWN = 8
function GroupAITweakData:_init_task_data(difficulty_index, difficulty)
	old_task_data(self, difficulty_index, difficulty)
	self.besiege.assault.force_balance_mul = {1,1,1,1}
	self.besiege.assault.force_pool_balance_mul = {1,1,1,1}
	self.besiege.recon.force_balance_mul = {1,1,1,1}
	if difficulty_index == DIFF_NORMAL then
		self.besiege.recon.force = {10,10,10}
		self.besiege.recon.interval = {30,30,30}
		self.besiege.assault.force = {20,20,20}
		self.besiege.assault.force_pool = {100,100,100}
		self.besiege.regroup.duration = {30,30,30}
		self.besiege.assault.hostage_hesitation_delay = {30,30,30}
		self.besiege.assault.delay = {60,50,40}
		self.besiege.assault.sustain_duration_balance_mul = {1,1,1,1}
		self.besiege.assault.fade_duration = 30
		self.besiege.assault.groups = {
			normal_solopistol = { 1,1,1 },
			normal_soloshot = { 1,1,1 },
			normal_solorevolver = { 1,1,1 },
			normal_solosmg = { 1,1,1 },
			normal_revolvergroup = { 1,1,1 },
			normal_shotgroup = { 1,1,1 },
			normal_smggroup = { 1,1,1 },
			normal_copcombo = { 1,1,1 },
			normal_ARswat = { 1,1,1 },
			normal_swatcombo = { 1,1,1 },
			normal_shieldbasicpistol = { 1,1,1 },
			normal_shieldbasic = { 1,1,1 }
		}
		self.besiege.reenforce.groups = {
			normal_solopistol = { 1,1,1 },
			normal_soloshot = { 1,1,1 },
			normal_solorevolver = { 1,1,1 },
			normal_solosmg = { 1,1,1 },
			normal_revolvergroup = { 1,1,1 },
			normal_shotgroup = { 1,1,1 },
			normal_smggroup = { 1,1,1 },
			normal_copcombo = { 1,1,1 },
			normal_ARswat = { 1,1,1 },
			normal_swatcombo = { 1,1,1 },
			normal_shieldbasicpistol = { 1,1,1 },
			normal_shieldbasic = { 1,1,1 }
		}
		self.besiege.recon.groups = {
			normal_rookiepair = { 1,1,1 },
			normal_rookie = { 1,1,1 }
		}
	end
	if difficulty_index == DIFF_HARD then
		self.besiege.recon.force = {10,10,10}
		self.besiege.recon.interval = {30,30,30}
		self.besiege.assault.force = {25,25,25}
		self.besiege.assault.force_pool = {125,125,125}
		self.besiege.regroup.duration = {30,30,30}
		self.besiege.assault.hostage_hesitation_delay = {30,30,30}
		self.besiege.assault.delay = {50,40,30}
		self.besiege.assault.sustain_duration_balance_mul = {1,1,1,1}
		self.besiege.assault.fade_duration = 30
		self.besiege.assault.groups = {
			hard_smggroup = { 1,1,1 },
			hard_copcombo = { 1,1,1 },
			hard_medicgroup = { 1,1,1 },
			hard_revolvermedic = { 1,1,1 },
			hard_argroupranged = { 1,1,1 },
			hard_lightgroup = { 1,1,1 },
			hard_flankswat = { 1,1,1 },
			hard_mixgroup = { 1,1,1 },
			hard_shieldlight = { 1,1,1 },
			hard_shieldsmg = { 1,1,1 },
			hard_shieldheavy = { 1,1,1 },
			hard_taser = { 1,1,1 }
		}
		self.besiege.reenforce.groups = {
			hard_smggroup = { 1,1,1 },
			hard_copcombo = { 1,1,1 },
			hard_medicgroup = { 1,1,1 },
			hard_revolvermedic = { 1,1,1 },
			hard_argroupranged = { 1,1,1 },
			hard_lightgroup = { 1,1,1 },
			hard_flankswat = { 1,1,1 },
			hard_mixgroup = { 1,1,1 },
			hard_shieldlight = { 1,1,1 },
			hard_shieldsmg = { 1,1,1 },
			hard_shieldheavy = { 1,1,1 },
			hard_taser = { 1,1,1 }
		}
		self.besiege.recon.groups = {
			hard_rookiemedic = { 1,1,1 },
			hard_rookiecombo = { 1,1,1 },
			hard_rookieshotgun = { 1,1,1 }
		}
	end
	if difficulty_index == DIFF_VERY_HARD then
		self.besiege.recon.force = {10,10,10}
		self.besiege.recon.interval = {30,30,30}
		self.besiege.assault.force = {30,30,30}
		self.besiege.assault.force_pool = {150,150,150}
		self.besiege.regroup.duration = {30,30,30}
		self.besiege.assault.hostage_hesitation_delay = {25,25,25}
		self.besiege.assault.delay = {40,30,20}
		self.besiege.assault.sustain_duration_balance_mul = {1,1,1,1}
		self.besiege.assault.fade_duration = 25
		self.besiege.assault.groups = {
			vhard_lightARranged = { 1,1,1 },
			vhard_lightARcharge = { 1,1,1 },
			vhard_lightARchargeMed = { 1,1,1 },
			vhard_lightARflankMed = { 1,1,1 },
			vhard_lightmixcharge = { 1,1,1 },
			vhard_lightmixchargeMed = { 1,1,1 },
			vhard_lightmixflankMed = { 1,1,1 },
			vhard_mixARcharge = { 1,1,1 },
			vhard_mixbothcharge = { 1,1,1 },
			vhard_mixheavybothcharge = { 1,1,1 },
			vhard_taserARgroup = { 1,1,1 },
			vhard_tasershotgroup = { 1,1,1 },
			vhard_shieldlightgroup = { 1,1,1 },
			vhard_shieldheavyARgroup = { 1,1,1 },
			vhard_shieldheavyshotgroup = { 1,1,1 },
			vhard_bullsolo = { 1,1,1 }
		}
		self.besiege.reenforce.groups = {
			vhard_lightARranged = { 1,1,1 },
			vhard_lightARcharge = { 1,1,1 },
			vhard_lightARchargeMed = { 1,1,1 },
			vhard_lightARflankMed = { 1,1,1 },
			vhard_lightmixcharge = { 1,1,1 },
			vhard_lightmixchargeMed = { 1,1,1 },
			vhard_lightmixflankMed = { 1,1,1 },
			vhard_mixARcharge = { 1,1,1 },
			vhard_mixbothcharge = { 1,1,1 },
			vhard_mixheavybothcharge = { 1,1,1 },
			vhard_taserARgroup = { 1,1,1 },
			vhard_tasershotgroup = { 1,1,1 },
			vhard_shieldlightgroup = { 1,1,1 },
			vhard_shieldheavyARgroup = { 1,1,1 },
			vhard_shieldheavyshotgroup = { 1,1,1 },
			vhard_bullsolo = { 1,1,1 }
		}
		self.besiege.recon.groups = {
			vhard_hrtmedic = { 1,1,1 },
			vhard_hrttaser = { 1,1,1 }
		}
	end
	if difficulty_index == DIFF_OVERKILL then
		self.besiege.recon.force = {10,10,10}
		self.besiege.recon.interval = {30,30,30}
		self.besiege.assault.force = {35,35,35}
		self.besiege.assault.force_pool = {175,175,175}
		self.besiege.regroup.duration = {30,30,30}
		self.besiege.assault.hostage_hesitation_delay = {25,25,25}
		self.besiege.assault.delay = {40,30,20}
		self.besiege.assault.sustain_duration_balance_mul = {1,1,1,1}
		self.besiege.assault.fade_duration = 25
		self.besiege.assault.groups = {
			ovk_mixARcharge = { 1,1,1 },
			ovk_mixheavyARcharge = { 1,1,1 },
			ovk_comboARcharge = { 1,1,1 },
			ovk_mixcombocharge = { 1,1,1 },
			ovk_mixcombomediccharge = { 1,1,1 },
			ovk_mixshotcharge = { 1,1,1 },
			ovk_shotcombomedicflank = { 1,1,1 },
			ovk_arcombomedicflank = { 1,1,1 },
			ovk_heavycombocharge = { 1,1,1 },
			ovk_lightcomboflank = { 1,1,1 },
			ovk_shieldcombo = { 1,1,1 },
			ovk_shieldshot = { 1,1,1 },
			ovk_tazerAR = { 1,1,1 },
			ovk_tazershot = { 1,1,1 },
			ovk_tazermedic = { 1,1,1 },
			ovk_greendozer = { 1,1,1 },
			ovk_blackdozer = { 1,1,1 },
			ovk_greenknight = { 1,1,1 },
			ovk_blackknight = { 1,1,1 },
			ovk_spoocpair = { 1,1,1 }
		}
		self.besiege.reenforce.groups = {
			ovk_mixARcharge = { 1,1,1 },
			ovk_mixheavyARcharge = { 1,1,1 },
			ovk_comboARcharge = { 1,1,1 },
			ovk_mixcombocharge = { 1,1,1 },
			ovk_mixcombomediccharge = { 1,1,1 },
			ovk_mixshotcharge = { 1,1,1 },
			ovk_shotcombomedicflank = { 1,1,1 },
			ovk_arcombomedicflank = { 1,1,1 },
			ovk_heavycombocharge = { 1,1,1 },
			ovk_lightcomboflank = { 1,1,1 },
			ovk_shieldcombo = { 1,1,1 },
			ovk_shieldshot = { 1,1,1 },
			ovk_tazerAR = { 1,1,1 },
			ovk_tazershot = { 1,1,1 },
			ovk_tazermedic = { 1,1,1 },
			ovk_greendozer = { 1,1,1 },
			ovk_blackdozer = { 1,1,1 },
			ovk_greenknight = { 1,1,1 },
			ovk_blackknight = { 1,1,1 },
			ovk_spoocpair = { 1,1,1 }
		}
		self.besiege.recon.groups = {
			ovk_vetmed = { 1,1,1 },
			ovk_hrtvetmix = { 1,1,1 },
			ovk_hrttaser = { 1,1,1 }
		}
	end
	if difficulty_index == DIFF_MAYHEM then
		self.besiege.recon.force = {10,10,10}
		self.besiege.recon.interval = {30,30,30}
		self.besiege.assault.force = {40,40,40}
		self.besiege.assault.force_pool = {200,200,200}
		self.besiege.regroup.duration = {30,30,30}
		self.besiege.assault.hostage_hesitation_delay = {20,20,20}
		self.besiege.assault.delay = {30,20,10}
		self.besiege.assault.sustain_duration_balance_mul = {1,1,1,1}
		self.besiege.assault.fade_duration = 20
		self.besiege.assault.groups = {
			mh_group_1 = { 1,1,1 },
			mh_group_2_std = { 1,1,1 },
			mh_group_2_med = { 1,1,1 },
			mh_group_3_std = { 1,1,1 },
			mh_group_3_med = { 1,1,1 },
			mh_group_4_std = { 1,1,1 },
			mh_group_4_med = { 1,1,1 },
			mh_group_5_std = { 1,1,1 },
			mh_group_5_med = { 1,1,1 },
			mh_whitedozer = { 1,1,1 },
			mh_blackpaladin = { 1,1,1 },
			mh_greenpaladin = { 1,1,1 },
			mh_takedown = { 1,1,1 },
			mh_castle = { 1,1,1 },
			mh_taserpair = { 1,1,1 },
			mh_spoocpair = { 1,1,1 },
			mh_partners = { 1,1,1 }
		}
		self.besiege.reenforce.groups = {
			mh_group_1 = { 1,1,1 },
			mh_group_2_std = { 1,1,1 },
			mh_group_2_med = { 1,1,1 },
			mh_group_3_std = { 1,1,1 },
			mh_group_3_med = { 1,1,1 },
			mh_group_4_std = { 1,1,1 },
			mh_group_4_med = { 1,1,1 },
			mh_group_5_std = { 1,1,1 },
			mh_group_5_med = { 1,1,1 },
			mh_whitedozer = { 1,1,1 },
			mh_blackpaladin = { 1,1,1 },
			mh_greenpaladin = { 1,1,1 },
			mh_takedown = { 1,1,1 },
			mh_castle = { 1,1,1 },
			mh_taserpair = { 1,1,1 },
			mh_spoocpair = { 1,1,1 },
			mh_partners = { 1,1,1 }
		}
		self.besiege.recon.groups = {
			mh_vetmed = { 1,1,1 },
			mh_hrtvetmix = { 1,1,1 },
			mh_hrttaser = { 1,1,1 }
		}
	end
	if difficulty_index == DIFF_DEATHWISH then
		self.besiege.recon.force = {10,10,10}
		self.besiege.recon.interval = {30,30,30}
		self.besiege.assault.force = {45,45,45}
		self.besiege.assault.force_pool = {250,250,250}
		self.besiege.regroup.duration = {30,30,30}
		self.besiege.assault.hostage_hesitation_delay = {20,20,20}
		self.besiege.assault.delay = {30,20,10}
		self.besiege.assault.sustain_duration_balance_mul = {1,1,1,1}
		self.besiege.assault.fade_duration = 20
		self.besiege.assault.groups = {
			dw_group_1 = { 1,1,1 },
			dw_group_2_std = { 1,1,1 },
			dw_group_2_med = { 1,1,1 },
			dw_group_3_std = { 1,1,1 },
			dw_group_3_med = { 1,1,1 },
			dw_group_4_std = { 1,1,1 },
			dw_group_4_med = { 1,1,1 },
			dw_group_5_std = { 1,1,1 },
			dw_group_5_med = { 1,1,1 },
			dw_skullpaladin = { 1,1,1 },
			dw_blackball = { 1,1,1 },
			dw_greeneye = { 1,1,1 },
			dw_takedowner = { 1,1,1 },
			dw_spoocpair = { 1,1,1 },
			dw_citadel = { 1,1,1 }
		}
		self.besiege.reenforce.groups = {
			dw_group_1 = { 1,1,1 },
			dw_group_2_std = { 1,1,1 },
			dw_group_2_med = { 1,1,1 },
			dw_group_3_std = { 1,1,1 },
			dw_group_3_med = { 1,1,1 },
			dw_group_4_std = { 1,1,1 },
			dw_group_4_med = { 1,1,1 },
			dw_group_5_std = { 1,1,1 },
			dw_group_5_med = { 1,1,1 },
			dw_skullpaladin = { 1,1,1 },
			dw_blackball = { 1,1,1 },
			dw_greeneye = { 1,1,1 },
			dw_takedowner = { 1,1,1 },
			dw_spoocpair = { 1,1,1 },
			dw_citadel = { 1,1,1 }
		}
		self.besiege.recon.groups = {
			dw_vetmed = { 1,1,1 },
			dw_hrtvetmix = { 1,1,1 },
			dw_spooctrio = { 1,1,1 },
			dw_hrttaser = { 1,1,1 }
		}
	end
	if difficulty_index == DIFF_CRACKDOWN then
		self.besiege.recon.force = {20,20,20}
		self.besiege.recon.interval = {20,20,20}
		self.besiege.assault.force = {50,50,50}
		self.besiege.assault.force_pool = {500,500,500}
		self.besiege.regroup.duration = {30,30,30}
		self.besiege.assault.hostage_hesitation_delay = {30,30,30}
		self.besiege.assault.delay = {30,20,10}
		self.besiege.assault.sustain_duration_balance_mul = {1,1,1,1}
		self.besiege.assault.fade_duration = 15
		self.besiege.assault.groups = {
			gorgon = { 0.075,0.075,0.075  },
			atlas = { 0.05,0.05,0.05  },
			chimera = { 0.05,0.05,0.05  },
			zeus = { 0.05,0.05,0.05  },
			janus = { 0.025,0.025,0.025 },
			epeius = { 0.05,0.05,0.05  },
			damocles = { 0.05,0.05,0.05  },
			caduceus = { 0.05,0.05,0.05  },
			atropos = { 0.05,0.05,0.05 },
			aegeas = { 0.05,0.05,0.05 },
			cd_group_1 = {0.1, 0.1, 0.1},
			cd_group_2_std = { 0.05,0.05,0.05  },
			cd_group_2_med = { 0.05,0.05,0.05  },
			cd_group_3_std = { 0.05,0.05,0.05  },
			cd_group_3_med = { 0.05,0.05,0.05  },
			cd_group_4_std = { 0.05,0.05,0.05  },
			cd_group_4_med = { 0.05,0.05,0.05  },
			cd_group_5_std = { 0.05,0.05,0.05  },
			cd_group_5_med = { 0.05,0.05,0.05  }
		}
		self.besiege.reenforce.groups = {
			cd_group_1 = {0.2, 0.2, 0.2},
			cd_group_2_std = { 0.1,0.1,0.1 },
			cd_group_2_med = { 0.1,0.1,0.1 },
			cd_group_3_std = { 0.1,0.1,0.1 },
			cd_group_3_med = { 0.1,0.1,0.1 },
			cd_group_4_std = { 0.1,0.1,0.1 },
			cd_group_4_med = { 0.1,0.1,0.1 },
			cd_group_5_std = { 0.1,0.1,0.1 },
			cd_group_5_med = { 0.1,0.1,0.1 }
		}
		self.besiege.recon.groups = {
			recovery_unit = { 0.2,0.2,0.2 },
			too_group = { 0.2,0.2,0.2 },
			styx = { 0.2,0.2,0.2 },
			recon = { 0.2,0.2,0.2 },
			hoplon = { 0.2,0.2,0.2 }
		}
	end
end
