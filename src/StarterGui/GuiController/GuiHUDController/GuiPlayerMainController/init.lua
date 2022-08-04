local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiFacade = require(PlayerGui:WaitForChild("GuiFacade"))

local GuiPlayerMain = GuiFacade.GuiPlayerMain

local GuiBarsWindow = GuiFacade.GuiBarsWindow
local GuiSlotsWindow = GuiFacade.GuiSlotsWindow

local GuiPlayerMainController = {}

function GuiPlayerMainController:Initialize()
	self.GuiBarsWindowController = require(script:WaitForChild("GuiBarsWindowController"))
	self.GuiSlotsWindowController = require(script:WaitForChild("GuiSlotsWindowController"))
end

GuiPlayerMainController:Initialize()
return GuiPlayerMainController
