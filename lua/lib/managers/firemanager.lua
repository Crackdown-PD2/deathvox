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

		if t > dot_info.fire_damage_received_time + (dot_info.is_molotov and self._fire_dot_grace_period or 0) and dot_info.fire_dot_counter >= 0.5 then
			self:_damage_fire_dot(dot_info)

			dot_info.fire_dot_counter = 0
		end

		if t > dot_info.fire_damage_received_time + dot_info.dot_length then
			if dot_info.fire_effects then
				for _, fire_effect_id in ipairs(dot_info.fire_effects) do
					World:effect_manager():fade_kill(fire_effect_id)
				end
			end

			self:_remove_flame_effects_from_doted_unit(dot_info.enemy_unit)
			self:_stop_burn_body_sound(dot_info.sound_source)
			table.remove(self._doted_enemies, index)

			if dot_info.enemy_unit and alive(dot_info.enemy_unit) then
				self._dozers_on_fire[dot_info.enemy_unit:id()] = nil
			end
		else
			dot_info.fire_dot_counter = dot_info.fire_dot_counter + dt
		end
	end
end

function FireManager:_add_doted_enemy(enemy_unit, fire_damage_received_time, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)
	local contains = false

	if self._doted_enemies then
		for _, dot_info in ipairs(self._doted_enemies) do
			if dot_info.enemy_unit == enemy_unit then
				if dot_info.fire_damage_received_time + dot_info.dot_length < fire_damage_received_time + dot_length then
					dot_info.fire_damage_received_time = fire_damage_received_time
					dot_info.dot_length = dot_length
				end

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
