local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Utility = CommonModuleFacade.Utility
local CommonConstant = CommonModuleFacade.CommonConstant


local ServerConstant = {
	DefaultAttackPoint = 10,
	DefaultSTRFactor = 1.2,
	IsTestMode = true
}

ServerConstant.__index = Utility.Inheritable__index
ServerConstant.__newindex = Utility.Inheritable__newindex

setmetatable(ServerConstant, CommonConstant)

return ServerConstant
