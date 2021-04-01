local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_lerp = mvector3.lerp
local mvec3_add = mvector3.add
local mvec3_sub = mvector3.subtract
local mvec3_mul = mvector3.multiply
local mvec3_norm = mvector3.normalize
local mvec3_len = mvector3.length
local mvec3_dir = mvector3.direction
local mvec3_cpy = mvector3.copy
local mvec3_dis = mvector3.distance
local mvec3_dot = mvector3.dot

local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
local temp_vec3 = Vector3()
local tmp_vec1 = Vector3()
local zero_vel_vec = Vector3(0, 0, 0)

local mrot_set = mrotation.set_yaw_pitch_roll
local mrot_lookat = mrotation.set_look_at
local tmp_rot_1 = Rotation()

local math_abs = math.abs
local math_min = math.min
local math_max = math.max
local math_random = math.random
local math_up = math.UP
local math_lerp = math.lerp

local table_insert = table.insert
local table_remove = table.remove
local next_g = next
local tostring_g = tostring

local world_g = World
local alive_g = alive
local call_on_next_update_g = call_on_next_update

local ids_func = Idstring
local left_hand_str = ids_func("LeftHandMiddle2")
local ids_movement = ids_func("movement")

local action_variants = {
	security = {
		idle = CopActionIdle,
		act = CopActionAct,
		walk = CopActionWalk,
		turn = CopActionTurn,
		hurt = CopActionHurt,
		stand = CopActionStand,
		crouch = CopActionCrouch,
		shoot = CopActionShoot,
		reload = CopActionReload,
		spooc = ActionSpooc,
		tase = CopActionTase,
		dodge = CopActionDodge,
		warp = CopActionWarp,
		healed = CopActionHealed
	}
}
local security_variant = action_variants.security

local old_init = CopMovement.init
function CopMovement:init(unit)
	CopMovement._action_variants.deathvox_shield = clone(security_variant)
	CopMovement._action_variants.deathvox_shield.hurt = ShieldActionHurt
	CopMovement._action_variants.deathvox_shield.walk = ShieldCopActionWalk
	CopMovement._action_variants.deathvox_heavyar = security_variant
	CopMovement._action_variants.deathvox_lightar = security_variant
	CopMovement._action_variants.deathvox_medic = clone(security_variant)
	CopMovement._action_variants.deathvox_medic.heal = MedicActionHeal
	CopMovement._action_variants.deathvox_guard = security_variant
	CopMovement._action_variants.deathvox_gman = security_variant
	CopMovement._action_variants.deathvox_lightshot = security_variant
	CopMovement._action_variants.deathvox_heavyshot = security_variant

	CopMovement._action_variants.deathvox_taser = security_variant
	CopMovement._action_variants.deathvox_sniper_assault = security_variant
	CopMovement._action_variants.deathvox_sniper = security_variant
	CopMovement._action_variants.deathvox_cloaker = security_variant
	CopMovement._action_variants.deathvox_grenadier = security_variant

	CopMovement._action_variants.deathvox_greendozer = clone(security_variant)
	CopMovement._action_variants.deathvox_greendozer.walk = TankCopActionWalk
	CopMovement._action_variants.deathvox_guarddozer = clone(security_variant)
	CopMovement._action_variants.deathvox_guarddozer.walk = TankCopActionWalk
	CopMovement._action_variants.deathvox_blackdozer = clone(security_variant)
	CopMovement._action_variants.deathvox_blackdozer.walk = TankCopActionWalk
	CopMovement._action_variants.deathvox_lmgdozer = clone(security_variant)
	CopMovement._action_variants.deathvox_lmgdozer.walk = TankCopActionWalk
	CopMovement._action_variants.deathvox_medicdozer = clone(security_variant)
	CopMovement._action_variants.deathvox_medicdozer.walk = TankCopActionWalk
	CopMovement._action_variants.deathvox_medicdozer.heal = MedicActionHeal

	CopMovement._action_variants.deathvox_cop_pistol = security_variant
	CopMovement._action_variants.deathvox_cop_revolver = security_variant
	CopMovement._action_variants.deathvox_cop_shotgun = security_variant
	CopMovement._action_variants.deathvox_cop_smg = security_variant

	CopMovement._action_variants.deathvox_fbi_hrt = security_variant
	CopMovement._action_variants.deathvox_fbi_veteran = security_variant
	CopMovement._action_variants.deathvox_fbi_rookie = security_variant

	old_init(self, unit)
end

function CopMovement:post_init()
	local unit = self._unit
	self._ext_brain = unit:brain()
	self._ext_network = unit:network()
	self._ext_anim = unit:anim_data()
	self._ext_base = unit:base()
	self._ext_damage = unit:character_damage()
	self._ext_inventory = unit:inventory()
	self._tweak_data = tweak_data.character[self._ext_base._tweak_table]
	tweak_data:add_reload_callback(self, self.tweak_data_clbk_reload)
	self._machine = self._unit:anim_state_machine()
	self._machine:set_callback_object(self)
	self._stance = {
		code = 1,
		name = "ntl",
		values = {
			1,
			0,
			0,
			0
		}
	}

	if managers.navigation:is_data_ready() then
		self._nav_tracker = managers.navigation:create_nav_tracker(self._m_pos)
		self._pos_rsrv_id = managers.navigation:get_pos_reservation_id()
	else
		--Application:error("[CopMovement:post_init] Spawned AI unit with incomplete navigation data.")
		self._unit:set_extension_update(ids_movement, false)
	end

	self._unit:kill_mover()
	self._unit:set_driving("script")
	self._unit:unit_data().has_alarm_pager = self._tweak_data.has_alarm_pager
	self._unit:unit_data().ignore_ecm_for_pager = self._tweak_data.ignore_ecm_for_pager

	local event_list = {
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
	self._unit:character_damage():add_listener("movement", event_list, callback(self, self, "damage_clbk"))

	self._unit:inventory():add_listener("movement", {"equip", "unequip"}, callback(self, self, "clbk_inventory"))

	self:add_weapons()

	if self._unit:inventory():is_selection_available(1) then
		self._unit:inventory():equip_selection(1, true)
	elseif self._unit:inventory():is_selection_available(2) then
		self._unit:inventory():equip_selection(2, true)
	end

	if self._ext_inventory:equipped_selection() == 2 and managers.groupai:state():whisper_mode() then
		self._ext_inventory:set_weapon_enabled(false)
	end

	self._ext_base:default_weapon_name(managers.groupai:state():enemy_weapons_hot() and "primary" or "secondary")

	local fwd = self._m_rot:y()
	self._action_common_data = {
		stance = self._stance,
		pos = self._m_pos,
		rot = self._m_rot,
		fwd = fwd,
		right = self._m_rot:x(),
		unit = unit,
		machine = self._machine,
		ext_movement = self,
		ext_brain = self._ext_brain,
		ext_anim = self._ext_anim,
		ext_inventory = self._ext_inventory,
		ext_base = self._ext_base,
		ext_network = self._ext_network,
		ext_damage = self._ext_damage,
		char_tweak = self._tweak_data,
		nav_tracker = self._nav_tracker,
		active_actions = self._active_actions,
		queued_actions = self._queued_actions,
		look_vec = mvec3_cpy(fwd)
	}

	self:upd_ground_ray()

	if self._gnd_ray then
		self:set_position(self._gnd_ray.position)
	end

	self:_post_init()
end

local difficulty_skins = {
	cop = "nil-mint-0",
	fbi = "m16_cs4-mint-0",
	gensec = "contraband_css-mint-0",
	zeal = "l85a2_cs4-mint-0",
	murky = "new_m4_skf-mint-0",
	classic = "amcar_same-mint-0"
}

function CopMovement:add_weapons()
	if self._tweak_data.use_factory then
		local weapon_to_use = self._tweak_data.factory_weapon_id[math_random(#self._tweak_data.factory_weapon_id)]
		local faction = tweak_data.levels:get_ai_group_type()
		local weapon_cosmetic = difficulty_skins[faction]
		if weapon_to_use then
			if weapon_cosmetic then
				self._unit:inventory():add_unit_by_factory_name(weapon_to_use, false, false, nil, weapon_cosmetic)
			else
				self._unit:inventory():add_unit_by_factory_name(weapon_to_use, false, false, nil, "")
			end
		end
	else
		local prim_weap_name = self._ext_base:default_weapon_name("primary")
		local sec_weap_name = self._ext_base:default_weapon_name("secondary")

		if prim_weap_name then
			self._unit:inventory():add_unit_by_name(prim_weap_name)
		end

		if sec_weap_name and sec_weap_name ~= prim_weap_name then
			self._unit:inventory():add_unit_by_name(sec_weap_name)
		end
	end
end

function CopMovement:is_taser_attack_allowed()
	return
end

function CopMovement:_chk_play_equip_weapon()
	if self._stance.values[1] == 1 and not self._ext_anim.equip and not self._tweak_data.no_equip_anim and not self:chk_action_forbidden("action") then
		local redir_res = self:play_redirect("equip")

		if redir_res then
			local weapon_unit = self._ext_inventory:equipped_unit()

			if weapon_unit then
				local weap_tweak = weapon_unit:base():weapon_tweak_data()
				local weapon_hold = weap_tweak.hold

				if type(weap_tweak.hold) == "table" then
					local num = #weap_tweak.hold + 1

					for i, hold_type in ipairs(weap_tweak.hold) do
						self._machine:set_parameter(redir_res, "to_" .. hold_type, num - i)
					end
				else
					self._machine:set_parameter(redir_res, "to_" .. weap_tweak.hold, 1)
				end
			end
		end
	end

	self._ext_inventory:set_weapon_enabled(true)
end

function CopMovement:damage_clbk(my_unit, damage_info)
	local hurt_type = damage_info.result.type

	if not hurt_type then
		return
	end

	if hurt_type == "healed" then
		self._ext_damage._health = self._ext_damage._HEALTH_INIT
		self._ext_damage._health_ratio = 1

		if self._unit:contour() then
			self._unit:contour():add("medic_heal")
			self._unit:contour():flash("medic_heal", 0.2)
		end

		if Network:is_server() then
			managers.modifiers:run_func("OnEnemyHealed", nil, self._unit)
		end

		if damage_info.is_synced or self._tweak_data.ignore_medic_revive_animation then
			return
		end

		local action_data = {
			body_part = 1,
			type = "healed",
			client_interrupt = Network:is_client(),
			allow_network = true
		}

		self:action_request(action_data)

		return
	elseif hurt_type == "death" and damage_info.is_synced then
		if self._queued_actions then
			self._queued_actions = {}
		end

		if self._rope then
			self._rope:base():retract()

			self._rope = nil
			self._rope_death = true

			if self._unit:sound().anim_clbk_play_sound then
				self._unit:sound():anim_clbk_play_sound(self._unit, "repel_end")
			end
		end

		if Network:is_server() then
			self:set_attention()
			self:throw_bag()
			self:set_joker_cooldown(false)
		else
			self:synch_attention()

			local carry_unit = self._carry_unit

			if carry_unit then
				carry_unit:carry_data():unlink()
				self:sync_throw_bag(carry_unit)
			end
		end

		local attack_dir = damage_info.col_ray and damage_info.col_ray.ray or damage_info.attack_dir
		local hit_pos = damage_info.col_ray and damage_info.col_ray.position or damage_info.pos
		local body_part = 1
		local blocks = {
			act = -1,
			aim = -1,
			action = -1,
			tase = -1,
			walk = -1,
			light_hurt = -1
		}

		local tweak = self._tweak_data
		local death_type = "normal"

		if tweak.damage.death_severity then
			if tweak.damage.death_severity < damage_info.damage / self._ext_damage._HEALTH_INIT then
				death_type = "heavy"
			end
		end

		local action_data = {
			type = "hurt",
			block_type = hurt_type,
			hurt_type = hurt_type,
			variant = damage_info.variant,
			direction_vec = attack_dir,
			hit_pos = hit_pos,
			body_part = body_part,
			blocks = blocks,
			client_interrupt = Network:is_client(),
			attacker_unit = damage_info.attacker_unit,
			death_type = death_type,
			ignite_character = damage_info.ignite_character,
			start_dot_damage_roll = damage_info.start_dot_damage_roll,
			is_fire_dot_damage = damage_info.is_fire_dot_damage,
			fire_dot_data = damage_info.fire_dot_data,
			allow_network = false
		}

		self:action_request(action_data)

		return
	elseif damage_info.is_synced or damage_info.variant == "bleeding" and not Network:is_server() then
		return
	end

	if hurt_type ~= "death" then
		if damage_info.variant == "bullet" or damage_info.variant == "explosion" or damage_info.variant == "fire" or damage_info.variant == "poison" or damage_info.variant == "dot" or damage_info.variant == "graze" then
			hurt_type = managers.modifiers:modify_value("CopMovement:HurtType", hurt_type)

			if not hurt_type then
				return
			end
		end
	end

	if self._anim_global == "shield" and damage_info.variant == "stun" and hurt_type ~= "death" then
		hurt_type = "expl_hurt"
		damage_info.result = {
			variant = damage_info.variant,
			type = "expl_hurt"
		}
	elseif hurt_type == "stagger" or hurt_type == "knock_down" then
		if self._anim_global == "shield" then
			hurt_type = "expl_hurt"
		else
			hurt_type = "hurt"
		end
	elseif hurt_type == "hurt" or hurt_type == "heavy_hurt" then
		if self._anim_global == "shield" then
			hurt_type = "expl_hurt"
		end
	end

	local block_type = hurt_type

	if hurt_type == "expl_hurt" or hurt_type == "fire_hurt" or hurt_type == "poison_hurt" or hurt_type == "taser_tased" then
		block_type = "heavy_hurt"
	end

	if hurt_type == "death" and self._queued_actions then
		self._queued_actions = {}
	end

	if Network:is_server() and self:chk_action_forbidden(block_type) then
		return
	end

	if hurt_type == "death" then
		if self._rope then
			self._rope:base():retract()

			self._rope = nil
			self._rope_death = true

			if self._unit:sound().anim_clbk_play_sound then
				self._unit:sound():anim_clbk_play_sound(self._unit, "repel_end")
			end
		end

		if Network:is_server() then
			self:set_attention()
			self:throw_bag()
			self:set_joker_cooldown(false)
		else
			self:synch_attention()

			local carry_unit = self._carry_unit

			if carry_unit then
				carry_unit:carry_data():unlink()
				self:sync_throw_bag(carry_unit)
			end
		end
	end

	local attack_dir = damage_info.col_ray and damage_info.col_ray.ray or damage_info.attack_dir
	local hit_pos = damage_info.col_ray and damage_info.col_ray.position or damage_info.pos
	local lgt_hurt = hurt_type == "light_hurt"
	local body_part = lgt_hurt and 4 or 1
	local blocks = nil

	if not lgt_hurt then
		blocks = {
			act = -1,
			aim = -1,
			action = -1,
			tase = -1,
			walk = -1,
			light_hurt = -1
		}

		if hurt_type == "bleedout" then
			blocks.bleedout = -1
			blocks.hurt = -1
			blocks.heavy_hurt = -1
			blocks.hurt_sick = -1
			blocks.concussion = -1
		end
	end

	local client_interrupt = nil

	if hurt_type == "death" then
		client_interrupt = Network:is_client()
	elseif damage_info.variant == "tase" then
		block_type = "bleedout"
	elseif hurt_type == "expl_hurt" or hurt_type == "fire_hurt" or hurt_type == "poison_hurt" or hurt_type == "taser_tased" then
		block_type = "heavy_hurt"

		if Network:is_client() then
			client_interrupt = true
		end
	elseif hurt_type ~= "bleedout" and hurt_type ~= "fatal" then
		if Network:is_client() then
			client_interrupt = true
		end

		block_type = "hurt"
	end

	local tweak = self._tweak_data
	local death_type = "normal"

	if tweak.damage.death_severity then
		if tweak.damage.death_severity < damage_info.damage / self._ext_damage._HEALTH_INIT then
			death_type = "heavy"
		end
	end

	local action_data = {
		type = "hurt",
		block_type = block_type,
		hurt_type = hurt_type,
		variant = damage_info.variant,
		direction_vec = attack_dir,
		hit_pos = hit_pos,
		body_part = body_part,
		blocks = blocks,
		client_interrupt = client_interrupt,
		attacker_unit = damage_info.attacker_unit,
		death_type = death_type,
		ignite_character = damage_info.ignite_character,
		start_dot_damage_roll = damage_info.start_dot_damage_roll,
		is_fire_dot_damage = damage_info.is_fire_dot_damage,
		fire_dot_data = damage_info.fire_dot_data,
		allow_network = true
	}

	if Network:is_server() or not self:chk_action_forbidden(action_data) then
		self:action_request(action_data)
	end
end

function CopMovement:anim_clbk_enemy_spawn_melee_item()
	local unit_name = self._melee_item_unit_name

	if unit_name == false or unit_name and alive_g(self._melee_item_unit) then
		return
	end

	if unit_name == nil then
		local base_ext = self._ext_base
		local melee_weapon = base_ext.melee_weapon and base_ext:melee_weapon()

		if melee_weapon and melee_weapon ~= "weapon" then
			local npc_melee_tweak_data = tweak_data.weapon.npc_melee[melee_weapon]

			if npc_melee_tweak_data then
				unit_name = npc_melee_tweak_data.unit_name
				self._melee_item_unit_name = unit_name
			else
				local ms = managers
				local melee_weapon_data = ms.blackmarket:get_melee_weapon_data(melee_weapon)

				if melee_weapon_data then
					local third_unit = melee_weapon_data.third_unit

					if third_unit then
						unit_name = ids_func(third_unit)
						self._melee_item_unit_name = unit_name
					end
				end
			end
		end

		if not unit_name then
			self._melee_item_unit_name = false

			return
		end
	end

	local my_unit = self._unit
	local align_obj_l_name = CopMovement._gadgets.aligns.hand_l
	local align_obj_l = my_unit:get_object(align_obj_l_name)
	local melee_unit = world_g:spawn_unit(unit_name, align_obj_l:position(), align_obj_l:rotation())

	my_unit:link(align_obj_l:name(), melee_unit, melee_unit:orientation_object():name())

	self._melee_item_unit = melee_unit
end

local pre_destroy_original = CopMovement.pre_destroy
function CopMovement:pre_destroy()
	pre_destroy_original(self)

	local melee_unit = self._melee_item_unit

	if alive_g(melee_unit) then
		melee_unit:unlink()
		world_g:delete_unit(melee_unit)

		self._melee_item_unit = nil
	end

	if Network:is_server() then
		self:throw_bag()
		self:set_joker_cooldown(false)
	else
		local carry_unit = self._carry_unit

		if carry_unit then
			carry_unit:carry_data():unlink()
			self:sync_throw_bag(carry_unit)
		end
	end

	self.update = self._upd_empty
end

function CopMovement:_upd_empty()
	self._gnd_ray = nil

	unit:set_extension_update_enabled(ids_movement, false)
end

function CopMovement:update(unit, t, dt)
	local old_need_upd = self._need_upd
	self._need_upd = false

	self:_upd_actions(t)

	if self._need_upd ~= old_need_upd then
		unit:set_extension_update_enabled(ids_movement, self._need_upd)
	end

	if self._force_head_upd then
		self._force_head_upd = nil

		self:upd_m_head_pos()
	end
end

function CopMovement:_upd_actions(t)
	local a_actions = self._active_actions
	local has_no_action = true

	for i = 1, #a_actions do
		local action = a_actions[i]

		if action then
			if action.update then
				action:update(t)
			end

			if not self._need_upd and action.need_upd then
				self._need_upd = action:need_upd()
			end

			if action.expired and action:expired() then
				a_actions[i] = false

				if action.on_exit then
					action:on_exit()
				end

				self._ext_brain:action_complete_clbk(action)
				self._ext_base:chk_freeze_anims()
			else
				has_no_action = nil
			end
		end
	end

	if has_no_action then
		for i = 1, #a_actions do
			local action = a_actions[i]

			if action then
				has_no_action = nil

				break
			end
		end
	end

	if has_no_action then
		local queued_actions = self._queued_actions

		if not queued_actions or not next_g(queued_actions) then
			self:play_redirect("idle")

			self:action_request({
				body_part = 3,
				type = "idle"
			})
		end
	end

	if not a_actions[1] then
		local queued_actions = self._queued_actions

		if not queued_actions or not next_g(queued_actions) then
			if not a_actions[2] then
				if not a_actions[3] and not self:chk_action_forbidden("action") then
					self:action_request({
						body_part = 3,
						type = "idle"
					})
				end
			elseif a_actions[2]:type() == "idle" then
				if not a_actions[3] then
					if not self:chk_action_forbidden("action") then
						self:action_request({
							body_part = 2,
							type = "idle",
							non_persistent = true,
							client_interrupt = true
						})

						self:action_request({
							body_part = 3,
							type = "idle"
						})
					end
				elseif a_actions[3]:type() == "idle" then
					if not self:chk_action_forbidden("action") then
						self:action_request({
							body_part = 2,
							type = "idle",
							non_persistent = true,
							client_interrupt = true
						})
					end
				end
			elseif not a_actions[3] and not self:chk_action_forbidden("action") then
				self:action_request({
					body_part = 3,
					type = "idle"
				})
			end
		end
	end

	self:_upd_stance(t)

	if not self._need_upd then
		local ext_anim = self._ext_anim

		if ext_anim.base_need_upd or ext_anim.upper_need_upd or ext_anim.fumble or self._stance.transition or self._suppression.transition then
			self._need_upd = true
		end
	end
end

function CopMovement:on_suppressed(state)
	local suppression = self._suppression
	local end_value = state and 1 or 0
	local vis_state = self._ext_base:lod_stage()

	if vis_state and end_value ~= suppression.value then
		local t = TimerManager:game():time()
		local duration = 0.5 * math_abs(end_value - suppression.value)
		suppression.transition = {
			end_val = end_value,
			start_val = suppression.value,
			duration = duration,
			start_t = t,
			next_upd_t = t + 0.07
		}
	else
		suppression.transition = nil
		suppression.value = end_value

		self._machine:set_global("sup", end_value)
	end

	self._action_common_data.is_suppressed = state and true or nil

	if Network:is_server() then
		if state then
			if not self._tweak_data.allowed_poses or self._tweak_data.allowed_poses.crouch then
				if not self._tweak_data.allowed_poses or self._tweak_data.allowed_poses.stand then
					if not self:chk_action_forbidden("walk") then
						local try_something_else = true

						if state == "panic" and not self:chk_action_forbidden("act") then
							if self._ext_anim.run and self._ext_anim.move_fwd then
								local action_desc = {
									clamp_to_graph = true,
									type = "act",
									body_part = 1,
									variant = "e_so_sup_fumble_run_fwd",
									blocks = {
										action = -1,
										walk = -1
									}
								}

								if self:action_request(action_desc) then
									try_something_else = false
								end
							else
								local allow = nil
								local vec_from = temp_vec1
								local vec_to = temp_vec2
								local ray_params = {
									allow_entry = false,
									trace = true,
									tracker_from = self:nav_tracker(),
									pos_from = vec_from,
									pos_to = vec_to
								}
								local allowed_fumbles = {
									"e_so_sup_fumble_inplace_3"
								}

								mvec3_set(ray_params.pos_from, self:m_pos())
								mvec3_set(ray_params.pos_to, self:m_rot():y())
								mvec3_mul(ray_params.pos_to, -100)
								mvec3_add(ray_params.pos_to, self:m_pos())

								allow = not managers.navigation:raycast(ray_params)

								if allow then
									table_insert(allowed_fumbles, "e_so_sup_fumble_inplace_1")
								end

								mvec3_set(ray_params.pos_from, self:m_pos())
								mvec3_set(ray_params.pos_to, self:m_rot():x())
								mvec3_mul(ray_params.pos_to, 200)
								mvec3_add(ray_params.pos_to, self:m_pos())

								allow = not managers.navigation:raycast(ray_params)

								if allow then
									table_insert(allowed_fumbles, "e_so_sup_fumble_inplace_2")
								end

								mvec3_set(ray_params.pos_from, self:m_pos())
								mvec3_set(ray_params.pos_to, self:m_rot():x())
								mvec3_mul(ray_params.pos_to, -200)
								mvec3_add(ray_params.pos_to, self:m_pos())

								allow = not managers.navigation:raycast(ray_params)

								if allow then
									table_insert(allowed_fumbles, "e_so_sup_fumble_inplace_4")
								end

								if #allowed_fumbles > 0 then
									local action_desc = {
										body_part = 1,
										type = "act",
										variant = allowed_fumbles[math_random(#allowed_fumbles)],
										blocks = {
											action = -1,
											walk = -1
										}
									}

									if self:action_request(action_desc) then
										try_something_else = false
									end
								end
							end
						end

						if try_something_else and not self._ext_anim.crouch and self._tweak_data.crouch_move then
							if self._ext_anim.idle then
								if not self._active_actions[2] or self._active_actions[2]:type() == "idle" then
									if not self:chk_action_forbidden("act") then
										local action_desc = {
											clamp_to_graph = true,
											type = "act",
											body_part = 2,
											variant = "suppressed_reaction",
											blocks = {
												walk = -1
											}
										}

										if self:action_request(action_desc) then
											try_something_else = false
										end
									end
								end
							end

							if try_something_else and not self:chk_action_forbidden("crouch") then
								local action_desc = {
									body_part = 4,
									type = "crouch"
								}

								self:action_request(action_desc)
							end
						end
					end
				end
			end
		end

		managers.network:session():send_to_peers_synched("suppressed_state", self._unit, state and true or false)
	end

	self:enable_update()
end

function CopMovement:sync_action_act_start(index, blocks_hurt, clamp_to_graph, needs_full_blend, start_rot, start_pos)
	if self._ext_damage:dead() then
		return
	end

	local redir_name = self._actions.act:_get_act_name_from_index(index)
	local body_part = 1
	local blocks = nil

	if redir_name == "suppressed_reaction" then
		body_part = 2
		blocks = {
			walk = -1,
			act = -1,
			idle = -1,
			dodge = -1
		}
	elseif redir_name == "gesture_stop" or redir_name == "arrest" or redir_name == "cmd_get_up" or redir_name == "cmd_down" or redir_name == "cmd_stop" or redir_name == "cmd_gogo" or redir_name == "cmd_point" then
		body_part = 3
		blocks = {
			action = -1,
			act = -1,
			idle = -1
		}
	else
		blocks = {
			act = -1,
			idle = -1,
			action = -1,
			walk = -1
		}
	end

	local action_data = {
		type = "act",
		body_part = body_part,
		variant = redir_name,
		blocks = blocks,
		start_rot = start_rot,
		start_pos = start_pos,
		clamp_to_graph = clamp_to_graph,
		needs_full_blend = needs_full_blend
	}

	if blocks_hurt then
		action_data.blocks.light_hurt = -1
		action_data.blocks.hurt = -1
		action_data.blocks.heavy_hurt = -1
		action_data.blocks.expl_hurt = -1
		action_data.blocks.fire_hurt = -1
	end

	self:action_request(action_data)
end

function CopMovement:sync_action_dodge_start(body_part, var, side, rot, speed, shoot_acc)
	if self._ext_damage:dead() then
		return
	end

	local action_data = {
		type = "dodge",
		body_part = body_part,
		variation = CopActionDodge.get_variation_name(var),
		direction = Rotation(rot):y(),
		side = CopActionDodge.get_side_name(side),
		speed = speed,
		shoot_accuracy = shoot_acc,
		blocks = {
			act = -1,
			tase = -1,
			bleedout = -1,
			dodge = -1,
			walk = -1,
			action = body_part == 1 and -1 or nil,
			aim = body_part == 1 and -1 or nil
		}
	}

	if action_data.variation ~= "side_step" then
		action_data.blocks.hurt = -1
		action_data.blocks.heavy_hurt = -1
	end

	self:action_request(action_data)
end

function CopMovement:sync_action_spooc_nav_point(pos, action_id)
	local spooc_action, is_queued = self:_get_latest_spooc_action(action_id)

	if is_queued then
		local stop_pos = spooc_action.stop_pos
		local nr_exp_points = spooc_action.nr_expected_nav_points

		if stop_pos and not nr_exp_points then
			return
		end

		local path = spooc_action.nav_path

		path[#path + 1] = pos

		if nr_exp_points then
			if nr_exp_points == 1 then
				spooc_action.nr_expected_nav_points = nil

				path[#path + 1] = stop_pos
			else
				spooc_action.nr_expected_nav_points = nr_exp_points - 1
			end
		end

		spooc_action.nav_path = path
	elseif spooc_action then
		spooc_action:sync_append_nav_point(pos)
	end
end

function CopMovement:sync_action_spooc_stop(pos, stop_nav_index, action_id)
	local spooc_action, is_queued = self:_get_latest_spooc_action(action_id)

	if is_queued then
		spooc_action.host_expired = true
		spooc_action.stop_pos = mvec3_cpy(pos)

		local host_stop_pos_i = spooc_action.host_stop_pos_inserted

		if host_stop_pos_i then
			stop_nav_index = stop_nav_index + host_stop_pos_i
		end

		local path = spooc_action.nav_path

		if #path > stop_nav_index then
			local new_path_table = {}

			for i = 1, stop_nav_index do
				new_path_table[#new_path_table + 1] = path[i]
			end

			path = new_path_table
		end

		if #path < stop_nav_index - 1 then
			spooc_action.nr_expected_nav_points = stop_nav_index - #path + 1
		else
			path[#path + 1] = pos

			local new_index = #path - 1
			new_index = new_index < 1 and 1 or new_index

			if new_index < spooc_action.path_index then
				spooc_action.path_index = new_index
			end
		end

		spooc_action.nav_path = path
	elseif spooc_action then
		spooc_action:sync_stop(pos, stop_nav_index)
	end
end

function CopMovement:sync_action_spooc_strike(pos, action_id)
	local spooc_action, is_queued = self:_get_latest_spooc_action(action_id)

	if is_queued then
		local stop_pos = spooc_action.stop_pos
		local nr_exp_points = spooc_action.nr_expected_nav_points

		if stop_pos and not nr_exp_points then
			return
		end

		spooc_action.strike = true

		if spooc_action.flying_strike then
			return
		end

		local path = spooc_action.nav_path
		path[#path + 1] = pos

		spooc_action.strike_nav_index = #path

		if nr_exp_points then
			if nr_exp_points == 1 then
				spooc_action.nr_expected_nav_points = nil

				path[#path + 1] = stop_pos
			else
				spooc_action.nr_expected_nav_points = nr_exp_points - 1
			end
		end

		spooc_action.nav_path = path
	elseif spooc_action then
		spooc_action:sync_strike(pos)
	end
end

function CopMovement:_get_latest_act_action()
	if self._queued_actions then
		for i = #self._queued_actions, 1, -1 do
			if self._queued_actions[i].type == "act" and not self._queued_actions[i].host_expired then
				return self._queued_actions[i], true, i
			end
		end
	end

	for body_part, action in ipairs(self._active_actions) do
		if action and action:type() == "act" then
			return self._active_actions[body_part], false, body_part
		end
	end
end

function CopMovement:sync_action_act_end()
	local act_action, queued, body_part = self:_get_latest_act_action()

	if queued then
		act_action.host_expired = true
	elseif act_action then
		self._active_actions[body_part] = false

		if act_action.on_exit then
			act_action:on_exit()
		end

		self:_chk_start_queued_action()
		self._ext_brain:action_complete_clbk(act_action)
	end
end

function CopMovement:_get_latest_tase_action()
	if self._queued_actions then
		for i = #self._queued_actions, 1, -1 do
			local action = self._queued_actions[i]

			if action.type == "tase" then
				return self._queued_actions[i], true
			end
		end
	end

	if self._active_actions[3] and self._active_actions[3]:type() == "tase" and not self._active_actions[3]:expired() then
		return self._active_actions[3]
	end
end

function CopMovement:sync_taser_fire()
	local tase_action, is_queued = self:_get_latest_tase_action()

	if is_queued then
		tase_action.firing_at_husk = true
	elseif tase_action then
		tase_action:fire_taser()
	end
end

function CopMovement:sync_action_walk_nav_point(pos, explicit)
	local walk_action, is_queued = self:_get_latest_walk_action(explicit)

	if is_queued then
		walk_action.nav_path[#walk_action.nav_path + 1] = pos
	elseif walk_action then
		walk_action:append_nav_point(pos)
	end
end

function CopMovement:sync_action_walk_nav_link(pos, rot, anim_index, from_idle)
	local nav_link = self._actions.walk.synthesize_nav_link(pos, rot, self._actions.act:_get_act_name_from_index(anim_index), from_idle)
	local walk_action, is_queued = self:_get_latest_walk_action()

	if is_queued then
		function nav_link.element.value(element, name)
			return element[name]
		end

		function nav_link.element.nav_link_wants_align_pos(element)
			return element.from_idle
		end

		walk_action.nav_path[#walk_action.nav_path + 1] = nav_link
	elseif walk_action then
		walk_action:append_nav_point(nav_link)
	end
end

function CopMovement:sync_action_walk_stop(explicit)
	local walk_action, is_queued = self:_get_latest_walk_action()

	if is_queued then
		walk_action.persistent = nil
	elseif walk_action then
		walk_action:stop()
	end
end

function CopMovement:synch_attention(attention)
	self:_remove_attention_destroy_listener(self._attention)
	self:_add_attention_destroy_listener(attention)

	if attention and attention.unit and not attention.destroy_listener_key then
		self:synch_attention(nil)

		return
	end

	local old_attention = self._attention
	self._attention = attention
	self._action_common_data.attention = attention

	for _, action in ipairs(self._active_actions) do
		if action and action.on_attention then
			action:on_attention(attention, old_attention)
		end
	end
end

function CopMovement:clbk_sync_attention(attention)
	if not alive_g(self._unit) then
		return
	end

	if self._attention ~= attention then
		return
	end

	attention = self._attention

	if attention.handler then
		if attention.handler:unit():id() ~= -1 then
			self._ext_network:send("set_attention", attention.handler:unit(), attention.reaction)
		else
			self._ext_network:send("cop_set_attention_pos", mvec3_cpy(attention.handler:get_attention_m_pos()))
		end
	elseif attention.unit then
		if attention.unit:id() ~= -1 then
			self._ext_network:send("set_attention", attention.unit, AIAttentionObject.REACT_IDLE)
		else
			self._ext_network:send("cop_set_attention_pos", mvec3_cpy(attention.handler:get_attention_m_pos()))
		end
	end
end

function CopMovement:get_hold_type(hold_type)
	if not hold_type then
		return
	end

	if type(hold_type) == "table" then
		for _, hold in ipairs(hold_type) do
			if HuskPlayerMovement.reload_times[hold] then
				return hold
			end
		end

		return
	elseif HuskPlayerMovement.reload_times[hold_type] then
		return hold_type
	else
		return
	end
end

function CopMovement:anim_clbk_start_reload_looped()
	local weapon_unit = self._ext_inventory:equipped_unit()

	if not weapon_unit then
		return
	end

	local weap_tweak = weapon_unit:base():weapon_tweak_data()
	local weapon_usage_tweak = self._tweak_data.weapon[weap_tweak.usage]
	local anim_multiplier = weapon_usage_tweak.RELOAD_SPEED or 1
	local hold_type = self:get_hold_type(weap_tweak.hold)

	if weap_tweak.looped_reload_speed then
		anim_multiplier = anim_multiplier * weap_tweak.looped_reload_speed
	end

	local redir_res = self:play_redirect("reload_looped")

	if redir_res then
		self._machine:set_speed(redir_res, anim_multiplier)

		if hold_type then
			self._machine:set_parameter(redir_res, hold_type, 1)
		end
	end
end

function CopMovement:anim_clbk_reload_exit()
	self:anim_clbk_hide_magazine_in_hand()
end

local _equip_item_original = CopMovement._equip_item
function CopMovement:_equip_item(item_type, align_place, droppable)
	if item_type == "needle" then
		align_place = "hand_l"
	end

	_equip_item_original(self, item_type, align_place, droppable)
end

--used by clients
function CopMovement:sync_reload_weapon(empty_reload, reload_speed_multiplier)
	local reload_action = {
		body_part = 3,
		type = "reload",
		idle_reload = empty_reload ~= 0 and empty_reload or nil
	}

	self:action_request(reload_action)
end

--stealth corpse position syncing
function CopMovement:sync_fall_position(pos, rot)
	if self._nr_synced then
		self._nr_synced = self._nr_synced + 1
	else
		self._nr_synced = 1
	end

	self:set_position(pos)
	self:set_rotation(rot)

	if self._nr_synced > 1 then
		local active_actions_1 = self._active_actions[1]

		if active_actions_1 and active_actions_1:type() == "hurt" and active_actions_1._ragdoll_freeze_clbk_id then
			active_actions_1._ragdoll_freeze_clbk_id = nil

			active_actions_1:_freeze_ragdoll()
		end
	end
end

function CopMovement:anim_clbk_spawn_dropped_magazine()
	if not self:allow_dropped_magazines() then
		return
	end

	local equipped_weapon = self._unit:inventory():equipped_unit()

	if alive_g(equipped_weapon) and not equipped_weapon:base()._assembly_complete then
		return
	end

	local ref_unit = nil
	local allow_throw = true

	if not self._magazine_data then
		local w_td_crew = self:_equipped_weapon_crew_tweak_data()

		if not w_td_crew or not w_td_crew.pull_magazine_during_reload then
			return
		end

		self:anim_clbk_show_magazine_in_hand()

		if not self._magazine_data then
			return
		elseif not alive_g(self._magazine_data.unit) then
			self._magazine_data = nil

			return
		end

		local attach_bone = left_hand_str
		local bone_hand = self._unit:get_object(attach_bone)

		if bone_hand then
			mvec3_set(temp_vec1, self._magazine_data.unit:position())
			mvec3_sub(temp_vec1, self._magazine_data.unit:oobb():center())
			mvec3_add(temp_vec1, bone_hand:position())
			self._magazine_data.unit:set_position(temp_vec1)
		end

		ref_unit = self._magazine_data.part_unit
		allow_throw = false
	end

	if self._magazine_data and alive_g(self._magazine_data.unit) then
		ref_unit = ref_unit or self._magazine_data.unit

		self._magazine_data.unit:set_visible(false)

		local pos = ref_unit:position()
		local rot = ref_unit:rotation()
		local dropped_mag = self:_spawn_magazine_unit(self._magazine_data.id, self._magazine_data.name, pos, rot)

		self:_set_unit_bullet_objects_visible(dropped_mag, self._magazine_data.bullets, false)

		local mag_size = self._magazine_data.weapon_data.pull_magazine_during_reload

		if type(mag_size) ~= "string" then
			mag_size = "medium"
		end

		mvec3_set(temp_vec1, ref_unit:oobb():center())
		mvec3_sub(temp_vec1, pos)
		mvec3_set(temp_vec2, pos)
		mvec3_add(temp_vec2, temp_vec1)

		local dropped_col = world_g:spawn_unit(CopMovement.magazine_collisions[mag_size][1], temp_vec2, rot)

		dropped_col:link(CopMovement.magazine_collisions[mag_size][2], dropped_mag)

		if allow_throw then
			if self._left_hand_direction then
				local throw_force = 10

				mvec3_set(temp_vec1, self._left_hand_direction)
				mvec3_mul(temp_vec1, self._left_hand_velocity or 3)
				mvec3_mul(temp_vec1, math_random(25, 45))
				mvec3_mul(temp_vec1, -1)
				dropped_col:push(throw_force, temp_vec1)
			end
		else
			local throw_force = 10
			local reload_speed_multiplier = 1
			local w_td_crew = self:_equipped_weapon_crew_tweak_data()

			if w_td_crew then
				local weapon_usage_tweak = self._tweak_data.weapon[w_td_crew.usage]
				reload_speed_multiplier = weapon_usage_tweak.RELOAD_SPEED or 1
			end

			local _t = reload_speed_multiplier - 1

			mvec3_set(temp_vec1, equipped_weapon:rotation():z())
			mvec3_mul(temp_vec1, math_lerp(math_random(65, 80), math_random(140, 160), _t))
			mvec3_mul(temp_vec1, math_random() < 0.0005 and 10 or -1)
			dropped_col:push(throw_force, temp_vec1)
		end

		managers.enemy:add_magazine(dropped_mag, dropped_col)
	end
end

function CopMovement:carrying_bag()
	return self._carry_unit and true or false
end

function CopMovement:set_carrying_bag(unit)
	self._carry_unit = unit or nil

	self:set_carry_speed_modifier()
end

function CopMovement:carry_id()
	return self._carry_unit and self._carry_unit:carry_data():carry_id()
end

function CopMovement:carry_data()
	return self._carry_unit and self._carry_unit:carry_data()
end

function CopMovement:carry_tweak()
	return self:carry_id() and tweak_data.carry.types[tweak_data.carry[self:carry_id()].type]
end

function CopMovement:throw_bag(target_unit, reason)
	if not self:carrying_bag() then
		return
	end

	local carry_unit = self._carry_unit
	self._was_carrying = {
		unit = carry_unit,
		reason = reason
	}

	carry_unit:carry_data():unlink()

	if Network:is_server() then
		self:sync_throw_bag(carry_unit, target_unit)
		managers.network:session():send_to_peers_synched("sync_ai_throw_bag", self._unit, carry_unit, target_unit)
	end
end

function CopMovement:was_carrying_bag()
	return self._was_carrying
end

function CopMovement:sync_throw_bag(carry_unit, target_unit)
	if not alive_g(target_unit) then
		return
	end

	local dynamic_bodies = {}
	local nr_bodies = carry_unit:num_bodies()

	for i = 0, nr_bodies - 1 do
		local body = carry_unit:body(i)

		if body:dynamic() then
			body:set_keyframed()

			dynamic_bodies[#dynamic_bodies + 1] = body
		end
	end

	call_on_next_update_g(function ()
		if not alive_g(carry_unit) or not alive_g(target_unit) or not alive_g(self._unit) then
			return
		end

		local spine_pos = Vector3()
		self._obj_spine:m_position(spine_pos)

		local target_pos = tmp_vec1
		local carry_rot = tmp_rot_1
		mvec3_set(target_pos, target_unit:movement():m_head_pos())

		local dir = target_pos - spine_pos
		mrot_lookat(carry_rot, dir, math_up)

		local set_z = dir:length() * 0.75
		target_pos = target_pos:with_z(target_pos.z + set_z)
		dir = target_pos - spine_pos

		carry_unit:set_position(spine_pos)
		carry_unit:set_velocity(zero_vel_vec)
		carry_unit:set_rotation(carry_rot)

		call_on_next_update_g(function ()
			if not alive_g(carry_unit) or not alive_g(target_unit) or not alive_g(self._unit) then
				return
			end

			for i = 1, #dynamic_bodies do
				local body = dynamic_bodies[i]

				body:set_dynamic()
			end

			call_on_next_update_g(function ()
				if not alive_g(carry_unit) or not alive_g(target_unit) or not alive_g(self._unit) then
					return
				end

				local throw_distance_multiplier = tweak_data.carry.types[tweak_data.carry[carry_unit:carry_data():carry_id()].type].throw_distance_multiplier

				carry_unit:push(tweak_data.ai_carry.throw_force, dir * throw_distance_multiplier)
			end)
		end)
	end)
end

function CopMovement:set_carry_speed_modifier()
	local tweak = self:carry_tweak()

	if tweak then
		local speed_mod = tweak.move_speed_modifier

		if speed_mod and speed_mod < 1 then
			self._carry_speed_modifier = speed_mod

			return
		end
	end

	self._carry_speed_modifier = nil
end

function CopMovement:set_hostage_speed_modifier(enable)
	if enable then
		local char_tweak_mul = self._tweak_data.hostage_move_speed or 1
		local hostage_mul = char_tweak_mul + managers.player:team_upgrade_value("player", "civilian_hostage_speed_bonus", 1) - 1

		if hostage_mul ~= 1 then
			self._hostage_speed_modifier = hostage_mul

			return
		end
	end

	self._hostage_speed_modifier = nil
end

function CopMovement:speed_modifier()
	local final_modifier = 1
	local carry_modifier = self._carry_speed_modifier

	if carry_modifier then
		final_modifier = final_modifier * carry_modifier
	end

	local hostage_modifier = self._hostage_speed_modifier

	if hostage_modifier then
		final_modifier = final_modifier * hostage_modifier
	end

	return final_modifier
end

local original_save = CopMovement.save
function CopMovement:save(save_data)
	original_save(self, save_data)

	save_data.movement.has_bag = self:carrying_bag()
end

local original_load = CopMovement.load
function CopMovement:load(load_data)
	original_load(self, load_data)

	local mov_load_data = load_data.movement

	if not mov_load_data or not mov_load_data.has_bag or not Network:is_client() then
		return
	end

	managers.network:session():send_to_host("request_carried_bag_unit", self._unit)
end

function CopMovement:outside_worlds_bounding_box()
	local my_unit = self._unit

	if Network:is_server() or my_unit:id() == -1 then
		my_unit:base():set_slot(my_unit, 0)
	end
end

function CopMovement:joker_counter_on_cooldown()
	return self._joker_ccd_clbk_id and true
end

function CopMovement:set_joker_cooldown(state, was_delayed_clbk)
	if state then
		if self._joker_ccd_clbk_id then
			return
		end
	elseif not self._joker_ccd_clbk_id then
		return
	end

	if state then
		local function f()
			self:set_joker_cooldown(false, true)
		end

		local joker_ccd_clbk_id = "remove_counter_cooldown" .. tostring_g(self._unit:key())
		self._joker_ccd_clbk_id = joker_ccd_clbk_id

		managers.enemy:add_delayed_clbk(joker_ccd_clbk_id, f, TimerManager:game():time() + 30)
	elseif was_delayed_clbk then
		self._joker_ccd_clbk_id = nil
	else
		local joker_ccd_clbk_id = self._joker_ccd_clbk_id

		if joker_ccd_clbk_id then
			managers.enemy:remove_delayed_clbk(joker_ccd_clbk_id)

			self._joker_ccd_clbk_id = nil
		end
	end
end
