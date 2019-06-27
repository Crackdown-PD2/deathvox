function GroupAIStateBesiege:_check_spawn_phalanx()
end

	function GroupAIStateBesiege:_voice_looking_for_angle(group)
		for u_key, unit_data in pairs(group.units) do
			if unit_data.char_tweak.chatter.ready and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "look_for_angle") then
			else
			end
		end
	end	
	
	function GroupAIStateBesiege:_voice_open_fire_start(group)
		for u_key, unit_data in pairs(group.units) do
			if unit_data.char_tweak.chatter.ready and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "open_fire") then
			else
			end
		end
	end

	function GroupAIStateBesiege:_voice_push_in(group)
		for u_key, unit_data in pairs(group.units) do
			if unit_data.char_tweak.chatter.ready and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "push") then
			else
			end
		end
	end

	function GroupAIStateBesiege:_voice_gtfo(group)
		for u_key, unit_data in pairs(group.units) do
			if unit_data.char_tweak.chatter.ready and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "retreat") then
			else
			end
		end
	end
	
	function GroupAIStateBesiege:_voice_deathguard_start(group)
		for u_key, unit_data in pairs(group.units) do
			if unit_data.char_tweak.chatter.ready and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "deathguard") then
			else
			end
		end
	end	
	
	function GroupAIStateBesiege:_voice_smoke(group)
		for u_key, unit_data in pairs(group.units) do
			if unit_data.char_tweak.chatter.ready and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "smoke") then
			else
			end
		end
	end	
	
	function GroupAIStateBesiege:_voice_flash(group)
		for u_key, unit_data in pairs(group.units) do
			if unit_data.char_tweak.chatter.ready and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "flash_grenade") then
			else
			end
		end
	end

	function GroupAIStateBesiege:_voice_dont_delay_assault(group)
		local time = self._t
		for u_key, unit_data in pairs(group.units) do
			if not unit_data.unit:sound():speaking(time) then
				unit_data.unit:sound():say("p01", true, nil)
				return true
			end
		end
		return false
	end

function GroupAIStateBesiege:provide_covering_fire(group_to_cover)
	if group_to_cover and group_to_cover.units then
		local lu_key, lu_data = nil, nil
		for u_key, u_data in pairs(group_to_cover.units) do
			lu_data = u_data
			lu_key = u_key
			break
		end
		local units_to_check = World:find_units_quick("sphere", lu_data.unit:position(), 2000, managers.slot:get_mask("enemies"))
		for _, enemy in ipairs(units_to_check) do
			local fuck = false
			local u_data = self._police[enemy:key()]
			for eu_key, eu_data in pairs(group_to_cover.units) do
				if u_data == eu_data then
					fuck = true
					break
				end
			end
			if not fuck then
				local brain = lu_data.unit:brain()
				local current_objective = brain:objective()
				if u_data.tactics_map and  u_data.tactics_map.provide_coverfire and current_objective and current_objective.area then
					local grp_objective = {
						attitude = "engage",
						pose = "stand",
						type = "assault_area",
						stance = "hos",
						attitude = "engage",
						moving_in = false,
						open_fire = true,
						pushed = false,
						charge = false,
						interrupt_dis = 0,
						tactic = current_objective.tactic,
						area = current_objective.area,
						coarse_path = {{
							current_objective.area.pos_nav_seg,
							mvector3.copy(current_objective.area.pos)
						}}
					}

					self:_set_objective_to_enemy_group(u_data.group, grp_objective)
				end
			end
		end
	end
end

function GroupAIStateBesiege:_set_assault_objective_to_group(group, phase)
	if not group.has_spawned then
		return
	end

	local phase_is_anticipation = phase == "anticipation"
	local current_objective = group.objective
	local approach, open_fire, push, pull_back, charge = nil
	local obstructed_area = self:_chk_group_areas_tresspassed(group)
	local group_leader_u_key, group_leader_u_data = self._determine_group_leader(group.units)
	local tactics_map = nil

	if group_leader_u_data and group_leader_u_data.tactics then
		tactics_map = {}

		for _, tactic_name in ipairs(group_leader_u_data.tactics) do
			tactics_map[tactic_name] = true
		end

		if current_objective.tactic and not tactics_map[current_objective.tactic] then
			current_objective.tactic = nil
		end

		for i_tactic, tactic_name in ipairs(group_leader_u_data.tactics) do
			if tactic_name == "deathguard" and not phase_is_anticipation then
				if current_objective.tactic == tactic_name then
					for u_key, u_data in pairs(self._char_criminals) do
						if u_data.status and current_objective.follow_unit == u_data.unit then
							local crim_nav_seg = u_data.tracker:nav_segment()

							if current_objective.area.nav_segs[crim_nav_seg] then
								return
							end
						end
					end
				end

				local closest_crim_u_data, closest_crim_dis_sq = nil

				for u_key, u_data in pairs(self._char_criminals) do
					if u_data.status then
						local closest_u_id, closest_u_data, closest_u_dis_sq = self._get_closest_group_unit_to_pos(u_data.m_pos, group.units)

						if closest_u_dis_sq and (not closest_crim_dis_sq or closest_u_dis_sq < closest_crim_dis_sq) then
							closest_crim_u_data = u_data
							closest_crim_dis_sq = closest_u_dis_sq
						end
					end
				end

				if closest_crim_u_data then
					local search_params = {
						id = "GroupAI_deathguard",
						from_tracker = group_leader_u_data.unit:movement():nav_tracker(),
						to_tracker = closest_crim_u_data.tracker,
						access_pos = self._get_group_acces_mask(group)
					}
					local coarse_path = managers.navigation:search_coarse(search_params)

					if coarse_path then
						local grp_objective = {
							distance = 800,
							type = "assault_area",
							attitude = "engage",
							tactic = "deathguard",
							moving_in = true,
							follow_unit = closest_crim_u_data.unit,
							area = self:get_area_from_nav_seg_id(coarse_path[#coarse_path][1]),
							coarse_path = coarse_path
						}
						group.is_chasing = true
						self:provide_covering_fire(group)
						self:_set_objective_to_enemy_group(group, grp_objective)
						self:_voice_deathguard_start(group)

						return
					end
				end
			elseif tactic_name == "charge" and not current_objective.moving_out and group.in_place_t and (self._t - group.in_place_t > 15 or self._t - group.in_place_t > 4 and self._drama_data.amount <= tweak_data.drama.low) and next(current_objective.area.criminal.units) and group.is_chasing and not current_objective.charge then
				charge = true
			end
		end
	end

	local objective_area = nil

	if obstructed_area then
		if current_objective.moving_out then
			if not current_objective.open_fire then
				open_fire = true
			end
		elseif not current_objective.pushed or charge and not current_objective.charge then
			push = true
		end
	else
		local obstructed_path_index = self:_chk_coarse_path_obstructed(group)

		if obstructed_path_index then
			print("obstructed_path_index", obstructed_path_index)

			objective_area = self:get_area_from_nav_seg_id(group.coarse_path[math.max(obstructed_path_index - 1, 1)][1])
			pull_back = true
		elseif not current_objective.moving_out then
			local has_criminals_close = nil

			if not current_objective.moving_out then
				for area_id, neighbour_area in pairs(current_objective.area.neighbours) do
					if next(neighbour_area.criminal.units) then
						has_criminals_close = true

						break
					end
				end
			end

			if charge then
				push = true
			elseif not has_criminals_close or not group.in_place_t then
				approach = true
			elseif not phase_is_anticipation and not current_objective.open_fire then
				open_fire = true
			elseif not phase_is_anticipation and group.in_place_t and (group.is_chasing or not tactics_map or not tactics_map.ranged_fire or self._t - group.in_place_t > 15) then
				push = true
			elseif phase_is_anticipation and current_objective.open_fire then
				pull_back = true
			end
		end
	end

	objective_area = objective_area or current_objective.area

	if open_fire then
		local grp_objective = {
			attitude = "engage",
			pose = "stand",
			type = "assault_area",
			stance = "hos",
			open_fire = true,
			tactic = current_objective.tactic,
			area = obstructed_area or current_objective.area,
			coarse_path = {{
				objective_area.pos_nav_seg,
				mvector3.copy(current_objective.area.pos)
			}}
		}
		self:_set_objective_to_enemy_group(group, grp_objective)
		self:_voice_open_fire_start(group)
	elseif approach or push then
		local assault_area, alternate_assault_area, alternate_assault_area_from, assault_path, alternate_assault_path = nil
		local to_search_areas = {objective_area}
		local found_areas = {[objective_area] = "init"}

		repeat
			local search_area = table.remove(to_search_areas, 1)

			if next(search_area.criminal.units) then
				local assault_from_here = true

				if not push and tactics_map and tactics_map.flank then
					local assault_from_area = found_areas[search_area]

					if assault_from_area ~= "init" then
						local cop_units = assault_from_area.police.units

						for u_key, u_data in pairs(cop_units) do
							if u_data.group and u_data.group ~= group and u_data.group.objective.type == "assault_area" then
								assault_from_here = false

								if not alternate_assault_area or math.random() < 0.5 then
									local search_params = {
										id = "GroupAI_assault",
										from_seg = current_objective.area.pos_nav_seg,
										to_seg = search_area.pos_nav_seg,
										access_pos = self._get_group_acces_mask(group),
										verify_clbk = callback(self, self, "is_nav_seg_safe")
									}
									alternate_assault_path = managers.navigation:search_coarse(search_params)

									if alternate_assault_path then
										self:_merge_coarse_path_by_area(alternate_assault_path)

										alternate_assault_area = search_area
										alternate_assault_area_from = assault_from_area
									end
								end

								found_areas[search_area] = nil

								break
							end
						end
					end
				end

				if assault_from_here then
					local search_params = {
						id = "GroupAI_assault",
						from_seg = current_objective.area.pos_nav_seg,
						to_seg = search_area.pos_nav_seg,
						access_pos = self._get_group_acces_mask(group),
						verify_clbk = callback(self, self, "is_nav_seg_safe")
					}
					assault_path = managers.navigation:search_coarse(search_params)

					if assault_path then
						self:_merge_coarse_path_by_area(assault_path)

						assault_area = search_area

						break
					end
				end
			else
				for other_area_id, other_area in pairs(search_area.neighbours) do
					if not found_areas[other_area] then
						table.insert(to_search_areas, other_area)

						found_areas[other_area] = search_area
					end
				end
			end
		until #to_search_areas == 0

		if not assault_area and alternate_assault_area then
			assault_area = alternate_assault_area
			found_areas[assault_area] = alternate_assault_area_from
			assault_path = alternate_assault_path
		end

		if assault_area and assault_path then
			local assault_area = push and assault_area or found_areas[assault_area] == "init" and objective_area or found_areas[assault_area]

			if #assault_path > 2 and assault_area.nav_segs[assault_path[#assault_path - 1][1]] then
				table.remove(assault_path)
			end

			local used_grenade = nil

			if push then
				local detonate_pos = nil

				if charge then
					for c_key, c_data in pairs(assault_area.criminal.units) do
						detonate_pos = c_data.unit:movement():m_pos()

						break
					end
				end

				local first_chk = math.random() < 0.5 and self._chk_group_use_flash_grenade or self._chk_group_use_smoke_grenade
				local second_chk = first_chk == self._chk_group_use_flash_grenade and self._chk_group_use_smoke_grenade or self._chk_group_use_flash_grenade
				used_grenade = first_chk(self, group, self._task_data.assault, detonate_pos)
				used_grenade = used_grenade or second_chk(self, group, self._task_data.assault, detonate_pos)
				self:provide_covering_fire(group)
				self:_voice_move_in_start(group)
			end

			if not push or used_grenade then
				local grp_objective = {
					type = "assault_area",
					stance = "hos",
					area = assault_area,
					coarse_path = assault_path,
					pose = push and "crouch" or "stand",
					attitude = push and "engage" or "avoid",
					moving_in = push and true or nil,
					open_fire = push or nil,
					pushed = push or nil,
					charge = charge,
					interrupt_dis = charge and 0 or nil
				}
				group.is_chasing = group.is_chasing or push
				if push or charge or approach then
					self:provide_covering_fire(group)
				end
				self:_set_objective_to_enemy_group(group, grp_objective)
			end
		end
	elseif pull_back then
		local retreat_area, do_not_retreat = nil

		for u_key, u_data in pairs(group.units) do
			local nav_seg_id = u_data.tracker:nav_segment()

			if current_objective.area.nav_segs[nav_seg_id] then
				retreat_area = current_objective.area

				break
			end

			if self:is_nav_seg_safe(nav_seg_id) then
				retreat_area = self:get_area_from_nav_seg_id(nav_seg_id)

				break
			end
		end

		if not retreat_area and not do_not_retreat and current_objective.coarse_path then
			local forwardmost_i_nav_point = self:_get_group_forwardmost_coarse_path_index(group)

			if forwardmost_i_nav_point then
				local nearest_safe_nav_seg_id = current_objective.coarse_path(forwardmost_i_nav_point)
				retreat_area = self:get_area_from_nav_seg_id(nearest_safe_nav_seg_id)
			end
		end

		if retreat_area then
			local new_grp_objective = {
				attitude = "avoid",
				stance = "hos",
				pose = "crouch",
				type = "assault_area",
				area = retreat_area,
				coarse_path = {{
					retreat_area.pos_nav_seg,
					mvector3.copy(retreat_area.pos)
				}}
			}
			group.is_chasing = nil

			self:_set_objective_to_enemy_group(group, new_grp_objective)

			return
		end
	end
end


function GroupAIStateBesiege:_set_reenforce_objective_to_group(group)
	if not group.has_spawned then
		return
	end

	local current_objective = group.objective

	if current_objective.target_area then
		if current_objective.moving_out and not current_objective.moving_in then
			local forwardmost_i_nav_point = self:_get_group_forwardmost_coarse_path_index(group)

			if forwardmost_i_nav_point then
				for i = forwardmost_i_nav_point + 1, #current_objective.coarse_path, 1 do
					local nav_point = current_objective.coarse_path[forwardmost_i_nav_point]

					if not self:is_nav_seg_safe(nav_point[1]) then
						for i = 0, #current_objective.coarse_path - forwardmost_i_nav_point, 1 do
							table.remove(current_objective.coarse_path)
						end

						local grp_objective = {
							attitude = "avoid",
							scan = true,
							pose = "stand",
							type = "reenforce_area",
							stance = "hos",
							area = self:get_area_from_nav_seg_id(current_objective.coarse_path[#current_objective.coarse_path][1]),
							target_area = current_objective.target_area
						}

						self:_set_objective_to_enemy_group(group, grp_objective)

						return
					end
				end
			end
		end

		if not current_objective.moving_out and not current_objective.area.neighbours[current_objective.target_area.id] then
			local search_params = {
				id = "GroupAI_reenforce",
				from_seg = current_objective.area.pos_nav_seg,
				to_seg = current_objective.target_area.pos_nav_seg,
				access_pos = self._get_group_acces_mask(group),
				verify_clbk = callback(self, self, "is_nav_seg_safe")
			}
			local coarse_path = managers.navigation:search_coarse(search_params)

			if coarse_path then
				self:_merge_coarse_path_by_area(coarse_path)
				table.remove(coarse_path)

				local grp_objective = {
					scan = true,
					pose = "stand",
					type = "reenforce_area",
					stance = "hos",
					attitude = "avoid",
					area = self:get_area_from_nav_seg_id(coarse_path[#coarse_path][1]),
					target_area = current_objective.target_area,
					coarse_path = coarse_path
				}

				self:_set_objective_to_enemy_group(group, grp_objective)
			end
		end

		if not current_objective.moving_out and current_objective.area.neighbours[current_objective.target_area.id] and not next(current_objective.target_area.criminal.units) then
			local grp_objective = {
				stance = "hos",
				scan = true,
				pose = "crouch",
				type = "reenforce_area",
				attitude = "engage",
				area = current_objective.target_area
			}
			self:provide_covering_fire(group)
			self:_set_objective_to_enemy_group(group, grp_objective)

			group.objective.moving_in = true
		end
	end
end


function GroupAIStateBesiege:_upd_group_spawning()
	local spawn_task = self._spawning_groups[1]

	if not spawn_task then
		return
	end

	local nr_units_spawned = 0
	local produce_data = {
		name = true,
		spawn_ai = {}
	}
	local group_ai_tweak = tweak_data.group_ai
	local spawn_points = spawn_task.spawn_group.spawn_pts


	local function _try_spawn_unit(u_type_name, spawn_entry)
		if GroupAIStateBesiege._MAX_SIMULTANEOUS_SPAWNS <= nr_units_spawned then
			return
		end

		local hopeless = true
		local current_unit_type = tweak_data.levels:get_ai_group_type()

		for _, sp_data in ipairs(spawn_points) do
			local category = group_ai_tweak.unit_categories[u_type_name]

			if (sp_data.accessibility == "any" or category.access[sp_data.accessibility]) and (not sp_data.amount or sp_data.amount > 0) and sp_data.mission_element:enabled() and category.unit_types[current_unit_type] then
				hopeless = false

				if sp_data.delay_t < self._t then
					local units = category.unit_types[current_unit_type]
					produce_data.name = units[math.random(#units)]
					produce_data.name = managers.modifiers:modify_value("GroupAIStateBesiege:SpawningUnit", produce_data.name)
					local spawned_unit = sp_data.mission_element:produce(produce_data)
					local u_key = spawned_unit:key()
					local objective = nil

					if spawn_task.objective then
						objective = self.clone_objective(spawn_task.objective)
					else
						if spawn_task.group.objective.element then
							objective = spawn_task.group.objective.element:get_random_SO(spawned_unit)

							if not objective then
								spawned_unit:set_slot(0)

								return true
							end

							objective.grp_objective = spawn_task.group.objective
						else
							spawned_unit:set_slot(0)

							return true
						end
					end

					local u_data = self._police[u_key]

					self:set_enemy_assigned(objective.area, u_key)

					if spawn_entry.tactics then
						u_data.tactics = spawn_entry.tactics
						u_data.tactics_map = {}

						for _, tactic_name in ipairs(u_data.tactics) do
							u_data.tactics_map[tactic_name] = true
						end
					end

					spawned_unit:brain():set_spawn_entry(spawn_entry, u_data.tactics_map)

					u_data.rank = spawn_entry.rank

					self:_add_group_member(spawn_task.group, u_key)

					if spawned_unit:brain():is_available_for_assignment(objective) then
						if objective.element then
							objective.element:clbk_objective_administered(spawned_unit)
						end

						spawned_unit:brain():set_objective(objective)
					else
						spawned_unit:brain():set_followup_objective(objective)
					end

					nr_units_spawned = nr_units_spawned + 1

					if spawn_task.ai_task then
						spawn_task.ai_task.force_spawned = spawn_task.ai_task.force_spawned + 1
					end

					sp_data.delay_t = self._t + sp_data.interval

					if sp_data.amount then
						sp_data.amount = sp_data.amount - 1
					end

					return true
				end
			end
		end

		if hopeless then
			debug_pause("[GroupAIStateBesiege:_upd_group_spawning] spawn group", spawn_task.spawn_group.id, "failed to spawn unit", u_type_name)

			return true
		end
	end

	for u_type_name, spawn_info in pairs(spawn_task.units_remaining) do
		if not group_ai_tweak.unit_categories[u_type_name].access.acrobatic then
			for i = spawn_info.amount, 1, -1 do
				local success = _try_spawn_unit(u_type_name, spawn_info.spawn_entry)

				if success then
					spawn_info.amount = spawn_info.amount - 1
				end

				break
			end
		end
	end

	for u_type_name, spawn_info in pairs(spawn_task.units_remaining) do
		for i = spawn_info.amount, 1, -1 do
			local success = _try_spawn_unit(u_type_name, spawn_info.spawn_entry)

			if success then
				spawn_info.amount = spawn_info.amount - 1
			end

			break
		end
	end

	local complete = true

	for u_type_name, spawn_info in pairs(spawn_task.units_remaining) do
		if spawn_info.amount > 0 then
			complete = false

			break
		end
	end

	if complete then
		spawn_task.group.has_spawned = true

		table.remove(self._spawning_groups, 1)

		if spawn_task.group.size <= 0 then
			self._groups[spawn_task.group.id] = nil
		end
	end
end

function GroupAIStateBesiege:_upd_assault_task()
	local task_data = self._task_data.assault

	if not task_data.active then
		return
	end

	local t = self._t

	self:_assign_recon_groups_to_retire()

	local force_pool = self:_get_difficulty_dependent_value(self._tweak_data.assault.force_pool) * self:_get_balancing_multiplier(self._tweak_data.assault.force_pool_balance_mul)
	local task_spawn_allowance = force_pool - (self._hunt_mode and 0 or task_data.force_spawned)

	if task_data.phase == "anticipation" then
		if task_spawn_allowance <= 0 then
			

			task_data.phase = "fade"
		
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		elseif task_data.phase_end_t < t then
			self._assault_number = self._assault_number + 1

			managers.mission:call_global_event("start_assault")
			managers.hud:start_assault(self._assault_number)
			self:_set_rescue_state(false)
			
			task_data.phase = "build"
			task_data.phase_end_t = self._t + self._tweak_data.assault.build_duration
			task_data.is_hesitating = nil

			self:set_assault_mode(true)
			managers.trade:set_trade_countdown(false)
		else
			managers.hud:check_anticipation_voice(task_data.phase_end_t - t)
			managers.hud:check_start_anticipation_music(task_data.phase_end_t - t)

			if task_data.is_hesitating and task_data.voice_delay < self._t then
				if self._hostage_headcount > 0 then
					local best_group = nil

					for _, group in pairs(self._groups) do
						if not best_group or group.objective.type == "reenforce_area" then
							best_group = group
						elseif best_group.objective.type ~= "reenforce_area" and group.objective.type ~= "retire" then
							best_group = group
						end
					end

					if best_group and self:_voice_delay_assault(best_group) then
						task_data.is_hesitating = nil
					end
				else
					task_data.is_hesitating = nil
				end
			end
		end
	elseif task_data.phase == "build" then
		if task_spawn_allowance <= 0 then
			
			task_data.phase = "fade"
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		elseif task_data.phase_end_t < t then
			local sustain_duration = math.lerp(self:_get_difficulty_dependent_value(self._tweak_data.assault.sustain_duration_min), self:_get_difficulty_dependent_value(self._tweak_data.assault.sustain_duration_max), math.random()) * self:_get_balancing_multiplier(self._tweak_data.assault.sustain_duration_balance_mul)

			managers.modifiers:run_func("OnEnterSustainPhase", sustain_duration)
			
			task_data.phase = "sustain"
			task_data.phase_end_t = t + sustain_duration
		end
	elseif task_data.phase == "sustain" then
		local end_t = self:assault_phase_end_time()
		task_spawn_allowance = managers.modifiers:modify_value("GroupAIStateBesiege:SustainSpawnAllowance", task_spawn_allowance, force_pool)

		if task_spawn_allowance <= 0 then
			
			task_data.phase = "fade"
			local time = self._t
		    for group_id, group in pairs(self._groups) do
	            for u_key, u_data in pairs(group.units) do
		        local nav_seg_id = u_data.tracker:nav_segment()
		        local current_objective = group.objective
		            if current_objective.coarse_path then
		                if not u_data.unit:sound():speaking(time) then
	                        u_data.unit:sound():say("r01", true)
		                end	
	                end					   
		        end	
		    end
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		elseif end_t < t and not self._hunt_mode then
			
			task_data.phase = "fade"
			local time = self._t
		    for group_id, group in pairs(self._groups) do
	            for u_key, u_data in pairs(group.units) do
		        local nav_seg_id = u_data.tracker:nav_segment()
		        local current_objective = group.objective
		            if current_objective.coarse_path then
		                if not u_data.unit:sound():speaking(time) then
	                        u_data.unit:sound():say("m01", true)
		                end	
	                end					   
		        end	
		    end
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		end
	else
		local end_assault = false
		local enemies_left = self:_count_police_force("assault")

		if not self._hunt_mode then
			local min_enemies_left = 50
			
			if enemies_left < min_enemies_left or task_data.phase_end_t + 350 < t then
				if task_data.phase_end_t - 8 < t and not task_data.said_retreat then
					
					task_data.said_retreat = true

					self:_police_announce_retreat()
					local time = self._t
		            for group_id, group in pairs(self._groups) do
	                    for u_key, u_data in pairs(group.units) do
		                local nav_seg_id = u_data.tracker:nav_segment()
		                local current_objective = group.objective
		                    if current_objective.coarse_path then
		                        if not u_data.unit:sound():speaking(time) then
	                                u_data.unit:sound():say("m01", true)
		                        end	
	                        end					   
		                end	
		            end
				end
			end
			if task_data.phase_end_t < t and self:_count_criminals_engaged_force(4) <= 3 then
				end_assault = true
			end

			if task_data.force_end or end_assault then
				

				task_data.active = nil
				task_data.phase = nil
				task_data.said_retreat = nil
				task_data.force_end = nil
				local time = self._t
		        for group_id, group in pairs(self._groups) do
	                for u_key, u_data in pairs(group.units) do
		            local nav_seg_id = u_data.tracker:nav_segment()
		            local current_objective = group.objective
		                if current_objective.coarse_path then
		                    if not u_data.unit:sound():speaking(time) then
	                            u_data.unit:sound():say("m01", true)
		                    end	
	                    end					   
		            end	
		        end

				managers.mission:call_global_event("end_assault")
				self:_begin_regroup_task()

				return
			end
		end
	end

	if self._drama_data.amount <= tweak_data.drama.low then
		for criminal_key, criminal_data in pairs(self._player_criminals) do
			self:criminal_spotted(criminal_data.unit)

			for group_id, group in pairs(self._groups) do
				if group.objective.charge then
					for u_key, u_data in pairs(group.units) do
						u_data.unit:brain():clbk_group_member_attention_identified(nil, criminal_key)
					end
				end
			end
		end
	end

	local primary_target_area = task_data.target_areas[1]

	if self:is_area_safe_assault(primary_target_area) then
		local target_pos = primary_target_area.pos
		local nearest_area, nearest_dis = nil

		for criminal_key, criminal_data in pairs(self._player_criminals) do
			if not criminal_data.status then
				local dis = mvector3.distance_sq(target_pos, criminal_data.m_pos)

				if not nearest_dis or dis < nearest_dis then
					nearest_dis = dis
					nearest_area = self:get_area_from_nav_seg_id(criminal_data.tracker:nav_segment())
				end
			end
		end

		if nearest_area then
			primary_target_area = nearest_area
			task_data.target_areas[1] = nearest_area
		end
	end

	local nr_wanted = task_data.force - self:_count_police_force("assault")

	if task_data.phase == "anticipation" then
		nr_wanted = nr_wanted - 5
	end

	if nr_wanted > 0 and task_data.phase ~= "fade" then
		local used_event = nil

		if task_data.use_spawn_event and task_data.phase ~= "anticipation" then
			task_data.use_spawn_event = false

			if self:_try_use_task_spawn_event(t, primary_target_area, "assault") then
				used_event = true
			end
		end

		if not used_event then
			if next(self._spawning_groups) then
				-- Nothing
			else
				local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(primary_target_area, self._tweak_data.assault.groups, nil, nil, nil)

				if spawn_group then
					local grp_objective = {
						attitude = "avoid",
						stance = "hos",
						pose = "crouch",
						type = "assault_area",
						area = spawn_group.area,
						coarse_path = {{
							spawn_group.area.pos_nav_seg,
							spawn_group.area.pos
						}}
					}

					self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective, task_data)
				end
			end
		end
	end

	if task_data.phase ~= "anticipation" then
		if task_data.use_smoke_timer < t then
			task_data.use_smoke = true
		end

		self:detonate_queued_smoke_grenades()
	end

	self:_assign_enemy_groups_to_assault(task_data.phase)
end

function GroupAIStateBesiege:_check_phalanx_damage_reduction_increase()
end

function GroupAIStateBesiege:set_phalanx_damage_reduction_buff(damage_reduction)
	local law1team = self:_get_law1_team()
	damage_reduction = damage_reduction or -1
	law1team.damage_reduction = nil
	self:set_damage_reduction_buff_hud()

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_damage_reduction_buff", damage_reduction)
	end
end

function GroupAIStateBesiege:set_damage_reduction_buff_hud()
end

function GroupAIStateBesiege:_chk_group_use_flash_grenade(group, task_data, detonate_pos)
	if task_data.use_smoke and not self:is_smoke_grenade_active() then
		local duration = tweak_data.group_ai.flash_grenade_lifetime

		for u_key, u_data in pairs(group.units) do
			if u_data.tactics_map and u_data.tactics_map.flash_grenade then
				if not detonate_pos then
					if u_data.group and u_data.group.objective and u_data.group.objective.area then
						if u_data.group.objective.type == "assault_area" or u_data.group.objective.type == "reenforce_area" then
							detonate_pos = mvector3.copy(u_data.group.objective.area.pos)
						else
							detonate_pos = mvector3.copy(u_data.m_pos)
						end
					else
						detonate_pos = mvector3.copy(u_data.m_pos)
					end
				end

				if detonate_pos then
					u_data.unit:sound():say("d02", true)
					u_data.unit:movement():play_redirect("throw_grenade")
					self:detonate_smoke_grenade(detonate_pos, detonate_pos, duration, true)

					task_data.use_smoke_timer = self._t + math.lerp(tweak_data.group_ai.smoke_and_flash_grenade_timeout[1], tweak_data.group_ai.smoke_and_flash_grenade_timeout[2], math.random() ^ 0.5)
					task_data.use_smoke = false
					return true
				end
			end
		end
	end
end

function GroupAIStateBesiege:_chk_group_use_smoke_grenade(group, task_data, detonate_pos)
	if task_data.use_smoke and not self:is_smoke_grenade_active() then
		local duration = tweak_data.group_ai.smoke_grenade_lifetime

		for u_key, u_data in pairs(group.units) do
			if u_data.tactics_map and u_data.tactics_map.smoke_grenade then
				if not detonate_pos then
					if u_data.group and u_data.group.objective and u_data.group.objective.area then
						if u_data.group.objective.type == "assault_area" or u_data.group.objective.type == "reenforce_area" then
							detonate_pos = mvector3.copy(u_data.group.objective.area.pos)
						else
							detonate_pos = mvector3.copy(u_data.m_pos)
						end
					else
						detonate_pos = mvector3.copy(u_data.m_pos)
					end
				end

				if detonate_pos then
					u_data.unit:sound():say("d01", true)
					u_data.unit:movement():play_redirect("throw_grenade")
					self:detonate_smoke_grenade(detonate_pos, detonate_pos, duration, false)

					task_data.use_smoke_timer = self._t + math.lerp(tweak_data.group_ai.smoke_and_flash_grenade_timeout[1], tweak_data.group_ai.smoke_and_flash_grenade_timeout[2], math.random() ^ 0.5)
					task_data.use_smoke = false
					return true
				end
			end
		end
	end
end

function GroupAIStateBesiege:assign_enemy_to_group_ai(unit, team_id)
	local u_tracker = unit:movement():nav_tracker()
	local seg = u_tracker:nav_segment()
	local area = self:get_area_from_nav_seg_id(seg)
	local current_unit_type = tweak_data.levels:get_ai_group_type()
	local u_name = unit:name()
	local u_category = nil

	for cat_name, category in pairs(tweak_data.group_ai.unit_categories) do
		local units = category.unit_types[current_unit_type]
		if units then
			for _, test_u_name in ipairs(units) do
				if u_name == test_u_name then
					u_category = cat_name

					break
				end
			end
		end
	end

	local group_desc = {
		size = 1,
		type = u_category or "custom"
	}
	local group = self:_create_group(group_desc)
	group.team = self._teams[team_id]
	local grp_objective = nil
	local objective = unit:brain():objective()
	local grp_obj_type = self._task_data.assault.active and "assault_area" or "recon_area"

	if objective then
		grp_objective = {
			type = grp_obj_type,
			area = objective.area or objective.nav_seg and self:get_area_from_nav_seg_id(objective.nav_seg) or area
		}
		objective.grp_objective = grp_objective
	else
		grp_objective = {
			type = grp_obj_type,
			area = area
		}
	end

	grp_objective.moving_out = false
	group.objective = grp_objective
	group.has_spawned = true

	self:_add_group_member(group, unit:key())
	self:set_enemy_assigned(area, unit:key())
end


function GroupAIStateBesiege:_assign_skirmish_groups_to_retire(group)
	--this is horrible, but it works.
	for group_id, group in pairs(self._groups) do --this acquires the groups currently existing in the level.
		local group_leader_u_key, group_leader_u_data = self._determine_group_leader(group.units)
		local tactics_map = nil

		if group_leader_u_data and group_leader_u_data.tactics then
			tactics_map = {}

			for _, tactic_name in ipairs(group_leader_u_data.tactics) do
				tactics_map[tactic_name] = true
			end
		end
		
		if managers.skirmish:is_skirmish() and tactics_map then
			if tactics_map.skirmish and group.objective.type ~= "retire" then
				local function suitable_grp_func(group)
					if tactics_map.skirmish and group.objective.type ~= "retire" then
						local grp_objective = {
							stance = "hos",
							attitude = "avoid",
							pose = "stand",
							type = "assault_area",
							area = group.objective.area
						}

						self:_set_objective_to_enemy_group(group, grp_objective)
					end
				end
				--log("retiring all enemies")
				self:_assign_groups_to_retire(self._tweak_data.assault.groups, suitable_grp_func)
			end			
		end
	end
end

function GroupAIStateBesiege:_upd_recon_tasks()
	local task_data = self._task_data.recon.tasks[1]
	
	if managers.skirmish:is_skirmish() then --makes unfit units retire during control/recon, mostly used as a safety measure to prevent leftovers
		self:_assign_skirmish_groups_to_retire(allowed_groups, suitable_grp_func, group)
	end
	
	self:_assign_enemy_groups_to_recon()

	if not task_data then
		return
	end

	local t = self._t

	self:_assign_assault_groups_to_retire()

	local target_pos = task_data.target_area.pos
	local nr_wanted = self:_get_difficulty_dependent_value(self._tweak_data.recon.force) - self:_count_police_force("recon")

	if nr_wanted <= 0 then
		return
	end

	local used_event, used_spawn_points, reassigned = nil

	if task_data.use_spawn_event then
		task_data.use_spawn_event = false

		if self:_try_use_task_spawn_event(t, task_data.target_area, "recon") then
			used_event = true
		end
	end

	if not used_event then
		local used_group = nil

		if next(self._spawning_groups) then
			used_group = true
		else
			local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(task_data.target_area, self._tweak_data.recon.groups, nil, nil, callback(self, self, "_verify_anticipation_spawn_point"))

			if spawn_group then
				local grp_objective = {
					attitude = "avoid",
					scan = true,
					stance = "hos",
					type = "recon_area",
					area = spawn_group.area,
					target_area = task_data.target_area
				}

				self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective)

				used_group = true
			end
		end
	end

	if used_event or used_spawn_points or reassigned then
		table.remove(self._task_data.recon.tasks, 1)

		self._task_data.recon.next_dispatch_t = t + math.ceil(self:_get_difficulty_dependent_value(self._tweak_data.recon.interval)) + math.random() * self._tweak_data.recon.interval_variation
	end
end
