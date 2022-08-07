local ClientRemoteEventImpl = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")
local Debug = require(CommonModule:WaitForChild("Debug"))

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
--local GameDataType = CommonEnum.GameDataType
local StatusType = CommonEnum.StatusType
--local ToolType = CommonEnum.ToolType
--local EquipType = CommonEnum.EquipType

local LocalPlayer = game.Players.LocalPlayer
local PlayerId = LocalPlayer.UserId

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- STC
local ChangeGameStateSTC = RemoteEvents:WaitForChild("ChangeGameStateSTC")
local NotifyWinnerSTC = RemoteEvents:WaitForChild("NotifyWinnerSTC")
local AddToolSTC = RemoteEvents:WaitForChild("AddToolSTC")
local RemoveToolSTC = RemoteEvents:WaitForChild("RemoveToolSTC")
local EquipToolSTC = RemoteEvents:WaitForChild("EquipToolSTC")
local UnequipToolSTC = RemoteEvents:WaitForChild("UnequipToolSTC")
local SwapInventorySlotSTC = RemoteEvents:WaitForChild("SwapInventorySlotSTC")


function ClientRemoteEventImpl:InitializeRemoteEvents(ClientGlobalStorage, GuiController)
	ClientGlobalStorage.GuiController = GuiController
	-- STC
	SwapInventorySlotSTC.OnClientEvent:Connect(function(slotIndex1, slotIndex2)
		Debug.Assert(slotIndex1, "장착 슬롯 비정상")
		Debug.Assert(slotIndex2, "도구 비정상")
		
		if not ClientGlobalStorage:SwapInventorySlot(PlayerId, slotIndex1, slotIndex2) then
			Debug.Assert(false, "인벤토리 슬롯을 스왑하지 못했습니다.")
			return
		end

		local tool1 = ClientGlobalStorage:GetInventorySlot(PlayerId, slotIndex1)
		if nil == tool1 then
			Debug.Assert(false, "슬롯인덱스가 비정상입니다.")
			return
		end

		local tool2 = ClientGlobalStorage:GetInventorySlot(PlayerId, slotIndex2)
		if nil == tool2 then
			Debug.Assert(false, "슬롯인덱스가 비정상입니다.")
			return
		end

		if not GuiController:SetInventoryToolSlot(slotIndex1, tool1) then
			Debug.Assert(false, "비정상입니다.")
			return
		end

		if not GuiController:SetInventoryToolSlot(slotIndex2, tool2) then
			Debug.Assert(false, "비정상입니다.")
			return
		end
	end)

	EquipToolSTC.OnClientEvent:Connect(function(equipType, tool)
		Debug.Assert(equipType, "장착 슬롯 비정상")
		Debug.Assert(tool, "도구 비정상")
		
		local prevTool, currentTool = ClientGlobalStorage:EquipTool(PlayerId, equipType, tool)
		if not currentTool then
			Debug.Assert(false, "장착하지 못했습니다.")
			return
		end

		if not GuiController:SetEquipToolSlot(equipType, tool) then
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

		if not GuiController:SetEquipToolSlot(equipType, nil) then
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

		if not GuiController:SetInventoryToolSlot(slotIndex, tool) then
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

		if not GuiController:SetInventoryToolSlot(slotIndex, nil) then
			Debug.Assert(false, "비정상입니다.")
			return
		end
	end)

	NotifyWinnerSTC.OnClientEvent:Connect(function(winnerType, winnerName, winnerReward)
		GuiController:SetWinnerMessage(winnerType, winnerName, winnerReward)
	end)

	ChangeGameStateSTC.OnClientEvent:Connect(function(gameState, ...)
		GuiController:ChangeGameState(gameState, {...})
	end)

end


return ClientRemoteEventImpl