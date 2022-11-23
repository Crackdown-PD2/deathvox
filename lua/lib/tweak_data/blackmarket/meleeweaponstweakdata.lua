if deathvox:IsTotalCrackdownEnabled() then 
	Hooks:PostHook(BlackMarketTweakData,"_init_melee_weapons","deathvox_init_melee_weapons_tweak_data",function(self,tweak_data)
				--Krieger Blade--
		self.melee_weapons.kampfmesser.subclasses = {
		}
		self.melee_weapons.kampfmesser.primary_class = "class_melee"
		self.melee_weapons.kampfmesser.stats.charge_time = 2
		self.melee_weapons.kampfmesser.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.kampfmesser.stats.concealment = 30
		self.melee_weapons.kampfmesser.stats.knockback_tier = 2
		self.melee_weapons.kampfmesser.stats.max_damage = 50
		self.melee_weapons.kampfmesser.stats.range = 185
		self.melee_weapons.kampfmesser.stats.min_damage = 30


				--Diving Knife--
		self.melee_weapons.pugio.subclasses = {
		}
		self.melee_weapons.pugio.primary_class = "class_melee"
		self.melee_weapons.pugio.stats.charge_time = 2
		self.melee_weapons.pugio.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.pugio.stats.concealment = 30
		self.melee_weapons.pugio.stats.knockback_tier = 2
		self.melee_weapons.pugio.stats.max_damage = 50
		self.melee_weapons.pugio.stats.range = 175
		self.melee_weapons.pugio.stats.min_damage = 30


				--Talons--
		self.melee_weapons.tiger.subclasses = {
		}
		self.melee_weapons.tiger.primary_class = "class_melee"
		self.melee_weapons.tiger.stats.charge_time = 2
		self.melee_weapons.tiger.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.tiger.stats.concealment = 30
		self.melee_weapons.tiger.stats.knockback_tier = 1
		self.melee_weapons.tiger.stats.max_damage = 50
		self.melee_weapons.tiger.stats.range = 150
		self.melee_weapons.tiger.stats.min_damage = 30


				--Kento's Tanto--
		self.melee_weapons.hauteur.subclasses = {
		}
		self.melee_weapons.hauteur.primary_class = "class_melee"
		self.melee_weapons.hauteur.stats.charge_time = 2
		self.melee_weapons.hauteur.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.hauteur.stats.concealment = 30
		self.melee_weapons.hauteur.stats.knockback_tier = 2
		self.melee_weapons.hauteur.stats.max_damage = 75
		self.melee_weapons.hauteur.stats.range = 150
		self.melee_weapons.hauteur.stats.min_damage = 30


				--Hook--
		self.melee_weapons.catch.subclasses = {
		}
		self.melee_weapons.catch.primary_class = "class_melee"
		self.melee_weapons.catch.stats.charge_time = 2
		self.melee_weapons.catch.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.catch.stats.concealment = 25
		self.melee_weapons.catch.stats.knockback_tier = 3
		self.melee_weapons.catch.stats.max_damage = 65
		self.melee_weapons.catch.stats.range = 200
		self.melee_weapons.catch.stats.min_damage = 50


				--Two Handed Great Ruler--
		self.melee_weapons.meter.subclasses = {
		}
		self.melee_weapons.meter.primary_class = "class_melee"
		self.melee_weapons.meter.stats.charge_time = 2
		self.melee_weapons.meter.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.meter.stats.concealment = 10
		self.melee_weapons.meter.stats.knockback_tier = 3
		self.melee_weapons.meter.stats.max_damage = 101
		self.melee_weapons.meter.stats.range = 275
		self.melee_weapons.meter.stats.min_damage = 75


				--Selfie-Stick--
		self.melee_weapons.selfie.subclasses = {
		}
		self.melee_weapons.selfie.primary_class = "class_melee"
		self.melee_weapons.selfie.stats.charge_time = 2
		self.melee_weapons.selfie.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.selfie.stats.concealment = 30
		self.melee_weapons.selfie.stats.knockback_tier = 3
		self.melee_weapons.selfie.stats.max_damage = 10
		self.melee_weapons.selfie.stats.range = 250
		self.melee_weapons.selfie.stats.min_damage = 5


				--Specialist Knives--
		self.melee_weapons.ballistic.subclasses = {
		}
		self.melee_weapons.ballistic.primary_class = "class_melee"
		self.melee_weapons.ballistic.stats.charge_time = 2
		self.melee_weapons.ballistic.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.ballistic.stats.concealment = 30
		self.melee_weapons.ballistic.stats.knockback_tier = 2
		self.melee_weapons.ballistic.stats.max_damage = 50
		self.melee_weapons.ballistic.stats.range = 200
		self.melee_weapons.ballistic.stats.min_damage = 30


				--Alabama Razor--
		self.melee_weapons.clean.subclasses = {
		}
		self.melee_weapons.clean.primary_class = "class_melee"
		self.melee_weapons.clean.stats.charge_time = 2
		self.melee_weapons.clean.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.clean.stats.concealment = 32
		self.melee_weapons.clean.stats.knockback_tier = 1
		self.melee_weapons.clean.stats.max_damage = 50
		self.melee_weapons.clean.stats.range = 150
		self.melee_weapons.clean.stats.min_damage = 30


				--Wing Butterfly Knife--
		self.melee_weapons.wing.subclasses = {
		}
		self.melee_weapons.wing.primary_class = "class_melee"
		self.melee_weapons.wing.stats.charge_time = 2
		self.melee_weapons.wing.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.wing.stats.concealment = 30
		self.melee_weapons.wing.stats.knockback_tier = 2
		self.melee_weapons.wing.stats.max_damage = 50
		self.melee_weapons.wing.stats.range = 185
		self.melee_weapons.wing.stats.min_damage = 30


				--Carpenter's Delight--
		self.melee_weapons.hammer.subclasses = {
		}
		self.melee_weapons.hammer.primary_class = "class_melee"
		self.melee_weapons.hammer.stats.charge_time = 2
		self.melee_weapons.hammer.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.hammer.stats.concealment = 25
		self.melee_weapons.hammer.stats.knockback_tier = 3
		self.melee_weapons.hammer.stats.max_damage = 65
		self.melee_weapons.hammer.stats.range = 185
		self.melee_weapons.hammer.stats.min_damage = 50


				--Morning Star--
		self.melee_weapons.morning.subclasses = {
		}
		self.melee_weapons.morning.primary_class = "class_melee"
		self.melee_weapons.morning.stats.charge_time = 2
		self.melee_weapons.morning.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.morning.stats.concealment = 15
		self.melee_weapons.morning.stats.knockback_tier = 4
		self.melee_weapons.morning.stats.max_damage = 90
		self.melee_weapons.morning.stats.range = 225
		self.melee_weapons.morning.stats.min_damage = 60


				--Ding Dong Breaching Tool--
		self.melee_weapons.dingdong.subclasses = {
		}
		self.melee_weapons.dingdong.primary_class = "class_melee"
		self.melee_weapons.dingdong.stats.charge_time = 2
		self.melee_weapons.dingdong.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.dingdong.stats.concealment = 15
		self.melee_weapons.dingdong.stats.knockback_tier = 4
		self.melee_weapons.dingdong.stats.max_damage = 90
		self.melee_weapons.dingdong.stats.range = 275
		self.melee_weapons.dingdong.stats.min_damage = 60


				--Rezkoye--
		self.melee_weapons.oxide.subclasses = {
		}
		self.melee_weapons.oxide.primary_class = "class_melee"
		self.melee_weapons.oxide.stats.charge_time = 2
		self.melee_weapons.oxide.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.oxide.stats.concealment = 25
		self.melee_weapons.oxide.stats.knockback_tier = 2
		self.melee_weapons.oxide.stats.max_damage = 50
		self.melee_weapons.oxide.stats.range = 225
		self.melee_weapons.oxide.stats.min_damage = 30


				--Machete Knife--
		self.melee_weapons.machete.subclasses = {
		}
		self.melee_weapons.machete.primary_class = "class_melee"
		self.melee_weapons.machete.stats.charge_time = 2
		self.melee_weapons.machete.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.machete.stats.concealment = 25
		self.melee_weapons.machete.stats.knockback_tier = 2
		self.melee_weapons.machete.stats.max_damage = 65
		self.melee_weapons.machete.stats.range = 225
		self.melee_weapons.machete.stats.min_damage = 50


				--Berger Combat Knife--
		self.melee_weapons.gerber.subclasses = {
		}
		self.melee_weapons.gerber.primary_class = "class_melee"
		self.melee_weapons.gerber.stats.charge_time = 2
		self.melee_weapons.gerber.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.gerber.stats.concealment = 30
		self.melee_weapons.gerber.stats.knockback_tier = 2
		self.melee_weapons.gerber.stats.max_damage = 50
		self.melee_weapons.gerber.stats.range = 150
		self.melee_weapons.gerber.stats.min_damage = 30


				--Utility Knife--
		self.melee_weapons.boxcutter.subclasses = {
		}
		self.melee_weapons.boxcutter.primary_class = "class_melee"
		self.melee_weapons.boxcutter.stats.charge_time = 2
		self.melee_weapons.boxcutter.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.boxcutter.stats.concealment = 32
		self.melee_weapons.boxcutter.stats.knockback_tier = 2
		self.melee_weapons.boxcutter.stats.max_damage = 30
		self.melee_weapons.boxcutter.stats.range = 185
		self.melee_weapons.boxcutter.stats.min_damage = 20


				--Baseball Bat--
		self.melee_weapons.baseballbat.subclasses = {
		}
		self.melee_weapons.baseballbat.primary_class = "class_melee"
		self.melee_weapons.baseballbat.stats.charge_time = 2
		self.melee_weapons.baseballbat.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.baseballbat.stats.concealment = 20
		self.melee_weapons.baseballbat.stats.knockback_tier = 4
		self.melee_weapons.baseballbat.stats.max_damage = 80
		self.melee_weapons.baseballbat.stats.range = 250
		self.melee_weapons.baseballbat.stats.min_damage = 50


				--Tenderizer--
		self.melee_weapons.tenderizer.subclasses = {
		}
		self.melee_weapons.tenderizer.primary_class = "class_melee"
		self.melee_weapons.tenderizer.stats.charge_time = 2
		self.melee_weapons.tenderizer.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.tenderizer.stats.concealment = 30
		self.melee_weapons.tenderizer.stats.knockback_tier = 4
		self.melee_weapons.tenderizer.stats.max_damage = 10
		self.melee_weapons.tenderizer.stats.range = 185
		self.melee_weapons.tenderizer.stats.min_damage = 5


				--Hackaton--
		self.melee_weapons.happy.subclasses = {
		}
		self.melee_weapons.happy.primary_class = "class_melee"
		self.melee_weapons.happy.stats.charge_time = 2
		self.melee_weapons.happy.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.happy.stats.concealment = 30
		self.melee_weapons.happy.stats.knockback_tier = 3
		self.melee_weapons.happy.stats.max_damage = 30
		self.melee_weapons.happy.stats.range = 250
		self.melee_weapons.happy.stats.min_damage = 15


				--Scout Knife--
		self.melee_weapons.scoutknife.subclasses = {
		}
		self.melee_weapons.scoutknife.primary_class = "class_melee"
		self.melee_weapons.scoutknife.stats.charge_time = 2
		self.melee_weapons.scoutknife.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.scoutknife.stats.concealment = 30
		self.melee_weapons.scoutknife.stats.knockback_tier = 2
		self.melee_weapons.scoutknife.stats.max_damage = 50
		self.melee_weapons.scoutknife.stats.range = 150
		self.melee_weapons.scoutknife.stats.min_damage = 30


				--Weapon Butt--
		self.melee_weapons.weapon.subclasses = {
		}
		self.melee_weapons.weapon.primary_class = "class_melee"
		self.melee_weapons.weapon.stats.charge_time = 2
		self.melee_weapons.weapon.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.weapon.stats.concealment = 30
		self.melee_weapons.weapon.stats.knockback_tier = 3
		self.melee_weapons.weapon.stats.max_damage = 30
		self.melee_weapons.weapon.stats.range = 200
		self.melee_weapons.weapon.stats.min_damage = 20


				--Compact Hatchet--
		self.melee_weapons.bullseye.subclasses = {
		}
		self.melee_weapons.bullseye.primary_class = "class_melee"
		self.melee_weapons.bullseye.stats.charge_time = 2
		self.melee_weapons.bullseye.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.bullseye.stats.concealment = 30
		self.melee_weapons.bullseye.stats.knockback_tier = 2
		self.melee_weapons.bullseye.stats.max_damage = 50
		self.melee_weapons.bullseye.stats.range = 185
		self.melee_weapons.bullseye.stats.min_damage = 30


				--Shepherd's Cane--
		self.melee_weapons.stick.subclasses = {
		}
		self.melee_weapons.stick.primary_class = "class_melee"
		self.melee_weapons.stick.stats.charge_time = 2
		self.melee_weapons.stick.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.stick.stats.concealment = 30
		self.melee_weapons.stick.stats.knockback_tier = 2
		self.melee_weapons.stick.stats.max_damage = 10
		self.melee_weapons.stick.stats.range = 225
		self.melee_weapons.stick.stats.min_damage = 5


				--Knuckle Daggers--
		self.melee_weapons.grip.subclasses = {
		}
		self.melee_weapons.grip.primary_class = "class_melee"
		self.melee_weapons.grip.stats.charge_time = 2
		self.melee_weapons.grip.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.grip.stats.concealment = 25
		self.melee_weapons.grip.stats.knockback_tier = 2
		self.melee_weapons.grip.stats.max_damage = 65
		self.melee_weapons.grip.stats.range = 150
		self.melee_weapons.grip.stats.min_damage = 50


				--Push Daggers--
		self.melee_weapons.push.subclasses = {
		}
		self.melee_weapons.push.primary_class = "class_melee"
		self.melee_weapons.push.stats.charge_time = 2
		self.melee_weapons.push.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.push.stats.concealment = 30
		self.melee_weapons.push.stats.knockback_tier = 2
		self.melee_weapons.push.stats.max_damage = 60
		self.melee_weapons.push.stats.range = 150
		self.melee_weapons.push.stats.min_damage = 30


				--Leather Sap--
		self.melee_weapons.sap.subclasses = {
		}
		self.melee_weapons.sap.primary_class = "class_melee"
		self.melee_weapons.sap.stats.charge_time = 2
		self.melee_weapons.sap.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.sap.stats.concealment = 30
		self.melee_weapons.sap.stats.knockback_tier = 3
		self.melee_weapons.sap.stats.max_damage = 30
		self.melee_weapons.sap.stats.range = 200
		self.melee_weapons.sap.stats.min_damage = 15


				--50 Blessings Briefcase--
		self.melee_weapons.briefcase.subclasses = {
		}
		self.melee_weapons.briefcase.primary_class = "class_melee"
		self.melee_weapons.briefcase.stats.charge_time = 2
		self.melee_weapons.briefcase.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.briefcase.stats.concealment = 30
		self.melee_weapons.briefcase.stats.knockback_tier = 3
		self.melee_weapons.briefcase.stats.max_damage = 20
		self.melee_weapons.briefcase.stats.range = 185
		self.melee_weapons.briefcase.stats.min_damage = 10


				--Cleaver Knife--
		self.melee_weapons.cleaver.subclasses = {
		}
		self.melee_weapons.cleaver.primary_class = "class_melee"
		self.melee_weapons.cleaver.stats.charge_time = 2
		self.melee_weapons.cleaver.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.cleaver.stats.concealment = 25
		self.melee_weapons.cleaver.stats.knockback_tier = 2
		self.melee_weapons.cleaver.stats.max_damage = 65
		self.melee_weapons.cleaver.stats.range = 185
		self.melee_weapons.cleaver.stats.min_damage = 50


				--Alpha Mauler--
		self.melee_weapons.alien_maul.subclasses = {
		}
		self.melee_weapons.alien_maul.primary_class = "class_melee"
		self.melee_weapons.alien_maul.stats.charge_time = 2
		self.melee_weapons.alien_maul.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.alien_maul.stats.concealment = 15
		self.melee_weapons.alien_maul.stats.knockback_tier = 4
		self.melee_weapons.alien_maul.stats.max_damage = 90
		self.melee_weapons.alien_maul.stats.range = 275
		self.melee_weapons.alien_maul.stats.min_damage = 60


				--Switchblade--
		self.melee_weapons.switchblade.subclasses = {
		}
		self.melee_weapons.switchblade.primary_class = "class_melee"
		self.melee_weapons.switchblade.stats.charge_time = 2
		self.melee_weapons.switchblade.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.switchblade.stats.concealment = 32
		self.melee_weapons.switchblade.stats.knockback_tier = 1
		self.melee_weapons.switchblade.stats.max_damage = 30
		self.melee_weapons.switchblade.stats.range = 175
		self.melee_weapons.switchblade.stats.min_damage = 20


				--X-46 Knife--
		self.melee_weapons.x46.subclasses = {
		}
		self.melee_weapons.x46.primary_class = "class_melee"
		self.melee_weapons.x46.stats.charge_time = 2
		self.melee_weapons.x46.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.x46.stats.concealment = 30
		self.melee_weapons.x46.stats.knockback_tier = 1
		self.melee_weapons.x46.stats.max_damage = 50
		self.melee_weapons.x46.stats.range = 185
		self.melee_weapons.x46.stats.min_damage = 30


				--Great Sword--
		self.melee_weapons.great.subclasses = {
		}
		self.melee_weapons.great.primary_class = "class_melee"
		self.melee_weapons.great.stats.charge_time = 2
		self.melee_weapons.great.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.great.stats.concealment = 10
		self.melee_weapons.great.stats.knockback_tier = 3
		self.melee_weapons.great.stats.max_damage = 101
		self.melee_weapons.great.stats.range = 275
		self.melee_weapons.great.stats.min_damage = 75


				--Survival Tomahawk--
		self.melee_weapons.tomahawk.subclasses = {
		}
		self.melee_weapons.tomahawk.primary_class = "class_melee"
		self.melee_weapons.tomahawk.stats.charge_time = 2
		self.melee_weapons.tomahawk.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.tomahawk.stats.concealment = 30
		self.melee_weapons.tomahawk.stats.knockback_tier = 3
		self.melee_weapons.tomahawk.stats.max_damage = 50
		self.melee_weapons.tomahawk.stats.range = 225
		self.melee_weapons.tomahawk.stats.min_damage = 30


				--Nova's Shank--
		self.melee_weapons.toothbrush.subclasses = {
		}
		self.melee_weapons.toothbrush.primary_class = "class_melee"
		self.melee_weapons.toothbrush.stats.charge_time = 2
		self.melee_weapons.toothbrush.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.toothbrush.stats.concealment = 30
		self.melee_weapons.toothbrush.stats.knockback_tier = 1
		self.melee_weapons.toothbrush.stats.max_damage = 40
		self.melee_weapons.toothbrush.stats.range = 150
		self.melee_weapons.toothbrush.stats.min_damage = 40


				--Trautman Knife--
		self.melee_weapons.rambo.subclasses = {
		}
		self.melee_weapons.rambo.primary_class = "class_melee"
		self.melee_weapons.rambo.stats.charge_time = 2
		self.melee_weapons.rambo.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.rambo.stats.concealment = 30
		self.melee_weapons.rambo.stats.knockback_tier = 2
		self.melee_weapons.rambo.stats.max_damage = 50
		self.melee_weapons.rambo.stats.range = 200
		self.melee_weapons.rambo.stats.min_damage = 30


				--K.L.A.S. Shovel--
		self.melee_weapons.shovel.subclasses = {
		}
		self.melee_weapons.shovel.primary_class = "class_melee"
		self.melee_weapons.shovel.stats.charge_time = 2
		self.melee_weapons.shovel.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.shovel.stats.concealment = 25
		self.melee_weapons.shovel.stats.knockback_tier = 3
		self.melee_weapons.shovel.stats.max_damage = 60
		self.melee_weapons.shovel.stats.range = 250
		self.melee_weapons.shovel.stats.min_damage = 40


				--Classic Baton--
		self.melee_weapons.oldbaton.subclasses = {
		}
		self.melee_weapons.oldbaton.primary_class = "class_melee"
		self.melee_weapons.oldbaton.stats.charge_time = 2
		self.melee_weapons.oldbaton.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.oldbaton.stats.concealment = 25
		self.melee_weapons.oldbaton.stats.knockback_tier = 3
		self.melee_weapons.oldbaton.stats.max_damage = 65
		self.melee_weapons.oldbaton.stats.range = 250
		self.melee_weapons.oldbaton.stats.min_damage = 50


				--Empty Palm Kata--
		self.melee_weapons.fight.subclasses = {
		}
		self.melee_weapons.fight.primary_class = "class_melee"
		self.melee_weapons.fight.stats.charge_time = 2
		self.melee_weapons.fight.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.fight.stats.concealment = 35
		self.melee_weapons.fight.stats.knockback_tier = 1
		self.melee_weapons.fight.stats.max_damage = 20
		self.melee_weapons.fight.stats.range = 150
		self.melee_weapons.fight.stats.min_damage = 20


				--350K Brass Knuckles--
		self.melee_weapons.brass_knuckles.subclasses = {
		}
		self.melee_weapons.brass_knuckles.primary_class = "class_melee"
		self.melee_weapons.brass_knuckles.stats.charge_time = 2
		self.melee_weapons.brass_knuckles.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.brass_knuckles.stats.concealment = 32
		self.melee_weapons.brass_knuckles.stats.knockback_tier = 1
		self.melee_weapons.brass_knuckles.stats.max_damage = 70
		self.melee_weapons.brass_knuckles.stats.range = 150
		self.melee_weapons.brass_knuckles.stats.min_damage = 30


				--Swagger Stick--
		self.melee_weapons.swagger.subclasses = {
		}
		self.melee_weapons.swagger.primary_class = "class_melee"
		self.melee_weapons.swagger.stats.charge_time = 2
		self.melee_weapons.swagger.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.swagger.stats.concealment = 25
		self.melee_weapons.swagger.stats.knockback_tier = 3
		self.melee_weapons.swagger.stats.max_damage = 65
		self.melee_weapons.swagger.stats.range = 225
		self.melee_weapons.swagger.stats.min_damage = 50


				--Ice Pick--
		self.melee_weapons.iceaxe.subclasses = {
		}
		self.melee_weapons.iceaxe.primary_class = "class_melee"
		self.melee_weapons.iceaxe.stats.charge_time = 2
		self.melee_weapons.iceaxe.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.iceaxe.stats.concealment = 25
		self.melee_weapons.iceaxe.stats.knockback_tier = 2
		self.melee_weapons.iceaxe.stats.max_damage = 65
		self.melee_weapons.iceaxe.stats.range = 250
		self.melee_weapons.iceaxe.stats.min_damage = 50


				--Microphone Stand--
		self.melee_weapons.micstand.subclasses = {
		}
		self.melee_weapons.micstand.primary_class = "class_melee"
		self.melee_weapons.micstand.stats.charge_time = 2
		self.melee_weapons.micstand.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.micstand.stats.concealment = 30
		self.melee_weapons.micstand.stats.knockback_tier = 2
		self.melee_weapons.micstand.stats.max_damage = 10
		self.melee_weapons.micstand.stats.range = 250
		self.melee_weapons.micstand.stats.min_damage = 5


				--Microphone--
		self.melee_weapons.microphone.subclasses = {
		}
		self.melee_weapons.microphone.primary_class = "class_melee"
		self.melee_weapons.microphone.stats.charge_time = 2
		self.melee_weapons.microphone.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.microphone.stats.concealment = 30
		self.melee_weapons.microphone.stats.knockback_tier = 1
		self.melee_weapons.microphone.stats.max_damage = 30
		self.melee_weapons.microphone.stats.range = 150
		self.melee_weapons.microphone.stats.min_damage = 15


				--Gold Fever--
		self.melee_weapons.mining_pick.subclasses = {
		}
		self.melee_weapons.mining_pick.primary_class = "class_melee"
		self.melee_weapons.mining_pick.stats.charge_time = 2
		self.melee_weapons.mining_pick.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.mining_pick.stats.concealment = 15
		self.melee_weapons.mining_pick.stats.knockback_tier = 3
		self.melee_weapons.mining_pick.stats.max_damage = 99
		self.melee_weapons.mining_pick.stats.range = 225
		self.melee_weapons.mining_pick.stats.min_damage = 75


				--Dragan's Cleaver Knife--
		self.melee_weapons.meat_cleaver.subclasses = {
		}
		self.melee_weapons.meat_cleaver.primary_class = "class_melee"
		self.melee_weapons.meat_cleaver.stats.charge_time = 2
		self.melee_weapons.meat_cleaver.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.meat_cleaver.stats.concealment = 25
		self.melee_weapons.meat_cleaver.stats.knockback_tier = 2
		self.melee_weapons.meat_cleaver.stats.max_damage = 65
		self.melee_weapons.meat_cleaver.stats.range = 195
		self.melee_weapons.meat_cleaver.stats.min_damage = 50


				--Utility Machete--
		self.melee_weapons.becker.subclasses = {
		}
		self.melee_weapons.becker.primary_class = "class_melee"
		self.melee_weapons.becker.stats.charge_time = 2
		self.melee_weapons.becker.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.becker.stats.concealment = 25
		self.melee_weapons.becker.stats.knockback_tier = 2
		self.melee_weapons.becker.stats.max_damage = 65
		self.melee_weapons.becker.stats.range = 200
		self.melee_weapons.becker.stats.min_damage = 50


				--Ursa Tanto Knife--
		self.melee_weapons.kabartanto.subclasses = {
		}
		self.melee_weapons.kabartanto.primary_class = "class_melee"
		self.melee_weapons.kabartanto.stats.charge_time = 2
		self.melee_weapons.kabartanto.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.kabartanto.stats.concealment = 30
		self.melee_weapons.kabartanto.stats.knockback_tier = 2
		self.melee_weapons.kabartanto.stats.max_damage = 50
		self.melee_weapons.kabartanto.stats.range = 185
		self.melee_weapons.kabartanto.stats.min_damage = 30


				--URSA Knife--
		self.melee_weapons.kabar.subclasses = {
		}
		self.melee_weapons.kabar.primary_class = "class_melee"
		self.melee_weapons.kabar.stats.charge_time = 2
		self.melee_weapons.kabar.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.kabar.stats.concealment = 30
		self.melee_weapons.kabar.stats.knockback_tier = 2
		self.melee_weapons.kabar.stats.max_damage = 50
		self.melee_weapons.kabar.stats.range = 185
		self.melee_weapons.kabar.stats.min_damage = 30


				--The Motherforker--
		self.melee_weapons.fork.subclasses = {
		}
		self.melee_weapons.fork.primary_class = "class_melee"
		self.melee_weapons.fork.stats.charge_time = 2
		self.melee_weapons.fork.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.fork.stats.concealment = 30
		self.melee_weapons.fork.stats.knockback_tier = 1
		self.melee_weapons.fork.stats.max_damage = 50
		self.melee_weapons.fork.stats.range = 185
		self.melee_weapons.fork.stats.min_damage = 30


				--Monkey Wrench--
		self.melee_weapons.shock.subclasses = {
		}
		self.melee_weapons.shock.primary_class = "class_melee"
		self.melee_weapons.shock.stats.charge_time = 2
		self.melee_weapons.shock.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.shock.stats.concealment = 25
		self.melee_weapons.shock.stats.knockback_tier = 3
		self.melee_weapons.shock.stats.max_damage = 50
		self.melee_weapons.shock.stats.range = 185
		self.melee_weapons.shock.stats.min_damage = 30


				--The Spear of Freedom--
		self.melee_weapons.freedom.subclasses = {
		}
		self.melee_weapons.freedom.primary_class = "class_melee"
		self.melee_weapons.freedom.stats.charge_time = 2
		self.melee_weapons.freedom.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.freedom.stats.concealment = 15
		self.melee_weapons.freedom.stats.knockback_tier = 3
		self.melee_weapons.freedom.stats.max_damage = 90
		self.melee_weapons.freedom.stats.range = 275
		self.melee_weapons.freedom.stats.min_damage = 60


				--Trench Knife--
		self.melee_weapons.fairbair.subclasses = {
		}
		self.melee_weapons.fairbair.primary_class = "class_melee"
		self.melee_weapons.fairbair.stats.charge_time = 2
		self.melee_weapons.fairbair.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.fairbair.stats.concealment = 30
		self.melee_weapons.fairbair.stats.knockback_tier = 2
		self.melee_weapons.fairbair.stats.max_damage = 50
		self.melee_weapons.fairbair.stats.range = 175
		self.melee_weapons.fairbair.stats.min_damage = 30


				--Telescopic Baton--
		self.melee_weapons.baton.subclasses = {
		}
		self.melee_weapons.baton.primary_class = "class_melee"
		self.melee_weapons.baton.stats.charge_time = 2
		self.melee_weapons.baton.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.baton.stats.concealment = 30
		self.melee_weapons.baton.stats.knockback_tier = 3
		self.melee_weapons.baton.stats.max_damage = 10
		self.melee_weapons.baton.stats.range = 250
		self.melee_weapons.baton.stats.min_damage = 5


				--Arkansas Toothpick--
		self.melee_weapons.bowie.subclasses = {
		}
		self.melee_weapons.bowie.primary_class = "class_melee"
		self.melee_weapons.bowie.stats.charge_time = 2
		self.melee_weapons.bowie.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.bowie.stats.concealment = 25
		self.melee_weapons.bowie.stats.knockback_tier = 2
		self.melee_weapons.bowie.stats.max_damage = 70
		self.melee_weapons.bowie.stats.range = 225
		self.melee_weapons.bowie.stats.min_damage = 50


				--Hotline 8000x--
		self.melee_weapons.brick.subclasses = {
		}
		self.melee_weapons.brick.primary_class = "class_melee"
		self.melee_weapons.brick.stats.charge_time = 2
		self.melee_weapons.brick.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.brick.stats.concealment = 30
		self.melee_weapons.brick.stats.knockback_tier = 3
		self.melee_weapons.brick.stats.max_damage = 70
		self.melee_weapons.brick.stats.range = 185
		self.melee_weapons.brick.stats.min_damage = 30


				--The Pen--
		self.melee_weapons.sword.subclasses = {
		}
		self.melee_weapons.sword.primary_class = "class_melee"
		self.melee_weapons.sword.stats.charge_time = 2
		self.melee_weapons.sword.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.sword.stats.concealment = 30
		self.melee_weapons.sword.stats.knockback_tier = 1
		self.melee_weapons.sword.stats.max_damage = 40
		self.melee_weapons.sword.stats.range = 150
		self.melee_weapons.sword.stats.min_damage = 40


				--Poker--
		self.melee_weapons.poker.subclasses = {
		}
		self.melee_weapons.poker.primary_class = "class_melee"
		self.melee_weapons.poker.stats.charge_time = 2
		self.melee_weapons.poker.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.poker.stats.concealment = 25
		self.melee_weapons.poker.stats.knockback_tier = 3
		self.melee_weapons.poker.stats.max_damage = 65
		self.melee_weapons.poker.stats.range = 185
		self.melee_weapons.poker.stats.min_damage = 50


				--Clover's Shillelagh--
		self.melee_weapons.shillelagh.subclasses = {
		}
		self.melee_weapons.shillelagh.primary_class = "class_melee"
		self.melee_weapons.shillelagh.stats.charge_time = 2
		self.melee_weapons.shillelagh.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.shillelagh.stats.concealment = 25
		self.melee_weapons.shillelagh.stats.knockback_tier = 3
		self.melee_weapons.shillelagh.stats.max_damage = 65
		self.melee_weapons.shillelagh.stats.range = 185
		self.melee_weapons.shillelagh.stats.min_damage = 50


				--Pitchfork--
		self.melee_weapons.pitchfork.subclasses = {
		}
		self.melee_weapons.pitchfork.primary_class = "class_melee"
		self.melee_weapons.pitchfork.stats.charge_time = 2
		self.melee_weapons.pitchfork.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.pitchfork.stats.concealment = 15
		self.melee_weapons.pitchfork.stats.knockback_tier = 3
		self.melee_weapons.pitchfork.stats.max_damage = 90
		self.melee_weapons.pitchfork.stats.range = 225
		self.melee_weapons.pitchfork.stats.min_damage = 60


				--El Verdugo--
		self.melee_weapons.agave.subclasses = {
		}
		self.melee_weapons.agave.primary_class = "class_melee"
		self.melee_weapons.agave.stats.charge_time = 2
		self.melee_weapons.agave.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.agave.stats.concealment = 25
		self.melee_weapons.agave.stats.knockback_tier = 3
		self.melee_weapons.agave.stats.max_damage = 65
		self.melee_weapons.agave.stats.range = 225
		self.melee_weapons.agave.stats.min_damage = 50


				--Hockey Stick--
		self.melee_weapons.hockey.subclasses = {
		}
		self.melee_weapons.hockey.primary_class = "class_melee"
		self.melee_weapons.hockey.stats.charge_time = 2
		self.melee_weapons.hockey.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.hockey.stats.concealment = 25
		self.melee_weapons.hockey.stats.knockback_tier = 3
		self.melee_weapons.hockey.stats.max_damage = 60
		self.melee_weapons.hockey.stats.range = 250
		self.melee_weapons.hockey.stats.min_damage = 40


				--Bearded Axe--
		self.melee_weapons.beardy.subclasses = {
		}
		self.melee_weapons.beardy.primary_class = "class_melee"
		self.melee_weapons.beardy.stats.charge_time = 2
		self.melee_weapons.beardy.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.beardy.stats.concealment = 10
		self.melee_weapons.beardy.stats.knockback_tier = 3
		self.melee_weapons.beardy.stats.max_damage = 101
		self.melee_weapons.beardy.stats.range = 275
		self.melee_weapons.beardy.stats.min_damage = 75


				--Okinawan Style Sai--
		self.melee_weapons.twins.subclasses = {
		}
		self.melee_weapons.twins.primary_class = "class_melee"
		self.melee_weapons.twins.stats.charge_time = 2
		self.melee_weapons.twins.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.twins.stats.concealment = 30
		self.melee_weapons.twins.stats.knockback_tier = 2
		self.melee_weapons.twins.stats.max_damage = 60
		self.melee_weapons.twins.stats.range = 200
		self.melee_weapons.twins.stats.min_damage = 30


				--Machete--
		self.melee_weapons.gator.subclasses = {
		}
		self.melee_weapons.gator.primary_class = "class_melee"
		self.melee_weapons.gator.stats.charge_time = 2
		self.melee_weapons.gator.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.gator.stats.concealment = 25
		self.melee_weapons.gator.stats.knockback_tier = 2
		self.melee_weapons.gator.stats.max_damage = 65
		self.melee_weapons.gator.stats.range = 225
		self.melee_weapons.gator.stats.min_damage = 50


				--Fire Axe--
		self.melee_weapons.fireaxe.subclasses = {
		}
		self.melee_weapons.fireaxe.primary_class = "class_melee"
		self.melee_weapons.fireaxe.stats.charge_time = 2
		self.melee_weapons.fireaxe.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.fireaxe.stats.concealment = 10
		self.melee_weapons.fireaxe.stats.knockback_tier = 3
		self.melee_weapons.fireaxe.stats.max_damage = 101
		self.melee_weapons.fireaxe.stats.range = 275
		self.melee_weapons.fireaxe.stats.min_damage = 75


				--OVERKILL Boxing Gloves--
		self.melee_weapons.boxing_gloves.subclasses = {
		}
		self.melee_weapons.boxing_gloves.primary_class = "class_melee"
		self.melee_weapons.boxing_gloves.stats.charge_time = 2
		self.melee_weapons.boxing_gloves.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.boxing_gloves.stats.concealment = 32
		self.melee_weapons.boxing_gloves.stats.knockback_tier = 3
		self.melee_weapons.boxing_gloves.stats.max_damage = 10
		self.melee_weapons.boxing_gloves.stats.range = 150
		self.melee_weapons.boxing_gloves.stats.min_damage = 5


				--Lucille Baseball Bat--
		self.melee_weapons.barbedwire.subclasses = {
		}
		self.melee_weapons.barbedwire.primary_class = "class_melee"
		self.melee_weapons.barbedwire.stats.charge_time = 2
		self.melee_weapons.barbedwire.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.barbedwire.stats.concealment = 20
		self.melee_weapons.barbedwire.stats.knockback_tier = 2
		self.melee_weapons.barbedwire.stats.max_damage = 100
		self.melee_weapons.barbedwire.stats.range = 275
		self.melee_weapons.barbedwire.stats.min_damage = 60


				--Psycho Knife--
		self.melee_weapons.chef.subclasses = {
		}
		self.melee_weapons.chef.primary_class = "class_melee"
		self.melee_weapons.chef.stats.charge_time = 2
		self.melee_weapons.chef.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.chef.stats.concealment = 30
		self.melee_weapons.chef.stats.knockback_tier = 1
		self.melee_weapons.chef.stats.max_damage = 70
		self.melee_weapons.chef.stats.range = 150
		self.melee_weapons.chef.stats.min_damage = 10


				--Spatula--
		self.melee_weapons.spatula.subclasses = {
		}
		self.melee_weapons.spatula.primary_class = "class_melee"
		self.melee_weapons.spatula.stats.charge_time = 2
		self.melee_weapons.spatula.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.spatula.stats.concealment = 30
		self.melee_weapons.spatula.stats.knockback_tier = 3
		self.melee_weapons.spatula.stats.max_damage = 10
		self.melee_weapons.spatula.stats.range = 185
		self.melee_weapons.spatula.stats.min_damage = 5


				--Bayonet Knife--
		self.melee_weapons.bayonet.subclasses = {
		}
		self.melee_weapons.bayonet.primary_class = "class_melee"
		self.melee_weapons.bayonet.stats.charge_time = 2
		self.melee_weapons.bayonet.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.bayonet.stats.concealment = 29
		self.melee_weapons.bayonet.stats.knockback_tier = 2
		self.melee_weapons.bayonet.stats.max_damage = 50
		self.melee_weapons.bayonet.stats.range = 185
		self.melee_weapons.bayonet.stats.min_damage = 30


				--Shawn's Shears--
		self.melee_weapons.shawn.subclasses = {
		}
		self.melee_weapons.shawn.primary_class = "class_melee"
		self.melee_weapons.shawn.stats.charge_time = 2
		self.melee_weapons.shawn.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.shawn.stats.concealment = 30
		self.melee_weapons.shawn.stats.knockback_tier = 2
		self.melee_weapons.shawn.stats.max_damage = 50
		self.melee_weapons.shawn.stats.range = 150
		self.melee_weapons.shawn.stats.min_damage = 30


				--Shinsakuto Katana--
		self.melee_weapons.sandsteel.subclasses = {
		}
		self.melee_weapons.sandsteel.primary_class = "class_melee"
		self.melee_weapons.sandsteel.stats.charge_time = 2
		self.melee_weapons.sandsteel.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.sandsteel.stats.concealment = 20
		self.melee_weapons.sandsteel.stats.knockback_tier = 1
		self.melee_weapons.sandsteel.stats.max_damage = 65
		self.melee_weapons.sandsteel.stats.range = 275
		self.melee_weapons.sandsteel.stats.min_damage = 50


				--Fists--
		self.melee_weapons.fists.subclasses = {
		}
		self.melee_weapons.fists.primary_class = "class_melee"
		self.melee_weapons.fists.stats.charge_time = 2
		self.melee_weapons.fists.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.fists.stats.concealment = 35
		self.melee_weapons.fists.stats.knockback_tier = 1
		self.melee_weapons.fists.stats.max_damage = 30
		self.melee_weapons.fists.stats.range = 150
		self.melee_weapons.fists.stats.min_damage = 15


				--Scalper Tomahawk--
		self.melee_weapons.scalper.subclasses = {
		}
		self.melee_weapons.scalper.primary_class = "class_melee"
		self.melee_weapons.scalper.stats.charge_time = 2
		self.melee_weapons.scalper.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.scalper.stats.concealment = 25
		self.melee_weapons.scalper.stats.knockback_tier = 3
		self.melee_weapons.scalper.stats.max_damage = 50
		self.melee_weapons.scalper.stats.range = 200
		self.melee_weapons.scalper.stats.min_damage = 30



		----------------------------------------------------------------------------------------------------------------------
		-- ************************************************ GIMMICK MELEES ************************************************ --
		----------------------------------------------------------------------------------------------------------------------

				--Buzzer--
		self.melee_weapons.taser.subclasses = {
		}
		self.melee_weapons.taser.primary_class = "class_melee"
		self.melee_weapons.taser.stats.charge_time = 2
		self.melee_weapons.taser.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.taser.stats.concealment = 25
		self.melee_weapons.taser.stats.knockback_tier = 1
		self.melee_weapons.taser.stats.max_damage = 5
		self.melee_weapons.taser.stats.range = 200
		self.melee_weapons.taser.stats.min_damage = 5


				--Tactical Flashlight--
		self.melee_weapons.aziz.subclasses = {
		}
		self.melee_weapons.aziz.primary_class = "class_melee"
		self.melee_weapons.aziz.stats.charge_time = 2
		self.melee_weapons.aziz.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.aziz.stats.concealment = 30
		self.melee_weapons.aziz.stats.knockback_tier = 2
		self.melee_weapons.aziz.stats.max_damage = 10
		self.melee_weapons.aziz.stats.range = 150
		self.melee_weapons.aziz.stats.min_damage = 5


				--Lumber Lite L2--
		self.melee_weapons.cs.subclasses = {
		}
		self.melee_weapons.cs.primary_class = "class_melee"
		self.melee_weapons.cs.stats.charge_time = 2
		self.melee_weapons.cs.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.cs.stats.concealment = 10
		self.melee_weapons.cs.stats.knockback_tier = 3
		self.melee_weapons.cs.stats.max_damage = 125
		self.melee_weapons.cs.stats.range = 200
		self.melee_weapons.cs.stats.min_damage = 40

				--Stainless Steel Syringe--
		self.melee_weapons.fear.subclasses = {
			"subclass_poison"
		}
		self.melee_weapons.fear.primary_class = "class_melee"
		self.melee_weapons.fear.stats.charge_time = 2
		self.melee_weapons.fear.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.fear.stats.concealment = 30
		self.melee_weapons.fear.stats.knockback_tier = 1
		self.melee_weapons.fear.stats.max_damage = 80
		self.melee_weapons.fear.stats.range = 200
		self.melee_weapons.fear.stats.min_damage = 50


				--Metal Detector--
		self.melee_weapons.detector.subclasses = {
		}
		self.melee_weapons.detector.primary_class = "class_melee"
		self.melee_weapons.detector.stats.charge_time = 2
		self.melee_weapons.detector.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.detector.stats.concealment = 30
		self.melee_weapons.detector.stats.knockback_tier = 3
		self.melee_weapons.detector.stats.max_damage = 10
		self.melee_weapons.detector.stats.range = 225
		self.melee_weapons.detector.stats.min_damage = 5
		self.melee_weapons.detector.mark_enemy_on_hit = true --mark target on hit
		self.melee_weapons.detector.aoe_mark_enemy_on_hit = true --aoe mark on charged hit


				--Rivertown Glen Bottle--
		self.melee_weapons.whiskey.subclasses = {
		}
		self.melee_weapons.whiskey.primary_class = "class_melee"
		self.melee_weapons.whiskey.stats.charge_time = 2
		self.melee_weapons.whiskey.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.whiskey.stats.concealment = 30
		self.melee_weapons.whiskey.stats.knockback_tier = 2
		self.melee_weapons.whiskey.stats.max_damage = 10
		self.melee_weapons.whiskey.stats.range = 185
		self.melee_weapons.whiskey.stats.min_damage = 5
		self.melee_weapons.whiskey.dodge_chance_bonus_while_charging = 0.1
		

				--Jackpot--
		self.melee_weapons.slot_lever.subclasses = {
		}
		self.melee_weapons.slot_lever.primary_class = "class_melee"
		self.melee_weapons.slot_lever.stats.charge_time = 2
		self.melee_weapons.slot_lever.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.slot_lever.stats.concealment = 30
		self.melee_weapons.slot_lever.stats.knockback_tier = 1
		self.melee_weapons.slot_lever.stats.max_damage = 20
		self.melee_weapons.slot_lever.stats.range = 225
		self.melee_weapons.slot_lever.stats.min_damage = 10
		self.melee_weapons.slot_lever.random_damage_mul = { 1,2,4,6,8,10 } --possible random damage multipliers


				--Buckler Shield--
		self.melee_weapons.buck.subclasses = {
		}
		self.melee_weapons.buck.primary_class = "class_melee"
		self.melee_weapons.buck.stats.charge_time = 2
		self.melee_weapons.buck.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.buck.stats.concealment = 10
		self.melee_weapons.buck.stats.knockback_tier = 2
		self.melee_weapons.buck.stats.max_damage = 50
		self.melee_weapons.buck.stats.range = 175
		self.melee_weapons.buck.stats.min_damage = 30
		
		self.melee_weapons.buck.melee_damage_resistance = 0.75
		self.melee_weapons.buck.all_damage_resistance = 0.1


				--Pounder--
		self.melee_weapons.nin.subclasses = {
		}
		self.melee_weapons.nin.primary_class = "class_melee"
		self.melee_weapons.nin.stats.charge_time = 2
		self.melee_weapons.nin.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.nin.stats.concealment = 20
		self.melee_weapons.nin.stats.knockback_tier = 2
		self.melee_weapons.nin.stats.max_damage = 80
		self.melee_weapons.nin.stats.range = 185
		self.melee_weapons.nin.stats.min_damage = 50
		
		self.melee_weapons.nin.pierce_body_armor = true
		self.melee_weapons.nin.pierce_shields = true


				--Kunai Knife--
		self.melee_weapons.cqc.subclasses = {
			"subclass_poison"
		}
		self.melee_weapons.cqc.primary_class = "class_melee"
		self.melee_weapons.cqc.stats.charge_time = 2
		self.melee_weapons.cqc.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.cqc.stats.concealment = 30
		self.melee_weapons.cqc.stats.knockback_tier = 1
		self.melee_weapons.cqc.stats.max_damage = 30
		self.melee_weapons.cqc.stats.range = 150
		self.melee_weapons.cqc.stats.min_damage = 20


				--Potato Masher--
		self.melee_weapons.model24.subclasses = {
		}
		self.melee_weapons.model24.primary_class = "class_melee"
		self.melee_weapons.model24.stats.charge_time = 2
		self.melee_weapons.model24.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.model24.stats.concealment = 30
		self.melee_weapons.model24.stats.knockback_tier = 1
		self.melee_weapons.model24.stats.max_damage = 30
		self.melee_weapons.model24.stats.range = 185
		self.melee_weapons.model24.stats.min_damage = 20
		self.melee_weapons.model24.panic_on_hit = true


				--Kazaguruma--
		self.melee_weapons.ostry.subclasses = {
		}
		self.melee_weapons.ostry.primary_class = "class_melee"
		self.melee_weapons.ostry.stats.charge_time = 2
		self.melee_weapons.ostry.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.ostry.stats.concealment = 10
		self.melee_weapons.ostry.stats.knockback_tier = 1
		self.melee_weapons.ostry.stats.max_damage = 50
		self.melee_weapons.ostry.stats.range = 200
		self.melee_weapons.ostry.stats.min_damage = 50


				--Bolt Cutters--
		self.melee_weapons.cutters.subclasses = {
		}
		self.melee_weapons.cutters.primary_class = "class_melee"
		self.melee_weapons.cutters.stats.charge_time = 2
		self.melee_weapons.cutters.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.cutters.stats.concealment = 30
		self.melee_weapons.cutters.stats.knockback_tier = 2
		self.melee_weapons.cutters.stats.max_damage = 10
		self.melee_weapons.cutters.stats.range = 275
		self.melee_weapons.cutters.stats.min_damage = 5
		self.melee_weapons.cutters.interact_cut_faster = 0.5


				--Electrical Brass Knuckles--
		self.melee_weapons.zeus.subclasses = {
		}
		self.melee_weapons.zeus.primary_class = "class_melee"
		self.melee_weapons.zeus.stats.charge_time = 2
		self.melee_weapons.zeus.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.zeus.stats.concealment = 25
		self.melee_weapons.zeus.stats.knockback_tier = 1
		self.melee_weapons.zeus.stats.max_damage = 50
		self.melee_weapons.zeus.stats.range = 200
		self.melee_weapons.zeus.stats.min_damage = 30


				--You're Mine--
		self.melee_weapons.branding_iron.subclasses = {
		}
		self.melee_weapons.branding_iron.primary_class = "class_melee"
		self.melee_weapons.branding_iron.stats.charge_time = 2
		self.melee_weapons.branding_iron.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.branding_iron.stats.concealment = 10
		self.melee_weapons.branding_iron.stats.knockback_tier = 2
		self.melee_weapons.branding_iron.stats.max_damage = 80
		self.melee_weapons.branding_iron.stats.range = 225
		self.melee_weapons.branding_iron.stats.min_damage = 50


				--Croupier's Rake--
		self.melee_weapons.croupier_rake.subclasses = {
		}
		self.melee_weapons.croupier_rake.primary_class = "class_melee"
		self.melee_weapons.croupier_rake.stats.charge_time = 2
		self.melee_weapons.croupier_rake.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.croupier_rake.stats.concealment = 30
		self.melee_weapons.croupier_rake.stats.knockback_tier = 1
		self.melee_weapons.croupier_rake.stats.max_damage = 10
		self.melee_weapons.croupier_rake.stats.range = 250
		self.melee_weapons.croupier_rake.stats.min_damage = 5
		self.melee_weapons.croupier_rake.random_knockback_tier = true --reference possible melee tiers


				--Money Bundle--
		self.melee_weapons.moneybundle.subclasses = {
		}
		self.melee_weapons.moneybundle.primary_class = "class_melee"
		self.melee_weapons.moneybundle.stats.charge_time = 2
		self.melee_weapons.moneybundle.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.moneybundle.stats.concealment = 30
		self.melee_weapons.moneybundle.stats.knockback_tier = 2
		self.melee_weapons.moneybundle.stats.max_damage = 25
		self.melee_weapons.moneybundle.stats.range = 150
		self.melee_weapons.moneybundle.stats.min_damage = 15
		self.melee_weapons.moneybundle.generate_cash = true

				--Chain Whip--
		self.melee_weapons.road.subclasses = {
		}
		self.melee_weapons.road.primary_class = "class_melee"
		self.melee_weapons.road.stats.charge_time = 2
		self.melee_weapons.road.stats.remove_weapon_movement_penalty = true
		self.melee_weapons.road.stats.concealment = 10
		self.melee_weapons.road.stats.knockback_tier = 3
		self.melee_weapons.road.stats.max_damage = 30
		self.melee_weapons.road.stats.range = 200
		self.melee_weapons.road.stats.min_damage = 30
		self.melee_weapons.road.hit_while_charging = {
			swing_delay_initial = 0.7,
			swing_delay_repeat = 0.33
		}




		
	end)
end
