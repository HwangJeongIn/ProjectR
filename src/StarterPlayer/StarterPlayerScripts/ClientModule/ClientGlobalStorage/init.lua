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

local ChangeGameDataCTS = RemoteEvents:WaitForChild("ChangeGameDataCTS")
local SelectToolCTS = RemoteEvents:WaitForChild("SelectToolCTS")
local EquipToolCTS = RemoteEvents:WaitForChild("EquipToolCTS")
local UnequipToolCTS = RemoteEvents:WaitForChild("UnequipToolCTS")
local SwapInventorySlotCTS = RemoteEvents:WaitForChild("SwapInventorySlotCTS")


local QuickSlots = require(script:WaitForChild("QuickSlots"))
local ClientGlobalStorage = CommonGlobalStorage
ClientGlobalStorage.QuickSlots = QuickSlots


function ClientGlobalStorage:Initialize(guiController)
	self:AddPlayer(LocalPlayer) -- 본인거는 서버도 통보안해준다.

	Debug.Assert(guiController, "비정상입니다.")
	--self.GuiController = guiController

	local ClientRemoteEventImpl = require(script:WaitForChild("ClientRemoteEventImpl"))
	ClientRemoteEventImpl:InitializeRemoteEvents(self, guiController)
end

function ClientGlobalStorage:SendSwapInventorySlot(slotIndex1, slotIndex2)
	local data = ClientGlobalStorage:GetData()
	local inventory = data[StatusType.Inventory]

	-- 서버로 올리기 전에 검증
	if nil == inventory:GetSlot(slotIndex1) 
	or nil == inventory:GetSlot(slotIndex2) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	SwapInventorySlotCTS:FireServer(slotIndex1, slotIndex2)
	return true
end


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

function ClientGlobalStorage:GetQuickSlot(slotIndex)
	local targetTool = self.QuickSlots:GetSlot(slotIndex)
	if nil == targetTool then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end
	
	return targetTool
end

function ClientGlobalStorage:SetQuickSlotByInventorySlot(quickSlotIndex, inventorySlotIndex)
	local targetTool = ClientGlobalStorage:GetInventorySlot(PlayerId, inventorySlotIndex)
	if nil == targetTool then
		Debug.Assert(false, "슬롯인덱스가 비정상입니다.")
		return false
	end

	if not self:SetQuickSlot(quickSlotIndex, targetTool) then
		Debug.Assert(false, "슬롯인덱스가 비정상입니다.")
		return false
	end
	return true
end

function ClientGlobalStorage:SetQuickSlot(slotIndex, tool)
	if not self.QuickSlots:SetSlot(slotIndex, tool) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	-- Gui 갱신
	if not self.GuiController:SetQuickToolSlot(slotIndex, tool) then
		Debug.Assert(false, "비정상입니다.")
		return
	end
	return true
end

function ClientGlobalStorage:SwapQuickSlot(slotIndex1, slotIndex2)
	if not self.QuickSlots:SwapSlot(slotIndex1, slotIndex2) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local tool1 = ClientGlobalStorage:GetQuickSlot(slotIndex1)
	if nil == tool1 then
		Debug.Assert(false, "슬롯인덱스가 비정상입니다.")
		return
	end

	local tool2 = ClientGlobalStorage:GetQuickSlot(slotIndex2)
	if nil == tool2 then
		Debug.Assert(false, "슬롯인덱스가 비정상입니다.")
		return false
	end


	--Gui 갱신
	if not self.GuiController:SetQuickToolSlot(slotIndex1, tool1) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if not self.GuiController:SetQuickToolSlot(slotIndex2, tool2) then
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
