-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local Utility = ServerModuleFacade.Utility
local ObjectTagUtility = ServerModuleFacade.ObjectTagUtility
local ObjectCollisionGroupUtility = ServerModuleFacade.ObjectCollisionGroupUtility

local NpcUtility = ServerModuleFacade.NpcUtility


local ServerConstant = ServerModuleFacade.ServerConstant
local DefaultWeaponSkillGameDataKey = ServerConstant.DefaultWeaponSkillGameDataKey
--local DefaultArmorSkillGameDataKey = ServerConstant.DefaultArmorSkillGameDataKey
local DefaultSkillCollisionSpeed = ServerConstant.DefaultSkillCollisionSpeed


local ServerEnum = ServerModuleFacade.ServerEnum
--[[
local GameDataType = ServerEnum.GameDataType
local CollisionGroupType = ServerEnum.CollisionGroupType

local SkillDataType = ServerEnum.SkillDataType
local EquipType = ServerEnum.EquipType
local WorldInteractorType = ServerEnum.WorldInteractorType
local SkillSequenceType = ServerEnum.SkillSequenceType
local SkillSequenceTypeConverter = SkillSequenceType.Converter
local SkillDataParameterType = ServerEnum.SkillDataParameterType
local SkillDataParameterTypeConverter = SkillDataParameterType.Converter

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage
local ServerGameDataManager = ServerModuleFacade.ServerGameDataManager

local SkillModule = ServerModuleFacade.SkillModule
local DamageCalculator = require(SkillModule:WaitForChild("DamageCalculator"))
--]]

local SkillAnimationTemplate = require(script.Parent:WaitForChild("SkillAnimationTemplate"))
local SkillEffectTemplate = require(script.Parent:WaitForChild("SkillEffectTemplate"))
local SkillSequenceAnimationTrack = require(script.Parent:WaitForChild("SkillSequenceAnimationTrack"))


local SkillSequence = {
    SkillSequenceAnimationTracks = {},
    SkillSequenceAnimationTrackCount = 0
}

function SkillSequence:InitializeSkillSequence()
    --[[
    SkillCollisionSequence:InitializeSkillCollision({
        [SkillCollisionParameterType.SkillCollisionSize] = Vector3.new(2, 2, 2),
        [SkillCollisionParameterType.SkillCollisionOffset] = Vector3.new(5, 0, 0), -- look, right, up
        [SkillCollisionParameterType.SkillCollisionEffect] = "SwordSlashEffect",
        [SkillCollisionParameterType.SkillCollisionOnDestroyingEffect] = "HitEffect"
    })
    --]]
end

function SkillSequence:GetSkillSequenceAnimationTrackCount()
    return self.SkillSequenceAnimationTrackCount
end


function SkillSequence:GetSkillSequenceAnimationTrack(skillSequenceAnimationTrackIndex)
    if not skillSequenceAnimationTrackIndex 
    or 0 > skillSequenceAnimationTrackIndex 
    or self.SkillSequenceAnimationTrackCount < skillSequenceAnimationTrackIndex then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return self.SkillSequenceAnimationTracks[skillSequenceAnimationTrackIndex]
end

function SkillSequence:AddSkillSequenceAnimationTrack(skillSequenceAnimationName, skillSequenceAnimationDuration)
    if not skillSequenceAnimationName or not skillSequenceAnimationDuration then
        Debug.Assert(false, "비정상입니다.")
        return 0
    end

    local skillSequenceAnimationWrapper = SkillAnimationTemplate:Get(skillSequenceAnimationName)
    if not skillSequenceAnimationWrapper then
        Debug.Assert(false, "애니메이션이 존재하지 않습니다. => " .. skillSequenceAnimationName)
        return 0
    end

    self.SkillSequenceAnimationTrackCount += 1
    local skillSequenceAnimationTrack = Utility:DeepCopy(SkillSequenceAnimationTrack)
    skillSequenceAnimationTrack:Initialize(skillSequenceAnimationWrapper, skillSequenceAnimationDuration)
    table.insert(self.SkillSequenceAnimationTracks, skillSequenceAnimationTrack)
    return self.SkillSequenceAnimationTrackCount
end

-- 빨리 나오는 순서대로 삽입하도록 강제한다.
function SkillSequence:AddSkillCollisionSequenceToSkillSequenceAnimationTrack(animationTrackIndex, skillCollisionFireTimeRate, skillCollisionSequence)
    local targetAnimationTrack = self:GetSkillSequenceAnimationTrack(animationTrackIndex)
    if not targetAnimationTrack then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if not targetAnimationTrack:AddSkillCollisionSequence(skillCollisionFireTimeRate, skillCollisionSequence) then
        Debug.Assert(false, "SkillCollisionSequence의 시작 순서대로 넣어주세요. 가능한 값은 0 ~ 1입니다.")
        return false
    end

    return true
end


return SkillSequence