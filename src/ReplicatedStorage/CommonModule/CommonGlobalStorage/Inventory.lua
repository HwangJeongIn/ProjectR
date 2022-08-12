local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))

local CommonConstant = require(CommonModule:WaitForChild("CommonConstant"))
local MaxInventorySlotCount = CommonConstant.MaxInventorySlotCount

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType
local ToolType = CommonEnum.ToolType

local ContainerModule = CommonModule:WaitForChild("ContainerModule")
local InventoryRaw = Utility:DeepCopy(require(ContainerModule:WaitForChild("TArray")))

local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local CommonGameDataManager = require(CommonGameDataModule:WaitForChild("CommonGameDataManager"))

InventoryRaw:Initialize(MaxInventorySlotCount)

local CommonObjectUtilityModule = CommonModule:WaitForChild("CommonObjectUtilityModule")
local ToolUtility = require(CommonObjectUtilityModule:WaitForChild("ToolUtility"))

local Inventory = {}
Inventory.InventoryRaw = InventoryRaw
Inventory[ToolType.Armor] = Utility:DeepCopy(InventoryRaw)
Inventory[ToolType.Weapon] = Utility:DeepCopy(InventoryRaw)
Inventory[ToolType.Consumable] = Utility:DeepCopy(InventoryRaw)


function Inventory:GetSlot(slotIndex)
	local targetTool = self.InventoryRaw:Get(slotIndex)
	if nil == targetTool then
		Debug.Assert(false, "슬롯 인덱스가 비정상입니다.")
		return nil
	end

	return targetTool
end

function Inventory:GetSlots(toolType)
	if toolType == ToolType.All then
		return self.InventoryRaw.GetValue()
	end
	
	return self[toolType]:GetValueToIndexTable()
end

function Inventory:GetSlotIndexRaw(tool)
	return self.InventoryRaw:GetIndex(tool)
end

function Inventory:GetSlotIndex(tool)
	if not tool then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local slotIndex = self.InventoryRaw:GetIndex(tool)
	if not slotIndex then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end
	
	return slotIndex
end

function Inventory:AddToolToSlot(slotIndex, tool)
	if not slotIndex or not tool then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not self.InventoryRaw:Set(slotIndex, tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local toolGameData = ToolUtility:GetGameData(tool)
	if not toolGameData then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not self[toolGameData.ToolType]:Push(tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function Inventory:RemoveToolFromSlot(slotIndex, tool)
	if not slotIndex or not tool then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not self.InventoryRaw:Set(slotIndex, nil) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local toolGameData = ToolUtility:GetGameData(tool)
	if not toolGameData then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not self[toolGameData.ToolType]:PopByValue(tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function Inventory:AddTool(tool)
	local toolGameData = ToolUtility:GetGameData(tool)
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
	local toolGameData = ToolUtility:GetGameData(tool)
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

function Inventory:SwapSlot(slotIndex1, slotIndex2)
	local tool1 = self.InventoryRaw:Get(slotIndex1)
	local tool2 = self.InventoryRaw:Get(slotIndex2)

	-- 그냥 비어있는 슬롯이라면 UndefinedElementValue 값을 가진다.
	if nil == tool1 or nil == tool2 then
		Debug.Assert(false, "슬롯 인덱스가 비정상입니다.")
		return false
	end

	self.InventoryRaw:SetRaw(slotIndex1, tool2)
	self.InventoryRaw:SetRaw(slotIndex2, tool1)
	return true
end


return Inventory
