local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModuleFacade = require(ReplicatedStorage:WaitForChild("CommonModuleFacade"))
local Debug = CommonModuleFacade.Debug
local Utility = CommonModuleFacade.Utility
local ToolUtility = CommonModuleFacade.ToolUtility


local CommonConstant = CommonModuleFacade.CommonConstant
local MaxPickupDistance = CommonConstant.MaxPickupDistance

local CommonEnum = CommonModuleFacade.CommonEnum
local GameDataType = CommonEnum.GameDataType
local StatusType = CommonEnum.StatusType
local ToolType = CommonEnum.ToolType
local EquipType = CommonEnum.EquipType

local CommonGameDataManager = CommonModuleFacade.CommonGameDataManager
local CommonGlobalStorage = CommonModuleFacade.CommonGlobalStorage

local LocalPlayer = game.Players.LocalPlayer
local PlayerId = LocalPlayer.UserId

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local ChangeGameDataCTS = RemoteEvents:WaitForChild("ChangeGameDataCTS")
local SelectToolCTS = RemoteEvents:WaitForChild("SelectToolCTS")
local EquipToolCTS = RemoteEvents:WaitForChild("EquipToolCTS")
local UnequipToolCTS = RemoteEvents:WaitForChild("UnequipToolCTS")
local SwapInventorySlotCTS = RemoteEvents:WaitForChild("SwapInventorySlotCTS")

local DropSelectedToolCTS = RemoteEvents:WaitForChild("DropSelectedToolCTS")
local DropToolCTS = RemoteEvents:WaitForChild("DropToolCTS")
local PickupToolCTS = RemoteEvents:WaitForChild("PickupToolCTS")
local ActivateToolSkillCTS = RemoteEvents:WaitForChild("ActivateToolSkillCTS")

local QuickSlots = require(script:WaitForChild("QuickSlots"))
local ClientGlobalStorage = CommonGlobalStorage
ClientGlobalStorage.QuickSlots = QuickSlots

ClientGlobalStorage.__index = Utility.Inheritable__index
ClientGlobalStorage.__newindex = Utility.Inheritable__newindex
--setmetatable(ClientGlobalStorage, CommonGlobalStorage)


function ClientGlobalStorage:Initialize(guiController)
	if not guiController then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	-- 본인거는 서버도 통보안해준다.
	if not self:AddPlayer(LocalPlayer) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	--self.GuiController = guiController
	local ClientRemoteEventImpl = require(script:WaitForChild("ClientRemoteEventImpl"))
	ClientRemoteEventImpl:InitializeRemoteEvents(self, guiController)
	return true
end

function ClientGlobalStorage:SendActivateToolSkill(tool, skillIndex)
	if not tool or not skillIndex then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local toolGameData = ToolUtility:GetGameData(tool)
	local equipType = toolGameData.EquipType
	if not equipType then
		Debug.Assert(false, "장착할 수 있는 장비만 스킬을 사용할 수 있습니다.")
		return false
	end

	 if toolGameData.SkillCount < skillIndex or 0 >= skillIndex then
		Debug.Assert(false, "스킬인덱스가 비정상입니다. => " .. tostring(skillIndex))
		return false
	 end

	-- 장착 검증
	if not self:IsInCharacter(PlayerId, equipType, tool) then
		Debug.Assert(false, "캐릭터가 해당 도구를 장착하고 있지 않습니다.")
		return false
	end

	ActivateToolSkillCTS:FireServer(tool, skillIndex)
	return true
end

function ClientGlobalStorage:SendDropTool(tool)
	if not tool then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	-- Backpack에 존재하는 지 검증
	if not self:IsInBackpack(PlayerId, tool) then
		Debug.Assert(false, "캐릭터가 해당 도구를 가지고 있지 않습니다.")
		return false
	end

	DropToolCTS:FireServer(tool)
	return true
end

function ClientGlobalStorage:SendDropSelectedTool(tool)
	if not tool then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	-- 지금 선택된 상태인지 검증
	if not self:IsInCharacterRaw(PlayerId, tool) then
		Debug.Assert(false, "캐릭터가 해당 도구를 들고 있지 않습니다.")
		return false
	end

	DropSelectedToolCTS:FireServer(tool)
	return true
end

function ClientGlobalStorage:SendPickupTool(tool)
	if not tool then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local distance = LocalPlayer:DistanceFromCharacter(tool.Handle.Position)
	if distance > MaxPickupDistance then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	PickupToolCTS:FireServer(tool)
	return true
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


function ClientGlobalStorage:SendSelectToolCTS(--[[slotIndex,--]] tool)
	if --[[not slotIndex or--]] not tool then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	SelectToolCTS:FireServer(--[[slotIndex,--]] tool)
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

function ClientGlobalStorage:ClearQuickSlotIfExist(tool)
	if nil == tool then
		Debug.Assert(false, "슬롯인덱스가 비정상입니다.")
		return false
	end

	local slotIndex = self.QuickSlots:GetSlotIndex(tool)
	if not slotIndex then
		return true
	end

	if not self:SetQuickSlot(slotIndex, nil) then
		Debug.Assert(false, "비정상입니다.")
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

return ClientGlobalStorage
