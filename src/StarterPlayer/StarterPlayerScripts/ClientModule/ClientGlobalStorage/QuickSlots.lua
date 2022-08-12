local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))

local CommonConstant = require(CommonModule:WaitForChild("CommonConstant"))
local MaxQuickSlotCount = CommonConstant.MaxQuickSlotCount

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local ToolType = CommonEnum.ToolType

local ContainerModule = CommonModule:WaitForChild("ContainerModule")
local QuickSlotsRaw = Utility:DeepCopy(require(ContainerModule:WaitForChild("TArray")))
QuickSlotsRaw:Initialize(MaxQuickSlotCount)

local QuickSlots = {}
QuickSlots.QuickSlotsRaw = QuickSlotsRaw

function QuickSlots:GetSlotIndex(tool)
	if not tool then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end
	
	return self.QuickSlotsRaw:GetIndex(tool)
end

function QuickSlots:GetSlot(slotIndex)
    local targetTool = self.QuickSlotsRaw:Get(slotIndex)
    if nil == targetTool then
        Debug.Assert(false, "슬롯 인덱스가 비정상입니다.")
        return nil
    end

    return targetTool
end

function QuickSlots:SetSlot(slotIndex, tool)
	if not slotIndex then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not self.QuickSlotsRaw:Set(slotIndex, tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function QuickSlots:SwapSlot(slotIndex1, slotIndex2)
	local tool1 = self.QuickSlotsRaw:Get(slotIndex1)
	local tool2 = self.QuickSlotsRaw:Get(slotIndex2)

	-- 그냥 비어있는 슬롯이라면 UndefinedElementValue 값을 가진다.
	if nil == tool1 or nil == tool2 then
		Debug.Assert(false, "슬롯 인덱스가 비정상입니다.")
		return false
	end

	self.QuickSlotsRaw:SetRaw(slotIndex1, tool2)
	self.QuickSlotsRaw:SetRaw(slotIndex2, tool1)
	return true
end


return QuickSlots
