--[[

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

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
