local destroy_original = AnimatedVehicleBase.destroy
function AnimatedVehicleBase:destroy(...)
	AnimatedVehicleBase.super.destroy(self, ...)
	destroy_original(self, ...)
end
