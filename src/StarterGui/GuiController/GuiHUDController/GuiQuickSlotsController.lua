local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonMoudleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonMoudleFacade.Debug
local Utility = CommonMoudleFacade.Utility
local ToolUtility = CommonMoudleFacade.ToolUtility

local CommonEnum = CommonMoudleFacade.CommonEnum
local SlotType = CommonEnum.SlotType
--local EquipType = CommonEnum.EquipType

local CommonConstant = CommonMoudleFacade.CommonConstant
local MaxQuickSlotCount = CommonConstant.MaxQuickSlotCount
local GuiQuickSlotOffsetRatio = CommonConstant.GuiQuickSlotOffsetRatio


local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiFacade = require(PlayerGui:WaitForChild("GuiFacade"))

local GuiQuickSlots = GuiFacade.GuiQuickSlots
local GuiToolSlotTemplate = GuiFacade.GuiTemplate.GuiSlot
local GuiToolSlotController = GuiFacade.GuiTemplateController.GuiToolSlotController


local GuiQuickSlotsRaw = Utility:DeepCopy(CommonMoudleFacade.TArray)
GuiQuickSlotsRaw:Initialize(MaxQuickSlotCount)
local GuiQuickSlotsController = {
	GuiQuickSlotsRaw = GuiQuickSlotsRaw
}

function GuiQuickSlotsController:Initialize()
	local GuiQuickSlotsHeight = GuiQuickSlots.AbsoluteSize.Y

    local GuiSlotsWindow = GuiQuickSlots.Parent
    local GuiSlotsWindowWidth = GuiSlotsWindow.AbsoluteSize.X

	local GuiQuickSlotOffset = GuiQuickSlotOffsetRatio * GuiQuickSlotsHeight

	local finalSlotSize = GuiQuickSlotsHeight - (GuiQuickSlotOffset * 2)
    local GuiQuickSlotsWidth = GuiQuickSlotOffset * (MaxQuickSlotCount + 1) + finalSlotSize * MaxQuickSlotCount
    if GuiQuickSlotsWidth > GuiSlotsWindowWidth then
        Debug.Assert(false, "부모 객체의 사이즈가 너무 작습니다. Gui가 비정상입니다.")
        return
    end

    
    local prevSize = GuiQuickSlots.Size
	GuiQuickSlots.Size = UDim2.new(GuiQuickSlotsWidth / GuiSlotsWindowWidth, 0, prevSize.Y.Scale, 0)

	local slotRatioX = finalSlotSize / GuiQuickSlotsWidth
	local halfSlotRatioX = slotRatioX / 2
	local slotRatioY = finalSlotSize / GuiQuickSlotsHeight
	local halfSlotRatioY = slotRatioY / 2

	local GuiQuickSlotOffsetRatioX =  GuiQuickSlotOffset / GuiQuickSlotsWidth
	local GuiQuickSlotOffsetRatioY =  GuiQuickSlotOffset / GuiQuickSlotsHeight
	
	local slotSize = UDim2.new(slotRatioX, 0, slotRatioY, 0)
	local slotAnchorPoint = Vector2.new(0.5, 0.5)
	local firstSlotPosition = UDim2.new(GuiQuickSlotOffsetRatioX + halfSlotRatioX, 0, GuiQuickSlotOffsetRatioY + halfSlotRatioY, 0)
	
    for slotIndex = 1, MaxQuickSlotCount do
        local newGuiToolSlot = GuiToolSlotTemplate:Clone()
        
        newGuiToolSlot.Size = slotSize
        newGuiToolSlot.AnchorPoint = slotAnchorPoint
        newGuiToolSlot.Position = firstSlotPosition + UDim2.new((GuiQuickSlotOffsetRatioX + slotRatioX) * (slotIndex - 1), 0, 0, 0)
        newGuiToolSlot.Parent = GuiQuickSlots
        newGuiToolSlot.Name = tostring(slotIndex)

        self.GuiQuickSlotsRaw:Set(slotIndex, GuiToolSlotController:new(SlotType.QuickSlot, slotIndex, newGuiToolSlot))
    end

end

function GuiQuickSlotsController:SetToolSlot(slotIndex, tool)
	if not slotIndex then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local targetGuiToolSlotController = self.GuiQuickSlotsRaw:Get(slotIndex)
	if not targetGuiToolSlotController then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not targetGuiToolSlotController:SetTool(tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

GuiQuickSlotsController:Initialize()
return GuiQuickSlotsController
