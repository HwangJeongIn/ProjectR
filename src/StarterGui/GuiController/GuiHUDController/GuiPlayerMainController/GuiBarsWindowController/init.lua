local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiHUD = PlayerGui:WaitForChild("GuiHUD")

local GuiPlayerMain = GuiHUD:WaitForChild("GuiPlayerMain")

local GuiBarsWindow = GuiPlayerMain:WaitForChild("GuiBarsWindow")


local GuiBarsWindowController = {}

function GuiBarsWindowController:Initialize()
	self.GuiHpBarController = require(script:WaitForChild("GuiHpBarController"))
end

GuiBarsWindowController:Initialize()
return GuiBarsWindowController
