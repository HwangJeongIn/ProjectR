local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")
local Debug = require(CommonModule:WaitForChild("Debug"))

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType
local ToolTypeSelector = CommonEnum.ToolType
local EquipTypeSelector = CommonEnum.EquipType


local Utility = require(CommonModule:WaitForChild("Utility"))
local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local GameDataBase = Utility:DeepCopy(require(CommonGameDataModule:WaitForChild("GameDataBase")))


local ToolGameData = {ToolModelToKeyMappingTable = require(script:WaitForChild("ToolModelToKeyMappingTable"))}

-- 내부 함수 먼저 정의
function ToolGameData:LoadAdditionalData(gameData, gameDataManager)
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

function ToolGameData:ValidateAllDataFinally(gameDataManager)
	for toolModelName, toolGameDataKey in pairs(self.ToolModelToKeyMappingTable) do
		if not self:Get(toolGameDataKey) then
			Debug.Assert(false, "해당 키가 존재하지 않습니다. => " .. toolModelName .. " : " .. tostring(toolGameDataKey))
			return false
		end
	end

	rawset(self, "GetGameDataByModelName", function(targetModelName)
		local targetKey = self.ToolModelToKeyMappingTable[targetModelName]
		if not targetKey then
			Debug.Assert(false, "모델이 등록된 키가 없습니다. => " .. targetModelName)
			return nil
		end

		-- 처음에 검증했기 때문에 무조건 존재한다. 추가 검증 없이 사용한다.
		return self:Get(targetKey)
	end)

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
--[[ 기본 무기 	--]] ToolGameData:InsertData(1, {Name = "DefaultWeapon", ToolType = ToolTypeSelector.Weapon, EquipType = EquipTypeSelector.Weapon, STR = 10, DEF = 10, Move = 10, AttackSpeed = 10, Skill = ""})
--[[ 검 		--]] ToolGameData:InsertData(2, {Name = "DefaultSword", ToolType = ToolTypeSelector.Weapon, EquipType = EquipTypeSelector.Weapon, STR = 10, DEF = 10, Move = 15, AttackSpeed = 30, Skill = ""})
--[[ 도끼		--]] ToolGameData:InsertData(3, {Name = "DefaultAxe", ToolType = ToolTypeSelector.Weapon, EquipType = EquipTypeSelector.Weapon, STR = 25, DEF = 5, Move = 1, AttackSpeed = 10, Skill = ""})


-- 방어구 종류
--[[ 기본 머리	--]] ToolGameData:InsertData(101, {Name = "DefaultHelmet", ToolType = ToolTypeSelector.Armor, EquipType = EquipTypeSelector.Helmet, DEF = 15})
--[[ 기본 가슴	--]] ToolGameData:InsertData(102, {Name = "DefaultChestplate", ToolType = ToolTypeSelector.Armor, EquipType = EquipTypeSelector.Chestplate, DEF = 30, Move = -5})
--[[ 기본 다리	--]] ToolGameData:InsertData(103, {Name = "DefaultLeggings", ToolType = ToolTypeSelector.Armor, EquipType = EquipTypeSelector.Leggings, DEF = 20, Move = 5})
--[[ 기본 발	--]] ToolGameData:InsertData(104, {Name = "DefaultBoots", ToolType = ToolTypeSelector.Armor, EquipType = EquipTypeSelector.Boots, DEF = 10, Move = 10})



-- 소모품 종류


return setmetatable({}, ToolGameData)
