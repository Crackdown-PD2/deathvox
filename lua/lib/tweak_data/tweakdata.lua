
tweak_data.projectiles.dv_grenadier_grenade = {
	damage = 0,
	launch_speed = 1250,
	curve_pow = 0,
	player_damage = 0,
	range = 350,
	init_timer = 2.5,
	mass_look_up_modifier = 1,
	sound_event = "gl_explode",
	name_id = "bm_launcher_frag",
	adjust_z = 0,
	push_at_body_index = 0
}

if deathvox:IsTotalCrackdownEnabled() then 
	
	tweak_data.TCD_WEAPON_BUCKSHOT_AMMO_DAMAGE_MUL = 0.5
	
	tweak_data.weapon_disable_crit_for_damage = {
		frag = nil --frag grenades are allowed to crit
	}

	tweak_data.projectiles.wpn_prj_four.damage = 1

	--shuriken
	tweak_data.projectiles.wpn_prj_ace.damage = 20

	--throwing knife
	tweak_data.projectiles.wpn_prj_target.damage = 80
	tweak_data.projectiles.wpn_prj_target.launch_speed = 1500

	--throwing axe
	tweak_data.projectiles.wpn_prj_hur.damage = 140
	tweak_data.projectiles.wpn_prj_hur.launch_speed = 1500
	--armor piercing not implemented

	--javelin
	tweak_data.projectiles.wpn_prj_jav.damage = 400
	--armor piercing not implemented

	--frag grenade
	
	tweak_data.projectiles.frag._cant_be_shot_to_detonate = true
	tweak_data.projectiles.frag.slot_mask_id = "bullet_impact_targets"
	tweak_data.projectiles.frag.damage = 300
	tweak_data.projectiles.frag.player_damage = 10
	tweak_data.projectiles.frag.range = 1000
	--tweak_data.projectiles.frag.launch_speed = 1500 --does this work for grenades? UPDATE: IT DOES
	tweak_data.projectiles.frag.critical_chance = 0.4
	tweak_data.projectiles.frag._curve_pow = 0

	--hef grenade
	tweak_data.projectiles.frag_com._cant_be_shot_to_detonate = true
	tweak_data.projectiles.frag_com.slot_mask_id = "bullet_impact_targets"
	tweak_data.projectiles.frag_com.damage = 100
	tweak_data.projectiles.frag_com.player_damage = 10
	tweak_data.projectiles.frag_com.range = 500
	tweak_data.projectiles.frag_com._curve_pow = 0
	--tweak_data.projectiles.frag_com.launch_speed = 1500
	--no falloff not implemented

	--dynamite
	tweak_data.projectiles.dynamite.slot_mask_id = "bullet_impact_targets"
	tweak_data.projectiles.dynamite.damage = 500
	tweak_data.projectiles.dynamite.player_damage = 10
	tweak_data.projectiles.dynamite.range = 1000
	tweak_data.projectiles.dynamite._curve_pow = 0
	--tweak_data.projectiles.dynamite.launch_speed = 1500
	--no falloff not implemented

	--matroyshka grenade
	tweak_data.projectiles.dada_com._cant_be_shot_to_detonate = true
	tweak_data.projectiles.dada_com.slot_mask_id = "bullet_impact_targets"
	tweak_data.projectiles.dada_com.damage = 40
	tweak_data.projectiles.dada_com.player_damage = 10
	tweak_data.projectiles.dada_com.range = 200
	tweak_data.projectiles.dada_com.child_clusters = 7
	--tweak_data.projectiles.dada_com.launch_speed = 1500
	--cluster splitting not yet implemented

	--concussion
	tweak_data.projectiles.concussion._cant_be_shot_to_detonate = true
	tweak_data.projectiles.concussion.slot_mask_id = "bullet_impact_targets"
	tweak_data.projectiles.concussion.damage = 0
	tweak_data.projectiles.concussion.player_damage = 0
	tweak_data.projectiles.concussion.range = 800
	--tweak_data.projectiles.concussion.launch_speed = 1500
	--4s stun, -50% Accuracy penalty for 5s after stun not implemented

	--molotov
	tweak_data.projectiles.molotov.damage = 0
	tweak_data.projectiles.molotov.player_damage = 5
	tweak_data.projectiles.molotov.range = 250
	--tweak_data.projectiles.molotov.launch_speed = 1500
	tweak_data.projectiles.molotov.fire_dot_data = {
		dot_trigger_chance = 35,
		dot_damage = 25,
		dot_length = 15,
		dot_trigger_max_distance = 3000,
		dot_tick_period = 0.5
	}
	tweak_data.projectiles.molotov.burn_duration = 10
	--all of this needs to be checked

	--incendiary grenade
	tweak_data.projectiles.fir_com._cant_be_shot_to_detonate = true
	tweak_data.projectiles.fir_com.slot_mask_id = "bullet_impact_targets"
	tweak_data.projectiles.fir_com.damage = 0
	tweak_data.projectiles.fir_com.player_damage = 5
	tweak_data.projectiles.fir_com.range = 112.5
	--tweak_data.projectiles.fir_com.launch_speed = 1500
	tweak_data.projectiles.fir_com.fire_dot_data = {
		dot_trigger_chance = 35,
		dot_damage = 25,
		dot_length = 30,
		dot_trigger_max_distance = 3000,
		dot_tick_period = 0.5
	}
	tweak_data.projectiles.fir_com.burn_duration = 10
	--central flame only (no subflame pools) not implemented
	--all of this needs to be checked
	
	tweak_data.contour.character.civilian_mark_special_color = Vector3(206/255,48/255,0/255)
	tweak_data.contour.character.civilian_mark_standard_color = Vector3(134/255,31/255,0/255)
end