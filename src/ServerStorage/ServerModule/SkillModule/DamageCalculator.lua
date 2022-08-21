local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug


local ServerConstant = ServerModuleFacade.ServerConstant
local DamageCalculationConstant = ServerConstant.DamageCalculationConstant
local DefualtAttackRate = ServerConstant.DefualtAttackRate
local DefaultDefenseRate = ServerConstant.DefaultDefenseRate
local DefaultAttackSpeedRate = ServerConstant.DefaultAttackSpeedRate
local DefaultMoveRate = ServerConstant.DefaultMoveRate

local DefaultSTR = ServerConstant.DefaultSTR
local DefaultDEF = ServerConstant.DefaultDEF


local ServerEnum = ServerModuleFacade.ServerEnum
local StatType = ServerEnum.StatType
local SkillFactorType = ServerEnum.SkillFactorType

local DamageCalculator = {}

local EmptyStatistic = {
    --[[
	[StatType.STR] = 0,
	[StatType.DEF] = 0,
	[StatType.Move] = 0,
	[StatType.AttackSpeed] = 0,
	
	[StatType.HP] = 0,
	[StatType.MP] = 0,
	[StatType.HIT] = 0,
	[StatType.Dodge] = 0,
	[StatType.Block] = 0,
	[StatType.Critical] = 0,
	[StatType.Sight] = 0
    --]]
}
Debug.Assert(StatType.Count == #EmptyStatistic + 1, "여기도 갱신해야합니다.")


function DamageCalculator:CalculateDamage(attackerSTR, attackeeDEF)
    local finalDamage = attackerSTR / (attackeeDEF + DamageCalculationConstant / DamageCalculationConstant)
    return finalDamage
end

function DamageCalculator:CalculateSkillDamage(skillFactor, attackerRawStatistic, attackeeRawStatistic)
    if not skillFactor or not attackerRawStatistic or not attackeeRawStatistic then
        Debug.Assert(false, "비정상입니다.")
        return 0
    end
    
    -- AttackRate / DefenseRate
    local attackRate = DefualtAttackRate
    if skillFactor[SkillFactorType.AttackRate] then
        attackRate = skillFactor[SkillFactorType.AttackRate]
    end

    local defenseRate = DefaultDefenseRate
    if skillFactor[SkillFactorType.DefenseRate] then
        defenseRate = skillFactor[SkillFactorType.DefenseRate]
    end

    -- AttackerSTR / AttackeeDEF
    local attackerSTR = DefaultSTR
    if attackerRawStatistic[StatType.STR] then
        attackerSTR = attackerRawStatistic[StatType.STR]
    end
    attackerSTR = attackRate * attackerSTR

    local attackeeDEF = DefaultDEF
    if attackeeRawStatistic[StatType.DEF] then
        attackeeDEF = attackeeRawStatistic[StatType.DEF]
    end
    attackeeDEF = defenseRate * attackeeDEF

    local finalDamge = self:CalculateDamage(attackerSTR, attackeeDEF)
    return finalDamge
end

function DamageCalculator:CalculateWorldInteractorSkillDamage(skillFactor, attackerRawStatistic)
    return self:CalculateSkillDamage(skillFactor, attackerRawStatistic, {})
end

return DamageCalculator