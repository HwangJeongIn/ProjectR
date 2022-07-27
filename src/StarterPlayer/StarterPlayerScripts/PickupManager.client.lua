local UIS = game:GetService("UserInputService")
local pickupKey = "F"

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local PlayerGui = player:WaitForChild("PlayerGui")
local GuiObjectTooltip = PlayerGui:WaitForChild("GuiObjectTooltip")
--local SlotTooltip = PlayerGui:WaitForChild("SlotTooltip")


-- 인벤토리 초기화



local GuiPlayerStatus = PlayerGui:WaitForChild("GuiPlayerStatus")
local GuiPlayerStatusWindow = GuiPlayerStatus:WaitForChild("GuiPlayerStatusWindow")
local GuiEquipSlots = GuiPlayerStatusWindow:WaitForChild("GuiEquipSlots")
local GuiInventory = GuiPlayerStatusWindow:WaitForChild("GuiInventory")

local GuiInventoryItemSlot = GuiInventory:WaitForChild("GuiItemSlot")




function InitializeGuiInventorySlots()
	
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local CommonMoudleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
	local CommonConstant = CommonMoudleFacade.CommonConstant
	
	local PlayerGui = player:WaitForChild("PlayerGui")
	local GuiPlayerStatus = PlayerGui:WaitForChild("GuiPlayerStatus")
	local GuiPlayerStatusWindow = GuiPlayerStatus:WaitForChild("GuiPlayerStatusWindow")
	--local GuiEquipSlots = GuiPlayerStatusWindow:WaitForChild("GuiEquipSlots")
	local GuiInventory = GuiPlayerStatusWindow:WaitForChild("GuiInventory")

	local GuiInventoryItemSlot = GuiInventory:WaitForChild("GuiItemSlot")

	
	local MaxInventorySlotCount = CommonConstant.MaxInventorySlotCount
	local GuiInventorySlotCountPerLine = CommonConstant.GuiInventorySlotCountPerLine
	local GuiInventorySlotOffset = CommonConstant.GuiInventorySlotOffset
	
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
	
	GuiInventoryItemSlot.Size = UDim2.new(slotRateX, 0, slotRateY, 0)
	GuiInventoryItemSlot.Position = UDim2.new(GuiInventoryOffsetRateX + halfSlotRateX, 0, GuiInventoryOffsetRateY + halfSlotRateY, 0)
	GuiInventoryItemSlot.AnchorPoint = Vector2.new(0.5, 0.5)
	
	GuiInventory.CanvasSize = UDim2.new(0, 0, finalGuiInventoryHeight / GuiInventorySize.Y, 0)
	
	local GuiInventorySlotMap = {}
	for y = 0, (GuiInventorySlotLineCount -1) do
		for x = 0, (GuiInventorySlotCountPerLine - 1) do
			
			local newGuiInventorySlot = GuiInventoryItemSlot:Clone()
			local slotIndex = y * GuiInventorySlotCountPerLine + x
			newGuiInventorySlot.Position += UDim2.new((GuiInventoryOffsetRateX + slotRateX) * x, 0, (GuiInventoryOffsetRateY + slotRateY) * y, 0)
			newGuiInventorySlot.Parent = GuiInventory
			newGuiInventorySlot.Name = tostring(slotIndex)
			GuiInventorySlotMap[slotIndex] = newGuiInventorySlot
		end
	end
	
	GuiInventoryItemSlot:Destroy()
	return GuiInventorySlotMap
end


InitializeGuiInventorySlots()


UIS.InputChanged:Connect(function(input)
	
	if mouse.Target then
		local target = mouse.Target.Parent
		if target.ClassName == "Tool" then

			GuiObjectTooltip.Adornee = mouse.Target
			GuiObjectTooltip.GuiObjectName.Text = target.Name

			GuiObjectTooltip.Enabled = true
			-- targetParent.Name
		else
			GuiObjectTooltip.Adornee = nil
			GuiObjectTooltip.Enabled = false
		end
		--if mouse.Target:FindFirstChild("")
	end
		
end)

UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode[pickupKey] then
		if mouse.Target then
			local target = mouse.Target.Parent
			if target.ClassName == "Tool" then
				local distanceFromItem = player:DistanceFromCharacter(mouse.Target.Position)
	
				if distanceFromItem < 30 then
					print("pick up!")
				end
			end
		end
	end
end)