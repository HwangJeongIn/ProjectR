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
local ArmorType = CommonEnum.ArmorType

local CommonGameDataModule = CommonModule:WaitForChild("CommonGameDataModule")
local CommonGameDataManager = require(CommonGameDataModule:WaitForChild("CommonGameDataManager"))

local ToolUtility = require(script:WaitForChild("ToolUtility"))
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
		[StatusType.Statistic] =  Utility:DeepCopy(PlayerStatistic),
		--[[
		[StatusType.ArmorSlot] = {
			-- 그냥 명시적으로 표현
			[ArmorType.Helmet] = {Value = nil, ToolGameData = nil},
			[ArmorType.Chestplate] = {Value = nil, ToolGameData = nil},
			[ArmorType.Leggings] = {Value = nil, ToolGameData = nil},
			[ArmorType.Boots] = {Value = nil, ToolGameData = nil}
		},

		-- 그냥 명시적으로 표현
		[StatusType.WeaponSlot] = {Value = nil, ToolGameData = nil},
		--]]
		[StatusType.EquipSlots] = Utility:DeepCopy(EquipSlots),
		[StatusType.Inventory] = Utility:DeepCopy(Inventory)
	}

	if self.IsClient then
		playerData[StatusType.QuickSlots] = {}
	end
	
	return playerData
end

function CommonGlobalStorage:SetClientMode()
	self.IsClient = true
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

-- Weapon은 명시적으로 장착하는 것이 없다. 그냥 들고 있으면 알아서 EquipSlot에 집어넣어야한다.
function CommonGlobalStorage:CheckAndEquipIfWeapon(playerId, tool)
	if not self.CheckPlayer(playerId) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local equipSlots = self.PlayerTable[playerId][StatusType.EquipSlots]
	if not equipSlots:CheckWeaponTool(tool) then
		return false
	end

	local prevToolGameData, currentToolGameData = equipSlots:EquipTool(tool)
	if not currentToolGameData then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if prevToolGameData then
		self:UpdateRemovedToolGameData(playerId, prevToolGameData)
	end
	
	self:UpdateAddedToolGameData(playerId, currentToolGameData)
	return true
end

function CommonGlobalStorage:EquipTool(playerId, tool)
	if not self.CheckPlayer(playerId) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	local equipSlots = self.PlayerTable[playerId][StatusType.EquipSlots]
	local prevToolGameData, currentToolGameData = equipSlots:EquipTool(tool, true)
	if not currentToolGameData then
		Debug.Assert(false, "비정상입니다.")
		return false
	end

	if prevToolGameData then
		self:UpdateRemovedToolGameData(playerId, prevToolGameData)
	end
	
	self:UpdateAddedToolGameData(playerId, currentToolGameData)
	return true
end

function CommonGlobalStorage:CheckAndGetArmorData(armor)
	if not armor then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local toolGameData = self:GetToolGameData(armor)
	if not toolGameData then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	if toolGameData.ToolType ~= ToolType.Armor then
		Debug.Assert(false, "비정상입니다.")
		return nil
	end

	local armorType = toolGameData.ArmorType
	if not ArmorType[armorType] then
		Debug.Assert(false, "비정상입니다. [ArmorType] => " .. tostring(armorType))
		return nil
	end
	
	return toolGameData, armorType
end

function CommonGlobalStorage:EquipArmor(playerId, armor)
	
	if not self:CheckPlayer(playerId) then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	local toolGameData, armorType = self:CheckAndGetArmorData(armor)
	if not toolGameData then
		Debug.Assert(false, "비정상입니다.")
		return false
	end
	
	self:UpdateRemovedToolGameData(self.PlayerTable[playerId][StatusType.WeaponSlot].ToolGameData)
	self:UpdateAddedToolGameData(toolGameData)
	
	self.PlayerTable[playerId][StatusType.ArmorSlot][armorType].Value = armor
	self.PlayerTable[playerId][StatusType.ArmorSlot][armorType].ToolGameData = toolGameData
	
	return true
end


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