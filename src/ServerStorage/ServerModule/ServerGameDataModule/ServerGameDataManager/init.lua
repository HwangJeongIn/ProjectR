local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))

local Debug = CommonModuleFacade.Debug
local CommonEnum = CommonModuleFacade.CommonEnum
local GameDataType = CommonEnum.GameDataType

local Utility = CommonModuleFacade.Utility
local CommonGameDataManager = CommonModuleFacade.CommonGameDataManager

local ServerGameDataManager = {}

ServerGameDataManager.__index = Utility.Inheritable__index
ServerGameDataManager.__newindex = Utility.Inheritable__newindex
setmetatable(ServerGameDataManager, CommonGameDataManager)

if not ServerGameDataManager:LoadGameData(script,
										{GameDataType.Character,
										}) then
	Debug.Assert(false, "비정상입니다.")
	return nil
end
return ServerGameDataManager
