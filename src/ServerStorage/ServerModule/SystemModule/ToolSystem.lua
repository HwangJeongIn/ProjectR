local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))

local Debug = CommonModuleFacade.Debug
local Utility = CommonModuleFacade.Utility

local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = ServerStorage:WaitForChild("ServerModuleFacade")

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage
local ServerEnum = ServerModuleFacade.ServerEnum

local ToolType = ServerEnum.ToolType
local ToolTypeConverter = ToolType.Converter
local Tools = ServerStorage:WaitForChild("Tools")

local ToolModule = ServerModuleFacade.ToolModule
local DamagerController = ToolModule:WaitForChild("DamagerController")

local ServerModule = ServerStorage:WaitForChild("ServerModule")
local SystemModule = ServerModule:WaitForChild("SystemModule")
local ObjectSystemBase = SystemModule:WaitForChild("ObjectSystemBase")

--[[
local ServerConstant = ServerModuleFacade.ServerConstant
local MaxPickupDistance = ServerConstant.MaxPickupDistance
local MaxDropDistance = ServerConstant.MaxDropDistance
local EquipTypeToBoneMappingTable = ServerConstant.EquipTypeToBoneMappingTable

local GameDataType = ServerEnum.GameDataType
local StatusType = ServerEnum.StatusType
local EquipType = ServerEnum.EquipType
--]]
local ToolSystem = {
}

ToolSystem.__index = Utility.Inheritable__index
ToolSystem.__newindex = Utility.Inheritable__newindex
setmetatable(ToolSystem, Utility.DeepCopy(ObjectSystemBase))

function ToolSystem:InitializeToolTemplate(tool)
    if not tool then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    local key = tool:FindFirstChild("Key")
    if not key then
        Debug.Assert(false, "도구에 Key 정보가 없습니다. => " .. tool.Name)
        return false
    end

    local handle = tool:FindFirstChild("Handle")
    if not handle then
        Debug.Assert(false, "도구에 핸들이 없습니다. => " .. tool.Name)
        return false
    end

    local mesh = tool:FindObjectJoints("Mesh")
    if not mesh then
        Debug.Assert(false, "메시 정보가 없습니다. => " .. tool.Name)
        return false
    end

    local parts = mesh:FindFirstChild("Parts")
    if not parts then
        Debug.Assert(false, "파츠 정보가 없습니다. => " .. tool.Name)
        return false
    end

    local trigger = handle:FindFirstChild("Trigger")
    if not trigger then
        Debug.Assert(false, "도구에 트리거가 없습니다. => " .. tool.Name)
        return false
    end

    if tool.CanBeDropped then
        Debug.Print("CanBeDropped가 켜져있습니다. 자동으로 꺼집니다. => " .. tool.Name)
        tool.CanBeDropped = false
    end

    if handle.CanTouch then
        Debug.Print("CanTouch가 켜져있습니다. 자동으로 꺼집니다. => " .. tool.Name)
        handle.CanTouch = false
    end

    if trigger.CanCollide then
        Debug.Print("Trigger에 CanCollide가 켜져있습니다. 자동으로 꺼집니다. => " .. tool.Name)
        trigger.CanCollide = false
        trigger.CanQuery = true
    end

    return true
end

function ToolSystem:Initialize()
    local ToolTemplateTable = {}

    local toolTypeCount = #ToolType - 1
    for toolType = 1, toolTypeCount do
        local targetToolFolderName = ToolTypeConverter[toolType] .. "s"
        local targetToolFolder = Tools:WaitForChild(targetToolFolderName)
        if not targetToolFolder then
            Debug.Assert(false, "해당 이름의 툴폴더가 없습니다. => " .. targetToolFolderName)
            return false
        end

        ToolTemplateTable[toolType] = {}
        for _, tool in pairs(targetToolFolder) do
            local toolName = tool.Name
            if ToolTemplateTable[toolName] then
                Debug.Assert(false, "툴이름이 동일합니다. 변경해야합니다. => " .. targetToolFolderName .. " => " .. toolName)
                return false
            end

            if not self:InitializeToolTemplate(tool) then
                Debug.Assert(false, "툴 템플릿 초기화에 실패했습니다. => " .. toolName)
                return false
            end

            ToolTemplateTable[toolName] = tool
        end
    end
    
    self.ToolTemplateTable = ToolTemplateTable
    return true
end

function ToolSystem:GetClonedToolScript(toolType, tool)
    if not toolType or not tool then
        Debug.Assert(false, "비정상입니다.")
        return nil
    end

    local targetScript = nil
    if ToolType.Weapon == toolType then
        
    elseif ToolType.Armor == toolType then

    elseif ToolType.Comsumable == toolType then
        
    end

    return targetScript
end

function ToolSystem:CreateTool(toolType, toolName)
    if not toolType or toolName then
        Debug.Assert(false, "툴 생성에 실패했습니다. => " .. tostring(toolType) .. " : " .. toolName)
        return nil
    end

    local createdTool = self:Create(toolType, toolName) 
    if not createdTool then
        Debug.Assert(false, "툴 생성에 실패했습니다. => " .. tostring(toolType) .. " : " .. toolName)
        return nil
    end

    return createdTool
end

function ToolSystem:DestroyTool(tool)
    if not tool then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    local typeString = type(tool)
    if "Tool" ~= typeString then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    if not self:Destroy(tool) then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    return true
end

function ToolSystem:FindObjectJoints(tool)
    local joints = {}

    local handle = tool:FindFirstChild("Handle")
    table.insert(joints, handle)

    local mesh = tool:FindObjectJoints("Mesh")
    local parts = mesh:FindFirstChild("Parts")

    for _, part in pairs(parts) do
        local joint = part:FindfirstChild("Joint")
        if not joint then
            continue
        end

        table.insert(joints, joint)
    end

    return joints
end

function ToolSystem:CreateImpl(toolType, toolName)
    local targetToolFolder = self.ToolTemplateTable[toolType]
    if not targetToolFolder then
        Debug.Assert(false, "해당 툴타입 관련 툴폴더가 없습니다. => " .. tostring(toolType))
        return nil
    end

    local targetTool = targetToolFolder[toolName]
    if not targetTool then
        Debug.Assert(false, "툴이 없습니다. => " .. toolName)
        return nil
    end
    
    local clonedTargetTool = targetTool:Clone()
	clonedTargetTool.Parent = nil

    return clonedTargetTool
end

function ToolSystem:PostCreateImpl(createdTool, toolType, toolName)
    local targetScript = self:GetClonedToolScript(toolType, createdTool)

     -- 없는 것도 존재할 수 있다.
    if targetScript then
        if not self:SetScript(createdTool, targetScript) then
            Debug.Assert(false, "비정상입니다.")
            return nil
        end
    end

    return createdTool
end

function ToolSystem:DestroyImpl(tool)
    return true
end

ToolSystem:Initialize()
return ToolSystem