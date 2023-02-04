if deathvox:IsTotalCrackdownEnabled() then
	Hooks:PostHook(HintManager,"init","crackdown_hintmanager_init",function(self)
		self:_parse_hint({
			id = "already_has_armor_plates",
			text_id = "hud_hint_already_has_armor_plates",
			event = "stinger_feedback_negative",
			sync = false
		})
		self:_parse_hint({
			id = "convert_enemy_failed_no_slots_count",
			text_id = "hud_hint_convert_enemy_failed_no_slots_count",
			event = "stinger_feedback_negative",
			sync = false
		})
		self:_parse_hint({
			id = "convert_enemy_failed_no_slots_generic",
			text_id = "hud_hint_convert_enemy_failed_no_slots_generic",
			event = "stinger_feedback_negative",
			sync = false
		})
		self:_parse_hint({
			id = "convert_enemy_failed_already_converted",
			text_id = "hud_hint_convert_enemy_failed_already_converted",
			event = "stinger_feedback_negative",
			sync = false
		})
	end)
end