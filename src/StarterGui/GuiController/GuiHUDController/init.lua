local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ClientModuleFacade = require(StarterPlayerScripts:WaitForChild("ClientModuleFacade"))
local CommonConstant = ClientModuleFacade.CommonConstant
local MaxQuickSlotCount = CommonConstant.MaxQuickSlotCount

local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiFacade = require(PlayerGui:WaitForChild("GuiFacade"))

local GuiHUD = GuiFacade.GuiHUD

local GuiHUDController = {}

function GuiHUDController:Initialize()
	self.GuiMinimapController = require(script:WaitForChild("GuiMinimapController"))
	self.GuiQuickSlotsController = require(script:WaitForChild("GuiQuickSlotsController"))
	self.GuiSkillSlotsController = require(script:WaitForChild("GuiSkillSlotsController"))
	self.GuiBarsWindowController = require(script:WaitForChild("GuiSkillSlotsController"))
	self.GuiHpBarController = self.GuiBarsWindowController.GuiHpBarController
end

GuiHUDController:Initialize()
return GuiHUDController
