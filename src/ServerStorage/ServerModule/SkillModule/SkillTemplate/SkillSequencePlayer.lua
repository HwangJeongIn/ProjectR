-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local Utility = ServerModuleFacade.Utility
local ObjectTagUtility = ServerModuleFacade.ObjectTagUtility
local ObjectCollisionGroupUtility = ServerModuleFacade.ObjectCollisionGroupUtility

local NpcUtility = ServerModuleFacade.NpcUtility


local ServerConstant = ServerModuleFacade.ServerConstant
local DefaultWeaponSkillGameDataKey = ServerConstant.DefaultWeaponSkillGameDataKey
--local DefaultArmorSkillGameDataKey = ServerConstant.DefaultArmorSkillGameDataKey
local DefaultSkillCollisionSpeed = ServerConstant.DefaultSkillCollisionSpeed


local ServerEnum = ServerModuleFacade.ServerEnum
--[[
local GameDataType = ServerEnum.GameDataType
local CollisionGroupType = ServerEnum.CollisionGroupType

local SkillDataType = ServerEnum.SkillDataType
local EquipType = ServerEnum.EquipType
local WorldInteractorType = ServerEnum.WorldInteractorType
local SkillSequenceType = ServerEnum.SkillSequenceType
local SkillSequenceTypeConverter = SkillSequenceType.Converter
local SkillDataParameterType = ServerEnum.SkillDataParameterType
local SkillDataParameterTypeConverter = SkillDataParameterType.Converter

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage
local ServerGameDataManager = ServerModuleFacade.ServerGameDataManager

local SkillModule = ServerModuleFacade.SkillModule
local DamageCalculator = require(SkillModule:WaitForChild("DamageCalculator"))
--]]

local SkillAnimationTemplate = require(script.Parent:WaitForChild("SkillAnimationTemplate"))
local SkillEffectTemplate = require(script.Parent:WaitForChild("SkillEffectTemplate"))
local SkillSequenceAnimationTrack = require(script.Parent:WaitForChild("SkillSequenceAnimationTrack"))
local skillCollisionSequencePlayer = require(script.Parent:WaitForChild("SkillCollisionSequencePlayer"))


local SkillSequencePlayer = {
    SkillOwner = nil,

    SkillSequence = nil,
    SkillSequenceAnimationTrackCount = nil,

    PrevTime = nil,
    CurrentSkillSequenceAnimationTrackIndex = nil,
    CurrentSkillSequenceAnimationTrackPosition = nil,

    --[[
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
    --]]
}


--function
function SkillSequencePlayer:Simulate(skillCastingTime, humanoidRootPart, skillCollisionHandler)

    local prevTime = os.clock()
    local currentTime = prevTime
    local deltaTime = 0
    local remainingSkillCollisionSequenceTrackDuration = SkillCollisionSequenceTrackDuration
    

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




    --[[

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
    --]]
end


function SkillSequencePlayer:Start(skillSequence, player)
    local ownerPlayerCharacter = player.character
    if not ownerPlayerCharacter then
        Debug.Assert(false, "캐릭터가 없습니다.")
        return false
    end

    local humanoid = ownerPlayerCharacter:FindFirstChild("Humanoid")
    Debug.Assert(humanoid, "비정상입니다.")

	local humanoidRootPart = ownerPlayerCharacter:FindFirstChild("HumanoidRootPart")
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

    local simulateCoroutine = coroutine.wrap(self.Simulate)
    simulateCoroutine(self, skillCastingTime, humanoidRootPart, skillCollisionHandler)

    self.PrevTime = os.clock()
    return true
end

function SkillSequencePlayer:InitializeSkillSequencePlayer(player, skillSequence)
    self.SkillOwner = player
    self.SkillSequence = skillSequence
    self.SkillSequenceAnimationTrackCount = skillSequence:GetSkillSequenceAnimationTrackCount()

    self.SkillSequenceAnimationTrackPlayer = 
    --[[
    SkillCollisionSequence:InitializeSkillCollision({
        [SkillCollisionParameterType.SkillCollisionSize] = Vector3.new(2, 2, 2),
        [SkillCollisionParameterType.SkillCollisionOffset] = Vector3.new(5, 0, 0), -- look, right, up
        [SkillCollisionParameterType.SkillCollisionEffect] = "SwordSlashEffect",
        [SkillCollisionParameterType.SkillCollisionOnDestroyingEffect] = "HitEffect"
    })
    --]]
end



return SkillSequencePlayer