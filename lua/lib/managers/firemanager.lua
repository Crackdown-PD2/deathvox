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
