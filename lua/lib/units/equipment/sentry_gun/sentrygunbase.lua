function SentryGunBase:unregister()
	if self._registered then
		self._registered = nil
	end
end

function SentryGunBase:register()
	self._registered = true
end

if deathvox:IsTotalCrackdownEnabled() then 

	SentryGunBase.DEPLOYEMENT_COST = {
		1,
		1,
		1
	}
	SentryGunBase.MIN_DEPLOYEMENT_COST = 0

--the only changes to this are the removal of the AP bullets skill check to spawn the interaction unit
	function SentryGunBase.spawn(owner, pos, rot, peer_id, verify_equipment, unit_idstring_index,fire_mode_index)
		local sentry_owner = nil

		if owner and owner:base().upgrade_value then
			sentry_owner = owner
		end

		local player_skill = PlayerSkill
		local ammo_multiplier = player_skill.skill_data("sentry_gun", "extra_ammo_multiplier", 1, sentry_owner)
		local armor_multiplier = 1 + player_skill.skill_data("sentry_gun", "armor_multiplier", 1, sentry_owner) - 1 + player_skill.skill_data("sentry_gun", "armor_multiplier2", 1, sentry_owner) - 1
		local spread_level = player_skill.skill_data("sentry_gun", "spread_multiplier", 1, sentry_owner)
		local rot_speed_level = player_skill.skill_data("sentry_gun", "rot_speed_multiplier", 1, sentry_owner)
	--	local ap_bullets = player_skill.has_skill("sentry_gun", "ap_bullets", sentry_owner)
		local has_shield = player_skill.has_skill("sentry_gun", "shield", sentry_owner)
		local id_string = Idstring("units/payday2/equipment/gen_equipment_sentry/gen_equipment_sentry")

		if unit_idstring_index then
			id_string = tweak_data.equipments.sentry_id_strings[unit_idstring_index]
		end

		local unit = World:spawn_unit(id_string, pos, rot)
		local spread_multiplier = SentryGunBase.SPREAD_MUL[spread_level]
		local rot_speed_multiplier = SentryGunBase.ROTATION_SPEED_MUL[rot_speed_level]

		managers.network:session():send_to_peers_synched("sync_equipment_setup", unit, 0, peer_id or 0)

		ammo_multiplier = SentryGunBase.AMMO_MUL[ammo_multiplier]

		unit:base():setup(owner, ammo_multiplier, armor_multiplier, spread_multiplier, rot_speed_multiplier, has_shield, attached_data,fire_mode_index)

		local owner_id = unit:base():get_owner_id()
		if owner_id then --don't check for ap bullets; just create firemode unit for firemode toggle interaction
		--(dirty firemode toggle interaction is now recycled for opening sentry control menu)
			local fire_mode_unit = World:spawn_unit(Idstring("units/payday2/equipment/gen_equipment_sentry/gen_equipment_sentry_fire_mode"), unit:position(), unit:rotation())
			unit:weapon():interaction_setup(fire_mode_unit, owner_id)
			managers.network:session():send_to_peers_synched("sync_fire_mode_interaction", unit, fire_mode_unit, owner_id)
		end
		
		local team = nil

		if owner then
			team = owner:movement():team()
		else
			team = managers.groupai:state():team_data(tweak_data.levels:get_default_team_ID("player"))
		end

		unit:movement():set_team(team)
		unit:brain():set_active(true)

		SentryGunBase.deployed = (SentryGunBase.deployed or 0) + 1

		return unit, spread_level, rot_speed_level
	end

	function SentryGunBase:setup(owner, ammo_multiplier, armor_multiplier, spread_multiplier, rot_speed_multiplier, has_shield, attached_data)
		if Network:is_client() and not self._skip_authentication then
			self._validate_clbk_id = "sentry_gun_validate" .. tostring(unit:key())

			managers.enemy:add_delayed_clbk(self._validate_clbk_id, callback(self, self, "_clbk_validate"), Application:time() + 60)
		end

		
		self._attached_data = attached_data
		self._ammo_multiplier = ammo_multiplier or 1
		self._armor_multiplier = armor_multiplier or 1
		self._spread_multiplier = spread_multiplier or 1
		self._rot_speed_multiplier = rot_speed_multiplier or 1

		if has_shield then
			self:enable_shield()
		end

		local ammo_amount = tweak_data.upgrades.sentry_gun_base_ammo * self._ammo_multiplier

		self._unit:weapon():set_ammo(ammo_amount)

		local armor_amount = tweak_data.upgrades.sentry_gun_base_armor * self._armor_multiplier

		self._unit:character_damage():set_health(armor_amount, 0)

		self._owner = owner

		if owner then
			local peer = managers.network:session():peer_by_unit(owner)

			if peer then
			
				if peer:id() == managers.network:session():local_peer():id() then
	--				self:_create_ws()
				end
				
				self._owner_id = peer:id()

				if self._unit:interaction() then
					self._unit:interaction():set_owner_id(self._owner_id)
				end
			end
		end

		self._unit:movement():setup(rot_speed_multiplier)
		self._unit:brain():setup(1 / rot_speed_multiplier)
		self:register()
		self._unit:movement():set_team(owner:movement():team())

		local setup_data = {
			expend_ammo = true,
			autoaim = true,
			alert_AI = true,
			creates_alerts = true,
			user_unit = self._owner,
			ignore_units = {
				self._unit,
				self._owner
			},
			alert_filter = self._owner:movement():SO_access(),
			spread_mul = self._spread_multiplier
		}

		self._unit:weapon():setup(setup_data)
		self._unit:set_extension_update_enabled(Idstring("base"), true)
		self:post_setup()
	--above is all vanilla
		return true
	end


	function SentryGunBase:remove()
		self._removed = true
		self._unit:set_slot(0)
	end
	
--	Hooks:PostHook(SentryGunBase,"pre_destroy","tcdso_sentry_predestroy",function(self)
--		SentryControlMenu:_remove_ws(self._ws)
--		self._ws = nil	
--	end)

	function SentryGunBase:_create_ws() 
--deprecated
		self._ws = SentryControlMenu:_create_panel(self._unit)
		self._panel = self._ws:panel()
		self._bitmap = self._panel:child("bitmap") or self._panel:bitmap({
			name = "bitmap",
			texture = "guis/textures/pd2/hud_health",
	--		texture = tweak_data.hud_icons.wp_sentry.texture,
	--		texture_rect = tweak_data.hud_icons.wp_sentry.texture_rect,
			w = 64,
			h = 64,
			alpha = 1,
			layer = 1,
			visible = false
		})
		self._text = self._panel:child("text") or self._panel:text({ --not yet used for anything
			name = "text",
			text = tostring(self._owner_id),
			font = tweak_data.hud.medium_font,
			color = Color.red,
			font_size = 36,
			layer = 2,
			alpha = 1,
			align = "center",
			vertical = "center",
			visible = false
		})
		self._bitmap:set_center(self._panel:center())
	end
end
