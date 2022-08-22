local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType
local WorldInteractorType = CommonEnum.WorldInteractorType

local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local GameDataBase = Utility:DeepCopy(require(CommonGameDataModule:WaitForChild("GameDataBase")))

local DropGameData = {}

-- 내부 함수 먼저 정의
function DropGameData:LoadAdditionalData(gameData, gameDataManager)
	return true
end

function DropGameData:ValidateData(gameData, gameDataManager)
    if not gameData.ToolGameDataKeySet then
        Debug.Assert(false, "DropGameData의 ToolGameDataKeySet이 존재하지 않습니다. => " .. tostring(gameData:GetKey()))
        return false
    end 

    local toolGameDataSet = {}
    for _, toolGameDataKey in pairs(gameData.ToolGameDataKeySet) do
        local toolGameData = gameDataManager[GameDataType.Tool]:Get(toolGameDataKey)

        if not toolGameData then
            Debug.Assert(false, "DropGameData의 ToolGameDataKey가 존재하지 않습니다. => " 
            .. tostring(gameData:GetKey()) .. " : " .. tostring(toolGameDataKey))
            return false
        end

        table.insert(toolGameDataSet, toolGameData)
    end

    rawset(gameData, "ToolGameDataSet", toolGameDataSet)
	return true
end

function DropGameData:ValidateDataFinally(gameDataManager)
    local allWorldInteractorGameData = gameDataManager[GameDataType.WorldInteractor]:GetAllData()

    for worldInteractorGameDataKey, worldInteractorGameData in pairs(allWorldInteractorGameData) do
        if WorldInteractorType.ItemBox == worldInteractorGameData.WorldInteractorType then
            local targetDropGameData = self:Get(worldInteractorGameData.DropGameDataKey)
            if not targetDropGameData then
                Debug.Assert(false, "WorldInteractorGameData의 DropGameDataKey가 존재하지 않습니다. => " 
                .. tostring(worldInteractorGameDataKey) .. " : " .. tostring(worldInteractorGameData.DropGameDataKey))

                return false
            end

            rawset(worldInteractorGameData, "DropGameData", targetDropGameData)
        end
    end
	return true
end

setmetatable(DropGameData, GameDataBase)
DropGameData:Initialize(GameDataType.Drop)


DropGameData:InsertData(1, {ToolGameDataKeySet = {10}})
DropGameData:InsertData(2, {ToolGameDataKeySet = {101, 102, 103, 104}})

return setmetatable({}, DropGameData)
