local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")
local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))

local CommonConstant = require(CommonModule:WaitForChild("CommonConstant"))
local MaxQuickSlotCount = CommonConstant.MaxQuickSlotCount

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType
local StatusType = CommonEnum.StatusType
local ToolType = CommonEnum.ToolType
local EquipType = CommonEnum.EquipType

local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local CommonGameDataManager = require(CommonGameDataModule:WaitForChild("CommonGameDataManager"))

local CommonGlobalStorage = require(CommonModule:WaitForChild("CommonGlobalStorage"))
local LocalPlayer = game.Players.LocalPlayer
local PlayerId = LocalPlayer.UserId

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- CTS
local ChangeGameDataCTS = RemoteEvents:WaitForChild("ChangeGameDataCTS")
local SelectToolCTS = RemoteEvents:WaitForChild("SelectToolCTS")
local EquipToolCTS = RemoteEvents:WaitForChild("EquipToolCTS")
local UnequipToolCTS = RemoteEvents:WaitForChild("UnequipToolCTS")

-- STC
local ChangeGameStateSTC = RemoteEvents:WaitForChild("ChangeGameStateSTC")
local NotifyWinnerSTC = RemoteEvents:WaitForChild("NotifyWinnerSTC")
local AddToolSTC = RemoteEvents:WaitForChild("AddToolSTC")
local RemoveToolSTC = RemoteEvents:WaitForChild("RemoveToolSTC")
local EquipToolSTC = RemoteEvents:WaitForChild("EquipToolSTC")
local UnequipToolSTC = RemoteEvents:WaitForChild("UnequipToolSTC")

local ClientGlobalStorage = CommonGlobalStorage

-- 초기화 코드
function ClientGlobalStorage:RegisterOnClientEvent(guiController)
	-- STC
	EquipToolSTC.OnClientEvent:Connect(function(equipType, tool)
		Debug.Assert(equipType, "장착 슬롯 비정상")
		Debug.Assert(tool, "도구 비정상")
		
		local prevTool, currentTool = ClientGlobalStorage:EquipTool(PlayerId, equipType, tool)
		if not currentTool then
			Debug.Assert(false, "장착하지 못했습니다.")
			return
		end

		if not guiController:SetEquipToolSlot(equipType, tool) then
			Debug.Assert(false, "비정상입니다.")
			return
		end
	end)

	UnequipToolSTC.OnClientEvent:Connect(function(equipType)
		Debug.Assert(equipType, "장착 슬롯 비정상")

		local prevTool = ClientGlobalStorage:UnequipTool(PlayerId, equipType)
		if not prevTool then
			Debug.Assert(false, "장착 해제하지 못했습니다.")
			return
		end

		if not guiController:SetEquipToolSlot(equipType, nil) then
			Debug.Assert(false, "비정상입니다.")
			return
		end
	end)

	AddToolSTC.OnClientEvent:Connect(function(slotIndex, tool)
		
		Debug.Assert(slotIndex, "슬롯 인덱스 비정상")
		Debug.Assert(tool, "도구 비정상")
		
		local data = ClientGlobalStorage:GetData()
		local inventory = data[StatusType.Inventory]

		if not inventory:AddToolToSlot(slotIndex, tool) then
			Debug.Assert(false, "비정상입니다.")
			return
		end

		if not guiController:SetInventoryToolSlot(slotIndex, tool) then
			Debug.Assert(false, "비정상입니다.")
			return
		end
	end)

	RemoveToolSTC.OnClientEvent:Connect(function(slotIndex, tool)
		
		Debug.Assert(slotIndex, "슬롯 인덱스 비정상")
		Debug.Assert(tool, "도구 비정상")
		
		local data = ClientGlobalStorage:GetData()
		local inventory = data[StatusType.Inventory]

		if not inventory:RemoveToolFromSlot(slotIndex, tool) then
			Debug.Assert(false, "비정상입니다.")
			return
		end

		if not guiController:SetInventoryToolSlot(slotIndex, nil) then
			Debug.Assert(false, "비정상입니다.")
			return
		end
	end)

	NotifyWinnerSTC.OnClientEvent:Connect(function(winnerType, winnerName, winnerReward)
		guiController:SetWinnerMessage(winnerType, winnerName, winnerReward)
	end)

	ChangeGameStateSTC.OnClientEvent:Connect(function(gameState, ...)
		guiController:ChangeGameState(gameState, {...})
	end)

end

function ClientGlobalStorage:Initialize(guiController)
	self:SetClientMode()
	self:AddPlayer(LocalPlayer) -- 본인거는 서버도 통보안해준다.

	Debug.Assert(guiController, "비정상입니다.")
	self.GuiController = guiController

	self:RegisterOnClientEvent(guiController)
end


-- CTS
function ClientGlobalStorage:SendSelectToolCTS(slotIndex, tool)
	if not slotIndex or not tool then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	SelectToolCTS:FireServer(slotIndex, tool)
	return true
end

function ClientGlobalStorage:SendEquipToolCTS(equipType, tool)
	if not equipType or not tool then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	EquipToolCTS:FireServer(equipType, tool)
	return true
end

function ClientGlobalStorage:SendUnequipToolCTS(equipType)
	if not equipType then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	UnequipToolCTS:FireServer(equipType)
	return true
end


function ClientGlobalStorage:GetData()
	return self.PlayerTable[PlayerId]
end

function ClientGlobalStorage:CheckQuickSlotIndex(quickSlotIndex)
	if MaxQuickSlotCount < quickSlotIndex or quickSlotIndex < 1 then
		Debug.Assert(false, "슬롯인덱스가 비정상입니다. [QuickSlot] => " .. tostring(quickSlotIndex))
		return false
	end
	
	return true
end


function ClientGlobalStorage:GetQuickSlot(quickSlotIndex)
	if self:CheckQuickSlotIndex(quickSlotIndex) == false then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end
	
	local data = self:GetData()
	return data[StatusType.QuickSlot][quickSlotIndex]
end

function ClientGlobalStorage:SetQuickSlot(quickSlotIndex, tool)
	
	if self:CheckQuickSlotIndex(quickSlotIndex) == false then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	if not tool then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	local data = self:GetData()
	data[StatusType.QuickSlot][quickSlotIndex] = tool
end

function ClientGlobalStorage:SwapQuickSlot(quickSlotIndex1, quickSlotIndex2)
	if self:CheckQuickSlotIndex(quickSlotIndex1) == false or self:CheckQuickSlotIndex(quickSlotIndex2) == false then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local tool1 = self:GetQuickSlot(quickSlotIndex1)
	local tool2 = self:GetQuickSlot(quickSlotIndex2)
	
	if self:SetQuickSlot(quickSlotIndex1, tool2) == false or self:SetQuickSlot(quickSlotIndex2, tool1) == false then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	return true
end

ClientGlobalStorage.__index = Utility.Inheritable__index
ClientGlobalStorage.__newindex = Utility.Inheritable__newindex
--setmetatable(ClientGlobalStorage, CommonGlobalStorage)

--ClientGlobalStorage:Initialize()
return ClientGlobalStorage
