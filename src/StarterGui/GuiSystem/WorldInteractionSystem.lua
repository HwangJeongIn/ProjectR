
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

local WorldInteractionSystem = {
    SlotControllerCandidate = nil,
    SlotController = nil,
    ShadowImage = nil
}

function GetToolFromPart(targetPart)
	if not targetPart then
		return nil
	end

	local targetTool = targetPart
	for count = 1, 2 do
		targetTool = targetTool.Parent
		if not targetTool then
			return nil
		end
	end

	if targetTool.ClassName ~= "Tool" then
		return nil
	end

	return targetTool
end

-- 더 정리할 필요있음
function OnInputChanged(input)

	if not Mouse.Target then
		return
	end

	local tool = GetToolFromPart(Mouse.Target)
	
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
	GuiObjectName.Text = tool.Name

	GuiObjectTooltip.Enabled = true
	-- targetParent.Name
	--if mouse.Target:FindFirstChild("")
end

function OnInputEnded(input)
	if input.KeyCode == Enum.KeyCode.F then
		if not Mouse.Target then
			return
		end
	
		local tool = GetToolFromPart(Mouse.Target)
		if not tool then
			GuiObjectTooltip.Adornee = nil
			GuiObjectTooltip.Enabled = false
			return
		end
		
		local distance = LocalPlayer:DistanceFromCharacter(Mouse.Target.Position)
		if distance < MaxPickupDistance then
			if not ClientGlobalStorage:SendPickupTool(tool) then
				Debug.Assert(false, "비정상입니다.")
			end
		end
	end
end

--UserInputService.InputBegan:Connect(OnInputBegan)
UserInputService.InputChanged:Connect(OnInputChanged)
UserInputService.InputEnded:Connect(OnInputEnded)


--WorldInteractionSystem:Initialize()
return WorldInteractionSystem