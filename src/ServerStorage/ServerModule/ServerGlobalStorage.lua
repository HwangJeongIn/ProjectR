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
local EquipType = ServerEnum.EquipType

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- STC
local AddToolSTC = RemoteEvents:WaitForChild("AddToolSTC")
local RemoveToolSTC = RemoteEvents:WaitForChild("RemoveToolSTC")
local EquipToolSTC = RemoteEvents:WaitForChild("EquipToolSTC")
local UnequipToolSTC = RemoteEvents:WaitForChild("UnequipToolSTC")

-- CTS
local SelectToolCTS = RemoteEvents:WaitForChild("SelectToolCTS")
local EquipToolCTS = RemoteEvents:WaitForChild("EquipToolCTS")
local UnequipToolCTS = RemoteEvents:WaitForChild("UnequipToolCTS")

local ServerGlobalStorage = CommonGlobalStorage


UnequipToolCTS.OnServerEvent:Connect(function(player, equipType)
	if not equipType then
		Debug.Assert(false, "비정상입니다.")
		return
	end

	local character = player.Character
	if not character then
		Debug.Print("플레이어 캐릭터가 존재하지 않습니다. 장착할 수 없습니다.")
		return
	end
	
	local playerId = player.UserId
	local prevTool = nil
	if equipType == EquipType.Weapon then
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid then
			Debug.Print("캐릭터의 휴머노이드가 존재하지 않습니다. 있을 수 있는 상황입니다.")
			return
		end

		prevTool = ServerGlobalStorage:UnequipTool(playerId, equipType)
		if not prevTool then
			Debug.Assert(false, "비정상입니다.")
			return
		end

		humanoid:UnequipTool(prevTool)
	else
		prevTool = ServerGlobalStorage:UnequipTool(playerId, equipType)
		if not prevTool then
			Debug.Assert(false, "비정상입니다.")
			return
		end

		prevTool.Parent = player.Backpack
	end

	UnequipToolSTC:FireClient(player, equipType)
end)

EquipToolCTS.OnServerEvent:Connect(function(player, equipType, tool)
	if not equipType or not tool then
		Debug.Assert(false, "비정상입니다.")
		return
	end

	local finalEquipType = ToolUtility:GetEquipType(tool)
	if finalEquipType ~= equipType then
		Debug.Assert(false, "클라이언트에서 보낸 정보와 실제 정보가 다릅니다.")
		return
	end

	if player.Backpack ~= tool.Parent then
		Debug.Assert(false, "해당 플레이어가 소유한 도구가 아닙니다.")
		return
	end

	local character = player.Character
	if not character then
		Debug.Print("플레이어 캐릭터가 존재하지 않습니다. 장착할 수 없습니다.")
		return
	end

	local playerId = player.UserId
	local prevTool = nil
	local currentTool = nil

	--[[
		* 무기의 경우
			Roblox의 EquipTool 호출 시 알아서 Character 하위로 옮겨진다.
			Roblox의 EquipTool 호출 시 이전에 장착중인 Tool은 Player.Backpack으로 옮겨진다.

		* 방어구의 경우(자체 구현)
			무기에서 하는 것들을 행동을 수동으로 해줘야 한다.
	--]]
	if equipType == EquipType.Weapon then
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid then
			Debug.Print("캐릭터의 휴머노이드가 존재하지 않습니다. 있을 수 있는 상황입니다.")
			return
		end

		humanoid:EquipTool(tool)
		prevTool, currentTool = ServerGlobalStorage:EquipTool(playerId, equipType, tool)
		if not currentTool then
			Debug.Assert(false, "비정상입니다.")
			return
		end
	else
		tool.Parent = character
		prevTool, currentTool = ServerGlobalStorage:EquipTool(playerId, equipType, tool)
		if not currentTool then
			Debug.Assert(false, "비정상입니다.")
			return
		end

		if prevTool then
			prevTool.Parent = player.Backpack
		end
	end
	
	EquipToolSTC:FireClient(player, equipType, tool)
end)

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
	local equipType = ToolUtility:GetEquipType(tool)
	if not equipType or equipType ~= EquipType.Weapon then
		return false
	end
	
	local prevTool, currentTool = self:EquipTool(playerId, equipType, tool)
	if not currentTool then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local player = game.Players:GetPlayerByUserId(playerId)
	EquipToolSTC:FireClient(player, equipType, tool)
	return true
end

function ServerGlobalStorage:CheckAndUnequipIfWeapon(playerId, tool)
	local equipType = ToolUtility:GetEquipType(tool)
	if not equipType or equipType ~= EquipType.Weapon then
		return false
	end
	
	local prevTool = self:UnequipTool(playerId, equipType) 
	if not prevTool then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local player = game.Players:GetPlayerByUserId(playerId)
	UnequipToolSTC:FireClient(player, equipType)
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

	-- 삭제하려면 Parent가 nil이다.
	if not tool.Parent then
		Debris:AddItem(tool, 0)
	end
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
