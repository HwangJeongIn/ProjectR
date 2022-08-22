local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local Utility = ServerModuleFacade.Utility
local ObjectTagUtility = ServerModuleFacade.ObjectTagUtility
local WorldInteractorUtility = ServerModuleFacade.WorldInteractorUtility

local ServerEnum = ServerModuleFacade.ServerEnum
local WorldInteractorType = ServerEnum.WorldInteractorType
local ObjectModule = ServerModuleFacade.ObjectModule

local WorldInteractorBase = {}
WorldInteractorBase.__index = Utility.Inheritable__index
WorldInteractorBase.__newindex = Utility.Inheritable__newindex
setmetatable(WorldInteractorBase, Utility:DeepCopy(require(ObjectModule:WaitForChild("ObjectBase"))))

function WorldInteractorBase:InitializeWorldInteractor(gameDataType, worldInteractor)
	local worldInteractorGameData = WorldInteractorUtility:GetGameData(worldInteractor)

	if not self:InitializeObject(gameDataType, worldInteractor, worldInteractorGameData) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	self.MaxHp = worldInteractorGameData.MaxHp
	self.CurrentHp = self.MaxHp

	local worldInteractorType = worldInteractorGameData.WorldInteractorType
	if WorldInteractorType.ItemBox == worldInteractorType then
		
	-- elseif WorldInteractorType.TempType == worldInteractorType then
	else
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

-- virtual
function WorldInteractorBase:OnDestroying()
	return true
end

function WorldInteractorBase:SetJoints(joints)
	if not joints then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local maxJointCount = #joints
	if maxJointCount then
		self.Joints = joints
		self.MaxJointCount = maxJointCount
	end

	return true
end

function WorldInteractorBase:TakeDamage(damage)
	if 0 > damage then
		Debug.Assert(false, "비정상입니다.")
		return -1
	end

	self.CurrentHp = self.CurrentHp - damage
	if 0 >= self.CurrentHp then
		self.CurrentHp = 0
		if not self:OnDestroying() then
			Debug.Assert(false, "OnDestroying에 실패했습니다.")
		end
		
		return 0
	end

	local currentHpRate = self.CurrentHp / self.MaxHp
	if self.Joints then
		local currentJointCount = #self.Joints

		local targetJointCount = math.ceil(self.MaxJointCount * currentHpRate)
		if targetJointCount < currentJointCount then
			local jointCountToDelete = currentJointCount - targetJointCount
			for i = 1, jointCountToDelete do
				Debris:AddItem(self.Joints[i], 0)
			end
		end
    end
	return self.CurrentHp
end

return WorldInteractorBase