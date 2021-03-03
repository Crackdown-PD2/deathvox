--copied from CD's CopActionWalk
function CivilianActionWalk:_get_current_max_walk_speed(move_dir)
	if move_dir == "l" or move_dir == "r" then
		move_dir = "strafe"
	end

	local ext_brain = self._ext_brain
	local multiplier = ext_brain.is_hostage and ext_brain:is_hostage() and self._common_data.char_tweak.hostage_move_speed or 1
	if deathvox:IsTotalCrackdownEnabled() then 
		--the only change is slightly modifying this statement to accommodate for TCD's Pack Mules Aced skill
		if ext_brain.is_tied and ext_brain:is_tied() and managers.enemy:is_civilian(self._unit) then 
			multiplier = multiplier * managers.player:team_upgrade_value("player","civilian_hostage_speed_bonus",1)
		end
	end
	
	local speed = self._common_data.char_tweak.move_speed[self._ext_anim.pose][self._haste][self._stance.name][move_dir] * multiplier
	local is_host = self._sync or Global.game_settings.single_player

	if not is_host then
		if self:_husk_needs_speedup() then
			self._host_peer = self._host_peer or managers.network:session():peer(1)
			local ping_multiplier = 1
			local vis_multiplier = 1

			if self._host_peer then
				ping_multiplier = ping_multiplier + Network:qos(self._host_peer:rpc()).ping / 1000
			end

			if Unit.occluded(self._unit) then
				vis_multiplier = 1.5
			else
				local lod = self._ext_base:lod_stage()
				local lod_multiplier_add = CopActionWalk.lod_multipliers[lod] or 0.65

				vis_multiplier = 0.85 + lod_multiplier_add
			end

			local final_multiplier = math_min(ping_multiplier * vis_multiplier, 2)
			speed = speed * final_multiplier
		elseif managers.groupai:state():whisper_mode() then
			speed = speed * tweak_data.network.stealth_speed_boost
		end
	end

	return speed
end