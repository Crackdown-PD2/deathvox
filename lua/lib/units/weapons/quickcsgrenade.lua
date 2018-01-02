function QuickCsGrenade:_setup_from_tweak_data()
	local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
	local difficulty_index = tweak_data:difficulty_to_index(difficulty)
	local grenade_entry = self._tweak_projectile_entry or "cs_grenade_quick"
	self._tweak_data = tweak_data.projectiles[grenade_entry]
	self._radius = self._tweak_data.radius or 300
	self._radius_blurzone_multiplier = self._tweak_data.radius_blurzone_multiplier or 1.3
	self._damage_per_tick = 1
	self._damage_tick_period = self._tweak_data.damage_tick_period or 0.25
end

function QuickCsGrenade:update(unit, t, dt)
	local current_time = TimerManager:game():time()
	if not self._remove_t then
		self._remove_t =  current_time + _G.deathvox.grenadier_gas_duration
	end
	if self._remove_t and self._remove_t < current_time then
		managers.network:session():send_to_peers_synched("sync_cs_grenade_kill")
		managers.groupai:state()._cs_grenade = nil
		self._unit:set_slot(0)
	end

	if self._state == 1 then
		self._timer = self._timer - dt

		if self._timer <= 0 then
			self._timer = self._timer + 0.5
			self._state = 2

			self:_play_sound_and_effects()
		end
	elseif self._state == 2 then
		self._timer = self._timer - dt

		if self._timer <= 0 then
			self._state = 3

			self:detonate()
		end
	elseif self._state == 3 and (not self._last_damage_tick or self._last_damage_tick + self._damage_tick_period < t) then
		self:_do_damage()

		self._last_damage_tick = t
	end
end