require("lib/units/enemies/cop/logics/CopLogicBase")
require("lib/units/enemies/cop/logics/CopLogicInactive")
require("lib/units/enemies/cop/logics/CopLogicIdle")
require("lib/units/enemies/cop/logics/CopLogicAttack")
require("lib/units/enemies/cop/logics/CopLogicIntimidated")
require("lib/units/enemies/cop/logics/CopLogicTravel")
require("lib/units/enemies/cop/logics/CopLogicArrest")
require("lib/units/enemies/cop/logics/CopLogicGuard")
require("lib/units/enemies/cop/logics/CopLogicFlee")
require("lib/units/enemies/cop/logics/CopLogicSniper")
require("lib/units/enemies/cop/logics/CopLogicTrade")
require("lib/units/enemies/cop/logics/CopLogicPhalanxMinion")
require("lib/units/enemies/cop/logics/CopLogicPhalanxVip")
require("lib/units/enemies/tank/logics/TankCopLogicAttack")
require("lib/units/enemies/shield/logics/ShieldLogicAttack")
require("lib/units/enemies/spooc/logics/SpoocLogicIdle")
require("lib/units/enemies/spooc/logics/SpoocLogicAttack")
require("lib/units/enemies/taser/logics/TaserLogicAttack")
local old_init = CopBrain.post_init
local logic_variants = {
	security = {
		idle = CopLogicIdle,
		attack = CopLogicAttack,
		travel = CopLogicTravel,
		inactive = CopLogicInactive,
		intimidated = CopLogicIntimidated,
		arrest = CopLogicArrest,
		guard = CopLogicGuard,
		flee = CopLogicFlee,
		sniper = CopLogicSniper,
		trade = CopLogicTrade,
		phalanx = CopLogicPhalanxMinion
	}
}
local security_variant = logic_variants.security
function CopBrain:post_init()
	CopBrain._logic_variants.deathvox_shield = clone(security_variant)
	CopBrain._logic_variants.deathvox_shield.intimidated = nil
	CopBrain._logic_variants.deathvox_shield.flee = nil
	
	CopBrain._logic_variants.deathvox_heavyar = clone(security_variant)
	CopBrain._logic_variants.deathvox_lightar = clone(security_variant)
	CopBrain._logic_variants.deathvox_medic = clone(security_variant)
	CopBrain._logic_variants.deathvox_guard = clone(security_variant)
	CopBrain._logic_variants.deathvox_gman = clone(security_variant)
	CopBrain._logic_variants.deathvox_lightshot = clone(security_variant)
	CopBrain._logic_variants.deathvox_heavyshot = clone(security_variant)
	
	CopBrain._logic_variants.deathvox_guarddozer = clone(security_variant)
	
	CopBrain._logic_variants.deathvox_taser = clone(security_variant)
	CopBrain._logic_variants.deathvox_taser.attack = TaserLogicAttack
	-- CopBrain._logic_variants.deathvox_taser.travel = TaserLogicTravel
	CopBrain._logic_variants.deathvox_sniper_assault = clone(security_variant)
	CopBrain._logic_variants.deathvox_sniper = clone(security_variant)
	CopBrain._logic_variants.deathvox_cloaker = clone(security_variant)
	CopBrain._logic_variants.deathvox_cloaker.idle = SpoocLogicIdle
	CopBrain._logic_variants.deathvox_cloaker.attack = SpoocLogicAttack
	-- CopBrain._logic_variants.deathvox_cloaker.travel = SpoocLogicTravel
	CopBrain._logic_variants.deathvox_grenadier = clone(security_variant)
	
	CopBrain._logic_variants.deathvox_greendozer = clone(security_variant)
	CopBrain._logic_variants.deathvox_blackdozer = clone(security_variant)
	CopBrain._logic_variants.deathvox_lmgdozer = clone(security_variant)
	CopBrain._logic_variants.deathvox_medicdozer = clone(security_variant)

	CopBrain._logic_variants.deathvox_cop_pistol = clone(security_variant)
	CopBrain._logic_variants.deathvox_cop_revolver = clone(security_variant)
	CopBrain._logic_variants.deathvox_cop_shotgun = clone(security_variant)
	CopBrain._logic_variants.deathvox_cop_smg = clone(security_variant)
	
	CopBrain._logic_variants.deathvox_fbi_hrt = clone(security_variant)
	CopBrain._logic_variants.deathvox_fbi_veteran = clone(security_variant)
	CopBrain._logic_variants.deathvox_fbi_rookie = clone(security_variant)

	old_init(self)
end

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
		managers.network:session():send_to_peers_synched("sync_unit_converted", self._unit)

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

		local health_multiplier, damage_multiplier, accuracy_multiplier = 1, 1
		local add_armor_piercing, no_hurt_animations, melee_stagger, health_regen, highlight_prioritizing = nil

		if alive(mastermind_criminal) then
			local base_ext = mastermind_criminal:base()

			health_multiplier = health_multiplier * (base_ext:upgrade_value("player", "convert_enemies_health_multiplier") or 1)
			health_multiplier = health_multiplier * (base_ext:upgrade_value("player", "passive_convert_enemies_health_multiplier") or 1)
			damage_multiplier = damage_multiplier * (base_ext:upgrade_value("player", "convert_enemies_damage_multiplier") or 1)
			damage_multiplier = damage_multiplier * (base_ext:upgrade_value("player", "passive_convert_enemies_damage_multiplier") or 1)

			--TCD placeholders
			accuracy_multiplier = base_ext:upgrade_value("player", "convert_enemies_acc_multiplier") or 1 --placeholder
			no_hurt_animations = nil
			melee_stagger = nil
			health_regen = nil
			highlight_prioritizing = nil
		else
			local player_manager = managers.player

			health_multiplier = health_multiplier * player_manager:upgrade_value("player", "convert_enemies_health_multiplier", 1)
			health_multiplier = health_multiplier * player_manager:upgrade_value("player", "passive_convert_enemies_health_multiplier", 1)
			damage_multiplier = damage_multiplier * player_manager:upgrade_value("player", "convert_enemies_damage_multiplier", 1)
			damage_multiplier = damage_multiplier * player_manager:upgrade_value("player", "passive_convert_enemies_damage_multiplier", 1)

			--TCD placeholders
			accuracy_multiplier = base_ext:upgrade_value("player", "convert_enemies_acc_multiplier") or 1
			no_hurt_animations = nil
			melee_stagger = nil
			health_regen = nil
			highlight_prioritizing = nil
		end

		local ext_dmg = self._unit:character_damage()
		ext_dmg:convert_to_criminal(health_multiplier)

		if health_regen and health_regen ~= 1 then
			ext_dmg:set_health_regen(health_regen)
		end

		if accuracy_multiplier ~= 1 then
			if ext_dmg._original_acc_mul then
				ext_dmg._original_acc_mul = accuracy_multiplier

				ext_dmg:set_accuracy_multiplier(ext_dmg._ON_STUN_ACCURACY_DECREASE * accuracy_multiplier)
			else
				ext_dmg:set_accuracy_multiplier(accuracy_multiplier)
			end
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

			managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "character_damage", 2)
		end

		if melee_stagger then
			self._unit:movement()._joker_melee_stagger = true
		end

		if highlight_prioritizing then
			self._unit:brain()._prioritize_marked_units_by_owner = true
		end

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
else
	function CopBrain:convert_to_criminal(mastermind_criminal)
		managers.network:session():send_to_peers_synched("sync_unit_converted", self._unit)

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

local on_nav_link_unregistered_original = CopBrain.on_nav_link_unregistered
function CopBrain:on_nav_link_unregistered(element_id)
	on_nav_link_unregistered_original(self, element_id)

	if next_g(self._logic_data.active_searches) then
		for search_id, search_type in pairs_g(self._logic_data.active_searches) do
			if search_type ~= 2 then
				self._nav_links_to_check = self._nav_links_to_check or {}
				self._nav_links_to_check[search_id] = element_id
			end
		end
	end
end

local clbk_pathing_results_original = CopBrain.clbk_pathing_results
function CopBrain:clbk_pathing_results(search_id, path)
	local dead_nav_links = self._nav_links_to_check

	if dead_nav_links then
		if path then
			local element_id = dead_nav_links[search_id]

			if element_id then
				for i = 1, #path do
					local nav_point = path[i]

					if not nav_point.x and nav_point:script_data().element._id == element_id then
						path = nil

						break
					end
				end
			end

			dead_nav_links[search_id] = nil

			if not next_g(dead_nav_links) then
				dead_nav_links = nil
			end
		elseif dead_nav_links[search_id] then
			dead_nav_links[search_id] = nil

			if not next_g(dead_nav_links) then
				dead_nav_links = nil
			end
		end

		self._nav_links_to_check = dead_nav_links
	end

	clbk_pathing_results_original(self, search_id, path)
end

function CopBrain:abort_detailed_pathing(search_id)
	if not self._logic_data.active_searches[search_id] then
		return
	end

	self._logic_data.active_searches[search_id] = nil

	managers.navigation:cancel_pathing_search(search_id)

	local dead_nav_links = self._nav_links_to_check

	if dead_nav_links and dead_nav_links[search_id] then
		dead_nav_links[search_id] = nil

		if not next_g(dead_nav_links) then
			dead_nav_links = nil
		end

		self._nav_links_to_check = dead_nav_links
	end
end

function CopBrain:cancel_all_pathing_searches()
	local dead_nav_links = self._nav_links_to_check
	local contains_dead_nav_link = {}

	for search_id, search_type in pairs_g(self._logic_data.active_searches) do
		if search_type == 2 then
			managers.navigation:cancel_coarse_search(search_id)
		else
			managers.navigation:cancel_pathing_search(search_id)

			if dead_nav_links and dead_nav_links[search_id] then
				contains_dead_nav_link[search_id] = true
				dead_nav_links[search_id] = nil
			end
		end
	end

	if dead_nav_links and not next_g(dead_nav_links) then
		self._nav_links_to_check = nil
	end

	local path_results = self._logic_data.pathing_results

	if path_results and next_g(path_results) then
		for search_id, path in pairs_g(path_results) do
			if path ~= "failed" and not contains_dead_nav_link[search_id] and type_g(path[1]) ~= "table" then
				for i = 1, #path do
					local nav_point = path[i]

					if not nav_point.x and nav_point:script_data().element:nav_link_delay() then
						nav_point:set_delay_time(0)
					end
				end
			end
		end
	end

	self._logic_data.active_searches = {}
	self._logic_data.pathing_results = nil
end

function CopBrain:on_suppressed(state)
	self._logic_data.is_suppressed = state or nil

	if state and self._current_logic.on_suppressed_state then
		self._current_logic.on_suppressed_state(self._logic_data)

		if self._logic_data.char_tweak.chatter.suppress then
			if math.random() <= 0.5 then
				self._unit:sound():say("hlp", true) 
			else --hopefully some variety here now
				self._unit:sound():say("lk3a", true) 
			end
		end
	end
end
