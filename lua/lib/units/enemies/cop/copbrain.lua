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
	CopBrain._logic_variants.deathvox_shield.attack = ShieldLogicAttack
	CopBrain._logic_variants.deathvox_shield.intimidated = nil
	CopBrain._logic_variants.deathvox_shield.flee = nil
	
	CopBrain._logic_variants.deathvox_heavyar = security_variant
	CopBrain._logic_variants.deathvox_lightar = security_variant
	CopBrain._logic_variants.deathvox_medic = security_variant
	CopBrain._logic_variants.deathvox_guard = security_variant
	CopBrain._logic_variants.deathvox_gman = security_variant
	CopBrain._logic_variants.deathvox_lightshot = security_variant
	CopBrain._logic_variants.deathvox_heavyshot = security_variant
	
	CopBrain._logic_variants.deathvox_guarddozer = clone(security_variant)
	CopBrain._logic_variants.deathvox_guarddozer.attack = TankCopLogicAttack
	
	CopBrain._logic_variants.deathvox_taser = clone(security_variant)
	CopBrain._logic_variants.deathvox_taser.attack = TaserLogicAttack
	CopBrain._logic_variants.deathvox_sniper_assault = security_variant
	CopBrain._logic_variants.deathvox_cloaker = clone(security_variant)
	CopBrain._logic_variants.deathvox_cloaker.idle = SpoocLogicIdle
	CopBrain._logic_variants.deathvox_cloaker.attack = SpoocLogicAttack
	CopBrain._logic_variants.deathvox_grenadier = security_variant
	
	CopBrain._logic_variants.deathvox_greendozer = clone(security_variant)
	CopBrain._logic_variants.deathvox_greendozer.attack = TankCopLogicAttack
	CopBrain._logic_variants.deathvox_blackdozer = clone(security_variant)
	CopBrain._logic_variants.deathvox_blackdozer.attack = TankCopLogicAttack
	CopBrain._logic_variants.deathvox_lmgdozer = clone(security_variant)
	CopBrain._logic_variants.deathvox_lmgdozer.attack = TankCopLogicAttack
	CopBrain._logic_variants.deathvox_medicdozer = clone(security_variant)
	CopBrain._logic_variants.deathvox_medicdozer.attack = TankCopLogicAttack

	CopBrain._logic_variants.deathvox_cop_pistol = security_variant
	CopBrain._logic_variants.deathvox_cop_revolver = security_variant
	CopBrain._logic_variants.deathvox_cop_shotgun = security_variant
	CopBrain._logic_variants.deathvox_cop_smg = security_variant
	
	CopBrain._logic_variants.deathvox_fbi_hrt = security_variant
	CopBrain._logic_variants.deathvox_fbi_veteran = security_variant
	CopBrain._logic_variants.deathvox_fbi_rookie = security_variant

	old_init(self)
end

function CopBrain:convert_to_criminal(mastermind_criminal)
	self._logic_data.is_converted = true
	self._logic_data.group = nil
	local mover_col_body = self._unit:body("mover_blocker")

	mover_col_body:set_enabled(false)

	local attention_preset = PlayerMovement._create_attention_setting_from_descriptor(self, tweak_data.attention.settings.team_enemy_cbt, "team_enemy_cbt")

	self._attention_handler:override_attention("enemy_team_cbt", attention_preset)

	local health_multiplier = 1
	local damage_multiplier = 1

	if alive(mastermind_criminal) then
		health_multiplier = health_multiplier * (mastermind_criminal:base():upgrade_value("player", "convert_enemies_health_multiplier") or 1)
		health_multiplier = health_multiplier * (mastermind_criminal:base():upgrade_value("player", "passive_convert_enemies_health_multiplier") or 1)
		damage_multiplier = damage_multiplier * (mastermind_criminal:base():upgrade_value("player", "convert_enemies_damage_multiplier") or 1)
		damage_multiplier = damage_multiplier * (mastermind_criminal:base():upgrade_value("player", "passive_convert_enemies_damage_multiplier") or 1)
	else
		health_multiplier = health_multiplier * managers.player:upgrade_value("player", "convert_enemies_health_multiplier", 1)
		health_multiplier = health_multiplier * managers.player:upgrade_value("player", "passive_convert_enemies_health_multiplier", 1)
		damage_multiplier = damage_multiplier * managers.player:upgrade_value("player", "convert_enemies_damage_multiplier", 1)
		damage_multiplier = damage_multiplier * managers.player:upgrade_value("player", "passive_convert_enemies_damage_multiplier", 1)
	end

	self._unit:character_damage():convert_to_criminal(health_multiplier)

	self._logic_data.attention_obj = nil

	CopLogicBase._destroy_all_detected_attention_object_data(self._logic_data)

	self._SO_access = managers.navigation:convert_access_flag(tweak_data.character.russian.access)
	self._logic_data.SO_access = self._SO_access
	self._logic_data.SO_access_str = tweak_data.character.russian.access
	self._slotmask_enemies = managers.slot:get_mask("enemies")
	self._logic_data.enemy_slotmask = self._slotmask_enemies
	local equipped_w_selection = self._unit:inventory():equipped_selection()

	if equipped_w_selection then
		self._unit:inventory():remove_selection(equipped_w_selection, true)
	end

	local weap_name = self._unit:base():default_weapon_name()

	self._unit:movement():add_weapons()
	if self._unit:inventory():is_selection_available(1) then
		self._unit:inventory():equip_selection(1, true)
	elseif self._unit:inventory():is_selection_available(2) then
		self._unit:inventory():equip_selection(2, true)
	end
	local weapon_unit = self._unit:inventory():equipped_unit()

	weapon_unit:base():add_damage_multiplier(damage_multiplier)
	self:set_objective(nil)
	self:set_logic("idle", nil)

	self._logic_data.objective_complete_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_criminal_objective_complete")
	self._logic_data.objective_failed_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_criminal_objective_failed")

	managers.groupai:state():on_criminal_jobless(self._unit)
	self._unit:base():set_slot(self._unit, 16)
	self._unit:movement():set_stance("hos")

	local action_data = {
		clamp_to_graph = true,
		type = "act",
		body_part = 1,
		variant = "attached_collar_enter",
		blocks = {
			heavy_hurt = -1,
			hurt = -1,
			action = -1,
			light_hurt = -1,
			walk = -1
		}
	}

	self._unit:brain():action_request(action_data)
	self._unit:sound():say("cn1", true, nil)
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

local REACT_IDLE = AIAttentionObject.REACT_IDLE
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_set = mvector3.set
local temp_vec1 = Vector3()
local temp_vec2 = Vector3()

local fs_original_copbrain_clbkdeath = CopBrain.clbk_death
function CopBrain:clbk_death(my_unit, damage_info)
	local gstate = managers.groupai:state()
	if gstate:whisper_mode() then
		fs_original_copbrain_clbkdeath(self, my_unit, damage_info)
	else
		local my_unit_key = my_unit:key()
		for u_key, unit in pairs(gstate._converted_police) do
			if u_key == my_unit_key then
				for _, cop_unit in pairs(managers.enemy:all_enemies()) do
					local attention_info = cop_unit.brain and cop_unit:brain()._logic_data.detected_attention_objects[my_unit_key]
					if attention_info then
						attention_info.previous_reaction = REACT_IDLE
					end
				end
			else
				local attention_info = unit:brain()._logic_data.detected_attention_objects[my_unit_key]
				if attention_info then
					attention_info.previous_reaction = REACT_IDLE
				end
			end
		end
		fs_original_copbrain_clbkdeath(self, my_unit, damage_info)
		gstate:unregister_AI_attention_object(my_unit_key)
	end
end

local fs_original_copbrain_converttocriminal = CopBrain.convert_to_criminal
function CopBrain:convert_to_criminal(mastermind_criminal)
	fs_original_copbrain_converttocriminal(self, mastermind_criminal)
	self._unit:movement().fs_do_track = nil
end

local fs_original_copbrain_oncriminalneutralized = CopBrain.on_criminal_neutralized
function CopBrain:on_criminal_neutralized(criminal_key)
	fs_original_copbrain_oncriminalneutralized(self, criminal_key)
	local attention_info = self._logic_data.detected_attention_objects[criminal_key]
	if attention_info then
		attention_info.previous_reaction = nil
	end
end

function CopBrain:action_complete_clbk(action)
	if not action.itr_fake_complete then
		if action.chk_block then
			local u_mov = self._unit:movement()
			u_mov.fs_blockers_nr = u_mov.fs_blockers_nr - 1
		end

		local action_desc = action._action_desc
		if action_desc and action_desc.variant and action_desc.variant:find('e_so_sup_fumble_inplace') == 1 then
			local u_mov = self._unit:movement()
			if u_mov._action_common_data.is_suppressed and action.expired and action:expired() then
				local allowed_fumbles = {'e_so_sup_fumble_inplace_3'}

				if u_mov._suppression.transition then
					local vec_from = temp_vec1
					local vec_to = temp_vec2
					local ray_params = {
						allow_entry = false,
						trace = true,
						tracker_from = u_mov:nav_tracker(),
						pos_from = vec_from,
						pos_to = vec_to
					}

					mvec3_set(vec_from, u_mov:m_pos())
					mvec3_set(vec_to, u_mov:m_rot():y())
					mvec3_mul(vec_to, -100)
					mvec3_add(vec_to, u_mov:m_pos())
					local allow = not managers.navigation:raycast(ray_params)
					if allow then
						table.insert(allowed_fumbles, 'e_so_sup_fumble_inplace_1')
					end

					mvec3_set(vec_from, u_mov:m_pos())
					mvec3_set(vec_to, u_mov:m_rot():x())
					mvec3_mul(vec_to, 200)
					mvec3_add(vec_to, u_mov:m_pos())
					allow = not managers.navigation:raycast(ray_params)
					if allow then
						table.insert(allowed_fumbles, 'e_so_sup_fumble_inplace_2')
					end

					mvec3_set(vec_from, u_mov:m_pos())
					mvec3_set(vec_to, u_mov:m_rot():x())
					mvec3_mul(vec_to, -200)
					mvec3_add(vec_to, u_mov:m_pos())
					allow = not managers.navigation:raycast(ray_params)
					if allow then
						table.insert(allowed_fumbles, 'e_so_sup_fumble_inplace_4')
					end
				end

				local action_desc = {
					body_part = 1,
					type = 'act',
					variant = allowed_fumbles[math.random(#allowed_fumbles)],
					blocks = {
						action = -1,
						walk = -1
					}
				}
				u_mov:action_request(action_desc)
			end
		end
	end

	self._current_logic.action_complete_clbk(self._logic_data, action)
end

local fs_original_copbrain_resetlogicdata = CopBrain._reset_logic_data
function CopBrain:_reset_logic_data()
	fs_original_copbrain_resetlogicdata(self)
	self._logic_data._tweak_table = self._unit:base()._tweak_table
end
