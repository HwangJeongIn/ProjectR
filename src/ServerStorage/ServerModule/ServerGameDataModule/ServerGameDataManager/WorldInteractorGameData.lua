local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType
local InteractorActionTypeSelector = CommonEnum.InteractorActionType

local Utility = require(CommonModule:WaitForChild("Utility"))
local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local GameDataBase = Utility:DeepCopy(require(CommonGameDataModule:WaitForChild("GameDataBase")))


local WorldInteractorGameData = {}

-- 내부 함수 먼저 정의
function WorldInteractorGameData:LoadAdditionalData(gameData, gameDataManager)
	return true
end

function WorldInteractorGameData:ValidateData(gameData, gameDataManager)
	if gameData.InteractorActionType == InteractorActionTypeSelector.DropItem then
		if not gameData.DropToolGameDataKey then
			Debug.Assert(false, "DropItem 타입인데 DropToolGameDataKey가 없습니다. => " .. tostring(gameData:GetKey()))
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

function WorldInteractorGameData:ValidateAllDataFinally(gameDataManager)
	return true
end

setmetatable(WorldInteractorGameData, GameDataBase)
WorldInteractorGameData:Initialize(GameDataType.WorldInteractor)


--[[ 검 드롭	--]] WorldInteractorGameData:InsertData(1, {InteractorActionType = InteractorActionTypeSelector.DropItem, DropToolGameDataKey = 2})
--[[ 도끼 상자  --]] WorldInteractorGameData:InsertData(2, {InteractorActionType = InteractorActionTypeSelector.DropItem, DropToolGameDataKey = 3})

return setmetatable({}, WorldInteractorGameData)
