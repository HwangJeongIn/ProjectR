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

local SkillDataType = ServerEnum.SkillDataType
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

function SkillTemplate:GetSkillTemplateByKey(skillGameDataKey)
    if not self.SkillImplTemplateTable[skillGameDataKey] then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return self.SkillImplTemplateTable[skillGameDataKey]
end

function SkillTemplate:RegisterSkillName(skillName)
    self.RawSkillData[skillName] = {}
    self.RawSkillData[skillName][SkillDataType.SkillImpl] = {}
    self.RawSkillData[skillName][SkillDataType.SkillDataParameter] = {}
end

function SkillTemplate:ValidateSkillDataParameter(skillDataParameter)
    local skillName = skillDataParameter.SkillName
    if not skillDataParameter.SkillName then
        Debug.Assert(false, "SkillName이 없습니다.")
        return false
    end

    if not skillDataParameter[SkillDataParameterType.SkillCollisionSize] then
        Debug.Assert(false, "SkillCollisionSize가 없습니다. => " .. skillName)
        return false
    end

    if not skillDataParameter[SkillDataParameterType.SkillCollisionOffset] then
        Debug.Assert(false, "SkillCollisionOffset이 없습니다. => " .. skillName)
        return false
    end

    if not skillDataParameter[SkillDataParameterType.SkillAnimation] then
        Debug.Assert(false, "SkillAnimation이 없습니다. => " .. skillName)
        return false
    end
    
    if not skillDataParameter[SkillDataParameterType.SkillEffect] then
        Debug.Assert(false, "SkillEffect가 없습니다. => " .. skillName)
        return false
    end

    return true
end

function SkillTemplate:GetSkillDataParameterFromRawSkillData(skillName, SkillDataParameterType)
    if not skillName or not SkillDataParameterType then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end
    
    if not self.RawSkillData[skillName][SkillDataType.SkillDataParameter] then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return self.RawSkillData[skillName][SkillDataType.SkillDataParameter][SkillDataParameterType]
end

function SkillTemplate:RegisterSkillDataParameter(skillDataParameter)
    if not self:ValidateSkillDataParameter(skillDataParameter) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    local skillAnimationName = skillDataParameter[SkillDataParameterType.SkillAnimation]
    local skillAnimation = SkillAnimationTemplate:Get(skillAnimationName)
    if not skillAnimation then
        Debug.Assert(false, "이름을 가진 애니메이션이 존재하지 않습니다. => " .. skillAnimationName)
        return false
    end
    skillDataParameter[SkillDataParameterType.SkillAnimation] = skillAnimation

    local skillEffectName = skillDataParameter[SkillDataParameterType.SkillEffect]
    local skillEffect = SkillEffectTemplate:Get(skillEffectName)
    if not skillEffect then
        Debug.Assert(false, "이름을 가진 이펙트가 존재하지 않습니다. => " .. skillEffectName)
        return false
    end
    skillDataParameter[SkillDataParameterType.SkillEffect] = skillEffect

    local skillName = skillDataParameter.SkillName
    self.RawSkillData[skillName][SkillDataType.SkillDataParameter] = skillDataParameter
    return true
end

function SkillTemplate:GetSkillImplFromRawSkillData(skillName, skillImplType)
    if not skillName or not skillImplType then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    if not self.RawSkillData[skillName][SkillDataType.SkillImpl] then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return self.RawSkillData[skillName][SkillDataType.SkillImpl][skillImplType]
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

    if self.RawSkillData[skillName][SkillDataType.SkillImpl][skillImplType] then
        Debug.Assert(false, skillName .. "_" .. skillImplString .. "를 두번 등록하려 합니다.")
        return false
    end
    
    self.RawSkillData[skillName][SkillDataType.SkillImpl][skillImplType] = inputFunction
    return true
end

function SkillTemplate:ValidateSkillTemplate(skillName)
    local lastSkillImplIndex = (SkillImplType.Count - 1)
    for skillImplIndex = 1, lastSkillImplIndex do
        local skillImplFunction = self:GetSkillImplFromRawSkillData(skillName, skillImplIndex)

        if not skillImplFunction then
            local skillImplString = SkillImplTypeConverter[skillImplIndex]
            local tempSkillImplFunctionName = skillName .. "_" .. skillImplString
            Debug.Assert(false, tempSkillImplFunctionName .. "가 정의되어 있지 않습니다.")
            return false
        end
    end

    return true
end

function SkillTemplate:InitializeAdditionalData(skillName)
    local skillCollisionSize = self:GetSkillDataParameterFromRawSkillData(skillName, SkillDataParameterType.SkillCollisionSize)
    if not skillCollisionSize then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    local skillCollisionOffset = self:GetSkillDataParameterFromRawSkillData(skillName, SkillDataParameterType.SkillCollisionOffset)
    if not skillCollisionOffset then
        Debug.Assert(false, "비정상입니다.")
        return false
    end
    

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

        if not self:InitializeAdditionalData(skillName) then
            Debug.Assert(false, "비정상입니다.")
            return false
        end

        if not self:ValidateSkillTemplate(skillName) then
            Debug.Assert(false, "비정상입니다.")
            return false
        end

        self.SkillImplTemplateTable[skillGameDataKey] = self.RawSkillData[skillName]
        local currentSkillTemplate = self.SkillImplTemplateTable[skillGameDataKey]
        
        self.SkillImplTemplateTable[skillGameDataKey].GetSkillImpl = function(_, skillImplType) 
            return currentSkillTemplate[SkillDataType.SkillImpl][skillImplType] 
        end

        self.SkillImplTemplateTable[skillGameDataKey].GetSkillDataParameter = function(_, skillDataParameterType) 
            return currentSkillTemplate[SkillDataType.SkillDataParameter][skillDataParameterType] 
        end

        self.SkillImplTemplateTable[skillGameDataKey].GetSkillGameData = function(_)
            return skillGameData
        end
    end
    return true
end


--1, Name = "BaseAttack"
SkillTemplate:RegisterSkillName("BaseAttack")

-- 데이터 로드해서 받아올 수 있도록 수정하면 좋을듯
SkillTemplate:RegisterSkillDataParameter({
    SkillName = "BaseAttack",
    [SkillDataParameterType.SkillCollisionSize] = Vector3.new(2, 2, 2),
    [SkillDataParameterType.SkillCollisionOffset] = Vector2.new(5, 0),
    [SkillDataParameterType.SkillAnimation] = "LeftSlash",
    [SkillDataParameterType.SkillEffect] = "SwordSlashEffect",
})

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
SkillTemplate:RegisterSkillName("WhirlwindSlash")

SkillTemplate:RegisterSkillDataParameter({
    SkillName = "WhirlwindSlash",
    [SkillDataParameterType.SkillCollisionSize] = Vector3.new(2, 2, 2),
    [SkillDataParameterType.SkillCollisionOffset] = Vector2.new(5, 0),
    [SkillDataParameterType.SkillAnimation] = "LeftSlash",
    [SkillDataParameterType.SkillEffect] = "SwordSlashEffect",
})

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
SkillTemplate:RegisterSkillName("TempestSlash")

SkillTemplate:RegisterSkillDataParameter({
    SkillName = "TempestSlash",
    [SkillDataParameterType.SkillCollisionSize] = Vector3.new(2, 2, 2),
    [SkillDataParameterType.SkillCollisionOffset] = Vector2.new(5, 0),
    [SkillDataParameterType.SkillAnimation] = "LeftSlash",
    [SkillDataParameterType.SkillEffect] = "SwordSlashEffect",
})


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
SkillTemplate:RegisterSkillName("PowerStrike")

SkillTemplate:RegisterSkillDataParameter({
    SkillName = "PowerStrike",
    [SkillDataParameterType.SkillCollisionSize] = Vector3.new(2, 2, 2),
    [SkillDataParameterType.SkillCollisionOffset] = Vector2.new(5, 0),
    [SkillDataParameterType.SkillAnimation] = "LeftSlash",
    [SkillDataParameterType.SkillEffect] = "SwordSlashEffect",
})

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
SkillTemplate:RegisterSkillName("StormBlade")

SkillTemplate:RegisterSkillDataParameter({
    SkillName = "StormBlade",
    [SkillDataParameterType.SkillCollisionSize] = Vector3.new(2, 2, 2),
    [SkillDataParameterType.SkillCollisionOffset] = Vector2.new(5, 0),
    [SkillDataParameterType.SkillAnimation] = "LeftSlash",
    [SkillDataParameterType.SkillEffect] = "SwordSlashEffect",
})

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