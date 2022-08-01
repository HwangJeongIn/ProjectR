local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))

--[[
local Utility = require(CommonModule:WaitForChild("Utility"))

local CommonConstant = require(CommonModule:WaitForChild("CommonConstant"))
local MaxInventorySlotCount = CommonConstant.MaxInventorySlotCount

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType
local ToolType = CommonEnum.ToolType

local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local CommonGameDataManager = require(CommonGameDataModule:WaitForChild("CommonGameDataManager"))
--]]

local PlayerStatistic = {
    Value = {}
}

function PlayerStatistic:CreateEmptyStatistic()
	return {
		DirtyFlag = false,
		STR = 0,
		DEF = 0,
		Move = 0,
		AttackSpeed = 0,
		
		HP = 0,
		MP = 0,
		HIT = 0,
		Dodge = 0,
		Block = 0,
		Critical = 0,
		Sight = 0
	}
end

function PlayerStatistic:ClearData()
    self.Value = self:CreateEmptyStatistic()
end

function PlayerStatistic:UpdateRemovedToolGameData(toolGameData)
	if not toolGameData then
        Debug.Assert(false, "비정상입니다.")
		return false
	end
	
    local toolGameDataRaw = getmetatable(toolGameData)
	for attribute, value in pairs(toolGameDataRaw) do
		if not self.Value[attribute] then
			continue
		end
        self.Value[attribute] -= value
	end
	return true
end

function PlayerStatistic:UpdateAddedToolGameData(toolGameData)
	if not toolGameData then
        Debug.Assert(false, "비정상입니다.")
		return false
	end
	
    local toolGameDataRaw = getmetatable(toolGameData)
	for attribute, value in pairs(toolGameDataRaw) do
		if not self.Value[attribute] then
			continue
		end
        self.Value[attribute] += value
	end
	return true
end

PlayerStatistic:ClearData()

return PlayerStatistic
