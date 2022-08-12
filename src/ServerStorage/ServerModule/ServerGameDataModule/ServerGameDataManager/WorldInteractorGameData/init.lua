local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))

local Debug = CommonModuleFacade.Debug
local Utility = CommonModuleFacade.Utility

local CommonGameDataModule = CommonModuleFacade.CommonGameDataModule
local GameDataBase = Utility:DeepCopy(require(CommonGameDataModule:WaitForChild("GameDataBase")))

local ServerStorage = game:GetService("ServerStorage")
local ServerModule = ServerStorage:WaitForChild("ServerModule")
local ServerEnum = require(ServerModule:WaitForChild("ServerEnum"))

local GameDataType = ServerEnum.GameDataType
local WorldInteractorTypeSelector = ServerEnum.WorldInteractorType

local WorldInteractorGameData = {ModelToKeyMappingTable = require(script:WaitForChild("WorldInteractorModelToKeyMappingTable"))}

-- 내부 함수 먼저 정의
function WorldInteractorGameData:LoadAdditionalData(gameData, gameDataManager)
	return true
end

function WorldInteractorGameData:ValidateData(gameData, gameDataManager)
	if gameData.WorldInteractorType == WorldInteractorTypeSelector.ItemBox then
		if not gameData.DropToolGameDataKey then
			Debug.Assert(false, "ItemBox 타입인데 DropToolGameDataKey가 없습니다. => " .. tostring(gameData:GetKey()))
			return false
		end
		
		local targetToolKey = gameData.DropToolGameDataKey
		local targetToolData = gameDataManager[GameDataType.Tool]:Get(targetToolKey)
		if not targetToolData then
			Debug.Assert(false, "DropToolGameDataKey가 존재하지 않습니다. => " .. tostring(targetToolKey) ..  " => " .. tostring(gameData:GetKey()))
			return false
		end
	end

	return true
end

function WorldInteractorGameData:ValidateDataFinally(gameDataManager)
	return true
end

setmetatable(WorldInteractorGameData, GameDataBase)
WorldInteractorGameData:Initialize(GameDataType.WorldInteractor)


--[[ 검 드롭	--]] WorldInteractorGameData:InsertData(1, {WorldInteractorType = WorldInteractorTypeSelector.ItemBox, DropToolGameDataKey = 2})
--[[ 도끼 상자  --]] WorldInteractorGameData:InsertData(2, {WorldInteractorType = WorldInteractorTypeSelector.ItemBox, DropToolGameDataKey = 3})

return setmetatable({}, WorldInteractorGameData)
