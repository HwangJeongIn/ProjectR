local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiFacade = require(PlayerGui:WaitForChild("GuiFacade"))

local GuiBarsWindow = GuiFacade.GuiBarsWindow


local GuiBarsWindowController = {}

function GuiBarsWindowController:Initialize()
	self.GuiHpBarController = require(script:WaitForChild("GuiHpBarController"))
end

GuiBarsWindowController:Initialize()
return GuiBarsWindowController
