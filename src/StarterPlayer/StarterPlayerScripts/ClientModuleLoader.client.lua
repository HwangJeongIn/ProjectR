--[[
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ClientModule = StarterPlayerScripts:WaitForChild("ClientModule")
--]]

local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
require(PlayerGui:WaitForChild("GuiController"))
