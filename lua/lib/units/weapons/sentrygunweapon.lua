local tmp_rot1 = Rotation()

local mvec_to = Vector3()

function SentryGunWeapon:switch_fire_mode()
	self:_set_fire_mode(not self._use_armor_piercing)

	if self._use_armor_piercing then
		managers.hint:show_hint("sentry_set_ap_rounds")
		self._unit:base()._use_armor_piercing = true
	else
		managers.hint:show_hint("sentry_normal_ammo")
		self._unit:base()._use_armor_piercing = nil
	end

	self._unit:network():send("sentrygun_sync_armor_piercing", self._use_armor_piercing)
	self._unit:sound_source():post_event("wp_sentrygun_swap_ammo")
	self._unit:event_listener():call("on_switch_fire_mode", self._use_armor_piercing)
end

if deathvox:IsTotalCrackdownEnabled() then 

	function SentryGunWeapon:init(unit)
		if self._owner_id then 
			self._ammo_type = "basic"
			self._sentry_firemode = "normal"
		end
		
		self._unit = unit
		
		self._current_damage_mul = 1
		self._timer = TimerManager:game()
		self._character_slotmask = managers.slot:get_mask("raycastable_characters")
		self._next_fire_allowed = -1000
		self._obj_fire = self._unit:get_object(Idstring("a_detect"))

		self._shoot_through_data = {from = Vector3()}
			
		self._effect_align = {
			self._unit:get_object(Idstring(self._muzzle_flash_parent or "fire")),
			self._unit:get_object(Idstring(self._muzzle_flash_parent or "fire"))
		}
		self._muzzle_flash_parent = nil

		if self._laser_align_name then
			self._laser_align = self._unit:get_object(Idstring(self._laser_align_name))
		end
		
		self._interleaving_fire = 1
		self._trail_effect_table = {
			effect = RaycastWeaponBase.TRAIL_EFFECT,
			position = Vector3(),
			normal = Vector3()
		}
		self._ammo_sync_resolution = 0.0625

		if Network:is_server() then
			self._ammo_total = 1
			self._ammo_max = self._ammo_total
			self._ammo_sync = 16
		else
			self._ammo_ratio = 1
		end

		self._spread_mul = 1
		self._use_armor_piercing = false
		self._slow_fire_rate = false
		self._fire_rate_reduction = 1
		self._name_id = self._unit:base():get_name_id()
		
		local my_tweak_data = self:_get_tweak_data()
		self._default_alert_size = my_tweak_data.alert_size
		self._from = Vector3()
		self._to = Vector3()
	end
	
		
	local orig__init = SentryGunWeapon._init
	function SentryGunWeapon:_init(...)
		if not self._owner_id then 
			return orig__init(self,...)
		end
		self._ammo_type = "basic" 

		self._laser_align = self._laser_align or self._unit:get_object(Idstring("fire"))
		
		self._name_id = self._unit:base():get_name_id()
		
		local my_tweak_data = self:_get_tweak_data()

	--! changed from is_host check to is_owner check	
		self._bullet_slotmask = managers.slot:get_mask(self._unit:base():is_owner() and "bullet_impact_targets" or "bullet_blank_impact_targets")

		self._character_slotmask = managers.slot:get_mask("raycastable_characters")
		self._muzzle_effect = Idstring(my_tweak_data.muzzleflash or "effects/particles/test/muzzleflash_maingun")
		local muzzle_offset = Vector3()

		mvector3.set_static(muzzle_offset, 0, 10, 0)

		self._muzzle_effect_table = {
			{
				force_synch = false,
				effect = self._muzzle_effect,
				parent = self._effect_align[1]
			},
			{
				force_synch = false,
				effect = self._muzzle_effect,
				parent = self._effect_align[2]
			}
		}
		self._use_shell_ejection_effect = SystemInfo:platform() == Idstring("WIN32")

		if self._use_shell_ejection_effect then
			self._obj_shell_ejection = self._unit:get_object(Idstring("shell"))
			self._shell_ejection_effect = Idstring(tweak_data.weapon[self._name_id].shell_ejection or "effects/payday2/particles/weapons/shells/shell_556")
			self._shell_ejection_effect_table = {
				effect = self._shell_ejection_effect,
				parent = self._obj_shell_ejection
			}
		end

		self._damage = my_tweak_data.DAMAGE
		self._alert_events = {}
		self._alert_fires = {}
		self._suppression = my_tweak_data.SUPPRESSION
	end

	function SentryGunWeapon:setup(setup_data)
		if self._unit:base():is_owner() then 
			self._unit:base():_create_ws()
		end
		self:_init()
		
		--
		self:setup_criminal_laser()
		self:_set_sentry_laser(self._unit:weapon():_get_sentry_firemode())
		
		self._setup = setup_data
		self._default_alert_size = self._alert_size
		self._current_damage_mul = 1
		self._owner = setup_data.user_unit
		self._spread_mul = setup_data.spread_mul
		self._auto_reload = setup_data.auto_reload
		self._fire_rate_reduction = 1

		local td = self:_get_tweak_data() --changed reference to change alert size based on tweakdata rather than name_id
		if setup_data.alert_AI then
			self._alert_events = {}
			self._alert_size = self._alert_size or td.alert_size
			self._alert_fires = {}
		else
			self._alert_events = nil
			self._alert_size = nil
			self._alert_fires = nil
		end

		if setup_data.bullet_slotmask then
			self._bullet_slotmask = setup_data.bullet_slotmask
		end
		
	end


	function SentryGunWeapon:trigger_held(blanks, expend_ammo, shoot_player, target_unit)
		local fired = nil

		if self._next_fire_allowed <= self._timer:time() then
			fired = self:fire(blanks, false, shoot_player, target_unit)
			local td = self:_get_tweak_data()
			if fired then
				local fire_rate = td.auto.fire_rate * self._fire_rate_reduction
				if self._unit:base():is_owner() then 
					if self:_get_ammo_type() ~= "basic" then 
					--turns out this fire-rate value is seconds per bullet, not bullets per second. 5HEAD
						fire_rate = fire_rate * managers.player:upgrade_value("sentry_gun","hobarts_funnies",1)
					end
				end
				self._next_fire_allowed = self._next_fire_allowed + fire_rate
				self._interleaving_fire = self._interleaving_fire == 1 and 2 or 1
			end
		end

		return fired
	end

	function SentryGunWeapon:fire(blanks, expend_ammo, shoot_player, target_unit)
		if expend_ammo then
			if self._ammo_total <= 0 then
				return
			end

			self:change_ammo(-1)
		end

		local fire_obj = self._effect_align[self._interleaving_fire]
		local from_pos = fire_obj:position()
		local direction = fire_obj:rotation():y()
		local td = self:_get_tweak_data()
		
		local SPREAD = td.SPREAD
		local td = self:_get_tweak_data()
		
		local firemode = self:_get_sentry_firemode()
		local ammotype = self:_get_ammo_type()
		
		if firemode ~= "overwatch" then 
			if (firemode ~= "manual") or not managers.player:has_category_upgrade("sentry","wrangler_accuracy") then
				--for wrangler mode + wrangler basic skill, skip spread calculations and use perfect accuracy instead
				mvector3.spread(direction, SPREAD * self._spread_mul)
			end
		end
		World:effect_manager():spawn(self._muzzle_effect_table[self._interleaving_fire])

		if self._use_shell_ejection_effect then
			World:effect_manager():spawn(self._shell_ejection_effect_table)
		end

		if self._unit:damage() and self._unit:damage():has_sequence("anim_fire_seq") then
			self._unit:damage():run_sequence_simple("anim_fire_seq")
		end

		local ray_res = self:_fire_raycast(from_pos, direction, shoot_player, target_unit)

		if self._alert_events and ray_res.rays then
			RaycastWeaponBase._check_alert(self, ray_res.rays, from_pos, direction, self._unit)
		end

		self._unit:movement():give_recoil()
		self._unit:event_listener():call("on_fire")

		return ray_res
	end

	function SentryGunWeapon:_fire_raycast(from_pos, direction, shoot_player, target_unit)
		if not self._setup.ignore_units then
			return
		end
		
		local td = self:_get_tweak_data()
		local ray_distance = td.FIRE_RANGE or 20000
		
		local firemode = self:_get_sentry_firemode()
		local ammotype = self:_get_ammo_type()
		
		local bullet_base = InstantBulletBase
		if ammotype == "taser" then 
			bullet_base = ElectricBulletBase
		elseif ammotype == "he" then 
			bullet_base = InstantExplosiveBulletBase
		end

		if firemode == "overwatch" then 
			ray_distance = 100000
		end
		if self._unit:base():is_owner() then 
			local advanced_rangefinder_data = managers.player:upgrade_value("sentry_gun","advanced_rangefinder",{0,0})
			ray_distance = ray_distance * (1 + advanced_rangefinder_data[1])
		end

		local hit_unit = nil
		local result = {}

		mvector3.set(mvec_to, direction)
		mvector3.multiply(mvec_to, ray_distance)
		mvector3.add(mvec_to, from_pos)

		self._from = from_pos
		self._to = mvec_to

		local ray_hits = nil
		local hit_enemy = false
		local went_through_wall = false
		local enemy_mask = self._unit:in_slot(25) and managers.slot:get_mask("enemies") or managers.slot:get_mask("criminals")
		local wall_mask = managers.slot:get_mask("world_geometry", "vehicles")
		local shield_mask = managers.slot:get_mask("enemy_shield_check")
		local ai_vision_ids = Idstring("ai_vision")
		local bulletproof_ids = Idstring("bulletproof")

		if self._use_armor_piercing then
			ray_hits = World:raycast_wall("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "thickness", 40, "thickness_mask", wall_mask) --try to change so that no infinite penetration happens
		else
			ray_hits = World:raycast_all("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
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

				if not self._use_armor_piercing then
					if hit_enemy or hit.unit:in_slot(wall_mask) and weak_body or hit.unit:in_slot(shield_mask) then
						break
					end
				else
					if hit.unit:in_slot(wall_mask) and weak_body then
						if went_through_wall then
							break
						else
							went_through_wall = true
						end
					end
				end
			end
		end

		local furthest_hit = unique_hits[#unique_hits]

		if #unique_hits > 0 then
			local hit_player = false

			for _, hit in ipairs(unique_hits) do
				if not hit_player and shoot_player then
					local player_hit_ray = deep_clone(hit)
					local player_hit, player_ray_data = RaycastWeaponBase.damage_player(self, player_hit_ray, from_pos, direction, result)

					if player_hit then
						hit_player = true
						char_hit = true

						local damage = self:_apply_dmg_mul(self._damage, player_ray_data, from_pos)
						local damaged_player = bullet_base:on_hit_player(player_hit_ray, self._unit, self._unit, damage)

						if damaged_player then
							if not self._use_armor_piercing then
								hit.unit = managers.player:player_unit()
								hit.body = hit.unit:body("inflict_reciever")
								hit.position = mvector3.copy(hit.body:position())
								hit.hit_position = hit.position
								hit.distance = mvector3.direction(hit.ray, mvector3.copy(from_pos), mvector3.copy(hit.position))
								hit.normal = -hit.ray
								furthest_hit = hit

								break
							end
						end	
					end
				end

				local damage = self:_apply_dmg_mul(self._damage, hit, from_pos)
				if alive(hit.unit) and self._unit:base():is_owner() then  
					if hit.unit:contour() then
						local mark_data = managers.player:upgrade_value("sentry_gun","targeting_matrix",false)
						if mark_data and type(mark_data) == "table" then 
							if mark_data[1] and hit.unit:contour()._contour_list and hit.unit:contour():has_id(mark_data[1]) then 
								damage = damage * (1 + mark_data[2])
							end
						end
					end
					if hit.body == hit.unit:body("Head") then 
						damage = damage * (1 + managers.player:upgrade_value("sentry_gun","wrangler_headshot_damage_bonus",0))
					end
					
				end
				if bullet_base:on_collision(hit, self._unit, self._unit, damage) then
					char_hit = true
				end
			end
		else
			if shoot_player then
				local player_hit, player_ray_data = RaycastWeaponBase.damage_player(self, nil, from_pos, direction, result)

				if player_hit then
					local damage = self:_apply_dmg_mul(self._damage, player_ray_data, from_pos)
					local damaged_player = bullet_base:on_hit_player(player_ray_data, self._unit, self._unit, damage)

					if damaged_player then
						char_hit = true

						if not self._use_armor_piercing then
							player_ray_data.unit = managers.player:player_unit()
							player_ray_data.body = player_ray_data.unit:body("inflict_reciever")
							player_ray_data.position = mvector3.copy(player_ray_data.body:position())
							player_ray_data.hit_position = player_ray_data.position
							player_ray_data.distance = mvector3.direction(player_ray_data.ray, mvector3.copy(from_pos), mvector3.copy(player_ray_data.position))
							player_ray_data.normal = -player_ray_data.ray
							furthest_hit = player_ray_data
						end
					end	
				end
			end
		end

		result.hit_enemy = char_hit

		if alive(self._obj_fire) then
			if furthest_hit and furthest_hit.distance > 600 or not furthest_hit then
				local trail_direction = furthest_hit and furthest_hit.ray or direction

				self:_spawn_trail_effect(trail_direction, furthest_hit)
			end
		end

		if self._suppression then
			local suppression_slot_mask = self._unit:in_slot(25) and managers.slot:get_mask("enemies") or managers.slot:get_mask("players", "criminals")

			RaycastWeaponBase._suppress_units(self, mvector3.copy(from_pos), mvector3.copy(direction), ray_distance, suppression_slot_mask, self._unit, nil)
		end

		if self._alert_events then
			result.rays = unique_hits
		end

		return result
	end

	function SentryGunWeapon:auto_fire_start_event()
		local ammo_type = self:_get_ammo_type()
		if (ammo_type == "ap") or (ammo_type == "he") then
			return self._fire_start_snd_event_ap
		else
			return self._fire_start_snd_event
		end
	end

	function SentryGunWeapon:auto_fire_end_event()
		local ammo_type = self:_get_ammo_type()
		if (ammo_type == "ap") or (ammo_type == "he") then
			return self._fire_stop_snd_event_ap
		else
			return self._fire_stop_snd_event
		end
	end


	function SentryGunWeapon:_apply_dmg_mul(damage, col_ray, from_pos)
		if self._unit:base():is_owner() then 
			damage = damage + managers.player:upgrade_value("sentry_gun","killer_machines_bonus_damage",0)
		end
		local damage_out = damage * self._current_damage_mul
		
		local td = self:_get_tweak_data()
		
		
		if td.DAMAGE_MUL_RANGE then
			local ray_dis = col_ray.distance or mvector3.distance(from_pos, col_ray.position)
			local ranges = td.DAMAGE_MUL_RANGE
			local i_range = nil

			for test_i_range, range_data in ipairs(ranges) do
				if ray_dis < range_data[1] or test_i_range == #ranges then
					i_range = test_i_range

					break
				end
			end

			if i_range == 1 or ranges[i_range][1] < ray_dis then
				damage_out = damage_out * ranges[i_range][2]
			else
				local dis_lerp = (ray_dis - ranges[i_range - 1][1]) / (ranges[i_range][1] - ranges[i_range - 1][1])
				damage_out = damage_out * math.lerp(ranges[i_range - 1][2], ranges[i_range][2], dis_lerp)
			end
		end

		return damage_out
	end

	local orig_update = SentryGunWeapon.update_laser
	function SentryGunWeapon:update_laser(...)
		if not self._unit:base()._owner_id then 
			return orig_update(self,...)
		end
		
		if not self:has_laser() then
			return
		end

		if self._unit:character_damage():dead() then 
			self:set_laser_enabled(false)
			return
		elseif self._unit:movement():is_inactivating() or self._unit:movement():is_inactivated() then
		elseif self._unit:movement():is_activating() or self._unit:movement():rearming() then
	--		self:set_laser_enabled("turret_module_rearming",true)
			return
		end
		self:_set_laser_state(true)
		if self._laser_unit then 
			self._laser_unit:base():set_on()
		end
	end
	
	
 --(below are all custom functions)
	function SentryGunWeapon:_get_tweak_data() --custom method
		if self._ammo_type == "taser" then 
			return tweak_data.weapon.sentry_taser
		elseif self._ammo_type == "ap" then 
			return tweak_data.weapon.sentry_ap
		elseif self._ammo_type == "he" then 
			return tweak_data.weapon.sentry_he
		else
			return (self._name_id and tweak_data.weapon[self._name_id]) or tweak_data.weapon.sentry_gun
		end
	end

	function SentryGunWeapon:_set_sentry_firemode(mode,play_sound)
		if self._sentry_firemode ~= mode then 
			if play_sound then 
				self._unit:sound_source():post_event("wp_sentrygun_swap_ammo")
			end
			self:stop_autofire()
			self:flip_fire_sound()
		end
		self:_set_sentry_laser(mode)
		self._sentry_firemode = mode
	end

	function SentryGunWeapon:_set_sentry_laser(mode)
		if self._laser_unit and self._laser_align then
			local color = Color(0,0,0,0)
			if mode == "manual" then
				color = SentryControlMenu.tweakdata.color_mode_manual
			elseif mode == "overwatch" then
				color = SentryControlMenu.tweakdata.color_mode_overwatch
			end
			if not self._unit:base():is_owner() then 
				self:set_laser_color(color:with_alpha(SentryControlMenu:GetTeammateSentryLaserAlpha()))
			else
				self:set_laser_color(color)
			end
		end
	end

	function SentryGunWeapon:_set_ammo_type(ammo_type,play_sound)
		if self._ammo_type ~= ammo_type then
			if play_sound then 
				self._unit:sound_source():post_event("wp_sentrygun_swap_ammo")
			end		
			self:stop_autofire()
			self:flip_fire_sound()
			self._use_armor_piercing = ammo_type == "ap"
		end
		
		self._ammo_type = ammo_type
	end

	function SentryGunWeapon:_get_ammo_type()
		return self._ammo_type
	end

	function SentryGunWeapon:_get_sentry_firemode()
		return self._sentry_firemode
	end

	function SentryGunWeapon:setup_criminal_laser() --creates the laser object, for player deployable sentries only
		if self._laser_unit and self._laser_align and self._unit:movement():team().id == "criminal1" then
			self._laser_unit:base():set_color(Color(0,0,0))
		elseif not alive(self._laser_unit) then
			self._laser_align = self._laser_align or self._unit:get_object(Idstring("fire"))
			if self._laser_align then 		
				local spawn_rot = self._laser_align:rotation()
				local spawn_pos = self._laser_align:position()
				self._laser_unit = World:spawn_unit(Idstring("units/payday2/weapons/wpn_npc_upg_fl_ass_smg_sho_peqbox/wpn_npc_upg_fl_ass_smg_sho_peqbox"), spawn_pos, spawn_rot)
				self._unit:link(self._laser_align:name(), self._laser_unit)
				self._laser_unit:base():set_npc()
				self._laser_unit:base():set_on()
				self._laser_unit:base():set_max_distace(10000)
				self._laser_unit:base():add_ray_ignore_unit(self._unit)
				self._laser_unit:base():set_color(Color(0,0,0))
				self._laser_unit:set_visible(false)
			end
		end
	end

	function SentryGunWeapon:set_laser_color(color)
		if alive(self._laser_unit) then 
			self._laser_unit:base():set_color(color)
		end
	end

	
else 
	function SentryGunWeapon:init(unit)
		self._unit = unit
		self._current_damage_mul = 1
		self._timer = TimerManager:game()
		self._character_slotmask = managers.slot:get_mask("raycastable_characters")
		self._next_fire_allowed = -1000
		self._obj_fire = self._unit:get_object(Idstring("a_detect"))
		self._shoot_through_data = {from = Vector3()}
		self._effect_align = {
			self._unit:get_object(Idstring(self._muzzle_flash_parent or "fire")),
			self._unit:get_object(Idstring(self._muzzle_flash_parent or "fire"))
		}
		self._muzzle_flash_parent = nil

		if self._laser_align_name then
			self._laser_align = self._unit:get_object(Idstring(self._laser_align_name))
		end

		self._interleaving_fire = 1
		self._trail_effect_table = {
			effect = RaycastWeaponBase.TRAIL_EFFECT,
			position = Vector3(),
			normal = Vector3()
		}
		self._ammo_sync_resolution = 0.0625

		if Network:is_server() then
			self._ammo_total = 1
			self._ammo_max = self._ammo_total
			self._ammo_sync = 16
		else
			self._ammo_ratio = 1
		end

		self._spread_mul = 1
		self._use_armor_piercing = false
		self._slow_fire_rate = false
		self._fire_rate_reduction = 1
		self._name_id = self._unit:base():get_name_id()
		local my_tweak_data = tweak_data.weapon[self._name_id]
		self._default_alert_size = my_tweak_data.alert_size
		self._from = Vector3()
		self._to = Vector3()
	end

	function SentryGunWeapon:_fire_raycast(from_pos, direction, shoot_player, target_unit)
		if not self._setup.ignore_units then
			return
		end

		local hit_unit = nil
		local result = {}
		local ray_distance = tweak_data.weapon[self._name_id].FIRE_RANGE or 20000

		mvector3.set(mvec_to, direction)
		mvector3.multiply(mvec_to, ray_distance)
		mvector3.add(mvec_to, from_pos)

		self._from = from_pos
		self._to = mvec_to

		local ray_hits = nil
		local hit_enemy = false
		local went_through_wall = false
		local enemy_mask = self._unit:in_slot(25) and managers.slot:get_mask("enemies") or managers.slot:get_mask("criminals")
		local wall_mask = managers.slot:get_mask("world_geometry", "vehicles")
		local shield_mask = managers.slot:get_mask("enemy_shield_check")
		local ai_vision_ids = Idstring("ai_vision")
		local bulletproof_ids = Idstring("bulletproof")

		if self._use_armor_piercing then
			ray_hits = World:raycast_wall("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "thickness", 40, "thickness_mask", wall_mask) --try to change so that no infinite penetration happens
		else
			ray_hits = World:raycast_all("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
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

				if not self._use_armor_piercing then
					if hit_enemy or hit.unit:in_slot(wall_mask) and weak_body or hit.unit:in_slot(shield_mask) then
						break
					end
				else
					if hit.unit:in_slot(wall_mask) and weak_body then
						if went_through_wall then
							break
						else
							went_through_wall = true
						end
					end
				end
			end
		end

		local furthest_hit = unique_hits[#unique_hits]

		if #unique_hits > 0 then
			local hit_player = false

			for _, hit in ipairs(unique_hits) do
				if not hit_player and shoot_player then
					local player_hit_ray = deep_clone(hit)
					local player_hit, player_ray_data  = RaycastWeaponBase.damage_player(self, player_hit_ray, from_pos, direction, result)

					if player_hit then
						hit_player = true
						char_hit = true

						local damage = self:_apply_dmg_mul(self._damage, player_ray_data, from_pos)
						local damaged_player = InstantBulletBase:on_hit_player(player_hit_ray, self._unit, self._unit, damage)

						if damaged_player then
							if not self._use_armor_piercing then
								hit.unit = managers.player:player_unit()
								hit.body = hit.unit:body("inflict_reciever")
								hit.position = mvector3.copy(hit.body:position())
								hit.hit_position = hit.position
								hit.distance = mvector3.direction(hit.ray, mvector3.copy(from_pos), mvector3.copy(hit.position))
								hit.normal = -hit.ray
								furthest_hit = hit

								break
							end
						end	
					end
				end

				local damage = self:_apply_dmg_mul(self._damage, hit, from_pos)

				if InstantBulletBase:on_collision(hit, self._unit, self._unit, damage) then
					char_hit = true
				end
			end
		else
			if shoot_player then
				local player_hit, player_ray_data = RaycastWeaponBase.damage_player(self, nil, from_pos, direction, result)

				if player_hit then
					local damage = self:_apply_dmg_mul(self._damage, player_ray_data, from_pos)
					local damaged_player = InstantBulletBase:on_hit_player(player_ray_data, self._unit, self._unit, damage)

					if damaged_player then
						char_hit = true

						if not self._use_armor_piercing then
							player_ray_data.unit = managers.player:player_unit()
							player_ray_data.body = player_ray_data.unit:body("inflict_reciever")
							player_ray_data.position = mvector3.copy(player_ray_data.body:position())
							player_ray_data.hit_position = player_ray_data.position
							player_ray_data.distance = mvector3.direction(player_ray_data.ray, mvector3.copy(from_pos), mvector3.copy(player_ray_data.position))
							player_ray_data.normal = -player_ray_data.ray
							furthest_hit = player_ray_data
						end
					end	
				end
			end
		end

		result.hit_enemy = char_hit

		if alive(self._obj_fire) then
			if furthest_hit and furthest_hit.distance > 600 or not furthest_hit then
				local trail_direction = furthest_hit and furthest_hit.ray or direction

				self:_spawn_trail_effect(trail_direction, furthest_hit)
			end
		end

		if self._suppression then
			local suppression_slot_mask = self._unit:in_slot(25) and managers.slot:get_mask("enemies") or managers.slot:get_mask("players", "criminals")

			RaycastWeaponBase._suppress_units(self, mvector3.copy(from_pos), mvector3.copy(direction), ray_distance, suppression_slot_mask, self._unit, nil)
		end

		if self._alert_events then
			result.rays = unique_hits
		end

		return result
	end
	
end