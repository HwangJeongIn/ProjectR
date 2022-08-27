local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local Utility = ServerModuleFacade.Utility

local ServerEnum = ServerModuleFacade.ServerEnum
local SkillSequenceAnimationTrackStateType = ServerEnum.SkillSequenceAnimationTrackStateType
local SkillCollisionSequenceStateType = ServerEnum.SkillCollisionSequenceStateType

local SkillSequenceAnimationTrackPlayer = require(script.Parent:WaitForChild("SkillSequenceAnimationTrackPlayer"))


local SkillSequencePlayer = {
    SkillOwner = nil,

    SkillSequence = nil,
    SkillSequenceAnimationTrackCount = nil,
}


function SkillSequencePlayer:StartSkillSequenceAnimationTrackPlayer(animationTrackPlayerIndex)
    local animationTrackPlayer = self.SkillSequenceAnimationTrackPlayers[animationTrackPlayerIndex]
    if not animationTrackPlayer:Initialize(self.SkillOwner, self.SkillSequence:GetSkillSequenceAnimationTrack(animationTrackPlayerIndex)) then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    if not animationTrackPlayer:Start() then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return animationTrackPlayer
end

function SkillSequencePlayer:Simulate(skillCollisionHandler)
    local prevTime = os.clock()
    local currentTime = prevTime
    local deltaTime = 0
    
    local currentAnimationTrackIndex = 1
    local currentSkillSequenceAnimationTrackPlayer = self:StartSkillSequenceAnimationTrackPlayer(currentAnimationTrackIndex)
    if not currentSkillSequenceAnimationTrackPlayer then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    local currentAnimationTrackStateType = nil
    local currentCollisionSequenceStateType = nil
    local returnedCollisionSequencePlayers = nil
    
    while currentAnimationTrackIndex <= self.SkillSequenceAnimationTrackPlayerCount 
    or 0 < self.SkillSequenceCollisionPlayerCount do
        currentTime = os.clock()
        deltaTime = currentTime - prevTime
        prevTime = currentTime

        if currentAnimationTrackIndex <= self.SkillSequenceAnimationTrackPlayerCount then
            currentAnimationTrackStateType, returnedCollisionSequencePlayers = currentSkillSequenceAnimationTrackPlayer:Update(currentTime)
        
            if SkillSequenceAnimationTrackStateType.Ended == currentAnimationTrackStateType then
                currentAnimationTrackIndex += 1
                if currentAnimationTrackIndex <= self.SkillSequenceAnimationTrackPlayerCount then
                    currentSkillSequenceAnimationTrackPlayer = self:StartSkillSequenceAnimationTrackPlayer(currentAnimationTrackIndex)
                    if not currentSkillSequenceAnimationTrackPlayer then
                        Debug.Assert(false, "비정상입니다.")
                        return false
                    end
                end
            end
        end

        -- 스킬 콜리전 업데이트
        for collisionSequencePlayerIndex, collisionSequencePlayer in pairs(self.SkillSequenceCollisionPlayers) do
            currentCollisionSequenceStateType = collisionSequencePlayer:Update(currentTime)
            if SkillCollisionSequenceStateType.Ended == currentCollisionSequenceStateType then
                collisionSequencePlayer:End()
                table.remove(self.SkillSequenceCollisionPlayers, collisionSequencePlayerIndex)
            end 
        end

        -- 추가되는 프레임에서는 업데이트를 따로 하지 않는다.
        if returnedCollisionSequencePlayers then
            for _, collisionSequencePlayer in pairs(returnedCollisionSequencePlayers) do
                collisionSequencePlayer:Start(skillCollisionHandler)
                self.SkillSequenceCollisionPlayerCount += 1
                table.insert(self.SkillSequenceCollisionPlayers, collisionSequencePlayer)
            end
        end

        wait(0)
    end
end

function SkillSequencePlayer:Start()
    local simulateCoroutine = coroutine.wrap(self.Simulate)
    simulateCoroutine(self, self.SkillCollisionHandler)
    return true
end

function SkillSequencePlayer:Initialize(player, skillSequence, skillCollisionHandler)
    self.SkillOwner = player
    self.SkillSequence = skillSequence
    self.SkillSequenceAnimationTrackPlayerCount = self.SkillSequence:GetSkillSequenceAnimationTrackCount()
    self.SkillCollisionHandler = skillCollisionHandler
    -- self.CurrentSkillSequenceAnimationTrackPlayerIndex = 1

    if not self.SkillSequenceAnimationTrackPlayerCount then
        Debug.Assert(false, "SkillSequence에 AnimationTrack이 하나도 없습니다. 동작하지 않습니다. 수정해주세요.")
        return false
    end

    self.SkillSequenceAnimationTrackPlayers = {}
    for skillSequenceAnimationTrackIndex = 1, self.SkillSequenceAnimationTrackPlayerCount do
        local skillSequenceAnimationTrack = self.SkillSequence:GetSkillSequenceAnimationTrack(skillSequenceAnimationTrackIndex)
        Debug.Assert(skillSequenceAnimationTrack, "비정상입니다.")

        local skillSequenceAnimationTrackPlayer = Utility:DeepCopy(SkillSequenceAnimationTrackPlayer)
        --[[
        if not skillSequenceAnimationTrackPlayer:Initialize(player, skillSequenceAnimationTrack) then
            Debug.Assert(false, "비정상입니다.")
            return false
        end
        --]]
        table.insert(self.SkillSequenceAnimationTrackPlayers, skillSequenceAnimationTrackPlayer)
    end

    self.SkillSequenceCollisionPlayers = {}
    self.SkillSequenceCollisionPlayerCount = 0
    
    return true
end



return SkillSequencePlayer