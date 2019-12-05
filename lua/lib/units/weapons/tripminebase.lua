function TripMineBase:_explode(col_ray)
	if not managers.network:session() then
		return
	end

	local damage_size = tweak_data.weapon.trip_mines.damage_size * managers.player:upgrade_value("trip_mine", "explosion_size_multiplier_1", 1) * managers.player:upgrade_value("trip_mine", "damage_multiplier", 1)
	local player = managers.player:player_unit()
	local my_pos = self._ray_from_pos
	local my_fwd = self._forward

	managers.explosion:give_local_player_dmg(my_pos, damage_size, tweak_data.weapon.trip_mines.player_damage)
	self._unit:set_extension_update_enabled(Idstring("base"), false)
	self._deactive_timer = 5
	self:_play_sound_and_effects(damage_size)

	local hit_pos = Vector3()

	mvector3.set(hit_pos, my_fwd)
	mvector3.multiply(hit_pos, 5)
	mvector3.add(hit_pos, my_pos)

	local slotmask = managers.slot:get_mask("explosion_targets")
	local bodies = World:find_bodies("intersect", "sphere", hit_pos, damage_size, slotmask)
	local splinters = {
		mvector3.copy(hit_pos)
	}
	local dirs = {
		Vector3(damage_size, 0, 0),
		Vector3(-damage_size, 0, 0),
		Vector3(0, damage_size, 0),
		Vector3(0, -damage_size, 0),
		Vector3(0, 0, damage_size),
		Vector3(0, 0, -damage_size)
	}
	local pos = Vector3()

	for _, dir in ipairs(dirs) do
		mvector3.set(pos, dir)
		mvector3.add(pos, hit_pos)

		local splinter_ray = World:raycast("ray", hit_pos, pos, "slot_mask", managers.slot:get_mask("world_geometry"))

		pos = (splinter_ray and splinter_ray.position or pos) - dir:normalized() * math.min(splinter_ray and splinter_ray.distance or 0, 10)
		local near_splinter = false

		for _, s_pos in ipairs(splinters) do
			if mvector3.distance_sq(pos, s_pos) < 900 then
				near_splinter = true

				break
			end
		end

		if not near_splinter then
			table.insert(splinters, mvector3.copy(pos))
		end
	end

	local units_to_hit = {}
	local units_to_push = {}
	local damage = tweak_data.weapon.trip_mines.damage * managers.player:upgrade_value("trip_mine", "damage_multiplier", 1)

	for _, hit_body in ipairs(bodies) do
		if alive(hit_body) then
			units_to_push[hit_body:unit():key()] = hit_body:unit()
			local character = hit_body:unit():character_damage() and hit_body:unit():character_damage().damage_explosion and not hit_body:unit():character_damage():dead()
			local apply_dmg = hit_body:extension() and hit_body:extension().damage
			local dir, ray_hit, damage_character = nil
			local dmg = damage

			if character then
				if not units_to_hit[hit_body:unit():key()] then
					for i_splinter, s_pos in ipairs(splinters) do
						ray_hit = not World:raycast("ray", s_pos, hit_body:center_of_mass(), "slot_mask", managers.slot:get_mask("world_geometry"), "report")

						if ray_hit then
							units_to_hit[hit_body:unit():key()] = true
							damage_character = true

							break
						end
					end
				end
			elseif apply_dmg or hit_body:dynamic() then
				if not units_to_hit[hit_body:unit():key()] then
					ray_hit = true
					units_to_hit[hit_body:unit():key()] = true
				end
			end

			if not ray_hit and units_to_hit[hit_body:unit():key()] and apply_dmg and character then
				for i_splinter, s_pos in ipairs(splinters) do
					ray_hit = not World:raycast("ray", s_pos, hit_body:center_of_mass(), "slot_mask", managers.slot:get_mask("world_geometry"), "report")

					if ray_hit then
						break
					end
				end
			end

			if ray_hit then
				dir = hit_body:center_of_mass()
				mvector3.direction(dir, hit_pos, dir)

				if apply_dmg then
					local normal = dir
					local prop_damage = math.min(dmg, 200)
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

				if character and damage_character then
					local hit_unit = hit_body:unit()

					if hit_unit:base() and hit_unit:base().has_tag and hit_unit:base():has_tag("tank") then
						dmg = dmg * 7
					end

					self:_give_explosion_damage(col_ray, hit_unit, dmg)
				end
			end
		end
	end

	local det_pos = self._ray_from_pos

	managers.explosion:units_to_push(units_to_push, det_pos, 300)

	if managers.network:session() then
		if managers.player:has_category_upgrade("trip_mine", "fire_trap") then
			local fire_trap_data = managers.player:upgrade_value("trip_mine", "fire_trap", nil)

			if fire_trap_data then
				managers.network:session():send_to_peers_synched("sync_trip_mine_explode_spawn_fire", self._unit, player, self._ray_from_pos, self._forward, damage_size, damage, fire_trap_data[1], fire_trap_data[2])
				self:_spawn_environment_fire(player, fire_trap_data[1], fire_trap_data[2])
			end
		elseif player then
			managers.network:session():send_to_peers_synched("sync_trip_mine_explode", self._unit, player, self._ray_from_pos, self._forward, damage_size, damage)
		else
			managers.network:session():send_to_peers_synched("sync_trip_mine_explode_no_user", self._unit, self._ray_from_pos, self._forward, damage_size, damage)
		end
	end

	local alert_filter = self._alert_filter or managers.groupai:state():get_unit_type_filter("civilians_enemies")
	local alert_unit = player or self._unit
	local alert_pos = self._ray_from_pos
	local alert_event = {
		"explosion",
		alert_pos,
		tweak_data.weapon.trip_mines.alert_radius,
		alert_filter,
		alert_unit
	}

	managers.groupai:state():propagate_alert(alert_event)

	if Network:is_server() then
		managers.mission:call_global_event("tripmine_exploded")
		Application:error("TRIPMINE EXPLODED")
	end

	self._unit:set_slot(0)
end

function TripMineBase:sync_trip_mine_explode(user_unit, ray_from, ray_to, damage_size, damage)
	local range = damage_size
	local my_pos = ray_from
	local my_fwd = ray_to

	managers.explosion:give_local_player_dmg(my_pos, range, tweak_data.weapon.trip_mines.player_damage)
	self:_play_sound_and_effects(range)

	local hit_pos = Vector3()

	mvector3.set(hit_pos, my_fwd)
	mvector3.multiply(hit_pos, 5)
	mvector3.add(hit_pos, my_pos)

	local slotmask = managers.slot:get_mask("explosion_targets")
	local bodies = World:find_bodies("intersect", "sphere", hit_pos, range, slotmask)
	local units_to_push = {}

	for _, hit_body in ipairs(bodies) do
		if alive(hit_body) then
			units_to_push[hit_body:unit():key()] = hit_body:unit()
			local apply_dmg = hit_body:extension() and hit_body:extension().damage and hit_body:unit():id() == -1

			if apply_dmg then
				local dir = hit_body:center_of_mass()
				mvector3.direction(dir, hit_pos, dir)

				local normal = dir
				local prop_damage = math.min(damage, 200)

				hit_body:extension().damage:damage_explosion(user_unit, normal, hit_body:position(), dir, prop_damage)
				hit_body:extension().damage:damage_damage(user_unit, normal, hit_body:position(), dir, prop_damage)
			end
		end
	end

	local det_pos = ray_from

	managers.explosion:units_to_push(units_to_push, det_pos, 300)

	if Network:is_server() then
		managers.mission:call_global_event("tripmine_exploded")
		Application:error("TRIPMINE EXPLODED")
	end

	self._unit:set_slot(0)
end

function TripMineBase:_play_sound_and_effects(range)
	local custom_params = {
		camera_shake_max_mul = 4,
		sound_muffle_effect = true,
		sound_event = "no_sound",
		effect = "effects/particles/explosions/explosion_grenade",
		feedback_range = range * 2
	}

	managers.explosion:play_sound_and_effects(self._position, self._unit:rotation():y(), range, custom_params)

	local sound_source = SoundDevice:create_source("TripMineBase")

	sound_source:set_position(self._unit:position())
	sound_source:post_event("trip_mine_explode")
	managers.enemy:add_delayed_clbk("TrMiexpl", callback(TripMineBase, TripMineBase, "_dispose_of_sound", {
		sound_source = sound_source
	}), TimerManager:game():time() + 4)
end

function TripMineBase:_give_explosion_damage(col_ray, unit, damage)
	local action_data = {
		variant = "explosion",
		damage = damage,
		attacker_unit = managers.player:player_unit(),
		weapon_unit = self._unit,
		col_ray = col_ray,
		owner = managers.player:player_unit(),
		owner_peer_id = self._owner_peer_id
	}
	local defense_data = unit:character_damage():damage_explosion(action_data)

	return defense_data
end
