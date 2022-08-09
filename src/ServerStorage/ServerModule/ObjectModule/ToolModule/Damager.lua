-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------

local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))
local Utility = ServerModuleFacade.Utility
local Debug = ServerModuleFacade.Debug
local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage


local ServerConstant = ServerModuleFacade.ServerConstant
local DefaultAttackPoint = ServerConstant.DefaultAttackPoint
local DefaultSTRFactor = ServerConstant.DefaultSTRFactor

local ServerEnum = ServerModuleFacade.ServerEnum
local GameDataType = ServerEnum.GameDataType
local StatType = ServerEnum.StatType

local ToolModule = ServerModuleFacade.ToolModule
local Debris = game:GetService("Debris")

local Damager = {}
Damager.__index = Utility.Inheritable__index
Damager.__newindex = Utility.Inheritable__newindex
setmetatable(Damager, Utility:DeepCopy(require(ToolModule:WaitForChild("ToolBase"))))

-- 함수 정의 ------------------------------------------------------------------------------------------------------

function Damager:InitializeDamager(gameDataType, damagerTool)
    if not self:InitializeTool(gameDataType, damagerTool) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    return true
end

function Damager:CanAttack(otherPart)
	if not otherPart then
		Debug.Assert(false, "대상이 존재하지 않습니다.")
		return false
	end
	
	local otherModel = otherPart.Parent
	if not otherModel then
		Debug.Assert(false, "모델이 존재하지 않습니다.")
		return false
	end
	
    local damagerTool = self:Root()
	if not damagerTool then
		Debug.Assert(false, "도구가 없습니다.")
		return false
	end
	
	local damagerToolParent = damagerTool.Parent
	local damagerToolClassName = damagerToolParent.ClassName
	if not damagerToolClassName 
		or damagerToolClassName == "Workspace" 		-- 필드에 존재
		or damagerToolClassName == "Backpack" then	-- 가방에 존재
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	-- 자기자신인 경우
	if damagerToolParent == otherModel then
		return false
	end
	
	return true
end

function Damager:CalcDamage(damagedActor, damageCauser)
	
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

function Damager:AttackCharacter(attackerCharacter, attackeeCharacter)

	local damage = CalcDamage(attackerCharacter, attackeeCharacter)
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

function Damager:Attack(attackeePart)
	if self:CanAttack(attackeePart) == false then
		--Debug.Assert(false, "공격할 수 없습니다.")
		return
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
		self:AttackCharacter(attackerCharacter, attackeeCharacter)
	end
--[[
	local attackerTag = Instance.new("ObjectValue")
	attackerTag.Name = "AttackerTag"
	attackerTag.Value = attackerPlayer
	attackerTag.Parent = attackeeHumanoid
	Debris:AddItem(attackerTag, 3.5)
	--]]
end

return Damager
