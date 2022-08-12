local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ClientModuleFacade = require(StarterPlayerScripts:WaitForChild("ClientModuleFacade"))

local Debug = ClientModuleFacade.Debug
local ToolUtility = ClientModuleFacade.ToolUtility
local CommonEnum = ClientModuleFacade.CommonEnum

local SlotType = CommonEnum.SlotType
local ToolTypeConverter = CommonEnum.ToolType.Converter

local EquipType = CommonEnum.EquipType
local EquipTypeConverter = CommonEnum.EquipType.Converter
local ClientGlobalStorage = ClientModuleFacade.ClientGlobalStorage

local LocalPlayer = game.Players.LocalPlayer

local GuiTooltipController = {}


function GuiTooltipController:SetToolImage(image)
	if image then
		self.GuiToolImage.Image = image
		self.GuiToolImage.ImageTransparency = 0
	else
		self.GuiToolImage.Image = ToolUtility.DefaultToolImage
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
	--self.SlotIndex = -1
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
	GuiExitButton.Activated:Connect(function(inputObject)
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
	local GuiButton1 = GuiTooltipButtons:WaitForChild("GuiButton1")
	local GuiButton2 = GuiTooltipButtons:WaitForChild("GuiButton2")
	local GuiButton3 = GuiTooltipButtons:WaitForChild("GuiButton3")
	local GuiButton4 = GuiTooltipButtons:WaitForChild("GuiButton4")


	self.GuiButtons = {
		[1] = {Button = GuiButton1, ButtonText = GuiButton1:FindFirstChild("GuiText"), ButtonAction = nil},
		[2] = {Button = GuiButton2, ButtonText = GuiButton2:FindFirstChild("GuiText"), ButtonAction = nil},
		[3] = {Button = GuiButton3, ButtonText = GuiButton3:FindFirstChild("GuiText"), ButtonAction = nil},
		[4] = {Button = GuiButton4, ButtonText = GuiButton4:FindFirstChild("GuiText"), ButtonAction = nil}
	}

	for _, buttonWrapper in pairs(self.GuiButtons) do
		local button = buttonWrapper.Button

		button.MouseEnter:connect(function(x,y)
			button.Transparency = 0.5
		end)
		
		button.MouseLeave:connect(function()
			button.Transparency = 0
		end)
	end


	self:ClearToolData()
end

function GuiTooltipController:CheckToolSlot()
	if not self.ToolSlot then
		return false
	end

	local tool = self.ToolSlot:GetTool()
	if not tool then
		return false
	end

	return true
end

function SelectToolAction(tooltip, inputObject)
	if not tooltip:CheckToolSlot() then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local tool = tooltip.ToolSlot:GetTool()
	if tool.Parent ~= LocalPlayer.Backpack then
		Debug.Assert(false, "어떤 경우인지 확인해봐야 합니다.")
		return false
	end
	
	if not ClientGlobalStorage:SendSelectToolCTS(--[[tooltip.ToolSlot:GetSlotIndex(),--]] tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function EquipToolAction(tooltip, inputObject)
	if not tooltip:CheckToolSlot() then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local tool = tooltip.ToolSlot:GetTool()
	local equipType = ToolUtility:GetEquipType(tool)
	if not equipType or not EquipTypeConverter[equipType] then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	if tool.Parent ~= LocalPlayer.Backpack then
		Debug.Assert(false, "어떤 경우인지 확인해봐야 합니다.")
		return false
	end
	
	if not ClientGlobalStorage:SendEquipToolCTS(equipType, tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function UnequipToolAction(tooltip, inputObject)
	if not tooltip:CheckToolSlot() then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local tool = tooltip.ToolSlot:GetTool()
	local equipType = ToolUtility:GetEquipType(tool)
	if not equipType or not EquipTypeConverter[equipType] then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	local character = LocalPlayer.Character
	if not character then
		Debug.Assert(false, "캐릭터가 존재하지 않습니다.")
		return false
	end

	if equipType == EquipType.Weapon then
		if tool.Parent ~= character then
			Debug.Assert(false, "해당 무기가 캐릭터 하위에 존재하지 않습니다.")
			return false
		end
	else
		local characterArmorsFolder = character:FindFirstChild("Armors")
		if tool.Parent ~= characterArmorsFolder then
			Debug.Assert(false, "해당 방어구가 캐릭터 방어구 하위에 존재하지 않습니다.")
			return false
		end
	end

	if not ClientGlobalStorage:SendUnequipToolCTS(equipType) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function GuiTooltipController:ClearButtons()
	for _, buttonWrapper in pairs(self.GuiButtons) do
		if buttonWrapper.ButtonAction then
			buttonWrapper.ButtonAction:Disconnect()
			buttonWrapper.ButtonAction = nil
		end

		buttonWrapper.ButtonText.Text = ""
		buttonWrapper.Button.Visible = false
	end
end

function GuiTooltipController:SetButton(buttonIndex, buttonText, buttonAction)
	if not buttonIndex or not buttonText or not buttonAction then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local targetButtonWrapper = self.GuiButtons[buttonIndex]
	if not targetButtonWrapper then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local buttonActionTypeString = type(buttonAction)
	if buttonActionTypeString ~= "function" then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local targetButton = targetButtonWrapper.Button
	local targetButtonText = targetButtonWrapper.ButtonText

	targetButtonWrapper.ButtonAction = targetButton.Activated:Connect(function(inputObject)
		if not buttonAction(self, inputObject) then
			Debug.Assert(false, "버튼 동작이 실패했습니다.")
		end
		self:ClearToolData()
	end)

	targetButtonText.Text = buttonText
	targetButton.Visible = true
	return true
end

function GuiTooltipController:InitializeButton(slotType, toolGameData)
	self:ClearButtons()

	local equipType = toolGameData.EquipType
	if slotType == SlotType.InventorySlot then
		if equipType then
			if equipType == EquipType.Weapon then
				if not self:SetButton(4, "Equip", EquipToolAction) then
					Debug.Assert(false, "비정상입니다.")
					return false
				end
			else
				if not self:SetButton(4, "Select", SelectToolAction) then
					Debug.Assert(false, "비정상입니다.")
					return false
				end

				if not self:SetButton(3, "Equip", EquipToolAction) then
					Debug.Assert(false, "비정상입니다.")
					return false
				end
			end
		else
			if not self:SetButton(4, "Select", SelectToolAction) then
				Debug.Assert(false, "비정상입니다.")
				return false
			end
		end
	elseif slotType == SlotType.EquipSlot then
		if not equipType then
			Debug.Assert(equipType, "비정상입니다. 게임데이터를 확인해야합니다.")
			return false
		end

		if not self:SetButton(4, "Unequip", UnequipToolAction) then
			Debug.Assert(false, "비정상입니다.")
			return false
		end

	elseif slotType == SlotType.QuickSlot then

	end

	return true
end

function GuiTooltipController:InitializeByToolSlot(toolSlot)
	if not toolSlot then
		self:ClearToolData()
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local tool = toolSlot:GetTool()
	local toolGameData = ToolUtility:GetGameData(tool)
	if not toolGameData then
		self:ClearToolData()
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not self:InitializeButton(toolSlot.SlotType, toolGameData) then
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