local old_unit_cat = GroupAITweakData._init_unit_categories
local old_spawn_group = GroupAITweakData._init_enemy_spawn_groups
local old_task_data = GroupAITweakData._init_task_data

function GroupAITweakData:_init_unit_categories(difficulty_index)
	old_unit_cat(self, difficulty_index)
	local access_type_walk_only = {walk = true}
	local access_type_all = {walk = true, acrobatic = true}
	if difficulty_index == 8 then
		self.special_unit_spawn_limits = {
			tank = 3,
			taser = 4,
			boom = 2,
			spooc = 4,
			shield = 6,
			medic = 3,
			ass_sniper = 2
		}
	end
	-- Death Vox
	self.unit_categories.deathvox_guard = {
		unit_types = {
			america = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard")
			},
			russia = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard")
			},
			zombie = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard")
			}						
		},
		access = access_type_all
	}
	self.unit_categories.deathvox_grenadier = {
		unit_types = {
			america = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_grenadier/ene_deathvox_grenadier")
			},
			russia = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_grenadier/ene_deathvox_grenadier")
			},
			zombie = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_grenadier/ene_deathvox_grenadier")
			}						
		},
		access = access_type_all,
		special_type = "boom"
	}
	self.unit_categories.deathvox_lightar = {
		unit_types = {
			america = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_lightar/ene_deathvox_lightar")
			},
			russia = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_lightar/ene_deathvox_lightar")
			},
			zombie = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_lightar/ene_deathvox_lightar")
			}						
		},
		access = access_type_all
	}
	self.unit_categories.deathvox_heavyar = {
		unit_types = {
			america = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_heavyar/ene_deathvox_heavyar")
			},				
			russia = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_heavyar/ene_deathvox_heavyar")
			},
			zombie = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_heavyar/ene_deathvox_heavyar")
			}					
		},
		access = access_type_all
	}
	self.unit_categories.deathvox_lightshot = {
		unit_types = {
			america = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_lightshot/ene_deathvox_lightshot")
			},
			russia = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_lightshot/ene_deathvox_lightshot")
			},
			zombie = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_lightshot/ene_deathvox_lightshot")
			}					
		},
		access = access_type_all
	}
	self.unit_categories.deathvox_heavyshot = {
		unit_types = {
			america = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_heavyshot/ene_deathvox_heavyshot")
			},
			russia = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_heavyshot/ene_deathvox_heavyshot")
			},
			zombie = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_heavyshot/ene_deathvox_heavyshot")
			}						
		},
		access = access_type_all
	}
	self.unit_categories.deathvox_shield = {
		unit_types = {
			america = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_shield/ene_deathvox_shield")
			},
			russia = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_shield/ene_deathvox_shield")
			},
			zombie = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_shield/ene_deathvox_shield")
			}						
		},
		access = access_type_all,
		special_type = "shield"
	}
	self.unit_categories.deathvox_medic = {
		unit_types = {
			america = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_medic/ene_deathvox_medic")
			},
			russia = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_medic/ene_deathvox_medic")
			},
			zombie = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_medic/ene_deathvox_medic")
			}						
		},
		access = access_type_all,
		special_type = "medic"
	}
	self.unit_categories.deathvox_taser = {
		unit_types = {
			america = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_taser/ene_deathvox_taser"),
			},
			russia = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_taser/ene_deathvox_taser"),
			},
			zombie = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_taser/ene_deathvox_taser"),
			}					
		},
		access = access_type_all,
		special_type = "taser"
	}
	self.unit_categories.deathvox_greendozer = {
		unit_types = {
			america = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_greendozer/ene_deathvox_greendozer"),
			},
			russia = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_greendozer/ene_deathvox_greendozer"),
			},
			zombie = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_greendozer/ene_deathvox_greendozer"),
			}					
		},
		access = access_type_walk_only,
		special_type = "tank"
	}
	self.unit_categories.deathvox_medicdozer = {
		unit_types = {
			america = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_medicdozer/ene_deathvox_medicdozer"),
			},				
			russia = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_medicdozer/ene_deathvox_medicdozer"),
			},
			zombie = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_medicdozer/ene_deathvox_medicdozer"),
			}					
		},
		access = access_type_walk_only,
		special_type = "tank"
	}
	self.unit_categories.deathvox_blackdozer = {
		unit_types = {
			america = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_blackdozer/ene_deathvox_blackdozer"),
			},
			russia = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_blackdozer/ene_deathvox_blackdozer"),
			},
			zombie = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_blackdozer/ene_deathvox_blackdozer"),
			}				
		},
		access = access_type_walk_only,
		special_type = "tank"
	}
	self.unit_categories.deathvox_lmgdozer = {
		unit_types = {
			america = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_lmgdozer/ene_deathvox_lmgdozer"),
			},
			russia = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_lmgdozer/ene_deathvox_lmgdozer"),
			},
			zombie = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_lmgdozer/ene_deathvox_lmgdozer"),
			}					
		},
		access = access_type_walk_only,
		special_type = "tank"
	}
	self.unit_categories.deathvox_cloaker = {
		unit_types = {
			america = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cloaker/ene_deathvox_cloaker")
			},
			russia = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cloaker/ene_deathvox_cloaker")
			},
			zombie = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_cloaker/ene_deathvox_cloaker")
			}					
		},
		access = access_type_all,
		special_type = "spooc"
	}
	self.unit_categories.deathvox_sniper_assault = {
		unit_types = {
			america = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_sniper_assault/ene_deathvox_sniper_assault"),
			},
			russia = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_sniper_assault/ene_deathvox_sniper_assault"),
			},
			zombie = {
				Idstring("units/pd2_mod_gageammo/characters/ene_deathvox_sniper_assault/ene_deathvox_sniper_assault"),
			}					
		},
		access = access_type_walk_only,
		special_type = "ass_sniper"
	}
end

function GroupAITweakData:_init_enemy_spawn_groups(difficulty_index)
	old_spawn_group(self, difficulty_index)
	self.enemy_spawn_groups.gorgon = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 3,
				amount_max = 3,
				tactics = self._tactics.tazer_charge,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.swat_rifle,
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
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.shield_wall_charge,
				rank = 4
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.swat_rifle,
				rank = 3
			},
			{
				unit = "deathvox_lmgdozer", -- placeholder
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.tank_rush,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.swat_rifle,
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
				tactics = self._tactics.tazer_charge,
				rank = 4
			},
			{
				unit = "deathvox_blackdozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.tank_rush,
				rank = 3
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.swat_rifle,
				rank = 2
			},
			{
				unit = "deathvox_blackdozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.tank_rush,
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
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.tank_rush,
				rank = 3
			},
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.tazer_charge,
				rank = 2
			},
			{
				unit = "deathvox_grenadier",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.swat_rifle,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.artemis = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_sniper_assault",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.swat_rifle,
				rank = 3
			},
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.shield_wall_charge,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.swat_rifle,
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
				tactics = self._tactics.shield_wall_charge,
				rank = 2
			},
			{
				unit = "deathvox_lmgdozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.tank_rush,
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
				amount_min = 3,
				amount_max = 3,
				tactics = self._tactics.spooc,
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
				tactics = self._tactics.tank_rush,
				rank = 3
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.swat_rifle,
				rank = 2
			},
			{
				unit = "deathvox_medicdozer",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.tank_rush,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.atropos = {
		amount = {4, 4},
		spawn = {
			{
				unit = "deathvox_cloaker",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.spooc,
				rank = 2
			},
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.tazer_charge,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.aegeas = {
		amount = {3, 3},
		spawn = {
			{
				unit = "deathvox_grenadier",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.swat_rifle,
				rank = 3
			},
			{
				unit = "deathvox_shield",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.shield_wall_ranged,
				rank = 2
			},
			{
				unit = "deathvox_grenadier",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.swat_rifle,
				rank = 1
			}
		}
	}

	-- Death Vox Control Phase

	self.enemy_spawn_groups.recovery_unit = {
		amount = {4, 4},
		spawn = {
			{
				unit = "FBI_suit_stealth_MP5",
				freq = 1,
				amount_min = 3,
				amount_max = 3,
				tactics = self._tactics.swat_rifle,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.swat_rifle,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.too_group = {
		amount = {4, 4},
		spawn = {
			{
				unit = "FBI_suit_M4_MP5",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.swat_rifle,
				rank = 2
			},
			{
				unit = "deathvox_taser",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.tazer_charge,
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
				amount_min = 4,
				amount_max = 4,
				tactics = self._tactics.spooc,
				rank = 1
			}
		}
	}

	self.enemy_spawn_groups.recon = {
		amount = {4, 4},
		spawn = {
			{
				unit = "FBI_suit_M4_MP5",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.swat_rifle,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 3,
				amount_max = 3,
				tactics = self._tactics.swat_rifle,
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
				tactics = self._tactics.swat_rifle,
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
				tactics = self._tactics.swat_shotgun_flank,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.swat_rifle,
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
				tactics = self._tactics.swat_shotgun_flank,
				rank = 3
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.swat_rifle,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.swat_rifle,
				rank = 2
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
				tactics = self._tactics.swat_shotgun_flank,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.swat_rifle,
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
				tactics = self._tactics.swat_shotgun_flank,
				rank = 3
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.swat_rifle,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.swat_rifle,
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
				tactics = self._tactics.swat_shotgun_flank,
				rank = 3
			},
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.swat_shotgun_flank,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.swat_rifle,
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
				tactics = self._tactics.swat_shotgun_flank,
				rank = 3
			},
			{
				unit = "deathvox_lightshot",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.swat_shotgun_flank,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.swat_rifle,
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
				tactics = self._tactics.swat_rifle,
				rank = 2
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 2,
				amount_max = 2,
				tactics = self._tactics.swat_rifle,
				rank = 1
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.swat_rifle,
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
				tactics = self._tactics.swat_rifle,
				rank = 3
			},
			{
				unit = "deathvox_lightar",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.swat_rifle,
				rank = 2
			},
			{
				unit = "deathvox_medic",
				freq = 1,
				amount_min = 1,
				amount_max = 1,
				tactics = self._tactics.swat_rifle,
				rank = 1
			}
		}
	}
end

function GroupAITweakData:_init_task_data(difficulty_index, difficulty)
	old_task_data(self, difficulty_index, difficulty)
	if difficulty_index == 8 then
		self.besiege.assault.groups = {
			gorgon = { 0.05,0.05,0.05  },
			atlas = { 0.05,0.05,0.05  },
			chimera = { 0.05,0.05,0.05  },
			zeus = { 0.05,0.05,0.05  },
			artemis = { 0.05,0.05,0.05 },
			epeius = { 0.05,0.05,0.05  },
			damocles = { 0.05,0.05,0.05  },
			caduceus = { 0.05,0.05,0.05  },
			atropos = { 0.05,0.05,0.05 },
			aegeas = { 0.05,0.05,0.05 },
			dv_group_1 = {0.2, 0.2, 0.2},
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
			recovery_unit = { 0.25,0.25,0.25 },
			too_group = { 0.25,0.25,0.25 },
			styx = { 0.25,0.25,0.25 },
			recon = { 0.25,0.25,0.25 },
		}
	end
end