
Hooks:PostHook(HintManager,"init","crackdown_hintmanager_init",function(self)
	self:_parse_hint({
		id = "already_has_armor_plates",
		text_id = "hint_hud_already_has_armor_plates",
		event = "stinger_feedback_negative",
		sync = false
	})
end)