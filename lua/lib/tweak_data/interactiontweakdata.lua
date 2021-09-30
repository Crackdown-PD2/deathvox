if deathvox:IsTotalCrackdownEnabled() then
	Hooks:PostHook(InteractionTweakData, "init", "tcd_interactiontweakdata_init", function(self, tweak_data)
		self.take_pardons.timer = 0		
		self.take_pardons.sound_start = "money_grab"	
		self.take_pardons.sound_event = "money_grab"	
		self.take_pardons.sound_done = "money_grab"			
		self.gage_assignment.timer = 0		
		self.gage_assignment.sound_start = "money_grab"	
		self.gage_assignment.sound_event = "money_grab"	
		self.gage_assignment.sound_done = "money_grab"	
		
		self.drill.upgrade_timer_multiplier = {
			upgrade = "drill_place_interaction_speed_multiplier",
			category = "player"
		}
		self.drill_upgrade.upgrade_timer_multiplier = {
			upgrade = "drill_upgrade_interaction_speed_multiplier",
			category = "player"
		}
		self.suburbia_drill.upgrade_timer_multiplier = {
			upgrade = "drill_place_interaction_speed_multiplier",
			category = "player"
		}
		self.suburbia_drill_jammed.upgrade_timer_multiplier = {
			upgrade = "drill_fix_interaction_speed_multiplier",
			category = "player"
		}
		self.apartment_drill_jammed.upgrade_timer_multiplier = {
			upgrade = "drill_fix_interaction_speed_multiplier",
			category = "player"
		}
		self.goldheist_drill.upgrade_timer_multiplier = {
			upgrade = "drill_place_interaction_speed_multiplier",
			category = "player"
		}
		self.goldheist_drill_jammed.upgrade_timer_multiplier = {
			upgrade = "drill_fix_interaction_speed_multiplier",
			category = "player"
		}
		self.huge_lance.upgrade_timer_multiplier = {
			upgrade = "drill_place_interaction_speed_multiplier",
			category = "player"
		}
		self.huge_lance_jammed.upgrade_timer_multiplier = {
			upgrade = "drill_fix_interaction_speed_multiplier",
			category = "player"
		}
		
		
		self.gen_int_saw_upgrade.upgrade_timer_multiplier = {
			upgrade = "drill_upgrade_interaction_speed_multiplier",
			category = "player"
		}
		self.secret_stash_saw.upgrade_timer_multiplier = {
			upgrade = "drill_place_interaction_speed_multiplier",
			category = "player"
		}
		self.apartment_saw.upgrade_timer_multiplier = {
			upgrade = "drill_place_interaction_speed_multiplier",
			category = "player"
		}
		self.hospital_saw.upgrade_timer_multiplier = {
			upgrade = "drill_place_interaction_speed_multiplier",
			category = "player"
		}
		self.gen_int_saw.upgrade_timer_multiplier = {
			upgrade = "drill_place_interaction_speed_multiplier",
			category = "player"
		}
		
		
		self.first_aid_kit.upgrade_timer_multipliers = {
			{
				upgrade = "interaction_speed_multiplier",
				category = "first_aid_kit"
			}
		}
		
		self.sentry_gun.upgrade_timer_multipliers = {
			{
				upgrade = "interaction_speed_multiplier",
				category = "sentry_gun"
			}
		}
		self.sentry_gun_fire_mode.requires_upgrade = nil --remove ap skill requirement for toggling sentry firemode/ammotype
		
		self.sentry_gun_vent_weapon_heat = {
			text_id = "hud_sentry_gun_vent_heat",
			action_text_id = "hud_action_sentry_gun_vent_heat",
			contour = "deployable",
			timer = 2,
			start_active = false
		}
		
		self.armor_plates = {
			icon = "equipment_armor_kit",
			text_id = "debug_interact_armor_plates_take",
			contour = "deployable",
			timer = 3.5,
			blocked_hint = "already_has_armor_plates",
			sound_start = "bar_helpup", --todo change the sound?
			sound_interupt = "bar_helpup_cancel",
			sound_done = "bar_helpup_finished",
			action_text_id = "hud_action_taking_armor_plates",
			upgrade_timer_multipliers = {
				{
					upgrade = "deploy_interact_faster",
					category = "player"
				}
			}
			
		}
		
		self.pick_lock_hard.upgrade_timer_multipliers = { 
			{
				upgrade = "pick_lock_hard_speed_multiplier",
				category = "player"
			}
			--[[
			--normal lockpick speed skills don't apply to safe locks... but they could
			,{
				upgrade = "pick_lock_easy_speed_multiplier",
				category = "player"
			}
			--]]
		}
		
		self.requires_ecm_jammer = {
			icon = "equipment_key_chain",
			contour = "interactable_icon",
			text_id = "hud_int_pick_electronic_lock",
			timer = 20,
			requires_upgrade = {
				upgrade = "can_hack_electronic_locks",
				category = "player"
			},
			action_text_id = "hud_action_picking_electronic_lock",
			sound_start = "bar_keyboard",
			sound_interupt = "bar_keyboard_cancel",
			sound_done = "bar_keyboard_finished",
			is_lockpicking = true
		}
		
		self.trip_mine.requires_upgrade = nil
		self.trip_mine.interact_distance = 2000
		self.shaped_sharge.timer = 1
		
		self.hospital_security_cable.is_snip = true
		self.hospital_security_cable_red.is_snip = true
		self.hospital_security_cable_blue.is_snip = true
		self.hospital_security_cable_green.is_snip = true
		self.hospital_security_cable_yellow.is_snip = true
		self.security_cable_grey.is_snip = true
		self.cut_fence.is_snip = true
		self.hold_cut_cable.is_snip = true
		self.hold_cut_wires.is_snip = true
		self.pex_cut_open_chains.is_snip = true
	end)
end
	