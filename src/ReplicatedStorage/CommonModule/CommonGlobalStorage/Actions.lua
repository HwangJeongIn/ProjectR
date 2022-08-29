local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))


local Actions = {
	SkillLastActivationTimeTable = {},
	RecentAttacker = nil,
	KillCount = 0,
}


function Actions:GetKillCount()
	return self.KillCount
end

function Actions:SetKillCount(killCount)
	if not killCount then
		Debug.Assert(killCount, "비정상입니다.")
		return false
	end

	self.KillCount = killCount
	return true
end

function Actions:SetRecentAttacker(attacker)
	if not attacker then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	self.RecentAttacker = attacker
	return true
end

function Actions:GetRecentAttacker()
	return self.RecentAttacker
end

function Actions:SetSkillLastActivationTime(skillGameDataKey, lastActivationTime)
	if not skillGameDataKey then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	self.SkillLastActivationTimeTable[skillGameDataKey] = lastActivationTime
	return true
end

function Actions:GetSkillLastActivationTime(skillGameDataKey)
	if not skillGameDataKey then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	return self.SkillLastActivationTimeTable[skillGameDataKey]
end


return Actions
