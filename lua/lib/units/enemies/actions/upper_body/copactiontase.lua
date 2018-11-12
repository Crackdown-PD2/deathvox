CopActionTase = CopActionTase or class()
local temp_vec1 = Vector3()
local temp_vec2 = Vector3()

function CopActionTase:on_attention(attention)
	if self._expired then
		self._attention = attention
	elseif Network:is_server() then
		if self._attention then
			if self._discharging then
				self._tasing_local_unit:movement():on_tase_ended()

				self._discharging = nil
			end

			if self._tasing_local_unit and self._tasing_player then
				self._attention.unit:movement():on_targetted_for_attack(false, self._unit)
			end

			self._tasing_player = nil
			self._tasing_local_unit = nil
			self._expired = true
			self.update = self._upd_empty
			self._attention = attention

			return
		end
	else
		if self._client_attention_set or not attention or not attention.unit then
			if self._discharging then
				self._tasing_local_unit:movement():on_tase_ended()

				self._discharging = nil
			end

			if self._tasing_local_unit and self._tasing_player then
				self._tasing_local_unit:movement():on_targetted_for_attack(false, self._unit)
			end

			self._tasing_player = nil
			self._tasing_local_unit = nil
			self._attention = attention
			self.update = self._upd_empty

			return
		end

		self._client_attention_set = true
	end

	local attention_unit = attention.unit
	self.update = nil
	local weapon_unit = self._ext_inventory:equipped_unit()
	local weap_tweak = weapon_unit:base():weapon_tweak_data()
	local weapon_usage_tweak = self._common_data.char_tweak.weapon[weap_tweak.usage]
	self._weap_tweak = weap_tweak
	self._w_usage_tweak = weapon_usage_tweak
	self._falloff = weapon_usage_tweak.FALLOFF
	self._turn_allowed = Network:is_client()
	self._attention = attention
	local t = TimerManager:game():time()
	local target_pos = attention.handler and attention.handler:get_attention_m_pos() or attention_unit:movement():m_head_pos()
	local shoot_from_pos = self._ext_movement:m_head_pos()
	local target_vec = target_pos - shoot_from_pos

	self._modifier:set_target_y(target_vec)

	local aim_delay = weapon_usage_tweak.aim_delay
	local lerp_dis = math.min(1, target_vec:length() / self._falloff[#self._falloff].r)
	local shoot_delay = math.lerp(aim_delay[1], aim_delay[2], lerp_dis)
	self._mod_enable_t = t + 0.1 --This is normally bound to shoot delay, but really, the taser only has a .1 aim delay, so it shouldn't matter.
	self._tasing_local_unit = nil
	self._tasing_player = nil

	if Network:is_server() then
		self._common_data.ext_network:send("action_tase_event", 1)

		if not attention_unit:base().is_husk_player then
			self._shoot_t = TimerManager:game():time() + 0.15 --keep it consistent, tase is executed first, if it fails, then open fire 
			self._tasing_local_unit = attention_unit
			self._line_of_fire_slotmask = managers.slot:get_mask("bullet_impact_targets_no_criminals")
			self._tasing_player = attention_unit:base().is_local_player
		end
	elseif attention_unit:base().is_local_player then
		self._shoot_t = TimerManager:game():time() + 0.15 --keep it consistent, tase is executed first, if it fails, then open fire 
		self._tasing_local_unit = attention_unit
		self._line_of_fire_slotmask = managers.slot:get_mask("bullet_impact_targets")
		self._tasing_player = true
	end

	if self._tasing_local_unit and self._tasing_player then
		self._tasing_local_unit:movement():on_targetted_for_attack(true, self._unit)
	end
end

function CopActionTase:update(t)
	if self._expired then
		return
	end

	local shoot_from_pos = self._ext_movement:m_head_pos()
	local target_dis = nil
	local target_vec = temp_vec1
	local target_pos = temp_vec2

	self._attention.unit:character_damage():shoot_pos_mid(target_pos)

	target_dis = mvector3.direction(target_vec, shoot_from_pos, target_pos)
	local target_vec_flat = target_vec:with_z(0)

	mvector3.normalize(target_vec_flat)

	local fwd_dot = mvector3.dot(self._common_data.fwd, target_vec_flat)

	if fwd_dot > 0.5 then
		if not self._modifier_on then
			self._modifier_on = true

			self._machine:force_modifier(self._modifier_name)

			self._mod_enable_t = t + 0.1 --execute tase check first
		end

		self._modifier:set_target_y(target_vec)
	else
		if self._modifier_on then
			self._modifier_on = nil

			self._machine:allow_modifier(self._modifier_name)
		end

		if self._turn_allowed and not self._ext_anim.walk and not self._ext_anim.turn and not self._ext_movement:chk_action_forbidden("walk") then
			local spin = target_vec:to_polar_with_reference(self._common_data.fwd, math.UP).spin
			local abs_spin = math.abs(spin)

			if abs_spin > 27 then
				local new_action_data = {
					type = "turn",
					body_part = 2,
					angle = spin
				}

				self._ext_movement:action_request(new_action_data)
			end
		end

		target_vec = nil
	end

	if not self._ext_anim.reload then
		if self._ext_anim.equip then
			-- Nothing
		elseif self._discharging then
			local vis_ray = self._unit:raycast("ray", shoot_from_pos, target_pos, "slot_mask", self._line_of_fire_slotmask, "sphere_cast_radius", self._w_usage_tweak.tase_sphere_cast_radius, "ignore_unit", self._tasing_local_unit, "report")

			if not self._tasing_local_unit:movement():tased() or vis_ray then
				if Network:is_server() then
					self._expired = true
				else
					self._tasing_local_unit:movement():on_tase_ended()
					self._attention.unit:movement():on_targetted_for_attack(false, self._unit)

					self._discharging = nil
					self._tasing_player = nil
					self._tasing_local_unit = nil
					self.update = self._upd_empty
				end
			end
		elseif self._shoot_t and target_vec and self._common_data.allow_fire and self._mod_enable_t < t then
			if self._tase_effect then
				World:effect_manager():fade_kill(self._tase_effect)
			end
	
			self._tase_effect = World:effect_manager():spawn({
				force_synch = true,
				effect = Idstring("effects/payday2/particles/character/taser_thread"),
				parent = self._ext_inventory:equipped_unit():get_object(Idstring("fire"))
			})

			if self._tasing_local_unit and mvector3.distance(shoot_from_pos, target_pos) <= self._w_usage_tweak.tase_distance then --less or equal
				local record = managers.groupai:state():criminal_record(self._tasing_local_unit:key())

				if not record or record.status or self._tasing_local_unit:movement():chk_action_forbidden("hurt") or self._tasing_local_unit:movement():zipline_unit() then
					if Network:is_server() then
						self._expired = true
					end
				else
					local vis_ray = self._unit:raycast("ray", shoot_from_pos, target_pos, "slot_mask", self._line_of_fire_slotmask, "sphere_cast_radius", self._w_usage_tweak.tase_sphere_cast_radius, "ignore_unit", self._tasing_local_unit, "report")

					if not vis_ray then
						self._common_data.ext_network:send("action_tase_event", 3)

						local attack_data = {
							attacker_unit = self._unit
						}

						self._attention.unit:character_damage():damage_tase(attack_data)
						CopDamage._notify_listeners("on_criminal_tased", self._unit, self._attention.unit)

						self._discharging = true

						if not self._tasing_local_unit:base().is_local_player then
							self._tasered_sound = self._unit:sound():play("tasered_3rd", nil)
						end

						local redir_res = self._ext_movement:play_redirect("recoil")

						if redir_res then
							self._machine:set_parameter(redir_res, "hvy", 0)
						end

						self._shoot_t = nil
					end
				end
			elseif not self._tasing_local_unit then
				self._tasered_sound = self._unit:sound():play("tasered_3rd", nil)
				local redir_res = self._ext_movement:play_redirect("recoil")

				if redir_res then
					self._machine:set_parameter(redir_res, "hvy", 0)
				end

				self._shoot_t = nil
			end
		end
	end
end
