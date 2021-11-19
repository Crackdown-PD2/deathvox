function CopLogicInactive.on_enemy_weapons_hot(data)
	if data.unit:interaction():active() then
		data.unit:interaction():set_active(false, true, true)
	end
end

function CopLogicInactive._register_attention(data, my_data)
	if data.unit:character_damage():dead() then
		if managers.groupai:state():whisper_mode() then
			data.brain:set_attention_settings({
				corpse_sneak = true
			})
		else
			data.brain:set_attention_settings(nil)
		end
	else
		data.unit:brain():set_attention_settings(nil)
	end
end
