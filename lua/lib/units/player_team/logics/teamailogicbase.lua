function TeamAILogicBase._set_attention_obj(data, new_att_obj, new_reaction)
	TeamAILogicBase.shouting_and_marking(data, data.internal_data, data.unit)

	local old_att_obj = data.attention_obj
	data.attention_obj = new_att_obj

	if new_att_obj then
		new_att_obj.reaction = new_reaction or new_att_obj.settings.reaction
	end

	local criminal = data.unit
	local my_data = data.internal_data
	local weapon_unit = criminal:inventory():equipped_unit()
	local weapon_tweak = weapon_unit:base():weapon_tweak_data()
	local current_logic = criminal:brain() and criminal:brain()._current_logic_name

	if not criminal:anim_data().reload and not my_data.firing and not my_data.shooting and not criminal:movement():chk_action_forbidden("reload") and current_logic ~= "assault" then
		TeamAILogicBase.idle_reload(data, my_data, criminal, weapon_unit, weapon_tweak)
	end

	if weapon_unit and weapon_tweak.reload == "looped" and criminal:brain()._loop_t and criminal:brain()._loop_t < data.t then --doing a looped reload
		if not criminal:movement():chk_action_forbidden("reload") and criminal:anim_data().reload then --wasn't interrupted and is still doing the loop
			local res = criminal:movement():play_redirect("reload_looped_exit") --exit the animation

			if res then
				managers.network:session():send_to_peers("play_distance_interact_redirect", criminal, "reload_looped_exit") --needs testing (speed could be synced with modified sync code to add multipliers as well)
			end
		end

		criminal:brain()._loop_t = nil --stop the loop
	end

	if old_att_obj and new_att_obj and old_att_obj.u_key == new_att_obj.u_key then
		if new_att_obj.stare_expire_t and new_att_obj.stare_expire_t < data.t then
			if new_att_obj.settings.pause then
				new_att_obj.stare_expire_t = nil
				new_att_obj.pause_expire_t = data.t + math.lerp(new_att_obj.settings.pause[1], new_att_obj.settings.pause[2], math.random())

				print("[TeamAILogicBase._chk_focus_on_attention_object] pausing for", current_attention.pause_expire_t - data.t, "sec")
			end
		elseif new_att_obj.pause_expire_t and new_att_obj.pause_expire_t < data.t then
			new_att_obj.pause_expire_t = nil
			new_att_obj.stare_expire_t = data.t + math.lerp(new_att_obj.settings.duration[1], new_att_obj.settings.duration[2], math.random())
		end
	elseif new_att_obj and new_att_obj.settings.duration then
		new_att_obj.stare_expire_t = data.t + math.lerp(new_att_obj.settings.duration[1], new_att_obj.settings.duration[2], math.random())
		new_att_obj.pause_expire_t = nil
	end
end

function TeamAILogicBase.idle_reload(data, my_data, criminal, weapon_unit, weapon_tweak)
	local magazine_size, current_ammo_in_mag = weapon_unit:base():ammo_info()

	if weapon_unit and current_ammo_in_mag <= magazine_size * 0.5 then --weapon has half or less ammo in it's mag
		local reload_speed = data.char_tweak.weapon[weapon_tweak.usage].RELOAD_SPEED or 1 --reload speed multiplier from charactertweakdata preset

		if weapon_tweak.reload == "looped" then
			local anim_multiplier = weapon_tweak.looped_reload_speed or 1 --reload speed multiplier from weapontweakdata (usually decreases the speed)

			anim_multiplier = anim_multiplier * reload_speed --final speed multiplier for the animation

			local res = criminal:movement():play_redirect("reload_looped") --start the loop animation

			if res then
				criminal:anim_state_machine():set_speed(res, anim_multiplier) --modify the speed of the animation

				local sound_prefix = weapon_tweak.sounds.prefix
				local single_reload = sound_prefix == "nagant_npc" or sound_prefix == "ching_npc" or sound_prefix == "ecp_npc" --using sounds because it's vanilla weapontweakdata friendly, replace with a proper check
				local loop_amount = not single_reload and magazine_size - current_ammo_in_mag or 1 --self-explanatory, 1 loop for each round missing from the mag unless the weapon is supposed to reload all at once

				criminal:brain()._loop_t = data.t + (1 * ((0.45 * loop_amount) / anim_multiplier)) --store the time loop in the unit's brain
				weapon_unit:base():on_reload() --refill the magazine, will make it so each loop adds a round later (maybe)
				managers.network:session():send_to_peers("play_distance_interact_redirect", criminal, "reload_looped") --needs testing (speed could be synced with modified sync code to add multipliers as well)
			end
		else
			local res = criminal:movement():play_redirect("reload") --standard reloads

			if res then
				criminal:anim_state_machine():set_speed(res, reload_speed) --modify the speed of the animation
				weapon_unit:base():on_reload() --refill the magazine
			end
		end

		managers.network:session():send_to_peers("reload_weapon_cop", criminal) --set ammo to 0 for the unit for clients
	end
end

function TeamAILogicBase.shouting_and_marking(data, my_data, criminal)
	local allow_domination = true --placeholder for an options menu toggle or a bot skill
	local only_dom_assistance = allow_domination and true --true is also a placeholder here

	local in_casing_mode = criminal:movement():cool()
	local being_tased = criminal:movement():tased()
	local completely_incapacitated = criminal:character_damage():fatal()
	local bleeding_out = criminal:character_damage():bleed_out() --but not completely incapacitated
	local is_cuffed = criminal:character_damage():arrested()

	if not completely_incapacitated and not being_tased and not my_data.acting then
		if not criminal:brain()._shouted_t or 1.5 < data.t - criminal:brain()._shouted_t then --not in shouting cooldown
			local assault_wave_in_progress = managers.groupai:state():get_assault_mode()
			local cannot_turn = assault_wave_in_progress and (my_data.firing or my_data.shooting)
			local civilian = TeamAILogicBase._find_intimidateable_civilians(criminal, cannot_turn, false, data.t)
			local enemy = TeamAILogicBase._find_intimidateable_enemies(data, criminal, only_dom_assistance, false)
			local mark_enemy = TeamAILogicBase._find_unit_to_mark(data, criminal, false, false)

			if not in_casing_mode and not bleeding_out and not is_cuffed then
				if not my_data._intimidate_t or my_data._intimidate_t + 2 < data.t then --can shout to intimidate (slightly longer to allow marking and battlecry shouts to play in between)
					TeamAILogicBase.intimidate_civilians(data, criminal) --shout at valid civilians in sight or very close by

					if civilian then --found valid civilian
						local is_escort = tweak_data.character[civilian:base()._tweak_table].is_escort

						if is_escort then
							local last_i_t = civilian:brain()._last_bot_e_intimidation_t
							local moving = civilian:anim_data().move

							if not moving and (not last_i_t or 2 < data.t - last_i_t) or moving and (not last_i_t or 4 < data.t - last_i_t) then --usual cooldown (2s) to make the escort move + flavour "GOGOGO" every 4s
								if (not my_data._intimidate_t or my_data._intimidate_t + 2 < data.t) and not my_data._turning_to_intimidate then --can shout to intimidate and not already turning
									if not cannot_turn and CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, criminal:movement():m_pos(), civilian:movement():m_pos()) then --turn to face the escort if they're not moving
										my_data._turning_to_intimidate = true
									end
								end
							end
						else
							if (not my_data._intimidate_t or my_data._intimidate_t + 2 < data.t) and not my_data._turning_to_intimidate then --can shout to intimidate and not already turning
								if not cannot_turn and CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, criminal:movement():m_pos(), civilian:movement():m_pos()) then --turn to face target
									my_data._turning_to_intimidate = true
								end
							end
						end
					end
				end

				if allow_domination and not civilian then
					if not criminal:brain()._last_intimidate_shout or 2 < data.t - criminal:brain()._last_intimidate_shout then
						TeamAILogicBase.intimidate_enemy(data, criminal, only_dom_assistance) --shout at valid enemies in sight or very close by

						if enemy then
							if (not my_data._intimidate_t or my_data._intimidate_t + 2 < data.t) and not my_data._turning_to_intimidate then --didn't shout at a civ/escort in the last 2 seconds and not already turning
								if not enemy:brain()._last_bot_intimidation_t or 1 < data.t - enemy:brain()._last_bot_intimidation_t then --enemy hasn't been intimidated by a bot in the last second (prevent insta-cuffing)
									if CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, criminal:movement():m_pos(), enemy:movement():m_pos()) then --turn to face target (not negated by shooting during a wave)
										my_data._turning_to_intimidate = true
									end
								end
							end
						end
					end
				end
			end

			if not civilian and (not allow_domination or not enemy) then --if no valid civilian or enemies (if domination is enabled) to intimidate are found
				TeamAILogicBase.mark_unit(data, criminal, false) --can actually mark enemies during bleedout and while cuffed, like players (not in casing mode, yet)

				if managers.groupai:state():whisper_mode() and mark_enemy then --turn to face units to mark during stealth
					if (not my_data._intimidate_t or my_data._intimidate_t + 2 < data.t) and not my_data._turning_to_intimidate then --can shout to intimidate and not already turning
						if CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, criminal:movement():m_pos(), mark_enemy:movement():m_pos()) then --turn to face the escort if they're not moving
							my_data._turning_to_intimidate = true
						end
					end
				end
			end

			if not in_casing_mode and not bleeding_out and not is_cuffed then
				if assault_wave_in_progress and (my_data.firing or my_data.shooting) and criminal:character_damage():health_ratio() < 1 and not criminal:sound():speaking() then --basically, if in actual combat
					managers.groupai:state():chk_say_teamAI_combat_chatter(criminal) --I actually modified the function called here to work properly, unlike in vanilla
				end
			end
		end
	elseif being_tased then
		if not criminal:brain()._shouted_t or 1.5 < data.t - criminal:brain()._shouted_t then --not in shouting cooldown
			TeamAILogicBase.mark_unit(data, criminal, true) --mark the attacking taser
		end
	end
end

function TeamAILogicBase._find_intimidateable_civilians(criminal, cannot_turn, validate_los, t)
	local head_pos = criminal:movement():m_head_pos()
	local look_vec = criminal:movement():m_rot():y()
	local my_tracker = criminal:movement():nav_tracker()
	local chk_vis_func = my_tracker.check_visibility

	local max_dis = 1200
	local max_e_dis = 500

	local close_dis = 400
	local close_e_dis = 200

	local intimidateable_civilians = {}
	local best_civ = nil
	local best_civ_wgt = false
	local highest_civ_wgt = 1
	local no_action = nil

	local found_ene_escort = nil

	for u_key, u_data in pairs(managers.enemy:all_enemies()) do --bots and enemies don't register escorts I think, so I have to do it this way
		if alive(u_data.unit) and chk_vis_func(my_tracker, u_data.unit:movement():nav_tracker()) and not u_data.unit:movement():cool() then --alive and has line of sight and alerted
			if u_data.unit:movement():team() and u_data.unit:movement():team().id == "criminal1" and not u_data.unit:anim_data().long_dis_interact_disabled and not u_data.unit:unit_data().disable_shout then --team + validation checks
				if not u_data.unit:anim_data().unintimidateable then --not doing an animation that prevents intimidation
					if tweak_data.character[u_data.unit:base()._tweak_table].is_escort then
						local last_i_t = u_data.unit:brain()._last_bot_e_intimidation_t

						if not u_data.unit:anim_data().move and (not last_i_t or 2 < t - last_i_t) or u_data.unit:anim_data().move and (not last_i_t or 4 < t - last_i_t) then --usual cooldown (2s) to make the escort move + flavour "GOGOGO" every 4s
							local u_head_pos = u_data.unit:movement():m_head_pos() + math.UP * 30
							local vec = u_head_pos - head_pos
							local dis = mvector3.normalize(vec)
							local angle = vec:angle(look_vec)
							local max_angle = math.max(8, math.lerp(90, 30, dis / max_e_dis))
							local verified = nil

							if validate_los then --as in, check if the bot is facing the escort
								verified = dis < close_e_dis or dis < max_e_dis and angle < max_angle --bot is close or is facing the target within allowed distance
							elseif cannot_turn then
								verified = dis < close_e_dis or dis < max_e_dis and angle < 60 --same as validate_los but with a fixed angle since the bot is shooting
							else
								verified = dis < max_e_dis --is within allowed distance (used to turn and face the escort, not to shout)
							end

							if dis < close_e_dis and angle > 30 then --bot is close but not facing the target
								no_action = true
							end

							if verified then
								local slotmask = managers.slot:get_mask("AI_visibility")
								local ray = World:raycast("ray", head_pos, u_head_pos, "slot_mask", slotmask, "ray_type", "ai_vision")

								if not ray then
									best_civ = u_data.unit
									found_ene_escort = true
								end
							end
						end
					end
				end
			end
		end
	end

	if not found_ene_escort then
		local found_civ_escort = nil

		for u_key, u_data in pairs(managers.enemy:all_civilians()) do --yes, apparently there are two types of escorts, why
			if alive(u_data.unit) and chk_vis_func(my_tracker, u_data.unit:movement():nav_tracker()) and not u_data.unit:movement():cool() then --alive and has line of sight and alerted
				if tweak_data.character[u_data.unit:base()._tweak_table].is_escort then
					if u_data.unit:in_slot(21) and not u_data.unit:anim_data().long_dis_interact_disabled and not u_data.unit:unit_data().disable_shout then --validation checks
						if not u_data.unit:anim_data().unintimidateable then --not doing an animation that prevents intimidation
							local last_i_t = u_data.unit:brain()._last_bot_e_intimidation_t

							if not u_data.unit:anim_data().move and (not last_i_t or 2 < t - last_i_t) or u_data.unit:anim_data().move and (not last_i_t or 4 < t - last_i_t) then --usual cooldown (2s) to make the escort move + flavour "GOGOGO" every 4s
								local u_head_pos = u_data.unit:movement():m_head_pos() + math.UP * 30
								local vec = u_head_pos - head_pos
								local dis = mvector3.normalize(vec)
								local angle = vec:angle(look_vec)
								local max_angle = math.max(8, math.lerp(90, 30, dis / max_e_dis))
								local verified = nil

								if validate_los then --as in, check if the bot is facing the escort
									verified = dis < close_e_dis or dis < max_e_dis and angle < max_angle --bot is close or is facing the target within allowed distance
								elseif cannot_turn then
									verified = dis < close_e_dis or dis < max_e_dis and angle < 60 --same as validate_los but with a fixed angle since the bot is shooting
								else
									verified = dis < max_e_dis --is within allowed distance (used to turn and face the escort, not to shout)
								end

								if dis < close_e_dis and angle > 30 then --bot is close but not facing the target
									no_action = true
								end

								if verified then
									local slotmask = managers.slot:get_mask("AI_visibility")
									local ray = World:raycast("ray", head_pos, u_head_pos, "slot_mask", slotmask, "ray_type", "ai_vision")

									if not ray then
										best_civ = u_data.unit
										found_civ_escort = true
									end
								end
							end
						end
					end
				else
					if not found_civ_escort then
						if tweak_data.character[u_data.unit:base()._tweak_table].intimidateable then --can be intimidated, determined through charactertweakdata
							if not u_data.unit:base().unintimidateable then
								if not u_data.unit:anim_data().unintimidateable then --not doing an animation that prevents intimidation
									if not u_data.unit:brain():is_tied() then --is not tied
										if not (u_data.unit:movement():stance_name() == "cbt" and u_data.unit:anim_data().stand) then --not standing up to be moved by a player (pretty sure)
											if not u_data.unit:anim_data().long_dis_interact_disabled and not u_data.unit:unit_data().disable_shout then --shout validation checks
												local civ_logic = u_data.unit:brain()._logic_data
												local civ_internal_data = civ_logic and civ_logic.internal_data
												local submission_meter = civ_internal_data and civ_internal_data.submission_meter --timer for the civ to get up when left unnattended
												local on_the_ground = u_data.unit:anim_data().drop

												if validate_los or (not on_the_ground or (on_the_ground and submission_meter and submission_meter < 10)) then --find any civs in sight, or find civs that are not on the ground or (are on the ground) with almost no intimidation left to turn and face them
													local u_head_pos = u_data.unit:movement():m_head_pos() + math.UP * 30
													local vec = u_head_pos - head_pos
													local dis = mvector3.normalize(vec)
													local angle = vec:angle(look_vec)
													local max_angle = math.max(8, math.lerp(90, 30, dis / max_dis))
													local verified = nil

													if validate_los then --as in, check if the bot is facing the civ
														verified = dis < close_dis or dis < max_dis and angle < max_angle --bot is close or is facing the target within allowed distance
													elseif cannot_turn then
														verified = dis < close_dis or dis < max_dis and angle < 60 --same as validate_los but with a fixed angle since the bot is shooting
													else
														verified = dis < max_dis --is within allowed distance (used to turn and face the civ, not to shout)
													end

													if dis < close_dis and angle > 30 then --bot is close but not facing the target
														no_action = true
													end

													if verified then
														local slotmask = managers.slot:get_mask("AI_visibility")
														local ray = World:raycast("ray", head_pos, u_head_pos, "slot_mask", slotmask, "ray_type", "ai_vision")

														if not ray then
															local inv_wgt = (not on_the_ground and 0.5 or 1) * dis * dis * (1 - vec:dot(look_vec))

															table.insert(intimidateable_civilians, {
																unit = u_data.unit,
																key = u_key,
																inv_wgt = inv_wgt
															})

															if not best_civ_wgt or inv_wgt < best_civ_wgt then
																best_civ_wgt = inv_wgt
																best_civ = u_data.unit
															end

															if highest_civ_wgt < inv_wgt then
																highest_civ_wgt = inv_wgt
															end
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end

	return best_civ, highest_civ_wgt, intimidateable_civilians, no_action
end

function TeamAILogicBase._find_intimidateable_ground_civilians(intimidateable_civilians)
	local intimidateable_downed_civilians = {}

	for u_key, u_data in pairs(intimidateable_civilians) do
		if u_data.unit:anim_data().drop then --is on the ground, duh
			local civ_logic = u_data.unit:brain()._logic_data
			local civ_internal_data = civ_logic and civ_logic.internal_data
			local submission_meter = civ_internal_data and civ_internal_data.submission_meter --timer for the civ to get up when left unnattended

			if submission_meter and submission_meter < 10 then --will get up in less than 10s if left unnattended
				table.insert(intimidateable_downed_civilians, {
					unit = u_data.unit,
					key = u_key
				})
			end
		end
	end

	return intimidateable_downed_civilians
end

function TeamAILogicBase._find_intimidateable_enemies(data, criminal, only_dom_assistance, validate_los)
	local head_pos = criminal:movement():m_head_pos()
	local look_vec = criminal:movement():m_rot():y()
	local my_tracker = criminal:movement():nav_tracker()
	local chk_vis_func = my_tracker.check_visibility

	local close_dis = 400
	local max_dis = 1200

	local best_enemy = nil
	local best_enemy_wgt = false
	local no_action = nil

	for att_key, att_data in pairs(data.detected_attention_objects) do
		if alive(att_data.unit) and (att_data.unit:character_damage() and att_data.unit:character_damage().dead and not att_data.unit:character_damage():dead()) and att_data.identified and att_data.verified and att_data.is_person and att_data.char_tweak then --validation and LoS checks
			if not att_data.unit:movement():cool() then --is alerted
				if criminal:movement():team().foes[att_data.unit:movement():team().id] then --belongs to an enemy team
					if not att_data.unit:base().unintimidateable then
						if not att_data.unit:anim_data().unintimidateable then --is not doing an animation that prevents intimidation
							if not att_data.char_tweak.priority_shout then --cannot be marked during loud
								if att_data.char_tweak.surrender then --has a surrender preset
									if not att_data.char_tweak.surrender.special and not att_data.char_tweak.surrender.never then --has a preset that actually allows surrendering
										if not att_data.unit:anim_data().hands_tied then --is not cuffed
											if not att_data.unit:unit_data().disable_shout then
												local hostage_limit_not_reached = managers.groupai:state():has_room_for_police_hostage()
												local lost_health = att_data.unit:character_damage():health_ratio() < 1
												local n, ammo_in_mag = data.unit:inventory():equipped_unit():base():ammo_info()

												local vulnerable = (lost_health and att_data.unit:anim_data().hurt) or att_data.unit:anim_data().reload or ammo_in_mag == 0
												local intimidated = att_data.unit:anim_data().surrender or att_data.unit:brain()._current_logic_name == "intimidated"
												local dropped_weapon = att_data.unit:anim_data().hands_back

												if dropped_weapon or intimidated or (not only_dom_assistance and hostage_limit_not_reached and vulnerable) then
													local u_head_pos = att_data.unit:movement():m_head_pos() + math.UP * 30
													local vec = u_head_pos - head_pos
													local dis = mvector3.normalize(vec)
													local angle = vec:angle(look_vec)
													local max_angle = math.max(8, math.lerp(90, 30, dis / max_dis))
													local verified = nil

													if validate_los then --as in, check if the bot is facing the enemy
														verified = dis < close_dis or dis < max_dis and angle < max_angle --bot is close or is facing the target within allowed distance
													else
														verified = dis < max_dis --is within allowed distance (used to turn and face the enemy, not to shout)
													end

													if dis < close_dis and angle > 30 then --bot is close but not facing the target
														no_action = true
													end

													if verified then
														local slotmask = managers.slot:get_mask("AI_visibility")
														local ray = World:raycast("ray", head_pos, u_head_pos, "slot_mask", slotmask, "ray_type", "ai_vision")

														if not ray then
															local inv_wgt = dropped_weapon and 0.1 or intimidated and 0.3 or vulnerable and 0.5 or 1

															if not best_enemy_wgt or inv_wgt < best_enemy_wgt then
																best_enemy_wgt = inv_wgt
																best_enemy = att_data.unit
															end
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end

	return best_enemy, no_action
end

function TeamAILogicBase._find_unit_to_mark(data, criminal, being_tased, validate_los)
	local head_pos = criminal:movement():m_head_pos()
	local look_vec = criminal:movement():m_rot():y()
	local my_tracker = criminal:movement():nav_tracker()
	local chk_vis_func = my_tracker.check_visibility
	local is_whisper_mode = managers.groupai:state():whisper_mode()

	local close_dis = 400
	local best_unit = nil
	local contour_type = nil
	local shout_id = nil
	local no_action = nil

	local crew_marking_upgrade = nil --placeholder for high value target bot skill
	local ace_upgrade = nil --placeholder for ace the version, alternatively, just use one if you're keeping this like vanilla where you only pick bot skills without being able to upgrade them
	local time_multiplier = 1

	if crew_marking_upgrade and ace_upgrade then
		time_multiplier = 2 --ace contour time extension
	end

	if being_tased then
		for att_key, att_data in pairs(data.detected_attention_objects) do
			if alive(att_data.unit) and (att_data.unit:character_damage() and att_data.unit:character_damage().dead and not att_data.unit:character_damage():dead()) and att_data.identified and att_data.is_person and att_data.char_tweak and att_data.unit:base():has_tag("taser") then --validation checks
				if att_data.unit:brain()._logic_data then --crash prevention
					local internal_taser_data = att_data.unit:brain()._logic_data.internal_data

					if internal_taser_data then
						local tasing = internal_taser_data.tasing

						if tasing then
							local tasing_target = tasing and tasing.target_u_data.unit == criminal and tasing.target_u_data.unit:movement():tased()

							if tasing_target then
								local final_contour = "mark_enemy" --standard contour with no damage bonus

								if crew_marking_upgrade then
									if ace_upgrade then
										final_contour = "mark_enemy_damage_bonus_distance" --ace damage bonus contour
									else
										final_contour = "mark_enemy_damage_bonus" --basic damage bonus contour
									end
								end

								local att_head_pos = att_data.unit:movement():m_head_pos() + math.UP * 30
								local slotmask = managers.slot:get_mask("AI_visibility")
								local ray = World:raycast("ray", head_pos, att_head_pos, "slot_mask", slotmask, "ray_type", "ai_vision")

								if not ray then
									best_unit = att_data.unit
									contour_type = final_contour
									shout_id = "s07x_sin" --tase grunt that a few characters have (the original PD2 ones IIRC)
								end
							end
						end
					end
				end
			end
		end
	else
		local found_turret = nil
		local turret_units = managers.groupai:state():turrets()

		if not is_whisper_mode then --pointless during stealth
			if turret_units then --crash prevention
				for u_key, turret_unit in pairs(turret_units) do
					if alive(turret_unit) and criminal:movement():team().foes[turret_unit:movement():team().id] then --alive and belongs to an enemy team
						if chk_vis_func(my_tracker, turret_unit:movement():nav_tracker()) then --has line of sight
							local turret_firing_range = tweak_data.weapon[turret_unit:base():get_name_id()].FIRE_RANGE
							local turret_detection_range = tweak_data.weapon[turret_unit:base():get_name_id()].DETECTION_RANGE
							local actual_fucking_range = 30000 --the usual default range for common turrets, just in case

							if turret_firing_range <= turret_detection_range then --checking the actual range, as the lowest value of the two is the maximum distance the turret is allowed to shoot at (forgive my stupidity if there's an easier way to check which value is lower)
								actual_fucking_range = turret_firing_range
							elseif turret_detection_range <= turret_firing_range then
								actual_fucking_range = turret_detection_range
							end

							local u_head_pos = turret_unit:movement():m_head_pos() + math.UP * 30
							local vec = u_head_pos - head_pos
							local dis = mvector3.normalize(vec)
							local angle = vec:angle(look_vec)
							local max_dis = actual_fucking_range
							local max_angle = math.max(8, math.lerp(90, 30, dis / max_dis))

							if dis < close_dis or dis < max_dis and angle < max_angle then --bot is close or is facing the target within allowed distance
								local contour = turret_unit:contour()
								local final_contour = "mark_unit_dangerous" --standard contour with no damage bonus
								local valid_contour_check = not contour._contour_list or (not contour:has_id(final_contour) and not contour:has_id("mark_unit_dangerous_damage_bonus") and not contour:has_id("mark_unit_dangerous_damage_bonus_distance"))

								if crew_marking_upgrade then
									if ace_upgrade then
										final_contour = "mark_unit_dangerous_damage_bonus_distance" --ace damage bonus contour (the distance bonus damage isn't applied in vanilla because OVK forgot to add it to SentryGunDamage)
										valid_contour_check = not contour._contour_list or not contour:has_id(final_contour)
									else
										final_contour = "mark_unit_dangerous_damage_bonus" --basic damage bonus contour
										valid_contour_check = not contour._contour_list or (not contour:has_id(final_contour) and not contour:has_id("mark_unit_dangerous_damage_bonus_distance"))
									end
								end

								if dis < close_dis and angle > 30 then --bot is close but not facing the target
									no_action = true
								end

								if valid_contour_check then --not already marked, or is marked with a "lower tier" contour
									local slotmask = managers.slot:get_mask("AI_visibility")
									local ray = World:raycast("ray", head_pos, u_head_pos, "slot_mask", slotmask, "ray_type", "ai_vision")

									if not ray then
										best_unit = turret_unit
										contour_type = final_contour
										found_turret = true
										shout_id = "f44x_any"
									end
								end
							end
						end
					end
				end
			end
		end

		if not found_turret then
			local found_camera = nil

			if is_whisper_mode and not managers.groupai:state():is_ecm_jammer_active("camera") then --pointless outside of stealth and if an ECM jammer is active (the latter, for bots at least)
				for _, cam_unit in ipairs(SecurityCamera.cameras) do
					if alive(cam_unit) and cam_unit:enabled() and not cam_unit:base():destroyed() and not cam_unit:base().is_friendly then --we obviously don't want to mark disabled, destroyed or "friendly" cameras
						if cam_unit:interaction() and cam_unit:interaction():active() and not cam_unit:interaction():disabled() then --can be interacted with (aka relevant at all or not)
							local cam_pos = cam_unit:base():get_mark_check_position() + math.UP * 30 --cameras use a different pos check
							local vec = cam_pos - head_pos
							local dis = mvector3.normalize(vec)
							local angle = vec:angle(look_vec)
							local max_dis = 3000
							local max_angle = math.max(8, math.lerp(90, 30, dis / max_dis))
							local verified = nil

							if validate_los then --as in, check if the bot is facing the camera
								verified = dis < close_dis or dis < max_dis and angle < max_angle --bot is close or is facing the camera within allowed distance
							else
								verified = dis < max_dis --is within allowed distance (used to turn and face the camera, not to mark it)
							end

							if verified then --bot is close or is facing the target within allowed distance
								if dis < close_dis and angle > 30 then --bot is close but not facing the target
									no_action = true
								end

								local contour = cam_unit:contour()

								if not contour._contour_list or not contour:has_id("mark_unit") then --not already marked
									local slotmask = managers.slot:get_mask("AI_visibility")
									local ray = World:raycast("ray", head_pos, cam_pos, "slot_mask", slotmask, "ray_type", "ai_vision")

									if not ray then
										best_unit = cam_unit
										contour_type = "mark_unit" --the standard camera contour
										found_camera = true
										shout_id = "f39_any"
									end
								end
							end
						end
					end
				end
			end
			
			if not found_camera then
				for att_key, att_data in pairs(data.detected_attention_objects) do
					if alive(att_data.unit) and (att_data.unit:character_damage() and att_data.unit:character_damage().dead and not att_data.unit:character_damage():dead()) and att_data.identified and att_data.verified and att_data.is_person and att_data.char_tweak then --validation and LoS checks
						if criminal:movement():team().foes[att_data.unit:movement():team().id] then --belongs to an enemy team
							local whisper_shout = is_whisper_mode and att_data.unit:movement():cool() and att_data.char_tweak.silent_priority_shout --is stealth, unit is not alerted and they can be shouted at during stealth
							local shout = att_data.char_tweak.priority_shout --can be shouted at during loud

							if whisper_shout or shout then
								local u_head_pos = att_data.unit:movement():m_head_pos() + math.UP * 30
								local vec = u_head_pos - head_pos
								local dis = mvector3.normalize(vec)
								local angle = vec:angle(look_vec)
								local max_dis = att_data.unit:base():has_tag("sniper") and 20000 or 3000 --allowing Snipers to be marked from very far away in comparison to other specials
								local max_angle = math.max(8, math.lerp(90, 30, dis / max_dis))
								local verified = nil

								if validate_los then --as in, check if the bot is facing the enemy
									verified = dis < close_dis or dis < max_dis and angle < max_angle --bot is close or is facing the enemy within allowed distance
								else
									verified = dis < max_dis --is within allowed distance (used to turn and face the enemy, not to mark them)
								end

								if verified then --bot is close or is facing the target within allowed distance
									local contour = att_data.unit:contour()
									local final_contour = "mark_enemy" --standard contour with no damage bonus
									local valid_contour_check = not contour._contour_list or (not contour:has_id(final_contour) and not contour:has_id("mark_enemy_damage_bonus") and not contour:has_id("mark_enemy_damage_bonus_distance"))

									if crew_marking_upgrade then
										if ace_upgrade then
											final_contour = "mark_enemy_damage_bonus_distance" --ace damage bonus contour
											valid_contour_check = not contour._contour_list or not contour:has_id(final_contour)
										else
											final_contour = "mark_enemy_damage_bonus" --basic damage bonus contour
											valid_contour_check = not contour._contour_list or (not contour:has_id(final_contour) and not contour:has_id("mark_enemy_damage_bonus_distance"))
										end
									end

									if dis < close_dis and angle > 30 then --bot is close but not facing the target
										no_action = true
									end

									if valid_contour_check then --not already marked, or is marked with a "lower tier" contour
										local slotmask = managers.slot:get_mask("AI_visibility")
										local ray = World:raycast("ray", head_pos, u_head_pos, "slot_mask", slotmask, "ray_type", "ai_vision")

										if not ray then
											best_unit = att_data.unit
											contour_type = final_contour
											shout_id = whisper_shout and whisper_shout .. "_any" or shout .. "x_any"
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end

	return best_unit, contour_type, shout_id, time_multiplier, no_action
end

function TeamAILogicBase.intimidate_civilians(data, criminal)
	local best_civ, highest_civ_wgt, intimidateable_civilians, no_action = TeamAILogicBase._find_intimidateable_civilians(criminal, false, true, data.t)
	local plural = false
	local intimidate_escort = best_civ and tweak_data.character[best_civ:base()._tweak_table].is_escort

	if not intimidate_escort then
		if #intimidateable_civilians > 1 then
			plural = true
		elseif #intimidateable_civilians <= 0 then
			return false
		end
	end

	local act_name, sound_name = nil
	local sound_suffix = plural and "plu" or "sin"

	if intimidate_escort then
		act_name = "cmd_point"
		sound_name = "f40_any" --not using "get up" lines since they're mostly unfitting inspire ones (the "gogo" inspire ones are not so bad in comparison), or they're played at wrong times
	else
		if best_civ:anim_data().move then --civ is moving
			act_name = "cmd_stop"

			local stop_civ_t = best_civ:brain()._stopped_civ_t
			local c_stop_civ_t = criminal:brain()._stopped_civ_t

			if not plural and (stop_civ_t and data.t < stop_civ_t + 3) and (c_stop_civ_t and data.t < c_stop_civ_t + 3) then --singular civ was told by the same bot to get down in the last 3 seconds
				sound_name = "f02b_sin" --I SAID GET DOWN
			else
				sound_name = "f02x_" .. sound_suffix --get down people/on the ground

				best_civ:brain()._stopped_civ_t = data.t
				criminal:brain()._stopped_civ_t = data.t
			end
		elseif best_civ:anim_data().drop then --civ is on the ground
			act_name = "cmd_down"

			local down_civ_t = criminal:brain()._shouted_down_civ_t

			if (down_civ_t and data.t < down_civ_t + 3) then --a specific bot told a civ (or more than one) to get down in the last 3 seconds
				sound_name = "f03b_any" --and stay put
			else
				local intimidateable_downed_civilians = TeamAILogicBase._find_intimidateable_ground_civilians(intimidateable_civilians)

				if #intimidateable_downed_civilians >= 1 then
					sound_name = "f03a_" .. sound_suffix --stay down/nobody moves
				else
					return false
				end
			end
		else
			act_name = "cmd_down"

			local stop_civ_t = best_civ:brain()._stopped_civ_t
			local c_stop_civ_t = criminal:brain()._stopped_civ_t

			if not plural and (stop_civ_t and data.t < stop_civ_t + 3) and (c_stop_civ_t and data.t < c_stop_civ_t + 3) then --singular civ was told by the same bot to get down in the last 3 seconds
				sound_name = "f02b_sin" --I SAID GET DOWN
			else
				sound_name = "f02x_" .. sound_suffix --get down people/on the ground
			end

			best_civ:brain()._stopped_civ_t = data.t
			criminal:brain()._stopped_civ_t = data.t
			criminal:brain()._shouted_down_civ_t = data.t
		end
	end

	if sound_name and not criminal:sound():speaking() then
		criminal:sound():say(sound_name, true)
	end

	if not no_action and not data.internal_data.firing and not data.internal_data.shooting and not criminal:anim_data().reload then --not doing an animation if shooting or reloading or the target is not in front of the bot
		local new_action = {
			align_sync = true,
			body_part = 3,
			type = "act",
			variant = act_name
		}

		if criminal:brain():action_request(new_action) then
			data.internal_data.gesture_arrest = true
		end
	end

	if intimidate_escort then
		best_civ:brain():on_intimidated(1, criminal) --intimidate the target
		best_civ:brain()._last_bot_e_intimidation_t = data.t
	else
		for _, civ in ipairs(intimidateable_civilians) do
			local amount = civ.inv_wgt / highest_civ_wgt --intimidation power (meh, considering how this works in general, for players, bots, and anything)

			if best_civ == civ.unit then
				amount = 1
			end

			civ.unit:brain():on_intimidated(amount, criminal) --intimidate the target/s
		end
	end

	criminal:brain()._shouted_t = data.t
	data.internal_data._intimidate_t = data.t

	return best_civ
end

function TeamAILogicBase.intimidate_enemy(data, criminal, only_dom_assistance)
	local best_enemy, no_action = TeamAILogicBase._find_intimidateable_enemies(data, criminal, only_dom_assistance, true)

	if not best_enemy then --enemy can't be shouted at or there's no enemy
		return false
	end

	local act_name, sound_name = nil

	if not criminal:sound():speaking() then
		if not best_enemy:brain()._last_bot_intimidation_t or 1 < data.t - best_enemy:brain()._last_bot_intimidation_t then --cooldown per enemy to avoid insta-cuffing
			if best_enemy:anim_data().hands_back then --dropped weapon
				act_name = "cmd_down"
				sound_name = "l03x_sin" --put your cuffs on
			elseif best_enemy:anim_data().surrender then --has hands in the air
				act_name = "cmd_down"
				sound_name = "l02x_sin" --on your knees
			else
				act_name = "cmd_stop"
				sound_name = "l01x_sin" --put your hands up/drop your weapon
			end
		else
			return false
		end
	else
		return false
	end

	if sound_name then
		criminal:sound():say(sound_name, true)
	end

	if not no_action and not data.internal_data.firing and not data.internal_data.shooting and not criminal:anim_data().reload then --not doing an animation if shooting or reloading or the target is not in front of the bot
		local new_action = {
			align_sync = true,
			body_part = 3,
			type = "act",
			variant = act_name
		}

		if criminal:brain():action_request(new_action) then
			data.internal_data.gesture_arrest = true
		end
	end

	criminal:brain()._shouted_t = data.t
	criminal:brain()._last_intimidate_shout = data.t

	best_enemy:brain():on_intimidated(1, criminal) --intimidate the target (needs some editing to avoid crashing)
	best_enemy:brain()._last_bot_intimidation_t = data.t

	return best_enemy
end

function TeamAILogicBase.mark_unit(data, criminal, being_tased)
	local best_unit, contour_type, shout_id, time_multiplier, no_action = TeamAILogicBase._find_unit_to_mark(data, criminal, being_tased, true)

	if not best_unit or not contour_type then --no enemy to mark or no contour to use
		return false
	end

	local use_sound = nil

	if not criminal:sound():speaking() then
		if being_tased then --for continuous grunting
			use_sound = true
		else
			local c_last_m_s = criminal:brain()._last_mark_shout
			local marking_sound_cooldown = managers.groupai:state():whisper_mode() and 5 or tweak_data.sound.criminal_sound.ai_callout_cooldown --vanilla default is 15s, set in soundtweakdata

			if not c_last_m_s or marking_sound_cooldown < data.t - c_last_m_s then --isn't on sound cooldown
				use_sound = true
			end
		end
	end

	if use_sound and shout_id then
		criminal:sound():say(shout_id, true)
	end

	criminal:brain()._last_mark_shout = data.t
	criminal:brain()._shouted_t = data.t

	--not doing an animation if being tased or while in casing mode/bleeding out/cuffed/shooting/reloading or the target is not in front of the bot
	if not no_action and not being_tased and not criminal:movement():cool() and not criminal:character_damage():bleed_out() and not criminal:character_damage():arrested() and not data.internal_data.firing and not data.internal_data.shooting and not criminal:anim_data().reload then
		local new_action = {
			variant = "cmd_point",
			align_sync = true,
			body_part = 3,
			type = "act"
		}

		if criminal:brain():action_request(new_action) then
			data.internal_data.gesture_arrest = true
		end
	end

	best_unit:contour():add(contour_type, true, time_multiplier)

	--broken for now because PD2
	--[[local is_shockproof = true --placeholder for bot shockproof skill

	if being_tased and is_shockproof then
		local action_data = {
			damage = 0,
			variant = "counter_tased",
			damage_effect = best_unit:character_damage()._HEALTH_INIT * 2,
			attacker_unit = criminal,
			attack_dir = -best_unit:movement()._action_common_data.fwd,
			col_ray = {
				position = mvector3.copy(best_unit:movement():m_head_pos()),
				body = best_unit:body("body")
			}
		}

		best_unit:character_damage():damage_melee(action_data) --because of course they would code it as damage_melee instead of, you know, damage_tase (could adapt, but this is broken anyways for no reason)
		best_unit:sound():play("tase_counter_attack") --BZZZZZZZZZZZZZZT
	end--]]

	return best_unit
end
