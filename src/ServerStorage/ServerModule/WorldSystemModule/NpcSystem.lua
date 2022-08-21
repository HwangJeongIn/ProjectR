local ServerStorage = game:GetService("ServerStorage")
local ServerModuleFacade = require(ServerStorage:WaitForChild("ServerModuleFacade"))

local Debug = ServerModuleFacade.Debug
local Utility = ServerModuleFacade.Utility

local ObjectTagUtility = ServerModuleFacade.ObjectTagUtility
local ObjectCollisionGroupUtility = ServerModuleFacade.ObjectCollisionGroupUtility
local NpcUtility = ServerModuleFacade.NpcUtility

local ServerGlobalStorage = ServerModuleFacade.ServerGlobalStorage
local ServerEnum = ServerModuleFacade.ServerEnum

local GameDataType = ServerEnum.GameDataType

--local NpcType = ServerEnum.NpcType
--local NpcTypeConverter = NpcType.Converter
local Npcs = ServerStorage:WaitForChild("Npcs")

local NpcModule = ServerModuleFacade.NpcModule

local ServerModule = ServerStorage:WaitForChild("ServerModule")
local SystemModule = ServerModule:WaitForChild("WorldSystemModule")
local ObjectSystemBase = require(SystemModule:WaitForChild("ObjectSystemBase"))

local NpcSystem = {}

NpcSystem.__index = Utility.Inheritable__index
NpcSystem.__newindex = Utility.Inheritable__newindex
setmetatable(NpcSystem, Utility:DeepCopy(ObjectSystemBase))

function NpcSystem:InitializeNpcTemplate(npc)
    return true
end

function NpcSystem:Initialize()
    local npcTemplateTable = {}

    local allNpcFolders = Npcs:GetChildren()
    for _, targetNpcFolder in pairs(allNpcFolders) do

        local targetNpcFolderNpcs = targetNpcFolder:GetChildren()
        for _, npc in pairs(targetNpcFolderNpcs) do

            local npcName = npc.Name
            local key = NpcUtility:GetGameDataKey(npc)
            if not key then
                Debug.Assert(false, "Npc에 키가 없습니다. => " .. npcName)
                return false
            end
            
            if npcTemplateTable[key] then
                Debug.Assert(false, "같은 키를 가진 도구가 있습니다. 키를 변경하세요 => " .. tostring(key) .. " => " .. npcName)
                return false
            end

            if not self:InitializeNpcTemplate(npc) then
                Debug.Assert(false, "툴 템플릿 초기화에 실패했습니다. => " .. npcName)
                return false
            end

            local npcGameData = NpcUtility:GetGameDataByKey(key)
            --ObjectTagUtility:AddTag(npc, NpcTypeConverter[npcGameData.NpcType])
            if not ObjectCollisionGroupUtility:SetNpcCollisionGroup(npc) then
                Debug.Assert(false, "SetWorldInteractorCollisionGroup에 실패했습니다. => " .. npcName)
                return false
            end
            
            npcTemplateTable[key] = {Npc = npc, NpcGameData = npcGameData}
        end
    end
    
    self.NpcTemplateTable = npcTemplateTable
    return true
end

NpcSystem:Initialize()
return NpcSystem