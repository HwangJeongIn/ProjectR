local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))

local CommonConstant = require(CommonModule:WaitForChild("CommonConstant"))
local MaxEquipSlotCount = CommonConstant.MaxEquipSlotCount

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local ToolType = CommonEnum.ToolType

local Container = CommonModule:WaitForChild("Container")
local ArmorSlotsRaw = Utility.DeepCopy(require(Container:WaitForChild("TArray")))
ArmorSlotsRaw:Initialize(MaxEquipSlotCount)

local EquipSlots = Utility.DeepCopy(require(script.Parent:WaitForChild("SlotBase")))
EquipSlots.ArmorSlotsRaw = ArmorSlotsRaw
EquipSlots.WeaponSlot = nil

function EquipSlots:CheckEquipToolGameData(toolGameData)
	if not toolGameData then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

    local targetToolType = toolGameData.ToolType
    if not targetToolType == ToolType.Armor and not targetToolType == ToolType.Weapon then
		return false
    end

    return true
end

function EquipSlots:CheckWeaponToolGameData(toolGameData)
    if not toolGameData then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

    local targetToolType = toolGameData.ToolType
    if not targetToolType == ToolType.Weapon then
		return false
    end

    return true
end

function EquipSlots:EquipTool(tool, withCheck)
    local toolGameData = self:GetToolGameData(tool)
    if not toolGameData then
		Debug.Assert(false, "비정상입니다.")
		return nil, nil
	end

    if withCheck then
        if not self:CheckEquipToolGameData(toolGameData) then
            Debug.Assert(false, "비정상입니다.")
            return nil, nil
        end
    end

    local targetToolType = toolGameData.ToolType
    local prevTool = nil
    if  targetToolType == ToolType.Armor then
        local targetArmorType = toolGameData.ArmorType
        prevTool = self.ArmorSlotsRaw:Get(targetArmorType)
        self.ArmorSlotsRaw:Set(tool)
    else
        if self.WeaponSlot then
            prevTool = self.WeaponSlot
        end
        self.WeaponSlot = tool
    end

    local prevToolGameData = nil
    if prevTool then
        prevToolGameData = self:GetToolGameData(prevTool)
        if not prevToolGameData then
            Debug.Assert(false, "도구는 존재하지만 데이터가 존재하지 않습니다.")
        end
    end

    return prevToolGameData, toolGameData
end

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


return EquipSlots
