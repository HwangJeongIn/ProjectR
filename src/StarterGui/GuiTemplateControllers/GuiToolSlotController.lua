local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ClientModuleFacade = require(StarterPlayerScripts:WaitForChild("ClientModuleFacade"))

local ClientGlobalStorage = ClientModuleFacade.ClientGlobalStorage
local Debug = ClientModuleFacade.Debug
local Utility = ClientModuleFacade.Utility
local ToolUtility = ClientModuleFacade.ToolUtility

local CommonEnum = ClientModuleFacade.CommonEnum
local SlotType = CommonEnum.SlotType

local Player = game.Players.LocalPlayer
local PlayerId = Player.UserId
local PlayerGui = Player:WaitForChild("PlayerGui")
local GuiTemplate = PlayerGui:WaitForChild("GuiTemplate")
local GuiSlot = GuiTemplate:WaitForChild("GuiSlot")

local GuiPopupWindowControllers = PlayerGui:WaitForChild("GuiPopupWindowControllers")
local GuiTooltipController = require(GuiPopupWindowControllers:WaitForChild("GuiTooltipController"))


local GuiSlotController = Utility:DeepCopy(require(script.Parent:WaitForChild("GuiSlotController")))

local GuiToolSlotController = GuiSlotController

function GuiToolSlotController:new(slotType, slotIndex, newGuiSlot)

	if not slotType == SlotType.InventorySlot 
	and not slotType == SlotType.EquipSlot 
	and not slotType == slotType.QuickSlot then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local newGuiToolSlotController = self:newRaw(slotType, slotIndex, newGuiSlot)


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
		newGuiToolSlotController.GuiSlot.Activated:connect(function(inputObject)
			local targetTool = newGuiToolSlotController.Tool
			if not targetTool then
				return
			end
			GuiTooltipController:InitializeByToolSlot(newGuiToolSlotController)
		end)
	elseif newGuiToolSlotController.SlotType == SlotType.EquipSlot then
		newGuiToolSlotController.GuiSlot.Activated:connect(function(inputObject)
			local targetTool = newGuiToolSlotController.Tool
			if not targetTool then
				return
			end
			GuiTooltipController:InitializeByToolSlot(newGuiToolSlotController)
		end)

	elseif newGuiToolSlotController.SlotType == SlotType.QuickSlot then
		newGuiToolSlotController.GuiSlot.Activated:connect(function(inputObject)
			local targetTool = newGuiToolSlotController.Tool
			if not targetTool then
				return
			end
			if not ClientGlobalStorage:IsInBackpack(PlayerId, targetTool) then
				Debug.Assert(false, "플레이어가 소유한 도구가 아닙니다.")
				return
			end

			ClientGlobalStorage:Send
			GuiTooltipController:InitializeByToolSlot(newGuiToolSlotController)
		end)
	end

	newGuiToolSlotController:ClearToolData()
	return newGuiToolSlotController
end

function GuiToolSlotController:ClearToolData()
	self:ClearData()
	self.Tool = nil
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

	self:SetImage(toolGameData.Image)
	self:SetName(tool.Name)
	self.Tool = tool

	-- 여러개 소유할 수 있다면 변경될 수 있다.
	if self.SlotType ~= SlotType.EquipSlot then
		self:SetNumber("1")
	end

	return true
end

return GuiToolSlotController
