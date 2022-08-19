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
function SkillController:UseSkill(toolOwnerPlayer)
    Debug.Assert(false, "UseSkill 상위에서 구현해야합니다.")
    return false
end

function SkillController:FindTargetInRange(toolOwnerPlayer)
    Debug.Assert(false, "FindTargetInRange 상위에서 구현해야합니다.")
    return nil
end

function SkillController:ApplySkillToTarget(toolOwnerPlayer, target)
    Debug.Assert(false, "ApplySkillToTarget 상위에서 구현해야합니다.")
    return false
end

function SkillController:GetSkillCollisionParameter(toolOwnerPlayerCFrame)
    Debug.Assert(false, "GetSkillCollisionParameter 상위에서 구현해야합니다.")
    return nil
end


-- function
function SkillController:ValidateSkillCollisionParameter(skillCollisionParameter)
    if not skillCollisionParameter then
        Debug.Assert(false, "정확히 반환하는 지 확인하세요.")
        return false
    end

    if not skillCollisionParameter.Size then
        Debug.Assert(false, "Size 정보가 없습니다.")
        return false
    end

    if not skillCollisionParameter.CFrame then
        Debug.Assert(false, "CFrame 정보가 없습니다.")
        return false
    end

    --[[
    if not skillCollisionParameter.Effect then
        --Debug.Assert(false, "CFrame 정보가 없습니다.")
        --return false
    end
    --]]

    return true
end

function SkillController:CreateSkillCollision(originCFrame)
    local skillCollisionSize = self.SkillTemplate:GetSkillDataParameter(SkillDataParameterType.SkillCollisionSize)
    local skillCollisionOffset = self.SkillTemplate:GetSkillDataParameter(SkillDataParameterType.SkillCollisionOffset)
    local finalOffsetVector = originCFrame.LookVector * skillCollisionOffset.X
                            + originCFrame.RightVector * skillCollisionOffset.Y

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

    local skillEffect = self.SkillTemplate:GetSkillDataParameter(SkillDataParameterType.SkillEffect)
    if skillEffect then
        local tempSkillEffect = skillEffect:Clone()
        tempSkillEffect.Parent = tempSkillCollision
    end

    return tempSkillCollision
end

function SkillController:SimulateSkillCollision(skillCastingTime, originCFrame, skillCollisionHandler)
    wait(skillCastingTime)
    local createdSkillCollision = self:CreateSkillCollision(originCFrame)

    local skillCollisionDuration = self.SkillTemplate:GetSkillDataParameter(SkillDataParameterType.SkillCollisionDuration)
    local skillCollisionDirection = self.SkillTemplate:GetSkillDataParameter(SkillDataParameterType.skillCollisionDirection)
    local skillCollisionSpeed = self.SkillTemplate:GetSkillDataParameter(SkillDataParameterType.SkillCollisionSpeed)
    local skillCollisionDetailMovementType = self.SkillTemplate:GetSkillDataParameter(SkillDataParameterType.SkillCollisionDetailMovementType)
    
    local skillCollisionConnection = createdSkillCollision.Touched:Connect(function(touchedPart) 
        skillCollisionHandler(createdSkillCollision, touchedPart) 
    end)

    if not skillCollisionDirection then
        wait(skillCollisionDuration)
    else
        local prevTime = os.clock()
        local currentTime = prevTime
        local deltaTime = 0
        local remainingSkillCollisionDuration = skillCollisionDuration

        while remainingSkillCollisionDuration > 0 do
            prevTime = currentTime
            currentTime = os.clock()
            deltaTime = currentTime - prevTime
            remainingSkillCollisionDuration -= (currentTime - prevTime)

            createdSkillCollision.CFrame = createdSkillCollision.CFrame + (skillCollisionDirection * skillCollisionSpeed * deltaTime)
            wait(0.1)
        end
    end

    skillCollisionConnection:Disconnect()
    Debris:AddItem(skillCollisionConnection, 0)
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

    local skillAnimation = self.SkillTemplate:GetSkillDataParameter(SkillDataParameterType.SkillAnimation)
    local skillCastingTime = 0

    if skillAnimation then
	    local skillAnimationTrack = humanoid:LoadAnimation(skillAnimation)

        local skillDuration = self.SkillTemplate:GetSkillDataParameter(SkillDataParameterType.SkillDuration)
        if not skillDuration then
            skillCastingTime = skillDuration / 2
            local skillAnimationSpeed = skillAnimationTrack.Length / skillDuration
            skillAnimationTrack:AdjustSpeed(skillAnimationSpeed)
        else
            skillCastingTime = skillAnimationTrack.Length / 2
        end

        skillAnimationTrack:Play()
    end

    --[[
    local startCreatingSkillCollisionTime = os.clock()	
    local createdSkillCollision = self:CreateSkillCollision(humanoidRootPart)

    local remainingSkillCastingTime =  os.clock() - startCreatingSkillCollisionTime
    if remainingSkillCastingTime < 0 then remainingSkillCastingTime = 0 end
    --]]

    local skillCollisionHandler = function(skillCollision, touchedPart)
        if ObjectCollisionGroupUtility:IsCollidableByPart(skillCollision, touchedPart) then
            if self.FindTargetInRange(toolOwnerPlayer) then
                self.ApplySkillToTarget(toolOwnerPlayer, touchedPart)
            end
        end
    end

    local simulateSkillCollisionCoroutine = coroutine.wrap(self.SimulateSkillCollision)
    simulateSkillCollisionCoroutine(self, skillCastingTime, humanoidRootPart.CFrame, skillCollisionHandler)

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

function SkillController:SetSkill(tool, skillGameData)
    local skillGameDataKey = skillGameData:GetKey()
    local targetSkillTemplate = SkillTemplate:GetSkillTemplateByKey(skillGameDataKey)
    if not targetSkillTemplate then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    
    self.UseSkill = targetSkillTemplate:GetSkillImpl(SkillImplType.UseSkill)
    self.FindTargetInRange = targetSkillTemplate:GetSkillImpl(SkillImplType.FindTargetInRange)
    self.ApplySkillToTarget = targetSkillTemplate:GetSkillImpl(SkillImplType.ApplySkillToTarget)
    self.GetSkillCollisionParameter = targetSkillTemplate:GetSkillImpl(SkillImplType.GetSkillCollisionParameter)
    self.SkillTemplate = targetSkillTemplate


    self.Tool = tool
    --self.SkillTemplateData = targetSkillTemplate
    --self.SkillGameDataKey = skillGameDataKey
    self.Name = skillGameData.Name
    self.Cooldown = skillGameData.Cooldown

    self.LastActivationTime = nil
    return true
end

return SkillController
