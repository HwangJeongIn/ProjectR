local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Utility = CommonModuleFacade.Utility
local CommonEnum = CommonModuleFacade.CommonEnum


local ServerEnum = {


}

ServerEnum.__index = Utility.Inheritable__index
ServerEnum.__newindex = Utility.Inheritable__newindex

setmetatable(ServerEnum, CommonEnum)

return ServerEnum
