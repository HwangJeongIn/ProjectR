-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local Utility = ServerModuleFacade.Utility


local SkillSequenceAnimationTrack = {
    SkillSequenceAnimationWrapper = nil,
    SkillSequenceAnimationDuration = nil,
    SkillCollisionSequenceWrappers = {},
    SkillCollisionSequenceCount = 0,
}

function SkillSequenceAnimationTrack:Initialize(skillSequenceAnimationWrapper, skillSequenceAnimationDuration)
    if not skillSequenceAnimationWrapper or not skillSequenceAnimationDuration then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    self.SkillSequenceAnimationWrapper = skillSequenceAnimationWrapper
    self.SkillSequenceAnimationDuration = skillSequenceAnimationDuration

    return true
end

function SkillSequenceAnimationTrack:GetSSkillSequenceAnimationWrapper()
    Debug.Assert(self.SkillSequenceAnimationWrapper, "비정상입니다.")
    return self.SkillSequenceAnimationWrapper
end

function SkillSequenceAnimationTrack:GetSkillSequenceAnimationDuration()
    Debug.Assert(self.SkillSequenceAnimationDuration, "비정상입니다.")
    return self.SkillSequenceAnimationDuration
end

function SkillSequenceAnimationTrack:AddSkillCollisionSequence(skillCollisionFireTimeRate, skillCollisionSequence)
    if not skillCollisionFireTimeRate or not skillCollisionSequence then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if 0 > skillCollisionFireTimeRate or 1 < skillCollisionFireTimeRate then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    local lastSkillCollisionFireTimeRate = self:GetLastSkillCollisionFireTimeRate()
    if lastSkillCollisionFireTimeRate < skillCollisionFireTimeRate then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    local skillCollisionSequenceWrapper = {
        SkillCollisionFireTimeRate = skillCollisionFireTimeRate,
        SkillCollisionSequence = skillCollisionSequence
    }

    table.insert(self.SkillCollisionSequenceWrappers, skillCollisionSequenceWrapper)
    return true
end

function SkillSequenceAnimationTrack:GetSkillCollisionSequenceWrapper(skillCollisionSequencIndex)
    if not skillCollisionSequencIndex or self.SkillCollisionSequenceCount < skillCollisionSequencIndex then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return self.SkillCollisionSequenceWrappers[skillCollisionSequencIndex]
end

function SkillSequenceAnimationTrack:GetSkillCollisionSequenceCount()
    return self.SkillCollisionSequenceCount
end

function SkillSequenceAnimationTrack:GetLastSkillCollisionFireTimeRate()
    if 0 == self.SkillCollisionSequenceCount then
        return 0
    end
    
    return self.SkillCollisionSequenceWrappers[self.SkillCollisionSequenceCount].SkillCollisionFireTimeRate
end


return SkillSequenceAnimationTrack