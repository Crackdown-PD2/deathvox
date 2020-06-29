function PlayerCarry:_upd_attention()
	if managers.groupai:state():whisper_mode() and not self._state_data.ducking then
		local preset = {
			"pl_friend_combatant_cbt",
			"pl_friend_non_combatant_cbt",
			"pl_foe_combatant_cbt_stand",
			"pl_foe_non_combatant_cbt_stand"
		}

		self._ext_movement:set_attention_settings(preset)
	else
		PlayerCarry.super._upd_attention(self)
	end
end
