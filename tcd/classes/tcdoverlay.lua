--[[
TCDOverlay = TCDOverlay or class()

function TCDOverlay:init(...)
	self.name = ""
	self.params = {
		
	}
end

function TCDOverlay:Update(t,dt)

end

--]]






------------------------
--sociopath combo counter

TCDSociopathComboOverlay = class()

function TCDSociopathComboOverlay:init(...)
	self.name = "sociopath_combo"
	self.params = {
		y_pos = 100,
		stack_count_font = "fonts/font_justice_shadow_outline",
		anim_pulse_duration = 0.5, --pulse font size for 0.5 seconds (0.5 seconds total elapsed)
		anim_timeout_hold_duration = 3.5, --wait for 3.5 seconds (4 seconds total elapsed)
		anim_timeout_fade_duration = 3, --color change for 3 seconds (7 seconds total elapsed); remaining timeout is handled outside
		font_size = 32,
		font_halign = "center",
		font_valign = "top",
		font_color_primary = Color("f579ff"),
		font_color_secondary = Color("43ebed"),
		font_color_pulse = Color("ffffff"),
		font_scale = 1.2
	}
	
	self.current_combo = "" --init text value of the text object; not necessarily a number!
	
end

function TCDSociopathComboOverlay:Create(parent_hud)
	parent_hud = parent_hud or self._parent_hud
	self._parent_hud = parent_hud
	local params = self.params
	local panel = parent_hud:panel({
		name = self.name
	})
	self._panel = panel
	
	local stack_count_text = panel:text({
		name = "stack_count_text",
		text = self.current_combo,
		font = params.stack_count_font,
		font_size = params.font_size,
		y = params.y_pos,
		align = params.font_halign,
		vertical = params.font_valign,
		color = params.font_color_primary,
		layer = 4
	})
	self._stack_count_text = stack_count_text
end

function TCDSociopathComboOverlay:OnComboChanged(previous,current)
	self.current_combo = tostring(current)
	
	local params = self.params
	local anim_pulse_duration = params.anim_pulse_duration
	local anim_timeout_hold_duration = params.anim_timeout_hold_duration
	local anim_timeout_fade_duration = params.anim_timeout_fade_duration
	--local base_combo_duration = tweak_data.upgrades.values.player.sociopath_combo_duration
	--base_combo_duration - (anim_timeout_fade_duration + anim_pulse_duration + (base_combo_duration - anim_timeout_low_duration))
--combo duration is 10s
	
	local font_scale = params.font_scale
	local color_scale = math.min(current/10,1)
	local to_font_size = params.font_size
	local from_font_size = to_font_size * font_scale
	local combo_text_string = managers.localization:text("hud_sociopath_combo_count")
	
	local stack_count_text = self._stack_count_text
	
	local font_color_pulse = params.font_color_pulse
	local font_color_primary = params.font_color_primary
	local font_color_secondary = params.font_color_secondary
	
	local s
	if current > 1 then 
		s = string.format(combo_text_string,current)
	else
		s = ""
	end
	if alive(stack_count_text) then
		if current > 1 then 
			stack_count_text:stop()
--			local function _t()
--				return string.format("%0.2f",Application:time())
--			end
--			local function _log(...)
--				return OffyLib:c_log(...)
--			end
			
			stack_count_text:animate(
				function(o)
				
--					_log(_t() .. " started ")
					
					over(anim_pulse_duration,
						function(t)
							local from_color = font_color_pulse
							local to_color = font_color_primary
							o:set_font_size(from_font_size + ((to_font_size - from_font_size) * t))
							o:set_color(from_color + ((to_color - from_color) * t))
						end
					)

--					_log(_t() .. " waiting")
--					wait(anim_timeout_hold_duration)
					
--					_log(_t() .. " fading color")
					local c = o:color()
					over(anim_timeout_fade_duration,
						function(t)
							local to_color = font_color_secondary
							o:set_color(c + ((to_color - c) * t))
						end
					)
--					_log(_t() .. " done, waiting...")
--					wait(3)
--					_log(_t() .. " done done?")
				end
			)
		else
			stack_count_text:stop()
		end
		
		stack_count_text:set_text(s)
	end

end








-----------------------
--sociopath retro down effect

TCDSociopathDownedOverlay = class() --deep_clone(TCDOverlay)

function TCDSociopathDownedOverlay:init(...)
--	TCDSociopathDownedOverlay.super.init(self,...)
	self.name = "sociopath_crt"
	
	self.params = {
		vignette_texture = "guis/textures/pd2/damage_overlay_sociopath/vignette_overlay",
		vignette_inverted_texture = "guis/textures/pd2/damage_overlay_sociopath/vignette_inverted_overlay",
		blackscreen_color = Color("000000"),
		
		scanlines_alpha = 0.2,
		scanlines_texture = "guis/textures/pd2/damage_overlay_sociopath/scanlines_overlay",
		scanlines_blend_mode = "sub",
		scanlines_texture_x = 0,
		scanlines_texture_y = 0,
		scanlines_texture_w = 1,
		scanlines_texture_h = 360,
		scanlines_speed = 100,
		
		static_texture_w = 256,
		static_texture_h = 256,
		static_rotation_step = 90,
		static_interval = 0.04,
		static_blend_mode = "normal",
		static_w = 256,
		static_h = 256,
		static_max_alpha = 0.85,
		
		whitescreens_count = 15,
		whitescreen_max_size = 0.66,
		whitescreen_delay_time = 0.001,
		whitescreen_off_time = 0.5,
		whitescreen_shine_time = 0.25,
		whitescreen_shine_scale = 0.2,
		whitescreen_color = Color("ffffff"),
		whitescreen_alpha = 0.1,
		
		dying_line_w_scale = 4,
		dying_line_h_scale = 0.025,
		blackscreen_timer = 0.25,
		death_screen_fadeout_time = 1,
		
		static_files = {
			"guis/textures/pd2/damage_overlay_sociopath/static1",
			"guis/textures/pd2/damage_overlay_sociopath/static2",
			"guis/textures/pd2/damage_overlay_sociopath/static3",
			"guis/textures/pd2/damage_overlay_sociopath/static4"
		}
	
	}
	
end

function TCDSociopathDownedOverlay:Create(parent_hud)
	parent_hud = parent_hud or self._parent_hud
	self._parent_hud = parent_hud
	if not alive(self._parent_hud) then
		log("TOTAL CRACKDOWN: ERROR! No parent hud to create sociopath downed overlay")
		return
	end
	local params = self.params
	if alive(parent_hud:child(self.name)) then 
		parent_hud:remove(parent_hud:child(self.name))
	end
	local panel = parent_hud:panel({
		name = self.name,
		layer = -9
	})
	self._panel = panel
	
	local panel_w,panel_h = panel:size()
	local panel_x,panel_y = panel:position()
	
	local death_panel = panel:panel({
		name = "death_panel",
		visible = false
	})
	self._death_panel = death_panel
	
	local blackscreen = panel:rect({
		name = "blackscreen",
		color = params.blackscreen_color,
		alpha = 0,
		layer = 0
	})
	self._blackscreen = blackscreen
	
	local vignette = panel:bitmap({
		name = "vignette",
		texture = params.vignette_texture,
		w = 0,
		h = 0,
		layer = 3
	})
	self._vignette = vignette
	
	local static_panel = panel:panel({
		name = "static",
		layer = 2
	})
	self._static_panel = static_panel
	
	local scanlines_panel = panel:panel({
		name = "scanlines",
		h = panel:h() * 2,
		alpha = params.scanlines_alpha,
		layer = 4,
		visible = false
	})
	self._scanlines_panel = scanlines_panel
	
	local scanline_1 = scanlines_panel:bitmap({
		name = "scanline_1",
		texture = params.scanlines_texture,
		texture_rect = {
			params.scanlines_texture_x,
			params.scanlines_texture_y,
			params.scanlines_texture_w,
			params.scanlines_texture_h
		},
		blend_mode = params.scanlines_blend_mode,
		y = 0,
		w = panel_w,
		h = panel_h
	})
	
	local scanline_2 = scanlines_panel:bitmap({
		name = "scanline_2",
		texture = params.scanlines_texture,
		texture_rect = {
			params.scanlines_texture_x,
			params.scanlines_texture_y,
			params.scanlines_texture_w,
			params.scanlines_texture_h
		},
		blend_mode = params.scanlines_blend_mode,
		y = panel_h,
		w = panel_w,
		h = panel_h
	})
	
	local statics_v = math.ceil(static_panel:h() / params.static_h)
	local statics_h = math.ceil(static_panel:w() / params.static_w)
	
	local num_statics = statics_v * statics_h
	
	for i = 0,num_statics-1,1 do 
		local row = math.floor(i/statics_h)
		local column = i % statics_h
		local x = params.static_w * column
		local y = params.static_h * row
		
		local static = static_panel:bitmap({
			name = "static_" .. i,
			texture = table.random(params.static_files),
			blend_mode = params.static_blend_mode,
			w = params.static_w,
			h = params.static_h,
			alpha = 0,
			x = x,
			y = y
		})
	end
	
	self._static_update_enabled = false
	self._scanlines_update_enabled = false
	
	self._current_static_index = 1
	self._static_change_t = 0
end

function TCDSociopathDownedOverlay:Update(t,dt,...) --static/scanlines effect
	local panel = self._panel
	if alive(panel) then 
		local params = self.params
		local player = managers.player and managers.player:local_player()
		
		
				--scroll scanlines
		if self._scanlines_update_enabled then 
			local scanlines_panel = self._scanlines_panel
			local scanline_y = scanlines_panel:y() + (dt * params.scanlines_speed)
			if scanline_y >= 0 then 
				scanlines_panel:set_y(-panel:h())
			else
				scanlines_panel:set_y(scanline_y)
			end
		end
		
			--downed progression effects
		if self._static_update_enabled and alive(player) then 
			local static_panel = self._static_panel
			
			local dmg_ext = player:character_damage()
			local progression = dmg_ext._downed_progression
			if progression and dmg_ext:is_downed() then 
			
				local prog_dec = progression / 100
				local scale = 2 - prog_dec
				
				--rescale vignette
				local vignette = self._vignette
				local vw,vh = panel:size()
				vignette:set_size(vw * scale,vh * scale)
				vignette:set_center(panel:center())
				
				--rotate/fade downed static
				self._static_change_t = self._static_change_t + dt
				if self._static_change_t >= params.static_interval then 
					self._static_change_t = 0
					
					self._current_static_index = (self._current_static_index + 1) % #params.static_files
					
					
					for i,static in pairs(static_panel:children()) do 
						static:set_image(table.random(params.static_files))
						static:set_rotation(self._current_static_index * params.static_rotation_step)
						static:set_alpha(prog_dec * prog_dec * params.static_max_alpha)
					end
					
				end
			end
		end
	end
--	TCDSociopathDownedOverlay.super.Update(self,t,dt,...)
end

function TCDSociopathDownedOverlay:StartDownedAnimation()
	--register updater
	self._scanlines_update_enabled = true
	self._static_update_enabled = true
	
	if alive(self._scanlines_panel) then 
		self._scanlines_panel:show()
	end
	
	self._current_static_index = 1
	self._static_change_t = 0
	
	BeardLib:AddUpdater("TCD_Sociopath_Downed_Overlay_Updater",callback(self,self,"Update"),true)
end

function TCDSociopathDownedOverlay:StopDownedAnimation()
	BeardLib:RemoveUpdater("TCD_Sociopath_Downed_Overlay_Updater")
	self:Create()
end

function TCDSociopathDownedOverlay:StartDeathAnimation()
	local panel = self._panel
	local params = self.params
	if alive(panel) then 
		local whitescreen_max_size = params.whitescreen_max_size
		local whitescreen_off_time = params.whitescreen_off_time
		local whitescreens_count = params.whitescreens_count
		local whitescreen_color = params.whitescreen_color
		local whitescreen_alpha = params.whitescreen_alpha
		local whitescreen_delay_time = params.whitescreen_delay_time
		local whitescreen_shine_time = params.whitescreen_shine_time
		local whitescreen_shine_scale = params.whitescreen_shine_scale
		local shine_texture = params.vignette_inverted_texture
		local dying_line_h = params.dying_line_h
		local dying_line_w_scale = params.dying_line_w_scale
		local dying_line_h_scale = params.dying_line_h_scale
		local death_screen_fadeout_time = params.death_screen_fadeout_time
		
		for i,static in pairs(self._static_panel:children()) do 
			static:set_alpha(0)
		end
		self._scanlines_panel:hide()
		self._vignette:set_size(0,0)
		self._blackscreen:set_alpha(1)
		
		local death_panel = self._death_panel
		death_panel:show()
		death_panel:animate(function(o)
		
			local function anim_fadeout(whs)
				over(whitescreen_off_time,function(elapsed_prog)
					elapsed_prog = 1 - elapsed_prog
					local ow,oh = whs:parent():size()
					whs:set_size(whitescreen_max_size * ow * elapsed_prog,whitescreen_max_size * oh * elapsed_prog)
					whs:set_center(whs:parent():center())
				end)
				whs:parent():remove(whs)
			end
			
			for i=1,whitescreens_count do 
				local cw,ch = o:size()
				local whitescreen_prog = i/whitescreens_count
				local ow = cw * whitescreen_max_size
				local oh = ch * whitescreen_max_size
				
				local whitescreen = o:rect({
					name = "whitescreen_" .. i,
					color = whitescreen_color,
					alpha = whitescreen_alpha,
					layer = 100 + i,
					blend_mode = "add",
					w = ow,
					h = oh
				})
				whitescreen:set_center(o:center())
				wait(whitescreen_delay_time)
				whitescreen:animate(anim_fadeout)
			end
			
			local shine = o:bitmap({
				name = "shine",
				texture = shine_texture,
				color = whitescreen_color,
				w = 0,
				h = 0,
				layer = 101
			})
			
			local dying_line = o:bitmap({
				name = "dying_line",
				texture = shine_texture,
				w = 0,
				layer = 100
--				h = dying_line_h --not set?
			})
			wait(whitescreen_off_time)
			over(whitescreen_shine_time,function(elapsed_prog)
				local _t = (-math.cos(elapsed_prog * 360) + 1) * whitescreen_shine_scale / 2
				local sw,sh = o:size()
				shine:set_size(sw * _t,sh * _t)
				shine:set_center(o:center())
				dying_line:set_alpha((-math.cos(elapsed_prog * 360) + 1) / 2)
				dying_line:set_size(dying_line_w_scale * o:w() * elapsed_prog,o:h() * dying_line_h_scale * elapsed_prog)
				dying_line:set_center(o:center())
			end)
			o:remove(shine)
			over(death_screen_fadeout_time,function(prog)
				o:set_alpha(1-prog)
			end)
			
			for _,v in pairs(o:children()) do 
				o:remove(v)
			end
			self._blackscreen:set_alpha(0)
			o:hide()
		end)
	end
end

function TCDSociopathDownedOverlay:StopDeathAnimation() --on revived
	if alive(self._death_panel) then 
		self._death_panel:stop()
		self._death_panel:hide()
	end
end


