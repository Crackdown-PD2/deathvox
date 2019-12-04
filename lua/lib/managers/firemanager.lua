function FireManager:init()
	self._enemies_on_fire = {}
	self._dozers_on_fire = {}
	self._doted_enemies = {}
	self._hellfire_enemies = {}
	self._fire_dot_grace_period = 1
	self._fire_dot_tick_period = 1
end

function FireManager:update(t, dt)
	for index = #self._doted_enemies, 1, -1 do
		local dot_info = self._doted_enemies[index]

		--no grace period means that DoT ticks will consistently trigger as long as the enemy is "doted"
		--instead of resetting the timer each time a new DoT instance is applied, correctly allowing players
		--to dose enemies continuously to maximize damage, as the latest update to flamethrower stats intended
		if dot_info.fire_dot_counter >= 0.5 then
			self:_damage_fire_dot(dot_info)

			dot_info.fire_dot_counter = 0
		end

		if t > dot_info.fire_damage_received_time + dot_info.dot_length then
			if dot_info.fire_effects then
				for _, fire_effect_id in ipairs(dot_info.fire_effects) do
					World:effect_manager():fade_kill(fire_effect_id)
				end
			end

			--fix for fire effects dissappearing on their own
			--self:_remove_flame_effects_from_doted_unit(dot_info.enemy_unit)

			if dot_info.sound_source then
				self:_stop_burn_body_sound(dot_info.sound_source)
			end

			table.remove(self._doted_enemies, index)

			if dot_info.enemy_unit and alive(dot_info.enemy_unit) then
				self._dozers_on_fire[dot_info.enemy_unit:id()] = nil
			end
		else
			dot_info.fire_dot_counter = dot_info.fire_dot_counter + dt
		end
	end
end

function FireManager:check_achievemnts(unit, t)
	if not unit and not alive(unit) then
		return
	end

	if not unit:base() or not unit:base()._tweak_table then
		return
	end

	if CopDamage.is_civilian(unit:base()._tweak_table) then
		return
	end

	--grant achievements only for the local player when they're the attackers
	if self._doted_enemies then
		for _, dot_info in ipairs(self._doted_enemies) do
			if dot_info.user_unit and dot_info.user_unit == managers.player:player_unit() then
				--nothing
			else
				return
			end
		end
	else
		return
	end

	for i = #self._enemies_on_fire, 1, -1 do
		local data = self._enemies_on_fire[i]

		if t - data.t > 5 or data.unit == unit then
			table.remove(self._enemies_on_fire, i)
		end
	end

	table.insert(self._enemies_on_fire, {
		unit = unit,
		t = t
	})

	if tweak_data.achievement.disco_inferno then
		local count = #self._enemies_on_fire

		if count >= 10 then
			managers.achievment:award(tweak_data.achievement.disco_inferno)
		end
	end

	--proper Dozer check
	if unit:base().has_tag and unit:base():has_tag("tank") then
		local unit_id = unit:id()

		self._dozers_on_fire[unit_id] = self._dozers_on_fire[unit_id] or {
			t = t,
			unit = unit
		}
	end

	if tweak_data.achievement.overgrill then
		for dozer_id, dozer_info in pairs(self._dozers_on_fire) do
			if t - dozer_info.t >= 10 then
				managers.achievment:award(tweak_data.achievement.overgrill)
			end
		end
	end
end

function FireManager:add_doted_enemy(enemy_unit, fire_damage_received_time, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)
	local dot_info = self:_add_doted_enemy(enemy_unit, fire_damage_received_time, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)

	--modified sync function to work along with normal dot syncing
	managers.network:session():send_to_peers_synched("sync_add_doted_enemy", enemy_unit, 0, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)
end

function FireManager:_add_doted_enemy(enemy_unit, fire_damage_received_time, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)
	local contains = false

	if self._doted_enemies then
		for _, dot_info in ipairs(self._doted_enemies) do
			if dot_info.enemy_unit == enemy_unit then
				--instead of always updating fire_damage_received_time, only do so (plus update the dot length) if the new length
				--is longer than the remaining DoT time (DoT damage also gets replaced as it's pretty much a new DoT instance)
				if dot_info.fire_damage_received_time + dot_info.dot_length < fire_damage_received_time + dot_length then
					dot_info.fire_damage_received_time = fire_damage_received_time
					dot_info.dot_length = dot_length
					dot_info.dot_damage = dot_damage
				else
					--to avoid a higher damage DoT from not applying, or applying with a longer timer
					if dot_info.dot_damage < dot_damage then
						dot_info.fire_damage_received_time = fire_damage_received_time
						dot_info.dot_length = dot_length
						dot_info.dot_damage = dot_damage
					end
				end

				--always override the attacker and weapons used so that the latest attacker gets credited properly
				dot_info.weapon_unit = weapon_unit
				dot_info.user_unit = user_unit
				dot_info.is_molotov = is_molotov

				contains = true
			end
		end

		if not contains then
			local dot_info = {
				fire_dot_counter = 0,
				enemy_unit = enemy_unit,
				fire_damage_received_time = fire_damage_received_time,
				weapon_unit = weapon_unit,
				dot_length = dot_length,
				dot_damage = dot_damage,
				user_unit = user_unit,
				is_molotov = is_molotov
			}

			table.insert(self._doted_enemies, dot_info)
			self:_start_enemy_fire_effect(dot_info)
			self:start_burn_body_sound(dot_info)
		end

		self:check_achievemnts(enemy_unit, fire_damage_received_time)
	end
end

function FireManager:detect_and_give_dmg(params)
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
	local fire_dot_data = params.fire_dot_data
	local results = {}
	local alert_radius = params.alert_radius or 3000
	local is_molotov = params.is_molotov

	if params.push_units ~= nil then
		push_units = params.push_units
	end

	local player = managers.player:player_unit()

	if player_dmg ~= 0 and alive(player) then
		player:character_damage():damage_fire({
			variant = "fire",
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

		--just check for geometry collisions to avoid issues with objects like helmets, shields, etc
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
		if alive(hit_body) then
			units_to_push[hit_body:unit():key()] = hit_body:unit()
			local character = hit_body:unit():character_damage() and hit_body:unit():character_damage().damage_fire and not hit_body:unit():character_damage():dead()
			local apply_dmg = hit_body:extension() and hit_body:extension().damage
			local dir, damage, ray_hit, damage_character = nil

			if character then
				if not units_to_hit[hit_body:unit():key()] then
					if params.no_raycast_check_characters then
						ray_hit = true
						units_to_hit[hit_body:unit():key()] = true
						damage_character = true
					else
						for i_splinter, s_pos in ipairs(splinters) do
							--same as the splinters themselves, --just check for geometry obstructions to avoid issues with objects like helmets, shields, etc
							ray_hit = not World:raycast("ray", s_pos, hit_body:center_of_mass(), "slot_mask", managers.slot:get_mask("world_geometry"), "report")

							if ray_hit then
								units_to_hit[hit_body:unit():key()] = true
								damage_character = true

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
							elseif not managers.groupai:state():is_unit_team_AI(hit_unit) then --properly check against bots
								count_cops = count_cops + 1
							end
						end
					end
				end
			elseif apply_dmg or hit_body:dynamic() then --sadly I can't really check for obstructions for geometry with damage extensions, it's just too inconsistent for no reason
				if not units_to_hit[hit_body:unit():key()] then
					ray_hit = true
					units_to_hit[hit_body:unit():key()] = true
				end
			end

			--allow multiple damage extensions from the same unit to be damaged (like against Dozers)
			--otherwise either one extension may be damaged at a time, or none at all
			if not ray_hit and units_to_hit[hit_body:unit():key()] and apply_dmg and character then
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

				if ignore_unit ~= hit_unit then
					hit_units[hit_unit:key()] = hit_unit
					dir = hit_body:center_of_mass()
					mvector3.direction(dir, hit_pos, dir)
					damage = dmg

					if apply_dmg then
						self:_apply_body_damage(true, hit_body, user_unit, dir, damage)
					end

					damage = math.max(damage, 1)

					if character and damage_character then
						local dead_before = hit_unit:character_damage():dead()
						local action_data = {
							variant = "fire",
							damage = damage,
							attacker_unit = user_unit,
							weapon_unit = owner,
							ignite_character = params.ignite_character,
							col_ray = self._col_ray or {
								position = hit_body:position(),
								ray = dir
							},
							is_fire_dot_damage = false,
							fire_dot_data = fire_dot_data,
							is_molotov = is_molotov
						}

						hit_unit:character_damage():damage_fire(action_data)

						if owner and not dead_before and hit_unit:base() and hit_unit:base()._tweak_table and hit_unit:character_damage():dead() then
							type = hit_unit:base()._tweak_table

							if CopDamage.is_civilian(type) then
								count_civilian_kills = count_civilian_kills + 1
							elseif CopDamage.is_gangster(type) then
								count_gangster_kills = count_gangster_kills + 1
							elseif not managers.groupai:state():is_unit_team_AI(hit_unit) then --properly check against bots
								count_cop_kills = count_cop_kills + 1
							end
						end
					end
				end
			end
		end
	end

	if push_units and push_units == true then
		--need to use these like this otherwise they're modified by the rest of the function
		local det_pos = params.hit_pos
		local push_range = params.range

		managers.explosion:units_to_push(units_to_push, det_pos, push_range)
	end

	local alert_unit = user_unit
	local alert_pos = params.hit_pos --same as with push_units

	if alive(alert_unit) and alert_unit:base() and alert_unit:base().thrower_unit then
		alert_unit = alert_unit:base():thrower_unit()
	end

	managers.groupai:state():propagate_alert({
		"fire",
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

function FireManager:_apply_body_damage(is_server, hit_body, user_unit, dir, damage)
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
			hit_body:extension().damage:damage_fire(user_unit, normal, hit_body:position(), dir, prop_damage)
			hit_body:extension().damage:damage_damage(user_unit, normal, hit_body:position(), dir, prop_damage)
		end

		if sync_damage and managers.network:session() then
			if alive(user_unit) then
				managers.network:session():send_to_peers_synched("sync_body_damage_fire", hit_body, user_unit, normal, hit_body:position(), dir, math.min(32768, network_damage))
			else
				managers.network:session():send_to_peers_synched("sync_body_damage_fire_no_attacker", hit_body, normal, hit_body:position(), dir, math.min(32768, network_damage))
			end
		end
	end
end

function FireManager:client_damage_and_push(position, normal, user_unit, dmg, range, curve_pow)
	local hit_pos = position
	local bodies = World:find_bodies("intersect", "sphere", hit_pos, range, managers.slot:get_mask("explosion_targets"))
	local units_to_push = {}

	for _, hit_body in ipairs(bodies) do
		local hit_unit = hit_body:unit()
		units_to_push[hit_unit:key()] = hit_unit
		local apply_dmg = hit_body:extension() and hit_body:extension().damage and hit_unit:id() == -1
		local dir, damage = nil

		if apply_dmg then
			--vanilla for some dumb reason applies fall-off here, when the detect_and_give_dmg function doesn't even make use of it
			dir = hit_body:center_of_mass()
			mvector3.direction(dir, hit_pos, dir)
			damage = dmg

			self:_apply_body_damage(false, hit_body, user_unit, dir, damage)
		end
	end

	managers.explosion:units_to_push(units_to_push, position, range)
end

function FireManager:_add_hellfire_enemy(enemy_unit)
	local dot_info = {
		enemy_unit = enemy_unit
	}
	table.insert(self._hellfire_enemies, dot_info)
	self:_start_hellfire_effect(dot_info)
end

function FireManager:_start_hellfire_effect(dot_info)
	local num_objects = #tweak_data.fire.hellfire_bones
	local num_effects = num_objects

	if not tmp_used_flame_objects then
		tmp_used_flame_objects = {}

		for _, effect in ipairs(tweak_data.fire.fire_bones) do
			table.insert(tmp_used_flame_objects, false)
		end
	end

	local idx = 1
	local effect_id = nil
	local effects_table = {}

	for i = 1, num_effects, 1 do
		while tmp_used_flame_objects[idx] do
			idx = math.random(1, num_objects)
		end

		local effect = tweak_data.fire.effects.hellfire_endless[tweak_data.fire.effects_cost[i]]
		local bone = dot_info.enemy_unit:get_object(Idstring(tweak_data.fire.hellfire_bones[idx]))

		if bone then
			effect_id = World:effect_manager():spawn({
				effect = Idstring(effect),
				parent = bone
			})

			table.insert(effects_table, effect_id)
		end

		tmp_used_flame_objects[idx] = true
	end

	dot_info.fire_effects = effects_table

	for idx, _ in ipairs(tmp_used_flame_objects) do
		tmp_used_flame_objects[idx] = false
	end
end

function FireManager:_remove_hell_fire_from_all()
	for index = #self._hellfire_enemies, 1, -1 do
		local dot_info = self._hellfire_enemies[index]
		if dot_info.fire_effects then
			for _, fire_effect_id in ipairs(dot_info.fire_effects) do
				World:effect_manager():fade_kill(fire_effect_id)
			end
		end
	end
end

function FireManager:_remove_hell_fire(enemy_unit)
	for index = #self._hellfire_enemies, 1, -1 do
		local dot_info = self._hellfire_enemies[index]
		if dot_info.fire_effects and dot_info.enemy_unit and dot_info.enemy_unit == enemy_unit then
			for _, fire_effect_id in ipairs(dot_info.fire_effects) do
				World:effect_manager():fade_kill(fire_effect_id)
			end
		end
	end
end
