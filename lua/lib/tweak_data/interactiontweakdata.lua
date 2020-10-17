Hooks:PostHook(InteractionTweakData, "init", "cd_interact_timer_stuff", function(self, tweak_data)
	if deathvox:IsTotalCrackdownEnabled() then
		self.take_pardons.timer = 0		
		self.take_pardons.sound_start = "money_grab"	
		self.take_pardons.sound_event = "money_grab"	
		self.take_pardons.sound_done = "money_grab"			
		self.gage_assignment.timer = 0		
		self.gage_assignment.sound_start = "money_grab"	
		self.gage_assignment.sound_event = "money_grab"	
		self.gage_assignment.sound_done = "money_grab"	
		
		
		self.sentry_gun.upgrade_timer_multipliers = {
			{
				upgrade = "interaction_speed_multiplier",
				category = "sentry_gun"
			}
		}
		self.sentry_gun_fire_mode.requires_upgrade = nil --remove ap skill requirement for toggling sentry firemode/ammotype
		
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
		
		
	end
	
end)