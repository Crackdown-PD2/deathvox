local pairs_g = pairs

local alive_g = alive

function DOTManager:update(t, dt)
	local doted_enemies = self._doted_enemies

	for index = #doted_enemies, 1, -1 do
		local dot_info = doted_enemies[index]
		local dot_counter = dot_info.dot_counter

		dot_counter = dot_counter + dt

		if dot_counter > 0.5 then
			self:_damage_dot(dot_info)

			dot_counter = dot_counter - 0.5
		end

		dot_info.dot_counter = dot_counter

		if t > dot_info.dot_length then
			local new_doted_enemies = {}

			for idx = 1, index - 1 do
				new_doted_enemies[#new_doted_enemies + 1] = doted_enemies[idx]
			end

			for idx = index + 1, #doted_enemies do
				new_doted_enemies[#new_doted_enemies + 1] = doted_enemies[idx]
			end

			doted_enemies = new_doted_enemies
			self._doted_enemies = doted_enemies
		end
	end
end

function DOTManager:check_achievemnts(unit, t)
	local achiev_data = tweak_data.achievement.dot_achievements

	if not achiev_data then
		return
	end

	local doted_enemies = self._doted_enemies

	if not doted_enemies or not alive_g(unit) then
		return
	end

	local base_ext = unit:base()

	if not base_ext then
		return
	end

	local tweak_name = base_ext._tweak_table

	if not tweak_name or CopDamage.is_civilian(tweak_name) then
		return
	end

	local dotted_enemies_by_variant = {}
	local local_player = managers.player:player_unit()

	for index = 1, #doted_enemies do
		local dot_info = doted_enemies[index]
		local variant = dot_info.variant
		dotted_enemies_by_variant[variant] = dotted_enemies_by_variant[variant] or {}

		if dot_info.user_unit and dot_info.user_unit == local_player then
			local tbl = dotted_enemies_by_variant[variant]
			tbl[#tbl + 1] = dot_info

			dotted_enemies_by_variant[variant] = tbl
		end
	end

	local variant_count_pass, all_pass = nil

	for achievement, achievement_data in pairs_g(tweak_data.achievement.dot_achievements) do
		variant_count_pass = not achievement_data.count or achievement_data.variant and dotted_enemies_by_variant[achievement_data.variant] and achievement_data.count <= #dotted_enemies_by_variant[achievement_data.variant]
		all_pass = variant_count_pass

		if all_pass then
			managers.achievment:award_data(achievement_data)

			break
		end
	end
end

if deathvox:IsTotalCrackdownEnabled() then
	function DOTManager:add_doted_enemy(enemy_unit, dot_damage_received_time, weapon_unit, dot_length, dot_damage, hurt_animation, variant, weapon_id)
		local local_player = managers.player:player_unit() or nil
		local dot_dmg_mul = managers.player:upgrade_value("subclass_poison", "weapon_subclass_damage_mul", 1)

		if dot_dmg_mul > 1 then
			dot_damage = dot_damage * dot_dmg_mul
		end

		local add_doted_f = self._add_doted_enemy
		local dot_info = add_doted_f(self, enemy_unit, dot_damage_received_time, weapon_unit, dot_length, dot_damage, hurt_animation, variant, weapon_id, local_player)

		local sync_variant = variant == "poison" and 1 or variant == "dot" and 2 or nil
		local weapon = weapon_id ~= nil and local_player or nil

		local session = managers.network:session()
		local send_to_peers_synched_f = session.send_to_peers_synched
		send_to_peers_synched_f(session, "sync_add_doted_enemy", enemy_unit, variant, weapon, dot_length, dot_damage, local_player, hurt_animation)

		local dot_range = managers.player:upgrade_value("subclass_poison", "poison_dot_aoe", 0)

		if dot_range > 0 then
			local nearby_enemies = enemy_unit:find_units_quick("sphere", enemy_unit:position(), dot_range, managers.slot:get_mask("enemies"))

			for i = 1, #nearby_enemies do
				local enemy = nearby_enemies[i]

				add_doted_f(self, enemy, dot_damage_received_time, weapon_unit, dot_length, dot_damage, false, variant, weapon_id, local_player)
				send_to_peers_synched_f(session, "sync_add_doted_enemy", enemy, sync_variant, weapon, dot_length, dot_damage, local_player, false)
			end
		end
	end
else
	function DOTManager:add_doted_enemy(enemy_unit, dot_damage_received_time, weapon_unit, dot_length, dot_damage, hurt_animation, variant, weapon_id)
		local local_player = managers.player:player_unit() or nil
		local dot_info = self:_add_doted_enemy(enemy_unit, dot_damage_received_time, weapon_unit, dot_length, dot_damage, hurt_animation, variant, weapon_id, local_player)

		local sync_variant = variant == "poison" and 1 or variant == "dot" and 2 or nil
		local weapon = weapon_id ~= nil and local_player or nil

		managers.network:session():send_to_peers_synched("sync_add_doted_enemy", enemy_unit, variant, weapon, dot_length, dot_damage, local_player, hurt_animation)
	end
end

function DOTManager:sync_add_dot_damage(enemy_unit, variant, weapon_unit, dot_length, dot_damage, user_unit, hurt_animation, variant, weapon_id)
	if enemy_unit then
		local t = TimerManager:game():time()

		self:_add_doted_enemy(enemy_unit, t, weapon_unit, dot_length, dot_damage, hurt_animation, variant, weapon_id, user_unit)
	end
end

function DOTManager:_add_doted_enemy(enemy_unit, dot_damage_received_time, weapon_unit, dot_length, dot_damage, hurt_animation, variant, weapon_id, user_unit)
	local doted_enemies = self._doted_enemies

	if not doted_enemies then
		return
	end

	local already_doted = false
	local t = TimerManager:game():time()
	local new_length = t + dot_length

	for i = 1, #doted_enemies do
		local dot_info = doted_enemies[i]

		if dot_info.enemy_unit == enemy_unit then
			already_doted = true

			--previous timer should never be shortened, unless the new instance would deal more damage
			if dot_info.dot_length < new_length or dot_info.dot_damage < dot_damage then
				dot_info.dot_length = new_length
				dot_info.dot_damage = dot_damage
			end

			--always override the rest of the info so that the latest attacker gets credited properly
			--only exception being hurt_animation, so that it doesn't magically get removed
			dot_info.weapon_unit = weapon_unit
			dot_info.hurt_animation = dot_info.hurt_animation or hurt_animation
			dot_info.variant = variant
			dot_info.weapon_id = weapon_id
			dot_info.user_unit = user_unit

			break
		end
	end

	if not already_doted then
		local dot_info = {
			dot_counter = 0,
			enemy_unit = enemy_unit,
			weapon_unit = weapon_unit,
			dot_length = new_length,
			dot_damage = dot_damage,
			hurt_animation = hurt_animation,
			variant = variant,
			weapon_id = weapon_id,
			user_unit = user_unit
		}

		doted_enemies[#doted_enemies + 1] = dot_info
	end

	self._doted_enemies = doted_enemies

	self:check_achievemnts(enemy_unit, t)
end

function DOTManager:_damage_dot(dot_info)
	if dot_info.user_unit and dot_info.user_unit == managers.player:player_unit() or not dot_info.user_unit and Network:is_server() then
		local attacker_unit = managers.player:player_unit()
		local col_ray = {
			unit = dot_info.enemy_unit
		}
		local damage = dot_info.dot_damage
		local ignite_character = false
		local weapon_unit = dot_info.weapon_unit
		local weapon_id = dot_info.weapon_id

		if dot_info.variant and dot_info.variant == "poison" then
			PoisonBulletBase:give_damage_dot(col_ray, weapon_unit, attacker_unit, damage, dot_info.hurt_animation, weapon_id)
		end
	end
end
