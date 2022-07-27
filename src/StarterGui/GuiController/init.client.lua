-- 클라이언트에게 보여주는 GUI이기 때문에 LocalScript 사용


-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- StarterGui UI

local StarterGui = script.Parent

local MainMessageText = StarterGui:WaitForChild("MainMessage").MainMessageText
local EventMessageText = StarterGui:WaitForChild("EventMessage").EventMessageText

local PlayersLeftCountText = StarterGui.PlayersLeftCount.PlayersLeftCountText
local KilledCountText = StarterGui.KilledCount.KilledCountText

local CurrentGameLengthText = StarterGui.CurrentGameLength.CurrentGameLengthText


-- 공통 저장소 변수

local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local GameStateType = CommonModuleFacade.CommonEnum.GameStateType
local WinnerType = CommonModuleFacade.CommonEnum.WinnerType


-- 리플리케이션 저장소 변수


--local MainMessage = ReplicatedStorage:WaitForChild("MainMessage")
--MainMessageText.Text = MainMessage.Value

local PlayersLeftCount = ReplicatedStorage:WaitForChild("PlayersLeftCount")
PlayersLeftCountText.Text = PlayersLeftCount.Value

local CurrentGameLength = ReplicatedStorage:WaitForChild("CurrentGameLength")
CurrentGameLengthText.Text = CurrentGameLength.Value

-- Remote Event

local ChangeGameStateSTC = ReplicatedStorage:WaitForChild("ChangeGameStateSTC")
local NotifyWinnerSTC = ReplicatedStorage:WaitForChild("NotifyWinnerSTC")

local ChangeGameDataCTS = ReplicatedStorage:WaitForChild("ChangeGameDataCTS")


PlayersLeftCount:GetPropertyChangedSignal("Value"):Connect(function()
	PlayersLeftCountText.Text = PlayersLeftCount.Value
end)

CurrentGameLength:GetPropertyChangedSignal("Value"):Connect(function()
	CurrentGameLengthText.Text = CurrentGameLength.Value
end)


-- 함수 정의 ------------------------------------------------------------------------------------------------------

local function ToggleInGameGui(isEnabled)
	PlayersLeftCountText.Parent.Enabled = isEnabled
	CurrentGameLengthText.Parent.Enabled = isEnabled
	KilledCountText.Parent.Enabled = isEnabled
end


local function SetMainMessage(inputText)
	
	if inputText == "" then
		
		MainMessageText.Parent.Enabled = false
		
	else
--[[
		local length = inputText:len()
		local boxSize = length * 20 + 40

		if MainMessageText.Size.X.Offset ~= boxSize then
			MainMessageText.Size = UDim2.fromOffset(boxSize, MainMessageText.Size.Y.Offset)
		end

		if MainMessageText.Position.X.Offset ~= (-(boxSize/2)) then
			MainMessageText.Position = UDim2.new(MainMessageText.Position.X.Scale, -(boxSize/2), MainMessageText.Position.Y.Offset, MainMessageText.Position.Y.Scale)
		end
--]]
		MainMessageText.Text = inputText
		MainMessageText.Parent.Enabled = true
	end
end

local function SetEventMessage(inputText)
	
	if inputText == "" then

		EventMessageText.Parent.Enabled = false

	else

		EventMessageText.Text = inputText
		EventMessageText.Parent.Enabled = true
		
		wait(3)

		EventMessageText.Parent.Enabled = false
	end
end


local function ProcessWaiting(arguments)

	print("GameStateType.Waiting in client")
	SetMainMessage("Waiting ... ")
	PlayersLeftCountText.Parent.Enabled = false
	CurrentGameLengthText.Parent.Enabled = false
	KilledCountText.Parent.Enabled = false
	
end


local function ProcessStarting(arguments)

	print("GameStateType.Starting in client")
	for i = 5, 1, -1 do
		SetMainMessage(tostring(i))
		wait(1)
	end
	
end


local function ProcessPlaying(arguments)

	local mapName = arguments[1]
	SetMainMessage(mapName .. " is selected")
	
	wait(2)
	
	SetMainMessage("Get ready to play")
	PlayersLeftCountText.Parent.Enabled = true
	CurrentGameLengthText.Parent.Enabled = true
	KilledCountText.Parent.Enabled = true
	
	wait(2)
	
	SetMainMessage("")
	
end


local function ProcessDead(arguments)

	SetMainMessage("You Died")
	
end


local function ProcessWaitingForFinishing(arguments)
	
	ProcessWaiting()
	
end


local GameStateProcessSelector = {
	[GameStateType.Waiting] = ProcessWaiting,
	[GameStateType.Starting] = ProcessStarting,
	[GameStateType.Playing] = ProcessPlaying,
	[GameStateType.Dead] = ProcessDead,
	[GameStateType.WaitingForFinishing] = ProcessWaitingForFinishing,
}

ChangeGameStateSTC.OnClientEvent:Connect(function(gameState, ...)
	
	print("GameStateType : " .. gameState)
	GameStateProcessSelector[gameState](...)
end)


local WinnerProcessSelector = {
	[WinnerType.Player] = "Winner is ",
	[WinnerType.NoOne_TimeIsUp] = "Time is up",
	[WinnerType.NoOne_AllPlayersWereDead] = "No one won the game",
	[WinnerType.Ai] = "Winner is AI",
}

NotifyWinnerSTC.OnClientEvent:Connect(function(winnerType, winnerName, winnerReward)
	
	local winnerMessageString = WinnerProcessSelector[winnerType]
	local rewardMessageString = ""
	
	if winnerName ~= nil then
		winnerMessageString = winnerMessageString .. winnerName
		if winnerReward ~= nil then
			rewardMessageString = winnerName .. " got " .. tostring(winnerReward) .. " coins"
		end
	end
	
	SetMainMessage(winnerMessageString)
	
	wait(3)
	
	if rewardMessageString then
		SetMainMessage(rewardMessageString)
	end
	
end)


-- 실행 코드 ------------------------------------------------------------------------------------------------------
