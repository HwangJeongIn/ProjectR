local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")
local Utility = require(CommonModule:WaitForChild("Utility"))
local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local EquipSlotCount = CommonEnum.EquipType.Count - 1


local CommonConstant = {
	MaxInventorySlotCount = 30,
	MaxEquipSlotCount = EquipSlotCount,

	MaxQuickSlotCount = 5,
	MaxSkillCount = 3,

	GuiInventorySlotCountPerLine = 5,
	GuiInventorySlotOffset = 2.5,
	GuiEquipSlotCountPerRow = 3,
	GuiEquipSlotCountPerColumn = 4,
	GuiEquipSlotOffset = 10,
	
	UndefinedElementValue = false
}

CommonConstant.__index = Utility.Inheritable__index
CommonConstant.__newindex = Utility.Inheritable__newindex

return CommonConstant
