local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ClientModuleFacade = require(StarterPlayerScripts:WaitForChild("ClientModuleFacade"))
local CommonConstant = ClientModuleFacade.CommonConstant
local MaxQuickSlotCount = CommonConstant.MaxQuickSlotCount

local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiHUD = PlayerGui:WaitForChild("GuiHUD")

local GuiPlayerMain = GuiHUD:WaitForChild("GuiPlayerMain")
local GuiMinimap = GuiHUD:WaitForChild("GuiMinimap")

local GuiBarsWindow = GuiPlayerMain:WaitForChild("GuiBarsWindow")
local GuiSlotsWindow = GuiPlayerMain:WaitForChild("GuiSlotsWindow")

local GuiHpBar = GuiBarsWindow:WaitForChild("GuiHpBar")

local GuiQuickSlots = GuiSlotsWindow:WaitForChild("GuiQuickSlots")
local GuiSkillSlots = GuiSlotsWindow:WaitForChild("GuiSkillSlots")

local GuiHUDController = {}

function GuiHUDController:Initialize()
	self.GuiMinimapController = require(script:WaitForChild("GuiMinimapController"))
	self.GuiPlayerMainController = require(script:WaitForChild("GuiPlayerMainController"))
end

GuiHUDController:Initialize()
return GuiHUDController
