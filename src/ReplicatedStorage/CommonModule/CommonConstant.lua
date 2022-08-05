local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")
local Utility = require(CommonModule:WaitForChild("Utility"))
local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local EquipSlotCount = CommonEnum.EquipType.Count - 1


local CommonConstant = {
	-- Inventory
	MaxInventorySlotCount = 30,
	GuiInventorySlotCountPerLine = 5,
	GuiInventorySlotOffsetRatio = 0.005,

	-- EquipSlots
	MaxEquipSlotCount = EquipSlotCount,
	GuiEquipSlotCountPerRow = 3,
	GuiEquipSlotCountPerColumn = 4,
	GuiEquipSlotOffsetRatio = 0.025,

	-- QuickSlots
	MaxQuickSlotCount = 5,
	GuiQuickSlotOffsetRatio = 0.05,

	-- SkillSlots
	MaxSkillCount = 4,
	-- 0.25보다 클수 없음
	GuiSkillSlotOffsetRatio = 0.075,
	
	UndefinedElementValue = false
}

CommonConstant.__index = Utility.Inheritable__index
CommonConstant.__newindex = Utility.Inheritable__newindex

return CommonConstant
