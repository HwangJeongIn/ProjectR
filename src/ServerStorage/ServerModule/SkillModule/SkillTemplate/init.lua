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
    self.RawSkillData[skillName][SkillDataType.SkillSequence] = nil
end

function SkillTemplate:GetSkillSequenceFromRawSkillData(skillName)
    if not skillName then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end
    
    if not self.RawSkillData[skillName][SkillDataType.SkillSequence] then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return self.RawSkillData[skillName][SkillDataType.SkillSequence] 
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

function SkillTemplate:RegisterSkillDataParameter(skillName, skillSequence)
    --[[
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

    
    local skillOnDestroyingEffectName = skillDataParameter[SkillDataParameterType.SkillOnDestroyingEffect]
    if skillOnDestroyingEffectName then
        local skillOnDestroyingEffect = SkillEffectTemplate:Get(skillOnDestroyingEffectName)
        if not skillOnDestroyingEffect then
            Debug.Assert(false, "이름을 가진 이펙트가 존재하지 않습니다. => " .. skillOnDestroyingEffectName)
            return false
        end
        skillDataParameter[SkillDataParameterType.SkillOnDestroyingEffect] = skillOnDestroyingEffect
    end
    local skillName = skillDataParameter.SkillName
    --]]

    self.RawSkillData[skillName][SkillDataType.SkillSequence] = skillSequence
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

        self.SkillImplTemplateTable[skillGameDataKey].GetSkillSequence = function(_) 
            return currentSkillTemplate[SkillDataType.SkillSequence]
        end

        self.SkillImplTemplateTable[skillGameDataKey].GetSkillGameData = function(_)
            return skillGameData
        end
    end
    return true
end


SkillTemplate:InitializeAllSkillTemplates()
return SkillTemplate