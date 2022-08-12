local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))

local Debug = CommonModuleFacade.Debug
local Utility = CommonModuleFacade.Utility

local CommonObjectUtilityModule = CommonModuleFacade.CommonObjectUtilityModule
local ObjectUtilityBase = require(CommonObjectUtilityModule:WaitForChild("ObjectUtilityBase"))

local ServerStorage = game:GetService("ServerStorage")
local ServerModule = ServerStorage:WaitForChild("ServerModule")
local ServerEnum = require(ServerModule:WaitForChild("SErverEnum"))

local GameDataType = ServerEnum.GameDataType
local ToolType = ServerEnum.ToolType


local WorldInteractorUtility = ObjectUtilityBase

function WorldInteractorUtility:Initialize()
	local ServerStorage = game:GetService("ServerStorage")
	local ServerModule = ServerStorage:WaitForChild("ServerModule")
	local ServerGameDataModule = ServerModule:WaitForChild("ServerGameDataModule")
	local ServerGameDataManager = require(ServerGameDataModule:WaitForChild("ServerGameDataManager"))

	if not self:InitializeRaw(ServerGameDataManager, GameDataType.WorldInteractor) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

WorldInteractorUtility:Initialize()
return WorldInteractorUtility
