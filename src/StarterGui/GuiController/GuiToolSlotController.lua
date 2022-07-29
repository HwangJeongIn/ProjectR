local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonMoudleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonMoudleFacade.Debug
local Utility = CommonMoudleFacade.Utility
local ToolUtility = CommonMoudleFacade.ToolUtility

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local GuiPlayerStatus = PlayerGui:WaitForChild("GuiPlayerStatus")
local GuiPlayerStatusWindow = GuiPlayerStatus:WaitForChild("GuiPlayerStatusWindow")
local GuiToolSlot = GuiPlayerStatusWindow:WaitForChild("GuiToolSlot")

local GuiToolSlotController = {}

function GuiToolSlotController:new(slotIndex, newGuiToolSlot)
	local newGuiToolSlotController = Utility:DeepCopy(self)

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
	newGuiToolSlotController.Tool = nil
	newGuiToolSlotController.SlotIndex = slotIndex

	newGuiToolSlotController.GuiToolSlot.MouseEnter:connect(function(x,y)
		newGuiToolSlotController.GuiToolSlot.ImageTransparency = 0.5
	end)
	
	newGuiToolSlotController.GuiToolSlot.MouseLeave:connect(function()
		newGuiToolSlotController.GuiToolSlot.ImageTransparency = 0
	end)

	newGuiToolSlotController.GuiToolSlot.MouseButton1Down:connect(function(x,y)
		local targetTool = newGuiToolSlotController.Tool
		local targetSlotIndex = newGuiToolSlotController.SlotIndex
		if not targetTool then
			return
		end
		newGuiToolSlotController.GuiToolSlot.ImageTransparency = 0.5
	end)
	
	
	
	newGuiToolSlotController:ClearToolData()
	return newGuiToolSlotController
end

function GuiToolSlotController:ClearToolData()
	self.GuiToolImage.Image = ToolUtility.EmptyToolImage
	self.GuiToolImage.ImageTransparency = 0.9
	
	self.GuiToolName.Text = ""
	self.GuiToolCount.Text = ""
end

function GuiToolSlotController:SetTool(tool)
	if not tool then
		self:ClearToolData()
		return true
	end

	local toolGameData = ToolUtility:GetToolGameData(tool)
	if not toolGameData then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if toolGameData.ToolImage then
		self.GuiToolImage = toolGameData.ToolImage
	end

	self.GuiToolName.Text = tool.Name
	-- 여러개 소유할 수 있다면 변경될 수 있다.
	self.GuiToolCount.Text = "1"
	self.Tool = tool

	return true
end

return GuiToolSlotController:new(GuiToolSlot)
