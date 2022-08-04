local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiFacade = require(PlayerGui:WaitForChild("GuiFacade"))

local GuiQuickSlots = GuiFacade.GuiQuickSlots
local GuiToolSlotTemplate = GuiFacade.GuiTemplate.GuiToolSlot

local GuiQuickSlotsController = {}

function GuiQuickSlotsController:Initialize()

    -- Constant
    local MaxQuickSlotCount = 5
    local GuiQuickSlotOffsetRatio = 0.01


    --local GuiEquipSlotsMetaData = {}
	--self:InitializeGuiEquipSlotsMetaData(GuiEquipSlotsMetaData)

	local GuiQuickSlotsWidth = GuiQuickSlots.AbsoluteSize.X
	local GuiQuickSlotsHeight = GuiQuickSlots.AbsoluteSize.Y

	local GuiQuickSlotOffsetX = 0
	local GuiQuickSlotOffsetY = GuiQuickSlotOffset

	local finalSlotSize = GuiQuickSlotsHeight - (GuiQuickSlotOffsetY * 2)


    --[[
	if (GuiEquipSlotWidth / GuiEquipSlotCountPerRow) < (GuiEquipSlotHeight / GuiEquipSlotCountPerColumn) then
		finalSlotSize = (GuiEquipSlotWidth - (GuiEquipSlotCountPerRow + 1) * GuiEquipSlotOffset) / GuiEquipSlotCountPerRow
		GuiEquipSlotOffsetX = GuiEquipSlotOffset
		GuiEquipSlotOffsetY = (GuiEquipSlotHeight - (finalSlotSize * GuiEquipSlotCountPerColumn)) / (GuiEquipSlotCountPerColumn + 1)
	else
		finalSlotSize = (GuiEquipSlotHeight - (GuiEquipSlotCountPerColumn + 1) * GuiEquipSlotOffset) / GuiEquipSlotCountPerColumn
		GuiEquipSlotOffsetX = (GuiEquipSlotWidth - (finalSlotSize * GuiEquipSlotCountPerRow)) / (GuiEquipSlotCountPerRow + 1)
		GuiEquipSlotOffsetY = GuiEquipSlotOffset
	end

	local slotRatioX = finalSlotSize / GuiEquipSlotWidth
	local halfSlotRatioX = slotRatioX / 2
	local slotRatioY = finalSlotSize / GuiEquipSlotHeight
	local halfSlotRatioY = slotRatioY / 2

	local GuiEquipSlotOffsetRatioX =  GuiEquipSlotOffsetX / GuiEquipSlotWidth
	local GuiEquipSlotOffsetRatioY =  GuiEquipSlotOffsetY / GuiEquipSlotHeight
	
	local slotSize = UDim2.new(slotRatioX, 0, slotRatioY, 0)
	local slotAnchorPoint = Vector2.new(0.5, 0.5)
	local FirstslotPosition = UDim2.new(GuiEquipSlotOffsetRatioX + halfSlotRatioX, 0, GuiEquipSlotOffsetRatioY + halfSlotRatioY, 0)
    --]]
end

GuiQuickSlotsController:Initialize()
return GuiQuickSlotsController
