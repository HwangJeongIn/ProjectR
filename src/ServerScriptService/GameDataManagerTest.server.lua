--[[
local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))
local GameDataManager =  ServerModuleFacade.GameDataManager

local key = 2

local row = GameDataManager.CharacterGameData:Get(key)
if row then
	local temp = row.STR
	local a
end

local testValue = GameDataManager.CharacterGameData[key].STR
--]]
