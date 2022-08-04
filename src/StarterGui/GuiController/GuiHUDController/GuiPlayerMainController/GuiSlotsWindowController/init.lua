local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiFacade = require(PlayerGui:WaitForChild("GuiFacade"))

local GuiQuickSlots = GuiFacade.GuiQuickSlots
local GuiSkillSlots = GuiFacade.GuiSkillSlots

local GuiSlotsWindowController = {}

function GuiSlotsWindowController:Initialize()
	self.GuiQuickSlotsController = require(script:WaitForChild("GuiQuickSlotsController"))
	self.GuiSkillSlotsController = require(script:WaitForChild("GuiSkillSlotsController"))
end

GuiSlotsWindowController:Initialize()
return GuiSlotsWindowController
