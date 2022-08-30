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

--[[
local EmptyStatistic = {
    
	[StatType.STR] = 0,
	[StatType.DEF] = 0,
	[StatType.Move] = 0,
	[StatType.Jump] = 0,
	[StatType.AttackSpeed] = 0,
	
	[StatType.Hp] = 0,
	[StatType.Mp] = 0,
	[StatType.Hit] = 0,
	[StatType.Dodge] = 0,
	[StatType.Block] = 0,
	[StatType.Critical] = 0,
	[StatType.Sight] = 0
}
Debug.Assert(StatType.Count == #EmptyStatistic + 1, "여기도 갱신해야합니다.")
--]]

function DamageCalculator:CalculateDamage(attackerSTR, attackeeDEF)
    local finalDamage = attackerSTR / (attackeeDEF + DamageCalculationConstant / DamageCalculationConstant)
    return finalDamage
end

function DamageCalculator:CalculateSkillDamage(skillFactor, attackerStatisticRaw, attackeeStatisticRaw)
    if not skillFactor or not attackerStatisticRaw or not attackeeStatisticRaw then
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
    if attackerStatisticRaw[StatType.STR] then
        attackerSTR = attackerStatisticRaw[StatType.STR]
    end
    attackerSTR = attackRate * attackerSTR

    local attackeeDEF = DefaultDEF
    if attackeeStatisticRaw[StatType.DEF] then
        attackeeDEF = attackeeStatisticRaw[StatType.DEF]
    end
    attackeeDEF = defenseRate * attackeeDEF

    local finalDamge = self:CalculateDamage(attackerSTR, attackeeDEF)
    finalDamge = finalDamge / 100
    return finalDamge
end

function DamageCalculator:CalculateWorldInteractorSkillDamage(skillFactor, attackerStatisticRaw)
    -- 무기에 상관없이 1고정 데미지
    return 1
    --return self:CalculateSkillDamage(skillFactor, attackerStatisticRaw, {})
end

return DamageCalculator