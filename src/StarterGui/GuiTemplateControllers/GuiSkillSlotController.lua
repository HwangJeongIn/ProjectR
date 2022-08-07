local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonMoudleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonMoudleFacade.Debug
local Utility = CommonMoudleFacade.Utility
local ToolUtility = CommonMoudleFacade.ToolUtility

local CommonEnum = CommonMoudleFacade.CommonEnum
local SlotType = CommonEnum.SlotType

local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiTemplate = PlayerGui:WaitForChild("GuiTemplate")
local GuiSlot = GuiTemplate:WaitForChild("GuiSlot")

local GuiPopupWindowControllers = PlayerGui:WaitForChild("GuiPopupWindowControllers")
local GuiTooltipController = require(GuiPopupWindowControllers:WaitForChild("GuiTooltipController"))


local GuiSlotController = Utility:DeepCopy(require(script.Parent:WaitForChild("GuiSlotController")))

local GuiSkillSlotController = GuiSlotController

function GuiSkillSlotController:new(slotType, slotIndex, newGuiSlot)

	if not slotType == SlotType.SkillSlot then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local newGuiSkillSlotController = self:newRaw(slotType, slotIndex, newGuiSlot)
	
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
	self.Skill = nil
end

function GuiSkillSlotController:ExecuteSkill(args)
	if not self.Skill(args) then
		Debug.Assert(false, "스킬 사용에 실패했습니다.")
	end
end

function GuiSkillSlotController:InitializeSkill(skillKey)
	if not skillKey then
		return false
	end

	-- ...
	return true
end

return GuiSkillSlotController
