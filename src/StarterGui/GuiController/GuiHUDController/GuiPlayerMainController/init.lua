local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiHUD = PlayerGui:WaitForChild("GuiHUD")

local GuiPlayerMain = GuiHUD:WaitForChild("GuiPlayerMain")

local GuiBarsWindow = GuiPlayerMain:WaitForChild("GuiBarsWindow")
local GuiSlotsWindow = GuiPlayerMain:WaitForChild("GuiSlotsWindow")


local GuiPlayerMainController = {}

function GuiPlayerMainController:Initialize()
	self.GuiBarsWindowController = require(script:WaitForChild("GuiBarsWindowController"))
	self.GuiSlotsWindowController = require(script:WaitForChild("GuiSlotsWindowController"))
end

GuiPlayerMainController:Initialize()
return GuiPlayerMainController
