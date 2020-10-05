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
		
	end
end)