local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType

local Utility = require(CommonModule:WaitForChild("Utility"))
local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local GameDataBase = Utility:DeepCopy(require(CommonGameDataModule:WaitForChild("GameDataBase")))

local CharacterGameData = {}

-- 내부 함수 먼저 정의
function CharacterGameData:LoadAdditionalData(gameData, gameDataManager)
	return true
end

function CharacterGameData:ValidateData(gameData, gameDataManager)
	return true
end

function CharacterGameData:ValidateAllDataFinally(gameDataManager)
	return true
end

setmetatable(CharacterGameData, GameDataBase)
CharacterGameData:Initialize(GameDataType.Character)

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


--[[ 기본 	--]] CharacterGameData:InsertData(1, {STR = 10, DEF = 10, Move = 10, AttackSpeed = 10, Skill = ""})
--[[ 성장	--]] CharacterGameData:InsertData(2, {STR = 50, DEF = 50, Move = 50, AttackSpeed = 50, Skill = ""})

return setmetatable({}, CharacterGameData)
