local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType

local ObjectUtility = {
}

function ObjectUtility:InitializeRaw(gameDataManager, gameDataType)
    if not gameDataManager or not gameDataType then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if not gameDataManager[gameDataType] then
        Debug.Assert(false, "비정상입니다.")
        return false
    end
    
    self.GameDataManager = gameDataManager
    self.GameDataType = gameDataType
    return true
end

function ObjectUtility:GetGameDataKeyByModelName(modelName)
	if not modelName then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local gameDataKey = self.GameDataManager[self.GameDataType]:GetGameDataKeyByModelName(modelName)
    if not gameDataKey then
        Debug.Assert(false, "GameDataKey가 존재하지 않습니다. [ModelName] => " .. modelName .. " | [GameDataType] => " .. tostring(self.GameDataType))
		return nil
    end

    return gameDataKey
end

function ObjectUtility:GetGameDataByModelName(modelName)
	if not modelName then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local gameData = self.GameDataManager[self.GameDataType]:GetGameDataByModelName(modelName)
	if not gameData then
		Debug.Assert(false, "GameData가 존재하지 않습니다. [ModelName] => " .. modelName .. " | [GameDataType] => " .. tostring(self.GameDataType))
		return nil
	end

	return gameData
end

function ObjectUtility:GetGameDataByKey(key)
	local gameData = self.GameDataManager[self.GameDataType]:Get(key)
	if not gameData then
		Debug.Assert(false, "GameData가 존재하지 않습니다. [Key] => " .. tostring(key).. " | [GameDataType] => " .. tostring(self.GameDataType))
		return nil
	end

	return gameData
end

function ObjectUtility:GetGameDataKey(object)
	if not object then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local gameDataKey = self:GetGameDataKeyByModelName(object.Name)
	if not gameDataKey then
		Debug.Assert(false, "모델과 일치하는 데이터가 Mapping Table을 확인해봐야 합니다. => " .. object.Name)
		return nil
	end

	return gameDataKey
end

function ObjectUtility:GetGameData(object)
	if not object then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local gameData = self:GetGameDataByModelName(object.Name)
	if not gameData then
		Debug.Assert(false, "모델과 일치하는 데이터가 Mapping Table을 확인해봐야 합니다. => " .. object.Name)
		return nil
	end

	return gameData
end

return ObjectUtility
