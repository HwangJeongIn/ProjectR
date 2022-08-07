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
local GuiEquipSlotOffsetRatio = CommonConstant.GuiEquipSlotOffsetRatio


local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiFacade = require(PlayerGui:WaitForChild("GuiFacade"))
local GuiEquipSlots = GuiFacade.GuiEquipSlots

local GuiToolSlotTemplate = GuiFacade.GuiTemplate.GuiSlot

local GuiToolSlotController = GuiFacade.GuiTemplateController.GuiToolSlotController

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

function GuiEquipSlotsController:Initialize()

	local GuiEquipSlotsMetaData = {}
	self:InitializeGuiEquipSlotsMetaData(GuiEquipSlotsMetaData)

	local GuiEquipSlotsWidth = GuiEquipSlots.AbsoluteSize.X
	local GuiEquipSlotsHeight = GuiEquipSlots.AbsoluteSize.Y

	local finalSlotSize = 0
	local GuiEquipSlotOffsetX = 0
	local GuiEquipSlotOffsetY = 0

	if (GuiEquipSlotsWidth / GuiEquipSlotCountPerRow) < (GuiEquipSlotsHeight / GuiEquipSlotCountPerColumn) then
		local GuiEquipSlotOffset = GuiEquipSlotsWidth * GuiEquipSlotOffsetRatio
		finalSlotSize = (GuiEquipSlotsWidth - (GuiEquipSlotCountPerRow + 1) * GuiEquipSlotOffset) / GuiEquipSlotCountPerRow
		GuiEquipSlotOffsetX = GuiEquipSlotOffset
		GuiEquipSlotOffsetY = (GuiEquipSlotsHeight - (finalSlotSize * GuiEquipSlotCountPerColumn)) / (GuiEquipSlotCountPerColumn + 1)
	else
		local GuiEquipSlotOffset = GuiEquipSlotsHeight * GuiEquipSlotOffsetRatio
		finalSlotSize = (GuiEquipSlotsHeight - (GuiEquipSlotCountPerColumn + 1) * GuiEquipSlotOffset) / GuiEquipSlotCountPerColumn
		GuiEquipSlotOffsetX = (GuiEquipSlotsWidth - (finalSlotSize * GuiEquipSlotCountPerRow)) / (GuiEquipSlotCountPerRow + 1)
		GuiEquipSlotOffsetY = GuiEquipSlotOffset
	end

	local slotRatioX = finalSlotSize / GuiEquipSlotsWidth
	local halfSlotRatioX = slotRatioX / 2
	local slotRatioY = finalSlotSize / GuiEquipSlotsHeight
	local halfSlotRatioY = slotRatioY / 2

	local GuiEquipSlotOffsetRatioX =  GuiEquipSlotOffsetX / GuiEquipSlotsWidth
	local GuiEquipSlotOffsetRatioY =  GuiEquipSlotOffsetY / GuiEquipSlotsHeight
	
	local slotSize = UDim2.new(slotRatioX, 0, slotRatioY, 0)
	local slotAnchorPoint = Vector2.new(0.5, 0.5)
	local firstSlotPosition = UDim2.new(GuiEquipSlotOffsetRatioX + halfSlotRatioX, 0, GuiEquipSlotOffsetRatioY + halfSlotRatioY, 0)

	
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
			newGuiToolSlot.Position = firstSlotPosition + UDim2.new((GuiEquipSlotOffsetRatioX + slotRatioX) * x, 0, (GuiEquipSlotOffsetRatioY + slotRatioY) * y, 0)
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

GuiEquipSlotsController:Initialize()
return GuiEquipSlotsController
