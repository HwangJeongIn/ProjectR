local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType

local Utility = require(CommonModule:WaitForChild("Utility"))
local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local GameDataBase = Utility:DeepCopy(require(CommonGameDataModule:WaitForChild("GameDataBase")))


local WorldInteractorGameData = setmetatable({Name = "WorldInteractorGameData"}, GameDataBase)
WorldInteractorGameData:Initialize(GameDataType.WorldInteractor)


--[[ 검 드롭		--]] WorldInteractorGameData:InsertData(1, {DropToolGameDataKey = 2})
--[[ 도끼 상자   --]] WorldInteractorGameData:InsertData(2, {DropToolGameDataKey = 3})

return setmetatable({}, WorldInteractorGameData)
