function TaserLogicAttack.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.unit:brain():cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {unit = data.unit}
	data.internal_data = my_data
	my_data.detection = data.char_tweak.detection.combat
	my_data.tase_distance = data.char_tweak.weapon.is_rifle.tase_distance or 1500

	if old_internal_data then
		my_data.turning = old_internal_data.turning
		my_data.firing = old_internal_data.firing
		my_data.shooting = old_internal_data.shooting
		my_data.attention_unit = old_internal_data.attention_unit

		CopLogicAttack._set_best_cover(data, my_data, old_internal_data.best_cover)
		CopLogicAttack._set_nearest_cover(my_data, old_internal_data.nearest_cover)
	end

	local key_str = tostring(data.key)
	my_data.update_task_key = "TaserLogicAttack.queued_update" .. key_str

	CopLogicBase.queue_task(my_data, my_data.update_task_key, TaserLogicAttack.queued_update, data, data.t, data.important)
	data.unit:brain():set_update_enabled_state(false)
	CopLogicIdle._chk_has_old_action(data, my_data)

	local objective = data.objective

	if objective then
		my_data.attitude = data.objective.attitude or "avoid"
	end

	my_data.weapon_range = data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range
	my_data.cover_test_step = 1
	data.tase_delay_t = data.tase_delay_t or -1

	TaserLogicAttack._chk_play_charge_weapon_sound(data, my_data, data.attention_obj)
	data.unit:movement():set_cool(false)

	if my_data ~= data.internal_data then
		return
	end

	data.unit:brain():set_attention_settings({cbt = true})
end

function TaserLogicAttack._chk_reaction_to_attention_object(data, attention_data, stationary)
	local reaction = CopLogicIdle._chk_reaction_to_attention_object(data, attention_data, stationary)

	if reaction < AIAttentionObject.REACT_SHOOT or not attention_data.criminal_record or not attention_data.is_person then
		return reaction
	end

	if attention_data.is_human_player and not attention_data.unit:movement():is_taser_attack_allowed() then
		return AIAttentionObject.REACT_COMBAT
	end

	if (attention_data.is_human_player or not attention_data.unit:movement():chk_action_forbidden("hurt")) and attention_data.verified and attention_data.verified_dis <= data.internal_data.tase_distance and data.tase_delay_t < data.t then
		return AIAttentionObject.REACT_SPECIAL_ATTACK --Fixes tasers not opening fire on things at ranges beyond their tasing range.
	end

	return reaction
end
