if deathvox:IsTotalCrackdownEnabled() then 
	function Drill.get_upgrades(drill_unit, player)
		local is_drill = drill_unit:base() and drill_unit:base().is_drill
		local is_saw = drill_unit:base() and drill_unit:base().is_saw
		local upgrades = nil

		if is_drill or is_saw then
			local player_skill = PlayerSkill
			upgrades = {
				auto_repair_level_1 = player_skill.skill_level("player", "drill_autorepair_1", 0, player),
				auto_repair_level_2 = player_skill.skill_level("player", "drill_autorepair_2", 0, player),
				speed_upgrade_level = player_skill.skill_level("player", "drill_speed_multiplier", 0, player),
				silent_drill = player_skill.has_skill("player", "silent_drill", player),
				reduced_alert = player_skill.has_skill("player", "drill_alert_rad", player),
				shock_trap = player_skill.skill_level("player","drill_shock_trap",0,player)
			}
		end

		return upgrades
	end


	function Drill:on_melee_hit(peer_id)
		if self._disable_upgrades then
			return
		end

		if self._jammed and not self._has_done_melee_restart then
			self._has_done_melee_restart = true
			self._unit:timer_gui():set_jammed(false)
			self._unit:interaction():set_active(false, true)
			self._unit:interaction():check_for_upgrade()

			if self._kickstarter_success_sequence then
				self._unit:damage():run_sequence_simple(self._kickstarter_success_sequence)
			end
			--disabled random chance check
		end
	end

	function Drill:set_skill_upgrades(upgrades)
		if self._disable_upgrades then
			return
		end
		
		local background_icons = {}
		local timer_gui_ext = self._unit:timer_gui()
		local background_icon_template = {
			texture = "guis/textures/pd2/skilltree/",
			alpha = 1,
			h = 128,
			y = 100,
			w = 128,
			x = 30,
			layer = 2
		}
		local background_icon_x = 30

		local function add_bg_icon_func(bg_icon_table, texture_name, color)
			local icon_data = deep_clone(background_icon_template)
			icon_data.texture = icon_data.texture .. texture_name
			icon_data.color = color
			icon_data.x = background_icon_x

			table.insert(bg_icon_table, icon_data)

			background_icon_x = background_icon_x + icon_data.w + 2
		end

		if self.is_drill or self.is_saw then
			local drill_speed_multiplier = tweak_data.upgrades.values.player.drill_speed_multiplier
			local drill_alert_rad = tweak_data.upgrades.values.player.drill_alert_rad[1]
			local current_speed_upgrade = self._skill_upgrades.speed_upgrade_level or 0
			local timer_multiplier = 1

			if upgrades.speed_upgrade_level and upgrades.speed_upgrade_level >= 2 or current_speed_upgrade >= 2 then
				timer_multiplier = drill_speed_multiplier[2]

				add_bg_icon_func(background_icons, "drillgui_icon_faster", timer_gui_ext:get_upgrade_icon_color("upgrade_color_2"))

				upgrades.speed_upgrade_level = 2
			elseif upgrades.speed_upgrade_level and upgrades.speed_upgrade_level >= 1 or current_speed_upgrade >= 1 then
				timer_multiplier = drill_speed_multiplier[1]

				add_bg_icon_func(background_icons, "drillgui_icon_faster", timer_gui_ext:get_upgrade_icon_color("upgrade_color_1"))

				upgrades.speed_upgrade_level = 1
			else
				add_bg_icon_func(background_icons, "drillgui_icon_faster", timer_gui_ext:get_upgrade_icon_color("upgrade_color_0"))

				upgrades.speed_upgrade_level = 0
			end

			local got_reduced_alert = upgrades.reduced_alert or false
			local current_reduced_alert = self._skill_upgrades.reduced_alert or false
			local got_silent_drill = upgrades.silent_drill or false
			local current_silent_drill = self._skill_upgrades.silent_drill or false
			local auto_repair_level_1 = upgrades.auto_repair_level_1 or 0
			local auto_repair_level_2 = upgrades.auto_repair_level_2 or 0
			local current_auto_repair_level_1 = self._skill_upgrades.auto_repair_level_1 or 0
			local current_auto_repair_level_2 = self._skill_upgrades.auto_repair_level_2 or 0

			timer_gui_ext:set_timer_multiplier(timer_multiplier)

			if got_silent_drill or current_silent_drill then
				self:set_alert_radius(nil)
				timer_gui_ext:set_skill(BaseInteractionExt.SKILL_IDS.aced)

				upgrades.silent_drill = true
				upgrades.reduced_alert = true

				add_bg_icon_func(background_icons, "drillgui_icon_silent", timer_gui_ext:get_upgrade_icon_color("upgrade_color_2"))
			elseif got_reduced_alert or current_reduced_alert then
				self:set_alert_radius(drill_alert_rad)
				timer_gui_ext:set_skill(BaseInteractionExt.SKILL_IDS.basic)

				upgrades.reduced_alert = true

				add_bg_icon_func(background_icons, "drillgui_icon_silent", timer_gui_ext:get_upgrade_icon_color("upgrade_color_1"))
			else
				self:set_alert_radius(tweak_data.upgrades.drill_alert_radius or 2500)
				timer_gui_ext:set_skill(BaseInteractionExt.SKILL_IDS.none)
				add_bg_icon_func(background_icons, "drillgui_icon_silent", timer_gui_ext:get_upgrade_icon_color("upgrade_color_0"))
			end
			local do_set_autorepair
			if auto_repair_level_1 > 0 or current_auto_repair_level_1 > 0 or auto_repair_level_2 > 0 or current_auto_repair_level_2 > 0 then
				
				upgrades.auto_repair_level_1 = current_auto_repair_level_1
				upgrades.auto_repair_level_2 = current_auto_repair_level_2
				local drill_autorepair_chance = 0

				if current_auto_repair_level_1 < auto_repair_level_1 then
					current_auto_repair_level_1 = auto_repair_level_1
					upgrades.auto_repair_level_1 = auto_repair_level_1
				end

				if current_auto_repair_level_2 < auto_repair_level_2 then
					current_auto_repair_level_2 = auto_repair_level_2
					upgrades.auto_repair_level_2 = auto_repair_level_2
				end

				if current_auto_repair_level_1 > 0 then
					drill_autorepair_chance = drill_autorepair_chance + tweak_data.upgrades.values.player.drill_autorepair_2[1]
				end

				if current_auto_repair_level_2 > 0 then
					drill_autorepair_chance = drill_autorepair_chance + tweak_data.upgrades.values.player.drill_autorepair_1[1]
				end
				
				
				if Network:is_server() then
					do_set_autorepair = true
					
					--removed rng check
				end

				add_bg_icon_func(background_icons, "drillgui_icon_restarter", timer_gui_ext:get_upgrade_icon_color("upgrade_color_1"))
			else
				add_bg_icon_func(background_icons, "drillgui_icon_restarter", timer_gui_ext:get_upgrade_icon_color("upgrade_color_0"))
			end
			self._skill_upgrades = deep_clone(upgrades)
			
			if do_set_autorepair then --moved this down here along with a check so that the skill upgrades can apply first
				self:set_autorepair(true)
			end
		end

		timer_gui_ext:set_background_icons(background_icons)
		timer_gui_ext:update_sound_event()
	end

	function Drill:set_jammed(jammed)
		jammed = jammed and true or false

		if self._jammed == jammed then
			return
		end

		self._jammed = jammed

		if self._jammed then
			self._jammed_count = self._jammed_count + 1

			self:_kill_drill_effect()

			if self._use_effect then
				local params = {
					effect = Idstring("effects/payday2/environment/drill_jammed"),
					parent = self._unit:get_object(Idstring("e_drill_particles"))
				}
				self._jammed_effect = World:effect_manager():spawn(params)
			end

			self:_reset_melee_autorepair()
			local drill_autorepair_delay = self._autorepair
			if drill_autorepair_delay and not (self._autorepair_clbk_id or self._has_done_guaranteed_autorepair) then --check for has done autorepair flag
				self._autorepair_clbk_id = "Drill_autorepair" .. tostring(self._unit:key())
				managers.enemy:add_delayed_clbk(self._autorepair_clbk_id, callback(self, self, "clbk_autorepair"), TimerManager:game():time() + drill_autorepair_delay)
			end
		elseif self._jammed_effect then
			self:_kill_jammed_effect()
			self:_start_drill_effect()

			if not self.is_hacking_device and not self.is_saw and not managers.groupai:state():whisper_mode() then
				managers.groupai:state():teammate_comment(nil, "g22", self._unit:position(), true, 500, false)
			end

			if self._autorepair_clbk_id then
				managers.enemy:remove_delayed_clbk(self._autorepair_clbk_id)

				self._autorepair_clbk_id = nil
			end

			if self._bain_report_sabotage_clbk_id then
				managers.enemy:remove_delayed_clbk(self._bain_report_sabotage_clbk_id)

				self._bain_report_sabotage_clbk_id = nil
			end
		end

		self:_change_num_jammed_drills(self._jammed and 1 or -1)

		if Network:is_server() then
			if jammed then
				self:_unregister_sabotage_SO()
			else
				self:_register_sabotage_SO()
			end
		end
	end


	function Drill:set_autorepair(state)

		local autorepair_upgrade_tier = 0
		if self._skill_upgrades.auto_repair_level_2 then
			autorepair_upgrade_tier = 2
		elseif self._skill_upgrades.auto_repair_level_1 then
			autorepair_upgrade_tier = 1
		end
		local drill_autorepair_delay = autorepair_upgrade_tier and tweak_data.upgrades.values.player.drill_auto_repair_guaranteed[autorepair_upgrade_tier]
		
		if not drill_autorepair_delay then
			return
		end
		
		if state and drill_autorepair_delay > 0 then 
			self._autorepair = drill_autorepair_delay
		else
			self._autorepair = state
		end

		if state then
			if self._jammed and not self._autorepair_clbk_id then
				if self._has_done_guaranteed_autorepair then
					--check for flag so that this can only happen once
					return
				end
				
				self._autorepair_clbk_id = "Drill_autorepair" .. tostring(self._unit:key())

				managers.enemy:add_delayed_clbk(self._autorepair_clbk_id, callback(self, self, "clbk_autorepair"), TimerManager:game():time() + drill_autorepair_delay)
			end
		elseif self._autorepair_clbk_id then
			managers.enemy:remove_delayed_clbk(self._autorepair_clbk_id)

			self._autorepair_clbk_id = nil
		end
	end

	function Drill:clbk_autorepair()
		self._autorepair_clbk_id = nil

		if alive(self._unit) then
			self._has_done_guaranteed_autorepair = true --add flag since this can only happen once
			self._unit:timer_gui():set_jammed(false)
			self._unit:interaction():set_active(false, true)
		end
	end



	do return end


	function Drill:on_sabotage_SO_started(saboteur)
		if not self._saboteur or self._saboteur:key() ~= saboteur:key() then
--			debug_pause_unit(self._unit, "[Drill:on_sabotage_SO_started] wrong saboteur", self._unit, saboteur, self._saboteur)
		end

		self._saboteur = nil
		
		if true then  --if self._skill_upgrades.static_defense then --(not checked/synced yet)
			return
		end
		

		self._unit:timer_gui():set_jammed(true)

		if not self._bain_report_sabotage_clbk_id then
			self._bain_report_sabotage_clbk_id = "Drill_bain_report_sabotage" .. tostring(self._unit:key())

			managers.enemy:add_delayed_clbk(self._bain_report_sabotage_clbk_id, callback(self, self, "clbk_bain_report_sabotage"), TimerManager:game():time() + 2 + 4 * math.random())
		end
	end

	--Hooks:PostHook(Drill,"_unregister_sabotage_SO","blarghlblargh",function(self,...)
	--	Log("Unregistered from sabotage " .. tostring(self._unit))
	--	Log(tostring(debug.traceback()))
	--end)

	function Drill:on_sabotage_SO_completed(saboteur)
		if true then  --if self._skill_upgrades.static_defense then --(not checked/synced yet)
			local attack_data = {
				damage = 0,
				variant = "bullet",
				pos = mvector3.copy(self._unit:position()),
				attack_dir = Vector3(0,0,0),
				attacker_unit = managers.player:local_player(),
				result = {
					variant = "bullet",
					type = "taser_tased"
				}
			}
			saboteur:character_damage():_call_listeners(attack_data)
		end
		self._saboteur = nil
	end

end