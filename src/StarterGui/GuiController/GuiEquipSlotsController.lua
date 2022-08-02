local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonMoudleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonMoudleFacade.Debug
local Utility = CommonMoudleFacade.Utility
local ToolUtility = CommonMoudleFacade.ToolUtility
local CommonConstant = CommonMoudleFacade.CommonConstant
local CommonEnum = CommonMoudleFacade.CommonEnum
local SlotType = CommonEnum.SlotType

local MaxEquipSlotCount = CommonConstant.MaxEquipSlotCount
local GuiEquipSlotCountPerColumn = CommonConstant.GuiEquipSlotCountPerColumn
local GuiEquipSlotCountPerRow = CommonConstant.GuiEquipSlotCountPerRow
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

function GuiEquipSlotsController:AddSlotDataToGuiEquipSlotsMetaData(metaData, slotIndex, slotType)
	if not metaData or not slotIndex or not slotType then
		Debug.Assert(false, "비정상입니다.")
		return
	end
end

function GuiEquipSlotsController:InitializeGuiEquipSlotsMetaData(metaData)
	--[[
		1	2	3
		4	5	6
		7	8	9
		10	11	12
	--]]

	if not metaData then
		Debug.Assert(false, "비정상입니다.")
		return
	end


end

function GuiEquipSlotsController:InitializeGuiToolSlots()

	local GuiEquipSlotsMetaData = {}
	self:InitializeGuiEquipSlotsMetaData(GuiEquipSlotsMetaData)

	local GuiEquipSlotWidth = GuiEquipSlots.AbsoluteSize.X
	local GuiEquipSlotHeight = GuiEquipSlots.AbsoluteSize.Y

	local finalSlotSize = 0
	local GuiEquipSlotOffsetX = 0
	local GuiEquipSlotOffsetY = 0

	if GuiEquipSlotWidth < GuiEquipSlotHeight then
		finalSlotSize = (GuiEquipSlotWidth - (GuiEquipSlotCountPerRow + 1) * GuiEquipSlotOffset) / GuiEquipSlotCountPerRow
		GuiEquipSlotOffsetX = GuiEquipSlotOffset
		GuiEquipSlotOffsetY = (finalSlotSize * GuiEquipSlotCountPerColumn) / (GuiEquipSlotCountPerColumn + 1)
	else
		finalSlotSize = (GuiEquipSlotHeight - (GuiEquipSlotCountPerColumn + 1) * GuiEquipSlotOffset) / GuiEquipSlotCountPerColumn
		GuiEquipSlotOffsetX = (finalSlotSize * GuiEquipSlotCountPerRow) / (GuiEquipSlotCountPerRow + 1)
		GuiEquipSlotOffsetY = GuiEquipSlotOffset
	end

	local slotRateX = finalSlotSize / GuiEquipSlotCountPerRow
	local halfSlotRateX = slotRateX / 2
	local slotRateY = finalSlotSize / GuiEquipSlotCountPerColumn
	local halfSlotRateY = slotRateY / 2

	local GuiEquipSlotOffsetRateX =  GuiEquipSlotOffsetX / GuiEquipSlotCountPerRow
	local GuiEquipSlotOffsetRateY =  GuiEquipSlotOffsetY / GuiEquipSlotCountPerColumn
	
	local slotSize = UDim2.new(slotRateX, 0, slotRateY, 0)
	local slotAnchorPoint = Vector2.new(0.5, 0.5)
	local FirstslotPosition = UDim2.new(GuiEquipSlotOffsetRateX + halfSlotRateX, 0, GuiEquipSlotOffsetRateY + halfSlotRateY, 0)

	
	for y = 0, (GuiEquipSlotCountPerColumn -1) do
		for x = 0, (GuiEquipSlotCountPerRow - 1) do
			
			local newGuiToolSlot = GuiToolSlotTemplate:Clone()
			local slotIndex = y * GuiEquipSlotCountPerRow + x + 1
			
			newGuiToolSlot.Size = slotSize
			newGuiToolSlot.AnchorPoint = slotAnchorPoint
			newGuiToolSlot.Position = FirstslotPosition + UDim2.new((GuiEquipSlotOffsetRateX + slotRateX) * x, 0, (GuiEquipSlotOffsetRateY + slotRateY) * y, 0)
			newGuiToolSlot.Parent = GuiEquipSlots
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
