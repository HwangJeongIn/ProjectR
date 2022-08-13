-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------

local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local Utility = ServerModuleFacade.Utility
local ObjectTagUtility = ServerModuleFacade.ObjectTagUtility

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage

local ServerConstant = ServerModuleFacade.ServerConstant

local ServerEnum = ServerModuleFacade.ServerEnum

local SkillTemplate = require(script:WaitForChild("SkillTemplate"))

local SkillController = {}
SkillController.__index = Utility.Inheritable__index
SkillController.__newindex = Utility.Inheritable__newindex


-- pure virtual function
function SkillController:UseSkill(toolOwner)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return false
end

function SkillController:FindTargetsInRange(toolOwner)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return nil
end

function SkillController:ApplySkillToTarget(toolOwner, target)
    Debug.Assert(false, "상위에서 구현해야합니다.")
    return false
end

-- function
function SkillController:ApplySkillToTargets(toolOwner, targets)
    for _, target in pairs(targets) do
        if not self:ApplySkillToTarget(toolOwner, target) then
            Debug.Assert(false, "비정상입니다.")
            return false
        end
    end

    return true
end

function SkillController:Activate(toolOwner)
    local currentTime = os.clock()
    if self.LastActivationTime then
        local elapsedTime = currentTime - self.LastActivationTime
        if elapsedTime < self.Cooldown then
            Debug.Print(tostring(self.Cooldown - elapsedTime) .. "초 후에 사용할 수 있습니다.")
            return true
        end
    end

    self.LastActivationTime = currentTime
    if not self:UseSkill(toolOwner) then
        Debug.Print(self.Name .. "에 실패했습니다.")
        return false
    end

    local targets = self:FindTargetInRange(toolOwner)
    if targets then
        if not self:ApplySkillToTargets(toolOwner, targets) then
            Debug.Print(self.Name .. "에 실패했습니다.")
            return false
        end
    end

    return true
end

function SkillController:SetSkill(toolOwnerPlayer, tool, skillGameDataKey)
    local targetSkillTemplate = SkillTemplate:GetSkillTemplateByKey(skillGameDataKey)
    if not targetSkillTemplate then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    self.UseSkill = targetSkillTemplate.UseSkill
    self.FindTargetsInRange = targetSkillTemplate.FindTargetsInRange
    self.ApplySkillToTarget = targetSkillTemplate.ApplySkillToTarget

    local skillGameData = targetSkillTemplate.GameData
    self.Tool = tool
    self.ToolOwner = toolOwnerPlayer.Character

    self.Name = skillGameData.Name
    self.Cooldown = skillGameData.Cooldown

    local playerId = toolOwnerPlayer.UserId
    --self.LastActivationTime = ServerGlobalStorage:GetCooldown(playerId, tool, skillGameDataKey)
    self.LastActivationTime = nil
    return true
end

return SkillController
