function CopLogicPhalanxMinion.register_in_group_ai(unit)
	if not managers.groupai:state():is_unit_in_phalanx_minion_data(unit:key()) then
		managers.groupai:state():register_phalanx_minion(unit)
		managers.groupai:state():unregister_special_unit(unit:key(), unit:base()._tweak_table) --unregister as Shield to not prevent other Shield groups from spawning
	end
end

function CopLogicPhalanxMinion.breakup(remote_call)
	local groupai = managers.groupai:state()
	local phalanx_minions = groupai:phalanx_minions()
	local phalanx_spawn_group = groupai:phalanx_spawn_group()

	if phalanx_spawn_group then
		local phalanx_center_pos = groupai._phalanx_center_pos
		local phalanx_center_nav_seg = managers.navigation:get_nav_seg_from_pos(phalanx_center_pos)
		local phalanx_area = groupai:get_area_from_nav_seg_id(phalanx_center_nav_seg)
		local grp_objective = {
			type = "hunt",
			area = phalanx_area,
			nav_seg = phalanx_center_nav_seg
		}

		groupai:_set_objective_to_enemy_group(phalanx_spawn_group, grp_objective)
	end

	for unit_key, unit in pairs(phalanx_minions) do
		if alive(unit) then
			local brain = unit:brain()

			if brain and brain:objective() then
				print("CopLogicPhalanxMinion.breakup current objective type: ", brain:objective().type)
				brain:set_objective(nil)
			end
			unit:base().is_phalanx = nil --the only change in this function, so you can stop yelling OH SHIT CAPTAIN at them once Winters is defeated. Also because this value can be used to allow stuff that normally doesn't work on them (i.e. shield_knock) if they no longer belong to a Phalanx
		end

		groupai:unregister_phalanx_minion(unit_key)
	end

	groupai:phalanx_despawned()

	if not remote_call then
		CopLogicPhalanxVip.breakup(true)
	end
end
