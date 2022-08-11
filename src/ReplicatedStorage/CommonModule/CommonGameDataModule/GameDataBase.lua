-- 상위 코드에서 같은 리소스에 대해 Wait 하는 경우가 생긴다. 종속성을 없애야 한다.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))
local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType


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

function GameDataBase:LoadAllAdditionalData(gameDataManager)
	for gameDataKey, gameData in pairs(self.Value) do
		if not self:LoadAdditionalData(gameData, gameDataManager) then
			Debug.Assert(false, "LoadAllAdditionalData에 실패했습니다. GameDataType => " .. tostring(self:GetGameDataType()))
			return false
		end
	end
	Debug.Print("!!")
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

-- readonly로 만들어준다.
function GameDataBase:Initialize(gameDataType)
	if not gameDataType then
		Debug.Assert(false, "비정상적인 게임데이터 타입입니다." .. tostring(gameDataType))
		return
	end

	rawset(self, "__index", Utility.Inheritable__index)
	rawset(self, "__newindex", Utility.Immutable__newindex)
	rawset(self, "Value", {})
	rawset(self, "GetGameDataType", function() return gameDataType end)
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
