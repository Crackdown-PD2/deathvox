local old_init = CopMovement.init
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
	
	self.fs_blockers_nr = 0
	self.fs_keep_groundray = 0
	self.fs_fake_ray_position = Vector3()
	self.fs_m_stand_pos = self._m_stand_pos
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
		Application:error("[CopMovement:post_init] Spawned AI unit with incomplete navigation data.")
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
		"concussion"
	}
	table.insert(event_list, "healed")
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
	local weap_name = self._ext_base:default_weapon_name(managers.groupai:state():enemy_weapons_hot() and "primary" or "secondary")
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
		look_vec = mvector3.copy(fwd)
	}
	self:upd_ground_ray()
	if self._gnd_ray then
		self:set_position(self._gnd_ray.position)
	end
	self:_post_init()
end
difficulty_skins = {
	cop = "nil-mint-0",
	fbi = "m16_cs4-mint-0",
	gensec = "m249_grunt-mint-0",
	zeal = "l85a2_cs4-mint-0",
	murky = "new_m4_skf-mint-0",
	classic = "amcar_same-mint-0"
}

function CopMovement:add_weapons()
	if self._tweak_data.use_factory then
		local weapon_to_use = self._tweak_data.factory_weapon_id[ math.random( #self._tweak_data.factory_weapon_id ) ]
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

	if damage_info.variant == "explosion" or damage_info.variant == "bullet" or damage_info.variant == "fire" or damage_info.variant == "poison" then
		hurt_type = managers.modifiers:modify_value("CopMovement:HurtType", hurt_type)
	end

	if hurt_type == "knock_down" and self._tweak_data.damage.shield_knocked and alive(self._ext_inventory and self._ext_inventory._shield_unit) then
		hurt_type = "shield_knock"
		block_type = "shield_knock"
		damage_info.variant = "melee"
		damage_info.result = {
			variant = "melee",
			type = "shield_knock"
		}
		damage_info.shield_knock = true
	end

	if hurt_type == "stagger" then
		hurt_type = "heavy_hurt"
	end

	local block_type = hurt_type

	if damage_info.variant == "taser_tased" then
		if (self._tweak_data.can_be_tased or self._tweak_data.can_be_tased == nil) then
			if damage_info.variant == "stun" and alive(self._ext_inventory and self._ext_inventory._shield_unit) then
				hurt_type = "shield_knock"
				block_type = "shield_knock"
				damage_info.variant = "melee"
				damage_info.result = {
					variant = "melee",
					type = "shield_knock"
				}
				damage_info.shield_knock = true
			end
		elseif not self._tweak_data.can_be_tased and hurt_type == "death" then
			hurt_type = "death"
		elseif not self._tweak_data.can_be_tased then
			if damage_info.variant == "stun" and alive(self._ext_inventory and self._ext_inventory._shield_unit) then
				hurt_type = "shield_knock"
				block_type = "shield_knock"
				damage_info.variant = "melee"
				damage_info.result = {
					variant = "melee",
					type = "shield_knock"
				}
				damage_info.shield_knock = true
			else
				hurt_type = nil
			end
		end
	end

	if hurt_type == "knock_down" or hurt_type == "expl_hurt" or hurt_type == "fire_hurt" or hurt_type == "poison_hurt" or hurt_type == "taser_tased" then
		block_type = "heavy_hurt"
	end

	if hurt_type == "expl_hurt" and self._unit:base():has_tag("tank") then
		hurt_type = nil
	end

	if hurt_type == "death" and self._queued_actions then
		self._queued_actions = {}
	end

	if not hurt_type or Network:is_server() and self:chk_action_forbidden(block_type) then
		if hurt_type == "death" then
			debug_pause_unit(self._unit, "[CopMovement:damage_clbk] Death action skipped!!!", self._unit)
			Application:draw_cylinder(self._m_pos, self._m_pos + math.UP * 5000, 30, 1, 0, 0)

			for body_part, action in ipairs(self._active_actions) do
				if action then
					print(body_part, action:type(), inspect(action._blocks))
				end
			end
		end

		return
	end

	if damage_info.variant == "stun" and alive(self._ext_inventory and self._ext_inventory._shield_unit) then
		hurt_type = "shield_knock"
		block_type = "shield_knock"
		damage_info.variant = "melee"
		damage_info.result = {
			variant = "melee",
			type = "shield_knock"
		}
		damage_info.shield_knock = true
	end

	if hurt_type == ("heavy_hurt" or "stagger") and alive(self._ext_inventory and self._ext_inventory._shield_unit) then
		hurt_type = "shield_knock"
		block_type = "shield_knock"
		damage_info.variant = "melee"
		damage_info.result = {
			variant = "melee",
			type = "shield_knock"
		}
		damage_info.shield_knock = true
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

		if hurt_type == "shield_knock" then
			blocks.light_hurt = -1
			blocks.concussion = -1
		end

		if hurt_type == "concussion" or hurt_type == "counter_tased" then
			blocks.hurt = -1
			blocks.light_hurt = -1
			blocks.heavy_hurt = -1
			blocks.stagger = -1
			blocks.knock_down = -1
			blocks.counter_tased = -1
			blocks.hurt_sick = -1
			blocks.expl_hurt = -1
			blocks.counter_spooc = -1
			blocks.fire_hurt = -1
			blocks.taser_tased = -1
			blocks.poison_hurt = -1
			blocks.shield_knock = -1
			blocks.concussion = -1
		end
	end

	block_type = damage_info.variant == "tase" and "bleedout" or (hurt_type == "expl_hurt" or hurt_type == "fire_hurt" or hurt_type == "poison_hurt" or hurt_type == "taser_tased") and "heavy_hurt" or hurt_type
	local client_interrupt = nil

	if Network:is_client() and (hurt_type == "light_hurt" or hurt_type == "hurt" and damage_info.variant ~= "tase" or hurt_type == "heavy_hurt" or hurt_type == "expl_hurt" or hurt_type == "shield_knock" or hurt_type == "counter_tased" or hurt_type == "taser_tased" or hurt_type == "counter_spooc" or hurt_type == "death" or hurt_type == "hurt_sick" or hurt_type == "fire_hurt" or hurt_type == "poison_hurt" or hurt_type == "concussion") then
		client_interrupt = true
	end

	local tweak = self._tweak_data
	local action_data = nil

	if hurt_type == "healed" then
		if Network:is_client() then
			client_interrupt = true
		end

		action_data = {
			body_part = 3,
			type = "healed",
			client_interrupt = client_interrupt
		}
	else
		action_data = {
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
			death_type = tweak.damage.death_severity and (tweak.damage.death_severity < damage_info.damage / tweak.HEALTH_INIT and "heavy" or "normal") or "normal",
			ignite_character = damage_info.ignite_character,
			start_dot_damage_roll = damage_info.start_dot_damage_roll,
			is_fire_dot_damage = damage_info.is_fire_dot_damage,
			fire_dot_data = damage_info.fire_dot_data
		}
	end

	local request_action = Network:is_server() or not self:chk_action_forbidden(action_data)

	if damage_info.is_synced and (hurt_type == "knock_down" or hurt_type == "heavy_hurt") then
		request_action = false
	end

	if request_action then
		self:action_request(action_data)

		if hurt_type == "death" and self._queued_actions then
			self._queued_actions = {}
		end
	end
end

CopMovement.move_speed_multiplier = 1

local fs_original_copmovement_chkactionforbidden = CopMovement.chk_action_forbidden
function CopMovement:chk_action_forbidden(action_type)
	return self.fs_blockers_nr > 0 and fs_original_copmovement_chkactionforbidden(self, action_type)
end

local fs_original_copmovement_actionrequest = CopMovement.action_request
function CopMovement:action_request(action_desc)
	local action = fs_original_copmovement_actionrequest(self, action_desc)
	if action and action.chk_block then
		self.fs_blockers_nr = self.fs_blockers_nr + 1
	end
	return action
end

local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_z = mvector3.z
local mvec3_mul = mvector3.multiply
local mvec3_add = mvector3.add
local mvec3_sub = mvector3.subtract
local mvec3_norm = mvector3.normalize
local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
local temp_vec3 = Vector3()
local math_down = math.DOWN
local math_abs = math.abs
local math_lerp = math.lerp
local math_min = math.min

local _qf
DelayedCalls:Add('DelayedModFSS_quadfield', 0, function()
	_qf = managers.navigation._quad_field
end)

local _units_per_navseg = FullSpeedSwarm.units_per_navseg
function CopMovement:set_position(pos)
	mvec3_set(self._m_pos, pos)
	self._m_stand_pos = nil

	self._obj_head:m_position(self._m_head_pos)
	self._obj_spine:m_position(self._m_com)
	self._nav_tracker:move(pos)
	self._unit:set_position(pos)

	if self.fs_do_track then
		local new_seg = _qf:find_nav_segment(pos, true)
		local old_seg = self._cur_seg
		if new_seg ~= old_seg then
			local u_key = self._unit:key()
			if old_seg then
				_units_per_navseg[old_seg][u_key] = nil
			end
			local new_list = _units_per_navseg[new_seg]
			if not new_list then
				new_list = {}
				_units_per_navseg[new_seg] = new_list
			end
			new_list[u_key] = self.fs_do_track
		end
		self._cur_seg = new_seg
	end
end

function CopMovement:set_m_pos(pos)
	mvec3_set(self._m_pos, pos)
	self._m_stand_pos = nil
	self._obj_head:m_position(self._m_head_pos)
	self._nav_tracker:move(pos)
	self._obj_spine:m_position(self._m_com)
end

local vec_stand = Vector3(0, 0, 160)
function CopMovement:m_stand_pos()
	local pos = self._m_stand_pos
	if not pos then
		pos = self.fs_m_stand_pos
		mvec3_set(pos, self._m_pos)
		mvec3_add(pos, vec_stand)
		self._m_stand_pos = pos
	end
	return pos
end

function CopMovement:upd_ground_ray(from_pos)
	local fake_ray
	if self.fs_keep_groundray > 0 then
		fake_ray = self._old_gnd_ray
		self.fs_keep_groundray = self.fs_keep_groundray - 1
	else
		local hit_ray
		local safe_pos = temp_vec1
		local new_pos = from_pos or self._m_pos
		local ground_z = self._nav_tracker:field_z()
		local fake_ray_pos = self.fs_fake_ray_position
		mvec3_set(temp_vec1, new_pos)
		mvec3_set_z(temp_vec1, ground_z + 171)
		mvec3_set(temp_vec2, safe_pos)
		mvec3_set_z(temp_vec2, ground_z - 140)
		local gnd_ray = World:raycast('ray', temp_vec1, temp_vec2, 'slot_mask', self._slotmask_gnd_ray, 'ray_type', 'walk')
		if gnd_ray then
			local hit_pos = gnd_ray.position
			local hit_pos_z = mvec3_z(hit_pos)
			local no_keep
			local new_pos_z = mvec3_z(new_pos)
			if hit_pos_z - new_pos_z > 100 then
				mvec3_set_z(temp_vec1, ground_z + 100)
				gnd_ray = World:raycast('ray', temp_vec1, temp_vec2, 'slot_mask', self._slotmask_gnd_ray, 'ray_type', 'walk') or gnd_ray
				hit_pos = gnd_ray.position
				hit_pos_z = mvec3_z(hit_pos)
				if hit_pos_z - new_pos_z > 99 then
					no_keep = true
				end
			end

			if no_keep then
				self.fs_keep_groundray = 0
				ground_z = fake_ray_pos and fake_ray_pos.z or ground_z
			else
				local d = math_abs(ground_z - hit_pos_z)
				self.fs_keep_groundray = 4 - (d / 2.5)
				ground_z = hit_pos_z
			end
			hit_ray = gnd_ray
		else
			self.fs_keep_groundray = 4
		end
		mvec3_set(fake_ray_pos, new_pos)
		mvec3_set_z(fake_ray_pos, ground_z)
		fake_ray = {
			position = fake_ray_pos,
			ray = math_down,
			unit = hit_ray and hit_ray.unit
		}
		self._old_gnd_ray = fake_ray
	end
	self._action_common_data.gnd_ray = fake_ray
	self._gnd_ray = fake_ray
end

if Network:is_server() then
	function CopMovement:fs_update_pre_destroyed()
		self._gnd_ray = nil
	end

	local fs_original_copmovement_predestroy = CopMovement.pre_destroy
	function CopMovement:pre_destroy()
		self._gnd_ray = nil
		self.update = CopMovement.fs_update_pre_destroyed
		fs_original_copmovement_predestroy(self)
	end

	local ids_movement = Idstring('movement')
	function CopMovement:update(unit, t, dt)
		self._gnd_ray = nil
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

	local idle_1 = {type = 'idle', body_part = 1}
	local idle_2 = {type = 'idle', body_part = 2}
	function CopMovement:_upd_actions(t)
		local a_actions = self._active_actions
		local has_no_action = true
		for i_action = 1, 4 do
			local action = a_actions[i_action]
			if action then
				local action_update = action.update
				if action_update then
					action_update(action, t)
				end
				if not self._need_upd then
					local action_need_upd = action.need_upd
					if action_need_upd then
						self._need_upd = action_need_upd(action)
					end
				end
				local action_expired = action.expired
				if action_expired and action_expired(action) then
					a_actions[i_action] = false
					local action_on_exit = action.on_exit
					if action_on_exit then
						action_on_exit(action)
					end
					self._ext_brain:action_complete_clbk(action)
					self._ext_base:chk_freeze_anims()
					for i = 1, 4 do
						has_no_action = has_no_action and a_actions[i]
					end
				else
					has_no_action = nil
				end
			end
		end
		if has_no_action then
			self:action_request(idle_1)
		elseif not a_actions[1] and not a_actions[2] and not self:chk_action_forbidden('action') then
			self:action_request(a_actions[3] and idle_2 or idle_1)
		end
		self:_upd_stance(t)
		if not self._need_upd then
			local ext_anim = self._ext_anim
			if ext_anim.base_need_upd or ext_anim.upper_need_upd or self._stance.transition or self._action_common_data.is_suppressed or self._suppression.transition then
				self._need_upd = true
			end
		end
	end

	local fs_original_copmovement_onsuppressed = CopMovement.on_suppressed
	function CopMovement:on_suppressed(state)
		fs_original_copmovement_onsuppressed(self, state)

		if not state and self._ext_anim.act and self._ext_anim.fumble then
			self:action_request({type = 'idle', body_part = 1})
		end
	end
end
