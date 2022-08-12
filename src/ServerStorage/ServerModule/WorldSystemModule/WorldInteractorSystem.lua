local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))

local Debug = CommonModuleFacade.Debug
local Utility = CommonModuleFacade.Utility
local ToolUtility = CommonModuleFacade.ToolUtility

local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage
local ServerEnum = ServerModuleFacade.ServerEnum

local GameDataType = ServerEnum.GameDataType

local ToolType = ServerEnum.ToolType
local ToolTypeConverter = ToolType.Converter
local Tools = ServerStorage:WaitForChild("Tools")

local ToolModule = ServerModuleFacade.ToolModule
local WeaponController = require(ToolModule:WaitForChild("WeaponController"))

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

    local key = worldInteractor:FindFirstChild("Key")
    if not key then
        Debug.Assert(false, "도구에 Key 정보가 없습니다. => " .. worldInteractor.Name)
        return false
    end
    local mesh = worldInteractor:FindFirstChild("Mesh")
    if not mesh then
        Debug.Assert(false, "메시 정보가 없습니다. => " .. worldInteractor.Name)
        return false
    end

    local trigger = worldInteractor:FindFirstChild("Trigger")
    if not trigger then
        Debug.Assert(false, "도구에 트리거가 없습니다. => " .. worldInteractor.Name)
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
    local ToolTemplateTable = {}

    local toolTypeCount = ToolType.Count - 2
    local allToolFolders = Tools:GetChildren()
    for _, targetToolFolder in pairs(allToolFolders) do

        local targetToolFolderTools = targetToolFolder:GetChildren()
        for _, tool in pairs(targetToolFolderTools) do

            local key = tool:FindFirstChild("Key")
            if not key then
                Debug.Assert(false, "도구에 키가 없습니다. => " .. tool.Name)
            end
            key = key.Value

            local toolGameData = ToolUtility:GetGameDataByKey(key)
            local toolModelName = tool.Name
            tool.Name = toolGameData.Name
            if ToolTemplateTable[key] then
                Debug.Assert(false, "같은 키를 가진 도구가 있습니다. 키를 변경하세요 => " .. tostring(key) .. " => " .. toolModelName)
                return false
            end

            if not self:InitializeToolTemplate(tool) then
                Debug.Assert(false, "툴 템플릿 초기화에 실패했습니다. => " .. toolModelName)
                return false
            end

            ToolTemplateTable[key] = {Tool = tool, ToolGameData = toolGameData}
        end
    end
    
    self.ToolTemplateTable = ToolTemplateTable
    return true
end

function WorldInteractorSystem:GetClonedToolScript(toolType, tool)
    if not toolType or not tool then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    local targetScript = nil
    if ToolType.Weapon == toolType then
        targetScript = Utility:DeepCopy(WeaponController)
        if not targetScript:InitializeWeaponController(GameDataType.Tool, tool) then
            Debug.Assert(false, "비정상입니다.")
            return nil
        end
    elseif ToolType.Armor == toolType then

    elseif ToolType.Comsumable == toolType then
        
    end

    return targetScript
end

function WorldInteractorSystem:CreateTool(toolKey)
    if not toolKey then
        Debug.Assert(false, "툴 생성에 실패했습니다. => " .. tostring(toolKey))
        return nil
    end

    local createdTool = self:Create(toolKey) 
    if not createdTool then
        Debug.Assert(false, "툴 생성에 실패했습니다. => " .. tostring(toolKey))
        return nil
    end

    return createdTool
end

function WorldInteractorSystem:DestroyTool(tool)
    if not tool then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    local className = tool.ClassName
    if "Tool" ~= className then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if not self:Destroy(tool) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    return true
end

function WorldInteractorSystem:FindObjectJoints(tool)
    local joints = {}

    local trigger = tool.Handle.Trigger
    table.insert(joints, trigger)

    local mesh = tool:FindFirstChild("Mesh")
    local parts = mesh:GetChildren()
    for _, part in pairs(parts) do
        local joint = part:FindFirstChild("Joint")
        if not joint then
            continue
        end

        table.insert(joints, joint)
    end

    return joints
end

function WorldInteractorSystem:CreateImpl(toolKey)
    local targetTool = self.ToolTemplateTable[toolKey]

    if not targetTool then
        Debug.Assert(false, "툴이 존재하지 않습니다. 게임데이터만 있을 가능성이 높습니다. => " .. tostring(toolKey))
        return nil
    end

    local clonedTargetTool = targetTool.Tool:Clone()
	clonedTargetTool.Parent = nil

    return clonedTargetTool
end

function WorldInteractorSystem:PostCreateImpl(createdTool, toolKey)
    local targetScript = self:GetClonedToolScript(self.ToolTemplateTable[toolKey].ToolGameData.ToolType, createdTool)

     -- 없는 것도 존재할 수 있다.
    if targetScript then
        if not self:SetScript(createdTool, targetScript) then
            Debug.Assert(false, "비정상입니다.")
            return nil
        end
    end

    return createdTool
end

function WorldInteractorSystem:DestroyImpl(tool)
    return true
end

WorldInteractorSystem:Initialize()
return WorldInteractorSystem