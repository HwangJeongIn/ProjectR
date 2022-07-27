local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")
local Utility = require(CommonModule:WaitForChild("Utility"))

local CommonConstant = {
	MaxQuickSlotCount = 5,
	MaxInventorySlotCount = 30,
	GuiInventorySlotCountPerLine = 5,
	GuiInventorySlotOffset = 5,
	UndefinedElementValue = false
}

CommonConstant.__index = Utility.Inheritable__index
CommonConstant.__newindex = Utility.Inheritable__newindex

return CommonConstant
