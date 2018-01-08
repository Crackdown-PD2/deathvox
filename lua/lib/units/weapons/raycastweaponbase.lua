function RaycastWeaponBase:_weapon_tweak_data_id()
	local override_gadget = self:gadget_overrides_weapon_functions()
	if override_gadget then
		return override_gadget.name_id
	end
	return self._name_id
end

function RaycastWeaponBase:set_laser_enabled(state)
	if not tweak_data.weapon[self._name_id].disable_sniper_laser then
		if state then
			if alive(self._laser_unit) then
				return
			end
			local spawn_rot = self._obj_fire:rotation()
			local spawn_pos = self._obj_fire:position()
			spawn_pos = spawn_pos - spawn_rot:y() * 8 + spawn_rot:z() * 2 - spawn_rot:x() * 1.5
			self._laser_unit = World:spawn_unit(Idstring("units/payday2/weapons/wpn_npc_upg_fl_ass_smg_sho_peqbox/wpn_npc_upg_fl_ass_smg_sho_peqbox"), spawn_pos, spawn_rot)
			self._unit:link(self._obj_fire:name(), self._laser_unit)
			self._laser_unit:base():set_npc()
			self._laser_unit:base():set_on()
			self._laser_unit:base():set_color_by_theme("cop_sniper")
			self._laser_unit:base():set_max_distace(10000)
		elseif alive(self._laser_unit) then
			self._laser_unit:set_slot(0)
			self._laser_unit = nil
		end
	end
end

function RaycastWeaponBase:_check_alert(rays, fire_pos, direction, user_unit)
	local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	local group_ai = managers.groupai:state()
	local t = TimerManager:game():time()
	local exp_t = t + 1.5
	local mvec3_dis = mvector3.distance_sq
	local all_alerts = self._alert_events
	local alert_rad = self._alert_size / 4
	if difficulty_index == 8 and not managers.groupai:state():whisper_mode() then
		alert_rad = 1250
	end
	local from_pos = mvec_from_pos
	local tolerance = 250000

	mvector3.set(from_pos, direction)
	mvector3.multiply(from_pos, -alert_rad)
	mvector3.add(from_pos, fire_pos)

	for i = #all_alerts, 1, -1 do
		if all_alerts[i][3] < t then
			table.remove(all_alerts, i)
		end
	end

	if #rays > 0 then
		for _, ray in ipairs(rays) do
			local event_pos = ray.position

			for i = #all_alerts, 1, -1 do
				if mvec3_dis(all_alerts[i][1], event_pos) < tolerance and mvec3_dis(all_alerts[i][2], from_pos) < tolerance then
					event_pos = nil

					break
				end
			end

			if event_pos then
				table.insert(all_alerts, {
					event_pos,
					from_pos,
					exp_t
				})

				local new_alert = {
					"bullet",
					event_pos,
					alert_rad,
					self._setup.alert_filter,
					user_unit,
					from_pos
				}

				group_ai:propagate_alert(new_alert)
			end
		end
	end

	local fire_alerts = self._alert_fires
	local cached = false

	for i = #fire_alerts, 1, -1 do
		if fire_alerts[i][2] < t then
			table.remove(fire_alerts, i)
		elseif mvec3_dis(fire_alerts[i][1], fire_pos) < tolerance then
			cached = true

			break
		end
	end

	if not cached then
		table.insert(fire_alerts, {
			fire_pos,
			exp_t
		})

		local new_alert = {
			"bullet",
			fire_pos,
			self._alert_size,
			self._setup.alert_filter,
			user_unit,
			from_pos
		}

		group_ai:propagate_alert(new_alert)
	end
end

