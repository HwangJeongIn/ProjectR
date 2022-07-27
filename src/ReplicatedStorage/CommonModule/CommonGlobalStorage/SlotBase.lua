local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType

local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local CommonGameDataManager = require(CommonGameDataModule:WaitForChild("CommonGameDataManager"))

local SlotBase = {}

function SlotBase:GetToolGameData(tool)
	
	if not tool then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local key = tool:FindFirstChild("Key")
	if not key then
		Debug.Assert(false, "Key 객체가 존재하지 않습니다. => " .. tostring(tool))
		return nil
	end

	key = key.Value
	local toolGameData = CommonGameDataManager[GameDataType.Tool]:Get(key)
	if not toolGameData then
		Debug.Assert(false, "ToolGameData가 존재하지 않습니다. [key] => " .. tostring(key))
		return nil
	end

	return toolGameData
end


return SlotBase
