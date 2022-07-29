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
local ArmorType = CommonEnum.ArmorType

local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local CommonGameDataManager = require(CommonGameDataModule:WaitForChild("CommonGameDataManager"))

local CommonGlobalStorage = require(CommonModule:WaitForChild("CommonGlobalStorage"))
local LocalPlayer = game.Players.LocalPlayer
local PlayerId = LocalPlayer.UserId


local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local GuiController = require(PlayerGui:WaitForChild("GuiController"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local ChangeGameStateSTC = RemoteEvents:WaitForChild("ChangeGameStateSTC")
local NotifyWinnerSTC = RemoteEvents:WaitForChild("NotifyWinnerSTC")
local ChangeGameDataCTS = RemoteEvents:WaitForChild("ChangeGameDataCTS")
local SetInventorySlotSTC = RemoteEvents:WaitForChild("SetInventorySlotSTC")
--local AddPlayerSTC = RemoteEvents:WaitForChild("AddPlayerSTC")

local ClientGlobalStorage = CommonGlobalStorage

NotifyWinnerSTC.OnClientEvent:Connect(function(winnerType, winnerName, winnerReward)
	GuiController:OnNotifyWinnerSTC(winnerType, winnerName, winnerReward)
end)

ChangeGameStateSTC.OnClientEvent:Connect(function(gameState, ...)
	GuiController:OnChangeGameStateSTC(gameState, {...})
end)

SetInventorySlotSTC.OnClientEvent:Connect(function(slotIndex, tool)
	
	Debug.Assert(slotIndex, "슬롯 인덱스 비정상")
	Debug.Assert(tool, "도구 비정상")
	
	local data = ClientGlobalStorage:GetData()
	local inventory = data[StatusType.Inventory]

	if not inventory:SetTool(slotIndex, tool) then
		Debug.Assert(false, "비정상입니다.")
		return
	end

	GuiController:OnSetInventorySlotSTC(slotIndex, tool)
end)









function ClientGlobalStorage:Initialize()
	self:SetClientMode()
	self:AddPlayer(LocalPlayer) -- 본인거는 서버도 통보안해준다.
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

ClientGlobalStorage:Initialize()

return ClientGlobalStorage
