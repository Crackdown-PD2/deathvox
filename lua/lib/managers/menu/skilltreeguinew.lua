if deathvox:IsTotalCrackdownEnabled() then

	local small_font_size = tweak_data.menu.pd2_small_font_size
		
	function NewSkillTreeGui:_update_description(item)
		local desc_panel = self._panel:child("InfoRootPanel"):child("DescriptionPanel")
		local text = desc_panel:child("DescriptionText")
		local tier = item:tier()
		local skill_id = item:skill_id()
		local tweak_data_skill = tweak_data.skilltree.skills[skill_id]
		local skill_stat_color = tweak_data.screen_colors.resource
		local color_replace_table = {}
		local points = self._skilltree:points() or 0
		local basic_cost = self._skilltree:get_skill_points(skill_id, 1) or 0
		local pro_cost = self._skilltree:get_skill_points(skill_id, 2) or 0
		local talent = tweak_data.skilltree.skills[skill_id]
		local unlocked = self._skilltree:skill_unlocked(nil, skill_id)
		local step = self._skilltree:next_skill_step(skill_id)
		local completed = self._skilltree:skill_completed(skill_id)
		local skill_descs = tweak_data.upgrades.skill_descs[skill_id] or {
			0,
			0
		}
		local basic_color_index = 1
		local pro_color_index = 2 + (skill_descs[1] or 0)

		if step > 1 then
			basic_cost = utf8.to_upper(managers.localization:text("st_menu_skill_owned"))
			color_replace_table[basic_color_index] = tweak_data.screen_colors.resource
		else
			basic_cost = managers.localization:text(basic_cost == 1 and "st_menu_point" or "st_menu_point_plural", {
				points = basic_cost
			})
		end

		if step > 2 then
			pro_cost = utf8.to_upper(managers.localization:text("st_menu_skill_owned"))
			color_replace_table[pro_color_index] = tweak_data.screen_colors.resource
		else
			pro_cost = managers.localization:text(pro_cost == 1 and "st_menu_point" or "st_menu_point_plural", {
				points = pro_cost
			})
		end

		local macroes = {
			basic = basic_cost,
			pro = pro_cost
		}
		
		for _,v in pairs(deathvox.tcd_icon_chars) do  --just adds wpn class/subclass icon macros
			if v.macro and v.character then
				macroes[v.macro] = v.character
			end
		end
		
		for i, d in pairs(skill_descs) do
			macroes[i] = d
		end

		local skill_btns = tweak_data.upgrades.skill_btns[skill_id]

		if skill_btns then
			for i, d in pairs(skill_btns) do
				macroes[i] = d()
			end
		end
		
		local basic_cost = managers.skilltree:skill_cost(tier, 1)
		local aced_cost = managers.skilltree:skill_cost(tier, 2)
		local skill_string = managers.localization:to_upper_text(tweak_data_skill.name_id)
		local cost_string = managers.localization:to_upper_text(basic_cost == 1 and "st_menu_skill_cost_singular" or "st_menu_skill_cost", {
			basic = basic_cost,
			aced = aced_cost
		})
		local desc_string = managers.localization:text(tweak_data.skilltree.skills[skill_id].desc_id, macroes)
		local full_string = skill_string .. "\n\n" .. desc_string

		if (_G.IS_VR or managers.user:get_setting("show_vr_descs")) and tweak_data.vr.skill_descs_addons[skill_id] then
			local addon_data = tweak_data.vr.skill_descs_addons[skill_id]
			local vr_addon = managers.localization:text(addon_data.text_id, addon_data.macros)
			full_string = full_string .. "\n\n" .. managers.localization:text("menu_vr_skill_addon") .. "\n" .. vr_addon
		end

		text:set_text(full_string)
		managers.menu_component:make_color_text(text)
		text:set_font_size(small_font_size)

		local _, _, _, h = text:text_rect()

		while h > desc_panel:h() - text:top() do
			text:set_font_size(text:font_size() * 0.98)

			_, _, _, h = text:text_rect()
		end
	end

end