local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_vec3 = Vector3()
local tmp_vec4 = Vector3()
local empty_idstr = Idstring("")
local idstr_concrete = Idstring("concrete")
local idstr_blood_spatter = Idstring("blood_spatter")
local idstr_blood_screen = Idstring("effects/particles/character/player/blood_screen")
local idstr_bullet_hit_blood = Idstring("effects/payday2/particles/impacts/blood/blood_impact_a")
local idstr_fallback = Idstring("effects/payday2/particles/impacts/fallback_impact_pd2")
local idstr_no_material = Idstring("no_material")
local idstr_bullet_hit = Idstring("bullet_hit")
local mvec3_set = mvector3.set
local mvec3_mul = mvector3.multiply
local mvec3_add = mvector3.add
local mvec3_neg = mvector3.negate
local mvec3_lerp = mvector3.lerp
local mvec3_spread = mvector3.spread
local mvec3_dist_sq = mvector3.distance_sq
local mvec3_dist = mvector3.distance
local mvec3_dot = mvector3.dot

Hooks:PostHook(GamePlayCentralManager,"do_shotgun_push","cd_gameplaycentralmgr_shotgun_push_sync",function(self, unit, hit_pos, dir, distance, attacker)
	if self:get_shotgun_push_range(attacker) < distance then
		return
	end

	if unit:id() ~= -1 then
		self:_add_corpse_to_shotgun_push_sync_list(unit)
		--local unit_pos = unit:position()
		--local unit_rot = unit:rotation()
		--managers.network:session():send_to_peers_synched("sync_fall_position", unit, unit_pos, unit_rot)
	end
end)

local update_original = GamePlayCentralManager.update
function GamePlayCentralManager:update(t, dt, ...)
	update_original(self, t, dt, ...)

	if self._corpses_to_sync then
		if not managers.groupai:state():whisper_mode() then
			self._corpses_to_sync = nil

			return
		end

		for _, corpse_info in pairs(self._corpses_to_sync) do
			if t >= corpse_info.sync_t then
				local unit = corpse_info.unit

				if not alive(unit) then
					self:_remove_corpse_from_shotgun_push_sync_list(corpse_info.u_key)
				else
					--self:_sync_shotgun_pushed_body(unit)

					local active_actions_1 = unit:movement()._active_actions[1]

					if active_actions_1 and active_actions_1:type() == "hurt" and active_actions_1._ragdoll_freeze_clbk_id then
						corpse_info.sync_t = t + 0.5
					else
						local unit_pos = unit:position()
						local unit_rot = unit:rotation()

						managers.network:session():send_to_peers_synched("sync_fall_position", unit, unit_pos, unit_rot)

						self:_remove_corpse_from_shotgun_push_sync_list(corpse_info.u_key)
					end
				end
			end
		end
	end
end

function GamePlayCentralManager:_add_corpse_to_shotgun_push_sync_list(unit)
	local u_key = unit:key()
	self._corpses_to_sync = self._corpses_to_sync or {}

	self._corpses_to_sync[u_key] = {
		unit = unit,
		sync_t = TimerManager:game():time() + 0.5,
		u_key = u_key
	}
end

function GamePlayCentralManager:_remove_corpse_from_shotgun_push_sync_list(u_key)
	self._corpses_to_sync[u_key] = nil

	if table.size(self._corpses_to_sync) == 0 then
		self._corpses_to_sync = nil
	end
end

-- i don't think this is used? - offy
function GamePlayCentralManager:_sync_shotgun_pushed_body(unit)
	local nr_u_bodies = unit:num_bodies()
	local i_u_body = 0

	while nr_u_bodies > i_u_body do
		local u_body = unit:body(i_u_body)

		if u_body:enabled() and u_body:dynamic() then
			local body_pos = u_body:position()

			managers.network:session():send_to_peers_synched("m79grenade_explode_on_client", body_pos, Vector3(), unit, i_u_body, 0, 0)
		end

		i_u_body = i_u_body + 1
	end
end


function GamePlayCentralManager:auto_highlight_enemy(unit, use_player_upgrades,from_tripmine)
	self._auto_highlighted_enemies = self._auto_highlighted_enemies or {}

	if self._auto_highlighted_enemies[unit:key()] and Application:time() < self._auto_highlighted_enemies[unit:key()] then
		return false
	end

	self._auto_highlighted_enemies[unit:key()] = Application:time() + (managers.groupai:state():whisper_mode() and 9 or 4)

	if not unit:contour() then
		debug_pause_unit(unit, "[GamePlayCentralManager:auto_highlight_enemy]: Unit doesn't have Contour Extension")
	end

	local time_multiplier = 1
	local contour_type = "mark_enemy"
	local is_camera = unit:base() and unit:base().is_security_camera

	if is_camera then
		contour_type = "mark_unit"
		time_multiplier = managers.player:upgrade_value("player", "mark_enemy_time_multiplier", 1)
	elseif use_player_upgrades then
		contour_type = managers.player:get_contour_for_marked_enemy(unit:base().get_type and unit:base():get_type()) or contour_type
		time_multiplier = managers.player:upgrade_value("player", "mark_enemy_time_multiplier", 1)
		if from_tripmine then 
			time_multiplier = time_multiplier * managers.player:upgrade_value("trip_mine","extended_mark_duration",1)
		end
	end

	if not is_camera and use_player_upgrades and Network:is_server() and managers.player:has_category_upgrade("player", "convert_enemies_target_marked") then
		unit:contour():add(contour_type, true, time_multiplier, nil, nil, managers.network:session():local_peer():id())
	else
		unit:contour():add(contour_type, true, time_multiplier)
	end

	return true
end
