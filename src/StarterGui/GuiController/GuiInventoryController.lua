local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonMoudleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonMoudleFacade.Debug
local Utility = CommonMoudleFacade.Utility
local ToolUtility = CommonMoudleFacade.ToolUtility
local CommonConstant = CommonMoudleFacade.CommonConstant

local MaxInventorySlotCount = CommonConstant.MaxInventorySlotCount
local GuiInventorySlotCountPerLine = CommonConstant.GuiInventorySlotCountPerLine
local GuiInventorySlotOffsetRatio = CommonConstant.GuiInventorySlotOffsetRatio

local CommonEnum = CommonMoudleFacade.CommonEnum
local SlotType = CommonEnum.SlotType


local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiFacade = require(PlayerGui:WaitForChild("GuiFacade"))
local GuiInventory = GuiFacade.GuiInventory

local GuiToolSlotTemplate = GuiFacade.GuiTemplate.GuiToolSlot
local GuiToolSlotController = GuiFacade.GuiTemplateController.GuiToolSlotController

local GuiInventoryRaw = Utility:DeepCopy(CommonMoudleFacade.TArray)
GuiInventoryRaw:Initialize(MaxInventorySlotCount)
local GuiInventoryController = {
	GuiInventoryRaw = GuiInventoryRaw
}

function GuiInventoryController:Initialize()
	local GuiInventorySize = GuiInventory.AbsoluteWindowSize
	local finalGuiInventoryWidth = GuiInventorySize.X
	local GuiInventoryWidth = GuiInventory.AbsoluteSize.X
	
	local GuiInventorySlotOffset = GuiInventorySlotOffsetRatio * finalGuiInventoryWidth
	local finalSlotSize = (finalGuiInventoryWidth - (GuiInventorySlotCountPerLine + 1) * GuiInventorySlotOffset) / GuiInventorySlotCountPerLine
	
	local GuiInventorySlotLineCount = math.ceil(MaxInventorySlotCount / GuiInventorySlotCountPerLine)
	
	local finalGuiInventoryHeight = finalSlotSize * GuiInventorySlotLineCount + GuiInventorySlotOffset * (GuiInventorySlotLineCount + 1)
	
	local slotRatioX = finalSlotSize / GuiInventoryWidth
	local halfSlotRatioX = slotRatioX / 2
	local slotRatioY = finalSlotSize / finalGuiInventoryHeight
	local halfSlotRatioY = slotRatioY / 2
	
	local GuiInventoryOffsetRatioX =  GuiInventorySlotOffset / GuiInventoryWidth
	local GuiInventoryOffsetRatioY =  GuiInventorySlotOffset / finalGuiInventoryHeight
	
	local slotSize = UDim2.new(slotRatioX, 0, slotRatioY, 0)
	local slotAnchorPoint = Vector2.new(0.5, 0.5)
	local firstSlotPosition = UDim2.new(GuiInventoryOffsetRatioX + halfSlotRatioX, 0, GuiInventoryOffsetRatioY + halfSlotRatioY, 0)

	
	GuiInventory.CanvasSize = UDim2.new(0, 0, finalGuiInventoryHeight / GuiInventorySize.Y, 0)
	
	for y = 0, (GuiInventorySlotLineCount -1) do
		for x = 0, (GuiInventorySlotCountPerLine - 1) do
			
			local newGuiToolSlot = GuiToolSlotTemplate:Clone()
			local slotIndex = y * GuiInventorySlotCountPerLine + x + 1
			
			newGuiToolSlot.Size = slotSize
			newGuiToolSlot.AnchorPoint = slotAnchorPoint
			newGuiToolSlot.Position = firstSlotPosition + UDim2.new((GuiInventoryOffsetRatioX + slotRatioX) * x, 0, (GuiInventoryOffsetRatioY + slotRatioY) * y, 0)
			newGuiToolSlot.Parent = GuiInventory
			newGuiToolSlot.Name = tostring(slotIndex)

			self.GuiInventoryRaw:Set(slotIndex, GuiToolSlotController:new(SlotType.InventorySlot, slotIndex, newGuiToolSlot))
		end
	end
end

function GuiInventoryController:GetToolSlot(slotIndex)
    if not slotIndex then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end
end

function GuiInventoryController:SetToolSlot(slotIndex, tool)
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

GuiInventoryController:Initialize()
return GuiInventoryController
