local mvec3_set = mvector3.set
local mvec3_mul = mvector3.multiply
local mvec3_add = mvector3.add
local mvec3_cpy = mvector3.copy
local mvec3_norm = mvector3.normalize

local mvec_to = Vector3()

local math_floor = math.floor
local math_ceil = math.ceil
local math_random = math.random
local math_clamp = math.clamp
local math_min = math.min
local math_max = math.max

local t_ins = table.insert

local world_g = World

local TCD_ENABLED = deathvox:IsTotalCrackdownEnabled()

local INSTAPEEL_BODIES = {}
if TCD_ENABLED then
	--list of Idstrings for bodies that take maxed damage from saws (currently just dozer faceplate "body_helmet_plate" but could also be "body_helmet_glass")
	for _,body_name in pairs(tweak_data.upgrades.values.saw.dozer_instant_armor_peel_bodies) do 
		INSTAPEEL_BODIES[Idstring(body_name)] = true
	end
	
	
local sawhit_collision_orig = SawHit.on_collision
function SawHit:on_collision(col_ray, weapon_unit, user_unit, damage, ...)
	if TCD_ENABLED then
		
		local hit_unit = col_ray.unit
		local base_ext = hit_unit:base()
		local is_crit, is_breachable_object = nil
		local unit_dmg_ext = hit_unit:character_damage()
		
		if unit_base_ext and self._bonus_dozer_damage and unit_base_ext.has_tag and unit_base_ext:has_tag("tank") then
			damage = damage * self._bonus_dozer_damage
		end
		if managers.groupai:state():is_enemy_special(hit_unit) then
			damage = damage * managers.player:upgrade_value("saw","damage_multiplier_to_specials",1)
		end
		if unit_dmg_ext then 
			
			if managers.player:has_category_upgrade("saw","crit_first_strike") then

				if unit_dmg_ext and not unit_dmg_ext._INTO_THE_PIT_PROC then
					unit_dmg_ext._INTO_THE_PIT_PROC = true
					is_crit = true
				end
			end
			
			if managers.player:has_category_upgrade("saw","panic_on_hit") and unit_dmg_ext.build_suppression then
				unit_dmg_ext:build_suppression("panic")
			end

			if unit_dmg_ext.build_suppression then
				unit_dmg_ext:build_suppression("panic")
			end
		end
		
		-- tcd skip dozer flat damage bonus;
		-- saws in tcd do plenty already
		
		local result = InstantBulletBase.on_collision(self, col_ray, weapon_unit, user_unit, damage, nil, nil, nil, is_crit)
		local col_body = col_ray.body
		local body_dmg_ext = hit_unit:damage() and col_body:extension() and col_body:extension().damage 
		if body_dmg_ext then
			is_breachable_object = true
			
			if managers.player:has_category_upgrade("saw","destroys_dozer_armor") and INSTAPEEL_BODIES[col_body:name()] then
				damage = 200 --max out damage to the plate body
			end
			
			damage = math_clamp(damage * managers.player:upgrade_value("saw", "lock_damage_multiplier", 1) * 4, 0, 200)

			body_dmg_ext:damage_lock(user_unit, col_ray.normal, col_ray.position, col_ray.direction, damage)
			
			if hit_unit:id() ~= -1 then
				managers.network:session():send_to_peers_synched("sync_body_damage_lock", col_body, damage)
			end
		end
		
		return result,is_breachable_object
	else
		return sawhit_collision_orig(self, col_ray, weapon_unit, user_unit, damage, ...)
	end
end

end


local original_init = SawWeaponBase.init
function SawWeaponBase:init(unit)
	original_init(self, unit)

	self._HIT_DEFAULT_AMMO_USAGE = 5
	self._HIT_ENEMY_AMMO_USAGE = 15
	self._SAW_RAYCAST_RANGE = 200 --2m

	self._shield_knock = false --knocking shields with a saw ends up being worse
	self._use_armor_piercing = true --this not being a thing normally is just silly

	if TCD_ENABLED then
		self._saw_enemies_free = managers.player:has_category_upgrade("saw", "enemy_cutter") --no ammo consumed on enemy hit
		self._extra_saw_range_mul = managers.player:upgrade_value("saw","range_mul",1) --basically what it says on the tin
		self._saw_through_shields = managers.player:has_category_upgrade("saw", "ignore_shields") --also what it says on the tin + don't spend ammo when hitting shields
		self._bonus_dozer_damage = managers.player:upgrade_value("saw","dozer_bonus_damage_mul",1) --fig a. tin label
		self._bloody_mess_radius = managers.player:upgrade_value("saw","killing_blow_radius") --saw kills damage nearby enemies)
		self._bloody_mess_do_extra_proc = managers.player:has_category_upgrade("saw","killing_blow_chain") --enemies killed by bloody mess basic can proc bloody mess one more time
		self._reduced_ammo_usage = math_floor(self._HIT_DEFAULT_AMMO_USAGE * managers.player:upgrade_value("saw", "durability_increase", 10))
		
		if managers.player:has_category_upgrade("saw","consecutive_damage_bonus") then
			self._has_consecutive_damage_bonus = true
			local consecutive_damage_bonus_data = managers.player:upgrade_value("saw","consecutive_damage_bonus",{0,0})
			self._consecutive_damage_bonus_rate = consecutive_damage_bonus_data[1]
			self._max_consecutive_damage_stacks = consecutive_damage_bonus_data[2]
		end
		self._enemy_damage_multiplier = managers.player:upgrade_value("saw","enemy_damage_multiplier",1)
					
					
		local stagger_radius,stagger_severity
		
		if managers.player:has_category_upgrade("saw","stagger_on_kill") then
			local stagger_data = managers.player:upgrade_value("saw","stagger_on_kill",{})
			stagger_radius = stagger_data.range
			stagger_severity = stagger_data.severity
		end
		
		self._stagger_on_kill_radius = stagger_radius
		self._stagger_on_kill_severity = stagger_severity
		
		if self._extra_saw_range_mul == 1 then
			self._extra_saw_range_mul = nil
		end

		if self._bonus_dozer_damage == 1 then
			self._bonus_dozer_damage = nil
		end
	else
		self._consume_no_ammo_chance = managers.player:has_category_upgrade("saw", "consume_no_ammo_chance") and managers.player:upgrade_value("saw", "consume_no_ammo_chance", 0)
		self._reduced_ammo_usage = managers.player:has_category_upgrade("saw", "enemy_slicer") and managers.player:upgrade_value("saw", "enemy_slicer", 10) --vanilla

		if self._consume_no_ammo_chance == 0 then
			self._consume_no_ammo_chance = nil
		end
	end

	--define slotmasks to use once for better performance
	self._shield_slotmask = managers.slot:get_mask("enemy_shield_check")
	self._enemy_slotmask = managers.slot:get_mask("enemies")
	self._civilian_slotmask = managers.slot:get_mask("civilians")
	self._wall_slotmask = managers.slot:get_mask("world_geometry", "vehicles")
end

function SawWeaponBase:weapon_range()
	local range = self._SAW_RAYCAST_RANGE or 200 --adding an extra fallback just in case

	if self._extra_saw_range_mul then
		range = range * self._extra_saw_range_mul
	end

	return range
end

function SawWeaponBase:fire(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	local ammo_in_mag = self:get_ammo_remaining_in_clip()

	if ammo_in_mag == 0 then
		return
	end

	local user_unit = self._setup.user_unit
	local ray_res, hit_something, drain_ammo, hit_an_enemy = self:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)

	if hit_something then
		self:_start_sawing_effect()

		if drain_ammo and not managers.player:has_active_temporary_property("bullet_storm") then --check if the hit will drain ammo (not a helmet, corpse or similar entities that are can get in the way and waste ammo)
			if TCD_ENABLED then
				if not hit_an_enemy or not self._saw_enemies_free then
					local ammo_usage = self._reduced_ammo_usage or self._HIT_DEFAULT_AMMO_USAGE
					ammo_usage = ammo_usage + math_ceil(math_random() * 10)
					ammo_usage = math_min(ammo_usage, ammo_in_mag)
					self:set_ammo_remaining_in_clip(math_max(ammo_in_mag - ammo_usage, 0))
					self:set_ammo_total(math_max(self:get_ammo_total() - ammo_usage, 0))
					self:_check_ammo_total(user_unit)
				end
			else
				local consume_ammo = true
				local dont_consume_chance = self._consume_no_ammo_chance

				if dont_consume_chance and math_random() < dont_consume_chance then
					consume_ammo = nil
				end

				if consume_ammo then --do ammo drain calculations once sure that ammo WILL be used
					local ammo_usage = nil

					if hit_an_enemy then
						ammo_usage = self._reduced_ammo_usage or self._HIT_ENEMY_AMMO_USAGE
					else
						ammo_usage = self._HIT_DEFAULT_AMMO_USAGE
					end

					ammo_usage = ammo_usage + math_ceil(math_random() * 10)
					ammo_usage = math_min(ammo_usage, ammo_in_mag)

					self:set_ammo_remaining_in_clip(math_max(ammo_in_mag - ammo_usage, 0))
					self:set_ammo_total(math_max(self:get_ammo_total() - ammo_usage, 0))
					self:_check_ammo_total(user_unit)
				end
			end
		end
	else
		self:_stop_sawing_effect()
	end

	if self._alert_events and ray_res.rays then
		if hit_something then
			self._alert_size = self._hit_alert_size
		else
			self._alert_size = self._no_hit_alert_size
		end

		self._current_stats.alert_size = self._alert_size

		self:_check_alert(ray_res.rays, from_pos, direction, user_unit)
	end

	return ray_res
end

function SawWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
	if TCD_ENABLED then
		--use usual firing position for other weapons (center of the camera for players)
		local range = self:weapon_range()

		mvec3_set(mvec_to, direction)
		mvec3_mul(mvec_to, range)
		mvec3_add(mvec_to, from_pos)
	else
		--vanilla, use the "barrel" object of the saw (30 cm back based on the way it's facing) as the point of origin then extend the range to 1 meter forward
		from_pos = self._obj_fire:position()
		direction = self._obj_fire:rotation():y()

		mvec3_add(from_pos, direction * -30)
		mvec3_set(mvec_to, direction)
		mvec3_mul(mvec_to, 100)
		mvec3_add(mvec_to, from_pos)
	end

	
	--raycast_all allows proper penetration by just using 1 ray, use it consistently instead of only when the player has the shield penetration upgrade
	local ray_hits = world_g:raycast_all("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "ray_type", "body bullet lock")
	local units_hit, actual_hits = {}, {}
	local hit_an_enemy, drain_ammo, do_bloody_mess, bloody_hit_damage, bloody_hit_pos = nil
	local do_stagger_on_kill

	for i, hit in ipairs(ray_hits) do
		local unit = hit.unit

		if not units_hit[unit:key()] then
			units_hit[unit:key()] = true
			hit.hit_position = hit.position
			actual_hits[#actual_hits + 1] = hit

			local should_stop = nil
			local hit_in_slot_func = unit.in_slot --define in_slot function of each unit in case the first check fails, for better performance

			if hit_in_slot_func(unit, self._shield_slotmask) then
				if not self._saw_through_shields then --stop hitting stuff past shields + drain ammo if the player lacks the shield piercing skill
					drain_ammo = true
					should_stop = true
				elseif not TCD_ENABLED then --drain ammo even with the skill only outside of TCD
					drain_ammo = true
				end
			elseif hit_in_slot_func(unit, self._enemy_slotmask) then
				hit_an_enemy = true
				drain_ammo = true
				should_stop = true
			elseif hit_in_slot_func(unit, self._wall_slotmask) then
				drain_ammo = true
				should_stop = true
			elseif hit_in_slot_func(unit, self._civilian_slotmask) then --civilians won't stop you from hitting something else, but they will still drain ammo (does not stack if hitting other things)
				drain_ammo = true
			end
			
			if TCD_ENABLED and hit_an_enemy then
				--damage mul should only apply to enemies, not saw-able objects like deposit boxes
				local enemy_damage_multiplier = self._enemy_damage_multiplier
				if self._has_consecutive_damage_bonus then
					enemy_damage_multiplier = enemy_damage_multiplier + (self._consecutive_damage_bonus_rate * managers.player:get_property("saw_consecutive_damage_stacks",0))
				end
				dmg_mul = dmg_mul + enemy_damage_multiplier
			end
			
			local damage = self:_get_current_damage(dmg_mul)
			
			local hit_result,is_breachable_object = SawHit:on_collision(hit, self._unit, user_unit, damage)
			if self._saw_enemies_free and not is_breachable_object then 
				drain_ammo = false
			end
			if TCD_ENABLED and hit_result and hit_an_enemy and hit_result.attack_data then
				
				--give rolling cutter basic damage bonus stacks here
				if self._has_consecutive_damage_bonus then 
					local consecutive_damage_stacks = math.clamp(managers.player:get_property("saw_consecutive_damage_stacks",0) + 1,0,self._max_consecutive_damage_stacks)
					managers.player:set_property("saw_consecutive_damage_stacks",consecutive_damage_stacks)
				end
				
				if hit_result.type and hit_result.type == "death" then 
				
					if self._stagger_on_kill_radius then
						do_stagger_on_kill = true
					end
					--do bloody mess effect here
					if self._bloody_mess_radius then 
						do_bloody_mess = true
						
						--raw_damage means the amount of damage dealt by a hit after all multipliers and reductions are applied, but before clamping the damage dealt to the maximum/current health of the unit
						local new_bloody_damage = hit_result.attack_data.raw_damage or damage

						if not bloody_hit_damage or bloody_hit_damage < new_bloody_damage then
							bloody_hit_damage = new_bloody_damage
							bloody_hit_pos = hit.position
						end
					end
				end
			end

			if should_stop then
				break
			end
		end
	end
	
	if do_stagger_on_kill then --adapted from old 'bloody mess' code
		local radius = self._stagger_on_kill_radius
		local severity = self._stagger_on_kill_severity
		local ray = ray_hits[1] 
		
		local bodies_hit = world_g:find_bodies("intersect", "sphere", ray.position, radius, self._enemy_slotmask)
		local enemies_hit = {}

		for _, body in ipairs(bodies_hit) do
			local enemy = body:unit()

			if not enemies_hit[enemy:key()] then
				
				enemies_hit[enemy:key()] = true
				
				if unit_base_ext and unit_base_ext.has_tag and not unit_base_ext:has_tag("tank") then
					local dmg_ext = enemy:character_damage()
					if dmg_ext and dmg_ext._call_listeners then
						dmg_ext:_call_listeners({
							variant = "bullet",
							damage = 0,
							type = "hurt",
							col_ray = ray,
							result = {
								variant = "bullet",
								type = severity
							}
						})
					end	
				end
			end
		end
	end
	
	if do_bloody_mess ~= nil then --not used
		local radius = self._bloody_mess_radius
		local bodies_hit = world_g:find_bodies("intersect", "sphere", bloody_hit_pos, radius, self._enemy_slotmask)
		local enemies_hit = {}
		local death_mess_positions = self._bloody_mess_do_extra_proc and {}

		for _, body in ipairs(bodies_hit) do
			local enemy = body:unit()

			if not enemies_hit[enemy:key()] then --not already hit (otherwise shapes with find_bodies or sphere rays can hit the same unit multiple times)
				enemies_hit[enemy:key()] = true

				local dmg_ext = enemy:character_damage()

				if dmg_ext and dmg_ext.damage_simple then
					local hit_pos = mvec3_cpy(body:position())
					local hit_dir = hit_pos - bloody_hit_pos
					mvec3_norm(hit_dir)

					local attack_data = {
						variant = "graze",
						damage = bloody_hit_damage,
						attacker_unit = user_unit,
						pos = hit_pos,
						attack_dir = hit_dir
					}

					local dmg_result = dmg_ext:damage_simple(attack_data)

					--store the hit position of enemies killed by the initial bloody hit, as handling this before actually dealing damage to all the enemies caught by the initial sphere would be a waste of performance (if they would die on the initial hit)
					if death_mess_positions and dmg_result and dmg_result.type == "death" then
						t_ins(death_mess_positions, hit_pos)
					end
				end
			end
		end

		if death_mess_positions then
			local new_enemies_hit = {}

			for _, new_origin_pos in ipairs(death_mess_positions) do
				local new_bodies_hit = world_g:find_bodies("intersect", "sphere", new_origin_pos, radius, self._enemy_slotmask)

				for _, body in ipairs(new_bodies_hit) do
					local enemy = body:unit()

					if not new_enemies_hit[enemy:key()] then
						new_enemies_hit[enemy:key()] = true

						local dmg_ext = enemy:character_damage()

						if dmg_ext and dmg_ext.damage_simple then
							local hit_pos = mvec3_cpy(body:position())
							local hit_dir = hit_pos - new_origin_pos
							mvec3_norm(hit_dir)

							local attack_data = {
								variant = "graze",
								damage = bloody_hit_damage,
								attacker_unit = user_unit,
								pos = hit_pos,
								attack_dir = hit_dir
							}

							dmg_ext:damage_simple(attack_data)
						end
					end
				end
			end
		end
	end

	local valid_hit = #actual_hits > 0 and true
	local result = {}

	result.hit_enemy = valid_hit --for syncing purposes, meaning if an impact should be simulated locally for other players

	if self._alert_events then
		result.rays = {
			actual_hits
		}
	end

	if actual_hits then
		managers.statistics:shot_fired({
			hit = true,
			weapon_unit = self._unit
		})
	end

	return result, valid_hit, drain_ammo, hit_an_enemy
end

function SawHit:play_impact_sound_and_effects(weapon_unit, col_ray)
	local decal = "saw"

	--until OVK fixes the "saw" decal negating blood splatters on characters (not the actual decals applied to walls)
	if col_ray.unit:character_damage() and not col_ray.unit:character_damage()._no_blood then
		decal = nil
	end

	managers.game_play_central:play_impact_sound_and_effects({
		decal = decal,
		no_sound = true,
		col_ray = col_ray
	})
end
