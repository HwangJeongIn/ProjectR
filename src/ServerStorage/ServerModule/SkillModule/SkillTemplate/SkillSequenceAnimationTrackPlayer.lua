local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local Utility = ServerModuleFacade.Utility

local ServerEnum = ServerModuleFacade.ServerEnum
local SkillSequenceAnimationTrackStateType = ServerEnum.SkillSequenceAnimationTrackStateType


local SkillSequenceAnimationTrackPlayer = {
    --[[
    SkillCollision = nil,
    SkillCollisionSize = nil,

    SkillCollisionEffect = nil,
    SkillCollisionSequence = nil,
    CurrentSkillCollisionSizeFactor = Vector3.new(1, 1, 1),
    CurrentTrackIndex = nil,
    CurrentTrackPosition = nil,

    ConvertedTrackDirections = nil,
    LookVector = nil,
    RightVector = nil,
    UpVector = nil,
    --]]
    
    PrevTime = nil,
    CurrentSkillCollisionSequenceIndex = 1,
    SkillCollisionSequenceCount = nil,

    SkillSequenceAnimationDuration = nil,
    RemainingAnimationTime = nil,

    PlayableSkillSequenceAnimationTrack = nil,
    SkillSequenceAnimationSpeed = nil,
}


function SkillSequenceAnimationTrackPlayer:Start()
    if self.PlayableSkillSequenceAnimationTrack then
        self.PlayableSkillSequenceAnimationTrack:Play(0.1, 1, self.SkillSequenceAnimationSpeed)
    end
    self.PrevTime = os.clock()

    return true
end

function SkillSequenceAnimationTrackPlayer:Update(currentTime)
    local deltaTime = currentTime - self.PrevTime
    self.PrevTime = currentTime

    self.RemainingAnimationTime -= deltaTime
    if 0 > self.RemainingAnimationTime then
        self.RemainingAnimationTime = 0
    end

    local fireTimeRate = (self.SkillSequenceAnimationDuration - self.RemainingAnimationTime) / self.SkillSequenceAnimationDuration

    local skillCollisionSequences = {}
    if self.SkillCollisionSequenceCount then
       while self.CurrentSkillCollisionSequenceIndex <= self.SkillCollisionSequenceCount do
            local currentSkillCollisionWrapper = self.SkillSequenceAnimationTrack:GetSkillCollisionSequenceWrapper(self.CurrentSkillCollisionSequenceIndex)
            if fireTimeRate < currentSkillCollisionWrapper.SkillCollisionFireTimeRate then
                break
            end

            table.insert(skillCollisionSequences, currentSkillCollisionWrapper.SkillCollisionSequence)
            self.CurrentSkillCollisionSequenceIndex += 1
        end
    end

    if 0 >= self.RemainingAnimationTime then
        if skillCollisionSequences[1] then
            return SkillSequenceAnimationTrackStateType.Ended, skillCollisionSequences
        else
            return SkillSequenceAnimationTrackStateType.Ended
        end
    else
        if skillCollisionSequences[1] then
            return SkillSequenceAnimationTrackStateType.Playing, skillCollisionSequences
        else
            return SkillSequenceAnimationTrackStateType.Playing
        end
    end
end

function SkillSequenceAnimationTrackPlayer:Initialize(player, skillSequenceAnimationTrack)
    self.SkillOwner = player
    self.SkillSequenceAnimationTrack = skillSequenceAnimationTrack

    local playerCharacter = player.character
    if not playerCharacter then
        Debug.Assert(false, "캐릭터가 없습니다.")
        return false
    end

    self.SkillCollisionSequenceCount = self.SkillSequenceAnimationTrack:GetSkillCollisionSequenceCount()
    self.CurrentSkillCollisionSequenceIndex = 1

    self.SkillSequenceAnimationDuration = self.SkillSequenceAnimationTrack:GetSkillSequenceAnimationDuration()
    self.RemainingAnimationTime = self.SkillSequenceAnimationDuration
    Debug.Assert(self.SkillSequenceAnimationDuration, "비정상입니다.")

    local skillSequenceAnimationWrapper = self.SkillSequenceAnimationTrack:GetSkillSequenceAnimationWrapper()
    if skillSequenceAnimationWrapper then

        local humanoid = playerCharacter:FindFirstChild("Humanoid")
        Debug.Assert(humanoid, "비정상입니다.")
    
        local humanoidRootPart = playerCharacter:FindFirstChild("HumanoidRootPart")
        Debug.Assert(humanoidRootPart, "비정상입니다.")

        local animation = skillSequenceAnimationWrapper.Animation
        local animationLength = skillSequenceAnimationWrapper.AnimationLength

        self.PlayableSkillSequenceAnimationTrack = humanoid:LoadAnimation(animation)
        self.SkillSequenceAnimationSpeed =  animationLength / self.SkillSequenceAnimationDuration
    end

    return true
end


function SkillSequenceAnimationTrackPlayer:GetSkillAnimation()
    return self.SkillAnimation
end

function SkillSequenceAnimationTrackPlayer:AddSkillCollisionSequence(skillCollisionFireTimeRate, skillCollisionSequence)
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

    table.insert(self.SkillCollisionSequences, skillCollisionSequenceWrapper)
    return true
end

function SkillSequenceAnimationTrackPlayer:GetLastSkillCollisionFireTimeRate()
    if 0 == self.SkillCollisionSequenceCount then
        return 0
    end
    
    return self.SkillCollisionSequences[self.SkillCollisionSequenceCount].SkillCollisionFireTimeRate
end


return SkillSequenceAnimationTrackPlayer