-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------

local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))
local Utility = ServerModuleFacade.Utility
--local ToolUtility = ServerModuleFacade.ToolUtility

local Debug = ServerModuleFacade.Debug
local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage


local ServerConstant = ServerModuleFacade.ServerConstant
local DefaultAttackPoint = ServerConstant.DefaultAttackPoint
local DefaultSTRFactor = ServerConstant.DefaultSTRFactor

local ServerEnum = ServerModuleFacade.ServerEnum
local GameDataType = ServerEnum.GameDataType
local StatType = ServerEnum.StatType
local EquipType = ServerEnum.EquipType

local ToolModule = ServerModuleFacade.ToolModule
local Debris = game:GetService("Debris")

local Weapon = {}
Weapon.__index = Utility.Inheritable__index
Weapon.__newindex = Utility.Inheritable__newindex
setmetatable(Weapon, Utility:DeepCopy(require(ToolModule:WaitForChild("ToolBase"))))

-- 함수 정의 ------------------------------------------------------------------------------------------------------

function Weapon:InitializeWeapon(gameDataType, weaponTool)
    if not self:InitializeTool(gameDataType, weaponTool) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

	local  gameData = self:GetGameData()
	self.SkillSet = {
		[1] = gameData.Skill1,
		[2] = gameData.Skill2,
		[3] = gameData.Skill3,
	}

    return true
end

function Weapon:IsInteractableObject(object)
	if not object then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
end

function Weapon:CanAttack(otherPart)
	if not otherPart then
		Debug.Assert(false, "대상이 존재하지 않습니다.")
		return false
	end
	
	local otherModel = otherPart.Parent
	if not otherModel then
		Debug.Assert(false, "모델이 존재하지 않습니다.")
		return false
	end
	
    local weaponTool = self:Root()
	if not weaponTool then
		Debug.Assert(false, "도구가 없습니다.")
		return false
	end
	
	local weaponToolParent = weaponTool.Parent
	local weaponToolClassName = weaponToolParent.ClassName
	if not weaponToolClassName 
		or weaponToolClassName == "Workspace" 		-- 필드에 존재
		or weaponToolClassName == "Backpack" then	-- 가방에 존재
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	-- 자기자신인 경우
	if weaponToolParent == otherModel then
		return false
	end
	
	return true
end

function Weapon:CalcDamageByDefaultSkill(damagedActor, damageCauser)
	
    --[[
    local playerOfDamagedActor = game.Players:GetPlayerByUserId(damagedActor)
    local playerOfDamageCauser = game.Players:GetPlayerByUserId(damageCauser)

	local damagedPlayer = game.Players:GetPlayerByUserId(damagedActor)
    local damageCauserPlayer = 

	local attackerSTR = 0
	local attackeeDEF = 0
	
	-- ==== 캐릭터 계산 ====
    ServerGlobalStorage:GetStat(StatType.STR)



	local attackerCharacterGameData = ServerGlobalStorage:GetGameData(attackerCharacter, GameDataType.Character)
	local attackeeCharacterGameData = ServerGlobalStorage:GetGameData(attackeeCharacter, GameDataType.Character)
	
	-- 캐릭터 공격 데이터
	if not attackerCharacterGameData then
		Debug.Assert(false, "캐릭터 정보가 없습니다." .. attackerCharacter.Name)
	else
		attackerSTR += attackerCharacterGameData.STR
	end
	
	-- 캐릭터 방어 데이터
	if not attackeeCharacterGameData then
		Debug.Assert(false, "캐릭터 정보가 없습니다." .. attackeeCharacter.Name)
	else
		attackeeDEF += attackeeCharacterGameData.DEF
	end
	
	-- ==== 도구 계산 =====
	local attackerToolGameData = ServerGlobalStorage:GetGameData(attackerCharacter, GameDataType.Tool)
	local attackeeToolGameData = ServerGlobalStorage:GetGameData(attackeeCharacter, GameDataType.Tool)
	
	-- 도구 공격 데이터
	if attackerToolGameData and attackerToolGameData.STR then
		attackerSTR += attackerToolGameData.STR
	end
	-- 도구 방어 데이터
	if attackeeToolGameData and attackeeToolGameData.DEF then
		attackeeDEF += attackeeToolGameData.DEF
	end
	
	
	local finalDamage = DefaultAttackPoint + (attackerSTR * DefaultSTRFactor) - attackeeDEF
	
	finalDamage = math.clamp(finalDamage, 0, 100)
	
	return finalDamage
    --]]
end

function Weapon:AttackCharacterByDefaultSkill(attackerCharacter, attackeeCharacter)

	local damage = self:CalcDamage(attackerCharacter, attackeeCharacter)
	Debug.Log("Damage : ".. tostring(damage))
	if damage == 0 then
		return
	end

	local attackeeCharacterHumanoid = attackeeCharacter:FindFirstChild("Humanoid")
	if not attackeeCharacterHumanoid then
		Debug.Assert(false, "Humanoid가 없습니다.")
		return
	end

	attackeeCharacterHumanoid:TakeDamage(damage)
end


function Weapon:AttackByDefaultSkill(attackeePart)
	if self:CanAttack(attackeePart) == false then
		--Debug.Assert(false, "공격할 수 없습니다.")
		return false
	end
	
	local attackeePlayer = game.Players:GetPlayerFromCharacter(attackeePart.Parent)
	print(attackeePlayer)
	print(attackeePart)
	print(attackeePart.Parent)
	if not attackeePlayer then
		-- 추가해야한다.
		Debug.Log("플레이어가 아닙니다.")
	else
		local attackerCharacter = Tool.Parent
		local attackeeCharacter = attackeePart.Parent
		if not self:AttackCharacter(attackerCharacter, attackeeCharacter) then
			Debug.Assert(false, "비정상입니다.")
			return false
		end
	end
--[[
	local attackerTag = Instance.new("ObjectValue")
	attackerTag.Name = "AttackerTag"
	attackerTag.Value = attackerPlayer
	attackerTag.Parent = attackeeHumanoid
	Debris:AddItem(attackerTag, 3.5)
	--]]

	return true
end

return Weapon
