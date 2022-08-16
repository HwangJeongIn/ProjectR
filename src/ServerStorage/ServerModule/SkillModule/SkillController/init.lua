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

local SkillTemplate = require(script:WaitForChild("SkillTemplate"))

local SkillController = {}
SkillController.__index = Utility.Inheritable__index
SkillController.__newindex = Utility.Inheritable__newindex


-- pure virtual function
function SkillController:UseSkill(toolOwnerPlayer)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return false
end

function SkillController:FindTargetsInRange(toolOwnerPlayer)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return nil
end

function SkillController:ApplySkillToTarget(toolOwnerPlayer, target)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return false
end


function SkillController:GetSkillCollisionParameter(toolOwnerPlayer)
    Debug.Assert(false, "상위에서 구현해야합니다.")
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

function SkillController:FilterTargetsBySkillCollision(toolOwnerPlayer)
    local skillCollisionParameter = self:GetSkillCollisionParameter(toolOwnerPlayer)
    if not self:ValidateSkillCollisionParameter(toolOwnerPlayer) then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    local tempSkillCollision = Instance.new("Part")
    ObjectCollisionGroupUtility:SetSkillCollisionGroup(tempSkillCollision)

    tempSkillCollision.Anchored = true
    tempSkillCollision.Transparency = 1

    --tempPart.CanTouch = false
    tempSkillCollision.CanCollide = false
    tempSkillCollision.CanQuery = true

    tempSkillCollision.Parent = game.workspace
    tempSkillCollision.Size =  skillCollisionParameter.Size
    tempSkillCollision.CFrame = skillCollisionParameter.CFrame
    --tempPart.Position = Vector3.new(0, 0, 0)

    -- 찾아봤지만 따로 방법이 없다. 현재는 이게 최선인듯하다. 
    local tempConnection = tempSkillCollision.Touched:Connect(function() end)
    local touchingParts = tempSkillCollision:GetTouchingParts()
    local finalTouchingParts = {}
    for _, touchingPart in pairs(touchingParts) do
        if ObjectCollisionGroupUtility:IsCollidableByPart(tempSkillCollision, touchingPart) then
            table.insert(finalTouchingParts, touchingPart)
        end
    end
    tempConnection:Disconnect()
    Debris:AddItem(tempSkillCollision, 0)

    return finalTouchingParts
end

function SkillController:ApplySkillToTargets(toolOwnerPlayer, targets)
    for _, target in pairs(targets) do
        if not self:ApplySkillToTarget(toolOwnerPlayer, target) then
            Debug.Assert(false, "비정상입니다.")
            return false
        end
    end

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
    if not self:UseSkill(player) then
        Debug.Print(self.Name .. "에 실패했습니다.")
        return false
    end

    local targetsFilteredBySkillCollision = self:FilterTargetsBySkillCollision(player)
    local finalTargets = self:FindTargetInRange(player, targetsFilteredBySkillCollision)
    if finalTargets then
        if not self:ApplySkillToTargets(player, finalTargets) then
            Debug.Print(self.Name .. "에 실패했습니다.")
            return false
        end
    end

    return true
end

function SkillController:SetToolOwnerPlayer(toolOwnerPlayer)
    if not toolOwnerPlayer then
        if self.ToolOwnerPlayer then
           local prevPlayerId = self.ToolOwnerPlayer.UserId 
           if self.LastActivationTime then
                ServerGlobalStorage:SetSkillLastActivationTime(prevPlayerId, self.SkillGameDataKey, self.LastActivationTime)
           end
        end
        self.LastActivationTime = nil
        self.ToolOwnerPlayer = nil
    else
        local playerId = toolOwnerPlayer.UserId
        local playerLastActivationTime = ServerGlobalStorage:GetSkillLastActivationTime(playerId, self.SkillGameDataKey)
        self.LastActivationTime = playerLastActivationTime
    end
end

function SkillController:SetSkill(tool, skillGameData)
    local skillGameDataKey = skillGameData:GetKey()
    local targetSkillTemplate = SkillTemplate:GetSkillTemplateByKey(skillGameDataKey)
    if not targetSkillTemplate then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    self.UseSkill = targetSkillTemplate.UseSkill
    self.FindTargetsInRange = targetSkillTemplate.FindTargetsInRange
    self.ApplySkillToTarget = targetSkillTemplate.ApplySkillToTarget

    self.Tool = tool
    self.SkillGameDataKey = skillGameDataKey
    self.Name = skillGameData.Name
    self.Cooldown = skillGameData.Cooldown

    self.LastActivationTime = nil
    return true
end

return SkillController
