local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))

local CommonEnum = CommonModuleFacade.CommonEnum
local GameDataType = CommonEnum.GameDataType

local Utility = CommonModuleFacade.Utility
local CommonGameDataManager = CommonModuleFacade.CommonGameDataManager


local ServerGameDataManager = {
	[GameDataType.Character] = require(script:WaitForChild("CharacterGameData")),
	[GameDataType.WorldInteractor] = require(script:WaitForChild("WorldInteractorGameData"))
}

ServerGameDataManager.__index = Utility.Inheritable__index
ServerGameDataManager.__newindex = Utility.Inheritable__newindex
setmetatable(ServerGameDataManager, CommonGameDataManager)

return ServerGameDataManager
