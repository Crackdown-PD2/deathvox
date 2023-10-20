ECMJammerBase._NET_EVENTS.feedback_stop_and_recharge = 8

local TCD_ENABLED = deathvox:IsTotalCrackdownEnabled()
				
local mvec3_cpy = mvector3.copy

local math_random = math.random
local math_lerp = math.lerp

local tostring_g = tostring

local alive_g = alive
local world_g = World

local ids_base = Idstring("base")

local init_original = ECMJammerBase.init
function ECMJammerBase:init(...)
	init_original(self, ...)

	self._is_server = Network:is_server()
	self._unit:set_extension_update_enabled(ids_base, false)
end

local sync_net_event_original = ECMJammerBase.sync_net_event
function ECMJammerBase:sync_net_event(event_id)
	local net_events = self._NET_EVENTS

	if event_id == net_events.feedback_flash then
		self:_set_feedback_battery_low()

		return
	elseif event_id == net_events.feedback_restart then
		local my_unit = self._unit

		my_unit:contour():remove("deployable_disabled")
		my_unit:sound_source():post_event("ecm_jammer_ready")
		my_unit:interaction():set_active(true)

		return
	elseif event_id == net_events.feedback_stop_and_recharge then
		self:_set_feedback_active(false)

		if self._jammer_active then
			self._add_disabled_contour_on_jammer_end = true
		else
			self._unit:contour():add("deployable_disabled")
		end

		return
	end

	sync_net_event_original(self, event_id)
end

local setup_original = ECMJammerBase.setup
function ECMJammerBase:setup(...)
	setup_original(self, ...)

	if not self._is_server then
		return
	end

	local t = TimerManager:game():time()
	local key_str = tostring_g(self._unit:key())

	local battery_low_clbk_id = "battery_low" .. key_str
	local battery_empty_clbk_id = "battery_empty" .. key_str
	self._battery_low_clbk_id = battery_low_clbk_id
	self._battery_empty_clbk_id = battery_empty_clbk_id

	local battery_life = self._battery_life
	local low_battery_life = battery_life - self._low_battery_life

	managers.enemy:add_delayed_clbk(battery_low_clbk_id, callback(self, self, "set_battery_low"), t + low_battery_life)
	managers.enemy:add_delayed_clbk(battery_empty_clbk_id, callback(self, self, "set_battery_empty"), t + battery_life)

	self:contour_interaction()
end

local sync_setup_original = ECMJammerBase.sync_setup
function ECMJammerBase:sync_setup(upgrade_lvl, peer_id)
	sync_setup_original(self, upgrade_lvl, peer_id)

	if not peer_id then
		return
	end

	self._owner_id = peer_id

	local peer = managers.network:session():peer(peer_id)

	self._owner = peer and peer:unit()

	self:contour_interaction()
end

local link_attachment_original = ECMJammerBase.link_attachment
function ECMJammerBase:link_attachment(body, ...)
	link_attachment_original(self, body, ...)

	if not self._is_server then
		return
	end

	local my_unit = self._unit
	local attach_unit = body:unit()
	local disabled_clbk = callback(self, self, "_clbk_attached_body_disabled")

	self._attached_data = {
		body = body,
		unit = attach_unit,
		disabled_clbk = disabled_clbk
	}

	attach_unit:add_body_enabled_callback(disabled_clbk)

	local has_destroy_listener = nil
	local listener_class = attach_unit:base()

	if listener_class and listener_class.add_destroy_listener then
		local listener_key = "ECMJammerBase" .. tostring_g(my_unit:key())
		self._attached_data.destroy_listener_key = listener_key

		listener_class:add_destroy_listener(listener_key, callback(self, self, "_clbk_attached_body_destroyed"))

		has_destroy_listener = true
	else
		listener_class = attach_unit:unit_data()

		if listener_class and listener_class.add_destroy_listener then
			local listener_key = "ECMJammerBase" .. tostring_g(my_unit:key())
			self._attached_data.destroy_listener_key = listener_key

			listener_class:add_destroy_listener(listener_key, callback(self, self, "_clbk_attached_body_destroyed"))

			has_destroy_listener = true
		end
	end

	if has_destroy_listener then
		return
	end

	local body_alive_chk_id = "ECMJammerBase._body_alive_chk" .. tostring_g(my_unit:key())
	self._body_alive_chk_id = body_alive_chk_id

	managers.enemy:add_delayed_clbk(body_alive_chk_id, callback(self, self, "_clbk_body_alive_chk"), Application:time() + 0.5)
end

function ECMJammerBase:_clbk_body_alive_chk(unit)
	if not alive_g(self._attached_data.body) then
		self._body_alive_chk_id = nil

		self:_remove_attached_body_callbacks()
		self:_force_remove()

		return
	end

	managers.enemy:add_delayed_clbk(self._body_alive_chk_id, callback(self, self, "_clbk_body_alive_chk"), Application:time() + 0.5)
end

function ECMJammerBase:_clbk_attached_body_destroyed(unit)
	self:_remove_attached_body_callbacks()
	self:_force_remove()
end

function ECMJammerBase:_clbk_attached_body_disabled(unit, body)
	local data = self._attached_data

	if data.body:key() ~= body:key() then
		return
	end

	if not body:enabled() then
		self:_remove_attached_body_callbacks()
		self:_force_remove()
	end
end

function ECMJammerBase:_remove_attached_body_callbacks()
	local data = self._attached_data

	if data then
		local attached_unit = data.unit

		if alive_g(attached_unit) then
			local destroy_key = data.destroy_listener_key

			if destroy_key then
				local listener_class = attached_unit:base()

				if listener_class and listener_class.add_destroy_listener then
					listener_class:remove_destroy_listener(destroy_key)
				else
					listener_class = attached_unit:unit_data()

					if listener_class and listener_class.add_destroy_listener then
						listener_class:remove_destroy_listener(destroy_key)
					end
				end
			end

			attached_unit:remove_body_enabled_callback(data.disabled_clbk)
		end
	end

	local body_alive_chk_id = self._body_alive_chk_id

	if body_alive_chk_id then
		managers.enemy:remove_delayed_clbk(body_alive_chk_id)

		self._body_alive_chk_id = nil
	end

	self._attached_data = nil
end

function ECMJammerBase:set_active(active)
	active = active and true

	if self._jammer_active == active then
		return
	end

	local my_unit = self._unit

	if self._is_server then
		if active then
			self._alert_filter = self:owner():movement():SO_access()
			local jam_cameras, jam_pagers = nil

			if self._owner_id == 1 then
				local pl_manager = managers.player

				jam_cameras = pl_manager:has_category_upgrade("ecm_jammer", "affects_cameras")
				jam_pagers = pl_manager:has_category_upgrade("ecm_jammer", "affects_pagers")

				self._can_retrigger = pl_manager:has_category_upgrade("ecm_jammer", "can_retrigger")
			else
				local owner_base = self:owner():base()

				jam_cameras = owner_base:upgrade_value("ecm_jammer", "affects_cameras")
				jam_pagers = owner_base:upgrade_value("ecm_jammer", "affects_pagers")

				self._can_retrigger = owner_base:upgrade_value("ecm_jammer", "can_retrigger")
			end

			managers.groupai:state():register_ecm_jammer(my_unit, {
				call = true,
				camera = jam_cameras,
				pager = jam_pagers
			})
			self:_send_net_event(self._NET_EVENTS.jammer_active)
		else
			managers.groupai:state():register_ecm_jammer(my_unit, false)
		end
	end

	if active then
		if not self._jam_sound_event then
			self._jam_sound_event = my_unit:sound_source():post_event("ecm_jammer_jam_signal")
		end

		my_unit:contour():add("deployable_active")
	else
		self._jammer_low_battery = nil

		local jam_sound_event = self._jam_sound_event

		if jam_sound_event then
			jam_sound_event:stop()

			self._jam_sound_event = nil

			my_unit:sound_source():post_event("ecm_jammer_jam_signal_stop")
		end

		local contour_ext = my_unit:contour()

		if contour_ext then
			if not self._feedback_active then
				contour_ext:remove("deployable_active")

				if self._add_disabled_contour_on_jammer_end then
					contour_ext:add("deployable_disabled")

					self._add_disabled_contour_on_jammer_end = nil
				end
			elseif not self._feedback_low_battery and contour_ext:is_flashing() then
				contour_ext:flash("deployable_active", nil)
			end
		end
	end

	self._jammer_active = active
end

function ECMJammerBase:update(unit, t, dt)
	self._unit:set_extension_update_enabled(ids_base, false)
end

function ECMJammerBase:check_battery()
end

local _set_battery_low_original = ECMJammerBase._set_battery_low
function ECMJammerBase:_set_battery_low()
	_set_battery_low_original(self)

	self._g_glow_jammer_green:set_visibility(false)
	self._jammer_low_battery = true
end

function ECMJammerBase:_set_feedback_active(state)
	state = state and true

	if state == self._feedback_active then
		return
	end

	local my_unit = self._unit

	if self._is_server then
		if state then
			local upg_data = tweak_data.upgrades
			self._feedback_interval = upg_data.ecm_feedback_interval or 1.5
			self._feedback_range = upg_data.ecm_jammer_base_range
			local duration_mul = 1

			if self._owner_id == 1 then
				local player_manager = managers.player

				duration_mul = duration_mul * player_manager:upgrade_value("ecm_jammer", "feedback_duration_boost", 1)
				duration_mul = duration_mul * player_manager:upgrade_value("ecm_jammer", "feedback_duration_boost_2", 1)
			else
				local owner_base = self:owner():base()
				local feedback_boost = owner_base:upgrade_value("ecm_jammer", "feedback_duration_boost") or 1
				local feedback_boost_2 = owner_base:upgrade_value("ecm_jammer", "feedback_duration_boost_2") or 1

				duration_mul = duration_mul * feedback_boost
				duration_mul = duration_mul * feedback_boost_2
			end

			local feedback_duration = math_lerp(upg_data.ecm_feedback_min_duration or 15, upg_data.ecm_feedback_max_duration or 20, math_random()) * duration_mul
			self._feedback_duration = feedback_duration

			local t = TimerManager:game():time()
			self._feedback_expire_t = t + feedback_duration
			local first_impact_t = t + math_lerp(0.1, 1, math_random())

			local key_str = tostring_g(my_unit:key())
			local feedback_clbk_id = "ecm_feedback" .. key_str
			self._feedback_clbk_id = feedback_clbk_id

			managers.enemy:add_delayed_clbk(feedback_clbk_id, callback(self, self, "clbk_feedback"), first_impact_t)

			local low_battery_t = t + feedback_duration - self._low_battery_life
			local low_battery_feedback_clbk_id = "low_battery_feedback" .. key_str
			self._low_battery_feedback_clbk_id = low_battery_feedback_clbk_id
			managers.enemy:add_delayed_clbk(low_battery_feedback_clbk_id, callback(self, self, "_set_feedback_battery_low"), low_battery_t)

			self:_send_net_event(self._NET_EVENTS.feedback_start)
		else
			local feedback_clbk_id = self._feedback_clbk_id

			if feedback_clbk_id then
				managers.enemy:remove_delayed_clbk(feedback_clbk_id)

				self._feedback_clbk_id = nil
			end

			local low_battery_feedback_clbk_id = self._low_battery_feedback_clbk_id

			if low_battery_feedback_clbk_id then
				managers.enemy:remove_delayed_clbk(low_battery_feedback_clbk_id)

				self._low_battery_feedback_clbk_id = nil
			end

			--use a delayed callback since frame-by-frame updating for something like this is stupid
			if self._can_retrigger then
				self:_send_net_event(self._NET_EVENTS.feedback_stop_and_recharge)

				local retrigger_interval = tweak_data.upgrades.ecm_feedback_retrigger_interval or 60
				local retrigger_clbk_id = "ecm_feedback_retrigger" .. tostring_g(my_unit:key())
				self._feedback_retrigger_clbk_id = retrigger_clbk_id

				managers.enemy:add_delayed_clbk(retrigger_clbk_id, callback(self, self, "clbk_feedback_retrigger"), TimerManager:game():time() + retrigger_interval)

				if self._jammer_active then
					self._add_disabled_contour_on_jammer_end = true
				else
					my_unit:contour():add("deployable_disabled")
				end
			elseif not self._being_destroyed then
				self:_send_net_event(self._NET_EVENTS.feedback_stop)
			end
		end
	end

	if state then
		my_unit:interaction():set_active(false)

		self._g_glow_feedback_green:set_visibility(true)
		self._g_glow_feedback_red:set_visibility(false)

		if not self._puke_sound_event then
			local jam_sound_event = self._jam_sound_event

			--the ecm feedback sound event stops the jammer event sounds (audibly, but not technically) for some reason, so this needs to be done
			if jam_sound_event then
				jam_sound_event:stop()

				local sound_src = my_unit:sound_source()

				sound_src:post_event("ecm_jammer_jam_signal_stop")

				self._puke_sound_event = sound_src:post_event("ecm_jammer_puke_signal")
				self._jam_sound_event = sound_src:post_event("ecm_jammer_jam_signal")
			else
				self._puke_sound_event = my_unit:sound_source():post_event("ecm_jammer_puke_signal")
			end
		end

		local contour_ext = my_unit:contour()

		contour_ext:remove("deployable_interactable")
		contour_ext:add("deployable_active")
	else
		self._feedback_low_battery = nil

		self._g_glow_feedback_green:set_visibility(false)
		self._g_glow_feedback_red:set_visibility(false)

		local puke_event = self._puke_sound_event

		if puke_event then
			puke_event:stop()

			self._puke_sound_event = nil

			my_unit:sound_source():post_event("ecm_jammer_puke_signal_stop")
		end

		local contour_ext = my_unit:contour()

		if contour_ext then
			if not self._jammer_active then
				contour_ext:remove("deployable_active")
			elseif not self._jammer_low_battery and contour_ext:is_flashing() then
				contour_ext:flash("deployable_active", nil)
			end
		end
	end

	self._feedback_active = state
end

function ECMJammerBase:clbk_feedback()
	local t = TimerManager:game():time()
	local my_unit = self._unit
	local cur_pos = my_unit:position()
	local range = self._feedback_range

	if not managers.groupai:state():enemy_weapons_hot() then
		managers.groupai:state():propagate_alert({
			"vo_cbt",
			mvec3_cpy(cur_pos),
			range,
			self._alert_filter,
			my_unit
		})
	end

	self._detect_and_give_dmg(cur_pos, my_unit, self:owner(), range)

	local expire_t = self._feedback_expire_t

	if expire_t < t then
		self._feedback_clbk_id = nil

		self:_set_feedback_active(false)
	else
		managers.enemy:add_delayed_clbk(self._feedback_clbk_id, callback(self, self, "clbk_feedback"), t + self._feedback_interval + math_random() * 0.3)
	end
end

function ECMJammerBase:_set_feedback_battery_low()
	self._g_glow_feedback_red:set_visibility(true)
	self._g_glow_feedback_green:set_visibility(false)

	local contour_ext = self._unit:contour()

	if not contour_ext:is_flashing() then
		contour_ext:flash("deployable_active", 0.15)
	end

	if self._is_server then
		self:_send_net_event(self._NET_EVENTS.feedback_flash)
	end

	self._feedback_low_battery = true
end

function ECMJammerBase:clbk_feedback_retrigger()
	if math_random() < tweak_data.upgrades.ecm_feedback_retrigger_chance then
		self:_send_net_event(self._NET_EVENTS.feedback_restart)

		local my_unit = self._unit

		my_unit:contour():remove("deployable_disabled")
		my_unit:sound_source():post_event("ecm_jammer_ready")
		my_unit:interaction():set_active(true)

		self._feedback_retrigger_clbk_id = nil
	else
		local retrigger_interval = tweak_data.upgrades.ecm_feedback_retrigger_interval or 60

		managers.enemy:add_delayed_clbk(self._feedback_retrigger_clbk_id, callback(self, self, "clbk_feedback_retrigger"), TimerManager:game():time() + retrigger_interval)
	end
end

function ECMJammerBase:contour_interaction()
	local my_unit = self._unit
	local contour_ext = my_unit:contour()

	if not contour_ext then
		return
	end

	local int_ext = my_unit:interaction()

	if not int_ext or not int_ext:active() then
		contour_ext:remove("deployable_interactable")
	else
		contour_ext:add("deployable_interactable")
	end
end

function ECMJammerBase._detect_and_give_dmg(from_pos, device_unit, user_unit, range, mark_enemies)
	local enemies_in_range = world_g:find_units_quick("sphere", from_pos, range, managers.slot:get_mask("enemies"))
	local attacker = alive_g(user_unit) and user_unit or nil
	local weapon = alive_g(device_unit) and device_unit or nil

	for i = 1, #enemies_in_range do
		local enemy = enemies_in_range[i]
		local dmg_ext = enemy:character_damage()

		if dmg_ext and dmg_ext.damage_explosion then
			local base_ext = enemy:base()
			local char_tweak = base_ext and base_ext.char_tweak and base_ext:char_tweak()
			local ecm_vuln = char_tweak and char_tweak.ecm_vulnerability

			if ecm_vuln and ecm_vuln ~= 0 then
				local can_stun = true
				local brain_ext = enemy:brain()

				if brain_ext then
					if brain_ext.is_hostage and brain_ext:is_hostage() or brain_ext.surrendered and brain_ext:surrendered() then
						can_stun = false
					end
				end

				local ext_mov = nil

				if can_stun then
					ext_mov = enemy:movement()

					local anim_data = enemy:anim_data()

					if anim_data and anim_data.act or ext_mov:chk_action_forbidden("hurt") or ecm_vuln < math_random() then
						can_stun = false
					end
				end

				if can_stun then
					local hit_pos = mvec3_cpy(ext_mov:m_head_pos())
					local attack_dir = hit_pos - from_pos
					local attack_data = {
						damage = 0,
						variant = "stun",
						attacker_unit = attacker,
						weapon_unit = weapon,
						col_ray = {
							position = hit_pos,
							ray = attack_dir:normalized()
						}
					}
					dmg_ext:damage_explosion(attack_data)
				end
				if mark_enemies and TCD_ENABLED then 
					local contour_ext = enemy:contour()
					if contour_ext then 
						contour_ext:add("pocket_ecm_marked",true,nil,nil,nil)
					end
				end
			end
		end
	end
end

function ECMJammerBase:_force_remove()
	if not self._is_server then
		return
	end

	self._unit:set_slot(0)
end

local save_original = ECMJammerBase.save
function ECMJammerBase:save(data)
	save_original(self, data)

	local state = data.ECMJammerBase
	state.low_battery_feedback = self._feedback_low_battery or nil

	if self._add_disabled_contour_on_jammer_end then
		state.delayed_disabled_contour = true
	elseif self._feedback_retrigger_clbk_id then
		state.has_disabled_contour = true
	end

	local attached_data = self._attached_data
	local attached_body = attached_data and attached_data.body

	if alive_g(attached_body) then
		local attached_unit = attached_data.unit
		local u_data_ext = attached_unit:unit_data()
		local unit_id = u_data_ext and u_data_ext.unit_id or attached_unit:editor_id()

		if unit_id then
			local my_unit = self._unit

			state.attached_u_id = unit_id
			state.attached_body_index = attached_unit:get_body_index(attached_body:name())
			state.attached_local_pos = my_unit:local_position()
			state.attached_local_rot = my_unit:local_rotation()
		end
	end

	data.ECMJammerBase = state
end

local load_original = ECMJammerBase.load
function ECMJammerBase:load(load_data)
	load_original(self, load_data)

	local data = load_data.ECMJammerBase
	local owner_id = data.owner_id
	local peer = managers.network:session():peer(owner_id)
	self._owner = peer and peer:unit()

	self:contour_interaction()

	if data.low_battery_feedback then
		self:_set_feedback_battery_low()
	end

	if data.delayed_disabled_contour then
		self._add_disabled_contour_on_jammer_end = true
	elseif data.has_disabled_contour then
		local my_unit = self._unit
		local contour_ext = my_unit:contour()

		--if contour_ext then
			contour_ext:add("deployable_disabled")
		--[[else
			call_on_next_update(function()
				if not alive_g(my_unit) then
					return
				end

				contour_ext = my_unit:contour()

				if contour_ext then
					contour_ext:add("deployable_disabled")
				end
			end)
		end]]
	end

	local parent_u_id = data.attached_u_id

	if not parent_u_id then
		return
	end

	local is_editor = Application:editor()
	local parent_unit = nil

	if is_editor then
		parent_unit = managers.editor:unit_with_id(parent_u_id)
	else
		parent_unit = managers.worlddefinition:get_unit_on_load(parent_u_id, callback(self, self, "clbk_load_parent_unit"))
	end

	if parent_unit then
		self:_post_load_attach(parent_unit, data.attached_body_index, data.attached_local_pos, data.attached_local_rot)
	elseif not is_editor then
		self._load_attach_data = {
			attached_body_index = data.attached_body_index,
			attached_local_pos = data.attached_local_pos,
			attached_local_rot = data.attached_local_rot
		}
	else
		log("ECMJammerBase: failed to attach ECM on load while using the editor")
	end
end

function ECMJammerBase:clbk_load_parent_unit(parent_unit)
	if parent_unit then
		local data = self._load_attach_data

		self:_post_load_attach(parent_unit, data.attached_body_index, data.attached_local_pos, data.attached_local_rot)
	end

	self._load_attach_data = nil
end

function ECMJammerBase:_post_load_attach(parent_unit, body_index, local_pos, local_rot)
	if not alive_g(parent_unit) or not alive_g(self._unit) then
		return
	end

	local parent_body = parent_unit:body(body_index)

	if not alive_g(parent_body) then
		return
	end

	self:link_attachment(parent_body, local_pos, local_rot)
end

local destroy_original = ECMJammerBase.destroy
function ECMJammerBase:destroy(...)
	ECMJammerBase.super.destroy(self, ...)

	self._can_retrigger = nil
	self._being_destroyed = true --intentionally different from UnitBase to not interfere

	destroy_original(self, ...)

	local retrigger_clbk_id = self._feedback_retrigger_clbk_id

	if retrigger_clbk_id then
		managers.enemy:remove_delayed_clbk(retrigger_clbk_id)

		self._feedback_retrigger_clbk_id = nil
	end

	local battery_low_clbk_id = self._battery_low_clbk_id

	if battery_low_clbk_id then
		managers.enemy:remove_delayed_clbk(battery_low_clbk_id)

		self._battery_low_clbk_id = nil
	end

	local battery_empty_clbk_id = self._battery_empty_clbk_id

	if battery_empty_clbk_id then
		managers.enemy:remove_delayed_clbk(battery_empty_clbk_id)

		self._battery_empty_clbk_id = nil
	end

	self:_remove_attached_body_callbacks()
end
