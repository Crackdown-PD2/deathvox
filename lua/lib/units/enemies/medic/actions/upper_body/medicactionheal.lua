
function MedicActionHeal:update(t)
	if not self._unit:anim_data().healing then
		self._done = true
		self._expired = true
	end

	self._ext_movement:upd_m_head_pos()
end

-- offy's note: this may be redundant?
function MedicActionHeal:on_exit()
	if self._expired then
		CopActionWalk._chk_correct_pose(self)
	end
end
