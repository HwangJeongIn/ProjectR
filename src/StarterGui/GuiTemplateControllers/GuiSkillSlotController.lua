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

local KeyBinder = ClientModuleFacade.KeyBinder

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

	newGuiSkillSlotController.GuiSlot.GuiImage.GuiNumber.Size =  UDim2.new(0.3, 0, 0.3, 0)
	newGuiSkillSlotController.GuiSlot.GuiImage.GuiNumber.Position =  UDim2.new(0, 0, 0, 0)


	local targetSlotIndexEnum = ToolUtility.SkillSlotIndexToKeyCodeTable[newGuiSkillSlotController.SlotIndex]
	if not targetSlotIndexEnum then
		Debug.Assert(false, "비정상입니다. 슬롯이 늘어났는지 확인해보세요")
		return
	end

	local skillSlotActionName = tostring(targetSlotIndexEnum)
	newGuiSkillSlotController.SkillKeyName = string.sub(skillSlotActionName, -1)

	KeyBinder:BindAction(Enum.UserInputState.Begin, targetSlotIndexEnum, skillSlotActionName, function(inputObject)
		if not self:ActivateSkill() then
			Debug.Assert(false, "비정상입니다.")
			return
		end
	end)

	newGuiSkillSlotController.GuiSlot.Activated:Connect(function(inputObject)
		if not self:ActivateSkill() then
			Debug.Assert(false, "비정상입니다.")
			return
		end
	end)

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
	self:SetNumber(self.SkillKeyName)

	self.SkillOwnerTool = skillOwnerTool
	self.SkillGameData = skillGameData

	self:SetVisible(true)
	return true
end

return GuiSkillSlotController