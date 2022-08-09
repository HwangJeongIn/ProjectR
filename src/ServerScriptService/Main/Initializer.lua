local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ChangeGameStateSTC = RemoteEvents:WaitForChild("ChangeGameStateSTC")


local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage
local ServerGameDataManager = ServerModuleFacade.ServerGameDataManager

local GameStateType = ServerModuleFacade.CommonEnum.GameStateType
local GameDataType = ServerModuleFacade.ServerEnum.GameDataType

local ToolModule = ServerModuleFacade.ToolModule
local DamagerControllerScript = ToolModule:WaitForChild("DamagerController")
local InteractorControllerScript = ToolModule:WaitForChild("InteractorController")

local Tools = ServerStorage:WaitForChild("Tools")
local ArmorTools = Tools:WaitForChild("Armors")
local WeaponTools = Tools:WaitForChild("Weapons")
local MapController = require(script.Parent:WaitForChild("MapController"))

local Initializer = {}


function InitializeTools()
	local toolFolders = Tools:GetChildren()

	for _, toolFolder in pairs(toolFolders) do
		local tools = toolFolder:GetChildren()
		for _, tool in pairs(tools) do

			tool.CanBeDropped = false
			local handle = tool:FindFirstChild("Handle")
			if not handle then
				Debug.Assert(false, "도구에 핸들이 없습니다. => " .. tool.Name)
				return false
			end

			local trigger = handle:FindFirstChild("Trigger")
			if not trigger then
				Debug.Assert(false, "도구에 트리거가 없습니다. => " .. tool.Name)
				return false
			end

			if handle.CanTouch then
				Debug.Print("CanTouch가 켜져있습니다. 자동으로 꺼집니다." .. tool.Name)
				handle.CanTouch = false
			end

			if trigger.CanCollide then
				Debug.Print("CanCollide가 켜져있습니다. 자동으로 꺼집니다." .. tool.Name)
				trigger.CanCollide = false
				trigger.CanQuery = true
			end

			if tool:FindFirstChild("Damager") then
				local clonedDamagerControllerScript = DamagerControllerScript:Clone()
				clonedDamagerControllerScript.Parent = tool

			elseif tool:FindFirstChild("Interactor") then
				local clonedInteractorControllerScript = InteractorControllerScript:Clone()
				clonedInteractorControllerScript.Parent = tool

			else
				Debug.Print("도구 용도 없음")
				--return false
			end
		end
	end
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

	if not ServerGlobalStorage:RegisterPlayerEvent(player) then
		Debug.Assert(false, "비정상입니다.")
	end
	
	character.Humanoid.Died:Connect(function()
		-- 죽었을 때
		if character:FindFirstChild("AliveTag")  then
			Debris:AddItem(character.AliveTag, 0)
		end
		ChangeGameStateSTC:FireClient(player, GameStateType.Dead)
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

function RegisterPlayerEvent()
	game.Players.PlayerAdded:Connect(OnPlayerAdded)
	game.Players.PlayerRemoving:Connect(OnPlayerRemoving)
end

function Initializer:InitializeGame()
	InitializeTools()
	RegisterPlayerEvent()
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
	local Boots = ArmorTools.Boots:Clone()
	Boots.Parent = player.Backpack

	local Chestplate = ArmorTools.Chestplate:Clone()
	Chestplate.Parent = player.Backpack

	local Helmet = ArmorTools.Helmet:Clone()
	Helmet.Parent = player.Backpack

	local Leggings = ArmorTools.Leggings:Clone()
	Leggings.Parent = player.Backpack
end

function Initializer:PushDefaulWeaponTools(player)
	local Sword = WeaponTools.Sword:Clone()
	Sword.Parent = player.Backpack

	local Axe = WeaponTools.Axe:Clone()
	Axe.Parent = player.Backpack
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

function Initializer:EnterGame(map, playersInGame)
	MapController:EnterMap(map, playersInGame)
	self:StartGame(playersInGame)
end


return Initializer


