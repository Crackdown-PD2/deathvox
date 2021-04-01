HuskTeamAIBase.chk_freeze_anims = CopBase.chk_freeze_anims

local post_init_original = HuskTeamAIBase.post_init
function HuskTeamAIBase:post_init()
	self._ext_movement = self._unit:movement()

	post_init_original(self)
end
