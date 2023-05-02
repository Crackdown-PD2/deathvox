function SpoocLogicIdle._exit_hiding(data)
	data.unit:brain():set_objective({ --this used to call data.unit:set_objective in vanilla...
		type = "act",
		action = {
			variant = "idle",
			body_part = 1,
			type = "act",
			blocks = {
				heavy_hurt = -1,
				idle = -1,
				action = -1,
				turn = -1,
				light_hurt = -1,
				walk = -1,
				fire_hurt = -1,
				hurt = -1,
				expl_hurt = -1
			}
		}
	})
end

function SpoocLogicIdle._chk_exit_hiding(data)
	for u_key, attention_data in pairs(data.detected_attention_objects) do
		if AIAttentionObject.REACT_SHOOT <= attention_data.reaction and data.unit:anim_data().hide_loop then
			if attention_data.dis < 1500 and (attention_data.verified or attention_data.nearly_visible) then
				SpoocLogicIdle._exit_hiding(data)
			elseif attention_data.dis < 700 then
				if attention_data.nav_tracker then
					local my_nav_seg_id = data.unit:movement():nav_tracker():nav_segment()
					local enemy_areas = managers.groupai:state():get_areas_from_nav_seg_id(attention_data.nav_tracker:nav_segment())

					for _, area in ipairs(enemy_areas) do
						if area.nav_segs[my_nav_seg_id] then
							SpoocLogicIdle._exit_hiding(data)

							break
						end
					end
				end
				
				if math.abs(attention_data.m_pos.z - data.m_pos.z) < 250 and attention_data.dis < 400 then
					SpoocLogicIdle._exit_hiding(data)
					
					break
				end
			end
		end
	end
end