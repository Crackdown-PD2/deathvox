if deathvox:IsTotalCrackdownEnabled() then 

	Hooks:PostHook(CivilianBrain,"init","cd_civilianbrain_init",function(self,unit)
		self._HOSTAGE_AREA_MARKING_T = Application:time()
		self._HAS_DONE_FAKEOUT_TRADE = false
	end)

	Hooks:PostHook(CivilianBrain,"update","cd_civilianbrain_update",function(self,unit, t, dt)
		if self:is_tied() then --and Network:is_server()
		
			if self._HOSTAGE_AREA_MARKING_T + tweak_data.upgrades.values.team.player.civilian_hostage_area_marking_interval < t then 

				self._HOSTAGE_AREA_MARKING_T = t
				
				local distance,incoming_damage_mul = unpack(managers.player:team_upgrade_value("player","civilian_hostage_area_marking",{}))
				if distance and distance > 0 then 
				
					local pos = unit:movement() and unit:movement():m_pos() or unit:position()
					
					for _,enemy_unit in pairs(World:find_units_quick("sphere",pos,distance,managers.slot:get_mask("enemies"))) do
						if enemy_unit:contour() then 
							if enemy_unit:base() and enemy_unit:base().sentry_gun then 
								enemy_unit:contour():add("mark_unit_dangerous",false)
							else
								enemy_unit:contour():add("mark_enemy",false)
							end
						end
					end
				end
			end
		end
	end)
	
end
