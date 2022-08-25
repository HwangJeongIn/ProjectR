-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local Utility = ServerModuleFacade.Utility
local ObjectTagUtility = ServerModuleFacade.ObjectTagUtility
local ObjectCollisionGroupUtility = ServerModuleFacade.ObjectCollisionGroupUtility

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage

local ServerConstant = ServerModuleFacade.ServerConstant

local ServerEnum = ServerModuleFacade.ServerEnum
local SkillImplType = ServerEnum.SkillImplType
local SkillDataParameterType = ServerEnum.SkillDataParameterType

local SkillModule = ServerModuleFacade.SkillModule
local SkillTemplate = require(SkillModule:WaitForChild("SkillTemplate"))

local SkillController = {}
SkillController.__index = Utility.Inheritable__index
SkillController.__newindex = Utility.Inheritable__newindex


-- pure virtual function
function SkillController:ValidateTargetInRange(toolOwnerPlayer, target)
    Debug.Assert(false, "ValidateTargetInRange 상위에서 구현해야합니다.")
    return nil
end

function SkillController:ApplySkillToTarget(toolOwnerPlayer, target, outputFromHandling)
    Debug.Assert(false, "ApplySkillToTarget 상위에서 구현해야합니다.")
    return false
end

-- function
function SkillController:CreateSkillCollision(originCFrame)
    local skillCollisionSize = self.SkillTemplateData:GetSkillDataParameter(SkillDataParameterType.SkillCollisionSize)
    local skillCollisionOffset = self.SkillTemplateData:GetSkillDataParameter(SkillDataParameterType.SkillCollisionOffset)
    local finalOffsetVector = originCFrame.LookVector * skillCollisionOffset.X
                            + originCFrame.RightVector * skillCollisionOffset.Y
                            + originCFrame.UpVector * skillCollisionOffset.Z

    local skillCollisionCFrame = originCFrame + finalOffsetVector

    local tempSkillCollision = Instance.new("Part")
    ObjectCollisionGroupUtility:SetSkillCollisionGroup(tempSkillCollision)

    tempSkillCollision.Anchored = true
    tempSkillCollision.Transparency = 1

    --tempPart.CanTouch = false
    tempSkillCollision.CanCollide = false
    tempSkillCollision.CanQuery = true

    tempSkillCollision.Parent = game.workspace
    tempSkillCollision.Size =  skillCollisionSize
    tempSkillCollision.CFrame = skillCollisionCFrame

    local skillEffect = self.SkillTemplateData:GetSkillDataParameter(SkillDataParameterType.SkillEffect)


    if skillEffect then
        local tempSkillEffect = skillEffect:Clone()
        tempSkillEffect.Parent = tempSkillCollision

        local targetRotation = self.Tool.Handle.CFrame.Rotation
        local skillCollisionRotation = tempSkillCollision.CFrame.Rotation

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

        tempSkillEffect.CFrame = targetRotation + tempSkillCollision.CFrame.Position

        local tempWeld = Instance.new("WeldConstraint")
        tempWeld.Name = "TempWeldConstraint"
        tempWeld.Part0 = tempSkillEffect
        tempWeld.Part1 = tempSkillCollision
        tempWeld.Parent = tempSkillEffect
    end

    return tempSkillCollision
end

function SkillController:SimulateSkillCollision(skillCastingTime, humanoidRootPart, skillCollisionHandler)
    wait(skillCastingTime)
    local createdSkillCollision = self:CreateSkillCollision(humanoidRootPart.CFrame)

    local SkillCollisionSequenceTrackDuration = self.SkillTemplateData:GetSkillDataParameter(SkillDataParameterType.SkillCollisionSequenceTrackDuration)
    local skillCollisionDirection = self.SkillTemplateData:GetSkillDataParameter(SkillDataParameterType.SkillCollisionDirection)
    if skillCollisionDirection then
        skillCollisionDirection = createdSkillCollision.CFrame[skillCollisionDirection]
    end
    local skillCollisionSpeed = self.SkillTemplateData:GetSkillDataParameter(SkillDataParameterType.SkillCollisionSpeed)
    local outputFromHandling = {}

    if not skillCollisionDirection then
        wait(SkillCollisionSequenceTrackDuration)
    else
        local prevTime = os.clock()
        local currentTime = prevTime
        local deltaTime = 0
        local remainingSkillCollisionSequenceTrackDuration = SkillCollisionSequenceTrackDuration
        
        --[[
        local skillCollisionConnection = createdSkillCollision.Touched:Connect(function(touchedPart) 
            skillCollisionHandler(createdSkillCollision, touchedPart, outputFromHandling) 
        end)
        --]]
        local skillCollisionConnection = createdSkillCollision.Touched:Connect(function(touchedPart) end)
        while remainingSkillCollisionSequenceTrackDuration > 0 and not outputFromHandling.PendingKill do
            prevTime = currentTime
            currentTime = os.clock()
            deltaTime = currentTime - prevTime
            remainingSkillCollisionSequenceTrackDuration -= (currentTime - prevTime)
            createdSkillCollision.CFrame = createdSkillCollision.CFrame + (skillCollisionDirection * skillCollisionSpeed * deltaTime)
            
            local touchingParts = createdSkillCollision:GetTouchingParts()
            for _, touchingPart in pairs(touchingParts) do
                skillCollisionHandler(createdSkillCollision, touchingPart, outputFromHandling) 
            end
            wait(0)
        end
        skillCollisionConnection:Disconnect()
    end

    -- 소멸 이펙트
    local skillOnDestroyingEffect = self.SkillTemplateData:GetSkillDataParameter(SkillDataParameterType.SkillOnDestroyingEffect)
    if skillOnDestroyingEffect then
        local onDestroyingEffect = skillOnDestroyingEffect:Clone()
        --onDestroyingEffect.Transparency = 0
        onDestroyingEffect.Anchored = true
        onDestroyingEffect.Parent = workspace
        onDestroyingEffect.CFrame = createdSkillCollision.CFrame
        Debris:AddItem(onDestroyingEffect, 0.2)
    end

    Debris:AddItem(createdSkillCollision, 0)
end

function SkillController:ActivateInternally(toolOwnerPlayer)
    local toolOwnerPlayerCharacter = toolOwnerPlayer.character
    if not toolOwnerPlayerCharacter then
        Debug.Assert(false, "캐릭터가 없습니다.")
        return false
    end

    local humanoid = toolOwnerPlayerCharacter:FindFirstChild("Humanoid")
    Debug.Assert(humanoid, "비정상입니다.")

	local humanoidRootPart = toolOwnerPlayerCharacter:FindFirstChild("HumanoidRootPart")
    Debug.Assert(humanoidRootPart, "비정상입니다.")

    local skillAnimationWrapper = self.SkillTemplateData:GetSkillDataParameter(SkillDataParameterType.SkillAnimation)
    local skillCastingTime = 0

    if skillAnimationWrapper then
        local skillAnimation = skillAnimationWrapper.Animation
        local skillAnimationLength = skillAnimationWrapper.AnimationLength

	    local skillAnimationTrack = humanoid:LoadAnimation(skillAnimation)

        local skillDuration = self.SkillTemplateData:GetSkillDataParameter(SkillDataParameterType.SkillDuration)
        local skillAnimationSpeed = 1
        if skillDuration then
            skillCastingTime = skillDuration / 2
            skillAnimationSpeed = skillAnimationLength / skillDuration
        else
            skillCastingTime = skillAnimationLength / 2
        end

        skillAnimationTrack:Play(0.1, 1, skillAnimationSpeed)
    end
    
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

    local simulateSkillCollisionCoroutine = coroutine.wrap(self.SimulateSkillCollision)
    simulateSkillCollisionCoroutine(self, skillCastingTime, humanoidRootPart, skillCollisionHandler)
    return true
end

function SkillController:Activate(player)
    if player ~= self.ToolOwnerPlayer then
        Debug.Assert(false, "비정상입니다. 원인을 파악해야합니다.")
        return false
    end

    local currentTime = os.clock()
    if self.LastActivationTime then
        local elapsedTime = currentTime - self.LastActivationTime
        if elapsedTime < self.Cooldown then
            Debug.Print(tostring(self.Cooldown - elapsedTime) .. "초 후에 사용할 수 있습니다.")
            return true
        end
    end

    self.LastActivationTime = currentTime
    if not self:ActivateInternally(player) then
        Debug.Print(self.Name .. "에 실패했습니다.")
        return false
    end

    return true
end

function SkillController:SetToolOwnerPlayer(toolOwnerPlayer)
    if self.ToolOwnerPlayer then
        local prevPlayerId = self.ToolOwnerPlayer.UserId 
        if self.LastActivationTime then
             ServerGlobalStorage:SetSkillLastActivationTime(prevPlayerId, self.SkillGameDataKey, self.LastActivationTime)
        end
        
        self.LastActivationTime = nil
    end

    self.ToolOwnerPlayer = toolOwnerPlayer
    if self.ToolOwnerPlayer  then
        local playerId = self.ToolOwnerPlayer.UserId
        local playerLastActivationTime = ServerGlobalStorage:GetSkillLastActivationTime(playerId, self.SkillGameDataKey)
        self.LastActivationTime = playerLastActivationTime
    end
end

function SkillController:SetSkillAsDefaultWeaponSkill(weaponTool)
    local defaultWeaponSkillGameData = SkillTemplate:GetDefaultWeaponSkillGameData()
    if not self:SetSkill(weaponTool, defaultWeaponSkillGameData) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    return true
end

function SkillController:GetSkillGameData()
    if not self.SkillTemplateData then
        return nil
    end

    return self.SkillTemplateData:GetSkillGameData()
end

function SkillController:SetSkill(tool, skillGameData)
    local skillGameDataKey = skillGameData:GetKey()
    local targetSkillTemplate = SkillTemplate:GetSkillTemplateByKey(skillGameDataKey)
    if not targetSkillTemplate then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    self.ValidateTargetInRange = targetSkillTemplate:GetSkillImpl(SkillImplType.ValidateTargetInRange)
    self.ApplySkillToTarget = targetSkillTemplate:GetSkillImpl(SkillImplType.ApplySkillToTarget)
    self.SkillTemplateData = targetSkillTemplate

    self.Tool = tool
    self.SkillGameDataKey = skillGameDataKey
    self.Name = skillGameData.Name
    self.Cooldown = skillGameData.Cooldown

    self.LastActivationTime = nil
    return true
end

return SkillController
