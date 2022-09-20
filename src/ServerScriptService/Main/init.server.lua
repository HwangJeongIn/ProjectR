local Initializer = require(script:WaitForChild("Initializer"))
Initializer:InitializeGame()


local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local ServerStorage = game:GetService("ServerStorage")

local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))
local ObjectCollisionGroupUtility = ServerModuleFacade.ObjectCollisionGroupUtility
local ServerConstant = ServerModuleFacade.ServerConstant
local IsTestMode = ServerConstant.IsTestMode

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage

local RemoteValues = ReplicatedStorage:WaitForChild("RemoteValues")

local MainMessage = RemoteValues:WaitForChild("MainMessage")
local CurrentGameLength = RemoteValues:WaitForChild("CurrentGameLength")
local PlayerCount = RemoteValues:WaitForChild("PlayerCount")
local PlayersLeftCount = RemoteValues:WaitForChild("PlayersLeftCount")

local ServerConstant = ServerModuleFacade.ServerConstant
local DefaultReward = ServerConstant.DefaultReward
local DefaultGameLength = ServerConstant.DefaultGameLength
local MinPlayerCount = 1
local MaxPlayerCount = 16


-- 공통 저장소관련
local GameStateType = ServerModuleFacade.CommonEnum.GameStateType
local WinnerType = ServerModuleFacade.CommonEnum.WinnerType


-- RemoteEvent
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local ChangeGameStateSTC = RemoteEvents:WaitForChild("ChangeGameStateSTC")
local NotifyWinnerSTC = RemoteEvents:WaitForChild("NotifyWinnerSTC")
local ChangeGameDataCTS = RemoteEvents:WaitForChild("ChangeGameDataCTS")

ChangeGameDataCTS.OnServerEvent:Connect(function(player, arg1)
	print(arg1 .. " is client message")
	print(MainMessage.Value)
end)





function ClearGui()
	CurrentGameLength.Value = 0
	PlayersLeftCount.Value = 0
	MainMessage.Value = ""
end


function Temp()
    wait(3)
    while #game.Players:GetPlayers() < 1 do
        wait(1)
    end
    
    local testPlayer = game.Players:GetPlayers()[1]
    while not testPlayer.Character do
        wait(1)
    end

	local players = game.Players:GetPlayers()
	for i, player in pairs(players) do
		--Initializer:PushDefaulToolsTemp(player)
	end
    
    ServerGlobalStorage:SelectDesertMapAndEnterMapTemp(game.Players:GetPlayers())

	wait(30)
	ServerGlobalStorage:ClearCurrentMap()
end


Temp()


while false  do
	-- 다른 플레이어를 기다리는 중
	while #game.Players:GetPlayers() < 3 do
		wait(1)
	end
	wait(3)

	-- 플레이어 저장
	
	local playersInGame = {}
	local players = game.Players:GetPlayers()
	for i, player in pairs(players) do
		while not player.Character do
			wait(1)
		end
	end

	for i, player in pairs(players) do
		
		if not player then
			continue
		end
		
		table.insert(playersInGame, player)
		ChangeGameStateSTC:FireClient(player, GameStateType.Starting)
	end
	
    -- 임시 코드
	Initializer:ClearPlayers(playersInGame)

	wait(5)
	
	-- 맵 선택

	--ServerGlobalStorage:SelectRandomMapAndEnterMap(playersInGame)
	ServerGlobalStorage:SelectDesertMapAndEnterMapTemp(playersInGame)
	Initializer:StartGame(playersInGame)
	
	-- 맵 선택 메시지, 게임 시작 메시지
	for i, player in pairs(playersInGame) do

		if not player then
			table.remove(playersInGame, i)
			continue
		end

		ChangeGameStateSTC:FireClient(player, GameStateType.Playing, "DesertMap")
	end
	
	local currentGameLength = DefaultGameLength
	
	local prevTime = 0
	local elapsedTime = 0
	local currentCharacter = nil
	local finalPlayerCount = #playersInGame

	local winnerType
	local winnerName
	local winnerReward
	
	while true do
		
		prevTime = os.clock()
		
		wait(1)
		
		for i, player in pairs(playersInGame) do
			
			if not player then
				-- 플레이어가 떠났을 때
				table.remove(playersInGame, i)
				continue
			end
			
			currentCharacter = player.Character
			
			if not currentCharacter then
				-- 플레이어의 캐릭터가 사망 / 플레이어가 떠났을 때
				table.remove(playersInGame, i)
			else
				if not currentCharacter:FindFirstChild("AliveTag") then
					table.remove(playersInGame, i)
				end
			end
		end
		
		elapsedTime = os.clock() - prevTime
		currentGameLength -= elapsedTime
		if currentGameLength < 0 then
			currentGameLength = 0
		end
		
		-- 클라이언트로 리플리케이션
		CurrentGameLength.Value = currentGameLength
		PlayersLeftCount.Value = #playersInGame
		
		-- 게임 종료 조건 확인
		if #playersInGame == 1 then
			--local reward = (playersInGame[1].KilledCount + (finalPlayerCount / 2)) * DefaultReward
			local reward = (finalPlayerCount / 2) * DefaultReward

			winnerType = WinnerType.Player
			winnerName = playersInGame[1].Name
			winnerReward = reward
			
			playersInGame[1].leaderstats.Coins.Value += reward
			break
			
		elseif #playersInGame == 0 then
			winnerType = WinnerType.NoOne_AllPlayersWereDead
			break
			
		elseif currentGameLength <= 0 then
			winnerType = WinnerType.NoOne_TimeIsUp
			break
		end
	end

	wait(8)
	if winnerType == WinnerType.Player then
		NotifyWinnerSTC:FireAllClients(winnerType, winnerName, winnerReward)
	else
		NotifyWinnerSTC:FireAllClients(winnerType)
	end
	
	
	wait(5)

	-- 맵 정리
	Initializer:ClearPlayers(playersInGame)
	ClearGui()
	ServerGlobalStorage:ClearCurrentMap()
	
	wait(5)
end