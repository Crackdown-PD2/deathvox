local mvec3_dis_sq = mvector3.distance_sq
local mvec3_copy = mvector3.copy

local math_round = math.round
local math_ceil = math.ceil
local math_random = math.random

local pairs_g = pairs

local alive_g = alive
local world_g = World

local idstr_func = Idstring

local draw_explosion_sphere = nil
local draw_sync_explosion_sphere = nil
local draw_splinters = nil
local draw_obstructed_splinters = nil
local draw_splinter_hits = nil
local debug_draw_duration = 3

function FireManager:update(t, dt)
	local doted_enemies = self._doted_enemies

	for index = #doted_enemies, 1, -1 do
		local dot_info = doted_enemies[index]
		local dot_counter = dot_info.fire_dot_counter

		dot_counter = dot_counter + dt

		if dot_counter > 0.5 then
			self:_damage_fire_dot(dot_info)

			dot_counter = dot_counter - 0.5
		end

		dot_info.fire_dot_counter = dot_counter

		if t > dot_info.dot_length then
			local fire_effects = dot_info.fire_effects

			if fire_effects then
				for idx = 1, #fire_effects do
					local effect_id = fire_effects[idx]

					world_g:effect_manager():fade_kill(effect_id)
				end
			end

			local sound_source = dot_info.sound_source

			if sound_source then
				self:_stop_burn_body_sound(sound_source)
			end

			local unit = dot_info.enemy_unit

			if alive_g(unit) then
				local base_ext = unit:base()

				if base_ext.has_tag and base_ext:has_tag("tank") then
					local unit_id = unit:id()

					--unit was already detached from the network, fetch the original id
					if unit_id == -1 then
						local corpse_data = managers.enemy:get_corpse_unit_data_from_key(unit:key())
						local actual_id = corpse_data and corpse_data.u_id

						if actual_id then
							unit_id = actual_id
						end
					end

					managers.fire:remove_dead_dozer_from_overgrill(unit_id)
				end
			end

			local new_doted_enemies = {}

			for idx = 1, index - 1 do
				new_doted_enemies[#new_doted_enemies + 1] = doted_enemies[idx]
			end

			for idx = index + 1, #doted_enemies do
				new_doted_enemies[#new_doted_enemies + 1] = doted_enemies[idx]
			end

			doted_enemies = new_doted_enemies
			self._doted_enemies = doted_enemies
		end
	end
end

function FireManager:check_achievemnts(unit, t)
	local doted_enemies = self._doted_enemies

	if not doted_enemies or not alive_g(unit) then
		return
	end

	local base_ext = unit:base()

	if not base_ext then
		return
	end

	local tweak_name = base_ext._tweak_table

	if not tweak_name or CopDamage.is_civilian(tweak_name) then
		return
	end

	--grant achievements only for the local player when they're the attackers
	for index = 1, #doted_enemies do
		local dot_info = doted_enemies[index]
		local e_unit = dot_info.enemy_unit

		if e_unit and e_unit == unit then
			local user_unit = dot_info.user_unit

			if not user_unit or user_unit ~= managers.player:player_unit() then
				return
			end

			break
		end
	end

	local achiev_data = tweak_data.achievement
	local disco_inferno = achiev_data.disco_inferno

	if disco_inferno then
		local enemies_on_fire = self._enemies_on_fire
		local was_already_in_table = nil

		for index = #enemies_on_fire, 1, -1 do
			local data = enemies_on_fire[index]

			if data.unit == unit then
				was_already_in_table = true

				data.t = t
			elseif t - data.t > 5 then
				local new_enemies_on_fire = {}

				for idx = 1, index - 1 do
					new_enemies_on_fire[#new_enemies_on_fire + 1] = enemies_on_fire[idx]
				end

				for idx = index + 1, #enemies_on_fire do
					new_enemies_on_fire[#new_enemies_on_fire + 1] = enemies_on_fire[idx]
				end

				enemies_on_fire = new_enemies_on_fire
			end
		end

		if not was_already_in_table then
			enemies_on_fire[#enemies_on_fire + 1] = {
				unit = unit,
				t = t
			}
		end

		self._enemies_on_fire = enemies_on_fire

		if #enemies_on_fire >= 10 then
			managers.achievment:award(disco_inferno)
		end
	end

	local overgrill = achiev_data.overgrill

	if overgrill then
		local dozers_on_fire = self._dozers_on_fire

		if base_ext.has_tag and base_ext:has_tag("tank") then
			local unit_id = unit:id()

			dozers_on_fire[unit_id] = dozers_on_fire[unit_id] or {
				t = t,
				unit = unit
			}
		end

		local awarded = nil

		for dozer_id, dozer_info in pairs_g(dozers_on_fire) do
			local dozer_unit = dozer_info.unit

			if not alive_g(dozer_unit) or dozer_unit:id() == 1 then
				dozers_on_fire[dozer_id] = nil
			elseif not awarded and t - dozer_info.t >= 10 then
				awarded = true

				managers.achievment:award(overgrill)
			end
		end

		self._dozers_on_fire = dozers_on_fire
	end
end

function FireManager:remove_dead_dozer_from_overgrill(unit_id)
	local dozers_on_fire = self._dozers_on_fire
	dozers_on_fire[unit_id] = nil

	if unit_id == -1 then
		for dozer_id, dozer_info in pairs_g(dozers_on_fire) do
			local dozer_unit = dozer_info.unit

			if not alive_g(dozer_unit) or dozer_unit:id() == -1 then
				dozers_on_fire[dozer_id] = nil
			end
		end
	end

	self._dozers_on_fire = dozers_on_fire
end

function FireManager:is_set_on_fire(unit)
	local doted_enemies = self._doted_enemies

	for i = 1, #doted_enemies do
		local dot_info = doted_enemies[i]

		if dot_info.enemy_unit == unit then
			return true
		end
	end

	return false
end

function FireManager:_add_doted_enemy(enemy_unit, fire_damage_received_time, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)
	local doted_enemies = self._doted_enemies

	if not doted_enemies then
		return
	end

	local already_doted = false
	local t = TimerManager:game():time()
	local new_length = t + dot_length

	for i = 1, #doted_enemies do
		local dot_info = doted_enemies[i]

		if dot_info.enemy_unit == enemy_unit then
			already_doted = true

			--previous timer should never be shortened, unless the new instance would deal more damage
			if dot_info.dot_length < new_length or dot_info.dot_damage < dot_damage then
				dot_info.dot_length = new_length
				dot_info.dot_damage = dot_damage
			end

			--always override the attacker and weapons used so that the latest attacker gets credited properly
			dot_info.weapon_unit = weapon_unit
			dot_info.user_unit = user_unit
			dot_info.is_molotov = is_molotov

			break
		end
	end

	if not already_doted then
		local dot_info = {
			fire_dot_counter = 0,
			enemy_unit = enemy_unit,
			weapon_unit = weapon_unit,
			dot_length = new_length,
			dot_damage = dot_damage,
			user_unit = user_unit,
			is_molotov = is_molotov
		}

		self:_start_enemy_fire_effect(dot_info)
		self:start_burn_body_sound(dot_info)
		doted_enemies[#doted_enemies + 1] = dot_info
	end

	self._doted_enemies = doted_enemies

	self:check_achievemnts(enemy_unit, t)
end

if deathvox:IsTotalCrackdownEnabled() then
	function FireManager:add_doted_enemy(enemy_unit, fire_damage_received_time, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)
		dot_damage = 0

		local dot_info = self:_add_doted_enemy(enemy_unit, fire_damage_received_time, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)

		managers.network:session():send_to_peers_synched("sync_add_doted_enemy", enemy_unit, 0, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)
	end
else
	function FireManager:add_doted_enemy(enemy_unit, fire_damage_received_time, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)
		local dot_info = self:_add_doted_enemy(enemy_unit, fire_damage_received_time, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)

		managers.network:session():send_to_peers_synched("sync_add_doted_enemy", enemy_unit, 0, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)
	end
end

local tmp_used_flame_objects = nil

function FireManager:_start_enemy_fire_effect(dot_info)
	local fire_data = tweak_data.fire
	local fire_bones = fire_data.fire_bones
	local fire_effects = fire_data.effects.endless
	local effects_cost = fire_data.effects_cost
	local num_fire_bones = #fire_bones
	local num_effects = math_random(3, num_fire_bones)

	if not tmp_used_flame_objects then
		tmp_used_flame_objects = {}

		for i = 1, num_fire_bones do
			tmp_used_flame_objects[#tmp_used_flame_objects + 1] = false
		end
	end

	local idx = 1
	local effects_table = {}
	local my_unit = dot_info.enemy_unit
	local get_object_f = my_unit.get_object

	for i = 1, num_effects do
		while tmp_used_flame_objects[idx] do
			idx = math_random(1, num_fire_bones)
		end

		local bone = get_object_f(my_unit, idstr_func(fire_bones[idx]))

		if bone then
			local effect_name = fire_effects[effects_cost[i]]
			local effect_id = world_g:effect_manager():spawn({
				effect = idstr_func(effect_name),
				parent = bone
			})

			effects_table[#effects_table + 1] = effect_id
		end

		tmp_used_flame_objects[idx] = true
	end

	dot_info.fire_effects = effects_table

	for i = 1, #tmp_used_flame_objects do
		tmp_used_flame_objects[i] = false
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
	local owner = params.owner
	local fire_dot_data = params.fire_dot_data
	local is_molotov = params.is_molotov
	local push_units = true

	if params.push_units ~= nil then
		push_units = params.push_units
	end

	if draw_explosion_sphere or draw_splinters or draw_obstructed_splinters or draw_splinter_hits then
		if owner and owner:base() and owner:base().get_name_id and owner:base():get_name_id() == "environment_fire" then
			debug_draw_duration = 0.1
		else
			debug_draw_duration = 3
		end
	end

	if player_dmg ~= 0 then
		local player = managers.player:player_unit()

		if player then
			player:character_damage():damage_fire({
				variant = "fire",
				position = hit_pos,
				range = range,
				damage = player_dmg,
				ignite_character = params.ignite_character
			})
		end
	end

	if draw_explosion_sphere then
		local new_brush = Draw:brush(Color.red:with_alpha(0.5), debug_draw_duration)
		new_brush:sphere(hit_pos, range)
	end

	local splinters = {
		mvec3_copy(hit_pos)
	}
	local dirs = {
		Vector3(range, 0, 0),
		Vector3(-range, 0, 0),
		Vector3(0, range, 0),
		Vector3(0, -range, 0),
		Vector3(0, 0, range),
		Vector3(0, 0, -range)
	}

	local geometry_mask = managers.slot:get_mask("world_geometry")

	for i = 1, #dirs do
		local dir = dirs[i]
		local tmp_pos = hit_pos - dir
		local splinter_ray = world_g:raycast("ray", hit_pos, tmp_pos, "slot_mask", geometry_mask)

		if splinter_ray then
			local ray_dis = splinter_ray.distance
			local dis = ray_dis > 10 and 10 or ray_dis

			tmp_pos = splinter_ray.position - dir:normalized() * dis
		end

		if draw_splinters then
			local new_brush = Draw:brush(Color.white:with_alpha(0.5), debug_draw_duration)
			new_brush:cylinder(hit_pos, tmp_pos, 0.5)
		end

		local near_other_splinter = false

		for idx = 1, #splinters do
			local s_pos = splinters[idx]

			if mvec3_dis_sq(tmp_pos, s_pos) < 900 then
				near_other_splinter = true

				break
			end
		end

		if not near_other_splinter then
			splinters[#splinters + 1] = mvec3_copy(tmp_pos)
		end
	end

	local count_cops, count_gangsters, count_civilians, count_cop_kills, count_gangster_kills, count_civilian_kills = 0, 0, 0, 0, 0, 0
	local is_civilian_func, is_gangster_func = CopDamage.is_civilian, CopDamage.is_gangster
	local units_to_hit, hit_units = {}, {}
	local units_to_push = nil

	if push_units and push_units == true then
		units_to_push = {}
	end

	local cast = alive_g(ignore_unit) and ignore_unit or world_g
	local bodies = cast:find_bodies("intersect", "sphere", hit_pos, range, slotmask)

	for i = 1, #bodies do
		local hit_body = bodies[i]

		if alive_g(hit_body) then
			local hit_unit = hit_body:unit()
			local hit_unit_key = hit_unit:key()

			if units_to_push then
				units_to_push[hit_unit_key] = hit_unit
			end

			local char_dmg_ext = hit_unit:character_damage()
			local hit_character = char_dmg_ext and char_dmg_ext.damage_fire and not char_dmg_ext:dead()
			local body_ext = hit_body:extension()
			local apply_dmg = body_ext and body_ext.damage and true
			local ray_hit, body_com, damage_character, tweak_name, is_civ, is_gangster, is_cop = nil

			if hit_character then
				if not units_to_hit[hit_unit_key] then
					if params.no_raycast_check_characters then
						ray_hit = true
						units_to_hit[hit_unit_key] = true
						damage_character = true
					else
						body_com = hit_body:center_of_mass()

						for i = 1, #splinters do
							local s_pos = splinters[i]

							ray_hit = not world_g:raycast("ray", s_pos, body_com, "slot_mask", geometry_mask, "report")

							if ray_hit then
								units_to_hit[hit_unit_key] = true
								damage_character = true

								if draw_splinter_hits then
									local new_brush = Draw:brush(Color.green:with_alpha(0.5), debug_draw_duration)
									new_brush:cylinder(s_pos, body_com, 0.5)
								end

								break
							elseif draw_obstructed_splinters then
								local new_brush = Draw:brush(Color.yellow:with_alpha(0.5), debug_draw_duration)
								new_brush:cylinder(s_pos, body_com, 0.5)
							end
						end
					end

					if ray_hit and owner then
						local base_ext = hit_unit:base()
						tweak_name = base_ext and base_ext._tweak_table

						if tweak_name then
							if is_civilian_func(tweak_name) then
								count_civilians = count_civilians + 1
								is_civ = true
							elseif is_gangster_func(tweak_name) then
								count_gangsters = count_gangsters + 1
								is_gangster = true
							elseif base_ext.has_tag and base_ext:has_tag("law") then
								count_cops = count_cops + 1
								is_cop = true
							end
						end
					end
				end
			elseif apply_dmg or hit_body:dynamic() then
				if not units_to_hit[hit_unit_key] then
					ray_hit = true
					units_to_hit[hit_unit_key] = true
				end
			end

			if not ray_hit and apply_dmg and units_to_hit[hit_unit_key] and char_dmg_ext and char_dmg_ext.damage_fire then
				if params.no_raycast_check_characters then
					ray_hit = true
				else
					body_com = body_com or hit_body:center_of_mass()

					for i = 1, #splinters do
						local s_pos = splinters[i]

						ray_hit = not world_g:raycast("ray", s_pos, body_com, "slot_mask", geometry_mask, "report")

						if ray_hit then
							break
						end
					end
				end
			end

			if ray_hit then
				hit_units[hit_unit_key] = hit_unit
				body_com = body_com or hit_body:center_of_mass()

				local dir = body_com - hit_pos
				local length = dir:length()
				dir = dir:normalized()

				local damage = dmg < 1 and 1 or dmg

				if apply_dmg then
					self:_apply_body_damage(true, hit_body, user_unit, dir, damage)
				end

				if damage_character then
					local action_data = {
						variant = "fire",
						damage = damage,
						attacker_unit = user_unit,
						weapon_unit = owner,
						ignite_character = params.ignite_character,
						col_ray = self._col_ray or {
							position = mvec3_copy(hit_body:position()),
							ray = dir
						},
						is_fire_dot_damage = false,
						fire_dot_data = fire_dot_data,
						is_molotov = is_molotov
					}

					char_dmg_ext:damage_fire(action_data)

					if tweak_name and char_dmg_ext:dead() then
						if is_civ then
							count_civilian_kills = count_civilian_kills + 1
						elseif is_gangster then
							count_gangster_kills = count_gangster_kills + 1
						elseif is_cop then
							count_cop_kills = count_cop_kills + 1
						end
					end
				end
			end
		end
	end

	if units_to_push then
		managers.explosion:units_to_push(units_to_push, hit_pos, range)
	end

	local alert_radius = params.alert_radius or 3000
	local alert_filter = params.alert_filter or managers.groupai:state():get_unit_type_filter("civilians_enemies")
	local alert_unit = user_unit

	if alive_g(alert_unit) then
		local alert_u_base_ext = alert_unit:base()

		if alert_u_base_ext and alert_u_base_ext.thrower_unit then
			alert_unit = alert_u_base_ext:thrower_unit()
		end
	end

	managers.groupai:state():propagate_alert({
		"fire",
		hit_pos,
		alert_radius,
		alert_filter,
		alert_unit
	})

	local results = {}

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

function FireManager:_apply_body_damage(is_local_attack, hit_body, user_unit, dir, damage)
	local hit_unit = hit_body:unit()
	local detached_from_network = hit_unit:id() == -1
	local local_damage = is_local_attack or detached_from_network
	local sync_damage = is_local_attack and not detached_from_network

	if not local_damage and not sync_damage then
		return
	end

	damage = damage > 200 and 200 or damage < 0.25 and math_round(damage, 0.25) or damage

	if damage <= 0 then
		return
	end

	local network_damage = math_ceil(damage * 163.84)
	damage = network_damage / 163.84

	local normal = dir
	local hit_pos = mvec3_copy(hit_body:position())

	if local_damage then
		local body_ext_dmg = hit_body:extension().damage

		body_ext_dmg:damage_fire(user_unit, normal, hit_pos, dir, damage)
		body_ext_dmg:damage_damage(user_unit, normal, hit_pos, dir, damage)
	end

	if not sync_damage then
		return
	end

	local session = managers.network:session()

	if not session then
		return
	end

	network_damage = network_damage > 32768 and 32768 or network_damage

	if alive_g(user_unit) then
		session:send_to_peers_synched("sync_body_damage_fire", hit_body, user_unit, normal, hit_pos, dir, network_damage)
	else
		session:send_to_peers_synched("sync_body_damage_fire_no_attacker", hit_body, normal, hit_pos, dir, network_damage)
	end
end

function FireManager:client_damage_and_push(from_pos, normal, user_unit, dmg, range, curve_pow)
	if draw_sync_explosion_sphere then
		local draw_duration = 3
		local new_brush = Draw:brush(Color.red:with_alpha(0.5), draw_duration)
		new_brush:sphere(from_pos, range)
	end

	local bodies = world_g:find_bodies("intersect", "sphere", from_pos, range, managers.slot:get_mask("explosion_targets"))
	local units_to_push = {}

	for i = 1, #bodies do
		local hit_body = bodies[i]

		if alive_g(hit_body) then
			local hit_unit = hit_body:unit()
			units_to_push[hit_unit:key()] = hit_unit

			local body_ext = hit_body:extension()

			if body_ext and body_ext.damage and hit_unit:id() == -1 then
				local dir = hit_body:center_of_mass() - from_pos
				dir = dir:normalized()

				local damage = dmg

				self:_apply_body_damage(false, hit_body, user_unit, dir, damage)
			end
		end
	end

	managers.explosion:units_to_push(units_to_push, from_pos, range)
end
