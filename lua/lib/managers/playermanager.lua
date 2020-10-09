Hooks:PostHook(PlayerManager,"_internal_load","deathvox_on_internal_load",function(self)
	if Network:is_server() then 
		deathvox:SyncOptionsToClients()
	else
		deathvox:ResetSessionSettings()
	end
end)

function PlayerManager:_chk_fellow_crimin_proximity(unit)
	local players_nearby = 0
		
	local criminals = World:find_units_quick(unit, "sphere", unit:position(), 1500, managers.slot:get_mask("criminals_no_deployables"))

	for _, criminal in ipairs(criminals) do
		players_nearby = players_nearby + 1
	end
		
	if players_nearby <= 0 then
		--log("uhohstinky")
	end
		
	return players_nearby
end

if deathvox:IsTotalCrackdownEnabled() then
	Hooks:PostHook(PlayerManager,"check_skills","deathvox_check_cd_skills",function(self)
		if self:has_category_upgrade("weapon", "making_miracles_basic") then
			self:set_property("making_miracles_stacks",0)
			self._message_system:register(Message.OnHeadShot,"proc_making_miracles_basic",
				function()
					local player = self:local_player()
					if not alive(player) then 
						return
					end
					local weapon = player:inventory():equipped_unit():base()
					if not weapon:is_weapon_class("rapidfire") then 
						return
					end
					
					self:add_to_property("making_miracles_stacks",1) --add one stack
					managers.enemy:remove_delayed_clbk("making_miracles_stack_expire",true) --reset timer if active
					managers.enemy:add_delayed_clbk("making_miracles_stack_expire", --add 4-second removal timer for stacks
						function()
							self:set_property("making_miracles_stacks",0)
						end,
						Application:time() + self:upgrade_value("weapon","making_miracles_basic",{0,0})[2]
					)
				end
			)
		else
			self._message_system:unregister(Message.OnLethalHeadShot,"proc_making_miracles_basic")
		end
		
		if self:has_category_upgrade("weapon","making_miracles_aced") then 
			self._message_system:register(Message.OnLethalHeadShot,"proc_making_miracles_aced",
				function(attack_data)
					local player = self:local_player()
					if not alive(player) then 
						return
					end
					local weapon_base = attack_data and attack_data.weapon_unit and attack_data.weapon_unit:base()
					if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_weapon_class("rapidfire") then 
						if weapon_base._setup.user_unit ~= player then 
							return
						end
					else
						return
					end
					
					self:add_to_property("making_miracles_stacks",1)
				end
			)
	else
		self._message_system:unregister(Message.OnLethalHeadShot,"proc_making_miracles_aced")
	end
		
		
		self:set_property("current_point_and_click_stacks",0)
		if self:has_category_upgrade("player","point_and_click_stacks") then 
			self._message_system:register(Message.OnEnemyShot,"proc_point_and_click",function(unit,attack_data)
				local player = self:local_player()
				if not alive(player) then 
					return
				end
				local weapon_base = attack_data and attack_data.weapon_unit and attack_data.weapon_unit:base()
				if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_weapon_class("precision") then 
					if weapon_base._setup.user_unit ~= player then 
						return
					end
				else
					return
				end
				self:add_to_property("current_point_and_click_stacks",self:upgrade_value("player","point_and_click_stacks",0))
			end)
			if self:has_category_upgrade("player","point_and_click_stack_from_kill") then 
				self._message_system:register(Message.OnEnemyKilled,"proc_investment_returns_basic",function(weapon_unit,variant,killed_unit)
					local player = self:local_player()
					if not alive(player) then 
						return
					end
					local weapon_base = weapon_unit and weapon_unit:base()
					if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_weapon_class("precision") then 
						if weapon_base._setup.user_unit ~= player then 
							return
						end
					else
						return
					end
					self:add_to_property("current_point_and_click_stacks",self:upgrade_value("player","point_and_click_stack_from_kill",0))
				end)
			else
				self._message_system:unregister(Message.OnEnemyKilled,"proc_investment_returns_basic")
			end
			
			if self:has_category_upgrade("player","point_and_click_stack_from_headshot_kill") then 
				self._message_system:register(Message.OnLethalHeadShot,"proc_investment_returns_aced",function(attack_data)
					local player = self:local_player()
					if not alive(player) then 
						return
					end
					local weapon_base = attack_data and attack_data.weapon_unit and attack_data.weapon_unit:base()
					if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_weapon_class("precision") then 
						if weapon_base._setup.user_unit ~= player then 
							return
						end
					else
						return
					end
					self:add_to_property("current_point_and_click_stacks",self:upgrade_value("player","point_and_click_stack_from_headshot_kill",0))
				end)
			else
				self._message_system:unregister(Message.OnLethalHeadShot,"proc_investment_returns_aced")
			end
			
			if self:has_category_upgrade("player","point_and_click_stack_mulligan") then 
				self._message_system:register(Message.OnEnemyKilled,"proc_mulligan_reprieve",function(weapon_unit,variant,killed_unit)
					local player = self:local_player()
					if not alive(player) then 
						return
					end
					local weapon_base = weapon_unit and weapon_unit:base()
					if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_weapon_class("precision") then 
						if weapon_base._setup.user_unit ~= player then 
							return
						end
					else
						return
					end
					
					managers.enemy:remove_delayed_clbk("point_and_click_on_shot_missed",true)
				end)
			else
				self._message_system:unregister(Message.OnEnemyKilled,"proc_mulligan_reprieve")
			end
			
			self._message_system:register(Message.OnWeaponFired,"clear_point_and_click_stacks",function(weapon_unit,result)
				if result and result.hit_enemy then
					return
				end
				
				local player = self:local_player()
				if not alive(player) then 
					return
				end
				
				local weapon_base = weapon_unit and weapon_unit:base()
				if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_weapon_class("precision") then 
					if weapon_base._setup.user_unit ~= player then 
						return
					end
				else
					return
				end
				
				if not managers.enemy:is_clbk_registered("point_and_click_on_shot_missed") then 
					managers.enemy:add_delayed_clbk("point_and_click_on_shot_missed",callback(self,self,"set_property","current_point_and_click_stacks",0),
						Application:time() + self:upgrade_value("player","point_and_click_stack_mulligan",0)
					)
				end
			end)
		else
			self._message_system:unregister(Message.OnEnemyShot,"proc_point_and_click")
			self._message_system:unregister(Message.OnWeaponFired,"clear_point_and_click_stacks")
		end
		
		if self:has_category_upgrade("weapon","magic_bullet") then 
			self._message_system:register(Message.OnLethalHeadShot,"proc_magic_bullet",function(attack_data)
				local player = self:local_player()
				if not alive(player) then 
					return
				end
				local weapon_base = attack_data.weapon_unit and attack_data.weapon_unit:base()
				if weapon_base and weapon_base._setup and weapon_base._setup.user_unit and weapon_base:is_weapon_class("precision") then 
					if weapon_base._setup.user_unit ~= player then 
						return
					end
				else
					return
				end
				
				if not weapon_base:ammo_full() then 
					local magic_bullet_level = self:upgrade_level("weapon","magic_bullet",0)
					local clip_current = weapon_base:get_ammo_remaining_in_clip()
					local clip_max = weapon_base:get_ammo_max_per_clip()
					local weapon_index = self:equipped_weapon_index()
					if (magic_bullet_level == 2) and (clip_current < clip_max) then
						weapon_base:set_ammo_remaining_in_clip(math.min(clip_max,clip_current + self:upgrade_value("weapon","magic_bullet",0)))
					else
						weapon_base:add_ammo_to_pool(self:upgrade_value("weapon","magic_bullet",0),self:equipped_weapon_index())
					end
					managers.hud:set_ammo_amount(weapon_index, weapon_base:ammo_info())
					player:sound():play("pickup_ammo")
				end
			end)
		else
			self._message_system:unregister(Message.OnLethalHeadShot,"proc_magic_bullet")
		end
		
	end)
end