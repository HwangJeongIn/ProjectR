-- 로컬 변수

local tool = script.Parent
local anim1 = tool.anim1
local damage = 5
local isAttacking = false
local humanoid
local target
local anim1Track


-- 이벤트 함수 정의

local function onTouched(otherPart)
	
	if isAttacking == false then return end
	
	isAttacking = false
	target = otherPart.Parent:FindFirstChild("Humanoid")
	if target ~= nil then 
		if target.Parent == tool.Parent then return end
	else
		if not otherPart.Parent.ObjectModule then return end
	
		target = require(otherPart.Parent.ObjectModule)
		if target == nil then return end
	end
	
	target:TakeDamage(damage)
end


local function onActivated()
	
	isAttacking = true
	humanoid = tool.Parent.Humanoid
	anim1Track = humanoid:LoadAnimation(anim1)
	anim1Track:Play()
	
	anim1Track.Stopped:Connect(function() isAttacking = false end)
	
	humanoid:TakeDamage(50)
end


-- 이벤트 바인드
tool.Activated:Connect(onActivated)
tool.Attacker.Touched:Connect(onTouched)