local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ClientModuleFacade = require(StarterPlayerScripts:WaitForChild("ClientModuleFacade"))
local CommonConstant = ClientModuleFacade.CommonConstant
local MaxQuickSlotCount = CommonConstant.MaxQuickSlotCount

local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiFacade = require(PlayerGui:WaitForChild("GuiFacade"))

local GuiHUD = GuiFacade.GuiHUD
local GuiPlayerMain = GuiFacade.GuiPlayerMain
local GuiMinimap = GuiFacade.GuiPlayerMain

local GuiHUDController = {}

function GuiHUDController:Initialize()
	self.GuiMinimapController = require(script:WaitForChild("GuiMinimapController"))
	self.GuiPlayerMainController = require(script:WaitForChild("GuiPlayerMainController"))
end

GuiHUDController:Initialize()
return GuiHUDController
