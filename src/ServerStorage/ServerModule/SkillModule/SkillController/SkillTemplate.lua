-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Utility = ServerModuleFacade.Utility
local ObjectTagUtility = ServerModuleFacade.ObjectTagUtility

local ServerEnum = ServerModuleFacade.ServerEnum
local GameDataType = ServerEnum.GameDataType
local EquipType = ServerEnum.EquipType
local WorldInteractorType = ServerEnum.WorldInteractorType

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage
local GameDataManager = ServerModuleFacade.GameDataManager
local Debug = ServerModuleFacade.Debug

local ObjectModule = ServerModuleFacade.ObjectModule

local SkillTemplate = { SkillTemplateTable = {} }

function SkillTemplate:GetSkillTemplateByKey(skillGameDataKey)
    if not self.SkillTemplateTable[skillGameDataKey] then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return self.SkillTemplateTable[skillGameDataKey]
end

function SkillTemplate:RegisterSkillTemplate(skillGameDataKey, 
    UseSkillFunction, FindTargetsInRangeFunction, ApplySkillToTargetFunction)

    if "function" ~= type(UseSkillFunction) 
    or "function" ~= type(FindTargetsInRangeFunction) 
    or "function" ~= type(ApplySkillToTargetFunction) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    self.SkillTemplateTable[skillGameDataKey] = {
        UseSkill = UseSkillFunction,
        FindTargetsInRange = FindTargetsInRangeFunction,
        ApplySkillToTarget = ApplySkillToTargetFunction
    }

    return true
end

function SkillTemplate:InitializeAllTemplates()
    local allData = GameDataManager[GameDataType.Skill]:GetAllData()

    local UseSkillName = nil
    local FindTargetsInRangeName = nil
    local ApplySkillToTargetName = nil

    local UseSkill = nil
    local FindTargetsInRange = nil
    local ApplySkillToTarget = nil

    for skillGameDataKey, skillGameData in pairs(allData) do
        local skillName = skillGameData

        UseSkillName = skillName .. "_" .. "UseSkill"
        FindTargetsInRangeName = skillName .. "_" .. "FindTargetsInRange"
        ApplySkillToTargetName = skillName .. "_" .. "UseSkillApplySkillToTarget"

        if not self[UseSkillName] then
            Debug.Assert(false, UseSkillName .. "가 정의되어 있지 않습니다.")
        end
        UseSkill = self[UseSkillName]
        self[UseSkillName] = nil

        if not self[FindTargetsInRangeName] then
            Debug.Assert(false, FindTargetsInRangeName .. "가 정의되어 있지 않습니다.")
        end
        FindTargetsInRange = self[FindTargetsInRangeName]
        self[FindTargetsInRangeName] = nil

        if not self[ApplySkillToTargetName] then
            Debug.Assert(false, ApplySkillToTargetName .. "가 정의되어 있지 않습니다.")
        end
        ApplySkillToTarget = self[ApplySkillToTargetName]
        self[ApplySkillToTargetName] = nil
        
        if not self:RegisterSkillTemplate(skillGameDataKey, UseSkill, FindTargetsInRange, ApplySkillToTarget) then
            Debug.Assert(false, "RegisterSkillTemplate에 실패했습니다. [Key] => " .. tostring(skillGameDataKey))
            return false
        end
    end

    return true
end




--1, Name = "BaseAttack"
function SkillTemplate:BaseAttack_UseSkill(skill, toolOwner)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return false
end

function SkillTemplate:BaseAttack_FindTargetsInRange(skill, toolOwner, filteredTargets)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return nil
end

function SkillTemplate:BaseAttack_ApplySkillToTarget(skill, toolOwner, target)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return false
end


--2, Name = "WhirlwindSlash"
function SkillTemplate:WhirlwindSlash_UseSkill(skill, toolOwner)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return false
end

function SkillTemplate:WhirlwindSlash_FindTargetsInRange(skill, toolOwner, filteredTargets)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return nil
end

function SkillTemplate:WhirlwindSlash_ApplySkillToTarget(skill, toolOwner, target)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return false
end


--3, Name = "TempestSlash"
function SkillTemplate:TempestSlash_UseSkill(skill, toolOwner)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return false
end

function SkillTemplate:TempestSlash_FindTargetsInRange(skill, toolOwner, filteredTargets)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return nil
end

function SkillTemplate:TempestSlash_ApplySkillToTarget(skill, toolOwner, target)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return false
end


--4, Name = "PowerStrike"
function SkillTemplate:PowerStrike_UseSkill(skill, toolOwner)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return false
end

function SkillTemplate:PowerStrike_FindTargetsInRange(skill, toolOwner, filteredTargets)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return nil
end

function SkillTemplate:PowerStrike_ApplySkillToTarget(skill, toolOwner, target)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return false
end


--5, Name = "StormBlade"
function SkillTemplate:StormBlade_UseSkill(skill, toolOwner)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return false
end

function SkillTemplate:StormBlade_FindTargetsInRange(skill, toolOwner, filteredTargets)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return nil
end

function SkillTemplate:StormBlade_ApplySkillToTarget(skill, toolOwner, target)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return false
end


SkillTemplate:InitializeAllTemplates()
return SkillTemplate