local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))

local Debug = CommonModuleFacade.Debug
local Utility = CommonModuleFacade.Utility

--[[
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
--]]

local ObjectSystemBase = {
    Objects = {}
}

ObjectSystemBase.__index = Utility.Inheritable__index
ObjectSystemBase.__newindex = Utility.Inheritable__newindex

-- pure virtual
function ObjectSystemBase:FindObjectJoints(object, ...)
    Debug.Assert(false, "상위 모듈에서 재정의해야합니다.")
    return nil
end

function ObjectSystemBase:CreateImpl(...)
    Debug.Assert(false, "상위 모듈에서 재정의해야합니다.")
    return nil
end

function ObjectSystemBase:DestroyImpl(...)
    Debug.Assert(false, "상위 모듈에서 재정의해야합니다.")
    return false
end

-- virtual
--function ObjectSystemBase:PostCreateImpl(..., createdObject) return createdObject end
--function ObjectSystemBase:PreDestroyImpl(object) return true end
--function ObjectSystemBase:PostDestroyImpl() return true end


function ObjectSystemBase:Create(...)
    local createdObject = self:CreateImpl(...)
    if not createdObject then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    createdObject = self:PostCreate(createdObject, ...)
    if not createdObject then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return createdObject
end

function ObjectSystemBase:PostCreate(createdObject, ...)
    if not self:RegisterObject(createdObject) then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    local objectJoints = self:FindObjectJoints(createdObject)
    self.Objects[createdObject] = { Value = createdObject, Joints = objectJoints }

    if self.PostCreateImpl then
        createdObject = self:PostCreateImpl(createdObject, ...)
        if not createdObject then
            Debug.Assert(false, "비정상입니다.")
            return nil
        end
    end

    return createdObject
end

function ObjectSystemBase:Destroy(object)
    if not self:PreDestroy(object) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if not self:DestroyImpl(object) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if not self:PostDestroy(object) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    return true
end

function ObjectSystemBase:PreDestroy(object)
    if not self:UnregisterObject(object) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if self.PreDestroyImpl then
        if not self:PreDestroyImpl(object) then
            Debug.Assert(false, "비정상입니다.")
            return false
        end
    end

    return true
end

function ObjectSystemBase:PostDestroy(object)
    local joints = self:GetJoints(object)
    if joints then
        for _, joint in pairs(joints) do
            Debris:AddItem(joint, 0)
        end
    end
	Debris:AddItem(object, 5)

    if self.PostDestroyImpl then
        if not self:PostDestroyImpl() then
            Debug.Assert(false, "비정상입니다.")
            return false
        end
    end

    return true
end



function ObjectSystemBase:IsValid(object)
    return nil ~= self.Objects[object]
end

function ObjectSystemBase:SetScript(object, inputScript)
    if not self:IsValid(object) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    --[[
    if not inputScript then
        Debug.Assert(false, "비정상입니다.")
        return false
    end 
    --]]

    self.Objects[object].Script = inputScript
    return true
end

function ObjectSystemBase:GetScript(object)
    if not self:IsValid(object) then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return self.Objects[object].Script
end

function ObjectSystemBase:GetJoints(object)
    if not self:IsValid(object) then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    return self.Objects[object].Joints
end

function ObjectSystemBase:RegisterObject(object)
    if not object then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if self:IsValid(object) then
        Debug.Assert(false, "두번 등록하려고 합니다. 확인해야합니다. => " .. tostring(object))
        return false
    end

    return true
end

function ObjectSystemBase:UnregisterObject(object)
    if not object then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if not self:IsValid(object) then
        Debug.Assert(false, "등록되지 않은 객체입니다. 확인해야합니다. => " .. tostring(object))
        return false
    end

    self.Objects[object] = nil
    return true
end

return ObjectSystemBase