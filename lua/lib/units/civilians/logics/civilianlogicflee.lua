function CivilianLogicFlee.on_rescue_SO_completed(ignore_this, data, good_pig)
	if data.internal_data.rescuer and good_pig:key() == data.internal_data.rescuer:key() then
		data.internal_data.rescue_active = nil
		data.internal_data.rescuer = nil

		if data.name == "surrender" then
			local new_action = nil

			if data.unit:anim_data().stand and data.is_tied then
				data.brain:on_hostage_move_interaction(nil, "release")
			elseif data.unit:anim_data().drop or data.unit:anim_data().tied then
				new_action = {
					variant = "stand",
					body_part = 1,
					type = "act"
				}
			end

			if data.is_tied then
				managers.network:session():send_to_peers_synched("sync_unit_surrendered", data.unit, false)

				data.is_tied = nil
			end

			if new_action then
				data.unit:interaction():set_active(false, true)
				data.unit:brain():action_request(new_action)
			end

			data.unit:brain():set_objective({
				is_default = true,
				was_rescued = true,
				type = "free"
			})
		elseif not CivilianLogicFlee._get_coarse_flee_path(data) then
			return
		end
	end

	data.unit:brain():set_update_enabled_state(true)
	managers.groupai:state():on_civilian_freed()
	good_pig:sound():say("h01", true)
end
