local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ClientModuleFacade = require(StarterPlayerScripts:WaitForChild("ClientModuleFacade"))

local Debug = ClientModuleFacade.Debug
local Utility = ClientModuleFacade.Utility
local ToolUtility = ClientModuleFacade.ToolUtility
local CommonEnum = ClientModuleFacade.CommonEnum
local SlotType = CommonEnum.SlotType

local KeyBinder = ClientModuleFacade.KeyBinder

local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiTemplate = PlayerGui:WaitForChild("GuiTemplate")
local GuiSlot = GuiTemplate:WaitForChild("GuiSlot")

local GuiSystem = PlayerGui:WaitForChild("GuiSystem")
local GuiDraggingSystem = require(GuiSystem:WaitForChild("GuiDraggingSystem"))
local WorldInteractionSystem = require(GuiSystem:WaitForChild("WorldInteractionSystem"))

local GuiSlotController = {}

function GuiSlotController:InitializeImage(slotType, slotIndex)

	if slotType == SlotType.SkillSlot then
		self.DefaultImage = ToolUtility.DefaultSkillImage
		self.EmptyImage = ToolUtility.EmptySkillImage
		self.DefaultSlotImage = ToolUtility.DefaultCircularSlotImage
		
		--self.GuiToolSlot.ImageTransparency = 0.65

	else
		self.DefaultImage = ToolUtility.DefaultToolImage
		self.EmptyImage = ToolUtility.EmptyToolImage
		self.DefaultSlotImage = ToolUtility.DefaultSlotImage
	--elseif slotType == SlotType.InventorySlot then
	--elseif slotType == SlotType.EquipSlot then
		--slotIndex
	--end
	--elseif slotType == SlotType.QuickSlot then
	end

	self.GuiSlot.Image = self.DefaultSlotImage
end

function GuiSlotController:newRaw(slotType, slotIndex, newGuiSlot)
	local newGuiSlotController = Utility:ShallowCopy(self)

	if not newGuiSlot then
		newGuiSlot = GuiSlot:Clone()
	end

	local newGuiImage = newGuiSlot:WaitForChild("GuiImage")
	local newGuiName = newGuiImage:WaitForChild("GuiName")
	local newGuiNumber = newGuiImage:WaitForChild("GuiNumber")

	newGuiSlotController.GuiSlot = newGuiSlot
	newGuiSlotController.GuiImage = newGuiImage
	newGuiSlotController.GuiName = newGuiName
	newGuiSlotController.GuiNumber = newGuiNumber
	newGuiSlotController.SlotIndex = slotIndex
	newGuiSlotController.SlotType = slotType
	
	--[[
	-- Touch
	KeyBinder:BindCustomAction(Enum.UserInputType.MouseButton1, Enum.UserInputState.Begin, "1", 
	function(actionName, inputState, inputObject)
		print("Enum.UserInputType.MouseButton1, Enum.UserInputState.Begin => " .. tostring(newGuiSlotController.SlotIndex))
	end)

	KeyBinder:BindCustomAction(Enum.UserInputType.MouseButton1, Enum.UserInputState.End, "2", 
	function(actionName, inputState, inputObject)
		print("Enum.UserInputType.MouseButton1, Enum.UserInputState.End => " .. tostring(newGuiSlotController.SlotIndex))
	end)

	
	newGuiSlotController.GuiSlot.InputBegan:Connect(function(inputObject) 
		print("newGuiSlotController.GuiSlot.InputBegan => " .. tostring(newGuiSlotController.SlotIndex))
	end)
	newGuiSlotController.GuiSlot.InputChanged:Connect(function(inputObject) 
		--print(newGuiSlotController.SlotIndex)
	end)
	newGuiSlotController.GuiSlot.InputEnded:Connect(function(inputObject) 
		print("newGuiSlotController.GuiSlot.InputEnded => " .. tostring(newGuiSlotController.SlotIndex))
	end)
--]]

	newGuiSlotController.GuiSlot.MouseEnter:Connect(function(x,y)
		newGuiSlotController.GuiSlot.ImageTransparency = 0.5
		Debug.Print("SetSlotControllerCandidate => " .. tostring(newGuiSlotController.SlotIndex))
		GuiDraggingSystem:SetSlotControllerCandidate(newGuiSlotController)
	end)

	newGuiSlotController.GuiSlot.MouseLeave:Connect(function()
		newGuiSlotController.GuiSlot.ImageTransparency = 0
		--Debug.Print("SetSlotControllerCandidate => nil")
		GuiDraggingSystem:CheckAndClearSlotControllerCandidate(newGuiSlotController)
	end)
	newGuiSlotController:InitializeImage(slotType, slotIndex)
	return newGuiSlotController
end

function GuiSlotController:GetImage()
	return self.GuiImage
end

function GuiSlotController:SetImage(image, isEmpty)
	if isEmpty then
		self.GuiImage.Image = self.EmptyImage
		self.GuiImage.ImageTransparency = 0.9
	else
		if image then
			self.GuiImage.Image = image
			self.GuiImage.ImageTransparency = 0
		else
			self.GuiImage.Image = self.DefaultImage
			self.GuiImage.ImageTransparency = 0
		end
	end
end

function GuiSlotController:SetName(name)
	self.GuiName.Text = name
end

function GuiSlotController:SetNumber(number)
	self.GuiNumber.Text = number
end

function GuiSlotController:ClearData()
	self:SetImage(nil, true)
	self:SetName("")
	self:SetNumber("")
end

function GuiSlotController:GetSlotIndex()
	return self.SlotIndex
end

return GuiSlotController
