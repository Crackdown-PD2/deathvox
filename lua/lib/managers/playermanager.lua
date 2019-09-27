Hooks:PostHook(PlayerManager,"_internal_load","deathvox_on_internal_load",function(self)
	if LuaNetworking:IsHost() or not LuaNetworking:IsMultiplayer() then 
		deathvox:SyncOptionsToClients()
	else
		deathvox:ResetSessionSettings()
	end
end)
