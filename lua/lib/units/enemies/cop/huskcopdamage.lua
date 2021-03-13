function HuskCopDamage:die(attack_data)
	CopDamage.MAD_3_ACHIEVEMENT(attack_data)
	self:_check_friend_4(attack_data)
	self:_remove_debug_gui()
	self._unit:base():set_slot(self._unit, 17)

	if self._unit:inventory() then
		self._unit:inventory():drop_shield()
	end

	attack_data.variant = attack_data.variant or "bullet"
	self._health = 0
	self._health_ratio = 0
	self._dead = true

	self:set_mover_collision_state(false)

	if self._unit:interaction() and self._unit:interaction().tweak_data == "hostage_convert" then
		self._unit:interaction():set_active(false)
	end

	if self._death_sequence and self._unit:damage() and self._unit:damage():has_sequence(self._death_sequence) then
		self._unit:damage():run_sequence_simple(self._death_sequence)
	end

	if self._unit:base().has_tag and self._unit:base():has_tag("spooc") then
		if self._char_tweak.die_sound_event then
			self._unit:sound():play(self._char_tweak.die_sound_event) --ensure that spoocs stop their looping presence sound
		end

		--if not self._unit:movement():cool() then --optional, to reinforce the idea of silent kills if desired
			self._unit:sound():say("x02a_any_3p") --death voiceline, can't use char_tweak().die_sound_event since spoocs have the presence loop stop there (this ensures both are played, unlike in vanilla)
		--end

		if self._unit:damage() and self._unit:damage():has_sequence("kill_spook_lights") then
			self._unit:damage():run_sequence_simple("kill_spook_lights")
		end
	else
		--if not self._unit:movement():cool() then
		if self._char_tweak.die_sound_event then --death voiceline determined through char_tweak().die_sound_event, otherwise use default
			self._unit:sound():say(self._char_tweak.die_sound_event)
		else
			self._unit:sound():say("x02a_any_3p")
		end
		--end
	end

	if self._unit:base().looping_voice then
		self._unit:base().looping_voice:set_looping(false)
		self._unit:base().looping_voice:stop()
		self._unit:base().looping_voice:close()
		self._unit:base().looping_voice = nil
	end

	--[[if self._unit:base():char_tweak().ends_assault_on_death then
		managers.hud:set_buff_enabled("vip", false)
	end]]

	self:_on_death()
	--to add later after adding some mutator fixes, if even wanted
	--managers.mutators:notify(Message.OnCopDamageDeath, self, attack_data)
end

if deathvox:IsTotalCrackdownEnabled()
	function HuskCopDamage:sync_net_event(event_id)
		if event_id ~= 1 then
			return
		end

		self._tased_time = tweak_data.upgrades.player.drill_shock_tase_time
	end
end
