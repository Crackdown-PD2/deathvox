if not ModCore then
	log("[ERROR] Unable to find ModCore from BeardLib! Is BeardLib installed correctly?")
	return
end
DeathVox = DeathVox or class(ModCore)

function DeathVox:init()
	self.super.init(self, ModPath .. "config.xml", true, true)
end
