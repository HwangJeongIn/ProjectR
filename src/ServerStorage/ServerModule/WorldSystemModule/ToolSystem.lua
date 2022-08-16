local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local Utility = ServerModuleFacade.Utility
local ToolUtility = ServerModuleFacade.ToolUtility
local ObjectTagUtility = ServerModuleFacade.ObjectTagUtility

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

--[[
local ServerConstant = ServerModuleFacade.ServerConstant
local MaxPickupDistance = ServerConstant.MaxPickupDistance
local MaxDropDistance = ServerConstant.MaxDropDistance
local EquipTypeToBoneMappingTable = ServerConstant.EquipTypeToBoneMappingTable

local GameDataType = ServerEnum.GameDataType
local StatusType = ServerEnum.StatusType
local EquipType = ServerEnum.EquipType
--]]
local ToolSystem = {}--Utility:DeepCopy(ObjectSystemBase)

ToolSystem.__index = Utility.Inheritable__index
ToolSystem.__newindex = Utility.Inheritable__newindex
setmetatable(ToolSystem, Utility:DeepCopy(ObjectSystemBase))

function ToolSystem:InitializeToolTemplate(tool)
    if not tool then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    --[[
    local key = tool:FindFirstChild("Key")
    if not key then
        Debug.Assert(false, "도구에 Key 정보가 없습니다. => " .. tool.Name)
        return false
    end
    --]]

    local handle = tool:FindFirstChild("Handle")
    if not handle then
        Debug.Assert(false, "도구에 핸들이 없습니다. => " .. tool.Name)
        return false
    end

    local mesh = tool:FindFirstChild("Mesh")
    if not mesh then
        Debug.Assert(false, "메시 정보가 없습니다. => " .. tool.Name)
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

    local allToolFolders = Tools:GetChildren()
    for _, targetToolFolder in pairs(allToolFolders) do

        local targetToolFolderTools = targetToolFolder:GetChildren()
        for _, tool in pairs(targetToolFolderTools) do

            local toolName = tool.Name
            local key = ToolUtility:GetGameDataKey(tool)
            if not key then
                Debug.Assert(false, "도구에 키가 없습니다. => " .. toolName)
                return false
            end
            
            if ToolTemplateTable[key] then
                Debug.Assert(false, "같은 키를 가진 도구가 있습니다. 키를 변경하세요 => " .. tostring(key) .. " => " .. toolName)
                return false
            end

            if not self:InitializeToolTemplate(tool) then
                Debug.Assert(false, "툴 템플릿 초기화에 실패했습니다. => " .. toolName)
                return false
            end

            local toolGameData = ToolUtility:GetGameDataByKey(key)
            ObjectTagUtility:AddTag(tool, ToolTypeConverter[toolGameData.ToolType])
            ToolTemplateTable[key] = {Tool = tool, ToolGameData = toolGameData}
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

function ToolSystem:ActivateToolSkill(tool, skillIndex)
    if not tool or skillIndex then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    local toolScript = self:GetScript(tool)
    if not toolScript then
        Debug.Assert(false, "비정상입니다.")
        return false
    end

    스킬 사용

    return true
end

function ToolSystem:CreateTool(toolKey)
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

function ToolSystem:DestroyTool(tool)
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

function ToolSystem:FindObjectJoints(tool)
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

function ToolSystem:CreateImpl(toolKey)
    local targetTool = self.ToolTemplateTable[toolKey]

    if not targetTool then
        Debug.Assert(false, "툴이 존재하지 않습니다. 게임데이터만 있을 가능성이 높습니다. => " .. tostring(toolKey))
        return nil
    end

    local clonedTargetTool = targetTool.Tool:Clone()
	clonedTargetTool.Parent = nil

    return clonedTargetTool
end

function ToolSystem:PostCreateImpl(createdTool, toolKey)
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

function ToolSystem:DestroyImpl(tool)
    return true
end

ToolSystem:Initialize()
return ToolSystem