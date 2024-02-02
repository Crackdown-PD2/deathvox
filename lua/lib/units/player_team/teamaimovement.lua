local mvec3_set = mvector3.set
local tmp_vec1 = Vector3()
local zero_vel_vec = Vector3(0, 0, 0)

local mrot_lookat = mrotation.set_look_at
local tmp_rot_1 = Rotation()

local math_random = math.random
local math_up = math.UP

local type_g = type
local next_g = next

local clone_g = clone
local alive_g = alive
local call_on_next_update_g = call_on_next_update


function TeamAIMovement:save(save_data)
	TeamAIMovement.super.save(self, save_data)

	local should_stay = self._should_stay

	if should_stay ~= nil then
		save_data.movement = save_data.movement or {}
		save_data.movement.should_stay = should_stay
	end
end

function TeamAIMovement:load(load_data)
	TeamAIMovement.super.load(self, load_data)

	local mov_load_data = load_data.movement

	if not mov_load_data then
		return
	end

	local should_stay = mov_load_data.should_stay

	if should_stay ~= nil then
		self:set_should_stay(should_stay)
	end
end

function TeamAIMovement:set_should_stay(should_stay)
	if self._should_stay == should_stay then
		return
	end

	self._should_stay = should_stay

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_team_ai_stopped", self._unit, should_stay)
	end

	local panel = managers.criminals:character_data_by_unit(self._unit)

	if panel then
		managers.hud:set_ai_stopped(panel.panel_id, should_stay)
	end
end

function TeamAIMovement:chk_action_forbidden(action_type)
	return TeamAIMovement.super.chk_action_forbidden(self, action_type)
end

--used by clients
function TeamAIMovement:sync_reload_weapon(empty_reload, reload_speed_multiplier)
	local reload_action = {
		body_part = 3,
		type = "reload",
		idle_reload = empty_reload ~= 0 and empty_reload or nil
	}

	self:action_request(reload_action)
end

function TeamAIMovement:is_taser_attack_allowed()
	if not self._unit:character_damage():is_downed() and not self._unit:character_damage():_cannot_take_damage() and not self:cool() and not self:chk_action_forbidden("hurt") then
		return true
	end
	
	return
end
