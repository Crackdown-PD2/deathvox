function GamePlayCentralManager:do_shotgun_push(unit, hit_pos, dir, distance, attacker)
	if not distance then
		return
	end

	local max_distance = 500

	if attacker == managers.player:player_unit() or managers.groupai:state():is_unit_team_AI(attacker) then
		max_distance = self:get_shotgun_push_range()
	end

	if distance < max_distance then
		if unit:id() > 0 then
			managers.network:session():send_to_peers_synched("sync_shotgun_push", unit, hit_pos, dir, distance, attacker)
		end

		self:_do_shotgun_push(unit, hit_pos, dir, distance, attacker)
	end
end

function GamePlayCentralManager:_do_shotgun_push(unit, hit_pos, dir, distance, attacker)
	if unit:movement()._active_actions[1] and unit:movement()._active_actions[1]:type() == "hurt" then
		unit:movement()._active_actions[1]:force_ragdoll(true)
	end

	local scale = math.clamp(1 - distance / self:get_shotgun_push_range(), 0.5, 1)
	local height = mvector3.distance(hit_pos, unit:position()) - 100
	local twist_dir = math.random(2) == 1 and 1 or -1
	local rot_acc = (dir:cross(math.UP) + math.UP * 0.5 * twist_dir) * -1000 * math.sign(height)
	local rot_time = 1 + math.rand(2)
	local nr_u_bodies = unit:num_bodies()
	local i_u_body = 0
	local is_dozer = unit:base() and unit:base().has_tag and unit:base():has_tag("tank")

	if is_dozer then
		scale = scale * 0.3 --get pushed with less force
		rot_time = rot_time * 0.4 --don't spin around so much
	end

	while nr_u_bodies > i_u_body do
		local u_body = unit:body(i_u_body)

		if u_body:enabled() and u_body:dynamic() then
			local body_mass = u_body:mass()

			World:play_physic_effect(Idstring("physic_effects/shotgun_hit"), u_body, Vector3(dir.x, dir.y, dir.z + 0.5) * 600 * scale, 4 * body_mass / math.random(2), rot_acc, rot_time)
			managers.mutators:notify(Message.OnShotgunPush, unit, hit_pos, dir, distance, attacker)
		end

		i_u_body = i_u_body + 1
	end
end
