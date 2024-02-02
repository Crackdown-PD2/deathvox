local mvec3_x = mvector3.x
local mvec3_y = mvector3.y
local mvec3_z = mvector3.z
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_sub = mvector3.subtract
local mvec3_dot = mvector3.dot
local mvec3_dis = mvector3.distance
local mvec3_dist_sq = mvector3.distance_sq
local mvec3_dir = mvector3.direction
local mvec3_norm = mvector3.normalize
local mvec3_cross = mvector3.cross
local mvec3_rand_ortho = mvector3.random_orthogonal
local mvec3_negate = mvector3.negate
local mvec3_len = mvector3.length
local mvec3_cpy = mvector3.copy
local mvec3_set_stat = mvector3.set_static
local mvec3_set_length = mvector3.set_length
local mvec3_angle = mvector3.angle
local mvec3_step = mvector3.step
local mvec3_lerp = mvector3.lerp

local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_vec3 = Vector3()

local math_lerp = math.lerp
local math_random = math.random
local math_up = math.UP
local math_abs = math.abs
local math_clamp = math.clamp
local math_min = math.min
local math_max = math.max
local math_sqrt = math.sqrt

local m_rot_x = mrotation.x
local m_rot_y = mrotation.y
local m_rot_z = mrotation.z

local table_insert = table.insert
local table_contains = table.contains

local REACT_COMBAT = AIAttentionObject.REACT_COMBAT
local REACT_SCARED = AIAttentionObject.REACT_SCARED
local REACT_SHOOT = AIAttentionObject.REACT_SHOOT
local REACT_SUSPICIOUS = AIAttentionObject.REACT_SUSPICIOUS

local is_local_vr = _G.IS_VR

local IS_TOTAL_CRACKDOWN_ENABLED = deathvox:IsTotalCrackdownEnabled()

function SentryGunBrain:_upd_fire(t,dt)
	local is_owner = self._unit:base():is_owner()
	local sentryweapon = self._unit:weapon()

	if self._ext_movement:is_activating() or self._ext_movement:is_inactivating() or self._idle then
		if self._firing then
			self:stop_autofire()
		end

		return
	end
	
	local expend_ammo = Network:is_server()
	local attention = self._ext_movement:attention()

	if sentryweapon:out_of_ammo() then
		if sentryweapon:can_auto_reload() then
			if self._firing then
				self:stop_autofire()
			end

			if not self._ext_movement:rearming() then
				self._ext_movement:rearm()
			end
		elseif not self._unit:base():waiting_for_refill() then
			self:switch_off()
		end
	elseif self._ext_movement:rearming() then
		self._ext_movement:complete_rearming()
	else
		local is_firemode_manual
		local is_ammo_ap
		if IS_TOTAL_CRACKDOWN_ENABLED then 
			local firemode = sentryweapon:_get_sentry_firemode()
			is_firemode_manual = firemode == "manual"
			is_ammo_ap = sentryweapon:_get_ammo_type() == "ap"
		end
		
		if is_owner and is_firemode_manual and not self._ext_movement:warming_up(t) then 
			local target
			local fire_obj = sentryweapon._effect_align[sentryweapon._interleaving_fire or ""]
			if alive(fire_obj) then 
				local my_pos = fire_obj:position()
				local direction = fire_obj:rotation():y()
				
				local td = self:_get_tweak_data()
				local fire_range = td.FIRE_RANGE
				
				local aim_pos = my_pos + (direction * fire_range)
				
				local bullet_slotmask = sentryweapon._bullet_slotmask
				
				if is_ammo_ap then
					bullet_slotmask = bullet_slotmask - self._shield_check
				end
				local manual_ray = World:raycast("ray",my_pos,aim_pos,"slot_mask",bullet_slotmask)
				
				local aim_unit = manual_ray and manual_ray.unit
				if aim_unit and managers.enemy:is_enemy(aim_unit) then 
					target = true
					
					if not self._firing then 
						sentryweapon:start_autofire()
						self._firing = true
					end
					
					sentryweapon:trigger_held(false, expend_ammo, false, aim_unit)
					
				end
				
			end
			if self._firing and not target then 
				self:stop_autofire()
			end
		elseif attention and attention.reaction and REACT_SHOOT <= attention.reaction and not self._ext_movement:warming_up(t) then
			local target_pos = self:get_target_base_pos(attention)

			if not target_pos then
				if self._firing then
					self:stop_autofire()
				end

				return
			end

			local my_pos = self._ext_movement:m_head_pos()

			if attention.unit and not self:_ignore_shield(my_pos, target_pos) then
				if self._firing then
					self:stop_autofire()
				end

				return
			end

			if not self:is_target_on_sight(my_pos, target_pos, attention.unit) then
				if self._firing then
					self:stop_autofire()
				end

				return
			end
			
			if is_owner then 
				if managers.player:has_category_upgrade("sentry_gun","automatic_highlight_enemies") then
					local mark_data = managers.player:upgrade_value("sentry_gun","automatic_highlight_enemies")
					if attention.unit and attention.unit:contour() then 
						local mark_type = mark_data[1]
						if attention.unit:base() and attention.unit:base().sentry_gun then 
							mark_type = "mark_unit_dangerous_damage_bonus"
							--temp fix 
						end
						attention.unit:contour():add(mark_type, true, 1)
	--						managers.network:session():send_to_peers_synched("spot_enemy", attention.unit)
					end
				end
				
			end
			


			local damage_player = attention.unit:base() and attention.unit:base().is_local_player

			if self._firing then
				sentryweapon:trigger_held(false, expend_ammo, damage_player, attention.unit)
			else
				mvec3_dir(tmp_vec1, my_pos, target_pos)

				local max_dot = self._tweak_data.KEEP_FIRE_ANGLE
				local sharpness_mul = self._shaprness_mul or 1
				max_dot = math_min(0.99, 1 - (1 - max_dot) * sharpness_mul)

				if max_dot < mvec3_dot(tmp_vec1, self._ext_movement:m_head_fwd()) then
					sentryweapon:start_autofire()
					sentryweapon:trigger_held(false, expend_ammo, damage_player, attention.unit)

					self._firing = true
				end
			end
		elseif self._firing then
			self:stop_autofire()
		end
	end
end

function SentryGunBrain:on_detected_attention_obj_modified(modified_u_key)
	local attention_info = self._detected_attention_objects[modified_u_key]

	if not attention_info then
		return
	end

	local new_settings = attention_info.handler:get_attention(self._SO_access, REACT_SUSPICIOUS, nil, self._unit:movement():team())
	local old_settings = attention_info.settings

	if new_settings == old_settings then
		return
	end

	local old_notice_clbk = not attention_info.identified and old_settings.notice_clbk ~= "clbk_notice_sneak" and old_settings.notice_clbk

	if new_settings then
		attention_info.settings = new_settings
		attention_info.stare_expire_t = nil
		attention_info.pause_expire_t = nil

		if attention_info.unit:character_damage() and attention_info.unit:character_damage().dead then
			attention_info.is_alive = not attention_info.unit:character_damage():dead()
		end
	else
		self:_destroy_detected_attention_object_data(attention_info)

		if self._attention_obj and self._attention_obj.u_key == modified_u_key then
			self._ext_movement:set_attention()
		end
	end

	if old_notice_clbk then
		if not new_settings or not new_settings.notice_clbk then
			old_notice_clbk(self._unit, false)
		end
	end
end

if IS_TOTAL_CRACKDOWN_ENABLED then

	local _setup_attention_handler_original = SentryGunBrain._setup_attention_handler
	function SentryGunBrain:_setup_attention_handler()
		if not self._unit:character_damage()._ignore_client_damage then
			_setup_attention_handler_original(self)
		end
	end

	function SentryGunBrain:switch_off()
		local is_server = Network:is_server()

		if is_server then
			self._ext_movement:set_attention()
		end

		self:set_active(false)
		self._ext_movement:switch_off()
		self._unit:set_slot(26)

		if managers.groupai:state():all_criminals()[self._unit:key()] then
			managers.groupai:state():on_criminal_neutralized(self._unit)
		end

		if is_server and self._attention_handler then
			PlayerMovement.set_attention_settings(self, nil)
		end

		self._unit:base():unregister()

		self._attention_obj = nil
	end

	function SentryGunBrain:_get_tweak_data() --custom method
		if self._unit:weapon() then 
			return self._unit:weapon():_get_tweak_data()
		end

		return self._name_id and tweak_data.weapon[self._name_id] or tweak_data.weapon.sentry_gun
	end

	function SentryGunBrain:update(unit, t, dt)
		if self._unit:base():is_owner() or Network:is_server() then
			self:_upd_detection(t)
			self:_select_focus_attention(t)
		end
		
		if Network:is_server() then
			self:_upd_flash_grenade(t)
			self:_upd_go_idle(t)
		end

		self:_upd_fire(t,dt)
	end

	function SentryGunBrain:switch_on()
		if self._active or self._unit:character_damage():dead() then
			return
		end

		if self._unit:damage():has_sequence("laser_activate") then
			self._unit:damage():run_sequence_simple("laser_activate")
		end
		
		self:set_active(true)
		self._ext_movement:switch_on()
		self._unit:set_slot(25)
		self._unit:base():register()
	end

	function SentryGunBrain:_upd_detection(t)
		if self._ext_movement:is_activating() or self._ext_movement:is_inactivating() then
			return
		end

		if t < self._next_detection_upd_t then
			return
		end

		local my_SO_access_str = self._SO_access_str
		local my_SO_access = self._SO_access
		local detected_objects = self._detected_attention_objects
		local my_key = self._unit:key()
		local my_team = self._ext_movement:team()
		local my_pos = self._ext_movement:m_head_pos()
		local my_tracker = self._ext_movement:nav_tracker()
		local chk_vis_func = my_tracker.check_visibility
		local vis_mask = self._visibility_slotmask
		local all_attention_objects = managers.groupai:state():get_AI_attention_objects_by_filter(my_SO_access_str, my_team)
		local parent_unit = alive(self._unit:parent()) and self._unit:parent()

		local td = self:_get_tweak_data()
		local detection_preset = td.DETECTION_DELAY
		local firing_range = td.FIRE_RANGE
		local max_detection_range = td.DETECTION_RANGE
		local firemode = self._unit:weapon():_get_sentry_firemode()

		if firemode == "overwatch" then
			firing_range = SentryControlMenu.tweakdata.OVERWATCH_DETECTION_RANGE
			max_detection_range = SentryControlMenu.tweakdata.OVERWATCH_DETECTION_RANGE
		end
		
		local target_any_specials

		if self._unit:base():is_owner() then 
			if managers.player:has_category_upgrade("sentry_gun","targeting_range_increase") then 
				local range_increase = managers.player:upgrade_value("sentry_gun","targeting_range_increase")
				firing_range = firing_range * (1 + range_increase)
				max_detection_range = max_detection_range * (1 + range_increase)
			end
			
			target_any_specials = managers.player:has_category_upgrade("sentry_gun","overwatch_targets_all_specials")
		end
		

		for u_key, attention_info in pairs(all_attention_objects) do
			if u_key ~= my_key and not detected_objects[u_key] then
				local skip = nil
				local att_unit = attention_info.unit
				local att_mov_ext = att_unit:movement()

				if firemode == "overwatch" then
					local att_base_ext = attention_info.unit:base()
					--if overwatch firemode, targeted enemy must be a sniper in order to notice them
					if att_base_ext and att_base_ext.has_tag then 
						if target_any_specials then
							if not att_base_ext:has_tag("special") then 
								skip = true
							end
						elseif not att_base_ext:has_tag("sniper") then
							skip = true
						end
					else
						skip = true
					end
				end

				if not skip and att_mov_ext then
					if att_mov_ext.downed and att_mov_ext:downed() then
						skip = true
					elseif att_mov_ext.is_cuffed and att_mov_ext:is_cuffed() then
						skip = true
					end
				end

				if not skip then
					local att_dmg_ext = att_unit:character_damage()

					if att_dmg_ext then
						if att_dmg_ext.dead and att_dmg_ext:dead() or att_dmg_ext.health_ratio and att_dmg_ext:health_ratio() <= 0 then
							skip = true
						end
					end

					if not skip then
						local att_brain_ext = att_unit:brain()

						if att_brain_ext then
							if att_brain_ext.objective and att_brain_ext:objective() == "surrender" or att_brain_ext.surrendered and att_brain_ext:surrendered() then
								skip = true
							end
						end
					end
				end

				if not skip then
					if not attention_info.nav_tracker or chk_vis_func(my_tracker, attention_info.nav_tracker) then
						local settings = attention_info.handler:get_attention(my_SO_access, REACT_SUSPICIOUS, nil, my_team)

						if settings then
							local distance = nil
							local attention_pos = attention_info.handler:get_detection_m_pos()
							local dis_sq = mvec3_dist_sq(my_pos, attention_pos)
							local max_dis = max_detection_range

							if settings.max_range then
								max_dis = math_min(max_dis, settings.max_range)
							end

							if settings.detection and settings.detection.range_mul then
								max_dis = max_dis * settings.detection.range_mul
							end

							local max_dis_sq = max_dis * max_dis

							if dis_sq < max_dis_sq then
								distance = math_sqrt(dis_sq)

								local vis_ray = nil

								if parent_unit then
									vis_ray = self._unit:raycast("ray", my_pos, attention_pos, "slot_mask", vis_mask, "ignore_unit", parent_unit, "ray_type", "ai_vision")
								else
									vis_ray = self._unit:raycast("ray", my_pos, attention_pos, "slot_mask", vis_mask, "ray_type", "ai_vision")
								end

								if not vis_ray or vis_ray.unit:key() == u_key then
									local visible_data = {
										visible_dis_multiplier = distance,
										visible_ray = vis_ray
									}

									detected_objects[u_key] = CopLogicBase._create_detected_attention_object_data(t, self._unit, u_key, attention_info, settings, nil, visible_data)
								end
							end
						end
					end
				end
			end
		end

		local update_delay = 2
		local health_ratio_chk_func = self._attention_health_ratio
		local objective_chk_func = self._attention_objective

		for u_key, attention_info in pairs(detected_objects) do
			if not attention_info.visible_in_this_instance and t < attention_info.next_verify_t then
				update_delay = math_min(attention_info.next_verify_t - t, update_delay)
			else
				local att_mov_ext = attention_info.unit:movement()
				local skip = nil

				if not attention_info.is_alive then
					skip = true
				else
					if firemode == "overwatch" then
						local att_base_ext = attention_info.unit:base()
						--if overwatch firemode, targeted enemy must be a sniper in order to notice them
						if att_base_ext and att_base_ext.has_tag then 
							if target_any_specials then
								if not att_base_ext:has_tag("special") then 
									skip = true
								end
							elseif not att_base_ext:has_tag("sniper") then
								skip = true
							end
						else
							skip = true
						end
					end

					if not skip and att_mov_ext then
						if att_mov_ext.downed and att_mov_ext:downed() then
							skip = true
						elseif att_mov_ext.is_cuffed and att_mov_ext:is_cuffed() then
							skip = true
						end
					end

					if not skip then
						if health_ratio_chk_func(self, attention_info) <= 0 or objective_chk_func(self, attention_info) == "surrender" then
							skip = true
						else
							local att_brain_ext = attention_info.unit:brain()

							if att_brain_ext and att_brain_ext.surrendered and att_brain_ext:surrendered() then
								skip = true
							end
						end
					end
				end

				if skip then
					self:_destroy_detected_attention_object_data(attention_info)
				else
					local settings = attention_info.settings
					local verify_interval = nil

					if attention_info.identified and attention_info.verified then
						verify_interval = settings.verification_interval
					else
						verify_interval = settings.notice_interval or settings.verification_interval
					end

					attention_info.next_verify_t = t + verify_interval
					update_delay = math_min(update_delay, verify_interval)

					if not attention_info.identified then
						local noticable, distance = nil

						if attention_info.visible_in_this_instance then
							noticable = true
							distance = attention_info.visible_dis_multiplier
						else
							local attention_pos = attention_info.m_head_pos
							local dis_sq = mvec3_dist_sq(my_pos, attention_pos)
							local max_dis = max_detection_range

							if settings.max_range then
								max_dis = math_min(max_dis, settings.max_range)
							end

							if settings.detection and settings.detection.range_mul then
								max_dis = max_dis * settings.detection.range_mul
							end

							local max_dis_sq = max_dis * max_dis

							if dis_sq < max_dis_sq then
								distance = math_sqrt(dis_sq)

								local vis_ray = attention_info.visible_ray

								if not vis_ray then
									if parent_unit then
										vis_ray = self._unit:raycast("ray", my_pos, attention_pos, "slot_mask", vis_mask, "ignore_unit", parent_unit, "ray_type", "ai_vision")
									else
										vis_ray = self._unit:raycast("ray", my_pos, attention_pos, "slot_mask", vis_mask, "ray_type", "ai_vision")
									end
								end

								if not vis_ray or vis_ray.unit:key() == u_key then
									noticable = true
									attention_info.visible_in_this_instance = true
								end

								if not attention_info.visible_ray then
									attention_info.visible_ray = vis_ray
								end
							end
						end

						local delta_prog = nil
						local dt = t - attention_info.prev_notice_chk_t

						if noticable then
							local min_delay = detection_preset[1][2]
							local max_delay = detection_preset[2][2]
							local dis_mul_mod = math_clamp((distance - detection_preset[1][1]) / (detection_preset[2][1] - detection_preset[1][1]), 0, 1)
							local notice_delay_mul = settings.notice_delay_mul or 1

							if settings.detection and settings.detection.delay_mul then
								notice_delay_mul = notice_delay_mul * settings.detection.delay_mul
							end

							local notice_delay_modified = math_lerp(min_delay * notice_delay_mul, max_delay, dis_mul_mod)
							delta_prog = notice_delay_modified > 0 and dt / notice_delay_modified or 1
						else
							delta_prog = dt * -0.125
						end

						attention_info.notice_progress = attention_info.notice_progress + delta_prog

						if attention_info.notice_progress > 1 then
							attention_info.notice_progress = nil
							attention_info.prev_notice_chk_t = nil
							attention_info.identified = true
							attention_info.release_t = t + settings.release_delay
							attention_info.identified_t = t
							noticable = true

						elseif attention_info.notice_progress < 0 then
							self:_destroy_detected_attention_object_data(attention_info)

							noticable = false
						else
							noticable = attention_info.notice_progress
							attention_info.prev_notice_chk_t = t
						end

						if noticable ~= false and settings.notice_clbk and settings.notice_clbk ~= "clbk_notice_sneak" then
							settings.notice_clbk(self._unit, noticable)
						end
					end

					if attention_info.identified then
						attention_info.next_verify_t = t + settings.verification_interval
						update_delay = math_min(update_delay, settings.verification_interval)
						attention_info.nearly_visible = nil

						local verified, vis_ray = nil
						local attention_pos = attention_info.m_head_pos
						local dis = mvec3_dis(my_pos, attention_pos)
						local max_dis = max_detection_range

						if dis < max_dis * 1.2 then
							if settings.max_range then
								max_dis = math_min(max_dis, settings.max_range)
							end

							if settings.detection and settings.detection.range_mul then
								max_dis = max_dis * settings.detection.range_mul
							end

							if dis < max_dis * 1.2 then
								if attention_info.visible_in_this_instance then
									verified = true
									vis_ray = attention_info.visible_ray
								else
									vis_ray = attention_info.visible_ray

									if not vis_ray then
										if parent_unit then
											vis_ray = self._unit:raycast("ray", my_pos, attention_pos, "slot_mask", vis_mask, "ignore_unit", parent_unit, "ray_type", "ai_vision")
										else
											vis_ray = self._unit:raycast("ray", my_pos, attention_pos, "slot_mask", vis_mask, "ray_type", "ai_vision")
										end
									end

									if not vis_ray or vis_ray.unit:key() == u_key then
										verified = true
									end
								end
							end
						end

						attention_info.verified = verified
						attention_info.dis = dis
						attention_info.vis_ray = vis_ray

						if verified and dis < firing_range then
							attention_info.release_t = nil
							attention_info.verified_t = t
							attention_info.verified_dis = dis

							mvec3_set(attention_info.verified_pos, attention_pos)

							if attention_info.last_verified_pos then
								mvec3_set(attention_info.last_verified_pos, attention_pos)
							else
								attention_info.last_verified_pos = mvec3_cpy(attention_pos)
							end
						elseif attention_info.has_team and my_team.foes[att_mov_ext:team().id] and REACT_COMBAT <= settings.reaction then
							local destroyed_att_data = nil

							if attention_info.criminal_record then
								if dis > 1000 and attention_info.release_t and attention_info.release_t < t then
									self:_destroy_detected_attention_object_data(attention_info)

									destroyed_att_data = true
								else
									update_delay = math_min(0.2, update_delay)
									attention_info.next_verify_t = math_min(0.2, attention_info.next_verify_t)

									mvec3_set(attention_info.verified_pos, attention_pos)
									attention_info.verified_dis = dis
								end
							elseif attention_info.release_t and attention_info.release_t < t then
								self:_destroy_detected_attention_object_data(attention_info)

								destroyed_att_data = true
							else
								attention_info.release_t = attention_info.release_t or t + settings.release_delay
							end

							if not destroyed_att_data then
								if vis_ray and attention_info.is_person and attention_info.verified_t and dis < 2000 then
									local required_last_seen_t = attention_info.criminal_record and 3 or settings.release_delay

									if t - attention_info.verified_t < required_last_seen_t or attention_info.nearly_visible_t and t - attention_info.nearly_visible_t < required_last_seen_t then
										local ignore_units = nil

										if parent_unit then
											ignore_units = {
												attention_info.unit,
												parent_unit
											}
										else
											ignore_units = attention_info.unit
										end

										local pos_chk = tmp_vec3

										if attention_info.unit:movement() and attention_info.unit:movement().m_com then
											mvec3_set(pos_chk, attention_info.unit:movement():m_com())
										else
											mvec3_set(pos_chk, attention_pos)
										end

										if self:is_target_on_sight(my_pos, pos_chk, ignore_units) then
											attention_info.nearly_visible = true
											attention_info.nearly_visible_t = t
											attention_info.release_t = nil

											if attention_info.last_verified_pos then
												mvec3_set(attention_info.last_verified_pos, attention_pos)
											else
												attention_info.last_verified_pos = mvec3_cpy(attention_pos)
											end
										end
									end
								end

								if attention_info.criminal_record and not attention_info.nearly_visible then
									attention_info.release_t = attention_info.release_t or t + 3
								end
							end
						elseif attention_info.release_t and attention_info.release_t < t then
							self:_destroy_detected_attention_object_data(attention_info)
						else
							attention_info.release_t = attention_info.release_t or t + settings.release_delay
						end
					end
				end
			end

			attention_info.visible_in_this_instance = nil
			attention_info.visible_angle = nil
			attention_info.visible_dis_multiplier = nil
			attention_info.visible_ray = nil
		end

		self._next_detection_upd_t = t + update_delay
	end

	function SentryGunBrain:_select_focus_attention(t)
		local td = self:_get_tweak_data()
		local DETECTION_RANGE = td.DETECTION_RANGE
		local firemode = self._unit:weapon():_get_sentry_firemode()

		if firemode == "overwatch" then 
			DETECTION_RANGE = SentryControlMenu.tweakdata.OVERWATCH_DETECTION_RANGE
		end

		local current_focus = self._attention_obj
		local current_pos = self._ext_movement:m_head_pos()
		local current_fwd = nil

		if current_focus then
			current_fwd = tmp_vec2

			mvec3_dir(current_fwd, current_pos, current_focus.m_head_pos)
		else
			current_fwd = self._ext_movement:m_head_fwd()
		end

		local best_focus_attention, best_focus_weight = nil
		local best_focus_reaction = 0
		local health_ratio_chk_func = self._attention_health_ratio
		local objective_chk_func = self._attention_objective

		for u_key, attention_info in pairs(self._detected_attention_objects) do
			if best_focus_reaction < attention_info.reaction or best_focus_reaction == attention_info.reaction then
				local remove_obj = nil
				local att_mov_ext = attention_info.unit:movement()

				if not attention_info.is_alive then
					remove_obj = true
				else
					if firemode == "overwatch" then
						local att_base_ext = attention_info.unit:base()
						--if overwatch firemode, targeted enemy must be a sniper in order to notice them
						if att_base_ext and att_base_ext.has_tag then 
							if target_any_specials then
								--or, must be any special enemy, with the relevant upgrade
								if not att_base_ext:has_tag("special") then 
									skip = true
								end
							elseif not att_base_ext:has_tag("sniper") then
								skip = true
							end
						else
							skip = true
						end
					end

					if not remove_obj and att_mov_ext then
						if att_mov_ext.downed and att_mov_ext:downed() then
							remove_obj = true
						elseif att_mov_ext.is_cuffed and att_mov_ext:is_cuffed() then
							remove_obj = true
						end
					end

					if not remove_obj then
						if health_ratio_chk_func(self, attention_info) <= 0 or objective_chk_func(self, attention_info) == "surrender" then
							remove_obj = true
						else
							local att_brain_ext = attention_info.unit:brain()

							if att_brain_ext and att_brain_ext.surrendered and att_brain_ext:surrendered() then
								remove_obj = true
							end
						end
					end
				end

				if remove_obj then
					self:_destroy_detected_attention_object_data(attention_info)
				elseif attention_info.identified then
					local weight = 1

					if not attention_info.verified then
						if attention_info.verified_t and t - attention_info.verified_t < 3 then
							if not attention_info.nearly_visible then
								weight = weight * 0.01
							end

							local max_duration = 3
							local elapsed_t = t - attention_info.verified_t
							weight = weight * math_lerp(1, 0.6, elapsed_t / max_duration)
						else
							weight = 0
						end
					end

					if weight > 0 then
						if attention_info.dmg_t and t - attention_info.dmg_t < 5 then
							local max_duration = 5
							local elapsed_t = t - attention_info.dmg_t
							weight = weight * math_lerp(1.2, 1, elapsed_t / max_duration)
						end

						local max_dis = DETECTION_RANGE
						local dis = mvec3_dir(tmp_vec1, current_pos, attention_info.m_head_pos)
						local dis_weight = math_max(0, (max_dis - dis) / max_dis)
						weight = weight * dis_weight

						if weight > 0 then
							local dot_weight = 1 + mvec3_dot(tmp_vec1, current_fwd)
							dot_weight = dot_weight * dot_weight * dot_weight
							weight = weight * dot_weight

							if REACT_SHOOT > attention_info.reaction then
								weight = weight * 0.001
							elseif attention_info.verified or attention_info.nearly_visible then
								if not self:_ignore_shield(current_pos, attention_info.m_head_pos) then
									weight = weight * 0.01
								elseif attention_info.verified then
									if attention_info.settings.weight_mul then
										weight = weight * attention_info.settings.weight_mul
									end

									if attention_info.is_local_player then
										local att_cur_state = att_mov_ext:current_state()

										if not att_cur_state._moving and att_cur_state:ducking() then
											weight = weight * managers.player:upgrade_value("player", "stand_still_crouch_camouflage_bonus", 1)
										end

										if managers.player:has_activate_temporary_upgrade("temporary", "chico_injector") and managers.player:upgrade_value("player", "chico_preferred_target", false) then
											weight = weight * 1000
										end

										if is_local_vr then
											local distance = attention_info.dis
											local vr_long_range_dmg_reduction = tweak_data.vr.long_range_damage_reduction_distance

											if vr_long_range_dmg_reduction[1] < distance then
												local mul = math_clamp(distance / vr_long_range_dmg_reduction[2] / 2, 0, 1) + 1
												weight = weight * mul
											end
										end
									elseif attention_info.is_husk_player then
										local att_base_ext = attention_info.unit:base()

										if att_base_ext.upgrade_value then
											if att_mov_ext and not att_mov_ext._move_data and att_mov_ext._pose_code and att_mov_ext._pose_code == 2 then
												local crouch_and_still_weight_mul = att_base_ext:upgrade_value("player", "stand_still_crouch_camouflage_bonus")

												if crouch_and_still_weight_mul then
													weight = weight * crouch_and_still_weight_mul
												end
											end

											if att_base_ext.has_activate_temporary_upgrade and att_base_ext:has_activate_temporary_upgrade("temporary", "chico_injector") and att_base_ext:upgrade_value("player", "chico_preferred_target") then
												weight = weight * 1000
											end

											if att_mov_ext.is_vr and att_mov_ext:is_vr() then
												local distance = attention_info.dis
												local vr_long_range_dmg_reduction = tweak_data.vr.long_range_damage_reduction_distance

												if vr_long_range_dmg_reduction[1] < distance then
													local mul = math_clamp(distance / vr_long_range_dmg_reduction[2] / 2, 0, 1) + 1
													weight = weight * mul
												end
											end
										end
									end
								end
							end
						end
					end

					if not best_focus_weight or best_focus_weight < weight then
						best_focus_weight = weight
						best_focus_attention = attention_info
						best_focus_reaction = attention_info.reaction
					end
				end
			end
		end

		if current_focus ~= best_focus_attention then
			if best_focus_attention then
				local attention_data = {
					unit = best_focus_attention.unit,
					u_key = best_focus_attention.u_key,
					handler = best_focus_attention.handler,
					reaction = best_focus_attention.reaction
				}

				self._ext_movement:set_attention(attention_data)
			else
				self._ext_movement:set_attention()
			end

			self._attention_obj = best_focus_attention
		end
	end

	function SentryGunBrain:is_target_on_sight(my_pos, target_base_pos, units_to_ignore)
		if not target_base_pos then
			return false
		end

		local td = self:_get_tweak_data()
		local fire_range = td.FIRE_RANGE
		local fire_range_sq = fire_range * fire_range

		local sentrygun_weapon = self._unit:weapon()
		local firemode = sentrygun_weapon:_get_sentry_firemode()

		if firemode ~= "overwatch" then 
			fire_range_sq = fire_range_sq * 4
			--not used for manual mode
			if fire_range_sq < mvec3_dist_sq(my_pos, target_base_pos) then
				return false
			end
		end

		local target_pos_same_height = mvec3_cpy(target_base_pos)

		mvec3_set_z(target_pos_same_height, mvec3_z(my_pos))

		local dir_to_target = mvec3_cpy(my_pos)

		mvec3_sub(dir_to_target, target_pos_same_height)
		mvec3_norm(dir_to_target)

		local right_offset = Vector3()

		mvec3_cross(right_offset, dir_to_target, math_up)

		local left_offset = mvec3_cpy(right_offset)

		mvec3_mul(right_offset, self.attention_target_offset_hor)
		mvec3_mul(left_offset, -self.attention_target_offset_hor)
		mvec3_set_z(right_offset, mvec3_z(right_offset) + self.attention_target_offset_ver)
		mvec3_set_z(left_offset, mvec3_z(left_offset) + self.attention_target_offset_ver)

		local offsets = {
			Vector3(0, 0, 0),
			right_offset,
			left_offset
		}
		local target_pos = Vector3()
		local attention, ignore_units = nil

		if units_to_ignore then
			ignore_units = units_to_ignore
		end

		for i, offset in ipairs(offsets) do
			mvec3_set(target_pos, target_base_pos)
			mvec3_add(target_pos, offset)

			local vis_ray = nil

			if ignore_units then
				vis_ray = self._unit:raycast("ray", my_pos, target_pos, "slot_mask", self._visibility_slotmask, "ignore_unit", ignore_units, "ray_type", "ai_vision", "report")
			else
				vis_ray = self._unit:raycast("ray", my_pos, target_pos, "slot_mask", self._visibility_slotmask, "ray_type", "ai_vision", "report")
			end

			if not vis_ray then
				return true
			end
		end

		return false
	end

	function SentryGunBrain:_ignore_shield(my_pos, target_pos)
		local ammo_type = self._unit:weapon():_get_ammo_type()

		if ammo_type == "ap" or ammo_type == "he" then
			return true
		end

		local hit_shield = self._unit:raycast("ray", my_pos, target_pos, "slot_mask", self._shield_check, "report")

		if hit_shield then
			return false
		end

		return true
	end


else	

	function SentryGunBrain:_upd_detection(t)
		if self._ext_movement:is_activating() or self._ext_movement:is_inactivating() then
			return
		end

		if t < self._next_detection_upd_t then
			return
		end

		local my_SO_access_str = self._SO_access_str
		local my_SO_access = self._SO_access
		local detected_objects = self._detected_attention_objects
		local my_key = self._unit:key()
		local my_team = self._ext_movement:team()
		local my_pos = self._ext_movement:m_head_pos()
		local my_tracker = self._ext_movement:nav_tracker()
		local chk_vis_func = my_tracker.check_visibility
		local firing_range = self._tweak_data.FIRE_RANGE
		local max_detection_range = self._tweak_data.DETECTION_RANGE
		local detection_preset = self._tweak_data.DETECTION_DELAY
		local vis_mask = self._visibility_slotmask
		local all_attention_objects = managers.groupai:state():get_AI_attention_objects_by_filter(my_SO_access_str, my_team)
		local parent_unit = alive(self._unit:parent()) and self._unit:parent()

		for u_key, attention_info in pairs(all_attention_objects) do
			if u_key ~= my_key and not detected_objects[u_key] then
				local skip = nil
				local att_unit = attention_info.unit
				local att_mov_ext = att_unit:movement()

				if att_mov_ext then
					if att_mov_ext.downed and att_mov_ext:downed() then
						skip = true
					elseif att_mov_ext.is_cuffed and att_mov_ext:is_cuffed() then
						skip = true
					end
				end

				if not skip then
					local att_dmg_ext = att_unit:character_damage()

					if att_dmg_ext then
						if att_dmg_ext.dead and att_dmg_ext:dead() or att_dmg_ext.health_ratio and att_dmg_ext:health_ratio() <= 0 then
							skip = true
						end
					end

					if not skip then
						local att_brain_ext = att_unit:brain()

						if att_brain_ext then
							if att_brain_ext.objective and att_brain_ext:objective() == "surrender" or att_brain_ext.surrendered and att_brain_ext:surrendered() then
								skip = true
							end
						end
					end
				end

				if not skip then
					if not attention_info.nav_tracker or chk_vis_func(my_tracker, attention_info.nav_tracker) then
						local settings = attention_info.handler:get_attention(my_SO_access, REACT_SUSPICIOUS, nil, my_team)

						if settings then
							local distance = nil
							local attention_pos = attention_info.handler:get_detection_m_pos()
							local dis_sq = mvec3_dist_sq(my_pos, attention_pos)
							local max_dis = max_detection_range

							if settings.max_range then
								max_dis = math_min(max_dis, settings.max_range)
							end

							if settings.detection and settings.detection.range_mul then
								max_dis = max_dis * settings.detection.range_mul
							end

							local max_dis_sq = max_dis * max_dis

							if dis_sq < max_dis_sq then
								distance = math_sqrt(dis_sq)

								local vis_ray = nil

								if parent_unit then
									vis_ray = self._unit:raycast("ray", my_pos, attention_pos, "slot_mask", vis_mask, "ignore_unit", parent_unit, "ray_type", "ai_vision")
								else
									vis_ray = self._unit:raycast("ray", my_pos, attention_pos, "slot_mask", vis_mask, "ray_type", "ai_vision")
								end

								if not vis_ray or vis_ray.unit:key() == u_key then
									local visible_data = {
										visible_dis_multiplier = distance,
										visible_ray = vis_ray
									}

									detected_objects[u_key] = CopLogicBase._create_detected_attention_object_data(t, self._unit, u_key, attention_info, settings, nil, visible_data)
								end
							end
						end
					end
				end
			end
		end

		local update_delay = 2
		local health_ratio_chk_func = self._attention_health_ratio
		local objective_chk_func = self._attention_objective

		for u_key, attention_info in pairs(detected_objects) do
			if not attention_info.visible_in_this_instance and t < attention_info.next_verify_t then
				update_delay = math_min(attention_info.next_verify_t - t, update_delay)
			else
				local att_mov_ext = attention_info.unit:movement()
				local skip = nil

				if not attention_info.is_alive then
					skip = true
				else
					if att_mov_ext then
						if att_mov_ext.downed and att_mov_ext:downed() then
							skip = true
						elseif att_mov_ext.is_cuffed and att_mov_ext:is_cuffed() then
							skip = true
						end
					end

					if not skip then
						if health_ratio_chk_func(self, attention_info) <= 0 or objective_chk_func(self, attention_info) == "surrender" then
							skip = true
						else
							local att_brain_ext = attention_info.unit:brain()

							if att_brain_ext and att_brain_ext.surrendered and att_brain_ext:surrendered() then
								skip = true
							end
						end
					end
				end

				if skip then
					self:_destroy_detected_attention_object_data(attention_info)
				else
					local settings = attention_info.settings
					local verify_interval = nil

					if attention_info.identified and attention_info.verified then
						verify_interval = settings.verification_interval
					else
						verify_interval = settings.notice_interval or settings.verification_interval
					end

					attention_info.next_verify_t = t + verify_interval
					update_delay = math_min(update_delay, verify_interval)

					if not attention_info.identified then
						local noticable, distance = nil

						if attention_info.visible_in_this_instance then
							noticable = true
							distance = attention_info.visible_dis_multiplier
						else
							local attention_pos = attention_info.m_head_pos
							local dis_sq = mvec3_dist_sq(my_pos, attention_pos)
							local max_dis = max_detection_range

							if settings.max_range then
								max_dis = math_min(max_dis, settings.max_range)
							end

							if settings.detection and settings.detection.range_mul then
								max_dis = max_dis * settings.detection.range_mul
							end

							local max_dis_sq = max_dis * max_dis

							if dis_sq < max_dis_sq then
								distance = math_sqrt(dis_sq)

								local vis_ray = attention_info.visible_ray

								if not vis_ray then
									if parent_unit then
										vis_ray = self._unit:raycast("ray", my_pos, attention_pos, "slot_mask", vis_mask, "ignore_unit", parent_unit, "ray_type", "ai_vision")
									else
										vis_ray = self._unit:raycast("ray", my_pos, attention_pos, "slot_mask", vis_mask, "ray_type", "ai_vision")
									end
								end

								if not vis_ray or vis_ray.unit:key() == u_key then
									noticable = true
									attention_info.visible_in_this_instance = true
								end

								if not attention_info.visible_ray then
									attention_info.visible_ray = vis_ray
								end
							end
						end

						local delta_prog = nil
						local dt = t - attention_info.prev_notice_chk_t

						if noticable then
							local min_delay = detection_preset[1][2]
							local max_delay = detection_preset[2][2]
							local dis_mul_mod = math_clamp((distance - detection_preset[1][1]) / (detection_preset[2][1] - detection_preset[1][1]), 0, 1)
							local notice_delay_mul = settings.notice_delay_mul or 1

							if settings.detection and settings.detection.delay_mul then
								notice_delay_mul = notice_delay_mul * settings.detection.delay_mul
							end

							local notice_delay_modified = math_lerp(min_delay * notice_delay_mul, max_delay, dis_mul_mod)
							delta_prog = notice_delay_modified > 0 and dt / notice_delay_modified or 1
						else
							delta_prog = dt * -0.125
						end

						attention_info.notice_progress = attention_info.notice_progress + delta_prog

						if attention_info.notice_progress > 1 then
							attention_info.notice_progress = nil
							attention_info.prev_notice_chk_t = nil
							attention_info.identified = true
							attention_info.release_t = t + settings.release_delay
							attention_info.identified_t = t
							noticable = true

						elseif attention_info.notice_progress < 0 then
							self:_destroy_detected_attention_object_data(attention_info)

							noticable = false
						else
							noticable = attention_info.notice_progress
							attention_info.prev_notice_chk_t = t
						end

						if noticable ~= false and settings.notice_clbk and settings.notice_clbk ~= "clbk_notice_sneak" then
							settings.notice_clbk(self._unit, noticable)
						end
					end

					if attention_info.identified then
						attention_info.next_verify_t = t + settings.verification_interval
						update_delay = math_min(update_delay, settings.verification_interval)
						attention_info.nearly_visible = nil

						local verified, vis_ray = nil
						local attention_pos = attention_info.m_head_pos
						local dis = mvec3_dis(my_pos, attention_pos)
						local max_dis = max_detection_range

						if dis < max_dis * 1.2 then
							if settings.max_range then
								max_dis = math_min(max_dis, settings.max_range)
							end

							if settings.detection and settings.detection.range_mul then
								max_dis = max_dis * settings.detection.range_mul
							end

							if dis < max_dis * 1.2 then
								if attention_info.visible_in_this_instance then
									verified = true
									vis_ray = attention_info.visible_ray
								else
									vis_ray = attention_info.visible_ray

									if not vis_ray then
										if parent_unit then
											vis_ray = self._unit:raycast("ray", my_pos, attention_pos, "slot_mask", vis_mask, "ignore_unit", parent_unit, "ray_type", "ai_vision")
										else
											vis_ray = self._unit:raycast("ray", my_pos, attention_pos, "slot_mask", vis_mask, "ray_type", "ai_vision")
										end
									end

									if not vis_ray or vis_ray.unit:key() == u_key then
										verified = true
									end
								end
							end
						end

						attention_info.verified = verified
						attention_info.dis = dis
						attention_info.vis_ray = vis_ray

						if verified and dis < firing_range then
							attention_info.release_t = nil
							attention_info.verified_t = t
							attention_info.verified_dis = dis

							mvec3_set(attention_info.verified_pos, attention_pos)

							if attention_info.last_verified_pos then
								mvec3_set(attention_info.last_verified_pos, attention_pos)
							else
								attention_info.last_verified_pos = mvec3_cpy(attention_pos)
							end
						elseif attention_info.has_team and my_team.foes[att_mov_ext:team().id] and REACT_COMBAT <= settings.reaction then
							local destroyed_att_data = nil

							if attention_info.criminal_record then
								if dis > 1000 and attention_info.release_t and attention_info.release_t < t then
									self:_destroy_detected_attention_object_data(attention_info)

									destroyed_att_data = true
								else
									update_delay = math_min(0.2, update_delay)
									attention_info.next_verify_t = math_min(0.2, attention_info.next_verify_t)

									mvec3_set(attention_info.verified_pos, attention_pos)
									attention_info.verified_dis = dis
								end
							elseif attention_info.release_t and attention_info.release_t < t then
								self:_destroy_detected_attention_object_data(attention_info)

								destroyed_att_data = true
							else
								attention_info.release_t = attention_info.release_t or t + settings.release_delay
							end

							if not destroyed_att_data then
								if vis_ray and attention_info.is_person and attention_info.verified_t and dis < 2000 then
									local required_last_seen_t = attention_info.criminal_record and 3 or settings.release_delay

									if t - attention_info.verified_t < required_last_seen_t or attention_info.nearly_visible_t and t - attention_info.nearly_visible_t < required_last_seen_t then
										local ignore_units = nil

										if parent_unit then
											ignore_units = {
												attention_info.unit,
												parent_unit
											}
										else
											ignore_units = attention_info.unit
										end

										local pos_chk = tmp_vec3

										if attention_info.unit:movement() and attention_info.unit:movement().m_com then
											mvec3_set(pos_chk, attention_info.unit:movement():m_com())
										else
											mvec3_set(pos_chk, attention_pos)
										end

										if self:is_target_on_sight(my_pos, pos_chk, ignore_units) then
											attention_info.nearly_visible = true
											attention_info.nearly_visible_t = t
											attention_info.release_t = nil

											if attention_info.last_verified_pos then
												mvec3_set(attention_info.last_verified_pos, attention_pos)
											else
												attention_info.last_verified_pos = mvec3_cpy(attention_pos)
											end
										end
									end
								end

								if attention_info.criminal_record and not attention_info.nearly_visible then
									attention_info.release_t = attention_info.release_t or t + 3
								end
							end
						elseif attention_info.release_t and attention_info.release_t < t then
							self:_destroy_detected_attention_object_data(attention_info)
						else
							attention_info.release_t = attention_info.release_t or t + settings.release_delay
						end
					end
				end
			end

			attention_info.visible_in_this_instance = nil
			attention_info.visible_angle = nil
			attention_info.visible_dis_multiplier = nil
			attention_info.visible_ray = nil
		end

		self._next_detection_upd_t = t + update_delay
	end

	function SentryGunBrain:_select_focus_attention(t)
		local current_focus = self._attention_obj
		local current_pos = self._ext_movement:m_head_pos()
		local current_fwd = nil

		if current_focus then
			current_fwd = tmp_vec2

			mvec3_dir(current_fwd, current_pos, current_focus.m_head_pos)
		else
			current_fwd = self._ext_movement:m_head_fwd()
		end

		local best_focus_attention, best_focus_weight = nil
		local best_focus_reaction = 0
		local health_ratio_chk_func = self._attention_health_ratio
		local objective_chk_func = self._attention_objective

		for u_key, attention_info in pairs(self._detected_attention_objects) do
			if best_focus_reaction < attention_info.reaction or best_focus_reaction == attention_info.reaction then
				local remove_obj = nil
				local att_mov_ext = attention_info.unit:movement()

				if not attention_info.is_alive then
					remove_obj = true
				else
					if att_mov_ext then
						if att_mov_ext.downed and att_mov_ext:downed() then
							remove_obj = true
						elseif att_mov_ext.is_cuffed and att_mov_ext:is_cuffed() then
							remove_obj = true
						end
					end

					if not remove_obj then
						if health_ratio_chk_func(self, attention_info) <= 0 or objective_chk_func(self, attention_info) == "surrender" then
							remove_obj = true
						else
							local att_brain_ext = attention_info.unit:brain()

							if att_brain_ext and att_brain_ext.surrendered and att_brain_ext:surrendered() then
								remove_obj = true
							end
						end
					end
				end

				if remove_obj then
					self:_destroy_detected_attention_object_data(attention_info)
				elseif attention_info.identified then
					local weight = 1

					if not attention_info.verified then
						if attention_info.verified_t and t - attention_info.verified_t < 3 then
							if not attention_info.nearly_visible then
								weight = weight * 0.01
							end

							local max_duration = 3
							local elapsed_t = t - attention_info.verified_t
							weight = weight * math_lerp(1, 0.6, elapsed_t / max_duration)
						else
							weight = 0
						end
					end

					if weight > 0 then
						if attention_info.dmg_t and t - attention_info.dmg_t < 5 then
							local max_duration = 5
							local elapsed_t = t - attention_info.dmg_t
							weight = weight * math_lerp(1.2, 1, elapsed_t / max_duration)
						end

						local max_dis = self._tweak_data.DETECTION_RANGE
						local dis = mvec3_dir(tmp_vec1, current_pos, attention_info.m_head_pos)
						local dis_weight = math_max(0, (max_dis - dis) / max_dis)
						weight = weight * dis_weight

						if weight > 0 then
							local dot_weight = 1 + mvec3_dot(tmp_vec1, current_fwd)
							dot_weight = dot_weight * dot_weight * dot_weight
							weight = weight * dot_weight

							if REACT_SHOOT > attention_info.reaction then
								weight = weight * 0.001
							elseif attention_info.verified or attention_info.nearly_visible then
								if not self:_ignore_shield(current_pos, attention_info.m_head_pos) then
									weight = weight * 0.01
								elseif attention_info.verified then
									if attention_info.settings.weight_mul then
										weight = weight * attention_info.settings.weight_mul
									end

									if attention_info.is_local_player then
										local att_cur_state = att_mov_ext:current_state()

										if not att_cur_state._moving and att_cur_state:ducking() then
											weight = weight * managers.player:upgrade_value("player", "stand_still_crouch_camouflage_bonus", 1)
										end

										if managers.player:has_activate_temporary_upgrade("temporary", "chico_injector") and managers.player:upgrade_value("player", "chico_preferred_target", false) then
											weight = weight * 1000
										end

										if is_local_vr then
											local distance = attention_info.dis
											local vr_long_range_dmg_reduction = tweak_data.vr.long_range_damage_reduction_distance

											if vr_long_range_dmg_reduction[1] < distance then
												local mul = math_clamp(distance / vr_long_range_dmg_reduction[2] / 2, 0, 1) + 1
												weight = weight * mul
											end
										end
									elseif attention_info.is_husk_player then
										local att_base_ext = attention_info.unit:base()

										if att_base_ext.upgrade_value then
											if att_mov_ext and not att_mov_ext._move_data and att_mov_ext._pose_code and att_mov_ext._pose_code == 2 then
												local crouch_and_still_weight_mul = att_base_ext:upgrade_value("player", "stand_still_crouch_camouflage_bonus")

												if crouch_and_still_weight_mul then
													weight = weight * crouch_and_still_weight_mul
												end
											end

											if att_base_ext.has_activate_temporary_upgrade and att_base_ext:has_activate_temporary_upgrade("temporary", "chico_injector") and att_base_ext:upgrade_value("player", "chico_preferred_target") then
												weight = weight * 1000
											end

											if att_mov_ext.is_vr and att_mov_ext:is_vr() then
												local distance = attention_info.dis
												local vr_long_range_dmg_reduction = tweak_data.vr.long_range_damage_reduction_distance

												if vr_long_range_dmg_reduction[1] < distance then
													local mul = math_clamp(distance / vr_long_range_dmg_reduction[2] / 2, 0, 1) + 1
													weight = weight * mul
												end
											end
										end
									end
								end
							end
						end
					end

					if not best_focus_weight or best_focus_weight < weight then
						best_focus_weight = weight
						best_focus_attention = attention_info
						best_focus_reaction = attention_info.reaction
					end
				end
			end
		end

		if current_focus ~= best_focus_attention then
			if best_focus_attention then
				local attention_data = {
					unit = best_focus_attention.unit,
					u_key = best_focus_attention.u_key,
					handler = best_focus_attention.handler,
					reaction = best_focus_attention.reaction
				}

				self._ext_movement:set_attention(attention_data)
			else
				self._ext_movement:set_attention()
			end

			self._attention_obj = best_focus_attention
		end
	end

	function SentryGunBrain:is_target_on_sight(my_pos, target_base_pos, units_to_ignore)
		if not target_base_pos then
			return false
		end

		local fire_range_sq = self._tweak_data.FIRE_RANGE * self._tweak_data.FIRE_RANGE

		if fire_range_sq < mvec3_dist_sq(my_pos, target_base_pos) then
			return false
		end

		local target_pos_same_height = mvec3_cpy(target_base_pos)

		mvec3_set_z(target_pos_same_height, mvec3_z(my_pos))

		local dir_to_target = mvec3_cpy(my_pos)

		mvec3_sub(dir_to_target, target_pos_same_height)
		mvec3_norm(dir_to_target)

		local right_offset = Vector3()

		mvec3_cross(right_offset, dir_to_target, math_up)

		local left_offset = mvec3_cpy(right_offset)

		mvec3_mul(right_offset, self.attention_target_offset_hor)
		mvec3_mul(left_offset, -self.attention_target_offset_hor)
		mvec3_set_z(right_offset, mvec3_z(right_offset) + self.attention_target_offset_ver)
		mvec3_set_z(left_offset, mvec3_z(left_offset) + self.attention_target_offset_ver)

		local offsets = {
			Vector3(0, 0, 0),
			right_offset,
			left_offset
		}
		local target_pos = Vector3()
		local attention, ignore_units = nil

		if units_to_ignore then
			ignore_units = units_to_ignore
		end

		for i, offset in ipairs(offsets) do
			mvec3_set(target_pos, target_base_pos)
			mvec3_add(target_pos, offset)

			local vis_ray = nil

			if ignore_units then
				vis_ray = self._unit:raycast("ray", my_pos, target_pos, "slot_mask", self._visibility_slotmask, "ignore_unit", ignore_units, "ray_type", "ai_vision", "report")
			else
				vis_ray = self._unit:raycast("ray", my_pos, target_pos, "slot_mask", self._visibility_slotmask, "ray_type", "ai_vision", "report")
			end

			if not vis_ray then
				return true
			end
		end

		return false
	end

	function SentryGunBrain:_ignore_shield(my_pos, target_pos)
		if self._ap_bullets then
			return true
		end

		local hit_shield = self._unit:raycast("ray", my_pos, target_pos, "slot_mask", self._shield_check, "report")

		if hit_shield then
			return false
		end

		return true
	end
end
