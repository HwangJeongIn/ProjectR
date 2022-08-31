local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ClientModuleFacade = require(StarterPlayerScripts:WaitForChild("ClientModuleFacade"))

local ClientGlobalStorage = ClientModuleFacade.ClientGlobalStorage
local Debug = ClientModuleFacade.Debug
local Utility = ClientModuleFacade.Utility
local ToolUtility = ClientModuleFacade.ToolUtility


local CommonEnum = ClientModuleFacade.CommonEnum
local SlotType = CommonEnum.SlotType
--local EquipType = CommonEnum.EquipType

local CommonConstant = ClientModuleFacade.CommonConstant
local MaxSkillCount = CommonConstant.MaxSkillCount
local GuiSkillSlotOffsetRatio = CommonConstant.GuiSkillSlotOffsetRatio


local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiFacade = require(PlayerGui:WaitForChild("GuiFacade"))

local GuiSkillSlots = GuiFacade.GuiSkillSlots
local GuiToolSlotTemplate = GuiFacade.GuiTemplate.GuiSlot
local GuiSkillSlotController = GuiFacade.GuiTemplateController.GuiSkillSlotController
local GuiSkillOwnerToolSlotController = GuiFacade.GuiTemplateController.GuiSkillOwnerToolSlotController

local GuiSkillSlotsRaw = Utility:DeepCopy(ClientModuleFacade.TArray)
GuiSkillSlotsRaw:Initialize(MaxSkillCount)
local GuiSkillSlotsController = {
	GuiSkillSlotsRaw = GuiSkillSlotsRaw,
    SkillOwnerTool = nil,
    SkillOwnerToolGameData = nil
}

function GetPositionOnCircleByAngle(radius, angle, offsetX, offsetY)
    local x = math.cos(angle) * radius
    local y = math.sin(angle) * radius

    -- y는 기준이 반대이기 때문에 -를 해준다.
    return x + offsetX, -y + offsetY
end

function GuiSkillSlotsController:Initialize()
	local GuiSkillSlotsWidth = GuiSkillSlots.AbsoluteSize.X
	local GuiSkillSlotsHeight = GuiSkillSlots.AbsoluteSize.Y

    local GuiHUDBottomWindow = GuiSkillSlots.Parent
    local prevSkillSlotsSize = GuiSkillSlots.Size
    if GuiSkillSlotsWidth < GuiSkillSlotsHeight then
        GuiSkillSlotsHeight = GuiSkillSlotsWidth
        local GuiHUDBottomWindowHeight = GuiHUDBottomWindow.AbsoluteSize.Y
        GuiSkillSlots.Size = UDim2.new(prevSkillSlotsSize.X.Scale, 0, GuiSkillSlotsHeight / GuiHUDBottomWindowHeight, 0)
    else
        GuiSkillSlotsWidth = GuiSkillSlotsHeight
        local GuiHUDBottomWindowWidth = GuiHUDBottomWindow.AbsoluteSize.X
        GuiSkillSlots.Size = UDim2.new(GuiSkillSlotsWidth / GuiHUDBottomWindowWidth, 0, prevSkillSlotsSize.Y.Scale, 0)
    end
    
    --local GuiSkillSlotsSize = GuiSkillSlotsWidth
    local mainToolSlotRatio = 0.5
    local mainToolSlotPositionRatioX = 0.5 +  mainToolSlotRatio / 2
    local mainToolSlotPositionRatioY = 0.5 +  mainToolSlotRatio / 2
    local skillCircleHalfRatio = mainToolSlotPositionRatioX


	local slotAnchorPoint = Vector2.new(0.5, 0.5)
    local mainToolSlotPosition = UDim2.new(mainToolSlotPositionRatioX, 0, mainToolSlotPositionRatioY, 0)
    local mainToolSlotSize = UDim2.new(mainToolSlotRatio, 0, mainToolSlotRatio, 0)

    local skillSlotRatio = 0.5 - GuiSkillSlotOffsetRatio * 2
	local skillSlotSize = UDim2.new(skillSlotRatio, 0, skillSlotRatio, 0)

    -- MainToolSlot
    local newGuiMainToolSlot = GuiToolSlotTemplate:Clone()
        
    newGuiMainToolSlot.AnchorPoint = slotAnchorPoint
    newGuiMainToolSlot.Size = mainToolSlotSize
    newGuiMainToolSlot.Position = mainToolSlotPosition
    newGuiMainToolSlot.Parent = GuiSkillSlots
    newGuiMainToolSlot.Name = tostring("MainToolSlot")

    self.GuiMainToolSlotController = GuiSkillOwnerToolSlotController:new(1, newGuiMainToolSlot)
    

	--local startRadian = math.rad(math.pi  * (1 / 2))
    --local endRadian = math.rad(math.pi * (1))

	local startRadian = math.pi  * (1 / 2)
    local endRadian = math.pi * (1)

    local radianSize = endRadian - startRadian
    local radianUnit = (radianSize / (MaxSkillCount - 1))
    for slotIndex = 1, MaxSkillCount do
        local newGuiToolSlot = GuiToolSlotTemplate:Clone()
        
        local currentRadian = startRadian + radianUnit * (slotIndex - 1)
        local finalXRatio, finalYRatio = GetPositionOnCircleByAngle(skillCircleHalfRatio, currentRadian, mainToolSlotPositionRatioX, mainToolSlotPositionRatioY)

        newGuiToolSlot.AnchorPoint = slotAnchorPoint
        newGuiToolSlot.Size = skillSlotSize
        newGuiToolSlot.Position = UDim2.new(finalXRatio, 0, finalYRatio, 0)
        newGuiToolSlot.Parent = GuiSkillSlots
        newGuiToolSlot.Name = tostring(slotIndex)

        self.GuiSkillSlotsRaw:Set(slotIndex, GuiSkillSlotController:new(slotIndex, newGuiToolSlot))
    end
end

function GuiSkillSlotsController:ClearSkillSlot(skillIndex)
	local targetGuiSkillSlotController = self.GuiSkillSlotsRaw:Get(skillIndex)
    if not targetGuiSkillSlotController then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    targetGuiSkillSlotController:SetSkill(nil, nil)
    return true
end

function GuiSkillSlotsController:ClearData()
    if not self.GuiMainToolSlotController:SetSkillOwnerTool(nil) then
        Debug.Assert(false, "비정상입니다.")
    end

    for skillIndex = 1, MaxSkillCount do
        if not self:ClearSkillSlot(skillIndex) then
            Debug.Assert(false, "비정상입니다.")
        end
    end

    self.SkillOwnerTool = nil
    self.SkillOwnerToolGameData = nil
end

function GuiSkillSlotsController:GetSkillSlot(skillIndex)
    local targetGuiSkillSlotController = self.GuiSkillSlotsRaw:Get(skillIndex)
    if not targetGuiSkillSlotController then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return targetGuiSkillSlotController
end

function GuiSkillSlotsController:SetSkillSlot(skillIndex, skillOwnerTool, skillGameData)
	local targetGuiSkillSlotController = self:GetSkillSlot(skillIndex)
    if not targetGuiSkillSlotController then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if not skillOwnerTool or not skillGameData then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if not targetGuiSkillSlotController:SetSkill(skillOwnerTool, skillGameData) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    return true
end

function GuiSkillSlotsController:SetSkillOwnerToolSlot(skillOwnerTool)
	if not skillOwnerTool then
        self:ClearData()
		return true
	end

    if not self.GuiMainToolSlotController:SetSkillOwnerTool(skillOwnerTool) then
        Debug.Assert(false, "비정상입니다.")
		return false
    end

    local skillOwnerToolGameData = ToolUtility:GetGameData(skillOwnerTool)
    local skillCount = skillOwnerToolGameData.SkillCount

    if skillCount then
        for skillIndex = 1, MaxSkillCount do
            if skillCount >= skillIndex then
                if not self:SetSkillSlot(skillIndex, skillOwnerTool, skillOwnerToolGameData.SkillGameDataSet[skillIndex]) then
                    Debug.Assert(false, "비정상입니다.")
                    return false
                end
            else
                if not self:ClearSkillSlot(skillIndex) then
                    Debug.Assert(false, "비정상입니다.")
                    return false
                end
            end
        end
    end
        
    self.SkillOwnerTool = skillOwnerTool
    self.SkillOwnerToolGameData = skillOwnerToolGameData
    
	return true
end

function GuiSkillSlotsController:RefreshSkillByLastActivationTime(skillGameDataKey, lastActivationTime)
    if not self.SkillOwnerToolGameData then
        --Debug.Assert(false, "비정상입니다.")
        --return false
        return true -- 착용하고 있지 않을 수 있다. -- 들고 있는 무기를 버리는 경우
    end

    local skillCount = self.SkillOwnerToolGameData.SkillCount
    if skillCount then
        for skillIndex = 1, skillCount do
            local targetSkillSlotController = self:GetSkillSlot(skillIndex)
            if not targetSkillSlotController then
                Debug.Assert(false, "비정상입니다. 코드 버그일 가능성이 매우 높습니다.")
                return false
            end

            local targetSkillGameDataKey = targetSkillSlotController:GetSkillGameDataKey()
            if targetSkillGameDataKey == skillGameDataKey then
                targetSkillSlotController:RefreshByLastActivationTime(lastActivationTime)
            end
        end
    end

    return true
end


GuiSkillSlotsController:Initialize()
return GuiSkillSlotsController
