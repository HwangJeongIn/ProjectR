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
local GuiToolSlot = GuiTemplate:WaitForChild("GuiToolSlot")

local GuiPopupWindowControllers = PlayerGui:WaitForChild("GuiPopupWindowControllers")
local GuiTooltipController = require(GuiPopupWindowControllers:WaitForChild("GuiTooltipController"))


local GuiToolSlotController = {}

function GuiToolSlotController:InitializeImage(slotType, slotIndex)

	if slotType == SlotType.SkillSlot then
		self.DefaultEmptyToolImage = ToolUtility.EmptyToolImage
		self.DefaultSlotImage = ToolUtility.DefaultCircularSlotImage
	else
		self.DefaultEmptyToolImage = ToolUtility.EmptyToolImage
		self.DefaultSlotImage = ToolUtility.DefaultSlotImage
	--elseif slotType == SlotType.InventorySlot then
	--elseif slotType == SlotType.EquipSlot then
		--slotIndex
	--end
	--elseif slotType == SlotType.QuickSlot then
	end

	self.GuiToolSlot.Image = self.DefaultSlotImage
end

function GuiToolSlotController:new(slotType, slotIndex, newGuiToolSlot)
	local newGuiToolSlotController = Utility:ShallowCopy(self)

	if not newGuiToolSlot then
		newGuiToolSlot = GuiToolSlot:Clone()
	end

	local newGuiToolImage = newGuiToolSlot:WaitForChild("GuiToolImage")
	local newGuiToolName = newGuiToolImage:WaitForChild("GuiToolName")
	local newGuiToolCount = newGuiToolImage:WaitForChild("GuiToolCount")

	newGuiToolSlotController.GuiToolSlot = newGuiToolSlot
	newGuiToolSlotController.GuiToolImage = newGuiToolImage
	newGuiToolSlotController.GuiToolName = newGuiToolName
	newGuiToolSlotController.GuiToolCount = newGuiToolCount
	newGuiToolSlotController.SlotIndex = slotIndex
	newGuiToolSlotController.SlotType = slotType
	
	newGuiToolSlotController.Tool = nil

	newGuiToolSlotController.GuiToolSlot.MouseEnter:connect(function(x,y)
		newGuiToolSlotController.GuiToolSlot.ImageTransparency = 0.5
	end)
	
	newGuiToolSlotController.GuiToolSlot.MouseLeave:connect(function()
		newGuiToolSlotController.GuiToolSlot.ImageTransparency = 0
	end)

	--[[
	newGuiToolSlotController.GuiToolSlot.MouseButton1Down:connect(function(x,y)

		print("GuiToolSlot.MouseButton1Down")
		local targetTool = newGuiToolSlotController.Tool
		local targetSlotIndex = newGuiToolSlotController.SlotIndex
		if not targetTool then
			return
		end

	end)
	--]]

	if newGuiToolSlotController.SlotType == SlotType.InventorySlot then
		newGuiToolSlotController.GuiToolSlot.Activated:connect(function(inputObject)
			local targetTool = newGuiToolSlotController.Tool
			if not targetTool then
				return
			end
			GuiTooltipController:InitializeByToolSlot(newGuiToolSlotController)
		end)
	elseif newGuiToolSlotController.SlotType == SlotType.EquipSlot then
		newGuiToolSlotController.GuiToolSlot.Activated:connect(function(inputObject)
			local targetTool = newGuiToolSlotController.Tool
			if not targetTool then
				return
			end
			GuiTooltipController:InitializeByToolSlot(newGuiToolSlotController)
		end)

	elseif newGuiToolSlotController.SlotType == SlotType.QuickSlot then

	end

	newGuiToolSlotController:InitializeImage(slotType, slotIndex)
	newGuiToolSlotController:ClearToolData()
	return newGuiToolSlotController
end

function GuiToolSlotController:SetToolImage(image)
	if image then
		self.GuiToolImage.Image = image
		self.GuiToolImage.ImageTransparency = 0
	else
		self.GuiToolImage.Image = ToolUtility.EmptyToolImage
		self.GuiToolImage.ImageTransparency = 0.9
	end
end

function GuiToolSlotController:ClearToolData()
	self:SetToolImage(nil)
	self.GuiToolName.Text = ""
	self.GuiToolCount.Text = ""

	self.Tool = nil
end

function GuiToolSlotController:GetSlotIndex()
	return self.SlotIndex
end

function GuiToolSlotController:GetTool()
	return self.Tool
end

function GuiToolSlotController:SetTool(tool)
	if not tool then
		self:ClearToolData()
		return true
	end

	local toolGameData = ToolUtility:GetToolGameData(tool)
	if not toolGameData then
		self:ClearToolData()
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	self:SetToolImage(toolGameData.Image)
	self.GuiToolName.Text = tool.Name
	self.Tool = tool

	-- 여러개 소유할 수 있다면 변경될 수 있다.
	if not self.SlotType == SlotType.EquipSlot then
		self.GuiToolCount.Text = "1"
	end

	return true
end

return GuiToolSlotController:new(SlotType.EquipSlot, -1, GuiToolSlot)
