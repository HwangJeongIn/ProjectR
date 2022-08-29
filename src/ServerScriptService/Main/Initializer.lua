local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ChangeGameStateSTC = RemoteEvents:WaitForChild("ChangeGameStateSTC")


local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local ObjectCollisionGroupUtility = ServerModuleFacade.ObjectCollisionGroupUtility

local ServerConstant = ServerModuleFacade.ServerConstant
local DefaultCharacterWalkSpeed = ServerConstant.DefaultCharacterWalkSpeed

local CommonEnum = ServerModuleFacade.CommonEnum
local GameStateType = CommonEnum.GameStateType
local ToolType = CommonEnum.ToolType

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage

local Initializer = {}

function Initializer:InitializeGame()

	local ServerModule = ServerModuleFacade.ServerModule
	local WorldSystemModule = ServerModule:WaitForChild("WorldSystemModule")
	local toolSystem = require(WorldSystemModule:WaitForChild("ToolSystem"))
	local worldInteractorSystem = require(WorldSystemModule:WaitForChild("WorldInteractorSystem"))
	local npcSystem = require(WorldSystemModule:WaitForChild("NpcSystem"))

	if not ServerGlobalStorage:Initialize(toolSystem, worldInteractorSystem, npcSystem) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	self:RegisterPlayerEvent()

	return true
end

function ClearPlayer(player)
	if not player then
		return false
	end
	
	-- 캐릭터가 존재하면 존재하는 캐릭터 정리 -- 없는 경우에도 들어올 수 있다.
	local character = player.Character
	if character then
		-- 데이터 기반으로 수정해야 된다.
		if character:FindFirstChild("AliveTag") then
			Debris:AddItem(character.AliveTag,0)
		end
		
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then 
			humanoid:UnequipTools()
		end
	else
		Debug.Assert(false, "왜 발생하는지 파악해야 합니다. => ".. player.Name)
	end
	
	-- 플레이어 가방 정리
	--ServerGlobalStorage:Un
	local allTools = player.Backpack:GetChildren()
	for _, targetTool in pairs(allTools) do
		targetTool.Parent = nil
	end
	--player.Backpack:ClearAllChildren()

	-- 플레이어 데이터 정리
	--[[
	if not ServerGlobalStorage:ClearPlayer(player) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	--]]
	return true
end

function OnCharacterAdded(player, character)
	--[[
	local characterGameData = ServerGameDataManager[GameDataType.Character]:Get(1)
	if not characterGameData then
		Debug.Assert(false, "데이터가 존재하지 않습니다.")
	end
	ServerGlobalStorage:AddGameData(character, characterGameData)
	--]]

	local armorsFolder = Instance.new("Folder")
	armorsFolder.Name = "Armors"
	armorsFolder.Parent = character

	if not ObjectCollisionGroupUtility:SetPlayerCollisionGroup(player) then
		Debug.Assert(false, "비정상입니다.")
	end

	if not ServerGlobalStorage:RegisterPlayerEvent(player) then
		Debug.Assert(false, "비정상입니다.")
	end
	
	character.Humanoid.WalkSpeed = DefaultCharacterWalkSpeed
	character.Humanoid.Died:Connect(function()
		local playerId = player.UserId
		local attacker = ServerGlobalStorage:GetRecentAttacker(playerId)
		if attacker then
			ChangeGameStateSTC:FireClient(player, GameStateType.Dead, attacker.Name)

			local attackerPlayer = game.Players:GetPlayerFromCharacter(attacker)
			if attackerPlayer then
				local attackerPlayerId = attackerPlayer.UserId
				if not ServerGlobalStorage:AddKillCountAndNotify(attackerPlayerId) then
					Debug.Assert(false, "AddKillCountAndNotify에 실패했습니다.")
				end
			end
		else
			ChangeGameStateSTC:FireClient(player, GameStateType.Dead)
		end
		

		-- 죽었을 때
		if character:FindFirstChild("AliveTag")  then
			Debris:AddItem(character.AliveTag, 0)
		end

		wait(3)
		--player:LoadCharacterBlocking()
		ChangeGameStateSTC:FireClient(player, GameStateType.WaitingForFinishing)
	end)
end

function OnCharacterRemoving(player, character)
	ClearPlayer(player)
end

function OnPlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		OnCharacterAdded(player, character)
	end)

	player.CharacterRemoving:Connect(function(character)
		OnCharacterRemoving(player, character)
	end)
	
	ServerGlobalStorage:InitializePlayer(player)

	local leaderstatsFolder = Instance.new("Folder")
	leaderstatsFolder.Name = "leaderstats"
	leaderstatsFolder.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 50
	coins.Parent = leaderstatsFolder
	
	ChangeGameStateSTC:FireClient(player, GameStateType.Waiting)
end

function OnPlayerRemoving(player)
	ServerGlobalStorage:RemovePlayer(player)
end

function Initializer:RegisterPlayerEvent()
	game.Players.PlayerAdded:Connect(OnPlayerAdded)
	game.Players.PlayerRemoving:Connect(OnPlayerRemoving)
end

function Initializer:ClearPlayers(players)
	for i, player in pairs (players) do
		if not ClearPlayer(player) then
			Debug.Assert(false, "플레이어 데이터 정리에 실패했습니다. => " .. player.Name)
			continue
		end
	end
end

function Initializer:PushDefaulArmorTools(player)
	ServerGlobalStorage:CreateToolToPlayer(101, player) -- DefaultHelmet
	ServerGlobalStorage:CreateToolToPlayer(102, player) -- DefaultChestplate
	ServerGlobalStorage:CreateToolToPlayer(103, player) -- DefaultLeggings
	ServerGlobalStorage:CreateToolToPlayer(104, player) -- DefaultBoots
end

function Initializer:PushDefaulWeaponTools(player)
	ServerGlobalStorage:CreateToolToPlayer(2, player) -- DefaultSword
	ServerGlobalStorage:CreateToolToPlayer(3, player) -- DefaultAxe
end

function Initializer:StartGame(playersInGame)
	for i, player in pairs (playersInGame) do

		if not player then
			Debug.Log("이미 나간 플레이어입니다. => " .. player.Name)
			table.remove(playersInGame, i)
			continue
		end

		local character = player.Character
		if not character then
			Debug.Assert(false, "플레이어의 캐릭터가 없습니다. 게임에서 제외됩니다. => " .. player.Name)
			table.remove(playersInGame, i)
			continue
		end
		
		self:PushDefaulWeaponTools(player)
		self:PushDefaulArmorTools(player)

		--[[
		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "BoolValue!!"
		boolValue.Parent = sword

		local temp = require(ServerModuleFacade.ToolModule.ToolBase)
		temp.Name = "temp"
		temp.Parent = sword
		
		local temp2 = temp:Clone()
		temp2.Parent = sword
		--]]
		-- 플레이어 생존 여부 확인을 위한 태그
		if not character:FindFirstChild("AliveTag") then
			local aliveTag = Instance.new("BoolValue")
			aliveTag.Name = "AliveTag"
			aliveTag.Parent = character
		end
	end
end

return Initializer


