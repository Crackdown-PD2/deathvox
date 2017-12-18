local old_group_misc_data = GroupAIStateBase._init_misc_data
function GroupAIStateBase:_init_misc_data()
	old_group_misc_data(self)
	self._special_unit_types = {
		tank = true,
		spooc = true,
		shield = true,
		taser = true,
		boom = true,
		medic = true,
		ass_sniper = true
	}
end

local old_group_base = GroupAIStateBase.on_simulation_started
function GroupAIStateBase:on_simulation_started()
	old_group_base(self)
	self._special_unit_types = {
		tank = true,
		spooc = true,
		shield = true,
		taser = true,
		boom = true,
		medic = true,
		ass_sniper = true
	}
end

function GroupAIStateBase:detonate_world_smoke_grenade(id)
	self._smoke_grenades = self._smoke_grenades or {}

	if not self._smoke_grenades[id] then
		Application:error("Could not detonate smoke grenade as it was not queued!", id)

		return
	end

	local data = self._smoke_grenades[id]

	if data.flashbang then
		if Network:is_client() then
			return
		end

		self._smoke_grenades[id] = nil
	else
		data.duration = data.duration == 0 and 15 or data.duration
		local smoke_grenade = World:spawn_unit(Idstring("units/weapons/smoke_grenade_quick/smoke_grenade_quick"), data.detonate_pos, Rotation())

		smoke_grenade:base():activate(data.detonate_pos, data.duration)
		managers.groupai:state():teammate_comment(nil, "g40x_any", data.detonate_pos, true, 2000, false)

		data.grenade = smoke_grenade
	end

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_smoke_grenade", data.detonate_pos, data.detonate_pos, data.duration, data.flashbang and true or false)
	end
end


function GroupAIStateBase:on_enemy_unregistered(unit)
	if self:is_unit_in_phalanx_minion_data(unit:key()) then
		self:unregister_phalanx_minion(unit:key())
		CopLogicPhalanxMinion:chk_should_breakup()
		CopLogicPhalanxMinion:chk_should_reposition()
	end

	self._police_force = self._police_force - 1
	local u_key = unit:key()

	self:_clear_character_criminal_suspicion_data(u_key)

	if not Network:is_server() then
		return
	end

	local e_data = self._police[u_key]

	if e_data.importance > 0 then
		for c_key, c_data in pairs(self._player_criminals) do
			local imp_keys = c_data.important_enemies

			for i, test_e_key in ipairs(imp_keys) do
				if test_e_key == u_key then
					table.remove(imp_keys, i)
					table.remove(c_data.important_dis, i)

					break
				end
			end
		end
	end

	for crim_key, record in pairs(self._ai_criminals) do
		record.unit:brain():on_cop_neutralized(u_key)
	end

	local unit_type = unit:base()._tweak_table
	local is_special = unit:movement()._tweak_data.is_special_unit
	log("unregistering enemy: " .. unit_type)
	if is_special then
		log("is special: " .. is_special)
	end
	
	if self._special_unit_types[unit_type] or is_special then
		if is_special then
			self:unregister_special_unit(u_key, is_special)
		else
			self:unregister_special_unit(u_key, unit_type)
		end
	end

	local dead = unit:character_damage():dead()

	if e_data.group then
		self:_remove_group_member(e_data.group, u_key, dead)
	end

	if e_data.assigned_area and dead then
		local spawn_point = unit:unit_data().mission_element

		if spawn_point then
			local spawn_pos = spawn_point:value("position")
			local u_pos = e_data.m_pos

			if mvector3.distance(spawn_pos, u_pos) < 700 and math.abs(spawn_pos.z - u_pos.z) < 300 then
				local found = nil

				for area_id, area_data in pairs(self._area_data) do
					local area_spawn_points = area_data.spawn_points

					if area_spawn_points then
						for _, sp_data in ipairs(area_spawn_points) do
							if sp_data.spawn_point == spawn_point then
								found = true
								sp_data.delay_t = math.max(sp_data.delay_t, self._t + math.random(30, 60))

								break
							end
						end

						if found then
							break
						end
					end

					local area_spawn_points = area_data.spawn_groups

					if area_spawn_points then
						for _, sp_data in ipairs(area_spawn_points) do
							if sp_data.spawn_point == spawn_point then
								found = true
								sp_data.delay_t = math.max(sp_data.delay_t, self._t + math.random(30, 60))

								break
							end
						end

						if found then
							break
						end
					end
				end
			end
		end
	end
end

-- Lines: 1450 to 1465
function GroupAIStateBase:on_enemy_registered(unit)
	if self._anticipated_police_force > 0 then
		self._anticipated_police_force = self._anticipated_police_force - 1
	else
		self._police_force = self._police_force + 1
	end

	local unit_type = unit:base()._tweak_table
	local is_special = unit:movement()._tweak_data.is_special_unit
	log("registering enemy: " .. unit_type)
	if is_special then
		log("is special: " .. is_special)
	end
	if self._special_unit_types[unit_type] or is_special then
		if is_special then
			self:register_special_unit(unit:key(), is_special)
		else
			self:register_special_unit(unit:key(), unit_type)
		end
	end

	if Network:is_client() then
		unit:movement():set_team(self._teams[tweak_data.levels:get_default_team_ID(unit:base():char_tweak().access == "gangster" and "gangster" or "combatant")])
	end
end

function GroupAIStateBase:chk_say_enemy_chatter(unit, unit_pos, chatter_type)
	if unit:sound():speaking(self._t) then
		return
	end

	local chatter_tweak = tweak_data.group_ai.enemy_chatter[chatter_type]
	local chatter_type_hist = self._enemy_chatter[chatter_type]

	if not chatter_type_hist then
		chatter_type_hist = {
			cooldown_t = 0,
			events = {}
		}
		self._enemy_chatter[chatter_type] = chatter_type_hist
	end

	local t = self._t

	if t < chatter_type_hist.cooldown_t then
		return
	end

	local nr_events_in_area = 0

	for i_event, event_data in pairs(chatter_type_hist.events) do
		if event_data.expire_t < t then
			chatter_type_hist[i_event] = nil
		elseif mvector3.distance(unit_pos, event_data.epicenter) < chatter_tweak.radius then
			if nr_events_in_area == chatter_tweak.max_nr - 1 then
				return
			else
				nr_events_in_area = nr_events_in_area + 1
			end
		end
	end

	local group_requirement = chatter_tweak.group_min

	if group_requirement and group_requirement > 1 then
		local u_data = self._police[unit:key()]
		local nr_in_group = 1

		if u_data.group then
			nr_in_group = u_data.group.size
		end

		if nr_in_group < group_requirement then
			return
		end
	end

	chatter_type_hist.cooldown_t = t + math.lerp(chatter_tweak.interval[1], chatter_tweak.interval[2], math.random())
	local new_event = {
		epicenter = mvector3.copy(unit_pos),
		expire_t = t + math.lerp(chatter_tweak.duration[1], chatter_tweak.duration[2], math.random())
	}

	table.insert(chatter_type_hist.events, new_event)
	unit:sound():say(chatter_tweak.queue, true)

	return true
end


function GroupAIStateBase:sync_cs_grenade(detonate_pos, shooter_pos, duration, damage, diameter)
	local grenade_to_use = World:spawn_unit(Idstring("units/weapons/cs_grenade_quick/cs_grenade_quick"), detonate_pos, Rotation())
	log("CRACKDOWN sync cs grenade: diameter")
	log(diameter)
	log("CRACKDOWN sync cs grenade: damage")
	log(damage)
	log("CRACKDOWN sync cs grenade: duration")
	log(duration)
	grenade_to_use:base():set_properties({
		radius = diameter * 0.5 * 100,
		damage = damage,
		duration = duration
	})
	grenade_to_use:base():detonate()
end