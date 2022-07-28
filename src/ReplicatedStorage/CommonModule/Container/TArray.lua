local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))
local CommonConstant = require(CommonModule:WaitForChild("CommonConstant"))
local UndefinedElementValue = CommonConstant.UndefinedElementValue

local Container = CommonModule:WaitForChild("Container")
local TContainerBase = Utility:DeepCopy(require(Container:WaitForChild("TContainerBase")))

local TArray = TContainerBase

function TArray:Initialize(maxCount)
	self:InitializeRaw(maxCount)
	
	if maxCount <= 0  then
		Debug.Assert(false, "배열 크기가 비정상입니다.")
		return false
	end
	for index = 1, maxCount do
		self.Value[index] = UndefinedElementValue
	end
	
	self.ValueToIndexTable = {}
	return true
end

function TArray:GetValue()
	return self.Value
end

function TArray:GetValueToIndexTable()
	return self.ValueToIndexTable
end

function TArray:IsEmptyIndex(index)
	return (self.Value[index] == UndefinedElementValue)
end

function TArray:IsFull()
	return self.CurrentCount >= self.MaxCount
end

function TArray:CheckIndex(index)
	if not self:CheckIndexRaw(index) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	if index > self.MaxCount then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	return true
end

function TArray:SetRaw(index, object)
	local isEmptyIndex = self:IsEmptyIndex(index)
	if object then
		if isEmptyIndex then
			self.CurrentCount += 1
		end
	else -- if not object then
		object = UndefinedElementValue
		if not isEmptyIndex then
			self.CurrentCount -= 1
		end
	end
	
	if not isEmptyIndex then
		self.ValueToIndexTable[self:GetRaw(index)] = nil
	end

	self.ValueToIndexTable[object] = index
	self.Value[index] = object
end

function TArray:Set(index, object)
	if not self:CheckIndex(index) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	self:SetRaw(index, object)
	return true
end

function TArray:GetRaw(index)
	return self.Value[index]
end

function TArray:Get(index)
	if not self:CheckIndex(index) then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end
	
	return self:GetRaw(index)
end

function TArray:Push(object)
	if self:IsFull() then
		Debug.Assert("비어 있는 공간이 없습니다.")
		return false
	end
	
	if not object then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
		
	local maxCount = self.MaxCount
	for index = 1, maxCount do
		if self:IsEmptyIndex(index) then
			self:SetRaw(index, object)
			return true
		end
	end
	
	Debug.Assert(false, "버그입니다. 확인해야합니다.")
	return false
end

function TArray:PopByIndex(index)
	if not self:CheckIndex(index) then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end
	
	local object = self:GetRaw(index)
	self:SetRaw(index, nil)
	
	return object
end

function TArray:GetIndex(value)
	if not value then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end
	
	return self.ValueToIndexTable[value]
end

function TArray:PopByValue(value)
	local targetIndex = self:GetIndex(value)
	if not targetIndex then
		Debug.Assert(false, "값이 존재하지 않습니다.")
		return nil
	end
	
	local result = self:PopByIndex(targetIndex)
	if not result then
		Debug.Assert(false, "인덱스 매핑에 버그가 있습니다.")
		return nil
	end
	
	return result
end

return TArray
