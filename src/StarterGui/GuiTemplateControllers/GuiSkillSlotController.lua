local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ClientModuleFacade = require(StarterPlayerScripts:WaitForChild("ClientModuleFacade"))

local ClientGlobalStorage = ClientModuleFacade.ClientGlobalStorage
local Debug = ClientModuleFacade.Debug
local Utility = ClientModuleFacade.Utility
local ToolUtility = ClientModuleFacade.ToolUtility

local CommonConstant = ClientModuleFacade.CommonConstant
local MaxSkillCount = CommonConstant.SkillCount

local CommonEnum = ClientModuleFacade.CommonEnum
local SlotType = CommonEnum.SlotType

local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiTemplate = PlayerGui:WaitForChild("GuiTemplate")
local GuiSlot = GuiTemplate:WaitForChild("GuiSlot")

local GuiPopupWindowControllers = PlayerGui:WaitForChild("GuiPopupWindowControllers")
local GuiTooltipController = require(GuiPopupWindowControllers:WaitForChild("GuiTooltipController"))


local GuiSlotController = Utility:DeepCopy(require(script.Parent:WaitForChild("GuiSlotController")))

local GuiSkillSlotController = GuiSlotController

function GuiSkillSlotController:new(slotIndex, newGuiSlot)
	local newGuiSkillSlotController = self:newRaw(SlotType.SkillSlot, slotIndex, newGuiSlot)
	
	newGuiSkillSlotController.GuiSlot.MouseEnter:connect(function(x,y)
		newGuiSkillSlotController.GuiSlot.ImageTransparency = 0.5
	end)
	
	newGuiSkillSlotController.GuiSlot.MouseLeave:connect(function()
		newGuiSkillSlotController.GuiSlot.ImageTransparency = 0
	end)

	if newGuiSkillSlotController.SlotType == SlotType.SkillSlot then
		--[[
		newGuiSkillSlotController.GuiSlot.Activated:connect(function(inputObject)
			local targetTool = newGuiSkillSlotController.Tool
			if not targetTool then
				return
			end
			GuiTooltipController:InitializeByToolSlot(newGuiSkillSlotController)
		end)
		--]]
	end

	newGuiSkillSlotController:ClearSkillData()
	return newGuiSkillSlotController
end

function GuiSkillSlotController:ClearSkillData()
	self:ClearData()
	self.SkillOwnerTool = nil
	self.SkillGameData = nil

	self:SetVisible(false)
end

function GuiSkillSlotController:ActivateSkill()
	local skillIndex = self:GetSlotIndex()
	if not skillIndex then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not self.SkillOwnerTool then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not ClientGlobalStorage:SendActivateToolSkill(skillIndex, self.SkillOwnerTool) then
		Debug.Assert(false, "스킬 사용에 실패했습니다.")
		return false
	end

	return true
end

function GuiSkillSlotController:SetSkill(skillOwnerTool, skillGameData)
	if not skillOwnerTool then
		self:ClearSkillData()
		return true
	end
	
	if not skillGameData then
		Debug.Assert(false, "스킬 정보 초기화에 실패했습니다.")
		self:ClearSkillData()
		return false
	end

	if not skillGameData then
		Debug.Assert(false, "스킬 정보 초기화에 실패했습니다.")
		self:ClearSkillData()
		return false
	end

	self:SetImage(skillGameData.Image)
	self:SetName(skillGameData.Name)

	self.SkillOwnerTool = skillOwnerTool
	self.SkillGameData = skillGameData

	self:SetVisible(true)
	return true
end

return GuiSkillSlotController