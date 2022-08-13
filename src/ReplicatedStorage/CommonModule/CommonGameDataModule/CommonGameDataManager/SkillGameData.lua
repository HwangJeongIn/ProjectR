local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")
local Debug = require(CommonModule:WaitForChild("Debug"))

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType
local SkillTypeSelector = CommonEnum.SkillType

local Utility = require(CommonModule:WaitForChild("Utility"))
local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local GameDataBase = Utility:DeepCopy(require(CommonGameDataModule:WaitForChild("GameDataBase")))


local SkillGameData = {ModelToKeyMappingTable = require(script:WaitForChild("ToolModelToKeyMappingTable"))}

-- 내부 함수 먼저 정의
function SkillGameData:LoadAdditionalData(gameData, gameDataManager)
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

--[[ 기본 공격 		--]] SkillGameData:InsertData(1, {Name = "BaseAttack", SkillType = SkillTypeSelector.AttackSkill, Cooldown = 0.5, Description = ""})
--[[ 휠윈드			--]] SkillGameData:InsertData(2, {Name = "WhirlwindSlash", SkillType = SkillTypeSelector.AttackSkill, Cooldown = 1, Description = "Spin around, inflicting ?% Damage."})
--[[ 템페스트 슬래시--]] SkillGameData:InsertData(3, {Name = "TempestSlash", SkillType = SkillTypeSelector.AttackSkill, Cooldown = 1, Description = "Charge and slash, inflicting ?% Damage."})

--[[ 파워 스트라이크--]] SkillGameData:InsertData(4, {Name = "PowerStrike", SkillType = SkillTypeSelector.AttackSkill, Cooldown = 1, Description = "Deliver a powerful attack, inflicting ?% Damage."})
--[[ 스톰 블레이드	--]] SkillGameData:InsertData(5, {Name = "StormBlade", SkillType = SkillTypeSelector.AttackSkill, Cooldown = 1, Description = "Smash the ground to create a storm of blades, inflicting ?% Damage"})


return setmetatable({}, SkillGameData)