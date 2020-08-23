local mvec3_set = mvector3.set
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_cpy = mvector3.copy

local temp_vec1 = Vector3()
local temp_vec2 = Vector3()

local math_abs = math.abs
local math_min = math.min
local math_max = math.max
local math_random = math.random
local math_UP = math.UP

local table_insert = table.insert
local table_remove = table.remove

local ids_movement = Idstring("movement")

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
		else
			self:synch_attention()
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
		else
			self:synch_attention()
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

	if damage_info.variant == "tase" and hurt_type ~= "death" then
		block_type = "bleedout"
	elseif hurt_type == "expl_hurt" or hurt_type == "fire_hurt" or hurt_type == "poison_hurt" or hurt_type == "taser_tased" then
		block_type = "heavy_hurt"

		if Network:is_client() then
			client_interrupt = true
		end
	else
		if hurt_type ~= "bleedout" and hurt_type ~= "fatal" and Network:is_client() then
			client_interrupt = true
		end

		block_type = hurt_type
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
	if alive(self._melee_item_unit) then
		return
	end

	local melee_weapon = self._unit:base().melee_weapon and self._unit:base():melee_weapon()
	local unit_name = melee_weapon and melee_weapon ~= "weapon" and tweak_data.weapon.npc_melee[melee_weapon] and tweak_data.weapon.npc_melee[melee_weapon].unit_name or nil

	if unit_name then
		local align_obj_l_name = CopMovement._gadgets.aligns.hand_l
		local align_obj_l = self._unit:get_object(align_obj_l_name)

		self._melee_item_unit = World:spawn_unit(unit_name, align_obj_l:position(), align_obj_l:rotation())
		self._unit:link(align_obj_l:name(), self._melee_item_unit, self._melee_item_unit:orientation_object():name())
	end
end

function CopMovement:_upd_actions(t)
	local a_actions = self._active_actions
	local has_no_action = true

	for i_action, action in ipairs(a_actions) do
		if action then
			if action.update then
				action:update(t)
			end

			if not self._need_upd and action.need_upd then
				self._need_upd = action:need_upd()
			end

			if action.expired and action:expired() then
				a_actions[i_action] = false

				if action.on_exit then
					action:on_exit()
				end

				self._ext_brain:action_complete_clbk(action)
				self._ext_base:chk_freeze_anims()

				for _, action in ipairs(a_actions) do
					if action then
						has_no_action = nil

						break
					end
				end
			else
				has_no_action = nil
			end
		end
	end

	if has_no_action then
		if not self._queued_actions or not next(self._queued_actions) then
			self:action_request({
				body_part = 1,
				type = "idle"
			})
		end
	end

	if not a_actions[1] then
		if not self._queued_actions or not next(self._queued_actions) then
			if not a_actions[2] then
				if not a_actions[3] or a_actions[3]:type() == "idle" then
					if not self:chk_action_forbidden("action") then
						self:action_request({
							body_part = 1,
							type = "idle"
						})
					end
				elseif not self:chk_action_forbidden("action") then
					self:action_request({
						body_part = 2,
						type = "idle"
					})
				end
			elseif a_actions[2]:type() == "idle" then
				if not a_actions[3] or a_actions[3]:type() == "idle" then
					if not self:chk_action_forbidden("action") then
						self:action_request({
							body_part = 1,
							type = "idle"
						})
					end
				end
			elseif not a_actions[3] and not self:chk_action_forbidden("action") then --or a_actions[3]:type() == "shoot" and self:stance_name() ~= "cbt" then
				self:action_request({
					body_part = 3,
					type = "idle"
				})
			end
		end
	end

	self:_upd_stance(t)

	if not self._need_upd then
		if self._ext_anim.base_need_upd or self._ext_anim.upper_need_upd or self._ext_anim.fumble or self._stance.transition or self._suppression.transition then
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
			idle = -1
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
		if spooc_action.stop_pos and not spooc_action.nr_expected_nav_points then
			return
		end

		table_insert(spooc_action.nav_path, pos)

		if spooc_action.nr_expected_nav_points then
			if spooc_action.nr_expected_nav_points == 1 then
				spooc_action.nr_expected_nav_points = nil

				table_insert(spooc_action.nav_path, spooc_action.stop_pos)
			else
				spooc_action.nr_expected_nav_points = spooc_action.nr_expected_nav_points - 1
			end
		end
	elseif spooc_action then
		spooc_action:sync_append_nav_point(pos)
	end
end

function CopMovement:sync_action_spooc_stop(pos, nav_index, action_id)
	local spooc_action, is_queued = self:_get_latest_spooc_action(action_id)

	if is_queued then
		spooc_action.host_expired = true

		if spooc_action.host_stop_pos_inserted then
			nav_index = nav_index + spooc_action.host_stop_pos_inserted
		end

		local nav_path = spooc_action.nav_path

		while nav_index < #nav_path do
			table_remove(nav_path)
		end

		spooc_action.stop_pos = pos

		if #nav_path < nav_index - 1 then
			spooc_action.nr_expected_nav_points = nav_index - #nav_path + 1
		else
			table_insert(nav_path, pos)

			spooc_action.path_index = math_max(1, math_min(spooc_action.path_index, #nav_path - 1))
		end
	elseif spooc_action then
		spooc_action:sync_stop(pos, nav_index)
	end
end

function CopMovement:sync_action_spooc_strike(pos, action_id)
	local spooc_action, is_queued = self:_get_latest_spooc_action(action_id)

	if is_queued then
		if spooc_action.stop_pos and not spooc_action.nr_expected_nav_points then
			return
		end

		table_insert(spooc_action.nav_path, pos)

		spooc_action.strike_nav_index = #spooc_action.nav_path
		spooc_action.strike = true
	elseif spooc_action then
		spooc_action:sync_strike(pos)
	end
end

function CopMovement:_get_latest_act_action()
	if self._queued_actions then
		for i = #self._queued_actions, 1, -1 do
			if self._queued_actions[i].type == "act" and not self._queued_actions[i].host_expired then
				return i, self._queued_actions[i], true
			end
		end
	end

	for body_part, action in ipairs(self._active_actions) do
		if action and action:type() == "act" then
			return body_part, self._active_actions[body_part]
		end
	end
end

function CopMovement:sync_action_act_end()
	local body_part, act_action, queued = self:_get_latest_act_action()

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
