if deathvox:IsTotalCrackdownEnabled() then 

	local angle = 10 --angle that the icon will rotate in either direction
	local rotation_speed = 0.5 --rotation cycles per second
	local time_offset = 0.33 --seconds delay for the shadow bitmap
	local rotation_offset = 0 --degrees delay for the shadow bitmap (functionally the same as time_offset but by a different measure)
	local scanlines_speed = 10 --px/sec


	Hooks:PostHook(SpecializationTierItem,"init","tcd_perkdeckgui_create",function(self,tier_data, tree_panel, tree, tier, x, y, w, h)

		local td = tweak_data.skilltree.specializations[self._tree]
		if td.shake and alive(self._tier_panel) then 
			local tier_icon = self._tier_icon
			
			local texture,texture_rect
			--if only there was a nice function to do this like tweak_data.skilltree:get_specialization_icon_data() except allowing tier selection
			
			local tier_data = tier_data or self._tier_data
			local texture_rect_x = tier_data.icon_xy and tier_data.icon_xy[1] or 0
			local texture_rect_y = tier_data.icon_xy and tier_data.icon_xy[2] or 0
			local guis_catalog = "guis/"

			if tier_data.texture_bundle_folder then
				guis_catalog = guis_catalog .. "dlcs/" .. tostring(tier_data.texture_bundle_folder) .. "/"
			end

			texture = guis_catalog .. "textures/pd2/specialization/icons_atlas"
			texture_rect = {
				texture_rect_x * 64,
				texture_rect_y * 64,
				64,
				64
			}
			
			local tier_icon_shadow = self._tier_panel:bitmap({
				name = "tier_icon_shadow",
				texture = texture,
				texture_rect = texture_rect,
				halign = "scale",
				valign = "scale",
				rotation = rotation_offset,
				layer = 0,
				color = Color("000000"),
				alpha = 1/3
			})
			tier_icon_shadow:grow(-16,-16)
			tier_icon_shadow:set_center(self._tier_panel:w() / 2, self._tier_panel:h() / 2)
			tier_icon_shadow:move(0,4)
			self._tier_icon_shadow = tier_icon_shadow
			
			--the original card texture is roughly 64x92, scaled down by 16px (?)
			
			local tier_scanlines_w = 64 - 8
			local tier_scanlines_h = 92 - 8
			local tier_scanlines_panel = self._tier_panel:panel({
				name = "tier_scanlines_panel",
				w = tier_scanlines_w - 2,
				h = tier_scanlines_h,
				x = (self._tier_panel:w() - tier_scanlines_w) / 2,
				y = 5,
				layer = 4
			})
			local tier_scanlines = tier_scanlines_panel:bitmap({
				name = "tier_scanlines",
				texture = "guis/textures/pd2/damage_overlay_sociopath/scanlines_overlay",
				texture_rect = {
					0,math.random(360 - 92),1,92 + math.random(-4,4) --360 is the scanlines file height
				},
				x = 1,
				w = tier_scanlines_panel:w(),
				h = tier_scanlines_panel:h() * 2,
				y = -tier_scanlines_h,
				blend_mode = "add",
				halign = "scale",
				valign = "scale",
				alpha = 1/3,
				layer = 10
			})
			self._tier_scanlines = tier_scanlines
			self._tier_scanlines_panel = tier_scanlines_panel
			
		end
		
	end)

	local function lerp_rot(item,dt)
		local rotation = item:rotation()

		local lerp_rotation = math.lerp(rotation, 0, dt * 10)
		local step_rotation = math.step(rotation, 0, dt * 20)

		rotation = math.abs(rotation - lerp_rotation) < math.abs(rotation - step_rotation) and step_rotation or lerp_rotation

		item:set_rotation(rotation)
	end
					
	local orig_specializationtieritem_updatesize = SpecializationTierItem.update_size
	function SpecializationTierItem:update_size(dt, tree_selected, ...)
		--todo smooth rotation/revert rotation when deselected
		local size = {
			self._tier_panel:size()
		}
		local end_size = tree_selected and self._selected_size or self._basic_size
		local is_done = true
		local lerp_size, step_size = nil

		for i = 1, #size do
			lerp_size = math.lerp(size[i], end_size[i], dt * 10)
			step_size = math.step(size[i], end_size[i], dt * 20)
			size[i] = math.abs(size[i] - lerp_size) < math.abs(size[i] - step_size) and step_size or lerp_size

			if is_done and size[i] ~= end_size[i] then
				is_done = false
			end
		end

		local cx, cy = self._tier_panel:center()

		self._tier_panel:set_size(unpack(size))
		self._tier_panel:set_center(cx, cy)
		self._select_box_panel:set_center(self._tier_panel:w() / 2, self._tier_panel:h() / 2)
		
		local td = tweak_data.skilltree.specializations[self._tree]
		if td.shake then
			if not self._rotation_start_t then
				self._rotation_start_t = Application:time()
			end
			
			local t = Application:time() - self._rotation_start_t
			
			local tier_scanlines = self._tier_scanlines
			if alive(tier_scanlines) then 
				local scanline_y = tier_scanlines:y() + (dt * scanlines_speed)
				if scanline_y >= 0 then 
					tier_scanlines:set_y(-self._tier_scanlines_panel:h())
				else
					tier_scanlines:set_y(scanline_y)
				end
				tier_scanlines:set_visible(tree_selected)
				self._tier_scanlines_panel:set_x((self._tier_panel:w() - self._tier_scanlines_panel:w()) / 2)
			end
			
			if alive(self._tier_icon) and alive(self._tier_icon_shadow) then 
				if tree_selected then 
					self._tier_icon:set_rotation(math.sin(t * 360 * rotation_speed) * angle)
					self._tier_icon_shadow:set_rotation(math.sin((t - time_offset) * 360 * rotation_speed) * angle)
					return false
				else
					lerp_rot(self._tier_icon,dt)
					lerp_rot(self._tier_icon_shadow,dt)
					
					self._rotation_start_t = nil
				end
			end
			
		else
			return orig_specializationtieritem_updatesize(self,dt,tree_selected,...)
		end
	end
	
end