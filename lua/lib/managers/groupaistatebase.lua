local old_group_misc_data = GroupAIStateBase._init_misc_data
function GroupAIStateBase:_init_misc_data()
	old_group_misc_data(self)
	self._special_unit_types = {
		tank = true,
		spooc = true,
		shield = true,
		taser = true,
		boom = true,
		medic = true
	}
end

local old_group_base = GroupAIStateBase.on_simulation_started
function GroupAIStateBase:on_simulation_started()
	old_group_base(self)
	self._special_unit_types = {
		tank = true,
		spooc = true,
		shield = true,
		taser = true,
		boom = true,
		medic = true
	}
end