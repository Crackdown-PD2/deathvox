if deathvox:IsTotalCrackdownEnabled() then 
	Hooks:PostHook(FragGrenade,"_setup_from_tweak_data","tcd_setup_fraggrenade_td",function(self)
		local grenade_entry = self._tweak_projectile_entry or "frag"
		local tweak_entry = tweak_data.projectiles[grenade_entry]
		self._critical_chance = tweak_entry.critical_chance
		self._child_clusters = tweak_entry.child_clusters
		if tweak_entry.slot_mask_id then 
			self._slot_mask = managers.slot:get_mask(tweak_entry.slot_mask_id)
		end
		self._cant_be_shot_to_detonate = tweak_entry._cant_be_shot_to_detonate
	end)

	function FragGrenade:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
		local pos = self._unit:position()
		local normal = math.UP
		local range = self._range
		local slot_mask = managers.slot:get_mask("explosion_targets")

		managers.explosion:give_local_player_dmg(pos, range, self._player_damage)
		managers.explosion:play_sound_and_effects(pos, normal, range, self._custom_params)

		local hit_units, splinters = managers.explosion:detect_and_give_dmg({
			player_damage = 0,
			hit_pos = pos,
			range = range,
			collision_slotmask = slot_mask,
			curve_pow = self._curve_pow,
			damage = self._damage,
			ignore_unit = self._unit,
			alert_radius = self._alert_radius,
			critical_chance = self._critical_chance,
			user = self:thrower_unit() or self._unit,
			owner = self._unit
		})
		
		--[[
		if grenade_entry == "dada_com" then 
			--do split here
			
			--spawn x number of child grenades, but flag each child grenade as unable to create more child grenades
		end
		--]]
		managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", GrenadeBase.EVENT_IDS.detonate)
		self._unit:set_slot(0)
	end

	
	function FragGrenade:bullet_hit()
		if self._cant_be_shot_to_detonate then 
			return
		elseif not Network:is_server() then
			return
		end
			
		self._timer = nil

		self:_detonate()
	end

end