local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_norm = mvector3.normalize
local mvec3_dir = mvector3.direction
local mvec3_set_l = mvector3.set_length
local mvec3_add = mvector3.add
local mvec3_dot = mvector3.dot
local mvec3_cross = mvector3.cross
local mvec3_rot = mvector3.rotate_with
local mvec3_rand_orth = mvector3.random_orthogonal
local mvec3_lerp = mvector3.lerp
local mrot_axis_angle = mrotation.set_axis_angle
local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
local temp_vec3 = Vector3()
local temp_rot1 = Rotation()
local bezier_curve = {
	0,
	0,
	1,
	1
}

local _f_CopActionShoot__get_target_pos = CopActionShoot._get_target_pos

function CopActionShoot:_get_target_pos(shoot_from_pos, ...)
	local target_pos, target_vec, target_dis, autotarget
	local _time = math.floor(TimerManager:game():time())
	self._throw_projectile_time = self._throw_projectile_time or 0
	target_pos, target_vec, target_dis, autotarget = _f_CopActionShoot__get_target_pos(self, shoot_from_pos, ...)
	if self._unit:base()._tweak_table == "deathvox_grenadier" and self._throw_projectile_time < _time then
		if self._shooting_player then
			local roll = math.rand(1, 100)
			if self._throw_projectile_time < _time then
				local chance_gas = 25
				if roll <= chance_gas and not managers.groupai:state()._cs_grenade and not Network:is_client() then
					self._throw_projectile_time = _time + math.round_with_precision(10, 2)
					shoot_from_pos = shoot_from_pos + Vector3(50, 50, 0)
					target_pos, target_vec, target_dis, autotarget = _f_CopActionShoot__get_target_pos(self, shoot_from_pos, ...)
					local dildo = _G.deathvox.BufferedSounds.grenadier.use_gas
					local voiceline_to_use = dildo[math.random(#dildo)]
					self._unit:base():play_voiceline(voiceline_to_use, true)
					deploy_gas(shoot_from_pos, target_vec)
				else
					roll = math.rand(1, 100)
					if roll <= 15 then
						local dildo = _G.deathvox.BufferedSounds.grenadier.spot_heister
						local voiceline_to_use = dildo[math.random(#dildo)]
						self._unit:base():play_voiceline(voiceline_to_use)
					end
				end
			end
		else
			target_pos, target_vec, target_dis, autotarget = _f_CopActionShoot__get_target_pos(self, shoot_from_pos, ...)
		end
	else
		target_pos, target_vec, target_dis, autotarget = _f_CopActionShoot__get_target_pos(self, shoot_from_pos, ...)
	end
	return target_pos, target_vec, target_dis, autotarget
end

function deploy_gas(shoot_from_pos, target_vec)
	local Net = _G.LuaNetworking
	local z_fix = {-0.05, -0.02, -0.05, -0.02, -0.07, -0.07, -0.1}
	target_vec = target_vec + Vector3(0, 0, z_fix[math.random(7)])
	local detonate_pos = managers.player:player_unit():position()
	managers.groupai:state():detonate_cs_grenade(detonate_pos, nil, _G.deathvox.grenadier_gas_duration)
end