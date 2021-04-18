local mvec3_dis_sq = mvector3.distance_sq
local mvec3_cpy = mvector3.copy
local mvec3_not_equal = mvector3.not_equal

local mrot_equal = mrotation.equal

local math_ceil = math.ceil
local math_random = math.random

local tostring_g = tostring

local alive_g = alive

local ids_base = Idstring("base")

local draw_explosion_sphere = nil
local draw_sync_explosion_sphere = nil
local draw_vanilla_explosion_cylinder = nil
local draw_splinters = nil
local draw_obstructed_splinters = nil
local draw_splinter_hits = nil

local set_active_original = TripMineBase.set_active
function TripMineBase:set_active(active, owner, stuck_on_enemy)
	set_active_original(self, active, owner)

	local activate_time = self._activate_timer

	if not activate_time then
		return
	end

	local my_unit = self._unit

	my_unit:set_extension_update_enabled(ids_base, false)

	if stuck_on_enemy then
		self._attached_data = nil

		return
	end

	local attached_data = self._attached_data

	if not attached_data then
		self:_explode()

		return
	end

	local t = TimerManager:game():time()
	local activate_clbk_id = "_activate_clbk_id" .. tostring_g(my_unit:key())
	self._activate_clbk_id = activate_clbk_id

	managers.enemy:add_delayed_clbk(activate_clbk_id, callback(self, self, "_clbk_activate"), t + activate_time)

	local hit_body = attached_data.body
	local hit_unit = hit_body:unit()
	local disabled_clbk = callback(self, self, "_clbk_attached_body_disabled")
	local activation_clbk = callback(self, self, "_clbk_attached_body_active")

	self._attached_data = {
		unit = hit_unit,
		body = hit_body,
		disabled_clbk = disabled_clbk,
		activation_clbk = activation_clbk,
		position = hit_body:position(),
		rotation = hit_body:rotation()
	}

	hit_unit:add_body_enabled_callback(disabled_clbk)
	hit_unit:add_body_activation_callback(activation_clbk)

	local has_destroy_listener = nil
	local listener_class = hit_unit:base()

	if listener_class and listener_class.add_destroy_listener then
		local listener_key = "TripMineBase" .. tostring_g(my_unit:key())
		self._attached_data.destroy_listener_key = listener_key

		listener_class:add_destroy_listener(listener_key, callback(self, self, "_clbk_attached_body_destroyed"))

		has_destroy_listener = true
	else
		listener_class = hit_unit:unit_data()

		if listener_class and listener_class.add_destroy_listener then
			local listener_key = "TripMineBase" .. tostring_g(my_unit:key())
			self._attached_data.destroy_listener_key = listener_key

			listener_class:add_destroy_listener(listener_key, callback(self, self, "_clbk_attached_body_destroyed"))

			has_destroy_listener = true
		end
	end

	if has_destroy_listener then
		local pos_rot_chk_id = "TripMineBase._pos_rot_chk" .. tostring_g(my_unit:key())
		self._pos_rot_chk_id = pos_rot_chk_id

		managers.enemy:add_delayed_clbk(pos_rot_chk_id, callback(self, self, "_clbk_pos_rot_chk"), Application:time() + 0.5)
	else
		local pos_rot_chk_id = "TripMineBase._pos_rot_chk" .. tostring_g(my_unit:key())
		self._pos_rot_chk_id = pos_rot_chk_id

		managers.enemy:add_delayed_clbk(pos_rot_chk_id, callback(self, self, "_clbk_pos_rot_alive_chk"), Application:time() + 0.5)
	end
end

function TripMineBase:_clbk_activate()
	self._activate_timer = nil

	self:set_armed(self._startup_armed)

	self._startup_armed = nil

	self._unit:set_extension_update_enabled(ids_base, true)
end

function TripMineBase:_clbk_pos_rot_chk()
	local data = self._attached_data
	local body = data.body

	if not mrot_equal(data.rotation, body:rotation()) or mvec3_not_equal(data.position, body:position()) then
		self._pos_rot_chk_id = nil

		self:_remove_attached_body_callbacks()
		self:_attach_explode()

		return
	end

	managers.enemy:add_delayed_clbk(self._pos_rot_chk_id, callback(self, self, "_clbk_pos_rot_chk"), Application:time() + 0.5)
end

function TripMineBase:_clbk_pos_rot_alive_chk(unit)
	local data = self._attached_data
	local body = data.body

	if not alive_g(data.body) or not mrot_equal(data.rotation, body:rotation()) or mvec3_not_equal(data.position, body:position()) then
		self._pos_rot_chk_id = nil

		self:_remove_attached_body_callbacks()
		self:_attach_explode()

		return
	end

	managers.enemy:add_delayed_clbk(self._pos_rot_chk_id, callback(self, self, "_clbk_pos_rot_alive_chk"), Application:time() + 0.5)
end

function TripMineBase:_clbk_attached_body_destroyed(unit)
	self:_remove_attached_body_callbacks()
	self:_attach_explode()
end

function TripMineBase:_clbk_attached_body_disabled(unit, body)
	local data = self._attached_data

	if data.body:key() ~= body:key() then
		return
	end

	if not body:enabled() or not mrot_equal(data.rotation, body:rotation()) or mvec3_not_equal(data.position, body:position()) then
		self:_remove_attached_body_callbacks()
		self:_attach_explode()
	end
end

function TripMineBase:_clbk_attached_body_active(tag, unit, body, activated)
	if activated then
		return
	end

	local data = self._attached_data

	if data.body:key() ~= body:key() then
		return
	end

	if not body:enabled() or not mrot_equal(data.rotation, body:rotation()) or mvec3_not_equal(data.position, body:position()) then
		self:_remove_attached_body_callbacks()
		self:_attach_explode()
	end
end

function TripMineBase:_attach_explode()
	self._unit:set_extension_update_enabled(ids_base, false)

	local explode_clbk_id = self._explode_clbk_id

	if explode_clbk_id then
		managers.enemy:remove_delayed_clbk(explode_clbk_id)

		self._explode_clbk_id = nil
	end

	self:_explode()
end

function TripMineBase:_remove_attached_body_callbacks()
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

			if data.disabled_clbk then
				attached_unit:remove_body_enabled_callback(data.disabled_clbk)
			end

			if data.activation_clbk then
				attached_unit:remove_body_activation_callback(data.activation_clbk)
			end
		end
	end

	local pos_rot_chk_id = self._pos_rot_chk_id

	if pos_rot_chk_id then
		managers.enemy:remove_delayed_clbk(pos_rot_chk_id)

		self._pos_rot_chk_id = nil
	end

	self._attached_data = nil
end

function TripMineBase:_play_sound_and_effects(range)
	range = range or tweak_data.weapon.trip_mines.damage_size

	local custom_params = {
		camera_shake_max_mul = 4,
		sound_muffle_effect = true,
		sound_event = "trip_mine_explode",
		effect = "effects/payday2/particles/explosions/grenade_explosion",
		feedback_range = range * 2,
		on_unit = true
	}

	local unit = self._unit
	local my_fwd = unit:rotation():y()
	local hit_pos = unit:position() + my_fwd * 5

	managers.explosion:play_sound_and_effects(hit_pos, my_fwd, range, custom_params)
end

local destroy_original = TripMineBase.destroy
function TripMineBase:destroy(...)
	TripMineBase.super.destroy(self, ...)
	destroy_original(self, ...)

	local activate_clbk_id = self._activate_clbk_id

	if activate_clbk_id then
		managers.enemy:remove_delayed_clbk(activate_clbk_id)

		self._activate_clbk_id = nil
	end

	local explode_clbk_id = self._explode_clbk_id

	if explode_clbk_id then
		managers.enemy:remove_delayed_clbk(explode_clbk_id)

		self._explode_clbk_id = nil
	end

	self:_remove_attached_body_callbacks()
end


--tripmine overhaul
if deathvox:IsTotalCrackdownEnabled() then 
	TripMineBase.vulnerability_upgrade_shift = 2
	TripMineBase.radius_upgrade_shift = 4
	
--todo disable tripmine updates etc. when it has been stuck to an enemy	
	
--new methods
	function TripMineBase:_get_trigger_mode()
		return self._trigger_mode
	end

	function TripMineBase:_get_payload_mode()
		return self._payload_mode
	end

	function TripMineBase:set_trigger_mode(mode) --local
		if self._activate_timer then 
			self._activate_timer = nil
			self:set_armed(self:_get_payload_mode() ~= "payload_sensor")

			self._unit:set_extension_update_enabled(ids_base, true)

			local activate_clbk_id = self._activate_clbk_id

			if activate_clbk_id then
				managers.enemy:remove_delayed_clbk(activate_clbk_id)

				self._activate_clbk_id = nil
			end
		end
		if self:_get_trigger_mode() == mode and mode == "trigger_special" then 
			--this one's a single-switch toggle between default/special (detonate doesn't really count as a trigger mode here since uh. as they say, it's a neat trick, but you can only do it once)
			self:_set_trigger_mode("trigger_default")
		else
			if self:is_owner() then 
				self:_set_trigger_mode(mode)
				if mode == "trigger_detonate" then 
					if self:_get_payload_mode() == "payload_sensor" then
						self:_set_payload_mode("payload_explosive")
						self:sync_send_trigger_mode(mode)
					end
					self:explode()
				end
			end
		end
	end
	
	function TripMineBase:_set_trigger_mode(mode)
		if mode and TripmineControlMenu.VALID_TRIPMINE_TRIGGER_MODES[mode] then
			if self._activate_timer then 
				self._activate_timer = nil
				self:set_armed(mode)
			end
			self._trigger_mode = mode
		else
			log("TOTAL CRACKDOWN: TripMineBase:_set_trigger_mode(" .. tostring_g(mode) .. "): Unknown trigger mode")
			return
		end
	end
	
	function TripMineBase:set_payload_mode(mode) --local
		if self._activate_timer then 
			self._activate_timer = nil
			self:set_armed(mode ~= "payload_sensor")

			self._unit:set_extension_update_enabled(ids_base, true)

			local activate_clbk_id = self._activate_clbk_id

			if activate_clbk_id then
				managers.enemy:remove_delayed_clbk(activate_clbk_id)

				self._activate_clbk_id = nil
			end
		end
		if self:is_owner() and mode ~= self:_get_payload_mode() then 
			self:_set_payload_mode(mode)
			self:sync_send_payload_mode(mode)

			if mode == "payload_recover" then 
				managers.player:add_grenade_amount(1, true)
			end
		end
	end

	function TripMineBase:_set_payload_mode(mode)
		if mode and TripmineControlMenu.VALID_TRIPMINE_PAYLOAD_MODES[mode] then
			self._payload_mode = mode
			if self._activate_timer then 
				self._activate_timer = nil
			end
			if mode == "payload_recover" then			
--				self:set_armed(false)
				if Network:is_server() or self._unit:id() == -1 then 
					self._unit:set_slot(0)
				else
					self._active = false
					self._unit:interaction():set_disabled(true)
					self._unit:set_visible(false)
				end
			else
				self:set_armed(mode ~= "payload_sensor")
			end
		else
			log("TOTAL CRACKDOWN: TripMineBase:_set_payload_mode(" .. tostring_g(mode) .. "): Unknown payload mode")
			return
		end
	end

	function TripMineBase:sync_send_trigger_mode(mode)
		--self._unit:network():send(self.NETWORK_SPOOF_ID,"_set_trigger_mode",0,mode) 
		--unit doesn't have network extension or else this would work great

		local session = managers.network:session()

		if session and self:is_owner() then
			local mode_sync_id = mode and TripmineControlMenu.NetworkSyncIDsReverseLookup[mode]

			if mode_sync_id then 
				session:send_to_peers_synched(TripmineControlMenu.NETWORK_SPOOF_ID, self._unit, managers.player:player_unit() or nil, Vector3(), Vector3(), 0, 0, mode_sync_id, 0)
			else
				log("TOTAL CRACKDOWN: TripMineBase:sync_send_trigger_mode(" .. tostring_g(mode) .. "): Unknown mode network id")
				return
			end
		end
	end
	
	function TripMineBase:sync_send_payload_mode(mode)
		--self._unit:network():send(self.NETWORK_SPOOF_ID,"_set_payload_mode",0,mode)

		local session = managers.network:session()

		if session and self:is_owner() then
			local mode_sync_id = mode and TripmineControlMenu.NetworkSyncIDsReverseLookup[mode]

			if mode_sync_id then 
				session:send_to_peers_synched(TripmineControlMenu.NETWORK_SPOOF_ID, self._unit, managers.player:player_unit() or nil, Vector3(), Vector3(), 0, 0, mode_sync_id, 1)
			else
				log("TOTAL CRACKDOWN: TripMineBase:sync_send_payload_mode(" .. tostring_g(mode) .. "): Unknown mode network id")
				return
			end
		end
	end
	
	function TripMineBase:is_owner()
		return managers.network:session() and self._owner_peer_id == managers.network:session():local_peer():id()
	end

	function TripMineBase:set_server_information(peer_id)
		self._server_information = {
			owner_peer_id = peer_id
		}

		--not actually a deployable in Total Crackdown, disabling
		--managers.network:session():peer(peer_id):set_used_deployable(true)
	end

	function TripMineBase:attach_to_enemy(stuck_enemy, position, rot, parent_obj, radius_upgrade_level, vulnerability_upgrade_level)
		local unit = self._unit

		unit:interaction():set_active(false)
		unit:set_extension_update_enabled(ids_base, false)

		local char_dmg = alive_g(stuck_enemy) and stuck_enemy:character_damage()

		if not char_dmg or char_dmg:dead() then
			--this might happen in cases of severe lag where the stuck_enemy and is killed between the time of the placement request and the time of execution
			if self:is_owner() then
				if self:_get_payload_mode() == "payload_sensor" then
					self:set_payload_mode("payload_explosive")
				end

				self:_explode()
			end

			return
		end

		stuck_enemy:link(parent_obj:name(), unit)

		local sound_ext = stuck_enemy:sound()

		if sound_ext then 
			local voice_roll = math_random()

			if voice_roll > 0.75 then 
				sound_ext:say("hlp")
			elseif voice_roll > 0.25 then
				sound_ext:say("burnhurt")
			elseif voice_roll > 0.01 then 
				sound_ext:say("burndeath")
			else
				sound_ext:say("ch1")
			end
		end

		if not self:is_owner() then
			return
		end

		if self:_get_payload_mode() == "payload_sensor" then
			self:set_payload_mode("payload_explosive")
		end

		local attack_data = {
			damage = 0,
			variant = "fire",
			pos = mvec3_cpy(position),
			attack_dir = mvec3_cpy(rot:y()),
			result = {
				variant = "fire",
				type = "fire_hurt"
			}
		}
		char_dmg:_call_listeners(attack_data)

		local panic_radius = managers.player:upgrade_value_by_level("trip_mine", "stuck_enemy_panic_radius", radius_upgrade_level, 0)

		if panic_radius > 0 then
			local is_dozer = stuck_enemy:base():has_tag("tank")
			local apply_vuln_data = nil

			if is_dozer and vulnerability_upgrade_level > 0 then
				local amount, duration = unpack(managers.player:upgrade_value("trip_mine", "stuck_dozer_damage_vulnerability", {0, 0}))
				apply_vuln_data = {
					id = "have_blast_aced_aoe_vulnerability",
					amount = amount,
					duration = duration
				}

				local dmg_ext = stuck_enemy:character_damage()

				if dmg_ext.set_damage_vulnerability then
					stuck_enemy:character_damage():set_damage_vulnerability(apply_vuln_data.id, apply_vuln_data.amount, apply_vuln_data.duration)
				end
			end

			--not sure if i should use tripmine's position or stuck_enemy's position
			--i guess hit_position since the other enemies would be afraid of the tripmine itself?
			local nearby_enemies = stuck_enemy:find_units_quick("sphere", position or stuck_enemy:movement():m_pos(), panic_radius, managers.slot:get_mask("enemies"))

			for i = 1, #nearby_enemies do
				local nearby_enemy = nearby_enemies[i]
				local dmg_ext = nearby_enemy:character_damage()

				if dmg_ext then
					if dmg_ext.build_suppression then 
						dmg_ext:build_suppression("panic")
					end

					if apply_vuln_data and dmg_ext.set_damage_vulnerability then
						--doesn't apply to turrets
						dmg_ext:set_damage_vulnerability(apply_vuln_data.id, apply_vuln_data.amount, apply_vuln_data.duration)
					end
				end
			end
		end

		local t = TimerManager:game():time()
		local u_key_str = tostring_g(unit:key())

		managers.enemy:add_delayed_clbk("tripmine_stuck_delayed_beep_" .. u_key_str, function()
			if alive_g(unit) then
				unit:sound_source():stop()
				unit:sound_source():post_event("trip_mine_beep_explode")

				managers.network:session():send_to_peers_synched("sync_unit_event_id_16", unit, "base", TripMineBase.EVENT_IDS.explosion_beep)
			end
		end, t + 0.6)

		self._explode_timer = 1

		local explode_clbk_id = "_explode_clbk_id" .. u_key_str
		self._explode_clbk_id = explode_clbk_id

		managers.enemy:add_delayed_clbk(explode_clbk_id, callback(self, self, "_explode"), t + 1)

		self._attached_data = {
			unit = stuck_enemy
		}

		local listener_class = stuck_enemy:base()

		if listener_class and listener_class.add_destroy_listener then
			local listener_key = "TripMineBase" .. u_key_str
			self._attached_data.destroy_listener_key = listener_key

			listener_class:add_destroy_listener(listener_key, callback(self, self, "_clbk_attached_body_destroyed"))

			has_destroy_listener = true
		end
	end



--changed vanilla methods	
	TripMineBase.EVENT_IDS = { --unchanged
		sensor_beep = 1,
		explosion_beep = 2
	}
	
	function TripMineBase.spawn(pos, rot, sensor_upgrade, peer_id)
		local unit = World:spawn_unit(Idstring("units/payday2/equipment/gen_equipment_tripmine/gen_equipment_tripmine"), pos, rot)

		managers.network:session():send_to_peers_synched("sync_trip_mine_setup", unit, sensor_upgrade, peer_id or 0)
		unit:base():setup(sensor_upgrade)
		
		unit:interaction():set_active(peer_id and peer_id == managers.network:session():local_peer():id()) --only the owner can change the tripmine

		return unit
	end
	
	function TripMineBase:init(unit)
		UnitBase.init(self, unit, false)
		
		self._unit = unit
		self._position = self._unit:position()
		self._rotation = self._unit:rotation()
		self._forward = self._rotation:y()
		self._ray_from_pos = Vector3()
		self._ray_to_pos = Vector3()
		self._init_length = 500
		self._length = self._init_length
		self._ids_laser = Idstring("laser")
		self._g_laser = self._unit:get_object(Idstring("g_laser"))
		self._g_laser_sensor = self._unit:get_object(Idstring("g_laser_sensor"))
		self._use_draw_laser = false
		
		--offy wuz hear v
		self._CONCUSSION_DAMAGE = 100
--		self._CONCUSSION_RANGE = 1000
		--
		
		
		if self._use_draw_laser then
			self._laser_color = Color(0.15, 1, 0, 0)
			self._laser_sensor_color = Color(0.15, 0.1, 0.1, 1)
			self._laser_brush = Draw:brush(self._laser_color, "VertexColor")

			self._laser_brush:set_blend_mode("opacity_add")
		end

		if Network:is_client() then
			self._validate_clbk_id = "trip_mine_validate" .. tostring_g(unit:key())

			managers.enemy:add_delayed_clbk(self._validate_clbk_id, callback(self, self, "_clbk_validate"), Application:time() + 60)
		end

		managers.player:send_message("trip_mine_placed", nil, self._unit)
	end

	function TripMineBase:setup(sensor_upgrade)
		self._slotmask = managers.slot:get_mask("trip_mine_targets")
		self._first_armed = false
		self._armed = false

		if sensor_upgrade then
--			self._MARK_CONTOUR = ""
--not needed actually
		end

		self._startup_armed = not managers.groupai:state():whisper_mode()

		self._sensor_upgrade = true

		self:set_active(false)
		self._unit:sound_source():post_event("trip_mine_attach")

		self._unit:contour():add("deployable_interactable")
		
		
		--offy wuz hear
		self._trigger_mode = TripmineControlMenu.DEFAULT_TRIGGER_MODE
		self._payload_mode = managers.groupai:state():whisper_mode() and "payload_sensor" or TripmineControlMenu.DEFAULT_PAYLOAD_MODE
	end
	
	function TripMineBase:update(unit, t, dt)
		--if you wish to use debug drawing for whatever reason, use the code below
		--and comment out the 'if not self._owner then' block of code
		--[[self:_update_draw_laser()

		if self._explode_timer or not self._owner then
			if not self._use_draw_laser then
				self._unit:set_extension_update_enabled(ids_base, false)
			end

			return
		end]]

		if not self._owner then
			--just in case
			self._unit:set_extension_update_enabled(ids_base, false)

			return
		end
		
		if self:_get_payload_mode() == "payload_sensor" then
			self:_sensor(t)

			local det_unit_last_t = self._sensor_last_unit_time

			if det_unit_last_t and det_unit_last_t < t then
				self._sensor_units_detected = nil
				self._sensor_last_unit_time = nil
			end

			return
		end

		self:_check()
	end

	function TripMineBase:_sensor(t)
		local ray = self:_raycast()

		if ray and ray.unit and not tweak_data.character[ray.unit:base()._tweak_table].is_escort then
			self._sensor_units_detected = self._sensor_units_detected or {}

			if not self._sensor_units_detected[ray.unit:key()] then
				self._sensor_units_detected[ray.unit:key()] = true

				if (self:_get_trigger_mode() ~= "trigger_special") or (managers.groupai:state():whisper_mode() and tweak_data.character[ray.unit:base()._tweak_table].silent_priority_shout or tweak_data.character[ray.unit:base()._tweak_table].priority_shout) then 
				--or managers.groupai:state():is_enemy_special(ray.unit)
					managers.game_play_central:auto_highlight_enemy(ray.unit, true,self:is_owner()) --only apply tripmine spotting upgrades if the person is the owner
					self:_emit_sensor_sound_and_effect()

					if managers.network:session() then
						managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", TripMineBase.EVENT_IDS.sensor_beep)
					end
				end

				self._sensor_last_unit_time = t + 5
			end
		end
	end

	function TripMineBase:_check()
		local session = managers.network:session()

		if not session then
			return
		end

		local ray = self:_raycast()

		if not ray then
			return
		end

		local hit_unit = ray.unit

		if hit_unit and not tweak_data.character[hit_unit:base()._tweak_table].is_escort then
			local hit_mov_ext = hit_unit:movement()
			local hit_unit_team = hit_mov_ext and hit_mov_ext:team()

			if hit_unit_team then
				local team_id_player = tweak_data.levels:get_default_team_ID("player")
				local team_id_ray = hit_unit_team.id

				if not managers.groupai:state():team_data(team_id_player).foes[team_id_ray] then
					return
				end
			end

			if self:_get_trigger_mode() ~= "trigger_special" or managers.groupai:state():is_enemy_special(ray.unit) then 
				local explode_time = tweak_data.weapon.trip_mines.delay + managers.player:upgrade_value("trip_mine", "explode_timer_delay", 0)
				self._explode_timer = explode_time

				local my_unit = self._unit

				my_unit:interaction():set_active(false)
				my_unit:set_extension_update_enabled(ids_base, false)

				local explode_clbk_id = "_explode_clbk_id" .. tostring_g(my_unit:key())
				self._explode_clbk_id = explode_clbk_id

				managers.enemy:add_delayed_clbk(explode_clbk_id, callback(self, self, "_explode"), TimerManager:game():time() + explode_time)

				self._explode_ray = ray

				my_unit:sound_source():post_event("trip_mine_beep_explode")

				session:send_to_peers_synched("sync_unit_event_id_16", my_unit, "base", TripMineBase.EVENT_IDS.explosion_beep)
			end
		end
	end

	function TripMineBase:explode(force)
		if not force then 
			if not self._active then
				return
			end
			
			if self._payload_mode == "payload_sensor" then 
			--self._active is used to check whether the unit is doing anything, basically, including its regular extension update
			--so check for the sensor mode manually here instead of doing set_active() when toggling sensor mode
				return
			end
		end

		self._active = false
		local col_ray = {
			ray = self._forward,
			position = self._position
		}

		self:_explode(col_ray)
	end

	function TripMineBase:_explode()
		local activate_clbk_id = self._activate_clbk_id

		if activate_clbk_id then
			managers.enemy:remove_delayed_clbk(activate_clbk_id)

			self._activate_clbk_id = nil
		end

		local player_manager = managers.player
		local damage_size = tweak_data.weapon.trip_mines.damage_size * player_manager:upgrade_value("trip_mine", "explosion_size_multiplier_1", 1) * player_manager:upgrade_value("trip_mine", "damage_multiplier", 1)
		local player = player_manager:player_unit() or nil
		local my_pos = self._ray_from_pos
		local my_fwd = self._forward
		local hit_pos = my_pos + my_fwd * 5

		if draw_explosion_sphere then
			local draw_duration = 3
			local new_brush = Draw:brush(Color.red:with_alpha(0.5), draw_duration)
			new_brush:sphere(hit_pos, damage_size)
		end

		if draw_vanilla_explosion_cylinder then
			local draw_duration = 3
			local new_brush = Draw:brush(Color.blue:with_alpha(0.5), draw_duration)
			new_brush:cylinder(my_pos, self._ray_to_pos, damage_size)
		end

		local unit = self._unit

		self._deactive_timer = 5

		local session = managers.network:session()
		local payload_mode = self:_get_payload_mode()

		if payload_mode == "payload_explosive" then
			managers.explosion:give_local_player_dmg(hit_pos, damage_size, tweak_data.weapon.trip_mines.player_damage)
			self:_play_sound_and_effects(damage_size)

			local splinters = {
				mvec3_cpy(hit_pos)
			}
			local dirs = {
				Vector3(damage_size, 0, 0),
				Vector3(-damage_size, 0, 0),
				Vector3(0, damage_size, 0),
				Vector3(0, -damage_size, 0),
				Vector3(0, 0, damage_size),
				Vector3(0, 0, -damage_size)
			}

			local geometry_mask = managers.slot:get_mask("world_geometry")

			for i = 1, #dirs do
				local dir = dirs[i]
				local tmp_pos = hit_pos - dir
				local splinter_ray = unit:raycast("ray", hit_pos, tmp_pos, "slot_mask", geometry_mask)

				if splinter_ray then
					local ray_dis = splinter_ray.distance
					local dis = ray_dis > 10 and 10 or ray_dis

					tmp_pos = splinter_ray.position - dir:normalized() * dis
				end

				if draw_splinters then
					local draw_duration = 3
					local new_brush = Draw:brush(Color.white:with_alpha(0.5), draw_duration)
					new_brush:cylinder(hit_pos, tmp_pos, 0.5)
				end

				local near_other_splinter = nil

				for idx = 1, #splinters do
					local s_pos = splinters[idx]

					if mvec3_dis_sq(tmp_pos, s_pos) < 900 then
						near_other_splinter = true

						break
					end
				end

				if not near_other_splinter then
					splinters[#splinters + 1] = mvec3_cpy(tmp_pos)
				end
			end

			local slot_manager = managers.slot
			local slotmask = slot_manager:get_mask("explosion_targets")
			local cant_hit_civilians = player_manager:has_category_upgrade("trip_mine", "no_damaging_civilians")
			local cant_hit_hostages = player_manager:has_category_upgrade("trip_mine", "no_damaging_hostages")

			if cant_hit_civilians then
				slotmask = slotmask - slot_manager:get_mask("civilians")
			end

			if cant_hit_hostages then
				slotmask = slotmask - 22 --hostages slotmask
			end

			local units_to_hit, units_to_push = {}, {}
			local damage = tweak_data.weapon.trip_mines.damage * player_manager:upgrade_value("trip_mine", "damage_multiplier", 1)
			local bodies = unit:find_bodies("intersect", "sphere", hit_pos, damage_size, slotmask)

			for i = 1, #bodies do
				local hit_body = bodies[i]

				if alive_g(hit_body) then
					local hit_unit = hit_body:unit()
					local hit_unit_key = hit_unit:key()
					units_to_push[hit_unit_key] = hit_unit

					local char_dmg_ext = hit_unit:character_damage()
					local hit_character = char_dmg_ext and char_dmg_ext.damage_explosion and not char_dmg_ext:dead()
					local body_ext = hit_body:extension()
					local body_ext_dmg = body_ext and body_ext.damage
					local ray_hit, body_com, damage_character = nil

					if hit_character then
						if not units_to_hit[hit_unit_key] then
							body_com = hit_body:center_of_mass()

							for i = 1, #splinters do
								local s_pos = splinters[i]

								ray_hit = not unit:raycast("ray", s_pos, body_com, "slot_mask", geometry_mask, "report")

								if ray_hit then
									units_to_hit[hit_unit_key] = true
									damage_character = true

									if draw_splinter_hits then
										local draw_duration = 3
										local new_brush = Draw:brush(Color.green:with_alpha(0.5), draw_duration)
										new_brush:cylinder(s_pos, body_com, 0.5)
									end

									break
								elseif draw_obstructed_splinters then
									local draw_duration = 3
									local new_brush = Draw:brush(Color.yellow:with_alpha(0.5), draw_duration)
									new_brush:cylinder(s_pos, body_com, 0.5)
								end
							end
						end
					elseif body_ext_dmg or hit_body:dynamic() then
						if not units_to_hit[hit_unit_key] then
							ray_hit = true
							units_to_hit[hit_unit_key] = true
						end
					end

					if not ray_hit and body_ext_dmg and units_to_hit[hit_unit_key] and char_dmg_ext and char_dmg_ext.damage_explosion then
						body_com = body_com or hit_body:center_of_mass()

						for i = 1, #splinters do
							local s_pos = splinters[i]

							ray_hit = not unit:raycast("ray", s_pos, body_com, "slot_mask", geometry_mask, "report")

							if ray_hit then
								break
							end
						end
					end

					if ray_hit then
						body_com = body_com or hit_body:center_of_mass()
						local dir = body_com - hit_pos
						dir = dir:normalized()

						local dmg = damage
						local base_ext = hit_unit:base()

						if base_ext and base_ext.has_tag and base_ext:has_tag("tank") then
							dmg = dmg * 7
						end

						local body_hit_pos = nil

						if body_ext_dmg then
							local normal = dir
							local prop_damage = dmg > 200 and 200 or dmg
							local network_damage = math_ceil(prop_damage * 163.84)
							prop_damage = network_damage / 163.84

							body_hit_pos = mvec3_cpy(hit_body:position())

							body_ext_dmg:damage_explosion(player, normal, body_hit_pos, dir, prop_damage)
							body_ext_dmg:damage_damage(player, normal, body_hit_pos, dir, prop_damage)

							if session and hit_unit:id() ~= -1 then
								network_damage = network_damage > 32768 and 32768 or network_damage

								if player then
									session:send_to_peers_synched("sync_body_damage_explosion", hit_body, player, normal, body_hit_pos, dir, network_damage)
								else
									session:send_to_peers_synched("sync_body_damage_explosion_no_attacker", hit_body, normal, body_hit_pos, dir, network_damage)
								end
							end
						end

						if damage_character then
							body_hit_pos = body_hit_pos or mvec3_cpy(hit_body:position())

							--since sending the same col_ray table for all hits actually doesn't make much sense
							local accurate_col_ray = {
								position = body_hit_pos,
								ray = dir
							}

							self:_give_explosion_damage(accurate_col_ray, hit_unit, dmg)
						end
					end
				end
			end

			if session then
				if player then
					session:send_to_peers_synched("sync_trip_mine_explode", unit, player, my_pos, my_fwd, damage_size, damage)
				else
					session:send_to_peers_synched("sync_trip_mine_explode_no_user", unit, my_pos, my_fwd, damage_size, damage)
				end
			end

			managers.explosion:units_to_push(units_to_push, hit_pos, 300)
		elseif payload_mode == "payload_incendiary" then
			self:_play_sound_and_effects(damage_size)

			if session then
				--see enveffecttweakdata to change values
				local added_time = 0
				local range_multiplier = 1

				session:send_to_peers_synched("sync_trip_mine_explode_spawn_fire", unit, player, my_pos, my_fwd, damage_size, damage, added_time, range_multiplier)
				self:_spawn_environment_fire(player, added_time, range_multiplier)
			end
		elseif payload_mode == "payload_concussive" then
			managers.explosion:play_sound_and_effects(hit_pos, my_fwd, damage_size, {
				camera_shake_max_mul = 4,
				effect = "effects/particles/explosions/explosion_flash_grenade",
				sound_event = "flashbang_explosion", --or the normal "trip_mine_explode", but in that case should use at least some of the code in TripMineBase:_play_sound_and_effects() since it disposes of the soundsource afterward
				feedback_range = damage_size * 2
			})

			if Network:is_server() then
				local hit_units, splinters = managers.explosion:detect_and_stun({
					player_damage = 1,
					hit_pos = hit_pos,
					range = damage_size,
					collision_slotmask = managers.slot:get_mask("enemies"),
					curve_pow = 2,
					damage = self._CONCUSSION_DAMAGE,
					ignore_unit = unit,
					alert_filter = self._alert_filter or managers.groupai:state():get_unit_type_filter("civilians_enemies"),
					alert_radius = tweak_data.weapon.trip_mines.alert_radius,
					user = player or unit,
					verify_callback = callback(self, self, "_can_stun_unit")
				})
			end

			if session then
				if player then
					session:send_to_peers_synched("sync_trip_mine_explode", unit, player, hit_pos, my_fwd, damage_size, damage)
				else
					session:send_to_peers_synched("sync_trip_mine_explode_no_user", unit, hit_pos, my_fwd, damage_size, damage)
				end
			end
		else
			log("TOTAL CRACKDOWN: TripMineBase:_explode(" .. tostring_g(payload_mode) .."): Unknown payload detonation type")
		end

		if payload_mode ~= "payload_concussive" then
			local alert_radius = tweak_data.weapon.trip_mines.alert_radius
			local alert_filter = self._alert_filter or managers.groupai:state():get_unit_type_filter("civilians_enemies")
			local alert_unit = player or unit
			local alert_event = {
				"explosion",
				hit_pos,
				alert_radius,
				alert_filter,
				alert_unit
			}

			managers.groupai:state():propagate_alert(alert_event)
		end

		if Network:is_server() then
			managers.mission:call_global_event("tripmine_exploded")

			unit:set_slot(0)
		else
			unit:set_visible(false)
			unit:interaction():set_active(false)
		end
	end

	function TripMineBase:_can_stun_unit(unit)
		if not alive_g(unit) then
			return
		end

		local brain_ext = unit:brain()

		if brain_ext and brain_ext.is_hostage and brain_ext:is_hostage() then
			return false
		end

		local base_ext = unit:base()

		if base_ext and base_ext._tweak_table and base_ext.char_tweak then
			local char_tweak = base_ext:char_tweak()

			if char_tweak and not char_tweak.immune_to_concussion then
				return true
			end
		end

		return false
	end

	function TripMineBase:sync_trip_mine_explode(user_unit, ray_from, ray_to, damage_size, damage)
		local hit_pos = ray_from + ray_to * 5
		local payload_mode = self:_get_payload_mode()
		local unit = self._unit

		if payload_mode == "payload_explosive" then
			managers.explosion:give_local_player_dmg(hit_pos, damage_size, tweak_data.weapon.trip_mines.player_damage)
			self:_play_sound_and_effects(damage_size)

			if draw_sync_explosion_sphere then
				local draw_duration = 3
				local new_brush = Draw:brush(Color.red:with_alpha(0.5), draw_duration)
				new_brush:sphere(hit_pos, damage_size)
			end

			local bodies = unit:find_bodies("intersect", "sphere", hit_pos, damage_size, managers.slot:get_mask("explosion_targets"))
			local units_to_push = {}

			for i = 1, #bodies do
				local hit_body = bodies[i]

				if alive_g(hit_body) then
					local hit_unit = hit_body:unit()
					units_to_push[hit_unit:key()] = hit_unit

					if hit_unit:id() == -1 then
						local body_ext = hit_body:extension()
						local body_ext_dmg = body_ext and body_ext.damage

						if body_ext_dmg then
							local dir = hit_body:center_of_mass() - hit_pos
							dir = dir:normalized()

							local normal = dir
							local dmg = damage
							dmg = dmg > 200 and 200 or dmg
							dmg = math_ceil(dmg * 163.84) / 163.84

							local body_hit_pos = hit_body:position()

							body_ext_dmg:damage_explosion(user_unit, normal, body_hit_pos, dir, dmg)
							body_ext_dmg:damage_damage(user_unit, normal, body_hit_pos, dir, dmg)
						end
					end
				end
			end

			managers.explosion:units_to_push(units_to_push, hit_pos, 300)
		elseif payload_mode == "payload_incendiary" then
			self:_play_sound_and_effects(damage_size)
		elseif payload_mode == "payload_concussive" then
			managers.explosion:play_sound_and_effects(hit_pos, my_fwd, damage_size, {
				camera_shake_max_mul = 4,
				effect = "effects/particles/explosions/explosion_flash_grenade",
				sound_event = "flashbang_explosion", --or the normal "trip_mine_explode", but in that case should use at least some of the code in TripMineBase:_play_sound_and_effects() since it disposes of the soundsource afterward
				feedback_range = damage_size * 2
			})

			if Network:is_server() then
				local owner_peer = managers.network:session():peer(self._server_information.owner_peer_id)
				local owner_unit = owner_peer and owner_peer:unit()
				owner_unit = alive_g(owner_unit) and owner_unit or nil

				local alert_filter = owner_unit and owner_unit:movement():SO_access() or managers.groupai:state():get_unit_type_filter("civilians_enemies")
				local hit_units, splinters = managers.explosion:detect_and_stun({
					player_damage = 1,
					hit_pos = hit_pos,
					range = damage_size,
					collision_slotmask = managers.slot:get_mask("enemies"),
					curve_pow = 2,
					damage = self._CONCUSSION_DAMAGE,
					ignore_unit = unit,
					alert_filter = alert_filter,
					alert_radius = tweak_data.weapon.trip_mines.alert_radius,
					user = owner_unit or unit,
					verify_callback = callback(self, self, "_can_stun_unit")
				})
			end
		else
			log("TOTAL CRACKDOWN: TripMineBase:sync_trip_mine_explode(" .. tostring_g(payload_mode) .."): Unknown payload detonation type")
		end

		if Network:is_server() then
			managers.mission:call_global_event("tripmine_exploded")

			unit:set_slot(0)
		else
			unit:set_visible(false)
			unit:interaction():set_active(false)
		end
	end

else

	function TripMineBase:update(unit, t, dt)
		--if you wish to use debug drawing for whatever reason, use the code below
		--and comment out the 'if not self._owner then' block of code
		--[[self:_update_draw_laser()

		if self._explode_timer or not self._owner then
			if not self._use_draw_laser then
				self._unit:set_extension_update_enabled(ids_base, false)
			end

			return
		end]]

		if not self._owner then
			--just in case
			self._unit:set_extension_update_enabled(ids_base, false)

			return
		end

		if not self._armed then
			if self._sensor_upgrade then
				self:_sensor(t)

				local det_unit_last_t = self._sensor_last_unit_time

				if det_unit_last_t and det_unit_last_t < t then
					self._sensor_units_detected = nil
					self._sensor_last_unit_time = nil
				end
			end

			return
		end

		self:_check()
	end

	local _check_original = TripMineBase._check
	function TripMineBase:_check()
		_check_original(self)

		local explode_time = self._explode_timer

		if not explode_time then
			return
		end

		local my_unit = self._unit

		my_unit:interaction():set_active(false)
		my_unit:set_extension_update_enabled(ids_base, false)

		local explode_clbk_id = "_explode_clbk_id" .. tostring_g(my_unit:key())
		self._explode_clbk_id = explode_clbk_id

		managers.enemy:add_delayed_clbk(explode_clbk_id, callback(self, self, "_explode"), TimerManager:game():time() + explode_time)
	end

	local sync_trip_mine_beep_explode_original = TripMineBase.sync_trip_mine_beep_explode
	function TripMineBase:sync_trip_mine_beep_explode()
		sync_trip_mine_beep_explode_original(self)

		self._unit:interaction():set_active(false)
	end

	function TripMineBase:_explode()
		local activate_clbk_id = self._activate_clbk_id

		if activate_clbk_id then
			managers.enemy:remove_delayed_clbk(activate_clbk_id)

			self._activate_clbk_id = nil
		end

		local player_manager = managers.player
		local damage_size = tweak_data.weapon.trip_mines.damage_size * player_manager:upgrade_value("trip_mine", "explosion_size_multiplier_1", 1) * player_manager:upgrade_value("trip_mine", "damage_multiplier", 1)
		local player = player_manager:player_unit() or nil
		local my_pos = self._ray_from_pos
		local my_fwd = self._forward
		local hit_pos = my_pos + my_fwd * 5

		if draw_explosion_sphere then
			local draw_duration = 3
			local new_brush = Draw:brush(Color.red:with_alpha(0.5), draw_duration)
			new_brush:sphere(hit_pos, damage_size)
		end

		if draw_vanilla_explosion_cylinder then
			local draw_duration = 3
			local new_brush = Draw:brush(Color.blue:with_alpha(0.5), draw_duration)
			new_brush:cylinder(my_pos, self._ray_to_pos, damage_size)
		end

		managers.explosion:give_local_player_dmg(hit_pos, damage_size, tweak_data.weapon.trip_mines.player_damage)
		self:_play_sound_and_effects(damage_size)

		local unit = self._unit

		self._deactive_timer = 5

		local splinters = {
			mvec3_cpy(hit_pos)
		}
		local dirs = {
			Vector3(damage_size, 0, 0),
			Vector3(-damage_size, 0, 0),
			Vector3(0, damage_size, 0),
			Vector3(0, -damage_size, 0),
			Vector3(0, 0, damage_size),
			Vector3(0, 0, -damage_size)
		}

		local geometry_mask = managers.slot:get_mask("world_geometry")

		for i = 1, #dirs do
			local dir = dirs[i]
			local tmp_pos = hit_pos - dir
			local splinter_ray = unit:raycast("ray", hit_pos, tmp_pos, "slot_mask", geometry_mask)

			if splinter_ray then
				local ray_dis = splinter_ray.distance
				local dis = ray_dis > 10 and 10 or ray_dis

				tmp_pos = splinter_ray.position - dir:normalized() * dis
			end

			if draw_splinters then
				local draw_duration = 3
				local new_brush = Draw:brush(Color.white:with_alpha(0.5), draw_duration)
				new_brush:cylinder(hit_pos, tmp_pos, 0.5)
			end

			local near_other_splinter = nil

			for idx = 1, #splinters do
				local s_pos = splinters[idx]

				if mvec3_dis_sq(tmp_pos, s_pos) < 900 then
					near_other_splinter = true

					break
				end
			end

			if not near_other_splinter then
				splinters[#splinters + 1] = mvec3_cpy(tmp_pos)
			end
		end

		local units_to_hit, units_to_push = {}, {}
		local damage = tweak_data.weapon.trip_mines.damage * player_manager:upgrade_value("trip_mine", "damage_multiplier", 1)

		local slotmask = managers.slot:get_mask("explosion_targets")
		local bodies = unit:find_bodies("intersect", "sphere", hit_pos, damage_size, slotmask)
		local session = managers.network:session()

		for i = 1, #bodies do
			local hit_body = bodies[i]

			if alive_g(hit_body) then
				local hit_unit = hit_body:unit()
				local hit_unit_key = hit_unit:key()
				units_to_push[hit_unit_key] = hit_unit

				local char_dmg_ext = hit_unit:character_damage()
				local hit_character = char_dmg_ext and char_dmg_ext.damage_explosion and not char_dmg_ext:dead()
				local body_ext = hit_body:extension()
				local body_ext_dmg = body_ext and body_ext.damage
				local ray_hit, body_com, damage_character = nil

				if hit_character then
					if not units_to_hit[hit_unit_key] then
						body_com = hit_body:center_of_mass()

						for i = 1, #splinters do
							local s_pos = splinters[i]

							ray_hit = not unit:raycast("ray", s_pos, body_com, "slot_mask", geometry_mask, "report")

							if ray_hit then
								units_to_hit[hit_unit_key] = true
								damage_character = true

								if draw_splinter_hits then
									local draw_duration = 3
									local new_brush = Draw:brush(Color.green:with_alpha(0.5), draw_duration)
									new_brush:cylinder(s_pos, body_com, 0.5)
								end

								break
							elseif draw_obstructed_splinters then
								local draw_duration = 3
								local new_brush = Draw:brush(Color.yellow:with_alpha(0.5), draw_duration)
								new_brush:cylinder(s_pos, body_com, 0.5)
							end
						end
					end
				elseif body_ext_dmg or hit_body:dynamic() then
					if not units_to_hit[hit_unit_key] then
						ray_hit = true
						units_to_hit[hit_unit_key] = true
					end
				end

				if not ray_hit and body_ext_dmg and units_to_hit[hit_unit_key] and char_dmg_ext and char_dmg_ext.damage_explosion then
					body_com = body_com or hit_body:center_of_mass()

					for i = 1, #splinters do
						local s_pos = splinters[i]

						ray_hit = not unit:raycast("ray", s_pos, body_com, "slot_mask", geometry_mask, "report")

						if ray_hit then
							break
						end
					end
				end

				if ray_hit then
					body_com = body_com or hit_body:center_of_mass()
					local dir = body_com - hit_pos
					dir = dir:normalized()

					local dmg = damage
					local base_ext = hit_unit:base()

					if base_ext and base_ext.has_tag and base_ext:has_tag("tank") then
						dmg = dmg * 7
					end

					local body_hit_pos = nil

					if body_ext_dmg then
						local normal = dir
						local prop_damage = dmg > 200 and 200 or dmg
						local network_damage = math_ceil(prop_damage * 163.84)
						prop_damage = network_damage / 163.84

						body_hit_pos = mvec3_cpy(hit_body:position())

						body_ext_dmg:damage_explosion(player, normal, body_hit_pos, dir, prop_damage)
						body_ext_dmg:damage_damage(player, normal, body_hit_pos, dir, prop_damage)

						if session and hit_unit:id() ~= -1 then
							network_damage = network_damage > 32768 and 32768 or network_damage

							if player then
								session:send_to_peers_synched("sync_body_damage_explosion", hit_body, player, normal, body_hit_pos, dir, network_damage)
							else
								session:send_to_peers_synched("sync_body_damage_explosion_no_attacker", hit_body, normal, body_hit_pos, dir, network_damage)
							end
						end
					end

					if damage_character then
						body_hit_pos = body_hit_pos or mvec3_cpy(hit_body:position())

						--since sending the same col_ray table for all hits actually doesn't make much sense
						local accurate_col_ray = {
							position = body_hit_pos,
							ray = dir
						}

						self:_give_explosion_damage(accurate_col_ray, hit_unit, dmg)
					end
				end
			end
		end

		if player_manager:has_category_upgrade("trip_mine", "fire_trap") then
			local fire_trap_data = player_manager:upgrade_value("trip_mine", "fire_trap", nil)

			if fire_trap_data then
				self:_spawn_environment_fire(player, fire_trap_data[1], fire_trap_data[2])

				if session then
					session:send_to_peers_synched("sync_trip_mine_explode_spawn_fire", unit, player, my_pos, my_fwd, damage_size, damage, fire_trap_data[1], fire_trap_data[2])
				end
			end
		elseif session then
			if player then
				session:send_to_peers_synched("sync_trip_mine_explode", unit, player, my_pos, my_fwd, damage_size, damage)
			else
				session:send_to_peers_synched("sync_trip_mine_explode_no_user", unit, my_pos, my_fwd, damage_size, damage)
			end
		end

		managers.explosion:units_to_push(units_to_push, hit_pos, 300)

		local alert_radius = tweak_data.weapon.trip_mines.alert_radius
		local alert_filter = self._alert_filter or managers.groupai:state():get_unit_type_filter("civilians_enemies")
		local alert_unit = player or unit
		local alert_event = {
			"explosion",
			hit_pos,
			alert_radius,
			alert_filter,
			alert_unit
		}

		managers.groupai:state():propagate_alert(alert_event)

		if Network:is_server() then
			managers.mission:call_global_event("tripmine_exploded")

			unit:set_slot(0)
		else
			unit:set_visible(false)
			unit:interaction():set_active(false)
		end
	end

	function TripMineBase:sync_trip_mine_explode(user_unit, ray_from, ray_to, damage_size, damage)
		local hit_pos = ray_from + ray_to * 5

		managers.explosion:give_local_player_dmg(hit_pos, damage_size, tweak_data.weapon.trip_mines.player_damage)
		self:_play_sound_and_effects(damage_size)

		if draw_sync_explosion_sphere then
			local draw_duration = 3
			local new_brush = Draw:brush(Color.red:with_alpha(0.5), draw_duration)
			new_brush:sphere(hit_pos, damage_size)
		end

		local unit = self._unit
		local bodies = unit:find_bodies("intersect", "sphere", hit_pos, damage_size, managers.slot:get_mask("explosion_targets"))
		local units_to_push = {}

		for i = 1, #bodies do
			local hit_body = bodies[i]

			if alive_g(hit_body) then
				local hit_unit = hit_body:unit()
				units_to_push[hit_unit:key()] = hit_unit

				if hit_unit:id() == -1 then
					local body_ext = hit_body:extension()
					local body_ext_dmg = body_ext and body_ext.damage

					if body_ext_dmg then
						local dir = hit_body:center_of_mass() - hit_pos
						dir = dir:normalized()

						local normal = dir
						local dmg = damage
						local base_ext = hit_unit:base()

						if base_ext and base_ext.has_tag and base_ext:has_tag("tank") then
							dmg = dmg * 7
						end

						dmg = dmg > 200 and 200 or dmg
						dmg = math_ceil(dmg * 163.84) / 163.84

						local body_hit_pos = hit_body:position()

						body_ext_dmg:damage_explosion(user_unit, normal, body_hit_pos, dir, dmg)
						body_ext_dmg:damage_damage(user_unit, normal, body_hit_pos, dir, dmg)
					end
				end
			end
		end

		managers.explosion:units_to_push(units_to_push, hit_pos, 300)

		if Network:is_server() then
			managers.mission:call_global_event("tripmine_exploded")

			unit:set_slot(0)
		else
			unit:set_visible(false)
			unit:interaction():set_active(false)
		end
	end

end
