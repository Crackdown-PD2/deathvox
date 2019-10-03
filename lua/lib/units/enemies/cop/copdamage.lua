local mvec_1 = Vector3()
local mvec_2 = Vector3()

function CopDamage:is_immune_to_shield_knockback()
	local acting = self._unit:anim_data() and self._unit:anim_data().act

	return self._immune_to_knockback or acting
end

function CopDamage:_comment_death(attacker, killed_unit, special_comment)
	local victim_base = killed_unit:base()
	if special_comment then
		PlayerStandard.say_line(attacker:sound(), special_comment)
	elseif victim_base:has_tag("tank") then
		PlayerStandard.say_line(attacker:sound(), "g30x_any")
	elseif victim_base:has_tag("spooc") then
		PlayerStandard.say_line(attacker:sound(), "g33x_any")
	elseif victim_base:has_tag("taser") then
		PlayerStandard.say_line(attacker:sound(), "g32x_any")
	elseif victim_base:has_tag("shield") then
		PlayerStandard.say_line(attacker:sound(), "g31x_any")
	elseif victim_base:has_tag("sniper") then
		PlayerStandard.say_line(attacker:sound(), "g35x_any")
	elseif victim_base:has_tag("medic") then
		PlayerStandard.say_line(attacker:sound(), "g36x_any")
	elseif victim_base:has_tag("custom") then
		PlayerStandard.say_line(attacker:sound(), "g92")
	end
end
function CopDamage:_AI_comment_death(unit, killed_unit, special_comment)
	local victim_base = killed_unit:base()

	if special_comment then
		unit:sound():say(special_comment, true)
	elseif victim_base:has_tag("tank") then
		unit:sound():say("g30x_any", true)
	elseif victim_base:has_tag("spooc") then
		unit:sound():say("g33x_any", true)
	elseif victim_base:has_tag("taser") then
		unit:sound():say("g32x_any", true)
	elseif victim_base:has_tag("shield") then
		unit:sound():say("g31x_any", true)
	elseif victim_base:has_tag("sniper") then
		unit:sound():say("g35x_any", true)
	elseif victim_base:has_tag("medic") then
		unit:sound():say("g36x_any", true)
	elseif victim_base:has_tag("custom") then
		unit:sound():say("g92", true)
	end
end

function CopDamage:check_medic_heal()
	if self._unit:anim_data() and self._unit:anim_data().act then
		return false
	end

	local medic = managers.enemy:get_nearby_medic(self._unit)
	local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	if difficulty_index == 8 and medic then
		if medic:character_damage():heal_unit(self._unit) then
			local enemies = World:find_units_quick(medic, "sphere", medic:position(), tweak_data.medic.radius, managers.slot:get_mask("enemies"))
			
			for _, enemy in ipairs(enemies) do
				if medic:character_damage():heal_unit(enemy, true) and not enemy == self._unit then
					enemy:movement():action_request({
						body_part = 1,
						type = "healed",
						client_interrupt = Network:is_client()
					})
				end
			end
			return true
		end
	else
		return medic and medic:character_damage():heal_unit(self._unit)
	end
end

function CopDamage:damage_explosion(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	if self:is_friendly_fire(attack_data.attacker_unit) then
		return "friendly_fire"
	end

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)

	if not is_civilian and attack_data.attacker_unit and alive(attack_data.attacker_unit) then
		managers.player:send_message(Message.OnEnemyShot, nil, attack_data.attacker_unit, self._unit, "explosion")
	end

	local result = nil
	local damage = attack_data.damage
	damage = damage * (self._char_tweak.damage.explosion_damage_mul or 1)
	damage = damage * (self._marked_dmg_mul or 1)

	--HVT ace now also grants its bonus
	if valid_attacker and self._marked_dmg_mul and self._marked_dmg_dist_mul then
		local attacking_unit = attack_data.attacker_unit

		if attacking_unit and attacking_unit:base() and attacking_unit:base().thrower_unit then
			attacking_unit = attacking_unit:base():thrower_unit()
		end

		if alive(attacking_unit) then
			local dst = mvector3.distance(attacking_unit:position(), self._unit:position())
			local spott_dst = tweak_data.upgrades.values.player.marked_inc_dmg_distance[self._marked_dmg_dist_mul]

			if spott_dst[1] < dst then
				damage = damage * spott_dst[2]
			end
		end
	end

	if attack_data.attacker_unit == managers.player:player_unit() then
		local critical_hit, crit_damage = self:roll_critical_hit(attack_data)
		damage = crit_damage

		if attack_data.weapon_unit and attack_data.variant ~= "stun" then
			if critical_hit then
				if damage > 0 then
					managers.hud:on_crit_confirmed()
				end
			else
				if damage > 0 then --prevent ECM feedback and similar from triggering the hit marker
					managers.hud:on_hit_confirmed()
				end
			end
		end

		if tweak_data.character[self._unit:base()._tweak_table].priority_shout then
			damage = damage * managers.player:upgrade_value("weapon", "special_damage_taken_multiplier", 1)
		end
	end

	damage = managers.modifiers:modify_value("CopDamage:DamageExplosion", damage, self._unit:base()._tweak_table)

	if self._unit:base():char_tweak().DAMAGE_CLAMP_EXPLOSION then
		damage = math.min(damage, self._unit:base():char_tweak().DAMAGE_CLAMP_EXPLOSION)
	end

	damage = self:_apply_damage_reduction(damage)
	damage = math.clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._unit:movement():cool() and self._unit:base():char_tweak()["stealth_instant_kill"] then
		damage = self._HEALTH_INIT
	end
	
	if self._immortal then
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		if self:check_medic_heal() then
			attack_data.variant = "healed"
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			attack_data.damage = self._health
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
		end
	else
		attack_data.damage = damage
		local result_type = attack_data.variant == "stun" and "hurt_sick" or self:get_damage_type(damage_percent, "explosion")
		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position
	local head = nil

	if self._head_body_name and attack_data.variant ~= "stun" then
		head = attack_data.col_ray.body and self._head_body_key and attack_data.col_ray.body:key() == self._head_body_key
		local body = self._unit:body(self._head_body_name)
	end

	result.ignite_character = attack_data.ignite_character

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			owner = attack_data.owner,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant,
			head_shot = head
		}
		if data.name == "deathvox_grenadier" then
			self._unit:damage():run_sequence_simple("grenadier_glass_break")
		else
			if self._head_body_name and attack_data.variant ~= "stun" then --moved this here so that only explosive kills send helmets flying for consistency's sake (since headshot damage doesn't change if a helmet is there or not)
				local body = self._unit:body(self._head_body_name)

				self:_spawn_head_gadget({
					position = body:position(),
					rotation = body:rotation(),
					dir = -attack_data.col_ray.ray
				})
			end
		end

		managers.statistics:killed_by_anyone(data)

		local attacker_unit = attack_data.attacker_unit

		if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			data.weapon_unit = attack_data.attacker_unit
		end

		if not is_civilian and managers.player:has_category_upgrade("temporary", "overkill_damage_multiplier") and attacker_unit == managers.player:player_unit() and attack_data.weapon_unit and attack_data.weapon_unit:base().weapon_tweak_data and not attack_data.weapon_unit:base().thrower_unit and attack_data.weapon_unit:base():is_category("shotgun", "saw") then
			managers.player:activate_temporary_upgrade("temporary", "overkill_damage_multiplier")
		end

		self:chk_killshot(attacker_unit, "explosion")

		if attacker_unit == managers.player:player_unit() then
			if alive(attacker_unit) then
				self:_comment_death(attacker_unit, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if is_civilian then
				managers.money:civilian_killed()
			end

			self:_check_damage_achievements(attack_data, false)
		else
			if attacker_unit and alive(attacker_unit) and managers.groupai:state():is_unit_team_AI(attacker_unit) then --enable team AI special kill callouts
				self:_AI_comment_death(attacker_unit, self._unit)
			end
		end
	end

	local attacker = attack_data.attacker_unit

	if not attacker or attacker:id() == -1 then
		attacker = self._unit
	end

	local weapon_unit = attack_data.weapon_unit

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", attacker, damage_percent)
	end

	if not self._no_blood and damage > 0 then
		managers.game_play_central:sync_play_impact_flesh(attack_data.pos, attack_data.col_ray.ray)
	end

	self:_send_explosion_attack_result(attack_data, attacker, damage_percent, self:_get_attack_variant_index(attack_data.result.variant), attack_data.col_ray.ray)
	self:_on_damage_received(attack_data)

	return result
end

function CopDamage:damage_bullet(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	if self:is_friendly_fire(attack_data.attacker_unit) then
		return "friendly_fire"
	end

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)

	if not is_civilian then
		managers.player:send_message(Message.OnEnemyShot, nil, attack_data.attacker_unit, self._unit, attack_data and attack_data.variant or "bullet")
	end

	--moved up here so that blocked shots don't interfere
	if attack_data.weapon_unit and attack_data.weapon_unit:base().is_category and attack_data.weapon_unit:base():is_category("saw") then
		managers.groupai:state():chk_say_enemy_chatter(self._unit, self._unit:movement():m_pos(), "saw")
	end
		
	if attack_data.attacker_unit:base().sentry_gun then
		managers.groupai:state():chk_say_enemy_chatter(self._unit, self._unit:movement():m_pos(), "sentry")
	end

	if self._has_plate and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_plate_name and not attack_data.armor_piercing then
		local armor_pierce_roll = math.rand(1)
		local armor_pierce_value = 0

		if attack_data.attacker_unit == managers.player:player_unit() and not attack_data.weapon_unit:base().thrower_unit then
			armor_pierce_value = armor_pierce_value + attack_data.weapon_unit:base():armor_piercing_chance()
			armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("player", "armor_piercing_chance", 0)
			armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("weapon", "armor_piercing_chance", 0)
			armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("weapon", "armor_piercing_chance_2", 0)

			if attack_data.weapon_unit:base():got_silencer() then
				armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("weapon", "armor_piercing_chance_silencer", 0)
			end

			if attack_data.weapon_unit:base():is_category("saw") then
				armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("saw", "armor_piercing_chance", 0)
			end
		end

		if armor_pierce_value <= armor_pierce_roll then
			local damage = attack_data.damage
			local damage_percent = math.ceil(math.clamp(damage / self._HEALTH_INIT_PRECENT, 1, self._HEALTH_GRANULARITY))
			damage = damage_percent * self._HEALTH_INIT_PRECENT
			damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

			local result_type = not self._char_tweak.immune_to_knock_down and (attack_data.knock_down and "knock_down" or attack_data.stagger and not self._has_been_staggered and "stagger") or self:get_damage_type(damage_percent, "bullet")
			
			local shield_stagger = nil

			if (result_type == "knock_down" or result_type == "stagger") and alive(self._unit:inventory() and self._unit:inventory()._shield_unit) then
				local can_be_shield_knocked = not self._unit:base().is_phalanx and self._char_tweak.damage.shield_knocked and not self:is_immune_to_shield_knockback()

				if can_be_shield_knocked then
					if result_type == "stagger" then
						shield_stagger = true
					end

					result_type = "expl_hurt"
				end
			end

			local result = {
				type = result_type,
				variant = attack_data.variant
			}

			local variant = nil

			if result.type == "knock_down" then
				variant = 1
			elseif result.type == "stagger" then
				variant = 2
				self._has_been_staggered = true
			elseif result.type == "healed" then
				variant = 3
			elseif result.type == "expl_hurt" then
				variant = 4

				if shield_stagger then
					self._has_been_staggered = true
				end
			elseif result.type == "hurt" then
				variant = 5
			elseif result.type == "heavy_hurt" then
				variant = 6
			elseif result.type == "light_hurt" then
				variant = 7
			elseif result.type == "dmg_rcv" then --important, need to sync if there's no reaction
				variant = 8
			else
				variant = 0
			end

			local body_index = self._unit:get_body_index(attack_data.col_ray.body:name())
			local hit_offset_height = math.clamp(attack_data.col_ray.position.z - self._unit:movement():m_pos().z, 0, 300)
			attack_data.result = result
			attack_data.pos = attack_data.col_ray.position
			attack_data.damage = 0
			damage = 0
			damage_percent = 0

			self:_send_bullet_attack_result(attack_data, attack_data.attacker_unit, damage_percent, body_index, hit_offset_height, variant)
			self:_on_damage_received(attack_data)

			return result --0 damage but the enemy can still flinch or get knocked around
		end

		--spawn a blood splatter if armor was penetrated just for flavor
		World:effect_manager():spawn({
			effect = Idstring("effects/payday2/particles/impacts/blood/blood_impact_a"),
			position = attack_data.col_ray.position,
			normal = attack_data.col_ray.ray
		})
	end

	local result = nil
	local body_index = self._unit:get_body_index(attack_data.col_ray.body:name())

	--the change below prevents you from using triggering headshot-based effects from Jokers and units that are supposed to ignore headshot multipliers in vanilla
	local head = not self._unit:in_slot(16) and not self._char_tweak.ignore_headshot and self._head_body_name and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name

	--negate headshot damage against Dozers if not done from the front (except for throwables) for consistency's sake, works pretty well I'd say
	if head and self._unit:base():has_tag("tank") and not attack_data.weapon_unit:base().thrower_unit then
		mvector3.set(mvec_1, attack_data.col_ray.body:position())
		mvector3.subtract(mvec_1, attack_data.attacker_unit:position())
		mvector3.normalize(mvec_1)
		mvector3.set(mvec_2, self._unit:rotation():y())

		local not_from_the_front = mvector3.dot(mvec_1, mvec_2) >= 0

		if not_from_the_front then
			head = false
		end
	end

	local damage = attack_data.damage

	damage = damage * (self._marked_dmg_mul or 1)

	if self._marked_dmg_mul and self._marked_dmg_dist_mul then
		local dst = mvector3.distance(attack_data.origin, self._unit:position())
		local spott_dst = tweak_data.upgrades.values.player.marked_inc_dmg_distance[self._marked_dmg_dist_mul]

		if spott_dst[1] < dst then
			damage = damage * spott_dst[2]
		end
	end

	local headshot = false
	local headshot_multiplier = 1

	if attack_data.attacker_unit == managers.player:player_unit() then
		local critical_hit, crit_damage = self:roll_critical_hit(attack_data)

		if critical_hit then
			damage = crit_damage
			attack_data.critical_hit = true

			if damage > 0 then
				managers.hud:on_crit_confirmed()
			end
		else
			if damage > 0 then --just in case
				managers.hud:on_hit_confirmed()
			end
		end

		headshot_multiplier = managers.player:upgrade_value("weapon", "passive_headshot_damage_multiplier", 1)

		if tweak_data.character[self._unit:base()._tweak_table].priority_shout then
			damage = damage * managers.player:upgrade_value("weapon", "special_damage_taken_multiplier", 1)
		end

		if head then
			managers.player:on_headshot_dealt()

			headshot = true
		end
	end

	if not self._damage_reduction_multiplier and head then
		if self._char_tweak.headshot_dmg_mul then
			damage = damage * self._char_tweak.headshot_dmg_mul * headshot_multiplier
		else
			damage = self._health * 10
		end
	end

	if not head and attack_data.weapon_unit:base().get_add_head_shot_mul then
		if self._char_tweak and not self._unit:base():has_tag("tank") and self._char_tweak.headshot_dmg_mul and not self._char_tweak.ignore_headshot then
			local add_head_shot_mul = attack_data.weapon_unit:base():get_add_head_shot_mul()

			if add_head_shot_mul then
				local tweak_headshot_mul = math.max(0, self._char_tweak.headshot_dmg_mul - 1)
				local mul = tweak_headshot_mul * add_head_shot_mul + 1
				damage = damage * mul
			end
		end
	end

	--proper stealth insta-killing and damage clamping (the latter won't interfere for insta-kills)
	if self._unit:movement():cool() and self._unit:base():char_tweak()["stealth_instant_kill"] then
		damage = self._HEALTH_INIT
	else
		if self._unit:base():char_tweak().DAMAGE_CLAMP_BULLET then
			damage = math.min(damage, self._unit:base():char_tweak().DAMAGE_CLAMP_BULLET)
		end
	end
		
	damage = self:_apply_damage_reduction(damage)
	attack_data.raw_damage = damage
	attack_data.headshot = head
	local damage_percent = math.ceil(math.clamp(damage / self._HEALTH_INIT_PRECENT, 1, self._HEALTH_GRANULARITY))
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		if self:check_medic_heal() then
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			if head then
				managers.player:on_lethal_headshot_dealt(attack_data.attacker_unit, attack_data)

				if math.random(10) < damage then
					self:_spawn_head_gadget({
						position = attack_data.col_ray.body:position(),
						rotation = attack_data.col_ray.body:rotation(),
						dir = attack_data.col_ray.ray
					})
				end
			end

			attack_data.damage = self._health
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
			self:chk_killshot(attack_data.attacker_unit, "bullet", headshot)
		end
	else
		attack_data.damage = damage
		--proper redirecting for hurt animations against shield units, using "expl_hurt" for Shields instead of "shield_knock" for more variety (plus it works with directions to produce different animations)
		local result_type = not self._char_tweak.immune_to_knock_down and (attack_data.knock_down and "knock_down" or attack_data.stagger and not self._has_been_staggered and "stagger") or self:get_damage_type(damage_percent, "bullet")

		if (result_type == "knock_down" or result_type == "stagger") and alive(self._unit:inventory() and self._unit:inventory()._shield_unit) then
			local can_be_shield_knocked = not self._unit:base().is_phalanx and self._char_tweak.damage.shield_knocked and not self:is_immune_to_shield_knockback()

			if can_be_shield_knocked then
				if result_type == "stagger" then
					shield_stagger = true
				end

				result_type = "expl_hurt"
			end
		end

		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position

	local shotgun_push = nil
	local distance = nil

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			head_shot = head,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant
		}

		
		
		if data.head_shot and data.name == "deathvox_grenadier" then
			self._unit:damage():run_sequence_simple("grenadier_glass_break")
		end
		
		if managers.groupai:state():all_criminals()[attack_data.attacker_unit:key()] then
			managers.statistics:killed_by_anyone(data)
		end

		if attack_data.attacker_unit == managers.player:player_unit() then
			local special_comment = self:_check_special_death_conditions(attack_data.variant, attack_data.col_ray.body, attack_data.attacker_unit, attack_data.weapon_unit)

			self:_comment_death(attack_data.attacker_unit, self._unit, special_comment)
			self:_show_death_hint(self._unit:base()._tweak_table)

			local attacker_state = managers.player:current_state()
			data.attacker_state = attacker_state

			managers.statistics:killed(data)
			self:_check_damage_achievements(attack_data, head)

			if not is_civilian and managers.player:has_category_upgrade("temporary", "overkill_damage_multiplier") and not attack_data.weapon_unit:base().thrower_unit and attack_data.weapon_unit:base():is_category("shotgun", "saw") then
				managers.player:activate_temporary_upgrade("temporary", "overkill_damage_multiplier")
			end

			if is_civilian then
				managers.money:civilian_killed()
			end
		elseif attack_data.attacker_unit:base().sentry_gun then
			if Network:is_server() then
				local server_info = attack_data.weapon_unit:base():server_information()

				if server_info and server_info.owner_peer_id ~= managers.network:session():local_peer():id() then
					local owner_peer = managers.network:session():peer(server_info.owner_peer_id)

					if owner_peer then
						owner_peer:send_queued_sync("sync_player_kill_statistic", data.name, data.head_shot and true or false, data.weapon_unit, data.variant, data.stats_name)
					end
				else
					data.attacker_state = managers.player:current_state()

					managers.statistics:killed(data)
				end
			end

			local sentry_attack_data = deep_clone(attack_data)
			sentry_attack_data.attacker_unit = attack_data.attacker_unit:base():get_owner()

			if sentry_attack_data.attacker_unit == managers.player:player_unit() then
				self:_check_damage_achievements(sentry_attack_data, head)
			else
				self._unit:network():send("sync_damage_achievements", sentry_attack_data.weapon_unit, sentry_attack_data.attacker_unit, sentry_attack_data.damage, sentry_attack_data.col_ray and sentry_attack_data.col_ray.distance, head)
			end
		else
			if managers.groupai:state():is_unit_team_AI(attack_data.attacker_unit) then
				local special_comment = self:_check_special_death_conditions(attack_data.variant, attack_data.col_ray.body, attack_data.attacker_unit, attack_data.weapon_unit) --allow Bodhi to destroy Tasers' heads

				self:_AI_comment_death(attack_data.attacker_unit, self._unit, special_comment)
			end

			distance = mvector3.distance(attack_data.origin, attack_data.col_ray.position)

			if not attack_data.weapon_unit:base().thrower_unit and attack_data.weapon_unit:base():is_category("shotgun") and distance and distance < ((attack_data.attacker_unit:base() and attack_data.attacker_unit:base().is_husk_player or managers.groupai:state():is_unit_team_AI(attack_data.attacker_unit)) and managers.game_play_central:get_shotgun_push_range() or 500) then
				shotgun_push = true
			end
		end
	end

	local hit_offset_height = math.clamp(attack_data.col_ray.position.z - self._unit:movement():m_pos().z, 0, 300)
	local attacker = attack_data.attacker_unit

	if attacker:id() == -1 then
		attacker = self._unit
	end

	local weapon_unit = attack_data.weapon_unit

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", attacker, damage_percent)
	end

	local variant = nil

	if result.type == "knock_down" then
		variant = 1
	elseif result.type == "stagger" then
		variant = 2
		self._has_been_staggered = true
	elseif result.type == "healed" then
		variant = 3
	elseif result.type == "expl_hurt" then
		variant = 4

		if shield_stagger then
			self._has_been_staggered = true
		end
	elseif result.type == "hurt" then
		variant = 5
	elseif result.type == "heavy_hurt" then
		variant = 6
	elseif result.type == "light_hurt" then
		variant = 7
	elseif result.type == "dmg_rcv" then --important, need to sync if there's no reaction
		variant = 8
	else
		variant = 0
	end

	self:_send_bullet_attack_result(attack_data, attacker, damage_percent, body_index, hit_offset_height, variant)
	self:_on_damage_received(attack_data)

	if shotgun_push then
		managers.game_play_central:_do_shotgun_push(self._unit, attack_data.col_ray.position, attack_data.col_ray.ray, distance, attack_data.attacker_unit)
	end

	result.attack_data = attack_data
	
	return result
end
function CopDamage:die(attack_data)
	if self._immortal then
		debug_pause("Immortal character died!")
	end

	local variant = attack_data.variant

	self:_check_friend_4(attack_data)
	CopDamage.MAD_3_ACHIEVEMENT(attack_data)
	self:_remove_debug_gui()
	self._unit:base():set_slot(self._unit, 17)

	if alive(managers.interaction:active_unit()) then
		managers.interaction:active_unit():interaction():selected()
	end

	self:drop_pickup()
	self._unit:inventory():drop_shield()

	if self._unit:unit_data().mission_element then
		self._unit:unit_data().mission_element:event("death", self._unit)

		if not self._unit:unit_data().alerted_event_called then
			self._unit:unit_data().alerted_event_called = true

			self._unit:unit_data().mission_element:event("alerted", self._unit)
		end
	end

	if self._unit:movement() then
		self._unit:movement():remove_giveaway()
	end

	variant = variant or "bullet"
	self._health = 0
	self._health_ratio = 0
	self._dead = true

	self:set_mover_collision_state(false)

	if self._death_sequence then
		if self._unit:damage() and self._unit:damage():has_sequence(self._death_sequence) then
			self._unit:damage():run_sequence_simple(self._death_sequence)
		else
			debug_pause_unit(self._unit, "[CopDamage:die] does not have death sequence", self._death_sequence, self._unit)
		end
	end

	if self._unit:base():has_tag("spooc") then
		if self._unit:base():char_tweak().die_sound_event then
			self._unit:sound():play(self._unit:base():char_tweak().die_sound_event, nil, nil) --ensure that spoocs stop their looping presence sound
		end

		--if not self._unit:movement():cool() then --optional, to reinforce the idea of silent kills if desired
			self._unit:sound():say("x02a_any_3p", nil, nil) --death voiceline, can't use char_tweak().die_sound_event since spoocs have the presence loop stop there (this ensures both are played, unlike in vanilla)
		--end
	else
		--if not self._unit:movement():cool() then
		if self._unit:base():char_tweak().die_sound_event then
			self._unit:sound():say(self._unit:base():char_tweak().die_sound_event or "x02a_any_3p", nil, nil) --death voiceline determined through char_tweak().die_sound_event, otherwise use default
		end
		--end
	end
	
	if self._unit:base().looping_voice then
		self._unit:base().looping_voice:set_looping(false)
		self._unit:base().looping_voice:stop()
		self._unit:base().looping_voice:close()
		self._unit:base().looping_voice = nil
	end
	if self._unit:base():char_tweak().ends_assault_on_death then
		-- this was a bad idea
		--[[for u_key, u_data in pairs(managers.enemy:all_enemies()) do
			if alive(u_data.unit) then
				local action_data = {
					variant = "fire",
					damage = u_data.unit:character_damage()._HEALTH_INIT,
					weapon_unit = nil,
					attacker_unit = nil,
					col_ray = {unit = u_data.unit},
					is_fire_dot_damage = true,
					is_molotov = false
				}
				u_data.unit:character_damage():damage_fire(action_data)
			end
		end]]--
		managers.fire:_remove_hell_fire_from_all()
		managers.groupai:state():unregister_phalanx_vip(self._unit)
		managers.groupai:state():force_end_assault_phase()
		managers.hud:set_buff_enabled("vip", false)
	end
	managers.fire:_remove_hell_fire(self._unit)
	self:_on_death()
	managers.mutators:notify(Message.OnCopDamageDeath, self, attack_data)

	--report enemy deaths when not in stealth and when instantly killing enemies without alerting them
	if not managers.groupai:state():whisper_mode() and not CopDamage.is_civilian(self._unit:base()._tweak_table) then
		if attack_data.attacker_unit and alive(attack_data.attacker_unit) then
			if managers.groupai:state():all_criminals()[attack_data.attacker_unit:key()] then
				managers.groupai:state():report_aggression(attack_data.attacker_unit)
			end
		end
	end
end

function CopDamage:damage_tase(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	if PlayerDamage.is_friendly_fire(self, attack_data.attacker_unit) then
		return "friendly_fire"
	end

	if alive(managers.groupai:state():phalanx_vip()) then
		return
	end

	local result = nil
	local damage = attack_data.damage
	--local head = self._head_body_name and not self._unit:in_slot(16) and not self._char_tweak.ignore_headshot and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name

	damage = self:_apply_damage_reduction(damage)
	damage = math.clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._health <= damage then
		attack_data.damage = self._health
		result = {
			variant = "bullet",
			type = "death"
		}

		self:die(attack_data)
		self:chk_killshot(attack_data.attacker_unit, "tase")

		--[[if head then
			local body = self._unit:body(self._head_body_name)

			self:_spawn_head_gadget({
				position = body:position(),
				rotation = body:rotation(),
				dir = -attack_data.col_ray.ray
			})
		end]]
	else
		attack_data.damage = damage
		result = {
			type = "none",
			variant = attack_data.variant
		}

		if self._char_tweak.damage.hurt_severity.tase == nil or self._char_tweak.damage.hurt_severity.tase then
			if attack_data.attacker_unit == managers.player:player_unit() then
				if attack_data.weapon_unit then
					managers.hud:on_hit_confirmed()
				end
			end

			if self._unit:base():has_tag("shield") then
				result.type = "taser_tased"
			else
				if self._char_tweak.damage and self._char_tweak.damage.tased_response then
					if attack_data.variant == "heavy" and self._char_tweak.damage.tased_response.heavy then
						self._tased_time = self._char_tweak.damage.tased_response.heavy.tased_time
						self._tased_down_time = self._char_tweak.damage.tased_response.heavy.down_time
						result.variant = "heavy"
					elseif self._char_tweak.damage.tased_response.light then
						self._tased_time = self._char_tweak.damage.tased_response.light.tased_time
						self._tased_down_time = self._char_tweak.damage.tased_response.light.down_time
						result.variant = "light"
					else
						self._tased_time = 5
						self._tased_down_time = 10
						result.variant = nil
					end
				end

				result.type = "hurt"
				attack_data.variant = "tase"
			end
		end

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			owner = attack_data.owner,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant,
			head_shot = head
		}

		managers.statistics:killed_by_anyone(data)

		local attacker_unit = attack_data.attacker_unit

		if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			data.weapon_unit = attack_data.attacker_unit
		end

		if attacker_unit == managers.player:player_unit() then
			if alive(attacker_unit) then
				self:_comment_death(attacker_unit, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if CopDamage.is_civilian(self._unit:base()._tweak_table) then
				managers.money:civilian_killed()
			end

			self:_check_damage_achievements(attack_data, false)
		else
			if attacker_unit and alive(attacker_unit) and managers.groupai:state():is_unit_team_AI(attacker_unit) then
				self:_AI_comment_death(attacker_unit, self._unit)
			end
		end
	end

	local attacker = attack_data.attacker_unit

	if not attacker or attacker and alive(attacker) and attacker:id() == -1 then
		attack_data.attacker_unit = self._unit
	end

	local weapon_unit = attack_data.weapon_unit

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", damage_percent)
	end

	local variant = nil

	if result.type == "hurt" and attack_data.variant == "tase" then
		if result.variant == "heavy" then
			variant = 1
		elseif result.variant == "light" then
			variant = 2
		else
			variant = 3
		end
	elseif result.type == "taser_tased" then
		variant = 4
	else
		variant = 0
	end

	self:_send_tase_attack_result(attack_data, damage_percent, variant)
	self:_on_damage_received(attack_data)

	return result
end

function CopDamage:sync_damage_tase(attacker_unit, damage_percent, variant, death)
	if self._dead then
		return
	end

	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local attack_data = {
		attacker_unit = attacker_unit,
		variant = variant
	}
	local result = nil

	if death then
		result = {
			variant = "bullet",
			type = "death"
		}

		self:die("bullet")
		self:chk_killshot(attacker_unit, "tase")

		local data = {
			variant = "melee",
			head_shot = false,
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name
		}

		managers.statistics:killed_by_anyone(data)
	else
		local result_type = nil

		if variant == 1 then
			result_type = "hurt"
			attack_data.variant = "tase"
			self._tased_time = self._char_tweak.damage.tased_response.heavy.tased_time
			self._tased_down_time = self._char_tweak.damage.tased_response.heavy.down_time
		elseif variant == 2 then
			result_type = "hurt"
			attack_data.variant = "tase"
			self._tased_time = self._char_tweak.damage.tased_response.light.tased_time
			self._tased_down_time = self._char_tweak.damage.tased_response.light.down_time
		elseif variant == 3 then
			result_type = "hurt"
			attack_data.variant = "tase"
			self._tased_time = 5
			self._tased_down_time = 10
		elseif variant == 4 then
			result_type = "taser_tased"
		else
			result_type = "none"
		end

		result = {
			type = result_type
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.damage = damage
	attack_data.is_synced = true
	local attack_dir = nil

	if attacker_unit then
		attack_dir = self._unit:position() - attacker_unit:position()

		mvector3.normalize(attack_dir)
	else
		attack_dir = -self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir
	attack_data.pos = self._unit:position()

	mvector3.set_z(attack_data.pos, attack_data.pos.z + math.random() * 180)
	self:_send_sync_tase_attack_result(attack_data)
	self:_on_damage_received(attack_data)
end

function CopDamage:stun_hit(attack_data)
	local anim_data = self._unit:anim_data()

	if self._dead or self._invulnerable or (anim_data and (anim_data.act or anim_data.surrender or anim_data.hands_back or anim_data.hands_tied)) then --dead, invulnerable, is acting or is intimidated
		return
	end

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)
	local attacker = attack_data.attacker_unit
	local valid_attacker = attacker and alive(attacker) and attacker.base and attacker:base() and attacker.movement and attacker:movement() --with how user/owner assigning works with grenades, just gotta make sure

	if not is_civilian and valid_attacker and self:is_friendly_fire(attacker) then --do not stun teammates and affect civilians regardless so that they drop the ground (even if that's clunky, I might rewrite it)
		return "friendly_fire"
	end

	local result = {
		type = "concussion",
		variant = attack_data.variant
	}
	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position
	local damage_percent = 0

	self:_send_stun_attack_result(attacker, damage_percent, self:_get_attack_variant_index(attack_data.result.variant), attack_data.col_ray.ray)
	self:_on_damage_received(attack_data)
	self:_create_stun_exit_clbk()

	return result
end

function CopDamage:sync_damage_stun(attacker_unit, damage_percent, i_attack_variant, death, direction)
	if self._dead then
		return
	end

	local variant = CopDamage._ATTACK_VARIANTS[i_attack_variant]
	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local attack_data = {
		variant = variant,
		attacker_unit = attacker_unit
	}
	local result = nil
	local result_type = "concussion"
	result = {
		type = result_type,
		variant = variant
	}
	attack_data.result = result
	attack_data.damage = damage
	attack_data.is_synced = true
	local attack_dir = nil

	if direction then
		attack_dir = direction
	elseif attacker_unit then
		attack_dir = self._unit:position() - attacker_unit:position()

		mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir

	if attack_data.attacker_unit and alive(attack_data.attacker_unit) and attack_data.attacker_unit == managers.player:player_unit() then
		if damage > 0 then
			managers.hud:on_hit_confirmed()
		end
	end

	attack_data.pos = self._unit:position()

	mvector3.set_z(attack_data.pos, attack_data.pos.z + math.random() * 180)
	self:_on_damage_received(attack_data)
	self:_create_stun_exit_clbk()
end

function CopDamage:get_damage_type(damage_percent, category)
	local hurt_table = self._char_tweak.damage.hurt_severity[category or "bullet"]
	if alive(managers.groupai:state():phalanx_vip()) then
		local table_to_use = {
			tase = false,
			bullet = {
				health_reference = 1,
				zones = {{none = 1}}
			},
			explosion = {
				health_reference = 1,
				zones = {{none = 1}}
			},
			melee = {
				health_reference = 1,
				zones = {{none = 1}}
			},
			fire = {
				health_reference = 1,
				zones = {{none = 1}}
			},
			poison = {
				health_reference = 1,
				zones = {{none = 1}}
			}
		}
		hurt_table = table_to_use[category or "bullet"]
	end

	local dmg = damage_percent / self._HEALTH_GRANULARITY

	if hurt_table.health_reference == "full" then
		-- Nothing
	else
		dmg = hurt_table.health_reference == "current" and math.min(1, (self._HEALTH_INIT * dmg) / self._health) or math.min(1, (self._HEALTH_INIT * dmg) / hurt_table.health_reference)
	end

	local zone = nil

	for i_zone, test_zone in ipairs(hurt_table.zones) do
		if i_zone == #hurt_table.zones or dmg < test_zone.health_limit then
			zone = test_zone

			break
		end
	end

	local rand_nr = math.random()
	local total_w = 0

	for sev_name, hurt_type in pairs(self._hurt_severities) do
		local weight = zone[sev_name]

		if weight and weight > 0 then
			total_w = total_w + weight

			if rand_nr <= total_w then
				return hurt_type or "dmg_rcv"
			end
		end
	end

	return "dmg_rcv"
end

function CopDamage:_on_damage_received(damage_info)
	--self:build_suppression("max", nil) --yes let's make threat completely pointless
	self:_call_listeners(damage_info)
	CopDamage._notify_listeners("on_damage", damage_info)

	if damage_info.result.type == "death" then
		managers.enemy:on_enemy_died(self._unit, damage_info)

		for c_key, c_data in pairs(managers.groupai:state():all_char_criminals()) do
			if c_data.engaged[self._unit:key()] then
				debug_pause_unit(self._unit:key(), "dead AI engaging player", self._unit, c_data.unit)
			end
		end
	end

	if self._dead and self._unit:movement():attention() then
		debug_pause_unit(self._unit, "[CopDamage:_on_damage_received] dead AI", self._unit, inspect(self._unit:movement():attention()))
	end

	local attacker_unit = damage_info and damage_info.attacker_unit

	if alive(attacker_unit) and attacker_unit:base() then
		if attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
		elseif attacker_unit:base().sentry_gun then
			attacker_unit = attacker_unit:base():get_owner()
		end
	end

	if attacker_unit == managers.player:player_unit() and damage_info then
		managers.player:on_damage_dealt(self._unit, damage_info)
	end

	if damage_info.variant == "melee" then
		managers.statistics:register_melee_hit()
	end

	self:_update_debug_ws(damage_info)
end

function CopDamage:sync_damage_bullet(attacker_unit, damage_percent, i_body, hit_offset_height, variant, death)
	if self._dead then
		return
	end

	local body = self._unit:body(i_body)
	local head = self._head_body_name and not self._unit:in_slot(16) and not self._char_tweak.ignore_headshot and body and body:name() == self._ids_head_body_name
	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local attack_data = {}
	local hit_pos = mvector3.copy(self._unit:movement():m_pos())

	mvector3.set_z(hit_pos, hit_pos.z + hit_offset_height)

	attack_data.pos = hit_pos
	attack_data.attacker_unit = attacker_unit
	attack_data.variant = "bullet"
	local attack_dir, distance = nil

	if attacker_unit then
		attack_dir = hit_pos - attacker_unit:movement():m_head_pos()
		distance = mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir
	local shotgun_push, result = nil

	if death then
		if head and math.random(10) < damage then
			self:_spawn_head_gadget({
				position = body:position(),
				rotation = body:rotation(),
				dir = attack_dir
			})
		end

		if head and self._unit:base()._tweak_table == "deathvox_grenadier" then --this wasn't synced before, just noticed
			self._unit:damage():run_sequence_simple("grenadier_glass_break")
		end

		result = {
			variant = "bullet",
			type = "death"
		}

		self:die(attack_data)
		self:chk_killshot(attacker_unit, "bullet")

		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			head_shot = head,
			weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit(),
			variant = attack_data.variant
		}

		if data.weapon_unit then
			self:_check_special_death_conditions("bullet", body, attacker_unit, data.weapon_unit)
			managers.statistics:killed_by_anyone(data)

			if not data.weapon_unit:base().thrower_unit and data.weapon_unit:base():is_category("shotgun") and distance and distance < ((attacker_unit:base() and attacker_unit:base().is_husk_player or managers.groupai:state():is_unit_team_AI(attacker_unit)) and managers.game_play_central:get_shotgun_push_range() or 500) then
				shotgun_push = true
			end
		end
	else
		local result_type = nil

		if variant == 1 then
			result_type = "knock_down"
		elseif variant == 2 then
			result_type = "stagger"
		elseif variant == 4 then
			result_type = "expl_hurt"
		elseif variant == 5 then
			result_type = "hurt"
		elseif variant == 6 then
			result_type = "heavy_hurt"
		elseif variant == 7 then
			result_type = "light_hurt"
		elseif variant == 8 then
			result_type = "dmg_rcv" --important, need to sync if there's no reaction
		else
			result_type = self:get_damage_type(damage_percent, "bullet") --to fall back in case other peers don't have the modified code
		end

		if variant == 3 then
			result_type = "healed"
		end

		result = {
			variant = "bullet",
			type = result_type
		}

		if result_type ~= "healed" then
			self:_apply_damage_to_health(damage)
		end
	end

	attack_data.variant = "bullet"
	attack_data.attacker_unit = attacker_unit
	attack_data.result = result
	attack_data.damage = damage
	attack_data.is_synced = true

	if not self._no_blood and damage > 0 then
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	self:_send_sync_bullet_attack_result(attack_data, hit_offset_height)
	self:_on_damage_received(attack_data)

	if shotgun_push then
		managers.game_play_central:_do_shotgun_push(self._unit, hit_pos, attack_dir, distance, attacker_unit)
	end
end

function CopDamage:damage_melee(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	if PlayerDamage.is_friendly_fire(self, attack_data.attacker_unit) then
		return "friendly_fire"
	end

	local result = nil
	local is_civlian = CopDamage.is_civilian(self._unit:base()._tweak_table)
	local is_gangster = CopDamage.is_gangster(self._unit:base()._tweak_table)
	local is_cop = not is_civlian and not is_gangster
	local head = self._head_body_name and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name
	local damage = attack_data.damage

	if attack_data.attacker_unit and attack_data.attacker_unit == managers.player:player_unit() then
		local critical_hit, crit_damage = self:roll_critical_hit(attack_data)

		if critical_hit then
			damage = crit_damage
			attack_data.critical_hit = true

			if damage > 0 then
				managers.hud:on_crit_confirmed()
			end
		else
			if damage > 0 then --no more hit marker when countering attacks or knocking shields around
				managers.hud:on_hit_confirmed()
			end
		end

		if tweak_data.achievement.cavity.melee_type == attack_data.name_id and not CopDamage.is_civilian(self._unit:base()._tweak_table) then
			managers.achievment:award(tweak_data.achievement.cavity.award)
		end
	end

	damage = damage * (self._marked_dmg_mul or 1)

	if self._unit:movement():cool() then --since damage_melee wasn't a thing here, I'm assuming the stealth instant kill check that CD has is intended only for bullets?
		damage = self._HEALTH_INIT
	else
		if self._unit:base():char_tweak().DAMAGE_CLAMP_MELEE then --adding it while I'm at it in case it's needed for some reason
			damage = math.min(damage, self._unit:base():char_tweak().DAMAGE_CLAMP_MELEE)
		end
	end

	local damage_effect = attack_data.damage_effect
	local damage_effect_percent = nil
	damage = self:_apply_damage_reduction(damage)
	damage = math.clamp(damage, self._HEALTH_INIT_PRECENT, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		if self:check_medic_heal() then
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			if head then
				self:_spawn_head_gadget({
					position = attack_data.col_ray.body:position(),
					rotation = attack_data.col_ray.body:rotation(),
					dir = attack_data.col_ray.ray
				})
			end

			damage_effect_percent = 1
			attack_data.damage = self._health
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
			self:chk_killshot(attack_data.attacker_unit, "melee")
		end
	else
		attack_data.damage = damage
		damage_effect = math.clamp(damage_effect, self._HEALTH_INIT_PRECENT, self._HEALTH_INIT)
		damage_effect_percent = math.ceil(damage_effect / self._HEALTH_INIT_PRECENT)
		damage_effect_percent = math.clamp(damage_effect_percent, 1, self._HEALTH_GRANULARITY)
		--proper hurt animation redirect and checking, like with bullet damage
		local result_type = attack_data.shield_knock and self._char_tweak.damage.shield_knocked and not self._unit:base().is_phalanx and "shield_knock" or attack_data.variant == "counter_tased" and "counter_tased" or attack_data.variant == "taser_tased" and (self._char_tweak.can_be_tased == nil or self._char_tweak.can_be_tased) and "taser_tased" or attack_data.variant == "counter_spooc" and (not self._unit:base():has_tag("tank") and not self._unit:base():has_tag("boss")) and "expl_hurt" or self:get_damage_type(damage_effect_percent, "melee") or "dmg_rcv"
		local variant = attack_data.variant

		if result_type == "taser_tased" and not self._unit:base():has_tag("shield") then --shields get tased as usual, other enemies get tased similarly to bots
			result_type = "hurt"
			variant = nil
			attack_data.variant = "tase"

			if attack_data.charge_lerp_value then
				local charge_power = math.lerp(0, 1, attack_data.charge_lerp_value)

				damage_effect_percent = charge_power
				self._tased_time = math.lerp(1, 5, charge_power)
				self._tased_down_time = self._tased_time * 2
			else
				damage_effect_percent = 0.4 --used for syncing purposes
				self._tased_time = 2
				self._tased_down_time = self._tased_time * 2
			end
		end

		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position
	local snatch_pager = false

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			head_shot = head,
			weapon_unit = attack_data.weapon_unit,
			name_id = attack_data.name_id,
			variant = attack_data.variant
		}

		managers.statistics:killed_by_anyone(data)

		if attack_data.attacker_unit == managers.player:player_unit() then
			local special_comment = self:_check_special_death_conditions(attack_data.variant, attack_data.col_ray.body, attack_data.attacker_unit, attack_data.name_id)

			self:_comment_death(attack_data.attacker_unit, self._unit, special_comment)
			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if not is_civlian and managers.groupai:state():whisper_mode() and managers.blackmarket:equipped_mask().mask_id == tweak_data.achievement.cant_hear_you_scream.mask then
				managers.achievment:award_progress(tweak_data.achievement.cant_hear_you_scream.stat)
			end

			if is_cop and Global.game_settings.level_id == "nightclub" and attack_data.name_id and attack_data.name_id == "fists" then
				managers.achievment:award_progress(tweak_data.achievement.final_rule.stat)
			end

			if is_civlian then
				managers.money:civilian_killed()
			end
		elseif managers.groupai:state():is_unit_team_AI(attack_data.attacker_unit) then
			local special_comment = self:_check_special_death_conditions(attack_data.variant, attack_data.col_ray.body, attack_data.attacker_unit, attack_data.name_id)

			self:_AI_comment_death(attack_data.attacker_unit, self._unit, special_comment)
		end
	end

	if tweak_data.blackmarket.melee_weapons[attack_data.name_id] then
		local achievements = tweak_data.achievement.enemy_melee_hit_achievements or {}
		local melee_type = tweak_data.blackmarket.melee_weapons[attack_data.name_id].type
		local enemy_base = self._unit:base()
		local enemy_movement = self._unit:movement()
		local enemy_type = enemy_base._tweak_table
		local unit_weapon = enemy_base._default_weapon_id
		local health_ratio = managers.player:player_unit():character_damage():health_ratio() * 100
		local melee_pass, melee_weapons_pass, type_pass, enemy_pass, enemy_weapon_pass, diff_pass, health_pass, level_pass, job_pass, jobs_pass, enemy_count_pass, tags_all_pass, tags_any_pass, all_pass, cop_pass, gangster_pass, civilian_pass, stealth_pass, on_fire_pass, behind_pass, result_pass, mutators_pass, critical_pass, action_pass, is_dropin_pass = nil

		for achievement, achievement_data in pairs(achievements) do
			melee_pass = not achievement_data.melee_id or achievement_data.melee_id == attack_data.name_id
			melee_weapons_pass = not achievement_data.melee_weapons or table.contains(achievement_data.melee_weapons, attack_data.name_id)
			type_pass = not achievement_data.melee_type or melee_type == achievement_data.melee_type
			result_pass = not achievement_data.result or attack_data.result.type == achievement_data.result
			enemy_pass = not achievement_data.enemy or enemy_type == achievement_data.enemy
			enemy_weapon_pass = not achievement_data.enemy_weapon or unit_weapon == achievement_data.enemy_weapon
			behind_pass = not achievement_data.from_behind or from_behind
			diff_pass = not achievement_data.difficulty or table.contains(achievement_data.difficulty, Global.game_settings.difficulty)
			health_pass = not achievement_data.health or health_ratio <= achievement_data.health
			level_pass = not achievement_data.level_id or (managers.job:current_level_id() or "") == achievement_data.level_id
			job_pass = not achievement_data.job or managers.job:current_real_job_id() == achievement_data.job
			jobs_pass = not achievement_data.jobs or table.contains(achievement_data.jobs, managers.job:current_real_job_id())
			enemy_count_pass = not achievement_data.enemy_kills or achievement_data.enemy_kills.count <= managers.statistics:session_enemy_killed_by_type(achievement_data.enemy_kills.enemy, "melee")
			tags_all_pass = not achievement_data.enemy_tags_all or enemy_base:has_all_tags(achievement_data.enemy_tags_all)
			tags_any_pass = not achievement_data.enemy_tags_any or enemy_base:has_any_tag(achievement_data.enemy_tags_any)
			cop_pass = not achievement_data.is_cop or is_cop
			gangster_pass = not achievement_data.is_gangster or is_gangster
			civilian_pass = not achievement_data.is_not_civilian or not is_civlian
			stealth_pass = not achievement_data.is_stealth or managers.groupai:state():whisper_mode()
			on_fire_pass = not achievement_data.is_on_fire or managers.fire:is_set_on_fire(self._unit)
			is_dropin_pass = achievement_data.is_dropin == nil or achievement_data.is_dropin == managers.statistics:is_dropin()

			if achievement_data.enemies then
				enemy_pass = false

				for _, enemy in pairs(achievement_data.enemies) do
					if enemy == enemy_type then
						enemy_pass = true

						break
					end
				end
			end

			mutators_pass = managers.mutators:check_achievements(achievement_data)
			critical_pass = not achievement_data.critical

			if achievement_data.critical then
				critical_pass = attack_data.critical_hit
			end

			action_pass = true

			if achievement_data.action then
				local action = enemy_movement:get_action(achievement_data.action.body_part)
				local action_type = action and action:type()
				action_pass = action_type == achievement_data.action.type
			end

			all_pass = melee_pass and melee_weapons_pass and type_pass and enemy_pass and enemy_weapon_pass and behind_pass and diff_pass and health_pass and level_pass and job_pass and jobs_pass and cop_pass and gangster_pass and civilian_pass and stealth_pass and on_fire_pass and enemy_count_pass and tags_all_pass and tags_any_pass and result_pass and mutators_pass and critical_pass and action_pass and is_dropin_pass

			if all_pass then
				if achievement_data.stat then
					managers.achievment:award_progress(achievement_data.stat)
				elseif achievement_data.award then
					managers.achievment:award(achievement_data.award)
				elseif achievement_data.challenge_stat then
					managers.challenge:award_progress(achievement_data.challenge_stat)
				elseif achievement_data.trophy_stat then
					managers.custom_safehouse:award(achievement_data.trophy_stat)
				elseif achievement_data.challenge_award then
					managers.challenge:award(achievement_data.challenge_award)
				end
			end
		end
	end

	local attacker = attack_data.attacker_unit

	if not attacker or attacker and alive(attacker) and attacker:id() == -1 then
		attack_data.attacker_unit = self._unit --needs testing online, but I'm almost sure the lack of these is what causes clients to crash normally
	end

	local hit_offset_height = math.clamp(attack_data.col_ray.position.z - self._unit:movement():m_pos().z, 0, 300)
	local variant = nil

	--all variants added to properly sync them, this can even be used with players that don't have the proper sync_damage_melee code as the vanilla numbers remain unchanged
	if result.type == "shield_knock" then
		variant = 1
	elseif result.type == "counter_tased" then
		variant = 2
	elseif result.type == "expl_hurt" then
		variant = 4
	elseif snatch_pager then
		variant = 3
	elseif result.type == "taser_tased" then
		variant = 5
	--[[elseif dismember_victim then
		variant = 6]]
	elseif result.type == "hurt" then
		if result.variant == "tase" then
			variant = 8
		else
			variant = 9
		end
	elseif result.type == "heavy_hurt" then
		variant = 10
	elseif result.type == "light_hurt" then
		variant = 11
	elseif result.type == "dmg_rcv" then --important, need to sync if there's no reaction
		variant = 12
	elseif result.type == "healed" then
		variant = 7
	else
		variant = 0
	end

	local body_index = self._unit:get_body_index(attack_data.col_ray.body:name())

	self:_send_melee_attack_result(attack_data, damage_percent, damage_effect_percent, hit_offset_height, variant, body_index)
	self:_on_damage_received(attack_data)

	return result
end

function CopDamage:sync_damage_melee(attacker_unit, damage_percent, damage_effect_percent, i_body, hit_offset_height, variant, death)
	local attack_data = {
		variant = "melee",
		attacker_unit = attacker_unit
	}
	local body = self._unit:body(i_body)
	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local result = nil

	if death then
		local melee_name_id = nil
		local valid_attacker = attacker_unit and alive(attacker_unit) and attacker_unit:base()

		if valid_attacker then
			if attacker_unit:base().is_husk_player then
				local peer_id = managers.network:session():peer_by_unit(attacker_unit):id()
				local peer = managers.network:session():peer(peer_id)

				melee_name_id = peer:melee_id()
			else
				melee_name_id = attacker_unit:base().melee_weapon and attacker_unit:base():melee_weapon()
			end

			if melee_name_id then
				self:_check_special_death_conditions("melee", body, attacker_unit, melee_name_id)
			end
		end

		result = {
			variant = "melee",
			type = "death"
		}

		self:die(attack_data)
		self:chk_killshot(attacker_unit, "melee")

		local data = {
			variant = "melee",
			head_shot = false,
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name
		}

		managers.statistics:killed_by_anyone(data)
	else
		local result_type = nil

		if variant == 1 then
			result_type = "shield_knock"
		elseif variant == 2 then
			result_type = "counter_tased"
		elseif variant == 4 then
			result_type = "expl_hurt"
		elseif variant == 5 then
			result_type = "taser_tased"
		elseif variant == 8 or variant == 9 then
			result_type = "hurt"

			if variant == 8 then
				self._tased_time = math.lerp(1, 5, damage_effect_percent)
				self._tased_down_time = self._tased_time * 2
			end
		elseif variant == 10 then
			result_type = "heavy_hurt"
		elseif variant == 11 then
			result_type = "light_hurt"
		elseif variant == 12 then
			result_type = "dmg_rcv" --important, need to sync if there's no reaction
		else
			result_type = self:get_damage_type(damage_effect_percent, "melee") --to fall back in case other peers don't have the modified code
		end

		if variant == 7 then
			result_type = "healed"
		end

		result = {
			variant = variant ~= 8 and "melee",
			type = result_type
		}

		if result_type ~= "healed" then --needs testing to see if something changed, don't know why only a few damage types have this and others don't, makes no sense
			self:_apply_damage_to_health(damage)
		end

		attack_data.variant = variant == 8 and "tase" or result_type
	end

	attack_data.result = result
	attack_data.damage = damage
	attack_data.is_synced = true
	local attack_dir = nil

	if attacker_unit then
		attack_dir = self._unit:position() - attacker_unit:position()

		mvector3.normalize(attack_dir)
	else
		attack_dir = -self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir

	if variant == 3 then
		self._unit:unit_data().has_alarm_pager = false
	end

	attack_data.pos = self._unit:position()

	mvector3.set_z(attack_data.pos, attack_data.pos.z + math.random() * 180)

	if not self._no_blood and damage > 0 then
		managers.game_play_central:sync_play_impact_flesh(self._unit:movement():m_pos() + Vector3(0, 0, hit_offset_height), attack_dir)
	end

	self:_send_sync_melee_attack_result(attack_data, hit_offset_height)
	self:_on_damage_received(attack_data)
end

function CopDamage:_check_special_death_conditions(variant, body, attacker_unit, weapon_unit)
	if not attacker_unit then
		return
	end

	if not alive(attacker_unit) then
		return
	end

	if not attacker_unit:base() then
		return
	end

	local special_deaths = self._unit:base():char_tweak().special_deaths --special deaths set in charactertweakdata

	if not special_deaths or not special_deaths[variant] then
		return
	end

	local body_data = special_deaths[variant][body:name():key()]

	if not body_data then
		return
	end

	if not managers.groupai:state():all_criminals()[attacker_unit:key()] then --is not a heister character
		return
	end

	local attacker_name = managers.criminals:character_name_by_unit(attacker_unit)

	if not body_data.character_name or body_data.character_name ~= attacker_name then
		return
	end

	local can_comment = Network:is_server() and managers.groupai:state():is_unit_team_AI(attacker_unit) or attacker_unit == managers.player:player_unit()

	if variant == "melee" then
		if body_data.melee_weapon_id and weapon_unit then
			if body_data.melee_weapon_id == weapon_unit then
				if self._unit:damage():has_sequence(body_data.sequence) then
					if body_data.sound_effect then
						self._unit:sound():play(body_data.sound_effect, nil, nil)
					end

					self._unit:damage():run_sequence_simple(body_data.sequence)

					if body_data.special_comment and can_comment then --local players or server bots sync the voiceline, no need to do this for husks
						return body_data.special_comment
					end
				end
			end
		end
	else
		if body_data.weapon_id and alive(weapon_unit) then
			local factory_id = weapon_unit:base()._factory_id --factory id, aka its unit id

			if not factory_id then
				return
			end

			if weapon_unit:base():is_npc() then --uses newnpcraycastweaponbase (so, bots and player husks)
				factory_id = utf8.sub(factory_id, 1, -5)
			end

			local weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(factory_id) --actual weapon id used in many files

			if body_data.weapon_id == weapon_id then
				if self._unit:damage():has_sequence(body_data.sequence) then
					self._unit:damage():run_sequence_simple(body_data.sequence)
				end

				if body_data.special_comment and can_comment then --local players or server bots sync the voiceline, no need to do this for husks
					return body_data.special_comment
				end
			end
		end
	end
end

function CopDamage:build_suppression(amount, panic_chance)
	if self._dead or self._invulnerable or self._unit:in_slot(16) or not self._char_tweak.suppression then --adding Jokers and invulnerable characters
		return
	end

	local t = TimerManager:game():time()
	local sup_tweak = self._char_tweak.suppression

	if panic_chance and (panic_chance == -1 or panic_chance > 0 and sup_tweak.panic_chance_mul > 0 and math.random() < panic_chance * sup_tweak.panic_chance_mul) then
		amount = "panic"
	end

	local amount_val = nil
	amount_val = (amount ~= "max" and amount ~= "panic" or sup_tweak.brown_point or sup_tweak.react_point[2]) and (Network:is_server() and self._suppression_hardness_t and t < self._suppression_hardness_t and amount * 0.5 or amount)

	if not Network:is_server() then
		local sync_amount = nil

		if amount == "panic" then
			sync_amount = 16
		elseif amount == "max" then
			sync_amount = 15
		else
			local sync_amount_ratio = nil

			if sup_tweak.brown_point then
				if sup_tweak.brown_point[2] <= 0 then
					sync_amount_ratio = 1
				else
					sync_amount_ratio = amount_val / sup_tweak.brown_point[2]
				end
			elseif sup_tweak.react_point[2] <= 0 then
				sync_amount_ratio = 1
			else
				sync_amount_ratio = amount_val / sup_tweak.react_point[2]
			end

			sync_amount = math.clamp(math.ceil(sync_amount_ratio * 15), 1, 15)
		end

		managers.network:session():send_to_host("suppression", self._unit, sync_amount)

		return
	end

	if self._suppression_data then
		self._suppression_data.value = math.min(self._suppression_data.brown_point or self._suppression_data.react_point, self._suppression_data.value + amount_val)
		self._suppression_data.last_build_t = t
		self._suppression_data.decay_t = t + self._suppression_data.duration

		managers.enemy:reschedule_delayed_clbk(self._suppression_data.decay_clbk_id, self._suppression_data.decay_t)
	else
		local duration = math.lerp(sup_tweak.duration[1], sup_tweak.duration[2], math.random())
		local decay_t = t + duration
		self._suppression_data = {
			value = amount_val,
			last_build_t = t,
			decay_t = decay_t,
			duration = duration,
			react_point = sup_tweak.react_point and math.lerp(sup_tweak.react_point[1], sup_tweak.react_point[2], math.random()),
			brown_point = sup_tweak.brown_point and math.lerp(sup_tweak.brown_point[1], sup_tweak.brown_point[2], math.random()),
			decay_clbk_id = "CopDamage_suppression" .. tostring(self._unit:key())
		}

		managers.enemy:add_delayed_clbk(self._suppression_data.decay_clbk_id, callback(self, self, "clbk_suppression_decay"), decay_t)
	end

	if not self._suppression_data.brown_zone and self._suppression_data.brown_point and self._suppression_data.brown_point <= self._suppression_data.value then
		self._suppression_data.brown_zone = true

		self._unit:brain():on_suppressed(amount == "panic" and "panic" or true)
	elseif amount == "panic" then
		self._unit:brain():on_suppressed("panic")
	end

	if not self._suppression_data.react_zone and self._suppression_data.react_point and self._suppression_data.react_point <= self._suppression_data.value then
		self._suppression_data.react_zone = true

		self._unit:movement():on_suppressed(amount == "panic" and "panic" or true)
	elseif amount == "panic" then
		self._unit:movement():on_suppressed("panic")
	end
end

function CopDamage:damage_fire(attack_data)
	local valid_attacker = attack_data.attacker_unit and alive(attack_data.attacker_unit)

	if self._dead or self._invulnerable then
		return
	end

	if valid_attacker and self:is_friendly_fire(attack_data.attacker_unit) then
		return "friendly_fire"
	end

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)

	local result = nil
	local damage = attack_data.damage

	if attack_data.attacker_unit == managers.player:player_unit() then
		if attack_data.weapon_unit and attack_data.variant ~= "stun" and not attack_data.is_fire_dot_damage then
			if damage > 0 then
				managers.hud:on_hit_confirmed()
			end
		end

		if tweak_data.character[self._unit:base()._tweak_table].priority_shout then
			damage = damage * managers.player:upgrade_value("weapon", "special_damage_taken_multiplier", 1)
		end
	end

	damage = damage * (self._char_tweak.damage.fire_damage_mul or 1)
	damage = damage * (self._marked_dmg_mul or 1)

	--HVT ace now also grants its bonus
	if not attack_data.is_fire_dot_damage and self._marked_dmg_mul and self._marked_dmg_dist_mul then
		local attacking_unit = attack_data.attacker_unit

		if attacking_unit and attacking_unit:base() and attacking_unit:base().thrower_unit then
			attacking_unit = attacking_unit:base():thrower_unit()
		end

		if alive(attacking_unit) then
			local dst = mvector3.distance(attacking_unit:position(), self._unit:position())
			local spott_dst = tweak_data.upgrades.values.player.marked_inc_dmg_distance[self._marked_dmg_dist_mul]

			if spott_dst[1] < dst then
				damage = damage * spott_dst[2]
			end
		end
	end

	if self._unit:base():char_tweak().DAMAGE_CLAMP_FIRE then
		damage = math.min(damage, self._unit:base():char_tweak().DAMAGE_CLAMP_FIRE)
	end

	damage = self:_apply_damage_reduction(damage)
	damage = math.clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		if self:check_medic_heal() then
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			attack_data.damage = self._health
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
			self:chk_killshot(attack_data.attacker_unit, "fire")
		end
	else
		attack_data.damage = damage
		local result_type = attack_data.variant == "stun" and "hurt_sick" or self:get_damage_type(damage_percent, "fire")
		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position

	local attacker_unit = attack_data.attacker_unit

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			owner = attack_data.owner,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant,
			head_shot = false,
			is_molotov = attack_data.is_molotov
		}

		managers.statistics:killed_by_anyone(data)

		if not is_civilian and managers.player:has_category_upgrade("temporary", "overkill_damage_multiplier") and attacker_unit == managers.player:player_unit() and alive(attack_data.weapon_unit) and not attack_data.weapon_unit:base().thrower_unit and attack_data.weapon_unit:base().is_category and attack_data.weapon_unit:base():is_category("shotgun", "saw") then
			managers.player:activate_temporary_upgrade("temporary", "overkill_damage_multiplier")
		end

		if attacker_unit and alive(attacker_unit) and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			data.weapon_unit = attack_data.attacker_unit
		end

		if attacker_unit == managers.player:player_unit() then
			if alive(attacker_unit) then
				self:_comment_death(attacker_unit, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if is_civilian then
				managers.money:civilian_killed()
			end

			self:_check_damage_achievements(attack_data, false)
		else
			if attacker_unit and alive(attacker_unit) and managers.groupai:state():is_unit_team_AI(attacker_unit) then
				self:_AI_comment_death(attacker_unit, self._unit)
			end
		end
	end

	local attacker = attack_data.attacker_unit

	if not attacker or attacker and alive(attacker) and attacker:id() == -1 then
		attacker = self._unit
	end

	local weapon_unit = attack_data.weapon_unit or attacker

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", damage_percent)
	end

	if not attack_data.is_fire_dot_damage then
		local fire_dot_data = attack_data.fire_dot_data
		local flammable = nil
		local char_tweak = tweak_data.character[self._unit:base()._tweak_table]

		if char_tweak.flammable == nil then
			flammable = true
		else
			flammable = char_tweak.flammable
		end

		local distance = 1000
		local hit_loc = attack_data.col_ray.hit_position

		if hit_loc and attacker_unit and attacker_unit.position then
			distance = mvector3.distance(hit_loc, attacker_unit:position())
		end

		local fire_dot_max_distance = 3000
		local fire_dot_trigger_chance = 30
		local dot_damage = fire_dot_data and fire_dot_data.dot_damage or 25

		if fire_dot_data then
			fire_dot_max_distance = tonumber(fire_dot_data.dot_trigger_max_distance)
			fire_dot_trigger_chance = tonumber(fire_dot_data.dot_trigger_chance)

			--optional DoT damage scaling based on the weapon and it's parts
			--[[if attack_data.attacker_unit and alive(attack_data.attacker_unit) and attack_data.attacker_unit:base()._grenade_entry == "molotov" or attack_data.is_molotov then
				--grenade, DoT unchanged
			elseif alive(attack_data.weapon_unit) and attack_data.weapon_unit:base()._name_id ~= nil and tweak_data.weapon[attack_data.weapon_unit:base()._name_id] ~= nil and tweak_data.weapon[attack_data.weapon_unit:base()._name_id].fire_dot_data ~= nil then
				local damage_modifier = 0

				for part_id, part in pairs(attack_data.weapon_unit:base()._parts) do
					damage_modifier = tweak_data.weapon.factory.parts[part_id].stats and tweak_data.weapon.factory.parts[part_id].stats.damage or damage_modifier
				end

				local weapon_damage = tweak_data.weapon[attack_data.weapon_unit:base()._name_id].stats.damage
				local damage = (weapon_damage + damage_modifier)
				dot_damage = (damage / dot_damage) * 100 --flamethrower, scale DoT damage depending on the base + mod weapon damage dealt through direct (impact) fire damage
				--usual dot_damage is 30
			elseif alive(attack_data.weapon_unit) and attack_data.weapon_unit:base()._parts then
				local damage_modifier = 0

				for part_id, part in pairs(attack_data.weapon_unit:base()._parts) do
					damage_modifier = tweak_data.weapon.factory.parts[part_id].stats and tweak_data.weapon.factory.parts[part_id].stats.damage or damage_modifier
				end

				local weapon_damage = tweak_data.weapon[attack_data.weapon_unit:base()._name_id].stats.damage
				local damage = (weapon_damage + damage_modifier) * 0.1
				dot_damage = dot_damage * damage * 0.1 --Dragon's Breath rounds, scale DoT damage depending on the base + mod weapon damage dealt through direct (impact) fire damage
				--usual dot_damage is 10
			end]]
		end

		local start_dot_damage_roll = math.random(1, 100)
		local start_dot_dance_antimation = false

		if flammable and distance < fire_dot_max_distance and start_dot_damage_roll <= fire_dot_trigger_chance then
			managers.fire:add_doted_enemy(self._unit, TimerManager:game():time(), attack_data.weapon_unit, fire_dot_data.dot_length, dot_damage, attack_data.attacker_unit, attack_data.is_molotov)

			start_dot_dance_antimation = true
		end

		if fire_dot_data then
			fire_dot_data.start_dot_dance_antimation = start_dot_dance_antimation
			attack_data.fire_dot_data = fire_dot_data
		end
	end

	self:_send_fire_attack_result(attack_data, attacker, damage_percent, attack_data.is_fire_dot_damage, attack_data.col_ray.ray, attack_data.result.type == "healed")
	self:_on_damage_received(attack_data)

	if not is_civilian and attack_data.attacker_unit and alive(attack_data.attacker_unit) then
		managers.player:send_message(Message.OnEnemyShot, nil, self._unit, attack_data)
	end

	return result
end
