local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType
local GameDataTypeConverter = GameDataType.Converter

local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))


local CommonGameDataManager = {}

CommonGameDataManager.__index = Utility.Inheritable__index
CommonGameDataManager.__newindex = Utility.Inheritable__newindex

function CommonGameDataManager:LoadGameData(gameDataOwner, gameTypeArray)
	local loadedGameDataSet = {}

	for _, gameDataType in pairs(gameTypeArray) do
		local gameDataTypeName = GameDataTypeConverter[gameDataType]
		if not gameDataTypeName then
			Debug.Assert(false, "게임 데이터 타입이름이 없습니다. => " .. tostring(gameDataType))
			return false
		end

		local gameDataName = gameDataTypeName .. "GameData"
		loadedGameDataSet[gameDataType] = require(gameDataOwner:WaitForChild(gameDataName))
		self[gameDataType] = loadedGameDataSet[gameDataType]
	end

	if not self:LoadAdditionalData(loadedGameDataSet) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not self:ValidateData(loadedGameDataSet) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function CommonGameDataManager:LoadAdditionalData(gameDataSet)
	for _, gameData in pairs(gameDataSet) do
		if not gameData:LoadAllAdditionalData(self) then
			Debug.Assert(false, "비정상입니다.")
			return false
		end
	end

	return true
end

function CommonGameDataManager:ValidateData(gameDataSet)
	for _, gameData in pairs(gameDataSet) do
		if not gameData:ValidateAllData(self) then
			Debug.Assert(false, "비정상입니다.")
			return false
		end
	end

	return true
end


if not CommonGameDataManager:LoadGameData(script,
										{GameDataType.Tool,
										--[[GameDataType.XXX--]]}) then
	Debug.Assert(false, "비정상입니다.")
	return nil
end

return CommonGameDataManager
