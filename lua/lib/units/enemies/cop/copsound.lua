function CopSound:chk_voice_prefix()
	if self._prefix then
		return self._prefix
	end
end


Hooks:PostHook(CopSound, "say", "vox_say", function(self, sound_name, sync, skip_prefix, important, callback)

	local full_sound = nil
	
	if self._prefix == "l5d_" then
		if sound_name == "c01" or sound_name == "att" then
			sound_name = "g90"
		elseif sound_name == "rrl" then
			sound_name = "pus"
		elseif sound_name == "t01" then
			sound_name = "prm"
		elseif sound_name == "h01" then
			sound_name = "h10"
		end
	end
	
	local fixed_sound = nil
	
	if self._prefix == "l1n_" or self._prefix == "l2n_" or self._prefix == "l3n_" or self._prefix == "l4n_" then
		if sound_name == "x02a_any_3p" then
			sound_name = "x01a_any_3p"
			--log("help")
			fixed_sound = true
		elseif sound_name == "x01a_any_3p" and not fixed_sound and not self._prefix == "l4n_" then
			sound_name = "x02a_any_3p"
			--log("fuckinghell")
		end
	end
	
	local faction = tweak_data.levels:get_ai_group_type()
	
	if self._prefix == "z1n_" or self._prefix == "z2n_" or self._prefix == "z3n_" or self._prefix == "z4n_" then
		if sound_name == "x02a_any_3p" then
			full_sound = "shd_x02a_any_3p_01"
		end
		
		if sound_name == "x01a_any_3p" then
			full_sound = "bdz_x01a_any_3p"
		end
		
		if sound_name ~= "x01a_any_3p" and sound_name ~= "x02a_any_3p" and not full_sound then
			sound_name = "g90"
		end
	end
	
	if self._unit:base():has_tag("special") and not sound_name == "g90" and not sound_name == "c01" then
	
		if sound_name == "x02a_any_3p" then
			if self._unit:base():has_tag("spooc") then
				if faction == "russia" then
					full_sound = "rclk_x02a_any_3p"
				else
					full_sound = "clk_x02a_any_3p"
				end
			end
			
			if self._unit:base():has_tag("taser") then
				if faction == "russia" then
					full_sound = "rtsr_x02a_any_3p"
				else
					full_sound = "tsr_x02a_any_3p"
				end
			end
			
			if self._unit:base():has_tag("tank") then
				full_sound = "bdz_x02a_any_3p"
			end
			
			if self._unit:base():has_tag("medic") then
				full_sound = "mdc_x02a_any_3p"
			end
		end
		
		if sound_name == "x01a_any_3p" then
			if self._unit:base():has_tag("spooc") then
				if faction == "russia" then
					full_sound = "rclk_x01a_any_3p" --weird he has hurt noises but the regular cloaker doesnt
				else
					full_sound = full_sound
				end
			end
			if self._unit:base():has_tag("taser") then
				if faction == "russia" then
					full_sound = "rtsr_x01a_any_3p"
				else
					full_sound = "tsr_x01a_any_3p"
				end
			end
			if self._unit:base():has_tag("tank") then
				full_sound = "bdz_x01a_any_3p"
			end
			if self._unit:base():has_tag("medic") then
				full_sound = "mdc_x01a_any_3p"
			end
		end
	end
	
	if self._prefix == "l3d_" then
		if sound_name == "burnhurt" then
			full_sound = "l1d_burnhurt"
		end
		if sound_name == "burndeath" then
			full_sound = "l1d_burndeath"
		end
	end
	
	--if self._prefix == "l1d_" or self._prefix == "l2d_" or self._prefix == "l3d_" or self._prefix == "l4d_" or self._prefix == "l5d_" then
		--if sound_name == "x02a_any_3p" then
			--full_sound = "shd_x02a_any_3p_01"
		--end
	--end
	
	if self._prefix == "fl1n_" then
        if sound_name == "x02a_any_3p" then
            full_sound = "fl1n_x01a_any_3p_01"
        end
    end
        
    if self._prefix == "r1n_" or self._prefix == "r2n_" or self._prefix == "r3n_" or self._prefix == "r4n_" then
        if sound_name == "x02a_any_3p" then
            full_sound = "l2n_x01a_any_3p"
        elseif sound_name == "x01a_any_3p" then
			full_sound = "l2n_x02a_any_3p"
        end
    end
	
	if not full_sound then
		if skip_prefix then
			full_sound = sound_name
		else
			full_sound = self._prefix .. sound_name
		end
	end

end)