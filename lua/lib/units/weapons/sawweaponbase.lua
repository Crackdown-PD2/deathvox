local mvec3_set = mvector3.set
local mvec3_mul = mvector3.multiply
local mvec3_add = mvector3.add
local mvec3_cpy = mvector3.copy
local mvec3_norm = mvector3.normalize

local mvec_to = Vector3()

local math_ceil = math.ceil
local math_random = math.random
local math_clamp = math.clamp
local math_min = math.min
local math_max = math.max

local t_ins = table.insert

local world_g = World

local is_total_cd = deathvox and deathvox:IsTotalCrackdownEnabled() and true

local original_init = SawWeaponBase.init
function SawWeaponBase:init(unit)
	original_init(self, unit)

	self._shield_knock = false --knocking shields with a saw ends up being worse
	self._use_armor_piercing = true --this not being a thing normally is just silly

	if is_total_cd then
		--player skills, if something isn't needed here, feel free to remove it (along with any commentary for the skills that isn't their names once all of them are implemented)
		self._rolling_cutter = managers.player:has_category_upgrade("saw", "enemy_slicer") and true --this only applies to the basic skill, and here only not consuming ammo when hitting enemies is implemented (the other part of the skill probably goes in playermanager)
		self._extra_saw_range = nil --handyman ace, basic needs to be implemented somewhere else I think
		self._saw_through_shields = managers.player:has_category_upgrade("saw", "ignore_shields") --not safe basic
		self._bonus_dozer_damage = nil --not safe ace
		self._bloody_mess = nil --needs a way to distinguish between basic and ace (or just use two different variables
		self._into_the_pit = nil --needs implementation for the critical hit (might have to be done in raycastweaponbase). Panic aspect of the skill already exists in playermanager (modify accordingly if necessary)
	else
		self._consume_no_ammo_chance = managers.player:has_category_upgrade("saw", "consume_no_ammo_chance") and managers.player:upgrade_value("saw", "consume_no_ammo_chance", 0)
		self._enemy_slicer_ammo_usage = managers.player:has_category_upgrade("saw", "enemy_slicer") and managers.player:upgrade_value("saw", "enemy_slicer", 10)
	end

	--define slotmasks to use once for better performance
	self._shield_slotmask = managers.slot:get_mask("enemy_shield_check")
	self._enemy_slotmask = managers.slot:get_mask("enemies")
	self._civilian_slotmask = managers.slot:get_mask("civilians")
	self._wall_slotmask = managers.slot:get_mask("world_geometry", "vehicles")
end

function SawWeaponBase:weapon_range()
	local range = 200

	if is_total_cd and self._extra_saw_range then
		range = range * self._extra_saw_range
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
			if is_total_cd then
				if not hit_an_enemy or not self._rolling_cutter then
					--adjust this block accordingly if needed to fit new TCD stats for the saw
					local ammo_usage = 5
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

				if consume_ammo then --do ammo drain calculations once sure ammo WILL be used
					local ammo_usage = 5

					if hit_an_enemy then
						if self._enemy_slicer_ammo_usage then
							ammo_usage = self._enemy_slicer_ammo_usage
						else
							ammo_usage = 15
						end
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
	if is_total_cd then
		--use usual firing position for other weapons (center of the camera for players)
		local range = self:weapon_range()

		mvec3_set(mvec_to, direction)
		mvec3_mul(mvec_to, range)
		mvec3_add(mvec_to, from_pos)
	else
		--use the "barrel" object of the saw (30 cm back based on the way it's facing) as the point of origin then extend the range to 1 meter forward
		from_pos = self._obj_fire:position()
		direction = self._obj_fire:rotation():y()

		mvec3_add(from_pos, direction * -30)
		mvec3_set(mvec_to, direction)
		mvec3_mul(mvec_to, 100)
		mvec3_add(mvec_to, from_pos)
	end

	local damage = self:_get_current_damage(dmg_mul)

	--raycast_all allows proper penetration by just using 1 ray, use it consistently instead of only when the player has the shield penetration upgrade
	local ray_hits = world_g:raycast_all("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "ray_type", "body bullet lock")
	local units_hit, actual_hits = {}, {}
	local hit_unit, hit_an_enemy, drain_ammo, do_bloody_mess, bloody_hit_damage, bloody_hit_pos = nil

	for i, hit in ipairs(ray_hits) do
		local unit = hit.unit

		if not units_hit[unit:key()] then
			units_hit[unit:key()] = true
			hit.hit_position = hit.position
			actual_hits[#actual_hits + 1] = hit

			local should_stop = nil
			local hit_in_slot_func = unit.in_slot --define in_slot function of each unit in case the first check fails, for better performance

			if hit_in_slot_func(unit, self._shield_slotmask) then
				drain_ammo = true

				if not self._saw_through_shields then --stop hitting stuff past shields unless the player has the skill + drain ammo
					should_stop = true
				end
			elseif hit_in_slot_func(unit, self._enemy_slotmask) then
				drain_ammo = true
				hit_an_enemy = true
				should_stop = true
			elseif hit_in_slot_func(unit, self._wall_slotmask) then
				drain_ammo = true
				should_stop = true
			elseif hit_in_slot_func(unit, self._civilian_slotmask) then --civilians won't stop you from hitting something else, but they will still drain ammo (does not stacking if hitting other things)
				drain_ammo = true
			end

			local hit_result = SawHit:on_collision(hit, self._unit, user_unit, damage)

			if hit_result then
				hit_unit = true --for hit_enemy, which means hitting units with a character_damage() extension, not specifically enemies

				if is_total_cd and hit_an_enemy and self._bloody_mess and hit_result.type and hit_result.type == "death" and hit_result.attack_data then
					do_bloody_mess = true

					--raw_damage means the amount of damage dealt by a hit after all multipliers and reductions are applied, but before clamping the damage dealt to the maximum/current health of the unit
					local new_bloody_damage = hit_result.attack_data.raw_damage or damage

					if not bloody_hit_damage or bloody_hit_damage < new_bloody_damage then
						bloody_hit_damage = new_bloody_damage
						bloody_hit_pos = hit.position
					end
				end
			end

			if should_stop then
				break
			end
		end
	end

	if do_bloody_mess ~= nil then
		local radius = 250 --the radius should also be defined through the skill instead of here
		local bodies_hit = world_g:find_bodies("intersect", "sphere", bloody_hit_pos, radius, self._enemy_slotmask)
		local enemies_hit = {}
		local death_mess_positions = self._bloody_mess_ace and {} --placeholder for whatever's done to check for the ace skill, name can alternatively be self._death_mess

		for _, body in ipairs(bodies_hit) do
			local enemy = body:unit()

			if not enemies_hit[enemy:key()] then --not already hit (shapes and sphere rays can hit the same unit multiple times)
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

	result.hit_enemy = hit_unit --hit a character_damage() unit and got a result from it, normally used for syncing purposes (whether to send a more droppable packet or not), might be used for something else

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

function SawHit:on_collision(col_ray, weapon_unit, user_unit, damage)
	local hit_unit = col_ray.unit

	--proper dozer checks for bonus damage
	if is_total_cd then
		if self._bonus_dozer_damage and hit_unit:base() and hit_unit:base().has_tag and hit_unit:base():has_tag("tank") then
			damage = damage * self._bonus_dozer_damage
		end
	elseif hit_unit:base() and hit_unit:base().has_tag and hit_unit:base():has_tag("tank") then
		damage = damage + 50
	end

	local result = InstantBulletBase.on_collision(self, col_ray, weapon_unit, user_unit, damage)

	if hit_unit:damage() and col_ray.body:extension() and col_ray.body:extension().damage then
		damage = math_clamp(damage * managers.player:upgrade_value("saw", "lock_damage_multiplier", 1) * 4, 0, 200)

		col_ray.body:extension().damage:damage_lock(user_unit, col_ray.normal, col_ray.position, col_ray.direction, damage)

		if hit_unit:id() ~= -1 then
			managers.network:session():send_to_peers_synched("sync_body_damage_lock", col_ray.body, damage)
		end
	end

	return result
end

function SawHit:play_impact_sound_and_effects(weapon_unit, col_ray)
	local decal = "saw"

	if col_ray.unit:character_damage() and not col_ray.unit:character_damage()._no_blood then --until OVK fixes the "saw" decal negating blood splatters on characters (not the actual decals applied ro walls)
		decal = nil
	end

	managers.game_play_central:play_impact_sound_and_effects({
		decal = decal,
		no_sound = true,
		col_ray = col_ray
	})
end
