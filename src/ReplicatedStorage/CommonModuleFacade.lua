local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")
local CommonConstant = require(CommonModule:WaitForChild("CommonConstant"))
local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))

local ContainerModule = CommonModule:WaitForChild("ContainerModule")
local TArray = require(ContainerModule:WaitForChild("TArray"))
local TList = require(ContainerModule:WaitForChild("TList"))

local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local CommonGameDataManager = require(CommonGameDataModule:WaitForChild("CommonGameDataManager"))
--local GameDataBase = require(CommonGameDataModule:WaitForChild("GameDataBase"))

local CommonGlobalStorage = CommonModule:WaitForChild("CommonGlobalStorage")
local ToolUtility = require(CommonGlobalStorage:WaitForChild("ToolUtility"))
CommonGlobalStorage = require(CommonGlobalStorage)

local CommonModuleFacade = {
	CommonModule = CommonModule,
	CommonConstant = CommonConstant,
	CommonEnum = CommonEnum,
	CommonGameDataModule = CommonGameDataModule,
	CommonGameDataManager = CommonGameDataManager,
	--GameDataBase = GameDataBase,
	CommonGlobalStorage = CommonGlobalStorage,
	ToolUtility = ToolUtility,
	TArray = TArray,
	TList = TList,
	Utility = Utility,
	Debug = Debug
}

CommonModuleFacade.__index = CommonModuleFacade.Utility.Inheritable__index
CommonModuleFacade.__newindex = CommonModuleFacade.Utility.Inheritable__newindex

return CommonModuleFacade
