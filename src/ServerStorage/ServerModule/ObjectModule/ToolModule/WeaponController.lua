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

--local WeaponModuleScript = ServerModuleFacade.ToolModule:WaitForChild("Weapon")
local Debris = game:GetService("Debris")

local WeaponController = {}

function WeaponController:InitializeWeaponController(gameDataType, weaponTool)
	self.WeaponTool = weaponTool
	self.Weapon = Utility:DeepCopy(require(ServerModuleFacade.ToolModule:WaitForChild("Weapon")))

    if not self.Weapon:InitializeWeapon(gameDataType, weaponTool) then
		Debug.Assert(false, "비정상입니다.")
        return false
    end

	--[[
	local clonedWeaponScriptRaw = Utility:AddClonedObjectModuleScriptToObject(WeaponTool, WeaponScript)
    self.Weapon = clonedWeaponScriptRaw

	--]]

	local Anim1 = self.WeaponTool:WaitForChild("Anim1")
	local Attacker = self.WeaponTool:WaitForChild("Attacker")
	local IsAttacking = false

	self.Anim1 = Anim1
	self.Attacker = Attacker
	self.IsAttacking = IsAttacking

	self.WeaponTool.Activated:Connect(function() OnActivated(WeaponController) end)
	self.WeaponTool.Attacker.Touched:Connect(function(touchedActor) OnTouched(WeaponController, touchedActor) end)

    return true
end

function OnTouched(WeaponController, touchedActor)
	if WeaponController.IsAttacking == false then 
		return 
	end

	WeaponController.IsAttacking = false
	WeaponController.Weapon:Attack(touchedActor)
end

function OnActivated(WeaponController)
	--Debug.Assert(false, ToolBase:GetGameDataKey())
	WeaponController.IsAttacking = true
	local humanoid = WeaponController.WeaponTool.Parent:FindFirstChild("Humanoid")
	local anim1Track = humanoid:LoadAnimation(WeaponController.Anim1)
	anim1Track:Play()

	anim1Track.Stopped:Connect(function() WeaponController.IsAttacking = false end)
	--humanoid:TakeDamage(50)
end

return WeaponController