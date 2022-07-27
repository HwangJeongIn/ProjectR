local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType

local Utility = require(CommonModule:WaitForChild("Utility"))


local CommonGameDataManager = {
	[GameDataType.Tool] = require(script:WaitForChild("ToolGameData"))
}

CommonGameDataManager.__index = Utility.Inheritable__index
CommonGameDataManager.__newindex = Utility.Inheritable__newindex

return CommonGameDataManager
