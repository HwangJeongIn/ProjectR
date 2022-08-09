local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))

local Debug = CommonModuleFacade.Debug
local Utility = CommonModuleFacade.Utility

local ServerStorage = game:GetService("ServerStorage")
local ServerModule = ServerStorage:WaitForChild("ServerModule")
local ServerGlobalStorage = require(ServerModule:WaitForChild("ServerGlobalStorage"))
local ServerEnum = require(ServerModule:WaitForChild("ServerEnum"))
local ServerConstant = require(ServerModule:WaitForChild("ServerConstant"))

local SystemModule = ServerModule:WaitForChild("SystemModule")
local ObjectSystemBase = SystemModule:WaitForChild("ObjectSystemBase")
local ToolModule = 

local MaxPickupDistance = ServerConstant.MaxPickupDistance
local MaxDropDistance = ServerConstant.MaxDropDistance

local EquipTypeToBoneMappingTable = ServerConstant.EquipTypeToBoneMappingTable

local GameDataType = ServerEnum.GameDataType
local StatusType = ServerEnum.StatusType
local ToolType = ServerEnum.ToolType
local EquipType = ServerEnum.EquipType

local ToolSystem = {
    Objects = {}
}

ToolSystem.__index = Utility.Inheritable__index
ToolSystem.__newindex = Utility.Inheritable__newindex

function ToolSystem:CheckObject(object)
    return nil ~= self.Objects[object]
end

function ToolSystem:RegisterObject(object)
    if not object then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if self:CheckObject(object) then
        Debug.Assert(false, "두번 등록하려고 합니다. 확인해야합니다. => " .. tostring(object))
        return false
    end

    self.Objects[object] = true
    return true
end

function ToolSystem:UnregisterObject(object)
    if not object then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if not self:CheckObject(object) then
        Debug.Assert(false, "등록되지 않은 객체입니다. 확인해야합니다. => " .. tostring(object))
        return false
    end

    self.Objects[object] = nil
    return true
end

setmetatable(ToolSystem, ObjectSystemBase)
return ToolSystem