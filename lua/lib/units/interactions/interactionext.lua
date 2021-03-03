--[[
local ids_material = Idstring("material")

local is_PS3 = SystemInfo:platform() == Idstring("PS3")
local is_win32 = SystemInfo:platform() == Idstring("WIN32")

local ids_contour_color = Idstring("contour_color")
local ids_contour_opacity = Idstring("contour_opacity")
--]]

if deathvox:IsTotalCrackdownEnabled() then 

	function TripMineInteractionExt:can_select(player)
		if self._unit:base():is_owner() then 
			return TripMineInteractionExt.super.can_select(self,player)
		end
		return false
	end
	
	
	function TripMineInteractionExt:interact(player)
		if not self:can_interact(player) then
			return false
		end

		TripMineInteractionExt.super.super.interact(self, player)

		--local armed = not self._unit:base():armed()

		--self._unit:base():set_armed(armed)
		
		if TripmineControlMenu.action_radial and self._unit:base():is_owner() then 
--			TripmineControlMenu.action_radial:clear_items()
--			local is_special = self._unit:base():_get_trigger_mode() == "special"
--			local special_slot = 6
--			TripmineControlMenu.action_radial._items,special_slot = TripmineControlMenu:GetMenuItems(is_special)
--			TripmineControlMenu.action_radial:populate_items()
--			TripmineControlMenu.action_radial._items[special_slot]._body:set_alpha(is_special and 0.5 or 1)
		
			TripmineControlMenu:SelectTripmineByUnit(self._unit)
		
			TripmineControlMenu.action_radial:Show()
			self:unselect()
			
			TripmineControlMenu.interacted_radial_start_t = Application:time()
			TripmineControlMenu.button_held_state = nil
		end
	end
	
	function SentryGunFireModeInteractionExt:interact(player)
		if not self:can_interact(player) then
			return false
		end

		SentryGunFireModeInteractionExt.super.super.interact(self, player)
		
		SentryControlMenu:SelectSentryByUnit(self._sentry_gun_weapon._unit)
		if SentryControlMenu.action_radial then 
			SentryControlMenu.action_radial:Show()
			self:unselect() --remove the prompt upon opening the menu
			
			SentryControlMenu.interacted_radial_start_t = Application:time()
			SentryControlMenu.button_held_state = nil
		end
	end
	
	ArmorPlatesBaseInteractionExt = ArmorPlatesBaseInteractionExt or class(UseInteractionExt)
	function ArmorPlatesBaseInteractionExt:_interact_blocked(player)
		return managers.player:get_property("armor_plates_active")--,false,"already_has_armor_plates"
	end
	
	function ArmorPlatesBaseInteractionExt:interact(player)
		ArmorPlatesBaseInteractionExt.super.super.interact(self,player)
		local interacted = self._unit:base():take(player)
		if interacted then 
			--managers.player:send_message(Message.OnArmorPlateUsed,nil,player)
			--no current plans to that would require setting up a listener
		end
		return interacted
	end
	
	function ReviveInteractionExt:interact(reviving_unit,from_quickrevive_fak)
		if reviving_unit and reviving_unit == managers.player:player_unit() then
			if not self:can_interact(reviving_unit) then
				return
			end

			if self._tweak_data.equipment_consume then
				managers.player:remove_special(self._tweak_data.special_equipment)
			end

			if self._tweak_data.sound_event then
				reviving_unit:sound():play(self._tweak_data.sound_event)
			end

			ReviveInteractionExt.super.interact(self, reviving_unit)
			managers.achievment:set_script_data("player_reviving", false)
			managers.player:activate_temporary_upgrade("temporary", "combat_medic_damage_multiplier")
			managers.player:activate_temporary_upgrade("temporary", "combat_medic_enter_steelsight_speed_multiplier")
		end

		self:remove_interact()

		if self._unit:damage() and self._unit:damage():has_sequence("interact") then
			self._unit:damage():run_sequence_simple("interact")
		end

		if self._unit:base().is_husk_player then
			local revive_rpc_params = {
				"revive_player",
				from_quickrevive_fak and 1, -- or managers.player:upgrade_value("player", "revive_health_boost", 0)
				managers.player:upgrade_value("player", "revive_damage_reduction_level", 0)
			}

			managers.statistics:revived({
				npc = false,
				reviving_unit = reviving_unit
			})
			self._unit:network():send_to_unit(revive_rpc_params)
		else
			self._unit:character_damage():revive(reviving_unit)
			managers.statistics:revived({
				npc = true,
				reviving_unit = reviving_unit
			})
		end

		if reviving_unit:in_slot(managers.slot:get_mask("criminals")) then
			local hint = self.tweak_data == "revive" and 2 or 3

			managers.network:session():send_to_peers_synched("sync_teammate_helped_hint", hint, self._unit, reviving_unit)
			managers.trade:sync_teammate_helped_hint(self._unit, reviving_unit, hint)
		end

		if managers.blackmarket:equipped_mask().mask_id == tweak_data.achievement.witch_doctor.mask then
			managers.achievment:award_progress(tweak_data.achievement.witch_doctor.stat)
		end

		local event_listener = reviving_unit:event_listener()

		if event_listener then
			event_listener:call("on_revive_interaction_success")
		end
	end
		
		
	function IntimitateInteractionExt:interact(player)
		if not self:can_interact(player) then
			return
		end

		local player_manager = managers.player
		local has_equipment = managers.player:has_special_equipment(self._tweak_data.special_equipment)

		if self._tweak_data.equipment_consume and has_equipment then
			managers.player:remove_special(self._tweak_data.special_equipment)
		end

		if self._tweak_data.sound_event then
			player:sound():play(self._tweak_data.sound_event)
		end

		if self._unit:damage() and self._unit:damage():has_sequence("interact") then
			self._unit:damage():run_sequence_simple("interact")
		end

		if self.tweak_data == "corpse_alarm_pager" then
			if Network:is_server() then
				self._nbr_interactions = 0

				if self._unit:character_damage():dead() then
					local u_id = managers.enemy:get_corpse_unit_data_from_key(self._unit:key()).u_id

					managers.network:session():send_to_peers_synched("alarm_pager_interaction", u_id, self.tweak_data, 3)
				else
					managers.network:session():send_to_peers_synched("sync_interacted", self._unit, self._unit:id(), self.tweak_data, 3)
				end

				self._unit:brain():on_alarm_pager_interaction("complete", player)

				if alive(managers.interaction:active_unit()) then
					managers.interaction:active_unit():interaction():selected()
				end
			else
				managers.groupai:state():sync_alarm_pager_bluff()

				if managers.enemy:get_corpse_unit_data_from_key(self._unit:key()) then
					local u_id = managers.enemy:get_corpse_unit_data_from_key(self._unit:key()).u_id

					managers.network:session():send_to_host("alarm_pager_interaction", u_id, self.tweak_data, 3)
				else
					managers.network:session():send_to_host("sync_interacted", self._unit, self._unit:id(), self.tweak_data, 3)
				end
			end

			if tweak_data.achievement.nothing_to_see_here and managers.player:local_player() == player then
				local achievement_data = tweak_data.achievement.nothing_to_see_here
				local achievement = "nothing_to_see_here"
				local memory = managers.job:get_memory(achievement, true)
				local t = Application:time()
				local new_memory = {
					value = 1,
					time = t
				}

				if memory then
					table.insert(memory, new_memory)

					for i = #memory, 1, -1 do
						if achievement_data.timer <= t - memory[i].time then
							table.remove(memory, i)
						end
					end
				else
					memory = {
						new_memory
					}
				end

				managers.job:set_memory(achievement, memory, true)

				local total_memory_value = 0

				for _, m_data in ipairs(memory) do
					total_memory_value = total_memory_value + m_data.value
				end

				if achievement_data.total_value <= total_memory_value then
					managers.achievment:award(achievement_data.award)
				end
			end

			self:remove_interact()
		elseif self.tweak_data == "corpse_dispose" then
			managers.player:set_carry("person", 0)
			managers.player:on_used_body_bag()

			local u_id = managers.enemy:get_corpse_unit_data_from_key(self._unit:key()).u_id

			if Network:is_server() then
				self:remove_interact()
				self:set_active(false, true)
				self._unit:set_slot(0)
				managers.network:session():send_to_peers_synched("remove_corpse_by_id", u_id, true, managers.network:session():local_peer():id())
				managers.player:register_carry(managers.network:session():local_peer(), "person")
			else
				managers.network:session():send_to_host("sync_interacted_by_id", u_id, self.tweak_data)
				player:movement():set_carry_restriction(true)
			end

			managers.mission:call_global_event("player_pickup_bodybag")
			managers.custom_safehouse:award("corpse_dispose")
		elseif self._tweak_data.dont_need_equipment and not has_equipment then
			self:set_active(false)
			self._unit:brain():on_tied(player, true)
		elseif self.tweak_data == "hostage_trade" then
			self._unit:brain():on_trade(player:position(), player:rotation(), true)

			if managers.blackmarket:equipped_mask().mask_id == tweak_data.achievement.relation_with_bulldozer.mask then
				managers.achievment:award_progress(tweak_data.achievement.relation_with_bulldozer.stat)
			end

			managers.statistics:trade({
				name = self._unit:base()._tweak_table
			})
		elseif self.tweak_data == "hostage_convert" then
			if Network:is_server() then
				self:remove_interact()
				self:set_active(false, true)
				managers.groupai:state():convert_hostage_to_criminal(self._unit)
			else
				managers.network:session():send_to_host("sync_interacted", self._unit, self._unit:id(), self.tweak_data, 1)
			end
		elseif self.tweak_data == "hostage_move" then
			if Network:is_server() then
				if self._unit:brain():on_hostage_move_interaction(player, "move") then
					self:remove_interact()
				end
			else
				managers.network:session():send_to_host("sync_interacted", self._unit, self._unit:id(), self.tweak_data, 1)
			end
		elseif self.tweak_data == "hostage_stay" then
			if Network:is_server() then
				if self._unit:brain():on_hostage_move_interaction(player, "stay") then
					self:remove_interact()
				end
			else
				managers.network:session():send_to_host("sync_interacted", self._unit, self._unit:id(), self.tweak_data, 1)
			end
		else
			self:remove_interact()
			self:set_active(false)
			player:sound():play("cable_tie_apply")
			self._unit:brain():on_tied(player, false, not managers.player:has_team_category_upgrade("player","civilian_hostage_no_fleeing"))
		end
	end
		
		--[[
	function SecurityCameraInteractionExt:check_interupt()
		if not managers.player:has_category_upgrade("player","tape_loop_amount_unlimited") or alive(SecurityCamera.active_tape_loop_unit) then
			return true
		end

		return SecurityCameraInteractionExt.super.check_interupt(self)
	end

	function SecurityCameraInteractionExt:_interact_blocked(player)
		if not managers.player:has_category_upgrade("player","tape_loop_amount_unlimited") or alive(SecurityCamera.active_tape_loop_unit) then
			return true, nil, "tape_loop_limit_reached"
		end

		return false
	end
--]]
	
end

