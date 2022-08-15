local UserInputService = game:GetService("UserInputService")			-- 선택해야한다.
local ContextActionService = game:GetService("ContextActionService")	-- 선택해야한다.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonModuleFacade.Debug
local Utility = CommonModuleFacade.Utility

local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local GuiPlayerStatus = PlayerGui:WaitForChild("GuiPlayerStatus")
local GuiPlayerStatusWindow = GuiPlayerStatus:WaitForChild("GuiPlayerStatusWindow")


local KeyBinder = {}
KeyBinder.__index = Utility.Inheritable__index
KeyBinder.__newindex = Utility.Inheritable__newindex

local InputToActionMappingTable = {
	[Enum.UserInputState.Begin] = {
		Always = {},
		[Enum.KeyCode.One] = {},
		[Enum.KeyCode.Two] = {},
		[Enum.KeyCode.Three] = {},
		[Enum.KeyCode.Four] = {},
		[Enum.KeyCode.Five] = {},
		--[Enum.KeyCode.Backquote] = {},
		[Enum.KeyCode.Q] = {},
		[Enum.KeyCode.E] = {},
		[Enum.KeyCode.R] = {}
	},

	[Enum.UserInputState.Change] = {
		Always = {}
	},

	[Enum.UserInputState.End] = {
		Always = {}
	}
}

function OnInput(input)
	local targetInputStateActions = InputToActionMappingTable[input.UserInputState]
	local targetInputTypeActions = nil

	for _, action in pairs(targetInputStateActions.Always) do
		action(input)
	end

	if input.KeyCode == Enum.KeyCode.Unknown then
		targetInputTypeActions = targetInputStateActions[input.UserInputType]
	else
		targetInputTypeActions = targetInputStateActions[input.KeyCode]
	end
	
	if not targetInputTypeActions then
		return
	end

	for _, action in pairs(targetInputTypeActions) do
		action(input)
	end
end

UserInputService.InputBegan:Connect(OnInput)
UserInputService.InputChanged:Connect(OnInput)
UserInputService.InputEnded:Connect(OnInput)

-- 무시되는 경우가 있어서 일단 보류
--[[
function KeyBinder:BindCustomAction(keyCodeOrUserInputType, userInputState, customActionName, customAction)
	ContextActionService:BindAction(
		customActionName,
		function(actionName, inputState, inputObject)
			if (inputState == userInputState) then
				customAction(inputObject)
			end
		end,
		true,
		keyCodeOrUserInputType)
end
--]]

function KeyBinder:UnbindAction(userInputState, keyCodeOrUserInputType, actionName)
	if not userInputState then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local targetInputStateActions = InputToActionMappingTable[userInputState]
	if not targetInputStateActions then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not keyCodeOrUserInputType then
		targetInputStateActions.Always[actionName] = nil
	else
		if targetInputStateActions[keyCodeOrUserInputType] then
			targetInputStateActions[keyCodeOrUserInputType][actionName] = nil
		end
	end

	return true
end

function KeyBinder:BindAction(userInputState, keyCodeOrUserInputType, actionName, action)
	if not userInputState or not action then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	local typeString = type(action)
	if typeString ~= "function" then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	local targetInputStateActions = InputToActionMappingTable[userInputState]
	if not targetInputStateActions then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not keyCodeOrUserInputType then
		if targetInputStateActions.Always[actionName] then
			Debug.Assert(false, "이미 존재하는 이름입니다. => " .. actionName)
			return false
		end
		targetInputStateActions.Always[actionName] = action
	else
		if not targetInputStateActions[keyCodeOrUserInputType] then
			targetInputStateActions[keyCodeOrUserInputType] = { [actionName] = action }
		else
			if targetInputStateActions[keyCodeOrUserInputType][actionName] then
				Debug.Assert(false, "이미 존재하는 이름입니다. => " .. actionName)
				return false
			end
			targetInputStateActions[keyCodeOrUserInputType][actionName] = action
		end
	end

	return true
end

function KeyBinder:Initialize()
	for keyCode, actionTable in pairs(InputToActionMappingTable) do
		
		local actionName = tostring(keyCode)
		ContextActionService:BindAction(
			actionName,
			function(actionName, inputState, inputObject)
				if (inputState == Enum.UserInputState.Begin) then
					for _, action in pairs(actionTable) do
						action(actionName, inputState, inputObject)
					end
				end
			end,
			true, keyCode)

		--[[
		ContextActionService:BindActionAtPriority(
			actionName,
			function(keyCode, action, actionName) 
				for actionName, action in pairs(actionTable) do
					action(keyCode, action, actionName)
				end
			end,
			true, 1, keyCode) -- 1은 우선순위
		--]]

	end
end

--KeyBinder:Initialize()
return KeyBinder

--[[
local character = nil
local player = nil

if true then
	player = script.Parent.Parent
else
	character = script.Parent
	player = game.Players:GetPlayerFromCharacter(character)
end

local backpack = player:FindFirstChild("Backpack")
local UserInputService = game:GetService("UserInputService")

local caseSelector = {
	[Enum.KeyCode.One] = function() end
}


local function handleOne1(actionName, inputState, inputObject)
	print("handleOne1 => " .. actionName)
end

local function handleOne2(actionName, inputState, inputObject)
	print("handleOne2 => " .. actionName)
end


local function handleOne3(actionName, inputState, inputObject)
	print("handleOne3 => " .. actionName)
end

local function handleOne4(actionName, inputState, inputObject)
	print("handleOne4 => " .. actionName)
end

local ContextActionService = game:GetService("ContextActionService")
ContextActionService:BindAction("One3", handleOne3, true, Enum.KeyCode.One)
ContextActionService:BindAction("One4", handleOne4, true, Enum.KeyCode.One)

ContextActionService:BindActionAtPriority("One1", handleOne1, true, 2, Enum.KeyCode.One)
ContextActionService:BindActionAtPriority("One2", handleOne2, true, 1, Enum.KeyCode.One)

return {}
--]]
--[[


local function onInputBegan(inputObject, gameProcessedEvent)
	-- First check if the "gameProcessedEvent" is true
	-- This indicates that another script had already processed the input, so this one can be ignored
	if gameProcessedEvent then return end
	-- Next, check that the input was a keyboard event
	if inputObject.UserInputType == Enum.UserInputType.Keyboard then
		print("A key was released: " .. inputObject.KeyCode.Name)

		--if Enum.KeyCode. ==
		local starterGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")

		local a = 3
	end
end

local function onInputEnded(inputObject, gameProcessedEvent)
	-- First check if the "gameProcessedEvent" is true
	-- This indicates that another script had already processed the input, so this one can be ignored
	if gameProcessedEvent then return end
	-- Next, check that the input was a keyboard event
	if inputObject.UserInputType == Enum.UserInputType.Keyboard then
		print("A key was released: " .. inputObject.KeyCode.Name)

		--if Enum.KeyCode. ==
	end
end


UserInputService.InputEnded:Connect(onInputEnded)
UserInputService.InputBegan:Connect(onInputBegan)
--]]