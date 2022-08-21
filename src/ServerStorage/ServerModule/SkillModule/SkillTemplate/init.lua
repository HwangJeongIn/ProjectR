-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
--[[
local Utility = ServerModuleFacade.Utility
local ObjectTagUtility = ServerModuleFacade.ObjectTagUtility
local ObjectCollisionGroupUtility = ServerModuleFacade.ObjectCollisionGroupUtility 
--]]

local ServerConstant = ServerModuleFacade.ServerConstant
local DefaultWeaponSkillGameDataKey = ServerConstant.DefaultWeaponSkillGameDataKey
--local DefaultArmorSkillGameDataKey = ServerConstant.DefaultArmorSkillGameDataKey

local ServerEnum = ServerModuleFacade.ServerEnum
local GameDataType = ServerEnum.GameDataType

local SkillDataType = ServerEnum.SkillDataType
local SkillImplType = ServerEnum.SkillImplType
local SkillImplTypeConverter = SkillImplType.Converter
local SkillDataParameterType = ServerEnum.SkillDataParameterType

local ServerGameDataManager = ServerModuleFacade.ServerGameDataManager

local SkillAnimationTemplate = require(script:WaitForChild("SkillAnimationTemplate"))
local SkillEffectTemplate = require(script:WaitForChild("SkillEffectTemplate"))
local SkillImpl = require(script:WaitForChild("SkillImpl"))

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

    if skillDataParameter[SkillDataParameterType.SkillCollisionDirection] then
        if not skillDataParameter[SkillDataParameterType.SkillCollisionSpeed] then
            Debug.Assert(false, "SkillCollisionDirection은 있지만, SkillCollisionSpeed가 없습니다. => " .. skillName)
            return false
        end
    end

    --[[
    if not skillDataParameter[SkillDataParameterType.SkillCollisionDetailMovementType] then
        Debug.Assert(false, "SkillCollisionDetailMovementType이 없습니다. => " .. skillName)
        return false
    end
    --]]

    if not skillDataParameter[SkillDataParameterType.SkillCollisionDuration] then
        skillDataParameter[SkillDataParameterType.SkillCollisionDuration] = 0
    end

    if not skillDataParameter[SkillDataParameterType.SkillAnimation] then
        Debug.Assert(false, "SkillAnimation이 없습니다. => " .. skillName)
        return false
    end

    --[[
    if not skillDataParameter[SkillDataParameterType.SkillDuration] then
        Debug.Assert(false, "SkillDuration이 없습니다. => " .. skillName)
        return false
    end
    --]]

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

function SkillTemplate:InitializeAllSkillTemplates()
    SkillImpl:RegisterAllSkillImpls(self)

    local defaultWeaponSkillGameData = ServerGameDataManager[GameDataType.Skill]:Get(DefaultWeaponSkillGameDataKey)
    Debug.Assert(defaultWeaponSkillGameData, "DefaultWeaponSkillGameDataKey에 해당하는 데이터가 없습니다.")
    self.GetDefaultWeaponSkillGameData = function() return defaultWeaponSkillGameData  end

    local allData = ServerGameDataManager[GameDataType.Skill]:GetAllData()
    for skillGameDataKey, skillGameData in pairs(allData) do
        self.SkillImplTemplateTable[skillGameDataKey] = {}
        local skillName = skillGameData.Name

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


SkillTemplate:InitializeAllSkillTemplates()
return SkillTemplate