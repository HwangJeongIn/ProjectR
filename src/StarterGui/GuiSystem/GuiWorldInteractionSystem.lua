
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
local ClientModuleFacade = require(StarterPlayerScripts:WaitForChild("ClientModuleFacade"))

local ClientGlobalStorage = ClientModuleFacade.ClientGlobalStorage
local Debug = ClientModuleFacade.Debug
local ToolUtility = ClientModuleFacade.ToolUtility
local KeyBinder = ClientModuleFacade.KeyBinder

local CommonConstant = ClientModuleFacade.CommonConstant

local MaxDistanceToIdentifyObject = CommonConstant.MaxDistanceToIdentifyObject
local MaxPickupDistance = CommonConstant.MaxPickupDistance

local CommonEnum = ClientModuleFacade.CommonEnum
local SlotType = CommonEnum.SlotType
local SlotTypeConverter = SlotType.Converter

local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local GuiObjectTooltip = PlayerGui:WaitForChild("GuiObjectTooltip")
local GuiObjectTooltipWindow = GuiObjectTooltip:WaitForChild("GuiObjectTooltipWindow")
local GuiObjectName = GuiObjectTooltipWindow:WaitForChild("GuiObjectName")


local Mouse = LocalPlayer:GetMouse()

local GuiWorldInteractionSystem = {}

function GuiWorldInteractionSystem:GetToolFromTrigger(targetPart)
	if not targetPart then
		return nil
	end

	local targetTool = targetPart.Parent
	--[[
	for count = 1, 2 do
		targetTool = targetTool.Parent
		if not targetTool then
			return nil
		end
	end
	--]]

	if targetTool.ClassName ~= "Tool" then
		return nil
	end

	return targetTool
end

function OnInputChanged(input)
	if not Mouse.Target then
		return
	end

	local tool = GuiWorldInteractionSystem:GetToolFromTrigger(Mouse.Target)
	if not tool then
		GuiObjectTooltip.Adornee = nil
		GuiObjectTooltip.Enabled = false
		return
	end

	local distance = LocalPlayer:DistanceFromCharacter(Mouse.Target.Position)
	if distance > MaxDistanceToIdentifyObject then
		GuiObjectTooltip.Adornee = nil
		GuiObjectTooltip.Enabled = false
		return
	end

	GuiObjectTooltip.Adornee = Mouse.Target
	local toolGameData = ToolUtility:GetGameDataByModelName(tool.Name)
	GuiObjectName.Text = toolGameData.Name 

	GuiObjectTooltip.Enabled = true
	-- targetParent.Name
	--if mouse.Target:FindFirstChild("")
end

function OnInputBegan(input)
	if not Mouse.Target then
		return
	end

	local tool = GuiWorldInteractionSystem:GetToolFromTrigger(Mouse.Target)
	if not tool then
		GuiObjectTooltip.Adornee = nil
		GuiObjectTooltip.Enabled = false
		return
	end
	
	local distance = LocalPlayer:DistanceFromCharacter(Mouse.Target.Position)
	if distance < MaxPickupDistance then
		if not ClientGlobalStorage:SendPickupTool(tool) then
			Debug.Assert(false, "??????????????????.")
		end
	end
end

--UserInputService.InputBegan:Connect(OnInputBegan)

KeyBinder:BindAction(Enum.UserInputState.Change, nil, "GuiWorldInteractionSystem", OnInputChanged)
KeyBinder:BindAction(Enum.UserInputState.Begin, Enum.KeyCode.F, "GuiWorldInteractionSystem", OnInputBegan)
--UserInputService.InputChanged:Connect(OnInputChanged)
--UserInputService.InputEnded:Connect(OnInputEnded)


--GuiWorldInteractionSystem:Initialize()
return GuiWorldInteractionSystem