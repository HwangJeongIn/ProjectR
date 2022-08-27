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
local SkillTemplateFolder = SkillModule:WaitForChild("SkillTemplate")
local SkillTemplate = require(SkillTemplateFolder)

local SkillSequencePlayer = require(SkillTemplateFolder:WaitForChild("SkillSequencePlayer"))


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

function SkillController:ActivateInternally(toolOwnerPlayer)
    local skillSequencePlayer = Utility:DeepCopy(SkillSequencePlayer)

    --[[
    if not skillSequencePlayer:Initialize(toolOwnerPlayer, self.SkillSequence, self.MultipleProcessingSkillCollisionHandler) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end
    --]]

    if not skillSequencePlayer:Initialize(toolOwnerPlayer, self.SkillSequence, self.SkillCollisionHandler) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end
    
    skillSequencePlayer:Start()
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
    
    self.SkillSequence = targetSkillTemplate:GetSkillSequence()

    self.SkillTemplateData = targetSkillTemplate

    self.Tool = tool
    self.SkillGameDataKey = skillGameDataKey
    self.Name = skillGameData.Name
    self.Cooldown = skillGameData.Cooldown

    self.LastActivationTime = nil


    self.MultipleProcessingSkillCollisionHandler = function(skillCollision, touchedPart, outputFromHandling)
        if ObjectCollisionGroupUtility:IsCollidableByPart(skillCollision, touchedPart) then
            if touchedPart.Parent == self.ToolOwnerPlayer.Character then
                return
            end

            --local touchedPartCollisionGroupName = ObjectCollisionGroupUtility:GetCollisionGroupNameByPart(touchedPart)
            --Debug.Print(touchedPart.Name .. " : ".. tostring(touchedPartCollisionGroupName))

            if self:ValidateTargetInRange(self.ToolOwnerPlayer, touchedPart) then
                if self:ApplySkillToTarget(self.ToolOwnerPlayer, touchedPart, outputFromHandling) then
                    outputFromHandling.Hit = true
                end
            end
        end
    end

    self.SkillCollisionHandler = function(skillCollision, touchedPart, outputFromHandling)
        if ObjectCollisionGroupUtility:IsCollidableByPart(skillCollision, touchedPart) then
            if touchedPart.Parent == self.ToolOwnerPlayer.Character then
                return
            end

            --local touchedPartCollisionGroupName = ObjectCollisionGroupUtility:GetCollisionGroupNameByPart(touchedPart)
            --Debug.Print(touchedPart.Name .. " : ".. tostring(touchedPartCollisionGroupName))

            if self:ValidateTargetInRange(self.ToolOwnerPlayer, touchedPart) then
                self:ApplySkillToTarget(self.ToolOwnerPlayer, touchedPart, outputFromHandling)
            end

            outputFromHandling.Hit = true
            outputFromHandling.PendingKill = true
        end
    end


    return true
end

return SkillController
