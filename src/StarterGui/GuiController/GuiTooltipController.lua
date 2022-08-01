local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ClientModuleFacade = require(StarterPlayerScripts:WaitForChild("ClientModuleFacade"))

local Debug = ClientModuleFacade.Debug
local ToolUtility = ClientModuleFacade.ToolUtility
local CommonEnum = ClientModuleFacade.CommonEnum
local ToolTypeConverter = CommonEnum.ToolType.Converter
local ClientGlobalStorage = ClientModuleFacade.ClientGlobalStorage

local LocalPlayer = game.Players.LocalPlayer

local GuiTooltipController = {}


function GuiTooltipController:SetToolImage(image)
	if image then
		self.GuiToolImage.Image = image
		self.GuiToolImage.ImageTransparency = 0
	else
		self.GuiToolImage.Image = ToolUtility.EmptyToolImage
		self.GuiToolImage.ImageTransparency = 0.9
	end
end

function GuiTooltipController:SetToolType(toolType)
	if toolType then
		self.GuiToolType.Text = ToolTypeConverter[toolType]
	else
		self.GuiToolType.Text = ""
	end
end

function GuiTooltipController:SetToolDescription(toolDescription)
	if toolDescription then
		self.GuiToolDescriptionText.Text = toolDescription
	else
		self.GuiToolDescriptionText.Text = "Unknown"
	end
end

function GuiTooltipController:SetToolStatus(toolGameData)
	if not toolGameData then
		self.GuiToolStatusText.Text = "Unknown"
		return
	end

	local statusText = ""
	if toolGameData.STR then
		statusText = statusText .. "STR " .. tostring(toolGameData.STR) .. "\n"
	end

	if toolGameData.DEF then
		statusText = statusText .. "DEF " .. tostring(toolGameData.DEF) .. "\n"
	end
	
	if toolGameData.Move then
		statusText = statusText .. "Move " .. tostring(toolGameData.Move) .. "\n"
	end
	
	if toolGameData.AttackSpeed then
		statusText = statusText .. "AttackSpeed " .. tostring(toolGameData.AttackSpeed) .. "\n"
	end
	
	if toolGameData.HP then
		statusText = statusText .. "HP " .. tostring(toolGameData.HP) .. "\n"
	end
	
	if toolGameData.MP then
		statusText = statusText .. "MP " .. tostring(toolGameData.MP) .. "\n"
	end
	
	if toolGameData.HIT then
		statusText = statusText .. "HIT " .. tostring(toolGameData.HIT) .. "\n"
	end
	
	if toolGameData.Dodge then
		statusText = statusText .. "Dodge " .. tostring(toolGameData.Dodge) .. "\n"
	end
	
	if toolGameData.Block then
		statusText = statusText .. "Block " .. tostring(toolGameData.Block) .. "\n"
	end
	
	if toolGameData.Critical then
		statusText = statusText .. "Critical " .. tostring(toolGameData.Critical) .. "\n"
	end
	
	if toolGameData.Sight then
		statusText = statusText .. "Sight " .. tostring(toolGameData.Sight) .. "\n"
	end

	self.GuiToolStatusText.Text = statusText
end

function GuiTooltipController:ClearToolData()
	self.GuiToolName.Text = ""
	self:SetToolImage(nil)
	self:SetToolType(nil)
	self:SetToolDescription(nil)
	self:SetToolStatus(nil)

	--[[
	self.GuiSelectButton = GuiSelectButton
	self.GuiUseButton = GuiUseButton
	self.GuiRemoveButton = GuiRemoveButton
	--]]

	self.Tool = nil
	self.InventorySlotIndex = -1
	self.GuiTooltip.Enabled = false
end

function GuiTooltipController:Initialize()
	local player = game.Players.LocalPlayer
	local PlayerGui = player:WaitForChild("PlayerGui")
	local GuiTooltip = PlayerGui:WaitForChild("GuiTooltip")
	local GuiTooltipWindow = GuiTooltip:WaitForChild("GuiTooltipWindow")
	
	self.GuiTooltip = GuiTooltip
	self.Tool = nil

	-- BaseData
	local GuiTooltipBaseData = GuiTooltipWindow:WaitForChild("GuiTooltipBaseData")
	local GuiToolName = GuiTooltipBaseData:WaitForChild("GuiToolName")
	local GuiToolImage = GuiTooltipBaseData:WaitForChild("GuiToolImage")
	local GuiToolType = GuiTooltipBaseData:WaitForChild("GuiToolType")

	self.GuiToolName = GuiToolName
	self.GuiToolImage = GuiToolImage
	self.GuiToolType = GuiToolType

	local GuiExitButton = GuiTooltipBaseData:WaitForChild("GuiExitButton")
	GuiExitButton.Activated:connect(function(inputObject)
		self:ClearToolData()
	end)

	-- DetailData
	local GuiTooltipDetailData = GuiTooltipWindow:WaitForChild("GuiTooltipDetailData")
	
	local GuiToolDescription = GuiTooltipDetailData:WaitForChild("GuiToolDescription")
	local GuiToolDescriptionText = GuiToolDescription:WaitForChild("GuiToolDescriptionText")
	
	local GuiToolStatus = GuiTooltipDetailData:WaitForChild("GuiToolStatus")
	local GuiToolStatusText = GuiToolStatus:WaitForChild("GuiToolStatusText")
	
	self.GuiToolDescriptionText = GuiToolDescriptionText
	self.GuiToolStatusText = GuiToolStatusText

	-- ButtonData
	local GuiTooltipButtons = GuiTooltipWindow:WaitForChild("GuiTooltipButtons")
	local GuiSelectButton = GuiTooltipButtons:WaitForChild("GuiSelectButton")
	local GuiUseButton = GuiTooltipButtons:WaitForChild("GuiUseButton")
	local GuiRemoveButton = GuiTooltipButtons:WaitForChild("GuiRemoveButton")

	self.GuiSelectButton = GuiSelectButton
	self.GuiUseButton = GuiUseButton
	self.GuiRemoveButton = GuiRemoveButton

	GuiSelectButton.Activated:connect(function(inputObject)
		if not self.ToolSlot then
			self:ClearToolData()
			return
		end

		local tool = self.ToolSlot:GetTool()
		if not tool then
			self:ClearToolData()
			return
		end

		if tool.Parent ~= LocalPlayer.Backpack then
			Debug.Assert(false, "어떤 경우인지 확인해봐야 합니다.")
			self:ClearToolData()
			return
		end
		
		if not ClientGlobalStorage:SendSelectToolCTS(self.ToolSlot:GetSlotIndex(), tool) then
			Debug.Assert(false, "비정상입니다.")
		end

		self:ClearToolData()
	end)

	self:ClearToolData()
end

function GuiTooltipController:InitializeByToolSlot(toolSlot)
	if not toolSlot then
		self:ClearToolData()
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local tool = toolSlot:GetTool()
	local toolGameData = ToolUtility:GetToolGameData(tool)
	if not toolGameData then
		self:ClearToolData()
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	self.ToolSlot = toolSlot
	self.GuiToolName.Text = tool.Name
	self:SetToolImage(toolGameData.Image)
	self:SetToolType(toolGameData.ToolType)
	self:SetToolDescription(toolGameData.Description)
	self:SetToolStatus(toolGameData)
	self.GuiTooltip.Enabled = true
	return true
end


GuiTooltipController:Initialize()
return GuiTooltipController