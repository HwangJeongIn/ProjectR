local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiFacade = require(PlayerGui:WaitForChild("GuiFacade"))

local GuiSkillSlots = GuiFacade.GuiSkillSlots

local GuiSkillSlotsController = {}

function GuiSkillSlotsController:Initialize()
end

GuiSkillSlotsController:Initialize()
return GuiSkillSlotsController
