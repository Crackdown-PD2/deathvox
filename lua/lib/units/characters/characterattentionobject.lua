local fs_original_characterattentionobject_setsettingsset = CharacterAttentionObject.set_settings_set
function CharacterAttentionObject:set_settings_set(settings_set)
	fs_original_characterattentionobject_setsettingsset(self, settings_set)
	self.rel_cache = {}
end
