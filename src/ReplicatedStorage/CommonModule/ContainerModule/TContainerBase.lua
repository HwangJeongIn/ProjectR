local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")
local Debug = require(CommonModule:WaitForChild("Debug"))
local CommonConstant = require(CommonModule:WaitForChild("CommonConstant"))
local UndefinedElementValue = CommonConstant.UndefinedElementValue

local TContainerBase = {
	Value = {
	
	}
}

function TContainerBase:InitializeRaw(maxCount)
	self.CurrentCount = 0	
	self.MaxCount = maxCount
end

function TContainerBase:IsEmpty()
	return (self.CurrentCount == 0)
end

function TContainerBase:CheckIndexRaw(index)
	if not index then
		Debug.Assert(false, "비정상입니다.")
		return false	
	end

	local typeString = type(index)
	if typeString ~= "number" then
		Debug.Assert(false, "비정상입니다.")
		return false	
	end
	
	if index <= 0 then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	return true
	--[[
	local targetLimit = 0

	if self.MaxCount then
		targetLimit = self.MaxCount
	else
		targetLimit = self.CurrentCount
	end
	
	return (index <= targetLimit)
	--]]
end

return TContainerBase
