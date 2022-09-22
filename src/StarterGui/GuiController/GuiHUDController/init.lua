local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ClientModuleFacade = require(StarterPlayerScripts:WaitForChild("ClientModuleFacade"))
local Debug = ClientModuleFacade.Debug

local CommonEnum = ClientModuleFacade.CommonEnum
local EquipType = CommonEnum.EquipType


--[[
local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiFacade = require(PlayerGui:WaitForChild("GuiFacade"))

local GuiHUD = GuiFacade.GuiHUD
--]]

local GuiHUDController = {}

function GuiHUDController:Initialize()
	self.GuiMinimapController = require(script:WaitForChild("GuiMinimapController"))
	self.GuiQuickSlotsController = require(script:WaitForChild("GuiQuickSlotsController"))
	self.GuiSkillSlotsController = require(script:WaitForChild("GuiSkillSlotsController"))
	self.GuiBarsWindowController = require(script:WaitForChild("GuiBarsWindowController"))
	self.GuiHpBarController = self.GuiBarsWindowController.GuiHpBarController
end

function GuiHUDController:SetQuickToolSlot(slotIndex, tool)
	if not self.GuiQuickSlotsController:SetToolSlot(slotIndex, tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function GuiHUDController:RefreshSkillByLastActivationTime(skillGameDataKey, lastActivationTime)
	if not self.GuiSkillSlotsController:RefreshSkillByLastActivationTime(skillGameDataKey, lastActivationTime) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function GuiHUDController:SetSkillOwnerToolSlot(equipType, tool)
	if EquipType.Weapon == equipType then
		if not self.GuiSkillSlotsController:SetSkillOwnerToolSlot(tool) then
			Debug.Assert(false, "비정상입니다.")
			return false
		end
	end

	return true
end


GuiHUDController:Initialize()
return GuiHUDController
