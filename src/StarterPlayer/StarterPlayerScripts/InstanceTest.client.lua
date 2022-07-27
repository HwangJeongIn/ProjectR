
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InstanceTestSTC = ReplicatedStorage:WaitForChild("InstanceTestSTC")
local InstanceTestModule = require(ReplicatedStorage:WaitForChild("InstanceTestModule"))

InstanceTestSTC.OnClientEvent:Connect(function(...)
	
	InstanceTestModule["Client"] = 1
	local args = {...}
	for _, arg in ipairs(args) do
		print("TEST!!")
		local temp2 = getmetatable(arg)
		local temp = 3
		
	end
	
end)