local mvec3_set = mvector3.set
local mvec3_set_stat = mvector3.set_static
local mvec3_set_z = mvector3.set_z
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_sub = mvector3.subtract
local mvec3_dot = mvector3.dot
local mvec3_dis = mvector3.distance
local mvec3_norm = mvector3.normalize
local mvec3_cpy = mvector3.copy
local mvec3_neg = mvector3.negate
local mvec3_lerp = mvector3.lerp
local mvec3_spread = mvector3.spread

local mvec_1 = Vector3()
local mvec_2 = Vector3()
local mvec_3 = Vector3()
local mvec_4 = Vector3()

local m_rot_z = mrotation.z

local math_lerp = math.lerp
local math_random = math.random
local math_clamp = math.clamp
local math_min = math.min
local math_max = math.max
local math_ceil = math.ceil
local math_up = math.UP
local math_down = math.DOWN

local table_insert = table.insert
local table_contains = table.contains
local table_size = table.size

local tostring_g = tostring
local alive_g = alive
local world_g = World

local idstr_func = Idstring
local ids_flesh = idstr_func("flesh")
local idstr_bullet_hit_blood = idstr_func("effects/payday2/particles/impacts/blood/blood_impact_a")
local table_contains = table.contains

local big_enemy_visor_shattering_table = { --this is now responsible for the glass shattering effects. insert/remove anything in this table to add and remove shattering, respectively
	-- BLUE SWAT TIER--
	idstr_func("units/pd2_mod_cops/characters/ene_deathvox_cop_heavyswat/ene_deathvox_cop_heavyswat"),
	idstr_func("units/pd2_mod_cops/characters/ene_deathvox_cop_heavyswat/ene_deathvox_cop_heavyswat_husk"),
	idstr_func("units/pd2_mod_cops/characters/ene_deathvox_cop_heavyswatshot/ene_deathvox_cop_heavyswatshot"),
	idstr_func("units/pd2_mod_cops/characters/ene_deathvox_cop_heavyswatshot/ene_deathvox_cop_heavyswatshot_husk"),
	idstr_func("units/pd2_mod_cops/characters/ene_deathvox_cop_taser/ene_deathvox_cop_taser"),
	idstr_func("units/pd2_mod_cops/characters/ene_deathvox_cop_taser/ene_deathvox_cop_taser_husk"),
	idstr_func("units/pd2_mod_cops/characters/ene_deathvox_cop_shield/ene_deathvox_cop_shield"),
	idstr_func("units/pd2_mod_cops/characters/ene_deathvox_cop_shield/ene_deathvox_cop_shield_husk"),
	
	-- FBI TIER--
	idstr_func("units/pd2_mod_fbi/characters/ene_deathvox_fbi_heavyswat/ene_deathvox_fbi_heavyswat"),
	idstr_func("units/pd2_mod_fbi/characters/ene_deathvox_fbi_heavyswat/ene_deathvox_fbi_heavyswat_husk"),
	idstr_func("units/pd2_mod_fbi/characters/ene_deathvox_fbi_taser/ene_deathvox_fbi_taser"),
	idstr_func("units/pd2_mod_fbi/characters/ene_deathvox_fbi_taser/ene_deathvox_fbi_taser_husk"),
	
	-- GENSEC TIER--
	idstr_func("units/pd2_mod_gensec/characters/ene_deathvox_gensec_heavyswat/ene_deathvox_gensec_heavyswat"),
	idstr_func("units/pd2_mod_gensec/characters/ene_deathvox_gensec_heavyswat/ene_deathvox_gensec_heavyswat_husk"),
	idstr_func("units/pd2_mod_gensec/characters/ene_deathvox_gensec_taser/ene_deathvox_gensec_taser"),
	idstr_func("units/pd2_mod_gensec/characters/ene_deathvox_gensec_taser/ene_deathvox_gensec_taser_husk"),	
	
	-- ZULU TIER--
	idstr_func("units/pd2_mod_gageammo/characters/ene_deathvox_taser/ene_deathvox_taser"),
	idstr_func("units/pd2_mod_gageammo/characters/ene_deathvox_taser/ene_deathvox_taser_husk"),

	-- MURKYWATER--
	idstr_func("units/pd2_mod_sharks/characters/ene_deathvox_taser/ene_deathvox_taser"),
	idstr_func("units/pd2_mod_sharks/characters/ene_deathvox_taser/ene_deathvox_taser_husk"),
	idstr_func("units/pd2_mod_sharks/characters/ene_deathvox_fbi_heavyswat/ene_deathvox_fbi_heavyswat"),
	idstr_func("units/pd2_mod_sharks/characters/ene_deathvox_fbi_heavyswat/ene_deathvox_fbi_heavyswat_husk"),
	
	-- CLASSIC TIER--
	idstr_func("units/pd2_mod_classic/characters/ene_deathvox_classic_heavyswat/ene_deathvox_classic_heavyswat"),
	idstr_func("units/pd2_mod_classic/characters/ene_deathvox_classic_heavyswat/ene_deathvox_classic_heavyswat_husk"),	
	idstr_func("units/pd2_mod_classic/characters/ene_deathvox_classic_heavyswatshot/ene_deathvox_classic_heavyswatshot"),
	idstr_func("units/pd2_mod_classic/characters/ene_deathvox_classic_heavyswatshot/ene_deathvox_classic_heavyswatshot_husk"),	
	idstr_func("units/pd2_mod_classic/characters/ene_deathvox_classic_heavyswat_noarmor/ene_deathvox_classic_heavyswat_noarmor"),
	idstr_func("units/pd2_mod_classic/characters/ene_deathvox_classic_heavyswat_noarmor/ene_deathvox_classic_heavyswat_noarmor_husk"),	
	idstr_func("units/pd2_mod_classic/characters/ene_deathvox_classic_heavyswatshot_noarmor/ene_deathvox_classic_heavyswatshot_noarmor"),
	idstr_func("units/pd2_mod_classic/characters/ene_deathvox_classic_heavyswatshot_noarmor/ene_deathvox_classic_heavyswatshot_noarmor"),	
	
	-- FEDERALES TIER--
	idstr_func("units/pd2_mod_federales/characters/ene_deathvox_heavyswat/ene_deathvox_heavyswat"),
	idstr_func("units/pd2_mod_federales/characters/ene_deathvox_heavyswat/ene_deathvox_heavyswat_husk"),
	idstr_func("units/pd2_mod_federales/characters/ene_deathvox_heavyswatshot/ene_deathvox_heavyswatshot"),
	idstr_func("units/pd2_mod_federales/characters/ene_deathvox_heavyswatshot/ene_deathvox_heavyswatshot_husk"),
	idstr_func("units/pd2_mod_federales/characters/ene_deathvox_tazer/ene_deathvox_tazer"),
	idstr_func("units/pd2_mod_federales/characters/ene_deathvox_tazer/ene_deathvox_tazer_husk")
}

CopDamage.melee_knockback_tiers = {
	[1] = false,
	[2] = "light_hurt",
	[3] = "hurt",
	[4] = "heavy_hurt",
	[5] = "expl_hurt"
}

Hooks:PostHook(CopDamage,"init","deathvox_copdamage_init",function(self,unit)
	self._stuck_tripmines = {} --not used
	
	self._damage_vulnerability_sources = {}
	if managers.enemy:is_enemy(unit) then
		--civilians don't need this
		
		self._damage_vulnerability_total = 0 --cached result; recalculated on vulnerability added or vulnerability ended
		--init/declaring the value here ensures that setting damage multipliers will do nothing for non-enemies
		--but also won't crash for non-enemies
		
		unit:set_extension_update_enabled(Idstring("character_damage"),true)
	end
end)

function CopDamage:update(unit,t,dt)
	self:update_damage_vulnerability(t,dt)
end


--custom function- only used in tcd at the moment;
--implemented into damage functions for each damage type.
--this should also be usable outside of tcd
function CopDamage:_get_incoming_damage_multiplier(multiplier)
	multiplier = multiplier or 1
	local pm = managers.player
	if pm:team_upgrade_level("player","civilian_hostage_area_marking") == 2 then --this upgrade is tcd only but should be safe to check with or without tcd enabled
		local range,lookout_aced_bonus = unpack(pm:team_upgrade_value("player","civilian_hostage_area_marking",{}))
		--this applies to damage from all sources, so we don't need to check if the attacker unit is the player
		if range and CivilianBase.get_nearby_civ(self._unit:movement():m_pos(),range,true) then 
			multiplier = multiplier * lookout_aced_bonus
		end
	end
	return multiplier + self:get_damage_vulnerability_total()
end

--damage vulnerability system also added and only used in tcd 
	--damage vulnerability is a multiplier to incoming damage that is additive with itself and all other sources
	--damage vulnerability is checked every frame
	--damage vulnerability is LOCAL, not synced
	--force_recalculate should only be used if you are changing the vulnerability amount
	--and plan to use the vulnerability value later on in the same frame
	--(eg. if the same damage source that applies vulnerability also damages the enemy in the same frame)
function CopDamage:add_to_damage_vulnerability(key,amount,duration,force_recalculate) 
	if not key then 
		return
	end
	local source = self._damage_vulnerability_sources[key]
	if source then 
		if duration then 
			source.duration = source.duration + duration
		end
		if amount then 
			source.amount = source.amount + amount
		end
	else
		self:set_damage_vulnerability(key,amount,duration,force_recalculate)
		--log("TCD ERROR: CopDamage:add_to_damage_vulnerability(" .. table.concat({key,amount,duration,force_recalculate},",")): source does not exist for this key! " .. debug.traceback())
	end
	if force_recalculate then 
		self:recalculate_damage_vulnerability_total()
	end
end

function CopDamage:set_damage_vulnerability(key,amount,duration,force_recalculate)
	if not key then 
		return
	end
	local source = self._damage_vulnerability_sources[key]
	if source then 
		if duration then 
			source.duration = duration
		end
		if amount then 
			source.amount = amount
		end
	else
		source = {
			start_t = Application:time(),
			key = key,
			amount = amount,
			duration = duration
		}
		self._damage_vulnerability_sources[key] = source
	end
	if force_recalculate then 
		self:recalculate_damage_vulnerability_total()
	end
end

function CopDamage:remove_damage_vulnerability(key,force_recalculate)
	if not key then 
		return
	end
	local source = self._damage_vulnerability_sources[key]
	self._damage_vulnerability_sources[key] =  nil
	if force_recalculate then 
		self:recalculate_damage_vulnerability_total()
	end
	return source
end

function CopDamage:update_damage_vulnerability(t,dt,idk)
	local total = 0
	for key,data in pairs(self._damage_vulnerability_sources) do 
		if data.start_t + data.duration < t then
			self._damage_vulnerability_sources[key] = nil
		else
			total = total + data.amount
		end
	end
	self._damage_vulnerability_total = total
end

function CopDamage:get_damage_vulnerability(key)
	if not key then 
		return
	end
	local data = self._damage_vulnerability_sources[key]
	if data then 
		return data.amount,data.duration
	end
end

function CopDamage:get_damage_vulnerability_total(force_recalculate) --try not to use this!
	if force_recalculate then 
		self:recalculate_damage_vulnerability_total()
	end
	return self._damage_vulnerability_total or 0
end

function CopDamage:recalculate_damage_vulnerability_total()
	if self._damage_vulnerability_total then 
		local total = 0
		for key,data in pairs(self._damage_vulnerability_sources) do 
			if data.amount then 
				total = total + data.amount
			end
		end
		self._damage_vulnerability_total = total
	end
end

function CopDamage:is_immune_to_shield_knockback()
	if self._immune_to_knockback or self._unit:anim_data() and self._unit:anim_data().act then
		return true
	end

	return false
end

function CopDamage:_comment_death(attacker, killed_unit, special_comment)
	if special_comment then
		PlayerStandard.say_line(attacker:sound(), special_comment)
	else
		local victim_base = killed_unit:base()

		if victim_base:has_tag("tank") then
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
end

function CopDamage:_AI_comment_death(attacker, killed_unit, special_comment)
	if special_comment then
		attacker:sound():say(special_comment, true)
	else
		local victim_base = killed_unit:base()

		if victim_base:has_tag("tank") then
			attacker:sound():say("g30x_any", true)
		elseif victim_base:has_tag("spooc") then
			attacker:sound():say("g33x_any", true)
		elseif victim_base:has_tag("taser") then
			attacker:sound():say("g32x_any", true)
		elseif victim_base:has_tag("shield") then
			attacker:sound():say("g31x_any", true)
		elseif victim_base:has_tag("sniper") then
			attacker:sound():say("g35x_any", true)
		elseif victim_base:has_tag("medic") then
			attacker:sound():say("g36x_any", true)
		elseif victim_base:has_tag("custom") then
			attacker:sound():say("g92", true)
		end
	end
end

function CopDamage:roll_critical_hit(attack_data)
	local damage = attack_data.damage
	if attack_data.critical_hit then
		--log("well, yes")
	end
	if not self:can_be_critical(attack_data) then
		--log("but actually, no")
		return false, damage
	end

	local critical_hits = self._char_tweak.critical_hits or {}
	local critical_hit = attack_data.critical_hit or nil

	if critical_hit then
		local critical_damage_mul = critical_hits.damage_mul or self._char_tweak.headshot_dmg_mul

		if critical_damage_mul then
			damage = damage * critical_damage_mul
		else
			damage = self._health * 10
		end
	end

	return critical_hit, damage
end

function CopDamage:check_medic_heal()
	local anim_data = self._unit:anim_data()

	if anim_data and anim_data.act then
		return false
	end

	local disabled_units = tweak_data.medic.disabled_units
	local tweak_table_name = self._unit:base()._tweak_table

	if table_contains(disabled_units, tweak_table_name) then
		return false
	end

	local mov_ext = self._unit:movement()
	local team = mov_ext.team and mov_ext:team()

	if team and team.id ~= "law1" then
		if not team.friends or not team.friends.law1 then
			return false
		end
	end

	local brain_ext = self._unit:brain()

	if brain_ext then
		if brain_ext.converted then
			if brain_ext:converted() then
				return false
			end
		elseif brain_ext._logic_data and brain_ext._logic_data.is_converted then
			return false
		end
	end

	--further ensure that the unit isn't acting or plans to act
	local act_action, was_queued = self._unit:movement():_get_latest_act_action()

	if act_action then
		if not was_queued or not act_action.host_expired then
			return false
		end
	end

	local medic = managers.enemy:get_nearby_medic(self._unit)

	if medic then
		local medic_dmg_ext = medic:character_damage()

		if medic_dmg_ext:heal_unit(self._unit) then
			local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)

			--if playing on Crackdown difficulty, find enemies around the Medic and proceed with the usual healing process on them as well
			if difficulty_index == 8 then
				local enemies = medic:find_units_quick("sphere", medic:position(), tweak_data.medic.radius, managers.slot:get_mask("enemies"))
				local my_key = self._unit:key()

				for i = 1, #enemies do
					local enemy = enemies[i]
					local anim_data = enemy:anim_data()
					local skip_enemy = anim_data and anim_data.act or my_key == enemy:key()

					if not skip_enemy then
						local tweak_table_name = enemy:base()._tweak_table

						skip_enemy = table_contains(disabled_units, tweak_table_name) and true

						if not skip_enemy then
							local mov_ext = enemy:movement()
							local team = mov_ext.team and mov_ext:team()

							if team and team.id ~= "law1" then
								if not team.friends or not team.friends.law1 then
									skip_enemy = true
								end
							end

							if not skip_enemy then
								local brain_ext = enemy:brain()

								if brain_ext and brain_ext._logic_data and brain_ext._logic_data.is_converted then
									skip_enemy = true
								end

								if not skip_enemy and medic_dmg_ext:heal_unit(enemy, true) then
									local attack_data = {
										damage = 0,
										type = "healed",
										variant = "healed",
										result = {
											variant = "healed",
											type = "healed"
										}
									}

									enemy:network():send("damage_simple", enemy, 0, 4, 1) --sync the healed instance to other peers
									enemy:character_damage():_call_listeners(attack_data)
								end
							end
						end
					end
				end
			end

			return true
		end
	end
end

function CopDamage:damage_explosion(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	local attacker_unit = attack_data.attacker_unit
	local weap_unit = attack_data.weapon_unit
	local thrower_unit = weap_unit and weap_unit:base().thrower_unit

	if attacker_unit and alive(attacker_unit) then
		if attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			weap_unit = attack_data.attacker_unit
		end

		if self:is_friendly_fire(attacker_unit) then
			return "friendly_fire"
		end
	end

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)
	local damage = attack_data.damage
	
	local critical_hit, crit_damage = self:roll_critical_hit(attack_data)
	if critical_hit then
		managers.hud:on_crit_confirmed()
		damage = crit_damage
		attack_data.critical_hit = true
	end	

	if self._char_tweak.damage.explosion_damage_mul then
		damage = damage * self._char_tweak.damage.explosion_damage_mul
	end

	if self._marked_dmg_mul then
		damage = damage * self._marked_dmg_mul

		if self._marked_dmg_dist_mul and alive(attacker_unit) then
			local dst = mvec3_dis(attacker_unit:position(), self._unit:position())
			local spott_dst = tweak_data.upgrades.values.player.marked_inc_dmg_distance[self._marked_dmg_dist_mul]

			if spott_dst[1] < dst then
				damage = damage * spott_dst[2]
			end
		end
	end

	if managers.fire:is_set_on_fire(self._unit) then
		local third_degree_dmg_mul = 1
		local attacker_base_ext = alive(attacker_unit) and attacker_unit:base()

		if attacker_base_ext then
			if attacker_base_ext.is_local_player then
				third_degree_dmg_mul = managers.player:upgrade_value("subclass_areadenial", "effect_doubleroasting_damage_increase_mul", 1)
			elseif attacker_base_ext.is_husk_player then
				third_degree_dmg_mul = attacker_base_ext:upgrade_value("subclass_areadenial", "effect_doubleroasting_damage_increase_mul") or 1
			end
		end

		if third_degree_dmg_mul > 1 then
			damage = damage * third_degree_dmg_mul
		end
	end

	local damage_multiplier = 1
	damage_multiplier = self:_get_incoming_damage_multiplier(damage_multiplier)
	damage = damage * damage_multiplier 
	damage = managers.modifiers:modify_value("CopDamage:DamageExplosion", damage, self._unit)
	damage = self:_apply_damage_reduction(damage)

	if attacker_unit == managers.player:player_unit() and damage > 0 and attack_data.variant ~= "stun" then
		managers.hud:on_hit_confirmed()
		--if critical_hit then
		--	managers.hud:on_crit_confirmed()
		--else
		--	managers.hud:on_hit_confirmed()
		--end
	end

	if self._char_tweak.DAMAGE_CLAMP_EXPLOSION then
		damage = math_min(damage, self._char_tweak.DAMAGE_CLAMP_EXPLOSION)
	end

	attack_data.raw_damage = damage

	damage = math_clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math_ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math_min(damage, self._health - 1)
	end

	local result = nil

	if self._health <= damage then
		attack_data.damage = self._health

		if self:check_medic_heal() then
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
			self:chk_killshot(attacker_unit, "explosion")
		end
	else
		local result_type = attack_data.variant == "stun" and "hurt_sick" or self:get_damage_type(damage_percent, "explosion")

		attack_data.damage = damage
		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position
	result.ignite_character = attack_data.ignite_character

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			owner = attack_data.owner,
			weapon_unit = weap_unit,
			variant = attack_data.variant
		}

		managers.statistics:killed_by_anyone(data)

		if attack_data.variant ~= "stun" then
			if data.name == "deathvox_grenadier" then
				self._unit:damage():run_sequence_simple("grenadier_glass_break")
			elseif self._head_body_name then
				local body = self._unit:body(self._head_body_name)

				self:_spawn_head_gadget({
					skip_push = true,
					position = body:position(),
					rotation = body:rotation()
				})
			end
		end

		if attacker_unit == managers.player:player_unit() then
			if is_civilian then
				managers.money:civilian_killed()
			elseif alive(attacker_unit) and attack_data.weapon_unit and attack_data.weapon_unit:base().weapon_tweak_data and not thrower_unit and managers.player:has_category_upgrade("temporary", "overkill_damage_multiplier") and attack_data.weapon_unit:base().is_category and attack_data.weapon_unit:base():is_category("shotgun", "saw") then
				managers.player:activate_temporary_upgrade("temporary", "overkill_damage_multiplier")
			end

			if alive(attacker_unit) then
				self:_comment_death(attacker_unit, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			self:_check_damage_achievements(attack_data, false)
		elseif alive(attacker_unit) and managers.groupai:state():is_unit_team_AI(attacker_unit) then
			self:_AI_comment_death(attacker_unit, self._unit)
		end
	end

	if alive(weap_unit) and weap_unit:base() and weap_unit:base().add_damage_result then
		weap_unit:base():add_damage_result(self._unit, result.type == "death", attacker_unit, damage_percent)
	end

	if attack_data.variant ~= "stun" and not self._no_blood and damage > 0 then
		managers.game_play_central:sync_play_impact_flesh(attack_data.pos, attack_data.col_ray.ray)
	end

	local attacker = attack_data.attacker_unit

	if not attacker or not alive(attacker) or attacker:id() == -1 then
		attacker = self._unit
	end

	local sync_attack_variant = attack_data.variant

	if result.type == "healed" then
		sync_attack_variant = "healed"
	end

	self:_send_explosion_attack_result(attack_data, attacker, damage_percent, self:_get_attack_variant_index(sync_attack_variant), attack_data.col_ray.ray)
	self:_on_damage_received(attack_data)

	return result
end

function CopDamage:sync_damage_explosion(attacker_unit, damage_percent, i_attack_variant, death, direction, weapon_unit)
	if self._dead then
		return
	end

	local variant = CopDamage._ATTACK_VARIANTS[i_attack_variant]
	local was_healed = nil

	if variant == "healed" then
		variant = "explosion"
		was_healed = true
	end

	local attack_data = {
		variant = variant,
		attacker_unit = attacker_unit,
		weapon_unit = weapon_unit
	}

	local attacker = attack_data.attacker_unit
	local weapon_unit = weapon_unit

	if attacker and attacker:base() and attacker:base().thrower_unit then
		attacker = attacker:base():thrower_unit()
		weapon_unit = attack_data.attacker_unit
	end

	if not weapon_unit then
		weapon_unit = attacker_unit and attacker_unit:inventory() and alive(attacker_unit:inventory():equipped_unit()) and attacker_unit:inventory():equipped_unit()
	end

	local hit_pos = mvec3_cpy(self._unit:position())
	mvec3_set_z(hit_pos, hit_pos.z + 100)

	local attack_dir, result = nil

	if direction then
		attack_dir = direction
	elseif attacker_unit then
		local from_pos = nil

		if attacker_unit:movement() and attacker_unit:movement().m_head_pos then
			from_pos = attacker_unit:movement():m_head_pos()
		else
			from_pos = attacker_unit:position()
		end

		attack_dir = hit_pos - from_pos
		mvec3_norm(attack_dir)
	else
		attack_dir = -self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir
	hit_pos = hit_pos - attack_dir * 5
	attack_data.pos = hit_pos

	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	attack_data.damage = damage

	if death then
		attack_data.damage = self._health
		result = {
			type = "death",
			variant = variant
		}

		self:die(attack_data)

		local data = {
			variant = "explosion",
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			weapon_unit = weapon_unit
		}

		managers.statistics:killed_by_anyone(data)

		self:chk_killshot(attacker, "explosion")

		if variant ~= "stun" then
			if data.name == "deathvox_grenadier" then
				self._unit:damage():run_sequence_simple("grenadier_glass_break")
			elseif self._head_body_name then
				local body = self._unit:body(self._head_body_name)

				self:_spawn_head_gadget({
					skip_push = true,
					position = body:position(),
					rotation = body:rotation()
				})
			end
		end

		if attacker == managers.player:player_unit() then
			if alive(attacker) then
				self:_comment_death(attacker, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if CopDamage.is_civilian(self._unit:base()._tweak_table) then
				managers.money:civilian_killed()
			end

			self:_check_damage_achievements(attack_data, false)
		end
	else
		local result_type = "dmg_rcv"

		if was_healed then
			result_type = "healed"

			attack_data.damage = self._health
		else
			self:_apply_damage_to_health(damage)
		end

		result = {
			type = result_type,
			variant = variant
		}
	end

	attack_data.result = result
	attack_data.is_synced = true

	if damage > 0 and variant ~= "stun" and attacker == managers.player:player_unit() and alive(attacker) then
		managers.hud:on_hit_confirmed()
	end

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", damage_percent)
	end

	if variant ~= "stun" and not self._no_blood and damage > 0 then
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	self:_on_damage_received(attack_data)
end

function CopDamage:damage_bullet(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	if self:is_friendly_fire(attack_data.attacker_unit) then
		return "friendly_fire"
	end

	if alive(attack_data.attacker_unit) and attack_data.attacker_unit:in_slot(16) then
		local has_surrendered = self._unit:brain().surrendered and self._unit:brain():surrendered() or self._unit:anim_data().surrender or self._unit:anim_data().hands_back or self._unit:anim_data().hands_tied

		if has_surrendered then
			return
		end
	end

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)
	
	local attacker_is_main_player = attack_data.attacker_unit == managers.player:player_unit()
	--moved up here so that blocked shots don't interfere
	if attack_data.weapon_unit and attack_data.weapon_unit:base().is_category and attack_data.weapon_unit:base():is_category("saw") then
		managers.groupai:state():chk_say_enemy_chatter(self._unit, self._unit:movement():m_pos(), "saw")
	end

	if attack_data.attacker_unit:base().sentry_gun then
		managers.groupai:state():chk_say_enemy_chatter(self._unit, self._unit:movement():m_pos(), "sentry")
	end
	
	mvec3_set(mvec_1, self._unit:position())
	mvec3_sub(mvec_1, attack_data.attacker_unit:position())
	mvec3_norm(mvec_1)
	mvec3_set(mvec_2, self._unit:rotation():y())

	local from_behind = mvec3_dot(mvec_1, mvec_2) >= 0
	if self._has_plate and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_plate_name then
		if attack_data.armor_piercing or (attack_data.weapon_unit:base().thrower_unit and deathvox:IsTotalCrackdownEnabled()) then --icky
		else
			local armor_pierce_roll = math_random()
			local armor_pierce_value = 0
			local thrower_unit = attack_data.weapon_unit:base().thrower_unit
			if attacker_is_main_player and not thrower_unit then
				armor_pierce_value = armor_pierce_value + attack_data.weapon_unit:base():armor_piercing_chance()
				armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("player", "armor_piercing_chance", 0)
				armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("weapon", "armor_piercing_chance", 0)
				armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("weapon", "armor_piercing_chance_2", 0)
				if attack_data.weapon_unit:base():got_silencer() then
					armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("weapon", "armor_piercing_chance_silencer", 0)
				end
			end

			if armor_pierce_value <= armor_pierce_roll then
				local result_type = nil

				if not self._char_tweak.immune_to_knock_down then
					if attack_data.knock_down then
						result_type = "knock_down"
					elseif attack_data.stagger and not self._has_been_staggered then
						result_type = "stagger"
						self._has_been_staggered = true
					end
				end

				if not result_type then
					local damage = attack_data.damage
					damage = math_clamp(damage, 0, self._HEALTH_INIT)
					local damage_percent = math_ceil(damage / self._HEALTH_INIT_PRECENT)
					damage = damage_percent * self._HEALTH_INIT_PRECENT
					damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

					result_type = self:get_damage_type(damage_percent, "bullet")
				end

				attack_data.damage = 0
				attack_data.raw_damage = 0

				local result = {
					type = result_type,
					variant = attack_data.variant
				}

				attack_data.result = result
				attack_data.pos = attack_data.col_ray.position

				local body_index = self._unit:get_body_index(attack_data.col_ray.body:name())
				local hit_offset_height = math_clamp(attack_data.col_ray.position.z - self._unit:position().z, 0, 300)
				local attacker = attack_data.attacker_unit

				if not attacker or not alive(attacker) or attacker:id() == -1 then
					attacker = self._unit
				end

				self:_send_bullet_attack_result(attack_data, attacker, 0, body_index, hit_offset_height, 0)
				self:_on_damage_received(attack_data)

				result.attack_data = attack_data

				return result
			end
		end

		local col_ray = attack_data.col_ray
		local decal_ray_from = mvec_1
		local decal_ray_to = mvec_2

		mvec3_set(decal_ray_from, col_ray.ray)
		mvec3_set(decal_ray_to, col_ray.position)
		mvec3_mul(decal_ray_from, 25)
		mvec3_add(decal_ray_to, decal_ray_from)
		mvec3_neg(decal_ray_from)
		mvec3_add(decal_ray_from, col_ray.position)

		local material_name = world_g:pick_decal_material(col_ray.unit, decal_ray_from, decal_ray_to, managers.slot:get_mask("bullet_impact_targets"))

		if material_name ~= idstr_bullet_hit_blood then
			local effect_normal = mvec_3
			mvec3_set(effect_normal, col_ray.normal)

			mvec3_set(mvec_4, col_ray.ray)
			mvec3_neg(mvec_4)
			mvec3_lerp(effect_normal, col_ray.normal, mvec_4, math_random())
			mvec3_spread(effect_normal, 10)

			world_g:effect_manager():spawn({
				effect = idstr_bullet_hit_blood,
				position = col_ray.position,
				normal = effect_normal
			})
		end
	end

	local body_index = self._unit:get_body_index(attack_data.col_ray.body:name())

	--the change below prevents you from using triggering headshot-based effects from Jokers and units that are supposed to ignore headshot multipliers in vanilla
	local head = self._head_body_name and not self._unit:in_slot(16) and not self._char_tweak.ignore_headshot and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name

	--negate headshot damage against Dozers if not done from the front (except for throwables) for consistency's sake, works pretty well I'd say
	if head and self._unit:base():has_tag("tank") then
		mvec3_set(mvec_1, attack_data.col_ray.ray)
		m_rot_z(self._unit:movement():m_head_rot(), mvec_2)

		if from_behind then
			head = false
		end
	end

	attack_data.headshot = head

	local damage = attack_data.damage
	local headshot_by_player = false
	local headshot_multiplier = 1
	local headshot_mul_addend = 0

	if attacker_is_main_player then
		local backstab_bullets_mul = 1
		local weap_base = alive(attack_data.weapon_unit) and attack_data.weapon_unit:base()
		local weapon_class = weap_base and weap_base.get_weapon_class and weap_base:get_weapon_class() or "NO_WEAPON_CLASS"
		local subclasses = weap_base and weap_base.get_weapon_subclasses and weap_base:get_weapon_subclasses() or {}

		local player_has_aggro = false
		local set_attention = self._unit:movement():attention()

		if set_attention then
			local att_unit = set_attention.unit
			local att_base_ext = att_unit and att_unit:base()

			player_has_aggro = att_base_ext and att_base_ext.is_local_player
		end

		if from_behind then 
			for _,subclass in pairs(subclasses) do 
				backstab_bullets_mul = backstab_bullets_mul + managers.player:upgrade_value(subclass,"backstab_bullets",0)
				if not player_has_aggro then 
					backstab_bullets_mul = backstab_bullets_mul + managers.player:upgrade_value(subclass,"unnoticed_damage_bonus",0)
				end
			end
		end

		damage = damage * backstab_bullets_mul

		if managers.fire:is_set_on_fire(self._unit) then
			local third_degree_dmg_mul = managers.player:upgrade_value("subclass_areadenial", "effect_doubleroasting_damage_increase_mul", 1)

			if third_degree_dmg_mul > 1 then
				damage = damage * third_degree_dmg_mul
			end
		end

		headshot_mul_addend = managers.player:upgrade_value(weapon_class, "headshot_mul_addend", 0)

		local critical_hit, crit_damage = self:roll_critical_hit(attack_data)

		if critical_hit then
			damage = crit_damage
			attack_data.critical_hit = true

			if damage > 0 then
				managers.hud:on_crit_confirmed()
			end
		elseif damage > 0 then
			managers.hud:on_hit_confirmed()
		end

		if self._char_tweak.priority_shout then
			damage = damage * managers.player:upgrade_value("weapon", "special_damage_taken_multiplier", 1)
		end

		if head then
			managers.player:on_headshot_dealt()

			headshot_by_player = true
			headshot_multiplier = headshot_multiplier * (managers.player:upgrade_value("weapon", "passive_headshot_damage_multiplier", 1) + headshot_mul_addend)
		end
	end

	if not self._damage_reduction_multiplier and head then
		if self._char_tweak.headshot_dmg_mul then
			damage = damage * self._char_tweak.headshot_dmg_mul * headshot_multiplier
		else
			damage = self._health * 10
		end
	end

	if self._marked_dmg_mul then
		damage = damage * self._marked_dmg_mul

		if self._marked_dmg_dist_mul then
			local dst = mvec3_dis(attack_data.origin, self._unit:position())
			local spott_dst = tweak_data.upgrades.values.player.marked_inc_dmg_distance[self._marked_dmg_dist_mul]

			if spott_dst[1] < dst then
				damage = damage * spott_dst[2]
			end
		end

		local attacker = attack_data.attacker_unit

		if alive(attacker) then
			local attacker_dmg_ext = attacker:character_damage()
			local joker_dmg_bonus = attacker_dmg_ext and attacker_dmg_ext._joker_mark_dmg_bonus

			if joker_dmg_bonus then
				damage = damage * joker_dmg_bonus
			end
		end
	end

	if not head and attack_data.weapon_unit:base().get_add_head_shot_mul and not self._unit:base():has_tag("tank") then
		if self._char_tweak and self._char_tweak.headshot_dmg_mul and not self._char_tweak.ignore_headshot then
			local add_head_shot_mul = attack_data.weapon_unit:base():get_add_head_shot_mul()

			if add_head_shot_mul then
				local tweak_headshot_mul = math_max(0, self._char_tweak.headshot_dmg_mul - 1)
				local mul = tweak_headshot_mul * add_head_shot_mul + 1 + headshot_mul_addend
				damage = damage * mul
			end
		end
	end
	
	local damage_multiplier = 1
	damage_multiplier = self:_get_incoming_damage_multiplier(damage_multiplier)
	damage = damage * damage_multiplier 
	
	damage = self:_apply_damage_reduction(damage)

	--proper stealth insta-killing and damage clamping (the latter won't interfere for insta-kills)
	if self._unit:movement():cool() and self._unit:base():char_tweak()["stealth_instant_kill"] then
		damage = self._HEALTH_INIT
	elseif self._char_tweak.DAMAGE_CLAMP_BULLET then
		damage = math_min(damage, self._char_tweak.DAMAGE_CLAMP_BULLET)
	end

	attack_data.raw_damage = damage

	damage = math_clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math_ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math_min(damage, self._health - 1)
	end

	local result = nil

	if self._health <= damage then
		attack_data.damage = self._health

		if self:check_medic_heal() then
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
			self:chk_killshot(attack_data.attacker_unit, "bullet", headshot_by_player)
		end
	else
		attack_data.damage = damage

		local result_type = nil

		if not self._char_tweak.immune_to_knock_down then
			if attack_data.knock_down then
				result_type = "knock_down"
			elseif attack_data.stagger and not self._has_been_staggered then
				result_type = "stagger"
				self._has_been_staggered = true
			end
		end

		if not result_type then
			result_type = self:get_damage_type(damage_percent, "bullet")
		end

		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			head_shot = head,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant
		}

		if head then
			managers.player:on_lethal_headshot_dealt(attack_data.attacker_unit, attack_data)

			if damage >= 10 or math_random(10) < damage then
				if data.name == "deathvox_grenadier" then
					self._unit:damage():run_sequence_simple("grenadier_glass_break")
				else
					self:_spawn_head_gadget({
						position = attack_data.col_ray.body:position(),
						rotation = attack_data.col_ray.body:rotation(),
						dir = attack_data.col_ray.ray
					})
				end
			end
		end

		managers.statistics:killed_by_anyone(data)

		if attacker_is_main_player then
			if is_civilian then
				managers.money:civilian_killed()
			elseif alive(attack_data.attacker_unit) and not attack_data.weapon_unit:base().thrower_unit and managers.player:has_category_upgrade("temporary", "overkill_damage_multiplier") and attack_data.weapon_unit:base():is_category("shotgun", "saw") then
				managers.player:activate_temporary_upgrade("temporary", "overkill_damage_multiplier")
			end

			if alive(attack_data.attacker_unit) then
				local special_comment = self:_check_special_death_conditions(attack_data.variant, attack_data.col_ray.body, attack_data.attacker_unit, attack_data.weapon_unit)

				self:_comment_death(attack_data.attacker_unit, self._unit, special_comment)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)

			local attacker_state = managers.player:current_state()
			data.attacker_state = attacker_state

			managers.statistics:killed(data)
			self:_check_damage_achievements(attack_data, head)
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
		elseif alive(attack_data.attacker_unit) and managers.groupai:state():is_unit_team_AI(attack_data.attacker_unit) then
			local special_comment = self:_check_special_death_conditions(attack_data.variant, attack_data.col_ray.body, attack_data.attacker_unit, attack_data.weapon_unit)

			self:_AI_comment_death(attack_data.attacker_unit, self._unit, special_comment)
		end
	end

	local hit_offset_height = math_clamp(attack_data.col_ray.position.z - self._unit:position().z, 0, 300)
	local attacker = attack_data.attacker_unit

	if not attacker or not alive(attacker) or attacker:id() == -1 then
		attacker = self._unit
	end

	local weapon_unit = attack_data.weapon_unit

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", attacker, damage_percent)
	end

	local i_result = nil

	if result.type == "healed" then
		i_result = 1
	else
		i_result = 0
	end

	self:_send_bullet_attack_result(attack_data, attacker, damage_percent, body_index, hit_offset_height, i_result)
	self:_on_damage_received(attack_data)

	if not is_civilian then
		managers.player:send_message(Message.OnEnemyShot, nil, self._unit, attack_data)
	end

	result.attack_data = attack_data

	return result
end

function CopDamage:die(attack_data)
	if not managers.enemy:is_corpse_disposal_enabled() then
		local unit_pos = self._unit:position()
		local unit_rot = self._unit:rotation()

		managers.network:session():send_to_peers_synched("sync_fall_position", self._unit, unit_pos, unit_rot)
	end

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

	attack_data.variant = attack_data.variant or "bullet"
	self._health = 0
	self._health_ratio = 0
	self._dead = true

	self:set_mover_collision_state(false)

	if self._death_sequence and self._unit:damage() and self._unit:damage():has_sequence(self._death_sequence) then
		self._unit:damage():run_sequence_simple(self._death_sequence)
	end

	if self._unit:base():has_tag("spooc") then
		if self._char_tweak.die_sound_event then
			self._unit:sound():play(self._char_tweak.die_sound_event) --ensure that spoocs stop their looping presence sound
		end

		--if not self._unit:movement():cool() then --optional, to reinforce the idea of silent kills if desired
			self._unit:sound():say("x02a_any_3p") --death voiceline, can't use char_tweak().die_sound_event since spoocs have the presence loop stop there (this ensures both are played, unlike in vanilla)
		--end

		if self._unit:damage() and self._unit:damage():has_sequence("kill_spook_lights") then
			self._unit:damage():run_sequence_simple("kill_spook_lights")
		end
	else
		--if not self._unit:movement():cool() then
		if self._char_tweak.die_sound_event then --death voiceline determined through char_tweak().die_sound_event, otherwise use default
			self._unit:sound():say(self._char_tweak.die_sound_event)
		else
			self._unit:sound():say("x02a_any_3p")
		end
		--end
	end

	if self._unit:base().looping_voice then
		self._unit:base().looping_voice:set_looping(false)
		self._unit:base().looping_voice:stop()
		self._unit:base().looping_voice:close()
		self._unit:base().looping_voice = nil
	end

	--[[if self._unit:base():char_tweak().ends_assault_on_death then
		for u_key, u_data in pairs(managers.enemy:all_enemies()) do
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
		end

		managers.fire:_remove_hell_fire_from_all()
		managers.groupai:state():unregister_phalanx_vip(self._unit)
		managers.groupai:state():force_end_assault_phase()
		managers.hud:set_buff_enabled("vip", false)
	end

	managers.fire:_remove_hell_fire(self._unit)]]

	self:_on_death()
	managers.mutators:notify(Message.OnCopDamageDeath, self, attack_data)

	--will add back again properly in coplogic files
	--report enemy deaths when not in stealth and when instantly killing enemies without alerting them
	--[[if not managers.groupai:state():whisper_mode() and not CopDamage.is_civilian(self._unit:base()._tweak_table) then
		if attack_data.attacker_unit and alive(attack_data.attacker_unit) then
			if managers.groupai:state():all_criminals()[attack_data.attacker_unit:key()] then
				managers.groupai:state():report_aggression(attack_data.attacker_unit)
			end
		end
	end]]
end

function CopDamage:damage_tase(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	local attacker_unit = attack_data.attacker_unit
	local weap_unit = attack_data.weapon_unit

	if attacker_unit and alive(attacker_unit) and self:is_friendly_fire(attacker_unit) then
		return "friendly_fire"
	end

	local damage = attack_data.damage
	
	local damage_multiplier = 1
	damage_multiplier = self:_get_incoming_damage_multiplier(damage_multiplier)
	damage = damage * damage_multiplier 

	if managers.fire:is_set_on_fire(self._unit) then
		local third_degree_dmg_mul = 1
		local attacker_base_ext = alive(attacker_unit) and attacker_unit:base()

		if attacker_base_ext then
			if attacker_base_ext.is_local_player then
				third_degree_dmg_mul = managers.player:upgrade_value("subclass_areadenial", "effect_doubleroasting_damage_increase_mul", 1)
			elseif attacker_base_ext.is_husk_player then
				third_degree_dmg_mul = attacker_base_ext:upgrade_value("subclass_areadenial", "effect_doubleroasting_damage_increase_mul") or 1
			end
		end

		if third_degree_dmg_mul > 1 then
			damage = damage * third_degree_dmg_mul
		end
	end

	damage = self:_apply_damage_reduction(damage)

	attack_data.raw_damage = damage

	damage = math_clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math_ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math_min(damage, self._health - 1)
	end

	local result, tase_variant = nil

	if self._health <= damage then
		attack_data.damage = self._health
		attack_data.variant = "bullet"

		if self:check_medic_heal() then
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			result = {
				variant = "bullet",
				type = "death"
			}

			self:die(attack_data)
			self:chk_killshot(attacker_unit, "tase")
		end
	else
		attack_data.damage = damage

		local result_type = "dmg_rcv"

		if not alive(managers.groupai:state():phalanx_vip()) then
			if self._char_tweak.damage.hurt_severity.tase == nil or self._char_tweak.damage.hurt_severity.tase then
				if weap_unit and attacker_unit == managers.player:player_unit() then
					managers.hud:on_hit_confirmed()
				end

				result_type = "taser_tased"

				self._tased_time = 5
				self._tased_down_time = 10

				local tased_response = self._char_tweak.damage.tased_response

				if tased_response then
					if attack_data.variant == "heavy" and tased_response.heavy then
						self._tased_time = tased_response.heavy.tased_time
						self._tased_down_time = tased_response.heavy.down_time
						tase_variant = "heavy"
					elseif tased_response.light then
						self._tased_time = tased_response.light.tased_time
						self._tased_down_time = tased_response.light.down_time
						tase_variant = "light"
					end
				end
			end
		end

		attack_data.variant = "bullet"

		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			owner = attack_data.owner,
			weapon_unit = weap_unit,
			variant = "bullet"
		}

		managers.statistics:killed_by_anyone(data)

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
		elseif alive(attacker_unit) and managers.groupai:state():is_unit_team_AI(attacker_unit) then
			self:_AI_comment_death(attacker_unit, self._unit)
		end
	end

	local attacker = attacker_unit

	if not attacker or not alive(attacker) or attacker:id() == -1 then
		attack_data.attacker_unit = self._unit
	end

	local i_result = nil

	if result.type == "taser_tased" then
		if tase_variant == "heavy" then
			i_result = 1
		elseif tase_variant == "light" then
			i_result = 2
		else
			i_result = 3
		end
	elseif result.type == "healed" then
		i_result = 4
	else
		i_result = 0
	end

	self:_send_tase_attack_result(attack_data, damage_percent, i_result)
	self:_on_damage_received(attack_data)

	return result
end

function CopDamage:sync_damage_tase(attacker_unit, damage_percent, i_result, death)
	if self._dead then
		return
	end

	local attack_data = {
		attacker_unit = attacker_unit,
		variant = "bullet"
	}

	local hit_pos = mvec3_cpy(self._unit:position())
	mvec3_set_z(hit_pos, hit_pos.z + 100)

	local attack_dir, result = nil

	if attacker_unit then
		local from_pos = nil

		if attacker_unit:movement() and attacker_unit:movement().m_head_pos then
			from_pos = attacker_unit:movement():m_head_pos()
		else
			from_pos = attacker_unit:position()
		end

		attack_dir = hit_pos - from_pos
		mvec3_norm(attack_dir)
	else
		attack_dir = -self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir
	hit_pos = hit_pos - attack_dir * 5
	attack_data.pos = hit_pos

	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	attack_data.damage = damage

	if death then
		attack_data.damage = self._health

		result = {
			variant = "bullet",
			type = "death"
		}

		self:die(attack_data)
		self:chk_killshot(attacker_unit, "tase")

		local data = {
			variant = "bullet",
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit(),
		}

		managers.statistics:killed_by_anyone(data)
	else
		local result_type = "dmg_rcv"

		if i_result == 4 then
			attack_data.damage = self._health
			result_type = "healed"
		else
			self:_apply_damage_to_health(damage)

			if i_result == 1 then
				result_type = "taser_tased"
				self._tased_time = self._char_tweak.damage.tased_response.heavy.tased_time
				self._tased_down_time = self._char_tweak.damage.tased_response.heavy.down_time
			elseif i_result == 2 then
				result_type = "taser_tased"
				self._tased_time = self._char_tweak.damage.tased_response.light.tased_time
				self._tased_down_time = self._char_tweak.damage.tased_response.light.down_time
			elseif i_result == 3 then
				result_type = "taser_tased"
				self._tased_time = 5
				self._tased_down_time = 10
			end
		end

		result = {
			type = result_type,
			variant = "bullet"
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.is_synced = true

	self:_on_damage_received(attack_data)
end

function CopDamage:stun_hit(attack_data)
	if self._dead or self._invulnerable then
		return
	else
		local anim_data = self._unit:anim_data()

		if anim_data.act or anim_data.surrender or anim_data.hands_back or anim_data.hands_tied or self._unit:brain().surrendered and self._unit:brain():surrendered() then
			return
		end
	end

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)
	local attacker_unit = attack_data.attacker_unit

	if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
	end

	if not is_civilian then --do not stun teammates and affect civilians regardless of the attacker
		if self:is_friendly_fire(attacker_unit) then
			return "friendly_fire"
		end
	end

	local attacker = attack_data.attacker_unit

	if not attacker or not alive(attacker) or attacker:id() == -1 then
		attacker = self._unit
	end

	local result = {
		type = "concussion",
		variant = attack_data.variant
	}
	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position

	self:_send_stun_attack_result(attacker, 0, self:_get_attack_variant_index(attack_data.variant), attack_data.col_ray.ray)
	self:_on_damage_received(attack_data)
	self:_create_stun_exit_clbk()

	return result
end

function CopDamage:sync_damage_stun(attacker_unit, damage_percent, i_attack_variant, death, direction)
	if self._dead then
		return
	end

	local variant = CopDamage._ATTACK_VARIANTS[i_attack_variant]
	local attack_data = {
		variant = variant,
		attacker_unit = attacker_unit
	}

	local hit_pos = mvec3_cpy(self._unit:position())
	mvec3_set_z(hit_pos, hit_pos.z + 100)

	local attack_dir = nil

	if direction then
		attack_dir = direction
	elseif attacker_unit then
		local from_pos = nil

		if attacker_unit:movement() and attacker_unit:movement().m_head_pos then
			from_pos = attacker_unit:movement():m_head_pos()
		else
			from_pos = attacker_unit:position()
		end

		attack_dir = self._unit:position() - from_pos
		mvec3_norm(attack_dir)
	else
		attack_dir = -self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir
	hit_pos = hit_pos - attack_dir * 5
	attack_data.pos = hit_pos

	local result = {
		type = "concussion",
		variant = variant
	}
	attack_data.result = result
	attack_data.is_synced = true

	self:_on_damage_received(attack_data)
	self:_create_stun_exit_clbk()
end

function CopDamage:get_damage_type(damage_percent, category)
	if alive(managers.groupai:state():phalanx_vip()) then
		return "dmg_rcv"
	end

	local hurt_table = self._char_tweak.damage.hurt_severity[category or "bullet"]
	local dmg = damage_percent / self._HEALTH_GRANULARITY

	if hurt_table.health_reference == "current" then
		dmg = math_min(1, self._HEALTH_INIT * dmg / self._health)
	elseif hurt_table.health_reference ~= "full" then
		dmg = math_min(1, self._HEALTH_INIT * dmg / hurt_table.health_reference)
	end

	local zone = nil

	for i_zone, test_zone in ipairs(hurt_table.zones) do
		if i_zone == #hurt_table.zones or dmg < test_zone.health_limit then
			zone = test_zone

			break
		end
	end

	local rand_nr = math_random()
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
	end

	local attacker_unit = damage_info.attacker_unit

	if alive(attacker_unit) and attacker_unit:base() then
		if attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
		elseif attacker_unit:base().sentry_gun then
			attacker_unit = attacker_unit:base():get_owner()
		end
	end

	if attacker_unit == managers.player:player_unit() then
		managers.player:on_damage_dealt(self._unit, damage_info)
	end

	if not self._dead and type(damage_info.damage) == "number" then
		local t = TimerManager:game():time()

		if not self._next_allowed_hurt_t or self._next_allowed_hurt_t and self._next_allowed_hurt_t < t then
			if damage_info.result_type ~= "healed" and damage_info.result_type ~= "death" then
				if damage_info.is_fire_dot_damage or damage_info.variant == "fire" then
					if not self._next_allowed_burnhurt_t or self._next_allowed_burnhurt_t < t then
						self._unit:sound():say("burnhurt")

						if self._unit:base():has_tag("special") then
							self._next_allowed_burnhurt_t = t + 6
							self._next_allowed_hurt_t = t + math_random(3, 6)
						else
							self._next_allowed_burnhurt_t = t + 4
							self._next_allowed_hurt_t = t + math_random(1, 4)
						end
					end
				else
					self._unit:sound():say("x01a_any_3p")

					if self._unit:base():has_tag("special") then
						self._next_allowed_hurt_t = t + math_random(3, 6)
					else
						self._next_allowed_hurt_t = t + math_random(1, 4)
					end
				end
			end
		end
	end

	--should prevent countering and shield knock from counting towards this
	if damage_info.variant == "melee" and type(damage_info.damage) == "number" and damage_info.damage > 0 then
		managers.statistics:register_melee_hit()
	end

	self:_update_debug_ws(damage_info)

	if self._start_regen_on_damage_taken then
		if self._dead then
			self._start_regen_on_damage_taken = nil
			self._health_regen_clbk_id = nil
			self._regen_percent = nil
		elseif self._health_ratio < 1 then
			self._start_regen_on_damage_taken = nil

			managers.enemy:add_delayed_clbk(self._health_regen_clbk_id, callback(self, self, "clbk_regen"), TimerManager:game():time() + 1)
		end
	end
end

function CopDamage:sync_damage_bullet(attacker_unit, damage_percent, i_body, hit_offset_height, i_result, death)
	if self._dead then
		return
	end

	local attack_data = {
		variant = "bullet",
		attacker_unit = attacker_unit
	}

	local from_pos, attack_dir, distance, result, shotgun_push, normal_push, is_shotgun = nil
	local body = self._unit:body(i_body)
	local head = self._head_body_name and not self._unit:in_slot(16) and not self._char_tweak.ignore_headshot and body and body:name() == self._ids_head_body_name
	local hit_pos = mvec3_cpy(body:position())
	attack_data.pos = hit_pos

	if attacker_unit then
		from_pos = attacker_unit:movement():m_head_pos()

		attack_dir = hit_pos - from_pos
		distance = mvec3_norm(attack_dir)
	else
		attack_dir = -self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir

	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	attack_data.damage = damage

	if death then
		attack_data.damage = self._health

		if head then
			self:_spawn_head_gadget({
				position = body:position(),
				rotation = body:rotation(),
				dir = attack_dir
			})
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

		if head then
			if damage >= 10 or math_random(10) < damage then
				if data.name == "deathvox_grenadier" then
					self._unit:damage():run_sequence_simple("grenadier_glass_break")
				else
					self:_spawn_head_gadget({
						position = body:position(),
						rotation = body:rotation(),
						dir = attack_dir
					})
				end
			end
		end

		local weapon = data.weapon_unit

		if weapon then
			self:_check_special_death_conditions("bullet", body, attacker_unit, weapon)
			managers.statistics:killed_by_anyone(data)

			local can_shotgun_push_locally = managers.enemy:is_corpse_disposal_enabled()

			if can_shotgun_push_locally then
				if distance then
					local weapon_base = weapon:base()
					is_shotgun = weapon_base and not weapon_base.thrower_unit and weapon_base.is_category and weapon_base:is_category("shotgun") or false

					if is_shotgun then
						local negate = nil

						if weapon_base._parts then
							for part_id, part in pairs(weapon_base._parts) do
								if tweak_data.weapon.factory.parts[part_id].custom_stats and tweak_data.weapon.factory.parts[part_id].custom_stats.rays == 1 then
									negate = true

									break
								end
							end
						end

						if not negate then
							local max_distance = 500

							if attacker_unit:base() then
								if attacker_unit:base().is_husk_player or managers.groupai:state():is_unit_team_AI(attacker_unit) then
									max_distance = managers.game_play_central:get_shotgun_push_range()
								end
							end

							if distance < max_distance then
								shotgun_push = true
							end
						end
					end
				end
			end

			if not shotgun_push then
				normal_push = true

				if is_shotgun == nil then
					local weapon_base = weapon:base()
					is_shotgun = weapon_base and not weapon_base.thrower_unit and weapon_base.is_category and weapon_base:is_category("shotgun")
				end
			end
		end
	else
		local result_type = "dmg_rcv"

		if i_result == 1 then
			result_type = "healed"

			attack_data.damage = self._health
		else
			self:_apply_damage_to_health(damage)
		end

		result = {
			variant = "bullet",
			type = result_type
		}
	end

	attack_data.result = result
	attack_data.is_synced = true

	if not self._no_blood and damage > 0 then
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	self:_on_damage_received(attack_data)

	if shotgun_push then
		local push_dir = attack_dir
		local push_hit_pos = hit_pos

		if attacker_unit:movement() and attacker_unit:movement().detect_look_dir then
			push_dir = attacker_unit:movement():detect_look_dir()
		end

		local hit_ray = world_g:raycast("ray", from_pos, body:center_of_mass(), "target_body", body)

		if hit_ray then
			push_hit_pos = hit_ray.position
		end

		managers.game_play_central:_do_shotgun_push(self._unit, push_hit_pos, push_dir, distance, attacker_unit)
	elseif normal_push then
		local active_actions = self._unit:movement()._active_actions
		local full_body_action = active_actions and active_actions[1]

		if not full_body_action or full_body_action:type() ~= "hurt" or not full_body_action._ragdolled then
			return
		end

		local hit_ray = world_g:raycast("ray", from_pos, body:center_of_mass(), "target_body", body)

		--use a fake ray if the raycast somehow misses
		if not hit_ray then
			hit_ray = {
				unit = self._unit,
				body = body,
				position = hit_pos,
				ray = attack_dir
			}
		end

		local push_multiplier = not is_shotgun and 2.5 or nil

		managers.game_play_central:physics_push(hit_ray, push_multiplier)
	end
end

function CopDamage:damage_melee(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	if self:is_friendly_fire(attack_data.attacker_unit) then
		return "friendly_fire"
	end

	if alive(attack_data.attacker_unit) and attack_data.attacker_unit:in_slot(16) then
		local has_surrendered = self._unit:brain().surrendered and self._unit:brain():surrendered() or self._unit:anim_data().surrender or self._unit:anim_data().hands_back or self._unit:anim_data().hands_tied

		if has_surrendered then
			return
		end
	end

	local result = nil
	local is_civilian, is_gangster, is_cop = nil
	local attacker_is_main_player = attack_data.attacker_unit == managers.player:player_unit()

	if CopDamage.is_civilian(self._unit:base()._tweak_table) then
		is_civilian = true
	elseif CopDamage.is_gangster(self._unit:base()._tweak_table) then
		is_gangster = true
	else
		is_cop = true
	end

	local head = self._head_body_name and not self._unit:in_slot(16) and not self._char_tweak.ignore_headshot and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name
	local damage = attack_data.damage
	local damage_effect = attack_data.damage_effect
	
	local damage_multiplier = 1
	local headshot_multiplier = 1

	local can_headshot = false
	if attacker_is_main_player then
		can_headshot = managers.player:has_category_upgrade("class_melee","can_headshot") and not self._char_tweak.ignore_headshot
		local critical_hit, crit_damage = self:roll_critical_hit(attack_data)

		if critical_hit then
			damage = crit_damage

			local critical_hits = self._char_tweak.critical_hits or {}
			local critical_damage_mul = critical_hits.damage_mul or self._char_tweak.headshot_dmg_mul

			if critical_damage_mul then
				damage_effect = damage_effect * critical_damage_mul
			else
				damage_effect = self._health * 10
			end

			attack_data.critical_hit = true

			if damage > 0 then
				managers.hud:on_crit_confirmed()
			end
		elseif damage > 0 then
			managers.hud:on_hit_confirmed()
		end

		if not is_civilian and tweak_data.achievement.cavity.melee_type == attack_data.name_id then
			managers.achievment:award(tweak_data.achievement.cavity.award)
		end
		if head and can_headshot then 
			attack_data.headshot = head
				
			if not self._damage_reduction_multiplier then
				if self._char_tweak.headshot_dmg_mul then
					headshot_multiplier = headshot_multiplier * self._char_tweak.headshot_dmg_mul
				end
			end
		
			managers.player:on_headshot_dealt()
			headshot_multiplier = headshot_multiplier * managers.player:upgrade_value("weapon", "passive_headshot_damage_multiplier", 1)
		end

		if managers.fire:is_set_on_fire(self._unit) then
			local third_degree_dmg_mul = managers.player:upgrade_value("subclass_areadenial", "effect_doubleroasting_damage_increase_mul", 1)
			local attacker_base_ext = alive(attacker_unit) and attacker_unit:base()

			if third_degree_dmg_mul > 1 then
				damage = damage * third_degree_dmg_mul
			end
		end
	end

	if self._marked_dmg_mul then
		damage = damage * self._marked_dmg_mul
		damage_effect = damage_effect * self._marked_dmg_mul

		local attacker = attack_data.attacker_unit

		if alive(attacker) then
			local attacker_dmg_ext = attacker:character_damage()
			local joker_dmg_bonus = attacker_dmg_ext and attacker_dmg_ext._joker_mark_dmg_bonus

			if joker_dmg_bonus then
				damage = damage * joker_dmg_bonus
			end
		end
	end
	
	damage_multiplier = self:_get_incoming_damage_multiplier(damage_multiplier)
	damage_multiplier = damage_multiplier * headshot_multiplier
	damage = damage * damage_multiplier 

	damage = self:_apply_damage_reduction(damage)
	damage_effect = self:_apply_damage_reduction(damage_effect)

	if self._unit:movement():cool() then
		damage = self._HEALTH_INIT
		damage_effect = self._HEALTH_INIT
	elseif self._char_tweak.DAMAGE_CLAMP_MELEE then --adding it while I'm at it in case it's needed for some reason
		damage = math_min(damage, self._char_tweak.DAMAGE_CLAMP_MELEE)
		damage_effect = math_min(damage_effect, self._char_tweak.DAMAGE_CLAMP_MELEE)
	end

	attack_data.raw_damage = damage

	damage = math_clamp(damage, 0, self._HEALTH_INIT)
	damage_effect = math_clamp(damage_effect, 0, self._HEALTH_INIT)

	local damage_percent = math_ceil(damage / self._HEALTH_INIT_PRECENT)
	local damage_effect_percent = math_ceil(damage_effect / self._HEALTH_INIT_PRECENT)

	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage_effect = damage_effect_percent * self._HEALTH_INIT_PRECENT

	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)
	damage_effect, damage_effect_percent = self:_apply_min_health_limit(damage_effect, damage_effect_percent)

	if self._immortal then
		damage = math_min(damage, self._health - 1)
		damage_effect = math_min(damage_effect, self._health - 1)
	end

	if self._health <= damage then
		damage_effect_percent = 1
		attack_data.damage = self._health
		attack_data.damage_effect = self._health

		if self:check_medic_heal() then
			result = {
				type = "healed",
				variant = "melee"
			}
		else
			result = {
				type = "death",
				variant = "melee"
			}

			self:die(attack_data)
			self:chk_killshot(attack_data.attacker_unit, "melee")
		end
	else
		attack_data.damage = damage
		attack_data.damage_effect = damage_effect

		local result_type = nil
		local is_tank = self._unit:base():has_tag("tank")
		if attack_data.shield_knock and self._char_tweak.damage.shield_knocked and not self:is_immune_to_shield_knockback() then
			result_type = "shield_knock"
		elseif attack_data.variant == "counter_tased" then
			result_type = "counter_tased"
		elseif attack_data.variant == "taser_tased" then
			if self._char_tweak.can_be_tased == nil or self._char_tweak.can_be_tased then
				result_type = "taser_tased"

				if attack_data.charge_lerp_value then
					local charge_power = math_lerp(0, 1, attack_data.charge_lerp_value)

					--damage_effect_percent here is used to sync how much the tase was charged (0-100%)
					damage_effect_percent = charge_power
					self._tased_time = math_lerp(1, 5, charge_power)
					self._tased_down_time = self._tased_time * 2
				else
					damage_effect_percent = 0.4
					self._tased_time = 2
					self._tased_down_time = self._tased_time * 2
				end
			end
		elseif attack_data.variant == "counter_spooc" and not is_tank and not self._unit:base():has_tag("boss") then
			result_type = "expl_hurt"
		end

		if not result_type then
			if attack_data.knockback_tier then 
				result_type = attack_data.knockback_tier and self.melee_knockback_tiers[math.min(#self.melee_knockback_tiers,attack_data.knockback_tier)]
				if result_type == "expl_hurt" and is_tank then 
					--expl_hurt is listed as a tier above hurt_heavy, but is not as severe an animation for bulldozers as hurt_heavy,
					--so don't punish the player for being TOO GOOD at punching things
					result_type = self.melee_knockback_tiers[4]
				end
			end
			if result_type == nil then 
				result_type = self:get_damage_type(damage_effect_percent, "melee")
			end
		end

		result = {
			type = result_type,
			variant = "melee"
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.variant = "melee"
	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position

	local snatch_pager, from_behind = nil

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			name_id = attack_data.name_id,
			variant = "melee"
		}

		managers.statistics:killed_by_anyone(data)

		if head then
			if can_headshot then 
				managers.player:on_lethal_headshot_dealt(attack_data.attacker_unit,attack_data)
			end
			if data.name == "deathvox_grenadier" then
				self._unit:damage():run_sequence_simple("grenadier_glass_break")
			else
				self:_spawn_head_gadget({
					position = attack_data.col_ray.body:position(),
					rotation = attack_data.col_ray.body:rotation(),
					dir = attack_data.col_ray.ray
				})
			end
		end

		if attacker_is_main_player then
			local special_comment = self:_check_special_death_conditions("melee", attack_data.col_ray.body, attack_data.attacker_unit, attack_data.name_id)

			self:_comment_death(attack_data.attacker_unit, self._unit, special_comment)
			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if is_civilian then
				managers.money:civilian_killed()
			else
				if managers.groupai:state():whisper_mode() and managers.blackmarket:equipped_mask().mask_id == tweak_data.achievement.cant_hear_you_scream.mask then
					managers.achievment:award_progress(tweak_data.achievement.cant_hear_you_scream.stat)
				end

				if is_cop and attack_data.name_id and attack_data.name_id == "fists" and Global.game_settings.level_id == "nightclub" then
					managers.achievment:award_progress(tweak_data.achievement.final_rule.stat)
				end

				mvec3_set(mvec_1, self._unit:position())
				mvec3_sub(mvec_1, attack_data.attacker_unit:position())
				mvec3_norm(mvec_1)
				mvec3_set(mvec_2, self._unit:rotation():y())

				from_behind = mvec3_dot(mvec_1, mvec_2) >= 0

				if math_random() < managers.player:upgrade_value("player", "melee_kill_snatch_pager_chance", 0) then
					snatch_pager = true
					self._unit:unit_data().has_alarm_pager = false
				end
			end
		elseif managers.groupai:state():is_unit_team_AI(attack_data.attacker_unit) then
			local special_comment = self:_check_special_death_conditions("melee", attack_data.col_ray.body, attack_data.attacker_unit, attack_data.name_id)

			self:_AI_comment_death(attack_data.attacker_unit, self._unit, special_comment)
		end
	end

	--only check for achievements if the attacker is the local player and they're alive (to be more specific, if their unit still exists)
	if attacker_is_main_player and tweak_data.blackmarket.melee_weapons[attack_data.name_id] then
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
			melee_weapons_pass = not achievement_data.melee_weapons or table_contains(achievement_data.melee_weapons, attack_data.name_id)
			type_pass = not achievement_data.melee_type or melee_type == achievement_data.melee_type
			result_pass = not achievement_data.result or attack_data.result.type == achievement_data.result
			enemy_pass = not achievement_data.enemy or enemy_type == achievement_data.enemy
			enemy_weapon_pass = not achievement_data.enemy_weapon or unit_weapon == achievement_data.enemy_weapon
			behind_pass = not achievement_data.from_behind or from_behind
			diff_pass = not achievement_data.difficulty or table_contains(achievement_data.difficulty, Global.game_settings.difficulty)
			health_pass = not achievement_data.health or health_ratio <= achievement_data.health
			level_pass = not achievement_data.level_id or (managers.job:current_level_id() or "") == achievement_data.level_id
			job_pass = not achievement_data.job or managers.job:current_real_job_id() == achievement_data.job
			jobs_pass = not achievement_data.jobs or table_contains(achievement_data.jobs, managers.job:current_real_job_id())
			enemy_count_pass = not achievement_data.enemy_kills or achievement_data.enemy_kills.count <= managers.statistics:session_enemy_killed_by_type(achievement_data.enemy_kills.enemy, "melee")
			tags_all_pass = not achievement_data.enemy_tags_all or enemy_base:has_all_tags(achievement_data.enemy_tags_all)
			tags_any_pass = not achievement_data.enemy_tags_any or enemy_base:has_any_tag(achievement_data.enemy_tags_any)
			cop_pass = not achievement_data.is_cop or is_cop
			gangster_pass = not achievement_data.is_gangster or is_gangster
			civilian_pass = not achievement_data.is_not_civilian or not is_civilian
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

	if not attacker or not alive(attacker) or attacker:id() == -1 then
		attack_data.attacker_unit = self._unit
	end

	local hit_offset_height = math_clamp(attack_data.col_ray.position.z - self._unit:position().z, 0, 300)
	local i_result = 0

	if snatch_pager then
		i_result = 3
	elseif result.type == "taser_tased" then
		i_result = 2
	elseif result.type == "healed" then
		i_result = 1
	end

	local body_index = self._unit:get_body_index(attack_data.col_ray.body:name())

	self:_send_melee_attack_result(attack_data, damage_percent, damage_effect_percent, hit_offset_height, i_result, body_index)
	self:_on_damage_received(attack_data)

	return result
end

function CopDamage:sync_damage_melee(attacker_unit, damage_percent, damage_effect_percent, i_body, hit_offset_height, i_result, death)
	if self._dead then
		return
	end

	local attack_data = {
		variant = "melee",
		attacker_unit = attacker_unit
	}
	local result, attack_dir = nil
	local body = self._unit:body(i_body)
	local head = self._head_body_name and not self._unit:in_slot(16) and not self._char_tweak.ignore_headshot and body and body:name() == self._ids_head_body_name
	local hit_pos = mvec3_cpy(body:position())
	attack_data.pos = hit_pos

	if attacker_unit then
		attack_dir = hit_pos - attacker_unit:movement():m_head_pos()
		mvec3_norm(attack_dir)
	else
		attack_dir = -self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir

	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local damage_effect = damage_effect_percent * self._HEALTH_INIT_PRECENT
	attack_data.damage = damage
	attack_data.damage_effect = damage_effect

	if death then
		attack_data.damage = self._health
		attack_data.damage_effect = self._health

		local melee_name_id = nil
		local valid_attacker = attacker_unit and attacker_unit:base()

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
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			name_id = melee_name_id,
			variant = "melee"
		}

		managers.statistics:killed_by_anyone(data)

		if head then
			if data.name == "deathvox_grenadier" then
				self._unit:damage():run_sequence_simple("grenadier_glass_break")
			else
				self:_spawn_head_gadget({
					position = body:position(),
					rotation = body:rotation(),
					dir = attack_dir
				})
			end
		end
	else
		local result_type = "dmg_rcv"

		if i_result == 1 then
			result_type = "healed"

			attack_data.damage = self._health
			attack_data.damage_effect = self._health
		else
			self:_apply_damage_to_health(damage)

			if i_result == 2 then
				self._tased_time = math_lerp(1, 5, damage_effect_percent)
				self._tased_down_time = self._tased_time * 2
			end
		end

		result = {
			variant = "melee",
			type = result_type
		}
	end

	attack_data.result = result
	attack_data.is_synced = true

	if i_result == 3 then
		self._unit:unit_data().has_alarm_pager = false
	end

	if not self._no_blood and damage > 0 then
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	self:_on_damage_received(attack_data)
end

function CopDamage:_check_special_death_conditions(variant, body, attacker_unit, weapon_unit)
	if not attacker_unit or not alive(attacker_unit) or not attacker_unit:base() then
		return
	end

	local special_deaths = self._char_tweak.special_deaths

	if not special_deaths or not special_deaths[variant] then
		return
	end

	local body_data = special_deaths[variant][body:name():key()]

	if not body_data then
		return
	end

	local required_character = body_data.character_name

	if required_character then
		local attacker_name = managers.criminals:character_name_by_unit(attacker_unit) or attacker_unit:base()._tweak_table or "error_no_name"

		if type(required_character) == "string" then
			if required_character ~= attacker_name then
				return
			end
		elseif type(required_character) == "table" and table_size(required_character) > 0 and not table_contains(required_character, attacker_name) then
			return
		end
	end

	if variant == "melee" then
		local required_melee = body_data.melee_weapon_id
		local melee_id = weapon_unit or "error_no_melee"

		if required_melee then
			if type(required_melee) == "string" then
				if required_melee ~= melee_id then
					return
				end
			elseif type(required_melee) == "table" and table_size(required_character) > 0 and not table_contains(required_melee, melee_id) then
				return
			end
		end
	elseif variant == "bullet" then
		local required_weapon = body_data.weapon_id

		if required_weapon then
			if not alive(weapon_unit) then
				return
			else
				local weapon_id = nil
				local factory_id = weapon_unit:base()._factory_id

				if factory_id then
					if weapon_unit:base():is_npc() then --uses newnpcraycastweaponbase (normally means bots and player husks)
						factory_id = utf8.sub(factory_id, 1, -5) --remove part of the factory id to be able to properly check it with a player variant
					end

					weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(factory_id)
				elseif weapon_unit:base().get_name_id then --needs testing
					weapon_id = weapon_unit:base():get_name_id()
					weapon_id = utf8.sub(weapon_id, 1, -4)
				end

				if not weapon_id then
					weapon_id = "error_no_id"
				end

				if type(required_weapon) == "string" then
					if required_weapon ~= weapon_id then
						return
					end
				elseif type(required_weapon) == "table" and table_size(required_character) > 0 and not table_contains(required_weapon, weapon_id) then
					return
				end
			end
		end
	end

	if body_data.sound_effect then
		self._unit:sound():play(body_data.sound_effect, nil, nil)
	end

	if body_data.sequence and self._unit:damage():has_sequence(body_data.sequence) then
		self._unit:damage():run_sequence_simple(body_data.sequence)
	end

	if body_data.special_comment then --local players or bots sync the voiceline, no need to do this for husks
		if attacker_unit == managers.player:player_unit() or Network:is_server() and managers.groupai:state():is_unit_team_AI(attacker_unit) then
			return body_data.special_comment
		end
	end
end

function CopDamage:build_suppression(amount, panic_chance)
	if self._dead or self._invulnerable or not self._char_tweak.suppression or self._unit:in_slot(16) then --adding Jokers and invulnerable characters
		return
	end

	local t = TimerManager:game():time()
	local sup_tweak = self._char_tweak.suppression

	if panic_chance then
		if panic_chance == -1 or panic_chance > 0 and sup_tweak.panic_chance_mul > 0 and math_random() < panic_chance * sup_tweak.panic_chance_mul then
			amount = "panic"
		end
	end

	local amount_val = nil

	if amount == "max" or amount == "panic" then
		local value = sup_tweak.brown_point or sup_tweak.react_point

		amount_val = value[2]
	elseif Network:is_server() and self._suppression_hardness_t and t < self._suppression_hardness_t then
		amount_val = amount * 0.5
	else
		amount_val = amount
	end

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

			sync_amount = math_clamp(math_ceil(sync_amount_ratio * 15), 1, 15)
		end

		managers.network:session():send_to_peer_synched(managers.network:session():peer(1), "suppression", self._unit, sync_amount)

		return
	end

	if self._suppression_data then
		self._suppression_data.value = math_min(self._suppression_data.brown_point or self._suppression_data.react_point, self._suppression_data.value + amount_val)
		self._suppression_data.last_build_t = t
		self._suppression_data.decay_t = t + self._suppression_data.duration

		managers.enemy:reschedule_delayed_clbk(self._suppression_data.decay_clbk_id, self._suppression_data.decay_t)
	else
		local duration = math_lerp(sup_tweak.duration[1], sup_tweak.duration[2], math_random())
		local decay_t = t + duration
		self._suppression_data = {
			value = amount_val,
			last_build_t = t,
			decay_t = decay_t,
			duration = duration,
			react_point = sup_tweak.react_point and math_lerp(sup_tweak.react_point[1], sup_tweak.react_point[2], math_random()),
			brown_point = sup_tweak.brown_point and math_lerp(sup_tweak.brown_point[1], sup_tweak.brown_point[2], math_random()),
			decay_clbk_id = "CopDamage_suppression" .. tostring(self._unit:key())
		}

		managers.enemy:add_delayed_clbk(self._suppression_data.decay_clbk_id, callback(self, self, "clbk_suppression_decay"), decay_t)
	end

	if not self._suppression_data.brown_zone and self._suppression_data.brown_point and self._suppression_data.brown_point <= self._suppression_data.value then
		self._suppression_data.brown_zone = true

		local state = amount == "panic" and "panic" or true

		self._unit:brain():on_suppressed(state)
	elseif amount == "panic" then
		self._unit:brain():on_suppressed("panic")
	end

	if not self._suppression_data.react_zone and self._suppression_data.react_point and self._suppression_data.react_point <= self._suppression_data.value then
		self._suppression_data.react_zone = true

		local state = amount == "panic" and "panic" or true

		self._unit:movement():on_suppressed(state)
	elseif amount == "panic" then
		self._unit:movement():on_suppressed("panic")
	end
end

function CopDamage:damage_fire(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	local attacker_unit = attack_data.attacker_unit
	local weap_unit = attack_data.weapon_unit

	if attacker_unit and alive(attacker_unit) then
		if attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			weap_unit = attack_data.attacker_unit
		end

		if self:is_friendly_fire(attacker_unit) then
			return "friendly_fire"
		end
	end

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)
	local damage = attack_data.damage

	if attacker_unit == managers.player:player_unit() and damage > 0 and weap_unit and alive(weap_unit) and attack_data.variant ~= "stun" and not attack_data.is_fire_dot_damage then
		local weap_base = weap_unit:base()
		local is_grenade_or_ground_fire = nil

		if weap_base then
			if weap_base.thrower_unit or weap_base.get_name_id and weap_base:get_name_id() == "environment_fire" then
				is_grenade_or_ground_fire = true
			end
		end

		if not is_grenade_or_ground_fire then
			managers.hud:on_hit_confirmed()
		end
	end

	if self._char_tweak.damage.fire_damage_mul then
		damage = damage * self._char_tweak.damage.fire_damage_mul
	end

	if self._marked_dmg_mul then
		damage = damage * self._marked_dmg_mul

		if not attack_data.is_fire_dot_damage and self._marked_dmg_dist_mul and alive(attacker_unit) then
			local dst = mvec3_dis(attacker_unit:position(), self._unit:position())
			local spott_dst = tweak_data.upgrades.values.player.marked_inc_dmg_distance[self._marked_dmg_dist_mul]

			if spott_dst[1] < dst then
				damage = damage * spott_dst[2]
			end
		end
	end

	local damage_multiplier = 1
	damage_multiplier = self:_get_incoming_damage_multiplier(damage_multiplier)
	damage = damage * damage_multiplier 

	if managers.fire:is_set_on_fire(self._unit) then
		local weapon_base = alive(weap_unit) and weap_unit:base()
		local stored_dmg_bonus = weapon_base and weapon_base._on_fire_dmg_mul

		if stored_dmg_bonus then
			damage = damage * stored_dmg_bonus
		else
			local third_degree_dmg_mul = 1
			local attacker_base_ext = alive(attacker_unit) and attacker_unit:base()

			if attacker_base_ext then
				if attacker_base_ext.is_local_player then
					third_degree_dmg_mul = managers.player:upgrade_value("subclass_areadenial", "effect_doubleroasting_damage_increase_mul", 1)
				elseif attacker_base_ext.is_husk_player then
					third_degree_dmg_mul = attacker_base_ext:upgrade_value("subclass_areadenial", "effect_doubleroasting_damage_increase_mul") or 1
				end
			end

			if third_degree_dmg_mul > 1 then
				damage = damage * third_degree_dmg_mul
			end
		end
	end

	damage = self:_apply_damage_reduction(damage)

	if self._char_tweak.DAMAGE_CLAMP_FIRE then
		damage = math_min(damage, self._char_tweak.DAMAGE_CLAMP_FIRE)
	end

	attack_data.raw_damage = damage

	damage = math_clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math_ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math_min(damage, self._health - 1)
	end

	local result = nil

	if self._health <= damage then
		attack_data.damage = self._health

		if self:check_medic_heal() then
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
			self:chk_killshot(attacker_unit, "fire")
		end
	else
		attack_data.damage = damage

		local result_type = "dmg_rcv"

		if not attack_data.is_fire_dot_damage and not deathvox:IsTotalCrackdownEnabled() then
			result_type = self:get_damage_type(damage_percent, "fire")
		end

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

		if attack_data.variant ~= "stun" then
			if data.name == "deathvox_grenadier" then
				self._unit:damage():run_sequence_simple("grenadier_glass_break")
			elseif self._head_body_name then
				local body = self._unit:body(self._head_body_name)

				self:_spawn_head_gadget({
					skip_push = true,
					position = body:position(),
					rotation = body:rotation()
				})
			end
		end

		managers.statistics:killed_by_anyone(data)

		if attacker_unit == managers.player:player_unit() then
			if is_civilian then
				managers.money:civilian_killed()
			elseif alive(attacker_unit) and alive(attack_data.weapon_unit) and not attack_data.weapon_unit:base().thrower_unit and managers.player:has_category_upgrade("temporary", "overkill_damage_multiplier") and attack_data.weapon_unit:base().is_category and attack_data.weapon_unit:base():is_category("shotgun", "saw") then
				managers.player:activate_temporary_upgrade("temporary", "overkill_damage_multiplier")
			end

			if alive(attacker_unit) then
				self:_comment_death(attacker_unit, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			self:_check_damage_achievements(attack_data, false)
		else
			if attacker_unit and alive(attacker_unit) and managers.groupai:state():is_unit_team_AI(attacker_unit) then
				self:_AI_comment_death(attacker_unit, self._unit)
			end
		end
	end

	local weapon_unit = weap_unit

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", damage_percent)
	end

	if not attack_data.is_fire_dot_damage and attack_data.fire_dot_data and result.type ~= "death" then
		local fire_dot_data = attack_data.fire_dot_data
		local flammable, start_dot_dance_antimation = nil

		if self._char_tweak.flammable == nil then
			flammable = true
		else
			flammable = self._char_tweak.flammable
		end

		if flammable then
			local distance = 1000
			local hit_pos = attack_data.col_ray.hit_position

			if hit_pos and attack_data.attacker_unit and alive(attack_data.attacker_unit) then
				local from_pos = nil

				if attack_data.attacker_unit:movement() and attack_data.attacker_unit:movement().m_head_pos then
					from_pos = attack_data.attacker_unit:movement():m_head_pos()
				else
					from_pos = attack_data.attacker_unit:position()
				end

				distance = mvec3_dis(hit_pos, from_pos)
			end

			local fire_dot_max_distance = tonumber(fire_dot_data.dot_trigger_max_distance) or 3000

			if distance < fire_dot_max_distance then
				local start_dot_damage_roll = math_random(100)
				local fire_dot_trigger_chance = fire_dot_data.dot_trigger_chance and tonumber(fire_dot_data.dot_trigger_chance) or 30

				if start_dot_damage_roll <= fire_dot_trigger_chance then
					local dot_damage = fire_dot_data.dot_damage and tonumber(fire_dot_data.dot_damage) or 25
					local t = TimerManager:game():time()

					managers.fire:add_doted_enemy(self._unit, t, weap_unit, fire_dot_data.dot_length, dot_damage, attacker_unit, attack_data.is_molotov)

					if result.type ~= "healed" and not deathvox:IsTotalCrackdownEnabled() then
						local use_animation_on_fire_damage = nil

						if self._char_tweak.use_animation_on_fire_damage == nil then
							use_animation_on_fire_damage = true
						else
							use_animation_on_fire_damage = self._char_tweak.use_animation_on_fire_damage
						end

						if use_animation_on_fire_damage then
							if self.get_last_time_unit_got_fire_damage then
								local last_time_received = self:get_last_time_unit_got_fire_damage()

								if last_time_received == nil or t - last_time_received > 1 then
									start_dot_dance_antimation = true
								end
							else
								start_dot_dance_antimation = true
							end
						end
					end
				end
			end

			fire_dot_data.start_dot_dance_antimation = start_dot_dance_antimation
			attack_data.fire_dot_data = fire_dot_data
		end

		if result.type ~= "healed" then
			if not start_dot_dance_antimation then --prevent fire_hurt from micro-stunning enemies when the dance animation isn't proced
				result.type = "dmg_rcv"
				attack_data.result.type = "dmg_rcv"
			else
				result.type = "fire_hurt"
				attack_data.result.type = "fire_hurt"
			end
		end
	end

	local attacker = attack_data.attacker_unit

	if not attacker or not alive(attacker) or attacker:id() == -1 then
		attacker = self._unit
	end

	self:_send_fire_attack_result(attack_data, attacker, damage_percent, attack_data.is_fire_dot_damage, attack_data.col_ray.ray, attack_data.result.type == "healed")
	self:_on_damage_received(attack_data)

	if not attack_data.is_fire_dot_damage and not is_civilian and attacker_unit and alive(attacker_unit) then
		managers.player:send_message(Message.OnEnemyShot, nil, self._unit, attack_data)
	end

	return result
end

function CopDamage:sync_damage_fire(attacker_unit, damage_percent, start_dot_dance_antimation, death, direction, weapon_type, weapon_id, healed)
	if self._dead then
		return
	end

	local variant = "fire"
	local attack_data = {
		variant = variant,
		attacker_unit = attacker_unit
	}

	local attacker = attack_data.attacker_unit
	local weapon_unit = nil

	if attacker and attacker:base() and attacker:base().thrower_unit then
		attacker = attacker:base():thrower_unit()
		weapon_unit = attack_data.attacker_unit
	end

	if not weapon_unit and weapon_id ~= "molotov" then
		weapon_unit = attacker_unit and attacker_unit:inventory() and alive(attacker_unit:inventory():equipped_unit()) and attacker_unit:inventory():equipped_unit()
	end

	local hit_pos = mvec3_cpy(self._unit:position())
	mvec3_set_z(hit_pos, hit_pos.z + 100)

	local attack_dir, result = nil

	if direction then
		attack_dir = direction
	elseif attacker_unit then
		local from_pos = nil

		if attacker_unit:movement() and attacker_unit:movement().m_head_pos then
			from_pos = attacker_unit:movement():m_head_pos()
		else
			from_pos = attacker_unit:position()
		end

		attack_dir = hit_pos - from_pos
		mvec3_norm(attack_dir)
	else
		attack_dir = -self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir
	hit_pos = hit_pos - attack_dir * 5
	attack_data.pos = hit_pos

	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	attack_data.damage = damage

	if death then
		attack_data.damage = self._health

		result = {
			type = "death",
			variant = variant
		}

		self:die(attack_data)
		self:chk_killshot(attacker_unit, "fire")

		local data = {
			variant = variant,
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			weapon_unit = weapon_unit,
			is_molotov = weapon_id == "molotov"
		}

		managers.statistics:killed_by_anyone(data)

		if data.name == "deathvox_grenadier" then
			self._unit:damage():run_sequence_simple("grenadier_glass_break")
		elseif self._head_body_name then
			local body = self._unit:body(self._head_body_name)

			self:_spawn_head_gadget({
				skip_push = true,
				position = body:position(),
				rotation = body:rotation()
			})
		end

		if attacker == managers.player:player_unit() then
			if alive(attacker) then
				self:_comment_death(attacker, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if CopDamage.is_civilian(self._unit:base()._tweak_table) then
				managers.money:civilian_killed()
			end

			self:_check_damage_achievements(attack_data, false)
		end
	else
		local result_type = "dmg_rcv"

		if healed then
			result_type = "healed"

			attack_data.damage = self._health
		else
			self:_apply_damage_to_health(damage)
		end

		result = {
			type = result_type,
			variant = variant
		}
	end

	attack_data.result = result
	attack_data.is_synced = true

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", damage_percent)
	end

	self:_on_damage_received(attack_data)
end

function CopDamage:damage_simple(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	if attack_data.variant == "graze" then
		local has_surrendered = self._unit:brain().surrendered and self._unit:brain():surrendered() or self._unit:anim_data().surrender or self._unit:anim_data().hands_back or self._unit:anim_data().hands_tied

		if has_surrendered then
			return
		end
	end

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)
	local result = nil
	local damage = attack_data.damage
	
	local damage_multiplier = 1
	damage_multiplier = self:_get_incoming_damage_multiplier(damage_multiplier)
	damage = damage * damage_multiplier 

	if managers.fire:is_set_on_fire(self._unit) then
		local third_degree_dmg_mul = 1
		local attacker_base_ext = alive(attacker_unit) and attacker_unit:base()

		if attacker_base_ext then
			if attacker_base_ext.is_local_player then
				third_degree_dmg_mul = managers.player:upgrade_value("subclass_areadenial", "effect_doubleroasting_damage_increase_mul", 1)
			elseif attacker_base_ext.is_husk_player then
				third_degree_dmg_mul = attacker_base_ext:upgrade_value("subclass_areadenial", "effect_doubleroasting_damage_increase_mul") or 1
			end
		end

		if third_degree_dmg_mul > 1 then
			damage = damage * third_degree_dmg_mul
		end
	end

	damage = self:_apply_damage_reduction(damage)

	if self._unit:movement():cool() and self._unit:base():char_tweak()["stealth_instant_kill"] then --allowing stealth insta-kill
		damage = self._HEALTH_INIT
	else
		--Graze damage is supposed to not benefit from any damage bonuses (as the damage is defined by the shot and skill upgrade you have), but it's not supposed to not be clamped like in vanilla, where everything can get nuked by it
		if self._char_tweak.DAMAGE_CLAMP_SHOCK then --no unit has DAMAGE_CLAMP_SHOCK, which is why Winters and the Phalanx can all die instantly to one headshot-proced Graze attack in vanilla
			damage = math_min(damage, self._char_tweak.DAMAGE_CLAMP_SHOCK)
		elseif self._char_tweak.DAMAGE_CLAMP_BULLET then --I would just replace the shock check with the bullet one, but checking for it first allows a custom clamp specifically against Graze to be used
			damage = math_min(damage, self._char_tweak.DAMAGE_CLAMP_BULLET)
		end
	end

	damage = math_clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math_ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math_min(damage, self._health - 1)
	end

	if self._health <= damage then
		attack_data.damage = self._health

		if self:check_medic_heal() then
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
			self:chk_killshot(attacker_unit, "shock")
		end
	else
		attack_data.damage = damage

		local result_type = nil

		--allowing knock_down and stagger, explanation at the end of the function
		if not self._char_tweak.immune_to_knock_down then
			local weapon_base = attack_data.attacker_unit and attack_data.attacker_unit:inventory() and attack_data.attacker_unit:inventory():equipped_unit() and attack_data.attacker_unit:inventory():equipped_unit():base()

			if weapon_base then
				local knock_down = weapon_base._knock_down and weapon_base._knock_down > 0 and math_random() < weapon_base._knock_down

				if knock_down then
					result_type = "knock_down"
				else
					local stagger = weapon_base._stagger and not self._has_been_staggered

					if stagger then
						result_type = "stagger"
						self._has_been_staggered = true
					end
				end
			end
		end

		if not result_type then
			result_type = self:get_damage_type(damage_percent)
		end

		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result

	local attacker_unit = attack_data.attacker_unit

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			owner = attack_data.owner,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant
		}

		managers.statistics:killed_by_anyone(data)

		if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			data.weapon_unit = attack_data.attacker_unit
		end

		if attacker_unit == managers.player:player_unit() then
			if is_civilian then
				managers.money:civilian_killed()
			elseif alive(attacker_unit) and attack_data.weapon_unit and attack_data.weapon_unit:base().weapon_tweak_data and not attack_data.weapon_unit:base().thrower_unit and managers.player:has_category_upgrade("temporary", "overkill_damage_multiplier") and attack_data.weapon_unit:base().is_category and attack_data.weapon_unit:base():is_category("shotgun", "saw") then
				managers.player:activate_temporary_upgrade("temporary", "overkill_damage_multiplier")
			end

			if alive(attacker_unit) then
				self:_comment_death(attacker_unit, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if is_civilian then
				managers.money:civilian_killed()
			end

			self:_check_damage_achievements(attack_data, false)
		elseif alive(attacker_unit) and managers.groupai:state():is_unit_team_AI(attacker_unit) then
			self:_AI_comment_death(attacker_unit, self._unit)
		end
	end

	local attacker = attack_data.attacker_unit

	if not attacker or not alive(attacker) or attacker:id() == -1 then
		attacker = self._unit
	end

	if not self._no_blood and damage > 0 then
		managers.game_play_central:sync_play_impact_flesh(attack_data.pos, attack_data.attack_dir)
	end

	local i_result = nil

	if result.type == "healed" then
		i_result = 1
	else
		i_result = 0
	end

	self:_send_simple_attack_result(attacker, damage_percent, self:_get_attack_variant_index(attack_data.variant), i_result)
	self:_on_damage_received(attack_data)

	if not is_civilian and attacker_unit and alive(attacker_unit) then
		managers.player:send_message(Message.OnEnemyShot, nil, self._unit, attack_data)
	end

	return result
end

function CopDamage:sync_damage_simple(attacker_unit, damage_percent, i_attack_variant, i_result, death)
	if self._dead then
		return
	end

	local variant = CopDamage._ATTACK_VARIANTS[i_attack_variant]
	local attack_data = {
		variant = variant,
		attacker_unit = attacker_unit
	}

	local hit_pos = mvec3_cpy(self._unit:position())
	mvec3_set_z(hit_pos, hit_pos.z + 100)

	local attack_dir, result = nil

	if attacker_unit then
		local from_pos = nil

		if attacker_unit:movement() and attacker_unit:movement().m_head_pos then
			from_pos = attacker_unit:movement():m_head_pos()
		else
			from_pos = attacker_unit:position()
		end

		attack_dir = hit_pos - from_pos
		mvec3_norm(attack_dir)
	else
		attack_dir = -self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir
	hit_pos = hit_pos - attack_dir * 5
	attack_data.pos = hit_pos

	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	attack_data.damage = damage

	if death then
		attack_data.damage = self._health

		result = {
			type = "death",
			variant = variant
		}

		self:die(attack_data)
		self:chk_killshot(attacker_unit, "shock")

		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit(),
			variant = variant
		}

		local attacker = attacker_unit

		if attacker and attacker:base() and attacker:base().thrower_unit then
			data.weapon_unit = attacker_unit
		end

		if data.weapon_unit then
			managers.statistics:killed_by_anyone(data)
		end
	else
		local result_type = "dmg_rcv"

		if i_result == 1 then
			result_type = "healed"

			attack_data.damage = self._health
		else
			self:_apply_damage_to_health(damage)
		end

		result = {
			type = result_type,
			variant = variant
		}
	end

	attack_data.result = result
	attack_data.is_synced = true

	if not self._no_blood and damage > 0 then
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	self:_on_damage_received(attack_data)
end

function CopDamage:damage_dot(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	if attack_data.attacker_unit and alive(attack_data.attacker_unit) and self:is_friendly_fire(attack_data.attacker_unit) then --you never know, maybe it can be useful later on
		return "friendly_fire"
	end

	local damage = attack_data.damage

	if self._char_tweak.damage.dot_damage_mul then
		damage = damage * self._char_tweak.damage.dot_damage_mul
	end

	if self._marked_dmg_mul then
		damage = damage * self._marked_dmg_mul
	end

	if managers.fire:is_set_on_fire(self._unit) then
		local third_degree_dmg_mul = 1
		local attacker = attack_data.attacker_unit
		local attacker_base_ext = alive(attacker) and attacker:base()

		if attacker_base_ext then
			if attacker_base_ext.is_local_player then
				third_degree_dmg_mul = managers.player:upgrade_value("subclass_areadenial", "effect_doubleroasting_damage_increase_mul", 1)
			elseif attacker_base_ext.is_husk_player then
				third_degree_dmg_mul = attacker_base_ext:upgrade_value("subclass_areadenial", "effect_doubleroasting_damage_increase_mul") or 1
			end
		end

		if third_degree_dmg_mul > 1 then
			damage = damage * third_degree_dmg_mul
		end
	end

	local damage_multiplier = 1
	damage_multiplier = self:_get_incoming_damage_multiplier(damage_multiplier)
	damage = damage * damage_multiplier 
	
	damage = self:_apply_damage_reduction(damage)

	if self._char_tweak.DAMAGE_CLAMP_DOT then --never hurts to add these additional clamps as they do nothing if you don't specifically add them in charactertweakdata
		damage = math_min(damage, self._char_tweak.DAMAGE_CLAMP_DOT)
	end

	attack_data.raw_damage = damage

	damage = math_clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math_ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math_min(damage, self._health - 1)
	end

	if not attack_data.variant then
		attack_data.variant = "dot"
	end

	local result = nil

	if self._health <= damage then
		attack_data.damage = self._health

		if self:check_medic_heal() then
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
			self:chk_killshot(attack_data.attacker_unit, attack_data.variant, nil, attack_data.weapon_id)
		end
	else
		attack_data.damage = damage

		local result_type = attack_data.hurt_animation and self:get_damage_type(damage_percent, attack_data.variant) or "dmg_rcv"

		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position

	if result.type == "death" then
		local variant = attack_data.weapon_id and tweak_data.blackmarket and tweak_data.blackmarket.melee_weapons and tweak_data.blackmarket.melee_weapons[attack_data.weapon_id] and "melee" or attack_data.variant
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			owner = attack_data.owner,
			weapon_unit = attack_data.weapon_unit,
			variant = variant,
			name_id = attack_data.weapon_id
		}

		managers.statistics:killed_by_anyone(data)

		if attack_data.attacker_unit == managers.player:player_unit() then
			if alive(attack_data.attacker_unit) then
				self:_comment_death(attack_data.attacker_unit, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if CopDamage.is_civilian(self._unit:base()._tweak_table) then
				managers.money:civilian_killed()
			end

			self:_check_damage_achievements(attack_data, false)
		end
	end

	if attack_data.hurt_animation and result.type ~= "poison_hurt" then
		attack_data.hurt_animation = false
	end

	local attacker = attack_data.attacker_unit

	if not attacker or not alive(attacker) or attacker:id() == -1 then
		attacker = self._unit
	end

	local sync_attack_variant = attack_data.variant

	if result.type == "healed" then
		if attack_data.variant == "poison" then
			sync_attack_variant = "poison_healed"
		else
			sync_attack_variant = "dot_healed"
		end
	end

	self:_send_dot_attack_result(attack_data, attacker, damage_percent, sync_attack_variant)
	self:_on_damage_received(attack_data)
end

function CopDamage:sync_damage_dot(attacker_unit, damage_percent, death, variant, hurt_animation, weapon_id)
	if self._dead then
		return
	end

	local attack_variant, was_healed, result = nil

	if variant == "poison_healed" then
		attack_variant = "poison"
		was_healed = true
	elseif variant == "dot_healed" then
		attack_variant = "dot"
		was_healed = true
	else
		attack_variant = variant
	end

	local attack_data = {
		variant = attack_variant,
		attacker_unit = attacker_unit
	}
	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	attack_data.damage = damage

	if death then
		attack_data.damage = self._health

		result = {
			type = "death",
			variant = attack_variant
		}

		self:die(attack_data)
		self:chk_killshot(attacker_unit, attack_variant, nil, weapon_id)

		local real_variant = weapon_id and tweak_data.blackmarket and tweak_data.blackmarket.melee_weapons and tweak_data.blackmarket.melee_weapons[weapon_id] and "melee" or attack_data.variant
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			weapon_unit = not weapon_id and attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit(),
			variant = real_variant,
			name_id = weapon_id
		}

		if data.weapon_unit or data.name_id then
			managers.statistics:killed_by_anyone(data)
		end
	else
		local result_type = "dmg_rcv"

		if was_healed then
			result_type = "healed"

			attack_data.damage = self._health
		else
			self:_apply_damage_to_health(damage)
		end

		result = {
			variant = attack_variant,
			type = result_type
		}
	end

	attack_data.result = result
	attack_data.weapon_id = weapon_id
	attack_data.is_synced = true

	self:_on_damage_received(attack_data)
end

function CopDamage:get_visible_body_part(shoot_from_pos, aim_vec)
	local dis = mvec3_dis(shoot_from_pos, self._unit:position())

	if dis > 3500 then
		self:shoot_pos_mid(aim_vec)
	else
		self._aim_bodies = {}

		table_insert(self._aim_bodies, self._unit:body("b_head"))
		table_insert(self._aim_bodies, self._unit:body("b_spine1"))
		table_insert(self._aim_bodies, self._unit:body("b_spine2"))
		table_insert(self._aim_bodies, self._unit:body("b_right_thigh"))
		table_insert(self._aim_bodies, self._unit:body("b_left_thigh"))

		local uncovered_body, best_angle = nil

		for i, body in ipairs(self._aim_bodies) do
			local body_pos = body:center_of_mass()
			local body_vec = body_pos - shoot_from_pos
			local body_angle = body_vec:angle(aim_vec)

			if not best_angle or body_angle < best_angle then
				local aim_ray = World:raycast("ray", shoot_from_pos, body_pos, "sphere_cast_radius", 5, "bundle", 4, "slot_mask", managers.slot:get_mask("enemy_shield_check"))

				if not aim_ray then
					uncovered_body = body
					best_angle = body_angle
				end
			end
		end

		if uncovered_body then
			mvec3_set(aim_vec, uncovered_body:center_of_mass())
		else
			self:shoot_pos_mid(aim_vec)
		end
	end
end

function CopDamage:is_friendly_fire(unit)
	if not unit or not unit:movement() or not unit:movement().friendly_fire or not unit:movement().team or not self._unit:movement().team then
		return false
	end

	if unit:movement():friendly_fire() then
		return false
	end

	if unit:movement():team() ~= self._unit:movement():team() then
		return false
	end

	return not unit:movement():team().foes[self._unit:movement():team().id]
end


Hooks:PreHook(CopDamage,"_on_death","deathvox_on_cop_damage_death",function(self)
	self._unit:set_extension_update_enabled(Idstring("character_damage"),false)
end)

--these are not used because they can apparently interfere with the unit's ability to despawn, even after it has died
function CopDamage:register_stuck_tripmine(unit)
	table.insert(self._stuck_tripmines,unit)
end

function CopDamage:unregister_stuck_tripmine(unit,index)
	for i,registered_tripmine in pairs(self._stuck_tripmines) do 
		if (i == index) or (registered_tripmine == unit) then 
			return table.remove(i)
		end
	end
end

function CopDamage:detonate_stuck_tripmines()
	self:remove_listener("stuck_tripmines_detonate_on_death")
	for i=#self._stuck_tripmines,1,-1 do 
		local tripmine_unit = self:unregister_stuck_tripmine(nil,i)
		if alive(tripmine_unit) then 
			tripmine_unit:base():explode()
		end
	end
end

function CopDamage:_spawn_head_gadget(params)
	local head_gear = self._head_gear
	local my_unit = self._unit

	if not head_gear then
		return
	end

	self._head_gear = nil

	local gear_object = self._head_gear_object

	if gear_object then
		local nr_gear_objects = self._nr_head_gear_objects

		if nr_gear_objects then
			for i = 1, nr_gear_objects do
				local head_gear_obj_name = gear_object .. tostring_g(i)

				my_unit:get_object(idstr_func(head_gear_obj_name)):set_visibility(false)
			end
		else
			my_unit:get_object(idstr_func(gear_object)):set_visibility(false)
		end

		local gear_decal_mesh = self._head_gear_decal_mesh

		if gear_decal_mesh then
			local mesh_name_idstr = idstr_func(gear_decal_mesh)

			my_unit:decal_surface(mesh_name_idstr):set_mesh_material(mesh_name_idstr, ids_flesh)
		end
	end

	local unit = world_g:spawn_unit(idstr_func(head_gear), params.position, params.rotation)
	self._head_gear_unit = unit

	if params.skip_push then
		return
	end

	local dir = math_up - params.dir / 2
	dir = dir:spread(25)
	local body = unit:body(0)

	body:push_at(body:mass(), dir * math_lerp(300, 650, math_random()), unit:position() + Vector3(math_random(), math_random(), math_random()))

	if not table_contains(big_enemy_visor_shattering_table, my_unit:name()) then
		return
	end

	local head_obj = idstr_func("Head")
	local head_object_get = my_unit:get_object(head_obj)
	
	if not head_object_get then
		return
	end
	
	local world_g = World		
	local sound_ext = my_unit:sound()	
	
	world_g:effect_manager():spawn({
		effect = idstr_func("effects/particles/bullet_hit/glass_breakable/bullet_hit_glass_breakable"),
		parent = head_object_get		
	})			
	
	sound_ext:play("swat_heavy_visor_shatter", nil, nil)
	sound_ext:play("swat_heavy_visor_shatter", nil, nil)
	sound_ext:play("swat_heavy_visor_shatter", nil, nil)
end

if deathvox:IsTotalCrackdownEnabled() then
	function CopDamage:set_health_regen(regen)
		self._regen_percent = regen or nil

		local clbk_id = self._health_regen_clbk_id

		if regen then
			if not clbk_id then
				clbk_id = "health_regen" .. tostring_g(self._unit:key())
				self._health_regen_clbk_id = clbk_id

				managers.enemy:add_delayed_clbk(clbk_id, callback(self, self, "clbk_regen"), TimerManager:game():time() + 1)
			end
		elseif clbk_id then
			if not self._start_regen_on_damage_taken then
				managers.enemy:remove_delayed_clbk(clbk_id)
			end

			self._start_regen_on_damage_taken = nil
			self._health_regen_clbk_id = nil
		end
	end

	function CopDamage:clbk_regen()
		local init_health = self._HEALTH_INIT
		local new_health = init_health * self._regen_percent + self._health

		if new_health >= init_health then
			self._health = init_health
			self._health_ratio = 1

			self._start_regen_on_damage_taken = true
		else
			self._health = new_health
			self._health_ratio = new_health / init_health

			managers.enemy:add_delayed_clbk(self._health_regen_clbk_id, callback(self, self, "clbk_regen"), TimerManager:game():time() + 1)
		end

		self:_update_debug_ws()

		managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "character_damage", HuskCopDamage._NET_EVENTS.joker_regen)
	end

	local destroy_original = CopDamage.destroy
	function CopDamage:destroy(...)
		destroy_original(self, ...)

		local head_gear_unit = self._head_gear_unit

		if alive_g(head_gear_unit) then
			head_gear_unit:set_slot(0)

			self._head_gear_unit = nil
		end

		self:set_health_regen()
	end
else
	local destroy_original = CopDamage.destroy
	function CopDamage:destroy(...)
		destroy_original(self, ...)

		local head_gear_unit = self._head_gear_unit

		if alive_g(head_gear_unit) then
			head_gear_unit:set_slot(0)

			self._head_gear_unit = nil
		end
	end
end

function CopDamage:_on_stun_hit_exit()
	local acc_reset_t = TimerManager:game():time() + self._ON_STUN_ACCURACY_DECREASE_TIME
	local reset_acc_clbk_id = self._reset_acc_clbk_id

	if reset_acc_clbk_id then
		managers.enemy:reschedule_delayed_clbk(reset_acc_clbk_id, acc_reset_t)
	else
		local original_multiplier = self._accuracy_multiplier
		self._original_acc_mul = original_multiplier

		self:set_accuracy_multiplier(self._ON_STUN_ACCURACY_DECREASE * original_multiplier)

		local function f()
			self:set_accuracy_multiplier(self._original_acc_mul)
			self._original_acc_mul = nil
			self._reset_acc_clbk_id = nil
		end

		reset_acc_clbk_id = "ResetAccuracy" .. tostring_g(self._unit:key())
		self._reset_acc_clbk_id = reset_acc_clbk_id

		managers.enemy:add_delayed_clbk(reset_acc_clbk_id, f, acc_reset_t)

		self._stun_exit_clbk = nil

		self._listener_holder:remove("after_stun_accuracy")
	end
end
