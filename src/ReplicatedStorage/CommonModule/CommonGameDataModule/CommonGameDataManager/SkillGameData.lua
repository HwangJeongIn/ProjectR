local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")
local Debug = require(CommonModule:WaitForChild("Debug"))

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType
local SkillTypeSelector = CommonEnum.SkillType
local SkillFactorTypeSelector = CommonEnum.SkillFactorType

local Utility = require(CommonModule:WaitForChild("Utility"))
local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local GameDataBase = Utility:DeepCopy(require(CommonGameDataModule:WaitForChild("GameDataBase")))


local SkillGameData = {}

-- 내부 함수 먼저 정의
function SkillGameData:LoadAdditionalData(gameData, gameDataManager)
	local skillFactor = {}
	if gameData.AttackRate then
		skillFactor[SkillFactorTypeSelector.AttackRate] = gameData.AttackRate
	end

	if gameData.DefenseRate then
		skillFactor[SkillFactorTypeSelector.DefenseRate] = gameData.DefenseRate
	end

	rawset(gameData, "SkillFactor", skillFactor)

	local splitedStrings = Utility:Split(gameData.Description, "<>")
	local newDescription = ""
	for _, splitedString in pairs(splitedStrings) do
		local skillFactorType = SkillFactorTypeSelector[splitedString]
		if skillFactorType then
			local factorValue = skillFactor[skillFactorType]
			local factorValueString = "?"
			if factorValue then
				factorValueString = tostring(factorValue)
			end
			newDescription = newDescription .. factorValueString
		else
			newDescription = newDescription .. splitedString
		end
	end

	rawset(gameData, "Description", newDescription)
	return true
end

function SkillGameData:ValidateData(gameData, gameDataManager)
	return true
end

function SkillGameData:ValidateDataFinally(gameDataManager)
	return true
end

setmetatable(SkillGameData, GameDataBase)
SkillGameData:Initialize(GameDataType.Skill)

--[[ 기본 공격 		--]] SkillGameData:InsertData(1, {Name = "BaseAttack", SkillType = SkillTypeSelector.AttackSkill, Cooldown = 0.5, AttackRate = 100, Description = "Inflicting <AttackRate>% Damage."})
--[[ 휠윈드			--]] SkillGameData:InsertData(2, {Name = "WhirlwindSlash", SkillType = SkillTypeSelector.AttackSkill, Cooldown = 1, AttackRate = 300, Description = "Spin around, inflicting <AttackRate>% Damage."})
--[[ 템페스트 슬래시--]] SkillGameData:InsertData(3, {Name = "TempestSlash", SkillType = SkillTypeSelector.AttackSkill, Cooldown = 1, AttackRate = 210, Description = "Charge and slash, inflicting <AttackRate>% Damage."})

--[[ 파워 스트라이크--]] SkillGameData:InsertData(4, {Name = "PowerStrike", SkillType = SkillTypeSelector.AttackSkill, Cooldown = 1, AttackRate = 450, Description = "Deliver a powerful attack, inflicting <AttackRate>% Damage."})
--[[ 스톰 블레이드	--]] SkillGameData:InsertData(5, {Name = "StormBlade", SkillType = SkillTypeSelector.AttackSkill, Cooldown = 1, AttackRate = 130, Description = "Smash the ground to create a storm of blades, inflicting <AttackRate>% Damage"})


return setmetatable({}, SkillGameData)