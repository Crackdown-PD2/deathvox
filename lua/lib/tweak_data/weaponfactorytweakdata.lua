local old_init = WeaponFactoryTweakData.init
function WeaponFactoryTweakData:init(...)
	old_init(self, ...)
    
	self.wpn_deathvox_grenadier = deep_clone(self.wpn_fps_gre_m32_npc)
	self.wpn_deathvox_grenadier.default_blueprint = {
		"wpn_fps_gre_m32_barrel",
		"wpn_fps_gre_m32_bolt",
		"wpn_fps_gre_m32_lower_reciever",
		"wpn_fps_gre_m32_mag",
		"wpn_fps_gre_m32_upper_reciever",
		"wpn_fps_upg_m4_s_standard_vanilla"
	}
	self.wpn_deathvox_grenadier.unit = "units/pd2_mod_gageammo/pew_pew_lasers/wpn_deathvox_grenadier"

end

-- Begin Total Crackdown Weapon Attachment materials
Hooks:PostHook( WeaponFactoryTweakData, "init", "totalcd_weaps", function(self)
	--BEGIN THE NEW INSANITY! (OR SOMETHING LIKE THAT!)
	if deathvox:IsTotalCrackdownEnabled() then

		local enabled = true
		if enabled then
			CSVStatReader:read_files("attachment",self)
			--any manual adjustments should be written after read_files() 
		end
		
--Mod stats info:
--      damage - Damage increased/decreased by attachment. (Note. If weapon use stats_modifiers for damage this value will be multiplied by it)
--      spread - Accuracy increased/decreased by attachment. 1/ -1 value = 4 / -4 accuracy in-game.
--      recoil - Stability increased/decreased by attachment. 1/ -1 value = 4 / -4 accuracy in-game.
--      concealment - Concealment increased/decreased by attachment.
--      extra_ammo - Adds additional rounds added to weapon magazine. 1 value = 2 rounds in-game.
--      total_ammo_mod - Increased/decreased weapon ammo pool. Values varies depending on total ammo pool.
--      reload - Increased/decreased weapon reload timers. 1 / -1 value = 10% / -10% reload time.
--      value - from table. Inconsistently reported/documented. Copy from decompile.

--Weapon stats:
--      damage - Base damage of weapon. Max value should be no more than 180 (Damage can be increased further by using "stats_modifiers")
--      spread - Base accuracy of weapon. 1 value = 4 accuracy - Game calculate it using: Value*4-4 = accuracy in-game. Example - 17 value = 17*4-4=64 accuracy.
--      spread_moving - NOT USED BY GAME (But just in case use same value as for "spread")
--      recoil - Base stability of weapon 1 value = 4 stability - Game calculate it using: Value*4-4 = stability in-game. Example - 16 value = 16*4-4=60 stability.
--      zoom - Base zoom value used when aiming down sights.
--      concealment - Base concealment of weapon.
--      suppression - Base suppression value.
	--Threat value = suppression * 2
--      value - from table. Inconsistently reported/documented. Copy from decompile.





	--------------------------------------
				--CAR-4 (DMR Kit)--
	--------------------------------------
	--Note: Conversion kit entries are not actual weapons and are only listed for referential purposes.
	--INCOMPLETE - see active mod description under CAR-4 instead.
		
		self.parts.car_dmr_kit_ammo_type = { --Dummy ammo type for DMR kit, needed for armor piercing and pickup multipliers to work properly.
			a_obj = "a_m",
			type = "ammo",
			unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
			stats = {
				value = 1
			},
			custom_stats = {
				armor_piercing_add = 1,
				ammo_pickup_max_mul = 4,
				ammo_pickup_min_mul = 2.5
			}
		}
		self.parts.car_dmr_kit_ammo_type.supported = true

		self.wpn_fps_sho_aa12.override = {
			wpn_fps_upg_a_slug = {
				stats = {
					value = 5, 
					spread = 5, 
					damage = 30
				},
				custom_stats = {				
					damage_near_mul = 999999999,
					damage_far_mul = 999999999, 
					rays = 1,				
					armor_piercing_add = 1,
					can_shoot_through_enemy = false,
					can_shoot_through_shield = true,
					can_shoot_through_wall = true,
					}
				},
			wpn_fps_upg_a_custom = {
				stats = {
					value = 3, 
					spread = -5
					}
				},
			wpn_fps_upg_a_custom_free = {
				stats = {
					value = 3
				},
				custom_stats = {				
					rays = 6		
				}			
			},						
			wpn_fps_upg_a_explosive = {
				stats = {
					value = 5, 
					spread = 5
				},
				custom_stats = {
					ignore_statistic = true,
					damage_far_mul = 999999999,	--as shit as this is this should theoretically work
					damage_near_mul = 999999999,
					ammo_pickup_max_mul = 4,
					ammo_pickup_min_mul = 2.5,				
					bullet_class = "InstantExplosiveBulletBase",
					rays = 1
				}
			}
		}
		
		--Nagant Bayonet [wpn_fps_snp_mosin_ns_bayonet] [Replaces Weapon Butt melee weapon with Nagant Bayonet melee weapon] Value: 1
		self.parts.wpn_fps_snp_mosin_ns_bayonet.supported = true
		self.parts.wpn_fps_snp_mosin_ns_bayonet.stats = {
			knockback_tier = 3,
			range = 250,
			min_damage = 50,
			min_damage_effect = 1,
			concealment = 0, --weapon butt's 30 + this 0
			max_damage_effect = 1,
			value = 1,
			max_damage = 80
		}

		self.parts.wpn_fps_bow_ecp_m_arrows_poison.subclass_modifiers = { --airbow
			"subclass_poison"
		}
		self.parts.wpn_fps_bow_frankish_m_poison.subclass_modifiers = { --light crossbow
			"subclass_poison"
		}
		self.parts.wpn_fps_upg_a_bow_poison.subclass_modifiers = {
			"subclass_poison"
		}
		self.parts.wpn_fps_bow_elastic_m_poison.subclass_modifiers = { --deca technologies compound bow
			"subclass_poison"
		}
		self.parts.wpn_fps_bow_long_m_poison.subclass_modifiers = { --english longbow
			"subclass_poison"
		}
		self.parts.wpn_fps_bow_arblast_m_poison.subclass_modifiers = { --arbiter
			"subclass_poison"
		}
		self.parts.wpn_fps_upg_a_grenade_launcher_incendiary.subclass_modifiers = { --gl40
			"subclass_areadenial"
		}
		self.parts.wpn_fps_upg_a_crossbow_poison.subclass_modifiers = {
			"subclass_poison"
		}
		self.parts.wpn_fps_upg_a_grenade_launcher_incendiary_arbiter.subclass_modifiers = {
			"subclass_areadenial"
		}
		--------------------------------------
		--Shared Attachments--
		--------------------------------------
		
		--auto and singlefire mods
		self.parts.wpn_fps_upg_i_singlefire.stats = {value = 5}
		self.parts.wpn_fps_upg_i_singlefire.supported = true
		
		self.parts.wpn_fps_upg_i_autofire.stats = {value = 8}
		self.parts.wpn_fps_upg_i_autofire.supported = true
		
		
		
		
	--Shotgun ammo type stat changes begin here.
		-- flechette rounds
		self.parts.wpn_fps_upg_a_piercing.stats = {value = 5, spread = 5}	
		self.parts.wpn_fps_upg_a_piercing.custom_stats = {
				damage_near_mul = 1.2 --not sure about these. might need to modify shotgunbase
		}
		self.parts.wpn_fps_upg_a_piercing.supported = true
		-- dragon's breath rounds (muzzleflash and actual hitbox/cone stuff ain't done)
		self.parts.wpn_fps_upg_a_dragons_breath.stats = {value = 5}			
		self.parts.wpn_fps_upg_a_dragons_breath.custom_stats = {
			ignore_statistic = true,
			muzzleflash = "effects/payday2/particles/weapons/shotgun/sho_muzzleflash_dragons_breath",
			can_shoot_through_shield = true,
			can_shoot_through_enemy = true,
			armor_piercing_add = 1,			
			damage_far_mul = 0.1333333333333333,
			damage_near_mul = 0.2,
			bullet_class = "FlameBulletBase",
			rays = 12,
			fire_dot_data = {
				dot_trigger_chance = "100",
				dot_damage = "10",
				dot_length = "3.1",
				dot_trigger_max_distance = "400",
				dot_tick_period = "0.5"
			}
		}
		self.parts.wpn_fps_upg_a_dragons_breath.supported = true
		-- he slugs
		self.parts.wpn_fps_upg_a_explosive.stats = {value = 5, spread = 5}			
		self.parts.wpn_fps_upg_a_explosive.custom_stats = {
				ignore_statistic = true,
				damage_far_mul = 999999999,	--as shit as this is this should theoretically work
				damage_near_mul = 999999999,
				bullet_class = "InstantExplosiveBulletBase",
				rays = 1
		}
		self.parts.wpn_fps_upg_a_explosive.supported = true
		-- ap slugs
		self.parts.wpn_fps_upg_a_slug.stats = {value = 5, spread = 5, damage = 30}	
		self.parts.wpn_fps_upg_a_slug.custom_stats = {
				damage_near_mul = 999999999,
				damage_far_mul = 999999999, 
				rays = 1,				
				armor_piercing_add = 1,
				can_shoot_through_enemy = false,
				can_shoot_through_shield = true,
				can_shoot_through_wall = true,
		}
		self.parts.wpn_fps_upg_a_slug.supported = true
		-- 000 buck
		self.parts.wpn_fps_upg_a_custom.stats = {value = 3, spread = -5}	
		self.parts.wpn_fps_upg_a_custom.supported = true
		-- community 000 buck
		self.parts.wpn_fps_upg_a_custom_free.stats = {value = 3}	
		self.parts.wpn_fps_upg_a_custom_free.custom_stats = {rays = 6}	
		self.parts.wpn_fps_upg_a_custom_free.name_id = "bm_wp_upg_a_custom_free"	
		self.parts.wpn_fps_upg_a_custom_free.desc_id = "bm_wp_upg_a_custom_free_desc"	
		self.parts.wpn_fps_upg_a_custom_free.supported = true
		
	end
end)

--Removes all weapon mod stats from weapon mods without the .supported flag.
--Has patchy support for custom weapons, but generally works on all vanilla stuff to my knowledge.
Hooks:PostHook( WeaponFactoryTweakData, "create_bonuses", "strip_mod_stats", function(self)
	if deathvox:IsTotalCrackdownEnabled() then
		for _, part in pairs(self.parts) do
			if not part.supported and part.stats then
				local suppression
				local alert_size
				if (part.sub_type == "silencer") or (part.perks and table.contains(part.perks,"silencer")) then 
					if part.subclass_modifiers then 
						table.insert(part.subclass_modifiers,"subclass_quiet")
					else
						part.subclass_modifiers = {"subclass_quiet"}
					end
					suppression = 11
					alert_size = part.stats.alert_size or 12
				end
				
				--Preserve cosmetic part stats.
				part.stats = {
					suppression = suppression,
					value = part.stats.value,
					zoom = part.stats.zoom,
					gadget_zoom = part.stats.gadget_zoom,
					alert_size = alert_size
				}
				part.custom_stats = nil
			end
		end
	end
end)