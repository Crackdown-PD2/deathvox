local TCD_ENABLED = deathvox:IsTotalCrackdownEnabled()
local mvec3_set = mvector3.set
local mvec3_add = mvector3.add
local mvec3_dot = mvector3.dot
local mvec3_sub = mvector3.subtract
local mvec3_mul = mvector3.multiply
local mvec3_norm = mvector3.normalize
local mvec3_dir = mvector3.direction
local mvec3_set_l = mvector3.set_length
local mvec3_len = mvector3.length
local mvec3_dis = mvector3.distance_sq
local mvec3_cpy = mvector3.copy

local math_clamp = math.clamp
local math_lerp = math.lerp
local math_acos = math.acos
local math_pow = math.pow
local math_floor = math.floor
local math_random = math.random

local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()

local tmp_rot1 = Rotation()

local world_g = World

Hooks:PostHook(RaycastWeaponBase,"init","deathvox_init_weapon_classes",function(self,unit)
	self:set_weapon_class(tweak_data.weapon[self._name_id].primary_class)
	local name_id = self._name_id
	self._subclasses = tweak_data.weapon[self._name_id].subclasses and table.deep_map_copy(tweak_data.weapon[name_id].subclasses) or {}
	--init; reset elsewhere
end)

function RaycastWeaponBase:get_weapon_class()
	return self._primary_class
end

function RaycastWeaponBase:set_weapon_class(class)
	self._primary_class = class
end

function RaycastWeaponBase:set_weapon_subclass(subclass)
	if not table.contains(self._subclasses,subclass) then 
		table.insert(self._subclasses,subclass)
	end
end

function RaycastWeaponBase:remove_weapon_subclass(...) --can remove multiple simultaneously
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

function RaycastWeaponBase:get_weapon_subclasses()
	return self._subclasses
end

function RaycastWeaponBase:is_weapon_class(class)
	if not class then 
		return false
	end
	local gadget_override = self:gadget_overrides_weapon_functions()
	if gadget_override then 
		local td = gadget_override.name_id and tweak_data.weapon[gadget_override.name_id]
		return td and td.primary_class == class
	end
	return self._primary_class == class
end

function RaycastWeaponBase:is_weapon_subclass(...)
	local subclasses = self._weapon_subclasses
	
	local gadget_override = self:gadget_overrides_weapon_functions()
	if gadget_override then 
		local td = gadget_override.name_id and tweak_data.weapon[gadget_override.name_id]
		subclasses = td and td.subclasses or {}
	end
	
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

function RaycastWeaponBase:can_shoot_through_wall() --return true if raycasts can overpenetrate thin walls (40cm)
	local penetration_distance = 40
	local can_shoot_through = self._can_shoot_through_walls or self._money_shot_pierce
	
	return can_shoot_through,penetration_distance
end
function RaycastWeaponBase:can_shoot_through_shield() --return true if raycasts can overpenetrate shields
	local can_shoot_through = self._can_shoot_through_shield or self._money_shot_pierce
	return can_shoot_through
end

function RaycastWeaponBase:can_shoot_through_enemy() --return true if raycasts can overpenetrate enemies
	local can_shoot_through = self._can_shoot_through_enemy or self._money_shot_pierce
	return can_shoot_through
end

function RaycastWeaponBase:check_autoaim(from_pos, direction, max_dist, use_aim_assist, autohit_override_data)
	local autohit = use_aim_assist and self._aim_assist_data or self._autohit_data
	autohit = autohit_override_data or autohit
	local autohit_near_angle = autohit.near_angle
	local autohit_far_angle = autohit.far_angle
	local far_dis = autohit.far_dis
	local closest_error, closest_ray = nil
	local tar_vec = tmp_vec1
	local ignore_units = self._setup.ignore_units
	local obstruction_slotmask = self._bullet_slotmask

	if self:can_shoot_through_shield() then
		obstruction_slotmask = obstruction_slotmask - 8
	end

	local cone_distance = max_dist or self:weapon_range() or 20000
	local tmp_vec_to = Vector3()
	mvector3.set(tmp_vec_to, mvector3.copy(direction))
	mvector3.multiply(tmp_vec_to, cone_distance)
	mvector3.add(tmp_vec_to, mvector3.copy(from_pos))

	local cone_radius = mvector3.length(tmp_vec_to) / 4
	local enemies_in_cone = world_g:find_units("cone", from_pos, tmp_vec_to, cone_radius, managers.slot:get_mask("player_autoaim"))

	for _, enemy in pairs(enemies_in_cone) do
		local com = enemy:movement():m_com()

		mvector3.set(tar_vec, com)
		mvector3.subtract(tar_vec, from_pos)

		local tar_aim_dot = mvec3_dot(direction, tar_vec)

		if tar_aim_dot > 0 and (not max_dist or tar_aim_dot < max_dist) then
			local tar_vec_len = math_clamp(mvec3_norm(tar_vec), 1, far_dis)
			local error_dot = mvec3_dot(direction, tar_vec)
			local error_angle = math.acos(error_dot)
			local dis_lerp = math.pow(tar_aim_dot / far_dis, 0.25)
			local autohit_min_angle = math_lerp(autohit_near_angle, autohit_far_angle, dis_lerp)

			if error_angle < autohit_min_angle then
				local percent_error = error_angle / autohit_min_angle

				if not closest_error or percent_error < closest_error then
					tar_vec_len = tar_vec_len + 100

					mvector3.multiply(tar_vec, tar_vec_len)
					mvector3.add(tar_vec, from_pos)

					local vis_ray = world_g:raycast("ray", from_pos, tar_vec, "slot_mask", obstruction_slotmask, "ignore_unit", ignore_units)

					if vis_ray and vis_ray.unit:key() == enemy:key() and (not closest_error or error_angle < closest_error) then
						closest_error = error_angle
						closest_ray = vis_ray

						mvector3.set(tmp_vec1, com)
						mvector3.subtract(tmp_vec1, from_pos)

						local d = mvec3_dot(direction, tmp_vec1)

						mvector3.set(tmp_vec1, direction)
						mvector3.multiply(tmp_vec1, d)
						mvector3.add(tmp_vec1, from_pos)
						mvector3.subtract(tmp_vec1, com)

						closest_ray.distance_to_aim_line = mvec3_len(tmp_vec1)
					end
				end
			end
		end
	end

	return closest_ray
end

Hooks:PostHook(RaycastWeaponBase,"setup","cd_raycastweaponbase_setup",function(self, setup_data, damage_multiplier)
	local name_id = self._name_id
	local blueprint = self._blueprint
	self:set_weapon_class(managers.weapon_factory:get_primary_weapon_class_from_blueprint(name_id,blueprint))
	self._subclasses = managers.weapon_factory:get_weapon_subclasses_from_blueprint(name_id,blueprint)
end)

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
			self._laser_unit = world_g:spawn_unit(Idstring("units/payday2/weapons/wpn_npc_upg_fl_ass_smg_sho_peqbox/wpn_npc_upg_fl_ass_smg_sho_peqbox"), spawn_pos, spawn_rot)
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

function RaycastWeaponBase:_collect_hits(from, to)
	local ray_hits = nil
	local hit_enemy = false
	local went_through_wall = false
	local enemy_mask = managers.slot:get_mask("enemies")
	local wall_mask = managers.slot:get_mask("world_geometry", "vehicles")
	local shield_mask = managers.slot:get_mask("enemy_shield_check")
	local ai_vision_ids = Idstring("ai_vision")
	local bulletproof_ids = Idstring("bulletproof")

	if self:can_shoot_through_wall() then
		ray_hits = world_g:raycast_wall("ray", from, to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "thickness", 40, "thickness_mask", wall_mask)
	else
		ray_hits = world_g:raycast_all("ray", from, to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
	end

	local units_hit = {}
	local unique_hits = {}

	for i, hit in ipairs(ray_hits) do
		if not units_hit[hit.unit:key()] then
			units_hit[hit.unit:key()] = true
			unique_hits[#unique_hits + 1] = hit
			hit.hit_position = hit.position
			hit_enemy = hit_enemy or hit.unit:in_slot(enemy_mask)
			local weak_body = hit.body:has_ray_type(ai_vision_ids)
			weak_body = weak_body or hit.body:has_ray_type(bulletproof_ids)

			if not self:can_shoot_through_enemy() and hit_enemy then
				break
			elseif hit.unit:in_slot(wall_mask) then
				if weak_body then --actually this means it's not glass/similar, why they choose to call it this way I don' know. These surfaces (glass/similar) get penetrated with no restriction or requirement
					if self._can_shoot_through_wall then
						if went_through_wall then
							break
						else
							went_through_wall = true --can also be changed to count the number of wall penetrations and limit them like that (using went_through_wall = (went_through_wall or 0) + 1
						end
					else
						break
					end
				end
			elseif not self:can_shoot_through_shield() and hit.unit:in_slot(shield_mask) then
				break
			end
		end
	end

	return unique_hits, hit_enemy
end


--Original AutoFireSoundFix mod by 90e, uploaded by DarKobalt.
--Reverb fixed by Doctor Mister Cool, aka Didn'tMeltCables, aka DinoMegaCool
--New AFSF2 version (current 1.82) uploaded and maintained by Offyerrocker.
_G.AutoFireSoundFixBlacklist = {
	["saw"] = true,
	["saw_secondary"] = true,
	["flamethrower_mk2"] = true,
	["m134"] = true,
	["mg42"] = true,
	["shuno"] = true,
	["system"] = true,
	["par"] = true
}

--Allows users/modders to easily edit this blacklist from outside of this mod
Hooks:Register("AFSF2_OnWriteBlacklist")
Hooks:Add("BaseNetworkSessionOnLoadComplete","AFSF2_OnLoadComplete",function()
	Hooks:Call("AFSF2_OnWriteBlacklist",AutoFireSoundFixBlacklist)
end)

--Check for if AFSF's fix code should apply to this particular weapon
function RaycastWeaponBase:_soundfix_should_play_normal()
	local name_id = self:get_name_id() or "xX69dank420blazermachineXx" --if somehow get_name_id() returns nil, crashing won't be my fault. though i guess you'll have bigger problems in that case. also you'll look dank af B)
	if not self._setup.user_unit == managers.player:player_unit() then
		--don't apply fix for NPCs or other players
		return true
	elseif tweak_data.weapon[name_id].use_fix ~= nil then 
		--for custom weapons
		return tweak_data.weapon[name_id].use_fix
	elseif AutoFireSoundFixBlacklist[name_id] then
		--blacklisted sound
		return true
	elseif not self:weapon_tweak_data().sounds.fire_single then
		--no singlefire sound; should play normal
		return true
	end
	return false
	--else, AFSF2 can apply fix to this weapon
end
--[[
--Prevent playing sounds except for blacklisted weapons
local orig_fire_sound = RaycastWeaponBase._fire_sound
function RaycastWeaponBase:_fire_sound(...)
	if self:_soundfix_should_play_normal() then
		return orig_fire_sound(self,...)
	end
end
--]]
function RaycastWeaponBase:start_shooting()
	if self:_soundfix_should_play_normal() then
		self:_fire_sound()

		self._bullets_fired = 0
	end
	self._shooting = true
	self._next_fire_allowed = math.max(self._next_fire_allowed, self._unit:timer():time())
end

--stop_shooting is only used for fire sound loops, so playing individual single-fire sounds means it doesn't need to be called
RaycastWeaponBase.orig_stop_shooting = RaycastWeaponBase.orig_stop_shooting or RaycastWeaponBase.stop_shooting
function RaycastWeaponBase:stop_shooting(...)
	if self:_soundfix_should_play_normal() then
		return RaycastWeaponBase.orig_stop_shooting(self,...)
	end
end


local mvec_to = Vector3()
local mvec_spread_direction = Vector3()

function RaycastWeaponBase:fire(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	local pm = managers.player
	if pm:has_activate_temporary_upgrade("temporary", "no_ammo_cost_buff") then
		pm:deactivate_temporary_upgrade("temporary", "no_ammo_cost_buff")

		if pm:has_category_upgrade("temporary", "no_ammo_cost") then
			pm:activate_temporary_upgrade("temporary", "no_ammo_cost")
		end
	end
	
	if self._autoaim and self._active_modify_mutator then
		self._active_modify_mutator:check_modify_weapon(self)
	end
	
	if not self:_soundfix_should_play_normal() then 
		self._bullets_fired = 0
		self:play_tweak_data_sound(self:weapon_tweak_data().sounds.fire_single,"fire_single")
	elseif self._bullets_fired then
	--the game plays starts the firesound when firing, in addition to calling _fire_sound()
	--this causes some firesounds to play twice, while also not playing the correct fire sound.
	--so U200 both broke AutoFireSoundFix, made the existing problem worse, and then added a new problem on top of that
	
		if self._bullets_fired == 1 and self:weapon_tweak_data().sounds.fire_single then
			self:play_tweak_data_sound("stop_fire")
			self:play_tweak_data_sound("fire_auto", "fire")
		end
		self:play_tweak_data_sound(self:weapon_tweak_data().sounds.fire_single,"fire_single")
		
		self._bullets_fired = self._bullets_fired + 1
	end

	
	local user_unit = self._setup.user_unit
	local is_player = user_unit == pm:player_unit()
	local consume_ammo = not pm:has_active_temporary_property("bullet_storm") and (not pm:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier") or not pm:has_category_upgrade("player", "berserker_no_ammo_cost")) or not is_player
	local ammo_usage = self:ammo_usage()	
	local base = self:ammo_base()
	local mag = base:get_ammo_remaining_in_clip()
		
	local mutator = nil

	if managers.mutators:is_mutator_active(MutatorPiggyRevenge) then
		mutator = managers.mutators:get_mutator(MutatorPiggyRevenge)
	end

	if mutator and mutator.get_free_ammo_chance and mutator:get_free_ammo_chance() then
		ammo_usage = 0
	end

	

	--if consume_ammo and (is_player or Network:is_server()) then
	if consume_ammo then

		if base:get_ammo_remaining_in_clip() == 0 then
			return
		end

		local remaining_ammo = mag - ammo_usage
		if remaining_ammo < 0 then
			ammo_usage = ammo_usage + remaining_ammo
			remaining_ammo = 0
		end
		
		if is_player then
			for _, category in ipairs(self:weapon_tweak_data().categories) do
				if pm:has_category_upgrade(category, "consume_no_ammo_chance") then
					local roll = math.rand(1)
					local chance = pm:upgrade_value(category, "consume_no_ammo_chance", 0)

					if roll < chance then
						ammo_usage = 0

--						print("NO AMMO COST")
					end
				end
			end
		end

		if mag > 0 and remaining_ammo <= (self.AKIMBO and 1 or 0) then
			local w_td = self:weapon_tweak_data()

			if w_td.animations and w_td.animations.magazine_empty then
				self:tweak_data_anim_play("magazine_empty")
			end

			if w_td.sounds and w_td.sounds.magazine_empty then
				self:play_tweak_data_sound("magazine_empty")
			end

			if w_td.effects and w_td.effects.magazine_empty then
				self:_spawn_tweak_data_effect("magazine_empty")
			end

			self:set_magazine_empty(true)
		end

		base:set_ammo_remaining_in_clip(base:get_ammo_remaining_in_clip() - ammo_usage)
		self:use_ammo(base, ammo_usage)
	end
	
	local do_money_shot
	if is_player and pm:has_category_upgrade(self:get_weapon_class(),"money_shot") then
		if mag == 1 then
			self._money_shot_ready = true
			self._money_shot_pierce = pm:has_category_upgrade(self:get_weapon_class(),"money_shot_pierce")
			
			local money_trail = Idstring("effects/particles/weapons/trail_dv_sniper")
			local money_muzzle = Idstring("effects/particles/weapons/money_muzzle_fps")
			
			self._trail_effect_table = {
				effect = money_trail,
				position = Vector3(),
				normal = Vector3()
			}
			
			self._muzzle_effect_table = {
				force_synch = true,
				effect = money_muzzle,
				parent = self._obj_fire
			}
			
--			self:play_sound("c4_explode_metal")
		else
			self._money_shot_ready = false
			self._money_shot_pierce = false
			
			self._trail_effect_table = {
				effect = self._trail_effect or self.TRAIL_EFFECT,
				position = Vector3(),
				normal = Vector3()
			}
			
			self._muzzle_effect_table = {
				force_synch = true,
				effect = self._muzzle_effect,
				parent = self._obj_fire
			}
			
		end
	end

	self:_check_ammo_total(user_unit)

	if alive(self._obj_fire) then
		self:_spawn_muzzle_effect(from_pos, direction)
	end

	self:_spawn_shell_eject_effect()

	local ray_res = self:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit, ammo_usage)
	
	if self._alert_events and ray_res.rays then
		self:_check_alert(ray_res.rays, from_pos, direction, user_unit)
	end
--[[
	if ray_res.enemies_in_cone then
		for enemy_data, dis_error in pairs(ray_res.enemies_in_cone) do
			if not enemy_data.unit:movement():cool() then
				enemy_data.unit:character_damage():build_suppression(suppr_mul * dis_error * self._suppression, self._panic_suppression_chance)
			end
		end
	end
--]]
	pm:send_message(Message.OnWeaponFired, nil, self._unit, ray_res)

	return ray_res
end

local reflect_result = Vector3()

function InstantBulletBase:on_ricochet(col_ray, weapon_unit, user_unit, damage, blank, no_sound, guaranteed_hit, restrictive_angles)
	local ignore_units = {}
	local can_shoot_through_enemy = nil
	local can_shoot_through_shield = nil

	local ricochet_range = guaranteed_hit and 1000 or 2000 --modify as you wish
	local impact_pos = col_ray.hit_position or col_ray.position
	if weapon_unit and alive(weapon_unit) then
		local weapon_base = weapon_unit:base()
		--shoot-through checks that will avoid crashing if the weapon somehow ceases to exist
		
		can_shoot_through_shield = weapon_base:can_shoot_through_shield()
		can_shoot_through_enemy = weapon_base:can_shoot_through_enemy()

		--usually a weapon has itself and its user ignored to avoid unnecessary collisions. These checks are here in case we want player husks to shoot visible ricochets (pretty sure other players can't see the ricochet if only local players can trigger them)
		if weapon_unit:base()._setup and weapon_unit:base()._setup.ignore_units then
			ignore_units = weapon_unit:base()._setup.ignore_units
		else
			table.insert(ignore_units, weapon_unit)

			if user_unit then
				table.insert(ignore_units, user_unit)
			end
		end
		
		if guaranteed_hit and weapon_base.is_category and managers.player:has_category_upgrade(weapon_base:get_weapon_class(), "class_rapidfire_guaranteed_hit_ricochet_bullets") then
			local bodies = world_g:find_bodies("intersect", "sphere", impact_pos, ricochet_range, managers.slot:get_mask("enemies")) --use a sphere to find nearby enemies
			local can_hit_enemy = false

			if #bodies > 0 then
				for _, hit_body in ipairs(bodies) do
					local hit_unit = hit_body:unit()

					if hit_unit.character_damage and hit_unit:character_damage() and hit_unit:character_damage().damage_bullet and not hit_unit:character_damage():dead() then --check if the enemy can take bullet damage and they're not dead
						local hit_ray = world_g:raycast("ray", impact_pos, hit_body:center_of_mass(), "slot_mask", self:bullet_slotmask(), "ignore_unit", ignore_units) --check if the enemy can actually be hit (isn't obstructed)

						if hit_ray and hit_ray.unit and hit_ray.unit:key() == hit_unit:key() then --make sure the one that's hit is the same as that was found in this loop
							mvector3.set(reflect_result, hit_ray.ray)
							col_ray.ray = hit_ray.ray
							can_hit_enemy = true

							break --to select and only hit that specific enemy
						end
					end
				end

				if not can_hit_enemy then
					return
				end
			else
				return
			end
		else
			mvector3.set_zero(reflect_result)
			mvector3.set(reflect_result, col_ray.ray) --get the direction of the bullet
			mvector3.add(reflect_result, -2 * col_ray.ray:dot(col_ray.normal) * col_ray.normal) --use the direction of the bullet to calculate where it should bounce off to

			local angle = math.abs(mvector3.angle(col_ray.ray, reflect_result))
			local allowed_angles = {0, 175}

			if restrictive_angles then
				allowed_angles = {0, 90}
			end

			local can_ricochet = not (angle < allowed_angles[1]) and not (angle > allowed_angles[2])

			if not can_ricochet then
				return
			end

			if not restrictive_angles then --if there's no restriction, apply some spread to avoid perfect 175° bounces
				local ricochet_spread_angle = {10, 30}

				mvector3.spread(reflect_result, math.random(ricochet_spread_angle[1], ricochet_spread_angle[2]))
			end
		end
	end



	local from_pos = col_ray.hit_position + col_ray.normal

	--usual collect_hits stuff to use proper penetration
	local ray_hits = nil
	local hit_enemy = false
	local enemy_mask = managers.slot:get_mask("enemies")
	local wall_mask = managers.slot:get_mask("world_geometry", "vehicles")
	local shield_mask = managers.slot:get_mask("enemy_shield_check")
	local ai_vision_ids = Idstring("ai_vision")
	local bulletproof_ids = Idstring("bulletproof")

	ray_hits = world_g:raycast_all("ray", from_pos, from_pos + reflect_result * ricochet_range, "slot_mask", self:bullet_slotmask(), "ignore_unit", ignore_units)

	local units_hit = {}
	local unique_hits = {}

	for i, hit in ipairs(ray_hits) do
		if not units_hit[hit.unit:key()] then
			units_hit[hit.unit:key()] = true
			unique_hits[#unique_hits + 1] = hit
			hit.hit_position = hit.position
			hit_enemy = hit_enemy or hit.unit:in_slot(enemy_mask)
			local weak_body = hit.body:has_ray_type(ai_vision_ids)
			weak_body = weak_body or hit.body:has_ray_type(bulletproof_ids)

			if not can_shoot_through_enemy and hit_enemy then
				break
			elseif hit.unit:in_slot(wall_mask) then
				if weak_body then
					break
				end
			elseif not can_shoot_through_shield and hit.unit:in_slot(shield_mask) then
				break
			end
		end
	end

	local hit_enemies = {}

	for _, hit in ipairs(unique_hits) do
		if hit.unit and hit.unit:character_damage() then
			table.insert(hit_enemies, hit.unit)
		end

		if guaranteed_hit then
			if not hit.unit:in_slot(managers.slot:get_mask("civilians")) then --ignore civs with guaranteed hits since you are not able to control where they go to (remove this check if you still want to make them to kill civs that happen to be in the way)
				InstantBulletBase:on_collision(hit, weapon_unit, user_unit, damage, blank, no_sound, true)
			end
		else
			InstantBulletBase:on_collision(hit, weapon_unit, user_unit, damage, blank, no_sound, true)
		end
	end

	for _, d in pairs(hit_enemies) do --if the ricochet hit a character, count it as an actual hit instead of a missed shot
		managers.statistics:shot_fired({
			skip_bullet_count = true,
			hit = true,
			weapon_unit = weapon_unit
		})
	end

	local furthest_hit = unique_hits[#unique_hits]

	--guaranteed hits use sniper trails to show them, while simulated hits simply use a bullet trail
	if guaranteed_hit then
		if not self._trail_length then
			self._trail_length = world_g:effect_manager():get_initial_simulator_var_vector2(Idstring("effects/particles/weapons/sniper_trail"), Idstring("trail"), Idstring("simulator_length"), Idstring("size"))
		end

		local trail = world_g:effect_manager():spawn({
			effect = Idstring("effects/particles/weapons/sniper_trail"),
			position = from_pos,
			normal = reflect_result
		})

		mvector3.set_y(self._trail_length, furthest_hit and furthest_hit.distance or ricochet_range)
		world_g:effect_manager():set_simulator_var_vector2(trail, Idstring("trail"), Idstring("simulator_length"), Idstring("size"), self._trail_length)
	else
		local trail = world_g:effect_manager():spawn({
			effect = Idstring("effects/particles/weapons/weapon_trail"),
			position = from_pos,
			normal = reflect_result
		})

		if furthest_hit then
			world_g:effect_manager():set_remaining_lifetime(trail, math.clamp((furthest_hit.distance - 600) / 10000, 0, furthest_hit.distance))
		else
			world_g:effect_manager():set_remaining_lifetime(trail, math.clamp((ricochet_range - 600) / 10000, 0, ricochet_range))
		end
	end
end

function InstantBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank, no_sound, already_ricocheted, critical_hit)
	if not blank and Network:is_client() and user_unit ~= managers.player:player_unit() then
		blank = true
	end

	local hit_unit = col_ray.unit
	local is_shield
	local enemy_unit
	if hit_unit:in_slot(managers.slot:get_mask("enemy_shield_check")) then
		local _enemy_unit = hit_unit:parent()
		if alive(_enemy_unit) then
			is_shield = true
			enemy_unit = _enemy_unit
		end
	end
	local weap_unit = alive(weapon_unit) and weapon_unit or nil
	local weapon_base = weap_unit and weap_unit:base()

	if not blank then
		if TCD_ENABLED and weap_unit and not critical_hit then
			critical_hit = self:calculate_crit(weap_unit, user_unit)
		end

		local has_category = weapon_base and not weapon_base.thrower_unit and weapon_base.is_category
		if has_category and user_unit == managers.player:player_unit() and hit_unit then
			local primary_class = weapon_base:get_weapon_class()
			local ricochet_damage_penalty = managers.player:upgrade_value(primary_class,"ricochet_damage_penalty",0)
			
			if already_ricocheted then
				if critical_hit and managers.player:has_category_upgrade("player","crit_ricochet_no_damage_penalty") then 
					--understandable have a nice day
				else
					damage = damage * ricochet_damage_penalty
				end
			elseif managers.player:has_category_upgrade(primary_class, "ricochet_bullets") then
				local can_bounce_off = false
				
				local can_shoot_through_wall = weapon_base:can_shoot_through_wall()
				local can_shoot_through_shield = weapon_base:can_shoot_through_shield()
				
				if not can_shoot_through_shield and hit_unit:in_slot(managers.slot:get_mask("enemy_shield_check")) then
					can_bounce_off = true
				elseif not can_shoot_through_wall and hit_unit:in_slot(managers.slot:get_mask("world_geometry", "vehicles")) and (col_ray.body:has_ray_type(Idstring("ai_vision")) or col_ray.body:has_ray_type(Idstring("bulletproof"))) then
					can_bounce_off = true
				end

				if can_bounce_off then
					InstantBulletBase:on_ricochet(col_ray, weap_unit, user_unit, damage, blank, no_sound, critical_hit)
				end
			end
		end

		--more proper checks for knocking back a shield
		if is_shield and weapon_base and weapon_base._shield_knock and enemy_unit then
			if enemy_unit:character_damage() and enemy_unit:character_damage().dead and not enemy_unit:character_damage():dead() then
				if enemy_unit:base():char_tweak() and not enemy_unit:base().is_phalanx and enemy_unit:base():char_tweak().damage.shield_knocked and not enemy_unit:character_damage():is_immune_to_shield_knockback() then
					local MIN_KNOCK_BACK = 200
					local KNOCK_BACK_CHANCE = 0.8
					local dmg_ratio = math.min(damage, MIN_KNOCK_BACK)
					dmg_ratio = dmg_ratio / MIN_KNOCK_BACK + 1

					local rand = math.random() * dmg_ratio

					if KNOCK_BACK_CHANCE < rand then
						local damage_info = {
							damage = 0,
							type = "shield_knock",
							variant = "melee",
							col_ray = col_ray,
							result = {
								variant = "melee",
								type = "shield_knock"
							}
						}

						enemy_unit:character_damage():_call_listeners(damage_info)
					end
				end
			end
		end
	end

	local play_impact_flesh = not hit_unit:character_damage() or not hit_unit:character_damage()._no_blood

	if hit_unit:damage() and managers.network:session() and col_ray.body:extension() and col_ray.body:extension().damage then
		local damage_body_extension = true
		local character_unit = nil

		if hit_unit:character_damage() then
			character_unit = hit_unit
		elseif is_shield and hit_unit:parent():character_damage() then
			character_unit = hit_unit:parent()
		end
		
		--if the unit hit is a character or a character's shield, do a friendly fire check before damaging the body extension that was hit
		if character_unit and character_unit:character_damage().is_friendly_fire and character_unit:character_damage():is_friendly_fire(user_unit) then
			damage_body_extension = false
		end

		if damage_body_extension then
			local sync_damage = not blank and hit_unit:id() ~= -1
			local network_damage = math.ceil(damage * 163.84)
			damage = network_damage / 163.84

			if sync_damage then
				local normal_vec_yaw, normal_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.normal, 128, 64)
				local dir_vec_yaw, dir_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.ray, 128, 64)

				managers.network:session():send_to_peers_synched("sync_body_damage_bullet", col_ray.unit:id() ~= -1 and col_ray.body or nil, user_unit:id() ~= -1 and user_unit or nil, normal_vec_yaw, normal_vec_pitch, col_ray.position, dir_vec_yaw, dir_vec_pitch, math.min(16384, network_damage))
			end

			local local_damage = not blank or hit_unit:id() == -1

			if local_damage then
				col_ray.body:extension().damage:damage_bullet(user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
				col_ray.body:extension().damage:damage_damage(user_unit, col_ray.normal, col_ray.position, col_ray.ray, damage)

				if weapon_base and weapon_base.categories and weapon_base:categories() then
					for _, category in ipairs(weapon_base:categories()) do
						col_ray.body:extension().damage:damage_bullet_type(category, user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
					end
				end
			end
		end
	end

	local result = nil

	if weap_unit and hit_unit:character_damage() and hit_unit:character_damage().damage_bullet then
		local is_alive = not hit_unit:character_damage():dead()
		
		local shuffle_cut_stacks = 0
		
		if not blank then
			local pierce_armor = false
			
			if user_unit == managers.player:player_unit() then
				if has_category and weapon_base:is_weapon_class("class_shotgun") then 
					local point_blank_range = managers.player:upgrade_value("class_shotgun","point_blank_basic",0)
					if point_blank_range > 0 then  --right now, basic and aced have the same proc range, but if you want to change that, this is where you'd do it
						if col_ray and col_ray.distance and (col_ray.distance <= point_blank_range) then 
							pierce_armor = true
							damage = damage * (1 + managers.player:upgrade_value("class_shotgun","point_blank_aced",0)) 
						end
					end
				end

				local projectile_td = nil

				if weapon_base then
					local projectile_entry = weapon_base._projectile_entry or weapon_base._tweak_projectile_entry
					projectile_td = projectile_entry and tweak_data.blackmarket.projectiles[projectile_entry]
				end

				if projectile_td and projectile_td.throwable and not projectile_td.is_a_grenade then 
				
					if managers.player:has_category_upgrade("class_throwing","throwing_boosts_melee_loop") then 
						local stacks = managers.player:get_property("shuffle_cut_melee_bonus_damage",0)
						local max_stacks = managers.player:upgrade_value("class_throwing","throwing_boosts_melee_loop",0)[1]
						managers.player:set_property("shuffle_cut_melee_bonus_damage",math.min(stacks+1,max_stacks))
					end

					local throwing_weapon_add_mul = 1

					if managers.player:has_category_upgrade("class_throwing","projectile_charged_damage_mul") then 
						throwing_weapon_add_mul = throwing_weapon_add_mul + managers.player:get_property("charged_throwable_damage_bonus",0)
						managers.player:set_property("charged_throwable_damage_bonus",0)
					end
					if managers.player:has_category_upgrade("class_melee","melee_boosts_throwing_loop") then 
						shuffle_cut_stacks = managers.player:get_property("shuffle_cut_throwing_bonus_damage",0)
						if shuffle_cut_stacks > 0 then 
							local shuffle_cut_bonus = managers.player:upgrade_value("class_melee","melee_boosts_throwing_loop")[2]
							throwing_weapon_add_mul = throwing_weapon_add_mul + shuffle_cut_bonus
						end
					end
					throwing_weapon_add_mul = throwing_weapon_add_mul + managers.player:upgrade_value("class_throwing","weapon_class_damage_mul",0)
					damage = damage * throwing_weapon_add_mul
				end
			end

			pierce_armor = pierce_armor or weapon_base and weapon_base._use_armor_piercing or weapon_base and weapon_base._money_shot_pierce

			local knock_down = weapon_base and weapon_base._knock_down and weapon_base._knock_down > 0 and math.random() < weapon_base._knock_down
			result = self:give_impact_damage(col_ray, weap_unit, user_unit, damage, pierce_armor, false, knock_down, weapon_base._stagger, weapon_base._variant, critical_hit)
		end
		
		local is_dead = hit_unit:character_damage():dead()
		
		if result and shuffle_cut_stacks ~= 0 then 
			if managers.player:has_category_upgrade("class_throwing","melee_loop_refund") and is_dead then 
				--on throwing weapon kill with shuffle and cut aced, do not consume a throwing damage bonus stack
			else
				--if the hit was not lethal or shuffle and cut is not aced, then consume a stack
				managers.player:set_property("shuffle_cut_throwing_bonus_damage",math.max(shuffle_cut_stacks - 1,0))
			end
		end


		if not is_dead then
			--if no damage is taken (blocked by grace period, script, mission stuff, etc). The less impact effects, the better
			if not result or result == "friendly_fire" then
				play_impact_flesh = false
			end
		end

		local push_multiplier = self:_get_character_push_multiplier(weap_unit, is_alive and is_dead)

		managers.game_play_central:physics_push(col_ray, push_multiplier)
	else
		managers.game_play_central:physics_push(col_ray)
	end

	if play_impact_flesh then
		managers.game_play_central:play_impact_flesh({
			col_ray = col_ray,
			no_sound = no_sound
		})
		self:play_impact_sound_and_effects(weap_unit, col_ray, no_sound)
	end

	return result
end

function InstantBulletBase:give_impact_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing, shield_knock, knock_down, stagger, variant, critical_hit)
	local action_data = {
		variant = variant or "bullet",
		damage = damage,
		weapon_unit = weapon_unit,
		attacker_unit = user_unit,
		col_ray = col_ray,
		armor_piercing = armor_piercing,
		shield_knock = shield_knock,
		origin = user_unit:position(),
		knock_down = knock_down,
		stagger = stagger,
		critical_hit = critical_hit
	}
	local defense_data = col_ray.unit:character_damage():damage_bullet(action_data)

	return defense_data
end

function InstantExplosiveBulletBase:on_collision_server(position, normal, damage, user_unit, weapon_unit, owner_peer_id, owner_selection_index)
	local slot_mask = managers.slot:get_mask("explosion_targets")
	--local critical_hit = self:calculate_crit(weapon_unit, user_unit) i have this fully implemented, but commented out, if we ever want explosive bullet crits.
	managers.explosion:play_sound_and_effects(position, normal, self.RANGE, self.EFFECT_PARAMS)
	local params = {
		hit_pos = position,
		range = self.RANGE,
		collision_slotmask = slot_mask,
		curve_pow = self.CURVE_POW,
		damage = damage,
		player_damage = damage * self.PLAYER_DMG_MUL,
		ignore_unit = weapon_unit,
		user = user_unit,
		--critical_hit = critical_hit,
		owner = weapon_unit
	}

	local hit_units, splinters, results = managers.explosion:detect_and_give_dmg(params)
	local network_damage = math.ceil(damage * 163.84)

	managers.network:session():send_to_peers_synched("sync_explode_bullet", position, normal, math.min(16384, network_damage), owner_peer_id)

	if managers.network:session():local_peer():id() == owner_peer_id then
		local enemies_hit = (results.count_gangsters or 0) + (results.count_cops or 0)
		local enemies_killed = (results.count_gangster_kills or 0) + (results.count_cop_kills or 0)

		managers.statistics:shot_fired({
			hit = false,
			weapon_unit = weapon_unit
		})

		for i = 1, enemies_hit do
			managers.statistics:shot_fired({
				skip_bullet_count = true,
				hit = true,
				weapon_unit = weapon_unit
			})
		end

		local weapon_pass, weapon_type_pass, count_pass, all_pass = nil

		for achievement, achievement_data in pairs(tweak_data.achievement.explosion_achievements) do
			weapon_pass = not achievement_data.weapon or true
			weapon_type_pass = not achievement_data.weapon_type or weapon_unit:base() and weapon_unit:base().weapon_tweak_data and weapon_unit:base():is_category(achievement_data.weapon_type)
			count_pass = not achievement_data.count or achievement_data.count <= (achievement_data.kill and enemies_killed or enemies_hit)
			all_pass = weapon_pass and weapon_type_pass and count_pass

			if all_pass and achievement_data.award then
				managers.achievment:award(achievement_data.award)
			end
		end
	else
		local peer = managers.network:session():peer(owner_peer_id)
		local SYNCH_MIN = 0
		local SYNCH_MAX = 31
		local count_cops = math.clamp(results.count_cops, SYNCH_MIN, SYNCH_MAX)
		local count_gangsters = math.clamp(results.count_gangsters, SYNCH_MIN, SYNCH_MAX)
		local count_civilians = math.clamp(results.count_civilians, SYNCH_MIN, SYNCH_MAX)
		local count_cop_kills = math.clamp(results.count_cop_kills, SYNCH_MIN, SYNCH_MAX)
		local count_gangster_kills = math.clamp(results.count_gangster_kills, SYNCH_MIN, SYNCH_MAX)
		local count_civilian_kills = math.clamp(results.count_civilian_kills, SYNCH_MIN, SYNCH_MAX)

		managers.network:session():send_to_peer_synched(peer, "sync_explosion_results", count_cops, count_gangsters, count_civilians, count_cop_kills, count_gangster_kills, count_civilian_kills, owner_selection_index)
	end
end
function RaycastWeaponBase:_suppress_units(from_pos, direction, distance, slotmask, user_unit, suppr_mul)
	local tmp_to = Vector3()

	mvector3.set(tmp_to, mvector3.copy(direction))
	mvector3.multiply(tmp_to, distance)
	mvector3.add(tmp_to, mvector3.copy(from_pos))

	local cone_radius = distance / 4
	local enemies_in_cone = world_g:find_units(user_unit, "cone", from_pos, tmp_to, cone_radius, slotmask)
	local enemies_to_suppress = {}

	--draw the cone to see where it goes
	local draw_suppression_cone = false

	if draw_suppression_cone and user_unit == managers.player:player_unit() then
		local draw_duration = 0.1
		local new_brush = Draw:brush(Color.white:with_alpha(0.5), draw_duration)
		new_brush:cone(from_pos, tmp_to, cone_radius)
	end

	if #enemies_in_cone > 0 then
		for _, enemy in ipairs(enemies_in_cone) do
			if Network:is_server() or user_unit == managers.player:player_unit() or enemy == managers.player:player_unit() then --clients only allow the local player to suppress or be suppressed (so that NPC husks don't suppress each other)
				if not table.contains(enemies_to_suppress, enemy) and enemy.character_damage and enemy:character_damage() and enemy:character_damage().build_suppression then --valid enemy + has suppression function
					if not enemy:movement().cool or enemy:movement().cool and not enemy:movement():cool() then --is alerted or can't be alerted at all (player)
						if enemy:character_damage().is_friendly_fire and not enemy:character_damage():is_friendly_fire(user_unit) then --not in the same team as the shooter
							local obstructed = world_g:raycast("ray", from_pos, enemy:movement():m_head_pos(), "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", "ai_vision", "report") --imitating AI checking for visibility for things like shouting

							if not obstructed then
								table.insert(enemies_to_suppress, enemy)
							end
						end
					end
				end
			end
		end

		if #enemies_to_suppress > 0 then
			for _, enemy in ipairs(enemies_to_suppress) do
				local enemy_distance = mvector3.distance(from_pos, enemy:movement():m_head_pos())
				local dis_lerp_value = math.clamp(enemy_distance, 0, distance) / distance
				
				if dis_lerp_value > 0.5 then
					dis_lerp_value = 0.5
				end

				local total_suppression = self._suppression

				if suppr_mul then
					total_suppression = total_suppression * suppr_mul
				end

				total_suppression = math.lerp(total_suppression, 0, dis_lerp_value) --scale suppression downwards and linearly, becoming 0 at maximum allowed distance or past that

				local total_panic_chance = false

				if self._panic_suppression_chance then
					total_panic_chance = self._panic_suppression_chance

					local suppr_lerp_value = math.clamp(total_suppression, 0, 4.5) / 4.5 --4.5 is the highest suppression value allowed for players, that point means maximum panic base chance

					total_panic_chance = math.lerp(0, total_panic_chance, suppr_lerp_value)
				end

				if total_suppression > 0 then
					if draw_suppression_cone and enemy:contour() then
						enemy:contour():add("medic_heal")
					end

					enemy:character_damage():build_suppression(total_suppression, total_panic_chance)
				end
			end
		end
	end
end

--taser bullets for taser sentries (currently used in total cd only) 
local MIN_KNOCK_BACK = 200 --WHY ARE THESE LOCAL VARIABLES
local KNOCK_BACK_CHANCE = 0.8

ElectricBulletBase = ElectricBulletBase or clone(InstantBulletBase)
ElectricBulletBase.id = "electric"

function ElectricBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank, no_sound)
	local hit_unit = col_ray.unit
	local shield_knock = false
	local is_shield = hit_unit:in_slot(8) and alive(hit_unit:parent())
	

	if is_shield and not hit_unit:parent():character_damage():is_immune_to_shield_knockback() and weapon_unit then
		shield_knock = weapon_unit:base()._shield_knock
		local dmg_ratio = math.min(damage, MIN_KNOCK_BACK)
		dmg_ratio = dmg_ratio / MIN_KNOCK_BACK + 1
		local rand = math.random() * dmg_ratio

		if KNOCK_BACK_CHANCE < rand then
			local enemy_unit = hit_unit:parent()

			if shield_knock and enemy_unit:character_damage() then
				local damage_info = {
					damage = 0,
					type = "shield_knock",
					variant = "melee",
					col_ray = col_ray,
					result = {
						variant = "melee",
						type = "shield_knock"
					}
				}

				enemy_unit:character_damage():_call_listeners(damage_info)
			end
		end
	end

	local play_impact_flesh = not hit_unit:character_damage() or not hit_unit:character_damage()._no_blood

	if hit_unit:damage() and managers.network:session() and col_ray.body:extension() and col_ray.body:extension().damage then
		local sync_damage = not blank and hit_unit:id() ~= -1
		local network_damage = math.ceil(damage * 163.84)
		damage = network_damage / 163.84

		if sync_damage then
			local normal_vec_yaw, normal_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.normal, 128, 64)
			local dir_vec_yaw, dir_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.ray, 128, 64)

			managers.network:session():send_to_peers_synched("sync_body_damage_bullet", col_ray.unit:id() ~= -1 and col_ray.body or nil, user_unit:id() ~= -1 and user_unit or nil, normal_vec_yaw, normal_vec_pitch, col_ray.position, dir_vec_yaw, dir_vec_pitch, math.min(16384, network_damage))
		end

		local local_damage = not blank or hit_unit:id() == -1

		if local_damage then
			col_ray.body:extension().damage:damage_bullet(user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
			col_ray.body:extension().damage:damage_damage(user_unit, col_ray.normal, col_ray.position, col_ray.ray, damage)

			if alive(weapon_unit) and weapon_unit:base().categories and weapon_unit:base():categories() then
				for _, category in ipairs(weapon_unit:base():categories()) do
					col_ray.body:extension().damage:damage_bullet_type(category, user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
				end
			end
		end
	end

	local result = nil

	if alive(weapon_unit) and hit_unit:character_damage() and hit_unit:character_damage().damage_bullet then
		local is_alive = not hit_unit:character_damage():dead()
		local knock_down = weapon_unit:base()._knock_down and weapon_unit:base()._knock_down > 0 and math.random() < weapon_unit:base()._knock_down
		result = self:give_impact_damage(col_ray, weapon_unit, user_unit, damage, weapon_unit:base()._use_armor_piercing, false, knock_down, weapon_unit:base()._stagger, weapon_unit:base()._variant)

		if result ~= "friendly_fire" then
			local is_dead = hit_unit:character_damage():dead()
			local push_multiplier = self:_get_character_push_multiplier(weapon_unit, is_alive and is_dead)

			managers.game_play_central:physics_push(col_ray, push_multiplier)
		else
			play_impact_flesh = false
		end
	else
		managers.game_play_central:physics_push(col_ray)
	end

	if play_impact_flesh then
		managers.game_play_central:play_impact_flesh({
			col_ray = col_ray,
			no_sound = no_sound
		})
		self:play_impact_sound_and_effects(weapon_unit, col_ray, no_sound)
	end

	return result
end

function ElectricBulletBase:give_impact_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing, shield_knock, knock_down, stagger, variant)
	local action_data = {
		variant = variant or "light",
		damage = damage,
		weapon_unit = weapon_unit,
		attacker_unit = user_unit,
		col_ray = col_ray,
		armor_piercing = armor_piercing,
		shield_knock = shield_knock,
		origin = user_unit:position(),
		knock_down = knock_down,
		stagger = stagger
	}
	local defense_data
	if col_ray.unit.character_damage then
		if col_ray.unit:character_damage().damage_tase then 
			defense_data = col_ray.unit:character_damage():damage_tase(action_data)
		elseif col_ray.unit:character_damage().damage_bullet then 
			defense_data = col_ray.unit:character_damage():damage_bullet(action_data)
		end
	end

	return defense_data
end

function RaycastWeaponBase:is_heavy_weapon() --deprecated, do not use
	log("function RaycastWeaponBase:is_heavy_weapon() is deprecated! Please use RaycastWeaponBase:is_weapon_class(\"class_heavy\") instead!")
	return false
end

if TCD_ENABLED then
	
	function RaycastWeaponBase:update_next_shooting_time()
		if self:is_weapon_class("class_shotgun") and self:fire_mode() == "auto" then 
			if tweak_data.weapon[self._name_id].CLIP_AMMO_MAX == 2 then 
				if managers.player:has_category_upgrade("class_shotgun","heartbreaker_doublebarrel") then 
					self._next_fire_allowed = 0
					return
				end
			end
		end

		local next_fire = self:weapon_fire_rate() / self:fire_rate_multiplier()
		self._next_fire_allowed = self._next_fire_allowed + next_fire
	end

	function RaycastWeaponBase:replenish()
		local pm = managers.player
		local ammo_max_multiplier = pm:upgrade_value("player", "extra_ammo_multiplier", 1)

		for _, category in ipairs(self:weapon_tweak_data().categories) do
			ammo_max_multiplier = ammo_max_multiplier * pm:upgrade_value(category, "extra_ammo_multiplier", 1)
		end

		ammo_max_multiplier = ammo_max_multiplier + ammo_max_multiplier * (self._total_ammo_mod or 0)
		ammo_max_multiplier = managers.modifiers:modify_value("WeaponBase:GetMaxAmmoMultiplier", ammo_max_multiplier)
		local ammo_max_per_clip = self:calculate_ammo_max_per_clip()
		local ammo_max = math.round((tweak_data.weapon[self._name_id].AMMO_MAX + pm:upgrade_value(self._name_id, "clip_amount_increase") * ammo_max_per_clip) * ammo_max_multiplier)
		ammo_max_per_clip = math.min(ammo_max_per_clip, ammo_max)

		self:set_ammo_max_per_clip(ammo_max_per_clip)
		self:set_ammo_max(ammo_max)
		self:set_ammo_total(ammo_max)
		self:set_ammo_remaining_in_clip(ammo_max_per_clip)
		
		self._reloaded_to_full = true --currently only used for Money Shot 

		self._ammo_pickup = tweak_data.weapon[self._name_id].AMMO_PICKUP
		
		--special toys aced
		if managers.player:has_category_upgrade("player","specialist_ammo_pickup_modifier") then
			local weapon_id = self:get_name_id()
			if tweak_data.weapon.tcd_specialist_pickup_amounts[weapon_id] then
				self._ammo_pickup = tweak_data.weapon.tcd_specialist_pickup_amounts[weapon_id]
			end
		end
		
		
		self:update_damage()
	end

	function RaycastWeaponBase:on_reload(amount)
		local ammo_base = self._reload_ammo_base or self:ammo_base()
		amount = amount or ammo_base:get_ammo_max_per_clip()

		if self._setup.expend_ammo then
			ammo_base:set_ammo_remaining_in_clip(math.min(ammo_base:get_ammo_total(), amount))
		else
			ammo_base:set_ammo_remaining_in_clip(amount)
			ammo_base:set_ammo_total(amount)
		end

		managers.job:set_memory("kill_count_no_reload_" .. tostring(self._name_id), nil, true)

		self._reload_ammo_base = nil
		
		if self:get_ammo_remaining_in_clip() == self:get_ammo_max_per_clip() then
			--tracks whether the reload restored the full magazine amount
			--currently only used for rapidfire's money shot basic skill
			self._reloaded_to_full = true
		else
			self._reloaded_to_full = nil
		end
	end

	function RaycastWeaponBase:add_ammo(ratio, add_amount_override)
		local function _add_ammo(ammo_base, ratio, add_amount_override)
			if ammo_base:get_ammo_max() == ammo_base:get_ammo_total() then
				ammo_base._stored_ammo_leftover = nil --just in case

				return false, 0
			end

			local add_amount = add_amount_override
			local picked_up = true

			if not add_amount then
				local multiplier_min = 1
				local multiplier_max = 1

				--overrides won't prevent pickup bonuses from applying
				if ammo_base._ammo_data then
					multiplier_min = ammo_base._ammo_data.ammo_pickup_min_mul or multiplier_min
					multiplier_max = ammo_base._ammo_data.ammo_pickup_max_mul or multiplier_max
				end

				local ammo_mul_1 = managers.player:upgrade_value("player", "pick_up_ammo_multiplier", 1) - 1
				local ammo_mul_2 = managers.player:upgrade_value("player", "pick_up_ammo_multiplier_2", 1) - 1
				local team_ai_mul = managers.player:crew_ability_upgrade_value("crew_scavenge", 0)
				local grenadelauncher_pickup_bonus = 0
				if self:is_category("grenade_launcher") then 
					grenadelauncher_pickup_bonus = managers.player:upgrade_value("weapon","grenade_launcher_ammo_pickup_increase",0)
				end
				
				multiplier_min = multiplier_min + ammo_mul_1 + ammo_mul_2 + team_ai_mul + grenadelauncher_pickup_bonus
				multiplier_max = multiplier_max + ammo_mul_1 + ammo_mul_2 + team_ai_mul + grenadelauncher_pickup_bonus

				--log("pickup - min mult: " .. tostring(multiplier_min) .. "")
				--log("pickup - max mult: " .. tostring(multiplier_max) .. "")

				local min_pickup = ammo_base._ammo_pickup[1] * multiplier_min
				local max_pickup = ammo_base._ammo_pickup[2] * multiplier_max

				if min_pickup == max_pickup then
					add_amount = min_pickup
				else
					add_amount = math_lerp(min_pickup, max_pickup, math_random())
				end

				--log("pickup - initial value: " .. tostring(add_amount) .. "")
			else
				--log("pickup - is override: " .. tostring(add_amount) .. "")
			end

			if ratio then
				add_amount = add_amount * ratio

				--log("pickup - after ratio: " .. tostring(add_amount) .. "")
			end

			if ammo_base._stored_ammo_leftover then
				--log("pickup - had leftover: " .. tostring(ammo_base._stored_ammo_leftover) .. "")

				add_amount = add_amount + ammo_base._stored_ammo_leftover
				ammo_base._stored_ammo_leftover = nil
			end

			if add_amount < 1 then
				if add_amount + 0.000001 < 1 then --tolerance check, thanks lua
					ammo_base._stored_ammo_leftover = add_amount

					return picked_up, add_amount
				else
					--log("pickup - floating point strikes again, forcing to 1")

					add_amount = 1
				end
			end

			local current_ammo = ammo_base:get_ammo_total()
			local new_ammo = current_ammo + add_amount
			local rounded_new_ammo = math_floor(new_ammo)
			local max_allowed_ammo = ammo_base:get_ammo_max()

			if new_ammo < max_allowed_ammo then
				--akimbos normally round up ammo if needed to get an even number due to their recoil animations (plus syncing I think), enable this block back if needed
				--[[local is_akimbo = ammo_base.AKIMBO

				if is_akimbo then
					local akimbo_rounding = rounded_new_ammo % 2 + #ammo_base._fire_callbacks

					if akimbo_rounding > 0 then
						--log("pickup - akimbo rounding: " .. tostring(akimbo_rounding) .. "")

						new_ammo = new_ammo + akimbo_rounding
						rounded_new_ammo = math_floor(new_ammo)
					end
				end]]

				if not is_akimbo or new_ammo < max_allowed_ammo then
					local leftover_ammo = new_ammo - rounded_new_ammo

					if leftover_ammo > 0 then
						--log("pickup - stored leftover: " .. tostring(leftover_ammo) .. "")

						ammo_base._stored_ammo_leftover = leftover_ammo
					end
				end
			end

			local ammo_to_add = math_clamp(rounded_new_ammo, 0, max_allowed_ammo)

			ammo_base:set_ammo_total(ammo_to_add)

			add_amount = ammo_to_add - current_ammo

			return picked_up, add_amount
		end

		local picked_up, add_amount = nil
		picked_up, add_amount = _add_ammo(self, ratio, add_amount_override)

		for _, gadget in ipairs(self:get_all_override_weapon_gadgets()) do
			if gadget and gadget.ammo_base then
				local p, a = _add_ammo(gadget:ammo_base(), ratio, add_amount_override)
				picked_up = p or picked_up
				add_amount = add_amount + a
			end
		end

		return picked_up, add_amount
	end
	
	function RaycastWeaponBase:fire_rate_multiplier(rof_mul)
	--the addition of the optional rof_mul argument is from tcd, not from vanilla
		rof_mul = rof_mul or 1
		if self:is_weapon_class("class_precision") then
			local tap_the_trigger_data = managers.player:upgrade_value("weapon","point_and_click_rof_bonus",{0,0})
			rof_mul = rof_mul * (1 + math.min(tap_the_trigger_data[1] * managers.player:get_property("current_point_and_click_stacks",0),tap_the_trigger_data[2]))
		elseif self:is_weapon_class("class_shotgun") and self:fire_mode() == "single" then 
			rof_mul = rof_mul + managers.player:upgrade_value("class_shotgun","shell_games_rof_bonus",0)
		end
		return rof_mul
	end
	
	--use NewRaycastWeaponBase for most weapons!
	function RaycastWeaponBase:reload_speed_multiplier(multiplier)
		multiplier = multiplier or 1
	--optional multiplier argument is added from cd here as well
		local pm = managers.player
		
		if pm:player_unit():character_damage().swansong then
			return 99
		end

		
		for _, category in ipairs(self:weapon_tweak_data().categories) do
			multiplier = multiplier * pm:upgrade_value(category, "reload_speed_multiplier", 1)
		end

		multiplier = multiplier * pm:upgrade_value("weapon", "passive_reload_speed_multiplier", 1)
		multiplier = multiplier * pm:upgrade_value(self._name_id, "reload_speed_multiplier", 1)
		
		if self:clip_empty() then
			--money shot aced reload speed
			multiplier = multiplier + pm:upgrade_value(self:get_weapon_class(), "empty_magazine_reload_speed_bonus", 0)
		end
		
		if self:is_weapon_class("class_precision") then
			local this_machine_data = pm:upgrade_value("weapon","point_and_click_bonus_reload_speed",{0,0})
			multiplier = multiplier * (1 + math.min(this_machine_data[1] * pm:get_property("current_point_and_click_stacks",0),this_machine_data[2]))
		elseif self:is_weapon_class("class_heavy") then
			local lead_farmer_data = pm:upgrade_value("class_heavy","lead_farmer",{0,0})
			local lead_farmer_bonus = math.min(pm:get_property("current_lead_farmer_stacks",0) * lead_farmer_data[1],lead_farmer_data[2])
			multiplier = multiplier + lead_farmer_bonus
		end
		
		multiplier = managers.modifiers:modify_value("WeaponBase:GetReloadSpeedMultiplier", multiplier)

		return multiplier
	end

	function RaycastWeaponBase:_get_current_damage(dmg_mul)
		local point_and_click_data = managers.player:upgrade_value("weapon","point_and_click_damage_bonus",{0,0})
		local damage = self._damage
		damage = damage * (dmg_mul or 1)
		damage = damage * managers.player:temporary_upgrade_value("temporary", "combat_medic_damage_multiplier", 1)
		if self:is_weapon_class("class_precision") then 
			local mul = math.max(1, math.min(point_and_click_data[1] * managers.player:get_property("current_point_and_click_stacks",0), point_and_click_data[2]))
			
			damage = damage * mul
		elseif self:is_weapon_class("class_shotgun") then 
			if self:fire_mode() == "auto" and self:clip_full() then 
				damage = damage * (1 + managers.player:upgrade_value("class_shotgun","heartbreaker_damage",0))
			end
		elseif self:is_weapon_class("class_saw") then 
			local rolling_cutter_data = managers.player:upgrade_value("saw","consecutive_damage_bonus",{0,0})
			
			local rolling_cutter_stacks = managers.player:get_property("rolling_cutter_aced_stacks",0)
			damage = damage * (1 + math.min(rolling_cutter_stacks * rolling_cutter_data[1],rolling_cutter_data[2]))
		end
		for _,subclass in pairs(self:get_weapon_subclasses()) do 
			damage = damage * managers.player:upgrade_value(subclass,"weapon_subclass_damage_mul",1)
		end
		damage = damage * managers.player:upgrade_value(self:get_weapon_class() or "NO_WEAPON_CLASS","weapon_class_damage_mul",1)
		return damage
	end

	function FlameBulletBase:calculate_crit(weapon_unit, user_unit)
		if not user_unit or user_unit ~= managers.player:player_unit() then
			return nil
		end
		local crit_value = managers.player:critical_hit_chance()
		local has_category = weapon_unit and alive(weapon_unit) and not weapon_unit:base().thrower_unit and weapon_unit:base().is_category
		
		if has_category then
			local primary_class = weapon_unit:base():get_weapon_class()
			
			crit_value = crit_value + managers.player:upgrade_value(primary_class, "primary_class_critical_hit_chance_increase", 0)
			
			local making_miracles_stacks = managers.player:get_temporary_property("shotgrouping_aced_stacks",0) --num stacks
			if making_miracles_stacks > 0 then 
				local making_miracles_crit_chance = managers.player:upgrade_value(primary_class,"critical_hit_chance_on_headshot",{0,0})[1] --chance per stack
				local making_miracles_crit_bonus = making_miracles_stacks * making_miracles_crit_chance --total applied bonus
				crit_value = crit_value + making_miracles_crit_bonus
			end
		end
		
		return math.random() < crit_value
	end
		
	function InstantBulletBase:calculate_crit(weapon_unit, user_unit)
		if not user_unit or user_unit ~= managers.player:player_unit() then
			return nil
		end

		local crit_value = managers.player:critical_hit_chance()
		
		local has_category = weapon_unit and alive(weapon_unit) and not weapon_unit:base().thrower_unit and weapon_unit:base().is_category
		
		if has_category then
			local primary_class = weapon_unit:base():get_weapon_class()
			
			crit_value = crit_value + managers.player:upgrade_value(primary_class, "primary_class_critical_hit_chance_increase", 0)
			
			local making_miracles_stacks = managers.player:get_temporary_property("shotgrouping_aced_stacks",0) --num stacks
			if making_miracles_stacks > 0 then 
				local making_miracles_crit_chance = managers.player:upgrade_value(primary_class,"critical_hit_chance_on_headshot",{0,0})[1] --chance per stack
				local making_miracles_crit_bonus = making_miracles_stacks * making_miracles_crit_chance --total applied bonus
				crit_value = crit_value + making_miracles_crit_bonus
			end
		end

		return crit_value > math.random()
	end

end
