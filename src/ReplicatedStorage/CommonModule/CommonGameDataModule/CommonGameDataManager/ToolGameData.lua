local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType
local ToolTypeSelector = CommonEnum.ToolType
local ArmorTypeSelector = CommonEnum.ArmorType


local Utility = require(CommonModule:WaitForChild("Utility"))
local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local GameDataBase = Utility.DeepCopy(require(CommonGameDataModule:WaitForChild("GameDataBase")))


local ToolGameData = setmetatable({Name = "ToolGameData"}, GameDataBase)
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
--[[ 기본 무기 	--]] ToolGameData:InsertData(1, {ToolType = ToolTypeSelector.Weapon, STR = 10, DEF = 10, Move = 10, AttackSpeed = 10, Skill = ""})
--[[ 검 			--]] ToolGameData:InsertData(2, {ToolType = ToolTypeSelector.Weapon, STR = 10, DEF = 10, Move = 15, AttackSpeed = 30, Skill = ""})
--[[ 도끼		--]] ToolGameData:InsertData(3, {ToolType = ToolTypeSelector.Weapon, STR = 25, DEF = 5, Move = 1, AttackSpeed = 10, Skill = ""})


-- 방어구 종류
--[[ 기본 머리	--]] ToolGameData:InsertData(101, {ToolType = ToolTypeSelector.Weapon, ArmorType = ArmorTypeSelector.Helmet, DEF = 15})
--[[ 기본 가슴	--]] ToolGameData:InsertData(102, {ToolType = ToolTypeSelector.Weapon, ArmorType = ArmorTypeSelector.Chestplate, DEF = 30, Move = -5})
--[[ 기본 다리	--]] ToolGameData:InsertData(103, {ToolType = ToolTypeSelector.Weapon, ArmorType = ArmorTypeSelector.Leggings, DEF = 20, Move = 5})
--[[ 기본 발		--]] ToolGameData:InsertData(104, {ToolType = ToolTypeSelector.Weapon, ArmorType = ArmorTypeSelector.Boots, DEF = 10, Move = 10})



-- 소모품 종류


return setmetatable({}, ToolGameData)
