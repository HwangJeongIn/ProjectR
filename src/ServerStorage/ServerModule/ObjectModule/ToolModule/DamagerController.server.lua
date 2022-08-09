-- 로컬 변수 정의, 바인드 --------------------------------------------------------------------------------------------

local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))
local Utility = ServerModuleFacade.Utility
local Debug = ServerModuleFacade.Debug
local ServerConstant = ServerModuleFacade.ServerConstant
local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage

local ServerEnum = ServerModuleFacade.ServerEnum
local GameDataType = ServerEnum.GameDataType
local StatType = ServerEnum.StatType

local Damager = Utility:DeepCopy(require(ServerModuleFacade.ToolModule:WaitForChild("Damager")))
local Debris = game:GetService("Debris")

local Tool = script.Parent
local Anim1 = Tool.anim1
local isAttacking = false

Damager:InitializeDamager(GameDataType.Tool, Tool)

function OnTouched(otherPart)
	if isAttacking == false then 
		return 
	end

	isAttacking = false
	Damager:Attack(otherPart)
end

function OnActivated()
	--Debug.Assert(false, ToolBase:GetGameDataKey())
	isAttacking = true
	local humanoid = Tool.Parent:FindFirstChild("Humanoid")
	local anim1Track = humanoid:LoadAnimation(Anim1)
	anim1Track:Play()

	anim1Track.Stopped:Connect(function() isAttacking = false end)
	--humanoid:TakeDamage(50)
end

-- 이벤트 바인드
Tool.Activated:Connect(OnActivated)
Tool.Attacker.Touched:Connect(OnTouched)
