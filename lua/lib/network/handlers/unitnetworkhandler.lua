if deathvox:IsTotalCrackdownEnabled() then 

	function UnitNetworkHandler:sync_trip_mine_explode_spawn_fire(unit, user_unit, ray_from, ray_to, damage_size, damage, added_time, range_multiplier, sender)
		if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
			return
		end
		if damage == 0 and damage_size == 0 then --signifies that added_time field is used to hold the new mode, be it trigger or payload
			local new_mode = added_time and TripmineControlMenu.NetworkSyncIDs[added_time]
			if new_mode then 
--				if TripmineControlMenu.VALID_TRIPMINE_TRIGGER_MODES[new_mode] then 
				if range_multiplier == 0 then
					unit:base():_set_trigger_mode(new_mode)
				elseif range_multiplier == 1 then 
--				elseif TripmineControlMenu.VALID_TRIPMINE_PAYLOAD_MODES[new_mode] then 
					unit:base():_set_payload_mode(new_mode)
				end
			end
			return
		end
		
		if not alive(user_unit) then
			user_unit = nil
		end

		if alive(unit) then
			unit:base():sync_trip_mine_explode_and_spawn_fire(user_unit, ray_from, ray_to, damage_size, damage, added_time, range_multiplier)
		end
	end

	--spoofed to sync sentry ammo type and firemode (and resultant laser color) in sentry control menu
	local orig_sync_movement_state = UnitNetworkHandler.sync_player_movement_state
	function UnitNetworkHandler:sync_player_movement_state(unit, state, down_time,unit_id_str,...)
	--note: unit_id_str is also a string value that can be spoofed
		if not alive(unit) then
			return
		end
	
		if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
			return
		end
		if (type(unit.weapon) == "function") and unit:weapon() then 
			--for sentries, since firemode and ammotype are usually set separately, i did not choose to sync both at the same time
			if down_time == 1 then 
				unit:weapon():_set_sentry_firemode(state)
				return
			elseif down_time == 2 then 
				unit:weapon():_set_ammo_type(state)
				return
			end
			return
		end
		return orig_sync_movement_state(self,unit,state,down_time,unit_id_str,...)
	end
	
	function UnitNetworkHandler:revive_player(revive_health_level, revive_damage_reduction, sender)
		local peer = self._verify_sender(sender)

		if not self._verify_gamestate(self._gamestate_filter.need_revive) or not peer then
			return
		end

		local player = managers.player:player_unit()
		local char_damage = player:character_damage()
		if revive_health_level > 0 and alive(player) then
			char_damage:set_revive_boost(revive_health_level)
			if revive_health_level == 1 then --restore down if revived from fak
			--since iirc there are no other sources of this upgrade except for FAKs in TCD, so it should be safe to use as a flag for a revive from a FAK
				char_damage._revives = Application:digest_value(Application:digest_value(char_damage._revives, false) + 1, true)
			end
		end

		if revive_damage_reduction > 0 then
			revive_damage_reduction = math.clamp(revive_damage_reduction, 1, 2)
			local tweak = tweak_data.upgrades.first_aid_kit.revived_damage_reduction[revive_damage_reduction]

			managers.player:activate_temporary_property("revived_damage_reduction", tweak[2], tweak[1])
		end

		if alive(player) then
			player:character_damage():revive()
		end
	end
	
	--same as vanilla but disabled HUD element in order to prevent conflicting with damage overshield mechanic
	--if/when the actual absorption mechanic is overhauled, this function (and its accompanying HUD element) may also need to be revisited
	function UnitNetworkHandler:sync_damage_absorption_hud(absorption_amount, sender)
		local peer = self._verify_sender(sender)

		if not peer or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
			return
		end

		local teammate_panel = managers.hud:get_teammate_panel_by_peer(peer)

		if teammate_panel then
--			teammate_panel:set_absorb_active(absorption_amount)
		end
	end
	
	function UnitNetworkHandler:place_trip_mine(pos, normal, sensor_upgrade, rpc)
		local peer = self._verify_sender(rpc)

		if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
			return
		end
		
--no anticheat for this since this is now a grenade AND can be replenished in multiple ways
--		if not managers.player:verify_equipment(peer:id(), "trip_mine") then
--			return
--		end

		local rot = Rotation(normal, math.UP)
		local peer = self._verify_sender(rpc)
		local unit = TripMineBase.spawn(pos, rot, sensor_upgrade, peer:id())

		unit:base():set_server_information(peer:id())
		rpc:activate_trip_mine(unit)
	end
	
	--used for tripmine syncing
		--from host as client
	local orig_sync_attach_projectile = UnitNetworkHandler.sync_attach_projectile
	function UnitNetworkHandler:sync_attach_projectile(unit, instant_dynamic_pickup, parent_unit, parent_body, parent_object, local_pos, dir, projectile_type_index, peer_id, sender,...)
		local peer = self._verify_sender(sender)

		if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
--			print("_verify failed!!!")

			return
		end
		
		if alive(unit) and unit:base() and not unit:base().set_thrower_unit_by_peer_id then 
			local bits = projectile_type_index - 1 --change range to [0,63] instead of [1,64]
			local radius_upgrade_level = Bitwise:rshift(bits,TripMineBase.radius_upgrade_shift)
			local vulnerability_upgrade_level = Bitwise:rshift(bits,TripMineBase.vulnerability_upgrade_shift) % 2^TripMineBase.vulnerability_upgrade_shift
			local rot = Rotation(dir,math.UP)
			if Network:is_server() then 
				local tripmine_unit = TripMineBase.spawn(local_pos,rot,true,peer_id)
				self:activate_trip_mine(trimpine_unit)
				tripmine_unit:base():set_server_information(peer_id)
				managers.network:session():send_to_peers("sync_attach_projectile",tripmine_unit,false,parent_unit,parent_body,parent_object,local_pos,dir,projectile_type_index,peer_id)

				return
			elseif unit:base().get_name_id and unit:base():get_name_id() == "trip_mine" then 
				unit:base():attach_to_enemy(parent_unit,local_pos,rot,parent_body,radius_upgrade_level,vulnerability_upgrade_level)
				return
			end
		end
			--assume that this is the spoofed function
		return orig_sync_attach_projectile(self,unit, instant_dynamic_pickup, parent_unit, parent_body, parent_object, local_pos, dir, projectile_type_index, peer_id, sender,...)
	end

	function UnitNetworkHandler:sync_contour_state(unit, u_id, type, state, multiplier, sender)
		if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
			return
		end

		local peer = self._verify_sender(sender)

		if not peer then
			return
		end

		local contour_unit = nil

		if alive(unit) and unit:id() ~= -1 then
			contour_unit = unit
		else
			local unit_data = managers.enemy:get_corpse_unit_data_from_id(u_id)

			if unit_data then
				contour_unit = unit_data.unit
			end
		end

		if not contour_unit then
			return
		end

		if state then
			if Network:is_server() then
				local peer_unit = peer:unit()

				if alive(peer_unit) and peer_unit:id() ~= -1 and peer_unit:base() and peer_unit:base():upgrade_value("player", "convert_enemies_target_marked") then
					contour_unit:contour():add(ContourExt.indexed_types[type], false, multiplier, nil, nil, peer:id())
				else
					contour_unit:contour():add(ContourExt.indexed_types[type], false, multiplier)
				end
			else
				contour_unit:contour():add(ContourExt.indexed_types[type], false, multiplier)
			end
		else
			contour_unit:contour():remove(ContourExt.indexed_types[type], nil)
		end
	end
end
--[[
local orig_sync_deployable_attachment = UnitNetworkHandler.sync_deployable_attachment
function UnitNetworkHandler:sync_deployable_attachment(unit, body, relative_pos, relative_rot, rpc,...)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not alive(unit) then
		return
	end

	if unit:base() and unit:base().get_name_id and unit:base():get_name_id() == "trip_mine" then 
		return orig_sync_deployable_attachment(unit, body, relative_pos, relative_rot, rpc,...)
	end
end
--]]

function UnitNetworkHandler:sync_friendly_fire_damage(peer_id, unit, damage, variant, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	if managers.network:session():local_peer():id() == peer_id then
		local player_unit = managers.player:player_unit()

		if alive(player_unit) and alive(unit) then
			local attack_info = {
				ignore_suppression = true,
				attacker_unit = unit,
				damage = damage,
				variant = variant,
				col_ray = {
					position = mvector3.copy(unit:movement():m_head_pos())
				}
			}

			if variant == "bullet" or variant == "projectile" then
				player_unit:character_damage():damage_bullet(attack_info)
			elseif variant == "melee" or variant == "taser_tased" then --allow melee tase to deal damage
				if variant == "taser_tased" then
					attack_info.tase_player = true --allow melee tase to do a non-lethal tase against other players
				end

				local push_vec = player_unit:movement():m_head_pos() - unit:movement():m_head_pos()

				attack_info.push_vel = push_vec:with_z(0.1):normalized() * 600

				player_unit:character_damage():damage_melee(attack_info)
			elseif variant == "fire" then
				player_unit:character_damage():damage_fire(attack_info)
			end
		end
	end

	managers.job:set_memory("trophy_flawless", true, false)
end

function UnitNetworkHandler:sync_add_doted_enemy(enemy_unit, variant, weapon_unit, dot_length, dot_damage, user_unit, is_molotov_or_hurt_animation, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	if variant == 0 then
		managers.fire:sync_add_fire_dot(enemy_unit, nil, weapon_unit, dot_length, dot_damage, user_unit, is_molotov_or_hurt_animation)
	else
		if variant == 1 then
			variant = "poison"
		elseif variant == 2 then
			variant = "dot"
		else
			variant = nil
		end

		if weapon_unit and alive(weapon_unit) and weapon_unit:base() then
			if weapon_unit:base().is_husk_player then
				local peer_id = managers.network:session():peer_by_unit(weapon_unit):id()
				local peer = managers.network:session():peer(peer_id)

				weapon_unit = peer:melee_id()
			else
				weapon_unit = weapon_unit:base().melee_weapon and weapon_unit:base():melee_weapon() or weapon_unit

				if weapon_unit == "weapon" then
					weapon_unit = nil
				end
			end
		end

		managers.dot:sync_add_dot_damage(enemy_unit, variant, weapon_unit, dot_length, dot_damage, user_unit, is_molotov_or_hurt_animation, variant, weapon_id)
	end
end

function UnitNetworkHandler:action_aim_state(unit, state)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(unit) then
		return
	end

	if state then
		local shoot_action = {
			block_type = "action",
			body_part = 3,
			type = "shoot"
		}

		unit:movement():action_request(shoot_action)
	else
		unit:movement():sync_action_aim_end()
	end
end

function UnitNetworkHandler:action_spooc_start(unit, target_u_pos, flying_strike, action_id, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) or not self._verify_character(unit) then
		return
	end

	local action_desc = {
		block_type = "walk",
		type = "spooc",
		path_index = 1,
		body_part = 1,
		nav_path = {
			unit:position()
		},
		target_u_pos = target_u_pos,
		flying_strike = flying_strike,
		action_id = action_id,
		blocks = {
			idle = -1,
			act = -1,
			turn = -1,
			walk = -1
		}
	}

	if flying_strike then
		action_desc.blocks.light_hurt = -1
		action_desc.blocks.heavy_hurt = -1
		action_desc.blocks.fire_hurt = -1
		action_desc.blocks.hurt = -1
		action_desc.blocks.expl_hurt = -1
		action_desc.blocks.taser_tased = -1
	end

	unit:movement():action_request(action_desc)
end

function UnitNetworkHandler:action_hurt_start(unit, hurt_type_idx, body_part, death_type_idx, type_idx, variant_idx, direction_vec, hit_pos, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	local hurt_type = CopActionHurt.idx_to_hurt_type(hurt_type_idx)

	if hurt_type == "death" then
		if not alive(unit) then
			return
		end

		local action_type = CopActionHurt.idx_to_type(type_idx)
		local variant = CopActionHurt.idx_to_variant(variant_idx)
		local block_type = hurt_type
		local mov_ext = unit:movement()
		local client_interrupt = nil

		if mov_ext._queued_actions then
			mov_ext._queued_actions = {}
		end

		if mov_ext._rope then
			mov_ext._rope:base():retract()

			mov_ext._rope = nil
			mov_ext._rope_death = true

			if unit:sound().anim_clbk_play_sound then
				unit:sound():anim_clbk_play_sound(unit, "repel_end")
			end
		end

		if Network:is_server() then
			mov_ext:set_attention()
		else
			client_interrupt = true
			mov_ext:synch_attention()
		end

		local blocks = {
			act = -1,
			aim = -1,
			action = -1,
			tase = -1,
			walk = -1,
			light_hurt = -1,
			death = -1
		}

		local action_data = {
			allow_network = false,
			client_interrupt = client_interrupt,
			hurt_type = hurt_type,
			block_type = block_type,
			blocks = blocks,
			body_part = body_part,
			death_type = CopActionHurt.idx_to_death_type(death_type_idx),
			type = action_type,
			variant = variant,
			direction_vec = direction_vec,
			hit_pos = hit_pos,
			sync_t = Application:time() - peer:qos().ping / 1000
		}

		unit:movement():action_request(action_data)
	else
		if not self._verify_character(unit) then
			return
		end

		local action_data = nil
		local action_type = CopActionHurt.idx_to_type(type_idx)

		if action_type == "healed" then
			--[[local dmg_ext = unit:character_damage()
			dmg_ext._health = dmg_ext._HEALTH_INIT
			dmg_ext._health_ratio = 1

			if unit:contour() then
				unit:contour():add("medic_heal")
				unit:contour():flash("medic_heal", 0.2)
			end]]

			if unit:anim_data() and unit:anim_data().act then
				return
			end

			action_data = {
				body_part = body_part,
				type = "healed",
				client_interrupt = Network:is_client()
			}
		else
			local block_type = hurt_type

			if hurt_type == "expl_hurt" or hurt_type == "fire_hurt" or hurt_type == "poison_hurt" or hurt_type == "taser_tased" then
				block_type = "heavy_hurt"
			end

			if Network:is_server() and unit:movement():chk_action_forbidden(block_type) then
				return
			end

			local variant = CopActionHurt.idx_to_variant(variant_idx)
			local client_interrupt, blocks = nil

			if variant == "tase" then
				block_type = "bleedout"
			elseif hurt_type == "expl_hurt" or hurt_type == "fire_hurt" or hurt_type == "poison_hurt" or hurt_type == "taser_tased" then
				block_type = "heavy_hurt"

				client_interrupt = Network:is_client()
			else
				block_type = hurt_type

				if hurt_type ~= "bleedout" and hurt_type ~= "fatal" then
					client_interrupt = Network:is_client()
				end
			end

			if hurt_type ~= "light_hurt" then
				blocks = {
					act = -1,
					aim = -1,
					action = -1,
					tase = -1,
					walk = -1,
					light_hurt = -1
				}

				if hurt_type == "bleedout" then
					blocks.bleedout = -1
					blocks.hurt = -1
					blocks.heavy_hurt = -1
					blocks.hurt_sick = -1
					blocks.concussion = -1
				end
			end

			action_data = {
				allow_network = false,
				client_interrupt = client_interrupt,
				hurt_type = hurt_type,
				block_type = block_type,
				blocks = blocks,
				body_part = body_part,
				death_type = CopActionHurt.idx_to_death_type(death_type_idx),
				type = action_type,
				variant = variant,
				direction_vec = direction_vec,
				hit_pos = hit_pos,
				sync_t = Application:time() - peer:qos().ping / 1000
			}
		end

		unit:movement():action_request(action_data)
	end
end

function UnitNetworkHandler:sync_medic_heal(unit, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	MedicActionHeal:check_achievements()

	if not self._verify_character(unit) then
		return
	end

	unit:character_damage()._heal_cooldown_t = Application:time()

	local anim_data = unit:anim_data()

	if anim_data and anim_data.act then
		unit:sound():say("heal")
	else
		local action_data = {
			body_part = 1,
			type = "heal",
			client_interrupt = Network:is_client()
		}

		unit:movement():action_request(action_data)
	end
end

function UnitNetworkHandler:sync_heist_time(time, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	time = time + peer:qos().ping / 1000

	managers.game_play_central:sync_heist_time(time)
end

function UnitNetworkHandler:request_place_ecm_jammer(battery_life_upgrade_lvl, body, pos, rot, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	if not alive(body) then
		sender:from_server_ecm_jammer_place_result(nil, nil, Vector3(), Rotation())

		return
	end

	local owner_unit = peer:unit()

	if not alive(owner_unit) or owner_unit:id() == -1 then
		sender:from_server_ecm_jammer_place_result(nil, nil, Vector3(), Rotation())

		return
	end

	local peer_id = peer:id()

	if not managers.player:verify_equipment(peer_id, "ecm_jammer") then
		return
	end

	local unit = ECMJammerBase.spawn(pos, rot, battery_life_upgrade_lvl, owner_unit, peer_id)

	if not alive(unit) then
		sender:from_server_ecm_jammer_place_result(nil, nil, Vector3(), Rotation())

		return
	end

	sender:from_server_ecm_jammer_place_result(unit, body, pos, rot)
	managers.network:session():send_to_peers_synched_except(peer_id, "sync_deployable_attachment", unit, body, pos, rot)

	local base_ext = unit:base()

	base_ext:set_server_information(peer_id)
	base_ext:set_active(true)

	local inv_body_rot = body:rotation():inverse()
	local relative_pos = pos - body:position()

	mvector3.rotate_with(relative_pos, inv_body_rot)

	local relative_rot = inv_body_rot * rot

	base_ext:link_attachment(body, relative_pos, relative_rot)
end

function UnitNetworkHandler:from_server_ecm_jammer_place_result(unit, body, pos, rot, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	unit = alive(unit) and unit or nil

	local local_player = managers.player:player_unit()

	if alive(local_player) then
		local_player:equipment():from_server_ecm_jammer_placement_result(unit and true or false)
	end

	if not unit then
		return
	end

	local base_ext = unit:base()

	base_ext:set_owner(local_player)

	if not alive(body) then
		return
	end

	local inv_body_rot = body:rotation():inverse()
	local relative_pos = pos - body:position()

	mvector3.rotate_with(relative_pos, inv_body_rot)

	local relative_rot = inv_body_rot * rot

	base_ext:link_attachment(body, relative_pos, relative_rot)
end

function UnitNetworkHandler:sync_deployable_attachment(unit, body, pos, rot, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	if not alive(unit) or not alive(body) then
		return
	end

	local inv_body_rot = body:rotation():inverse()
	local relative_pos = pos - body:position()

	mvector3.rotate_with(relative_pos, inv_body_rot)

	local relative_rot = inv_body_rot * rot

	unit:base():link_attachment(body, relative_pos, relative_rot)
end

function UnitNetworkHandler:place_sentry_gun(pos, rot, equipment_selection_index, user_unit, unit_idstring_index, ammo_level, fire_mode_index, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local peer = self._verify_sender(sender)

	if not peer then
		return
	end

	if equipment_selection_index == 0 or not alive(user_unit) or user_unit:id() == -1 then
		sender:from_server_sentry_gun_place_result(peer:id(), 0, nil, 1, 1, false, 1, 1)

		return
	end

	local peer_id = peer:id()

	if not managers.player:verify_equipment(peer_id, "sentry_gun") then
		return
	end

	local unit, spread_level, rot_level = SentryGunBase.spawn(user_unit, pos, rot, peer_id, true, unit_idstring_index)

	if not unit then
		sender:from_server_sentry_gun_place_result(peer_id, 0, nil, 1, 1, false, 1, 1)

		return
	end

	local can_switch_fire_mode = PlayerSkill.has_skill("sentry_gun", "ap_bullets", user_unit)
	fire_mode_index = can_switch_fire_mode and fire_mode_index or 1

	unit:base():set_server_information(peer_id)

	local has_shield = unit:base():has_shield()

	managers.network:session():send_to_peers_synched("from_server_sentry_gun_place_result", peer_id, equipment_selection_index or 0, unit, rot_level, spread_level, has_shield, ammo_level, fire_mode_index)
	unit:event_listener():call("on_setup", false)
	unit:base():post_setup(fire_mode_index)
end

function UnitNetworkHandler:from_server_sentry_gun_place_result(owner_peer_id, equipment_selection_index, sentry_gun_unit, rot_level, spread_level, shield, ammo_level, fire_mode_index, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	local local_peer = managers.network:session():local_peer()
	local local_player = local_peer:unit()
	local_player = alive(local_player) and local_player or nil

	if equipment_selection_index == 0 or not alive(sentry_gun_unit) then
		if local_player and owner_peer_id == local_peer:id() then
			local_player:equipment():from_server_sentry_gun_place_result()
		end

		return
	end

	local base_ext = sentry_gun_unit:base()

	base_ext:set_owner_id(owner_peer_id)

	if local_player and owner_peer_id == local_peer:id() then
		managers.player:from_server_equipment_place_result(equipment_selection_index, local_player, sentry_gun_unit)
	end

	if shield then
		base_ext:enable_shield()
	end

	local rot_speed_mul = SentryGunBase.ROTATION_SPEED_MUL[rot_level]

	sentry_gun_unit:movement():setup(rot_speed_mul)
	sentry_gun_unit:brain():setup(1 / rot_speed_mul)

	local spread_mul = SentryGunBase.SPREAD_MUL[spread_level]
	local setup_data = {
		spread_mul = spread_mul,
		ignore_units = {
			sentry_gun_unit
		}
	}

	sentry_gun_unit:weapon():setup(setup_data)

	local ammo_mul = SentryGunBase.AMMO_MUL[ammo_level]

	sentry_gun_unit:weapon():setup_virtual_ammo(ammo_mul)
	sentry_gun_unit:event_listener():call("on_setup", base_ext:is_owner())
	base_ext:post_setup(fire_mode_index)
end
