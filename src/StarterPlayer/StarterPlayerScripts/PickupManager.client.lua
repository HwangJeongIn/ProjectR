local UIS = game:GetService("UserInputService")
local pickupKey = "F"

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local PlayerGui = player:WaitForChild("PlayerGui")
local GuiObjectTooltip = PlayerGui:WaitForChild("GuiObjectTooltip")
--local SlotTooltip = PlayerGui:WaitForChild("SlotTooltip")


-- 인벤토리 초기화


UIS.InputChanged:Connect(function(input)
	
	if mouse.Target then
		local target = mouse.Target.Parent
		if target.ClassName == "Tool" then

			GuiObjectTooltip.Adornee = mouse.Target
			GuiObjectTooltip.GuiObjectName.Text = target.Name

			GuiObjectTooltip.Enabled = true
			-- targetParent.Name
		else
			GuiObjectTooltip.Adornee = nil
			GuiObjectTooltip.Enabled = false
		end
		--if mouse.Target:FindFirstChild("")
	end
		
end)

UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode[pickupKey] then
		if mouse.Target then
			local target = mouse.Target.Parent
			if target.ClassName == "Tool" then
				local distanceFromItem = player:DistanceFromCharacter(mouse.Target.Position)
	
				if distanceFromItem < 30 then
					print("pick up!")
				end
			end
		end
	end
end)