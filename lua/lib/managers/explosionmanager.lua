local idstr_small_light_fire = Idstring("effects/particles/fire/small_light_fire")
local idstr_explosion_std = Idstring("explosion_std")
local empty_idstr = Idstring("")
local molotov_effect = "effects/payday2/particles/explosions/molotov_grenade"
local tmp_vec3 = Vector3()

function ExplosionManager:detect_and_stun(params)
	local hit_pos = params.hit_pos
	local slotmask = params.collision_slotmask
	local user_unit = params.user
	local damage = params.damage
	local player_dmg = params.player_damage or dmg
	local range = params.range
	local ignore_unit = params.ignore_unit
	local curve_pow = params.curve_pow
	local col_ray = params.col_ray
	local alert_filter = params.alert_filter or managers.groupai:state():get_unit_type_filter("civilians_enemies")
	local owner = params.owner
	local push_units = false
	local results = {}
	local alert_radius = params.alert_radius or 10000

	if params.push_units ~= nil then
		push_units = params.push_units
	end

	local bodies = World:find_bodies("intersect", "sphere", hit_pos, range, slotmask)
	local splinters = {
		mvector3.copy(hit_pos)
	}
	local dirs = {
		Vector3(range, 0, 0),
		Vector3(-range, 0, 0),
		Vector3(0, range, 0),
		Vector3(0, -range, 0),
		Vector3(0, 0, range),
		Vector3(0, 0, -range)
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

	local count_cops = 0
	local count_gangsters = 0
	local count_civilians = 0
	local count_cop_kills = 0
	local count_gangster_kills = 0
	local count_civilian_kills = 0
	local units_to_hit = {}
	local units_to_push = {}
	local hit_units = {}
	local type = nil

	for _, hit_body in ipairs(bodies) do
		if alive(hit_body) and ignore_unit ~= hit_body:unit() then
			units_to_push[hit_body:unit():key()] = hit_body:unit()
			local character = hit_body:unit():character_damage() and hit_body:unit():character_damage().stun_hit and not hit_body:unit():character_damage():dead()
			local ray_hit = nil

			if character and not units_to_hit[hit_body:unit():key()] then
				local can_stun = not params.verify_callback

				if params.verify_callback then
					local character_unit = hit_body:unit()

					can_stun = params.verify_callback(character_unit)
				end

				if can_stun then
					if params.no_raycast_check_characters then
						ray_hit = true
						units_to_hit[hit_body:unit():key()] = true
					else
						for i_splinter, s_pos in ipairs(splinters) do
							ray_hit = not World:raycast("ray", s_pos, hit_body:center_of_mass(), "slot_mask", managers.slot:get_mask("world_geometry"), "report")

							if ray_hit then
								units_to_hit[hit_body:unit():key()] = true

								break
							end
						end
					end
				end
			end

			if ray_hit then
				local hit_unit = hit_body:unit()

				hit_units[hit_unit:key()] = hit_unit

				if owner and hit_unit:base() and hit_unit:base()._tweak_table and not hit_unit:character_damage():dead() then
					type = hit_unit:base()._tweak_table

					if CopDamage.is_civilian(type) then
						count_civilians = count_civilians + 1
					elseif CopDamage.is_gangster(type) then
						count_gangsters = count_gangsters + 1
					elseif not managers.groupai:state():is_unit_team_AI(hit_unit) then
						count_cops = count_cops + 1
					end
				end

				local dir = hit_body:center_of_mass()
				mvector3.direction(dir, hit_pos, dir)

				local dead_before = hit_unit:character_damage():dead()
				local action_data = {
					variant = "stun",
					damage = damage,
					attacker_unit = user_unit,
					weapon_unit = owner,
					col_ray = self._col_ray or {
						position = hit_body:position(),
						ray = dir
					}
				}

				hit_unit:character_damage():stun_hit(action_data)

				if owner and not dead_before and hit_unit:base() and hit_unit:base()._tweak_table and hit_unit:character_damage():dead() then
					type = hit_unit:base()._tweak_table

					if CopDamage.is_civilian(type) then
						count_civilian_kills = count_civilian_kills + 1
					elseif CopDamage.is_gangster(type) then
						count_gangster_kills = count_gangster_kills + 1
					elseif not managers.groupai:state():is_unit_team_AI(hit_unit) then
						count_cop_kills = count_cop_kills + 1
					end
				end
			end
		end
	end

	if push_units and push_units == true then
		local det_pos = params.hit_pos
		local push_range = params.range

		managers.explosion:units_to_push(units_to_push, det_pos, push_range)
	end

	local alert_unit = user_unit
	local alert_pos = params.hit_pos

	if alive(alert_unit) and alert_unit:base() and alert_unit:base().thrower_unit then
		alert_unit = alert_unit:base():thrower_unit()
	end

	managers.groupai:state():propagate_alert({
		"explosion",
		alert_pos,
		alert_radius,
		alert_filter,
		alert_unit
	})

	if owner then
		results.count_cops = count_cops
		results.count_gangsters = count_gangsters
		results.count_civilians = count_civilians
		results.count_cop_kills = count_cop_kills
		results.count_gangster_kills = count_gangster_kills
		results.count_civilian_kills = count_civilian_kills
	end

	return hit_units, splinters, results
end

function ExplosionManager:detect_and_give_dmg(params)
	local hit_pos = params.hit_pos
	local slotmask = params.collision_slotmask
	local user_unit = params.user
	local dmg = params.damage
	local player_dmg = params.player_damage or dmg
	local range = params.range
	local ignore_unit = params.ignore_unit
	local curve_pow = params.curve_pow
	local col_ray = params.col_ray
	local alert_filter = params.alert_filter or managers.groupai:state():get_unit_type_filter("civilians_enemies")
	local owner = params.owner
	local push_units = true
	local results = {}
	local alert_radius = params.alert_radius or 10000

	if params.push_units ~= nil then
		push_units = params.push_units
	end

	local player = managers.player:player_unit()

	if player_dmg ~= 0 and alive(player) then
		player:character_damage():damage_explosion({
			variant = "explosion",
			position = hit_pos,
			range = range,
			damage = player_dmg,
			ignite_character = params.ignite_character
		})
	end

	local bodies = World:find_bodies("intersect", "sphere", hit_pos, range, slotmask)
	local splinters = {
		mvector3.copy(hit_pos)
	}
	local dirs = {
		Vector3(range, 0, 0),
		Vector3(-range, 0, 0),
		Vector3(0, range, 0),
		Vector3(0, -range, 0),
		Vector3(0, 0, range),
		Vector3(0, 0, -range)
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

	local count_cops = 0
	local count_gangsters = 0
	local count_civilians = 0
	local count_cop_kills = 0
	local count_gangster_kills = 0
	local count_civilian_kills = 0
	local units_to_hit = {}
	local units_to_push = {}
	local hit_units = {}
	local type = nil

	for _, hit_body in ipairs(bodies) do
		if alive(hit_body) and ignore_unit ~= hit_body:unit() then
			units_to_push[hit_body:unit():key()] = hit_body:unit()
			local character = hit_body:unit():character_damage() and hit_body:unit():character_damage().damage_explosion and not hit_body:unit():character_damage():dead()
			local apply_dmg = hit_body:extension() and hit_body:extension().damage
			local dir, len, damage, ray_hit, damage_character = nil
			--local dmg_mul = 1

			if character then
				if not units_to_hit[hit_body:unit():key()] then
					if params.no_raycast_check_characters then
						ray_hit = true
						units_to_hit[hit_body:unit():key()] = true
						damage_character = true
					else
						for i_splinter, s_pos in ipairs(splinters) do
							ray_hit = not World:raycast("ray", s_pos, hit_body:center_of_mass(), "slot_mask", managers.slot:get_mask("world_geometry"), "report")

							if ray_hit then
								units_to_hit[hit_body:unit():key()] = true
								damage_character = true

								--shield explosion damage mitigation
								--[[local det_pos = params.hit_pos
								local e_center_of_mass = hit_body:unit():body("body"):center_of_mass()
								local shield_ray = World:raycast("ray", det_pos, e_center_of_mass, "slot_mask", managers.slot:get_mask("enemy_shield_check"))

								if shield_ray and alive(shield_ray.unit:parent()) then
									local p_unit = shield_ray.unit:parent()
									local p_unit_dmg = p_unit:character_damage()

									if p_unit_dmg and p_unit_dmg.dead and not p_unit_dmg:dead() then
										if hit_body:unit() == p_unit then
											if p_unit:base():char_tweak().damage.shield_explosion_damage_mul then
												dmg_mul = p_unit:base():char_tweak().damage.shield_explosion_damage_mul
											else
												dmg_mul = 0.25
											end
										else
											if p_unit:base():char_tweak().damage.shield_explosion_ally_damage_mul then
												dmg_mul = p_unit:base():char_tweak().damage.shield_explosion_ally_damage_mul
											else
												dmg_mul = 0.5
											end
										end
									end
								end]]

								break
							end
						end
					end

					if owner and ray_hit then
						local hit_unit = hit_body:unit()

						if hit_unit:base() and hit_unit:base()._tweak_table and not hit_unit:character_damage():dead() then
							type = hit_unit:base()._tweak_table

							if CopDamage.is_civilian(type) then
								count_civilians = count_civilians + 1
							elseif CopDamage.is_gangster(type) then
								count_gangsters = count_gangsters + 1
							elseif not managers.groupai:state():is_unit_team_AI(hit_unit) then
								count_cops = count_cops + 1
							end
						end
					end
				end
			elseif apply_dmg or hit_body:dynamic() then
				if not units_to_hit[hit_body:unit():key()] then
					ray_hit = true
					units_to_hit[hit_body:unit():key()] = true
				end
			end

			if not ray_hit and units_to_hit[hit_body:unit():key()] and apply_dmg and hit_body:unit():character_damage() and hit_body:unit():character_damage().damage_explosion then
				if params.no_raycast_check_characters then
					ray_hit = true
				else
					for i_splinter, s_pos in ipairs(splinters) do
						ray_hit = not World:raycast("ray", s_pos, hit_body:center_of_mass(), "slot_mask", managers.slot:get_mask("world_geometry"), "report")

						if ray_hit then
							break
						end
					end
				end
			end

			if ray_hit then
				local hit_unit = hit_body:unit()

				hit_units[hit_unit:key()] = hit_unit
				dir = hit_body:center_of_mass()
				len = mvector3.direction(dir, hit_pos, dir)
				damage = dmg * math.pow(math.clamp(1 - len / range, 0, 1), curve_pow)
				--damage = damage * dmg_mul

				if apply_dmg then
					local prop_damage = damage

					if 1 - len / range < -5 then
						prop_damage = math.max(damage, 1)
					end

					self:_apply_body_damage(true, hit_body, user_unit, dir, prop_damage)
				end

				--[[if dmg_mul ~= 0 then
					damage = math.max(damage, 1)
				end]]

				damage = math.max(damage, 1)

				if character and damage_character then
					local dead_before = hit_unit:character_damage():dead()
					local action_data = {
						variant = "explosion",
						damage = damage,
						attacker_unit = user_unit,
						weapon_unit = owner,
						col_ray = self._col_ray or {
							position = hit_body:position(),
							ray = dir
						},
						ignite_character = params.ignite_character
					}

					hit_unit:character_damage():damage_explosion(action_data)

					if owner and not dead_before and hit_unit:base() and hit_unit:base()._tweak_table and hit_unit:character_damage():dead() then
						type = hit_unit:base()._tweak_table

						if CopDamage.is_civilian(type) then
							count_civilian_kills = count_civilian_kills + 1
						elseif CopDamage.is_gangster(type) then
							count_gangster_kills = count_gangster_kills + 1
						elseif not managers.groupai:state():is_unit_team_AI(hit_unit) then
							count_cop_kills = count_cop_kills + 1
						end
					end
				end
			end
		end
	end

	if push_units and push_units == true then
		local det_pos = params.hit_pos
		local push_range = params.range

		managers.explosion:units_to_push(units_to_push, det_pos, push_range)
	end

	local alert_unit = user_unit
	local alert_pos = params.hit_pos

	if alive(alert_unit) and alert_unit:base() and alert_unit:base().thrower_unit then
		alert_unit = alert_unit:base():thrower_unit()
	end

	managers.groupai:state():propagate_alert({
		"explosion",
		alert_pos,
		alert_radius,
		alert_filter,
		alert_unit
	})

	if owner then
		results.count_cops = count_cops
		results.count_gangsters = count_gangsters
		results.count_civilians = count_civilians
		results.count_cop_kills = count_cop_kills
		results.count_gangster_kills = count_gangster_kills
		results.count_civilian_kills = count_civilian_kills
	end

	return hit_units, splinters, results
end

function ExplosionManager:units_to_push(units_to_push, hit_pos, range)
	range = math.min(range, 500)

	for u_key, unit in pairs(units_to_push) do
		if alive(unit) then
			local is_character = unit:character_damage() and unit:character_damage().damage_explosion

			if not is_character or unit:character_damage():dead() then
				if is_character and unit:movement() and unit:movement()._active_actions and unit:movement()._active_actions[1] and unit:movement()._active_actions[1]:type() == "hurt" then
					unit:movement()._active_actions[1]:force_ragdoll()
				end

				local nr_u_bodies = unit:num_bodies()
				local rot_acc = Vector3(1 - math.rand(2), 1 - math.rand(2), 1 - math.rand(2)) * 10
				local i_u_body = 0

				while nr_u_bodies > i_u_body do
					local u_body = unit:body(i_u_body)

					if u_body:enabled() and u_body:dynamic() then
						local body_mass = u_body:mass()
						local len = mvector3.direction(tmp_vec3, hit_pos, u_body:center_of_mass())
						local body_vel = u_body:velocity()
						local vel_dot = mvector3.dot(body_vel, tmp_vec3)
						local max_vel = 800

						if vel_dot < max_vel then
							mvector3.set_z(tmp_vec3, mvector3.z(tmp_vec3) + 0.75)

							local push_vel = (1 - len / range) * (max_vel - math.max(vel_dot, 0))

							mvector3.multiply(tmp_vec3, push_vel)
							World:play_physic_effect(Idstring("physic_effects/body_explosion"), u_body, tmp_vec3, body_mass / math.random(2), u_body:position(), rot_acc, 1)
						end
					end

					i_u_body = i_u_body + 1
				end
			end

			if unit:body("body") then
				local push_vec = Vector3()
				mvector3.direction(push_vec, hit_pos, unit:body("body"):center_of_mass())

				unit:push(5, push_vec * range * 2)
			end
		end
	end
end

function ExplosionManager:_apply_body_damage(is_server, hit_body, user_unit, dir, damage)
	local hit_unit = hit_body:unit()
	local local_damage = is_server or hit_unit:id() == -1
	local sync_damage = is_server and hit_unit:id() ~= -1

	if not local_damage and not sync_damage then
		print("_apply_body_damage skipped")

		return
	end

	local normal = dir
	local prop_damage = math.min(damage, 200)

	if prop_damage < 0.25 then
		prop_damage = math.round(prop_damage, 0.25)
	end

	if prop_damage > 0 then
		local network_damage = math.ceil(prop_damage * 163.84)
		prop_damage = network_damage / 163.84

		if local_damage then
			hit_body:extension().damage:damage_explosion(user_unit, normal, hit_body:position(), dir, prop_damage)
			hit_body:extension().damage:damage_damage(user_unit, normal, hit_body:position(), dir, prop_damage)
		end

		if sync_damage and managers.network:session() then
			if alive(user_unit) then
				managers.network:session():send_to_peers_synched("sync_body_damage_explosion", hit_body, user_unit, normal, hit_body:position(), dir, math.min(32768, network_damage))
			else
				managers.network:session():send_to_peers_synched("sync_body_damage_explosion_no_attacker", hit_body, normal, hit_body:position(), dir, math.min(32768, network_damage))
			end
		end
	end
end

function ExplosionManager:client_damage_and_push(position, normal, user_unit, dmg, range, curve_pow)
	local hit_pos = position
	local bodies = World:find_bodies("intersect", "sphere", hit_pos, range, managers.slot:get_mask("explosion_targets"))
	local units_to_push = {}

	for _, hit_body in ipairs(bodies) do
		if alive(hit_body) then
			local hit_unit = hit_body:unit()
			units_to_push[hit_unit:key()] = hit_unit

			local apply_dmg = hit_body:extension() and hit_body:extension().damage and hit_unit:id() == -1
			local dir, len, damage = nil

			if apply_dmg then
				dir = hit_body:center_of_mass()
				len = mvector3.direction(dir, hit_pos, dir)
				damage = dmg * math.pow(math.clamp(1 - len / range, 0, 1), curve_pow)

				self:_apply_body_damage(false, hit_body, user_unit, dir, damage)
			end
		end
	end

	self:units_to_push(units_to_push, position, range)
end
