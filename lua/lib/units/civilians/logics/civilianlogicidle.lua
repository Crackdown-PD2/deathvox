function CivilianLogicIdle.on_alert(data, alert_data)
	if data.is_tied and data.unit:anim_data().stand then
		return
	end

	local my_data = data.internal_data
	local my_dis, alert_delay = nil
	local my_listen_pos = data.unit:movement():m_head_pos()
	local alert_epicenter = alert_data[2]

	if CopLogicBase._chk_alert_obstructed(data.unit:movement():m_head_pos(), alert_data) then
		return
	end

	if CopLogicBase.is_alert_aggressive(alert_data[1]) and not data.unit:base().unintimidateable then
		if not data.unit:movement():cool() then
			local aggressor = alert_data[5]

			if aggressor and aggressor:base() then
				local is_intimidation = nil

				if aggressor:base().is_local_player then
					if managers.player:has_category_upgrade("player", "civ_calming_alerts") then
						is_intimidation = true
					end
				elseif aggressor:base().is_husk_player and aggressor:base():upgrade_value("player", "civ_calming_alerts") then
					is_intimidation = true
				end

				if is_intimidation then
					if not data.brain:interaction_voice() then
						data.unit:brain():on_intimidated(1, aggressor)
					end

					return
				end
			end
		end

		data.unit:movement():set_cool(false, managers.groupai:state().analyse_giveaway(data.unit:base()._tweak_table, alert_data[5], alert_data))
		data.unit:movement():set_stance(data.is_tied and "cbt" or "hos")
	end

	if alert_data[5] then
		local att_obj_data, is_new = CopLogicBase.identify_attention_obj_instant(data, alert_data[5]:key())
	end

	if my_data == data.internal_data and not data.char_tweak.ignores_aggression then
		my_dis = my_dis or alert_epicenter and mvector3.distance(my_listen_pos, alert_epicenter) or 3000
		alert_delay = math.lerp(1, 4, math.min(1, my_dis / 2000)) * math.random()

		if not my_data.delayed_alert_id then
			my_data.delayed_alert_id = "alert" .. tostring(data.key)

			CopLogicBase.add_delayed_clbk(my_data, my_data.delayed_alert_id, callback(CivilianLogicIdle, CivilianLogicIdle, "_delayed_alert_clbk", {
				data = data,
				alert_data = clone(alert_data)
			}), TimerManager:game():time() + alert_delay)
		end
	end
end
