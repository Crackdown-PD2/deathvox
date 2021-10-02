--[[

Hooks:PostHook(SpecializationTierItem,"init","deathvox_tcd_correct_perkdeck_icons",function(self,tier_data, tree_panel, tree, tier, x, y, w, h)
	if alive(self._tier_icon) then 
		local texture,texture_rect = tweak_data.skilltree:get_specialization_icon_data_by_spec_and_tier(tree,tier,false)
		if texture_rect then 
			self._tier_icon:set_image(texture,unpack(texture_rect))
		end
	end
end)
--]]