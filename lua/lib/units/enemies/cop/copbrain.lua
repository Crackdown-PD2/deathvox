require("lib/units/enemies/cop/logics/CopLogicBase")
require("lib/units/enemies/cop/logics/CopLogicInactive")
require("lib/units/enemies/cop/logics/CopLogicIdle")
require("lib/units/enemies/cop/logics/CopLogicAttack")
require("lib/units/enemies/cop/logics/CopLogicIntimidated")
require("lib/units/enemies/cop/logics/CopLogicTravel")
require("lib/units/enemies/cop/logics/CopLogicArrest")
require("lib/units/enemies/cop/logics/CopLogicGuard")
require("lib/units/enemies/cop/logics/CopLogicFlee")
require("lib/units/enemies/cop/logics/CopLogicSniper")
require("lib/units/enemies/cop/logics/CopLogicTrade")
require("lib/units/enemies/cop/logics/CopLogicPhalanxMinion")
require("lib/units/enemies/cop/logics/CopLogicPhalanxVip")
require("lib/units/enemies/tank/logics/TankCopLogicAttack")
require("lib/units/enemies/shield/logics/ShieldLogicAttack")
require("lib/units/enemies/spooc/logics/SpoocLogicIdle")
require("lib/units/enemies/spooc/logics/SpoocLogicAttack")
require("lib/units/enemies/taser/logics/TaserLogicAttack")
local old_init = CopBrain.init
local logic_variants = {
	security = {
		idle = CopLogicIdle,
		attack = CopLogicAttack,
		travel = CopLogicTravel,
		inactive = CopLogicInactive,
		intimidated = CopLogicIntimidated,
		arrest = CopLogicArrest,
		guard = CopLogicGuard,
		flee = CopLogicFlee,
		sniper = CopLogicSniper,
		trade = CopLogicTrade,
		phalanx = CopLogicPhalanxMinion
	}
}
local security_variant = logic_variants.security
function CopBrain:init(unit)
	old_init(self, unit)
	CopBrain._logic_variants.deathvox_shield = clone(security_variant)
	CopBrain._logic_variants.deathvox_shield.attack = ShieldLogicAttack
	CopBrain._logic_variants.deathvox_shield.intimidated = nil
	CopBrain._logic_variants.deathvox_shield.flee = nil
	
	CopBrain._logic_variants.deathvox_heavyar = security_variant
	CopBrain._logic_variants.deathvox_lightar = security_variant
	CopBrain._logic_variants.deathvox_medic = security_variant
	CopBrain._logic_variants.deathvox_guard = security_variant
	CopBrain._logic_variants.deathvox_lightshot = security_variant
	CopBrain._logic_variants.deathvox_heavyshot = security_variant
	
	CopBrain._logic_variants.deathvox_taser = clone(security_variant)
	CopBrain._logic_variants.deathvox_taser.attack = TaserLogicAttack
	CopBrain._logic_variants.deathvox_sniper_assault = security_variant
	CopBrain._logic_variants.deathvox_cloaker = clone(security_variant)
	CopBrain._logic_variants.deathvox_cloaker.idle = SpoocLogicIdle
	CopBrain._logic_variants.deathvox_cloaker.attack = SpoocLogicAttack
	CopBrain._logic_variants.deathvox_grenadier = security_variant
	
	CopBrain._logic_variants.deathvox_greendozer = clone(security_variant)
	CopBrain._logic_variants.deathvox_greendozer.attack = TankCopLogicAttack
	CopBrain._logic_variants.deathvox_blackdozer = clone(security_variant)
	CopBrain._logic_variants.deathvox_blackdozer.attack = TankCopLogicAttack
	CopBrain._logic_variants.deathvox_lmgdozer = clone(security_variant)
	CopBrain._logic_variants.deathvox_lmgdozer.attack = TankCopLogicAttack
	CopBrain._logic_variants.deathvox_medicdozer = clone(security_variant)
	CopBrain._logic_variants.deathvox_medicdozer.attack = TankCopLogicAttack
end