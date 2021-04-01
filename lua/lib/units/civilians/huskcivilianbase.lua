local sync_net_event_original = HuskCivilianBase.sync_net_event
function HuskCivilianBase:sync_net_event(event_id)
	if event_id == 3 then
		managers.groupai:state():on_hostage_follow(nil, self._unit, true)

		return
	end

	sync_net_event_original(self, event_id)
end
