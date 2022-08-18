-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Utility = ServerModuleFacade.Utility
local ObjectTagUtility = ServerModuleFacade.ObjectTagUtility

local ServerConstant = ServerModuleFacade.ServerConstant
local DefaultWeaponSkillGameDataKey = ServerConstant.DefaultWeaponSkillGameDataKey
--local DefaultArmorSkillGameDataKey = ServerConstant.DefaultArmorSkillGameDataKey


local ServerEnum = ServerModuleFacade.ServerEnum
local GameDataType = ServerEnum.GameDataType
local EquipType = ServerEnum.EquipType
local WorldInteractorType = ServerEnum.WorldInteractorType
local SkillImplType = ServerEnum.SkillImplType
local SkillImplTypeConverter = SkillImplType.Converter

local SkillDataParameterType = ServerEnum.SkillDataParameterType
local SkillDataParameterTypeConverter = SkillDataParameterType.Converter

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage
local ServerGameDataManager = ServerModuleFacade.ServerGameDataManager
local Debug = ServerModuleFacade.Debug

local SkillAnimationTemplate = require(script:WaitForChild("SkillAnimationTemplate"))
local SkillEffectTemplate = require(script:WaitForChild("SkillEffectTemplate"))

local SkillTemplate = { 
    SkillImplTemplateTable = {},
    RawSkillData = {}
}

function SkillTemplate:GetSkillImplTemplateByKey(skillGameDataKey)
    if not self.SkillImplTemplateTable[skillGameDataKey] then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return self.SkillImplTemplateTable[skillGameDataKey]
end

--[[
function SkillTemplate:RegisterSkillName(skillName)
    self.RawSkillData[skillName] = {}
    self.RawSkillData[skillName].SkillCollisionParameter = {}
end
--]]

function SkillTemplate:GetSkillCollisionParameter(skillName, SkillDataParameterType)
    if not skillName or not SkillDataParameterType then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end
    
    if not self.RawSkillData[skillName].SkillCollisionParameter then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return self.RawSkillData[skillName].SkillCollisionParameter[SkillDataParameterType]
end

function SkillTemplate:RegisterSkillCollisionParameter(skillName, SkillDataParameterType, inputValue)
    if not skillName or not SkillDataParameterType then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    local SkillDataParameterTypeString = SkillDataParameterTypeConverter[SkillDataParameterType]
    if not SkillDataParameterTypeString then
        Debug.Assert(false, "비정상입니다. => " .. skillName)
        return false
    end

    if not self.RawSkillData[skillName] then
        self.RawSkillData[skillName] = {}
    end
    
    if not self.RawSkillData[skillName].SkillCollisionParameter then
        self.RawSkillData[skillName].SkillCollisionParameter = {}
    end

    if self.RawSkillData[skillName].SkillCollisionParameter[SkillDataParameterType] then
        Debug.Assert(false, skillName .. "_" .. SkillDataParameterTypeString .. "를 두번 등록하려 합니다.")
        return false
    end

    self.RawSkillData[skillName].SkillCollisionParameter[SkillDataParameterType] = inputValue
    return true
end

function SkillTemplate:GetSkillImpl(skillName, skillImplType)
    if not skillName or not skillImplType then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    if not self.RawSkillData[skillName] then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return self.RawSkillData[skillName][skillImplType]
end

function SkillTemplate:RegisterSkillImpl(skillName, skillImplType, inputFunction)
    if not skillName or not inputFunction then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if "function" ~= type(inputFunction) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    local skillImplString = SkillImplTypeConverter[skillImplType]
    if not skillImplString then
        Debug.Assert(false, "비정상입니다. => " .. skillName)
        return false
    end

    if not self.RawSkillData[skillName] then
        self.RawSkillData[skillName] = {}
    end

    if self.RawSkillData[skillName][skillImplType] then
        Debug.Assert(false, skillName .. "_" .. skillImplString .. "를 두번 등록하려 합니다.")
        return false
    end
    
    self.RawSkillData[skillName][skillImplType] = inputFunction
    return true
end

function SkillTemplate:InitializeAllSkillTemplates()
    local defaultWeaponSkillGameData = ServerGameDataManager[GameDataType.Skill]:Get(DefaultWeaponSkillGameDataKey)
    Debug.Assert(defaultWeaponSkillGameData, "DefaultWeaponSkillGameDataKey에 해당하는 데이터가 없습니다.")
    self.GetDefaultWeaponSkillGameData = function() return defaultWeaponSkillGameData  end

    local allData = ServerGameDataManager[GameDataType.Skill]:GetAllData()
    for skillGameDataKey, skillGameData in pairs(allData) do
        self.SkillImplTemplateTable[skillGameDataKey] = {}
        local skillName = skillGameData.Name

        -- 파라미터에 따라서 GetSkillCollisionParameter 자동 등록
        local skillCollisionSize = self:GetSkillCollisionParameter(skillName, SkillDataParameterType.SkillCollisionSize)
        Debug.Assert(skillCollisionSize, "비정상입니다.")

        local skillCollisionOffset = self:GetSkillCollisionParameter(skillName, SkillDataParameterType.SkillCollisionOffset)
        Debug.Assert(skillCollisionOffset, "비정상입니다.")

        self:RegisterSkillImpl(skillName,
            SkillImplType.GetSkillCollisionParameter,
            function(skillController, toolOwnerPlayerCFrame)
                local skillCollisionParameter = {}

                local finalOffsetVector = toolOwnerPlayerCFrame.LookVector * skillCollisionOffset.X 
                + toolOwnerPlayerCFrame.RightVector * skillCollisionOffset.Y
                skillCollisionParameter.Size = skillCollisionSize
                skillCollisionParameter.CFrame = toolOwnerPlayerCFrame + finalOffsetVector
                return skillCollisionParameter
            end)

        local lastSkillImplIndex = (SkillImplType.Count - 1)
        for skillImplIndex = 1, lastSkillImplIndex do
            local skillImplFunction = self:GetSkillImpl(skillName, skillImplIndex)

            if not skillImplFunction then
                local skillImplString = SkillImplTypeConverter[skillImplIndex]
                local tempSkillImplFunctionName = skillName .. "_" .. skillImplString
                Debug.Assert(false, tempSkillImplFunctionName .. "가 정의되어 있지 않습니다.")
                return false
            end

            self.SkillImplTemplateTable[skillGameDataKey][skillImplIndex] = skillImplFunction
        end
    end
    return true
end


--1, Name = "BaseAttack"

-- 데이터 로드해서 받아올 수 있도록 수정하면 좋을듯
local SkillData = 
{
    [SkillDataParameterType.SkillCollisionSize] = 1,
    [SkillDataParameterType.SkillCollisionOffset] = 1,


}
SkillTemplate:RegisterSkillCollisionParameter(
    "BaseAttack",
    SkillDataParameterType.SkillCollisionSize,
    Vector3.new(2, 2, 2)
)

SkillTemplate:RegisterSkillCollisionParameter(
    "BaseAttack",
    SkillDataParameterType.SkillCollisionOffset,
    Vector2.new(5, 0)
)

SkillTemplate:RegisterSkillImpl(
    "BaseAttack",
    SkillImplType.UseSkill,
    function(skillController, toolOwnerPlayer)
        
        return true
    end
)

SkillTemplate:RegisterSkillImpl(
    "BaseAttack",
    SkillImplType.FindTargetsInRange,
    function(skillController, toolOwnerPlayer, filteredTargets)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return nil
    end
)

SkillTemplate:RegisterSkillImpl(
    "BaseAttack",
    SkillImplType.ApplySkillToTarget,
    function(skillController, toolOwnerPlayer, target)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return false
    end
)


--2, Name = "WhirlwindSlash"
SkillTemplate:RegisterSkillCollisionParameter(
    "WhirlwindSlash",
    SkillDataParameterType.SkillCollisionSize,
    Vector3.new(2, 2, 2)
)

SkillTemplate:RegisterSkillCollisionParameter(
    "WhirlwindSlash",
    SkillDataParameterType.SkillCollisionOffset,
    Vector2.new(5, 0)
)

SkillTemplate:RegisterSkillImpl(
    "WhirlwindSlash",
    SkillImplType.UseSkill,
    function(skillController, toolOwnerPlayer)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return false
    end
)

SkillTemplate:RegisterSkillImpl(
    "WhirlwindSlash",
    SkillImplType.FindTargetsInRange,
    function(skillController, toolOwnerPlayer, filteredTargets)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return nil
    end
)

SkillTemplate:RegisterSkillImpl(
    "WhirlwindSlash",
    SkillImplType.ApplySkillToTarget,
    function(skillController, toolOwnerPlayer, target)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return false
    end
)


--3, Name = "TempestSlash"
SkillTemplate:RegisterSkillCollisionParameter(
    "TempestSlash",
    SkillDataParameterType.SkillCollisionSize,
    Vector3.new(2, 2, 2)
)

SkillTemplate:RegisterSkillCollisionParameter(
    "TempestSlash",
    SkillDataParameterType.SkillCollisionOffset,
    Vector2.new(5, 0)
)

SkillTemplate:RegisterSkillImpl(
    "TempestSlash",
    SkillImplType.UseSkill,
    function(skillController, toolOwnerPlayer)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return false
    end
)

SkillTemplate:RegisterSkillImpl(
    "TempestSlash",
    SkillImplType.FindTargetsInRange,
    function(skillController, toolOwnerPlayer, filteredTargets)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return nil
    end
)

SkillTemplate:RegisterSkillImpl(
    "TempestSlash",
    SkillImplType.ApplySkillToTarget,
    
    function(skillController, toolOwnerPlayer, target)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return false
    end
)


--4, Name = "PowerStrike"
SkillTemplate:RegisterSkillCollisionParameter(
    "PowerStrike",
    SkillDataParameterType.SkillCollisionSize,
    Vector3.new(2, 2, 2)
)

SkillTemplate:RegisterSkillCollisionParameter(
    "PowerStrike",
    SkillDataParameterType.SkillCollisionOffset,
    Vector2.new(5, 0)
)

SkillTemplate:RegisterSkillImpl(
    "PowerStrike",
    SkillImplType.UseSkill,
    function(skillController, toolOwnerPlayer)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return false
    end
)

SkillTemplate:RegisterSkillImpl(
    "PowerStrike",
    SkillImplType.FindTargetsInRange,
    function(skillController, toolOwnerPlayer, filteredTargets)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return nil
    end
)

SkillTemplate:RegisterSkillImpl(
    "PowerStrike",
    SkillImplType.ApplySkillToTarget,
    function(skillController, toolOwnerPlayer, target)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return false
    end
)


--5, Name = "StormBlade"
SkillTemplate:RegisterSkillCollisionParameter(
    "StormBlade",
    SkillDataParameterType.SkillCollisionSize,
    Vector3.new(2, 2, 2)
)

SkillTemplate:RegisterSkillCollisionParameter(
    "StormBlade",
    SkillDataParameterType.SkillCollisionOffset,
    Vector2.new(5, 0)
)

SkillTemplate:RegisterSkillImpl(
    "StormBlade",
    SkillImplType.UseSkill,
    function(skillController, toolOwnerPlayer)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return false
    end
)

SkillTemplate:RegisterSkillImpl(
    "StormBlade",
    SkillImplType.FindTargetsInRange,
    function(skillController, toolOwnerPlayer, filteredTargets)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return nil
    end
)

SkillTemplate:RegisterSkillImpl(
    "StormBlade",
    SkillImplType.ApplySkillToTarget,
    function(skillController, toolOwnerPlayer, target)
        Debug.Assert(false, "상위에서 구현해야합니다.")
        return false
    end
)


SkillTemplate:InitializeAllSkillTemplates()
return SkillTemplate