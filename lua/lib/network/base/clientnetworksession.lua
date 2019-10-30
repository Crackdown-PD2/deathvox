Hooks:PostHook(ClientNetworkSession,"on_peer_synched","deathvox_syncclientplayer",function(self,peer_id)
	deathvox:SyncOptionsToClient(peer_id)
end)