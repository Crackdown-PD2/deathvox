local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_norm = mvector3.normalize
local mvec3_dir = mvector3.direction
local mvec3_set_l = mvector3.set_length
local mvec3_add = mvector3.add
local mvec3_dot = mvector3.dot
local mvec3_cross = mvector3.cross
local mvec3_rot = mvector3.rotate_with
local mvec3_rand_orth = mvector3.random_orthogonal
local mvec3_lerp = mvector3.lerp
local mrot_axis_angle = mrotation.set_axis_angle
local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
local temp_vec3 = Vector3()
local temp_rot1 = Rotation()
local bezier_curve = {
	0,
	0,
	1,
	1
}

function CopActionShoot:update(t)
	local vis_state = self._ext_base:lod_stage()
	vis_state = vis_state or 4

	if vis_state == 1 then
		-- Nothing
	elseif self._skipped_frames < vis_state * 3 then
		self._skipped_frames = self._skipped_frames + 1

		return
	else
		self._skipped_frames = 1
	end

	local shoot_from_pos = self._shoot_from_pos
	local ext_anim = self._ext_anim
	local target_vec, target_dis, autotarget, target_pos = nil

	if self._attention then
		target_pos, target_vec, target_dis, autotarget = self:_get_target_pos(shoot_from_pos, self._attention, t)
		local tar_vec_flat = temp_vec2

		mvec3_set(tar_vec_flat, target_vec)
		mvec3_set_z(tar_vec_flat, 0)
		mvec3_norm(tar_vec_flat)

		local fwd = self._common_data.fwd
		local fwd_dot = mvec3_dot(fwd, tar_vec_flat)

		if self._turn_allowed then
			local active_actions = self._common_data.active_actions
			local queued_actions = self._common_data.queued_actions

			if (not active_actions[2] or active_actions[2]:type() == "idle") and (not queued_actions or not queued_actions[1] and not queued_actions[2]) and not self._ext_movement:chk_action_forbidden("walk") then
				local fwd_dot_flat = mvec3_dot(tar_vec_flat, fwd)

				if fwd_dot_flat < 0.96 then
					local spin = tar_vec_flat:to_polar_with_reference(fwd, math.UP).spin
					local new_action_data = {
						body_part = 2,
						type = "turn",
						angle = spin
					}

					self._ext_movement:action_request(new_action_data)
				end
			end
		end

		target_vec = self:_upd_ik(target_vec, fwd_dot, t)
	end

	if not ext_anim.reload and not ext_anim.equip and not ext_anim.melee then
	
		if ext_anim.equip then
			-- Nothing
		elseif self._weapon_base:clip_empty() then
			if self._autofiring then
				self._weapon_base:stop_autofire()
				self._ext_movement:play_redirect("up_idle")

				self._autofiring = nil
				self._autoshots_fired = nil
			end

			if managers.groupai:state():is_unit_team_AI(self._unit) or alive(managers.groupai:state():phalanx_vip()) or not self._ext_anim.base_no_reload then -- allows the team AI to reload while moving and only allows other NPCs to reload while moving if Winters is alive
				if self._weap_tweak.reload == "looped" then
					local anim_multiplier = self._weap_tweak.looped_reload_speed or 1

					anim_multiplier = anim_multiplier * (self._reload_speed or 1)

					local res = CopActionReload._play_reload(self, t, anim_multiplier)

					if res then
						self._machine:set_speed(res, anim_multiplier)
					end
				else
					local res = CopActionReload._play_reload(self)

					if res then
						self._machine:set_speed(res, self._reload_speed)
					end
				end

				if Network:is_server() then
					managers.network:session():send_to_peers("reload_weapon_cop", self._unit)
				end
			end
		elseif self._autofiring then
			if not target_vec or not self._common_data.allow_fire then
				self._weapon_base:stop_autofire()

				self._shoot_t = t + 0.6
				self._autofiring = nil
				self._autoshots_fired = nil

				self._ext_movement:play_redirect("up_idle")
			else
				local spread = self._spread
				local falloff, i_range = self:_get_shoot_falloff(target_dis, self._falloff)
				local dmg_buff = self._unit:base():get_total_buff("base_damage")
				local dmg_mul = (1 + dmg_buff) * falloff.dmg_mul
				local new_target_pos = self._shoot_history and self:_get_unit_shoot_pos(t, target_pos, target_dis, self._w_usage_tweak, falloff, i_range, autotarget)

				if new_target_pos then
					target_pos = new_target_pos
				else
					spread = math.min(20, spread)
				end

				local spread_pos = temp_vec2

				mvec3_rand_orth(spread_pos, target_vec)
				mvec3_set_l(spread_pos, spread)
				mvec3_add(spread_pos, target_pos)

				target_dis = mvec3_dir(target_vec, shoot_from_pos, spread_pos)
				local fired = self._weapon_base:trigger_held(shoot_from_pos, target_vec, dmg_mul, self._shooting_player, nil, nil, nil, self._attention.unit)

				if fired then
					if fired.hit_enemy and fired.hit_enemy.type == "death" and self._unit:unit_data().mission_element then
						self._unit:unit_data().mission_element:event("killshot", self._unit)
					end

					if not ext_anim.recoil and vis_state == 1 and not ext_anim.base_no_recoil and not ext_anim.move and not self._unit:base():has_tag("tank") then --prevent Dozers from using recoil animations, aka aiming their guns, they introduced this with Housewarming Party and never fixed it
						self._ext_movement:play_redirect("recoil_auto")
					end

					if not self._autofiring or self._autofiring - 1 <= self._autoshots_fired then
						self._autofiring = nil
						self._autoshots_fired = nil

						self._weapon_base:stop_autofire()
						self._ext_movement:play_redirect("up_idle")

						if vis_state == 1 then
							self._shoot_t = t + (self._common_data.is_suppressed and 1.5 or 1) * math.lerp(falloff.recoil[1], falloff.recoil[2], self:_pseudorandom())
						else
							self._shoot_t = t + falloff.recoil[2]
						end
					else
						self._autoshots_fired = self._autoshots_fired + 1
					end
				end
			end
		elseif target_vec and self._common_data.allow_fire and self._shoot_t < t and self._mod_enable_t < t then
			local shoot = nil

			if autotarget or self._shooting_husk_player and self._next_vis_ray_t < t then
				if self._shooting_husk_player then
					self._next_vis_ray_t = t + 2
				end

				local fire_line = World:raycast("ray", shoot_from_pos, target_pos, "slot_mask", self._verif_slotmask, "ray_type", "ai_vision")

				if fire_line then
					if t - self._line_of_sight_t > 3 then
						local aim_delay_minmax = self._w_usage_tweak.aim_delay
						local lerp_dis = math.min(1, target_vec:length() / self._falloff[#self._falloff].r)
						local aim_delay = math.lerp(aim_delay_minmax[1], aim_delay_minmax[2], lerp_dis)
						aim_delay = aim_delay + self:_pseudorandom() * aim_delay * 0.3

						if self._common_data.is_suppressed then
							aim_delay = aim_delay * 1.5
						end

						self._shoot_t = t + aim_delay
					elseif fire_line.distance > 300 then
						shoot = true
					end
				else
					if t - self._line_of_sight_t > 1 and not self._last_vis_check_status then
						local shoot_hist = self._shoot_history
						local displacement = mvector3.distance(target_pos, shoot_hist.m_last_pos)
						local focus_delay = self._w_usage_tweak.focus_delay * math.min(1, displacement / self._w_usage_tweak.focus_dis)
						shoot_hist.focus_start_t = t
						shoot_hist.focus_delay = focus_delay
						shoot_hist.m_last_pos = mvector3.copy(target_pos)
					end

					self._line_of_sight_t = t
					shoot = true
				end

				self._last_vis_check_status = shoot
			else
				shoot = self._shooting_husk_player and self._last_vis_check_status or true
			end

			if self._common_data.char_tweak.no_move_and_shoot and self._common_data.ext_anim and self._common_data.ext_anim.move then
				shoot = false
				self._shoot_t = t + (self._common_data.char_tweak.move_and_shoot_cooldown or 1)
			end

			if shoot then
				local melee = nil

				if (not self._common_data.melee_countered_t or t - self._common_data.melee_countered_t > 15) and self._w_usage_tweak.melee_speed and self._melee_timeout_t < t and not alive(self._ext_inventory and self._ext_inventory._shield_unit) then
					if autotarget then
						if target_dis < 130 then
							melee = self:_chk_start_melee(target_vec, target_dis, autotarget, target_pos)
						end
					else
						if Network:is_server() then --prevent husks from attempting to melee each other
							local is_sentry = self._attention and self._attention.unit and self._attention.unit:base() and self._attention.unit:base().sentry_gun
							local is_player_husk = self._attention and self._attention.unit and self._attention.unit:base() and self._attention.unit:base().is_husk_player

							local head_pos = self._unit:movement():m_head_pos()
							local att_movement = self._attention and self._attention.unit and self._attention.unit.movement and self._attention.unit:movement() or nil
							local u_head_pos = att_movement and att_movement.m_head_pos and att_movement:m_head_pos() or nil
							local covered_by_shield = u_head_pos and World:raycast("ray", head_pos, u_head_pos, "ignore_unit", {self._unit}, "slot_mask", managers.slot:get_mask("enemy_shield_check"))

							if target_dis < 180 and not is_sentry and not is_player_husk then
								if self._attention and self._attention.unit and self._attention.unit:base() and self._attention.unit:base()._tweak_table ~= "shield" then
									if not covered_by_shield then
										melee = self:_chk_start_melee(target_vec, target_dis, nil, target_pos) --if the enemy isn't a Shield and it's not protected by a shield, attempt a melee attack
									end
								else
									melee = self:_chk_start_melee(target_vec, target_dis, nil, target_pos)
								end
							end
						end
					end
				end

				if not melee then
					local falloff, i_range = self:_get_shoot_falloff(target_dis, self._falloff)
					local dmg_buff = self._unit:base():get_total_buff("base_damage")
					local dmg_mul = (1 + dmg_buff) * falloff.dmg_mul
					local firemode = nil

					if self._automatic_weap then
						firemode = falloff.mode and falloff.mode[1] or 1
						local random_mode = self:_pseudorandom()

						for i_mode, mode_chance in ipairs(falloff.mode) do
							if random_mode <= mode_chance then
								firemode = i_mode

								break
							end
						end
					else
						firemode = 1
					end

					if firemode > 1 then
						self._weapon_base:start_autofire(firemode < 4 and firemode)

						if self._w_usage_tweak.autofire_rounds then
							if firemode < 4 then
								self._autofiring = firemode
							elseif falloff.autofire_rounds then
								local diff = falloff.autofire_rounds[2] - falloff.autofire_rounds[1]
								self._autofiring = math.round(falloff.autofire_rounds[1] + self:_pseudorandom() * diff)
							else
								local diff = self._w_usage_tweak.autofire_rounds[2] - self._w_usage_tweak.autofire_rounds[1]
								self._autofiring = math.round(self._w_usage_tweak.autofire_rounds[1] + self:_pseudorandom() * diff)
							end
						else
							Application:stack_dump_error("autofire_rounds is missing from weapon usage tweak data!", self._weap_tweak.usage)
						end

						self._autoshots_fired = 0

						if vis_state == 1 and not ext_anim.base_no_recoil and not ext_anim.move and not self._unit:base():has_tag("tank") then --same as the other check above
							self._ext_movement:play_redirect("recoil_auto")
						end
					else
						local spread = self._spread

						local new_target_pos = self._shoot_history and self:_get_unit_shoot_pos(t, target_pos, target_dis, self._w_usage_tweak, falloff, i_range, autotarget)

						--if autotarget then /// removing this stupid autotarget check allows single shot for NPCs to actually use accuracy stats in charactertweakdata and work properly just like autofire, instead of depending on spread alone
							if new_target_pos then
								target_pos = new_target_pos
							else
								spread = math.min(20, spread)
							end
						--end

						local spread_pos = temp_vec2

						mvec3_rand_orth(spread_pos, target_vec)
						mvec3_set_l(spread_pos, spread)
						mvec3_add(spread_pos, target_pos)

						target_dis = mvec3_dir(target_vec, shoot_from_pos, spread_pos)
						local fired = self._weapon_base:singleshot(shoot_from_pos, target_vec, dmg_mul, self._shooting_player, nil, nil, nil, self._attention.unit)

						if fired and fired.hit_enemy and fired.hit_enemy.type == "death" and self._unit:unit_data().mission_element then
							self._unit:unit_data().mission_element:event("killshot", self._unit)
						end

						if vis_state == 1 then
							if not ext_anim.base_no_recoil and not ext_anim.move then
								self._ext_movement:play_redirect("recoil_single")
							end
							self._shoot_t = t + (self._common_data.is_suppressed and 1.5 or 1) * math.lerp(falloff.recoil[1], falloff.recoil[2], self:_pseudorandom())
						else
							self._shoot_t = t + falloff.recoil[2]
						end
					end
				end
			end
		end
	end

	if self._weap_tweak.reload == "looped" then
		CopActionReload.update_looped(self, t)
	end

	if self._ext_anim.base_need_upd then
		self._ext_movement:upd_m_head_pos()
	end
end

function CopActionShoot:_chk_start_melee(target_vec, target_dis, autotarget, target_pos)
	local melee_weapon = self._unit:base():melee_weapon()
	local is_weapon = melee_weapon == "weapon"
	local state = self._ext_movement:play_redirect(is_weapon and "melee" or "melee_item")

	if state then
		if not is_weapon then
			local anim_attack_vars = self._common_data.char_tweak.melee_anims or {
				"var1",
				"var2"
			}
			local melee_var = self:_pseudorandom(#anim_attack_vars)

			self._common_data.machine:set_parameter(state, anim_attack_vars[melee_var], 1)

			local param = tweak_data.weapon.npc_melee[melee_weapon].animation_param

			self._common_data.machine:set_parameter(state, param, 1)
		end

		if is_weapon then
			local anim_speed = self._w_usage_tweak.melee_speed

			self._common_data.machine:set_speed(state, anim_speed)
		end

		managers.network:session():send_to_peers_synched("play_distance_interact_redirect", self._unit, is_weapon and "melee" or "melee_item") --let other players see when npcs attempt a melee attack instead of nothing, why isn't this in vanilla?

		self._melee_timeout_t = TimerManager:game():time() + (self._w_usage_tweak.melee_retry_delay and math.lerp(self._w_usage_tweak.melee_retry_delay[1], self._w_usage_tweak.melee_retry_delay[2], self:_pseudorandom()) or 1)
	else
		debug_pause_unit(self._common_data.unit, "[CopActionShoot:_chk_start_melee] redirect failed in state", self._common_data.machine:segment_state(Idstring("base")), self._common_data.unit)
	end

	return state and true
end

function CopActionShoot:anim_clbk_melee_strike()
	--some checks to prevent crashes
	if not self._attention then
		return
	end

	if not self._attention.unit then
		return
	end

	--does not actually mean "not dead", just that it's still existing and didn't despawn (dead bodies count as "alive" in this sense)
	if not alive(self._attention.unit) then
		return
	end

	if not self._attention.unit:base() then
		return
	end

	--can be damaged, or at least has that kind of damage functions
	if not self._attention.unit:character_damage() then
		return
	end

	--can take proper melee/bullet damage
	if not self._attention.unit:character_damage().damage_melee or not self._attention.unit:character_damage().damage_bullet then
		return
	end

	--regarding husks, to prevent both server and synced attacks (by server or clients) from crashing by trying to damage them, when they normally take damage locally
	if self._attention.unit:base().sentry_gun or self._attention.unit:base().is_husk_player then
		return
	end

	local shoot_from_pos = self._shoot_from_pos
	local ext_anim = self._ext_anim
	local target_pos, target_vec, target_dis, autotarget = self:_get_target_pos(shoot_from_pos, self._attention, TimerManager:game():time())
	local max_dix = autotarget and 165 or 180

	--prevent husks from hitting each other as a client which results in a crash
	if not autotarget and not Network:is_server() then
		return
	end

	--distance check
	if target_dis >= max_dix then
		return
	end

	--the target is actually alive
	if not autotarget and self._attention.unit:character_damage().dead and not self._attention.unit:character_damage():dead() then
		return
	end

	local min_dot = math.lerp(0, 0.4, target_dis / max_dix)
	local tar_vec_flat = temp_vec2

	mvec3_set(tar_vec_flat, target_vec)
	mvec3_set_z(tar_vec_flat, 0)
	mvec3_norm(tar_vec_flat)

	local fwd = self._common_data.fwd
	local fwd_dot = mvec3_dot(fwd, tar_vec_flat)

	if fwd_dot < min_dot then
		return
	end

	local push_vel = target_vec:with_z(0.1):normalized() * 600
	local melee_weapon = self._unit:base():melee_weapon()
	local is_weapon = melee_weapon == "weapon"
	local damage = is_weapon and self._w_usage_tweak.melee_dmg or tweak_data.weapon.npc_melee[melee_weapon].damage
	local dmg_mul = is_weapon and 1 or self._common_data.char_tweak.melee_weapon_dmg_multiplier or 1
	dmg_mul = dmg_mul * (1 + self._unit:base():get_total_buff("base_damage"))
	damage = damage * dmg_mul

	--unit and target heads to use for calculations and a shield obstruction check
	local head_pos = self._unit:movement():m_head_pos()
	local att_movement = self._attention.unit.movement and self._attention.unit:movement() or nil
	local u_head_pos = att_movement and att_movement.m_head_pos and att_movement:m_head_pos() or nil
	local covered_by_shield = u_head_pos and World:raycast("ray", head_pos, u_head_pos, "ignore_unit", {self._unit}, "slot_mask", managers.slot:get_mask("enemy_shield_check"))

	local knock_shield = nil

	--if the target is covered by a shield and is a normal Shield enemy, knock them back, else just produce a sound (this works as an additional check for non-Shield enemies so that if the attack is started before the enemy is covered by a shield, it won't hit them through it)
	if not autotarget then
		if covered_by_shield then
			if self._attention.unit:base() and self._attention.unit:base()._tweak_table == "shield" then
				knock_shield = true
			else
				if melee_weapon == "knife_1" then
					self._unit:sound():play("knife_hit_gen", nil, true)
				elseif melee_weapon == "fists" then
					self._unit:sound():play("fist_hit_gen", nil, true)
				elseif melee_weapon == "helloween" then
					self._unit:sound():play("knuckles_hit_gen", nil, true)
				elseif melee_weapon == "baton" or melee_weapon == "weapon" then
					self._unit:sound():play("melee_hit_gen", nil, true)
				end

				return
			end
		end
	end

	--separate autotarget and non-autotarget values (mostly if unused) + shield_knock
	local action_data = {
		variant = "melee",
		damage = knock_shield and 0 or damage,
		damage_effect = damage * 2,
		weapon_unit = not autotarget and nil or self._weapon_unit,
		attacker_unit = not autotarget and self._unit or self._common_data.unit,
		melee_weapon = not autotarget and nil or melee_weapon,
		push_vel = not autotarget and nil or push_vel,
		shield_knock = knock_shield and true or nil,
		is_melee_attack = not autotarget and not knock_shield and true,
		origin = head_pos,
		col_ray = {
			body = not autotarget and self._attention.unit.body and self._attention.unit:body("body") or nil, --need the Idstring for sentries for this to work against them without crashing
			position = not autotarget and u_head_pos and mvector3.copy(u_head_pos) or (head_pos + fwd * 50),
			ray = not autotarget and u_head_pos and mvector3.copy(u_head_pos - head_pos) or mvector3.copy(target_vec)
		}
	}
	local defense_data = (autotarget or knock_shield) and self._attention.unit:character_damage():damage_melee(action_data) or self._attention.unit:character_damage():damage_bullet(action_data)

	if defense_data then
		if defense_data == "countered" then
			self._common_data.melee_countered_t = TimerManager:game():time()
			local action_data = {
				damage_effect = 1,
				damage = 0,
				variant = "counter_spooc",
				attacker_unit = self._strike_unit,
				col_ray = {
					body = self._unit:body("body"),
					position = self._common_data.pos + math.UP * 100
				},
				attack_dir = -1 * target_vec:normalized(),
				name_id = managers.blackmarket:equipped_melee_weapon()
			}

			self._unit:character_damage():damage_melee(action_data)

			return
		else
			if melee_weapon then --because of the parameters above, this intentionally doesn't work against players
				local hit_offset_height = math.clamp(head_pos.z - self._attention.unit:movement():m_pos().z, 0, 300)
				local hit_pos = mvector3.copy(self._attention.unit:movement():m_pos())

				mvector3.set_z(hit_pos, hit_pos.z + hit_offset_height)

				local hit_rot = hit_pos - head_pos

				--SEMTRY TARGET SOUND AND EFFECTS - UNUSED FOR NOW
				--[[if self._attention.unit:base() and self._attention.unit:base().sentry_gun then
					if melee_weapon == "knife_1" then
						self._attention.unit:sound():play("knife_hit_gen", nil, true)
					elseif melee_weapon == "fists" then
						self._attention.unit:sound():play("fist_hit_gen", nil, true)
					elseif melee_weapon == "helloween" then
						self._attention.unit:sound():play("knuckles_hit_gen", nil, true)
					elseif melee_weapon == "baton" or melee_weapon == "weapon" then
						self._attention.unit:sound():play("melee_hit_gen", nil, true)
					end

					World:effect_manager():spawn({
						effect = Idstring("bullet_hit"),
						position = hit_pos,
						normal = hit_rot
					})
				else]]
					if knock_shield then
						if melee_weapon == "knife_1" then
							self._attention.unit:sound():play("knife_hit_gen", nil, true)
						elseif melee_weapon == "fists" then
							self._attention.unit:sound():play("fist_hit_gen", nil, true)
						elseif melee_weapon == "helloween" then
							self._attention.unit:sound():play("knuckles_hit_gen", nil, true) --not all sounds work, I guess they're just not loaded
						elseif melee_weapon == "baton" or melee_weapon == "weapon" then
							self._attention.unit:sound():play("melee_hit_gen", nil, true)
						end
					else
						if melee_weapon == "knife_1" then
							self._attention.unit:sound():play("knife_hit_body", nil, true)
						elseif melee_weapon == "fists" then
							self._attention.unit:sound():play("fist_hit_body", nil, true)
						elseif melee_weapon == "helloween" then
							self._attention.unit:sound():play("knuckles_hit_body", nil, true)
						elseif melee_weapon == "baton" or melee_weapon == "weapon" then
							self._attention.unit:sound():play("melee_hit_body", nil, true)
						end

						World:effect_manager():spawn({
							effect = Idstring("effects/payday2/particles/impacts/blood/blood_impact_a"),
							position = hit_pos,
							normal = hit_rot
						})
					end
				--end
			end
		end
	end
end
