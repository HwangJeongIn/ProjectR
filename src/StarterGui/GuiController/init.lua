local ReplicatedStorage = game:GetService("ReplicatedStorage")


local PlayerGui = script.Parent

local GuiController = {}
GuiController.GuiInventoryController = require(script:WaitForChild("GuiInventoryController"))
GuiController.GuiEquipSlotsController = require(script:WaitForChild("GuiEquipSlotsController"))

local GuiMainMessageText = PlayerGui:WaitForChild("GuiMainMessage").GuiMainMessageText
local GuiEventMessageText = PlayerGui:WaitForChild("GuiEventMessage").GuiEventMessageText

local GuiBoard = PlayerGui:WaitForChild("GuiBoard")
local GuiPlayersLeftCountText = GuiBoard:WaitForChild("GuiPlayersLeftCount"):WaitForChild("GuiPlayersLeftCountText")
local GuiKilledCountText = GuiBoard:WaitForChild("GuiKilledCount"):WaitForChild("GuiKilledCountText")
local GuiCurrentGameLengthText = GuiBoard:WaitForChild("GuiCurrentGameLength"):WaitForChild("GuiCurrentGameLengthText")

local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonModuleFacade.Debug
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

PlayersLeftCount:GetPropertyChangedSignal("Value"):Connect(function()
	GuiPlayersLeftCountText.Text = PlayersLeftCount.Value
end)

CurrentGameLength:GetPropertyChangedSignal("Value"):Connect(function()
	GuiCurrentGameLengthText.Text = CurrentGameLength.Value
end)



-- 함수 정의 ------------------------------------------------------------------------------------------------------

function ToggleInGameGui(isEnabled)
	GuiPlayersLeftCountText.Parent.Enabled = isEnabled
	GuiCurrentGameLengthText.Parent.Enabled = isEnabled
	GuiKilledCountText.Parent.Enabled = isEnabled
end


function SetGuiMainMessage(inputText)
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

function SetGuiEventMessage(inputText)
	
	if inputText == "" then
		GuiEventMessageText.Parent.Enabled = false
	else
		GuiEventMessageText.Text = inputText
		GuiEventMessageText.Parent.Enabled = true
		wait(3)
		GuiEventMessageText.Parent.Enabled = false
	end
end

function ProcessWaiting(arguments)
	print("GameStateType.Waiting in client")
	SetGuiMainMessage("Waiting ... ")
	GuiPlayersLeftCountText.Parent.Enabled = false
	GuiCurrentGameLengthText.Parent.Enabled = false
	GuiKilledCountText.Parent.Enabled = false
	
end

function ProcessStarting(arguments)
	print("GameStateType.Starting in client")
	for i = 5, 1, -1 do
		SetGuiMainMessage(tostring(i))
		wait(1)
	end
end

function ProcessPlaying(arguments)
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

function ProcessDead(arguments)
	SetGuiMainMessage("You Died")
end

function ProcessWaitingForFinishing(arguments)
	ProcessWaiting()
end

local GameStateProcessSelector = {
	[GameStateType.Waiting] = ProcessWaiting,
	[GameStateType.Starting] = ProcessStarting,
	[GameStateType.Playing] = ProcessPlaying,
	[GameStateType.Dead] = ProcessDead,
	[GameStateType.WaitingForFinishing] = ProcessWaitingForFinishing,
}
function GuiController:OnChangeGameStateSTC(gameState, arguments)
	--print("GameStateType : " .. gameState)
	GameStateProcessSelector[gameState](arguments)
end

local WinnerProcessSelector = {
	[WinnerType.Player] = "Winner is ",
	[WinnerType.NoOne_TimeIsUp] = "Time is up",
	[WinnerType.NoOne_AllPlayersWereDead] = "No one won the game",
	[WinnerType.Ai] = "Winner is AI",
}
function GuiController:OnNotifyWinnerSTC(winnerType, winnerName, winnerReward)
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
end

function GuiController:OnSetInventorySlotSTC(slotIndex, tool)
	if not self.GuiInventoryController:SetTool(slotIndex, tool) then
		Debug.Assert(false, "비정상입니다.")
	end
end



return GuiController

-- 실행 코드 ------------------------------------------------------------------------------------------------------
