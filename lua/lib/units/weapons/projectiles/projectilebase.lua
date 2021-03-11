local mvec1 = Vector3()
local mvec2 = Vector3()
local mrot1 = Rotation()


Hooks:PreHook(ProjectileBase,"init","deathvox_projectilebase_init",function(self,unit)
	self._primary_class = self._primary_class or "NO_WEAPON_CLASS"
	self._subclasses = self._subclasses or {}
end)

function ProjectileBase:get_weapon_class()
	return self._primary_class
end
function ProjectileBase:set_weapon_class(class)
	self._primary_class = class
end
function ProjectileBase:set_weapon_subclass(subclass)
	if not table.contains(self._subclasses,subclass) then 
		table.insert(self._subclasses,subclass)
	end
end
function ProjectileBase:remove_weapon_subclass(...) --can remove multiple simultaneously
	local num_subclasses = #self._subclasses
	if num_subclasses <= 0 then 
		return
	end
	for _,subclass in pairs({...}) do 
		for i = num_subclasses,1,-1 do 
			if self._subclasses[i] == subclass then 
				table.remove(self._subclasses,i)
				break
			end
		end
	end
end
function ProjectileBase:get_weapon_subclasses()
	return self._subclasses
end
function ProjectileBase:is_weapon_class(class)
	if not class then 
		return false
	end
	return self._primary_class == class
end
function ProjectileBase:is_weapon_subclass(...)
	local subclasses = self._weapon_subclasses

	local matched
	for _,category in pairs({...}) do 
		if table.contains(subclasses or {},category) then 
			--must not be missing match to any given parameters, and must positively match at least one parameter
			--(therefore if own subclasses table is empty, this will return false)
			matched = true
		else
			return false
		end
	end
	return matched
end



function ProjectileBase:update(unit, t, dt)
	if not self._simulated and not self._collided then
		self._unit:m_position(mvec1)
		mvector3.set(mvec2, self._velocity * dt)
		mvector3.add(mvec1, mvec2)
		self._unit:set_position(mvec1)

		if self._orient_to_vel then
			mrotation.set_look_at(mrot1, mvec2, math.UP)
			self._unit:set_rotation(mrot1)
		end

		self._velocity = Vector3(self._velocity.x, self._velocity.y, self._velocity.z - 980 * dt)
	end

	if self._sweep_data and not self._collided then
		self._unit:m_position(self._sweep_data.current_pos)

		local col_ray = nil
		local ignore_units = {}

		if self._thrower_unit then
			--to avoid colliding with the thrower, this prevents NPCs from hitting themselves with the projectile when launching it, along with player husks when FF is enabled
			table.insert(ignore_units, self._thrower_unit)

			--if the thrower has a shield equipped, ignore it as well (pretty important, even if the shield throw animation is used and the throw is timed, a collision can still easily happen)
			if alive(self._thrower_unit:inventory() and self._thrower_unit:inventory()._shield_unit) then
				table.insert(ignore_units, self._thrower_unit:inventory()._shield_unit)
			end
		end

		if #ignore_units > 0 then
			col_ray = World:raycast("ray", self._sweep_data.last_pos, self._sweep_data.current_pos, "slot_mask", self._sweep_data.slot_mask, "ignore_unit", ignore_units) --prevent husks from hitting themselves with RPGs/grenade launchers
		else
			col_ray = World:raycast("ray", self._sweep_data.last_pos, self._sweep_data.current_pos, "slot_mask", self._sweep_data.slot_mask)
		end

		if self._draw_debug_trail then
			Draw:brush(Color(1, 0, 0, 1), nil, 3):line(self._sweep_data.last_pos, self._sweep_data.current_pos)
		end

		if col_ray and col_ray.unit then
			mvector3.direction(mvec1, self._sweep_data.last_pos, self._sweep_data.current_pos)
			mvector3.add(mvec1, col_ray.position)
			self._unit:set_position(mvec1)
			self._unit:set_position(mvec1)

			if self._draw_debug_impact then
				Draw:brush(Color(0.5, 0, 0, 1), nil, 10):sphere(col_ray.position, 4)
				Draw:brush(Color(0.5, 1, 0, 0), nil, 10):sphere(self._unit:position(), 3)
			end

			col_ray.velocity = self._unit:velocity()
			self._collided = true

			self:_on_collision(col_ray)
		end

		self._unit:m_position(self._sweep_data.last_pos)
	end
end

function ProjectileBase.throw_projectile(projectile_type, pos, dir, owner_peer_id, npc_unit, npc_throwable)
	if not ProjectileBase.check_time_cheat(projectile_type, owner_peer_id) then
		return
	end

	local tweak_entry = tweak_data.blackmarket.projectiles[projectile_type]
	local unit_name = Idstring(not Network:is_server() and tweak_entry.local_unit or tweak_entry.unit)
	local unit = World:spawn_unit(unit_name, pos, Rotation(dir, math.UP))

	if npc_unit then
		if not Network:is_server() then
			return
		end

		if alive(npc_unit) then
			unit:base():set_thrower_unit(npc_unit)

			if not npc_throwable then
				unit:base():set_weapon_unit(npc_unit:inventory():equipped_unit())
			end
		end
	else
		if owner_peer_id and managers.network:session() then
			local peer = managers.network:session():peer(owner_peer_id)
			local thrower_unit = peer and peer:unit()

			if alive(thrower_unit) then
				unit:base():set_thrower_unit(thrower_unit)

				if not tweak_entry.throwable and thrower_unit:movement() and thrower_unit:movement():current_state() then
					unit:base():set_weapon_unit(thrower_unit:movement():current_state()._equipped_unit)
				end
			end
		end
	end

	unit:base():throw({
		dir = dir,
		projectile_entry = projectile_type
	})

	if not npc_unit then
		if unit:base().set_owner_peer_id then
			unit:base():set_owner_peer_id(owner_peer_id)
		end
	end

	local projectile_type_index = tweak_data.blackmarket:get_index_from_projectile_id(projectile_type)
	local sync_peer_id = 0

	if not npc_unit and owner_peer_id then
		sync_peer_id = owner_peer_id
	end

	managers.network:session():send_to_peers_synched("sync_throw_projectile", unit:id() ~= -1 and unit or nil, pos, dir, projectile_type_index, sync_peer_id)

	if tweak_data.blackmarket.projectiles[projectile_type].impact_detonation then
		unit:damage():add_body_collision_callback(callback(unit:base(), unit:base(), "clbk_impact"))
		unit:base():create_sweep_data()
	end

	return unit
end


if deathvox:IsTotalCrackdownEnabled() then 

	function ProjectileBase:throw(params)
		self._owner = params.owner
		local velocity = params.dir
		local adjust_z = 50
		local launch_speed = 250
		local push_at_body_index = nil

		if params.projectile_entry then 
			if tweak_data.projectiles[params.projectile_entry] then
				adjust_z = tweak_data.projectiles[params.projectile_entry].adjust_z or adjust_z
				launch_speed = tweak_data.projectiles[params.projectile_entry].launch_speed or launch_speed
				push_at_body_index = tweak_data.projectiles[params.projectile_entry].push_at_body_index
			end
			if tweak_data.blackmarket.projectiles[params.projectile_entry] then 
				self:set_projectile_entry(params.projectile_entry)
			end
		end
		
		if self._thrower_unit == managers.player:local_player() then 
			launch_speed = launch_speed * managers.player:upgrade_value(self:get_weapon_class() or "NO_WEAPON_CLASS","projectile_velocity_mul",1)
		end

		velocity = velocity * launch_speed
		velocity = Vector3(velocity.x, velocity.y, velocity.z + adjust_z)
		local mass_look_up_modifier = self._mass_look_up_modifier or 2
		local mass = math.max(mass_look_up_modifier * (1 + math.min(0, params.dir.z)), 1)

		if self._simulated then
			if push_at_body_index then
				self._unit:push_at(mass, velocity, self._unit:body(push_at_body_index):center_of_mass())
			else
				self._unit:push_at(mass, velocity, self._unit:position())
			end
		else
			self._velocity = velocity
		end

		if params.projectile_entry and tweak_data.blackmarket.projectiles[params.projectile_entry] then
		
			local tweak_entry = tweak_data.blackmarket.projectiles[params.projectile_entry]
			local physic_effect = tweak_entry.physic_effect

			if physic_effect then
				World:play_physic_effect(physic_effect, self._unit)
			end

			if tweak_entry.add_trail_effect then
				self:add_trail_effect(tweak_entry.add_trail_effect)
			end

			local unit_name = tweak_entry.sprint_unit

			if unit_name then
				local new_dir = Vector3(params.dir.y * -1, params.dir.x, params.dir.z)
				local sprint = World:spawn_unit(Idstring(unit_name), self._unit:position() + new_dir * 50, self._unit:rotation())
				local rot = Rotation(params.dir, math.UP)

				mrotation.x(rot, mvec1)
				mvector3.multiply(mvec1, 0.15)
				mvector3.add(mvec1, new_dir)
				mvector3.add(mvec1, math.UP / 2)
				mvector3.multiply(mvec1, 100)
				sprint:push_at(mass, mvec1, sprint:position())
			end

--			self:set_projectile_entry(params.projectile_entry)
		end
	end


	Hooks:PostHook(ProjectileBase,"set_projectile_entry","deathvox_projectilebase_set_projectile_entry",function(self,projectile_entry)
		local entry = self._tweak_projectile_entry or projectile_entry
		local projectile_td = tweak_data.blackmarket.projectiles[entry]
		if projectile_td then 
			if projectile_td.throwable and not projectile_td.is_a_grenade then 
				self:set_weapon_class("class_throwing")
				if projectile_td.is_poison then	--this flag is added by tcd, not vanilla
					self:set_weapon_subclass("subclass_poison")
				end
			end
			if projectile_td.is_a_grenade then 
				self:set_weapon_class("class_grenade")
				--not really used but might as well have it there
			end
		else
--			log("TOTAL CRACKDOWN: Error! ProjectileBase:set_projectile_entry(" .. tostring(projectile_entry) .. "): No tweak entry for ".. tostring(entry))
		end
		
	end)
end
