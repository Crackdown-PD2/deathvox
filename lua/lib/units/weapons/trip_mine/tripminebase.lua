if deathvox:IsTotalCrackdownEnabled() then 
			
--new methods
	function TripMineBase:_get_trigger_mode()
		return self._trigger_mode
	end

	function TripMineBase:_get_payload_mode()
		return self._payload_mode
	end

	function TripMineBase:set_trigger_mode(mode) --local
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
			self._trigger_mode = mode
		else
			log("TOTAL CRACKDOWN: TripMineBase:_set_trigger_mode(" .. tostring(mode) .. "): Unknown trigger mode")
			return
		end
	end
	
	function TripMineBase:set_payload_mode(mode) --local
		if self:is_owner() and mode ~= self:_get_payload_mode() then 
			self:_set_payload_mode(mode)
			self:sync_send_payload_mode(mode)
		end
	end

	function TripMineBase:_set_payload_mode(mode)
		if mode and TripmineControlMenu.VALID_TRIPMINE_PAYLOAD_MODES[mode] then
			self._payload_mode = mode
			self:set_armed(mode ~= "payload_sensor")
		else
			log("TOTAL CRACKDOWN: TripMineBase:_set_payload_mode(" .. tostring(mode) .. "): Unknown payload mode")
			return
		end
	end

	function TripMineBase:sync_send_trigger_mode(mode)
		--self._unit:network():send(self.NETWORK_SPOOF_ID,"_set_trigger_mode",0,mode) 
		--unit doesn't have network extension or else this would work great

		local session = managers.network:session()
		if self:is_owner() and session then 
			local mode_sync_id = mode and TripmineControlMenu.NetworkSyncIDsReverseLookup[mode]
			if mode_sync_id then 
				session:send_to_peers_synched(TripmineControlMenu.NETWORK_SPOOF_ID, self._unit, managers.player:local_player(), self._ray_from_pos, self._ray_to_pos, 0, 0, mode_sync_id, 0)
			else
				log("TOTAL CRACKDOWN: TripMineBase:sync_send_trigger_mode(" .. tostring(mode) .. "): Unknown mode network id")
				return
			end
		end
	end
	
	function TripMineBase:sync_send_payload_mode(mode)
		--self._unit:network():send(self.NETWORK_SPOOF_ID,"_set_payload_mode",0,mode)
		local session = managers.network:session()
		if self:is_owner() and session then 
			local mode_sync_id = mode and TripmineControlMenu.NetworkSyncIDsReverseLookup[mode]
			if mode_sync_id then 
				session:send_to_peers_synched(TripmineControlMenu.NETWORK_SPOOF_ID, self._unit, managers.player:local_player(), self._ray_from_pos, self._ray_to_pos, 0, 0, mode_sync_id, 1)
			else
				log("TOTAL CRACKDOWN: TripMineBase:sync_send_payload_mode(" .. tostring(mode) .. "): Unknown mode network id")
				return
			end
		end
	end
	
	function TripMineBase:is_owner()
		return managers.network:session() and self._owner_peer_id == managers.network:session():local_peer():id()
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
		
		unit:interaction():set_disabled(peer_id and (peer_id ~= managers.network:session():local_peer():id())) --only the owner can change the tripmine

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
			self._validate_clbk_id = "trip_mine_validate" .. tostring(unit:key())

			managers.enemy:add_delayed_clbk(self._validate_clbk_id, callback(self, self, "_clbk_validate"), Application:time() + 60)
		end

		managers.player:send_message("trip_mine_placed", nil, self._unit)
	end

	function TripMineBase:setup(sensor_upgrade)
		self._slotmask = managers.slot:get_mask("trip_mine_targets")
		self._first_armed = false
		self._armed = false

		if sensor_upgrade then
			self._startup_armed = not managers.groupai:state():whisper_mode()
		else
			self._startup_armed = true
		end

		self._sensor_upgrade = sensor_upgrade

		self:set_active(false)
		self._unit:sound_source():post_event("trip_mine_attach")

		self._unit:contour():add("deployable_interactable")
		
		
		--offy wuz hear
		self._trigger_mode = TripmineControlMenu.DEFAULT_TRIGGER_MODE
		self._payload_mode = managers.groupai:state():whisper_mode() and "payload_sensor" or TripmineControlMenu.DEFAULT_PAYLOAD_MODE
	end
	
	function TripMineBase:update(unit, t, dt)
		self:_update_draw_laser()

		if not self._owner then
			return
		end
		
		local payload_mode = self:_get_payload_mode()
		
		self:_check_body()

		if self._explode_timer then
			self._explode_timer = self._explode_timer - dt

			if self._explode_timer <= 0 then
				self:_explode(self._explode_ray)

				return
			end
		end

		if self._activate_timer then
			self._activate_timer = self._activate_timer - dt

			if self._activate_timer <= 0 then
				self._activate_timer = nil

				self:set_armed(self._startup_armed)

				self._startup_armed = nil
			end

			return
		end

		if self._deactive_timer then
			self._deactive_timer = self._deactive_timer - dt

			if self._deactive_timer <= 0 then
				self._deactive_timer = nil
			end

			return
		end

		if payload_mode == "payload_sensor" then
			self:_sensor(t)

			if self._sensor_units_detected and self._sensor_last_unit_time and self._sensor_last_unit_time < t then
				self._sensor_units_detected = nil
				self._sensor_last_unit_time = nil
			end

			return
		end

		if not self._explode_timer then
			self:_check()
		end
	end

	function TripMineBase:_sensor(t)
		local ray = self:_raycast()

		if ray and ray.unit and not tweak_data.character[ray.unit:base()._tweak_table].is_escort then
			self._sensor_units_detected = self._sensor_units_detected or {}

			if not self._sensor_units_detected[ray.unit:key()] then
				self._sensor_units_detected[ray.unit:key()] = true

				if (self:_get_trigger_mode() ~= "trigger_special") or (managers.groupai:state():whisper_mode() and tweak_data.character[ray.unit:base()._tweak_table].silent_priority_shout or tweak_data.character[ray.unit:base()._tweak_table].priority_shout) then 
				--or managers.groupai:state():is_enemy_special(ray.unit)
					managers.game_play_central:auto_highlight_enemy(ray.unit, true)
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
		if not managers.network:session() then
			return
		end

		local ray = self:_raycast()

		if ray and ray.unit and not tweak_data.character[ray.unit:base()._tweak_table].is_escort then
			if ray.unit:movement() and ray.unit:movement():team() then
				local team_id_player = tweak_data.levels:get_default_team_ID("player")
				local team_id_ray = ray.unit:movement():team().id

				if not managers.groupai:state():team_data(team_id_player).foes[team_id_ray] then
					return
				end
			end
			if (self:_get_trigger_mode() ~= "trigger_special") or managers.groupai:state():is_enemy_special(ray.unit) then 
				self._explode_timer = tweak_data.weapon.trip_mines.delay + managers.player:upgrade_value("trip_mine", "explode_timer_delay", 0)
				self._explode_ray = ray

				self._unit:sound_source():post_event("trip_mine_beep_explode")

				if managers.network:session() then
					managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", TripMineBase.EVENT_IDS.explosion_beep)
				end
			end
		end
	end
	
	function TripMineBase:explode()
		if not self._active then
			return
		end
		
		if self._payload_mode == "payload_sensor" then 
		--self._active is used to check whether the unit is doing anything, basically, including its regular extension update
		--so check for the sensor mode manually here instead of doing set_active() when toggling sensor mode
			return
		end

		self._active = false
		local col_ray = {
			ray = self._forward,
			position = self._position
		}

		self:_explode(col_ray)
	end

	function TripMineBase:_explode(col_ray)
		if not managers.network:session() then
			return
		end
		
		
		local player = managers.player:player_unit()
		local slotmask = managers.slot:get_mask("explosion_targets")
		local damage = tweak_data.weapon.trip_mines.damage * managers.player:upgrade_value("trip_mine", "damage_multiplier", 1)
		local damage_size = tweak_data.weapon.trip_mines.damage_size * managers.player:upgrade_value("trip_mine", "explosion_size_multiplier_1", 1) * managers.player:upgrade_value("trip_mine", "damage_multiplier", 1)
		local bodies = World:find_bodies("intersect", "cylinder", self._ray_from_pos, self._ray_to_pos, damage_size, slotmask)
		
		local function explosion_aoe()
			local characters_hit = {}

			managers.explosion:give_local_player_dmg(self._position, damage_size, tweak_data.weapon.trip_mines.player_damage)
			self._unit:set_extension_update_enabled(Idstring("base"), false)

			self._deactive_timer = 5

			self:_play_sound_and_effects()

			for _, hit_body in ipairs(bodies) do
				if alive(hit_body) then
					local character = hit_body:unit():character_damage() and hit_body:unit():character_damage().damage_explosion
					local apply_dmg = hit_body:extension() and hit_body:extension().damage
					local dir, ray_hit = nil

					if character and not characters_hit[hit_body:unit():key()] then
						local com = hit_body:center_of_mass()
						local ray_from = math.point_on_line(self._ray_from_pos, self._ray_to_pos, com)
						ray_hit = not World:raycast("ray", ray_from, com, "slot_mask", slotmask, "ignore_unit", {
							hit_body:unit()
						}, "report")

						if ray_hit then
							characters_hit[hit_body:unit():key()] = true
						end
					elseif apply_dmg or hit_body:dynamic() then
						ray_hit = true
					end

					if ray_hit then
						dir = hit_body:center_of_mass()

						mvector3.direction(dir, self._ray_from_pos, dir)

						if apply_dmg then
							local normal = dir
							local prop_damage = math.min(damage, 200)
							local network_damage = math.ceil(prop_damage * 163.84)
							prop_damage = network_damage / 163.84

							hit_body:extension().damage:damage_explosion(player, normal, hit_body:position(), dir, prop_damage)
							hit_body:extension().damage:damage_damage(player, normal, hit_body:position(), dir, prop_damage)

							if hit_body:unit():id() ~= -1 then
								if player then
									managers.network:session():send_to_peers_synched("sync_body_damage_explosion", hit_body, player, normal, hit_body:position(), dir, math.min(32768, network_damage))
								else
									managers.network:session():send_to_peers_synched("sync_body_damage_explosion_no_attacker", hit_body, normal, hit_body:position(), dir, math.min(32768, network_damage))
								end
							end
						end

						if hit_body:unit():in_slot(managers.game_play_central._slotmask_physics_push) then
							hit_body:unit():push(5, dir * 500)
						end

						if character then
							self:_give_explosion_damage(col_ray, hit_body:unit(), damage)
						end
					end
				end
			end
		end
		
		local payload_mode = self:_get_payload_mode()
		if payload_mode == "payload_explosive" then 

			explosion_aoe()

			if managers.network:session() then
				if player then
					managers.network:session():send_to_peers_synched("sync_trip_mine_explode", self._unit, player, self._ray_from_pos, self._ray_to_pos, damage_size, damage)
				else
					managers.network:session():send_to_peers_synched("sync_trip_mine_explode_no_user", self._unit, self._ray_from_pos, self._ray_to_pos, damage_size, damage)
				end
			end
		elseif payload_mode == "payload_incendiary" then 
		
--			explosion_aoe()
			
			self:_play_sound_and_effects()
			
			--see enveffecttweakdata to change values
			local added_time = 0
			local range_multiplier = 1
			if managers.network:session() then
				managers.network:session():send_to_peers_synched("sync_trip_mine_explode_spawn_fire", self._unit, player, self._ray_from_pos, self._ray_to_pos, damage_size, damage, added_time, range_multiplier)
				self:_spawn_environment_fire(player, added_time, range_multiplier)
			end
		elseif payload_mode == "payload_concussive" then 
			local owner_peer = self._owner_peer_id and managers.network:session():peer(self._owner_peer_id)
			local owner_user = owner_peer and owner_peer._unit or player
			managers.explosion:play_sound_and_effects(self._position, self._forward:normalized(), damage_size, {
				camera_shake_max_mul = 4,
				effect = "effects/particles/explosions/explosion_flash_grenade",
				sound_event = "flashbang_explosion", --or the normal "trip_mine_explode", but in that case should use at least some of the code in TripMineBase:_play_sound_and_effects() since it disposes of the soundsource afterward
				feedback_range = damage_size * 2
			})
			local hit_units, splinters = managers.explosion:detect_and_stun({
				player_damage = 1,
				hit_pos = self._position,--self._unit:position() + (self._forward:normalized() * 1), --without this workaround, the tripmine is ever so slightly inside the surface it's stuck to and fails the line-of-sight check; but apparently we should use self._position instead, which accounts for this issue
				range = damage_size,
				collision_slotmask = managers.slot:get_mask("enemies"),
				curve_pow = 2,
				damage = self._CONCUSSION_DAMAGE,
				ignore_unit = self._unit,
				alert_radius = tweak_data.weapon.trip_mines.alert_radius,
				user = owner_user
--,				verify_callback = function(hit_unit) end
			})
		else
			log("TOTAL CRACKDOWN: TripMineBase:_explode(" .. tostring(payload_mode) .."): Unknown payload detonation type")
			return
		end


		local alert_event = {
			"aggression",
			self._position,
			tweak_data.weapon.trip_mines.alert_radius,
			self._alert_filter,
			self._unit
		}

		managers.groupai:state():propagate_alert(alert_event)

		if Network:is_server() then
			managers.mission:call_global_event("tripmine_exploded")
--			Application:error("TRIPMINE EXPLODED")
		end

		self._unit:set_slot(0)
	end
	

	
	
end









