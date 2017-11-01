function RaycastWeaponBase:set_laser_enabled(state)
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
