local cd_wave_difficulties = {
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
	local new_difficulty = cd_wave_difficulties[wave_number]

	if new_difficulty and new_difficulty ~= Global.game_settings.difficulty then
		Global.game_settings.difficulty = new_difficulty
		tweak_data:set_difficulty(new_difficulty)
	end

	if Network:is_server() then
		managers.network:session():send_to_peers("sync_end_assault_skirmish")
	end
end

function SkirmishManager:sync_load(data)
	local state = data.SkirmishManager
	local wave_number = state.wave_number

	self:sync_start_assault(wave_number)

	self._start_wave = wave_number

	local new_ransom_amount = tweak_data.skirmish.ransom_amounts[wave_number]

	if new_ransom_amount then
		self:set_ransom_amount(new_ransom_amount)
	end

	local new_difficulty = cd_wave_difficulties[wave_number]

	if new_difficulty and new_difficulty ~= Global.game_settings.difficulty then
		Global.game_settings.difficulty = new_difficulty
		tweak_data:set_difficulty(new_difficulty)
	end
end
