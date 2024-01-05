local mvec3_cpy = mvector3.copy

Hooks:PostHook(CopBrain, "init", "CD_copbrain_init", function(self, unit)
	CopBrain._logic_variants.tank.attack = BossLogicAttack
	CopBrain._logic_variants.tank_medic.attack = BossLogicAttack
	CopBrain._logic_variants.tank_mini.attack = BossLogicAttack
	CopBrain._logic_variants.mobster_boss = CopBrain._logic_variants.tank
	CopBrain._logic_variants.biker_boss = CopBrain._logic_variants.tank
	CopBrain._logic_variants.drug_lord_boss = CopBrain._logic_variants.tank

	CopBrain._logic_variants.deathvox_shield = CopBrain._logic_variants.shield
	
	CopBrain._logic_variants.deathvox_heavyar = CopBrain._logic_variants.swat
	CopBrain._logic_variants.deathvox_lightar = CopBrain._logic_variants.swat
	CopBrain._logic_variants.deathvox_medic = CopBrain._logic_variants.swat
	CopBrain._logic_variants.deathvox_guard = CopBrain._logic_variants.swat
	CopBrain._logic_variants.deathvox_gman = CopBrain._logic_variants.swat
	CopBrain._logic_variants.deathvox_lightshot = CopBrain._logic_variants.swat
	CopBrain._logic_variants.deathvox_heavyshot = CopBrain._logic_variants.swat
	
	CopBrain._logic_variants.deathvox_guarddozer = CopBrain._logic_variants.tank
	CopBrain._logic_variants.deathvox_taser = CopBrain._logic_variants.taser
	CopBrain._logic_variants.deathvox_sniper_assault = CopBrain._logic_variants.swat
	CopBrain._logic_variants.deathvox_sniper = CopBrain._logic_variants.sniper
	CopBrain._logic_variants.deathvox_cloaker = CopBrain._logic_variants.spooc
	CopBrain._logic_variants.deathvox_grenadier = CopBrain._logic_variants.swat
	
	CopBrain._logic_variants.deathvox_greendozer = CopBrain._logic_variants.tank
	CopBrain._logic_variants.deathvox_blackdozer = CopBrain._logic_variants.tank
	CopBrain._logic_variants.deathvox_lmgdozer = CopBrain._logic_variants.tank
	CopBrain._logic_variants.deathvox_medicdozer = CopBrain._logic_variants.tank

	CopBrain._logic_variants.deathvox_cop_pistol = CopBrain._logic_variants.cop
	CopBrain._logic_variants.deathvox_cop_revolver = CopBrain._logic_variants.cop
	CopBrain._logic_variants.deathvox_cop_shotgun = CopBrain._logic_variants.cop
	CopBrain._logic_variants.deathvox_cop_smg = CopBrain._logic_variants.cop
	
	CopBrain._logic_variants.deathvox_fbi_hrt = CopBrain._logic_variants.fbi
	CopBrain._logic_variants.deathvox_fbi_veteran = CopBrain._logic_variants.fbi
	CopBrain._logic_variants.deathvox_fbi_rookie = CopBrain._logic_variants.fbi
end)

CopBrain._NET_EVENTS = {
	stopped_seeing_client_peaceful = 11,
	detected_client_peaceful_verified = 10,
	detected_client_peaceful = 9,
	client_no_longer_verified = 8,
	detected_suspected_client = 7,
	stopped_suspecting_client = 6,
	suspecting_client_verified = 5,
	suspecting_client = 4,
	detected_client = 3,
	stopped_seeing_client = 2,
	seeing_client = 1
}

function CopBrain:sync_net_event(event_id, peer)
	local peer_id = peer:id()
	local peer_unit = managers.criminals:character_unit_by_peer_id(peer_id)

	if not peer_unit then
		return
	end

	if event_id == self._NET_EVENTS.seeing_client then
		managers.groupai:state():on_criminal_suspicion_progress(peer_unit, self._unit, 1, peer_id)
	elseif event_id == self._NET_EVENTS.stopped_seeing_client then
		managers.groupai:state():on_criminal_suspicion_progress(peer_unit, self._unit, false, peer_id)
	elseif event_id == self._NET_EVENTS.detected_client then
		managers.groupai:state():on_criminal_suspicion_progress(peer_unit, self._unit, true, peer_id)

		self._unit:movement():set_cool(false, managers.groupai:state().analyse_giveaway(self._unit:base()._tweak_table, peer_unit))

		local att_obj_data = CopLogicBase.identify_attention_obj_instant(self._logic_data, peer_unit:key())

		if att_obj_data and att_obj_data.criminal_record then
			managers.groupai:state():criminal_spotted(peer_unit)
		end
	elseif event_id == self._NET_EVENTS.detected_client_peaceful or event_id == self._NET_EVENTS.detected_client_peaceful_verified then
		local t = self._logic_data.t
		local att_u_key = peer_unit:key()
		local att_obj_data = self._logic_data.detected_attention_objects[att_u_key]

		if att_obj_data then
			if not att_obj_data.client_peaceful_detection then
				mvector3.set(att_obj_data.verified_pos, att_obj_data.m_head_pos)

				att_obj_data.verified_dis = mvector3.distance(self._unit:movement():m_head_pos(), att_obj_data.m_head_pos)

				if not att_obj_data.identified then
					att_obj_data.identified = true
					att_obj_data.identified_t = t
					att_obj_data.notice_progress = nil
					att_obj_data.prev_notice_chk_t = nil
				elseif att_obj_data.uncover_progress then
					att_obj_data.uncover_progress = nil
				end
			end
		else
			local attention_info = managers.groupai:state():get_AI_attention_objects_by_filter(self._logic_data.SO_access_str)[att_u_key]

			if attention_info then
				local settings = attention_info.handler:get_attention(self._logic_data.SO_access, nil, nil, self._logic_data.team)

				if settings then
					att_obj_data = CopLogicBase._create_detected_attention_object_data(t, self._unit, att_u_key, attention_info, settings)
					att_obj_data.identified = true
					att_obj_data.identified_t = t
					att_obj_data.notice_progress = nil
					att_obj_data.prev_notice_chk_t = nil

					self._logic_data.detected_attention_objects[att_u_key] = att_obj_data
				end
			end
		end

		if att_obj_data then
			att_obj_data.client_peaceful_detection = true

			if event_id == self._NET_EVENTS.detected_client_peaceful_verified then
				att_obj_data.verified = true
			end
		end
	elseif event_id == self._NET_EVENTS.suspecting_client or event_id == self._NET_EVENTS.suspecting_client_verified then
		local t = self._logic_data.t
		local att_u_key = peer_unit:key()
		local att_obj_data = self._logic_data.detected_attention_objects[att_u_key]

		if att_obj_data then
			if not att_obj_data.client_casing_suspicion then
				mvector3.set(att_obj_data.verified_pos, att_obj_data.m_head_pos)

				att_obj_data.verified_dis = mvector3.distance(self._unit:movement():m_head_pos(), att_obj_data.m_head_pos)

				if not att_obj_data.identified then
					att_obj_data.identified = true
					att_obj_data.identified_t = t
					att_obj_data.notice_progress = nil
					att_obj_data.prev_notice_chk_t = nil
				elseif att_obj_data.uncover_progress then
					att_obj_data.uncover_progress = nil
				end
			end
		else
			local attention_info = managers.groupai:state():get_AI_attention_objects_by_filter(self._logic_data.SO_access_str)[att_u_key]

			if attention_info then
				local settings = attention_info.handler:get_attention(self._logic_data.SO_access, nil, nil, self._logic_data.team)

				if settings then
					att_obj_data = CopLogicBase._create_detected_attention_object_data(t, self._unit, att_u_key, attention_info, settings)
					att_obj_data.identified = true
					att_obj_data.identified_t = t
					att_obj_data.notice_progress = nil
					att_obj_data.prev_notice_chk_t = nil

					self._logic_data.detected_attention_objects[att_u_key] = att_obj_data
				end
			end
		end

		if att_obj_data then
			if not att_obj_data.client_casing_suspicion then
				att_obj_data.client_casing_suspicion = true

				managers.groupai:state():on_criminal_suspicion_progress(peer_unit, self._unit, 1, peer_id)
			end

			if event_id == self._NET_EVENTS.suspecting_client_verified then
				att_obj_data.verified = true
			end
		end
	elseif event_id == self._NET_EVENTS.client_no_longer_verified then
		local att_obj_data = self._logic_data.detected_attention_objects[peer_unit:key()]

		if att_obj_data then
			att_obj_data.verified = nil
		end
	elseif event_id == self._NET_EVENTS.stopped_suspecting_client or event_id == self._NET_EVENTS.stopped_seeing_client_peaceful then
		if event_id == self._NET_EVENTS.stopped_suspecting_client then
			managers.groupai:state():on_criminal_suspicion_progress(peer_unit, self._unit, false, peer_id)
		end

		local att_obj_data = self._logic_data.detected_attention_objects[peer_unit:key()]

		if att_obj_data then
			att_obj_data.handler:remove_listener("detect_" .. tostring(self._logic_data.key))

			self._logic_data.detected_attention_objects[peer_unit:key()] = nil

			local my_data = self._logic_data.internal_data

			if self._logic_data.attention_obj and self._logic_data.attention_obj.u_key == peer_unit:key() then
				CopLogicBase._set_attention_obj(self._logic_data, nil, nil)

				if my_data then
					if my_data.firing or my_data.firing_on_client then
						self._unit:movement():set_allow_fire(false)

						my_data.firing = nil
						my_data.firing_on_client = nil
					end
				end
			end

			if my_data and my_data.arrest_targets then
				my_data.arrest_targets[peer_unit:key()] = nil
			end

			local set_attention = self._unit:movement():attention()

			if set_attention and set_attention.u_key == peer_unit:key() then
				self._unit:movement():set_attention()
			end
		end
	elseif event_id == self._NET_EVENTS.detected_suspected_client then
		managers.groupai:state():on_criminal_suspicion_progress(peer_unit, self._unit, true, peer_id)

		local att_obj_data = self._logic_data.detected_attention_objects[peer_unit:key()]

		if att_obj_data then
			att_obj_data.client_casing_suspicion = nil
			att_obj_data.client_casing_detected = true
		end
	end
end

if deathvox:IsTotalCrackdownEnabled() then
	function CopBrain:convert_to_criminal(mastermind_criminal)
		if self._alert_listen_key then
			managers.groupai:state():remove_alert_listener(self._alert_listen_key)
		else
			self._alert_listen_key = "CopBrain" .. tostring(self._unit:key())
		end

		local alert_listen_filter = managers.groupai:state():get_unit_type_filter("combatant")
		local alert_types = {
			explosion = true,
			fire = true,
			aggression = true,
			bullet = true
		}

		managers.groupai:state():add_alert_listener(self._alert_listen_key, callback(self, self, "on_alert"), alert_listen_filter, alert_types, self._unit:movement():m_head_pos())

		self._logic_data.is_converted = true
		self._logic_data.group = nil
		local mover_col_body = self._unit:body("mover_blocker")

		mover_col_body:set_enabled(false)

		local attention_preset = PlayerMovement._create_attention_setting_from_descriptor(self, tweak_data.attention.settings.team_enemy_cbt, "team_enemy_cbt")

		self._attention_handler:override_attention("enemy_team_cbt", attention_preset)

		local health_multiplier, damage_multiplier, accuracy_multiplier, range_multiplier = 0.2, 1, 1, 1
		local add_armor_piercing, no_hurt_animations, melee_stagger, health_regen, highlight_prioritizing, marked_enemy_bonus, gun_stagger, gain_dmg_over_t = nil

		if alive(mastermind_criminal) then
			local base_ext = mastermind_criminal:base()

			health_multiplier = base_ext:upgrade_value("player", "passive_convert_enemies_health_multiplier") or 0.2
			damage_multiplier = damage_multiplier * (base_ext:upgrade_value("player", "convert_enemies_damage_multiplier") or 1)
			damage_multiplier = damage_multiplier * (base_ext:upgrade_value("player", "passive_convert_enemies_damage_multiplier") or 1)

			--TCD skills
			range_multiplier = base_ext:upgrade_value("player", "convert_enemies_range_bonus", 1) or 1
			accuracy_multiplier = base_ext:upgrade_value("player", "convert_enemies_accuracy_bonus") or 1
			add_armor_piercing = base_ext:upgrade_value("player", "convert_enemies_piercing_bullets")
			no_hurt_animations = base_ext:upgrade_value("player", "convert_enemies_knockback_proof")
			melee_stagger = base_ext:upgrade_value("player", "convert_enemies_melee")
			gun_stagger = base_ext:upgrade_value("player", "convert_enemies_always_stagger")
			gain_dmg_over_t = base_ext:upgrade_value("player", "convert_enemy_gains_dmg_over_t")
			health_regen = base_ext:upgrade_value("player", "convert_enemies_health_regen") or 0
			highlight_prioritizing = base_ext:upgrade_value("player", "convert_enemies_target_marked")
			marked_enemy_bonus = base_ext:upgrade_value("player", "convert_enemies_marked_damage_bonus") or 1
		else
			local player_manager = managers.player

			health_multiplier = player_manager:upgrade_value("player", "passive_convert_enemies_health_multiplier", 0.2)
			damage_multiplier = damage_multiplier * player_manager:upgrade_value("player", "convert_enemies_damage_multiplier", 1)
			damage_multiplier = damage_multiplier * player_manager:upgrade_value("player", "passive_convert_enemies_damage_multiplier", 1)

			--TCD skills
			range_multiplier = player_manager:upgrade_value("player", "convert_enemies_range_bonus", 1)
			accuracy_multiplier = player_manager:upgrade_value("player", "convert_enemies_accuracy_bonus", 1)
			add_armor_piercing = player_manager:upgrade_value("player", "convert_enemies_piercing_bullets")
			no_hurt_animations = player_manager:upgrade_value("player", "convert_enemies_knockback_proof")
			melee_stagger = player_manager:upgrade_value("player", "convert_enemies_melee")
			gun_stagger = player_manager:upgrade_value("player", "convert_enemies_always_stagger")
			gain_dmg_over_t = player_manager:upgrade_value("player", "convert_enemy_gains_dmg_over_t")
			health_regen = player_manager:upgrade_value("player", "convert_enemies_health_regen", 0)
			highlight_prioritizing = player_manager:upgrade_value("player", "convert_enemies_target_marked")
			marked_enemy_bonus = player_manager:upgrade_value("player", "convert_enemies_marked_damage_bonus", 1)
		end

		local ext_dmg = self._unit:character_damage()
		ext_dmg:convert_to_criminal(health_multiplier)

		if health_regen and health_regen ~= 0 then
			ext_dmg:set_health_regen(health_regen)
		end

		if marked_enemy_bonus and marked_enemy_bonus ~= 1 then
			ext_dmg._joker_mark_dmg_bonus = marked_enemy_bonus
		end

		if self._logic_data.attention_obj then
			CopLogicBase._set_attention_obj(self._logic_data, nil, nil)
		end

		local current_attention = self._unit:movement():attention()

		if current_attention then
			CopLogicBase._reset_attention(self._logic_data)
		end

		CopLogicBase._destroy_all_detected_attention_object_data(self._logic_data)

		local team_ai_so_access = tweak_data.character.russian.access

		self._SO_access = managers.navigation:convert_access_flag(team_ai_so_access)
		self._logic_data.SO_access = self._SO_access
		self._logic_data.SO_access_str = team_ai_so_access
		self._slotmask_enemies = managers.slot:get_mask("enemies")
		self._logic_data.enemy_slotmask = self._slotmask_enemies

		local char_tweaks = deep_clone(self._unit:base()._char_tweak)

		if no_hurt_animations then
			char_tweaks.damage.hurt_severity = tweak_data.character.presets.hurt_severities.no_hurts_no_tase
			char_tweaks.can_be_tased = false
			char_tweaks.use_animation_on_fire_damage = false
			char_tweaks.immune_to_knock_down = true
			char_tweaks.immune_to_concussion = true

			managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "character_damage", HuskCopDamage._NET_EVENTS.set_joker_no_hurts)
		end

		if highlight_prioritizing then
			if alive(mastermind_criminal) then
				local peer = managers.network:session():peer_by_unit(mastermind_criminal)

				if peer then
					self._unit:brain()._prioritize_marked_units_by_owner_id = peer:id()
				end
			else
				self._unit:brain()._prioritize_marked_units_by_owner_id = managers.network:session():local_peer():id()
			end
		end

		char_tweaks.suppression = nil
		char_tweaks.crouch_move = false
		char_tweaks.allowed_poses = {stand = true}
		char_tweaks.access = team_ai_so_access
		char_tweaks.no_run_stop = true
		
		local rifle_user = {
			deathvox_lightar = true,
			deathvox_heavyar = true
		}
		
		local shotgun_user = {
			deathvox_lightshot = true,
			deathvox_heavyshot = true
		}
		
			
		local w_usage = self._unit:inventory():equipped_unit() and self._unit:inventory():equipped_unit():base():weapon_tweak_data() and self._unit:inventory():equipped_unit():base():weapon_tweak_data().usage
		if rifle_user[self._unit:base()._tweak_table] then
			gun_stagger = nil
					
			if accuracy_multiplier ~= 1 then
				if ext_dmg._original_acc_mul then
					ext_dmg._original_acc_mul = accuracy_multiplier

					ext_dmg:set_accuracy_multiplier(ext_dmg._ON_STUN_ACCURACY_DECREASE * accuracy_multiplier)
				else
					ext_dmg:set_accuracy_multiplier(accuracy_multiplier)
				end
			end
			
			if range_multiplier ~= 1 then
				if w_usage then
					local falloff_table = char_tweaks.weapon[w_usage].FALLOFF
					
					for i = 1, #falloff_table do
						local t = falloff_table[i]
						
						t.r = t.r * range_multiplier
					end
				end
			end
		elseif shotgun_user[self._unit:base()._tweak_table] then
			add_armor_piercing = nil
				
			if melee_stagger then
				self._unit:movement()._joker_melee_stagger = true
			end	
		else
			local rifle_usages = {
				is_rifle = true,
				is_light_rifle = true,
				is_heavy_rifle = true,
				is_bullpup
			}
			
			local shotgun_usages = {
				is_shotgun_pump = true,
				is_shotgun_mag = true,
				is_light_shotgun = true,
				is_heavy_shotgun = true
			}
			
			if w_usage then
				if rifle_usages[w_usage] then
					gun_stagger = nil
					
					if accuracy_multiplier ~= 1 then
						if ext_dmg._original_acc_mul then
							ext_dmg._original_acc_mul = accuracy_multiplier

							ext_dmg:set_accuracy_multiplier(ext_dmg._ON_STUN_ACCURACY_DECREASE * accuracy_multiplier)
						else
							ext_dmg:set_accuracy_multiplier(accuracy_multiplier)
						end
					end
					
					if range_multiplier ~= 1 then
						local falloff_table = char_tweaks.weapon[w_usage].FALLOFF
						
						for i = 1, #falloff_table do
							local t = falloff_table[i]
							
							t.r = t.r * range_multiplier
						end
					end
				elseif shotgun_usages[w_usage] then	
					add_armor_piercing = nil
				
					if melee_stagger then
						self._unit:movement()._joker_melee_stagger = true
					end	
				else
					add_armor_piercing = nil
					gun_stagger = nil
				end
			end
		end

		self._logic_data.char_tweak = char_tweaks
		self._unit:base()._char_tweak = char_tweaks
		ext_dmg._char_tweak = char_tweaks
		self._unit:movement()._tweak_data = char_tweaks
		self._unit:movement()._action_common_data.char_tweak = char_tweaks

		local equipped_w_selection = self._unit:inventory():equipped_selection()

		if equipped_w_selection then
			self._unit:inventory():remove_selection(equipped_w_selection, true)
		end

		local weap_name = self._unit:base():default_weapon_name()

		TeamAIInventory.add_unit_by_name(self._unit:inventory(), weap_name, true)

		local weapon_unit = self._unit:inventory():equipped_unit()

		weapon_unit:base():add_damage_multiplier(damage_multiplier)
		
		if gain_dmg_over_t then
			ext_dmg:begin_increase_dmg_clbks()
		end

		if add_armor_piercing then
			weapon_unit:base()._use_armor_piercing = true
		end
		
		if gun_stagger then
			weapon_unit:base()._knock_down = 2
		end

		self._logic_data.important = true

		self:set_objective(nil)
		self:set_logic("idle", nil)

		self._logic_data.objective_complete_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_criminal_objective_complete")
		self._logic_data.objective_failed_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_criminal_objective_failed")

		managers.groupai:state():on_criminal_jobless(self._unit)
		self._unit:base():set_slot(self._unit, 16)
		self._unit:movement():set_stance("hos")

		local action_data = {
			variant = "stand",
			body_part = 1,
			type = "act"
		}

		self._unit:brain():action_request(action_data)
		self._unit:sound():say("cn1", true, nil)
	end
else
	function CopBrain:convert_to_criminal(mastermind_criminal)

		if self._alert_listen_key then
			managers.groupai:state():remove_alert_listener(self._alert_listen_key)
		else
			self._alert_listen_key = "CopBrain" .. tostring(self._unit:key())
		end

		local alert_listen_filter = managers.groupai:state():get_unit_type_filter("combatant")
		local alert_types = {
			explosion = true,
			fire = true,
			aggression = true,
			bullet = true
		}

		managers.groupai:state():add_alert_listener(self._alert_listen_key, callback(self, self, "on_alert"), alert_listen_filter, alert_types, self._unit:movement():m_head_pos())

		self._logic_data.is_converted = true
		self._logic_data.group = nil
		local mover_col_body = self._unit:body("mover_blocker")

		mover_col_body:set_enabled(false)

		local attention_preset = PlayerMovement._create_attention_setting_from_descriptor(self, tweak_data.attention.settings.team_enemy_cbt, "team_enemy_cbt")

		self._attention_handler:override_attention("enemy_team_cbt", attention_preset)

		local health_multiplier, damage_multiplier = 1, 1

		if alive(mastermind_criminal) then
			local base_ext = mastermind_criminal:base()

			health_multiplier = health_multiplier * (base_ext:upgrade_value("player", "convert_enemies_health_multiplier") or 1)
			health_multiplier = health_multiplier * (base_ext:upgrade_value("player", "passive_convert_enemies_health_multiplier") or 1)
			damage_multiplier = damage_multiplier * (base_ext:upgrade_value("player", "convert_enemies_damage_multiplier") or 1)
			damage_multiplier = damage_multiplier * (base_ext:upgrade_value("player", "passive_convert_enemies_damage_multiplier") or 1)
		else
			local player_manager = managers.player

			health_multiplier = health_multiplier * player_manager:upgrade_value("player", "convert_enemies_health_multiplier", 1)
			health_multiplier = health_multiplier * player_manager:upgrade_value("player", "passive_convert_enemies_health_multiplier", 1)
			damage_multiplier = damage_multiplier * player_manager:upgrade_value("player", "convert_enemies_damage_multiplier", 1)
			damage_multiplier = damage_multiplier * player_manager:upgrade_value("player", "passive_convert_enemies_damage_multiplier", 1)
		end

		local ext_dmg = self._unit:character_damage()
		ext_dmg:convert_to_criminal(health_multiplier)

		if self._logic_data.attention_obj then
			CopLogicBase._set_attention_obj(self._logic_data, nil, nil)
		end

		local current_attention = self._unit:movement():attention()

		if current_attention then
			CopLogicBase._reset_attention(self._logic_data)
		end

		CopLogicBase._destroy_all_detected_attention_object_data(self._logic_data)

		local team_ai_so_access = tweak_data.character.russian.access

		self._SO_access = managers.navigation:convert_access_flag(team_ai_so_access)
		self._logic_data.SO_access = self._SO_access
		self._logic_data.SO_access_str = team_ai_so_access
		self._slotmask_enemies = managers.slot:get_mask("enemies")
		self._logic_data.enemy_slotmask = self._slotmask_enemies

		local char_tweaks = deep_clone(self._unit:base()._char_tweak)

		char_tweaks.suppression = nil
		char_tweaks.crouch_move = false
		char_tweaks.allowed_poses = {stand = true}
		char_tweaks.access = team_ai_so_access
		char_tweaks.no_run_stop = true

		self._logic_data.char_tweak = char_tweaks
		self._unit:base()._char_tweak = char_tweaks
		ext_dmg._char_tweak = char_tweaks
		self._unit:movement()._tweak_data = char_tweaks
		self._unit:movement()._action_common_data.char_tweak = char_tweaks

		local equipped_w_selection = self._unit:inventory():equipped_selection()

		if equipped_w_selection then
			self._unit:inventory():remove_selection(equipped_w_selection, true)
		end

		local weap_name = self._unit:base():default_weapon_name()

		TeamAIInventory.add_unit_by_name(self._unit:inventory(), weap_name, true)

		local weapon_unit = self._unit:inventory():equipped_unit()

		weapon_unit:base():add_damage_multiplier(damage_multiplier)

		if add_armor_piercing then
			weapon_unit:base()._use_armor_piercing = true
		end

		self._logic_data.important = true

		self:set_objective(nil)
		self:set_logic("idle", nil)

		self._logic_data.objective_complete_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_criminal_objective_complete")
		self._logic_data.objective_failed_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_criminal_objective_failed")

		managers.groupai:state():on_criminal_jobless(self._unit)
		self._unit:base():set_slot(self._unit, 16)
		self._unit:movement():set_stance("hos")

		local action_data = {
			variant = "stand",
			body_part = 1,
			type = "act"
		}

		self._unit:brain():action_request(action_data)
		self._unit:sound():say("cn1", true, nil)
	end
end

function CopBrain:clbk_alarm_pager(ignore_this, data)
	local pager_data = self._alarm_pager_data
	local clbk_id = pager_data.pager_clbk_id
	pager_data.pager_clbk_id = nil

	if not managers.groupai:state():whisper_mode() then
		self:end_alarm_pager()

		return
	end

	if pager_data.nr_calls_made == 0 then
		if managers.groupai:state():is_ecm_jammer_active("pager") and not self._unit:unit_data().ignore_ecm_for_pager then
			self:end_alarm_pager()
			self:begin_alarm_pager(true)

			return
		end

		self._unit:sound():stop()

		if self._unit:character_damage():dead() then
			self._unit:sound():corpse_play(self:_get_radio_id("dsp_radio_query_1"), nil, true)
		else
			self._unit:sound():play(self:_get_radio_id("dsp_radio_query_1"), nil, true)
		end

		self._unit:interaction():set_tweak_data("corpse_alarm_pager")
		self._unit:interaction():set_active(true, true)
	elseif pager_data.nr_calls_made < pager_data.total_nr_calls then
		self._unit:sound():stop()

		if self._unit:character_damage():dead() then
			self._unit:sound():corpse_play(self:_get_radio_id("dsp_radio_reminder_1"), nil, true)
		else
			self._unit:sound():play(self:_get_radio_id("dsp_radio_reminder_1"), nil, true)
		end
	elseif pager_data.nr_calls_made == pager_data.total_nr_calls then
		self._unit:interaction():set_active(false, true)
		managers.groupai:state():on_police_called("alarm_pager_not_answered")
		self._unit:sound():stop()

		if self._unit:character_damage():dead() then
			self._unit:sound():corpse_play("pln_alm_any_any", nil, true)
		else
			self._unit:sound():play("pln_alm_any_any", nil, true)
		end

		self:end_alarm_pager()
	end

	if pager_data.nr_calls_made == pager_data.total_nr_calls - 1 then
		self._unit:interaction():set_outline_flash_state(true, true)
	end

	pager_data.nr_calls_made = pager_data.nr_calls_made + 1

	if pager_data.nr_calls_made <= pager_data.total_nr_calls then
		local duration_settings = tweak_data.player.alarm_pager.call_duration[math.min(#tweak_data.player.alarm_pager.call_duration, pager_data.nr_calls_made)]
		local call_delay = math.lerp(duration_settings[1], duration_settings[2], math.random())
		self._alarm_pager_data.pager_clbk_id = clbk_id

		managers.enemy:add_delayed_clbk(self._alarm_pager_data.pager_clbk_id, callback(self, self, "clbk_alarm_pager"), TimerManager:game():time() + call_delay)
	end
end

local next_g = next
local pairs_g = pairs
local type_g = type

function CopBrain:_add_pathing_result(search_id, path)
	self._logic_data.active_searches[search_id] = nil
	self._logic_data.pathing_results = self._logic_data.pathing_results or {}
	self._logic_data.pathing_results[search_id] = path or "failed"
	
	if path and self._current_logic._pathing_complete_clbk then
		self._current_logic._pathing_complete_clbk(self._logic_data)
	end
end

function CopBrain:_reset_logic_data()
	self._logic_data = {
		unit = self._unit,
		brain = self,
		brain_updating = false,
		active_searches = {},
		m_pos = self._unit:movement():m_pos(),
		char_tweak = tweak_data.character[self._unit:base()._tweak_table],
		key = self._unit:key(),
		pos_rsrv = {},
		pos_rsrv_id = self._unit:movement():pos_rsrv_id(),
		SO_access = self._SO_access,
		SO_access_str = tweak_data.character[self._unit:base()._tweak_table].access,
		detected_attention_objects = {},
		attention_handler = self._attention_handler,
		visibility_slotmask = managers.slot:get_mask("AI_visibility"),
		enemy_slotmask = self._slotmask_enemies,
		cool = self._unit:movement():cool(),
		objective_complete_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_objective_complete"),
		objective_failed_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_objective_failed")
	}
end

function CopBrain:set_update_enabled_state(state)
	self._unit:set_extension_update_enabled(Idstring("brain"), state)
	
	if self._logic_data then
		self._logic_data.brain_updating = state
	end
end

function CopBrain:on_suppressed(state)
	self._logic_data.is_suppressed = state or nil

	if state and self._current_logic.on_suppressed_state then
		self._current_logic.on_suppressed_state(self._logic_data)

		-- hopefully some variety here now
		if state == "panic" and math.random() <= 0.5 then
			self._unit:sound():say("lk3a", true) 
		elseif self._logic_data.char_tweak.chatter.suppress then
			self._unit:sound():say("hlp", true)
		end
	end
end

function CopBrain:search_for_coarse_immediate(search_id, to_seg, verify_clbk, access_neg)
	local params = {
		from_tracker = self._unit:movement():nav_tracker(),
		to_seg = to_seg,
		access = {
			"walk"
		},
		id = search_id,
		verify_clbk = verify_clbk,
		access_pos = self._logic_data.char_tweak.access,
		access_neg = access_neg
	}

	return managers.navigation:search_coarse(params)
end

function CopBrain:search_for_path(search_id, to_pos, prio, access_neg, nav_segs)
	if not prio then
		prio = CopLogicTravel.get_pathing_prio(self._logic_data)
	end

	local params = {
		tracker_from = self._unit:movement():nav_tracker(),
		pos_to = to_pos,
		result_clbk = callback(self, self, "clbk_pathing_results", search_id),
		id = search_id,
		prio = prio,
		access_pos = self._SO_access,
		access_neg = access_neg,
		nav_segs = nav_segs
	}
	
	self._logic_data.active_searches[search_id] = true

	managers.navigation:search_pos_to_pos(params)

	return true
end

function CopBrain:search_for_path_from_pos(search_id, from_pos, to_pos, prio, access_neg, nav_segs)
	if not prio then
		prio = CopLogicTravel.get_pathing_prio(self._logic_data)
	end

	local params = {
		pos_from = from_pos,
		pos_to = to_pos,
		result_clbk = callback(self, self, "clbk_pathing_results", search_id),
		id = search_id,
		prio = prio,
		access_pos = self._SO_access,
		access_neg = access_neg,
		nav_segs = nav_segs
	}
	
	self._logic_data.active_searches[search_id] = true
	managers.navigation:search_pos_to_pos(params)

	return true
end

function CopBrain:search_for_path_to_cover(search_id, cover, offset_pos, access_neg)
	if not prio then
		prio = CopLogicTravel.get_pathing_prio(self._logic_data)
		--log("Waaaah")
	end

	local params = {
		tracker_from = self._unit:movement():nav_tracker(),
		tracker_to = cover[3],
		prio = prio,
		result_clbk = callback(self, self, "clbk_pathing_results", search_id),
		id = search_id,
		access_pos = self._SO_access,
		access_neg = access_neg
	}
	
	if offset_pos then
		params.pos_to = mvector3.copy(offset_pos)
		params.tracker_to = nil
	end

	self._logic_data.active_searches[search_id] = true
	managers.navigation:search_pos_to_pos(params)

	return true
end

function CopBrain:is_criminal()
	if self._unit:in_slot(16) or self._logic_data.team.id == tweak_data.levels:get_default_team_ID("player") or self._logic_data.team.friends[tweak_data.levels:get_default_team_ID("player")] then
		return true
	end
end