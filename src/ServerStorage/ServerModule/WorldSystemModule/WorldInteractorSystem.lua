local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local Utility = ServerModuleFacade.Utility
local ObjectTagUtility = ServerModuleFacade.ObjectTagUtility
local ObjectCollisionGroupUtility = ServerModuleFacade.ObjectCollisionGroupUtility
local WorldInteractorUtility = ServerModuleFacade.WorldInteractorUtility

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage
local ServerEnum = ServerModuleFacade.ServerEnum

local GameDataType = ServerEnum.GameDataType

local WorldInteractorType = ServerEnum.WorldInteractorType
local WorldInteractorTypeConverter = WorldInteractorType.Converter
local WorldInteractors = ServerStorage:WaitForChild("WorldInteractors")

local WorldInteractorModule = ServerModuleFacade.WorldInteractorModule
--local ItemBoxController = require(WorldInteractorModule:WaitForChild("ItemBoxController"))

local ServerModule = ServerStorage:WaitForChild("ServerModule")
local SystemModule = ServerModule:WaitForChild("WorldSystemModule")
local ObjectSystemBase = require(SystemModule:WaitForChild("ObjectSystemBase"))

local WorldInteractorSystem = {}--Utility:DeepCopy(ObjectSystemBase)

WorldInteractorSystem.__index = Utility.Inheritable__index
WorldInteractorSystem.__newindex = Utility.Inheritable__newindex
setmetatable(WorldInteractorSystem, Utility:DeepCopy(ObjectSystemBase))

function WorldInteractorSystem:InitializeWorldInteractorTemplate(worldInteractor)
    if not worldInteractor then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    local mesh = worldInteractor:FindFirstChild("Mesh")
    if not mesh then
        Debug.Assert(false, "메시 정보가 없습니다. => " .. worldInteractor.Name)
        return false
    end

    local trigger = worldInteractor:FindFirstChild("Trigger")
    if not trigger then
        Debug.Assert(false, "WorldInteractor에 트리거가 없습니다. => " .. worldInteractor.Name)
        return false
    end

    --[[
    if not trigger.CanCollide then
        Debug.Print("Trigger에 CanCollide가 꺼져있습니다. 자동으로 켜집니다. => " .. worldInteractor.Name)
        trigger.CanCollide = true
        trigger.CanQuery = true
    end
    --]]

    return true
end

function WorldInteractorSystem:Initialize()
    local worldInteractorTemplateTable = {}

    local allWorldInteractorFolders = WorldInteractors:GetChildren()
    for _, targetWorldInteractorFolder in pairs(allWorldInteractorFolders) do

        local targetWorldInteractors = targetWorldInteractorFolder:GetChildren()
        for _, worldInteractor in pairs(targetWorldInteractors) do

            local worldInteractorName = worldInteractor.Name
            local key = WorldInteractorUtility:GetGameDataKey(worldInteractor)
            if not key then
                Debug.Assert(false, "WorldInteractor에 키가 없습니다. => " .. worldInteractorName)
                return false
            end
            
            if worldInteractorTemplateTable[key] then
                Debug.Assert(false, "같은 키를 가진 WorldInteractor가 있습니다. 키를 변경하세요 => " .. tostring(key) .. " => " .. worldInteractorName)
                return false
            end

            if not self:InitializeWorldInteractorTemplate(worldInteractor) then
                Debug.Assert(false, "WorldInteractor 템플릿 초기화에 실패했습니다. => " .. worldInteractorName)
                return false
            end

            local worldInteractorGameData = WorldInteractorUtility:GetGameDataByKey(key)
            
            ObjectTagUtility:AddTag(worldInteractor, WorldInteractorTypeConverter[worldInteractorGameData.WorldInteractorType])

            if not ObjectCollisionGroupUtility:SetWorldInteractorCollisionGroup(worldInteractor) then
                Debug.Assert(false, "SetWorldInteractorCollisionGroup에 실패했습니다. => " .. worldInteractorName)
                return false
            end
        
            worldInteractorTemplateTable[key] = {WorldInteractor = worldInteractor, WorldInteractorGameData = worldInteractorGameData}
        end
    end
    
    self.WorldInteractorTemplateTable = worldInteractorTemplateTable
    return true
end

function WorldInteractorSystem:GetClonedWorldInteractorScript(worldInteractorType, worldInteractor)
    if not worldInteractorType or not worldInteractor then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    local targetScript = nil
    if WorldInteractorType.ItemBox == worldInteractorType then
        --[[
        targetScript = Utility:DeepCopy(WeaponController)
        if not targetScript:InitializeWeaponController(GameDataType.WorldInteractor, worldInteractor) then
            Debug.Assert(false, "비정상입니다.")
            return nil
        end
        --]]
    end

    return targetScript
end

function WorldInteractorSystem:CreateWorldInteractor(worldInteractorKey)
    if not worldInteractorKey then
        Debug.Assert(false, "WorldInteractor 생성에 실패했습니다. => " .. tostring(worldInteractorKey))
        return nil
    end

    local createdWorldInteractor = self:Create(worldInteractorKey) 
    if not createdWorldInteractor then
        Debug.Assert(false, "WorldInteractor 생성에 실패했습니다. => " .. tostring(worldInteractorKey))
        return nil
    end

    return createdWorldInteractor
end

function WorldInteractorSystem:DestroyWorldInteractor(worldInteractor)
    if not worldInteractor then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if not self:Destroy(worldInteractor) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    return true
end

function WorldInteractorSystem:FindObjectJoints(worldInteractor)
    local joints = {}

    -- 따로 삭제해주는 것으로 변경
    --[[
    local trigger = worldInteractor.Trigger
    table.insert(joints, trigger)
    --]]
    local parts = worldInteractor.Mesh:GetChildren()
    for _, part in pairs(parts) do
        local joint = part:FindFirstChild("Joint")
        if not joint then
            continue
        end

        table.insert(joints, joint)
    end

    return joints
end

function WorldInteractorSystem:CreateImpl(worldInteractorKey)
    local targetWorldInteractor = self.WorldInteractorTemplateTable[worldInteractorKey]

    if not targetWorldInteractor then
        Debug.Assert(false, "WorldInteractor가 존재하지 않습니다. 게임데이터만 있을 가능성이 높습니다. => " .. tostring(worldInteractorKey))
        return nil
    end

    local clonedTargetWorldInteractor = targetWorldInteractor.WorldInteractor:Clone()
	clonedTargetWorldInteractor.Parent = nil

    return clonedTargetWorldInteractor
end

function WorldInteractorSystem:PostCreateImpl(createdWorldInteractor, worldInteractorKey)
    local targetScript = self:GetClonedWorldInteractorScript(self.WorldInteractorTemplateTable[worldInteractorKey].WorldInteractorGameData.WorldInteractorType, createdWorldInteractor)

     -- 없는 것도 존재할 수 있다.
    if targetScript then
        if not self:SetScript(createdWorldInteractor, targetScript) then
            Debug.Assert(false, "비정상입니다.")
            return nil
        end
    end

    return createdWorldInteractor
end

function WorldInteractorSystem:PreDestroyImpl(WorldInteractor)
	Debris:AddItem(WorldInteractor.Trigger, 0)
    return true
end

function WorldInteractorSystem:DestroyImpl(WorldInteractor)
    return true
end

WorldInteractorSystem:Initialize()
return WorldInteractorSystem