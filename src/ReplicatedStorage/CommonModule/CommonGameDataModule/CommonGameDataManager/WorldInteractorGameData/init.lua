local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")
local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType
local WorldInteractorTypeSelector = CommonEnum.WorldInteractorType

local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local GameDataBase = Utility:DeepCopy(require(CommonGameDataModule:WaitForChild("GameDataBase")))



local WorldInteractorGameData = {ModelToKeyMappingTable = require(script:WaitForChild("WorldInteractorModelToKeyMappingTable"))}

-- 내부 함수 먼저 정의
function WorldInteractorGameData:LoadAdditionalData(gameData, gameDataManager)
	return true
end

function WorldInteractorGameData:ValidateData(gameData, gameDataManager)
	if not gameData.MaxHp then
		Debug.Assert(false, "MaxHp가 없습니다. => " .. tostring(gameData:GetKey()))
		return false
	end

	if gameData.WorldInteractorType == WorldInteractorTypeSelector.ItemBox then
		if not gameData.DropGameDataKey then
			Debug.Assert(false, "ItemBox 타입인데 DropToolGameDataKey가 없습니다. => " .. tostring(gameData:GetKey()))
			return false
		end
		
		-- 공용데이터가 아닌 서버의 서버데이터로 검증할 예정이다.
		--[[
		local targetToolKey = gameData.DropToolGameDataKey
		local targetToolData = gameDataManager[GameDataType.Tool]:Get(targetToolKey)
		if not targetToolData then
			Debug.Assert(false, "DropToolGameDataKey가 존재하지 않습니다. => " .. tostring(targetToolKey) ..  " => " .. tostring(gameData:GetKey()))
			return false
		end
		--]]
	end

	return true
end

function WorldInteractorGameData:ValidateDataFinally(gameDataManager)
	return true
end

setmetatable(WorldInteractorGameData, GameDataBase)
WorldInteractorGameData:Initialize(GameDataType.WorldInteractor)

--[[ 검 드롭	--]] WorldInteractorGameData:InsertData(1, {WorldInteractorType = WorldInteractorTypeSelector.ItemBox, MaxHp = 4, DropGameDataKey = 1})
--[[ 도끼 상자  --]] WorldInteractorGameData:InsertData(2, {WorldInteractorType = WorldInteractorTypeSelector.ItemBox, MaxHp = 4, DropGameDataKey = 2})
return setmetatable({}, WorldInteractorGameData)
