local TCD_ENABLED = deathvox:IsTotalCrackdownEnabled()
function ShotgunBase:setup_default()
	local weapontweakdata = tweak_data.weapon[self._name_id]
	local ammo_data = self._ammo_data
	self._rays = weapontweakdata.rays or ammo_data and ammo_data.rays or 6
	self._single_damage_instance = true --basically a toggle option between vanilla (with proper priorization and rays) and the damage-per-pellet feature

	if ammo_data and TCD_ENABLED then
		--use damage-per-pellet if the shotgun has the proper ammo type equipped
		if ammo_data.single_damage_instance then
			self._single_damage_instance = false
		end
		if ammo_data.bullet_class == "FlameBulletBase" then
			local flame_effect_ext = self._flame_effect_ext
			if not flame_effect_ext then
				flame_effect_ext = FlamethrowerEffectExtension:new(self._unit)
				--this needs to be replaced actually
				--this is meant to be an actual unit extension
				--and also it raycasts for flame particle collision
				--even though dragon's breath rounds are piercing/overpenetrating
				flame_effect_ext._name_id = self._name_id
				
				flame_effect_ext._flame_effect = {
					effect = Idstring("effects/payday2/particles/explosions/flamethrower")
				}
				
				flame_effect_ext._nozzle_effect = {
					effect = Idstring("effects/payday2/particles/explosions/flamethrower_nosel")
				}
				flame_effect_ext._pilot_light = {
					effect = Idstring("effects/payday2/particles/explosions/flamethrower_pilot")
				}
				self._flame_effect_ext = flame_effect_ext
				flame_effect_ext._single_flame_effect_duration = 1
				flame_effect_ext._distance_to_gun_tip = 50
				flame_effect_ext._flamethrower_effect_collection = {}
				local upd_name = "upd_flamethrower_" .. tostring(self._unit:key())
				self._flame_effect_upd_name = upd_name
				BeardLib:AddUpdater(upd_name,callback(flame_effect_ext,flame_effect_ext,"update",self._unit))
			end
			flame_effect_ext._flame_max_range = self._range or 400
		end
	end
	
	self._damage_near = weapontweakdata.damage_near
	self._damage_far = weapontweakdata.damage_far
	self._range = self._damage_far

	if weapontweakdata.use_shotgun_reload == nil then
		self._use_shotgun_reload = self._use_shotgun_reload or self._use_shotgun_reload == nil
	else
		self._use_shotgun_reload = weapontweakdata.use_shotgun_reload
	end
	
	
	self._hip_fire_rate_inc = managers.player:upgrade_value("shotgun", "hip_rate_of_fire", 0) --allow Close By aced's rate of fire bonus to apply to all shotguns
end

function ShotgunBase:_update_stats_values(disallow_replenish, ammo_data)
	ShotgunBase.super._update_stats_values(self, disallow_replenish, ammo_data)
	self:setup_default()

	if self._ammo_data then
		if self._ammo_data.rays ~= nil then
			self._rays = self._ammo_data.rays
		end
		if self._ammo_data.rays_mul then
			self._rays = math.ceil(self._rays * self._ammo_data.rays_mul)
		end

		if self._ammo_data.damage_near ~= nil then
			self._damage_near = self._ammo_data.damage_near
		end

		if self._ammo_data.damage_near_mul ~= nil then
			self._damage_near = self._damage_near * self._ammo_data.damage_near_mul
		end

		if self._ammo_data.damage_far ~= nil then
			self._damage_far = self._ammo_data.damage_far
		end

		if self._ammo_data.damage_far_mul ~= nil then
			self._damage_far = self._damage_far * self._ammo_data.damage_far_mul
		end

		self._range = self._damage_far
	end
end

function ShotgunBase:fire_rate_multiplier()
	local fire_rate_mul = self._fire_rate_multiplier
	if self._fire_mode == Idstring("single") then 
		if self._hip_fire_rate_inc ~= 0 then
			local user_unit = self._setup and self._setup.user_unit
			local current_state = alive(user_unit) and user_unit:movement() and user_unit:movement()._current_state

			if current_state and not current_state:in_steelsight() then --but only when firing in single mode as intended (and as usual, when not aiming)
				fire_rate_mul = fire_rate_mul + 1 - self._hip_fire_rate_inc
				fire_rate_mul = self:_convert_add_to_mul(fire_rate_mul)
			end
		end
		if self:is_weapon_class("class_shotgun") then --i don't think there's any shotgun weapons that aren't crackdown weapon class "class_shotgun", but just to be safe 
		--UPDATE: UNDERBARREL SHOTGUNS EXIST NOW BAYBEEEE
			fire_rate_mul = fire_rate_mul + managers.player:upgrade_value("class_shotgun","shell_games_rof_bonus",0)
		end
	end
	return fire_rate_mul
end

function ShotgunBase:_spawn_muzzle_effect(from_pos,direction,...)
--	Draw:brush(Color.red,5):line(from_pos,from_pos + (direction * 1000))
	ShotgunBase.super._spawn_muzzle_effect(self,from_pos,direction,...)
	
	if self._flame_effect_ext then
		self._flame_effect_ext:_spawn_muzzle_effect(from_pos,direction,...)
	end
end

function ShotgunBase:destroy(unit,...)
	if self._flame_effect_upd_name then
		BeardLib:RemoveUpdater(self._flame_effect_upd_name)
	end
	ShotgunBase.super.destroy(self,unit,...)
end

local mvec_temp = Vector3()
local mvec_to = Vector3()
local mvec_direction = Vector3()
local mvec_spread_direction = Vector3()

function ShotgunBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
	if self:gadget_overrides_weapon_functions() then
		return self:gadget_function_override("_fire_raycast", self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul) --in case someone makes something like this for a shotgun
	end

	local wall_piercing = self._can_shoot_through_wall
	local shield_piercing = self._can_shoot_through_shield
	local body_piercing = self._can_shoot_through_enemy

	local bullet_class = self:bullet_class()
	local ap_slug = bullet_class == InstantBulletBase and self._rays == 1
	local he_round = bullet_class == InstantExplosiveBulletBase
	local dragons_breath = bullet_class == FlameBulletBase

	local check_additional_achievements = self._ammo_data and self._ammo_data.check_additional_achievements
	local is_civ_f = CopDamage.is_civilian

	local result = nil
	local col_rays = nil

	if self._alert_events then --keeping consistency with vanilla, it seems pointless but at the same time, nothing changes as far as I'm aware
		col_rays = {}
	end

	local current_state = user_unit:movement()._current_state
	local inc_range_mul = 1

	if current_state and current_state:in_steelsight() then
		inc_range_mul = managers.player:upgrade_value("shotgun", "steelsight_range_inc", 1)
	end

	self._range = self._range * inc_range_mul --since the shotgun's range is used to determine the length of the rays, Far Away ace will increase it accordingly

	local damage = self:_get_current_damage(dmg_mul)
	local weight = 0.1

	local spread_x, spread_y = self:_get_spread(user_unit)
	local right = direction:cross(Vector3(0, 0, 1)):normalized()
	local up = direction:cross(right):normalized()

	mvector3.set(mvec_direction, direction)

	local ray_hits = nil
	local hit_an_enemy = false

	for i = 1, self._rays, 1 do
		local theta = math.random() * 360
		local ax = math.sin(theta) * math.random() * spread_x * (spread_mul or 1)
		local ay = math.cos(theta) * math.random() * spread_y * (spread_mul or 1)

		mvector3.set(mvec_spread_direction, mvec_direction)
		mvector3.add(mvec_spread_direction, right * math.rad(ax))
		mvector3.add(mvec_spread_direction, up * math.rad(ay))
		mvector3.set(mvec_to, mvec_spread_direction)
		mvector3.multiply(mvec_to, self._range) --actually limit the range of the ray using the shotgun's range limit
		mvector3.add(mvec_to, from_pos)

		local enemy_mask = managers.slot:get_mask("enemies")
		local wall_mask = managers.slot:get_mask("world_geometry", "vehicles")
		local shield_mask = managers.slot:get_mask("enemy_shield_check") --to clarify, dragon's breath (FlameBulletBase) ignores shield objects completely from the get-go
		local ai_vision_ids = Idstring("ai_vision")
		local bulletproof_ids = Idstring("bulletproof")

		--proper penetration using one ray, against walls and things like corpses, bots, etc (like other weapons have). HE rounds obviously still stop at the first thing they hit
		if dragons_breath and TCD_ENABLED then
			ray_hits = World:raycast_all("ray", from_pos, mvec_to, "sphere_cast_radius", 40, "disable_inner_ray", "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
--			local angle = 15
--			local radius = self._range * math.tan(angle)
--			ray_hits = World:find_units("cone",from_pos,mvec_to,radius,"slot_mask", enemy_mask, "ignore_unit", self._setup.ignore_units)
			--todo search for bodies in cone instead so that headshots are enabled
		elseif he_round then
			ray_hits = World:raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
		elseif wall_piercing then
			ray_hits = World:raycast_wall("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "thickness", 40, "thickness_mask", wall_mask)
		else
			ray_hits = World:raycast_all("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
		end

		local units_hit = {}
		local unique_hits = {} --table for collected hits
		
		if he_round then
--			if hit_an_enemy then --once an enemy gets hit, this is always true until another shot is fired
--				hit_an_enemy = hit_an_enemy
--			end

			if ray_hits then
				if not hit_an_enemy and ray_hits.unit and ray_hits.unit:in_slot(enemy_mask) then
					hit_an_enemy = true
				end

				table.insert(unique_hits, ray_hits)
			end
		else
			local went_through_wall = false

			for i, hit in ipairs(ray_hits) do
				if not units_hit[hit.unit:key()] then
					units_hit[hit.unit:key()] = true
					unique_hits[#unique_hits + 1] = hit
					hit.hit_position = hit.position
					local weak_body = hit.body:has_ray_type(ai_vision_ids)
					weak_body = weak_body or hit.body:has_ray_type(bulletproof_ids)
					local checked_hit = unique_hits[#unique_hits]
					local point_blank_pierce = user_unit == managers.player:player_unit() and checked_hit and checked_hit.distance and checked_hit.distance <= managers.player:upgrade_value("class_shotgun", "point_blank_basic",0)
					
					if hit_an_enemy then --once an enemy gets hit, this is always true until another shot is fired
						hit_an_enemy = hit_an_enemy
					else
						hit_an_enemy = hit.unit:in_slot(enemy_mask) and true or false
					end

					if not (body_piercing or point_blank_pierce) and hit.unit:in_slot(enemy_mask) then
						break
					elseif hit.unit:in_slot(wall_mask) then
						if weak_body then --actually the other way around, this is a solid wall (just being consistent with vanilla)
							if (wall_piercing or point_blank_pierce) then
								if went_through_wall then
									break
								else
									went_through_wall = true
								end
							else
								break
							end
						end
					elseif not (point_blank_pierce or shield_piercing or point_blank_pierce) and hit.unit:in_slot(shield_mask) then
						break
					end
				end
			end
		end

		if self._autoaim then
			local autoaim = self:check_autoaim(from_pos, direction, self._range)

			if autoaim then
				if hit_an_enemy then
					self._autohit_current = (self._autohit_current + weight) / (1 + weight) --decrease autohit chance

					autoaim = false
				else
					autoaim = false

					local autohit = self:check_autoaim(from_pos, direction, self._range)

					if autohit then
						local autohit_chance = 1 - math.clamp((self._autohit_current - self._autohit_data.MIN_RATIO) / (self._autohit_data.MAX_RATIO - self._autohit_data.MIN_RATIO), 0, 1)

						if math.random() < autohit_chance then
							self._autohit_current = (self._autohit_current + weight) / (1 + weight) --decrease autohit chance when sucessfully auto-hitting

							mvector3.set(mvec_to, from_pos)
							mvector3.add_scaled(mvec_to, autohit.ray, self._range)

							--proper penetration using one ray, against walls and things like corpses, bots, etc (like other weapons have). HE rounds obviously still stop at the first thing they hit
							if he_round then
								ray_hits = World:raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
							elseif wall_piercing then
								ray_hits = World:raycast_wall("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "thickness", 40, "thickness_mask", wall_mask)
							else
								ray_hits = World:raycast_all("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
							end

							if he_round then
								if ray_hits then
									table.insert(unique_hits, ray_hits)
								end
							else
								local went_through_wall = false

								for i, hit in ipairs(ray_hits) do
									if not units_hit[hit.unit:key()] then
										units_hit[hit.unit:key()] = true
										unique_hits[#unique_hits + 1] = hit
										hit.hit_position = hit.position
										local weak_body = hit.body:has_ray_type(ai_vision_ids)
										weak_body = weak_body or hit.body:has_ray_type(bulletproof_ids)
										local checked_hit = unique_hits[#unique_hits]
										local point_blank_pierce = user_unit == managers.player:player_unit() and managers.player:has_category_upgrade("player", "point_blank") and checked_hit and checked_hit.distance and checked_hit.distance <= 200

										if not body_piercing and not point_blank_pierce and hit.unit:in_slot(enemy_mask) then
											break
										elseif hit.unit:in_slot(wall_mask) then
											if weak_body then --actually the other way around, this is a solid wall (just being consistent with vanilla)
												if wall_piercing then
													if went_through_wall then
														break
													else
														went_through_wall = true
													end
												else
													break
												end
											end
										elseif not shield_piercing and not point_blank_pierce and hit.unit:in_slot(shield_mask) then
											break
										end
									end
								end
							end
						else
							self._autohit_current = self._autohit_current / (1 + weight) --increase autohit chance when nothing is hit
						end
					end
				end
			end
		end

		if col_rays then
			for _, col_ray in ipairs(unique_hits) do
				if col_ray then
					table.insert(col_rays, col_ray) --if something was hit
				else
					local ray_to = mvector3.copy(mvec_to)
					local spread_direction = mvector3.copy(mvec_spread_direction)

					table.insert(col_rays, {
						position = ray_to,
						ray = spread_direction
					}) --go to where the ray was going to go anyway
				end
			end
		end

		local furthest_hit = unique_hits[#unique_hits]

		if alive(self._obj_fire) then
			if furthest_hit and furthest_hit.distance > 600 or not furthest_hit then --last collision made by the ray or no collision, both used to spawn the cosmetic tracers from the barrel of the gun
				local trail_direction = furthest_hit and furthest_hit.ray or mvec_spread_direction

				self._obj_fire:m_position(self._trail_effect_table.position)
				mvector3.set(self._trail_effect_table.normal, trail_direction)

				local trail = World:effect_manager():spawn(self._trail_effect_table)

				if furthest_hit then
					World:effect_manager():set_remaining_lifetime(trail, math.clamp((furthest_hit.distance - 600) / 10000, 0, furthest_hit.distance))
				else
					World:effect_manager():set_remaining_lifetime(trail, math.clamp((self._range - 600) / 10000, 0, self._range)) --actually limit tracers using the shotgun's range limit if nothing is hit by a pellet
				end
			end
		end
	end

	--usual RaycastWeaponBase stat stuff to be used for AP slugs, as vanilla uses RaycastWeaponBase:fire_raycast to spawn another ray after penetrating something
	local hit_count = 0
	local cop_kill_count = 0
	local hit_through_wall = false
	local hit_through_shield = false
	local hit_anyone = false
	
	local extra_collisions = self.extra_collisions and self:extra_collisions()
	
	--usual shotgun stat stuff
	local kill_data = {
		kills = 0,
		headshots = 0,
		civilian_kills = 0
	}

	local units_to_ignore = {}
	local hit_enemies = {}
	local hit_shields = {}

	for _, col_ray in pairs(col_rays) do
		if col_ray and col_ray.unit then
			if self._single_damage_instance then
				if col_ray.unit:character_damage() then
					if not hit_enemies[col_ray.unit:key()] then --not already hit
						hit_enemies[col_ray.unit:key()] = col_ray
					else
						if col_ray.body then
							if col_ray.unit:character_damage().is_head then --has is_head function
								if col_ray.unit:character_damage():is_head(col_ray.body) then --prioritize headshots
									hit_enemies[col_ray.unit:key()] = col_ray
								elseif col_ray.body:name() == Idstring("body_helmet_plate") or col_ray.body:name() == Idstring("body_helmet_glass") then --prioritize dozer faceplates and visors over other body shots
									hit_enemies[col_ray.unit:key()] = col_ray
								end
							else
								local turret_shield = col_ray.unit:character_damage()._shield_body_name_ids
								local turret_weak_spot = col_ray.unit:character_damage()._bag_body_name_ids

								if turret_shield and (col_ray.body:name() == turret_shield) or turret_weak_spot and (col_ray.body:name() == turret_weak_spot) then --prioritize the shield or weak spot of a turret over other parts of it's body
									hit_enemies[col_ray.unit:key()] = col_ray
								end
							end
						end
					end
				else
					if self._rays ~= 1 and col_ray.unit:in_slot(managers.slot:get_mask("enemy_shield_check")) then
						if not hit_shields[col_ray.unit:key()] then --not already hit
							hit_shields[col_ray.unit:key()] = col_ray

							--only hit the shield once to avoid almost guaranteed knockbacks
							bullet_class:on_collision(col_ray, self._unit, user_unit, damage)
						else
							bullet_class:on_collision_effects(col_ray, self._unit, user_unit, damage)
						end
					else
						local final_damage = damage / self._rays
						final_damage = self:get_damage_falloff(final_damage, col_ray, user_unit)

						--still going to split damage here among the pellets and apply fall-off to avoid situations where a 155-damage shotgun deals 155 damage per pellet to things like solid objects or similar
						bullet_class:on_collision(col_ray, self._unit, user_unit, final_damage)
					end
				end
			else
				local final_damage
				
				if table.contains(units_to_ignore, col_ray.unit:key()) then
					final_damage = 0 --basically nullify the hit
				else
					--apply falloff and damage-per-pellet penalty for iron hand buckshot
					final_damage = self:get_damage_falloff(damage * tweak_data.TCD_WEAPON_BUCKSHOT_AMMO_DAMAGE_MUL, col_ray, user_unit)
					
					if col_ray.unit:character_damage() and col_ray.unit:character_damage().dead and col_ray.unit:character_damage():dead() then --additional check to avoid pushing dead enemies excessively
						table.insert(units_to_ignore, col_ray.unit:key())
					end
				end
				
				if self._rays ~= 1 and col_ray.unit:in_slot(managers.slot:get_mask("enemy_shield_check")) then
					if not hit_shields[col_ray.unit:key()] then --not already hit
						hit_shields[col_ray.unit:key()] = col_ray
						table.insert(units_to_ignore, col_ray.unit:key())

						--only hit the shield once to avoid almost guaranteed knockbacks
						bullet_class:on_collision(col_ray, self._unit, user_unit, damage)
					else
						bullet_class:on_collision_effects(col_ray, self._unit, user_unit, damage)
					end
				end

				if final_damage > 0 then
					local my_result = nil

					my_result = bullet_class:on_collision(col_ray, self._unit, user_unit, final_damage)
					
					if extra_collisions then
						for idx, extra_col_data in ipairs(extra_collisions) do
							if alive(hit.unit) then
								extra_col_data.bullet_class:on_collision(hit, self._unit, user_unit, dmg * (extra_col_data.dmg_mul or 1))
							end
						end
					end
					
					--only try to modify the result if the mutator is active and the unit is valid
					if managers.game_play_central:get_shotgun_push_range() ~= 500 and col_ray.unit:character_damage() and not (col_ray.unit:base() and col_ray.unit:base().sentry_gun) then
						my_result = managers.mutators:modify_value("ShotgunBase:_fire_raycast", my_result)
					end

					if ap_slug then
						if col_ray.unit:in_slot(managers.slot:get_mask("world_geometry")) then
							hit_through_wall = true
						elseif col_ray.unit:in_slot(managers.slot:get_mask("enemy_shield_check")) then
							hit_through_shield = hit_through_shield or alive(col_ray.unit:parent())
						end
					end

					if my_result then
						if col_ray.unit:character_damage() then
							if not hit_enemies[col_ray.unit:key()] then --to prevent accuracy stat shenanigans (if you hit an enemy, it counts as one hit for that one enemy, no matter how many pellets connect to the same enemy)
								hit_enemies[col_ray.unit:key()] = col_ray
							end
						end

						if ap_slug then
							col_ray.damage_result = my_result
							hit_anyone = true
							hit_count = hit_count + 1
						end

						if my_result.type then
							if my_result.type == "healed" then
								table.insert(units_to_ignore, col_ray.unit:key()) --to prevent units that were just healed from instantly dying again if you have enough damage
							elseif my_result.type == "death" then
								table.insert(units_to_ignore, col_ray.unit:key()) --to prevent unnecessary hits that send corpses flying even further

								if managers.game_play_central:get_shotgun_push_range() ~= 500 or not ap_slug and not dragons_breath then --usual shotgun push + allow AP slugs to abduct enemies (by causing a push) only when the mutator is enabled
									managers.game_play_central:do_shotgun_push(col_ray.unit, col_ray.position, col_ray.ray, col_ray.distance, user_unit)
								end

								kill_data.kills = kill_data.kills + 1

								if my_result.attack_data and my_result.attack_data.headshot then --remember this is only for headshot kills
									kill_data.headshots = kill_data.headshots + 1
								end
								
								local unit_base = col_ray.unit:base()
								local unit_type = unit_base and unit_base._tweak_table
								local is_civilian = unit_type and is_civ_f(unit_type)
								if is_civilian then
									kill_data.civilian_kills = kill_data.civilian_kills + 1
								else
									if ap_slug then
										cop_kill_count = cop_kill_count + 1
									end
								end
								
								if check_additional_achievements then
									self:_check_kill_achievements(cop_kill_count, unit_base, unit_type, is_civilian, hit_through_wall, hit_through_shield)
								end
							end
						end
					end
				end
			end
		end
	end

	if self._single_damage_instance then
		for _, col_ray in pairs(hit_enemies) do
			local final_damage = self:get_damage_falloff(damage, col_ray, user_unit) --damage obviously isn't equally splitted according to the number of pellets
			
			if final_damage > 0 then
				local my_result = nil

				my_result = bullet_class:on_collision(col_ray, self._unit, user_unit, final_damage)
				
				if extra_collisions then
					for idx, extra_col_data in ipairs(extra_collisions) do
						if alive(hit.unit) then
							extra_col_data.bullet_class:on_collision(hit, self._unit, user_unit, dmg * (extra_col_data.dmg_mul or 1))
						end
					end
				end
				
				if managers.game_play_central:get_shotgun_push_range() ~= 500 and not (col_ray.unit:base() and col_ray.unit:base().sentry_gun) then --only try to modify the result if the mutator is active and the unit is valid
					my_result = managers.mutators:modify_value("ShotgunBase:_fire_raycast", my_result)
				end

				if ap_slug then
					if col_ray.unit:in_slot(managers.slot:get_mask("world_geometry")) then
						hit_through_wall = true
					elseif col_ray.unit:in_slot(managers.slot:get_mask("enemy_shield_check")) then
						hit_through_shield = hit_through_shield or alive(col_ray.unit:parent())
					end
				end

				if my_result then
					if ap_slug then
						col_ray.damage_result = my_result
						hit_anyone = true
						hit_count = hit_count + 1
					end

					if my_result.type and my_result.type == "death" then
						--usual shotgun push + allow AP slugs and Dragon's Breath (requires copdamage small modification) to abduct enemies only when the mutator is enabled
						if managers.game_play_central:get_shotgun_push_range() ~= 500 or not ap_slug and not dragons_breath then
							managers.game_play_central:do_shotgun_push(col_ray.unit, col_ray.position, col_ray.ray, col_ray.distance, user_unit)
						end

						kill_data.kills = kill_data.kills + 1

						if my_result.attack_data and my_result.attack_data.headshot then --remember this is only for headshot kills
							kill_data.headshots = kill_data.headshots + 1
						end
						
						local unit_base = col_ray.unit:base()
						local unit_type = unit_base and unit_base._tweak_table
						local is_civilian = unit_type and is_civ_f(unit_type)

						if is_civilian then
							kill_data.civilian_kills = kill_data.civilian_kills + 1
						else
							if ap_slug then
								cop_kill_count = cop_kill_count + 1
							end
						end

						if check_additional_achievements then 
							self:_check_kill_achievements(cop_kill_count, unit_base, unit_type, is_civilian, hit_through_wall, hit_through_shield)
						end
					end
				end
			end
		end
	end

	if self._suppression then
		self:_suppress_units(mvector3.copy(from_pos), mvector3.copy(direction), self._range, managers.slot:get_mask("enemies"), user_unit, suppr_mul)
	end

	if not result then
		result = {
			hit_enemy = ap_slug and hit_anyone or #hit_enemies > 0 and true or false
		}

		if self._alert_events then
			result.rays = #col_rays > 0 and col_rays --all actual hits + firing location alert enemies accordingly
		end
	end

	managers.statistics:shot_fired({ --fired shots reduce end accuracy stat
		hit = false,
		weapon_unit = self._unit
	})

	for i = 1, #hit_enemies, 1 do --enemies hit per fired shot pull increase accuracy accordingly (negating the one above)
		managers.statistics:shot_fired({
			skip_bullet_count = true,
			hit = true,
			weapon_unit = self._unit
		})
	end


	if check_additional_achievements then 
		self:_check_tango_achievements(cop_kill_count)
	end
	
	self:_check_one_shot_shotgun_achievements(kill_data)

	return result
end

--proper shotgun tase rounds, if ever used (no blood impacts, damage against body sequence stuff and non-npc units reduced to 1, otherwise 0)
function InstantElectricBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank, no_sound)
	local hit_unit = col_ray.unit

	if hit_unit:damage() and managers.network:session() and col_ray.body:extension() and col_ray.body:extension().damage then
		local sync_damage = not blank and hit_unit:id() ~= -1
		local network_damage = math.ceil(1 * 163.84) --here's the damage against body extensions (like visors/faceplates) or things like glass, door locks, etc
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

	if alive(weapon_unit) and hit_unit:character_damage() and hit_unit:character_damage().damage_tase then
		local is_alive = not hit_unit:character_damage():dead()
		result = self:give_impact_damage(col_ray, weapon_unit, user_unit, damage, true)

		if result ~= "friendly_fire" then
			local is_dead = hit_unit:character_damage():dead()
			local push_multiplier = self:_get_character_push_multiplier(weapon_unit, is_alive and is_dead)

			managers.game_play_central:physics_push(col_ray, push_multiplier)
		end
	else
		managers.game_play_central:physics_push(col_ray)
	end

	return result
end

function InstantElectricBulletBase:give_impact_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing)
	local hit_unit = col_ray.unit
	local action_data = {
		damage = 0,
		weapon_unit = weapon_unit,
		attacker_unit = user_unit,
		col_ray = col_ray,
		armor_piercing = armor_piercing, --should be true to be sure, frontal body armor shouldn't block this
		attack_dir = col_ray.ray,
		variant = damage > 155 and "heavy" or "light" --placeholder, in case you have a better idea to calculate this for weapons
	}
	local defense_data = hit_unit and hit_unit:character_damage().damage_tase and hit_unit:character_damage():damage_tase(action_data)

	return defense_data
end
