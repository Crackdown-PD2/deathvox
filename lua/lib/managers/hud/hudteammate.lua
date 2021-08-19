HUDTeammate.sociopath_health_texture_path = "guis/textures/pd2/hud_health_sociopath"
HUDTeammate.sociopath_health_texture_w = 96
HUDTeammate.sociopath_health_texture_h = 96

Hooks:PostHook(HUDTeammate,"_create_radial_health","deathvox_hudteammate_createradialhealth",function(self, radial_health_panel)
	
	local is_sociopath
	if self._main_player then 
		is_sociopath = managers.player:has_category_upgrade("player","sociopath_mode")
	else
		local peer_id = self:peer_id()
		if peer_id then 
		--todo peer detection
			local peer = managers.network:session():peer(peer_id) 
			if peer then 
				local outfit = peer and peer:blackmarket_outfit()
				local skills = outfit and outfit.skills
				local perk = skills and skills.specializations
				if perk then 
					if perk[1] == 9 then --sociopath is deck #9
						is_sociopath = true
					end
				end
			end
		end

	end
	
	if is_sociopath then 
		local panel = radial_health_panel or self._radial_health_panel
		if alive(panel) then 
			local radial_health = panel:child("radial_health")
			if alive(radial_health) then 
				radial_health:hide()
			end
			
			local radial_bg = panel:child("radial_bg")
			if alive(radial_bg) then 
				radial_bg:hide()
			end
			
			local sociopath_health = panel:bitmap({
				name = "sociopath_health",
				texture = self.sociopath_health_texture_path,
				color = Color(1,1,1),
				texture_rect = {
					0,
					0,
					HUDTeammate.sociopath_health_texture_w,
					HUDTeammate.sociopath_health_texture_h
				},
				layer = 1,
				w = panel:w(),
				h = panel:h()
			})
			self._sociopath_health = sociopath_health
			
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
			--[[
			local radial_info_meter_bg = panel:child("radial_info_meter_bg")
			if alive(radial_info_meter_bg) then 
				radial_info_meter_bg:hide()
			end
			--]]
		end
	end
end)

Hooks:PostHook(HUDTeammate,"set_health","deathvox_hudteammate_sethealth",function(self,data)
	if alive(self._sociopath_health) then 
		local current_index = math.floor(5 - data.current)
		local tw = HUDTeammate.sociopath_health_texture_w
		local th = HUDTeammate.sociopath_health_texture_h
		self._sociopath_health:set_texture_rect(1 + ((1 + tw) * current_index),1,tw,th)
	end
	
end)