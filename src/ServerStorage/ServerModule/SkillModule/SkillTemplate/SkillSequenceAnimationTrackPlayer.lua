local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local Utility = ServerModuleFacade.Utility

local ServerEnum = ServerModuleFacade.ServerEnum
local SkillSequenceAnimationTrackStateType = ServerEnum.SkillSequenceAnimationTrackStateType

local SkillCollisionSequencePlayer = require(script.Parent:WaitForChild("SkillCollisionSequencePlayer"))


local SkillSequenceAnimationTrackPlayer = {
    SkillOwner = nil,

    PrevTime = nil,
    CurrentSkillCollisionSequenceIndex = nil,
    SkillCollisionSequenceCount = nil,
    SkillCollisionSequencePlayerWrappers = nil,

    SkillSequenceAnimationDuration = nil,
    RemainingAnimationTime = nil,

    SkillSequenceAnimationTrack = nil,
    PlayableSkillSequenceAnimationTrack = nil,
    SkillSequenceAnimationSpeed = nil,
}


function SkillSequenceAnimationTrackPlayer:Initialize(player, skillSequenceAnimationTrack)
    self.SkillOwner = player
    self.SkillSequenceAnimationTrack = skillSequenceAnimationTrack

    local playerCharacter = player.character
    if not playerCharacter then
        Debug.Assert(false, "캐릭터가 없습니다.")
        return false
    end

    local humanoid = playerCharacter:FindFirstChild("Humanoid")
    Debug.Assert(humanoid, "비정상입니다.")

    local humanoidRootPart = playerCharacter:FindFirstChild("HumanoidRootPart")
    Debug.Assert(humanoidRootPart, "비정상입니다.")

    self.SkillCollisionSequenceCount = self.SkillSequenceAnimationTrack:GetSkillCollisionSequenceCount()
    self.CurrentSkillCollisionSequenceIndex = 1
    if not self.SkillCollisionSequenceCount then
        Debug.Assert(false, "SkillCollisionSequence가 SkillSequenceAnimationTrack 에 존재하지 않습니다.")
        return false
    end

    -- collision sequence player
    self.SkillCollisionSequencePlayerWrappers = {}
    for skillCollisionSequenceIndex = 1, self.SkillCollisionSequenceCount do
        local currentSkillCollisionSequenceWrapper = self.SkillSequenceAnimationTrack:GetSkillCollisionSequenceWrapper(skillCollisionSequenceIndex)
        
        local skillCollisionSequencePlayer = Utility:DeepCopy(SkillCollisionSequencePlayer)
        if not skillCollisionSequencePlayer:Initialize(currentSkillCollisionSequenceWrapper.SkillCollisionSequence) then
            Debug.Assert(false, "SkillCollisionSequencePlayer 초기화에 싪했습니다.")
            return false
        end
        
        local skillCollisionSequencePlayerWrapper = {
            SkillCollisionSequencePlayer = skillCollisionSequencePlayer,
            SkillCollisionFireTimeRate = currentSkillCollisionSequenceWrapper.SkillCollisionFireTimeRate
        }

        table.insert(self.SkillCollisionSequencePlayerWrappers, skillCollisionSequencePlayerWrapper)
    end

    -- animation
    self.SkillSequenceAnimationDuration = self.SkillSequenceAnimationTrack:GetSkillSequenceAnimationDuration()
    self.RemainingAnimationTime = self.SkillSequenceAnimationDuration
    Debug.Assert(self.SkillSequenceAnimationDuration, "비정상입니다.")

    local skillSequenceAnimationWrapper = self.SkillSequenceAnimationTrack:GetSkillSequenceAnimationWrapper()
    if skillSequenceAnimationWrapper then
        local animation = skillSequenceAnimationWrapper.Animation
        local animationLength = skillSequenceAnimationWrapper.AnimationLength

        self.PlayableSkillSequenceAnimationTrack = humanoid:LoadAnimation(animation)
        self.SkillSequenceAnimationSpeed = self.SkillSequenceAnimationTrack:GetSkillSequenceAnimationSpeed()
        -- animationLength / self.SkillSequenceAnimationDuration
    end

    return true
end

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

    local skillCollisionSequencePlayers = {}
    while self.CurrentSkillCollisionSequenceIndex <= self.SkillCollisionSequenceCount do
        local currentSkillCollisionPlayerWrapper = self.SkillCollisionSequencePlayerWrappers[self.CurrentSkillCollisionSequenceIndex]
        if fireTimeRate < currentSkillCollisionPlayerWrapper.SkillCollisionFireTimeRate then
            break
        end

        table.insert(skillCollisionSequencePlayers, currentSkillCollisionPlayerWrapper.SkillCollisionSequencePlayer)
        self.CurrentSkillCollisionSequenceIndex += 1
    end

    if 0 >= self.RemainingAnimationTime then
        if skillCollisionSequencePlayers[1] then
            return SkillSequenceAnimationTrackStateType.Ended, skillCollisionSequencePlayers
        else
            return SkillSequenceAnimationTrackStateType.Ended
        end
    else
        if skillCollisionSequencePlayers[1] then
            return SkillSequenceAnimationTrackStateType.Playing, skillCollisionSequencePlayers
        else
            return SkillSequenceAnimationTrackStateType.Playing
        end
    end
end


return SkillSequenceAnimationTrackPlayer