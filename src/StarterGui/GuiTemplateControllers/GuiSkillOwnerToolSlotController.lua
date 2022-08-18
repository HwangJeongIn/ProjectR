local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ClientModuleFacade = require(StarterPlayerScripts:WaitForChild("ClientModuleFacade"))

local Debug = ClientModuleFacade.Debug
local Utility = ClientModuleFacade.Utility
local ToolUtility = ClientModuleFacade.ToolUtility

local CommonEnum = ClientModuleFacade.CommonEnum
local SlotType = CommonEnum.SlotType

--[[
local CommonConstant = ClientModuleFacade.CommonConstant
local MaxSkillCount = CommonConstant.SkillCount

local ClientGlobalStorage = ClientModuleFacade.ClientGlobalStorage


local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiTemplate = PlayerGui:WaitForChild("GuiTemplate")
local GuiSlot = GuiTemplate:WaitForChild("GuiSlot")
local GuiPopupWindowControllers = PlayerGui:WaitForChild("GuiPopupWindowControllers")
--]]

local GuiSlotController = Utility:DeepCopy(require(script.Parent:WaitForChild("GuiSlotController")))

local GuiSkillOwnerToolSlotController = GuiSlotController

function GuiSkillOwnerToolSlotController:new(slotIndex, newGuiSlot)
	local newGuiSkillOwnerToolSlotController = self:newRaw(SlotType.SkillOwnerToolSlot, slotIndex, newGuiSlot)
	
	newGuiSkillOwnerToolSlotController:ClearSkillOwnerToolData()
	return newGuiSkillOwnerToolSlotController
end

function GuiSkillOwnerToolSlotController:ClearSkillOwnerToolData()
	self:ClearData()
	self.Tool = nil
end

function GuiSkillOwnerToolSlotController:SetSkillOwnerTool(tool)
	if not tool then
		self:ClearSkillOwnerToolData()
		return true
	end

	local toolGameData = ToolUtility:GetGameData(tool)
	if not toolGameData then
		self:ClearSkillOwnerToolData()
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	self:SetImage(toolGameData.Image)
	self:SetName(toolGameData.Name)
	self.Tool = tool
	return true
end

return GuiSkillOwnerToolSlotController
