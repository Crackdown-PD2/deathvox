function TeamAIBrain:post_init()
	self:_reset_logic_data()

	local my_key = tostring(self._unit:key())

	self._unit:character_damage():add_listener("TeamAIBrain_hurt" .. my_key, {
		"concussion",
		"bleedout",
		"hurt",
		"light_hurt",
		"heavy_hurt",
		"fatal",
		"none"
	}, callback(self, self, "clbk_damage"))
	self._unit:character_damage():add_listener("TeamAIBrain_death" .. my_key, {
		"death"
	}, callback(self, self, "clbk_death"))
	managers.groupai:state():add_listener("TeamAIBrain" .. my_key, {
		"enemy_weapons_hot"
	}, callback(self, self, "clbk_heat"))

	if not self._current_logic then
		self:set_init_logic("idle")
	end

	self:_setup_attention_handler()

	self._alert_listen_key = "TeamAIBrain" .. my_key
	local alert_listen_filter = managers.groupai:state():get_unit_type_filter("combatant")
	local alert_types = {
		explosion = true,
		fire = true,
		aggression = true,
		bullet = true
	}

	managers.groupai:state():add_alert_listener(self._alert_listen_key, callback(self, self, "on_alert"), alert_listen_filter, alert_types, self._unit:movement():m_head_pos())
end
