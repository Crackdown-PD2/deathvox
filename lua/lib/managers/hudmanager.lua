local nl_w_pos = Vector3()
local nl_pos = Vector3()
local nl_cam_forward = Vector3()
local tmp_vec1 = Vector3()
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_dir = mvector3.direction
local mvec3_ang = mvector3.angle
local mvec3_x = mvector3.x
local mvec3_y = mvector3.y
local mvec3_z = mvector3.z
function HUDManager:_update_name_labels(t, dt)
	local managers = managers
	local viewport = managers.viewport
	local cam = viewport:get_current_camera()
	if not cam then
		return
	end
	local cam_pos = viewport:get_current_camera_position()
	local cam_rot = viewport:get_current_camera_rotation()
	mrotation.y(cam_rot, nl_cam_forward)

	local player = managers.player:local_player()
	local mvt = player and player:alive() and player:movement()
	local in_steelsight = mvt and mvt:current_state() and mvt:current_state():in_steelsight()

	for _, data in ipairs(self._hud.name_labels) do
		local alpha

		local movement = data.movement
		if movement then
			mvec3_set(nl_w_pos, movement:m_pos())
			mvec3_set_z(nl_w_pos, mvec3_z(movement:m_head_pos()) + 30)
			if movement.current_state_name and movement:current_state_name() == "driving" then
				alpha = 0
			elseif movement.vehicle_seat and movement.vehicle_seat.occupant ~= nil then
				alpha = 0
			end
		elseif data.vehicle then
			if not alive(data.vehicle) then
				return
			end
			local pos = data.vehicle:position()
			mvec3_set(nl_w_pos, pos)
			mvec3_set_z(nl_w_pos, mvec3_z(pos) + data.vehicle:vehicle_driving().hud_label_offset)
		end

		if not alpha then
			mvec3_dir(tmp_vec1, cam_pos, nl_w_pos)
			local angle = mvec3_ang(nl_cam_forward, tmp_vec1)
			if angle > 90 then
				alpha = 0
			elseif in_steelsight then
				--angle = angle / 8.11
				alpha = angle * angle * 0.0152
			else
				alpha = 1
			end
		end

		local label_panel = data.panel
		if alpha > 0 then
			mvec3_set(nl_pos, self._workspace:world_to_screen(cam, nl_w_pos))
			label_panel:set_center(mvec3_x(nl_pos), mvec3_y(nl_pos))
		end

		label_panel:set_alpha(alpha)
	end
end

local fs_original_hudmanager_addmugshotbyunit = HUDManager.add_mugshot_by_unit
function HUDManager:add_mugshot_by_unit(unit)
	if alive(unit) then
		return fs_original_hudmanager_addmugshotbyunit(self, unit)
	end
end