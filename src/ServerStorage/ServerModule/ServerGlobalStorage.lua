local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonModuleFacade.Debug
local Utility = CommonModuleFacade.Utility
local CommonGlobalStorage = CommonModuleFacade.CommonGlobalStorage

local ServerStorage = game:GetService("ServerStorage")
local ServerModule = ServerStorage:WaitForChild("ServerModule")
local ServerEnum = require(ServerModule:WaitForChild("ServerEnum"))

local GameDataType = ServerEnum.GameDataType
local StatusType = ServerEnum.StatusType
local ToolType = ServerEnum.ToolType
local ArmorType = ServerEnum.ArmorType

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local AddToolSTC = RemoteEvents:WaitForChild("AddToolSTC")
local RemoveToolSTC = RemoteEvents:WaitForChild("RemoveToolSTC")


local ServerGlobalStorage = CommonGlobalStorage

function ServerGlobalStorage:AddTool(playerId, tool)
	local player = game.Players:GetPlayerByUserId(playerId)
	if not player then
		Debug.Assert(false, "플레이어가 존재하지 않습니다.")
		return false
	end

	if not self:CheckPlayer(playerId) then
		Debug.Assert(false, "플레이어 데이터가 존재하지 않습니다.")
		return false
	end
	
	local inventory = self.PlayerTable[playerId][StatusType.Inventory]
	if not inventory:AddTool(tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local slotIndex = inventory:GetSlotIndexRaw(tool)
	Debug.Assert(slotIndex, "코드 버그")

	AddToolSTC:FireClient(player, slotIndex, tool)
	return true
end

function ServerGlobalStorage:RemoveTool(playerId, tool)
	local player = game.Players:GetPlayerByUserId(playerId)
	if not player then
		Debug.Assert(false, "플레이어가 존재하지 않습니다.")
		return false
	end

	if not self:CheckPlayer(playerId) then
		Debug.Assert(false, "플레이어 데이터가 존재하지 않습니다.")
		return false
	end
	
	local inventory = self.PlayerTable[playerId][StatusType.Inventory]
	local slotIndex = inventory:GetSlotIndexRaw(tool)
	Debug.Assert(slotIndex, "코드 버그")

	if not inventory:RemoveTool(tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	RemoveToolSTC:FireClient(player, slotIndex, tool)
	tool:Destroy()
	return true
end

function ServerGlobalStorage:RegisterPlayerEvent(player)

	if not player then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local playerId = player.UserId
	player.Backpack.ChildAdded:Connect(function(tool)
		self:AddTool(playerId, tool)
	end)

	player.Backpack.ChildRemoved:Connect(function(tool)
		self:RemoveTool(playerId, tool)
	end)
	
	return true
end

function ServerGlobalStorage:InitializePlayer(player)
	
	if not self:AddPlayer(player) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end





ServerGlobalStorage.__index = Utility.Inheritable__index
ServerGlobalStorage.__newindex = Utility.Inheritable__newindex

--setmetatable(ServerGlobalStorage, CommonGlobalStorage)


return ServerGlobalStorage
