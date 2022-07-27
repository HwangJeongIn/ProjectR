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
	
	actions = {},
	Root = Utility.EmptyFunction,
	GetGameDataType = Utility.EmptyFunction,
	GetGameDataKey = Utility.EmptyFunction,
	GetGameData = Utility.EmptyFunction,
	
}
ObjectBase.__index = Utility.Inheritable__index
ObjectBase.__newindex = Utility.Inheritable__newindex

--[[
local root = nil
local gameDataType = nil
local gameDataKey = nil
local gameData = nil
--]]

-- local actions = {}


-- 함수 정의 ------------------------------------------------------------------------------------------------------

--[[
function ObjectBase:Initialize(objectGameDataType, objectRoot)

	if not objectRoot then
		Debug.Assert(false, "입력이 비정상입니다. GameDataType => " .. tostring(objectGameDataType))
		return	
	end

	local typSTring  = type(objectGameDataType)
	if not objectGameDataType or type(objectGameDataType) ~= "number" then
		Debug.Assert(false, "입력이 비정상입니다.")
		return	
	end


	local objectGameDataKey = objectRoot:FindFirstChild("Key")
	if not objectGameDataKey then
		Debug.Assert(false, "객체에 키 태그가 존재하지 않습니다.")
		return
	end

	objectGameDataKey = objectGameDataKey.Value

	local objectGameData = GameDataManager[objectGameDataType]:Get(objectGameDataKey)
	if not objectGameData then
		Debug.Assert(false, "데이터가 존재하지 않습니다.")
		return
	end

	self.root = objectRoot
	self.gameDataType = objectGameDataType
	self.gameDataKey = objectGameDataKey
	self.gameData = objectGameData
end
--]]

function ObjectBase:Initialize(objectGameDataType, objectRoot)
	
	if not objectRoot then
		Debug.Assert(false, "입력이 비정상입니다. GameDataType => " .. tostring(objectGameDataType))
		return	
	end

	local typSTring  = type(objectGameDataType)
	if not objectGameDataType or type(objectGameDataType) ~= "number" then
		Debug.Assert(false, "입력이 비정상입니다.")
		return	
	end


	local objectGameDataKey = objectRoot:FindFirstChild("Key")
	if not objectGameDataKey then
		Debug.Assert(false, "객체에 키 태그가 존재하지 않습니다.")
		return
	end

	objectGameDataKey = objectGameDataKey.Value

	local objectGameData = ServerGameDataManager[objectGameDataType]:Get(objectGameDataKey)
	if not objectGameData then
		Debug.Assert(false, "데이터가 존재하지 않습니다.")
		return
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
end

--[[
function ObjectBase:Initialize__(objectGameDataType, objectRoot)
	
	-- Clone하면 두 번 호출될 수 있음
	if root then
		Debug.Log("재초기화 GameDataType => " .. tostring(gameDataType))
		--return	
	end
	
	if not objectRoot then
		Debug.Assert(false, "입력이 비정상입니다. GameDataType => " .. tostring(gameDataType))
		return	
	end
	
	local typSTring  = type(objectGameDataType)
	if not objectGameDataType or type(objectGameDataType) ~= "number" then
		Debug.Assert(false, "입력이 비정상입니다.")
		return	
	end
	
	
	local objectGameDataKey = objectRoot:FindFirstChild("Key")
	if not objectGameDataKey then
		Debug.Assert(false, "객체에 키 태그가 존재하지 않습니다.")
		return
	end
	
	objectGameDataKey = objectGameDataKey.Value
	
	local objectGameData = GameDataManager[objectGameDataType]:Get(objectGameDataKey)
	if not objectGameData then
		Debug.Assert(false, "데이터가 존재하지 않습니다.")
		return
	end
	
	root = objectRoot
	gameDataType = objectGameDataType
	gameDataKey = objectGameDataKey
	gameData = objectGameData
	
	
end

function ObjectBase:Root()
	Debug.Assert(self.root, "ObjectRoot가 존재하지 않습니다. 초기화 해주세요.")
	return self.root
end

function ObjectBase:GetGameDataType()
	Debug.Assert(self.root, "ObjectRoot가 존재하지 않습니다. 초기화 해주세요.")
	Debug.Assert(self.gameDataType, "GameDataType이 존재하지 않습니다. 초기화 해주세요.")
	return self.gameDataType
end

function ObjectBase:GetGameDataKey()

	Debug.Assert(self.root, "ObjectRoot가 존재하지 않습니다. 초기화 해주세요.")
	Debug.Assert(self.gameDataType, "GameDataType이 존재하지 않습니다. 초기화 해주세요.")
	Debug.Assert(self.gameDataKey, "GameDataKey가 존재하지 않습니다. 초기화 해주세요.")
	return self.gameDataKey
end

function ObjectBase:GetGameData()
	Debug.Assert(self.root, "ObjectRoot가 존재하지 않습니다. 초기화 해주세요.")
	Debug.Assert(self.gameDataType, "GameDataType이 존재하지 않습니다. 초기화 해주세요.")
	Debug.Assert(self.gameData, "GameData가 존재하지 않습니다. 초기화 해주세요.")
	return self.gameData
end
--]]
--[[
function ObjectBase.Root()
	Debug.Assert(root, "ObjectRoot가 존재하지 않습니다. 초기화 해주세요.")
	return root
end

function ObjectBase.GetGameDataType()
	Debug.Assert(root, "ObjectRoot가 존재하지 않습니다. 초기화 해주세요.")
	Debug.Assert(gameDataType, "GameDataType이 존재하지 않습니다. 초기화 해주세요.")
	return gameDataType
end

function ObjectBase.GetGameDataKey()

	Debug.Assert(root, "ObjectRoot가 존재하지 않습니다. 초기화 해주세요.")
	Debug.Assert(gameDataType, "GameDataType이 존재하지 않습니다. 초기화 해주세요.")
	Debug.Assert(gameDataKey, "GameDataKey가 존재하지 않습니다. 초기화 해주세요.")
	return gameDataKey
end

function ObjectBase.GetGameData()
	Debug.Assert(root, "ObjectRoot가 존재하지 않습니다. 초기화 해주세요.")
	Debug.Assert(gameDataType, "GameDataType이 존재하지 않습니다. 초기화 해주세요.")
	Debug.Assert(gameData, "GameData가 존재하지 않습니다. 초기화 해주세요.")
	return gameData
end
--]]

function ObjectBase:BindAction(action)
	
	local typeString = type(action)
	
	if typeString ~= "function" then
		Debug.Assert(false, tostring(action) .. " is not function")
		return
	end
	
	local actionName = tostring(action)
	
	self.actions[actionName] = action
end

function ObjectBase:UnbindActions()
	
	self.actions = {}
	
end

function ObjectBase:UnbindAction(action)
	
	local typeString = type(action)

	if typeString ~= "function" then
		Debug.Assert(false, tostring(action) .. " is not function")
		return
	end
	
	local actionName = tostring(action)
	self.actions[actionName] = nil
	
end

function ObjectBase:ExecuteActions(...)
	
	for --[[actionName--]] _, action in pairs(self.actions) do
		action(...)
	end
	
end

--[[
function ObjectBase.ExecuteAction(action, ...)
	
	local actionName = tostring(action)
	
	if actions[actionName]  then
		actions[actionName](...)
	end
	
end
--]]

-- 반환 코드 ------------------------------------------------------------------------------------------------------

return ObjectBase
