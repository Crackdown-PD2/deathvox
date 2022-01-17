core:module("UserManager")

Hooks:PostHook(GenericUserManager, "setup_setting_map", "cd_init", function(self)
	self:setup_setting(400, "hold_to_jump", false) --keep this here, it won't do anything, but will add compatibility with hh
	self:setup_setting(401, "staticrecoil", false)
	self:setup_setting(402, "holdtofire", false)
end)

Hooks:PostHook(GenericUserManager, "reset_controls_setting_map", "CD_reset_controls_setting_map", function(self)
	self:set_setting("hold_to_jump", self:get_default_setting("hold_to_jump"))
	self:set_setting("staticrecoil", self:get_default_setting("staticrecoil"))
	self:set_setting("holdtofire", self:get_default_setting("holdtofire"))
end)

Hooks:PostHook(GenericUserManager, "sanitize_settings", "CD_sanitize_settings", function(self)
	local setting = self:get_setting("hold_to_jump")
	local setting_valid = setting == false or setting == true

	if not setting_valid then
		self:set_setting("hold_to_jump", false)
	end
	
	local setting = self:get_setting("staticrecoil")
	local setting_valid = setting == false or setting == true

	if not setting_valid then
		self:set_setting("staticrecoil", false)
	end
	
	local setting = self:get_setting("holdtofire")
	local setting_valid = setting == false or setting == true

	if not setting_valid then
		self:set_setting("holdtofire", false)
	end
end)