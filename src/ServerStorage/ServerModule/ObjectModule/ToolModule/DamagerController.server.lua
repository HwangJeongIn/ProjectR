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

--local DamagerModuleScript = ServerModuleFacade.ToolModule:WaitForChild("Damager")
local Debris = game:GetService("Debris")

local DamagerTool = script.Parent
 
local DamagerController = {}

function DamagerController:InitializeDamagerController(gameDataType, damagerTool)
	self.DamagerTool = DamagerTool
	self.Damager = Utility.DeepCopy(require(ServerModuleFacade.ToolModule:WaitForChild("Damager")))
	--[[
	local clonedDamagerScriptRaw = Utility:AddClonedObjectModuleScriptToObject(damagerTool, damagerScript)
    self.Damager = clonedDamagerScriptRaw
    if not self.Damager:InitializeDamager(gameDataType, damagerTool) then
        return false
    end
	--]]

	local Anim1 = self.DamagerTool:WaitForChild("Anim1")
	local Attacker = self.DamagerTool:WaitForChild("Attacker")
	local IsAttacking = false

	self.Anim1 = Anim1
	self.Attacker = Attacker
	self.IsAttacking = IsAttacking

    return true
end

function OnTouched(DamagerController, touchedActor)
	if DamagerController.IsAttacking == false then 
		return 
	end

	DamagerController.IsAttacking = false
	DamagerController.Damager:Attack(touchedActor)
end

function OnActivated(DamagerController)
	--Debug.Assert(false, ToolBase:GetGameDataKey())
	DamagerController.IsAttacking = true
	local humanoid = DamagerController.DamagerTool.Parent:FindFirstChild("Humanoid")
	local anim1Track = humanoid:LoadAnimation(DamagerController.Anim1)
	anim1Track:Play()

	anim1Track.Stopped:Connect(function() DamagerController.IsAttacking = false end)
	--humanoid:TakeDamage(50)
end

-- 이벤트 바인드
DamagerTool.Activated:Connect(function() OnActivated(DamagerController) end)
DamagerTool.Attacker.Touched:Connect(function(touchedActor) OnTouched(DamagerController, touchedActor) end)

DamagerController:InitializeDamagerController(GameDataType.Tool, DamagerTool)