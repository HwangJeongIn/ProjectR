local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))

local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ClientModule = StarterPlayerScripts:WaitForChild("ClientModule")

local ClientGlobalStorage = require(ClientModule:WaitForChild("ClientGlobalStorage"))
local KeyBinder = require(ClientModule:WaitForChild("KeyBinder"))


local ClientModuleFacade = {
	KeyBinder = KeyBinder,
	ClientGlobalStorage = ClientGlobalStorage
}

setmetatable(ClientModuleFacade, CommonModuleFacade)
ClientModuleFacade.__index = ClientModuleFacade.Utility.Inheritable__index

return ClientModuleFacade
