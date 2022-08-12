local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))

local CommonConstant = require(CommonModule:WaitForChild("CommonConstant"))
local MaxEquipSlotCount = CommonConstant.MaxEquipSlotCount

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local ToolType = CommonEnum.ToolType

local ContainerModule = CommonModule:WaitForChild("ContainerModule")
local EquipSlotsRaw = Utility:DeepCopy(require(ContainerModule:WaitForChild("TArray")))
EquipSlotsRaw:Initialize(MaxEquipSlotCount)

local ToolUtility = require(script.Parent:WaitForChild("ToolUtility"))
local EquipSlots = {}
EquipSlots.EquipSlotsRaw = EquipSlotsRaw

function EquipSlots:GetSlot(slotIndex)
	local targetTool = self.EquipSlotsRaw:Get(slotIndex)
	if nil == targetTool then
		Debug.Assert(false, "슬롯 인덱스가 비정상입니다.")
		return nil
	end

	return targetTool
end

function EquipSlots:UnequipTool(equipType)
    if not equipType then
        Debug.Assert(false, "타입이 비정상입니다.")
        return nil
    end

    local prevTool = self.EquipSlotsRaw:Get(equipType)
    if not prevTool then
        Debug.Assert(false, "장착된 도구가 없습니다.")
        return nil
    else
        self.EquipSlotsRaw:Set(equipType, nil)
    end

    --[[
    local prevToolGameData = ToolUtility:GetGameData(prevTool)
    if not prevToolGameData then
        Debug.Assert(false, "도구는 존재하지만 데이터가 존재하지 않습니다.")
        return nil
    end
    --]]
    return prevTool
end

function EquipSlots:UnequipToolByTool(tool)
    if not tool then
        Debug.Assert(false, "비정상입니다.")
		return nil
    end

    local toolGameData = ToolUtility:GetGameData(tool)
    if not toolGameData then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

    if not ToolUtility:CheckEquipableToolGameData(toolGameData) then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end
    
    local equipType = toolGameData.EquipType
    local prevTool = self.EquipSlotsRaw:Get(equipType)
    if prevTool ~= tool then
        Debug.Assert(false, "해제하려는 장비와 장착중인 장비가 다릅니다. 코드 버그입니다.")
        return nil
    end

    local prevTool = self:UnequipTool(equipType)
    if not prevTool then
        Debug.Assert(false, "장착된 도구가 없습니다.")
        return nil
    end

    return prevTool
end

function EquipSlots:EquipTool(equipType, tool)
    if not equipType or not tool then
        Debug.Assert(false, "비정상입니다.")
		return nil, nil
    end

    local toolGameData = ToolUtility:GetGameData(tool)
    if not toolGameData then
        Debug.Assert(false, "비정상입니다.")
        return nil, nil
    end

    if not ToolUtility:CheckEquipableToolGameData(toolGameData) then
        Debug.Assert(false, "비정상입니다.")
        return nil, nil
    end

    local prevTool = self.EquipSlotsRaw:Get(equipType)
    self.EquipSlotsRaw:Set(equipType, tool)

    --[[
    local prevToolGameData = nil
    if prevTool then
        prevToolGameData = ToolUtility:GetGameData(prevTool)
        if not prevToolGameData then
            Debug.Assert(false, "도구는 존재하지만 데이터가 존재하지 않습니다.")
        end
    end
    --]]

    return prevTool, tool
end


return EquipSlots
