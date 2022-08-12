local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommonModule = ReplicatedStorage:WaitForChild("CommonModule")
local Debug = require(CommonModule:WaitForChild("Debug"))
local Utility = require(CommonModule:WaitForChild("Utility"))

local CommonConstant = require(CommonModule:WaitForChild("CommonConstant"))
local MaxInventorySlotCount = CommonConstant.MaxInventorySlotCount

local CommonEnum = require(CommonModule:WaitForChild("CommonEnum"))
local GameDataType = CommonEnum.GameDataType
local StatusType = CommonEnum.StatusType
local ToolType = CommonEnum.ToolType
local EquipType = CommonEnum.EquipType

local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local CommonGameDataManager = require(CommonGameDataModule:WaitForChild("CommonGameDataManager"))

local CommonObjectUtilityModule = CommonModule:WaitForChild("CommonObjectUtilityModule")
local ToolUtility = require(CommonObjectUtilityModule:WaitForChild("ToolUtility"))

local Inventory = require(script:WaitForChild("Inventory"))
local EquipSlots = require(script:WaitForChild("EquipSlots"))
local PlayerStatistic = require(script:WaitForChild("PlayerStatistic"))

local CommonGlobalStorage = {
	IsClient = false,
	PlayerTable = {}
}


function CommonGlobalStorage:CreateEmptyStatistic()
	return {
		DirtyFlag = false,
		STR = 0,
		DEF = 0,
		Move = 0,
		AttackSpeed = 0,
		
		HP = 0,
		MP = 0,
		HIT = 0,
		Dodge = 0,
		Block = 0,
		Critical = 0,
		Sight = 0
	}
end

function CommonGlobalStorage:CreateEmptyData()
	local playerData = {
		[StatusType.Statistic] = Utility:DeepCopy(PlayerStatistic),
		[StatusType.EquipSlots] = Utility:DeepCopy(EquipSlots),
		[StatusType.Inventory] = Utility:DeepCopy(Inventory)
	}
	
	return playerData
end

function CommonGlobalStorage:CheckPlayer(playerId)
	if self.PlayerTable[playerId] then
		return true
	end
	return false
end

function CommonGlobalStorage:AddPlayer(player)
	if not player then
		Debug.Assert(false, "플레이어가 존재하지 않습니다.")
		return false
	end
	
	local playerId = player.UserId
	if self:CheckPlayer(playerId) == true then
		Debug.Assert(false, "두번 추가하려고 합니다 반드시 확인해야합니다.")
		return false
	end
	
	self.PlayerTable[playerId] = self:CreateEmptyData()
	return true
end

function CommonGlobalStorage:RemovePlayer(player)
	if not player then
		Debug.Assert(false, "플레이어가 존재하지 않습니다.")
		return false
	end
	
	local playerId = player.UserId
	self.PlayerTable[playerId] = nil
	
	return true
end

function CommonGlobalStorage:ClearPlayer(player)
	if not player then
		Debug.Assert(false, "플레이어가 존재하지 않습니다.")
		return false
	end

	local playerId = player.UserId
	
	if not self:CheckPlayer(playerId) then
		Debug.Assert(false, "플레이어 데이터가 존재하지 않습니다.")
		return false
	end

	self.PlayerTable[playerId] = self:CreateEmptyData()
	return true
end

function CommonGlobalStorage:GetPlayerStatistic(playerId)
	if not self:CheckPlayer(playerId) then
		Debug.Assert(false, "플레이어가 존재하지 않습니다.")
		return nil
	end

	--self:CheckAndCalculateStatistic(playerId)
	return self.PlayerTable[playerId][StatusType.Statistic]:Get()
end

-- 각 합산된 능력치
function CommonGlobalStorage:GetStat(playerId, statType)
	if not statType then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end
	
	local targetPlayerStatistic = self:GetPlayerStatistic(playerId)
	if not targetPlayerStatistic then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local targetStat = targetPlayerStatistic:GetStat(statType)
	if nil == targetStat then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	return targetStat
end

function CommonGlobalStorage:UpdateRemovedToolGameData(playerId, toolGameData)
	if not self:CheckPlayer(playerId) then
		Debug.Assert(false, "플레이어가 존재하지 않습니다.")
		return false
	end

	local playerStatistic = self.PlayerTable[playerId][StatusType.Statistic]
	if not playerStatistic:UpdateRemovedToolGameData(toolGameData) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function CommonGlobalStorage:UpdateAddedToolGameData(playerId, toolGameData)
	if not self:CheckPlayer(playerId) then
		Debug.Assert(false, "플레이어가 존재하지 않습니다.")
		return false
	end

	local playerStatistic = self.PlayerTable[playerId][StatusType.Statistic]
	if not playerStatistic:UpdateAddedToolGameData(toolGameData) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function CommonGlobalStorage:IsInBackpack(playerId, tool)
	local player = game.Players:GetPlayerByUserId(playerId)
	return player.Backpack == tool.Parent
end

function CommonGlobalStorage:IsInCharacterRaw(playerId, tool)
	local player = game.Players:GetPlayerByUserId(playerId)
	local character = player.Character
	if not character then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	return (character == tool.Parent)
end

function CommonGlobalStorage:IsInCharacter(playerId, equipType, tool, findAll)
	local player = game.Players:GetPlayerByUserId(playerId)
	local character = player.Character
	if not character then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if equipType == EquipType.Weapon or not equipType then
		return (character == tool.Parent)
	elseif equipType == EquipType.Armor then

		if findAll and (character == tool.Parent) then
			return true
		end

		local characterArmorsFolder = character:FindFirstChild("Armors")
		if not characterArmorsFolder then
			Debug.Assert(false, "비정상입니다.")
			return false
		end
		return (characterArmorsFolder == tool.Parent)
	end
	
	return true
end

function CommonGlobalStorage:EquipTool(playerId, equipType, tool)
	if not self:CheckPlayer(playerId) then
		Debug.Assert(false, "비정상입니다.")
		return nil, nil
	end

	local equipSlots = self.PlayerTable[playerId][StatusType.EquipSlots]
	local prevTool, currentTool = equipSlots:EquipTool(equipType, tool)
	if not currentTool then
		Debug.Assert(false, "비정상입니다.")
		return nil, nil
	end

	local currentToolGameData = ToolUtility:GetGameData(currentTool)
	if not currentToolGameData then
		Debug.Assert(false, "비정상입니다.")
		return nil, nil
	end

	local prevToolGameData = nil
	if prevTool then
		prevToolGameData = ToolUtility:GetGameData(currentTool)
		if not prevToolGameData then
			Debug.Assert(false, "비정상입니다.")
			return nil, nil
		end
	end

	if prevToolGameData then
		self:UpdateRemovedToolGameData(playerId, prevToolGameData)
	end
	
	self:UpdateAddedToolGameData(playerId, currentToolGameData)
	return prevTool, currentTool
end

function CommonGlobalStorage:UnequipTool(playerId, equipType)
	if not self:CheckPlayer(playerId) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local equipSlots = self.PlayerTable[playerId][StatusType.EquipSlots]
	local prevTool = equipSlots:UnequipTool(equipType)
	if not prevTool then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local prevToolGameData = ToolUtility:GetGameData(prevTool)
	if not prevToolGameData then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end
	self:UpdateRemovedToolGameData(playerId, prevToolGameData)

	return prevTool
end

function CommonGlobalStorage:UnequipToolByTool(playerId, tool)
	if not self:CheckPlayer(playerId) then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local equipSlots = self.PlayerTable[playerId][StatusType.EquipSlots]
	local prevTool = equipSlots:UnequipToolByTool(tool)
	if not prevTool then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local prevToolGameData = ToolUtility:GetGameData(prevTool)
	if not prevToolGameData then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end
	self:UpdateRemovedToolGameData(playerId, prevToolGameData)

	return prevTool
end

function CommonGlobalStorage:GetInventorySlot(playerId, slotIndex)
	if not self:CheckPlayer(playerId) then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local inventory = self.PlayerTable[playerId][StatusType.Inventory]
	local tool = inventory:GetSlot(slotIndex)
	if nil == tool then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	return tool
end

function CommonGlobalStorage:SwapInventorySlot(playerId, slotIndex1, slotIndex2)
	if not self:CheckPlayer(playerId) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local inventory = self.PlayerTable[playerId][StatusType.Inventory]
	if not inventory:SwapSlot(slotIndex1, slotIndex2) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	return true
end

function CommonGlobalStorage:GetEquipSlot(playerId, equipType)
	if not self:CheckPlayer(playerId) then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local equipSlots = self.PlayerTable[playerId][StatusType.EquipSlots]
	local tool = equipSlots:GetSlot(equipType)
	if nil == tool then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	return tool
end

--[[
function CommonGlobalStorage:CheckAndGetArmorData(armor)
	if not armor then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local toolGameData = self:GetGameData(armor)
	if not toolGameData then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	if toolGameData.ToolType ~= ToolType.Armor then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local EquipType = toolGameData.EquipType
	if not EquipType[EquipType] then
		Debug.Assert(false, "비정상입니다. [EquipType] => " .. tostring(EquipType))
		return nil
	end
	
	return toolGameData, EquipType
end

function CommonGlobalStorage:EquipArmor(playerId, armor)
	
	if not self:CheckPlayer(playerId) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	local toolGameData, EquipType = self:CheckAndGetArmorData(armor)
	if not toolGameData then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	self:UpdateRemovedToolGameData(self.PlayerTable[playerId][StatusType.WeaponSlot].ToolGameData)
	self:UpdateAddedToolGameData(toolGameData)
	
	self.PlayerTable[playerId][StatusType.ArmorSlot][EquipType].Value = armor
	self.PlayerTable[playerId][StatusType.ArmorSlot][EquipType].ToolGameData = toolGameData
	
	return true
end
--]]

CommonGlobalStorage.__index = Utility.Inheritable__index
CommonGlobalStorage.__newindex = Utility.Inheritable__newindex

return CommonGlobalStorage




-- 한번에 장착을 위한 기능들 --
--[[
function CommonGlobalStorage:GetAllToolGameData(playerId)

	if not self:CheckPlayer(playerId) then
		Debug.Assert(false, "플레이어가 존재하지 않습니다.")
		return false
	end

	local allToolData = {}
	local toolGameData = self.PlayerTable[playerId][StatusType.WeaponSlot].ToolGameData
	if toolGameData then
		table.insert(allToolData, toolGameData)
	end

	local allArmorSlots = self.PlayerTable[playerId][StatusType.ArmorSlot]

	for _, slot in pairs(allArmorSlots) do
		toolGameData = slot.ToolGameData
		if toolGameData then
			table.insert(allToolData, toolGameData)
		end
	end

	return allToolData
end

function CommonGlobalStorage:CheckStatisticDirtyFlag(playerId)
	return self.PlayerTable[playerId][StatusType.Statistic].DirtyFlag
end

function CommonGlobalStorage:CheckAndCalculateStatistic(playerId)
	if not self:CheckPlayer(playerId) then
		Debug.Assert(false, "플레이어가 존재하지 않습니다.")
		return
	end

	if self:CheckStatisticDirtyFlag(playerId) == false then
		return
	end

	local allToolGameData = self:GetAllToolGameData(playerId)
	
	self.PlayerTable[playerId][StatusType.Statistic] = self:CreateEmptyStatistic()
	for _, toolGameData in pairs(allToolGameData) do

		for attribute, value in pairs(toolGameData) do
			self.PlayerTable[playerId][StatusType.Statistic][attribute] += value
		end
	end
end
--]]
-- 한번에 장착을 위한 기능들 --