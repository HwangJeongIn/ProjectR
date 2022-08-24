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


function SkillCollisionSequencePlayer:InitializeAllSkillCollisionSequenceTrackDirections(collisionSequence, ownerCFrame)
    if not collisionSequence or not ownerCFrame then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if not collisionSequence:IsValid() then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    self.LookVector = CFrame.LookVector
    self.RightVector = CFrame.RightVector
    self.UpVector = CFrame.UpVector

    local trackCount = collisionSequence:GetTrackCount()
    self.ConvertedTrackDirections = {}

    for trackIndex = 1, trackCount do
        local currentTrack = collisionSequence:GetTrack(trackIndex)
        
        local relativeDirection = currentTrack:GetTrackData(SkillCollisionSequenceTrackParameterType.SkillCollisionDirection)
        local convertedTrackDirection = self.LookVector * relativeDirection.X
                                      + self.RightVector * relativeDirection.Y
                                      + self.UpVector * relativeDirection.Z

        convertedTrackDirection = convertedTrackDirection.Unit
        table.insert(self.ConvertedTrackDirections, convertedTrackDirection)
    end

    return true
end

function SkillCollisionSequencePlayer:Initialize(collision, collisionSequence, ownerCFrame)
    if not collision or not collisionSequence or not ownerCFrame then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if not self:InitializeAllSkillCollisionSequenceTrackDirections(collisionSequence, ownerCFrame) then
        Debug.Assert(false, "InitializeAllSkillCollisionSequenceTrackDirections에 실패했습니다.")
        return false
    end

    self.Collision = collision
    self.CollisionSequence = collisionSequence
    self.CollisionSequenceTrackCount = collisionSequence:GetTrackCount()

    self.CurrentTrackIndex = 1
    self.CurrentTrackPosition = 0.0
end

function SkillCollisionSequencePlayer:Start()
    self.StartTime = os.clock()
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