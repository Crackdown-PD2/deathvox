local alive_g = alive

if deathvox:IsTotalCrackdownEnabled() then

	function DOTManager:add_doted_enemy(data)
		
		local dot_info, var_info, should_sync = self:_add_doted_enemy(data)
		

		local selection_index = nil
		local weapon = data.weapon_unit
		local attacker = data.attacker_unit
		local doted_unit = data.unit
		attacker = attacker and attacker:id() ~= -1 and attacker or nil
		
		-- cd changes contained here v
		if alive_g(attacker) and attacker == managers.player:player_unit() then
			
			if var_info.dot_damage then
				local dot_dmg_mul = managers.player:upgrade_value("subclass_poison", "weapon_subclass_damage_mul", 1)

				if dot_dmg_mul > 1 then
					var_info.dot_damage = var_info.dot_damage * dot_dmg_mul
				end
			end
			
			if not data.no_spread then
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
								new_data.no_spread = true
								new_data.hurt_animation = false
								--{ --sample
								--	unit = data.unit,
								--	dot_data = data.dot_data,
								--	hurt_animation = data.hurt_animation,
								--	modified_length = data.modified_length,
								--	weapon_id = data.weapon_id,
								--	weapon_unit = data.weapon_unit,
								--	attacker_unit = user_unit
								--}
								
								self:add_doted_enemy(new_data)
							end
						end	
					end
				end
			end
		end
		
		if should_sync then
			if doted_unit:id() == -1 then
				Application:error("[DOTManager:add_doted_enemy] Unit is not network-synced, can't sync dot.", doted_unit)

				return dot_info, var_info
			end

			local tweak_sync_index = tweak_data.dot:get_sync_index_from_name(data.dot_data.name)

			if not tweak_sync_index then
				Application:error("[DOTManager:add_doted_enemy] No sync index found for tweak name '" .. tostring(data.dot_data.name) .. "', can't sync dot.")

				return dot_info, var_info
			end
			if weapon then
				local base_ext = weapon:base()
				selection_index = base_ext and base_ext.selection_index and base_ext:selection_index()
				weapon = weapon:id() ~= -1 and weapon or nil
			end

			local is_melee = tweak_data.blackmarket and tweak_data.blackmarket.melee_weapons and tweak_data.blackmarket.melee_weapons[data.weapon_id] and true or false
			local hurt_anim = data.hurt_animation and true or false

			managers.network:session():send_to_peers_synched("sync_add_doted_enemy", doted_unit, attacker, weapon, is_melee, hurt_anim, tweak_sync_index, selection_index or 0)
		end

		return dot_info, var_info
	end
	
end