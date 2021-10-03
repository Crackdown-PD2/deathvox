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
			layer = 0,
			color = Color("000000"),
			alpha = 1/3
		})
		tier_icon_shadow:grow(-16,-16)
		tier_icon_shadow:set_center(self._tier_panel:w() / 2, self._tier_panel:h() / 2)
		tier_icon_shadow:move(0,4)
		self._tier_icon_shadow = tier_icon_shadow
		
		local tier_scanlines_w = 64 - 8
		local tier_scanlines_h = 92 - 8
		local tier_scanlines = self._tier_panel:panel({
			name = "tier_scanlines",
			w = tier_scanlines_w,
			h = tier_scanlines_h,
			x = (self._tier_panel:w() - tier_scanlines_w) / 2,
			y = 5,
			layer = 4
		})
		local scanlines = tier_scanlines:bitmap({
			name = "scanlines",
			texture = "guis/textures/pd2/damage_overlay_sociopath/scanlines_overlay",
			texture_rect = {
				0,math.random(360 - 92),1,84 + math.random(16)
			},
			w = tier_scanlines:w(),
			h = tier_scanlines:h() * 2,
			y = -tier_scanlines_h,
			blend_mode = "add",
			halign = "scale",
			valign = "scale",
			alpha = 0.5,
			layer = 10
		})
		self._tier_scanlines = scanlines
		
	end
	
end)

local orig_specializationtieritem_updatesize = SpecializationTierItem.update_size
function SpecializationTierItem:update_size(dt, tree_selected, ...)
	--todo smooth rotation/revert rotation when deselected
--[[
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

	if not self._rotation_start_t then
		self._rotation_start_t = Application:time()
	end

	local tweak_data = tweak_data.skilltree.specializations[self._tree]
	if tweak_data.shake then
		if tree_selected then
			local time_since_start = Application:time() - self._rotation_start_t
			local rotation = math.sin(time_since_start * 100) * 10

			for _, child in pairs(self._tier_panel:children()) do
				if child.set_rotation then
					child:set_rotation(rotation)
				end
			end

			return false
		else
			for _, child in pairs(self._tier_panel:children()) do
				if child.set_rotation then
					local rotation = child:rotation()
					local lerp_rotation = math.lerp(rotation, 0, dt * 10)
					local step_rotation = math.step(rotation, 0, dt * 20)
					rotation = math.abs(rotation - lerp_rotation) < math.abs(rotation - step_rotation) and step_rotation or lerp_rotation

					child:set_rotation(rotation)
				end
			end

			self._rotation_start_t = nil
		end
	end

	--]]
	local td = tweak_data.skilltree.specializations[self._tree]
	if td.shake then
		local t = Application:time()
		local rotation_delay = 0.33 --seconds
		local angle = 10
		local scanlines_speed = 10 --px/sec
		local rotation_speed = 0.5 --cycles per second
		local is_done = false
		
		if alive(self._tier_icon) and alive(self._tier_icon_shadow) then 
			if tree_selected then 
--				self._tier_icon:rotate(dt * rotation_speed * angle)
--				self._tier_icon_shadow:set_rotation(dt * rotation_speed * angle)
				self._tier_icon:set_rotation(math.sin(t * 360 * rotation_speed) * angle)
				self._tier_icon_shadow:set_rotation(math.sin((t - rotation_delay) * 360 * rotation_speed) * angle)
				is_done = false
			--[[
				local desired_rotation = 0
				local current_rotation = self._tier_icon:rotation()
				local delta_rotation = dt * rotation_speed
				if math.abs(desired_rotation - current_rotation) < math.abs(delta_rotation) then 
					is_done = true
					self._tier_icon:set_rotation(desired_rotation)
					self._tier_icon_shadow:set_rotation(desired_rotation)
				else
					self._tier_icon:set_rotation(current_rotation + delta_rotation)
					self._tier_icon_shadow:set_rotation(current_rotation + delta_rotation)
					is_done = false
				end
				--]]
			end
		end
		
		local tier_scanlines = self._tier_scanlines
		if alive(tier_scanlines) then 
			local scanline_y = tier_scanlines:y() + (dt * scanlines_speed)
			if scanline_y >= 0 then 
				tier_scanlines:set_y(-self._tier_panel:child("tier_scanlines"):h())
			else
				tier_scanlines:set_y(scanline_y)
			end
			tier_scanlines:set_visible(tree_selected)
--			self._tier_panel:child("tier_scanlines"):set_x((self._tier_panel:w() - self._tier_panel:child("tier_scanlines"):w()) / 2)
		end
		is_done = orig_specializationtieritem_updatesize(self,dt,tree_selected,...) and is_done
		return not tree_selected and is_done
	else
		return orig_specializationtieritem_updatesize(self,dt,tree_selected,...)
	end
end