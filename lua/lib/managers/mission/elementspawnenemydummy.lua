local enemy_replacements = {
	
-- Beat police.
		["units/payday2/characters/ene_cop_1/ene_cop_1"] = "deathvox_cop_pistol",
		["units/payday2/characters/ene_cop_2/ene_cop_2"] = "deathvox_cop_revolver",
		["units/payday2/characters/ene_cop_3/ene_cop_3"] = "deathvox_cop_smg",
		["units/payday2/characters/ene_cop_4/ene_cop_4"] = "deathvox_cop_shotgun",
	
-- "Classic" FBI units. Now principally used in assault breaks.
		["units/payday2/characters/ene_fbi_1/ene_fbi_1"] = "deathvox_fbi_rookie",
		["units/payday2/characters/ene_fbi_2/ene_fbi_2"] = "deathvox_fbi_veteran",
		["units/payday2/characters/ene_fbi_3/ene_fbi_3"] = "deathvox_fbi_hrt",
--City swats.
		["units/payday2/characters/ene_city_swat_1/ene_city_swat_1"] = "deathvox_lightar",
		["units/payday2/characters/ene_city_swat_2/ene_city_swat_2"] = "deathvox_lightshot",
		["units/payday2/characters/ene_city_swat_3/ene_city_swat_3"] = "deathvox_lightar",
		["units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870"] = "deathvox_heavyshot",
		["units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36"] = "deathvox_heavyar",

--fbi swats.
		["units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"] = "deathvox_lightar",
		["units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"] = "deathvox_lightshot",
		["units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"] = "deathvox_heavyar",
		["units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870"] = "deathvox_heavyshot",

--blue and "white" swats.
		["units/payday2/characters/ene_swat_1/ene_swat_1"] = "deathvox_lightar",
		["units/payday2/characters/ene_swat_2/ene_swat_2"] = "deathvox_lightshot",
		["units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1"] = "deathvox_heavyar",
		["units/payday2/characters/ene_swat_heavy_r870/ene_swat_heavy_r870"] = "deathvox_heavyshot",

-- base zeals.
		["units/pd2_dlc_gitgud/characters/ene_zeal_swat/ene_zeal_swat"] = "deathvox_lightar",
		["units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy"] = "deathvox_heavyar",

-- SWAT special enemies.
-- shields.
		["units/payday2/characters/ene_shield_1/ene_shield_1"] = "deathvox_shield",
		["units/payday2/characters/ene_shield_2/ene_shield_2"] = "deathvox_shield",
		["units/payday2/characters/ene_city_shield/ene_city_shield"] = "deathvox_shield",
		["units/pd2_dlc_gitgud/characters/ene_zeal_swat_shield/ene_zeal_swat_shield"] = "deathvox_shield",
--cloakers.
		["units/payday2/characters/ene_spook_1/ene_spook_1"] = "deathvox_cloaker",
		["units/pd2_dlc_gitgud/characters/ene_zeal_cloaker/ene_zeal_cloaker"] = "deathvox_cloaker",
--medics.
		["units/payday2/characters/ene_medic_m4/ene_medic_m4"] = "deathvox_medic",
		["units/payday2/characters/ene_medic_r870/ene_medic_r870"] = "deathvox_medic",
--snipers. commenting out in case we get custom unit appearance.
--		["units/payday2/characters/ene_sniper_1/ene_sniper_1"] = 
--		["units/payday2/characters/ene_sniper_2/ene_sniper_2"] = 
--tasers.
		["units/payday2/characters/ene_tazer_1/ene_tazer_1"] = "deathvox_taser",
		["units/pd2_dlc_gitgud/characters/ene_zeal_tazer/ene_zeal_tazer"] = "deathvox_taser",

--bulldozers.		
		["units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"] = "deathvox_greendozer",
		["units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"] = "deathvox_blackdozer",
		["units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"] = "deathvox_lmgdozer",
	
--Z-dozers. DS unit order is irregular- confirmed correct.
		["units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer/ene_zeal_bulldozer"] = "deathvox_lmgdozer",
		["units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_2/ene_zeal_bulldozer_2"] = "deathvox_greendozer",
		["units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_3/ene_zeal_bulldozer_3"] = "deathvox_blackdozer",

-- Medicdozer, in case of scripted use in future.
		["units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic"] = "deathvox_medicdozer",
-- Minidozer, in case of scripted use in future.
--		["units/pd2_dlc_drm/characters/ene_bulldozer_minigun/ene_bulldozer_minigun"] = 
-- sm_ enemies currently unused.

-- Akan below.	
-- akan cop enemies.
		["units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass"] = "deathvox_lightar",
		["units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"] = "deathvox_lightar",
		["units/pd2_dlc_mad/characters/ene_akan_cs_cop_asval_smg/ene_akan_cs_cop_asval_smg"] = "deathvox_lightar",
		["units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870"] = "deathvox_lightshot",
-- akan swat enemies.
		["units/pd2_dlc_mad/characters/ene_akan_cs_heavy_ak47_ass/ene_akan_cs_heavy_ak47_ass"]  = "deathvox_heavyar",
		["units/pd2_dlc_mad/characters/ene_akan_cs_heavy_r870/ene_akan_cs_heavy_r870"] = "deathvox_heavyshot",
		["units/pd2_dlc_mad/characters/ene_akan_cs_swat_ak47_ass/ene_akan_cs_swat_ak47_ass"] = "deathvox_lightar",
		["units/pd2_dlc_mad/characters/ene_akan_cs_swat_r870/ene_akan_cs_swat_r870"] = "deathvox_lightshot",
-- akan fbi enemies.
		["units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36"] = "deathvox_heavyar",
		["units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870/ene_akan_fbi_heavy_r870"] = "deathvox_heavyshot",
		["units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870"] = "deathvox_lightshot",
		["units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"] = "deathvox_lightar",
-- akan dw enemies.
		["units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_ak47_ass/ene_akan_fbi_swat_dw_ak47_ass"] = "deathvox_lightar",
		["units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_r870/ene_akan_fbi_swat_dw_r870"] = "deathvox_lightshot",

-- Akan Specials below.
-- akan shields.
		["units/pd2_dlc_mad/characters/ene_akan_cs_shield_c45/ene_akan_cs_shield_c45"] = "deathvox_shield",
		["units/pd2_dlc_mad/characters/ene_akan_fbi_shield_dw_sr2_smg/ene_akan_fbi_shield_dw_sr2_smg"] = "deathvox_shield",
		["units/pd2_dlc_mad/characters/ene_akan_fbi_shield_sr2_smg/ene_akan_fbi_shield_sr2_smg"] = "deathvox_shield",

-- akan cloaker.
		["units/pd2_dlc_mad/characters/ene_akan_fbi_spooc_asval_smg/ene_akan_fbi_spooc_asval_smg"] = "deathvox_cloaker",

-- akan sniper. Not swapping for now. Need to see how to get effect working regardless.
--		["units/pd2_dlc_mad/characters/ene_akan_cs_swat_sniper_svd_snp/ene_akan_cs_swat_sniper_svd_snp"]

-- akan taser.
		["units/pd2_dlc_mad/characters/ene_akan_cs_tazer_ak47_ass/ene_akan_cs_tazer_ak47_ass"] = "deathvox_taser",

--akan dozers.
		["units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"] = "deathvox_greendozer",
		["units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg"] = "deathvox_lmgdozer",
		["units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"] = "deathvox_blackdozer",
-- Zombie cops below.
	
-- Zombie Special units.
-- Zombie Dozers.
--		["units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"] = "deathvox_greendozer",
--		["units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"] = "blackdozer",
--		["units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3"] = "deathvox_lmgdozer",

-- Other units.

-- Security Guards, not directly replacing. There are  more of these to document! 
--	I need to check against the full pool and identify roles. Some have pistols, some have smgs, some have shotguns.
--		["units/payday2/characters/ene_security_1/ene_security_1"] = "units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard",
--		["units/payday2/characters/ene_security_2/ene_security_2"] = "units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard",
--		["units/payday2/characters/ene_security_3/ene_security_3"] = "units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard",
--		["units/payday2/characters/ene_security_4/ene_security_4"] = "units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard",
--		["units/payday2/characters/ene_security_5/ene_security_5"] = "units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard",
--		["units/payday2/characters/ene_security_6/ene_security_6"] = "units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard",
--		["units/payday2/characters/ene_security_7/ene_security_7"] = "units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard",
--		["units/payday2/characters/ene_security_8/ene_security_8"] = "units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard"

-- Definitely missing Alesso guards here.
	
-- Secret Service.
-- Light.
-- No light.
-- Murkywater.
	
-- Safehouse guards (Hoxvenge).
	

-- "Dress" FBI of various sorts, male and female.	
	
-- Criminals below here.

-- Commissar's Russian mob in Hotline Miami.
-- 1:
--		["units/payday2/characters/ene_gang_mobster_1/ene_gang_mobster_1"] = 
-- 2: 
--		["units/payday2/characters/ene_gang_mobster_2/ene_gang_mobster_2"] = 
-- 3:
--		["units/payday2/characters/ene_gang_mobster_3/ene_gang_mobster_3"] = 
-- 4:
--		["units/payday2/characters/ene_gang_mobster_4/ene_gang_mobster_4"] = 
-- 5:
--		["units/payday2/characters/ene_gang_russian_5/ene_gang_russian_5"] =

-- Overkill MC.

-- Cobras.
-- ["units/payday2/characters/ene_gang_black_1/ene_gang_black_1"] =
-- ["units/payday2/characters/ene_gang_black_2/ene_gang_black_2"] =
-- ["units/payday2/characters/ene_gang_black_3/ene_gang_black_3"] =
-- ["units/payday2/characters/ene_gang_black_4/ene_gang_black_4"] =
	
-- Mendozas.
-- 1:
--		["units/payday2/characters/ene_gang_mexican_1/ene_gang_mexican_1"] = 
-- 2:
--		["units/payday2/characters/ene_gang_mexican_2/ene_gang_mexican_2"] = 
-- 3:
--		["units/payday2/characters/ene_gang_mexican_3/ene_gang_mexican_3"] = 
-- 4:
--		["units/payday2/characters/ene_gang_mexican_4/ene_gang_mexican_4"] = 

-- Russians for Vlad jobs/other miscellany.

-- Sosa guards.
-- Outdoor 1:
--		["units/pd2_dlc_friend/characters/ene_bolivian_thug_outdoor_01/ene_bolivian_thug_outdoor_01"] = 
-- Outdoor 2:
--		["units/pd2_dlc_friend/characters/ene_bolivian_thug_outdoor_02/ene_bolivian_thug_outdoor_02"] = 
-- Indoor 1:
--		["units/pd2_dlc_friend/characters/ene_thug_indoor_01/ene_thug_indoor_01"] = 
-- Indoor 2:	
--		["units/pd2_dlc_friend/characters/ene_thug_indoor_02/ene_thug_indoor_02"] = 
-- Security Manager:
--		["units/pd2_dlc_friend/characters/ene_security_manager/ene_security_manager"]
	
	
-- Brooklyn 10-10.
-- Sniper:
--		["units/pd2_dlc_spa/characters/ene_sniper_3/ene_sniper_3"] = 
	
-- Bosses. Now handled via direct reference in charactertweakdata.
-- Commissar.
-- Sosa.
-- Unarmored Sosa.
-- Biker boss.
-- Chavez.
-- Hector.
-- Unarmored Hector.
-- Undercover (RvD 1).
-- FBI Boss (Hoxbreak 2).
	
-- Headless TitanDozer.	There are be multiple specified for different heists- further inquiry needed.
	
-- Headless Zealdozer.
--		["units/pd2_dlc_help/characters/ene_zeal_bulldozer_halloween/ene_zeal_bulldozer_halloween"]	

-- German unit replacement for specific custom heists.
		["units/zdann/characters/ene_ger_city_heavy_g36/ene_ger_city_heavy_g36"] = "deathvox_heavyar",
		["units/zdann/characters/ene_ger_city_heavy_r870/ene_ger_city_heavy_r870"] = "deathvox_heavyshot",
		["units/zdann/characters/ene_ger_city_swat_1/ene_ger_city_swat_1"] = "deathvox_lightar",
		["units/zdann/characters/ene_ger_city_swat_2/ene_ger_city_swat_2"] = "deathvox_lightshot",
		["units/zdann/characters/ene_ger_city_swat_3/ene_ger_city_swat_3"] = "deathvox_lightar",
		["units/zdann/characters/ene_ger_city_swat_r870/ene_ger_city_swat_r870"] = "deathvox_lightshot",
		["units/zdann/characters/ene_ger_fbi_heavy_1/ene_ger_fbi_heavy_1"] = "deathvox_heavyar",
		["units/zdann/characters/ene_ger_fbi_heavy_r870/ene_ger_fbi_heavy_r870"] = "deathvox_heavyshot",
		["units/zdann/characters/ene_ger_fbi_swat_1/ene_ger_fbi_swat_1"] = "deathvox_lightar",
		["units/zdann/characters/ene_ger_fbi_swat_2/ene_ger_fbi_swat_2"] = "deathvox_lightshot",
		["units/zdann/characters/ene_ger_flamer_1/ene_ger_flamer_1"] = "deathvox_greendozer",
		["units/zdann/characters/ene_ger_flamer_2/ene_ger_flamer_2"] = "deathvox_blackdozer",
		["units/zdann/characters/ene_ger_flamer_3/ene_ger_flamer_3"] = "deathvox_lmgdozer",
		["units/zdann/characters/ene_ger_flamer_4/ene_ger_flamer_4"] = "deathvox_lmgdozer", -- todo: implement flamer class for flamerdozer, need to add 4 bikerdozer anyways
		["units/zdann/characters/ene_ger_guard_1/ene_ger_guard_1"] = "deathvox_guard",
		["units/zdann/characters/ene_ger_guard_2/ene_ger_guard_2"] = "deathvox_guard",
		["units/zdann/characters/ene_ger_medic_m4/ene_ger_medic_m4"] = "deathvox_medic",
		["units/zdann/characters/ene_ger_medic_r870/ene_ger_medic_r870"] = "deathvox_medic",
		["units/zdann/characters/ene_ger_shield_1/ene_ger_shield_1"] = "deathvox_shield",
		["units/zdann/characters/ene_ger_shield_2/ene_ger_shield_2"] = "deathvox_shield",
		["units/zdann/characters/ene_ger_shield_city/ene_ger_shield_city"] = "deathvox_shield",
		["units/zdann/characters/ene_ger_swat_1/ene_ger_swat_1"] = "deathvox_lightar",
		["units/zdann/characters/ene_ger_swat_2/ene_ger_swat_2"] = "deathvox_lightshot",
		["units/zdann/characters/ene_ger_swat_heavy_1/ene_ger_swat_heavy_1"] = "deathvox_heavyar",
		["units/zdann/characters/ene_ger_swat_heavy_r870/ene_ger_swat_heavy_r870"] = "deathvox_heavyshot"
	}
function ElementSpawnEnemyDummy:init(...)
	ElementSpawnEnemyDummy.super.init(self, ...)
	local ai_type = tweak_data.levels:get_ai_group_type()
	local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
	local difficulty_index = tweak_data:difficulty_to_index(difficulty)
	local job = Global.level_data and Global.level_data.level_id
	if enemy_replacements[self._values.enemy] then
		self._values.enemy = self:get_enemy_by_diff(enemy_replacements[self._values.enemy], ai_type)
	end
	self._enemy_name = self._values.enemy and Idstring(self._values.enemy) or Idstring("units/payday2/characters/ene_swat_1/ene_swat_1")
	self._values.enemy = nil
	self._units = {}
	self._events = {}
	self:_finalize_values()
end

function ElementSpawnEnemyDummy:get_enemy_by_diff(enemy_to_check, ai_type)
	local unit_categories = tweak_data.group_ai.unit_categories
	if unit_categories[enemy_to_check] then
		local unit_to_check = unit_categories[enemy_to_check]
		if unit_to_check.unit_type_spawner[ai_type] then
			return unit_to_check.unit_type_spawner[ai_type]
		else
			return unit_to_check.unit_type_spawner["cop"]
		end
	end
	return "units/payday2/characters/ene_swat_1/ene_swat_1"
end
	
