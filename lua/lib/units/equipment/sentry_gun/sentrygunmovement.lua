local mvec3_dir = mvector3.direction
local mvec3_dist_sq = mvector3.distance_sq
local mvec3_dot = mvector3.dot
local mvec3_cross = mvector3.cross
local mvec3_sub = mvector3.subtract
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local math_max = math.max
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()

function SentryGunMovement:_update_rearming(t, dt)
	self:_upd_hacking(t, dt)

	if self._rearm_complete_t and self._rearm_complete_t < t then
		self:complete_rearming()
	end
end

function SentryGunMovement:_update_repairing(t, dt)
	self:_upd_hacking(t, dt)

	if self._repair_complete_t then
		local repair_complete_ratio = 1 - (self._repair_complete_t - t) / self._tweak.AUTO_REPAIR_DURATION

		self._unit:character_damage():update_shield_smoke_level(repair_complete_ratio, true)

		if self._repair_complete_t < t then
			self:complete_repairing()
		end
	end
end

if deathvox:IsTotalCrackdownEnabled() then 

	Hooks:PostHook(SentryGunMovement,"init","tcdso_sentry_movement_init",function(self,unit)
		self._sync_target_pos = (unit:position() or Vector3()) + (self._unit_fwd * 100)
		self._upd_sync_aim_t = math.random() * SentryControlMenu.tweakdata._SYNC_AIM_INTERVAL
	end)

	local orig_get_target = SentryGunMovement._get_target_dir
	function SentryGunMovement:_get_target_dir(attention, dt,...)
		if not self._unit:base()._owner_id then
			return orig_get_target(self,attention,dt,...)
		elseif not self._unit:base():is_owner() then 
			if self._sync_target_pos then 
				return self._sync_target_pos
			end
		end
		
		local weapon = self._unit:weapon()
		local firemode = weapon:_get_sentry_firemode()
		local ammotype = weapon:_get_ammo_type()
		local player = managers.player:local_player()
		
		local target_pos = tmp_vec1
		
		if firemode == "manual" then
			local fwd_ray = player and player:movement():current_state()._fwd_ray
			if fwd_ray and fwd_ray.position then 
				if fwd_ray.unit == self._unit then 
					target_pos = player:movement():m_head_pos()
					--WHAT'RE YOU LOOKING AT, PUNK
				else
					target_pos = fwd_ray.position
				end
				self._m_last_attention_pos = self._m_last_attention_pos or Vector3()
				mvector3.set(self._m_last_attention_pos,target_pos)
				self._m_last_attention_vel = self._m_last_attention_vel or Vector3()
			elseif player then 
				target_pos = player:movement():m_head_pos() + (player:movement():m_head_rot():y() * 10000)
			elseif self._m_last_attention_pos then
				target_pos = self._m_last_attention_pos
			else
				return orig_get_target(self,attention,dt,...)
			end
			
		else
			self._m_last_attention_pos = nil
			self._m_last_attention_vel = nil
			return orig_get_target(self,attention,dt,...)
		end	
		
		
		
		if self._switched_off then
			mvector3.set(tmp_vec2, self._unit_fwd)
			mvector3.rotate_with(tmp_vec2, self._switch_off_rot)

			return tmp_vec2
		else
			local target_vec = tmp_vec2

			mvec3_dir(target_vec, self._m_head_pos, target_pos)

			return target_vec
		end
	end

	function SentryGunMovement:sync_fall_position(pos,rot) --spoofed network function;
		self._sync_target_pos = pos
		--[[
		local r = rot:yaw()
		local g = rot:pitch()
		local b = rot:roll()
		self._unit:weapon():set_laser_color(Color(r,g,b):with_alpha(0.3))
	--]]
	end

	Hooks:PostHook(SentryGunMovement,"_upd_movement","tcdso_sentry_movement_init",function(self,dt)

		if self._unit:base():is_owner() then 
			self._upd_sync_aim_t = self._upd_sync_aim_t + dt
			if self._upd_sync_aim_t > SentryControlMenu.tweakdata._SYNC_AIM_INTERVAL then 
				self._upd_sync_aim_t = self._upd_sync_aim_t - SentryControlMenu.tweakdata._SYNC_AIM_INTERVAL
				--[[
				local color_rot = self._unit:rotation()
				local laser = self._unit:weapon()._laser_unit 
				if laser then 
					color_rot = Rotation(laser:r(),laser:g(),laser:b())
				end
				--]]
				self._unit:network():send("sync_fall_position",self._m_head_fwd or self:_get_target_dir(),self._unit:rotation())
			end
			
			--slapped this here because apparently SentryWeaponBase:update() isn't used as a client
			local base = self._unit:base()
			if base._ws then 
				local size = 1000
				local pos = self._unit:position()
				local rot = self._unit:rotation()
				local vec_rot = rot:y()

				local ground_offset_vec = Vector3(0,0,3) --prevents z-fighting with whatever surface the sentry is on

				local right = vec_rot:cross(Vector3(0,0,1)):normalized()	
				local up = -vec_rot:cross(right):normalized()	

				local offset_vector = pos + ground_offset_vec + (vec_rot * size / 2) + (right * size / -2)
				local right_vector = right * size
				local bottom_vector = vec_rot * -size
				
				base._ws:set_world(size,size,offset_vector,right_vector,bottom_vector)
				
				
				
				local rot_speed = SentryControlMenu.tweakdata.bitmap_rotation_speed
				base._bitmap:set_rotation(base._bitmap:rotation() + (rot_speed * dt))
			end
		end
	end)
end