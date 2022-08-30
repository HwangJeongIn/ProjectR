local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")
local Debug = require(CommonModule:WaitForChild("Debug"))

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType
local ToolTypeSelector = CommonEnum.ToolType
local EquipTypeSelector = CommonEnum.EquipType

local CommonConstant = require(CommonModule:WaitForChild("CommonConstant"))
local MaxSkillCount = CommonConstant.MaxSkillCount

local Utility = require(CommonModule:WaitForChild("Utility"))
local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local GameDataBase = Utility:DeepCopy(require(CommonGameDataModule:WaitForChild("GameDataBase")))


local ToolGameData = {ModelToKeyMappingTable = require(script:WaitForChild("ToolModelToKeyMappingTable"))}

-- 내부 함수 먼저 정의
function ToolGameData:LoadSkillGameDataBySkillGameDataKey(skillGameDataKey, gameDataManager)
	local skillGameData = gameDataManager[GameDataType.Skill]:Get(skillGameDataKey)
	if not skillGameData then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	return skillGameData
end

function ToolGameData:LoadAdditionalData(gameData, gameDataManager)
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
	return true
end

function ToolGameData:ValidateData(gameData, gameDataManager)
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

	return true
end

function ToolGameData:ValidateDataFinally(gameDataManager)
	return true
end

setmetatable(ToolGameData, GameDataBase)
ToolGameData:Initialize(GameDataType.Tool)

--[[
HP : 체력
MP : 마력
STR : 공격력
DEF : 방어력
HIT : 명중
AttackSpeed : 공격속도
Dodge : 회피
Block : 블록
Critical : 크리티컬
Move : 이동력
Sight : 시야
--]]

-- 무기 종류
ToolGameData:InsertData(1, {Name = "WoodStick", ToolType = ToolTypeSelector.Weapon, EquipType = EquipTypeSelector.Weapon, STR = 10, DEF = 10, Move = 10, AttackSpeed = 10})


ToolGameData:InsertData(2, {Name = "Sword", ToolType = ToolTypeSelector.Weapon, EquipType = EquipTypeSelector.Weapon, STR = 10, DEF = 10, Move = 15, AttackSpeed = 30, SkillSet = {1, 1, 1}})
ToolGameData:InsertData(3, {Name = "Axe", ToolType = ToolTypeSelector.Weapon, EquipType = EquipTypeSelector.Weapon, STR = 25, DEF = 5, Move = 1, AttackSpeed = 10})
ToolGameData:InsertData(4, {Name = "RustySword", ToolType = ToolTypeSelector.Weapon, EquipType = EquipTypeSelector.Weapon, STR = 10, DEF = 10, Move = 15, AttackSpeed = 30, })
ToolGameData:InsertData(5, {Name = "SmallKnife", ToolType = ToolTypeSelector.Weapon, EquipType = EquipTypeSelector.Weapon, STR = 10, DEF = 10, Move = 15, AttackSpeed = 30, })
ToolGameData:InsertData(6, {Name = "Knife", ToolType = ToolTypeSelector.Weapon, EquipType = EquipTypeSelector.Weapon, STR = 10, DEF = 10, Move = 15, AttackSpeed = 30, })
ToolGameData:InsertData(7, {Name = "BlueSword", ToolType = ToolTypeSelector.Weapon, EquipType = EquipTypeSelector.Weapon, STR = 10, DEF = 10, Move = 15, AttackSpeed = 30, })
ToolGameData:InsertData(8, {Name = "FlameSword", ToolType = ToolTypeSelector.Weapon, EquipType = EquipTypeSelector.Weapon, STR = 10, DEF = 10, Move = 15, AttackSpeed = 30, })
ToolGameData:InsertData(9, {Name = "FrostSword", ToolType = ToolTypeSelector.Weapon, EquipType = EquipTypeSelector.Weapon, STR = 10, DEF = 10, Move = 15, AttackSpeed = 30, })
ToolGameData:InsertData(10, {Name = "BloodSword", ToolType = ToolTypeSelector.Weapon, EquipType = EquipTypeSelector.Weapon, STR = 10, DEF = 10, Move = 15, AttackSpeed = 30, })


--[[
ToolGameData:InsertData(2, {Name = "Sword", ToolType = ToolTypeSelector.Weapon, EquipType = EquipTypeSelector.Weapon, STR = 10, DEF = 10, Move = 15, AttackSpeed = 30, SkillSet = {3, 5}})
ToolGameData:InsertData(3, {Name = "Axe", ToolType = ToolTypeSelector.Weapon, EquipType = EquipTypeSelector.Weapon, STR = 25, DEF = 5, Move = 1, AttackSpeed = 10, SkillSet = {4}})

ToolGameData:InsertData(4, {Name = "RustySword", ToolType = ToolTypeSelector.Weapon, EquipType = EquipTypeSelector.Weapon, STR = 10, DEF = 10, Move = 15, AttackSpeed = 30, SkillSet = {3, 5}})
ToolGameData:InsertData(5, {Name = "SmallKnife", ToolType = ToolTypeSelector.Weapon, EquipType = EquipTypeSelector.Weapon, STR = 10, DEF = 10, Move = 15, AttackSpeed = 30, SkillSet = {3, 5}})
ToolGameData:InsertData(6, {Name = "Knife", ToolType = ToolTypeSelector.Weapon, EquipType = EquipTypeSelector.Weapon, STR = 10, DEF = 10, Move = 15, AttackSpeed = 30, SkillSet = {3, 5}})
ToolGameData:InsertData(7, {Name = "BlueSword", ToolType = ToolTypeSelector.Weapon, EquipType = EquipTypeSelector.Weapon, STR = 10, DEF = 10, Move = 15, AttackSpeed = 30, SkillSet = {3, 5}})
ToolGameData:InsertData(8, {Name = "FlameSword", ToolType = ToolTypeSelector.Weapon, EquipType = EquipTypeSelector.Weapon, STR = 10, DEF = 10, Move = 15, AttackSpeed = 30, SkillSet = {3, 5}})
ToolGameData:InsertData(9, {Name = "FrostSword", ToolType = ToolTypeSelector.Weapon, EquipType = EquipTypeSelector.Weapon, STR = 10, DEF = 10, Move = 15, AttackSpeed = 30, SkillSet = {3, 5}})
ToolGameData:InsertData(10, {Name = "BloodSword", ToolType = ToolTypeSelector.Weapon, EquipType = EquipTypeSelector.Weapon, STR = 10, DEF = 10, Move = 15, AttackSpeed = 30, SkillSet = {3, 5}})
--]]

-- 방어구 종류
ToolGameData:InsertData(101, {Name = "Helmet", ToolType = ToolTypeSelector.Armor, EquipType = EquipTypeSelector.Helmet, DEF = 15})
ToolGameData:InsertData(102, {Name = "Chestplate", ToolType = ToolTypeSelector.Armor, EquipType = EquipTypeSelector.Chestplate, DEF = 40, Move = -8})
ToolGameData:InsertData(103, {Name = "Leggings", ToolType = ToolTypeSelector.Armor, EquipType = EquipTypeSelector.Leggings, DEF = 20})
ToolGameData:InsertData(104, {Name = "Boots", ToolType = ToolTypeSelector.Armor, EquipType = EquipTypeSelector.Boots, DEF = 10, Move = 10, Jump = 5})



-- 소모품 종류

return setmetatable({}, ToolGameData)
