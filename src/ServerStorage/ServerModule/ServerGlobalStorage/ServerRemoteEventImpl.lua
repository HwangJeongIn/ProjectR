local ServerRemoteEventImpl = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonModuleFacade.Debug
local ToolUtility = CommonModuleFacade.ToolUtility

local CommonConstant = CommonModuleFacade.CommonConstant
local MaxPickupDistance = CommonConstant.MaxPickupDistance

local CommonEnum = CommonModuleFacade.CommonEnum

local EquipType = CommonEnum.EquipType

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- STC
--local AddToolSTC = RemoteEvents:WaitForChild("AddToolSTC")
--local RemoveToolSTC = RemoteEvents:WaitForChild("RemoveToolSTC")
local EquipToolSTC = RemoteEvents:WaitForChild("EquipToolSTC")
local UnequipToolSTC = RemoteEvents:WaitForChild("UnequipToolSTC")
local SwapInventorySlotSTC = RemoteEvents:WaitForChild("SwapInventorySlotSTC")

-- CTS
local SelectToolCTS = RemoteEvents:WaitForChild("SelectToolCTS")
local EquipToolCTS = RemoteEvents:WaitForChild("EquipToolCTS")
local UnequipToolCTS = RemoteEvents:WaitForChild("UnequipToolCTS")
local SwapInventorySlotCTS = RemoteEvents:WaitForChild("SwapInventorySlotCTS")
local PickupToolCTS = RemoteEvents:WaitForChild("PickupToolCTS")
local DropToolCTS = RemoteEvents:WaitForChild("DropToolCTS")
local DropSelectedToolCTS = RemoteEvents:WaitForChild("DropSelectedToolCTS")


function ServerRemoteEventImpl:InitializeRemoteEvents(ServerGlobalStorage)

    DropToolCTS.OnServerEvent:Connect(function(player, tool)
        if not ServerGlobalStorage:DropTool(player, tool) then
            Debug.Assert(false, "비정상입니다.")
            return
        end
    end)

    DropSelectedToolCTS.OnServerEvent:Connect(function(player, tool)
        if not ServerGlobalStorage:DropSelectedTool(player, tool) then
            Debug.Assert(false, "비정상입니다.")
            return
        end
    end)

    PickupToolCTS.OnServerEvent:Connect(function(player, tool)

        if not ServerGlobalStorage:SelectWorkspaceTool(player, tool) then
            Debug.Assert(false, "비정상입니다.")
            return
        end
    end)

    SwapInventorySlotCTS.OnServerEvent:Connect(function(player, slotIndex1, slotIndex2)
        
        local playerId = player.UserId
        if not ServerGlobalStorage:SwapInventorySlot(playerId, slotIndex1, slotIndex2) then
            Debug.Assert(false, "비정상입니다.")
            return
        end

        SwapInventorySlotSTC:FireClient(player, slotIndex1, slotIndex2)
    end)

    UnequipToolCTS.OnServerEvent:Connect(function(player, equipType)
        if not equipType then
            Debug.Assert(false, "비정상입니다.")
            return
        end
    
        local character = player.Character
        if not character then
            Debug.Print("플레이어 캐릭터가 존재하지 않습니다. 장착 해제할 수 없습니다.")
            return
        end
        
        local playerId = player.UserId
        if not ServerGlobalStorage:IsInCharacterByEquipType(playerId, equipType) then
            Debug.Assert(false, "비정상입니다.")
            return
        end
        
        local prevTool = nil
        if equipType == EquipType.Weapon then
            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid then
                Debug.Print("캐릭터의 휴머노이드가 존재하지 않습니다. 있을 수 있는 상황입니다.")
                return
            end
    
            prevTool = ServerGlobalStorage:UnequipTool(playerId, equipType)
            if not prevTool then
                Debug.Assert(false, "비정상입니다.")
                return
            end
    
            humanoid:UnequipTools()
        else
            prevTool = ServerGlobalStorage:UnequipTool(playerId, equipType)
            if not prevTool then
                Debug.Assert(false, "비정상입니다.")
                return
            end
    
            if not ServerGlobalStorage:DetachArmorFromPlayer(player, prevTool) then
                Debug.Assert(false, "비정상입니다.")
                return
            end
        end
    
        UnequipToolSTC:FireClient(player, equipType)
    end)
    
    EquipToolCTS.OnServerEvent:Connect(function(player, equipType, tool)
        if not equipType or not tool then
            Debug.Assert(false, "비정상입니다.")
            return
        end
    
        local finalEquipType = ToolUtility:GetEquipType(tool)
        if finalEquipType ~= equipType then
            Debug.Assert(false, "클라이언트에서 보낸 정보와 실제 정보가 다릅니다.")
            return
        end
    
        local character = player.Character
        if not character then
            Debug.Print("플레이어 캐릭터가 존재하지 않습니다. 장착할 수 없습니다.")
            return
        end

        local playerId = player.UserId
        if not ServerGlobalStorage:IsInBackpack(playerId, tool) then
            Debug.Assert(false, "비정상입니다.")
            return
        end
    
        local prevTool = nil
        local currentTool = nil
    
        --[[
            * 무기의 경우
                Roblox의 EquipTool 호출 시 알아서 Character 하위로 옮겨진다.
                Roblox의 EquipTool 호출 시 이전에 장착중인 Tool은 Player.Backpack으로 옮겨진다.
    
            * 방어구의 경우(자체 구현)
                무기에서 하는 것들을 행동을 수동으로 해줘야 한다.
        --]]
        if equipType == EquipType.Weapon then
            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid then
                Debug.Print("캐릭터의 휴머노이드가 존재하지 않습니다. 있을 수 있는 상황입니다.")
                return
            end
    
            prevTool, currentTool = ServerGlobalStorage:EquipTool(playerId, equipType, tool)
            if not currentTool then
                Debug.Assert(false, "비정상입니다.")
                return
            end
            
            humanoid:EquipTool(tool)
        else
            prevTool, currentTool = ServerGlobalStorage:EquipTool(playerId, equipType, tool)
            if not currentTool then
                Debug.Assert(false, "비정상입니다.")
                return
            end
    
            if prevTool then
                if not ServerGlobalStorage:DetachArmorFromPlayer(player, prevTool) then
                    Debug.Assert(false, "비정상입니다.")
                    return
                end
            end
    
            if not ServerGlobalStorage:AttachArmorToPlayer(player, currentTool) then
                Debug.Assert(false, "비정상입니다.")
                return
            end
        end
        
        EquipToolSTC:FireClient(player, equipType, tool)
    end)
    
    SelectToolCTS.OnServerEvent:Connect(function(player, inventorySlotIndex, tool)
        if not inventorySlotIndex or not tool then
            Debug.Assert(false, "비정상입니다.")
            return
        end

        if not ServerGlobalStorage:SelectTool(player, tool, false) then
            Debug.Assert(false, "비정상입니다.")
            return
        end
    end)
end

return ServerRemoteEventImpl