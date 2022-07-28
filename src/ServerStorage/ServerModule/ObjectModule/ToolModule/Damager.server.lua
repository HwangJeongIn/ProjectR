-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------

local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))
local Utility = ServerModuleFacade.Utility
local Debug = ServerModuleFacade.Debug
local ServerConstant = ServerModuleFacade.ServerConstant
local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage

local GameDataType = ServerModuleFacade.ServerEnum.GameDataType

local ToolBase = Utility:DeepCopy(require(ServerModuleFacade.ToolModule:WaitForChild("ToolBase")))
local Debris = game:GetService("Debris")

local Tool = script.Parent
local Anim1 = Tool.anim1
local isAttacking = false

ToolBase:InitializeAll(GameDataType.Tool, Tool)

-- 함수 정의 ------------------------------------------------------------------------------------------------------

function CanAttack(otherPart)
	
	if not otherPart then
		Debug.Assert(false, "대상이 존재하지 않습니다.")
		return false
	end
	
	local otherModel = otherPart.Parent
	if not otherModel then
		Debug.Assert(false, "모델이 존재하지 않습니다.")
		return false
	end
	
	if not Tool then
		Debug.Assert(false, "도구가 없습니다.")
		return false
	end
	
	local toolParent = Tool.Parent
	local toolParentClassName = toolParent.ClassName
	if not toolParentClassName 
		or toolParentClassName == "Workspace" 		-- 필드에 존재
		or toolParentClassName == "Backpack" then	-- 가방에 존재
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	-- 자기자신인 경우
	if toolParent == otherModel then
		return false
	end
	
	return true
	
end

function CalcDamage(attackerCharacter, attackeeCharacter)
	
	local attackerSTR = 0
	local attackeeDEF = 0
	
	-- ==== 캐릭터 계산 ====
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
	
	
	local finalDamage = ServerConstant.DefaultAttackPoint + (attackerSTR * ServerConstant.DefaultSTRFactor) - attackeeDEF
	
	finalDamage = math.clamp(finalDamage, 0, 100)
	
	return finalDamage
	
end

function AttackCharacter(attackerCharacter, attackeeCharacter)

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

function Attack(attackeePart)
	
	
	if CanAttack(attackeePart) == false then
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
		AttackCharacter(attackerCharacter, attackeeCharacter)
	end
	
	
--[[
	local attackerTag = Instance.new("ObjectValue")
	attackerTag.Name = "AttackerTag"
	attackerTag.Value = attackerPlayer
	attackerTag.Parent = attackeeHumanoid
	Debris:AddItem(attackerTag, 3.5)
	--]]
end


function onTouched(otherPart)

	if isAttacking == false then return end
	isAttacking = false
	
	Attack(otherPart)
	
	--[[
	target = otherPart.Parent:FindFirstChild("Humanoid")
	if target ~= nil then 
		if target.Parent == tool.Parent then return end
	else
		if not otherPart.Parent.ObjectModule then return end

		target = require(otherPart.Parent.ObjectModule)
		if target == nil then return end
	end

	target:TakeDamage(damage)
	--]]
end


function onActivated()

	--Debug.Assert(false, ToolBase:GetGameDataKey())
	isAttacking = true
	local humanoid = Tool.Parent:FindFirstChild("Humanoid")
	local anim1Track = humanoid:LoadAnimation(Anim1)
	anim1Track:Play()

	anim1Track.Stopped:Connect(function() isAttacking = false end)

	--humanoid:TakeDamage(50)
end


-- 이벤트 바인드
Tool.Activated:Connect(onActivated)
Tool.Attacker.Touched:Connect(onTouched)
