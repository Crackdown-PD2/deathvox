local destroy_original = MissionDoor.destroy
function MissionDoor:destroy(...)
	MissionDoor.super.destroy(self, ...)
	destroy_original(self, ...)
end
