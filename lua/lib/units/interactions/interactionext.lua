--[[
local ids_material = Idstring("material")

local is_PS3 = SystemInfo:platform() == Idstring("PS3")
local is_win32 = SystemInfo:platform() == Idstring("WIN32")

local ids_contour_color = Idstring("contour_color")
local ids_contour_opacity = Idstring("contour_opacity")
--]]

if deathvox:IsTotalCrackdownEnabled() then 

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

