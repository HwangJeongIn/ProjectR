local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local StatType = CommonEnum.StatType
local StatTypeConverter = StatType.Converter

--[[

local CommonConstant = require(CommonModule:WaitForChild("CommonConstant"))
local MaxInventorySlotCount = CommonConstant.MaxInventorySlotCount


local ToolType = CommonEnum.ToolType

local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local CommonGameDataManager = require(CommonGameDataModule:WaitForChild("CommonGameDataManager"))
--]]

local PlayerStatistic = {
    Value = {}
}

local EmptyStatistic = {
	[StatType.STR] = 0,
	[StatType.DEF] = 0,
	[StatType.Move] = 0,
	[StatType.Jump] = 0,
	[StatType.AttackSpeed] = 0,
	
	[StatType.Hp] = 0,
	[StatType.Mp] = 0,
	[StatType.Hit] = 0,
	[StatType.Dodge] = 0,
	[StatType.Block] = 0,
	[StatType.Critical] = 0,
	[StatType.Sight] = 0
}
Debug.Assert(StatType.Count == #EmptyStatistic + 1, "여기도 갱신해야합니다.")


function PlayerStatistic:CreateEmptyStatistic()
	return Utility:DeepCopy(EmptyStatistic)
end

function PlayerStatistic:ClearData()
    self.Value = self:CreateEmptyStatistic()
end

function PlayerStatistic:GetPlayerStatisticRaw()
	return self.Value
end

function PlayerStatistic:GetStat(statType)
	local targetStat = self.Value[statType]
	if nil == targetStat then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	return targetStat
end

function PlayerStatistic:UpdateStatFromToolGameData(toolGameData, isAdded)
	if not toolGameData then
        Debug.Assert(false, "비정상입니다.")
		return false
	end
	
    local toolGameDataRaw = getmetatable(toolGameData)
	for attribute, value in pairs(toolGameDataRaw) do
		local attributeIndex = StatType[attribute]
		if not attributeIndex then
			continue
		end

		if not self.Value[attributeIndex] then
			Debug.Assert(false, "비정상입니다. => " .. tostring(attributeIndex))
			return false
		end

		if isAdded then
			self.Value[attributeIndex] += value
		else
			self.Value[attributeIndex] -= value
		end
	end
	
	return true
end

function PlayerStatistic:UpdateRemovedToolGameData(toolGameData)
	return self:UpdateStatFromToolGameData(toolGameData, false)
end

function PlayerStatistic:UpdateAddedToolGameData(toolGameData)
	return self:UpdateStatFromToolGameData(toolGameData, true)
end

PlayerStatistic:ClearData()

return PlayerStatistic
