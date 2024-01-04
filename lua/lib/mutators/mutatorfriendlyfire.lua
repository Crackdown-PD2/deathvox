--[[
function MutatorFriendlyFire:setup(mutator_manager)
	MutatorFriendlyFire.super.setup(mutator_manager)

	--this results in anything that uses this slotmask to hit targets, to hit player husks, which is NOT good, so I'm commenting it out
	--managers.slot._masks.bullet_impact_targets = managers.slot._masks.bullet_impact_targets_ff
end
--]]

function MutatorFriendlyFire:modify_value(id, value)
	if id == "PlayerDamage:FriendlyFire" then
		return false
	elseif id == "HuskPlayerDamage:FriendlyFireDamage" then
		return value * self:get_friendly_fire_damage_multiplier() --normally this also multiplies damage by 0.25 for no reason?? Makes the ingame slider confusing
	elseif id == "ProjectileBase:create_sweep_data:slot_mask" or id == "PlayerStandard:init:melee_slot_mask" or id == "RaycastWeaponBase:setup:weapon_slot_mask" then
		return value + 3
	end
end
