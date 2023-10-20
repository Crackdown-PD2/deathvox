Hooks:PostHook(NetworkTweakData,"init","deathvox_networktweakdata_init",function(self,tweak_data)
	self.player_tick_rate = 60				--orig 20
	self.look_direction_smooth_step = 32	--orig 16
end)