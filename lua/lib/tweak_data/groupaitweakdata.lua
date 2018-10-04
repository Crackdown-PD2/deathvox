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
	self.special_unit_spawn_limits = {
		tank = 2,
		taser = 4,
		boom = 2,
		spooc = 4,
		shield = 6,
		medic = 4,
		ass_sniper = 3
	}
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
				"flash_grenade",
				"smoke_grenade"
				},
			deathvox_grenad_lead = {
				"ranged_fire",
				"provide_coverfire",
				"deathguard",
				"flash_grenade",
				"smoke_grenade"
				},
			deathvox_grenad_pinch = {
				"ranged_fire",
				"provide_coverfire",
				"provide_support",
				"deathguard",
				"flash_grenade",
				"smoke_grenade"
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
			deathvox_swat_charge = {
				"charge",
				"provide_coverfire",
				"provide_support",
				"flash_grenade",
				"smoke_grenade"
				},
			deathvox_swat_flank = {
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
				"deathguard"
				},
			deathvox_tazer_lead = {
				"flash_grenade",
				"smoke_grenade",
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
				"charge",
				"flash_grenade",
				"smoke_grenade",
				"provide_coverfire",
				"provide_support"
				},
			deathvox_supportsmoke = {
				"flank",
				"smoke_grenade",
				"flash_grenade",
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
	self.enemy_spawn_groups.normal_first_responders = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_cop_pistol",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_ranged,
				rank = 2
			},
			{
				unit = "deathvox_cop_revolver",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_ranged,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.normal_swat_team = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_cop_smg",
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
	self.enemy_spawn_groups.normal_pushers = {
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
				unit = "deathvox_cop_shotgun",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.normal_sheriff = {
		amount = {3, 3},
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
				unit = "deathvox_cop_revolver",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.normal_recon = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_fbi_rookie",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 2
			},
			{
				unit = "deathvox_cop_pistol",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 1
			}
		}
	}
	-- Hard spawngroups
	self.enemy_spawn_groups.hard_first_responders = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_cop_smg",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 3
			},
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 2
			},
			{
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.hard_swat_team = {
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
				unit = "deathvox_heavyshot",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.hard_pushers = {
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
				unit = "deathvox_lightshot",
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
				tactics = self._tactics.deathvox_swat_charge,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.hard_sheriff = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_cop_revolver",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
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
				unit = "deathvox_heavyar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 1
			}
		}
	}
	self.enemy_spawn_groups.hard_recon = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_cop_shotgun",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 2
			},
			{
				unit = "deathvox_fbi_rookie",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.deathvox_swat_flank,
				rank = 1
			}
		}
	}
	-- Very Hard spawngroups
	-- Overkill spawngroups
	-- Mayhem spawngroups
	-- Death Wish spawngroups
	-- Crackdown spawngroups
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
			},				{
				unit = "deathvox_grenadier",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.deathvox_grenad_follow,
				rank = 1
			}
		}
	}

	-- Death Vox Control Phase

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

	-- Normal DV Spawngroups

	self.enemy_spawn_groups.dv_group_1 = {
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

	self.enemy_spawn_groups.dv_group_2_std = {
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
	self.enemy_spawn_groups.dv_group_2_med = {
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
	self.enemy_spawn_groups.dv_group_3_std = {
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
	self.enemy_spawn_groups.dv_group_4_std = {
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
	self.enemy_spawn_groups.dv_group_4_med = {
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
	self.enemy_spawn_groups.dv_group_5_std = {
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
	self.enemy_spawn_groups.dv_group_5_med = {
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
			normal_first_responders = { 1,1,1 },
			normal_pushers = { 1,1,1 },
			normal_sheriff = { 1,1,1 },
			normal_swat_team = { 1,1,1 },
		}
		self.besiege.reenforce.groups = {
			normal_first_responders = { 1,1,1 },
			normal_pushers = { 1,1,1 },
			normal_sheriff = { 1,1,1 },
			normal_swat_team = { 1,1,1 },
		}
		self.besiege.recon.groups = {
			normal_recon = { 1,1,1 },
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
			hard_first_responders = { 1,1,1 },
			hard_pushers = { 1,1,1 },
			hard_sheriff = { 1,1,1 },
			hard_swat_team = { 1,1,1 }
		}
		self.besiege.reenforce.groups = {
			hard_first_responders = { 1,1,1 },
			hard_pushers = { 1,1,1 },
			hard_sheriff = { 1,1,1 },
			hard_swat_team = { 1,1,1 }
		}
		self.besiege.recon.groups = {
			hard_recon = { 1,1,1 }
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
			gorgon = { 0.05,0.05,0.05  },
			atlas = { 0.05,0.05,0.05  },
			chimera = { 0.05,0.05,0.05  },
			zeus = { 0.05,0.05,0.05  },
			janus = { 0.05,0.05,0.05 },
			epeius = { 0.05,0.05,0.05  },
			damocles = { 0.05,0.05,0.05  },
			caduceus = { 0.05,0.05,0.05  },
			atropos = { 0.05,0.05,0.05 },
			aegeas = { 0.05,0.05,0.05 },
			dv_group_1 = {0.1, 0.1, 0.1},
			dv_group_2_std = { 0.05,0.05,0.05  },
			dv_group_2_med = { 0.05,0.05,0.05  },
			dv_group_3_std = { 0.05,0.05,0.05  },
			dv_group_3_med = { 0.05,0.05,0.05  },
			dv_group_4_std = { 0.05,0.05,0.05  },
			dv_group_4_med = { 0.05,0.05,0.05  },
			dv_group_5_std = { 0.05,0.05,0.05  },
			dv_group_5_med = { 0.05,0.05,0.05  }
		}
		self.besiege.reenforce.groups = {
			dv_group_1 = {0.2, 0.2, 0.2},
			dv_group_2_std = { 0.1,0.1,0.1 },
			dv_group_2_med = { 0.1,0.1,0.1 },
			dv_group_3_std = { 0.1,0.1,0.1 },
			dv_group_3_med = { 0.1,0.1,0.1 },
			dv_group_4_std = { 0.1,0.1,0.1 },
			dv_group_4_med = { 0.1,0.1,0.1 },
			dv_group_5_std = { 0.1,0.1,0.1 },
			dv_group_5_med = { 0.1,0.1,0.1 }
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
