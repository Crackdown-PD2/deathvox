Hooks:PostHook(HostNetworkSession,"on_peer_sync_complete","deathvox_synchostplayer",function(self,peer,peer_id)
	deathvox:SyncOptionsToClient(peer_id)
end)