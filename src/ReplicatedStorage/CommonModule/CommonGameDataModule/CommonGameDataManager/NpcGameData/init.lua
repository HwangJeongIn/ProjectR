local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")
local Debug = require(CommonModule:WaitForChild("Debug"))

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType

local CommonConstant = require(CommonModule:WaitForChild("CommonConstant"))

local Utility = require(CommonModule:WaitForChild("Utility"))
local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local GameDataBase = Utility:DeepCopy(require(CommonGameDataModule:WaitForChild("GameDataBase")))


local NpcGameData = {ModelToKeyMappingTable = require(script:WaitForChild("NpcModelToKeyMappingTable"))}

-- 내부 함수 먼저 정의
function NpcGameData:LoadSkillGameDataBySkillGameDataKey(skillGameDataKey, gameDataManager)
	local skillGameData = gameDataManager[GameDataType.Skill]:Get(skillGameDataKey)
	if not skillGameData then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	return skillGameData
end

function NpcGameData:LoadAdditionalData(gameData, gameDataManager)
	--[[
	if gameData.SkillSet then
		
		local gameDataRaw = getmetatable(gameData)
		gameDataRaw.SkillGameDataSet = {}
		
		local key = gameData:GetKey()
		local skillCount = #gameDataRaw.SkillSet
		if MaxSkillCount < skillCount then
			Debug.Assert(false, "스킬 최대 개수를 넘겼습니다. [Key] => " .. tostring(key))
			return false
		end

		gameDataRaw.SkillCount = 0
		for index, skillGameDataKey in pairs(gameDataRaw.SkillSet) do
			local skillGameData = self:LoadSkillGameDataBySkillGameDataKey(skillGameDataKey, gameDataManager)
			if not skillGameData then
				Debug.Assert(false, "해당 스킬 데이터가 존재하지 않습니다. [Key] => " .. tostring(key) .. " : [SkillGameDataKey] => " .. tostring(skillGameDataKey))
				return false
			end

			gameDataRaw.SkillGameDataSet[index] = skillGameData
			gameDataRaw.SkillCount += 1
		end
	end
	--]]
	return true
end

function NpcGameData:ValidateData(gameData, gameDataManager)
	--[[
	if not gameData.Name then
		Debug.Assert(false, "툴 이름이 없습니다. => " .. tostring(gameData:GetKey()))
		return false
	end

	local toolType = gameData.ToolType
	if not toolType then
		Debug.Assert(false, "툴 타입이 없습니다. => " .. tostring(gameData:GetKey()))
		return false
	end

	if ToolTypeSelector.Armor == toolType or ToolTypeSelector.Weapon == toolType then
		if not gameData.EquipType then
			Debug.Assert(false, "툴 타입이 Armor, Weapon 타입인데 EquipType이 없습니다. => " .. tostring(gameData:GetKey()))
			return false
		end
	end
	--]]
	return true
end

function NpcGameData:ValidateDataFinally(gameDataManager)
	return true
end

setmetatable(NpcGameData, GameDataBase)
NpcGameData:Initialize(GameDataType.Npc)


-- 몬스터 종류
NpcGameData:InsertData(1, {Name = "WaterNymph"})
NpcGameData:InsertData(2, {Name = "WaterNymph"})
NpcGameData:InsertData(3, {Name = "WaterNymph"})


-- 일반 Npc 종류


return setmetatable({}, NpcGameData)
