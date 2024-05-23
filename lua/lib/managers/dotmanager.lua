local alive_g = alive

if deathvox:IsTotalCrackdownEnabled() then
	
	function DOTManager:add_doted_enemy(data)

		-- cd changes MOSTLY contained here in this block v
		local attacker = data.attacker_unit	
		if data.dot_data and data.dot_data.variant == "poison" then
			if alive_g(attacker) and attacker == managers.player:player_unit() then
				
				local doted_unit = data.unit
				if alive_g(doted_unit) then
					
					if not data.no_spread then
						-- Toxic Shock poison spreading
						local dot_range = managers.player:upgrade_value("subclass_poison", "poison_dot_aoe", 0)
						
						if dot_range > 0 then
							local nearby_enemies = doted_unit:find_units_quick("sphere", doted_unit:position(), dot_range, managers.slot:get_mask("enemies"))
							
							for i = 1, #nearby_enemies do
								local enemy = nearby_enemies[i]
								if enemy ~= doted_unit then
									local base = enemy:base()
									if base and not base.sentry_gun then -- don't apply to sentryguns
										local new_data = table.deep_map_copy(data)
										new_data.unit = enemy
										new_data.no_spread = true -- from tcd; this newly-applied instance shouldn't cause further poison spreading
										new_data.hurt_animation = false
										
										--{ --sample
										--	[string] weapon_id
										--	[Unit] unit
										--	[Unit] attacker_unit
										--	[bool] hurt_animation
										--	[Unit] weapon_unit
										--	[table] dot_data
											-- [string] variant
											-- [float] dot_grace_period
											-- [float] dot_tick_period
											-- [string->classtable lookup]damage_class
											-- [float] dot_damage
											-- [float] dot_length
											-- [string->tweakdata dot table lookup] name
											-- [bool] PROCESSED
										--}
										
										self:add_doted_enemy(new_data)
									end
								end	
							end
						end
					end
				end
				
				-- apply damage bonus after spread
				-- or else the damage bonus would be exponential
				if data.dot_damage then
					data.dot_damage = data.dot_damage * managers.player:upgrade_value("subclass_poison", "weapon_subclass_damage_mul", 1)
				end
			end
		end
		-- end tcd changes (mostly)
		
		local dot_info, var_info, should_sync = self:_add_doted_enemy(data)
		
		if should_sync then
			if data.unit:id() == -1 then
				Application:error("[DOTManager:add_doted_enemy] Unit is not network-synced, can't sync dot.", data.unit)

				return dot_info, var_info
			end

			local tweak_sync_index = tweak_data.dot:get_sync_index_from_name(data.dot_data.name)

			if not tweak_sync_index then
				Application:error("[DOTManager:add_doted_enemy] No sync index found for tweak name '" .. tostring(data.dot_data.name) .. "', can't sync dot.")

				return dot_info, var_info
			end

			local selection_index = nil
			local weapon = data.weapon_unit
			--local attacker = data.attacker_unit
			attacker = attacker and attacker:id() ~= -1 and attacker or nil

			if weapon then
				local base_ext = weapon:base()
				selection_index = base_ext and base_ext.selection_index and base_ext:selection_index()
				weapon = weapon:id() ~= -1 and weapon or nil
			end

			local is_melee = tweak_data.blackmarket and tweak_data.blackmarket.melee_weapons and tweak_data.blackmarket.melee_weapons[data.weapon_id] and true or false
			local hurt_anim = data.hurt_animation and true or false

			managers.network:session():send_to_peers_synched("sync_add_doted_enemy", data.unit, attacker, weapon, is_melee, hurt_anim, tweak_sync_index, selection_index or 0)
		end

		return dot_info, var_info
	end
	
end