function FireManager:init()
	self._enemies_on_fire = {}
	self._dozers_on_fire = {}
	self._doted_enemies = {}
	self._hellfire_enemies = {}
	self._fire_dot_grace_period = 1
	self._fire_dot_tick_period = 1
	
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
