if deathvox:IsTotalCrackdownEnabled() then

	Hooks:PostHook(TeamAIDamage,"init","tcd_teamaidamage_check_bleed_out2",function(self)
		self:add_listener("tcd_biker_check_bleedout",{"bleedout"},
			function()
				Hooks:Call("TCD_OnCriminalDowned","local_ai",self,"bleed_out",self:down_time())
			end
		)
	end)
	
end