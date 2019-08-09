function CopActionReload:_play_reload(t, loop_t_multiplier)
	local weap_tweak = self._weapon_unit and self._weapon_unit:base() and self._weapon_unit:base():weapon_tweak_data()

	if loop_t_multiplier and not self._ext_anim.base_no_recoil then
		local sound_prefix = weap_tweak.sounds.prefix --using weapon sounds because vanilla friendly, customize as you wish
		local single_reload = sound_prefix == "nagant_npc" or sound_prefix == "ching_npc" or sound_prefix == "ecp_npc"
		local use_pump_anim_on_end = sound_prefix == "remington_npc" or sound_prefix == "serbu_npc" or sound_prefix == "keltec_npc" or sound_prefix == "m37_npc" or sound_prefix == "china_npc"
		local loop_amount = not single_reload and (use_pump_anim_on_end and weap_tweak.CLIP_AMMO_MAX - 3 or weap_tweak.CLIP_AMMO_MAX) or 1

		local redir_res = self._ext_movement:play_redirect("reload_looped")

		if redir_res then
			self._looped_reload = true
			self._loop_t = t + (1 * ((0.45 * loop_amount) / loop_t_multiplier))
			self._loop_t_multiplier = loop_t_multiplier
			self._use_pump = use_pump_anim_on_end
		else
			cat_print("george", "[CopActionReload:_play_reload] redirect failed in", self._machine:segment_state(Idstring("base")))

			return
		end

		return redir_res
	else
		local redir_res = self._ext_movement:play_redirect("reload")

		if not redir_res then
			cat_print("george", "[CopActionReload:_play_reload] redirect failed in", self._machine:segment_state(Idstring("base")))

			return
		end

		return redir_res
	end
end

function CopActionReload:update_looped(t)
	if self._looped_reload then
		if self._loop_t < t then
			local res = self._use_pump and self._ext_movement:play_redirect("reload") or self._ext_movement:play_redirect("reload_looped_exit")

			if res then
				if self._use_pump then --sadly, the shotgun reload + pump is missing the sfx for now, and I've been trying to locate it to no avail, would be thankful if someone knows about this
					if self._loop_t_multiplier then
						self._machine:set_speed(res, self._loop_t_multiplier)
						self._loop_t_multiplier = nil
					end

					self._use_pump = nil
				end

				self._looped_reload = nil
			end
		end
	end
end
