local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))
local CommonConstant = require(CommonModule:WaitForChild("CommonConstant"))
local UndefinedElementValue = CommonConstant.UndefinedElementValue

local Container = CommonModule:WaitForChild("Container")
local TContainerBase = Utility.DeepCopy(require(Container:WaitForChild("TContainerBase")))

local TList = TContainerBase

function TList:Initialize(maxCount)
	self:InitializeRaw(maxCount)
	return true
end

function TList:IsFull()
	if self.MaxCount then
		return self.CurrentCount >= self.MaxCount
	else -- if not self.MaxCount then
		return false		
	end
end

function TList:CheckIndex(index)
	if not self:CheckIndexRaw(index) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if index > self.CurrentCount then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function TList:SetRaw(index, object)
	if not object  then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	self.Value[index] = object
end

function TList:Set(index, object)
	if not self:CheckIndex(index) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not self:SetRaw(index, object) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	return true
end

function TList:GetRaw(index)
	return self.Value[index]
end

function TList:Get(index)
	if not self:CheckIndex(index) then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	return self:GetRaw(index)
end

function TList:Push(object)
	if not object then
		Debug.Assert(false, "비정상입니다.")
		return false	
	end

	if self:IsFull() then
		Debug.Assert(false, "더 이상 추가할 수 없습니다.")
		return false	
	end

	self.CurrentCount += 1
	table.insert(self.Value, object)
	return true
end

function TList:Pop(index)
	if not self:CheckIndex(index) then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local object = self:GetRaw(index)
	table.remove(self.Value, index)
	self.CurrentCount -= 1
	
	return object
end

function TList:PopBack()
	if self:IsEmpty() then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end
	
	local index = self.CurrentCount
	local object = self:GetRaw(index)
	table.remove(self.Value, index)
	self.CurrentCount -= 1

	return object
end

return TList
