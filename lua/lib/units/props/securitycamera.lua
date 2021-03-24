if deathvox:IsTotalCrackdownEnabled() then 

	--no longer using SecurityCamera.active_tape_loop_unit; instead tracking all looped cameras in the below table
	SecurityCamera.all_active_tape_loop_units = {}

	--these functions added from tcd
	function SecurityCamera.register_tape_loop_unit(unit)
		table.insert(SecurityCamera.all_active_tape_loop_units,#SecurityCamera.all_active_tape_loop_units + 1,unit)
	end

	function SecurityCamera.unregister_tape_loop(unit)
		local all_loops = SecurityCamera.get_all_active_tape_loop_units()
		for _,cam_unit in ipairs(all_loops) do 
			if cam_unit == unit then 
				cam_unit:contour():remove("mark_unit_friendly")
				break
			end
		end
	end

	function SecurityCamera.get_all_active_tape_loop_units(skip_check)
		if not skip_check then 
			for i=#SecurityCamera.all_active_tape_loop_units,1,-1 do 
				local unit = SecurityCamera.all_active_tape_loop_units[i]
				if not alive(unit) then 
					table.remove(SecurityCamera.all_active_tape_loop_units,i)
				end
			end
		end
		
		return SecurityCamera.all_active_tape_loop_units
	end

	function SecurityCamera.can_start_new_tape_loop(unit)
		if managers.player:has_team_category_upgrade("player","tape_loop_amount_unlimited") then 
			return true
		end
		if #SecurityCamera.all_active_tape_loop_units == 0 then 
			return true
		end
		
		if alive(unit) then 
			for i,cam_unit in ipairs(SecurityCamera.all_active_tape_loop_units) do 
				if cam_unit == unit then 
					--player can refresh a currently looped camera
					return true
				end
			end
		else
			return true
		end
		
		return false
	end


--below functions modified to accommodate multilooping
	function SecurityCamera:start_tape_loop(tape_loop_t)
		if not SecurityCamera.can_start_new_tape_loop(self._unit) then 
			return
		end

		local time_upgrade_level = managers.player:upgrade_level("player", "tape_loop_duration", 0)

		if Network:is_server() then
			self:_start_tape_loop_by_upgrade_level(time_upgrade_level)

			if time_upgrade_level == 1 then
				self:_send_net_event(self._NET_EVENTS.start_tape_loop_1)
			elseif time_upgrade_level == 2 then
				self:_send_net_event(self._NET_EVENTS.start_tape_loop_2)
			end
		elseif time_upgrade_level == 1 then
			self:_send_net_event(self._NET_EVENTS.request_start_tape_loop_1)
		elseif time_upgrade_level == 2 then
			self:_send_net_event(self._NET_EVENTS.request_start_tape_loop_2)
		end
	end

	function SecurityCamera:_request_start_tape_loop_by_upgrade_level(time_upgrade_level)
		if not Network:is_server() then
			return
		end
		
		if not SecurityCamera.can_start_new_tape_loop(self._unit) then 
			return
		end
		
		self:_start_tape_loop_by_upgrade_level(time_upgrade_level)

		if time_upgrade_level == 1 then
			self:_send_net_event(self._NET_EVENTS.start_tape_loop_1)
		elseif time_upgrade_level == 2 then
			self:_send_net_event(self._NET_EVENTS.start_tape_loop_2)
		end
	end

	function SecurityCamera:_start_tape_loop(tape_loop_t)
		self:_deactivate_tape_loop_restart()

		self._tape_loop_end_t = Application:time() + tape_loop_t
		
		SecurityCamera.register_tape_loop_unit(self._unit)

		self._unit:contour():add("mark_unit_friendly")

		if self._unit:interaction() then
			self._unit:interaction():set_active(false)
		end

		if self._camera_wrong_image_sound then
			self._camera_wrong_image_sound:stop()
		end

		self._camera_wrong_image_sound = self._unit:sound_source():post_event("camera_wrong_image")

		if self._tape_loop_expired_clbk_id then
			managers.enemy:remove_delayed_clbk(self._tape_loop_expired_clbk_id)

			self._tape_loop_expired_clbk_id = nil
		end

		self._tape_loop_expired_clbk_id = "tape_loop_expired" .. tostring(self._unit:key())

		managers.enemy:add_delayed_clbk(self._tape_loop_expired_clbk_id, callback(self, self, "_clbk_tape_loop_expired"), self._tape_loop_end_t)
	end

	function SecurityCamera:_clbk_tape_loop_expired(...)
		self._tape_loop_expired_clbk_id = nil
		self._tape_loop_end_t = nil

		self._unit:contour():remove("mark_unit_friendly")

		if self._unit:interaction() then
			self._unit:interaction():set_active(true)
		end

		if self._destroyed then
			return
		end

		self:_activate_tape_loop_restart(5)

		SecurityCamera.unregister_tape_loop(self._unit)
	end

	function SecurityCamera:_deactivate_tape_loop()
		if Network:is_server() then
			self:_send_net_event(self._NET_EVENTS.deactivate_tape_loop)
		end

		SecurityCamera.unregister_tape_loop(self._unit)

		if self._tape_loop_expired_clbk_id then
			managers.enemy:remove_delayed_clbk(self._tape_loop_expired_clbk_id)

			self._tape_loop_end_t = nil
			self._tape_loop_expired_clbk_id = nil
		end

		if self._camera_wrong_image_sound then
			self._camera_wrong_image_sound:stop()

			self._camera_wrong_image_sound = nil
		end

		if self._tape_loop_restarting_t then
			self:_deactivate_tape_loop_restart()
		end

		if self._unit:interaction() then
			self._unit:interaction():set_active(false)
		end
	end

	function SecurityCamera:destroy(unit)
		table.delete(SecurityCamera.cameras, self._unit)

		self._destroying = true

		self:set_detection_enabled(false)

		if self._call_police_clbk_id then
			managers.enemy:remove_delayed_clbk(self._call_police_clbk_id)

			self._call_police_clbk_id = nil
		end

		if self._tape_loop_expired_clbk_id then
			managers.enemy:remove_delayed_clbk(self._tape_loop_expired_clbk_id)

			self._tape_loop_expired_clbk_id = nil
		end

		SecurityCamera.unregister_tape_loop(self._unit)
	end


end