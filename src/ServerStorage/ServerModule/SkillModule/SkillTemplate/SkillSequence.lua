local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local Utility = ServerModuleFacade.Utility

local SkillAnimationTemplate = require(script.Parent:WaitForChild("SkillAnimationTemplate"))
local SkillSequenceAnimationTrack = require(script.Parent:WaitForChild("SkillSequenceAnimationTrack"))


local SkillSequence = {
    SkillSequenceAnimationTracks = {},
    SkillSequenceAnimationTrackCount = 0
}


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