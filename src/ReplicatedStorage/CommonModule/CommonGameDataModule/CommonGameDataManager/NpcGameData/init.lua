local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")
local Debug = require(CommonModule:WaitForChild("Debug"))

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType
local StatTypeSelector = CommonEnum.StatType

local CommonConstant = require(CommonModule:WaitForChild("CommonConstant"))

local Utility = require(CommonModule:WaitForChild("Utility"))
local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local GameDataBase = Utility:DeepCopy(require(CommonGameDataModule:WaitForChild("GameDataBase")))


local NpcGameData = {ModelToKeyMappingTable = require(script:WaitForChild("NpcModelToKeyMappingTable"))}

function NpcGameData:LoadAdditionalData(gameData, gameDataManager)
	local StatisticRaw = {}
	if gameData.STR then
		StatisticRaw[StatTypeSelector.STR] = gameData.STR
	end

	if gameData.DEF then
		StatisticRaw[StatTypeSelector.DEF] = gameData.DEF
	end
	
	if gameData.Move then
		StatisticRaw[StatTypeSelector.Move] = gameData.Move
	end

	if gameData.AttackSpeed then
		StatisticRaw[StatTypeSelector.AttackSpeed] = gameData.AttackSpeed
	end

	rawset(gameData, "StatisticRaw", StatisticRaw)
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
NpcGameData:InsertData(1, {Name = "Dummy", STR = 10, DEF = 10, Move = 10, AttackSpeed = 10})
NpcGameData:InsertData(2, {Name = "WaterNymph", STR = 20, DEF = 10, Move = 25, AttackSpeed = 50})


-- 일반 Npc 종류


return setmetatable({}, NpcGameData)
