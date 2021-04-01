local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_set_l = mvector3.set_length
local mvec3_sub = mvector3.subtract
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_dot = mvector3.dot
local mvec3_cross = mvector3.cross
local mvec3_norm = mvector3.normalize
local mvec3_dir = mvector3.direction
local mvec3_rand_orth = mvector3.random_orthogonal
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_copy = mvector3.copy
local mvec3_lerp = mvector3.lerp

local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_vec3 = Vector3()
local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
local temp_vec3 = Vector3()

local mrot_set = mrotation.set_yaw_pitch_roll

local math_abs = math.abs
local math_lerp = math.lerp
local math_floor = math.floor
local math_random = math.random
local math_rand = math.rand
local math_randomseed = math.randomseed
local math_ceil = math.ceil
local math_UP = math.UP
local math_clamp = math.clamp
local math_min = math.min
local math_max = math.max
local math_pow = math.pow
local math_bezier = math.bezier
local bezier_curve = {
	0,
	0,
	1,
	1
}

local table_insert = table.insert
local table_index_of = table.index_of

local pairs_g = pairs
local tostring_g = tostring

local idstr_func = Idstring
local ids_empty = idstr_func("")
local ids_base = idstr_func("base")
local ids_upper_body = idstr_func("upper_body")
local ids_bone_spine = idstr_func("Spine")
local ids_root_follow = idstr_func("root_follow")
local ids_hips = idstr_func("Hips")
local ids_dragons_breath_effect = idstr_func("effects/payday2/particles/impacts/sparks/dragons_breath_hit_effect")
local ids_look_head = idstr_func("look_head")
local ids_aim_r_arm = idstr_func("aim_r_arm")
local ids_action_upper_body = idstr_func("action_upper_body")
local ids_movement = idstr_func("movement")
local ids_expl_physics = idstr_func("physic_effects/body_explosion")

local world_g = World

CopActionHurt._ik_presets = {
	spine_head_r_arm = {
		update = "_update_spine_head_r_arm",
		start = "_begin_spine_head_r_arm",
		get_blend = "_get_blend_spine_head_r_arm",
		stop = "_stop_spine_head_r_arm"
	},
	r_arm = {
		update = "_update_ik_r_arm",
		start = "_begin_ik_r_arm",
		get_blend = "_get_blend_ik_r_arm",
		stop = "_stop_ik_r_arm"
	}
}

CopActionHurt.network_allowed_hurt_types = {
	light_hurt = true,
	shield_knock = true,
	hurt = true,
	heavy_hurt = true,
	death = true,
	fatal = true,
	fire_hurt = true,
	poison_hurt = true,
	bleedout = true,
	knock_down = true,
	expl_hurt = true,
	stagger = true,
	hurt_sick = true,
	counter_tased = true,
	taser_tased = true,
	concussion = true,
	healed = true
}

function CopActionHurt:init(action_desc, common_data)
	self._common_data = common_data
	self._ext_base = common_data.ext_base
	self._ext_brain = common_data.ext_brain
	self._ext_damage = common_data.ext_damage
	self._ext_movement = common_data.ext_movement
	self._ext_inventory = common_data.ext_inventory
	self._ext_anim = common_data.ext_anim
	self._body_part = action_desc.body_part
	self._unit = common_data.unit
	self._machine = common_data.machine
	self._attention = common_data.attention
	self._action_desc = action_desc
	self._variant = action_desc.variant
	self._is_server = Network:is_server()
	self._timer = TimerManager:game()

	if action_desc.sync_t then
		self._timer_offset = Application:time() - action_desc.sync_t
	end

	local t = self._timer:time()
	local tweak_table = common_data.ext_base._tweak_table
	local is_civilian = CopDamage.is_civilian(tweak_table)
	local is_female, uses_shield_anims, taser_tased_tasing = nil
	local is_stealth = managers.groupai:state():whisper_mode()

	if common_data.machine:get_global("female") == 1 then
		is_female = true
	end

	if common_data.machine:get_global("shield") == 1 then
		uses_shield_anims = true
	end

	local death_type = action_desc.death_type
	local crouching = common_data.ext_anim.crouch or common_data.ext_anim.hurt and common_data.machine:get_parameter(common_data.machine:segment_state(ids_base), "crh") > 0
	local redir_res = nil
	local action_type = action_desc.hurt_type

	if action_type == "stagger" then
		action_type = "hurt"
	elseif action_type == "knock_down" then
		action_type = "expl_hurt"
	end

	self._hurt_type = action_type

	if action_type == "fatal" then
		redir_res = common_data.ext_movement:play_redirect("fatal")

		if not redir_res then
			return
		end

		managers.hud:set_mugshot_downed(common_data.unit:unit_data().mugshot_id)

		self._floor_normal = self:_get_floor_normal(common_data.pos, common_data.fwd, common_data.right)
	elseif action_type == "bleedout" then
		redir_res = common_data.ext_movement:play_redirect("bleedout")

		if not redir_res then
			return
		end

		self.update = self._upd_bleedout_enter

		self._floor_normal = self:_get_floor_normal(common_data.pos, common_data.fwd, common_data.right)

		if common_data.ext_inventory then
			if self._is_server then
				common_data.ext_inventory:equip_selection(1, true)
			end

			local weapon_unit = common_data.ext_inventory:equipped_unit()

			if weapon_unit then
				self._weapon_unit = weapon_unit

				local weap_base = weapon_unit:base()
				self._weapon_base = weap_base

				local weap_tweak = weap_base:weapon_tweak_data()
				local weapon_usage_tweak = common_data.char_tweak.weapon[weap_tweak.usage]

				self._weap_tweak = weap_tweak
				self._w_usage_tweak = weapon_usage_tweak
				self._aim_delay_minmax = weapon_usage_tweak.aim_delay or {0, 0}
				self._focus_delay = weapon_usage_tweak.focus_delay or 0
				self._focus_displacement = weapon_usage_tweak.focus_dis or 500
				self._spread = weapon_usage_tweak.spread or 20
				self._miss_dis = weapon_usage_tweak.miss_dis or 30
				self._automatic_weap = weap_tweak.auto and weapon_usage_tweak.autofire_rounds and true or nil
				self._reload_speed = weapon_usage_tweak.RELOAD_SPEED
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
			end

			self._anim = redir_res
			self._shoot_t = t

			self._shoot_from_pos = common_data.ext_movement:m_head_pos()
			self._shield_slotmask = managers.slot:get_mask("enemy_shield_check")
			self._fire_line_slotmask = managers.slot:get_mask("AI_visibility")

			local preset_data = self._ik_presets["r_arm"]
			self._ik_preset = preset_data
			self[preset_data.start](self)

			self._skipped_frames = 1
		end
	elseif action_desc.variant == "tase" then
		redir_res = common_data.ext_movement:play_redirect("tased")

		if not redir_res then
			return
		end

		managers.hud:set_mugshot_tased(common_data.unit:unit_data().mugshot_id)

		self.update = self._upd_tased
	elseif action_type == "fire_hurt" or action_type == "light_hurt" and action_desc.variant == "fire" then
		redir_res = common_data.ext_movement:play_redirect("fire_hurt")

		if not redir_res then
			return
		end

		if action_desc.ignite_character == "dragonsbreath" then
			self:_dragons_breath_sparks()
		end

		local fwd_dot = action_desc.direction_vec:dot(common_data.fwd)
		local right_dot = action_desc.direction_vec:dot(common_data.right)
		local dir_str = nil

		if math_abs(right_dot) < math_abs(fwd_dot) then
			if fwd_dot < 0 then
				dir_str = "fwd"
			else
				dir_str = "bwd"
			end
		elseif right_dot > 0 then
			dir_str = "l"
		else
			dir_str = "r"
		end

		common_data.machine:set_parameter(redir_res, dir_str, 1)
	elseif action_type == "taser_tased" then
		local can_be_tased = nil
		local tase_time = not uses_shield_anims and common_data.ext_damage._tased_time

		if tase_time then
			self._tased_time = t + tase_time
			common_data.ext_damage._tased_time = nil

			redir_res = self._ext_movement:play_redirect("tased")

			if not redir_res then
				return
			end

			taser_tased_tasing = true

			self.update = self._upd_tased
		else
			redir_res = common_data.ext_movement:play_redirect("taser")

			if not redir_res then
				return
			end

			local anim_roll = self:_pseudorandom(4)
			local anim_parameter = "var" .. tostring_g(anim_roll)

			common_data.machine:set_parameter(redir_res, anim_parameter, 1)
		end

		if self._tased_effect then
			world_g:effect_manager():fade_kill(self._tased_effect)

			self._tased_effect = nil
		end

		local tase_effect_table = common_data.ext_damage._tase_effect_table

		if tase_effect_table then
			self._tased_effect = world_g:effect_manager():spawn(tase_effect_table)
		end
	elseif action_type == "light_hurt" then
		if common_data.ext_anim.upper_body_active and not common_data.ext_anim.upper_body_empty and not common_data.ext_anim.recoil then
			return
		end

		redir_res = common_data.ext_movement:play_redirect(action_type)

		if not redir_res then
			return
		end

		local dir_str = nil
		local fwd_dot = action_desc.direction_vec:dot(common_data.fwd)

		if fwd_dot < 0 then
			if action_desc.direction_vec:dot(common_data.right) > 0 then
				dir_str = "l"
			else
				dir_str = "r"
			end
		else
			dir_str = "bwd"
		end

		common_data.machine:set_parameter(redir_res, dir_str, 1)

		local height_str = common_data.ext_movement:m_com().z < action_desc.hit_pos.z and "high" or "low"

		common_data.machine:set_parameter(redir_res, height_str, 1)

		self._expired = true

		return true
	elseif action_type == "concussion" then
		local redir_name = "concussion_stun"
		redir_res = common_data.ext_movement:play_redirect(redir_name)

		if not redir_res then
			return
		end

		local variant = nil

		if uses_shield_anims then
			variant = "var" .. tostring_g(self:_pseudorandom(4))
		else
			local fwd_dot = action_desc.direction_vec:dot(common_data.fwd)
			local right_dot = action_desc.direction_vec:dot(common_data.right)

			if math_abs(right_dot) < math_abs(fwd_dot) then
				if fwd_dot < 0 then
					local rnd_anim = self:_pseudorandom(6)

					if rnd_anim == 1 then
						variant = "bwd"
					else
						rnd_anim = rnd_anim - 1
						variant = "var" .. tostring_g(rnd_anim)
					end
				else
					variant = "fwd"
				end
			elseif right_dot > 0 then
				variant = "r"
			else
				variant = "l"
			end
		end

		common_data.machine:set_parameter(redir_res, variant, 1)
	elseif action_type == "hurt_sick" then
		local ecm_hurts_table = common_data.char_tweak.ecm_hurts

		if not ecm_hurts_table then
			return
		end

		redir_res = common_data.ext_movement:play_redirect("hurt_sick")

		if not redir_res then
			return
		end

		local sick_variants = {}

		for k, v in pairs_g(ecm_hurts_table) do
			sick_variants[#sick_variants + 1] = k
		end

		local variant = #sick_variants == 1 and sick_variants[1] or sick_variants[self:_pseudorandom(#sick_variants)]

		for i = 1, #sick_variants do
			local hurt = sick_variants[i]
			local anim_global_param = hurt == variant and 1 or 0

			common_data.machine:set_global(hurt, anim_global_param)
		end

		local duration_diff = ecm_hurts_table[variant].max_duration - ecm_hurts_table[variant].min_duration
		local duration = ecm_hurts_table[variant].min_duration + duration_diff * self:_pseudorandom()

		self._sick_time = t + duration
		self.update = self._upd_sick
	elseif action_type == "poison_hurt" then
		redir_res = common_data.ext_movement:play_redirect("hurt_poison")

		if not redir_res then
			return
		end
	else
		local keep_checking = true

		if action_type == "death" then
			if action_desc.variant == "fire" then
				keep_checking = nil

				local variant = 0

				if common_data.ext_anim.ragdoll or common_data.ext_movement:died_on_rope() then
					self:force_ragdoll()
				else
					redir_res = common_data.ext_movement:play_redirect("death_fire")

					if not redir_res then
						return
					end

					self:_prepare_ragdoll()

					variant = 1

					local variant_count = #self.fire_death_anim_variants_length

					if variant_count > 1 then
						variant = self:_pseudorandom(variant_count)
					end

					for i = 1, variant_count do
						local state_value = i == variant and 1 or 0

						common_data.machine:set_parameter(redir_res, "var" .. tostring_g(i), state_value)
					end
				end

				self:_start_enemy_fire_effect_on_death(variant)
				managers.fire:check_achievemnts(common_data.unit, t)
			elseif action_desc.variant == "poison" or action_desc.variant == "dot" then
				keep_checking = nil
				self:force_ragdoll()
			else
				if not common_data.char_tweak.no_run_death_anim then
					if common_data.ext_anim.run and common_data.ext_anim.move_fwd or common_data.ext_anim.sprint then
						keep_checking = nil

						redir_res = common_data.ext_movement:play_redirect("death_run")

						if not redir_res then
							return
						end

						self:_prepare_ragdoll()

						local variant_type = is_female and "female" or "male"
						local variant = self.running_death_anim_variants[variant_type] or 1

						if variant > 1 then
							variant = self:_pseudorandom(variant)
						end

						common_data.machine:set_parameter(redir_res, "var" .. tostring_g(variant), 1)
					end
				end

				self._floor_normal = self:_get_floor_normal(common_data.pos, common_data.fwd, common_data.right)
			end

			if keep_checking then
				if common_data.ext_anim.run or common_data.ext_anim.ragdoll then
					keep_checking = nil
					self:force_ragdoll()
				end
			end
		elseif action_type == "heavy_hurt" then
			if common_data.ext_anim.run and common_data.ext_anim.move_fwd or common_data.ext_anim.sprint then
				if not common_data.is_suppressed and not crouching then
					keep_checking = nil
					redir_res = common_data.ext_movement:play_redirect("heavy_run")

					if not redir_res then
						return
					end

					local variant = self.running_hurt_anim_variants.fwd or 1

					if variant > 1 then
						variant = self:_pseudorandom(variant)
					end

					common_data.machine:set_parameter(redir_res, "var" .. tostring_g(variant), 1)
				end
			end
		end

		if keep_checking then
			local variant, height, old_variant, old_info = nil

			if common_data.ext_anim.hurt then
				if action_type == "hurt" or action_type == "heavy_hurt" then
					local machine = common_data.machine
					local segment_state_base = machine:segment_state(ids_base)
					local get_param_f = machine.get_parameter

					for i = 1, self.hurt_anim_variants_highest_num do
						if get_param_f(machine, segment_state_base, "var" .. i) then
							old_variant = i

							break
						end
					end

					if old_variant ~= nil then
						old_info = {
							fwd = get_param_f(machine, segment_state_base, "fwd"),
							bwd = get_param_f(machine, segment_state_base, "bwd"),
							l = get_param_f(machine, segment_state_base, "l"),
							r = get_param_f(machine, segment_state_base, "r"),
							high = get_param_f(machine, segment_state_base, "high"),
							low = get_param_f(machine, segment_state_base, "low"),
							crh = get_param_f(machine, segment_state_base, "crh"),
							mod = get_param_f(machine, segment_state_base, "mod"),
							hvy = get_param_f(machine, segment_state_base, "hvy")
						}
					end
				end
			end

			local redirect = action_type

			if action_type == "shield_knock" then
				local rand = self:_pseudorandom(self.shield_knock_variants) - 1
				redirect = "shield_knock_var" .. tostring_g(rand)
			end

			if redirect then
				redir_res = common_data.ext_movement:play_redirect(redirect)
			end

			if not redir_res then
				return
			end

			if action_desc.variant ~= "bleeding" then
				local nr_variants = common_data.ext_anim.base_nr_variants

				if nr_variants then
					variant = 1

					if nr_variants > 1 then
						if action_type == "death" then
							--var0 is normally missing because 0 isn't among the possible rolls normally
							variant = self:_pseudorandom(0, nr_variants)
						else
							variant = self:_pseudorandom(nr_variants)
						end
					end
				else
					local fwd_dot = action_desc.direction_vec:dot(common_data.fwd)
					local right_dot = action_desc.direction_vec:dot(common_data.right)
					local dir_str = nil

					if math_abs(right_dot) < math_abs(fwd_dot) then
						if fwd_dot < 0 then
							dir_str = "fwd"
						else
							dir_str = "bwd"
						end
					elseif right_dot > 0 then
						dir_str = "l"
					else
						dir_str = "r"
					end

					common_data.machine:set_parameter(redir_res, dir_str, 1)

					local hit_z = action_desc.hit_pos.z
					height = common_data.ext_movement:m_com().z < hit_z and "high" or "low"

					if action_type == "death" then
						if is_civilian then
							death_type = "normal"
						end

						local pose_type = crouching and "crouching" or "not_crouching"

						if is_female then
							variant = self.death_anim_fe_variants[death_type][pose_type][dir_str][height]
						else
							variant = self.death_anim_variants[death_type][pose_type][dir_str][height]
						end

						if variant > 1 then
							variant = self:_pseudorandom(0, variant)
						end

						self:_prepare_ragdoll()
					elseif action_type == "counter_tased" then
						if self._tased_effect then
							world_g:effect_manager():fade_kill(self._tased_effect)

							self._tased_effect = nil
						end

						local tase_effect_table = common_data.ext_damage._tase_effect_table

						if tase_effect_table then
							self._tased_effect = world_g:effect_manager():spawn(tase_effect_table)
						end
					elseif action_type ~= "shield_knock" and action_type ~= "taser_tased" then
						if old_variant then
							if old_info[dir_str] == 1 and old_info[height] == 1 and old_info.mod == 1 and action_type == "hurt" or old_info.hvy == 1 and action_type == "heavy_hurt" then
								variant = old_variant
							end
						end

						if not variant then
							if action_type == "expl_hurt" then
								variant = self.hurt_anim_variants[action_type][dir_str]
							else
								variant = self.hurt_anim_variants[action_type].not_crouching[dir_str][height]
							end

							if variant > 1 then
								variant = self:_pseudorandom(variant)
							end
						end
					end
				end

				variant = variant or 1

				common_data.machine:set_parameter(redir_res, "var" .. tostring_g(variant), 1)

				if height then
					common_data.machine:set_parameter(redir_res, height, 1)
				end

				if crouching then
					common_data.machine:set_parameter(redir_res, "crh", 1)
				end

				if action_type == "hurt" then
					common_data.machine:set_parameter(redir_res, "mod", 1)
				elseif action_type == "heavy_hurt" then
					common_data.machine:set_parameter(redir_res, "hvy", 1)
				elseif action_type == "death" then
					if not is_civilian then
						if death_type == "heavy" or action_desc.death_type == "heavy" then
							common_data.machine:set_parameter(redir_res, "heavy", 1)
						end
					end
				elseif action_type == "expl_hurt" then
					common_data.machine:set_parameter(redir_res, "expl", 1)
				end
			end
		end
	end

	if not self._ragdolled then
		if common_data.ext_anim.upper_body_active then
			common_data.ext_movement:play_redirect("up_idle")
		end

		if self.update == nil then
			if common_data.ext_anim.skip_force_to_graph then
				self.update = self._upd_empty
			else
				self.update = self._upd_hurt
			end
		end
	end

	self._last_vel_z = 0

	local shoot_chance, tase_shooting, equipped_weapon, weap_base = nil

	if not uses_shield_anims and common_data.ext_inventory and not self._weapon_dropped and not common_data.ext_movement:cool() then
		equipped_weapon = common_data.ext_inventory:equipped_unit()

		if equipped_weapon then
			weap_base = equipped_weapon:base()

			if weap_base then
				if not weap_base.clip_empty or not weap_base:clip_empty() then
					if taser_tased_tasing or action_desc.variant == "tase" then
						shoot_chance = 1
						tase_shooting = true
					elseif action_type == "counter_tased" or action_type == "taser_tased" then
						shoot_chance = 1
					elseif not is_stealth then
						if action_type == "death" then
							if common_data.char_tweak.shooting_death then
								shoot_chance = 0.1
							end
						elseif action_type == "hurt" or action_type == "heavy_hurt" or action_type == "expl_hurt" or action_type == "fire_hurt" then
							shoot_chance = 0.1
						end
					end
				end
			end
		end
	end

	if shoot_chance then
		if shoot_chance == 1 or self:_pseudorandom() <= shoot_chance then
			self._weapon_unit = equipped_weapon
			self._weapon_base = weap_base

			common_data.unit:movement():set_friendly_fire(true)
			self._friendly_fire = true

			--restore friendly fire on hurts, but only on the server and while preventing it from hitting civs or hostages
			if self._is_server and not common_data.ext_base.nick_name then
				if action_type == "death" then
					local shooting_death_mask = managers.slot:get_mask("bullet_impact_targets_shooting_death")
					local civilian_mask = managers.slot:get_mask("civilians")
					local hostage_mask = 22
					shooting_death_mask = shooting_death_mask - civilian_mask - hostage_mask

					self._weapon_base:set_bullet_hit_slotmask(shooting_death_mask)
				else
					self._original_slot_mask = self._original_slot_mask or deep_clone(self._weapon_base._bullet_slotmask)

					local civilian_mask = managers.slot:get_mask("civilians")
					local hostage_mask = 22
					local new_slot_mask = self._original_slot_mask - civilian_mask - hostage_mask
					self._weapon_base:set_bullet_hit_slotmask(new_slot_mask)
					self._changed_slot_mask = new_slot_mask
				end
			end

			local weap_tweak = weap_base:weapon_tweak_data()
			local weapon_usage_tweak = common_data.char_tweak.weapon[weap_tweak.usage]

			self._spread = weapon_usage_tweak.spread or 20

			if tase_shooting then
				self._shooting_hurt_tase = true

				local weap_tweak = weap_base:weapon_tweak_data()
				local weapon_usage_tweak = common_data.char_tweak.weapon[weap_tweak.usage]
				self._weap_tweak = weap_tweak
				self._w_usage_tweak = weapon_usage_tweak
				self._aim_delay_minmax = weapon_usage_tweak.aim_delay or {0, 0}
				self._focus_delay = weapon_usage_tweak.focus_delay or 0
				self._focus_displacement = weapon_usage_tweak.focus_dis or 500
				self._miss_dis = weapon_usage_tweak.miss_dis or 30
				self._automatic_weap = weap_tweak.auto and weapon_usage_tweak.autofire_rounds and true or nil
				self._reload_speed = weapon_usage_tweak.RELOAD_SPEED
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
				self._anim = redir_res
				self._shoot_t = t + 1

				self._shoot_from_pos = common_data.ext_movement:m_head_pos()

				local preset_data = self._ik_presets["spine_head_r_arm"]
				self._ik_preset = preset_data
				self[preset_data.start](self)

				self._skipped_frames = 1

				self:on_attention(common_data.attention)
			elseif weap_base:weapon_tweak_data().auto then
				weap_base:start_autofire()

				self._shooting_hurt = true
			else
				self._delayed_shooting_hurt_clbk_id = "shooting_hurt" .. tostring_g(common_data.unit:key())

				managers.enemy:add_delayed_clbk(self._delayed_shooting_hurt_clbk_id, callback(self, self, "clbk_shooting_hurt"), t + 0.2)
			end
		end
	end

	if not common_data.ext_base.nick_name then
		if action_desc.variant == "fire" then
			if action_type == "fire_hurt" then
				common_data.unit:sound():say("burnhurt")
			elseif action_type == "death" then
				if common_data.ext_base:has_tag("tank") then
					if common_data.char_tweak.die_sound_event then
						common_data.unit:sound():say(common_data.char_tweak.die_sound_event)
					else
						common_data.unit:sound():say("x02a_any_3p")
					end
				else
					common_data.unit:sound():say("burndeath")

					if common_data.ext_base:has_tag("spooc") and common_data.char_tweak.die_sound_event then
						common_data.unit:sound():play(common_data.char_tweak.die_sound_event)
					end
				end
			end
		elseif action_type == "death" then
			if common_data.ext_base:has_tag("spooc") then
				if common_data.char_tweak.die_sound_event then
					common_data.unit:sound():play(common_data.char_tweak.die_sound_event)
				end

				common_data.unit:sound():say("x02a_any_3p")
			elseif common_data.char_tweak.die_sound_event then
				common_data.unit:sound():say(common_data.char_tweak.die_sound_event)
			else
				common_data.unit:sound():say("x02a_any_3p")
			end
		elseif action_type == "counter_tased" or action_type == "taser_tased" or action_desc.variant == "tase" then
			if common_data.ext_base:has_tag("taser") then
				common_data.unit:sound():say("tasered")
			else
				common_data.unit:sound():say("x01a_any_3p")
			end
		elseif action_type == "hurt_sick" then
			if common_data.ext_base:has_tag("medic") or common_data.ext_base:has_tag("taser") or common_data.ext_base:has_tag("spooc") then
				common_data.unit:sound():say("burndeath")
			else
				if common_data.ext_base:has_tag("law") and not common_data.ext_base:has_tag("special") then
					common_data.unit:sound():say("ch3")
				else
					common_data.unit:sound():say("x01a_any_3p")
				end
			end
		else
			common_data.unit:sound():say("x01a_any_3p")
		end

		if action_type == "death" and common_data.ext_base:has_tag("tank") then
			local unit_id = common_data.unit:id()

			--unit was already detached from the network, fetch the original id
			if unit_id == -1 then
				local corpse_data = managers.enemy:get_corpse_unit_data_from_key(common_data.unit:key())
				local actual_id = corpse_data and corpse_data.u_id

				if actual_id then
					unit_id = actual_id
				end
			end

			managers.fire:remove_dead_dozer_from_overgrill(unit_id)
		end

		if self._is_server then
			local radius = nil

			if is_stealth then
				local default_radius = tweak_data.upgrades.cop_hurt_alert_radius_whisper

				if action_type == "fire_hurt" or action_type == "fire_death" then
					radius = default_radius * 3
				else
					if action_desc.attacker_unit and alive(action_desc.attacker_unit) and action_desc.attacker_unit:base() then
						if action_desc.attacker_unit:base().is_local_player then
							radius = managers.player:upgrade_value("player", "silent_kill", default_radius)
						elseif action_desc.attacker_unit:base().upgrade_value then
							radius = action_desc.attacker_unit:base():upgrade_value("player", "silent_kill") or default_radius
						end
					end

					radius = radius or default_radius
				end
			else
				radius = tweak_data.upgrades.cop_hurt_alert_radius

				if action_type == "fire_hurt" or action_type == "fire_death" then
					radius = radius * 3
				end
			end

			local new_alert = {
				"vo_distress",
				common_data.ext_movement:m_head_pos(),
				radius,
				common_data.ext_brain:SO_access(),
				common_data.unit
			}

			managers.groupai:state():propagate_alert(new_alert)
		end
	end

	CopActionAct._create_blocks_table(self, action_desc.blocks)
	common_data.ext_movement:enable_update()

	if self._is_server and action_type ~= "death" then
		if action_desc.body_part == 1 or action_desc.body_part == 2 then
			local stand_rsrv = common_data.ext_brain:get_pos_rsrv("stand")

			if not stand_rsrv or mvec3_dis_sq(stand_rsrv.position, common_data.pos) > 400 then
				common_data.ext_brain:add_pos_rsrv("stand", {
					radius = 30,
					position = mvec3_copy(common_data.pos)
				})
			end
		end
	end

	if self:is_network_allowed(action_desc) then
		local hurt_type_idx = self.hurt_type_to_idx(action_type)
		local body_part = action_desc.body_part
		local death_type_idx = self.death_type_to_idx(death_type)
		local type_idx = self.type_to_idx(action_desc.type)
		local variant_idx = self.variant_to_idx(action_desc.variant)
		local direction_vec = action_desc.direction_vec or Vector3()
		local hit_pos = action_desc.hit_pos or Vector3()

		common_data.ext_network:send("action_hurt_start", hurt_type_idx, body_part, death_type_idx, type_idx, variant_idx, direction_vec, hit_pos)
	end

	return true
end

function CopActionHurt:is_network_allowed(action_desc)
	if not self.network_allowed_hurt_types[action_desc.hurt_type] then
		return false
	end

	if action_desc.allow_network == false then
		return false
	end

	return true
end

--vanilla
--[[local tmp_vec50 = Vector3()
local os_time = os.time
local math_round = math.round

function CopActionHurt:_pseudorandom(a, b)
	local mult = 10
	local ht = managers.game_play_central:get_heist_timer()

	local t = math_floor(ht * mult + 0.5) / mult
	local r = math_random() * 999 + 1
	local uid = self._unit:id()
	local seed = uid^(t / 183.62) * 100 % 100000

	math_randomseed(seed)

	local result = a and b and math_random(a, b) or a and math_random(a) or math_random()

	math_randomseed(os_time() / r + Application:time())

	for i = 1, math_round(math_random() * 10) do
		math_random()
	end

	if self._last_result then
		local pos = tmp_vec50

		mvec3_set(pos, self._unit:position())
		local pos_h_increase = self._pos_height_increase

		if pos_h_increase and pos_h_increase < 200 then
			pos_h_increase = pos_h_increase + 5
			self._pos_height_increase = pos_h_increase

			pos = pos + math_UP * pos_h_increase
		else
			self._pos_height_increase = 0
		end

		if self._last_result == result then
			local brush = Draw:brush(Color.red:with_alpha(0.5), 1)
			brush:sphere(pos, 20)
		else
			local brush = Draw:brush(Color.green:with_alpha(0.5), 1)
			brush:sphere(pos, 20)
		end
	end

	self._last_result = result

	return result
end]]

--just using math.random
--[[local tmp_vec50 = Vector3()

function CopActionHurt:_pseudorandom(a, b)
	local result = a and b and math_random(a, b) or a and math_random(a) or math_random()

	if self._last_result then
		local pos = tmp_vec50

		mvec3_set(pos, self._unit:position())
		local pos_h_increase = self._pos_height_increase

		if pos_h_increase and pos_h_increase < 200 then
			pos_h_increase = pos_h_increase + 5
			self._pos_height_increase = pos_h_increase

			pos = pos + math_UP * pos_h_increase
		else
			self._pos_height_increase = 0
		end

		if self._last_result == result then
			local brush = Draw:brush(Color.red:with_alpha(0.5), 1)
			brush:sphere(pos, 20)
		else
			local brush = Draw:brush(Color.green:with_alpha(0.5), 1)
			brush:sphere(pos, 20)
		end
	end

	self._last_result = result

	return result
end]]

--current method, will return the same result if called in the same frame + a and b are the same (this includes either or both of them being nil)
--that aside, this should work perfectly when it comes to simulating the same random results across peers
--REQUIRES SOME CHANGES TO UNITNETWORKHANDLER.LUA, GAMEPLAYCENTRALMANAGER.LUA AND NETWORK_SETTINGS.XML, IN REGARDS TO THE HEIST TIMER syncing
--local tmp_vec50 = Vector3()
function CopActionHurt:_pseudorandom(a, b)
	local ht = managers.game_play_central:get_heist_timer()
	local timer_offset = self._timer_offset

	if timer_offset then
		ht = ht - timer_offset
	end

	--using this + swapping which t local below is used results in this system being more friendly across peers
	--at the cost of getting the same results for the same type of roll within each second
	ht = math_floor(ht)

	--can't use negative values in these calculations
	ht = ht < 0 and -ht or ht

	--[[while ht < 60 do
		ht = ht + ht
	end]]

	local mult = 10
	--local t = math_floor(ht * mult + 0.5) / mult
	local t = (ht * mult + 0.5) / mult
	local r = math_random() * 999 + 1
	local uid = self._unit:id()
	uid = uid ~= -1 and uid or math_random(50) * uid
	local seed = uid^(t / 183.62) * 100 % 100000

	math_randomseed(seed)

	local result = a and b and math_random(a, b) or a and math_random(a) or math_random()

	--[[if self._last_result then
		local pos = tmp_vec50

		mvec3_set(pos, self._unit:position())
		local pos_h_increase = self._pos_height_increase

		if pos_h_increase and pos_h_increase < 200 then
			pos_h_increase = pos_h_increase + 5
			self._pos_height_increase = pos_h_increase

			pos = pos + math_UP * pos_h_increase
		else
			self._pos_height_increase = 0
		end

		if self._last_result == result then
			local brush = Draw:brush(Color.red:with_alpha(0.5), 1)
			brush:sphere(pos, 20)
		else
			local brush = Draw:brush(Color.green:with_alpha(0.5), 1)
			brush:sphere(pos, 20)
		end
	end

	self._last_result = result]]

	math_randomseed(ht / r + ht)
	math_random()

	return result
end

CopActionHurt.idx_to_hurt_type_map = {
	"bleedout",
	"light_hurt",
	"heavy_hurt",
	"expl_hurt",
	"hurt",
	"hurt_sick",
	"shield_knock",
	"knock_down",
	"stagger",
	"counter_tased",
	"taser_tased",
	"death",
	"fatal",
	"fire_hurt",
	"poison_hurt",
	"concussion",
	"healed"
}

function CopActionHurt.hurt_type_to_idx(hurt_type)
	local res = nil

	for idx, hurt in pairs_g(CopActionHurt.idx_to_hurt_type_map) do
		if hurt == hurt_type then
			res = idx

			break
		end
	end

	if not res then
		return table_index_of(CopActionHurt.idx_to_hurt_type_map, "death")
	end

	return res
end

function CopActionHurt.death_type_to_idx(death)
	return table_index_of(CopActionHurt.idx_to_death_type_map, death)
end

CopActionHurt.idx_to_type_map = {
	"hurt",
	"heavy_hurt",
	"hurt_sick",
	"poison_hurt",
	"death",
	"healed"
}

function CopActionHurt.type_to_idx(hurt_type)
	return table_index_of(CopActionHurt.idx_to_type_map, hurt_type)
end

CopActionHurt.idx_to_variant_map = {
	"bullet",
	"melee",
	"explosion",
	"fire",
	"tase",
	"stun",
	"graze",
	"counter_spooc",
	"bleeding",
	"poison",
	"dot",
	"counter_tased",
	"other"
}

function CopActionHurt.variant_to_idx(var)
	local variant_map = CopActionHurt.idx_to_variant_map
	local idx = table_index_of(variant_map, var)

	if idx < 0 then
		return #variant_map
	else
		return idx
	end
end

local tmp_used_flame_objects = nil

function CopActionHurt:_start_enemy_fire_effect_on_death(death_variant)
	local fire_data = tweak_data.fire
	local fire_bones = fire_data.fire_bones
	local effects_cost = fire_data.effects_cost
	local num_fire_bones = #fire_bones
	local effect_tbl = fire_data.fire_death_anims[death_variant] or fire_data.fire_death_anims[0]
	local fire_effects = fire_data.effects[effect_tbl.effect]
	local num_effects = math_random(3, num_fire_bones)

	if not tmp_used_flame_objects then
		tmp_used_flame_objects = {}

		for i = 1, num_fire_bones do
			tmp_used_flame_objects[#tmp_used_flame_objects + 1] = false
		end
	end

	local idx = 1
	local effects_table = {}
	local my_unit = self._unit
	local get_object_f = my_unit.get_object

	for i = 1, num_effects do
		while tmp_used_flame_objects[idx] do
			idx = math_random(1, num_fire_bones)
		end

		local bone = get_object_f(my_unit, idstr_func(fire_bones[idx]))

		if bone then
			local effect_name = fire_effects[effects_cost[i]]
			local effect_id = world_g:effect_manager():spawn({
				effect = idstr_func(effect_name),
				parent = bone
			})

			effects_table[#effects_table + 1] = effect_id
		end

		tmp_used_flame_objects[idx] = true
	end

	self._fire_death_effects_table = effects_table

	for i = 1, #tmp_used_flame_objects do
		tmp_used_flame_objects[i] = false
	end

	self._fire_death_sound_source_table = {enemy_unit = my_unit}

	managers.fire:start_burn_body_sound(self._fire_death_sound_source_table, effect_tbl.duration)
end

function CopActionHurt:_dragons_breath_sparks()
	local bone_spine = self._unit:get_object(ids_bone_spine)

	if bone_spine then
		world_g:effect_manager():spawn({
			effect = ids_dragons_breath_effect,
			parent = bone_spine
		})
	end
end

function CopActionHurt:_get_floor_normal(at_pos, fwd, right)
	local padding_height = 150
	local center_pos = at_pos + math_UP

	mvec3_set_z(center_pos, center_pos.z + padding_height)

	local fall = 100
	local down_vec = Vector3(0, 0, -fall - padding_height)
	local dis = 50
	local fwd_pos, bwd_pos, r_pos, l_pos = nil
	local from_pos = fwd * dis

	mvec3_add(from_pos, center_pos)

	local to_pos = from_pos + down_vec
	local ground_ray_slotmask = managers.slot:get_mask("AI_graph_obstacle_check") --managers.slot:get_mask("world_geometry")
	local down_ray = world_g:raycast("ray", from_pos, to_pos, "slot_mask", ground_ray_slotmask, "ray_type", "walk")
	--local down_ray = World:raycast("ray", from_pos, to_pos, "slot_mask", 1)

	if down_ray then
		fwd_pos = down_ray.position
	else
		fwd_pos = to_pos:with_z(at_pos.z)
	end

	mvec3_set(from_pos, fwd)
	mvec3_mul(from_pos, -dis)
	mvec3_add(from_pos, center_pos)
	mvec3_set(to_pos, from_pos)
	mvec3_add(to_pos, down_vec)

	down_ray = world_g:raycast("ray", from_pos, to_pos, "slot_mask", ground_ray_slotmask, "ray_type", "walk")

	if down_ray then
		bwd_pos = down_ray.position
	else
		bwd_pos = to_pos:with_z(at_pos.z)
	end

	mvec3_set(from_pos, right)
	mvec3_mul(from_pos, dis)
	mvec3_add(from_pos, center_pos)
	mvec3_set(to_pos, from_pos)
	mvec3_add(to_pos, down_vec)

	down_ray = world_g:raycast("ray", from_pos, to_pos, "slot_mask", ground_ray_slotmask, "ray_type", "walk")

	if down_ray then
		r_pos = down_ray.position
	else
		r_pos = to_pos:with_z(at_pos.z)
	end

	mvec3_set(from_pos, right)
	mvec3_mul(from_pos, -dis)
	mvec3_add(from_pos, center_pos)
	mvec3_set(to_pos, from_pos)
	mvec3_add(to_pos, down_vec)

	down_ray = world_g:raycast("ray", from_pos, to_pos, "slot_mask", ground_ray_slotmask, "ray_type", "walk")

	if down_ray then
		l_pos = down_ray.position
	else
		l_pos = to_pos

		mvec3_set_z(l_pos, at_pos.z)
	end

	local pose_fwd = fwd_pos

	mvec3_sub(pose_fwd, bwd_pos)

	local pose_l = l_pos

	mvec3_sub(pose_l, r_pos)

	local ground_normal = pose_fwd:cross(pose_l)

	mvec3_norm(ground_normal)

	return ground_normal
end

function CopActionHurt:on_exit()
	if self._autofiring or self._shooting_hurt then
		self._shooting_hurt = false
		self._autofiring = nil
		self._autoshots_fired = nil

		self._weapon_base:stop_autofire()
	end

	if self._delayed_shooting_hurt_clbk_id then
		managers.enemy:remove_delayed_clbk(self._delayed_shooting_hurt_clbk_id)

		self._delayed_shooting_hurt_clbk_id = nil
	end

	if self._friendly_fire then
		self._unit:movement():set_friendly_fire(false)

		self._friendly_fire = nil

		if self._changed_slot_mask then
			self._weapon_base:set_bullet_hit_slotmask(self._original_slot_mask)
		end
	end

	if self._modifier_on then
		self[self._ik_preset.stop](self)
	end

	if self._shooting_player and alive(self._attention.unit) then
		self._attention.unit:movement():on_targetted_for_attack(false, self._unit)
	end

	if self._expired then
		CopActionWalk._chk_correct_pose(self)
	end

	if self._tased_effect then
		world_g:effect_manager():fade_kill(self._tased_effect)
	end

	if self._is_server and not self._expired then
		if self._hurt_type == "bleedout" or self._hurt_type == "fatal" or self._variant == "tase" then
			self._common_data.ext_network:send("action_hurt_end")
		end

		if self._hurt_type == "bleedout" then
			self._ext_inventory:equip_selection(2, true)
		end
	end

	if self._hurt_type == "fatal" or self._variant == "tase" then
		managers.hud:set_mugshot_normal(self._unit:unit_data().mugshot_id)
	end

	if self._ext_damage.call_listener then
		self._ext_damage:call_listener("on_exit_hurt")
	end

	if self._hurt_type == "fire_hurt" and self._ext_damage.set_last_time_unit_got_fire_damage then
		self._ext_damage:set_last_time_unit_got_fire_damage(self._timer:time())
	end
end

function CopActionHurt:_get_pos_clamped_to_graph(test_head)
	local tracker = self._ext_movement:nav_tracker()
	local r = tracker:field_position()
	local new_pos = tmp_vec1

	mvec3_set(new_pos, self._unit:get_animation_delta_position())
	mvec3_set_z(new_pos, 0)
	mvec3_add(new_pos, r)

	local ray_params = nil

	if test_head then
		local h = tmp_vec2

		mvec3_set(h, self._common_data.ext_movement._obj_head:position())
		mvec3_set_z(h, new_pos.z)

		ray_params = {
			trace = true,
			tracker_from = tracker,
			pos_to = h
		}
		local hit = managers.navigation:raycast(ray_params)
		local nh = ray_params.trace[1]
		local collision_side = ray_params.trace[2]

		if hit and collision_side then
			mvec3_set(tmp_vec3, managers.navigation._dir_str_to_vec[collision_side])
			mvec3_sub(h, nh)
			mvec3_set_z(h, 0)

			local error_amount = -mvec3_dot(tmp_vec3, h)

			mvec3_mul(tmp_vec3, error_amount)
			mvec3_add(new_pos, tmp_vec3)
		end
	else
		ray_params = {
			tracker_from = tracker
		}
	end

	ray_params.pos_to = new_pos
	ray_params.trace = true

	managers.navigation:raycast(ray_params)
	mvec3_set(new_pos, ray_params.trace[1])

	return new_pos
end

function CopActionHurt:_upd_sick(t)
	local dt = self._timer:delta_time()

	self._last_pos = self:_get_pos_clamped_to_graph()

	CopActionWalk._set_new_pos(self, dt)

	local new_rot = self._unit:get_animation_delta_rotation()
	new_rot = self._common_data.rot * new_rot

	mrot_set(new_rot, new_rot:yaw(), 0, 0)

	self._ext_movement:set_rotation(new_rot)

	if not self._sick_time or self._sick_time < t then
		local redir_res = self._ext_movement:play_redirect("idle")

		if redir_res then
			self.update = self._upd_exiting
		else
			self._expired = true
		end
	end

	if self._ext_anim.base_need_upd then
		self._ext_movement:upd_m_head_pos()
	end
end

function CopActionHurt:_upd_exiting(t)
	if not self._ext_anim.hurt then
		self._expired = true
	end
end

function CopActionHurt:_upd_tased(t)
	local dt = self._timer:delta_time()

	if self._ext_anim.tased or self._ext_anim.tased_loop then
		if self._shooting_hurt_tase then
			self:_upd_tase_shooting(t)
		end

		self._last_pos = self:_get_pos_clamped_to_graph()

		CopActionWalk._set_new_pos(self, dt)

		local new_rot = self._unit:get_animation_delta_rotation()
		new_rot = self._common_data.rot * new_rot

		mrot_set(new_rot, new_rot:yaw(), 0, 0)

		self._ext_movement:set_rotation(new_rot)
	else
		self._shooting_hurt_tase = nil

		if self._autofiring then
			self._weapon_base:stop_autofire()

			self._autofiring = nil
			self._autoshots_fired = nil
		end
	end

	if self._tased_time and self._tased_time < t then
		if self._tased_down_time and t < self._tased_down_time then
			self._ext_movement:play_redirect("fatal")
			self.update = self._upd_tased_down
			self._shooting_hurt_tase = nil

			if self._autofiring then
				self._weapon_base:stop_autofire()

				self._autofiring = nil
				self._autoshots_fired = nil
			end
		else
			self._expired = true
		end
	end

	if self._ext_anim.base_need_upd then
		self._ext_movement:upd_m_head_pos()
	end
end

function CopActionHurt:_upd_tased_down(t)
	if not self._tased_down_time or self._tased_down_time < t then
		self._expired = true
	end

	self:_upd_hurt(t)
end

function CopActionHurt:_upd_hurt(t)
	local dt = self._timer:delta_time()

	if self._ext_anim.hurt or self._ext_anim.death then
		if self._shooting_hurt then
			local weap_base = self._weapon_base

			if weap_base._next_fire_allowed <= t then
				local weap_unit = self._weapon_unit
				local shoot_from_pos = weap_unit:position()
				local shoot_to_pos = shoot_from_pos + weap_unit:rotation():y() * 1000
				local dir_vec = temp_vec1
				mvec3_dir(dir_vec, shoot_from_pos, shoot_to_pos)

				local spread_pos = temp_vec2
				mvec3_rand_orth(spread_pos, dir_vec)
				mvec3_set_l(spread_pos, self._spread)
				mvec3_add(spread_pos, shoot_to_pos)
				mvec3_dir(dir_vec, shoot_from_pos, spread_pos)

				local dmg_buff = self._ext_base:get_total_buff("base_damage")
				local dmg_mul = 1 + dmg_buff

				if weap_base:trigger_held(shoot_from_pos, dir_vec, dmg_mul) then
					if weap_base.clip_empty and weap_base:clip_empty() then
						self._shooting_hurt = false

						weap_base:stop_autofire()
					end
				end
			end
		end

		self._last_pos = self:_get_pos_clamped_to_graph(true)

		CopActionWalk._set_new_pos(self, dt)

		local new_rot = self._unit:get_animation_delta_rotation()
		new_rot = self._common_data.rot * new_rot

		mrot_set(new_rot, new_rot:yaw(), 0, 0)

		if self._ext_anim.death then
			local rel_prog = math_clamp(self._machine:segment_relative_time(ids_base), 0, 1)

			if self._floor_normal == nil then
				self._floor_normal = Vector3(0, 0, 1)
			end

			local normal = math_lerp(math_UP, self._floor_normal, rel_prog)
			local fwd = new_rot:y()

			mvec3_cross(tmp_vec1, fwd, normal)
			mvec3_cross(fwd, normal, tmp_vec1)

			new_rot = Rotation(fwd, normal)
		end

		self._ext_movement:set_rotation(new_rot)

		if self._ext_anim.base_need_upd then
			self._ext_movement:upd_m_head_pos()
		end
	else
		if self._shooting_hurt then
			self._shooting_hurt = false

			self._weapon_base:stop_autofire()
		end

		if self._delayed_shooting_hurt_clbk_id then
			managers.enemy:remove_delayed_clbk(self._delayed_shooting_hurt_clbk_id)

			self._delayed_shooting_hurt_clbk_id = nil
		end

		if self._hurt_type == "death" then
			self._died = true
		else
			self._expired = true
		end
	end
end

function CopActionHurt:_upd_tase_shooting(t)
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

	local common_data = self._common_data
	local attention = self._attention

	if self._weapon_base.clip_empty and self._weapon_base:clip_empty() then
		--[[if self._is_server then
			managers.network:session():send_to_peers_synched("reload_weapon_cop", self._unit)
		end]]

		if self._autofiring then
			self._weapon_base:stop_autofire()

			self._autofiring = nil
			self._autoshots_fired = nil
		end

		if self._modifier_on then
			self._modifier_on = nil

			self._machine:allow_modifier(self._spine_modifier_name)
			self._machine:allow_modifier(self._head_modifier_name)
			self._machine:allow_modifier(self._r_arm_modifier_name)
		end

		self:on_attention(nil, attention)
		self._shooting_hurt_tase = nil
		self:on_attention(attention)

		return
	end

	local shoot_from_pos = self._shoot_from_pos
	local ext_anim = self._ext_anim
	local target_pos, target_vec, target_dis, shooting_local_player = nil

	if attention then
		target_pos, target_vec, target_dis, shooting_local_player = self:_get_target_pos(shoot_from_pos, attention, t)

		local tar_vec_flat = temp_vec2

		mvec3_set(tar_vec_flat, target_vec)
		mvec3_set_z(tar_vec_flat, 0)
		mvec3_norm(tar_vec_flat)

		local fwd = common_data.fwd
		local fwd_dot = mvec3_dot(fwd, tar_vec_flat)

		target_vec = self:_upd_ik(target_vec, fwd_dot, t)
	end

	if not target_vec and self._modifier_on then
		self._modifier_on = nil

		self._machine:allow_modifier(self._spine_modifier_name)
		self._machine:allow_modifier(self._head_modifier_name)
		self._machine:allow_modifier(self._r_arm_modifier_name)
	end

	local autofiring = self._autofiring

	if autofiring then
		if not cannot_fire_yet then
			if target_vec then
				local falloff, i_range = CopActionShoot._get_shoot_falloff(self, target_dis, self._falloff)
				local dmg_buff = self._ext_base:get_total_buff("base_damage") + 1
				local dmg_mul = dmg_buff * falloff.dmg_mul
				local att_unit = attention.unit
				local shooting_husk = self._shooting_husk_unit
				local simplified_shooting = not att_unit or shooting_husk
				local miss_pos = not simplified_shooting and CopActionShoot._get_unit_shoot_pos(self, t, target_pos, target_dis, falloff, i_range, shooting_local_player)

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
					autofiring = self._autofiring

					if not autofiring or autofiring - 1 <= self._autoshots_fired then
						self._autofiring = nil
						self._autoshots_fired = nil

						self._weapon_base:stop_autofire()

						self._shoot_t = t + math_lerp(1, 1.2, self:_pseudorandom())
					else
						self._autoshots_fired = self._autoshots_fired + 1
					end
				end
			else
				local shoot_from_pos = self._weapon_unit:position()
				local shoot_to_pos = shoot_from_pos + self._weapon_unit:rotation():y() * 1000
				local dir_vec = temp_vec1
				mvec3_dir(dir_vec, shoot_from_pos, shoot_to_pos)

				local spread_pos = temp_vec2
				mvec3_rand_orth(spread_pos, dir_vec)
				mvec3_set_l(spread_pos, self._spread)
				mvec3_add(spread_pos, shoot_to_pos)
				mvec3_dir(dir_vec, shoot_from_pos, spread_pos)

				local dmg_buff = self._ext_base:get_total_buff("base_damage")
				local dmg_mul = 1 + dmg_buff

				if self._weapon_base:trigger_held(shoot_from_pos, dir_vec, dmg_mul) then
					autofiring = self._autofiring

					if not autofiring or autofiring - 1 <= self._autoshots_fired then
						self._autofiring = nil
						self._autoshots_fired = nil

						self._weapon_base:stop_autofire()

						self._shoot_t = t + math_lerp(1, 1.2, self:_pseudorandom())
					else
						self._autoshots_fired = self._autoshots_fired + 1
					end
				end
			end
		end
	elseif not cannot_fire_yet and self._shoot_t < t then
		if target_vec then
			local falloff, i_range = CopActionShoot._get_shoot_falloff(self, target_dis, self._falloff)
			local dmg_buff = self._ext_base:get_total_buff("base_damage") + 1
			local dmg_mul = dmg_buff * falloff.dmg_mul
			local simplified_shooting = not att_unit or shooting_husk
			local miss_pos = not simplified_shooting and CopActionShoot._get_unit_shoot_pos(self, t, target_pos, target_dis, falloff, i_range, shooting_local_player)

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

			if self._automatic_weap and self._weapon_base:ammo_info() > 1 then
				self._weapon_base:start_autofire()

				self._autofiring = self._w_usage_tweak.autofire_rounds[1] + self:_pseudorandom(self._w_usage_tweak.autofire_rounds[1])

				local shots_fired = 0

				if self._weapon_base:trigger_held(shoot_from_pos, target_vec, dmg_mul, shooting_local_player, nil, nil, nil, att_unit) then
					shots_fired = 1
				end

				self._autoshots_fired = shots_fired
			elseif self._weapon_base:singleshot(shoot_from_pos, target_vec, dmg_mul, shooting_local_player, nil, nil, nil, att_unit) then
				local custom_singleshot_rof = self._weap_tweak.custom_single_fire_rate
				local recoil_1 = custom_singleshot_rof or 1
				local recoil_2 = custom_singleshot_rof and custom_singleshot_rof * 1.5 or 1.2

				self._shoot_t = t + math_lerp(recoil_1, recoil_2, self:_pseudorandom())
			end
		else
			local shoot_from_pos = self._weapon_unit:position()
			local shoot_to_pos = shoot_from_pos + self._weapon_unit:rotation():y() * 1000
			local dir_vec = temp_vec1
			mvec3_dir(dir_vec, shoot_from_pos, shoot_to_pos)

			local spread_pos = temp_vec2
			mvec3_rand_orth(spread_pos, dir_vec)
			mvec3_set_l(spread_pos, self._spread)
			mvec3_add(spread_pos, shoot_to_pos)
			mvec3_dir(dir_vec, shoot_from_pos, spread_pos)

			local dmg_buff = self._ext_base:get_total_buff("base_damage")
			local dmg_mul = 1 + dmg_buff

			if self._automatic_weap and self._weapon_base:ammo_info() > 1 then
				self._weapon_base:start_autofire()

				self._autofiring = self._w_usage_tweak.autofire_rounds[1] + self:_pseudorandom(self._w_usage_tweak.autofire_rounds[1])

				local shots_fired = 0

				if self._weapon_base:trigger_held(shoot_from_pos, dir_vec, dmg_mul, shooting_local_player, nil, nil, nil, att_unit) then
					shots_fired = 1
				end

				self._autoshots_fired = shots_fired
			elseif self._weapon_base:singleshot(shoot_from_pos, dir_vec, dmg_mul, shooting_local_player, nil, nil, nil, att_unit) then
				local custom_singleshot_rof = self._weap_tweak.custom_single_fire_rate
				local recoil_1 = custom_singleshot_rof or 1
				local recoil_2 = custom_singleshot_rof and custom_singleshot_rof * 1.5 or 1.2

				self._shoot_t = t + math_lerp(recoil_1, recoil_2, self:_pseudorandom())
			end
		end
	end
end

function CopActionHurt:_upd_bleedout_enter(t)
	local vis_state = self._ext_base:lod_stage()
	vis_state = vis_state or 4

	if vis_state ~= 1 then
		if self._skipped_frames < vis_state * 3 then
			self._skipped_frames = self._skipped_frames + 1

			return
		else
			self._skipped_frames = 1
		end
	end

	local dt = self._timer:delta_time()

	self._last_pos = self:_get_pos_clamped_to_graph(true)

	CopActionWalk._set_new_pos(self, dt)

	local common_data = self._common_data
	local floor_normal = self._floor_normal or self:_get_floor_normal(common_data.pos, common_data.fwd, common_data.right)
	self._floor_normal = nil

	if self._ext_anim.bleedout_enter then
		local rel_t = self._machine:segment_relative_time(ids_base)
		rel_t = math_min(1, rel_t + 0.5)
		local rel_prog = math_clamp(rel_t, 0, 1)
		local normal = math_lerp(math_UP, floor_normal, rel_prog)

		mvec3_cross(tmp_vec1, common_data.fwd, normal)
		mvec3_cross(tmp_vec2, normal, tmp_vec1)

		local new_rot = Rotation(tmp_vec2, normal)

		self._ext_movement:set_rotation(new_rot)
	else
		mvec3_cross(tmp_vec1, common_data.fwd, floor_normal)
		mvec3_cross(tmp_vec2, floor_normal, tmp_vec1)

		local new_rot = Rotation(tmp_vec2, floor_normal)

		self._ext_movement:set_rotation(new_rot)

		if self._weapon_unit then
			self.update = self._upd_bleedout

			self:on_attention(common_data.attention)

			self:update(t)
		else
			self.update = self._upd_bleedout_no_weapon
		end
	end
end

function CopActionHurt:_upd_bleedout_no_weapon(t)
	local vis_state = self._ext_base:lod_stage()
	vis_state = vis_state or 4

	if vis_state ~= 1 then
		if self._skipped_frames < vis_state * 3 then
			self._skipped_frames = self._skipped_frames + 1

			return
		else
			self._skipped_frames = 1
		end
	end

	local ext_anim = self._ext_anim
	local attention = self._attention
	local _, target_vec = nil

	if attention then
		local shoot_from_pos = self._shoot_from_pos

		_, target_vec = self:_get_target_pos(shoot_from_pos, attention, t)
		target_vec = self:_upd_ik(target_vec, nil, t)
	end

	if ext_anim.reload or ext_anim.equip then
		if self._modifier_on then
			self._modifier_on = nil

			self._machine:allow_modifier(self._head_modifier_name)
			self._machine:allow_modifier(self._r_arm_modifier_name)
		end
	elseif target_vec then
		local common_data = self._common_data
		local aim_polar = target_vec:to_polar_with_reference(common_data.fwd, math_UP)
		local aim_spin_d90 = aim_polar.spin / 90
		local machine = self._machine
		local anim = machine:segment_state(ids_base)
		local fwd = 1 - math_clamp(math_abs(aim_spin_d90), 0, 1)

		machine:set_parameter(anim, "angle0", fwd)

		local bwd = math_clamp(math_abs(aim_spin_d90), 1, 2) - 1

		machine:set_parameter(anim, "angle180", bwd)

		local l = 1 - math_clamp(math_abs(aim_spin_d90 - 1), 0, 1)

		machine:set_parameter(anim, "angle90neg", l)

		local r = 1 - math_clamp(math_abs(aim_spin_d90 + 1), 0, 1)

		machine:set_parameter(anim, "angle90", r)
	end

	if self._ext_anim.base_need_upd then
		self._ext_movement:upd_m_head_pos()
	end
end

function CopActionHurt:_upd_bleedout(t)
	local vis_state = self._ext_base:lod_stage()
	vis_state = vis_state or 4

	local cannot_fire_yet = self._weapon_base._next_fire_allowed > t
	local ext_anim = self._ext_anim

	if cannot_fire_yet and not ext_anim.reload and vis_state ~= 1 then
		if self._skipped_frames < vis_state * 3 then
			self._skipped_frames = self._skipped_frames + 1

			return
		else
			self._skipped_frames = 1
		end
	end

	local shoot_from_pos = self._shoot_from_pos
	local attention = self._attention
	local common_data = self._common_data
	local target_pos, target_vec, target_dis, shooting_local_player = nil

	if attention then
		target_pos, target_vec, target_dis, shooting_local_player = self:_get_target_pos(shoot_from_pos, attention, t)
		target_vec = self:_upd_ik(target_vec, nil, t)
	end

	local autofiring = self._autofiring

	if ext_anim.reload or ext_anim.equip then
		if self._modifier_on then
			self._modifier_on = nil

			self._machine:allow_modifier(self._head_modifier_name)
			self._machine:allow_modifier(self._r_arm_modifier_name)
		end
	elseif self._weapon_base:clip_empty() then
		if autofiring then
			self._weapon_base:stop_autofire()

			self._autofiring = nil
			self._autoshots_fired = nil
		end

		local res = self._ext_movement:play_redirect("reload")

		if res then
			self._machine:set_speed(res, self._reload_speed)
			self._weapon_base:on_reload()
		end

		--[[if self._is_server then
			managers.network:session():send_to_peers_synched("reload_weapon_cop", self._unit)
		end]]
	elseif not target_vec then
		if autofiring then
			self._weapon_base:stop_autofire()

			self._shoot_t = t + 0.6
			self._autofiring = nil
			self._autoshots_fired = nil
		end

		if self._modifier_on then
			self._modifier_on = nil

			self._machine:allow_modifier(self._head_modifier_name)
			self._machine:allow_modifier(self._r_arm_modifier_name)
		end
	else
		local aim_polar = target_vec:to_polar_with_reference(common_data.fwd, math_UP)
		local aim_spin_d90 = aim_polar.spin / 90
		local machine = self._machine
		local anim = machine:segment_state(ids_base)
		local fwd = 1 - math_clamp(math_abs(aim_spin_d90), 0, 1)

		machine:set_parameter(anim, "angle0", fwd)

		local bwd = math_clamp(math_abs(aim_spin_d90), 1, 2) - 1

		machine:set_parameter(anim, "angle180", bwd)

		local l = 1 - math_clamp(math_abs(aim_spin_d90 - 1), 0, 1)

		machine:set_parameter(anim, "angle90neg", l)

		local r = 1 - math_clamp(math_abs(aim_spin_d90 + 1), 0, 1)

		machine:set_parameter(anim, "angle90", r)

		if autofiring then
			if not common_data.allow_fire then
				self._weapon_base:stop_autofire()

				self._shoot_t = t + 0.6
				self._autofiring = nil
				self._autoshots_fired = nil
			elseif not cannot_fire_yet then
				local falloff, i_range = CopActionShoot._get_shoot_falloff(self, target_dis, self._falloff)
				local dmg_buff = self._ext_base:get_total_buff("base_damage") + 1
				local dmg_mul = dmg_buff * falloff.dmg_mul
				local att_unit = attention.unit
				local shoot_hist = self._shoot_history
				local shooting_husk = self._shooting_husk_unit
				local simplified_shooting = not att_unit or shooting_husk
				local miss_pos = shoot_hist and not simplified_shooting and CopActionShoot._get_unit_shoot_pos(self, t, target_pos, target_dis, falloff, i_range, shooting_local_player)

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
					autofiring = self._autofiring

					if not autofiring or autofiring - 1 <= self._autoshots_fired then
						self._autofiring = nil
						self._autoshots_fired = nil

						self._weapon_base:stop_autofire()

						local dis_lerp = math_min(1, target_dis / falloff.r)
						local shoot_delay = math_lerp(falloff.recoil[1], falloff.recoil[2], dis_lerp)

						if common_data.is_suppressed then
							shoot_delay = shoot_delay * 1.5
						end

						self._shoot_t = t + shoot_delay
					else
						self._autoshots_fired = self._autoshots_fired + 1
					end
				end
			end
		elseif common_data.allow_fire and self._mod_enable_t < t then
			local shoot = nil
			local att_unit = attention.unit
			local shooting_husk = self._shooting_husk_unit

			if att_unit then
				if not shooting_husk or not self._next_vis_ray_t or self._next_vis_ray_t < t then
					if shooting_husk then
						self._next_vis_ray_t = t + 2
					end

					local fire_line_is_obstructed = self._unit:raycast("ray", shoot_from_pos, target_pos, "slot_mask", self._fire_line_slotmask, "ray_type", "ai_vision")

					if fire_line_is_obstructed then
						if not self._line_of_sight_t or t - self._line_of_sight_t > 3 then
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

						if not self._line_of_sight_t or t - self._line_of_sight_t > 1 then
							self._shoot_history.focus_start_t = t
							self._shoot_history.focus_delay = self._focus_delay
						end

						self._shoot_history.m_last_pos = mvec3_copy(target_pos)
						self._line_of_sight_t = t
					end

					self._last_vis_check_status = shoot
				else
					shoot = self._last_vis_check_status
				end
			else
				shoot = true
			end

			if shoot and not cannot_fire_yet and self._shoot_t < t then
				local falloff, i_range = CopActionShoot._get_shoot_falloff(self, target_dis, self._falloff)
				local dmg_buff = self._ext_base:get_total_buff("base_damage") + 1
				local dmg_mul = dmg_buff * falloff.dmg_mul
				local shoot_hist = self._shoot_history
				local simplified_shooting = not att_unit or shooting_husk
				local miss_pos = shoot_hist and not simplified_shooting and CopActionShoot._get_unit_shoot_pos(self, t, target_pos, target_dis, falloff, i_range, shooting_local_player)

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

				local firemode = nil
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
							self._autofiring = math_ceil(falloff.autofire_rounds[1] + math_random() * diff)
							--self._autofiring = math_ceil(falloff.autofire_rounds[1] + random_mode_roll * diff)
						else
							local diff = self._w_usage_tweak.autofire_rounds[2] - self._w_usage_tweak.autofire_rounds[1]
							self._autofiring = math_ceil(self._w_usage_tweak.autofire_rounds[1] + math_random() * diff)
							--self._autofiring = math_ceil(self._w_usage_tweak.autofire_rounds[1] + random_mode_roll * diff)
						end
					end

					local shots_fired = 0

					if self._weapon_base:trigger_held(shoot_from_pos, target_vec, dmg_mul, shooting_local_player, nil, nil, nil, att_unit) then
						shots_fired = 1
					end

					self._autoshots_fired = shots_fired
				elseif self._weapon_base:singleshot(shoot_from_pos, target_vec, dmg_mul, shooting_local_player, nil, nil, nil, att_unit) then
					local recoil_1 = nil
					local recoil_2 = nil

					if self._weap_tweak.custom_single_fire_rate then
						recoil_1 = self._weap_tweak.custom_single_fire_rate
						recoil_2 = self._weap_tweak.custom_single_fire_rate * #self._falloff * 1.5
					else
						recoil_1 = falloff.recoil[1]
						recoil_2 = falloff.recoil[2]
					end

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

	if self._ext_anim.base_need_upd then
		self._ext_movement:upd_m_head_pos()
	end
end

function CopActionHurt:_upd_ragdolled(t)
	local dt = self._timer:delta_time()

	if self._shooting_hurt then
		--[[if not self._is_server and not self._temp_set_ammo_to_0_on_client_id then ----eventually just make NPCs spend ammo on clients and wait for reloads from the host
			self._temp_set_ammo_to_0_on_client_id = "set_ammo_0" ..tostring_g(self._unit:key())

			managers.enemy:add_delayed_clbk(self._temp_set_ammo_to_0_on_client_id, callback(self, self, "_set_ammo_0"), self._timer:time() + 3)
		end]]

		local weap_base = self._weapon_base

		if weap_base._next_fire_allowed <= t then
			local weap_unit = self._weapon_unit
			local shoot_from_pos = weap_unit:position()
			local shoot_to_pos = shoot_from_pos + weap_unit:rotation():y() * 100
			local dir_vec = temp_vec1
			mvec3_dir(dir_vec, shoot_from_pos, shoot_to_pos)

			local spread_pos = temp_vec2
			mvec3_rand_orth(spread_pos, dir_vec)
			mvec3_set_l(spread_pos, self._spread)
			mvec3_add(spread_pos, shoot_to_pos)
			mvec3_dir(dir_vec, shoot_from_pos, spread_pos)

			local dmg_buff = self._ext_base:get_total_buff("base_damage")
			local dmg_mul = 1 + dmg_buff

			if weap_base:trigger_held(shoot_from_pos, dir_vec, dmg_mul) then
				local u_body = self._unit:body("rag_RightArm")

				if u_body and u_body:enabled() and u_body:dynamic() then
					local rot_acc = Vector3(1 - math_rand(2), 1 - math_rand(2), 1 - math_rand(2)) * 10
					local body_mass = u_body:mass()
					local length = mvec3_dir(temp_vec3, shoot_from_pos, u_body:center_of_mass())
					local body_vel = u_body:velocity()
					local vel_dot = mvec3_dot(body_vel, temp_vec3)
					local max_vel = 800

					if vel_dot < max_vel then
						mvec3_set_z(temp_vec3, temp_vec3.z + 0.75)

						local push_vel = max_vel - math_max(vel_dot, 0)

						mvec3_mul(temp_vec3, push_vel)
						world_g:play_physic_effect(ids_expl_physics, u_body, temp_vec3, body_mass / math_random(2), u_body:position(), rot_acc, 1)
					end
				end

				if weap_base.clip_empty and weap_base:clip_empty() then
					self._shooting_hurt = false

					weap_base:stop_autofire()

					self._weapon_dropped = true
					self._ext_inventory:drop_weapon()
					managers.enemy:reschedule_delayed_clbk(self._ragdoll_freeze_clbk_id, self._timer:time() + 1.5)
				end
			end
		end
	end

	if self._ragdoll_active then
		self._hips_obj:m_position(tmp_vec1)
		self._ext_movement:set_position(tmp_vec1)
	end

	if not self._ragdoll_freeze_clbk_id and not self._shooting_hurt then
		self._died = true
	end
end

function CopActionHurt:_set_ammo_0()
	local weap_base = self._weapon_base
	local ammo_base = weap_base and weap_base:ammo_base()

	if ammo_base then
		ammo_base:set_ammo_remaining_in_clip(0)
	end
end

function CopActionHurt:chk_block(action_type, t)
	if self._hurt_type == "death" then
		return true
	elseif action_type == "death" then
		return false
	elseif action_type == "stand" then
		if self._variant == "tase" or self._hurt_type == "bleedout" or self._hurt_type == "fatal" then
			return false
		else
			return true
		end
	elseif action_type == "turn" or action_type == "crouch" or CopActionAct.chk_block(self, action_type, t) then
		return true
	elseif action_type ~= "bleedout" and action_type ~= "fatal" and self._variant ~= "tase" and not self._ext_anim.hurt_exit then
		return true
	end
end

function CopActionHurt:on_attention(attention, old_attention)
	local shooting_tase = self._shooting_hurt_tase

	if self.update == self._upd_tased then
		if not shooting_tase then
			if self._shooting_player and old_attention and alive(old_attention.unit) then
				old_attention.unit:movement():on_targetted_for_attack(false, self._common_data.unit)
			end

			self._shooting_player = nil
			self._attention = attention

			return
		end
	elseif self.update ~= self._upd_bleedout then
		if self._shooting_player and old_attention and alive(old_attention.unit) then
			old_attention.unit:movement():on_targetted_for_attack(false, self._common_data.unit)
		end

		self._shooting_player = nil
		self._attention = attention

		return
	end

	if self._shooting_player and old_attention and alive(old_attention.unit) then
		old_attention.unit:movement():on_targetted_for_attack(false, self._common_data.unit)
	end

	if not shooting_tase and self._autofiring then
		self._weapon_base:stop_autofire()

		self._autofiring = nil
		self._autoshots_fired = nil
	end

	self._shooting_player = nil
	self._shooting_husk_unit = nil
	self._next_vis_ray_t = nil

	if attention then
		local t = self._timer:time()

		self[self._ik_preset.start](self)

		local vis_state = self._ext_base:lod_stage()

		if shooting_tase then
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
		else
			if vis_state and vis_state < 3 then
				self._aim_transition = {
					duration = 0.5,
					start_t = t,
					start_vec = mvec3_copy(self._common_data.look_vec)
				}
				self._get_target_pos = self._get_transition_target_pos
			else
				self._aim_transition = nil
				self._get_target_pos = nil
			end

			self._mod_enable_t = t + 0.5
		end

		if attention.unit then
			local att_ext_base = attention.unit:base()

			if att_ext_base and att_ext_base.is_local_player then
				self._shooting_player = true
				attention.unit:movement():on_targetted_for_attack(true, self._unit)
			elseif not self._is_server or att_ext_base and att_ext_base.is_husk_player then
				self._shooting_husk_unit = true
			end

			if shooting_tase then
				self._shoot_t = t
			else
				local target_pos, _, target_dis = CopActionShoot._get_target_pos(self, self._shoot_from_pos, attention)
				local usage_tweak = self._w_usage_tweak
				local shoot_hist = self._shoot_history
				local aim_delay = 0
				local aim_delay_minmax = self._aim_delay_minmax

				if shoot_hist then
					local displacement = mvec3_dis(target_pos, shoot_hist.m_last_pos)

					if displacement > self._focus_displacement then
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

function CopActionHurt:on_death_exit()
	if self._autofiring or self._shooting_hurt then
		self._shooting_hurt = false
		self._autofiring = nil
		self._autoshots_fired = nil

		self._weapon_base:stop_autofire()
	end

	if self._delayed_shooting_hurt_clbk_id then
		managers.enemy:remove_delayed_clbk(self._delayed_shooting_hurt_clbk_id)

		self._delayed_shooting_hurt_clbk_id = nil
	end

	if not self._ragdolled then
		self._unit:set_animations_enabled(false)
	end
end

function CopActionHurt:on_death_drop(unit, stage)
	if self._weapon_dropped then
		return
	end

	if self._shooting_hurt then
		--[[if stage == 2 then
			self._weapon_dropped = true
			self._shooting_hurt = false

			self._weapon_base:stop_autofire()
			self._ext_inventory:drop_weapon()
		end]]
	elseif self._delayed_shooting_hurt_clbk_id then
		self._drop_weapon_after_firing = true
	elseif self._ext_inventory then
		self._weapon_dropped = true

		self._ext_inventory:drop_weapon()
	end
end

function CopActionHurt:on_inventory_event(event)
	local new_weapon_unit = not self._weapon_dropped and self._ext_inventory:equipped_unit()

	if self._autofiring or self._shooting_hurt then
		self._shooting_hurt = false
		self._autofiring = nil
		self._autoshots_fired = nil

		if alive(self._weapon_unit) then
			self._weapon_base:stop_autofire()
		end
	end

	if new_weapon_unit then
		self._weapon_unit = new_weapon_unit

		local new_weapon_base = new_weapon_unit:base()
		self._weapon_base = new_weapon_base

		local weap_tweak = new_weapon_base:weapon_tweak_data()
		local weapon_usage_tweak = self._common_data.char_tweak.weapon[weap_tweak.usage]
		self._weap_tweak = weap_tweak
		self._w_usage_tweak = weapon_usage_tweak
		self._aim_delay_minmax = weapon_usage_tweak.aim_delay or {0, 0}
		self._focus_delay = weapon_usage_tweak.focus_delay or 0
		self._focus_displacement = weapon_usage_tweak.focus_dis or 500
		self._spread = weapon_usage_tweak.spread or 20
		self._miss_dis = weapon_usage_tweak.miss_dis or 30
		self._automatic_weap = weap_tweak.auto and weapon_usage_tweak.autofire_rounds and true or nil
		self._reload_speed = weapon_usage_tweak.RELOAD_SPEED
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

		if self._changed_slot_mask then
			new_weapon_base:set_bullet_hit_slotmask(self._changed_slot_mask)
		end

		if self.update == self._upd_bleedout_no_weapon then
			self.update = self._upd_bleedout
		end
	else
		if self._shooting_hurt_tase then
			self._shooting_hurt_tase = nil

			if self._modifier_on then
				self._modifier_on = nil

				self._machine:allow_modifier(self._spine_modifier_name)
				self._machine:allow_modifier(self._head_modifier_name)
				self._machine:allow_modifier(self._r_arm_modifier_name)
			end
		elseif self._modifier_on then
			self._modifier_on = nil

			self._machine:allow_modifier(self._head_modifier_name)
			self._machine:allow_modifier(self._r_arm_modifier_name)
		end

		if self._delayed_shooting_hurt_clbk_id then
			managers.enemy:remove_delayed_clbk(self._delayed_shooting_hurt_clbk_id)

			self._delayed_shooting_hurt_clbk_id = nil
		end

		self._weapon_unit = nil
		self._weapon_base = nil
		self._weap_tweak = nil
		self._w_usage_tweak = nil
		self._aim_delay_minmax = nil
		self._focus_delay = nil
		self._focus_displacement = nil
		self._spread = nil
		self._miss_dis = nil
		self._automatic_weap = nil
		self._reload_speed = nil
		self._falloff = nil
		self._shoot_t = nil
		self._shoot_history = nil
		self._shield_slotmask = nil
		self._changed_slot_mask = nil

		if self.update == self._upd_bleedout then
			self.update = self._upd_bleedout_no_weapon
		end
	end
end

function CopActionHurt:save(save_data) ----not a priority, but add anim_start_t stuff eventually, requires going through almost the entire file
	local t_n = type_name
	local alive_g = alive

	for i, k in pairs_g(self._action_desc) do
		if t_n(k) ~= "Unit" or alive_g(k) then
			save_data[i] = k
		end
	end
end

function CopActionHurt:_start_ragdoll(reset_momentum)
	if self._ragdolled then
		return true
	end

	local unit = self._unit
	local u_dmg_ext = unit:damage()

	if not u_dmg_ext or not u_dmg_ext:has_sequence("switch_to_ragdoll") then
		return
	end

	if reset_momentum and u_dmg_ext:has_sequence("leg_arm_hitbox") then
		u_dmg_ext:run_sequence_simple("leg_arm_hitbox")
	end

	self._ragdolled = true

	self:on_death_drop(unit, 2)

	--self._ext_base:set_visibility_state(1)
	unit:set_driving("orientation_object")
	self._machine:set_enabled(false)
	unit:set_animations_enabled(false)

	u_dmg_ext:run_sequence_simple("switch_to_ragdoll")

	unit:add_body_activation_callback(callback(self, self, "clbk_body_active_state"))

	self._root_act_tags = {}
	local hips_body = unit:body("rag_Hips")
	local tag = hips_body:activate_tag()

	if tag == ids_empty then
		tag = ids_root_follow

		hips_body:set_activate_tag(tag)
	end

	self._root_act_tags[tag:key()] = true
	tag = hips_body:deactivate_tag()

	if tag == ids_empty then
		tag = ids_root_follow

		hips_body:set_deactivate_tag(tag)
	end

	self._root_act_tags[tag:key()] = true
	self._hips_obj = unit:get_object(ids_hips)
	self._ragdoll_active = true

	self._ext_movement:enable_update()

	self._rag_pos = self._hips_obj:position()
	self._ragdoll_freeze_clbk_id = "freeze_rag" .. tostring_g(unit:key())

	managers.enemy:add_delayed_clbk(self._ragdoll_freeze_clbk_id, callback(self, self, "clbk_chk_freeze_ragdoll"), self._timer:time() + 3)

	if self._ext_anim.repel_loop then
		unit:sound():anim_clbk_play_sound(unit, "repel_end")
	end

	return true
end

function CopActionHurt:clbk_chk_freeze_ragdoll()
	if not alive(self._unit) then
		return
	end

	if self._shooting_hurt then
		self._hips_obj:m_position(self._rag_pos)

		managers.enemy:add_delayed_clbk(self._ragdoll_freeze_clbk_id, callback(self, self, "clbk_chk_freeze_ragdoll"), self._timer:time() + 1.5)

		return
	end

	self._hips_obj:m_position(tmp_vec1)

	local cur_dis = mvec3_dis(self._rag_pos, tmp_vec1)

	if cur_dis < 30 then
		self._ragdoll_freeze_clbk_id = nil

		self:_freeze_ragdoll()
		self:_post_freeze_ragdoll()
	else
		mvec3_set(self._rag_pos, tmp_vec1)
		managers.enemy:add_delayed_clbk(self._ragdoll_freeze_clbk_id, callback(self, self, "clbk_chk_freeze_ragdoll"), self._timer:time() + 1.5)
	end
end

function CopActionHurt:_post_freeze_ragdoll()
	if self._ragdoll_freeze_clbk_id then
		managers.enemy:remove_delayed_clbk(self._ragdoll_freeze_clbk_id)

		self._ragdoll_freeze_clbk_id = nil

		self:_freeze_ragdoll()
	end

	if self._shooting_hurt then
		self._shooting_hurt = false

		self._weapon_base:stop_autofire()
	end

	if not self._weapon_dropped then
		self._weapon_dropped = true
		self._ext_inventory:drop_weapon()
	end

	--[[if Network:is_server() then
		local att_object = managers.groupai:state():get_all_AI_attention_objects()[self._unit:key()]
		local att_handler = att_object and att_object.handler

		if att_handler then
			att_handler:set_update_enabled(false)
		end
	end]]

	self.update = self._upd_empty
	self._unit:set_extension_update_enabled(ids_movement, false)
end

function CopActionHurt:clbk_shooting_hurt()
	self._delayed_shooting_hurt_clbk_id = nil

	if not alive(self._weapon_unit) then
		return
	end

	local weap_unit = self._weapon_unit
	local weap_base = self._weapon_base
	local shoot_from_pos = weap_unit:position()
	local shoot_to_pos = shoot_from_pos + weap_unit:rotation():y() * 1000
	local dir_vec = temp_vec1
	mvec3_dir(dir_vec, shoot_from_pos, shoot_to_pos)

	local spread_pos = temp_vec2
	mvec3_rand_orth(spread_pos, dir_vec)
	mvec3_set_l(spread_pos, self._spread)
	mvec3_add(spread_pos, shoot_to_pos)
	mvec3_dir(dir_vec, shoot_from_pos, spread_pos)

	local dmg_buff = self._ext_base:get_total_buff("base_damage")
	local dmg_mul = 1 + dmg_buff

	weap_base:singleshot(shoot_from_pos, dir_vec, dmg_mul)

	if self._drop_weapon_after_firing then
		local u_body = self._unit:body("rag_RightArm")

		if u_body and u_body:enabled() and u_body:dynamic() then
			local rot_acc = Vector3(1 - math_rand(2), 1 - math_rand(2), 1 - math_rand(2)) * 10
			local body_mass = u_body:mass()
			local length = mvec3_dir(temp_vec3, shoot_from_pos, u_body:center_of_mass())
			local body_vel = u_body:velocity()
			local vel_dot = mvec3_dot(body_vel, temp_vec3)
			local max_vel = 800

			if vel_dot < max_vel then
				mvec3_set_z(temp_vec3, temp_vec3.z + 0.75)

				local push_vel = max_vel - math_max(vel_dot, 0)

				mvec3_mul(temp_vec3, push_vel)
				world_g:play_physic_effect(ids_expl_physics, u_body, temp_vec3, body_mass / math_random(2), u_body:position(), rot_acc, 1)
			end
		end

		self._drop_weapon_after_firing = nil

		self._ext_inventory:drop_weapon()
	--[[elseif not weap_base.clip_empty or not weap_base:clip_empty() then
		self._delayed_shooting_hurt_clbk_id = "shooting_hurt" .. tostring_g(self._unit:key())

		managers.enemy:add_delayed_clbk(self._delayed_shooting_hurt_clbk_id, callback(self, self, "clbk_shooting_hurt"), self._timer:time() + math_lerp(1, 1.2, self:_pseudorandom()))]]
	end
end

function CopActionHurt:on_destroy()
	if self._autofiring or self._shooting_hurt then
		self._shooting_hurt = false
		self._autofiring = nil
		self._autoshots_fired = nil

		self._weapon_base:stop_autofire()
	end

	if self._delayed_shooting_hurt_clbk_id then
		managers.enemy:remove_delayed_clbk(self._delayed_shooting_hurt_clbk_id)

		self._delayed_shooting_hurt_clbk_id = nil
	end

	if self._shooting_player and alive(self._attention.unit) then
		self._attention.unit:movement():on_targetted_for_attack(false, self._unit)
	end

	local tased_effect = self._tased_effect

	if tased_effect then
		world_g:effect_manager():fade_kill(tased_effect)

		self._tased_effect = nil
	end

	local fire_effects_table = self._fire_death_effects_table

	if fire_effects_table then
		for i = 1, #fire_effects_table do
			local effect_id = fire_effects_table[i]

			world_g:effect_manager():fade_kill(effect_id)
		end
	end

	local fire_sound_table = self._fire_death_sound_source_table

	if fire_sound_table and fire_sound_table.sound_source then
		managers.fire:_stop_burn_body_sound(fire_sound_table.sound_source)
	end
end

function CopActionHurt:_get_transition_target_pos(shoot_from_pos, attention, t)
	local transition = self._aim_transition
	local prog = (t - transition.start_t) / transition.duration

	if prog > 1 then
		self._aim_transition = nil
		self._get_target_pos = nil

		return self:_get_target_pos(shoot_from_pos, attention)
	end

	prog = math_bezier(bezier_curve, prog)
	local target_pos, target_vec, target_dis, autotarget = nil

	if attention.handler then
		target_pos = temp_vec1

		mvec3_set(target_pos, attention.handler:get_attention_m_pos())

		if self._shooting_player then
			autotarget = true
		end
	elseif attention.unit then
		if self._shooting_player then
			autotarget = true
		end

		target_pos = temp_vec1

		attention.unit:character_damage():shoot_pos_mid(target_pos)
	else
		target_pos = attention.pos
	end

	target_vec = temp_vec3
	target_dis = mvec3_dir(target_vec, shoot_from_pos, target_pos)

	self._mod_enable_t = t + math_lerp(0.5, 0, prog)
	mvec3_lerp(target_vec, transition.start_vec, target_vec, prog)

	return target_pos, target_vec, target_dis, autotarget
end

function CopActionHurt:_get_target_pos(shoot_from_pos, attention)
	local target_pos, target_vec, target_dis, autotarget = nil

	if attention.handler then
		target_pos = temp_vec1

		mvec3_set(target_pos, attention.handler:get_attention_m_pos())

		if self._shooting_player then
			autotarget = true
		end
	elseif attention.unit then
		if self._shooting_player then
			autotarget = true
		end

		target_pos = temp_vec1

		attention.unit:character_damage():shoot_pos_mid(target_pos)
	else
		target_pos = attention.pos
	end

	target_vec = temp_vec3
	target_dis = mvec3_dir(target_vec, shoot_from_pos, target_pos)

	return target_pos, target_vec, target_dis, autotarget
end

function CopActionHurt:set_ik_preset(preset_name)
	self[self._ik_preset.stop](self)

	local preset_data = self._ik_presets[preset_name]
	self._ik_preset = preset_data

	self[preset_data.start](self)
end

function CopActionHurt:_begin_spine_head_r_arm()
	if self._spine_modifier then
		return
	end

	self._spine_modifier_name = ids_action_upper_body
	self._spine_modifier = self._machine:get_modifier(self._spine_modifier_name)
	self._head_modifier_name = ids_look_head
	self._head_modifier = self._machine:get_modifier(self._head_modifier_name)
	self._r_arm_modifier_name = ids_aim_r_arm
	self._r_arm_modifier = self._machine:get_modifier(self._r_arm_modifier_name)

	self._modifier_on = nil
	self._mod_enable_t = nil

	self:_set_ik_updator("_upd_spine_head_r_arm")
end

function CopActionHurt:_stop_spine_head_r_arm()
	if not self._spine_modifier then
		return
	end

	self._machine:allow_modifier(self._spine_modifier_name)
	self._machine:allow_modifier(self._head_modifier_name)
	self._machine:allow_modifier(self._r_arm_modifier_name)

	self._spine_modifier_name = nil
	self._spine_modifier = nil
	self._head_modifier_name = nil
	self._head_modifier = nil
	self._r_arm_modifier_name = nil
	self._r_arm_modifier = nil
	self._modifier_on = nil
end

function CopActionHurt:_upd_spine_head_r_arm(target_vec, fwd_dot, t)
	if fwd_dot > 0.5 then
		if not self._modifier_on then
			self._modifier_on = true

			self._machine:force_modifier(self._spine_modifier_name)
			self._machine:force_modifier(self._head_modifier_name)
			self._machine:force_modifier(self._r_arm_modifier_name)
		end

		self._spine_modifier:set_target_y(target_vec)
		self._head_modifier:set_target_z(target_vec)
		self._r_arm_modifier:set_target_y(target_vec)
		mvec3_set(self._common_data.look_vec, target_vec)

		return target_vec
	else
		if self._modifier_on then
			self._modifier_on = nil

			self._machine:allow_modifier(self._spine_modifier_name)
			self._machine:allow_modifier(self._head_modifier_name)
			self._machine:allow_modifier(self._r_arm_modifier_name)
		end

		return nil
	end
end

function CopActionHurt:_get_blend_spine_head_r_arm()
	return self._r_arm_modifier:blend()
end

function CopActionHurt:_begin_ik_r_arm()
	if self._head_modifier then
		return
	end

	self._head_modifier_name = ids_look_head
	self._head_modifier = self._machine:get_modifier(self._head_modifier_name)
	self._r_arm_modifier_name = ids_aim_r_arm
	self._r_arm_modifier = self._machine:get_modifier(self._r_arm_modifier_name)
	self._modifier_on = nil
	self._mod_enable_t = nil

	self:_set_ik_updator("_upd_ik_r_arm")
end

function CopActionHurt:_stop_ik_r_arm()
	if not self._head_modifier then
		return
	end

	self._machine:allow_modifier(self._head_modifier_name)
	self._machine:allow_modifier(self._r_arm_modifier_name)

	self._head_modifier_name = nil
	self._head_modifier = nil
	self._r_arm_modifier_name = nil
	self._r_arm_modifier = nil
	self._modifier_on = nil
end

function CopActionHurt:_upd_ik_r_arm(target_vec, fwd_dot, t)
	if fwd_dot then
		if fwd_dot > 0.5 then
			if not self._modifier_on then
				self._modifier_on = true

				self._machine:force_modifier(self._head_modifier_name)
				self._machine:force_modifier(self._r_arm_modifier_name)
			end

			self._head_modifier:set_target_z(target_vec)
			self._r_arm_modifier:set_target_y(target_vec)
			mvec3_set(self._common_data.look_vec, target_vec)

			return target_vec
		else
			if self._modifier_on then
				self._modifier_on = nil

				self._machine:allow_modifier(self._head_modifier_name)
				self._machine:allow_modifier(self._r_arm_modifier_name)
			end

			return nil
		end
	end

	if not self._modifier_on then
		self._modifier_on = true

		self._machine:force_modifier(self._head_modifier_name)
		self._machine:force_modifier(self._r_arm_modifier_name)
	end

	self._head_modifier:set_target_z(target_vec)
	self._r_arm_modifier:set_target_y(target_vec)
	mvec3_set(self._common_data.look_vec, target_vec)

	return target_vec
end

function CopActionHurt:_get_blend_ik_r_arm()
	return self._r_arm_modifier:blend()
end

function CopActionHurt:_set_ik_updator(name)
	self._upd_ik = self[name]
end
