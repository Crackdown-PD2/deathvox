if deathvox:IsTotalCrackdownEnabled() then

	function TradeManager:get_criminal_to_trade(wait_for_player)
		local ai_crim, has_player = nil
	
		local release_all_custodied = managers.player:has_team_category_upgrade("player","civilian_hostage_vip_trade")

		for _, crim in ipairs(self._criminals_to_respawn) do
			has_player = has_player or not crim.ai

			if crim.respawn_penalty <= 0 then
				if not crim.ai then
					return crim
				else
					ai_crim = ai_crim or crim
				end
			end
		end

		return (not wait_for_player or not has_player) and ai_crim,release_all_custodied and self._criminals_to_respawn
	end

	function TradeManager:clbk_respawn_criminal(pos, rotation)
		self._criminal_respawn_clbk = nil
		self._trading_hostage = nil
		local respawn_criminal,all_waiting_criminals = self:get_criminal_to_trade(false)

		if not respawn_criminal then
			self._trade_in_progress = false

			return
		end
		
		if all_waiting_criminals then 
			for i=#all_waiting_criminals,1,-1 do 
				--bit bunched up, spawning all in one place, but... i'm sure it's fine
				local crim = all_waiting_criminals[i]
				if crim then 
					self:criminal_respawn(pos,rotation,crim)
				end
			end
		else
			self:criminal_respawn(pos, rotation, respawn_criminal)
		end

--		print("Found criminal to respawn ", respawn_criminal and inspect(respawn_criminal))
	end

	
	do return end
	
	
	--false idol aced (not finished)
	function TradeManager:begin_hostage_trade(position, rotation, hostage, is_instant_trade, skip_free_criminal, skip_hint, skip_init)
	if hostage then
		local clbk_key = "TradeManager"
		self._trading_hostage = true
		
		self._hostage_to_trade = hostage
		
		if managers.player:has_team_category_upgrade("player","civilian_hostage_fakeout_trade") and not hostage.unit:brain()._has_done_fakeout_trade then 
			hostage.unit:brain()._has_done_fakeout_trade = true
			hostage.initialized = false
		else
			hostage.unit:brain():set_logic("trade", {
				skip_hint = skip_hint or false
			})
			if not hostage.initialized then
				self._hostage_to_trade.death_clbk_key = clbk_key
				self._hostage_to_trade.destroyed_clbk_key = clbk_key

				hostage.unit:character_damage():add_listener(clbk_key, {
					"death"
				}, callback(self, self, "clbk_hostage_died"))
				hostage.unit:base():add_destroy_listener(clbk_key, callback(self, self, "clbk_hostage_destroyed"))

				hostage.initialized = true
			end
		end


		if is_instant_trade then
			self._auto_assault_ai_trade_t = nil

			hostage.unit:brain():on_trade(position, rotation, not skip_free_criminal)

			self._trade_complete = false
		end
	else
		self:cancel_trade()
	end
end
	
	
		--didn't even change the below but they're bookmarked here because they may be relevant to taskmaster's false idol skill -offy
	
	
	
	function TradeManager:on_hostage_traded(pos, rotation)
		print("RC: Traded hostage!!")

		if self._criminal_respawn_clbk or self._trade_in_progress then
			return
		end

		self._hostage_to_trade = nil
		self._trade_in_progress = true
		local respawn_t = self._t + 2
		local clbk_id = "Respawn_criminal_on_trade"
		self._criminal_respawn_clbk = clbk_id

		managers.enemy:add_delayed_clbk(clbk_id, callback(self, self, "clbk_respawn_criminal", pos, rotation), respawn_t)
	end
	
	function TradeManager:play_custody_voice(criminal_name)
		if managers.criminals:local_character_name() == criminal_name then
			return
		end

		if #self._criminals_to_respawn == 3 then
			local criminal_left = nil

			for _, crim_data in pairs(managers.groupai:state():all_char_criminals()) do
				if not crim_data.unit:movement():downed() then
					criminal_left = managers.criminals:character_name_by_unit(crim_data.unit)

					break
				end
			end

			if managers.criminals:local_character_name() == criminal_left then
				managers.achievment:set_script_data("last_man_standing", true)

				if managers.groupai:state():bain_state() then
					local character_code = managers.criminals:character_static_data_by_name(criminal_left).ssuffix

					managers.dialog:queue_narrator_dialog("i20" .. character_code, {})
				end

				return
			end
		end

		if managers.groupai:state():bain_state() then
			local character_code = managers.criminals:character_static_data_by_name(criminal_name).ssuffix

			managers.dialog:queue_narrator_dialog("h11" .. character_code, {})
		end
	end
	function TradeManager:_announce_spawn(criminal_name)
		if not managers.groupai:state():bain_state() then
			return
		end

		local character_code = managers.criminals:character_static_data_by_name(criminal_name).ssuffix

		managers.dialog:queue_narrator_dialog("q02" .. character_code, {})
	end
	
end