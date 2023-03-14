if deathvox:IsTotalCrackdownEnabled() then 

	Hooks:PostHook(CivilianBrain,"init","cd_civilianbrain_init",function(self,unit)
		self._hostage_area_marking_t = Application:time()
		self._has_done_fakeout_trade = false
	end)

	Hooks:PostHook(CivilianBrain,"update","cd_civilianbrain_update",function(self,unit, t, dt)
		--marking and damage are both clientside
		
		if self:is_tied() then --and Network:is_server()
			if managers.player:has_team_category_upgrade("player","civilian_hostage_area_marking") then
				local interval = tweak_data.upgrades.values.team.player.civilian_hostage_area_marking_interval
				if self._hostage_area_marking_t + interval < t then 

					self._hostage_area_marking_t = self._hostage_area_marking_t + interval
					
					local distance = tweak_data.upgrades.values.team.player.civilian_hostage_area_marking_distance
					local pos = unit:movement() and unit:movement():m_pos() or unit:position()
					
					for _,enemy_unit in pairs(World:find_units_quick("sphere",pos,distance,managers.slot:get_mask("enemies"))) do
						local ubase = enemy_unit:base()
						if ubase then
							if enemy_unit:contour() then 
								if ubase.sentry_gun then 
									enemy_unit:contour():add("mark_enemy",false)
								else
									if ubase.has_tag and ubase:has_tag("special") and managers.player:team_upgrade_value("player","civilian_hostage_area_marking") > 1 then
										enemy_unit:contour():add("civilian_mark_special",false)
									else
										enemy_unit:contour():add("civilian_mark_standard",false)
									end
								end
							end
						end
					end
				end
			end
		end
	end)
	
	function CivilianBrain:on_hostage_move_interaction(interacting_unit, command)
		if not self._logic_data.is_tied then
			return
		end

		if command == "move" then
			local following_hostages = managers.groupai:state():get_following_hostages(interacting_unit)
			local max_nr = interacting_unit:base():upgrade_value("player","max_civ_hostage_followers",1)

			if following_hostages and max_nr <= table.size(following_hostages) then
				return
			end

			if not self._unit:anim_data().drop and self._unit:anim_data().tied then
				return
			end

			local stand_action_desc = {
				clamp_to_graph = true,
				variant = "stand_tied",
				body_part = 1,
				type = "act"
			}
			local action = self._unit:movement():action_request(stand_action_desc)

			if not action then
				return
			end

			self._unit:movement():set_stance("cbt", nil, true)

			local follow_objective = {
				interrupt_health = 0,
				distance = 500,
				type = "follow",
				lose_track_dis = 2000,
				stance = "cbt",
				interrupt_dis = 0,
				follow_unit = interacting_unit,
				nav_seg = interacting_unit:movement():nav_tracker():nav_segment(),
				fail_clbk = callback(self, self, "on_hostage_follow_objective_failed")
			}

			self:set_objective(follow_objective)
			self._unit:interaction():set_tweak_data("hostage_stay")
			self._unit:interaction():set_active(true, true)
			interacting_unit:sound():say("f38_any", true, false)

			self._following_hostage_contour_id = self._unit:contour():add("friendly", true)

			managers.groupai:state():on_hostage_follow(interacting_unit, self._unit, true)
		elseif command == "stay" then
			if not self._unit:anim_data().stand then
				return
			end

			self:set_objective({
				amount = 1,
				type = "surrender",
				aggressor_unit = interacting_unit
			})

			if not self._unit:anim_data().stand then
				return
			end

			local stand_action_desc = {
				clamp_to_graph = true,
				variant = "drop",
				body_part = 1,
				type = "act"
			}
			local action = self._unit:movement():action_request(stand_action_desc)

			if not action then
				return
			end

			self._unit:movement():set_stance("hos", nil, true)
			self._unit:interaction():set_tweak_data("hostage_move")
			self._unit:interaction():set_active(true, true)

			if alive(interacting_unit) then
				interacting_unit:sound():say("f02x_sin", true, false)
			end

			if self._following_hostage_contour_id then
				self._unit:contour():remove_by_id(self._following_hostage_contour_id, true)

				self._following_hostage_contour_id = nil
			end

			managers.groupai:state():on_hostage_follow(interacting_unit, self._unit, false)
		elseif command == "release" then
			self._logic_data.is_tied = nil

			if self._logic_data.objective and self._logic_data.objective.type == "follow" then
				self:set_objective(nil)
			end

			self._unit:movement():set_stance("hos", nil, true)

			local stand_action_desc = {
				variant = "panic",
				body_part = 1,
				type = "act"
			}
			local action = self._unit:movement():action_request(stand_action_desc)

			if not action then
				return
			end

			self._unit:interaction():set_tweak_data("intimidate")
			self._unit:interaction():set_active(false, true)

			if self._following_hostage_contour_id then
				self._unit:contour():remove_by_id(self._following_hostage_contour_id, true)

				self._following_hostage_contour_id = nil
			end

			managers.groupai:state():on_hostage_follow(interacting_unit, self._unit, false)
		end

		return true
	end

	
end
