
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InstanceTestSTC = ReplicatedStorage:WaitForChild("InstanceTestSTC")
local InstanceTestModule = require(ReplicatedStorage:WaitForChild("InstanceTestModule"))

local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local ServerEnum = ServerModuleFacade.ServerEnum
local GameDataType = ServerEnum.GameDataType
local ServerGameDataManager = ServerModuleFacade.ServerGameDataManager

local toolGameData = ServerGameDataManager[GameDataType.Tool]:Get(1)
local toolGameDataRaw = getmetatable(toolGameData)


while true do

	wait(5)
	InstanceTestModule["Server"] = 1
	
	local players = game.Players:GetPlayers()
	for _, player in ipairs(players) do
		
		local backpack = player.Backpack
		
		local tools = backpack:GetChildren()
		
		local finalString = ""
		for i, tool in ipairs(tools) do
			InstanceTestSTC:FireClient(player, toolGameData)
			
			
			--print(tool)
			--finalString = finalString .. " / Tool" .. tostring(i) .. " => " .. tostring(tool)
		end
		
		--print(finalString)
		
	end

end