function BowWeaponBase:init(unit)
	BowWeaponBase.super.init(self, unit)

	self._client_authoritative = true
	self._no_reload = managers.player:has_category_upgrade("weapon","bow_instant_ready")
	self._homing_arrows = managers.player:has_category_upgrade("weapon","homing_bolts")
	self._steelsight_speed = 0.5
end

function CrossbowWeaponBase:init(unit)
	CrossbowWeaponBase.super.init(self, unit)

	self._client_authoritative = true
	self._should_reload_immediately = true
	self._piercer_bolts = managers.player:has_category_upgrade("weapon", "crossbow_piercer")
	
	if managers.player:has_category_upgrade("weapon","xbow_headshot_instant_reload") then 
		self._should_reload_immediately = false
	end
end

function CrossbowWeaponBase:should_reload_immediately()
	return self._should_reload_immediately
end