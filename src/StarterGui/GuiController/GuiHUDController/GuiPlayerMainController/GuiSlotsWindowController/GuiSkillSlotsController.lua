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

function GuiSkillSlotsController:Initialize()
	local GuiSkillSlotsHeight = GuiSkillSlots.AbsoluteSize.Y

    local GuiSlotsWindow = GuiSkillSlots.Parent
    local GuiSlotsWindowWidth = GuiSlotsWindow.AbsoluteSize.X

	local GuiSkillSlotOffset = GuiSkillSlotOffsetRatio * GuiSkillSlotsHeight

	local finalSlotSize = GuiSkillSlotsHeight - (GuiSkillSlotOffset * 2)
    local GuiSkillSlotsWidth = GuiSkillSlotOffset * (MaxSkillCount + 1) + finalSlotSize * MaxSkillCount
    if GuiSkillSlotsWidth > GuiSlotsWindowWidth then
        Debug.Assert(false, "부모 객체의 사이즈가 너무 작습니다. Gui가 비정상입니다.")
        return
    end

    
    local prevSize = GuiSkillSlots.Size
	GuiSkillSlots.Size = UDim2.new(GuiSkillSlotsWidth / GuiSlotsWindowWidth, 0, prevSize.Y.Scale, 0)

	local slotRatioX = finalSlotSize / GuiSkillSlotsWidth
	local halfSlotRatioX = slotRatioX / 2
	local slotRatioY = finalSlotSize / GuiSkillSlotsHeight
	local halfSlotRatioY = slotRatioY / 2

	local GuiSkillSlotOffsetRatioX =  GuiSkillSlotOffset / GuiSkillSlotsWidth
	local GuiSkillSlotOffsetRatioY =  GuiSkillSlotOffset / GuiSkillSlotsHeight
	
	local slotSize = UDim2.new(slotRatioX, 0, slotRatioY, 0)
	local slotAnchorPoint = Vector2.new(0.5, 0.5)
	local firstSlotPosition = UDim2.new(GuiSkillSlotOffsetRatioX + halfSlotRatioX, 0, GuiSkillSlotOffsetRatioY + halfSlotRatioY, 0)
	
    for slotIndex = 1, MaxSkillCount do
        local newGuiToolSlot = GuiToolSlotTemplate:Clone()
        
        newGuiToolSlot.Size = slotSize
        newGuiToolSlot.AnchorPoint = slotAnchorPoint
        newGuiToolSlot.Position = firstSlotPosition + UDim2.new((GuiSkillSlotOffsetRatioX + slotRatioX) * (slotIndex - 1), 0, 0, 0)
        newGuiToolSlot.Parent = GuiSkillSlots
        newGuiToolSlot.Name = tostring(slotIndex)

        self.GuiSkillSlotsRaw:Set(slotIndex, GuiToolSlotController:new(SlotType.SkillSlot, slotIndex, newGuiToolSlot))
    end

end

GuiSkillSlotsController:Initialize()
return GuiSkillSlotsController
