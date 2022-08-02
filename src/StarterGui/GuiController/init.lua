local PlayerGui = script.Parent

local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ClientModuleFacade = require(StarterPlayerScripts:WaitForChild("ClientModuleFacade"))

local ClientGlobalStorage = ClientModuleFacade.ClientGlobalStorage
local Debug = ClientModuleFacade.Debug
local GameStateType = ClientModuleFacade.CommonEnum.GameStateType
local WinnerType = ClientModuleFacade.CommonEnum.WinnerType


-- 리플리케이션 저장소 변수
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteValues = ReplicatedStorage:WaitForChild("RemoteValues")

local PlayersLeftCount = RemoteValues:WaitForChild("PlayersLeftCount")
local CurrentGameLength = RemoteValues:WaitForChild("CurrentGameLength")

local GuiController = {}

-- 함수 정의 ------------------------------------------------------------------------------------------------------

function GuiController:Initialize()
	GuiController.GuiInventoryController = require(script:WaitForChild("GuiInventoryController"))
	GuiController.GuiEquipSlotsController = require(script:WaitForChild("GuiEquipSlotsController"))
	
	self.GuiMainMessageText = PlayerGui:WaitForChild("GuiMainMessage").GuiMainMessageText
	self.GuiEventMessageText = PlayerGui:WaitForChild("GuiEventMessage").GuiEventMessageText
	
	local GuiBoard = PlayerGui:WaitForChild("GuiBoard")
	self.GuiPlayersLeftCountText = GuiBoard:WaitForChild("GuiPlayersLeftCount"):WaitForChild("GuiPlayersLeftCountText")
	self.GuiKilledCountText = GuiBoard:WaitForChild("GuiKilledCount"):WaitForChild("GuiKilledCountText")
	self.GuiCurrentGameLengthText = GuiBoard:WaitForChild("GuiCurrentGameLength"):WaitForChild("GuiCurrentGameLengthText")

	self.GuiPlayersLeftCountText.Text = PlayersLeftCount.Value
	self.GuiCurrentGameLengthText.Text = CurrentGameLength.Value
	
	PlayersLeftCount:GetPropertyChangedSignal("Value"):Connect(function()
		self.GuiPlayersLeftCountText.Text = PlayersLeftCount.Value
	end)

	CurrentGameLength:GetPropertyChangedSignal("Value"):Connect(function()
		self.GuiCurrentGameLengthText.Text = CurrentGameLength.Value
	end)

	self.GameStateProcessSelector = {
		[GameStateType.Waiting] = self.ProcessWaiting,
		[GameStateType.Starting] = self.ProcessStarting,
		[GameStateType.Playing] = self.ProcessPlaying,
		[GameStateType.Dead] = self.ProcessDead,
		[GameStateType.WaitingForFinishing] = self.ProcessWaitingForFinishing,
	}
	
	self.WinnerProcessSelector = {
		[WinnerType.Player] = "Winner is ",
		[WinnerType.NoOne_TimeIsUp] = "Time is up",
		[WinnerType.NoOne_AllPlayersWereDead] = "No one won the game",
		[WinnerType.Ai] = "Winner is AI",
	}

	ClientGlobalStorage:Initialize(self)
end

function GuiController:ToggleInGameGui(isEnabled)
	self.GuiPlayersLeftCountText.Parent.Enabled = isEnabled
	self.GuiCurrentGameLengthText.Parent.Enabled = isEnabled
	self.GuiKilledCountText.Parent.Enabled = isEnabled
end

function GuiController:SetGuiMainMessage(inputText)
	if inputText == "" then
		self.GuiMainMessageText.Parent.Enabled = false
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
		self.GuiMainMessageText.Text = inputText
		self.GuiMainMessageText.Parent.Enabled = true
	end
end

function GuiController:SetGuiEventMessage(inputText)
	
	if inputText == "" then
		self.GuiEventMessageText.Parent.Enabled = false
	else
		self.GuiEventMessageText.Text = inputText
		self.GuiEventMessageText.Parent.Enabled = true
		wait(3)
		self.GuiEventMessageText.Parent.Enabled = false
	end
end

function GuiController:ProcessWaiting(arguments)
	print("GameStateType.Waiting in client")
	self:SetGuiMainMessage("Waiting ... ")
	self.GuiPlayersLeftCountText.Parent.Enabled = false
	self.GuiCurrentGameLengthText.Parent.Enabled = false
	self.GuiKilledCountText.Parent.Enabled = false
	
end

function GuiController:ProcessStarting(arguments)
	print("GameStateType.Starting in client")
	for i = 5, 1, -1 do
		self:SetGuiMainMessage(tostring(i))
		wait(1)
	end
end

function GuiController:ProcessPlaying(arguments)
	local mapName = arguments[1]
	self:SetGuiMainMessage(mapName .. " is selected")
	
	wait(2)
	
	self:SetGuiMainMessage("Get ready to play")
	self.GuiPlayersLeftCountText.Parent.Enabled = true
	self.GuiCurrentGameLengthText.Parent.Enabled = true
	self.GuiKilledCountText.Parent.Enabled = true
	
	wait(2)
	
	self:SetGuiMainMessage("")
end

function GuiController:ProcessDead(arguments)
	self:SetGuiMainMessage("You Died")
end

function GuiController:ProcessWaitingForFinishing(arguments)
	self:ProcessWaiting()
end


function GuiController:ChangeGameState(gameState, arguments)
	--print("GameStateType : " .. gameState)
	self.GameStateProcessSelector[gameState](self, arguments)
end


function GuiController:SetWinnerMessage(winnerType, winnerName, winnerReward)
	local winnerMessageString = self.WinnerProcessSelector[winnerType]
	local rewardMessageString = ""
	
	if winnerName ~= nil then
		winnerMessageString = winnerMessageString .. winnerName
		if winnerReward ~= nil then
			rewardMessageString = winnerName .. " got " .. tostring(winnerReward) .. " coins"
		end
	end
	
	self:SetGuiMainMessage(winnerMessageString)
	wait(3)
	
	if rewardMessageString then
		self:SetGuiMainMessage(rewardMessageString)
	end
end

function GuiController:SetInventoryToolSlot(slotIndex, tool)
	if not slotIndex then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not self.GuiInventoryController:SetToolSlot(slotIndex, tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function GuiController:SetEquipToolSlot(equipType, tool)
	if not equipType then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not self.GuiEquipSlotsController:SetToolSlot(equipType, tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end
GuiController:Initialize()
return GuiController

-- 실행 코드 ------------------------------------------------------------------------------------------------------
