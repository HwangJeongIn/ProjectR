-- 상위 코드에서 같은 리소스에 대해 Wait 하는 경우가 생긴다. 종속성을 없애야 한다.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))
local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType
local GameDataTypeConverter = GameDataType.Converter

local CommonConstant = require(CommonModule:WaitForChild("CommonConstant"))
local ObjectGameDataTypeTable = CommonConstant.ObjectGameDataTypeTable


local GameDataBase = {}
GameDataBase.__index = Utility.Inheritable__index
GameDataBase.__newindex = Utility.Immutable__newindex

function GameDataBase:LoadAdditionalData(gameData, gameDataManager)
	Debug.Assert(false, "재정의해야합니다. GameDataType => " .. tostring(self:GetGameDataType()))
	return false
end

function GameDataBase:ValidateData(gameData, gameDataManager)
	Debug.Assert(false, "재정의해야합니다. GameDataType => " .. tostring(self:GetGameDataType()))
	return false
end

function GameDataBase:ValidateDataFinally(gameDataManager)
	Debug.Assert(false, "재정의해야합니다. GameDataType => " .. tostring(self:GetGameDataType()))
	return false
end

function GameDataBase:LoadAllAdditionalData(gameDataManager)
	for gameDataKey, gameData in pairs(self.Value) do
		if not self:LoadAdditionalData(gameData, gameDataManager) then
			Debug.Assert(false, "LoadAllAdditionalData에 실패했습니다. GameDataType => " .. tostring(self:GetGameDataType()))
			return false
		end
	end
	return true
end

function GameDataBase:ValidateAllData(gameDataManager)
	for gameDataKey, gameData in pairs(self.Value) do
		if not self:ValidateData(gameData, gameDataManager) then
			Debug.Assert(false, "ValidateAllData에 실패했습니다. GameDataType => " .. tostring(self:GetGameDataType()))
			return false
		end
	end
	return true
end

function GameDataBase:IsObjectGameData()
	return (nil ~= ObjectGameDataTypeTable[self:GetGameDataType()])
end

function GameDataBase:ValidateAllDataFinally(gameDataManager)
	if self:IsObjectGameData() then
		if not self:ValidateObjectGameData() then
			Debug.Assert(false, "ValidateObjectGameData에 실패했습니다." .. tostring(self:GetGameDataType()))
			return false
		end
	end

	if not self:ValidateDataFinally(gameDataManager) then
		Debug.Assert(false, "ValidateDataFinally에 실패했습니다. GameDataType => " .. tostring(self:GetGameDataType()))
		return false
	end
	return true
end

function GameDataBase:InitializeObjectGameData()
	if not self.ModelToKeyMappingTable then
		Debug.Assert(false, "ModelToKeyMappingTable가 없습니다. Object기반 데이터는 꼭 필요합니다. => [GameDataType]" .. tostring(self:GetGameDataType()))
		return false
	end
	
	rawset(self, "GetGameDataByModelName", function(gameData, targetModelName)
		local targetKey = self.ModelToKeyMappingTable[targetModelName]
		if not targetKey then
			Debug.Assert(false, "모델이 등록된 키가 없습니다. => " .. targetModelName)
			return nil
		end

		-- 검증하기 때문에 무조건 존재한다.
		return self:Get(targetKey)
	end)

	rawset(self, "GetGameDataKeyByModelName", function(gameData, targetModelName)
		local targetKey = self.ModelToKeyMappingTable[targetModelName]
		if not targetKey then
			Debug.Assert(false, "모델이 등록된 키가 없습니다. => " .. targetModelName)
			return nil
		end

		return targetKey
	end)

	return true
end

function GameDataBase:ValidateObjectGameData()
	for modelName, gameDataKey in pairs(self.ModelToKeyMappingTable) do
		if not self:Get(gameDataKey) then
			Debug.Assert(false, "해당 키가 존재하지 않습니다.=> [GameDataType]" .. tostring(self:GetGameDataType()) .. " => " .. modelName .. " : " .. tostring(gameDataKey))
			return false
		end
	end

	return true
end

-- readonly로 만들어준다.
function GameDataBase:Initialize(gameDataType)
	if not gameDataType then
		Debug.Assert(false, "비정상적인 게임데이터 타입입니다." .. tostring(gameDataType))
		return false
	end

	local gameDataTypeString = GameDataTypeConverter[gameDataType]
	local gameDataString = gameDataTypeString .. "GameData"

	rawset(self, "__index", Utility.Inheritable__index)
	rawset(self, "__newindex", Utility.Immutable__newindex)
	
	rawset(self, "Name", gameDataString)
	rawset(self, "Value", {})
	rawset(self, "GetAllData", function() return self.Value end)
	rawset(self, "GetGameDataType", function() return gameDataType end)

	if self:IsObjectGameData() then
		if not self:InitializeObjectGameData() then
			Debug.Assert(false, "InitializeObjectGameData에 실패했습니다." .. tostring(gameDataType))
			return false
		end
	end

	return true
end

function GameDataBase:Get(key)
	local keyTypeString = type(key)
	
	if keyTypeString ~= "number" then
		Debug.Assert(false, "잘못된 키값입니다.")
		return nil
	end
	
	local value = self.Value[key]
	
	if not value then
		Debug.Assert(false, "존재하지 않는 키값입니다. => ".. tostring(key))
		return nil
	end
	
	return value
end

function GameDataBase:InsertData(key, value)
	local keyTypeString = type(key)
	
	if keyTypeString ~= "number" then
		Debug.Assert(false, "정수형 키만 가질 수 있습니다.")
		return
	end
	
	if self.Value[key] ~= nil then
		Debug.Assert(false, "중복 삽입하려고 합니다.")
		return
	end
	
	local valueTypeString = type(value)
	
	if valueTypeString ~= "table" then
		Debug.Assert(false, "잘못된 값을 삽입하려고 합니다.")
		return
	end
	
	value.GetGameDataType = GameDataBase.GetGameDataType
	value.GetKey = function() return key end
	
	setmetatable(value, {__index = function(_, prop)
		--Debug.Print("해당 속성이 존재하지 않습니다.".. self.Name .. "[" ..tostring(key).. "] => " .. tostring(prop)) 
	end} )
	
	value.__index = Utility.Inheritable__index
	value.__newindex = Utility.Immutable__newindex
	
	rawset(self.Value, key, setmetatable({}, value))
	
end


return GameDataBase
