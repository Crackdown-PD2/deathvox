--[[
local ids_material = Idstring("material")

local is_PS3 = SystemInfo:platform() == Idstring("PS3")
local is_win32 = SystemInfo:platform() == Idstring("WIN32")

local ids_contour_color = Idstring("contour_color")
local ids_contour_opacity = Idstring("contour_opacity")
--]]

if deathvox:IsTotalCrackdownEnabled() then 

	function BaseInteractionExt:_get_timer()
		local modified_timer = self:_get_modified_timer()

		if modified_timer then
			return modified_timer
		end

		local multiplier = 1

		
		if self.tweak_data == "corpse_dispose" then
			multiplier = multiplier * managers.player:upgrade_value("player", "burglar_body_interaction_speed_mul",1)
		elseif self.tweak_data == "corpse_alarm_pager" then
			multiplier = multiplier * managers.player:upgrade_value("player", "burglar_pager_interaction_speed_mul",1)
		else
			multiplier = multiplier * managers.player:crew_ability_upgrade_value("crew_interact", 1)
			multiplier = multiplier * managers.player:team_upgrade_value("crewchief","passive_interaction_speed_multiplier",1)
			
			if managers.groupai:state():whisper_mode() then
				multiplier = multiplier * managers.player:upgrade_value("player", "burglar_stealth_interaction_speed_mul",1)
			end
		end

		if self.tweak_data == "hostage_convert" then 
			local brain = self._unit:brain()
			if brain and brain.is_tied and brain:is_tied() then 
				return 0.01
			end
		end

		if self._tweak_data.upgrade_timer_multiplier then
			multiplier = multiplier * managers.player:upgrade_value(self._tweak_data.upgrade_timer_multiplier.category, self._tweak_data.upgrade_timer_multiplier.upgrade, 1)
		end

		if self._tweak_data.upgrade_timer_multipliers then
			for _, upgrade_timer_multiplier in pairs(self._tweak_data.upgrade_timer_multipliers) do
				multiplier = multiplier * managers.player:upgrade_value(upgrade_timer_multiplier.category, upgrade_timer_multiplier.upgrade, 1)
			end
		end

		if managers.player:has_category_upgrade("player", "level_interaction_timer_multiplier") then
			local data = managers.player:upgrade_value("player", "level_interaction_timer_multiplier") or {}
			local player_level = managers.experience:current_level() or 0
			multiplier = multiplier * (1 - (data[1] or 0) * math.ceil(player_level / (data[2] or 1)))
		end

		if self._tweak_data.is_snip then 
			local melee_entry = managers.blackmarket and managers.blackmarket:equipped_melee_weapon() 
			local melee_td = melee_entry and tweak_data.blackmarket.melee_weapons[melee_entry]
			if melee_td and melee_td.interact_cut_faster then 
				multiplier = multiplier * melee_td.interact_cut_faster
			end
		end

		return self:_timer_value() * multiplier * managers.player:toolset_value()
	end

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
		
		return
	end
	
	function SentryGunInteractionExt:interact(player)
		SentryGunInteractionExt.super.super.interact(self, player)
		return self._unit:base():on_interaction()
	end
	
--	function SentryGunInteractionExt:can_interact(...)
--		return SentryGunInteractionExt.super.super.can_interact(self, ...) and not SentryControlMenu:IsMenuActive()
--	end

	function SentryGunInteractionExt:can_select(...)
		return SentryGunInteractionExt.super.super.can_select(self, ...) and not SentryControlMenu:IsMenuActive()
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
		local has_deployable = self:_has_required_deployable()
		
		if self._tweak_data.equipment_consume and has_equipment then
			managers.player:remove_special(self._tweak_data.special_equipment)
		end

		if has_deployable and self._tweak_data.required_deployable and self._tweak_data.deployable_consume then
			managers.player:remove_equipment(self._tweak_data.required_deployable,self._tweak_data.slot or 1)
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
		
	function IntimitateInteractionExt:_interact_blocked(player)
		
		local player_manager = managers.player
		
		if self.tweak_data == "corpse_dispose" then
			if player_manager:is_carrying() then
				return true
			end

			if player_manager:chk_body_bags_depleted() then
				return true, nil, "body_bag_limit_reached"
			end

			local has_upgrade = player_manager:has_category_upgrade("player", "corpse_dispose")

			if not has_upgrade then
				return true
			end

			return not player_manager:can_carry("person")
		elseif self.tweak_data == "hostage_convert" then
			return not player_manager:has_category_upgrade("player", "convert_enemies") or player_manager:chk_minion_limit_reached() or managers.groupai:state():whisper_mode() or not self:_has_required_deployable()
		elseif self.tweak_data == "hostage_move" then
			if not self._unit:anim_data().tied then
				return true
			end

			local following_hostages = managers.groupai:state():get_following_hostages(player)
			local max_nr = player:base():upgrade_level("player", "falseidol_aced_followers") and 3 or 1

			if following_hostages and max_nr <= table.size(following_hostages) then
--				log("a")
				return true, nil, "hint_hostage_follow_limit"
			end
		elseif self.tweak_data == "hostage_stay" then
			return not self._unit:anim_data().stand or self._unit:anim_data().to_idle
		end
	end
	
	function SecurityCameraInteractionExt:check_interupt()
		if not SecurityCamera.can_start_new_tape_loop(self._unit) then
			return true
		end

		return SecurityCameraInteractionExt.super.check_interupt(self)
	end

	function SecurityCameraInteractionExt:_interact_blocked(player)
		if not SecurityCamera.can_start_new_tape_loop(self._unit) then
			return true, nil, "tape_loop_limit_reached"
		end

		return false
	end
	
	
	function MissionDoorDeviceInteractionExt:server_place_mission_door_device(player, sender)
		local can_place = not self._unit:mission_door_device() or self._unit:mission_door_device():can_place()

		if sender then
			sender:result_place_mission_door_device(self._unit, can_place)
		else
			self:result_place_mission_door_device(can_place)
		end

		local network_session = managers.network:session()

		self:remove_interact()

		local is_saw = self._unit:base() and self._unit:base().is_saw
		local is_drill = self._unit:base() and self._unit:base().is_drill

		if is_saw or is_drill then
			local user_unit = nil

			if player and player:base() and not player:base().is_local_player then
				user_unit = player
			end

			local upgrades = Drill.get_upgrades(self._unit, user_unit)

			self._unit:base():set_skill_upgrades(upgrades)
			network_session:send_to_peers_synched("sync_drill_upgrades", self._unit, upgrades.auto_repair_level, upgrades.shock_trap, upgrades.speed_upgrade_level, upgrades.silent_drill, upgrades.reduced_alert)
		end

		if self._unit:damage() then
			self._unit:damage():run_sequence_simple("interact", {
				unit = player
			})
		end

		network_session:send_to_peers_synched("sync_interacted", self._unit, -2, self.tweak_data, 1)
		self:set_active(false)
		self:check_for_upgrade()

		if self._unit:mission_door_device() then
			self._unit:mission_door_device():placed()
		end

		if self._tweak_data.sound_event then
			player:sound():play(self._tweak_data.sound_event)
		end

		return can_place
	end
	
end

