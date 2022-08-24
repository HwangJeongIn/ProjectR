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


local SkillCollisionParameterType = ServerEnum.SkillCollisionParameterType
local SkillCollisionParameterTypeConverter = SkillCollisionParameterType.Converter
local SkillCollisionSequenceTrackParameterType = ServerEnum.SkillCollisionSequenceTrackParameterType
local SkillCollisionSequenceTrackParameterTypeConverter = SkillCollisionSequenceTrackParameterType.Converter


local ServerGameDataManager = ServerModuleFacade.ServerGameDataManager

local SkillAnimationTemplate = require(script:WaitForChild("SkillAnimationTemplate"))
local SkillEffectTemplate = require(script:WaitForChild("SkillEffectTemplate"))
local SkillImpl = require(script:WaitForChild("SkillImpl"))

local SkillCollisionSequence = {
    Collision = {},
    CollisionSequenceTracks = {},
    CollisionSequenceTrackCount = 0
}

function SkillCollisionSequence:ValidateSkillCollisionParameter(skillCollisionParameter)
    if not skillCollisionParameter[SkillCollisionParameterType.SkillCollisionSize] then
        Debug.Assert(false, "SkillCollisionSize 가 없습니다.")
        return false
    end

    if not skillCollisionParameter[SkillCollisionParameterType.SkillCollisionOffset] then
        Debug.Assert(false, "SkillCollisionOffset 가 없습니다.")
        return false
    end
    
    if not skillCollisionParameter[SkillCollisionParameterType.SkillCollisionEffect] then
        Debug.Assert(false, "SkillCollisionEffect 가 없습니다.")
        return false
    end
    
    if not skillCollisionParameter[SkillCollisionParameterType.SkillCollisionOnDestroyingEffect] then
        Debug.Assert(false, "SkillCollisionOnDestroyingEffect 가 없습니다.")
        return false
    end

    return true
end

function SkillCollisionSequence:InitializeSkillCollision(skillCollisionParameter)
    --[[ 예시
    SkillCollisionSequence:InitializeSkillCollision({
        [SkillCollisionParameterType.SkillCollisionSize] = Vector3.new(2, 2, 2),
        [SkillCollisionParameterType.SkillCollisionOffset] = Vector3.new(5, 0, 0), -- look, right, up
        [SkillCollisionParameterType.SkillCollisionEffect] = "SwordSlashEffect",
        [SkillCollisionParameterType.SkillCollisionOnDestroyingEffect] = "HitEffect"
    })
    --]]

    if not self:ValidateSkillCollisionParameter(skillCollisionParameter) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    local skillCollisionEffectName = skillCollisionParameter[SkillCollisionParameterType.SkillCollisionEffect]
    local skillCollisionEffect = SkillEffectTemplate:Get(skillCollisionEffectName)
    if not skillCollisionEffect then
        Debug.Assert(false, "해당 이름을 가진 이펙트가 존재하지 않습니다. => " .. skillCollisionEffect)
        return false
    end
    skillCollisionParameter[SkillCollisionParameterType.SkillCollisionEffect] = skillCollisionEffect

    local skillCollisionOnDestroyingEffectName = skillCollisionParameter[SkillCollisionParameterType.SkillCollisionOnDestroyingEffect]
    local skillCollisionOnDestroyingEffect = SkillEffectTemplate:Get(skillCollisionOnDestroyingEffectName)
    if not skillCollisionOnDestroyingEffect then
        Debug.Assert(false, "해당 이름을 가진 이펙트가 존재하지 않습니다. => " .. skillCollisionOnDestroyingEffect)
        return false
    end
    skillCollisionParameter[SkillCollisionParameterType.SkillCollisionOnDestroyingEffect] = skillCollisionOnDestroyingEffect

    self.Collision = skillCollisionParameter
    return true
end

function SkillCollisionSequence:ValidateSkillCollisionSequenceTrackParameter(skillCollisionSequenceTrackParameter)
    if not skillCollisionSequenceTrackParameter[SkillCollisionSequenceTrackParameterType.SkillCollisionDirection] then
        Debug.Assert(false, "SkillCollisionDirection 가 없습니다.")
        return false
    end

    if not skillCollisionSequenceTrackParameter[SkillCollisionSequenceTrackParameterType.SkillCollisionSpeed] then
        Debug.Assert(false, "SkillCollisionSpeed 가 없습니다.")
        return false
    end
    
    local skillCollisionSequenceTrackDuration = skillCollisionSequenceTrackParameter[SkillCollisionSequenceTrackParameterType.SkillCollisionSequenceTrackDuration]
    if not skillCollisionSequenceTrackDuration then
        Debug.Assert(false, "SkillCollisionSequenceTrackDuration 가 없습니다.")
        return false
    end

    if 0 >= skillCollisionSequenceTrackDuration then
        Debug.Assert(false, "SkillCollisionSequenceTrackDuration 이 0보다 작거나 같습니다.")
        return false
    end

    return true
end

function SkillCollisionSequence:AddTrack(skillCollisionSequenceTrackParameter)
    --[[ 예시
    SkillCollisionSequence:AddTrack({
        [skillCollisionSequenceTrackParameter.SkillCollisionDirection] = Vector3.new(1, 0, 0), -- look, right, up
        [skillCollisionSequenceTrackParameter.SkillCollisionSpeed] = DefaultSkillCollisionSpeed,
        [skillCollisionSequenceTrackParameter.SkillCollisionSequenceTrackDuration] = 1,
    })
    --]]

    if not self:ValidateSkillCollisionSequenceTrackParameter(skillCollisionSequenceTrackParameter) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    skillCollisionSequenceTrackParameter.GetData = function(collisionSequenceTrack, skillCollisionSequenceTrackParameterType)
        return collisionSequenceTrack[skillCollisionSequenceTrackParameterType]
    end

    table.insert(self.CollisionSequenceTracks, skillCollisionSequenceTrackParameter)
    self.CollisionSequenceTrackCount += 1
    return true
end

function SkillCollisionSequence:IsValid()
    return 0 ~= self.CollisionSequenceTrackCount
end

function SkillCollisionSequence:GetTrackCount()
    return self.CollisionSequenceTrackCount
end

function SkillCollisionSequence:GetTrack(trackIndex)
    if 0 >= trackIndex or self.CollisionSequenceTrackCount < trackIndex then
        Debug.Assert(false, "트랙인덱스가 비정상입니다.")
        return nil
    end

    return self.CollisionSequenceTracks[trackIndex]
end

function SkillCollisionSequence:GetTrackData(trackIndex, skillCollisionSequenceTrackParameterType)
    if not SkillCollisionSequenceTrackParameterTypeConverter[skillCollisionSequenceTrackParameterType] then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    local targetTrack = self:GetTrack(trackIndex)
    if not targetTrack then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return targetTrack[skillCollisionSequenceTrackParameterType]
end

function SkillCollisionSequence:GetCollisionData(skillCollisionParameterType)
    if not SkillCollisionParameterTypeConverter[skillCollisionParameterType] then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return self.Collision[skillCollisionParameterType]
end


return SkillCollisionSequence