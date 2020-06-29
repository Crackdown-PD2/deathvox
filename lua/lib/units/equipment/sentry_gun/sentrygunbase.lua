function SentryGunBase:unregister()
	if self._registered then
		self._registered = nil
	end
end

function SentryGunBase:register()
	self._registered = true
end
