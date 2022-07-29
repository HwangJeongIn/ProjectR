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

-- readonly로 만들어준다.
function GameDataBase:Initialize(gameDataType)
	rawset(self, "__index", Utility.Inheritable__index)
	rawset(self, "__newindex", Utility.Immutable__newindex)
	
	if not gameDataType then
		Debug.Assert(false, "비정상적인 Enum 값입니다." .. tostring(gameDataType))
		return
	end
	GameDataBase.GetGameDataType = function() return gameDataType end
end

function GameDataBase:Get(key)
	
	local keyTypeString = type(key)
	
	if keyTypeString ~= "number" then
		Debug.Assert(false, "잘못된 키값입니다.")
		return nil
	end
	
	local value = self[key]
	
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
	
	if self[key] ~= nil then
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
	
	rawset(self, key, setmetatable({}, value))
	
end


return GameDataBase
