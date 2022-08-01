local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonModuleFacade.Debug
local Utility = CommonModuleFacade.Utility
local ToolUtility = CommonModuleFacade.ToolUtility
local CommonGlobalStorage = CommonModuleFacade.CommonGlobalStorage

local ServerStorage = game:GetService("ServerStorage")
local ServerModule = ServerStorage:WaitForChild("ServerModule")
local ServerEnum = require(ServerModule:WaitForChild("ServerEnum"))

local GameDataType = ServerEnum.GameDataType
local StatusType = ServerEnum.StatusType
local ToolType = ServerEnum.ToolType
local ArmorType = ServerEnum.ArmorType

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- STC
local AddToolSTC = RemoteEvents:WaitForChild("AddToolSTC")
local RemoveToolSTC = RemoteEvents:WaitForChild("RemoveToolSTC")
local EquipToolSTC = RemoteEvents:WaitForChild("EquipToolSTC")
local UnequipToolSTC = RemoteEvents:WaitForChild("UnequipToolSTC")

-- CTS
local SelectToolCTS = RemoteEvents:WaitForChild("SelectToolCTS")

local ServerGlobalStorage = CommonGlobalStorage

SelectToolCTS.OnServerEvent:Connect(function(player, inventorySlotIndex, tool)
	if not inventorySlotIndex or not tool then
		Debug.Assert(false, "비정상입니다.")
		return
	end
	
	if player.Backpack ~= tool.Parent then
		Debug.Assert(false, "플레이어가 소유한 도구가 아닙니다.")
		return
	end

	local character = player.Character
	if not character then
		Debug.Print("플레이어 캐릭터가 존재하지 않습니다. 있을 수 있는 상황입니다.")
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		Debug.Print("캐릭터의 휴머노이드가 존재하지 않습니다. 있을 수 있는 상황입니다.")
		return
	end

	humanoid:EquipTool(tool)
	ServerGlobalStorage:CheckAndEquipIfWeapon(player.UserId, tool)
end)

-- Weapon은 명시적으로 장착하는 것이 없다. 그냥 들고 있으면 알아서 EquipSlot에 집어넣어야한다.
function ServerGlobalStorage:CheckAndEquipIfWeapon(playerId, tool)
	if not ToolUtility:CheckWeaponTool(tool) then
		return false
	end
	
	if not self:EquipTool(playerId, tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local player = game.Players:GetPlayerByUserId(playerId)
	EquipToolSTC:FireClient(player, tool)
	return true
end

function ServerGlobalStorage:CheckAndUnequipIfWeapon(playerId, tool)
	if not ToolUtility:CheckWeaponTool(tool) then
		return false
	end
	
	if not self:UnequipTool(playerId, tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local player = game.Players:GetPlayerByUserId(playerId)
	UnequipToolSTC:FireClient(player, tool)
	return true
end

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
	Debris:AddItem(tool, 0)
	return true
end

function ServerGlobalStorage:UnregisterPlayerEvent(player)
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
