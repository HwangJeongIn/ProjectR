local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonMoudleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonMoudleFacade.Debug
local CommonConstant = CommonMoudleFacade.CommonConstant


local MaxInventorySlotCount = CommonConstant.MaxInventorySlotCount
local GuiInventorySlotCountPerLine = CommonConstant.GuiInventorySlotCountPerLine
local GuiInventorySlotOffset = CommonConstant.GuiInventorySlotOffset


local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiPlayerStatus = PlayerGui:WaitForChild("GuiPlayerStatus")
local GuiPlayerStatusWindow = GuiPlayerStatus:WaitForChild("GuiPlayerStatusWindow")
local GuiEquipSlots = GuiPlayerStatusWindow:WaitForChild("GuiEquipSlots")
local GuiInventory = GuiPlayerStatusWindow:WaitForChild("GuiInventory")
local GuiToolSlot = GuiPlayerStatusWindow:WaitForChild("GuiToolSlot")
local GuiToolSlotController = require(script.Parent:WaitForChild("GuiToolSlotController"))


local GuiInventoryController = {
    GuiInventoryRaw = {}
}

function GuiInventoryController:InitializeGuiToolSlots()
	local GuiInventorySize = GuiInventory.AbsoluteWindowSize
	local finalGuiInventoryWidth = GuiInventorySize.X
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
	
	GuiToolSlot.Size = UDim2.new(slotRateX, 0, slotRateY, 0)
	GuiToolSlot.Position = UDim2.new(GuiInventoryOffsetRateX + halfSlotRateX, 0, GuiInventoryOffsetRateY + halfSlotRateY, 0)
	GuiToolSlot.AnchorPoint = Vector2.new(0.5, 0.5)
	
	GuiInventory.CanvasSize = UDim2.new(0, 0, finalGuiInventoryHeight / GuiInventorySize.Y, 0)
	
	for y = 0, (GuiInventorySlotLineCount -1) do
		for x = 0, (GuiInventorySlotCountPerLine - 1) do
			
			local newGuiToolSlot = GuiToolSlot:Clone()
			local slotIndex = y * GuiInventorySlotCountPerLine + x
			newGuiToolSlot.Position += UDim2.new((GuiInventoryOffsetRateX + slotRateX) * x, 0, (GuiInventoryOffsetRateY + slotRateY) * y, 0)
			newGuiToolSlot.Parent = GuiInventory
			newGuiToolSlot.Name = tostring(slotIndex)

            self.GuiInventoryRaw[slotIndex] = GuiToolSlotController:new(newGuiToolSlot)
		end
	end
end

function GuiInventoryController:SetTool(slotIndex, tool)
    if not tool or not slotIndex then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

    if not self.GuiInventoryRaw[slotIndex] then
		Debug.Assert(false, "비정상입니다.")
		return false
    end

    local guiToolSlotController = self.GuiInventoryRaw[slotIndex]

	if not guiToolSlotController:SetTool(tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

GuiInventoryController:InitializeGuiToolSlots()
return GuiInventoryController
