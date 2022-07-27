-- 클라이언트에게 보여주는 GUI이기 때문에 LocalScript 사용


-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- PlayerGui UI

local PlayerGui = script.Parent

local GuiMainMessageText = PlayerGui:WaitForChild("GuiMainMessage").GuiMainMessageText
local GuiEventMessageText = PlayerGui:WaitForChild("GuiEventMessage").GuiEventMessageText


local GuiBoard = PlayerGui:WaitForChild("GuiBoard")
local GuiPlayersLeftCountText = GuiBoard:WaitForChild("GuiPlayersLeftCount"):WaitForChild("GuiPlayersLeftCountText")
local GuiKilledCountText = GuiBoard:WaitForChild("GuiKilledCount"):WaitForChild("GuiKilledCountText")
local GuiCurrentGameLengthText = GuiBoard:WaitForChild("GuiCurrentGameLength"):WaitForChild("GuiCurrentGameLengthText")


-- 공통 저장소 변수

local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local GameStateType = CommonModuleFacade.CommonEnum.GameStateType
local WinnerType = CommonModuleFacade.CommonEnum.WinnerType


-- 리플리케이션 저장소 변수


--local GuiMainMessage = ReplicatedStorage:WaitForChild("GuiMainMessage")
--GuiMainMessageText.Text = GuiMainMessage.Value

local RemoteValues = ReplicatedStorage:WaitForChild("RemoteValues")

local PlayersLeftCount = RemoteValues:WaitForChild("PlayersLeftCount")
GuiPlayersLeftCountText.Text = PlayersLeftCount.Value

local CurrentGameLength = RemoteValues:WaitForChild("CurrentGameLength")
GuiCurrentGameLengthText.Text = CurrentGameLength.Value

-- Remote Event

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local ChangeGameStateSTC = RemoteEvents:WaitForChild("ChangeGameStateSTC")
local NotifyWinnerSTC = RemoteEvents:WaitForChild("NotifyWinnerSTC")
local ChangeGameDataCTS = RemoteEvents:WaitForChild("ChangeGameDataCTS")


PlayersLeftCount:GetPropertyChangedSignal("Value"):Connect(function()
	GuiPlayersLeftCountText.Text = PlayersLeftCount.Value
end)

CurrentGameLength:GetPropertyChangedSignal("Value"):Connect(function()
	GuiCurrentGameLengthText.Text = CurrentGameLength.Value
end)


-- 함수 정의 ------------------------------------------------------------------------------------------------------

local function ToggleInGameGui(isEnabled)
	GuiPlayersLeftCountText.Parent.Enabled = isEnabled
	GuiCurrentGameLengthText.Parent.Enabled = isEnabled
	GuiKilledCountText.Parent.Enabled = isEnabled
end


local function SetGuiMainMessage(inputText)
	
	if inputText == "" then
		
		GuiMainMessageText.Parent.Enabled = false
		
	else
--[[
		local length = inputText:len()
		local boxSize = length * 20 + 40

		if GuiMainMessageText.Size.X.Offset ~= boxSize then
			GuiMainMessageText.Size = UDim2.fromOffset(boxSize, GuiMainMessageText.Size.Y.Offset)
		end

		if GuiMainMessageText.Position.X.Offset ~= (-(boxSize/2)) then
			GuiMainMessageText.Position = UDim2.new(GuiMainMessageText.Position.X.Scale, -(boxSize/2), GuiMainMessageText.Position.Y.Offset, GuiMainMessageText.Position.Y.Scale)
		end
--]]
		GuiMainMessageText.Text = inputText
		GuiMainMessageText.Parent.Enabled = true
	end
end

local function SetGuiEventMessage(inputText)
	
	if inputText == "" then

		GuiEventMessageText.Parent.Enabled = false

	else

		GuiEventMessageText.Text = inputText
		GuiEventMessageText.Parent.Enabled = true
		
		wait(3)

		GuiEventMessageText.Parent.Enabled = false
	end
end


local function ProcessWaiting(arguments)

	print("GameStateType.Waiting in client")
	SetGuiMainMessage("Waiting ... ")
	GuiPlayersLeftCountText.Parent.Enabled = false
	GuiCurrentGameLengthText.Parent.Enabled = false
	GuiKilledCountText.Parent.Enabled = false
	
end


local function ProcessStarting(arguments)

	print("GameStateType.Starting in client")
	for i = 5, 1, -1 do
		SetGuiMainMessage(tostring(i))
		wait(1)
	end
	
end


local function ProcessPlaying(arguments)

	local mapName = arguments[1]
	SetGuiMainMessage(mapName .. " is selected")
	
	wait(2)
	
	SetGuiMainMessage("Get ready to play")
	GuiPlayersLeftCountText.Parent.Enabled = true
	GuiCurrentGameLengthText.Parent.Enabled = true
	GuiKilledCountText.Parent.Enabled = true
	
	wait(2)
	
	SetGuiMainMessage("")
	
end


local function ProcessDead(arguments)

	SetGuiMainMessage("You Died")
	
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
	GameStateProcessSelector[gameState]({...})
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
	
	SetGuiMainMessage(winnerMessageString)
	
	wait(3)
	
	if rewardMessageString then
		SetGuiMainMessage(rewardMessageString)
	end
	
end)


-- 실행 코드 ------------------------------------------------------------------------------------------------------
