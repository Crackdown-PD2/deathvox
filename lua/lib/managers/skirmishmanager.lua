local wave_difficulties = {
	"normal", --1
	"hard", --2
	"overkill", --3
	"overkill_145", --4
	"overkill_145", --5
	"easy_wish", --6
	"overkill_290", --7
	"overkill_290", --8
	"sm_wish" --9
}

function SkirmishManager:on_end_assault()
	local wave_number = self:current_wave_number()
	local new_ransom_amount = tweak_data.skirmish.ransom_amounts[wave_number]
	self:set_ransom_amount(new_ransom_amount)

	wave_number = wave_number + 1

	local new_difficulty = wave_difficulties[wave_number]

	if new_difficulty and new_difficulty ~= Global.game_settings.difficulty then
		Global.game_settings.difficulty = new_difficulty
		tweak_data:set_difficulty(new_difficulty)
	end

	if Network:is_server() then
		managers.network:session():send_to_peers("sync_end_assault_skirmish")
	end
end

function SkirmishManager:sync_start_assault(wave_number)
	if not self:is_skirmish() then
		return
	end

	for i = (self._synced_wave_number or 0) + 1, wave_number do
		self:_apply_modifiers_for_wave(i)
	end

	self._synced_wave_number = wave_number

	local new_ransom_amount = tweak_data.skirmish.ransom_amounts[wave_number]
	self:set_ransom_amount(new_ransom_amount)

	local new_difficulty = wave_difficulties[wave_number]

	if new_difficulty and new_difficulty ~= Global.game_settings.difficulty then
		Global.game_settings.difficulty = new_difficulty
		tweak_data:set_difficulty(new_difficulty)
	end
end
