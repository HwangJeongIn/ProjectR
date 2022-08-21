local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local Utility = ServerModuleFacade.Utility
local ObjectTagUtility = ServerModuleFacade.ObjectTagUtility
local WorldInteractorUtility = ServerModuleFacade.WorldInteractorUtility

local ServerEnum = ServerModuleFacade.ServerEnum
--[[
local GameDataType = ServerEnum.GameDataType
local EquipType = ServerEnum.EquipType
local WorldInteractorType = ServerEnum.WorldInteractorType
--]]
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

	self.CurrentHp = worldInteractorGameData.MaxHp
	local worldInteractorType = worldInteractorGameData.WorldInteractorType
	if WorldInteractorType.ItemBox == worldInteractorType then
	-- elseif WorldInteractorType.TempType == worldInteractorType then
	else
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

return WorldInteractorBase