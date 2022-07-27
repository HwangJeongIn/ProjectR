
local toolHandle = script.Parent

--local character = script.Parent.Parent


while #game.Players:GetPlayers() < 1 do
	wait(1)
end

for i, player in pairs(game.Players:GetPlayers()) do
	local backpack = player:FindFirstChild("Backpack")
	backpack:Destroy()
end




--toolHandle.Touched= nil
--toolHandle.TouchEnded= nil
--[[
toolHandle.Touched:Connect(function(otherPart)
	print("test!")
end)


toolHandle.TouchEnded:Connect(function(otherPart)
	print("test!2")
end)
--]]
