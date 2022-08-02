local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")
local Utility = require(CommonModule:WaitForChild("Utility"))
local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local EquipSlotCount = CommonEnum.ArmorType.Count - 1


local CommonConstant = {
	MaxQuickSlotCount = 5,
	MaxInventorySlotCount = 30,
	MaxEquipSlotCount = EquipSlotCount,
	GuiInventorySlotCountPerLine = 5,
	GuiInventorySlotOffset = 5,
	GuiEquipSlotCountPerRow = 3,
	GuiEquipSlotCountPerColumn = 4,
	GuiEquipSlotOffset = 10,
	
	UndefinedElementValue = false
}

CommonConstant.__index = Utility.Inheritable__index
CommonConstant.__newindex = Utility.Inheritable__newindex

return CommonConstant
