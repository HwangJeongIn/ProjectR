local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonMoudleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonMoudleFacade.Debug
local Utility = CommonMoudleFacade.Utility
local ToolUtility = CommonMoudleFacade.ToolUtility

local CommonEnum = CommonMoudleFacade.CommonEnum
local SlotType = CommonEnum.SlotType
--local EquipType = CommonEnum.EquipType

local CommonConstant = CommonMoudleFacade.CommonConstant
local MaxSkillCount = CommonConstant.MaxSkillCount
local GuiSkillSlotOffsetRatio = CommonConstant.GuiSkillSlotOffsetRatio


local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiFacade = require(PlayerGui:WaitForChild("GuiFacade"))

local GuiSkillSlots = GuiFacade.GuiSkillSlots
local GuiToolSlotTemplate = GuiFacade.GuiTemplate.GuiToolSlot
local GuiToolSlotController = GuiFacade.GuiTemplateController.GuiToolSlotController


local GuiSkillSlotsRaw = Utility:DeepCopy(CommonMoudleFacade.TArray)
GuiSkillSlotsRaw:Initialize(MaxSkillCount)
local GuiSkillSlotsController = {
	GuiSkillSlotsRaw = GuiSkillSlotsRaw
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

    self.GuiMainToolSlotController = GuiToolSlotController:new(SlotType.SkillSlot, 1, newGuiMainToolSlot)




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

        self.GuiSkillSlotsRaw:Set(slotIndex, GuiToolSlotController:new(SlotType.SkillSlot, slotIndex, newGuiToolSlot))
    end
end

GuiSkillSlotsController:Initialize()
return GuiSkillSlotsController
