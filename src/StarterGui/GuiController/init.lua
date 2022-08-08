local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ClientModuleFacade = require(StarterPlayerScripts:WaitForChild("ClientModuleFacade"))

local ClientGlobalStorage = ClientModuleFacade.ClientGlobalStorage
local Debug = ClientModuleFacade.Debug
local GameStateType = ClientModuleFacade.CommonEnum.GameStateType
local WinnerType = ClientModuleFacade.CommonEnum.WinnerType

local KeyBinder = ClientModuleFacade.KeyBinder


-- 리플리케이션 저장소 변수
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteValues = ReplicatedStorage:WaitForChild("RemoteValues")

local PlayersLeftCount = RemoteValues:WaitForChild("PlayersLeftCount")
local CurrentGameLength = RemoteValues:WaitForChild("CurrentGameLength")


local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiFacade = require(PlayerGui:WaitForChild("GuiFacade"))


local GuiController = {}

-- 함수 정의 ------------------------------------------------------------------------------------------------------

function GuiController:BindGuiKeys()

	-- Service
	local TweenService = game:GetService("TweenService")

	-- Gui
	local GuiPlayerStatus = GuiFacade.GuiPlayerStatus
	local GuiPlayerStatusWindow = GuiFacade.GuiPlayerStatusWindow

	-- GuiController
	local GuiTooltipController = GuiFacade.GuiTooltipController

	local GuiPlayerStatusGuiTweenInfo = TweenInfo.new(
		.5, -- Time
		Enum.EasingStyle.Linear,--Enum.EasingStyle.Back, --Enum.EasingStyle.Linear, -- EasingStyle
		Enum.EasingDirection.In, -- EasingDirection
		0, -- RepeatCount (when less than zero the tween will loop indefinitely)
		false, -- Reverses (tween will reverse once reaching it's goal)
		0 -- DelayTime
	)
	--local tween = TweenService:Create(part, GuiInventoryTweenInfo, {Position = Vector3.new(0, 0, 0)})
	--local tween = TweenService:Create(GuiPlayerStatusWindow, GuiPlayerStatusGuiTweenInfo, { Position = UDim2.new(0,0,.5,0)})
	local GuiPlayerStatusGuiTween = TweenService:Create(GuiPlayerStatusWindow, GuiPlayerStatusGuiTweenInfo, { Position = UDim2.new(.5,0,.5,0)})
	
	KeyBinder:BindCustomAction(Enum.KeyCode.Backquote, Enum.UserInputState.Begin, "GuiPlayerStatusToggleKey", 
	function(inputObject)
		if GuiPlayerStatus.Enabled then
			GuiPlayerStatusWindow.Position = UDim2.new(0.3,0,.5,0)
			GuiTooltipController:ClearToolData()
		else
			GuiPlayerStatusGuiTween:Play()
		end
		GuiPlayerStatus.Enabled = not GuiPlayerStatus.Enabled
	end)
end

function GuiController:InitializeTopbar()
	local StarterGui = game:GetService("StarterGui")
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)

	-- Create a "Fake" replacement topbar with a ScreenGui and Frame
	local GuiTopbar = Instance.new("ScreenGui")
	local GuiTopbarWindow = Instance.new("Frame")
	 
	-- Move (0, 0) to the actual top left corner of the screen, instead of under the topbar
	GuiTopbar.IgnoreGuiInset = true
	GuiTopbar.Name = "GuiTopbar"
	-- The topbar is 36 pixels tall, and spans the entire width of the screen
	GuiTopbarWindow.Size = UDim2.new(1, 0, 0, 36) 
	GuiTopbarWindow.Name = "GuiTopbarWindow"
	-- Style the topbar
	GuiTopbarWindow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	GuiTopbarWindow.BackgroundTransparency = 0.2
	GuiTopbarWindow.BorderSizePixel = 0
	 
	GuiTopbarWindow.Parent = GuiTopbar
	GuiTopbar.Parent = PlayerGui
end

function GuiController:Initialize()
	self.GuiInventoryController = require(script:WaitForChild("GuiInventoryController"))
	self.GuiEquipSlotsController = require(script:WaitForChild("GuiEquipSlotsController"))
	local GuiHUDController = require(script:WaitForChild("GuiHUDController"))
	self.GuiQuickSlotsController = GuiHUDController.GuiQuickSlotsController
	self.GuiSkillSlotsController = GuiHUDController.GuiSkillSlotsController

	self.GuiMainMessageText = PlayerGui:WaitForChild("GuiMainMessage").GuiMainMessageText
	self.GuiEventMessageText = PlayerGui:WaitForChild("GuiEventMessage").GuiEventMessageText
	
	self.GuiBoardWindow = GuiFacade.GuiBoardWindow
	self.GuiPlayersLeftCountText = self.GuiBoardWindow:WaitForChild("GuiPlayersLeftCount"):WaitForChild("GuiPlayersLeftCountText")
	self.GuiKilledCountText = self.GuiBoardWindow:WaitForChild("GuiKilledCount"):WaitForChild("GuiKilledCountText")
	self.GuiCurrentGameLengthText = self.GuiBoardWindow:WaitForChild("GuiCurrentGameLength"):WaitForChild("GuiCurrentGameLengthText")

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

	self:InitializeTopbar()
	self:BindGuiKeys()
	ClientGlobalStorage:Initialize(self)
end

function GuiController:ToggleInGameGui(isEnabled)
	self.GuiPlayersLeftCountText.Parent.Visible = isEnabled
	self.GuiCurrentGameLengthText.Parent.Visible = isEnabled
	self.GuiKilledCountText.Parent.Visible = isEnabled
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

	self:ToggleInGameGui(false)
	
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

	self:ToggleInGameGui(true)

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

function GuiController:SetQuickToolSlot(slotIndex, tool)
	if not slotIndex then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not self.GuiQuickSlotsController:SetToolSlot(slotIndex, tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end


GuiController:Initialize()
return GuiController

-- 실행 코드 ------------------------------------------------------------------------------------------------------
