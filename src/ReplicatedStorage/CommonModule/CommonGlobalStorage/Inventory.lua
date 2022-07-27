local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))

local CommonConstant = require(CommonModule:WaitForChild("CommonConstant"))
local MaxInventorySlotCount = CommonConstant.MaxInventorySlotCount

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType
local ToolType = CommonEnum.ToolType

local Container = CommonModule:WaitForChild("Container")
local InventoryRaw = Utility.DeepCopy(require(Container:WaitForChild("TArray")))

local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local CommonGameDataManager = require(CommonGameDataModule:WaitForChild("CommonGameDataManager"))

InventoryRaw:Initialize(MaxInventorySlotCount)

local Inventory = Utility.DeepCopy(require(script.Parent:WaitForChild("SlotBase")))
Inventory.InventoryRaw = InventoryRaw
Inventory[ToolType.Armor] = Utility.DeepCopy(InventoryRaw)
Inventory[ToolType.Weapon] = Utility.DeepCopy(InventoryRaw)
Inventory[ToolType.Consumable] = Utility.DeepCopy(InventoryRaw)

function Inventory:GetSlots(toolType)
	if toolType == ToolType.All then
		return self.InventoryRaw.GetValue()
	end
	
	return self[toolType]:GetValueToIndexTable()
end

function Inventory:AddTool(tool)
	local toolGameData = self:GetToolGameData(tool)
	if not toolGameData then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	if not self.InventoryRaw:Push(tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	if not self[toolGameData.ToolType]:Push(tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	return true
end

function Inventory:RemoveTool(tool)
	local toolGameData = self:GetToolGameData(tool)
	if not toolGameData then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	if not self.InventoryRaw:PopByValue(tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not self[toolGameData.ToolType]:PopByValue(tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	return true
end


return Inventory
