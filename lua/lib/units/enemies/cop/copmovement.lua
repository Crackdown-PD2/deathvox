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
Hooks:PreHook(CopMovement,"init","cd_copmovement_init",(self,unit,...)
	local security_variant = action_variants.security

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
end)

Hooks:PostHook(CopMovement,"post_init","cd_copmovement_postinit",function(self)
	self._unit:unit_data().ignore_ecm_for_pager = self._tweak_data.ignore_ecm_for_pager
end)

local difficulty_skins = {
	cop = "nil-mint-0",
	fbi = "m16_cs4-mint-0",
	gensec = "contraband_css-mint-0",
	zeal = "l85a2_cs4-mint-0",
	murky = "new_m4_skf-mint-0",
	classic = "amcar_same-mint-0"
}

-- npc weapon skins
function CopMovement:add_weapons()
	if self._tweak_data.use_factory then
		local weapon_to_use = self._tweak_data.factory_weapon_id[math_random(#self._tweak_data.factory_weapon_id)]
		local faction = tweak_data.levels:get_ai_group_type()
		local weapon_cosmetic = difficulty_skins[faction]
		if weapon_to_use then
			if weapon_cosmetic then
				self._ext_inventory:add_unit_by_factory_name(weapon_to_use, false, false, nil, weapon_cosmetic)
			else
				self._ext_inventory:add_unit_by_factory_name(weapon_to_use, false, false, nil, "")
			end
		end
	else
		local prim_weap_name = self._ext_base:default_weapon_name("primary")
		local sec_weap_name = self._ext_base:default_weapon_name("secondary")

		if prim_weap_name then
			self._ext_inventory:add_unit_by_name(prim_weap_name)
		end

		if sec_weap_name and sec_weap_name ~= prim_weap_name then
			self._ext_inventory:add_unit_by_name(sec_weap_name)
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
function CopMovement:pre_destroy(...)
	pre_destroy_original(self, ...)

	if Network:is_server() then
		self:throw_bag()
		self:set_joker_cooldown(false)
	end

	self.update = self._upd_empty
end

function CopMovement:_upd_empty()
	self._gnd_ray = nil

	unit:set_extension_update_enabled(ids_movement, false)
end

function CopMovement:sync_action_dodge_start(body_part, var, side, rot, speed, shoot_acc)
	if self._ext_damage:dead() then
		return
	end

	local var_name = CopActionDodge.get_variation_name(var)
	local action_data = {
		type = "dodge",
		body_part = body_part,
		variation = var_name,
		direction = Rotation(rot):y(),
		side = CopActionDodge.get_side_name(side),
		speed = speed,
		shoot_accuracy = shoot_acc / 10, -- this is the only change
		blocks = {
			act = -1,
			idle = -1,
			turn = -1,
			tase = -1,
			dodge = -1,
			walk = -1
		}
	}

	if body_part == 1 then
		action_data.blocks.aim = -1
		action_data.blocks.action = -1
	end

	if var_name ~= "side_step" then
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

function CopMovement:sync_action_act_end(body_part)
	local act_action, queued = self:_get_latest_act_action(body_part)

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
				mvec3_norm(self._left_hand_direction)

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

function CopMovement:outside_worlds_bounding_box()
	local my_unit = self._unit

	if Network:is_server() or my_unit:id() == -1 then
		my_unit:base():set_slot(my_unit, 0)
	end
end

function CopMovement:joker_counter_on_cooldown()
	return self._joker_ccd_clbk_id and true
end

function CopMovement:set_joker_cooldown(time_amount, was_delayed_clbk)
	if time_amount then
		if self._joker_ccd_clbk_id then
			return
		end
	elseif not self._joker_ccd_clbk_id then
		return
	end

	if time_amount then
		local function f()
			self:set_joker_cooldown(false, true)
		end

		local joker_ccd_clbk_id = "remove_counter_cooldown" .. tostring_g(self._unit:key())
		self._joker_ccd_clbk_id = joker_ccd_clbk_id

		managers.enemy:add_delayed_clbk(joker_ccd_clbk_id, f, TimerManager:game():time() + time_amount)
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
