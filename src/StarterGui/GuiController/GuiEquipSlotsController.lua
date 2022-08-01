local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonMoudleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonMoudleFacade.Debug
local Utility = CommonMoudleFacade.Utility
local ToolUtility = CommonMoudleFacade.ToolUtility
local CommonConstant = CommonMoudleFacade.CommonConstant
local CommonEnum = CommonMoudleFacade.CommonEnum
local SlotType = CommonEnum.SlotType

local MaxEquipSlotCount = CommonConstant.MaxEquipSlotCount
local GuiEquipSlotCountPerLine = CommonConstant.GuiEquipSlotCountPerLine
local GuiEquipSlotOffset = CommonConstant.GuiEquipSlotOffset


local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiPlayerStatus = PlayerGui:WaitForChild("GuiPlayerStatus")
local GuiPlayerStatusWindow = GuiPlayerStatus:WaitForChild("GuiPlayerStatusWindow")
local GuiEquipSlots = GuiPlayerStatusWindow:WaitForChild("GuiEquipSlots")

local GuiTemplate = PlayerGui:WaitForChild("GuiTemplate")
local GuiToolSlotTemplate = GuiTemplate:WaitForChild("GuiToolSlot")

local GuiToolSlotController = require(script.Parent:WaitForChild("GuiToolSlotController"))
local GuiTooltipController = require(script.Parent:WaitForChild("GuiTooltipController"))

local GuiEquipSlotsRaw = Utility:DeepCopy(CommonMoudleFacade.TArray)
GuiEquipSlotsRaw:Initialize(MaxEquipSlotCount)
local GuiEquipSlotsController = {
	GuiEquipSlotsRaw = GuiEquipSlotsRaw
}

function GuiEquipSlotsController:InitializeGuiToolSlots()
	local GuiEquipSlotsSize = GuiEquipSlots.AbsoluteWindowSize
	local finalGuiInventoryWidth = GuiEquipSlotsSize.X
	local GuiInventoryWidth = GuiInventory.AbsoluteSize.X
	
	local finalSlotSize = (finalGuiInventoryWidth - (GuiInventorySlotCountPerLine + 1) * GuiInventorySlotOffset) / GuiInventorySlotCountPerLine
	
	local GuiInventorySlotLineCount = math.ceil(MaxInventorySlotCount / GuiInventorySlotCountPerLine)
	
	local finalGuiInventoryHeight = finalSlotSize * GuiInventorySlotLineCount + GuiInventorySlotOffset * (GuiInventorySlotLineCount + 1)
	
	local slotRateX = finalSlotSize / GuiInventoryWidth
	local halfSlotRateX = slotRateX / 2
	local slotRateY = finalSlotSize / finalGuiInventoryHeight
	local halfSlotRateY = slotRateY / 2
	
	local GuiInventoryOffsetRateX =  GuiInventorySlotOffset / GuiInventoryWidth
	local GuiInventoryOffsetRateY =  GuiInventorySlotOffset / finalGuiInventoryHeight
	
	local slotSize = UDim2.new(slotRateX, 0, slotRateY, 0)
	local slotAnchorPoint = Vector2.new(0.5, 0.5)
	local FirstslotPosition = UDim2.new(GuiInventoryOffsetRateX + halfSlotRateX, 0, GuiInventoryOffsetRateY + halfSlotRateY, 0)

	
	GuiInventory.CanvasSize = UDim2.new(0, 0, finalGuiInventoryHeight / GuiInventorySize.Y, 0)
	
	for y = 0, (GuiInventorySlotLineCount -1) do
		for x = 0, (GuiInventorySlotCountPerLine - 1) do
			
			local newGuiToolSlot = GuiToolSlotTemplate:Clone()
			local slotIndex = y * GuiInventorySlotCountPerLine + x + 1
			
			newGuiToolSlot.Size = slotSize
			newGuiToolSlot.AnchorPoint = slotAnchorPoint
			newGuiToolSlot.Position = FirstslotPosition + UDim2.new((GuiInventoryOffsetRateX + slotRateX) * x, 0, (GuiInventoryOffsetRateY + slotRateY) * y, 0)
			newGuiToolSlot.Parent = GuiInventory
			newGuiToolSlot.Name = tostring(slotIndex)

			self.GuiInventoryRaw:Set(slotIndex, GuiToolSlotController:new(slotIndex, newGuiToolSlot))
		end
	end
end

function GuiEquipSlotsController:GetToolSlot(slotIndex)
    if not slotIndex then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end
end

function GuiEquipSlotsController:SetToolSlot(slotIndex, tool)
	if not slotIndex then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local targetGuiToolSlotController = self.GuiInventoryRaw:Get(slotIndex)
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

GuiEquipSlotsController:InitializeGuiToolSlots()
return GuiEquipSlotsController
