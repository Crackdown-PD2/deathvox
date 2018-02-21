local sm_wish = {
		["units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"] = "units/pd2_mod_gageammo/characters/ene_deathvox_greendozer/ene_deathvox_greendozer",
		["units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"] = "units/pd2_mod_gageammo/characters/ene_deathvox_blackdozer/ene_deathvox_blackdozer",
		["units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"] = "units/pd2_mod_gageammo/characters/ene_deathvox_lmgdozer/ene_deathvox_lmgdozer",
		["units/payday2/characters/ene_city_swat_1/ene_city_swat_1"] = "units/pd2_mod_gageammo/characters/ene_deathvox_lightar/ene_deathvox_lightar",
		["units/payday2/characters/ene_city_swat_2/ene_city_swat_2"] = "units/pd2_mod_gageammo/characters/ene_deathvox_lightar/ene_deathvox_lightar",
		["units/payday2/characters/ene_city_swat_3/ene_city_swat_3"] = "units/pd2_mod_gageammo/characters/ene_deathvox_lightar/ene_deathvox_lightar",
		["units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"] = "units/pd2_mod_gageammo/characters/ene_deathvox_lightar/ene_deathvox_lightar",
		["units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"] = "units/pd2_mod_gageammo/characters/ene_deathvox_lightar/ene_deathvox_lightar",
		["units/payday2/characters/ene_swat_1/ene_swat_1"] = "units/pd2_mod_gageammo/characters/ene_deathvox_lightar/ene_deathvox_lightar",
		["units/payday2/characters/ene_swat_2/ene_swat_2"] = "units/pd2_mod_gageammo/characters/ene_deathvox_lightar/ene_deathvox_lightar",
		["units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1"] = "units/pd2_mod_gageammo/characters/ene_deathvox_heavyar/ene_deathvox_heavyar",
		["units/payday2/characters/ene_swat_heavy_r870/ene_swat_heavy_r870"] = "units/pd2_mod_gageammo/characters/ene_deathvox_heavyshot/ene_deathvox_heavyshot",
		["units/payday2/characters/ene_shield_1/ene_shield_1"] = "units/pd2_mod_gageammo/characters/ene_deathvox_shield/ene_deathvox_shield",
		["units/payday2/characters/ene_shield_2/ene_shield_2"] = "units/pd2_mod_gageammo/characters/ene_deathvox_shield/ene_deathvox_shield",
		["units/payday2/characters/ene_city_shield/ene_city_shield"] = "units/pd2_mod_gageammo/characters/ene_deathvox_shield/ene_deathvox_shield",
		["units/payday2/characters/ene_fbi_1/ene_fbi_1"] = "units/pd2_mod_gageammo/characters/ene_deathvox_lightar/ene_deathvox_lightar",
		["units/payday2/characters/ene_fbi_2/ene_fbi_2"] = "units/pd2_mod_gageammo/characters/ene_deathvox_lightar/ene_deathvox_lightar",
		["units/payday2/characters/ene_fbi_3/ene_fbi_3"] = "units/pd2_mod_gageammo/characters/ene_deathvox_lightar/ene_deathvox_lightar",
		["units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"] = "units/pd2_mod_gageammo/characters/ene_deathvox_heavyar/ene_deathvox_heavyar",
		["units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870"] = "units/pd2_mod_gageammo/characters/ene_deathvox_heavyshot/ene_deathvox_heavyshot",
		["units/payday2/characters/ene_security_1/ene_security_1"] = "units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard",
		["units/payday2/characters/ene_security_2/ene_security_2"] = "units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard",
		["units/payday2/characters/ene_security_3/ene_security_3"] = "units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard",
		["units/payday2/characters/ene_security_4/ene_security_4"] = "units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard",
		["units/payday2/characters/ene_security_5/ene_security_5"] = "units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard",
		["units/payday2/characters/ene_security_6/ene_security_6"] = "units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard",
		["units/payday2/characters/ene_security_7/ene_security_7"] = "units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard",
		["units/payday2/characters/ene_security_8/ene_security_8"] = "units/pd2_mod_gageammo/characters/ene_deathvox_guard/ene_deathvox_guard"
	}
function ElementSpawnEnemyDummy:init(...)
	ElementSpawnEnemyDummy.super.init(self, ...)
	local ai_type = tweak_data.levels:get_ai_group_type()
	local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
	local difficulty_index = tweak_data:difficulty_to_index(difficulty)
	local job = Global.level_data and Global.level_data.level_id

	if difficulty_index == 8 then
		if sm_wish[self._values.enemy] then
			self._values.enemy = sm_wish[self._values.enemy]
		end
		self._values.enemy = sm_wish[self._values.enemy] or self._values.enemy
	end
	
	self._enemy_name = self._values.enemy and Idstring(self._values.enemy) or Idstring("units/payday2/characters/ene_swat_1/ene_swat_1")
	self._values.enemy = nil
	self._units = {}
	self._events = {}
	self:_finalize_values()
end