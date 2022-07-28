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
local InventoryRaw = Utility:DeepCopy(require(Container:WaitForChild("TArray")))

local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local CommonGameDataManager = require(CommonGameDataModule:WaitForChild("CommonGameDataManager"))

InventoryRaw:Initialize(MaxInventorySlotCount)

local ToolUtility = require(script.Parent:WaitForChild("ToolUtility"))

local Inventory = {}
Inventory.InventoryRaw = InventoryRaw
Inventory[ToolType.Armor] = Utility:DeepCopy(InventoryRaw)
Inventory[ToolType.Weapon] = Utility:DeepCopy(InventoryRaw)
Inventory[ToolType.Consumable] = Utility:DeepCopy(InventoryRaw)

function Inventory:GetSlots(toolType)
	if toolType == ToolType.All then
		return self.InventoryRaw.GetValue()
	end
	
	return self[toolType]:GetValueToIndexTable()
end

function Inventory:GetSlotIndexRaw(tool)
	return InventoryRaw:GetIndex(tool)
end

function Inventory:GetSlotIndex(tool)
	if not tool then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local slotIndex = InventoryRaw:GetIndex(tool)
	if not slotIndex then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end
	
	return slotIndex
end

function Inventory:SetTool(slotIndex, tool)
	if not tool or not slotIndex then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not InventoryRaw:Set(slotIndex) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function Inventory:AddTool(tool)
	local toolGameData = ToolUtility:GetToolGameData(tool)
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
	local toolGameData = ToolUtility:GetToolGameData(tool)
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
