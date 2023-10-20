local alive_g = _G.alive
local ids_func = _G.Idstring
local pairs_g = pairs
local ids_unit = ids_func("unit")
local ids_unit = ids_func("unit")
local ids_lod = ids_func("lod")
local ids_lod1 = ids_func("lod1")
local ids_ik_aim = ids_func("ik_aim")
local ids_r_toe = ids_func("RightToeBase")
local ids_l_toe = ids_func("LeftToeBase")

function CopBase:_chk_spawn_gear()
	--[[if self._unit:base():char_tweak().ends_assault_on_death then
		managers.groupai:state():register_phalanx_vip(self._unit)
		GroupAIStateBesiege:set_assault_endless(true)
		managers.hud:set_buff_enabled("vip", true)

		for u_key, u_data in pairs(managers.enemy:all_enemies()) do
			if alive(u_data.unit) then
				managers.fire:_add_hellfire_enemy(u_data.unit)
			end
		end

		for _, converted_enemy_unit in pairs(managers.groupai:state():all_converted_enemies()) do
			if alive(converted_enemy_unit) then
				local action_data = {
					variant = "fire",
					damage = 99999999999,
					weapon_unit = nil,
					attacker_unit = nil,
					col_ray = {unit = converted_enemy_unit},
					is_fire_dot_damage = true,
					is_molotov = false
				}
				converted_enemy_unit:character_damage():damage_fire(action_data)
			end
		end
	end

	if alive(managers.groupai:state():phalanx_vip()) then
		managers.fire:_add_hellfire_enemy(self._unit)
	end]]

	if self:has_tag("spooc") then
		if self._unit:damage() and self._unit:damage():has_sequence("turn_on_spook_lights") then
			self._unit:damage():run_sequence_simple("turn_on_spook_lights")
		end

		local job_tweak_data = tweak_data.narrative.jobs[managers.job:current_real_job_id()]

		if job_tweak_data and job_tweak_data.is_christmas_heist then
			local align_obj_name = Idstring("Head")
			local align_obj = self._unit:get_object(align_obj_name)
			self._headwear_unit = World:spawn_unit(Idstring("units/payday2/characters/ene_acc_spook_santa_hat/ene_acc_spook_santa_hat"), Vector3(), Rotation())

			self._unit:link(align_obj_name, self._headwear_unit, self._headwear_unit:orientation_object():name())
		end
	elseif managers.perpetual_event:has_event_santa_hats() then
		if self._tweak_table == "tank_medic" or self._tweak_table == "tank_mini" then
			self._headwear_unit = safe_spawn_unit("units/pd2_dlc_xm20/characters/ene_acc_dozer_zeal_santa_hat/ene_acc_dozer_zeal_santa_hat", Vector3(), Rotation())
		elseif self._tweak_table == "tank" then
			local region = tweak_data.levels:get_ai_group_type()
			local difficulty_index = tweak_data:difficulty_to_index(Global and Global.game_settings and Global.game_settings.difficulty or "overkill")

			if region == "russia" or region == "federales" then
				self._headwear_unit = safe_spawn_unit("units/pd2_dlc_xm20/characters/ene_acc_dozer_akan_santa_hat/ene_acc_dozer_akan_santa_hat", Vector3(), Rotation())
			elseif difficulty_index == 8 then
				self._headwear_unit = safe_spawn_unit("units/pd2_dlc_xm20/characters/ene_acc_dozer_zeal_santa_hat/ene_acc_dozer_zeal_santa_hat", Vector3(), Rotation())
			else
				self._headwear_unit = safe_spawn_unit("units/pd2_dlc_xm20/characters/ene_acc_dozer_santa_hat/ene_acc_dozer_santa_hat", Vector3(), Rotation())
			end
		end
	end
end

function CopBase:default_weapon_name()
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)

	if diff_index < 4 then
		local unit_name = self._unit:name()
		local classic_shield = unit_name == Idstring("units/pd2_mod_classic/characters/ene_deathvox_classic_shield/ene_deathvox_classic_shield") or unit_name == Idstring("units/pd2_mod_classic/characters/ene_deathvox_classic_shield/ene_deathvox_classic_shield_husk")

		if classic_shield then
			local deathvox_pistol = Idstring("units/pd2_mod_gageammo/pew_pew_lasers/wpn_npc_c45/wpn_npc_c45")

			return deathvox_pistol
		end
	end

	local default_weapon_id = self._default_weapon_id
	local weap_ids = tweak_data.character.weap_ids

	for i_weap_id, weap_id in ipairs(weap_ids) do
		if default_weapon_id == weap_id then
			return tweak_data.character.weap_unit_names[i_weap_id]
		end
	end
end

Hooks:PostHook(CopBase, "init", "res_init", function(self)
	self.voice_end_t = 0
end)

function CopBase:play_voiceline(buffer, force)
	local t = TimerManager:game():time()
	
	if force or t > self.voice_end_t then
		if self.my_voice and not self.my_voice:is_closed() then
			self.my_voice:stop()
			self.my_voice:close()
		end

		self.my_voice = XAudio.UnitSource:new(self._unit, buffer)
		self.voice_end_t = t + buffer:get_length()
	end
end

function CopBase:set_visibility_state(stage)
	local unit = self._unit
	stage = stage or false
	local state = stage and true

	if not state and not self._allow_invisible then
		state = true
		stage = 3
	end

	if self._lod_stage == stage then
		return
	end

	local inventory = unit:inventory()
	local weapon = inventory and inventory.get_weapon and inventory:get_weapon()

	if weapon then
		weapon:base():set_flashlight_light_lod_enabled(stage ~= 2 and not not stage)
	end

	if self._visibility_state ~= state then
		if inventory then
			inventory:set_visibility_state(state)

			local mask_unit = inventory._mask_unit

			if mask_unit and alive_g(mask_unit) then
				mask_unit:set_visible(state)

				local linked_units = mask_unit:children()

				for i = 1, #linked_units do
					local linked_unit = linked_units[i]

					linked_unit:set_visible(state)
				end
			end
		end

		unit:set_visible(state)

		local headwear_unit = self._headwear_unit

		if headwear_unit then
			headwear_unit:set_visible(state)
		end

		local spawn_manager_ext = unit:spawn_manager()

		if spawn_manager_ext then
			local linked_units = spawn_manager_ext:linked_units()

			if linked_units then
				local spawned_units = spawn_manager_ext:spawned_units()

				for unit_id, _ in pairs_g(linked_units) do
					local unit_entry = spawned_units[unit_id]

					if unit_entry then
						local child_unit = unit_entry.unit

						if alive_g(child_unit) then
							child_unit:set_visible(state)
						end
					end
				end
			end
		end

		local set_animatable_state = state

		if not set_animatable_state then
			local anim_ext = self._ext_anim

			if not anim_ext.can_freeze or not anim_ext.upper_body_empty then
				set_animatable_state = true
			end
		end

		if set_animatable_state ~= self._animatable_state then
			self._animatable_state = set_animatable_state

			unit:set_animatable_enabled(ids_lod, set_animatable_state)
			unit:set_animatable_enabled(ids_ik_aim, set_animatable_state)
		end

		self._visibility_state = state
	end

	if state then
		if stage ~= self._last_set_anim_lod then
			self._last_set_anim_lod = stage

			self:set_anim_lod(stage)
		end

		if stage == 1 then
			unit:movement():enable_update(true)

			unit:set_animatable_enabled(ids_lod1, true)
		elseif self._lod_stage == 1 then
			unit:set_animatable_enabled(ids_lod1, false)
		end
	else
		if self._lod_stage == 1 then
			unit:set_animatable_enabled(ids_lod1, false)
		end

		local anim_lod = 3

		if anim_lod ~= self._last_set_anim_lod then
			self._last_set_anim_lod = anim_lod

			self:set_anim_lod(anim_lod)
		end
	end

	self._lod_stage = stage

	self:chk_freeze_anims()
end

function CopBase:melee_weapon()
	local set_melee = self._char_tweak.melee_weapon

	if set_melee and set_melee ~= "weapon" then
		local ms = managers
		local melee_weapon_data = ms.blackmarket:get_melee_weapon_data(set_melee)

		if melee_weapon_data then
			local third_unit = melee_weapon_data.third_unit

			if third_unit then
				local name = ids_func(third_unit)
				local dr = ms.dyn_resource
				local pack_path = "packages/dyn_resources"
				if not dr:is_resource_ready(ids_unit, name, pack_path) then
					dr:load(ids_unit, name, pack_path, false)
				end
			end
		end
	end

	return set_melee or self._melee_weapon_table or "weapon"
end

function CopBase:pre_destroy(unit)
	UnitBase.pre_destroy(self, unit)

	local headwear = self._headwear_unit

	if alive_g(headwear) then
		headwear:set_slot(0)
	end

	unit:brain():pre_destroy(unit)
	self._ext_movement:pre_destroy()
	self._unit:inventory():pre_destroy()
end
