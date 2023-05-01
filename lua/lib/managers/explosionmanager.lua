local mvec3_dis_sq = mvector3.distance_sq
local mvec3_copy = mvector3.copy

local math_round = math.round
local math_pow = math.pow
local math_clamp = math.clamp
local math_random = math.random
local math_rand = math.rand
local math_ceil = math.ceil

local pairs_g = pairs

local world_g = World
local alive_g = alive

local expl_physics_str = Idstring("physic_effects/body_explosion")

local draw_explosion_sphere = nil
local draw_sync_explosion_sphere = nil
local draw_splinters = nil
local draw_obstructed_splinters = nil
local draw_splinter_hits = nil
local draw_shield_obstructions = nil

function ExplosionManager:detect_and_stun(params)
	local hit_pos = params.hit_pos
	local slotmask = params.collision_slotmask
	local user_unit = params.user
	local damage = params.damage
	local range = params.range
	local ignore_unit = params.ignore_unit
	local curve_pow = params.curve_pow
	local col_ray = params.col_ray
	local owner = params.owner
	local push_units = false

	if params.push_units ~= nil then
		push_units = params.push_units
	end

	if draw_explosion_sphere then
		local draw_duration = 3
		local new_brush = Draw:brush(Color.red:with_alpha(0.5), draw_duration)
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
			splinters[#splinters + 1] = mvec3_copy(tmp_pos)
		end
	end

	local count_cops, count_gangsters, count_civilians, count_cop_kills, count_gangster_kills, count_civilian_kills = 0, 0, 0, 0, 0, 0
	local is_civilian_func, is_gangster_func = CopDamage.is_civilian, CopDamage.is_gangster
	local units_to_hit, hit_units, units_to_push = {}, {}, push_units == true and {} or nil

	local cast = alive_g(ignore_unit) and ignore_unit or world_g
	local bodies = cast:find_bodies("intersect", "sphere", hit_pos, range, slotmask)

	for i = 1, #bodies do
		local hit_body = bodies[i]

		if alive_g(hit_body) then
			local hit_unit = hit_body:unit()
			local hit_unit_key = hit_unit:key()
			local ray_hit, body_com, char_dmg_ext = nil

			if not units_to_hit[hit_unit_key] then
				if units_to_push then
					units_to_push[hit_unit_key] = hit_unit
				end

				char_dmg_ext = hit_unit:character_damage()
				local hit_character = char_dmg_ext and char_dmg_ext.stun_hit and not char_dmg_ext:dead()

				if hit_character then
					local verif_clbk = params.verify_callback
					local can_stun = not verif_clbk or verif_clbk(hit_unit)

					if can_stun then
						if params.no_raycast_check_characters then
							ray_hit = true
							units_to_hit[hit_unit_key] = true
						else
							body_com = hit_body:center_of_mass()

							for i = 1, #splinters do
								local s_pos = splinters[i]

								ray_hit = not world_g:raycast("ray", s_pos, body_com, "slot_mask", geometry_mask, "report")

								if ray_hit then
									units_to_hit[hit_unit_key] = true

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
					end
				end
			end

			if ray_hit then
				hit_units[hit_unit_key] = hit_unit

				local tweak_name, is_civ, is_gangster, is_cop = nil

				if owner then
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

				body_com = body_com or hit_body:center_of_mass()
				local dir = body_com - hit_pos
				dir = dir:normalized()

				local attack_data = {
					variant = "stun",
					damage = damage,
					attacker_unit = user_unit,
					weapon_unit = owner,
					col_ray = self._col_ray or {
						position = mvec3_copy(hit_body:position()),
						ray = dir
					}
				}

				char_dmg_ext = char_dmg_ext or hit_unit:character_damage()

				char_dmg_ext:stun_hit(attack_data)

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

	if units_to_push then
		managers.explosion:units_to_push(units_to_push, hit_pos, range)
	end

	local alert_radius = params.alert_radius or 10000
	local alert_filter = params.alert_filter or managers.groupai:state():get_unit_type_filter("civilians_enemies")
	local alert_unit = user_unit

	if alive_g(alert_unit) then
		local alert_u_base_ext = alert_unit:base()

		if alert_u_base_ext and alert_u_base_ext.thrower_unit then
			alert_unit = alert_u_base_ext:thrower_unit()
		end
	end

	managers.groupai:state():propagate_alert({
		"explosion",
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
	local owner = params.owner
	local push_units = true

	if params.push_units ~= nil then
		push_units = params.push_units
	end

	if player_dmg > 0 then
		local player = managers.player:player_unit()

		if player then
			player:character_damage():damage_explosion({
				variant = "explosion",
				position = hit_pos,
				range = range,
				damage = player_dmg,
				ignite_character = params.ignite_character
			})
		end
	end

	if draw_explosion_sphere then
		local draw_duration = 3
		local new_brush = Draw:brush(Color.red:with_alpha(0.5), draw_duration)
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
	local shield_mask = managers.slot:get_mask("enemy_shield_check")

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
			splinters[#splinters + 1] = mvec3_copy(tmp_pos)
		end
	end

	local count_cops, count_gangsters, count_civilians, count_cop_kills, count_gangster_kills, count_civilian_kills = 0, 0, 0, 0, 0, 0
	local is_civilian_func, is_gangster_func = CopDamage.is_civilian, CopDamage.is_gangster
	local units_to_hit, hit_units, units_to_push = {}, {}, push_units == true and {} or nil

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
			local hit_character = char_dmg_ext and char_dmg_ext.damage_explosion and not char_dmg_ext:dead()
			local body_ext = hit_body:extension()
			local apply_dmg = body_ext and body_ext.damage and true
			local ray_hit, body_com, damage_character, dmg_mul, tweak_name, is_civ, is_gangster, is_cop = nil

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

								local mov_ext = hit_unit:movement()

								if mov_ext and mov_ext.m_com then
									local e_com = mov_ext:m_com()
									local shield_ray = world_g:raycast("ray", hit_pos, e_com, "slot_mask", shield_mask)
									local shield_enemy = shield_ray and shield_ray.unit:parent()

									if shield_enemy and alive_g(shield_enemy) then
										if draw_shield_obstructions then
											local draw_duration = 3
											local new_brush = Draw:brush(Color.blue:with_alpha(0.5), draw_duration)
											new_brush:cylinder(hit_pos, shield_ray.position, 1.5)
										end

										local s_ene_dmg = shield_enemy:character_damage()

										if s_ene_dmg and s_ene_dmg.dead and not s_ene_dmg:dead() then
											local s_base_ext = shield_enemy:base()
											local char_tweak = s_base_ext and s_base_ext.char_tweak and s_base_ext:char_tweak()

											if char_tweak then
												local tweak_dmg = char_tweak.damage
												local dmg_multiplier = nil

												if hit_unit == shield_enemy then
													dmg_multiplier = tweak_dmg.shield_explosion_damage_mul
												else
													dmg_multiplier = tweak_dmg.shield_explosion_ally_damage_mul
												end

												if dmg_multiplier == 0 then
													ray_hit = nil

													break
												else
													dmg_mul = dmg_multiplier
												end
											else
												ray_hit = nil
											end
										end
									end
								end

								if ray_hit then
									if draw_splinter_hits then
										local draw_duration = 3
										local new_brush = Draw:brush(Color.green:with_alpha(0.5), draw_duration)
										new_brush:cylinder(s_pos, body_com, 0.5)
									end

									break
								end
							end

							if draw_obstructed_splinters then
								local draw_duration = 3
								local new_brush = Draw:brush(Color.yellow:with_alpha(0.5), draw_duration)
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

			if not ray_hit and apply_dmg and units_to_hit[hit_unit_key] and char_dmg_ext and char_dmg_ext.damage_explosion then
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

				local damage = dmg_mul and dmg * dmg_mul or dmg

				if dmg_mul ~= 0 then --check that damage isn't being fully negated by a shield
					damage = damage * math_pow(math_clamp(1 - length / range, 0, 1), curve_pow) --apply falloff
					damage = damage < 1 and 1 or damage --clamp to 1 (10) if less
				end

				if apply_dmg and damage > 0 then
					local prop_damage = damage < 1 and 1 - length / range < -5 and 1 or damage

					self:_apply_body_damage(true, hit_body, user_unit, dir, prop_damage)
				end

				if damage_character then
					local action_data = {
						variant = "explosion",
						damage = damage,
						attacker_unit = user_unit,
						weapon_unit = owner,
						col_ray = self._col_ray or {
							position = mvec3_copy(hit_body:position()),
							ray = dir
						},
						ignite_character = params.ignite_character
					}

					char_dmg_ext:damage_explosion(action_data)

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

	local alert_radius = params.alert_radius or 10000
	local alert_filter = params.alert_filter or managers.groupai:state():get_unit_type_filter("civilians_enemies")
	local alert_unit = user_unit

	if alive_g(alert_unit) then
		local alert_u_base_ext = alert_unit:base()

		if alert_u_base_ext and alert_u_base_ext.thrower_unit then
			alert_unit = alert_u_base_ext:thrower_unit()
		end
	end

	managers.groupai:state():propagate_alert({
		"explosion",
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

function ExplosionManager:units_to_push(units_to_push, from_pos, range)
	if range > 500 then
		range = 500
	end

	for u_key, unit in pairs_g(units_to_push) do
		if alive_g(unit) then
			local char_dmg_ext = unit:character_damage()
			local is_character = char_dmg_ext and char_dmg_ext.damage_explosion

			if not is_character or char_dmg_ext:dead() then
				if is_character then
					local mov_ext = unit:movement()
					local full_body_action = mov_ext and mov_ext._active_actions and mov_ext._active_actions[1]

					if full_body_action and full_body_action:type() == "hurt" then
						full_body_action:force_ragdoll(true)
					end
				end

				local nr_u_bodies = unit:num_bodies()
				local rot_acc = Vector3(1 - math_rand(2), 1 - math_rand(2), 1 - math_rand(2)) * 10
				local i_u_body = 0

				while nr_u_bodies > i_u_body do
					local u_body = unit:body(i_u_body)

					if u_body:enabled() and u_body:dynamic() then
						local dir_vec = u_body:center_of_mass() - from_pos
						local length = dir_vec:length()
						dir_vec = dir_vec:normalized()

						local vel_dot = u_body:velocity():dot(dir_vec)
						local max_vel = 800

						if vel_dot < max_vel then
							local vel_sub = vel_dot < 0 and 0 or vel_dot
							local push_vel = (1 - length / range) * (max_vel - vel_sub)
							dir_vec = dir_vec:with_z(dir_vec.z + 0.75) * push_vel

							world_g:play_physic_effect(expl_physics_str, u_body, dir_vec, u_body:mass() / math_random(2), u_body:position(), rot_acc, 1)
						end
					end

					i_u_body = i_u_body + 1
				end
			end

			local main_body = unit:body("body")

			if main_body then
				local push_vec = main_body:center_of_mass() - from_pos
				push_vec = push_vec:normalized()

				--5 here is 5kg, the resulting push_vec is velocity
				--use 500 and 20000 respectively to break corpses completely
				unit:push(5, push_vec * range * 2)
			end
		end
	end
end

--[[ temp disabled 4/30 testing if this resolves crashing from throwing grenades
function ExplosionManager:_apply_body_damage(is_local_attack, hit_body, user_unit, dir, damage)
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

		body_ext_dmg:damage_explosion(user_unit, normal, hit_pos, dir, damage)
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
		session:send_to_peers_synched("sync_body_damage_explosion", hit_body, user_unit, normal, hit_pos, dir, network_damage)
	else
		session:send_to_peers_synched("sync_body_damage_explosion_no_attacker", hit_body, normal, hit_pos, dir, network_damage)
	end
end
--]]

function ExplosionManager:client_damage_and_push(from_pos, normal, user_unit, dmg, range, curve_pow)
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
				local length = dir:length()
				dir = dir:normalized()

				local damage = dmg * math_pow(math_clamp(1 - length / range, 0, 1), curve_pow)

				self:_apply_body_damage(false, hit_body, user_unit, dir, damage)
			end
		end
	end

	self:units_to_push(units_to_push, from_pos, range)
end
