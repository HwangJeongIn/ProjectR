local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))

local Debug = CommonModuleFacade.Debug
local Utility = CommonModuleFacade.Utility
local ToolUtility = CommonModuleFacade.ToolUtility

local ServerStorage = game:GetService("ServerStorage")
local ServerModule = ServerStorage:WaitForChild("ServerModule")
local ServerGlobalStorage = require(ServerModule:WaitForChild("ServerGlobalStorage"))
local ServerEnum = require(ServerModule:WaitForChild("ServerEnum"))
local ServerConstant = require(ServerModule:WaitForChild("ServerConstant"))

local MaxPickupDistance = ServerConstant.MaxPickupDistance
local MaxDropDistance = ServerConstant.MaxDropDistance

local EquipTypeToBoneMappingTable = ServerConstant.EquipTypeToBoneMappingTable

local GameDataType = ServerEnum.GameDataType
local StatusType = ServerEnum.StatusType
local ToolType = ServerEnum.ToolType
local EquipType = ServerEnum.EquipType

local WorldSystem = {
    Objects = {}
}




function SpawnObject(parent, position, )

end

return WorldSystem