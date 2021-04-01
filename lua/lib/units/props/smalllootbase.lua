local destroy_original = SmallLootBase.destroy
function SmallLootBase:destroy(...)
	SmallLootBase.super.destroy(self, ...)
	destroy_original(self, ...)
end
