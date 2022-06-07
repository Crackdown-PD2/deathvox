local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_mul = mvector3.multiply
local mvec3_sub = mvector3.subtract
local mvec3_norm = mvector3.normalize
local mvec3_dir = mvector3.direction
local mvec3_dis = mvector3.distance
local mvec3_set_l = mvector3.set_length
local mvec3_add = mvector3.add
local mvec3_dot = mvector3.dot
local mvec3_cross = mvector3.cross
local mvec3_rot = mvector3.rotate_with
local mvec3_rand_orth = mvector3.random_orthogonal
local mvec3_lerp = mvector3.lerp
local mvec3_copy = mvector3.copy

local temp_vec2 = Vector3()
local temp_vec3 = Vector3()
local temp_vec4 = Vector3()

local math_min = math.min
local math_lerp = math.lerp
local math_ceil = math.ceil
local math_random = math.random
local math_clamp = math.clamp
local math_up = math.UP

local mrot_axis_angle = mrotation.set_axis_angle
local temp_rot1 = Rotation()

local draw_target_vec_firing = nil
local draw_melee_sphere_rays = nil
local draw_aim_delay_vis_proc = nil
local draw_fire_line_ray = nil
local draw_focus_displacement = nil
local draw_focus_delay_vis_reset = nil

function CopActionShoot:init(action_desc, common_data)
	local inventory_ext = common_data.ext_inventory
	local weapon_unit = inventory_ext:equipped_unit()

	if not weapon_unit then
		return false
	end

	self._weapon_unit = weapon_unit

	self._common_data = common_data
	self._ext_inventory = inventory_ext
	self._ext_movement = common_data.ext_movement
	self._ext_anim = common_data.ext_anim
	self._ext_brain = common_data.ext_brain
	self._ext_base = common_data.ext_base
	self._machine = common_data.machine
	self._unit = common_data.unit
	self._body_part = action_desc.body_part
	self._variant = action_desc.variant

	local weap_base = weapon_unit:base()
	self._weapon_base = weap_base

	local weap_tweak = weap_base:weapon_tweak_data()
	self._weap_tweak = weap_tweak

	local char_tweak = common_data.char_tweak
	local weapon_usage_tweak = char_tweak.weapon[weap_tweak.usage]
	
	if char_tweak.is_special_unit and char_tweak.is_special_unit == "sniper" then
		self._sniper_enemy = true
	end
	
	self._w_usage_tweak = weapon_usage_tweak

	self._aim_delay_minmax = weapon_usage_tweak.aim_delay or {0, 0}
	self._focus_delay = weapon_usage_tweak.focus_delay or 0
	self._focus_displacement = weapon_usage_tweak.focus_dis or 500
	self._spread = weapon_usage_tweak.spread or 20
	self._miss_dis = weapon_usage_tweak.miss_dis or 30
	self._automatic_weap = weap_tweak.auto and weapon_usage_tweak.autofire_rounds and true or nil
	self._falloff = weapon_usage_tweak.FALLOFF or {
		{
			dmg_mul = 1,
			r = 1500,
			acc = {
				0.2,
				0.6
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				3,
				3,
				1
			}
		}
	}

	self._melee_timeout_t = 0
	self._shoot_t = 0
	self._timer = TimerManager:game()

	self._shoot_from_pos = self._ext_movement:m_head_pos()

	local shield_unit = alive(self._ext_inventory._shield_unit) and self._ext_inventory._shield_unit or nil
	self._shield = shield_unit

	self._tank_animations = self._ext_movement._anim_global == "tank" and true or nil
	self._fire_line_slotmask = managers.slot:get_mask("AI_visibility")
	self._shield_slotmask = managers.slot:get_mask("enemy_shield_check")

	local is_team_ai, is_converted = nil

	if managers.groupai:state():is_unit_team_AI(self._unit) then
		is_team_ai = true
		self._is_team_ai = true
	elseif self._ext_brain.converted and self._ext_brain:converted() or managers.groupai:state():is_enemy_converted_to_criminal(self._unit) then
		is_converted = true
		self._is_converted = true
	end

	if not shield_unit then
		local melee_weapon = self._ext_base.melee_weapon and self._ext_base:melee_weapon()

		if melee_weapon then
			self._geometry_slotmask = managers.slot:get_mask("world_geometry", "vehicles")

			local slotmask, electrical, shield_knock, anim_param = nil
			local damage, dmg_mul, speed, range = 3, 1, 1, 150
			local retry_delay = {1, 1}
			local hit_player = true
			local anim_vars = {
				"var1",
				"var2"
			}

			if is_team_ai then
				damage = weapon_usage_tweak.melee_dmg
				slotmask = managers.slot:get_mask("bullet_impact_targets_no_criminals")
				shield_knock = true
				hit_player = nil
			elseif is_converted then
				slotmask = managers.slot:get_mask("bullet_impact_targets_no_criminals")
				hit_player = nil
			end

			if not slotmask then
				slotmask = slotmask or managers.slot:get_mask("bullet_impact_targets_no_police") + 3
			end

			if weapon_usage_tweak.melee_retry_delay then
				retry_delay = weapon_usage_tweak.melee_retry_delay
			end

			if melee_weapon == "weapon" then
				if weapon_usage_tweak.melee_dmg then
					damage = weapon_usage_tweak.melee_dmg
				end

				if weapon_usage_tweak.melee_speed then
					speed = weapon_usage_tweak.melee_speed
				end
			else
				if char_tweak.melee_weapon_dmg_multiplier then
					dmg_mul = char_tweak.melee_weapon_dmg_multiplier
				end

				if char_tweak.melee_weapon_speed then
					speed = char_tweak.melee_weapon_speed
				end

				local melee_weapon_stats = tweak_data.weapon.npc_melee[melee_weapon]

				if melee_weapon_stats then
					if melee_weapon_stats.damage then
						damage = melee_weapon_stats.damage
					elseif weapon_usage_tweak.melee_dmg then
						damage = weapon_usage_tweak.melee_dmg
					end

					if melee_weapon_stats.range then
						range = melee_weapon_stats.range
					end

					if melee_weapon_stats.electrical then
						electrical = true
					end
					
					if melee_weapon_stats.animation_param then
						anim_param = melee_weapon_stats.animation_param
					end
				end

				if char_tweak.melee_anims then
					anim_vars = char_tweak.melee_anims
				end
			end

			self._melee_weapon_data = {
				melee_weapon = melee_weapon,
				damage = damage,
				dmg_mul = dmg_mul,
				speed = speed,
				retry_delay = retry_delay,
				range = range,
				slotmask = slotmask,
				hit_player = hit_player,
				electrical = electrical,
				shield_knock = shield_knock,
				anim_param = anim_param,
				anim_vars = anim_vars
			}
		end
	end

	if Network:is_server() then
		self._is_server = true

		self._ext_movement:set_stance_by_code(3)

		common_data.ext_network:send("action_aim_state", true)
	else
		self._turn_allowed = true
	end

	local preset_name = self._ext_anim.base_aim_ik or "spine"
	local preset_data = self._ik_presets[preset_name]
	self._ik_preset = preset_data
	self[preset_data.start](self)

	self:on_attention(common_data.attention)

	CopActionAct._create_blocks_table(self, action_desc.blocks)

	self._skipped_frames = 1

	return true
end

function CopActionShoot:on_exit()
	if self._is_server then
		--[[if not self._exiting_to_reload then
			if not self._attention or not self._attention.reaction or self._attention.reaction < AIAttentionObject.REACT_AIM then
				self._ext_movement:set_stance_by_code(2)
			end
		end]]

		if not self._exiting_to_reload then
			self._ext_movement:set_stance_by_code(2)
		end

		self._common_data.ext_network:send("action_aim_state", false)
	end

	if self._modifier_on then
		self[self._ik_preset.stop](self)
	end

	if self._autofiring then
		self._weapon_base:stop_autofire()
		self._ext_movement:play_redirect("up_idle")
	end

	if self._shooting_player and alive(self._attention.unit) then
		self._attention.unit:movement():on_targetted_for_attack(false, self._common_data.unit)
	end
end

function CopActionShoot:on_attention(attention, old_attention)
	if self._shooting_player and old_attention and alive(old_attention.unit) then
		old_attention.unit:movement():on_targetted_for_attack(false, self._common_data.unit)
	end

	if self._autofiring then
		self._weapon_base:stop_autofire()
		self._ext_movement:play_redirect("up_idle")

		self._autofiring = nil
		self._autoshots_fired = nil
	end

	self._shooting_player = nil
	self._shooting_husk_unit = nil
	self._next_vis_ray_t = nil
	self._can_melee = nil

	if attention then
		local t = self._timer:time()

		self[self._ik_preset.start](self)

		local vis_state = self._ext_base:lod_stage()

		if vis_state and vis_state < 3 and self[self._ik_preset.get_blend](self) > 0 then
			self._aim_transition = {
				duration = 0.333,
				start_t = t,
				start_vec = mvec3_copy(self._common_data.look_vec)
			}
			self._get_target_pos = self._get_transition_target_pos
		else
			self._aim_transition = nil
			self._get_target_pos = nil
		end

		self._mod_enable_t = t + 0.5

		if attention.unit then
			local att_ext_base = attention.unit:base()

			if att_ext_base and att_ext_base.is_local_player then
				self._shooting_player = true
				attention.unit:movement():on_targetted_for_attack(true, self._unit)

				if self._melee_weapon_data then
					self._can_melee = true
				end
			elseif self._is_server then
				if att_ext_base and att_ext_base.is_husk_player then
					self._shooting_husk_unit = true
				elseif self._melee_weapon_data then
					if deathvox:IsTotalCrackdownEnabled() then
						if self._is_converted then
							if self._ext_movement._joker_melee_stagger then
								self._can_melee = true
								self._joker_melee_stagger = true
							end
						else
							self._can_melee = true
						end
					else
						self._can_melee = true
					end
				end
			else
				self._shooting_husk_unit = true
			end

			local target_pos, _, target_dis = CopActionShoot._get_target_pos(self, self._shoot_from_pos, attention)
			local usage_tweak = self._w_usage_tweak
			local shoot_hist = self._shoot_history
			local aim_delay = 0
			local aim_delay_minmax = self._aim_delay_minmax

			if shoot_hist then
				local displacement = mvec3_dis(target_pos, shoot_hist.m_last_pos)

				if displacement > self._focus_displacement then
					if draw_focus_displacement then
						local line = Draw:brush(Color.blue:with_alpha(0.5), 2)
						line:cylinder(self._shoot_from_pos, shoot_hist.m_last_pos, 0.5)
						line:cylinder(self._shoot_from_pos, target_pos, 0.5)
						line:cylinder(target_pos, shoot_hist.m_last_pos, 0.5)
					end

					if aim_delay_minmax[1] ~= 0 or aim_delay_minmax[2] ~= 0 then
						if aim_delay_minmax[1] == aim_delay_minmax[2] then
							aim_delay = aim_delay_minmax[1]
						else
							local dis_lerp = self._focus_displacement / displacement

							aim_delay = math_lerp(aim_delay_minmax[2], aim_delay_minmax[1], dis_lerp)
						end

						if self._common_data.is_suppressed then
							aim_delay = aim_delay * 1.5
						end
					end

					self._shoot_t = self._mod_enable_t + aim_delay
				end

				shoot_hist.m_last_pos = mvec3_copy(target_pos)

				if shoot_hist.u_key and shoot_hist.u_key ~= attention.unit:key() then
					shoot_hist.focus_start_t = t
					shoot_hist.focus_delay = self._focus_delay

					self._line_of_sight_t = nil
				end

				shoot_hist.u_key = attention.unit:key()
			else
				if aim_delay_minmax[1] ~= 0 or aim_delay_minmax[2] ~= 0 then
					if aim_delay_minmax[1] == aim_delay_minmax[2] then
						aim_delay = aim_delay_minmax[1]
					else
						local dis_lerp = math_min(1, target_dis / self._falloff[#self._falloff].r)

						aim_delay = math_lerp(aim_delay_minmax[1], aim_delay_minmax[2], dis_lerp)
					end

					if self._common_data.is_suppressed then
						aim_delay = aim_delay * 1.5
					end
				end

				self._shoot_t = self._mod_enable_t + aim_delay

				shoot_hist = {
					focus_start_t = t,
					focus_delay = self._focus_delay,
					m_last_pos = mvec3_copy(target_pos),
					u_key = attention.unit:key()
				}
				self._shoot_history = shoot_hist
			end
		end
	else
		self[self._ik_preset.stop](self)

		if self._aim_transition then
			self._aim_transition = nil
			self._get_target_pos = nil
		end
	end

	self._attention = attention
end

function CopActionShoot:update(t)
	local vis_state = self._ext_base:lod_stage()
	vis_state = vis_state or 4

	local cannot_fire_yet = self._weapon_base._next_fire_allowed > t

	if cannot_fire_yet and vis_state ~= 1 then
		if self._skipped_frames < vis_state * 3 then
			self._skipped_frames = self._skipped_frames + 1

			return
		else
			self._skipped_frames = 1
		end
	end

	local shoot_from_pos = self._shoot_from_pos
	local ext_anim = self._ext_anim
	local attention = self._attention
	local common_data = self._common_data
	local target_pos, target_vec, target_dis, shooting_local_player = nil

	if attention then
		target_pos, target_vec, target_dis, shooting_local_player = self:_get_target_pos(shoot_from_pos, attention, t)
		local tar_vec_flat = temp_vec2

		mvec3_set(tar_vec_flat, target_vec)
		mvec3_set_z(tar_vec_flat, 0)
		mvec3_norm(tar_vec_flat)

		local fwd = common_data.fwd
		local fwd_dot = mvec3_dot(fwd, tar_vec_flat)

		if self._turn_allowed then
			local active_actions = common_data.active_actions

			if not active_actions[2] or active_actions[2]:type() == "idle" then
				local queued_actions = common_data.queued_actions

				if not queued_actions or not queued_actions[1] and not queued_actions[2] then
					if not self._ext_movement:chk_action_forbidden("walk") then
						local fwd_dot_flat = mvec3_dot(tar_vec_flat, fwd)

						if fwd_dot_flat < 0.96 then
							local spin = tar_vec_flat:to_polar_with_reference(fwd, math_up).spin
							local new_action_data = {
								body_part = 2,
								type = "turn",
								angle = spin
							}

							self._ext_movement:action_request(new_action_data)
						end
					end
				end
			end
		end

		target_vec = self:_upd_ik(target_vec, fwd_dot, t)
	end

	local autofiring = self._autofiring

	if not ext_anim.reload and not ext_anim.equip and not ext_anim.melee then
		local can_melee = target_vec and common_data.allow_fire and self._can_melee and true or nil

		if can_melee then
			local melee_start_range = self._melee_weapon_data.range - 20

			if target_dis > melee_start_range then
				can_melee = nil
			end
		end

		local do_melee = can_melee and self:check_melee_start(t, attention.unit, target_dis, target_vec, shoot_from_pos, shooting_local_player) and self:_chk_start_melee(t)

		if do_melee then
			if autofiring then
				self._weapon_base:stop_autofire()

				self._autofiring = nil
				self._autoshots_fired = nil
			end

			self._shoot_t = t + 1
		elseif self._weapon_base:clip_empty() then
			if autofiring then
				self._weapon_base:stop_autofire()
				self._ext_movement:play_redirect("up_idle")

				self._autofiring = nil
				self._autoshots_fired = nil
			end

			if self._is_server and not ext_anim.recoil then
				self._exiting_to_reload = true

				local reload_action = {
					body_part = 3,
					type = "reload"
				}

				self._ext_movement:action_request(reload_action)
			end
		elseif autofiring then
			if not common_data.allow_fire or not target_vec then
				self._weapon_base:stop_autofire()

				self._shoot_t = t + 0.6
				self._autofiring = nil
				self._autoshots_fired = nil

				self._ext_movement:play_redirect("up_idle")
			elseif cannot_fire_yet then
				if not ext_anim.recoil and not ext_anim.base_no_recoil and not ext_anim.move and vis_state == 1 then
					--if self._tank_animations then
						--self._ext_movement:play_redirect("recoil_single")
					--else
						self._ext_movement:play_redirect("recoil_auto")
					--end
				end
			else
				local falloff, i_range = self:_get_shoot_falloff(target_dis, self._falloff)
				local dmg_buff = self._ext_base:get_total_buff("base_damage") + 1
				local dmg_mul = dmg_buff * falloff.dmg_mul
				local att_unit = attention.unit
				local shoot_hist = self._shoot_history
				local shooting_husk = self._shooting_husk_unit
				local simplified_shooting = not att_unit or shooting_husk
				local miss_pos = shoot_hist and not simplified_shooting and self:_get_unit_shoot_pos(t, target_pos, target_dis, falloff, i_range, shooting_local_player)

				if shoot_hist and att_unit then
					mvec3_set(self._shoot_history.m_last_pos, target_pos)
				end

				if miss_pos then
					mvec3_dir(target_vec, shoot_from_pos, miss_pos)
				else
					local spread = self._spread

					if shooting_husk then
						spread = spread + self._miss_dis * math_random() * 0.1
					elseif spread > 20 then
						spread = 20
					end

					if spread > 0 then
						local spread_pos = temp_vec2

						mvec3_rand_orth(spread_pos, target_vec)
						mvec3_set_l(spread_pos, spread)
						mvec3_add(spread_pos, target_pos)
						mvec3_dir(target_vec, shoot_from_pos, spread_pos)
					end
				end

				if self._weapon_base:trigger_held(shoot_from_pos, target_vec, dmg_mul, shooting_local_player, nil, nil, nil, att_unit) then
					if draw_target_vec_firing then
						local line = Draw:brush(Color.green:with_alpha(1), 0.1)
						line:cylinder(shoot_from_pos, shoot_from_pos + target_vec * target_dis, 5)
					end

					autofiring = self._autofiring

					if not autofiring or autofiring - 1 <= self._autoshots_fired then
						self._autofiring = nil
						self._autoshots_fired = nil

						self._weapon_base:stop_autofire()
						self._ext_movement:play_redirect("up_idle")

						local dis_lerp = math_min(1, target_dis / falloff.r)
						local shoot_delay = math_lerp(falloff.recoil[1], falloff.recoil[2], dis_lerp)

						if common_data.is_suppressed then
							shoot_delay = shoot_delay * 1.5
						end

						self._shoot_t = t + shoot_delay
					else
						if not ext_anim.recoil and not ext_anim.base_no_recoil and not ext_anim.move and vis_state == 1 then
							--if self._tank_animations then
								--self._ext_movement:play_redirect("recoil_single")
							--else
								self._ext_movement:play_redirect("recoil_auto")
							--end
						end

						self._autoshots_fired = self._autoshots_fired + 1
					end
				end
			end
		elseif common_data.allow_fire and target_vec and self._mod_enable_t < t then
			local can_shoot, shoot = true, nil

			if common_data.char_tweak.no_move_and_shoot then
				local walking = nil
				local lower_body_action = common_data.active_actions[2]

				if lower_body_action and lower_body_action:type() == "walk" then
					walking = true
				else
					local queued_actions = common_data.queued_actions

					if queued_actions then
						for i = #queued_actions, 1, -1 do
							local action = queued_actions[i]

							if action.type == "walk" then
								walking = true

								break
							end
						end
					end
				end

				if walking then
					can_shoot = nil

					local moving_cooldown = common_data.char_tweak.move_and_shoot_cooldown or 1

					self._shoot_t = t + moving_cooldown
				end
			end

			if can_shoot then
				if attention.unit then
					local shooting_husk = self._shooting_husk_unit

					if not shooting_husk or not self._next_vis_ray_t or self._next_vis_ray_t < t then
						if shooting_husk then
							self._next_vis_ray_t = t + 2
						end

						local fire_line_is_obstructed = self._unit:raycast("ray", shoot_from_pos, target_pos, "slot_mask", self._fire_line_slotmask, "ray_type", "ai_vision")

						if fire_line_is_obstructed then
							if not self._line_of_sight_t or t - self._line_of_sight_t > 5 then
								if draw_aim_delay_vis_proc then
									local draw_duration = shooting_husk and 4 or 2

									local line = Draw:brush(Color.yellow:with_alpha(0.5), draw_duration)
									line:cylinder(shoot_from_pos, fire_line_is_obstructed.position, 0.5)
								end

								local aim_delay = 0
								local aim_delay_minmax = self._aim_delay_minmax

								if aim_delay_minmax[1] ~= 0 or aim_delay_minmax[2] ~= 0 then
									if aim_delay_minmax[1] == aim_delay_minmax[2] then
										aim_delay = aim_delay_minmax[1]
									else
										local dis_lerp = math_min(1, target_dis / self._falloff[#self._falloff].r)

										aim_delay = math_lerp(aim_delay_minmax[1], aim_delay_minmax[2], dis_lerp)
									end

									if common_data.is_suppressed then
										aim_delay = aim_delay * 1.5
									end
								end

								self._shoot_t = t + aim_delay
							elseif fire_line_is_obstructed.distance > 300 then
								shoot = true
							end
						else
							local shield_in_the_way = nil

							if self._shooting_player or not self._weapon_base._use_armor_piercing then
								if self._shield then
									shield_in_the_way = self._unit:raycast("ray", shoot_from_pos, target_pos, "slot_mask", self._shield_slotmask, "ignore_unit", self._shield, "report")
								else
									shield_in_the_way = self._unit:raycast("ray", shoot_from_pos, target_pos, "slot_mask", self._shield_slotmask, "report")
								end
							end

							if not shield_in_the_way then
								shoot = true
							end

							if not self._line_of_sight_t or t - self._line_of_sight_t > 2 then
								if draw_focus_delay_vis_reset then
									local draw_duration = shooting_husk and 4 or 2

									local line = Draw:brush(Color.green:with_alpha(0.5), draw_duration)
									line:cylinder(shoot_from_pos, self._shoot_history.m_last_pos, 0.5)
									line:cylinder(shoot_from_pos, target_pos, 0.5)
									line:cylinder(target_pos, self._shoot_history.m_last_pos, 0.5)
								end

								self._shoot_history.focus_start_t = t
								self._shoot_history.focus_delay = self._focus_delay
							end

							self._shoot_history.m_last_pos = mvec3_copy(target_pos)
							self._line_of_sight_t = t
						end

						if draw_fire_line_ray then
							local draw_duration = shooting_husk and 2 or 0.1
							local line_to_pos = fire_line_is_obstructed and fire_line_is_obstructed.position or target_pos
							local line = fire_line_is_obstructed and Draw:brush(Color.red:with_alpha(0.2), draw_duration) or Draw:brush(Color.white:with_alpha(0.2), draw_duration)
							line:cylinder(shoot_from_pos, line_to_pos, 0.1)
						end

						self._last_vis_check_status = shoot
					else
						shoot = self._last_vis_check_status
					end
				else
					shoot = true
				end
			end

			--some of the calculations above still need to be done even if the weapon can't fire yet
			--hence why we should check for not cannot_fire_yet here, to prevent actual unnecessary calculations
			if shoot and not cannot_fire_yet and self._shoot_t < t then
				local falloff, i_range = self:_get_shoot_falloff(target_dis, self._falloff)
				local dmg_buff = self._ext_base:get_total_buff("base_damage") + 1
				local dmg_mul = dmg_buff * falloff.dmg_mul
				local att_unit = attention.unit
				local shoot_hist = self._shoot_history
				local shooting_husk = self._shooting_husk_unit
				local simplified_shooting = not att_unit or shooting_husk
				local miss_pos = shoot_hist and not simplified_shooting and self:_get_unit_shoot_pos(t, target_pos, target_dis, falloff, i_range, shooting_local_player)

				if shoot_hist and att_unit then
					mvec3_set(self._shoot_history.m_last_pos, target_pos)
				end

				if miss_pos then
					mvec3_dir(target_vec, shoot_from_pos, miss_pos)
				else
					local spread = self._spread

					if shooting_husk then
						spread = spread + self._miss_dis * math_random() * 0.1
					elseif spread > 20 then
						spread = 20
					end

					if spread > 0 then
						local spread_pos = temp_vec2

						mvec3_rand_orth(spread_pos, target_vec)
						mvec3_set_l(spread_pos, spread)
						mvec3_add(spread_pos, target_pos)
						mvec3_dir(target_vec, shoot_from_pos, spread_pos)
					end
				end

				local firemode = 1
				--local firemode, random_mode_roll = nil

				if self._automatic_weap and self._weapon_base:ammo_info() > 1 then
					firemode = falloff.mode and falloff.mode[1] or 1
					local falloff_modes = falloff.mode
					local random_mode_roll = math_random()
					--random_mode_roll = self:_pseudorandom()

					for i_mode = 1, #falloff_modes do
						local mode_chance = falloff_modes[i_mode]

						if random_mode_roll <= mode_chance then
							firemode = i_mode

							break
						end
					end
				end

				if firemode > 1 then
					self._weapon_base:start_autofire(firemode < 4 and firemode)

					if self._w_usage_tweak.autofire_rounds then
						if firemode < 4 then
							self._autofiring = firemode
						elseif falloff.autofire_rounds then
							local diff = falloff.autofire_rounds[2] - falloff.autofire_rounds[1]
							self._autofiring = math_ceil(falloff.autofire_rounds[1] + math_random() * diff)
							--self._autofiring = math_ceil(falloff.autofire_rounds[1] + random_mode_roll * diff)
						else
							local diff = self._w_usage_tweak.autofire_rounds[2] - self._w_usage_tweak.autofire_rounds[1]
							self._autofiring = math_ceil(self._w_usage_tweak.autofire_rounds[1] + math_random() * diff)
							--self._autofiring = math_ceil(self._w_usage_tweak.autofire_rounds[1] + random_mode_roll * diff)
						end
					end

					local shots_fired = 0

					--in case something else besides the timer is added to the function to prevent the gun from firing
					--however if you do something like this, you'd want to do something similar to the cannot_fire_yet, to avoid wasting performance
					if self._weapon_base:trigger_held(shoot_from_pos, target_vec, dmg_mul, shooting_local_player, nil, nil, nil, att_unit) then
						shots_fired = 1

						if draw_target_vec_firing then
							local line = Draw:brush(Color.green:with_alpha(1), 0.1)
							line:cylinder(shoot_from_pos, shoot_from_pos + target_vec * target_dis, 5)
						end
					end

					self._autoshots_fired = shots_fired

					if not ext_anim.recoil and not ext_anim.base_no_recoil and not ext_anim.move and vis_state == 1 then
						--if self._tank_animations then
							--self._ext_movement:play_redirect("recoil_single")
						--else
							self._ext_movement:play_redirect("recoil_auto")
						--end
					end
				elseif self._weapon_base:singleshot(shoot_from_pos, target_vec, dmg_mul, shooting_local_player, nil, nil, nil, att_unit) then
					if draw_target_vec_firing then
						local line = Draw:brush(Color.green:with_alpha(1), 0.1)
						line:cylinder(shoot_from_pos, shoot_from_pos + target_vec * target_dis, 5)
					end

					if not ext_anim.base_no_recoil and not ext_anim.move and vis_state == 1 then
						self._ext_movement:play_redirect("recoil_single")
					end

					local custom_singleshot_rof = self._weap_tweak.custom_single_fire_rate
					local recoil_1 = custom_singleshot_rof or falloff.recoil[1]
					local recoil_2 = custom_singleshot_rof and custom_singleshot_rof * i_range * 1.5 or falloff.recoil[2]

					local dis_lerp = math_min(1, target_dis / falloff.r)
					local shoot_delay = math_lerp(recoil_1, recoil_2, dis_lerp)

					if common_data.is_suppressed then
						shoot_delay = shoot_delay * 1.5
					end

					self._shoot_t = t + shoot_delay
				end
			end
		end
	end

	if ext_anim.base_need_upd then
		self._ext_movement:upd_m_head_pos()
	end
end

function CopActionShoot:_get_unit_shoot_pos(t, pos, dis, falloff, i_range, shooting_local_player)
	--local attention = self._attention
	local att_unit = self._attention.unit
	local shoot_hist = self._shoot_history
	local focus_prog = nil

	if shoot_hist and shoot_hist.focus_delay then
		local focus_delay = shoot_hist.focus_delay
		local att_dmg_ext = att_unit:character_damage()

		if att_dmg_ext and att_dmg_ext.focus_delay_mul then
			focus_delay = att_dmg_ext:focus_delay_mul() * focus_delay
		end

		if focus_delay > 0 then
			local time_passed = t - shoot_hist.focus_start_t
			focus_prog = time_passed / focus_delay
		end

		if not focus_prog or focus_prog >= 1 then
			shoot_hist.focus_delay = nil
			focus_prog = 1
		end
	else
		focus_prog = 1
	end

	local hit_chances = falloff.acc

	--values are interpolated between previous falloff entries unless using the first one
	if i_range == 1 then
		hit_chance = math_lerp(hit_chances[1], hit_chances[2], focus_prog)
	else
		local prev_falloff = self._falloff[i_range - 1]
		dis_lerp = math_min(1, (dis - prev_falloff.r) / (falloff.r - prev_falloff.r))

		local prev_range_hit_chance = math_lerp(prev_falloff.acc[1], prev_falloff.acc[2], focus_prog)
		hit_chance = math_lerp(prev_range_hit_chance, math_lerp(hit_chances[1], hit_chances[2], focus_prog), dis_lerp)
	end

	local common_data = self._common_data

	if common_data.is_suppressed then
		hit_chance = hit_chance * 0.5
	end

	local lower_body_action = common_data.active_actions[2]

	if lower_body_action and lower_body_action:type() == "dodge" then
		hit_chance = hit_chance * lower_body_action:accuracy_multiplier()
	end

	local dmg_ext = self._unit:character_damage()

	if dmg_ext.accuracy_multiplier then
		hit_chance = hit_chance * dmg_ext:accuracy_multiplier()
	end

	--anim_data and active_action checks don't quite work the same way
	--in this case, this one expires sooner to be more accurate with the dodging aspect of the animation
	local att_anim_data = att_unit:anim_data()

	if att_anim_data and att_anim_data.dodge then
		hit_chance = hit_chance * 0.5
	end
	
	local dodge_sniper_shot = nil
	local hit = nil
	
	if hit_chance >= 1 then
		hit = true
	elseif hit_chance > 0 then
		hit = math_random() < hit_chance
	end
		
	
	if shooting_local_player then
		if hit then
			if self._sniper_enemy and shooting_local_player then
				if att_unit:character_damage()._next_sniper_dodge_t then
					local pm_timer = managers.player:player_timer():time()
					if att_unit:character_damage()._next_sniper_dodge_t <= pm_timer then
						hit = nil
						
						att_unit:sound():play("bullet_whizby_medium", nil, false)
						att_unit:sound():play("bullet_whizby_medium", nil, false)
						att_unit:sound():play("bullet_whizby_medium", nil, false)
						att_unit:sound():play("bullet_whizby_medium", nil, false)
						att_unit:sound():play("clk_baton_swing", nil, false)
						att_unit:sound():play("clk_baton_swing", nil, false)
						
						att_unit:character_damage()._next_sniper_dodge_t = pm_timer + 10
						
						local params = {text = "NARROWLY AVOIDED A SNIPER'S SHOT!", time = 1}
						managers.hud._hud_hint:show(params)
					end
				end
			end
		end
	end
	
	if not hit then
		local enemy_vec = temp_vec2

		if shooting_local_player then
			mvec3_set(enemy_vec, pos)
		else
			local att_mov_ext = att_unit:movement()

			if not att_mov_ext or not att_mov_ext.m_com then
				mvec3_set(enemy_vec, pos)
			else
				mvec3_set(enemy_vec, att_mov_ext:m_com())
			end
		end

		mvec3_sub(enemy_vec, self._shoot_from_pos) --proper shooting pos, instead of the unit's m_pos (which is where they're standing on)

		local error_vec = Vector3()

		mvec3_cross(error_vec, enemy_vec, math_up)
		mrot_axis_angle(temp_rot1, enemy_vec, math_random(360))
		mvec3_rot(error_vec, temp_rot1)

		local miss_min_dis = shooting_local_player and 31 or 120
		local focus_dis = focus_prog == 1 and 0 or self._miss_dis * 0.1 * (1 - focus_prog)
		local error_vec_len = miss_min_dis + self._spread + focus_dis

		mvec3_set_l(error_vec, error_vec_len)
		mvec3_add(error_vec, pos)

		return error_vec
	end
end

function CopActionShoot:check_melee_start(t, att_unit, target_dis, target_vec, melee_from_pos, target_is_local_player)
	if self._melee_timeout_t >= t then
		return
	end

	local countered_t = self._common_data.melee_countered_t

	if countered_t and countered_t >= t then
		return
	end

	local att_base_ext, att_dmg_ext, is_sentry = nil

	if not target_is_local_player then
		att_base_ext = att_unit:base()

		if not att_base_ext or att_base_ext.is_husk_player then
			return
		end

		att_dmg_ext = att_unit:character_damage()

		--we can use bullet damage against turrets/sentries, but check for damage_melee against anything else
		if att_base_ext.sentry_gun then
			is_sentry = true
		elseif not att_dmg_ext.damage_melee then
			return
		end

		if att_dmg_ext.dead and att_dmg_ext:dead() then
			return
		end
	end

	local my_fwd = self._ext_movement:m_head_rot():z()

	mvec3_set(temp_vec3, my_fwd)
	mvec3_mul(temp_vec3, target_dis)
	mvec3_add(temp_vec3, melee_from_pos)

	mvec3_set(temp_vec4, target_vec)
	mvec3_set_z(temp_vec4, 0)
	mvec3_norm(temp_vec4)

	local melee_weap_data = self._melee_weapon_data
	local melee_start_range = melee_weap_data.range - 20
	local min_dot = math_lerp(0, 0.4, target_dis / melee_start_range)
	local fwd_dot = mvec3_dot(my_fwd, temp_vec4)

	if fwd_dot < min_dot then
		return
	end

	local obstructed_by_geometry = self._unit:raycast("ray", melee_from_pos, temp_vec3, "sphere_cast_radius", 10, "slot_mask", self._geometry_slotmask, "ray_type", "body melee", "report")

	if obstructed_by_geometry then
		return
	end

	local function chk_covered_by_shield()
		local hit_shield = self._unit:raycast("ray", melee_from_pos, temp_vec3, "sphere_cast_radius", 25, "slot_mask", self._shield_slotmask, "ray_type", "body melee", "report")

		if hit_shield then
			return true
		end
	end

	if target_is_local_player then
		if not melee_weap_data.electrical or not att_unit:movement():tased() then
			if not chk_covered_by_shield() then
				return true
			end
		end
	elseif is_sentry then
		if not melee_weap_data.electrical and not chk_covered_by_shield() then
			return true
		end
	elseif chk_covered_by_shield() then
		local att_inv_ext = att_unit:inventory()

		if att_inv_ext and alive(att_inv_ext._shield_unit) then
			local can_be_knocked = melee_weap_data.shield_knock and not att_base_ext.is_phalanx and att_base_ext:char_tweak().damage.shield_knocked and not att_dmg_ext:is_immune_to_shield_knockback()

			if can_be_knocked and not att_unit:movement():chk_action_forbidden("hurt") then
				return true
			end
		end
	elseif melee_weap_data.electrical then
		local char_tweak = att_base_ext:char_tweak()
		local can_be_tased = char_tweak.can_be_tased and true or char_tweak.can_be_tased == nil

		if can_be_tased and not att_unit:movement():chk_action_forbidden("hurt") then
			return true
		end
	else
		return true
	end
end

function CopActionShoot:_chk_start_melee(t)
	local melee_weap_data = self._melee_weapon_data
	local melee_weapon = melee_weap_data.melee_weapon
	local is_weapon = melee_weapon == "weapon"
	local redir_name = is_weapon and "melee" or "melee_item"
	local tank_melee = nil

	if is_weapon then
		if self._weap_tweak.usage == "mini" then
			redir_name = "melee_bayonet" --bash with the front of the minigun's barrel like in first person
		end
	elseif melee_weapon == "fists" and self._tank_animations then
		redir_name = "melee" --use tank_melee unique punching animation as originally intended
		tank_melee = true
	end

	local melee_res = self._ext_movement:play_redirect(redir_name)

	if not melee_res then
		return
	end

	if melee_weap_data.speed ~= 1 then
		self._common_data.machine:set_speed(melee_res, melee_weap_data.speed)
	end

	if not is_weapon and not tank_melee then
		if #melee_weap_data.anim_vars == 1 then
			self._common_data.machine:set_parameter(melee_res, melee_weap_data.anim_vars[1], 1)
		else
			local melee_var = math_random(#melee_weap_data.anim_vars)

			self._common_data.machine:set_parameter(melee_res, melee_weap_data.anim_vars[melee_var], 1)
		end

		if melee_weap_data.anim_param then
			self._common_data.machine:set_parameter(melee_res, melee_weap_data.anim_param, 1)
		end
	end

	--let other players see when NPCs attempt a melee attack instead of nothing (not actually cosmetic as melee attacks are tied to the animation, but the necessary checks to prevent issues with that are there)
	managers.network:session():send_to_peers_synched("play_distance_interact_redirect", self._unit, redir_name)

	if melee_weap_data.retry_delay[1] == melee_weap_data.retry_delay[2] then
		self._melee_timeout_t = t + melee_weap_data.retry_delay[1]
	else
		self._melee_timeout_t = t + math_lerp(melee_weap_data.retry_delay[1], melee_weap_data.retry_delay[2], math_random())
	end

	return true
end

function CopActionShoot:anim_clbk_melee_strike()
	local melee_weap_data = self._melee_weapon_data

	if not melee_weap_data then
		return
	end

	local melee_from_pos = self._shoot_from_pos
	local my_fwd = self._ext_movement:m_head_rot():z()

	mvec3_set(temp_vec3, my_fwd)
	mvec3_mul(temp_vec3, melee_weap_data.range)
	mvec3_add(temp_vec3, melee_from_pos)

	local melee_slotmask = melee_weap_data.slotmask
	local attention = self._attention

	if attention and attention.unit then
		local enemies_slot_mask = managers.slot:get_mask("enemies")

		if attention.unit:in_slot(enemies_slot_mask) and self._unit:in_slot(enemies_slot_mask) then
			melee_slotmask = managers.slot:get_mask("bullet_impact_targets")
		end
	end

	--similar to player melee attacks, use a sphere ray instead of just a normal plain ray
	local col_ray = self._unit:raycast("ray", melee_from_pos, temp_vec3, "sphere_cast_radius", 20, "slot_mask", melee_slotmask, "ray_type", "body melee")

	if draw_melee_sphere_rays then
		local draw_duration = 3
		local new_brush = col_ray and Draw:brush(Color.red:with_alpha(0.5), draw_duration) or Draw:brush(Color.white:with_alpha(0.5), draw_duration)
		local sphere_draw_pos = col_ray and col_ray.position or temp_vec3
		local sphere_draw_size = col_ray and 5 or 20
		new_brush:sphere(sphere_draw_pos, sphere_draw_size)
	end

	local local_player = nil

	--a more clean method of determining if the local player should get hit or not, without cancelling the attack if the player can't get hit, like it did before
	--sadly, no raycasts I tried so far (even with target_unit/target_body) seem to be able to hit the local player
	if melee_weap_data.hit_player then	
		local_player = managers.player:player_unit()

		if local_player and not self._unit:character_damage():is_friendly_fire(local_player) then
			local player_head_pos = local_player:movement():m_head_pos()
			local attack_dir = player_head_pos - melee_from_pos
			local player_distance = attack_dir:length()

			if player_distance <= melee_weap_data.range then
				if not col_ray or col_ray.distance > player_distance or not self._unit:raycast("ray", melee_from_pos, player_head_pos, "sphere_cast_radius", 5, "slot_mask", melee_slotmask, "ray_type", "body melee", "report") then
					mvec3_set(temp_vec4, attack_dir)
					mvec3_set_z(temp_vec4, 0)
					mvec3_norm(temp_vec4)
					mvec3_norm(attack_dir)

					local min_dot = math_lerp(0, 0.2, player_distance / melee_weap_data.range)
					local fwd_dot = mvec3_dot(my_fwd, temp_vec4)

					if fwd_dot >= min_dot then
						col_ray = {
							unit = local_player,
							position = mvec3_copy(player_head_pos),
							ray = attack_dir
						}

						if draw_melee_sphere_rays then
							local draw_duration = 3
							local new_brush = Draw:brush(Color.yellow:with_alpha(0.5), draw_duration)
							local sphere_draw_pos = player_head_pos
							local sphere_draw_size = 5
							new_brush:sphere(sphere_draw_pos, sphere_draw_size)
						end
					end
				end
			end
		end
	end

	if not col_ray or not alive(col_ray.unit) then
		return
	end

	local is_server = self._is_server
	local melee_weapon = melee_weap_data.melee_weapon
	local damage = melee_weap_data.damage
	local dmg_buff = self._ext_base:get_total_buff("base_damage") + 1
	damage = damage * melee_weap_data.dmg_mul * dmg_buff

	managers.game_play_central:physics_push(col_ray) --the function already has sanity checks so it's fine to just use it like this

	local hit_unit = col_ray.unit
	local character_unit, shield_knock, defense_data = nil

	if is_server and melee_weap_data.shield_knock and hit_unit:in_slot(self._shield_slotmask) then
		local parent = hit_unit:parent()

		if alive(parent) then
			local parent_base_ext = parent:base()
			local can_be_knocked = parent_base_ext and not parent_base_ext.is_phalanx and parent_base_ext:char_tweak().damage.shield_knocked and not parent:character_damage():is_immune_to_shield_knockback()

			if can_be_knocked then
				shield_knock = true
				character_unit = parent
			end
		end
	end

	character_unit = character_unit or hit_unit

	local unit_dmg_ext = character_unit:character_damage()
	local unit_base_ext = character_unit:base()

	if local_player and character_unit == local_player then
		local action_data = {
			variant = "melee",
			damage = damage,
			weapon_unit = self._weapon_unit,
			attacker_unit = self._unit,
			melee_weapon = melee_weapon,
			push_vel = mvec3_copy(col_ray.ray:with_z(0.1)) * 600,
			tase_player = melee_weap_data.electrical and true or nil,
			col_ray = col_ray
		}

		defense_data = unit_dmg_ext:damage_melee(action_data)
	elseif is_server then --only allow melee damage against NPCs for the host (used in case an enemy targets a client locally but hits something else instead)
		if unit_dmg_ext then
			if unit_base_ext and unit_base_ext.sentry_gun then
				local action_data = {
					variant = "bullet",
					damage = damage,
					weapon_unit = self._weapon_unit,
					attacker_unit = self._unit,
					origin = mvec3_copy(melee_from_pos),
					col_ray = col_ray
				}

				defense_data = unit_dmg_ext:damage_bullet(action_data) --sentries/turrets lack a melee damage function
			elseif unit_dmg_ext.damage_melee then
				if not unit_base_ext or not unit_base_ext.is_husk_player then --ignore player husks as the damage CAN be synced and dealt to them
					local variant = shield_knock and "melee" or melee_weap_data.electrical and "taser_tased" or "melee"
					local action_data = {
						variant = variant,
						damage = shield_knock and 0 or damage,
						damage_effect = shield_knock and 0 or self._joker_melee_stagger and unit_dmg_ext._health or damage * 2,
						weapon_unit = melee_weapon == "weapon" and self._weapon_unit or nil,
						attacker_unit = self._unit,
						name_id = melee_weapon,
						shield_knock = shield_knock,
						col_ray = col_ray
					}

					defense_data = unit_dmg_ext:damage_melee(action_data)
				end
			end
		end

		if character_unit:damage() and col_ray.body:extension() and col_ray.body:extension().damage then --damage objects with body extensions (like glass), just like players are able to
			damage = math_clamp(damage, 0, 63)

			col_ray.body:extension().damage:damage_melee(self._unit, col_ray.normal, col_ray.position, col_ray.ray, damage)
			managers.network:session():send_to_peers_synched("sync_body_damage_melee", col_ray.body, self._unit, col_ray.normal, col_ray.position, col_ray.ray, damage)
		end
	end

	if not defense_data or defense_data == "friendly_fire" then
		return
	end

	if defense_data == "countered" then
		self._common_data.melee_countered_t = self._timer:time() + 15

		local my_com = self._ext_movement:m_com()
		local attack_dir = my_com - character_unit:movement():m_head_pos()
		mvec3_norm(attack_dir)

		local counter_data = {
			damage = 0,
			damage_effect = 1,
			variant = "counter_spooc",
			attacker_unit = character_unit,
			attack_dir = attack_dir,
			col_ray = {
				position = mvec3_copy(my_com),
				body = self._unit:body("body"),
				ray = attack_dir
			},
			name_id = character_unit == local_player and managers.blackmarket:equipped_melee_weapon() or character_unit:base():melee_weapon()
		}

		self._unit:character_damage():damage_melee(counter_data)
	elseif not shield_knock and character_unit ~= local_player and unit_dmg_ext and not unit_dmg_ext._no_blood then
		if not unit_base_ext or unit_base_ext.sentry_gun then
			managers.game_play_central:play_impact_sound_and_effects({
				no_decal = true,
				col_ray = col_ray
			})
		else
			managers.game_play_central:sync_play_impact_flesh(col_ray.position, col_ray.ray)
		end
	end
end
