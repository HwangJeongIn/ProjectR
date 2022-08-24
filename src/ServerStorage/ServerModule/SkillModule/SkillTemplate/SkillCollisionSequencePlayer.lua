local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local Utility = ServerModuleFacade.Utility
local ObjectTagUtility = ServerModuleFacade.ObjectTagUtility
local ObjectCollisionGroupUtility = ServerModuleFacade.ObjectCollisionGroupUtility 

local ServerConstant = ServerModuleFacade.ServerConstant
local DefaultWeaponSkillGameDataKey = ServerConstant.DefaultWeaponSkillGameDataKey
--local DefaultArmorSkillGameDataKey = ServerConstant.DefaultArmorSkillGameDataKey

local ServerEnum = ServerModuleFacade.ServerEnum
local GameDataType = ServerEnum.GameDataType

local SkillDataType = ServerEnum.SkillDataType
local SkillImplType = ServerEnum.SkillImplType
local SkillImplTypeConverter = SkillImplType.Converter


local SkillCollisionParameterType = ServerEnum.SkillCollisionParameterType
local SkillCollisionSequenceTrackParameterType = ServerEnum.SkillCollisionSequenceTrackParameterType
local SkillCollisionSequenceState = ServerEnum.SkillCollisionSequenceState

local ServerGameDataManager = ServerModuleFacade.ServerGameDataManager

local SkillAnimationTemplate = require(script:WaitForChild("SkillAnimationTemplate"))
local SkillEffectTemplate = require(script:WaitForChild("SkillEffectTemplate"))
local SkillImpl = require(script:WaitForChild("SkillImpl"))


local SkillCollisionSequencePlayer = {
    Collision = nil,
    CollisionSequence = nil,
    CollisionSequenceTrackCount = nil,

    StartTime = nil,
    CurrentTrackIndex = nil,
    CurrentTrackPosition = nil,

    ConvertedTrackDirections = nil,
    LookVector = nil,
    RightVector = nil,
    UpVector = nil
}


function SkillCollisionSequencePlayer:InitializeAllSkillCollisionSequenceTrackDirections(collisionSequence, originCFrame)
    if not collisionSequence or not originCFrame then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if not collisionSequence:IsValid() then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    local lookVector = originCFrame.LookVector
    local rightVector = originCFrame.RightVector
    local upVector = originCFrame.UpVector

    local trackCount = collisionSequence:GetTrackCount()
    self.ConvertedTrackDirections = {}

    for trackIndex = 1, trackCount do
        local currentTrack = collisionSequence:GetTrack(trackIndex)
        
        local relativeDirection = currentTrack:GetTrackData(SkillCollisionSequenceTrackParameterType.SkillCollisionDirection)
        local convertedTrackDirection = lookVector * relativeDirection.X
                                      + rightVector * relativeDirection.Y
                                      + upVector * relativeDirection.Z

        convertedTrackDirection = convertedTrackDirection.Unit
        table.insert(self.ConvertedTrackDirections, convertedTrackDirection)
    end

    return true
end

function SkillCollisionSequencePlayer:Initialize(collisionSequence, originCFrame)
    if not collisionSequence or not originCFrame then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if not self:InitializeAllSkillCollisionSequenceTrackDirections(collisionSequence, originCFrame) then
        Debug.Assert(false, "InitializeAllSkillCollisionSequenceTrackDirections에 실패했습니다.")
        return false
    end

    self.OriginCFrame = originCFrame
    self.CollisionSequence = collisionSequence
    self.CollisionSequenceTrackCount = collisionSequence:GetTrackCount()

    self.CurrentTrackIndex = 1
    self.CurrentTrackPosition = 0.0
end

function SkillCollisionSequencePlayer:GetSynchronizedSkillEffectCFrameToOrigin(originCFrame, skillCollision)
    local targetRotation = originCFrame.Rotation
    local skillCollisionRotation = skillCollision.CFrame.Rotation

    local dotResult = targetRotation.LookVector:Dot(skillCollisionRotation.LookVector)
    if 0 > dotResult then
        local rightVector = -targetRotation.RightVector
        local upVector = targetRotation.UpVector
        local lookVector = targetRotation.LookVector

        targetRotation = CFrame.new(
            0, 0, 0, 
          --RightVector | UpVector | –LookVector
          rightVector.X, upVector.X, lookVector.X,
          rightVector.Y, upVector.Y, lookVector.Y, 
          rightVector.Z, upVector.Z, lookVector.Z) 

    end

    return (targetRotation + skillCollision.CFrame.Position)
end

function SkillCollisionSequencePlayer:CreateSkillCollision(originCFrame)
    if not originCFrame then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    local skillCollisionSize = self.CollisionSequence:GetCollisionData(SkillCollisionParameterType.SkillCollisionSize)
    local skillCollisionOffset = self.CollisionSequence:GetCollisionData(SkillCollisionParameterType.SkillCollisionOffset)
    local finalOffsetVector = originCFrame.LookVector * skillCollisionOffset.X
                            + originCFrame.RightVector * skillCollisionOffset.Y
                            + originCFrame.UpVector * skillCollisionOffset.Z

    local skillCollisionCFrame = originCFrame + finalOffsetVector

    local tempSkillCollision = Instance.new("Part")
    tempSkillCollision.Name = "SkillCollision"
    ObjectCollisionGroupUtility:SetSkillCollisionGroup(tempSkillCollision)

    tempSkillCollision.Anchored = true
    tempSkillCollision.Transparency = 1

    --tempPart.CanTouch = false
    tempSkillCollision.CanCollide = false
    tempSkillCollision.CanQuery = true

    tempSkillCollision.Parent = game.workspace
    tempSkillCollision.Size =  skillCollisionSize
    tempSkillCollision.CFrame = skillCollisionCFrame


    local skillCollisionEffect = self.CollisionSequence:GetCollisionData(SkillCollisionParameterType.SkillCollisionEffect)
    if skillCollisionEffect then
        local tempSkillCollisionEffect = skillCollisionEffect:Clone()
        tempSkillCollisionEffect.Parent = tempSkillCollision

        -- 방향 동기화하는 것은 스킬에 따라 결정할 수 있도록 해줘야 한다.
        if true then
            tempSkillCollisionEffect.CFrame = skillCollisionCFrame
        else
            tempSkillCollisionEffect.CFrame = self:GetSynchronizedSkillEffectCFrameToOrigin(originCFrame, tempSkillCollision)
        end
        

        local tempWeld = Instance.new("WeldConstraint")
        tempWeld.Name = "TempWeldConstraint"
        tempWeld.Part0 = tempSkillCollisionEffect
        tempWeld.Part1 = tempSkillCollision
        tempWeld.Parent = tempSkillCollisionEffect
    end

    return tempSkillCollision
end

function SkillCollisionSequencePlayer:Start()
    local skillCollision = self:CreateSkillCollision(self.OriginCFrame)
    if not skillCollision then
        Debug.Assert(false, "SkillCollision을 만들지 못했습니다.")
        return false
    end

    self.Collision = skillCollision
    self.StartTime = os.clock()
end

function SkillCollisionSequencePlayer:End()
    local skillCollisionOnDestroyingEffect = self.CollisionSequence:GetCollisionData(SkillCollisionParameterType.SkillCollisionOnDestroyingEffect)
    if skillCollisionOnDestroyingEffect then
        local onDestroyingEffect = skillCollisionOnDestroyingEffect:Clone()
        --onDestroyingEffect.Transparency = 0
        onDestroyingEffect.Anchored = true
        onDestroyingEffect.Parent = workspace
        onDestroyingEffect.CFrame = self.Collision.CFrame
        Debris:AddItem(onDestroyingEffect, 0.2)
    end

    Debris:AddItem(self.Collision, 0)
end

function SkillCollisionSequencePlayer:Update(currentTime)
    local remainingTime = currentTime - self.StartTime

    local currentTrack = nil
    local direction = nil
    local speed = nil
    local duration = nil

    while 0 < remainingTime and self.CollisionSequenceTrackCount >= self.CurrentTrackIndex do
        currentTrack = self.CollisionSequence:GetTrack(self.CurrentTrackIndex)
        direction = self.ConvertedTrackDirections[self.CurrentTrackIndex]
        speed = currentTrack:GetData(SkillCollisionSequenceTrackParameterType.SkillCollisionSpeed)
        duration = currentTrack:GetData(SkillCollisionSequenceTrackParameterType.SkillCollisionSequenceTrackDuration)

        local remainingTrackTime = self.CurrentTrackPosition - duration
        local simulationTime = remainingTrackTime
        self.CurrentTrackPosition = 0

        remainingTime -= remainingTrackTime
        if 0 > remainingTime then
            simulationTime = remainingTime
            self.CurrentTrackPosition += simulationTime
        else
            self.CurrentTrackPosition = 0
            self.CurrentTrackIndex += 1
        end

        local deltaVector = direction * speed * simulationTime
        self.Collision.CFrame = self.Collision.CFrame + deltaVector
    end

    if self.CollisionSequenceTrackCount < self.CurrentTrackIndex then
        return SkillCollisionSequenceState.Ended
    else
        return SkillCollisionSequenceState.Playing
    end
end


return SkillCollisionSequencePlayer