local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug

local ServerEnum = ServerModuleFacade.ServerEnum
local SkillCollisionSequenceTrackParameterType = ServerEnum.SkillCollisionSequenceTrackParameterType
-- local SkillCollisionSequenceTrackParameterTypeConverter = SkillCollisionSequenceTrackParameterType.Converter


local SkillCollisionSequenceTrack = {
    Value = nil
}

function SkillCollisionSequenceTrack:GetData(skillCollisionSequenceTrackParameterType)
    return self.Value[skillCollisionSequenceTrackParameterType]
end

function SkillCollisionSequenceTrack:ValidateSkillCollisionSequenceTrackParameter(skillCollisionSequenceTrackParameter)
    -- 없을 수 있다. 없으면 자자리에 위치한다.
    -- 다만 모두 존재하거나 존재하지 않아야 한다.
    if not skillCollisionSequenceTrackParameter[SkillCollisionSequenceTrackParameterType.SkillCollisionDirection] then
        Debug.Assert(false, "SkillCollisionDirection 가 없습니다.")
        return false
    end

    if not skillCollisionSequenceTrackParameter[SkillCollisionSequenceTrackParameterType.SkillCollisionSpeed] then
        Debug.Assert(false, "SkillCollisionSpeed 가 없습니다.")
        return false
    end

    --[[
    -- 없으면 그대로 유지된다.
    if not skillCollisionSequenceTrackParameter[SkillCollisionSequenceTrackParameterType.SkillCollisionSize] then
        Debug.Assert(false, "SkillCollisionSize 가 없습니다.")
        return false
    end
    --]]

    local listenSkillCollisionEvent = skillCollisionSequenceTrackParameter[SkillCollisionSequenceTrackParameterType.ListenSkillCollisionEvent]
    if nil == listenSkillCollisionEvent then
        Debug.Assert(false, "ListenSkillCollisionEvent 가 없습니다.")
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

function SkillCollisionSequenceTrack:Initialize(skillCollisionSequenceTrackParameter)
    if not self:ValidateSkillCollisionSequenceTrackParameter(skillCollisionSequenceTrackParameter) then
        Debug.Assert(false, "ValidateSkillCollisionSequenceTrackParameter에 실패했습니다.")
        return false
    end

    self.Value = skillCollisionSequenceTrackParameter
    return true
end


return SkillCollisionSequenceTrack