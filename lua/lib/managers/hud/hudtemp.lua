if deathvox:IsTotalCrackdownEnabled() then 
	Hooks:PostHook(HUDTemp,"init","tcd_init",function(self,hud)
		Hooks:Call("TCD_Create_Stack_Tracker_HUD",hud.panel)
	end)
end