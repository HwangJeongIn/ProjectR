local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local ObjectCollisionGroupUtility = ServerModuleFacade.ObjectCollisionGroupUtility 

local ServerConstant = ServerModuleFacade.ServerConstant
local SkillCollisionInVisible = ServerConstant.SkillCollisionInVisible

local ServerEnum = ServerModuleFacade.ServerEnum
local SkillCollisionParameterType = ServerEnum.SkillCollisionParameterType
local SkillCollisionSequenceTrackParameterType = ServerEnum.SkillCollisionSequenceTrackParameterType
local SkillCollisionSequenceStateType = ServerEnum.SkillCollisionSequenceStateType


local SkillCollisionSequencePlayer = {
    SkillCollision = nil,
    SkillCollisionSize = nil,

    SkillCollisionEffect = nil,
    SkillCollisionSequence = nil,
    SkillCollisionSequenceTrackCount = nil,

    PrevTime = nil,
    CurrentSkillCollisionSizeFactor = Vector3.new(1, 1, 1),
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

    local trackCount = collisionSequence:GetSkillCollisionSequenceTrackCount()
    self.ConvertedTrackDirections = {}

    for trackIndex = 1, trackCount do
        local currentTrack = collisionSequence:GetSkillCollisionSequenceTrack(trackIndex)
        
        local relativeDirection = currentTrack:GetData(SkillCollisionSequenceTrackParameterType.SkillCollisionDirection)

        local convertedTrackDirection = nil
        if not relativeDirection then
            convertedTrackDirection = Vector3.new(0,0,0)
        else
            convertedTrackDirection = lookVector * relativeDirection.X
                                    + rightVector * relativeDirection.Y
                                    + upVector * relativeDirection.Z
        end


        convertedTrackDirection = convertedTrackDirection.Unit
        self.ConvertedTrackDirections[trackIndex] = convertedTrackDirection
    end

    return true
end

function SkillCollisionSequencePlayer:Initialize(collisionSequence)
    if not collisionSequence then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    self.SkillCollisionSequence = collisionSequence
    self.SkillCollisionSequenceTrackCount = collisionSequence:GetSkillCollisionSequenceTrackCount()

    self.CurrentTrackIndex = 1
    self.CurrentTrackPosition = 0.0

    return true
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

function SkillCollisionSequencePlayer:CalculateSizeBySizeFactor(size, sizeFactor)
    return Vector3.new(size.X * sizeFactor.X, size.Y * sizeFactor.Y, size.Z * sizeFactor.Z)
end

function SkillCollisionSequencePlayer:InitializeSkillCollision(originCFrame)
    if not originCFrame then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    local skillCollisionSize = self.SkillCollisionSequence:GetSkillCollisionData(SkillCollisionParameterType.SkillCollisionSize)
    local skillCollisionOffset = self.SkillCollisionSequence:GetSkillCollisionData(SkillCollisionParameterType.SkillCollisionOffset)
    local finalOffsetVector = originCFrame.LookVector * skillCollisionOffset.X
                            + originCFrame.RightVector * skillCollisionOffset.Y
                            + originCFrame.UpVector * skillCollisionOffset.Z

    local skillCollisionCFrame = originCFrame + finalOffsetVector

    local tempSkillCollision = Instance.new("Part")
    tempSkillCollision.Name = "SkillCollision"
    ObjectCollisionGroupUtility:SetSkillCollisionGroup(tempSkillCollision)

    tempSkillCollision.Anchored = true
    tempSkillCollision.Transparency = SkillCollisionInVisible

    --tempPart.CanTouch = false
    tempSkillCollision.CanCollide = false
    tempSkillCollision.CanQuery = true

    tempSkillCollision.Parent = game.workspace
    tempSkillCollision.Size =  skillCollisionSize
    tempSkillCollision.CFrame = skillCollisionCFrame

    self.SkillCollision = tempSkillCollision
    self.InitialSkillCollisionSize = skillCollisionSize

    local skillCollisionEffect = self.SkillCollisionSequence:GetSkillCollisionData(SkillCollisionParameterType.SkillCollisionEffect)
    if skillCollisionEffect then
        local tempSkillCollisionEffect = skillCollisionEffect:Clone()
        tempSkillCollisionEffect.Parent = tempSkillCollision

        tempSkillCollisionEffect.Size = skillCollisionSize
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

        self.SkillCollisionEffect = tempSkillCollisionEffect
    end

    self.SkillCollisionOnCreateSound =  self.SkillCollisionSequence:GetSkillCollisionData(SkillCollisionParameterType.SkillCollisionOnCreateSound)
    self.SkillCollisionOnUpdateSound =  self.SkillCollisionSequence:GetSkillCollisionData(SkillCollisionParameterType.SkillCollisionOnUpdateSound)
    self.SkillCollisionOnHitSound =  self.SkillCollisionSequence:GetSkillCollisionData(SkillCollisionParameterType.SkillCollisionOnHitSound)
    self.SkillCollisionOnDestroySound =  self.SkillCollisionSequence:GetSkillCollisionData(SkillCollisionParameterType.SkillCollisionOnDestroySound)

    if self.SkillCollisionOnCreateSound then
		self.SkillCollisionOnCreateSound = self.SkillCollisionOnCreateSound:Clone()
		self.SkillCollisionOnCreateSound.Parent = workspace
    end

    if self.SkillCollisionOnUpdateSound then
		self.SkillCollisionOnUpdateSound = self.SkillCollisionOnUpdateSound:Clone()
		self.SkillCollisionOnUpdateSound.Parent = workspace
    end

    if self.SkillCollisionOnHitSound then
		self.SkillCollisionOnHitSound = self.SkillCollisionOnHitSound:Clone()
		self.SkillCollisionOnHitSound.Parent = workspace
    end

    if self.SkillCollisionOnDestroySound then
		self.SkillCollisionOnDestroySound = self.SkillCollisionOnDestroySound:Clone()
		self.SkillCollisionOnDestroySound.Parent = workspace
    end

    return true
end

function SkillCollisionSequencePlayer:Start(originCFrame, skillCollisionHandler)
    if not self:InitializeAllSkillCollisionSequenceTrackDirections(self.SkillCollisionSequence, originCFrame) then
        Debug.Assert(false, "InitializeAllSkillCollisionSequenceTrackDirections에 실패했습니다.")
        return false
    end

    if not self:InitializeSkillCollision(originCFrame) then
        Debug.Assert(false, "InitializeSkillCollisio에 실패했습니다.")
        return false
    end

    self.SkillCollisionHandler = skillCollisionHandler

    if self.SkillCollisionOnCreateSound then
        --Debug.Print("SkillCollisionOnCreateSound")
        self.SkillCollisionOnCreateSound:Play()
        Debris:AddItem(self.SkillCollisionOnCreateSound, self.SkillCollisionOnCreateSound.TimeLength)
    end

    -- 현재의 Roblox에서는 Trigger 같은 충돌체의 경우 이벤트를 바인딩해야 충돌관련 처리를 할 수 있다.
    self.SkillCollisionTouchedConnection = self.SkillCollision.Touched:Connect(function(touchingPart) end)
    self.PrevTime = os.clock()

    return true
    
    --[[
    local skillCollisionHandler = function(skillCollision, touchedPart, outputFromHandling)
        if ObjectCollisionGroupUtility:IsCollidableByPart(skillCollision, touchedPart) then
            
            local touchedPartCollisionGroupName = ObjectCollisionGroupUtility:GetCollisionGroupNameByPart(touchedPart)
            Debug.Print(touchedPart.Name .. " : ".. tostring(touchedPartCollisionGroupName))

            if self:ValidateTargetInRange(toolOwnerPlayer, touchedPart) then
                self:ApplySkillToTarget(toolOwnerPlayer, touchedPart, outputFromHandling)
            end

            outputFromHandling.PendingKill = true
        end
    end
    --]]
end

function SkillCollisionSequencePlayer:End()
    -- 예외처리 해서 여러번 처리되지는 않지만 이벤트 발생을 막기 위해 끊어준다.
    self.SkillCollisionTouchedConnection:Disconnect()

    local skillCollisionOnDestroyEffect = self.SkillCollisionSequence:GetSkillCollisionData(SkillCollisionParameterType.SkillCollisionOnDestroyEffect)
    if skillCollisionOnDestroyEffect then
        local onDestroyingEffect = skillCollisionOnDestroyEffect:Clone()
        --onDestroyingEffect.Transparency = 0
        onDestroyingEffect.Anchored = true
        onDestroyingEffect.Parent = workspace
        onDestroyingEffect.CFrame = self.SkillCollision.CFrame
        Debris:AddItem(onDestroyingEffect, 0.2)
    end

    if self.SkillCollisionOnUpdateSound then
        if self.SkillCollisionOnUpdateSound.IsPlaying then
            self.SkillCollisionOnUpdateSound:Stop()
        end
        
        Debris:AddItem(self.SkillCollisionOnUpdateSound, 0)
    end

    if self.SkillCollisionOnHitSound then
        Debris:AddItem(self.SkillCollisionOnHitSound, self.SkillCollisionOnHitSound.TimeLength)
    end

    if self.SkillCollisionOnDestroySound then
        --Debug.Print("SkillCollisionOnDestroySound")
        self.SkillCollisionOnDestroySound:Play()
        Debris:AddItem(self.SkillCollisionOnDestroySound, self.SkillCollisionOnDestroySound.TimeLength)
    end

    Debris:AddItem(self.SkillCollision, 0)
end

function SkillCollisionSequencePlayer:Update(currentTime)
    local deltaTime = currentTime - self.PrevTime
    self.PrevTime = currentTime

    local currentTrack = nil
    local direction = nil
    local speed = nil
    local duration = nil
    local toSize = nil
    local listenEvent = nil

    local finalCFrame = self.SkillCollision.CFrame
    while 0 < deltaTime and self.SkillCollisionSequenceTrackCount >= self.CurrentTrackIndex do
        currentTrack = self.SkillCollisionSequence:GetSkillCollisionSequenceTrack(self.CurrentTrackIndex)
        direction = self.ConvertedTrackDirections[self.CurrentTrackIndex]
        speed = currentTrack:GetData(SkillCollisionSequenceTrackParameterType.SkillCollisionSpeed)
        duration = currentTrack:GetData(SkillCollisionSequenceTrackParameterType.SkillCollisionSequenceTrackDuration)
        toSize = currentTrack:GetData(SkillCollisionSequenceTrackParameterType.SkillCollisionSize)
        listenEvent = currentTrack:GetData(SkillCollisionSequenceTrackParameterType.ListenSkillCollisionEvent)

        local remainingTrackTime = duration - self.CurrentTrackPosition
        
        local simulationTime = nil
        if 0 > (deltaTime - remainingTrackTime) then
            simulationTime = deltaTime
            self.CurrentTrackPosition += simulationTime

            if toSize then
                local factor = simulationTime / remainingTrackTime
                -- linear interpolation
                self.CurrentSkillCollisionSizeFactor = factor * toSize + (1 - factor) * self.CurrentSkillCollisionSizeFactor
            end
        else
            simulationTime = remainingTrackTime
            self.CurrentTrackPosition = 0
            self.CurrentTrackIndex += 1

            if toSize then
                self.CurrentSkillCollisionSizeFactor = toSize
            end
        end
        deltaTime -= remainingTrackTime

        if speed then
            finalCFrame = finalCFrame + (direction * speed * simulationTime)
        end
    end

    if speed then
        self.SkillCollision.CFrame = CFrame.new(Vector3.zero, direction) + finalCFrame.Position
    end

    local finalSize = self:CalculateSizeBySizeFactor(self.InitialSkillCollisionSize, self.CurrentSkillCollisionSizeFactor)
    self.SkillCollision.Size = finalSize
    self.SkillCollisionEffect.Size = finalSize
    --if toSize then end

    if self.SkillCollisionOnUpdateSound then
        if not self.SkillCollisionOnUpdateSound.IsPlaying then
            --Debug.Print("SkillCollisionOnUpdateSound")
            self.SkillCollisionOnUpdateSound:Play()
        end
    end
    
    if listenEvent then
        local outputFromHandling = {}
        local touchingParts = self.SkillCollision:GetTouchingParts()
        for _, touchingPart in pairs(touchingParts) do
            if self.SkillCollisionHandler(self.SkillCollision, touchingPart, outputFromHandling) then
                break
            end
        end

        if outputFromHandling.Hit then
            if self.SkillCollisionOnHitSound then
                --Debug.Print("SkillCollisionOnHitSound")
                self.SkillCollisionOnHitSound:Play()
            end
        end
    
        -- 더 좋은 방법을 찾아야 한다.
        if outputFromHandling.PendingKill then
            return SkillCollisionSequenceStateType.Ended
        end
    end

    if self.SkillCollisionSequenceTrackCount < self.CurrentTrackIndex then
        return SkillCollisionSequenceStateType.Ended
    else
        return SkillCollisionSequenceStateType.Playing
    end
end


return SkillCollisionSequencePlayer