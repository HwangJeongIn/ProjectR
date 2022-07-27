local tool = script.Parent

local function explode(point)
	local e = Instance.new("Explosion")
	e.DestroyJointRadiusPercent = 0 -- Make the explosion non-deadly 
	e.Position = point
	e.Parent = workspace
end

local function onActivated()
	-- Get the Humanoid that Activated the tool
	print("onActivated")
	local human = tool.Parent.Humanoid
	-- Call explode with the current point the Humanoid is targetting
	explode(tool.Parent.HumanoidRootPart.Position) 
end

tool.Activated:Connect(onActivated)