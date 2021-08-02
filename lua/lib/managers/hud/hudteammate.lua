HUDTeammate.sociopath_health_texture_path = "guis/textures/pd2/hud_health_sociopath"
HUDTeammate.sociopath_health_texture_w = 96
HUDTeammate.sociopath_health_texture_h = 96

Hooks:PostHook(HUDTeammate,"_create_radial_health","deathvox_hudteammate_createradialhealth",function(self, radial_health_panel)
	
	local is_sociopath
	if self._main_player then 
--		is_sociopath = managers.player:has_category_upgrade("player","sociopath_mode")
	else
		--todo peer detection
	end
	
	if is_sociopath then 
		local panel = radial_health_panel or self._radial_health_panel
		if alive(panel) then 
			local radial_health = panel:child("radial_health")
			if alive(radial_health) then 
				radial_health:hide()
			end
			
			local sociopath_health = panel:bitmap({
				name = "sociopath_health",
				texture = self.sociopath_health_texture_path,
				color = Color(1,1,1),
				texture_rect = {
					0,
					0,
					self.sociopath_health_texture_w,
					self.sociopath_health_texture_h
				},
				layer = 1,
				w = panel:w(),
				h = panel:h()
			})
	--		sociopath_health:set_center(c_x,c_y)
			
			local radial_shield = panel:child("radial_shield")
			if alive(radial_shield) then 
				radial_shield:hide()
			end
			
			local radial_delayed_damage_armor = panel:child("radial_delayed_damage_armor")
			if alive(radial_delayed_damage_armor) then 
				radial_delayed_damage_armor:hide()
			end
			
			local radial_delayed_damage_health = panel:child("radial_delayed_damage_health")
			if alive(radial_delayed_damage_health) then 
				radial_delayed_damage_health:hide()
			end

			local radial_absorb_health_active = panel:child("radial_absorb_health_active")
			if alive(radial_absorb_health_active) then 
				radial_absorb_health_active:hide()
			end
			local radial_absorb_shield_active = panel:child("radial_absorb_shield_active")
			if alive(radial_absorb_shield_active) then 
				radial_absorb_shield_active:hide()
			end
			local radial_info_meter_bg = panel:child("radial_info_meter_bg")
			if alive(radial_info_meter_bg) then 
				radial_info_meter_bg:hide()
			end
		end
	end
end)

Hooks:PostHook(HUDTeammate,"set_health","deathvox_hudteammate_sethealth",function(self,current,total)
	if alive(self._sociopath_health) then 
		local tw = self.sociopath_health_texture_w
		local th = self.sociopath_health_texture_h
		self._sociopath_health:set_texture_rect(1 + ((1 + tw) * math.round(current)),1,tw,th)
		
	end
	
end)