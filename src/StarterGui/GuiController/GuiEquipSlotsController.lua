local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonMoudleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonMoudleFacade.Debug
local Utility = CommonMoudleFacade.Utility
local ToolUtility = CommonMoudleFacade.ToolUtility
local CommonConstant = CommonMoudleFacade.CommonConstant
local CommonEnum = CommonMoudleFacade.CommonEnum
local SlotType = CommonEnum.SlotType
local EquipType = CommonEnum.EquipType

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

function GuiEquipSlotsController:AddSlotDataToGuiEquipSlotsMetaData(metaData, slotPositionIndex, equipType)
	if not metaData or not slotPositionIndex or not equipType then
		Debug.Assert(false, "비정상입니다.")
		return
	end

	metaData[slotPositionIndex] = equipType
end

function GuiEquipSlotsController:InitializeGuiEquipSlotsMetaData(metaData)
	if not metaData then
		Debug.Assert(false, "비정상입니다.")
		return
	end

	--[[
		1	2	3
		4	5	6
		7	8	9
		10	11	12
	--]]
	self:AddSlotDataToGuiEquipSlotsMetaData(metaData, 4, EquipType.Weapon) -- 4번 무기

	self:AddSlotDataToGuiEquipSlotsMetaData(metaData, 2, EquipType.Helmet) -- 2번 헬멧
	self:AddSlotDataToGuiEquipSlotsMetaData(metaData, 5, EquipType.Chestplate) -- 5번 갑옷
	self:AddSlotDataToGuiEquipSlotsMetaData(metaData, 8, EquipType.Leggings) -- 8번 바지
	self:AddSlotDataToGuiEquipSlotsMetaData(metaData, 11, EquipType.Boots) -- 11번 신발
end

function GuiEquipSlotsController:InitializeGuiToolSlots()

	local GuiEquipSlotsMetaData = {}
	self:InitializeGuiEquipSlotsMetaData(GuiEquipSlotsMetaData)

	local GuiEquipSlotWidth = GuiEquipSlots.AbsoluteSize.X
	local GuiEquipSlotHeight = GuiEquipSlots.AbsoluteSize.Y

	local finalSlotSize = 0
	local GuiEquipSlotOffsetX = 0
	local GuiEquipSlotOffsetY = 0

	if (GuiEquipSlotWidth / GuiEquipSlotCountPerRow) < (GuiEquipSlotHeight / GuiEquipSlotCountPerColumn) then
		finalSlotSize = (GuiEquipSlotWidth - (GuiEquipSlotCountPerRow + 1) * GuiEquipSlotOffset) / GuiEquipSlotCountPerRow
		GuiEquipSlotOffsetX = GuiEquipSlotOffset
		GuiEquipSlotOffsetY = (GuiEquipSlotHeight - (finalSlotSize * GuiEquipSlotCountPerColumn)) / (GuiEquipSlotCountPerColumn + 1)
	else
		finalSlotSize = (GuiEquipSlotHeight - (GuiEquipSlotCountPerColumn + 1) * GuiEquipSlotOffset) / GuiEquipSlotCountPerColumn
		GuiEquipSlotOffsetX = (GuiEquipSlotWidth - (finalSlotSize * GuiEquipSlotCountPerRow)) / (GuiEquipSlotCountPerRow + 1)
		GuiEquipSlotOffsetY = GuiEquipSlotOffset
	end

	local slotRateX = finalSlotSize / GuiEquipSlotWidth
	local halfSlotRateX = slotRateX / 2
	local slotRateY = finalSlotSize / GuiEquipSlotHeight
	local halfSlotRateY = slotRateY / 2

	local GuiEquipSlotOffsetRateX =  GuiEquipSlotOffsetX / GuiEquipSlotWidth
	local GuiEquipSlotOffsetRateY =  GuiEquipSlotOffsetY / GuiEquipSlotHeight
	
	local slotSize = UDim2.new(slotRateX, 0, slotRateY, 0)
	local slotAnchorPoint = Vector2.new(0.5, 0.5)
	local FirstslotPosition = UDim2.new(GuiEquipSlotOffsetRateX + halfSlotRateX, 0, GuiEquipSlotOffsetRateY + halfSlotRateY, 0)

	
	for y = 0, (GuiEquipSlotCountPerColumn -1) do
		for x = 0, (GuiEquipSlotCountPerRow - 1) do
			
			local newGuiToolSlot = GuiToolSlotTemplate:Clone()
			local slotPositionIndex = y * GuiEquipSlotCountPerRow + x + 1
			
			local equipType = GuiEquipSlotsMetaData[slotPositionIndex]
			if not equipType  then
				continue
			end

			newGuiToolSlot.Size = slotSize
			newGuiToolSlot.AnchorPoint = slotAnchorPoint
			newGuiToolSlot.Position = FirstslotPosition + UDim2.new((GuiEquipSlotOffsetRateX + slotRateX) * x, 0, (GuiEquipSlotOffsetRateY + slotRateY) * y, 0)
			newGuiToolSlot.Parent = GuiEquipSlots
			newGuiToolSlot.Name = tostring(equipType)

			self.GuiEquipSlotsRaw:Set(equipType, GuiToolSlotController:new(SlotType.EquipSlot, equipType, newGuiToolSlot))
		end
	end
end

function GuiEquipSlotsController:SetToolSlot(equipType, tool)
	if not equipType then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local targetGuiToolSlotController = self.GuiEquipSlotsRaw:Get(equipType)
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
