-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Utility = CommonModuleFacade.Utility

local ServerStorage = game:GetService("ServerStorage")
local ServerModule = ServerStorage:WaitForChild("ServerModule")
local ServerGameDataModule = ServerModule:WaitForChild("ServerGameDataModule")
local ServerGameDataManager = require(ServerGameDataModule:WaitForChild("ServerGameDataManager"))
--[[
local ServerEnum = require(ServerModule:WaitForChild("ServerEnum"))
local GameDataType = ServerEnum.GameDataType
--]]

local Debug = CommonModuleFacade.Debug

local ObjectBase = {
	
	Actions = {},
	Root = Utility.EmptyFunction,
	GetGameDataType = Utility.EmptyFunction,
	GetGameDataKey = Utility.EmptyFunction,
	GetGameData = Utility.EmptyFunction,
	
}
ObjectBase.__index = Utility.Inheritable__index
ObjectBase.__newindex = Utility.Inheritable__newindex


function ObjectBase:InitializeObject(objectGameDataType, objectRoot)
	if not objectRoot then
		Debug.Assert(false, "입력이 비정상입니다. GameDataType => " .. tostring(objectGameDataType))
		return false
	end

	local typSTring  = type(objectGameDataType)
	if not objectGameDataType or type(objectGameDataType) ~= "number" then
		Debug.Assert(false, "입력이 비정상입니다.")
		return false
	end


	local objectGameDataKey = objectRoot:FindFirstChild("Key")
	if not objectGameDataKey then
		Debug.Assert(false, "객체에 키 태그가 존재하지 않습니다.")
		return false
	end

	objectGameDataKey = objectGameDataKey.Value

	local objectGameData = ServerGameDataManager[objectGameDataType]:Get(objectGameDataKey)
	if not objectGameData then
		Debug.Assert(false, "데이터가 존재하지 않습니다.")
		return false
	end
	
	local interalData = {
		root = objectRoot,
		gameDataType = objectGameDataType,
		gameDataKey = objectGameDataKey,
		gameData = objectGameData,
	}
	
	self.Root = function()
		Debug.Assert(interalData.root, "ObjectRoot가 존재하지 않습니다. 초기화 해주세요.")
		return interalData.root
	end

	self.GetGameDataType = function()
		Debug.Assert(interalData.root, "ObjectRoot가 존재하지 않습니다. 초기화 해주세요.")
		Debug.Assert(interalData.gameDataType, "GameDataType이 존재하지 않습니다. 초기화 해주세요.")
		return interalData.gameDataType
	end

	self.GetGameDataKey = function()
		Debug.Assert(interalData.root, "ObjectRoot가 존재하지 않습니다. 초기화 해주세요.")
		Debug.Assert(interalData.gameDataType, "GameDataType이 존재하지 않습니다. 초기화 해주세요.")
		Debug.Assert(interalData.gameDataKey, "GameDataKey가 존재하지 않습니다. 초기화 해주세요.")
		return interalData.gameDataKey
	end

	self.GetGameData = function()
		Debug.Assert(interalData.root, "ObjectRoot가 존재하지 않습니다. 초기화 해주세요.")
		Debug.Assert(interalData.gameDataType, "GameDataType이 존재하지 않습니다. 초기화 해주세요.")
		Debug.Assert(interalData.gameData, "GameData가 존재하지 않습니다. 초기화 해주세요.")
		return interalData.gameData
	end

	return true
end

function ObjectBase:BindAction(action)
	
	local typeString = type(action)
	
	if typeString ~= "function" then
		Debug.Assert(false, tostring(action) .. " is not function")
		return
	end
	
	local actionName = tostring(action)
	
	self.Actions[actionName] = action
end

function ObjectBase:UnbindActions()
	
	self.Actions = {}
	
end

function ObjectBase:UnbindAction(action)
	
	local typeString = type(action)

	if typeString ~= "function" then
		Debug.Assert(false, tostring(action) .. " is not function")
		return
	end
	
	local actionName = tostring(action)
	self.Actions[actionName] = nil
	
end

function ObjectBase:ExecuteActions(...)
	
	for --[[actionName--]] _, action in pairs(self.Actions) do
		action(...)
	end
	
end

return ObjectBase
